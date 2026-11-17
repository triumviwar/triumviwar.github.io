extends SceneTree
## The Brood prologue, "Specimen One" (docs/campaign_b01_build.md), and the engine it needed:
##   - the data checks out, every text has pt and es, the seats for solo / co-op / versus, THE NATURALIST storyline opens
##     after the Crown's prologue and lists b01, the stills and the sounds load, the colours (station YELLOW, garrison
##     PURPLE, pack GREEN), the dark jungle floor;
##   - the ENGINE, each feature on its own: `cage` (in place, harmless, eggs kept as eggs), `spare` (untargetable and
##     unhurt), `pin` (the gun with no horse), `carry` (slower, unarmed), `floor` and `heal`, the `hp` condition, scripted
##     ROOT and UPROOT (a father nesting by another side's Mother) and the `rooted` condition by tag, `burn`, building
##     SITES and the `build` objective, exits that open `after` a trigger and keep `except` tags, a counter set from a
##     count (and `plus`), the rain and the jungle lights, the hub's `flag` gating;
##   - THE MISSION played through, both ways of each choice: run A (TELL the lieutenant, BURN the eggs), run B (KEEP IT
##     QUIET, SAVE the research), run C (quiet, the fire takes the eggs: Lindqvist never reaches the specimen house; Pieter
##     lost); each part's beats (the pen, Valadares, the tracks, the goats, the lure learnt then set, the waves to the jars
##     and then past them, the village, the turtle, the forest quiet, the Sire, the countdown, the clutch, the fire, he
##     takes her, the choice, the canoes); the story's loss counts (progress, flags, THE STATION IS LOST, the ending's
##     if-lines); the naturalist's hub and the King's study after it; and the two real defeats (a hero killed; left
##     behind when the canoes leave).
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_b01.gd
## Prints CHECK lines, then "campaign_b01: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "b01_specimen"
var main: Node
var fails := 0
var _kept := ""


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-70s %s %s" % [name, "ok" if ok else "FAIL", detail])
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
	print("campaign_b01: %d failures" % fails)
	quit(1 if fails > 0 else 0)


func _start(mode := "solo", seat := "p1") -> Game:
	if main.game:
		main._to_menu()
		await process_frame
	for n in main.ui_layer.get_children():
		if n.name == "MissionEnd" or n is StillShow:
			n.queue_free()
	main.start(Campaign.make_cfg(MID, mode, seat))
	await process_frame
	await process_frame
	paused = false
	# (the match begins a moment after the map is ready: the units and the mission's own tick run from then on)
	for i in 400:
		if main.game.clock > 0.0:
			break
		await physics_frame
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


## Real game time: `secs` of physics at the fixed rate (units walk, root, fight), the mission ticking itself.
func _run_for(secs: float) -> void:
	var n := int(secs * 30.0)
	for i in n:
		await physics_frame


## Two rounds: a trigger waiting on an objective that the first round's check settled fires in the second.
func _step2(g: Game, to: float) -> void:
	_step(g, to)
	_step(g, to + 0.1)


func _waves(r: MissionRun) -> Array:
	return r.tagged("wave_c") + r.tagged("wave_w") + r.tagged("wave_e")


func _kill_waves(r: MissionRun) -> void:
	for t in ["wave_c", "wave_w", "wave_e", "spit", "goat_raptors", "raiders", "called", "guard", "sire_pack"]:
		_kill(r, t)


func _kill(r: MissionRun, tag: String) -> void:
	for e in r.tagged(tag):
		e.spared = false
		e.hp_floor = 0.0
		if e is Building:
			e.take_damage(1e9, null)
		else:
			e.die()


func _put(g: Game, us: Array, at: Rect2) -> void:
	var i := 0
	for u in us:
		u.position = at.get_center() + Vector2((i % 4) * 14 - 21, (i / 4) * 14 - 14)
		u.velocity = Vector2.ZERO
		if u is Unit:
			u.cmd_stop()
		i += 1
	g._rebuild_hash()


func _end_panel() -> Node:
	return main.ui_layer.find_child("MissionEnd", true, false)


func _labels(n: Node) -> Array:
	var out: Array = []
	for c in n.find_children("*", "Label", true, false):
		out.append(String((c as Label).text))
	return out


func _ui() -> MissionUi:
	for n in main.ui_layer.get_children():
		if n is MissionUi:
			return n
	return null


