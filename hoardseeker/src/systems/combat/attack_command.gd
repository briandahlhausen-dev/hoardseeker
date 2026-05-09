## AttackCommand
##
## An actor attacks another actor. The first concrete Command subclass —
## the canonical example of how every state-changing action flows through
## the command pipeline.
##
## Both attacker and target are resolved via state.find_actor(), so either
## may be a PlayerState or a MonsterState. The duck-typed access to .hp /
## .ac / .action_points works uniformly across both — see MonsterState's
## doc header for why no shared base class.
##
## Resolution sequence:
##   1. Roll d20 + attack_modifier vs. target.ac
##   2. Natural 20 = crit (always hits, doubles damage dice)
##   3. Natural 1 = fumble (always misses)
##   4. Otherwise: hit if total >= target.ac
##   5. On hit: roll damage dice, subtract from target.hp
##   6. Always: subtract ap_cost from attacker.action_points
##
## Damage stats are stored directly on the command instance — AttackCommand
## is the raw-attack primitive. For ability-driven attacks (where stats live
## in an AbilityDef .tres), use UseAbilityCommand instead. AttackCommand
## remains useful for cases without a formal AbilityDef, e.g. monster basic
## attacks where the stats come from MonsterDef rather than AbilityDef.
##
## Knows about: GameState, GameEvent, RNGService (via state). Treats
##              attacker / target as untyped Resources (duck-typed).
## Used by: CommandProcessor, tests.

class_name AttackCommand extends Command

## The actor being attacked. Looked up via state.find_actor(target_id).
@export var target_id: String = ""

## Bonus added to the d20 attack roll. Negative values are valid (e.g.
## Champion's Great Weapon Master pays -2 for +damage).
@export var attack_modifier: int = 0

## Damage = sum of (damage_dice_count d damage_dice_sides) + damage_modifier.
## Crits add an extra (damage_dice_count d damage_dice_sides) on top.
@export var damage_dice_count: int = 1
@export var damage_dice_sides: int = 8
@export var damage_modifier: int = 0

## Action points consumed by this attack, regardless of hit/miss.
@export var ap_cost: int = 1


func _init(p_actor_id: String = "", p_target_id: String = "") -> void:
	actor_id = p_actor_id
	target_id = p_target_id
	command_type = "ATTACK"


func validate(state: Resource) -> bool:
	var attacker: Resource = state.find_actor(actor_id)
	var target: Resource = state.find_actor(target_id)
	if attacker == null or target == null:
		return false
	if attacker.hp <= 0:
		return false
	if target.hp <= 0:
		return false
	if attacker.action_points < ap_cost:
		return false
	return true


func apply(state: Resource) -> Array[GameEvent]:
	var events: Array[GameEvent] = []
	var attacker: Resource = state.find_actor(actor_id)
	var target: Resource = state.find_actor(target_id)

	# === Attack roll ===
	var attack_natural: int = state.rng.roll(20)
	var attack_total: int = attack_natural + attack_modifier

	events.append(GameEvent.new("DICE_ROLLED", {
		"actor": actor_id,
		"type": "attack",
		"natural": attack_natural,
		"total": attack_total,
		"target_ac": target.ac,
	}))

	var is_crit: bool = attack_natural == 20
	var is_fumble: bool = attack_natural == 1
	var hit: bool = is_crit or (not is_fumble and attack_total >= target.ac)

	if hit:
		# === Damage roll ===
		var damage_dice: Array[int] = state.rng.roll_dice(damage_dice_count, damage_dice_sides)
		var damage_total: int = damage_modifier
		for d in damage_dice:
			damage_total += d

		# Crits double the damage dice (rolled twice, not multiplied — D&D 5e style)
		if is_crit:
			var extra_dice: Array[int] = state.rng.roll_dice(damage_dice_count, damage_dice_sides)
			for d in extra_dice:
				damage_total += d

		# Floor at 0 — modifiers shouldn't turn an attack into healing
		damage_total = max(0, damage_total)
		target.hp = max(0, target.hp - damage_total)

		events.append(GameEvent.new("DAMAGE_DEALT", {
			"actor": actor_id,
			"target": target_id,
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
			"fumble": is_fumble,
		}))

	# === AP cost (always paid, hit or miss) ===
	attacker.action_points -= ap_cost

	return events
