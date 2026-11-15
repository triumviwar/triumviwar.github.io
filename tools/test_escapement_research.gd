extends SceneTree
## THE ESCAPEMENT'S THREE RESEARCHES (escapement-research, 0.38.19, docs/escapement_research.md; the owner 2026-11-15
## 20:34): SHIELD WALL moved from the Light Works to the Escapement, the Netter's reach 180 -> 150 and the new LONG CHAIN
## (+90: 240) at the Escapement; the Field Cannon (430) still the longest reach of any unit; the drill on Netters in the
## field and new ones; the Netter's sight still covers 240; the range chip names the bonus; a save keeps LONG CHAIN and pays
## back a SHIELD WALL queued at a Light Works (an old save); the Clockwork computer buys SHIELD WALL at the Escapement and
## LONG CHAIN with 2 Netters.
##   godot --headless --fixed-fps 30 --script res://tools/test_escapement_research.gd
const U := preload("res://tools/gear_test_util.gd")
var fails := 0


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-76s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	# ---- the numbers
	var sw: Dictionary = Defs.RESEARCH["shield_wall"]
	var lc: Dictionary = Defs.RESEARCH.get("long_chain", {})
	check("SHIELD WALL is researched at the Escapement", String(sw["at"]) == Defs.CW_TECH, String(sw["at"]))
	check("SHIELD WALL keeps its price and time (100 cogs + 50 Tension, 45 s)", int(sw["cost"]) == 100 and Defs.tension_cost(sw) == 50 and is_equal_approx(float(sw["time"]), 45.0))
	var at_esc: Array = []
	var at_works: Array = []
	for k in Defs.RESEARCH:
		if String(Defs.RESEARCH[k]["at"]) == Defs.CW_TECH:
			at_esc.append(k)
		if String(Defs.RESEARCH[k]["at"]) == Defs.CW_WORKS:
			at_works.append(k)
	at_esc.sort()
	check("the Escapement holds 3 researches: HIGH LEAP, LONG CHAIN, SHIELD WALL", at_esc == ["high_leap", "long_chain", "shield_wall"], str(at_esc))
	check("the Light Works researches nothing now", at_works.is_empty(), str(at_works))
	check("LONG CHAIN exists, a drill on Netters, costs cogs and Tension", not lc.is_empty() and bool(lc.get("drill", false)) and Array(lc.get("kinds", [])) == [Defs.NETTER] \
			and int(lc.get("cost", 0)) > 0 and Defs.tension_cost(lc) > 0)
	var base := float(Defs.UNITS[Defs.NETTER]["range"])
	var up := base + float(lc.get("range", 0.0))
	check("the Netter's reach is 150 (was 180)", is_equal_approx(base, 150.0), "%.0f" % base)
	check("with LONG CHAIN it is 240: longer than the old 180", is_equal_approx(up, 240.0) and up > 180.0, "%.0f" % up)
	var cannon := float(Defs.UNITS["cannon"]["range"])
	var longest := ""
	var second := 0.0
	for k in Defs.UNITS:
		var r := float(Defs.UNITS[k].get("range", 0.0))
		if k == Defs.NETTER:
			r = up
		if k != "cannon" and r > second:
			second = r
			longest = k
	check("the Field Cannon (430) is still the longest reach of any unit (next: %s %.0f)" % [longest, second], cannon >= 430.0 and second < cannon, "%.0f" % cannon)
	check("LONG CHAIN's 240 is far under the cannon's 430", up < cannon - 100.0)
	check("the Netter's sight (9 tiles) still covers 240", float(Defs.UNITS[Defs.NETTER]["sight"]) * Defs.TILE >= up, "%d px" % (int(Defs.UNITS[Defs.NETTER]["sight"]) * Defs.TILE))
	# ---- in a game: the Light Works refuses SHIELD WALL, the Escapement makes both
	var g := U.make(root)
	await process_frame
	await process_frame
	var hall := U.hall(g, 0)
	g.players[0]["gold"] = 50000
	g.players[0]["tension"] = 5000.0
	var works := U.put(g, 0, Defs.CW_WORKS, hall.cell)
	if works != null:
		var w := g.research_problem(works, "shield_wall")
		check("a Light Works refuses SHIELD WALL", w != "", w)
	var esc := U.put(g, 0, Defs.CW_TECH, hall.cell)
	check("an Escapement links", esc != null and g.gear_net.is_linked(esc))
	if esc == null:
		_end()
		return
	if g.gear_net.spring_for(esc) == null:
		var w0 := g.research_problem(esc, "long_chain")
		check("an Escapement with no Mainspring in its network refuses LONG CHAIN (the Tension rule)", w0 != "", w0)
		_spring_beside(g, esc)
		U.step(g, 0.6)
	var spot := hall.center() + Vector2(0, 300)
	var old: Unit = g._add_unit(Defs.NETTER, 0, _open(g, spot))
	old.cmd_hold()
	check("a Netter in the field reaches 150", is_equal_approx(old._range(), 150.0), "%.0f" % old._range())
	check("the range chip shows 150 with no bonus line", _chip(old).find("Long Chain") < 0, _chip(old))
	var why := g.start_research(esc, "long_chain")
	check("the Escapement starts LONG CHAIN", why == "", why)
	var why2 := g.start_research(esc, "shield_wall")
	check("the Escapement queues SHIELD WALL behind it", why2 == "" and g.researching(0, "shield_wall"), why2)
	U.step(g, float(lc["time"]) + 1.0)
	check("after its time LONG CHAIN is researched", g.has_tech(0, "long_chain"))
	check("LONG CHAIN: the Netter in the field reaches 240 at once", is_equal_approx(old._range(), 240.0), "%.0f" % old._range())
	var fresh: Unit = g._add_unit(Defs.NETTER, 0, _open(g, spot + Vector2(80, 0)))
	check("LONG CHAIN: a new Netter comes out reaching 240", is_equal_approx(fresh._range(), 240.0), "%.0f" % fresh._range())
	check("Defs stays 150 (the drill is on the units' own copy)", is_equal_approx(float(Defs.UNITS[Defs.NETTER]["range"]), 150.0))
	check("the range chip names the bonus", _chip(fresh).find("Long Chain") >= 0, _chip(fresh))
	check("its stand-in icon is drawn (CwArt)", CwArt.icon("research_long_chain") != null)
	U.step(g, float(sw["time"]) + 1.0)
	check("SHIELD WALL is researched at the Escapement", g.has_tech(0, "shield_wall"))
	var cs: Unit = g._add_unit("clock_soldier", 0, _open(g, spot + Vector2(-80, 0)))
	check("SHIELD WALL still gives a Clock Soldier 85 health and the stance", is_equal_approx(cs.max_hp, 85.0) and ShieldWall.problem(cs) == "", "%.0f" % cs.max_hp)
	# ---- a save: LONG CHAIN kept; SHIELD WALL queued at a Light Works (an old save) paid back
	g.demo = false
	var d: Dictionary = JSON.parse_string(JSON.stringify(SaveGame.capture(g, {})))      # (a save goes through JSON)
	g.demo = true
	var gold0 := int(d["players"][0]["gold"])
	var ten0 := float(d["players"][0].get("tension", 0.0))
	(d["players"][0]["tech"] as Dictionary).erase("shield_wall")
	var queued := false
	for bd in d["buildings"]:
		if String(bd["k"]) == Defs.CW_WORKS and int(bd["t"]) == 0:
			bd["queue"] = ["@shield_wall"]
			bd["prod_t"] = 20.0
			queued = true
			break
	check("(the save has a Light Works to queue the old research in)", queued)
	SaveGame.restore(g, d)
	await process_frame
	check("loaded: LONG CHAIN is still researched", g.has_tech(0, "long_chain"))
	var nets := g.units.filter(func(u: Unit) -> bool: return u.team == 0 and u.kind == Defs.NETTER)
	check("loaded: the Netters reach 240", not nets.is_empty() and nets.all(func(u: Unit) -> bool: return is_equal_approx(u._range(), 240.0)), str(nets.map(func(u: Unit) -> float: return u._range())))
	check("loaded: SHIELD WALL queued at a Light Works is gone from its queue", not g.researching(0, "shield_wall"))
	check("loaded: and paid back in full (100 cogs + 50 Tension)", int(g.players[0]["gold"]) == gold0 + 100 and is_equal_approx(g.tension(0), ten0 + 50.0),
			"%d -> %d, %.0f -> %.0f" % [gold0, int(g.players[0]["gold"]), ten0, g.tension(0)])
	var lw: Array = g.buildings.filter(func(b: Building) -> bool: return b.team == 0 and b.kind == Defs.CW_WORKS)
	check("loaded: the Light Works' clock is not carried to the next entry", lw.is_empty() or is_zero_approx(lw[0].prod_t), "%.1f" % (lw[0].prod_t if not lw.is_empty() else 0.0))
	# ---- the computer
	var g2 := g
	g2.players[0]["tech"].erase("long_chain")
	g2.players[0]["tech"].erase("shield_wall")
	for u in g2.units.filter(func(u: Unit) -> bool: return u.team == 0 and u.kind == Defs.NETTER):
		g2.apply_drills(u)
	var esc2: Array = g2.buildings.filter(func(b: Building) -> bool: return b.team == 0 and b.kind == Defs.CW_TECH)
	check("(the loaded Escapement works)", g2.has_working(0, Defs.CW_TECH))
	var ai := AI.new()
	ai.game = g2
	ai.team = 0
	ai.difficulty = 2
	ai.process_mode = Node.PROCESS_MODE_DISABLED
	g2.add_child(ai)
	for u in g2.units.filter(func(u: Unit) -> bool: return u.team == 0 and u.kind == Defs.NETTER):
		g2.units.erase(u)
		u.queue_free()
	g2._add_unit(Defs.NETTER, 0, _open(g2, spot))
	ai._chain_research()
	check("the computer does not buy LONG CHAIN for 1 Netter", not g2.researching(0, "long_chain"))
	g2._add_unit(Defs.NETTER, 0, _open(g2, spot + Vector2(60, 0)))
	ai._chain_research()
	check("the computer buys LONG CHAIN at the Escapement once it has 2 Netters", g2.researching(0, "long_chain") \
			and esc2.any(func(b: Building) -> bool: return b.queue.has("@long_chain")))
	for i in 5:
		g2._add_unit("clock_soldier", 0, _open(g2, spot + Vector2(-60, (i - 2) * 26.0)))
	for i in 4:
		var m: Unit = g2._add_unit("musketeer", 1, _open(g2, spot + Vector2(150, (i - 1.5) * 28.0)))
		m.auto_work = false
		m.cmd_hold()
	g2.explored.fill(1)
	U.step(g2, 0.5)
	ai._shield_research()
	check("the computer researches SHIELD WALL at the Escapement once it meets shooters", g2.researching(0, "shield_wall") \
			and esc2.any(func(b: Building) -> bool: return b.queue.has("@shield_wall")))
	check("... and never at a Light Works", not lw.any(func(b: Building) -> bool: return is_instance_valid(b) and b.queue.has("@shield_wall")))
	_end()


func _end() -> void:
	print("ALL PASS" if fails == 0 else "%d FAILED" % fails)
	quit(1 if fails > 0 else 0)


func _chip(u: Unit) -> String:
	var info: Dictionary = UnitStats.of_unit(u)
	for c in info.get("chips", []):
		if String(c.get("title", "")) == "Range":
			return String(c.get("stats", "")) + " | " + String(c.get("body", ""))
	return ""


func _spring_beside(g: Game, b: Building) -> Building:
	for deg in [0.0, 90.0, 180.0, -90.0, 45.0, 135.0, -45.0, -135.0]:
		var c := GearNet.ring_spot(g, 0, "mainspring", b, deg)
		if c.x >= 0:
			var m := g._add_building("mainspring", 0, c, true)
			g.gear_net.solve()
			return m
	return null


func _open(g: Game, p: Vector2) -> Vector2:
	return g.cell_center(g.nearest_free(g.cell_of(g.on_map(p)), 10))
