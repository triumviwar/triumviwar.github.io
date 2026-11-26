extends SceneTree
## Act 2's "The Siege of Concórdia" (docs/campaign_d11_build.md):
##   - the data checks out, every text has pt and es, all three lines list it after d09, THE DIAMOND's lock (open after d09
##     with the city chosen first; with the swarm chosen first only once d10 is won), the seats (solo the Crown or THE CITY;
##     co-op the valley; versus the city), the map (d07's city with its wall, the plateau), the stills, THE ROSTER LADDER's
##     C9 (the column) and K7 (the city), the two VERSIONS' labels, no dashes, THE BROOD IS NOT A PERSON in the texts;
##   - THE FLAGS at the start: the canon (every flag missing: GROWN, Jakob alive, the weak gates known, Hollweg on the wall,
##     a few of the valley), FRESH (d09 first = clockwork: the scaffolding, a smaller garrison, no bolt-throwers), Jakob lost,
##     the stop-works logged, d07 `spring` stopped (Hollweg with the column, the masters and their postern, weaker gates),
##     d04 `colonists` fought (the valley's many);
##   - PART 1: the lines (the NEW cards, the earthworks' sites dug, the probes, the owls over the camp), PART 2: the three
##     sorties, the log read (the west gate), a gate knocked down, the sorties beaten; PART 3 FRESH: the mine (the pioneers
##     under the ground, the spring blown, the city braked, WON: `siege` close); PART 3 GROWN: the great sortie, the diggers
##     come up in the camp, dusk: WON `siege` held_off; Jakob's death: `jakob` lost; the park blown: LOST;
##   - THE CITY (the solo pick and versus): its objective, its cogs, its win by the park or by Father Ferrer; the Crown's work
##     done: its loss; SAVE AND LOAD in Part 2, IRONMAN, the HUBS and the WAR MAP after d11; no script error anywhere.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_d11.gd [-- only=data,flags,part1,part2,fresh,grown,defeat,city,save,ironman,hubs]
## Prints CHECK lines, then "campaign_d11: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "d11_siege"
var main: Node
var fails := 0
var _kept := ""
var _errs: Array = []


