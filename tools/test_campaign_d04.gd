extends SceneTree
## Act 2's "The City of Gears" (docs/campaign_d04_build.md):
##   - the data checks out, every text has pt and es, the Clockmaker line lists it after d02 and it opens only once d02
##     is won (`needs`), the seats (solo the guild, versus the valley), the HIGHLANDS map and the stills, THE ROSTER
##     LADDER's K5 for the guild (the Clock Aviary and the Swift), the hub's purse and reach (hubs-grow);
##   - THE FLAGS at the start: d02 `exodus` (2 / 3 / 4 houses) and c01 `saved` many (+1), c01 `gate` and d02 `drawings`
##     (the Heavy Works standing, or built from memory in Part 2), a06 `varenne` (Varenne or Citizen Morel);
##   - THE FOG OF THE UNMAPPED: the plateau known, the ways dark; a valley man on dark land is off the guild's screen;
##     a Swift flying over a way maps it;
##   - PART 1: the Clocktower's site, then the Mainspring's, the Cog Press's and the Aviary's, two Swifts, the three ways
##     mapped (the captain comes sooner); a04 `broken` kept: THE FIRST RAID; melted: THE PARLEY (Hollweg walks down, the
##     council's voice goes with him; flag `colonists` parley at the end) or the parley missed (a raid);
##   - PART 2: the crowds with torches (spared), TURN THEM BACK, a fire raises THE VALLEY'S TEMPER, Padre Anselmo calls
##     them home; the temper at its top: the militia rides at once;
##   - PART 3: the crates (Hollweg in the gallery: the crates' soldiers, the plates' spreading gear ground), the dawn
##     attack, its break and the win (`crates` opened, `colonists` fought), the ending and debrief;
##   - THE DEFEATS: the first quarter burnt; the Clocktower down;
##   - VERSUS: the valley's seat, its win;
##   - SAVE AND LOAD in the middle (the chart's map kept), IRONMAN, the HUBS and the WAR MAP after d04.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_d04.gd
## Prints CHECK lines, then "campaign_d04: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "d04_concordia"
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
	print("campaign_d04: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if the line was played up to d02 with these flags (each merged over its canon), at a difficulty.
## `with_d02` false: d02 not finished.
func _progress(c01 := {}, a04 := {}, a06 := {}, d02 := {}, diff := "normal", with_d02 := true) -> void:
	var p := {"reached": [MID], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	var f1 := {"bells": "quiet", "saved": "some", "jakob": "alive", "cut": "no", "gate": "pattern"}
	f1.merge(c01, true)
	p["done"]["c01_thirteenth"] = {"won_by": "guild", "side": "guild", "flags": f1}
	p["done"]["a02_furth"] = {"won_by": "guild", "side": "guild", "flags": {"stopwork": "fitted", "furth": "strong", "jakob": "alive"}}
	var f4 := {"broken": "kept", "lost_to_machine": 0, "stopworks": "found", "jakob": "alive"}
	f4.merge(a04, true)
	p["done"]["a04_visit"] = {"won_by": "visit", "side": "visit", "flags": f4}
	var f6 := {"varenne": "spared", "paris": "stood"}
	f6.merge(a06, true)
	p["done"]["a06_barricades"] = {"won_by": "crown", "side": "crown", "flags": f6}
	p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}}
	if with_d02:
		var f2 := {"exodus": "some", "exodus_n": 3, "drawings": "carried", "jakob": "stayed"}
		f2.merge(d02, true)
		p["done"]["d02_exodus"] = {"won_by": "exodus", "side": "exodus", "flags": f2}
	Campaign.save_progress(p)


func _start(mode := "solo") -> Game:
	if main.game:
		main._to_menu()
		await process_frame
	for n in main.ui_layer.get_children():
		if n.name == "MissionEnd" or n is StillShow:
			n.queue_free()
	main.start(Campaign.make_cfg(MID, mode, "p1", false, ""))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	_step(g, 1.0)
	_step(g, 2.0)
	return g


## The clock moved to `to` and one round of the mission's checks (as its 0.25 s tick does, Act 2's pieces included).
func _step(g: Game, to: float) -> void:
	g.clock = to
	var r := g.mission
	r._t = 0.0
	paused = false
	r._physics_process(MissionRun.TICK)


## Steps from the clock now to `to`, a quarter second at a time (a STAY and a TURN need every check).
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
		i += 1
	g._rebuild_hash()


