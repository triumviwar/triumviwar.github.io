extends SceneTree
## THE LIMIT IS LOCAL (econ-limit-local, the owner 2026-11-15 18:06: "it should be 2 per Town Hall, 2 per Clocktower";
## docs/econ_limit_local.md): every Farm / Powder Mill / Cog Press / Mainspring belongs to the hall it draws from (its
## nearest built hall) and each hall allows Defs.econ_per_hall of each kind round it.
##   [crown] 2 Farms near one Town Hall; a 3rd near the same hall is refused even with 2 halls (the side's limit is 4), with
##           the local reason; near the other hall it is fine; the cards' counts (FARMS 2/2, FARMS 1/2); the Powder Mill 1/1
##   [fallen] a fallen hall's Farms go to the next nearest: over its count (3/2) they work, no new one there
##   [going]  a hall going up allows nothing yet; a tie between two halls goes to the older one
##   [clock]  the same for Cog Presses (2 a Clocktower) and the Mainspring (1)
##   [ai]     the computer's spot finder skips a full hall (a spot by the other hall, or none when all are full: never a refused one)
##   godot --headless --fixed-fps 30 --script res://tools/test_econ_limit_local.gd
const U := preload("res://tools/gear_test_util.gd")
const HUD := preload("res://scripts/ui/hud.gd")
var fails := 0


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-82s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _count(g: Game, t: int, kind: String) -> int:
	return g.econ_count(t, kind)


## A cell where `kind` may go for t and whose nearest built hall is h, the limits set aside (Defs.econ_test): the spot a
## player would pick next to h. (-1, -1): none.
func _spot_by(g: Game, t: int, kind: String, h: Building, gear := false) -> Vector2i:
	var f := g.faction_of(t)
	Defs.econ_test = {f: {kind: 99}}
	var size: Vector2i = Defs.BUILDINGS[kind]["size"]
	var best := Vector2i(-1, -1)
	var bd := INF
	for y in range(h.cell.y - 16, h.cell.y + 17):
		for x in range(h.cell.x - 16, h.cell.x + 17):
			var c := Vector2i(x, y)
			if not g.in_map(c):
				continue
			var d := Vector2(c - h.cell).length()
			if d >= bd:
				continue
			var mid := (Vector2(c) + Vector2(size) * 0.5) * Defs.TILE
			if g.nearest_hall(mid, t) != h:
				continue
			if g.placement_problem(t, kind, c) != "" or not g.margin_free(c, size):
				continue
			if gear and g.gear_net.candidate(t, kind, c, false)["state"] != "ok":
				continue
			best = c
			bd = d
	Defs.econ_test = {}
	return best


func _lay(g: Game, t: int, kind: String, c: Vector2i) -> Building:
	var b := g._add_building(kind, t, c, true)
	if g.gear_net != null:
		g.gear_net.solve()
	return b


## A second hall of t: on free ground 19-30 tiles from the first.
func _second_hall(g: Game, t: int, a: Building, built := true) -> Building:
	var k := g.faction_hall(t)
	var c := g.find_spot(t, k, a, 19, 30, "near")
	if c.x < 0:
		return null
	var b := g._add_building(k, t, c, built)
	if g.gear_net != null:
		g.gear_net.solve()
	return b


func _card(g: Game, h: Building) -> String:
	var hud = HUD.new()
	hud.game = g
	var s: String = hud._econ_counts(h)
	hud.free()
	return s


