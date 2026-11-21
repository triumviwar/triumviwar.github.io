extends "res://tools/playtest/pt_base.gd"
## REPLAYS played from the main menu: rec:<full|mixed|light> picked on the Settings page (REPLAY RECORDING), a short
## skirmish played (you v an Easy computer, the match sped up), left by the match menu; then REPLAYS: the list, WATCH,
## pause / play, every speed, a seek by dragging the bar (back and forward), FOG and CAMERA, the HUD's VIEW menu, the
## match menu inside a replay, QUIT; KEEP, DELETE (twice), and a broken / cut replay file and an empty one in the list.
## (see pt_base.gd for the command line)

var rec := "full"


func play() -> void:
	rec = String(args.get("rec", "full"))
	await set_recording(rec)
	await press_button("Menu_skirmish")
	await wait(0.8)
	await shot("lobby")
	print("PT OFFSCREEN ", off_screen())
	var st := button("START")
	if not expect(st != null, "the skirmish lobby has START"):
		return
	await press(st)
	await wait(6.0)
	var g := game()
	if not expect(g != null, "a skirmish started"):
		return
	note("match: %s, me %s v %s; replay mode %s" % [g.map_id, g.factions[g.human], str(g.factions), Settings.replay_mode()])
	# play a little: select everything of mine on screen and send it somewhere, train a worker
	Engine.time_scale = 4.0
	await wait(25.0)          # (~100 s of game time)
	Engine.time_scale = 1.0
	await shot("match_100s")
	await press_match_menu("QUIT TO MENU")
	await wait(2.0)
	note("after quitting: screen %s; last replay %s" % [str(button_names()).substr(0, 160), main.last_replay])
	await press_button("Menu_replays")
	await wait(0.8)
	await shot("replays_list")
	print("PT OFFSCREEN ", off_screen())
	var rows := ReplayFile.list()
	note("replays listed: %d; newest %s" % [rows.size(), str(rows[0]).substr(0, 300) if not rows.is_empty() else "-"])
	await press_button("WATCH")
	await wait(4.0)
	g = game()
	if not expect(g != null and g.replay != null, "the replay plays"):
		await shot("watch_failed")
		return
	await shot("replay_start")
	print("PT OFFSCREEN ", off_screen())
	var pl = g.replay
	note("player: length %.1f start %.1f playing %s speed %s" % [pl.length, pl.start_t, pl.playing, pl.speed])
	# pause / play
	await press(play_button())
	await wait(1.0)
	var t1: float = pl.play_t
	await wait(1.5)
	expect(absf(pl.play_t - t1) < 0.05, "paused: the clock stands (%.2f -> %.2f)" % [t1, pl.play_t])
	await shot("replay_paused")
	await press(play_button())
	# speeds
	for sp in ["½x", "2x", "4x", "8x", "1x"]:
		var b := button(sp)
		if b == null:
			note("no speed button %s (have %s)" % [sp, str(button_names()).substr(0, 300)])
			continue
		await press(b)
		var a: float = pl.play_t
		await wait(2.0)
		note("speed %s: %.2f s of replay in 2 s real" % [sp, pl.play_t - a])
	# seek: drag the slider's grabber to 80 %, then back to 10 %
	var sl: HSlider = null
	for c in root.find_children("*", "HSlider", true, false):
		if (c as Control).is_visible_in_tree():
			sl = c
	if sl:
		var r := sl.get_global_rect()
		var cur := r.position + Vector2(r.size.x * inverse_lerp(sl.min_value, sl.max_value, sl.value), r.size.y * 0.5)
		if phone:
			await touch_drag(cur, r.position + Vector2(r.size.x * 0.8, r.size.y * 0.5))
		else:
			await drag(cur, r.position + Vector2(r.size.x * 0.8, r.size.y * 0.5))
		await wait(1.5)
		note("dragged the bar to 80%%: play_t %.1f of %.1f" % [pl.play_t, pl.length])
		await shot("replay_seek80")
		await press_at(r.position + Vector2(r.size.x * 0.1, r.size.y * 0.5))
		await wait(1.5)
		note("clicked the bar at 10%%: play_t %.1f" % pl.play_t)
		await shot("replay_seek10")
	else:
		find("no replay slider on screen")
	# Home / keys (computer)
	if not phone:
		await key(KEY_SPACE)
		await wait(0.5)
		note("Space: playing %s" % pl.playing)
		await key(KEY_SPACE)
		await key(KEY_EQUAL)
		note("= : speed %s" % pl.speed)
		await key(KEY_HOME)
		await wait(0.5)
		note("Home: play_t %.1f" % pl.play_t)
	# fog and camera
	for i in 3:
		var fb := button("FOG")
		if fb:
			await press(fb)
			await wait(0.8)
			note("FOG button now '%s'" % (fb as Button).text)
	await shot("replay_fog")
	for i in 3:
		var cb := button("CAMERA")
		if cb:
			await press(cb)
			await wait(0.8)
			note("CAMERA button now '%s'" % (cb as Button).text)
	await shot("replay_camera")
	# the HUD's VIEW / PRODUCTION / ARMY panels (spectator)
	var h := hud()
	if h.has_method("view_rect"):
		await press_at(hud_rect(h.view_rect()).get_center())
		await wait(0.6)
		await shot("replay_view_menu")
		note("VIEW open: %s" % h.view_open)
		await press_at(hud_rect(h.view_rect()).get_center())
	if h.has_method("spec_panels"):
		note("spec panels rect %s" % str(h.spec_panels()))
	# play to the end at 8x
	var b8 := button("8x")
	if b8:
		await press(b8)
	var tw := 0.0
	while tw < 60.0 and not pl.at_end:
		await wait(1.0)
		tw += 1.0
	note("at the end: %s after %.0f s; note: %s" % [pl.at_end, tw, str(texts_on_screen().filter(func(t: String) -> bool: return t.contains("end") or t.contains("wins") or t.contains("winner")))])
	await shot("replay_end")
	await press_button("QUIT")
	await wait(1.5)
	await shot("after_replay_quit")
	note("after QUIT: screen %s" % str(button_names()).substr(0, 200))
	# KEEP, DELETE
	if button("KEEP"):
		await press_button("KEEP")
		await wait(0.4)
		note("after KEEP: kept %s" % str(ReplayFile.list().map(func(m: Dictionary) -> bool: return bool(m.get("kept", false)))))
	var n0 := ReplayFile.list().size()
	await press_button("DELETE")
	await wait(0.3)
	note("one DELETE: %d -> %d" % [n0, ReplayFile.list().size()])
	await press_button("SURE?")
	await wait(0.3)
	note("SURE?: %d -> %d" % [n0, ReplayFile.list().size()])
	# broken files: garbage, empty, cut in half
	ReplayFile.ensure_dir()
	var f := FileAccess.open(ReplayFile.DIR + "/replay_garbage.hfr", FileAccess.WRITE)
	f.store_string("this is not a replay at all ".repeat(50))
	f.close()
	f = FileAccess.open(ReplayFile.DIR + "/replay_empty.hfr", FileAccess.WRITE)
	f.close()
	var real := ReplayFile.list()
	if not real.is_empty():
		var bytes := FileAccess.get_file_as_bytes(String(real[0]["path"]))
		f = FileAccess.open(ReplayFile.DIR + "/replay_cut.hfr", FileAccess.WRITE)
		f.store_buffer(bytes.slice(0, bytes.size() / 2))
		f.close()
	await press_button("BACK")
	await press_button("Menu_replays")
	await wait(0.8)
	await shot("replays_with_broken")
	var listed: Array = []
	for m in ReplayFile.list():
		listed.append("%s:%s:%s" % [String(m["path"]).get_file(), String(m.get("result", "")), str(m.get("len", ""))])
	note("listed with broken files: %d: %s" % [listed.size(), str(listed)])
	# watch each one, newest first
	for i in mini(4, ReplayFile.list().size()):
		var ws := buttons().filter(func(b: BaseButton) -> bool: return b is Button and (b as Button).text == "WATCH")
		if i >= ws.size():
			break
		await press(ws[i])
		await wait(4.0)
		var gg := game()
		note("WATCH #%d: game %s replay %s; note: %s" % [i, gg != null, gg != null and gg.replay != null, str(texts_on_screen().filter(func(t: String) -> bool: return t.contains("an't") or t.contains("version") or t.contains("broken"))).substr(0, 300)])
		await shot("watch_%d" % i)
		if gg:
			var q := button("QUIT")
			if q:
				await press(q)
				await wait(1.5)


