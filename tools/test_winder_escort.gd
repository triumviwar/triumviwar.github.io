extends SceneTree
## WINDERS ESCORT THE ARMY (docs/winder_escort.md, scripts/winder_escort.gd; the owner 2026-11-15 20:11-20:15).
## 1. A mixed attack-move (Clock Soldiers + 2 Winders, the Winders starting IN FRONT): the Winders escort, end behind
##    the army, never ahead of its front on the march, wind and mend in the fight, never charge (they keep their distance
##    from the enemy), and follow when the army is sent on without them in the selection.
## 2. WIND UP on one unit and on a group; 3. Shift-queued behind a move; 4. a group of only Winders keeps its plain
##    attack-move; 5. right-click on an enemy with the Winders in the selection: they escort, the soldiers attack.
##   godot --headless --fixed-fps 30 --script res://tools/test_winder_escort.gd
##   (FILM=1: pictures to docs/shots/winder_escort/, needs a display: xvfb-run -a godot --rendering-driver opengl3
##    --resolution 1280x720 --script res://tools/test_winder_escort.gd)
const U := preload("res://tools/gear_test_util.gd")
const N := 8
var fails := 0
var film := OS.get_environment("FILM") == "1"
const SHOTS := "res://docs/shots/winder_escort/"


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-72s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _open_near(g: Game, p: Vector2) -> Vector2:
	var c := g.cell_of(g.on_map(p))
	if g.is_free(c):
		return g.cell_center(c)
	return g.cell_center(g.nearest_free(c, 6))


## A straight stretch of open, walkable ground `len` px long and 300 px wide, off the gear field, far from `avoid`.
func _lane(g: Game, avoid: Vector2, len: float) -> Array:
	var sz := Vector2(g.W * Defs.TILE, g.H * Defs.TILE)
	var best: Array = []
	var bd := -INF
	for yi in range(4, 40):
		var y := sz.y * yi / 44.0
		for xi in range(2, 20):
			var a := Vector2(sz.x * xi / 22.0, y)
			var b := a + Vector2(len, 0)
			if b.x > sz.x - 64 or y > sz.y - 200 or y < 200:
				continue
			var ok := true
			for p in [a, b, (a + b) * 0.5, a + Vector2(0, 80), a - Vector2(0, 80), b + Vector2(0, 80), b - Vector2(0, 80), (a + b) * 0.5 + Vector2(0, 80), (a + b) * 0.5 - Vector2(0, 80)]:
				if not g.is_free(g.cell_of(p)) or g.in_field(0, p) or p.distance_to(avoid) < 700.0:
					ok = false
					break
			if not ok or not g.line_clear(a, b, 12.0) or not g.line_clear(a + Vector2(0, 60), b + Vector2(0, 60), 12.0) \
					or not g.line_clear(a - Vector2(0, 60), b - Vector2(0, 60), 12.0):
				continue
			var dd := minf(a.distance_to(avoid), b.distance_to(avoid))
			if dd > bd:
				bd = dd
				best = [a, b]
	return best


func _mid(us: Array) -> Vector2:
	var c := Vector2.ZERO
	var n := 0
	for u in us:
		if is_instance_valid(u) and not u.dead:
			c += u.position
			n += 1
	return c / maxf(1, n)


