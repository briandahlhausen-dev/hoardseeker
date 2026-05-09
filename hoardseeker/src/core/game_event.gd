## GameEvent
##
## A fact about something that happened in the simulation. Emitted by
## Commands when they apply; consumed by the renderer, audio, narrator,
## achievement system, and anything else that wants to know "X just happened."
##
## GameEvents are pure data. They never mutate state. They describe what
## the simulation did, not what to do next.
##
## Examples (data dictionaries shown loosely; actual contents are per-event):
##   GameEvent.new("DICE_ROLLED", {"actor": "p1", "roll": 18, "type": "attack"})
##   GameEvent.new("DAMAGE_DEALT", {"target": "skeleton_3", "amount": 11})
##   GameEvent.new("ATTACK_MISSED", {"actor": "p1", "target": "skeleton_3"})
##   GameEvent.new("STATUS_APPLIED", {"target": "p1", "status": "BURN", "duration": 3})
##
## Knows about: nothing. Pure data resource.
## Used by: every system that wants to react to simulation events.

class_name GameEvent extends Resource

@export var event_type: String = ""
@export var data: Dictionary = {}
@export var timestamp_logical: int = 0


func _init(p_type: String = "", p_data: Dictionary = {}) -> void:
	event_type = p_type
	data = p_data
