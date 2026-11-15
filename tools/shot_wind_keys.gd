extends SceneTree
## The Clockwork army's wind-up keys in game (docs/wind_keys.md), in the CLOCKWORK LAB: for every unit with a key
## (WindKeyData.KEYS) two rows of eight facing the eight ways (left to right S SE E NE N NW W SW): the top row fully
## wound, the bottom row run down (wind 0: its key still); standing, then on a walk frame, at 2x and 4x. Then a turning
## film of the top row walking (frames for a gif: tools/wind_keys_gif.py).
##   <outdir>/<kind>_{idle,walk}_{2x,4x}.png, <outdir>/film/<kind>_NN.png
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_wind_keys.gd -- <outdir> [kinds]
var main: Node
var g
var out := ""
var t := 0.0
var started := false
var kinds: Array = []
const ORDER := [2, 1, 0, 7, 6, 5, 4, 3]     # facing octants (x right, y down): S SE E NE N NW W SW
const GAP := {"clock_soldier": 50.0, "springer": 64.0, "netter": 72.0, "pendulum": 84.0, "cuckoo": 60.0, "ticking_owl": 74.0}
const ROW := {"clock_soldier": 70.0, "springer": 84.0, "netter": 64.0, "pendulum": 100.0, "cuckoo": 60.0, "ticking_owl": 84.0}


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	out = a[0]
	kinds = a[1].split(",") if a.size() > 1 else WindKeyData.KEYS.keys()
	DirAccess.make_dir_recursive_absolute(out + "/film")
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
	paused = false
	if not started and t > 1.0:
		started = true
		_run()
	return false


func _snap(name: String, wait := 0.3) -> void:
	await create_timer(wait).timeout
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, name])


func _open_spot() -> Vector2:
	var hall: Building = null
	for b in g.buildings:
		if b.team == g.human and not b.dead:
			hall = b
			break
	for r in range(12, 120):
		for k in 16:
			var p: Vector2 = hall.center() + Vector2.from_angle(TAU * k / 16.0) * float(r) * Defs.TILE
			var c: Vector2i = g.cell_of(p)
			var ok := true
			for y in range(c.y - 7, c.y + 8):
				for x in range(c.x - 13, c.x + 14):
					var cc := Vector2i(x, y)
					if not g.in_map(cc) or g.solid[g.idx(cc)] != 0 or g.cliff[g.idx(cc)] != 0 or g.ramp[g.idx(cc)] != 0:
						ok = false
						break
				if not ok:
					break
			for bb in g.buildings:
				if not bb.dead and bb.center().distance_to(p) < 460.0:
					ok = false
			if ok:
				return p
	push_warning("no open spot")
	return hall.center() + Vector2(0, 300)


func _pose(us: Array, a: String, f: int, dt := 0.0) -> void:
	for u in us:
		u._set_anim(a, true)
		u.sprite.frame = posmod(f, u.sprite.hframes)
		if u._wkey != null:
			u._wkey.step(dt)          # (the units' own processing is off: their keys are stepped here)


func _run() -> void:
	for c in root.find_children("*", "CanvasLayer", true, false):
		c.visible = false
	g.reveal = true
	Settings.expansion_spots = false
	var spot := _open_spot()
	for u in g.units:
		if u.team == g.human and not u.dead and not u.is_worker():
			u.position = spot + Vector2(0, 1400)      # (the Lab's own army out of the picture)
	for kind in kinds:
		var gap: float = GAP.get(kind, 60.0)
		var rh: float = ROW.get(kind, 70.0)
		var rows: Array = []
		for row in 2:
			for i in 8:
				var u: Unit = g._add_unit(kind, g.human, spot + Vector2((float(i) - 3.5) * gap, -rh * 0.5 + rh * row))
				u.cmd_stop()
				rows.append(u)
		await create_timer(0.6).timeout
		for i in rows.size():
			var u: Unit = rows[i]
			u.set_physics_process(false)
			u.set_process(false)
			u.facing = Vector2.from_angle(float(ORDER[i % 8]) * PI / 4.0)
			u.wind = 1.0 if i < 8 else 0.0
		var top := spot + Vector2(0, 20 if kind == "pendulum" else 0)
		for pose in [["idle", 0], ["walk", 2]]:
			_pose(rows, pose[0], pose[1])
			g.camera.position = top + Vector2(0, -20)
			g.camera.zoom = Vector2(2.0, 2.0)
			await _snap("%s_%s_2x" % [kind, pose[0]])
			g.camera.zoom = Vector2(4.0, 4.0)
			g.camera.position = top + Vector2(-gap * 2.0, -20)
			await _snap("%s_%s_4x_l" % [kind, pose[0]])
			g.camera.position = top + Vector2(gap * 2.0, -20)
			await _snap("%s_%s_4x_r" % [kind, pose[0]])
		# a film: the top row walking (the strip stepped by hand), the keys turning live; full wind on the left half, the
		# right half (NW W SW + N) run down halfway
		for i in 8:
			(rows[i] as Unit).wind = 1.0 if i < 4 else 0.35
		g.camera.zoom = Vector2(2.0, 2.0)
		g.camera.position = top + Vector2(0, -20 - rh * 0.5)
		for f in 24:
			_pose(rows.slice(0, 8), "walk", f, 0.07)
			await _snap("film/%s_%02d" % [kind, f], 0.07)
		for u in rows:
			g.units.erase(u)
			u.queue_free()
		await create_timer(0.2).timeout
	quit()
