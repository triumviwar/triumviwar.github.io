extends "res://tools/playtest/pt_base.gd"
## PLAYTEST, saving and loading (job playtest-menus-online). The game keeps ONE save: the autosave of the match
## being played (user://autosave.json, every 15 s and when you leave); the main menu's CONTINUE brings it back.
##   PT_HOME=<dir> tools/playtest/run.sh pt_saves 1280x720 case:play      a skirmish by clicks, MENU > QUIT TO MENU,
##                                                                        CONTINUE, the same again, then EXIT
##   PT_HOME=<dir> tools/playtest/run.sh pt_saves 1280x720 case:restart   (same folder) CONTINUE after a restart
##   PT_HOME=<dir> tools/playtest/run.sh pt_saves 1280x720 case:<bad>     a broken or old save file first

var hud: Control


func play() -> void:
	var c := String(args.get("case", "play"))
	if c.begins_with("bad_"):
		write_bad(c)
	await start_main()
	await look("menu_" + c)
	var cont: Button = main.menu_buttons.get("continue")
	print("PT %s CONTINUE shown: %s  (%s)" % [c, cont != null, shown(cont).replace("\n", " ") if cont else ""])
	check_errors(c)
	match c:
		"play":
			await play_and_continue()
		"restart":
			if cont == null:
				find("BUG", "restart", "no CONTINUE after a restart (the match was left with QUIT TO MENU, then EXIT)")
				return
			await continue_and_check("restart")
			await quit_to_menu("restart")
		_:
			if cont != null:
				await tap(cont)
				await wait(3.0)
				check_errors(c)
				await look("after_continue_" + c)
				if main.game != null:
					await quit_to_menu(c)
			await look("menu_end_" + c)


func write_bad(c: String) -> void:
	var v := String(ProjectSettings.get_setting("application/config/version", "dev"))
	var good := ""
	if FileAccess.file_exists("res://tools/playtest/fixtures/autosave_good.json"):
		good = FileAccess.get_file_as_string("res://tools/playtest/fixtures/autosave_good.json")
	var t := ""
	match c:
		"bad_garbage":
			t = "\u0000\u0001 this is not json {{{"
		"bad_empty":
			t = ""
		"bad_array":
			t = "[1, 2, 3]"
		"bad_truncated":
			t = good.substr(0, good.length() / 2)
		"bad_old_version":
			var d: Dictionary = JSON.parse_string(good)
			d["version"] = "0.37.0"
			t = JSON.stringify(d)
		"bad_no_slots":
			t = JSON.stringify({"version": v, "clock": 75.0, "cfg": {"map": "greenhold"}})
		"bad_no_clock":
			var d2: Dictionary = JSON.parse_string(good)
			d2.erase("clock")
			t = JSON.stringify(d2)
		"bad_cfg_array":
			t = JSON.stringify({"version": v, "clock": 75.0, "cfg": [1, 2]})
		"bad_units_broken":
			var d3: Dictionary = JSON.parse_string(good)
			for k in d3.keys():
				if d3[k] is Array and (d3[k] as Array).size() > 3 and k != "cfg":
					d3[k] = (d3[k] as Array).slice(0, 2) + [{"kind": "no_such_unit", "pos": "x"}, 7, null]
			t = JSON.stringify(d3)
	var f := FileAccess.open(SaveGame.PATH, FileAccess.WRITE)
	f.store_string(t)
	f.close()


# ------------------------------------------------------------------ the HUD (drawn by hand: its rects are read, the clicks are real)

func hud_point(local: Vector2) -> Vector2:
	return root.get_final_transform() * hud.get_global_transform_with_canvas() * local


func hud_tap(r: Rect2) -> void:
	await tap_at(hud_point(r.get_center()))


func menu_item(label: String) -> Dictionary:
	for b in hud._menu_buttons():
		if String(b["label"]).begins_with(label):
			return b
	return {}


func open_game_menu() -> void:
	await hud_tap(hud.menu_rect())
	await wait(0.4)
	if not hud.menu_open:
		find("BUG", "hud", "the MENU button did not open the menu")


