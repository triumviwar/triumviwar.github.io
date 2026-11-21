extends SceneTree
## The match log starts with its header ("Triumviwar vX.Y.Z match log", GameName.is_log_header) even though the
## computers write their first lines (their plans) before MatchLog.begin (playtest-skirmish-brood, 2026-11-21).
##   godot --headless --fixed-fps 30 --script res://tools/test_match_log_header.gd
var main: Node
var t := 0.0
var fails := 0
var done := false


func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _process(delta: float) -> bool:
	t += delta
	if t > 0.2 and main.game == null and not done:
		main.start({"map": "hollowfen", "seed": 4242, "slots": [
			{"who": "you", "faction": "brood", "colour": 0, "side": 0},
			{"who": "hard", "faction": "crown", "colour": 1, "side": 1, "strategy": "optimal"}]})
		return false
	if main.game != null and t > 3.0 and not done:
		done = true
		var lines: PackedStringArray = main.game.mlog.lines
		check(lines.size() > 3 and GameName.is_log_header(lines[0]), "the first line is the header: '%s'" % (lines[0] if lines.size() > 0 else ""))
		var plan_at := -1
		for i in lines.size():
			if lines[i].contains("plan"):
				plan_at = i
				break
		check(plan_at > 0, "the computer's plan line comes after the header (line %d)" % plan_at)
		print("RESULT ", "PASS" if fails == 0 else "FAIL %d" % fails)
		quit(fails)
	return false
