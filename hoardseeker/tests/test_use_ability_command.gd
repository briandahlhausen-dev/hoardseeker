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
const MonsterDef = preload("res://src/content/monsters/monster_def.gd")

const SKELETON_WARRIOR_PATH := "res://src/content/monsters/skeleton_warrior.tres"


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
	# Multi-target coverage (chunk 5)
	failures.append_array(_test_multi_target_factory_constructs_command())
	failures.append_array(_test_validate_fails_target_count_mismatch_too_few())
	failures.append_array(_test_validate_fails_target_count_mismatch_too_many())
	failures.append_array(_test_validate_fails_one_of_two_targets_dead())
	failures.append_array(_test_cleave_apply_decrements_ap_only_once())
	failures.append_array(_test_cleave_apply_emits_per_target_events())
	failures.append_array(_test_cleave_apply_deterministic())
	# Phase C — heal path coverage (fighter_second_wind)
	failures.append_array(_test_self_target_factory_constructs_command())
	failures.append_array(_test_second_wind_validates_when_fighter_knows_it())
	failures.append_array(_test_second_wind_heals_caster())
	failures.append_array(_test_second_wind_caps_heal_at_max_hp())
	failures.append_array(_test_second_wind_emits_healed_event_no_attack_roll())
	failures.append_array(_test_second_wind_decrements_ap())
	# Phase H — execute mechanic (champion_critical_finisher)
	failures.append_array(_test_execute_does_not_trigger_above_threshold())
	failures.append_array(_test_execute_can_instakill_below_threshold())
	failures.append_array(_test_execute_fail_falls_through_to_damage())
	# Phase K — applies_effects on AbilityDef
	failures.append_array(_test_applies_effects_on_hit())
	failures.append_array(_test_does_not_apply_effects_on_miss())
	failures.append_array(_test_does_not_apply_effects_on_defeated_target())
	failures.append_array(_test_applies_effects_on_heal())
	# Phase L — save throws
	failures.append_array(_test_save_success_skips_effect_application())
	failures.append_array(_test_save_fail_applies_effect())
	failures.append_array(_test_save_does_not_skip_damage())
	failures.append_array(_test_no_save_type_means_no_save_roll())
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
	var skeleton: MonsterState = (load(SKELETON_WARRIOR_PATH) as MonsterDef).spawn_monster_state("skel_1")
	# Override HP for tests that exercise low-HP / dead-target validation paths.
	skeleton.hp = target_hp
	skeleton.max_hp = max(target_hp, 1)
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


# Build a fight with a fighter and TWO skeletons, for cleave-style coverage.
# Mirrors _make_state but with multi-monster encounter and known_abilities
# defaulting to fighter_cleave so callers don't have to repeat it.
func _make_multi_state(
	attacker_ap: int = 3,
	skel_hp: int = 12,
	known_abilities: Array[String] = ["fighter_cleave"],
	seed_val: int = 42,
) -> GameState:
	var gs: GameState = GameState.new()
	gs.seed = seed_val
	gs.rng = RNGService.new(seed_val)
	gs.event_log = EventLog.new()
	gs.event_log.seed = seed_val

	var fighter: PlayerState = PlayerState.new()
	fighter.actor_id = "fighter_1"
	fighter.hp = 20
	fighter.max_hp = 20
	fighter.ac = 16
	fighter.action_points = attacker_ap
	fighter.max_action_points = 3
	fighter.ability_ids = known_abilities
	gs.players.append(fighter)

	gs.current_encounter = EncounterState.new()
	var skeleton_def: MonsterDef = load(SKELETON_WARRIOR_PATH) as MonsterDef
	for actor_id in ["skel_1", "skel_2"]:
		var skel: MonsterState = skeleton_def.spawn_monster_state(actor_id)
		# Override HP per test parameter (validation tests use low values).
		skel.hp = skel_hp
		skel.max_hp = max(skel_hp, 1)
		gs.current_encounter.monsters.append(skel)

	return gs


# The static factory builds a UseAbilityCommand with N target_ids without
# using the single-target back-compat ctor. This is the path multi-target
# callers will use.
func _test_multi_target_factory_constructs_command() -> Array[String]:
	var cmd: UseAbilityCommand = UseAbilityCommand.multi_target(
		"fighter_1", "fighter_cleave", ["skel_1", "skel_2"]
	)
	var failures: Array[String] = []
	if cmd.actor_id != "fighter_1":
		failures.append("multi_factory: actor_id wrong, got '%s'" % cmd.actor_id)
	if cmd.ability_id != "fighter_cleave":
		failures.append("multi_factory: ability_id wrong, got '%s'" % cmd.ability_id)
	if cmd.target_ids.size() != 2:
		failures.append("multi_factory: expected 2 target_ids, got %d" % cmd.target_ids.size())
	elif cmd.target_ids[0] != "skel_1" or cmd.target_ids[1] != "skel_2":
		failures.append("multi_factory: target_ids contents wrong: %s" % str(cmd.target_ids))
	if cmd.command_type != "USE_ABILITY":
		failures.append("multi_factory: command_type should be USE_ABILITY, got '%s'" % cmd.command_type)
	return failures


