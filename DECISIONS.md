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

## 2026-05-08 — Bootstrap budget mode confirmed (<$5k total)

**Status**: Decided

**Context**: Budget reality check. The original docs assumed contractor-driven art/audio production (~$10-50k). Actual project budget is **<$5,000 total** over the 18-22 month pre-launch window.

**Decision**: Operate in bootstrap mode for the duration of the pre-launch project. Total spend cap: $5,000 across all categories (tools, subscriptions, services, the Steam Direct fee, business setup, AI subscriptions, any commissioned work). After fixed overhead this leaves roughly $2,500-3,500 for creative work.

**Rationale**:
- Forces tight scope discipline from day one rather than mid-project crisis.
- Aligns the production model with what one solo developer can realistically execute with AI assistance.
- Removes a class of failure modes (contractor disputes, payment issues, contractor scope creep).
- Makes launch math survivable on much lower revenue — break-even possible on hundreds of sales rather than thousands.

**Trade-offs**:
- Cannot afford contracted illustrator, composer, or voice actor at launch.
- Aesthetic ceiling is lower than the original "BG3-feeling premium" vision.
- Marketing pitch must shift to match what we can actually ship.
- Several downstream decisions in this document follow from this constraint (art direction, audio direction, narration, scope cuts).

**Revisit if**: Demo reception and wishlist count justify contractor investment before launch. A successful Steam Next Fest with 25k+ wishlists could fund a polish pass with a contracted illustrator pre-launch.

---

## 2026-05-08 — Art direction: AI-generated stylized illustration with hand cleanup (Path B)

**Status**: Decided. Supersedes the "2D realism (painted)" decision above.

**Context**: 2D painted realism requires a contracted illustrator (~$5-25k) and is incompatible with bootstrap budget. We evaluated three alternatives: pixel art (Path A), AI-generated stylized illustration with hand cleanup (Path B), and AI-generated painted with cleanup (Path C). User chose Path B.

**Decision**: AI-generated stylized illustration (D&D sourcebook / Inscryption-adjacent feel) with **mandatory hand cleanup on every shipped asset**. Tools:
- Generation: Midjourney subscription (or local Stable Diffusion).
- Cleanup: Krita and Photopea (free).
- Hardware: Wacom Intuos S tablet (~$80, one-time).
- Total tooling cost: ~$440 over project lifetime.

Estimated cleanup workload: ~275 hours total (portraits, ability icons, artifact icons, monster portraits, biome backgrounds), spread over ~18 months at ~15 hrs/month — well inside the 40-hour weekly cap.

**Rationale**:
- Preserves D&D-feeling aesthetic (sourcebook / tabletop tonal connection) much better than pixel art.
- Solo-doable with AI assistance handling composition, anatomy, color; user does the disciplined cleanup that determines final quality.
- Total tooling cost fits comfortably inside bootstrap budget.

**Trade-offs**:
- **Steam requires AI disclosure** in the store listing's "AI Generated Content" field. Hiding it is not an option.
- **TTRPG/D&D audience is the most AI-art-skeptical audience on Steam**, and we are targeting that audience. Review-bomb risk is real.
- Cleanup discipline is the key risk mitigation. Each asset must look hand-touched, not raw-AI. Cleanup hours are not optional.
- Style consistency across hundreds of assets is hard with AI tools that update over time. Strict prompt template + style guide is essential.

**Revisit if**: Steam policy on AI content tightens further; review-bomb response to demo overwhelms cleanup discipline; or wishlist conversion suggests audience tolerance is materially different from expected.

---

## 2026-05-08 — Audio direction: royalty-free + one commissioned theme; no voice acting

**Status**: Decided. Supersedes original audio direction (original orchestral score, contracted voice actor).

**Context**: Contracted composer ($3-15k) and voice actor ($1.5-6k) are incompatible with bootstrap budget. Need an audio plan that fits <$500 total.

