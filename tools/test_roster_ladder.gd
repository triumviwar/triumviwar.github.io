extends SceneTree
## THE ROSTER LADDER (docs/campaign_roster_ladder.md): every BUILT mission's player roster matches the doc's CHECKED TABLE.
##   - the table is read from the doc (one row per step: the mission, the bound teams, the NEW pieces, the allow-list);
##   - for each row whose mission is in campaign/missions: each bound team's roster "allow" is the row's allow-list (as a
##     set), its "new" the row's NEW pieces, every name is a piece the engine knows (Campaign.roster_known), and a NEW
##     card (a line of the speaker "new", said to the ladder side) is there for each NEW piece, with pt and es;
##   - each ladder's allow-lists only grow, step by step (a piece once given is never taken away by the ladder);
##   - LIVE: each built mission started solo: for the bound team, every piece of its faction is refused ("Not in this
##     mission.") exactly when it is off the allow-list (the story's own deny on top), and the refusals reach the
##     places the player meets them: a building (Game.requirement_text), a unit at its building (Game.can_train), a
##     research (Game.research_problem / BroodResearch), the Brood's grub morph, the Mother's eggs and her GROW.
##   godot --headless --fixed-fps 30 --script res://tools/test_roster_ladder.gd
## Prints CHECK lines, then "roster_ladder: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const DOC := "res://docs/campaign_roster_ladder.md"
var main: Node
var fails := 0
var _kept := ""


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-74s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	if FileAccess.file_exists(Campaign.PROGRESS):
		_kept = FileAccess.get_file_as_string(Campaign.PROGRESS)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _finish() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	if _kept != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept)
		f.close()
	print("roster_ladder: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The CHECKED TABLE's rows: [{step, mission, teams, new, with, allow, faction}] (the faction from the step's letter).
func _table() -> Array:
	var out: Array = []
	var txt := FileAccess.get_file_as_string(DOC)
	var on := false
	for line in txt.split("\n"):
		if line.begins_with("## THE CHECKED TABLE"):
			on = true
			continue
		if on and line.begins_with("## "):
			break
		if not on or not line.begins_with("| ") or line.begins_with("| step") or line.begins_with("| ---"):
			continue
		var c := line.split("|")
		if c.size() < 8:
			continue
		var words := func(s: String) -> Array:
			var a: Array = []
			for w in s.strip_edges().split(" ", false):
				if w != "-":
					a.append(w)
			return a
		var step := String(c[1]).strip_edges()
		out.append({"step": step, "mission": String(c[2]).strip_edges(), "teams": words.call(c[3]), "new": words.call(c[4]),
			"with": words.call(c[5]), "allow": words.call(c[6]),
			"faction": {"C": "crown", "K": "clockwork", "B": "brood"}.get(step.left(1), "")})
	return out


func _minus(a: Array, b: Array) -> Array:
	var out: Array = []
	for x in a:
		if not b.has(x):
			out.append(x)
	return out


func _same(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for x in a:
		if not b.has(x):
			return false
	return true


func _run() -> void:
	var rows := _table()
	var facs: Array = rows.map(func(r): return r["faction"])
	check("the doc's CHECKED TABLE is there (three ladders)", rows.size() >= 20 and facs.has("crown") and facs.has("clockwork") and facs.has("brood"), "%d rows" % rows.size())
	# ---- each ladder only grows; a step's allow-list is the one before plus its own pieces
	var prev := {}
	for r in rows:
		var f: String = r["faction"]
		var before: Array = prev.get(f, [])
		var lost := _minus(before, r["allow"])
		var extra := _minus(r["allow"], before)
		var own: Array = (r["new"] as Array) + (r["with"] as Array)
		var first := before.is_empty()
		check("%s: the ladder only grows (nothing taken away)" % r["step"], lost.is_empty(), str(lost))
		check("%s: what it adds is its NEW pieces and what comes with them" % r["step"], first or _same(extra, own), "%s v %s" % [extra, own])
		var unknown := _minus(r["allow"], Campaign.roster_items(f))
		check("%s: every piece is one of the %s's" % [r["step"], f], unknown.is_empty(), str(unknown))
		prev[f] = r["allow"]
	# ---- the built missions' data
	var built: Array = []
	for r in rows:
		var mid: String = r["mission"]
		if mid == "(slot)" or not FileAccess.file_exists("res://campaign/missions/%s.json" % mid):
			continue
		built.append(r)
		var m := Campaign.mission(mid)
		var pr := Campaign.problems(m)
		check("%s: data checks out" % mid, pr.is_empty(), "; ".join(pr))
		for tid in r["teams"]:
			var tm: Dictionary = {}
			for t in m["teams"]:
				if String(t["id"]) == tid:
					tm = t
			check("%s: team %s is there, of the %s" % [mid, tid, r["faction"]], not tm.is_empty() and Campaign.engine_faction(m, String(tm.get("faction", ""))) == r["faction"])
			var ros: Dictionary = tm.get("roster", {})
			var have: Array = ros.get("allow", [])
			check("%s: team %s's allow-list is the table's" % [mid, tid], _same(have, r["allow"]),
				"extra %s, missing %s" % [_minus(have, r["allow"]), _minus(r["allow"], have)])
			check("%s: team %s's NEW pieces are the table's" % [mid, tid], _same(ros.get("new", []), r["new"]), "%s" % [ros.get("new", [])])
		# the NEW card: one line of the speaker "new" per new piece (the Venom Challenger shares the Tyrant's), to one side
		var cards: Array = []
		for k in m["lines"]:
			if String(m["lines"][k].get("who", "")) == "new":
				cards.append(k)
		var want: Array = []
		for k in r["new"]:
			if k != "venom_challenger":
				want.append("new_" + k)
		check("%s: a NEW card per new piece" % mid, _same(cards, want), "%s" % [cards])
		var side := String(m["speakers"].get("new", {}).get("side", ""))
		var to_side := side != ""
		for k in cards:
			if String(m["lines"][k].get("to", "")) != side:
				to_side = false
		check("%s: the cards go to the ladder side only" % mid, to_side)
		var early := false
		for tr in m["triggers"]:
			if String(tr["id"]) == "ladder_new" and float(tr["when"].get("time", 999)) <= 10.0 and _same(tr["do"][0]["say"], cards):
				early = true
		check("%s: the cards are said early" % mid, early)
		var miss: Array = []
		for k in cards:
			var tx := String(m["lines"][k]["text"])
			if not LangPt.T.has(tx) or not LangEs.T.has(tx):
				miss.append(k)
		check("%s: the cards have pt and es" % mid, miss.is_empty(), str(miss))
	var names: Array = built.map(func(r): return r["mission"])
	check("the seven built missions are on the ladder", _minus(["p01_leaf", "c01_thirteenth", "b01_specimen", "a02_furth", "a03_plateau", "a01_presses", "a06_barricades"], names).is_empty())
	# ---- LIVE: each built mission started, its bound team refused exactly what is off its list
	for r in built:
		await _live(r)
	_finish()


func _start(mid: String) -> Game:
	if main.game:
		main._to_menu()
		await process_frame
	for n in main.ui_layer.get_children():
		if n.name == "MissionEnd" or n is StillShow:
			n.queue_free()
	main.start(Campaign.make_cfg(mid, "solo"))
	await process_frame
	await process_frame
	paused = false
	return main.game


func _live(r: Dictionary) -> void:
	var mid: String = r["mission"]
	var g: Game = await _start(mid)
	var mr: MissionRun = g.mission
	check("%s: started" % mid, mr != null)
	if mr == null:
		return
	var m: Dictionary = mr.data
	for tid in r["teams"]:
		var t := mr.team_index(tid)
		var tm := mr.team_data(t)
		var story: Array = tm.get("roster", {}).get("deny", [])
		var wrong: Array = []
		for k in Campaign.roster_items(r["faction"]):
			var off := not (r["allow"] as Array).has(k) or story.has(k)
			if mr.denied(t, k) != off:
				wrong.append(k)
		check("%s: %s refused exactly what is off its list" % [mid, tid], wrong.is_empty(), str(wrong))
		_gates(g, mr, t, r)


## The refusals reach the player's buttons (one piece of each kind the step leaves out, when it has one).
func _gates(g: Game, mr: MissionRun, t: int, r: Dictionary) -> void:
	var mid: String = r["mission"]
	var f: String = r["faction"]
	var allow: Array = r["allow"]
	var NOT := "Not in this mission."
	var off_b := ""
	var on_b := ""
	for k in Campaign.roster_items(f):
		if Defs.BUILDINGS.has(k) and not Defs.retired(k):
			if not allow.has(k) and off_b == "":
				off_b = k
			elif allow.has(k) and on_b == "" and k != "town_hall" and k != "clocktower":
				on_b = k
	if off_b != "":
		check("%s: a building off the list is refused (%s)" % [mid, off_b], g.requirement_text(t, off_b) == NOT)
	if on_b != "":
		check("%s: a building on the list is not refused for the roster (%s)" % [mid, on_b], g.requirement_text(t, on_b) != NOT)
	# a unit at a building the team has
	for b in g.buildings:
		if b.dead or b.team != t:
			continue
		for k in (Defs.BUILDINGS[b.kind].get("trains", []) as Array):
			if not Defs.UNITS.has(k):
				continue
			var why := g.can_train(b, k)
			check("%s: %s at the %s: refused for the roster only when off the list" % [mid, k, b.kind],
				(why == NOT) == (not allow.has(k) or mr.denied(t, k)), why)
	# a research: the first of the faction's that is off the list
	for k in Defs.RESEARCH:
		if String(Defs.RESEARCH[k].get("faction", "")) != f or allow.has(k):
			continue
		if f == "brood":
			continue      # (checked below through her card)
		var at: Building = null
		for b in g.buildings:
			if not b.dead and b.team == t and b.kind == String(Defs.RESEARCH[k]["at"]) and b.built:
				at = b
		if at:
			check("%s: research %s refused" % [mid, k], g.research_problem(at, k) == NOT)
		break
	if f != "brood":
		return
	var q := BroodNew.queen(g, t)
	check("%s: the Brood team has its Mother" % mid, q != null)
	if q == null:
		return
	for k in ["dilophosaurus", "pterodactyl", "tyrannosaur"]:
		var why := BroodRoot.morph_problem(g, t, k)
		check("%s: a grub into the %s: refused only when off the list" % [mid, k], (why == NOT) == mr.denied(t, k), why)
	for k in ["raptor", "spitter", "hatchlings", "brute", "mist_toad"]:
		if not BroodNew.hatch_list().has(k):
			continue
		var why := BroodNew.lay_problem(g, q, k)
		check("%s: her %s egg: refused only when off the list" % [mid, k], (why == NOT) == mr.denied(t, k), why)
	var gw := BroodNew.grow_problem(g, q)
	check("%s: GROW to stage 2: refused only when off the list" % mid, (gw == NOT) == mr.denied(t, "stage2"), gw)
	var rq := BroodResearch.problem(g, q, "nb_quick_roots")
	check("%s: her research Quick Roots refused (off every Act 1 list)" % mid, rq == NOT or rq == "Can't research that here." , rq)
