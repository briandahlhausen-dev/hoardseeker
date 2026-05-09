# SESSION_PROTOCOL.md — Hoardseeker

> The discipline that keeps Claude's long-term memory of project decisions solid across an 18-22 month project.
> Read at the start of every session, before doing anything else.

---

## Why this file exists

Solo dev + AI-assisted = high risk of decisions made in conversation but never written down. Across 18-22 months that decay compounds. By month 12, Claude is working from stale assumptions and the user can't remember what was agreed in month 4. **Lost decisions cost more than any other failure mode in this project's operating model.**

This file is the discipline that prevents that loss. Three rituals (start / mid-session / end) plus a clear document hierarchy. If we follow it, future-Claude can reconstruct the project's full reasoning by reading the docs alone — no need to remember anything from prior conversations.

---

## The session loop

### 1. Session start ritual (5-10 min, every session)

Claude does this every session. Don't skip. Don't compress.

1. **Read `CLAUDE.md`** — orient on project state, mode, recent decisions (Quick context section is the headline).
2. **Read `VIBE_CODING.md` and `RESILIENCE.md`** — refresh on discipline rules and warning signs.
3. **`git log --oneline -20`** — see what was last worked on. Recent commits are the freshest record of activity.
4. **Read the last entry in `RECAPS.md`** (if exists) — what shipped last week, what's stuck.
5. **Read the "Open questions" section of `DECISIONS.md`** — what's still unresolved.
6. **Skim `TECH_DEBT.md`** (if exists) — anything tagged BLOCKER or HIGH.
7. **Skim `IDEAS.md`** (if exists) — only to recall what's been deferred, NOT to re-evaluate.
8. **State current understanding aloud and confirm** — tell the user what you understand the project state to be and ask what they want to tackle today. This catches drift between actual state and Claude's read of state.

If Claude skips step 8, drift accumulates. Don't skip it.

### 2. Mid-session capture discipline

When something happens during the session, route it to the right doc **immediately at the moment of consensus** — not in a batch at session end. Batched capture loses things.

