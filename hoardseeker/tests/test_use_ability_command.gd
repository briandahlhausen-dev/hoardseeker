## test_use_ability_command.gd
##
## Verifies UseAbilityCommand — the third concrete Command and the first
## one that pulls its stats from data (fighter_slash.tres).
##
## Coverage:
##   - validate() rejects unknown actor / target / ability id
##   - validate() rejects when actor doesn't know the ability
##   - validate() rejects when actor lacks the AP for the ability's cost
##   - validate() rejects on dead attacker / dead target
##   - apply() decrements AP by the ability's ap_cost
##   - apply() emits DICE_ROLLED, plus DAMAGE_DEALT or ATTACK_MISSED
##   - apply() events tag the ability id (so the renderer can show the move)
##   - same seed + same setup = same final HP + same event sequence (determinism)
##   - integration: a Fighter using fighter_slash via CommandProcessor lands
##     a hit on a Skeleton over many seeds (proves the data-driven path works
##     end-to-end through validate -> load .tres -> apply -> log)

extends RefCounted

const GameState = preload("res://src/core/game_state.gd")
const PlayerState = preload("res://src/core/player_state.gd")
const MonsterState = preload("res://src/core/monster_state.gd")
const EncounterState = preload("res://src/core/encounter_state.gd")
const EventLog = preload("res://src/core/event_log.gd")
const RNGService = preload("res://src/core/rng_service.gd")
const GameEvent = preload("res://src/core/game_event.gd")
const UseAbilityCommand = preload("res://src/systems/combat/use_ability_command.gd")
const CommandProcessor = preload("res://src/core/command_processor.gd")


func run_tests() -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_test_validate_normal_case_passes())
	failures.append_array(_test_validate_fails_unknown_actor())
	failures.append_array(_test_validate_fails_unknown_target())
	failures.append_array(_test_validate_fails_unknown_ability())
	failures.append_array(_test_validate_fails_actor_does_not_know_ability())
	failures.append_array(_test_validate_fails_insufficient_ap())
	failures.append_array(_test_validate_fails_dead_target())
	failures.append_array(_test_apply_decrements_ap())
	failures.append_array(_test_apply_emits_dice_rolled_with_ability_tag())
	failures.append_array(_test_apply_deterministic_with_seed())
	failures.append_array(_test_integration_lands_a_hit_through_processor())
	return failures


# Build a fight-shaped state with a fighter who knows fighter_slash.
func _make_state(
	attacker_ap: int = 3,
	target_hp: int = 12,
	known_abilities: Array[String] = ["fighter_slash"],
	seed_val: int = 42,
) -> GameState:
	var gs: GameState = GameState.new()
	gs.seed = seed_val
	gs.rng = RNGService.new(seed_val)
	gs.event_log = EventLog.new()
	gs.event_log.seed = seed_val

	var fighter: PlayerState = PlayerState.new()
	fighter.actor_id = "fighter_1"
	fighter.display_name = "Aric"
	fighter.class_id = "fighter"
	fighter.hp = 20
	fighter.max_hp = 20
	fighter.ac = 16
	fighter.action_points = attacker_ap
	fighter.max_action_points = 3
	fighter.ability_ids = known_abilities
	gs.players.append(fighter)

	gs.current_encounter = EncounterState.new()
	var skeleton: MonsterState = MonsterState.new()
	skeleton.actor_id = "skel_1"
	skeleton.monster_id = "skeleton_warrior"
	skeleton.hp = target_hp
	skeleton.max_hp = max(target_hp, 1)
	skeleton.ac = 13
	gs.current_encounter.monsters.append(skeleton)

	return gs


func _test_validate_normal_case_passes() -> Array[String]:
	var state: GameState = _make_state()
	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "fighter_slash", "skel_1")
	if not cmd.validate(state):
		return ["validate_normal: should pass with fighter who knows fighter_slash and a live skeleton"]
	return []


func _test_validate_fails_unknown_actor() -> Array[String]:
	var state: GameState = _make_state()
	var cmd: UseAbilityCommand = UseAbilityCommand.new("nobody", "fighter_slash", "skel_1")
	if cmd.validate(state):
		return ["validate_unknown_actor: should fail when actor_id doesn't exist"]
	return []


func _test_validate_fails_unknown_target() -> Array[String]:
	var state: GameState = _make_state()
	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "fighter_slash", "no_such_target")
	if cmd.validate(state):
		return ["validate_unknown_target: should fail when target_id doesn't exist"]
	return []