func _mid(r: MissionRun, area: String) -> Vector2:
	return r.area_rect(area).get_center()


func _said(r: MissionRun, id: String) -> bool:
	return r.said_ids.has(id)


func _team_units(g: Game, r: MissionRun, team: String, kinds: Array = []) -> Array:
	var t := r.team_index(team)
	return g.units.filter(func(u): return not u.dead and u.team == t and (kinds.is_empty() or kinds.has(u.kind)))


func _fighters(g: Game, r: MissionRun) -> Array:
	return _team_units(g, r, "guild", ["clock_soldier", "springer", "netter", "pendulum"])


## A site of the tag finished at once (its Winders' work done).
func _finish_site(g: Game, r: MissionRun, tag: String) -> void:
	for b in r.tagged(tag):
		if b is Building and not b.built:
			b.add_progress(99999.0)
	_step(g, g.clock + 0.25)


## Part 1 by the script: the tower, the spring, the press and the Aviary finished, two Swifts made and flown over the
## three ways.
func _part1(g: Game, r: MissionRun) -> void:
	_finish_site(g, r, "tower")
	_walk(g, g.clock + 1.0)
	_finish_site(g, r, "spring")
	_finish_site(g, r, "press")
	_walk(g, g.clock + 1.0)
	_finish_site(g, r, "aviary")
	_walk(g, g.clock + 1.0)
	var t := r.team_index("guild")
	for i in 2:
		r.act({"spawn": {"team": "guild", "kind": "cuckoo", "count": 1, "at": "aviary_spot", "tag": "test_swifts"}})
	_walk(g, g.clock + 1.5)
	for w in ["way_road", "way_path", "way_track"]:
		_put(g, r.tagged("test_swifts").slice(0, 1), _mid(r, w))
		_walk(g, g.clock + 1.0)
	_put(g, r.tagged("test_swifts"), _mid(r, "west_field"))


func _run() -> void:
	await process_frame
	_data()
	await _flags()
	await _chart()
	await _play()
	await _parley()
	await _boil()
	await _defeats()
	await _versus()
	await _save_load()
	await _ironman()
	_hubs()
	check("no script error in the whole run", _errs.is_empty(), str(_errs.slice(0, 3)))
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("d04_concordia: data checks out", pr.is_empty(), "; ".join(pr))
	var extra := ["Concórdia's Council Hall", "TURNING BACK", "TURNED BACK!", "Pattern of 2767", "Captain Arruda", "Padre Anselmo"]
	for role in ["settler", "varenne_exile", "morel", "arruda", "valley_militia", "rancher", "colonist", "colonist_torch", "anselmo", "crate_soldier"]:
		extra.append(String(Rebels.ROLES[role]["about"]))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + extra:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission, its roles and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Clockmaker line lists d04 after d02", String(sl.get("id", "")) == "clockmaker"
		and (sl["missions"] as Array).find(MID) == (sl["missions"] as Array).find("d02_exodus") + 1)
	check("d02's next (the guild's side) is d04", String(Campaign.mission("d02_exodus")["next"]["exodus"]) == MID)
	_progress({}, {}, {}, {}, "normal", false)
	check("d04 is shut until d02 is won (needs d02)", not Campaign.unlocked(MID))
	_progress()
	check("... and open once it is", Campaign.unlocked(MID))
	check("the seats: solo the guild only; versus the guild p1, the valley p2", Campaign.solo_sides(m) == ["guild"]
		and Campaign.seat_side(m, "versus", "p1") == "guild" and Campaign.seat_side(m, "versus", "p2") == "valley")
	check("the map is the HIGHLANDS (THE HIGHLANDS biome)", Campaign.map_data("concordia").get("biome", "") == "highlands")
	for k in m["stills"]:
		check("still %s is in" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	var gt: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "guild")[0]
	check("THE ROSTER LADDER K5: the guild may have the Clock Aviary and the Swift, both NEW (and K4's turret still)",
		(gt["roster"]["allow"] as Array).has("cuckoo_house") and (gt["roster"]["allow"] as Array).has("ratchet_turret")
		and (gt["roster"]["new"] as Array) == ["cuckoo_house", "cuckoo"])
	check("hubs-grow: d04 earns GUILD MARKS and the guild's rooms reach it", (HubGrow.line("clockmaker")["earn"] as Array).has(MID)
		and HubGrow.line_for(MID) == "clockmaker")


# ================================================================== the flags at the start

