# TECH_DEBT.md — Hoardseeker

> Append-only log of known issues, fix-laters, and architectural concerns.
> Severity tags: BLOCKER (fix this week), HIGH (fix this phase), MEDIUM (fix before launch), LOW (nice to fix).
> Template + protocol live in `SESSION_PROTOCOL.md`.

---

## 2026-05-09 — `gh pr merge --delete-branch` fails when run from a worktree [LOW]

**Where**: PR-merge workflow when run from inside any git worktree (e.g., `.claude/worktrees/intelligent-yonath-9e8856`). The parent repo's main checkout is held by the parent worktree; the merge command's local cleanup tries to switch to it and fails.

**What's wrong**: `gh pr merge <N> --merge --delete-branch` performs the merge remotely via the GitHub API, then tries to clean up locally by switching to `main` and running `git branch -d` on the merged branch. From inside a worktree this fails:

```
failed to run git: fatal: 'main' is already used by worktree at 'C:/Users/brian/Desktop/Hoardseeker'
```

The remote merge succeeds normally — the merge commit lands, the remote branch is deleted, the PR closes. Only the local branch cleanup step throws this error. First-time encounter looks alarming; the actual blast radius is zero.

**Workaround (verified)**:
1. Run the merge with `--delete-branch=false` (or just drop `--delete-branch`) when working from a worktree, then delete the remote branch separately via the GitHub UI or `gh api -X DELETE`.
2. Alternative: drop the flag entirely, let the merge succeed, then run `git fetch --prune` to sync the remote-side branch deletion that GitHub's "Delete branch on merge" repo setting handles.
3. Alternative: do PR merges from the parent repo (not a worktree) when convenient.

**Why we deferred the fix**: Hit during the chunk 1 merge. Workaround is one extra step and reliable. Not worth a wrapper script yet.

**Cost of not fixing**: Every PR merge from a worktree throws this error. Easy to misread as a fatal merge failure on first encounter, but the merge has actually succeeded. New contributors (or future-Claude in a fresh session) will trip on this once and then know.

**Suggested fix when revisited**: A small wrapper around `gh pr merge` that detects whether the cwd is inside a worktree (`git rev-parse --is-inside-work-tree` + checking `git worktree list`) and adapts the flags. Or: file a bug against `gh` to handle the multi-worktree case gracefully.

---

## 2026-05-09 — Dispatch / mobile push setup is partial [LOW]

**Where**: User-side configuration on the local machine being handed off FROM (and pending on whatever new machine takes over).

**What's wrong**: User installed the Claude mobile app and signed in, then tried `/config` to enable "Push when Claude decides" but got "/config isn't available in this environment" — they're not in the CLI variant. The right path is **Dispatch** (Claude Desktop → Cowork → Dispatch in left sidebar → Get started → enable computer-wake → finish setup), but the user pivoted to handing off to a different machine before completing it. Result: `PushNotification` calls still report "Mobile push not sent (Remote Control inactive)" — the user gets desktop notifications but not phone notifications.

**Why we deferred the fix**: Machine handoff happened mid-setup. The new machine will need its own Dispatch (or Remote Control) configuration anyway, so finishing the setup on the old machine would have been wasted effort.

**Cost of not fixing**: Lower-quality experience during long autonomous Claude work — the user has to actively check progress instead of getting pinged on phone. Not a project-blocker; the project ships fine without phone notifications.

**Suggested fix when revisited**: On the new machine, install Claude Desktop (claude.com/download), navigate Cowork → Dispatch → Get started → enable computer wake → finish setup. Test with a `PushNotification` call from Claude — phone should buzz. Once working, the existing autonomous-work pattern gets phone-based observability.

---

## 2026-05-08 — Local tests require `godot --headless --import` on fresh checkout [LOW]

**Where**: `hoardseeker/` test workflow.

**What's wrong**: When the project is freshly checked out (no `.godot/` cache yet), running `godot --headless --script tests/test_runner.gd` produces parse errors like `Could not resolve external class member "players"` for any test that references a `class_name`'d resource with cross-class typed exports (e.g. `Array[PlayerState]` inside `GameState`). The class registry hasn't been built yet, so Godot can't resolve the cross-references at parse time. Tests using only `preload()`-with-no-cross-refs (like `test_rng_determinism.gd`) work fine; tests touching `GameState` or other multi-class structures don't.

**Workaround**: Run `godot --headless --import` once first, before any `--script` invocation. This builds `.godot/global_script_class_cache.cfg` and the registry; subsequent test runs work.

**Why we deferred the fix**: CI handles itself (the workflow already does `--import` before running tests). This only affects local development on a fresh clone, and only for the first run.

**Cost of not fixing**: A future Claude session or fresh contributor running tests on a clean checkout will see confusing parse errors and waste 10-20 minutes diagnosing. Documented here so the answer is one search away.

**Suggested fix when revisited**: Add a `hoardseeker/tests/run.sh` wrapper that does `godot --headless --import || true && godot --headless --script tests/test_runner.gd`. Or have `test_runner.gd` detect when the class cache is missing and print a helpful error pointing at the workaround.

---

## 2026-05-08 — Godot wrapper has two fragility points [LOW]

**Where**: `C:\Users\brian\bin\godot` (bash wrapper) and `C:\Users\brian\bin\godot.bat` (cmd wrapper).

**What's wrong**:
1. **Hardcoded path**: Both wrappers reference `C:\Users\brian\Downloads\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe` — the original download location. If the user moves the Godot folder out of Downloads (e.g., during routine cleanup) or updates Godot to a newer version, the wrappers will silently break: `godot --version` fails with "file not found."
2. **Must use the `_console.exe` variant, not the GUI `.exe`**: The wrappers were initially set to point at the GUI exe (`Godot_v4.6.2-stable_win64.exe`). When run from Git Bash with `--headless --script`, the GUI version produced no stdout output (process hung silently while running). The console subsystem variant (`Godot_v4.6.2-stable_win64_console.exe`) is required for any test/CI usage. If a future "cleanup" reverts to the GUI exe, all headless tests will silently hang again. **Update**: This was caught and fixed during the first test-runner integration on 2026-05-08.

**Why we deferred the fix**: Tooling-check session prioritized getting `godot` invokable as a command. The wrapper works today; cleanup of the install location and a more robust resolver is a separate concern.

**Cost of not fixing**: Minor user friction. If point 1 breaks, the failure is loud and easy to diagnose. If point 2 regresses, the failure is silent — tests hang with no output. Not launch-blocking but the silent-hang case is the bigger trap.

**Suggested fix when revisited**: Move Godot install to a stable location (e.g., `C:\Users\brian\bin\Godot\` or `C:\Tools\Godot\`), update wrappers to point there. Add a `GODOT_PATH` env var read by the wrappers as a fallback. Always use the `_console.exe` variant in the wrapper — never the GUI exe — and add a comment in the wrapper explaining why.
