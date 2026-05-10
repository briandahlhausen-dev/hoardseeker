## test_attack_command.gd
##
## Verifies AttackCommand — the first concrete Command subclass — covers
## the validate/apply contract, decrements AP, mutates target HP, emits
## the right events, and produces deterministic results given a seed.
##
## Tests use preload() rather than the global class registry so they run
## reliably even before --import populates the registry. Same pattern as
## test_rng_determinism and test_game_state_serialization.

extends RefCounted

const AttackCommand = preload("res://src/systems/combat/attack_command.gd")
const GameState = preload("res://src/core/game_state.gd")
const PlayerState = preload("res://src/core/player_state.gd")
const RNGService = preload("res://src/core/rng_service.gd")
const GameEvent = preload("res://src/core/game_event.gd")


func run_tests() -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_test_validate_normal_case_passes())
	failures.append_array(_test_validate_fails_no_attacker())
	failures.append_array(_test_validate_fails_no_target())
	failures.append_array(_test_validate_fails_zero_hp_attacker())
	failures.append_array(_test_validate_fails_zero_hp_target())
	failures.append_array(_test_validate_fails_insufficient_ap())
	failures.append_array(_test_apply_decrements_ap())
	failures.append_array(_test_apply_emits_dice_rolled_event())
	failures.append_array(_test_apply_deterministic_with_seed())
	failures.append_array(_test_apply_can_defeat_target())
	failures.append_array(_test_apply_emits_hit_or_miss_consistently())
	# Phase F — damage type + resistance
	failures.append_array(_test_target_with_resistance_takes_half_damage())
	failures.append_array(_test_immunity_zeroes_damage_on_hit())
	failures.append_array(_test_no_resistance_entry_means_full_damage())
	return failures


# Build a GameState with two players in a known starting configuration.
func _make_state(
	attacker_hp: int = 20,
	target_hp: int = 20,
	attacker_ap: int = 3,
	target_ac: int = 14,
	seed_val: int = 42,
) -> GameState:
	var gs: GameState = GameState.new()
	gs.seed = seed_val
	gs.rng = RNGService.new(seed_val)

	var p1: PlayerState = PlayerState.new()
	p1.actor_id = "p1"
	p1.hp = attacker_hp
	p1.max_hp = max(attacker_hp, 1)
	p1.ac = 14
	p1.action_points = attacker_ap

	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "p2"
	p2.hp = target_hp
	p2.max_hp = max(target_hp, 1)
	p2.ac = target_ac
	p2.action_points = 3

	gs.players.append(p1)
	gs.players.append(p2)
	return gs


# Normal valid setup: validate() returns true.
func _test_validate_normal_case_passes() -> Array[String]:
	var state: GameState = _make_state()
	var cmd: AttackCommand = AttackCommand.new("p1", "p2")
	if not cmd.validate(state):
		return ["validate_normal_case: should pass with valid setup"]
	return []


# Missing attacker -> validate fails.
func _test_validate_fails_no_attacker() -> Array[String]:
	var state: GameState = _make_state()
	var cmd: AttackCommand = AttackCommand.new("nonexistent", "p2")
	if cmd.validate(state):
		return ["validate_fails_no_attacker: should fail when attacker doesn't exist"]
	return []


# Missing target -> validate fails.
func _test_validate_fails_no_target() -> Array[String]:
	var state: GameState = _make_state()
	var cmd: AttackCommand = AttackCommand.new("p1", "nonexistent")
	if cmd.validate(state):
		return ["validate_fails_no_target: should fail when target doesn't exist"]
	return []


# Attacker at 0 HP -> validate fails (can't attack while dead).
func _test_validate_fails_zero_hp_attacker() -> Array[String]:
	var state: GameState = _make_state(0, 20)
	var cmd: AttackCommand = AttackCommand.new("p1", "p2")
	if cmd.validate(state):
		return ["validate_fails_zero_hp_attacker: should fail when attacker has 0 HP"]
	return []


# Target at 0 HP -> validate fails (can't attack the already-defeated).
func _test_validate_fails_zero_hp_target() -> Array[String]:
	var state: GameState = _make_state(20, 0)
	var cmd: AttackCommand = AttackCommand.new("p1", "p2")
	if cmd.validate(state):
		return ["validate_fails_zero_hp_target: should fail when target has 0 HP"]
	return []


