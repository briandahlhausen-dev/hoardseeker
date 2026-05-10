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
	var skel: MonsterState = MonsterState.new()
	skel.actor_id = "skel_1"
	skel.monster_id = "skeleton_warrior"
	skel.hp = 12
	skel.max_hp = 12
	skel.ac = 13
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
