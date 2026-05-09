# FULL_VISION.md — Hoardseeker

> The complete launch vision. Everything in `VERTICAL_SLICE.md` first, then this expands outward.
> Reference document — read for context, do not treat as a build checklist.

---

## The launch product

**Hoardseeker 1.0** ships under bootstrap-mode production (<$5k total project budget). The launch is intentionally tight; biomes 3-4 ship as free post-launch updates over year 1-2.

- **12 classes**, each mechanically distinct (full roster, no cuts)
- **3 subclass options per class** (36 total)
- **~250 abilities** across all classes
- **2 themed biomes at launch**: The Forgotten Crypt (floors 1-10) + The Sunken Halls (floors 11-20). Each with a unique boss.
- **~80 artifacts** that meaningfully change builds
- **~30 monster types** across the two launch biomes, plus 2 bosses (Lich King, Drowned Empress)
- **Solo mode + Duo mode**, both fully featured at launch
- **Ranked seasonal ladders**: separate solo + duo, composite ELO, 2-3 month seasons
- **Daily seed runs**: solo and duo, separate leaderboards
- **Sparse text-only DM narration** at ~80-100 trigger moments (parchment overlay, no voice acting)
- **Curated soundtrack**: royalty-free orchestral (Kevin MacLeod, FreePD, Pixabay Music, Tabletop Audio) + one commissioned signature theme for title/boss
- **Full save/load**, including mid-run cloud saves on Steam
- **English at launch**, with localization-ready architecture for major languages in year 2

**Free post-launch content drops** (year 1-2):
- **Biome 3**: The Ember Reach (floors 21-30) + The Forgemaster boss
- **Biome 4**: The Astral Vault (floors 31-40) + The Architect boss
- Additional artifacts, monsters, narration moments, and balance updates per drop
- Possibly: seasonal class-spotlight events, crossover cosmetics, new game modes

---

## The 12 classes

Each class is mechanically distinct enough that someone who likes one might not like another. Diversity is the goal.

| Class | Core fantasy | Core mechanic | Resource | Difficulty |
|---|---|---|---|---|
| **Fighter** | Reliable martial powerhouse | Big weapon, big numbers | Action points only | Easy |
| **Wizard** | Spellslinger | Slot-based magic, prepared spells | Spell slots | Medium |
| **Rogue** | Burst damage, evasion | Sneak attack, advantage exploitation | AP + cunning points | Medium |
| **Cleric** | Heals + smites | Channel divinity, holy spell list | Spell slots | Medium |
| **Barbarian** | Raging melee | HP-as-resource, low AC high damage | Rage charges | Easy |
| **Ranger** | Bows, beasts, terrain | Companion pet, ranged DPS | AP + favored enemy bonuses | Medium |
| **Bard** | Buffs, control, support | Inspiration dice given to allies | Bardic inspiration | Hard |
| **Sorcerer** | Wild magic chaos | Spell slots + metamagic on cards | Slots + sorcery points | Hard |
| **Warlock** | Pact magic | Few but powerful spells, recharge on rest | Pact slots | Medium |
| **Druid** | Shapeshifter | Wild Shape into beast forms with own HP | Druidic charges | Hard |
| **Paladin** | Smite-stacker | Burn slots for nova damage | Spell slots + smite | Easy |
| **Monk** | Combo striker | Multi-hit chains, stunning strike | Ki points | Hard |

Difficulty rating reflects mechanical complexity, not power. New players will be funneled toward Fighter / Barbarian / Paladin in tutorialization. Hard classes are unlocked progressively.

### Per-class subclass design

Each class has 3 subclasses that radically change playstyle. Examples:

- **Fighter**: Champion (crit-fishing), Battle Master (tactical maneuvers), Eldritch Knight (sword + spell)
- **Wizard**: Evocation (raw damage), Abjuration (defensive shields), Illusion (control + misdirection)
- **Rogue**: Thief (loot + utility), Assassin (alpha-strike), Arcane Trickster (spell + sneak)
- *...and so on for all 12.*

Subclass is drafted around floor 5 of every run, which is when the player has enough run-context to make a meaningful choice.

---

## The 6 races

