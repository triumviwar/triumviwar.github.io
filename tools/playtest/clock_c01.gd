extends "res://tools/playtest/pt_match.gd"
## PLAYTEST, c01_thirteenth "The Thirteenth Hour" played from the main menu as a person (job playtest-campaign-clock).
## Args (plus pt_lib's): player=careful|passive|reckless|jakob|chaos  bells=rung|quiet|wait  gate=people|pattern|wait
##   diff=easy|normal|hard  speed=<time scale>  pages=<opening pages to watch>  drawings=1|0  quit=<game secs: quit to
##   the menu then and start again>
## careful: plays the whole mission to win; passive: never gives an order (the story should still move, then Hollweg is
## trapped: DEFEAT); reckless: walks Hollweg into the machine (DEFEAT: Hollweg killed); jakob: sends Jakob alone into the
## mill island at dusk (he should die; the mission goes on, flag jakob lost); chaos: plays as careful but clicks around,
## pauses, opens SETTINGS, presses Esc and resizes the window at odd moments.

var player := "careful"
var mid := "c01_thirteenth"


func play() -> void:
	player = arg("player", "careful")
	choice_picks = {"bells": arg("bells", "quiet"), "gate": arg("gate", "pattern")}
	set_progress({"p01_leaf": ["crown", {"families": "save"}]})
	var ok := await start_mission("clockmaker", mid, arg("diff", "normal"), "", true, int(arg("pages", "0")))
	if not ok:
		return
	await snap("start", 1.0)
	layout_check("c01 start")
	set_speed(float(arg("speed", "6")))
	var quit_at := float(arg("quit", "-1"))
	var t0 := Time.get_ticks_msec()
	var think := 0.0
	var last_print := -60.0
	while is_instance_valid(game) and not game.over:
		await wait(0.25)
		watch()
		await answer_choice()
		if game.clock - last_print >= 60.0:
			last_print = game.clock
			_status()
		if float(arg("until", "99999")) < game.clock:
			note("stopped at %d (until=)" % game.clock)
			return
		if quit_at > 0 and game.clock >= quit_at:
			quit_at = -1
			await _quit_and_restart()
			continue
		if game.clock >= think:
			think = game.clock + 2.0
			match player:
				"careful", "chaos":
					await careful()
				"reckless":
					await reckless()
				"jakob":
					await jakob_alone()
				"passive":
					pass
			if player == "chaos":
				await chaos()
		await _shots()
		if Time.get_ticks_msec() - t0 > 2400 * 1000:
			finding("c01 %s: still not over after 40 real minutes (game clock %d)" % [player, game.clock])
			break
	var title := await await_end(int(arg("endpages", "3")))
	note("c01 %s ended: %s; flags %s; objectives %s" % [player, title, run.flags if run else {}, run.obj if run else {}])
	var p := Campaign.progress()
	note("progress after: %s" % [p.get("done", {}).get(mid, {})])
	# the end panel's buttons: CAMPAIGN, back to the hub (does it show the hub after the fall?)
	if await press_name("End_CAMPAIGN"):
		await wait(0.6)
		note("after CAMPAIGN: %s" % [page_texts(6)])
		await snap("hub_after", 0.6)


func _status() -> void:
	var seeds := ["seed_mill", "seed_baths", "seed_market", "seed_east"].filter(func(s): return not run.tagged(s).is_empty())
	var left := ""
	if run.clocks.has("fall"):
		left = "%ds" % int(float(run.clocks["fall"]) - game.clock)
	note("STATUS t=%d cogs=%d army=%d machine=%d seeds=%s saved=%d/%d hollweg=%s jakob=%s fall_in=%s sel=%d" % [game.clock, gold(),
		_army().size(), run.count({"team": "machine"}), ",".join(seeds), int(run.counters.get("saved", 0)), int(run.counters.get("townsfolk", 0)),
		_hp("hollweg"), _hp("jakob"), left, game.selected_units().size()])
	if not run.tagged("hollweg").is_empty():
		var h: Unit = run.tagged("hollweg")[0]
		note("  hollweg at %s order %s, machines within 8 tiles: %d" % [game.cell_of(h.position), h.get("order") if "order" in h else "?",
			game.units.filter(func(u): return not u.dead and u.team == run.team_index("machine") and u.position.distance_to(h.position) < 256).size()])


