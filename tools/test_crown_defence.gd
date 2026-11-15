extends SceneTree
## DEFENDING AGAINST A PUSH (crown-coach-defence, scripts/ai_crown_defence.gd, docs/crown-coach-defence.md):
##   godot --headless --fixed-fps 30 --script res://tools/test_crown_defence.gd
## A Hard Crown computer (Balanced) on Greenhold against a Clockwork that stands still (its computer off; the test moves
## its soldiers). Then:
##  [alert]   8 Clock Soldiers on our half of the map, 30 tiles out, walking at our base: within ALERT_BY s the Crown's
##            alert is on (soldiers before labourers: wants_soldiers; no balloon party forms: party_wait)
##  [walk]    the owner's game: 4 Musketeers out below the main (by a Cottage at the natural's site) when 8 Clock Soldiers
##            come between them and the ramp: none walks past the enemy on a plain move (no Musketeer dies on a "move"
##            order), they fight or step round (steers + fights > 0)
##  [muster]  12 Clock Soldiers at a Farm on the main, the army at home (5 Musketeers, spread) worth less than MUSTER_K
##            times them: it musters at the hall (mustering), no Musketeer is sent to the Farm alone (none farther than
##            FARM_GAP from the muster point while the enemy stays at the Farm), and when the Clock Soldiers come at the
##            hall the line fights as one (engages > 0)
##  [off]     `-- defence:off`: the module does nothing (run the test with it to see [walk] and [muster] fail)
const T := 32.0
const ALERT_BY := 12.0
const FARM_GAP := 260.0
var fails := 0
var main: Node
var g: Game
var ai


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func wait(s: float) -> void:
	var until := g.clock + s
	while g.clock < until:
		await physics_frame


func _free(p: Vector2) -> Vector2:
	var c := g.cell_of(p)
	for r in 10:
		for y in range(c.y - r, c.y + r + 1):
			for x in range(c.x - r, c.x + r + 1):
				var m := Vector2i(x, y)
				if g.in_map(m) and g._walkable(m):
					return (Vector2(m) + Vector2(0.5, 0.5)) * T
	return p


func _clear_foes() -> void:
	for u in g.army(1):
		if not u.dead:
			u.die()


