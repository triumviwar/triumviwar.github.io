extends SceneTree
## A SMALL RAID GETS A DEFENCE ITS SIZE (ai-fixes-a, docs/ai_fixes_a.md; the opponent review's "the whole army defends the
## base (12 units, 1,160) against a raid worth 150"). A staged scene: a Hard Clockwork computer (Balanced) against a Crown
## whose computer is off. Once the Clockwork's army at home is worth ARMY_MIN or more, RIDERS Horsemen ("cuirassier") ride into
## its base by a Cog Press and stay there (it is never caught: the bait).
##   godot --headless --fixed-fps 30 --script res://tools/test_cw_raid_size.gd -- [map:greenhold] [seed:5] [cwraidsize:off]
## Checks (FOR s after the raider comes): some of the army meets it (MET_MIN of value within NEAR px of a rider at once), and at
## most SHARE_MAX of the army's value is SENT at it (the army's own answer: the whole army, phase "defend", counts as all
## of it; else the group of defenders; units that stand near it at their gathering point anyway are not counted). With `cwraidsize:off` the second
## check is expected to fail (the whole army came): it prints the numbers either way.
const ARMY_MIN := 1100.0        # (its push is held back for the scene: the Crown computer is off, it would win by ~8:00)
const FOR := 25.0
const RIDERS := 5             # (a Horseman is worth 60 to the computer: 300, over the token raid's 150)
const NEAR := 450.0
const MET_MIN := 200.0
const SHARE_MAX := 0.7         # (a group worth twice the raid: 600 of ~1,100 here)
var fails := 0
var map := "greenhold"
var seed_ := 5


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split(":", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"map": map = kv[1]
			"seed": seed_ = int(kv[1])
	_run.call_deferred()


func _soldiers(g: Game) -> Array:
	return g.army(1).filter(func(u: Unit) -> bool: return not u.dead and not u.is_worker() and u.has_attack() and not u.is_air() \
		and u.kind != "powder_wagon")


func _value(ai, list: Array) -> float:
	var v := 0.0
	for u in list:
		v += float(ai._unit_value(u))
	return v


func _run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	seed(seed_)
	main.start({"map": map, "seed": seed_, "slots": [
		{"who": "hard", "faction": "crown", "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "hard", "faction": "clockwork", "colour": 1, "side": 1, "strategy": "balanced"}]})
	await process_frame
	await process_frame
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	var ai = null
	for a in g.ais:
		if a.team == 0:
			a.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			ai = a
	ai.peaceful = true          # (the scene: no push goes out, the army stays at home as between two pushes)
	var t_ready := -1.0
	var nx := 0.0
	while g.clock < 900.0 and not g.over:
		await physics_frame
		if g.clock < nx:
			continue
		nx = g.clock + 1.0
		var home: Array = _soldiers(g).filter(func(u: Unit) -> bool: return ai.push == null or not ai.push.has(u))
		if int(g.clock) % 60 == 0:
			print("%d s: home %d, push %s" % [int(g.clock), int(_value(ai, home)), "-" if ai.push == null else ai.push.phase])
		if _value(ai, home) >= ARMY_MIN and (ai.push == null or ai.push.phase == ""):
			t_ready = g.clock
			break
	check(t_ready > 0.0, "the Clockwork's army at home is worth %d or more (%s)" % [int(ARMY_MIN), "at %d s" % int(t_ready) if t_ready > 0.0 else "never"])
	if t_ready < 0.0:
		_end()
		return
	var press: Building = null
	var hall: Building = g.halls_of(1)[0]
	for b in g.buildings:
		if b.team == 1 and not b.dead and b.kind == "cog_press":
			if press == null or b.center().distance_to(hall.center()) > press.center().distance_to(hall.center()):
				press = b
	var spot: Vector2 = press.center() if press != null else hall.center()
	var riders: Array = []
	for i in RIDERS:
		riders.append(g._add_unit("cuirassier", 0, spot + Vector2(-80 + 40 * i, 40)))
	var raider: Unit = riders[0]
	print("the raid: %d Horsemen worth %d" % [RIDERS, int(_value(ai, riders))])
	var army0 := _value(ai, _soldiers(g))
	var most := 0.0
	var whole_s := 0.0
	var grp := 0.0
	var t0 := g.clock
	var next := t0
	while g.clock < t0 + FOR and not g.over:
		await physics_frame
		if g.clock < next:
			continue
		next += 0.5
		for r in riders:
			if is_instance_valid(r) and not r.dead:
				r.hp = r.max_hp
				r.cmd_move(spot + Vector2(randf_range(-120, 120), randf_range(-120, 120)))
		var near: Array = _soldiers(g).filter(func(u: Unit) -> bool: return riders.any(func(r) -> bool: return is_instance_valid(r) and u.position.distance_to(r.position) < NEAR))
		most = maxf(most, _value(ai, near))
		if ai.army_g.phase == "defend":
			whole_s += 0.5
		var sent: Array = ai.army_g.defenders.keys().filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)
		grp = maxf(grp, _value(ai, sent))
	var sent_most := army0 if whole_s > 0.0 else grp
	print("army %d; the whole army defended %.1f s; the most sent as a group %d; most near the raider at once %d" % [int(army0), whole_s, int(grp), int(most)])
	check(most >= MET_MIN, "the raider is met (%d of value near it at once, %d wanted)" % [int(most), int(MET_MIN)])
	check(sent_most <= army0 * SHARE_MAX, "no more than %d%% of the army is sent at it (%.0f%%)" % [int(SHARE_MAX * 100), 100.0 * sent_most / maxf(1.0, army0)])
	_end()


func _end() -> void:
	print("ALL PASS" if fails == 0 else "FAIL (%d)" % fails)
	quit(1 if fails > 0 else 0)
