extends SceneTree
## THE CROWN'S GUNS AT CONTACT, a bench (crown-guns-coach, docs/crown_guns_coach.md; scripts/ai_crown_guns.gd): a Crown
## wave (12 Musketeers, 3 Field Cannons, 2 Horsemen for its screen) set out by the Crown computer's own wave loop across the
## open middle of a map toward the enemy's base, and an enemy force ahead of it:
##   clock   10 Clock Soldiers coming on (an attack-move at the wave)           (Crown v Clockwork)
##   raptor  16 Raptors coming on                                                (Crown v Brood)
##   hold    8 Musketeers on HOLD across the road (the wave walks into them)    (the mirror)
##   flank   10 Clock Soldiers coming on from the wave's flank, out of its sight until close
##   home    the wave stands at home on its rally; 10 Clock Soldiers walk at it (a defence)
## Counts: the guns set up at contact (an enemy within 260 px of a Musketeer), the guns that fired by contact + 10 s, the
## line's state at contact, and what the wave killed and lost in the 45 s after contact. Each scenario `runs` times.
##   godot --headless --fixed-fps 30 --script res://tools/bench_crown_guns.gd -- [only:clock,raptor] [runs:2] [map:greenhold]
##       [out:/abs/file.json] [gunscoach:off ...]
## A measuring tool: it changes no rule.
var main: Node
var g: Game
var res: Array = []


func _initialize() -> void:
	_run.call_deferred()


