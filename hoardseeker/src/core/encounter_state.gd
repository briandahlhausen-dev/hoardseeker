## EncounterState
##
## State of the current combat encounter. Null when not in combat. When a
## fight starts, EncounterState is populated; when it resolves, it goes
## back to null.
##
## This is a SCAFFOLD. Phase 1 (combat core) populates the fields and wires
## up the turn loop, monster AI, status effect resolution, etc.
##
## Knows about: nothing. Pure data resource.
## Used by: GameState (single instance, may be null), CombatSystem (Phase 1),
##          combat_view UI (Phase 2).

class_name EncounterState extends Resource

@export var encounter_id: String = ""

## Monsters in this encounter. MonsterState lives in src/core/ alongside
## PlayerState — they're treated as siblings, not united under a shared
## base class.
@export var monsters: Array[MonsterState] = []

## Turn order — array of actor_ids (players + monsters) in initiative order.
## Rotates as turns complete. Recomputed at the start of each round.
@export var turn_order: Array[String] = []

## Whose turn it is right now. References an actor_id from turn_order.
@export var active_actor_id: String = ""

## Round counter — starts at 1 when the encounter begins, increments at
## the top of each new round.
@export var round_number: int = 1

## Front row vs back row positioning. Slay-the-Spire-style abstract
## positioning, not a grid. Maps actor_id -> "FRONT" | "BACK".
@export var positions: Dictionary = {}
