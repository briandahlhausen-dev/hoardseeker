## test_status_effect.gd
##
## Verifies the status-effect architecture introduced in chunk 8:
##   - StatusEffect is a clean pure-data Resource
##   - ApplyStatusEffectCommand validates + appends to target
##   - EndTurnCommand ticks effects on the new active actor
##   - Stun behavior (the one example effect): zeros AP at turn start
##   - Duration decrements + expired effects are removed cleanly
##   - Permanent effects (duration_remaining == -1) survive ticks
##   - Replay / determinism-friendly: ticking is deterministic per turn
##
## Stun is the example effect chunk 8 ships behavior for. Other effects
## (poison, slow, regenerate, etc.) are stubs in the dispatch — adding
## them is a follow-up chunk per the chunk-8 DECISIONS entry.

extends RefCounted

const GameState = preload("res://src/core/game_state.gd")
const PlayerState = preload("res://src/core/player_state.gd")
const MonsterState = preload("res://src/core/monster_state.gd")
const EncounterState = preload("res://src/core/encounter_state.gd")
const EventLog = preload("res://src/core/event_log.gd")
const RNGService = preload("res://src/core/rng_service.gd")
const GameEvent = preload("res://src/core/game_event.gd")
const StatusEffect = preload("res://src/core/status_effect.gd")
const ApplyStatusEffectCommand = preload("res://src/systems/combat/apply_status_effect_command.gd")
const EndTurnCommand = preload("res://src/systems/combat/end_turn_command.gd")
const CommandProcessor = preload("res://src/core/command_processor.gd")
const MonsterDef = preload("res://src/content/monsters/monster_def.gd")

const SKELETON_WARRIOR_PATH := "res://src/content/monsters/skeleton_warrior.tres"


func run_tests() -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_test_default_construction())
	failures.append_array(_test_apply_validate_normal_case())
	failures.append_array(_test_apply_validate_fails_on_null_effect())
	failures.append_array(_test_apply_validate_fails_on_empty_effect_id())
	failures.append_array(_test_apply_validate_fails_on_unknown_target())
	failures.append_array(_test_apply_validate_fails_on_dead_target())
	failures.append_array(_test_apply_appends_effect_and_emits_event())
	failures.append_array(_test_stun_zeros_ap_on_turn_start())
	failures.append_array(_test_tick_decrements_duration())
	failures.append_array(_test_expired_effect_is_removed())
	failures.append_array(_test_permanent_effect_survives_tick())
	failures.append_array(_test_unknown_effect_id_ticks_without_crashing())
	failures.append_array(_test_multiple_effects_all_tick())
	# Phase A — additional effect kinds
	failures.append_array(_test_poison_damages_target_on_tick())
	failures.append_array(_test_poison_can_defeat_target())
	failures.append_array(_test_poison_with_zero_damage_is_noop())
	failures.append_array(_test_slow_reduces_ap_after_refresh())
	failures.append_array(_test_slow_floors_ap_at_zero())
	failures.append_array(_test_regenerate_heals_capped_at_max_hp())
	failures.append_array(_test_regenerate_does_not_revive_dead_actor())
	# Phase I — bleed (DOT physical damage, shares dispatch with poison)
	failures.append_array(_test_bleed_default_type_is_physical())
	failures.append_array(_test_bleed_damage_reduced_by_physical_resistance())
	failures.append_array(_test_poison_damage_reduced_by_poison_resistance())
	return failures


# Build a 2-actor turn-order state: fighter then skeleton, fighter active.
func _make_state(seed_val: int = 42) -> GameState:
	var gs: GameState = GameState.new()
	gs.seed = seed_val
	gs.rng = RNGService.new(seed_val)
	gs.event_log = EventLog.new()
	gs.event_log.seed = seed_val
	gs.phase = "IN_COMBAT"

	var fighter: PlayerState = PlayerState.new()
	fighter.actor_id = "fighter_1"
	fighter.hp = 20
	fighter.max_hp = 20
	fighter.ac = 16
	fighter.action_points = 0  # outgoing actor — AP doesn't matter post-EndTurn
	fighter.max_action_points = 3
	gs.players.append(fighter)

	gs.current_encounter = EncounterState.new()
	var skel: MonsterState = (load(SKELETON_WARRIOR_PATH) as MonsterDef).spawn_monster_state("skel_1")
	gs.current_encounter.monsters.append(skel)

	gs.turn_order = ["fighter_1", "skel_1"]
	gs.active_actor_id = "fighter_1"
	return gs


