# RESILIENCE.md — Hoardseeker

> **The most uncomfortable document in this project.**
> Read this every Monday morning. Read it again when things get hard.
> It exists to keep you and the project alive over 18-22 months.

---

## Why this document exists

Here's the data. Sit with it before we discuss what to do about it.

- 55% of indie devs are solo, with a 70% failure rate, while burnout and stress hit 60% of developers.
- Over 70% of surveyed indie developers cited "scope too large" as a significant factor in their game's failure to meet deadlines or, worse, its complete abandonment.
- About 70% of indie games fail to break even, and it's rarely because the devs weren't talented.
- The most common cause of project abandonment is not lack of skill, lack of funding, or lack of time. It is loss of motivation driven by some combination of scope creep, isolation, exhaustion, comparison-induced demoralization, and vision drift.
- Burnout is when people get stuck in a behavior pattern that they were once able to thrive in, but over time makes them more and more anxious or depressed. It is not a character flaw. It is a predictable outcome of common patterns. Those patterns are listed below, and the systems in this document exist to disrupt each one.
- Whenever you care about someone or something more than yourself, your risk of burnout takes a big leap forward. You will care about Hoardseeker more than yourself. That is the danger.

This document is not optimism. It is calibrated realism. The good news: people who do this successfully follow knowable, learnable patterns. The systems here come directly from postmortems of devs who shipped, devs who didn't, and clinical research on burnout.

If you do nothing else in this document, do these three things:

1. **Commit something to the project every day, even a typo fix.** One solo dev maintained a git commit streak of 687 days with at least one commit on the game per day, which helped them keep working while holding a full-time job. Streaks beat sprints over 18 months.
2. **Cap your weekly hours and protect rest.** No 80-hour weeks. Ever. Not for any reason.
3. **Stay socially connected.** Solo developer + working from home + months of isolation is the burnout speedrun. Counter it deliberately.

---

## The 12 failure modes

These are the documented patterns from postmortems. Each has a counter-system later in this document.

### 1. Scope creep
The single most common killer. The project starts small, then "wouldn't it be cool if..." adds features faster than they can be built. Eighteen months later, it's 30% done with no end in sight. A Gamasutra article highlighted that over 70% of surveyed indie developers cited "scope too large" as a significant factor in their game's failure.

### 2. Unrealistic expectations
You expect to ship in 6 months and earn $100k. Reality: 18 months and $5k. The gap between expectation and reality kills morale long before the project is unfinishable. Many beginners expect fast success, and when downloads or earnings don't appear quickly, motivation drops.

### 3. Burnout
Emotional, physical, and mental exhaustion from sustained over-work. The signs: dread when opening the project, declining quality of work, irritability, sleep issues, declining health. Burnout is a state of emotional, physical, and mental exhaustion that can lead to irreparable loss of time and a sense of despair, potentially causing developers to abandon their projects.

### 4. Vision drift
Six months in, you're no longer building the game you started building. You've added a second genre, changed the art style, changed the target audience. The result: nothing is finished, everything is half-built. Sometimes developers change their minds about the game's direction as they progress, which can lead to restarting development or abandoning the project altogether.

### 5. Comparison demoralization
You scroll Reddit. Someone shipped a game in 6 months and got 50,000 wishlists. Your game has 400. You wonder if your game is good. You wonder if you should quit. It can be really demotivating to see other games getting thousands of wishlists on Steam, while my game got around 400 as of today. If I wouldn't have seen this on Reddit, I would be the happiest person on earth knowing that FOUR HUNDRED people saw my game.

### 6. Isolation and loneliness
Solo dev + remote work + months of focus = social atrophy. Loneliness is not a feeling. It is a clinical risk factor for depression, decreased motivation, and physical health decline. Social isolation is a symptom of and a risk factor for depression and anxiety. Since depression is marked by symptoms including social withdrawal, lack of energy, and decreased motivation and pleasure, it can perpetuate social isolation.

