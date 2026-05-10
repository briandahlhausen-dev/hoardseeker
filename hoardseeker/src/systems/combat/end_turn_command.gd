## EndTurnCommand
##
## The active actor declares their turn over. Advances turn_order to the
## next actor, refreshes the new actor's action points, ticks status
## effects on the new active actor, increments the round counter when
## we wrap from last back to first.
##
## This is the second concrete Command. It's how a player says "I'm
## done thinking, move on" — and it's also where status-effect ticking
## happens, since "start of an actor's turn" is the canonical moment
## for effects to decrement / apply / expire.
##
## Resolution:
##   1. Validate: actor_id matches state.active_actor_id
##   2. Emit TURN_ENDED event for the outgoing actor
##   3. Advance state.active_actor_id to the next entry in turn_order
##   4. If we wrapped (next == first), increment round (in EncounterState
##      if present, otherwise on GameState as a logical event)
##   5. Refresh the new active player's action_points to max
##   6. Tick the new active actor's status_effects (decrement durations,
##      apply per-turn behavior like stun, remove expired)
##   7. Emit TURN_STARTED event for the incoming actor
##
## Status-effect tick order: AP refresh happens BEFORE the tick, so stun
## (which zeros AP) sees a full AP pool to deny. If the order were
## reversed, stun would hit zero AP, then the AP refresh would undo it.
##
## Knows about: GameState, PlayerState, StatusEffect, GameEvent.
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

	# Refresh the new active actor's action points. Both players AND
	# monsters get the refresh — design call captured in the chunk-J
	# DECISIONS entry ("Monster turn flow: A, share AP-driven turns").
	# find_actor returns either kind; the duck-typed access works because
	# both PlayerState and MonsterState have action_points / max_action_points.
	var next_actor: Resource = state.find_actor(next_actor_id)
	if next_actor != null:
		next_actor.action_points = next_actor.max_action_points

	# Tick status effects on the new active actor — both players AND monsters.
	# Effects exist on either kind of actor, and stun/poison/etc. should
	# affect monsters now that monster AI / AP refresh is wired up.
	# (next_actor was already resolved above for AP refresh; reuse it.)
	if next_actor != null:
		_tick_status_effects(next_actor, next_actor_id, events)

	events.append(GameEvent.new("TURN_STARTED", {"actor": next_actor_id}))

	return events


## Tick the actor's status effects at the start of their turn:
##   - Apply per-turn behavior (stun zeros AP; future: poison damages, etc.)
##   - Decrement duration_remaining
##   - Remove expired effects (duration_remaining <= 0)
##
## Iterates a copy of the array so we can rebuild it cleanly. Per-effect
## events are appended to `events` for replay / renderer consumption.
##
## Effect dispatch is on effect_id. Adding a new effect kind:
##   1. Create a new branch in the dispatch
##   2. Add tests in test_status_effect.gd
## No new code outside this function — that's the chunk-8 design call.
func _tick_status_effects(actor: Resource, actor_id: String, events: Array[GameEvent]) -> void:
	var surviving: Array = []
	for effect in actor.status_effects:
		# Per-turn behavior dispatch
		match effect.effect_id:
			"stun":
				# Stun denies all action points for the turn. For monsters
				# (who don't carry AP yet), this is currently a no-op on
				# action_points — but the event still fires so renderers
				# show "stunned!" and replays attribute the moment.
				actor.action_points = 0
			"poison", "bleed":
				# Damage-over-time effects share one arm. They differ only
				# in their default damage_type — poison defaults to "poison"
				# (its own resistance lookup), bleed defaults to "physical"
				# (zombie's physical resistance reduces bleed but not poison).
				# Either can override via params.damage_type.
				#
				# params.damage_per_turn is the pre-resistance amount.
				# Resistance is applied via target.damage_resistances same
				# as direct attacks, so DOT damage and direct damage now
				# follow consistent rules.
				var dmg: int = effect.params.get("damage_per_turn", 0)
				if dmg > 0:
					var default_type: String = "poison" if effect.effect_id == "poison" else "physical"
					var dtype: String = effect.params.get("damage_type", default_type)
					var resist: float = actor.damage_resistances.get(dtype, 1.0)
					dmg = max(0, int(dmg * resist))
					if dmg > 0:
						actor.hp = max(0, actor.hp - dmg)
						events.append(GameEvent.new("DAMAGE_DEALT", {
							"target": actor_id,
							"amount": dmg,
							"source": "status_effect:" + effect.effect_id,
							"damage_type": dtype,
							"crit": false,
						}))
						if actor.hp <= 0:
							events.append(GameEvent.new("ACTOR_DEFEATED", {
								"target": actor_id,
							}))
			"slow":
				# Slow reduces AP each turn (after the AP refresh has run).
				# params.ap_reduction is the amount. Floored at 0; can't go
				# negative. For an actor with max_action_points = 3 and
				# ap_reduction = 1, slow leaves them at AP = 2.
				var reduction: int = effect.params.get("ap_reduction", 0)
				actor.action_points = max(0, actor.action_points - reduction)
			"regenerate":
				# Regenerate heals the target each tick, capped at max_hp.
				# Skips if the actor is already defeated (no Lazarus effect).
				if actor.hp > 0:
					var heal: int = effect.params.get("hp_per_turn", 0)
					if heal > 0:
						var actual: int = min(heal, actor.max_hp - actor.hp)
						if actual > 0:
							actor.hp += actual
							events.append(GameEvent.new("HEALED", {
								"target": actor_id,
								"amount": actual,
								"source": "status_effect:regenerate",
							}))
			# Future effect types (bleed, burn, charm, etc.) add their
			# dispatch branches here. Effects with no per-turn behavior
			# (only modifying initial values) fall through.
			_:
				pass

		events.append(GameEvent.new("STATUS_TICKED", {
			"target": actor_id,
			"effect_id": effect.effect_id,
			"duration_after": effect.duration_remaining - 1,
		}))

		# Decrement and decide whether the effect survives.
		# Permanent effects use duration_remaining == -1 (untouched here).
		if effect.duration_remaining > 0:
			effect.duration_remaining -= 1
		if effect.duration_remaining > 0 or effect.duration_remaining == -1:
			surviving.append(effect)
		else:
			events.append(GameEvent.new("STATUS_EXPIRED", {
				"target": actor_id,
				"effect_id": effect.effect_id,
			}))

	actor.status_effects = surviving
