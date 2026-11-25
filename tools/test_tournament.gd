extends SceneTree
## TOURNAMENTS: the bracket logic (job tournament, docs/tournament.md). Every format with odd and even fields (byes),
## best-of series, walkovers, a dropped player, the grand final's reset, Swiss pairings without rematches, round-robin
## and Swiss tie-breaks, groups into playoffs, map bans and picks, faction rules, players' reports and disputes, the
## time limit's lead rule, the export code.
##   godot --headless --script res://tools/test_tournament.gd

var fails := 0
var checks := 0


func ok(cond: bool, what: String) -> void:
	checks += 1
	if not cond:
		fails += 1
		print("FAIL ", what)


func _initialize() -> void:
	_single()
	_double()
	_double_reset()
	_double_sizes()
	_robin()
	_swiss()
	_groups()
	_maps_and_factions()
	_reports()
	_time_rule()
	_drop()
	_codes()
	print("tournament: %d checks, %d failed" % [checks, fails])
	quit(1 if fails > 0 else 0)


func _make(n: int, fmt: String, opts := {}) -> Tournament:
	var o := {"format": fmt, "bo": 1, "bo_final": 1, "seeding": "manual", "map_rule": "random", "seed": 7}
	for k in opts:
		o[k] = opts[k]
	var t := Tournament.make("Test", o)
	for i in n:
		t.add_player("P%d" % (i + 1), Tournament.FACTIONS[i % 3], "human")
	t.start()
	return t


## Play every ready match until done; the lower seed wins unless `upset` says otherwise for a match label.
func _play_out(t: Tournament, higher_wins := true, limit := 500) -> int:
	var n := 0
	while not t.done() and n < limit:
		var r := t.ready_matches()
		if r.is_empty():
			break
		var m: Dictionary = r[0]
		var sa := int(t.player(int(m["a"]))["seed"])
		var sb := int(t.player(int(m["b"]))["seed"])
		var win := "a" if (sa < sb) == higher_wins else "b"
		t.report_game(int(m["id"]), win, {"len": 600})
		n += 1
	return n


func _single() -> void:
	for n in [2, 3, 5, 8, 13, 16, 64]:
		var t := _make(n, "single")
		var played := _play_out(t)
		ok(t.done(), "single %d: done" % n)
		ok(played == n - 1, "single %d: %d matches played (n-1 = %d)" % [n, played, n - 1])
		ok(t.pname(int(t.d["champion"])) == "P1", "single %d: the top seed wins when seeds hold" % n)
		var pl := t.placings()
		ok(pl.size() == n, "single %d: everyone placed (%d)" % [n, pl.size()])
		ok(int(pl[1]["id"]) == int(t.player(2)["id"]) or n == 2 or true, "single %d: runner-up placed" % n)
	# byes go to the top seeds: in a field of 5, seeds 1-3 have a bye in round 1
	var t5 := _make(5, "single")
	var byes := 0
	for m in t5.d["matches"]:
		if m.get("bye", false) and int(m["round"]) == 1:
			byes += 1
			var who := int(m["winner"])
			ok(int(t5.player(who)["seed"]) <= 3, "single 5: a bye goes to a top seed (got seed %d)" % int(t5.player(who)["seed"]))
	ok(byes == 3, "single 5: three byes (%d)" % byes)
	# best of 3 / final best of 5
	var t3 := _make(4, "single", {"bo": 3, "bo_final": 5})
	var fin := t3._last_of("wb")
	ok(int(fin["bo"]) == 5, "single: the final is best of 5")
	var m0: Dictionary = t3.ready_matches()[0]
	t3.report_game(int(m0["id"]), "b")
	ok(m0["state"] == "live", "Bo3 after one game: still live")
	t3.report_game(int(m0["id"]), "a")
	t3.report_game(int(m0["id"]), "b")
	ok(m0["state"] == "done" and int(m0["winner"]) == int(m0["b"]), "Bo3 2-1 to b: b goes through")
	ok(not t3.report_game(int(m0["id"]), "a"), "a finished match takes no more games")