func _flags() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	check("canon: 3 houses of the first quarter (d02 exodus some), 900 health each", r.tagged("houses").size() == 3
		and int(r.counters["houses_n"]) == 3 and r.tagged("houses").all(func(b): return b.max_hp >= 900.0))
	check("canon: the Heavy Works stands (the pattern; the drawings carried)", r.tagged("heavy").size() == 1 and r.tagged("heavy")[0].built
		and not r.denied(r.team_index("guild"), "heavy_works"))
	check("canon: Varenne is the council's voice (a06 spared)", r.tagged("varenne").size() == 1 and r.tagged("morel").is_empty()
		and r.tagged("voice")[0].spared)
	check("the Clocktower is a site to raise; the guild's cogs and Tension at hand", r.tagged("tower").size() == 1 and not r.tagged("tower")[0].built
		and int(g.players[r.team_index("guild")]["gold"]) >= 500)
	check("the Clock Soldiers are drilled to SHIELD WALL (K4 carried)", g.has_tech(r.team_index("guild"), "shield_wall"))
	check("the guild's army starts wound", _fighters(g, r).all(func(u): return u.wind > 0.9))
	_progress({}, {}, {}, {"exodus": "few"})
	g = await _start()
	check("d02 exodus few: 2 houses", g.mission.tagged("houses").size() == 2)
	_progress({"saved": "many"}, {}, {}, {"exodus": "many"})
	g = await _start()
	check("d02 exodus many + c01 saved many: 5 houses", g.mission.tagged("houses").size() == 5)
	_progress({"gate": "people"})
	g = await _start()
	r = g.mission
	check("c01 gate people: no Heavy Works; Hollweg builds it from memory (denied until the night)", r.tagged("heavy").is_empty()
		and r.denied(r.team_index("guild"), "heavy_works"))
	_progress({}, {}, {}, {"drawings": "taken"})
	g = await _start()
	check("d02 drawings taken: from memory too", g.mission.tagged("heavy").is_empty())
	_progress({}, {}, {"varenne": "executed"})
	g = await _start()
	r = g.mission
	check("a06 Varenne executed: Citizen Morel is the council's voice", r.tagged("morel").size() == 1 and r.tagged("varenne").is_empty())


# ================================================================== THE FOG OF THE UNMAPPED

func _chart() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	var a2 := r.a2
	check("the chart is on: the plateau known, the cart road below dark", a2.chart_share("plateau") > 0.99 and a2.chart_share("way_road") < 0.2)
	check("the land is drawn dark where unmapped (the guild's screen)", a2._chart_sprite != null and a2._chart_sprite.visible)
	r.act({"spawn": {"team": "militia", "kind": "musketeer", "count": 1, "at": "road_mid", "tag": "test_scout"}})
	var scout: Unit = r.tagged("test_scout")[0]
	var gt := r.team_index("guild")
	_put(g, _team_units(g, r, "guild", ["clock_soldier"]).slice(0, 1), scout.position + Vector2(60, 0))
	g.refresh_fog()
	check("a valley man on dark land is off the guild's screen, though a soldier of the guild stands by him", not scout.visible
		and g.is_visible_to(gt, scout.position))
	r.act({"spawn": {"team": "guild", "kind": "cuckoo", "count": 1, "at": "road_mid", "tag": "test_swift"}})
	_walk(g, g.clock + 1.0)
	g.refresh_fog()
	check("a Swift over the road maps it: the man is seen", a2.chart_share("way_road") > 0.2 and scout.visible)
	_put(g, r.tagged("test_swift"), _mid(r, "way_road"))
	_walk(g, g.clock + 1.5)
	check("the way mapped: counted (1 of 3)", int(r.counters["mapped"]) >= 1 and r.fired.has("map_road"))


# ================================================================== the play through (a04 broken kept: the raid)