func _arg(k: String, d: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(k + ":"):
			return a.substr(k.length() + 1)
	return d


func _until(clock: float, cond := Callable()) -> void:
	while g.clock < clock and not g.over:
		await physics_frame
		if cond.is_valid() and cond.call():
			return


func _start(fb: String, sd: int, map: String) -> void:
	if main != null:
		main.queue_free()
		await process_frame
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	seed(sd)
	main.start({"map": map, "seed": sd, "slots": [
		{"who": "hard", "faction": "crown", "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "hard", "faction": fb, "colour": 1, "side": 1, "strategy": "balanced"}]})
	await process_frame
	await process_frame
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	# (the enemy's computer is taken off: the bench's enemy does what the scenario says)
	for a in g.ais.duplicate():
		if a.team == 1:
			g.ais.erase(a)


func _ai(t: int):
	for a in g.ais:
		if a.team == t:
			return a
	return null


func _spawn(kind: String, t: int, p: Vector2) -> Unit:
	var c: Vector2i = g.nearest_free(g.cell_of(g.on_map(p)), 6)
	return g._add_unit(kind, t, g.cell_center(c))


func _alive(list: Array) -> Array:
	return list.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)


func _run() -> void:
	var only := _arg("only", "clock,raptor,hold,flank,home").split(",")
	var runs := int(_arg("runs", "2"))
	var map := _arg("map", "greenhold")
	for sc in only:
		for r in runs:
			await _one(sc, r, map)
	var tot := {}
	for x in res:
		var k: String = x["sc"]
		if not tot.has(k):
			tot[k] = {"n": 0, "guns": 0, "set": 0, "fired": 0, "killed": 0, "lost": 0, "formed": 0}
		var t: Dictionary = tot[k]
		t["n"] += 1
		t["guns"] += x["guns"]
		t["set"] += x["set"]
		t["fired"] += x["fired"]
		t["killed"] += x["killed"]
		t["lost"] += x["lost"]
		t["formed"] += 1 if x["formed"] else 0
	for k in tot:
		var t: Dictionary = tot[k]
		print("TOTAL %-7s runs %d  guns %d  set at contact %d  fired in 10 s %d  formed %d  killed %d  lost %d  (k/l %.2f)" % [
			k, t["n"], t["guns"], t["set"], t["fired"], t["formed"], t["killed"], t["lost"], float(t["killed"]) / maxf(1.0, float(t["lost"]))])
	var out := _arg("out", "")
	if out != "":
		var f := FileAccess.open(out, FileAccess.WRITE)
		f.store_string(JSON.stringify({"runs": res, "total": tot}, " "))
	quit(0)


func _one(sc: String, r: int, map: String) -> void:
	var fb := "clockwork"
	if sc == "raptor":
		fb = "brood"
	elif sc == "hold":
		fb = "crown"
	await _start(fb, 7300 + r * 17 + sc.length(), map)
	var ai = _ai(0)
	ai.line_ai()
	ai.peaceful = true
	await _until(g.clock + 1.0)
	var mid := Vector2(Game.W, Game.H) * Defs.TILE * 0.5
	var home: Vector2 = ai._halls()[0].center() if not ai._halls().is_empty() else Vector2(g.starts[0]) * Defs.TILE
	var goal: Vector2 = Vector2(g.starts[1]) * Defs.TILE
	var to_goal: Vector2 = (goal - mid).normalized()
	var perp := Vector2(-to_goal.y, to_goal.x)
	var at: Vector2 = mid - to_goal * 500.0 + perp * (r * 60.0 - 30.0)
	if sc == "home":
		at = home + (mid - home).normalized() * 380.0
	var wave: Array = []
	for i in 12:
		wave.append(_spawn("musketeer", 0, at + Vector2((i % 6) * 28, (i / 6) * 28)))
	for i in 3:
		wave.append(_spawn("cannon", 0, at - to_goal * 90.0 + Vector2(i * 50, 0)))
	for i in 2:
		wave.append(_spawn("cuirassier", 0, at + Vector2(i * 40, -60)))
	await _until(g.clock + 2.0)
	var foes: Array = []
	var foe_at: Vector2 = mid + to_goal * 380.0
	if sc == "flank":
		foe_at = mid + perp * 760.0 - to_goal * 100.0
	if sc == "home":
		foe_at = at + (mid - home).normalized() * 1300.0
	var fk: String = {"clock": "clock_soldier", "raptor": "raptor", "hold": "musketeer", "flank": "clock_soldier", "home": "clock_soldier"}[sc]
	var nf: int = {"clock": 14, "raptor": 24, "hold": 12, "flank": 14, "home": 14}[sc]
	for i in nf:
		var f := _spawn(fk, 1, foe_at + Vector2((i % 5) * 26, (i / 5) * 26))
		foes.append(f)
		f.cmd_hold()
	if sc == "home":
		ai.peaceful = true
		for u in wave:
			if u.kind == "cannon":
				pass
	else:
		ai.peaceful = true
		ai._attacking = true
		ai._wave_target = goal
		ai._wave_set.clear()
		for u in wave:
			ai._wave_set[u] = true
			u.cmd_move(goal, true)
	# the enemy: Musketeers hold; the others come on after a few seconds (toward where the wave will be)
	print("   at %s foe_at %s goal %s mid %s clock %.1f" % [str(at), str(foe_at), str(goal), str(mid), g.clock])
	var go_t := g.clock + (6.0 if sc != "home" else 1.0)
	var contact_t := -1.0
	var guns: Array = wave.filter(func(u: Unit) -> bool: return u.kind == "cannon")
	var set_n := 0
	var st0 := ""
	var k0 := 0.0
	var l0 := 0.0
	var sent := false
	var counted := false
	var t_end := g.clock + 120.0
	while g.clock < t_end and not g.over:
		await physics_frame
		if not sent and g.clock >= go_t:
			sent = true
			for f in _alive(foes):
				if sc == "hold":
					f.cmd_hold()
				else:
					var wc := Vector2.ZERO
					var wn := 0
					for u in _alive(wave):
						wc += u.position
						wn += 1
					f.cmd_move(wc / maxi(1, wn) if wn > 0 else at, true)
		if sent and sc == "hold" and Engine.get_physics_frames() % 30 == 0:
			pass
		if contact_t < 0.0:
			var hit := false
			for u in _alive(wave):
				if u.kind != "musketeer":
					continue
				for o in _alive(foes):
					if o.position.distance_to(u.position) < 260.0:
						hit = true
						break
				if hit:
					break
			if hit:
				contact_t = g.clock
				set_n = _alive(guns).filter(func(u: Unit) -> bool: return u.tesla_mode == "deployed").size()
				st0 = ai.ln.st
				k0 = float(g.stats[0]["value_killed"])
				l0 = float(g.stats[1]["value_killed"])
				t_end = g.clock + 45.0
		if contact_t >= 0.0 and not counted and g.clock >= contact_t + 10.0:
			counted = true
			for u in guns:
				if is_instance_valid(u) and u.fired_t >= contact_t - 0.5:
					_first_fired += 1
		# (foes coming on keep coming at the wave)
		if sent and sc != "hold" and Engine.get_physics_frames() % 60 == 0:
			for f in _alive(foes):
				if f.order == "idle" and f.target == null:
					var wc := Vector2.ZERO
					var wn := 0
					for u in _alive(wave):
						wc += u.position
						wn += 1
					if wn > 0:
						f.cmd_move(wc / wn, true)
	var x := {"sc": sc, "run": r, "contact": snappedf(contact_t, 0.1), "st": st0, "formed": st0 in ["form", "step", "set", "await", "advance"],
		"guns": guns.size(), "set": set_n, "fired": _first_fired, "killed": int(float(g.stats[0]["value_killed"]) - k0),
		"lost": int(float(g.stats[1]["value_killed"]) - l0), "said": ai.ln.said.slice(-6)}
	if sc == "home":
		x["formed"] = ai.ln.def_lines > 0
	_first_fired = 0
	print("%-6s run %d: contact %.1f (line %s), guns %d, set at contact %d, fired in 10 s %d; killed %d lost %d; %s" % [
		sc, r, contact_t, st0, guns.size(), set_n, x["fired"], x["killed"], x["lost"], str(x["said"])])
	res.append(x)


var _first_fired := 0
