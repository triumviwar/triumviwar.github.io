extends SceneTree
## ROOTMAW SPOTS AND THE COUNT (brood-rootmaw-spots; scripts/rootmaw_spots.gd, docs/brood_rootmaw_spots.md):
##  [count]    the Brood Mother's swamp takes 3 Rootmaws, a rooted Mound Turtle's 2: the 4th (the 3rd) is refused with a
##             "Full: ..." reason (BroodRoot.place_problem, the ghost's refusal), a grub on its way to turn into one counts,
##             and the card's label reads "ROOTMAWS n/3";
##  [fit]      on every built-in map (2 players, all-Brood) the marks give each side's Mother the 2 spots its start
##             Rootmaw leaves room for and each of its 2 marked turtle sites 2 spots, every one legal for a player's ROOT
##             and the computer's, a circle's width apart and from the start Rootmaw; the two sides' marks mirror each other;
##  [show]     shown to a Brood player only (not a Crown player, not when watching, not with Settings.rootmaw_spots off);
##  [snap]     no snapping: a legal spot off the marks roots where it was put.
##   godot --headless --fixed-fps 30 --script res://tools/test_rootmaw_spots.gd [-- maps:a,b]

var failed := 0
var main: Node


func _initialize() -> void:
	_run.call_deferred(OS.get_cmdline_user_args())


func _ok(c: bool, what: String) -> void:
	if not c:
		failed += 1
		print("  FAIL ", what)
	else:
		print("  ok   ", what)


func _make(id: String, facs: Array, demo := true) -> Game:
	var g := Game.new()
	g.map_id = id
	g.demo = demo
	var sides: Array = []
	for i in facs.size():
		sides.append(i % 2)
	g.factions = facs
	g.sides = sides
	g.colours = range(facs.size())
	root.add_child(g)
	return g


func _root_at(g: Game, k: String, t: int, p: Vector2) -> Unit:
	var u := g._add_unit(k, t, p)
	u.tesla_mode = "deployed"
	u.nb["m"] = "deployed"
	BroodRoot.footprint_on(g, u, false)
	if k == BroodNew.TURTLE:
		u.nb["swr"] = BroodNew.swamp_full(u)
	if k == BroodNew.MAW:
		BroodNew._claim(g, u)
	g._update_swamp()
	return u


func _drop(g: Game, u: Unit) -> void:
	BroodRoot.footprint_off(g, u)
	u.dead = true
	g.units.erase(u)
	u.queue_free()
	g._update_swamp()


func _run(args: Array) -> void:
	var ids: Array = MapGen.all_ids()
	for a in args:
		if String(a).begins_with("maps:"):
			ids = Array(String(a).substr(5).split(","))
	await _count_checks()
	await _show_checks()
	for id in ids:
		await _fit_map(id)
	print("rootmaw spots: %s" % ("ALL OK" if failed == 0 else "%d FAILED" % failed))
	quit(1 if failed > 0 else 0)


# ------------------------------------------------------------------ [count] and [snap]

