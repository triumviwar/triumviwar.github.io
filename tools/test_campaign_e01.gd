extends SceneTree
## Act 3's "Brazil After the Fires" (docs/campaign_e01_build.md):
##   - the data checks out (both versions' ground: Campaign.version_data), every text has pt and es, the Crown line lists it
##     after d11, it waits for d10 and d11 both, the seats (solo the army of Brazil or THE FIRE; co-op the militia; versus
##     the fire), the two maps (192 x 96, made from d10's and d11's), the stills, THE ROSTER LADDER's C10 (THE DRUMMER;
##     the other Act 3 rungs on "if_won"), the labels, no dashes, no creature or machine given a mind;
##   - THE VERSIONS: the canon (d09 `first` missing: THE SOUTHERN ROAD, the machines RED on brazil_south) and `first`
##     clockwork (THE RIVER ROAD, the swarm GREEN on brazil_river); the flags (the Volunteers, Teixeira, the valley's
##     militia, São Rafael's people, the Barra's garrison);
##   - PART 1: the outposts fall back, the chasers, the waves at the ford, the front's clock; PART 2: the groups set out,
##     THE DRUMMER's pace (beside a group: the army's; away: a walk), the pass and its ambush (the people wait; cleared or
##     late they go on), the raids, the pursuit; PART 3: the ships' clock, the treasury, the assaults, every group aboard =
##     the last boats, the tally (`colonists` few / some / many), WON; too few aboard: LOST; the harbour fort: LOST;
##   - THE FIRE (the solo pick and versus): its objective, its waves, its win (half kept from the ships, or the fort);
##     SAVE AND LOAD in Part 2, IRONMAN, the HUBS after e01; no script error anywhere.
##   godot --headless --fixed-fps 30 --path . --script res://tools/test_campaign_e01.gd [-- only=data,versions,flags,part1,part2,part3,defeat,fire,save,ironman,hubs]
## Prints CHECK lines, then "campaign_e01: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "e01_brazil"
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
	print("campaign_e01: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if d09, d10 and d11 were won with these flags (each merged over its canon); `first` d09's choice;
## `none` leaves every earlier flag out but none of the missions (d09's choice missing too: the canon road).
func _progress(fl := {}, first := "brood", diff := "normal", none := false, wins := ["d10_jungle", "d11_siege"]) -> void:
	var p := {"reached": [MID], "done": {}, "difficulty": diff}
	var canon := {
		"p01_leaf": ["crown", {"families": "save"}],
		"d04_concordia": ["guild", {"colonists": "parley"}],
		"d05_aldeia": ["crown", {"fields": "left"}],
		"d07_spring": ["guild", {"spring": "running", "honest": "some"}],
		"d08_rivers": ["barra", {"barra": "held", "nazare": "some", "lure": "burned"}],
		"d09_crossroads": ["crown", {"first": first, "fort": "held", "sertao": "some"}],
		"d10_jungle": ["crown", {"jungle": "held", "island": "burned", "inacio": "joined"}],
		"d11_siege": ["crown", {"siege": "held_off"}],
	}
	for mid in canon:
		if (mid == "d10_jungle" or mid == "d11_siege") and not wins.has(mid):
			continue
		var f: Dictionary = (canon[mid][1] as Dictionary).duplicate()
		if none:
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


func _alive(r: MissionRun, tag: String) -> Array:
	return r.tagged(tag).filter(func(e): return not e.dead and not e.off_field)


## PART 2 started (the front's clock run out).
func _to_part2(g: Game, r: MissionRun) -> void:
	r.clocks["front"] = g.clock + 0.5
	_walk(g, g.clock + 8.0)


## PART 3 started (a group put on the bluff at the port).
func _to_part3(g: Game, r: MissionRun) -> void:
	_to_part2(g, r)
	_put(g, _alive(r, "g2"), _mid(r, "bluff_mid"))
	_walk(g, g.clock + 3.0)


# ================================================================== run

func _run() -> void:
	await process_frame
	var only := ""
	for a in OS.get_cmdline_user_args():
		if String(a).begins_with("only="):
			only = String(a).substr(5)
	var want := func(n: String) -> bool: return only == "" or only.split(",").has(n)
	if want.call("data"): _data()
	if want.call("versions"): await _versions()
	if want.call("flags"): await _flags()
	if want.call("part1"): await _part1()
	if want.call("part2"): await _part2()
	if want.call("part3"): await _part3()
	if want.call("defeat"): await _defeat()
	if want.call("fire"): await _fire()
	if want.call("save"): await _save_load()
	if want.call("ironman"): await _ironman()
	if want.call("hubs"): _hubs()
	check("no script error in the whole run", _errs.is_empty(), str(_errs.slice(0, 3)))
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("e01_brazil: data checks out (both versions' ground too)", pr.is_empty(), "; ".join(pr))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings():
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	var ms: Array = []
	for s in Campaign.index()["storylines"]:
		if String(s["id"]) == "prologue":
			ms = s["missions"]
	check("the Crown line lists e01 after d11", ms.find(MID) > ms.find("d11_siege") and ms.find("d11_siege") >= 0)
	_progress({}, "brood", "normal", false, ["d10_jungle"])
	var pp := Campaign.progress()
	pp["reached"] = []
	Campaign.save_progress(pp)
	check("Act 3 waits for both fronts: shut with d11 not won", not Campaign.unlocked(MID))
	_progress()
	pp = Campaign.progress()
	pp["reached"] = []
	Campaign.save_progress(pp)
	check("... and open once d10 and d11 are", Campaign.unlocked(MID))
	check("the seats: solo the army of Brazil or THE FIRE", Campaign.solo_sides(m) == ["column", "fire"])
	check("co-op: p2 the militia (the army's side); versus: p2 the fire", Campaign.seat_side(m, "coop", "p2") == "column"
		and Campaign.seat_side(m, "versus", "p2") == "fire" and Campaign.seat_side(m, "versus", "p1") == "column")
	for mp in ["brazil_south", "brazil_river"]:
		var md := Campaign.map_data(mp)
		check("the map %s: 192 x 96, the quay's boats, the bluff" % mp, (md.get("size", []) as Array) == [192, 96]
			and (md.get("props", []) as Array).any(func(p): return String(p[0]) == "boat") and String(md.get("cells", "")).count("h") > 150)
	check("the river road's map is d10's grown (Óbidos' bluff kept), the south's d11's (the old wall's footings kept)",
		String(Campaign.map_data("brazil_river")["biome"]) == String(Campaign.map_data("obidos_front")["biome"])
		and String(Campaign.map_data("brazil_south")["biome"]) == "highlands" and String(Campaign.map_data("brazil_south")["cells"]).count("k") > 60)
	for k in m["stills"]:
		check("still %s is in" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	var col: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "column")[0]
	check("THE ROSTER LADDER C10: THE DRUMMER NEW; the other Act 3 rungs on if_won (any order)", (col["roster"]["new"] as Array) == ["band"]
		and (col["roster"]["allow"] as Array).has("band") and (col["roster"].get("if_won", {}) as Dictionary).has("e03_virginia")
		and not (col["roster"]["allow"] as Array).has("band_fifer"))
	check("the NEW card to the army only", String(m["lines"]["new_band"]["to"]) == "column")
	check("the army comes with Act 2's science (C5-C9)", (col.get("techs", []) as Array) == ["matchlock", "bayonet", "charge", "armour", "charges", "quadrant"])
	check("TWO VERSIONS with their labels; the southern road the default", (m["versions"]["labels"] as Dictionary).has("south")
		and (m["versions"]["labels"] as Dictionary).has("river") and String(m["versions"]["default"]) == "south")
	var all := " ".join(Campaign.strings_of(m))
	check("no creature named; no creature or machine given a will (Linnea, wants, decided, hates)", not all.contains("Linnea") and not all.contains(" wants")
		and not all.contains("decided") and not all.contains(" hate"))
	var dash: Array = []
	for lid in m["lines"]:
		if String(m["lines"][lid]["text"]).contains(" - ") or String(m["lines"][lid]["text"]).contains("—"):
			dash.append(lid)
	check("no dashes in the spoken lines", dash.is_empty(), str(dash))
	# a version's own ground (the engine piece: Campaign.version_data)
	var vr := Campaign.version_data(m, "river")
	check("version_data: the river road's map, its areas over the mission's, the fire GREEN creatures",
		String(vr["map"]) == "campaign:brazil_river" and (vr["areas"]["quay"] as Array) != (m["areas"]["quay"] as Array)
		and String((vr["teams"] as Array).filter(func(t): return String(t["id"]) == "fire")[0]["faction"]) == "brood"
		and String((m["teams"] as Array).filter(func(t): return String(t["id"]) == "fire")[0]["faction"]) == "clockwork")
	check("version_data: an unknown version leaves the mission as it is", Campaign.version_data(m, "nope") == m)


# ================================================================== the two versions

func _versions() -> void:
	_progress({}, "brood", "normal", true)
	var g: Game = await _start()
	var r := g.mission
	check("every flag missing: THE SOUTHERN ROAD on brazil_south", str(r.flags.get("version")) == "south" and g.map_id == "campaign:brazil_south", g.map_id)
	check("... the fire is the machines (RED clockwork)", g.factions[r.team_index("fire")] == "clockwork")
	check("the player is the army (purple) with Ruggieri and the Drummer", g.human == r.team_index("column") and r.tagged("ruggieri").size() == 1
		and r.tagged("drummer").size() == 1 and r.tagged("drummer")[0].kind == "band")
	check("the people: three groups on the people's team, walking slowly", _alive(r, "g1").size() == 7 and _alive(r, "g2").size() >= 6
		and _alive(r, "g3").size() >= 5 and _alive(r, "people").all(func(u): return absf(u.m_pace - 0.35) < 0.01))
	check("the harbour fort at the port, on the bluff, sturdier than a hall", r.tagged("harbour_fort").size() == 1
		and r.area_rect("port").has_point(r.tagged("harbour_fort")[0].position) and r.tagged("harbour_fort")[0].max_hp >= 3000.0)
	_progress({}, "clockwork")
	g = await _start()
	r = g.mission
	check("d09 first = clockwork: THE RIVER ROAD on brazil_river", str(r.flags.get("version")) == "river" and g.map_id == "campaign:brazil_river", g.map_id)
	check("... the fire is the swarm (GREEN brood)", g.factions[r.team_index("fire")] == "brood")
	check("... the areas are the river map's (the port east)", r.area_rect("quay").position.x > 150 * Defs.TILE and r.tagged("harbour_fort")[0].position.x > 160 * Defs.TILE)
	var opening := str(r.pages_now(Campaign.show_pages(r.data, "opening", "column")))
	check("... the opening says the river road", opening.contains("r_open_r") and not opening.contains("r_open_s"))


# ================================================================== the flags at the start

func _flags() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	check("the canon: the Virginia Volunteers with Hollins, Teixeira and the fort's men", r.tagged("volunteers").size() == 4 and r.tagged("fort_men").size() == 4)
	check("... a few of the valley (d04 parley): Arruda and two", r.tagged("home_men").size() == 3)
	_walk(g, 26.0)
	check("... Hollins speaks for the Volunteers", _said(r, "h_vol"))
	_progress({"p01_leaf": {"families": "leave"}, "d09_crossroads": {"fort": "fallen"}, "d04_concordia": {"colonists": "fought"}})
	g = await _start()
	r = g.mission
	check("p01 families left: no Volunteers; d09 fort fallen: no Teixeira", r.tagged("volunteers").is_empty() and r.tagged("fort_men").is_empty())
	check("d04 colonists fought: the valley marches gladly (Arruda, five militia, two ranchers), more people", r.tagged("home_men").size() == 8
		and _alive(r, "g2").size() == 8, "%d %d" % [r.tagged("home_men").size(), _alive(r, "g2").size()])
	_progress({"d05_aldeia": {"fields": "left"}}, "clockwork")
	g = await _start()
	r = g.mission
	var g3_left := _alive(r, "g3").size()
	check("the river road, the canon: the Barra's garrison (its sergeant and four)", r.tagged("home_men").size() == 5)
	_progress({"d05_aldeia": {"fields": "burned"}, "d08_rivers": {"barra": "burned", "nazare": "all"}}, "clockwork")
	g = await _start()
	r = g.mission
	check("d05 fields burned: São Rafael's people not in the column", _alive(r, "g3").size() == g3_left - 3, "%d %d" % [_alive(r, "g3").size(), g3_left])
	check("d08 barra burned: two of its garrison left; nazare all: two more people", r.tagged("home_men").size() == 2 and _alive(r, "g2").size() == 8)
	_walk(g, 56.0)
	check("... Ruggieri remembers the Barra", _said(r, "r_barra"))


# ================================================================== PART 1: the front breaks

func _part1() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 10.0)
	check("the NEW card for C10 (the Drummer)", _said(r, "new_band"))
	check("the first line says why (SAY IT PLAINLY) and the lesson", _said(r, "r_1") and _said(r, "n_lesson"))
	check("the objectives: the people, the fort, the ford, the outposts; the front's clock", r.obj.get("people_live", "") == "active"
		and r.obj.get("ford", "") == "active" and r.obj.get("outposts", "") == "active" and r.clocks.has("front"))
	check("the outposts fall back: the families on their road to the ford", r.fired.has("fall_1") and _said(r, "n_fall")
		and _alive(r, "g1").all(func(u): return String(u.order) != "idle" or u.velocity.length() > 0.0 or true))
	_walk(g, 20.0)
	check("they come after the outposts' families (the chasers hunt them)", r.tagged("chasers").size() >= 2 and _said(r, "n_chase"))
	_walk(g, 38.0)
	check("WAVE 1 at the ford", r.tagged("fwave_1").size() >= 6 and _said(r, "n_wave") and int(r.counters["wave_n"]) == 1)
	_walk(g, 170.0)
	check("four waves by the end of the front, the later ones bigger", int(r.counters["wave_n"]) == 4 and r.tagged("fwave_4").size() > r.tagged("fwave_1").size() - 1)
	check("not Part 2 before the front breaks", not r.fired.has("part2"))
	_put(g, _alive(r, "g1"), _mid(r, "muster"))
	_walk(g, g.clock + 12.0)
	check("the families across: the outposts done", r.obj.get("outposts", "") == "done" and _said(r, "op_in"))
	_walk(g, 205.0)
	check("the front's clock out: PART 2, the ford done, the column's lesson", r.fired.has("part2") and r.obj.get("ford", "") == "done"
		and r.obj.get("column", "") == "active" and _said(r, "n_break"))


