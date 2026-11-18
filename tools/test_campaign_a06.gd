extends SceneTree
## Act 1's "The Barricades of Paris" (docs/campaign_a06_build.md):
##   - the data checks out, every text has pt and es, the Crown line lists it after a01 and a01's Crown win leads to it,
##     the seats for solo, co-op and versus (no solo side pick), the map (the city generator's Paris) and the stills
##     load, its war map pin is live and its rules read `varenne`, THE ROSTER LADDER's C3 (the Foundry, the Mortar);
##   - THE FLAGS AT THE START: p01 `families` (the Virginia volunteers), a01 `lyon` calm / sullen / risen / none (the
##     Lyon men at the bridges and the Bastille) and `printer` (Fairleigh's opening line);
##   - PART 1: the three barricades (palisades across the only street), their men, a breach and the rush down the
##     street (the canister tip), each barricade taken, Part 2;
##   - PART 2: Notre-Dame open to harm only now, the bridges, the torch waves over the Petit Pont, Part 3;
##   - PART 3: the hall's ring (spared until now), the breach, Varenne's flight for the boats, his escape (a loss), the
##     CAPTURE, THE CHOICE both ways (`varenne` spared / executed, `paris` stood), the win, the ending by the flags,
##     the progress;
##   - THE DEFEATS (Notre-Dame burnt, the Field Marshal or Father Tomasz killed), VERSUS (the Assembly wins when
##     Notre-Dame burns), THE DIFFICULTY (the Assembly's numbers, Varenne's flight), THE HUB.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_a06.gd
## Prints CHECK lines, then "campaign_a06: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "a06_barricades"
const A01 := "a01_presses"
const P01 := "p01_leaf"
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
	print("campaign_a06: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if p01 and a01 were won by the Crown with these flags ("" for a01's lyon: a01 not in the progress).
func _progress(families: String, lyon := "calm", printer := "taken", diff := "normal") -> void:
	var p := {"reached": [MID], "done": {}, "difficulty": diff}
	if families != "":
		p["done"][P01] = {"won_by": "crown", "side": "crown", "flags": {"families": families}}
	if lyon != "":
		var fl := {"lyon": lyon}
		if printer != "":
			fl["printer"] = printer
		p["done"][A01] = {"won_by": "crown", "side": "crown", "flags": fl}
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
	var g: Game = main.game
	_step(g, 1.0)
	_step(g, 2.0)
	return g


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


func _said(r: MissionRun, id: String) -> bool:
	return r.said_ids.has(id)


## Part 1 done by the script (every barricade's men dead), then Part 2.
func _to_part2(g: Game, r: MissionRun) -> void:
	for b in ["bar_1", "bar_2", "bar_3"]:
		_kill(r, b + "_men")
		_step(g, g.clock + 0.25)
	_step(g, g.clock + 0.5)
	_step(g, g.clock + 6.5)


## Part 2 done by the script: the bridges taken, the three torch waves come and killed, then Part 3.
func _to_part3(g: Game, r: MissionRun) -> void:
	await _to_part2(g, r)
	_kill(r, "bridge_nd_men")
	_kill(r, "bridge_ch_men")
	_step(g, g.clock + 0.5)
	var t0 := float(r.fired["part2"])
	_step(g, t0 + 121.0)
	_kill(r, "torches")
	_kill(r, "torch_escort")
	_step(g, g.clock + 0.5)
	_step(g, g.clock + 5.5)


func _run() -> void:
	await process_frame
	_data()
	await _flags()
	await _part1()
	await _part2()
	await _part3()
	await _defeats()
	await _versus()
	await _difficulty()
	_hub()
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("a06_barricades: data checks out", pr.is_empty(), "; ".join(pr))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings():
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Crown line: p01, a01, then a06", String(sl.get("id", "")) == "prologue" and (sl["missions"] as Array).slice(0, 3) == [P01, A01, MID])
	check("a01 won by the Crown leads to a06 (the Assembly's win nowhere)", Campaign.next_of(A01, "crown") == MID and Campaign.next_of(A01, "assembly") == "")
	check("a06 leads nowhere yet (a07 is not built)", Campaign.next_of(MID, "crown") == "" and Campaign.next_of(MID, "assembly") == "")
	Campaign.save_progress({"reached": [], "done": {}})
	Campaign.record(P01, "solo", "crown", "crown", {"families": "save"})
	check("a06 is locked before a01", not Campaign.unlocked(MID))
	Campaign.record(A01, "solo", "crown", "crown", {"lyon": "calm", "printer": "taken"})
	check("...and open once a01 is won", Campaign.unlocked(MID))
	check("no solo side pick (versus only): the Crown", Campaign.solo_sides(m) == ["crown"])
	var c := Campaign.make_cfg(MID, "solo")
	check("solo: you are the army; the guns, the town, the Assembly scripted", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "script"])
	c = Campaign.make_cfg(MID, "coop", "p1", true)
	check("co-op online: the friend is Ruggieri's guns", c["slots"].map(func(s): return s["who"]) == ["you", "remote", "script", "script"])
	c = Campaign.make_cfg(MID, "versus", "p1", true)
	check("versus online: the friend is the Free Assembly", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "remote"])
	check("the army PURPLE, the town YELLOW, the Assembly GREEN", int(c["slots"][0]["colour"]) == 4 and int(c["slots"][2]["colour"]) == 3 and int(c["slots"][3]["colour"]) == 2)
	var md := Campaign.map_data("paris_barricades")
	check("the map is the city generator's Paris, 128 x 96", String(m["map"]) == "campaign:paris_barricades" and (md.get("size", []) as Array).map(func(x): return int(x)) == [128, 96]
		and (md.get("props", []) as Array).size() > 1000)
	for k in m["stills"]:
		check("still %s: its picture loads" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	check("the opening and the ending per side", (m["opening"] as Dictionary).has("crown") and (m["opening"] as Dictionary).has("assembly")
		and (m["ending"] as Dictionary).has("crown") and (m["ending"] as Dictionary).has("assembly"))
	var army: Dictionary = m["teams"][0]
	check("THE ROSTER LADDER C3: the army may make the Foundry's Mortar, new here", (army["roster"]["new"] as Array) == ["foundry", "mortar"]
		and (army["roster"]["allow"] as Array).has("mortar") and (army["roster"]["allow"] as Array).has("cuirassier") and not (army["roster"]["allow"] as Array).has("church"))
	check("...the NEW cards said to the Crown", (m["lines"] as Dictionary).has("new_foundry") and (m["lines"] as Dictionary).has("new_mortar")
		and String(m["lines"]["new_mortar"]["to"]) == "crown")
	var pin := {}
	var w = JSON.parse_string(FileAccess.get_file_as_string("res://campaign/warmap.json"))
	for p in w["pins"]:
		if String(p["mission"]) == MID:
			pin = p
	check("the war map's pin is live (no working title: the mission's own)", not pin.is_empty() and not pin.has("title"))
	var vals := {}
	var won_by := {}
	for rl in w["rules"]:
		var s := JSON.stringify(rl)
		if s.contains("a06_barricades.varenne"):
			vals[String(rl["if"]["flag"]["a06_barricades.varenne"])] = true
		if rl["if"].has("won_by") and (rl["if"]["won_by"] as Dictionary).has(MID):
			won_by[String(rl["if"]["won_by"][MID])] = true
	check("its rules read `varenne` spared / executed and who won", vals.has("spared") and vals.has("executed") and won_by.has("crown") and won_by.has("assembly"))


# ================================================================== the flags at the start

func _flags() -> void:
	# [families, lyon, printer, volunteers, lyon men]
	for fl in [["save", "calm", "taken", 6, 0], ["leave", "sullen", "taken", 0, 4], ["save", "risen", "", 6, 10], ["", "", "", 0, 0]]:
		_progress(fl[0], fl[1], fl[2])
		var g: Game = await _start()
		var r: MissionRun = g.mission
		var P := "families %s, lyon %s, printer %s: " % [fl[0] if fl[0] != "" else "-", fl[1] if fl[1] != "" else "-", fl[2] if fl[2] != "" else "-"]
		var ids: Array = []
		for pg in r.pages_now(r.data["opening"]["crown"]):
			for l in pg["lines"]:
				ids.append(String(l["id"]) if l is Dictionary else String(l))
		check(P + "the opening's lines", ids.has("f_open_saved") == (fl[0] == "save") and ids.has("f_open_printer") == (fl[2] == "taken")
			and ids.has("f_open_noprinter") == (fl[2] != "taken"), str(ids))
		var vol: Array = r.tagged("volunteers")
		check(P + "the Virginia volunteers (%d), named" % fl[3], vol.size() == fl[3] and vol.all(func(u): return String(u.get_meta("mission_name", "")).contains("Hollins")), str(vol.size()))
		check(P + "the Lyon men (%d)" % fl[4], r.tagged("lyon_men").size() == fl[4], str(r.tagged("lyon_men").size()))
		check(P + "the army: the marshal, the priest, 14 Musketeers, 4 Horsemen, 2 guns and a mortar", r.tagged("fairleigh").size() == 1 and r.tagged("tomasz").size() == 1
			and r.tagged("army_men").size() == 14 and r.tagged("riders").size() == 4 and r.tagged("cannons").size() == 2 and r.tagged("mortars").size() == 1
			and r.tagged("ruggieri").size() == 1 and r.tagged("fairleigh")[0].max_hp >= 320.0)
		check(P + "the camp: a Barracks, the Foundry, the Breeder", r.tagged("foundry").size() == 1 and r.tagged("breeder").size() == 1 and r.tagged("barracks").size() == 1)
		_step(g, 25.0)
		check(P + "the volunteers' lines", _said(r, "v_saved") == (fl[0] == "save"))
		_step(g, 26.0)
		check(P + "the NEW cards", _said(r, "new_foundry") and _said(r, "new_mortar"))


# ================================================================== part 1

func _part1() -> void:
	_progress("save")
	var g: Game = await _start()
	var r: MissionRun = g.mission
	var at := r.team_index("assembly")
	check("part 1: the objectives", r.obj["barricades"] == "active" and r.obj["fairleigh"] == "active" and r.obj["tomasz"] == "active"
		and r.obj["notre_dame"] == "hidden" and r.obj["varenne"] == "hidden")
	for b in ["bar_1", "bar_2", "bar_3"]:
		var walls: Array = r.tagged(b + "_wall")
		check("%s: five palisades across the street, the Assembly's" % b, walls.size() == 5 and walls.all(func(w): return w.team == at))
	check("the barricades' men: 6, 8 (a captured gun), 10", r.tagged("bar_1_men").size() == 6 and r.tagged("bar_2_men").size() == 8 and r.tagged("bar_3_men").size() == 10
		and r.tagged("captured_guns").size() == 2, str([r.tagged("bar_1_men").size(), r.tagged("bar_2_men").size(), r.tagged("bar_3_men").size()]))
	check("Notre-Dame, the hall, its ring and its men are spared until their part", r.tagged("notre_dame")[0].spared and r.tagged("hall")[0].spared
		and r.tagged("ring").all(func(b): return b.spared) and r.tagged("hall_men").all(func(u): return u.spared) and r.tagged("varenne")[0].spared)
	check("the hall's ring: palisades and one gate (the west side's, the Assembly's way out)", r.tagged("ring").size() > 40
		and r.tagged("ring").filter(func(b): return b.kind == "gate").size() == 1)
	# a breach: one palisade of the first barricade down
	r.tagged("bar_1_wall")[2].take_damage(1e9, null)
	_step(g, 30.0)
	check("A BREACH: the rush comes out down the street (3 pikes, 2 militia)", r.fired.has("breach_bar_1") and r.tagged("rush_bar_1").size() == 5
		and r.tagged("rush_bar_1").filter(func(u): return u.kind == "pikeman").size() == 3)
	_step(g, 31.25)
	check("...Ruggieri calls for canister (the tip, the card pointed at)", _said(r, "r_rush") and _said(r, "tip_canister"))
	_kill(r, "bar_1_men")
	_step(g, 32.0)
	check("BARRICADE 1 TAKEN: 1 of 3", int(r.counters["taken"]) == 1 and _said(r, "f_bar_1") and r.objective_text(r.objective("barricades")).begins_with("Take the three"))
	_kill(r, "bar_2_men")
	_kill(r, "bar_3_men")
	_step(g, 33.0)
	check("all three taken", int(r.counters["taken"]) == 3 and _said(r, "f_bar_3"))
	_step(g, 38.5)
	check("not Part 2 at once", not r.fired.has("part2"))
	_step(g, 39.5)
	check("PART 2 six seconds after: the barricades done, the bridges and Notre-Dame shown", r.fired.has("part2") and r.obj["barricades"] == "done"
		and r.obj["bridges"] == "active" and r.obj["notre_dame"] == "active" and not r.tagged("notre_dame")[0].spared)


# ================================================================== part 2

func _part2() -> void:
	_progress("save", "sullen")
	var g: Game = await _start()
	var r: MissionRun = g.mission
	await _to_part2(g, r)
	var t0 := float(r.fired["part2"])
	_step(g, t0 + 13.0)
	check("sullen Lyon: the narrator names the Lyon men, Tomasz knows them", _said(r, "n_lyon_sullen") and _said(r, "t_lyon") and not _said(r, "n_lyon_risen"))
	_step(g, t0 + 39.0)
	check("no torches before 0:40", r.tagged("torches").is_empty())
	_step(g, t0 + 40.5)
	var tor: Array = r.tagged("torches")
	check("THE FIRST TORCH WAVE at the Place Maubert: 2 torch-bearers, 2 militia", tor.size() == 2 and tor.all(func(u): return u.has_meta("torch")) and r.tagged("torch_escort").size() == 2
		and _said(r, "n_torch"))
	check("...sent over the Petit Pont to the parvis", tor.all(func(u): return u.order == "move"))
	_kill(r, "bridge_nd_men")
	_step(g, t0 + 41.0)
	check("the Pont Notre-Dame taken (its Lyon men too): 1 of 2", int(r.counters["bridges"]) == 1)
	_kill(r, "bridge_ch_men")
	_step(g, t0 + 41.5)
	check("BOTH BRIDGES: done", int(r.counters["bridges"]) == 2 and r.obj["bridges"] == "done" and _said(r, "f_bridges"))
	_kill(r, "torches")
	_step(g, t0 + 60.0)
	check("Part 3 waits for the torch waves", not r.fired.has("part3"))
	_step(g, t0 + 120.5)
	check("the third wave at 2:00", r.fired.has("torch_3") and r.tagged("torches").size() == 2)
	_kill(r, "torches")
	_step(g, g.clock + 0.5)
	_step(g, g.clock + 5.5)
	check("PART 3: the torches stopped, the bridges held", r.fired.has("part3") and r.obj["varenne"] == "active" and r.obj["bridges"] == "hidden" and _said(r, "f_3"))
	check("...the ring and the hall's men open to attack, the hall itself kept", r.tagged("ring").all(func(b): return not b.spared) and r.tagged("hall_men").all(func(u): return not u.spared)
		and not r.tagged("varenne")[0].spared and r.tagged("hall")[0].spared)
	check("Varenne can't be killed: a capture's floor", r.tagged("varenne")[0].hp_floor > 0.0)


# ================================================================== part 3: the flight, the capture, the choice

func _part3() -> void:
	# ---- the flight and the escape (a loss)
	_progress("save")
	var g: Game = await _start()
	var r: MissionRun = g.mission
	await _to_part3(g, r)
	r.tagged("ring")[0].take_damage(1e9, null)
	_step(g, g.clock + 0.5)
	check("THE RING BREACHED: the marshal warns", r.fired.has("breached") and _said(r, "f_breach"))
	var tb := float(r.fired["breached"])
	_step(g, tb + 11.0)
	check("Varenne holds 12 s (NORMAL)", not r.fired.has("flight_normal"))
	_step(g, tb + 12.5)
	var va: Unit = r.tagged("varenne")[0]
	check("...then RUNS for the boats with his guard", r.fired.has("flight_normal") and va.order == "move" and _said(r, "n_flight") and not r.fired.has("flight_easy"))
	_put(g, [va], r.area_rect("port").get_center())
	_walk(g, g.clock + 10.0)
	check("at the quay: the boat waits (not yet gone)", not g.over and _said(r, "n_quay"))
	_walk(g, g.clock + 11.0)
	check("20 s at the quay: VARENNE ESCAPES, the Crown loses", g.over and r.winner_side == "assembly" and r.obj["varenne"] == "failed" and _said(r, "n_escaped"))
	# ---- the capture and the choice: SPARED
	for v in ["spared", "executed"]:
		_progress("save", "calm", "taken")
		g = await _start()
		r = g.mission
		await _to_part3(g, r)
		va = r.tagged("varenne")[0]
		va.take_damage(1e6, null)
		check(v + ": Varenne worn down to a quarter, alive", not va.dead and va.hp <= va.max_hp * 0.25 + 0.5)
		var man: Unit = r.tagged("army_men")[0]
		_put(g, [man], va.position + Vector2(20, 0))
		_step(g, g.clock + 0.5)
		_step(g, g.clock + 0.25)
		check(v + ": TAKEN ALIVE", r.obj["varenne"] == "done" and r.captured.has("varenne") and _said(r, "va_taken"))
		_step(g, g.clock + 8.5)
		check(v + ": THE CHOICE: Tomasz asks for mercy, the marshal leaves the order to you", r.fired.has("verdict") and _said(r, "t_mercy") and _said(r, "f_order")
			and String(r.choice_open.get("id", "")) == "varenne" and String(r.choice_open.get("default", "")) == "spared")
		r.choose("varenne", v)
		_step(g, g.clock + 0.5)
		check(v + ": the flag, the lines", r.flags.get("varenne", "") == v and _said(r, "f_spared" if v == "spared" else "f_exec"))
		_step(g, g.clock + 1.5)
		check(v + ": `paris` stood", r.flags.get("paris", "") == "stood")
		_step(g, g.clock + 7.5)
		_step(g, g.clock + 5.5)
		check(v + ": PARIS IS THE KING'S: the Crown wins", g.over and r.winner_side == "crown")
		await create_timer(1.8).timeout
		var show: StillShow = null
		for n in main.ui_layer.get_children():
			if n is StillShow:
				show = n
		check(v + ": the Crown's ending plays", show != null)
		if show:
			for i in 20:
				if is_instance_valid(show) and not show.is_queued_for_deletion():
					show.next()
			var want := ["f_end1", "f_end_spared", "f_end_saved", "t_end_spared", "k_end_spared", "k_end2"] if v == "spared" \
				else ["f_end1", "f_end_exec", "f_end_saved", "t_end_exec", "k_end_exec", "k_end2"]
			check(v + ": the ending's lines by the flags", show.shown_ids == want, str(show.shown_ids))
		var p := Campaign.progress()
		check(v + ": it counts: done by the Crown, `varenne` and `paris` kept", (p["done"] as Dictionary).has(MID) and Campaign.flag(MID, "varenne") == v
			and Campaign.flag(MID, "paris") == "stood")
	# ---- the choice unanswered: the canon (spared)
	_progress("save")
	g = await _start()
	r = g.mission
	await _to_part3(g, r)
	va = r.tagged("varenne")[0]
	va.take_damage(1e6, null)
	_put(g, [r.tagged("army_men")[0]], va.position + Vector2(20, 0))
	_step(g, g.clock + 0.5)
	_step(g, g.clock + 8.5)
	_step(g, g.clock + 121.0)
	check("the choice left unanswered: the canon, SPARED", r.flags.get("varenne", "") == "spared")


# ================================================================== the defeats

func _defeats() -> void:
	_progress("leave")
	var g: Game = await _start()
	var r: MissionRun = g.mission
	await _to_part2(g, r)
	_kill(r, "notre_dame")
	_step(g, g.clock + 0.5)
	check("NOTRE-DAME BURNT: the Crown loses", g.over and r.winner_side == "assembly" and r.obj["notre_dame"] == "failed" and _said(r, "n_nd_burnt"))
	check("...and it does not count", not (Campaign.progress()["done"] as Dictionary).has(MID))
	for who in ["fairleigh", "tomasz"]:
		g = await _start()
		r = g.mission
		_step(g, 20.0)
		_kill(r, who)
		_step(g, 21.0)
		check("%s killed: the Crown loses" % who, g.over and r.winner_side == "assembly" and r.obj[who] == "failed")


# ================================================================== versus (offline: the Assembly scripted)

func _versus() -> void:
	_progress("save")
	var g: Game = await _start("versus")
	var r: MissionRun = g.mission
	check("versus: the Assembly's objective", r.objectives_for("assembly").map(func(o): return o["id"]) == ["a_hold"])
	check("versus: the Assembly's own lines", _said(r, "a_1") and not _said(r, "f_1"))
	await _to_part2(g, r)
	_kill(r, "notre_dame")
	_step(g, g.clock + 0.5)
	check("versus: Notre-Dame burnt wins it for the Assembly", g.over and r.winner_side == "assembly" and r.obj["a_hold"] == "done")
	await create_timer(1.8).timeout
	var p := Campaign.progress()
	check("versus: the story follows the winner (the Assembly)", (p["done"] as Dictionary).has(MID) and String(p["done"][MID]["won_by"]) == "assembly")


# ================================================================== the difficulty

func _difficulty() -> void:
	for d in [["easy", 3, 25], ["hard", 5, 6]]:
		_progress("save", "calm", "taken", d[0])
		var g: Game = await _start()
		var r: MissionRun = g.mission
		var n := r.tagged("bar_1_men").filter(func(u): return u.kind == "musketeer").size()
		check("%s: the first barricade's militia scaled (%d)" % [d[0], d[1]], n == int(d[1]), str(n))
		check("%s: the army is the player's: never scaled" % d[0], r.tagged("army_men").size() == 14 and r.tagged("volunteers").size() == 6)
		await _to_part3(g, r)
		r.tagged("ring")[0].take_damage(1e9, null)
		_step(g, g.clock + 0.5)
		var tb := float(r.fired["breached"])
		_step(g, tb + float(d[2]) - 1.0)
		check("%s: Varenne not yet away" % d[0], not r.fired.has("flight_" + d[0]))
		_step(g, tb + float(d[2]) + 0.5)
		check("%s: he runs %d s after the breach" % [d[0], d[2]], r.fired.has("flight_" + d[0]) and not r.fired.has("flight_normal"))
	Campaign.set_difficulty("normal")


# ================================================================== the hub

func _hub() -> void:
	var sl := Campaign.storyline_of(MID)
	var hub: Dictionary = sl["hub"]
	for v in ["spared", "executed"]:
		var after := {"done": {P01: {"side": "crown"}, A01: {"side": "crown"}, MID: {"side": "crown", "flags": {"varenne": v}}}}
		var kl: Array = CampaignMenu.talk_lines(hub["talks"]["king"], after)
		check("the King's talk after a06 (%s)" % v, String(kl[0]).contains("Varenne") and String(kl[0]).contains("sea" if v == "spared" else "signed"), str(kl))
		var tl: Array = CampaignMenu.talk_lines(hub["talks"]["tomasz"], after)
		check("the Cardinal's talk after a06 (%s)" % v, String(tl[0]).contains("asked for his life" if v == "spared" else "last night"), str(tl))
	var fl: Array = CampaignMenu.talk_lines(hub["talks"]["fairleigh"], {"done": {P01: {"side": "crown"}, MID: {"side": "crown", "flags": {"varenne": "spared"}}}})
	check("Fairleigh's letter after a06", String(fl[0]).contains("Paris is quiet"))