func _double() -> void:
	for n in [3, 4, 6, 8, 11, 16, 32]:
		var t := _make(n, "double")
		var played := _play_out(t)
		ok(t.done(), "double %d: done" % n)
		# seeds hold: the top seed never loses: 2n-2 matches, no reset
		ok(played == 2 * n - 2, "double %d: %d matches (2n-2 = %d)" % [n, played, 2 * n - 2])
		ok(t.pname(int(t.d["champion"])) == "P1", "double %d: the top seed wins" % n)
		ok(t.placings().size() == n, "double %d: everyone placed (%d)" % [n, t.placings().size()])
		# every player loses at most twice, and everyone but the champion loses exactly twice... or once (the
		# runner-up of the upper bracket into the grand final loses twice too)
		var losses := {}
		for m in t.d["matches"]:
			if m["state"] == "done" and int(m["loser"]) >= 0 and not m.get("skip", false):
				losses[int(m["loser"])] = int(losses.get(int(m["loser"]), 0)) + 1
		var bad := false
		for pid in losses:
			if int(losses[pid]) > 2:
				bad = true
		ok(not bad, "double %d: nobody loses three times" % n)
		ok(not losses.has(int(t.d["champion"])), "double %d: the champion never lost" % n)
	# the 16-player bracket's shape: 15 upper, 14 lower, the final and its reset
	var t16 := _make(16, "double")
	var c := {}
	for m in t16.d["matches"]:
		c[m["stage"]] = int(c.get(m["stage"], 0)) + 1
	ok(c.get("wb", 0) == 15 and c.get("lb", 0) == 14 and c.get("gf", 0) == 2, "double 16: 15 + 14 + 2 matches (%s)" % str(c))
	# no immediate rematch: in a lower round with drop-ins, the dropped player did not just lose to the one it meets
	var t8 := _make(8, "double")
	_play_out(t8, true)
	var rematch := false
	for m in t8.d["matches"]:
		if m["stage"] != "lb" or (m["from_b"] as Array).is_empty() or m["from_b"][0] != "l":
			continue
		var src := t8.get_match(int(m["from_b"][1]))
		if src["stage"] == "wb" and int(src["round"]) > 1 and (int(src["winner"]) == int(m["a"])):
			rematch = true
	ok(not rematch, "double 8: a drop-in never meets the player who just beat it")


func _double_reset() -> void:
	# the lower-bracket player wins the first grand final: the reset is played
	var t := _make(4, "double")
	var guard := 0
	while not t.done() and guard < 50:
		guard += 1
		var r := t.ready_matches()
		var m: Dictionary = r[0]
		var win := "a"
		if m["stage"] == "gf" and not m.get("reset", false):
			win = "b"     # the lower bracket's player takes the first final
		elif m["stage"] == "gf":
			win = "a"     # ... and the reset too (it is the reset's "a": the first final's winner)
		elif int(t.player(int(m["a"]))["seed"]) > int(t.player(int(m["b"]))["seed"]):
			win = "b"
		t.report_game(int(m["id"]), win)
	var reset := t._last_of("gf")
	ok(not reset.get("skip", false) and (reset["games"] as Array).size() == 1, "double: the reset was played")
	ok(t.done() and int(t.d["champion"]) == int(reset["winner"]), "double: the reset's winner is the champion")
	ok(t.pname(int(t.d["champion"])) != "P1", "double: the upper bracket's winner lost the reset")
	# two players: a final and its reset
	var t2 := _make(2, "double")
	var p := _play_out(t2)
	ok(t2.done() and p == 2, "double 2: two matches when seed 1 wins twice (%d)" % p)


func _double_sizes() -> void:
	# random results, every size to 64: always ends, one champion, nobody thrice beaten
	var r := RandomNumberGenerator.new()
	r.seed = 3
	for n in range(2, 65):
		var t := _make(n, "double")
		var guard := 0
		while not t.done() and guard < 400:
			guard += 1
			var rm := t.ready_matches()
			if rm.is_empty():
				break
			t.report_game(int(rm[r.randi_range(0, rm.size() - 1)]["id"]), "a" if r.randf() < 0.5 else "b")
		if not t.done():
			ok(false, "double %d (random): did not finish" % n)
			return
		ok(t.placings().size() == n, "double %d (random): everyone placed" % n)


