# VISION.md — Hoardseeker

## The pitch (one sentence)

*A D&D-inspired roguelike deckbuilder where every action is a dice roll, playable solo or with one trusted partner, with ranked seasonal ladders for both modes.*

## The 30-second hook

You roll a character. You pick a class — Fighter, Wizard, Rogue, Cleric, twelve in total. You pick a race — Human, Elf, Dwarf, Halfling, Half-Orc, Tiefling, six in total. You enter a branching dungeon, fighting through themed biomes. Every attack, save, and skill check is a visible dice roll. Crits shake the screen. Mid-run, you draft a subclass that defines your build. You collect curated artifacts that completely change how your class plays. You die in 30-45 minutes. You unlock something new. You run it back.

Or you bring a partner. The dungeon splits you sometimes — you're in different rooms, fighting different fights, and you have to regroup. If they go down, you can revive them. The loot is shared, and you negotiate. Your duo has its own ranked rating, separate from your solo rating. Climbing the ladder with the same partner builds a real partnership.

## Why this works

The success patterns from solo-developer breakouts are clear: **one strong verb, familiar genre frame, deep replayability, streamable hook, auteur aesthetic.** Hoardseeker hits all five.

- **The verb is "roll."** Every dice roll is the marketing.
- **The frame is "D&D roguelike."** Instantly understood by tens of millions of TTRPG-adjacent players.
- **Replayability is built-in:** 12 classes × subclasses × artifact combos × duo pairs.
- **Streamable:** crits, near-deaths, clutch revives, comeback runs.
- **Auteur aesthetic:** stylized 2D illustration with sourcebook tone, parchment UI, curated orchestral mood. Cohesive and ownable on a bootstrap budget.

## Who we're building for

**Primary**: TTRPG-adjacent players who watch Critical Role / Dimension 20, played BG3, like Slay the Spire, and want a fast roguelike with that same flavor.

**Secondary**: Roguelike deckbuilder fans (Slay the Spire, Balatro, Inscryption players) looking for the next addiction.

**Tertiary**: Co-op players who want a turn-based experience to play with a single trusted friend (the duo audience underserved between solo roguelikes and 4-player co-op).

## Design pillars

These are the values every design decision is measured against. If a feature doesn't serve at least one pillar, cut it.

1. **The dice are the star.** Every important moment is a roll. The animation, the screen shake, the sound — these get more polish than anything else.
2. **Class fantasy first, balance second.** A Wizard should *feel* like a Wizard before they're balanced against a Rogue. Power fantasy beats math.
3. **Every run tells a story.** Subclasses, artifacts, and emergent moments mean two runs of the same class play differently. The player should be able to describe their last run in one sentence ("I was a fire-Wizard who got the Crown of Glass and one-shot the boss").
4. **Duo is partnership, not parallel play.** Splitting the party, sharing loot, reviving — the design forces *interaction*. If duo could work as two side-by-side single-player games, we did it wrong.
5. **The ladder matters.** Seasonal resets, composite ELO, separate solo and duo ranks. Climbing has weight. The leaderboard is a reason to come back, not an afterthought.
6. **Tight scope shipping > big vision languishing.** We ship the small thing, then expand. Cut everything that doesn't serve the launch loop.

## Tone & aesthetic

- **Visual**: Stylized 2D illustration with a tabletop-sourcebook feel. Pen-and-ink linework, parchment textures, restrained painted shading. Inscryption-adjacent in tonal weight, but warmer and more D&D-flavored. Production model is AI generation + mandatory hand cleanup; quality lives in the cleanup, not the prompt. Parchment-and-ink UI. Saturated but not garish.
- **Audio**: Orchestral fantasy curated from royalty-free sources (Kevin MacLeod, FreePD, Pixabay Music, Tabletop Audio) with one commissioned signature theme for title screen / boss. The "playing D&D in a candle-lit room" mood, not a 90-minute original score. Diegetic sounds — clinking gold, dice on wood, rustling parchment — carry most of the audio identity.
- **Narration**: Sparse text-only DM narration. Boss intros, deaths, major artifact pickups, run-ending moments. Never on routine actions. The narrator is *written*, not voiced — appearing in a stylized parchment overlay with subtle SFX (parchment unfurl, ink scratch). Voice should feel like a dungeon master at a real table — wry, knowing, occasionally cruel — but the player reads, not listens.
- **Tone**: Teen rating. Classic D&D. There's blood when things die. Skeletons, undead, dark caves. But not Darkest Dungeon grim — there's also tavern warmth, treasure-glow, the joy of a perfect crit.
- **Writing**: Light framing story (you're an adventurer, the dungeon needs clearing). Dialogue is short, evocative, slightly archaic without being parodic. Never breaks the fourth wall.

## What success looks like

- **Vertical slice (month 4)**: 1 class, 1 biome, 1 boss, full loop. We know if the core feel is fun.
- **Steam page live (month 5)**: First trailer cut. Devlog cadence established.
- **Steam Next Fest demo (month 6-9, depending on schedule)**: 2 classes, 1 biome. Target 15,000+ wishlists during fest.
- **Pre-launch (month 14)**: 25,000-50,000+ wishlists. Self-publish on Steam baseline; publisher partnership only if it materializes on favorable terms.
- **Launch (month 18-20)**: 12 classes, 2 biomes (Forgotten Crypt + Sunken Halls), solo + duo modes, ranked ladders live. Realistic week-1: 5,000-30,000 copies under bootstrap-mode self-publish; higher with publisher partnership.
- **Year 1-2 free updates**: Biome 3 (Ember Reach) and Biome 4 (Astral Vault) ship as free content drops. Plus seasonal events, class-spotlight ladders. Console ports only via publisher partnership if available.

## What failure looks like (and how we avoid it)

- **Failure mode 1: Scope creep kills the launch.** → Strict feature gates. Vertical slice first. Cut classes from launch roster if needed (6 polished beats 12 mediocre).
- **Failure mode 2: Duo mode is too hard to build, ships broken.** → Architect for duo from day one (deterministic + command-pattern), but soft-launch duo as 1.0 if needed and scope it down to one biome co-op if necessary.
- **Failure mode 3: No audience at launch.** → Devlog from month 5. TikTok-friendly clips of crits, near-deaths, big artifacts. Steam Next Fest demo. Publisher partnership for PR reach.
- **Failure mode 4: Balance is unplayable with 12 classes × subclasses.** → Data-driven balance. Configs over code. Telemetry from demo onwards. Public balance changelog.
- **Failure mode 5: Cheaters ruin the ranked ladder.** → Deterministic replay validation server-side. Every leaderboard run is verifiable.

## The one-paragraph identity

Hoardseeker is the roguelike deckbuilder for everyone who's ever wished a Slay the Spire run felt like a real D&D session. It's fast, dice-driven, and ruthless. You can play alone or with one friend, and either way there's a ladder to climb. It looks like a tabletop sourcebook brought to life and sounds like a candle-lit table at midnight. It's built by one person with AI assistance under a strict bootstrap budget, designed to be the kind of game streamers play for hundreds of hours and that fills a Discord with people sharing their wildest runs.
