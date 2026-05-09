## MonsterState
##
## A single monster's state within an encounter. Sibling of PlayerState —
## deliberately not unified under a CombatantState base class. Player and
## monster carry different lifecycle concerns (subclass draft, inventory,
## glints vs. AI behavior, loot table, despawn) and forcing a shared base
## couples them in ways we'd later have to unwind.
##
## When code needs "either kind of actor" (e.g. an attack that targets
## anyone), use GameState.find_actor() which returns an untyped Resource.
##
## This is a SCAFFOLD. Phase 1 (combat core) fills in the combat-relevant
## fields. Later phases add AI behaviors, loot tables, spawn metadata, etc.
## Add fields here as they become needed — don't pre-fill speculatively.
##
## Knows about: nothing. Pure data resource.
## Used by: EncounterState (holds the array), CombatProcessor / commands
##          that target monsters, GameState.find_actor() / find_monster().

class_name MonsterState extends Resource

# === Identity ===
@export var actor_id: String = ""           # unique per-encounter id (e.g. "skel_1")
@export var display_name: String = ""       # "Skeleton Warrior" — human-readable
@export var monster_id: String = ""         # MonsterDef id, e.g. "skeleton_warrior"

# === Combat-relevant (Phase 1 will exercise these) ===
@export var hp: int = 0
@export var max_hp: int = 0
@export var ac: int = 0
@export var action_points: int = 0
@export var max_action_points: int = 3

# === Stats (D&D-style, mirrors PlayerState for parity) ===
@export var stats: Dictionary = {}          # {"STR": 14, "DEX": 12, ...}

# === Abilities the monster can use this encounter ===
@export var ability_ids: Array[String] = []

# === Status effects applied to this monster ===
@export var status_effects: Array = []      # Array of StatusEffect resources (Phase 1+)
