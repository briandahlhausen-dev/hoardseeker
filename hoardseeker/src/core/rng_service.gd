## RNGService
##
## Deterministic random number generator. ALL gameplay randomness flows
## through this service. Same seed + same sequence of calls = same results,
## every time, on every machine, forever.
##
## This is what makes replay-based anti-cheat possible (the server can
## re-simulate any run from its seed + command log) and what makes lockstep
## duo networking possible (both peers compute identical results).
##
## Banned in game logic: randi(), randf(), randf_range(), Time.*,
## OS.get_unix_time(), Engine.get_frames_drawn(). Use this service instead.
##
## Renderers and animations may use the global randf() for visual jitter
## (no gameplay impact). RNGService is for gameplay only.
##
## Save / replay design:
## ---------------------
## Persists `seed`, `rng_state`, and `stream_position`:
##
## - `seed` is the run identifier — stable, doesn't change after _init.
## - `rng_state` is Godot's underlying PRNG state — the "where am I in
##   the stream" pointer. Updated after every consumer call. This is
##   what lets a duplicated RNGService produce the same NEXT result as
##   the original would have, regardless of how many calls preceded.
## - `stream_position` is a diagnostic call counter. NOT used to
##   reconstruct PRNG position; `rng_state` does that.
##
## Duplicate-safety:
## -----------------
## The service does NOT keep a persistent `RandomNumberGenerator` field.
## Every method allocates a fresh one, sets its state from the persisted
## fields, makes the call, and writes the new state back. This is the
## only correctness path through Godot's Resource model:
##
##   - A `var _rng: RandomNumberGenerator` field is shallow-copied by
##     `Resource.duplicate(true)` (verified empirically), so original
##     and copy would SHARE a single PRNG instance — calls on one would
##     advance the other.
##   - We can't override `duplicate()` cleanly in GDScript to null out
##     the field on the copy.
##   - Lazy reconstruction from `stream_position` doesn't work because
##     `randi_range()` uses rejection sampling and consumes a variable
##     number of underlying ticks per call.
##
## Allocation cost is one `RandomNumberGenerator.new()` per consumer
## call — a tiny RefCounted Object, microseconds in practice. At gameplay
## RNG-call rates this is irrelevant.
##
## Why state, not call-count, for save state: `randi_range()` uses
## rejection sampling internally, so it can consume a variable number
## of underlying PRNG ticks per call. Counting calls and replaying via
## `randi()` does NOT reproduce the same internal state. Persisting
## `state` directly captures the position regardless of method type.
##
## Knows about: nothing (pure resource, no node/scene dependencies).
## Used by: every system that needs randomness.

class_name RNGService extends Resource

## The run's master seed. Stable identifier — doesn't change after _init.
## Note: 'seed' shadows the GDScript built-in seed() function. This is
## intentional per ARCHITECTURE.md and harmless (Godot emits a warning
## but the code works).
@export var seed: int = 0

## The underlying Godot RandomNumberGenerator state. Updated after every
## consumer call. This is the load-bearing field for replay correctness:
## given seed + rng_state, we reconstruct the PRNG to the exact same
## position regardless of how many calls of which kind got us there.
@export var rng_state: int = 0

## Diagnostic counter — how many consumer calls have been made. Each
## public method (roll / chance / pick) increments by 1. Useful for
## "the log says 47 calls happened, did we actually make 47?" assertions.
## Not used for PRNG reconstruction; rng_state is.
@export var stream_position: int = 0


func _init(p_seed: int = 0) -> void:
	seed = p_seed
	stream_position = 0
	# Capture the post-seed PRNG state. Without this, rng_state stays
	# at its 0 default and _build_rng can't tell "fresh" from "explicitly
	# at state 0" (which IS a valid PRNG state).
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed
	rng_state = rng.state


## Construct a fresh RandomNumberGenerator at the persisted state.
## Always returns a new instance — never shared. This is what keeps
## Resource.duplicate(true) safe; see the duplicate-safety section in
## the class header.
func _build_rng() -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed
	rng.state = rng_state
	return rng


## Roll a single die with the given number of sides. Returns 1..sides inclusive.
func roll(sides: int) -> int:
	var rng: RandomNumberGenerator = _build_rng()
	var result: int = rng.randi_range(1, sides)
	stream_position += 1
	rng_state = rng.state
	return result


## Roll multiple dice of the same kind. Returns an array of results.
func roll_dice(count: int, sides: int) -> Array[int]:
	var results: Array[int] = []
	for i in count:
		results.append(roll(sides))
	return results


## Returns true with the given probability (0.0 to 1.0).
func chance(probability: float) -> bool:
	var rng: RandomNumberGenerator = _build_rng()
	var result: bool = rng.randf() < probability
	stream_position += 1
	rng_state = rng.state
	return result


## Pick a random element from a non-empty array. Returns null if empty.
func pick(arr: Array) -> Variant:
	if arr.is_empty():
		return null
	var rng: RandomNumberGenerator = _build_rng()
	var result: Variant = arr[rng.randi() % arr.size()]
	stream_position += 1
	rng_state = rng.state
	return result
