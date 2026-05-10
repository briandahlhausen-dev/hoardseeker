## test_monster_ai.gd
##
## Verifies MonsterAI.pick_next_action and the full monster-turn loop:
##   - AI picks AttackCommand against first living player
##   - AI returns null when monster is dead, out of AP, or has no targets
##   - End-to-end: fighter ends turn → skeleton AI loop runs → skeleton
##     ends turn → fighter active again with refreshed AP
##   - Monsters now get AP refresh on their turn (extension of EndTurnCommand)
##   - Stun on a monster works the same as on a player (zeros their AP, AI
##     loop terminates immediately)

extends RefCounted

const GameState = preload("res://src/core/game_state.gd")
const PlayerState = preload("res://src/core/player_state.gd")
const MonsterState = preload("res://src/core/monster_state.gd")
const EncounterState = preload("res://src/core/encounter_state.gd")
const EventLog = preload("res://src/core/event_log.gd")
const RNGService = preload("res://src/core/rng_service.gd")
const StatusEffect = preload("res://src/core/status_effect.gd")
const AttackCommand = preload("res://src/systems/combat/attack_command.gd")
const EndTurnCommand = preload("res://src/systems/combat/end_turn_command.gd")
const MonsterAI = preload("res://src/systems/combat/monster_ai.gd")
const CommandProcessor = preload("res://src/core/command_processor.gd")
const MonsterDef = preload("res://src/content/monsters/monster_def.gd")

const SKELETON_WARRIOR_PATH := "res://src/content/monsters/skeleton_warrior.tres"


func run_tests() -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_test_ai_picks_attack_on_living_player())
	failures.append_array(_test_ai_returns_null_when_monster_dead())
	failures.append_array(_test_ai_returns_null_when_no_ap())
	failures.append_array(_test_ai_returns_null_when_no_living_targets())
	failures.append_array(_test_ap_refresh_extends_to_monster())
	failures.append_array(_test_full_monster_turn_via_ai_loop())
	failures.append_array(_test_stunned_monster_ai_loop_terminates_without_action())
	return failures


# Build a 2-actor turn-order state: fighter active, skeleton next.
func _make_state(seed_val: int = 42) -> GameState:
	var gs: GameState = GameState.new()
	gs.seed = seed_val
	gs.rng = RNGService.new(seed_val)
	gs.event_log = EventLog.new()
	gs.event_log.seed = seed_val
	gs.phase = "IN_COMBAT"

	var fighter: PlayerState = PlayerState.new()
	fighter.actor_id = "fighter_1"
	fighter.hp = 20
	fighter.max_hp = 20
	fighter.ac = 16
	fighter.action_points = 0  # outgoing — refresh happens at next start-of-turn
	fighter.max_action_points = 3
	gs.players.append(fighter)

	gs.current_encounter = EncounterState.new()
	var skel: MonsterState = (load(SKELETON_WARRIOR_PATH) as MonsterDef).spawn_monster_state("skel_1")
	skel.action_points = 0  # outgoing — will refresh on its turn
	gs.current_encounter.monsters.append(skel)

	gs.turn_order = ["fighter_1", "skel_1"]
	gs.active_actor_id = "fighter_1"
	return gs


# Skeleton with AP and a living target picks an AttackCommand against
# that target.
func _test_ai_picks_attack_on_living_player() -> Array[String]:
	var state: GameState = _make_state()
	# Skeleton is fresh; give it some AP for the test
	state.find_monster("skel_1").action_points = 2

	var cmd: Command = MonsterAI.pick_next_action(state, "skel_1")
	var failures: Array[String] = []
	if cmd == null:
		failures.append("ai_attack: should have picked an action")
		return failures
	if not (cmd is AttackCommand):
		failures.append("ai_attack: expected AttackCommand, got %s" % cmd.get_class())
		return failures
	if cmd.actor_id != "skel_1":
		failures.append("ai_attack: AttackCommand.actor_id should be skel_1, got '%s'" % cmd.actor_id)
	if cmd.target_id != "fighter_1":
		failures.append("ai_attack: target should be fighter_1 (only living player), got '%s'" % cmd.target_id)
	return failures


# Defeated monster (HP 0) returns null — can't act when dead.
func _test_ai_returns_null_when_monster_dead() -> Array[String]:
	var state: GameState = _make_state()
	state.find_monster("skel_1").hp = 0
	state.find_monster("skel_1").action_points = 2
	if MonsterAI.pick_next_action(state, "skel_1") != null:
		return ["ai_dead: should return null when monster is at 0 HP"]
	return []


