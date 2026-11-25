extends SceneTree
## THE CROWN'S FIGHTS AT EQUAL VALUE, a set-piece bench (crown-micro, docs/crown_micro.md; the owner 2026-11-25: "a gigantic
## round of battles, micro training the AI"). No economy: a Crown army and a Brood army of the SAME value (Game.unit_value)
## meet; the Crown under its computer's fighting code (Hard: its wave loop, line, guns, screen, riders' hit and run,
## defence; and the crown-micro coaching unless `cmic:off`), the Brood under its units' own fighting (an attack-move at
## the Crown, the way its waves go in: the Brood computer is taken off so it builds nothing).
## Scenarios `<where>-<size>-<mix>`:
##   where  open  the Crown wave marches across the open middle toward the Brood's side; the Brood comes on head-on
##          home  the Crown army stands at home in front of its hall (its rally); the Brood walks at the hall (a defence)
##          ramp  the Crown wave goes up the Brood's main ramp; the Brood stands on HOLD at its top (a choke, uphill)
##          side  as open, but the Brood comes on from the wave's flank
##   size   s ~700, m ~1,600, l ~3,200 (the Crown army's value; the Brood's the same)
##   mix    raptor (Raptors only), mixed (2 Raptors : 1 Spitter : 1 Tyrant Challenger), late (mixed + Brutes),
##          spit (Spitters with a Raptor screen)
## Counts per fight (from first contact, at most `fight` s, default 90): value killed and lost, the share of each army left,
## the score (Crown share left - Brood share left: +1 a clean Crown win, -1 a clean loss).
##   godot --headless --fixed-fps 30 --path . --script res://tools/bench_crown_micro.gd -- [only:open-m-mixed,...|set:core]
##       [runs:3] [map:greenhold] [seed:0] [out:/abs/file.json] [shots:/abs/dir] [cmic:off ...]
## A measuring tool: it changes no rule.
var main: Node
var g: Game
var res: Array = []
var shots := ""

const SETS := {
	"core": ["open-m-raptor", "open-m-mixed", "open-m-late", "home-m-raptor", "home-m-mixed", "ramp-m-mixed",
		"side-m-mixed", "open-s-mixed", "open-l-mixed", "open-l-late", "open-m-spit", "home-l-late"],
	"quick": ["open-m-raptor", "open-m-mixed", "home-m-mixed", "open-l-late"],
}

const CROWN := {
	"s": {"musketeer": 8, "cannon": 1, "cuirassier": 2},
	"m": {"musketeer": 14, "cannon": 3, "cuirassier": 3, "mortar": 1},
	"l": {"musketeer": 26, "cannon": 5, "cuirassier": 4, "mortar": 2},
}
const MIX := {
	"raptor": ["raptor"],
	"mixed": ["raptor", "raptor", "spitter", "tyrant_challenger"],
	"late": ["raptor", "raptor", "spitter", "tyrant_challenger", "spitter", "brute"],
	"spit": ["spitter", "spitter", "raptor"],
}


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
	g.path_budget_us = 1 << 40
	if g.hud:
		g.hud.countdown = 0.0
		if shots != "":
			g.hud.visible = false
	if g.spectator:
		g.spectator.process_mode = Node.PROCESS_MODE_DISABLED
	if g.controls:
		g.controls.process_mode = Node.PROCESS_MODE_DISABLED
	paused = false
	for a in g.ais.duplicate():
		if a.team == 1:
			g.ais.erase(a)


func _ai(t: int):
	for a in g.ais:
		if a.team == t:
			return a
	return null


func _spawn(kind: String, t: int, p: Vector2) -> Unit:
	var c: Vector2i = g.nearest_free(g.cell_of(g.on_map(p)), 8)
	return g._add_unit(kind, t, g.cell_center(c))


func _alive(list: Array) -> Array:
	return list.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)


func _value(list: Array) -> float:
	var v := 0.0
	for u in _alive(list):
		v += float(Game.unit_value(u)) * clampf(u.hp / maxf(1.0, u.max_hp), 0.0, 1.0)
	return v


