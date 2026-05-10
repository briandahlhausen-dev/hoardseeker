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

**Last updated**: 2026-05-10 (Sun) — Phase 1 architecture complete (week 1 close)

### Where we are
**Phase 1 architecture is done.** All foundational simulation primitives are in place and tested. The last 9 chunks (across Sat 2026-05-09 + Sun 2026-05-10) shipped every Phase-1 architectural piece per ROADMAP.md plus three follow-on additions (status effects, fixture migration, full-fight integration replay test).

`main` is at `ace69d6` (post chunk-9 merge). Working tree clean. CI green on every push since 2026-05-08.

### Test surface
**12 test files green** on `main`:
- `test_rng_determinism` (12 assertions, includes duplicate-safety regression tests)
- `test_game_state_serialization` (7)
- `test_attack_command` (11) — uses `find_actor` since chunk 2
- `test_command_processor` (7)
- `test_end_turn_command` (9)
- `test_monster_state` (10)
- `test_scripted_fight` (6 sub-tests, includes 50-seed determinism gate)
- `test_ability_def` (7) — covers fighter_slash, fighter_cleave, fighter_power_strike
- `test_use_ability_command` (18, includes multi-target coverage)
- `test_replay` (6 sub-tests, includes 30-seed sweep + full-fight integration)
- `test_monster_def` (6) — covers skeleton_warrior + spawn_monster_state contract
- `test_status_effect` (13) — covers stun + tick mechanics

### What architecture exists
- **Resources**: `GameState`, `PlayerState`, `MonsterState` (siblings, no CombatantState base — see DECISIONS), `AbilityDef`, `MonsterDef`, `StatusEffect`, `EventLog`, `RNGService` (duplicate-safe via persisted `rng_state`)
- **Commands**: `AttackCommand`, `EndTurnCommand` (incl. status-effect tick), `UseAbilityCommand` (single + multi-target via `target_ids`), `ApplyStatusEffectCommand`. Processed via `CommandProcessor`; logged in `EventLog`.
- **Content**: `fighter_slash.tres`, `fighter_cleave.tres`, `fighter_power_strike.tres`, `skeleton_warrior.tres`. All tests use the canonical defs via `MonsterDef.spawn_monster_state()` since chunk 9.
- **Replay**: `EventLog.replay()` round-trips against fresh initial state. Full-fight test composes all four concrete Commands.

### What's blocked (and what unblocks it)
Two design questions in [IDEAS.md](IDEAS.md) gate the remaining real architectural work:

1. **Monster turn flow** (2026-05-09 entry): when monster AI lands, do monster turns share the AP-refresh path (extending `EndTurnCommand` via `find_actor`), or use a separate mechanism? Three decision-driving questions in the entry.
2. **Status-effect / ability integration + stacking + save throws** (2026-05-10 entry): how does `AbilityDef` declare effects on hit? What happens when an effect is applied twice? Where does save-throw resolution live? All three unblock `fighter_shield_bash` (the next ability per CONTENT.md), so they likely land as a single follow-up design pass.

### What needs to happen first when we resume

1. **Re-read [IDEAS.md](IDEAS.md)** — both entries spell out the questions concretely with decision-driving questions for each.
2. **Engage the user on those questions** — don't pick the answers unilaterally; the user is the director per VIBE_CODING.md.
3. **Once unblocked**: skeleton AI (monster turn-end mechanism), then `fighter_shield_bash` as the first effect-applying ability.

If the user wants to keep moving without unblocking design, autonomous-friendly options:
- More monster defs (`skeleton_archer.tres`, `zombie.tres`) — pure-data adds, low value
- More ability defs that fit existing patterns — likewise

### Any blockers
- None on the project itself. Architecture is solid, CI is green.
- Two design calls in IDEAS.md gate the next architectural chunks; not "blockers" in the sense of broken state, but real ceilings on what the next chunk can be.

### Open admin items (tracked, not blocking)
- LLC formation pending (Month 1-2 per `VIBE_CODING.md`)
- Wacom tablet purchase pending (when art cleanup begins, ~Month 4-6)
- `Hoardseeker - Copy` folder on user's old Desktop — legacy, user to decide
- Pricing decision (~$14.99 vs $19.99) deferred to ~Month 14 per `DECISIONS.md`
- `RECAPS.md` 2026-05-08 entry still has "How I felt" blank; 2026-05-10 entry (this session-end commit) also has the line blank
- Dispatch / mobile push setup is partial (per TECH_DEBT.md). User has Stop-hook desktop sound working (Ring01.wav). Phone push still needs Dispatch via Claude Desktop → Cowork → Dispatch.
- Friday audit routine (`trig_014n5heywcVN3czDASX9bhgL`) — first run **2026-05-15 around 4pm ET**; will open a PR titled `Friday audit YYYY-MM-DD` against main.

### Working memory worth carrying over (not in code or commits)
- **`gh pr merge --delete-branch` fails from a worktree**. Workaround: `--delete-branch=false` + `git fetch --prune`. See TECH_DEBT.md.
- **Tests use `preload()` rather than `class_name`**. preload makes tests robust on fresh checkouts before the first `--import` pass.
- **Run tests locally via `bash hoardseeker/tests/run.sh`** — wraps the `--import` step.
- **The user is non-technical and only interacts via Claude.** They don't open VS Code manually, they don't run terminal commands themselves. See `user_workflow_claude_only.md` memory.
- **The user wants Claude-time estimates, not human-dev hours.** See `feedback_estimates_use_claude_time.md` memory.
- **Send `PushNotification` at end of every response that hands control back.** See `user_notification_sound.md` memory.
- **EventLog.replay does NOT re-append commands/events to the replayed state's log** — the log is the input, not the output. Asserting log-size equality post-replay is a false-positive test pattern. Documented in `event_log.gd`.
- **5-min cache TTL trap**: when polling for slow operations, prefer ~270s waits or 1200-1800s waits. 300s is the worst-of-both option.

### Branch / files involved
- `main` is current at `ace69d6`. All chunk branches merged.
- This session-end commit lands on `session-end-2026-05-10` and gets merged to main as part of session close.
- All companion files in place: `RECAPS.md`, `TECH_DEBT.md`, `IDEAS.md`, `SESSION_PROTOCOL.md`.
