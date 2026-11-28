extends SceneTree
## TOURNAMENTS, PLAYED IN THE GAME (docs/tournament.md): an ALL COMPUTER tournament of two (a Crown and a Brood
## computer, double elimination, best of 1, a short time limit) run from its page with PLAY EVERY GAME QUICKLY: every
## game a real match, played one after another at QUICK_SPEED with the picture covered, ended at the time limit by the
## lead rule (or played again), its result and replay put on the bracket by the game itself, until the champion.
## Then the same for a 2v2 TEAM tournament (job tournament-formats): two computer teams of two, four slots a game, the
## lead rule by team. `only:1` / `only:2` runs one of them.
##   godot --headless --script res://tools/test_tournament_play.gd [-- limit:40 only:2]
var main
var fails := 0
var checks := 0
var limit := 40
var tid := ""
var only := 0


func ok(c: bool, what: String) -> void:
	checks += 1
	print(("CHECK ok   " if c else "CHECK FAIL ") + what)
	if not c:
		fails += 1


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("limit:"):
			limit = int(a.substr(6))
		if a.begins_with("only:"):
			only = int(a.substr(5))
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	Settings.load_all()
	Settings.device = "pc"
	Settings.apply()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await create_timer(0.5).timeout
	for ts in [1, 2]:
		if only == 0 or only == ts:
			await _run_one(ts)
	print("tournament play: %d checks, %d failed" % [checks, fails])
	quit(1 if fails > 0 else 0)


func _run_one(ts: int) -> void:
	var tag := "1v1" if ts == 1 else "%dv%d" % [ts, ts]
	print("---- %s" % tag)
	var t := Tournament.make("Play Test " + tag, {"mode": "computer", "format": "double", "bo": 1, "bo_final": 1, "time_limit": limit,
		"map_rule": "random", "maps": ["greenhold"], "team_size": ts})
	if ts == 1:
		t.add_player("Crown Optimal", "crown", "hard", "optimal")
		t.add_player("Brood Optimal", "brood", "hard", "optimal")
	else:
		t.add_team("Crown and Brood", [{"name": "Crown Optimal", "faction": "crown", "who": "hard", "plan": "optimal"},
			{"name": "Brood Optimal", "faction": "brood", "who": "hard", "plan": "optimal"}])
		t.add_team("Clockwork and Crown", [{"name": "Clockwork Optimal", "faction": "clockwork", "who": "hard", "plan": "optimal"},
			{"name": "Crown Balanced", "faction": "crown", "who": "hard", "plan": "balanced"}])
	ok(t.start(), "%s: the tournament starts" % tag)
	t.save()
	tid = String(t.d["id"])
	TournamentPage.show_tournament(main, tid)
	await process_frame
	var p: TournamentPage = main.ui_layer.find_child("TournamentPage", true, false)
	ok(p != null and p.t != null, "its page opens")
	var b: Button = main.ui_layer.find_child("Tour_PlayAll", true, false)
	ok(b != null, "PLAY EVERY GAME QUICKLY is on the page")
	b.pressed.emit()
	await process_frame
	ok(main.game != null and not main.tour_game.is_empty(), "a game of the tournament is under way")
	if main.game:
		ok(main.game.n_players() == 2 * ts, "%s: the game has %d players (%d)" % [tag, 2 * ts, main.game.n_players()])
		var sd := {}
		for x in main.game.sides:
			sd[int(x)] = int(sd.get(int(x), 0)) + 1
		ok(sd.size() == 2 and sd.values().all(func(v) -> bool: return int(v) == ts), "%s: two sides of %d" % [tag, ts])
	ok(Engine.time_scale == TournamentPage.QUICK_SPEED, "played quickly (x%d)" % int(Engine.time_scale))
	var t0 := Time.get_ticks_msec()
	var games := 0
	var last_game: Game = null
	while Time.get_ticks_msec() - t0 < 900000:
		await process_frame
		if main.game and main.game != last_game:
			last_game = main.game
			games += 1
		var cur := Tournament.load_from("user://tournaments/%s.json" % tid)
		if cur and cur.done() and main.game == null:
			break
	var fin := Tournament.load_from("user://tournaments/%s.json" % tid)
	ok(fin != null and fin.done(), "the tournament ran to its champion (%s)" % (fin.pname(int(fin.d["champion"])) if fin else "?"))
	var played := fin.all_games() if fin else []
	ok(played.size() >= 2, "%d games are on the bracket (%d matches started)" % [played.size(), games])
	var timed := played.filter(func(g) -> bool: return g["how"] == "time").size()
	ok(timed + played.filter(func(g) -> bool: return g["how"] == "played").size() == played.size(), "each game won by the game or at the time limit (%d at the limit)" % timed)
	var rp := played.filter(func(g) -> bool: return String(g["replay"]) != "" and FileAccess.file_exists(ReplayFile.DIR + "/" + String(g["replay"])))
	ok(rp.size() == played.size(), "every game's replay is kept and linked (%d of %d)" % [rp.size(), played.size()])
	ok(Engine.time_scale == 1.0, "the game's speed is back to normal")
	ok(main.ui_layer.find_child("TournamentPage", true, false) != null, "back on the tournament's page")
	for g in rp:
		ReplayFile.delete(ReplayFile.DIR + "/" + String(g["replay"]))
	if ts > 1 and fin:
		ok(fin.player(int(fin.d["champion"])).has("members"), "%s: the champion is a team" % tag)
		ok(played.all(func(g) -> bool: return String(g["fa"]).split(",").size() == ts), "%s: each game keeps the team's factions" % tag)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://tournaments/%s.json" % tid))
	TournamentPage.show_home(main)
	await process_frame
