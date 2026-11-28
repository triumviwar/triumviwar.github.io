extends SceneTree
## THE MAIN MENU'S GRID (the owner's layout, 2026-10-31; GROUPS since menu-groups, docs/menu_groups.md):
##   top level  OFFLINE ONLINE REPLAYS EDITOR / SETTINGS EXIT (not on the web) CONTINUE (only with a save)
##   OFFLINE    TUTORIAL CAMPAIGN SKIRMISH WORLD WAR / BACK
##   ONLINE     PLAY ONLINE TOURNAMENTS / BACK
## inside the painting's top-left sky and never over the CROSS (Main.menu_keepout) at any screen size; Esc does nothing
## on the top level and goes up a level in a group; a page's BACK returns to the group it was opened from;
## HOW TO PLAY is on the TUTORIAL page, MATCH LOGS on the REPLAYS page.
##   godot --headless --script res://tools/test_menu_grid.gd
## Prints PASS / FAIL lines and "menu_grid: N fails".
var main
var fails := 0


func _initialize() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	Settings.load_all()
	Settings.device = "pc"
	Settings.apply()
	Loc.set_lang("en")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _check(what: String, ok: bool, got: Variant) -> void:
	print(("PASS " if ok else "FAIL ") + what + "  " + str(got))
	if not ok:
		fails += 1


func _esc() -> void:
	var ev := InputEventKey.new()
	ev.keycode = KEY_ESCAPE
	ev.pressed = true
	root.push_input(ev)


func _on_menu() -> bool:
	return is_instance_valid(main._menu_grid) and main._menu_grid.is_inside_tree()


func _on_group(g: String) -> bool:
	return _on_menu() and main.menu_group == g


## No button of the shown level covers the cross, none overlap, all inside the sky.
func _grid_ok(what: String) -> void:
	var b: Dictionary = main.menu_buttons
	var vs: Vector2 = main._menu_grid.size
	var sky := Rect2(Vector2.ZERO, vs * Vector2(0.62, 0.62))
	var ko: Rect2 = main.menu_keepout(vs)
	var rects: Array = []
	for id in b:
		var r := Rect2(b[id].position, b[id].size)
		rects.append(r)
		if not sky.encloses(r):
			_check(what + ": " + id + " inside the sky", false, [r, sky])
		if r.intersects(ko):
			_check(what + ": " + id + " clear of the cross", false, [r, ko])
	var lap := false
	for i in rects.size():
		for j in range(i + 1, rects.size()):
			lap = lap or (rects[i] as Rect2).intersects(rects[j])
	_check(what + ": no two buttons overlap", not lap, rects.size())


## Open a page with `open`, press Esc (its BACK): back on the main menu?
func _back_from(name: String, open: Callable) -> void:
	open.call()
	await process_frame
	await process_frame
	_check(name + " has a BACK", is_instance_valid(main._esc_button), main._esc_button)
	_esc()
	await process_frame
	await process_frame
	_check(name + " BACK -> main menu", _on_menu(), name)


## The same from a group: back on that group.
func _back_to(group: String, name: String, id: String) -> void:
	main.menu_group = group
	main.show_menu()
	await process_frame
	main.menu_buttons[id].pressed.emit()
	await process_frame
	await process_frame
	_check(name + " has a BACK", is_instance_valid(main._esc_button), main._esc_button)
	_esc()
	await process_frame
	await process_frame
	_check(name + " BACK -> the %s group" % group.to_upper(), _on_group(group), [main.menu_group, _on_menu()])


