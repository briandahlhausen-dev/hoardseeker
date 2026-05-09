# ROADMAP.md — Hoardseeker

> Phased plan from project start to launch (months 1-22) and beyond.
> Updated as milestones complete or slip. **Always check current phase before deciding what to work on.**

---

## Status

- **Current phase**: Phase 0 (project setup)
- **Last updated**: 2026-05-08 (bootstrap realignment)
- **Target launch**: month 18-20 (with buffer to month 22)
- **Mode**: Bootstrap (<$5k total project budget). See `DECISIONS.md` for full implications.

---

## Phase 0 — Project setup (week 1)

**Goal**: Empty Godot project with the architectural skeleton in place.

- [ ] Godot 4 installed, project created
- [ ] Repository on GitHub (private until launch announcement)
- [ ] Directory structure matches `ARCHITECTURE.md`
- [ ] `.gitignore` for Godot + assets pipeline
- [ ] CI on GitHub Actions: run headless tests on every push
- [ ] `RNGService`, `GameState`, `Command` base classes scaffolded
- [ ] One placeholder test asserting determinism harness works
- [ ] All design docs (this folder) committed

**Gate to Phase 1**: A no-op simulation runs headless. A test passes. CI is green.

---

## Phase 1 — Combat core (weeks 2-5, vertical slice)

**Goal**: A scripted fight resolves deterministically in headless mode.

- [ ] `PlayerState`, `EncounterState`, `MonsterState` resources
- [ ] `Command` subclasses: `AttackCommand`, `UseAbilityCommand`, `EndTurnCommand`
- [ ] `CommandProcessor` validates and applies commands
- [ ] `EventLog` captures commands and emitted events
- [ ] Turn order, action points, HP, AC math
- [ ] 2 abilities: `fighter_slash`, `fighter_cleave`
- [ ] 1 monster: skeleton warrior, simple AI
- [ ] Test: scripted fight to completion, deterministic
- [ ] Test: replay event log, end states match

**Gate to Phase 2**: Same seed + same commands = byte-identical end state, every time. 100% pass rate over 1000 simulated runs.

---

## Phase 2 — Combat UI & feel (weeks 6-9, vertical slice)

**Goal**: The combat scene feels good to play.

- [ ] Combat scene laid out: enemies right, player left, abilities bottom
- [ ] Dice roll animation (centerpiece — invest heavily, iterate until great)
- [ ] HP bars, action point pips, damage numbers
- [ ] Crit: screen shake, sound, particle burst
- [ ] Status effect icons
- [ ] Hover tooltips on abilities
- [ ] Combat audio: dice clack, sword hit, monster death
- [ ] Combat music
- [ ] Playtest: 3 non-developers play 2 fights each. Capture feedback.

**Gate to Phase 3**: A non-developer plays a fight, then says "let me try one more." If not, iterate on combat feel until they do.

---

## Phase 3 — Run structure (weeks 10-12, vertical slice)

**Goal**: A full 10-floor run is playable.

- [ ] Branching map view (Slay the Spire-style)
- [ ] Map generation algorithm (deterministic from seed)
- [ ] Floor transitions, fade-ins
- [ ] Reward screens between fights
- [ ] Room types: combat, elite, treasure, shop, rest
- [ ] Gold + Glints (risk currency)
- [ ] Subclass draft at floor 5
- [ ] Death screen with run summary
- [ ] Loop back to character creation

**Gate to Phase 4**: A 30-minute run can be completed start to finish, then started over.

---

## Phase 4 — Slice content & polish (weeks 13-16, vertical slice)

**Goal**: Vertical slice is "done" — full Fighter content, full Crypt biome.

- [ ] All 20 Fighter abilities authored as `.tres`
- [ ] All 15 slice artifacts authored
- [ ] All 12 slice monsters authored, AI behaviors
- [ ] Lich King boss with 3 phases
- [ ] 4 narration moments hooked up + voice acting (placeholder TTS at first)
- [ ] Save/load mid-run
- [ ] Settings menu (audio, video, controls)
- [ ] Title screen, basic credits
- [ ] Steam Leaderboards integration (daily seed only, no anti-cheat)

**Gate to Phase 5**: Vertical slice success criteria met (see `VERTICAL_SLICE.md`). 5/6 metrics passed. **Quarterly modularity audit passes** (fresh-Claude can add a feature to combat without touching dungeon, loot, or UI).

---

## Phase 5 — Public-facing demo (weeks 17-22)

**Goal**: A polished version of the slice + 1 more class, suitable for showing publicly.

- [ ] Steam page submitted and approved (capsule art, screenshots, trailer cut)
- [ ] Wishlist campaign begins (devlog cadence: 2 posts/week)
- [ ] Second class implemented end-to-end (Wizard — to demonstrate spell-slot system)
- [ ] Polish pass on the slice based on playtest feedback
- [ ] First trailer (60-90 seconds, dice-and-crits showcase)
- [ ] Demo build packaged for Steam Next Fest submission

**Gate to Phase 6**: Steam page live, 5,000+ wishlists, demo accepted into next Steam Next Fest.

---

