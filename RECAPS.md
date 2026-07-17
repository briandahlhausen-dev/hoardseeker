# RECAPS.md — Hoardseeker

> Friday-or-end-of-week 5-line recap. Append-only.
> Per `RESILIENCE.md`: bad weeks count. Honest entries beat polished ones.
> Template + protocol live in `SESSION_PROTOCOL.md`.

---

## 2026-05-08 (Fri) — Week 1 (project realignment + Phase 0 complete)

- **What shipped** (12 merge commits to `main`, all pushed to GitHub):
  - **Bootstrap budget realignment**: 10 design docs updated to reflect <$5k production model. AI-generated stylized illustration with hand cleanup, royalty-free music + one commissioned theme, text-only narration. Launch scope locked at 12 classes / 2 biomes (Crypt + Sunken Halls); biomes 3-4 ship as free post-launch updates.
  - **`SESSION_PROTOCOL.md` installed**: cross-session discipline doc with start/mid/end rituals, document hierarchy, companion-file templates.
  - **`LICENSE` (all rights reserved) and `README.md`** added.
  - **Tooling foundation**: Godot 4.6.2 invokable as `godot` command (with note: must use `_console.exe` variant for Git Bash), GitHub remote live at `briandahlhausen-dev/hoardseeker`, OneDrive auto-backup confirmed already running via Desktop redirect, gh CLI installed.
  - **Phase 0 (project setup) — COMPLETE**:
    - Godot 4.6.2 project initialized (`hoardseeker/project.godot`)
    - Full directory tree per `ARCHITECTURE.md` (`src/{core,content/*,systems/*,networking,ui/*}`, `tests/`, `assets/{art,audio,fonts}`, `tools/`)
    - `RNGService` scaffolded + 8 determinism assertions passing
    - `GameState` + `PlayerState` + `DungeonState` + `EncounterState` + `EventLog` + `Command` base + `GameEvent` scaffolded
    - `test_game_state_serialization.gd` with 7 assertions covering deep-duplicate independence, EventLog append, and other foundational contracts
    - GitHub Actions CI: headless tests run on every push to `main` and on PRs; Godot binary cached between runs
    - 2 test files, 15 total assertions, all green
- **What got hard**: Original project docs assumed contractor-driven production (~$10-50k); had to honestly recompute timelines using Claude-assisted authoring rates after user pushback. Embedded git repo inside `hoardseeker/` subfolder + duplicate docs created friction at session start. Godot's class registry isn't built until `--import` runs once, so cross-class typed `@export`s caused confusing parse errors in the GameState test until I figured out the workaround (now documented in `TECH_DEBT.md`).
- **What surprised me**:
  - User pushed back on "cutting 6 classes saves 4-5 months" claim, forcing a more rigorous Claude-time analysis that landed at "1-2 months calendar saved." That pushback was high-value; led to the 12-class launch decision.
  - OneDrive Desktop redirect was already auto-backing-up the project; user thought no backup was set up.
  - The Godot GUI exe silently hangs when `--headless --script` is invoked from Git Bash — must use the `_console.exe` variant. Caught early; would have been a horrible debugging session if hit later.
  - Phase 0 went much faster than expected. Going from "no Godot project at all" to "passing tests in CI" took about 4 hours of work.
- **How I felt**: _(user fills in)_
- **What's next week**:
  - Phase 1 (combat core, weeks 2-5 per `ROADMAP.md`): concrete `AttackCommand`, `UseAbilityCommand`, `EndTurnCommand`; `CommandProcessor`; turn order math; first ability + first monster (skeleton) with simple AI; scripted-fight headless test.
  - Possibly: `gh auth login` for automation (so I can verify CI status without bothering user).
  - LLC formation as a low-engagement parallel administrative task (Month 1-2 priority per `VIBE_CODING.md`).

---

## 2026-05-10 (Sun) — Week 1 close (Phase 1 architecture complete)

