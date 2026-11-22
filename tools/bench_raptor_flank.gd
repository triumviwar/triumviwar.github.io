extends SceneTree
## DO THE RAPTORS GO ROUND THE GUNS? a set-piece fight test (crown-brood-fix, docs/crown_brood_fix.md; the owner 2026-11-22:
## "Raptors flank the cannons / horsemen scouting?"). A Crown force (12 Musketeers, 3 Field Cannons, 2 Horsemen; the Crown
## computer's own micro on: its line, guns, screen and riders) against a Brood force of the SAME value (Game.unit_value):
##   home   the Crown force stands in a line on its own side, the guns unlimbered behind it, the riders by them; the Brood
##          comes on at the Crown's hall behind the line (an attack-move, as its waves do)
##   field  the Crown force marches as a wave toward the Brood's side (the wave loop: line, guns, screen); the Brood comes on
## Brood forces: raptor (all Raptors) / mixed (half Raptors, a quarter Spitters, a quarter Tyrant Challengers, by value).
## Counts, per run (from the first contact, 75 s): the Brood units that reached a gun (within 70 px), how many of those had
## crossed the line's front OUTSIDE its ends (round the flank), the first time one did, guns lost, value killed and lost.
##   godot --headless --fixed-fps 30 --path . --script res://tools/bench_raptor_flank.gd -- [only:home-raptor,field-mixed]
##       [runs:3] [map:greenhold] [out:/abs/file.json] [canlight:2.0 cbfflank:on ...]
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


func _until(clock: float) -> void:
	while g.clock < clock and not g.over:
		await physics_frame


func _start(sd: int, map: String) -> void:
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
		{"who": "hard", "faction": "brood", "colour": 1, "side": 1, "strategy": "balanced"}]})
	await process_frame
	await process_frame
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	for a in g.ais.duplicate():
		if a.team == 1:
			g.ais.erase(a)        # (the Brood's computer off: the bench's Brood does what the scenario says)


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


func _value(list: Array) -> float:
	var v := 0.0
	for u in _alive(list):
		v += float(Game.unit_value(u))
	return v


func _run() -> void:
	var only := _arg("only", "home-raptor,home-mixed,field-raptor,field-mixed").split(",")
	var runs := int(_arg("runs", "3"))
	var map := _arg("map", "greenhold")
	for sc in only:
		for r in runs:
			await _one(sc, r, map)
	var tot := {}
	for x in res:
		var k: String = x["sc"]
		if not tot.has(k):
			tot[k] = {"n": 0, "foes": 0, "reached": 0, "flank": 0, "runs_reached": 0, "guns_lost": 0, "killed": 0, "lost": 0, "first": []}
		var t: Dictionary = tot[k]
		t["n"] += 1
		t["foes"] += x["foes"]
		t["reached"] += x["reached"]
		t["flank"] += x["flank"]
		t["runs_reached"] += 1 if x["reached"] > 0 else 0
		t["guns_lost"] += x["guns_lost"]
		t["killed"] += x["killed"]
		t["lost"] += x["lost"]
		if x["first"] >= 0.0:
			t["first"].append(x["first"])
	for k in tot:
		var t: Dictionary = tot[k]
		print("TOTAL %-13s runs %d  foes %d  reached the guns %d (in %d runs; round the flank %d)  guns lost %d  killed %d  lost %d  (k/l %.2f)  first at %s s" % [
			k, t["n"], t["foes"], t["reached"], t["runs_reached"], t["flank"], t["guns_lost"], t["killed"], t["lost"],
			float(t["killed"]) / maxf(1.0, float(t["lost"])), str(t["first"])])
	var out := _arg("out", "")
	if out != "":
		var f := FileAccess.open(out, FileAccess.WRITE)
		f.store_string(JSON.stringify({"args": " ".join(OS.get_cmdline_user_args()), "runs": res, "total": tot}, " "))
	quit(0)


