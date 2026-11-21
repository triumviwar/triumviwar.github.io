extends "res://tools/playtest/pt_setup_util.gd"
## EVERY button on EVERY Crown card (docs/playtest_2026_11_21_skirmish_crown.md). A SANDBOX match (EDITOR > SANDBOX:
## its own panel hands out gold and powder and switches the enemy computer off, as a player would use it), then a
## labourer builds every Crown building, every building trains everything it can, and every card button of every
## building and unit is hovered (its tooltip read) and pressed once; what happened is printed:
##   "PT CARD <selection> | <label> | enabled | tip title / need | -> mode, toast, selection".
##   args: opp=CLOCKWORK lang=en

var log_lines: Array = []


func run() -> void:
	var opp := String(args.get("opp", "CLOCKWORK"))
	await wait_real(1.0)
	await press_button("EDITOR")
	await wait_real(0.3)
	await press_button("SANDBOX")
	await wait_real(0.3)
	await press_button("1v1")
	await pick_in_slot(0, 1, "CROWN")
	await pick_in_slot(1, 0, "EASY AI")
	await pick_in_slot(1, 1, opp)
	await press_button("START")
	await wait_match()
	await shot("sandbox_start")
	# the sandbox: money, powder, the enemy's computer off
	for i in 12:
		await press_button("+1000 GOLD")
	for i in 6:
		await press_button("+200 POWDER")
	await press_button("2")
	await press_button("AI: ON")
	await press_button("» 1")
	await press_button("SPEED X1")
	await press_button("SPEED X2")
	await shot("sandbox_panel")
	await press_button("SANDBOX <")
	Engine.time_scale = 4.0
	var g := game()
	var hall = my_buildings("town_hall")[0]
	# the builders: a double-click on a labourer picks every labourer on screen; Ctrl+2 keeps them as group 2
	var l0 = free_labourer()
	await look_at(ent_point(l0))
	await double_click(w2s(ent_point(l0)))
	await settle()
	step("double-click a labourer: %d selected (%s)" % [game().selection.size(), str(game().selection.map(func(x) -> String: return x.kind))])
	await ctrl_key(KEY_2)
	await settle()
	# the hall's card first (its LABOURER trains: 8 more hands)
	await exercise(hall, "town_hall", ["- WORKER"])
	for i in 6:
		await select_ent(hall)
		await card("LABOURER")
	await wait(30)
	# every building in stages (each waits for what it needs)
	for stage in [["cottage", "farm", "powder_mill", "horse_breeder"], ["barracks"], ["armoury", "foundry", "church", "cottage"], ["town_hall", "barracks"]]:
		for k in stage:
			await build_one(k)
		for k in stage:
			await wait_built(k)
	# walls: a palisade line dragged, a gate in it, Shift-corners
	await walls()
	await wait(70)
	await shot("base_built")
	for b in my_buildings():
		step("BUILDING %s built=%s" % [b.kind, b.built])
	# every building's card
	var seen := {}
	for b in my_buildings():
		if seen.has(b.kind) or not b.built:
			continue
		seen[b.kind] = true
		await exercise(b, b.kind, ["DEMOLISH", "CANCEL"])
	# train: every unit button of every production building, twice
	for k in ["horse_breeder", "barracks", "foundry", "armoury", "church"]:
		for b in my_buildings(k):
			if not b.built:
				continue
			await select_ent(b)
			for lab in card_labels():
				var l := String(lab).trim_suffix("(x)")
				if l in ["RALLY", "DEMOLISH", "CANCEL", "AUTO REFIT", "ARM WITH POWDER", "BACK"]:
					continue
				await card(l)
				await card(l)
			break
	await wait(60)
	await shot("army_trained")
	# every unit kind's card
	seen = {}
	for u in my_units():
		if seen.has(u.kind):
			continue
		seen[u.kind] = true
		await exercise(u, u.kind, ["DISMOUNT", "RELEASE HORSE", "SACRIFICE"])
	await shot("after_units")
	# DEMOLISH and CANCEL last: a cottage demolished, a farm placed and cancelled
	var cot = my_buildings("cottage")[0]
	await select_ent(cot)
	var r1 := await card("DEMOLISH")
	await settle()
	step("DEMOLISH once: %s toast '%s' cottage dead=%s" % [r1, toast_text(), cot.dead])
	await card("DEMOLISH")
	await wait(3)
	step("DEMOLISH twice: cottage dead=%s / demolishing=%s" % [cot.dead, str(cot.get("demolishing")) if "demolishing" in cot else "?"])
	await build_one("farm")
	var fresh := my_buildings("farm").filter(func(b) -> bool: return not b.built)
	if not fresh.is_empty():
		await select_ent(fresh[0])
		step("site card: " + ", ".join(card_labels()))
		var gold0 := int(res()["gold"])
		await card("ABANDON")
		await settle()
		step("ABANDON before it started: gold %d -> %d, site dead=%s" % [gold0, int(res()["gold"]), fresh[0].dead])
	for l in log_lines:
		print(l)