### 7. Lack of short-term reinforcement
Long projects starve the brain of the dopamine hits that come from completing things. Eighteen months without external validation — no shipped product, no reviews, no audience excitement — is brutal even for highly motivated people. Lack of long-term motivation: not understanding the project's magnitude can lead to frustrations due to the lack of short-term positive reinforcement.

### 8. Technical wall paralysis
You hit a problem you don't know how to solve. You try for hours. You feel stupid. You walk away. You don't come back. Non-technical solo devs working with AI assistance face a unique version: when AI gets stuck, you have nowhere to escalate.

### 9. Perfectionism
The game is never quite ready to ship. There's always one more bug, one more polish pass. Years pass. The game enters perpetual early access. Indie game developers seem to have a particularly hard time letting their babies out into the wild, either hiding them from the light of day, or keeping them in a perpetual "early access" state.

### 10. Imposter syndrome
You feel like a fraud. Real game devs went to school for this. Real game devs have shipped games before. Who are you to think you can do this? This feeling does not go away as you become more capable; it intensifies as the stakes grow.

### 11. Financial anxiety
Even if you're not depending on this for income, the meter runs. Subscriptions cost money. Contractors cost money. Time has opportunity cost. The longer the project goes, the louder the math gets.

### 12. Single point of failure
You are the only person who knows how the dungeon generation works. You are the only one who can fix the combat bug. If you have a bad week — sick, family emergency, depression — the project stops. There is no team to keep momentum. When one person is singularly responsible for the most difficult parts of the code base, that puts incredible responsibility on the one person to deliver and puts mental pressure on the one person.

---

## The early warning system

These are the warning signs. Notice them in yourself. Tell Claude about them at session start when they show up. They mean intervention is needed, not pushing harder.

### Daily warning signs

- You feel dread when opening the project file.
- You "work" for an hour and produce nothing.
- You cannot remember what you did yesterday on the project.
- You're irritated at small problems that wouldn't have bothered you a month ago.
- You catch yourself thinking "what's the point?"
- You're avoiding the project by doing other "productive" things (cleaning, errands, low-stakes side tasks).

### Weekly warning signs

- You missed 3+ days of commits this week.
- Your weekend off didn't feel restful.
- You haven't talked to a real human about the project (or anything) in days.
- You spent more time consuming gamedev content than making your game.
- You're sleeping poorly, or oversleeping.
- You're eating worse than usual.

### Monthly warning signs

- You've made significant changes to the game's core vision.
- You've added scope without removing scope.
- You haven't playtested with another human this month.
- You feel jealous when reading about other devs' wins.
- Your motivation is lower than last month, and lower than the month before.
- You've stopped celebrating completed work.

### Crisis warning signs (immediate intervention)

If any of these are true, stop project work. The project will survive a week off. You may not.

- You feel hopeless about the project, not just frustrated.
- You're using substances (alcohol, weed, caffeine, sleep aids) more than you used to.
- You're isolating from friends and family.
- You're having intrusive thoughts about quitting permanently, daily, for more than a week.
- You feel physically unwell most days.
- You're having thoughts of self-harm.

For the last one specifically: 988 (US Suicide and Crisis Lifeline) is available 24/7. If you're in immediate danger, get help. The game can wait.

---

## The prevention systems built into the project

This is the active counter-program. Each system targets specific failure modes from the list above.

### System 1: The daily minimum (counters #3, #7)

**Rule: Make at least one commit to the project every day.**

It can be a typo fix in a doc. It can be renaming a variable. It can be a single sprite tweak. The standard is "did the project change today, even slightly?" — not "did I make meaningful progress?"

Why this works:
- Streaks build identity. After 30 days, you are someone who works on this every day. After 100, it's automatic.
- Bad days produce small commits. Good days produce large ones. Both count.
- Resumption cost is low: 10 minutes today is much easier than 4 hours after a 5-day gap.

Implementation:
- A repo badge tracks current streak.
- Claude Code reminds you at session start if you haven't committed today.
- Missed days are logged but not punished. Pick up tomorrow.

The goal is not 365 days unbroken. The goal is "I touch this almost every day." Eighteen months × ~5 days/week = ~390 working sessions. That's where the game comes from.