func _one(sc: String, r: int, map: String) -> void:
	var where := sc.split("-")[0]
	var mix := sc.split("-")[1]
	await _start(8100 + r * 23 + sc.length(), map)
	var ai = _ai(0)
	ai.line_ai()
	ai.peaceful = true
	await _until(g.clock + 1.0)
	var mid := Vector2(Game.W, Game.H) * Defs.TILE * 0.5
	var hall: Vector2 = ai._halls()[0].center() if not ai._halls().is_empty() else Vector2(g.starts[0]) * Defs.TILE
	var goal: Vector2 = Vector2(g.starts[1]) * Defs.TILE
	var to_goal: Vector2 = (goal - mid).normalized()
	var perp := Vector2(-to_goal.y, to_goal.x)
	var at: Vector2
	var front: Vector2         # (the way the Brood comes from, from the line)
	if where == "home":
		var out_dir: Vector2 = (mid - hall).normalized()
		at = hall + out_dir * 420.0 + Vector2(r * 30.0 - 30.0, 0)
		front = out_dir
	else:
		at = mid - to_goal * 900.0 + perp * (r * 60.0 - 60.0)
		front = to_goal
	var side := Vector2(-front.y, front.x)
	var wave: Array = []
	var sc_k := int(_arg("scale", "1"))
	var nm := 12 * sc_k
	for i in nm:
		wave.append(_spawn("musketeer", 0, at + side * (float(i % 18) - 8.5) * 26.0 - front * float(i / 18) * 28.0))
	var guns: Array = []
	for i in 3 * sc_k:
		var c := _spawn("cannon", 0, at - front * (90.0 + float(i / 6) * 60.0) + side * (float(i % 6) - 2.5) * 70.0)
		guns.append(c)
		wave.append(c)
	for i in 2 * sc_k:
		wave.append(_spawn("cuirassier", 0, at - front * 50.0 + side * (i % 2 * 2 - 1) * (190.0 + float(i / 2) * 40.0)))
	var cv := _value(wave)
	await _until(g.clock + 1.0)
	if where == "home":
		for u in wave:
			if u.kind == "cannon":
				u.cmd_deploy()
			else:
				u.cmd_hold()
	else:
		ai._attacking = true
		ai._wave_target = goal
		ai._wave_set.clear()
		for u in wave:
			ai._wave_set[u] = true
			u.cmd_move(goal, true)
	# the Brood: the same value, a block out in front
	var kinds: Array = ["raptor"] if mix == "raptor" else ["raptor", "raptor", "spitter", "tyrant_challenger"]
	var foes: Array = []
	var foe_at: Vector2 = at + front * (1300.0 if where == "home" else 1500.0)
	var bv := 0.0
	var i := 0
	while bv < cv and i < 600:
		var k: String = kinds[i % kinds.size()]
		var f := _spawn(k, 1, foe_at + side * float((i % 12) - 6) * 30.0 + front * float(i / 12) * 30.0)
		foes.append(f)
		f.cmd_hold()
		bv += float(Game.unit_value(f))
		i += 1
	await _until(g.clock + (2.0 if where == "home" else 4.0))
	var target: Vector2 = hall if where == "home" else at
	for f in _alive(foes):
		f.cmd_move(target, true)
	var contact_t := -1.0
	var t_end := g.clock + 150.0
	var lm := at
	var ld := front
	var lp := side
	var half := 0.0
	var fwd := {}        # foe -> last forward coordinate from the line
	var crossed := {}    # foe -> "flank" / "front"
	var reached := {}    # foe -> how it had crossed
	var first := -1.0
	var k0 := 0.0
	var l0 := 0.0
	var n_guns := guns.size()
	while g.clock < t_end and not g.over:
		await physics_frame
		var musk: Array = _alive(wave).filter(func(u: Unit) -> bool: return u.kind == "musketeer")
		if contact_t < 0.0:
			for u in musk:
				for o in _alive(foes):
					if o.position.distance_to(u.position) < 260.0:
						contact_t = g.clock
						break
				if contact_t >= 0.0:
					break
			if contact_t >= 0.0:
				t_end = g.clock + 75.0
				k0 = float(g.stats[0]["value_killed"])
				l0 = float(g.stats[1]["value_killed"])
		# the line as it stands now: its middle, its front (toward the Brood), its half length
		if not musk.is_empty() and Engine.get_physics_frames() % 6 == 0:
			lm = Vector2.ZERO
			for u in musk:
				lm += u.position
			lm /= float(musk.size())
			var fc := Vector2.ZERO
			var fa := _alive(foes)
			for o in fa:
				fc += o.position
			if not fa.is_empty():
				ld = (fc / float(fa.size()) - lm).normalized()
				if ld == Vector2.ZERO:
					ld = front
				lp = Vector2(-ld.y, ld.x)
			half = 0.0
			for u in musk:
				half = maxf(half, absf((u.position - lm).dot(lp)))
		for o in _alive(foes):
			var f: float = (o.position - lm).dot(ld)
			if fwd.has(o) and float(fwd[o]) > 0.0 and f <= 0.0 and not crossed.has(o):
				crossed[o] = "flank" if absf((o.position - lm).dot(lp)) > half + 30.0 else "front"
			fwd[o] = f
			if not reached.has(o):
				for c in _alive(guns):
					if o.position.distance_to(c.position) < 70.0:
						reached[o] = crossed.get(o, "front")
						if first < 0.0 and contact_t >= 0.0:
							first = g.clock - contact_t
						break
		if _alive(foes).is_empty() or _alive(wave).is_empty():
			break
		# (the Brood keeps coming)
		if Engine.get_physics_frames() % 60 == 0:
			for o in _alive(foes):
				if o.order == "idle" and o.target == null:
					o.cmd_move(target, true)
	var flank := 0
	for o in reached:
		if reached[o] == "flank":
			flank += 1
	var x := {"sc": sc, "run": r, "crown_value": int(cv), "brood_value": int(bv), "foes": foes.size(),
		"contact": snappedf(contact_t, 0.1), "reached": reached.size(), "flank": flank, "first": snappedf(first, 0.1),
		"guns_lost": n_guns - _alive(guns).size(), "killed": int(float(g.stats[0]["value_killed"]) - k0),
		"lost": int(float(g.stats[1]["value_killed"]) - l0), "crown_left": int(_value(wave)), "brood_left": int(_value(foes)),
		"crossed_flank": crossed.values().filter(func(v) -> bool: return v == "flank").size(), "crossed": crossed.size()}
	res.append(x)
	print("  %s run %d: %s" % [sc, r, str(x)])
