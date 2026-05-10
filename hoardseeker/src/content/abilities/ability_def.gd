## AbilityDef
##
## Static definition of an ability — its cost, dice, modifiers. Pure data.
## Lives as a `.tres` file under `src/content/abilities/`. The filename
## (minus extension) is conventionally the same as the `id` field.
##
## This is the first concrete example of CLAUDE.md hard rule #4:
## "content is data, not code." Adding a new ability must not require
## any code change — only a new `.tres` and (eventually) a string-table
## entry for its name and description.
##
## Resolved by `UseAbilityCommand`, which loads the def by id-as-path
## convention and runs the resolution dance against it. A future chunk
## may introduce a registry on GameState to cache loaded defs; until
## then, direct `load()` is fine because Godot caches Resource loads.
##
## Localization-readiness: name and description fields hold *string IDs*,
## not literal English. The string table doesn't exist yet — when it
## does, ability lookup will route through `tr(name_string_id)`. See
## CONTENT.md "Localization readiness."
##
## Knows about: nothing. Pure data resource.
## Used by: UseAbilityCommand, eventually a future AbilityRegistry.

class_name AbilityDef extends Resource

# === Identity ===
@export var id: String = ""                          # matches the .tres filename, e.g. "fighter_slash"
@export var name_string_id: String = ""              # e.g. "ability_fighter_slash_name"
@export var description_string_id: String = ""      # e.g. "ability_fighter_slash_description"

# === Cost ===
@export var ap_cost: int = 1

# === Targeting ===
## Number of distinct targets the ability requires. Default 1 (single-target).
## Cleave-style abilities set this to 2; future "all enemies in zone" abilities
## will need a richer mechanism (see IDEAS.md when that question lands).
##
## UseAbilityCommand validates that the caller supplied exactly target_count
## target_ids; mismatched counts are rejected.
@export var target_count: int = 1

# === Attack roll ===
## Bonus added to the d20 attack roll (negative values valid for risk-taking abilities).
@export var attack_modifier: int = 0

# === Damage ===
## Damage = sum of (damage_dice_count d damage_dice_sides) + damage_modifier.
## Crits add an extra (damage_dice_count d damage_dice_sides) on top.
@export var damage_dice_count: int = 1
@export var damage_dice_sides: int = 8
@export var damage_modifier: int = 0

## Damage type — used by target resistances to compute final damage.
## Conventional values: "physical", "fire", "cold", "necrotic", "radiant",
## "poison", etc. Defaults to "physical" so existing damage abilities
## (slash, cleave, power_strike, all monster basic attacks) remain
## physical without editing their .tres.
@export var damage_type: String = "physical"

# === Heal ===
## Optional heal payload. When `heal_dice_count > 0` the ability is
## treated as a heal — UseAbilityCommand skips the attack roll entirely
## and applies (heal_dice_count d heal_dice_sides) + heal_modifier as
## healing (clamped at max_hp), emitting a HEALED event.
##
## A heal ability typically also has zero damage dice (the two are
## mutually exclusive by convention), but nothing structurally enforces
## that. If both are set, the dispatch in UseAbilityCommand currently
## takes the heal path. Hybrid abilities (damage + self-heal) would
## need a richer dispatch — defer until that's a real requirement.
@export var heal_dice_count: int = 0
@export var heal_dice_sides: int = 0
@export var heal_modifier: int = 0

# === Status effects to apply on success ===
## Effects to apply to each target after a successful damage / heal.
## "Success" means the damage hit (not missed) OR the heal landed
## (heals don't miss). Multiple effects can be declared per ability —
## e.g., fighter_shield_bash applies STUN; a future "Frostbite" might
## apply both SLOW and a damage-over-time.
##
## Stacking rule (chunk-K design call): when applying an effect with
## an effect_id already present on the target, REFRESH the duration to
## max(existing.duration_remaining, incoming.duration_remaining). The
## existing effect's params are preserved (the second cast doesn't
## overwrite — match D&D 5e refresh semantics).
##
## Each Array entry is a fully-formed StatusEffect with effect_id,
## duration_remaining, and params populated. UseAbilityCommand
## DUPLICATES each effect at apply time so the def's instances aren't
## shared with the target's status_effects array.
##
## Empty array (default) = ability applies no effects on success.
@export var applies_effects: Array[StatusEffect] = []

# === Execute (instakill at low HP) ===
## Optional "execute" payload. When `execute_threshold_pct > 0` and
## `execute_chance > 0`, UseAbilityCommand checks BEFORE the attack roll
## whether target.hp / target.max_hp < execute_threshold_pct. If yes,
## rolls rng.chance(execute_chance); on success the target is instakilled
## (target.hp = 0, EXECUTED + ACTOR_DEFEATED events fire) and the normal
## attack/damage flow is skipped entirely.
##
## On execute failure (chance roll missed) OR when target is above
## threshold, the ability falls through to the normal damage path. So
## execute abilities should also have a sensible damage payload — a
## fallback for when the execute doesn't land.
##
## Currently checked PRE-damage (target's HP at time of casting). The
## alternative is post-damage check ("finishing blow" flavor); see the
## chunk-H DECISIONS entry for why pre-damage was picked.
@export var execute_threshold_pct: float = 0.0
@export var execute_chance: float = 0.0