func _run() -> void:
	# ================================================================ the Crown
	var g := U.make(root, ["crown", "clockwork"])
	await process_frame
	await process_frame
	var a := U.hall(g, 0)
	check("[crown] a Town Hall and its starting Farm", a != null and _count(g, 0, "farm") == 1, "%d" % _count(g, 0, "farm"))
	var per := Defs.econ_per_hall("crown", "farm")
	check("[crown] 2 Farms and 1 Powder Mill a Town Hall", per == 2 and Defs.econ_per_hall("crown", "powder_mill") == 1)
	var c := _spot_by(g, 0, "farm", a)
	check("[crown] a 2nd Farm near the main: allowed", c.x >= 0 and g.placement_problem(0, "farm", c) == "", g.placement_problem(0, "farm", c) if c.x >= 0 else "no spot")
	if c.x >= 0:
		_lay(g, 0, "farm", c)
	check("[crown] the main has 2 (econ_at)", g.econ_at(a, "farm") == 2, "%d" % g.econ_at(a, "farm"))
	var b := _second_hall(g, 0, a)
	check("[crown] a second Town Hall", b != null and g.halls_of(0).size() == 2)
	if b == null:
		_end()
		return
	check("[crown] the side's limit is 4, 2 laid", g.econ_limit(0, "farm") == 4 and _count(g, 0, "farm") == 2, "%d/%d" % [_count(g, 0, "farm"), g.econ_limit(0, "farm")])
	var c3 := _spot_by(g, 0, "farm", a)
	var why := g.placement_problem(0, "farm", c3) if c3.x >= 0 else "no spot"
	check("[crown] a 3rd Farm near the main is refused, though 2 halls allow 4", c3.x >= 0 and why == "This Town Hall already has its Farms (2/2). Build near another Town Hall.", why)
	check("[crown] the refusals are translated (pt, es)", Game.ECON_FULL.values().all(func(k: String) -> bool: return LangPt.T.has(k) and LangEs.T.has(k)))
	var fs := g.find_spot(0, "farm", a, 4, Defs.ECON_RANGE - 2, "behind")
	check("[crown] find_spot round the main finds no spot of the main's", fs.x < 0 or g.nearest_hall((Vector2(fs) + Vector2(Defs.BUILDINGS["farm"]["size"]) * 0.5) * Defs.TILE, 0) == b,
		str(fs))
	var cb := _spot_by(g, 0, "farm", b)
	check("[crown] near the other hall: allowed", cb.x >= 0 and g.placement_problem(0, "farm", cb) == "", g.placement_problem(0, "farm", cb) if cb.x >= 0 else "no spot")
	var fb: Building = null
	if cb.x >= 0:
		fb = _lay(g, 0, "farm", cb)
	check("[crown] it belongs to the new hall: 2/2 and 1/2", g.econ_at(a, "farm") == 2 and g.econ_at(b, "farm") == 1 and g.soil_hall(fb) == b)
	check("[crown] the cards: FARMS 2/2 at the main, 1/2 at the new hall", _card(g, a).begins_with("FARMS 2/2") and _card(g, b).begins_with("FARMS 1/2"), _card(g, a) + " | " + _card(g, b))
	check("[crown] the card counts the Powder Mill too", _card(g, a).contains("POWDER MILL 0/1"), _card(g, a))
	var cm := _spot_by(g, 0, "powder_mill", a)
	if cm.x >= 0:
		_lay(g, 0, "powder_mill", cm)
	var cm2 := _spot_by(g, 0, "powder_mill", a)
	var whym := g.placement_problem(0, "powder_mill", cm2) if cm2.x >= 0 else "no spot"
	check("[crown] a 2nd Powder Mill near the main is refused", cm.x >= 0 and cm2.x >= 0 and whym.begins_with("This Town Hall already has its Powder Mill (1/1)"), whym)
	check("[crown] near the other hall a Mill is fine", g.placement_problem(0, "powder_mill", _spot_by(g, 0, "powder_mill", b)) == "")
	# ---------------------------------------------------------------- the computer's spot finder
	var ai := AICrown.new()
	ai.game = g
	ai.team = 0
	ai.difficulty = 2
	g.add_child(ai)
	await process_frame
	if ai.has_method("_econ_spot"):
		var sp: Vector2i = ai._econ_spot("farm")
		var sp_h: Building = g.nearest_hall((Vector2(sp) + Vector2(Defs.BUILDINGS["farm"]["size"]) * 0.5) * Defs.TILE, 0) if sp.x >= 0 else null
		check("[ai] the computer's Farm spot is by the hall with room", sp.x >= 0 and sp_h == b and g.placement_problem(0, "farm", sp) == "", "%s %s" % [sp, g.placement_problem(0, "farm", sp) if sp.x >= 0 else ""])
	else:
		check("[ai] a computer for the Crown", false, "no AI")
	# ---------------------------------------------------------------- a tie, a hall going up
	var mid := (a.center() + b.center()) * 0.5
	check("[going] a point as near both halls goes to the older one", is_equal_approx(a.edge_distance(mid), b.edge_distance(mid)) == false or g.nearest_hall(mid, 0) == a,
		"%.1f / %.1f" % [a.edge_distance(mid), b.edge_distance(mid)])
	var cgo := _second_hall(g, 0, b, false)
	if cgo != null:
		check("[going] a hall going up adds nothing to the limit", g.econ_limit(0, "farm") == 4, "%d" % g.econ_limit(0, "farm"))
		check("[going] its card shows nothing laid yet", _card(g, cgo).begins_with("FARMS 0/2"), _card(g, cgo))
		g.buildings.erase(cgo)
		cgo.queue_free()
	# ---------------------------------------------------------------- the fallen hall
	if fb != null:
		var c2 := _spot_by(g, 0, "farm", b)
		if c2.x >= 0:
			_lay(g, 0, "farm", c2)
		b.dead = true          # (as Game removes a fallen building: dead, then out of the lists)
		check("[fallen] its Farms go to the main: 4 there (4/2), they keep drawing from it", g.econ_at(a, "farm") == 4 and g.soil_hall(fb) == a, "%d" % g.econ_at(a, "farm"))
		check("[fallen] the side's limit is what stands (4): no room anywhere", g.econ_limit(0, "farm") == 4 and _count(g, 0, "farm") >= g.econ_limit(0, "farm"), "%d/%d" % [_count(g, 0, "farm"), g.econ_limit(0, "farm")])
		var cf := _spot_by(g, 0, "farm", a)
		var whyf := g.placement_problem(0, "farm", cf) if cf.x >= 0 else "no spot"
		check("[fallen] no new Farm by the main while it is over its count", cf.x < 0 or whyf != "", whyf)
		check("[fallen] the card says FARMS 4/2", _card(g, a).begins_with("FARMS 4/2"), _card(g, a))
	g.queue_free()
	await process_frame

	# ================================================================ the Clockwork
	var w := U.make(root, ["clockwork", "crown"])
	await process_frame
	await process_frame
	var ta := U.hall(w, 0)
	var pk := Defs.GEAR_PRESS
	check("[clock] a Clocktower and its starting Cog Press", ta != null and _count(w, 0, pk) == 1, "%d" % _count(w, 0, pk))
	check("[clock] 2 Cog Presses and 1 Mainspring a Clocktower", Defs.econ_per_hall("clockwork", pk) == 2 and Defs.econ_per_hall("clockwork", "mainspring") == 1)
	var p2 := _spot_by(w, 0, pk, ta, true)
	if p2.x >= 0:
		_lay(w, 0, pk, p2)
	check("[clock] a 2nd press by the first Clocktower", w.econ_at(ta, pk) == 2, "%d" % w.econ_at(ta, pk))
	var tb := _second_hall(w, 0, ta)
	check("[clock] a second Clocktower", tb != null)
	if tb != null:
		check("[clock] the side's limit is 4", w.econ_limit(0, pk) == 4, "%d" % w.econ_limit(0, pk))
		var p3 := _spot_by(w, 0, pk, ta, true)
		var why3 := w.placement_problem(0, pk, p3) if p3.x >= 0 else "no spot"
		check("[clock] a 3rd press by the first Clocktower is refused", p3.x >= 0 and why3 == "This Clocktower already has its Cog Presses (2/2). Build near another Clocktower.", why3)
		var rs := GearEcon.room_spot(w, 0, pk, [ta])
		check("[clock] the computer's ring spot by the full Clocktower: none of its own",
			rs.x < 0 or w.nearest_hall((Vector2(rs) + Vector2(Defs.BUILDINGS[pk]["size"]) * 0.5) * Defs.TILE, 0) != ta, str(rs))
		var pb := _spot_by(w, 0, pk, tb, true)
		check("[clock] by the new Clocktower: allowed", pb.x >= 0 and w.placement_problem(0, pk, pb) == "", w.placement_problem(0, pk, pb) if pb.x >= 0 else "no spot")
		if pb.x >= 0:
			_lay(w, 0, pk, pb)
		check("[clock] the cards: COG PRESSES 2/2 and 1/2", _card(w, ta).begins_with("COG PRESSES 2/2") and _card(w, tb).begins_with("COG PRESSES 1/2"), _card(w, ta) + " | " + _card(w, tb))
		var ms := _spot_by(w, 0, "mainspring", ta, true)
		if ms.x >= 0:
			_lay(w, 0, "mainspring", ms)
		var ms2 := _spot_by(w, 0, "mainspring", ta, true)
		var whys := w.placement_problem(0, "mainspring", ms2) if ms2.x >= 0 else "no spot"
		check("[clock] a 2nd Mainspring by the same Clocktower is refused", ms.x >= 0 and ms2.x >= 0 and whys.begins_with("This Clocktower already has its Mainspring (1/1)"), whys)
		check("[clock] the card: MAINSPRING 1/1", _card(w, ta).contains("MAINSPRING 1/1"), _card(w, ta))
		var ms3 := _spot_by(w, 0, "mainspring", tb, true)
		check("[clock] a Mainspring by the other Clocktower: allowed", ms3.x < 0 or w.placement_problem(0, "mainspring", ms3) == "",
			w.placement_problem(0, "mainspring", ms3) if ms3.x >= 0 else "no spot (gear room)")
	w.queue_free()
	await process_frame
	_end()


func _end() -> void:
	print("RESULT %s (%d failed)" % ["PASS" if fails == 0 else "FAIL", fails])
	quit(1 if fails > 0 else 0)
