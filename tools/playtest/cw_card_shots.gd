extends SceneTree
## Every Clockwork card in a language, pictured, with every label that does not fit its button even at the smallest
## size listed (job playtest-skirmish-clockwork). A check tool, not a player: it sets the match up directly.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 \
##       --script res://tools/playtest/cw_card_shots.gd -- out=DIR lang=pt [phone]

const G := preload("res://tools/gear_test_util.gd")
var io
const IN := preload("res://tools/playtest/cw_input.gd")


func _initialize() -> void:
	_run.call_deferred()


func arg(k: String, d: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(k + "="):
			return a.substr(k.length() + 1)
		if a == k:
			return "1"
	return d


func _run() -> void:
	io = IN.new(self)
	io.shots_dir = arg("out", "/tmp/claude-0/pt/cards")
	DirAccess.make_dir_recursive_absolute(io.shots_dir)
	Settings.load_all()
	Settings.device = "mobile" if arg("phone", "") != "" else "pc"
	Settings.set_language(arg("lang", "pt"))
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await io.frames(5)
	main.start({"map": "greenhold", "seed": 7, "sandbox": true, "slots": [
		{"who": "you", "faction": "clockwork", "colour": 0, "side": 0},
		{"who": "easy", "faction": "crown", "colour": 1, "side": 1}]})
	for i in 120:
		await io.frames(1)
		if main.game and main.game.hud and main.game.hud.countdown <= 0.0:
			break
	var g: Game = main.game
	for ai in g.ais:
		ai.process_mode = Node.PROCESS_MODE_DISABLED
	g.players[0]["gold"] = 50000
	g.players[0]["tension"] = 5000.0
	var hall: Building = G.hall(g, 0)
	var things: Array = [hall]
	for k in ["mainspring", Defs.GEAR_PRESS, "regulator", "movement_works", "escapement", "heavy_works", "cuckoo_house", "ratchet_turret"]:
		var b: Building = G.put(g, 0, k, hall.cell, k == "heavy_works")
		if b:
			things.append(b)
	g._recount_supply(0)
	g.players[0]["cap"] = 200
	for k in ["winder", "clock_soldier", "springer", "netter", "pendulum", "ballista", "great_winder", "brass_serpent", "cuckoo", "ticking_owl"]:
		things.append(g._add_unit(k, 0, hall.center() + Vector2(0, 220)))
	await io.frames(10)
	var too_long := {}
	var font := UiStyle.bold_font()
	for e in things:
		if e == null:
			continue
		g.set_selection([e])
		g.camera.position = e.center()
		await io.frames(6)
		for b in g.hud._card_buttons:
			var lab := Loc.t(String(b["item"][1]).trim_prefix("> ").trim_prefix("~ "))
			var w := (b["rect"] as Rect2).size.x - 5
			if font.get_string_size(lab, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x > w:
				too_long[lab] = e.kind
		await io.shot("card_%s_%s" % [Settings.language, e.kind])
	print("PT  LABELS TOO LONG AT 8 PX (%s): %s" % [Settings.language, too_long])
	Settings.set_language("en")
	quit(0)
