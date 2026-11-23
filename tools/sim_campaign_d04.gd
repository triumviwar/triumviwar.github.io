extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 2's "The City of Gears" (docs/campaign_d04_build.md) with a simple bot and prints, every 30 seconds, how
## it goes: the part, the buildings raised, the Swifts and the ways mapped, the raid or the parley, the crowds turned
## back, the fires and the valley's temper, the crates, the dawn attack, Hollweg's health. A balance check (the owner's
## three rules: NO WAITING is measured): the player who plays it holds the city at EASY, NORMAL and HARD; a player who
## does nothing loses (the first quarter burns, or the tower falls). At the end: the mission's longest stretch with
## nothing to do (target under 45 s).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_d04.gd -- [active] [diff=easy|normal|hard]
##        [broken=kept|melted] [varenne=spared|executed] [gate=pattern|people] [drawings=carried|taken]
##        [exodus=few|some|many] [saved=few|some|many] [careless] [noparley] [until=<seconds>] [none] [save_at=<s>]
##        [shots=<dir>] (pictures of the parts; needs a window: xvfb-run, not --headless) [debug]
##   careless: the bot never turns the crowds back (it fights the raids and opens the crates only)
##   noparley: (broken=melted) the bot never walks Hollweg down to the captain
## The earlier missions' flags are written into the progress file for the run (and the player's own progress put back).
var main: Node
var until := 2400.0
var active := false
var diff := "normal"
var c01 := {"bells": "quiet", "saved": "some", "jakob": "alive", "cut": "no", "gate": "pattern"}
var a04 := {"broken": "kept", "lost_to_machine": 0, "stopworks": "found", "jakob": "alive"}
var a06 := {"varenne": "spared", "paris": "stood"}
var d02 := {"exodus": "some", "drawings": "carried", "jakob": "stayed"}
var no_flags := false
var careless := false
var noparley := false
var _saved_progress := ""
var shots := ""
var _shot_n := 0
var _shot_done := {}
var _swift_way := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a == "careless":
			careless = true
		elif a == "noparley":
			noparley = true
		elif a == "none":
			no_flags = true
		elif a.begins_with("shots="):
			shots = a.substr(6)
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.contains("=") and not a.begins_with("save_at") and not a.begins_with("load"):
			var kv := a.split("=")
			for d in [c01, a04, a06, d02]:
				if d.has(kv[0]):
					d[kv[0]] = kv[1]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["d04_concordia"], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if not no_flags:
		p["done"]["c01_thirteenth"] = {"won_by": "guild", "side": "guild", "flags": c01}
		p["done"]["a04_visit"] = {"won_by": "visit", "side": "visit", "flags": a04}
		p["done"]["a06_barricades"] = {"won_by": "crown", "side": "crown", "flags": a06}
		p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}}
		p["done"]["d02_exodus"] = {"won_by": "exodus", "side": "exodus", "flags": d02}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("d04_concordia", "solo", "p1", false, ""))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	print("SIM diff=%s c01=%s a04=%s a06=%s d02=%s active=%s careless=%s" % [diff, "none" if no_flags else str(c01), str(a04), str(a06), str(d02), active, careless])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
		if paused:
			paused = false          # (the crates' mid-match show pauses a solo match under a window: the bot reads it at once)
		if shots != "":
			await _shots(g, r)
		if active and g.clock >= think:
			think = g.clock + 0.75
			_play(g, r)
		if g.clock >= next:
			next += 30.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			var hw: Array = r.tagged("hollweg")
			var gt := r.team_index("guild")
			print("SIM t=%4d part=%s gold=%d tension=%d built=%s swifts=%d mapped=%d raid=%d houses=%d/%d mob=%d turned=%d home=%d temper=%d fires=%d attack=%d guild=%d hollweg=%s hp=%d clocks=%s" % [
				g.clock, part, int(g.players[gt]["gold"]), int(g.players[gt].get("tension", 0)), str(_built(r)),
				int(r.counters.get("swifts", 0)), int(r.counters.get("mapped", 0)), int(r.counters.get("raid_left", 0)),
				int(r.counters.get("houses", 0)), int(r.counters.get("houses_n", 0)), r.tagged("mob").filter(func(u): return u.team == r.team_index("town")).size(),
				int(r.counters.get("turned_back", 0)), int(r.counters.get("home_n", 0)), int(r.counters.get("temper", 0)), r.burning_count("city"),
				int(r.counters.get("attack_left", 0)), _men(g, gt).size(), str(g.cell_of(hw[0].position)) if not hw.is_empty() else "-",
				int(hw[0].hp) if not hw.is_empty() else 0, _clocks(g, r)])
			if OS.get_cmdline_user_args().has("debug"):
				print("  winds ", g.units.filter(func(u): return not u.dead and u.team == gt).map(func(u): return "%s%.2f%s hp%d %s" % [u.kind.substr(0, 3), u.wind, str(g.cell_of(u.position)), int(u.hp), u.order]))
				print("  foes ", g.units.filter(func(u): return not u.dead and u.team == r.team_index("militia")).map(func(u): return "%s%s hp%d %s" % [u.kind.substr(0, 3), str(g.cell_of(u.position)), int(u.hp), u.order]))
	var idle: Dictionary = r.longest_idle()
	print("SIM end t=%d over=%s winner=%s flags=%s counters=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.counters, r.obj])
	print("SIM fired ", ["parley", "raid", "boil", "mob_3", "anselmo", "anselmo_calls", "part3", "crates_open", "attack", "attack_path", "attack_spent", "break", "won", "tower_lost", "quarter_lost"].map(func(k): return "%s@%d" % [k, int(r.fired[k])] if r.fired.has(k) else k + "-"))
	print("SIM longest_idle %d s (from %d s)%s" % [int(idle.get("secs", 0.0)), int(idle.get("from", 0.0)), "" if float(idle.get("secs", 0.0)) < 45.0 else "  OVER 45 s"])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _built(r: MissionRun) -> String:
	var out := ""
	for t in ["tower", "spring", "aviary", "heavy"]:
		var bs: Array = r.tagged(t)
		out += t.substr(0, 2) + ("+" if not bs.is_empty() and bs[0].built else ("." if not bs.is_empty() else "-"))
	return out


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


## The player: the Winders raise every site there is; the Aviary makes two Swifts and each flies one of the three ways;
## the fighters hold by the quarter and the tower and fight what comes; with a parley Hollweg walks down to the captain;
## at night every free fighter pair stands by a torch-bearer (TURN THEM BACK) and the Winders put out fires; at dawn
## Hollweg walks to the gallery and the fighters hold the tower.
func _play(g: Game, r: MissionRun) -> void:
	var gt := r.team_index("guild")
	var men: Array = g.units.filter(func(u): return not u.dead and u.team == gt)
	var fighters: Array = men.filter(func(u): return u.kind in ["clock_soldier", "springer", "netter", "pendulum"])
	var winders: Array = men.filter(func(u): return u.kind == "winder")
	var swifts: Array = men.filter(func(u): return u.kind == "cuckoo")
	var hw: Array = r.tagged("hollweg")
	# the Winders: sites, then fires
	var sites: Array = []
	for t in ["tower", "spring", "aviary", "press", "heavy"]:
		for b in r.tagged(t):
			if b is Building and not b.built and not b.dead:
				sites.append(b)
	var fires: Array = r.tagged("city").filter(func(b): return not b.dead and r.is_burning(b))
	for i in winders.size():
		var w: Unit = winders[i]
		if not fires.is_empty() and i % 2 == 0:
			var fb: Building = fires[i / 2 % fires.size()]
			if w.position.distance_to(fb.center()) > 2.5 * Defs.TILE:
				_go(g, w, fb.center())
		elif not sites.is_empty():
			if w.order != "build":
				w.cmd_build(sites[i % sites.size()])
		elif w.position.distance_to(r.area_rect("west_field").get_center()) > 4 * Defs.TILE:
			_go(g, w, r.area_rect("west_field").get_center() + Vector2(0, 30))
	# the Aviary: two Swifts
	for b in r.tagged("aviary"):
		if b is Building and b.built and swifts.size() < 2 and b.queue.size() < 1:
			var why := g.train(b, "cuckoo")
			if OS.get_cmdline_user_args().has("debug") and why != "":
				print("SIM train: ", why)
	# spare cogs: Clock Soldiers at the Light Works (a player who reads the cards does)
	if swifts.size() >= 2 or r.fired.has("part2"):
		for b in g.buildings:
			if b.team == gt and b.kind == "movement_works" and b.built and b.queue.size() < 1 and int(g.players[gt]["gold"]) >= 100:
				g.train(b, "clock_soldier")
	# the Swifts: one way each, then home
	var ways := ["way_road", "way_path", "way_track"]
	for i in swifts.size():
		var s: Unit = swifts[i]
		var left: Array = ways.filter(func(w): return r.a2.chart_share(w) < 0.6)
		if left.is_empty():
			_go(g, s, r.area_rect("west_field").get_center())
			continue
		var w: String = left[i % left.size()]
		_go(g, s, r.area_rect(w).get_center())
	# Hollweg
	if not hw.is_empty():
		var h: Unit = hw[0]
		if r.obj.get("parley", "") == "active" and not noparley:
			_go(g, h, r.area_rect("parley").get_center())
		elif r.obj.get("crates", "") == "active":
			_go(g, h, r.area_rect("gallery").get_center())
		elif h.position.distance_to(r.area_rect("west_field").get_center()) > 4 * Defs.TILE:
			_go(g, h, r.area_rect("west_field").get_center())
	# the fighters
	var mob: Array = r.tagged("mob").filter(func(u): return not u.dead and u.team == r.team_index("town"))
	var night := r.fired.has("part2") and not r.fired.has("part3")
	var hold := r.area_rect("west_field").get_center()
	if r.obj.get("raid", "") == "active" or night or r.fired.has("attack"):
		hold = g.cell_center(Vector2i(73, 20))     # (by the houses, on the field's west edge: the Regulators' rings)
	for i in fighters.size():
		var u: Unit = fighters[i]
		if u.kind == "clock_soldier" and ShieldWall.can(u) and not u.shield_up and r.fired.has("attack"):
			ShieldWall.set_up(u, true)
		if night and not careless and not mob.is_empty():
			# two by each torch-bearer, nearest the quarter first
			mob.sort_custom(func(a, b): return a.position.distance_to(hold) < b.position.distance_to(hold))
			var m: Unit = mob[(i / 2) % mob.size()]
			if u.position.distance_to(m.position) > 1.2 * Defs.TILE:
				_go(g, u, m.position)
			continue
		var f := _nearest_foe(g, hold, gt, 9.0 * Defs.TILE)
		if f == null:
			f = _nearest_foe(g, u.position, gt, 6.0 * Defs.TILE)
		if f and not _busy(u):
			u.cmd_attack(f)
		elif f == null and u.position.distance_to(hold) > 4 * Defs.TILE:
			_go(g, u, hold + Vector2(randf_range(-50, 50), randf_range(-50, 50)))


## CHECK THE FEEL: pictures of each part, the camera on what matters then (docs/shots/d04_concordia/).
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(id: String, after: float) -> bool: return r.fired.has(id) and g.clock > float(r.fired.get(id, 0)) + after
	var want := {"start": g.clock > 3.0, "tower": f.call("tower_built", 2.0), "aviary": f.call("aviary_built", 8.0),
		"mapping": int(r.counters.get("swifts", 0)) >= 1 and int(r.counters.get("mapped", 0)) >= 1, "raid": f.call("raid", 25.0),
		"parley": f.call("parley", 1.0), "night": f.call("mob_1", 30.0), "turned": int(r.counters.get("turned_back", 0)) >= 2,
		"anselmo": f.call("anselmo_calls", 2.0), "crates": f.call("crates_open", 4.0), "plates": f.call("crates_open", 40.0),
		"attack": f.call("attack", 30.0), "won": f.call("won", 1.0)}
	for k in want:
		if not want[k] or _shot_done.has(k):
			continue
		_shot_done[k] = true
		var at := r.area_rect("tower_area").get_center()
		match k:
			"start", "tower":
				at = r.area_rect("tower_area").get_center() + Vector2(-120, 60)
			"aviary":
				at = r.area_rect("aviary_spot").get_center()
			"mapping":
				var s: Array = g.units.filter(func(u): return not u.dead and u.kind == "cuckoo")
				if not s.is_empty():
					at = s[0].position
			"raid", "night", "turned":
				at = r.area_rect("ramp_road").get_center() + Vector2(160, -40)
			"parley", "anselmo":
				at = r.area_rect("road_top").get_center()
			"crates", "plates":
				at = r.area_rect("gallery").get_center() + Vector2(-120, 80)
			"attack":
				at = r.area_rect("quarter").get_center() + Vector2(200, 0)
		g.camera.position = at
		for i in 4:
			await process_frame
		var img := root.get_viewport().get_texture().get_image()
		_shot_n += 1
		img.save_jpg("%s/%d_%s.jpg" % [shots, _shot_n, k], 0.85)
		print("SIM shot %s" % k)
