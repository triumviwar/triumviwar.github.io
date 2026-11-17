extends SceneTree
## THE CROWN MIRROR (crown-v-crown-coach, docs/crown-v-crown-coach.md; scripts/ai_crown_mirror.gd):
##  1. AICrown.mirror() is on for a Crown computer against a Crown, off against the Brood and the Clockwork
##  2. THE RAIDER GETS AN ANSWER: an enemy Horseman among the labourers of a Crown with a Barracks and no soldier: a
##     Musketeer is queued within a few seconds
##  3. THE WAVE MARCHES AS ONE: a wave of 10 Musketeers strung out over the open ground closes up (the log's line, the
##     spread under SPREAD_MAX) before it goes on
##  4. THE TIMING KEEPS ITS TIMING: OPTIMAL's late greedy read keeps the Timing attack in the mirror
##  5. THE WINNER FINISHES: hunt_anyway over a token army only with a big army of its own; hunt_goal is a hall
##  6. THE SIDE AHEAD PRESSES (crown-mirror-coach): ahead of the enemy army it knows, the wave's supply bar comes down;
##     not while behind; the Siege push goes without its full kit while ahead; `cmcpress:off` keeps the bar
##  7. THE OUTLYING HALLS FIRST (crown-mirror-coach): an open hall out in the field before a walled one by the main; a hall
##     it was just beaten at is left; `cmctarget:off` gives the shared target
##   godot --headless --fixed-fps 30 --script res://tools/test_crown_mirror.gd
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


func _start(fa: String, fb: String, plan := "balanced") -> void:
	if main != null:
		main.queue_free()
		await process_frame
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	seed(5151)
	main.start({"map": "greenhold", "seed": 5151, "slots": [
		{"who": "hard", "faction": fa, "colour": 0, "side": 0, "strategy": plan},
		{"who": "hard", "faction": fb, "colour": 1, "side": 1, "strategy": "balanced"}]})
	await process_frame
	await process_frame
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false


func _ai(t: int):
	for a in g.ais:
		if a.team == t:
			return a
	return null


## crown-mirror-coach (docs/crown_mirror_coach.md): AICrownMirror.press, wave_target, press_siege.
func _press_and_target(ai, cm) -> void:

	g.clock = maxf(g.clock, cm.PRESS_FROM + 60.0)
	ai._attacking = false
	cm._was_attacking = false
	cm._wave_off_t = -99.0
	var mine: Array = []
	var home: Vector2 = Vector2(g.starts[0]) * Defs.TILE + Vector2(0, 160)
	for i in 18:
		mine.append(g._add_unit("musketeer", 0, g.cell_center(g.nearest_free(g.cell_of(home + Vector2(i * 20, 0)), 4))))
	# (nothing of the enemy seen lately, and its reckoning made small: the enemy's army we know of is small)
	ai.ch._seen.clear()
	ai.ch._last_army_t = g.clock
	var foes: Array = []
	ai._attack_at = 99
	cm.press()
	check(ai._attack_at < 99, "6. the side ahead presses: the wave's bar comes down to its army (%d supply)" % ai._attack_at)
	# behind: the enemy army seen lately is bigger
	for i in 20:
		var u: Unit = g._add_unit("musketeer", 1, Vector2(g.starts[1]) * Defs.TILE + Vector2(i * 20, 160))
		foes.append(u)
		ai.ch._seen[u] = [g.clock, u.position, float(Game.unit_value(u))]
	ai.ch._last_army_t = g.clock
	ai._attack_at = 99
	cm._press_said = -99.0
	cm.press()
	check(ai._attack_at == 99, "... not while the enemy army it knows is bigger (%d known)" % int(cm.foe_army()))
	check(not cm.press_siege(mine, 3), "... and the Siege push keeps its kit while behind")
	for u in foes:
		ai.ch._seen.erase(u)
		u.take_damage(99999.0, null)
	check(cm.press_siege(mine, 1), "... the Siege push goes without its full kit while ahead (1 gun)")
	cm.press_on = false
	ai._attack_at = 99
	cm.press()
	check(ai._attack_at == 99, "... `cmcpress:off`: the bar stands")
	cm.press_on = true
	# 7. the outlying hall first: a walled hall by the enemy's main and an open one out in the field
	var near_c: Vector2i = g.nearest_free(g.starts[1] + Vector2i(-8, 6), 6)
	var far_p: Vector2 = Vector2(g.starts[1]).lerp(Vector2(g.starts[0]), 0.55) * Defs.TILE
	var far_c: Vector2i = g.nearest_free(g.cell_of(far_p), 8)
	var walled: Building = g._add_building("town_hall", 1, near_c, true)
	var open: Building = g._add_building("town_hall", 1, far_c, true)
	for k in 6:
		g._add_building("wall", 1, g.nearest_free(near_c + Vector2i(-2 + k, -3), 3), true)
	cm._tgt = null
	cm._tgt_t = -99.0
	var tp: Vector2 = cm.wave_target(g.center_of_team(0))
	check(open != null and tp.distance_to(open.center()) < 4.0, "7. the wave goes for the open hall out in the field, not the walled one by the main (%s)" % str(g.cell_of(tp)))
	ai._walled_halls[open] = g.clock + 120.0
	cm._tgt_t = -99.0
	tp = cm.wave_target(g.center_of_team(0))
	check(tp.distance_to(open.center()) > 4.0, "... a hall it was just beaten at is left (%s)" % str(g.cell_of(tp)))
	ai._walled_halls.erase(open)
	cm.target_on = false
	check(cm.wave_target(g.center_of_team(0)) == Vector2.INF, "... `cmctarget:off`: the shared target")
	cm.target_on = true
	for b in [walled, open]:
		if is_instance_valid(b) and not b.dead:
			b.die()
	for u in mine:
		u.take_damage(99999.0, null)
	ai._attack_at = 99


