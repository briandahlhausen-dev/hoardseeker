# ARCHITECTURE.md — Hoardseeker

> **READ THIS BEFORE WRITING ANY CODE.**
> The patterns here are non-negotiable. They are what make duo co-op, ranked anti-cheat, and replay sharing possible.

---

## The five pillars

Everything else in this document follows from these.

1. **Determinism**: Same seed + same inputs = exactly the same game, every time.
2. **Pure data state**: Game state is serializable resources. No state lives in nodes or scenes.
3. **Command pattern**: All state changes go through commands. No direct mutation.
4. **Event sourcing**: Commands are logged. The current state is replayable from the log.
5. **N-player generality**: Every system handles a list of players. Solo is N=1, duo is N=2.

If you find yourself wanting to violate one of these, **stop and ask the user.** These are load-bearing.

---

## Project layout

The repository root contains the design docs (`*.md`), the `LICENSE`, the project-level `README.md`, and the `hoardseeker/` Godot project folder. The Godot project is a sibling to the docs, not a parent — this keeps the docs accessible without cd-ing into the game folder.

```
Hoardseeker/                   # repo root (project.godot is NOT here)
├── *.md                       # all design docs (CLAUDE.md, VISION.md, etc.)
├── LICENSE                    # all rights reserved
├── README.md                  # project overview
├── .gitignore                 # repo-wide
└── hoardseeker/               # Godot project root
    ├── project.godot
    ├── README.md              # short pointer back to root docs
    ├── .gitignore             # Godot-specific
    ├── src/
    │   ├── core/              # Engine-agnostic game logic. NO Godot dependencies here.
    │   │   ├── rng.gd         # RNGService — deterministic random
    │   │   ├── game_state.gd  # GameState resource — pure data
    │   │   ├── command.gd     # Command base class
    │   │   ├── command_processor.gd
    │   │   ├── event_log.gd   # Append-only log of all commands
    │   │   └── simulation.gd  # Headless game runner
    │   ├── content/           # Content as data (.tres resources)
    │   │   ├── classes/       # ClassDef resources
    │   │   ├── subclasses/
    │   │   ├── abilities/
    │   │   ├── artifacts/
    │   │   ├── monsters/
    │   │   └── biomes/
    │   ├── systems/           # Gameplay systems (combat, dungeon, loot, etc.)
    │   │   ├── combat/
    │   │   ├── dungeon/
    │   │   ├── loot/
    │   │   ├── progression/
    │   │   └── meta/
    │   ├── networking/        # Duo mode and leaderboards
    │   │   ├── lobby.gd
    │   │   ├── sync.gd
    │   │   └── leaderboard_client.gd
    │   └── ui/                # All visual/audio. Reads state, never writes.
    │       ├── screens/
    │       ├── widgets/
    │       ├── combat_view/
    │       └── narrator/
    ├── tests/                 # Headless tests
    │   ├── test_runner.gd
    │   ├── test_determinism.gd
    │   ├── test_combat.gd
    │   └── ...
    ├── assets/
    │   ├── art/
    │   ├── audio/
    │   └── fonts/
    └── tools/                 # Dev-only scripts (balance dashboards, content editors)
```

**Filenames in `src/core/` etc. are the planned scaffold** — empty placeholder directories with `.gitkeep` files exist now (Phase 0 setup); the actual `.gd` files are scaffolded in Phase 1.

**Critical rule**: `src/core/` has zero dependencies on Godot's scene tree, nodes, or rendering. It's pure GDScript that could theoretically run on a server. This is what makes determinism, headless tests, and server-side replay validation possible.

---

## Determinism (`src/core/rng.gd`)

```gdscript
class_name RNGService extends Resource

@export var seed: int = 0
@export var stream_position: int = 0
var _rng: RandomNumberGenerator

func _init(p_seed: int = 0) -> void:
    seed = p_seed
    _rng = RandomNumberGenerator.new()
    _rng.seed = seed
    stream_position = 0

func roll(sides: int) -> int:
    stream_position += 1
    return _rng.randi_range(1, sides)

func roll_dice(count: int, sides: int) -> Array[int]:
    var results: Array[int] = []
    for i in count:
        results.append(roll(sides))
    return results

func chance(probability: float) -> bool:
    stream_position += 1
    return _rng.randf() < probability

func pick(arr: Array) -> Variant:
    if arr.is_empty():
        return null
    stream_position += 1
    return arr[_rng.randi() % arr.size()]
```