Race is picked alongside class at character creation, locked for the run. Each race grants small stat bumps (closer to D&D feel) plus a signature mechanical perk. Stat bumps are intentionally small (+1 in 1-2 stats) so race never invalidates class fantasy — a Halfling Barbarian is still a Barbarian, just *also* lucky.

| Race | Stat bumps | Signature perk | Difficulty fit |
|---|---|---|---|
| **Human** | +1 to all stats | **Versatile** — start with one extra ability of choice from your class's pool. | Any class |
| **Elf** | +2 DEX, +1 INT | **Keen Senses** — advantage on initiative; immune to sleep and charm. | Wizard, Ranger, Rogue |
| **Dwarf** | +2 CON, +1 STR | **Stout** — +2 max HP per floor cleared; resistance to poison damage. | Fighter, Cleric, Barbarian |
| **Halfling** | +2 DEX, +1 CHA | **Lucky** — once per fight, reroll a natural 1. | Rogue, Bard, Ranger |
| **Half-Orc** | +2 STR, +1 CON | **Savage Attacks** — crits roll one extra damage die. | Barbarian, Fighter, Paladin |
| **Tiefling** | +2 CHA, +1 INT | **Infernal Heritage** — start with one free fire spell; resistance to fire damage. | Sorcerer, Warlock, Wizard |

### Why these 6 (and not 8)

We curated to maximize mechanical distinctness while keeping art / balance load reasonable. The 2 races we cut from the proposed roster:

- **Gnome** — overlapped mechanically with Halfling. Could return as a free post-launch update if the community asks.
- **Dragonborn** — breath weapon mechanic is cool but visually expensive (each color has a different breath, suggests sub-races, suggests visual variants). Better as a paid expansion.

### Race-class synergy

The "fit" column is a hint, not a restriction. Any race + any class is playable. But some pairings unlock latent build space:

- **Halfling Rogue**: Lucky perk + sneak attack reroll = absurd consistency.
- **Dwarf Cleric**: Stout perk + Cleric heals = late-game tank stacking.
- **Tiefling Sorcerer**: Infernal Heritage's free fire spell + Sorcerer wild magic = chaos spec.
- **Human anything**: extra ability of choice means human mains play "the build I dreamed of."
- **Half-Orc Barbarian**: more crit dice on rage attacks. The "I crit for half their HP" build.
- **Elf Wizard**: advantage on initiative = cast first, end fights before they start.

These synergies are intentional. They give per-race "best build" guides that streamers and content creators will write, generating organic marketing.

### What doesn't change with race

- No race-locked classes.
- No race-locked artifacts.
- No race-locked dialogue or content paths.
- No race-locked subclasses.

Race is an expressive layer on top of class, not a parallel content gate.

### Race art at launch (revised for bootstrap mode)

Under bootstrap-mode production (AI gen + hand cleanup, no contracted illustrator), the original 216-portrait plan isn't feasible. The current approach uses **shared base portraits per class** with **race differentiation via color palette swaps + small accessory/silhouette tweaks**, not unique illustrations per race × class.

- **Slice**: Human only. 3 portrait variants for the Fighter (the only slice class).
- **Demo**: Human + 2 others (Dwarf + Half-Orc — most visually distinct via accessories/silhouette). Fighter + Wizard with palette/accessory variants.
- **Launch**: 12 base class portraits + 6 race color palettes / accessory layers = ~36-48 portrait variants total (versus the original 216 plan).

Race differentiation reads through:
- Color palette overlays (skin tone, hair color)
- Accessory swaps (Dwarf braid beads, Tiefling horns, Halfling smaller frame, Half-Orc tusks)
- Subtle silhouette tweaks (size class for Halflings, posture cues)

Per-race fully unique portraits become a possible **post-launch art polish pass** if revenue allows it. This is a deliberate trade: launch quality over launch quantity. Players still see meaningfully distinct races; we just don't illustrate every combination from scratch.

---

## Biomes — 2 at launch, 2 in post-launch updates

Each biome has a distinct visual identity, monster roster, and boss. Each *run* takes you through biomes via a branching map, with biome bosses gating progression. Like Hades' chambers structure but with branching choices within each biome.

### Launch biomes (2)

