extends SceneTree
## ONLINE SPECTATORS, end to end on one computer (docs/online_spectators.md): a relay, a HOST, a GUEST who plays and two
## SPECTATORS, each its own process (tools/test_online.sh spectators runs them all and checks the CHECK lines).
##   role:spec1  joins first (takes the free seat), then picks SPECTATOR in its FACTION list: it moves to the spectators'
##               group and the seat is free again; in the match it must see every side, its forged order is refused, it
##               says something in the chat (the spectators only), and after the end it gets the host's whole replay.
##   role:guest  joins after it and takes the seat; plays (its picture still hides the enemy it can't see), says something
##               the spectators must hear, never hears the spectators, and surrenders at the end.
##   role:spec2  JOINS TO WATCH once the match is under way (a first whole picture), chats, then leaves mid-game: the
##               players must not notice (no computer takes a seat, the match goes on).
##   role:host   checks the room (the spectator listed apart, START allowed), audits every player's picture against its
##               side's sight (NetSession.fog_audit), and measures its upload with 2 spectators (the BW line).
var main: Node
var role := "host"
var relay := "ws://127.0.0.1:8799"
var code := "SPEC"
var map := "hollowfen"
var limit := 300.0
var match_secs := 55.0           # the guest surrenders after this long in the match
var shots := ""                  # shots:<dir>: screenshots (needs a window: xvfb-run, no --headless)
var t := 0.0
var lobby: NetLobby
var g: Game
var step := 0
var step_t := 0.0
var base := {}
var results := {}
var _shot_q: Array = []
var _bw: Dictionary = {}
var ai := false                  # ai: the host runs a Hard computer for each side (a real fight to measure the upload in)
var stay := 12.0                 # spec2: seconds it watches before it leaves


func _initialize() -> void:
	Engine.max_fps = 60
	for a in OS.get_cmdline_user_args():
		if a.begins_with("role:"):
			role = a.substr(5)
		elif a.begins_with("relay:"):
			relay = a.substr(6)
		elif a.begins_with("code:"):
			code = a.substr(5)
		elif a.begins_with("map:"):
			map = a.substr(4)
		elif a.begins_with("shots:"):
			shots = a.substr(6)
		elif a.begins_with("match:"):
			match_secs = float(a.substr(6))
		elif a == "ai":
			ai = true
		elif a.begins_with("stay:"):
			stay = float(a.substr(5))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func check(name: String, ok: bool, extra := "") -> void:
	results[name] = ok
	print("CHECK %s %s %s %s" % [role.to_upper(), name, "OK" if ok else "FAIL", extra])


func snap(name: String) -> void:
	if shots != "":
		_shot_q.append([name, 20])


func _snap_tick() -> void:
	for q in _shot_q.duplicate():
		q[1] -= 1
		if q[1] <= 0:
			_shot_q.erase(q)
			var img := root.get_viewport().get_texture().get_image()
			if img:
				img.save_png("%s/%s_%s.png" % [shots, role, q[0]])
				print("SHOT %s_%s" % [role, q[0]])


func _process(delta: float) -> bool:
	t += delta
	step_t += delta
	_snap_tick()
	if t < 0.5:
		return false
	if lobby == null:
		_begin()
		return false
	if t > limit:
		print("TIMEOUT %s in step %d" % [role, step])
		_finish()
		return false
	match role:
		"host":
			_host()
		"guest":
			_guest()
		"spec1":
			_spec1()
		"spec2":
			_spec2()
	return false


func _begin() -> void:
	lobby = NetLobby.new()
	main.add_child(lobby)
	main.net_lobby = lobby
	lobby.failed.connect(func(why: String) -> void: print("%s LOBBY FAILED: %s" % [role.to_upper(), why]))
	if role == "host":
		lobby.host(relay, code)
		lobby.map = map
		lobby.slots[0]["faction"] = "crown"
		lobby.slots[1]["faction"] = "crown"
		lobby.set_colour(0, 0)
		return
	lobby.start_now.connect(func(cfg: Dictionary) -> void:
		print("%s got start: map=%s slots=%d spec=%s" % [role.to_upper(), cfg["map"], cfg["slots"].size(), str(cfg["net"].get("spec", false))])
		main.start(cfg))
	lobby.want_spec = role == "spec2"
	lobby.join(relay, code)


