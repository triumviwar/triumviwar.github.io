extends SceneTree
## TOURNAMENT, FROM THE COMMAND LINE (job tournament, docs/tournament.md, docs/championship_sim.md): the in-game
## Tournament's bracket driven by a script, for the ALL-COMPUTER championship simulation (tools/study/championship_sim.py
## plays each game with tools/qa_match.gd and tells the result back here). One call, one step:
##   godot --headless --script res://tools/tournament_cli.gd -- cmd:new file:/abs/t.json cfg:/abs/cfg.json
##   godot --headless --script res://tools/tournament_cli.gd -- cmd:next file:/abs/t.json      (prints GAME {...} lines)
##   godot --headless --script res://tools/tournament_cli.gd -- cmd:result file:/abs/t.json mid:3 gi:0 \
##       winner:<slot or -1> s0:<score slot 0> s1:<score slot 1> len:<seconds> map:<id> swap:0|1 replay:<name>
##   godot --headless --script res://tools/tournament_cli.gd -- cmd:show file:/abs/t.json     (prints the bracket)
## cfg.json: {"name", "format", "bo", "bo_final", "maps", "map_rule", "loser_picks", "factions", "seed", "seeding",
##   "time_limit", "players": [{"name", "faction", "who", "plan"}]}.

var args := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split(":", true, 1)
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	var out := 0
	match String(args.get("cmd", "")):
		"new":
			out = _new()
		"next":
			out = _next()
		"result":
			out = _result()
		"show":
			out = _show()
		_:
			print("ERROR unknown cmd")
			out = 1
	quit(out)


func _load() -> Tournament:
	return Tournament.load_from(String(args["file"]))


func _write(t: Tournament) -> void:
	var f := FileAccess.open(String(args["file"]), FileAccess.WRITE)
	f.store_string(JSON.stringify(t.d, " "))


func _new() -> int:
	var cfg = JSON.parse_string(FileAccess.get_file_as_string(String(args["cfg"])))
	if not (cfg is Dictionary):
		print("ERROR bad cfg")
		return 1
	var opts := {}
	for k in ["format", "bo", "bo_final", "maps", "map_rule", "loser_picks", "factions", "seeding", "time_limit", "seed", "groups", "advance", "swiss_rounds"]:
		if cfg.has(k):
			opts[k] = cfg[k]
	opts["mode"] = "computer"
	var t := Tournament.make(String(cfg.get("name", "Championship")), Tournament._ints(opts))
	for p in cfg["players"]:
		t.add_player(String(p["name"]), String(p.get("faction", "random")), String(p.get("who", "hard")), String(p.get("plan", "optimal")))
	if not t.start():
		print("ERROR ", t.start_problem())
		return 1
	t.computer_turns()
	_write(t)
	print("OK started ", t.d["matches"].size(), " matches")
	return 0


func _next() -> int:
	var t := _load()
	t.computer_turns()
	_write(t)
	if t.done():
		print("DONE ", JSON.stringify({"champion": t.d["champion"], "name": t.pname(int(t.d["champion"]))}))
		return 0
	for m in t.ready_matches():
		var ng := t.next_game(m)
		var gi: int = ng["game"]
		var pa := t.player(int(m["a"]))
		var pb := t.player(int(m["b"]))
		var swap := t.swap_spots(m, gi)
		var sa := [ng["fa"], String(pa["plan"]), String(pa["who"])]
		var sb := [ng["fb"], String(pb["plan"]), String(pb["who"])]
		print("GAME ", JSON.stringify({"mid": m["id"], "gi": gi, "map": ng["map"], "seed": ng["seed"], "swap": swap,
			"slots": [sb, sa] if swap else [sa, sb], "a": pa["name"], "b": pb["name"], "label": t.match_label(m),
			"replays": int(m.get("replays", 0)), "end": int(t.d.get("time_limit", 1200))}))
	return 0


func _result() -> int:
	var t := _load()
	var m := t.get_match(int(args["mid"]))
	if m.is_empty() or m["state"] == "done" or (m["games"] as Array).size() != int(args["gi"]):
		print("STALE")
		return 0
	var swap := String(args.get("swap", "0")) == "1"
	var w := int(args.get("winner", "-1"))
	var s0 := float(args.get("s0", "0"))
	var s1 := float(args.get("s1", "0"))
	var sa := s1 if swap else s0
	var sb := s0 if swap else s1
	var info := {"len": int(args.get("len", "0")), "map": String(args.get("map", "")), "replay": String(args.get("replay", "")),
		"seed": int(args.get("seed", "0")), "sa": int(sa), "sb": int(sb)}
	var nx := t.next_game(m)
	info["fa"] = nx["fa"]
	info["fb"] = nx["fb"]
	var win := ""
	if w >= 0:
		win = ("b" if w == 0 else "a") if swap else ("a" if w == 0 else "b")
		info["how"] = "played"
	else:
		var v := t.time_verdict(m, sa, sb)
		if v == "again":
			t.replay_game(int(m["id"]))
			_write(t)
			print("AGAIN")
			return 0
		win = v
		info["how"] = "time"
	t.report_game(int(m["id"]), win, info)
	t.computer_turns()
	_write(t)
	print("TAKEN ", win)
	return 0


func _show() -> int:
	var t := _load()
	for m in t.d["matches"]:
		var sc := t.score(m)
		print("%3d %-24s %-18s %d-%d %-18s %s %s" % [m["id"], t.match_label(m), t.pname(int(m["a"])), sc[0], sc[1], t.pname(int(m["b"])),
			m["state"], ("-> " + t.pname(int(m["winner"]))) if m["state"] == "done" else ""])
	if t.done():
		print("CHAMPION ", t.pname(int(t.d["champion"])))
		for p in t.placings():
			print("  %d. %s" % [p["place"], t.pname(int(p["id"]))])
	return 0