**Decision**:
- **Music**: Primary soundtrack curated from royalty-free orchestral sources (Kevin MacLeod / incompetech.com, FreePD, Pixabay Music, Tabletop Audio commercial-licensed tracks). One signature theme commissioned at ~$300 from a music school student or low-end AirGigs composer for the title screen / boss theme.
- **Voice**: Cut entirely. All narration is text-only with stylized parchment overlay. The "DM voice" as imagined in the original docs is removed from the design.
- **SFX**: Freesound.org (CC0 only, license-verified), Audacity (free) for editing. Custom dice-clack recording with phone + Audacity ($0).

Total audio budget: ~$300-400.

**Rationale**:
- Slay the Spire (our primary touchstone) ships with no narrative voice acting and players love it; text-only narration is not a compromise relative to our reference game.
- Royalty-free orchestral has improved significantly in availability and quality; sufficient variety exists for a D&D-feeling soundtrack.
- Removing voice acting eliminates an entire production track (casting, scheduling, recording, mixing, retakes).

**Trade-offs**:
- Loses the "DM voice" atmospheric goal. Text-only narration carries less emotional weight than voiced delivery.
- Royalty-free orchestral lacks the cohesion of a single composer's full original score. Curation discipline matters.
- Cannot use AI-generated music or voice in shipped product (still excluded under the revised AI rule — see separate decision below).

**Revisit if**: Demo wishlist conversion funds a contracted composer pre-launch ($3-5k for ~30 minutes of original score is achievable at higher wishlist counts).

---

## 2026-05-08 — Narration: text-only forever; no voice acting in shipped product

**Status**: Decided. Supersedes the original "sparse DM narration" via voice actor.

**Context**: Voice acting (~$1.5-6k for ~200 lines) is incompatible with bootstrap budget. Considered cheap VA via Reddit/Discord, AI voice (ElevenLabs), and text-only options.

**Decision**: All narration is **text-only**, displayed in a stylized parchment overlay at narration trigger moments (run start, first crit, boss intros, deaths, mythic artifact pickups, comeback saves, long combo chains). **No voice acting in shipped product, ever** — including post-launch updates and any future DLC.

**Rationale**:
- Slay the Spire's narrative content is text-only and players love it; this is not a compromise relative to our primary touchstone.
- Removes an entire production track (casting, recording, mixing, scheduling).
- Eliminates voice continuity risk if a VA becomes unavailable mid-project or post-launch.
- AI voice was considered and rejected: voice AI is currently the most contentious AI category for player sentiment, and the rule revision keeps AI voice off-limits.

**Trade-offs**:
- Less atmospheric weight on dramatic moments (boss intros, death lines).
- Mitigation: invest the saved budget/time in stylized parchment animation, sound design (parchment unfurling SFX), and writing quality.

**Revisit if**: A passion VA contributor offers their work for free or at a deeply nominal rate AND the user is willing to take on the production overhead. Otherwise this decision is permanent.

---

## 2026-05-08 — Launch scope: 12 classes, 2 biomes, with post-launch content roadmap

**Status**: Decided. Tightens but does not supersede the original 12-class roster (which stays); supersedes the 4-biome launch.

**Context**: Tightening launch scope to fit bootstrap timeline and budget. Original launch was 12 classes + 4 biomes. Evaluated cuts of 6, 8, 10, or 12 launch classes, and 2 or 3 launch biomes. The Claude-assisted authoring rate makes class authoring much cheaper than originally estimated; biome cuts save more art and balance work than class cuts.

**Decision**:
- **Launch with all 12 classes**, including Druid (Wild Shape) and Ranger (companion pet).
- **Launch with 2 biomes**: The Forgotten Crypt + The Sunken Halls.
- **Post-launch free updates** ship the remaining 2 biomes: Ember Reach (year 1 update) and Astral Vault (year 1-2 update).
- **Launch target shifts** from 16-18 months to ~18-20 months to absorb Druid/Ranger subsystem engineering.

**Rationale**:
- Class count is the marketing headline pitch ("12 classes"). Cutting damages the pitch significantly.
- Biome cuts save substantially more work than class cuts (~30 fewer monsters, 2 fewer bosses, ~80-120 hrs of art cleanup) without weakening the marketing pitch.
- Druid and Ranger introduce new combat subsystems beyond just class-level mechanics; they need real architecture work but are doable with Claude doing the heavy lifting.
- Post-launch biome drops become the Year 1 content cadence, supporting sustained engagement after launch.

