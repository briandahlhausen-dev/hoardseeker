## EventLog
##
## Append-only log of every command issued in this run + every event emitted
## by those commands. The log + the seed = the entire run. From these two
## things alone we can:
##
##   1. Replay the run to its current state (deterministically)
##   2. Verify a leaderboard score (server replays, confirms final state)
##   3. Generate spectator playback ("watch this run")
##   4. Reproduce bug reports (paste the log, replay, see the bug)
##   5. Migrate old saves to new versions (replay through migration shims)
##
## This is the load-bearing artifact behind anti-cheat and replay sharing.
## Treat it accordingly: never modify a logged command after the fact, never
## skip events, never let any code mutate state outside this pipeline.
##
## See ARCHITECTURE.md "Event log & replays" for the full contract.
##
## Knows about: Command, GameEvent, GameState (only via replay()).
## Used by: CommandProcessor (writes to it), replay validators (reads it).

class_name EventLog extends Resource

## The full ordered command history for this run.
@export var commands: Array[Command] = []

## The full ordered event history. May be larger than commands (one command
## can emit multiple events).
@export var events: Array[GameEvent] = []

## The seed this run was created with. Replay needs it to recreate the
## RNGService in the same starting state.
@export var seed: int = 0


## Append a single command to the log. Called by the CommandProcessor
## when a command has been validated and is about to apply.
func append_command(cmd: Command) -> void:
	commands.append(cmd)


## Append the events emitted by a command. Called by the CommandProcessor
## immediately after a command's apply() returns.
func append_events(events_list: Array[GameEvent]) -> void:
	events.append_array(events_list)


## Replay this log against an initial GameState, producing the final state.
## The initial_state must be the state at run-start (post-character-creation,
## pre-first-command). Returns the post-replay state.
##
## If any logged command fails to validate during replay, that's a desync
## or a tampered log — push_error and return the partial state. The caller
## (validator, replay viewer) decides what to do from there.
##
## Note: parameter and return type are Resource (not GameState) to avoid
## a circular class_name dependency at parse time. Caller casts as needed.
func replay(initial_state: Resource) -> Resource:
	var state: Resource = initial_state.duplicate(true)
	for cmd in commands:
		if not cmd.validate(state):
			push_error("EventLog.replay: command #%d failed validation" % commands.find(cmd))
			return state
		cmd.apply(state)
	return state
