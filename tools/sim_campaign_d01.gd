extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 2's "The Gold of Vila Rica" (docs/campaign_d01_build.md) with a simple bot and prints, every 30 seconds,
## how it goes: the part, the town's temper, the quarters calmed, the armouries closed, the agitators, the rising, the
## gold carts on the road and at the coast, Ramos, Tomasz's health. A balance check (the owner's three rules: NO WAITING
## is measured): the player who plays it holds Vila Rica at EASY, NORMAL and HARD; a player who does nothing loses (the
## town rises). At the end: the mission's longest stretch with nothing to do (target under 45 s).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_d01.gd -- [active] [diff=easy|normal|hard]
##        [families=save|leave] [lyon=calm|sullen|risen] [varenne=spared|executed] [rome=few|some|all] [careless]
##        [noledges] [until=<seconds>] [save_at=<s>] [shots=<dir>] (pictures; needs a window: xvfb-run) [debug]
##   careless: Tomasz never goes to the churchyards (the bot fights and searches only)
##   noledges: in Part 3 nobody climbs the ledges (every man escorts the carts)
## The earlier missions' flags are written into the progress file for the run (and the player's own progress put back).
var main: Node
var until := 2400.0
var active := false
var diff := "normal"
var p01 := {"families": "save"}
var a01 := {"lyon": "calm", "printer": "taken"}
var a06 := {"varenne": "spared", "paris": "stood"}
var a07 := {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}
var careless := false
var noledges := false
var _saved_progress := ""
var shots := ""
var _shot_n := 0
var _shot_done := {}
var _search := 0               # (the next candidate house the searchers knock at)
var _knocked := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a == "careless":
			careless = true
		elif a == "noledges":
			noledges = true
		elif a.begins_with("shots="):
			shots = a.substr(6)
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.contains("=") and not a.begins_with("save_at") and not a.begins_with("load"):
			var kv := a.split("=")
			for d in [p01, a01, a06, a07]:
				if d.has(kv[0]):
					d[kv[0]] = kv[1]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["d01_minas"], "done": {}, "difficulty": diff}
	p["done"]["p01_leaf"] = {"won_by": "crown", "side": "crown", "flags": p01}
	p["done"]["a01_presses"] = {"won_by": "crown" if a01["lyon"] != "risen" else "assembly", "side": "crown", "flags": a01}
	p["done"]["a06_barricades"] = {"won_by": "crown", "side": "crown", "flags": a06}
	p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": a07}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("d01_minas", "solo", "p1", false, ""))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	print("SIM diff=%s p01=%s a01=%s a06=%s a07=%s active=%s careless=%s noledges=%s" % [diff, p01, a01, a06, a07, active, careless, noledges])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
		if paused:
			paused = false
		if shots != "":
			await _shots(g, r)
		if active and g.clock >= think:
			think = g.clock + 0.75
			_play(g, r)
		if g.clock >= next:
			next += 30.0
			var part := "1" if not r.fired.has("signal") else ("2" if not r.fired.has("part3") else "3")
			var tz: Array = r.tagged("tomasz")
			var gt := r.team_index("garrison")
			print("SIM t=%4d part=%s gold=%d powder=%d temper=%d/%d calmed=%d closed=%d runners=%d rising=%d miners_home=%d carts=%d out=%d lost=%d taken=%d ledge=%d ramos=%s garrison=%d tomasz=%s hp=%d clocks=%s" % [
				g.clock, part, int(g.players[gt]["gold"]), int(g.players[gt].get("res2", 0)), int(r.counters.get("temper", 0)), int(r.counters.get("temper_top", 0)),
				int(r.counters.get("calmed", 0)), int(r.counters.get("closed", 0)), r.tagged("runner").size(), int(r.counters.get("rising_left", 0)),
				int(r.counters.get("miners_home", 0)), r.tagged("carts").size(), int(r.counters.get("gold_out", 0)), int(r.counters.get("gold_lost", 0)),
				int(r.counters.get("carts_taken", 0)), int(r.counters.get("ledge_left", 0)), "taken" if r.captured.has("ramos") else str(r.tagged("ramos").size()),
				_men(g, gt).size(), str(g.cell_of(tz[0].position)) if not tz.is_empty() else "-", int(tz[0].hp) if not tz.is_empty() else 0, _clocks(g, r)])
	var idle: Dictionary = r.longest_idle()
	print("SIM end t=%d over=%s winner=%s flags=%s counters=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.counters, r.obj])
	print("SIM fired ", ["printer_shown", "researched", "calm_all", "closed_all", "signal_soon", "risen", "signal", "band_p", "miners_home", "rising_broken",
		"part3", "ledges_clear", "cart_go", "ambush", "ramos_taken", "ramos_run", "ramos_fled", "road_done", "won", "foundry_lost", "gold_zero"].map(
		func(k): return "%s@%d" % [k, int(r.fired[k])] if r.fired.has(k) else k + "-"))
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


func _nearest_foe(g: Game, p: Vector2, me: int, reach: float, buildings := false) -> Entity:
	var best: Entity = null
	var bd := reach
	for f in g.units:
		if f.dead or f.kind == "horse" or f.spared or g.allied(f.team, me):
			continue
		var d := p.distance_to(f.position)
		if d < bd:
			bd = d
			best = f
	if buildings:
		for b in g.buildings:
			if b.dead or b.spared or g.allied(b.team, me):
				continue
			var d := p.distance_to(b.center())
			if d < bd:
				bd = d
				best = b
	return best


func _go(g: Game, u: Unit, p: Vector2, attack := false) -> void:
	if u.velocity.length() < 5.0 or u.order_point.distance_to(p) > 48.0:
		g.group_move([u], p, attack)


func _busy(u: Unit) -> bool:
	return u.target != null and is_instance_valid(u.target) and not u.target.dead


func _fight_or_go(g: Game, u: Unit, at: Vector2, reach: float) -> void:
	var f := _nearest_foe(g, u.position, u.team, reach, true)
	if f and not _busy(u):
		u.cmd_attack(f)
	elif f == null and u.position.distance_to(at) > 2.5 * Defs.TILE:
		_go(g, u, at)


## The player: the Armoury researches the Matchlock and the Socket Bayonet (AUTO REFIT on); Tomasz walks to each
## quarter's churchyard; the horsemen ride down the agitators; two Musketeers knock at the candidate houses in turn and
## the rest break into any armoury found; at night the men hold the square's two stairs and the ridge, Tomasz goes to
## the Rosário; at dawn a party climbs the gorge's ledges and the rest escort the carts; the horsemen go for Ramos.
func _play(g: Game, r: MissionRun) -> void:
	var gt := r.team_index("garrison")
	var men: Array = g.units.filter(func(u): return not u.dead and u.team == gt)
	var muskets: Array = men.filter(func(u): return u.kind == "musketeer")
	var riders: Array = men.filter(func(u): return u.kind == "cuirassier" and not r.tagged("meneses").has(u))
	var guns: Array = men.filter(func(u): return u.kind == "cannon")
	var tz: Array = r.tagged("tomasz")
	# the Armoury: research, AUTO REFIT; the Barracks: Musketeers while there is gold
	for b in r.tagged("armoury"):
		if b is Building and b.built and b.queue.size() < 1:
			for k in ["bayonet", "matchlock"]:
				if not g.has_tech(gt, k) and not g.researching(gt, k):
					var why := g.start_research(b, k)
					if OS.get_cmdline_user_args().has("debug") and why != "":
						print("SIM research: ", why)
					break
			b.auto_refit = true
	for b in r.tagged("barracks"):
		if b is Building and b.built and b.queue.size() < 1 and int(g.players[gt]["gold"]) >= 160 and muskets.size() < 22:
			g.train(b, "musketeer")
	var part1 := not r.fired.has("signal")
	var part3 := r.fired.has("part3")
	# Tomasz
	if not tz.is_empty():
		var t: Unit = tz[0]
		if part1 and not careless:
			var left: Array = ["pilar", "carmo", "rosario", "efigenia"].filter(func(q): return not r.fired.has("calm_" + q))
			left.sort_custom(func(a, b): return t.position.distance_to(r.area_rect("adro_" + a).get_center()) < t.position.distance_to(r.area_rect("adro_" + b).get_center()))
			if not left.is_empty():
				_go(g, t, r.area_rect("adro_" + left[0]).get_center())
		elif r.obj.get("miners", "") == "active" and not r.fired.has("miners_home") and not careless:
			_go(g, t, r.area_rect("adro_rosario").get_center())
		elif part3:
			var cs: Array = r.tagged("carts").filter(func(c): return not c.dead)
			if not cs.is_empty():
				_go(g, t, cs[cs.size() - 1].position + Vector2(-40, 0))
		elif t.position.distance_to(r.area_rect("praca").get_center()) > 5 * Defs.TILE:
			_go(g, t, r.area_rect("praca").get_center())
	# the horsemen: agitators in Part 1, Ramos in Part 3
	var runners: Array = r.tagged("runner").filter(func(u): return not u.dead)
	for i in riders.size():
		var u: Unit = riders[i]
		if part1 and not runners.is_empty():
			runners.sort_custom(func(a, b): return u.position.distance_to(a.position) < u.position.distance_to(b.position))
			if not _busy(u):
				u.cmd_attack(runners[0])
		elif part3 and not r.tagged("ramos").is_empty() and not r.captured.has("ramos") and r.fired.has("ambush"):
			var ra: Unit = r.tagged("ramos")[0]
			if u.target != ra:
				u.cmd_attack(ra)
		elif part3:
			var cs: Array = r.tagged("carts").filter(func(c): return not c.dead)
			_fight_or_go(g, u, cs[i % cs.size()].position if not cs.is_empty() else r.area_rect("gorge_mid").get_center(), 6 * Defs.TILE)
		else:
			_fight_or_go(g, u, r.area_rect("ridge_w").get_center() if not part1 else r.area_rect("praca").get_center(), 7 * Defs.TILE)
	# the Musketeers
	var found: Array = r.tagged("armouries").filter(func(b): return not b.dead and not b.spared)
	for i in muskets.size():
		var u: Unit = muskets[i]
		if part1:
			if not found.is_empty():
				var b: Building = found[i % found.size()]
				if not _busy(u):
					var f := _nearest_foe(g, b.center(), gt, 5 * Defs.TILE)
					u.cmd_attack(f if f else b)
				continue
			if i < 2:
				# the searchers: the next candidate house not yet knocked at
				var cand := "cand_%d" % (_search % 8 + 1)
				var door := r.area_rect(cand).get_center() + Vector2(0, 1.8 * Defs.TILE)
				if u.position.distance_to(door) < 1.2 * Defs.TILE:
					_knocked[cand] = float(_knocked.get(cand, 0.0)) + 0.75
					if float(_knocked[cand]) > 4.0:
						_search += 1
				else:
					_go(g, u, door)
				continue
			_fight_or_go(g, u, r.area_rect("praca").get_center() + Vector2((i % 5) * 30 - 60, 40), 8 * Defs.TILE)
		elif not part3:
			var posts := ["below_sq_s", "below_sq_n", "ridge_w"]
			var at := r.area_rect(posts[i % 3]).get_center()
			if posts[i % 3] == "below_sq_s":
				at = r.area_rect("praca").get_center() + Vector2(0, 5 * Defs.TILE)
			elif posts[i % 3] == "below_sq_n":
				at = r.area_rect("praca").get_center() + Vector2(0, -6 * Defs.TILE)
			_fight_or_go(g, u, at, 7 * Defs.TILE)
		else:
			var ledge_men: Array = r.tagged("ledge_men").filter(func(e): return not e.dead)
			if not noledges and i < 8 and not ledge_men.is_empty():
				# the climbers: four up each ledge by its stairs
				var tgt := "ledge_n" if i < 4 else "ledge_s"
				var on: Array = ledge_men.filter(func(e): return r.area_rect(tgt).grow(2 * Defs.TILE).has_point(e.position))
				if on.is_empty():
					on = ledge_men
				if not _busy(u):
					u.cmd_attack(on[0])
				continue
			var cs: Array = r.tagged("carts").filter(func(c): return not c.dead)
			var at2: Vector2 = cs[i % cs.size()].position if not cs.is_empty() else r.area_rect("coast").get_center()
			_fight_or_go(g, u, at2, 6 * Defs.TILE)
	for u in guns:
		_fight_or_go(g, u, r.area_rect("praca").get_center() if not part3 else r.area_rect("road_mid").get_center(), 12 * Defs.TILE)


## CHECK THE FEEL: pictures of each part, the camera on what matters then (docs/shots/d01_minas/).
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(id: String, after: float) -> bool: return r.fired.has(id) and g.clock > float(r.fired.get(id, 0)) + after
	var want := {"start": g.clock > 3.0, "calm": f.call("calm_pilar", 0.5) or f.call("calm_carmo", 0.5), "found": f.call("first_found", 1.0),
		"runner": f.call("first_runner", 1.0), "signal": f.call("signal", 3.0), "stairs": f.call("band_r", 30.0), "miners": f.call("miners_home", 2.0),
		"ridge": f.call("band_p", 20.0), "dawn": f.call("part3", 3.0), "gorge": f.call("ambush", 4.0), "ramos": f.call("ramos_taken", 0.5) or f.call("ramos_run", 2.0),
		"won": f.call("won", 1.0)}
	for k in want:
		if not want[k] or _shot_done.has(k):
			continue
		_shot_done[k] = true
		var at := r.area_rect("praca").get_center()
		match k:
			"start":
				at = r.area_rect("praca").get_center() + Vector2(0, 160)
			"calm":
				var tz: Array = r.tagged("tomasz")
				if not tz.is_empty():
					at = tz[0].position
			"found":
				var fb: Array = r.tagged("armouries").filter(func(b): return not b.dead and not b.spared)
				if not fb.is_empty():
					at = fb[0].center()
			"runner":
				var rn: Array = r.tagged("runner").filter(func(u): return not u.dead)
				if not rn.is_empty():
					at = rn[0].position
			"stairs":
				at = r.area_rect("sq_s").get_center()
			"miners":
				at = r.area_rect("adro_rosario").get_center()
			"ridge":
				at = r.area_rect("ridge_w").get_center()
			"dawn":
				at = r.area_rect("foundry_door").get_center() + Vector2(0, 100)
			"gorge", "ramos":
				at = r.area_rect("gorge_mid").get_center() + Vector2(-80, 0)
			"won":
				at = r.area_rect("gorge_e").get_center()
		g.camera.position = at
		for i in 4:
			await process_frame
		var img := root.get_viewport().get_texture().get_image()
		_shot_n += 1
		img.save_jpg("%s/%d_%s.jpg" % [shots, _shot_n, k], 0.85)
		print("SIM shot %s" % k)
