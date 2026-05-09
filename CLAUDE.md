# CLAUDE.md — Hoardseeker

> **You are working on Hoardseeker, a D&D-inspired roguelike deckbuilder built in Godot 4.**
> This file is your index. Read it on every session before doing anything else.

---

## Quick context

- **Game**: Hoardseeker
- **Tagline**: *Roll the dice. Raid the dungeon. Don't die alone.*
- **Genre**: Turn-based roguelike with D&D-inspired combat, solo + duo co-op, ranked leaderboards
- **Engine**: Godot 4 (GDScript)
- **Target platforms**: Steam (PC) at launch; console ports only via publisher partnership if available (deferred under bootstrap mode otherwise)
- **Solo developer + AI-assisted (Claude Code)**
- **Target launch**: 18-20 months from project start (with buffer to 22)
- **Mode**: **Bootstrap (<$5k total budget).** No contracted illustrator, composer, or voice actor at launch. Production model is AI generation + hand cleanup for art, royalty-free + one ~$300 commissioned theme for music, text-only narration. See `DECISIONS.md` (entries dated 2026-05-08) for the full realignment.
- **Launch scope**: 12 classes, 2 biomes (Crypt + Sunken Halls). Biomes 3-4 ship as free post-launch updates over year 1-2.

## Read these in order, every session

