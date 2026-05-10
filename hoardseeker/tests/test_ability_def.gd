## test_ability_def.gd
##
## Verifies the AbilityDef resource class and the canonical first ability,
## fighter_slash.tres. This is the regression net for the data side of
## CLAUDE.md hard rule #4 ("content is data, not code"):
##
##   - Default-construct an AbilityDef in memory; sensible defaults.
##   - Load `fighter_slash.tres` from disk; it parses, the script is
##     bound, and the field values match what CONTENT.md declares.
##
## If someone edits the .tres and accidentally drops the script binding
## or changes the canonical stats, this test fires.
##
## Uses preload() / load() in the same way the real production code
## does. fighter_slash.tres is a real, shipped file.

extends RefCounted

const AbilityDef = preload("res://src/content/abilities/ability_def.gd")

const FIGHTER_SLASH_PATH := "res://src/content/abilities/fighter_slash.tres"
const FIGHTER_CLEAVE_PATH := "res://src/content/abilities/fighter_cleave.tres"
const FIGHTER_POWER_STRIKE_PATH := "res://src/content/abilities/fighter_power_strike.tres"
const FIGHTER_SECOND_WIND_PATH := "res://src/content/abilities/fighter_second_wind.tres"
const CHAMPION_GREAT_WEAPON_MASTER_PATH := "res://src/content/abilities/champion_great_weapon_master.tres"
const CHAMPION_CRITICAL_FINISHER_PATH := "res://src/content/abilities/champion_critical_finisher.tres"
const FIGHTER_SHIELD_BASH_PATH := "res://src/content/abilities/fighter_shield_bash.tres"


func run_tests() -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_test_default_construction())
	failures.append_array(_test_fighter_slash_tres_loads())
	failures.append_array(_test_fighter_slash_canonical_stats())
	failures.append_array(_test_load_via_resource_loader_exists())
	failures.append_array(_test_fighter_cleave_canonical_stats())
	failures.append_array(_test_fighter_power_strike_canonical_stats())
	failures.append_array(_test_target_count_defaults_to_one())
	# Phase C — heal-path coverage on the data side
	failures.append_array(_test_heal_fields_default_to_zero())
	failures.append_array(_test_fighter_second_wind_canonical_stats())
	# Phase F — damage type defaults
	failures.append_array(_test_damage_type_defaults_to_physical())
	# Phase G — first Champion subclass ability (pure data add, no architecture)
	failures.append_array(_test_champion_great_weapon_master_canonical_stats())
	# Phase H — execute mechanic
	failures.append_array(_test_execute_fields_default_to_zero())
	failures.append_array(_test_champion_critical_finisher_canonical_stats())
	# Phase L — save throw fields + fighter_shield_bash (first ability that uses them)
	failures.append_array(_test_save_fields_default_to_no_save())
	failures.append_array(_test_fighter_shield_bash_canonical_stats())
	return failures


# Fresh in-memory AbilityDef should construct cleanly with sensible defaults.
func _test_default_construction() -> Array[String]:
	var def: AbilityDef = AbilityDef.new()
	var failures: Array[String] = []
	if def.id != "":
		failures.append("default_construction: id should be empty, got '%s'" % def.id)
	if def.ap_cost != 1:
		failures.append("default_construction: ap_cost should default to 1, got %d" % def.ap_cost)
	if def.damage_dice_count != 1:
		failures.append("default_construction: damage_dice_count should default to 1, got %d" % def.damage_dice_count)
	if def.damage_dice_sides != 8:
		failures.append("default_construction: damage_dice_sides should default to 8, got %d" % def.damage_dice_sides)
	if def.attack_modifier != 0:
		failures.append("default_construction: attack_modifier should default to 0, got %d" % def.attack_modifier)
	return failures


# fighter_slash.tres exists on disk and loads as a non-null AbilityDef.
# This is what UseAbilityCommand will exercise at runtime.
func _test_fighter_slash_tres_loads() -> Array[String]:
	var loaded: Resource = load(FIGHTER_SLASH_PATH)
	var failures: Array[String] = []
	if loaded == null:
		failures.append("tres_loads: load() returned null for %s" % FIGHTER_SLASH_PATH)
		return failures
	if not (loaded is AbilityDef):
		failures.append("tres_loads: loaded resource is not an AbilityDef (got %s)" % loaded.get_class())
	return failures


