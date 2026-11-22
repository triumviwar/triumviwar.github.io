extends SceneTree
## RIGHT-CLICK ON ONE OF OURS = FOLLOW (the owner 2026-11-22: "when I select a unit and I right click it on another unit
## it is supposed to stay following the unit until we give them another command"): the selection follows that unit
## wherever it goes, until another order; a right click on the ground is still a move.
##   godot --headless --fixed-fps 30 --script res://tools/test_follow_click.gd
var main: Node
var t := 0.0
var g
var started := false
var fails := 0


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


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func wait(sec: float) -> void:
	var end: float = g.clock + sec
	while g.clock < end:
		await physics_frame


func _run() -> void:
	var mine: Array = g.units.filter(func(u) -> bool: return u.team == 0 and not u.dead and u.kind != "horse")
	check(mine.size() >= 3, "three of ours to try with (%d)" % mine.size())
	var leader = mine[0]
	var a = mine[1]
	var b = mine[2]
	for u in [leader, a, b]:
		u.cmd_stop()
	g.smart_command([a, b], leader.position)
	await wait(0.2)
	check(a.order == "follow" and a.order_target == leader and b.order == "follow", "a right click on one of ours: both follow it (%s, %s)" % [a.order, b.order])
	var far: Vector2 = leader.position + Vector2(10, 6) * Defs.TILE
	leader.give({"o": "move", "p": g.on_map(far)}, false)
	await wait(14.0)
	check(a.order == "follow" and b.order == "follow", "they still follow after it walks off (%s, %s)" % [a.order, b.order])
	check(a.position.distance_to(leader.position) < 3.0 * Defs.TILE and b.position.distance_to(leader.position) < 3.0 * Defs.TILE,
		"they are with it where it went (%.0f, %.0f px)" % [a.position.distance_to(leader.position), b.position.distance_to(leader.position)])
	await wait(4.0)
	check(a.order == "follow", "they keep following while it stands (%s)" % a.order)
	g.smart_command([a], a.position + Vector2(-3, 0) * Defs.TILE)
	await wait(0.2)
	check(a.order != "follow", "a right click on the ground ends it: %s" % a.order)
	g.smart_command([leader], leader.position)
	await wait(0.2)
	check(leader.order != "follow", "a unit never follows itself (%s)" % leader.order)
	print("follow click: %d failures" % fails)
	quit(1 if fails > 0 else 0)