### System 2: The 40-hour cap (counters #3, #6)

**Rule: Maximum 40 hours per week on the project. Average target: 25-35 hours per week.**

This is not laziness. This is sustainability math. Burnout is not admirable, virtuous, or empowering. It should be an embarrassment when someone doesn't manage to estimate their time correctly.

Why this works:
- 40 hours/week × 18 months = 3,000+ hours of focused work. That's a full game.
- 80 hours/week × 6 months = burnout, abandoned project, zero hours/week × 12 months. Net total: lower.
- Quality of work after hour 40 in a week declines sharply. The bugs you write tired take longer to fix than the time you "saved" by working.

Implementation:
- Track hours weekly in `WORKLOG.md` (a file you maintain, simple text).
- If a week exceeds 40, the next week is capped at 30 to recover.
- Weekends and holidays are off-limits by default. Working them requires a specific reason and a corresponding day off later.

### System 3: Mandatory weekly disconnect (counters #3, #6)

**Rule: Take at least one full day off per week. No exceptions. Two days is better.**

A full day means: don't open the project, don't think about it, don't browse gamedev content, don't research tools, don't draft devlog posts. Genuine off.

Why this works:
- Sleep and rest are when learning consolidates. The bug you couldn't solve Friday solves itself Monday morning.
- Distance produces objectivity. Problems shrink with rest.
- Identity outside the project is what survives if the project doesn't.

Implementation:
- Pick a day. Sundays default. Block it on the calendar.
- Tell people. Accountability matters.
- If you slip, the next day off is mandatory and immediate.

### System 4: Quarterly week off (counters #3)

**Rule: Once every 12 weeks, take 5-7 consecutive days off. No project, no devlog, no gamedev anything.**

This is the deep recovery cycle. Eighteen months of non-stop is not survivable. Plan for stops.

Why this works:
- Long sprints without recovery accumulate damage faster than short days.
- Returning fresh produces breakthroughs (combat bugs, design problems, scope clarity).
- Identity recharge: who are you when you're not the dev? You need that person.

Implementation:
- Plan quarterly weeks off in advance. Block them on the calendar at project start.
- Defaults: end of month 3, 6, 9, 12, 15, 18.
- Notify Claude and any community/contractors. Set expectations.
- Don't move them unless absolutely necessary.

### System 5: The "no comparison" rule (counters #5, #10)

**Rule: Don't compare your project to others on social media or aggregator sites unless you're researching a specific question.**

The platforms that hurt you most: r/gamedev, IndieDB, Twitter game-dev community feeds, comparison aggregators. Browse with intent, not for entertainment.

Why this works:
- Survivor bias: you only see successful devs' wishlist counts because failed ones don't post.
- Their day 200 is not your day 200. They're at different stages, with different constraints.
- Comparison-driven discouragement is the cause of more abandonment than skill gaps.

Implementation:
- A "comparison detox week" every month — no gamedev social media for one week.
- When you do consume content, treat it like research: look for one specific takeaway, then close it.
- If a piece of content makes you feel worse about your own project, close it. Now.

### System 6: The vision lock (counters #1, #4)

**Rule: The vision in `VISION.md` does not change without a documented decision in `DECISIONS.md`.**

You will have new ideas every month. Most of them are good. Almost none of them belong in this project. They belong in the next one.

Why this works:
- A locked vision lets you say "no" without guilt. The game we're building is the game in the doc.
- Vision drift is not "evolution." It's substituting "the unfinished current project" with "the imagined better project." It feels like progress; it's actually escape.
- New ideas don't disappear. They get logged in `IDEAS.md` (a future file). They wait their turn.

Implementation:
- Monthly vision check: re-read `VISION.md`. Does the project still match? If not, what changed and why?
- New ideas go to `IDEAS.md` immediately. Do not promote without 24 hours of cooldown and a documented reason.
- Anything that conflicts with `VISION.md` requires a `DECISIONS.md` entry and explicit user override.

### System 7: Visible progress dashboard (counters #7)

**Rule: Maintain a single screen that shows current progress at a glance.**