func _play() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 9.0)
	check("the NEW card for K5 is said", _said(r, "new_cuckoo_house") and _said(r, "new_cuckoo"))
	_finish_site(g, r, "tower")
	_walk(g, g.clock + 1.0)
	check("the tower stands: the Mainspring's and the Cog Press's sites, the captain's clock", r.fired.has("tower_built")
		and r.tagged("spring").size() == 1 and r.tagged("press").size() == 1 and r.clocks.has("captain") and r.obj.get("city_tower", "") == "active")
	_finish_site(g, r, "spring")
	_walk(g, g.clock + 1.0)
	check("the spring wound: the Aviary's site", r.fired.has("spring_built") and r.tagged("aviary").size() == 1)
	_finish_site(g, r, "aviary")
	_walk(g, g.clock + 1.0)
	var av: Building = r.tagged("aviary")[0]
	var why := g.train(av, "cuckoo")
	check("the Aviary makes a Swift (meshed with the Mainspring: Tension flows)", why == "", why)
	check("... and asks for two", r.obj.get("swifts", "") == "active")
	var left0 := float(r.clocks["captain"]) - g.clock
	_part1(g, r)
	check("three ways mapped: the captain comes sooner", int(r.counters["mapped"]) == 3 and r.fired.has("map_all")
		and float(r.clocks["captain"]) - g.clock < left0 - 60.0)
	_walk(g, float(r.clocks["captain"]) + 1.0)
	check("a04 broken kept: THE FIRST RAID comes up the road and the pine path", r.fired.has("raid") and r.tagged("raid").size() >= 5
		and r.obj.get("raid", "") == "active")
	check("... the guild was told plainly (the road mapped)", _said(r, "u_raid"))
	for u in r.tagged("raid"):
		u.die()
	_walk(g, g.clock + 4.0)
	check("the raid beaten: Part 1 over", r.fired.has("raid_over") and r.fired.has("part1_over"))
	_walk(g, g.clock + 40.0)
	check("PART 2 at night: the crowds' and the temper's objectives, the Heavy Works' denial lifted", r.fired.has("part2")
		and r.obj.get("fear", "") == "active" and r.obj.get("temper", "") == "active")
	_walk(g, g.clock + 9.0)
	var mob: Array = r.tagged("mob").filter(func(u): return u.team == r.team_index("town"))
	check("the first crowd with torches (4: a04 kept), spared", mob.size() == 4 and mob.all(func(u): return u.spared and u.has_meta("torch")))
	var man: Unit = mob[0]
	_put(g, [man], _mid(r, "road_top"))
	r._routes.clear()
	_put(g, _fighters(g, r).slice(0, 2), man.position + Vector2(24, 0))
	_walk(g, g.clock + 3.0)
	check("TURN THEM BACK: two fighters by a torch-bearer with no militia near: he turns back, torch out", man.team == r.team_index("calmed")
		and not man.has_meta("torch") and int(r.counters["turned_back"]) == 1)
	_walk(g, g.clock + 4.0)
	check("... and walks home", man.order == "move")
	var house: Building = r.tagged("houses")[0]
	r.set_alight(house, r.data["torch_fire"])
	_walk(g, g.clock + 1.0)
	check("a fire in the quarter: the temper rises", int(r.counters["temper"]) == 1 and r.burning_count("city") == 1)
	_put(g, _team_units(g, r, "guild", ["winder"]).slice(0, 1), house.center() + Vector2(0, 40))
	_walk(g, g.clock + 8.0)
	check("a Winder by the fire puts it out", r.burning_count("city") == 0)
	_walk(g, float(r.fired["mob_3"]) + 25.0 + 1.0)
	check("PADRE ANSELMO comes up the road", r.fired.has("anselmo") and r.tagged("anselmo").size() == 1)
	_put(g, r.tagged("anselmo"), _mid(r, "road_top"))
	_walk(g, g.clock + 45.0)
	check("... calls his people home: the crowds turn back, torches out", r.fired.has("anselmo_calls")
		and r.tagged("mob").filter(func(u): return not u.dead and u.team == r.team_index("town")).is_empty())
	_walk(g, float(r.fired["anselmo_calls"]) + 20.0)
	check("PART 3 at dawn: the crates' objective", r.fired.has("part3") and r.obj.get("crates", "") == "active")
	var hw: Unit = r.tagged("hollweg")[0]
	_put(g, [hw], _mid(r, "gallery"))
	_walk(g, g.clock + 9.0)
	check("Hollweg in the gallery: the crates opened (two soldiers of 2767, a Winder, the plates' gear ground)", r.fired.has("crates_open")
		and r.tagged("crate_men").size() == 3 and str(r.flags.get("crates")) == "opened"
		and (r.act2["grounds"] as Array).any(func(x): return String(x["name"]) == "plates" and String(x["kind"]) == "gear"))
	_walk(g, g.clock + 30.0)
	check("the plates creep across the floor by themselves", (r.act2["grounds"] as Array).filter(func(x): return String(x["name"]) == "plates")[0]["r"] > 2.0)
	check("the dawn attack up the road and the ranch track", r.fired.has("attack") and r.tagged("road_men").size() >= 4 and r.tagged("track_men").size() >= 2)
	_walk(g, g.clock + 25.0)
	check("... and the pine path", r.fired.has("attack_path") and not r.tagged("path_men").is_empty())
	for u in r.tagged("attack"):
		u.die()
	_walk(g, g.clock + 12.0)
	check("the attack broken, the crates opened: the city stands (the guild wins)", g.over and r.winner_side == "guild", r.winner_side)
	check("the flags: colonists fought (no parley), crates opened", str(r.flags.get("colonists")) == "fought" and str(r.flags.get("crates")) == "opened")
	var pages := r.pages_now(Campaign.show_pages(r.data, "ending", "guild"))
	check("the ending has its pages", pages.size() == 2)
	check("the debrief fills its numbers", r.fill(String(r.data["debrief"]["guild"]["text"])).contains("3 houses") or r.fill(String(r.data["debrief"]["guild"]["text"])).contains("of 3"))


