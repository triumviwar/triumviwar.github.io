extends SceneTree
## Act 1's "The Printing Houses" (docs/campaign_a01_build.md):
##   - the data checks out, every text has pt and es, the Crown line lists it after p01 and p01's Crown win leads to it,
##     the seats for solo, co-op and versus (no solo side pick), the map (the city generator's Lyon) and the stills load,
##     its war map pin is live;
##   - THE PROLOGUE'S FLAG at the start (p01_leaf `families` save / leave / none): Tomasz's lines;
##   - WHERE THE PRESSES PRINT: the layout choice (random by the match's seed; each layout), six DISGUISED presses among
##     the town's houses (the town's colour, untouchable) and how one is given away (a Crown unit within 3 tiles; not
##     the Assembly's own, not from 5 tiles), its men, the Watch's hint;
##   - PART 1: the runners (a press's every 2:00, to the nearest square), the temper (a runner on a square +1, a press
##     closed -2, the sermon -1), four presses closed;
##   - PART 2: the weavers, the agitators turning them while Tomasz is away, the bands on the stairs, the STAY, home;
##   - PART 3: the traboules, the great press (disguised), the CAPTURE of Rouvière, the win, the flags (`lyon`,
##     `printer`), the ending by the flags, the progress;
##   - THE DEFEATS (the temper's top, Tomasz killed), VERSUS (the Assembly wins at the top), THE DIFFICULTY, THE HUB.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_a01.gd
## Prints CHECK lines, then "campaign_a01: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "a01_presses"
const P01 := "p01_leaf"
const LAYOUTS := {"old_town": [1, 4, 5, 8, 9, 12], "river": [2, 3, 6, 7, 10, 11], "hill": [1, 3, 6, 7, 9, 11]}
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
	print("campaign_a01: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if p01 was won by the Crown with `families` ("" : p01 not in the progress at all), at a difficulty.
func _progress(families: String, diff := "normal") -> void:
	var p := {"reached": [MID], "done": {}, "difficulty": diff}
	if families != "":
		p["done"][P01] = {"won_by": "crown", "side": "crown", "flags": {"families": families}}
	Campaign.save_progress(p)


func _start(mode := "solo") -> Game:
	if main.game:
		main._to_menu()
		await process_frame
	for n in main.ui_layer.get_children():
		if n.name == "MissionEnd" or n is StillShow:
			n.queue_free()
	main.start(Campaign.make_cfg(MID, mode, "p1", false))
	await process_frame
	await process_frame
	paused = false
	return main.game


## The clock moved to `to` and one round of the mission's checks (as its 0.25 s tick does).
func _step(g: Game, to: float) -> void:
	g.clock = to
	var r := g.mission
	r._tick_turning()
	r._tick_exits()
	r._tick_held()
	r._tick_disguise()
	if not r.choice_open.is_empty() and g.clock >= float(r.choice_open.get("until", INF)):
		r.choose(String(r.choice_open["id"]), String(r.choice_open.get("default", "")))
	r._run_triggers()
	r._check_objectives()


func _walk(g: Game, to: float) -> void:
	var t := g.clock
	while t < to and not g.over:
		t = minf(to, t + 0.25)
		_step(g, t)


## A press closed by the Crown: found first (a disguised house can't be hurt), then burnt.
func _close(r: MissionRun, tag: String) -> void:
	r.act({"unmask": {"tag": tag}})
	_kill(r, tag)


func _kill(r: MissionRun, tag: String) -> void:
	for e in r.tagged(tag):
		if e is Building:
			e.take_damage(1e9, null)
		else:
			e.die()


func _put(g: Game, us: Array, at: Vector2) -> void:
	var i := 0
	for u in us:
		u.position = at + Vector2((i % 4) * 14 - 21, (i / 4) * 14 - 14)
		u.velocity = Vector2.ZERO
		u.cmd_stop()
		i += 1
	g._rebuild_hash()


func _away(g: Game, r: MissionRun) -> void:
	# the garrison out of everyone's way (the east bank's garrison yard)
	_put(g, r.tagged("garrison_men") + r.tagged("riders") + r.tagged("delorme") + r.tagged("wagon"), r.area_rect("garrison_yard").get_center())


## Started, the layout forced (the choice answered before its trigger: its actions run, the trigger finds it answered).
func _start_layout(lid: String, mode := "solo") -> Game:
	var g: Game = await _start(mode)
	var r: MissionRun = g.mission
	if lid != "":
		r.choose("layout", lid)
	_step(g, 1.0)
	_step(g, 2.0)
	return g


func _lot(n: int) -> Vector2i:
	var a: Array = Campaign.mission(MID)["areas"]["cand_%d" % n]
	return Vector2i(int(a[0]) + 1, int(a[1]) + 1)


func _run() -> void:
	await process_frame
	_data()
	await _flags()
	await _layouts()
	await _part1()
	await _parts23()
	await _defeats()
	await _versus()
	await _difficulty()
	_hub()
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("a01_presses: data checks out", pr.is_empty(), "; ".join(pr))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings():
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Crown line (id kept), titled THE CROWN: p01, then a01", String(sl.get("id", "")) == "prologue" and String(sl.get("title", "")) == "The Crown"
		and (sl["missions"] as Array).slice(0, 2) == [P01, MID])
	check("p01 won by the Crown leads to a01 (the rebels' win nowhere)", Campaign.next_of(P01, "crown") == MID and Campaign.next_of(P01, "rebels") == "")
	check("a01 leads nowhere yet (a06 is not built)", Campaign.next_of(MID, "crown") == "" and Campaign.next_of(MID, "assembly") == "")
	Campaign.save_progress({"reached": [], "done": {}})
	check("a01 is locked before p01", not Campaign.unlocked(MID))
	Campaign.record(P01, "solo", "crown", "crown", {"families": "save"})
	check("...and open once p01 is won", Campaign.unlocked(MID))
	check("no solo side pick (versus only): the Crown", Campaign.solo_sides(m) == ["crown"])
	var c := Campaign.make_cfg(MID, "solo")
	check("solo: you are the garrison; the Watch, the town, the Assembly scripted", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "script"])
	c = Campaign.make_cfg(MID, "coop", "p1", true)
	check("co-op online: the friend is the City Watch", c["slots"].map(func(s): return s["who"]) == ["you", "remote", "script", "script"])
	c = Campaign.make_cfg(MID, "versus", "p1", true)
	check("versus online: the friend is the Free Assembly", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "remote"])
	check("the garrison PURPLE, the town YELLOW, the Assembly GREEN", int(c["slots"][0]["colour"]) == 4 and int(c["slots"][2]["colour"]) == 3 and int(c["slots"][3]["colour"]) == 2)
	var md := Campaign.map_data("lyon_presses")
	check("the map is the city generator's Lyon, 128 x 96", String(m["map"]) == "campaign:lyon_presses" and (md.get("size", []) as Array).map(func(x): return int(x)) == [128, 96]
		and (md.get("props", []) as Array).size() > 1000)
	for k in m["stills"]:
		check("still %s: its picture loads" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	check("the opening and the ending per side", (m["opening"] as Dictionary).has("crown") and (m["opening"] as Dictionary).has("assembly")
		and (m["ending"] as Dictionary).has("crown") and (m["ending"] as Dictionary).has("assembly"))
	var pin := {}
	var w = JSON.parse_string(FileAccess.get_file_as_string("res://campaign/warmap.json"))
	for p in w["pins"]:
		if String(p["mission"]) == MID:
			pin = p
	check("the war map's pin is live (no working title: the mission's own)", not pin.is_empty() and not pin.has("title"))
	var vals := {}
	for rl in w["rules"]:
		var s := JSON.stringify(rl)
		if s.contains("a01_presses.lyon"):
			vals[String(rl["if"]["flag"]["a01_presses.lyon"])] = true
	check("its rules read `lyon` calm / sullen", vals.has("calm") and vals.has("sullen"))


# ================================================================== the prologue's flag

func _flags() -> void:
	for fam in ["save", "leave", ""]:
		_progress(fam)
		var g: Game = await _start_layout("old_town")
		var r: MissionRun = g.mission
		var P := "families %s: " % (fam if fam != "" else "(none)")
		var ids: Array = []
		for pg in r.pages_now(r.data["opening"]["crown"]):
			for l in pg["lines"]:
				ids.append(String(l["id"]) if l is Dictionary else String(l))
		check(P + "the opening's lines", ids.has("t_open_saved") == (fam == "save") and ids.has("t_open_left") == (fam != "save") and ids.has("c_open"), str(ids))
		_step(g, 18.0)
		check(P + "Tomasz's line in the streets", r.said_ids.has("t_saved") == (fam == "save") and r.said_ids.has("t_left") == (fam != "save"))
		check(P + "the garrison: Delorme, Tomasz, 12 Musketeers, 4 Horsemen", r.tagged("delorme").size() == 1 and r.tagged("tomasz").size() == 1
			and r.tagged("garrison_men").size() == 12 and r.tagged("riders").size() == 4 and r.tagged("tomasz")[0].max_hp >= 360.0)
		check(P + "the Watch at four bridges, the hall, the town's houses", r.tagged("watch_men").size() == 8 and r.tagged("weavers_hall").size() == 1
			and r.tagged("houses").size() == 16 + 6)


# ================================================================== where the presses print

func _layouts() -> void:
	_progress("save")
	# ---- random: the match's seed picks one of the three
	var g: Game = await _start_layout("")
	var r: MissionRun = g.mission
	check("the hidden yard's two traboules are shut (doors in the town's colour, untouchable)", r.tagged("yard_doors").size() == 2
		and r.tagged("yard_doors").all(func(b): return b.spared and b.cloth_colour() == g.team_colour(r.team_index("town"))))
	check("random layout: one of the three", LAYOUTS.has(String(r.flags.get("layout", ""))), str(r.flags.get("layout", "")))
	for lid in LAYOUTS:
		g = await _start_layout(lid)
		r = g.mission
		var at := r.team_index("assembly")
		var tt := r.team_index("town")
		var presses: Array = r.tagged("presses")
		var cells: Array = presses.map(func(b): return b.cell)
		var want: Array = (LAYOUTS[lid] as Array).map(func(n): return Vector2i(Campaign.mission(MID)["areas"]["cand_%d" % n][0] + 1, Campaign.mission(MID)["areas"]["cand_%d" % n][1] + 1))
		check("layout %s: six presses on its candidates" % lid, presses.size() == 6 and want.all(func(c): return cells.has(c)), str(cells))
		check("layout %s: the presses are the Assembly's, disguised as the town's, untouchable" % lid, presses.all(func(b): return b.team == at and b.spared and b.has_meta("disguise_team") and b.cloth_colour() == g.team_colour(tt)))
		check("layout %s: the other six candidates are the town's houses" % lid, r.tagged("houses").filter(func(b): return b.team == tt).size() == 22)
		check("layout %s: press_1..6 tagged" % lid, range(1, 7).all(func(i): return r.tagged("press_%d" % i).size() == 1))
	# ---- the disguise and its giving away
	g = await _start_layout("old_town")
	r = g.mission
	var p1: Building = r.tagged("press_1")[0]
	var man: Unit = r.tagged("garrison_men")[0]
	_put(g, [man], p1.center() + Vector2(0, (p1.size.y * 0.5 + 5.5) * Defs.TILE))
	_step(g, 3.0)
	check("a Crown man 5 tiles off: the press stays hidden", p1.spared and not r.unmasked.has("press_1"))
	var own: Unit = g._add_unit("musketeer", r.team_index("assembly"), p1.center() + Vector2(0, (p1.size.y * 0.5 + 1.0) * Defs.TILE))
	_step(g, 3.5)
	check("the Assembly's own man at its door: still hidden", p1.spared)
	own.die()
	_put(g, [man], p1.center() + Vector2(0, (p1.size.y * 0.5 + 1.2) * Defs.TILE))
	_step(g, 4.0)
	check("a Crown man at its door: not at once (he must stop and look)", p1.spared and not r.unmasked.has("press_1"))
	_walk(g, 7.25)
	check("...3 s at its door: UNMASKED (its own colour, open to attack)", not p1.spared and not p1.has_meta("disguise_team")
		and r.unmasked.has("press_1") and r.unmasked.has("presses") and p1.cloth_colour() == g.team_colour(p1.team))
	check("its men come out (2 militia and a pike)", r.tagged("press_men").size() == 3 and r.said_ids.has("d_found"))
	var p2: Building = r.tagged("press_2")[0]
	_put(g, r.tagged("watch_men").slice(0, 1), p2.center() + Vector2(0, (p2.size.y * 0.5 + 1.2) * Defs.TILE))
	_walk(g, 11.0)
	check("the Watch finds one too", r.unmasked.has("press_2"))


# ================================================================== part 1

func _part1() -> void:
	_progress("save")
	var g: Game = await _start_layout("river")
	var r: MissionRun = g.mission
	var gt := r.team_index("garrison")
	check("part 1: the objectives", r.obj["presses"] == "active" and r.obj["temper"] == "active" and r.obj["tomasz"] == "active" and r.obj["speech"] == "hidden")
	check("the temper starts at 2", int(r.counters["temper"]) == 2 and r.objective_text(r.objective("temper")).begins_with("The city"))
	_step(g, 41.0)
	check("a runner out of the first press at 0:40", r.tagged("runner_1").size() == 1 and r.tagged("runner").size() == 1 and r.fired.has("run_1_normal")
		and not r.fired.has("run_1_easy"))
	var run: Unit = r.tagged("runner_1")[0]
	var sq := "terreaux"
	for ti in r.data["triggers"]:
		if String(ti["id"]) == "run_1_normal":
			for ti2 in ti["do"][1]["order"]["to_if"]:
				if r.cond(ti2["if"]):
					sq = String(ti2["to"])
	_put(g, [run], r.area_rect(sq).get_center())
	_step(g, 42.0)
	check("A RUNNER ON A SQUARE: off the map, the temper 3", int(r.counters["temper"]) == 3, str(r.counters["temper"]))
	r.act({"counter": {"name": "temper", "set": 5}})
	_step(g, 61.0)
	check("the second press's runner at 1:00", r.tagged("runner_2").size() == 1)
	check("the city pays its garrison at 1:00", int(g.players[gt]["gold"]) == 340)
	# the sermon
	_put(g, r.tagged("tomasz"), r.area_rect("bellecour").get_center())
	_walk(g, 92.0)
	check("THE SERMON: Tomasz on a square 30 s: the temper -1", int(r.counters["temper"]) == 4 and r.said_ids.has("t_sermon"), str(r.counters["temper"]))
	# a press closed
	_close(r, "press_1")
	_step(g, 93.0)
	_step(g, 93.25)
	check("A PRESS CLOSED: 1 of 4, the temper -2, 60 gold", int(r.counters["closed"]) == 1 and int(r.counters["temper"]) == 2
		and int(g.players[gt]["gold"]) == 400 and r.said_ids.has("d_closed") and r.objective_text(r.objective("presses")).begins_with("Find the Assembly"), str([r.counters, r.said_ids.has("d_closed"), g.players[gt]["gold"]]))
	_step(g, 162.0)
	check("a closed press sends no more runners", r.tagged("runner_1", false).size() == 1)
	# the Watch's hint at 5:00 (press 2 not yet found)
	_step(g, 299.0)
	check("no hint before 5:00", not r.unmasked.has("press_2"))
	_step(g, 301.0)
	check("THE WATCH'S HINT at 5:00: the first press still hidden (2) given away", r.unmasked.has("press_2") and not r.unmasked.has("press_3") and r.said_ids.has("w_hint"))
	_step(g, 449.0)
	_step(g, 451.0)
	check("...and the next at 7:30", r.unmasked.has("press_3"))
	# the temper's lines
	r.act({"counter": {"name": "temper", "set": 10}})
	_step(g, 452.0)
	check("the temper at 10: the shutters close", r.said_ids.has("n_temper10"))
	r.act({"counter": {"name": "temper", "set": 3}})
	for i in [2, 3, 4]:
		_close(r, "press_%d" % i)
	_step(g, 453.0)
	_step(g, 453.25)
	check("four presses closed", int(r.counters["closed"]) == 4 and int(r.counters["temper"]) == 0)
	check("the temper never under 0", int(r.counters["temper"]) == 0)
	_step(g, 461.5)
	check("PART 2 eight seconds after: the presses' objective done", r.fired.has("part2") and r.obj["presses"] == "done" and r.obj["speech"] == "active")


# ================================================================== parts 2 and 3, and the win

func _part2(g: Game, r: MissionRun, P: String) -> void:
	var t0 := float(r.fired["part2"])
	check(P + "the weavers on the hall's square (16), spared", r.tagged("weavers").size() == 16 and r.tagged("weavers").all(func(u): return u.spared and r.area_rect("hall_square").has_point(u.position)))
	check(P + "six more Musketeers below the stairs", r.tagged("reinforce").size() == 6)
	check(P + "the remaining presses print no more", not r.fired.has("run_5_normal") or float(r.fired["run_5_normal"]) < t0)
	_put(g, r.tagged("tomasz"), r.area_rect("garrison_yard").get_center())
	_step(g, t0 + 12.5)
	check(P + "the agitators need a while: nobody turned at 0:12", not r.fired.has("turn"))
	_step(g, t0 + 25.5)
	_step(g, t0 + 26.0)
	check(P + "Tomasz away: two weavers turn", r.fired.has("turn") and r._turning.size() >= 1 and int(r.counters["weavers"]) == 2 and r.said_ids.has("n_turn"))
	var temper := int(r.counters["temper"])
	_step(g, t0 + 30.0)
	check(P + "...they are the Assembly's mob now, no longer spared", r.tagged("mob").size() == 2 and r.tagged("mob").all(func(u): return u.team == r.team_index("assembly") and not u.spared))
	_step(g, t0 + 41.0)
	check(P + "the first band at the Terreaux, for the hall", r.tagged("band").size() == 6 and r.said_ids.has("d_band1"))
	_put(g, r.tagged("tomasz"), r.area_rect("hall_square").get_center() + Vector2(0, 64))
	var t1 := g.clock
	var turned := int(r.counters["weavers"])
	temper = int(r.counters["temper"])
	_walk(g, t1 + 20.0)
	check(P + "Tomasz on the square: no more turned", int(r.counters["weavers"]) == turned and int(r.counters["temper"]) == temper)
	_walk(g, t1 + 46.5)
	check(P + "THE STAY: he has spoken (45 s)", r.obj["speech"] == "done" and r.said_ids.has("wv_spoken"))
	check(P + "the weavers go home, the temper -3", r.fired.has("spoken") and int(r.counters["temper"]) == maxi(0, temper - 3))
	var stay: Array = r.tagged("weavers").filter(func(u): return u.team == r.team_index("town"))
	check(P + "only the weavers who listened are sent home (not the mob)", r.tagged("mob").all(func(u): return u.team != r.team_index("town")) and stay.size() >= 16 - turned, str(stay.size()))
	_put(g, stay, r.area_rect("home_w").get_center())
	_step(g, g.clock + 0.5)
	check(P + "...off the map at home, counted", int(r.counters["home"]) == stay.size(), str(r.counters["home"]))


func _parts23() -> void:
	_progress("save")
	var g: Game = await _start_layout("hill")
	var r: MissionRun = g.mission
	_step(g, 30.0)
	for i in [1, 2, 3, 4]:
		_close(r, "press_%d" % i)
	_step(g, 31.0)
	_step(g, 31.25)
	_step(g, 39.5)
	check("run: part 2", r.fired.has("part2"))
	await _part2(g, r, "part 2: ")
	# the Assembly still on the hill holds Part 3 back
	_step(g, g.clock + 6.0)
	var held := not r.fired.has("part3")
	for u in g.units.duplicate():
		if not u.dead and u.team == r.team_index("assembly") and r.area_rect("hilltop_all").has_point(u.position):
			u.die()
	check("part 3 waits while the Assembly is on the hill (or 1:30)", held or float(r.fired.get("spoken", 0.0)) + 90.0 <= g.clock)
	_step(g, g.clock + 0.5)
	_step(g, g.clock + 5.5)
	check("PART 3: the great press's objectives, the traboules pinged", r.fired.has("part3") and r.obj["great"] == "active" and r.obj["rouviere"] == "active"
		and r.obj["close_great"] == "active" and r.said_ids.has("wv_yard"))
	check("the yard's doors (in the traboules) are broken open now", r.tagged("yard_doors", false).size() == 2 and r.tagged("yard_doors").is_empty())
	var gp: Building = r.tagged("great_press")[0]
	check("the great press is disguised (the town's colour, untouchable)", gp.spared and gp.has_meta("disguise_team"))
	check("the master printer in the yard, kept from dying (capture)", r.tagged("printer").size() == 1 and r.tagged("printer")[0].hp_floor > 0.0)
	var men: Array = r.tagged("garrison_men").slice(0, 4)
	_put(g, men, r.area_rect("yard").get_center())
	_walk(g, g.clock + 3.5)
	check("a Crown man in the yard: the great press UNMASKED, found", not gp.spared and r.obj["great"] == "done" and r.said_ids.has("pr_1"))
	_step(g, g.clock + 30.5)
	check("the great press prints on while it stands (a runner to the Terreaux)", r.tagged("runner_great").size() >= 1)
	var pr: Unit = r.tagged("printer")[0]
	pr.take_damage(1e6, null)
	check("the printer can't be killed: down to a quarter", not pr.dead and pr.hp <= pr.max_hp * 0.25 + 0.5)
	_put(g, [men[0]], pr.position + Vector2(20, 0))
	_step(g, g.clock + 0.5)
	_step(g, g.clock + 0.25)
	check("TAKEN ALIVE: the capture done, the flag `printer`", r.obj["rouviere"] == "done" and r.flags.get("printer", "") == "taken" and r.said_ids.has("pr_taken"),
		str([r.obj["rouviere"], r.flags.get("printer", ""), pr.hp, pr.hp_floor, men[0].dead, men[0].position.distance_to(pr.position)]))
	r.act({"counter": {"name": "temper", "set": 5}})
	_kill(r, "great_press")
	_step(g, g.clock + 0.5)
	_step(g, g.clock + 3.5)
	check("the great press closed: Lyon is quiet, `lyon` calm (temper 5)", r.fired.has("won") and r.flags.get("lyon", "") == "calm" and int(r.flags.get("lyon_n", -1)) == 5)
	_step(g, g.clock + 8.5)
	check("THE PRESSES ARE SILENT: the Crown wins", g.over and r.winner_side == "crown")
	await create_timer(1.8).timeout
	var show: StillShow = null
	for n in main.ui_layer.get_children():
		if n is StillShow:
			show = n
	check("the Crown's ending plays", show != null)
	if show:
		for i in 20:
			if is_instance_valid(show) and not show.is_queued_for_deletion():
				show.next()
		check("the ending's lines by the flags", show.shown_ids == ["t_end1", "t_end_calm", "t_end_saved", "c_end", "k_end1", "k_end2"], str(show.shown_ids))
	var p := Campaign.progress()
	check("it counts: done, by the Crown, the flags kept", (p["done"] as Dictionary).has(MID) and Campaign.flag(MID, "lyon") == "calm"
		and Campaign.flag(MID, "printer") == "taken")
	# ---- sullen: the temper at 6 or more
	g = await _start_layout("old_town")
	r = g.mission
	r.act({"counter": {"name": "temper", "set": 6}})
	var won_tr: Dictionary = {}
	for t in r.data["triggers"]:
		if String(t["id"]) == "won":
			won_tr = t
	r.fire({"id": "x", "do": (won_tr["do"] as Array).filter(func(a): return a.has("tally"))})
	check("a temper of 6 at the end: `lyon` sullen", r.flags.get("lyon", "") == "sullen")


# ================================================================== the defeats

func _defeats() -> void:
	_progress("leave")
	var g: Game = await _start_layout("river")
	var r: MissionRun = g.mission
	_step(g, 30.0)
	r.act({"counter": {"name": "temper", "set": 19}})
	_step(g, 31.0)
	check("the temper at 19: not yet", not g.over and r.said_ids.has("n_temper15"))
	r.act({"counter": {"name": "temper", "add": 1}})
	_step(g, 32.0)
	check("THE TEMPER AT 20: the city rises, the Crown loses", g.over and r.winner_side == "assembly" and r.obj["temper"] == "failed" and r.said_ids.has("n_risen"))
	check("...and it does not count", not (Campaign.progress()["done"] as Dictionary).has(MID))
	g = await _start_layout("river")
	r = g.mission
	_step(g, 30.0)
	_kill(r, "tomasz")
	_step(g, 31.0)
	check("Tomasz killed: the Crown loses", g.over and r.winner_side == "assembly" and r.obj["tomasz"] == "failed")
	# the printer killed would fail the capture: he can't be (his floor), so the captive is safe until taken


# ================================================================== versus (offline: the Assembly scripted)

func _versus() -> void:
	_progress("save")
	var g: Game = await _start_layout("hill", "versus")
	var r: MissionRun = g.mission
	check("versus: the Assembly's objectives", r.objectives_for("assembly").map(func(o): return o["id"]) == ["a_raise", "a_priest"])
	check("versus: the Assembly's own lines name its layout", r.said_ids.has("a_layout_hill"))
	_step(g, 30.0)
	r.act({"counter": {"name": "temper", "set": 20}})
	_step(g, 31.0)
	check("versus: the temper's top wins it for the Assembly", g.over and r.winner_side == "assembly" and r.obj["a_raise"] == "done")
	await create_timer(1.8).timeout
	var p := Campaign.progress()
	check("versus: the story follows the winner (the Assembly; Lyon risen)", (p["done"] as Dictionary).has(MID) and String(p["done"][MID]["won_by"]) == "assembly")


# ================================================================== the difficulty

func _difficulty() -> void:
	for d in [["easy", 1, 420], ["hard", 3, 510]]:
		_progress("save", d[0])
		var g: Game = await _start_layout("old_town")
		var r: MissionRun = g.mission
		_step(g, 41.0)
		check("%s: the runners on its own timetable" % d[0], r.fired.has("run_1_" + d[0]) and not r.fired.has("run_1_normal"))
		var p1: Building = r.tagged("press_1")[0]
		_put(g, r.tagged("riders").slice(0, 1), p1.center() + Vector2(0, (p1.size.y * 0.5 + 1.0) * Defs.TILE))
		_walk(g, 45.0)
		var n := r.tagged("press_men").filter(func(u): return u.kind == "musketeer").size()
		check("%s: a press's militia scaled (%d)" % [d[0], d[1]], n == int(d[1]), str(n))
		check("%s: the garrison is the player's: never scaled" % d[0], r.tagged("garrison_men").size() == 12)
		_step(g, float(d[2]) - 1.0)
		check("%s: the first hint has come, the second not yet" % d[0], r.unmasked.has("press_2") and not r.unmasked.has("press_3"))
		_step(g, float(d[2]) + 1.0)
		check("%s: the second hint at %d s" % [d[0], d[2]], r.unmasked.has("press_3"))
	Campaign.set_difficulty("normal")


# ================================================================== the hub

func _hub() -> void:
	var sl := Campaign.storyline_of(MID)
	var hub: Dictionary = sl["hub"]
	var after := {"done": {P01: {"side": "crown"}, MID: {"side": "crown"}}}
	check("the King's talk after a01", String(CampaignMenu.talk_lines(hub["talks"]["king"], after)[0]).contains("Lyon went home"))
	check("the Cardinal's talk after a01", String(CampaignMenu.talk_lines(hub["talks"]["tomasz"], after)[1]).contains("Paris"))
