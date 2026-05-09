# DECISIONS.md — Hoardseeker

> Append-only log of design and architecture decisions.
> When you make a meaningful decision, log it here with the rationale.
> Future-you (and Claude Code) will thank you.

---

## Format

Each entry:

```
## YYYY-MM-DD — [DECISION TITLE]

**Status**: [Decided / Reversed / Superseded]
**Context**: What problem are we solving?
**Decision**: What did we decide?
**Rationale**: Why?
**Trade-offs**: What did we give up?
**Revisit if**: Conditions under which this should be reopened.
```

---

## [project start] — Engine: Godot 4 with GDScript

**Status**: Decided

**Context**: Need to choose an engine that's AI-assistable, free, ships to Steam, and supports a 2D RPG with networking.

**Decision**: Godot 4, primary scripting in GDScript.

**Rationale**:
- Text-based scene/resource files (`.tscn`, `.tres`) are diff-friendly and AI-readable.
- MIT-licensed, no royalties.
- GDScript reads like Python — low syntax tax for AI authoring.
- Buckshot Roulette (~8M copies) proves Godot at solo-dev scale.
- Headless mode (`godot --headless`) enables CI testing.
- Deterministic sim is straightforward in GDScript.

**Trade-offs**:
- 3D performance is weaker than Unreal (we're 2D — irrelevant).
- C# option exists but not chosen — GDScript is simpler for solo dev.
- Smaller asset store than Unity — most assets we need are bespoke anyway.

**Revisit if**: Discover a hard limitation in Godot networking that requires Unity-level features.

---

## [project start] — Genre: D&D-inspired roguelike deckbuilder, solo + duo

**Status**: Decided

**Context**: Establishing the game's identity.

**Decision**: D&D-inspired roguelike deckbuilder. Solo + duo modes. Ranked seasonal ladders for both.

**Rationale**:
- One verb (roll) hits the "single mechanic" pattern from successful solo dev games.
- "D&D roguelike" is a clean, marketable pitch with a known audience.
- Duo (not solo, not 4-player) is a positioning gap in the market.
- Ranked is a retention engine.

**Trade-offs**:
- Crowded genre (Slay the Spire, Balatro, many imitators).
- Duo doubles engineering complexity vs. solo-only.
- Ranked requires backend infrastructure and anti-cheat.

**Revisit if**: Vertical slice combat doesn't feel different enough from Slay the Spire / Balatro.

---

## [project start] — D&D rules: loose, not strict

**Status**: Decided

**Context**: How closely should we follow D&D 5e rules?

**Decision**: D&D vibes only. Optimize for fun. Drop literal SRD compliance.

**Rationale**:
- Strict 5e rules don't fit a 30-45 minute roguelike pacing (5e combat is too slow).
- "Loose D&D" is what BG3, Wildermyth, and other beloved D&D-likes do.
- Avoids any Wizards of the Coast IP entanglement.
- Lets us tune for video-game feel (crit on 19, multi-hit chains, etc.) without breaking tabletop math.

**Trade-offs**:
- Won't satisfy hardcore 5e simulation fans (small audience).
- Branding is "inspired by" not "official."

**Revisit if**: A Wizards licensing opportunity emerges (unlikely, and we should probably stay independent regardless).

---

## [project start] — Vertical slice scope: 1 class, 1 biome, 1 boss

**Status**: Decided

**Context**: How big should the first internal milestone be?

**Decision**: Fighter + Forgotten Crypt + Lich King. Solo only. 4 months.

**Rationale**:
- Smallest possible scope that proves combat feel.
- Fighter has no spell slots — simplest class to implement.
- One biome means one art style, one music track set, one set of monsters.
- Architecture supports duo from day one but doesn't implement it.

**Trade-offs**:
- Slice doesn't show class variety, which is the game's core promise.
- No public-facing build at month 4 — only internal.

**Revisit if**: Combat feel is locked in faster than expected (could expand slice early to 2 classes).

---

## [project start] — Visual style: 2D realism (painted)

**Status**: Decided (with caveat noted)

**Context**: Visual identity choice.

**Decision**: 2D painted realism. MtG / HoMM3 / painted-Slay-the-Spire territory.

**Rationale**:
- Cohesive, ownable aesthetic.
- Differentiates from pixel-art saturated indie market.
- Plays to AI-art-pipeline strengths (concept generation + hand cleanup).

**Trade-offs**:
- **Most expensive art choice.** Pixel art would be 3-4x cheaper.
- Requires either a contracted illustrator or significant solo art skill investment.
- Risks looking cheap if AI art is overused without cleanup.

**Revisit if**: Art production rate falls more than 30% behind plan. Contingency: lean harder on stylized line art with selective coloring (cheaper but still cohesive).

---

## [project start] — Combat: turn-based, abstract positioning, action points

**Status**: Decided

**Context**: How combat plays.

**Decision**: Slay-the-Spire-style abstract positioning (front/back rows), 3 AP per turn, full ability list visible, dice rolls visible.

**Rationale**:
- Familiar to roguelike-deckbuilder audience.
- Simpler to implement and balance than grid tactics.
- Action points feel D&D, full visible list feels D&D, dice rolls feel D&D.
- Networking is trivial for turn-based.

**Trade-offs**:
- Less tactical depth than XCOM-style grids.
- Some D&D mechanics (movement, terrain, opportunity attacks) get simplified or cut.

**Revisit if**: Playtests show combat lacks tactical interest at higher difficulty.

---

## [project start] — Class identity: fixed class, drafted subclass

**Status**: Decided

**Context**: How rigid should class identity be?

**Decision**: Pick class at start, can't change. Draft subclass at floor 5.

**Rationale**:
- Class identity provides marketing pitch ("12 classes").
- Subclass draft gives the run-defining choice moment without breaking class fantasy.
- Synergy with artifacts: subclass + artifacts = run identity.

**Trade-offs**:
- Less flexibility than full multiclass or pool-of-abilities approaches.
- Players who don't like a class are stuck for the run.

**Revisit if**: Players express frustration with class lock-in. Possible mitigation: a "respec" mechanic mid-run for high cost.

---

## [project start] — Multiplayer: split-party duo, lockstep, peer-to-peer

**Status**: Decided

**Context**: How does duo mode actually work?

**Decision**: Lockstep simulation, P2P via Steam relay, split-party at certain map nodes, shared loot pool with negotiation, revives via Glints.

**Rationale**:
- Lockstep is the right model for turn-based games — generous latency budget.
- P2P avoids relay server costs.
- Split-party is the differentiator vs. just-play-side-by-side co-op.
- Shared loot creates negotiation and trust dynamics that make duo *partnership*.

**Trade-offs**:
- Steam-only at launch (no cross-play with non-Steam stores).
- Determinism must be flawless — single RNG slip = desync.
- Split-party doubles UI complexity.

**Revisit if**: Determinism is unmanageable for a solo dev. Fallback: client-server with one peer authoritative (more bandwidth, simpler determinism story).

---

## [project start] — Ranked: composite ELO, seasonal resets, single solo + single duo ladder

**Status**: Decided

**Context**: Structure of competitive systems.

**Decision**: Composite ELO from multiple factors. 10-12 week seasons. One solo ladder, one duo ladder. Class-spotlight as weekly events.

**Rationale**:
- Composite ELO captures depth + score + run quality, not just one metric.
- Seasonal resets = built-in re-engagement events.
- Single ladder concentrates competition (top of ladder is meaningful).
- Class-spotlight events keep all classes relevant without permanent ladder fragmentation.

**Trade-offs**:
- Composite scoring is harder to explain to new players than "highest score."
- Single ladder means players who specialize in one class compete with mains-of-other-classes.

**Revisit if**: Players strongly request per-class permanent ladders. Could split later without breaking existing ratings.

---

## [project start] — Tone: Teen, classic D&D

**Status**: Decided

**Context**: Audience targeting and content rating.

**Decision**: Teen rating. Classic D&D feel — blood when things die, dark themes, no graphic gore.

**Rationale**:
- Teen-rated maximizes audience without being kid-targeted.
- Aligns with audience expectation (BG3, Critical Role, etc.).
- Permits M-rated themes (death, skeletons, dark magic) without M-rated visual extremes.

**Trade-offs**:
- Less edgy than Darkest Dungeon (smaller hardcore audience).
- More violent than Slay the Spire (loses some family-friendly audience).

**Revisit if**: Asset budget pushes us toward less-detailed visuals where blood doesn't read well — could shift more abstract.

---

## [project start] — Races: 6-race roster, stat bumps + perks, Human-only in slice

**Status**: Decided

**Context**: Should the game have D&D races, and how mechanically impactful?

**Decision**: 6 races at launch (Human, Elf, Dwarf, Halfling, Half-Orc, Tiefling). Stat bumps + signature perks (closer to actual D&D). Slice ships Human only.

**Rationale**:
- Race is a core part of D&D fantasy; skipping it weakens the "D&D-inspired" pitch.
- 6 races (vs 8) cuts visually-expensive options (Dragonborn) and mechanically-redundant options (Gnome).
- Stat bumps + perks gives mechanical identity (Halfling Lucky, Half-Orc Savage Attacks) that creates real build texture.
- Human-only in slice keeps art load minimal while testing the system.
- 12 classes × 6 races × 3 subclass options = 216 mechanical combinations. Strong build diversity for marketing and replay.

**Trade-offs**:
- Race art is the largest single illustrator ask: 216 portraits at launch (6 × 12 × 3 variants).
- Slight balance complexity: race × class interactions create matrix to monitor via telemetry.
- Stat bumps add small math layer; we have to test that no race+class combo dominates the meta.

**Revisit if**: Illustrator capacity falls short — contingency is shipping launch with race silhouette/color differentiation only and full per-race portraits as a free post-launch update.

---

## [project start] — Vibe coding workflow: discipline + audits + non-technical user posture

**Status**: Decided

**Context**: User is non-technical (no coding, no game dev experience). Project is solo + AI-assisted over 18-22 months. Need a disciplined operating model that prevents the failure modes of over-confident AI development.

**Decision**: Document and follow the workflow in `VIBE_CODING.md`:
- User is the director, AI is the engineer.
- Plain-English plans before code, every time.
- Always work on branches, never on main.
- Tests are a contract — no feature ships without them.
- Per-commit, weekly, monthly, quarterly, and pre-launch audits enforced.
- Quarterly fresh-Claude modularity test catches architectural drift.
- AI-generated content for prototyping only; final assets are human-made or human-cleaned.
- Decision calendar gives the user time to make choices about tools, contractors, services.

**Rationale**:
- Solo dev failure mode #1 is scope creep. Discipline rules block this.
- Solo dev failure mode #2 is unmaintainable code. Audits and modularity tests block this.
- Solo dev failure mode #3 is burnout. Hard work-hour caps and peer-group recommendations block this.
- AI-assisted dev failure mode is "AI did something I don't understand." The "propose plan in plain English first" rule blocks this.
- The user explicitly requested this discipline; it must be load-bearing in the project's operating system, not optional.

**Trade-offs**:
- Audit overhead is real (~half a day per quarter for the modularity test, plus the smaller cadences).
- "Plan before code" slows sprints slightly but prevents larger rework.
- Strict refusal to use AI for final assets adds budget cost (need contracted illustrator/composer/VA).

**Revisit if**: Timeline slips badly enough that we need to relax some rules. Triage which rule first: most likely candidate is reducing audit frequency, never reducing modularity discipline.

---

## Open questions (not yet decided)

These need to be revisited as the slice progresses:

1. **Final game name**: "Hoardseeker" is the working name. Should we trademark/domain-grab now? Probably yes, but verify availability before committing publicly.
2. **Composer**: Find and contract by month 8. Get demo tracks during Phase 2 if possible.
3. **Voice actor for narrator**: Find by month 9. Need ~200 lines recorded by month 12.
4. **Illustrator**: Find by month 6. Earlier if budget allows. AI-only-art is a fallback.
5. **Publisher target**: Approach Playstack, Future Friends, Hooded Horse around month 12-13. Have demo + Steam page metrics + clear launch plan ready.
6. **Pricing**: $19.99 is the working number. Validate vs. Slay the Spire ($24.99), Balatro ($14.99), Inscryption ($19.99). Probably right.
7. **Demo length**: How much of the game does the demo show? Probably 2 floors + 1 elite + 1 mini-boss, capped at ~15 minutes per attempt. Decide by Phase 5.
