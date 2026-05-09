## DungeonState
##
## The current dungeon's branching map state — which biome we're in, which
## floor, which nodes are reachable, which path was taken so far.
##
## This is a SCAFFOLD. Phase 3 (run structure) fills in the map generation,
## node graph, and traversal logic.
##
## Knows about: nothing. Pure data resource.
## Used by: GameState (single instance), DungeonSystem (Phase 3),
##          map UI (Phase 3+).

class_name DungeonState extends Resource

@export var biome_id: String = ""               # current biome's BiomeDef id
@export var current_floor: int = 1              # 1..floor_count
@export var floor_count: int = 10               # total floors in this biome

## Per-player position on the map. Solo: 1 entry; duo: 2 entries.
## Maps actor_id -> node_id. Allows the split-party mechanic where each
## player can be at a different node simultaneously.
@export var actor_positions: Dictionary = {}

## All map nodes for the current biome. Each entry is a MapNode resource
## (defined in src/systems/dungeon/ in Phase 3). Untyped here to avoid
## introducing a class that doesn't exist yet.
@export var nodes: Array = []

## IDs of nodes the players have already cleared / visited.
@export var visited_node_ids: Array[String] = []
