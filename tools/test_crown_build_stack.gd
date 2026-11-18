extends SceneTree
## LABOURERS STACKED ON A SITE (crown-build-stack, docs/crown_build_stack.md; scripts/ai_crown_stack.gd AICrownStack).
##   [stack]  a Crown computer's Farm site with one builder gets helpers from the labourers close by (idle ones first),
##            up to its want; the Farm stands in about a third of the time one labourer takes
##   [off]    with the switch off nobody joins, and the Farm takes its full time
##   [far]    a working labourer too far away is not pulled (his walk would cost more than his share of the work)
##   [unsafe] a site in danger gets no helpers
##   [ghost]  a site not begun yet (its builder still on the way) gets none: helpers on its footprint would keep it a ghost
##   [brood]  THE HALL STEP KEEPS ITS GOLD never plays against the Brood
##   godot --headless --fixed-fps 30 --script res://tools/test_crown_build_stack.gd
const U := preload("res://tools/gear_test_util.gd")
var fails := 0


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-82s %s %s" % [name, "ok" if ok else "FAIL", detail])
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


## A free Farm spot near the hall (not its own farm's).
func _farm_spot(g: Game, h: Building) -> Vector2i:
	return g.find_spot(0, "farm", h, 4, 14, "near")


## Lays a Farm with one builder and puts n labourers idle `dist` px from it; returns [site, helpers]
func _setup(g: Game, h: Building, n: int, dist: float) -> Array:
	var c := _farm_spot(g, h)
	var labs: Array = g.workers(0)
	var first: Unit = labs[0]
	var site: Building = g.place_building(0, "farm", c, [first])
	var mid := site.center()
	var helpers: Array = []
	for i in n:
		var u: Unit = g._add_unit("labourer", 0, mid + Vector2(dist, 0).rotated(i * 0.9))
		u.cmd_stop()
		helpers.append(u)
	first.position = mid + Vector2(0, 70)
	return [site, helpers]


func _builders(g: Game, b: Building) -> int:
	return g.workers(0).filter(func(u: Unit) -> bool: return u.order == "build" and u.order_target == b).size()


func _time_to_build(g: Game, b: Building) -> float:
	var t := 0.0
	while not b.built and t < 90.0:
		U.step(g, 0.5)
		t += 0.5
	return t


func _game() -> Game:
	var g := U.make(root, ["crown", "clockwork"], "greenhold")
	g.players[0]["gold"] = 2000
	return g


func _run() -> void:
	# ---------------------------------------------------------------- [stack]
	var g := _game()
	await process_frame
	await process_frame
	var ai := _ai(g, 0)
	await process_frame
	var h := U.hall(g, 0)
	var s: Array = _setup(g, h, 4, 120.0)
	var site: Building = s[0]
	U.step(g, 0.2)
	for u in s[1]:
		u.cmd_stop()        # (idle: no post to go back to, they cost nothing at the site)
	var stk := AICrownStack.new(ai)
	stk.tick()
	var n := _builders(g, site)
	var w: Array = stk.want(site)
	check("[stack] the Farm site gets helpers up to its want (%d)" % int(w[0]), n >= 3 and n <= int(w[0]), "%d builders, sent %d (idle %d)" % [n, stk.sent, stk.sent_idle])
	var t_on := _time_to_build(g, site)
	check("[stack] it stands well under a lone labourer's 25 s", site.built and t_on < 17.0, "%.1f s" % t_on)
	stk.tick()
	check("[stack] the report lists it", stk.built.any(func(e: Array) -> bool: return e[0] == "farm"), str(stk.built))
	g.queue_free()
	await process_frame
	# ---------------------------------------------------------------- [off]
	g = _game()
	await process_frame
	await process_frame
	ai = _ai(g, 0)
	await process_frame
	h = U.hall(g, 0)
	s = _setup(g, h, 4, 120.0)
	site = s[0]
	U.step(g, 0.2)
	stk = AICrownStack.new(ai)
	stk.on_switch = false
	stk.tick()
	check("[off] with the switch off nobody joins", _builders(g, site) == 1 and stk.sent == 0, "%d" % _builders(g, site))
	var t_off := _time_to_build(g, site)
	check("[off] the Farm takes about a lone labourer's time", site.built and t_off > 22.0, "%.1f s (stacked %.1f s)" % [t_off, t_on])
	g.queue_free()
	await process_frame
	# ---------------------------------------------------------------- [far]
	g = _game()
	await process_frame
	await process_frame
	ai = _ai(g, 0)
	await process_frame
	h = U.hall(g, 0)
	s = _setup(g, h, 0, 0.0)
	site = s[0]
	var far: Unit = g._add_unit("labourer", 0, site.center() + Vector2(1400, 0))
	for u in g.workers(0):
		if u != far and u.order != "build":
			u.position = site.center() + Vector2(1400, 40)
	# a working labourer far off (gathering): his 19 s walk is more than his share of a Farm's 25 s
	var farm0: Building = null
	for b in g.buildings:
		if b.team == 0 and b.kind == "farm" and b.built:
			farm0 = b
	if farm0 != null:
		for u in g.workers(0):
			if u.order != "build":
				u.cmd_gather(farm0)
	U.step(g, 0.2)
	stk = AICrownStack.new(ai)
	stk.tick()
	check("[far] no working labourer walks across the map to help", _builders(g, site) == 1, "%d builders" % _builders(g, site))
	g.queue_free()
	await process_frame
	# ---------------------------------------------------------------- [unsafe]
	g = _game()
	await process_frame
	await process_frame
	ai = _ai(g, 0)
	await process_frame
	h = U.hall(g, 0)
	s = _setup(g, h, 4, 120.0)
	site = s[0]
	U.step(g, 0.2)
	ai._danger_pts.append([site.center(), g.clock])
	stk = AICrownStack.new(ai)
	stk.tick()
	check("[unsafe] a site in danger gets no helpers", _builders(g, site) == 1, "%d" % _builders(g, site))
	g.queue_free()
	await process_frame
	# ---------------------------------------------------------------- [ghost]
	g = _game()
	await process_frame
	await process_frame
	ai = _ai(g, 0)
	await process_frame
	h = U.hall(g, 0)
	s = _setup(g, h, 4, 120.0)
	site = s[0]
	for u in g.workers(0):
		if u.order == "build" and u.order_target == site:
			u.position = site.center() + Vector2(900, 0)       # (its builder far off: the site stays a ghost)
	site.ghost = true
	site.progress = 0.0
	for u in s[1]:
		u.cmd_stop()
	stk = AICrownStack.new(ai)
	stk.tick()
	check("[ghost] a site not begun yet gets no helpers", _builders(g, site) == 1 and stk.sent == 0, "%d builders, ghost %s" % [_builders(g, site), site.ghost])
	g.queue_free()
	await process_frame
	# ---------------------------------------------------------------- [brood]
	g = U.make(root, ["crown", "brood"], "greenhold")
	await process_frame
	await process_frame
	ai = _ai(g, 0)
	await process_frame
	stk = AICrownStack.new(ai)
	check("[brood] the hall step keeps no gold against the Brood", not stk.hall_keeps())
	g.queue_free()
	await process_frame
	print("FAILS %d" % fails)
	quit(1 if fails > 0 else 0)
