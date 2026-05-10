## MonsterDef
##
## Static definition of a monster — its canonical stats, abilities, the
## "what does this monster look like at spawn" data. Pure data Resource.
## Lives as a `.tres` file under `src/content/monsters/`. The filename
## (minus extension) is conventionally the same as the `id` field.
##
## Mirrors the AbilityDef pattern (CLAUDE.md hard rule #4: "content is
## data, not code"). Adding a new monster is a `.tres` change, not a
## code change. AI behaviors will eventually live here too — currently
## blocked on the IDEAS.md monster-turn design question.
##
## Spawn pattern: each def is its own factory via `spawn_monster_state()`.
## Encounter setup loads the .tres and asks it for a fresh runtime
## MonsterState instance. The actor_id (per-encounter unique handle like
## "skel_1", "skel_2") is supplied by the caller — multiple skeletons
## from the same def get different actor_ids in the same encounter.
##
## Localization-readiness: name and description fields hold *string IDs*,
## not literal English. The string table doesn't exist yet — when it
## does, monster lookup will route through `tr(name_string_id)`. See
## CONTENT.md "Localization readiness."
##
## Knows about: MonsterState (constructs one). Pure data otherwise.
## Used by: encounter setup code, tests, eventually a future MonsterRegistry.

class_name MonsterDef extends Resource

# === Identity ===
@export var id: String = ""                          # matches the .tres filename, e.g. "skeleton_warrior"
@export var name_string_id: String = ""              # e.g. "monster_skeleton_warrior_name"
@export var description_string_id: String = ""      # e.g. "monster_skeleton_warrior_description"

# === Canonical combat stats ===
@export var max_hp: int = 1
@export var ac: int = 10
@export var max_action_points: int = 2

# === Abilities the monster can use ===
## Ability ids (matching .tres files in src/content/abilities/) the monster
## brings into combat. Currently unused (no monster AI yet); will drive
## skeleton-side UseAbilityCommand once monster turns are designed.
@export var ability_ids: Array[String] = []

# === Damage resistances ===
## Maps damage_type (String) -> multiplier (float). 1.0 = normal damage,
## 0.5 = half damage (resistance), 0.0 = immunity, 2.0 = vulnerability.
## Copied to MonsterState on spawn; missing keys default to 1.0 at the
## resolution site (no modifier). Use this for static resistances baked
## into the monster — temporary resistance buffs go through status effects.
@export var damage_resistances: Dictionary = {}


## Construct a fresh MonsterState for this def. The actor_id is per-
## encounter unique (multiple skeletons from this def get different
## actor_ids in the same encounter). HP and AP start at max.
##
## Encounter setup typically calls this once per monster slot, then
## drops the resulting MonsterStates into EncounterState.monsters.
func spawn_monster_state(p_actor_id: String) -> MonsterState:
	var m: MonsterState = MonsterState.new()
	m.actor_id = p_actor_id
	m.monster_id = id
	# display_name will eventually be tr(name_string_id); keep the def's
	# id as a fallback until the string table lands.
	m.display_name = name_string_id if name_string_id != "" else id
	m.hp = max_hp
	m.max_hp = max_hp
	m.ac = ac
	m.action_points = max_action_points
	m.max_action_points = max_action_points
	m.ability_ids = ability_ids.duplicate()  # don't share array refs across spawns
	m.damage_resistances = damage_resistances.duplicate()  # same — independent dict per spawn
	return m