1. **`VIBE_CODING.md`** — **READ FIRST.** The user is non-technical. This file defines how we work together: discipline rules, audit cadence, modularity enforcement, what irreversible actions require confirmation. Violating these rules causes project failure.
2. **`RESILIENCE.md`** — **READ SECOND.** Burnout and project abandonment are the dominant failure modes for solo devs. This file defines the systems that prevent them. Pay special attention to the early warning signs and the crisis protocol — recognizing them in the user's messages is part of your job.
3. **`SESSION_PROTOCOL.md`** — **READ THIRD.** The discipline that keeps long-term memory of decisions intact across an 18-22 month project. Defines the session-start, mid-session, and session-end rituals plus the document hierarchy. The "Currently in flight" section at the bottom of this file (CLAUDE.md) is where the cross-session pickup state lives.
4. **`DECISIONS.md`** — read the most recent entries and the "Open questions" section. This is the canonical decision log. Anything we decided lives here.
5. **`VISION.md`** — what we're building and why. The north star.
6. **`ARCHITECTURE.md`** — how the code is structured. **Read this before writing any code.** Especially the determinism, command pattern, and event sourcing sections.
7. **`VERTICAL_SLICE.md`** — what we're building *first*. Months 1-4 scope. This is your active work plan.
8. **`FULL_VISION.md`** — the complete design (everything we'll eventually build). Reference for context, not a checklist.
9. **`CONTENT.md`** — classes, races, subclasses, abilities, artifacts, monsters. Data-driven content lives here.
10. **`MULTIPLAYER.md`** — duo mode design, networking architecture, ranked system. Not implemented in vertical slice.
11. **`ROADMAP.md`** — phased plan from prototype to launch.
12. **`RECAPS.md`, `IDEAS.md`, `TECH_DEBT.md`** (if they exist) — recent week's recap, deferred ideas, known issues. Created lazily when first needed; templates in `SESSION_PROTOCOL.md`.

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

The full session-start ritual is in `SESSION_PROTOCOL.md`. Summary:

1. Read `VIBE_CODING.md`, `RESILIENCE.md`, `SESSION_PROTOCOL.md`, then this file.
2. Read recent entries + open questions in `DECISIONS.md`.
3. `git log --oneline -20` to see what was last worked on.
4. Read the "Currently in flight" section at the bottom of this file — that's the cross-session pickup state.
5. Read the most recent entry in `RECAPS.md` if it exists.
6. Skim `TECH_DEBT.md` for anything BLOCKER or HIGH if it exists.
7. Check `ROADMAP.md` for current phase.
8. **State your understanding of current project state to the user and confirm what we're tackling today.** Catches drift between actual state and your read of it.
9. Confirm what we're working on with the user before writing code. **Always propose the plan in plain English first. Wait for approval.**
10. Work on a branch, never on `main`.
11. Run existing tests (`godot --headless --script test_runner.gd`) before changes.
12. After substantial changes, run the test suite again. Don't ship if anything fails.
13. Before any irreversible action (file deletion, force push, branch reset, paid recording session, Steam build submission), pause and confirm with the user.

## When you finish a session

Full ritual is in `SESSION_PROTOCOL.md`. Summary:

1. Confirm new decisions are in `DECISIONS.md` (not just promised — actually written down).
2. Confirm new ideas in `IDEAS.md` and new tech debt in `TECH_DEBT.md` (create either when first needed; templates in `SESSION_PROTOCOL.md`).
3. Commit with a message that explains the *intent*, not just the diff.
4. Push to the branch. **Confirm with the user before merging to `main`.**
5. Run a quick modularity check: did the change touch only the system it should have? If it spread, flag it.
6. **Update the "Currently in flight" section at the bottom of this file.** Empty it if nothing's in flight; otherwise leave the next session a clean handoff.
7. If end-of-week, append a 5-line entry to `RECAPS.md`.

## What we are NOT building

To prevent scope creep, here's the explicit "no" list:

- ❌ 4-player co-op (duo only — design lives or dies on the duo experience)
- ❌ Real-time combat (turn-based, always)
- ❌ Open world / hubs between runs (you're in the dungeon or you're dead)
- ❌ Crafting systems (curated artifacts only)
- ❌ Player housing / cosmetic shops (not until far post-launch, if ever)
- ❌ Mobile or web ports at launch (PC only)
- ❌ Voice chat (text + ping system only)
- ❌ Voice acting of any kind (narration is text-only forever — see `DECISIONS.md` for the bootstrap-mode decision)

Adding any of these requires explicit user approval and a documented design discussion.

## Audit cadence (full details in VIBE_CODING.md)

- **Every commit**: lint passes, tests pass, new code has tests, no banned API calls.
- **Every Friday**: 15-min health check (test suite green, file size review, tech debt catalog).
- **Every month**: dependency audit, unused code audit, performance audit, build size audit.
- **Every 3 months**: fresh-Claude modularity test. If a system fails the test, refactor before adding more features.
- **Pre-launch (months 16-17)**: comprehensive security, performance, localization, save/load, and polish audit.

If an audit fails, **fixing it takes priority over adding new features**. No exceptions.

## On asset creation

The AI-content rule was revised for bootstrap mode on 2026-05-08. See `VIBE_CODING.md` ("The AI-content rule") and `DECISIONS.md` ("Revised AI-content rule") for the full rule. Summary:

- **AI-generated visual art is permitted in shipped product** if and only if (1) every asset has substantial hand cleanup with documented process, (2) Steam disclosure is accurate and prominent, and (3) a public "How this art was made" statement is maintained. Cleanup discipline is what determines quality.
- **AI-generated music is OFF-LIMITS in shipped product.** Royalty-free curation + one ~$300 commissioned signature theme is the path.
- **AI-generated voice is OFF-LIMITS in shipped product.** Narration is text-only forever.
- **AI for prototyping** (Midjourney, Suno, ElevenLabs) is fine internally — never shipped.

When the user asks for asset work:
- Prototypes / dev builds / mood boards: AI generation is fine, no cleanup required.
- Demo or launch builds: art must go through the full cleanup workflow per `VIBE_CODING.md`. Do not commit raw AI generations as final shipped assets. Music and voice paths are bounded by the rules above (royalty-free + commissioned theme; text-only narration).

## Proactively offering tools and connections

The user is non-technical and may not know what tools or services exist. When you encounter a need that has a known tool/service solution (asset pipelines, version control improvements, MCP integrations, automation), proactively mention it — but defer to the user's decision and budget. Never auto-subscribe to anything or assume a tool is available.

---

## Currently in flight

> Updated at end of every session. Empty if nothing in flight. Read first thing on session start.

**Last updated**: 2026-05-08 (end of session — full week-1 wrap)

- **What we were working on**: Project realignment + foundation. Three things in sequence: (1) bootstrap budget realignment across 10 design docs, (2) installed `SESSION_PROTOCOL.md` for cross-session discipline + LICENSE + README, (3) tooling check + GitHub remote setup.
- **Where we paused**: Clean session end. Everything merged to `main` and pushed to `origin/main` (https://github.com/briandahlhausen-dev/hoardseeker). Working tree clean. Project is now properly tracked, backed up to GitHub + OneDrive, and Godot is invokable as `godot` command.
- **What needs to happen first when we resume**:
  1. **Phase 0 project scaffold** (recommended, ~2-3 hours focused) — Godot folder structure in `hoardseeker/` per `ARCHITECTURE.md`, base classes (`RNGService`, `GameState`, `Command`), test runner, first determinism test. This is the natural next milestone.
  2. **LLC formation** (optional, parallel admin task) — Month 1-2 priority per `VIBE_CODING.md`. Low-engagement, can be done alongside coding work.
  3. **Style guide locking** (premature; defer) — Month 4-6 work per the decision calendar.
- **Any blockers**: None. Ready to pick up wherever the user wants.
- **Open admin items** (not blocking, just tracked):
  - LLC formation pending (Month 1-2)
  - Wacom tablet purchase pending (when art cleanup begins, ~Month 4-6)
  - Hoardseeker - Copy folder on Desktop (legacy, user to decide whether to archive/delete)
  - Pricing decision (~$14.99 vs $19.99) deferred to ~Month 14 per DECISIONS.md
- **Branch / files involved**: `main` is current and pushed. All session branches merged and deleted. Companion files `RECAPS.md` and `TECH_DEBT.md` now exist. `IDEAS.md` not yet created (no entries yet).
- **Ritual reminder**: User's `RECAPS.md` entry for 2026-05-08 has the "How I felt" line left blank. They can fill it in any time by telling Claude what to add.