# Cleave declares target_count=2; supplying only 1 target must reject at
# validate. This is what stops the single-target back-compat ctor from
# accidentally driving a multi-target ability.
func _test_validate_fails_target_count_mismatch_too_few() -> Array[String]:
	var state: GameState = _make_multi_state()
	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "fighter_cleave", "skel_1")
	if cmd.validate(state):
		return ["target_count_too_few: cleave with 1 target should be rejected (target_count=2)"]
	return []


# Slash declares target_count=1; supplying 2 targets must reject at validate.
# The opposite mismatch direction.
func _test_validate_fails_target_count_mismatch_too_many() -> Array[String]:
	var state: GameState = _make_multi_state(3, 12, ["fighter_slash"])
	var cmd: UseAbilityCommand = UseAbilityCommand.multi_target(
		"fighter_1", "fighter_slash", ["skel_1", "skel_2"]
	)
	if cmd.validate(state):
		return ["target_count_too_many: slash with 2 targets should be rejected (target_count=1)"]
	return []


# All declared targets must be alive; if any is dead, validate rejects.
# The "any" semantic prevents a cleave from "wasting" an attack on a corpse.
func _test_validate_fails_one_of_two_targets_dead() -> Array[String]:
	var state: GameState = _make_multi_state()
	state.find_monster("skel_2").hp = 0
	var cmd: UseAbilityCommand = UseAbilityCommand.multi_target(
		"fighter_1", "fighter_cleave", ["skel_1", "skel_2"]
	)
	if cmd.validate(state):
		return ["one_target_dead: cleave should reject when any target is at 0 HP"]
	return []


# Cleave costs 2 AP. apply() must decrement AP by exactly 2, NOT by 4
# (twice for two targets). This is the "AP cost paid once per command"
# rule and the easiest invariant to break in a multi-target loop.
func _test_cleave_apply_decrements_ap_only_once() -> Array[String]:
	var state: GameState = _make_multi_state(3)
	var cmd: UseAbilityCommand = UseAbilityCommand.multi_target(
		"fighter_1", "fighter_cleave", ["skel_1", "skel_2"]
	)
	cmd.apply(state)
	var fighter: PlayerState = state.find_player("fighter_1")
	if fighter.action_points != 1:
		return ["cleave_ap: expected AP 1 (3 - 2), got %d" % fighter.action_points]
	return []


# Multi-target apply must emit at least one DICE_ROLLED per target,
# tagged with the target's id. This is what lets the renderer / replay
# attribute each roll to a specific enemy.
func _test_cleave_apply_emits_per_target_events() -> Array[String]:
	var state: GameState = _make_multi_state(3)
	var cmd: UseAbilityCommand = UseAbilityCommand.multi_target(
		"fighter_1", "fighter_cleave", ["skel_1", "skel_2"]
	)
	var events: Array[GameEvent] = cmd.apply(state)

	var dice_rolled_targets: Dictionary = {}
	for evt in events:
		if evt.event_type == "DICE_ROLLED" and evt.data.has("target"):
			dice_rolled_targets[evt.data.get("target")] = true

	var failures: Array[String] = []
	if not dice_rolled_targets.has("skel_1"):
		failures.append("cleave_events: no DICE_ROLLED tagged target=skel_1")
	if not dice_rolled_targets.has("skel_2"):
		failures.append("cleave_events: no DICE_ROLLED tagged target=skel_2")
	return failures


