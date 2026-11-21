extends "res://tools/playtest/pt_base.gd"
## PLAYTEST, the menus (job playtest-menus-online): a player walks every page of the main menu with real clicks or taps.
##   tools/playtest/run.sh pt_menus 1280x720 out:<dir> lang:en device:pc player:careful
## player:careful  every page, every Settings row changed and changed back (checked in settings.cfg), BACK buttons
## player:fast     the same pages, BACK by Esc, double clicks, presses before a page has settled
## player:confused random taps on every page, Esc at odd moments, the window resized while a page is open


func play() -> void:
	var player := String(args.get("player", "careful"))
	await start_main()
	await look("menu")
	match player:
		"careful":
			await careful()
		"fast":
			await fast()
		"confused":
			await confused()


# ------------------------------------------------------------------ helpers

func cfg_text() -> String:
	return FileAccess.get_file_as_string(Settings.PATH) if FileAccess.file_exists(Settings.PATH) else ""


func back() -> void:
	if not await press("BACK", 0.35, true):
		await key_tap(KEY_ESCAPE)
		await wait(0.35)


func menu_shown() -> bool:
	return main.menu_buttons.has("settings") and is_instance_valid(main.menu_buttons["settings"]) and (main.menu_buttons["settings"] as Control).is_visible_in_tree()


func to_menu(where: String) -> void:
	for i in 4:
		if menu_shown():
			return
		await back()
	if not menu_shown():
		find("BUG", where, "could not get back to the main menu with BACK / Esc; buttons: %s" % str(button_texts()).substr(0, 300))


func menu_press(id: String) -> bool:
	if not main.menu_buttons.has(id):
		find("BUG", "menu", "no %s button on the main menu" % id)
		return false
	var b: Control = main.menu_buttons[id]
	print("PT PRESS menu %s" % id)
	await tap(b)
	await wait(0.5)
	return true


## Scrolls the list holding `c` with the wheel (or a finger drag on a phone) until it is fully on screen.
func bring_into_view(c: Control) -> void:
	var sc: ScrollContainer = null
	var p := c.get_parent()
	while p != null:
		if p is ScrollContainer:
			sc = p
			break
		p = p.get_parent()
	if sc == null:
		return
	for i in 30:
		var vr := screen_rect(sc)
		var r := screen_rect(c)
		if vr.encloses(r.grow(-1)):
			return
		var down := r.position.y > vr.position.y
		# (a finger drag scrolls only where the system says it has a touch screen; the virtual screen has none, so the
		# wheel stands in for the finger on the phone runs too)
		await scroll_at(vr.get_center(), down, 1)
		await process_frame
	print("PT NOTE could not scroll %s into view" % _path(c))


func finger_drag(a: Vector2, b: Vector2) -> void:
	var e := InputEventScreenTouch.new()
	e.position = a
	e.pressed = true
	Input.parse_input_event(e)
	await process_frame
	for i in 8:
		var d := InputEventScreenDrag.new()
		d.position = a.lerp(b, (i + 1) / 8.0)
		d.relative = (b - a) / 8.0
		Input.parse_input_event(d)
		await process_frame
	var u := InputEventScreenTouch.new()
	u.position = b
	u.pressed = false
	Input.parse_input_event(u)
	await process_frame


func rows_with_meta() -> Dictionary:
	var res := {}
	for c in all_controls():
		if (c as Control).has_meta("setting"):
			res[String((c as Control).get_meta("setting"))] = c
	return res


func first_of(n: Node, cls: String) -> Node:
	for ch in n.get_children():
		if ch.is_class(cls):
			return ch
		var x := first_of(ch, cls)
		if x != null:
			return x
	return null


# ------------------------------------------------------------------ the careful player

const SKIP_ROWS := ["device", "layout", "patch_notes", "anim_viewer", "music_player", "reset", "window_full", "fullscreen"]

