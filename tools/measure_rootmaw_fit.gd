extends SceneTree
## ROOTMAW FIT (brood-rootmaw-spots, docs/brood_rootmaw_spots.md): on every built-in map, all-Brood, how many Rootmaws
## fit on each side's swamp with the circle radius r (no two circles overlapping: middles 2r apart), with the game's own
## placing rules as the computer asks them (footprint, level, ramps and lanes clear: RootmawSpots.candidates):
##  - main, empty: the Mother's swamp (stage 1) with her start Rootmaw taken away (the full 3 from nothing),
##  - main, start: with her start Rootmaw where the game puts it (2 more round it),
##  - turtles: a Mound Turtle rooted on each of the side's rated turtle sites (ExpansionSpots.nb_rate; the 2 marked
##    ones first) and the Rootmaws that fit on its swamp (want 2).
##   godot --headless --fixed-fps 30 --script res://tools/measure_rootmaw_fit.gd [-- r:8,7,6 maps:a,b turtles:all]

var radii: Array = [8.0, 7.5, 7.0, 6.5, 6.0]
var all_turtles := false
var quality := false
var qual: Array = []


func _initialize() -> void:
	_run.call_deferred(OS.get_cmdline_user_args())


func _make(id: String, n: int) -> Game:
	var g := Game.new()
	g.map_id = id
	g.demo = true
	var facs: Array = []
	var sides: Array = []
	for i in n:
		facs.append("brood")
		sides.append(i % 2)
	g.factions = facs
	g.sides = sides
	g.colours = range(n)
	root.add_child(g)
	return g


func _drop(g: Game, u: Unit) -> void:
	BroodRoot.footprint_off(g, u)
	u.dead = true
	g.units.erase(u)
	u.queue_free()


func _run(args: Array) -> void:
	var ids: Array = MapGen.all_ids()
	for a in args:
		if String(a).begins_with("r:"):
			radii = Array(String(a).substr(2).split(",")).map(func(x): return float(x))
		elif String(a).begins_with("maps:"):
			ids = Array(String(a).substr(5).split(","))
		elif a == "turtles:all":
			all_turtles = true
		elif a == "quality":
			quality = true
	# per radius: [main empty min, main start min, turtle (marked) min, failures list]
	var worst := {}
	for r in radii:
		worst[r] = {"empty": 99, "start": 99, "turtle": 99, "bad": []}
	for id in ids:
		var counts: Array = [2]
		if MapGen.max_players(id) > 2:
			counts.append(MapGen.max_players(id))
		for n in counts:
			var g := _make(id, n)
			await process_frame
			await process_frame
			g._update_swamp()
			var line := "%-18s %dp" % [id, n]
			for t in n:
				var q := BroodNew.queen(g, t)
				var start_maw: Unit = null
				for u in g.units:
					if u.team == t and u.kind == BroodNew.MAW and not u.dead:
						start_maw = u
				q.tesla_mode = "deployed"
				q.nb["m"] = "deployed"
				var res := []
				# (the spots are looked for once with a tiny circle, so no circle rules them out; the radius is applied
				# in the fitting: RootmawSpots.pick)
				RootmawSpots.r_test = 0.25
				var c_start := RootmawSpots.candidates(g, q, start_maw, true)
				var spot := start_maw.position
				_drop(g, start_maw)
				var c_empty := RootmawSpots.candidates(g, q, null, true)
				var lvl := int(g.height[g.idx(g.cell_of(BroodRoot.anchor(g, q)))])
				var reg := BroodRoot.home_region(g, q.position)
				for r in radii:
					RootmawSpots.r_test = r
					var ws := RootmawSpots.pick(c_start, 2, [spot])
					var with_start := ws.size() + 1
					if quality:
						# (where the marks fall: on her level and in her region, and how far from her feet, tiles)
						var same := 1 if int(g.height[g.idx(g.cell_of(spot))]) == lvl and g.region_of(g.cell_of(spot)) == reg else 0
						var ds: Array = [snappedf(spot.distance_to(q.position) / Defs.TILE, 0.1)]
						for p in ws:
							if int(g.height[g.idx(g.cell_of(p))]) == lvl and g.region_of(g.cell_of(p)) == reg:
								same += 1
							ds.append(snappedf((p as Vector2).distance_to(q.position) / Defs.TILE, 0.1))
						qual.append("%s %dp p%d r%.1f: on her level %d/3, tiles from her %s" % [id, n, t, r, same, str(ds)])
					var empty := RootmawSpots.pick(c_empty, 3, []).size()
					res.append([r, empty, with_start])
				RootmawSpots.r_test = 0.25
				var sm := g._add_unit(BroodNew.MAW, t, spot)
				sm.tesla_mode = "deployed"
				sm.nb["m"] = "deployed"
				BroodRoot.footprint_on(g, sm, false)
				# turtles on the side's sites
				var es: ExpansionSpots = g.exp_spots
				var sites: Array = ExpansionSpots.nb_rate(g, t, es.all)
				if not all_turtles:
					sites = sites.slice(0, 2)
				var tres := {}
				for r in radii:
					tres[r] = []
				for s in sites:
					var feet := BroodRoot.feet_at(BroodNew.TURTLE, s["tc"])
					if BroodRoot.place_problem(g, t, BroodNew.TURTLE, feet) != "":
						continue
					var tu := g._add_unit(BroodNew.TURTLE, t, feet)
					tu.tesla_mode = "deployed"
					tu.nb["m"] = "deployed"
					BroodRoot.footprint_on(g, tu, false)
					RootmawSpots.r_test = 0.25
					var ct := RootmawSpots.candidates(g, tu, null, true)
					for r in radii:
						RootmawSpots.r_test = r
						tres[r].append(RootmawSpots.pick(ct, 2, [spot]).size())
					_drop(g, tu)
				line += "  p%d:" % t
				for i in radii.size():
					var r: float = radii[i]
					var tl: Array = tres[r]
					var tmin: int = tl.min() if not tl.is_empty() else -1
					line += " r%s %d/%d/%s" % [str(r), int(res[i][1]), int(res[i][2]), ",".join(tl.map(func(x): return str(x)))]
					var w: Dictionary = worst[r]
					w["empty"] = mini(int(w["empty"]), int(res[i][1]))
					w["start"] = mini(int(w["start"]), int(res[i][2]))
					if tmin >= 0:
						w["turtle"] = mini(int(w["turtle"]), tmin)
					if int(res[i][1]) < 3 or int(res[i][2]) < 3 or (tmin >= 0 and tmin < 2):
						(w["bad"] as Array).append("%s %dp p%d: main %d (start %d), turtles %s" % [id, n, t, int(res[i][1]), int(res[i][2]), str(tl)])
			print(line)
			g.queue_free()
			await process_frame
	RootmawSpots.r_test = 0.0
	if quality:
		print("\nQUALITY (the Mother's start Rootmaw and the 2 marks)")
		for l in qual:
			print("  ", l)
	print("\nSUMMARY (fewest that fit: main empty / main with its start Rootmaw / a marked turtle site)")
	for r in radii:
		var w: Dictionary = worst[r]
		print("r %.1f: main %d, main+start %d, turtle %d; short: %d" % [r, int(w["empty"]), int(w["start"]), int(w["turtle"]), (w["bad"] as Array).size()])
		for b in (w["bad"] as Array).slice(0, 12):
			print("    ", b)
	quit(0)
