extends "res://tools/playtest/brood_play.gd"
## Playtest (job playtest-skirmish-brood): EVERY BROOD BUTTON tried by hand in the SANDBOX (EDITOR > SANDBOX: its
## +1000 FOOD / +200 SPOILS buttons and AI: OFF let one person reach every stage in a few minutes). Input only; it reads
## the game to check what happened and prints "PROBE OK|ODD <what>". Pictures in docs/shots/playtest_2026_11_21/skirmish_brood/.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 --script res://tools/playtest/brood_probe.gd \
##     -- [mobile] [lang=pt] [part=all|eco|army|late|ui]

var part := "all"


func probe(ok: bool, what: String) -> void:
	print("PROBE %s %s" % ["OK " if ok else "ODD", what])
	if not ok:
		finding("PROBE", what)


func sandbox_panel(open: bool) -> void:
	var t: BaseButton = pt.find_button("SANDBOX")
	if t == null:
		pt.note("no SANDBOX toggle")
		return
	var is_open := String(t.text).ends_with("<")
	if is_open != open:
		await pt.click_control(t)
		await pt.frames(4)


func sandbox(label: String, times := 1) -> void:
	await sandbox_panel(true)
	for i in times:
		if not await pt.click_text(label):
			break
		await pt.frames(2)


func give(food_k := 1, spoils_k := 0) -> void:
	await sandbox(Defs.res_names("brood")[0].to_upper(), 0)
	for i in food_k:
		await pt.click_text("+1000")
	for i in spoils_k:
		await pt.click_text("+200")
	await sandbox_panel(false)


func wait_game(t: float, every := 0.5) -> void:
	var end: float = g.clock + t
	while g.clock < end and not g.over:
		await pt.secs(every)
		watch_toasts()


func rooted_maws() -> int:
	return mine(BroodNew.MAW).filter(func(u: Unit) -> bool: return BroodNew.rooted(u)).size()


func _run() -> void:
	pt.tag = "probe_%s%s" % ["phone" if mobile else "pc", ("_" + o["lang"]) if o["lang"] != "en" else ""]
	for a in OS.get_cmdline_user_args():
		if a.begins_with("part="):
			part = a.substr(5)
	await pt.frames(5)
	if not await pt.into_match(main, {"opp": "crown", "who": "easy", "plan": "BALANCED", "map": "HOLLOWFEN", "sandbox": true}):
		_end(1)
		return
	g = main.game
	hud = g.hud
	me = g.human
	await pt.secs(4.0)
	# the enemy's computer off (the sandbox's own button), on the enemy's tab
	await sandbox_panel(true)
	await pt.shot("sandbox_panel")
	for b in pt.all_buttons(root):
		if b is Button and String((b as Button).text).strip_edges() in ["P2", "2"]:
			await pt.click_control(b)
			break
	await pt.click_text("AI: ON")
	for b in pt.all_buttons(root):
		if b is Button and String((b as Button).text).strip_edges() in ["P1", "1"]:
			await pt.click_control(b)
			break
	await sandbox_panel(false)
	pt.note("enemy ai: %s" % str(g.ais.map(func(a): return a.process_mode)))
	Engine.time_scale = 2.0
	if part in ["all", "eco"]:
		await eco()
	if part in ["all", "army"]:
		await army_part()
	if part in ["all", "late"]:
		await late()
	if part in ["all", "ui"]:
		await ui_part()
	Engine.time_scale = 1.0
	_end(0)


# ------------------------------------------------------------------ the economy: Mother, grubs, Rootmaws, the count