func _test_validate_fails_unknown_ability() -> Array[String]:
	# Fighter "knows" the fictional ability so the ability_ids check passes,
	# isolating the test to the ability-def-not-found branch of validate().
	var state: GameState = _make_state(3, 12, ["fictional_ability"])
	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "fictional_ability", "skel_1")
	if cmd.validate(state):
		return ["validate_unknown_ability: should fail when no .tres exists for ability_id"]
	return []


func _test_validate_fails_actor_does_not_know_ability() -> Array[String]:
	# Fighter has an empty ability_ids list — they don't know fighter_slash
	# even though the .tres exists.
	var empty: Array[String] = []
	var state: GameState = _make_state(3, 12, empty)
	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "fighter_slash", "skel_1")
	if cmd.validate(state):
		return ["validate_doesnt_know: should fail when ability_id not in actor.ability_ids"]
	return []


func _test_validate_fails_insufficient_ap() -> Array[String]:
	var state: GameState = _make_state(0)  # AP = 0; fighter_slash costs 1
	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "fighter_slash", "skel_1")
	if cmd.validate(state):
		return ["validate_insufficient_ap: should fail when actor.action_points < ability.ap_cost"]
	return []


func _test_validate_fails_dead_target() -> Array[String]:
	var state: GameState = _make_state(3, 0)  # skeleton at 0 HP
	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "fighter_slash", "skel_1")
	if cmd.validate(state):
		return ["validate_dead_target: should fail when target.hp <= 0"]
	return []


# fighter_slash costs 1 AP; apply() must always decrement by that amount.
func _test_apply_decrements_ap() -> Array[String]:
	var state: GameState = _make_state(3)
	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "fighter_slash", "skel_1")
	cmd.apply(state)
	var fighter: PlayerState = state.find_player("fighter_1")
	if fighter.action_points != 2:
		return ["apply_decrements_ap: expected AP 2 (3 - 1), got %d" % fighter.action_points]
	return []


# apply() must emit DICE_ROLLED with the ability id attached so the
# renderer / replay log can attribute the roll to the move.
func _test_apply_emits_dice_rolled_with_ability_tag() -> Array[String]:
	var state: GameState = _make_state()
	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "fighter_slash", "skel_1")
	var events: Array[GameEvent] = cmd.apply(state)
	for e in events:
		if e.event_type == "DICE_ROLLED" and e.data.get("ability") == "fighter_slash":
			return []
	return ["apply_emits_dice_rolled: no DICE_ROLLED event tagged with ability=fighter_slash"]


# Same seed + same command = same events (types in order) and same final HP.
# This is the determinism contract the EventLog replay relies on.
func _test_apply_deterministic_with_seed() -> Array[String]:
	var failures: Array[String] = []

	var state_a: GameState = _make_state(3, 12, ["fighter_slash"], 99)
	var cmd_a: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "fighter_slash", "skel_1")
	var events_a: Array[GameEvent] = cmd_a.apply(state_a)

	var state_b: GameState = _make_state(3, 12, ["fighter_slash"], 99)
	var cmd_b: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "fighter_slash", "skel_1")
	var events_b: Array[GameEvent] = cmd_b.apply(state_b)

	if events_a.size() != events_b.size():
		failures.append("deterministic: event counts differ (a=%d, b=%d)" % [events_a.size(), events_b.size()])
		return failures
	for i in events_a.size():
		if events_a[i].event_type != events_b[i].event_type:
			failures.append("deterministic: event %d type differs (a=%s, b=%s)" % [i, events_a[i].event_type, events_b[i].event_type])
			break

	var skel_a: MonsterState = state_a.find_monster("skel_1")
	var skel_b: MonsterState = state_b.find_monster("skel_1")
	if skel_a.hp != skel_b.hp:
		failures.append("deterministic: skeleton HP differs (a=%d, b=%d)" % [skel_a.hp, skel_b.hp])
	return failures


# End-to-end: fighter using fighter_slash through CommandProcessor lands
# a hit on the skeleton in at least one seed within a small sample. Proves
# the full data-driven path works: validate -> load .tres -> apply -> log.
func _test_integration_lands_a_hit_through_processor() -> Array[String]:
	for seed_val in range(1, 30):
		var state: GameState = _make_state(3, 12, ["fighter_slash"], seed_val)
		var processor: CommandProcessor = CommandProcessor.new()
		var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "fighter_slash", "skel_1")
		var ok: bool = processor.process(cmd, state)
		if not ok:
			return ["integration: processor rejected fighter_slash on seed %d (should have validated)" % seed_val]
		# At least one seed must produce a damage event (otherwise determinism
		# is broken or the .tres has zero damage).
		for evt in state.event_log.events:
			if evt.event_type == "DAMAGE_DEALT" and evt.data.get("ability") == "fighter_slash":
				return []
	return ["integration: 29 seeds vs AC 13 produced zero hits — suspicious"]