# --- StatusEffect default-construction ---

func _test_default_construction() -> Array[String]:
	var e: StatusEffect = StatusEffect.new()
	var failures: Array[String] = []
	if e.effect_id != "":
		failures.append("default: effect_id should be empty, got '%s'" % e.effect_id)
	if e.duration_remaining != 0:
		failures.append("default: duration_remaining should be 0, got %d" % e.duration_remaining)
	if e.params.size() != 0:
		failures.append("default: params should be empty, got %d entries" % e.params.size())
	if e.source_actor_id != "":
		failures.append("default: source_actor_id should be empty, got '%s'" % e.source_actor_id)
	return failures


# --- ApplyStatusEffectCommand validation ---

func _test_apply_validate_normal_case() -> Array[String]:
	var state: GameState = _make_state()
	var stun: StatusEffect = StatusEffect.new()
	stun.effect_id = "stun"
	stun.duration_remaining = 1
	var cmd: ApplyStatusEffectCommand = ApplyStatusEffectCommand.new("fighter_1", "skel_1", stun)
	if not cmd.validate(state):
		return ["validate_normal: should pass with valid actor + target + effect"]
	return []


func _test_apply_validate_fails_on_null_effect() -> Array[String]:
	var state: GameState = _make_state()
	var cmd: ApplyStatusEffectCommand = ApplyStatusEffectCommand.new("fighter_1", "skel_1", null)
	if cmd.validate(state):
		return ["validate_null_effect: should fail when effect is null"]
	return []


func _test_apply_validate_fails_on_empty_effect_id() -> Array[String]:
	var state: GameState = _make_state()
	var e: StatusEffect = StatusEffect.new()  # effect_id defaults to ""
	e.duration_remaining = 1
	var cmd: ApplyStatusEffectCommand = ApplyStatusEffectCommand.new("fighter_1", "skel_1", e)
	if cmd.validate(state):
		return ["validate_empty_id: should fail when effect_id is empty"]
	return []


func _test_apply_validate_fails_on_unknown_target() -> Array[String]:
	var state: GameState = _make_state()
	var stun: StatusEffect = StatusEffect.new()
	stun.effect_id = "stun"
	stun.duration_remaining = 1
	var cmd: ApplyStatusEffectCommand = ApplyStatusEffectCommand.new("fighter_1", "no_such_actor", stun)
	if cmd.validate(state):
		return ["validate_unknown_target: should fail when target_id doesn't resolve"]
	return []


func _test_apply_validate_fails_on_dead_target() -> Array[String]:
	var state: GameState = _make_state()
	state.find_monster("skel_1").hp = 0
	var stun: StatusEffect = StatusEffect.new()
	stun.effect_id = "stun"
	stun.duration_remaining = 1
	var cmd: ApplyStatusEffectCommand = ApplyStatusEffectCommand.new("fighter_1", "skel_1", stun)
	if cmd.validate(state):
		return ["validate_dead_target: should fail when target is at 0 HP"]
	return []


# --- ApplyStatusEffectCommand apply ---

func _test_apply_appends_effect_and_emits_event() -> Array[String]:
	var state: GameState = _make_state()
	var stun: StatusEffect = StatusEffect.new()
	stun.effect_id = "stun"
	stun.duration_remaining = 1
	stun.source_actor_id = "fighter_1"
	var cmd: ApplyStatusEffectCommand = ApplyStatusEffectCommand.new("fighter_1", "skel_1", stun)
	var events: Array[GameEvent] = cmd.apply(state)

	var failures: Array[String] = []
	var skel: MonsterState = state.find_monster("skel_1")
	if skel.status_effects.size() != 1:
		failures.append("apply_append: expected 1 effect on skel after apply, got %d" % skel.status_effects.size())
	elif skel.status_effects[0].effect_id != "stun":
		failures.append("apply_append: appended effect_id wrong, got '%s'" % skel.status_effects[0].effect_id)

	var saw_status_applied: bool = false
	for evt in events:
		if evt.event_type == "STATUS_APPLIED" and evt.data.get("effect_id") == "stun":
			saw_status_applied = true
			break
	if not saw_status_applied:
		failures.append("apply_append: no STATUS_APPLIED event for stun")
	return failures


