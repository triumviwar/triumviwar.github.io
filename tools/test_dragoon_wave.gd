extends SceneTree
## A DRAGOON WAVE KEEPS GOING (ai-lessons 1, docs/ai_lessons.md; battle-matrix-all found it): the Crown computer's wave
## of Dragoons rides at a Brood force; its Dragoons get off to fire. Before the fix each one getting off or back on
## dropped out of the wave's count, the wave fell under 6 supply and was sent home; they rode to and fro and never fired.
##  [kept]   the wave is still out 25 s after the first Dragoon got off
##  [fired]  the Dragoons hurt the Brood force (more than 300 health off it)
##   godot --headless --fixed-fps 30 --script res://tools/test_dragoon_wave.gd [-- ail:off]
var main: Node
var g: Game
var fails := 0


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _until(clock: float, cond := Callable()) -> void:
	while g.clock < clock and not g.over:
		await physics_frame
		if cond.is_valid() and cond.call():
			return


func _spawn(kind: String, t: int, p: Vector2) -> Unit:
	var c: Vector2i = g.nearest_free(g.cell_of(g.on_map(p)), 6)
	return g._add_unit(kind, t, g.cell_center(c))


func _run() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	seed(6162)
	main.start({"map": "greenhold", "seed": 6161, "slots": [
		{"who": "hard", "faction": "crown", "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "hard", "faction": "brood", "colour": 1, "side": 1, "strategy": "balanced"}]})
	await process_frame
	await process_frame
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	await _until(2.0)
	var ai: AI = null
	for a in g.ais:
		if a.team == 0:
			ai = a
		else:
			a.process_mode = Node.PROCESS_MODE_DISABLED
	var mid := Vector2(Game.W, Game.H) * Defs.TILE * 0.5
	var goal: Vector2 = Vector2(g.starts[1]) * Defs.TILE
	var to_goal: Vector2 = (goal - mid).normalized()
	var start_at: Vector2 = mid - to_goal * 450.0
	var wave: Array = []
	for i in 10:
		wave.append(_spawn("dragoon", 0, start_at + Vector2((i % 5) * 34, (i / 5) * 34)))
	var foes: Array = []
	var foe_at: Vector2 = mid + to_goal * 150.0
	for i in 8:
		var f := _spawn("spitter", 1, foe_at + Vector2((i % 4) * 24, (i / 4) * 24))
		f.cmd_move(start_at, true)      # (the Brood force comes at them)
		foes.append(f)
	var hp0 := 0.0
	for f in foes:
		hp0 += f.hp
	ai.peaceful = true
	ai._attack_at = 99999
	ai._attacking = true
	ai._wave_target = goal
	ai._wave_set.clear()
	for u in wave:
		ai._wave_set[u] = true
		u.cmd_move(goal, true)
	var off_t := -1.0
	var ended_t := -1.0
	while g.clock < 70.0 and not g.over:
		await physics_frame
		if off_t < 0.0:
			for u in wave:
				if is_instance_valid(u) and not u.dead and (u.kind == "musketeer" or u.order == "dismount"):
					off_t = g.clock
					break
		if OS.get_cmdline_user_args().has("debug") and Engine.get_physics_frames() % 30 == 0:
			var c := {}
			for u in wave:
				if is_instance_valid(u) and not u.dead:
					var k: String = u.kind + "/" + u.order
					c[k] = int(c.get(k, 0)) + 1
			print("DBG %.0f att %s ready %d %s" % [g.clock, ai._attacking, wave.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead and not ai._horse_coming(u)).size(), str(c)])
		if Engine.get_physics_frames() % 60 == 0:
			for f in foes:      # (the Brood force keeps coming at the Dragoons: its computer is off)
				if is_instance_valid(f) and not f.dead and f.target == null:
					for u in wave:
						if is_instance_valid(u) and not u.dead:
							f.cmd_move(u.position, true)
							break
		if ended_t < 0.0 and not ai._attacking:
			ended_t = g.clock
		if off_t > 0.0 and g.clock > off_t + float(OS.get_environment("DW_T") if OS.get_environment("DW_T") != "" else "25"):
			break
	var hp1 := 0.0
	for f in foes:
		if is_instance_valid(f) and not f.dead:
			hp1 += f.hp
	print("   first got off at %.0f s, the wave ended at %.0f s; Brood health %d -> %d" % [off_t, ended_t, int(hp0), int(hp1)])
	check(off_t > 0.0 and (ended_t < 0.0 or ended_t > off_t + 25.0), "[kept] the wave is still out 25 s after the first Dragoon got off")
	check(hp0 - hp1 > 300.0, "[fired] the Dragoons hurt the Brood force (%d health off it)" % int(hp0 - hp1))
	print("FAILS %d" % fails)
	print("ALL PASS" if fails == 0 else "SOME FAILED")
	quit(1 if fails > 0 else 0)