# Same seed + same multi-target sequence = same final HP for both targets
# and same event-type stream. Multi-target determinism — important
# because per-target loops can hide subtle ordering bugs.
func _test_cleave_apply_deterministic() -> Array[String]:
	var failures: Array[String] = []

	var sa: GameState = _make_multi_state(3, 12, ["fighter_cleave"], 77)
	var cmda: UseAbilityCommand = UseAbilityCommand.multi_target(
		"fighter_1", "fighter_cleave", ["skel_1", "skel_2"]
	)
	var ea: Array[GameEvent] = cmda.apply(sa)

	var sb: GameState = _make_multi_state(3, 12, ["fighter_cleave"], 77)
	var cmdb: UseAbilityCommand = UseAbilityCommand.multi_target(
		"fighter_1", "fighter_cleave", ["skel_1", "skel_2"]
	)
	var eb: Array[GameEvent] = cmdb.apply(sb)

	if ea.size() != eb.size():
		failures.append("cleave_deterministic: event counts differ (a=%d, b=%d)" % [ea.size(), eb.size()])
		return failures

	for i in ea.size():
		if ea[i].event_type != eb[i].event_type:
			failures.append("cleave_deterministic: event %d type differs (a=%s, b=%s)" % [i, ea[i].event_type, eb[i].event_type])
			break

	if sa.find_monster("skel_1").hp != sb.find_monster("skel_1").hp:
		failures.append("cleave_deterministic: skel_1 HP differs (a=%d, b=%d)" % [sa.find_monster("skel_1").hp, sb.find_monster("skel_1").hp])
	if sa.find_monster("skel_2").hp != sb.find_monster("skel_2").hp:
		failures.append("cleave_deterministic: skel_2 HP differs (a=%d, b=%d)" % [sa.find_monster("skel_2").hp, sb.find_monster("skel_2").hp])
	return failures


# --- Phase C: heal path (fighter_second_wind) ---

# Build a state with a wounded fighter who knows fighter_second_wind.
# Helper used by all the heal-path tests.
func _make_heal_state(
	fighter_hp: int = 5,
	fighter_max_hp: int = 20,
	attacker_ap: int = 3,
	known_abilities: Array[String] = ["fighter_second_wind"],
	seed_val: int = 42,
) -> GameState:
	var gs: GameState = GameState.new()
	gs.seed = seed_val
	gs.rng = RNGService.new(seed_val)
	gs.event_log = EventLog.new()
	gs.event_log.seed = seed_val

	var fighter: PlayerState = PlayerState.new()
	fighter.actor_id = "fighter_1"
	fighter.hp = fighter_hp
	fighter.max_hp = fighter_max_hp
	fighter.ac = 16
	fighter.action_points = attacker_ap
	fighter.max_action_points = 3
	fighter.ability_ids = known_abilities
	gs.players.append(fighter)
	gs.current_encounter = EncounterState.new()
	return gs


# self_target() factory wraps actor_id as the sole target. Caller doesn't
# have to remember the "pass own actor_id as third arg" pattern.
func _test_self_target_factory_constructs_command() -> Array[String]:
	var cmd: UseAbilityCommand = UseAbilityCommand.self_target("fighter_1", "fighter_second_wind")
	var failures: Array[String] = []
	if cmd.actor_id != "fighter_1":
		failures.append("self_target: actor_id wrong, got '%s'" % cmd.actor_id)
	if cmd.target_ids.size() != 1:
		failures.append("self_target: target_ids should have 1 element, got %d" % cmd.target_ids.size())
	elif cmd.target_ids[0] != "fighter_1":
		failures.append("self_target: target_ids[0] should match actor_id, got '%s'" % cmd.target_ids[0])
	if cmd.ability_id != "fighter_second_wind":
		failures.append("self_target: ability_id wrong, got '%s'" % cmd.ability_id)
	return failures


# Self-target heal validates correctly — the actor IS the target, target
# alive (fighter has hp > 0), AP sufficient, ability known.
func _test_second_wind_validates_when_fighter_knows_it() -> Array[String]:
	var state: GameState = _make_heal_state()
	var cmd: UseAbilityCommand = UseAbilityCommand.self_target("fighter_1", "fighter_second_wind")
	if not cmd.validate(state):
		return ["second_wind_validate: should pass with known ability + alive caster + sufficient AP"]
	return []


# apply() restores HP. Wounded fighter (5/20) heals by 1d10 (1-10) and
# gets capped at max_hp. The exact value is RNG-driven; we just assert
# the HP went UP and stayed in range.
func _test_second_wind_heals_caster() -> Array[String]:
	var state: GameState = _make_heal_state(5, 20)
	var cmd: UseAbilityCommand = UseAbilityCommand.self_target("fighter_1", "fighter_second_wind")
	cmd.apply(state)

	var fighter: PlayerState = state.find_player("fighter_1")
	var failures: Array[String] = []
	if fighter.hp <= 5:
		failures.append("second_wind_heal: HP should have increased from 5, got %d" % fighter.hp)
	if fighter.hp > 20:
		failures.append("second_wind_heal: HP should not exceed max_hp 20, got %d" % fighter.hp)
	# Heal range with 1d10 (no modifier): 1..10. 5 + roll, capped at 20.
	# So result must be in [6, 15] (since 5 + 1 = 6 minimum, 5 + 10 = 15 max).
	if fighter.hp < 6 or fighter.hp > 15:
		failures.append("second_wind_heal: HP should be in [6, 15] for 1d10 from 5, got %d" % fighter.hp)
	return failures