# fighter_slash.tres carries the canonical stats per CONTENT.md.
# If someone "improves" the .tres by changing values, this test catches it.
# The canonical line:
#   "fighter_slash | Slash | 1 AP | d20 attack, 1d8 damage. The bread and butter."
func _test_fighter_slash_canonical_stats() -> Array[String]:
	var def: AbilityDef = load(FIGHTER_SLASH_PATH) as AbilityDef
	var failures: Array[String] = []
	if def == null:
		failures.append("canonical_stats: fighter_slash.tres failed to load as AbilityDef — can't check stats")
		return failures
	if def.id != "fighter_slash":
		failures.append("canonical_stats: id should be 'fighter_slash', got '%s'" % def.id)
	if def.ap_cost != 1:
		failures.append("canonical_stats: ap_cost should be 1, got %d" % def.ap_cost)
	if def.damage_dice_count != 1:
		failures.append("canonical_stats: damage_dice_count should be 1, got %d" % def.damage_dice_count)
	if def.damage_dice_sides != 8:
		failures.append("canonical_stats: damage_dice_sides should be 8, got %d" % def.damage_dice_sides)
	if def.damage_modifier != 0:
		failures.append("canonical_stats: damage_modifier should be 0, got %d" % def.damage_modifier)
	if def.attack_modifier != 0:
		failures.append("canonical_stats: attack_modifier should be 0, got %d" % def.attack_modifier)
	# String IDs should reference the eventual table, not contain literal English.
	if def.name_string_id == "" or def.name_string_id.contains(" "):
		failures.append("canonical_stats: name_string_id should be a string-table id (got '%s')" % def.name_string_id)
	return failures


# ResourceLoader.exists() is what UseAbilityCommand uses to detect missing
# defs gracefully. Verify it returns true for fighter_slash and false for
# a fictional ability id.
func _test_load_via_resource_loader_exists() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(FIGHTER_SLASH_PATH):
		failures.append("resource_loader: ResourceLoader.exists() should be true for fighter_slash.tres")
	if ResourceLoader.exists("res://src/content/abilities/this_ability_does_not_exist.tres"):
		failures.append("resource_loader: ResourceLoader.exists() should be false for a fictional ability id")
	return failures


# fighter_cleave.tres: 2 AP, two adjacent enemies, 1d8 each per CONTENT.md.
# This is the canonical multi-target ability; target_count=2 is what makes
# it different from a copy of slash.
func _test_fighter_cleave_canonical_stats() -> Array[String]:
	var def: AbilityDef = load(FIGHTER_CLEAVE_PATH) as AbilityDef
	var failures: Array[String] = []
	if def == null:
		failures.append("cleave: fighter_cleave.tres failed to load as AbilityDef")
		return failures
	if def.id != "fighter_cleave":
		failures.append("cleave: id should be 'fighter_cleave', got '%s'" % def.id)
	if def.ap_cost != 2:
		failures.append("cleave: ap_cost should be 2, got %d" % def.ap_cost)
	if def.target_count != 2:
		failures.append("cleave: target_count should be 2 (the whole point), got %d" % def.target_count)
	if def.damage_dice_count != 1:
		failures.append("cleave: damage_dice_count should be 1, got %d" % def.damage_dice_count)
	if def.damage_dice_sides != 8:
		failures.append("cleave: damage_dice_sides should be 8, got %d" % def.damage_dice_sides)
	if def.attack_modifier != 0:
		failures.append("cleave: attack_modifier should be 0, got %d" % def.attack_modifier)
	return failures


# fighter_power_strike.tres: 2 AP, single target, 1d12 damage, +2 attack
# per CONTENT.md. This is the proof point that adding a single-target
# ability is just a .tres — no code change required for the data path.
func _test_fighter_power_strike_canonical_stats() -> Array[String]:
	var def: AbilityDef = load(FIGHTER_POWER_STRIKE_PATH) as AbilityDef
	var failures: Array[String] = []
	if def == null:
		failures.append("power_strike: fighter_power_strike.tres failed to load")
		return failures
	if def.id != "fighter_power_strike":
		failures.append("power_strike: id should be 'fighter_power_strike', got '%s'" % def.id)
	if def.ap_cost != 2:
		failures.append("power_strike: ap_cost should be 2, got %d" % def.ap_cost)
	if def.target_count != 1:
		failures.append("power_strike: target_count should be 1, got %d" % def.target_count)
	if def.damage_dice_count != 1:
		failures.append("power_strike: damage_dice_count should be 1, got %d" % def.damage_dice_count)
	if def.damage_dice_sides != 12:
		failures.append("power_strike: damage_dice_sides should be 12, got %d" % def.damage_dice_sides)
	if def.attack_modifier != 2:
		failures.append("power_strike: attack_modifier should be 2 (the +2 to-hit is the point), got %d" % def.attack_modifier)
	return failures


