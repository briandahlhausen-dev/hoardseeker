## test_command_processor.gd
##
## Verifies the CommandProcessor pipeline:
##   - rejects invalid commands without mutating state or logging
##   - applies valid commands and logs them in order
##   - assigns monotonically-increasing logical timestamps
##   - propagates the logical timestamp to emitted events
##   - integrates end-to-end with AttackCommand (proof the pipeline composes)
##
## Uses preload() so tests run from a fresh project state.

extends RefCounted

const CommandProcessor = preload("res://src/core/command_processor.gd")
const Command = preload("res://src/core/command.gd")
const GameState = preload("res://src/core/game_state.gd")
const PlayerState = preload("res://src/core/player_state.gd")
const EventLog = preload("res://src/core/event_log.gd")
const GameEvent = preload("res://src/core/game_event.gd")
const RNGService = preload("res://src/core/rng_service.gd")
const AttackCommand = preload("res://src/systems/combat/attack_command.gd")


func run_tests() -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_test_valid_command_logs_and_applies())
	failures.append_array(_test_invalid_command_does_not_log())
	failures.append_array(_test_logical_timestamp_increments())
	failures.append_array(_test_events_inherit_command_timestamp())
	failures.append_array(_test_process_all_stops_on_first_rejection())
	failures.append_array(_test_attack_command_through_processor())
	failures.append_array(_test_null_event_log_still_applies())
	return failures


# Build a minimal GameState with an EventLog and two players.
func _make_state(seed_val: int = 42) -> GameState:
	var gs: GameState = GameState.new()
	gs.seed = seed_val
	gs.rng = RNGService.new(seed_val)
	gs.event_log = EventLog.new()
	gs.event_log.seed = seed_val

	var p1: PlayerState = PlayerState.new()
	p1.actor_id = "p1"
	p1.hp = 20
	p1.max_hp = 20
	p1.ac = 14
	p1.action_points = 3

	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "p2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 14
	p2.action_points = 3

	gs.players.append(p1)
	gs.players.append(p2)
	return gs


# A test command that ALWAYS validates true and emits one tagged event.
class _AlwaysValidCommand extends Command:
	var tag: String = ""
	func _init(p_tag: String = "x") -> void:
		actor_id = "test"
		command_type = "ALWAYS_VALID"
		tag = p_tag
	func validate(_state: Resource) -> bool:
		return true
	func apply(_state: Resource) -> Array[GameEvent]:
		return [GameEvent.new("TEST_TAG", {"tag": tag})]


# A test command that ALWAYS validates false (used to verify rejection path).
class _AlwaysRejectedCommand extends Command:
	func _init() -> void:
		actor_id = "test"
		command_type = "ALWAYS_REJECTED"
	func validate(_state: Resource) -> bool:
		return false
	func apply(_state: Resource) -> Array[GameEvent]:
		# Should never be called when validate returns false
		return [GameEvent.new("SHOULD_NOT_FIRE", {})]


# Valid command: process() returns true, command + events are in the log.
func _test_valid_command_logs_and_applies() -> Array[String]:
	var state: GameState = _make_state()
	var processor: CommandProcessor = CommandProcessor.new()
	var cmd: _AlwaysValidCommand = _AlwaysValidCommand.new("first")

	var ok: bool = processor.process(cmd, state)

	var failures: Array[String] = []
	if not ok:
		failures.append("valid_command: process() should return true for a valid command")
	if state.event_log.commands.size() != 1:
		failures.append("valid_command: expected 1 command in log, got %d" % state.event_log.commands.size())
	if state.event_log.events.size() != 1:
		failures.append("valid_command: expected 1 event in log, got %d" % state.event_log.events.size())
	if state.event_log.commands.size() > 0 and state.event_log.commands[0].command_type != "ALWAYS_VALID":
		failures.append("valid_command: logged command type wrong")
	if state.event_log.events.size() > 0 and state.event_log.events[0].event_type != "TEST_TAG":
		failures.append("valid_command: logged event type wrong")
	return failures


# Invalid command: process() returns false, NOTHING is logged.
func _test_invalid_command_does_not_log() -> Array[String]:
	var state: GameState = _make_state()
	var processor: CommandProcessor = CommandProcessor.new()
	var cmd: _AlwaysRejectedCommand = _AlwaysRejectedCommand.new()

	var ok: bool = processor.process(cmd, state)

	var failures: Array[String] = []
	if ok:
		failures.append("invalid_command: process() should return false for a rejected command")
	if state.event_log.commands.size() != 0:
		failures.append("invalid_command: rejected commands should not be logged (got %d)" % state.event_log.commands.size())
	if state.event_log.events.size() != 0:
		failures.append("invalid_command: rejected commands' events should not be logged (got %d)" % state.event_log.events.size())
	return failures