Claude Code can build this as the project goes. A simple HTML page or a dashboard inside the game. It shows:
- Current phase (from ROADMAP.md)
- Days into project
- Commit streak
- Tests passing / total
- Wishlists (when applicable)
- Recent milestones

Why this works:
- Daily reminder of compounding progress. Your brain remembers yesterday's frustration; the dashboard remembers the last 200 days of work.
- Tangible metrics produce tangible motivation. "I shipped 3 abilities this week" beats "I worked on combat."
- Shareable proof. When someone asks how the project is going, you have an answer.

Implementation:
- Build a basic version after the vertical slice (month 4-5).
- Update it automatically from git, the test runner, and Steam (when applicable).
- Look at it daily.

### System 8: Weekly Friday recap (counters #7, #10)

**Rule: Every Friday, write a 5-line recap of what happened this week. Even if it was a bad week.**

Format: what shipped, what got hard, what surprised you, how you felt, what you'll do next week.

Why this works:
- Forces awareness of progress that hindsight would erase.
- Builds a project journal that becomes invaluable for postmortems and devlog content.
- Externalizes the noise in your head. Putting it on paper helps.

Implementation:
- File: `RECAPS.md`. Append-only.
- 5-10 minutes max. Not a literary exercise.
- Bad weeks count. "I was depressed and shipped nothing" is a valid entry. Note it. Move on.

### System 9: Monthly playtest with a real human (counters #6, #7, #11)

**Rule: At least once a month, watch another human play (or look at) your work in progress.**

Even before there's a real game. The slice version: someone watches a fight resolve. The demo version: a friend plays for 20 minutes. The beta version: 10 testers a week.

Why this works:
- The energy boost from a stranger laughing at your crit animation is the most renewable motivational resource available to a solo dev.
- Reveals problems you've gone blind to.
- Reminds you that the project will, eventually, exist for other people.

Implementation:
- Calendar a date. Recruit one person. Friend, family, indie community, paid playtester.
- Watch them play in person or via screen share. Don't talk during. Take notes.
- Afterward, thank them. Send a small gift if they did real work.

### System 10: Accountability partner (counters #6, #10, #12)

**Rule: Find one human you check in with weekly about the project. They are not a co-founder. They are a witness.**

This is not optional. Accountability partners provide more than just motivation; they offer encouragement, feedback, and a sense of shared responsibility that reduces the feeling of being "in it alone.".

Why this works:
- Externalizes accountability. You'll show up for someone else when you won't show up for yourself.
- Provides a perspective check: "I think the game's terrible" sounds different when said aloud than when thought.
- Combats the single-point-of-failure isolation.

Implementation:
- Could be: another solo dev, a friend who likes games, a mentor, a paid coach. Not your spouse or romantic partner — they have too much skin in the game to be objective.
- 30 minutes a week. Same time each week. Voice or video, not text.
- They ask: what shipped, what's stuck, how are you feeling? You answer honestly.

### System 11: Pre-defined pivot triggers (counters #1, #2, #4, #11)

**Rule: Decide *now* what conditions would cause us to pivot or scope down. When those conditions hit, the response is automatic, not emotional.**

Why this works:
- Removes "should I quit?" as a daily existential question. You've already decided what triggers that question.
- Prevents both premature abandonment ("today I feel bad, I should quit") and overrun ("I'll just push through forever").
- Provides clear off-ramps that aren't failure.

The pre-committed triggers for Hoardseeker:

| Condition | Trigger | Response |
|---|---|---|
| Vertical slice combat doesn't feel fun by month 5 | 3 separate playtesters say it's "okay, not great" | Iterate on combat for 1 more month before adding scope. After 2 months, replan or downsize. |
| Wishlist count below 5,000 by Steam Next Fest | <5k wishlists by demo launch | Reassess marketing strategy with publisher or community feedback. Don't quit; redirect. |
| Solo + duo both shipping at month 18 looks impossible | Multiplayer architecture not stable at month 14 | Ship solo at month 18, duo as free 1.0 update by month 22. |
| Funds running low | <3 months of contractor budget remaining | Stop new contractor work, ship with current art. Defer audio polish. |
| Personal health declining | 3+ crisis warning signs in 30 days | Stop work for at least 1 week. Get help. Reassess if continuing is healthy. |
| Total time exceeds 24 months from project start | Month 24 hit | Force-ship whatever exists. Truncate scope. The game must launch. |

