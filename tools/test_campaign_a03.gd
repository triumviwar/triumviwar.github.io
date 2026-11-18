extends SceneTree
## Act 1's "The Lost Plateau" (docs/campaign_a03_build.md):
##   - the data checks out, every text has pt and es, the Naturalist line lists it after b01 and b01's pack win leads to
##     it, the seats for solo (either side) and versus, the map and the stills load;
##   - THE PROLOGUE'S FLAGS at the start (b01_specimen: saved few / some / many, eggs left / taken, turtle early / late,
##     rival standing / driven, teles told / quiet, pieter alive / lost) and none at all (b01's canon);
##   - THE PARTY played through: the climb, the four marks (a STAY each), the rim's sight of the nest and Linnea, THE MAP
##     both ways, the nest waking, the Sire home, the canoe's countdown, the exit counted, the win, the flags kept and the
##     ending; the nest woken early (the survey cut short); the defeats (Valadares killed, the rains, the canoe gone);
##   - THE NEST (the solo side pick): its hunters asleep and every new one with them, the workers awake, the scripted
##     party's route, the Sire home, the win by Valadares killed and by the party brought under half, the loss when he
##     gets down;
##   - THE DIFFICULTY: the nest's numbers and the raced clocks on EASY and HARD, the player's side never scaled;
##   - THE HUB: Lindqvist reads the report (by the map and by the side).
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_a03.gd
## Prints CHECK lines, then "campaign_a03: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "a03_plateau"
const B01 := "b01_specimen"
const CANON := {"teles": "quiet", "clutch": "saved", "eggs": "left", "saved": "some", "saved_n": 15, "pieter": "lost",
	"turtle": "late", "rival": "standing"}
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
	print("campaign_a03: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if b01 was won by the Sire's pack with these flags ({} none: b01 not in the progress), at a difficulty.
func _progress(flags: Variant, diff := "normal") -> void:
	var p := {"reached": [MID], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if flags is Dictionary:
		var f: Dictionary = CANON.duplicate()
		f.merge(flags, true)
		p["done"][B01] = {"won_by": "sire", "side": "sire", "flags": f}
	Campaign.save_progress(p)


func _start(side := "", mode := "solo") -> Game:
	if main.game:
		main._to_menu()
		await process_frame
	for n in main.ui_layer.get_children():
		if n.name == "MissionEnd" or n is StillShow:
			n.queue_free()
	main.start(Campaign.make_cfg(MID, mode, "p1", false, side))
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
	r._tick_routes()
	r._tick_sleep()
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


func _put(g: Game, us: Array, at: Rect2) -> void:
	var i := 0
	for u in us:
		u.position = at.get_center() + Vector2((i % 4) * 14 - 21, (i / 4) * 14 - 14)
		u.velocity = Vector2.ZERO
		i += 1
	g._rebuild_hash()


func _n(g: Game, t: int, kind: String) -> int:
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind == kind).size()


func _people(g: Game, r: MissionRun) -> Array:
	var pt := r.team_index("party")
	return g.units.filter(func(u): return not u.dead and u.team == pt and u.kind in ["musketeer", "labourer", "dismounted"])


func _run() -> void:
	await process_frame
	_data()
	await _flags()
	await _party_play()
	await _woken()
	await _defeats()
	await _nest_play()
	await _difficulty()
	await _hub()
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("a03_plateau: data checks out", pr.is_empty(), "; ".join(pr))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings():
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	for t in ["The supply cache", "The Mother", "Young", "Guide"]:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(t)
	check("every text of the mission, the hubs and its names has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Naturalist line: b01, then a03", String(sl.get("id", "")) == "naturalist" and (sl["missions"] as Array).slice(0, 2) == [B01, MID])
	check("b01 won by the pack leads to a03", Campaign.next_of(B01, "sire") == MID and Campaign.next_of(B01, "rival") == "")
	check("a03 leads nowhere yet (a05 is not built)", Campaign.next_of(MID, "party") == "" and Campaign.next_of(MID, "nest") == "")
	Campaign.save_progress({"reached": [], "done": {"p01_leaf": {}}})
	check("a03 is locked before b01", not Campaign.unlocked(MID))
	Campaign.record(B01, "solo", "sire", "sire", CANON)
	check("...and open once b01 is won", Campaign.unlocked(MID))
	check("solo sides: the party (default) and the nest", Campaign.solo_sides(m) == ["party", "nest"])
	var c := Campaign.make_cfg(MID, "solo")
	check("solo as the party: you; the nest and the rest scripted", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "script", "script"])
	c = Campaign.make_cfg(MID, "solo", "p1", false, "nest")
	check("solo as the nest: you are green; the party scripted", c["slots"].map(func(s): return s["who"]) == ["script", "you", "script", "script", "script"]
		and String(c["campaign"]["side"]) == "nest")
	c = Campaign.make_cfg(MID, "versus", "p1", true)
	check("versus online: the friend is the nest", c["slots"].map(func(s): return s["who"]) == ["you", "remote", "script", "script", "script"])
	check("the party YELLOW, the nest GREEN, the red pack RED", int(c["slots"][0]["colour"]) == 3 and int(c["slots"][1]["colour"]) == 2 and int(c["slots"][4]["colour"]) == 1)
	var md := Campaign.map_data("cloud_plateau")
	check("the map is the cloud plateau, jungle, 128 x 112", String(m["map"]) == "campaign:cloud_plateau" and String(md.get("biome", "")) == "jungle"
		and (md.get("size", []) as Array).map(func(x): return int(x)) == [128, 112])
	for k in m["stills"]:
		check("still %s: its picture loads" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	check("the opening and the ending per side", (m["opening"] as Dictionary).has("party") and (m["opening"] as Dictionary).has("nest")
		and (m["ending"] as Dictionary).has("party") and (m["ending"] as Dictionary).has("nest"))
	check("no creature speaks: the nest's pages are the King's", (m["opening"]["nest"] as Array).all(func(pg): return (pg["lines"] as Array).all(
		func(l): return String(m["lines"][l]["who"]) == "king")) and (m["ending"]["nest"] as Array).all(func(pg): return (pg["lines"] as Array).all(
		func(l): return String(m["lines"][l]["who"]) == "king")))
	# (but the roster ladder's NEW cards: the game's own voice, docs/campaign_roster_ladder.md)
	check("no line is said to the nest but the NEW cards", (m["lines"] as Dictionary).values().all(func(l): return String(l.get("to", "")) != "nest" or String(l["who"]) == "new"))


# ================================================================== the prologue's flags at the start

func _flags() -> void:
	for which in ["canon", "none"]:
		_progress(CANON if which == "canon" else null)
		var g := await _start()
		var r: MissionRun = g.mission
		var nt := r.team_index("nest")
		var pt := r.team_index("party")
		_step(g, 1.0)
		_step(g, 2.5)
		var P := "flags %s: " % which
		check(P + "Valadares, Benedito, four men, one guide", r.tagged("valadares").size() == 1 and r.tagged("benedito").size() == 1
			and r.tagged("men").size() == 4 and r.tagged("guides").size() == 1 and r.tagged("teles_men").is_empty())
		check(P + "the party counted at the start (7)", int(r.counters["party0"]) == 7, str(r.counters["party0"]))
		check(P + "the guide lights the waterfall stair", r.said_ids.has("g_stair") and not r.said_ids.has("g_split"))
		check(P + "the supply cache: a Powder Wagon, pinned", r.tagged("cache").size() == 1 and r.tagged("cache")[0].kind == "powder_wagon"
			and r.tagged("cache")[0].m_pace == 0.0)
		check(P + "the nest: its Mother in the hollow, spared (nobody plays the nest)", r.tagged("nest_mother").size() == 1
			and r.tagged("nest_mother")[0].kind == "brood_mother" and r.tagged("nest_mother")[0].spared)
		check(P + "six Raptors and two Spitters asleep", _n(g, nt, "raptor") == 6 and _n(g, nt, "spitter") == 2
			and r.tagged("nest_guard").all(func(u): return u.has_meta("mission_asleep")), "%d raptors" % _n(g, nt, "raptor"))
		check(P + "one Mound Turtle", r.tagged("turtles").size() == 1)
		var lin: Array = r.tagged("linnea")
		check(P + "Linnea among them, grown (half size), spared and still", lin.size() == 1 and is_equal_approx(float(lin[0].get_meta("role_scale", 0.0)), 0.5)
			and lin[0].spared and lin[0].team == r.team_index("kin"))
		check(P + "the red pack in the forest (the rival stood)", r.tagged("red_pack").size() == 3 and r.tagged("red_pack")[0].team == r.team_index("rival"))
		check(P + "two patrols on the top", r.tagged("patrol_w").size() == 3 and r.tagged("patrol_e").size() == 3)
		check(P + "the rains' countdown (14:00)", r.clocks.has("rains") and is_equal_approx(float(r.clocks["rains"]) - float(r.fired["start"]), 840.0), str(r.clocks))
		check(P + "the climb's objective, Valadares must live", r.obj["climb"] == "active" and r.obj["valadares"] == "active" and r.obj["survey"] == "hidden")
		check(P + "the nest's objectives hidden (nobody plays it)", r.obj["n_mother"] == "hidden" and r.obj["n_hunt"] == "hidden")
		check(P + "the mist halves the sight", is_equal_approx(r.mist_sight, 0.5))
		check(P + "the party is yours", g.human == pt)
		_step(g, 4.0)
		_step(g, 30.0)
		check(P + "Pieter lost: the drawings, God rest him", r.said_ids.has("v_drawings") and r.said_ids.has("v_pieter_lost") and not r.said_ids.has("v_pieter"))
	# ---- saved few / many
	_progress({"saved": "few"})
	var g := await _start()
	var r: MissionRun = g.mission
	_step(g, 1.0)
	_step(g, 2.5)
	check("few saved: no guide, Valadares finds the way himself", r.tagged("guides").is_empty() and r.said_ids.has("v_noguide") and int(r.counters["party0"]) == 6)
	_progress({"saved": "many"})
	g = await _start()
	r = g.mission
	_step(g, 1.0)
	_step(g, 2.5)
	_step(g, 11.0)
	check("many saved: two guides, both ways lit", r.tagged("guides").size() == 2 and r.said_ids.has("g_stair") and r.said_ids.has("g_split"))
	# ---- the eggs taken, the turtle early, the rival driven, Teles told, Pieter alive
	_progress({"eggs": "taken", "turtle": "early", "rival": "driven", "teles": "told", "pieter": "alive"})
	g = await _start()
	r = g.mission
	var nt := r.team_index("nest")
	_step(g, 1.0)
	check("eggs taken: four young Raptors more in the nest", _n(g, nt, "raptor") == 10)
	check("turtle early: two Mound Turtles", r.tagged("turtles").size() == 2)
	check("rival driven: no red pack", r.tagged("red_pack").is_empty())
	check("Teles told: six of his Musketeers", r.tagged("teles_men").size() == 6 and int(r.counters["party0"]) == 13)
	_step(g, 4.0)
	_step(g, 30.0)
	check("Pieter alive: his drawings", r.said_ids.has("v_pieter") and not r.said_ids.has("v_pieter_lost"))


# ================================================================== the party, played through

## Up the cliff and round the four marks (the nest's hunters left asleep: nobody comes near them).
func _survey(g: Game, r: MissionRun, P: String) -> void:
	_step(g, 2.0)
	check(P + "the intro", r.said_ids.has("v_1") and r.said_ids.has("b_1"))
	_put(g, r.tagged("valadares"), r.area_rect("stair_top"))
	_step(g, 5.0)
	check(P + "ON THE TOP: the survey's objective, walk softly", r.obj["climb"] == "done" and r.obj["survey"] == "active" and r.obj["softly"] == "active"
		and r.said_ids.has("v_top"))
	var t := 6.0
	for mk in ["cairn", "source", "lookout", "rim"]:
		_put(g, r.tagged("valadares"), r.area_rect(mk))
		_walk(g, t + 38.0)
		check(P + "the %s: not yet after 38 s" % mk, not r.fired.has("mark_" + mk))
		_walk(g, t + 41.0)
		check(P + "THE %s taken (40 s)" % mk.to_upper(), r.fired.has("mark_" + mk))
		t += 42.0
	check(P + "four marks", int(r.counters["marks"]) == 4 and r.objective_text(r.objective("survey")).contains("4 of 4"))
	_walk(g, t + 6.0)
	check(P + "at the rim: the nest seen, Linnea", r.said_ids.has("v_rim") and r.said_ids.has("v_linnea"))
	check(P + "the nest still asleep (Valadares never came within 6 tiles)", r.cond({"asleep": "nest"}))
	check(P + "THE MAP: the choice is offered", r.fired.has("surveyed") and r.obj["survey"] == "done" and String(r.choice_open.get("id", "")) == "map")


func _party_play() -> void:
	# ---- run D: b01's canon, the map DRAWN (the default, unanswered), everyone down
	_progress(CANON)
	var g := await _start()
	var r: MissionRun = g.mission
	var nt := r.team_index("nest")
	var P := "party D (drawn): "
	await _survey(g, r, P)
	var t0 := g.clock
	_walk(g, t0 + 31.0)
	check(P + "the default unanswered: DRAWN", r.flags.get("map", "") == "drawn")
	_walk(g, t0 + 34.0)
	check(P + "PART 3: the nest wakes, the Sire comes home up the way nearest Valadares", r.fired.has("part3") and r.cond({"awake": "nest"})
		and r.tagged("sire").size() == 1 and r.tagged("sire")[0].team == nt
		and r.area_rect("trail_w" if r.flags.get("sire_way", "") == "stair" else "trail_e").grow(64).has_point(r.tagged("sire")[0].position)
		and r.said_ids.has("v_run_e" if r.flags.get("sire_way", "") == "stair" else "v_run_w"))
	check(P + "the flight's objectives, the canoe's countdown (4:30)", r.obj["flee"] == "active" and r.obj["canoe"] == "active"
		and is_equal_approx(float(r.clocks["canoe"]) - float(r.fired["part3_party"]), 270.0) and r.obj["rains"] == "hidden")
	check(P + "the hunters awake and moving", r.tagged("nest_guard").all(func(u): return not u.has_meta("mission_asleep") and u.m_pace > 0.0))
	_step(g, g.clock + 4.0)
	check(P + "the hunters hunt the party", r.tagged("nest_guard").any(func(u): return u.target != null or u.order != "idle"))
	check(P + "the mist thins", is_equal_approx(r.mist_sight, 0.7))
	# the men and the rest reach the canoe; Valadares goes last
	var others := _people(g, r).filter(func(u): return not r.tagged("valadares").has(u))
	_put(g, others, r.area_rect("landing"))
	_step(g, g.clock + 0.5)
	check(P + "the canoe takes them (6 down)", int(r.counters["down"]) == 6 and _people(g, r).size() == 1)
	check(P + "the cache is not taken", r.tagged("cache").size() == 1)
	_put(g, r.tagged("valadares"), r.area_rect("landing"))
	_walk(g, g.clock + 3.0)
	check(P + "Valadares last: the end, ALL down", r.fired.has("the_end") and r.flags.get("party", "") == "all" and int(r.flags.get("party_n", 0)) == 7
		and r.tagged("valadares").size() == 1)
	_walk(g, g.clock + 6.0)
	check(P + "THE PARTY WINS", g.over and r.winner_side == "party")
	check(P + "the flags: map drawn, survey full, Linnea seen", r.flags.get("survey", "") == "full" and r.flags.get("linnea", "") == "seen")
	await create_timer(1.8).timeout
	var show: StillShow = null
	for n in main.ui_layer.get_children():
		if n is StillShow:
			show = n
	check(P + "the party's ending plays", show != null)
	if show:
		for i in 20:
			if is_instance_valid(show) and not show.is_queued_for_deletion():
				show.next()
		check(P + "the ending's lines by the flags", show.shown_ids == ["v_end1", "v_end_all", "v_end_drawn", "v_end_linnea", "k_end1", "k_end_drawn"], str(show.shown_ids))
	var p := Campaign.progress()
	check(P + "it counts: done, by the party, the flags kept", (p["done"] as Dictionary).has(MID) and String(p["done"][MID]["side"]) == "party"
		and Campaign.flag(MID, "map") == "drawn" and Campaign.flag(MID, "party") == "all")
	# ---- run W: the map WITHHELD, men lost: some down
	_progress(CANON)
	g = await _start()
	r = g.mission
	P = "party W (withheld): "
	await _survey(g, r, P)
	r.choose("map", "withheld")
	_step(g, g.clock + 0.5)
	check(P + "WITHHELD", r.flags.get("map", "") == "withheld" and r.said_ids.has("v_withheld"))
	_walk(g, g.clock + 3.0)
	check(P + "part 3", r.fired.has("part3_party"))
	_kill(r, "men")
	_put(g, r.tagged("benedito") + r.tagged("guides"), r.area_rect("landing"))
	_step(g, g.clock + 0.5)
	_put(g, r.tagged("valadares"), r.area_rect("landing"))
	_walk(g, g.clock + 3.0)
	check(P + "four men lost: 3 of 7 down, FEW", r.flags.get("party", "") == "few" and int(r.flags.get("party_n", 0)) == 3, str(r.flags))
	_walk(g, g.clock + 6.0)
	check(P + "...still a win (Valadares came down)", g.over and r.winner_side == "party")
	await create_timer(1.8).timeout
	check(P + "the map withheld kept", Campaign.flag(MID, "map") == "withheld")


## The party woke the nest before the survey was done.
func _woken() -> void:
	_progress(CANON)
	var g := await _start()
	var r: MissionRun = g.mission
	_step(g, 2.0)
	_put(g, r.tagged("valadares"), r.area_rect("stair_top"))
	_step(g, 4.0)
	var guard: Unit = r.tagged("nest_guard")[0]
	_put(g, r.tagged("men").slice(0, 1), Rect2(guard.position - Vector2(64, 64), Vector2(128, 128)))
	_step(g, 4.5)
	check("woken early: the nest is awake", r.cond({"awake": "nest"}))
	_walk(g, 7.0)
	check("woken early: Part 3 at once, the survey cut short, walk softly failed", r.fired.has("part3_party") and r.obj["survey"] == "hidden"
		and r.obj["softly"] == "failed" and r.flags.get("survey", "") == "cut" and r.said_ids.has("v_woke"))
	check("woken early: the map's choice still comes", String(r.choice_open.get("id", "")) == "map")
	check("woken early: a failed optional objective does not lose", not g.over)


func _defeats() -> void:
	_progress(CANON)
	var g := await _start()
	var r: MissionRun = g.mission
	_step(g, 30.0)
	_kill(r, "valadares")
	_step(g, 31.0)
	check("Valadares killed: the party loses", g.over and r.winner_side == "nest" and r.obj["valadares"] == "failed")
	check("...and it does not count", not (Campaign.progress()["done"] as Dictionary).has(MID))
	# a passive party: the rains come at 14:00
	g = await _start()
	r = g.mission
	_step(g, 600.0)
	check("a passive party: nothing at 10:00", not g.over)
	var rains := float(r.clocks["rains"])
	_step(g, rains + 0.5)
	_step(g, rains + 3.0)
	check("...THE RAINS at 14:00: the survey failed, a loss", g.over and r.winner_side == "nest" and r.said_ids.has("b_rains"))
	# the canoe goes without Valadares
	g = await _start()
	r = g.mission
	await _survey(g, r, "canoe run: ")
	r.choose("map", "drawn")
	_walk(g, g.clock + 4.0)
	_step(g, float(r.clocks["canoe"]) + 0.5)
	check("the canoe gone without Valadares: a loss", g.over and r.winner_side == "nest" and r.obj["flee"] == "failed")


# ================================================================== the nest (the solo side pick)

func _nest_play() -> void:
	_progress(CANON)
	var g := await _start("nest")
	var r: MissionRun = g.mission
	var nt := r.team_index("nest")
	var pt := r.team_index("party")
	check("nest: you lead the green team", g.human == nt and r.solo_side == "nest")
	_step(g, 0.5)
	_step(g, 1.5)
	check("nest: its objectives, the hunt still hidden", r.obj["n_mother"] == "active" and r.obj["n_sleep"] == "active" and r.obj["n_hunt"] == "hidden")
	check("nest: no lines (no creature speaks), no party lines shown", not r.said_ids.has("v_1"))
	check("nest: your hunters asleep, the workers awake", r.tagged("nest_guard").all(func(u): return u.has_meta("mission_asleep"))
		and g.units.filter(func(u): return not u.dead and u.team == nt and u.kind in ["grub", "brood_mother", "rootmaw"]).all(func(u): return not u.has_meta("mission_asleep")))
	check("nest: the Mother not spared (yours to lose)", not r.tagged("nest_mother")[0].spared)
	check("nest: no patrols (the scripted ones are the party's game)", r.tagged("patrol_w").is_empty())
	check("nest: no Tyrannosaur of your own (the Sire is coming)", r.denied(nt, "tyrannosaur"))
	# a new hunter sleeps too
	var nu: Unit = g._add_unit("raptor", nt, r.area_rect("nest_core").get_center())
	_step(g, 2.0)
	check("nest: a new hunter falls asleep with the rest", nu.has_meta("mission_asleep") and nu.m_pace == 0.0)
	var gr: Unit = g._add_unit("grub", nt, r.area_rect("nest_core").get_center())
	_step(g, 2.25)
	check("nest: a new grub stays awake", not gr.has_meta("mission_asleep"))
	_step(g, 3.5)
	check("nest: the party climbs by itself (a route)", r._routes.any(func(rt): return String(rt["name"]) == "leg1"))
	# the scripted party: round the marks (moved there for the test) and the survey done
	for mk in ["cairn", "source", "rim", "lookout"]:
		_put(g, r.tagged("valadares"), r.area_rect(mk))
		_walk(g, g.clock + 41.0)
	check("nest: the party took its four marks", int(r.counters["marks"]) == 4)
	_walk(g, g.clock + 5.0)
	check("nest: the party's map drawn at once (nobody answers it)", r.flags.get("map", "") == "drawn")
	check("nest: PART 3: the Sire is home (yours), the nest awake, the hunt", r.fired.has("part3") and r.tagged("sire").size() == 1 and r.tagged("sire")[0].team == nt
		and r.obj["n_hunt"] == "active" and nu.m_pace > 0.0 and not nu.has_meta("mission_asleep"))
	_step(g, g.clock + 2.0)
	check("nest: the party ended at the lookout (east): the Sire comes up the split, the party goes back west by the stair",
		r.flags.get("sire_way", "") == "split" and r._routes.any(func(rt): return String(rt["name"]) == "down" and (rt["pts"] as Array).has("stair_top")))
	# half of them killed: under half left
	var ppl := _people(g, r).filter(func(u): return not r.tagged("valadares").has(u))
	for i in 4:
		ppl[i].die()
	_step(g, g.clock + 1.5)
	check("nest: THE PARTY UNDER HALF: the nest wins", g.over and r.winner_side == "nest" and r.obj["n_hunt"] == "done", str(r.counters))
	await create_timer(1.8).timeout
	var p := Campaign.progress()
	check("nest: it counts for the nest's player, on the nest's side", (p["done"] as Dictionary).has(MID) and String(p["done"][MID]["side"]) == "nest"
		and Campaign.flag(MID, "plateau") == "kept")
	# Valadares killed wins too
	_progress(CANON)
	g = await _start("nest")
	r = g.mission
	_step(g, 2.0)
	_kill(r, "valadares")
	_step(g, 3.0)
	check("nest: Valadares killed wins too", g.over and r.winner_side == "nest")
	await create_timer(1.8).timeout
	# he gets down: the nest loses
	_progress(CANON)
	g = await _start("nest")
	r = g.mission
	_step(g, 2.0)
	for mk in ["cairn", "source", "rim", "lookout"]:
		_put(g, r.tagged("valadares"), r.area_rect(mk))
		_walk(g, g.clock + 41.0)
	_walk(g, g.clock + 6.0)
	_put(g, _people(g, r).filter(func(u): return not r.tagged("valadares").has(u)), r.area_rect("landing"))
	_step(g, g.clock + 0.5)
	_put(g, r.tagged("valadares"), r.area_rect("landing"))
	_walk(g, g.clock + 3.0)
	check("nest: the party down whole: the hunt failed", r.fired.has("the_end") and r.obj["n_hunt"] == "failed")
	_walk(g, g.clock + 6.0)
	check("nest: ...the party wins", g.over and r.winner_side == "party")
	check("nest: a loss does not count", not (Campaign.progress()["done"] as Dictionary).has(MID))


# ================================================================== the difficulty

func _difficulty() -> void:
	for d in [["easy", 5, 2, 1050.0, 337.5], ["hard", 7, 2, 756.0, 243.0]]:
		_progress(CANON, d[0])
		var g := await _start()
		var r: MissionRun = g.mission
		var nt := r.team_index("nest")
		_step(g, 1.0)
		check("%s: the nest's Raptors scaled (%d)" % [d[0], d[1]], _n(g, nt, "raptor") == int(d[1]), str(_n(g, nt, "raptor")))
		check("%s: the party never scaled (4 men)" % d[0], r.tagged("men").size() == 4)
		check("%s: the rains' countdown %s" % [d[0], d[3]], is_equal_approx(float(r.clocks["rains"]) - float(r.fired["start"]), float(d[3])), str(r.clocks["rains"]))
		await _survey(g, r, "%s: " % d[0])
		r.choose("map", "drawn")
		_walk(g, g.clock + 4.0)
		check("%s: the canoe's countdown %s" % [d[0], d[4]], is_equal_approx(float(r.clocks["canoe"]) - float(r.fired["part3_party"]), float(d[4])))
		g = await _start("nest")
		r = g.mission
		_step(g, 1.0)
		check("%s, as the nest: your own hunters never scaled (6 Raptors)" % d[0], _n(g, r.team_index("nest"), "raptor") == 6)
		check("%s, as the nest: the party's men scaled" % d[0], r.tagged("men").size() == (3 if d[0] == "easy" else 5), str(r.tagged("men").size()))
	Campaign.set_difficulty("normal")


# ================================================================== the hub

func _hub() -> void:
	main._to_menu()
	await process_frame
	var sl := Campaign.storyline_of(MID)
	var hub: Dictionary = sl["hub"]
	var after := CampaignMenu.hub_now(hub, {"done": {B01: {"side": "sire"}, MID: {"side": "party", "flags": {"map": "drawn"}}}})
	check("hub after a03: the warehouse at the Barra", String(after["title"]) == "The Warehouse at the Barra")
	var lq: Dictionary = hub["talks"]["lindqvist"]
	check("Lindqvist after a03: the report", String(CampaignMenu.talk_lines(lq, {"done": {B01: {}, MID: {"side": "party", "flags": {"map": "drawn"}}}})[0]).contains("report"))
	check("Lindqvist after a03 withheld: Benedito remembers", String(CampaignMenu.talk_lines(lq, {"done": {B01: {}, MID: {"side": "party", "flags": {"map": "withheld"}}}})[0]).contains("Benedito"))
	check("Lindqvist after a03 won by the nest: Valadares never came down", String(CampaignMenu.talk_lines(lq, {"done": {B01: {}, MID: {"side": "nest", "flags": {}}}})[0]).contains("never came down"))
