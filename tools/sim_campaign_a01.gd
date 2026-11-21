extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 1's "The Printing Houses" (docs/campaign_a01_build.md) with a simple bot and prints, every minute, how it
## goes: the part, the city's temper, the presses closed and found, the garrison, the runners out, the Assembly's men. A
## balance check: a player who plays it wins on NORMAL in a sensible time; a player who does nothing loses when the
## city rises.
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_a01.gd -- [active] [layout=old_town|river|hill]
##        [families=save|leave] [diff=easy|normal|hard] [until=<seconds>]
## The prologue's flag is written into the progress file for the run (and the player's own progress put back after).
## The bot plays fair: it does not know which houses print; its riders go round the houses (the lots: the twelve
## candidates and the town's own, in one order) and every musketeer it has keeps a square.
var main: Node
var until := 1800.0
var active := false
var diff := "normal"
var layout := ""
var families := "save"
var _saved_progress := ""
var _tour: Array = []
var _tour_i := 0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.begins_with("layout="):
			layout = a.substr(7)
		elif a.begins_with("families="):
			families = a.substr(9)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	Campaign.save_progress({"reached": ["a01_presses"], "done": {"p01_leaf": {"won_by": "crown", "side": "crown", "flags": {"families": families}}},
		"difficulty": diff})
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("a01_presses", "solo", "p1", false))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	if layout != "":
		r.choose("layout", layout)
	var next := 0.0
	var think := 2.0
	var gt := r.team_index("garrison")
	var at := r.team_index("assembly")
	# the riders' round: every house lot, nearest first from the garrison, then on from each
	var lots: Array = []
	for nm in r.data["areas"]:
		if String(nm).begins_with("cand_") or String(nm).begins_with("home_"):
			lots.append(String(nm))
	var at_p := r.area_rect("garrison_yard").get_center()
	while not lots.is_empty():
		lots.sort_custom(func(a, b): return r.area_rect(a).get_center().distance_to(at_p) < r.area_rect(b).get_center().distance_to(at_p))
		_tour.append(lots[0])
		at_p = r.area_rect(lots[0]).get_center()
		lots.remove_at(0)
	print("SIM diff=%s families=%s active=%s layout=%s" % [diff, families, active, layout])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
		if active and g.clock >= think:
			think = g.clock + 1.0
			_play(g, r, gt, at)
		if g.clock >= next:
			next += 60.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			print("SIM t=%4d part=%s layout=%s temper=%d closed=%d found=%d garrison=%d runners=%d assembly=%d weavers_turned=%d home=%d tomasz=%s" % [
				g.clock, part, r.flags.get("layout", "?"), int(r.counters["temper"]), int(r.counters["closed"]),
				range(1, 7).filter(func(i): return r.unmasked.has("press_%d" % i)).size(), r.count({"team": "garrison"}),
				r.tagged("runner").size(), r.count({"team": "assembly"}), int(r.counters["weavers"]), int(r.counters["home"]),
				"ok" if not r.tagged("tomasz").is_empty() else "DEAD"])
			print("SIM      found presses standing: %s; riders at %s" % [r.tagged("presses").filter(func(b): return not b.has_meta("disguise_team")).map(func(b): return [b.cell, int(b.hp)]),
				g.units.filter(func(u): return not u.dead and u.team == gt and u.kind == "cuirassier").map(func(u): return [g.cell_of(u.position), u.target.kind if u.target and is_instance_valid(u.target) else "-"])])
			var gp: Array = r.tagged("great_press")
			print("SIM      great press %s, printer %s, hall %s" % ["-" if gp.is_empty() else ("hidden" if gp[0].has_meta("disguise_team") else "found %d" % int(gp[0].hp)),
				"taken" if r.captured.has("printer") else str(r.tagged("printer").size()), "up" if not r.tagged("weavers_hall").is_empty() else "BURNT"])
	print("SIM end t=%d over=%s winner=%s flags=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.obj])
	var tw: Array = r.tagged("tomasz", false)
	if not tw.is_empty() and is_instance_valid(tw[0]) and tw[0].dead:
		var lh = tw[0].get("last_hit_by")
		print("SIM tomasz died at %s, last hit by %s" % [g.cell_of(tw[0].position), (str(lh.kind) + " " + String(lh.get_meta("rebel_role", "")) + " team " + str(lh.team)) if lh is Object and is_instance_valid(lh) else str(lh)])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _idle(u: Unit) -> bool:
	return (u.target == null or not is_instance_valid(u.target) or u.target.dead) and u.velocity.length() < 5.0


func _fight(g: Game, us: Array, foe_t: int, reach: float, home: Vector2, spread := 70.0) -> void:
	for u in us:
		var foe := _nearest_foe(g, u, foe_t, reach)
		if foe and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
			u.cmd_attack(foe)
		elif foe == null and u.position.distance_to(home) > spread * 1.6 and _idle(u):
			g.group_move([u], home + Vector2(randf_range(-spread, spread), randf_range(-spread, spread)) * 0.5, true)


func _play(g: Game, r: MissionRun, gt: int, at: int) -> void:
	var muskets: Array = g.units.filter(func(u): return not u.dead and u.team == gt and u.kind == "musketeer")
	var riders: Array = g.units.filter(func(u): return not u.dead and u.team == gt and u.kind in ["cuirassier", "dismounted"])
	var tom: Array = r.tagged("tomasz")
	var found: Array = r.tagged("presses").filter(func(b): return not b.has_meta("disguise_team"))
	# the powder wagon keeps to the middle of the squares (Jacobins), the muskets' refill
	for w in r.tagged("wagon"):
		if w.position.distance_to(r.area_rect("jacobins").get_center()) > 120.0 and _idle(w):
			g.group_move([w], r.area_rect("jacobins").get_center(), false)
	# the garrison's barracks trains Musketeers with the city's money
	for b in r.tagged("barracks"):
		if not b.dead and b.queue.size() < 2 and int(g.players[gt]["gold"]) >= 75 and g.can_train(b, "musketeer") == "":
			g.train(b, "musketeer")
	# ---------------- part 1: muskets keep the squares; riders go round the houses; a found press: everyone near breaks it
	if not r.fired.has("part2"):
		var squares := ["terreaux", "jacobins", "cordeliers", "bellecour", "saint_jean"]
		# (a strike group: the riders and the first four muskets go for a found press; the rest keep the squares)
		var strike: Array = riders + muskets.slice(0, 4)
		var keep: Array = muskets.slice(4)
		var tgt0: Building = null
		var bd := INF
		for b in found:
			var dd: float = b.center().distance_to(r.area_rect("garrison_yard").get_center()) * 0.0 + (b.center().distance_to(strike[0].position) if not strike.is_empty() else 0.0)
			if dd < bd:
				bd = dd
				tgt0 = b
		if tgt0:
			for u in strike:
				var foe := _nearest_foe(g, u, at, 220.0)
				if foe and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
					u.cmd_attack(foe)
				elif foe == null and u.target != tgt0:
					u.cmd_attack(tgt0)
			riders = []
			muskets = keep
		for i in muskets.size():
			var u: Unit = muskets[i]
			var near_press: Building = null
			for b in found:
				if b.center().distance_to(u.position) < 9 * Defs.TILE:
					near_press = b
			if near_press and _nearest_foe(g, u, at, 200.0) == null:
				if u.target != near_press:
					u.cmd_attack(near_press)
				continue
			_fight(g, [u], at, 260.0, r.area_rect(squares[i % squares.size()]).get_center())
		if not tom.is_empty() and tom[0].position.distance_to(r.area_rect("bellecour").get_center()) > 90.0 and _idle(tom[0]):
			g.group_move(tom, r.area_rect("bellecour").get_center(), false)
		var tgt: Building = found[0] if not found.is_empty() else null
		for u in riders:
			var foe := _nearest_foe(g, u, at, 180.0)
			if foe and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
				u.cmd_attack(foe)
			elif tgt and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
				u.cmd_attack(tgt)
			elif tgt == null and _idle(u):
				# the round: stop at a house's door 4 s (to see in), then the next house on it
				if not u.has_meta("dwell"):
					u.set_meta("dwell", g.clock + 4.0)
				elif g.clock >= float(u.get_meta("dwell")):
					u.remove_meta("dwell")
					_tour_i = (_tour_i + 1) % _tour.size()
					g.group_move([u], r.area_rect(_tour[_tour_i]).get_center(), true)
		return
	# ---------------- part 2: everyone up the hill, Tomasz to the hall's square once the men are there
	if not r.fired.has("part3"):
		var top := r.area_rect("hall_square").get_center()
		var army: Array = muskets + riders
		for i in army.size():
			var post := top + Vector2(((i % 6) - 2.5) * 40.0, 120.0 + (i / 6) * 30.0)
			_fight(g, [army[i]], at, 280.0, post, 50.0)
		var there: int = army.filter(func(u): return u.position.distance_to(top) < 300.0).size()
		if not tom.is_empty() and r.obj.get("speech", "") == "done":
			# (he has spoken: behind the hall, the soldiers between him and the stairs)
			var back := r.area_rect("hall_square").position + Vector2(2.5, 1.5) * Defs.TILE
			if tom[0].position.distance_to(back) > 50.0 and _idle(tom[0]):
				g.group_move(tom, back, false)
		elif not tom.is_empty() and (there >= 4 or g.clock > float(r.fired["part2"]) + 40.0) and tom[0].position.distance_to(top) > 80.0 and _idle(tom[0]):
			g.group_move(tom, top + Vector2(0, 40), false)
		return
	# ---------------- part 3: the yard through the south traboule; the printer worn down and taken; the press broken
	var yard := r.area_rect("yard").get_center()
	var pr: Array = r.tagged("printer")
	var gp: Array = r.tagged("great_press")
	for i in (muskets + riders).size():
		var u: Unit = (muskets + riders)[i]
		var foe := _nearest_foe(g, u, at, 220.0)
		if foe and String(foe.get_meta("rebel_role", "")) != "printer":
			if u.target == null or not is_instance_valid(u.target) or u.target.dead:
				u.cmd_attack(foe)
			continue
		if not pr.is_empty() and not pr[0].has_meta("mission_captured") and u.position.distance_to(yard) < 260.0:
			if u.target != pr[0]:
				u.cmd_attack(pr[0])
			continue
		if not gp.is_empty() and not gp[0].has_meta("disguise_team") and u.position.distance_to(yard) < 300.0:
			if u.target != gp[0]:
				u.cmd_attack(gp[0])
			continue
		if u.position.distance_to(yard) > 120.0 and _idle(u):
			g.group_move([u], yard, true)
	# (Tomasz stays up on the hall's square, where the hill is held)


func _nearest_foe(g: Game, u: Unit, t: int, reach: float) -> Unit:
	var best: Unit = null
	var bd := reach
	for f in g.units:
		if f.dead or f.team != t or f.kind == "horse" or f.spared:
			continue
		var d := u.position.distance_to(f.position)
		if d < bd:
			bd = d
			best = f
	return best
