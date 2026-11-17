extends SceneTree
var main: Node
func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()
func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("c01_thirteenth", "solo"))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	print("ais ", g.ais.size(), " teams ", r.team_ids)
	for t in r.team_ids.size():
		var us := g.units.filter(func(u): return u.team == t)
		var bs := g.buildings.filter(func(b): return b.team == t)
		print(t, " units ", us.map(func(u): return u.kind), " bld ", bs.map(func(b): return [b.kind, b.cell]))
	print("tags ", r.tags.keys())
	print("hollweg ", r.tagged("hollweg")[0].kind, " name ", r.tagged("hollweg")[0].get_meta("mission_name",""))
	print("objs ", r.objectives_for("guild").map(func(o): return r.objective_text(o)))
	print("deny ", g.can_train(g.buildings.filter(func(b): return b.team == 0 and b.kind == "clocktower")[0], "pendulum"), " | ", g.requirement_text(0, "heavy_works"))
	# fire the dusk directly
	for tid in ["dusk"]:
		for tr in r.data["triggers"]:
			if tr["id"] == tid:
				r.fire(tr)
	for tag in ["seed_mill", "seed_baths", "links", "mill_works"]:
		print(tag, " ", r.tagged(tag).map(func(b): return b.cell))
	for tr in r.data["triggers"]:
		if tr["id"] == "night":
			r.fire(tr)
	for tag in ["seed_market", "seed_east"]:
		print(tag, " ", r.tagged(tag).map(func(b): return b.cell))
	print("log done")
	quit(0)
