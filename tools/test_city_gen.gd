extends SceneTree
## THE CITY GENERATOR (tools/campaign/city_gen.py, docs/city_generator.md):
##   - the same seed gives the same town, another seed another (its demo town, every call in it), run through python3;
##   - campaign/maps/lyon_presses.json is what tools/campaign/make_lyon_map.py writes now (the map and the script agree);
##   - in the game (a01_presses on Lyon): every house the generator put down is placed by the map loader (the
##     generator's foot rules are the game's), the rivers and fords are where the map says, and from the garrison a
##     unit can walk to every square, bridge, stair, lot and the hall's square (the game's own pathfinder), while the
##     hidden yard is walled in but for its two traboules.
##   godot --headless --fixed-fps 30 --script res://tools/test_city_gen.gd
## Prints CHECK lines, then "city_gen: N failures"; exit code 1 on a failure.
var main: Node
var fails := 0


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-74s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _py(args: Array) -> Array:
	var out: Array = []
	var code := OS.execute("python3", args, out, true)
	return [code, "".join(out)]


func _run() -> void:
	await process_frame
	_determinism()
	await _in_game()
	print("city_gen: %d failures" % fails)
	quit(1 if fails > 0 else 0)


func _determinism() -> void:
	var gen := ProjectSettings.globalize_path("res://tools/campaign/city_gen.py")
	var a := ProjectSettings.globalize_path("user://city_demo_a.json")
	var b := ProjectSettings.globalize_path("user://city_demo_b.json")
	var c := ProjectSettings.globalize_path("user://city_demo_c.json")
	var ra := _py([gen, "--demo", "7", "--out", a])
	var rb := _py([gen, "--demo", "7", "--out", b])
	var rc := _py([gen, "--demo", "8", "--out", c])
	check("python3 runs the generator (demo town, every call)", ra[0] == 0 and rb[0] == 0 and rc[0] == 0, String(ra[1]).strip_edges())
	var ta := FileAccess.get_file_as_string("user://city_demo_a.json")
	var tb := FileAccess.get_file_as_string("user://city_demo_b.json")
	var tc := FileAccess.get_file_as_string("user://city_demo_c.json")
	check("the same seed: the same town", ta != "" and ta == tb)
	check("another seed: another town", tc != "" and tc != ta)
	var d = JSON.parse_string(ta)
	check("the demo town is a map editor map (size, cells, props, starts)", d is Dictionary and (d["cells"] as String).length() == int(d["size"][0]) * int(d["size"][1])
		and (d["props"] as Array).size() > 100 and (d["cells"] as String).contains("f") and (d["cells"] as String).contains("r") and (d["cells"] as String).contains("k"))
	# Lyon: the map in the repo is what its script writes now
	var lyon := ProjectSettings.globalize_path("user://lyon_check.json")
	var rl := _py(["-c", "import sys; sys.path.insert(0, '%s'); import make_lyon_map as L; L.build().save('%s')" % [ProjectSettings.globalize_path("res://tools/campaign"), lyon]])
	check("make_lyon_map.py runs", rl[0] == 0, String(rl[1]).strip_edges())
	check("campaign/maps/lyon_presses.json is the script's town (rebuild it after a change)",
		FileAccess.get_file_as_string("user://lyon_check.json") == FileAccess.get_file_as_string("res://campaign/maps/lyon_presses.json"))
	for f in ["user://city_demo_a.json", "user://city_demo_b.json", "user://city_demo_c.json", "user://lyon_check.json"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(f))


func _in_game() -> void:
	var m := Campaign.mission("a01_presses")
	main.start(Campaign.make_cfg("a01_presses", "solo", "p1", false))
	await process_frame
	await process_frame
	var g: Game = main.game
	var md := Campaign.map_data("lyon_presses")
	check("Lyon in the game: every house put down (the generator's foot rules are the loader's)", g.mapgen.props.size() == (md["props"] as Array).size(),
		"%d of %d" % [g.mapgen.props.size(), (md["props"] as Array).size()])
	var cells: String = md["cells"]
	var W := int(md["size"][0])
	var water := 0
	var fords := 0
	for i in cells.length():
		if cells[i] == "w":
			water += 1
			if g.water[i] != 1:
				fords = -99999
		elif cells[i] == "f":
			fords += 1
	check("the rivers are water, the six bridges fords", water > 500 and fords > 30)
	var areas: Dictionary = m["areas"]
	var from := g.cell_center(Vector2i(112, 46))
	var bad: Array = []
	var names: Array = []
	for nm in areas:
		var s := String(nm)
		if s.begins_with("cand_") or s.begins_with("home_") or s.begins_with("pont_") or s.begins_with("stair_") \
				or s in ["terreaux", "jacobins", "cordeliers", "bellecour", "saint_jean", "hall_square", "fourviere_square", "garrison"]:
			names.append(s)
	for nm in names:
		var a: Array = areas[nm]
		var r := Rect2(float(a[0]) * Defs.TILE, float(a[1]) * Defs.TILE, float(a[2]) * Defs.TILE, float(a[3]) * Defs.TILE)
		var p := g.find_path(from, r.get_center())
		var end: Vector2 = p[p.size() - 1] if p.size() > 0 else from
		if not r.grow(Defs.TILE * 1.5).has_point(end):
			bad.append(nm)
	check("from the garrison a unit walks to every square, bridge, stair and lot (%d)" % names.size(), bad.is_empty(), str(bad))
	# the yard: walled in but for its traboules (the mission's doors in them opened, as its Part 3 does)
	g.mission.act({"spare": {"tag": "yard_doors", "on": false}})
	g.mission.act({"hurt": {"tag": "yard_doors", "amount": 99999}})
	g._rebuild_hash()
	var yard: Array = areas["yard"]
	var inside := Vector2i(int(yard[0]) + 1, int(yard[1]) + 1)
	var into := g.find_path(from, g.cell_center(inside))
	check("the hidden yard can be walked into (through its traboules)", into.size() > 0 and into[into.size() - 1].distance_to(g.cell_center(inside)) < Defs.TILE * 1.5)
	var through := false
	for t in ["trab_yard_s", "trab_yard_e"]:
		var ta: Array = areas[t]
		var tr := Rect2(float(ta[0]) * Defs.TILE, float(ta[1]) * Defs.TILE, float(ta[2]) * Defs.TILE, float(ta[3]) * Defs.TILE).grow(Defs.TILE * 0.5)
		for pt in into:
			if tr.has_point(pt):
				through = true
	check("...and the way in is a traboule", through)
	var yb: Array = areas["yard_block"]
	var walled := true
	for x in range(int(yb[0]), int(yb[0]) + int(yb[2])):
		for y in [int(yb[1]), int(yb[1]) + int(yb[3]) - 1]:
			var c := Vector2i(x, y)
			var in_trab := false
			for t in ["trab_yard_s", "trab_yard_e"]:
				var ta: Array = areas[t]
				if Rect2i(int(ta[0]), int(ta[1]), int(ta[2]), int(ta[3])).has_point(c):
					in_trab = true
			if not in_trab and g.solid[g.idx(c)] == 0:
				walled = false
	check("the yard's block is solid houses along its edges (but the traboules)", walled)
