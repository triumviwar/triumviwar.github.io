extends SceneTree
## THE FINISHER (crown-finish, docs/crown_finish.md; scripts/ai_crown_finish.gd), isolated:
##   godot --headless --fixed-fps 30 --script res://tools/test_crown_finish.gd
## A Hard Crown computer against a Hard Clockwork computer on Greenhold. At 1:00 the Clockwork's army is taken away and the
## Crown is given 40 Musketeers and 3 Field Cannons at its rally spot (the finisher may start from 1:00 here: `from_t`).
## (a) the finisher starts, on "crush" (four times the enemy army it reckons, or more), with no guard (nothing came home);
## (b) its target is a Clocktower or a building that trains the Clockwork's army;
## (c) the body marches on it: within 90 s its middle is 600 px or more nearer, or the target has fallen;
## (d) none of its men is taken by the harass as a stray far from home (the bug of the first version);
## (e) when the target falls it goes for the next, and does not go home: 3 minutes on, it is still on, or the Clockwork has
##     lost a building to it.
var fails := 0


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.start({"map": "greenhold", "seed": 7, "slots": [
		{"who": "hard", "faction": "crown", "colour": 0, "side": 0, "strategy": "optimal"},
		{"who": "hard", "faction": "clockwork", "colour": 1, "side": 1, "strategy": "balanced"}]})
	await process_frame
	await process_frame
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	var ai
	for a in g.ais:
		if a.team == 0:
			ai = a
	ai.fin = ai.AICrownFinishS.new(ai)
	ai.fin.from_t = 60.0
	while g.clock < 58.0:
		await physics_frame
	for u in g.units.duplicate():
		if u.team == 1 and not u.dead and not u.is_worker() and u.has_attack():
			u.die()
	var spot: Vector2 = ai._home_spot(ai._front())
	for i in 40:
		g._add_unit("musketeer", 0, spot + Vector2(randf_range(-90, 90), randf_range(-90, 90)))
	for i in 3:
		g._add_unit("cannon", 0, spot + Vector2(-60 + 60 * i, 120))      # (40 x 60 + 3 x 170 = 2,910: over the 2,500 floor)
	g.players[0]["cap"] = maxi(int(g.players[0]["cap"]), g.supply_used(0) + 10)
	var t0 := g.clock
	while g.clock < t0 + 30.0 and not ai.fin.active and not g.over:
		await physics_frame
	check(ai.fin.active, "the finisher starts with 40 Musketeers and 3 guns against no enemy army (%.0f s)" % (g.clock - t0))
	check(ai.fin.why == "crush", "on \"crush\" (%s)" % ai.fin.why)
	check(ai.fin.men.size() >= 40, "it takes the army (%d men)" % ai.fin.men.size())
	await physics_frame
	var tg = ai.fin.target
	var ok_t: bool = tg != null and tg is Building and (tg.kind == g.faction_hall(1) or not (tg.d.get("trains", []) as Array).is_empty())
	check(ok_t, "its target is a Clocktower or a building that trains the army (%s)" % (str(tg.kind) if tg != null else "none"))
	var mid0: Vector2 = ai.fin._middle(ai.fin.men.keys()) if not ai.fin.men.is_empty() else Vector2.ZERO
	var d0: float = mid0.distance_to(ai.fin._pos(tg)) if tg != null else 0.0
	var t1 := g.clock
	var closer := false
	var strays := 0
	while g.clock < t1 + 90.0 and not g.over:
		await physics_frame
		if ai.harass != null:
			for u in ai.fin.men.keys():
				if ai.harass.has(u):
					strays += 1
		if not ai.fin._alive(tg):
			closer = true
			break
		if not ai.fin.men.is_empty() and ai.fin._middle(ai.fin.men.keys()).distance_to(ai.fin._pos(tg)) < d0 - 600.0:
			closer = true
			break
	check(closer, "the body marches on it (%.0f px off at the start)" % d0)
	check(strays == 0, "no man of the finisher's is taken by the harass (%d)" % strays)
	var lost0 := int(g.stats[0]["value_killed"])
	var t2 := g.clock
	while g.clock < t2 + 180.0 and ai.fin.active and not g.over:
		await physics_frame
	check(ai.fin.active or ai.fin.broke > 0 or g.over, "3 minutes on it is still on, or it broke buildings (on %s, broke %d, killed %d)" % [
		str(ai.fin.active), ai.fin.broke, int(g.stats[0]["value_killed"]) - lost0])
	print("ALL PASS" if fails == 0 else "%d FAILED" % fails)
	quit(0 if fails == 0 else 1)