| Event | Goes to | Format |
|---|---|---|
| Design decision made | `DECISIONS.md` | Append entry with full template (status, context, decision, rationale, trade-offs, revisit-if) |
| New idea that won't be built now | `IDEAS.md` | Append one-paragraph entry (what it is, why deferred, promote-to-build conditions) |
| Bug, inconsistency, or "fix later" item | `TECH_DEBT.md` | Append with severity tag, location, what's wrong, cost-of-not-fixing |
| Open question we don't have data to answer | `DECISIONS.md` "Open questions" section | Append with the data that would resolve it |
| Architecture rule discovered or refined | `ARCHITECTURE.md` | Edit the relevant section (and add a `DECISIONS.md` entry if it's a real change) |
| Workflow / collaboration preference | `VIBE_CODING.md` (process) or Claude's auto-memory (style) | Process changes go in the project doc. Style preferences go in Claude's memory. |
| Plain "this is what I want next" task | TodoWrite (in-session only) | Tasks live in the active todo list. Don't pollute project docs with them. |

**The capture rule**: when a decision crystallizes, Claude says *"I'm capturing that in DECISIONS.md now"* and does it. Not "we should write this down later." Now. Otherwise it dies.

### 3. Session end ritual (5 min)

Before signing off:

1. **Confirm new decisions are captured** in `DECISIONS.md` with full template.
2. **Confirm new ideas** are in `IDEAS.md`.
3. **Confirm new tech debt** is in `TECH_DEBT.md`.
4. **Run the modularity check** (per CLAUDE.md): did changes touch only the system they should have? Flag if not.
5. **Commit any in-progress doc changes** with intent-explaining messages.
6. **End-of-week entry**: if it's Friday or last working day of the week, append a 5-line entry to `RECAPS.md`.
7. **Update "Currently in flight"** at the bottom of `CLAUDE.md` (see template below) so the next session starts oriented. Clear it if nothing's in flight.

---

## Document hierarchy — which doc is canonical for what

| Question | Canonical answer in |
|---|---|
| What's the project building? | `VISION.md` (north star) + `FULL_VISION.md` (full launch spec) |
| What did we decide and why? | `DECISIONS.md` |
| What are we *currently* building? | `VERTICAL_SLICE.md` + `ROADMAP.md` (phase status) |
| How do we work? | `VIBE_CODING.md` (process) + this file (session discipline) |
| How do we keep going? | `RESILIENCE.md` |
| What's the architecture? | `ARCHITECTURE.md` |
| What's the content data? | `CONTENT.md` |
| How does multiplayer work? | `MULTIPLAYER.md` |
| What are we explicitly NOT doing? | `IDEAS.md` (deferred ideas), `CLAUDE.md` "What we are NOT building" (hard no's) |
| What's broken / fix-later? | `TECH_DEBT.md` |
| What happened recently? | `RECAPS.md`, plus `git log` |
| What's the current session pickup? | `CLAUDE.md` "Currently in flight" section |
| How does Claude carry context across sessions? | This file |

**If two docs disagree**: `DECISIONS.md` wins for design questions. `ARCHITECTURE.md` wins for technical questions. `CLAUDE.md` wins for current session state. When you discover a contradiction, fix it in the moment — don't leave drift.

---

## Companion files (templates)

Three files referenced throughout the project. Created lazily when first needed.

### `IDEAS.md` template

```markdown
# IDEAS.md — Hoardseeker

> Append-only log of ideas that won't be built now (or maybe ever).
> Adding here is how we say "no" without losing the thought.
> Promotion to the build requires a `DECISIONS.md` entry first.

## YYYY-MM-DD — [IDEA NAME]

**What it is**: One sentence.
**Why deferred**: Where it would live if we did it (post-launch update? sequel? cut entirely?).
**Surface area**: Roughly how big a build it would be (hours, days, weeks).
**Promote-to-build conditions**: What would have to be true for this to come back?
```

### `TECH_DEBT.md` template

```markdown
# TECH_DEBT.md — Hoardseeker

> Append-only log of known issues, fix-laters, and architectural concerns.
> Severity tags: BLOCKER (fix this week), HIGH (fix this phase), MEDIUM (fix before launch), LOW (nice to fix).

## YYYY-MM-DD — [DEBT TITLE] [SEVERITY]

**Where**: File path + brief location.
**What's wrong**: One paragraph.
**Why we deferred the fix**: Time pressure? Scope creep? Waiting on a decision?
**Cost of not fixing**: What breaks if this goes to launch?
```

### `RECAPS.md` template

```markdown
# RECAPS.md — Hoardseeker

> Friday-or-end-of-week 5-line recap. Append-only.
> Per `RESILIENCE.md`: bad weeks count. Honest entries beat polished ones.

## YYYY-MM-DD — [WEEK NUMBER OR LABEL]

- **What shipped**: ...
- **What got hard**: ...
- **What surprised me**: ...
- **How I felt**: ...
- **What's next week**: ...
```

### "Currently in flight" template (lives at the bottom of `CLAUDE.md`)

```markdown
## Currently in flight

(Updated at end-of-session. Empty if nothing in flight.)

- **What we were working on**: ...
- **Where we paused**: ...
- **What needs to happen first when we resume**: ...
- **Any blockers**: ...
- **Branch / files involved**: ...
```

---

## Memory: Claude's auto-memory vs. project docs

Claude has a separate auto-memory system (`~/.claude/projects/.../memory/`) that persists across sessions. The relationship to project docs:

- **Project docs are canonical** for anything that future-anyone (not just Claude) needs to know — the user, a contractor, a publisher reviewer, a future collaborator, future-Claude.
- **Claude's auto-memory** is for things that help Claude specifically be a better collaborator: user role, working style preferences, feedback like *"don't suggest X, user dislikes it"*, references to external systems.
- **If the question is "what did we decide?"** → project doc.
- **If the question is "how does this user prefer to be told things?"** → Claude's memory.

When in doubt, write to the project doc. Memory should not duplicate what's in the project doc — that creates two sources of truth and they will drift. The project doc wins.

---

## Anti-patterns this file is preventing

- **The lost decision**: A decision made in conversation, never written down, then re-debated 6 months later. Both parties try to remember what was agreed. Both remember differently. Time wasted, momentum killed.
- **The phantom plan**: Claude says "I'll do X" without capturing what X was. Next session it's a vague memory that may or may not match what gets built.
- **The drift**: Project docs slowly stop matching reality because nobody updated them as decisions were made. By month 12 the docs describe a game that no longer exists.
- **The stale memory**: Claude works from a 6-month-old assumption because the doc wasn't updated. Builds the wrong thing.
- **The orphan idea**: A great suggestion comes up mid-session, gets deferred, has nowhere to live, gets forgotten. Six months later the user remembers it but can't reconstruct the original framing.
- **The compounding tech debt**: Small "fix laters" never tracked. All emerge as surprises pre-launch. Last-month panic.
- **The non-handoff**: Session ends mid-work. Next session starts cold. Half an hour spent reconstructing context that should have been one paragraph in CLAUDE.md.

Each of these has a specific countermeasure in the rituals above. If you find yourself in one of them, the protocol failed — fix the protocol, not just the symptom.

---

## When to update this protocol itself

Edit this file when:
- A new doc is added to the project → add it to the hierarchy table.
- A new ritual proves useful and should become standard → add to the appropriate session phase.
- A failure mode shows up that this file should be preventing → add it to the anti-patterns section and add a countermeasure.
- Roles or working style fundamentally shift → revisit the whole protocol.

Updates to this file go through `DECISIONS.md` like any other process change. The protocol is itself a load-bearing decision.