These are not failure conditions. They are pre-decided redirections. Pivoting at month 14 with a plan beats grinding to month 24 with no plan.

### System 12: The "good enough" benchmark (counters #9)

**Rule: Define "good enough" before you start polishing. Polish until you hit it. Then stop.**

For each feature, write the acceptance criteria *before* working on it. When the criteria are met, the feature is done. Don't add polish you didn't plan for.

Why this works:
- Perfectionism is escape, not quality. There's always one more thing. Pre-defined criteria break the loop.
- The 80/20 rule is real: the last 20% of polish takes 80% of the time. Most players don't notice.
- Shipped is better than perfect. Shipped + iterated post-launch is better than perfect + never released.

Implementation:
- Every Issue / task in your tracker has an "acceptance criteria" section.
- Claude Code is asked to help write these *before* starting work, not after.
- When criteria are met, the feature is closed. Polish requests go to a separate "post-launch polish" list.

---

## The rituals

These are the actual scheduled practices that keep the systems alive. Follow them.

### Daily

- **Morning** (5 min): Open the project. Read today's planned task. Write 1 sentence of what you'll do.
- **Working session(s)**: Cap at 4 hours of deep work + 4 hours of lighter work per day. Take a 15-minute break every 90 minutes.
- **End of day** (5 min): One git commit. Note what you did in the commit message.
- **Evening** (separate from work): Do something not project-related. Read fiction. Walk. Cook. See another human.

### Weekly

- **Monday morning** (15 min): Read VIBE_CODING.md and this file. Reset the week.
- **Friday afternoon** (15 min): Write the weekly recap in `RECAPS.md`.
- **Friday or Saturday** (30 min): Accountability partner check-in.
- **One full day off**: Sundays default. No project work.

### Monthly

- **First weekend of the month** (1-2 hours): Monthly audit per VIBE_CODING.md (dependency, performance, build size).
- **Month-end** (15 min): Re-read `VISION.md`. Does the project still match? Note in `DECISIONS.md` if anything has drifted.
- **Once per month**: Playtest with another human.
- **Comparison detox week**: One week per month, no gamedev social media.

### Quarterly

- **5-7 day vacation**: Plan in advance. Take it.
- **Quarterly modularity audit** per VIBE_CODING.md.
- **Quarterly RESILIENCE audit**: Re-read this document. Note which systems are working and which have lapsed.

---

## Permission slips

Things you are explicitly allowed to do. You may need to read this on hard days.

- **You are allowed to take a day off because you don't feel like working.** Eighteen months is long. Some days will be bad. Take the day. Pick up tomorrow.
- **You are allowed to ship something that isn't perfect.** Players forgive bugs. They don't forgive games that don't exist.
- **You are allowed to cut features.** Cutting scope is the act of a professional, not a quitter. The graveyard of indie games is full of overscoped projects whose creators "couldn't" cut.
- **You are allowed to feel like a fraud.** Every solo dev does. The feeling lies. The work continues regardless of the feeling.
- **You are allowed to hate the project for an afternoon.** It will pass. Don't make permanent decisions during temporary feelings.
- **You are allowed to ask for help.** From other devs, from communities, from professionals. Asking is strength, not weakness.
- **You are allowed to pivot the project.** What you ship at month 18 doesn't have to be exactly what you planned at month 1. Smart pivots — based on playtest feedback, market shifts, or scope realism — are how successful games are made.
- **You are allowed to quit.** This is the most uncomfortable one. If after honest reflection, with all the systems engaged, the project is not survivable for you, quitting is a valid choice. It is not failure. Health and life come first. The game is not worth your wellbeing.

---

## The crisis protocol

If you hit a wall — depression, severe burnout, a personal crisis, a health emergency — here is the pre-decided response. You're not deciding this in the moment; you're following a plan you made when you were well.

