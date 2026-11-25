extends SceneTree
## Pictures of TOURNAMENTS (docs/tournament.md, docs/shots/tournament/), and a walk through its pages pressing its
## buttons: the main menu's button, the list, MAKE A TOURNAMENT, an ALL COMPUTER double elimination of 16 half played
## (bracket, a match's card, standings, schedule, players, rules), the champion, a groups tournament, a Swiss one, an
## online one at sign-up and a match card with bans to make. Uses a scratch user folder of its own tournaments only
## (they are deleted after).
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_tournament.gd -- <outdir> [pc|mobile] [pt|es]
var main
var out := ""
var sfx := ""
var made: Array = []
var fails := 0


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	out = a[0]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	Settings.load_all()
	Settings.device = a[1] if a.size() > 1 else "pc"
	sfx = "" if Settings.device == "pc" else "_phone"
	if a.size() > 2:
		Settings.set_language(a[2])        # (a third word: the language, "pt" or "es")
		sfx += "_" + a[2]
	else:
		Settings.set_language("en")
	Settings.apply()
	DirAccess.make_dir_recursive_absolute(out)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _snap(name: String, wait := 0.5) -> void:
	await create_timer(wait).timeout
	await process_frame
	await process_frame
	root.get_viewport().get_texture().get_image().save_png("%s/%s%s.png" % [out, name, sfx])
	print("shot ", name)


func _press(name: String) -> bool:
	var b: Node = main.ui_layer.find_child(name, true, false)
	if b == null or not (b is BaseButton):
		print("FAIL no button ", name)
		fails += 1
		return false
	(b as BaseButton).pressed.emit()
	return true


func _page() -> TournamentPage:
	return main.ui_layer.find_child("TournamentPage", true, false)


func _keep(t: Tournament) -> Tournament:
	t.save()
	made.append(String(t.d["id"]))
	return t


## Play `n` games of the ready matches (side a wins 2 in 3, by the tournament's own dice), maps and factions filled.
func _play(t: Tournament, n: int) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 11
	for i in n:
		if t.done():
			return
		t.computer_turns()
		var rm := t.ready_matches()
		if rm.is_empty():
			return
		var m: Dictionary = rm[0]
		var ng := t.next_game(m)
		t.report_game(int(m["id"]), "a" if r.randf() < 0.62 else "b", {"len": r.randi_range(420, 1200), "how": "time" if r.randf() < 0.15 else "played"})


func _field(t: Tournament, n: int) -> void:
	for i in n:
		var e: Array = TournamentPage.DEFAULT_FIELD[i % TournamentPage.DEFAULT_FIELD.size()]
		t.add_player("%s %s" % [String(e[0]).capitalize(), AI.STRATEGIES[e[1]]["name"]], e[0], "hard", e[1])


func _run() -> void:
	await create_timer(1.0).timeout
	main.show_menu()
	await _snap("01_menu")
	if not main.menu_buttons.has("tournament"):
		print("FAIL no TOURNAMENTS on the main menu")
		fails += 1
	else:
		(main.menu_buttons["tournament"] as Button).pressed.emit()
	await _snap("02_home")
	_press("Tour_Make")
	await _snap("03_make")
	# an ALL COMPUTER double elimination of 16, half played
	var t := _keep(Tournament.make("The Winter Cup", {"mode": "computer", "format": "double", "bo": 3, "bo_final": 5, "time_limit": 1200}))
	_field(t, 16)
	t.start()
	_play(t, 40)
	t.save()
	TournamentPage.show_tournament(main, String(t.d["id"]))
	await _snap("04_bracket_double")
	var p := _page()
	p._bv.zoom_by(1.6, Vector2(200, 200))
	await _snap("05_bracket_zoomed")
	var live := t.ready_matches()
	p.t.computer_turns()
	p._open_match(int(live[0]["id"]))
	await _snap("06_match_card")
	_press("Tour_MatchClose")
	for tb in ["standings", "schedule", "players", "rules"]:
		_press("Tour_Tab_" + tb)
		await _snap("07_tab_" + tb)
	_press("Tour_Tab_bracket")
	# finished: the champion
	_play(p.t, 200)
	p.t.save()
	TournamentPage.show_tournament(main, String(p.t.d["id"]))
	await create_timer(0.3).timeout
	_page()._champion()
	await _snap("08_champion", 1.0)
	_press("Tour_ChampionClose")
	await _snap("09_bracket_done")
	# groups, then playoffs (12 players, 4 groups)
	var g := _keep(Tournament.make("Groups Open", {"mode": "offline", "format": "groups", "groups": 4, "advance": 2, "bo": 1, "bo_final": 3}))
	_field(g, 12)
	g.start()
	_play(g, 26)
	g.save()
	TournamentPage.show_tournament(main, String(g.d["id"]))
	await _snap("10_groups")
	_press("Tour_Tab_standings")
	await _snap("11_groups_standings")
	# Swiss, 10 players, round 3
	var s := _keep(Tournament.make("Swiss Night", {"mode": "offline", "format": "swiss", "bo": 1}))
	_field(s, 10)
	s.start()
	_play(s, 12)
	s.save()
	TournamentPage.show_tournament(main, String(s.d["id"]))
	_press("Tour_Tab_bracket")
	await _snap("12_swiss")
	_press("Tour_Tab_standings")
	await _snap("13_swiss_standings")
	# an online tournament at sign-up, then started: a match card with a ban to make
	var o := _keep(Tournament.make("Friday Online", {"mode": "online", "format": "single", "bo": 3, "map_rule": "veto", "factions": "series", "checkin": true}))
	var mine := o.add_player("Salgarellius", "crown")
	o.d["org_pid"] = mine
	for nm in ["Ana", "Bruno", "Carla", "Diego", "Elena"]:
		o.add_player(nm, "random")
	for pl in o.players():
		if pl["name"] != "Elena" and pl["name"] != "Diego":
			o.check_in(int(pl["id"]))
	o.save()
	TournamentPage.show_tournament(main, String(o.d["id"]))
	_press("Tour_Tab_players")
	await _snap("14_online_signup")
	var dk0 = main.get("tour_desk")
	if dk0:
		dk0.close_desk()
		dk0.queue_free()
		main.set("tour_desk", null)
	o.d["seeding"] = "manual"
	o.start()
	o.save()
	TournamentPage.show_tournament(main, String(o.d["id"]))
	_press("Tour_Tab_bracket")
	await _snap("15_online_bracket")
	var pg := _page()
	var pick_m: Dictionary = pg.t.ready_matches()[0]
	for m in pg.t.ready_matches():
		if pg.t.side_of(m, mine) != "":
			pick_m = m
	pg._open_match(int(pick_m["id"]))
	await _snap("16_online_ban")
	_press("Tour_MatchClose")
	# clean up this run's tournaments
	for id in made:
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://tournaments/%s.json" % id))
	var dk = main.get("tour_desk")
	if dk:
		dk.close_desk()
	print("shot_tournament: done, %d failures" % fails)
	quit(1 if fails > 0 else 0)
