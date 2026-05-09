# TECH_DEBT.md — Hoardseeker

> Append-only log of known issues, fix-laters, and architectural concerns.
> Severity tags: BLOCKER (fix this week), HIGH (fix this phase), MEDIUM (fix before launch), LOW (nice to fix).
> Template + protocol live in `SESSION_PROTOCOL.md`.

---

## 2026-05-08 — Godot wrapper has two fragility points [LOW]

**Where**: `C:\Users\brian\bin\godot` (bash wrapper) and `C:\Users\brian\bin\godot.bat` (cmd wrapper).

**What's wrong**:
1. **Hardcoded path**: Both wrappers reference `C:\Users\brian\Downloads\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe` — the original download location. If the user moves the Godot folder out of Downloads (e.g., during routine cleanup) or updates Godot to a newer version, the wrappers will silently break: `godot --version` fails with "file not found."
2. **Must use the `_console.exe` variant, not the GUI `.exe`**: The wrappers were initially set to point at the GUI exe (`Godot_v4.6.2-stable_win64.exe`). When run from Git Bash with `--headless --script`, the GUI version produced no stdout output (process hung silently while running). The console subsystem variant (`Godot_v4.6.2-stable_win64_console.exe`) is required for any test/CI usage. If a future "cleanup" reverts to the GUI exe, all headless tests will silently hang again. **Update**: This was caught and fixed during the first test-runner integration on 2026-05-08.

**Why we deferred the fix**: Tooling-check session prioritized getting `godot` invokable as a command. The wrapper works today; cleanup of the install location and a more robust resolver is a separate concern.

**Cost of not fixing**: Minor user friction. If point 1 breaks, the failure is loud and easy to diagnose. If point 2 regresses, the failure is silent — tests hang with no output. Not launch-blocking but the silent-hang case is the bigger trap.

**Suggested fix when revisited**: Move Godot install to a stable location (e.g., `C:\Users\brian\bin\Godot\` or `C:\Tools\Godot\`), update wrappers to point there. Add a `GODOT_PATH` env var read by the wrappers as a fallback. Always use the `_console.exe` variant in the wrapper — never the GUI exe — and add a comment in the wrapper explaining why.
