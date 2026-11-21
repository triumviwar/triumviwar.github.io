extends "res://tools/playtest/pt_match.gd"
## PLAYTEST, a02_furth "The Fürth Line" from the main menu as a person (job playtest-campaign-clock).
## Args (plus pt_lib's): side=guild|machine  player=careful|passive|reckless|chaos  diff=easy|normal|hard  speed=
##   c01=<bells>,<saved>,<jakob>,<cut>,<gate> (the prologue's flags written to the progress first; default
##   quiet,some,alive,no,pattern)  pages=  endpages=  until=  quit=
## guild careful: Hollweg to the Honest One (the stop-work), a Light Works, Clock Soldiers, the army to both gates for the
## sorties, then the mill seed. guild passive: no order (the parts should still move on; the Honest One may fall).
## guild reckless: Hollweg walks out to the machine (DEFEAT). machine careful: every soldier at the Honest One, more
## trained; machine passive: nothing (the countdown runs out: the machine loses).

var player := "careful"
var side := "guild"
var mid := "a02_furth"


func play() -> void:
	player = arg("player", "careful")
	side = arg("side", "guild")
	var f := arg("c01", "quiet,some,alive,no,pattern").split(",")
	var c01 := {"bells": f[0], "saved": f[1], "saved_n": {"few": 12, "some": 40, "many": 70}.get(f[1], 40), "jakob": f[2], "cut": f[3], "gate": f[4]}
	set_progress({"p01_leaf": ["crown", {"families": "save"}], "c01_thirteenth": ["guild", c01]})
	var ok := await start_mission("clockmaker", mid, arg("diff", "normal"), side, true, int(arg("pages", "0")))
	if not ok:
		return
	check("a02: the side picked is the side played", run.my_side() == side, run.my_side())
	await snap("a02_%s_start" % side, 1.0)
	layout_check("a02 start")
	note("a02 roster: heavy_works '%s', pendulum '%s', light works '%s'" % [game.requirement_text(game.human, "heavy_works"),
		game.requirement_text(game.human, "pendulum"), game.requirement_text(game.human, "movement_works")])
	set_speed(float(arg("speed", "6")))
	var think := 0.0
	var last := -60.0
	var t0 := Time.get_ticks_msec()
	var quit_at := float(arg("quit", "-1"))
	while is_instance_valid(game) and not game.over:
		await wait(0.25)
		watch()
		if game.clock - last >= 60.0:
			last = game.clock
			_status()
		if float(arg("until", "99999")) < game.clock:
			note("stopped at %d (until=)" % game.clock)
			return
		if quit_at > 0 and game.clock >= quit_at:
			quit_at = -1
			set_speed(1.0)
			await menu_item("QUIT TO MENU")
			await wait(1.0)
			check("a02 quit: back at a menu, no match", main.game == null, str(page_texts(5)))
			_fired_seen.clear()
			_obj_seen.clear()
			if not await start_mission("clockmaker", mid, arg("diff", "normal"), side):
				return
			set_speed(float(arg("speed", "6")))
			continue
		if game.clock >= think:
			think = game.clock + 2.0
			if side == "guild":
				match player:
					"careful", "chaos":
						await guild_careful()
					"reckless":
						await guild_reckless()
			else:
				if player in ["careful", "chaos"]:
					await machine_careful()
		await _shots()
		if Time.get_ticks_msec() - t0 > 2400 * 1000:
			finding("a02 %s %s: not over after 40 real minutes (clock %d)" % [side, player, game.clock])
			break
	var title := await await_end(int(arg("endpages", "3")))
	note("a02 %s %s ended: %s; flags %s; objectives %s" % [side, player, title, run.flags if run else {}, run.obj if run else {}])
	note("progress after: %s" % [Campaign.progress().get("done", {}).get(mid, {})])
	note("reached: %s" % [Campaign.progress().get("reached", [])])
	if await press_name("End_CAMPAIGN"):
		await wait(0.6)
		note("after CAMPAIGN: %s" % [page_texts(8)])
		await snap("hub_after_a02_%s" % side, 0.6)


func _status() -> void:
	var hw := run.tagged("hollweg")
	var ho := run.tagged("honest")
	var left := ""
	if run.clocks.has("line"):
		left = "%ds" % int(float(run.clocks["line"]) - game.clock)
	note("STATUS t=%d side=%s cogs=%d mine=%d machine=%d army=%d sorties=%d hollweg=%s honest=%s mill=%s line_in=%s" % [game.clock, side, gold(),
		mine().size(), run.count({"team": "machine"}), run.count({"team": "army"}), int(run.counters.get("sorties", 0)),
		"dead" if hw.is_empty() else "%d" % hw[0].hp, "gone" if ho.is_empty() else "%d" % ho[0].hp,
		"up" if not run.tagged("seed_mill").is_empty() else "-", left])


var _shot_done := {}


func _shots() -> void:
	var want := {"part2": run.obj.get("hold", "") == "active" and game.clock > float(run.fired.get("sortie_1", 1e9)) + 30,
		"part3": run.obj.get("mill", "") == "active",
		"mid": game.clock > 600}
	var where := {"part2": "meadow_gate", "part3": "mill", "mid": "road_gate"}
	for k in want:
		if want[k] and not _shot_done.has(k):
			_shot_done[k] = true
			var keep := speed
			set_speed(1.0)
			await look_at(run.area_rect(where[k]).get_center())
			await snap("a02_%s_%s" % [side, k], 0.4)
			layout_check("a02 " + k)
			set_speed(keep)