# Monster with 0 AP returns null — turn naturally ends when budget exhausted.
func _test_ai_returns_null_when_no_ap() -> Array[String]:
	var state: GameState = _make_state()
	state.find_monster("skel_1").action_points = 0
	if MonsterAI.pick_next_action(state, "skel_1") != null:
		return ["ai_no_ap: should return null when monster has 0 AP"]
	return []


# All players defeated → null (monster has nothing to attack).
func _test_ai_returns_null_when_no_living_targets() -> Array[String]:
	var state: GameState = _make_state()
	state.find_monster("skel_1").action_points = 2
	state.find_player("fighter_1").hp = 0  # only player, dead
	if MonsterAI.pick_next_action(state, "skel_1") != null:
		return ["ai_no_targets: should return null when no living players"]
	return []


# When fighter ends turn, the skeleton's AP refreshes to its max
# (was 0 outgoing → 2 incoming). This is the EndTurnCommand extension
# that makes monster turns AP-driven.
func _test_ap_refresh_extends_to_monster() -> Array[String]:
	var state: GameState = _make_state()  # skeleton starts with AP=0
	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var skel: MonsterState = state.find_monster("skel_1")
	if skel.action_points != skel.max_action_points:
		return ["ap_refresh: skeleton AP should refresh to max (%d), got %d" % [skel.max_action_points, skel.action_points]]
	if state.active_actor_id != "skel_1":
		return ["ap_refresh: active actor should be skeleton after fighter EndTurn, got '%s'" % state.active_actor_id]
	return []


# Full monster turn: fighter ends turn → skeleton becomes active with
# refreshed AP → AI loop runs (issues attacks until null) → skeleton
# ends its turn → fighter active again with refreshed AP.
# Each attack the AI issues should consume 1 AP; with max_action_points=2
# the skeleton attacks twice, then the AI returns null.
func _test_full_monster_turn_via_ai_loop() -> Array[String]:
	var state: GameState = _make_state()
	var processor: CommandProcessor = CommandProcessor.new()

	# Fighter ends turn — control passes to skeleton, AP refreshes
	processor.process(EndTurnCommand.new("fighter_1"), state)

	# Run the AI loop
	var attack_count: int = 0
	while true:
		var cmd: Command = MonsterAI.pick_next_action(state, "skel_1")
		if cmd == null:
			break
		var ok: bool = processor.process(cmd, state)
		if not ok:
			return ["monster_turn: AI-issued command was rejected by processor"]
		attack_count += 1
		# Sanity: prevent infinite loops if AI is broken
		if attack_count > 10:
			return ["monster_turn: AI loop didn't terminate after 10 actions"]

	# Skeleton ends its turn explicitly (the AI helper doesn't do this; the
	# test driver / future AIRunner is responsible)
	processor.process(EndTurnCommand.new("skel_1"), state)

	var failures: Array[String] = []
	# AI should have used all 2 starting AP via AttackCommand (1 AP each)
	if attack_count != 2:
		failures.append("monster_turn: expected 2 AI actions (max_action_points=2), got %d" % attack_count)
	# Control should be back at the fighter with refreshed AP
	if state.active_actor_id != "fighter_1":
		failures.append("monster_turn: active should be fighter_1 after wrap, got '%s'" % state.active_actor_id)
	var fighter: PlayerState = state.find_player("fighter_1")
	if fighter.action_points != fighter.max_action_points:
		failures.append("monster_turn: fighter AP should be refreshed (%d), got %d" % [fighter.max_action_points, fighter.action_points])
	# At least 2 commands should be in the log (the attacks); turn-end commands too
	if state.event_log.commands.size() < 2:
		failures.append("monster_turn: expected at least 2 commands logged, got %d" % state.event_log.commands.size())
	return failures


# Stun on a monster: when fighter ends turn → skeleton becomes active
# → status tick zeros skeleton's AP → AI loop returns null on first
# call (skeleton has no AP). Same mechanic as stun on a player.
func _test_stunned_monster_ai_loop_terminates_without_action() -> Array[String]:
	var state: GameState = _make_state()
	var stun: StatusEffect = StatusEffect.new()
	stun.effect_id = "stun"
	stun.duration_remaining = 1
	state.find_monster("skel_1").status_effects.append(stun)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)
	# After EndTurn: skeleton active, AP refreshed to 2, then stun ticks → AP=0

	var skel: MonsterState = state.find_monster("skel_1")
	if skel.action_points != 0:
		return ["stunned_monster: AP should be 0 after stun tick, got %d" % skel.action_points]

	# AI should immediately return null on first call
	var cmd: Command = MonsterAI.pick_next_action(state, "skel_1")
	if cmd != null:
		return ["stunned_monster: AI should return null when AP=0, got %s" % cmd.command_type]
	return []
