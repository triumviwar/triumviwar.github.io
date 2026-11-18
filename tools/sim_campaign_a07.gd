extends SceneTree
## Plays Act 1's "The Council of Rome" (docs/campaign_a07_build.md) with a simple bot and prints, every minute, how it
## goes: the part, the dawn clock, the guard, the creatures, the automata, the fires, the houses standing, the people
## saved. A balance check: a player who plays it wins on NORMAL; a player who does nothing loses (the creatures or the
## machines reach Saint Peter's Square).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_a07.gd -- [active] [diff=easy|normal|hard]
##        [cages=few|some|all] [broken=kept|melted] [varenne=spared|executed] [lost=<n>] [until=<seconds>]
## The flags are written into the progress file for the run (and the player's own progress put back after).
## The bot: the guard's muskets and guns split over the three bridges' west feet (Sant'Angelo the strongest), the King
## kept in the castle's yard; in Part 2 Father Tomasz, with the four riders round him, goes over Sant'Angelo to the
## Piazza Navona, the Piazza del Popolo and the Campo de' Fiori in turn to call the people, then home; two Missionaries
## trained at Santo Spirito go to the far squares; the riders put out fires near the squares on the way; the gold buys
## Musketeers for the weakest bridge.
var main: Node
var until := 1500.0
var active := false
var diff := "normal"
var cages := "some"
var broken := "kept"
var varenne := "spared"
var lost := 0
var _saved_progress := ""
var _deaths := {}
var _watch: Array = []
var _tomasz_i := 0
var _posted := false
const BRIDGE_POST := {"ponte_ripetta": 5, "ponte_sant_angelo": 6, "ponte_sisto": 4}
const TOUR := ["navona", "popolo_square", "campo_fiori"]


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.begins_with("cages="):
			cages = a.substr(6)
		elif a.begins_with("broken="):
			broken = a.substr(7)
		elif a.begins_with("varenne="):
			varenne = a.substr(8)
		elif a.begins_with("lost="):
			lost = int(a.substr(5))
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	Campaign.save_progress({"reached": ["a07_council"], "done": {
		"a04_visit": {"won_by": "visit", "side": "visit", "flags": {"broken": broken, "lost_to_machine": lost}},
		"a05_specimens": {"won_by": "expedition", "side": "expedition", "flags": {"cages": cages, "eggs": "left"}},
		"a06_barricades": {"won_by": "crown", "side": "crown", "flags": {"varenne": varenne, "paris": "stood"}}}, "difficulty": diff})
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _of(g: Game, t: int, kinds: Array) -> Array:
	return g.units.filter(func(u) -> bool: return not u.dead and u.team == t and kinds.has(u.kind))


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("a07_council", "solo", "p1", false))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 3.0
	var gt := r.team_index("guard")
	print("SIM diff=%s cages=%s broken=%s varenne=%s lost=%d active=%s" % [diff, cages, broken, varenne, lost, active])
	while g.clock < until and not g.over:
		await physics_frame
		if paused:
			paused = false          # (the mid-match show pauses a solo match: the bot reads it at once)
		if active and g.clock >= think:
			think = g.clock + 1.0
			_play(g, r, gt)
		for u in g.units:
			if not u.dead and u.team == gt and not _watch.has(u):
				_watch.append(u)
		for u in _watch.duplicate():
			if not is_instance_valid(u):
				_watch.erase(u)
				continue
			if u.dead:
				_watch.erase(u)
				var key := "%s by t%d" % [u.kind, u.last_hit_team]
				_deaths[key] = int(_deaths.get(key, 0)) + 1
		if g.clock >= next:
			next += 60.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			var dawn := "-" if not r.clocks.has("dawn") else str(int(maxf(0.0, float(r.clocks["dawn"]) - g.clock)))
			print("SIM t=%4d part=%s dawn=%s guard=%d (muskets %d) garrison=%d creatures=%d automata=%d cell=%d burning=%d houses=%d saved=%d king=%s tomasz=%s piazza c=%d m=%d" % [
				g.clock, part, dawn, r.count({"team": "guard"}), _of(g, gt, ["musketeer"]).size(), r.count({"team": "garrison"}),
				r.count({"side": "creatures"}), r.count({"side": "automata"}), r.count({"side": "assembly"}),
				r.burning_count("houses"), r.tagged("houses").size(), int(r.counters["saved"]),
				"ok" if not r.tagged("king").is_empty() else "DEAD", "ok" if not r.tagged("tomasz").is_empty() else "DEAD",
				r.count({"side": "creatures", "area": "piazza_in"}), r.count({"side": "automata", "area": "piazza_in"})])
			if not _deaths.is_empty():
				print("SIM      guard lost: %s" % _deaths)
				_deaths.clear()
	print("SIM end t=%d over=%s winner=%s out=%s flags=%s saved=%d fires_out=%d objectives=%s" % [g.clock, g.over, r.winner_side, r.out_sides, r.flags,
		int(r.counters["saved"]), r.fires_out, r.obj])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
		f.close()
	quit(0)