| Biome | Floors | Theme | Monster archetypes | Boss |
|---|---|---|---|---|
| **The Forgotten Crypt** | 1-10 | Undead, dark stone, candlelight | Skeletons, zombies, ghouls, wraiths | The Lich King |
| **The Sunken Halls** | 11-20 | Flooded ruins, blue-green light, kelp | Sahuagin, drowned ones, sea hags, krakenkin | The Drowned Empress |

A "complete run" at launch goes through both biomes — ~70 minutes for a full successful run, well within roguelike norms. Most players die in the Crypt early on. Reaching the Drowned Empress is the late-game brag at launch.

### Post-launch biomes (free content updates, year 1-2)

| Biome | Floors | Theme | Monster archetypes | Boss | Target ship |
|---|---|---|---|---|---|
| **The Ember Reach** | 21-30 | Lava caves, dwarven forges | Fire elementals, dwarven undead, salamanders, devils | The Forgemaster | Year 1 |
| **The Astral Vault** | 31-40 | Floating platforms, starfields, geometry | Astral constructs, illithids, beholders, githyanki | The Architect | Year 1-2 |

These ship as free updates and become the major Year 1 content cadence. Each adds 10 floors, ~15 monsters, 1 boss, biome-specific artifacts, and additional narration moments. Reaching the Architect post-launch becomes the eventual late-game brag.

**Why this split**: under bootstrap mode, shipping 2 biomes at launch keeps the art and balance load tractable for a solo developer using AI generation + hand cleanup. Biomes 3-4 are the most visually expensive (Ember Reach's lava lighting, Astral Vault's geometric otherworldliness), making them the right candidates to defer until launch revenue / production rhythm is established.

---

## Combat in detail

### Action economy

- Each turn, the active actor has **3 Action Points**.
- Abilities cost AP (most cost 1-2, big abilities cost 3, ultimates cost more).
- Movement, repositioning, item use also cost AP.
- Enemies have their own AP budgets, varying by type.
- Initiative is rolled once at fight start: d20 + Dex modifier. Higher goes first.

### Dice rolls

Every attack:
1. **Attack roll**: d20 + ability modifier vs. target's AC. Crit on natural 20, fumble on natural 1.
2. **Damage roll**: weapon/spell dice (e.g., 2d6 for a longsword), modifiers added.
3. **Crit doubles damage dice** (rolled twice, not multiplied). Big number, screen shake.

Every save:
1. **Save roll**: d20 + relevant save modifier vs. ability DC.
2. Failure applies effect; success negates or halves.

### Status effects

A short, curated list (10-12 total). Examples:
- **Burn**: 1d4 damage at start of turn, lasts 3 turns.
- **Stun**: skip next turn.
- **Bleed**: 1d6 damage when target moves or attacks.
- **Bless**: +1d4 to attack rolls.
- **Curse**: -2 to all rolls.
- **Advantage / Disadvantage**: roll twice, take higher / lower.

Status effects stack additively where it makes sense, and are part of the build. ("Burn-stack" is a real strategy.)

### Positioning (abstract, no grid)

Slay-the-Spire-style: front row vs. back row. Some abilities only target front. Some pull/push enemies between rows. No movement grid; positioning is a tactical layer, not a logistics puzzle.

---

## Artifacts (curated, ~80 at launch)

Artifacts are the run's identity. Each is distinct, build-defining, and worth talking about.

Three rarity tiers, drop rates and effects scaling appropriately:

- **Common (~40)**: Flat numerical buffs. *"Belt of Strength: +1 STR."*
- **Rare (~30)**: Mechanical changes. *"Crown of Glass: When you crit, all enemies take half the damage you dealt."*
- **Mythic (~10)**: Build-defining. *"The Lich's Heart: You die at -10 HP instead of 0, but you can't be healed above half max HP."*

Mythic artifacts are run-makers. A run with one feels different from a run without.

Artifacts are class-agnostic — any class can pick up any artifact — but some artifacts strongly favor certain classes. This is intentional: it creates "I rolled the Wizard run of my life" moments.

### The risk currency

A second currency, "Glints," earned from optional hard encounters (elites and risk rooms). Spent only at special shrine rooms for:
- Mythic artifact rerolls
- Subclass-specific upgrades
- Curse removal
- Re-rolling stats mid-run (rare, costly)

Glints exist to make the elite/risk path feel rewarding. A "no-Glints" run is doable but harder.