func careful() -> void:
	# every page of the grid, in order
	for id in ["tutorial", "campaign", "skirmish", "help", "replays", "editor"]:
		if not await menu_press(id):
			continue
		await look("page_" + id)
		match id:
			"help":
				await walk_help()
			"replays":
				if await press("MATCH LOGS"):
					await look("match_logs")
					await back()
			"editor":
				await walk_editor_page()
		await to_menu(id)
	# the version line opens the patch notes
	var vb: BaseButton = null
	for b in buttons():
		if b.tooltip_text == "PATCH NOTES":
			vb = b
	if vb != null:
		await tap(vb)
		await wait(0.4)
		await look("patch_notes_from_version")
		await scroll_page("patch_notes_from_version")
		await back()
	await to_menu("patch notes")
	# SETTINGS, every tab and row
	await menu_press("settings")
	for tab in ["GAMEPLAY", "DISPLAY", "SOUND", "EXPERIMENTAL", "OTHER"]:
		var tb := find_by_name("Tab_" + tab)
		if tb == null:
			find("BUG", "settings", "no tab " + tab)
			continue
		await tap(tb)
		await wait(0.35)
		await look("settings_" + tab.to_lower())
		await walk_rows(tab)
		await look("settings_" + tab.to_lower() + "_after")
	# OTHER's pages
	await open_tab("OTHER")
	if await press_row("patch_notes"):
		await look("patch_notes_from_settings")
		await back()
		if not is_tab_open("OTHER"):
			find("UX", "settings", "BACK from PATCH NOTES did not return to Settings > OTHER (it returned to %s)" % page_name())
	await open_tab("OTHER")
	if await press_row("anim_viewer"):
		await look("anim_viewer")
		for b in ["FRAME >", "< UNIT", "UNIT >", "ALL DIRECTIONS"]:
			await press(b, 0.3)
		await look("anim_viewer_after")
		await back()
	await open_tab("OTHER")
	# RESET: armed, then pressed (everything but language, device, sound, relay back to the start)
	var before_reset := cfg_text()
	if await press_row("reset"):
		await look("reset_armed")
		await press_row("reset")
		await look("reset_done")
		print("PT reset changed settings.cfg: ", before_reset != cfg_text())
	# SOUND: the music player
	await open_tab("SOUND")
	if await press_row("music_player"):
		await look("music_player")
		await walk_music()
		await back()
		await look("after_music_back")
	await open_tab("GAMEPLAY")
	if await press_row("layout"):
		await look("layout")
		await back()
	await open_tab("GAMEPLAY")
	# PLAYING ON opens the device page; picking the same device comes back to the menu
	if await press_row("device"):
		await look("device_page")
		await press("COMPUTER" if device == "pc" else "MOBILE")
		await look("after_device")
	await to_menu("settings")
	# the flags on the main menu: Portuguese, Spanish, back to the start
	for code in ["pt", "es", lang]:
		var fl := find_flag(code)
		if fl == null:
			find("BUG", "menu", "no flag " + code)
			continue
		await tap(fl)
		await wait(0.4)
		if Settings.language != code:
			find("BUG", "menu", "flag %s pressed but the language is %s" % [code, Settings.language])
		await look("menu_flag_" + code)


func find_by_name(n: String) -> Control:
	for c in all_controls():
		if String(c.name) == n:
			return c
	return null


func find_flag(code: String) -> Control:
	for b in buttons():
		if b.tooltip_text == Loc.NATIVE[code]:
			return b
	return null


func is_tab_open(tab: String) -> bool:
	return find_by_name("Tab_" + tab) != null and main.settings_tab == tab


func page_name() -> String:
	return str(button_texts()).substr(0, 160)


func open_tab(tab: String) -> void:
	if find_by_name("Tab_" + tab) == null:
		if menu_shown():
			await menu_press("settings")
		else:
			await to_menu("open_tab")
			await menu_press("settings")
	var tb := find_by_name("Tab_" + tab)
	if tb != null:
		await tap(tb)
		await wait(0.3)


func press_row(id: String) -> bool:
	var rows := rows_with_meta()
	if not rows.has(id):
		print("PT MISS row ", id)
		return false
	var b := first_of(rows[id], "BaseButton") as Control
	if b == null:
		return false
	await bring_into_view(b)
	print("PT PRESS row %s '%s'" % [id, shown(b)])
	await tap(b)
	await wait(0.4)
	return true


