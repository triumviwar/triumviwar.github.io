extends SceneTree
## Job ui-access-phone (docs/ui_access_phone.md): COLOUR-BLIND HELP, TEXT SIZE, the phone's bigger card and portraits.
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1600x720 --fixed-fps 30 --script res://tools/test_ui_access_phone.gd | grep -E "FAIL|PASS|DONE"
##  - OFF shows Defs.PALETTE as it was; RED-GREEN / BLUE-YELLOW show 8 different colours with their own names,
##    in Game.team_colour, Defs.colour_of and the units' cloth; the health bar's colours; the war map's holders
##  - the settings are kept in the file and RESET puts them back
##  - TEXT SIZE: a Label made at 20 shows at 30 at 150% and back at 20 at 100%; a node marked no_text_scale keeps 20
##  - a computer's HUD is as it was (4 x 3 card of 60, portraits 34); a phone held sideways: the card's buttons at
##    least 9 mm (a 68 mm short side), 2 rows and page tabs that change the page, portraits PHONE_SEL in one row
var fails := 0
var _kept := ""


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	Settings.load_all()
	if FileAccess.file_exists(Settings.PATH):
		_kept = FileAccess.get_file_as_string(Settings.PATH)
	var cb0 := Settings.cb_mode
	var ts0 := Settings.text_size
	# --- colours
	Settings.cb_mode = 0
	ColourAccess.changed()
	for i in Defs.PALETTE.size():
		check(ColourAccess.team(i) == Defs.PALETTE[i][1] and ColourAccess.team_name(i) == Defs.PALETTE[i][0], "OFF: slot %d as the game's own" % i)
	check(ColourAccess.hp(0.9) == Color(0.3, 0.9, 0.3, 1.0), "OFF: the health bar green as before")
	for m in [1, 2]:
		Settings.cb_mode = m
		ColourAccess.changed()
		var seen := {}
		var names := {}
		for i in Defs.PALETTE.size():
			seen[ColourAccess.team(i).to_html()] = true
			names[ColourAccess.team_name(i)] = true
			check(Defs.colour_of(i) == ColourAccess.team(i) and Defs.colour_name(i) == ColourAccess.team_name(i), "mode %d: Defs shows slot %d's shown colour and name" % [m, i])
		check(seen.size() == 8 and names.size() == 8, "mode %d: 8 different colours and names" % m)
		check(ColourAccess.hp(0.9) != Color(0.3, 0.9, 0.3, 1.0) and ColourAccess.hp(0.9) != ColourAccess.hp(0.1), "mode %d: the health bar's colours changed" % m)
	Settings.cb_mode = 1
	ColourAccess.changed()
	var mach := ColourAccess.holder("machine", Color(0.74, 0.16, 0.10, 0.42))
	check(mach.h > 0.05 and mach.h < 0.15 and is_equal_approx(mach.a, 0.42), "RED-GREEN: the machine's territory orange, its see-through kept")
	check(ColourAccess.faction("brood", WWRules.COLOUR["brood"]).b > 0.7, "RED-GREEN: the Brood sky blue on the world map")
	Settings.cb_mode = 2
	check(ColourAccess.faction("brood", WWRules.COLOUR["brood"]) == WWRules.COLOUR["brood"], "BLUE-YELLOW: the factions' map colours as they were")
	# --- the file
	Settings.cb_mode = 2
	Settings.text_size = 130
	Settings.save_all()
	Settings.cb_mode = 0
	Settings.text_size = 100
	Settings._loaded = false
	Settings.load_all()
	check(Settings.cb_mode == 2 and Settings.text_size == 130, "kept in the settings file")
	Settings.reset()
	check(Settings.cb_mode == 0 and Settings.text_size == 100, "RESET puts them back")
	# --- text size
	TextScale.install()
	Settings.text_size = 150
	var host := Control.new()
	root.add_child(host)
	var l := UiStyle.text("A", 20)
	var keep := UiStyle.text("B", 20)
	keep.set_meta(TextScale.SKIP, true)
	host.add_child(l)
	host.add_child(keep)
	await process_frame
	await process_frame
	check(l.get_theme_font_size("font_size") == 30, "TEXT SIZE 150%%: a 20 label at 30 (%d)" % l.get_theme_font_size("font_size"))
	check(keep.get_theme_font_size("font_size") == 20, "no_text_scale keeps its size")
	Settings.text_size = 100
	TextScale.apply_all()
	check(l.get_theme_font_size("font_size") == 20, "back to 100%%: 20 again (%d)" % l.get_theme_font_size("font_size"))
	check(TextScale.hud(14) == 14, "100%: the HUD's words as they were")
	Settings.text_size = 150
	check(TextScale.hud(10) == 13, "150%%: the HUD's words grow by its share (10 -> %d)" % TextScale.hud(10))
	Settings.text_size = 100
	host.queue_free()
	# --- the HUD: a computer, then a phone held sideways
	Settings.cb_mode = 0
	ColourAccess.changed()
	await _hud_checks("pc")
	await _hud_checks("mobile")
	Settings.cb_mode = cb0
	Settings.text_size = ts0
	if _kept != "":
		var f := FileAccess.open(Settings.PATH, FileAccess.WRITE)
		f.store_string(_kept)
	print("DONE  %d fail(s)" % fails)
	quit(1 if fails > 0 else 0)