# fighter_slash.tres pre-dates target_count and doesn't set it explicitly.
# The default of 1 must apply on load — otherwise existing single-target
# abilities silently break the moment target_count is read.
func _test_target_count_defaults_to_one() -> Array[String]:
	var def: AbilityDef = load(FIGHTER_SLASH_PATH) as AbilityDef
	if def == null:
		return ["target_count_default: fighter_slash.tres failed to load"]
	if def.target_count != 1:
		return ["target_count_default: fighter_slash should default to target_count=1 (the .tres pre-dates the field), got %d" % def.target_count]
	return []


# Heal fields default to 0 (no heal). Damage abilities (slash, cleave,
# power_strike) pre-date the heal fields; the dispatch in
# UseAbilityCommand checks heal_dice_count > 0 to take the heal path,
# so this default keeps existing damage abilities on the damage path.
func _test_heal_fields_default_to_zero() -> Array[String]:
	var def: AbilityDef = AbilityDef.new()
	var failures: Array[String] = []
	if def.heal_dice_count != 0:
		failures.append("heal_default: heal_dice_count should default to 0, got %d" % def.heal_dice_count)
	if def.heal_dice_sides != 0:
		failures.append("heal_default: heal_dice_sides should default to 0, got %d" % def.heal_dice_sides)
	if def.heal_modifier != 0:
		failures.append("heal_default: heal_modifier should default to 0, got %d" % def.heal_modifier)

	# Sanity: existing damage .tres files (which don't set heal fields)
	# still have heal_dice_count == 0, so the dispatch routes them to the
	# damage path correctly.
	var slash: AbilityDef = load(FIGHTER_SLASH_PATH) as AbilityDef
	if slash.heal_dice_count != 0:
		failures.append("heal_default: fighter_slash.tres should have heal_dice_count=0, got %d" % slash.heal_dice_count)
	return failures


# damage_type defaults to "physical" for new in-memory AbilityDefs and
# for existing damage .tres files (which don't set damage_type explicitly).
# This is the back-compat property — existing damage abilities all stay
# physical without editing every .tres.
func _test_damage_type_defaults_to_physical() -> Array[String]:
	var failures: Array[String] = []
	var fresh: AbilityDef = AbilityDef.new()
	if fresh.damage_type != "physical":
		failures.append("damage_type: fresh AbilityDef should default to 'physical', got '%s'" % fresh.damage_type)

	# Existing damage .tres files (slash, cleave, power_strike) pre-date
	# damage_type and must inherit the default.
	for path in [FIGHTER_SLASH_PATH, FIGHTER_CLEAVE_PATH, FIGHTER_POWER_STRIKE_PATH]:
		var def: AbilityDef = load(path) as AbilityDef
		if def == null:
			failures.append("damage_type: failed to load %s" % path)
			continue
		if def.damage_type != "physical":
			failures.append("damage_type: %s should default to 'physical', got '%s'" % [path, def.damage_type])
	return failures


# fighter_second_wind: 1 AP, self-target, 1d10 healing per the D&D 5e
# Fighter feature. Damage fields are 0 (the heal-vs-damage dispatch
# in UseAbilityCommand routes by heal_dice_count > 0).
func _test_fighter_second_wind_canonical_stats() -> Array[String]:
	var def: AbilityDef = load(FIGHTER_SECOND_WIND_PATH) as AbilityDef
	var failures: Array[String] = []
	if def == null:
		failures.append("second_wind: fighter_second_wind.tres failed to load")
		return failures
	if def.id != "fighter_second_wind":
		failures.append("second_wind: id should be 'fighter_second_wind', got '%s'" % def.id)
	if def.ap_cost != 1:
		failures.append("second_wind: ap_cost should be 1, got %d" % def.ap_cost)
	if def.target_count != 1:
		failures.append("second_wind: target_count should be 1 (self-target uses 1 target slot), got %d" % def.target_count)
	if def.heal_dice_count != 1:
		failures.append("second_wind: heal_dice_count should be 1, got %d" % def.heal_dice_count)
	if def.heal_dice_sides != 10:
		failures.append("second_wind: heal_dice_sides should be 10 (1d10 per D&D 5e), got %d" % def.heal_dice_sides)
	if def.damage_dice_count != 0:
		failures.append("second_wind: damage_dice_count should be 0 (it's a heal), got %d" % def.damage_dice_count)
	return failures


