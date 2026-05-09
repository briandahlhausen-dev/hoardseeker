## EndTurnCommand
##
## The active actor declares their turn over. Advances turn_order to the
## next actor, refreshes the new actor's action points, increments the
## round counter when we wrap from last back to first.
##
## This is the second concrete Command — simpler than AttackCommand,
## same pattern. It's how a player says "I'm done thinking, move on."
##
## Resolution:
##   1. Validate: actor_id matches state.active_actor_id
##   2. Emit TURN_ENDED event for the outgoing actor
##   3. Advance state.active_actor_id to the next entry in turn_order
##   4. If we wrapped (next == first), increment round (in EncounterState
##      if present, otherwise on GameState as a logical event)
##   5. Refresh the new active player's action_points to max
##   6. Emit TURN_STARTED event for the incoming actor
##
## Knows about: GameState, PlayerState, GameEvent.
## Used by: CommandProcessor, tests.

class_name EndTurnCommand extends Command


func _init(p_actor_id: String = "") -> void:
	actor_id = p_actor_id
	command_type = "END_TURN"


func validate(state: Resource) -> bool:
	# Only the actor whose turn it currently is may end the turn.
	if state.active_actor_id == "":
		return false
	if state.active_actor_id != actor_id:
		return false
	# Turn order must be non-empty (otherwise there's nothing to advance to).
	if state.turn_order.is_empty():
		return false
	return true


func apply(state: Resource) -> Array[GameEvent]:
	var events: Array[GameEvent] = []

	events.append(GameEvent.new("TURN_ENDED", {"actor": actor_id}))

	# Advance to the next actor in turn_order.
	var current_idx: int = state.turn_order.find(actor_id)
	# If for some reason the actor isn't in turn_order (shouldn't happen
	# given validate, but defensive), default to first entry.
	if current_idx < 0:
		current_idx = 0
	var next_idx: int = (current_idx + 1) % state.turn_order.size()
	var wrapped: bool = next_idx <= current_idx
	var next_actor_id: String = state.turn_order[next_idx]
	state.active_actor_id = next_actor_id

	# If we wrapped from last actor back to first, that's a new round.
	if wrapped:
		var round_num: int = 1
		if state.current_encounter != null:
			state.current_encounter.round_number += 1
			round_num = state.current_encounter.round_number
		events.append(GameEvent.new("ROUND_STARTED", {"round": round_num}))

	# Refresh the new active actor's action points — player-only by design.
	# Monsters don't yet take AP-driven actions, so a missing refresh on a
	# monster is intentional, not stale code. Whether monster turns will
	# share this AP path or use a separate mechanism is an open design
	# question (see IDEAS.md), to be decided when monster AI lands.
	var next_player: PlayerState = state.find_player(next_actor_id)
	if next_player != null:
		next_player.action_points = next_player.max_action_points

	events.append(GameEvent.new("TURN_STARTED", {"actor": next_actor_id}))

	return events