## Phase 6 — Steam Next Fest (weeks 23-30)

**Goal**: Demo at Steam Next Fest. Massive wishlist push.

- [ ] Demo live during Steam Next Fest week
- [ ] Daily devlog clips on TikTok / X / YouTube Shorts
- [ ] Streamer outreach: 50+ keys to TTRPG-adjacent streamers
- [ ] Discord launched, community moderation set up
- [ ] Live Q&A and feedback collection during fest
- [ ] Post-fest: prioritize feedback, ship demo patch

**Gate to Phase 7**: 15,000-25,000 wishlists. Public sentiment is positive (>80% positive Steam reviews on demo, even if review count is low). **Quarterly modularity audit passes** (month 6).

---

## Phase 7 — Content build-out (months 8-12, bootstrap-mode workflow)

**Goal**: All 12 classes, 6 races (mechanically), and 2 launch biomes implemented. (Biomes 3-4 deferred to post-launch updates per `DECISIONS.md`.)

- [ ] Classes 3-12 implemented (Claude-authored, user-reviewed): Rogue, Cleric, Barbarian, Ranger, Bard, Sorcerer, Warlock, Druid, Paladin, Monk
  - [ ] Druid Wild Shape subsystem (alternate combat mode) — design + implementation buffer
  - [ ] Ranger pet companion subsystem (second controllable actor) — design + implementation buffer
- [ ] Races 2-6 implemented as data + perks: Elf, Dwarf, Halfling, Half-Orc, Tiefling
- [ ] Race differentiation: shared base portraits + ~6 color/accessory overlay layers (~36-48 portrait variants total, NOT 216 unique illustrations)
- [ ] Biome 2 implemented: Sunken Halls + Drowned Empress boss
- [ ] All ~250 abilities authored as `.tres` (Claude-fast; user reviews + cleans icons)
- [ ] All ~80 artifacts authored
- [ ] All ~30 launch-biome monsters authored, AI behaviors
- [ ] DM narration: ~80-100 cues written, parchment overlay system implemented (text-only, no VA)
- [ ] Music: royalty-free curation in `audio/MUSIC_LICENSES.md`; one signature theme commissioned (~$300) and delivered
- [ ] SFX: Freesound CC0 sound bank assembled, custom dice clack recorded
- [ ] Localization-ready: all strings extracted
- [ ] Asset cleanup pass: every shipped portrait/icon/background hand-touched in Krita per `VIBE_CODING.md` workflow
- [ ] **Quarterly modularity audit** at month 9 (end of Q3)
- [ ] **Quarterly modularity audit** at month 12 (end of Q4)
- [ ] **Bootstrap budget reality check** at month 9 and month 12 (spend-to-date vs $5k cap)

**Gate to Phase 8**: All 12 classes built. 2 launch biomes complete. Game playable end-to-end as a complete solo experience. Asset cleanup discipline holding (every shipped asset hand-touched). Bootstrap budget on track.

---

## Phase 8 — Multiplayer build (months 13-16)

**Goal**: Duo mode complete. Ranked ladders live.

(Detailed sub-phases in `MULTIPLAYER.md`. Brief summary here.)

- [ ] GodotSteam integration, lobby system
- [ ] Lockstep command sync, state hash checks
- [ ] Split-party gameplay
- [ ] Duo combat UI, partner inventory view
- [ ] Loot negotiation UI
- [ ] Revive mechanic
- [ ] Backend service deployed (auth, leaderboards, replay validation)
- [ ] Composite ELO calculation
- [ ] Seasonal ranked structure
- [ ] Class-spotlight weekly events
- [ ] Anti-cheat replay validation working

**Gate to Phase 9**: 50+ hours of duo playtesting with no game-breaking desyncs. Leaderboard validation pipeline catches injected fake runs. ELO ranks feel meaningful.

---

## Phase 9 — Closed beta (month 13, in parallel with Phase 8)

**Goal**: Real users play the full game, find bugs, validate balance.

- [ ] ~500 closed beta keys distributed (Discord regulars, demo top players)
- [ ] Telemetry pipeline live, balance dashboards built
- [ ] Daily balance review of class win rates
- [ ] Bug tracker with public visibility
- [ ] Weekly beta builds with patch notes

**Gate to Phase 10**: Class win rates within ±10% of each other in matched-skill brackets. No game-breaking bugs reported in 7 consecutive days.

---

## Phase 10 — Launch prep (months 17-19)

**Goal**: Final polish. Marketing push. Self-publish baseline; publisher partnership only if it materializes on favorable terms.

- [ ] Publisher conversation outcome: signed (target Playstack, Hooded Horse, Future Friends, or equivalent) OR self-publish path locked. Self-publish is the baseline assumption under bootstrap mode.
- [ ] **English-only at launch.** Localization deferred to year 2 post-launch contingent on revenue.
- [ ] Final trailer (1.5-2 minutes, dice-and-crits showcase + duo + ranked)
- [ ] Press kit prepared and distributed
- [ ] Influencer kit + early access keys distributed (free keys, no paid UA budget)
- [ ] Cloud saves verified, achievements live
- [ ] Final QA pass
- [ ] AI-content disclosure on Steam page complete and accurate per Steam policy
- [ ] Public "How this art was made" statement live (project website / Discord)
- [ ] Launch day plan: streamer-watch streams, Discord events