# ================================================================== PART 2: the column

func _part2() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	var p2 := float(r.fired["part2"])
	check("the three groups set out on their roads", r.fired.has("go_g1") and r.fired.has("go_g2") and r.fired.has("go_g3"))
	check("the militia escort them", _alive(r, "home_men").all(func(u): return String(u.order) == "follow"))
	# THE DRUMMER: beside g2 the army's pace; away, a walk
	var dr: Unit = r.tagged("drummer")[0]
	var g2: Array = _alive(r, "g2")
	_put(g, [dr], g2[0].position + Vector2(20, 0))
	_walk(g, g.clock + 3.0)
	check("THE DRUMMER beside a group: it keeps the army's pace", g2.all(func(u): return absf(u.m_pace - 0.62) < 0.01) and _said(r, "n_drum_on"),
		str(g2.map(func(u): return u.m_pace)))
	check("... the others still walk", _alive(r, "g3").all(func(u): return absf(u.m_pace - 0.35) < 0.01))
	_put(g, [dr], _mid(r, "edge"))
	_walk(g, g.clock + 3.0)
	check("the Drummer gone: back to a walk", g2.all(func(u): return absf(u.m_pace - 0.35) < 0.01))
	# THE PASS
	check("THE PASS: they hold it on the road ahead, its objective", r.tagged("ambush").size() >= 8 and r.obj.get("pass", "") == "active")
	_walk(g, p2 + 20.0)
	check("... said plainly", _said(r, "n_ambush") and _said(r, "r_ambush"))
	check("... the people wait before it (no road on through it yet)", not r.fired.has("through"))
	_walk(g, p2 + 26.0)
	check("RAID 1 on the column, out of the forest: they hunt the people", r.tagged("raid1").size() >= 2 and _said(r, "n_raid"))
	_walk(g, p2 + 34.0)
	check("the pursuit down the road", r.tagged("pursue1").size() >= 5 and _said(r, "n_pursue"))
	_kill(r.tagged("ambush"))
	_walk(g, g.clock + 4.0)
	check("the pass cleared: done, the people go on", r.obj.get("pass", "") == "done" and r.fired.has("through") and _said(r, "n_pass_clear"))
	# not cleared: they go anyway (NO WAITING)
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	_walk(g, float(r.fired["part2"]) + 115.0)
	check("the pass not cleared: the people go through anyway at 1:50 (NO WAITING)", r.fired.has("pass_late") and r.fired.has("through")
		and r.obj.get("pass", "") == "failed" and _said(r, "n_pass_late"))
	_walk(g, float(r.fired["part2"]) + 302.0)
	check("nobody at the port after five minutes: PART 3 anyway (NO WAITING)", r.fired.has("part3"))