func _play(g: Game, r: MissionRun, gt: int) -> void:
	var muskets := _of(g, gt, ["musketeer"])
	var guns := _of(g, gt, ["cannon"])
	var riders := _of(g, gt, ["cuirassier"])
	# the guard at the bridges' west feet (once; new muskets go to the post with fewest)
	if not _posted:
		_posted = true
		var i := 0
		for b in BRIDGE_POST:
			var n: int = BRIDGE_POST[b]
			var us: Array = muskets.slice(i, i + n)
			i += n
			for u in us:
				u.set_meta("post", b)
			g.group_move(us, r.area_rect(b + "_w").get_center() + Vector2(-80, 0), true)
		if guns.size() >= 2:
			guns[0].set_meta("post", "ponte_ripetta")
			guns[1].set_meta("post", "ponte_sisto")
			g.group_move([guns[0]], r.area_rect("ponte_ripetta_w").get_center() + Vector2(-150, 0), false)
			g.group_move([guns[1]], r.area_rect("ponte_sisto_w").get_center() + Vector2(-150, 0), false)
	for u in muskets:
		if not u.has_meta("post"):
			var best := "ponte_sant_angelo"
			var bn := 999
			for b in BRIDGE_POST:
				var n := muskets.filter(func(x) -> bool: return String(x.get_meta("post", "")) == b).size()
				if n < bn:
					bn = n
					best = b
			u.set_meta("post", best)
			g.group_move([u], r.area_rect(best + "_w").get_center() + Vector2(-80, 0), true)
	for u in guns:
		if u.tesla_mode == "packed" and u.velocity.length() < 2.0 and u.order != "move":
			u.cmd_deploy()
	# the King stays in the castle's yard
	for k in r.tagged("king"):
		if k.position.distance_to(r.area_rect("castel_yard").get_center()) > 120.0:
			g.group_move([k], r.area_rect("castel_yard").get_center(), false)
	# train Missionaries (two) and Musketeers with the gold
	var p: Dictionary = g.players[gt]
	var church: Array = r.tagged("santo_spirito")
	var barracks: Array = r.tagged("barracks")
	if r.fired.has("part2") and _of(g, gt, ["missionary"]).size() < 3 and not church.is_empty() and church[0].queue.is_empty():
		g.train(church[0], "missionary")
	if int(p["gold"]) >= 120 and not barracks.is_empty() and barracks[0].queue.size() < 2:
		g.train(barracks[0], "musketeer")
	if not r.fired.has("part2"):
		return
	# Father Tomasz's tour with the riders round him
	var tz: Array = r.tagged("tomasz")
	if not tz.is_empty():
		var t: Unit = tz[0]
		var goal := "castel_yard"
		while _tomasz_i < TOUR.size() and _called(r, TOUR[_tomasz_i]):
			_tomasz_i += 1
		if _tomasz_i < TOUR.size():
			goal = TOUR[_tomasz_i]
		var at := r.area_rect(goal).get_center()
		if t.position.distance_to(at) > 60.0:
			g.group_move([t], at, false)
		var home := _tomasz_i >= TOUR.size()
		for rd in riders:
			if home:
				# the tour done: the riders put out the nearest fire on the east bank (they stand by the house)
				var fire: Variant = _nearest_fire(r, rd.position)
				if fire != null:
					var spot: Vector2 = fire.center() + Vector2(0, 40)
					if rd.position.distance_to(spot) > 30.0:
						g.group_move([rd], spot, false)
					continue
			if rd.position.distance_to(t.position) > 140.0:
				g.group_move([rd], t.position, true)
	# the trained Missionaries go to the squares Tomasz will reach last
	var ms := _of(g, gt, ["missionary"]).filter(func(u) -> bool: return not r.tagged("tomasz").has(u))
	var far := ["campo_fiori", "popolo_square"]
	for i in ms.size():
		var sq: String = far[i % far.size()]
		if _called(r, sq):
			sq = "steps"
		var at2 := r.area_rect(sq).get_center()
		if ms[i].position.distance_to(at2) > 60.0:
			g.group_move([ms[i]], at2, false)


func _nearest_fire(r: MissionRun, at: Vector2) -> Variant:
	var best: Variant = null
	var bd := INF
	for b in r.tagged("houses"):
		if r.is_burning(b) and b.center().distance_to(at) < bd:
			bd = b.center().distance_to(at)
			best = b
	return best


func _called(r: MissionRun, square: String) -> bool:
	var q := String({"navona": "parione", "popolo_square": "campo_marzio", "campo_fiori": "regola"}.get(square, ""))
	return q == "" or r.fired.has("call_" + q) or r.fired.has("flee_" + q) or r.fired.has("smoke_" + q) or r.tagged("people_" + q).is_empty()