---

## Duo mode

(See `MULTIPLAYER.md` for full networking architecture. This is the design summary.)

### What changes in duo

- **Two players, two characters**, one shared dungeon.
- **Split-party mechanic**: at certain map nodes, the path branches into two simultaneous rooms. Each player resolves their own room, then the party rejoins. This creates "I'll handle the elite, you grab the shop" moments.
- **Combat**: when in the same room, alternating turns. When in different rooms, parallel resolution.
- **Loot**: shared pool. Players negotiate. UI shows both inventories.
- **Revives**: a downed player can be revived by their partner via a "Revive" action that costs full AP and uses one Glint.
- **Run ends** when both players are dead simultaneously. A solo player can finish a run their partner died in (reduced score).

### Duo-specific design

- **Class synergies**: some classes pair beautifully (Cleric+Fighter, Wizard+Rogue). Some are challenging (two Barbarians = high damage, no healing).
- **Per-pair leaderboards** are weekly events, not a permanent fixture. Permanent ranked is just "Duo overall."
- **Reconnect-tolerant**: if a partner drops, the run pauses and waits 5 minutes for them to reconnect. After that, the remaining player can solo-continue or end the run.

---

## The ranked system

### Composite ELO

Rating change after a run is computed from multiple factors, not just win/loss. Inputs:

- **Floors reached** (most weight): you score even on losses if you went deep
- **Score** (Glints earned, monsters slain, artifacts collected, time bonuses)
- **Run quality** (consistent crits, no deaths in duo, etc.)
- **Difficulty modifier**: Glints per encounter completed, biome of death

Each run produces a delta: `+25` for a strong performance, `-10` for a quick death. Players' ratings climb or fall over many runs.

### Seasonal structure

- **Seasons last ~10-12 weeks.**
- At season end: rank resets to a soft floor (you keep ~half your distance from the floor, à la League of Legends).
- Top 100 finishers per season earn a cosmetic flair (run banner, profile frame).
- Daily seed runs continue between seasons; only the ladder resets.

### Anti-cheat

Server-side replay validation. Every leaderboard submission is `(seed, command_log)`. The server replays it, confirms the score, and either accepts or rejects. A cheater can't lie about their score because the math has to add up. See `ARCHITECTURE.md` and `MULTIPLAYER.md`.

### Class-spotlight events (weekly)

Every week, one class gets a temporary leaderboard. Top finishers get a class-specific cosmetic. This drives engagement with classes the player might not otherwise pick.

---

## Story & narration

### Framing story

You're an adventurer. The Hoardseeker's Guild has marked the dungeon as a target. You go in. You loot. You die. You go in again. Other adventurers are doing the same — that's the leaderboard.

Minimal NPCs. A guild master who greets you on the title screen. A merchant who appears in shops. A mysterious figure who hints at the dungeon's deeper purpose (lore drips out over many runs, never explicit).

### Narration system

**All narration is text-only.** No voice acting in shipped product, ever (including post-launch updates). The DM speaks through stylized parchment overlays at trigger moments, with subtle SFX (parchment unfurl, ink scratch, brief musical sting) carrying the atmospheric weight a voice would otherwise.

~80-100 narration cues across the launch product (reduced from original 200 because text writing is faster than VO production). Triggers:

- **Run start** (varies by class): "*The Wizard descends, spells crackling at her fingertips.*"
- **First crit of a run**: "*A perfect strike.*"
- **Boss intros** (one per boss, ~50-100 words each)
- **Death** (varies by death type)
- **First-time mythic artifact pickup** (per artifact)
- **Comeback save** (revived from <5 HP)
- **Long combo chains** (3+ crits in a row)

Tone: sparse, dry, occasionally cruel. Bastion / Hades / classic D&D DM in feel — but read, not heard. Slay the Spire is the precedent: text-only narrative content, players love it.

### What we don't do

- Voice acting of any kind in shipped product (text only, forever)
- Long cutscenes
- Fully voiced character dialogue
- Branching narrative
- Player-name acknowledgement

---

## Audio direction