**Rules of RNG:**

- All random values flow through this service.
- **Banned in game logic**: `randi()`, `randf()`, `randf_range()`, `Time.*`, `OS.get_unix_time()`, `Engine.get_frames_drawn()`.
- Renderers and animations may use `randf()` for visual jitter (no gameplay impact).
- Each game has one `RNGService` instance, seeded from the run seed.
- The `stream_position` is part of the save state — replays must reach the same position to be valid.

---

## Game state (`src/core/game_state.gd`)

```gdscript
class_name GameState extends Resource

@export var run_id: String = ""
@export var seed: int = 0
@export var rng: RNGService
@export var players: Array[PlayerState] = []
@export var dungeon: DungeonState
@export var current_encounter: EncounterState
@export var event_log: EventLog
@export var phase: String = "PRE_RUN"  # PRE_RUN, IN_DUNGEON, IN_COMBAT, BOSS, GAME_OVER
@export var turn_order: Array[String] = []
@export var active_actor_id: String = ""
```

**Rules of state:**

- Every gameplay-relevant value is an `@export` on a `Resource`. Saveable, loadable, serializable to JSON.
- No `Node` references in state. Use IDs (`String`) and resolve at the renderer layer.
- `PlayerState`, `EncounterState`, `DungeonState` are all resources, recursively.
- Anything not in `GameState` doesn't exist for game logic purposes.

---

## Command pattern (`src/core/command.gd`)

```gdscript
class_name Command extends Resource

@export var actor_id: String = ""
@export var timestamp_logical: int = 0  # Logical clock, not wall time
@export var command_type: String = ""

# Override in subclasses:
func validate(state: GameState) -> bool:
    return true

func apply(state: GameState) -> Array[GameEvent]:
    return []
```

Example concrete command:

```gdscript
class_name AttackCommand extends Command

@export var target_id: String = ""
@export var ability_id: String = ""

func validate(state: GameState) -> bool:
    var actor := state.find_actor(actor_id)
    var target := state.find_actor(target_id)
    var ability := state.find_ability(ability_id)
    if not actor or not target or not ability: return false
    if actor.action_points < ability.cost: return false
    return true

func apply(state: GameState) -> Array[GameEvent]:
    var events: Array[GameEvent] = []
    var actor := state.find_actor(actor_id)
    var target := state.find_actor(target_id)
    var ability := state.find_ability(ability_id)
    
    var attack_roll := state.rng.roll(20)
    events.append(GameEvent.new("DICE_ROLLED", {"actor": actor_id, "roll": attack_roll, "type": "attack"}))
    
    var hit := attack_roll >= target.armor_class
    if hit:
        var damage_dice := state.rng.roll_dice(ability.damage_count, ability.damage_sides)
        var damage: int = damage_dice.reduce(func(a, b): return a + b, 0)
        target.hp -= damage
        events.append(GameEvent.new("DAMAGE_DEALT", {"target": target_id, "amount": damage}))
    else:
        events.append(GameEvent.new("ATTACK_MISSED", {"actor": actor_id, "target": target_id}))
    
    actor.action_points -= ability.cost
    return events
```

**Rules of commands:**

- A command is a request; the processor decides if it's valid.
- Commands are pure functions of state: `(state, command) -> (new_state, events)`.
- Commands NEVER touch the renderer, audio, or scene tree. They emit events; the renderer listens.
- Every game-state change has a corresponding command. No exceptions.
- Networking is "send the command across the wire." That's it.

---

## Event log & replays (`src/core/event_log.gd`)

```gdscript
class_name EventLog extends Resource

@export var commands: Array[Command] = []
@export var events: Array[GameEvent] = []
@export var seed: int = 0

func append_command(cmd: Command) -> void:
    commands.append(cmd)

func append_events(events_list: Array[GameEvent]) -> void:
    events.append_array(events_list)

func replay(initial_state: GameState) -> GameState:
    var state := initial_state.duplicate(true)
    state.rng = RNGService.new(state.seed)
    for cmd in commands:
        if not cmd.validate(state):
            push_error("Replay validation failed at cmd %d" % commands.find(cmd))
            return state
        cmd.apply(state)
    return state
```