class Catch extends Logger:
	var out: Array
	func _init(o: Array) -> void:
		out = o
	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _en: bool, error_type: int, _bt: Array[ScriptBacktrace]) -> void:
		if error_type == 2:          # SCRIPT ERROR
			out.append("%s @ %s:%d %s" % [rationale if rationale != "" else code, file, line, function])
	func _log_message(_m: String, _e: bool) -> void:
		pass


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-74s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	OS.add_logger(Catch.new(_errs))
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
	MissionSave.clear_all(MID)
	print("campaign_d11: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if d09 (and, with the swarm first, d10) were won with these flags (each merged over its canon);
## `first` d09's choice; `none` leaves every earlier flag out but d09's choice (the canon); `no_d10`: d10 not won.
func _progress(fl := {}, first := "brood", diff := "normal", none := false, no_d10 := false) -> void:
	var p := {"reached": [MID], "done": {}, "difficulty": diff}
	var canon := {
		"c01_thirteenth": ["guild", {"jakob": "alive", "bells": "quiet", "saved": "some", "gate": "pattern"}],
		"a04_visit": ["visit", {"broken": "kept", "stopworks": "found", "jakob": "alive"}],
		"a07_council": ["crown", {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}],
		"d04_concordia": ["guild", {"colonists": "parley"}],
		"d07_spring": ["guild", {"spring": "running", "honest": "some"}],
		"d09_crossroads": ["crown", {"first": first, "fort": "held", "sertao": "some"}],
		"d10_jungle": ["crown", {"jungle": "held"}],
	}
	for mid in canon:
		if mid == "d10_jungle" and (no_d10 or first != "brood"):
			continue
		var f: Dictionary = (canon[mid][1] as Dictionary).duplicate()
		if none and mid != "d09_crossroads":
			f = {}
		for k in fl.get(mid, {}):
			f[k] = fl[mid][k]
		p["done"][mid] = {"won_by": canon[mid][0], "side": canon[mid][0], "flags": f}
	Campaign.save_progress(p)


func _start(mode := "solo", side := "", mark := "") -> Game:
	if main.game:
		main._to_menu()
		await process_frame
	for n in main.ui_layer.get_children():
		if n.name == "MissionEnd" or n is StillShow:
			n.queue_free()
	if mode == "solo":
		main.start(Campaign.make_cfg(MID, "solo", "p1", false, side))
	else:
		main.start(Campaign.make_cfg(MID, mode, "p1", false))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	if mark != "":
		g.mission.player_teams[g.mission.team_index(mark)] = true      # (the friend's team marked as a person's, as online)
	_step(g, 1.0)
	_step(g, 2.5)
	return g


func _step(g: Game, to: float) -> void:
	g.clock = to
	var r := g.mission
	r._t = 0.0
	paused = false
	r._physics_process(MissionRun.TICK)


func _walk(g: Game, to: float) -> void:
	var t := g.clock
	while t < to and not g.over:
		t = minf(to, t + 0.25)
		_step(g, t)


func _put(g: Game, us: Array, at: Vector2) -> void:
	var i := 0
	for u in us:
		u.position = at + Vector2((i % 4) * 14 - 21, (i / 4) * 14 - 14)
		u.velocity = Vector2.ZERO
		u.cmd_stop()
		i += 1
	g._rebuild_hash()


func _mid(r: MissionRun, area: String) -> Vector2:
	return r.area_rect(area).get_center()


func _said(r: MissionRun, id: String) -> bool:
	return r.said_ids.has(id)


func _kill(es: Array) -> void:
	for e in es:
		if is_instance_valid(e) and not e.dead:
			e.hp_floor = 0.0
			e.spared = false
			e.take_damage(999999.0, null)


func _team(g: Game, r: MissionRun, tm: String) -> Array:
	var t := r.team_index(tm)
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind != "horse" and not u.off_field)


func _hp(r: MissionRun, tag: String) -> float:
	var l: Array = r.tagged(tag).filter(func(e): return not e.dead)
	return -1.0 if l.is_empty() else float(l[0].max_hp)


## PART 1 done the quick way: every earthwork dug.
func _dig(g: Game, r: MissionRun) -> void:
	for b in r.tagged("earthworks"):
		if b is Building and not b.built:
			b.add_progress(9999.0)
	_walk(g, g.clock + 1.0)


## PART 2 started (the lines dug after a minute).
func _to_part2(g: Game, r: MissionRun) -> void:
	_dig(g, r)
	_walk(g, maxf(g.clock, 61.0) + 6.0)


## PART 2 done the quick way: every sortie out and killed.
func _to_part3(g: Game, r: MissionRun) -> void:
	_walk(g, float(r.fired.get("part2", g.clock)) + 8.0 + 100.0 + 2.0)
	for i in 8:
		_kill(r.tagged("sortie"))
		_walk(g, g.clock + 2.0)
		if r.fired.has("part3"):
			break
	_walk(g, g.clock + 1.0)


# ================================================================== run

