extends "res://tools/playtest/pt_match.gd"
## PLAYTEST, a04_visit "Father Ferrer's Visit" from the main menu as a person (job playtest-campaign-clock).
## Args (plus pt_lib's): player=careful|passive|close|wander|reckless  broken=melted|kept|wait  diff=  speed=
##   prior=<furth>,<jakob>,<gate> (a02's furth, c01/a02's Jakob, c01's gate; default strong,alive,pattern)  pages=
## careful: the six workshops (nearest first), Jakob's word or the log, the night Winder followed at 5-6 tiles, the bank,
## the riot met at the bridge and the gap, the choice. passive: nothing (the dusk should end the visit: LOST).
## close: follows the night Winder at a tile and a half (it should stop, turn and wait; the visit should still be
## winnable after backing off). wander: lets the Winder go (the brothers' pings), then finds it again. reckless: walks
## Ferrer onto the machine's meadow in Part 1 (DEFEAT: Ferrer killed?).

var player := "careful"
var mid := "a04_visit"


func play() -> void:
	player = arg("player", "careful")
	choice_picks = {"broken": arg("broken", "kept")}
	var pr := arg("prior", "strong,alive,pattern").split(",")
	set_progress({"p01_leaf": ["crown", {"families": "save"}],
		"c01_thirteenth": ["guild", {"bells": "quiet", "saved": "some", "saved_n": 40, "jakob": pr[1], "cut": "no", "gate": pr[2]}],
		"a02_furth": ["guild", {"furth": pr[0], "jakob": pr[1], "stopwork": "fitted"}]})
	var ok := await start_mission("clockmaker", mid, arg("diff", "normal"), "", true, int(arg("pages", "0")))
	if not ok:
		return
	await snap("a04_start", 1.0)
	layout_check("a04 start")
	note("a04 party: %s" % [mine().map(func(u): return u.kind)])
	set_speed(float(arg("speed", "5")))
	var last := -60.0
	var think := 0.0
	var t0 := Time.get_ticks_msec()
	while is_instance_valid(game) and not game.over:
		await wait(0.2)
		watch()
		await answer_choice()
		if game.clock - last >= 45.0:
			last = game.clock
			_status()
		if float(arg("until", "99999")) < game.clock:
			note("stopped at %d (until=)" % game.clock)
			return
		if game.clock >= think:
			think = game.clock + (0.8 if run.fired.has("leg1") and not run.fired.has("at_bank") else 2.0)
			match player:
				"careful", "close", "wander":
					await careful()
				"reckless":
					await reckless()
		await _shots()
		if Time.get_ticks_msec() - t0 > 2400 * 1000:
			finding("a04 %s: not over after 40 real minutes (clock %d)" % [player, game.clock])
			break
	var title := await await_end(int(arg("endpages", "3")))
	note("a04 %s ended: %s; flags %s; objectives %s; counters %s" % [player, title, run.flags if run else {}, run.obj if run else {}, run.counters if run else {}])
	note("progress after: %s; reached %s" % [Campaign.progress().get("done", {}).get(mid, {}), Campaign.progress().get("reached", [])])
	if await press_name("End_CAMPAIGN"):
		await wait(0.6)
		note("after CAMPAIGN: %s" % [page_texts(8)])
		await snap("hub_after_a04", 0.6)


func _status() -> void:
	var f := run.tagged("ferrer")
	var nw := run.tagged("night_winder")
	var d := ""
	if not f.is_empty() and not nw.is_empty():
		d = "%.1f tiles" % (f[0].position.distance_to(nw[0].position) / Game.T)
	note("STATUS t=%d inspected=%d ferrer=%s hollweg=%s jakob=%s winder_gap=%s spotted=%d dark=%d lost=%d dusk=%s dawn=%s" % [game.clock,
		int(run.counters.get("inspected", 0)), _hp("ferrer"), _hp("hollweg"), _hp("jakob"), d, int(run.counters.get("spotted", 0)),
		int(run.counters.get("dark", 0)), int(run.counters.get("lost_to_machine", 0)),
		"%ds" % int(float(run.clocks["dusk"]) - game.clock) if run.clocks.has("dusk") else "-",
		"%ds" % int(float(run.clocks["dawn"]) - game.clock) if run.clocks.has("dawn") else "-"])


func _hp(tg: String) -> String:
	var a := run.tagged(tg)
	return "dead" if a.is_empty() else "%d" % a[0].hp


