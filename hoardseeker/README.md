# hoardseeker (Godot project root)

This is the Godot 4 project root. Open `project.godot` in Godot to load the editor.

**For project orientation, read the docs at the parent directory:**
- `../README.md` — project overview
- `../CLAUDE.md` — index for Claude Code sessions; hard rules; current state
- `../ARCHITECTURE.md` — code structure (read before writing code here)
- `../VIBE_CODING.md` — how the solo+AI workflow works
- `../SESSION_PROTOCOL.md` — session-management discipline
- `../DECISIONS.md` — decision log
- All other design docs are at `../`

## Layout (per ARCHITECTURE.md)

```
hoardseeker/
├── project.godot          ← Godot 4 project file
├── src/
│   ├── core/              ← engine-agnostic game logic, no Godot dependencies
│   ├── content/           ← .tres resources (classes, abilities, etc.)
│   ├── systems/           ← gameplay systems (combat, dungeon, loot, etc.)
│   ├── networking/        ← duo mode and leaderboards
│   └── ui/                ← reads state, never writes
├── tests/                 ← headless tests (godot --headless --script tests/test_runner.gd)
├── assets/                ← art, audio, fonts
└── tools/                 ← dev-only scripts (balance dashboards, content editors)
```

## Architecture rules (from `../ARCHITECTURE.md`)

The five non-negotiable pillars:
1. **Determinism** — same seed + same inputs = same game, every time
2. **Pure data state** — game state is serializable Resources
3. **Command pattern** — all state changes go through Commands
4. **Event sourcing** — Commands are logged; current state is replayable
5. **N-player generality** — solo is duo with N=1

If you're about to violate one of these, stop and read `../ARCHITECTURE.md`.