func set_recording(mode: String) -> void:
	await press_button("Menu_settings")
	await wait(0.5)
	for tab in main.SETTINGS_TABS:
		var row: Control = null
		for c in root.find_children("*", "Control", true, false):
			if c.has_meta("setting") and String(c.get_meta("setting")) == "replay_rec" and (c as Control).is_visible_in_tree():
				row = c
		if row:
			for i in 4:
				var b := buttons(row)
				if b.is_empty():
					break
				var t := String((b[0] as Button).text).to_lower()
				if t == mode or t == Loc.t(mode.to_upper()).to_lower():
					break
				await press(b[0])
				await wait(0.3)
				row = null
				for c in root.find_children("*", "Control", true, false):
					if c.has_meta("setting") and String(c.get_meta("setting")) == "replay_rec" and (c as Control).is_visible_in_tree():
						row = c
				if row == null:
					break
			note("REPLAY RECORDING set: %s (on tab %s)" % [Settings.replay_mode(), tab])
			await shot("settings_replay_rec")
			break
		var tb := button(Loc.t(tab))
		if tb:
			await press(tb)
			await wait(0.3)
	await press_button("BACK")
	await wait(0.4)


func play_button() -> Button:
	for c in root.find_children("*", "Control", true, false):
		if c.get_script() == preload("res://scripts/ui/replay_bar.gd"):
			return c._play
	find("no replay bar")
	return null