# Heal at full HP: no-op for HP, but HEALED event still fires with
# amount=0 (renderer can ignore). The "requested" field captures the
# intended heal amount before clamping.
func _test_second_wind_caps_heal_at_max_hp() -> Array[String]:
	var state: GameState = _make_heal_state(20, 20)  # already at full HP
	var cmd: UseAbilityCommand = UseAbilityCommand.self_target("fighter_1", "fighter_second_wind")
	var events: Array[GameEvent] = cmd.apply(state)

	var failures: Array[String] = []
	var fighter: PlayerState = state.find_player("fighter_1")
	if fighter.hp != 20:
		failures.append("second_wind_cap: HP should stay at 20 (max), got %d" % fighter.hp)

	# The HEALED event should have amount=0 and requested>0
	var saw_capped: bool = false
	for evt in events:
		if evt.event_type == "HEALED" and evt.data.get("target") == "fighter_1":
			if evt.data.get("amount") == 0 and evt.data.get("requested", 0) > 0:
				saw_capped = true
				break
	if not saw_capped:
		failures.append("second_wind_cap: expected HEALED with amount=0 and requested>0")
	return failures


# Heal path emits HEALED but NOT DICE_ROLLED-for-attack — heals don't
# do attack rolls. (They DO consume RNG for the heal dice, but the
# attack-roll DICE_ROLLED with type=attack should not fire.)
func _test_second_wind_emits_healed_event_no_attack_roll() -> Array[String]:
	var state: GameState = _make_heal_state(5, 20)
	var cmd: UseAbilityCommand = UseAbilityCommand.self_target("fighter_1", "fighter_second_wind")
	var events: Array[GameEvent] = cmd.apply(state)

	var saw_healed: bool = false
	var saw_attack_roll: bool = false
	for evt in events:
		if evt.event_type == "HEALED" and evt.data.get("ability") == "fighter_second_wind":
			saw_healed = true
		if evt.event_type == "DICE_ROLLED" and evt.data.get("type") == "attack":
			saw_attack_roll = true

	var failures: Array[String] = []
	if not saw_healed:
		failures.append("second_wind_events: no HEALED event for fighter_second_wind")
	if saw_attack_roll:
		failures.append("second_wind_events: heal path should NOT emit attack-roll DICE_ROLLED")
	return failures


# AP cost still pays. Second Wind costs 1 AP; fighter starts at 3, ends at 2.
func _test_second_wind_decrements_ap() -> Array[String]:
	var state: GameState = _make_heal_state(5, 20, 3)
	var cmd: UseAbilityCommand = UseAbilityCommand.self_target("fighter_1", "fighter_second_wind")
	cmd.apply(state)
	var fighter: PlayerState = state.find_player("fighter_1")
	if fighter.action_points != 2:
		return ["second_wind_ap: expected AP 2 (3 - 1), got %d" % fighter.action_points]
	return []


# --- Phase H: execute mechanic (champion_critical_finisher) ---

# Build a state with a fighter who knows champion_critical_finisher and a
# skeleton at the specified HP. Fighter starts with 3 AP (matches the
# ability's 3 AP cost so it can apply once).
func _make_finisher_state(skel_hp: int, seed_val: int = 42) -> GameState:
	var gs: GameState = GameState.new()
	gs.seed = seed_val
	gs.rng = RNGService.new(seed_val)
	gs.event_log = EventLog.new()
	gs.event_log.seed = seed_val

	var fighter: PlayerState = PlayerState.new()
	fighter.actor_id = "fighter_1"
	fighter.hp = 20
	fighter.max_hp = 20
	fighter.ac = 16
	fighter.action_points = 3
	fighter.max_action_points = 3
	fighter.ability_ids = ["champion_critical_finisher"]
	gs.players.append(fighter)

	gs.current_encounter = EncounterState.new()
	# Use the canonical skeleton_warrior def then override HP.
	const SKELETON_WARRIOR_PATH := "res://src/content/monsters/skeleton_warrior.tres"
	var def: Resource = load(SKELETON_WARRIOR_PATH)
	var skel: MonsterState = def.spawn_monster_state("skel_1")
	skel.hp = skel_hp  # tests pick where on the threshold the target sits
	gs.current_encounter.monsters.append(skel)
	return gs