func _run() -> void:
	await process_frame
	var only := ""
	for a in OS.get_cmdline_user_args():
		if String(a).begins_with("only="):
			only = String(a).substr(5)
	var want := func(n: String) -> bool: return only == "" or only.split(",").has(n)
	if want.call("data"): _data()
	if want.call("flags"): await _flags()
	if want.call("part1"): await _part1()
	if want.call("part2"): await _part2()
	if want.call("fresh"): await _fresh()
	if want.call("grown"): await _grown()
	if want.call("defeat"): await _defeat()
	if want.call("city"): await _city()
	if want.call("save"): await _save_load()
	if want.call("ironman"): await _ironman()
	if want.call("hubs"): _hubs()
	check("no script error in the whole run", _errs.is_empty(), str(_errs.slice(0, 3)))
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("d11_siege: data checks out", pr.is_empty(), "; ".join(pr))
	var extra := ["Father Ferrer", "Jakob", "Meister Hollweg"]
	for role in ["ferrer_siege", "jakob_siege", "pioneer", "hollweg_prisoner", "hollweg_walls"]:
		extra.append(String(Rebels.ROLES[role]["about"]))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + extra:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission, its roles and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	for sid in ["prologue", "clockmaker", "naturalist"]:
		var ms: Array = []
		for s in Campaign.index()["storylines"]:
			if String(s["id"]) == sid:
				ms = s["missions"]
		check("the %s line lists d11 after d09" % sid, ms.find(MID) > ms.find("d09_crossroads") and ms.find("d09_crossroads") >= 0)
	# THE DIAMOND: the second front waits for the first
	_progress({}, "clockwork")
	var pp := Campaign.progress()
	pp["reached"] = []
	Campaign.save_progress(pp)
	check("the city chosen first: d11 open after d09", Campaign.unlocked(MID))
	_progress({}, "brood", "normal", false, true)
	pp = Campaign.progress()
	pp["reached"] = []
	Campaign.save_progress(pp)
	check("the swarm chosen first: d11 shut until d10 is won", not Campaign.unlocked(MID))
	_progress({}, "brood")
	pp = Campaign.progress()
	pp["reached"] = []
	Campaign.save_progress(pp)
	check("... and open once d10 is", Campaign.unlocked(MID))
	check("the seats: solo the Crown or THE CITY", Campaign.solo_sides(m) == ["crown", "city"])
	check("co-op: p2 the valley (the Crown's side); versus: p2 the city", Campaign.seat_side(m, "coop", "p2") == "crown"
		and Campaign.seat_side(m, "versus", "p2") == "city" and Campaign.seat_side(m, "versus", "p1") == "crown")
	var md := Campaign.map_data("concordia_siege")
	check("the map: the highlands, the town wall (rock) with its openings", md.get("biome", "") == "highlands" and String(md.get("cells", "")).count("k") > 60,
		str(String(md.get("cells", "")).count("k")))
	for k in m["stills"]:
		check("still %s is in" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	var col: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "column")[0]
	check("THE ROSTER LADDER C9: PREPARED CHARGES and the QUADRANT, both NEW; no balloon (the jungle's rung)",
		(col["roster"]["allow"] as Array).has("charges") and (col["roster"]["new"] as Array) == ["charges", "quadrant"]
		and (col["roster"]["deny"] as Array).has("balloon"))
	var city: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "city")[0]
	check("THE ROSTER LADDER K7: the city bound, SPRING BALLISTA and LONG CHAIN NEW", (city["roster"]["new"] as Array) == ["ballista", "long_chain"]
		and (city["roster"]["allow"] as Array).has("owl_morph"))
	check("the NEW cards: the column's to the Crown, the city's to the city", String(m["lines"]["new_charges"]["to"]) == "crown"
		and String(m["lines"]["new_ballista"]["to"]) == "city")
	check("the column comes with C5-C7 researched", (col.get("techs", []) as Array) == ["matchlock", "bayonet", "charge", "armour"])
	check("TWO VERSIONS with their labels", (m["versions"]["labels"] as Dictionary).has("fresh") and (m["versions"]["labels"] as Dictionary).has("grown")
		and String(m["versions"]["default"]) == "grown")
	check("hubs-grow: d11 earns on the Crown line", (HubGrow.line("prologue")["earn"] as Array).has(MID))
	var all := " ".join(Campaign.strings_of(m))
	check("no creature named; no machine given a will (Linnea, wants, decided)", not all.contains("Linnea") and not all.contains(" wants")
		and not all.contains("decided"))
	var dash: Array = []
	for lid in m["lines"]:
		if String(m["lines"][lid]["text"]).contains(" - ") or String(m["lines"][lid]["text"]).contains("—"):
			dash.append(lid)
	check("no dashes in the spoken lines", dash.is_empty(), str(dash))


