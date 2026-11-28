extends "res://tools/playtest/pt_base.gd"
## PLAYTEST, settings kept between runs and settings files that are broken (job playtest-menus-online).
## Each case is its own run of the game (Settings loads once a run), all with raw_settings and their own user folder:
##   PT_HOME=<dir> tools/playtest/run.sh pt_settings_file 1280x720 raw_settings case:set      (change by clicks, EXIT)
##   PT_HOME=<dir> tools/playtest/run.sh pt_settings_file 1280x720 raw_settings case:check    (are they back?)
##   PT_HOME=<dir> tools/playtest/run.sh pt_settings_file 1280x720 raw_settings case:bad_<n>  (a broken file first)
## (raw_settings: the base leaves settings.cfg as it is, the game reads it itself.)

const BAD := {
	"bad_garbage": "\u0000\u0001PK\u0003\u0004 not a config file at all ]]][[[ ÿþ",
	"bad_empty": "",
	"bad_types": "[input]\ndevice=5\ndrag_mode=true\nui_size=\"big\"\nfullscreen=\"yes\"\ngrid_keys=\"x\"\ntooltips=3\nbuild_grid=[1, 2]\nmini_alpha=\"half\"\n\n[ui]\nlanguage=12\narea_marks=\"no\"\npowder_smoke=\"thick\"\nhealth_bars=9\nband_marks=-4\noverlay_alpha=\"x\"\nreplays_keep=\"all\"\nreplay_rec=3\nnarrator=\"y\"\nnarrator_volume=\"loud\"\nnarrator_rate=\"fast\"\n\n[online]\nrelay_url=7\nladder_url=[1]\nranked_dev_id=1.5\n\n[display]\nfullscreen=\"maybe\"\n",
	"bad_old": "[input]\ndevice=\"pc\"\n\n[ui]\nground_system=true\nground_nocap=true\ncw_lab=true\nlanguage=\"pt\"\n",
	"bad_values": "[input]\ndevice=\"tablet\"\ndrag_mode=\"sideways\"\nui_size=999\n\n[ui]\nlanguage=\"xx\"\nreplays_keep=-5\noverlay_alpha=40.0\n",
	"bad_half": "[input]\ndevice=\"pc\"\ndrag_mode=\"bo",
	"bad_audio": "[input]\ndevice=\"pc\"\n\n[audio]\nmusic=\"loud\"\nsound=-3\nmute_music=\"y\"\n",
}


func play() -> void:
	var c := String(args.get("case", "set"))
	if BAD.has(c):
		var f := FileAccess.open(Settings.PATH, FileAccess.WRITE)
		f.store_string(BAD[c])
		f.close()
	await start_main()
	await look("start_" + c)
	print("PT %s device='%s' lang='%s' relay='%s' ui_size=%s menu=%s" % [c, Settings.device, Settings.language, Settings.relay_url, str(Settings.ui_size), menu_up()])
	check_errors(c)
	match c:
		"set":
			await set_by_clicks()
		"check":
			check_back()
		_:
			# with a broken file the game must still be usable: the device page or the menu, and Settings opens
			if Settings.device == "":
				await press("COMPUTER")
			if not menu_up():
				find("BUG", c, "no main menu after the start (buttons: %s)" % str(button_texts()).substr(0, 200))
				return
			await tap(main.menu_open("settings"))
			await wait(0.4)
			await look("settings_" + c)
			if find_button("BACK") == null:
				find("BUG", c, "Settings did not open")
			check_errors(c)


func menu_up() -> bool:
	return main != null and main.on_menu()      # (any level: menu-groups)


func row_button(id: String) -> BaseButton:
	for c in all_controls():
		if (c as Control).has_meta("setting") and String((c as Control).get_meta("setting")) == id:
			for b in c.find_children("*", "BaseButton", true, false):
				return b
	return null


func row_slider(id: String) -> HSlider:
	for c in all_controls():
		if (c as Control).has_meta("setting") and String((c as Control).get_meta("setting")) == id:
			for b in c.find_children("*", "HSlider", true, false):
				return b
	return null