# Target above the 25% HP threshold (e.g. 6/12 = 50%): execute branch
# never enters. Normal damage flow runs. RNG should advance through
# attack roll + damage roll, NOT the execute chance.
func _test_execute_does_not_trigger_above_threshold() -> Array[String]:
	# Skeleton at 6/12 = 50%, well above the 25% threshold
	var state: GameState = _make_finisher_state(6, 42)
	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "champion_critical_finisher", "skel_1")
	var events: Array[GameEvent] = cmd.apply(state)

	var failures: Array[String] = []
	for evt in events:
		if evt.event_type == "EXECUTED":
			failures.append("above_threshold: EXECUTED event fired but target was above threshold (50%% HP)")
	# Should see normal attack-roll DICE_ROLLED
	var saw_attack_roll: bool = false
	for evt in events:
		if evt.event_type == "DICE_ROLLED" and evt.data.get("type") == "attack":
			saw_attack_roll = true
			break
	if not saw_attack_roll:
		failures.append("above_threshold: expected normal attack-roll DICE_ROLLED, none seen")
	return failures


# Target below threshold + execute success: target.hp = 0, EXECUTED +
# ACTOR_DEFEATED events fire, NO attack-roll DICE_ROLLED (skipped).
# We sweep seeds to find one where rng.chance(0.5) returns true.
func _test_execute_can_instakill_below_threshold() -> Array[String]:
	for seed_val in range(1, 30):
		# Skeleton at 2/12 = 16.6% HP, below 25% threshold
		var state: GameState = _make_finisher_state(2, seed_val)
		var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "champion_critical_finisher", "skel_1")
		var events: Array[GameEvent] = cmd.apply(state)

		var saw_executed: bool = false
		var saw_defeated: bool = false
		var saw_attack_roll: bool = false
		for evt in events:
			if evt.event_type == "EXECUTED" and evt.data.get("target") == "skel_1":
				saw_executed = true
			if evt.event_type == "ACTOR_DEFEATED" and evt.data.get("target") == "skel_1":
				saw_defeated = true
			if evt.event_type == "DICE_ROLLED" and evt.data.get("type") == "attack":
				saw_attack_roll = true

		if saw_executed:
			# Validate the execute path's invariants
			if state.find_monster("skel_1").hp != 0:
				return ["execute_kill: seed %d EXECUTED but target HP=%d (expected 0)" % [seed_val, state.find_monster("skel_1").hp]]
			if not saw_defeated:
				return ["execute_kill: seed %d EXECUTED without ACTOR_DEFEATED event" % seed_val]
			if saw_attack_roll:
				return ["execute_kill: seed %d EXECUTED but attack-roll DICE_ROLLED also fired (should be skipped)" % seed_val]
			return []  # success
	return ["execute_kill: 29 seeds at 16.6%% HP with 0.5 chance produced no executes — suspicious (probability ~5e-9)"]


# Target below threshold + execute FAILS: falls through to normal damage.
# We sweep seeds looking for one where rng.chance(0.5) returns false AND
# the subsequent attack roll hits, then verify damage was applied.
func _test_execute_fail_falls_through_to_damage() -> Array[String]:
	for seed_val in range(1, 60):
		# Skeleton at 2/12 = 16.6% HP, below threshold. Reset HP each iteration.
		var state: GameState = _make_finisher_state(2, seed_val)
		var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "champion_critical_finisher", "skel_1")
		var events: Array[GameEvent] = cmd.apply(state)

		var saw_executed: bool = false
		var saw_attack_roll: bool = false
		var saw_damage_or_miss: bool = false
		for evt in events:
			if evt.event_type == "EXECUTED":
				saw_executed = true
			if evt.event_type == "DICE_ROLLED" and evt.data.get("type") == "attack":
				saw_attack_roll = true
			if evt.event_type in ["DAMAGE_DEALT", "ATTACK_MISSED"]:
				saw_damage_or_miss = true

		# Looking for: execute did NOT fire, but normal flow did.
		if not saw_executed and saw_attack_roll and saw_damage_or_miss:
			return []  # success — execute failed and normal flow ran
	return ["execute_fail: 59 seeds produced no execute-fail-then-normal-flow case (suspicious)"]


# --- Phase K: applies_effects on AbilityDef ---

const StatusEffect = preload("res://src/core/status_effect.gd")
const AbilityDef = preload("res://src/content/abilities/ability_def.gd")

