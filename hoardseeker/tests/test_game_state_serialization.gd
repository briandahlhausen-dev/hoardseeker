## test_game_state_serialization.gd
##
## Verifies the foundational state-handling contract:
##   1. GameState can be created and populated with nested resources.
##   2. GameState.duplicate(true) produces a deep copy.
##   3. The deep copy is independent — mutating it does not affect the original.
##
## This is what save/load and replay depend on. If duplicate(true) ever
## returns a shallow copy or fails to roundtrip a field, replays diverge
## and save/load produces corrupt state.
##
## Uses preload() for the same reason as test_rng_determinism — runs
## reliably from a fresh project state without requiring an --import pass.

extends RefCounted

const GameState = preload("res://src/core/game_state.gd")
const PlayerState = preload("res://src/core/player_state.gd")
const DungeonState = preload("res://src/core/dungeon_state.gd")
const EncounterState = preload("res://src/core/encounter_state.gd")
const EventLog = preload("res://src/core/event_log.gd")
const Command = preload("res://src/core/command.gd")
const GameEvent = preload("res://src/core/game_event.gd")
const RNGService = preload("res://src/core/rng_service.gd")


func run_tests() -> Array[String]:
	var failures: Array[String] = []

	failures.append_array(_test_create_empty_game_state())
	failures.append_array(_test_populate_nested_state())
	failures.append_array(_test_deep_duplicate_independence())
	failures.append_array(_test_event_log_append())
	failures.append_array(_test_game_event_construction())
	failures.append_array(_test_command_default_validate_apply())
	failures.append_array(_test_find_player_helper())

	return failures


# A fresh GameState should construct cleanly with sensible defaults.
func _test_create_empty_game_state() -> Array[String]:
	var gs: GameState = GameState.new()
	var failures: Array[String] = []
	if gs.run_id != "":
		failures.append("create_empty: default run_id should be empty, got '%s'" % gs.run_id)
	if gs.seed != 0:
		failures.append("create_empty: default seed should be 0, got %d" % gs.seed)
	if gs.phase != "PRE_RUN":
		failures.append("create_empty: default phase should be PRE_RUN, got '%s'" % gs.phase)
	if gs.players.size() != 0:
		failures.append("create_empty: players array should start empty, size %d" % gs.players.size())
	return failures


# Populate a GameState with nested resources and verify the structure holds.
func _test_populate_nested_state() -> Array[String]:
	var gs: GameState = GameState.new()
	gs.run_id = "test_run_42"
	gs.seed = 42
	gs.phase = "IN_COMBAT"
	gs.rng = RNGService.new(42)

	var p: PlayerState = PlayerState.new()
	p.actor_id = "p1"
	p.display_name = "Aric"
	p.hp = 14
	p.max_hp = 14
	p.ac = 16
	gs.players.append(p)

	gs.dungeon = DungeonState.new()
	gs.dungeon.biome_id = "forgotten_crypt"
	gs.dungeon.current_floor = 3

	gs.event_log = EventLog.new()
	gs.event_log.seed = 42

	var failures: Array[String] = []
	if gs.run_id != "test_run_42":
		failures.append("populate: run_id mismatch")
	if gs.players.size() != 1:
		failures.append("populate: expected 1 player, got %d" % gs.players.size())
	if gs.players[0].hp != 14:
		failures.append("populate: nested player hp wrong, got %d" % gs.players[0].hp)
	if gs.dungeon.biome_id != "forgotten_crypt":
		failures.append("populate: dungeon biome_id wrong")
	if gs.dungeon.current_floor != 3:
		failures.append("populate: dungeon current_floor wrong")
	return failures


# duplicate(true) MUST produce a deep copy. Modifying the copy must not
# affect the original. This is foundational for save/load and replay.
func _test_deep_duplicate_independence() -> Array[String]:
	var gs: GameState = GameState.new()
	gs.seed = 99
	gs.run_id = "original"

	var p: PlayerState = PlayerState.new()
	p.actor_id = "p1"
	p.hp = 50
	p.gold = 100
	gs.players.append(p)

	var copy: GameState = gs.duplicate(true)

	var failures: Array[String] = []

	# Initial values must match
	if copy.seed != 99:
		failures.append("deep_duplicate: copy.seed should be 99, got %d" % copy.seed)
	if copy.run_id != "original":
		failures.append("deep_duplicate: copy.run_id should be 'original', got '%s'" % copy.run_id)
	if copy.players.size() != 1:
		failures.append("deep_duplicate: copy.players size mismatch")
	if copy.players[0].hp != 50:
		failures.append("deep_duplicate: copy.players[0].hp should be 50, got %d" % copy.players[0].hp)

	# Independence: mutating copy must not change original
	copy.players[0].hp = 1
	copy.run_id = "mutated"
	copy.seed = 0
	if gs.players[0].hp != 50:
		failures.append("deep_duplicate: mutating copy.players[0].hp affected original (got %d, expected 50)" % gs.players[0].hp)
	if gs.run_id != "original":
		failures.append("deep_duplicate: mutating copy.run_id affected original")
	if gs.seed != 99:
		failures.append("deep_duplicate: mutating copy.seed affected original")

	# Independence in the other direction: mutating original must not change copy
	gs.players[0].gold = 9999
	if copy.players[0].gold == 9999:
		failures.append("deep_duplicate: mutating original.players[0].gold affected copy")

	return failures