- **Music** — curated royalty-free orchestral with one commissioned signature theme:
  - Primary library curated from Kevin MacLeod (incompetech.com), FreePD (CC0), Pixabay Music, Tabletop Audio commercial-licensed tracks.
  - One signature theme commissioned (~$300, music school student or AirGigs lower tier) for title screen / boss intro.
  - Per-track licenses tracked in `audio/MUSIC_LICENSES.md`. Attribution provided in credits where required.
  - AI-generated music is not used in shipped product (per the revised AI-content rule).
- **SFX** — Freesound CC0 + custom dice recording:
  - Dice rolls (the centerpiece — multiple variations, custom recorded with phone + Audacity, $0).
  - Sword hits, magic crackles, monster vocals, parchment rustles, gold clinks. ~150 SFX total, sourced from Freesound.org (CC0 only, license-verified per file in `audio/SFX_LICENSES.md`).
- **Mix**: audio is loud and present. Crits hit hard. The dice are loud. Music ducks for narration overlays.
- **Total audio budget**: ~$300-400 (one commissioned theme + buffer). The commissioned theme is the only paid audio asset.

---

## Visual direction

- **Stylized 2D illustration with sourcebook tone.** Pen-and-ink linework, parchment textures, restrained painted shading. Inscryption-adjacent in tonal weight, but warmer and more D&D-flavored. Not painted realism. Not pixel art. Not cartoon.
- **Production model**: AI generation (Midjourney or local Stable Diffusion) + mandatory hand cleanup in Krita / Photopea. Every shipped asset gets hand-touched. The cleanup is what determines final quality, not the prompt. See `VIBE_CODING.md` for the full workflow + revised AI-content rule.
- **Asset count at launch** (substantially reduced from original spec via the 2-biome cut + race differentiation via palette/accessory swaps):
  - ~36 character portraits (12 classes × shared base + race color/accessory variants — not unique per race × class)
  - ~30 monster portraits (2 launch biomes only)
  - ~80 artifact icons
  - ~250 ability icons
  - ~10 environment backgrounds (2 biomes × 5 room types)
  - Full UI set (parchment-and-ink theme)
- **Cleanup workload**: ~275 hours total across the project, spread over 18-20 months at ~15 hrs/month. Inside the 40-hour weekly cap with margin.
- **Animations**: Simple skeletal animation or sprite swaps for combat actions. Deliberate, weighty, like a card game with movement. No fully animated characters at launch.
- **UI**: Parchment-and-ink. Ornate frames. Calligraphic fonts for headers, readable serif for body text. Wax seals as buttons. Hand-drawn flourishes.
- **AI disclosure**: Steam store page discloses AI-generated content per Steam's required field. Public "How this art was made" statement on the project website / Discord. Transparency is part of the deal, not a fallback.

---

## Monetization

- **Premium**: $14.99-19.99 base price at launch (final pricing decided ~month 14 based on demo reception and bootstrap-tier production reality; lower end is more likely).
- **No microtransactions, no battle pass, no loot boxes.** Period.
- **Cosmetic DLC** acceptable in year 2 if production is sustainable. Class skin packs, biome retextures. Cosmetic only — never gameplay-affecting. (Narrator voice packs explicitly excluded — text-only narration is permanent per `DECISIONS.md`.)
- **Free content updates** in year 1-2: the planned post-launch biome drops (Ember Reach, then Astral Vault) plus modes / events. This is the "Friends of Jimbo" pattern from Balatro.

---

## Live operations (year 1+)

After launch, sustained engagement comes from:

- **The planned biome drops**: Ember Reach (year 1) and Astral Vault (year 1-2) are the headline free content updates. Each adds 10 floors, ~15 monsters, 1 boss, biome-specific artifacts, and additional narration moments.
- **Weekly class-spotlight leaderboards** (rotating across all 12 classes, automatic)
- **Seasonal ranked resets** (every 10-12 weeks)
- **Daily seed challenges** (always-on)
- **Smaller content drops** between biomes (new artifacts, balance updates, additional mythic items)
- **Crossover events** with other indie games (Balatro-style — free cosmetics from partner games), if opportunities arise
- **Community events** (custom seed contests, fan art competitions)

The live ops cadence is the difference between a one-and-done indie hit and a long-tail success. Bootstrap-mode launch keeps the year-1 update budget in the $0-300/month range (one composer commission per major drop is the only meaningful expense).