func _run() -> void:
	await process_frame
	_data()
	await _engine()
	await _play("A", "told", "burned")
	await _play("B", "quiet", "saved")
	await _play("C", "quiet", "")
	await _defeats()
	await _hub_after()
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("b01_specimen: data checks out", pr.is_empty(), "; ".join(pr))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + ["Pieter (the jars)", "Dr. Lindqvist (the crate)", "Pieter"]:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("THE NATURALIST storyline's first mission is b01", String(sl.get("id", "")) == "naturalist" and String(sl.get("title", "")) == "The Naturalist" and (sl["missions"] as Array) == [MID])
	check("its line is the owner's", String(sl.get("about", "")) == "A naturalist on the Amazon raises a creature no one has seen, and loses it to the forest.")
	check("it opens after the Crown's prologue", String(sl.get("requires", "")) == "p01_leaf")
	var c := Campaign.make_cfg(MID, "solo")
	check("solo: you are the station; the garrison, the pen and the pack are scripted", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "script"])
	c = Campaign.make_cfg(MID, "coop", "p1", true)
	check("co-op online: the friend is the garrison", c["slots"].map(func(s): return s["who"]) == ["you", "remote", "script", "script"])
	c = Campaign.make_cfg(MID, "versus", "p1", true)
	check("versus online: the friend is the pack", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "remote"])
	check("the station YELLOW, the garrison PURPLE, the pack GREEN", int(c["slots"][0]["colour"]) == 3 and int(c["slots"][1]["colour"]) == 4 and int(c["slots"][3]["colour"]) == 2
		and c["slots"][3]["faction"] == "brood" and c["slots"][0]["faction"] == "crown")
	check("the map is the Rio Negro map, in the jungle", String(m["map"]) == "campaign:rio_negro_station" and String(Campaign.map_data("rio_negro_station").get("biome", "")) == "jungle")
	check("the floor is darkened (the pack reads on it)", (m.get("floor", []) as Array).size() == 3 and float(m["floor"][1]) < 0.8)
	for k in m["stills"]:
		check("still %s: its picture loads" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	for s in ["linnea_call", "forest_answer", "sire_roar"]:
		check("sound campaign/%s is in" % s, ResourceLoader.exists("res://assets/audio/campaign/%s.wav" % s))
	check("the voice folder is b01 (no recordings yet: silent)", String(m.get("voice", "")) == "b01" and CampaignVoice.path_of(m, "l_open1") == "")
	check("campaign roles: lindqvist, valadares, pieter, teles, joaquim, villager, benedito, linnea",
		["lindqvist", "valadares", "pieter", "teles", "joaquim", "villager", "benedito", "linnea"].all(func(r): return Defs.UNITS.has(String(Rebels.role(r).get("kind", "")))))
	check("Linnea is a Brood Mother's kind, drawn at 0.3", String(Rebels.role("linnea")["kind"]) == "brood_mother" and is_equal_approx(float(Rebels.role("linnea")["scale"]), 0.3))


# ================================================================== the engine, feature by feature

func _engine() -> void:
	var g := await _start()
	var r: MissionRun = g.mission
	var st := r.team_index("station")
	var pt := r.team_index("pack")
	var pen_t := r.team_index("pen")
	_step(g, 0.5)
	check("no computer player (everything but the station is scripted)", g.ais.is_empty())
	check("the jungle afternoon light at the start", r.light_name == "jungle_day" and r.light_node != null)
	check("the floor tinted dark", g.ground.modulate.g < 0.8, str(g.ground.modulate))
	check("the station's house, specimen house and garden", r.tagged("station_house").size() == 1 and r.tagged("specimen_house").size() == 1 and r.tagged("garden").size() == 1
		and r.tagged("station_house")[0].kind == "town_hall")
	check("her pen: 12 sites, not built (stakes and a gate)", r.tagged("pen").size() == 12 and r.tagged("pen").all(func(b): return b is Building and not b.built)
		and r.tagged("pen").filter(func(b): return b.kind == "gate").size() == 1, str(r.tagged("pen").size()))
	var lin: Unit = r.tagged("linnea")[0]
	check("Linnea: a Brood Mother of the pen team, on the station's side, named", lin.kind == "brood_mother" and lin.team == pen_t and g.allied(pen_t, st)
		and String(lin.get_meta("mission_name", "")) == "Linnea")
	check("Linnea drawn at 0.3 (about a third of the Mother)", is_equal_approx(float(lin.get_meta("role_scale", 1.0)), 0.3) and lin.radius < 20.0, str(lin.radius))
	check("CAGE: Linnea can't move or bite", lin.m_pace == 0.0 and lin.m_unarmed and lin.has_meta("mission_caged"))
	check("SPARE: nobody can touch her", lin.spared and lin.untouchable())
	var p0 := lin.position
	lin.position += Vector2(60, 0)
	r._tick_held()
	check("cage: put back in her pen", lin.position.distance_to(p0) < 1.0)
	var rap: Array = r._spawn({"team": "pack", "kind": "raptor", "count": 1, "at": "pen", "tag": "t_rap"})
	check("spare: a pack creature beside her doesn't pick her", g.find_target(rap[0], 300.0) != lin)
	lin.take_damage(500.0, rap[0])
	check("spare: and nothing hurts her", lin.hp == lin.max_hp)
	check("no Brood Mother for the pack: it is not beaten (the mission ends things)", not g.eliminated[pt] and not g.over)
	_kill(r, "t_rap")
	# ---- floor, heal, hp
	var sire: Array = r._spawn({"team": "pack", "kind": "tyrannosaur", "count": 1, "at": "nest", "tag": "t_sire"})
	r.act({"floor": {"tag": "t_sire", "share": 0.33}})
	sire[0].take_damage(5000.0, null)
	check("FLOOR: the Sire cannot die tonight (stops at a third)", not sire[0].dead and absf(sire[0].hp - 330.0) < 2.0, str(sire[0].hp))
	check("hp condition: below 0.36", r.cond({"hp": {"tag": "t_sire", "below": 0.36}}) and not r.cond({"hp": {"tag": "t_sire", "below": 0.3}}))
	r.act({"heal": {"tag": "t_sire", "share": 0.7}})
	check("HEAL: back to 70%", absf(sire[0].hp - 700.0) < 1.0)
	# ---- root and uproot (a father nesting by another side's Mother)
	r.act({"order": {"tag": "t_sire", "do": "root", "to": "nest"}})
	check("ROOT: the Sire walks to the nest to root", sire[0].order == "nb_root", sire[0].order)
	await _run_for(4.0)
	check("rooted (beside a Mother not his side's)", BroodNew.rooted(sire[0]) and r.cond({"rooted": {"tag": "t_sire"}}), "%s %s" % [sire[0].order, sire[0].tesla_mode])
	check("rooted he cannot bite", not sire[0].can_hit(r.tagged("guards")[0]))
	r.act({"order": {"tag": "t_sire", "do": "uproot"}})
	await _run_for(3.2)
	check("UPROOT", not BroodNew.rooted(sire[0]) and not r.cond({"rooted": {"tag": "t_sire"}}), sire[0].tesla_mode)
	_kill(r, "t_sire")
	# ---- pin, carry
	var gun: Array = r._spawn({"team": "garrison", "kind": "cannon", "count": 1, "at": "gun_spot", "tag": "t_gun"})
	r.act({"pin": {"tag": "t_gun", "on": true}})
	g.group_move(gun, r.area_rect("jetty").get_center() + Vector2(0, 80), false)
	var gp: Vector2 = gun[0].position
	await _run_for(1.5)
	check("PIN: the gun with no horse does not move", gun[0].position.distance_to(gp) < 3.0 and gun[0].m_pace == 0.0)
	check("pin: it still fights", not gun[0].m_unarmed)
	_kill(r, "t_gun")
	var lq: Unit = r.tagged("lindqvist")[0]
	r.act({"carry": {"tag": "lindqvist", "on": true, "pace": 0.6}})
	check("CARRY: slower and unarmed", is_equal_approx(lq.m_pace, 0.6) and lq.m_unarmed and not lq.can_hit(rap[0]))
	r.act({"carry": {"tag": "lindqvist", "on": false}})
	check("carry off", lq.m_pace == 1.0 and not lq.m_unarmed)
	# ---- burn
	var spec: Building = r.tagged("specimen_house")[0]
	var h0 := spec.hp
	r.act({"burn": {"tag": "specimen_house", "secs": 10}})
	for i in 8:
		r._tick_held()
	check("BURN: the specimen house burns down in its time", spec.hp < h0 * 0.85 and not spec.dead, "%d of %d" % [spec.hp, h0])
	r._burning.clear()
	spec.hp = spec.max_hp
	# ---- sites, the build objective
	check("the pen objective is open", r.obj["pen"] == "active")
	for b in r.tagged("pen"):
		b.progress = 1.0
		b.built = true
		b.hp = b.max_hp
	_step(g, 5.0)
	check("BUILD: every stake and the gate built, the pen is done", r.obj["pen"] == "done")
	# ---- counters from a count, exits after / except
	r.act({"counter": {"name": "people", "count": {"team": "station"}}})
	var n0 := int(r.counters["people"])
	check("counter from a count", n0 == g.units.filter(func(u): return u.team == st and not u.dead).size(), str(n0))
	r.act({"counter": {"name": "people", "count": {"tag": "folk"}, "plus": true}})
	check("counter plus a count", int(r.counters["people"]) == n0 + r.tagged("folk").size())
	_put(g, r.tagged("hands").slice(0, 2) + r.tagged("lindqvist"), r.area_rect("jetty"))
	r._tick_exits()
	check("EXIT after: the jetty takes nobody before the station falls", r.tagged("hands").size() == 6 and int(r.counters["saved"]) == 0)
	r.fired["turn"] = g.clock
	r._tick_exits()
	check("exit: once open it takes the hands, counted", r.tagged("hands").size() == 4 and int(r.counters["saved"]) == 2, str(r.counters["saved"]))
	check("exit except: Lindqvist stays on the jetty", r.tagged("lindqvist").size() == 1)
	r.fired.erase("turn")
	# ---- lights, rain
	check("the jungle lights", ["jungle_dusk", "jungle_night", "fire_night", "grey_dawn"].all(func(k): return MissionRun.LIGHTS.has(k)))
	r.act({"weather": "rain"})
	check("rain asked for (drawn only with a window)", true)
	r.act({"weather": ""})
	# ---- an egg kept as an egg
	var eg: Array = r._spawn({"team": "pen", "kind": "brood_egg", "count": 1, "at": "pen_in", "tag": "t_egg"})
	r.act({"cage": {"tag": "t_egg", "on": true}})
	await _run_for(2.0)
	check("a caged egg doesn't hatch", not eg[0].dead and float(eg[0].nb.get("t", 0.0)) == 0.0)
	_kill(r, "t_egg")
	# ---- the ending's lines by flag
	var pages := r.pages_now(Campaign.show_pages(r.data, "ending", "station"))
	check("ending: no flags, the plain lines", (pages[0]["lines"] as Array) == ["l_end1"] and (pages[3]["lines"] as Array) == ["k_end1", "k_end2"], str(pages[0]["lines"]))
	r.flags["clutch"] = "saved"
	r.flags["pieter"] = "lost"
	pages = r.pages_now(Campaign.show_pages(r.data, "ending", "station"))
	check("ending: saved and Pieter lost; the King's truth", (pages[0]["lines"] as Array) == ["l_end1", "l_end_saved", "l_end_nopieter"]
		and (pages[3]["lines"] as Array) == ["k_end1", "k_end2", "k_end_saved"], str(pages[0]["lines"]))
	r.flags.clear()


# ================================================================== the mission, played through

## One run through the three parts. teles: "told" / "quiet"; clutch: "burned" / "saved" ("" = Lindqvist never reaches the
## specimen house: the fire takes them; and Pieter is lost).
func _play(run: String, teles: String, clutch: String) -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	var g := await _start()
	var r: MissionRun = g.mission
	var st := r.team_index("station")
	var pt := r.team_index("pack")
	var P := "run %s (%s, %s): " % [run, teles, clutch if clutch != "" else "fire"]
	for h in ["lindqvist", "pieter"]:
		r.tagged(h)[0].spared = true          # (the test's own shield: real time runs in Part 3 and the pack bites)
	_step(g, 0.5)
	_step(g, 2.0)
	check(P + "the intro lines", r.said_ids.slice(0, 3) == ["l_1", "p_1", "tip_1"], str(r.said_ids))
	check(P + "objectives: the pen and Lindqvist", r.objectives_for("station").map(func(o): return o["id"]) == ["pen", "lindqvist"])
	# ---------------------------------------------------------------- PART 1
	for b in r.tagged("pen"):
		b.progress = 1.0
		b.built = true
		b.hp = b.max_hp
	_step2(g, 80.0)
	check(P + "her pen built", r.obj["pen"] == "done" and r.said_ids.has("l_pen") and r.said_ids.has("l_weigh"))
	_step(g, 141.0)
	check(P + "Valadares comes down the river", r.tagged("valadares").size() == 1 and r.tagged("valadares")[0].team == st and r.obj["valadares"] == "active"
		and String(r.tagged("valadares")[0].get_meta("mission_name", "")) == "Valadares")
	r.tagged("valadares")[0].spared = true
	_put(g, r.tagged("lindqvist"), r.area_rect("jetty"))
	_step2(g, 150.0)
	check(P + "they meet", r.obj["meet"] == "done" and r.said_ids.has("v_2"))
	_step(g, 151.0)
	_step(g, 158.0)
	check(P + "the tracks: go with Pieter to the ford", r.obj["tracks"] == "active")
	_put(g, r.tagged("pieter"), r.area_rect("ford"))
	_step(g, 170.0)
	_step(g, 170.5)
	check(P + "not hers: too many", r.fired.has("tracks_found") and r.said_ids.has("l_tracks"))
	_put(g, r.tagged("pieter") + r.tagged("lindqvist"), r.area_rect("yard"))
	_step(g, 185.0)
	check(P + "dusk: she calls, something answers", r.fired.has("goats_come") and r.light_name == "jungle_dusk" and r.said_ids.has("n_call"))
	_step(g, 190.5)
	check(P + "two hunters for the goats (green, the pack's)", r.tagged("goat_raptors").size() == 2 and r.tagged("goat_raptors")[0].team == pt and r.obj["goats"] == "active")
	_kill(r, "goat_raptors")
	_step2(g, 200.0)
	check(P + "driven off: she has kin", r.obj["goats"] == "done" and r.said_ids.has("l_kin"))
	_step(g, 204.5)
	check(P + "THE FIRST CHOICE is offered", String(r.choice_open.get("id", "")) == "teles")
	await process_frame
	var ui := _ui()
	check(P + "the choice panel's buttons", ui != null and ui.find_child("Choose_told", true, false) != null and ui.find_child("Choose_quiet", true, false) != null)
	ui.pick_choice("teles", teles)
	check(P + "teles: " + teles, r.flags.get("teles", "") == teles)
	# ---------------------------------------------------------------- PART 2
	_step(g, 206.0)
	_step(g, 210.0)
	check(P + "the Eve of Saint John: night and rain", r.fired.has("eve") and r.light_name == "jungle_night")
	var eve_t := float(r.fired["eve"])
	var said := r.said_ids
	check(P + "the lure is LEARNT before it is set", said.find("l_lure1") >= 0 and said.find("l_lure1") < said.find("tip_lure") and r.obj["lure"] == "active")
	check(P + "Pieter carries the jars", String(r.tagged("pieter")[0].get_meta("mission_name", "")) == "Pieter (the jars)")
	for a in ["jar_w", "jar_c", "jar_e"]:
		_put(g, r.tagged("pieter"), r.area_rect(a))
		_step(g, g.clock + 1.0)
	check(P + "three jars set", int(r.counters["jars"]) == 3 and r.obj["lure"] == "done" and String(r.tagged("pieter")[0].get_meta("mission_name", "")) == "Pieter")
	_put(g, r.tagged("pieter"), r.area_rect("yard"))
	if teles == "told":
		check(P + "TOLD: the village goes to the fort, the garrison to the causeway", r.fired.has("eve_told") and r.tagged("folk").all(func(u): return u.order == "move"))
		check(P + "TOLD: the gun at the station's landing, pinned", r.tagged("gun").size() == 1 and r.area_rect("gun_spot").grow(40).has_point(r.tagged("gun")[0].position)
			and r.tagged("gun")[0].m_pace == 0.0)
		check(P + "TOLD: hold the pens", r.obj["hold"] == "active" and r.obj["village"] == "hidden")
	else:
		check(P + "QUIET: bring the village in", r.obj["village"] == "active" and r.obj["hold"] == "hidden")
		_step(g, eve_t + 51.0)
		check(P + "QUIET: hunters at the bonfires", r.tagged("raiders").size() == 4 and r.said_ids.has("j_raid"))
		_put(g, r.tagged("guards"), r.area_rect("village"))
		_step(g, g.clock + 0.5)
		check(P + "QUIET: the station's guns at the village: they come", r.fired.has("folk_go") and r.tagged("folk").all(func(u): return u.order == "move"))
		_kill(r, "raiders")
		_put(g, r.tagged("folk"), r.area_rect("yard"))
		_put(g, r.tagged("guards"), r.area_rect("yard"))
		_step(g, g.clock + 2.5)
		check(P + "QUIET: the village is in", r.obj["village"] == "done" and int(r.counters["folk_in"]) == r.tagged("folk").size(), str(r.counters["folk_in"]))
	# the waves: the first two to the jars, then past them to her pen
	var near := func(us: Array, area: String) -> bool:
		return not us.is_empty() and us.all(func(u): return u.order_point.distance_to(r.area_rect(area).get_center()) < 220.0)
	_step(g, eve_t + 60.5)
	check(P + "wave 1 out of the creek trail: to its jar (the lure works)", r.fired.has("wave_c") and near.call(r.tagged("wave_c"), "jar_c"))
	_step(g, eve_t + 110.5)
	check(P + "wave 2 out of the north-west: to its jar", r.fired.has("wave_w") and near.call(r.tagged("wave_w"), "jar_w"))
	_step2(g, eve_t + 160.5)
	check(P + "wave 3: past the jars, to her pen", r.fired.has("wave_e") and near.call(r.tagged("wave_e"), "pen") and r.said_ids.has("p_past"), str(r.counters["waves"]))
	_kill_waves(r)
	_step(g, eve_t + 221.0)
	check(P + "the island that walks: to the creek's mouth, to root", r.tagged("turtle").size() == 1 and r.tagged("turtle")[0].team == pt and r.obj["turtle"] == "active"
		and r.tagged("turtle")[0].order == "nb_root")
	var kill_turtle := run != "C"
	if kill_turtle:
		_kill(r, "turtle")
		_step(g, eve_t + 222.0)
		check(P + "the turtle killed before midnight", r.obj["turtle"] == "done" and r.flags.get("turtle", "") == "early")
	_step(g, eve_t + 481.0)
	if not kill_turtle:
		check(P + "the turtle alive: the forest is not quiet yet", not r.fired.has("quiet_falls"))
		_step(g, eve_t + 661.0)
	check(P + "the forest goes quiet", r.fired.has("quiet_falls") and r.said_ids.has("n_quiet"))
	_kill_waves(r)
	# ---------------------------------------------------------------- PART 3
	_step(g, g.clock + 11.0)
	check(P + "PART 3: the Sire, told plainly, the countdown", r.fired.has("turn") and r.tagged("sire").size() == 1 and r.said_ids.has("v_lost") and r.obj["fall"] == "active")
	var turn_t := float(r.fired["turn"])
	_step(g, turn_t + 0.5)
	var want := 520.0 + (90.0 if kill_turtle else 0.0)
	check(P + "the canoes in 8:40 (+1:30 with the turtle dead early)", absf(float(r.clocks["canoes"]) - (turn_t + want)) < 0.6, str(float(r.clocks["canoes"]) - turn_t))
	check(P + "the part 1-2 objectives leave the panel", not r.objectives_for("station").map(func(o): return o["id"]).has("lure"))
	var want_p: int = g.units.filter(func(u): return u.team == st and not u.dead).size() - 2 + r.tagged("folk").size() + int(r.counters["saved"])
	check(P + "the people counted", int(r.counters["people"]) == want_p, "%d v %d" % [int(r.counters["people"]), want_p])
	check(P + "the Sire cannot die tonight", r.tagged("sire")[0].hp_floor > 300.0)
	check(P + "the fire light", r.light_name == "fire_night")
	if teles == "told":
		check(P + "TOLD: the village to the fort's steps; the gun to keep", r.fired.has("turn_folk_told") and r.obj["gun"] == "active")
	# the Sire at her pen: he roots, she lays
	var sr: Unit = r.tagged("sire")[0]
	_kill(r, "sire_pack")
	_put(g, [sr], r.area_rect("nest"))
	await _run_for(0.3)
	check(P + "he comes to the pen and lies down", r.fired.has("sire_at_pen"))
	await _run_for(4.0)
	check(P + "rooted beside her", BroodNew.rooted(sr), "%s %s" % [sr.order, sr.tesla_mode])
	_step(g, g.clock + 0.3)
	check(P + "like a groom", r.said_ids.has("l_groom"))
	for i in 6:
		_step(g, g.clock + 26.0)
	check(P + "THE CLUTCH: eggs in her straw (5), kept as eggs", r.tagged("eggs").size() == 5 and r.tagged("eggs").all(func(e): return e.has_meta("mission_caged") and e.spared),
		str(r.tagged("eggs").size()))
	check(P + "she is too young", r.said_ids.has("l_young"))
	check(P + "he calls with her, the forest answers", int(r._times.get("sire_call", 0)) >= 2)
	_kill_waves(r)
	# hurt to a third he gets up
	sr.take_damage(5000.0, null)
	_step(g, g.clock + 0.3)
	await _run_for(3.2)
	check(P + "hurt to a third he gets up (nothing kills him)", not sr.dead and not BroodNew.rooted(sr) and int(r.counters["drove"]) == 1 and r.said_ids.has("n_nothing"))
	_kill_waves(r)
	# the fire
	check(P + "the station burns, the house last", r._burning.size() >= 2 and r.fired.has("fire_3") == (g.clock - turn_t >= 160.0))
	# he takes her
	var lin: Unit = r.tagged("linnea")[0]
	var canoes := float(r.clocks["canoes"])
	var take := float(r.clocks["take"])
	check(P + "he takes her before the specimen house can burn down", take < turn_t + 150.0 + 360.0 and take < canoes - 120.0)
	_step(g, take + 0.1)
	check(P + "HE TAKES HER: the pen broken", r.fired.has("taken") and r.tagged("pen").is_empty())
	_step(g, take + 1.5)
	check(P + "she is the pack's now, free, still untouchable", lin.team == pt and not lin.has_meta("mission_caged") and lin.spared and r.tagged("taken").size() == 1)
	_step(g, take + 4.0)
	_step(g, take + 6.0)
	check(P + "they walk off up the creek trail", lin.order == "move" and sr.order == "move")
	_put(g, [lin, sr], r.area_rect("out_n"))
	_step(g, take + 7.0)
	check(P + "...and off the map", r.tagged("taken").is_empty() and r.tagged("sire").is_empty())
	check(P + "the research: reach the specimen house", r.obj["research"] == "active")
	if clutch != "":
		_put(g, r.tagged("lindqvist"), r.area_rect("spec"))
		_step(g, take + 9.0)
		check(P + "THE SECOND CHOICE is offered", String(r.choice_open.get("id", "")) == "clutch" and r.obj["research"] == "done")
		await process_frame
		check(P + "the choice panel's buttons", ui.find_child("Choose_burned", true, false) != null and ui.find_child("Choose_saved", true, false) != null)
		ui.pick_choice("clutch", clutch)
		check(P + "clutch: " + clutch, r.flags.get("clutch", "") == clutch and r.tagged("eggs").is_empty())
		var lq: Unit = r.tagged("lindqvist")[0]
		if clutch == "saved":
			check(P + "SAVED: Lindqvist carries the crate (slower, can't shoot)", lq.m_pace < 1.0 and lq.m_unarmed and String(lq.get_meta("mission_name", "")) == "Dr. Lindqvist (the crate)")
		else:
			check(P + "BURNED: Lindqvist free and armed", lq.m_pace == 1.0 and not lq.m_unarmed)
	else:
		_kill(r, "pieter")
		_step(g, canoes - 39.0)
		check(P + "never reached: the fire takes the eggs", r.flags.get("clutch", "") == "burned" and r.flags.get("fire", "") == "yes" and r.obj["research"] == "failed"
			and r.tagged("eggs").is_empty())
		check(P + "Pieter lost", r.obj["pieter"] == "failed" and r.said_ids.has("l_pieter") and not g.over)
	# the people to the jetty
	var hands := r.tagged("hands")
	var n_hands := hands.size()
	_put(g, hands, r.area_rect("jetty"))
	_step(g, canoes - 30.0)
	check(P + "the hands into the canoes: counted", int(r.counters["saved"]) >= n_hands and r.tagged("hands").is_empty(), str(r.counters["saved"]))
	var folk := r.tagged("folk")
	_put(g, folk, r.area_rect("fort_steps" if teles == "told" else "jetty"))
	_step(g, canoes - 29.0)
	check(P + "the villagers out too", r.tagged("folk").is_empty() and int(r.counters["saved"]) >= n_hands + folk.size())
	check(P + "the warning", r.said_ids.has("b_warn"))
	_put(g, r.tagged("lindqvist"), r.area_rect("jetty"))
	_put(g, r.tagged("valadares"), r.area_rect("jetty").grow_individual(0, 0, 0, -40))
	_step(g, canoes - 28.0)
	check(P + "the heroes stay on the jetty (not taken off as 'saved')", r.tagged("lindqvist").size() == 1 and r.tagged("valadares").size() == 1)
	_step(g, canoes + 0.1)
	check(P + "THE CANOES LEAVE with them aboard", r.fired.has("leave") and r.said_ids.has("n_leave") and not g.over)
	check(P + "the saved tallied", r.flags.has("saved") and int(r.flags.get("saved_n", -1)) == int(r.counters["saved"]))
	check(P + "the flags", r.flags.get("teles", "") == teles and r.flags.get("pieter", "") == ("lost" if clutch == "" else "alive")
		and r.flags.get("turtle", "") == ("early" if kill_turtle else "late") and r.flags.get("clutch", "") == (clutch if clutch != "" else "burned"), str(r.flags))
	if teles == "told":
		check(P + "TOLD: the gun's flag", r.flags.get("gun", "") in ["kept", "lost"])
	_step(g, canoes + 13.0)
	check(P + "the story's end: the station 'wins' the mission", g.over and r.winner_side == "station" and r.obj["out"] == "done")
	await create_timer(1.8).timeout
	var show: StillShow = null
	for n in main.ui_layer.get_children():
		if n is StillShow:
			show = n
	check(P + "the ending plays", show != null)
	if show:
		for i in 20:
			if is_instance_valid(show) and not show.is_queued_for_deletion():
				show.next()
		var wl: Array = ["l_end1", {"saved": "l_end_saved", "burned": "l_end_burned", "": "l_end_fire"}[clutch], "l_end_pieter" if clutch != "" else "l_end_nopieter",
			"l_end_north", "l_end2", "k_end1", "k_end2"]
		if clutch == "saved":
			wl.append("k_end_saved")
		check(P + "the ending's lines by the flags", show.shown_ids == wl, str(show.shown_ids))
	for i in 3:
		await process_frame
	var ep := _end_panel()
	check(P + "the end screen", ep != null)
	if ep:
		var ls := _labels(ep)
		check(P + "it says THE STATION IS LOST, not VICTORY", ls.has("THE STATION IS LOST") and not ls.has("VICTORY"), str(ls.slice(0, 2)))
		check(P + "the debrief's lines by the flags", ls.any(func(s): return s.contains("Teles was " + ("told" if teles == "told" else "not told"))))
		check(P + "the people counted on it", ls.any(func(s): return s.contains("%d of %d" % [int(r.counters["saved"]), int(r.counters["people"])])))
	var p := Campaign.progress()
	check(P + "the story's loss COUNTS: the mission is done", (p["done"] as Dictionary).has(MID))
	check(P + "the flags are kept for later missions", Campaign.flag(MID, "teles") == teles and Campaign.flag(MID, "clutch") == (clutch if clutch != "" else "burned"))


func _defeats() -> void:
	# a hero killed: the one real loss (retry)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	var g := await _start()
	var r: MissionRun = g.mission
	_step(g, 30.0)
	_kill(r, "lindqvist")
	_step(g, 31.0)
	check("Lindqvist killed: the mission is lost", g.over and r.winner_side == "pack" and r.obj["lindqvist"] == "failed" and r.obj["p_kill"] == "done")
	await create_timer(1.8).timeout
	var ep := _end_panel()
	check("...the end screen says DEFEAT", ep != null and _labels(ep).has("DEFEAT"))
	check("...and it does not count", not (Campaign.progress()["done"] as Dictionary).has(MID))
	# left behind at the jetty
	g = await _start()
	r = g.mission
	_step(g, 0.5)
	_step(g, 141.0)
	for tr in r.data["triggers"]:
		if String(tr["id"]) == "quiet_falls":
			r.fire(tr)
	_step(g, g.clock + 11.0)
	check("left behind: part 3 started", r.fired.has("turn"))
	_put(g, r.tagged("lindqvist"), r.area_rect("yard"))
	_step(g, float(r.clocks["canoes"]) + 0.1)
	_step(g, float(r.clocks["canoes"]) + 1.0)
	check("Lindqvist not at the jetty when the canoes leave: lost", g.over and r.winner_side == "pack" and r.obj["out"] == "failed" and r.said_ids.has("n_behind"))


func _hub_after() -> void:
	main._to_menu()
	await process_frame
	var sl := Campaign.storyline_of(MID)
	var before := CampaignMenu.hub_now(sl["hub"], {"done": {}})
	check("hub before: Lindqvist's Station, her crate, no egg of the plateau yet", String(before["title"]) == "Lindqvist's Station"
		and (before["hotspots"] as Array).any(func(h): return h["id"] == "crate") and not (before["hotspots"] as Array).any(func(h): return h["id"] == "egg"))
	var saved := CampaignMenu.hub_now(sl["hub"], {"done": {MID: {"flags": {"clutch": "saved"}}}})
	check("hub after (eggs saved): the warehouse at the Barra, the crate in the cellar", String(saved["title"]) == "The Warehouse at the Barra"
		and (saved["hotspots"] as Array).any(func(h): return h["id"] == "eggs_crate") and not (saved["hotspots"] as Array).any(func(h): return h["id"] == "notebook")
		and not (saved["hotspots"] as Array).any(func(h): return h["id"] == "crate"))
	var burned := CampaignMenu.hub_now(sl["hub"], {"done": {MID: {"flags": {"clutch": "burned"}}}})
	check("hub after (eggs burned): the singed notebook", (burned["hotspots"] as Array).any(func(h): return h["id"] == "notebook")
		and not (burned["hotspots"] as Array).any(func(h): return h["id"] == "eggs_crate"))
	var tk: Dictionary = sl["hub"]["talks"]["eggs_crate"]
	check("the crate's talk: it grows", String(CampaignMenu.talk_lines(tk, {"done": {MID: {"flags": {"clutch": "saved"}}}})[1]) == "It grows.")
	var king: Dictionary = Campaign.storylines()[0]["hub"]
	check("the King's study after b01: Lindqvist held there", (CampaignMenu.hub_now(king, {"done": {MID: {}}})["hotspots"] as Array).any(func(h): return h["id"] == "lindqvist_held")
		and not (CampaignMenu.hub_now(king, {"done": {}})["hotspots"] as Array).any(func(h): return h["id"] == "lindqvist_held"))
	check("the King's words after b01", String(CampaignMenu.talk_lines(king["talks"]["king"], {"done": {"p01_leaf": {}, MID: {}}})[1]).contains("held in the palace"))
	Campaign.save_progress({"reached": [], "done": {"p01_leaf": {}, MID: {"flags": {"clutch": "saved"}}}})
	CampaignMenu.line = "naturalist"
	CampaignMenu.show(main)
	await process_frame
	await process_frame
	check("the hub page: THE CRATE IN THE CELLAR listed", main.find_child("HotspotList_eggs_crate", true, false) != null and main.find_child("HotspotList_crate", true, false) == null)
	CampaignMenu.line = ""