- **What shipped** (9 chunks, 18 merge commits to `main` over Friday + Saturday + Sunday):
  - **Phase 1 architectural primitives**, all with unit + integration tests:
    - `AttackCommand` (raw-attack primitive, chunk 2 PvP-style → chunk 5 multi-target via UseAbilityCommand)
    - `EndTurnCommand` (turn rotation + AP refresh + chunk-8 status-effect tick)
    - `CommandProcessor` (the only state mutator; logical timestamp from event_log size)
    - `UseAbilityCommand` (single + multi-target via target_ids list)
    - `ApplyStatusEffectCommand`
    - `GameState`, `PlayerState`, `MonsterState` (+ `find_actor()` returning untyped Resource — sibling resources, no CombatantState base class)
    - `RNGService` redesigned mid-week to be duplicate-safe via persisted `rng_state` (caught real bug while writing replay test)
    - `EventLog` with deterministic `replay()` round-tripping the full pipeline
    - `AbilityDef` data class + `target_count` for multi-target → `fighter_slash`, `fighter_cleave`, `fighter_power_strike` `.tres`
    - `MonsterDef` data class + `spawn_monster_state()` factory → `skeleton_warrior.tres` + chunk-9 fixture migration across 4 test files
    - `StatusEffect` data class + dispatch-on-effect_id ticking → stun (other effects are stub branches)
  - **Test surface**: 12 test files green on every push since 2026-05-08. Coverage includes 50-seed determinism gate, 30-seed replay round-trip, full-fight integration test composing all four concrete Commands through replay.
  - **Captures discipline held**: every chunk that surfaced a real architectural call shipped its own DECISIONS entry in the same commit. IDEAS.md picked up two deferred-design entries (monster turn flow; status effect ability integration / stacking / save throws).
- **What got hard**:
  - The replay test surfaced a non-obvious RNGService bug — `Resource.duplicate(true)` shallow-copies the non-`@export`'d `_rng` field, so original and copy shared a single PRNG. Caught it via 30-line diagnostic. Considered call-counter-based reconstruction first; rejected (Godot's `randi_range` uses rejection sampling so call counts can't reproduce state). Final fix: persist `rng_state` directly, build fresh PRNG per call.
  - `gh pr merge --delete-branch` from a worktree fails because it tries to switch the local checkout to `main`, which is held by the parent worktree. Documented in TECH_DEBT.md with the `--delete-branch=false` + `git fetch --prune` workaround.
  - Sound-alert hook: first attempt used `SystemSounds.Asterisk.Play()` which silently does nothing if Windows sound scheme has Asterisk set to "(None)". Switched to `SoundPlayer.PlaySync()` on a real `.wav`. Took two iterations to land on Ring01.wav.
- **What surprised me**:
  - The data-driven content rule (`.tres` not code) actually held under pressure. `fighter_power_strike` shipped as pure-data — zero code change. `fighter_cleave` did force a small refactor (target_count on def + target_ids on command), but that's the right kind of pressure: discover the architectural extension at the smallest second-ability that demands it, not later when 5 single-target abilities have hardened the pattern.
  - Status effects came out smaller than expected. Generic `StatusEffect` resource + `match` dispatch in `EndTurnCommand._tick_status_effects()` is simpler than a class hierarchy and has clear revisit thresholds.
  - The full-fight integration test (chunk 6) caught my own snapshot mistake — I tried to compare `event_log.commands.size()` post-replay and got correctly-failing tests. Realized `EventLog.replay` doesn't re-append to the new state's log (the log is the input, not the output). Captured the clarification in `event_log.gd`'s docstring.
- **How I felt**: _(user fills in)_
- **What's next week**:
  - **Resolve the IDEAS.md design questions** (monster turn flow + status-effect / ability integration / stacking / save throws). Both block real architectural work; both are short conversations.
  - Once unblocked: skeleton AI (monster turn-end mechanism), then `fighter_shield_bash` as the first ability that applies an effect on hit.
  - More content authoring as desired (more abilities via `.tres`, more monster defs).
  - Phase 2 prep starts when architecture extensions slow down — combat scene UI, dice-roll animation, the centerpiece dice-feel polish per `ROADMAP.md` Phase 2.

---

## 2026-07-17 (Fri) — Week 10 audit (68-day gap; 10 consecutive unreviewed audit PRs)

- **What shipped**: Nothing. Zero game commits since Phase L on 2026-05-10 — 68 days ago. Phases A–L (monster AI, damage types + resistances, bleed, execute mechanic, effect application, save throws, fighter_shield_bash) all shipped on May 10 and are captured in DECISIONS.md and on the merged PR branches. This is the 10th consecutive Friday audit with the same finding.
- **What got hard**: The silence itself. The game simulation is completely intact — CI green, 13+ test files passing, architecture solid. What's absent is momentum. That's a human problem, not a code problem, and it has a human solution: show up when you're ready.
- **What surprised me**: The audit routine ran faithfully for 10 weeks with no human session. That's the system doing exactly what it was designed to do — hold the thread so you don't have to keep it in your head.
- **How I felt**: _(user fills in)_
- **What's next week**: Whenever you're ready: (1) read issues #24 and #26, close them when you know where you stand; (2) batch-close old audit PRs (#21–#31) and merge the most recent one; (3) split `use_ability_command.gd` before Phase 2 adds more surface area; (4) start Phase 2 — combat scene UI + dice-roll animation. The simulation is solid. Re-entry cost is low.
