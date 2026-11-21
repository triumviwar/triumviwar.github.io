extends SceneTree
## THE BROOD COMPUTER USES THE LINGERING SWAMP (brood-mother-uproot, docs/brood_mother_uproot.md): a raid of three Clock
## Soldiers strikes at its rooted Mother (its army none): she gets up and fights; meanwhile her Rootmaw waits on the
## lingering swamp, rooted; the raid dead, she roots again before the swamp runs out, and no Rootmaw lost its swamp.
##   godot --headless --fixed-fps 30 --script res://tools/test_brood_mother_uproot_ai.gd [-- broodlinger:off]
var main: Node
var t := 0.0
var g: Game
var started := false
var fails := 0
var ai: AIBroodNew
var bt := 1
var ft := 0


func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _process(_delta: float) -> bool:
	t += _delta
	if t > 0.2 and main.game == null:
		seed(5)
		main.start({"map": "glimmerdeep", "seed": 123537401, "slots": [
			{"who": "hard", "faction": "clockwork", "colour": 0, "side": 0, "strategy": "rush"},
			{"who": "hard", "faction": "brood", "colour": 1, "side": 1, "strategy": "economy"}]})
		return false
	if main.game == null:
		return false
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	if not started and t > 0.5:
		started = true
		for a in g.ais:
			if a is AIBroodNew:
				ai = a
				bt = a.team
			else:
				a.process_mode = Node.PROCESS_MODE_DISABLED
		ft = 1 - bt
		_run()
	return false


func wait(sec: float) -> void:
	var end: float = g.clock + sec
	while g.clock < end:
		await physics_frame


func _run() -> void:
	await wait(6.0)
	var q: Unit = BroodNew.queen(g, bt)
	for u in g.units:
		if u.team == ft:
			u.cmd_stop()
	var maw: Unit = null
	for u in g.units:
		if u.team == bt and u.kind == BroodNew.MAW and BroodNew.rooted(u):
			maw = u
	check(BroodNew.rooted(q) and maw != null, "the computer's Mother and a Rootmaw rooted")
	var lost0 := int(g.stats[bt].get("maw_lost_swamp", 0))
	var foes: Array = []
	var side := Vector2(BroodNew.drawn_r(q) + 30.0, 0)
	for i in 3:
		var u: Unit = g._add_unit("clock_soldier", ft, q.position + side + Vector2(0, (i - 1) * 24))
		u.cmd_attack(q)
		foes.append(u)
	var value := 0
	for u in foes:
		value += Game.unit_value(u)
	print("raid worth %d" % value)
	var up := false
	var waited := false
	var t0 := g.clock
	while g.clock - t0 < 25.0:
		await physics_frame
		if q.tesla_mode == "packed":
			up = true
		if is_instance_valid(maw) and maw.nb.has("wait"):
			waited = true
	check(up, "a raid worth %d strikes at her: she gets up to fight" % value)
	if BroodNew.linger_on:
		check(waited, "meanwhile her Rootmaw waits on her lingering swamp")
	for u in foes:
		if is_instance_valid(u) and not u.dead:
			u.take_damage(99999.0, null)
	var t1 := g.clock
	while g.clock - t1 < 70.0 and not BroodNew.rooted(q):
		await wait(0.5)
	check(BroodNew.rooted(q), "the raid over, she roots again (%.0f s)" % (g.clock - t1))
	await wait(4.0)
	var lost := int(g.stats[bt].get("maw_lost_swamp", 0)) - lost0
	if BroodNew.linger_on:
		check(lost == 0 and is_instance_valid(maw) and BroodNew.rooted(maw), "no Rootmaw lost its swamp (%d), hers still rooted" % lost)
	else:
		print("(switch off) Rootmaws that lost their swamp: %d" % lost)
	print("%d FAILED" % fails if fails > 0 else "ALL PASS")
	quit(1 if fails > 0 else 0)