func _run() -> void:
	shots = _arg("shots", "")
	var only: Array = []
	var st := _arg("set", "")
	if st != "":
		only = SETS[st]
	else:
		only = Array(_arg("only", "open-m-mixed").split(","))
	var runs := int(_arg("runs", "3"))
	var map := _arg("map", "greenhold")
	var s0 := int(_arg("seed", "0"))
	var t0 := Time.get_ticks_msec()
	for sc in only:
		for r in runs:
			await _one(sc, s0 + r, map)
	var tot := {}
	for x in res:
		var k: String = x["sc"]
		if not tot.has(k):
			tot[k] = {"n": 0, "killed": 0, "lost": 0, "score": 0.0, "wins": 0}
		var t: Dictionary = tot[k]
		t["n"] += 1
		t["killed"] += x["killed"]
		t["lost"] += x["lost"]
		t["score"] += x["score"]
		t["wins"] += 1 if x["score"] > 0.0 else 0
	var all := {"n": 0, "killed": 0, "lost": 0, "score": 0.0, "wins": 0}
	for k in tot:
		var t: Dictionary = tot[k]
		print("TOTAL %-15s n %d  killed %d  lost %d  k/l %.2f  score %+.2f  crown won %d" % [k, t["n"], t["killed"], t["lost"],
			float(t["killed"]) / maxf(1.0, float(t["lost"])), t["score"] / float(t["n"]), t["wins"]])
		for f in ["n", "killed", "lost", "score", "wins"]:
			all[f] += t[f]
	print("ALL n %d killed %d lost %d k/l %.2f score %+.3f crown won %d  (%d s)" % [all["n"], all["killed"], all["lost"],
		float(all["killed"]) / maxf(1.0, float(all["lost"])), all["score"] / maxf(1.0, float(all["n"])), all["wins"],
		(Time.get_ticks_msec() - t0) / 1000])
	var out := _arg("out", "")
	if out != "":
		var f := FileAccess.open(out, FileAccess.WRITE)
		f.store_string(JSON.stringify({"args": " ".join(OS.get_cmdline_user_args()), "runs": res, "total": tot}, " "))
	quit(0)