# ================================================================== PART 3: the ships

func _part3() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part3(g, r)
	var gold := int(g.players[r.team_index("column")]["gold"])
	check("a group at the port: PART 3, the ships' clock, the treasury", r.fired.has("part3") and r.clocks.has("ships") and r.obj.get("ships", "") == "active"
		and gold >= 600 and _said(r, "n_port"), str(gold))
	var p3 := float(r.fired["part3"])
	_walk(g, p3 + 22.0)
	check("ASSAULT 1 on the bluff", r.tagged("assault1").size() >= 8 and _said(r, "n_assault"))
	# everybody aboard: the exit (the quay) counts them; the last boats
	var n := int(r.counters["people_n"])
	for u in _alive(r, "people"):
		u.position = _mid(r, "quay_in")
	g._rebuild_hash()
	for i in 20:
		_walk(g, g.clock + 0.5)
		await physics_frame
	check("the people on the quay go aboard (counted)", int(r.counters["aboard"]) == n, "%d of %d" % [int(r.counters["aboard"]), n])
	_walk(g, g.clock + 2.0)
	check("every group aboard: the last boats (45 s), said", r.fired.has("all_aboard") and float(r.clocks["ships"]) - g.clock <= 46.0)
	_walk(g, g.clock + 52.0)
	check("THE SHIPS SAIL: WON, `colonists` many, Ruggieri alive", g.over and r.winner_side == "column" and str(r.flags.get("colonists")) == "many"
		and str(r.flags.get("ruggieri")) == "alive" and r.obj.get("people_live", "") == "done", "%s %s %s" % [g.over, r.winner_side, r.flags])
	# some aboard: `colonists` some
	_progress()
	g = await _start()
	r = g.mission
	_to_part3(g, r)
	n = int(r.counters["people_n"])
	var ppl: Array = _alive(r, "people")
	for i in ppl.size():
		if i < int(n * 0.6):
			ppl[i].position = _mid(r, "quay_in")
		else:
			_kill([ppl[i]])
	g._rebuild_hash()
	for i in 20:
		_walk(g, g.clock + 0.5)
		await physics_frame
	_walk(g, float(r.fired["part3"]) + 200.0)
	check("sixty in a hundred aboard: WON, `colonists` some", g.over and r.winner_side == "column" and str(r.flags.get("colonists")) == "some",
		"%s %s" % [r.winner_side, r.flags])