# --- Stun behavior: zeros AP on turn start ---

# When EndTurnCommand passes control to a stunned actor, the tick should
# zero their action_points (regardless of the AP refresh that just ran).
func _test_stun_zeros_ap_on_turn_start() -> Array[String]:
	# Two players so we can EndTurn from one to the other (skeleton ticking
	# is in a separate test). Stun the second player; end first player's
	# turn; verify second player has 0 AP after their turn starts.
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.action_points = 0
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	# Stun fighter_2 for 1 turn
	var stun: StatusEffect = StatusEffect.new()
	stun.effect_id = "stun"
	stun.duration_remaining = 1
	state.find_player("fighter_2").status_effects.append(stun)

	# Fighter_1 ends turn -> fighter_2 becomes active
	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var failures: Array[String] = []
	var p2_after: PlayerState = state.find_player("fighter_2")
	if p2_after.action_points != 0:
		failures.append("stun_zeros_ap: expected fighter_2 AP=0 after stun tick, got %d" % p2_after.action_points)
	if state.active_actor_id != "fighter_2":
		failures.append("stun_zeros_ap: active actor should be fighter_2, got '%s'" % state.active_actor_id)
	return failures


# --- Tick: duration decrements ---

func _test_tick_decrements_duration() -> Array[String]:
	# Duration-2 stun applied to fighter_2. End fighter_1's turn. Stun
	# duration on fighter_2 should now be 1 (decremented from 2).
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var stun: StatusEffect = StatusEffect.new()
	stun.effect_id = "stun"
	stun.duration_remaining = 2
	state.find_player("fighter_2").status_effects.append(stun)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var p2_after: PlayerState = state.find_player("fighter_2")
	if p2_after.status_effects.size() != 1:
		return ["tick_decrement: stun should still be on fighter_2 (1 turn left), got %d effects" % p2_after.status_effects.size()]
	if p2_after.status_effects[0].duration_remaining != 1:
		return ["tick_decrement: duration should be 1 after one tick (started at 2), got %d" % p2_after.status_effects[0].duration_remaining]
	return []


# --- Expiry: duration hitting 0 removes the effect ---

func _test_expired_effect_is_removed() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var stun: StatusEffect = StatusEffect.new()
	stun.effect_id = "stun"
	stun.duration_remaining = 1  # one turn left -> expires after this tick
	state.find_player("fighter_2").status_effects.append(stun)

	var processor: CommandProcessor = CommandProcessor.new()
	var events_emitted: Array = []
	# Use process_all to capture event log via state.event_log
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var failures: Array[String] = []
	var p2_after: PlayerState = state.find_player("fighter_2")
	if p2_after.status_effects.size() != 0:
		failures.append("expired_removed: expected 0 effects after expiry, got %d" % p2_after.status_effects.size())

	var saw_expired: bool = false
	for evt in state.event_log.events:
		if evt.event_type == "STATUS_EXPIRED" and evt.data.get("effect_id") == "stun":
			saw_expired = true
			break
	if not saw_expired:
		failures.append("expired_removed: no STATUS_EXPIRED event emitted")
	return failures


# --- Permanent effects (duration_remaining == -1) survive ticks ---

func _test_permanent_effect_survives_tick() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var curse: StatusEffect = StatusEffect.new()
	curse.effect_id = "curse"  # unknown effect_id — falls through to no-op tick
	curse.duration_remaining = -1  # permanent
	state.find_player("fighter_2").status_effects.append(curse)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var p2_after: PlayerState = state.find_player("fighter_2")
	if p2_after.status_effects.size() != 1:
		return ["permanent: expected curse to survive (duration -1), got %d effects" % p2_after.status_effects.size()]
	if p2_after.status_effects[0].duration_remaining != -1:
		return ["permanent: duration_remaining should stay at -1 across ticks, got %d" % p2_after.status_effects[0].duration_remaining]
	return []


