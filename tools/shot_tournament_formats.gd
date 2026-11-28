extends SceneTree
## Pictures of the TOURNAMENT TYPES and the MAP POOL PICKER (job tournament-formats, docs/tournament_formats.md,
## docs/shots/tournament_formats/): MAKE A TOURNAMENT with the TYPE list, the map pool's cards (all, 4-player maps,
## 6-8 players, a search, a 2v2's greyed 2-player maps, your maps greyed online), a 2v2 all-computer tournament half
## played (bracket, a match card with the teams' members, players, standings), a 2v2 online one at sign-up with its
## teams, a drawn-teams one at sign-up, and a 3v3. Uses its own tournaments only (deleted after).
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_tournament_formats.gd -- <outdir> [pc|mobile]
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


func _find(name: String) -> Node:
	return main.ui_layer.find_child(name, true, false)


func _press(name: String) -> bool:
	var b: Node = _find(name)
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


## Scroll the page's (first) scroll list so `node` is in view.
func _scroll_to(node: Control) -> void:
	var p: Node = node.get_parent()
	while p and not (p is ScrollContainer):
		p = p.get_parent()
	if p:
		var sc := p as ScrollContainer
		sc.scroll_vertical = int(node.global_position.y - sc.global_position.y + sc.scroll_vertical - 8)


func _play(t: Tournament, n: int) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 5
	for i in n:
		if t.done():
			return
		t.computer_turns()
		var rm := t.ready_matches()
		if rm.is_empty():
			return
		t.report_game(int(rm[0]["id"]), "a" if r.randf() < 0.6 else "b", {"len": r.randi_range(420, 1200)})


func _set_type(ts: int) -> void:
	var o: OptionButton = _find("Tour_Type")
	if o == null:
		print("FAIL no TYPE list")
		fails += 1
		return
	o.select(Tournament.TEAM_SIZES.find(ts))
	o.item_selected.emit(Tournament.TEAM_SIZES.find(ts))


func _run() -> void:
	await create_timer(1.0).timeout
	TournamentPage.show_home(main)
	await process_frame
	_press("Tour_Make")
	await _snap("01_make_type")
	var pool_head: Control = _find("Tour_PoolPl_all")
	await process_frame
	if pool_head:
		_scroll_to(pool_head)
	await _snap("02_pool_all")
	_press("Tour_PoolPl_4")
	await process_frame
	await process_frame
	_scroll_to(_find("Tour_PoolPl_all"))
	await _snap("03_pool_4player")
	_press("Tour_PoolPl_more")
	await process_frame
	await process_frame
	_scroll_to(_find("Tour_PoolPl_all"))
	await _snap("04_pool_6_8")
	_press("Tour_PoolPl_all")
	var se: LineEdit = _find("Tour_PoolSearch")
	if se:
		se.text = "ford"
		se.text_submitted.emit("ford")
	await process_frame
	await process_frame
	_scroll_to(_find("Tour_PoolPl_all"))
	await _snap("05_pool_search")
	TournamentPage.pool_search = ""
	# a 2v2: the 2-player maps greyed
	_set_type(2)
	await process_frame
	_press("Tour_PoolPl_2")
	await process_frame
	await process_frame
	_scroll_to(_find("Tour_PoolPl_all"))
	await _snap("06_pool_2v2_greyed")
	_press("Tour_PoolPl_all")
	TournamentPage.pool_players = "all"
	# a 2v2 all computer tournament, half played
	var t := _keep(Tournament.make("Pairs Cup", {"mode": "computer", "format": "double", "bo": 1, "bo_final": 3, "team_size": 2,
		"maps": ["greenhold", "dune_sea", "frostfang"]}))
	TournamentPage.fill_teams(t, 8)
	t.start()
	_play(t, 9)
	t.save()
	TournamentPage.show_tournament(main, String(t.d["id"]))
	await process_frame
	_press("Tour_Tab_bracket")
	await process_frame
	await _snap("07_2v2_bracket")
	var p := _page()
	p.t.computer_turns()
	p._open_match(int(p.t.ready_matches()[0]["id"]))
	await _snap("08_2v2_match_card")
	_press("Tour_MatchClose")
	await process_frame
	_press("Tour_Tab_players")
	await process_frame
	await _snap("09_2v2_players")
	await process_frame
	_press("Tour_Tab_standings")
	await process_frame
	await _snap("10_2v2_standings")
	# a 2v2 online one at sign-up: fixed teams, one short of a player
	var o := _keep(Tournament.make("Friday Pairs", {"mode": "online", "format": "single", "bo": 3, "team_size": 2, "team_rule": "fixed"}))
	var mine := o.join_team("Purple Guard", "Salgarellius", "crown")
	o.d["org_pid"] = int(mine[0])
	o.d["org_key"] = String(mine[2])
	o.join_team("Purple Guard", "Ana", "clockwork")
	o.join_team("Green Eyes", "Bruno", "brood")
	o.join_team("Green Eyes", "Carla", "brood")
	o.join_team("Brass Hands", "Diego", "clockwork")
	o.save()
	TournamentPage.show_tournament(main, String(o.d["id"]))
	await process_frame
	_press("Tour_Tab_players")
	await process_frame
	await _snap("11_2v2_online_signup")
	var dk0 = main.get("tour_desk")
	if dk0:
		dk0.close_desk()
		dk0.queue_free()
		main.set("tour_desk", null)
	# drawn teams at sign-up
	var dr := _keep(Tournament.make("Lucky Draw", {"mode": "offline", "format": "robin", "bo": 1, "team_size": 2, "team_rule": "drawn"}))
	for nm in ["Ana", "Bruno", "Carla", "Diego", "Elena", "Fábio"]:
		dr.add_player(nm, ["crown", "clockwork", "brood"][dr.players().size() % 3])
	dr.save()
	TournamentPage.show_tournament(main, String(dr.d["id"]))
	await process_frame
	_press("Tour_Tab_players")
	await process_frame
	await _snap("12_drawn_signup")
	dr.start()
	dr.save()
	TournamentPage.show_tournament(main, String(dr.d["id"]))
	await process_frame
	_press("Tour_Tab_players")
	await process_frame
	await _snap("13_drawn_teams")
	# a 3v3 round robin of four teams
	var maps3: Array = MapData.NAMED.keys().filter(func(id) -> bool: return MapGen.max_players(String(id)) >= 6)
	var t3 := _keep(Tournament.make("Threes", {"mode": "computer", "format": "robin", "bo": 1, "team_size": 3, "maps": maps3.slice(0, 3)}))
	TournamentPage.fill_teams(t3, 4)
	t3.start()
	_play(t3, 3)
	t3.save()
	TournamentPage.show_tournament(main, String(t3.d["id"]))
	await process_frame
	_press("Tour_Tab_standings")
	await process_frame
	await _snap("14_3v3_standings")
	for id in made:
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://tournaments/%s.json" % id))
	var dk = main.get("tour_desk")
	if dk:
		dk.close_desk()
	print("shot_tournament_formats: done, %d failures" % fails)
	quit(1 if fails > 0 else 0)