func _hp(tg: String) -> String:
	var a := run.tagged(tg)
	return "dead" if a.is_empty() else "%d/%d" % [a[0].hp, a[0].max_hp]


func _army() -> Array:
	return mine().filter(func(u) -> bool: return u.kind in ["clock_soldier", "springer", "netter", "pendulum"] and not run.tagged("hollweg").has(u))


var _shot_done := {}


func _shots() -> void:
	var want := {"gift": run.fired.has("gift") and game.clock > float(run.fired.get("gift", 0)) + 15,
		"found": run.fired.has("found") and game.clock > float(run.fired.get("found", 0)) + 3,
		"turn": run.fired.has("turned_go") and game.clock > float(run.fired.get("turned_go", 0)) + 3,
		"night": run.fired.has("lost") and game.clock > float(run.fired.get("lost", 0)) + 60,
		"late": run.clocks.has("fall") and float(run.clocks["fall"]) - game.clock < 100,
		"stroke": run.fired.has("stroke")}
	var where := {"gift": "workshop", "found": "mill_island", "turn": "workshop", "night": "road_w", "late": "gate_in", "stroke": "gate_in"}
	for k in want:
		if want[k] and not _shot_done.has(k):
			_shot_done[k] = true
			var keep := speed
			set_speed(1.0)
			await look_at(run.area_rect(where[k]).get_center())
			await snap("c01_" + k, 0.4)
			layout_check("c01 " + k)
			set_speed(keep)


# ------------------------------------------------------------------ the careful player

var _order_sent := false
var _why_said := false
var _why_n := 0
var _placing: Array = []
var _jakob_sent := false


