extends SceneTree
## Act 1's "The Fürth Line" (docs/campaign_a02_build.md):
##   - the data checks out, every text has pt and es, the Clockmaker line lists it after c01 and c01's guild win leads to
##     it, the seats for solo (either side), co-op and versus, the map and the stills load;
##   - THE PROLOGUE'S FLAGS at the start, each value that changes it (c01_thirteenth: bells rung / quiet, saved few / some
##     / many, jakob alive / lost, cut yes / no, gate pattern / people) and none at all (c01's defaults);
##   - THE GUILD played through: the stop-work (a STAY), the Light Works, the three sorties (on one bank or both by `cut`),
##     the signal (saved many), the mill, the win, the flags kept; the two defeats (Hollweg killed, the Honest One down);
##   - THE MACHINE (the solo side pick): its army, its income, the scripted guild, the mill seed, the win (the Honest One
##     burnt) and the loss (the line finished);
##   - THE DIFFICULTY: the sorties' numbers on EASY and HARD, the machine's raced clock;
##   - THE HUB: Fürth for the guild, the Machine's City for a machine player.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_a02.gd
## Prints CHECK lines, then "campaign_a02: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "a02_furth"
const C01 := "c01_thirteenth"
const DEFAULTS := {"bells": "quiet", "saved": "some", "jakob": "alive", "cut": "no", "gate": "pattern"}
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
	print("campaign_a02: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if c01 was won by the guild with these flags ({} none: c01 not in the progress at all), at a difficulty.
func _progress(flags: Variant, diff := "normal") -> void:
	var p := {"reached": [MID], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if flags is Dictionary:
		var f: Dictionary = DEFAULTS.duplicate()
		f.merge(flags, true)
		p["done"][C01] = {"won_by": "guild", "side": "guild", "flags": f}
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


func _put(g: Game, us: Array, at: Rect2) -> void:
	var i := 0
	for u in us:
		u.position = at.get_center() + Vector2((i % 4) * 14 - 21, (i / 4) * 14 - 14)
		u.velocity = Vector2.ZERO
		i += 1
	g._rebuild_hash()


func _n(g: Game, t: int, kind: String) -> int:
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind == kind).size()


func _run() -> void:
	await process_frame
	_data()
	await _flags()
	await _guild_play()
	await _defeats()
	await _machine_play()
	await _difficulty()
	await _hub()
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("a02_furth: data checks out", pr.is_empty(), "; ".join(pr))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings():
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Clockmaker line: c01, then a02", String(sl.get("id", "")) == "clockmaker" and (sl["missions"] as Array).slice(0, 2) == [C01, MID])
	check("c01 won by the guild leads to a02", Campaign.next_of(C01, "guild") == MID and Campaign.next_of(C01, "machine") == "")
	check("a02 won by the guild leads to a04 (a machine win nowhere)", Campaign.next_of(MID, "guild") == "a04_visit" and Campaign.next_of(MID, "machine") == "")
	Campaign.save_progress({"reached": [], "done": {"p01_leaf": {}}})
	check("a02 is locked before c01", not Campaign.unlocked(MID))
	Campaign.record(C01, "solo", "guild", "guild", DEFAULTS)
	check("...and open once c01 is won", Campaign.unlocked(MID))
	check("the record keeps the side the player led", String((Campaign.progress()["done"][C01] as Dictionary).get("side", "")) == "guild")
	check("solo sides: the guild (default) and the machine", Campaign.solo_sides(m) == ["guild", "machine"])
	var c := Campaign.make_cfg(MID, "solo")
	check("solo as the guild: you; the army, the town and the machine scripted", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "script"])
	c = Campaign.make_cfg(MID, "solo", "p1", false, "machine")
	check("solo as the machine: you are red; the guild scripted", c["slots"].map(func(s): return s["who"]) == ["script", "script", "script", "you"]
		and String(c["campaign"]["side"]) == "machine")
	c = Campaign.make_cfg(MID, "coop", "p1", true)
	check("co-op online: the friend is the Franconian army", c["slots"].map(func(s): return s["who"]) == ["you", "remote", "script", "script"])
	c = Campaign.make_cfg(MID, "versus", "p1", true)
	check("versus online: the friend is the machine", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "remote"])
	check("the guild BLUE, the army PURPLE, the machine RED", int(c["slots"][0]["colour"]) == 0 and int(c["slots"][1]["colour"]) == 4 and int(c["slots"][3]["colour"]) == 1)
	var md := Campaign.map_data("furth_line")
	check("the map is the Fürth map, in snow, 128 x 80", String(m["map"]) == "campaign:furth_line" and String(md.get("biome", "")) == "snow"
		and (md.get("size", []) as Array).map(func(x): return int(x)) == [128, 80])
	for k in m["stills"]:
		check("still %s: its picture loads" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	check("the opening and the ending per side", (m["opening"] as Dictionary).has("guild") and (m["opening"] as Dictionary).has("machine")
		and (m["ending"] as Dictionary).has("guild") and (m["ending"] as Dictionary).has("machine"))
	check("no narrator on the machine side: its lines are the machine's or the King's", (m["opening"]["machine"] as Array).all(func(pg): return (pg["lines"] as Array).all(
		func(l): return String(m["lines"][l]["who"]) in ["king", "machine"])))


# ================================================================== the prologue's flags at the start

func _flags() -> void:
	# ---- c01's defaults (quiet, some, Jakob alive, links not cut, the pattern): written out, and none at all
	for which in ["defaults", "none"]:
		_progress(DEFAULTS if which == "defaults" else null)
		var g := await _start()
		var r: MissionRun = g.mission
		var gt := r.team_index("guild")
		var at := r.team_index("army")
		_step(g, 1.0)
		var P := "flags %s: " % which
		check(P + "the Honest One is the guild's Clocktower", r.tagged("honest").size() == 1 and r.tagged("honest")[0].kind == "clocktower" and r.tagged("honest")[0].team == gt)
		check(P + "Hollweg and Jakob at Fürth", r.tagged("hollweg").size() == 1 and r.tagged("jakob").size() == 1)
		check(P + "quiet bells: the commissary, 10 musketeers, no guns", r.tagged("commissary").size() == 1 and _n(g, at, "musketeer") == 10 and _n(g, at, "cannon") == 0,
			"%d musketeers" % _n(g, at, "musketeer"))
		check(P + "quiet bells: no Light Works until the stop-work", g.requirement_text(gt, "movement_works") == "The commissary forbids it until the stop-work is fitted.")      # (the deny's own words: playtest-campaign-clock)
		check(P + "quiet bells: no extra cogs", int(g.players[gt]["gold"]) == 400)
		check(P + "some saved: two cottages and four diggers", r.tagged("cottages").size() == 2 and r.tagged("diggers").size() == 4)
		check(P + "the pattern: no Heavy Works yet (Part 3)", r.denied(gt, "heavy_works") and r.denied(gt, "pendulum"))
		check(P + "Jakob's objective shown", r.obj["jakob"] == "active")
		check(P + "the seeds by Nuremberg's gates are spared", r.tagged("seed_n")[0].spared and r.tagged("seed_s")[0].spared)
		check(P + "the earthworks round the gates dug, the gates set", r.tagged("earthworks").filter(func(b): return b.kind == "gate").size() == 4
			and r.tagged("earthworks").size() >= 20)
		check(P + "the guild's own defence is NOT there (a person leads the guild)", r.tagged("g_def").is_empty() and r.tagged("g_works").is_empty())
		check(P + "the machine's own army is NOT there (scripted: a garrison)", r.tagged("m_start").is_empty() and r.tagged("gate_guard").size() == 8)
	# ---- the bells rung
	_progress({"bells": "rung"})
	var g := await _start()
	var r: MissionRun = g.mission
	var gt := r.team_index("guild")
	var at := r.team_index("army")
	_step(g, 1.0)
	check("bells rung: a bigger army, two Field Cannons, no commissary", _n(g, at, "musketeer") == 16 and _n(g, at, "cannon") == 2 and r.tagged("commissary").is_empty(),
		"%d musketeers, %d guns" % [_n(g, at, "musketeer"), _n(g, at, "cannon")])
	check("bells rung: the Light Works at once, 200 cogs more", g.requirement_text(gt, "movement_works") == "" and int(g.players[gt]["gold"]) == 600)
	check("bells rung: the colonel says so", r.said_ids.has("col_1") and not r.said_ids.has("com_1"))
	_step(g, 16.0)
	check("bells rung: ...and thanks the guild", r.said_ids.has("col_rung"))
	# ---- saved few / many
	_progress({"saved": "few"})
	g = await _start()
	r = g.mission
	_step(g, 1.0)
	check("few saved: no cottages, no diggers", r.tagged("cottages").is_empty() and r.tagged("diggers").is_empty())
	_progress({"saved": "many"})
	g = await _start()
	r = g.mission
	_step(g, 1.0)
	check("many saved: four cottages and eight diggers", r.tagged("cottages").size() == 4 and r.tagged("diggers").size() == 8)
	# ---- Jakob lost
	_progress({"jakob": "lost"})
	g = await _start()
	r = g.mission
	_step(g, 1.0)
	check("Jakob lost: he is not at Fürth, his objective hidden", r.tagged("jakob").is_empty() and r.obj["jakob"] == "hidden")


# ================================================================== the guild, played through

## Through the three parts: stop-work, works, the sorties, the mill. `flags`: c01's that matter for the run.
func _through(g: Game, r: MissionRun, P: String, many := false, cut := false) -> void:
	var gt := r.team_index("guild")
	var mt := r.team_index("machine")
	_step(g, 2.0)
	check(P + "the intro and the part's objectives", r.said_ids.has("h_1") and r.obj["stopwork"] == "active" and r.obj["works"] == "active"
		and r.obj["hollweg"] == "active" and r.obj["honest"] == "active")
	_put(g, r.tagged("hollweg"), r.area_rect("honest_ring"))
	_walk(g, 20.0)
	check(P + "the stop-work: not yet after 18 s", r.obj["stopwork"] == "active")
	_walk(g, 29.0)
	check(P + "THE STOP-WORK fitted after 25 s by the tower", r.obj["stopwork"] == "done" and r.said_ids.has("h_stop") and r.flags.get("stopwork", "") == "fitted")
	check(P + "the Light Works is allowed now", g.requirement_text(gt, "movement_works") == "")
	_step(g, 40.0)
	check(P + "a Light Works being built does not count yet", not r.fired.has("works_up"))
	r._place_building({"team": "guild", "kind": "movement_works", "at": [44, 22]})
	_step(g, 41.0)
	check(P + "a Light Works standing: done", r.obj["works"] == "done")
	_step(g, 51.0)
	check(P + "the army digs the north bank's earthworks", r.fired.has("dig_1") and r.tagged("earthworks").size() >= 40)
	_step(g, 57.0)
	check(P + "PART 2: the sortie's objective, the stop-work's gone", r.fired.has("part2") and r.obj["hold"] == "active" and r.obj["stopwork"] == "hidden")
	var wave1 := float(r.clocks["sortie"])
	_step(g, wave1 - 21.0)
	_step(g, wave1 - 19.0)
	check(P + ("the loyal quarter's signal (many saved)" if many else "no signal (not many saved)"), r.fired.has("signal") == many)
	_step(g, wave1 - 11.0)
	check(P + "Jakob hears the first sortie coming", r.said_ids.has("j_tick_s"))
	_step(g, wave1 + 0.1)
	check(P + "SORTIE 1 out of the south gate", r.fired.has("wave_1") and r.tagged("sortie1").size() == 6
		and r.tagged("sortie1").all(func(u): return u.team == mt and u.position.y > 40 * Defs.TILE), str(r.tagged("sortie1").size()))
	check(P + "the earthworks on the south bank dug", r.fired.has("dig_2"))
	_kill(r, "sortie1")
	_step(g, wave1 + 30.0)
	check(P + "sortie 1 beaten back: 1 of 3", int(r.counters["sorties"]) == 1 and r.objective_text(r.objective("hold")).begins_with("Hold the earthworks: 1 of 3"))
	var w2 := float(r.clocks["sortie2"])
	_step(g, w2 + 0.1)
	var s2: Array = r.tagged("sortie2")
	if cut:
		check(P + "SORTIE 2: the links were cut, so the meadows again", r.fired.has("wave_2c") and not r.fired.has("wave_2") and s2.all(func(u): return u.position.y > 40 * Defs.TILE))
	else:
		check(P + "SORTIE 2: on the north road", r.fired.has("wave_2") and not r.fired.has("wave_2c") and s2.size() == 8 and s2.all(func(u): return u.position.y < 30 * Defs.TILE))
	_kill(r, "sortie2")
	_step(g, w2 + 10.0)
	check(P + "sortie 2 beaten back", int(r.counters["sorties"]) == 2)
	var w3 := float(r.clocks["sortie3"])
	_step(g, w3 + 0.1)
	if cut:
		check(P + "SORTIE 3: all of it on the meadows", r.fired.has("wave_3c") and r.tagged("sortie3").size() == 10 and r.tagged("sortie3n").is_empty())
	else:
		check(P + "SORTIE 3: on both banks", r.fired.has("wave_3") and r.tagged("sortie3").size() == 6 and r.tagged("sortie3n").size() == 5)
	_kill(r, "sortie3")
	_step(g, w3 + 5.0)
	check(P + "half of sortie 3 is not the whole of it", cut or not r.fired.has("beat_3"))
	_kill(r, "sortie3n")
	_step(g, w3 + 6.0)
	check(P + "sortie 3 beaten back: 3 of 3", int(r.counters["sorties"]) == 3)
	_step(g, w3 + 12.5)
	check(P + "PART 3: the hold is done, the mill seeded (red), its objective", r.fired.has("part3") and r.obj["hold"] == "done" and r.obj["mill"] == "active"
		and r.tagged("seed_mill").size() == 1 and r.tagged("seed_mill")[0].team == mt and not r.tagged("seed_mill")[0].spared)
	check(P + "the colonel's reserve", r.tagged("reserve").size() == 4)
	check(P + "the mill seed is half grown (about half its health)", r.tagged("seed_mill")[0].hp < r.tagged("seed_mill")[0].max_hp * 0.6)


func _guild_play() -> void:
	# ---- run A: c01's defaults (the pattern: the Heavy Works opens in Part 3)
	_progress(DEFAULTS)
	var g := await _start()
	var r: MissionRun = g.mission
	var gt := r.team_index("guild")
	var P := "guild A (defaults): "
	await _through(g, r, P)
	_step(g, g.clock + 9.0)
	check(P + "the pattern: the Heavy Works and the Pendulum open", not r.denied(gt, "heavy_works") and not r.denied(gt, "pendulum") and r.said_ids.has("h_pattern"))
	var t3 := g.clock
	_step(g, t3 + 40.0)
	check(P + "the mill seed grows while it stands", not r.tagged("mach_mill_grow").is_empty())
	_kill(r, "seed_mill")
	_step(g, t3 + 41.0)
	check(P + "the mill burnt: the lines, the flags", r.fired.has("mill_burnt") and r.said_ids.has("h_safe") and r.flags.has("furth") and r.flags.get("jakob", "") == "alive")
	_step(g, t3 + 52.0)
	check(P + "THE LINE HOLDS: the guild wins", g.over and r.winner_side == "guild")
	var army := int(r.counters["army"])
	check(P + "the army's strength counted into `furth`", r.flags["furth"] == ("strong" if army >= 10 else "thin"), "%d men: %s" % [army, r.flags["furth"]])
	await create_timer(1.8).timeout
	var show: StillShow = null
	for n in main.ui_layer.get_children():
		if n is StillShow:
			show = n
	check(P + "the guild's ending plays", show != null)
	if show:
		for i in 20:
			if is_instance_valid(show) and not show.is_queued_for_deletion():
				show.next()
		check(P + "the ending's lines by the flags", show.shown_ids == ["h_end1", "h_end_" + String(r.flags["furth"]), "h_end_jakob", "h_end2", "k_end1", "k_end2"], str(show.shown_ids))
	var p := Campaign.progress()
	check(P + "it counts: done, by the guild, the flags kept", (p["done"] as Dictionary).has(MID) and String(p["done"][MID]["side"]) == "guild"
		and Campaign.flag(MID, "furth") in ["strong", "thin"])
	# ---- run B: rung, many saved, the links cut, the people (no drawings), Jakob lost
	_progress({"bells": "rung", "saved": "many", "cut": "yes", "gate": "people", "jakob": "lost"})
	g = await _start()
	r = g.mission
	gt = r.team_index("guild")
	P = "guild B (rung, many, cut, people, no Jakob): "
	# (Jakob lost: no warnings; the test's _through looks for one, so give him back for the walk-through's lines only)
	await _through_b(g, r, P)
	_step(g, g.clock + 9.0)
	check(P + "the people: no Heavy Works, four more Winders instead", r.denied(gt, "heavy_works") and r.tagged("people_hands").size() == 4 and r.said_ids.has("h_people"))
	var p3 := float(r.fired.get("part3", g.clock))
	_step(g, p3 + 300.0)
	check(P + "the mill left standing: no tide at 5:00", r.tagged("tide").is_empty())
	_step(g, p3 + 361.0)
	check(P + "...a tide with a Pendulum at 6:00", r.tagged("tide").filter(func(u): return u.kind == "pendulum").size() == 1 and r.said_ids.has("col_tide"))
	_kill(r, "seed_mill")
	_step(g, g.clock + 1.0)
	_step(g, g.clock + 11.0)
	check(P + "the line holds; Jakob is not with the guild (flag)", g.over and r.winner_side == "guild" and r.flags.get("jakob", "") == "lost")


## Run B's walk-through (no Jakob: no warnings, and the sorties by the cut links).
func _through_b(g: Game, r: MissionRun, P: String) -> void:
	var mt := r.team_index("machine")
	_step(g, 2.0)
	check(P + "no Jakob, no commissary; the colonel's thanks", r.tagged("jakob").is_empty() and r.tagged("commissary").is_empty())
	_put(g, r.tagged("hollweg"), r.area_rect("honest_ring"))
	r._place_building({"team": "guild", "kind": "movement_works", "at": [44, 22]})
	_walk(g, 30.0)
	check(P + "the stop-work and the works", r.obj["stopwork"] == "done" and r.obj["works"] == "done")
	_step(g, 46.0)
	check(P + "part 2", r.fired.has("part2"))
	var w1 := float(r.clocks["sortie"])
	_step(g, w1 - 19.0)
	check(P + "the loyal quarter's signal: the gates revealed", r.fired.has("signal") and r.said_ids.has("n_signal"))
	_step(g, w1 - 10.0)
	check(P + "no Jakob, no ticking", not r.said_ids.has("j_tick_s"))
	_step(g, w1 + 0.1)
	_kill(r, "sortie1")
	_step(g, w1 + 1.0)
	var w2 := float(r.clocks["sortie2"])
	_step(g, w2 + 0.1)
	check(P + "the links cut: sortie 2 on the meadows", r.fired.has("wave_2c") and r.tagged("sortie2").all(func(u): return u.team == mt and u.position.y > 40 * Defs.TILE))
	_kill(r, "sortie2")
	_step(g, w2 + 1.0)
	var w3 := float(r.clocks["sortie3"])
	_step(g, w3 + 0.1)
	check(P + "sortie 3 all on the meadows", r.fired.has("wave_3c") and r.tagged("sortie3n").is_empty())
	_kill(r, "sortie3")
	_step(g, w3 + 1.0)
	_step(g, w3 + 7.5)
	check(P + "part 3", r.fired.has("part3") and r.tagged("seed_mill").size() == 1)


func _defeats() -> void:
	_progress(DEFAULTS)
	var g := await _start()
	var r: MissionRun = g.mission
	_step(g, 30.0)
	_kill(r, "hollweg")
	_step(g, 31.0)
	check("Hollweg killed: the guild loses", g.over and r.winner_side == "machine" and r.obj["hollweg"] == "failed")
	check("...and it does not count", not (Campaign.progress()["done"] as Dictionary).has(MID))
	g = await _start()
	r = g.mission
	_step(g, 30.0)
	_kill(r, "honest")
	_step(g, 31.0)
	check("the Honest One burnt: the guild loses", g.over and r.winner_side == "machine" and r.obj["honest"] == "failed")
	# a passive guild: Part 2 comes at 7:00 whatever happened
	g = await _start()
	r = g.mission
	_step(g, 300.0)
	check("a passive guild: no Part 2 at 5:00", not r.fired.has("part2"))
	_step(g, 421.0)
	_step(g, 436.5)
	check("...Part 2 at 7:00 anyway", r.fired.has("part2"))


# ================================================================== the machine (the solo side pick)

func _machine_play() -> void:
	_progress(DEFAULTS)
	var g := await _start("machine")
	var r: MissionRun = g.mission
	var gt := r.team_index("guild")
	var mt := r.team_index("machine")
	check("machine: you lead the red team", g.human == mt and r.solo_side == "machine")
	_step(g, 1.0)
	_step(g, 1.5)
	check("machine: your army by the gates, a Light Works", r.tagged("m_start").size() == 12 and r.tagged("m_works").size() == 1 and r.tagged("m_works")[0].team == mt)
	check("machine: no garrison on hold (they are yours)", r.tagged("gate_guard").is_empty())
	check("machine: cogs and Tension to start", int(g.players[mt]["gold"]) == 500 and g.tension(mt) >= 200.0)
	check("machine: the line's countdown (18:00)", r.clocks.has("line") and is_equal_approx(float(r.clocks["line"]) - 1.0, 1080.0), str(r.clocks))
	check("machine: its objectives, not the guild's", r.objectives_for("machine").map(func(o): return o["id"]) == ["m_line", "m_break"])
	check("machine: its own lines (no narrator: the machine)", r.said_ids.has("m_intro") and not r.said_ids.has("h_1"))
	check("machine: no Presses or Mainspring (the seeds are its income)", r.denied(mt, "cog_press") and r.denied(mt, "mainspring"))
	# (campaign-fixes-1121: on NORMAL 4 more Clock Soldiers and a Pendulum in the guild's own defence)
	check("machine: the guild defends itself (scripted, a Light Works up)", r.tagged("g_def").size() == 23 and r.tagged("g_works").size() == 1, str(r.tagged("g_def").size()))
	_step(g, 30.0)
	check("machine: the seeds' timetable pays", int(g.players[mt]["gold"]) == 700)
	_step(g, 60.0)
	check("machine: no free construct before 2:00", r.tagged("m_free").is_empty())
	_step(g, 120.0)
	check("machine: a construct out of each gate", r.tagged("m_free").size() == 2 and r.tagged("m_free").all(func(u): return u.team == mt))
	_step(g, 121.0)
	check("machine: the guild trains (scripted)", r.tagged("g_more").size() == 2)
	_step(g, 361.0)
	check("machine: the seed at the Rednitz mill at 6:00", r.tagged("seed_mill").size() == 1 and r.tagged("seed_mill")[0].team == mt and r.obj["m_mill"] == "active")
	_step(g, 430.0)
	check("machine: no sorties for a person's machine (no Part 2)", not r.fired.has("part2") and r.tagged("sortie1").is_empty())
	_step(g, 601.0)
	check("machine: the guild strikes at the mill at 10:00", r.tagged("g_strike").size() == 8)
	_kill(r, "honest")
	_step(g, 602.0)
	check("machine: THE HONEST ONE BURNT: the machine wins", g.over and r.winner_side == "machine" and r.obj["m_break"] == "done")
	check("machine: the flag furth fallen", r.flags.get("furth", "") == "fallen")
	await create_timer(1.8).timeout
	var show: StillShow = null
	for n in main.ui_layer.get_children():
		if n is StillShow:
			show = n
	if show:
		for i in 10:
			if is_instance_valid(show) and not show.is_queued_for_deletion():
				show.next()
		check("machine: its ending is the King's (that is not how it went)", show.shown_ids == ["k_end_m1", "k_end_m2"], str(show.shown_ids))
	else:
		check("machine: its ending plays", false)
	var p := Campaign.progress()
	check("machine: it counts for the machine's player, on the machine's side", (p["done"] as Dictionary).has(MID) and String(p["done"][MID]["side"]) == "machine")
	# ---- Hollweg killed also wins; the clock out loses
	_progress(DEFAULTS)
	g = await _start("machine")
	r = g.mission
	_step(g, 2.0)
	_kill(r, "hollweg")
	_step(g, 3.0)
	check("machine: Hollweg killed wins too", g.over and r.winner_side == "machine")
	_progress(DEFAULTS)
	g = await _start("machine")
	r = g.mission
	_step(g, 2.0)
	_step(g, float(r.clocks["line"]) - 100.0)
	check("machine: two minutes' warning", r.said_ids.has("m_warn"))
	_step(g, float(r.clocks["line"]) + 0.1)
	check("machine: THE LINE FINISHED: the machine loses", g.over and r.winner_side == "guild" and r.obj["m_break"] == "failed")
	check("machine: a loss does not count", not (Campaign.progress()["done"] as Dictionary).has(MID))


# ================================================================== the difficulty

func _difficulty() -> void:
	for d in [["easy", 4, 1350.0], ["hard", 6, 972.0]]:
		_progress(DEFAULTS, d[0])
		var g := await _start()
		var r: MissionRun = g.mission
		_put(g, r.tagged("hollweg"), r.area_rect("honest_ring"))
		r._place_building({"team": "guild", "kind": "movement_works", "at": [44, 22]})
		_walk(g, 30.0)
		_step(g, 46.0)
		_step(g, float(r.clocks["sortie"]) + 0.1)
		var n := r.tagged("sortie1").filter(func(u): return u.kind == "clock_soldier").size()
		check("%s: sortie 1's Clock Soldiers scaled (%d)" % [d[0], d[1]], n == int(d[1]), str(n))
		check("%s: the Franconian army is the player's side: never scaled" % d[0], _n(g, r.team_index("army"), "musketeer") == 10)
		g = await _start("machine")
		r = g.mission
		_step(g, 1.0)
		_step(g, 1.5)
		check("%s, as the machine: the line's countdown %s" % [d[0], d[2]], is_equal_approx(float(r.clocks["line"]) - 1.0, float(d[2])), str(float(r.clocks["line"]) - 1.0))
		check("%s, as the machine: your own army never scaled" % d[0], r.tagged("m_start").size() == 12)
	Campaign.set_difficulty("normal")


# ================================================================== the hub

func _hub() -> void:
	main._to_menu()
	await process_frame
	var sl := Campaign.storyline_of(MID)
	var hub: Dictionary = sl["hub"]
	var furth := CampaignMenu.hub_now(hub, {"done": {C01: {"side": "guild"}}})
	check("hub after c01: the guild in exile at Fürth, Hollweg there", String(furth["title"]) == "The Guild in Exile at Fürth" and not (furth["hide_layers"] as Array).has("hollweg")
		and (furth["hotspots"] as Array).any(func(h): return h["id"] == "hollweg"))
	var held := CampaignMenu.hub_now(hub, {"done": {C01: {"side": "guild"}, MID: {"side": "guild"}}})
	check("hub after a02 won by the guild: still Fürth", String(held["title"]) == "The Guild in Exile at Fürth" and (held["hotspots"] as Array).any(func(h): return h["id"] == "hollweg"))
	check("Hollweg's talk after a02", String(CampaignMenu.talk_lines(hub["talks"]["hollweg"], {"done": {C01: {}, MID: {"side": "guild"}}})[0]).contains("The line held"))
	var mach := {"done": {C01: {"side": "guild"}, MID: {"side": "machine"}}}
	var city := CampaignMenu.hub_now(hub, mach)
	check("hub after a02 won as the Machine: the Machine's City, his letter", String(city["title"]) == "Nuremberg, the Machine's City"
		and (city["hide_layers"] as Array).has("hollweg") and (city["hotspots"] as Array).any(func(h): return h["id"] == "letter")
		and not (city["hotspots"] as Array).any(func(h): return h["id"] == "hollweg"))
	check("the automaton's talk in the Machine's City", String(CampaignMenu.talk_lines(hub["talks"]["automaton"], mach)[0]).contains("Something finished it"))
	check("the automaton's talk at Fürth", String(CampaignMenu.talk_lines(hub["talks"]["automaton"], {"done": {C01: {}}})[0]).contains("STOP-WORK"))
	# the page itself with c01 done: Fürth, Hollweg in the painting
	Campaign.save_progress({"reached": [MID], "done": {"p01_leaf": {}, C01: {"side": "guild"}}})
	CampaignMenu.line = "clockmaker"
	CampaignMenu.show(main)
	await process_frame
	await process_frame
	var hs: HubScene = main.find_child("HubScene", true, false).get_child(0) as HubScene if main.find_child("HubScene", true, false) else null
	check("the hub page at Fürth: Hollweg in the painting, no letter", hs != null and not hs.hidden_layers.has("hollweg")
		and main.find_child("HotspotList_letter", true, false) == null)
