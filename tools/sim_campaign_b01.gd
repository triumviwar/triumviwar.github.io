extends SceneTree
## Plays the Brood prologue, "Specimen One" (docs/campaign_b01_build.md), with a simple player bot and prints, every minute,
## how it goes: the part, the station's army, the pack, the people saved, the time left. A balance check: Parts 1-2 must
## be winnable by a player who plays them (the pen built, the goats, the lure, the village, the turtle), Part 3 a fair
## retreat (Lindqvist and Valadares out, the people saved depending on play), and a player who does nothing must lose.
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_b01.gd [-- active] [teles=told|quiet] [clutch=saved|burned]
##        [until=<seconds>] [shots=<dir>] [speed=<x>] (shots: pictures of the parts; needs a window: xvfb-run, not --headless)
var main: Node
var until := 3000.0
var active := false      # ("active": the hands build the pen and a Barracks and work the garden, Musketeers trained while
                         # there is gold; Lindqvist meets Valadares, Pieter goes to the ford and sets the jars; the army
                         # waits at the jars, brings the village in (quiet), kills the turtle; in Part 3 it shoots the
                         # rooted Sire, the people walk to the jetty, Lindqvist goes to the specimen house, then all aboard)
var teles := "quiet"
var clutch := "saved"
var shots := ""
var _shot_n := 0
var _shot_done := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		if a.begins_with("until="):
			until = float(a.substr(6))
		if a.begins_with("teles="):
			teles = a.substr(6)
		if a.begins_with("clutch="):
			clutch = a.substr(7)
		if a.begins_with("shots="):
			shots = a.substr(6)
		if a.begins_with("speed="):
			Engine.time_scale = float(a.substr(6))
			Engine.max_physics_steps_per_frame = 32
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("b01_specimen", "solo"))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 2.0
	var st := r.team_index("station")
	var pt := r.team_index("pack")
	while g.clock < until and not g.over:
		await physics_frame
		if not r.choice_open.is_empty():
			var cid := String(r.choice_open["id"])
			if cid == "teles":
				r.choose(cid, teles)
			elif cid == "clutch":
				r.choose(cid, clutch)
		if active and g.clock >= think:
			think = g.clock + 1.5
			_play(g, r, st, pt)
		if shots != "":
			await _shots(g, r)
		if g.clock >= next:
			next += 60.0
			var part := "1" if not r.fired.has("eve") else ("2" if not r.fired.has("turn") else "3")
			var left := ""
			if r.clocks.has("canoes"):
				left = "%ds" % int(float(r.clocks["canoes"]) - g.clock)
			print("SIM t=%4d part=%s station=%d army=%d pack=%d gold=%d folk=%d saved=%d/%d eggs=%d sire=%s lindqvist=%s valadares=%s pieter=%s pen=%s canoes_in=%s" % [g.clock, part,
				r.count({"team": "station"}), _army(g, st).size(), r.count({"team": "pack"}), int(g.players[st]["gold"]), r.tagged("folk").size(),
				int(r.counters.get("saved", 0)), int(r.counters.get("people", 0)), r.tagged("eggs").size(),
				("rooted" if BroodNew.rooted(r.tagged("sire")[0]) else "up %d" % r.tagged("sire")[0].hp) if not r.tagged("sire").is_empty() else "-",
				_hp(r, "lindqvist"), _hp(r, "valadares"), _hp(r, "pieter"), r.obj.get("pen", ""), left])
	for h in ["lindqvist", "valadares"]:
		var hs: Array = r.tagged(h, false)
		if not hs.is_empty() and is_instance_valid(hs[0]) and hs[0].dead:
			print("SIM %s died at cell %s, last hit by %s" % [h, g.cell_of(hs[0].position), hs[0].last_hit_by])
	print("SIM end t=%d over=%s winner=%s flags=%s" % [g.clock, g.over, r.winner_side, r.flags])
	print("SIM objectives %s" % r.obj)
	quit()


func _hp(r: MissionRun, tag: String) -> String:
	var t := r.tagged(tag)
	return "DEAD" if t.is_empty() else str(int(t[0].hp))


func _army(g: Game, st: int) -> Array:
	return g.units.filter(func(u): return not u.dead and u.team == st and u.kind in ["musketeer", "dismounted"] and not u.has_meta("rebel_role"))


func _go(g: Game, us: Array, p: Vector2, fight := false) -> void:
	var idle: Array = us.filter(func(u): return u.position.distance_to(p) > 90.0 and (u.velocity.length() < 5.0 or u.order == "idle"))
	if not idle.is_empty():
		g.group_move(idle, p, fight)


