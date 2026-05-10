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
