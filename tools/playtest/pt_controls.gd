extends "res://tools/playtest/pt_setup_util.gd"
## Every control of a computer player (docs/playtest_2026_11_21_skirmish_crown.md): selection by click, Shift-click,
## Ctrl-click, double-click and box; control groups (Ctrl, Shift, Alt, recall, double tap to centre); right-click move,
## Shift queues, the right-drag line, A / M / S / H / P; the minimap (click, drag, right-click); camera keys, edge
## scroll, wheel zoom, Space, F1-F3, F4-F10 views; the in-match menu (pause, sliders, settings, surrender), chat;
## leaving to the menu and CONTINUE. Each check prints "PT CHECK <name> ok|FAIL <detail>".

var fails := 0


func check(name: String, ok: bool, detail := "") -> void:
	print("PT CHECK %s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1
		finding("CONTROLS %s: %s" % [name, detail])


func sel_kinds() -> Array:
	return game().selection.filter(func(x) -> bool: return is_instance_valid(x)).map(func(x) -> String: return x.kind)


func cam() -> Vector2:
	return game().camera.position


func run() -> void:
	await wait_real(1.0)
	await setup_1v1("EASY AI", "CROWN", "BALANCED")
	await press_button("START")
	await wait_match()
	var g := game()
	var hall = my_buildings("town_hall")[0]
	await look_at(ent_point(hall))
	await key(KEY_SPACE)
	await wait_real(0.3)
	var labs := my_units("labourer")
	# ---- selection
	await press(w2s(ent_point(labs[0])))
	await settle()
	check("click_select", game().selection.size() == 1 and game().selection[0] == labs[0], str(sel_kinds()))
	_shift = true
	await click(w2s(ent_point(labs[1])))
	_shift = false
	await settle()
	check("shift_click_add", game().selection.size() == 2, str(sel_kinds()))
	_shift = true
	await click(w2s(ent_point(labs[1])))
	_shift = false
	await settle()
	check("shift_click_drop", game().selection.size() == 1, str(sel_kinds()))
	await key(KEY_ESCAPE)
	await settle()
	check("esc_clears", game().selection.is_empty(), str(sel_kinds()))
	_ctrl = true
	await click(w2s(ent_point(labs[0])))
	_ctrl = false
	await settle()
	check("ctrl_click_type", game().selection.size() == labs.size(), "%d of %d" % [game().selection.size(), labs.size()])
	await key(KEY_ESCAPE)
	await double_click(w2s(ent_point(labs[2])))
	await settle()
	check("double_click_type", game().selection.size() == labs.size(), "%d of %d" % [game().selection.size(), labs.size()])
	await key(KEY_ESCAPE)
	# box: round every labourer
	var r := Rect2(w2s(labs[0].position), Vector2.ZERO)
	for u in labs:
		r = r.expand(w2s(u.position + Vector2(0, -12)))
	r = r.grow(30)
	await drag(r.position, r.end)
	await settle()
	check("box_select", game().selection.size() >= labs.size(), "%d (%s)" % [game().selection.size(), str(sel_kinds())])
	await shot("box_select")
	# a box that also takes the hall: buildings should not join units
	r = r.expand(w2s(ent_point(hall)))
	await drag(r.position, r.end)
	await settle()
	check("box_units_only", not sel_kinds().has("town_hall"), str(sel_kinds()))
	# ---- groups
	await ctrl_key(KEY_1)
	await key(KEY_ESCAPE)
	await key(KEY_1)
	await settle()
	check("group_recall", game().selection.size() >= labs.size(), str(game().selection.size()))
	var far: Vector2 = cam() + Vector2(900, 600)
	await hold_key(KEY_RIGHT, 0.6)
	await hold_key(KEY_DOWN, 0.6)
	var moved := cam()
	check("arrow_keys_pan", moved.distance_to(hall.position) > 100, "cam %s" % str(moved))
	await key(KEY_1)
	await key(KEY_1)
	await settle()
	check("group_double_tap_centres", cam().distance_to(labs[0].position) < 400, "cam %s labs %s" % [str(cam()), str(labs[0].position)])
	await press(w2s(ent_point(hall)))
	await settle()
	_shift = true
	await key(KEY_1)
	_shift = false
	await settle()
	check("shift_number_adds_group", game().selection.size() >= labs.size() + 1, str(sel_kinds()))
	await press(w2s(ent_point(hall)))
	await settle()
	key_down(KEY_SHIFT, true)
	await ctrl_key(KEY_1)
	key_down(KEY_SHIFT, false)
	await key(KEY_ESCAPE)
	await key(KEY_1)
	await settle()
	check("ctrl_shift_number_adds", sel_kinds().has("town_hall"), str(sel_kinds()))
	await shot("groups_bar")
	# ---- orders
	await key(KEY_ESCAPE)
	await drag(r.position, r.end)
	await settle()
	var spot: Vector2 = hall.position + Vector2(-200, 160)
	await rclick(w2s(spot))
	await settle()
	check("rclick_move", labs.all(func(u) -> bool: return u.order in ["move", "amove"]), str(labs.map(func(u) -> String: return u.order)))
	_shift = true
	await rclick(w2s(spot + Vector2(100, 0)))
	await rclick(w2s(spot + Vector2(100, 100)))
	_shift = false
	await settle()
	var qn: int = labs[0].queue.size()
	check("shift_queue", qn >= 2, "queue %d" % qn)
	await shot("shift_queue")
	await key(KEY_S)
	await settle()
	check("S_stops", labs.all(func(u) -> bool: return u.order == "idle"), str(labs.map(func(u) -> String: return u.order)))
	await key(KEY_H)
	await settle()
	check("H_holds", labs.all(func(u) -> bool: return u.order == "hold"), str(labs.map(func(u) -> String: return u.order)))
	await key(KEY_M)
	check("M_move_mode", hud().controls.mode == "move", hud().controls.mode)
	await click(w2s(spot))
	await settle()
	check("move_click", labs.all(func(u) -> bool: return u.order == "move"), str(labs.map(func(u) -> String: return u.order)))
	await key(KEY_A)
	check("A_attack_mode", hud().controls.mode == "attack", hud().controls.mode)
	await click(w2s(spot + Vector2(60, 0)))
	await settle()
	check("attack_move", labs.all(func(u) -> bool: return u.order == "amove"), str(labs.map(func(u) -> String: return u.order)))
	await key(KEY_P)
	check("P_patrol_mode", hud().controls.mode == "patrol", hud().controls.mode)
	await key(KEY_ESCAPE)
	check("esc_cancels_mode", hud().controls.mode == "", hud().controls.mode)
	# right-drag line
	await drag(w2s(spot + Vector2(-120, 0)), w2s(spot + Vector2(120, 0)), MOUSE_BUTTON_RIGHT, 12)
	await wait(3)
	var ys := labs.map(func(u) -> float: return u.position.y)
	var xs := labs.map(func(u) -> float: return u.position.x)
	check("line_move", (ys.max() - ys.min()) < 60 and (xs.max() - xs.min()) > 120, "xs %s ys %s" % [str(xs), str(ys)])
	await shot("line_move")
	# ---- minimap
	var m: Rect2 = hud().mini_rect()
	var ms: float = hud().ui_scale
	var c0 := cam()
	await press((m.position + m.size * 0.8) * ms)
	await settle()
	check("minimap_click", cam().distance_to(c0) > 300, "%s -> %s" % [str(c0), str(cam())])
	await drag((m.position + m.size * 0.2) * ms, (m.position + m.size * 0.6) * ms, MOUSE_BUTTON_LEFT, 10)
	await settle()
	var expect := Vector2(Game.W, Game.H) * Game.T * 0.6
	check("minimap_drag", cam().distance_to(expect) < 400, "cam %s expect ~%s" % [str(cam()), str(expect)])
	await key(KEY_1)
	await settle()
	await rclick((m.position + m.size * 0.3) * ms)
	await settle()
	check("minimap_rclick_orders", labs.any(func(u) -> bool: return u.order in ["move", "amove"]), str(labs.map(func(u) -> String: return u.order)))
	await key(KEY_S)
	# ---- camera
	c0 = cam()
	await move(Vector2(vp_size().x - 1, vp_size().y * 0.4), 3)
	await wait_real(1.0)
	check("edge_scroll", cam().x > c0.x + 40, "%s -> %s" % [str(c0), str(cam())])
	await move(vp_size() * 0.5, 3)
	var z0: float = game().camera.zoom.x
	await wheel(vp_size() * 0.4, true, 3)
	var z1: float = game().camera.zoom.x
	await wheel(vp_size() * 0.4, false, 6)
	var z2: float = game().camera.zoom.x
	check("wheel_zoom", z1 > z0 and z2 < z1, "%.2f %.2f %.2f" % [z0, z1, z2])
	await key(KEY_1)
	await key(KEY_SPACE)
	await settle()
	check("space_centres", cam().distance_to(labs[0].position) < 500, str(cam()))
	_shift = true
	await key(KEY_F5)
	_shift = false
	await settle()
	var saved_cam := cam()
	step("Shift+F5 toast '%s'" % toast_text())
	await hold_key(KEY_LEFT, 0.8)
	await key(KEY_F5)
	await settle()
	check("camera_view_F5", cam().distance_to(saved_cam) < 20, "%s v %s" % [str(cam()), str(saved_cam)])
	await key(KEY_F1)
	await settle()
	step("F1 idle -> %s" % str(sel_kinds()))
	await key(KEY_F2)
	await settle()
	step("F2 army -> %s toast '%s'" % [str(sel_kinds()), toast_text()])
	await key(KEY_F3)
	await settle()
	check("F3_make", sel_kinds().has("town_hall"), str(sel_kinds()))
	# the hall's labourer by its letter
	var q0: int = hall.queue.size()
	var key_l := ""
	for b in hud()._card_items:
		if String(b[1]).begins_with("LABOURER"):
			key_l = String(b[6]) if b.size() > 6 else ""
	step("LABOURER hotkey is '%s'" % key_l)
	if key_l.length() == 1:
		await key(OS.find_keycode_from_string(key_l))
		await settle()
		check("card_hotkey", hall.queue.size() == q0 + 1, "queue %d -> %d" % [q0, hall.queue.size()])
	# ---- chat
	await key(KEY_ENTER)
	await settle()
	check("enter_opens_chat", hud().chat_typing, "")
	await type_text("gl hf")
	await key(KEY_ENTER)
	await settle()
	check("chat_sent", not hud().chat_typing, "")
	await shot("chat")
	# ---- the in-match menu
	var mr: Rect2 = hud().menu_rect()
	await press(mr.get_center() * ms)
	await settle()
	check("menu_opens", hud().menu_open, "")
	await shot("match_menu")
	var labels: Array = hud()._menu_buttons().map(func(b) -> String: return String(b.get("label", "")))
	step("menu: " + ", ".join(labels))
	await menu_press("PAUSE")
	await settle()
	check("pause", paused or hud().paused, "tree %s hud %s" % [paused, hud().paused])
	var clk: float = g.clock
	await wait_real(1.0)
	check("paused_clock_stops", absf(g.clock - clk) < 0.01, "%.2f -> %.2f" % [clk, g.clock])
	await shot("paused")
	if not hud().menu_open:
		await press(mr.get_center() * ms)
		await settle()
	await menu_press("RESUME")
	await settle()
	check("resume", not hud().paused, "")
	if not hud().menu_open:
		await press(mr.get_center() * ms)
		await settle()
	await menu_press("SETTINGS")
	await wait_real(0.5)
	await shot("settings_over_match")
	step("settings buttons: " + list_buttons().substr(0, 600))
	await key(KEY_ESCAPE)
	await wait_real(0.3)
	check("settings_esc_back", not hud().settings_open, "")
	# leave to the menu and CONTINUE
	var n_units := my_units().size()
	clk = g.clock
	await press(mr.get_center() * ms)
	await settle()
	await menu_press("QUIT TO MENU")
	await wait_real(1.5)
	await shot("menu_after_quit")
	step("main menu: " + list_buttons())
	var ok := await press_button("CONTINUE")
	await wait_match()
	await wait_real(1.0)
	if ok and main.game:
		check("continue_restores", absf(main.game.clock - clk) < 5.0 and absf(my_units().size() - n_units) <= 2, "clock %.1f v %.1f units %d v %d" % [main.game.clock, clk, my_units().size(), n_units])
		await key(KEY_1)
		await settle()
		check("groups_after_continue", game().selection.size() >= 4, str(sel_kinds()))
	await shot("continued")
	# surrender
	mr = hud().menu_rect()
	await press(mr.get_center() * ms)
	await settle()
	await menu_press("SURRENDER")
	await settle()
	await shot("surrender_confirm")
	await menu_press("YES, SURRENDER")
	await wait_real(3.0)
	check("surrender_ends", game() == null or game().over, "")
	await shot("after_surrender")
	step("after surrender: " + list_buttons())
	await press_button("COPY LOG")
	await settle()
	var clip := DisplayServer.clipboard_get()
	check("copy_log", clip.begins_with("Triumviwar"), clip.substr(0, 80))
	step("CHECKS failed %d" % fails)


func menu_press(label: String) -> void:
	for b in hud()._menu_buttons():
		if String(b.get("label", "")).begins_with(label):
			await press((b["rect"] as Rect2).get_center() * hud().ui_scale)
			step("menu '%s'" % label)
			return
	finding("MENU: no '%s' (menu: %s)" % [label, str(hud()._menu_buttons().map(func(b) -> String: return String(b.get("label", ""))))])
