# CONTENT.md — Hoardseeker

> All gameplay content (classes, subclasses, abilities, artifacts, monsters) is authored as `.tres` resources.
> This document specifies the data shapes and authoring guidelines.
> The vertical slice ships with Fighter content only. Full launch content is the ~12-month build.

---

## Authoring philosophy

1. **Content is data, never code.** A new spell is a new `.tres` file. A new monster is a new `.tres` file.
2. **Mechanics are composable.** A small set of effect primitives (damage, heal, status, push, draw, etc.) combine into any ability.
3. **Naming matters.** Every class, ability, artifact gets a flavorful name *and* a clear mechanical description. Both are reviewed.
4. **Balance is iterated.** Initial values are educated guesses. Telemetry from playtests adjusts them.

---

## Data shapes

### `ClassDef`

```gdscript
class_name ClassDef extends Resource

@export var id: String = ""                          # "fighter", unique
@export var display_name: String = ""                # "Fighter"
@export var description: String = ""                 # one-line tagline
@export var difficulty: String = "EASY"              # EASY, MEDIUM, HARD
@export var portrait_set: Array[Texture2D] = []      # 3 random appearances
@export var starting_hp: int = 12
@export var starting_ac: int = 14
@export var starting_action_points: int = 3
@export var hit_die: int = 10                        # d10 per level for HP
@export var primary_stat: String = "STR"             # which stat boosts attacks
@export var resource_type: String = "AP_ONLY"        # AP_ONLY, SPELL_SLOTS, RAGE, KI, etc.
@export var starting_abilities: Array[AbilityDef] = []
@export var ability_pool: Array[AbilityDef] = []      # what they can draft from
@export var subclass_options: Array[SubclassDef] = [] # 3 per class
@export var unlock_condition: String = ""            # "" = unlocked at start
@export var lore: String = ""                        # 2-3 paragraphs of flavor
```

### `RaceDef`

```gdscript
class_name RaceDef extends Resource

@export var id: String = ""                          # "human", unique
@export var display_name: String = ""                # "Human"
@export var description: String = ""                 # one-line tagline
@export var stat_modifiers: Dictionary = {}          # {"STR": 1, "CON": 1} small bumps
@export var perks: Array[RacePerk] = []              # mechanical features
@export var portrait_overlay_color: Color           # subtle visual differentiator
@export var size_class: String = "MEDIUM"            # SMALL, MEDIUM (affects some abilities)
@export var unlock_condition: String = ""            # "" = unlocked at start
@export var lore: String = ""                        # 2-3 paragraphs of flavor
```

### `RacePerk`

A perk is a mechanical hook attached to a race. Perks are passive triggers, similar to artifact effects.

```gdscript
class_name RacePerk extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var trigger: String = "PASSIVE"              # PASSIVE, ON_HIT, ON_CRIT, ON_FLOOR_START, etc.
@export var effect_id: String = ""                   # links to effect implementation
@export var effect_data: Dictionary = {}             # parametrize the effect
@export var charges_per_fight: int = 0               # 0 = unlimited / passive, N = limited
```

### `SubclassDef`

```gdscript
class_name SubclassDef extends Resource

@export var id: String = ""
@export var display_name: String = ""                 # "Champion"
@export var description: String = ""                  # tagline
@export var class_id: String = ""                     # which class it belongs to
@export var passive_effect: String = ""               # e.g., "Crit on 19 or 20"
@export var passive_data: Dictionary = {}             # data backing the passive
@export var ability_pool: Array[AbilityDef] = []      # subclass-specific abilities
@export var starting_ability: AbilityDef             # one auto-granted on draft
@export var lore: String = ""
```

### `AbilityDef`

```gdscript
class_name AbilityDef extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""                  # tooltip text
@export var class_id: String = ""                     # owning class
@export var subclass_id: String = ""                  # "" if class-wide
@export var min_level: int = 1
@export var cost_action_points: int = 1
@export var cost_resource: int = 0                    # spell slot, ki point, etc.
@export var cooldown_turns: int = 0                   # 0 = no cooldown
@export var target_type: String = "SINGLE_ENEMY"      # SINGLE_ENEMY, ALL_ENEMIES, SELF, ALLY, ROW
@export var range_type: String = "MELEE"              # MELEE, RANGED, ANY
@export var attack_roll: bool = true                  # does it require an attack roll?
@export var save_required: String = ""                # "" or "DEX", "WIS", etc.
@export var save_dc_base: int = 10
@export var damage_count: int = 0
@export var damage_sides: int = 0
@export var damage_type: String = "PHYSICAL"          # PHYSICAL, FIRE, COLD, POISON, etc.
@export var heal_count: int = 0
@export var heal_sides: int = 0
@export var status_effects: Array[StatusEffectDef] = []
@export var custom_effect_id: String = ""             # for one-off mechanics
@export var icon: Texture2D
@export var sound_id: String = ""
@export var animation_id: String = ""
```

### `ArtifactDef`