func _run() -> void:
	await process_frame
	main.menu_group = ""
	main.show_menu()
	await process_frame
	await process_frame
	var b: Dictionary = main.menu_buttons
	var top := ["g_offline", "g_online", "replays", "editor", "settings", "exit"]
	var miss := top.filter(func(id: String) -> bool: return not b.has(id))
	_check("the top level's 6 fixed buttons", miss.is_empty(), miss)
	_check("no grouped button on the top level", not (b.has("campaign") or b.has("skirmish") or b.has("tournament") or b.has("worldwar") or b.has("tutorial") or b.has("online")), b.keys())
	_check("OFFLINE first, ONLINE beside it", b["g_offline"].text == "OFFLINE" and b["g_online"].text == "ONLINE" and absf(b["g_offline"].position.y - b["g_online"].position.y) < 1.0 and b["g_offline"].position.x < b["g_online"].position.x, [b["g_offline"].position, b["g_online"].position])
	_check("no Esc on the top level", main._esc_button == null, main._esc_button)
	_grid_ok("top")
	_check("title box", main._menu_title.position.x <= main._menu_grid.size.x * 0.01 and main._menu_title.size.x <= main._menu_grid.size.x * 0.53 + 1, Rect2(main._menu_title.position, main._menu_title.size))
	var save: Dictionary = SaveGame.peek()
	var want_cont: bool = not save.is_empty() and not SaveGame.old_brood(save) and save.get("version", "") == main.version
	_check("CONTINUE only with a save of this version", b.has("continue") == want_cont, [b.has("continue"), want_cont])
	var fake := {"version": main.version, "cfg": {"slots": [{"faction": "crown"}, {"faction": "clockwork"}]}, "clock": 754}
	var c: Button = main._menu_button("continue", fake, true)
	_check("CONTINUE with a save", c != null and c.text.begins_with("CONTINUE\n("), c.text if c else null)
	_check("no CONTINUE without a save", main._menu_button("continue", {}, true) == null, "")
	var old := fake.duplicate(true)
	old["version"] = "0.0.1"
	_check("no CONTINUE for another version's save", main._menu_button("continue", old, true) == null, "")
	# OFFLINE
	b["g_offline"].pressed.emit()
	await process_frame
	await process_frame
	b = main.menu_buttons
	_check("OFFLINE: its group", _on_group("offline") and b.has("tutorial") and b.has("campaign") and b.has("skirmish") and b.has("worldwar") and b.has("back"), b.keys())
	_check("OFFLINE: SKIRMISH text", b["skirmish"].text == "SKIRMISH", b["skirmish"].text)
	_check("OFFLINE: TUTORIAL next to CAMPAIGN (same row)", absf(b["tutorial"].position.y - b["campaign"].position.y) < 1.0 and b["tutorial"].position.x < b["campaign"].position.x, [b["tutorial"].position, b["campaign"].position])
	_check("OFFLINE: CAMPAIGN enabled", not b["campaign"].disabled, "")
	_check("OFFLINE: Esc is its BACK", main._esc_button == b["back"], main._esc_button)
	_grid_ok("offline")
	_esc()
	await process_frame
	await process_frame
	_check("Esc in OFFLINE -> the top level", _on_group(""), main.menu_group)
	# ONLINE
	main.menu_buttons["g_online"].pressed.emit()
	await process_frame
	await process_frame
	b = main.menu_buttons
	_check("ONLINE: its group", _on_group("online") and b.has("online") and b.has("tournament") and b.has("back"), b.keys())
	_check("ONLINE: PLAY ONLINE, TOURNAMENTS", b["online"].text.replace("\n", " ") == "PLAY ONLINE" and b["tournament"].text == "TOURNAMENTS", [b["online"].text, b["tournament"].text])
	_grid_ok("online")
	b["back"].pressed.emit()
	await process_frame
	_check("ONLINE's BACK -> the top level", _on_group(""), main.menu_group)
	# the phone's back in a group: up a level, not the quit question
	main.menu_buttons["g_online"].pressed.emit()
	await process_frame
	main._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await process_frame
	_check("the phone's back in a group -> the top level, no question", _on_group("") and not main.ask_open(), [main.menu_group, main.ask_open()])
	# menu_open / menu_reveal (tests and playtest drivers)
	var cb: Button = main.menu_open("campaign")
	_check("menu_open opens the button's group", cb != null and cb.is_visible_in_tree() and main.menu_group == "offline", main.menu_group)
	_check("menu_reveal by label goes to the top level for SETTINGS", main.menu_reveal("SETTINGS") and main.menu_group == "", main.menu_group)
	_check("menu_reveal by name: Menu_tournament", main.menu_reveal("Menu_tournament") and main.menu_group == "online", main.menu_group)
	_check("menu_reveal: a shown button is left alone", not main.menu_reveal("TOURNAMENTS"), "")
	# the keyboard: Enter on OFFLINE focuses the first button there
	main.menu_group = ""
	main.show_menu()
	await process_frame
	main.menu_buttons["g_offline"].grab_focus()
	await process_frame
	var ev := InputEventAction.new()
	ev.action = "ui_accept"
	ev.pressed = true
	Input.parse_input_event(ev)
	await process_frame
	var up := InputEventAction.new()
	up.action = "ui_accept"
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame
	await process_frame
	var fo: Control = root.gui_get_focus_owner()
	_check("Enter on OFFLINE: OFFLINE's first button has the focus", _on_group("offline") and fo != null and fo == main.menu_buttons.get("tutorial"), [main.menu_group, fo])
	# the cross at every screen size: no cell of any group over it
	for vs in [Vector2(1280, 720), Vector2(1600, 720), Vector2(1707, 720), Vector2(1280, 960), Vector2(1280, 800), Vector2(1440, 720)]:
		for pc in [true, false]:
			var ko: Rect2 = main.menu_keepout(vs)
			var g: Array = main.menu_geometry(vs, pc)
			var bs: Vector2 = g[0]
			var cells: Array = main.menu_cells(vs, pc, 7)
			var bad := cells.filter(func(p: Vector2) -> bool: return Rect2(p, bs).intersects(ko))
			_check("%s %s: 7 cells clear of the cross" % [vs, "pc" if pc else "phone"], bad.is_empty() and cells.size() == 7, cells)
			if not pc:
				_check("%s phone: min size" % vs, bs.x >= main.MENU_MIN_MOBILE.x and bs.y >= main.MENU_MIN_MOBILE.y, bs)
			var far := Vector2.ZERO
			for p in cells:
				far = far.max(p + bs)
			_check("%s %s: grid compact" % [vs, "pc" if pc else "phone"], far.x <= vs.x * 0.5 and far.y <= vs.y * 0.62, far / vs)
	_check("the cross's painting is the size measured", (load("res://assets/menu/battle.jpg") as Texture2D).get_size() == main.MENU_PAINT, "")
	# EXIT hidden on the web
	main.menu_web = true
	main.menu_group = ""
	main.show_menu()
	await process_frame
	_check("no EXIT on the web", not main.menu_buttons.has("exit") and main.menu_buttons.has("settings"), main.menu_buttons.keys())
	main.menu_web = false
	main.show_menu()
	await process_frame
	# Esc on the top level does nothing
	_esc()
	await process_frame
	_check("Esc on the top level: still the menu", _on_group(""), "")
	# MATCH LOGS from the REPLAYS page
	var rm = main.show_replays()
	await process_frame
	var logs: Button = rm.find_child("MatchLogs", true, false)
	_check("MATCH LOGS on the REPLAYS page", logs != null and logs.text == "MATCH LOGS", logs)
	if logs:
		logs.pressed.emit()
		await process_frame
		_check("MATCH LOGS opens the logs", is_instance_valid(main._esc_button) and not _on_menu(), "")
		_esc()
		await process_frame
		await process_frame
		_check("logs BACK -> main menu", _on_menu(), "")
	# every page's BACK comes back to the group it was opened from
	await _back_to("offline", "TUTORIAL", "tutorial")
	await _back_to("offline", "SKIRMISH", "skirmish")
	await _back_to("offline", "WORLD WAR", "worldwar")
	await _back_to("online", "PLAY ONLINE", "online")
	await _back_to("", "REPLAYS", "replays")
	await _back_to("", "EDITOR", "editor")
	await _back_to("", "SETTINGS", "settings")
	# HOW TO PLAY from the TUTORIAL page; its BACK goes to the TUTORIAL page
	main.menu_open("tutorial").pressed.emit()
	await process_frame
	var hb: Button = main.find_child("Tutorial_Help", true, false)
	_check("HOW TO PLAY on the TUTORIAL page", hb != null and hb.text == "HOW TO PLAY", hb)
	if hb:
		hb.pressed.emit()
		await process_frame
		_esc()
		await process_frame
		await process_frame
		_check("HOW TO PLAY BACK -> TUTORIAL page", main.find_child("Tutorial_Help", true, false) != null, "")
	print("menu_grid: %d fails" % fails)
	quit(1 if fails > 0 else 0)