func _defeat() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part3(g, r)
	_kill(r.tagged("people"))
	_walk(g, float(r.fired["part3"]) + 190.0)
	check("nobody aboard when the ships sail: LOST", g.over and r.winner_side != "column" and _said(r, "n_too_few") and r.obj.get("people_live", "") == "failed",
		"%s %s" % [g.over, r.winner_side])
	_progress()
	g = await _start()
	r = g.mission
	_walk(g, 6.0)
	_kill(r.tagged("harbour_fort"))
	_walk(g, g.clock + 8.0)
	check("the harbour fort broken: LOST", g.over and r.winner_side != "column" and _said(r, "n_fort_lost"), "%s %s" % [g.over, r.winner_side])


# ================================================================== THE FIRE: the solo pick and versus

func _fire() -> void:
	_progress({}, "clockwork")
	var g: Game = await _start("solo", "fire")
	var r := g.mission
	check("THE FIRE picked: the player is the swarm (the river road)", g.human == r.team_index("fire") and r.cond({"playing": "fire"})
		and not r.cond({"playing": "column"}) and g.factions[g.human] == "brood")
	check("... its objective, its first strength, its lines", r.obj.get("f_catch", "") == "active" and _alive(r, "f_army").size() >= 10 and _said(r, "n_f1"))
	check("... the scripted army holds the ford (no scripted waves, no ambush)", r.fired.has("sc_hold") and not r.fired.has("fwave_1"))
	var n0 := _alive(r, "f_army").size()
	_walk(g, 60.0)
	check("... more of its own every minute", _alive(r, "f_army").size() > n0 and _said(r, "n_f_reinf"))
	_to_part2(g, r)
	_walk(g, g.clock + 30.0)
	check("... the front breaks: the scripted army walks the road, the people do not wait at the pass", r.fired.has("sc_road") and r.fired.has("through"))
	_kill(r.tagged("people"))
	_to_part3(g, r)
	r.clocks["ships"] = g.clock + 0.5
	_walk(g, g.clock + 8.0)
	check("THE FIRE: the ships sail with nobody aboard: WON for the fire", g.over and r.winner_side == "fire" and str(r.flags.get("colonists", "")) == "",
		"%s %s %s" % [g.over, r.winner_side, r.flags])
	# versus: the fort
	_progress()
	g = await _start("versus", "", "fire")
	r = g.mission
	check("versus: the friend is the fire (the machines, the southern road), his objective", r.cond({"playing": "fire"}) and r.obj.get("f_catch", "") == "active"
		and g.factions[r.team_index("fire")] == "clockwork")
	_walk(g, 10.0)
	_kill(r.tagged("harbour_fort"))
	_walk(g, g.clock + 7.0)
	check("versus: the harbour fort broken: WON for the fire", g.over and r.winner_side == "fire", "%s %s" % [g.over, r.winner_side])


