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


func run_tests() -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_test_default_construction())
	failures.append_array(_test_fighter_slash_tres_loads())
	failures.append_array(_test_fighter_slash_canonical_stats())
	failures.append_array(_test_load_via_resource_loader_exists())
	failures.append_array(_test_fighter_cleave_canonical_stats())
	failures.append_array(_test_fighter_power_strike_canonical_stats())
	failures.append_array(_test_target_count_defaults_to_one())
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