func _all_ok() -> bool:
	for k in results:
		if not results[k]:
			return false
	return true


func _finish() -> void:
	print("%s %s" % [role.to_upper(), "ALL OK" if _all_ok() and not results.is_empty() else "SOME FAILED"])
	if lobby and is_instance_valid(lobby):
		lobby.dispose()
	quit(0)


func _hall_of(gm: Game, team: int) -> Building:
	for b in gm.buildings:
		if b.team == team and not b.dead and b.kind == Defs.FACTIONS[gm.faction_of(team)]["hall"]:
			return b
	return null


func _lines_from_specs(gm: Game) -> Array:
	return gm.chat.lines.filter(func(l: Dictionary) -> bool: return int(l.get("spec", 0)) > 0 or int(l["team"]) < 0) if gm.chat else []


# ------------------------------------------------------------------ host

func _host() -> void:
	if g == null:
		if step == 0 and lobby.specs.size() == 1 and lobby.all_seated():
			step = 1
			step_t = 0.0
			if shots != "":
				main.show_online()
				snap("lobby")
		if step == 1 and step_t > (3.0 if shots != "" else 1.0):
			check("host_lobby_lists_spectator_apart", lobby.specs.size() == 1 and lobby.slots.size() == 2 and int(lobby.slots[1].get("peer", -1)) >= 0
				and not lobby.is_spec(int(lobby.slots[1]["peer"])), "specs %s, seats %d" % [str(lobby.specs), lobby.slots.size()])
			check("host_can_start_with_spectators", lobby.problem() == "", lobby.problem())
			main.start(lobby.make_cfg())
			g = main.game
			g.net.fog_audit = true
			if ai:
				for tm in [0, 1]:
					var c: AI = AICrown.new()
					c.game = g
					c.team = tm
					c.difficulty = 2
					c.strategy = "balanced"
					g.add_child(c)
					g.ais.append(c)
			step = 2
			step_t = 0.0
		return
	var s := g.net
	if step == 2:
		base["ais"] = g.ais.size()
		check("host_session_has_spectator", s.spec_peers.size() == 1 and s.peer_team.size() == 1, "spectators %s, players %s" % [str(s.spec_peers), str(s.peer_team)])
		step = 3
	if step == 3 and s.spec_peers.size() == 2 and not _bw.has("t0"):
		_bw = {"t0": t, "pb": s.player_bytes, "sb": s.spec_bytes, "all": s.link.sent_bytes, "n0": s.snap_n, "c0": g.clock}
		print("HOST a second spectator joined the match under way at %.0f s of play" % g.clock)
		base["two"] = true
	if step == 3 and base.has("two") and s.spec_peers.size() == 1 and not base.has("left"):
		base["left"] = true
		var dt := maxf(t - float(_bw["t0"]), 0.001)
		var pb := (s.player_bytes - int(_bw["pb"])) / 1024.0 / dt
		var sb := (s.spec_bytes - int(_bw["sb"])) / 1024.0 / dt
		var all := (s.link.sent_bytes - int(_bw["all"])) / 1024.0 / dt
		print("BW host upload with 1 guest player + 2 spectators over %.0f s (%d pictures, %d units on the field at the end, %.0f-%.0f s of play): to the player %.1f KB/s, to the spectators %.1f KB/s (%.1f each), everything %.1f KB/s" % [dt, s.snap_n - int(_bw["n0"]), g.units.size(), float(_bw.get("c0", 0.0)), g.clock, pb, sb, sb / 2.0, all])
		base["after_left_t"] = t
	if step == 3 and base.has("after_left_t") and t - float(base["after_left_t"]) > 4.0 and not results.has("host_spectator_leaving_changes_nothing"):
		check("host_spectator_leaving_changes_nothing", not g.over and g.ais.size() == int(base["ais"]) and s.lost_peers.is_empty() and s.peer_team.size() == 1,
			"over %s, computers %d (was %d), players lost %d" % [str(g.over), g.ais.size(), int(base["ais"]), s.lost_peers.size()])
	if g.over and step == 3:
		step = 4
		step_t = 0.0
	if step == 4:
		if s.replay_progress() >= 1.0 and step_t > 6.0 or step_t > 60.0:
			var refused := 0
			var why := ""
			for pr in s.audit:
				if s.spec_peers.has(pr) or not s.peer_team.has(pr):
					refused += int(s.audit[pr]["refused"])
					why = str(s.audit[pr]["why"])
			check("host_refused_spectator_orders", refused >= 1, why)
			check("host_players_pictures_hide_the_fog", s.fog_stats["leaks"] == 0 and s.fog_stats["pictures"] > 0, str(s.fog_stats))
			check("host_never_showed_spectator_chat", _lines_from_specs(g).is_empty(), str(_lines_from_specs(g)))
			check("host_sent_replay_to_everyone", s.replay_progress() >= 1.0, "%d KB" % (s.rp_out.size() / 1024))
			_finish()


