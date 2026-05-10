## StatusEffect
##
## A temporary modifier on an actor — stun, slow, poison, bleed, regenerate,
## etc. Pure-data Resource. Lives on actor.status_effects: Array (the field
## was scaffolded on PlayerState and MonsterState in chunk 1; this is the
## first chunk that gives it shape).
##
## Generic-by-design: one StatusEffect class with an effect_id field, not
## a separate StunEffect / PoisonEffect / SlowEffect class hierarchy. The
## tick logic in EndTurnCommand dispatches on effect_id. Reasons for
## generic-over-subclasses are in the chunk-8 DECISIONS.md entry; the
## short version is that effects are mostly data (a magnitude, a duration)
## with a small handful of behaviors we can dispatch on a string.
##
## When does it tick: at the START of the affected actor's turn. The new
## active actor's effects tick when EndTurnCommand makes them active —
## decrement duration, apply per-turn behavior (stun zeros AP, poison
## damages, etc.), remove expired effects.
##
## Knows about: nothing. Pure data resource.
## Used by: PlayerState, MonsterState (storage), EndTurnCommand (tick),
##          ApplyStatusEffectCommand (creation).

class_name StatusEffect extends Resource

## Identifier matching the effect kind. Tick logic dispatches on this.
## Examples: "stun", "slow", "poison", "bleed", "regenerate".
@export var effect_id: String = ""

## Turns remaining. Decremented at the start of the affected actor's turn.
## When it hits 0 the effect is removed (after applying its tick behavior
## one last time, if applicable). Use -1 for "permanent until cleansed".
@export var duration_remaining: int = 0

## Effect-specific parameters. Untyped Dictionary keeps the storage shape
## flexible for effects we haven't designed yet:
##   - poison:    {"damage_per_turn": 3}
##   - slow:      {"ap_reduction": 1}
##   - regenerate: {"hp_per_turn": 2}
## Empty for stun (the "no AP this turn" behavior is implicit in the
## effect_id, no parameters needed).
@export var params: Dictionary = {}

## Who applied this effect. Used for attribution in the event log
## (e.g. "Aric stunned the skeleton"). Empty if applied by an environmental
## hazard / non-actor source.
@export var source_actor_id: String = ""
