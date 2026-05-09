# MULTIPLAYER.md — Hoardseeker

> Duo mode design and networking architecture.
> NOT IMPLEMENTED in vertical slice. Architectural decisions in `ARCHITECTURE.md` keep duo cheap to add later.

---

## Design summary (recap from FULL_VISION.md)

- **Duo only** (2 players, never 3-4).
- **Split-party gameplay**: branching map nodes that split the duo into separate rooms, then reunite.
- **Shared loot pool** with negotiation UI.
- **Revives**: a downed player can be revived by their partner.
- **Run ends** when both players die simultaneously.
- **Separate ranked ladders** for solo and duo. Composite ELO. Seasonal resets.

---

## Networking architecture

### Transport: GodotSteam

We use GodotSteam (community Godot Steam SDK) as the transport layer. Reasons:

- **Steam relay servers** handle NAT traversal — no port forwarding for players.
- **No backend servers required** for matchmaking; Steam lobbies handle it.
- **Free for Steam-released games.**
- **Voice chat available** if we ever want it (we don't, but optionality).
- **Friend invites work natively** through Steam.

Tradeoff: Steam-only at launch. Console/Epic/GOG ports require an alternative transport (Epic Online Services has equivalent functionality).

### Sync model: Lockstep

The game is turn-based, so we have unlimited latency budget. Lockstep is dramatically simpler than client-server prediction.

**How it works:**

1. Both peers run the full simulation locally.
2. Player input becomes a `Command`.
3. The command is broadcast to both peers (including the originator).
4. Both peers apply the command to their local state when received.
5. Because the simulation is deterministic (`ARCHITECTURE.md`), both peers' states stay in sync.

**State hash check** every N commands or every turn boundary: peers exchange a hash of their `GameState`. If hashes diverge, log the desync, fall back to host's state.

### Authority model: Soft-host

One peer is designated host. Most decisions are symmetric (both peers compute the same result), but:

- **Host owns the seed** for each fight, dungeon generation, and loot drops. Sends seed to peer at start.
- **Host arbitrates conflicts** (e.g., both players try to grab the same loot — host's command wins).
- **Host's state is canonical** in case of desync.
- **Host migration on disconnect**: if host drops, the remaining peer becomes host and the dropped peer can reconnect as client.

Why "soft-host" rather than full client-server? Because both peers run the simulation, latency feels instant for both. We avoid the cost of a relay server. The host role is mostly bookkeeping, not authority.

### Lobby & matchmaking

- **Friend invites**: Steam invite system. Trivial.
- **Quickplay** (post-launch nice-to-have): Steam lobbies with skill-bracket matchmaking.
- **Discord-driven matchmaking**: most early players come pair-formed from social platforms. Don't over-build matchmaking pre-launch.

### Reconnect handling

- **Drop detection**: Steam's connection-lost callback.
- **Pause window**: 5 minutes. Game pauses. Remaining player sees "Partner disconnected, waiting...".
- **Reconnect**: returning peer rejoins lobby, receives full event log, replays it deterministically to catch up to current state.
- **Timeout**: if 5 minutes elapse, remaining player gets a choice — solo-finish the run (with score reduced by 50%) or end the run.

### Cheat resistance in duo

Same anti-cheat as solo: every leaderboard run has its `(seed, command_log)` validated server-side. Even in duo, both peers' commands are logged together. Server-side replay verifies the score.

A peer running a modified client to send fake commands would desync the other peer almost immediately, so peer-vs-peer cheating is largely self-defeating.

---

## Ranked system

### Composite ELO calculation

Per-run rating delta is computed from multiple factors:

```
delta = base_score_delta + bonuses + penalties

base_score_delta = sigmoid_curve(floors_reached, expected_floors_for_rating) * 30

bonuses:
  + crit_streak_bonus      (max +5 for 5+ consecutive crits)
  + glints_earned_bonus    (max +5 for max-glint run)
  + flawless_floor_bonus   (max +5 for no-damage floors)
  + duo_revive_bonus       (max +3 for 3+ partner revives, duo only)

penalties:
  - quick_death_penalty    (max -10 for dying in floor 1-2)
  - excessive_resting      (max -5 for too many rest rooms)
```

Sigmoid centered on the player's current rating. A 1500-rated player who reaches biome 2 gets a small positive delta; reaching biome 4 gets a large positive delta.

### Rating ranges

- **Bronze** (0-800): newer players, learning the systems
- **Silver** (800-1400): consistent biome 1-2 clears
- **Gold** (1400-2000): biome 2-3 regular, biome 4 occasional
- **Platinum** (2000-2600): biome 4 regular, building optimized strategies
- **Diamond** (2600-3200): top 5%, deep mastery
- **Master** (3200+): top 1%, ladder push

Per-class spotlight events (see below) have separate temporary ladders.

### Seasonal structure

- **Season length**: 10-12 weeks.
- **Reset behavior**: end-of-season rating compresses toward the floor. A 3000-rated player resets to ~2200 (keeping half the distance from base). New season opens at this soft floor.
- **Rewards**: top 100 players get a unique cosmetic (banner, profile frame). Top 1000 get a season badge. Everyone above Bronze gets a participation cosmetic.

### Daily seed mode

- **Same seed for all players each day.**
- **Solo daily** and **duo daily** are separate.
- **Score-based** ranking (not ELO — leaderboards just sort by score).
- **One attempt per day per mode.** No retries.
- **Resets at midnight UTC.**

### Class-spotlight (weekly events)

- **One class per week** is the spotlight class.
- **Temporary leaderboard** for that class only, runs from Monday to Sunday.
- **Top finishers get class-specific cosmetic** (alternate portrait, alternate ability icons, profile flair).
- **Auto-rotates** through all 12 classes. Every class gets a spotlight every 12 weeks.

This drives engagement with classes the player wouldn't otherwise pick. It's also a way to test class balance — high participation in spotlight = active player feedback per class.

---

## Backend architecture

### What we host

A small backend service for:

- **Account profiles** (display name, cosmetics, lifetime stats)
- **Leaderboard storage** (solo, duo, daily, class-spotlight)
- **Replay validation** (deterministic re-simulation of submitted runs)
- **ELO calculations** and seasonal resets
- **Telemetry ingest** (anonymized run data for balance analysis)

### What we don't host

- **Matchmaking servers** (Steam handles it)
- **Game servers** (peer-to-peer, no relay needed)
- **Save game storage** (Steam Cloud handles it)
- **Voice chat** (we don't have it; if added later, Steam handles it)

### Stack recommendation

- **Backend**: Go or Rust service. Stateless API workers, replay validators run as background jobs.
- **Database**: PostgreSQL for accounts and leaderboards. Redis for active session caching.
- **Hosting**: A single VPS or Fly.io / Railway deployment is sufficient through 100k DAU. No need to over-engineer.
- **Replay validation**: a headless Godot binary running command logs through the simulation. Can horizontal-scale as a worker pool if validation queue grows.
- **Cost target**: <$200/month for first year. <$1k/month at 100k DAU.

A single-developer-friendly option: **Supabase** (managed Postgres + auth + edge functions) for persistence + a small replay-validator worker on Fly.io. Total stack one person can operate.

### API endpoints (rough)

```
POST  /v1/auth/steam              # exchange Steam ticket for session token
GET   /v1/profile/:id             # public profile
PUT   /v1/profile                 # update own profile
POST  /v1/runs/submit             # submit run for validation + ranking
GET   /v1/runs/:id                # fetch run (for replay viewer)
GET   /v1/leaderboard/solo        # solo ladder, paginated
GET   /v1/leaderboard/duo         # duo ladder
GET   /v1/leaderboard/daily       # today's daily seeds
GET   /v1/leaderboard/spotlight   # current class-spotlight
GET   /v1/season                  # current season info
POST  /v1/telemetry               # anonymized run data
```

---

## Validation pipeline

When a run is submitted:

1. Client uploads `(seed, command_log, claimed_score, claimed_floors_reached, etc.)`.
2. Backend queues a validation job.
3. Worker spins up a headless Godot instance.
4. Worker loads the seed, replays every command, captures resulting state.
5. Worker compares replay's actual score/floors to claimed values.
6. **Match**: run is approved, ELO updated, leaderboard updated.
7. **Mismatch**: run rejected, flagged for review (auto-ban only on repeated rejections).

Validation latency target: <30 seconds for a typical 30-minute run. Most users don't see leaderboard updates instantly anyway, so this is fine.

---

## Build phase: when to add networking

Per `ROADMAP.md`, networking is added in months 13-16, after solo is feature-complete. Rough sub-phases:

1. **Lobby + connection** (2 weeks): Steam lobby creation, friend invites, host/client roles, connection lost handling.
2. **Lockstep command sync** (2 weeks): commands serialize and broadcast, both peers apply, state hash checks.
3. **Split-party UX** (3 weeks): the map has split nodes, both peers run their own room simultaneously, results sync at rejoin.
4. **Duo combat UI** (2 weeks): see partner's HP, hand, abilities; ping system; revive interaction.
5. **Loot negotiation UI** (1 week): shared loot pool with claim/decline/timer.
6. **Backend leaderboards + ELO** (3 weeks): API, validation pipeline, ranked ladders for both modes.
7. **Anti-cheat hardening** (2 weeks): replay validation, suspicious-pattern detection, ban tooling.
8. **Polish & desync chasing** (2 weeks): hunt down state divergence bugs, reconnect testing.

Total: ~17 weeks (~4 months). This is what the timeline budgets.

---

## Known risks

- **Determinism violations**: the #1 cause of multiplayer roguelike bugs. A single `randf()` slipped into game logic = desync. Mitigation: linter that scans for banned RNG calls in `src/core/` and `src/systems/`.
- **Floating-point determinism**: floats are deterministic within a single CPU architecture. Cross-platform play (e.g., Linux vs. Windows) needs validation. Mitigation: use ints for all gameplay math; floats only for visuals.
- **Slow replay validation queue at scale**: if leaderboards become popular, validation backlog grows. Mitigation: scale validation workers horizontally; deprioritize validation for runs that don't make top 10000.
- **Steam outages**: Steam down = duo down. Mitigation: solo always works offline; communicate Steam status clearly to user when matchmaking fails.
- **Toxic duo behavior**: griefing partners by suiciding. Mitigation: report/block system; ELO loss for solo-quitting after partner death; quickplay matchmaking only paired with people who've duo'd before.

---

## What duo *isn't*

To prevent scope creep:

- ❌ Voice chat (text only)
- ❌ Spectator mode at launch (post-launch nice-to-have)
- ❌ Cross-play with consoles at launch
- ❌ 3-4 player co-op (the design lives or dies on the duo intimacy)
- ❌ Duo-only content (no abilities or artifacts that only work in duo)
- ❌ Trade systems (no trading items between accounts; loot stays in-run)
- ❌ Guilds, friends lists beyond Steam's (Steam handles social layer)
