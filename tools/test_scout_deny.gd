extends SceneTree
## DENY THE SCOUT (scout-deny, scripts/ai_scout_deny.gd, docs/scout_deny.md): an enemy scout walking into each faction's
## base is hunted down within CATCH_S s by fit hunters (never the whole army), nothing chases past the leash, workers go
## at a scout only when no soldier can and go back to work after, and with the switch off nobody is sent.
##   godot --headless --fixed-fps 30 --script res://tools/test_scout_deny.gd
var fails := 0
const CATCH_S := 40.0


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _start(fac: String, map := "greenhold", seed_ := 5) -> Array:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.start({"map": map, "seed": seed_, "slots": [
		{"who": "human", "faction": "crown", "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "hard", "faction": fac, "colour": 1, "side": 1, "strategy": "optimal"}]})
	await process_frame
	await process_frame
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	var ai: AI
	for a in g.ais:
		if a.team == 1:
			ai = a
	return [main, g, ai]


func _wait(n: int) -> void:
	for i in n:
		await physics_frame


func _home(g: Game) -> Vector2:
	if BroodNew.on(g, 1) and BroodNew.queen(g, 1) != null:
		return BroodNew.queen(g, 1).position
	return (g.halls_of(1)[0] as Building).center()


## A point this many tiles from the AI's home toward the enemy's (walkable).
func _toward(g: Game, tiles: float) -> Vector2:
	var h := _home(g)
	var dir := (g.start_mid(0) - h).normalized()
	for k in 30:
		var p := h + dir.rotated(0.15 * (k % 2 * 2 - 1) * (k / 2)) * tiles * Defs.TILE
		if g.in_map(g.cell_of(p)) and g._walkable(g.cell_of(p)):
			return p
	return h + dir * tiles * Defs.TILE


func _hunters(fac: String) -> Array:
	match fac:
		"brood":
			return ["raptor", "raptor", "raptor"]
		"crown":
			return ["cuirassier", "cuirassier", "musketeer", "musketeer"]
	return ["clock_soldier", "clock_soldier", "clock_soldier"]


func _army(g: Game, fac: String) -> Array:
	var out: Array = []
	var h := _home(g)
	var i := 0
	for k in _hunters(fac):
		var u: Unit = g._add_unit(k, 1, h + Vector2(60 + 18 * i, 70))
		out.append(u)
		i += 1
	return out


## The scout walks into the base and round the hall (a loop of points 6 tiles out, as a computer's scout does).
func _scout(g: Game, kind: String, hp := 0.0) -> Unit:
	var s: Unit = g._add_unit(kind, 0, _toward(g, 16.0))
	if hp > 0.0:
		s.max_hp = hp
		s.hp = hp
	s.auto_work = false
	s.set_meta("loop", 0)
	_drive(g, s)
	return s


var loop_c := Vector2.INF       # (the loop's centre: the AI's home unless a case sets it)
var loop_r := 6.0


func _loop_pt(g: Game, k: int) -> Vector2:
	var h := _home(g) if loop_c == Vector2.INF else loop_c
	var a0 := (g.start_mid(0) - h).angle()
	for j in 8:
		var p := h + Vector2.RIGHT.rotated(a0 + TAU * float(k + j) / 6.0) * loop_r * Defs.TILE
		if g.in_map(g.cell_of(p)) and g._walkable(g.cell_of(p)):
			return p
	return h


## On round the loop (call it now and then).
func _drive(g: Game, s: Unit) -> void:
	if s.dead or not s.has_meta("loop"):
		return
	var k: int = s.get_meta("loop")
	var p := _loop_pt(g, k)
	if s.position.distance_to(p) < 50.0 or s.order == "idle":
		k += 1
		s.set_meta("loop", k)
		p = _loop_pt(g, k)
	if s.order != "move" or s.order_point.distance_to(p) > 10.0:
		s.cmd_move(p)


func _case_catch(fac: String) -> void:
	var r := await _start(fac)
	var main: Node = r[0]
	var g: Game = r[1]
	var ai: AI = r[2]
	await _wait(600)          # (20 s: the computer is going)
	var army := _army(g, fac)
	await _wait(30)
	var s := _scout(g, "labourer")
	var t0 := g.clock
	var dead_at := -1.0
	var most := 0
	while g.clock - t0 < CATCH_S:
		await _wait(15)
		_drive(g, s)
		if ai.sd != null:
			most = maxi(most, ai.sd.hunters.size())
		if s.dead:
			dead_at = g.clock - t0
			break
	var sent: int = ai.sd.n["sent"] if ai.sd != null else 0
	print("  [%s] scout dead after %.1f s, hunts sent %d, most hunters at once %d, army %d" % [fac, dead_at, sent, most, army.size()])
	check(sent >= 1 or (dead_at >= 0.0 and dead_at < 12.0), "%s: hunters are sent after the scouting Labourer (or the guard shoots it at once)" % fac)
	check(dead_at >= 0.0, "%s: the scouting Labourer is killed within %d s (%.1f)" % [fac, int(CATCH_S), dead_at])
	check(most <= AIScoutDeny.MAX_PER, "%s: at most %d hunters for one scout, never the army (%d)" % [fac, AIScoutDeny.MAX_PER, most])
	await _wait(300)
	var log_ok: bool = sent == 0 or (ai.sd.said.any(func(l) -> bool: return String(l[1]).begins_with("sends ")) \
		and (dead_at < 0.0 or ai.sd.said.any(func(l) -> bool: return String(l[1]).begins_with("killed the Crown's scouting Labourer"))))
	check(log_ok, "%s: the match log tells the chase and the kill" % fac)
	check(ai.sd.hunters.is_empty(), "%s: the hunters are let go after the kill (%d)" % [fac, ai.sd.hunters.size()])
	main.queue_free()
	await process_frame


func _case_leash(fac: String) -> void:
	var r := await _start(fac)
	var main: Node = r[0]
	var g: Game = r[1]
	var ai: AI = r[2]
	await _wait(600)
	_army(g, fac)
	await _wait(30)
	var s := _scout(g, "labourer", 40000.0)          # (it can't be killed, nor hit back: it runs off)
	s.m_unarmed = true
	var t0 := g.clock
	while g.clock - t0 < 25.0 and (ai.sd == null or ai.sd.hunters.is_empty()):
		await _wait(15)
		_drive(g, s)
	s.remove_meta("loop")
	check(ai.sd != null and not ai.sd.hunters.is_empty(), "%s: hunters go after a scout (leash case)" % fac)
	var chasers: Array = ai.sd.hunters.keys() if ai.sd != null else []
	s.cmd_move(g.start_mid(0))        # (home, far away)
	var worst := -INF
	t0 = g.clock
	while g.clock - t0 < 45.0:
		await _wait(15)
		for u in chasers:
			if is_instance_valid(u) and not u.dead:
				worst = maxf(worst, ai.sd.base_dist(u.position) / Defs.TILE)
	var limit := AIScoutDeny.LEASH + 4.0
	print("  [%s leash] farthest a hunter went past its base: %.1f tiles (limit %.1f), hunts ended %d" % [fac, worst, limit, ai.sd.n["escaped"]])
	for l in ai.sd.said:
		print("    %.1f %s" % [l[0], l[1]])
	check(worst <= limit, "%s: nothing chases past the leash (%.1f tiles past the base)" % [fac, worst])
	check(ai.sd.n["escaped"] >= 1, "%s: the chase is given up and the hunters go back" % fac)
	main.queue_free()
	await process_frame


## No soldier at all early: the hands next to a grub scout go at it, then back to work.
func _case_workers() -> void:
	var r := await _start("crown")
	var main: Node = r[0]
	var g: Game = r[1]
	var ai: AI = r[2]
	await _wait(900)
	for u in g.army(1):
		u.die()
	var farm: Building = null
	for b in g.buildings:
		if b.team == 1 and b.kind == "farm" and b.built and not b.dead and (farm == null or b.crew.size() > farm.crew.size()):
			farm = b
	loop_c = farm.center() if farm != null else Vector2.INF
	loop_r = 3.0
	var s: Unit = g._add_unit("grub", 0, _loop_pt(g, 3))     # (inside the walled main: a scout that slipped in)
	s.auto_work = false
	s.set_meta("loop", 0)
	_drive(g, s)
	var t0 := g.clock
	var dead_at := -1.0
	var workers_sent := 0
	while g.clock - t0 < 30.0:
		await _wait(15)
		_drive(g, s)
		workers_sent = maxi(workers_sent, ai.sd.n["workers_sent"] if ai.sd != null else 0)
		if s.dead:
			dead_at = g.clock - t0
			break
	for l in ai.sd.said:
		print("    %.1f %s" % [l[0], l[1]])
	print("    none fit %d" % ai.sd.n["none_fit"])
	print("  [workers] grub dead after %.1f s, workers sent %d" % [dead_at, workers_sent])
	check(workers_sent >= 1 and workers_sent <= AIScoutDeny.MAX_PER, "crown: with no soldier, 1-2 labourers go at a grub scout (%d)" % workers_sent)
	check(dead_at >= 0.0 or (ai.sd != null and ai.sd.n["escaped"] >= 1), "crown: the grub is killed or driven off")
	await _wait(450)
	var idle := 0
	for w in g.workers(1):
		if w.order == "idle" and w.can_gather() and g.free_site(1, w.position) != null:
			idle += 1
	check(ai.sd.hunters.is_empty() and idle == 0, "crown: the labourers are back at work (%d idle, %d hunters)" % [idle, ai.sd.hunters.size()])
	loop_c = Vector2.INF
	loop_r = 6.0
	main.queue_free()
	await process_frame


## The switch off: nobody is sent by this rule.
func _case_off() -> void:
	AIScoutDeny.on = false
	var r := await _start("brood")
	var main: Node = r[0]
	var g: Game = r[1]
	var ai: AI = r[2]
	await _wait(600)
	_army(g, "brood")
	var s := _scout(g, "labourer")
	for k in 40:
		await _wait(15)
		_drive(g, s)
	check(ai.sd == null or ai.sd.n["sent"] == 0, "scoutdeny:off: nobody is sent after a scout")
	AIScoutDeny.on = true
	main.queue_free()
	await process_frame


func _run() -> void:
	var only := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("only:"):
			only = a.substr(5)          # (catch, leash, workers, off: one case alone)
	if only in ["", "catch"]:
		for fac in ["brood", "crown", "clockwork"]:
			await _case_catch(fac)
	if only in ["", "leash"]:
		for fac in ["brood", "crown"]:
			await _case_leash(fac)
	if only in ["", "workers"]:
		await _case_workers()
	if only in ["", "off"]:
		await _case_off()
	print("scout deny: %s (%d failed)" % ["ALL PASS" if fails == 0 else "FAILURES", fails])
	quit(1 if fails > 0 else 0)
