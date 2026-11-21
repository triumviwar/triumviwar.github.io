extends "res://tools/playtest/pt_base.gd"
## A FACTION LESSON (lesson:t10_crown | t20_clockwork | t30_brood) played from the main menu by a new player who
## follows the task and the pointer with real clicks / taps: select by clicking the unit, the command card's buttons,
## BUILD and a click (two taps on a phone) on the ground, right-click (tap) to send workers. Every step's line, task,
## pointer and the card's buttons are logged. player:careful (default) or player:sloppy (clicks the card's buttons it
## sees before reading, cancels a building, idles, loses workers).
## (see pt_base.gd for the command line)

var who := "careful"
var lesson := "t10_crown"
var step_t := {}


func play() -> void:
	who = String(args.get("player", "careful"))
	lesson = String(args.get("lesson", "t10_crown"))
	await press_button("Menu_tutorial")
	await wait(0.5)
	await press_button("Lesson_" + lesson)
	await wait(0.3)
	await shot(lesson + "_card")
	await press_button("Lesson_Start")
	await wait(4.0)
	var g := game()
	if not expect(g != null and g.mission != null, "the lesson started"):
		return
	await shot(lesson + "_start")
	var t0 := Time.get_ticks_msec()
	var last := ""
	var stuck := 0.0
	Engine.time_scale = float(args.get("speed", "2"))
	var cap := float(args.get("cap", "1500"))
	while g and is_instance_valid(g) and not g.over and stuck < 240.0 and g.clock < cap:
		var act := task_ids_active().filter(func(x: String) -> bool: return x.begins_with("task_"))
		var cur: String = act[0].trim_prefix("task_") if not act.is_empty() else ""
		if cur != last:
			if last != "":
				step_t[last] = g.clock - float(step_t.get(last + "_from", g.clock))
			step_t[cur + "_from"] = g.clock
			note("STEP %s at %.0f s: %s" % [cur, g.clock, lesson_state()])
			if cur != "":
				await shot("%s_%s" % [lesson, cur])
			last = cur
			stuck = 0.0
		if cur == "":
			await read_lines(2)
			await wait(1.0)
			stuck += 1.0
			continue
		var before := g.clock
		await do_step(cur)
		await wait(2.0)
		stuck += 2.0 + (g.clock - before) * 0.0
	Engine.time_scale = 1.0
	var end_ := root.find_child("LessonEnd", true, false)
	note("lesson over=%s LessonEnd=%s in %.0f s game time (%.0f s real); steps: %s" % [g.over if g else "-", end_ != null, g.clock if g else 0.0, (Time.get_ticks_msec() - t0) / 1000.0, str(step_t)])
	if stuck >= 240.0:
		find("%s: STUCK on step '%s' for 240 s of trying: %s" % [lesson, last, lesson_state()])
	await wait(1.0)
	await shot(lesson + "_end")
	print("PT OFFSCREEN ", off_screen())


# ------------------------------------------------------------------ small actions
func mine(kind: String) -> Array:
	var g := game()
	var out_: Array = []
	for e in g.units + g.buildings:
		if e.team == g.human and not e.dead and e.kind == kind:
			out_.append(e)
	return out_


func pos_of(e: Entity) -> Vector2:
	return e.position if e is Unit else e.center()


## Click (tap) an entity of mine to select it, looking at it first.
func select(e: Entity) -> void:
	if not in_view(pos_of(e)):
		await look_at(pos_of(e))
	await press_at(world_to_screen(pos_of(e)))
	await wait(0.2)


func select_also(e: Entity) -> void:
	if phone:
		return
	if not in_view(pos_of(e)):
		return
	await click(world_to_screen(pos_of(e)), MOUSE_BUTTON_LEFT, {"shift": true})


## Right-click (tap) a world point / entity with the selection.
func order(w: Vector2) -> void:
	if not in_view(w):
		await look_at(w)
	if phone:
		await tap(world_to_screen(w))
	else:
		await click(world_to_screen(w), MOUSE_BUTTON_RIGHT)


func idle_worker(kind: String) -> Unit:
	var ws := mine(kind)
	if ws.is_empty():
		return null
	ws.sort_custom(func(a, b) -> bool: return a.order == "idle" and b.order != "idle")
	return ws[0]


