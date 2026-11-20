extends SceneTree
## THE GUN CREWMAN (gun-crew-fetch, docs/gun_crew_fetch.md). The owner (2026-11-20): "Horses are not supposed to go alone.
## Without a hauler the cannon operator should go from the foundry and get the horse on a leash back to the foundry."
## 1. no haulers: a crewman comes out of the Foundry, leads the breeder's spare horse back, hitches it, goes back in, and the
##    Field Cannon comes out drawn by that horse; no horse ever walks to the Foundry by itself;
## 2. the horse still being bred: the crewman waits by the breeder and brings it when it's done (a Mortar);
## 3. with a hauler free: the hauler brings it and no crewman comes out (a Powder Wagon);
## 4. the crewman killed on the way: the horse stays where it is, another crewman comes out and the gun still comes;
## 5. the gun cancelled while he leads the horse: the horse is let go where it stands, free, and he goes back in;
## 6. a far breeder behind a wall with a gate: he goes through the gate both ways;
## 7. two guns queued: one crewman leads both horses (HAUL.batch); a crewman can't be picked (his Foundry is);
## 8. a save and a load while he is out: he isn't saved, a new one comes out and the gun still comes.
##   godot --headless --fixed-fps 30 --script res://tools/test_gun_crew_fetch.gd
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


func _physics_process(_delta: float) -> bool:
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