# ------------------------------------------------------------------ guest (plays)

func _guest() -> void:
	if g == null:
		if lobby._got_lobby and not base.has("lobby_ok") and lobby.specs.size() == 1:
			base["lobby_ok"] = true
			check("guest_lobby_shows_spectator_group", lobby.my_slot == 1 and not lobby.spectating and lobby.specs.size() == 1, "my slot %d, specs %s" % [lobby.my_slot, str(lobby.specs)])
		if main.game != null:
			g = main.game
			step = 1
			step_t = 0.0
		return
	var s := g.net
	if step == 1 and s.snaps_got >= 15:
		check("guest_fog_hides_enemy_base", _hall_of(g, g.human) != null and _hall_of(g, 0) == null, "own hall %s, enemy hall seen %s" % [str(_hall_of(g, g.human) != null), str(_hall_of(g, 0) != null)])
		g.chat.player_say("player hello")
		step = 2
		step_t = 0.0
	if step == 2 and step_t > match_secs:
		check("guest_never_heard_spectators", _lines_from_specs(g).is_empty(), str(_lines_from_specs(g)))
		g.player_surrender()
		step = 3
		step_t = 0.0
	if step == 3 and (s.rp_path != "" or step_t > 50.0):
		check("guest_got_whole_replay", s.rp_path != "" and FileAccess.file_exists(s.rp_path), s.rp_path.get_file())
		_finish()


# ------------------------------------------------------------------ spectators

func _spec_game_checks(tag: String) -> void:
	var s := g.net
	check(tag + "_watches", g.net_watch and g.demo and g.spectating() and g.controlled_team() == -1 and s.watching and s.my_team == -1,
		"net_watch %s demo %s spectating %s" % [str(g.net_watch), str(g.demo), str(g.spectating())])
	var teams := {}
	for u in g.units:
		teams[u.team] = int(teams.get(u.team, 0)) + 1
	check(tag + "_full_vision", _hall_of(g, 0) != null and _hall_of(g, 1) != null and teams.has(0) and teams.has(1), "units by team %s" % str(teams))