# ================================================================== the flags at the start

func _flags() -> void:
	_progress({}, "brood", "normal", true)
	var g: Game = await _start()
	var r := g.mission
	check("every earlier flag missing: GROWN (the swarm first), Jakob alive, Hollweg on his wall (spared)", str(r.flags.get("version")) == "grown"
		and r.tagged("jakob").size() == 1 and r.tagged("hollweg_w").size() == 1 and r.tagged("hollweg_w")[0].spared and r.tagged("hollweg").is_empty())
	check("the player is the column (purple) with Ferrer and Ruggieri", g.human == r.team_index("column") and r.tagged("ferrer").size() == 1
		and r.tagged("ruggieri").size() == 1)
	check("GROWN: the bolt-throwers on the wall, owls, Pendulums; the finished wall", r.tagged("wall_guns").size() == 3 and r.tagged("city_owls").size() == 2
		and _hp(r, "breach_n") >= 1000.0, str(_hp(r, "breach_n")))
	check("the valley: a few (d04 parley, the canon)", r.tagged("militia").size() == 3)
	_walk(g, 3.5)
	check("the stop-works found and Jakob alive: the north and south gates weak at the start", _hp(r, "g_north") < _hp(r, "g_west") * 0.5
		and _hp(r, "g_south") < _hp(r, "g_west") * 0.5, "%s %s %s" % [_hp(r, "g_north"), _hp(r, "g_south"), _hp(r, "g_west")])
	check("the great spring's tower: the mine's work, not the guns'", _hp(r, "spring") >= 6000.0)
	# FRESH
	_progress({}, "clockwork")
	g = await _start()
	r = g.mission
	check("d09 first = clockwork: FRESH, the scaffolding, a smaller garrison, no bolt-throwers", str(r.flags.get("version")) == "fresh"
		and _hp(r, "breach_n") < 300.0 and r.tagged("wall_guns").is_empty() and r.tagged("garrison").size() < 12, "%s %d" % [_hp(r, "breach_n"), r.tagged("garrison").size()])
	# Jakob lost, the stop-works logged
	_progress({"c01_thirteenth": {"jakob": "lost"}, "a04_visit": {"stopworks": "logged"}})
	g = await _start()
	r = g.mission
	_walk(g, 3.5)
	check("Jakob lost: not in the column; no gate known at the start", r.tagged("jakob").is_empty() and _hp(r, "g_north") == _hp(r, "g_west"))
	var pages := str(r.pages_now(Campaign.show_pages(r.data, "opening", "crown")))
	check("the opening: Ferrer has Jakob's log", pages.contains("f_open_nojakob") and not pages.contains("f_open_jakob"))
	# d07 spring stopped, d04 colonists fought
	_progress({"d07_spring": {"spring": "stopped", "honest": "many"}, "d04_concordia": {"colonists": "fought"}})
	var g_run: Game = await _start()
	var hp_run := 0.0
	_progress({"d07_spring": {"spring": "running"}})
	g_run = await _start()
	_walk(g_run, 3.5)
	hp_run = _hp(g_run.mission, "g_west")
	_progress({"d07_spring": {"spring": "stopped", "honest": "many"}, "d04_concordia": {"colonists": "fought"}})
	g = await _start()
	r = g.mission
	_walk(g, 3.5)
	check("d07 spring stopped: Hollweg with the column (a hero), not on the wall", r.tagged("hollweg").size() == 1 and r.tagged("hollweg_w").is_empty()
		and r.tagged("hollweg")[0].team == r.team_index("column"))
	check("... the honest masters and their postern (theirs: it opens for the Crown)", r.tagged("matthias").size() == 1 and r.tagged("masters").size() == 4
		and r.tagged("postern").all(func(b): return b.team == r.team_index("masters")))
	check("... the city smaller: its gates weaker", _hp(r, "g_west") < hp_run, "%s < %s" % [_hp(r, "g_west"), hp_run])
	check("d04 colonists fought: the valley marches gladly (many)", r.tagged("militia").size() == 9)


