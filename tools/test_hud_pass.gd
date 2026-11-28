extends SceneTree
## The match HUD pass (job ui-hud-pass, docs/ui_hud_pass.md), in a real match:
##   godot --headless --fixed-fps 30 --script res://tools/test_hud_pass.gd 2>&1 | grep -E "FAIL|PASS|DONE"
##  1. HOTKEY PRIORITY: a Barracks + Musketeers selected: A attacks (no Musketeer queued), the Barracks' buttons follow
##     the units' and no letter of theirs is a unit command's; the Barracks alone: A trains a Musketeer
##  2. JUMP TO LAST ALERT: two alerts, Home goes to the newest, Home again to the one before
##  3. SUPPLY BLOCKED: a train refused for supply blocks (the pill flashes), room again ends it
##  4. GLOWS: IDLE glows with an idle worker; MAKE glows with every production building idle, not while one trains;
##     ARMY glows while a soldier was just hit
##  5. TOOLTIPS: the parts hold every word of the old tooltip (cost on the title line, a summary first)
##  6. INCOME A MINUTE in the resource tooltip, SHOW APM switch
var fails := 0


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _key(kc: int) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = kc as Key
	e.pressed = true
	return e


func _build(g: Game, kind: String) -> Building:
	var hall: Building = g.halls_of(0)[0]
	for r in range(5, 22):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var c: Vector2i = hall.cell + Vector2i(dx, dy)
				if g.placement_problem(0, kind, c) == "":
					return g._add_building(kind, 0, c, true)
	return null


func _words(s: String) -> Dictionary:
	var out := {}
	for w in s.replace("\n", " ").replace("·", " ").split(" ", false):
		out[w] = true
	return out


