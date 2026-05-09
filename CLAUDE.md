# CLAUDE.md — Hoardseeker

> **You are working on Hoardseeker, a D&D-inspired roguelike deckbuilder built in Godot 4.**
> This file is your index. Read it on every session before doing anything else.

---

## Quick context

- **Game**: Hoardseeker
- **Tagline**: *Roll the dice. Raid the dungeon. Don't die alone.*
- **Genre**: Turn-based roguelike with D&D-inspired combat, solo + duo co-op, ranked leaderboards
- **Engine**: Godot 4 (GDScript)
- **Target platforms**: Steam (PC) at launch; consoles via publisher post-launch
- **Solo developer + AI-assisted (Claude Code)**
- **Target launch**: 16-22 months from project start

## Read these in order, every session

1. **`VIBE_CODING.md`** — **READ FIRST.** The user is non-technical. This file defines how we work together: discipline rules, audit cadence, modularity enforcement, what irreversible actions require confirmation. Violating these rules causes project failure.
2. **`RESILIENCE.md`** — **READ SECOND.** Burnout and project abandonment are the dominant failure modes for solo devs. This file defines the systems that prevent them. Pay special attention to the early warning signs and the crisis protocol — recognizing them in the user's messages is part of your job.
3. **`VISION.md`** — what we're building and why. The north star.
4. **`ARCHITECTURE.md`** — how the code is structured. **Read this before writing any code.** Especially the determinism, command pattern, and event sourcing sections.
5. **`VERTICAL_SLICE.md`** — what we're building *first*. Months 1-4 scope. This is your active work plan.
6. **`FULL_VISION.md`** — the complete design (everything we'll eventually build). Reference for context, not a checklist.
7. **`CONTENT.md`** — classes, races, subclasses, abilities, artifacts, monsters. Data-driven content lives here.
8. **`MULTIPLAYER.md`** — duo mode design, networking architecture, ranked system. Not implemented in vertical slice.
9. **`ROADMAP.md`** — phased plan from prototype to launch.

## Hard rules — never violate these

These are architectural constants. Breaking them creates massive rework debt later.

1. **Determinism is sacred.** All RNG goes through `RNGService` with a per-run seed. No `randf()`, no `Time.get_ticks_msec()` in game logic. Ever.
2. **Game state is pure data.** State lives in `Resource` classes (`.tres`). Renderers read state but never own it.
3. **Actions are commands.** No direct state mutations. Every action is a `Command` object processed by `GameStateController`. This enables networking, replays, and undo.
4. **Content is data, not code.** Classes, races, subclasses, abilities, artifacts, monsters all live as `.tres` resources. Adding a new spell should never require code changes.
5. **Solo is duo with N=1.** Build all systems to handle a list of players from day one. Solo is not a special case.
6. **Test the simulation, not the renderer.** Game logic must be playable headless. If it requires a visual to test, it's wrong.
7. **The user is non-technical.** Explain plans in plain English before coding. Never assume engineering knowledge. Always propose before building. Always confirm before irreversible actions.
8. **Modularity is sacred.** Every system must pass the fresh-Claude test (see VIBE_CODING.md). If you can't add a feature to a system without modifying other systems, the architecture is wrong. Stop and refactor.
9. **The 150-line rule.** If a `.gd` file grows past ~150 lines, propose splitting it.
10. **User wellbeing comes before the project.** Watch for the early warning signs in RESILIENCE.md. If the user shows signs of burnout, fatigue, or crisis, do not push them to keep working. Suggest taking a break, reference the relevant prevention systems, and remind them the project will survive a pause.

## Coding style

- GDScript, not C#. Faster iteration, simpler debugging, all the perf we need.
- `snake_case` for variables and functions, `PascalCase` for classes.
- Static typing everywhere: `var hp: int = 10`, not `var hp = 10`.
- Resource-based architecture. Prefer `class_name` exports over `preload()` chains.
- Comments explain *why*, not *what*. Code should be self-documenting otherwise.
- One responsibility per script. If a node script has more than ~150 lines, split it.

## When you start a session

1. Read `VIBE_CODING.md` first, then `CLAUDE.md`, `VISION.md`, `ARCHITECTURE.md`, and `VERTICAL_SLICE.md`.
2. Check `ROADMAP.md` for current phase.
3. Confirm what we're working on with the user before writing code. **Always propose the plan in plain English first. Wait for approval.**
4. Work on a branch, never on `main`.
5. Run existing tests (`godot --headless --script test_runner.gd`) before changes.
6. After substantial changes, run the test suite again. Don't ship if anything fails.
7. Before any irreversible action (file deletion, force push, branch reset, paid recording session, Steam build submission), pause and confirm with the user.

## When you finish a session

1. Update relevant docs if the design changed.
2. Note unresolved decisions or new tech debt in `DECISIONS.md` and `TECH_DEBT.md` (create the latter when first needed).
3. Commit with a message that explains the *intent*, not just the diff.
4. Push to the branch. Confirm with the user before merging to `main`.
5. Run a quick modularity check: did the change touch only the system it should have? If it spread, flag it.

## What we are NOT building

To prevent scope creep, here's the explicit "no" list:

- ❌ 4-player co-op (duo only — design lives or dies on the duo experience)
- ❌ Real-time combat (turn-based, always)
- ❌ Open world / hubs between runs (you're in the dungeon or you're dead)
- ❌ Crafting systems (curated artifacts only)
- ❌ Player housing / cosmetic shops (not until far post-launch, if ever)
- ❌ Mobile or web ports at launch (PC only)
- ❌ Voice chat (text + ping system only — sparse DM narration is the only voice in the game)

Adding any of these requires explicit user approval and a documented design discussion.

## Audit cadence (full details in VIBE_CODING.md)

- **Every commit**: lint passes, tests pass, new code has tests, no banned API calls.
- **Every Friday**: 15-min health check (test suite green, file size review, tech debt catalog).
- **Every month**: dependency audit, unused code audit, performance audit, build size audit.
- **Every 3 months**: fresh-Claude modularity test. If a system fails the test, refactor before adding more features.
- **Pre-launch (months 16-17)**: comprehensive security, performance, localization, save/load, and polish audit.

If an audit fails, **fixing it takes priority over adding new features**. No exceptions.

## On asset creation

Per VIBE_CODING.md, AI-generated content (Midjourney, Suno, ElevenLabs, etc.) is acceptable for *prototyping and references only*. Final shipped assets must be human-created or human-cleaned with explicit licensing. When the user asks for asset work:

- For prototypes / dev builds / mood boards: AI generation is fine.
- For demo or launch builds: ask whether assets are placeholder or final. Refuse to commit AI-generated content as final without confirming the user understands the legal/policy implications.

## Proactively offering tools and connections

The user is non-technical and may not know what tools or services exist. When you encounter a need that has a known tool/service solution (asset pipelines, version control improvements, MCP integrations, automation), proactively mention it — but defer to the user's decision and budget. Never auto-subscribe to anything or assume a tool is available.
