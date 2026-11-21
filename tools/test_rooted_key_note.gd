extends SceneTree
## A, M, S, H or P with only rooted Brood creatures picked says "Rooted: UPROOT it first." (it said "Attack: not now.":
## playtest-skirmish-brood, 2026-11-21); with the Mother up, A is ATTACK again.
##   godot --headless --fixed-fps 30 --script res://tools/test_rooted_key_note.gd
var main: Node
var t := 0.0
var fails := 0
var step := 0


func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _process(delta: float) -> bool:
	t += delta
	if t > 0.2 and main.game == null and step == 0:
		Settings.device = "pc"
		main.start({"map": "hollowfen", "seed": 4242, "slots": [
			{"who": "you", "faction": "brood", "colour": 0, "side": 0},
			{"who": "easy", "faction": "crown", "colour": 1, "side": 1}]})
		step = 1
		return false
	if main.game == null:
		return false
	var g = main.game
	if step == 1 and t > 6.0:
		var q := BroodNew.queen(g, g.human)
		g.set_selection([q])
		g.hud._refresh_card()
		step = 2
	elif step == 2 and t > 6.5:
		g.hud._msg = ""
		for k in [KEY_A, KEY_M, KEY_H]:
			g.hud.hotkey(k)
		check(String(g.hud._msg) == "Rooted: UPROOT it first.", "a move/attack key on the rooted Mother: '%s'" % g.hud._msg)
		print("RESULT ", "PASS" if fails == 0 else "FAIL %d" % fails)
		quit(fails)
	return false