func _run() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	seed(7)
	main.start({"map": "greenhold", "seed": 7, "slots": [
		{"who": "hard", "faction": "crown", "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "hard", "faction": "clockwork", "colour": 1, "side": 1, "strategy": "economy"}]})
	await process_frame
	await process_frame
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	for a in g.ais:
		if a.team == 1:
			a.process_mode = Node.PROCESS_MODE_DISABLED      # (the Clockwork stands still)
		else:
			ai = a
	await wait(2.0)
	var dfn: AICrownDefence = ai.defence()
	var ch = ai.ch
	check(dfn.active(), "(set-up) the defence is on (run without `defence:off`)")
	var hall: Vector2 = g.center_of_team(0)
	var foe_hall: Vector2 = g.center_of_team(1)
	# [alert]
	var dir := (foe_hall - hall).normalized()
	var at := _free(hall + dir * 30.0 * T)
	var cs: Array = []
	for i in 8:
		var u: Unit = g._add_unit("clock_soldier", 1, _free(at + Vector2(float(i % 4) * 22.0, float(i / 4) * 22.0)))
		u.cmd_move(hall, false)
		cs.append(u)
	# (a rider of ours sees them: the computer only knows what it sees)
	var eye: Unit = g._add_unit("cuirassier", 0, _free(hall + dir * 22.0 * T))
	eye.cmd_hold()
	var t0 := g.clock
	var seen_at := -1.0
	while g.clock - t0 < ALERT_BY:
		await wait(0.5)
		if dfn.alert:
			seen_at = g.clock - t0
			break
	check(dfn.alert, "[alert] the Crown sees the push coming within %.0f s (%s)" % [ALERT_BY, ("%.1f s" % seen_at) if seen_at >= 0.0 else "never"])
	check(dfn.party_wait() and dfn.wants_soldiers(), "[alert] soldiers before labourers and no balloon party while it lasts")
	_clear_foes()
	if is_instance_valid(eye):
		eye.die()
	await wait(3.0)
	# [walk]: Musketeers out at the hall site nearest the ramp's foot, Clock Soldiers come between them and the ramp
	var foot: Vector2 = (ch._ramp_mid + Vector2(0.5, 0.5)) * T - ch._in * 3.0 * T
	var site := Vector2.INF
	for s in g.base_sites:
		var p: Vector2 = (Vector2(s) + Vector2(2.5, 2.0)) * T
		if g.starts.has(s) or ch.on_main(p):
			continue
		if site == Vector2.INF or p.distance_to(foot) < site.distance_to(foot):
			site = p
	g._add_building("cottage", 0, g.nearest_free(g.cell_of(site) + Vector2i(-3, 0), 8), true)
	var muskets: Array = []
	for i in 4:
		muskets.append(g._add_unit("musketeer", 0, _free(site + Vector2(float(i) * 24.0, 60.0))))
	var m0p: Vector2 = site + Vector2(36.0, 60.0)
	var band: Vector2 = ch._bc * T
	var mid := m0p + (band - m0p).normalized() * minf(300.0, m0p.distance_to(band) * 0.5)
	print("  (the Musketeers out are %.1f tiles from the ramp's top; the Clock Soldiers stand %.0f px from them on the way)" % [m0p.distance_to(band) / T, mid.distance_to(m0p)])
	var claws: Array = []
	for i in 8:
		var u: Unit = g._add_unit("clock_soldier", 1, _free(mid + Vector2(float(i % 4 - 2) * 24.0, float(i / 4) * 24.0)))
		u.cmd_hold()
		claws.append(u)
	await wait(0.5)
	for u in muskets:
		u.cmd_move(band)       # (sent up to the post on a plain move, as the owner's were: the computer must not let it stand)
	var s0: int = dfn.steers + dfn.fights
	var walk_deaths := 0
	var last: Dictionary = {}
	t0 = g.clock
	while g.clock - t0 < 30.0:
		await wait(0.25)
		if OS.get_cmdline_user_args().has("debug") and int(g.clock * 4.0) % 8 == 0:
			print("  (t %.1f: %s; threat %s holds %d)" % [g.clock - t0, ", ".join(muskets.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead).map(func(u) -> String: return "%s %s slot %s errand %s det %s army %s" % [u.order, str(u.position.round()), str(ch._slot.has(u)), str(ai._on_errand(u)), str(ai._det.has(u)), str(g.army(0).has(u))])), str(ai._threat()), ch.holds])
		for u in muskets:
			if is_instance_valid(u) and not u.dead:
				last[u] = u.order
			elif last.has(u):
				if String(last[u]) == "move":
					walk_deaths += 1
				last.erase(u)
		for c in claws:
			if g.clock - t0 < 6.0:
				continue            # (they stand between the Musketeers and the ramp a moment: the Crown calls its men home)
			if is_instance_valid(c) and not c.dead and c.order == "idle":
				var near: Unit = null
				for u in muskets:
					if is_instance_valid(u) and not u.dead and (near == null or u.position.distance_to(c.position) < near.position.distance_to(c.position)):
						near = u
				if near != null and near.position.distance_to(c.position) < 420.0:
					c.cmd_attack(near)
	var killed := claws.filter(func(c) -> bool: return not is_instance_valid(c) or c.dead).size()
	print("  (the Musketeers out: %d alive of 4, %d Clock Soldiers killed)" % [muskets.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead).size(), killed])
	check(dfn.steers + dfn.fights > s0, "[walk] the Musketeers out fight or step round the enemy (%d orders)" % (dfn.steers + dfn.fights - s0))
	check(walk_deaths == 0, "[walk] none dies walking past the enemy on a plain move (%d)" % walk_deaths)
	_clear_foes()
	for u in muskets:
		if is_instance_valid(u) and not u.dead:
			u.die()
	await wait(5.0)
	# [muster]: a Farm on the main far from the hall, Clock Soldiers at it, 5 Musketeers spread over the main
	var farm: Building = null
	var fd := 0.0
	for b in g.buildings:
		if b.team == 0 and not b.dead and b.kind == "farm" and ch.on_main(b.center()) and b.center().distance_to(hall) > fd:
			fd = b.center().distance_to(hall)
			farm = b
	if farm == null:
		var fc: Vector2i = g.nearest_free(g.cell_of(hall - ch._in * 9.0 * T), 10)
		farm = g._add_building("farm", 0, fc, true)
	var home: Array = []
	for i in 5:
		home.append(g._add_unit("musketeer", 0, _free(hall + Vector2(float(i - 2) * 90.0, -70.0 + float(i % 2) * 140.0))))
	await wait(4.0)
	var gang: Array = []
	for i in 12:
		var u: Unit = g._add_unit("clock_soldier", 1, _free(farm.center() + Vector2(float(i % 4 - 2) * 22.0, float(i / 4 - 1) * 22.0 + 60.0)))
		u.cmd_attack(farm)
		gang.append(u)
	var m0: int = dfn.musters
	var e0: int = dfn.engages
	var far_out := 0
	var mustered := false
	t0 = g.clock
	while g.clock - t0 < 12.0:
		await wait(0.5)
		if dfn.mustering():
			mustered = true
			for u in home:
				if is_instance_valid(u) and not u.dead and u.position.distance_to(farm.center()) < FARM_GAP and u.position.distance_to(dfn._muster_p) > FARM_GAP:
					far_out += 1
	check(mustered and dfn.musters > m0, "[muster] the army musters at the hall against a force it cannot beat (%d)" % (dfn.musters - m0))
	check(far_out == 0, "[muster] no Musketeer goes to the Farm alone (%d looks)" % far_out)
	# the Clock Soldiers come at the hall: the gathered line fights as one
	for u in gang:
		if is_instance_valid(u) and not u.dead:
			u.cmd_move(dfn._muster_p if dfn._muster_p != Vector2.INF else hall, true)
	t0 = g.clock
	while g.clock - t0 < 20.0:
		await wait(0.5)
		if dfn.engages > e0:
			break
		if int(g.clock * 2.0) % 4 == 0:
			var live_g := gang.filter(func(c) -> bool: return is_instance_valid(c) and not c.dead)
			print("  (t %.1f: mustering %s at %s, %d Clock Soldiers left, nearest %.0f px from it, threat %s)" % [g.clock - t0, str(dfn.mustering()), str(dfn._muster_p),
				live_g.size(), live_g.map(func(c) -> float: return c.position.distance_to(dfn._muster_p)).min() if not live_g.is_empty() else -1.0, str(ai._threat())])
	var g_left := gang.filter(func(c) -> bool: return is_instance_valid(c) and not c.dead).size()
	var h_left := home.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead).size()
	# (the line on HOLD at the muster shoots them as they come: the muster may end, its army now worth more than what is left,
	# before the last ones reach it; that is the muster working too)
	check(dfn.engages > e0 or (12 - g_left) * 70 > (5 - h_left) * 60 * 2, "[muster] when they come at the hall the gathered army fights as one (%d engaged; %d of 12 Clock Soldiers left, %d of 5 Musketeers)" % [dfn.engages - e0, g_left, h_left])
	print("test_crown_defence: %s (%d failed)" % ["ALL PASS" if fails == 0 else "FAILED", fails])
	quit(1 if fails > 0 else 0)
