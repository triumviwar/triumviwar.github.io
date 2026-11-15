extends SceneTree
## THE BALLOON PARTY WAITS FOR ITS MEN (crown-coach-balloon, docs/crown-coach-balloon.md; scripts/ai_crown_balloon.gd):
##   godot --headless --fixed-fps 30 --script res://tools/test_crown_balloon_coach.gd [-- trace]
## A Hard Crown computer on the Balloon harass plan against a Clockwork that stands still (its computer off), on Hollowfen
## (the owner's game of 2026-11-15).
##  [wait]     an empty balloon with too few men for a party waits over its boarding spot at home (never out alone)
##  [mend]     a hurt balloon at home is mended by a labourer
##  [spot]     the boarding spot is on the side of the main hall away from the enemy
##  [load]     a party forms only with the balloon home; no man of it walks out more than LOAD_R tiles from home while
##             it loads; three or more climb in, and it never leaves with men walking after it
##  [calloff]  Clock Soldiers at the main while a party loads: the party is called off, nobody boards, the balloon stays
##  [aviary]   a Clock Aviary counts as anti-air where it stands
##  [hit]      a party whose balloon is hit on the way (HIT_K of its health) turns back home
##  [switch]   with the coaching off (`blfix:off`, here the module's fix_on) an empty balloon floats out to look, as before
const T := 32.0
const LOAD_R := 22.0
var fails := 0
var main: Node
var g: Game
var ai: AICrown
var trace := false
var hall: Building


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	trace = OS.get_cmdline_user_args().has("trace")
	_run.call_deferred()


func wait(s: float) -> void:
	var until := g.clock + s
	while g.clock < until:
		await physics_frame


func _start() -> void:
	if main != null:
		main.queue_free()
		await process_frame
		await process_frame
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	seed(11)
	main.start({"map": "hollowfen", "seed": 4287366311, "slots": [
		{"who": "hard", "faction": "crown", "colour": 0, "side": 0, "strategy": "balloon"},
		{"who": "hard", "faction": "clockwork", "colour": 1, "side": 1, "strategy": "balanced"}]})
	await process_frame
	await process_frame
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
		g.hud.visible = false
		g.hud.process_mode = Node.PROCESS_MODE_DISABLED
	paused = false
	ai = null
	for a in g.ais:
		if a.team == 1:
			a.process_mode = Node.PROCESS_MODE_DISABLED      # (the Clockwork stands still)
		elif a is AICrown:
			ai = a
	await wait(1.0)
	hall = ai._halls()[0]


func _free(p: Vector2) -> Vector2:
	var c := g.cell_of(p)
	for r in 8:
		for y in range(c.y - r, c.y + r + 1):
			for x in range(c.x - r, c.x + r + 1):
				var m := Vector2i(x, y)
				if g.in_map(m) and g._walkable(m):
					return (Vector2(m) + Vector2(0.5, 0.5)) * T
	return p


func _foe_start() -> Vector2:
	return (Vector2(g.starts[1]) + Vector2(2.5, 2.0)) * T


func _musk(n: int) -> Array:
	var out: Array = []
	for i in n:
		out.append(g._add_unit("musketeer", 0, _free(hall.center() + Vector2(-100 + 25 * i, 130))))
	return out