**Trade-offs**:
- Complete-run length drops from 4 biomes (~120-150 minutes) to 2 biomes (~70 minutes). Still within roguelike norms but shorter than the original ambition.
- Post-launch development requires sustained user motivation and ideally launch revenue. If launch underperforms, biomes 3-4 may slip further.
- Druid and Ranger subsystem risk is real; if either becomes unmanageable, contingency is shipping that class as a post-launch update instead.

**Revisit if**: Druid or Ranger architecture proves intractable for solo+Claude development — pull either to post-launch and reduce launch classes accordingly. Or if biome 1-2 production tracking shows >2x the expected pace, biome 3 (Ember Reach) could be added back to launch scope.

---

## 2026-05-08 — Adopt SESSION_PROTOCOL.md as the cross-session discipline

**Status**: Decided

**Context**: The bootstrap-realignment session surfaced how easily decisions can be made in conversation but never written down. Across an 18-22 month project with Claude as the primary engineer, lost decisions are a top-tier failure mode: by month 12, Claude works from stale assumptions and the user can't reconstruct what was agreed in month 4.

**Decision**: Adopt `SESSION_PROTOCOL.md` as the canonical discipline for session management. The protocol defines:
- Session-start ritual (read order, state-check, drift confirmation with the user)
- Mid-session capture discipline (decisions go to `DECISIONS.md`, ideas to `IDEAS.md`, tech debt to `TECH_DEBT.md` — at the moment of consensus, not in a batch)
- Session-end ritual (commit, modularity check, "Currently in flight" handoff)
- Document hierarchy (which doc is canonical for what)
- Templates for `IDEAS.md`, `TECH_DEBT.md`, `RECAPS.md`, and the "Currently in flight" section
- Memory vs project doc relationship (project docs are canonical; Claude's auto-memory is for collaboration style)

`CLAUDE.md` is updated to list `SESSION_PROTOCOL.md` as #3 in the session-start read order and to host the "Currently in flight" section at its bottom.

**Rationale**:
- Bootstrap-mode + 18-22 month timeline + AI-engineer collaboration model = high blast radius for lost decisions. The protocol exists to prevent that.
- Mid-session capture (not batched at end-of-session) is the discipline that actually works; batched capture loses things.
- The "Currently in flight" handoff section is the cheapest possible solution to the cold-start problem at the next session.
- Centralizing the document hierarchy in one place prevents drift between docs over time.

**Trade-offs**:
- ~5 minutes of overhead per session for the start and end rituals.
- Discipline is required: if Claude or the user skips capture in the moment, the protocol fails. The protocol cannot self-enforce.
- One more doc to maintain. But it's small and stable; updates to the protocol itself go through DECISIONS.md.

**Revisit if**: The protocol proves to lose more time than it saves (unlikely after the first month). Or if a fundamentally different working model emerges (e.g., the user becomes more technical and starts writing code themselves).

---

## 2026-05-08 — Revised AI-content rule: AI art permitted in shipped product with cleanup + disclosure

**Status**: Decided. Supersedes the original "Never ship AI-generated content as final art, music, or voice in a commercial release" rule in VIBE_CODING.md.

**Context**: The original blanket "never ship AI as final" rule conflicts directly with Path B (AI-generated art with hand cleanup). Need a revised rule that protects the original spirit (don't ship raw AI slop, be honest with players) while permitting the specific bootstrap-feasible workflow.

**Decision**: Revise the rule in `VIBE_CODING.md` as follows:

> **AI-generated content may appear in shipped product ONLY when:**
> 1. Every asset has substantial hand cleanup with documented process (cleanup is what determines final quality).
> 2. The Steam store page discloses AI use prominently and accurately, per Steam's required "AI Generated Content" field.
> 3. We maintain a public "How this art was made" statement on the project website / Discord, explaining the workflow honestly.
>
> **AI-generated music and AI-generated voice remain off-limits in shipped product.** These categories carry higher community sensitivity and weaker cleanup options. Royalty-free music + commissioned signature theme + text-only narration are the alternatives.

**Rationale**:
- Original rule was written assuming a contractor-funded production model. Bootstrap reality requires a different rule.
- The revised rule keeps the *spirit* of the original (don't ship raw slop, be transparent with players) while permitting the specific feasible path.
- AI music/voice exclusions match where community sentiment is most negative and where royalty-free / text alternatives are strongest.

**Trade-offs**:
- Some philosophical purity lost. The user accepts AI tooling in shipped product where previously the answer was a flat no.
- Reputational risk in TTRPG audience that is particularly anti-AI-art (mitigated by cleanup discipline + transparency).
- This rule may need re-tightening if Steam policy changes or community response is severe.

**Revisit if**: Steam tightens AI policy in a way that makes disclosure a liability; or audience response makes AI-shipped art untenable for our specific genre.

---

## 2026-05-09 — CommandProcessor logical timestamp is derived from log size, not a separate counter

**Status**: Decided

**Context**: When implementing `CommandProcessor.process(command, state)` (Phase 1), needed a way to assign monotonic logical timestamps to each command + the events it emits. Two reasonable approaches: (a) maintain a counter on the processor instance, increment per command; (b) derive the timestamp from `state.event_log.commands.size()` at process time.

**Decision**: Use approach (b). Each processed command gets `timestamp_logical = event_log.commands.size()` BEFORE being appended. So command 0 lands at logical time 0, command 1 at logical time 1, etc. Events emitted by that command inherit the same logical time.

**Rationale**:
- The event log IS the source of truth for "what has happened in this run." A separate counter is a second source that can drift.
- `RNGService.stream_position` follows the same pattern (state-derived, not separate counter).
- Replay just re-walks the log; no counter to reset.
- CommandProcessor stays stateless (RefCounted with no fields). Simpler to reason about, trivially safe to construct ad-hoc.
- If we ever needed to truncate the log (rollback), the counter would be wrong; the derived approach is correct by construction.

**Trade-offs**:
- The processor needs read access to `state.event_log` to know what time it is. This is fine — the processor already mutates the log; reading it is cheap.
- Doesn't survive log corruption — if the log gets truncated, the next "logical time" jumps. But truncation isn't a use case we support.

**Revisit if**: We add a use case where commands get assigned logical times before they're processed (e.g. clients pre-stamp commands and the processor just validates the stamp). At that point the source of truth shifts to whoever's doing the stamping.

---

## 2026-05-09 — Adopt the Friday audit routine (scheduled remote agent)

**Status**: Decided

**Context**: `VIBE_CODING.md` and `RESILIENCE.md` both prescribe a Friday end-of-week audit (test status, file size, tech debt review, weekly recap). For most of the project's life this would have to be a manual ritual — easy to skip, easy to forget. With the Claude GitHub App now installed on `briandahlhausen-dev/hoardseeker`, a scheduled remote agent can run the audit automatically.

**Decision**: A weekly scheduled remote agent (routine ID `trig_014n5heywcVN3czDASX9bhgL`) runs every Friday at `0 20 * * 5` UTC (= Friday 4pm EDT / 3pm EST). It:
- Reads CLAUDE.md / VIBE_CODING.md / RESILIENCE.md / SESSION_PROTOCOL.md, plus most recent entries in DECISIONS.md / RECAPS.md / TECH_DEBT.md
- Reviews the week's git activity, CI status (via gh), .gd file sizes (>150 lines), TODO/FIXME deltas, tech debt aging, and "Currently in flight" staleness
- Opens a PR titled `Friday audit YYYY-MM-DD` against main containing a draft RECAPS.md entry (5-line format, "How I felt" left for user) and audit findings in the PR description
- **Does NOT merge the PR** — user reviews on Monday
- Opens an `AUDIT-CRITICAL: <summary>` GitHub issue if anything urgent is found (failing CI on main, BLOCKER tech debt unfixed >7 days, RESILIENCE.md crisis warnings)

**Rationale**:
- Discipline rituals only work if they're reliable; cron beats memory.
- The PR-not-commit pattern means the audit has zero unilateral authority — it surfaces findings, the user decides what's true and what to merge.
- Critical-issue escalation routes truly urgent things (broken main, abandoned project signals) to GitHub notifications you'd see on your phone.
- Cost: the routine runs in Anthropic's cloud at the user's existing Pro/Max plan rate. No additional spend.

**Trade-offs**:
- The remote agent doesn't have Godot installed, so it can't run tests directly — it checks CI status instead. This is fine because CI runs the tests on every push; CI is the source of truth for "did the tests pass this week."
- Adds a weekly PR to review. If the user ignores the PR for several weeks, the cadence collapses (still better than no audit at all).
- If the audit ever produces a low-quality output, the prompt may need tuning.

**Revisit if**: PRs become noise the user routinely closes without reading (signals the prompt is too loose); or if the user starts running manual end-of-week audits with me consistently and the routine becomes redundant.

---

## 2026-05-09 — No CombatantState base class; find_actor returns Resource

**Status**: Decided

**Context**: Phase 1 chunks 1-2 needed AttackCommand to target either a PlayerState or a MonsterState. Two reasonable shapes for the polymorphism:
- (a) Extract a shared `CombatantState` base class carrying the common combat fields (`hp`, `ac`, `action_points`, `actor_id`, etc.), then `find_actor() -> CombatantState`.
- (b) Keep `PlayerState` and `MonsterState` as siblings (no shared base), and have `find_actor() -> Resource` (untyped). Callers access `.hp` / `.ac` / `.action_points` via duck typing.

**Decision**: Approach (b). Sibling Resources, no `CombatantState` base, `find_actor` returns untyped `Resource`. `AttackCommand.validate()` and `AttackCommand.apply()` type their attacker/target locals as `Resource`.

**Rationale**:
- The two have **diverging lifecycle concerns**, not just diverging fields. Players carry subclass draft, inventory, gold, glints, artifacts, run-progress state. Monsters carry AI behaviors, loot tables, spawn metadata, despawn rules. A shared base would either bloat with members one side ignores, or force a painful split later when divergence grows.
- The shared *combat* surface is small (5 fields). The shared *lifecycle* surface is zero. Extracting a base for 5 fields when the rest of the type is disjoint is a poor trade.
- `find_actor`'s untyped return makes the polymorphism boundary explicit. Callers that need "either kind" can't accidentally reach for player-only fields. Callers that genuinely need a player still use `find_player`.
- Composition over inheritance fits Godot's Resource model — round-tripping disjoint types via the resource saver is straightforward; forcing a base class buys nothing the runtime cares about.

**Trade-offs**:
- No compile-time guarantee that PlayerState and MonsterState share the same combat-field shape. If MonsterState renamed `hp` to `vitality`, AttackCommand would silently break at runtime. Mitigation: `test_scripted_fight.gd` exercises the cross-type path on every CI run.
- "Any actor" code can't use static typing for the actor variable; everything is `var x: Resource` plus trust in the convention.
- New contributors might expect a base class and be momentarily confused. Mitigation: the `MonsterState` doc header explicitly explains the choice and references this entry by date.

**Load-bearing files** (where this decision shapes the code):
- [src/core/monster_state.gd](hoardseeker/src/core/monster_state.gd) — the sibling Resource; doc header carries the rationale.
- [src/core/game_state.gd](hoardseeker/src/core/game_state.gd) — `find_actor()` returns `Resource`; doc comment explains why.
- [src/systems/combat/attack_command.gd](hoardseeker/src/systems/combat/attack_command.gd) — uses `find_actor`, types locals as `Resource`.

**Revisit if**: PlayerState and MonsterState ever come to share 5+ fields with identical semantics AND 5+ command types need the cross-type lookup. At that combined threshold the structural commonality is large enough that base-class extraction costs less than the duplication. Current count: ~5 shared fields, 1 cross-type command. Well under threshold.

---

## 2026-05-10 — UseAbilityCommand carries `target_ids` always; AbilityDef.target_count specifies how many

**Status**: Decided

**Context**: Phase 1 chunk 5 added a second concrete ability (`fighter_cleave`) which fundamentally targets *two* enemies at once. The chunk-3 `UseAbilityCommand` carried a single `target_id: String`. Two reasonable shapes for adding multi-target support:

- (a) Keep `target_id` for single-target. Add a second command type, `UseMultiTargetAbilityCommand`, with `target_ids: Array[String]`. AbilityDef has no targeting field; the *command type* tells you the count.
- (b) Replace `target_id` with `target_ids: Array[String]` on the existing command. Single-target abilities pass a 1-element array. AbilityDef declares `target_count: int` so validate can catch count mismatches between the command and the data.

**Decision**: Approach (b). One command type, `target_ids` always, `AbilityDef.target_count` as the source of truth for "how many targets does this ability expect."

The single-target convenience constructor `UseAbilityCommand.new(actor, ability, target_id)` wraps a non-empty `target_id` into a 1-element `target_ids` automatically — chunk-3's tests pass unchanged. Multi-target callers use the static factory `UseAbilityCommand.multi_target(actor, ability, target_ids)`.

**Rationale**:
- One command type means one apply path, one resolution loop, one set of events. Cleave's per-target events look exactly like slash's events tagged with target id.
- Putting `target_count` on `AbilityDef` (the data) rather than the command type (the code) keeps the rule that "adding a new ability is a `.tres` change, not a code change." A future "stab three goblins" ability is `target_count=3` in a .tres, no new command class.
- `target_ids.size() != def.target_count` is a simple validate check that catches both directions of mismatch (cleave with 1 target, slash with 2 targets).
- The single-target back-compat constructor preserves the existing ergonomic API for the 90% case. Most abilities are single-target and shouldn't pay multi-target ergonomic tax.

**Trade-offs**:
- `target_count` is a fixed integer — no support yet for "1 to N" targets (e.g., a fireball that hits all enemies in a zone, where the count varies with positioning). When that need arrives, expect to add a richer `targeting: String` enum field alongside `target_count`. The current shape doesn't preclude it.
- Order of `target_ids` matters (events are emitted per target in array order). For abilities where order is irrelevant, callers carry a small ergonomic burden of choosing an order.
- The static factory is a second construction path, slightly more API surface than a single ctor.

**Load-bearing files**:
- [src/content/abilities/ability_def.gd](hoardseeker/src/content/abilities/ability_def.gd) — `target_count: int = 1`.
- [src/systems/combat/use_ability_command.gd](hoardseeker/src/systems/combat/use_ability_command.gd) — `target_ids: Array[String]`, back-compat ctor, `multi_target` factory, per-target resolution loop.
- [src/content/abilities/fighter_cleave.tres](hoardseeker/src/content/abilities/fighter_cleave.tres) — first multi-target ability, `target_count=2`.

**Revisit if**: An ability needs variable target count (zone effects, "all enemies", "all allies in line"). Replace or augment `target_count` with a `targeting` enum at that point. Or if the per-target apply path needs to differ structurally per ability (e.g., cleave that auto-chains to a third target on kill — at that point a Strategy pattern on AbilityDef may beat the single resolution loop).

---

## 2026-05-10 — Status effects: one generic StatusEffect class, dispatch on effect_id, ticked on EndTurnCommand

**Status**: Decided

**Context**: Phase 1 chunk 8 added the status-effect concept end-to-end. Three architectural calls had to be made:

1. **One generic class vs. per-effect subclasses**. We could have one `StatusEffect` Resource with an `effect_id: String` and a `params: Dictionary`, with tick logic dispatching on `effect_id`. Or a class hierarchy: `StunEffect`, `PoisonEffect`, `SlowEffect`, etc., each overriding a virtual `tick()` method.
2. **When does ticking happen**. Start-of-turn (the affected actor's turn), end-of-turn, top-of-round, or some combination.
3. **Where does dispatch live**. On the effect object itself (each effect knows how to tick), in EndTurnCommand, in a separate StatusEffectSystem.

**Decision**:
1. **One generic `StatusEffect` class**. Fields: `effect_id`, `duration_remaining`, `params: Dictionary`, `source_actor_id`. Pure data. Subclasses are NOT introduced.
2. **Tick at start-of-turn** of the affected actor. Implemented inside `EndTurnCommand.apply()`: when the new active actor is set, their effects tick.
3. **Dispatch lives in `EndTurnCommand._tick_status_effects()`** as a `match effect_id:` block. Adding a new effect kind is a new branch in that function plus tests; no other code changes.

**Rationale**:
- Most effects are mostly data (a magnitude + duration) with a small handful of behaviors. A class hierarchy buys polymorphism we don't need yet, at the cost of more files and a more rigid shape that's painful to refactor when we discover an effect needs new fields.
- Centralized dispatch (one match block in EndTurnCommand) makes "what does this effect do?" answerable in one place. Compared to scattering the answer across N subclass files, this is faster to read and harder to lose track of.
- Start-of-turn ticking matches D&D 5e's "at the start of your turn" condition checks, which is the design idiom we're inheriting. End-of-turn ticking would force odd phrasing for stun ("loses next turn"); start-of-turn ticking lets us express things naturally ("stunned: lose AP this turn").
- AP refresh runs BEFORE the tick so stun (which zeros AP) sees a full pool to deny. Reversed order would have AP refresh undo the stun.

**Trade-offs**:
- The dispatch grows a `match` arm per new effect type. At ~20 effects this becomes a long block; at that point a registry pattern (effect_id → tick callable) may beat the match. Not an issue for the slice (we'll have ~5 effects in scope).
- The generic `params: Dictionary` is untyped — risk of typos in keys (e.g., `damage_per_turn` vs. `damage`). Mitigation: per-effect tests assert the contract; doc comments in StatusEffect spell out the convention.
- Effects defined as "modify max_hp" or "give bonus to attack rolls" don't fit cleanly in a tick-based model — those are passive modifiers. When the first such effect arrives we'll likely add a separate "passive modifier" mechanism alongside this tick-based one.

**Load-bearing files**:
- [src/core/status_effect.gd](hoardseeker/src/core/status_effect.gd) — the data class.
- [src/systems/combat/apply_status_effect_command.gd](hoardseeker/src/systems/combat/apply_status_effect_command.gd) — the entry point for status creation.
- [src/systems/combat/end_turn_command.gd](hoardseeker/src/systems/combat/end_turn_command.gd) — `_tick_status_effects()` is where new effect-kinds get their tick behavior.

**Revisit if**:
- The match block grows beyond ~10 arms and is causing review pain — switch to a registry / dispatch table.
- Effects need cross-actor or world-level interactions (e.g., aura effects affecting nearby actors) — current single-actor tick model won't handle that cleanly.
- The first passive modifier (non-tick) effect arrives — needs a separate mechanism.

---

## Open questions (not yet decided)

These need to be revisited as the slice progresses:

1. **Final game name**: "Hoardseeker" is the working name. Should we trademark/domain-grab now? Probably yes, but verify availability before committing publicly.
2. **Commissioned signature theme composer**: Source for the one ~$300 signature theme (title screen / boss). Likely AirGigs lower tier, music school program, or solo composer on Reddit r/composer. Decide by month 8.
3. **Publisher target**: Approach Playstack, Future Friends, Hooded Horse around month 12-13. Have demo + Steam page metrics + clear launch plan ready. Less critical now under bootstrap mode — self-publish on Steam is the realistic baseline.
4. **Pricing**: $19.99 is the original working number. Bootstrap-mode production might support a lower launch price ($14.99) to compete with Balatro / Inscryption pricing tier and reflect the more modest production. Validate against demo reception. Decide by month 14.
5. **Demo length**: How much of the game does the demo show? Probably 2 floors + 1 elite + 1 mini-boss, capped at ~15 minutes per attempt. Decide by Phase 5.

### Closed questions (resolved by 2026-05-08 bootstrap realignment)

- ~~Composer for full original score~~ — Replaced with royalty-free curation + one commissioned signature theme. See "Audio direction" decision.
- ~~Voice actor for DM narrator~~ — Cut entirely. See "Narration: text-only forever" decision.
- ~~Illustrator for full launch art~~ — Replaced with AI-generated art + hand cleanup workflow. See "Art direction: Path B" decision.
