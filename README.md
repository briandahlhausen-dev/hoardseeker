# Hoardseeker

> *Roll the dice. Raid the dungeon. Don't die alone.*

A D&D-inspired roguelike deckbuilder. Solo + duo co-op. Ranked seasonal ladders. Targeting Steam (PC) at launch.

Built in Godot 4 by one non-technical developer with Claude Code as the primary engineer.

---

## Project mode

**Bootstrap (<$5k total project budget).** No contracted illustrator, composer, or voice actor at launch. See `DECISIONS.md` (entries dated 2026-05-08) for the full production model.

- Art: AI-generated stylized illustration with mandatory hand cleanup, per the revised AI-content rule in `VIBE_CODING.md`
- Music: curated royalty-free orchestral + one ~$300 commissioned signature theme
- Voice: text-only narration, no voice acting in shipped product
- Launch: 12 classes, 2 biomes (Forgotten Crypt + Sunken Halls), with biomes 3-4 as free post-launch updates

---

## Where to start

If you're picking up this project for the first time (or after a long break), read the docs in this order:

1. `CLAUDE.md` — project index, hard rules, current state
2. `VIBE_CODING.md` — how we work (non-technical user + AI engineer)
3. `RESILIENCE.md` — burnout prevention, pivot triggers
4. `SESSION_PROTOCOL.md` — session-management discipline
5. `DECISIONS.md` — canonical decision log
6. `VISION.md` — north star
7. `ARCHITECTURE.md` — code structure (read before writing any code)
8. `VERTICAL_SLICE.md` — current active scope (months 1-4)
9. `FULL_VISION.md` — complete launch design
10. `CONTENT.md` — classes, races, abilities, artifacts, monsters
11. `MULTIPLAYER.md` — duo mode design, networking, ranked
12. `ROADMAP.md` — phased plan from prototype to launch

Companion files (created lazily as needed):
- `RECAPS.md` — weekly recaps
- `IDEAS.md` — deferred ideas
- `TECH_DEBT.md` — known issues

---

## Repository layout

```
Hoardseeker/                  ← project root (this directory)
├── *.md                      ← all design docs at root
├── LICENSE                   ← all rights reserved
├── README.md                 ← this file
├── .gitignore
└── hoardseeker/              ← Godot project root (Phase 0 setup pending)
    ├── project.godot         ← (not yet created)
    ├── src/                  ← (not yet created)
    ├── tests/                ← (not yet created)
    ├── assets/               ← (not yet created)
    └── ...
```

Per `ARCHITECTURE.md`, the Godot project is structured for determinism, the command pattern, and event sourcing — load-bearing for replay-based anti-cheat and lockstep duo networking.

---

## Status

- **Current phase**: Phase 0 (project setup)
- **Target launch**: 18-20 months from project start (with buffer to 22)
- **Last major milestone**: Bootstrap realignment + session protocol installed (2026-05-08)

For current session pickup state, see the "Currently in flight" section at the bottom of `CLAUDE.md`.

---

## License

All rights reserved. See `LICENSE` for full terms.

This is a private development repository. The project is not open source.
