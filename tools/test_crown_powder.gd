extends SceneTree
## THE CROWN'S POWDER STUDY (crown-powder-study, docs/crown_powder_study.md; scripts/crown_powder.gd): the four options, each a
## match switch, OFF by default:
##   off: the saltpetre 1,320, the floor 15%, no Nitre Beds on the build list, no BUY POWDER;
##   A salt2500: a new Town Hall holds 2,500; B floor35: a Mill on spent saltpetre grinds at 35%;
##   C nitre: the Nitre Beds on the list, by a Farm or Horse Breeder, one per Town Hall, 3 gold a powder at 40 a minute,
##     resting at 400 banked, hungry with no Farm near;
##   D buy: 50 powder for 150 gold, then a 30 s wait.
##   godot --headless --fixed-fps 30 --script res://tools/test_crown_powder.gd
const U := preload("res://tools/gear_test_util.gd")
var fails := 0


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-74s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _spot(g: Game, t: int, kind: String, around: Building, r := 14) -> Vector2i:
	var best := Vector2i(-1, -1)
	var bd := INF
	for y in range(around.cell.y - r, around.cell.y + r + 1):
		for x in range(around.cell.x - r, around.cell.x + r + 1):
			var c := Vector2i(x, y)
			if g.in_map(c) and g.placement_problem(t, kind, c) == "" and g.margin_free(c, Defs.BUILDINGS[kind]["size"]):
				var d := Vector2(c - around.cell).length()
				if d < bd:
					bd = d
					best = c
	return best


func _run() -> void:
	# ---------------------------------------------------------------- off: as before
	CrownPowder.set_opts("")
	check("off: a Town Hall's saltpetre 1,320", CrownPowder.lode_full("town_hall") == 1320.0)
	check("off: the Clocktower's brass unchanged", CrownPowder.lode_full("clocktower") == 9000.0)
	check("off: the Mill's floor 15%", CrownPowder.powder_floor() == Defs.POWDER_FLOOR and Defs.POWDER_FLOOR == 0.15)
	check("off: no Nitre Beds on the Crown's list", not Defs.build_list("crown").has(CrownPowder.BEDS))

	var g: Game = U.make(root, ["crown", "clockwork"])
	var th: Building = U.hall(g, 0)
	check("off: BUY POWDER refused", CrownPowder.buy(g, 0) != "")

	# ---------------------------------------------------------------- A and B
	CrownPowder.set_opts("salt2500+floor35")
	check("salt2500: a Town Hall holds 2,500", th.lode_full() == 2500.0 and CrownPowder.lode_full("clocktower") == 9000.0)
	check("floor35: the floor is 35%", CrownPowder.powder_floor() == 0.35)
	var mc := _spot(g, 0, "powder_mill", th)
	var mill: Building = g._add_building("powder_mill", 0, mc, true) if mc.x >= 0 else null
	check("a Powder Mill stands", mill != null)
	if mill != null:
		th.lode = 0.0
		check("floor35: spent saltpetre grinds at 35%", absf(g.draw_lode(mill, 10.0) - 3.5) < 0.001)
		th.lode = 1250.0
		check("salt2500: half the saltpetre grinds at the half share", absf(g.draw_lode(mill, 10.0) - 10.0 * Defs.second_share(0.5, 0.35)) < 0.01)
	CrownPowder.set_opts("")
	th.lode = 1320.0
	if mill != null:
		g.buildings.erase(mill)
		mill.dead = true
	for u in g.workers(0).duplicate():
		u.auto_work = false
		u.cmd_stop()
		g.units.erase(u)
		u.queue_free()

	# ---------------------------------------------------------------- C: Nitre Beds
	CrownPowder.set_opts("nitre")
	check("nitre: the Nitre Beds on the Crown's list after the Mill", Defs.build_list("crown").find(CrownPowder.BEDS) == Defs.build_list("crown").find("powder_mill") + 1)
	check("nitre: not on the Clockwork's", not Defs.build_list("clockwork").has(CrownPowder.BEDS))
	for b in g.buildings.duplicate():
		if b.team == 0 and (b.kind == "farm" or b.kind == "horse_breeder"):
			g.buildings.erase(b)
			b.queue_free()
	var bad := _spot(g, 0, "cottage", th)
	check("nitre: refused with no Farm or Horse Breeder near", bad.x >= 0 and CrownPowder.place_problem(g, 0, bad).contains("Farm"), CrownPowder.place_problem(g, 0, bad))
	var fc := _spot(g, 0, "farm", th)
	var farm: Building = g._add_building("farm", 0, fc, true) if fc.x >= 0 else null
	check("a Farm stands", farm != null)
	var bc := _spot(g, 0, CrownPowder.BEDS, farm if farm else th, 10)
	check("nitre: a spot by the Farm", bc.x >= 0)
	var beds: Building = g._add_building(CrownPowder.BEDS, 0, bc, true) if bc.x >= 0 else null
	if beds != null:
		var bc2 := _spot(g, 0, "cottage", th)
		check("nitre: one per Town Hall", CrownPowder.place_problem(g, 0, bc2).contains("already"), CrownPowder.place_problem(g, 0, bc2))
		g.players[0]["gold"] = 5000
		g.players[0]["res2"] = 0.0
		U.step(g, 60.0)
		var made := float(g.players[0]["res2"])
		check("nitre: about 40 powder a minute", made >= 37.0 and made <= 41.0, "%.0f" % made)
		check("nitre: 3 gold a powder", int(g.stats[0].get("nitre_gold", 0)) == 3 * int(g.stats[0].get("nitre_powder", 0)) and 5000 - int(g.players[0]["gold"]) >= 3 * int(made) - 10,
			"gold %d, nitre %s" % [5000 - int(g.players[0]["gold"]), str(g.stats[0].get("nitre_powder"))])
		g.players[0]["res2"] = 400.0
		U.step(g, 10.0)
		check("nitre: rests while 400 powder are banked", float(g.players[0]["res2"]) == 400.0)
		g.players[0]["res2"] = 0.0
		if farm != null:
			g.buildings.erase(farm)
			farm.dead = true
		U.step(g, 10.0)
		check("nitre: hungry with no Farm or Horse Breeder near", float(g.players[0]["res2"]) <= 1.0, "%.0f" % float(g.players[0]["res2"]))
	CrownPowder.set_opts("")

	# ---------------------------------------------------------------- D: BUY POWDER
	CrownPowder.set_opts("buy")
	g.players[0]["gold"] = 500
	g.players[0]["res2"] = 0.0
	check("buy: 50 powder for 150 gold", CrownPowder.buy(g, 0) == "" and float(g.players[0]["res2"]) == 50.0 and int(g.players[0]["gold"]) == 350)
	check("buy: then a wait", CrownPowder.buy(g, 0).contains("again"), CrownPowder.buy(g, 0))
	U.step(g, CrownPowder.BUY_WAIT + 1.0)
	check("buy: again after the wait", CrownPowder.buy(g, 0) == "" and float(g.players[0]["res2"]) >= 100.0)
	g.players[0]["gold"] = 100
	U.step(g, CrownPowder.BUY_WAIT + 1.0)
	check("buy: not without the gold", CrownPowder.buy(g, 0).contains("gold"))
	check("buy: not for the Clockwork", CrownPowder.buy(g, 1) != "")
	CrownPowder.set_opts("")

	print("RESULT %s (%d failed)" % ["PASS" if fails == 0 else "FAIL", fails])
	quit(1 if fails > 0 else 0)