func _run() -> void:
	await _start()
	if ai == null or ai.bl == null:
		check(false, "[plan] the harass is made on its plan")
		_end()
		return
	var bl = ai.bl
	# [wait]: one balloon, one Musketeer (too few for a party), the balloon left 30 tiles out toward the enemy
	var dir := (_foe_start() - hall.center()).normalized()
	var b: Unit = g._add_unit("balloon", 0, hall.center() + dir * 30.0 * T)
	_musk(1)
	var far := 0.0
	for i in 60:
		await wait(1.0)
		if i > 45:
			far = maxf(far, b.position.distance_to(bl._board_spot()))
	check(bl.parties.is_empty(), "[wait] no party with one Musketeer (%d)" % bl.parties.size())
	check(far < 80.0, "[wait] the empty balloon came home and waits over its boarding spot (%.0f px from it)" % far)
	# [mend]: the balloon hurt at home: a labourer mends it
	b.hp = b.max_hp * 0.5
	g.players[0]["gold"] += 400
	var hp0 := b.hp
	for k in 9:
		await wait(5.0)
		if trace:
			print("   mend: hp %.0f gold %d menders %s workers %s" % [b.hp, ai._gold(), str(bl._menders.values().map(func(w): return w.order)), str(g.workers(0).map(func(w): return [w.order, w.carrying, int(w.position.distance_to(b.position))]).slice(0, 6))])
	check(b.hp > hp0 + 20.0, "[mend] a labourer mends the hurt balloon at home (%.0f -> %.0f)" % [hp0, b.hp])
	b.hp = b.max_hp
	# [spot]
	var spot: Vector2 = bl._board_spot()
	check((spot - hall.center()).dot(dir) < 0.0, "[spot] the boarding spot is behind the hall, away from the enemy (%s, hall %s)" % [str(Vector2i(spot / T)), str(Vector2i(hall.center() / T))])
	# [load]: the balloon sent out again, then four more Musketeers: no man walks out to it
	b.position = hall.center() + dir * 30.0 * T
	var men := _musk(4)
	var formed_at_far := false
	var worst := 0.0
	var boarded := 0
	for i in 70:
		await wait(1.0)
		for p in bl.parties:
			if p["b"] == b and String(p["phase"]) == "load" and b.position.distance_to(spot) > 14.0 * T and game_clock_formed(p) >= g.clock - 1.0:
				formed_at_far = true
		for m in men:
			if is_instance_valid(m) and not m.dead and m.aboard == null:
				worst = maxf(worst, m.position.distance_to(hall.center()) / T)
		boarded = maxi(boarded, b.passengers.size())
		if trace and i % 5 == 0:
			print("   %.0f %s" % [g.clock, str(bl.parties.map(func(p): return [p["phase"], (p["men"] as Array).size(), (p["b"] as Unit).passengers.size()]))])
	check(not formed_at_far, "[load] no party formed while its balloon was away")
	check(worst <= LOAD_R, "[load] no man walked out more than %d tiles from home while it loaded (%.1f)" % [int(LOAD_R), worst])
	check(boarded >= 3, "[load] three or more climbed into the basket (%d)" % boarded)
	var left_behind := 0
	for p in bl.parties:
		if String(p["phase"]) not in ["load", "done"]:
			for m in p["men"]:
				if (m as Unit).aboard == null and String(p["phase"]) == "fly":
					left_behind += 1
	check(left_behind == 0, "[load] no man walking after a balloon that has left (%d)" % left_behind)
	# [calloff]: a fresh start; a party loads, Clock Soldiers come to the main
	await _start()
	bl = ai.bl
	var b2: Unit = g._add_unit("balloon", 0, hall.center() + Vector2(0, 110))
	_musk(5)
	var t0 := g.clock
	while g.clock - t0 < 40.0:
		await wait(0.5)
		if not bl.parties.is_empty() and String(bl.parties[0]["phase"]) == "load":
			break
	var loading: bool = not bl.parties.is_empty()
	for i in 6:
		var cs: Unit = g._add_unit("clock_soldier", 1, _free(hall.center() + Vector2(-40 + 16 * i, -90)))
		cs.cmd_hold()
	await wait(6.0)
	var called: bool = bl.parties.is_empty() or bl.parties.all(func(p): return String(p["phase"]) == "done")
	check(loading, "[calloff] a party was loading")
	check(called, "[calloff] Clock Soldiers at the main call it off")
	await wait(10.0)
	check(b2.position.distance_to(hall.center()) < 12.0 * T and b2.passengers.size() == 0, "[calloff] the balloon stays home, nobody aboard (%d tiles, %d aboard)" % [int(b2.position.distance_to(hall.center()) / T), b2.passengers.size()])
	# [aviary]
	await _start()
	bl = ai.bl
	var av: Building = null
	var fs := _foe_start()
	for k in 24:
		var c: Vector2i = g.cell_of(fs + Vector2.RIGHT.rotated(TAU * k / 24.0) * 9.0 * T)
		if g.in_map(c) and g._walkable(c) and g._walkable(c + Vector2i(1, 1)):
			av = g._add_building("cuckoo_house", 1, c, true)
			break
	check(av != null and bl._aa_of(av) > 0.0, "[aviary] a Clock Aviary counts as anti-air (reach %.0f)" % (bl._aa_of(av) if av != null else 0.0))
	# [hit]
	var b3: Unit = g._add_unit("balloon", 0, hall.center() + Vector2(0, 110))
	_musk(5)
	t0 = g.clock
	var flying := false
	while g.clock - t0 < 90.0:
		await wait(0.5)
		for p in bl.parties:
			if p["b"] == b3 and String(p["phase"]) == "fly":
				flying = true
		if flying:
			break
	check(flying, "[hit] a party flies out")
	if flying:
		b3.hp -= b3.max_hp * 0.3
		b3.hit_clock = g.clock
		var ph := ""
		for k in 6:
			await wait(0.5)
			for p in bl.parties:
				if p["b"] == b3:
					if ph != "home":
						ph = String(p["phase"])
					if trace:
						print("   hp %.0f hp0 %.0f %s" % [b3.hp, float(p.get("hp0", -1)), ph])
		check(ph == "home", "[hit] hit on the way, it turns back home (%s)" % ph)
	# [switch]
	await _start()
	bl = ai.bl
	bl.fix_on = false
	var b4: Unit = g._add_unit("balloon", 0, hall.center() + Vector2(0, 110))
	await wait(40.0)
	check(b4.position.distance_to(hall.center()) > 15.0 * T, "[switch] with the coaching off the empty balloon floats out to look (%d tiles)" % int(b4.position.distance_to(hall.center()) / T))
	_end()


func game_clock_formed(p: Dictionary) -> float:
	return float(p.get("t0", -1.0))


func _end() -> void:
	print("test_crown_balloon_coach: %s (%d failed)" % ["ALL PASS" if fails == 0 else "FAILED", fails])
	quit(1 if fails > 0 else 0)