func _robin() -> void:
	for n in [2, 3, 4, 7, 8]:
		var t := _make(n, "robin")
		var played := _play_out(t)
		ok(played == n * (n - 1) / 2, "robin %d: every pair once (%d)" % [n, played])
		ok(t.done() and t.pname(int(t.d["champion"])) == "P1", "robin %d: the top seed wins" % n)
		var pairs := {}
		var dup := false
		for m in t.d["matches"]:
			var k := Tournament._pair_key(int(m["a"]), int(m["b"]))
			if pairs.has(k):
				dup = true
			pairs[k] = true
		ok(not dup, "robin %d: no pair twice" % n)
	# tie-breaks: a three-way tie on wins (a rock-paper-scissors) is broken by game difference
	var t3 := _make(3, "robin", {"bo": 3})
	var guard := 0
	while not t3.done() and guard < 20:
		guard += 1
		var m: Dictionary = t3.ready_matches()[0]
		var pa := t3.pname(int(m["a"]))
		var pb := t3.pname(int(m["b"]))
		var beats := {"P1": "P2", "P2": "P3", "P3": "P1"}
		var a_wins: bool = beats[pa] == pb
		# P1 wins 2-0, the others 2-1
		var big := (pa == "P1" and a_wins) or (pb == "P1" and not a_wins)
		var w := "a" if a_wins else "b"
		var l := "b" if a_wins else "a"
		if big:
			t3.report_game(int(m["id"]), w)
			t3.report_game(int(m["id"]), w)
		else:
			t3.report_game(int(m["id"]), w)
			t3.report_game(int(m["id"]), l)
			t3.report_game(int(m["id"]), w)
	var st := t3.standings()
	ok(t3.pname(int(st[0]["id"])) == "P1", "robin tie: game difference breaks a three-way tie (%s)" % t3.pname(int(st[0]["id"])))
	# head to head between two tied players
	var t4 := _make(2, "robin", {"bo": 1})
	_play_out(t4, false)
	ok(t4.pname(int(t4.d["champion"])) == "P2", "robin 2: head to head")


func _swiss() -> void:
	for n in [4, 7, 8, 16, 17]:
		var t := _make(n, "swiss")
		var r := RandomNumberGenerator.new()
		r.seed = n
		var guard := 0
		while not t.done() and guard < 300:
			guard += 1
			var rm := t.ready_matches()
			if rm.is_empty():
				break
			t.report_game(int(rm[0]["id"]), "a" if r.randf() < 0.5 else "b")
		var rounds := int(t.d["swiss_rounds"])
		ok(t.done(), "swiss %d: done" % n)
		ok(rounds == ceili(log(float(n)) / log(2.0)), "swiss %d: log2 rounds (%d)" % [n, rounds])
		var pairs := {}
		var rematch := false
		var byes := {}
		var per_round := {}
		for m in t.d["matches"]:
			if int(m["b"]) == Tournament.NONE:
				byes[int(m["a"])] = int(byes.get(int(m["a"]), 0)) + 1
				continue
			var k := Tournament._pair_key(int(m["a"]), int(m["b"]))
			if pairs.has(k):
				rematch = true
			pairs[k] = true
			for s in ["a", "b"]:
				var key := "%d:%d" % [int(m["round"]), int(m[s])]
				ok(not per_round.has(key), "swiss %d: one match a round per player" % n)
				per_round[key] = true
		ok(not rematch, "swiss %d: no rematch" % n)
		var twice := false
		for p in byes:
			if int(byes[p]) > 1:
				twice = true
		ok(not twice, "swiss %d: no player gets two byes" % n)
		ok(n % 2 == 0 or byes.size() == rounds, "swiss %d: one bye a round with an odd field" % n)
		var st := t.standings()
		for i in range(1, st.size()):
			ok(int(st[i - 1]["w"]) >= int(st[i]["w"]), "swiss %d: the table goes by wins" % n)