# champion_great_weapon_master per CONTENT.md "Champion subclass":
# "Heavy attack: 2d10, but -2 attack roll. 2 AP."
# First Champion subclass ability and the first ability with a NEGATIVE
# attack_modifier — proves the existing damage-path arithmetic handles
# negative modifiers correctly without special-casing.
func _test_champion_great_weapon_master_canonical_stats() -> Array[String]:
	var def: AbilityDef = load(CHAMPION_GREAT_WEAPON_MASTER_PATH) as AbilityDef
	var failures: Array[String] = []
	if def == null:
		failures.append("gwm: champion_great_weapon_master.tres failed to load")
		return failures
	if def.id != "champion_great_weapon_master":
		failures.append("gwm: id should be 'champion_great_weapon_master', got '%s'" % def.id)
	if def.ap_cost != 2:
		failures.append("gwm: ap_cost should be 2, got %d" % def.ap_cost)
	if def.target_count != 1:
		failures.append("gwm: target_count should be 1, got %d" % def.target_count)
	if def.attack_modifier != -2:
		failures.append("gwm: attack_modifier should be -2 (the trade-off is the point), got %d" % def.attack_modifier)
	if def.damage_dice_count != 2:
		failures.append("gwm: damage_dice_count should be 2, got %d" % def.damage_dice_count)
	if def.damage_dice_sides != 10:
		failures.append("gwm: damage_dice_sides should be 10 (2d10), got %d" % def.damage_dice_sides)
	if def.damage_type != "physical":
		failures.append("gwm: damage_type should be 'physical', got '%s'" % def.damage_type)
	# This ability is pure damage — no heal payload.
	if def.heal_dice_count != 0:
		failures.append("gwm: heal_dice_count should be 0 (pure damage ability), got %d" % def.heal_dice_count)
	return failures


# Execute fields default to 0.0 for fresh AbilityDefs and existing
# damage abilities — the dispatch in UseAbilityCommand requires BOTH
# threshold > 0 and chance > 0 to enter the execute branch, so these
# defaults keep all existing abilities on the normal damage path.
func _test_execute_fields_default_to_zero() -> Array[String]:
	var failures: Array[String] = []
	var fresh: AbilityDef = AbilityDef.new()
	if fresh.execute_threshold_pct != 0.0:
		failures.append("execute_default: fresh threshold should be 0.0, got %s" % str(fresh.execute_threshold_pct))
	if fresh.execute_chance != 0.0:
		failures.append("execute_default: fresh chance should be 0.0, got %s" % str(fresh.execute_chance))

	# Existing damage abilities (not designed as executes) must inherit defaults.
	for path in [FIGHTER_SLASH_PATH, FIGHTER_CLEAVE_PATH, FIGHTER_POWER_STRIKE_PATH, CHAMPION_GREAT_WEAPON_MASTER_PATH]:
		var def: AbilityDef = load(path) as AbilityDef
		if def.execute_threshold_pct != 0.0 or def.execute_chance != 0.0:
			failures.append("execute_default: %s should have execute fields=0.0, got threshold=%s chance=%s" % [path, str(def.execute_threshold_pct), str(def.execute_chance)])
	return failures