## BUILD a building with a worker: select it, BUILD, the building's button, then a click (tap tap) on a good spot.
func build(worker_kind: String, kind: String, label: String) -> bool:
	var g := game()
	var w := idle_worker(worker_kind)
	if w == null:
		find("no %s to build a %s" % [worker_kind, kind])
		return false
	await select(w)
	if card_labels().has("BACK") and not card_labels().has("BUILD"):
		await press_card("BACK")          # (a page left open: back to the orders)
	note("card of a %s: %s" % [worker_kind, str(card_labels())])
	if not await press_card("BUILD"):
		return false
	await wait(0.2)
	note("BUILD page: %s" % str(card().map(func(c: Dictionary) -> String: return "%s%s" % [c["label"], "" if c["enabled"] else "(off)"])))
	if not await press_card(label):
		return false
	await wait(0.2)
	var hall: Building = null
	for b in g.buildings:
		if b.team == g.human and not b.dead and b.kind == g.faction_hall(g.human):
			hall = b
			break
	var size: Vector2i = Defs.BUILDINGS[kind]["size"]
	var c := Vector2i(-1, -1)
	# a spot a player would pick: free ground near the hall, seen on the screen away from the panels
	if not in_view(hall.center()):
		await look_at(hall.center())
	var hc := g.cell_of(hall.center())
	for rad in range(3, 16):
		for dy in range(-rad, rad + 1):
			for dx in range(-rad, rad + 1):
				if c.x >= 0 or maxi(absi(dx), absi(dy)) != rad:
					continue
				var cc := hc + Vector2i(dx, dy)
				if g.placement_problem(g.human, kind, cc) != "":
					continue
				var sp0 := world_to_screen((Vector2(cc) + Vector2(size) * 0.5) * Game.T)
				var vs := screen_size()
				if (phone and in_view((Vector2(cc) + Vector2(size) * 0.5) * Game.T)) or \
						(not phone and sp0.x > 430 and sp0.y > 150 and sp0.x < vs.x - 40 and sp0.y < vs.y - 220):
					c = cc
	if c.x < 0:
		c = g.find_spot(g.human, kind, hall, 3, 14) if hall else Vector2i(-1, -1)
	if c.x < 0:
		find("no spot for a %s" % kind)
		return false
	var wpt := (Vector2(c) + Vector2(size) * 0.5) * Game.T
	if not in_view(wpt):
		await look_at(wpt)
	var sp := world_to_screen(wpt)
	var n_before := mine(kind).size()
	await press_at(sp)
	await wait(0.2)
	if mine(kind).size() == n_before:
		await press_at(sp)          # (a phone: the first tap puts the ghost, the second places it)
		await wait(0.2)
	var ok := mine(kind).size() > n_before
	note("placed %s: %s (%s); the screen says: %s" % [kind, ok, c, hud()._msg])
	if not ok:
		find("could not place a %s at %s by clicking (%s)" % [kind, c, g.placement_problem(g.human, kind, c)])
		await key(KEY_ESCAPE)
	return ok


func train(from_kind: String, label: String, n := 1) -> void:
	var bs := mine(from_kind)
	if bs.is_empty():
		find("no %s to train at" % from_kind)
		return
	await select(bs[0])
	var tries := 0
	while not card_labels().any(func(l: String) -> bool: return l.get_slice(" ", 0) == label.get_slice(" ", 0)) and tries < 4:
		if tries == 0:
			find("clicking the %s selected something else (%s): it is hidden behind another building; MAKE (F3) instead" % [from_kind, str(game().selection.map(func(e) -> String: return e.kind))])
		if phone:
			await tap(hud_rect(hud().bar.button_rect(2)).get_center())
		else:
			await key(KEY_F3)
		await wait(0.3)
		tries += 1
	note("card of the %s: %s" % [from_kind, str(card().map(func(c: Dictionary) -> String: return "%s%s" % [c["label"], "" if c["enabled"] else "(off)"]))])
	for i in n:
		await press_card(label)
		await wait(0.3)


func crew(worker_kind: String, site_kind: String, n: int) -> void:
	var sites := mine(site_kind)
	if sites.is_empty():
		return
	var site: Building = sites[0]
	for s in sites:
		if s.crew.size() < site.crew.size():
			site = s
	for i in n:
		var ws := mine(worker_kind).filter(func(u) -> bool: return not site.crew.has(u))
		ws.sort_custom(func(a, b) -> bool: return a.order == "idle" and b.order != "idle")
		if ws.is_empty():
			return
		await select(ws[0])
		await order(site.center())


# ------------------------------------------------------------------ the steps
var _done_once := {}