# ================================================================== the parley (a04 broken melted)

func _parley() -> void:
	_progress({}, {"broken": "melted"})
	var g: Game = await _start()
	var r := g.mission
	_part1(g, r)
	_walk(g, float(r.clocks["captain"]) + 1.0)
	check("a04 melted: the captain waits on the road to PARLEY (no raid), spared", r.fired.has("parley_go") and not r.fired.has("raid")
		and r.obj.get("parley", "") == "active" and r.tagged("arruda")[0].spared)
	var hw: Unit = r.tagged("hollweg")[0]
	_put(g, [hw], _mid(r, "parley"))
	_put(g, r.tagged("voice"), _mid(r, "parley") + Vector2(16, 0))
	_walk(g, g.clock + 5.0)
	check("Hollweg and the council's voice by him: THE PARLEY (Hollweg forbids his machines to strike the valley)", r.fired.has("parley")
		and _said(r, "h_parley") and _said(r, "v_parley"))
	_walk(g, g.clock + 30.0)
	check("the captain rides home: Part 1 over without a blow", r.fired.has("parley_gone") and r.tagged("arruda").is_empty() and r.fired.has("part1_over"))
	# straight to the end: the night with no fire, the crates, the attack (smaller: half the valley stayed home)
	_walk(g, float(r.fired["part1_over"]) + 45.0)
	_walk(g, float(r.fired["part2"]) + 8.0 + 80.0 + 1.0)
	_put(g, r.tagged("anselmo"), _mid(r, "road_top"))
	_walk(g, g.clock + 50.0)
	_put(g, r.tagged("hollweg"), _mid(r, "gallery"))
	_walk(g, g.clock + 25.0)
	check("after the parley the dawn attack is smaller, and no path party", r.fired.has("attack") and r.tagged("attack").size() <= 9
		and not r.fired.has("attack_path"), str(r.tagged("attack").size()))
	for u in r.tagged("attack"):
		u.die()
	_walk(g, g.clock + 12.0)
	check("won with the parley: flag colonists parley", g.over and r.winner_side == "guild" and str(r.flags.get("colonists")) == "parley")
	# the parley missed: the captain raids
	_progress({}, {"broken": "melted"})
	g = await _start()
	r = g.mission
	_part1(g, r)
	_walk(g, float(r.clocks["captain"]) + 1.0)
	_walk(g, float(r.clocks["parley"]) + 1.0)
	check("nobody came down to talk: the parley failed and the raid comes", r.fired.has("parley_fail") and r.fired.has("raid")
		and r.obj.get("parley", "") == "failed")


# ================================================================== the temper boiled over

func _boil() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_part1(g, r)
	_walk(g, float(r.clocks["captain"]) + 1.0)
	for u in r.tagged("raid"):
		u.die()
	_walk(g, g.clock + 50.0)
	check("the night", r.fired.has("part2"))
	r.act({"counter": {"name": "temper", "add": 8}})
	_walk(g, g.clock + 1.0)
	check("THE VALLEY'S TEMPER at its top (8 NORMAL): the bells ring, the militia rides at once", r.fired.has("boil")
		and str(r.flags.get("colonists")) == "fought")
	_walk(g, g.clock + 5.0)
	check("... Part 3 early, the attack bigger, the crowds sent home", r.fired.has("part3") and r.fired.has("attack")
		and r.tagged("mob").filter(func(u): return not u.dead and u.team == r.team_index("town") and not u.has_meta("mission_turning")).size() <= 4)


# ================================================================== the defeats