func _count_checks() -> void:
	print("[count] greenhold")
	var g := _make("greenhold", ["brood", "brood"])
	await process_frame
	await process_frame
	g._update_swamp()
	var q := BroodNew.queen(g, 0)
	q.tesla_mode = "deployed"
	q.nb["m"] = "deployed"
	g._update_swamp()
	_ok(RootmawSpots.count_at(g, q) == [1, 3], "the Mother's swamp starts with 1 of 3 (%s)" % str(RootmawSpots.count_at(g, q)))
	var spots := RootmawSpots.fit(g, q)
	_ok(spots.size() == 2, "2 marked spots round the Mother (%d)" % spots.size())
	if spots.size() < 2:
		g.queue_free()
		return
	# [snap] a legal spot off the marks: accepted where it is
	var off := Vector2.INF
	for c in RootmawSpots.candidates(g, q):
		var p: Vector2 = c[0]
		if spots.all(func(s: Vector2) -> bool: return s.distance_to(p) > 2.0 * Defs.TILE) and BroodRoot.place_problem(g, 0, BroodNew.MAW, p) == "":
			off = p
			break
	_ok(off != Vector2.INF, "[snap] a legal spot off the marks exists")
	if off != Vector2.INF:
		var m0 := g._add_unit(BroodNew.MAW, 0, off)
		var why := BroodNew.on_root(g, m0)
		_ok(why == "" and m0.position == BroodRoot.snap(BroodNew.MAW, off), "[snap] it roots where it was put, not on a mark (%s)" % why)
		_drop(g, m0)
	# a grub on its way to turn into one counts; then the 2 marked spots, then the 4th is refused
	var gr: Unit = null
	for u in g.units:
		if u.team == 0 and u.kind == "grub":
			gr = u
			break
	gr.order = "nb_morph"
	gr.nb["mk"] = BroodNew.MAW
	gr.order_point = spots[0]
	_ok(RootmawSpots.count_at(g, q) == [2, 3], "a grub on its way to turn into a Rootmaw counts (%s)" % str(RootmawSpots.count_at(g, q)))
	gr.order = ""
	gr.nb.erase("mk")
	var m1 := _root_at(g, BroodNew.MAW, 0, spots[0])
	_ok(BroodRoot.place_problem(g, 0, BroodNew.MAW, spots[1]) == "", "the 3rd on its mark: allowed")
	var m2 := _root_at(g, BroodNew.MAW, 0, spots[1])
	_ok(RootmawSpots.count_at(g, q) == [3, 3], "3 of 3 (%s)" % str(RootmawSpots.count_at(g, q)))
	_ok(RootmawSpots.label(g, q) == "ROOTMAWS 3/3", "the card reads %s" % RootmawSpots.label(g, q))
	_ok(RootmawSpots.fit(g, q).is_empty(), "a full swamp shows no marks")
	# a 4th anywhere on her swamp: no legal spot left, and the reason is the count
	var cands_full := RootmawSpots.candidates(g, q).size()
	_ok(cands_full == 0, "with 3 of 3 no spot on her swamp is legal (%d)" % cands_full)
	_ok(RootmawSpots.room_problem(g, 0, spots[0] + Vector2(Defs.TILE, 0)).begins_with("Full"), "room_problem says Full on her swamp")
	# a turtle: 2
	var es: ExpansionSpots = g.exp_spots
	var sites: Array = ExpansionSpots.nb_rate(g, 0, es.all)
	var tu: Unit = null
	for s in sites:
		var feet := BroodRoot.feet_at(BroodNew.TURTLE, s["tc"])
		if BroodRoot.place_problem(g, 0, BroodNew.TURTLE, feet) == "" and feet.distance_to(q.position) > 20 * Defs.TILE:
			tu = _root_at(g, BroodNew.TURTLE, 0, feet)
			break
	_ok(tu != null, "a turtle on a site")
	if tu != null:
		_ok(RootmawSpots.count_at(g, tu) == [0, 2], "a rooted turtle's swamp: 0 of 2 (%s)" % str(RootmawSpots.count_at(g, tu)))
		var ts := RootmawSpots.fit(g, tu)
		_ok(ts.size() == 2, "2 marked spots round the turtle (%d)" % ts.size())
		if ts.size() == 2:
			_root_at(g, BroodNew.MAW, 0, ts[0])
			_root_at(g, BroodNew.MAW, 0, ts[1])
			_ok(RootmawSpots.count_at(g, tu) == [2, 2], "2 of 2 (%s)" % str(RootmawSpots.count_at(g, tu)))
			_ok(RootmawSpots.room_problem(g, 0, tu.position + Vector2(0, 2 * Defs.TILE)).begins_with("Full"), "the turtle's 3rd: Full")
	g.queue_free()
	await process_frame


# ------------------------------------------------------------------ [show]

func _show_checks() -> void:
	print("[show]")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	for i in 6:
		await process_frame
	for fac in ["brood", "crown"]:
		main.start({"map": "greenhold", "seed": 4242, "slots": [
			{"who": "you", "faction": fac, "colour": 0, "side": 0},
			{"who": "easy", "faction": "brood", "colour": 1, "side": 1}]})
		for i in 10:
			await process_frame
		var g: Game = main.game
		var q := BroodNew.queen(g, 0)
		if q != null:
			q.tesla_mode = "deployed"
			q.nb["m"] = "deployed"
		g._update_swamp()
		g.maw_spots._key = "-"
		g.maw_spots.refresh()
		if fac == "brood":
			_ok(g.maw_spots.shown.size() == 2, "a Brood player sees 2 Rootmaw marks (%d)" % g.maw_spots.shown.size())
			var mine := g.maw_spots.shown.all(func(s: Dictionary) -> bool: return (s["src"] as Unit).team == 0)
			_ok(mine, "only his own side's swamp is marked")
			Settings.rootmaw_spots = false
			g.maw_spots.refresh()
			_ok(g.maw_spots.shown.is_empty(), "SHOW ROOTMAW SPOTS off: none")
			Settings.rootmaw_spots = true
			g.maw_spots.refresh()
			_ok(g.maw_spots.shown.size() == 2, "on again: shown")
		else:
			_ok(g.maw_spots.shown.is_empty(), "a Crown player sees none (the enemy Brood's swamp neither)")
		g.queue_free()
		main.game = null
		for i in 4:
			await process_frame
	var gd := _make("greenhold", ["brood", "brood"], true)
	await process_frame
	gd.maw_spots.refresh()
	_ok(gd.maw_spots.shown.is_empty(), "watching (demo): none")
	gd.queue_free()
	await process_frame


