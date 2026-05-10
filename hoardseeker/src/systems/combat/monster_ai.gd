## MonsterAI
##
## Decides what command a monster should issue next. Stateless static helper —
## not a Command itself, not a Resource. Caller invokes pick_next_action()
## repeatedly until it returns null, then issues EndTurnCommand for the monster.
##
## Typical caller pattern (test driver / future AI runner):
##
##     while true:
##         var cmd = MonsterAI.pick_next_action(state, monster_id)
##         if cmd == null:
##             break
##         processor.process(cmd, state)
##     processor.process(EndTurnCommand.new(monster_id), state)
##
## Why a helper, not a Command: a single monster's turn produces a *sequence*
## of commands (attack, attack, end-turn), each its own state mutation. Bundling
## "the whole turn" inside one command would either smuggle multiple mutations
## into one apply() (violates the chunk-3 hard rule) or require sub-command
## composition that's heavier than this scope needs.
##
## Why "next action" rather than "all actions for this turn": keeps the AI
## reactive to mid-turn state changes. If the monster's first attack triggers
## a counter that hurts them, the next pick can re-evaluate. Right now the AI
## doesn't use that — but the shape preserves the option.
##
## Current AI: skeleton-style basic attack. Pick the first living player target,
## attack with a raw AttackCommand using AttackCommand defaults (1d8, 0 mod, 1 AP).
## Returns null when:
##   - monster doesn't exist or is at 0 HP
##   - monster has 0 AP (turn over)
##   - no living player targets (battle effectively won)
##
## When monster ability lookup is wired (chunk-K-or-later), this expands to:
##   1. For each ability the monster knows, score its expected value.
##   2. Pick highest-scoring ability with sufficient AP.
##   3. Otherwise basic attack.
## Currently monsters carry empty ability_ids in their .tres — they only know
## the basic attack via this AI's hardcoded fallback.
##
## Knows about: GameState (read-only), AttackCommand (constructs it).
## Used by: test drivers; eventually a future AIRunner system that fires
##          when active_actor_id transitions to a monster.

class_name MonsterAI extends RefCounted


## Returns the next Command the monster wants to issue, or null if it
## wants to end its turn (or can't act).
static func pick_next_action(state: Resource, monster_id: String) -> Command:
	var monster: MonsterState = state.find_monster(monster_id)
	if monster == null:
		return null
	if monster.hp <= 0:
		return null
	if monster.action_points <= 0:
		return null

	# Find the first living player to target.
	var target_id: String = ""
	for p in state.players:
		if p.hp > 0:
			target_id = p.actor_id
			break

	if target_id == "":
		# No living targets — end turn.
		return null

	# Basic attack with default stats. Future: pick from monster's ability_ids
	# and use UseAbilityCommand.
	return AttackCommand.new(monster_id, target_id)
