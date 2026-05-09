## test_end_turn_command.gd
##
## Verifies EndTurnCommand:
##   - validate fails if not the active actor's turn
##   - validate fails if turn_order is empty
##   - apply advances active_actor_id to next in turn_order
##   - apply emits TURN_ENDED + TURN_STARTED events
##   - apply refreshes the new active player's action_points to max
##   - apply wraps around (last actor -> first) and increments round
##   - integrates with CommandProcessor

extends RefCounted

const EndTurnCommand = preload("res://src/systems/combat/end_turn_command.gd")
const CommandProcessor = preload("res://src/core/command_processor.gd")
const GameState = preload("res://src/core/game_state.gd")
const PlayerState = preload("res://src/core/player_state.gd")
const EncounterState = preload("res://src/core/encounter_state.gd")
const EventLog = preload("res://src/core/event_log.gd")
const RNGService = preload("res://src/core/rng_service.gd")
const GameEvent = preload("res://src/core/game_event.gd")


func run_tests() -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_test_validate_passes_for_active_actor())
	failures.append_array(_test_validate_fails_for_non_active_actor())
	failures.append_array(_test_validate_fails_when_turn_order_empty())
	failures.append_array(_test_validate_fails_when_no_active_actor())
	failures.append_array(_test_apply_advances_active_actor())
	failures.append_array(_test_apply_emits_turn_ended_and_started())
	failures.append_array(_test_apply_refreshes_new_actor_ap())
	failures.append_array(_test_apply_wraps_and_increments_round())
	failures.append_array(_test_apply_through_processor())
	return failures


func _make_state(active: String = "p1", order: Array[String] = ["p1", "p2"]) -> GameState:
	var gs: GameState = GameState.new()
	gs.seed = 1
	gs.rng = RNGService.new(1)
	gs.event_log = EventLog.new()
	gs.turn_order = order
	gs.active_actor_id = active

	var p1: PlayerState = PlayerState.new()
	p1.actor_id = "p1"
	p1.hp = 20
	p1.max_hp = 20
	p1.ac = 14
	p1.action_points = 1  # spent down — will get refreshed when their turn comes
	p1.max_action_points = 3

	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "p2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 14
	p2.action_points = 0  # spent fully — will get refreshed when their turn comes
	p2.max_action_points = 3

	gs.players.append(p1)
	gs.players.append(p2)
	return gs


func _test_validate_passes_for_active_actor() -> Array[String]:
	var state: GameState = _make_state("p1")
	var cmd: EndTurnCommand = EndTurnCommand.new("p1")
	if not cmd.validate(state):
		return ["validate_active_actor: should pass when actor is the active one"]
	return []


func _test_validate_fails_for_non_active_actor() -> Array[String]:
	var state: GameState = _make_state("p1")  # p1's turn
	var cmd: EndTurnCommand = EndTurnCommand.new("p2")  # p2 trying to end
	if cmd.validate(state):
		return ["validate_non_active: should fail when actor is not the active one"]
	return []


func _test_validate_fails_when_turn_order_empty() -> Array[String]:
	var state: GameState = _make_state("p1")
	state.turn_order = []
	var cmd: EndTurnCommand = EndTurnCommand.new("p1")
	if cmd.validate(state):
		return ["validate_empty_order: should fail when turn_order is empty"]
	return []


func _test_validate_fails_when_no_active_actor() -> Array[String]:
	var state: GameState = _make_state("")  # no active actor
	var cmd: EndTurnCommand = EndTurnCommand.new("p1")
	if cmd.validate(state):
		return ["validate_no_active: should fail when active_actor_id is empty"]
	return []


func _test_apply_advances_active_actor() -> Array[String]:
	var state: GameState = _make_state("p1", ["p1", "p2"])
	var cmd: EndTurnCommand = EndTurnCommand.new("p1")
	cmd.apply(state)
	if state.active_actor_id != "p2":
		return ["apply_advances: expected active_actor_id 'p2' after p1 ended, got '%s'" % state.active_actor_id]
	return []


func _test_apply_emits_turn_ended_and_started() -> Array[String]:
	var state: GameState = _make_state("p1")
	var cmd: EndTurnCommand = EndTurnCommand.new("p1")
	var events: Array[GameEvent] = cmd.apply(state)

	var has_ended: bool = false
	var has_started: bool = false
	var ended_actor: String = ""
	var started_actor: String = ""
	for e in events:
		if e.event_type == "TURN_ENDED":
			has_ended = true
			ended_actor = e.data.get("actor", "")
		elif e.event_type == "TURN_STARTED":
			has_started = true
			started_actor = e.data.get("actor", "")

	var failures: Array[String] = []
	if not has_ended:
		failures.append("emits_turn_ended_started: missing TURN_ENDED event")
	elif ended_actor != "p1":
		failures.append("emits_turn_ended_started: TURN_ENDED actor wrong, got '%s'" % ended_actor)
	if not has_started:
		failures.append("emits_turn_ended_started: missing TURN_STARTED event")
	elif started_actor != "p2":
		failures.append("emits_turn_ended_started: TURN_STARTED actor wrong, got '%s'" % started_actor)
	return failures


func _test_apply_refreshes_new_actor_ap() -> Array[String]:
	var state: GameState = _make_state("p1")
	# p2 starts with action_points=0, max=3 — should be refreshed to 3
	var cmd: EndTurnCommand = EndTurnCommand.new("p1")
	cmd.apply(state)
	var p2: PlayerState = state.find_player("p2")
	if p2.action_points != 3:
		return ["refreshes_ap: expected p2 action_points=3 after their turn started, got %d" % p2.action_points]
	return []


func _test_apply_wraps_and_increments_round() -> Array[String]:
	var state: GameState = _make_state("p2", ["p1", "p2"])
	state.current_encounter = EncounterState.new()
	state.current_encounter.round_number = 5

	# p2 ends their turn — this wraps back to p1, which means new round
	var cmd: EndTurnCommand = EndTurnCommand.new("p2")
	var events: Array[GameEvent] = cmd.apply(state)

	var failures: Array[String] = []
	if state.active_actor_id != "p1":
		failures.append("wraps: expected active_actor_id 'p1' after p2 wraps, got '%s'" % state.active_actor_id)
	if state.current_encounter.round_number != 6:
		failures.append("wraps: expected round_number 6 after wrap, got %d" % state.current_encounter.round_number)

	var has_round_started: bool = false
	for e in events:
		if e.event_type == "ROUND_STARTED":
			has_round_started = true
			if e.data.get("round") != 6:
				failures.append("wraps: ROUND_STARTED data.round should be 6, got %s" % str(e.data.get("round")))
			break
	if not has_round_started:
		failures.append("wraps: expected a ROUND_STARTED event after wrap")
	return failures


func _test_apply_through_processor() -> Array[String]:
	var state: GameState = _make_state("p1")
	var processor: CommandProcessor = CommandProcessor.new()
	var cmd: EndTurnCommand = EndTurnCommand.new("p1")

	var ok: bool = processor.process(cmd, state)
	var failures: Array[String] = []
	if not ok:
		failures.append("through_processor: process() should succeed")
	if state.active_actor_id != "p2":
		failures.append("through_processor: state.active_actor_id should be 'p2' after process")
	if state.event_log.commands.size() != 1:
		failures.append("through_processor: expected 1 command logged, got %d" % state.event_log.commands.size())
	if state.event_log.events.size() < 2:
		failures.append("through_processor: expected >=2 events (TURN_ENDED + TURN_STARTED), got %d" % state.event_log.events.size())
	return failures