func eco() -> void:
	await give(2, 0)
	# the Mother's card and its tooltips
	await select_mother()
	await pt.shot("mother_card")
	pt.note("mother card: %s" % ", ".join(pt.card(hud).map(func(b): return "%s[%s]%s" % [b["label"], b["key"], "" if b["enabled"] else "x"])))
	for lab in ["ROOTMAWS", "GROW", "LAYING", "GRUB", "RAPTOR"]:
		await pt.hover_card(hud, lab, "tip_" + lab.to_lower())
	# lay grubs with the key (S)
	var g0 := mine("grub").size()
	for i in 6:
		await pt.key(KEY_S)
	await wait_game(30.0)
	probe(mine("grub").size() >= g0 + 5, "S on the Mother laid grubs (%d -> %d)" % [g0, mine("grub").size()])
	# worker rally: the Mother's first right-click on a Rootmaw
	await select_mother()
	var maw: Unit = mine(BroodNew.MAW)[0]
	await click_world(BroodRoot.rect_of(maw).get_center(), MOUSE_BUTTON_RIGHT)
	await pt.shot("worker_rally")
	# the gold BEST ROOTMAW SPOTS while placing, then two more Rootmaws on them
	for n in 2:
		var spots: Array = RootmawSpots.spots_for(g, me)
		pt.note("gold spots: %d %s" % [spots.size(), str(spots.map(func(s): return s["p"] / Defs.TILE))])
		if spots.is_empty():
			probe(false, "no gold Rootmaw spot shown with %d Rootmaws rooted" % rooted_maws())
			break
		var gr := mine("grub")
		await select_unit(gr[gr.size() - 1])
		await pt.key(KEY_B)
		await pt.shot("grub_build_page")
		await card("ROOTMAW")
		await look(spots[0]["p"])
		pt.move(scr(BroodRoot.rect_for(BroodNew.MAW, spots[0]["p"]).get_center()))
		await pt.frames(4)
		await pt.shot("rootmaw_ghost_on_gold")
		await pt.click(scr(BroodRoot.rect_for(BroodNew.MAW, spots[0]["p"]).get_center()))
		await wait_game(4.0)
	await wait_game(30.0)
	probe(rooted_maws() >= 3, "three Rootmaws rooted on the gold spots (%d)" % rooted_maws())
	await select_mother()
	var lab := ""
	for b in pt.card(hud):
		if String(b["label"]).begins_with("ROOTMAWS"):
			lab = b["label"]
	probe(lab == "ROOTMAWS 3/3", "the Mother's card count says '%s'" % lab)
	await pt.shot("mother_card_3maws")
	# a 4th Rootmaw on her (full) swamp: what does the player hear?
	var gr2 := mine("grub")
	await select_unit(gr2[0])
	await pt.key(KEY_B)
	await card("ROOTMAW")
	var q := mother()
	var spot4 := q.position + Vector2(0, 6 * Defs.TILE)
	await look(spot4)
	pt.move(scr(spot4))
	await pt.frames(4)
	await pt.shot("rootmaw_fourth_ghost")
	await pt.click(scr(spot4))
	await pt.frames(3)
	pt.note("4th Rootmaw toast: '%s'" % hud._msg)
	probe(String(hud._msg) != "", "a 4th Rootmaw on her full swamp is refused with a reason ('%s')" % hud._msg)
	await pt.key(KEY_ESCAPE)
	# HARVEST with no bodies near: do the grubs go back to work?
	var workers := mine("grub").filter(func(u: Unit) -> bool: return u.order == "gather")
	if workers.size() >= 3:
		await select_unit(workers[0])
		await select_unit(workers[1], true)
		await select_unit(workers[2], true)
		var picked: Array = g.selected_units().duplicate()
		await card("HARVEST")
		await wait_game(25.0)
		var stuck := picked.filter(func(u) -> bool: return is_instance_valid(u) and u.order == "harvest")
		probe(stuck.is_empty(), "HARVEST with no bodies near: %d of %d grubs still out of work after 25 s (orders %s)" % [stuck.size(), picked.size(), str(picked.map(func(u): return u.order))])
		await pt.key(KEY_F1)
		await pt.frames(3)
		probe(g.selected_units().any(func(u): return stuck.has(u)) or stuck.is_empty(), "F1 (IDLE) finds the grubs left harvesting nothing")
	# UPROOT the Mother: what happens to the Rootmaws on her swamp?
	var before := rooted_maws()
	await select_mother()
	await card("UPROOT")
	await wait_game(14.0)
	var after := rooted_maws()
	await pt.shot("mother_uprooted_14s")
	probe(after == before, "Mother uprooted 14 s: Rootmaws rooted %d -> %d" % [before, after])
	# and ROOT her again where she stands
	await select_mother()
	await pt.shot("mother_up_card")
	if await card("ROOT"):
		await pt.shot("mother_root_ghost")
		await place_root(BroodNew.QUEEN, mother().position, false)
	await wait_game(20.0)
	probe(BroodNew.rooted(mother()), "the Mother rooted again by ROOT + a click where she stands")
	probe(rooted_maws() == before, "after she roots again, Rootmaws rooted: %d (were %d) without new orders" % [rooted_maws(), before])
	# root the loose Rootmaws again: ROOT on each (the ghost where it stands)
	for m in mine(BroodNew.MAW).filter(func(u: Unit) -> bool: return not BroodNew.rooted(u)):
		await select_unit(m)
		if await card("ROOT"):
			await place_root(BroodNew.MAW, m.position, false)
			pt.note("reroot toast: %s" % hud._msg)
	await wait_game(15.0)
	probe(rooted_maws() == before, "re-ROOTed the Rootmaws by hand: %d rooted" % rooted_maws())
	# HAUL one and root it again
	var mw: Unit = mine(BroodNew.MAW).filter(func(u: Unit) -> bool: return BroodNew.rooted(u))[0]
	await select_unit(mw)
	await card("HAUL")
	await wait_game(5.0)
	await pt.shot("rootmaw_hauling")
	probe(not BroodNew.rooted(mw), "HAUL got the Rootmaw up")
	if await card("ROOT"):
		await place_root(BroodNew.MAW, mw.position, false)
	await wait_game(8.0)
	probe(BroodNew.rooted(mw), "a hauled Rootmaw rooted again where it stood")