# Build a state with a fighter who knows a "test_attack" ability
# constructed in-memory (not a .tres file). The ability deals 1 damage
# and applies a 2-turn stun on hit. We monkey-patch the load path by
# setting fighter.ability_ids and using a state where we directly
# inject the def via duck typing.
#
# Actually simpler: construct an in-memory AbilityDef and call apply()
# directly without going through CommandProcessor — we lose the full
# pipeline test but get focused effect-application coverage.
func _make_state_with_def_in_memory() -> Dictionary:
	var gs: GameState = GameState.new()
	gs.seed = 42
	gs.rng = RNGService.new(42)
	gs.event_log = EventLog.new()
	gs.event_log.seed = 42

	var fighter: PlayerState = PlayerState.new()
	fighter.actor_id = "fighter_1"
	fighter.hp = 20
	fighter.max_hp = 20
	fighter.ac = 16
	fighter.action_points = 3
	fighter.max_action_points = 3
	gs.players.append(fighter)

	gs.current_encounter = EncounterState.new()
	const SKELETON_WARRIOR_PATH := "res://src/content/monsters/skeleton_warrior.tres"
	var skel_def: Resource = load(SKELETON_WARRIOR_PATH)
	var skel: MonsterState = skel_def.spawn_monster_state("skel_1")
	gs.current_encounter.monsters.append(skel)

	# Build an in-memory ability def: heavy attack mod (so it always hits
	# AC 13) + applies 2-turn stun.
	var def: AbilityDef = AbilityDef.new()
	def.id = "test_smash"
	def.ap_cost = 2
	def.target_count = 1
	def.attack_modifier = 30  # always hits
	def.damage_dice_count = 1
	def.damage_dice_sides = 4
	def.damage_modifier = 0
	def.damage_type = "physical"

	var stun: StatusEffect = StatusEffect.new()
	stun.effect_id = "stun"
	stun.duration_remaining = 2
	def.applies_effects = [stun]

	return {"state": gs, "def": def}


# Hit applies the declared effect; STATUS_APPLIED event fires; effect
# now sits on the target. Use the inline _resolve_attack path by
# building a UseAbilityCommand that we drive directly with the
# in-memory def via _resolve_against_target.
#
# We can't use the normal apply() flow because it loads the def from
# disk. Instead we test by invoking _resolve_against_target with our
# in-memory def — the public apply path is covered indirectly by
# integration tests that use the real fighter_slash etc.
func _test_applies_effects_on_hit() -> Array[String]:
	var setup: Dictionary = _make_state_with_def_in_memory()
	var gs: GameState = setup["state"]
	var def: AbilityDef = setup["def"]

	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "test_smash", "skel_1")
	var events: Array[GameEvent] = []
	var skel: MonsterState = gs.find_monster("skel_1")
	cmd._resolve_against_target(gs, def, skel, "skel_1", events)

	var failures: Array[String] = []
	# Skeleton should now have the stun effect
	if skel.status_effects.size() != 1:
		failures.append("applies_hit: expected 1 effect on skeleton after hit, got %d" % skel.status_effects.size())
	elif skel.status_effects[0].effect_id != "stun":
		failures.append("applies_hit: expected stun effect, got '%s'" % skel.status_effects[0].effect_id)
	elif skel.status_effects[0].duration_remaining != 2:
		failures.append("applies_hit: stun duration should be 2 (from def), got %d" % skel.status_effects[0].duration_remaining)

	# STATUS_APPLIED should have fired
	var saw_applied: bool = false
	for evt in events:
		if evt.event_type == "STATUS_APPLIED" and evt.data.get("effect_id") == "stun":
			saw_applied = true
			break
	if not saw_applied:
		failures.append("applies_hit: STATUS_APPLIED event missing")

	# Independence: the def's effect array should NOT be aliased to the
	# target's status_effects (chunk-K duplicate-on-apply rule)
	if not skel.status_effects.is_empty() and not def.applies_effects.is_empty():
		if skel.status_effects[0] == def.applies_effects[0]:
			failures.append("applies_hit: target's effect is the SAME object as the def's (should be a duplicate)")
	return failures


# Misses don't apply effects. Build the same in-memory def but with a
# huge target AC so the attack misses, and verify no effect lands.
func _test_does_not_apply_effects_on_miss() -> Array[String]:
	var setup: Dictionary = _make_state_with_def_in_memory()
	var gs: GameState = setup["state"]
	var def: AbilityDef = setup["def"]
	# Override the attack modifier to guarantee a miss (negative + low AC means low total)
	def.attack_modifier = -100
	gs.find_monster("skel_1").ac = 50  # extra insurance

	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "test_smash", "skel_1")
	var events: Array[GameEvent] = []
	var skel: MonsterState = gs.find_monster("skel_1")
	cmd._resolve_against_target(gs, def, skel, "skel_1", events)

	var failures: Array[String] = []
	if skel.status_effects.size() != 0:
		failures.append("applies_miss: miss should not apply effects, got %d" % skel.status_effects.size())
	# Sanity: should have seen ATTACK_MISSED
	var saw_miss: bool = false
	for evt in events:
		if evt.event_type == "ATTACK_MISSED":
			saw_miss = true
			break
	if not saw_miss:
		failures.append("applies_miss: expected ATTACK_MISSED event")
	return failures