# ================================================================== PART 1: the lines

func _part1() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 10.0)
	check("the NEW cards for C9 are said (the city's K7 only to the city)", _said(r, "new_charges") and _said(r, "new_quadrant"))
	check("the lines and their lesson (SAY IT PLAINLY)", _said(r, "r_lines") and _said(r, "n_lines"))
	check("the objectives: the park, the lines, nightfall's clock, the charges", r.obj.get("park", "") == "active" and r.obj.get("lines", "") == "active"
		and r.obj.get("dusk", "") == "active" and r.obj.get("charges", "") == "active" and r.clocks.has("dusk"))
	var sites: Array = r.tagged("earthworks")
	check("twelve earthworks to dig, all sites", sites.size() == 12 and sites.all(func(b): return not b.built), str(sites.size()))
	_walk(g, 16.0)
	check("Jakob marks the weak gates", _said(r, "j_weak") and r.obj.get("breach", "") == "active")
	_walk(g, 36.0)
	check("Hollweg seen on his wall (the spring running)", _said(r, "f_hollweg") and _said(r, "j_hollweg"))
	_walk(g, 45.0)
	check("PROBE: a few machines out of the north gate at the diggers", r.tagged("probe1").size() >= 3 and _said(r, "n_probe")
		and r.tagged("probe1").all(func(u): return u.wind > 0.9))
	_walk(g, 54.0)
	check("Ruggieri asks for the charges", _said(r, "r_charges"))
	_walk(g, 78.0)
	check("GROWN: owls over the camp", r.tagged("owls_camp").size() == 2 and _said(r, "n_owls_camp"))
	_dig(g, r)
	_walk(g, g.clock + 2.0)
	check("the lines dug: done, the guns asked for", r.obj.get("lines", "") == "done" and _said(r, "n_lines_done"))
	_walk(g, g.clock + 6.0)
	check("PART 2 at nightfall (the lines dug): the sorties' objective", r.fired.has("part2") and r.obj.get("sorties", "") == "active")
	# the lines not dug: the clock brings the night anyway (NO WAITING)
	_progress()
	g = await _start()
	r = g.mission
	r.clocks["dusk"] = g.clock + 0.5
	_walk(g, g.clock + 6.0)
	check("nightfall's clock out: Part 2 anyway, the lines' objective closed", r.fired.has("part2") and r.obj.get("lines", "") == "hidden")


# ================================================================== PART 2: the sorties

func _part2() -> void:
	_progress({"a04_visit": {"stopworks": "logged"}, "d07_spring": {"spring": "stopped"}})
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	var p2 := float(r.fired["part2"])
	_walk(g, p2 + 10.0)
	check("SORTIE 1 at night: chains at the west gate, owls", r.tagged("s1").size() >= 4 and r.tagged("s1").any(func(u): return u.kind == "ticking_owl")
		and int(r.counters["sortie_n"]) == 1)
	_walk(g, p2 + 20.0)
	check("the stop-works logged: Ferrer reads the log, the west gate weak", _said(r, "f_log") and _hp(r, "g_west") < _hp(r, "g_north"))
	_walk(g, p2 + 32.0)
	check("d07 stopped: Matthias' postern", _said(r, "m_postern"))
	_kill(r.tagged("s1"))
	_walk(g, p2 + 60.0)
	check("SORTIE 2 at dawn: out of the north and south gates", r.tagged("s2").size() >= 6 and int(r.counters["sortie_n"]) == 2)
	check("not done while the third sortie has not come", not r.fired.has("sorties_done"))
	_kill(r.tagged("g_west"))
	_walk(g, g.clock + 1.0)
	check("a gate knocked down: the breach done", r.obj.get("breach", "") == "done" and _said(r, "n_breach"))
	_to_part3(g, r)
	check("the sorties beaten: Part 3", r.fired.has("sorties_done") and r.fired.has("part3"))
	# full day before they are beaten: Part 3 anyway
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	r.clocks["dawn"] = g.clock + 0.5
	_walk(g, g.clock + 8.0)
	check("full day before they are beaten: back behind the wall, Part 3 anyway (NO WAITING)", r.fired.has("full_day") and r.fired.has("part3"))


