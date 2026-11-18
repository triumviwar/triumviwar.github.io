extends SceneTree
## Act 1's "Father Ferrer's Visit" (docs/campaign_a04_build.md):
##   - the data checks out, every text has pt and es, the Clockmaker line lists it after a02 and a02's guild win leads
##     to it, the seats for solo, co-op and versus (no solo side pick), the map (a02's grown) and the stills load;
##   - THE FLAGS at the start (a02 `furth` strong / thin and missing, `jakob` lost in a02 or c01, c01 `gate` people, a01
##     played or not), the roster ladder's K3 for the guild;
##   - PART 1 played through: the six STAYs, the two signs, Hollweg called away, Jakob's bin (or, Jakob lost, the log in
##     the barn), the dusk countdown and its loss;
##   - PART 2: the night, the mesh disguised, the night Winder's way (ROUTE), too close (it turns back and sets out
##     again), too far (the brother's word), the bank, the reveal (pattern / people), the dawn and its loss;
##   - PART 3: the convert, the march, the exit counted (lost_to_machine), the machine's sortie, the guild's Pendulum,
##     the riot over; THE CHOICE both ways (and its default), the flags, the win, the ending and debrief;
##   - the defeats (Ferrer, Hollweg), VERSUS (the machine's objective and its win by the count), the DIFFICULTY (the riot,
##     the machine's numbers, the raced clocks), the HUBS after a04 (Fürth and the King's study).
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_a04.gd
## Prints CHECK lines, then "campaign_a04: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "a04_visit"
const A02 := "a02_furth"
const C01 := "c01_thirteenth"
const C01_DEF := {"bells": "quiet", "saved": "some", "jakob": "alive", "cut": "no", "gate": "pattern"}
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
	print("campaign_a04: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if c01 and a02 were won by the guild with these flags (a02: {"furth", "jakob"}; c01 merged over its
## defaults; a01: {} not played), at a difficulty. a02 = null: a02 (and c01) not in the progress at all.
func _progress(a02: Variant, c01 := {}, a01 := {}, diff := "normal") -> void:
	var p := {"reached": [MID], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if a02 is Dictionary:
		var f: Dictionary = C01_DEF.duplicate()
		f.merge(c01, true)
		p["done"][C01] = {"won_by": "guild", "side": "guild", "flags": f}
		var f2 := {"stopwork": "fitted", "furth": "strong", "furth_n": 12, "jakob": "alive"}
		f2.merge(a02, true)
		p["done"][A02] = {"won_by": "guild", "side": "guild", "flags": f2}
	if not a01.is_empty():
		p["done"]["a01_presses"] = {"won_by": "crown", "side": "crown", "flags": a01}
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
	r._tick_routes()
	r._tick_disguise()
	if not r.choice_open.is_empty() and g.clock >= float(r.choice_open.get("until", INF)):
		r.choose(String(r.choice_open["id"]), String(r.choice_open.get("default", "")))
	r._run_triggers()
	r._check_objectives()


## Steps from the clock now to `to`, a quarter second at a time (a STAY needs every check).
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
		i += 1
	g._rebuild_hash()


func _mid(r: MissionRun, area: String) -> Vector2:
	return r.area_rect(area).get_center()


func _said(r: MissionRun, id: String) -> bool:
	return r.said_ids.has(id)


func _n(g: Game, t: int, kind: String) -> int:
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind == kind).size()


## Part 1 by the script: Ferrer stays in each workshop in turn (Jakob brought to him, or the log read).
func _inspect(g: Game, r: MissionRun) -> void:
	var fe: Unit = r.tagged("ferrer")[0]
	for i in 6:
		_put(g, [fe], _mid(r, "ws_%d" % (i + 1)))
		_walk(g, g.clock + 10.75)
		if i == 2:
			_walk(g, g.clock + 4.5)
			if not r.tagged("jakob").is_empty():
				_put(g, r.tagged("jakob"), fe.position + Vector2(20, 0))
				_walk(g, g.clock + 0.5)
	if r.objective("log") and r.obj.get("log", "") == "active":
		_put(g, [fe], _mid(r, "barn"))
		_walk(g, g.clock + 10.75)


## Part 2 by the script: the night, the night Winder walked along its way (the party with it), the bank, the reveal.
func _night(g: Game, r: MissionRun) -> void:
	_walk(g, g.clock + 6.5)       # (part2)
	_walk(g, g.clock + 20.5)      # (night)
	_put(g, r.tagged("escort") + r.tagged("brothers"), r.tagged("ferrer")[0].position + Vector2(0, 3 * Defs.TILE))
	_walk(g, g.clock + 8.5)       # (leg1)
	var w: Array = r.tagged("night_winder")
	for leg in [["w_town", "w_camp"], ["w_line", "w_west"], ["bank"]]:
		for wp in leg:
			_put(g, w, _mid(r, wp))
			_step(g, g.clock + 0.25)
			_step(g, g.clock + 0.25)
		_walk(g, g.clock + 12.5)
	_put(g, r.tagged("ferrer"), r.area_rect("bank_watch").position + Vector2(64, 64))
	_walk(g, g.clock + 3.5)


func _run() -> void:
	await process_frame
	_data()
	await _flags()
	await _play()
	await _play_jakob_lost()
	await _night_rules()
	await _defeats()
	await _versus()
	await _difficulty()
	await _hub()
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("a04_visit: data checks out", pr.is_empty(), "; ".join(pr))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + ["The night Winder", "Gear ground"]:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	for role in ["ferrer_visit", "lay_brother"]:
		var ab := String(Rebels.ROLES[role]["about"])
		check("the role %s and its words" % role, LangPt.T.has(ab) and LangEs.T.has(ab))
	var sl := Campaign.storyline_of(MID)
	check("the Clockmaker line: c01, a02, then a04", String(sl.get("id", "")) == "clockmaker" and (sl["missions"] as Array).slice(0, 3) == [C01, A02, MID])
	check("a02 won by the guild leads to a04 (a machine win leads nowhere)", Campaign.next_of(A02, "guild") == MID and Campaign.next_of(A02, "machine") == "")
	check("a04 leads nowhere yet (a07 is not built)", Campaign.next_of(MID, "visit") == "" and Campaign.next_of(MID, "machine") == "")
	Campaign.save_progress({"reached": [], "done": {"p01_leaf": {}, C01: {"won_by": "guild"}}})
	check("a04 is locked before a02", not Campaign.unlocked(MID))
	Campaign.record(A02, "solo", "guild", "guild", {"furth": "strong"})
	check("...and open once a02 is won by the guild", Campaign.unlocked(MID))
	check("no solo side pick (versus only): the visit", Campaign.solo_sides(m) == ["visit"])
	var c := Campaign.make_cfg(MID, "solo")
	check("solo: you are Ferrer's party; the guild, the works and the machine scripted", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "script"])
	c = Campaign.make_cfg(MID, "coop", "p1", true)
	check("co-op online: the friend is the guild", c["slots"].map(func(s): return s["who"]) == ["you", "remote", "script", "script"])
	c = Campaign.make_cfg(MID, "versus", "p1", true)
	check("versus online: the friend is the machine", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "remote"])
	check("the party PURPLE, the guild BLUE, the machine RED", int(c["slots"][0]["colour"]) == 4 and int(c["slots"][1]["colour"]) == 0 and int(c["slots"][3]["colour"]) == 1)
	var md := Campaign.map_data("furth_works")
	var md2 := Campaign.map_data("furth_line")
	check("the map is Fürth grown: a02's ground, autumn, 128 x 80", String(m["map"]) == "campaign:furth_works" and String(md.get("biome", "")) == "autumn"
		and (md.get("size", []) as Array).map(func(x): return int(x)) == [128, 80] and String(md["cells"]) == String(md2["cells"]))
	for k in m["stills"]:
		check("still %s: its picture loads" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	check("the opening and the ending per side", (m["opening"] as Dictionary).has("visit") and (m["ending"] as Dictionary).has("visit") and (m["ending"] as Dictionary).has("machine"))
	check("the narrator is Ferrer, framed by the King", (m["opening"]["visit"] as Array).all(func(pg): return (pg["lines"] as Array).all(
		func(l): return String(m["lines"][l]["who"]) in ["king", "ferrer"])))
	var guild: Dictionary = {}
	for tm in m["teams"]:
		if tm["id"] == "guild":
			guild = tm
	check("the roster ladder's K3: the guild may build the Heavy Works and the Pendulum, and they are NEW",
		(guild["roster"]["allow"] as Array).has("heavy_works") and (guild["roster"]["allow"] as Array).has("pendulum") and guild["roster"]["new"] == ["heavy_works", "pendulum"])
	check("the war map's pin is live (no planned title) and its rules name this mission's flags", WarMapData.problems().is_empty(), "; ".join(WarMapData.problems()))


# ================================================================== the flags at the start

func _flags() -> void:
	for it in [["strong", {"furth": "strong"}, 8], ["thin", {"furth": "thin"}, 5], ["none", null, 8]]:
		_progress(it[1])
		var g := await _start()
		var r: MissionRun = g.mission
		var pt := r.team_index("party")
		var gt := r.team_index("guild")
		var P := "flags %s: " % it[0]
		check(P + "the escort is %d Musketeers" % it[2], r.tagged("escort").size() == int(it[2]), str(r.tagged("escort").size()))
		check(P + "Ferrer and two lay brothers", r.tagged("ferrer").size() == 1 and r.tagged("brothers").size() == 2 and r.tagged("ferrer")[0].team == pt)
		check(P + "the gate men", r.tagged("gap_men").size() == 4 and r.tagged("gate_men").size() == 3)
		check(P + "Hollweg and Jakob at the works", r.tagged("hollweg").size() == 1 and r.tagged("jakob").size() == 1 and r.tagged("hollweg")[0].team == gt)
		check(P + "the Honest One, the six workshops (spared), the Pendulum", r.tagged("honest").size() == 1 and r.tagged("shops").size() == 6
			and r.tagged("shops").all(func(b): return b.spared and b.team == gt) and r.tagged("g_pendulum").size() == 1)
		check(P + "the winding pair in the Escapement", r.tagged("pair").size() == 3)
		check(P + "the machine's meadow seed and links (spared)", r.tagged("seed_meadow").size() == 1 and r.tagged("seed_meadow")[0].spared and r.tagged("links").size() == 3)
		check(P + "the line dug, the road gate set, the meadow gap open", r.tagged("earthworks").filter(func(b): return b.kind == "gate").size() == 2
			and not r.tagged("earthworks").any(func(b): return b.cell.y >= 47 and b.cell.y <= 50))
		check(P + "the guild may build K3 (Heavy Works, Pendulum), not the Ballista", not r.denied(gt, "heavy_works") and not r.denied(gt, "pendulum") and r.denied(gt, "ballista"))
		check(P + "the dusk clock (10:00)", absf(float(r.clocks.get("dusk", 0.0)) - 1.0 - 600.0) < 1.0, str(r.clocks))
		check(P + "the intro said; the NEW cards to come", _said(r, "f_1") and _said(r, "h_1"))
		_walk(g, 9.0)
		check(P + "the K3 NEW cards said", _said(r, "new_heavy_works") and _said(r, "new_pendulum"))
		if it[0] == "thin":
			_walk(g, 16.0)
			check(P + "Ferrer on the thin escort", _said(r, "f_thin"))
	# Jakob lost in a02, or in c01
	for it in [["a02", {"jakob": "lost"}, {}], ["c01", {}, {"jakob": "lost"}]]:
		_progress(it[1], it[2])
		var g := await _start()
		var r: MissionRun = g.mission
		check("Jakob lost in %s: no Jakob at Fürth" % it[0], r.tagged("jakob").is_empty())


# ================================================================== the visit played through (c01's defaults, a01 played)

func _play() -> void:
	_progress({"furth": "strong"}, {}, {"lyon": "calm", "printer": "taken"})
	var g := await _start()
	var r: MissionRun = g.mission
	var fe: Unit = r.tagged("ferrer")[0]
	var mt := r.team_index("machine")
	# ---- PART 1: a STAY of 6 s in each workshop
	_put(g, [fe], _mid(r, "ws_1"))
	_walk(g, g.clock + 9.0)
	check("p1: 9 s in the Light Works is not enough", int(r.counters["inspected"]) == 0)
	_walk(g, g.clock + 1.75)
	check("p1: 10 s: inspected 1, nothing there", int(r.counters["inspected"]) == 1 and _said(r, "f_ws1"))
	_put(g, [fe], _mid(r, "ws_2"))
	_walk(g, g.clock + 10.75)
	check("p1: the Escapement: a Winder winding another (the sign)", int(r.counters["inspected"]) == 2 and _said(r, "f_wind") and _said(r, "h_wind"))
	_put(g, [fe], _mid(r, "ws_3"))
	_walk(g, g.clock + 10.75)
	check("p1: three seen: Hollweg called away to the presses", r.fired.has("called_away") and _said(r, "j_call"))
	_walk(g, g.clock + 4.5)
	check("p1: Jakob wants a word (the objective), he comes to the Father", r.obj["jakob_bin"] == "active" and _said(r, "j_word"))
	_put(g, r.tagged("jakob"), fe.position + Vector2(20, 0))
	_walk(g, g.clock + 0.5)
	check("p1: Jakob's bin: the stop-works taken out (told the Father)", r.obj["jakob_bin"] == "done" and _said(r, "j_bin") and _said(r, "f_bin")
		and r.flags.get("stopworks", "") == "found")
	_put(g, [fe], _mid(r, "ws_5"))
	_walk(g, g.clock + 10.75)
	check("p1: the lockers: the Assembly's pamphlets", _said(r, "f_print"))
	_walk(g, g.clock + 8.5)
	check("p1: ...on the Lyon type (a01 played)", _said(r, "f_type") and not _said(r, "f_type_no"))
	_put(g, [fe], _mid(r, "ws_4"))
	_walk(g, g.clock + 10.75)
	_put(g, [fe], _mid(r, "ws_6"))
	_walk(g, g.clock + 10.75)
	check("p1: six of six: the inspection done; no log needed (Jakob told)", int(r.counters["inspected"]) == 6 and r.obj["inspect"] == "done" and r.obj["log"] != "active")
	check("p1: a workshop counts once", r.fired.has("ws_6"))
	# ---- PART 2: the night
	_walk(g, g.clock + 6.5)
	check("p2: dusk; the inspection off the panel; the dusk clock stopped", r.fired.has("part2") and not r.clocks.has("dusk") and r.obj["inspect"] == "hidden")
	_walk(g, g.clock + 20.5)
	check("p2: night: the broken ones on the bank and by the Mainspring (10 + 5, the works'), the night Winder", r.tagged("broken").size() == 15
		and r.tagged("shift").size() == 5
		and r.tagged("broken").all(func(u): return u.team == r.team_index("works")) and r.tagged("night_winder").size() == 1)
	check("p2: the gear ground nobody laid: the works' own (no guild hand built it)", r.tagged("mesh").size() == 1 and r.tagged("mesh")[0].team == r.team_index("works"))
	check("p2: follow it; the dawn clock (7:00)", r.obj["follow"] == "active" and r.obj["dawn"] == "active" and absf(float(r.clocks["dawn"]) - g.clock - 420.0 + 0.5) < 2.0)
	_put(g, r.tagged("escort") + r.tagged("brothers"), fe.position + Vector2(0, 3 * Defs.TILE))
	_walk(g, g.clock + 8.5)
	var w: Array = r.tagged("night_winder")
	check("p2: the Winder sets out (a route)", r._routes.any(func(rt): return String(rt["name"]) == "leg1"))
	for wp in ["w_town", "w_camp"]:
		_put(g, w, _mid(r, wp))
		_step(g, g.clock + 0.25)
		_step(g, g.clock + 0.25)
	check("p2: leg 1 done", r.route_done.has("leg1"))
	_walk(g, g.clock + 12.5)
	for wp in ["w_line", "w_west"]:
		_put(g, w, _mid(r, wp))
		_step(g, g.clock + 0.25)
		_step(g, g.clock + 0.25)
	_walk(g, g.clock + 12.5)
	_put(g, w, _mid(r, "bank"))
	_step(g, g.clock + 0.25)
	_step(g, g.clock + 0.25)
	check("p2: at the bank: followed; watch from the bank", r.obj["follow"] == "done" and r.obj["watch"] == "active" and _said(r, "b_bank"))
	_put(g, [fe], r.area_rect("bank_watch").position + Vector2(64, 64))
	_walk(g, g.clock + 3.5)
	check("p2: THE REVEAL: the meshing seen", r.fired.has("reveal") and _said(r, "n_mesh"))
	_walk(g, g.clock + 1.5)
	check("p2: the pattern (c01 canon): the Perpetual's drawings", _said(r, "f_pattern") and not _said(r, "f_people"))
	check("p2: the dawn clock stopped", not r.clocks.has("dawn"))
	# ---- PART 3: the riot
	var broken: Array = r.tagged("broken").duplicate()
	_walk(g, g.clock + 12.5)
	check("p3: the riot: the broken ones stutter (the warning)", r.fired.has("riot") and int(r.counters["riot"]) == 15 and r.obj["riot"] == "active")
	check("p3: the winding pair stopped by Hollweg's key (caged, kept out of it)", r.tagged("pair").all(func(u): return u.m_pace == 0.0 and u.spared))
	_walk(g, g.clock + 4.5)
	check("p3: they turn RED (the machine's) and are the rioters", broken.all(func(u): return u.team == mt) and r.tagged("rioters").size() == 15)
	_walk(g, g.clock + 1.0)
	check("p3: they march for the machine's ground", r.fired.has("riot_march") and _said(r, "h_pend"))
	check("p3: the guild's Pendulum holds the yard's gate (on its ground)", r.tagged("g_pendulum")[0].order == "hold" and g.in_field(r.team_index("guild"), r.tagged("g_pendulum")[0].position))
	# two of them reach the machine's ground: counted and gone
	var rio: Array = r.tagged("rioters")
	_put(g, rio.slice(0, 2), _mid(r, "meadow_ground"))
	_step(g, g.clock + 0.25)
	check("p3: two reach the machine's ground: lost_to_machine 2, taken off", int(r.counters["lost_to_machine"]) == 2 and r.tagged("rioters").size() == 13)
	_walk(g, g.clock + 10.0)
	check("p3: the machine's sortie out to meet them", r.tagged("sortie").size() == 8 and r.fired.has("m_sortie"))
	# the rest stopped
	_kill(r, "rioters")
	_walk(g, g.clock + 3.5)
	check("p3: the riot over (the rest stopped)", r.obj["riot"] == "done" and _said(r, "f_some"))
	check("p3: the flag lost_to_machine is the count (2)", int(r.flags.get("lost_to_machine", -1)) == 2 and int(r.flags.get("lost_to_machine_n", -1)) == 2)
	_walk(g, g.clock + 6.5)
	check("THE CHOICE: THE BROKEN ONES, offered to the visit", String(r.choice_open.get("id", "")) == "broken" and String(r.choice_open.get("default", "")) == "kept")
	r.choose("broken", "melted")
	_walk(g, g.clock + 1.5)
	check("melted: the flag, Ferrer's and Hollweg's lines", r.flags.get("broken", "") == "melted" and _said(r, "f_melted") and _said(r, "h_melted"))
	check("Jakob alive (flag)", r.flags.get("jakob", "") == "alive")
	_walk(g, g.clock + 12.0)
	check("THE VISIT ENDS: a win for the visit", g.over and r.winner_side == "visit")
	var pages := r.pages_now(r.data["ending"]["visit"])
	var ids: Array = []
	for pg in pages:
		ids.append_array(pg["lines"])
	check("the ending: melted, the lost counted, Jakob's word; the King", ids.has("f_end_melted") and ids.has("f_end_lost") and ids.has("f_end_jakob")
		and not ids.has("f_end_kept") and ids.has("k_end_melted"), str(ids))
	await create_timer(1.8).timeout
	var p := Campaign.progress()
	check("the progress: done by the visit, the flags kept", (p["done"] as Dictionary).has(MID) and String(p["done"][MID]["won_by"]) == "visit"
		and String(p["done"][MID]["flags"]["broken"]) == "melted")


# ================================================================== Jakob lost, the people, the choice's default

func _play_jakob_lost() -> void:
	_progress({"furth": "thin", "jakob": "lost"}, {"gate": "people"})
	var g := await _start()
	var r: MissionRun = g.mission
	var fe: Unit = r.tagged("ferrer")[0]
	for i in 6:
		_put(g, [fe], _mid(r, "ws_%d" % (i + 1)))
		_walk(g, g.clock + 10.75)
	check("jakob lost: a journeyman calls Hollweg away (not Jakob)", _said(r, "n_call") and not _said(r, "j_call"))
	check("jakob lost: read his old log in the barn (the objective)", r.obj["log"] == "active" and not r.fired.has("part2"))
	_walk(g, g.clock + 8.0)
	check("jakob lost: no Part 2 before the log", not r.fired.has("part2"))
	check("jakob lost: no Jakob comes; the plain pamphlets (a01 not played)", not r.fired.has("jakob_comes") and _said(r, "f_type_no"))
	_put(g, [fe], _mid(r, "barn"))
	_walk(g, g.clock + 10.75)
	check("jakob lost: the log read: the same signs two years before", r.obj["log"] == "done" and _said(r, "f_log2") and r.flags.get("stopworks", "") == "logged")
	_walk(g, g.clock + 6.5)
	check("jakob lost: Part 2", r.fired.has("part2"))
	_walk(g, g.clock + 20.5)
	check("people: 17 broken (two salvaged)", r.tagged("broken").size() == 17 and r.tagged("salvaged").size() == 2)
	_put(g, r.tagged("escort") + r.tagged("brothers"), fe.position + Vector2(0, 3 * Defs.TILE))
	_walk(g, g.clock + 8.5)
	var w: Array = r.tagged("night_winder")
	for leg in [["w_town", "w_camp"], ["w_line", "w_west"], ["bank"]]:
		for wp in leg:
			_put(g, w, _mid(r, wp))
			_step(g, g.clock + 0.25)
			_step(g, g.clock + 0.25)
		_walk(g, g.clock + 12.5)
	# (a man of the party by the gear ground works as well as the Father's stay)
	_put(g, [fe], r.tagged("mesh")[0].center() + Vector2(0, 40))
	_walk(g, g.clock + 3.0)
	check("people: the reveal: salvaged red parts", r.fired.has("reveal") and _said(r, "f_people") and not _said(r, "f_pattern"))
	_walk(g, g.clock + 18.0)
	_kill(r, "rioters")
	_walk(g, g.clock + 10.0)
	check("none lost: Ferrer's thanks, lost_to_machine 0", _said(r, "f_none") and int(r.flags.get("lost_to_machine", -1)) == 0)
	# nobody answers: KEPT (the canon)
	_walk(g, g.clock + 121.0)
	check("the choice unanswered: KEPT (the default, canon)", r.flags.get("broken", "") == "kept" and _said(r, "h_kept"))
	check("Jakob lost (flag carried)", r.flags.get("jakob", "") == "lost")
	_walk(g, g.clock + 12.0)
	check("kept: the visit wins", g.over and r.winner_side == "visit")
	var ids: Array = []
	for pg in r.pages_now(r.data["ending"]["visit"]):
		ids.append_array(pg["lines"])
	check("the ending: kept, nothing lost, no Jakob's word; the King's mistake", ids.has("f_end_kept") and not ids.has("f_end_lost") and not ids.has("f_end_jakob")
		and ids.has("k_end_kept"), str(ids))


# ================================================================== the night Winder's rules

func _night_rules() -> void:
	_progress({"furth": "strong"})
	var g := await _start()
	var r: MissionRun = g.mission
	_inspect(g, r)
	_walk(g, g.clock + 6.5)
	_walk(g, g.clock + 20.5)
	_walk(g, g.clock + 8.5)
	var w: Unit = r.tagged("night_winder")[0]
	var esc: Array = r.tagged("escort")
	# too far: nobody within 8 tiles for 10 s: the brother's word (the Winder doesn't wait)
	_put(g, r.tagged("ferrer") + r.tagged("brothers") + esc, Vector2(10, 10) * Defs.TILE)
	_put(g, r.tagged("gap_men") + r.tagged("gate_men"), Vector2(12, 70) * Defs.TILE)
	_put(g, [w], _mid(r, "w_town"))
	_walk(g, g.clock + 11.5)
	check("night: lost from sight 10 s: the brother says where it went", _said(r, "b_lost"))
	# too close: within 3 tiles: it turns back, then sets out again
	_put(g, [esc[0]], w.position + Vector2(Defs.TILE * 2, 0))
	_walk(g, g.clock + 1.25)
	check("night: too close: it sees you and stops", r.fired.has("spotted") and int(r.counters["turning"]) == 1 and _said(r, "n_spotted")
		and not r._routes.any(func(rt): return String(rt["name"]) == "leg1"))
	_walk(g, g.clock + 13.0)
	check("night: it waits while you stand close", not r.fired.has("resume_1") and int(r.counters["turning"]) == 1)
	_put(g, [esc[0]], Vector2(10, 10) * Defs.TILE)
	_walk(g, g.clock + 1.5)
	check("night: backed off: it goes on with the leg it was on", r.fired.has("resume_1") and int(r.counters["turning"]) == 0
		and r._routes.any(func(rt): return String(rt["name"]) == "leg1"))
	# the dawn: never reached the bank
	_walk(g, g.clock + 420.0)
	check("night: dawn with nothing seen: the visit is lost", g.over and r.winner_side == "machine" and r.obj["follow"] == "failed")


# ================================================================== defeats

func _defeats() -> void:
	for who in ["ferrer", "hollweg"]:
		_progress({"furth": "strong"})
		var g := await _start()
		var r: MissionRun = g.mission
		_step(g, 20.0)
		_kill(r, who)
		_step(g, 21.0)
		check("%s killed: the visit is lost" % who, g.over and r.winner_side == "machine" and r.obj[who] == "failed")
		check("...and it does not count", not (Campaign.progress()["done"] as Dictionary).has(MID))
	# a passive player: the works shut at dusk
	_progress({"furth": "strong"})
	var g := await _start()
	var r: MissionRun = g.mission
	_step(g, 300.0)
	check("passive: nothing at 5:00", not g.over)
	_step(g, 602.0)
	_step(g, 602.5)
	check("passive: the works shut at dusk with the inspection unfinished: lost", g.over and r.winner_side == "machine" and r.obj["inspect"] == "failed" and _said(r, "n_dusk"))


# ================================================================== versus (offline: the machine's side played by the second seat)

func _versus() -> void:
	_progress({"furth": "strong"})
	# (the machine's seat as a friend's: no AI, its units his; the network itself is not run here)
	if main.game:
		main._to_menu()
		await process_frame
	for n in main.ui_layer.get_children():
		if n.name == "MissionEnd" or n is StillShow:
			n.queue_free()
	var cfg := Campaign.make_cfg(MID, "versus", "p1", false)
	cfg["slots"][3]["who"] = "remote"
	main.start(cfg)
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	_step(g, 1.0)
	_step(g, 2.0)
	var mt := r.team_index("machine")
	check("versus: the machine's objective", r.objectives_for("machine").map(func(o): return o["id"]) == ["m_take"])
	check("versus: the machine's army and Light Works (no garrison on hold)", r.tagged("m_start").size() == 11 and r.tagged("m_works").size() == 1 and r.tagged("m_guard").is_empty(),
		"%d %d %d playing=%s" % [r.tagged("m_start").size(), r.tagged("m_works").size(), r.tagged("m_guard").size(), r.cond({"playing": "machine"})])
	check("versus: its seed on the meadows is not spared (it can be fought for)", not r.tagged("seed_meadow")[0].spared)
	check("versus: the lines go to their own sides", String(r.data["lines"]["f_1"]["to"]) == "visit" and String(r.data["lines"]["m_intro"]["to"]) == "machine")
	_step(g, 31.0)
	check("versus: the seed's income", int(g.players[mt]["gold"]) >= 550)
	_inspect(g, r)
	await _night(g, r)
	_walk(g, g.clock + 12.5)
	_walk(g, g.clock + 5.5)
	check("versus: no scripted sortie (the machine is a person's)", not r.fired.has("m_sortie"))
	var rio: Array = r.tagged("rioters")
	check("versus: the rioters are the machine player's", rio.size() == 15 and rio.all(func(u): return u.team == mt))
	_put(g, rio.slice(0, 6), _mid(r, "meadow_ground"))
	_step(g, g.clock + 0.25)
	_step(g, g.clock + 0.25)
	check("versus: six brought home: the machine wins", g.over and r.winner_side == "machine" and r.obj["m_take"] == "done")
	await create_timer(1.8).timeout
	var p := Campaign.progress()
	check("versus: the story follows the winner (the machine)", (p["done"] as Dictionary).has(MID) and String(p["done"][MID]["won_by"]) == "machine")


# ================================================================== the difficulty

func _difficulty() -> void:
	for d in [["easy", 10, 3, 750.0, 5], ["hard", 19, 5, 510.0, 8]]:
		_progress({"furth": "strong"}, {}, {}, d[0])
		var g: Game = await _start()
		var r: MissionRun = g.mission
		check("%s: the machine's garrison scaled (%d)" % [d[0], d[2]], r.tagged("m_guard").size() == int(d[2]), str(r.tagged("m_guard").size()))
		check("%s: the party is the player's: never scaled" % d[0], r.tagged("escort").size() == 8 and r.tagged("gap_men").size() == 4)
		check("%s: the dusk clock %d s" % [d[0], int(d[3])], absf(float(r.clocks.get("dusk", 0.0)) - 1.0 - float(d[3])) < 2.0, str(r.clocks))
		_inspect(g, r)
		_walk(g, g.clock + 6.5)
		_walk(g, g.clock + 20.5)
		check("%s: the riot is %d strong" % [d[0], d[1]], r.tagged("broken").size() == int(d[1]), str(r.tagged("broken").size()))
		_put(g, r.tagged("escort") + r.tagged("brothers"), r.tagged("ferrer")[0].position + Vector2(0, 3 * Defs.TILE))
		var want := 420.0 * (1.25 if d[0] == "easy" else 0.85)
		check("%s: the dawn clock %d s" % [d[0], int(want)], absf(float(r.clocks.get("dawn", 0.0)) - g.clock - want) < 2.0)
		_walk(g, g.clock + 8.5)
		var w: Array = r.tagged("night_winder")
		for leg in [["w_town", "w_camp"], ["w_line", "w_west"], ["bank"]]:
			for wp in leg:
				_put(g, w, _mid(r, wp))
				_step(g, g.clock + 0.25)
				_step(g, g.clock + 0.25)
			_walk(g, g.clock + 12.5)
		_put(g, r.tagged("ferrer"), r.area_rect("bank_watch").position + Vector2(64, 64))
		_walk(g, g.clock + 3.5)
		_walk(g, g.clock + 28.0)
		check("%s: the machine's sortie scaled (%d)" % [d[0], d[4]], r.tagged("sortie").filter(func(u): return u.kind == "clock_soldier").size() == int(d[4]),
			"%d fired=%s %s" % [r.tagged("sortie").size(), r.fired.has("m_sortie"), r.fired.keys().slice(-8)])


# ================================================================== the hubs

func _hub() -> void:
	main._to_menu()
	await process_frame
	var hub: Dictionary = Campaign.storyline_of(MID)["hub"]
	var base := {"done": {C01: {"side": "guild"}, A02: {"side": "guild"}}}
	var kept := {"done": {C01: {"side": "guild"}, A02: {"side": "guild"}, MID: {"side": "visit", "flags": {"broken": "kept"}}}}
	var melted := {"done": {C01: {"side": "guild"}, A02: {"side": "guild"}, MID: {"side": "visit", "flags": {"broken": "melted"}}}}
	check("the Fürth hub after a04: still the guild's barn", String(CampaignMenu.hub_now(hub, kept)["title"]) == "The Guild in Exile at Fürth")
	check("Hollweg after a04, kept: he will mend them", String(CampaignMenu.talk_lines(hub["talks"]["hollweg"], kept)[1]).contains("Every machine can be mended"))
	check("Hollweg after a04, melted: slag", String(CampaignMenu.talk_lines(hub["talks"]["hollweg"], melted)[0]).contains("slag"))
	check("the automaton after a04, kept / melted", String(CampaignMenu.talk_lines(hub["talks"]["automaton"], kept)[0]).contains("new pin")
		and String(CampaignMenu.talk_lines(hub["talks"]["automaton"], melted)[0]).contains("receipt"))
	check("Hollweg before a04: the line held", String(CampaignMenu.talk_lines(hub["talks"]["hollweg"], base)[0]).contains("The line held"))
	var study: Dictionary = Campaign.storyline_of("p01_leaf")["hub"]
	check("the King after a04, kept / melted", String(CampaignMenu.talk_lines(study["talks"]["king"], kept)[1]).contains("I let him")
		and String(CampaignMenu.talk_lines(study["talks"]["king"], melted)[1]).contains("Ferrer was right"))
	check("Hollweg in exile after a04", String(CampaignMenu.talk_lines(study["talks"]["hollweg_exile"], kept)[1]).contains("sure I could mend them"))
