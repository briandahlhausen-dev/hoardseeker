# ROADMAP.md — Hoardseeker

> Phased plan from project start to launch (months 1-22) and beyond.
> Updated as milestones complete or slip. **Always check current phase before deciding what to work on.**

---

## Status

- **Current phase**: Phase 0 (project setup)
- **Last updated**: project start
- **Target launch**: month 18 (with 4-month buffer to month 22)

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

## Phase 7 — Content build-out (months 8-12)

**Goal**: All 12 classes, 6 races, and all 4 biomes implemented.

- [ ] Classes 3-12 implemented: Rogue, Cleric, Barbarian, Ranger, Bard, Sorcerer, Warlock, Druid, Paladin, Monk
- [ ] Races 2-6 implemented as data + perks: Elf, Dwarf, Halfling, Half-Orc, Tiefling
- [ ] Race portrait variants: 6 races × 12 classes × 3 variants = 216 portraits (largest single art ask)
- [ ] Biomes 2-4 implemented: Sunken Halls, Ember Reach, Astral Vault
- [ ] Bosses 2-4 implemented: Drowned Empress, Forgemaster, Architect
- [ ] All ~250 abilities authored
- [ ] All ~80 artifacts authored
- [ ] All ~60 monsters authored
- [ ] DM narration: voice actor contracted, ~200 lines recorded
- [ ] Composer: contracted, full ~90 minutes of music delivered
- [ ] Localization-ready: all strings extracted
- [ ] **Quarterly modularity audit** at month 9 (end of Q3)
- [ ] **Quarterly modularity audit** at month 12 (end of Q4)

**Gate to Phase 8**: Full content is in. Game is playable end-to-end as a complete solo experience.

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

## Phase 10 — Launch prep (months 17-18)

**Goal**: Final polish. Marketing push. Publisher partnership locked.

- [ ] Publisher contract signed (target: Playstack, Hooded Horse, Future Friends, or equivalent)
- [ ] Localization complete for launch languages (English + ~3 others)
- [ ] Final trailer (1.5-2 minutes, story + class showcase + duo + ranked)
- [ ] Press kit prepared and distributed
- [ ] Influencer kit + early access keys distributed
- [ ] Cloud saves verified, achievements live
- [ ] Final QA pass
- [ ] Launch day plan: streamer-watch streams, Discord events

**Gate to Phase 11**: Wishlist count target hit (50k+). Publisher confirms launch readiness. No critical bugs.

---

## Phase 11 — Launch (week of month 18, with 4-month buffer to month 22)

**Goal**: Ship.

- [ ] Steam launch
- [ ] Day 1 patch ready (small fixes only)
- [ ] Live community management — Discord, Steam forums, Reddit
- [ ] Streamer support: keys, schedule for high-profile streams
- [ ] Day 7 retrospective: review sales, reviews, common complaints

**Success metrics**:
- 25k-100k copies week 1 (depending on wishlist conversion)
- >85% positive Steam reviews
- 1k+ concurrent players in week 1
- Discord >5k members in month 1

---

## Post-launch (months 19-30)

**Year 1 live operations**:

- **Month 19-20**: Patch cadence weekly. Bug fixing, balance tuning.
- **Month 21**: First content update — new class (Artificer or Blood Hunter — community vote). Free.
- **Month 23**: Second content update — new biome (the Twisted Fey or the Outer Plane). Free.
- **Month 25**: Crossover event with another indie roguelike (Balatro-style cosmetic exchange). Free.
- **Month 27**: Third content update — new mode (Endless mode? PvP duels? TBD by community feedback).
- **Month 30**: Major expansion announcement (paid, optional, ~$10).

**Console ports**: months 24-30, via publisher. Switch first (matches the audience), then PS5/Xbox.

**Year 2 plans**: TBD based on what year 1 data tells us. Possible: a sequel, a major expansion, a spin-off, or sustained free-update mode.

---

## Risks & contingencies

| Risk | Likelihood | Mitigation |
|---|---|---|
| Vertical slice combat doesn't feel fun | Medium | Iterate up to 2 extra months on combat before expanding scope |
| Content production falls behind | High | Cut from 12 to 8 classes at launch; ship the rest as free updates |
| Multiplayer is too buggy at month 16 | Medium | Soft-launch duo as a 1.0 free update post-launch; ship solo at month 16-18 |
| Wishlists below target | High | Extended demo period, more devlog, paid marketing as last resort |
| Publisher partnership falls through | Medium | Self-publish on Steam; defer console ports |
| Solo dev burns out | Medium | Strict 40-hour weeks, mandatory days off, regular playtester contact for motivation |
| Engine limitation hit | Low | Godot 4 is mature for this scope; very unlikely |

---

## Notes on the timeline

- **18 months is aggressive but doable** with strict scope discipline and AI-assisted development. AAA studios take 3-5 years for similar scope; 12-person indie teams take 2-3 years; solo dev with AI compresses this further but only if scope holds.
- **22 months is the realistic max** before this becomes "the long Stardew Valley path" of 3-4 years.
- **Anything past 24 months is a red flag** — stop, scope down, ship what you have.

The fastest way to fail is to keep adding "just one more thing." The fastest way to succeed is to ship something tight, then expand post-launch as a live game.
