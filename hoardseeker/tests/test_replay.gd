## test_replay.gd
##
## The Phase 1 replay-equality test (per ROADMAP.md):
##
##   "Test: replay event log, end states match."
##
## Verifies the contract documented on EventLog.replay():
##   - Replaying a recorded log against a fresh copy of the initial state
##     reproduces the post-original-run state exactly (HP, AP, RNG position,
##     active turn pointer).
##   - Replay does not mutate the input initial_state (it duplicates internally).
##   - Replay halts and returns the partial state if any logged command
##     fails validation (tampered log / desync detection).
##
## This is the load-bearing artifact behind anti-cheat replay validation,
## save/load round-trips, and (later) duo lockstep networking. If this test
## ever fails, all three of those break.
##
## Coverage:
##   - Single AttackCommand round-trips
##   - Mixed stream (Attack + EndTurn + UseAbility) round-trips
##   - Round-trip across many seeds (sample, fail-fast on first divergence)
##   - Replay does not mutate the input state
##   - Replay halts on validation failure with a partial state

extends RefCounted

const GameState = preload("res://src/core/game_state.gd")
const PlayerState = preload("res://src/core/player_state.gd")
const MonsterState = preload("res://src/core/monster_state.gd")
const EncounterState = preload("res://src/core/encounter_state.gd")
const EventLog = preload("res://src/core/event_log.gd")
const RNGService = preload("res://src/core/rng_service.gd")
const AttackCommand = preload("res://src/systems/combat/attack_command.gd")
const EndTurnCommand = preload("res://src/systems/combat/end_turn_command.gd")
const UseAbilityCommand = preload("res://src/systems/combat/use_ability_command.gd")
const CommandProcessor = preload("res://src/core/command_processor.gd")


func run_tests() -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_test_replay_single_attack_round_trips())
	failures.append_array(_test_replay_multi_command_stream_round_trips())
	failures.append_array(_test_replay_round_trips_across_many_seeds())
	failures.append_array(_test_replay_does_not_mutate_input_state())
	failures.append_array(_test_replay_halts_on_validation_failure())
	failures.append_array(_test_replay_full_realistic_fight_round_trips())
	return failures


# Build a "post-character-creation, pre-first-command" GameState. Fighter
# knows fighter_slash; skeleton is in an encounter; turn_order configured.
func _make_initial_state(seed_val: int = 42) -> GameState:
	var gs: GameState = GameState.new()
	gs.run_id = "replay_test_run"
	gs.seed = seed_val
	gs.rng = RNGService.new(seed_val)
	gs.event_log = EventLog.new()
	gs.event_log.seed = seed_val
	gs.phase = "IN_COMBAT"

	var fighter: PlayerState = PlayerState.new()
	fighter.actor_id = "fighter_1"
	fighter.display_name = "Aric"
	fighter.class_id = "fighter"
	fighter.hp = 20
	fighter.max_hp = 20
	fighter.ac = 16
	fighter.action_points = 3
	fighter.max_action_points = 3
	fighter.ability_ids = ["fighter_slash"]
	gs.players.append(fighter)

	gs.current_encounter = EncounterState.new()
	var skeleton: MonsterState = MonsterState.new()
	skeleton.actor_id = "skel_1"
	skeleton.monster_id = "skeleton_warrior"
	skeleton.hp = 12
	skeleton.max_hp = 12
	skeleton.ac = 13
	skeleton.action_points = 2
	skeleton.max_action_points = 2
	gs.current_encounter.monsters.append(skeleton)

	gs.turn_order = ["fighter_1", "skel_1"]
	gs.active_actor_id = "fighter_1"

	return gs


