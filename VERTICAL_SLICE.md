# VERTICAL_SLICE.md — Hoardseeker

> **Goal**: Build the smallest possible thing that proves the game is fun.
> **Timeline**: 4 months.
> **Scope**: 1 class, 1 biome, 1 boss, full run loop, solo only.

---

## What's in the vertical slice

Just enough game to answer one question: **"Does the dice-roll combat feel good?"**

If the answer is yes, we expand to full vision. If the answer is no, we iterate on combat feel until it does — *before* writing more content.

### In scope

- **1 class**: Fighter (chosen because it stress-tests combat without the complexity of spell slots)
- **1 race**: Human (Versatile perk: pick one extra starting ability)
- **1 subclass tier**: 3 subclass options to draft from at floor 5 (Champion, Battle Master, Eldritch Knight)
- **1 biome**: The Forgotten Crypt (10 floors, undead/skeleton theme)
- **1 boss**: The Lich King (final encounter)
- **~12 monsters**: skeletons, zombies, ghouls, wraiths, plus boss
- **~20 abilities**: Fighter's full ability tree across all 3 subclasses
- **~15 artifacts**: enough to show the build-defining variety
- **Combat system**: turn-based, action points, dice rolls, status effects, screen shake on crits
- **Map system**: branching node map (Slay the Spire-style)
- **Loot system**: gold + risk currency, basic shop, artifact rewards
- **Run loop**: roll character → enter dungeon → fight through 10 floors → boss → die or win → unlock screen → run it back
- **Sparse text-only DM narration**: 4 hardcoded narration moments (run start, first crit, boss intro, death/victory) displayed in stylized parchment overlay. No voice acting.
- **Daily seed leaderboard**: Steam Leaderboards integration, Steam-only, no anti-cheat yet
- **Save/load**: in-progress runs survive crashes
- **Settings menu**: audio, visuals, key binds

### Out of scope (deferred)

- 11 other classes
- 5 other races (Elf, Dwarf, Halfling, Half-Orc, Tiefling)
- Other biomes
- Duo mode (architecture supports it, no UI/networking yet)
- Composite ELO (just a high-score leaderboard for now)
- Anti-cheat replay validation
- Custom backend (use Steam Leaderboards for vertical slice)
- Achievements
- Localization
- Console support
- Story / lore / NPCs beyond what's needed for one biome
- Most artifacts (15 of ~80 launch target)
- Most monsters (12 of ~60 launch target)
- Subclass progression past initial draft

---

## The slice's player experience

> Player launches game. Title screen plays a short orchestral cue. They click "New Run."
>
> **Character creation (15 seconds)**: Roll 4d6 drop lowest, six times, for stats. Reroll allowed once. Pick "Fighter" — only class available. Character portrait appears (one of 3 randomized appearances). Name auto-generates ("Aric the Bold") with rename option.
>
> **Parchment overlay reveals** (sparse, ~5 seconds with ink-scratch SFX): *"The Forgotten Crypt has not seen the living for a thousand years. Until tonight."*
>
> **Map view**: Slay the Spire-style branching map. 10 floors. Player picks a path.
>
> **Floor 1**: Combat encounter. 2 skeletons. Combat UI: enemies on right, player on left, abilities along bottom, action points top-left, HP top-right, dice roll display center.
>
> Player picks "Cleave" — costs 2 AP. Dice roll animates large in the screen center: d20. Lands on 18. **Hit.** Damage roll: 2d8 = 11. Screen flashes. Skeleton's HP bar drains. Skeleton crumbles.
>
> Combat continues. Player wins. Reward screen: 15 gold + choice of 3 abilities to add. Player picks "Second Wind."
>
> **Floor 2**: Path choice — combat (gold + ability) or elite (artifact + risk currency). Player picks elite. Hard fight. Player nearly dies. Wins. Artifact: "Ring of Reckless Strength" — +2 damage but -2 AC.
>
> **Floors 3-4**: More combat. Treasure room. A shop (spend gold for abilities, risk currency for artifacts).
>
> **Floor 5**: Subclass draft. Three options presented with full descriptions. Player picks Eldritch Knight. New abilities unlock.
>
> **Floors 6-9**: Harder combat, more interesting builds emerging. Player accumulates 3 artifacts that synergize.
>
> **Floor 10**: Boss approach. **Parchment overlay**: *"The Lich King's bone throne creaks as you enter. He has waited a thousand years for this fight. He hopes you will be more interesting than the last."*
>
> Boss fight. Multiple phases. Player wins with 6 HP.
>
> **Victory screen**: Run summary, score, leaderboard rank. Unlock: Battle Master subclass mastery achievement. New cosmetic background unlocked.
>
> Total time: ~35 minutes. Player clicks "New Run."

If this experience is fun, the game is fun. If it's not, the game isn't.

---

## Build phases (4 months)

### Phase 0: Project setup (week 1)

