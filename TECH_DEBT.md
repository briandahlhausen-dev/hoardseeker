# TECH_DEBT.md — Hoardseeker

> Append-only log of known issues, fix-laters, and architectural concerns.
> Severity tags: BLOCKER (fix this week), HIGH (fix this phase), MEDIUM (fix before launch), LOW (nice to fix).
> Template + protocol live in `SESSION_PROTOCOL.md`.

---

## 2026-05-08 — Godot wrapper hardcodes path to Downloads folder [LOW]

**Where**: `C:\Users\brian\bin\godot` (bash wrapper) and `C:\Users\brian\bin\godot.bat` (cmd wrapper).

**What's wrong**: Both wrappers reference `C:\Users\brian\Downloads\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64.exe` — the original download location. If the user moves the Godot folder out of Downloads (e.g., during routine cleanup) or updates Godot to a newer version, the wrappers will silently break: `godot --version` fails with "file not found."

**Why we deferred the fix**: Tooling-check session prioritized getting `godot` invokable as a command. The wrapper works today; cleanup of the install location is a separate concern.

**Cost of not fixing**: Minor user friction. If the wrapper breaks, the failure is loud and easy to diagnose. Worst case: 10 minutes to re-edit the path or move the install. Not launch-blocking.

**Suggested fix when revisited**: Move Godot install to a stable location (e.g., `C:\Users\brian\bin\Godot\` or `C:\Tools\Godot\`), update wrappers to point there. Or add a small `which`-style fallback that checks multiple known locations. Or use a `GODOT_PATH` env var read by the wrappers.