## Group 2 (the builders), then BUILD.
func builders() -> String:
	await key(KEY_2)
	await settle()
	if game().selection.is_empty():
		finding("GROUPS: group 2 came back empty")
	return await card("BUILD")


func wait_built(k: String) -> void:
	for i in 60:
		var bs := my_buildings(k)
		if not bs.is_empty() and bs.all(func(b) -> bool: return b.built):
			return
		await wait(2)
	finding("BUILD: %s still not built after 2 minutes (sites %d)" % [k, my_buildings(k).size()])


## A labourer standing in the open (not inside a building's click area), as a player picks one.
func free_labourer():
	var g := game()
	var best = null
	for u in my_units("labourer"):
		var hit = g.entity_at(u.position + Vector2(0, -12))
		if hit != u:
			continue
		if best == null or (u.order == "idle" and best.order != "idle"):
			best = u
	return best if best else my_units("labourer")[0]


func build_one(k: String) -> void:
	var g := game()
	var spot := Vector2i(-1, -1)
	var hc: Vector2i = my_buildings("town_hall")[0].cell
	if k == "town_hall" and g.exp_spots:
		for sp in g.exp_spots.spots:
			if int(sp["team"]) == g.human and g.placement_problem(g.human, k, sp["c"]) == "":
				spot = sp["c"]
				break
	if spot.x < 0:
		for r in range(5, 24):
			for a in 32:
				var c := hc + Vector2i(Vector2(r, 0).rotated(TAU * a / 32.0))
				if g.placement_problem(g.human, k, c) == "":
					spot = c
					break
			if spot.x >= 0:
				break
	if spot.x < 0:
		finding("no spot for " + k)
		return
	var r := await builders()
	if r != "ok":
		return
	await settle()
	var lab := k.replace("_", " ").to_upper()
	if k == "powder_mill":
		lab = "POWDER"
	r = await card(lab)
	if r != "ok":
		finding("BUILD %s: %s" % [k, r])
		await key(KEY_ESCAPE)
		return
	var size: Vector2i = Defs.BUILDINGS[k]["size"]
	var w := Vector2(spot) * Defs.TILE + Vector2(size) * Defs.TILE * 0.5
	await look_at(w)
	# a wrong spot first: on top of the Town Hall (a player misclicks)
	await move(ent_point(my_buildings("town_hall")[0]).x * Vector2.RIGHT + w2s(my_buildings("town_hall")[0].rect().get_center()).y * Vector2.DOWN, 2)
	var p0 := w2s(my_buildings("town_hall")[0].rect().get_center())
	await move(p0, 2)
	await click(p0)
	await settle()
	step("placing %s on the Town Hall: toast '%s', still placing=%s" % [k, toast_text(), hud().controls.mode == "place"])
	if hud().controls.mode != "place":
		finding("PLACE: a refused spot ended placing mode (%s)" % k)
		await card("BUILD")
		await card(lab)
	var p := w2s(w)
	await move(p, 3)
	await click(p)
	await settle()
	step("placed %s at %s: mode '%s' toast '%s'" % [k, str(spot), hud().controls.mode, toast_text()])