func do_step(sid: String) -> void:
	var g := game()
	var first := not _done_once.has(sid)
	_done_once[sid] = true
	await read_lines(4)
	if who == "sloppy" and first:
		await sloppy(sid)
	match lesson + ":" + sid:
		# ---------------- the Crown
		"t10_crown:hall":
			await select(g.mission.tagged("hall")[0])
		"t10_crown:labourer":
			if first:
				await train("town_hall", "LABOURER")
		"t10_crown:cottage":
			if first or mine("cottage").is_empty():
				await build("labourer", "cottage", "COTTAGE")
		"t10_crown:mill":
			if mine("powder_mill").is_empty():
				await build("labourer", "powder_mill", "POWDER MILL")
		"t10_crown:mill_crew":
			await crew("labourer", "powder_mill", 2)
		"t10_crown:barracks":
			if mine("barracks").is_empty():
				await build("labourer", "barracks", "BARRACKS")
		"t10_crown:musketeers":
			if first:
				await train("barracks", "MUSKETEER", 3)
		"t10_crown:wall":
			if first:
				await wall()
		"t10_crown:foundry":
			if mine("foundry").is_empty():
				await build("labourer", "foundry", "FOUNDRY")
		"t10_crown:cannon":
			if first:
				await train("foundry", "FIELD CANNON")
		"t10_crown:ridge":
			var ms := mine("musketeer")
			if not ms.is_empty():
				await select(ms[0])
				for m in ms.slice(1):
					await select_also(m)
				await order(g.mission.area_rect("ridge").get_center())
		# ---------------- the Clockwork
		"t20_clockwork:tower":
			await select(g.mission.tagged("tower")[0])
		"t20_clockwork:winder":
			if first:
				await train("clocktower", "WINDER")
		"t20_clockwork:gear_view", "t20_clockwork:gear_view_off":
			if phone:
				await select(mine("clocktower")[0])
				note("tower card: %s" % str(card_labels()))
				await press_card("GEAR VIEW")
			else:
				await key(KEY_QUOTELEFT)
		"t20_clockwork:press":
			if mine("cog_press").size() < 2:
				await build("winder", "cog_press", "COG PRESS")
		"t20_clockwork:press_crew":
			await crew("winder", "cog_press", 1)
		"t20_clockwork:mainspring":
			if mine("mainspring").is_empty():
				await build("winder", "mainspring", "MAINSPRING")
		"t20_clockwork:tension":
			await crew("winder", "mainspring", 1)
		"t20_clockwork:works":
			if mine("movement_works").is_empty():
				await build("winder", "movement_works", "LIGHT WORKS")
		"t20_clockwork:soldiers":
			if first:
				await train("movement_works", "CLOCK SOLDIER", 2)
		# ---------------- the Brood
		"t30_brood:mother":
			await select(BroodNew.queen(g, g.human))
		"t30_brood:eggs":
			if first:
				await select(BroodNew.queen(g, g.human))
				note("Mother's card: %s" % str(card_labels()))
				await press_card("GRUB")
		"t30_brood:turtle":
			if mine("mound_turtle").is_empty():
				await morph("MOUND TURTLE", "mound_turtle", g.mission.area_rect("natural").get_center())
		"t30_brood:rootmaw":
			if mine("rootmaw").size() < 2 and not mine("mound_turtle").is_empty():
				await morph("ROOTMAW", "rootmaw", mine("mound_turtle")[0].position)
		"t30_brood:rootmaw_crew":
			await crew_brood()
		"t30_brood:sire":
			if mine("tyrannosaur").is_empty():
				await morph("TYRANT SIRE", "tyrannosaur", BroodNew.queen(g, g.human).position)
		"t30_brood:raptors":
			if first:
				await select(BroodNew.queen(g, g.human))
				await press_card("RAPTOR")
		# ---------------- the practice games (hints follow what you do)
		"t19_crown_practice:start":
			if mine("labourer").size() < 7:
				await train("town_hall", "LABOURER", 3)
				await wait(8.0)
		"t19_crown_practice:build":
			if mine("cottage").is_empty():
				await build("labourer", "cottage", "COTTAGE")
			elif mine("powder_mill").is_empty():
				await build("labourer", "powder_mill", "POWDER MILL")
			elif mine("barracks").is_empty():
				await crew("labourer", "powder_mill", 2)
				await build("labourer", "barracks", "BARRACKS")
			else:
				await wait(4.0)
		"t19_crown_practice:army":
			await train("barracks", "MUSKETEER", 2)
			if mine("cottage").size() < 3 and g.players[g.human]["gold"] > 200:
				await build("labourer", "cottage", "COTTAGE")
			await wait(6.0)
		"t19_crown_practice:foundry":
			if mine("foundry").is_empty():
				await build("labourer", "foundry", "FOUNDRY")
			await train("barracks", "MUSKETEER", 1)
		"t19_crown_practice:attack", "t29_clockwork_practice:attack", "t39_brood_practice:attack":
			await attack_out()
		"t29_clockwork_practice:start":
			if mine("winder").size() < 8:
				await train("clocktower", "WINDER", 3)
				await wait(8.0)
		"t29_clockwork_practice:build":
			if mine("cog_press").size() < 2:
				await build("winder", "cog_press", "COG PRESS")
			elif mine("mainspring").is_empty():
				await build("winder", "mainspring", "MAINSPRING")
			elif mine("movement_works").is_empty():
				await crew("winder", "mainspring", 2)
				await build("winder", "movement_works", "LIGHT WORKS")
			else:
				await wait(4.0)
		"t29_clockwork_practice:army":
			await train("movement_works", "CLOCK SOLDIER", 2)
			await wait(6.0)
		"t39_brood_practice:start":
			if mine("grub").size() < 9:
				await select(BroodNew.queen(g, g.human))
				for i in 3:
					await press_card("GRUB")
				await wait(8.0)
		"t39_brood_practice:build":
			if mine("mound_turtle").is_empty():
				await morph("MOUND TURTLE", "mound_turtle", BroodNew.queen(g, g.human).position + Vector2(0, 260))
			elif mine("tyrannosaur").is_empty():
				await morph("TYRANT SIRE", "tyrannosaur", BroodNew.queen(g, g.human).position)
			else:
				await wait(4.0)
		"t39_brood_practice:army":
			await select(BroodNew.queen(g, g.human))
			for i in 2:
				await press_card("RAPTOR")
			await wait(6.0)
		_:
			await wait(1.0)