# --- Unknown effect_id falls through cleanly ---

# Effects whose effect_id isn't matched by the dispatch should still
# tick (decrement, eventually expire) without crashing.
func _test_unknown_effect_id_ticks_without_crashing() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var unknown: StatusEffect = StatusEffect.new()
	unknown.effect_id = "fictional_effect"
	unknown.duration_remaining = 1
	state.find_player("fighter_2").status_effects.append(unknown)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var p2_after: PlayerState = state.find_player("fighter_2")
	# The unknown effect ticks (no behavior), then expires (duration hit 0)
	if p2_after.status_effects.size() != 0:
		return ["unknown_id: unknown effect should still expire after duration hits 0, got %d effects" % p2_after.status_effects.size()]
	# Fighter_2 should NOT have 0 AP — the unknown effect doesn't stun
	if p2_after.action_points != p2_after.max_action_points:
		return ["unknown_id: unknown effect shouldn't zero AP (only stun does), got AP=%d" % p2_after.action_points]
	return []


# --- Multiple effects all tick on the same turn ---

func _test_multiple_effects_all_tick() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	# Two effects of different durations
	var stun: StatusEffect = StatusEffect.new()
	stun.effect_id = "stun"
	stun.duration_remaining = 1  # expires this tick

	var curse: StatusEffect = StatusEffect.new()
	curse.effect_id = "curse"  # unknown — no-op behavior
	curse.duration_remaining = 3  # 2 turns left after this tick

	var p2_state: PlayerState = state.find_player("fighter_2")
	p2_state.status_effects.append(stun)
	p2_state.status_effects.append(curse)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var p2_after: PlayerState = state.find_player("fighter_2")
	# stun expired, curse survives
	if p2_after.status_effects.size() != 1:
		return ["multi_tick: expected 1 surviving effect (stun expired, curse 2 left), got %d" % p2_after.status_effects.size()]
	if p2_after.status_effects[0].effect_id != "curse":
		return ["multi_tick: surviving effect should be curse, got '%s'" % p2_after.status_effects[0].effect_id]
	if p2_after.status_effects[0].duration_remaining != 2:
		return ["multi_tick: curse duration should be 2 (was 3), got %d" % p2_after.status_effects[0].duration_remaining]
	# stun fired before expiring — AP should be 0
	if p2_after.action_points != 0:
		return ["multi_tick: stun should have zeroed AP before expiring, got %d" % p2_after.action_points]
	return []


# --- Phase A: poison ---

# Poison damages the target each tick; emits DAMAGE_DEALT with the
# status-effect source so renderers can attribute the popup to poison.
func _test_poison_damages_target_on_tick() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var poison: StatusEffect = StatusEffect.new()
	poison.effect_id = "poison"
	poison.duration_remaining = 3
	poison.params = {"damage_per_turn": 3}
	state.find_player("fighter_2").status_effects.append(poison)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var failures: Array[String] = []
	var p2_after: PlayerState = state.find_player("fighter_2")
	if p2_after.hp != 17:
		failures.append("poison_damage: expected HP 17 (20 - 3), got %d" % p2_after.hp)

	# Verify DAMAGE_DEALT was emitted with poison source
	var saw_poison_damage: bool = false
	for evt in state.event_log.events:
		if evt.event_type == "DAMAGE_DEALT" and evt.data.get("source") == "status_effect:poison":
			if evt.data.get("amount") == 3 and evt.data.get("target") == "fighter_2":
				saw_poison_damage = true
				break
	if not saw_poison_damage:
		failures.append("poison_damage: no DAMAGE_DEALT event with poison source + correct amount/target")
	return failures