func _hud_checks(dev: String) -> void:
	Settings.device = dev
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.start({"map": "greenhold", "seed": 5, "slots": [
		{"who": "you", "faction": "crown", "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "hard", "faction": "brood", "colour": 1, "side": 1, "strategy": "balanced"}]})
	await process_frame
	await process_frame
	var g: Game = main.game
	var hud = g.hud
	hud.countdown = 0.0
	paused = false
	for ai in g.ais:
		ai.process_mode = Node.PROCESS_MODE_DISABLED
	hud._fit()
	if dev == "pc":
		check(hud._rows() == 3 and hud._cols() == 4 and is_equal_approx(hud._btn(), hud.CARD_BTN_PC), "computer: the 4 x 3 card of 60 as it was")
		check(is_equal_approx(hud._sel_size(), 34.0) and hud._sel_vis() == 2, "computer: portraits 34, two rows, as they were")
	else:
		var vs: Vector2 = hud._vs()
		var mm: float = vs.y / hud.PHONE_SHORT_MM
		check(hud._btn() >= 9.0 * mm - 0.01, "phone: the card's buttons at least 9 mm (%.1f HUD units, 9 mm = %.1f)" % [hud._btn(), 9.0 * mm])
		check(hud._rows() == 2, "phone: two rows a page")
		var cr: Rect2 = hud.card_rect()
		check(Rect2(Vector2.ZERO, vs).encloses(cr), "phone: the card fits the screen (%s in %s)" % [cr, vs])
		check(cr.size.y < vs.y * 0.4, "phone: the card under 40% of the height")
		check(hud._sel_size() >= 60.0 and hud._sel_vis() == 1, "phone: portraits %d, one row" % int(hud._sel_size()))
		# a Labourer's card has more than 8 commands: pages
		var lab = null
		for w in g.workers(0):
			lab = w
			break
		g.set_selection([lab])
		hud._refresh_card()
		check(hud._card_pages() >= 2, "phone: a Labourer's card has %d pages" % hud._card_pages())
		if hud._card_pages() >= 2:
			var bar: Rect2 = hud._card_bar
			check(bar.size.x >= hud.PAGE_TAB_W - 4.0 and cr.encloses(bar), "phone: the page tabs inside the card")
			var p2: Vector2 = bar.position + Vector2(bar.size.x * 0.5, bar.size.y * 0.75)
			hud._card_press(p2)
			hud._card_release(p2)
			check(hud._card_page() == 1 and hud._card_scroll == hud._rows(), "phone: the second tab shows the second page")
			hud._refresh_card()
			check(hud._card_buttons.size() > 0, "phone: page 2 has buttons")
		var army: Array = []
		for i in 12:
			army.append(g._add_unit("musketeer", 0, g.halls_of(0)[0].center() + Vector2(i * 20, 200)))
		g.set_selection(army)
		await process_frame
		hud.queue_redraw()
		await process_frame
		var ok := true
		for pt in hud._portraits:
			if (pt["rect"] as Rect2).size.x < 60.0 or not hud.panel_rect().encloses(pt["rect"]):
				ok = false
		check(ok and not hud._portraits.is_empty(), "phone: %d portraits, each %d wide, inside the panel" % [hud._portraits.size(), int(hud._sel_size())])
	main.queue_free()
	await process_frame