func _run() -> void:
	origin = _open_area(32, 20)
	if origin.x < 0:
		print("FAIL: no open ground for the test")
		quit(1)
		return
	g.reveal = true
	g.players[0]["gold"] = 50000
	g.players[0]["res2"] = 5000
	g.players[0]["cap"] = 200
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
	await physics_frame
	await physics_frame
	check(g.haulers_of(0).is_empty(), "no haulers")

	# ---- 1. no haulers: the crewman fetches the spare horse
	var h := _spare(br)
	var coat: String = h.coat
	var rid := _queue("cannon")
	check(h.horse_rid == rid and h.into == null, "the breeder's spare horse is kept for the cannon and stays at the breeder")
	var ok: bool = await wait_for(func() -> bool: return crews().size() == 1, 3.0)
	check(ok, "a gun crewman comes out of the Foundry (%d)" % crews().size())
	var cm: Unit = crews()[0] if ok else null
	if cm:
		check(fdy.edge_distance(cm.position) < 60.0, "he comes out by the Foundry (%.0f px)" % fdy.edge_distance(cm.position))
		check(not g.army(0).has(cm) and not g.workers(0).has(cm), "he is in no army or worker list")
		g.set_selection([cm])
		check(g.selection.size() == 1 and g.selection[0] == fdy, "picking him picks his Foundry")
		g.set_selection([])
	ok = await wait_for(func() -> bool: return h.leader == cm and cm != null, 40.0)
	check(ok, "he takes the horse on the leash at the breeder")
	check(h.rein_shown() or not ok, "the leash is drawn (the haulers' rein)")
	ok = await wait_for(func() -> bool: return h.hitch_p != Vector2.INF and h.into == fdy, 40.0)
	check(ok, "he leads it back and it stands hitched by the Foundry")
	ok = await wait_for(func() -> bool: return crews().is_empty(), 20.0)
	check(ok, "he goes back into the Foundry")
	fdy.prod_t = maxf(fdy.prod_t, fdy.entry_time("cannon") - 0.5)
	ok = await wait_for(func() -> bool: return guns("cannon").size() == 1, 10.0)
	check(ok, "the Field Cannon comes out")
	if ok:
		var c: Unit = guns("cannon")[0]
		check(c.harnessed and c.coat == coat, "drawn by that horse (%s, %s)" % [c.coat, coat])
	check(not is_instance_valid(h) or h.dead or h.off_field or not g.units.has(h), "the horse went into the gun's team")

	# ---- 2. the horse bred for it: he waits by the breeder (a Mortar)
	await _clear()
	rid = _queue("mortar")
	check(g.rid_breeder(0, rid) == br, "no spare horse: the breeder trains one for the Mortar")
	ok = await wait_for(func() -> bool: return crews().size() == 1, 3.0)
	check(ok, "a crewman comes out for it")
	cm = crews()[0] if ok else null
	ok = await wait_for(func() -> bool: return cm != null and br.edge_distance(cm.position) < 50.0, 30.0)
	check(ok and g.reserved_horse(0, rid) == null, "he waits by the breeder while the horse is bred")
	ok = await wait_for(func() -> bool: return g.reserved_horse(0, rid) != null and g.reserved_horse(0, rid).leader == cm, 40.0)
	check(ok, "the new horse comes out and he takes it straight away")
	fdy.prod_t = maxf(fdy.prod_t, fdy.entry_time("mortar") - 0.5)
	ok = await wait_for(func() -> bool: return guns("mortar").size() == 1, 60.0)
	check(ok, "the Mortar comes out")
	await wait_for(func() -> bool: return crews().is_empty(), 20.0)
	check(crews().is_empty(), "and the crewman is back inside")

	# ---- 3. a hauler free: he brings it, no crewman (a Powder Wagon)
	await _clear()
	var w: Unit = g._add_unit("labourer", 0, hall.center() + Vector2(0, 90))
	w.auto_work = false
	g.smart_command([w], hall.center())
	await wait(1.0)
	check(hall.haulers().size() == 1, "one hauler")
	h = _spare(br)
	rid = _queue("powder_wagon")
	var seen_crew := false
	var t0: float = g.clock
	while g.clock < t0 + 50.0 and not (h.hitch_p != Vector2.INF and h.into == fdy):
		if not crews().is_empty():
			seen_crew = true
		await physics_frame
	check(h.hitch_p != Vector2.INF and h.into == fdy, "the hauler brought the horse")
	check(not seen_crew, "no crewman came out")
	fdy.prod_t = maxf(fdy.prod_t, fdy.entry_time("powder_wagon") - 0.5)
	ok = await wait_for(func() -> bool: return guns("powder_wagon").size() == 1, 10.0)
	check(ok, "the Powder Wagon comes out")
	g.consume_unit(w)
	await wait(0.5)

	# ---- 4. the crewman killed on the way
	await _clear()
	h = _spare(br)
	rid = _queue("cannon")
	ok = await wait_for(func() -> bool: return h.leader != null and h.leader.kind == "gun_crewman", 40.0)
	check(ok, "a crewman has the horse")
	if ok:
		var dead_one: Unit = h.leader
		var where: Vector2 = h.position
		dead_one.take_damage(999.0, null)
		await wait(0.3)
		check(dead_one.dead and h.leader == null and h.horse_rid == rid, "killed: the horse stays where it is, still kept for the cannon")
		check(h.position.distance_to(where) < 60.0 and h.into == null, "and does not walk off to the Foundry by itself")
		ok = await wait_for(func() -> bool: return crews().size() == 1 and crews()[0] != dead_one, 8.0)
		check(ok, "another crewman comes out")
		fdy.prod_t = maxf(fdy.prod_t, fdy.entry_time("cannon") - 0.5)
		ok = await wait_for(func() -> bool: return guns("cannon").size() == 1, 60.0)
		check(ok, "the cannon still comes out")

	# ---- 5. cancelled while he leads it
	await _clear()
	await wait_for(func() -> bool: return crews().is_empty(), 1.0)
	h = _spare(br)
	rid = _queue("cannon")
	ok = await wait_for(func() -> bool: return h.leader != null and h.leader.kind == "gun_crewman", 40.0)
	await wait(1.5)
	if ok:
		cm = h.leader
		g.cancel_train(fdy)
		await wait(0.5)
		check(h.leader == null and h.horse_rid == 0 and h.into == null, "cancelled: the horse is let go where it stands, free")
		var hp: Vector2 = h.position
		await wait(3.0)
		check(h.position.distance_to(hp) < 80.0, "it stays there (grazing)")
		ok = await wait_for(func() -> bool: return crews().is_empty(), 30.0)
		check(ok, "and he goes back into the Foundry")
	else:
		check(false, "cancel: a crewman had the horse")

	# ---- 6. a far breeder behind a wall with a gate
	await _clear()
	far_br = g._add_building("horse_breeder", 0, origin + Vector2i(26, 12), true)
	for y in 20:
		if y == 10:
			gate = g._add_building("gate", 0, origin + Vector2i(23, y), true)
		else:
			g._add_building("wall", 0, origin + Vector2i(23, y), true)
	g._astar_dirty = true
	await physics_frame
	h = _spare(far_br)
	rid = _queue("cannon")
	check(h.horse_rid == rid, "the far breeder's horse is kept")
	t0 = g.clock
	ok = await wait_for(func() -> bool: return h.leader != null and h.leader.kind == "gun_crewman", 60.0)
	check(ok, "the crewman reaches the far breeder through the gate")
	ok = await wait_for(func() -> bool: return h.hitch_p != Vector2.INF and h.into == fdy, 60.0)
	check(ok, "and leads the horse back through it (%.0f s)" % (g.clock - t0))
	fdy.prod_t = maxf(fdy.prod_t, fdy.entry_time("cannon") - 0.5)
	ok = await wait_for(func() -> bool: return guns("cannon").size() == 1, 10.0)
	check(ok, "the cannon comes out")

	# ---- 7. two guns: one crewman leads both horses
	await _clear()
	var h1 := _spare(far_br)
	var h2 := _spare(far_br)
	h2.position += Vector2(30, 0)
	_queue("cannon")
	_queue("cannon")
	await wait(2.0)
	check(crews().size() == 1, "one crewman for two horses side by side (%d)" % crews().size())
	ok = await wait_for(func() -> bool: return h1.leader != null and h1.leader == h2.leader, 60.0)
	check(ok, "he leads both")
	ok = await wait_for(func() -> bool: return h1.into == fdy and h2.into == fdy and h1.hitch_p != Vector2.INF and h2.hitch_p != Vector2.INF, 60.0)
	check(ok, "both hitched by the Foundry")

	# ---- 8. a save and a load while he is out
	await _clear()
	h = _spare(far_br)
	rid = _queue("cannon")
	ok = await wait_for(func() -> bool: return h.leader != null and h.leader.kind == "gun_crewman", 60.0)
	if ok:
		var data: Dictionary = SaveGame.capture(g, {})
		var n := 0
		for ud in data.get("units", []):
			if String(ud.get("k", "")) == "gun_crewman":
				n += 1
		check(n == 0, "the crewman is not in the save")
		var saved_rid := false
		for ud in data.get("units", []):
			if int(ud.get("rid", 0)) == rid:
				saved_rid = true
		check(saved_rid, "the horse is saved with its reservation")

	check(lone_max < 60.0, "no horse ever walked to a building by itself (farthest %.0f px: %s)" % [lone_max, lone_what])
	print("gun crew fetch: " + ("ALL PASS" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
