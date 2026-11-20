extends SceneTree
## Pictures of the Gun Crewman (gun-crew-fetch, docs/gun_crew_fetch.md): no haulers, a Field Cannon queued at the Foundry;
## he comes out, walks to the Horse Breeder, takes the horse on the leash, leads it back, hitches it, goes back in, and
## the cannon rolls out drawn by that horse. Frames every 0.5 s of game time for a film (tools: ffmpeg/gif).
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --fixed-fps 30 --script res://tools/shot_gun_crew_fetch.gd -- <outdir>
var out := ""
var main: Node
var t := 0.0
var g
var started := false
var fails := 0
var origin := Vector2i(-1, -1)
var hall: Building
var fdy: Building
var br: Building
var far_br: Building
var gate: Building
var lone_max := 0.0          # the farthest a horse kept for a gun was ever from its building walking there alone
var lone_what := ""


func _initialize() -> void:
	out = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out + "/film")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _process(_delta: float) -> bool:
	t += _delta
	if t > 0.2 and main.game == null:
		main.start({"map": "hollowfen", "seed": 4242, "slots": [
			{"who": "you", "faction": "crown", "colour": 0, "side": 0},
			{"who": "easy", "faction": "brood", "colour": 1, "side": 1}]})
		return false
	if main.game == null:
		return false
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	if not started and t > 1.0:
		started = true
		for ai in g.ais:
			ai.process_mode = Node.PROCESS_MODE_DISABLED
		_run()
	return false


func _unused_physics(_delta: float) -> bool:
	# THE RULE: a horse never walks to a building by itself (its last steps to the hitch spot excepted: HAUL.reach)
	if g != null and started:
		for h in g.horses_of(0):
			if h.into is Building and h.hitch_p == Vector2.INF and h.leader == null and is_instance_valid(h.into):
				var d: float = (h.into as Building).edge_distance(h.position)
				if d > lone_max:
					lone_max = d
					lone_what = "%s at %.0f px from the %s" % [h.coat, d, (h.into as Building).kind]
	return false


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func wait(sec: float) -> void:
	var end: float = g.clock + sec
	while g.clock < end:
		await physics_frame


func wait_for(cond: Callable, sec: float) -> bool:
	var end: float = g.clock + sec
	while g.clock < end:
		if cond.call():
			return true
		await physics_frame
	return cond.call()


func at(dx: float, dy: float) -> Vector2:
	return Vector2(origin) * Defs.TILE + Vector2(dx, dy)


func _open_area(w: int, h: int) -> Vector2i:
	var starts: Array = []
	for b in g.buildings:
		starts.append(b.center())
	for y in range(4, g.H - h - 4):
		for x in range(4, g.W - w - 4):
			var ok := true
			var h0: int = g.height[g.idx(Vector2i(x, y))]
			for yy in h:
				for xx in w:
					var c := Vector2i(x + xx, y + yy)
					if g.solid[g.idx(c)] != 0 or g.ramp[g.idx(c)] != 0 or g.height[g.idx(c)] != h0:
						ok = false
						break
				if not ok:
					break
			if not ok:
				continue
			var p: Vector2 = g.cell_center(Vector2i(x + w / 2, y + h / 2))
			for s in starts:
				if p.distance_to(s) < 700.0:
					ok = false
			if ok:
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func crews() -> Array:
	return g.units.filter(func(u: Unit) -> bool: return u.team == 0 and not u.dead and u.kind == "gun_crewman")


func guns(k: String) -> Array:
	return g.units.filter(func(u: Unit) -> bool: return u.team == 0 and not u.dead and u.kind == k)


func _clear() -> void:
	for h in g.horses_of(0).duplicate():
		g.consume_unit(h)
	for u in g.units.duplicate():
		if u.team == 0 and (Defs.HARNESSED.has(u.kind) or u.kind == "gun_crewman"):
			g.consume_unit(u)
	for b in [br, far_br, fdy]:
		if b:
			b.queue.clear()
			b.kits.clear()
			b.prod_t = 0.0
	await physics_frame


## A spare horse standing by breeder b.
func _spare(b: Building) -> Unit:
	var h: Unit = g._add_unit("horse", 0, b.center() + Vector2(0, b.rect().size.y * 0.5 + 20))
	h.graze_at = h.position
	return h


## Queue gun k at the Foundry, with its build time cut short (the horse is what is tested).
func _queue(k: String) -> int:
	check(g.train(fdy, k) == "", "%s queued" % k)
	return int(fdy.kit_at(fdy.queue.size() - 1).get("rid", 0))



func _snap(name: String) -> void:
	await process_frame
	await process_frame
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, name])


func _run() -> void:
	origin = _open_area(32, 20)
	if origin.x < 0:
		print("no open ground")
		quit(1)
		return
	g.players[0]["gold"] = 50000
	g.players[0]["res2"] = 5000
	for u in g.units.duplicate():
		if u.position.distance_to(at(520, 320)) < 1200.0:
			g.consume_unit(u)
	await physics_frame
	g._add_building("cottage", 0, origin + Vector2i(1, 16), true)
	hall = g._add_building("town_hall", 0, origin + Vector2i(1, 1), true)
	g._add_building("barracks", 0, origin + Vector2i(1, 9), true)
	fdy = g._add_building("foundry", 0, origin + Vector2i(9, 8), true)
	br = g._add_building("horse_breeder", 0, origin + Vector2i(16, 2), true)
	for b in g.buildings:
		if b.team == 0:
			b.supply()
	fdy.rally = at(380, 640)
	g._astar_dirty = true
	g.reveal = true
	await physics_frame
	var h := _spare(br)
	g.camera.position = (fdy.center() + br.center()) * 0.5
	g.camera.zoom = Vector2(1.6, 1.6)
	g.train(fdy, "cannon")
	var n := 0
	var named := {}
	var t0: float = g.clock
	while g.clock < t0 + 60.0:
		var c := crews()
		var cm: Unit = c[0] if not c.is_empty() else null
		var key := ""
		if cm and h.leader == null and br.edge_distance(cm.position) > 120.0 and not named.has("1_out"):
			key = "1_out"
		elif h.leader == cm and cm != null and br.edge_distance(cm.position) < 80.0 and not named.has("2_leash"):
			key = "2_leash"
		elif h.leader == cm and cm != null and fdy.edge_distance(cm.position) < 200.0 and fdy.edge_distance(cm.position) > 80.0 and not named.has("3_lead"):
			key = "3_lead"
		elif is_instance_valid(h) and h.hitch_p != Vector2.INF and not named.has("4_hitched"):
			key = "4_hitched"
		if key != "":
			named[key] = true
			if key == "4_hitched":
				fdy.prod_t = maxf(fdy.prod_t, fdy.entry_time("cannon") - 2.0)
			await _snap(key)
		if int(g.clock * 2.0) != int((g.clock - 1.0 / 30.0) * 2.0):
			await _snap("film/%03d" % n)
			n += 1
		if not guns("cannon").is_empty() and not named.has("5_cannon"):
			for i in 30:
				await physics_frame
			named["5_cannon"] = true
			await _snap("5_cannon")
			break
		await physics_frame
	# a close look at him
	var cm2: Unit = g._add_unit("gun_crewman", 0, at(300, 520))
	cm2.order = "idle"
	var lab: Unit = g._add_unit("labourer", 0, at(340, 520))
	lab.auto_work = false
	g.camera.position = at(320, 510)
	g.camera.zoom = Vector2(4.0, 4.0)
	for i in 10:
		await physics_frame
	await _snap("6_crewman_beside_labourer")
	print("shots: ", named.keys(), " film frames ", n)
	quit(0)