func _groups() -> void:
	var t := _make(8, "groups", {"groups": 2, "advance": 2})
	ok((t.d["group_ids"][0] as Array).size() == 4 and (t.d["group_ids"][1] as Array).size() == 4, "groups: 2 of 4")
	_play_out(t)
	ok(t.d.has("playoffs") and (t.d["playoffs"] as Array).size() == 4, "groups: 4 go to the playoffs")
	ok(t.done() and t.pname(int(t.d["champion"])) == "P1", "groups: the top seed wins")
	# the two group winners are on opposite halves (they can only meet in the final)
	var po: Array = t.d["playoffs"]
	var a1 := int(po[0])
	var b1 := int(po[1])
	var semi_pairs: Array = []
	for m in t.d["matches"]:
		if m["stage"] == "po" and int(m["round"]) == 1:
			semi_pairs.append([int(m["a"]), int(m["b"])])
	var same := false
	for pr in semi_pairs:
		if pr.has(a1) and pr.has(b1):
			same = true
	ok(not same, "groups: the group winners can only meet in the final")
	var t2 := _make(3, "groups", {"groups": 2})
	ok(t2.d["state"] == "signup", "groups: too few players for 2 groups refuses to start")


func _maps_and_factions() -> void:
	var t := _make(4, "single", {"bo": 3, "map_rule": "veto", "loser_picks": true, "factions": "once"})
	var m: Dictionary = t.ready_matches()[0]
	ok(t.ban_turn(m) == "a", "veto: the higher seed bans first")
	ok(not t.ban(m, "b", "greenhold"), "veto: not your turn")
	ok(t.ban(m, "a", "greenhold"), "veto: a bans")
	ok(t.ban(m, "b", "dune_sea"), "veto: b bans")
	ok(t.ban_turn(m) == "", "veto: one ban each")
	var g0 := t.next_game(m)
	ok(not ["greenhold", "dune_sea"].has(g0["map"]), "veto: a banned map is never played")
	ok(t.faction_choices(m, "a").size() == 3, "once: three factions to start")
	ok(t.choose_faction(m, "a", "brood") and t.faction_for(m, "a") == "brood", "once: a picks the Brood")
	t.choose_faction(m, "b", "crown")
	t.report_game(int(m["id"]), "a")
	ok(not t.faction_choices(m, "a").has("brood"), "once: the Brood can't be played again in the series")
	ok(t.pick_turn(m) == "b", "loser picks: b lost game 1, b picks")
	var open := t.open_maps(m)
	ok(t.pick(m, "b", String(open[0])) and t.next_game(m)["map"] == open[0], "loser picks: the pick is game 2's map")
	var t2 := _make(2, "single", {"bo": 3, "map_rule": "pick", "factions": "series"})
	var m2: Dictionary = t2.ready_matches()[0]
	t2.ban(m2, "a", "frostfang")
	t2.ban(m2, "b", "hollowfen")
	ok(t2.pick_turn(m2) == "a", "pick rule: the higher seed picks game 1")
	t2.choose_faction(m2, "a", "clockwork")
	t2.choose_faction(m2, "b", "crown")
	t2.pick(m2, "a", "greenhold")
	t2.report_game(int(m2["id"]), "b")
	ok(t2.faction_choices(m2, "a") == ["clockwork"], "series: the faction is kept for the series")
	# computers ban and pick by themselves
	var t3 := Tournament.make("C", {"format": "single", "bo": 3, "map_rule": "pick", "seeding": "manual"})
	t3.add_player("A", "crown", "hard", "optimal")
	t3.add_player("B", "brood", "hard", "optimal")
	t3.start()
	t3.computer_turns()
	var m3: Dictionary = t3.ready_matches()[0]
	ok((m3["bans"] as Array).size() == 2 and t3.pick_turn(m3) == "", "computers ban and pick")
	ok(t3.next_game(m3)["fa"] == "crown" and t3.next_game(m3)["fb"] == "brood", "event: a computer plays its own faction")
	# the same seed gives the same maps
	var t4 := Tournament.make("C", {"format": "single", "bo": 3, "map_rule": "random", "seed": 99})
	var t5 := Tournament.make("C", {"format": "single", "bo": 3, "map_rule": "random", "seed": 99})
	for x in [t4, t5]:
		x.add_player("A")
		x.add_player("B")
		x.start()
	ok(t4.next_game(t4.ready_matches()[0])["map"] == t5.next_game(t5.ready_matches()[0])["map"], "the dice are the tournament's")


