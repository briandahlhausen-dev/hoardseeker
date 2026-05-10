## UseAbilityCommand
##
## An actor uses a named ability against one or more targets. The third
## concrete Command — and the first command that pulls its stats from
## data rather than carrying them inline. This is the runtime side of
## CLAUDE.md hard rule #4 ("content is data, not code"): adding a new
## ability is a `.tres` change, not a code change.
##
## Targeting:
##   The command always carries `target_ids: Array[String]`, even for
##   single-target abilities (which use a 1-element array). The
##   `AbilityDef.target_count` field declares how many targets the
##   ability expects; validate() rejects mismatched counts.
##
##   The single-target convenience constructor `UseAbilityCommand.new(
##   actor, ability, target_id)` wraps `target_id` into a 1-element
##   `target_ids` automatically. Multi-target callers use the static
##   factory `multi_target(actor, ability, target_ids)`.
##
## Relationship to AttackCommand:
##   - AttackCommand stays as the raw-attack primitive (stats inline on
##     the command instance). Useful for monster basic attacks and other
##     cases where there's no formal AbilityDef.
##   - UseAbilityCommand is the player-facing entry point: "actor X uses
##     ability Y against targets Z." Looks up the AbilityDef by id, runs
##     the same d20 + damage resolution dance against each target.
##
## Ability lookup is currently a direct `load()` against the convention
## path `res://src/content/abilities/{ability_id}.tres`. Godot caches
## resource loads, so this is fast and deterministic given a stable
## file. A future chunk may introduce an AbilityRegistry on GameState
## that loads all defs at run start; until then this works fine.
##
## Resolution sequence (per target, in target_ids order):
##   1. Load AbilityDef by id (once per command, not per target)
##   2. Roll d20 + def.attack_modifier vs. target.ac
##   3. Natural 20 = crit, natural 1 = fumble, otherwise hit if total >= AC
##   4. On hit: roll damage dice from def, subtract from target.hp
##   5. AP cost is paid ONCE per command (not per target).
##
## Knows about: GameState, AbilityDef, GameEvent, RNGService (via state).
##              Treats attacker / target as untyped Resources (duck-typed
##              same as AttackCommand — see no-CombatantState DECISIONS entry).
## Used by: CommandProcessor, tests, eventually input handlers.

class_name UseAbilityCommand extends Command

## The ability being used. Resolved via load() against the convention path.
@export var ability_id: String = ""

## Ordered list of actor_ids the ability targets. For single-target
## abilities, this is a 1-element array. For cleave-style abilities,
## this is N elements where N == AbilityDef.target_count. Order matters:
## targets are resolved in the order given (relevant for "first hit
## triggers" effects later).
@export var target_ids: Array[String] = []


## Single-target convenience constructor. The third positional arg is
## wrapped into a 1-element `target_ids` array — covers fighter_slash,
## fighter_power_strike, and most player abilities. For multi-target
## (cleave-style), use the static factory `multi_target` below.
func _init(p_actor_id: String = "", p_ability_id: String = "", p_target_id: String = "") -> void:
	actor_id = p_actor_id
	ability_id = p_ability_id
	if p_target_id != "":
		target_ids = [p_target_id]
	command_type = "USE_ABILITY"


## Explicit multi-target factory. Use for cleave-style abilities where
## the caller has more than one target_id to declare.
static func multi_target(p_actor_id: String, p_ability_id: String, p_target_ids: Array[String]) -> UseAbilityCommand:
	var cmd: UseAbilityCommand = UseAbilityCommand.new(p_actor_id, p_ability_id)
	cmd.target_ids = p_target_ids
	return cmd


func validate(state: Resource) -> bool:
	var attacker: Resource = state.find_actor(actor_id)
	if attacker == null:
		return false
	if attacker.hp <= 0:
		return false

	# Actor must actually know this ability — can't invoke what you don't have.
	if not (ability_id in attacker.ability_ids):
		return false

	var def: AbilityDef = _load_ability_def()
	if def == null:
		return false

	# Target count must match the ability's declared count exactly.
	if target_ids.size() != def.target_count:
		return false

	# Every declared target must exist and be alive.
	for tid in target_ids:
		var target: Resource = state.find_actor(tid)
		if target == null:
			return false
		if target.hp <= 0:
			return false

	if attacker.action_points < def.ap_cost:
		return false
	return true


func apply(state: Resource) -> Array[GameEvent]:
	var events: Array[GameEvent] = []
	var attacker: Resource = state.find_actor(actor_id)
	var def: AbilityDef = _load_ability_def()

	# Resolve each target independently. A multi-target ability rolls
	# attack-and-damage per target; one target may hit while another
	# misses, or both may be defeated by the same swing.
	for tid in target_ids:
		var target: Resource = state.find_actor(tid)
		_resolve_against_target(state, def, target, tid, events)

	# AP cost paid ONCE per command, regardless of target_count or hits.
	attacker.action_points -= def.ap_cost

	return events


## Resolve one attack-and-damage exchange against a single target.
## Appends the resulting events to `events`. Mutates target.hp on hit.
func _resolve_against_target(
	state: Resource,
	def: AbilityDef,
	target: Resource,
	target_id: String,
	events: Array[GameEvent],
) -> void:
	# === Attack roll ===
	var attack_natural: int = state.rng.roll(20)
	var attack_total: int = attack_natural + def.attack_modifier

	events.append(GameEvent.new("DICE_ROLLED", {
		"actor": actor_id,
		"type": "attack",
		"ability": ability_id,
		"target": target_id,
		"natural": attack_natural,
		"total": attack_total,
		"target_ac": target.ac,
	}))

	var is_crit: bool = attack_natural == 20
	var is_fumble: bool = attack_natural == 1
	var hit: bool = is_crit or (not is_fumble and attack_total >= target.ac)

	if hit:
		# === Damage roll ===
		var damage_dice: Array[int] = state.rng.roll_dice(def.damage_dice_count, def.damage_dice_sides)
		var damage_total: int = def.damage_modifier
		for d in damage_dice:
			damage_total += d

		# Crits double the damage dice (rolled twice, not multiplied — D&D 5e style)
		if is_crit:
			var extra_dice: Array[int] = state.rng.roll_dice(def.damage_dice_count, def.damage_dice_sides)
			for d in extra_dice:
				damage_total += d

		damage_total = max(0, damage_total)
		target.hp = max(0, target.hp - damage_total)

		events.append(GameEvent.new("DAMAGE_DEALT", {
			"actor": actor_id,
			"target": target_id,
			"ability": ability_id,
			"amount": damage_total,
			"crit": is_crit,
		}))

		if target.hp <= 0:
			events.append(GameEvent.new("ACTOR_DEFEATED", {
				"target": target_id,
			}))
	else:
		events.append(GameEvent.new("ATTACK_MISSED", {
			"actor": actor_id,
			"target": target_id,
			"ability": ability_id,
			"fumble": is_fumble,
		}))


## Resolves an ability_id to its AbilityDef via the convention path.
## Returns null if no .tres exists at the expected location.
func _load_ability_def() -> AbilityDef:
	var path: String = "res://src/content/abilities/" + ability_id + ".tres"
	if not ResourceLoader.exists(path):
		return null
	return load(path) as AbilityDef
