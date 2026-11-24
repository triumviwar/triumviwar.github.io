extends SceneTree
## TOURNAMENTS ONLINE on one computer (docs/tournament.md "Online"): a local relay (tools/relay/local_relay.mjs), the
## organiser's desk and ten players' games in one process. Ten players join at once (the relay seats 7 guests in a room:
## the others wait and call again), a wrong key is refused, a name twice is refused, check-in, the organiser starts,
## bans and a faction by the players' own calls, a result both report (and one only the winner reports, then the
## loser), a dispute, a player leaving, a spectator's look; then a match's room as PLAY YOUR MATCH makes it: the host's
## room carries the bracket's map and factions, the guest sits, and its faction change is refused.
##   tools/test_online.sh tournament     (or: node tools/relay/local_relay.mjs 8799 & godot --headless --script
##   res://tools/test_tournament_online.gd -- relay:ws://127.0.0.1:8799)

var relay := "ws://127.0.0.1:8799"
var fails := 0
var checks := 0
var desk: TournamentNet
var t: Tournament
var players: Array = []      # TournamentNet, one a player


func ok(c: bool, what: String) -> void:
	checks += 1
	print(("CHECK ok   " if c else "CHECK FAIL ") + what)
	if not c:
		fails += 1


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("relay:"):
			relay = a.substr(6)
	_run.call_deferred()


func _wait(cond: Callable, secs := 20.0) -> bool:
	var t0 := Time.get_ticks_msec()
	while not cond.call():
		await process_frame
		if Time.get_ticks_msec() - t0 > secs * 1000.0:
			return false
	return true


## A player's call, waited for: [ok, why].
func _call(p: TournamentNet, msg: Dictionary) -> Array:
	var res := []
	p.answered.connect(func(o: bool, w: String) -> void: res.append_array([o, w]), CONNECT_ONE_SHOT)
	p.call_desk(relay, String(t.d["id"]), msg)
	await _wait(func() -> bool: return not res.is_empty(), 40.0)
	return res if not res.is_empty() else [false, "no answer"]


