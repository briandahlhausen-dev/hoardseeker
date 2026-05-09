# IDEAS.md — Hoardseeker

> Append-only log of ideas, deferred design choices, and open questions
> that won't be resolved now (or maybe ever).
> Adding here is how we say "not now" without losing the thought.
> Promotion to the build requires a `DECISIONS.md` entry first.
> Template + protocol live in `SESSION_PROTOCOL.md`.

---

## 2026-05-09 — Monster turn flow: shared AP refresh with players, or separate mechanism?

**What it is**: When monster AI lands, monsters will need *some* turn-start logic. Open question: does that logic share the AP-refresh path that `EndTurnCommand` currently runs for players (extending it to handle monsters via `find_actor` rather than `find_player`), or do monsters use an entirely separate mechanism (e.g., AI-driven action selection without an explicit AP budget)?

**Why deferred**: No monster AI yet. `AttackCommand` can already target monsters (chunk 2 work), but monsters don't yet *act* on their own turn. The right answer depends on whether monster turn structure ends up resembling player turn structure (multi-action AP budget, abilities-list-as-data) or something simpler (one decision per turn, no AP, behaviors-as-functions). The design call belongs with the chunk that introduces monster behavior, not now.

**Surface area**: A few hours either way once monster-AI design is settled. Shared path = small refactor in `EndTurnCommand` (find_player → find_actor for the AP-refresh leg, plus a guard for monsters that don't carry AP). Separate path = a new `MonsterTurnCommand` (or equivalent) without touching `EndTurnCommand`.

**Promote-to-build conditions**: Decide when scoping the Phase 1 chunk that introduces the skeleton's behavior. The decision-driving questions:
- How many actions does a typical monster take per turn? (One = no AP needed; multiple = AP makes sense.)
- Does monster AP need to be visible to players? (Affects abilities like "stun" or "slow" that deny action_points to a target.)
- Do monsters share enough turn-structure with players that the same `EndTurnCommand` pipeline is the natural fit?

If "yes" to two or more, share the path. If "no" to all three, separate mechanism is cleaner.
