extends SceneTree
## TOURNAMENTS ONLINE on one computer (docs/tournament.md "Online"): a local relay (tools/relay/local_relay.mjs), the
## organiser's desk and ten players' games in one process. Ten players join at once (the relay seats 7 guests in a room:
## the others wait and call again), a wrong key is refused, a name twice is refused, check-in, the organiser starts,
## bans and a faction by the players' own calls, a result both report (and one only the winner reports, then the
## loser), a dispute, a player leaving, a spectator's look; then a match's room as PLAY YOUR MATCH makes it: the host's
## room carries the bracket's map and factions, the guest sits, and its faction change is refused.
## Then a 2v2 TEAM tournament (job tournament-formats): four players join two teams by name, a fifth is refused by a
## full team, the start, a match's room for four (the host sets it from the bracket, each guest takes its own seat),
## a team-mate's report and the other team's agreeing.
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
	desk.close_desk()
	for x in [host, guest, spec]:
		x.dispose()
	await create_timer(0.5).timeout
	await _teams()
	print("tournament online: %d checks, %d failed" % [checks, fails])
	print("ALL OK" if fails == 0 else "SOME FAILED")
	await create_timer(0.5).timeout
	quit(1 if fails > 0 else 0)


## A 2v2 tournament online (job tournament-formats).
func _teams() -> void:
	t = Tournament.make("Loopback Pairs", {"mode": "online", "format": "single", "bo": 1, "bo_final": 1, "map_rule": "random",
		"team_size": 2, "team_rule": "fixed", "maps": ["greenhold"]})
	t.d["id"] = "TPAIR"
	desk = TournamentNet.new()
	root.add_child(desk)
	desk.open_desk(relay, t)
	ok(await _wait(func() -> bool: return desk.link != null and desk.link.connected), "teams: the desk opens")
	var ps: Array = []
	var spec := [["Ana", "Reds", "crown"], ["Bo", "Reds", "brood"], ["Cy", "Blues", "clockwork"], ["Di", "Blues", "crown"]]
	for e in spec:
		var p := TournamentNet.new()
		root.add_child(p)
		ps.append(p)
		var r: Array = await _call(p, {"t": "tj", "name": e[0], "team": e[1], "fac": e[2]})
		ok(r[0] and String(r[1]).begins_with("ok"), "teams: %s joins %s (%s)" % [e[0], e[1], r[1]])
	ok(t.players().size() == 2 and t.players().all(func(x) -> bool: return (x["members"] as Array).size() == 2), "teams: two teams of two on the desk")
	ok(int(ps[0].me) == int(ps[1].me) and int(ps[1].mi) == 1 and int(ps[2].me) != int(ps[0].me), "teams: each knows its team and its place in it")
	var extra := TournamentNet.new()
	root.add_child(extra)
	var r2: Array = await _call(extra, {"t": "tj", "name": "Ed", "team": "Reds"})
	ok(String(r2[1]).contains("full"), "teams: a full team refuses a fifth (%s)" % r2[1])
	var r3: Array = await _call(extra, {"t": "tj", "name": "Ed"})
	ok(String(r3[1]).contains("team"), "teams: joining without a team's name is refused (%s)" % r3[1])
	var prob := t.start_problem()
	ok(t.start(), "teams: the organiser starts (%s)" % prob)
	t.save()
	var m: Dictionary = t.ready_matches()[0]
	# the match's room: side a's first player hosts it from the bracket; every other player takes its own seat
	var gs := t.game_slots(m, false)
	var by_seat := {}
	for p in ps:
		for i in gs.size():
			if String(gs[i]["s"]) == t.side_of(m, p.me) and int(gs[i]["mi"]) == p.mi:
				by_seat[i] = p
	ok(by_seat.size() == 4, "teams: four seats for four players")
	var host := NetLobby.new()
	root.add_child(host)
	host.tour = {"tid": "TPAIR", "mid": int(m["id"]), "gi": 0}
	host.host(relay, t.room_code(m))
	host.tour_setup(String(t.next_game(m)["map"]), gs)
	await _wait(func() -> bool: return host.online, 15.0)
	var guests: Array = []
	for i in [3, 1, 2]:          # (they arrive in any order)
		var g := NetLobby.new()
		root.add_child(g)
		g.tour_seat = i
		g.join(relay, t.room_code(m))
		guests.append(g)
		await create_timer(0.3).timeout
	ok(await _wait(func() -> bool: return host.all_seated() and guests.all(func(g) -> bool: return g._got_lobby), 25.0), "teams: all four in the room")
	ok(guests.all(func(g) -> bool: return g.my_slot == g.tour_seat), "teams: each guest sits in its own seat (%s)" % str(guests.map(func(g) -> int: return g.my_slot)))
	ok(host.slots.size() == 4 and int(host.slots[0]["side"]) == int(host.slots[1]["side"]) and int(host.slots[2]["side"]) != int(host.slots[0]["side"]), "teams: the room has two sides of two")
	var want: Array = gs.map(func(x) -> String: return String(x["faction"]))
	ok(host.slots.map(func(x) -> String: return String(x["faction"])) == want, "teams: the room has each member's faction (%s)" % str(want))
	guests[0].choose_faction("brood" if String(want[3]) != "brood" else "crown")
	await create_timer(1.0).timeout
	ok(String(host.slots[3]["faction"]) == String(want[3]), "teams: nobody changes a faction in the room")
	ok(host.make_cfg()["slots"].size() == 4, "teams: the match starts with four slots")
	# results: a team-mate's word for the winners waits, the other team's agreeing settles it
	var r4: Array = await _call(by_seat[1], {"t": "tr", "mid": int(m["id"]), "win": "a", "info": {"game": 0}})
	ok(String(r4[1]) == "waiting", "teams: a winner's team-mate alone waits (%s)" % r4[1])
	var r5: Array = await _call(by_seat[3], {"t": "tr", "mid": int(m["id"]), "win": "a", "info": {"game": 0}})
	ok(t.done() and int(t.d["champion"]) == int(m["a"]), "teams: the other team's member agrees: team %s is the champion" % t.pname(int(m["a"])))
	desk.close_desk()
	host.dispose()
	for g in guests:
		g.dispose()
	await create_timer(0.5).timeout


func _by_id(pid: int) -> TournamentNet:
	for p in players:
		if p.me == pid:
			return p
	return null