# ================================================================== PART 3 FRESH: the mine

func _fresh() -> void:
	_progress({}, "clockwork")
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_to_part3(g, r)
	check("FRESH Part 3: THE MINE, Jakob hears the spring", r.obj.get("mine", "") == "active" and _said(r, "n_mine") and _said(r, "j_mine"))
	var pio: Array = r.tagged("pioneers")
	_put(g, pio, _mid(r, "mine_mouth"))
	_walk(g, g.clock + 4.0)
	check("two pioneers at the mouth: down they go (SAPPING), the clock", r.fired.has("sap_go") and r.obj.get("mine_clock", "") == "active"
		and pio.all(func(u): return u.off_field), str(pio.map(func(u): return u.off_field)))
	_walk(g, g.clock + 8.0)
	check("the great sortie at the mouth", r.tagged("m1").size() >= 4)
	_kill(r.tagged("sortie"))
	_walk(g, float(r.fired["sap_go"]) + 47.0)
	check("they come up under the spring: the tower blown, the city braked", r.fired.has("spring_down") and _said(r, "n_spring_down"))
	var city_men := _team(g, r, "city").filter(func(u): return u.kind == "clock_soldier")
	check("... every machine in the city run down", city_men.all(func(u): return u.wind <= 0.01), str(city_men.size()))
	_walk(g, g.clock + 20.0)
	check("they come back up the gallery; WON for the Crown, siege close, Jakob alive", g.over and r.winner_side == "crown"
		and str(r.flags.get("siege")) == "close" and str(r.flags.get("jakob")) == "alive", "%s %s %s" % [g.over, r.winner_side, r.flags])
	# no pioneer left: three more from the baggage; Jakob falls on the way: jakob lost
	_progress({}, "clockwork")
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	_kill(r.tagged("pioneers"))
	_walk(g, g.clock + 1.0)
	check("Jakob can fall here (no floor): his line, his objective failed", _said(r, "n_jakob_down") and r.obj.get("jakob", "") == "failed")
	_to_part3(g, r)
	_walk(g, g.clock + 1.0)
	check("no pioneer left: three more from the baggage", r.tagged("pioneers").filter(func(u): return not u.dead).size() == 3 and _said(r, "n_reserve"))
	for b in r.tagged("spring"):
		b.take_damage(9999999.0, null)
	_walk(g, g.clock + 12.0)
	check("the spring brought down by the guns before the mine: WON anyway, jakob lost", g.over and r.winner_side == "crown"
		and str(r.flags.get("siege")) == "close" and str(r.flags.get("jakob")) == "lost", str(r.flags))


# ================================================================== PART 3 GROWN: the great sortie

func _grown() -> void:
	_progress({"c01_thirteenth": {"jakob": "lost"}})
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_to_part3(g, r)
	check("GROWN Part 3: THE GREAT SORTIE, the clocks, the diggers (Ferrer: the sentries heard them)", r.obj.get("hold", "") == "active"
		and r.clocks.has("relief") and r.clocks.has("diggers") and _said(r, "f_dig") and not _said(r, "j_dig"))
	check("the city's diggers under the ground", r.tagged("diggers").size() == 5 and r.tagged("diggers").all(func(u): return u.off_field))
	var h0 := float(r.fired["hold_on"])
	_walk(g, h0 + 10.0)
	check("the first wave out of the gates at the camp", r.tagged("g1").size() >= 6)
	_kill(r.tagged("sortie"))
	_walk(g, h0 + 46.0)
	check("the diggers come up beside the siege park, with a mine", r.fired.has("dig_up") and _said(r, "n_up") and r.tagged("diggers").all(func(u): return not u.off_field)
		and float(r.tagged("park")[0].hp) < float(r.tagged("park")[0].max_hp), "dig_up %s n_up %s park %s" % [r.fired.has("dig_up"), _said(r, "n_up"), r.tagged("park")[0].hp])
	_walk(g, h0 + 102.0)
	check("the big wave with the bolt-throwers", r.tagged("g3").any(func(u): return u.kind == "ballista"))
	_kill(r.tagged("sortie"))
	r.clocks["relief"] = g.clock + 0.5
	_walk(g, g.clock + 8.0)
	check("dusk: WON for the Crown, siege held_off, jakob lost (lost before)", g.over and r.winner_side == "crown"
		and str(r.flags.get("siege")) == "held_off" and str(r.flags.get("jakob")) == "lost", str(r.flags))