## Every row of a tab: a switch pressed and pressed back, a stepping choice stepped all the way round, a slider
## moved and moved back, the relay address typed over and put back; each change must reach settings.cfg.
func walk_rows(tab: String) -> void:
	var ids: Array = rows_with_meta().keys()
	for id in ids:
		if SKIP_ROWS.has(id) or id == "language":
			continue
		var rows := rows_with_meta()
		if not rows.has(id):
			continue
		var row: Control = rows[id]
		var start := cfg_text()
		var slider := first_of(row, "HSlider") as HSlider
		var edit := first_of(row, "LineEdit") as LineEdit
		var btn := first_of(row, "BaseButton") as BaseButton
		if id in ["music", "sound", "ambience"]:
			await sound_row(id, row)
			continue
		if slider != null:
			await bring_into_view(slider)
			var v0 := slider.value
			await drag_slider(slider, 0.1 if slider.ratio > 0.5 else 0.9)
			var v1 := slider.value
			var saved_mid := cfg_text()
			await drag_slider(slider, (v0 - slider.min_value) / maxf(0.0001, slider.max_value - slider.min_value))
			print("PT ROW %s slider %.2f -> %.2f -> %.2f saved:%s" % [id, v0, v1, slider.value, saved_mid != start])
			if is_equal_approx(v0, v1):
				find("BUG", "settings " + tab, "slider %s did not move when dragged" % id)
			elif saved_mid == start:
				find("BUG", "settings " + tab, "slider %s moved but settings.cfg did not change" % id)
			continue
		if edit != null:
			await relay_row(edit, start)
			continue
		if btn == null:
			continue
		await bring_into_view(btn)
		var first_text := shown(btn)
		var seen: Array = [first_text]
		var changed_file := false
		for step in 8:
			await tap(btn)
			await wait(0.3)
			# a stepping row rebuilds the page: find the row's button again
			rows = rows_with_meta()
			if not rows.has(id):
				find("BUG", "settings " + tab, "row %s gone after pressing it (page now: %s)" % [id, page_name()])
				return
			btn = first_of(rows[id], "BaseButton") as BaseButton
			await bring_into_view(btn)
			if cfg_text() != start:
				changed_file = true
			var now := shown(btn)
			if now == first_text and cfg_text() == start:
				break
			seen.append(now)
		print("PT ROW %s %s saved:%s back:%s" % [id, str(seen), changed_file, cfg_text() == start])
		if seen.size() < 2:
			find("BUG", "settings " + tab, "row %s: pressing it changed nothing on screen" % id)
		if not changed_file:
			find("BUG", "settings " + tab, "row %s: settings.cfg never changed" % id)
		if shown(btn) != first_text:
			find("BUG", "settings " + tab, "row %s: going round its choices did not come back to '%s'" % [id, first_text])
		elif cfg_text() != start:
			print("PT NOTE row %s: back to '%s' on screen but saved as a chosen value, no longer the automatic default" % [id, first_text])


func sound_row(id: String, row: Control) -> void:
	var mute := first_of(row, "BaseButton") as BaseButton
	var sl := first_of(row, "HSlider") as HSlider
	var vol0: float = Music.me.get_volume(id)
	await bring_into_view(sl)
	await drag_slider(sl, 0.25)
	var vol1: float = Music.me.get_volume(id)
	await drag_slider(sl, vol0)
	var muted0: bool = Music.me.is_muted(id)
	await tap(mute)
	await wait(0.2)
	var muted1: bool = Music.me.is_muted(id)
	await tap(mute)
	await wait(0.2)
	print("PT ROW %s volume %.2f -> %.2f -> %.2f mute %s -> %s -> %s" % [id, vol0, vol1, Music.me.get_volume(id), muted0, muted1, Music.me.is_muted(id)])
	if is_equal_approx(vol0, vol1):
		find("BUG", "settings SOUND", "%s bar did not move" % id)
	if muted0 == muted1:
		find("BUG", "settings SOUND", "%s mute did nothing" % id)


func relay_row(edit: LineEdit, start: String) -> void:
	var orig := edit.text
	await bring_into_view(edit)
	await tap(edit)
	await key_tap(KEY_A, false, true)
	await type_text("ws://éçã 🙂 <bad> " + "x".repeat(200))
	await wait(0.2)
	var weird := Settings.relay_url
	await look("relay_weird")
	await key_tap(KEY_A, false, true)
	await key_tap(KEY_BACKSPACE)
	await wait(0.2)
	print("PT ROW relay typed '%s...' saved:%s empty now '%s'" % [weird.substr(0, 30), cfg_text() != start, Settings.relay_url])
	await type_text(orig)
	await key_tap(KEY_ENTER)
	await wait(0.2)
	if Settings.relay_url != orig:
		find("BUG", "settings GAMEPLAY", "relay address not back to '%s' (it is '%s')" % [orig, Settings.relay_url])
	# what does an empty relay field come back as after a restart? (load_all puts the default back)


func walk_help() -> void:
	var secs: Array = []
	for b in buttons():
		var raw: String = (b as Button).text if b is Button else ""
		if raw != "" and raw != "BACK" and b.tooltip_text != "PATCH NOTES":
			secs.append(shown(b))
	for t in secs:
		if await press(t, 0.3, true):
			await look("help_" + t.to_lower().replace(" ", "_").replace("/", "_").substr(0, 20))


func walk_editor_page() -> void:
	print("PT editor page buttons ", button_texts())


func scroll_page(name: String) -> void:
	var sc: ScrollContainer = null
	for c in all_controls("ScrollContainer"):
		sc = c
		break
	if sc == null:
		return
	var r := screen_rect(sc)
	await scroll_at(r.get_center(), true, 25)
	await look(name + "_scrolled")