func tab(t: String) -> void:
	for c in all_controls():
		if String(c.name) == "Tab_" + t:
			await tap(c)
			await wait(0.3)
			return


## The choices a player makes: Portuguese, GRID keys, tooltips off, REPLAYS KEPT 50, overlay 90%, band marks OFF,
## expansion spots off, gear turn off, narrator speed 1.6; then EXIT (the real button).
func set_by_clicks() -> void:
	if Settings.device == "":
		await press("COMPUTER")
	await tap(main.menu_open("settings"))
	await wait(0.4)
	await tap(row_button("grid_keys"))
	await wait(0.2)
	await tap(row_button("tooltips"))
	await wait(0.2)
	await tap(row_button("replays_keep"))      # 30 -> 50
	await wait(0.3)
	await tab("DISPLAY")
	await drag_slider(row_slider("overlay_alpha"), (0.9 - 0.3) / 0.7)
	await tap(row_button("band_marks"))        # SELECTED -> OFF
	await wait(0.3)
	await tap(row_button("expansion_spots"))
	await wait(0.2)
	await tab("EXPERIMENTAL")
	await tap(row_button("gear_turn"))
	await wait(0.2)
	await tab("SOUND")
	if row_slider("music") != null:
		await drag_slider(row_slider("music"), 0.3)
	await tap(row_button("narrator_rate"))     # 1.1 -> 1.3
	await wait(0.3)
	await tap(row_button("narrator_rate"))     # -> 1.6
	await wait(0.3)
	await tab("GAMEPLAY")
	# the Portuguese flag in the LANGUAGE row
	for b in buttons():
		if b.tooltip_text == Loc.NATIVE["pt"]:
			await tap(b)
			break
	await wait(0.4)
	await look("set_done")
	print("PT SET grid=%s tips=%s keep=%d overlay=%.2f band=%d spots=%s gear=%s rate=%.1f lang=%s music=%.2f" % [Settings.grid_keys, Settings.tooltips, Settings.replays_keep, Settings.overlay_alpha, Settings.band_marks, Settings.expansion_spots, Settings.gear_turn, Settings.narrator_rate, Settings.language, Music.me.get_volume("music")])
	# EXIT, as a player leaves: BACK to the menu, then EXIT
	await key_tap(KEY_ESCAPE)
	await wait(0.4)
	if not menu_up():
		find("BUG", "set", "Esc did not bring the menu back")
	if main.menu_open("exit") != null:
		print("PT PRESS EXIT")
		await tap(main.menu_open("exit"))
		await wait(1.0)
		find("BUG", "set", "EXIT did not close the game")
	else:
		find("BUG", "set", "no EXIT button")


func check_back() -> void:
	var want := {"grid": true, "tips": false, "keep": 50, "band": 2, "spots": false, "gear": false, "lang": "pt"}
	var got := {"grid": Settings.grid_keys, "tips": Settings.tooltips, "keep": Settings.replays_keep, "band": Settings.band_marks, "spots": Settings.expansion_spots, "gear": Settings.gear_turn, "lang": Settings.language}
	for k in want:
		if str(want[k]) != str(got[k]):
			find("BUG", "check", "after a restart %s is %s, set to %s" % [k, str(got[k]), str(want[k])])
	if absf(Settings.overlay_alpha - 0.9) > 0.051:
		find("BUG", "check", "overlay opacity %.2f after the restart, set to 0.90" % Settings.overlay_alpha)
	if absf(Settings.narrator_rate - 1.6) > 0.01:
		find("BUG", "check", "narrator speed %.1f after the restart, set to 1.6" % Settings.narrator_rate)
	if absf(Music.me.get_volume("music") - 0.3) > 0.06:
		find("BUG", "check", "music volume %.2f after the restart, set to 0.30" % Music.me.get_volume("music"))
	var mb: Button = main.menu_open("settings")
	if mb != null and not mb.atr(mb.text).to_upper().begins_with("CONFIGURA"):
		find("BUG", "check", "the menu is not in Portuguese after the restart")
	print("PT CHECK done ", got)
	if find_button("COPY REPORT") != null:
		find("BUG", "check", "the crash page came up after a normal EXIT")