func _defeat() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 6.0)
	_kill(r.tagged("park"))
	_walk(g, g.clock + 3.0)
	check("the siege park's magazine blown: LOST", g.over and r.winner_side != "crown" and _said(r, "n_park_down"), "%s %s" % [g.over, r.winner_side])


# ================================================================== THE CITY: the solo pick and versus

func _city() -> void:
	_progress({}, "clockwork")
	var g: Game = await _start("solo", "city")
	var r := g.mission
	check("THE CITY picked: the player is the city", g.human == r.team_index("city") and r.cond({"playing": "city"}) and not r.cond({"playing": "crown"}))
	check("... its objective and its lines, the earthworks already dug", r.obj.get("c_break", "") == "active" and _said(r, "cn_1")
		and r.tagged("earthworks").all(func(b): return b.built))
	check("... the column's Ferrer not protected (the prey)", not r.heroes.protects(r.tagged("ferrer")[0]))
	var gold0 := int(g.players[g.human]["gold"])
	_walk(g, 12.0)
	check("... cogs from the works", int(g.players[g.human]["gold"]) > gold0)
	_walk(g, 16.0)
	check("... the NEW cards for K7 (not the Crown's)", _said(r, "new_ballista") and _said(r, "new_long_chain"))
	_kill(r.tagged("ferrer"))
	_walk(g, g.clock + 4.0)
	check("THE CITY: Father Ferrer brought down: WON for the city", g.over and r.winner_side == "city", "%s %s" % [g.over, r.winner_side])
	# the Crown's scripted work done (FRESH: its pioneers go down by themselves): the city loses
	_progress({}, "clockwork")
	g = await _start("solo", "city")
	r = g.mission
	r.clocks["dusk"] = g.clock + 0.5
	_walk(g, g.clock + 6.0)
	_to_part3(g, r)
	_put(g, r.tagged("pioneers"), _mid(r, "mine_mouth"))
	_walk(g, g.clock + 4.0)
	check("the scripted column sends its pioneers down (FRESH)", r.fired.has("sap_go") and _said(r, "cn_mine"))
	_walk(g, float(r.fired["sap_go"]) + 47.0)
	_walk(g, g.clock + 20.0)
	check("the spring blown: the Crown's work done, LOST for the city", g.over and r.winner_side == "crown", "%s %s" % [g.over, r.winner_side])
	# versus: the park
	_progress()
	g = await _start("versus", "", "city")
	r = g.mission
	check("versus: the friend is the city, his objective", r.cond({"playing": "city"}) and r.obj.get("c_break", "") == "active")
	_walk(g, 10.0)
	_kill(r.tagged("park"))
	_walk(g, g.clock + 4.0)
	check("versus: the park blown: WON for the city", g.over and r.winner_side == "city", "%s %s" % [g.over, r.winner_side])


# ================================================================== save and load, ironman

func _snap(g: Game) -> Dictionary:
	var r := g.mission
	var tags := {}
	for k in r.tags:
		tags[k] = r.tagged(k).size()
	return {"flags": r.flags, "counters": r.counters, "obj": r.obj, "tags": tags, "fired": r.fired.keys().size()}