# champion_critical_finisher per CONTENT.md "Champion subclass":
# "Execute: 50%+ chance to instakill any enemy below 25% HP. 3 AP."
# This is the first ability with both execute fields populated.
# Fallback damage is 1d8 — modest payload for when the execute fails.
func _test_champion_critical_finisher_canonical_stats() -> Array[String]:
	var def: AbilityDef = load(CHAMPION_CRITICAL_FINISHER_PATH) as AbilityDef
	var failures: Array[String] = []
	if def == null:
		failures.append("finisher: champion_critical_finisher.tres failed to load")
		return failures
	if def.id != "champion_critical_finisher":
		failures.append("finisher: id should be 'champion_critical_finisher', got '%s'" % def.id)
	if def.ap_cost != 3:
		failures.append("finisher: ap_cost should be 3, got %d" % def.ap_cost)
	if def.execute_threshold_pct != 0.25:
		failures.append("finisher: execute_threshold_pct should be 0.25 (below 25%% HP per CONTENT.md), got %s" % str(def.execute_threshold_pct))
	if def.execute_chance != 0.5:
		failures.append("finisher: execute_chance should be 0.5 (50%% per CONTENT.md), got %s" % str(def.execute_chance))
	# Fallback damage payload — 1d8 if the execute doesn't land.
	if def.damage_dice_count != 1:
		failures.append("finisher: damage_dice_count should be 1, got %d" % def.damage_dice_count)
	if def.damage_dice_sides != 8:
		failures.append("finisher: damage_dice_sides should be 8 (1d8 fallback), got %d" % def.damage_dice_sides)
	return failures


# Save fields default to "no save" — empty save_type means
# UseAbilityCommand skips the save check entirely. Existing damage and
# heal abilities inherit this default; their effects (when declared via
# applies_effects in some future authoring pass) would apply
# unconditionally on hit.
func _test_save_fields_default_to_no_save() -> Array[String]:
	var failures: Array[String] = []
	var fresh: AbilityDef = AbilityDef.new()
	if fresh.save_type != "":
		failures.append("save_default: fresh save_type should be empty, got '%s'" % fresh.save_type)
	if fresh.save_dc != 0:
		failures.append("save_default: fresh save_dc should be 0, got %d" % fresh.save_dc)
	if fresh.save_negates_effect != true:
		failures.append("save_default: fresh save_negates_effect should default to true")

	# Existing damage abilities (no save) keep working unchanged.
	for path in [FIGHTER_SLASH_PATH, FIGHTER_CLEAVE_PATH, FIGHTER_POWER_STRIKE_PATH, CHAMPION_GREAT_WEAPON_MASTER_PATH]:
		var def: AbilityDef = load(path) as AbilityDef
		if def.save_type != "":
			failures.append("save_default: %s should have empty save_type, got '%s'" % [path, def.save_type])
	return failures


# fighter_shield_bash per CONTENT.md "Base abilities":
# "1 AP | 1d4 damage + STUN on save fail (DC 14 CON)."
# First ability with both applies_effects populated AND a save throw.
func _test_fighter_shield_bash_canonical_stats() -> Array[String]:
	var def: AbilityDef = load(FIGHTER_SHIELD_BASH_PATH) as AbilityDef
	var failures: Array[String] = []
	if def == null:
		failures.append("shield_bash: fighter_shield_bash.tres failed to load")
		return failures
	if def.id != "fighter_shield_bash":
		failures.append("shield_bash: id should be 'fighter_shield_bash', got '%s'" % def.id)
	if def.ap_cost != 1:
		failures.append("shield_bash: ap_cost should be 1, got %d" % def.ap_cost)
	if def.damage_dice_count != 1 or def.damage_dice_sides != 4:
		failures.append("shield_bash: damage should be 1d4, got %dd%d" % [def.damage_dice_count, def.damage_dice_sides])
	# Save fields
	if def.save_type != "CON":
		failures.append("shield_bash: save_type should be 'CON' per CONTENT.md, got '%s'" % def.save_type)
	if def.save_dc != 14:
		failures.append("shield_bash: save_dc should be 14 per CONTENT.md, got %d" % def.save_dc)
	if def.save_negates_effect != true:
		failures.append("shield_bash: save_negates_effect should be true (success = no stun)")
	# applies_effects should have the stun
	if def.applies_effects.size() != 1:
		failures.append("shield_bash: should have 1 declared effect (stun), got %d" % def.applies_effects.size())
	elif def.applies_effects[0].effect_id != "stun":
		failures.append("shield_bash: declared effect should be stun, got '%s'" % def.applies_effects[0].effect_id)
	elif def.applies_effects[0].duration_remaining != 1:
		failures.append("shield_bash: stun duration should be 1, got %d" % def.applies_effects[0].duration_remaining)
	return failures