func quit_to_menu(where: String) -> void:
	hud = main.game.hud if main.game else null
	if hud == null:
		return
	await open_game_menu()
	await look("game_menu_" + where)
	var q := menu_item("QUIT TO MENU")
	if q.is_empty():
		find("BUG", where, "no QUIT TO MENU in the match menu")
		return
	await hud_tap(q["rect"])
	await wait(1.0)
	if main.game != null:
		var y := menu_item("YES")
		if not y.is_empty():
			await hud_tap(y["rect"])
			await wait(1.0)
	if main.game != null:
		find("BUG", where, "QUIT TO MENU did not leave the match")


func start_skirmish() -> void:
	await tap(main.menu_buttons["skirmish"])
	await wait(0.6)
	await look("lobby")
	if not await press("START", 0.2, true):
		find("BUG", "lobby", "no START")
		return
	for i in 120:
		await wait(0.25)
		if main.game != null and main.game.clock > 0.5:
			break
	if main.game == null:
		find("BUG", "lobby", "START pressed, no match after 30 s")
		return
	hud = main.game.hud


func play_and_continue() -> void:
	await start_skirmish()
	if main.game == null:
		return
	await look("match_start", 1.0)
	# play like a person for a while: select all workers? the hall: a click on the screen middle, the hall's hotkey,
	# a right click somewhere, Ctrl+1, the camera keys
	var vs := Vector2(DisplayServer.window_get_size())
	await click_at(vs * 0.5)
	await key_tap(KEY_H)
	await click_at(vs * Vector2(0.55, 0.45), MOUSE_BUTTON_RIGHT)
	await key_tap(KEY_1, false, true)
	for i in 10:
		key(KEY_RIGHT, true)
		await wait(0.1)
	key(KEY_RIGHT, false)
	for i in 40:
		await wait(0.5)
		if main.game.clock > 22.0:
			break
	await look("match_played")
	var clock0: float = main.game.clock
	var units0: int = main.game.units.size()
	var builds0: int = main.game.buildings.size()
	print("PT left at %.1f s, %d units, %d buildings" % [clock0, units0, builds0])
	await quit_to_menu("first")
	await wait(0.6)
	var cont: Button = main.menu_buttons.get("continue")
	await look("menu_with_continue")
	if cont == null:
		find("BUG", "play", "no CONTINUE on the menu after QUIT TO MENU")
		return
	print("PT CONTINUE text: ", shown(cont).replace("\n", " | "))
	await continue_and_check("first", clock0, units0, builds0)
	# play on a little, leave again (the save is written again), then EXIT
	for i in 20:
		await wait(0.5)
	await quit_to_menu("second")
	await wait(0.5)
	var before := FileAccess.get_file_as_string(SaveGame.PATH)
	print("PT save size %d bytes" % before.length())
	if main.menu_buttons.has("exit"):
		print("PT PRESS EXIT")
		await tap(main.menu_buttons["exit"])
		await wait(1.0)
		find("BUG", "play", "EXIT did not close the game")


func continue_and_check(where: String, clock0 := -1.0, units0 := -1, builds0 := -1) -> void:
	var cont: Button = main.menu_buttons.get("continue")
	await tap(cont)
	for i in 120:
		await wait(0.25)
		if main.game != null and main.game.hud != null:
			break
	if main.game == null:
		find("BUG", where, "CONTINUE pressed, no match")
		return
	hud = main.game.hud
	await wait(1.0)
	await look("continued_" + where)
	print("PT continued at %.1f s, %d units, %d buildings" % [main.game.clock, main.game.units.size(), main.game.buildings.size()])
	if clock0 >= 0.0 and absf(main.game.clock - clock0) > 20.0:
		find("BUG", where, "continued at %.1f s, left at %.1f s" % [main.game.clock, clock0])
	if units0 >= 0 and absi(main.game.units.size() - units0) > 3:
		find("BUG", where, "continued with %d units, left with %d" % [main.game.units.size(), units0])
	if builds0 >= 0 and main.game.buildings.size() != builds0:
		print("PT NOTE buildings %d after CONTINUE, %d when left (a site placed meanwhile?)" % [main.game.buildings.size(), builds0])
	check_errors(where)
