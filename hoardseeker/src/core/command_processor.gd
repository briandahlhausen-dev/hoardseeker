## CommandProcessor
##
## The single point of entry for every state-changing action in the game.
## Validates a command, applies it, logs the command + emitted events.
## All gameplay flows through this — there is no other path to mutate state.
##
## Pipeline per process():
##   1. command.validate(state)  → bool
##   2. if invalid → return false (nothing changes; nothing logged)
##   3. assign command.timestamp_logical = next position in the log
##   4. command.apply(state)     → Array[GameEvent], mutates state
##   5. event_log.append_command(command)
##   6. event_log.append_events(events)
##   7. return true
##
## Why this matters (per ARCHITECTURE.md):
##   - Networking: in duo mode, commands are broadcast then processed on
##     each peer. The processor pipeline is identical on both sides;
##     determinism + same command stream = identical state.
##   - Replay: EventLog.replay() runs the same commands through this
##     processor against the initial state. Anti-cheat is "server replays,
##     confirms claimed score matches actual outcome."
##   - Save/load: state is serialized, command log is the audit trail.
##
## CommandProcessor itself is stateless — no fields, no per-instance memory.
## All state lives in GameState (and its EventLog). The processor is just
## a function call wrapped in a class for namespace clarity.
##
## Knows about: Command, GameState, EventLog, GameEvent.
## Used by: input handlers, AI controllers, network sync code, replay code.

class_name CommandProcessor extends RefCounted


## Process a single command against the given state.
## Returns true on success (validated + applied + logged).
## Returns false if validate() rejected — state is unchanged, nothing logged.
##
## The state's event_log must be non-null. (Phase 0 scaffolds may pass null
## for testing simple cases; in that case the command still applies, but no
## logging happens. Production code should always provide an event log.)
func process(command: Command, state: GameState) -> bool:
	if not command.validate(state):
		return false

	# Logical clock: this command's position in the log (0-indexed). Same
	# clock value is used for the events emitted by this command.
	var logical_time: int = 0
	if state.event_log != null:
		logical_time = state.event_log.commands.size()

	command.timestamp_logical = logical_time

	var events: Array[GameEvent] = command.apply(state)

	# Stamp emitted events with the same logical time so a replay can
	# reconstruct command-event grouping.
	for evt in events:
		evt.timestamp_logical = logical_time

	if state.event_log != null:
		state.event_log.append_command(command)
		state.event_log.append_events(events)

	return true


## Process a sequence of commands. Stops on the first rejection.
## Returns the number of commands successfully processed (i.e. all of them
## if every one validated, or N where the (N+1)th was rejected).
func process_all(commands: Array, state: GameState) -> int:
	var count: int = 0
	for cmd in commands:
		if not process(cmd, state):
			break
		count += 1
	return count
