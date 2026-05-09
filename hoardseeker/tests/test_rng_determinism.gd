## test_rng_determinism.gd
##
## Proves the foundational architecture promise:
## same seed + same sequence of calls = identical results, every time.
##
## If this test ever fails, the whole replay-validation / duo-lockstep /
## save-load story breaks. This test is the canary.
##
## Uses preload() rather than the global class_name so the test runs
## reliably from a fresh project state (without requiring an --import pass
## to build Godot's class registry first).

extends RefCounted

const RNGService = preload("res://src/core/rng_service.gd")


func run_tests() -> Array[String]:
	var failures: Array[String] = []

	failures.append_array(_test_same_seed_same_rolls())
	failures.append_array(_test_different_seeds_diverge())
	failures.append_array(_test_stream_position_tracks_calls())
	failures.append_array(_test_roll_dice_returns_correct_count())
	failures.append_array(_test_roll_in_range())
	failures.append_array(_test_chance_distribution_basic())
	failures.append_array(_test_pick_handles_empty())
	failures.append_array(_test_pick_returns_array_member())

	return failures


# Two RNGService instances with the same seed must produce identical
# sequences of every kind of call.
func _test_same_seed_same_rolls() -> Array[String]:
	var a := RNGService.new(42)
	var b := RNGService.new(42)
	var failures: Array[String] = []

	for i in 1000:
		var ra := a.roll(20)
		var rb := b.roll(20)
		if ra != rb:
			failures.append("same_seed_same_rolls: roll #%d diverged (a=%d, b=%d)" % [i, ra, rb])
			break  # one failure is enough; don't spam

	# Mixed call types
	a = RNGService.new(99)
	b = RNGService.new(99)
	for i in 100:
		var dice_a := a.roll_dice(3, 6)
		var dice_b := b.roll_dice(3, 6)
		if dice_a != dice_b:
			failures.append("same_seed_same_rolls: roll_dice #%d diverged (a=%s, b=%s)" % [i, dice_a, dice_b])
			break
		var ca := a.chance(0.5)
		var cb := b.chance(0.5)
		if ca != cb:
			failures.append("same_seed_same_rolls: chance #%d diverged (a=%s, b=%s)" % [i, ca, cb])
			break

	return failures


# Different seeds should diverge at least somewhere across many calls.
# (A tiny chance of a false positive exists but practically zero across 1000 calls.)
func _test_different_seeds_diverge() -> Array[String]:
	var a := RNGService.new(1)
	var b := RNGService.new(2)
	var diverged := false
	for i in 1000:
		if a.roll(20) != b.roll(20):
			diverged = true
			break
	if not diverged:
		return ["different_seeds_diverge: 1000 rolls of d20 with seed 1 vs seed 2 produced identical sequences (extremely improbable)"]
	return []


# stream_position must increment with every random call.
func _test_stream_position_tracks_calls() -> Array[String]:
	var rng := RNGService.new(7)
	var failures: Array[String] = []
	if rng.stream_position != 0:
		failures.append("stream_position: fresh instance not at 0 (was %d)" % rng.stream_position)

	rng.roll(20)
	if rng.stream_position != 1:
		failures.append("stream_position: after 1 roll() expected 1, got %d" % rng.stream_position)

	rng.roll_dice(3, 6)  # 3 internal roll() calls
	if rng.stream_position != 4:
		failures.append("stream_position: after roll_dice(3,6) expected 4 total, got %d" % rng.stream_position)

	rng.chance(0.5)
	if rng.stream_position != 5:
		failures.append("stream_position: after chance() expected 5, got %d" % rng.stream_position)

	rng.pick([1, 2, 3])
	if rng.stream_position != 6:
		failures.append("stream_position: after pick() expected 6, got %d" % rng.stream_position)

	return failures


# roll_dice must return an array of the requested count.
func _test_roll_dice_returns_correct_count() -> Array[String]:
	var rng := RNGService.new(7)
	var dice := rng.roll_dice(5, 6)
	if dice.size() != 5:
		return ["roll_dice: expected 5 results, got %d" % dice.size()]
	return []


# All roll() results must be in [1, sides].
func _test_roll_in_range() -> Array[String]:
	var rng := RNGService.new(13)
	for i in 1000:
		var result := rng.roll(20)
		if result < 1 or result > 20:
			return ["roll_in_range: roll(20) returned %d (out of range)" % result]
	return []


# chance() with probability 0.0 should always be false; 1.0 always true.
func _test_chance_distribution_basic() -> Array[String]:
	var rng := RNGService.new(31)
	var failures: Array[String] = []
	for i in 100:
		if rng.chance(0.0):
			failures.append("chance_distribution_basic: chance(0.0) returned true at iter %d" % i)
			break
	for i in 100:
		if not rng.chance(1.0):
			failures.append("chance_distribution_basic: chance(1.0) returned false at iter %d" % i)
			break
	return failures


# pick() on empty array must return null.
func _test_pick_handles_empty() -> Array[String]:
	var rng := RNGService.new(99)
	var result = rng.pick([])
	if result != null:
		return ["pick_handles_empty: expected null, got %s" % str(result)]
	return []


# pick() must return a member of the input array.
func _test_pick_returns_array_member() -> Array[String]:
	var rng := RNGService.new(99)
	var arr := [10, 20, 30, 40, 50]
	for i in 100:
		var result = rng.pick(arr)
		if not (result in arr):
			return ["pick_returns_array_member: pick returned %s which is not in %s" % [str(result), str(arr)]]
	return []