func _run() -> void:
	var was_apm := Settings.show_apm
	var was_grid := Settings.grid_keys
	Settings.grid_keys = false
	var dev := Settings.device
	Settings.device = "pc"
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.start({"map": "greenhold", "seed": 5, "slots": [
		{"who": "you", "faction": "crown", "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "hard", "faction": "crown", "colour": 1, "side": 1, "strategy": "balanced"}]})
	await process_frame
	await process_frame
	var g: Game = main.game
	var hud = g.hud
	hud.countdown = 0.0
	paused = false
	for ai in g.ais:
		ai.process_mode = Node.PROCESS_MODE_DISABLED
	for i in 5:
		await physics_frame
	g.players[0]["gold"] = 5000
	g.players[0]["res2"] = 500
	var bar_ks: Building = _build(g, "barracks")
	check(bar_ks != null, "a Barracks to test with")
	var men: Array = []
	var c: Vector2 = g.halls_of(0)[0].center() + Vector2(0, 160)
	for i in 4:
		var u := g._add_unit("musketeer", 0, c + Vector2(i * 26, 0))
		men.append(u)

	# ---------------------------------------------------------------- 1. hotkey priority
	g.set_selection(men + [bar_ks])
	await process_frame
	hud._refresh_card()
	var items: Array = hud._card_items
	var labs: Array = items.map(func(it: Array) -> String: return String(it[1]).trim_prefix("> ").trim_prefix("~ "))
	check(labs.has("ATTACK") and labs.has("MUSKETEER"), "units + Barracks: the card has ATTACK and the Barracks' MUSKETEER (%s)" % str(labs))
	check(labs.find("ATTACK") < labs.find("MUSKETEER"), "the units' commands come first")
	var unit_keys := {}
	var sec_keys: Array = []
	for it in items:
		var k := String(it[6]) if it.size() > 6 else ""
		if hud._sec_for.has(hud.card_label(it)):
			sec_keys.append(k)
		elif k != "":
			unit_keys[k] = true
	var clash := sec_keys.filter(func(k: String) -> bool: return k != "" and unit_keys.has(k))
	check(clash.is_empty(), "no building letter is a unit command's (building keys %s)" % str(sec_keys))
	var mi: int = labs.find("MUSKETEER")
	check(String(items[mi][6]) == "", "MUSKETEER shows no letter there (A is ATTACK)")
	hud.hotkey(KEY_A)
	await process_frame
	check(g.controls.mode == "attack", "A with units + Barracks: attack (mode %s)" % g.controls.mode)
	check(bar_ks.queue.is_empty(), "...and no Musketeer queued")
	g.controls.cancel_mode()
	# a building button still works from the mixed card (click)
	var before := bar_ks.queue.size()
	(items[mi][2] as Callable).call()
	await process_frame
	check(bar_ks.queue.size() == before + 1, "clicking MUSKETEER on the mixed card trains one at the Barracks")
	check(g.selection.size() == men.size() + 1, "...and the selection stays as it was")
	bar_ks.queue.clear()
	# the Barracks alone: A trains
	g.set_selection([bar_ks])
	await process_frame
	hud._refresh_card()
	hud.hotkey(KEY_A)
	await process_frame
	check(bar_ks.queue.has("musketeer"), "the Barracks alone: A trains a Musketeer (%s)" % str(bar_ks.queue))
	bar_ks.queue.clear()

	# ---------------------------------------------------------------- 2. jump to last alert
	var p1: Vector2 = g.halls_of(0)[0].center() + Vector2(600, 0)
	var p2: Vector2 = g.halls_of(0)[0].center() + Vector2(0, 700)
	hud.note_alert(p1, "attack", "Your forces are under attack!")
	g.clock += 1.0
	hud.note_alert(p2, "built", "Barracks finished.")
	hud.bar.key(_key(KEY_HOME))
	check(g.camera.position.distance_to(p2) < 1.0, "Home: the camera goes to the newest alert")
	hud.bar.key(_key(KEY_HOME))
	check(g.camera.position.distance_to(p1) < 1.0, "Home again: the one before")
	hud.note_alert(p1 + Vector2(20, 0), "attack", "Your forces are under attack!")
	check(hud.alerts().list.size() == 2, "a new alert beside a fresh one of its kind replaces it (%d kept)" % hud.alerts().list.size())

	# ---------------------------------------------------------------- 3. supply blocked
	g.players[0]["cap"] = g.supply_used(0)
	var why: String = g.train(bar_ks, "musketeer")
	check(why.to_lower().contains("supply"), "a Musketeer at full supply is refused (%s)" % why)
	check(hud.alerts().blocked(), "SUPPLY BLOCKED is on")
	check(hud._msg.contains(Loc.t("SUPPLY BLOCKED: production is waiting.")), "...and says so once (%s)" % hud._msg)
	g._recount_supply(0)
	g.players[0]["cap"] = g.supply_used(0) + 20
	check(not hud.alerts().blocked(), "room again: no longer blocked")

	# ---------------------------------------------------------------- 4. glows
	hud._refresh_counts()
	var idle_n := int(hud._counts[1])
	var lab0: Unit = null
	for u in g.labourers(0):
		lab0 = u
		break
	if lab0:
		lab0.order = "idle"
	hud._refresh_counts()
	await physics_frame
	var gl: Array = hud.alerts().glows(int(hud._counts[1]))
	check(bool(gl[0]) == (int(hud._counts[1]) > 0), "IDLE glows when a worker is idle (%d idle, was %d)" % [int(hud._counts[1]), idle_n])
	g.clock = maxf(g.clock, 30.0)
	for b in hud.bar.production_buildings():
		(b as Building).queue.clear()
	await physics_frame
	gl = hud.alerts().glows(0)
	check(bool(gl[2]), "MAKE glows with every production building idle")
	g.train(bar_ks, "musketeer")
	await physics_frame
	gl = hud.alerts().glows(0)
	check(not bool(gl[2]), "...not while the Barracks trains")
	bar_ks.queue.clear()
	men[0].hit_clock = g.clock
	await physics_frame
	gl = hud.alerts().glows(0)
	check(bool(gl[1]), "ARMY glows while a soldier was just hit")

	# ---------------------------------------------------------------- 5. tooltips keep every word
	g.set_selection([bar_ks])
	await process_frame
	hud._refresh_card()
	for it in hud._card_items:
		if hud.card_label(it) == "MUSKETEER":
			var tip: Dictionary = hud._card_tip(it)
			var parts: Dictionary = hud.tip_parts(tip)
			var old_w := _words(Loc.t(String(tip.get("stats", ""))) + " " + Loc.t(String(tip.get("body", ""))) + " " + Loc.t(String(tip.get("hint", ""))))
			var new_w := _words(" ".join([parts["cost"], parts["sum"], parts["stats"], parts["detail"], parts["hint"]]))
			var lost: Array = old_w.keys().filter(func(w: String) -> bool: return not new_w.has(w))
			check(lost.is_empty(), "the Musketeer's tooltip keeps every word (lost %s)" % str(lost))
			check(String(parts["cost"]).contains("gold"), "its cost is on the title line (%s)" % parts["cost"])
			check(String(parts["sum"]) != "" and String(parts["sum"]).length() <= 160, "a short summary first: %s" % parts["sum"])
	var long_tip := {"title": "x", "body": "Gold pays for everything. Labourers on Farms bring in the harvests from their Town Hall's soil. The soil runs out, and spent soil pays nothing: expand to a fresh Town Hall."}
	var lp: Dictionary = hud.tip_parts(long_tip)
	check(String(lp["sum"]) == "Gold pays for everything." and String(lp["detail"]).begins_with("Labourers"), "a long body: its first sentence is the summary, the rest below (%s | %s)" % [lp["sum"], lp["detail"]])

	# ---------------------------------------------------------------- 6. income a minute, APM switch
	for i in 3:
		g.clock += 5.0
		g.stats[0]["gold"] = float(g.stats[0]["gold"]) + 100.0
		g.players[0]["gold"] = float(g.players[0]["gold"]) + 50.0
		hud.alerts().sample(0)
	var rt: Dictionary = hud._res_tip(0)
	check(String(rt.get("sum", "")).contains(Loc.t("a minute")) or String(rt.get("sum", "")).contains("minute"), "the gold tooltip starts with income and spending a minute: %s" % rt.get("sum", ""))
	var rs: Vector2 = hud.alerts().rates(0, 0)
	check(rs.x > 0.0 and rs.y > 0.0, "income %.0f and spent %.0f a minute from the samples" % [rs.x, rs.y])
	var sp: Dictionary = hud._res_tip(2)
	check(String(sp.get("sum", "")).begins_with("Workers"), "the supply tooltip starts with workers / army / production: %s" % sp.get("sum", ""))
	Settings.show_apm = false
	check(not Settings.show_apm, "SHOW APM can be switched off")

	Settings.show_apm = was_apm
	Settings.grid_keys = was_grid
	Settings.device = dev
	print("DONE  %d failures" % fails)
	quit(1 if fails > 0 else 0)
