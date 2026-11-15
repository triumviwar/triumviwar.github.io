extends SceneTree
## pendulum-high-swing (docs/pendulum_air.md): screenshots of the Pendulum's HIGH SWING at flyers in the CLOCKWORK LAB, in
## every view (the W ones are the E ones mirrored): a Balloon, a Swift, a Pterodactyl or a Skywing at each of its eight
## sides, the swing frozen on its frames 2 (the telegraph), 4 (THE HIT: the blade over its head) and 5; then a blow at a
## soldier on the ground (the low sweep is kept for it). Also a contact sheet of every view's hit frame (all_hits.png).
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_pendulum_high_swing.gd -- <outdir>
var main: Node
var g
var out := ""
var t := 0.0
var started := false
var hits: Array = []          # [label, Image] of every view's hit frame (the contact sheet)

const SIDES := [["s", Vector2.DOWN, "cuckoo"], ["se", Vector2(1, 1), "balloon"], ["e", Vector2.RIGHT, "pterodactyl"],
		["ne", Vector2(1, -1), "skywing"], ["n", Vector2.UP, "balloon"], ["nw", Vector2(-1, -1), "cuckoo"],
		["w", Vector2.LEFT, "skywing"], ["sw", Vector2(-1, 1), "pterodactyl"]]


func _initialize() -> void:
	out = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out)
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


func _shot() -> Image:
	await process_frame
	return root.get_viewport().get_texture().get_image()


func _wait(cond: Callable, limit: float) -> void:
	var w := 0.0
	while not cond.call() and w < limit:
		await process_frame
		w += 1.0 / 60.0


## The game stopped where it is for a screenshot (no hit flash), then let go.
func _frozen(name: String) -> Image:
	g.process_mode = Node.PROCESS_MODE_DISABLED
	for u in g.units:
		u.flash = 0.0
		if u._mat:
			u._mat.set_shader_parameter("flash", 0.0)
	await process_frame
	await process_frame
	var img: Image = await _shot()
	img.save_png("%s/%s.png" % [out, name])
	g.process_mode = Node.PROCESS_MODE_INHERIT
	return img


func _dummy(kind: String, p: Vector2) -> Unit:
	var u: Unit = g._add_unit(kind, 1, p)
	u.max_hp = 99999.0
	u.hp = 99999.0
	u.auto_work = false
	u.cmd_hold()
	u.hold_fire = true
	u.d = u.d.duplicate()
	u.d["damage"] = 0
	u.d["range"] = 1
	u.d["speed"] = 0
	return u


func _gone(u: Unit) -> void:
	if not is_instance_valid(u):
		return
	g.selection.erase(u)
	u.visible = false
	if not u.dead:
		u.die()
	u.visible = false


func _open_ground(hall: Building) -> Vector2:
	var best := Vector2i(-1, -1)
	var bd := INF
	for y in range(hall.cell.y - 34, hall.cell.y + 35):
		for x in range(hall.cell.x - 34, hall.cell.x + 35):
			var c := Vector2i(x, y)
			if not g.in_map(c) or c.x < 12 or c.y < 12 or c.x > Game.W - 12 or c.y > Game.H - 12:
				continue
			var d := Vector2(c - hall.cell).length()
			if d >= bd or d < 14.0:
				continue
			var ok := true
			for yy in range(-6, 7):
				for xx in range(-8, 9):
					var cc := c + Vector2i(xx, yy)
					if not g.in_map(cc) or not g._walkable(cc) or g.ramp[g.idx(cc)] != 0 or g.height[g.idx(cc)] != g.height[g.idx(c)] or g.solid[g.idx(cc)] != 0:
						ok = false
						break
				if not ok:
					break
			if ok:
				best = c
				bd = d
	return g.cell_center(best) if best.x >= 0 else hall.center() + Vector2(0, 260)


func _run() -> void:
	var hall: Building = null
	for b in g.buildings:
		if b.team == g.human and not b.dead and b.kind == "clocktower":
			hall = b
	for c in root.find_children("*", "CanvasLayer", true, false):
		c.visible = false
	g.reveal = true
	var open := _open_ground(hall)
	var pends: Array = g.units.filter(func(u: Unit) -> bool: return u.team == g.human and u.kind == Defs.PENDULUM and not u.dead)
	for u in g.units.filter(func(u: Unit) -> bool: return u.team == g.human and not u.dead and u.kind != "winder"):
		if not (u in pends):
			u.position = open + Vector2(700, 700)
	var pd: Unit = pends[0]
	for i in range(1, pends.size()):
		pends[i].position = open + Vector2(-300, 300)
	pd.position = open
	g.note_move(pd)
	pd.cmd_stop()
	g.camera.zoom = Vector2(2.6, 2.6)
	for sd in SIDES:
		var dir: Vector2 = (sd[1] as Vector2).normalized()
		var foe: Unit = _dummy(sd[2], pd.position + dir * 46.0)
		g.camera.position = pd.position + Vector2(dir.x * 18.0, -44.0)
		pd.facing = dir
		await create_timer(0.5).timeout
		Engine.time_scale = 0.2
		pd.cmd_attack(foe)
		for k in [1, 3, 4]:
			await _wait(func() -> bool: return String(pd.anim).begins_with("attack") and pd.frame_i == k, 20.0)
			var img: Image = await _frozen("%s_%s_%s_f%d" % [sd[0], sd[2], pd.anim, k + 1])
			if k == 3:
				hits.append(["%s %s" % [sd[0], pd.anim], img])
		print("%s at a %s: %s, %d flyers hit" % [sd[0], sd[2], pd.anim, pd.last_air_hits])
		Engine.time_scale = 1.0
		await _wait(func() -> bool: return pd.phase == "", 5.0)
		pd.cmd_stop()
		_gone(foe)
		await create_timer(0.3).timeout
	# ---- the ground: a soldier to the south, the low sweep
	var sol: Unit = _dummy("musketeer", pd.position + Vector2(0, 30))
	g.camera.position = pd.position + Vector2(0, -30)
	pd.facing = Vector2.DOWN
	await create_timer(0.4).timeout
	Engine.time_scale = 0.2
	pd.cmd_attack(sol)
	await _wait(func() -> bool: return String(pd.anim).begins_with("attack") and pd.frame_i == 3, 20.0)
	await _frozen("ground_s_%s_f4" % pd.anim)
	print("ground: %s" % pd.anim)
	Engine.time_scale = 1.0
	_contact_sheet()
	quit()


## Every view's hit frame, cropped round the Pendulum, in one picture.
func _contact_sheet() -> void:
	if hits.is_empty():
		return
	var vs := root.get_viewport().get_visible_rect().size
	var cw := 340
	var ch := 470
	var sheet := Image.create(cw * 4, ch * 2, false, Image.FORMAT_RGBA8)
	for i in hits.size():
		var img: Image = hits[i][1]
		var cx := int(vs.x * 0.5) - cw / 2
		var cy := int(vs.y * 0.5) - ch / 2 - 60
		sheet.blit_rect(img, Rect2i(cx, cy, cw, ch), Vector2i((i % 4) * cw, (i / 4) * ch))
	sheet.save_png("%s/all_hits.png" % out)
