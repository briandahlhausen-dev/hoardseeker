## test_runner.gd
##
## Minimal headless test runner for Hoardseeker.
##
## Run with: godot --headless --script tests/test_runner.gd
## (from inside the hoardseeker/ directory)
##
## Each test file under tests/ should define a `run_tests() -> Array[String]`
## function that returns an array of failure messages. An empty array means
## all assertions in that file passed.
##
## Exit code: 0 if all tests pass, 1 if any fail.

extends SceneTree


func _init() -> void:
	var total_failures: Array[String] = []
	var test_count: int = 0

	print("================================================================")
	print(" Hoardseeker test runner")
	print("================================================================")

	# Register tests here. Adding a new test file = one new line below.
	# (We can auto-discover via DirAccess later if the count grows.)
	test_count += 1
	var rng_script: Script = load("res://tests/test_rng_determinism.gd")
	var rng_test: Object = rng_script.new()
	total_failures.append_array(_run("RNG determinism", rng_test))

	test_count += 1
	var gs_script: Script = load("res://tests/test_game_state_serialization.gd")
	var gs_test: Object = gs_script.new()
	total_failures.append_array(_run("GameState serialization", gs_test))

	test_count += 1
	var attack_script: Script = load("res://tests/test_attack_command.gd")
	var attack_test: Object = attack_script.new()
	total_failures.append_array(_run("AttackCommand", attack_test))

	test_count += 1
	var processor_script: Script = load("res://tests/test_command_processor.gd")
	var processor_test: Object = processor_script.new()
	total_failures.append_array(_run("CommandProcessor", processor_test))

	test_count += 1
	var end_turn_script: Script = load("res://tests/test_end_turn_command.gd")
	var end_turn_test: Object = end_turn_script.new()
	total_failures.append_array(_run("EndTurnCommand", end_turn_test))

	test_count += 1
	var monster_script: Script = load("res://tests/test_monster_state.gd")
	var monster_test: Object = monster_script.new()
	total_failures.append_array(_run("MonsterState", monster_test))

	# --- Summary ---
	print("================================================================")
	if total_failures.is_empty():
		print(" ALL TESTS PASSED (%d test file(s))" % test_count)
		quit(0)
	else:
		print(" FAILURES (%d):" % total_failures.size())
		for f in total_failures:
			print("   - %s" % f)
		quit(1)


func _run(label: String, test_obj: Object) -> Array[String]:
	print("[ run ] %s" % label)
	var failures: Array[String] = test_obj.run_tests()
	if failures.is_empty():
		print("[ ok  ] %s" % label)
	else:
		print("[FAIL ] %s (%d failure(s))" % [label, failures.size()])
	return failures