# Defeated targets don't get status effects applied — applying stun to
# a corpse is meaningless and clutters the log.
func _test_does_not_apply_effects_on_defeated_target() -> Array[String]:
	var setup: Dictionary = _make_state_with_def_in_memory()
	var gs: GameState = setup["state"]
	var def: AbilityDef = setup["def"]
	# Set target to 1 HP, give the ability massive damage so it kills on hit
	def.damage_dice_count = 10
	def.damage_dice_sides = 100
	gs.find_monster("skel_1").hp = 1

	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "test_smash", "skel_1")
	var events: Array[GameEvent] = []
	var skel: MonsterState = gs.find_monster("skel_1")
	cmd._resolve_against_target(gs, def, skel, "skel_1", events)

	var failures: Array[String] = []
	if skel.hp != 0:
		failures.append("applies_dead: target should be defeated (HP 0), got %d" % skel.hp)
	# Status effects should NOT have been applied
	if skel.status_effects.size() != 0:
		failures.append("applies_dead: defeated target should not have effects applied, got %d" % skel.status_effects.size())
	# No STATUS_APPLIED event
	for evt in events:
		if evt.event_type == "STATUS_APPLIED":
			failures.append("applies_dead: STATUS_APPLIED should not fire when target is defeated")
			break
	return failures


# Heal abilities also apply effects (heals don't fail, so always apply).
# Build an in-memory heal ability that applies a "blessing" effect on the
# heal recipient.
func _test_applies_effects_on_heal() -> Array[String]:
	var gs: GameState = GameState.new()
	gs.seed = 42
	gs.rng = RNGService.new(42)
	gs.event_log = EventLog.new()

	var fighter: PlayerState = PlayerState.new()
	fighter.actor_id = "fighter_1"
	fighter.hp = 5
	fighter.max_hp = 20
	fighter.ac = 16
	fighter.action_points = 3
	fighter.max_action_points = 3
	gs.players.append(fighter)
	gs.current_encounter = EncounterState.new()

	var def: AbilityDef = AbilityDef.new()
	def.id = "test_blessed_heal"
	def.ap_cost = 2
	def.target_count = 1
	def.heal_dice_count = 1
	def.heal_dice_sides = 4

	var bless: StatusEffect = StatusEffect.new()
	bless.effect_id = "blessing"
	bless.duration_remaining = 3
	def.applies_effects = [bless]

	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "test_blessed_heal", "fighter_1")
	var events: Array[GameEvent] = []
	cmd._resolve_against_target(gs, def, fighter, "fighter_1", events)

	var failures: Array[String] = []
	# HP should have increased
	if fighter.hp <= 5:
		failures.append("applies_heal: HP should have increased from 5, got %d" % fighter.hp)
	# Blessing effect should be on fighter
	var saw_blessing: bool = false
	for e in fighter.status_effects:
		if e.effect_id == "blessing":
			saw_blessing = true
			break
	if not saw_blessing:
		failures.append("applies_heal: heal target should have blessing effect")
	return failures


# --- Phase L: save throws ---

# Build an in-memory save-throw def: 1d4 damage, applies stun, save_type=CON
# DC=14. Skel target's CON modifier is +20 → save always succeeds.
# Verify: damage lands, stun does NOT apply, SAVE_ROLLED event fires
# with saved=true.
func _test_save_success_skips_effect_application() -> Array[String]:
	var setup: Dictionary = _make_state_with_def_in_memory()
	var gs: GameState = setup["state"]
	var def: AbilityDef = setup["def"]
	# Configure as a save-required ability
	def.attack_modifier = 30  # always hits (already set in helper but make explicit)
	def.save_type = "CON"
	def.save_dc = 14
	def.save_negates_effect = true
	# Stack the deck: target has +20 CON → save always succeeds (1+20=21 >= 14)
	gs.find_monster("skel_1").stats = {"CON": 20}

	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "test_save", "skel_1")
	var events: Array[GameEvent] = []
	var skel: MonsterState = gs.find_monster("skel_1")
	var hp_before: int = skel.hp
	cmd._resolve_against_target(gs, def, skel, "skel_1", events)

	var failures: Array[String] = []
	# Damage should still land (save only gates effect, not damage)
	if skel.hp >= hp_before:
		failures.append("save_success: damage should still land on save success, HP unchanged")
	# Stun should NOT have been applied
	for e in skel.status_effects:
		if e.effect_id == "stun":
			failures.append("save_success: stun should NOT apply on save success (save_negates_effect=true)")
	# SAVE_ROLLED event should fire with saved=true
	var saw_save: bool = false
	for evt in events:
		if evt.event_type == "SAVE_ROLLED":
			saw_save = true
			if evt.data.get("saved") != true:
				failures.append("save_success: SAVE_ROLLED.saved should be true (CON +20 vs DC 14)")
			break
	if not saw_save:
		failures.append("save_success: SAVE_ROLLED event missing")
	return failures


