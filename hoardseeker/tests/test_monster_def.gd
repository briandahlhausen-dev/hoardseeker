## test_monster_def.gd
##
## Verifies the MonsterDef resource class and the canonical first monster,
## skeleton_warrior.tres. Mirrors test_ability_def's coverage shape since
## MonsterDef is the monster-side application of the same data-driven
## pattern (CLAUDE.md hard rule #4).
##
## Coverage:
##   - Default-construct a MonsterDef in memory; sensible defaults
##   - skeleton_warrior.tres loads as MonsterDef with canonical stats
##   - spawn_monster_state(actor_id) produces a usable MonsterState
##     with HP / AP at max, ac copied, distinct actor_ids across spawns
##   - ability_ids is independent across spawns (no shared array refs)
##
## Uses preload() for fresh-checkout robustness.

extends RefCounted

const MonsterDef = preload("res://src/content/monsters/monster_def.gd")
const MonsterState = preload("res://src/core/monster_state.gd")

const SKELETON_WARRIOR_PATH := "res://src/content/monsters/skeleton_warrior.tres"


func run_tests() -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_test_default_construction())
	failures.append_array(_test_skeleton_warrior_tres_loads())
	failures.append_array(_test_skeleton_warrior_canonical_stats())
	failures.append_array(_test_spawn_monster_state_returns_usable_state())
	failures.append_array(_test_spawn_monster_state_with_distinct_actor_ids())
	failures.append_array(_test_spawn_monster_state_does_not_share_array_refs())
	return failures


# Fresh in-memory MonsterDef should construct cleanly with sensible defaults.
func _test_default_construction() -> Array[String]:
	var def: MonsterDef = MonsterDef.new()
	var failures: Array[String] = []
	if def.id != "":
		failures.append("default: id should be empty, got '%s'" % def.id)
	if def.max_hp != 1:
		failures.append("default: max_hp should default to 1, got %d" % def.max_hp)
	if def.ac != 10:
		failures.append("default: ac should default to 10, got %d" % def.ac)
	if def.max_action_points != 2:
		failures.append("default: max_action_points should default to 2, got %d" % def.max_action_points)
	if def.ability_ids.size() != 0:
		failures.append("default: ability_ids should start empty")
	return failures


# skeleton_warrior.tres exists on disk and loads as a non-null MonsterDef.
func _test_skeleton_warrior_tres_loads() -> Array[String]:
	var loaded: Resource = load(SKELETON_WARRIOR_PATH)
	var failures: Array[String] = []
	if loaded == null:
		failures.append("tres_loads: load() returned null for %s" % SKELETON_WARRIOR_PATH)
		return failures
	if not (loaded is MonsterDef):
		failures.append("tres_loads: loaded resource is not a MonsterDef (got %s)" % loaded.get_class())
	return failures


# skeleton_warrior.tres carries the canonical stats (12 HP, AC 13, 2 AP).
# These match what test fixtures across the project have been hard-coding;
# the .tres now becomes the canonical source for "skeleton" everywhere.
func _test_skeleton_warrior_canonical_stats() -> Array[String]:
	var def: MonsterDef = load(SKELETON_WARRIOR_PATH) as MonsterDef
	var failures: Array[String] = []
	if def == null:
		failures.append("canonical: skeleton_warrior.tres failed to load as MonsterDef")
		return failures
	if def.id != "skeleton_warrior":
		failures.append("canonical: id should be 'skeleton_warrior', got '%s'" % def.id)
	if def.max_hp != 12:
		failures.append("canonical: max_hp should be 12, got %d" % def.max_hp)
	if def.ac != 13:
		failures.append("canonical: ac should be 13, got %d" % def.ac)
	if def.max_action_points != 2:
		failures.append("canonical: max_action_points should be 2, got %d" % def.max_action_points)
	if def.name_string_id == "" or def.name_string_id.contains(" "):
		failures.append("canonical: name_string_id should be a string-table id (got '%s')" % def.name_string_id)
	return failures


# spawn_monster_state(id) returns a MonsterState pre-populated from the
# def's canonical stats. HP and AP start at max — the spawn produces a
# fresh, ready-to-fight monster.
func _test_spawn_monster_state_returns_usable_state() -> Array[String]:
	var def: MonsterDef = load(SKELETON_WARRIOR_PATH) as MonsterDef
	var m: MonsterState = def.spawn_monster_state("skel_1")
	var failures: Array[String] = []
	if m == null:
		failures.append("spawn: spawn_monster_state returned null")
		return failures
	if m.actor_id != "skel_1":
		failures.append("spawn: actor_id should be 'skel_1', got '%s'" % m.actor_id)
	if m.monster_id != "skeleton_warrior":
		failures.append("spawn: monster_id should match def id, got '%s'" % m.monster_id)
	if m.hp != 12 or m.max_hp != 12:
		failures.append("spawn: HP/max_hp should be 12, got hp=%d max_hp=%d" % [m.hp, m.max_hp])
	if m.ac != 13:
		failures.append("spawn: ac should be 13, got %d" % m.ac)
	if m.action_points != 2 or m.max_action_points != 2:
		failures.append("spawn: AP/max_AP should be 2, got ap=%d max=%d" % [m.action_points, m.max_action_points])
	return failures


# Two spawns from the same def must have different actor_ids (caller-
# supplied) but identical stats. This is the multi-skeleton pattern —
# encounters with two skeleton_warriors get skel_1 + skel_2 from the
# same def.
func _test_spawn_monster_state_with_distinct_actor_ids() -> Array[String]:
	var def: MonsterDef = load(SKELETON_WARRIOR_PATH) as MonsterDef
	var m1: MonsterState = def.spawn_monster_state("skel_1")
	var m2: MonsterState = def.spawn_monster_state("skel_2")
	var failures: Array[String] = []
	if m1.actor_id == m2.actor_id:
		failures.append("distinct_ids: both spawns got the same actor_id '%s'" % m1.actor_id)
	if m1.monster_id != m2.monster_id:
		failures.append("distinct_ids: monster_id should match (both from same def)")
	if m1.hp != m2.hp or m1.ac != m2.ac:
		failures.append("distinct_ids: stats should be identical across spawns")
	# Verify they are distinct objects (mutating one doesn't affect the other)
	m1.hp = 0
	if m2.hp == 0:
		failures.append("distinct_ids: mutating m1.hp affected m2 (shared reference)")
	return failures


# ability_ids on the def is an Array; spawns must NOT share the underlying
# array reference. If they did, mutating one monster's ability_ids during
# combat would mutate the def AND every other spawn from that def.
func _test_spawn_monster_state_does_not_share_array_refs() -> Array[String]:
	var def: MonsterDef = MonsterDef.new()
	def.id = "test_monster"
	def.ability_ids = ["bone_slash", "stomp"]

	var m1: MonsterState = def.spawn_monster_state("m1")
	var m2: MonsterState = def.spawn_monster_state("m2")

	# Mutate m1's ability_ids — m2 and the def must be unaffected.
	m1.ability_ids.append("new_ability")

	var failures: Array[String] = []
	if m2.ability_ids.size() != 2:
		failures.append("array_refs: m2.ability_ids was affected by mutating m1 (shared reference)")
	if def.ability_ids.size() != 2:
		failures.append("array_refs: def.ability_ids was affected by mutating spawn (shared reference)")
	return failures