# Insufficient AP -> validate fails.
func _test_validate_fails_insufficient_ap() -> Array[String]:
	var state: GameState = _make_state(20, 20, 0)  # attacker AP = 0
	var cmd: AttackCommand = AttackCommand.new("p1", "p2")
	cmd.ap_cost = 1
	if cmd.validate(state):
		return ["validate_fails_insufficient_ap: should fail when AP < cost"]
	return []


# apply() always decrements AP by ap_cost (hit or miss).
func _test_apply_decrements_ap() -> Array[String]:
	var state: GameState = _make_state(20, 20, 3)
	var cmd: AttackCommand = AttackCommand.new("p1", "p2")
	cmd.ap_cost = 2
	cmd.apply(state)
	var attacker: PlayerState = state.find_player("p1")
	if attacker.action_points != 1:
		return ["apply_decrements_ap: expected AP 1 (3-2), got %d" % attacker.action_points]
	return []


# apply() always emits a DICE_ROLLED event for the attack roll.
func _test_apply_emits_dice_rolled_event() -> Array[String]:
	var state: GameState = _make_state()
	var cmd: AttackCommand = AttackCommand.new("p1", "p2")
	var events: Array[GameEvent] = cmd.apply(state)
	for e in events:
		if e.event_type == "DICE_ROLLED":
			return []
	return ["apply_emits_dice_rolled: no DICE_ROLLED event in result"]


# Same seed + same setup = same events + same final state. This is the
# foundational determinism contract for all commands.
func _test_apply_deterministic_with_seed() -> Array[String]:
	var failures: Array[String] = []

	var state_a: GameState = _make_state(20, 20, 3, 14, 42)
	var cmd_a: AttackCommand = AttackCommand.new("p1", "p2")
	var events_a: Array[GameEvent] = cmd_a.apply(state_a)

	var state_b: GameState = _make_state(20, 20, 3, 14, 42)
	var cmd_b: AttackCommand = AttackCommand.new("p1", "p2")
	var events_b: Array[GameEvent] = cmd_b.apply(state_b)

	if events_a.size() != events_b.size():
		failures.append("deterministic: event counts differ (a=%d, b=%d)" % [events_a.size(), events_b.size()])
		return failures

	for i in events_a.size():
		if events_a[i].event_type != events_b[i].event_type:
			failures.append("deterministic: event %d type differs (a=%s, b=%s)" % [i, events_a[i].event_type, events_b[i].event_type])

	var p2_a: PlayerState = state_a.find_player("p2")
	var p2_b: PlayerState = state_b.find_player("p2")
	if p2_a.hp != p2_b.hp:
		failures.append("deterministic: target HP differs after apply (a=%d, b=%d)" % [p2_a.hp, p2_b.hp])

	return failures


# When a hit lands and target is at 1 HP with massive damage, ACTOR_DEFEATED
# fires. Try multiple seeds to find one where the attack hits.
func _test_apply_can_defeat_target() -> Array[String]:
	for seed_val in range(1, 50):
		var state: GameState = _make_state(20, 1, 3, 10, seed_val)
		var cmd: AttackCommand = AttackCommand.new("p1", "p2")
		cmd.damage_dice_count = 1
		cmd.damage_dice_sides = 100
		var events: Array[GameEvent] = cmd.apply(state)
		for e in events:
			if e.event_type == "ACTOR_DEFEATED" and e.data.get("target") == "p2":
				return []
	return ["apply_can_defeat_target: 50 seeds vs 1 HP target with massive damage produced no ACTOR_DEFEATED event"]


# Across many seeds: each apply() emits exactly one of DAMAGE_DEALT or
# ATTACK_MISSED — never both, never neither.
func _test_apply_emits_hit_or_miss_consistently() -> Array[String]:
	for seed_val in range(1, 30):
		var state: GameState = _make_state(20, 100, 3, 14, seed_val)
		var cmd: AttackCommand = AttackCommand.new("p1", "p2")
		var events: Array[GameEvent] = cmd.apply(state)
		var hit_count: int = 0
		var miss_count: int = 0
		for e in events:
			if e.event_type == "DAMAGE_DEALT":
				hit_count += 1
			elif e.event_type == "ATTACK_MISSED":
				miss_count += 1
		if hit_count + miss_count != 1:
			return ["hit_or_miss: seed %d produced %d hits + %d misses (expected exactly one)" % [seed_val, hit_count, miss_count]]
	return []


# --- Phase F: damage type + resistance ---