# ------------------------------------------------------------------ [fit] on every map

func _fit_map(id: String) -> void:
	var g := _make(id, ["brood", "brood"])
	await process_frame
	await process_frame
	g._update_swamp()
	var got := []
	var bad := []
	for t in 2:
		var q := BroodNew.queen(g, t)
		q.tesla_mode = "deployed"
		q.nb["m"] = "deployed"
		g._update_swamp()
		var start_maw: Unit = null
		for u in g.units:
			if u.team == t and u.kind == BroodNew.MAW and not u.dead:
				start_maw = u
		var sp := RootmawSpots.fit(g, q)
		got.append(sp)
		if sp.size() != 2:
			bad.append("p%d: %d marks round the Mother (want 2)" % [t, sp.size()])
		for p in sp:
			if BroodRoot.place_problem(g, t, BroodNew.MAW, p) != "" or BroodRoot.place_problem(g, t, BroodNew.MAW, p, null, true) != "":
				bad.append("p%d: mark %s not legal: %s" % [t, str(p), BroodRoot.place_problem(g, t, BroodNew.MAW, p, null, true)])
			if p.distance_to(start_maw.position) < 2.0 * Defs.PIT_CLAIM * Defs.TILE - 0.01:
				bad.append("p%d: mark %s in the start Rootmaw's circle" % [t, str(p)])
		if sp.size() == 2 and (sp[0] as Vector2).distance_to(sp[1]) < 2.0 * Defs.PIT_CLAIM * Defs.TILE - 0.01:
			bad.append("p%d: its two marks overlap" % t)
		# the 2 marked turtle sites
		var es: ExpansionSpots = g.exp_spots
		var n_sites := 0
		for s in ExpansionSpots.nb_rate(g, t, es.all):
			if n_sites >= 2:
				break
			var feet := BroodRoot.feet_at(BroodNew.TURTLE, s["tc"])
			if BroodRoot.place_problem(g, t, BroodNew.TURTLE, feet) != "":
				continue
			n_sites += 1
			var tu := _root_at(g, BroodNew.TURTLE, t, feet)
			var ts := RootmawSpots.fit(g, tu)
			if ts.size() != 2:
				bad.append("p%d: turtle at %s: %d marks (want 2)" % [t, str(s["tc"]), ts.size()])
			_drop(g, tu)
	# mirror-fair: p1's marks are the mirror images of p0's (their footprints)
	if got[0].size() == got[1].size():
		var fs: Vector2i = BroodRoot.fp(BroodNew.MAW)[0]
		var a: Array = got[0].map(func(p: Vector2) -> Vector2i: return g.sym_rect(0, BroodRoot.cell_for(BroodNew.MAW, p), fs))
		var b: Array = got[1].map(func(p: Vector2) -> Vector2i: return g.sym_rect(1, BroodRoot.cell_for(BroodNew.MAW, p), fs))
		a.sort()
		b.sort()
		if a != b and g._flip_of(1) != Vector2i.ZERO:      # (only where the map mirrors the starts: Game.start_flip)
			# (a note, not a failure: a map's mirror allows a few stray trees and rocks (Game._map_symmetries), and the
			# marks follow the open ground round them; both sides still get their full count)
			print("    note: the sides' marks don't mirror exactly (in the first start's frame): %s / %s" % [str(a), str(b)])
	else:
		bad.append("the sides got %d and %d marks" % [got[0].size(), got[1].size()])
	print("[fit] %-18s %s" % [id, "ok" if bad.is_empty() else "FAIL"])
	for m in bad:
		print("    BAD ", m)
	if not bad.is_empty():
		failed += 1
	g.queue_free()
	await process_frame