var _shot_done := {}


func _shots() -> void:
	var want := {"jakob": run.fired.has("jakob_told") or run.fired.has("log_read"),
		"follow": run.fired.has("leg1") and game.clock > float(run.fired.get("leg1", 0)) + 20,
		"spotted": run.fired.has("spotted"),
		"reveal": run.fired.has("reveal") and game.clock > float(run.fired.get("reveal", 0)) + 4,
		"riot": run.fired.has("riot") and game.clock > float(run.fired.get("riot", 0)) + 25}
	for k in want:
		if want[k] and not _shot_done.has(k):
			_shot_done[k] = true
			var keep := speed
			set_speed(1.0)
			var f := run.tagged("ferrer")
			if not f.is_empty():
				await look_at(f[0].position)
			await snap("a04_" + k, 0.3)
			layout_check("a04 " + k)
			set_speed(keep)


var _ws_done := {}
var _ws_at := ""


func careful() -> void:
	var fe := run.tagged("ferrer")
	if fe.is_empty():
		return
	var f: Unit = fe[0]
	# PART 1: the six workshops (stay 10 s in each), then Jakob's word (he comes to Ferrer: stand still) or the log
	if run.obj.get("inspect", "") == "active":
		for i in range(1, 7):
			if run.fired.has("ws_%d" % i):
				_ws_done[i] = true
		if _ws_at != "" and run.fired.has(_ws_at):
			_ws_at = ""
		if _ws_at == "":
			var best := -1
			var bd := INF
			for i in range(1, 7):
				if _ws_done.has(i):
					continue
				var d := f.position.distance_to(run.area_rect("ws_%d" % i).get_center())
				if d < bd:
					bd = d
					best = i
			if best > 0:
				_ws_at = "ws_%d" % best
				await select([f])
				await order_to(run.area_rect(_ws_at).get_center())
		elif f.velocity.length() < 3.0 and not run.area_rect(_ws_at).has_point(f.position):
			await select([f])
			await order_to(run.area_rect(_ws_at).get_center())
		return
	if run.obj.get("log", "") == "active" and not run.area_rect("barn").has_point(f.position) and f.velocity.length() < 3.0:
		await select([f])
		await order_to(run.area_rect("barn").get_center())
		return
	# PART 2: follow the night Winder
	var nwa := run.tagged("night_winder")
	if run.obj.get("follow", "") == "active" and not nwa.is_empty():
		var nw: Unit = nwa[0]
		var d := f.position.distance_to(nw.position) / Game.T
		var want_d := 5.5
		if player == "close":
			want_d = 1.5 if int(run.counters.get("spotted", 0)) < 2 else 5.5      # (too close twice, then a proper distance)
		if player == "wander" and game.clock < float(run.fired.get("leg1", 0)) + 40:
			return       # (lets it go for a while: the brothers should say where it went)
		if absf(d - want_d) > 1.2:
			var away := (f.position - nw.position)
			if away.length() < 1.0:
				away = Vector2(1, 0)
			var goal := nw.position + away.normalized() * want_d * Game.T
			await select([f])
			await order_to(goal)
		return
	if run.obj.get("watch", "") == "active" and not run.area_rect("bank_watch").has_point(f.position):
		await select([f])
		await order_to(run.area_rect("bank_watch").get_center())
		return
	# PART 3: the riot: the escort and the gate men meet the broken ones at the bridge and the gap; Ferrer back in town
	if run.obj.get("riot", "") == "active":
		var men := mine().filter(func(u): return u.kind == "musketeer")
		var idle := men.filter(func(u): return u.target == null or not is_instance_valid(u.target))
		var riot := run.tagged("rioters")
		if not riot.is_empty() and idle.size() >= 2:
			var c := Vector2.ZERO
			for r in riot:
				c += r.position
			c /= riot.size()
			await select(idle)
			await order_to(c, true)
		if not run.area_rect("town").has_point(f.position) and f.velocity.length() < 3.0 and game.clock - _ferrer_sent > 20:
			_ferrer_sent = game.clock
			await select([f])
			await order_to(run.area_rect("town").get_center())


var _ferrer_sent := -100.0


func reckless() -> void:
	var fe := run.tagged("ferrer")
	if fe.is_empty():
		return
	if fe[0].velocity.length() < 3.0 and not run.area_rect("meadow").has_point(fe[0].position):
		await select([fe[0]])
		await order_to(run.area_rect("meadow").get_center())
