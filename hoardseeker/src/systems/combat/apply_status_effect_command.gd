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
## Stacking rule (chunk-K design call): when applying an effect with an
## effect_id already present on the target, the existing instance's
## duration_remaining is refreshed to max(existing, incoming) and the
## STATUS_REFRESHED event fires instead of STATUS_APPLIED. Params on the
## existing instance are preserved — the second application doesn't
## overwrite (D&D 5e refresh semantics, captured in DECISIONS).
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
	apply_effect_with_stacking(target, effect, actor_id, target_id, events)
	return events


## Stacking-aware effect application. Shared between this command and
## UseAbilityCommand's per-target effect-application loop so both paths
## use the same rule.
##
## - If an effect with the same effect_id is already on the target,
##   refresh its duration to max(existing, incoming). Existing params
##   stay (don't overwrite). Emit STATUS_REFRESHED with old/new durations.
## - Otherwise append the (already-supplied) effect and emit STATUS_APPLIED.
##
## Caller is responsible for passing a non-shared StatusEffect instance
## (UseAbilityCommand duplicates from AbilityDef.applies_effects so the
## def's instances aren't aliased onto live actors).
static func apply_effect_with_stacking(
	target: Resource,
	new_effect: StatusEffect,
	source_actor_id: String,
	target_id_for_event: String,
	events: Array[GameEvent],
) -> void:
	# Look for existing effect with same id
	for existing in target.status_effects:
		if existing.effect_id == new_effect.effect_id:
			var old_duration: int = existing.duration_remaining
			# Permanent effects (-1) stay permanent regardless of refresh
			if existing.duration_remaining == -1 or new_effect.duration_remaining == -1:
				existing.duration_remaining = -1
			else:
				existing.duration_remaining = max(existing.duration_remaining, new_effect.duration_remaining)
			events.append(GameEvent.new("STATUS_REFRESHED", {
				"actor": source_actor_id,
				"target": target_id_for_event,
				"effect_id": new_effect.effect_id,
				"old_duration": old_duration,
				"new_duration": existing.duration_remaining,
			}))
			return

	# No existing effect — append the new one fresh
	target.status_effects.append(new_effect)
	events.append(GameEvent.new("STATUS_APPLIED", {
		"actor": source_actor_id,
		"target": target_id_for_event,
		"effect_id": new_effect.effect_id,
		"duration": new_effect.duration_remaining,
	}))