func walls() -> void:
	var g := game()
	var hc: Vector2i = my_buildings("town_hall")[0].cell
	var a := Vector2i(-1, -1)
	for r in range(10, 20):
		var c := hc + Vector2i(r, r / 2)
		if g.placement_problem(g.human, "wall", c) == "" and g.placement_problem(g.human, "wall", c + Vector2i(0, 6)) == "":
			a = c
			break
	if a.x < 0:
		finding("WALL: no open stretch found")
		return
	await builders()
	await settle()
	var r := await card("PALISADE")
	step("PALISADE: " + r)
	var wa := (Vector2(a) + Vector2(0.5, 0.5)) * Defs.TILE
	var wb := (Vector2(a + Vector2i(0, 6)) + Vector2(0.5, 0.5)) * Defs.TILE
	await look_at(wa)
	await drag(w2s(wa), w2s(wb), MOUSE_BUTTON_LEFT, 10)
	await settle()
	var walls_n := my_buildings("wall").size()
	step("palisade dragged: %d wall pieces, mode '%s', toast '%s'" % [walls_n, hud().controls.mode, toast_text()])
	await shot("palisade")
	await key(KEY_ESCAPE)
	# a gate in the middle of it
	await builders()
	await settle()
	r = await card("GATE")
	var wg := (Vector2(a + Vector2i(0, 3)) + Vector2(0.5, 0.5)) * Defs.TILE
	await look_at(wg)
	await move(w2s(wg), 3)
	await click(w2s(wg))
	await settle()
	if hud().controls.mode == "place":
		await click(w2s(wg + Vector2(0, Defs.TILE)))
		await settle()
	step("gate: %d gates, mode '%s', toast '%s'" % [my_buildings("gate").size(), hud().controls.mode, toast_text()])
	await key(KEY_ESCAPE)
	# Shift-click corners: an L
	await builders()
	await settle()
	await card("PALISADE")
	var c0 := (Vector2(a + Vector2i(3, -4)) + Vector2(0.5, 0.5)) * Defs.TILE
	var c1 := c0 + Vector2(4, 0) * Defs.TILE
	var c2 := c1 + Vector2(0, 3) * Defs.TILE
	await look_at(c1)
	await click(w2s(c0))
	key_down(KEY_SHIFT, true)
	await click(w2s(c1))
	await click(w2s(c2))
	key_down(KEY_SHIFT, false)
	await settle()
	step("shift-corner palisade: %d wall pieces now, mode '%s', toast '%s'" % [my_buildings("wall").size(), hud().controls.mode, toast_text()])
	await shot("palisade_corners")
	await key(KEY_ESCAPE)


## Hover and press every card button of a selection, once; logs what each did.
func exercise(e, name: String, skip: Array) -> void:
	if not is_instance_valid(e) or e.dead:
		return
	await select_ent(e)
	if not game().selection.has(e):
		finding("SELECT: clicking a %s selected %s" % [name, str(game().selection.map(func(x) -> String: return x.kind))])
		return
	var labels := card_labels()
	step("CARD %s: %s" % [name, ", ".join(labels)])
	await shot("card_" + name)
	for raw in labels:
		var lab := String(raw).trim_suffix("(x)")
		if lab in skip or lab == "BACK":
			continue
		if not is_instance_valid(e) or e.dead:
			return
		await select_ent(e)
		var b := find_card(lab)
		if b.is_empty():
			continue
		# hover: the tooltip
		await move((b["rect"] as Rect2).get_center(), 2)
		await wait_real(0.6)
		var tip: Dictionary = hud()._tip
		var tip_t := "%s / %s / need: %s" % [String(tip.get("title", "")), String(tip.get("stats", "")).replace("\n", " "), String(tip.get("need", "")).replace("\n", " ")]
		var sel0: Array = game().selection.duplicate()
		var r := await card(lab)
		await settle()
		var mode: String = hud().controls.mode
		var sel1: Array = game().selection.map(func(x) -> String: return x.kind)
		var line := "PT CARD %s | %s | %s | tip %s | -> %s mode '%s' toast '%s' sel %s" % [name, lab, "on" if b["enabled"] else "OFF(" + String(b["why"]) + ")",
			tip_t, r, mode, toast_text(), str(sel1)]
		log_lines.append(line)
		print(line)
		if tip.is_empty() and Settings.tooltips:
			finding("TOOLTIP: no tooltip on %s's %s" % [name, lab])
		if mode != "":
			await key(KEY_ESCAPE)
		elif hud().page != "":
			await key(KEY_ESCAPE)