# ------------------------------------------------------------------ the army: the Sire, eggs, Raptors, research, sacrifice

func army_part() -> void:
	await give(2, 1)
	var q := mother()
	# a Mound Turtle at home for supply
	await grub_to(BroodNew.TURTLE, find_spot(BroodNew.TURTLE, q.position, 9, 15))
	# the Tyrant Sire: first OUT of the father range (a person tries), then in it
	var gr := mine("grub")
	await select_unit(gr[0])
	await pt.key(KEY_B)
	await card("TYRANT SIRE")
	var far := q.position + Vector2(12 * Defs.TILE, 2 * Defs.TILE)
	await look(far)
	pt.move(scr(far))
	await pt.frames(4)
	await pt.shot("sire_ghost_out_of_range")
	await pt.click(scr(far))
	await pt.frames(3)
	pt.note("out of range toast: '%s'" % hud._msg)
	probe(String(hud._msg).to_lower().contains("range") or String(hud._msg).to_lower().contains("father"), "the Sire out of range is refused: '%s'" % hud._msg)
	await pt.key(KEY_ESCAPE)
	var sp := find_spot(BroodNew.FATHER, q.position, 3, 7)
	probe(sp != Vector2.INF, "a spot for the Tyrant Sire in the father range exists")
	await grub_to(BroodNew.FATHER, sp)
	await wait_game(45.0)
	var sire := BroodNew.father(g, me, BroodNew.FATHER)
	probe(sire != null and BroodNew.rooted(sire), "the Tyrant Sire nested beside her (lure, then him)")
	# Raptors: eggs into his nest
	var a0 := mine("raptor").size()
	await lay("raptor", 4)
	await pt.shot("raptor_eggs")
	await wait_game(6.0)
	if sire:
		await select_unit(sire)
		await pt.shot("sire_card_nest")
		pt.note("sire card: %s" % ", ".join(pt.card(hud).map(func(b): return "%s%s" % [b["label"], "" if b["enabled"] else "(x: %s)" % b["why"]])))
		# research: every one on his card, in turn
		for b in pt.card(hud):
			if b["enabled"] and not (b["label"] in ["UPROOT", "RALLY", "WORKERS"]) and b["icon"] != "rally":
				await pt.hover_card(hud, b["label"], "tip_sire_" + String(b["label"]).to_lower().replace(" ", "_"))
				await card(b["label"])
				pt.note("pressed %s on the Sire: %s" % [b["label"], hud._msg])
				break
	await wait_game(40.0)
	probe(mine("raptor").size() >= a0 + 6, "4 Raptor eggs hatched %d Raptors" % (mine("raptor").size() - a0))
	await pt.shot("raptors_hatched")
	# group, hotkeys, hold, patrol, stop, drag-a-line, Shift queue with Raptors
	await pt.key(KEY_F2)
	pt.hold_ctrl(true)
	await pt.key(KEY_1)
	pt.hold_ctrl(false)
	probe(not g.selected_units().is_empty(), "F2 picked the army (%d)" % g.selected_units().size())
	await pt.shot("army_card")
	pt.note("raptor card: %s" % ", ".join(pt.card(hud).map(func(b): return "%s[%s]" % [b["label"], b["key"]])))
	await pt.key(KEY_H)
	await pt.frames(3)
	probe(g.selected_units().all(func(u): return u.order == "hold"), "H holds them")
	var c: Vector2 = q.position + Vector2(0, 10 * Defs.TILE)
	await look(c)
	# drag a line with the right button
	await pt.drag(scr(c) - Vector2(120, 0), scr(c) + Vector2(120, 0), MOUSE_BUTTON_RIGHT)
	await wait_game(4.0)
	await pt.shot("raptors_line")
	# Shift-queued moves
	pt.hold_shift(true)
	for i in 3:
		await pt.click(scr(c) + Vector2(-150 + i * 150, 80), MOUSE_BUTTON_RIGHT)
	pt.hold_shift(false)
	await pt.frames(3)
	await pt.shot("raptors_queue")
	await pt.key(KEY_S)
	# PATROL
	await pt.key(KEY_P)
	await pt.click(scr(c) + Vector2(200, 0))
	await wait_game(3.0)
	probe(g.selected_units().any(func(u): return u.order == "patrol"), "P + click patrols")
	# SACRIFICE one Raptor
	var r1: Unit = mine("raptor")[0]
	var s0 := spoils()
	await select_unit(r1)
	await card("SACRIFICE")
	await wait_game(15.0)
	probe(spoils() > s0, "SACRIFICE gave spoils (%d -> %d)" % [s0, spoils()])
	# camera keys: F5 save (Shift), move, F5 back; zoom wheel; Space centres
	pt.hold_shift(true)
	await pt.key(KEY_F5)
	pt.hold_shift(false)
	await pt.key(KEY_RIGHT, 30)
	var cam: Vector2 = g.camera.position
	await pt.key(KEY_F5)
	await pt.frames(3)
	probe(g.camera.position.distance_to(cam) > 50, "Shift+F5 saves a view, F5 goes back to it")
	await pt.wheel(pt.vsize() * 0.5, true, 4)
	await pt.shot("zoom_in")
	await pt.wheel(pt.vsize() * 0.5, false, 8)
	await pt.shot("zoom_out")