func _spec1() -> void:
	if g == null:
		if lobby._got_lobby and step == 0 and lobby.my_slot == 1:
			lobby.choose_faction("spectator")       # (the FACTION list's SPECTATOR)
			step = 1
			step_t = 0.0
		if step == 1 and lobby.spectating:
			check("spec_moved_to_spectators", lobby.my_slot == -1 and lobby.specs.size() == 1 and lobby.my_spec == 1 and not bool(lobby.slots[1].get("here", true)),
				"specs %s, seat 2 free %s" % [str(lobby.specs), str(not bool(lobby.slots[1].get("here", true)))])
			step = 2
		if step == 2 and shots != "" and lobby.specs.size() == 1 and not base.has("lobby_shot") and lobby.slots.all(func(sl) -> bool: return bool(sl.get("here", true))):
			base["lobby_shot"] = true
			main.show_online()
			snap("lobby")
		if main.game != null:
			g = main.game
			step = 3
			step_t = 0.0
		return
	var s := g.net
	if step == 3 and s.snaps_got >= 15:
		_spec_game_checks("spec")
		# a forged order for one of the host's units: refused by the host (spectators order nothing)
		for u in g.units:
			if u.team == 0 and u.net_id != 0:
				s.send_cmd({"o": u.net_id, "f": "stop", "a": []})
				break
		g.chat.player_say("spec hello")
		step = 4
		step_t = 0.0
		if shots != "":
			snap("match")
	if step == 4 and step_t > 3.0 and not results.has("spec_order_refused"):
		check("spec_order_refused", s.refusals >= 1 and s.last_msg.contains("watching"), s.last_msg)
	if step == 4 and shots != "" and step_t > 20.0 and not base.has("shot2"):
		base["shot2"] = true
		snap("match_later")
	if step == 4 and g.over:
		var lines := g.chat.lines.map(func(l: Dictionary) -> String: return "%s: %s" % [l["name"], l["text"]])
		check("spec_heard_player", lines.any(func(x: String) -> bool: return x.ends_with("player hello")), str(lines))
		check("spec_heard_late_spectator", lines.any(func(x: String) -> bool: return x.contains("SPECTATOR 2") and x.ends_with("late hello")), str(lines))
		check("spec_saw_the_end", g.winner >= 0, "winner %d" % g.winner)
		step = 5
		step_t = 0.0
	if step == 5 and (s.rp_path != "" or step_t > 50.0):
		_spec_replay_checks(s)
		_finish()


func _spec_replay_checks(s: NetSession) -> void:
	var own: String = g.rec.path if g.rec else ""
	check("spec_got_whole_replay", s.rp_path != "" and FileAccess.file_exists(s.rp_path) and (own == "" or not FileAccess.file_exists(own)),
		"%s; own record %s" % [s.rp_path.get_file(), "replaced" if own != "" and not FileAccess.file_exists(own) else "kept"])
	if s.rp_path == "":
		return
	var listed := ReplayFile.list().filter(func(m: Dictionary) -> bool: return String(m["path"]) == s.rp_path)
	check("spec_replay_in_replays_list", listed.size() == 1 and String(listed[0].get("result", "")) == "watched", str(listed[0].get("result", "?")) if not listed.is_empty() else "not listed")
	var d := ReplayPlayer.load_file(s.rp_path)
	var ok := not d.has("error")
	var teams := {}
	var ended := false
	var length := 0.0
	if ok:
		var pg := Game.new()
		pg.puppet = true
		pg.demo = true
		pg.factions = g.factions.duplicate()
		pg.colours = g.colours.duplicate()
		pg.sides = g.sides.duplicate()
		pg.income_mult = g.income_mult.duplicate()
		pg.map_id = g.map_id
		root.add_child(pg)
		var rp := ReplayPlayer.play(pg, d)
		rp.seek(rp.length * 0.5)
		for u in pg.units:
			teams[u.team] = int(teams.get(u.team, 0)) + 1
		rp.seek(rp.length)
		length = rp.length
		ended = rp.length > 10.0
		ok = teams.has(0) and teams.has(1) and ended
		pg.queue_free()
	check("spec_replay_plays_to_the_end", ok, "units by team at the middle %s, length %.0f s" % [str(teams), length])


func _spec2() -> void:
	if g == null:
		if main.game != null:
			g = main.game
			step = 1
			step_t = 0.0
		return
	var s := g.net
	if step == 1 and s.snaps_got >= 20 and step_t > 3.0:
		check("spec2_joined_match_under_way", g.clock > 5.0 and lobby.spectating, "clock %.0f s at the first look" % g.clock)
		_spec_game_checks("spec2")
		check("spec2_first_picture_whole", s.count_diff_max == 0, "worst difference %d" % s.count_diff_max)
		g.chat.player_say("late hello")
		step = 2
		step_t = 0.0
	if step == 2 and step_t > stay:
		var lines := g.chat.lines.map(func(l: Dictionary) -> String: return "%s: %s" % [l["name"], l["text"]])
		check("spec2_chat_shown_as_mine", lines.any(func(x: String) -> bool: return x.begins_with("YOU (SPECTATOR)") and x.ends_with("late hello")), str(lines))
		print("SPEC2 leaves mid-game")
		_finish()
