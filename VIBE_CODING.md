# VIBE_CODING.md — Hoardseeker

> **The most important document in this project.**
> You are a non-technical solo developer building an ambitious game with AI assistance. This file is how you don't fail.
> Read this before every work session, alongside `CLAUDE.md`.

---

## Who you are

- Zero coding experience.
- Zero game development experience.
- Building Hoardseeker over ~18-22 months with Claude Code as your primary engineer.

This is not a disadvantage if you're disciplined. It is a catastrophic disadvantage if you aren't. The discipline rules in this document are how you bridge the gap.

**The core insight**: You are the *director*, not the engineer. Your job is to know what you want, hold the vision, taste-test the result, and refuse to let scope or quality drift. Claude Code's job is to translate that into working software.

If you ever find yourself trying to *understand the code line by line*, you've made a wrong turn. You don't need to. You need to understand:

1. What it's *supposed* to do (the design docs).
2. Whether it actually does that (the tests + your playtesting).
3. Whether you can change it later without breaking everything (modularity audits).

Everything else is Claude Code's problem.

---

## How vibe coding actually works (the loop)

This is the workflow for every feature, every change, every session:

### 1. State the goal in plain English

Open Claude Code. Tell it what you want, in your own words. Reference the docs. Examples:

- ✅ *"I want to add the Fighter's Cleave ability per the spec in CONTENT.md. Make sure it follows the command pattern in ARCHITECTURE.md."*
- ❌ *"Implement a 2-AP ability that does damage to two adjacent enemies."*

The first version gives Claude the docs as context. The second version is you doing engineering work you don't need to do.

### 2. Let Claude propose before it builds

Always ask: **"Walk me through what you'd do, before you do it."** Claude Code will outline the plan. Read it. If it sounds wrong, push back. If it sounds right, say "go ahead."

This catches 80% of mistakes before they become code you have to undo.

### 3. Verify with the tests, not the eyeballs

After Claude implements something, ask: **"Run the tests. Did everything pass? Did you add new tests for this feature?"**

You don't need to read the test code. You need to confirm:
- The feature has tests (Claude wrote them).
- All tests pass (the green light).
- The CI is green on the next push.

If something fails, the workflow is: **"Tests are failing on X. Fix it without breaking anything else, and explain what went wrong in plain English."** You don't debug. Claude does.

### 4. Playtest the change yourself

After every meaningful feature, *play the game*. Even if it's just one fight. Your taste is the only thing keeping the design honest. The dice should feel good. The crits should pop. The combat should feel like D&D.

If it doesn't feel right, say so. **"The dice roll animation feels too slow. Make it punchier."** That's a valid engineering instruction.

### 5. Commit and document

Every working session ends with: **"Commit this with a message explaining the intent. Update DECISIONS.md if we made any new design choices. Update VIBE_CODING.md if we discovered something about our workflow."**

Documentation is not optional. The docs are how future-Claude understands the project. If they go stale, you're flying blind.

---

## The non-negotiable discipline rules

Break these and the project fails. They are inviolable.

### Rule 1: Never write code yourself

You are not an engineer. If you find yourself typing into a `.gd` file, stop. Ask Claude Code to do it. The one exception: copy-pasting between files at Claude's instruction.

This isn't about capability — it's about consistency. The codebase has rules. You don't know them. Claude does. Stay in your lane.

### Rule 2: Never commit code you don't understand the *purpose* of

You don't need to understand the code. You need to understand what it does for the game. Before every commit, ask: **"In one sentence, what does this change do for the player?"**

If Claude can't answer that clearly, the change isn't ready. If you don't accept the answer, the change isn't ready.

### Rule 3: Never let Claude do something irreversible without confirming

Ask Claude Code to **always confirm before**:
- Deleting files
- Force-pushing to git
- Resetting branches
- Running database migrations
- Submitting builds to Steam
- Recording paid voice / music sessions

When you set up Claude Code, your first instruction is: *"Never perform irreversible actions without my explicit yes-let's-do-it confirmation. List the action and wait."*

### Rule 4: Always work on a branch

Claude Code should never commit directly to `main`. Every feature is a branch. Every branch gets reviewed (by Claude itself, before you merge). This is your safety net — if something is broken, you delete the branch and start over.