# EventLog.append_command and append_events must store entries in order.
func _test_event_log_append() -> Array[String]:
	var log: EventLog = EventLog.new()
	log.seed = 7

	var cmd1: Command = Command.new()
	cmd1.actor_id = "p1"
	cmd1.command_type = "TEST_CMD_1"
	cmd1.timestamp_logical = 1
	log.append_command(cmd1)

	var cmd2: Command = Command.new()
	cmd2.actor_id = "p1"
	cmd2.command_type = "TEST_CMD_2"
	cmd2.timestamp_logical = 2
	log.append_command(cmd2)

	var events: Array[GameEvent] = [
		GameEvent.new("E1", {"a": 1}),
		GameEvent.new("E2", {"b": 2}),
	]
	log.append_events(events)

	var failures: Array[String] = []
	if log.commands.size() != 2:
		failures.append("event_log: expected 2 commands, got %d" % log.commands.size())
	if log.commands[0].command_type != "TEST_CMD_1":
		failures.append("event_log: commands[0] type wrong")
	if log.commands[1].timestamp_logical != 2:
		failures.append("event_log: commands[1] timestamp wrong")
	if log.events.size() != 2:
		failures.append("event_log: expected 2 events, got %d" % log.events.size())
	if log.events[0].event_type != "E1":
		failures.append("event_log: events[0] type wrong")
	return failures


# GameEvent should construct with type + data dictionary.
func _test_game_event_construction() -> Array[String]:
	var evt: GameEvent = GameEvent.new("DAMAGE_DEALT", {"target": "skeleton_3", "amount": 11})
	var failures: Array[String] = []
	if evt.event_type != "DAMAGE_DEALT":
		failures.append("game_event: event_type wrong, got '%s'" % evt.event_type)
	if not evt.data.has("target") or evt.data.get("target") != "skeleton_3":
		failures.append("game_event: data.target wrong")
	if not evt.data.has("amount") or evt.data.get("amount") != 11:
		failures.append("game_event: data.amount wrong")
	return failures


# Command base class default validate() returns true; default apply() returns [].
# Subclasses override these. The defaults must be sane for the base.
func _test_command_default_validate_apply() -> Array[String]:
	var cmd: Command = Command.new()
	cmd.actor_id = "test"
	cmd.command_type = "BASE_TEST"
	var failures: Array[String] = []

	var dummy_state: GameState = GameState.new()
	if not cmd.validate(dummy_state):
		failures.append("command: base validate() should return true by default")

	var events: Array[GameEvent] = cmd.apply(dummy_state)
	if events.size() != 0:
		failures.append("command: base apply() should return empty array, got size %d" % events.size())
	return failures


# GameState.find_player(actor_id) returns the matching player or null.
func _test_find_player_helper() -> Array[String]:
	var gs: GameState = GameState.new()
	var p1: PlayerState = PlayerState.new()
	p1.actor_id = "p1"
	p1.display_name = "Alice"
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "p2"
	p2.display_name = "Bob"
	gs.players.append(p1)
	gs.players.append(p2)

	var failures: Array[String] = []
	var found_p1: PlayerState = gs.find_player("p1")
	if found_p1 == null:
		failures.append("find_player: should have found p1")
	elif found_p1.display_name != "Alice":
		failures.append("find_player: found wrong player for p1, got '%s'" % found_p1.display_name)

	var found_p2: PlayerState = gs.find_player("p2")
	if found_p2 == null:
		failures.append("find_player: should have found p2")
	elif found_p2.display_name != "Bob":
		failures.append("find_player: found wrong player for p2")

	var found_none: PlayerState = gs.find_player("does_not_exist")
	if found_none != null:
		failures.append("find_player: should have returned null for nonexistent id")

	return failures