# When the target has 0.5 resistance to the attack's damage type, the
# damage applied is half the rolled total (int-truncated). Verified
# across multiple seeds — find one where the attack hits, compare the
# DAMAGE_DEALT amount vs an unresisted reference run with the same seed.
func _test_target_with_resistance_takes_half_damage() -> Array[String]:
	for seed_val in range(1, 50):
		# Reference run: target with NO resistance
		var ref_state: GameState = _make_state(20, 100, 3, 10, seed_val)
		var ref_cmd: AttackCommand = AttackCommand.new("p1", "p2")
		var ref_events: Array[GameEvent] = ref_cmd.apply(ref_state)
		var ref_damage: int = -1
		for e in ref_events:
			if e.event_type == "DAMAGE_DEALT":
				ref_damage = e.data.get("amount", 0)
				break
		if ref_damage <= 1:  # need a hit with at least 2 damage so halving is observable
			continue

		# Resistance run: same seed + same setup, but target resists physical at 0.5
		var resist_state: GameState = _make_state(20, 100, 3, 10, seed_val)
		resist_state.find_player("p2").damage_resistances = {"physical": 0.5}
		var resist_cmd: AttackCommand = AttackCommand.new("p1", "p2")
		var resist_events: Array[GameEvent] = resist_cmd.apply(resist_state)
		var resist_damage: int = -1
		for e in resist_events:
			if e.event_type == "DAMAGE_DEALT":
				resist_damage = e.data.get("amount", 0)
				break

		if resist_damage == -1:
			return ["resistance_half: seed %d, reference hit but resistance run produced no DAMAGE_DEALT" % seed_val]
		var expected: int = int(ref_damage * 0.5)
		if resist_damage != expected:
			return ["resistance_half: seed %d, expected %d (= %d * 0.5), got %d" % [seed_val, expected, ref_damage, resist_damage]]
		return []
	return ["resistance_half: 49 seeds produced no qualifying hits with damage > 1 (suspicious)"]


# Resistance multiplier of 0.0 = immunity. Hit lands but damage is 0.
# DAMAGE_DEALT still fires (with amount 0) so the renderer shows
# "Immune" rather than no feedback.
func _test_immunity_zeroes_damage_on_hit() -> Array[String]:
	for seed_val in range(1, 30):
		var state: GameState = _make_state(20, 100, 3, 10, seed_val)
		state.find_player("p2").damage_resistances = {"physical": 0.0}
		var cmd: AttackCommand = AttackCommand.new("p1", "p2")
		var events: Array[GameEvent] = cmd.apply(state)
		# Only check seeds where the attack actually hit
		var hit: bool = false
		for e in events:
			if e.event_type == "DAMAGE_DEALT":
				hit = true
				if e.data.get("amount") != 0:
					return ["immunity: seed %d hit but damage was %d (expected 0 for immunity)" % [seed_val, e.data.get("amount")]]
				break
		if hit:
			# Target HP must be unchanged
			if state.find_player("p2").hp != 100:
				return ["immunity: seed %d hit but target HP changed (expected 100, got %d)" % [seed_val, state.find_player("p2").hp]]
			return []
	return ["immunity: 29 seeds produced no hits (sample too small or AC too high)"]


# Target with NO entry for the attack's damage_type takes full damage.
# Missing key -> default 1.0 multiplier. This is the back-compat path.
func _test_no_resistance_entry_means_full_damage() -> Array[String]:
	for seed_val in range(1, 30):
		# Target with resistance to a DIFFERENT type than the attack
		var state: GameState = _make_state(20, 100, 3, 10, seed_val)
		state.find_player("p2").damage_resistances = {"fire": 0.0}  # immune to fire, but attack is physical
		var cmd: AttackCommand = AttackCommand.new("p1", "p2")
		var events: Array[GameEvent] = cmd.apply(state)
		var damage: int = -1
		for e in events:
			if e.event_type == "DAMAGE_DEALT":
				damage = e.data.get("amount", 0)
				break
		if damage > 0:
			# Compare against a non-resistance run with same seed — should be identical
			var ref_state: GameState = _make_state(20, 100, 3, 10, seed_val)
			var ref_cmd: AttackCommand = AttackCommand.new("p1", "p2")
			var ref_events: Array[GameEvent] = ref_cmd.apply(ref_state)
			var ref_damage: int = -1
			for e in ref_events:
				if e.event_type == "DAMAGE_DEALT":
					ref_damage = e.data.get("amount", 0)
					break
			if damage != ref_damage:
				return ["no_match: seed %d, fire-immunity should not affect physical damage (ref=%d, with-fire-immunity=%d)" % [seed_val, ref_damage, damage]]
			return []
	return ["no_match: 29 seeds produced no hits (sample too small)"]
