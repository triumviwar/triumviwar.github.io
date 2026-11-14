extends SceneTree
## Dragoons get back on their horses to move (the owner's playtest 2026-11-14 20:51).
##   godot --headless --fixed-fps 30 --script res://tools/test_dragoon_remount.gd
## A Dragoon (and an Armoured Dragoon) told to ATTACK dismounts to fire; a MOVE then must put him back in the saddle and
## ride, never leave the horse behind. Only the DISMOUNT command leaves him on foot as a Musketeer with his horse free.
var fails := 0
var g: Game
var main: Node


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func wait(s: float) -> void:
	var until := g.clock + s
	var frames := int(s * 30.0) + 60
	while g.clock < until and frames > 0:
		frames -= 1
		await physics_frame


func wait_for(f: Callable, s: float) -> bool:
	var until := g.clock + s
	var frames := int(s * 30.0) + 60
	while g.clock < until and frames > 0:
		frames -= 1
		if f.call():
			return true
		await physics_frame
	return f.call()


func _run() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.start({"map": "greenhold", "seed": 7, "slots": [
		{"who": "human", "faction": "crown", "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "hard", "faction": "brood", "colour": 1, "side": 1, "strategy": "balanced"}]})
	await process_frame
	await process_frame
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	for a in g.ais:
		a.process_mode = Node.PROCESS_MODE_DISABLED
	g.ais = g.ais.filter(func(a) -> bool: return a.team != 0)     # (the test harness gives the human's side a computer too: not in a real match)
	g.human = 0
	var hall: Building
	for b in g.buildings:
		if b.team == 0 and b.kind == "town_hall":
			hall = b
	for armoured in [false, true]:
		var tag := "armoured " if armoured else ""
		var base: Vector2 = hall.center() + Vector2(14, 6) * Defs.TILE * (1 if not armoured else -1)
		base = g.cell_center(g.nearest_free(g.cell_of(base), 8))
		var d: Unit = g._add_unit("dragoon", 0, base)
		if armoured:
			d.armoured = true
		await physics_frame
		var foe_at: Vector2 = g.cell_center(g.nearest_free(g.cell_of(base + Vector2(6, 0) * Defs.TILE), 6))
		var foe: Unit = g._add_unit("raptor", 1, foe_at)
		foe.hp = 100000.0
		foe.max_hp = 100000.0
		foe.set_physics_process(false)
		await physics_frame
		var start_kind := d.kind
		check(d.is_mounted(), tag + "a Dragoon starts in the saddle (" + start_kind + ")")
		if armoured:
			g.group_move([d], foe.position, true)       # (the armoured one: an attack-move into range)
		else:
			d.give({"o": "attack", "e": foe})
		var on_foot := await wait_for(func() -> bool: return not d.is_mounted() and d.order in ["attack", "amove"], 12.0)
		check(on_foot, tag + "told to ATTACK he dismounts to fire")
		await wait(3.0)
		var horse: Unit = d.steed
		check(horse != null and is_instance_valid(horse), tag + "his horse is kept as his (steed set)")
		# the fight carries him away from where he got off: his horse trails him
		var drift: Vector2 = g.cell_center(g.nearest_free(g.cell_of(d.position + Vector2(0, 7) * Defs.TILE), 4))
		d.position = drift
		g.note_move(d)
		var follows := await wait_for(func() -> bool: return horse.position.distance_to(d.position) <= 3.2 * Defs.TILE, 8.0)
		check(follows, tag + "his horse walks after him when the fight carries him off (%.1f tiles)" % (horse.position.distance_to(d.position) / Defs.TILE))
		# and if it is still far off when the MOVE comes, he walks back to it
		var drift2: Vector2 = g.cell_center(g.nearest_free(g.cell_of(d.position + Vector2(0, -9) * Defs.TILE), 4))
		d.position = drift2
		g.note_move(d)
		var far: Vector2 = g.cell_center(g.nearest_free(g.cell_of(base - Vector2(12, 0) * Defs.TILE * (1 if not armoured else -1)), 8))
		g.group_move([d], far, false)
		var back_on := await wait_for(func() -> bool: return d.is_mounted(), 15.0)
		check(back_on, tag + "a MOVE while he fights on foot puts him back in the saddle (order %s, kind %s)" % [d.order, d.kind])
		await wait_for(func() -> bool: return d.position.distance_to(far) < 3.0 * Defs.TILE, 20.0)
		check(d.is_mounted() and d.position.distance_to(far) < 3.0 * Defs.TILE, tag + "and rides to the spot (%.0f px off)" % d.position.distance_to(far))
		var loose := g.units.filter(func(u) -> bool: return u.kind == "horse" and not u.dead and u.position.distance_to(base) < 8.0 * Defs.TILE and u.leader == null)
		check(loose.is_empty(), tag + "no horse left behind where he fought (%d)" % loose.size())
		# the player's own DISMOUNT: on foot for good, the horse free
		d.cmd_dismount()
		await wait_for(func() -> bool: return not d.is_mounted(), 5.0)
		print("  after DISMOUNT: kind %s auto_mount %s order %s ais %s" % [d.kind, d.auto_mount, d.order, g.ais.map(func(a): return a.team)])
		var far2 := far + Vector2(0, 5) * Defs.TILE
		g.group_move([d], g.cell_center(g.nearest_free(g.cell_of(far2), 6)), false)
		await wait(4.0)
		check(not d.is_mounted(), tag + "after the player's DISMOUNT a MOVE keeps him on foot (a Musketeer)")
		foe.hp = 0.0
		foe.die() if foe.has_method("die") else null
		await wait(1.0)
	print("dragoon remount: %d failures" % fails)
	quit(1 if fails > 0 else 0)