func _one(sc: String, r: int, map: String) -> void:
	var parts := sc.split("-")
	var where := parts[0]
	var size := parts[1]
	var mix := parts[2]
	await _start(9100 + r * 31 + sc.hash() % 997, map)
	var ai = _ai(0)
	ai.line_ai()
	ai.peaceful = true
	await _until(g.clock + 1.0)
	var mid := Vector2(Game.W, Game.H) * Defs.TILE * 0.5
	var halls: Array = ai._halls()
	var hall: Vector2 = halls[0].center() if not halls.is_empty() else Vector2(g.starts[0]) * Defs.TILE
	var goal: Vector2 = Vector2(g.starts[1]) * Defs.TILE
	var to_goal: Vector2 = (goal - mid).normalized()
	var at: Vector2
	var front: Vector2
	if where == "home":
		var out_dir: Vector2 = (mid - hall).normalized()
		at = hall + out_dir * 260.0
		front = out_dir
	elif where == "ramp":
		var bm: Unit = null
		for u in g.units:
			if u.team == 1 and not u.dead and u.kind == "brood_mother":
				bm = u
		var top := Vector2.INF
		for b in g.buildings:
			if b.team == 1 and not b.dead:
				top = g.ramp_top(b)
				break
		goal = bm.position if bm != null else goal
		if top == Vector2.INF:
			top = goal.lerp(mid, 0.3) / Defs.TILE
		var topp: Vector2 = top * Defs.TILE
		front = (topp - goal).normalized()       # (out of the Brood's main, down the ramp)
		at = topp + front * 900.0
		front = -front                           # (the Crown faces up the ramp)
	else:
		at = mid - to_goal * 900.0
		front = to_goal
	var side := Vector2(-front.y, front.x)
	var wave: Array = []
	var comp: Dictionary = CROWN[size]
	var nm: int = comp.get("musketeer", 0)
	for i in nm:
		wave.append(_spawn("musketeer", 0, at + side * (float(i % 14) - 6.5) * 26.0 - front * float(i / 14) * 28.0))
	for k in ["cannon", "mortar"]:
		for i in int(comp.get(k, 0)):
			wave.append(_spawn(k, 0, at - front * (90.0 + (60.0 if k == "mortar" else 0.0)) + side * (float(i) - float(comp[k] - 1) * 0.5) * 70.0))
	for i in int(comp.get("cuirassier", 0)):
		wave.append(_spawn("cuirassier", 0, at - front * 50.0 + side * (i % 2 * 2 - 1) * (190.0 + float(i / 2) * 40.0)))
	var cv := _value(wave)
	var guns: Array = wave.filter(func(u: Unit) -> bool: return u.kind in ["cannon", "mortar"])
	var n_guns := guns.size()
	AICrownMicro.reset_counters()
	await _until(g.clock + 1.0)
	if where != "home":
		ai._attacking = true
		ai._wave_target = goal
		ai._wave_set.clear()
		for u in wave:
			ai._wave_set[u] = true
			u.cmd_move(goal, true)
	var kinds: Array = MIX[mix]
	var foes: Array = []
	var foe_at: Vector2
	match where:
		"home":
			foe_at = at + front * 1300.0
		"side":
			foe_at = at + side * 1100.0 + front * 250.0
		"ramp":
			foe_at = at + front * 1000.0
		_:
			foe_at = at + front * 1500.0
	var bv := 0.0
	var i := 0
	while bv < cv and i < 800:
		var k: String = kinds[i % kinds.size()]
		var f := _spawn(k, 1, foe_at + side * float((i % 14) - 7) * 30.0 + front * float(i / 14) * 30.0)
		foes.append(f)
		f.cmd_hold()
		bv += float(Game.unit_value(f))
		i += 1
	await _until(g.clock + (2.0 if where == "home" else 3.0))
	var target: Vector2 = hall if where == "home" else at
	if where != "ramp":
		for f in _alive(foes):
			f.cmd_move(target, true)
	var contact_t := -1.0
	var fight := float(_arg("fight", "90"))
	var t_end := g.clock + 150.0
	var k0 := 0.0
	var l0 := 0.0
	var next_shot := 0.0
	var shot_i := 0
	while g.clock < t_end and not g.over:
		await physics_frame
		if contact_t < 0.0 and Engine.get_physics_frames() % 5 == 0:
			for u in _alive(wave):
				for o in g.units_near(u.position, 260.0):
					if o.team == 1 and not o.dead:
						contact_t = g.clock
						break
				if contact_t >= 0.0:
					break
			if contact_t >= 0.0:
				t_end = g.clock + fight
				k0 = float(g.stats[0]["value_killed"])
				l0 = float(g.stats[1]["value_killed"])
				next_shot = g.clock + 2.0
		if shots != "" and contact_t >= 0.0 and g.clock >= next_shot and shot_i < 8:
			next_shot = g.clock + 6.0
			await _shot("%s_r%d_%02d.png" % [sc, r, shot_i], wave, foes)
			shot_i += 1
		if _alive(foes).is_empty() or _alive(wave).is_empty():
			break
		if where != "ramp" and Engine.get_physics_frames() % 60 == 0:
			for o in _alive(foes):
				if o.order == "idle" and o.target == null:
					o.cmd_move(target, true)
		if where == "ramp" and contact_t >= 0.0 and Engine.get_physics_frames() % 60 == 0:
			for o in _alive(foes):         # (the holders on the top go for the Crown once it is up with them)
				if o.order == "hold" and g.clock - contact_t > 8.0:
					o.cmd_move(at, true)
	var cl := _value(wave)
	var bl := _value(foes)
	var x := {"sc": sc, "run": r, "crown_value": int(cv), "brood_value": int(bv), "foes": foes.size(),
		"contact": snappedf(contact_t, 0.1), "secs": snappedf(g.clock - maxf(0.0, contact_t), 0.1),
		"killed": int(float(g.stats[0]["value_killed"]) - k0), "lost": int(float(g.stats[1]["value_killed"]) - l0),
		"crown_left": snappedf(cl / maxf(1.0, cv), 0.01), "brood_left": snappedf(bl / maxf(1.0, bv), 0.01),
		"score": snappedf(cl / maxf(1.0, cv) - bl / maxf(1.0, bv), 0.01),
		"guns_lost": n_guns - _alive(guns).size(), "micro": AICrownMicro.counters(0)}
	res.append(x)
	print("  %s run %d: %s" % [sc, r, str(x)])


func _shot(file: String, wave: Array, foes: Array) -> void:
	var c := Vector2.ZERO
	var n := 0
	for u in _alive(wave) + _alive(foes):
		c += u.position
		n += 1
	if n == 0:
		return
	var cam: Camera2D = g.camera
	cam.position = c / float(n)
	cam.zoom = Vector2(0.9, 0.9)
	cam.reset_smoothing()
	for k in 3:
		await process_frame
	var img := root.get_viewport().get_texture().get_image()
	img.save_jpg(shots.path_join(file.replace(".png", ".jpg")), 0.8)