func _run() -> void:
	Settings.charge_bars = true
	var g := U.make(root)
	await process_frame
	await process_frame
	g.human = 0
	g.players[0]["gold"] = 5000
	var hall := U.hall(g, 0)
	for u in g.units.duplicate():
		u.position = hall.center() + Vector2(-99999, -99999)     # (everyone else out of the way)
	var lane := _lane(g, hall.center(), 1000.0)
	check("found an open lane off the gear field", not lane.is_empty())
	if lane.is_empty():
		return _end()
	var a: Vector2 = lane[0]
	var b: Vector2 = lane[1]
	var fwd := (b - a).normalized()
	print("lane %s -> %s" % [a, b])
	if film:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOTS))
	# ---- 1. the army: run down and hurt; the Winders IN FRONT of it (where the owner's ran ahead)
	var army: Array = []
	for i in N:
		var p := a + Vector2(-(i % 4) * 26.0, (i / 4) * 30.0 - 15.0)
		var s: Unit = g._add_unit("clock_soldier", 0, _open_near(g, p))
		s.wind = 0.35 + 0.05 * (i % 3)
		s.hp = s.max_hp * 0.7
		army.append(s)
	var w1: Unit = g._add_unit("winder", 0, _open_near(g, a + Vector2(70, -20)))
	var w2: Unit = g._add_unit("winder", 0, _open_near(g, a + Vector2(70, 20)))
	for w in [w1, w2]:
		w.wind = 1.0
		w.auto_work = false
	# the enemy at the far end: Crown Musketeers standing (no computer runs here: they fight what comes in reach)
	var foes: Array = []
	for i in 4:
		var f: Unit = g._add_unit("musketeer", 1, _open_near(g, b + Vector2(40 + (i % 2) * 26.0, (i / 2) * 40.0 - 20.0)))
		foes.append(f)
	U.step(g, 0.3)
	var sel: Array = army + [w1, w2]
	g.group_move(sel, b, true)         # (A + click: the attack-move the owner gave)
	check("a mixed attack-move: the Winders escort (order escort)", w1.order == "escort" and w2.order == "escort", "%s / %s" % [w1.order, w2.order])
	check("the soldiers attack-move as before", army.all(func(s: Unit) -> bool: return s.order == "amove"), army[0].order)
	var ahead := 0
	var samples := 0
	var march_ahead_max := -INF
	var wind_fight := 0
	var mend_fight := 0
	var charged := 0
	var fought := 0
	var min_foe := INF
	var t := 0.0
	var frame := 0
	var start_wind := 0.0
	for s in army:
		start_wind += s.wind
	while t < 45.0:
		U.step(g, 0.1)
		t += 0.1
		var alive := army.filter(func(s: Unit) -> bool: return is_instance_valid(s) and not s.dead)
		if alive.is_empty():
			break
		var front := -INF
		for s in alive:
			front = maxf(front, (s.position - a).dot(fwd))
		var fight := foes.any(func(f: Unit) -> bool: return is_instance_valid(f) and not f.dead and alive.any(func(s: Unit) -> bool: return s.target == f))
		for w in [w1, w2]:
			if w.dead:
				continue
			var wp: float = (w.position - a).dot(fwd)
			if t > 4.0 and not fight:
				samples += 1
				if wp > front + 8.0:
					ahead += 1
				march_ahead_max = maxf(march_ahead_max, wp - front)
			if fight:
				if w.work == "repairing":
					wind_fight += 1
				if w.target != null and is_instance_valid(w.target) and w.target is Unit and w.target.team == 1:
					fought += 1
				for f in foes:
					if is_instance_valid(f) and not f.dead:
						min_foe = minf(min_foe, f.edge_distance(w.position) - w.radius)
		if film and frame < 14 and int(round(t * 10.0)) % 25 == 0:
			await _shot(g, _mid(alive + [w1, w2]), SHOTS + "amove_%02d.png" % frame)
			frame += 1
		if not foes.any(func(f: Unit) -> bool: return is_instance_valid(f) and not f.dead) and t > 10.0 and alive.all(func(s: Unit) -> bool: return s.order == "idle"):
			break
	var alive2 := army.filter(func(s: Unit) -> bool: return is_instance_valid(s) and not s.dead)
	var mean_w := 0.0
	for s in alive2:
		mean_w += s.wind
	mean_w /= maxf(1, alive2.size())
	print("march: %d samples, %d ahead of the front (worst %.0f px past it); fight: %d winding/mending samples, fought %d, nearest an enemy came %.0f px; %d soldiers left, mean charge %.2f (start %.2f)"
			% [samples, ahead, march_ahead_max, wind_fight, fought, min_foe, alive2.size(), mean_w, start_wind / N])
	check("on the march the Winders are never ahead of the army's front (<= 3%)", samples > 20 and ahead <= samples * 0.03, "%d of %d" % [ahead, samples])
	check("they wind and mend in the fight", wind_fight > 10, str(wind_fight))
	check("they never charge: no fighting, kept off the enemy (> 20 px)", fought == 0 and min_foe > 20.0, "fought %d, closest %.0f px" % [fought, min_foe])
	check("the army's charge went up", mean_w > start_wind / N + 0.15, "%.2f" % mean_w)
	check("still escorting when the attack-move is over", w1.order == "escort" and w2.order == "escort", "%s / %s" % [w1.order, w2.order])
	for s in alive2:
		s.wind = 1.0          # (all wound and mended: nobody needs them, so they take their place behind)
		s.hp = s.max_hp
	U.step(g, 5.0)
	var c := _mid(alive2)
	var behind := 0
	for w in [w1, w2]:
		if (w.position - c).dot(fwd) < 0.0:
			behind += 1
	check("at the end they stand behind the army, not in front", behind == 2, "%d of 2 behind (%.0f, %.0f px)" % [behind, (w1.position - c).dot(fwd), (w2.position - c).dot(fwd)])
	check("...side by side, not on top of each other", w1.position.distance_to(w2.position) > 12.0, "%.0f px" % w1.position.distance_to(w2.position))
	if film:
		await _shot(g, _mid(alive2 + [w1, w2]), SHOTS + "amove_end.png")
	# ---- the army sent on (only the soldiers selected): the Winders follow
	var back := a + Vector2(200, 0)
	g.group_move(alive2, back, false)
	U.step(g, 2.0)
	var trail := w1.order == "escort" and w2.order == "escort" and w1.velocity.length() > 10.0
	U.step(g, 20.0)
	var c2 := _mid(alive2)
	check("the army sent on alone: the Winders follow it", trail and w1.position.distance_to(c2) < 160.0 and w2.position.distance_to(c2) < 160.0,
			"walking %s, %.0f / %.0f px from its middle" % [trail, w1.position.distance_to(c2), w2.position.distance_to(c2)])
	check("...and end on the far side from where it came (behind it)", (w1.position - c2).dot(-fwd) < 0.0 or (w2.position - c2).dot(-fwd) < 0.0,
			"%.0f / %.0f" % [(w1.position - c2).dot(-fwd), (w2.position - c2).dot(-fwd)])
	# ---- 2. WIND UP on one unit
	var s1: Unit = alive2[0]
	var w3: Unit = g._add_unit("winder", 0, _open_near(g, s1.position + Vector2(-150, 60)))
	w3.auto_work = false
	U.step(g, 0.2)
	g.wind_up_order([w3], [s1])
	check("WIND UP on one unit: escort", w3.order == "escort" and w3.esc_group == [s1], w3.order)
	s1.wind = 0.3
	s1.cmd_move(s1.position + Vector2(-400, 0))
	var wound_walk := 0
	for i in 120:
		U.step(g, 0.1)
		if w3.work == "repairing" and w3.velocity.length() > 10.0:
			wound_walk += 1
	check("...he winds it walking behind it, and it is wound", wound_walk > 10 and s1.wind > 0.8, "%d samples, charge %.2f" % [wound_walk, s1.wind])
	check("...and stays with it", w3.order == "escort" and w3.position.distance_to(s1.position) < 120.0, "%.0f px" % w3.position.distance_to(s1.position))
	# ---- 2b. WIND UP on a group (the Winders and the army selected)
	for s in alive2:
		s.wind = 0.4
	g.wind_up_order([w1, w2, w3], alive2)
	check("WIND UP on a group: all three escort it", [w1, w2, w3].all(func(w: Unit) -> bool: return w.order == "escort" and w.esc_group.size() == alive2.size()))
	U.step(g, 1.5)
	var pats := {}
	for w in [w1, w2, w3]:
		if w.esc_patient != null:
			pats[w.esc_patient] = true
	check("...spread: no two on one unit", pats.size() == [w1, w2, w3].filter(func(w: Unit) -> bool: return w.esc_patient != null).size(), "%d patients" % pats.size())
	U.step(g, 25.0)
	check("...and the group is wound", alive2.all(func(s: Unit) -> bool: return s.wind > 0.9), ", ".join(alive2.map(func(s: Unit) -> String: return "%.2f" % s.wind)))
	# ---- 3. Shift-queued behind a move
	var spot := _open_near(g, w3.position + Vector2(0, 90))
	w3.cmd_move(spot)
	g.group_move([w3] + alive2, alive2[0].position + Vector2(100, 0), false, true)
	check("Shift: the escort waits behind his move", w3.order == "move" and w3.queue.size() == 1 and w3.queue[0]["o"] == "escort", "%s, queue %s" % [w3.order, str(w3.queue.map(func(o): return o["o"]))])
	for i in 100:
		U.step(g, 0.1)
		if w3.order == "escort":
			break
	check("...then he escorts", w3.order == "escort", w3.order)
	# ---- 4. only Winders: plain orders, unchanged
	g.group_move([w1, w2], w1.position + Vector2(0, 150), true)
	check("a group of only Winders keeps its plain attack-move", w1.order == "amove" and w2.order == "amove", "%s / %s" % [w1.order, w2.order])
	g.group_move([w1, w2], w1.position + Vector2(0, -150), false)
	check("...and its plain move", w1.order == "move" and w2.order == "move", "%s / %s" % [w1.order, w2.order])
	# ---- 5. a right-click on an enemy, Winders in the selection
	var foe: Unit = g._add_unit("musketeer", 1, _open_near(g, c2 + Vector2(300, 0)))
	U.step(g, 0.2)
	g.smart_command([w1] + alive2, foe.position)
	check("right-click on an enemy: the soldiers attack it, the Winder escorts", w1.order == "escort" and alive2.all(func(s: Unit) -> bool: return s.order == "attack"),
			"%s / %s" % [w1.order, alive2[0].order])
	# ---- 6. a STOP ends it
	w1.cmd_stop()
	check("STOP ends the escort", w1.order == "idle" and w1.esc_group.is_empty(), w1.order)
	_end()


func _shot(g: Game, at: Vector2, path: String) -> void:
	g.camera.position = at
	g.camera.zoom = Vector2(2.0, 2.0)
	await process_frame
	await process_frame
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(path))


func _end() -> void:
	print("RESULT %s (%d failed)" % ["PASS" if fails == 0 else "FAIL", fails])
	quit(1 if fails > 0 else 0)