## The army out: ARMY (F2 / the bar's ARMY), ATTACK (A), a click on the minimap at the enemy's corner.
func attack_out() -> void:
	var g := game()
	var foe := Vector2.ZERO
	for b in g.buildings:
		if b.team != g.human and not b.dead:
			foe = b.center()
			break
	if foe == Vector2.ZERO:
		for u in g.units:
			if u.team != g.human and not u.dead:
				foe = u.position
				break
	if phone:
		var ab := hud_rect(hud().bar.button_rect(1))
		await tap(ab.get_center())
	else:
		await key(KEY_F2)
	await wait(0.3)
	note("army selected: %d" % g.selection.size())
	if g.selection.is_empty():
		return
	if not await press_card("ATTACK"):
		return
	await press_at(mini_spot(foe))
	await wait(30.0)
	note("attack: my army %d, enemy buildings %d, enemy units %d, clock %.0f" % [g.selection.size(), g.buildings.filter(func(b) -> bool: return b.team != g.human and not b.dead).size(), g.units.filter(func(u) -> bool: return u.team != g.human and not u.dead).size(), g.clock])


## A palisade across the top of the ramp with a gate in it: BUILD, PALISADE, a drag; then BUILD, GATE, a click.
func wall() -> void:
	var g := game()
	var a := Vector2i(7, 19)
	var b := Vector2i(9, 19)
	var w := idle_worker("labourer")
	await select(w)
	await press_card("BUILD")
	note("BUILD page: %s" % str(card_labels()))
	var got := false
	for lab in ["PALISADE", "WALL"]:
		if card_labels().has(lab):
			await press_card(lab)
			got = true
			break
	if not got:
		find("no PALISADE / WALL on the Labourer's BUILD page: %s" % str(card_labels()))
		return
	var pa := world_to_screen((Vector2(a) + Vector2(0.5, 0.5)) * Game.T)
	var pb := world_to_screen((Vector2(b) + Vector2(0.5, 0.5)) * Game.T)
	if not in_view((Vector2(a) + Vector2(0.5, 0.5)) * Game.T):
		await look_at((Vector2(a) + Vector2(0.5, 0.5)) * Game.T)
		pa = world_to_screen((Vector2(a) + Vector2(0.5, 0.5)) * Game.T)
		pb = world_to_screen((Vector2(b) + Vector2(0.5, 0.5)) * Game.T)
	var n0 := mine("wall").size()
	if phone:
		await tap(pa)
		await tap(pb)
		note("after tapping the two ends: card %s" % str(card_labels()))
		await tap(pb)
	else:
		await click(pa)
		await click(pb)
	await wait(0.4)
	note("walls %d -> %d; card now %s" % [n0, mine("wall").size(), str(card_labels())])
	await shot("t10_crown_wall_laid")
	await key(KEY_ESCAPE)
	# the gate
	await select(idle_worker("labourer"))
	await press_card("BUILD")
	if not await press_card("GATE"):
		return
	var pg := world_to_screen((Vector2(8, 19) + Vector2(0.5, 0.5)) * Game.T)
	await press_at(pg)
	await press_at(pg)
	await wait(0.3)
	note("gates now %d at %s (built %s); walls at %s" % [mine("gate").size(), str(mine("gate").map(func(b) -> Vector2i: return b.cell)), str(mine("gate").map(func(b) -> bool: return b.built)), str(mine("wall").map(func(b) -> Vector2i: return b.cell))])