# Poison can take a target to 0 HP and emit ACTOR_DEFEATED — the
# damage-over-time path needs the same defeat-detection as direct attacks.
func _test_poison_can_defeat_target() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 2  # so 3 damage takes them to 0 (clamped)
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var poison: StatusEffect = StatusEffect.new()
	poison.effect_id = "poison"
	poison.duration_remaining = 1
	poison.params = {"damage_per_turn": 3}
	state.find_player("fighter_2").status_effects.append(poison)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var failures: Array[String] = []
	var p2_after: PlayerState = state.find_player("fighter_2")
	if p2_after.hp != 0:
		failures.append("poison_defeat: expected HP 0, got %d" % p2_after.hp)

	var saw_defeated: bool = false
	for evt in state.event_log.events:
		if evt.event_type == "ACTOR_DEFEATED" and evt.data.get("target") == "fighter_2":
			saw_defeated = true
			break
	if not saw_defeated:
		failures.append("poison_defeat: no ACTOR_DEFEATED event for fighter_2")
	return failures


# Poison with damage_per_turn = 0 (or missing param) is a no-op for HP.
# Tests the params.get() default path.
func _test_poison_with_zero_damage_is_noop() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var poison: StatusEffect = StatusEffect.new()
	poison.effect_id = "poison"
	poison.duration_remaining = 1
	# No params set — damage_per_turn defaults to 0
	state.find_player("fighter_2").status_effects.append(poison)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var p2_after: PlayerState = state.find_player("fighter_2")
	if p2_after.hp != 20:
		return ["poison_zero: HP should be unchanged (poison with 0 damage), got %d" % p2_after.hp]
	# No DAMAGE_DEALT event should have fired for poison
	for evt in state.event_log.events:
		if evt.event_type == "DAMAGE_DEALT" and evt.data.get("source") == "status_effect:poison":
			return ["poison_zero: no DAMAGE_DEALT should fire for 0-damage poison, but one did"]
	return []


# --- Phase A: slow ---

# Slow reduces AP each turn AFTER the refresh. With max_action_points=3
# and ap_reduction=1, the slowed actor should land on AP=2.
func _test_slow_reduces_ap_after_refresh() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.action_points = 0  # outgoing — refresh happens in EndTurn
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var slow: StatusEffect = StatusEffect.new()
	slow.effect_id = "slow"
	slow.duration_remaining = 2
	slow.params = {"ap_reduction": 1}
	state.find_player("fighter_2").status_effects.append(slow)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var p2_after: PlayerState = state.find_player("fighter_2")
	# Refresh sets AP to max (3); slow reduces by 1 → 2
	if p2_after.action_points != 2:
		return ["slow_reduce: expected AP 2 (3 - 1), got %d" % p2_after.action_points]
	return []


# Slow with reduction larger than max_action_points should floor at 0,
# not go negative.
func _test_slow_floors_ap_at_zero() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var slow: StatusEffect = StatusEffect.new()
	slow.effect_id = "slow"
	slow.duration_remaining = 1
	slow.params = {"ap_reduction": 99}  # absurdly large
	state.find_player("fighter_2").status_effects.append(slow)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var p2_after: PlayerState = state.find_player("fighter_2")
	if p2_after.action_points != 0:
		return ["slow_floor: expected AP 0 (clamped), got %d" % p2_after.action_points]
	return []


# --- Phase A: regenerate ---

# Regenerate heals each turn but is capped at max_hp. A target at 18/20
# with hp_per_turn=5 lands at 20, not 23.
func _test_regenerate_heals_capped_at_max_hp() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 18
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var regen: StatusEffect = StatusEffect.new()
	regen.effect_id = "regenerate"
	regen.duration_remaining = 1
	regen.params = {"hp_per_turn": 5}  # would push to 23 if uncapped
	state.find_player("fighter_2").status_effects.append(regen)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var failures: Array[String] = []
	var p2_after: PlayerState = state.find_player("fighter_2")
	if p2_after.hp != 20:
		failures.append("regenerate_cap: expected HP 20 (capped at max), got %d" % p2_after.hp)

	# HEALED event should reflect the ACTUAL heal, not the requested 5.
	# (18 + 2 = 20; the actual heal was 2)
	var saw_healed: bool = false
	for evt in state.event_log.events:
		if evt.event_type == "HEALED" and evt.data.get("source") == "status_effect:regenerate":
			if evt.data.get("amount") == 2:
				saw_healed = true
				break
	if not saw_healed:
		failures.append("regenerate_cap: HEALED event should have amount=2 (the actual heal after capping)")
	return failures