# ================================================================== save and load, ironman

func _snap(g: Game) -> Dictionary:
	var r := g.mission
	var tags := {}
	for k in r.tags:
		tags[k] = r.tagged(k).size()
	return {"flags": r.flags, "counters": r.counters, "obj": r.obj, "tags": tags, "fired": r.fired.keys().size()}


func _save_load() -> void:
	for first in ["brood", "clockwork"]:
		_progress({}, first)
		MissionSave.clear_all(MID)
		var g: Game = await _start()
		var r := g.mission
		_to_part2(g, r)
		_walk(g, g.clock + 12.0)
		var before := _snap(g)
		main.mission_save_now()
		check("SAVE written in Part 2 (%s)" % first, MissionSave.has(MID, "save"))
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
		check("LOADED the same (%s): flags (the version too), counters, objectives, tags" % first, diff.is_empty(), "; ".join(diff))
		check("... on the version's own map and areas", g2.map_id == ("campaign:brazil_river" if first == "clockwork" else "campaign:brazil_south")
			and g2.mission.area_rect("quay") == r.area_rect("quay"), g2.map_id)
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


# ================================================================== the hubs after e01

func _hubs() -> void:
	_progress()
	Campaign.record(MID, "solo", "column", "column", {"version": "south", "colonists": "many", "ruggieri": "alive"})
	var p := Campaign.progress()
	var pro: Dictionary = {}
	for s in Campaign.index()["storylines"]:
		if String(s["id"]) == "prologue":
			pro = s
	check("the King's study: the King on the number, not a guess", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["king"], p)).contains("not a guess"))
	check("the King's study: the dispatch from aboard", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["dispatch"], p)).contains("off the coast of Brazil"))
	Campaign.record(MID, "solo", "column", "column", {"version": "river", "colonists": "few", "ruggieri": "alive"})
	p = Campaign.progress()
	check("too few: the King's other line", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["king"], p)).contains("has not forgiven himself"))
