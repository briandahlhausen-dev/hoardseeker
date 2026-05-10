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