**Gate to Phase 11**: Wishlist count target hit (25k-50k+ realistic under bootstrap-tier production; 50k+ a stretch). No critical bugs. AI disclosure compliant.

---

## Phase 11 — Launch (week of month 18-20, with buffer to month 22)

**Goal**: Ship.

- [ ] Steam launch (PC only)
- [ ] Day 1 patch ready (small fixes only)
- [ ] Live community management — Discord, Steam forums, Reddit
- [ ] Streamer support: keys, schedule for high-profile streams
- [ ] Day 7 retrospective: review sales, reviews, common complaints
- [ ] Active monitoring of AI-disclosure-related review sentiment; respond honestly to questions

**Success metrics (bootstrap-realistic)**:
- 5k-30k copies week 1 under self-publish (higher with publisher partnership)
- >80% positive Steam reviews (AI disclosure may suppress this slightly vs hand-painted indies)
- 200-1k concurrent players in week 1
- Discord >1k members in month 1

**Break-even math** under bootstrap mode: at $14.99 base price and ~70% Steam revenue share after VAT, break-even is around 500-700 copies (covers Steam Direct, domain, AI subscriptions, signature theme commission, LLC overhead). Anything above is profit / reinvestment in post-launch content.

---

## Post-launch (months 19-30)

**Year 1 live operations** (bootstrap-mode cadence):

- **Month 19-20**: Patch cadence weekly. Bug fixing, balance tuning.
- **Month 21-22**: **Free content drop #1 — Biome 3 (The Ember Reach)** with The Forgemaster boss, ~15 new monsters, biome artifacts, narration. Includes one new commissioned theme (~$300) for the biome.
- **Month 24-25**: Smaller free drop — additional artifacts, balance updates, possibly daily seed mode polish, possibly a new game mode (Endless? TBD by community feedback).
- **Month 27-28**: **Free content drop #2 — Biome 4 (The Astral Vault)** with The Architect boss, ~15 new monsters, biome artifacts, narration.
- **Month 30**: Year 2 retrospective. Decide on: paid expansion, sequel concept, sustained free-update mode, or wind-down.

**Console ports**: only via publisher partnership if available. Self-publish console launches are not feasible under bootstrap mode (devkit costs, certification fees). Defer indefinitely.

**Year 2 plans**: TBD based on what year 1 data tells us. Possible: a paid expansion (introducing the cut classes' mechanics in new forms, new biomes), a sequel, a spin-off, or sustained free-update mode. **Localization** funding is a year-2 question — only viable if revenue supports it.

---

## Risks & contingencies

| Risk | Likelihood | Mitigation |
|---|---|---|
| Vertical slice combat doesn't feel fun | Medium | Iterate up to 2 extra months on combat before expanding scope |
| Content production falls behind | High | Cut Druid + Ranger to post-launch (10 launch classes instead of 12); ship the cut classes as the year-1 update cadence alongside biomes |
| Druid Wild Shape or Ranger pet subsystem proves intractable | Medium | Pull the affected class to post-launch immediately; do not absorb the timeline cost |
| Multiplayer is too buggy at month 18 | Medium | Soft-launch duo as a 1.0 free update post-launch; ship solo at month 18-20 |
| AI-content review-bomb on Steam | Medium | Cleanup discipline + transparent disclosure + public process statement. Monitor reviews actively in first 30 days. |
| Wishlists below target | High | Extended demo period, more devlog. Paid marketing not available under bootstrap; lean on free TikTok / dev community channels. |
| Publisher partnership falls through | Medium-High under bootstrap mode | Self-publish on Steam (the baseline assumption); defer console ports indefinitely |
| Solo dev burns out | Medium | Strict 40-hour weeks, mandatory days off, regular playtester contact for motivation. See `RESILIENCE.md` |
| Bootstrap budget breached | Medium | Cut scope, not raise budget. Pivot triggers in `RESILIENCE.md` define the response. |
| Steam tightens AI-content policy mid-development | Low-Medium | Maintain cleanup discipline so assets pass any reasonable disclosure standard. Worst case: rework affected assets. |
| Engine limitation hit | Low | Godot 4 is mature for this scope; very unlikely |

---

## Notes on the timeline

- **18-20 months is the bootstrap-mode target** with strict scope discipline and Claude-assisted development. AAA studios take 3-5 years for similar scope; 12-person indie teams take 2-3 years; solo dev with Claude compresses this further but only if scope holds.
- **22 months is the realistic max** before this becomes "the long Stardew Valley path" of 3-4 years.
- **Anything past 24 months is a red flag** — stop, scope down, ship what you have.

The fastest way to fail is to keep adding "just one more thing." The fastest way to succeed is to ship something tight, then expand post-launch as a live game. The 12-class / 2-biome launch is the **tight-but-marketable** scope chosen specifically to balance the marketing pitch against bootstrap-mode production reality. Cuts from here go to scope, not to budget.