# Capture the values that determine "did the run end up the same place."
# Includes RNG stream position — if RNG diverges, replay is broken even
# if HP happens to coincide.
func _state_snapshot(state: Resource) -> Dictionary:
	var fighter: PlayerState = state.find_player("fighter_1")
	var skel: MonsterState = state.find_monster("skel_1")
	return {
		"fighter_hp": fighter.hp if fighter != null else null,
		"fighter_ap": fighter.action_points if fighter != null else null,
		"skel_hp": skel.hp if skel != null else null,
		"active_actor": state.active_actor_id,
		"rng_position": state.rng.stream_position,
		"phase": state.phase,
	}


func _compare_snapshots(a: Dictionary, b: Dictionary, label: String) -> Array[String]:
	var failures: Array[String] = []
	for key in a:
		if a[key] != b[key]:
			failures.append("%s: %s mismatch (original=%s, replay=%s)" % [label, key, str(a[key]), str(b[key])])
	return failures


# Process one attack, then replay the resulting log against a fresh state
# with the same seed. Final-state values must match.
func _test_replay_single_attack_round_trips() -> Array[String]:
	var s_original: GameState = _make_initial_state(7)
	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(AttackCommand.new("fighter_1", "skel_1"), s_original)
	var snapshot_original: Dictionary = _state_snapshot(s_original)

	var s_fresh: GameState = _make_initial_state(7)
	var s_replay: Resource = s_original.event_log.replay(s_fresh)
	var snapshot_replay: Dictionary = _state_snapshot(s_replay)

	return _compare_snapshots(snapshot_original, snapshot_replay, "single_attack")


# Multi-command stream covers all three concrete Commands. AttackCommand
# (with RNG), EndTurnCommand (no RNG, mutates turn pointer + AP refresh),
# UseAbilityCommand (RNG + .tres lookup). Replay must round-trip all three.
func _test_replay_multi_command_stream_round_trips() -> Array[String]:
	var s_original: GameState = _make_initial_state(99)
	var processor: CommandProcessor = CommandProcessor.new()

	# Fighter attacks once
	processor.process(AttackCommand.new("fighter_1", "skel_1"), s_original)
	# Fighter ends turn -> skeleton's turn
	processor.process(EndTurnCommand.new("fighter_1"), s_original)
	# Skeleton ends turn (no attack) -> wraps to fighter, AP refreshes
	processor.process(EndTurnCommand.new("skel_1"), s_original)
	# Fighter uses fighter_slash
	processor.process(UseAbilityCommand.new("fighter_1", "fighter_slash", "skel_1"), s_original)

	var snapshot_original: Dictionary = _state_snapshot(s_original)

	var s_fresh: GameState = _make_initial_state(99)
	var s_replay: Resource = s_original.event_log.replay(s_fresh)
	var snapshot_replay: Dictionary = _state_snapshot(s_replay)

	return _compare_snapshots(snapshot_original, snapshot_replay, "multi_command")


# Round-trip property must hold across every seed, not just one we picked.
# Sample 30 seeds (test runtime); the property is structural.
func _test_replay_round_trips_across_many_seeds() -> Array[String]:
	for seed_val in range(1, 31):
		var s_original: GameState = _make_initial_state(seed_val)
		var processor: CommandProcessor = CommandProcessor.new()
		processor.process(AttackCommand.new("fighter_1", "skel_1"), s_original)
		processor.process(AttackCommand.new("fighter_1", "skel_1"), s_original)
		processor.process(AttackCommand.new("fighter_1", "skel_1"), s_original)
		var snapshot_original: Dictionary = _state_snapshot(s_original)

		var s_fresh: GameState = _make_initial_state(seed_val)
		var s_replay: Resource = s_original.event_log.replay(s_fresh)
		var snapshot_replay: Dictionary = _state_snapshot(s_replay)

		var diff: Array[String] = _compare_snapshots(snapshot_original, snapshot_replay, "many_seeds(seed=%d)" % seed_val)
		if diff.size() > 0:
			return diff  # fail-fast on first bad seed
	return []


