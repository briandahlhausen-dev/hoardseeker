# IDEAS.md — Hoardseeker

> Append-only log of ideas, deferred design choices, and open questions
> that won't be resolved now (or maybe ever).
> Adding here is how we say "not now" without losing the thought.
> Promotion to the build requires a `DECISIONS.md` entry first.
> Template + protocol live in `SESSION_PROTOCOL.md`.

---

## 2026-05-09 — Monster turn flow: shared AP refresh with players, or separate mechanism? ✅ RESOLVED 2026-05-10

**Resolution**: Decided — Approach A (shared AP-driven turns). See DECISIONS.md 2026-05-10 entry "Monster turn flow." Implemented in Phase J (`MonsterAI` helper, `EndTurnCommand` AP-refresh extends to monsters via `find_actor`).

---

## 2026-05-09 — Monster turn flow [original entry, kept for context]

**What it is**: When monster AI lands, monsters will need *some* turn-start logic. Open question: does that logic share the AP-refresh path that `EndTurnCommand` currently runs for players (extending it to handle monsters via `find_actor` rather than `find_player`), or do monsters use an entirely separate mechanism (e.g., AI-driven action selection without an explicit AP budget)?

**Why deferred**: No monster AI yet. `AttackCommand` can already target monsters (chunk 2 work), but monsters don't yet *act* on their own turn. The right answer depends on whether monster turn structure ends up resembling player turn structure (multi-action AP budget, abilities-list-as-data) or something simpler (one decision per turn, no AP, behaviors-as-functions). The design call belongs with the chunk that introduces monster behavior, not now.

**Surface area**: A few hours either way once monster-AI design is settled. Shared path = small refactor in `EndTurnCommand` (find_player → find_actor for the AP-refresh leg, plus a guard for monsters that don't carry AP). Separate path = a new `MonsterTurnCommand` (or equivalent) without touching `EndTurnCommand`.

**Promote-to-build conditions**: Decide when scoping the Phase 1 chunk that introduces the skeleton's behavior. The decision-driving questions:
- How many actions does a typical monster take per turn? (One = no AP needed; multiple = AP makes sense.)
- Does monster AP need to be visible to players? (Affects abilities like "stun" or "slow" that deny action_points to a target.)
- Do monsters share enough turn-structure with players that the same `EndTurnCommand` pipeline is the natural fit?

If "yes" to two or more, share the path. If "no" to all three, separate mechanism is cleaner.

---

## 2026-05-10 — Status effects: ability integration, stacking rules, save throws ✅ RESOLVED 2026-05-10

**Resolution**: All three sub-questions decided. See DECISIONS.md 2026-05-10 entries:
- Ability integration → "AbilityDef.applies_effects (full effects inline)" — implemented in Phase K
- Stacking → "refresh duration on same effect_id" — implemented in Phase K
- Save throws → "AbilityDef save fields; saves gate effect, not damage" — implemented in Phase L (with `fighter_shield_bash` as first ability)

---

## 2026-05-10 — Status effect questions [original entry, kept for context]

**What it is**: Three deferred design questions that all sit on top of the chunk-8 status-effect architecture.

**1. Ability integration** — How does an ability declare it applies an effect on hit?
Options:
- (a) `AbilityDef.applies_effect_id: String` — single effect, looked up by id from a registry.
- (b) `AbilityDef.effect_to_apply: StatusEffect` — full effect carried inline; copied onto target on hit.
- (c) `AbilityDef.on_hit_commands: Array[Command]` — generic "apply these commands as side effects on hit."
- Each option has trade-offs around composability (option c is most flexible but heaviest), data-only authorability (option a/b stay in `.tres`), and effect parameterization (option b lets cleave's stun differ from shield_bash's stun in duration without two effect entries).

**2. Stacking rules** — What happens when an actor already has effect X and a new copy is applied?
Options:
- (a) Always stack — second instance is independent. Two stuns = stunned for duration max(d1, d2) by accident, or worse, double-applied tick behaviors.
- (b) Refresh duration — if effect_id already present, set duration_remaining = max(existing, incoming). No double application.
- (c) Per-effect rule on the effect itself — e.g. `StatusEffect.stack_mode: String` enum ("stack", "refresh", "ignore", "max_intensity").
- D&D 5e is mostly "doesn't stack — same effect refreshes." Option (b) matches that; option (c) is the most flexible but adds shape to effects.

**3. Save throws** — Some ability-applied effects allow the target a saving throw to resist.
Options:
- (a) Resolve at apply time — if save succeeds, ApplyStatusEffectCommand validates false (or its apply emits a "save succeeded" event and skips the append).
- (b) Save resolution lives on AbilityDef (the ability defines the save type / DC), so ApplyStatusEffectCommand stays save-agnostic.
- (c) Save lives on the effect itself — so any effect can declare "saved against on apply" or "saves at start of every turn."

**Why deferred**: All three depend on each other and on more abilities being authored. fighter_shield_bash is the obvious driver (CONTENT.md says "1d4 damage + STUN on save fail (DC 14 CON)"), so ability integration + save throws will likely land together as a single design pass. Stacking rules can wait until the second stunning ability or the first stacking ability (poison stacks naturally?) appears.

**Surface area**: Probably 1 chunk per question, possibly bundled. Ability integration alone is small; stacking is a design-only change once decided; save throws need a stat-check primitive on actors (also a design call).

**Promote-to-build conditions**: When `fighter_shield_bash` is the next ability to author. That ability requires answers to ability-integration + save-throws + (probably) stacking — so it's the natural unblock point for all three.
