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

These come into play when you start producing visible content. **Bootstrap mode (<$5k total) shapes every choice below.**

| Decision | Options | Cost ballpark | Notes |
|---|---|---|---|
| **AI generation tool (production, not just prototype)** | Midjourney, Stable Diffusion (ComfyUI local), DALL-E 3 | $0-30/mo | Used for actual shipped art via the cleanup workflow. Pause subscription between heavy generation periods to control cost. |
| **Image cleanup** | Krita (free, recommended), Photopea (free, browser), Photoshop (avoid for cost) | $0 | Krita is the primary tool. Free. |
| **Graphics tablet** | Wacom Intuos S, XP-Pen alternatives | ~$50-80 one-time | Required for meaningful cleanup. One-time cost. |
| **Music curation** | Kevin MacLeod (free, attribution), FreePD (CC0), Pixabay Music, Tabletop Audio | $0 | Primary music source. No subscription. Build a curated track list with verified licenses. |
| **SFX library** | Freesound.org (CC0 only, verify each file) | $0 | All SFX from CC0 sources. Custom dice clack via phone + Audacity, $0. |
| **Music prototyping (internal only)** | Suno, Udio | Optional, $10-30/mo | Internal prototyping only. Never shipped. Skip if budget tight. |

### Decide by month 5

When you go public with a Steam page.

| Decision | Options | Cost | Notes |
|---|---|---|---|
| **Steam Direct fee** | One-time $100 per game | $100 | Required to publish on Steam. Pay this when you create your Steam page. |
| **Domain name** | hoardseeker.com etc. via Namecheap, Cloudflare | $10-15/yr | Grab early before someone else does. |
| **Discord setup** | Free Discord server | Free | Set up by month 5, recruit moderators by month 8. |
| **Email / newsletter** | Buttondown, ConvertKit, Mailchimp | $0-30/mo | For wishlist conversion. Buttondown is solo-dev friendly. |

### Decide by month 6-8

Under bootstrap mode, the big-contractor lane is closed. The decisions here are about the one tightly-scoped commission we *do* make and confirming our DIY production tracks are on schedule.

| Decision | Options | Cost ballpark | Notes |
|---|---|---|---|
| **Illustrator** | — | **SKIP** under bootstrap mode | Replaced by AI generation + hand cleanup workflow. See `DECISIONS.md` (Path B). |
| **Signature theme composer (1 track only)** | AirGigs lower tier, music school students, Reddit r/composer | ~$300 (one-time) | Commission ONE signature theme for title/boss. Royalty-free covers the rest. Start scouting month 6, contract by month 8. |
| **Voice actor** | — | **SKIP** under bootstrap mode | Narration is text-only forever. See `DECISIONS.md`. |
| **SFX designer** | — | **SKIP** under bootstrap mode | Layered Freesound CC0 + custom dice recording covers the need. |

**Bootstrap budget reality check** (run this monthly starting month 4): total spend so far + projected remaining vs. $5,000 cap. If projected breaches the cap, the response is *cut scope*, not *raise the budget*. The bootstrap-mode pivot triggers in `RESILIENCE.md` and the contingency plan in `ROADMAP.md` exist precisely for this case.

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

### Visual assets (bootstrap mode workflow)

**The production model is: AI generation → mandatory human cleanup → ship.** No contracted illustrator. Every asset that ships gets hand-touched in Krita or Photopea before going into the game. The cleanup is what determines whether the result reads as "thoughtful indie art" or "AI slop."

**Tools (one-time setup):**
1. Midjourney subscription (~$30/mo during heavy generation periods, can pause between batches) OR local Stable Diffusion if hardware allows.
2. **Krita** (free) — primary cleanup tool. Better tablet support than Photopea.
3. **Photopea** (free, browser-based) — alternative for quick edits and PSD interop.
4. **Wacom Intuos S** (~$80, one-time) — meaningful cleanup is hard without a tablet.
5. **Figma** (free tier) — for UI layout, frame composition, icon arrangement.