# Logical timestamps increment monotonically: first command at 0, second at 1, etc.
func _test_logical_timestamp_increments() -> Array[String]:
	var state: GameState = _make_state()
	var processor: CommandProcessor = CommandProcessor.new()

	var c1: _AlwaysValidCommand = _AlwaysValidCommand.new("a")
	var c2: _AlwaysValidCommand = _AlwaysValidCommand.new("b")
	var c3: _AlwaysValidCommand = _AlwaysValidCommand.new("c")

	processor.process(c1, state)
	processor.process(c2, state)
	processor.process(c3, state)

	var failures: Array[String] = []
	if c1.timestamp_logical != 0:
		failures.append("logical_timestamp: c1 should be at 0, got %d" % c1.timestamp_logical)
	if c2.timestamp_logical != 1:
		failures.append("logical_timestamp: c2 should be at 1, got %d" % c2.timestamp_logical)
	if c3.timestamp_logical != 2:
		failures.append("logical_timestamp: c3 should be at 2, got %d" % c3.timestamp_logical)
	return failures


# Events emitted by a command share its logical timestamp (so replay can
# reconstruct command-event grouping).
func _test_events_inherit_command_timestamp() -> Array[String]:
	var state: GameState = _make_state()
	var processor: CommandProcessor = CommandProcessor.new()

	processor.process(_AlwaysValidCommand.new("first"), state)
	processor.process(_AlwaysValidCommand.new("second"), state)

	var failures: Array[String] = []
	if state.event_log.events.size() != 2:
		failures.append("events_inherit: expected 2 events, got %d" % state.event_log.events.size())
		return failures
	if state.event_log.events[0].timestamp_logical != 0:
		failures.append("events_inherit: first event should be at logical time 0, got %d" % state.event_log.events[0].timestamp_logical)
	if state.event_log.events[1].timestamp_logical != 1:
		failures.append("events_inherit: second event should be at logical time 1, got %d" % state.event_log.events[1].timestamp_logical)
	return failures


# process_all() halts on the first rejection.
func _test_process_all_stops_on_first_rejection() -> Array[String]:
	var state: GameState = _make_state()
	var processor: CommandProcessor = CommandProcessor.new()

	var sequence: Array = [
		_AlwaysValidCommand.new("a"),
		_AlwaysValidCommand.new("b"),
		_AlwaysRejectedCommand.new(),  # halts here
		_AlwaysValidCommand.new("d"),  # never reached
	]

	var processed: int = processor.process_all(sequence, state)

	var failures: Array[String] = []
	if processed != 2:
		failures.append("process_all: expected 2 successful processes (then halt), got %d" % processed)
	if state.event_log.commands.size() != 2:
		failures.append("process_all: expected 2 commands logged, got %d" % state.event_log.commands.size())
	return failures


# End-to-end: AttackCommand goes through the processor cleanly and produces
# the expected log entries (1 command + N events depending on hit/miss).
func _test_attack_command_through_processor() -> Array[String]:
	var state: GameState = _make_state()
	var processor: CommandProcessor = CommandProcessor.new()

	var attack: AttackCommand = AttackCommand.new("p1", "p2")
	var ok: bool = processor.process(attack, state)

	var failures: Array[String] = []
	if not ok:
		failures.append("attack_through_processor: AttackCommand should succeed")
	if state.event_log.commands.size() != 1:
		failures.append("attack_through_processor: expected 1 command logged, got %d" % state.event_log.commands.size())
	if state.event_log.events.size() < 2:
		# AttackCommand emits at least DICE_ROLLED + (DAMAGE_DEALT or ATTACK_MISSED)
		failures.append("attack_through_processor: expected >=2 events, got %d" % state.event_log.events.size())

	# Check attacker AP went down (real state mutation went through)
	var attacker: PlayerState = state.find_player("p1")
	if attacker.action_points != 2:  # started at 3, ap_cost=1
		failures.append("attack_through_processor: attacker AP should be 2 after attack, got %d" % attacker.action_points)
	return failures


# A null event_log is allowed (for cheap tests / detached commands). The
# command still applies; nothing is logged.
func _test_null_event_log_still_applies() -> Array[String]:
	var state: GameState = _make_state()
	state.event_log = null  # explicitly null
	var processor: CommandProcessor = CommandProcessor.new()

	var attack: AttackCommand = AttackCommand.new("p1", "p2")
	var ok: bool = processor.process(attack, state)

	var failures: Array[String] = []
	if not ok:
		failures.append("null_event_log: process() should still succeed when event_log is null")
	# Verify state mutated even without logging
	var attacker: PlayerState = state.find_player("p1")
	if attacker.action_points != 2:
		failures.append("null_event_log: attacker AP should still update (got %d, expected 2)" % attacker.action_points)
	return failures