func morph(label: String, kind: String, around: Vector2) -> void:
	var g := game()
	for u in mine("grub"):
		if String(u.order) == "nb_morph":
			return          # (one is on its way already)
	var gr := idle_worker("grub")
	if gr == null:
		find("no grub to morph")
		return
	await select(gr)
	note("grub card: %s" % str(card_labels()))
	if not await press_card("BUILD"):
		return
	note("grub BUILD page: %s" % str(card().map(func(c: Dictionary) -> String: return "%s%s" % [c["label"], "" if c["enabled"] else "(off)"])))
	if not await press_card(label):
		return
	# a spot it may root on (the game's own check), clicked (tapped twice)
	var p := Vector2.INF
	for rad in range(0, 15):
		for dy in range(-rad, rad + 1):
			for dx in range(-rad, rad + 1):
				if p.is_finite() or maxi(absi(dx), absi(dy)) != rad:
					continue
				var fp := BroodRoot.feet_at(kind, g.cell_of(around) + Vector2i(dx, dy))
				if BroodRoot.place_problem(g, g.human, kind, fp, gr) == "":
					p = fp
	if not p.is_finite():
		find("no spot to root a %s near %s" % [kind, g.cell_of(around)])
		await key(KEY_ESCAPE)
		return
	if not in_view(p):
		await look_at(p)
	await press_at(world_to_screen(p))
	await wait(0.2)
	note("morph %s, first click: mode '%s', grub order %s, the screen says '%s'" % [kind, hud().controls.mode, gr.order if is_instance_valid(gr) else "(gone)", hud()._msg])
	if hud().controls.mode == "nb_root":
		await press_at(world_to_screen(p))          # (a phone: the first tap moves the ghost there, the second roots it)
		await wait(0.3)
		note("morph %s, second: mode '%s', grub order %s, says '%s'" % [kind, hud().controls.mode, gr.order if is_instance_valid(gr) else "(gone)", hud()._msg])


func crew_brood() -> void:
	var maws := mine("rootmaw").filter(func(u) -> bool: return WorkerLabels.workers(game(), u).size() < 2)
	if maws.is_empty():
		return
	var want := 0
	for mw in maws:
		want += 2 - WorkerLabels.workers(game(), mw).size()
	if mine("grub").size() < want + 2:
		note("not enough grubs (%d) for %d places: the Mother lays more" % [mine("grub").size(), want])
		await select(BroodNew.queen(game(), game().human))
		await press_card("GRUB")
		await press_card("GRUB")
		await wait(8.0)
	var mw: Unit = maws[0]
	var gs := mine("grub").filter(func(x) -> bool: return x.home_mine != mw)
	for gr in gs.slice(0, 2 - WorkerLabels.workers(game(), mw).size()):
		await select(gr)
		await order(mw.position)


## The sloppy player, the first time a step comes: presses whatever card buttons it sees (but MENU), clicks empty
## ground, presses Esc, cancels: does the lesson still go on?
func sloppy(sid: String) -> void:
	var labels := card_labels()
	if not labels.is_empty():
		var pick: String = labels[randi() % labels.size()]
		note("sloppy presses %s on step %s" % [pick, sid])
		await press_card(pick)
		await wait(0.3)
		await press_at(screen_size() * Vector2(randf_range(0.2, 0.8), randf_range(0.2, 0.6)))
		await key(KEY_ESCAPE)
	if sid in ["cottage", "press", "turtle"]:
		await wait(30.0)            # (idles half a minute)