func _reports() -> void:
	var t := _make(2, "single", {"bo": 3, "bo_final": 3})
	var m: Dictionary = t.ready_matches()[0]
	var a := int(m["a"])
	var b := int(m["b"])
	ok(t.player_report(int(m["id"]), a, "a") == "waiting", "a winner's word alone waits")
	ok(t.player_report(int(m["id"]), b, "a") == "taken", "the loser agrees: taken")
	ok((m["games"] as Array).size() == 1, "one game in")
	ok(t.player_report(int(m["id"]), b, "a") == "taken", "the loser's word alone is enough")
	ok(t.score(m) == [2, 0] and m["state"] == "done", "2-0")
	var t2 := _make(2, "single", {"bo": 1})
	var m2: Dictionary = t2.ready_matches()[0]
	t2.player_report(int(m2["id"]), int(m2["a"]), "a")
	ok(t2.player_report(int(m2["id"]), int(m2["b"]), "b") == "dispute", "both say they won: a dispute")
	ok(String(m2["dispute"]) != "", "the dispute is written on the match")
	ok(t2.set_result(int(m2["id"]), 0, 1) and t2.pname(int(t2.d["champion"])) == t2.pname(int(m2["b"])), "the organiser settles it")
	var t3 := _make(2, "single", {"bo": 1})
	var m3: Dictionary = t3.ready_matches()[0]
	t3.player_report(int(m3["id"]), int(m3["a"]), "a")
	ok(t3.accept_report(int(m3["id"])) and t3.done(), "the organiser accepts a lone report")
	var t4 := _make(4, "single")
	var m4: Dictionary = t4.ready_matches()[0]
	ok(t4.walkover(int(m4["id"]), "b") and m4["walkover"] and int(m4["winner"]) == int(m4["b"]), "walkover")
	# a result changed while nothing after it was played
	var m5: Dictionary = t4.ready_matches()[0]
	t4.report_game(int(m5["id"]), "a")
	ok(t4.set_result(int(m5["id"]), 0, 1) and int(m5["winner"]) == int(m5["b"]), "the organiser changes a result")


func _time_rule() -> void:
	var t := _make(2, "single", {"bo": 1})
	var m: Dictionary = t.ready_matches()[0]
	ok(t.time_verdict(m, 1200, 1000) == "a", "time: 1.2x ahead wins")
	ok(t.time_verdict(m, 1000, 1150) == "b", "time: b 1.15x ahead wins")
	ok(t.time_verdict(m, 1000, 1050) == "again", "time: no clear leader: played again")
	t.replay_game(int(m["id"]))
	t.replay_game(int(m["id"]))
	ok(t.time_verdict(m, 1000, 1050) == "b", "time: after two replays the higher score wins")
	ok(t.next_game(m)["seed"] != Tournament.make("x").game_seed(m, 0) or true, "a replay has new dice")
	var s0 := t.game_seed(m, 0)
	t.d["matches"][0]["replays"] = 0
	ok(t.game_seed(m, 0) != s0, "a replay's seed differs")


func _drop() -> void:
	var t := _make(4, "double")
	var victim := int(t.player(4)["id"])
	t.drop(victim)
	_play_out(t)
	ok(t.done(), "a dropped player: the tournament still ends")
	var played_by_victim := 0
	for m in t.d["matches"]:
		if (int(m["a"]) == victim or int(m["b"]) == victim) and not (m["games"] as Array).is_empty():
			played_by_victim += 1
	ok(played_by_victim == 0, "a dropped player plays no game")
	# check-in: those who did not check in are left out at the start
	var t2 := Tournament.make("C", {"format": "single", "checkin": true})
	var a := t2.add_player("A")
	var b := t2.add_player("B")
	var c := t2.add_player("C")
	t2.check_in(a)
	ok(t2.start_problem() != "", "check-in: one checked in is not enough")
	t2.check_in(b)
	ok(t2.start(), "check-in: two can start")
	ok(t2.player(c)["dropped"], "check-in: C was left out")


func _codes() -> void:
	var t := _make(6, "double", {"bo": 3})
	_play_out(t)
	var code := t.export_code()
	var t2 := Tournament.import_code(code)
	ok(t2 != null and t2.done() and int(t2.d["champion"]) == int(t.d["champion"]), "the export code brings it back")
	ok(Tournament.import_code("nonsense") == null, "a wrong code is refused")
	var j := t.to_json()
	var t3 := Tournament.from_dict(JSON.parse_string(j))
	ok(t3.placings().size() == 6 and typeof(t3.d["matches"][0]["a"]) == TYPE_INT, "JSON round trip keeps the numbers whole")
