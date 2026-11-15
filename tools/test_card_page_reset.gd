extends SceneTree
## A CARD PAGE IS SHUT BY A NEW PICK (the owner, 2026-11-15 20:27): a worker given BUILD and then unselected and picked
## again shows his MAIN card, not the build page he left open. For the Crown, the Clockwork and the Brood (grub).
## Also: the build page stays open while the same selection keeps it (a redraw of the card does not shut it).
##   godot --headless --fixed-fps 30 --script res://tools/test_card_page_reset.gd
var main: Node
var t := 0.0
var busy := false
var fails := 0


func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _process(delta: float) -> bool:
	t += delta
	if busy or t < 0.2:
		return false
	busy = true
	_run()
	return false


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _labels(card: Array) -> Array:
	return card.map(func(it) -> String: return String(it[1]))


func _run() -> void:
	for f in ["crown", "clockwork", "brood"]:
		if main.game != null:
			main._to_menu()
			await process_frame
			await process_frame
		main.start({"map": "hollowfen", "seed": 4242, "slots": [
			{"who": "you", "faction": f, "colour": 0, "side": 0},
			{"who": "easy", "faction": "crown" if f != "crown" else "brood", "colour": 1, "side": 1}]})
		for i in 30:
			await physics_frame
		var g: Game = main.game
		g.hud.countdown = 0.0
		for ai in g.ais:
			ai.process_mode = Node.PROCESS_MODE_DISABLED
		var w: Unit = null
		for u in g.units:
			if u.team == g.human and u.is_worker():
				w = u
				break
		_check(w != null, "%s: a worker to pick" % f)
		if w == null:
			continue
		g.set_selection([w])
		var main_card := _labels(g.hud._build_card())
		_check(main_card.has("BUILD"), "%s: the worker's main card has BUILD" % f)
		g.hud.page = "build"
		var page_card := _labels(g.hud._build_card())
		_check(page_card.has("BACK"), "%s: BUILD opens the build page" % f)
		var again := _labels(g.hud._build_card())
		_check(again.has("BACK"), "%s: the page stays open while he stays picked" % f)
		g.set_selection([])
		g.hud._build_card()
		g.set_selection([w])
		var back := _labels(g.hud._build_card())
		_check(back.has("BUILD") and not back.has("BACK"), "%s: unselected and picked again: the main card (%s)" % [f, ", ".join(back)])
		g.hud.page = "build"
		g.hud._build_card()
		g.set_selection([w])          # (picked again without unselecting: the same pick, the page stays)
		_check(_labels(g.hud._build_card()).has("BACK"), "%s: the same worker clicked again keeps the page" % f)
	print("RESULT %s (%d failed)" % ["PASS" if fails == 0 else "FAIL", fails])
	quit(1 if fails > 0 else 0)
