extends SceneTree
## THE MILLS' FULL CREW (crown-mill-crew, docs/crown_mill_crew.md; scripts/ai_crown_mill_crew.gd AICrownMillCrew):
##   [gate]    on for the Crown computer (Normal and up) against the factions in MATCHUPS; `millcrew:off` turns it off
##   [early]   nothing before 5:00
##   [calm]    off while the bank holds what the army needs
##   [low]     no powder and musket men dry: on; the Mills' crew it holds is a full 6 a Mill, at most SHARE of the labourers
##   [fill]    the nearest Mill to 6, then the next (the shared mover filled only the first), at most MOVE_A_THINK a think
##   [farms]   the hands come from the Farms; one carrying a harvest stays
##   [release] the bank refilled: off after HOLD, then the hands go back one at a time
##   godot --headless --fixed-fps 30 --script res://tools/test_crown_mill_crew.gd
const U := preload("res://tools/gear_test_util.gd")
var fails := 0


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-72s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _ai(g: Game, t: int) -> AICrown:
	var ai := AICrown.new()
	ai.game = g
	ai.team = t
	ai.difficulty = 2
	g.add_child(ai)
	ai.set_process(false)
	ai.set_physics_process(false)
	return ai


func _spot(g: Game, t: int, kind: String, around: Building, r := 16, skip := []) -> Vector2i:
	var best := Vector2i(-1, -1)
	var bd := INF
	for y in range(around.cell.y - r, around.cell.y + r + 1):
		for x in range(around.cell.x - r, around.cell.x + r + 1):
			var c := Vector2i(x, y)
			if skip.has(c):
				continue
			if g.in_map(c) and g.placement_problem(t, kind, c) == "" and g.margin_free(c, Defs.BUILDINGS[kind]["size"]):
				var d := Vector2(c - around.cell).length()
				if d < bd:
					bd = d
					best = c
	return best


func _crew(mills: Array) -> Array:
	return mills.map(func(m: Building) -> int: return m.crew.size())


func _run() -> void:
	var g := U.make(root, ["crown", "clockwork"], "greenhold")
	U.step(g, 0.5)
	var ai := _ai(g, 0)
	var mc := ai.mill_crew()
	check("[gate] on against the Clockwork", mc.enabled())
	var th := U.hall(g, 0)
	# two Farms and two Mills by the hall, sixteen labourers on the Farms
	var farms: Array = []
	for i in 2:
		var c := _spot(g, 0, "farm", th)
		farms.append(g._add_building("farm", 0, c, true))
	var mills: Array = []
	for i in 2:
		var c := _spot(g, 0, "powder_mill", th)
		mills.append(g._add_building("powder_mill", 0, c, true))
	check("two Farms and two Mills stand", farms.all(func(b) -> bool: return b != null) and mills.all(func(b) -> bool: return b != null))
	for w in g.workers(0).duplicate():
		g.units.erase(w)
		w.queue_free()
	for i in 16:
		var u: Unit = g._add_unit("labourer", 0, th.center() + Vector2(40 + (i % 4) * 12, 40 + (i / 4) * 12))
		u.cmd_gather(farms[i % 2])
	# ten Musketeers with no shot
	var men: Array = []
	for i in 10:
		var m: Unit = g._add_unit("musketeer", 0, th.center() + Vector2(-80 - (i % 5) * 14, 60 + (i / 5) * 14))
		m.set_ammo(0)
		men.append(m)
	U.step(g, 6.0)
	g.players[0]["res2"] = 0.0
	g.players[0]["gold"] = 500

	# [early]
	g.clock = 200.0
	mc.tick()
	check("[early] not before 5:00", not mc.active and mc.floor_crew() == 0)

	# [calm]
	g.clock = 400.0
	g.players[0]["res2"] = 900.0
	mc.tick()
	check("[calm] a full bank: off", not mc.active)

	# [low]
	g.players[0]["res2"] = 0.0
	mc.tick()
	check("[low] no powder, ten musket men dry: on", mc.active, "dry %d, need %.0f" % [mc._dry, mc._need])
	var labs := g.workers(0).size()
	check("[low] the crew it holds: up to 6 a Mill, at most the share of the labourers",
		mc.floor_crew() <= 12 and mc.floor_crew() == mini(12, maxi(0, int(labs * AICrownMillCrew.SHARE_DRY))), "floor %d of %d labourers" % [mc.floor_crew(), labs])
	check("[low] the Crown's Mill cap follows it", ai._mill_cap() >= mc.floor_crew())

	# [fill]
	var before: Array = _crew(mills)
	var farm_before: int = farms[0].crew.size() + farms[1].crew.size()
	var carrier: Unit = null
	for u in g.workers(0):
		if u.home_mine == farms[0]:
			u.carrying = 5
			carrier = u
			break
	ai._balance_mill(g.workers(0))
	var after_one: int = _crew(mills)[0] + _crew(mills)[1] - before[0] - before[1]
	check("[fill] at most %d hands a think" % AICrownMillCrew.MOVE_A_THINK, after_one > 0 and after_one <= AICrownMillCrew.MOVE_A_THINK, "%d" % after_one)
	for k in 6:
		ai._balance_mill(g.workers(0))
	var c := _crew(mills)
	check("[fill] the nearest Mill filled to 6, then the second gets hands", maxi(c[0], c[1]) == 6 and mini(c[0], c[1]) >= 1, str(c))
	check("[fill] up to the crew it holds", c[0] + c[1] == mc.floor_crew(), "%s, floor %d" % [str(c), mc.floor_crew()])
	check("[farms] the hands came from the Farms", farms[0].crew.size() + farms[1].crew.size() == farm_before - (c[0] + c[1] - before[0] - before[1]))
	check("[farms] the one carrying a harvest stayed", carrier != null and carrier.home_mine == farms[0])

	# [release]
	g.players[0]["res2"] = 2000.0
	g.clock = 410.0
	mc.tick()
	check("[release] not before HOLD", mc.active)
	g.clock = 400.0 + AICrownMillCrew.HOLD + 1.0
	mc.tick()
	check("[release] the bank refilled: off", not mc.active)
	var held := mc.floor_crew()
	g.clock += AICrownMillCrew.STEP_BACK + 0.1
	mc.tick()
	check("[release] the hands go back one at a time", mc.floor_crew() == held - 1, "%d -> %d" % [held, mc.floor_crew()])
	g.queue_free()

	for foe in ["brood", "crown"]:
		var g2 := U.make(root, ["crown", foe], "greenhold")
		U.step(g2, 0.5)
		var a2 := _ai(g2, 0)
		check("[gate] against the %s: %s" % [foe, "on" if AICrownMillCrew.MATCHUPS.has(foe) else "off"], a2.mill_crew().enabled() == AICrownMillCrew.MATCHUPS.has(foe))
		g2.queue_free()

	print("RESULT %s (%d failed)" % ["PASS" if fails == 0 else "FAIL", fails])
	quit(1 if fails > 0 else 0)