```gdscript
class_name ArtifactDef extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var rarity: String = "COMMON"                 # COMMON, RARE, MYTHIC
@export var icon: Texture2D
@export var pickup_narration_id: String = ""         # narrator line on first pickup
@export var triggers: Array[ArtifactTrigger] = []     # when does it activate?
@export var effects: Array[ArtifactEffect] = []       # what does it do?
@export var stat_modifiers: Dictionary = {}           # passive stat changes
@export var lore: String = ""
@export var class_synergy: Array[String] = []         # ["wizard", "sorcerer"] hints
```

### `MonsterDef`

```gdscript
class_name MonsterDef extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var biome_id: String = ""
@export var tier: String = "REGULAR"                  # REGULAR, ELITE, BOSS
@export var portrait: Texture2D
@export var hp_base: int = 10
@export var ac: int = 12
@export var action_points: int = 2
@export var stats: Dictionary = {}                    # STR, DEX, CON, INT, WIS, CHA
@export var resistances: Array[String] = []
@export var weaknesses: Array[String] = []
@export var abilities: Array[AbilityDef] = []         # what they can do
@export var ai_behavior: String = "AGGRESSIVE"        # AGGRESSIVE, DEFENSIVE, SUPPORT, RANDOM
@export var loot_table_id: String = ""
@export var death_narration_chance: float = 0.0       # rare death lines
```

### `BiomeDef`

```gdscript
class_name BiomeDef extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var floor_count: int = 10
@export var monster_pool: Array[MonsterDef] = []
@export var elite_pool: Array[MonsterDef] = []
@export var boss: MonsterDef
@export var background_textures: Dictionary = {}      # room_type -> texture
@export var music_combat: AudioStream
@export var music_explore: AudioStream
@export var music_boss: AudioStream
@export var ambient_sound: AudioStream
@export var artifact_pool: Array[ArtifactDef] = []    # biome-flavored loot
@export var intro_narration_id: String = ""
@export var boss_intro_narration_id: String = ""
```

---

## The Fighter (vertical slice content)

The Fighter is the only complete class in the slice. Full spec below — this is the template for the other 11.

### Class definition

```yaml
id: fighter
display_name: Fighter
description: A martial veteran. Reliable damage, no surprises, all impact.
difficulty: EASY
starting_hp: 14
starting_ac: 16
starting_action_points: 3
hit_die: 10
primary_stat: STR
resource_type: AP_ONLY
```

### Fighter abilities (20 total — 8 base + 4 per subclass)

**Base abilities (available to all Fighter subclasses):**

| ID | Name | Cost | Description |
|---|---|---|---|
| `fighter_slash` | Slash | 1 AP | d20 attack, 1d8 damage. The bread and butter. |
| `fighter_cleave` | Cleave | 2 AP | Attack two adjacent enemies, 1d8 each. |
| `fighter_power_strike` | Power Strike | 2 AP | 1d12 damage, +2 to attack roll. |
| `fighter_shield_bash` | Shield Bash | 1 AP | 1d4 damage + STUN on save fail (DC 14 CON). |
| `fighter_second_wind` | Second Wind | 1 AP | Heal 1d10. Once per fight. |
| `fighter_riposte` | Riposte | 0 AP (reaction) | When attacked and miss, counter-attack 1d8. Once per turn. |
| `fighter_battle_cry` | Battle Cry | 1 AP | Self: +2 to attack rolls for 3 turns. |
| `fighter_action_surge` | Action Surge | 0 AP | Gain +2 AP this turn. Once per fight. |

**Champion subclass (crit-fishing):**

- Passive: Crits trigger on natural 19 or 20.
- `champion_great_weapon_master` — Heavy attack: 2d10, but -2 attack roll. 2 AP.
- `champion_overwhelm` — On crit, attack again for free. Ability passive.
- `champion_unstoppable` — Cannot be stunned for 3 turns. 1 AP.
- `champion_critical_finisher` — Execute: 50%+ chance to instakill any enemy below 25% HP. 3 AP.

**Battle Master subclass (tactical maneuvers):**

- Passive: Each round, gain 1 maneuver die (d6).
- `bm_disarm` — Spend maneuver: enemy drops weapon, -2 to attacks for 3 turns.
- `bm_trip_attack` — Spend maneuver: knock enemy prone, advantage on next attack.
- `bm_commander_strike` — Spend maneuver: ally gets bonus attack.
- `bm_evasive_footwork` — Spend maneuver: +AC equal to maneuver die for 1 round.

**Eldritch Knight subclass (sword + spell):**

- Passive: Can use 2 wizard cantrips, gains 2 spell slots per fight.
- `ek_shield` — Reaction: +5 AC against one attack. Costs spell slot.
- `ek_shocking_grasp` — Melee 1d8 lightning + STUN on hit. Costs spell slot.
- `ek_burning_hands` — Cone fire: all front-row enemies, 3d6, DEX save halves. Costs spell slot.
- `ek_war_magic` — After casting a spell, free weapon attack.

### Fighter starting kit