func _run() -> void:
	t = Tournament.make("Loopback Cup", {"mode": "online", "format": "double", "bo": 3, "bo_final": 3, "map_rule": "veto",
		"factions": "series", "checkin": true, "seeding": "manual"})
	t.d["id"] = "TLOOP"
	desk = TournamentNet.new()
	root.add_child(desk)
	desk.open_desk(relay, t)
	ok(await _wait(func() -> bool: return desk.link != null and desk.link.connected), "the desk opens on the relay")
	# ten players join at once
	var done := []
	for i in 10:
		var p := TournamentNet.new()
		root.add_child(p)
		players.append(p)
		p.answered.connect(func(o: bool, _w: String) -> void: done.append(o), CONNECT_ONE_SHOT)
		p.call_desk(relay, "TLOOP", {"t": "tj", "name": "Player %d" % (i + 1), "fac": ["crown", "brood", "clockwork"][i % 3]})
	await _wait(func() -> bool: return done.size() >= 10, 90.0)
	ok(done.size() == 10 and done.all(func(x) -> bool: return x), "ten players joined at once (%d answered)" % done.size())
	ok(t.players().size() == 10, "the desk holds 10 players (%d)" % t.players().size())
	ok(players.all(func(p) -> bool: return p.me >= 0 and p.key != ""), "each player got its id and key")
	ok(players.all(func(p) -> bool: return p.t != null and not str(p.t.d).contains(String(t.player(p.me)["key"]))), "no key is sent to the players")
	# a name twice, a wrong key
	var dup := TournamentNet.new()
	root.add_child(dup)
	var r: Array = await _call(dup, {"t": "tj", "name": "player 3"})
	ok(r[0] and String(r[1]).contains("taken"), "the same name twice is refused (%s)" % r[1])
	var liar := TournamentNet.new()
	root.add_child(liar)
	liar.me = players[0].me
	liar.key = "0000"
	r = await _call(liar, {"t": "tci"})
	ok(String(r[1]).contains("not in"), "a wrong key can't act for a player (%s)" % r[1])
	# check-in: 9 of 10; the last one leaves
	for i in 9:
		await _call(players[i], {"t": "tci"})
	ok(t.players().filter(func(p) -> bool: return p["checked"]).size() == 9, "nine checked in")
	r = await _call(players[9], {"t": "tl"})
	ok(t.players().size() == 9, "a player left before the start (%d left)" % t.players().size())
	# the organiser starts
	var prob := t.start_problem()
	ok(t.start(), "the organiser starts (%s)" % prob)
	t.save()
	r = await _call(players[0], {"t": "tj"})
	ok(players[0].t.d["state"] == "running", "a player's copy shows it under way")
	# seed 1 (player 1) has a bye; find a real first-round match
	var m := {}
	for x in t.ready_matches():
		if int(x["a"]) >= 0 and int(x["b"]) >= 0:
			m = x
			break
	var pa: TournamentNet = _by_id(int(m["a"]))
	var pb: TournamentNet = _by_id(int(m["b"]))
	var mid := int(m["id"])
	r = await _call(pb, {"t": "tb", "mid": mid, "map": "greenhold"})
	ok(String(r[1]).contains("Not your ban"), "b can't ban first")
	await _call(pa, {"t": "tb", "mid": mid, "map": "greenhold"})
	await _call(pb, {"t": "tb", "mid": mid, "map": "dune_sea"})
	ok((m["bans"] as Array) == ["greenhold", "dune_sea"], "both banned (%s)" % str(m["bans"]))
	await _call(pa, {"t": "tf", "mid": mid, "fac": "crown"})
	await _call(pb, {"t": "tf", "mid": mid, "fac": "brood"})
	ok(t.faction_for(m, "a") == "crown" and t.faction_for(m, "b") == "brood", "each chose a faction for game 1")
	# game 1: both report a won
	r = await _call(pa, {"t": "tr", "mid": mid, "win": "a", "info": {"game": 0, "len": 700}})
	ok(String(r[1]) == "waiting", "the winner's report waits (%s)" % r[1])
	r = await _call(pb, {"t": "tr", "mid": mid, "win": "a", "info": {"game": 0, "len": 700}})
	ok(t.score(m) == [1, 0], "both agree: 1-0 (%s)" % str(t.score(m)))
	# game 2: the loser's word alone is enough
	ok(t.faction_for(m, "a") == "crown", "series: the faction is kept for game 2")
	r = await _call(pa, {"t": "tr", "mid": mid, "win": "b", "info": {"game": 1, "len": 800}})
	ok(t.score(m) == [1, 1], "the loser reported: 1-1")
	# game 3: a dispute, the organiser settles it
	r = await _call(pa, {"t": "tr", "mid": mid, "win": "a", "info": {"game": 2}})
	r = await _call(pb, {"t": "tr", "mid": mid, "win": "b", "info": {"game": 2}})
	ok(String(r[1]) == "dispute" and String(m["dispute"]) != "", "both say they won: a dispute (%s, %s)" % [r[1], m["dispute"]])
	ok(t.set_result(mid, 2, 1), "the organiser sets 2-1")
	ok(m["state"] == "done" and int(m["winner"]) == int(m["a"]), "the match is over")
	# a report for someone else's match
	var other: TournamentNet = null
	for p in players.slice(0, 9):
		if p != pa and p != pb:
			other = p
			break
	r = await _call(other, {"t": "tr", "mid": mid, "win": "b"})
	ok(String(r[1]).contains("not your match") or String(r[1]).contains("That is not"), "only the match's players report it (%s)" % r[1])
	# a spectator looks at the bracket
	var look := TournamentNet.new()
	root.add_child(look)
	r = await _call(look, {"t": "tj"})
	ok(r[0] and look.me == -1 and look.t != null and look.t.d["state"] == "running", "a spectator sees the bracket")
	# a game's own report sent at the end of a match (TournamentPage._report_later)
	var m2 := {}
	for x in t.ready_matches():
		if int(x["a"]) >= 0 and int(x["b"]) >= 0 and x["state"] == "ready":
			m2 = x
			break
	var p2a: TournamentNet = _by_id(int(m2["a"]))
	TournamentNet.joined_save("TLOOP", {"me": p2a.me, "key": p2a.key})
	var main := Node.new()
	root.add_child(main)
	t.ban(m2, "a", "frostfang")
	t.ban(m2, "b", "hollowfen")
	t.choose_faction(m2, "a", "clockwork")
	t.choose_faction(m2, "b", "crown")
	TournamentPage._report_later(main, "TLOOP", {"t": "tr", "mid": int(m2["id"]), "win": "b", "info": {"game": 0, "len": 444, "replay": "x.hfr"}},
		{"relay": relay})
	ok(await _wait(func() -> bool: return (m2["games"] as Array).size() == 1, 30.0), "the game's own report (the loser's) reached the desk")
	ok(String(m2["games"][0]["replay"]) == "x.hfr" if not (m2["games"] as Array).is_empty() else false, "the replay's name is on the bracket")
	# PLAY YOUR MATCH's room: the host's room carries the bracket's map and factions; a guest's faction change is refused
	var ng := t.next_game(m2)
	var host := NetLobby.new()
	root.add_child(host)
	host.host(relay, t.room_code(m2))
	host.set_map(String(ng["map"]))
	host.slots[0]["faction"] = "clockwork"
	host.slots[1]["faction"] = "crown"
	host.tour_lock = true
	await _wait(func() -> bool: return host.online, 15.0)
	var guest := NetLobby.new()
	root.add_child(guest)
	guest.join(relay, t.room_code(m2))
	ok(await _wait(func() -> bool: return guest._got_lobby and host.all_seated(), 20.0), "the opponent joined the match's room %s" % t.room_code(m2))
	ok(guest.map == String(ng["map"]) and String(guest.slots[1]["faction"]) == "crown", "the room has the bracket's map and factions (%s, %s)" % [guest.map, guest.slots[1]["faction"]])
	guest.choose_faction("brood")
	host.set_map("greenhold")
	await create_timer(1.5).timeout
	ok(String(host.slots[1]["faction"]) == "crown" and host.map == String(ng["map"]), "nobody changes the bracket's map or factions in the room")
	var spec := NetLobby.new()
	root.add_child(spec)
	spec.want_spec = true
	spec.join(relay, t.room_code(m2))
	ok(await _wait(func() -> bool: return spec.spectating and spec._got_lobby, 20.0), "a spectator joins the match's room from the bracket")
	print("tournament online: %d checks, %d failed" % [checks, fails])
	print("ALL OK" if fails == 0 else "SOME FAILED")
	desk.close_desk()
	for x in [host, guest, spec]:
		x.dispose()
	await create_timer(0.5).timeout
	quit(1 if fails > 0 else 0)


func _by_id(pid: int) -> TournamentNet:
	for p in players:
		if p.me == pid:
			return p
	return null
