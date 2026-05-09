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
## Knows about: nothing (pure resource, no node/scene dependencies).
## Used by: every system that needs randomness.

class_name RNGService extends Resource

## Note: 'seed' shadows the GDScript built-in seed() function. This is
## intentional per ARCHITECTURE.md and harmless (Godot emits a warning
## but the code works). If the warnings become noisy, rename to seed_value.
@export var seed: int = 0

## Tracks how many random calls have been made on this instance. Part of
## save state — replays must reach the same stream_position to be valid.
@export var stream_position: int = 0

var _rng: RandomNumberGenerator


func _init(p_seed: int = 0) -> void:
	seed = p_seed
	_rng = RandomNumberGenerator.new()
	_rng.seed = seed
	stream_position = 0


## Roll a single die with the given number of sides. Returns 1..sides inclusive.
func roll(sides: int) -> int:
	stream_position += 1
	return _rng.randi_range(1, sides)


## Roll multiple dice of the same kind. Returns an array of results.
func roll_dice(count: int, sides: int) -> Array[int]:
	var results: Array[int] = []
	for i in count:
		results.append(roll(sides))
	return results


## Returns true with the given probability (0.0 to 1.0).
func chance(probability: float) -> bool:
	stream_position += 1
	return _rng.randf() < probability


## Pick a random element from a non-empty array. Returns null if empty.
func pick(arr: Array) -> Variant:
	if arr.is_empty():
		return null
	stream_position += 1
	return arr[_rng.randi() % arr.size()]
