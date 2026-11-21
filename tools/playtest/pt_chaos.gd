extends "res://tools/playtest/pt_setup_util.gd"
## The player who tries to break it (docs/playtest_2026_11_21_skirmish_crown.md): double presses, Esc during page
## changes, random clicks and keys everywhere (the HUD too), drags that start on the HUD or leave the window, the
## window resized mid-match, the menu opened while placing, leaving to the menu while placing and CONTINUE, a second
## START press, the setup screen's every preset, eight players, every map arrow. Watch the log for SCRIPT ERRORs: each
## chaos step prints "PT [..] chaos <what>" first.

const KEYS := [KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F, KEY_G, KEY_H, KEY_M, KEY_P, KEY_Q, KEY_R, KEY_S, KEY_T, KEY_V,
	KEY_W, KEY_X, KEY_Z, KEY_1, KEY_2, KEY_3, KEY_0, KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F9, KEY_ESCAPE, KEY_TAB,
	KEY_SPACE, KEY_BACKSPACE, KEY_QUOTELEFT, KEY_DELETE]


func run() -> void:
	await wait_real(1.0)
	# double press on the menu, Esc while the page changes
	var sk := find_button("SKIRMISH")
	step("chaos double press SKIRMISH + Esc")
	var skp := ctl_center(sk)
	await click(skp)
	await click(skp)
	await key(KEY_ESCAPE)
	await wait_real(0.3)
	step("page now: " + list_buttons().substr(0, 200))
	if find_button("START") == null:
		await press_button("SKIRMISH")
	# every preset, eight players, the map arrows round and round
	for p in ["2v2", "3v3", "4v4", "1v2", "1v3", "FFA", "1v1"]:
		step("chaos preset " + p)
		await press_button(p)
		await shot("preset_" + p)
	for i in 8:
		var add := find_button("+  ADD PLAYER")
		if add == null:
			break
		await press_control(add)
	step("players after ADD x8: %d (buttons: %s)" % [main.lobby["slots"].size(), list_buttons().substr(0, 300)])
	await shot("eight_players")
	# every option of slot 2's dropdowns
	for col in [0, 1, 2, 3, 4]:
		var bs := slot_buttons(1)
		if col >= bs.size():
			continue
		await press_control(bs[col])
		await frames(4)
		var items := buttons().filter(func(b) -> bool: return b.get_parent() != null and b.get_parent().get_parent() is ScrollContainer and button_text(b) != "")
		step("chaos slot 2 column %d offers %d items" % [col, items.size()])
		await shot("dropdown_col%d" % col)
		# Esc closes the list?
		await key(KEY_ESCAPE)
		await frames(4)
		step("after Esc on the list: page %s" % ("setup" if find_button("START") else "LEFT THE SETUP"))
		if find_button("START") == null:
			finding("SETUP: Esc on an open dropdown left the setup page")
			await press_button("SKIRMISH")
	for i in 30:
		var nx := find_button(">")
		if nx:
			var nxp := ctl_center(nx)
			await click(nxp)
	step("chaos map arrows x30: map %s" % str(main.lobby["map"]))
	# remove players with ×
	for i in 8:
		var xs := buttons().filter(func(b) -> bool: return button_text(b) == "×")
		if xs.is_empty():
			break
		await press_control(xs.back())      # (the last row: YOU stays)
	step("players after × presses: %d" % main.lobby["slots"].size())
	await press_button("1v1")
	await pick_in_slot(0, 1, "CROWN")
	await pick_in_slot(1, 0, "HARD AI")
	await pick_in_slot(1, 1, "CLOCKWORK")
	# START pressed twice
	var stp := ctl_center(find_button("START"))
	step("chaos double START")
	await click(stp)
	await click(stp)
	await wait_match()
	await shot("match")
	# random clicks and keys everywhere
	for i in 220:
		var p := Vector2(randf() * vp_size().x, randf() * vp_size().y)
		var r := randf()
		if r < 0.35:
			await click(p)
		elif r < 0.5:
			await rclick(p)
		elif r < 0.7:
			await key(KEYS[randi() % KEYS.size()])
		elif r < 0.78:
			_shift = randf() < 0.5
			_ctrl = randf() < 0.3
			await click(p)
			_shift = false
			_ctrl = false
		elif r < 0.86:
			var q := Vector2(randf() * vp_size().x, randf() * vp_size().y)
			await drag(p, q, MOUSE_BUTTON_LEFT if randf() < 0.6 else MOUSE_BUTTON_RIGHT, 5)
		elif r < 0.92:
			await wheel(p, randf() < 0.5, 2)
		else:
			# drags leaving the window
			await drag(p, Vector2(-80, vp_size().y + 60), MOUSE_BUTTON_LEFT, 5)
		if i % 40 == 0:
			step("chaos random input %d" % i)
			await shot("chaos_%03d" % i)
		if main.game == null or main.game.over:
			step("the match ended or left during chaos at %d (game %s)" % [i, str(main.game)])
			break
	if main.game == null:
		return
	# resize the window mid-match
	step("chaos resize to 844x390 and back")
	DisplayServer.window_set_size(Vector2i(844, 390))
	await wait_real(1.0)
	await shot("resized_small")
	DisplayServer.window_set_size(Vector2i(1280, 720))
	await wait_real(1.0)
	await shot("resized_back")
	# placing a building, then the menu; then leaving while placing
	await key(KEY_ESCAPE)
	var labs := my_units("labourer")
	if not labs.is_empty():
		await look_at(ent_point(labs[0]))
		await click(w2s(ent_point(labs[0])))
		await settle()
		await card("BUILD")
		await settle()
		await card("COTTAGE")
		await move(vp_size() * 0.45, 3)
		step("chaos MENU while placing (mode '%s')" % hud().controls.mode)
		var mr: Rect2 = hud().menu_rect()
		await click(mr.get_center() * hud().ui_scale)
		await settle()
		await shot("menu_while_placing")
		for b in hud()._menu_buttons():
			if String(b.get("label", "")) == "QUIT TO MENU":
				await click((b["rect"] as Rect2).get_center() * hud().ui_scale)
		await wait_real(1.0)
		step("chaos left while placing; menu: " + list_buttons().substr(0, 200))
		var cont := nth_button("CONTINUE", 0)
		if cont:
			var cp := ctl_center(cont)
			await click(cp)
			await click(cp)
			await wait_match()
			await wait_real(1.0)
			step("continued: mode '%s' selection %d" % [hud().controls.mode, game().selection.size()])
			await shot("continued")
	# Esc spam and Alt+Enter
	for i in 6:
		await key(KEY_ESCAPE)
	step("chaos F11")
	await key(KEY_F11)
	await wait_real(0.5)
	await key(KEY_F11)
	await wait_real(0.5)
	await shot("after_f11")