# replay() does duplicate(true) internally, so the input state must be
# untouched after the call returns. If replay ever forgets the duplicate
# and mutates in place, every save/load and replay-validator will leak.
func _test_replay_does_not_mutate_input_state() -> Array[String]:
	# Build a log on a separate state
	var s_recorder: GameState = _make_initial_state(13)
	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(AttackCommand.new("fighter_1", "skel_1"), s_recorder)
	processor.process(AttackCommand.new("fighter_1", "skel_1"), s_recorder)
	var log: EventLog = s_recorder.event_log

	# Snapshot a separate fresh state, replay the log against it, then
	# verify the input's snapshot is unchanged.
	var s_input: GameState = _make_initial_state(13)
	var snapshot_before: Dictionary = _state_snapshot(s_input)
	log.replay(s_input)  # discard return; we're checking s_input
	var snapshot_after: Dictionary = _state_snapshot(s_input)

	return _compare_snapshots(snapshot_before, snapshot_after, "no_mutation_of_input")


# If a logged command can't validate against the initial state — e.g.,
# the player roster changed between when the log was recorded and when
# it's being replayed — replay halts at the failure point and returns
# the state at that point. This is the desync / tamper detection path.
func _test_replay_halts_on_validation_failure() -> Array[String]:
	# Build a valid one-attack log
	var s_recorder: GameState = _make_initial_state(7)
	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(AttackCommand.new("fighter_1", "skel_1"), s_recorder)
	var log: EventLog = s_recorder.event_log

	# Build an initial state where the attack will fail validation:
	# fighter_1 doesn't exist (cleared the roster).
	var s_broken: GameState = _make_initial_state(7)
	s_broken.players.clear()

	# Replay should halt at command 0 with state unchanged from s_broken.
	# (Godot will print a push_error to stderr; that's expected, not a test failure.)
	var s_replay: Resource = log.replay(s_broken)

	var failures: Array[String] = []
	if s_replay.players.size() != 0:
		failures.append("halts_on_validation: post-replay state should still have 0 players, got %d" % s_replay.players.size())
	# Skeleton must be untouched — its HP must still be the starting value.
	var skel_after: MonsterState = s_replay.find_monster("skel_1")
	if skel_after == null:
		failures.append("halts_on_validation: skeleton should still exist post-halt")
	elif skel_after.hp != 12:
		failures.append("halts_on_validation: skeleton HP should be unchanged (12), got %d" % skel_after.hp)
	# RNG must not have advanced — apply() never ran
	if s_replay.rng.stream_position != 0:
		failures.append("halts_on_validation: RNG should not have advanced (expected 0, got %d)" % s_replay.rng.stream_position)
	return failures


