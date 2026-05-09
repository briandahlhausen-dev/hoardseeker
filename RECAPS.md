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
