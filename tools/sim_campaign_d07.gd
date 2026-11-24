extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 2's "The Council of Gears" (docs/campaign_d07_build.md) with a simple bot and prints, every 30 seconds, how
## it goes: the part, the signs found, the owls, the buildings turned, the masters brought out, the hall and the quarter,
## the works broken, the brake. A balance check (the owner's three rules: NO WAITING is measured): the player who plays
## it holds the hall and reaches the brake at EASY, NORMAL and HARD; a player who does nothing loses (the hall turns).
## At the end: the mission's longest stretch with nothing to do (target under 45 s).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_d07.gd -- [active] [diff=easy|normal|hard]
##        [saved=few|some|many] [jakob=alive|lost] [gate=pattern|people] [broken=kept|melted] [varenne=spared|executed]
##        [colonists=fought|parley] [stop] [nomasters] [noleap] [until=<seconds>] [none] [save_at=<s>]
##        [every=<s>] (the report's step) [shots=<dir>] (pictures of the parts; needs a window: xvfb-run, not --headless) [debug]
##   stop: the bot picks STOP IT at the brake (else the default, LET IT RUN)
##   nomasters: the bot never goes for the masters; noleap: never jumps (only the stairs)
## The earlier missions' flags are written into the progress file for the run (and the player's own progress put back).
var main: Node
var until := 2400.0
var active := false
var diff := "normal"
var c01 := {"bells": "quiet", "saved": "some", "jakob": "alive", "cut": "no", "gate": "pattern"}
var a04 := {"broken": "kept", "lost_to_machine": 0, "stopworks": "found", "jakob": "alive"}
var a06 := {"varenne": "spared", "paris": "stood"}
var d02 := {"exodus": "some", "drawings": "carried", "jakob": "stayed"}
var d04 := {"colonists": "fought", "crates": "opened"}
var no_flags := false
var stop := false
var nomasters := false
var noleap := false
var _saved_progress := ""
var shots := ""
var _shot_n := 0
var _shot_done := {}
var _chose := false
var _push := false
var every := 30.0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a == "stop":
			stop = true
		elif a == "nomasters":
			nomasters = true
		elif a == "noleap":
			noleap = true
		elif a == "none":
			no_flags = true
		elif a.begins_with("shots="):
			shots = a.substr(6)
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("every="):
			every = float(a.substr(6))
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.contains("=") and not a.begins_with("save_at") and not a.begins_with("load"):
			var kv := a.split("=")
			for d in [c01, a04, a06, d02, d04]:
				if d.has(kv[0]):
					d[kv[0]] = kv[1]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["d07_spring"], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if not no_flags:
		p["done"]["c01_thirteenth"] = {"won_by": "guild", "side": "guild", "flags": c01}
		p["done"]["a04_visit"] = {"won_by": "visit", "side": "visit", "flags": a04}
		p["done"]["a06_barricades"] = {"won_by": "crown", "side": "crown", "flags": a06}
		p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}}
		p["done"]["d02_exodus"] = {"won_by": "exodus", "side": "exodus", "flags": d02}
		p["done"]["d04_concordia"] = {"won_by": "guild", "side": "guild", "flags": d04}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("d07_spring", "solo", "p1", false, ""))
	await process_frame
	await process_frame
	if shots != "":
		RenderingServer.render_loop_enabled = false     # (drawn only for the pictures: a software renderer is slow)
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	print("SIM diff=%s c01=%s a04=%s a06=%s d04=%s active=%s stop=%s" % [diff, "none" if no_flags else str(c01), str(a04), str(a06), str(d04), active, stop])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
		if paused:
			paused = false          # (the vote's mid-match show pauses a solo match under a window: the bot reads it at once)
			if shots != "" and g.hud:
				for n in g.hud.get_parent().get_children():
					if n is StillShow:
						(n as StillShow).finish()     # (the pictures: the show read through, as a player would)
		if shots != "":
			await _shots(g, r)
		if active and g.clock >= think:
			think = g.clock + 0.75
			_play(g, r)
		if g.clock >= next:
			next += every
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			var hw: Array = r.tagged("hollweg")
			var gt := r.team_index("guild")
			var mt := r.team_index("machine")
			print("SIM t=%4d part=%s cogs=%d tension=%d found=%d owls=%d turned=%d honest=%d lost_m=%d broken=%d houses=%d/%d hall=%s guild=%d machine=%d hollweg=%s hp=%d leap=%s clocks=%s" % [
				g.clock, part, int(g.players[gt]["gold"]), int(g.players[gt].get("tension", 0)), int(r.counters.get("found", 0)),
				int(r.counters.get("owls", 0)), int(r.counters.get("turned", 0)), int(r.counters.get("honest_n", 0)), int(r.counters.get("lost_masters", 0)),
				int(r.counters.get("broken_n", 0)), int(r.counters.get("houses", 0)), int(r.counters.get("houses_n", 0)),
				"turned" if r.fired.has("hall_lost") else "ours", _men(g, gt).size(), _men(g, mt).size(),
				str(g.cell_of(hw[0].position)) if not hw.is_empty() else "-", int(hw[0].hp) if not hw.is_empty() else 0,
				str(g.has_tech(gt, "high_leap")), _clocks(g, r)])
			if OS.get_cmdline_user_args().has("debug"):
				print("  ours ", g.units.filter(func(u): return not u.dead and u.team == gt).map(func(u): return "%s%.2f%s hp%d %s" % [u.kind.substr(0, 4), u.wind, str(g.cell_of(u.position)), int(u.hp), u.order]))
				print("  foes ", g.units.filter(func(u): return not u.dead and u.team == mt).map(func(u): return "%s%s hp%d %s" % [u.kind.substr(0, 4), str(g.cell_of(u.position)), int(u.hp), u.order]))
	var idle: Dictionary = r.longest_idle()
	print("SIM end t=%d over=%s winner=%s flags=%s counters=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.counters, r.obj])
	print("SIM fired ", ["vote", "part1", "found_all", "part2", "q_turned_north", "q_turned_forge", "q_turned_mill", "q_turned_market", "broken", "valley",
		"all_turned", "dawn", "part3", "at_brake", "spring_set", "won", "hall_lost", "quarter_lost"].map(func(k): return "%s@%d" % [k, int(r.fired[k])] if r.fired.has(k) else k + "-"))
	print("SIM longest_idle %d s (from %d s)%s" % [int(idle.get("secs", 0.0)), int(idle.get("from", 0.0)), "" if float(idle.get("secs", 0.0)) < 45.0 else "  OVER 45 s"])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _clocks(g: Game, r: MissionRun) -> String:
	var out := []
	for cn in r.clocks:
		var left := float(r.clocks[cn]) - g.clock
		if left > 0:
			out.append("%s:%d" % [cn, int(left)])
	return ",".join(out)


func _men(g: Game, t: int) -> Array:
	return g.units.filter(func(u): return not u.dead and u.team == t and u.has_attack())


func _nearest_foe(g: Game, p: Vector2, me: int, reach: float) -> Unit:
	var best: Unit = null
	var bd := reach
	for f in g.units:
		if f.dead or f.kind == "horse" or f.spared or g.allied(f.team, me) or not f.has_attack():
			continue
		var d := p.distance_to(f.position)
		if d < bd:
			bd = d
			best = f
	return best


func _go(g: Game, u: Unit, p: Vector2, attack := false) -> void:
	if u.velocity.length() < 5.0 or u.order_point.distance_to(p) > 48.0:
		g.group_move([u], p, attack)


func _busy(u: Unit) -> bool:
	return u.target != null and is_instance_valid(u.target) and not u.target.dead


func _mid(r: MissionRun, a: String) -> Vector2:
	return r.area_rect(a).get_center()


## The player: Part 1 four small groups to the four doors, the Aviary's research and two morphs; Part 2 the fighters
## hold the hall's yard and the quarter's gate, a Springer runs to each master's house, the owls bomb the turned works,
## HIGH LEAP at the Escapement; Part 3 everyone up the west stair (the Springers jump up beside it where an owl sees),
## Hollweg behind them to the brake; at the choice LET IT RUN (or STOP IT with `stop`).
func _play(g: Game, r: MissionRun) -> void:
	var gt := r.team_index("guild")
	var men: Array = g.units.filter(func(u): return not u.dead and u.team == gt)
	var fighters: Array = men.filter(func(u): return u.kind in ["clock_soldier", "springer", "netter", "pendulum"])
	var springers: Array = men.filter(func(u): return u.kind == "springer")
	var swifts: Array = men.filter(func(u): return u.kind == "cuckoo")
	var owls: Array = men.filter(func(u): return u.kind == "ticking_owl")
	var hw: Array = r.tagged("hollweg")
	var p1 := not r.fired.has("part2")
	var p3 := r.fired.has("part3")
	if p3 and not _push:
		var rally := _mid(r, "below_stair_w") + Vector2(-8 * Defs.TILE, 2 * Defs.TILE)
		var there := fighters.filter(func(u): return u.position.distance_to(rally) < 5 * Defs.TILE).size()
		_push = there >= maxi(4, int(fighters.size() * 0.7)) or g.clock > float(r.fired["part3"]) + 45.0
	# the research and the morphs
	for b in r.tagged("aviary"):
		if b is Building and b.built and not g.has_tech(gt, "owl_morph") and not g.researching(gt, "owl_morph") and r.obj.get("owls", "") == "active":
			g.start_research(b, "owl_morph")
	if g.has_tech(gt, "owl_morph"):
		for s in swifts:
			if s.owl_t < 0.0 and CwAir.morph_problem(s) == "":
				CwAir.start_morph(s)
	if r.fired.has("leap_ask") and not g.has_tech(gt, "high_leap") and not g.researching(gt, "high_leap"):
		for b in r.tagged("escapement"):
			if b is Building and b.built:
				var why := g.start_research(b, "high_leap")
				if OS.get_cmdline_user_args().has("debug") and why != "":
					print("SIM research: ", why)
	# spare cogs: Clock Soldiers at the Light Works
	if not p1:
		for b in r.tagged("light_works"):
			if b is Building and b.built and b.queue.size() < 2 and int(g.players[gt]["gold"]) >= 120:
				g.train(b, "clock_soldier")
	# the swifts (Part 1: watch the hall) and the owls (bomb the turned works, then over the west stair's top)
	var turned_works: Array = r.tagged("meshed").filter(func(b): return b is Building and not b.dead and b.team == r.team_index("machine"))
	for o in owls + swifts:
		if p3:
			_go(g, o, _mid(r, "upper_w") + Vector2(40, 0))
		elif not turned_works.is_empty() and o.kind == "ticking_owl":
			var t: Building = turned_works[0]
			if o.target != t:
				o.cmd_attack(t)
		else:
			_go(g, o, _mid(r, "hall_yard"))
	# the honest masters: a Springer to each house still the council's
	var runners := {}
	if not nomasters and r.fired.has("part2") and not p3:
		var free: Array = springers.duplicate()
		for q in ["forge", "mill", "market"]:
			var ms: Array = r.tagged("master_" + q).filter(func(u): return u.team == r.team_index("council"))
			if ms.is_empty() or free.is_empty():
				continue
			var s: Unit = free.pop_front()
			runners[s] = true
			_go(g, s, ms[0].position)
	# Hollweg
	if not hw.is_empty():
		var h: Unit = hw[0]
		if p3:
			var near_top := 0
			for u in fighters:
				if g.on_high(u.position):
					near_top += 1
			if near_top >= 3 or r.fired.has("at_brake") or g.on_high(h.position):
				_go(g, h, _mid(r, "brake"))
			else:
				_go(g, h, _mid(r, "below_stair_w") + Vector2(-90, 30))
		elif h.position.distance_to(_mid(r, "camp")) > 4 * Defs.TILE:
			_go(g, h, _mid(r, "camp"))
	if r.fired.has("spring_ask") and not _chose and String(r.choice_open.get("id", "")) == "spring":
		_chose = true
		r.choose("spring", "stopped" if stop else "running")
	# the fighters
	var finds := ["n_press", "f_works", "m_press", "k_press"]
	for i in fighters.size():
		var u: Unit = fighters[i]
		if runners.has(u):
			continue
		if u.kind == "clock_soldier" and ShieldWall.can(u) and not u.shield_up and not p1:
			ShieldWall.set_up(u, true)
		if p1 and not r.fired.has("found_all") and r.fired.has("part1"):
			var left: Array = finds.filter(func(a): return not r.fired.has("find_" + {"n_press": "north", "f_works": "forge", "m_press": "mill", "k_press": "market"}[a]))
			if not left.is_empty():
				var a: String = left[i % left.size()]
				var f := _nearest_foe(g, u.position, gt, 5.0 * Defs.TILE)
				if f and not _busy(u):
					u.cmd_attack(f)
				elif f == null:
					_go(g, u, _mid(r, a))
				continue
		var hold := _mid(r, "hall_yard") if i % 2 == 0 else _mid(r, "quarter_gate")
		if p3:
			hold = _mid(r, "below_stair_w") if _push else _mid(r, "below_stair_w") + Vector2(-8 * Defs.TILE, 2 * Defs.TILE)
			if g.on_high(u.position) or r.fired.has("at_brake") or (_push and _nearest_foe(g, _mid(r, "below_stair_w"), gt, 8.0 * Defs.TILE) == null):
				hold = _mid(r, "brake")
			if u.kind == "springer" and not noleap and g.has_tech(gt, "high_leap") and not g.on_high(u.position) \
					and u.position.distance_to(_mid(r, "below_stair_w")) < 7 * Defs.TILE and Springer.ready_problem(u) == "":
				var top := _mid(r, "upper_w") + Vector2(2 * Defs.TILE, 0)
				if Springer.problem(u, top) == "":
					Springer.jump_order(g, [u], top)
					continue
		var f := _nearest_foe(g, hold, gt, 9.0 * Defs.TILE)
		if f == null:
			f = _nearest_foe(g, u.position, gt, 6.0 * Defs.TILE)
		if f and not _busy(u):
			u.cmd_attack(f)
		elif f == null and u.position.distance_to(hold) > 3 * Defs.TILE:
			_go(g, u, hold + Vector2(randf_range(-40, 40), randf_range(-40, 40)), p3)


## CHECK THE FEEL: pictures of each part, the camera on what matters then (docs/shots/d07_spring/).
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(id: String, after: float) -> bool: return r.fired.has(id) and g.clock > float(r.fired.get(id, 0)) + after
	var want := {"start": f.call("part1", 3.0), "find": f.call("find_north", 1.0) or f.call("find_forge", 1.0), "owls": int(r.counters.get("owls", 0)) >= 1,
		"thirteen": f.call("part2", 4.0), "turning": int(r.counters.get("turned", 0)) >= 3, "master": int(r.counters.get("honest_n", 0)) >= 1,
		"hall": f.call("q_turned_forge", 25.0), "dawn": f.call("part3", 6.0), "leap": f.call("part3", 50.0), "brake": f.call("at_brake", 2.0),
		"won": f.call("won", 1.0)}
	for k in want:
		if not want[k] or _shot_done.has(k):
			continue
		_shot_done[k] = true
		var at := _mid(r, "council_sq")
		match k:
			"start":
				at = _mid(r, "camp") + Vector2(160, -60)
			"find":
				at = _mid(r, "n_press") if r.fired.has("find_north") else _mid(r, "f_works")
			"owls":
				var o: Array = g.units.filter(func(u): return not u.dead and u.kind == "ticking_owl")
				at = o[0].position if not o.is_empty() else _mid(r, "camp")
			"thirteen":
				at = _mid(r, "spring_top")
			"turning":
				at = _mid(r, "f_works")
			"master":
				var ms: Array = r.tagged("saved_master")
				at = ms[0].position if not ms.is_empty() else _mid(r, "quarter_in")
			"hall":
				at = _mid(r, "hall_yard")
			"dawn", "leap":
				at = _mid(r, "below_stair_w") + Vector2(120, -40)
			"brake", "won":
				at = _mid(r, "brake")
		g.camera.position = at
		RenderingServer.render_loop_enabled = true
		if g.hud:
			g.hud.paused = false        # (the vote's show left the HUD's pause panel up: the tree runs)
			g.hud.queue_redraw()
		for i in 4:
			await process_frame
		var img := root.get_viewport().get_texture().get_image()
		RenderingServer.render_loop_enabled = false
		_shot_n += 1
		img.save_jpg("%s/%d_%s.jpg" % [shots, _shot_n, k], 0.85)
		print("SIM shot %s" % k)
