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
				if OS.get_cmdline_user_args().has("debug"):
					for r in radii:
						RootmawSpots.r_test = r
						var cs := RootmawSpots.candidates(g, q, start_maw)
						print("  p%d r%.1f cands %d: %s" % [t, r, cs.size(), str(cs.slice(0, 6).map(func(c): return [g.cell_of(c[0]), snappedf(c[1], 0.1)]))])
				for r in radii:
					RootmawSpots.r_test = r
					var with_start := RootmawSpots.pick(RootmawSpots.candidates(g, q, start_maw), 2, [start_maw.position]).size() + 1
					var empty := RootmawSpots.pick(RootmawSpots.candidates(g, q, start_maw), 3, []).size()
					# (the empty case: the start Rootmaw's own footprint still lies there; its cells are free ground
					# for the others in truth, so measure without it too)
					res.append([r, empty, with_start])
				# the empty swamp for real: the start Rootmaw gone
				var spot := start_maw.position
				_drop(g, start_maw)
				for i in radii.size():
					RootmawSpots.r_test = radii[i]
					var e2 := RootmawSpots.pick(RootmawSpots.candidates(g, q), 3, []).size()
					res[i][1] = maxi(int(res[i][1]), e2)
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
					for r in radii:
						RootmawSpots.r_test = r
						var fixed: Array = [sm.position]
						tres[r].append(RootmawSpots.pick(RootmawSpots.candidates(g, tu), 2, fixed).size())
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
	print("\nSUMMARY (fewest that fit: main empty / main with its start Rootmaw / a marked turtle site)")
	for r in radii:
		var w: Dictionary = worst[r]
		print("r %.1f: main %d, main+start %d, turtle %d; short: %d" % [r, int(w["empty"]), int(w["start"]), int(w["turtle"]), (w["bad"] as Array).size()])
		for b in (w["bad"] as Array).slice(0, 12):
			print("    ", b)
	quit(0)
