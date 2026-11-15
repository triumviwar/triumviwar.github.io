extends SceneTree
## Pictures of the ROOTMAW SPOTS (brood-rootmaw-spots, docs/brood_rootmaw_spots.md) for docs/shots/rootmaw_spots/:
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1600x900 --fixed-fps 30 --script res://tools/shot_rootmaw_spots.gd -- \
##       out:/abs/dir [maps:a,b,...]
## For each map (a Brood player against a Crown computer, at the start):
##   main_<map>.png   her base: the start Rootmaw and the 2 gold marks for the other two (HUD on, minimap marks);
##   place_<map>.png  the same while placing a Rootmaw (brighter, their circles, "ROOTMAWS 1/3" over her);
##   turtle_<map>.png a Mound Turtle rooted on her best turtle spot and its 2 marks (her two filled in), placing a Rootmaw.
var main: Node
var out := ""
var maps: Array = ["greenhold", "dune_sea", "hollowfen"]
var t := 0.0
var busy := false


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split(":", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"out": out = kv[1]
			"maps": maps = Array(kv[1].split(","))
	DirAccess.make_dir_recursive_absolute(out)
	Settings.load_all()
	Settings.device = "pc"
	Settings.rootmaw_spots = true
	Settings.expansion_spots = true
	Settings.apply()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _process(delta: float) -> bool:
	t += delta
	if t > 0.3 and not busy:
		busy = true
		_run()
	return false


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _snap(g: Game, name: String) -> void:
	await _frames(3)
	g.update_view_rect()
	g.overlay.queue_redraw()
	await _frames(30)
	var img: Image = root.get_viewport().get_texture().get_image()
	img.save_png("%s/%s.png" % [out, name])
	print("shot ", name)


func _look(g: Game, p: Vector2, z: float) -> void:
	g.camera.zoom = Vector2(z, z)
	g.camera.position = p + Vector2(0, 90)          # (the HUD covers the bottom)
	g.camera.reset_smoothing()


func _run() -> void:
	for map in maps:
		var slots: Array = [{"who": "you", "faction": "brood", "colour": 0, "side": 0, "strategy": "balanced"},
			{"who": "normal", "faction": "crown", "colour": 1, "side": 1, "strategy": "balanced"}]
		main.start({"map": map, "seed": 7, "slots": slots})
		await _frames(5)
		var g: Game = main.game
		if g.hud:
			g.hud.countdown = 0.0
		paused = false
		await _frames(100)          # (she roots, her swamp spreads)
		g.process_mode = Node.PROCESS_MODE_DISABLED
		g.camera.process_mode = Node.PROCESS_MODE_ALWAYS
		if g.controls:
			g.controls.process_mode = Node.PROCESS_MODE_DISABLED
		var q := BroodNew.queen(g, g.human)
		g.maw_spots._key = "-"
		g.maw_spots.refresh()
		_look(g, q.position, 0.72)
		await _snap(g, "main_%s" % map)
		g.controls.mode = "nb_morph"
		g.controls.place_kind = BroodNew.MAW
		g.maw_spots._placing = true
		g.maw_spots._key = "-"
		g.maw_spots.refresh()
		_look(g, q.position, 0.72)
		await _snap(g, "place_%s" % map)
		g.controls.mode = ""
		g.maw_spots._placing = false
		# her two marks filled, then a turtle on her best turtle spot
		for s in g.maw_spots.shown.duplicate():
			var m := g._add_unit(BroodNew.MAW, g.human, s["p"])
			m.tesla_mode = "deployed"
			m.nb["m"] = "deployed"
			BroodRoot.footprint_on(g, m, false)
			BroodNew._claim(g, m)
		var picks := ExpansionSpots.nb_pick(g, g.human, g.exp_spots)
		if not picks.is_empty():
			var feet := BroodRoot.feet_at(BroodNew.TURTLE, picks[0]["tc"])
			var tu := g._add_unit(BroodNew.TURTLE, g.human, feet)
			tu.tesla_mode = "deployed"
			tu.nb["m"] = "deployed"
			BroodRoot.footprint_on(g, tu, false)
			tu.nb["swr"] = BroodNew.swamp_full(tu)
			g._update_swamp()
			g.process_mode = Node.PROCESS_MODE_INHERIT
			await _frames(2)
			g.process_mode = Node.PROCESS_MODE_DISABLED
			g.maw_spots._key = "-"
			g.maw_spots.refresh()
			g.exp_spots.refresh()          # (the turtle spot it took hides)
			g.controls.mode = "nb_morph"
			g.controls.place_kind = BroodNew.MAW
			g.maw_spots._placing = true
			g.maw_spots._key = "-"
			g.maw_spots.refresh()
			_look(g, tu.position, 0.72)
			await _snap(g, "turtle_%s" % map)
		main.game = null
		g.queue_free()
		await _frames(3)
	quit(0)
