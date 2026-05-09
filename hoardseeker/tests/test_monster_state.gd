## test_monster_state.gd
##
## Verifies MonsterState construction, default values, and the
## GameState helpers that find actors across players + monsters:
##   - find_monster(actor_id) -> MonsterState | null
##   - find_actor(actor_id)   -> Resource | null  (player or monster)
##
## These helpers are the foundation Chunk 2 will lean on when AttackCommand
## switches from find_player() to find_actor() so it can target either.
##
## Uses preload() rather than the global class registry so tests run reliably
## from a fresh checkout before the first --import pass. Same pattern as the
## other test files.

extends RefCounted

const GameState = preload("res://src/core/game_state.gd")
const PlayerState = preload("res://src/core/player_state.gd")
const MonsterState = preload("res://src/core/monster_state.gd")
const EncounterState = preload("res://src/core/encounter_state.gd")


func run_tests() -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_test_create_empty_monster_state())
	failures.append_array(_test_populate_monster_state())
	failures.append_array(_test_monster_deep_duplicate_independence())
	failures.append_array(_test_find_monster_returns_match())
	failures.append_array(_test_find_monster_no_encounter_returns_null())
	failures.append_array(_test_find_monster_unknown_id_returns_null())
	failures.append_array(_test_find_actor_finds_player())
	failures.append_array(_test_find_actor_finds_monster())
	failures.append_array(_test_find_actor_unknown_returns_null())
	failures.append_array(_test_find_actor_no_encounter_still_finds_player())
	return failures


# Build a GameState with a player and (optionally) an encounter with monsters.
func _make_state(with_encounter: bool, monster_specs: Array = []) -> GameState:
	var gs: GameState = GameState.new()

	var p: PlayerState = PlayerState.new()
	p.actor_id = "p1"
	p.display_name = "Aric"
	p.hp = 20
	p.max_hp = 20
	gs.players.append(p)

	if with_encounter:
		gs.current_encounter = EncounterState.new()
		for spec in monster_specs:
			var m: MonsterState = MonsterState.new()
			m.actor_id = spec["actor_id"]
			m.display_name = spec.get("display_name", "")
			m.monster_id = spec.get("monster_id", "")
			m.hp = spec.get("hp", 10)
			m.max_hp = spec.get("max_hp", 10)
			m.ac = spec.get("ac", 12)
			gs.current_encounter.monsters.append(m)

	return gs


# Fresh MonsterState should construct cleanly with sensible defaults.
func _test_create_empty_monster_state() -> Array[String]:
	var m: MonsterState = MonsterState.new()
	var failures: Array[String] = []
	if m.actor_id != "":
		failures.append("create_empty: default actor_id should be empty, got '%s'" % m.actor_id)
	if m.monster_id != "":
		failures.append("create_empty: default monster_id should be empty, got '%s'" % m.monster_id)
	if m.hp != 0:
		failures.append("create_empty: default hp should be 0, got %d" % m.hp)
	if m.max_action_points != 3:
		failures.append("create_empty: default max_action_points should be 3, got %d" % m.max_action_points)
	if m.ability_ids.size() != 0:
		failures.append("create_empty: ability_ids should start empty, got size %d" % m.ability_ids.size())
	if m.status_effects.size() != 0:
		failures.append("create_empty: status_effects should start empty, got size %d" % m.status_effects.size())
	return failures


# Populating fields and reading them back works as expected.
func _test_populate_monster_state() -> Array[String]:
	var m: MonsterState = MonsterState.new()
	m.actor_id = "skel_1"
	m.display_name = "Skeleton Warrior"
	m.monster_id = "skeleton_warrior"
	m.hp = 12
	m.max_hp = 12
	m.ac = 13
	m.action_points = 2
	m.ability_ids = ["bone_slash"]

	var failures: Array[String] = []
	if m.actor_id != "skel_1":
		failures.append("populate: actor_id mismatch")
	if m.display_name != "Skeleton Warrior":
		failures.append("populate: display_name mismatch")
	if m.monster_id != "skeleton_warrior":
		failures.append("populate: monster_id mismatch")
	if m.hp != 12 or m.max_hp != 12:
		failures.append("populate: hp/max_hp mismatch")
	if m.ac != 13:
		failures.append("populate: ac mismatch")
	if m.action_points != 2:
		failures.append("populate: action_points mismatch")
	if m.ability_ids.size() != 1 or m.ability_ids[0] != "bone_slash":
		failures.append("populate: ability_ids contents wrong")
	return failures