func _run() -> void:
	# 1. on in the mirror only
	for fb in ["brood", "clockwork"]:
		await _start("crown", fb)
		await _until(2.0)
		check(_ai(0).mirror() == null, "no mirror play against the %s" % fb)
	await _start("crown", "crown")
	await _until(2.0)
	check(_ai(0).mirror() != null and _ai(1).mirror() != null, "both Crowns play the mirror against a Crown")
	var ai = _ai(0)
	_ai(1).process_mode = Node.PROCESS_MODE_DISABLED
	# 2. the raider: a Horseman among the labourers once a Barracks stands
	await _until(400.0, func() -> bool: return ai._mine("barracks").any(func(b) -> bool: return b.built))
	check(ai._mine("barracks").any(func(b) -> bool: return b.built), "a Barracks stands (%d s)" % int(g.clock))
	for u in g.army(0):
		u.take_damage(99999.0, null)        # (no soldier to meet the raider)
	g.players[0]["gold"] = int(g.players[0]["gold"]) + 600
	var w: Unit = g.workers(0)[0]
	var horse: Unit = g._add_unit("cuirassier", 1, w.position + Vector2(60, 0))
	horse.cmd_hold()
	var t0 := g.clock
	await _until(t0 + 12.0, func() -> bool:
		return ai._mine("barracks").any(func(b) -> bool: return b.queue.has("musketeer")) or g.army(0).any(func(u) -> bool: return u.kind == "musketeer"))
	check(ai._mine("barracks").any(func(b) -> bool: return b.queue.has("musketeer")) or g.army(0).any(func(u) -> bool: return u.kind == "musketeer"),
		"a Musketeer is queued for the raider (%.1f s)" % (g.clock - t0))
	if is_instance_valid(horse) and not horse.dead:
		horse.take_damage(99999.0, null)
	# 4. the timing keeps its timing
	if ai.opt != null:
		ai.opt.current = "timing"
		var keep: Array = ai.opt._punish("crown", 400.0)
		check(keep.is_empty(), "a late greedy read keeps the Timing attack in the mirror (%s)" % str(keep))
		ai.opt.current = "balanced"
		check(not ai.opt._punish("crown", 400.0).is_empty(), "... and still picks for another plan")
	# 5. the hunt: a token army against a big one, a small one against a small one
	var mine: Array = []
	for i in 20:
		mine.append(g._add_unit("musketeer", 0, Vector2(g.starts[0]) * Defs.TILE + Vector2(0, 200)))
	var cm = ai.mirror()
	check(cm.hunt_anyway(1, mine), "a hunt goes on over a token enemy army (20 Musketeers against none)")
	check(not cm.hunt_anyway(1, mine.slice(0, 4)), "not with a small army of its own")
	var goal: Vector2 = cm.hunt_goal(1, Vector2(g.starts[0]) * Defs.TILE)
	check(g.halls_of(1).any(func(h) -> bool: return h.center().distance_to(goal) < 4.0), "the hunt goes for a hall")
	for u in mine:
		u.take_damage(99999.0, null)
	# 3. the march: 10 Musketeers strung out in a line across the open middle, sent as a wave
	var mid := Vector2(Game.W, Game.H) * Defs.TILE * 0.5
	var wave: Array = []
	for i in 10:
		var p: Vector2 = g.on_map(mid + Vector2(-340 + i * 76, 0))
		var c: Vector2i = g.nearest_free(g.cell_of(p), 4)
		wave.append(g._add_unit("musketeer", 0, g.cell_center(c)))
	await _until(g.clock + 1.0)
	ai._attacking = true
	ai._wave_set.clear()
	for u in wave:
		ai._wave_set[u] = true
		u.cmd_move(Vector2(g.starts[1]) * Defs.TILE, true)
	# (crown-line-fight: with the Crown's line on, the march's close-up is AICrownLine's; `-- line:off` the mirror's own)
	var ln = ai.line_ai()
	var talk: Array = ln.said if ln != null and ln.active() else cm.said
	var said0: int = talk.size()
	await _until(g.clock + 30.0, func() -> bool: return talk.size() > said0)
	var lines: Array = talk.slice(said0).map(func(x) -> String: return String(x[1]))
	check(lines.any(func(l: String) -> bool: return l.contains("close up")), "the strung-out wave closes up (%s)" % str(lines))
	for kk in 4:
		await _until(g.clock + 3.0)
		print("   t %.0f regroup %s attacking %s: %s" % [g.clock, str(cm.regrouping() or (ln != null and ln.regrouping())), str(ai._attacking), str(wave.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead).map(func(u) -> String: return "%s@%d,%d" % [u.order, int(u.position.x / 32), int(u.position.y / 32)]))])
	await _until(g.clock + 16.0, func() -> bool: return not cm.regrouping() and not (ln != null and ln.regrouping()))
	var last: String = String(talk[-1][1]) if not talk.is_empty() else ""
	var sp := 99.0
	var k := last.find("together (")
	if k >= 0:
		sp = float(last.substr(k + 10).split(" ")[0])
	check(sp < cm.SPREAD_MAX, "it went on together: %s" % last)
	for u in wave:
		if is_instance_valid(u) and not u.dead:
			u.take_damage(99999.0, null)
	# 6-7. crown-mirror-coach: the side ahead presses; the outlying hall first; the switches
	await _press_and_target(ai, cm)
	print("FAILS %d" % fails)
	print("ALL PASS" if fails == 0 else "SOME FAILED")
	quit(1 if fails > 0 else 0)