# Save fail: target's CON modifier is -10 → save always fails. Effect
# applies. Damage also applies (always does on hit).
func _test_save_fail_applies_effect() -> Array[String]:
	var setup: Dictionary = _make_state_with_def_in_memory()
	var gs: GameState = setup["state"]
	var def: AbilityDef = setup["def"]
	def.attack_modifier = 30
	def.save_type = "CON"
	def.save_dc = 14
	def.save_negates_effect = true
	# Save always fails: -10 + d20 (max 20) = 10, vs DC 14 → fail
	gs.find_monster("skel_1").stats = {"CON": -10}

	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "test_save", "skel_1")
	var events: Array[GameEvent] = []
	var skel: MonsterState = gs.find_monster("skel_1")
	cmd._resolve_against_target(gs, def, skel, "skel_1", events)

	var failures: Array[String] = []
	# Stun SHOULD have been applied (save failed)
	var saw_stun: bool = false
	for e in skel.status_effects:
		if e.effect_id == "stun":
			saw_stun = true
	if not saw_stun:
		failures.append("save_fail: stun should apply on save fail")
	# SAVE_ROLLED event should fire with saved=false
	for evt in events:
		if evt.event_type == "SAVE_ROLLED":
			if evt.data.get("saved") != false:
				failures.append("save_fail: SAVE_ROLLED.saved should be false (CON -10 vs DC 14)")
			break
	return failures


# Even on save success, the damage payload still lands. Saves only gate
# effect application — not damage. (D&D 5e "save halves" is a future need.)
func _test_save_does_not_skip_damage() -> Array[String]:
	var setup: Dictionary = _make_state_with_def_in_memory()
	var gs: GameState = setup["state"]
	var def: AbilityDef = setup["def"]
	def.attack_modifier = 30
	def.damage_dice_count = 5  # hefty damage so we can verify it landed
	def.damage_dice_sides = 8
	def.save_type = "CON"
	def.save_dc = 14
	gs.find_monster("skel_1").stats = {"CON": 20}  # save always succeeds

	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "test_save", "skel_1")
	var events: Array[GameEvent] = []
	var skel: MonsterState = gs.find_monster("skel_1")
	var hp_before: int = skel.hp
	cmd._resolve_against_target(gs, def, skel, "skel_1", events)

	# Verify damage landed despite save success
	var saw_damage: bool = false
	for evt in events:
		if evt.event_type == "DAMAGE_DEALT":
			saw_damage = true
			break
	if not saw_damage:
		return ["save_no_damage_skip: DAMAGE_DEALT should fire even when save succeeds"]
	if skel.hp >= hp_before:
		return ["save_no_damage_skip: HP should have decreased; got %d, was %d" % [skel.hp, hp_before]]
	return []


# Default: save_type empty means no save roll happens at all. Effects
# apply unconditionally on hit (existing chunk-K behavior).
func _test_no_save_type_means_no_save_roll() -> Array[String]:
	var setup: Dictionary = _make_state_with_def_in_memory()
	var gs: GameState = setup["state"]
	var def: AbilityDef = setup["def"]
	def.attack_modifier = 30
	# def.save_type defaults to "" — no save
	def.save_dc = 99  # would be unsave-able if save logic ran
	gs.find_monster("skel_1").stats = {"CON": -50}

	var cmd: UseAbilityCommand = UseAbilityCommand.new("fighter_1", "test_save", "skel_1")
	var events: Array[GameEvent] = []
	var skel: MonsterState = gs.find_monster("skel_1")
	cmd._resolve_against_target(gs, def, skel, "skel_1", events)

	# No SAVE_ROLLED event should fire
	for evt in events:
		if evt.event_type == "SAVE_ROLLED":
			return ["no_save: SAVE_ROLLED should not fire when save_type is empty"]
	# Stun should still apply (no save check, applies unconditionally)
	var saw_stun: bool = false
	for e in skel.status_effects:
		if e.effect_id == "stun":
			saw_stun = true
	if not saw_stun:
		return ["no_save: stun should apply when no save (existing chunk-K behavior)"]
	return []