You don't need to know git. You need to say: **"Make a branch for this work, push to that branch, and tell me when it's ready to merge."**

### Rule 5: Tests are the contract

Every feature ships with tests. No exceptions. **"Build feature X *and* tests for X"** is one task, not two. If Claude tries to ship a feature without tests, push back: *"Where are the tests?"*

This is what keeps the project alive at month 12 when you've forgotten how the combat system worked at month 3. The tests prove the system still works.

### Rule 6: Modularity is sacred

Every system in the codebase must pass the **fresh-Claude test**: a new Claude Code session, given only the design docs and that one module's interface, can modify the module without reading the rest of the codebase.

If it can't, the module is too coupled and needs refactoring.

You enforce this with quarterly audits (see "Audits" section below).

### Rule 7: When in doubt, scope down

Every time you're tempted to add something, ask: **"Does this serve the launch loop, or am I dreaming?"** If it's dreaming, write it down in `IDEAS.md` (a future file we'll create) and do not build it.

The graveyard of indie games is full of features that "would be cool." Yours isn't going to be one of them.

---

## Your tool stack

Decisions you'll need to make, with deadlines so you have time to research and choose.

### Already decided

| Tool | Why | Cost |
|---|---|---|
| **Godot 4** | Game engine | Free |
| **Claude Code** | Primary engineer | Subscription you already have |
| **GDScript** | Programming language | Built into Godot |
| **GitHub** | Code repository + CI | Free for private repos |

### Decide by month 1

Set these up before any serious code is written.

| Decision | Options | Notes |
|---|---|---|
| **Code editor** | VS Code (recommended), Cursor, Zed | Pick whichever Claude Code integrates with most cleanly. |
| **Project tracker** | Linear, Notion, GitHub Projects, plain Markdown | Doesn't matter much; pick one and stick with it. |
| **Backup strategy** | Automatic GitHub + cloud drive sync of `/docs` and `/assets` | Non-negotiable. Set this up *now*. |
| **Devlog platform(s)** | Twitter/X, TikTok, YouTube Shorts, Bluesky, dev blog | You don't need all. Pick 1-2 and post weekly starting month 5. |

### Decide by month 3

These come into play when you start producing visible content.

| Decision | Options | Cost ballpark | Notes |
|---|---|---|---|
| **Concept art tool** | Midjourney, Stable Diffusion (ComfyUI), DALL-E 3, Adobe Firefly | $10-30/mo | Used for placeholder art, mood boards, illustrator references. Not for final art. |
| **Image cleanup** | Photoshop, Affinity Photo, Photopea (free) | $0-20/mo | For touching up AI-generated concept art. Photopea is free and runs in browser. |
| **Music prototyping** | Suno, Udio | $10-30/mo | For prototype tracks before hiring a composer. Never ship AI music as final. |
| **SFX library** | Freesound.org (free, attribution), Soundsnap, ElevenLabs Sound Effects | $0-30/mo | Most SFX can be free. Custom dice sounds = recording session, ~$200. |

### Decide by month 5

When you go public with a Steam page.

| Decision | Options | Cost | Notes |
|---|---|---|---|
| **Steam Direct fee** | One-time $100 per game | $100 | Required to publish on Steam. Pay this when you create your Steam page. |
| **Domain name** | hoardseeker.com etc. via Namecheap, Cloudflare | $10-15/yr | Grab early before someone else does. |
| **Discord setup** | Free Discord server | Free | Set up by month 5, recruit moderators by month 8. |
| **Email / newsletter** | Buttondown, ConvertKit, Mailchimp | $0-30/mo | For wishlist conversion. Buttondown is solo-dev friendly. |

### Decide by month 6-8

The big creative contractor decisions. These take time to find people, so start scouting early.

| Decision | Options | Cost ballpark | Notes |
|---|---|---|---|
| **Illustrator** | ArtStation, Reddit r/HungryArtists, Cara, personal network | $5k-25k for full launch art | The single biggest budget decision. Start scouting month 4, contract month 6. |
| **Composer** | AirGigs, Soundtrack.net, university film-scoring programs, personal network | $3k-15k for ~90 min of music | Start month 6-8, contract by month 9. |
| **Voice actor (DM narrator)** | Casting Call Club, Voice123, BackStage | $1.5k-6k for ~200 lines | Start month 8, contract by month 10. |
| **SFX designer (optional)** | AirGigs, A Sound Effect, freelance sound designers | $1k-5k | Skip if budget tight; layered free SFX work fine. |

If your total budget is tight (< $5k), you can lean heavily on AI-generated concept art with hand cleanup and royalty-free music. The game will look less premium but is shippable. We'll have a frank budget conversation around month 4.

### Decide by month 12-13

The big distribution and infrastructure decisions.

| Decision | Options | Cost | Notes |
|---|---|---|---|
| **Backend host** | Supabase (managed), Fly.io, Railway, self-hosted | $0-200/mo | Supabase is the solo-dev pick. Free tier handles closed beta. |
| **Telemetry** | PostHog, Plausible, custom Supabase tables | $0-50/mo | Anonymized run data for balance. PostHog has free tier. |
| **Publisher** | Playstack, Hooded Horse, Future Friends Games, Raw Fury | Revenue split (typically 20-30%) | Approach with demo + Steam page metrics. They handle PR, console ports, marketing. |
| **Localization service** | LocalizeDirect, Altagram, freelance translators | $5-15k for 7-8 languages | Year 2 expense, post-launch. Don't worry about it now. |

### Tools we will *not* use

To keep the stack manageable for a non-technical solo dev:

- ❌ **Multiple game engines.** We picked Godot. We're not switching.
- ❌ **Custom networking middleware** (Photon, Mirror). GodotSteam is sufficient.
- ❌ **Cryptocurrency/NFT/blockchain anything.** Hoardseeker has none of this.
- ❌ **Live service infrastructure beyond what's needed for ranked.** No daily quests systems, no battle pass platform, no microtransaction backend.

---

## Asset creation workflow

You're not an artist or musician. Here's the disciplined process for getting professional-looking output.

### Visual assets

**For placeholder / concept art (months 1-6):**
1. Generate concept with Midjourney or SD using a consistent prompt template.
2. Touch up in Photopea (crop, color-correct, remove artifacts).
3. Drop into Godot. This is fine for the slice and demo.
4. Note: AI-generated concept *can* be used in the slice but should be replaced before launch with original or contracted art for legal safety and quality.

**For final art (months 6+):**
1. Brief the illustrator with concept references (your AI generations are great references — be transparent about that).
2. Establish a style guide with the illustrator: 2-3 reference pieces nailed down, then everything else follows.
3. Iterate in batches: 5 portraits at a time, review, approve, next batch.
4. Always own your assets. Contract specifies "work for hire" with full IP transfer.

**For UI / icons:**
1. UI design can be solo-dev friendly. Use Figma's free tier for layout.
2. Ability icons: ~250 needed at launch. Either contract a small icon set ($1-3k) or generate + cleanup with strict consistency.
3. Don't try to design UI from scratch — adapt a known D&D-feeling pattern (parchment + ink) and stay disciplined.

### Audio assets

**Music:**
1. Prototype with Suno/Udio for early builds. *Internal use only.*
2. Around month 8, contract a real composer. Provide your prototypes as references — *"this is the vibe, replace with original."*
3. Final tracks delivered as WAV, looped versions for in-game use, plus full versions for trailers.
4. Always own the music. Contract: full IP transfer, perpetual license.

**Voice (DM narrator):**
1. Prototype with ElevenLabs for placeholder narration in builds. *Internal use only.*
2. Around month 10, contract a voice actor. Provide your prototypes as references for tone.
3. Record in a single session (cheaper) or batch sessions as content is finalized.
4. Always own the recordings. Contract: full IP transfer + buyout (no per-game royalties).

**SFX:**
1. Build a sound bank from Freesound.org (CC0 only — verify license). Layer multiple sounds for richness.
2. The dice roll sound is the most important. Consider a custom recording session ($200-500) for the perfect dice clack.
3. Use Audacity (free) for editing.

### The legal-safety rule on AI assets

**Never ship AI-generated content as final art, music, or voice in a commercial release.** Reasons:

- Steam policy on AI content is evolving and could change.
- Copyright on AI-generated work is legally murky in most jurisdictions.
- Players sometimes review-bomb games for using AI art ("AI slop" backlash).
- Quality ceiling is lower than human-made.

**AI is excellent for:**
- Internal prototyping
- Mood boards and references for human artists
- Placeholder art in dev builds
- Concept exploration before commissioning

**AI is not for:**
- Anything in the released game
- Anything in your trailer
- Anything in your Steam screenshots

If budget forces AI in the final product, get explicit written consent from a contracted human artist who has reworked it substantially. Document the process. Be transparent with players if it ever comes up.

---

## Code quality and audits

The codebase needs to stay healthy across 18+ months. These audits are how that happens.

### Per-commit audit (every change)

Claude Code does this automatically as part of every commit:

- Lint passes (`gdformat`, `gdlint`)
- All tests pass
- New code has tests
- No new banned API calls (`randf()` outside RNG service, etc.)
- Commit message explains intent

Your check: ask Claude *"Did all the per-commit audits pass?"* before merging.

### Weekly audit (every Friday or end of work week)

Time required: 15 minutes. Run with Claude Code:

1. **"Run the full test suite. Are all tests green?"**
2. **"Show me the 'tech debt' list — anything we noted as 'fix later' this week?"**
3. **"What was the largest file we changed this week? Is it still under our 150-line guideline?"**
4. **"Did we add any new TODOs or FIXMEs in code? Catalog them."**

Catalog goes in `TECH_DEBT.md` (a file we'll create when it first has content).

### Monthly audit (first weekend of each month)

Time required: 1-2 hours. Run with Claude Code:

1. **The dependency audit**: *"List every external library we use. Is each one still maintained? Are there any we no longer need?"*
2. **The unused code audit**: *"Find any classes, functions, or files that are no longer referenced. Should we delete them?"*
3. **The performance audit**: *"Run the simulation 1000 times headless. What's the average frame time? Any regressions from last month?"*
4. **The size audit**: *"What's our build size? Where are the biggest assets? Anything we can compress without losing quality?"*

### Quarterly audit (every 3 months — months 3, 6, 9, 12, 15, 18)

Time required: a full day. The most important audit. This is the **fresh-Claude modularity test**.

The process:

1. Pick the 3 most recently-built systems (e.g., combat, dungeon generation, loot).
2. Open a *new* Claude Code session with no prior context.
3. Provide it only `CLAUDE.md`, the relevant design doc (e.g., `CONTENT.md`), and the source files for one of the systems.
4. Ask: **"Add [some plausible feature] to this system. Make it work without modifying any other system."**
5. Watch what happens.

**Pass**: Fresh Claude implements the feature within 30 minutes, only touching the one system, all tests pass.

**Fail**: Fresh Claude needs to read other systems, modify shared state, or violates architecture. The system is too coupled. Refactor.

This is your safety net. If you do this every 3 months, you'll catch architectural drift before it becomes unfixable. Skip these audits and at month 14 you'll discover you can't add a new class without rewriting half the game.

### Pre-launch audit (month 16-17)

Time required: 1-2 weeks. Comprehensive review with Claude Code:

- **Security audit**: any way for cheaters to break the leaderboard? Any way to inject content?
- **Performance audit**: 60 FPS on a 5-year-old laptop? Memory under 500MB?
- **Localization audit**: every player-facing string in the string table?
- **Save/load audit**: every game state field serializable? Old saves still load after engine update?
- **Crash audit**: does the game recover gracefully from network drops, file corruption, etc.?
- **Polish audit**: every UI screen, every animation, every sound — does it feel finished?

This is the audit that determines whether you actually launch or delay. Don't skip it.

---

## Modularity enforcement

How we keep the codebase refactor-able forever.

### The boundaries are sacred

`src/core/` knows nothing about `src/ui/`. `src/systems/combat/` knows nothing about `src/systems/dungeon/`. These boundaries are enforced by:

1. **Import rules** (in code review): a `src/core/` file importing a UI class is an immediate blocker.
2. **The fresh-Claude test** (in quarterly audits).
3. **Your discipline**: if Claude starts coupling things, push back. *"Why does combat need to know about the dungeon? Can we route this through events instead?"*

### Everything is data, not code, where possible

Adding a new class, ability, artifact, monster, biome, or race should be a `.tres` file, not a code change. If you find yourself coding new content, the data model is wrong. Fix the model.

### Events are the glue

Systems communicate via events, not direct calls. Combat emits `DAMAGE_DEALT` events; the UI listens; the narrator listens; achievements listen. None of those systems know about each other.

This is what makes future changes cheap. Want to add a new visual effect on damage? Listen to the event. Don't modify combat.

### The 150-line rule

If a `.gd` script grows past 150 lines, **stop and split it**. Tell Claude: *"This file is getting long. Refactor into smaller modules with clear responsibilities."*

This is a rough heuristic, not a law. Some files (like the main `GameState` resource) will exceed it. But the spirit holds: small files, clear responsibilities, easy to refactor.

### Document the why, not the what

Every module has a header comment explaining *what it's for and why it exists*. Future-you will not remember. Future-Claude won't have context.

```gdscript
## CombatResolver
##
## Owns the resolution of attack-vs-defense interactions.
## Receives AttackCommand events, computes hit/miss/damage,
## emits resolution events. Stateless — does not modify state directly.
## Used by: command_processor.gd
## Knows about: nothing (pure functions)
```

If a file doesn't have this header, ask Claude to add one.

---

## Safety rails

Things that go wrong with non-technical solo devs, and how to prevent them.

### Disaster: "I lost a week of work"

**Cause**: Forgot to commit. Computer crashed. Hard drive died.

**Prevention**:
1. Commit every working session, minimum. Claude Code prompts you to.
2. Push to GitHub at the end of every session. This is non-negotiable.
3. GitHub serves as your backup. Even if your laptop dies tomorrow, you're fine.
4. Quarterly: download a full repo zip and store on a separate cloud drive.

### Disaster: "I broke the game and can't undo it"

**Cause**: Pushed bad code to main. Don't know how to revert.

**Prevention**:
1. **Always work on branches**, never directly on main.
2. Branches get reviewed and merged via pull request.
3. If main breaks, ask Claude: *"Roll back the last merge to main. Show me what changed."*

### Disaster: "I let scope balloon and now the project is unfinishable"

**Cause**: Saying yes to every cool idea.

**Prevention**:
1. Hard "no" list in `CLAUDE.md`. We have one. Re-read it monthly.
2. New ideas go to `IDEAS.md` (we'll create this when needed). They do not get built unless explicitly promoted.
3. Quarterly review: *"What did we add to scope this quarter? Was it worth it?"*

### Disaster: "I made a contract decision I regret"

**Cause**: Hired wrong artist. Bad publisher contract. Lost rights to assets.

**Prevention**:
1. **Read every contract.** Not skim — read.
2. Get a second opinion on contracts over $5k. (Reddit r/gamedev, IndieGameLawyer, your network.)
3. Always get **written IP transfer** clauses. Always.
4. Never sign exclusive distribution deals at month 1. Wait for leverage.

### Disaster: "I burned out at month 12"

**Cause**: 80-hour weeks for a year, no recovery time, no peer contact.

**Prevention**:
1. Hard cap at ~40 hours/week. This is sustainable for 18-22 months. 60 hours/week is not.
2. Mandatory days off. Take weekends. Take a week off every 3 months.
3. Find a peer group. Solo dev Discord servers, indie game meetups, local game jams.
4. Playtest with humans regularly. The energy boost from "they liked it!" is real.

### Disaster: "Claude Code did something I didn't expect and now things are weird"

**Cause**: Vague instruction. Claude inferred wrong. Code doesn't match intent.

**Prevention**:
1. Be specific. Reference the docs. Reference the file.
2. Ask for the plan first. Always.
3. Use branches. If a session goes sideways, throw away the branch.
4. Trust your gut. If something feels off, ask Claude to explain it back to you in plain English. If it can't, it's wrong.

---

## When to ask for human help

There are limits to what AI can do for you. Plan to engage humans on:

| Need | Where | When |
|---|---|---|
| **Contract review** | Lawyer or experienced indie dev friend | Any contract over $5k. |
| **Tax / business setup** | Accountant familiar with software businesses | Month 1-2. Form an LLC or equivalent. |
| **Playtesting** | Friends, family, indie communities, paid playtesters | Month 4 onward, monthly. |
| **Marketing strategy** | Indie marketing consultants, GameDev marketing courses, /r/gamedev | Month 5-8. |
| **Publisher negotiation** | Industry mentor, second opinion on terms | Month 12-13. |
| **Localization** | Localization service, native speakers | Year 2. |
| **Accessibility review** | Game Accessibility Conference resources, accessibility consultants | Month 14-15. |

Budget for these. ~$2-5k total over 18 months for human consultation is reasonable and high-leverage.

---

## Decision calendar

Everything you need to decide, sorted by deadline. Print this. Tape it somewhere visible.

### Month 1
- [ ] Code editor (VS Code, Cursor, Zed)
- [ ] Project tracker (Linear, Notion, GitHub Projects)
- [ ] Backup strategy verified (GitHub + cloud drive)
- [ ] Devlog platform(s) selected (don't post yet)
- [ ] Business entity formed (LLC or equivalent — talk to an accountant)

### Month 3
- [ ] Concept art tool subscribed (Midjourney etc.)
- [ ] Image cleanup tool installed (Photopea is free)
- [ ] Music prototyping tool subscribed (Suno or Udio)
- [ ] SFX library bookmarked (Freesound.org)

### Month 4
- [ ] Total project budget defined (and any contractor budget)
- [ ] Begin scouting illustrators (ArtStation portfolios, network)
- [ ] First playtester sessions begin (just friends)

### Month 5
- [ ] Steam Direct fee paid ($100), Steam page started
- [ ] Domain registered (hoardseeker.com etc.)
- [ ] Discord server set up
- [ ] Newsletter set up (Buttondown or similar)
- [ ] First public devlog post

### Month 6
- [ ] Illustrator contracted, style guide work begins
- [ ] Begin scouting composer

### Month 8
- [ ] Composer contracted
- [ ] Begin scouting voice actor for narrator
- [ ] First trailer cut (rough)

### Month 10
- [ ] Voice actor contracted
- [ ] Steam Next Fest registration submitted (timing dependent on fest schedule)

### Month 12
- [ ] Backend host chosen and deployed (Supabase or Fly.io)
- [ ] Telemetry pipeline live
- [ ] Begin approaching publishers

### Month 13
- [ ] Closed beta begins
- [ ] Publisher contract signed (if going that route)

### Month 14-16
- [ ] Localization plan finalized (decide what languages, what budget)
- [ ] Accessibility audit
- [ ] Final trailer cut
- [ ] Press kit finalized

### Month 17-18
- [ ] Pre-launch audit complete
- [ ] Launch day plan finalized
- [ ] Day 1 patch ready in branch

### Month 18+
- [ ] Launch
- [ ] Live ops decisions begin

---

## When you start a session — the routine

Every time you sit down to work:

1. Read `CLAUDE.md` and this file (refresh the discipline rules).
2. Check `ROADMAP.md` for current phase.
3. Pull latest from GitHub. Confirm you're on the right branch.
4. Tell Claude Code what you want to do today. In plain English.
5. Ask Claude for a plan. Read it. Approve or push back.
6. Work.
7. Run tests. All pass?
8. Playtest the change. Does it feel right?
9. Commit. Push. Update docs if anything changed.
10. Note any tech debt or new ideas.

If you do this every session, you cannot lose. Even slow weeks add up. Even bad weeks don't break the project. Discipline beats inspiration over 18 months.

---

## The single most important rule

**You are the director. The AI is the engineer. You hold the vision. They translate.**

Never reverse this. Never let the AI tell you what the game should be. Never accept "it's good enough" if your gut says it isn't. Never accept "that can't be done" without a second opinion.

The reason solo dev games succeed is *one person's clear vision, executed with unrelenting taste*. The vision is you. The taste is you. Everything else is a tool.

Use the tools. Don't become one.