# ------------------------------------------------------------------ late: GROW, the other Sires, every creature, MATURE

func late() -> void:
	await give(3, 3)
	var q := mother()
	await select_mother()
	await pt.hover_card(hud, "GROW", "tip_grow_stage2")
	await card("GROW")
	await pt.shot("growing")
	await wait_game(50.0)
	probe(BroodNew.stage(mother()) >= 1, "GROW reached stage 2 (stage %d)" % BroodNew.stage(mother()))
	await pt.shot("stage2")
	# Venom Sire and Storm Sire
	for k in [BroodNew.DILO, BroodNew.PTERO]:
		var sp := find_spot(k, mother().position, 3, 7)
		probe(sp != Vector2.INF, "room for the %s in the father range" % k)
		if sp != Vector2.INF:
			await grub_to(k, sp)
		await wait_game(5.0)
	await give(2, 2)
	await select_mother()
	await card("GROW")
	await wait_game(70.0)
	probe(BroodNew.stage(mother()) >= 2, "GROW reached stage 3 (stage %d)" % BroodNew.stage(mother()))
	await pt.shot("stage3")
	await give(3, 3)
	# every creature on her card
	await select_mother()
	pt.note("stage 3 mother card: %s" % ", ".join(pt.card(hud).map(func(b): return "%s%s" % [b["label"], "" if b["enabled"] else "(x: %s)" % b["why"]])))
	for k in BroodNew.hatch_list():
		var n := await lay(k, 1)
		pt.note("lay %s: %d" % [k, n])
		await pt.frames(5)
	await wait_game(60.0)
	var kinds := {}
	for u in mine():
		kinds[u.kind] = int(kinds.get(u.kind, 0)) + 1
	pt.note("kinds now: %s" % str(kinds))
	await pt.shot("every_creature")
	for k in BroodNew.hatch_list():
		if k != "grub":
			probe(kinds.has(k) or kinds.has(String(Defs.UNITS[k].get("spawn_kind", k))), "%s hatched" % k)
	# MATURE: one Raptor (click), then all (Ctrl+key)
	var rap := mine("raptor")
	if not rap.is_empty():
		await select_unit(rap[0])
		await pt.hover_card(hud, "MATURE", "tip_mature")
		await card("MATURE")
		await wait_game(25.0)
		probe(not mine("tyrant_challenger").is_empty() or mine().any(func(u): return u.kind.contains("challenger")), "MATURE made a Challenger")
	# the Mist Toad's spells on enemies (spawned by the sandbox for the enemy)
	var toad := mine().filter(func(u: Unit) -> bool: return u.kind == "mist_toad")
	if not toad.is_empty():
		await select_unit(toad[0])
		await pt.shot("toad_card")
		pt.note("toad card: %s" % ", ".join(pt.card(hud).map(func(b): return "%s%s" % [b["label"], "" if b["enabled"] else "(x: %s)" % b["why"]])))
		for sl in ["FOG", "MIASMA", "TONGUE"]:
			if await card(sl):
				await click_world(toad[0].position + Vector2(5 * Defs.TILE, 0))
				pt.note("%s: %s" % [sl, hud._msg])
				await pt.shot("toad_" + sl.to_lower())
			await pt.key(KEY_ESCAPE)
	# a Mound Turtle on NEW ground (the gold spot), then its ROOTMAWS n/2
	if g.exp_spots != null:
		var picks: Array = ExpansionSpots.nb_pick(g, me, g.exp_spots)
		pt.note("turtle gold spots: %d" % picks.size())
		if not picks.is_empty():
			var tsp := find_spot(BroodNew.TURTLE, BroodRoot.feet_at(BroodNew.TURTLE, picks[0]["tc"]), 0, 3)
			await grub_to(BroodNew.TURTLE, tsp)
			await wait_game(60.0)
			var far := mine(BroodNew.TURTLE).filter(func(u): return BroodNew.rooted(u) and u.position.distance_to(mother().position) > 15 * Defs.TILE)
			probe(not far.is_empty(), "a Mound Turtle rooted on new ground")
			if not far.is_empty():
				await select_unit(far[0])
				await pt.shot("turtle_card")
				pt.note("turtle card: %s" % ", ".join(pt.card_labels(hud)))


