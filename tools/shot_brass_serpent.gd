extends SceneTree
## Screenshots of the BRASS SERPENT (scripts/brass_serpent.gd, docs/brass_serpent.md) in the CLOCKWORK LAB: Serpents of four
## sizes side by side; one crawling a curve; a Hydra; a Winder carrying a gear out to one; Clock Soldiers riding its body; a
## fight against Crown Musketeers (gears breaking off the tail, the wrecks); the card with its buttons. Plus frames of the
## fight for a GIF.
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1600x900 --fixed-fps 30 --script res://tools/shot_brass_serpent.gd -- <outdir>
var main: Node
var g
var out := ""
var t := 0.0
var started := false
var hold := false          # (the game held still: the bite frames)
const K := Defs.SERPENT_KIND


func _initialize() -> void:
	out = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out + "/gif")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _process(delta: float) -> bool:
	t += delta
	if t > 0.2 and main.game == null:
		main.start_lab()
		return false
	if main.game == null:
		return false
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = hold
	if not started and t > 1.0:
		started = true
		_run()
	return false


func _snap(name: String, wait := 0.5) -> void:
	if wait > 0.0:
		await create_timer(wait).timeout
	await process_frame
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, name])
	print("shot ", name)


func _frames(n: int) -> void:
	for i in n:
		await physics_frame


func _cam(p: Vector2, z: float) -> void:
	g.camera.position = p
	g.camera.zoom = Vector2(z, z)
	await _frames(20)


func _ui(on: bool) -> void:
	for c in root.find_children("*", "CanvasLayer", true, false):
		c.visible = on


func _open(p: Vector2) -> Vector2:
	var c: Vector2i = g.cell_of(g.on_map(p))
	if g.is_free(c):
		return g.cell_center(c)
	return g.cell_center(g.nearest_free(c, 8))


func _open_ground(hall: Building) -> Vector2:
	var near_b := func(c: Vector2i) -> bool:
		for bd in g.buildings:
			if not bd.dead and Vector2(bd.cell - c).length() < 13.0:
				return true
		return false
	var best := Vector2i(-1, -1)
	var bd2 := INF
	for y in range(14, Game.H - 14, 2):
		for x in range(16, Game.W - 16, 2):
			var c := Vector2i(x, y)
			var d := Vector2(c - hall.cell).length()
			if d >= bd2 or near_b.call(c):
				continue
			var ok := true
			for yy in range(-6, 7):
				for xx in range(-12, 13):
					var cc := c + Vector2i(xx, yy)
					if not g.in_map(cc) or not g._walkable(cc) or g.ramp[g.idx(cc)] != 0 or g.height[g.idx(cc)] != g.height[g.idx(c)] or g.solid[g.idx(cc)] != 0:
						ok = false
						break
				if not ok:
					break
			if ok:
				best = c
				bd2 = d
	return g.cell_center(best) if best.x >= 0 else hall.center() + Vector2(0, 260)


func _serp(p: Vector2, gears: Array, facing := Vector2.RIGHT) -> Unit:
	var u: Unit = g._add_unit(K, g.human, _open(p))
	u.facing = facing
	u.serp["g"] = gears.duplicate()
	BrassSerpent.apply(u)
	u.hp = u.max_hp
	BrassSerpent.reset_trail(u)
	u.cmd_stop()
	return u


func _n(size: String, n: int) -> Array:
	var a: Array = []
	for i in n:
		a.append(size)
	return a


func _gone(list: Array) -> void:
	for u in list:
		if is_instance_valid(u) and not u.dead:
			u.visible = false
			g.units.erase(u)
			u.queue_free()
	await _frames(5)


func _crawl(u: Unit, pts: Array) -> void:
	for p in pts:
		u.cmd_move(g.on_map(p))
		for i in 200:
			await physics_frame
			if u.position.distance_to(p) < 20.0 or u.order == "idle":
				break


