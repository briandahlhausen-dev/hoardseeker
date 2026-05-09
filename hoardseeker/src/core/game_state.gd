## GameState
##
## The top-level container for the entire simulation state of a run. Every
## gameplay value either lives in here, or in a Resource referenced from here.
## Anything not in GameState (or reachable from it) doesn't exist as far as
## the simulation is concerned.
##
## Saving a run = saving this resource. Loading a run = loading this resource.
## Replaying a run = creating a fresh GameState with the same seed and applying
## the EventLog's commands.
##
## CRITICAL RULES (from ARCHITECTURE.md):
##   - Pure data. No methods that emit signals. No node references. No
##     scene-tree dependencies. Resources only, IDs only.
##   - Mutated only by Commands via the CommandProcessor pipeline. Never
##     touched directly by UI, audio, or systems.
##   - Renderers READ from GameState; they NEVER write to it.
##
## Phase 0: GameState exists as a scaffold with the field set defined.
## Phase 1: CommandProcessor + first commands actually populate / mutate it.
##
## Knows about: RNGService, PlayerState, MonsterState, DungeonState,
##              EncounterState, EventLog. All resource types.
## Used by: every system in the project, indirectly via the processor.

class_name GameState extends Resource

# === Run identity ===
@export var run_id: String = ""                # unique per-run identifier
@export var seed: int = 0                      # the run's master seed

# === RNG ===
## All random calls in gameplay logic flow through this service. Created
## with the run's seed. Saved as part of the state so replays restore the
## RNG to the right stream_position when resuming a run.
@export var rng: RNGService

# === Players ===
## Solo: 1 entry. Duo: 2 entries. Designed N-player from day one — see
## ARCHITECTURE.md "N-player generality."
@export var players: Array[PlayerState] = []

# === World state ===
@export var dungeon: DungeonState
@export var current_encounter: EncounterState  # null when not in combat

# === Event log (for replay + anti-cheat) ===
@export var event_log: EventLog

# === Phase tracking ===
## High-level lifecycle of a run.
## Valid values: PRE_RUN, IN_DUNGEON, IN_COMBAT, BOSS, GAME_OVER.
@export var phase: String = "PRE_RUN"

# === Whose turn is it (across all actors, players + monsters) ===
@export var turn_order: Array[String] = []
@export var active_actor_id: String = ""


## Convenience: find the PlayerState with a given actor_id.
## Returns null if not found.
func find_player(p_actor_id: String) -> PlayerState:
	for p in players:
		if p.actor_id == p_actor_id:
			return p
	return null


## Convenience: find the MonsterState with a given actor_id within the
## current encounter. Returns null if there is no current encounter or no
## monster in it matches.
func find_monster(p_actor_id: String) -> MonsterState:
	if current_encounter == null:
		return null
	for m in current_encounter.monsters:
		if m.actor_id == p_actor_id:
			return m
	return null


## Convenience: find any actor (player or monster) by actor_id.
##
## Returns an untyped Resource because callers that need "either kind"
## genuinely don't care which concrete type came back — they treat both
## uniformly via duck-typed access (.hp, .actor_id, etc). Returning a
## shared base class would force MonsterState and PlayerState to inherit
## from one, coupling their lifecycle concerns prematurely.
##
## Returns null if no actor with that id exists.
func find_actor(p_actor_id: String) -> Resource:
	var p: PlayerState = find_player(p_actor_id)
	if p != null:
		return p
	return find_monster(p_actor_id)