# Full Phase-1 integration: a realistic fight using ALL three concrete
# Commands plus single AND multi-target UseAbilityCommand variants,
# replayed end-to-end against a fresh initial state. The chunk-1..chunk-5
# architecture must compose: AttackCommand + EndTurnCommand + single-
# target UseAbilityCommand + multi-target UseAbilityCommand all
# round-tripping in one log against fresh RNG and fresh EventLog.
#
# If any chunk's apply() has a hidden non-determinism (or any pair has a
# composition bug), this test catches it. Existing replay tests round-
# trip individual command types; this one round-trips the combination.
func _test_replay_full_realistic_fight_round_trips() -> Array[String]:
	var s_original: GameState = _make_full_fight_state(31)
	var processor: CommandProcessor = CommandProcessor.new()

	# Realistic fight script — fighter_1 has 3 AP per turn, knows 3 abilities.
	# Turn 1: fighter cleaves both skeletons (2 AP), then power-strikes skel_1 (2 AP).
	#         Wait — power_strike costs 2, fighter has 3 - 2 = 1 left. Use slash (1 AP).
	processor.process(
		UseAbilityCommand.multi_target("fighter_1", "fighter_cleave", ["skel_1", "skel_2"]),
		s_original,
	)
	processor.process(
		UseAbilityCommand.new("fighter_1", "fighter_slash", "skel_1"),
		s_original,
	)
	# Fighter ends turn -> skel_1's turn
	processor.process(EndTurnCommand.new("fighter_1"), s_original)
	# Skeletons just pass (no monster AI yet)
	processor.process(EndTurnCommand.new("skel_1"), s_original)
	processor.process(EndTurnCommand.new("skel_2"), s_original)
	# Wraps back to fighter, AP refreshed
	# Turn 2: fighter does a basic AttackCommand (the raw primitive) on skel_2,
	# then power_strikes skel_2 (2 AP, total 3 spent).
	# But power_strike validation requires actor.hp > 0 and target.hp > 0;
	# if skel_2 is dead from turn 1 cleave, the command rejects. That's fine —
	# the test asserts replay matches whatever the original processor did, hit or miss.
	processor.process(AttackCommand.new("fighter_1", "skel_2"), s_original)
	processor.process(
		UseAbilityCommand.new("fighter_1", "fighter_power_strike", "skel_2"),
		s_original,
	)

	var snapshot_original: Dictionary = _full_fight_snapshot(s_original)

	# Replay against a fresh initial state. Same seed, same starting roster.
	var s_fresh: GameState = _make_full_fight_state(31)
	var s_replay: Resource = s_original.event_log.replay(s_fresh)
	var snapshot_replay: Dictionary = _full_fight_snapshot(s_replay)

	return _compare_snapshots(snapshot_original, snapshot_replay, "full_fight")


# Multi-skeleton initial state for the full-fight integration test.
# Fighter knows all three abilities. Turn order is 3-actor.
func _make_full_fight_state(seed_val: int) -> GameState:
	var gs: GameState = GameState.new()
	gs.run_id = "full_fight_replay_test"
	gs.seed = seed_val
	gs.rng = RNGService.new(seed_val)
	gs.event_log = EventLog.new()
	gs.event_log.seed = seed_val
	gs.phase = "IN_COMBAT"

	var fighter: PlayerState = PlayerState.new()
	fighter.actor_id = "fighter_1"
	fighter.display_name = "Aric"
	fighter.class_id = "fighter"
	fighter.hp = 30
	fighter.max_hp = 30
	fighter.ac = 16
	fighter.action_points = 3
	fighter.max_action_points = 3
	fighter.ability_ids = ["fighter_slash", "fighter_cleave", "fighter_power_strike"]
	gs.players.append(fighter)

	gs.current_encounter = EncounterState.new()
	for actor_id in ["skel_1", "skel_2"]:
		var skel: MonsterState = MonsterState.new()
		skel.actor_id = actor_id
		skel.monster_id = "skeleton_warrior"
		skel.hp = 12
		skel.max_hp = 12
		skel.ac = 13
		skel.action_points = 2
		skel.max_action_points = 2
		gs.current_encounter.monsters.append(skel)

	gs.turn_order = ["fighter_1", "skel_1", "skel_2"]
	gs.active_actor_id = "fighter_1"

	return gs


# Snapshot for full-fight test — captures both skeletons.
#
# Deliberately does NOT include event_log.commands.size() or .events.size().
# EventLog.replay() does not re-append commands/events to the replayed
# state's log (the log is the input, not the output) — so post-replay
# log sizes are 0 even when state HP/AP/RNG match exactly. Asserting
# log-size equality would falsely fail this test for a non-bug.
func _full_fight_snapshot(state: Resource) -> Dictionary:
	var fighter: PlayerState = state.find_player("fighter_1")
	var skel_1: MonsterState = state.find_monster("skel_1")
	var skel_2: MonsterState = state.find_monster("skel_2")
	return {
		"fighter_hp": fighter.hp,
		"fighter_ap": fighter.action_points,
		"skel_1_hp": skel_1.hp,
		"skel_2_hp": skel_2.hp,
		"active_actor": state.active_actor_id,
		"rng_position": state.rng.stream_position,
		"phase": state.phase,
	}