func _defeats() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	for b in r.tagged("houses"):
		b.die()
	_walk(g, g.clock + 6.0)
	check("every house of the first quarter burnt: lost", g.over and r.winner_side != "guild" and r.obj.get("quarter", "") == "failed", r.winner_side)
	_progress()
	g = await _start()
	r = g.mission
	_finish_site(g, r, "tower")
	_walk(g, g.clock + 1.0)
	r.tagged("tower")[0].die()
	_walk(g, g.clock + 6.0)
	check("the Clocktower down: lost", g.over and r.winner_side != "guild" and r.obj.get("city_tower", "") == "failed")


# ================================================================== versus: the valley

func _versus() -> void:
	_progress()
	var g: Game = await _start("versus")
	var r := g.mission
	check("versus: the guild is the host's (p1); the valley's militia is p2's, with Arruda and men in the town",
		g.human == r.team_index("guild") and r.tagged("arruda").size() == 1 and r.tagged("militia_men").size() >= 7)
	check("... no parley in versus and no scripted orders on p2's men", not r.fired.has("parley_go"))
	for b in r.tagged("houses"):
		b.die()
	_walk(g, g.clock + 6.0)
	check("the valley burns the first quarter: the valley wins", g.over and r.winner_side == "valley", r.winner_side)
	var pages := r.pages_now(Campaign.show_pages(r.data, "ending", "valley"))
	check("the valley's ending: the King says that is not how it went", pages.size() == 2)


# ================================================================== save and load in the middle

func _snap(g: Game) -> Dictionary:
	var r := g.mission
	var tg := {}
	for t in r.tags:
		tg[t] = r.tagged(String(t)).size()
	return {"flags": r.flags, "counters": r.counters, "obj": r.obj, "tags": tg, "chart_on": bool(r.act2["chart"].get("on", false)),
		"road": snappedf(r.a2.chart_share("way_road"), 0.01), "plateau": snappedf(r.a2.chart_share("plateau"), 0.01),
		"deny": r.deny.get(r.team_index("guild"), {}).size(), "tech": g.has_tech(r.team_index("guild"), "shield_wall")}


func _save_load() -> void:
	_progress()
	MissionSave.clear_all(MID)
	var g: Game = await _start()
	var r := g.mission
	_part1(g, r)
	_walk(g, g.clock + 4.0)
	var before := _snap(g)
	main.mission_save_now()
	check("SAVE written once the ways are mapped", MissionSave.has(MID, "save"))
	main.mission_load("save")
	await process_frame
	await process_frame
	paused = false
	var g2: Game = main.game
	if g2.hud:
		g2.hud.countdown = 0.0
	g2.mission._physics_process(MissionRun.TICK)
	var after := _snap(g2)
	var diff: Array = []
	for k in before:
		if JSON.stringify(before[k], "", true) != JSON.stringify(after[k], "", true):
			diff.append("%s: %s -> %s" % [k, before[k], after[k]])
	check("LOADED the same: flags, counters, objectives, tags, THE CHART'S MAP, the denied, the drill", diff.is_empty(), "; ".join(diff))
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


# ================================================================== the hubs and the war map after d04

func _hubs() -> void:
	_progress()
	Campaign.record(MID, "solo", "guild", "guild", {"colonists": "fought", "crates": "opened"})
	var p := Campaign.progress()
	var sl := Campaign.storyline_of(MID)
	var hw: Dictionary = sl["hub"]["talks"]["hollweg"]
	check("the hub: Hollweg talks of the council after d04", str(CampaignMenu.talk_lines(hw, p)).contains("council meets at noon"))
	check("the hub is Concórdia's council hall after d04", str(sl["hub"]["after"]).contains("Concórdia's Council Hall"))
	check("the hub: Ulrich talks of the plates", str(HubGrow.talk_lines(HubGrow.talk("ulrich"), p)).contains("plates lay themselves"))
	var st: Dictionary = WarMapData.state(p)
	var led: Array = st.get("ledger", []).map(func(x): return String(x.get("text", "")))
	check("the war map's ledger: Concórdia founded, the valley fought, the crates opened",
		led.has("Hollweg founded Concórdia on the southern highlands: a city that governs itself.")
		and led.has("The valley fought the city from its first day.") and led.has("In the mine Hollweg opened the two crates of 2767."), str(led.slice(-4)))
	check("the war map's data has no problem", WarMapData.problems().is_empty(), "; ".join(WarMapData.problems()))
