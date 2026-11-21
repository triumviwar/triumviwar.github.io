extends "res://tools/playtest/pt_mission.gd"
## The confused / fiddling player in the Prologue: in by the LIST (not the map), SKIP on the opening, mashing keys in
## the 3-2-1, the dialogue's NEXT and SKIP, the objectives folded, the MENU: PAUSE (does the clock stop? do the lines
## stop?), SETTINGS over the match, the window resized to a phone's size and back, QUIT TO MENU (is anything kept? is
## there a CONTINUE?), back in, SURRENDER, the end screen's PLAY AGAIN (the opening again?), BATTLE REPORT, CAMPAIGN.


func setup() -> void:
	mid = "p01_leaf"
	super.setup()
	tag = "p01ui_%s_%s_%s" % [diff, device, lang]


func play() -> void:
	if not await enter("list"):
		return
	await opening(true)
	if g() == null:
		return
	# the 3-2-1: mash
	for k in [KEY_F2, KEY_A, KEY_ESCAPE, KEY_H, KEY_S, KEY_SPACE, KEY_F1, KEY_F3]:
		await key(k)
	await click_at(Vector2(640, 300))
	await click_at(Vector2(640, 300), MOUSE_BUTTON_RIGHT)
	flush_errors("countdown mash")
	await play_for(6.0, 2.0)
	# the dialogue box: NEXT, then SKIP
	var nb := by_name("Dialogue_NEXT")
	note("dialogue box at start: %s" % [nb != null])
	await shot("10_dialogue")
	off_screen("dialogue")
	if nb:
		var before := said.size()
		await press_name("Dialogue_NEXT")
		await press_name("Dialogue_SKIP", false)
		await frames(3)
		check("SKIP hides the dialogue box", by_name("Dialogue_NEXT") == null)
		await play_for(10.0, 2.0)
		note("lines after skip: %d -> %d" % [before, said.size()])
	# fold the objectives: a click on their title
	var mu: MissionUi = null
	for n in main.ui_layer.get_children():
		if n is MissionUi:
			mu = n
	if mu:
		var op: Control = mu._obj
		await click_at(to_window(op, Vector2(40, 12)))
		await frames(3)
		await shot("11_objectives_folded")
		note("objectives folded: %s" % mu.folded if "folded" in mu else "?")
		await click_at(to_window(op, Vector2(40, 12)))
	# PAUSE from the MENU
	await menu_open()
	note("menu: %s" % [menu_labels()])
	await shot("12_menu")
	check("no SAVE in a campaign mission's menu", not menu_labels().any(func(l: String) -> bool: return l.begins_with("SAVE")),
		str(menu_labels()))
	await menu_press("PAUSE")
	await menu_press("BACK TO THE MATCH")
	var c0 := g().clock
	await wait(3.0)
	check("PAUSE stops the clock", is_equal_approx(g().clock, c0), "%.2f -> %.2f" % [c0, g().clock])
	await shot("13_paused")
	off_screen("paused")
	# a line arriving while paused waits (the box doesn't count down): read what it shows
	# RESUME from the small panel
	var pb: Array = hud()._paused_buttons()
	if not pb.is_empty():
		await click_at(to_window(hud(), (pb[0]["rect"] as Rect2).get_center()))
	await wait(1.0)
	check("RESUME runs the clock again", g().clock > c0)
	# SETTINGS over the match
	await menu_open()
	await menu_press("SETTINGS")
	await frames(10)
	await shot("14_settings_in_match")
	off_screen("settings over the match")
	note("settings page: %s" % labels_text().left(200))
	await key(KEY_ESCAPE)
	await frames(6)
	check("Esc closes the Settings over the match", not hud().settings_open)
	if hud().menu_open:
		await menu_press("BACK TO THE MATCH")
	# the window to a phone's size and back
	if not headless:
		DisplayServer.window_set_size(Vector2i(844, 390))
		await frames(20)
		await shot("15_resized_small")
		off_screen("resized 844x390")
		DisplayServer.window_set_size(Vector2i(1280, 720))
		await frames(20)
		await shot("16_resized_back")
		flush_errors("resize")
	# QUIT TO MENU
	await play_for(20.0, 4.0)
	await menu_open()
	await menu_press("QUIT TO MENU")
	await frames(10)
	await shot("17_after_quit")
	check("QUIT TO MENU: the main menu", by_text("CAMPAIGN") != null)
	note("main menu after quitting a mission: %s" % [buttons().map(func(b: BaseButton) -> String: return String(b.text))])
	check("quitting records nothing", not Campaign.progress()["done"].has(mid))
	flush_errors("quit")
	# back in, the map path this time, read the opening; then SURRENDER
	if not await enter("map"):
		return
	await opening(false)
	await play_for(8.0, 2.0)
	await menu_open()
	await menu_press("SURRENDER")
	await shot("18_surrender_confirm")
	await menu_press("YES, SURRENDER")
	await frames(10)
	var txt := await ending(false)
	check("SURRENDER: DEFEAT", txt.find(Loc.t("DEFEAT")) >= 0, txt.left(80))
	check("a surrender records nothing", not Campaign.progress()["done"].has(mid))
	# PLAY AGAIN: does the opening come again? (StillShow) or straight in
	await press_name("End_PLAY_AGAIN")
	await frames(10)
	var again_show := by_name("StillShow") != null
	note("PLAY AGAIN shows the opening again: %s; game: %s" % [again_show, g() != null])
	await shot("19_play_again")
	while by_name("StillShow"):
		await press_name("Show_SKIP")
	await frames(10)
	check("PLAY AGAIN restarts the mission", g() != null and r() != null and r().id == mid)
	if g():
		said.clear()
		await play_for(5.0, 2.0)
		await menu_open()
		await menu_press("SURRENDER")
		await menu_press("YES, SURRENDER")
		await ending(false)
	await press_name("End_BATTLE_REPORT")
	await frames(10)
	await shot("20_battle_report")
	off_screen("battle report")
	note("battle report: %s" % labels_text().left(300))
	note("buttons on the report: %s" % [buttons().map(func(b: BaseButton) -> String: return String(b.text))])
	flush_errors("report")
	await key(KEY_ESCAPE)
	await frames(10)
	await shot("21_after_report_esc")
	note("after Esc on the report: %s" % [buttons().map(func(b: BaseButton) -> String: return String(b.text))])
