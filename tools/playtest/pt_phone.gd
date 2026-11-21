extends "res://tools/playtest/pt_setup_util.gd"
## The phone (docs/playtest_2026_11_21_skirmish_crown.md): device=mobile at a phone's size, TOUCH only: the menus and
## the setup by taps, then a match: tap select, double tap, a one-finger box drag, DRAG: BOX / PAN, long press to move,
## two-finger pan and pinch zoom, the minimap, card taps, a building placed by tap and tap again (and PLACE), a long
## press on a train button (auto-train), groups (hold to save, tap to select), the "?" help, quick chat, the menu.
##   xvfb ... --resolution 844x390 ... -- device=mobile

var fails := 0


func check(name: String, ok: bool, detail := "") -> void:
	print("PT CHECK %s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1
		finding("PHONE %s: %s" % [name, detail])


func sel_kinds() -> Array:
	return game().selection.filter(func(x) -> bool: return is_instance_valid(x)).map(func(x) -> String: return x.kind)


func run() -> void:
	device = "mobile"
	await wait_real(1.5)
	await shot("menu")
	await setup_1v1("EASY AI", "BROOD", "BALANCED")
	await shot("setup")
	step("setup buttons: " + list_buttons())
	await press_button("START")
	await wait_match()
	await wait_real(0.5)
	await shot("match_start")
	var g := game()
	step("ui_scale %.2f viewport %s" % [hud().ui_scale, str(vp_size())])
	var hall = my_buildings("town_hall")[0]
	var labs := my_units("labourer")
	await look_at(labs[0].position)
	await tap(w2s(ent_point(labs[0])))
	await settle()
	check("tap_select", game().selection.size() == 1, str(sel_kinds()))
	await shot("tap_select")
	await double_tap(w2s(ent_point(labs[1])))
	await settle()
	check("double_tap_type", game().selection.size() == labs.size(), "%d of %d" % [game().selection.size(), labs.size()])
	# one-finger drag: a box (the default)
	await tap(w2s(hall.position + Vector2(300, 300)))      # (empty ground: deselect / or a move order!)
	await settle()
	step("tap on empty ground with labourers selected: orders %s, selection %s" % [str(labs.map(func(u) -> String: return u.order)), str(sel_kinds())])
	var r := Rect2(w2s(labs[0].position), Vector2.ZERO)
	for u in labs:
		r = r.expand(w2s(u.position + Vector2(0, -12)))
	r = r.grow(25)
	await swipe(r.position, r.end, 12)
	await settle()
	check("drag_box", game().selection.size() >= 2, str(sel_kinds()))
	# long press: move without fighting
	var sp := vp_size() * Vector2(0.55, 0.3)       # (open ground above the HUD)
	step("long press with %s selected" % str(sel_kinds()))
	await long_press(sp, 0.8)
	await settle()
	check("long_press_move", labs.any(func(u) -> bool: return u.order == "move"), str(labs.map(func(u) -> String: return u.order)))
	# two fingers: pan and pinch
	var z0: float = g.camera.zoom.x
	await pinch(vp_size() * 0.45, 120, 260)
	var z1: float = g.camera.zoom.x
	check("pinch_zoom_in", z1 > z0 * 1.2, "%.2f -> %.2f" % [z0, z1])
	await pinch(vp_size() * 0.45, 260, 100)
	check("pinch_zoom_out", g.camera.zoom.x < z1, "%.2f -> %.2f" % [z1, g.camera.zoom.x])
	var c0: Vector2 = g.camera.position
	touch(vp_size() * 0.4, true, 0)
	touch(vp_size() * 0.4 + Vector2(80, 0), true, 1)
	await frames(2)
	for i in 10:
		touch_move(vp_size() * 0.4 + Vector2(-10 * i, -6 * i), 0)
		touch_move(vp_size() * 0.4 + Vector2(80 - 10 * i, -6 * i), 1)
		await process_frame
	touch(vp_size() * 0.4, false, 0)
	touch(vp_size() * 0.4, false, 1)
	await frames(3)
	check("two_finger_pan", g.camera.position.distance_to(c0) > 40, "%s -> %s" % [str(c0), str(g.camera.position)])
	await shot("after_pan")
	# DRAG: BOX / PAN switch
	var dr: Rect2 = hud().drag_rect()
	var ms: float = hud().ui_scale
	var dm0 := Settings.drag_mode
	await tap(dr.get_center() * ms)
	await settle()
	check("drag_switch", Settings.drag_mode != dm0, "%s -> %s toast '%s'" % [dm0, Settings.drag_mode, toast_text()])
	c0 = g.camera.position
	await swipe(vp_size() * 0.5, vp_size() * 0.5 + Vector2(-150, -60), 10)
	check("one_finger_pan", g.camera.position.distance_to(c0) > 40, "%s -> %s" % [str(c0), str(g.camera.position)])
	await tap(dr.get_center() * ms)
	await settle()
	# minimap tap
	var m: Rect2 = hud().mini_rect()
	c0 = g.camera.position
	await tap((m.position + m.size * 0.75) * ms)
	await settle()
	check("minimap_tap", g.camera.position.distance_to(c0) > 300, "%s -> %s" % [str(c0), str(g.camera.position)])
	await shot("minimap_tap")
	# the hall: a card tap trains, a long press switches auto-train
	await look_at(ent_point(hall))
	await tap(w2s(ent_point(hall)))
	await settle()
	step("hall tap -> %s; card %s" % [str(sel_kinds()), ", ".join(card_labels())])
	if not sel_kinds().has("town_hall"):
		finding("PHONE: a tap on the Town Hall's middle selected %s (labourers stand at its door)" % str(sel_kinds()))
		await tap(w2s(hall.rect().get_center() + Vector2(0, -30)))
		await settle()
	await shot("hall_card")
	var q0: int = hall.queue.size()
	await card("LABOURER")
	await settle()
	check("card_tap_trains", hall.queue.size() == q0 + 1, "%d -> %d" % [q0, hall.queue.size()])
	var lb := find_card("LABOURER")
	if not lb.is_empty():
		await long_press((lb["rect"] as Rect2).get_center(), 1.0)
		await settle()
		step("long press LABOURER: toast '%s' card %s" % [toast_text(), ", ".join(card_labels())])
		await shot("auto_train")
	# groups: hold to save, tap to select
	var gb = null
	for i in 12:
		var b = hud().bar
		break
	await double_tap(w2s(ent_point(labs[0])))
	await settle()
	var bar = hud().bar
	var g1r: Rect2 = bar.rect_of(bar.GROUP0) if bar.has_method("rect_of") else Rect2()
	step("group button rect %s" % str(g1r))
	if g1r.size.x > 0:
		await long_press(g1r.get_center() * ms, 1.0)
		await settle()
		step("hold group 1: toast '%s'" % toast_text())
		await tap(dr.get_center() * ms + Vector2(0, 200))
		await settle()
		await tap(g1r.get_center() * ms)
		await settle()
		check("group_tap_selects", game().selection.size() >= 4, str(sel_kinds()))
	# a building: BUILD, a building, a tap, a tap again
	await card("BUILD")
	await settle()
	await card("COTTAGE")
	await settle()
	var hc: Vector2i = hall.cell
	var spot_c := Vector2i(-1, -1)
	for rr in range(6, 14):
		for a in 16:
			var c: Vector2i = hc + Vector2i(Vector2(rr, 0).rotated(TAU * a / 16.0))
			if g.placement_problem(g.human, "cottage", c) == "":
				spot_c = c
				break
		if spot_c.x >= 0:
			break
	var w := Vector2(spot_c) * Defs.TILE + Vector2(Defs.BUILDINGS["cottage"]["size"]) * Defs.TILE * 0.5
	await look_at(w)
	await tap(w2s(w))
	await settle()
	await shot("ghost")
	step("after one tap: mode '%s' card %s" % [hud().controls.mode, ", ".join(card_labels())])
	var n0 := my_buildings("cottage").size()
	await tap(w2s(w))
	await settle()
	check("tap_tap_places", my_buildings("cottage").size() == n0 + 1, "mode '%s' toast '%s'" % [hud().controls.mode, toast_text()])
	# the "?" help
	var hr: Rect2 = hud().help_rect() if hud().has_method("help_rect") else Rect2()
	if hr.size.x > 0:
		await tap(hr.get_center() * ms)
		await settle()
		check("help_mode", hud().help_mode, "")
		await tap(w2s(ent_point(hall)))
		await settle()
		step("help tap on the hall: tip %s" % str(hud()._tip.get("title", "")))
		await shot("help_tip")
		await tap(vp_size() * 0.5)
		if hud().help_mode:
			await tap(hr.get_center() * ms)
	# quick chat
	var cr: Rect2 = hud().chat_btn_rect()
	if cr.size.x > 0:
		await tap(cr.get_center() * ms)
		await settle()
		check("quick_chat_opens", hud().quick_open, "")
		await shot("quick_chat")
		await tap(cr.get_center() * ms)
	# the menu
	var mr: Rect2 = hud().menu_rect()
	await tap(mr.get_center() * ms)
	await settle()
	check("menu_opens", hud().menu_open, "")
	await shot("menu")
	await tap(Vector2(5, vp_size().y - 5))
	await settle()
	step("tap outside the menu: open %s" % hud().menu_open)
	step("CHECKS failed %d" % fails)