# Regenerate must NOT bring a defeated actor back. If hp <= 0 at tick
# time, the heal is skipped entirely.
func _test_regenerate_does_not_revive_dead_actor() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 0  # defeated
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var regen: StatusEffect = StatusEffect.new()
	regen.effect_id = "regenerate"
	regen.duration_remaining = 1
	regen.params = {"hp_per_turn": 5}
	state.find_player("fighter_2").status_effects.append(regen)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var p2_after: PlayerState = state.find_player("fighter_2")
	if p2_after.hp != 0:
		return ["regenerate_no_revive: dead actor should stay dead, got HP %d" % p2_after.hp]
	# No HEALED event should have fired
	for evt in state.event_log.events:
		if evt.event_type == "HEALED" and evt.data.get("target") == "fighter_2":
			return ["regenerate_no_revive: HEALED should not fire for a defeated actor"]
	return []


# --- Phase I: bleed (DOT physical damage, shares dispatch with poison) ---

# bleed defaults to "physical" damage type. The DAMAGE_DEALT event
# carries damage_type so renderers can show "physical bleed" vs
# "poison venom" differently.
func _test_bleed_default_type_is_physical() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var bleed: StatusEffect = StatusEffect.new()
	bleed.effect_id = "bleed"
	bleed.duration_remaining = 1
	bleed.params = {"damage_per_turn": 3}  # no damage_type override → defaults to physical
	state.find_player("fighter_2").status_effects.append(bleed)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var saw_bleed_damage: bool = false
	for evt in state.event_log.events:
		if evt.event_type == "DAMAGE_DEALT" and evt.data.get("source") == "status_effect:bleed":
			if evt.data.get("damage_type") == "physical":
				saw_bleed_damage = true
				break
	if not saw_bleed_damage:
		return ["bleed_default: expected DAMAGE_DEALT from bleed with damage_type='physical'"]
	return []


# A target with physical resistance takes reduced bleed damage. Zombie
# has 0.5 physical resistance per Phase F — bleed at 4/turn deals 2.
func _test_bleed_damage_reduced_by_physical_resistance() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	p2.damage_resistances = {"physical": 0.5}  # mid-fight resistance buff or innate
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var bleed: StatusEffect = StatusEffect.new()
	bleed.effect_id = "bleed"
	bleed.duration_remaining = 1
	bleed.params = {"damage_per_turn": 4}
	state.find_player("fighter_2").status_effects.append(bleed)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var p2_after: PlayerState = state.find_player("fighter_2")
	if p2_after.hp != 18:
		return ["bleed_resist: expected HP 18 (20 - 2 = 4 * 0.5), got %d" % p2_after.hp]
	return []


# Poison's default damage_type is "poison" — a target with poison
# resistance reduces poison damage but NOT physical (e.g., Cure Wounds
# wouldn't help; an antitoxin would).
func _test_poison_damage_reduced_by_poison_resistance() -> Array[String]:
	var state: GameState = _make_state()
	var p2: PlayerState = PlayerState.new()
	p2.actor_id = "fighter_2"
	p2.hp = 20
	p2.max_hp = 20
	p2.ac = 16
	p2.max_action_points = 3
	p2.damage_resistances = {"poison": 0.0}  # immune to poison
	state.players.append(p2)
	state.turn_order = ["fighter_1", "fighter_2"]
	state.active_actor_id = "fighter_1"

	var poison: StatusEffect = StatusEffect.new()
	poison.effect_id = "poison"
	poison.duration_remaining = 1
	poison.params = {"damage_per_turn": 5}
	state.find_player("fighter_2").status_effects.append(poison)

	var processor: CommandProcessor = CommandProcessor.new()
	processor.process(EndTurnCommand.new("fighter_1"), state)

	var p2_after: PlayerState = state.find_player("fighter_2")
	if p2_after.hp != 20:
		return ["poison_immune: expected HP 20 (immune), got %d" % p2_after.hp]
	# DAMAGE_DEALT should NOT fire when damage clamps to 0 after resistance
	for evt in state.event_log.events:
		if evt.event_type == "DAMAGE_DEALT" and evt.data.get("source") == "status_effect:poison":
			return ["poison_immune: DAMAGE_DEALT should not fire when poison damage is fully resisted"]
	return []