func _play(g: Game, r: MissionRun, st: int, pt: int) -> void:
	var hands: Array = r.tagged("hands")
	var army := _army(g, st)
	var lq: Array = r.tagged("lindqvist")
	var va: Array = r.tagged("valadares")
	var pi: Array = r.tagged("pieter")
	var have := func(k: String) -> int: return g.buildings.filter(func(b): return not b.dead and b.team == st and b.kind == k).size()
	if not r.fired.has("turn"):
		# the pen first, then a Barracks, the rest to the garden; Musketeers while there is gold
		var sites: Array = r.tagged("pen").filter(func(b): return not b.built)
		if not sites.is_empty():
			var i := 0
			for h in hands.slice(0, 4):
				if h.order != "build" or int(g.clock) % 20 == 0:
					h.cmd_build(sites[i % sites.size()])      # (each hand its own stake, asked again now and then)
				i += 1
		elif have.call("barracks") < 2 and int(g.players[st]["gold"]) >= int(Defs.BUILDINGS["barracks"]["cost"]) and not hands.is_empty():
			var c: Vector2i = g.find_spot(st, "barracks", r.tagged("station_house")[0], 3, 12)
			if c.x >= 0:
				g.place_building(st, "barracks", c, hands.slice(0, 2))
		else:
			var farm: Array = r.tagged("garden")
			for h in hands:
				if h.order == "idle" and not farm.is_empty():
					h.cmd_gather(farm[0])
		for b in g.buildings:
			if b.team == st and not b.dead and b.built and b.kind == "barracks" and b.queue.size() < 2 and int(g.players[st]["gold"]) >= 60:
				g.train(b, "musketeer")
	if not r.fired.has("eve"):
		# part 1: Lindqvist to Valadares, Pieter to the ford, the army at the goats
		if r.obj.get("meet", "") == "active" and not lq.is_empty():
			_go(g, lq, r.area_rect("jetty").get_center())
		elif not lq.is_empty():
			_go(g, lq, r.area_rect("house").get_center() + Vector2(-40, 90))
		if r.obj.get("tracks", "") == "active" and not pi.is_empty():
			_go(g, pi, r.area_rect("ford").get_center())
		_go(g, army, r.area_rect("goats").get_center(), true)
		return
	if not r.fired.has("turn"):
		if not lq.is_empty():
			_go(g, lq, r.area_rect("house").get_center() + Vector2(-40, 90))       # (kept back by the house)
		# part 2: Pieter to the jars, the army at the jars (the lure), then at the pen; quiet: the village; the turtle
		if r.obj.get("lure", "") == "active" and not pi.is_empty():
			for a in ["jar_c", "jar_w", "jar_e"]:
				if int(r.counters.get(a + "_set", 0)) == 0:
					var to: Vector2 = r.area_rect(a).get_center()
					if pi[0].order != "move" or pi[0].order_point.distance_to(to) > 80.0:
						g.group_move(pi, to, false)          # (a labourer at the garden is never idle: told straight)
					break
		elif not pi.is_empty():
			_go(g, pi, r.area_rect("yard").get_center())
		if r.obj.get("village", "") == "active":
			_go(g, army, r.area_rect("village").get_center(), true)
		elif r.obj.get("turtle", "") == "active":
			# (half the army at the turtle, half stays by the pen and the house)
			_go(g, army.slice(0, army.size() / 2), r.area_rect("mouth").get_center(), true)
			_go(g, army.slice(army.size() / 2), r.area_rect("pen").get_center() + Vector2(-120, 0), true)
		elif int(r.counters.get("waves", 0)) < 2 and int(r.counters.get("jars", 0)) >= 1:
			_go(g, army, r.area_rect("jar_c").get_center(), true)
		else:
			_go(g, army, r.area_rect("pen").get_center() + Vector2(0, -60), true)
		return
	# part 3: the people to the jetty; the army shoots the rooted Sire, then falls back; Lindqvist to the specimen house
	var left := float(r.clocks.get("canoes", 0.0)) - g.clock
	_go(g, hands + pi, r.area_rect("jetty").get_center())
	if left < 150.0:
		_go(g, army + va, r.area_rect("jetty").get_center())
	else:
		var sire: Array = r.tagged("sire")
		var near_nest: int = g.units.filter(func(u): return not u.dead and u.team == pt and u.kind != "tyrannosaur" and u.position.distance_to(r.area_rect("nest").get_center()) < 420.0).size()
		if not sire.is_empty() and BroodNew.rooted(sire[0]) and near_nest < 4 and army.size() >= 6:
			for u in army:
				if u.target == null or not is_instance_valid(u.target) or u.target.dead:
					u.cmd_attack(sire[0])
		elif not sire.is_empty() and not BroodNew.rooted(sire[0]):
			_go(g, army, r.area_rect("jetty").get_center())          # (he is up: nothing kills him; get away from him)
		else:
			_go(g, army, r.area_rect("yard").get_center() + Vector2(0, 80), true)
		_go(g, va, r.area_rect("jetty").get_center() + Vector2(0, -60))
	if not lq.is_empty():
		var to := "spec" if (r.obj.get("research", "") == "active") else "jetty"
		_go(g, lq, r.area_rect(to).get_center())


## Pictures of the parts (with a window): the station, the pen built, the goats, the night and the jars, the turtle, the
## Sire at the pen, the clutch, the fall, the jetty, the canoes leaving.
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(t: String, d: float) -> bool: return r.fired.has(t) and g.clock > float(r.fired.get(t, 0)) + d
	var want := {"station": g.clock > 3.0, "pen": f.call("pen_done", 2.0), "goats": f.call("goats_attack", 6.0),
		"lure": f.call("lure_set", 3.0), "night_wave": f.call("wave_e", 8.0), "turtle": f.call("turtle_comes", 30.0),
		"sire": f.call("sire_rooted", 3.0), "clutch": f.call("eggs", 60.0), "taken": f.call("taken", 4.0),
		"fall": f.call("taken", 30.0), "jetty": r.clocks.has("canoes") and float(r.clocks["canoes"]) - g.clock < 25.0,
		"leave": f.call("leave", 3.0)}
	var where := {"station": "yard", "pen": "pen", "goats": "goats", "lure": "jar_c", "night_wave": "pen", "turtle": "mouth",
		"sire": "nest", "clutch": "pen", "taken": "nest_wide", "fall": "yard", "jetty": "jetty", "leave": "jetty"}
	for k in want:
		if want[k] and not _shot_done.has(k):
			_shot_done[k] = true
			g.camera.position = r.area_rect(where[k]).get_center()
			for i in 4:
				await process_frame
			var img := root.get_viewport().get_texture().get_image()
			_shot_n += 1
			img.save_jpg("%s/%d_%s.jpg" % [shots, _shot_n, k], 0.85)
			print("SIM shot %s" % k)
