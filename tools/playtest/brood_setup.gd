extends SceneTree
## Playtest (job playtest-skirmish-brood): the SKIRMISH SETUP as a person clicks it, from a first start (the device
## page) to START, with every option on the setup screen tried on the way. Pictures in
## docs/shots/playtest_2026_11_21/skirmish_brood/.
##   xvfb-run -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 --script res://tools/playtest/brood_setup.gd
##     [-- pc|mobile lang=en|pt|es]
const Lib := preload("res://tools/playtest/brood_pt_lib.gd")
var pt
var main: Node
var device := "pc"
var lang := "en"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a in ["pc", "mobile"]:
			device = a
		elif a.begins_with("lang="):
			lang = a.substr(5)
	# a first start: no settings file
	var cfg := ProjectSettings.globalize_path("user://settings.cfg")
	if FileAccess.file_exists("user://settings.cfg"):
		DirAccess.remove_absolute(cfg)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	pt = Lib.new(self)
	pt.tag = "setup_%s_%s" % [device, lang]
	_run.call_deferred()


func _dropdowns() -> Array:
	var out: Array = []
	for b in pt.all_buttons(main.menu):
		if b is Button and String((b as Button).text).ends_with("▼"):
			out.append(b)
	return out


func _pick(dd: Button, item: String) -> bool:
	await pt.click_control(dd)
	await pt.frames(3)
	# the list is the newest child of the ui layer
	var shade: Node = main.ui_layer.get_child(main.ui_layer.get_child_count() - 1)
	var ok: bool = await pt.click_text(item, false, shade)
	await pt.frames(3)
	return ok


func _run() -> void:
	await pt.frames(10)
	pt.touch_mode = false
	await pt.shot("device_page")
	if lang != "en":
		# the language flags in the corner (their tooltips name the language)
		for b in pt.all_buttons(main.menu):
			if String(b.tooltip_text) == Loc.NATIVE[lang]:
				await pt.click_control(b)
				break
		await pt.frames(5)
		pt.note("language now %s" % Settings.language)
	await pt.click_text("MOBILE" if device == "mobile" else "COMPUTER")
	await pt.frames(10)
	pt.touch_mode = device == "mobile"
	await pt.shot("main_menu")
	pt.note("menu buttons: %s" % ", ".join(pt.button_texts(main.menu)))
	if not await pt.click_text({"en": "SKIRMISH", "pt": "ESCARAMUÇA", "es": "ESCARAMUZA"}[lang]):
		quit(1)
		return
	await pt.frames(10)
	await pt.shot("lobby_first")
	# every preset
	for p in ["2v2", "3v3", "4v4", "1v2", "1v3", "FFA", "1v1"]:
		await pt.click_text(p, true)
		await pt.frames(6)
		if p in ["4v4", "FFA"]:
			await pt.shot("lobby_" + p)
	# slot 0: YOU, the Brood
	var dds := _dropdowns()
	pt.note("dropdowns: %s" % ", ".join(dds.map(func(b: Button) -> String: return b.text)))
	await _pick(dds[1], Defs.faction_label("brood").to_upper())
	dds = _dropdowns()
	# slot 1: Hard Crown, OPTIMAL plan
	var row1: Array = dds.filter(func(b: Button) -> bool: return b.get_global_rect().position.y > dds[0].get_global_rect().position.y + 20)
	await _pick(row1[0], "HARD AI")
	dds = _dropdowns()
	row1 = dds.filter(func(b: Button) -> bool: return b.get_global_rect().position.y > dds[0].get_global_rect().position.y + 20)
	await _pick(row1[1], Defs.faction_label("crown").to_upper())
	dds = _dropdowns()
	row1 = dds.filter(func(b: Button) -> bool: return b.get_global_rect().position.y > dds[0].get_global_rect().position.y + 20)
	await _pick(row1[3], "OPTIMAL")
	await pt.shot("lobby_brood_v_crown")
	# colour list, team list opened and closed by a click outside
	dds = _dropdowns()
	await pt.click_control(dds[2])
	await pt.frames(3)
	await pt.shot("colour_list")
	await pt.click(Vector2(5, 5))
	await pt.frames(3)
	# the map: step through every map with > and look at a few
	var n := 0
	for i in 40:
		await pt.click_text(">", true)
		await pt.frames(3)
		n += 1
	pt.note("stepped %d maps; now %d players, sides %s" % [n, main.lobby["slots"].size(), str(main.lobby["slots"].map(func(x): return x["side"]))])
	await pt.shot("lobby_after_maps")
	await pt.click_text("1v1", true)
	await pt.frames(6)
	# the map list
	dds = _dropdowns()
	var mapdd: Button = null
	for b in dds:
		if b.get_global_rect().position.x > pt.vsize().x * 0.6:
			mapdd = b
	if mapdd:
		await pt.click_control(mapdd)
		await pt.frames(5)
		await pt.shot("map_list")
		var shade: Node = main.ui_layer.get_child(main.ui_layer.get_child_count() - 1)
		await pt.click_text("HOLLOWFEN", false, shade)
		await pt.frames(5)
	await pt.shot("lobby_ready")
	pt.note("lobby: %s" % JSON.stringify(main.lobby))
	if main.lobby["slots"].size() != 2 or main.lobby["slots"][1]["faction"] != "crown":
		pt.note("FINDING: the setup is not the one picked")
	await pt.click_text({"en": "START", "pt": "INICIAR", "es": "EMPEZAR"}.get(lang, "START"))
	await pt.secs(4.0)
	await pt.shot("match_start")
	pt.note("game: %s" % str(main.game))
	quit(0)
