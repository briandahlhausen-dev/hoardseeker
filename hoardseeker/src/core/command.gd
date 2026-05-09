## Command
##
## Base class for all state-changing actions in the simulation. Commands
## are how the game produces new state — there is no other way. No system
## may mutate GameState directly. Every change goes through a Command.
##
## A Command is a pure function of state:
##   (state, command) -> (new_state, events)
##
## Subclasses override:
##   validate(state) -> bool       — is this command legal in this state?
##   apply(state) -> Array[GameEvent]  — mutate state, return what happened
##
## Networking is "send the command across the wire." Replay is "store the
## command list, replay against initial seed." Anti-cheat is "server replays
## the command log and verifies the score." All three follow from this
## pattern. See ARCHITECTURE.md "Command pattern" and "Event log & replays".
##
## Concrete subclasses live in src/systems/ near the system they affect:
##   src/systems/combat/attack_command.gd
##   src/systems/combat/use_ability_command.gd
##   src/systems/combat/end_turn_command.gd
##   ... etc.
##
## Knows about: GameState (read-only via validate; mutated via apply),
##              GameEvent (constructs them in apply).
## Used by: CommandProcessor (coming in Phase 1).

class_name Command extends Resource

@export var actor_id: String = ""

## Logical clock — monotonically increasing per-game integer. NOT wall-clock
## time (wall-clock breaks determinism). Assigned by the CommandProcessor
## when a command is accepted into the log.
@export var timestamp_logical: int = 0

## Discriminator for serialization / debugging / event log filtering.
## Subclasses set this in their _init().
@export var command_type: String = ""


## Override in subclasses. Returns true if this command is legal given the
## current state. validate() must be a pure function — no state mutation,
## no random calls, no side effects. Same state + same command = same
## validation result, every time.
func validate(_state: Resource) -> bool:
	return true


## Override in subclasses. Mutates the given state and returns the array of
## GameEvents that describe what happened. apply() may consume RNG (via the
## state's rng service) — that's the only "side effect" allowed. No direct
## audio, no UI calls, no logging outside of returned events.
##
## Note: parameter is typed Resource (not GameState) to avoid circular
## class_name resolution at parse time. Subclasses may type-cast as needed.
func apply(_state: Resource) -> Array[GameEvent]:
	return []