func _army() -> Array:
	return mine().filter(func(u) -> bool: return u.kind in ["clock_soldier", "springer", "netter", "pendulum"])


func _green_cell(k: String, near_b: Entity) -> Vector2i:
	var c0 := game.cell_of(near_b.position)
	for r in range(3, 16):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var c := c0 + Vector2i(dx, dy)
				if game.placement_problem(game.human, k, c) == "":
					return c
	return Vector2i(-1, -1)


var _sent_hollweg := false
var _built_lw := false
var _gates_set := false


func guild_careful() -> void:
	var hol := run.tagged("hollweg")
	var honest: Array = run.tagged("honest")
	if honest.is_empty():
		return
	var ho: Building = honest[0]
	# Hollweg to the Honest One (the stop-work), once; back there if he wanders
	if not hol.is_empty() and run.obj.get("stopwork", "") == "active" and not run.area_rect("honest_ring").has_point(hol[0].position) and hol[0].velocity.length() < 5:
		await select(hol)
		await order_to(run.area_rect("honest_ring").get_center())
	# a Light Works when allowed, then Regulators; Clock Soldiers
	var winders := mine("winder")
	var plan := ["movement_works", "regulator", "regulator"]
	var seen := {}
	for k in plan:
		seen[k] = int(seen.get(k, 0)) + 1
		if my_buildings(k).size() >= int(seen[k]):
			continue
		if winders.is_empty() or gold() < int(Defs.BUILDINGS[k]["cost"]) + 10:
			break
		var why := game.requirement_text(game.human, k)
		if why != "":
			if not _said.has(k):
				_said[k] = true
				note("can't build %s yet: %s" % [k, why])
			break
		var c := _green_cell(k, ho)
		if c.x >= 0:
			note("build %s at %s: %s" % [k, c, await build(winders[0], k, c)])
		break
	for lw in my_buildings("movement_works"):
		if lw.built and lw.queue.size() < 2 and gold() >= 80:
			if not on_screen(spot_of(lw)):
				await look_at(spot_of(lw))
			await click_at(w2s(spot_of(lw)))
			await frames(2)
			if not await press_card(["clock_soldier"], true):
				var cs: Array = card().filter(func(x): return x["icon"] == "clock_soldier")
				if not _said.has("train") and not cs.is_empty():
					_said["train"] = true
					note("can't train: %s" % cs[0]["why"])
			break
	var army := _army()
	if run.obj.get("hold", "") == "active":
		# the army split over the two gates, inside the line
		var idle := army.filter(func(u): return u.target == null or not is_instance_valid(u.target))
		if idle.size() >= 2 and (not _gates_set or randf() < 0.3):
			_gates_set = true
			var half := idle.size() / 2
			await select(idle.slice(0, half))
			await order_to(run.area_rect("inside_n").get_center(), true)
			await select(idle.slice(half))
			await order_to(run.area_rect("inside_s").get_center(), true)
		if not hol.is_empty() and not run.area_rect("barn").has_point(hol[0].position) and hol[0].velocity.length() < 5:
			await select(hol)
			await order_to(run.area_rect("barn").get_center())
	elif run.obj.get("mill", "") == "active" and not run.tagged("seed_mill").is_empty():
		var seed: Building = run.tagged("seed_mill")[0]
		var idle2 := army.filter(func(u): return u.target == null or not is_instance_valid(u.target))
		if idle2.size() >= 3:
			await select(idle2)
			await order_to(seed.position, true)
	if run.obj.get("mill", "") == "active" and not _said.has("p3roster"):
		_said["p3roster"] = true
		note("a02 part 3 roster: heavy_works '%s', pendulum '%s' (c01 gate %s)" % [game.requirement_text(game.human, "heavy_works"),
			game.requirement_text(game.human, "pendulum"), Campaign.flag("c01_thirteenth", "gate")])
		if Campaign.flag("c01_thirteenth", "gate") == "pattern" and game.requirement_text(game.human, "heavy_works") != "":
			finding("a02 part 3: c01's drawings (gate pattern) should open the Heavy Works; it says '%s'" % game.requirement_text(game.human, "heavy_works"))


var _said := {}


func guild_reckless() -> void:
	var hol := run.tagged("hollweg")
	if hol.is_empty():
		return
	if game.clock > 30 and hol[0].velocity.length() < 5:
		await select(hol)
		await order_to(run.area_rect("meadow_mid").get_center())


func machine_careful() -> void:
	var army := _army()
	var honest: Array = run.tagged("honest")
	var target: Vector2 = honest[0].position if not honest.is_empty() else run.area_rect("barn").get_center()
	var idle := army.filter(func(u): return (u.target == null or not is_instance_valid(u.target)) and u.velocity.length() < 5)
	# wait for a band of 10 (as a player gathers before he walks), then all at the Honest One
	if idle.size() >= 10 or (game.clock > 420 and idle.size() >= 4):
		await select(idle)
		await order_to(target, true)
	for lw in my_buildings("movement_works"):
		if lw.built and lw.queue.size() < 2 and gold() >= 80:
			if not on_screen(spot_of(lw)):
				await look_at(spot_of(lw))
			await click_at(w2s(spot_of(lw)))
			await frames(2)
			await press_card(["clock_soldier", "springer"], true)
			break
