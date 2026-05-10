## ApplyStatusEffectCommand
##
## Applies a StatusEffect to a target actor. The fourth concrete Command,
## and the entry point for all status-effect creation in the simulation —
## environmental hazards, ability triggers, monster abilities all eventually
## route through this command (or wrap it).
##
## Note: Phase 1 chunk 8 introduces this command but does NOT yet wire
## abilities to it. UseAbilityCommand still doesn't apply effects on hit —
## that integration is the next chunk (so AbilityDef.applies_effect_id
## or similar can be designed properly). For now, tests construct
## ApplyStatusEffectCommand directly to drive status-effect coverage.
##
## Resolution sequence:
##   1. Validate: target exists and is alive
##   2. Append the effect to target.status_effects
##   3. Emit STATUS_APPLIED event
##
## Validation does NOT enforce stacking rules (e.g. "you can't stun an
## already-stunned actor"). Stacking is a deferred design call — see
## IDEAS.md. Currently effects can stack freely; tick logic processes
## them in array order.
##
## Knows about: GameState, StatusEffect, GameEvent.
##              Treats target as untyped Resource (find_actor returns either
##              PlayerState or MonsterState; both have status_effects).
## Used by: CommandProcessor, tests, eventually UseAbilityCommand and
##          any environmental-hazard / monster-ability path.

class_name ApplyStatusEffectCommand extends Command

## The actor receiving the effect. Resolved via state.find_actor.
@export var target_id: String = ""

## The effect to apply. Constructed by the caller. The command takes
## ownership conceptually — once applied, mutating this object would
## also mutate the on-actor instance. Tests / callers should construct
## a fresh StatusEffect per command, not reuse a shared one.
@export var effect: StatusEffect


func _init(p_actor_id: String = "", p_target_id: String = "", p_effect: StatusEffect = null) -> void:
	actor_id = p_actor_id
	target_id = p_target_id
	effect = p_effect
	command_type = "APPLY_STATUS_EFFECT"


func validate(state: Resource) -> bool:
	# The applying actor doesn't need to exist — environmental hazards
	# and other non-actor sources are valid (with actor_id == "" or a
	# sentinel like "environment"). What we DO require is a real target
	# and a real effect.
	if effect == null:
		return false
	if effect.effect_id == "":
		return false

	var target: Resource = state.find_actor(target_id)
	if target == null:
		return false
	if target.hp <= 0:
		return false
	return true


func apply(state: Resource) -> Array[GameEvent]:
	var events: Array[GameEvent] = []
	var target: Resource = state.find_actor(target_id)

	# Append the effect to target's status_effects array.
	target.status_effects.append(effect)

	events.append(GameEvent.new("STATUS_APPLIED", {
		"actor": actor_id,                          # who applied it (may be "")
		"target": target_id,
		"effect_id": effect.effect_id,
		"duration": effect.duration_remaining,
	}))

	return events