# A deep-duplicated MonsterState (via owning GameState.duplicate(true))
# must be independent of the original. Same contract as PlayerState.
func _test_monster_deep_duplicate_independence() -> Array[String]:
	var gs: GameState = _make_state(true, [{
		"actor_id": "skel_1",
		"display_name": "Skeleton",
		"hp": 10,
		"max_hp": 10,
	}])

	var copy: GameState = gs.duplicate(true)
	var failures: Array[String] = []

	if copy.current_encounter == null:
		failures.append("deep_duplicate: copy has no current_encounter")
		return failures
	if copy.current_encounter.monsters.size() != 1:
		failures.append("deep_duplicate: copy monsters size mismatch")
		return failures
	if copy.current_encounter.monsters[0].hp != 10:
		failures.append("deep_duplicate: copy monster hp mismatch")

	# Mutate copy; original must be unchanged.
	copy.current_encounter.monsters[0].hp = 1
	if gs.current_encounter.monsters[0].hp != 10:
		failures.append("deep_duplicate: mutating copy monster.hp affected original (got %d)" % gs.current_encounter.monsters[0].hp)

	# Mutate original; copy must be unchanged.
	gs.current_encounter.monsters[0].max_hp = 999
	if copy.current_encounter.monsters[0].max_hp == 999:
		failures.append("deep_duplicate: mutating original monster.max_hp affected copy")

	return failures


# find_monster returns the matching monster when an encounter is in flight.
func _test_find_monster_returns_match() -> Array[String]:
	var gs: GameState = _make_state(true, [
		{"actor_id": "skel_1", "display_name": "Skeleton A"},
		{"actor_id": "skel_2", "display_name": "Skeleton B"},
	])

	var failures: Array[String] = []
	var found: MonsterState = gs.find_monster("skel_2")
	if found == null:
		failures.append("find_monster: should have found skel_2")
	elif found.display_name != "Skeleton B":
		failures.append("find_monster: returned wrong monster, got '%s'" % found.display_name)
	return failures


# find_monster returns null when there is no current encounter.
func _test_find_monster_no_encounter_returns_null() -> Array[String]:
	var gs: GameState = _make_state(false)
	if gs.find_monster("skel_1") != null:
		return ["find_monster: should be null when no encounter is in flight"]
	return []


# find_monster returns null for an actor_id that doesn't exist in the encounter.
func _test_find_monster_unknown_id_returns_null() -> Array[String]:
	var gs: GameState = _make_state(true, [{"actor_id": "skel_1"}])
	if gs.find_monster("does_not_exist") != null:
		return ["find_monster: should be null for unknown actor_id"]
	return []


# find_actor finds a player by id.
func _test_find_actor_finds_player() -> Array[String]:
	var gs: GameState = _make_state(true, [{"actor_id": "skel_1"}])
	var found: Resource = gs.find_actor("p1")
	if found == null:
		return ["find_actor: should have found player p1"]
	if not (found is PlayerState):
		return ["find_actor: expected PlayerState for p1, got %s" % found.get_class()]
	if found.actor_id != "p1":
		return ["find_actor: returned wrong actor for p1"]
	return []


# find_actor finds a monster by id.
func _test_find_actor_finds_monster() -> Array[String]:
	var gs: GameState = _make_state(true, [{"actor_id": "skel_1", "display_name": "Bones"}])
	var found: Resource = gs.find_actor("skel_1")
	if found == null:
		return ["find_actor: should have found monster skel_1"]
	if not (found is MonsterState):
		return ["find_actor: expected MonsterState for skel_1, got %s" % found.get_class()]
	if found.actor_id != "skel_1":
		return ["find_actor: returned wrong actor for skel_1"]
	return []


# find_actor returns null for an unknown id.
func _test_find_actor_unknown_returns_null() -> Array[String]:
	var gs: GameState = _make_state(true, [{"actor_id": "skel_1"}])
	if gs.find_actor("nobody") != null:
		return ["find_actor: should be null for unknown actor_id"]
	return []


# find_actor finds a player even when no encounter is in flight.
# (Players exist outside encounters; monsters do not.)
func _test_find_actor_no_encounter_still_finds_player() -> Array[String]:
	var gs: GameState = _make_state(false)
	var found: Resource = gs.find_actor("p1")
	if found == null:
		return ["find_actor: should have found player p1 with no encounter"]
	if not (found is PlayerState):
		return ["find_actor: expected PlayerState, got %s" % found.get_class()]
	return []