func careful() -> void:
	var hall: Building = run.tagged("perpetual")[0] if not run.tagged("perpetual").is_empty() else null
	var part := 1 if not run.fired.has("dusk") else (2 if not run.fired.has("lost") else 3)
	# economy: a Light Works, then Clock Soldiers (part 1 and 2)
	if hall and part < 3:
		var winders := mine("winder").filter(func(u): return not run.tagged("children").has(u))
		# the build order a player learns from the card's refusals: a Light Works, then Regulators when "Need more supply"
		var plan := ["movement_works", "regulator", "regulator", "movement_works", "regulator"]
		var seen := {}
		for k in plan:
			seen[k] = int(seen.get(k, 0)) + 1
			if my_buildings(k).size() >= int(seen[k]):
				continue
			if winders.is_empty() or gold() < int(Defs.BUILDINGS[k]["cost"]) + 10:
				break
			var c := _green_cell(k, hall)
			if c.x >= 0:
				var ok := await build(winders[0], k, c)
				note("build %s at %s: %s" % [k, c, ok])
			else:
				note("build %s: no green spot near the Perpetual" % k)
			break
		for lw in my_buildings("movement_works"):
			if lw.built and lw.queue.size() < 2 and gold() >= 80:
				await select_building(lw)
				if not await press_card(["clock_soldier", "CLOCK SOLDIER"], true):
					_why_n += 1
					if _why_n <= 6:
						var cs: Array = card().filter(func(x): return x["icon"] == "clock_soldier")
						note("could not train at %s (built %s, on the gears %s): %s" % [lw.cell if "cell" in lw else lw.position, lw.built,
							lw.get("powered") if "powered" in lw else "?", cs[0]["why"] if not cs.is_empty() else card_text()])
						note("   selected: %s / %s; card: %s; clicked %s (world %s, cam %s, zoom %s, mode '%s')" % [game.selected_building(), game.selected_units().map(func(u): return u.kind), card_text(),
							w2s(lw.position), lw.position, game.camera.position, game.camera.zoom, game.controls.mode])
						if _why_n == 1:
							await snap("dbg_train", 0.1)
				break
	var army := _army()
	if part == 1:
		if run.obj.get("order", "") == "active" and army.size() >= 6 and not _order_sent:
			_order_sent = true
			await select(army.slice(0, 6))
			await order_to(run.area_rect("wagons").get_center())
			note("six sent to the wagons (selected %d)" % game.selected_units().size())
		elif _order_sent and run.obj.get("order", "") == "active" and game.clock > 400:
			_order_sent = false      # (try again: some never got there)
		return
	var jak: Array = run.tagged("jakob")
	var hol: Array = run.tagged("hollweg")
	if part == 2:
		if run.obj.get("look", "") == "active":
			if not jak.is_empty() and not _jakob_sent:
				_jakob_sent = true
				await select(jak)
				await order_to(run.area_rect("mill_bank").get_center())
				await select(army)
				await order_to(run.area_rect("mill_bank").get_center(), true)
			return
		if not run.tagged("seed_mill").is_empty():
			var seed: Building = run.tagged("seed_mill")[0]
			var idle := army.filter(func(u): return u.target == null or not is_instance_valid(u.target))
			if idle.size() >= 3:
				await select(idle)
				await order_to(seed.position, true)
			# the netter: catch one (its ability, or a right click on a red machine)
			var nets := mine("netter")
			if not nets.is_empty() and run.obj.get("catch", "") == "active":
				var foe := _nearest_foe(nets[0], 600.0)
				if foe:
					await select(nets)
					await order_on(foe)
		return
	# part 3: Hollweg to the gate, Jakob to the Guild House and back, the army on the west road
	if not hol.is_empty() and not run.area_rect("gate_in").has_point(hol[0].position) and hol[0].velocity.length() < 5.0:
		await select(hol)
		await order_to(run.area_rect("gate_in").get_center())
	if not jak.is_empty():
		var to := "guildhouse" if arg("drawings", "1") == "1" and run.obj.get("drawings", "") == "active" else "gate_in"
		if not run.area_rect(to).has_point(jak[0].position) and jak[0].velocity.length() < 5.0:
			await select(jak)
			await order_to(run.area_rect(to).get_center())
	var idle2 := army.filter(func(u): return (u.target == null or not is_instance_valid(u.target)) and u.velocity.length() < 5.0)
	if idle2.size() >= 1:
		# the army walks with Hollweg (attack-move to him), then holds the gate's road
		var goal: Vector2 = run.area_rect("road_w").get_center()
		if not hol.is_empty() and not run.area_rect("gate_in").has_point(hol[0].position):
			goal = hol[0].position
		await select(idle2)
		await order_to(goal, true)


## A cell where the ghost shows green (as a player slides it until it does), near the hall, spiralling out.
func _green_cell(k: String, hall: Building) -> Vector2i:
	var c0 := game.cell_of(hall.position)
	for r in range(3, 16):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var c := c0 + Vector2i(dx, dy)
				if game.placement_problem(game.human, k, c) == "":
					return c
	return Vector2i(-1, -1)


func select_building(b: Building) -> void:
	if not on_screen(spot_of(b)):
		await look_at(spot_of(b))
	if not on_screen(spot_of(b)):
		finding("could not bring %s into the middle of the view with the minimap" % b.kind)
	await click_at(w2s(spot_of(b)))
	await frames(2)


func _nearest_foe(u: Unit, reach: float) -> Unit:
	var mt := run.team_index("machine")
	var best: Unit = null
	var bd := reach
	for f in game.units:
		if f.dead or f.team != mt:
			continue
		var d := u.position.distance_to(f.position)
		if d < bd:
			bd = d
			best = f
	return best


# ------------------------------------------------------------------ the others

func reckless() -> void:
	# play part 1 normally (so the story moves), then walk Hollweg alone at the machine
	if not run.fired.has("dusk"):
		await careful()
		return
	var hol: Array = run.tagged("hollweg")
	if hol.is_empty():
		return
	var target: Vector2 = run.area_rect("mill_island").get_center()
	if hol[0].position.distance_to(target) > 64:
		await select(hol)
		await order_to(target)


