extends SceneTree
## The campaign engine (docs/campaign_engine.md): every mission's data checks out (Campaign.problems), every campaign
## text has its Portuguese and Spanish, the setups for solo / co-op / versus seat the right players, and the test
## mission plays: the start is laid out, the triggers fire (lines, a counter-attack, reinforcements, a hurt hall), the
## mission is won (the rebels' hall burned: the storylines open), lost (the captain killed) and won by the other side
## (versus: the rebels hold out). The hub's talks change after the mission. Since campaign-m1 the engine's test mission
## p01_revolt is no longer in the storylines (the prologue is p01_leaf: tools/test_campaign_m1.gd); it stays as the
## engine's test bed.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign.gd
## Prints CHECK lines, then "campaign: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
var main: Node
var fails := 0
var _kept := ""


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-64s %s %s" % [name, "ok" if ok else "FAIL", detail])
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
	print("campaign: %d failures" % fails)
	quit(1 if fails > 0 else 0)


func _data() -> void:
	for id in Campaign.mission_ids() + ["p01_revolt"]:
		var pr := Campaign.problems(Campaign.mission(id))
		check("mission %s: data checks out" % id, pr.is_empty(), "; ".join(pr))
	var texts: Array = Campaign.index_strings()
	for id in Campaign.mission_ids() + ["p01_revolt"]:
		texts.append_array(Campaign.strings_of(Campaign.mission(id)))
	var miss: Array = []
	for t in texts:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every campaign text has pt and es", miss.is_empty(), " | ".join(miss))
	# the briefing's objectives never show a raw "{counter}" or "{clock:name}" (CampaignMenu.brief_fill; playtest 2026-11-21)
	var raw: Array = []
	for id in Campaign.mission_ids():
		var m := Campaign.mission(id)
		for o in m.get("objectives", []):
			var bt := CampaignMenu.brief_fill(m, String(o["text"]))
			if bt.find("{") >= 0 or bt.find("}") >= 0:
				raw.append(id + ": " + bt.left(60))
	check("the briefings' objectives: no raw {placeholders}", raw.is_empty(), " | ".join(raw))
	var a06 := Campaign.mission("a06_barricades")
	var pt := CampaignMenu.brief_fill(a06, "{taken} of {taken.of}, {clock:patience}")
	check("brief_fill: a06's barricades and the King's patience", pt.begins_with("0 of 3, ") and pt.find(":") > 0 and pt.find("…") < 0, pt)
	# who sits where
	var c := Campaign.make_cfg("p01_revolt", "solo")
	check("solo: you, scripted horse, scripted rebels", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script"], str(c["slots"].map(func(s): return s["who"])))
	c = Campaign.make_cfg("p01_revolt", "coop", "p1", true)
	check("co-op online: you, friend, scripted rebels", c["slots"].map(func(s): return s["who"]) == ["you", "remote", "script"])
	c = Campaign.make_cfg("p01_revolt", "versus", "p1", true)
	check("versus online: you (crown), scripted horse, friend (rebels)", c["slots"].map(func(s): return s["who"]) == ["you", "script", "remote"])
	c = Campaign.make_cfg("p01_revolt", "versus", "p2", true)
	check("versus online, host plays the rebels", c["slots"].map(func(s): return s["who"]) == ["remote", "script", "you"])
	check("crown and rebels on opposite sides", c["slots"][0]["side"] != c["slots"][2]["side"] and c["slots"][0]["side"] == c["slots"][1]["side"])
	# a campaign-only faction plays its stand-in until it exists
	check("campaign-only faction -> stand-in", Campaign.engine_faction({"factions": {"tribes": {"stand_in": "crown"}}}, "tribes") == "crown")
	check("all three prologues are open at first (owner 2026-11-18), the Crown marked Start here", Campaign.unlocked("p01_leaf") and Campaign.unlocked("b01_specimen") and Campaign.unlocked("c01_thirteenth") and bool(Campaign.storylines()[0].get("start", false)))


func _start(mode: String, seat := "p1") -> Game:
	main.start(Campaign.make_cfg("p01_revolt", mode, seat))
	await process_frame
	await process_frame
	paused = false
	return main.game


const E0 := "x_engine0"


## ACT 1's ENGINE STEP 0 (act1-engine0, docs/act1_engine0.md): a copy of the test mission with every new key, kept in
## Campaign's cache only (never a file): "if" on units, the difficulty (its condition, spawns, countdowns), the solo side
## pick, STAY, NEAR, ROUTE, FOLLOW, SLEEP / WAKE, MIST, CAPTURE.
func _engine0_mission() -> Dictionary:
	var m: Dictionary = Campaign.mission("p01_revolt").duplicate(true)
	m["id"] = E0
	m["solo_sides"] = ["crown", "rebels"]
	m["difficulty"] = {"easy": {"clocks": 1.25, "spawns": 0.75}}
	m["units"].append({"team": "rebels", "kind": "musketeer", "count": 2, "at": "village", "tag": "easy_only", "if": {"difficulty": "easy"}})
	m["units"].append({"team": "rebels", "kind": "musketeer", "count": 2, "at": "village", "tag": "hard_only", "if": {"difficulty": "hard"}})
	m["units"].append({"team": "rebels", "kind": "musketeer", "count": 4, "at": "village", "tag": "kept", "fixed": true, "order": "hold"})
	m["objectives"] = (m["objectives"] as Array).filter(func(o) -> bool: return String(o["id"]) != "ringleader")
	m["objectives"].append({"id": "escape", "side": "crown", "primary": false, "kind": "countdown", "clock": "escape", "text": "x"})
	m["objectives"].append({"id": "hold_ford", "side": "crown", "primary": false, "kind": "reach", "area": "ford", "side_units": "crown", "count": 3, "secs": 5, "text": "x"})
	m["objectives"].append({"id": "take", "side": "crown", "primary": false, "kind": "capture", "tag": "ringleader", "share": 0.25, "within": 3, "text": "x"})
	m["triggers"] = (m["triggers"] as Array).filter(func(t) -> bool: return String(t["id"]) != "ringleader_down")
	for tr in m["triggers"]:
		if String(tr["id"]) == "intro_rebels":
			# (the rebels' own lines whenever a person leads them: versus, or solo with the side picked)
			tr.erase("modes")
			tr["when"] = {"all": [{"time": 1}, {"playing": "rebels"}]}
	m["triggers"].append({"id": "clocks", "when": {"time": 1}, "do": [{"clock": {"name": "escape", "secs": 100}}, {"clock": {"name": "timer", "secs": 100}}]})
	m["triggers"].append({"id": "easy_said", "when": {"difficulty": ["easy"]}, "do": [{"flag": {"easy": 1}}]})
	m["triggers"].append({"id": "crown_played", "when": {"playing": "crown"}, "do": [{"flag": {"crown_played": 1}}]})
	m["triggers"].append({"id": "stayed", "when": {"stay": {"tag": "column_foot", "area": "ford", "count": 3, "secs": 5}}, "do": [{"flag": {"stayed": 1}}]})
	return m


func _engine0() -> void:
	var path := "%s/missions/%s.json" % [Campaign.DIR, E0]
	Campaign._cache[path] = _engine0_mission()
	var m := Campaign.mission(E0)
	var pr := Campaign.problems(m)
	check("engine0: the test mission's new keys check out", pr.is_empty(), "; ".join(pr))
	var bad: Dictionary = m.duplicate(true)
	bad["solo_sides"] = ["nobody"]
	bad["difficulty"] = {"brutal": {"clocks": 2}}
	bad["units"].append({"team": "rebels", "kind": "musketeer", "at": "village", "if": {"stay": {"tag": "x", "area": "nowhere"}}})
	bad["triggers"].append({"id": "b", "when": {"difficulty": "silly"}, "do": [{"order": {"tag": "x", "do": "route", "route": ["nowhere"]}},
		{"sleep": {"team": "nobody"}}, {"mist": {"side": "crown"}}, {"weather": "mist"}]})
	bad["objectives"].append({"id": "c", "side": "crown", "kind": "capture", "text": "x"})
	var bp := Campaign.problems(bad)
	for want in ["solo_sides: unknown side", "difficulty: unknown level", "stay in unknown area", "unknown difficulty", "route through unknown area", "of unknown team", "mist needs", "a capture needs a tag"]:
		check("engine0: problems() catches '%s'" % want, bp.any(func(x: String) -> bool: return x.contains(want)), "; ".join(bp))
	check("engine0: weather mist is known", not bp.any(func(x: String) -> bool: return x.contains("unknown weather")))
	# the SOLO SIDE PICK: the seats
	check("engine0: the sides a solo player may lead", Campaign.solo_sides(m) == ["crown", "rebels"], str(Campaign.solo_sides(m)))
	check("engine0: a side the mission doesn't offer falls back", Campaign.solo_side(m, "nobody") == "crown" and Campaign.solo_side(Campaign.mission("p01_leaf"), "rebels") == "crown")
	var c := Campaign.make_cfg(E0, "solo", "p1", false, "rebels")
	check("engine0: solo as the rebels: column scripted, rebels yours", c["slots"].map(func(s): return s["who"]) == ["script", "script", "you"] and c["campaign"]["side"] == "rebels", str(c["slots"].map(func(s): return s["who"])))
	c = Campaign.make_cfg(E0, "solo")
	check("engine0: solo by default: the mission's own side", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script"] and c["campaign"]["side"] == "crown")
	check("engine0: the setup carries the difficulty", String(c["campaign"].get("difficulty", "")) == "normal")
	# the DIFFICULTY: kept in the progress, the prologues' values
	Campaign.set_difficulty("easy")
	check("engine0: difficulty kept", Campaign.difficulty() == "easy" and String(Campaign.make_cfg(E0, "solo")["campaign"]["difficulty"]) == "easy")
	Campaign.set_difficulty("silly")
	check("engine0: an unknown difficulty is refused", Campaign.difficulty() == "easy")
	for pid in ["p01_leaf", "c01_thirteenth", "b01_specimen"]:
		var pm := Campaign.mission(pid)
		check("engine0: %s has its difficulty" % pid, pm.has("difficulty") and float(Campaign.diff_mult(pm, "easy")["spawns"]) < 1.0 and float(Campaign.diff_mult(pm, "hard")["spawns"]) > 1.0 and is_equal_approx(float(Campaign.diff_mult(pm, "normal")["spawns"]), 1.0))
	check("engine0: c01's countdown is longer on easy", float(Campaign.diff_mult(Campaign.mission("c01_thirteenth"), "easy")["clocks"]) > 1.0)
	# BRUTAL (the owner 2026-11-28): HARD's numbers and a little more, the mission's rules read "hard", the foes cheat
	var c01 := Campaign.mission("c01_thirteenth")
	var hm := Campaign.diff_mult(c01, "hard")
	var bm := Campaign.diff_mult(c01, "brutal")
	check("brutal: shorter clocks and more foes than hard", float(bm["clocks"]) < float(hm["clocks"]) and float(bm["spawns"]) > float(hm["spawns"]), "%s v %s" % [bm, hm])
	check("brutal: a mission's rules read it as hard", Campaign.level("brutal") == "hard" and Campaign.cond_before({"difficulty": "hard"}, "", "brutal"))
	Campaign.set_difficulty("brutal")
	var bc := Campaign.make_cfg("b01_specimen", "solo")
	var ai_slots: Array = bc["slots"].filter(func(s): return not ["you", "script", "remote"].has(String(s["who"])))
	check("brutal: kept, and every computer foe cheats", Campaign.difficulty() == "brutal" and not ai_slots.is_empty() and ai_slots.all(func(s): return float(s.get("cheat", 1.0)) > 1.0), str(bc["slots"]))
	Campaign.set_difficulty("easy")
	# ---------------------------------------------------------------- play it on EASY, as the Crown
	main._to_menu()
	main.start(Campaign.make_cfg(E0, "solo"))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	check("engine0: the run knows its difficulty and side", r.difficulty == "easy" and r.solo_side == "crown" and is_equal_approx(float(r.mult["spawns"]), 0.75))
	check("engine0: units with \"if\": the easy ones come, the hard ones don't", r.tagged("easy_only").size() == 2 and r.tagged("hard_only").is_empty(), "%d %d" % [r.tagged("easy_only").size(), r.tagged("hard_only").size()])
	check("engine0: EASY: fewer of the foe (4 militia -> 3)", r.tagged("militia").size() == 3, str(r.tagged("militia").size()))
	check("engine0: a \"fixed\" entry keeps its count", r.tagged("kept").size() == 4)
	check("engine0: the player's own side is never scaled (8 muskets)", r.tagged("column_foot").size() == 8)
	check("engine0: a hero stays one", r.tagged("ringleader").size() == 1)
	r.act({"spawn": {"team": "rebels", "kind": "musketeer", "count": 8, "at": "village", "tag": "wave"}})
	check("engine0: EASY: a spawned wave of 8 -> 6", r.tagged("wave").size() == 6, str(r.tagged("wave").size()))
	_step(g, 1.5)
	check("engine0: the raced countdown is 25% longer, a plain timer isn't", absf(float(r.clocks["escape"]) - g.clock - 125.0) < 0.6 and absf(float(r.clocks["timer"]) - g.clock - 100.0) < 0.6, str(r.clocks))
	check("engine0: the difficulty condition", r.flags.has("easy"))
	check("engine0: the playing condition", r.flags.has("crown_played") and r.cond({"playing": "crown"}) and not r.cond({"playing": "rebels"}))
	# STAY: three muskets at the ford for five seconds
	var foot := r.tagged("column_foot")
	var fr := r.area_rect("ford")
	for i in 3:
		foot[i].position = fr.get_center() + Vector2(i * 14 - 14, 0)
		foot[i].cmd_hold()
	g._rebuild_hash()
	var t := 2.0
	while t < 6.0:
		_step(g, t)
		t += 0.25
	check("engine0: STAY: not yet after 4 s", not r.flags.has("stayed") and r.obj["hold_ford"] == "active")
	while t < 8.0:
		_step(g, t)
		t += 0.25
	check("engine0: STAY: done after 5 s (condition and reach-with-secs)", r.flags.has("stayed") and r.obj["hold_ford"] == "done", "%s %s" % [r.flags, r.obj["hold_ford"]])
	# NEAR
	var cap: Unit = r.tagged("captain")[0]
	var rl: Unit = r.tagged("ringleader")[0]
	check("engine0: NEAR: far apart", not r.cond({"near": {"tag": "captain", "to": "ringleader", "within": 3}}))
	# SLEEP / WAKE: the militia sleep until a Crown man comes within 5 tiles
	r.act({"sleep": {"tag": "militia", "name": "village", "within": 5, "then": {"do": "attack", "to": "camp"}}})
	var mil: Array = r.tagged("militia")
	check("engine0: SLEEP: they can't move or fight", r.cond({"asleep": "village"}) and mil.all(func(u) -> bool: return u.m_pace == 0.0 and u.m_unarmed))
	r._tick_sleep()
	check("engine0: SLEEP: nobody near, still asleep", not r.cond({"awake": "village"}))
	cap.position = mil[0].position + Vector2(3 * Defs.TILE, 0)
	g._rebuild_hash()
	r._tick_sleep()
	check("engine0: WAKE: a foe within reach wakes them, their order follows", r.cond({"awake": "village"}) and mil.all(func(u) -> bool: return u.m_pace == 1.0 and not u.m_unarmed) and mil.any(func(u) -> bool: return u.order != "idle" and u.order != "hold"), str(mil.map(func(u): return u.order)))
	r.act({"sleep": {"tag": "kept", "within": 0}})
	r.tagged("kept")[0].take_damage(5.0, null)
	r._tick_sleep()
	check("engine0: WAKE: a wound wakes a group", r.cond({"awake": "kept"}))
	# ROUTE: the ford guard walks the ford, then the camp
	r.act({"order": {"tag": "ford_guard", "do": "route", "route": ["ford", "camp"], "name": "patrol"}})
	var fg: Array = r.tagged("ford_guard")
	check("engine0: ROUTE: off to the first waypoint", fg.all(func(u) -> bool: return u.order == "move"), str(fg.map(func(u): return u.order)))
	for u in fg:
		u.position = fr.get_center()
	g._rebuild_hash()
	r._tick_routes()
	check("engine0: ROUTE: on to the next", r._routes.size() == 1 and int(r._routes[0]["i"]) == 1 and not r.cond({"route_done": "patrol"}))
	for u in fg:
		u.position = r.area_rect("camp").get_center()
	g._rebuild_hash()
	r._tick_routes()
	check("engine0: ROUTE: done at the last", r.cond({"route_done": "patrol"}) and r._routes.is_empty())
	# FOLLOW: the ringleader shadows the captain
	cap.position = r.area_rect("camp").get_center()
	g._rebuild_hash()
	r.act({"order": {"tag": "ringleader", "do": "follow", "leader": "captain", "within": 3}})
	for i in 4:
		r._tick_routes()
	check("engine0: FOLLOW: walks after the leader", rl.order == "move", rl.order)
	rl.position = cap.position + Vector2(Defs.TILE, 0)
	g._rebuild_hash()
	check("engine0: NEAR: within reach", r.cond({"near": {"tag": "captain", "to": "ringleader", "within": 3}}) and r.cond({"near": {"tag": "ringleader", "to_side": "crown", "within": 2}}))
	# CAPTURE: the ringleader can't be killed; beaten down with a Crown man by him, he is taken
	r._follows.clear()
	check("engine0: CAPTURE: a floor on the man", rl.hp_floor >= rl.max_hp * 0.25 - 0.01)
	rl.take_damage(99999.0, null)
	check("engine0: CAPTURE: he doesn't die", not rl.dead and rl.hp <= rl.max_hp * 0.25 + 0.5)
	r._check_objectives()
	check("engine0: CAPTURE: taken (done, caged, spared)", r.obj["take"] == "done" and r.cond({"captured": "ringleader"}) and rl.spared and rl.m_pace == 0.0, r.obj["take"])
	# MIST: the rebels see half as far
	r.act({"mist": {"sight": 0.5, "side": "rebels"}})
	var reb_u: Unit = r.tagged("kept")[0]
	check("engine0: MIST: the foe's sight halved, ours not", r.sight_of(reb_u, 8) == 4 and r.sight_of(cap, 8) == 8)
	reb_u._tick_unit(1.0 / 30.0)
	cap._tick_unit(1.0 / 30.0)      # (one tick of each by hand: the match's 3-2-1 may still hold the tree paused)
	check("engine0: MIST: a unit's own sight follows", reb_u.sight == maxi(2, roundi(int(reb_u.d["sight"]) * 0.5)) and cap.sight == int(cap.d["sight"]), "%d %d" % [reb_u.sight, cap.sight])
	r.act({"mist": {"sight": 1.0}})
	check("engine0: MIST: cleared", r.sight_of(reb_u, 8) == 8)
	check("engine0: not over in all this", not g.over)
	# ---------------------------------------------------------------- the other side, alone: the rebels
	main._to_menu()
	main.start(Campaign.make_cfg(E0, "solo", "p1", false, "rebels"))
	await process_frame
	await process_frame
	paused = false
	g = main.game
	r = g.mission
	check("engine0: SOLO SIDE PICK: you lead the rebels", r.my_side() == "rebels" and r.solo_side == "rebels" and r.player_teams.has(r.team_index("rebels")) and g.human == r.team_index("rebels"))
	check("engine0: SOLO SIDE PICK: now the Crown is the foe (EASY: 8 muskets -> 6)", r.tagged("column_foot").size() == 6 and r.tagged("militia").size() == 4, "%d %d" % [r.tagged("column_foot").size(), r.tagged("militia").size()])
	check("engine0: SOLO SIDE PICK: the rebels' objectives are yours", r.objectives_for(r.my_side()).any(func(o) -> bool: return String(o["id"]) == "hold"))
	_step(g, 1.5)
	check("engine0: SOLO SIDE PICK: the rebels' own lines are said", r.said_ids.has("r1"))
	check("engine0: the playing condition follows the pick", r.cond({"playing": "rebels"}) and not r.cond({"playing": "crown"}))
	main._to_menu()
	Campaign.set_difficulty("normal")


func _step(g: Game, to: float) -> void:
	g.clock = to
	g.mission._run_triggers()
	g.mission._check_objectives()


func _run() -> void:
	await process_frame
	_data()
	# ---------------------------------------------------------------- solo, won
	var g := await _start("solo")
	var r: MissionRun = g.mission
	check("the mission is on the game", r != null and r.mode == "solo")
	check("no computer player for scripted sides", g.ais.is_empty(), str(g.ais.size()))
	var col := r.team_index("column")
	var reb := r.team_index("rebels")
	check("the column: captain, 8 muskets, 2 horse", r.count({"team": "column"}) == 11, str(r.count({"team": "column"})))
	check("the column has no buildings", r.count({"team": "column", "buildings": true}) == 11)
	check("the rebels' hall is tagged", r.tagged("rebel_hall").size() == 1)
	var kinds := {}
	for b in g.buildings:
		if b.team == reb:
			kinds[b.kind] = true
	check("rebels: hall, farm, cottage, barracks", kinds.has("town_hall") and kinds.has("farm") and kinds.has("cottage") and kinds.has("barracks"), str(kinds.keys()))
	check("rebel hall at its spot", r.tagged("rebel_hall")[0].cell == Vector2i(14, 28))
	check("the camera starts at the camp", r.area_rect("camp").grow(200).has_point(g.camera.position))
	check("objectives: 4 for the crown", r.objectives_for("crown").size() == 4)
	_step(g, 1.5)
	check("intro lines said", r.said_ids.slice(0, 3) == ["i1", "i2", "tip1"], str(r.said_ids))
	check("versus-only lines not said in solo", not r.said_ids.has("r1"))
	await process_frame
	var ui: MissionUi = null
	for n in main.ui_layer.get_children():
		if n is MissionUi:
			ui = n
	check("the dialogue box shows a line", ui != null and ui._box.visible and ui._text.text != "")
	ui.skip_all()
	check("SKIP clears the lines", not ui._box.visible and ui.queue.is_empty())
	# three of the column at the ford: the sergeant speaks; 10 s later the militia counter-attacks
	var foot := r.tagged("column_foot")
	var fr := r.area_rect("ford")
	for i in 5:
		foot[i].position = fr.get_center() + Vector2(i * 14 - 28, 0)
	g._rebuild_hash()
	_step(g, 5.0)
	check("at the ford: line said", r.fired.has("at_ford") and r.said_ids.has("f1"))
	check("take the ford: done with five men", r.obj["ford"] == "done")
	_step(g, 5.5)
	check("ford taken (next check): the village is shown", r.fired.has("ford_taken") and not r.reveals.is_empty())
	_step(g, 16.0)
	check("militia counter-attack after the delay", r.fired.has("militia_go"))
	var mil: Array = r.tagged("militia")
	check("the militia were ordered out", not mil.is_empty() and mil[0].order != "hold", str(mil[0].order if not mil.is_empty() else ""))
	_step(g, 121.0)
	check("the Crown's horse arrives", r.tagged("relief").size() == 4 and r.said_ids.has("h1"))
	var hall: Building = r.tagged("rebel_hall")[0]
	hall.take_damage(50.0, null)
	_step(g, 122.0)
	check("hurt hall: the ringleader speaks", r.said_ids.has("b1"))
	check("not over yet", not g.over)
	hall.take_damage(999999.0, null)
	_step(g, 123.0)
	check("hall burned: the crown wins", g.over and r.winner_side == "crown", "%s %s" % [g.over, r.winner_side])
	check("the winner is a crown team", g.winner == col or g.winner == r.team_index("horse"))
	check("the captain's protect is settled done", r.obj["captain"] == "done")
	await create_timer(1.6).timeout
	check("the mission's end screen shows", main.ui_layer.find_child("MissionEnd", true, false) != null)
	var p := Campaign.progress()
	check("progress: the test mission is done", (p["done"] as Dictionary).has("p01_revolt"))
	check("every storyline is open from the start", Campaign.storyline_open(Campaign.storylines()[1]))
	Campaign.record("p01_leaf", "solo", "crown", "crown", {"families": "save"})
	p = Campaign.progress()
	check("the prologue won: the naturalist and clockmaker storylines open", Campaign.storyline_open(Campaign.storylines()[1]) and Campaign.storyline_open(Campaign.storylines()[2]))
	check("the prologue's choice is kept for later missions", Campaign.flag("p01_leaf", "families") == "save")
	var tk: Dictionary = Campaign.storylines()[0]["hub"]["talks"]["fairleigh"]
	check("the Governor's talk changed after the mission", String(CampaignMenu.talk_lines(tk, p)[0]).begins_with("It is done."))
	# ---------------------------------------------------------------- solo, lost: the captain killed
	main._to_menu()
	g = await _start("solo")
	r = g.mission
	_step(g, 2.0)
	r.tagged("captain")[0].die()
	_step(g, 3.0)
	check("captain killed: the rebels win", g.over and r.winner_side == "rebels")
	# ---------------------------------------------------------------- versus (offline: the rebels scripted): they hold out
	main._to_menu()
	g = await _start("versus")
	r = g.mission
	_step(g, 2.0)
	check("versus: the rebels' own lines are said (shown to the rebels only)", r.said_ids.has("r1"))
	_step(g, 481.0)
	check("rebels hold eight minutes: they win", g.over and r.winner_side == "rebels")
	# ---------------------------------------------------------------- online, without a network: the room and a guest's mission
	var l := NetLobby.new()
	l.is_host = true
	root.add_child(l)
	l.set_campaign("p01_revolt", "coop")
	var lc := l.make_cfg()
	check("campaign room: the mission's map and seats", l.map == "campaign:ford_village" and l.slots.map(func(s): return s["who"]) == ["you", "remote", "script"])
	check("campaign room: the match setup carries the mission", lc.has("campaign") and lc["campaign"]["mode"] == "coop")
	var gc := l._guest_cfg(lc, 1)
	check("the guest's setup carries the mission too", gc.has("campaign") and gc["slots"][1]["who"] == "you")
	l.free()
	main._to_menu()
	g = await _start("coop")
	var guest := MissionRun.new()
	guest.game = g
	guest.setup(Campaign.mission("p01_revolt"), "coop", Campaign.make_cfg("p01_revolt", "coop"), true)
	var heard: Array = []
	guest.said.connect(func(ln: Dictionary) -> void: heard.append(ln["id"]))
	guest.on_net({"t": "camp", "k": "say", "ids": ["i1", "r1"]})
	check("guest: a line for its side is shown, the foe's is not", heard == ["i1"], str(heard))
	var ob := guest.obj.duplicate()
	ob["ford"] = "done"
	guest.on_net({"t": "camp", "k": "obj", "o": ob})
	check("guest: objectives follow the host's", guest.obj["ford"] == "done")
	guest.check_end()
	check("guest: never decides the end itself", not g.over)
	guest.free()
	await _engine0()
	# ---------------------------------------------------------------- the menu pages build
	main._to_menu()
	await process_frame
	main.show_campaign()
	await process_frame
	check("the hub has its hotspots", main.menu.find_child("Hotspot_war_table", true, false) != null and main.menu.find_child("HotspotList_fairleigh", true, false) != null)
	CampaignMenu.war_table(main)
	await process_frame
	check("the war table lists the mission", main.menu.find_child("Mission_p01_leaf", true, false) != null)
	CampaignMenu.briefing(main, "p01_leaf")
	await process_frame
	check("the briefing has START", main.menu.find_child("Briefing_Start", true, false) != null)
	check("the briefing has the difficulty", main.menu.find_child("Diff_easy", true, false) != null and main.menu.find_child("Diff_hard", true, false) != null)
	check("a one-sided mission has no side pick", main.menu.find_child("Side_rebels", true, false) == null)
	Campaign._cache["%s/missions/%s.json" % [Campaign.DIR, E0]] = _engine0_mission()
	CampaignMenu.briefing(main, E0)
	await process_frame
	var sb: Button = main.menu.find_child("Side_rebels", true, false)
	check("a mirrored mission's briefing: pick a side", sb != null and main.menu.find_child("Side_crown", true, false) != null)
	if sb:
		sb.pressed.emit()
		await process_frame
		check("the side picked is the briefing's side", CampaignMenu.solo_pick == "rebels")
	var hb: Button = main.menu.find_child("Diff_hard", true, false)
	if hb:
		hb.pressed.emit()
		await process_frame
	check("DIFFICULTY pressed on the briefing: kept in the progress", Campaign.difficulty() == "hard")
	Campaign.set_difficulty("normal")
	CampaignMenu.solo_pick = ""
	# the Clockwork and Brood hubs (layered paintings: Hollweg's workshop, Lindqvist's station), opened for the test
	for it in [["clockmaker", "hollweg", "clock"], ["naturalist", "lindqvist", "crate"]]:
		Campaign.open_all = true
		CampaignMenu.line = it[0]
		CampaignMenu.show(main)
		await process_frame
		var hs: HubScene = null
		for n in main.menu.find_children("*", "HubScene", true, false):
			hs = n
		check("the %s hub is a layered painting" % it[0], hs != null and hs.ok() and hs._tex.has(it[1]))
		var who: Button = main.menu.find_child("Hotspot_" + it[1], true, false)
		check("the %s hub: its person and objects" % it[0], who != null and main.menu.find_child("HotspotList_" + it[2], true, false) != null)
		if who:
			who.pressed.emit()
			await process_frame
			var tt: Label = main.menu.find_child("TalkText", true, false)
			check("the %s hub: the person talks" % it[0], tt != null and tt.text != "" and tt.text != "...")
		Campaign.open_all = false
	CampaignMenu.line = ""
	_finish()