A new Fighter run begins with: Slash + Power Strike + Second Wind. (3 abilities, room to draft into more.)

---

## The Lich King (vertical slice boss)

```yaml
id: lich_king
display_name: The Lich King
biome_id: forgotten_crypt
tier: BOSS
hp_base: 220
ac: 18
action_points: 4
phases: 3
```

### Phase 1 (HP 100% → 66%)
- Uses staff melee + necrotic bolt + summon skeleton minion (1 per turn).
- Telegraphed every 3 turns: "Channeling..." → next turn casts Wave of Death (all players, 3d6 necrotic, CON save halves).

### Phase 2 (HP 66% → 33%)
- Drops staff. Becomes airborne. Now teleports between front and back rows.
- Phylactery appears as a separate target (HP 50). If destroyed, boss can't revive in phase 3.
- Adds: Dispel Heal (cancels next heal cast on player).

### Phase 3 (HP 33% → 0%)
- Berserk: 6 AP per turn.
- All necrotic damage doubles.
- If phylactery survived: revives at 30% HP once.

### Narration

- Intro: "*The Lich King's bone throne creaks as you enter. He has waited a thousand years for this fight. He hopes you will be more interesting than the last.*"
- Phase 2 transition: "*The staff falls. The Lich King rises.*"
- Death: "*A thousand years undone in an evening. He almost looks relieved.*"

---

## Artifact catalog (vertical slice — 15 of ~80)

A representative cross-section. Full catalog in `data/artifacts/`.

### Common (slice: 8)
- **Belt of Strength**: +1 STR, +1 to melee damage rolls.
- **Boots of Speed**: +1 to initiative rolls.
- **Cloak of Resistance**: +1 to all saves.
- **Iron Ration**: Heal 1d6 between fights, once per floor.
- **Lockpick**: 50% chance to skip locked-door encounters without combat.
- **Lucky Coin**: Once per fight, reroll any d20.
- **Smelling Salts**: Cure stun on self, once per fight.
- **Whetstone**: First attack of every fight has advantage.

### Rare (slice: 5)
- **Crown of Glass**: When you crit, all enemies take half the damage you dealt.
- **Ring of Reckless Strength**: +2 damage on all attacks, -2 AC.
- **Hourglass of the Veteran**: First 2 turns of every fight, +1 AP.
- **Vial of Liquid Courage**: Immune to fear and curse effects.
- **Banner of the Brave**: Every 5th attack auto-crits.

### Mythic (slice: 2)
- **The Lich's Heart**: You die at -10 HP instead of 0, but you cannot be healed above 50% max HP.
- **Crown of the Forgotten King**: Skeletons and undead are friendly to you. They join you as minions in combat. You cannot enter holy biomes.

(The Lich's Heart is intentionally a Crypt-themed mythic. Drops are lore-aware.)

---

## Monster catalog (vertical slice — 12 of ~60)

Forgotten Crypt biome only. Full catalog in `data/monsters/`.

### Regular (8)
- **Skeleton Archer** — ranged, low HP, low AC.
- **Skeleton Warrior** — melee, balanced.
- **Skeleton Mage** — ranged caster, weak to physical.
- **Zombie** — slow, high HP, high physical resistance.
- **Ghoul** — fast, paralysis bite (DEX save).
- **Wraith** — incorporeal, half damage from physical, weak to radiant.
- **Bone Golem** — high HP and AC, slow, immune to status.
- **Crypt Spider** — fast, poison bite, swarms.

### Elite (3)
- **Death Knight** — undead Fighter analogue, drops the Crown of the Forgotten King.
- **Banshee** — wail = AOE fear save, drops the Vial of Liquid Courage.
- **Necromancer** — summons skeletons, drops a random rare artifact.

### Boss (1)
- **The Lich King** — see above.

---

## Authoring rate

For planning purposes:

- **A new ability**: ~2 hours to author (data + icon + balancing).
- **A new artifact**: ~2 hours.
- **A new monster**: ~6 hours (data + portrait + AI behavior + animations).
- **A new class**: ~80 hours (full kit, 3 subclasses, integration testing).
- **A new biome**: ~120 hours (data + monsters + boss + art + music + narration).

Solo dev + AI assistance puts the content total at roughly:
- 12 classes × 80h = 960h (~6 months full-time)
- 4 biomes × 120h = 480h (~3 months full-time)
- Artifacts/monsters/abilities filling = ~3-4 months full-time

This is why the launch timeline is 16-22 months. Content is the load.

---

## Localization readiness

- **All player-facing strings** go through a string table (`tr("ability_fighter_slash_name")`).
- **No hardcoded English** in `.tres` files for display text. Use string IDs.
- **Narration IDs** map to recorded lines. Subtitle text accompanies every line.
- **Cultural review pass** before localization commits — some D&D fantasy concepts don't translate cleanly.

Launch in English. Major languages (German, French, Spanish, Portuguese-BR, Russian, Simplified Chinese, Japanese, Korean) within 6 months post-launch.