func jakob_alone() -> void:
	if not run.fired.has("dusk"):
		await careful()
		return
	var jak: Array = run.tagged("jakob")
	if not jak.is_empty():
		await select(jak)
		await order_to(run.area_rect("mill_island").get_center())
	# then play on as the careful player (the army), Jakob or no Jakob
	_jakob_sent = true
	await careful()


var _chaos_n := 0


func chaos() -> void:
	_chaos_n += 1
	var r := _chaos_n % 9
	var keep := speed
	match r:
		0:
			# random clicks on the map and the HUD
			var vr := root.get_visible_rect()
			for i in 6:
				await click_at(Vector2(randf() * vr.size.x, randf() * vr.size.y))
			await key(KEY_ESCAPE)
		1:
			# pause, look, resume (P? the menu's PAUSE)
			set_speed(1.0)
			if await menu_item("PAUSE"):
				await snap("chaos_paused", 0.3)
				layout_check("paused menu")
				var c0 := game.clock
				await wait(1.0)
				check("paused: the clock stands", absf(game.clock - c0) < 0.05, "%f %f" % [c0, game.clock])
				await menu_item("RESUME")
				if game.hud.menu_open:
					await menu_item("BACK TO THE MATCH")
			set_speed(keep)
		2:
			# the settings page over the match, then back
			set_speed(1.0)
			if await menu_item("SETTINGS"):
				await wait(0.5)
				await snap("chaos_settings", 0.2)
				layout_check("settings over a mission")
				await key(KEY_ESCAPE)
				await wait(0.3)
				if game.hud.settings_open:
					finding("Esc did not close the Settings page over the mission")
					var bb := button_text("BACK")
					await press(bb, "Settings BACK")
			if game.hud.menu_open:
				await menu_item("BACK TO THE MATCH")
			set_speed(keep)
		3:
			# resize the window (a phone turned, a window dragged)
			var w := get_root().size
			DisplayServer.window_set_size(Vector2i(900, 600))
			await wait(0.6)
			await snap("chaos_resized", 0.3)
			layout_check("resized 900x600")
			DisplayServer.window_set_size(w)
			await wait(0.4)
		4:
			# a dialogue line: SKIP / NEXT pressed if one is up
			var nb := ctrl("Dialogue_NEXT", "Button")
			if nb:
				await press(nb, "dialogue NEXT")
		5:
			# the minimap dragged, the wheel, an edge of the map
			await look_at(Vector2(0, 0))
			await look_at(Vector2(Game.W, Game.H) * Game.T)
			var e := InputEventMouseButton.new()
			e.button_index = MOUSE_BUTTON_WHEEL_UP
			e.pressed = true
			e.position = to_window(root.get_visible_rect().get_center())
			Input.parse_input_event(e)
		6:
			# double-click a unit (all of its type) and order them nowhere (off the map)
			var a := _army()
			if not a.is_empty() and on_screen(a[0].position):
				await double_click_at(w2s(spot_of(a[0])))
				await right_click_at(Vector2(-50, -50))
		7:
			# a hotkey storm
			for k in [KEY_F1, KEY_F2, KEY_1, KEY_SPACE, KEY_H, KEY_S, KEY_B, KEY_ESCAPE]:
				await key(k)
		8:
			await key(KEY_ESCAPE)
			await key(KEY_ESCAPE)


func _quit_and_restart() -> void:
	note("quitting to the menu at %d" % game.clock)
	set_speed(1.0)
	await menu_item("QUIT TO MENU")
	await wait(1.0)
	note("after QUIT TO MENU: %s; game %s" % [page_texts(8), main.game])
	await snap("after_quit", 0.4)
	check("quit from a mission: no match left", main.game == null)
	check("quit from a mission: progress not counted", not Campaign.progress()["done"].has(mid))
	said_log.clear()
	_fired_seen.clear()
	_obj_seen.clear()
	_order_sent = false
	_jakob_sent = false
	var ok := await start_mission("clockmaker", mid, arg("diff", "normal"))
	if ok:
		set_speed(float(arg("speed", "6")))