**The cleanup discipline (this is what determines quality):**
1. Generate with a locked style guide: same prompt template, same model version, same color palette across all assets in a category.
2. Inspect every generation for AI tells (extra fingers, melted geometry, asymmetric eyes, weird text, inconsistent armor).
3. Hand-paint over problem areas in Krita with a tablet. Even a rough overpaint reads as human.
4. Adjust line weights, color balance, and edge softness for visual consistency across the asset set.
5. Final pass: compare side-by-side with previously approved assets. Style drifting? Adjust before continuing the batch.

**Style guide first, generation second:**
1. Lock 3-5 reference pieces nailed down before generating in volume. These become the visual north stars.
2. Document the prompt template, model version, and any seed values in `assets/STYLE_GUIDE.md` (we'll create this when generation begins).
3. The bar: anyone could pick up the project and produce on-style art if the style guide is good. If they can't, the guide isn't tight enough.

**For UI / icons:**
1. UI layout in Figma, then implement in Godot directly. Adapt a known D&D-feeling pattern (parchment + ink) and stay disciplined.
2. Ability icons: ~250 at launch. AI generation + 15-30 minutes cleanup per icon. Total cleanup workload ~60-100 hrs spread across the project.
3. Artifact icons: ~80 at launch. ~30 minutes cleanup each. Total ~40 hrs.
4. Reuse aggressively: ability icons share frame/border treatments; race variants are color/accessory swaps not unique illustrations.

**Backup discipline:**
- Keep both the AI source generation AND the cleaned-up final, with a naming convention (`portrait_fighter_human_v1_raw.png`, `portrait_fighter_human_v1_clean.png`).
- Document the prompt and any seed used so a regen for consistency tweaks is reproducible.

**Total estimated cleanup workload over 18 months:** ~275 hours (portraits, ability icons, artifact icons, monster portraits, biome backgrounds). At ~15 hours/month, well inside the 40-hour weekly cap with significant slack for rest and other work.

### Audio assets (bootstrap mode workflow)

**Music** — primary soundtrack is curated royalty-free + one commissioned signature theme:
1. Curate from royalty-free orchestral sources: Kevin MacLeod (incompetech.com, attribution required), FreePD (CC0), Pixabay Music (commercial-OK), Tabletop Audio (some commercial-licensed tracks). Verify each track's license individually before shipping.
2. Maintain `audio/MUSIC_LICENSES.md` with per-track license + attribution requirements.
3. Around month 8, commission ONE signature theme (~$300) from a music school student, AirGigs lower tier, or Reddit r/composer for the title screen / boss intro. Provide royalty-free references as the "vibe baseline" with the brief: *"original track, this style, this length."*
4. Contract for the signature theme: full IP transfer, perpetual license, work-for-hire — even at low budget. Standard contract, no exceptions.
5. AI-generated music is not used in shipped product. Suno/Udio is acceptable for internal prototyping only (e.g., temp soundtrack while waiting on royalty-free curation).

**Voice (DM narrator)** — cut entirely:
1. All narration is text-only. No voice acting in shipped product, ever.
2. Stylized parchment overlay with subtle SFX (parchment unfurling, ink scratch) replaces the atmospheric weight a voice would carry.
3. AI voice (ElevenLabs / similar) is acceptable for the user's personal prototyping if it helps writing pacing — never shipped.

**SFX** — Freesound + custom dice recording:
1. Build a sound bank from Freesound.org (CC0 only — verify license per file). Layer multiple sounds for richness.
2. The dice roll sound is the most important. Custom recording with phone + Audacity ($0): record real dice on real surfaces (wood, stone, parchment) and layer with effect processing.
3. Use Audacity (free) for editing.
4. Maintain `audio/SFX_LICENSES.md` with per-file source + license verification.

### The AI-content rule (revised 2026-05-08 for bootstrap mode)

> **AI-generated content may appear in shipped product ONLY when:**
> 1. Every asset has substantial hand cleanup with documented process. The cleanup is what determines final quality, not the prompt.
> 2. The Steam store page discloses AI use prominently and accurately, per Steam's required "AI Generated Content" field.
> 3. We maintain a public "How this art was made" statement on the project website / Discord, explaining the workflow honestly.
>
> **AI-generated music and AI-generated voice remain off-limits in shipped product.** These categories carry higher community sensitivity and weaker cleanup options. Royalty-free music + one commissioned signature theme + text-only narration are the alternatives.

The earlier blanket "never ship AI as final" rule was written assuming a contractor-funded production model. Bootstrap mode (<$5k total) makes that model infeasible. The revised rule keeps the *spirit* of the original (don't ship raw slop, be honest with players) while permitting the specific bootstrap-feasible workflow. See `DECISIONS.md` (entry: *Revised AI-content rule, 2026-05-08*) for full rationale.

**Risks we are explicitly accepting:**
- Steam may tighten AI policy further. We will comply with whatever the policy is at submission time.
- The TTRPG/D&D audience is the most AI-art-skeptical audience on Steam. Review-bomb risk is real and non-trivial.
- Cleanup discipline is what protects us from the worst-case reception. Cleanup hours are not optional.

**AI is still excellent for:**
- Internal prototyping (no shipping bar)
- Mood boards and visual references
- Placeholder art in dev builds
- Concept exploration before the cleanup pass

**AI is still off-limits for:**
- Music in shipped product (royalty-free + one commissioned theme is the path)
- Voice in shipped product (narration is text-only forever)
- Any asset that did not receive substantial human cleanup
- Anything in the trailer or Steam screenshots that hasn't gone through cleanup discipline

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
| **Contract review** | Lawyer, experienced indie dev friend, or AI-assisted review for sanity-check (any contract, even small ones) | Any contract — even the ~$300 signature theme commission. The cost of a bad clause is higher than the time it takes to read. |
| **Tax / business setup** | Accountant familiar with software businesses | Month 1-2. Form an LLC or equivalent. Budget ~$100-800 depending on state. |
| **Playtesting** | Friends, family, indie communities, free playtesters | Month 4 onward, monthly. Paid playtesters skipped under bootstrap mode. |
| **Marketing strategy** | Free resources first: /r/gamedev, How To Market A Game blog, Chris Zukowski's free content | Month 5-8. Paid consultants skipped under bootstrap mode. |
| **Publisher negotiation** | Industry mentor, second opinion on terms via Discord communities | Month 12-13. Free / favor-economy first. |
| **Localization** | Free first: deferred entirely under bootstrap mode | Year 2 post-launch only, contingent on revenue. |
| **Accessibility review** | Game Accessibility Conference resources (free), GAconf YouTube talks | Month 14-15. Self-audit first; paid consultant only if revenue allows. |

Bootstrap budget allocation for human consultation: **near zero pre-launch.** LLC setup is the one likely paid consultation (~$100-800 one-time). Everything else leans on free resources and community goodwill.

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
- [ ] First bootstrap-budget reality check (spend-to-date + projected remainder vs. $5k cap)
- [ ] Begin AI generation experiments + lock the visual style guide (3-5 north-star reference pieces)
- [ ] First playtester sessions begin (just friends)

### Month 5
- [ ] Steam Direct fee paid ($100), Steam page started
- [ ] Domain registered (hoardseeker.com etc.)
- [ ] Discord server set up
- [ ] Newsletter set up (Buttondown or similar)
- [ ] First public devlog post

### Month 6
- [ ] Visual style guide locked (`assets/STYLE_GUIDE.md`) — prompt template + reference pieces approved
- [ ] First batch of finished portraits (3-5) shipped through the full AI-gen + cleanup pipeline
- [ ] Begin scouting for the one ~$300 commissioned signature theme (music school programs, AirGigs, r/composer)

### Month 8
- [ ] Signature theme commissioned (~$300, contract with full IP transfer)
- [ ] Royalty-free music curation in `audio/MUSIC_LICENSES.md` — at least 10 verified tracks
- [ ] First trailer cut (rough)

### Month 10
- [ ] Signature theme delivered + integrated
- [ ] Text-only narration overlay polished (parchment reveal animation, ink-scratch SFX)
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