- Godot 4 project initialized
- Repository structure matches `ARCHITECTURE.md`
- Git initialized, basic .gitignore
- Test runner working (`godot --headless --script tests/test_runner.gd`)
- CI on GitHub Actions running tests on push
- Empty `RNGService`, `GameState`, `Command` base classes scaffolded
- One placeholder test confirming determinism harness works

**Exit criteria**: We can run a no-op simulation headless, write a test, see it pass.

### Phase 1: Combat core (weeks 2-5)

- `GameState`, `PlayerState`, `EncounterState` resources defined
- `Command` base + concrete commands: `AttackCommand`, `MoveCommand`, `EndTurnCommand`, `UseAbilityCommand`
- `CommandProcessor` validates and applies commands, emits events
- `EventLog` accumulates commands and events
- Turn order, action points, HP, AC, basic combat math
- Status effects (burn, stun, advantage/disadvantage)
- 2 abilities working end-to-end ("Slash" and "Cleave")
- 1 monster type (skeleton) with simple AI
- Headless test: scripted fight resolves deterministically

**Exit criteria**: A fight runs to completion in headless mode. Same seed + same commands = same result, every time.

### Phase 2: Combat UI & feel (weeks 6-9)

- 2D combat scene: enemies and player as illustrated cards/portraits
- Dice roll animation (the centerpiece — invest heavily)
- Damage numbers, HP bars, action point pips
- Crit screen shake, sound, particle burst
- Ability bar at bottom of screen, hover tooltips
- Status effect icons
- Sparse audio: dice clack, sword hit, monster death, footstep
- The combat *feels right* test: a non-developer plays a fight and says "that felt good"

**Exit criteria**: Showing the combat to someone makes them want another fight. The crit moment is satisfying.

### Phase 3: Run structure (weeks 10-12)

- Branching map view (Slay the Spire-style nodes)
- Map generation algorithm (deterministic from seed)
- Floor transitions, fade-ins, narration triggers
- Reward screens between fights
- Shop room, elite room, treasure room, rest room
- Gold + risk currency tracked and spent
- Subclass draft at floor 5
- Death screen → unlock screen → main menu loop

**Exit criteria**: A full 10-floor run can be played start to finish. Loops back to a new run.

### Phase 4: Content & polish (weeks 13-16)

- All 20 Fighter abilities authored as `.tres`
- All 15 artifacts authored
- All 12 monsters authored, with AI behaviors
- Boss encounter (Lich King) with phases
- 4 DM narration moments hooked up (text-only parchment overlay; no voice acting per `DECISIONS.md`)
- Save/load mid-run
- Settings menu
- Title screen, credits
- Steam Leaderboards integration (daily seed mode)
- Localization-ready string system (English only at slice, but extracted)

**Exit criteria**: A stranger can launch the game, complete a run, and want to play another.

---

## Hard "no"s for the slice

If you find yourself building any of these in months 1-4, **stop and ask the user**. They're not slice features.

- ❌ A second class
- ❌ Networking, lobbies, duo UI of any kind
- ❌ ELO calculations
- ❌ Custom server backend
- ❌ Content editor tools (build content by hand for the slice)
- ❌ Steam Workshop / mod support
- ❌ Multiple languages
- ❌ A second biome (even a "small" one)
- ❌ Cosmetics, character customization beyond name/portrait
- ❌ Cinematic cutscenes

These are FULL_VISION.md things. Not now.

---

## Soft "yes if cheap"s for the slice

These would be nice if they don't cost more than a few hours each. Skip if they balloon.

- ✅ Steam achievements (5-10 of them)
- ✅ A second appearance for skeletons (variation reads as polish)
- ✅ Different damage numbers for different damage types (visual variety)
- ✅ Background music for combat vs map
- ✅ A simple options menu

---

## Success metrics for the slice

Before expanding to full vision, the slice should hit these:

1. **The combat feel test**: a non-developer plays 2 fights and is engaged the whole time.
2. **Replayability test**: a tester completes a run, then chooses to start another *unprompted*.
3. **The crit test**: a tester reacts visibly to their first crit (laugh, lean in, "ohhh").
4. **The build test**: by floor 8, the player describes their character with words like "tanky" or "burst" or "dodgy" — meaning the artifacts and abilities are creating a build identity.
5. **The determinism test**: replaying the event log produces an identical end state. 100% pass rate.
6. **The framerate test**: 60 FPS minimum on a 5-year-old laptop.

If we hit 5/6, we expand. If we miss any, we iterate on the slice.

---

## What we tell people about the slice

We **don't** publicly release the vertical slice. It's an internal milestone.

External-facing milestones come later:
- **Public demo** (month 5-6): Polished version of the slice + 1 more class.
- **Steam Next Fest demo** (month 7-9, depending on schedule): 2 classes, 1 biome, time-limited.
- **Closed beta** (month 13): Friends + Discord regulars, full content.
- **Public launch** (month 16-22): Full game.

The slice is for us, to know if we have something. Don't show it.
