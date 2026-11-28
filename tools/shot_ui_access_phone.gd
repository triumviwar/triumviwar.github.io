extends SceneTree
## Pictures for job ui-access-phone (docs/ui_access_phone.md, docs/shots/ui_access_phone/): the Settings page's
## ACCESSIBILITY rows, the skirmish lobby with 8 colours, a match (an army of mixed health selected, the hall's card,
## the minimap) and the world war map, in one colour-blind mode and text size a run. A picture tool, not a test.
## Leaves user://settings.cfg as it was.
##   xvfb-run -a -s "-screen 0 2400x1080x24" godot --rendering-driver opengl3 --resolution 1600x720 \
##       --script res://tools/shot_ui_access_phone.gd -- <outdir> <pc|mobile> <cb 0-2> <text 90-150> [tag] [dpi] [lang]
## (a phone: the window 1600 x 720 for a 2400 x 1080 phone, dpi 400 x 720/1080 = 267 for its 6.5")
var main
var out := ""
var dev := "pc"
var tag := ""
var _kept := ""


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	out = a[0]
	dev = a[1]
	if FileAccess.file_exists(Settings.PATH):
		_kept = FileAccess.get_file_as_string(Settings.PATH)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	Settings.load_all()
	Settings.device = dev
	Settings.set_language(a[6] if a.size() > 6 else "en")
	Settings.cb_mode = int(a[2])
	Settings.text_size = int(a[3])
	tag = a[4] if a.size() > 4 else ""
	if a.size() > 5 and float(a[5]) > 0.0:
		Settings.test_dpi = float(a[5])
	ColourAccess.changed()
	Settings.apply()
	DirAccess.make_dir_recursive_absolute(out)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _snap(name: String, wait := 0.6) -> void:
	await create_timer(wait).timeout
	await process_frame
	await process_frame
	var nm := "%s/%s_%s%s.jpg" % [out, dev, name, ("_" + tag) if tag != "" else ""]
	root.get_viewport().get_texture().get_image().save_jpg(nm, 0.85)
	print("shot ", nm)


func _run() -> void:
	await create_timer(0.8).timeout
	main.show_settings("DISPLAY")
	await _snap("settings")
	main._preset("4v4")
	main.lobby["map"] = main._preset_pool("4v4")
	for i in (main.lobby["slots"] as Array).size():
		main.lobby["slots"][i]["colour"] = i % Defs.PALETTE.size()
	main.show_skirmish()
	await _snap("lobby")
	await _match()
	await _world_war()
	if _kept != "":
		var f := FileAccess.open(Settings.PATH, FileAccess.WRITE)
		f.store_string(_kept)
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Settings.PATH))
	quit()


func _match() -> void:
	main.start({"map": "greenhold", "seed": 7, "slots": [
		{"who": "you", "faction": "crown", "colour": 0, "side": 0},
		{"who": "easy", "faction": "brood", "colour": 1, "side": 1},
		{"who": "easy", "faction": "clockwork", "colour": 2, "side": 1},
		{"who": "easy", "faction": "crown", "colour": 3, "side": 0}]})
	await process_frame
	await process_frame
	var g: Game = main.game
	g.hud.countdown = 0.0
	paused = false
	for ai in g.ais:
		ai.process_mode = Node.PROCESS_MODE_DISABLED
	g.players[0]["gold"] = 6400
	var hall = g.halls_of(0)[0]
	var at: Vector2 = hall.center() + Vector2(380, 180)
	var army: Array = []
	var kinds := ["musketeer", "musketeer", "musketeer", "musketeer", "cuirassier", "dragoon", "cannon", "musketeer"]
	for i in 16:
		var u = g._add_unit(kinds[i % kinds.size()], 0, at + Vector2((i % 8) * 34, (i / 8) * 34))
		if u:
			u.hp = u.max_hp * [1.0, 0.7, 0.4, 0.2, 0.12, 0.9, 0.3, 0.55][i % 8]
			army.append(u)
	# a foe of every other colour beside them, hurt, so the team colours and the bars show side by side
	var foes := [[1, "raptor"], [2, "clock_soldier"], [3, "musketeer"], [1, "spitter"], [2, "clock_soldier"], [3, "cuirassier"]]
	for j in foes.size():
		var f = g._add_unit(foes[j][1], int(foes[j][0]), at + Vector2(j * 40, 120))
		if f:
			f.hp = f.max_hp * [0.8, 0.45, 0.2][j % 3]
			f.process_mode = Node.PROCESS_MODE_DISABLED
	await create_timer(1.2).timeout
	g.camera.position = at + Vector2(130, 70)
	g.set_selection(army)
	await _snap("army")
	g.camera.position = hall.center() + Vector2(160, 40)
	g.set_selection([hall])
	await _snap("hall")
	var bar = g.hud._card_bar
	if bar is Rect2 and (bar as Rect2).size.x > 0.0 and dev == "mobile":
		g.hud._card_scroll = g.hud._rows()
		g.hud._card_fresh = true
		await _snap("hall_page2")


## THE WORLD WAR some years on (every side the computer): the territory in the factions' colours.
func _world_war() -> void:
	main._quit_match()
	var w := WWWar.make({"players": {"crown": "normal", "clockwork": "normal", "brood": "normal"}, "seed": 4, "name": "shot_access"})
	for i in 30:
		WWAI.play_turn(w)
		w.end_turn()
		if String(w.d["winner"]) != "":
			break
	var p := WWPage.show_war(main, w, " ")
	await process_frame
	p._close_overlay()
	p.map.show_rect(p.map.world_rect())
	await _snap("world_war", 1.0)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://worldwar/shot_access.json"))