func _save_load() -> void:
	_progress({}, "clockwork")
	MissionSave.clear_all(MID)
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_walk(g, g.clock + 12.0)
	var before := _snap(g)
	var spring_hp := _hp(r, "spring")
	main.mission_save_now()
	check("SAVE written in Part 2", MissionSave.has(MID, "save"))
	main.mission_load("save")
	await process_frame
	await process_frame
	paused = false
	var g2: Game = main.game
	if g2.hud:
		g2.hud.countdown = 0.0
	var after := _snap(g2)
	var diff: Array = []
	for k in before:
		if JSON.stringify(before[k], "", true) != JSON.stringify(after[k], "", true):
			diff.append("%s: %s -> %s" % [k, before[k], after[k]])
	check("LOADED the same: flags (the version too), counters, objectives, tags", diff.is_empty(), "; ".join(diff))
	check("... the great spring's tower keeps its mission health", _hp(g2.mission, "spring") == spring_hp, "%s %s" % [_hp(g2.mission, "spring"), spring_hp])
	for i in 90:
		await physics_frame
	check("plays on after the load with no script error", _errs.is_empty(), str(_errs.slice(0, 3)))
	main._to_menu()
	await process_frame
	MissionSave.clear_all(MID)


func _ironman() -> void:
	_progress()
	Campaign.set_ironman()
	var g: Game = await _start()
	var labels: Array = g.hud._menu_list().map(func(b: Dictionary) -> String: return String(b["label"]))
	check("IRONMAN: no SAVE nor LOAD SAVE in the match menu", not labels.has("SAVE") and not labels.has("LOAD SAVE"), str(labels))
	main._to_menu()
	await process_frame
	_progress()


# ================================================================== the hubs and the war map after d11

func _hubs() -> void:
	_progress()
	Campaign.record(MID, "solo", "crown", "crown", {"version": "grown", "siege": "held_off", "jakob": "alive"})
	var p := Campaign.progress()
	var pro: Dictionary = {}
	var clk: Dictionary = {}
	for s in Campaign.index()["storylines"]:
		match String(s["id"]):
			"prologue": pro = s
			"clockmaker": clk = s
	check("the King's study: the King on the road held a year", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["king"], p)).contains("held the road a whole year"))
	check("the King's study: the dispatch on the great sortie", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["dispatch"], p)).contains("great sortie held"))
	check("Hollweg (the spring running): on his wall, listening", str(CampaignMenu.talk_lines(clk["hub"]["talks"]["hollweg"], p)).contains("Not by a beat"))
	var st := WarMapData.state(p)
	check("the war map: Concórdia the machine's, the valley contested (held off)", String(st["regions"]["concordia"]) == "machine"
		and String(st["regions"]["valley"]) == "contested")
	check("the war map's data has no problem", WarMapData.problems().is_empty(), "; ".join(WarMapData.problems()))
	_progress({"d07_spring": {"spring": "stopped"}}, "clockwork")
	Campaign.record(MID, "solo", "crown", "crown", {"version": "fresh", "siege": "close", "jakob": "lost"})
	p = Campaign.progress()
	check("the spring blown: the King, the siege ring on the map, Jakob in the ledger", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["king"], p)).contains("miss a beat")
		and bool(WarMapData.state(p)["marks"].get("siege_ring", false))
		and (WarMapData.state(p).get("ledger", []) as Array).map(func(x): return String(x.get("text", ""))).has("Jakob fell before the walls of Concórdia."))
	check("Hollweg (the spring stopped): his confession", str(CampaignMenu.talk_lines(clk["hub"]["talks"]["hollweg"], p)).contains("confession"))
	_progress()
	Campaign.record(MID, "versus", "city", "city", {})
	p = Campaign.progress()
	check("a city's win: the seal broken (not how it went)", String(WarMapData.state(p)["pins"][MID]["seal"]) == "broken")