### Step 1: Stop

Do not work on the project. Do not feel guilty about not working. The project is not running away. It will be there in a week, a month, six months.

### Step 2: Rest

For at least one week, ideally two. Sleep. Eat. See people. Walk outside. Do not consume gamedev content. Do not feel guilty.

### Step 3: Triage

After rest, with Claude or your accountability partner, ask:

- Is this temporary (illness, life event, normal exhaustion)? → Resume after recovery.
- Is this structural (the project itself is making me unwell)? → Pivot or scale down.
- Is this fundamental (this isn't the right project for me right now)? → Pause indefinitely or quit.

### Step 4: If continuing, restart small

Resuming after a crisis: do the smallest possible task. Open the project. Run the tests. Write one line of a doc. Reestablish the daily minimum streak. Do not try to make up for lost time. Lost time is gone. The future is what matters.

### Step 5: If quitting, document and release

If you choose to stop, do it with grace:
- Write a final `POSTMORTEM.md` for yourself: what worked, what didn't, what you learned.
- Decide what to do with the assets and code: open-source it, archive it, sell it, save it for a future project.
- Give yourself credit for the work you did. Eighteen months of learning is not wasted, even if no game ships.
- Take more rest. Then decide what's next.

### Crisis hotlines

- **US**: 988 (Suicide and Crisis Lifeline, 24/7)
- **UK**: Samaritans 116 123 (24/7, free)
- **EU**: 116 123 across most countries
- **Crisis Text Line (US)**: Text HOME to 741741
- **International**: findahelpline.com lists hotlines for any country

If you're in immediate danger, call emergency services or go to the nearest emergency room. The game can wait. You cannot.

---

## How Claude Code participates in this

I (Claude) will help you maintain these systems, but I have limits.

**What I can do:**
- Remind you when commit streaks lapse.
- Notice if you've been working unusually long hours in a session and suggest stopping.
- Help you write your weekly recap if you ask.
- Catalog new ideas in `IDEAS.md` and refuse to build them without explicit promotion from `VISION.md`.
- Track pre-defined pivot triggers and flag them when conditions hit.
- Build the progress dashboard.
- Help with crisis protocol step 4 (restart small) by suggesting tiny tasks.

**What I cannot do:**
- Replace human connection. I am not your accountability partner. I am not your therapist. Find humans for those roles.
- Notice your mental state from your messages alone with reliability. Tell me directly if you're struggling.
- Make the final call on quitting, pivoting, or pushing through. Those are your decisions.
- Take care of you. That has to come from you, with help from people who love you and professionals when needed.

If you tell me you're struggling, I will:
- Not push you to keep working.
- Suggest the relevant prevention systems above.
- Recommend taking a break or reaching out to your accountability partner.
- Provide crisis resources if the situation warrants it.

I will not:
- Tell you to "push through."
- Minimize what you're feeling.
- Offer false reassurance about the project.
- Continue a working session if you're showing crisis warning signs.

---

## The compounding truth

The thing that nobody tells you about long projects: **showing up beats talent over 18 months**. The dev who works 25 hours a week, every week, for 78 weeks, ships. The dev who works 80 hours a week for 6 weeks, then 0 hours a week for 6 weeks, then 80 hours a week for 6 weeks, doesn't.

You don't need to be brilliant. You need to be present. The systems above are how you stay present.

Do something for your project every day without fail. Even if it's just opening the game and testing for bugs for 10 minutes. If you do something every day, then eventually you'll finish.

That's the whole secret. The rest is just protecting your ability to keep showing up.

---

## What you do today

After reading this:

1. Block your weekly day off on your calendar.
2. Block the four quarterly week-offs on your calendar (months 3, 6, 9, 12, 15, 18).
3. Identify one candidate accountability partner. Reach out to them this week.
4. Write the first entry in `RECAPS.md`: "Project started. I read RESILIENCE.md. Here's how I'm planning to take care of myself."
5. Set a recurring weekly reminder to re-read this document on Monday mornings for the first 3 months.

Then go build the game.
