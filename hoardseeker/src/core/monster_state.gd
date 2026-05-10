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
## Convention: values stored here are SAVE MODIFIERS (signed ints), not
## raw ability scores. CON 14 in D&D maps to +2 modifier; we store 2.
## Empty dictionary means "all stats at +0" — the average baseline that
## still allows save throws to function (lookup defaults to 0).
@export var stats: Dictionary = {}          # {"STR": 1, "DEX": 0, "CON": 2, ...}

# === Abilities the monster can use this encounter ===
@export var ability_ids: Array[String] = []

# === Status effects applied to this monster ===
@export var status_effects: Array = []      # Array of StatusEffect resources (Phase 1+)

# === Damage resistances ===
## Maps damage_type (String) -> multiplier (float). 1.0 = normal damage,
## 0.5 = half damage (resistance), 0.0 = immunity, 2.0 = vulnerability.
## Missing keys default to 1.0 (no modifier). Populated from MonsterDef
## at spawn; can be temporarily modified during combat (e.g. by status
## effects that grant resistance).
@export var damage_resistances: Dictionary = {}
