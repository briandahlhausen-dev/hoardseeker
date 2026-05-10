## PlayerState
##
## A single player's state in a run. Solo mode has one PlayerState in the
## GameState.players array; duo has two. Every system that reads or writes
## per-player data goes through this resource.
##
## This is a SCAFFOLD. Phase 1 (combat core) fills in the combat-relevant
## fields. Later phases add inventory, subclass progression, status effects,
## etc. Add fields here as they become needed — don't pre-fill speculatively.
##
## Knows about: nothing. Pure data resource.
## Used by: GameState (holds the array), every system that reads/writes
##          per-player values.

class_name PlayerState extends Resource

# === Identity ===
@export var actor_id: String = ""           # unique per-run identifier (e.g. "p1", "p2")
@export var display_name: String = ""       # "Aric the Bold" — human-readable
@export var class_id: String = ""           # ClassDef id, e.g. "fighter"
@export var subclass_id: String = ""        # SubclassDef id; "" until floor 5 draft
@export var race_id: String = ""            # RaceDef id, e.g. "human"

# === Combat-relevant (Phase 1 will exercise these) ===
@export var hp: int = 0
@export var max_hp: int = 0
@export var ac: int = 0
@export var action_points: int = 0
@export var max_action_points: int = 3

# === Stats (D&D-style) ===
@export var stats: Dictionary = {}          # {"STR": 14, "DEX": 12, ...}

# === Resources (per-class — populated by class definition at run start) ===
## Generic dictionary so each class can carry its own resource type
## (spell_slots, rage, ki, inspiration, etc.) without per-class fields here.
@export var resources: Dictionary = {}

# === Persistent run state ===
@export var ability_ids: Array[String] = []     # ability IDs the player currently has
@export var artifact_ids: Array[String] = []    # artifact IDs picked up
@export var status_effects: Array = []          # Array of StatusEffect resources (Phase 1+)

# === Damage resistances ===
## Maps damage_type (String) -> multiplier (float). 1.0 = normal damage,
## 0.5 = half damage (resistance), 0.0 = immunity, 2.0 = vulnerability.
## Missing keys default to 1.0. Populated from class/race/equipment
## eventually; for now stays empty unless explicitly set by tests or
## (future) buff effects.
@export var damage_resistances: Dictionary = {}
@export var gold: int = 0
@export var glints: int = 0                     # risk currency