func _run() -> void:
	_ui(false)
	var hall: Building = null
	for b in g.buildings:
		if b.team == g.human and b.kind == "clocktower":
			hall = b
	var at := _open_ground(hall)
	for u in g.units.duplicate():
		if u.team != g.human and not u.dead:
			u.visible = false
			u.die()
	print("stage at ", g.cell_of(at))
	# ---- four sizes, each crawled out straight so its body lies behind it
	var sizes := [_n("s", 2), _n("s", 6), _n("s", 6) + _n("b", 4), _n("s", 6) + _n("b", 10)]
	var made: Array = []
	for i in sizes.size():
		var u := _serp(at + Vector2(-260, -150 + i * 100), sizes[i])
		made.append(u)
	for u in made:
		u.cmd_move(g.on_map(u.position + Vector2(380, 0)))
	await _frames(240)
	await _cam(at + Vector2(-20, 0), 1.3)
	await _snap("sizes_2s_6s_6s4b_6s10b", 0.3)
	# (beside Clock Soldiers and a Pendulum, for the scale)
	var cmp: Array = []
	for j in 3:
		var cs0: Unit = g._add_unit("clock_soldier", g.human, _open(made[2].position + Vector2(-40 + j * 26, 46)))
		cs0.cmd_hold()
		cmp.append(cs0)
	var pd: Unit = g._add_unit("pendulum", g.human, _open(made[2].position + Vector2(70, 50)))
	pd.cmd_hold()
	cmp.append(pd)
	await _frames(30)
	await _cam(made[2].position + Vector2(-40, 20), 2.6)
	await _snap("closeup_6s4b", 0.3)
	await _gone(made + cmp)
	# ---- the eight ways it faces (each crawled a little that way, so its body lies behind it)
	var eight: Array = []
	for i in 8:
		var dir := Vector2.from_angle(TAU * i / 8.0)
		var ctr := at + Vector2(-240 + (i % 4) * 160, -70 + (i / 4) * 170)
		var e8 := _serp(ctr - dir * 60.0, _n("s", 4) + _n("b", 2), dir)
		e8.cmd_move(g.on_map(ctr + dir * 10.0))
		eight.append(e8)
	await _frames(150)
	await _cam(at + Vector2(0, 15), 1.9)
	await _snap("eight_ways", 0.3)
	# ---- the bite, frame by frame, in the five painted directions (W, SW, NW: mirrored)
	await _cam(at + Vector2(0, 15), 1.9)
	hold = true
	for fr in 4:
		for e8 in eight:
			e8.set_meta("serp_bite", g.clock - BrassSerpent.BITE_FRAME * (fr + 0.5))
			e8.queue_redraw()
		await process_frame
		await process_frame
		root.get_viewport().get_texture().get_image().save_png("%s/bite_frame_%d.png" % [out, fr])
		print("shot bite_frame_%d" % fr)
	hold = false
	await _gone(eight)
	# ---- a curve
	var c := _serp(at + Vector2(-300, 80), _n("s", 8) + _n("b", 4))
	await _crawl(c, [at + Vector2(-100, -80), at + Vector2(80, 60), at + Vector2(240, -60)])
	await _cam(at + Vector2(60, 0), 1.6)
	await _snap("crawling_a_curve", 0.0)
	# ---- Clock Soldiers riding its body
	var segs := BrassSerpent.segments(c)
	var riders: Array = []
	for k in [3, 6, 9]:
		var cs: Unit = g._add_unit("clock_soldier", g.human, segs[k][0])
		cs.position = segs[k][0]
		cs.wind = 0.3
		cs.cmd_hold()
		riders.append(cs)
	g.set_selection(riders)
	await _frames(60)
	await _cam(segs[6][0], 2.2)
	await _snap("clock_soldiers_winding_on_its_body", 0.3)
	g.set_selection([])
	await _gone(riders)
	# ---- a Hydra
	var a := _serp(at + Vector2(-200, -40), _n("s", 8))
	var b := _serp(at + Vector2(-140, 60), _n("s", 6) + _n("b", 2))
	g.serpent_order([a, b, c], "link")
	var hy: Unit = null
	for i in 400:
		await physics_frame
		for o in [a, b, c]:
			if is_instance_valid(o) and not o.dead and BrassSerpent.heads(o) >= 3:
				hy = o
		if hy != null:
			break
	if hy == null:
		for o in [c, a, b]:
			if is_instance_valid(o) and not o.dead:
				hy = o
				break
	await _crawl(hy, [hy.position + Vector2(240, 30)])
	await _cam(hy.position + Vector2(-80, 0), 1.8)
	await _snap("hydra_3_heads", 0.3)
	_ui(true)
	g.set_selection([hy])
	await _frames(20)
	await _snap("hydra_card", 0.6)
	g.set_selection([])
	_ui(false)
	await _gone([hy, a, b, c].filter(func(o) -> bool: return is_instance_valid(o)))
	# ---- a fight: a Serpent bites into a line of Crown Musketeers; gears break off the tail and lie as wrecks
	var fs := _serp(at + Vector2(-140, 0), _n("s", 6) + _n("b", 4))
	var foes: Array = []
	for i in 6:
		var m: Unit = g._add_unit("musketeer", 1, _open(at + Vector2(140, -100 + i * 40)))
		m.auto_work = false
		m.cmd_hold()
		foes.append(m)
	fs.cmd_move(at + Vector2(140, 0), true)
	g.camera.position = at
	g.camera.zoom = Vector2(1.5, 1.5)
	var k := 0
	for f in 720:
		await physics_frame
		if f % 6 == 0:
			g.camera.position = g.camera.position.lerp(fs.position + Vector2(80, 0), 0.5)
			await process_frame
			root.get_viewport().get_texture().get_image().save_png("%s/gif/f_%03d.png" % [out, k])
			k += 1
		if f == 420:
			await _snap("fight_vs_musketeers", 0.0)
		if fs.dead or foes.all(func(m: Unit) -> bool: return m.dead):
			break
	await _snap("fight_after", 0.0)
	print("after the fight: %d gears, hp %.0f/%.0f, wrecks %d" % [BrassSerpent.gears(fs).size(), fs.hp, fs.max_hp,
		g.bodies.filter(func(w) -> bool: return is_instance_valid(w) and String(w.kind).begins_with("serpent_gear")).size()])
	_ui(true)
	g.set_selection([fs] if not fs.dead else [])
	await _frames(20)
	await _snap("fight_card", 0.4)
	quit()