# ------------------------------------------------------------------ the match UI: pause, menu, settings, surrender, end

func ui_part() -> void:
	Engine.time_scale = 1.0
	await pt.key(KEY_PAUSE)
	await pt.frames(5)
	pt.note("paused after Pause key: %s" % str(get_root().get_tree().paused if false else hud.paused))
	await pt.shot("pause_key")
	await pt.menu_click(hud, "PAUSE")
	await pt.shot("menu_paused")
	pt.note("menu: %s" % ", ".join(pt.menu_labels(hud)))
	await pt.menu_click(hud, "RESUME")
	await pt.menu_click(hud, "SETTINGS")
	await pt.frames(10)
	await pt.shot("settings_in_match")
	await pt.key(KEY_ESCAPE)
	await pt.frames(5)
	await pt.menu_click(hud, "SURRENDER")
	await pt.shot("surrender_confirm")
	for b in hud._menu_buttons():
		if b.get("bad", false) and String(b["label"]) != "SURRENDER":
			await pt.click((b["rect"] as Rect2).get_center() * hud.ui_scale)
			break
	await pt.secs(4.0)
	await pt.shot("end_screen")
	probe(g.over, "SURRENDER ended the match")
	pt.note("end screen buttons: %s" % ", ".join(pt.button_texts(main.ui_layer)))