**Why this matters**: A run can be reduced to `(seed, [commands])`. To verify a leaderboard score, the server replays the commands deterministically and confirms the final state. **This is your anti-cheat.** It also enables:

- Spectator replays (watch top runs)
- "Daily seed" mode (everyone gets the same seed, same commands produce same results)
- Bug reports include the command log → reproduce instantly
- Shared "look at my insane run" clips

---

## N-player generality

Even though the vertical slice is solo, **every system handles `players: Array[PlayerState]` from day one.**

- Combat turn order is a queue of `actor_id`s, supporting any number of players.
- Loot drops emit a `LootAvailable` event with no implicit owner.
- The dungeon map tracks per-player position; for solo, it's an array of one.
- The narrator binds to events, not to a single player.

This is cheap to do upfront, *expensive* to retrofit. We do it now.

---

## Duo mode networking (deferred — see MULTIPLAYER.md)

Brief summary of the architecture so the rest of the code is shaped correctly:

- **Authoritative model**: One peer is host, the other is client. Both run the simulation; host's state is canonical for conflict resolution.
- **Sync method**: Lockstep — commands are broadcast to both peers, both peers apply commands deterministically, states stay in sync.
- **Why lockstep works**: Game is turn-based, so we have all the time we need to wait for both inputs. Latency budget is generous.
- **Transport**: GodotSteam (Steam relay networking). No port forwarding, no NAT issues.
- **Desync detection**: Periodic state hashes compared between peers. On mismatch, host's state wins.
- **Reconnect**: Client rejoin replays the command log to catch up.

The vertical slice does NOT implement networking. But the architecture must support adding it without rewrites.

---

## Content as data

Every gameplay element is a `.tres` resource. Examples:

```gdscript
# src/content/abilities/ability_def.gd
class_name AbilityDef extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var class_id: String = ""           # Which class can take this
@export var min_level: int = 1
@export var cost_action_points: int = 1
@export var cost_spell_slot: int = 0
@export var damage_count: int = 0
@export var damage_sides: int = 0
@export var damage_type: String = "PHYSICAL"
@export var target_type: String = "SINGLE_ENEMY"
@export var range_type: String = "MELEE"
@export var status_effects: Array[StatusEffectDef] = []
@export var icon: Texture2D
```

Adding a new spell = creating a new `.tres` file. Zero code changes.

This is critical for AI-assisted dev: I can generate 50 spell `.tres` files in a batch without touching the engine.

---

## Testing strategy

The simulation is testable headless. Every test runs without rendering.

```bash
godot --headless --script tests/test_runner.gd
```

**Test categories:**

1. **Determinism tests**: Run same seed + same commands twice, assert identical state hashes.
2. **Command tests**: Each command has unit tests for validate/apply.
3. **Combat scenarios**: Set up a fight, run scripted commands, assert outcomes.
4. **Replay tests**: Generate a run, save the event log, replay it, assert match.
5. **Balance tests**: Run 1000 simulated runs per class, assert win rate falls in expected range.

Every PR/commit must pass all tests. CI enforced.

---

## Performance notes

- **State serialization** must be fast. Use Godot's binary `Resource` format, not JSON, for live state.
- **Event log** can be large (a long run might have 5000 commands). Compress on save.
- **Commands per second** is low (turn-based). The bottleneck will be UI animations, not simulation.
- **Memory budget**: target <500MB total. We're not making AAA — keep textures reasonable.

---

## Tooling we'll need (build incrementally)

- **Content editor**: A custom Godot tool scene to author abilities/artifacts/monsters in-engine. Day one is fine to author `.tres` by hand; build the tool once content volume hurts.
- **Balance dashboard**: Run 1000 simulated games per class/subclass combination, output win rate / average run length / artifact pickup rate. Build at month 6.
- **Replay viewer**: Spectator UI that scrubs through an event log. Build at month 9.
- **Telemetry pipeline**: Anonymized run summaries shipped to a backend for balance analysis. Build before demo.

---

## What "good code" looks like in this project

- Adding a new class is editing data files + maybe one new `.gd` for unique mechanics.
- Adding a new ability is one `.tres` file.
- Adding a new biome is data + a few new monster `.tres` files + new artwork.
- Adding networking is wrapping the existing command pipeline. No rewrites.
- Adding console support is engine-level, not game-level. The game doesn't know what platform it's on.

If a feature requires changing many files across many systems, we got the architecture wrong. Stop and refactor.