func walk_music() -> void:
	var tracks: Array = []
	for b in buttons():
		if b is Button and (b as Button).tooltip_text in ["Battle", "Calm", "Main menu"]:
			tracks.append(b)
	print("PT music tracks on screen: ", tracks.size())
	if tracks.size() > 2:
		await press("The Orchard Minuet", 1.0)
		var now: String = Music.me.now_playing()
		print("PT music now playing: ", now)
		if now == "":
			find("BUG", "music player", "tapped a piece, nothing playing")
		await look("music_playing")
		if await press("PAUSE"):
			if not Music.me.is_paused():
				find("BUG", "music player", "PAUSE did not pause")
			await press("PLAY")
	# the mode button (IN A MATCH PLAY ...) round its modes
	var mb: BaseButton = null
	for b in buttons():
		if b is Button and Music.MODE_NAMES.values().has((b as Button).text):
			mb = b
	if mb != null:
		var m0: String = Music.me.mode
		for i in Music.MODES.size():
			await tap(mb)
			await wait(0.3)
			for b in buttons():
				if b is Button and Music.MODE_NAMES.values().has((b as Button).text):
					mb = b
			await look("music_mode_%d" % i)
		if Music.me.mode != m0:
			find("BUG", "music player", "mode did not come round to %s" % m0)


# ------------------------------------------------------------------ the fast player

func fast() -> void:
	for id in ["tutorial", "campaign", "skirmish", "help", "replays", "editor", "settings", "online"]:
		if not main.menu_buttons.has(id):
			continue
		var b: Control = main.menu_buttons[id]
		await double_click(b)                    # a double click on the menu button
		await frames(2)
		await look("fast_" + id, 0.15)
		# spam every visible button once, quickly, then Esc twice
		var bs := buttons()
		var n := 0
		for x in bs:
			if n > 6:
				break
			if not is_instance_valid(x):
				continue
			var t: String = (x as Button).text if x is Button else ""
			if t.contains("EXIT") or String(x.name) == "Menu_exit" or t.contains("START") or t.contains("PLAY") or t.contains("HOST") or t.contains("JOIN") or t.contains("DOWNLOAD"):
				continue
			if not (x as Control).is_visible_in_tree():
				continue
			await tap(x)
			n += 1
		await key_tap(KEY_ESCAPE)
		await key_tap(KEY_ESCAPE)
		await wait(0.3)
		check_errors("fast_" + id)
		await to_menu("fast " + id)
	# Settings tabs clicked as fast as frames allow
	await menu_press("settings")
	for i in 3:
		for tab in ["GAMEPLAY", "DISPLAY", "SOUND", "EXPERIMENTAL", "OTHER"]:
			var tb := find_by_name("Tab_" + tab)
			if tb != null:
				await tap(tb)
	await look("fast_tabs")
	await to_menu("fast tabs")
	# the flags hammered
	for i in 6:
		var fl := find_flag(["pt", "es", "en"][i % 3])
		if fl != null:
			await tap(fl)
	await look("fast_flags")
	var fl2 := find_flag(lang)
	if fl2 != null:
		await tap(fl2)


# ------------------------------------------------------------------ the confused player

func confused() -> void:
	var vs := Vector2(DisplayServer.window_get_size())
	for id in ["settings", "help", "replays", "editor", "tutorial", "campaign", "skirmish", "online"]:
		await to_menu("confused " + id)
		if not await menu_press(id):
			continue
		# random taps anywhere, avoiding nothing
		for i in 12:
			var p := Vector2(rng.randf() * vs.x, rng.randf() * vs.y)
			# but not on a button that leaves the menus
			var risky := false
			for b in buttons():
				if screen_rect(b).has_point(p):
					var t: String = (b as Button).text if b is Button else ""
					if t.contains("EXIT") or String(b.name) == "Menu_exit" or t.contains("START") or t.contains("PLAY") or t.contains("HOST") or t.contains("JOIN") or t.contains("DOWNLOAD") or t.contains("CONTINUE") or t.contains("RESET") or t.contains("REDEFIN") or t.contains("DELETE") or t.contains("WATCH"):
						risky = true
			if risky:
				continue
			var hit := ""
			for b in buttons():
				if screen_rect(b).has_point(p):
					hit = String((b as Button).text if b is Button else b.name)
			print("PT TAP %s on '%s'" % [str(p.round()), hit])
			await tap_at(p)
			await frames(3)
			if i == 5:
				await key_tap(KEY_ESCAPE)
		# (resizing the window was tried: the virtual screen has no window manager and ignores it; other sizes are
		# separate runs with --resolution instead)
		await look("confused_%s" % id)
		check_errors("confused_" + id)
	await to_menu("confused end")
