extends SceneTree
## The Naturalist's prologue, "Specimen One", PLAYED AS THE BROOD (docs/campaign_b01_build.md: the prologue flip), and
## the engine it needed:
##   - the data checks out, every text has pt and es, the seats (solo: you are the Sire's pack, the rival pack the Brood
##     computer; versus: the friend is the rival pack), THE NATURALIST storyline, the stills and sounds, the colours (the
##     Sire's pack GREEN, the rival RED, the station YELLOW, the garrison PURPLE), the dark jungle floor;
##   - the ENGINE, each feature on its own: the flip's `nest_free` (a father nesting away from his Mother's range, a
##     person's ROOT too), the `heel` order (Linnea at the Sire's heels), a team's `ai_foe` (the rival computer goes for the
##     Sire's pack, not the station) and `supply_cap`, `hall_tag` on a Brood team (her Mother); and the Brood prologue's:
##     `cage`, `spare`, `carry`, `floor` and `heal`, the `hp` condition, scripted ROOT and UPROOT and the `rooted`
##     condition by tag, `burn`, exits that open `after` a trigger and keep `except` tags, a counter from a count, the
##     jungle lights, a caged egg;
##   - THE MISSION played through, both ways of the player's one choice: run L (LEAVE the clutch: Lindqvist saves it,
##     the canon) and run T (TAKE the clutch: the Sire carries it home); each step of the teaching strip (root, lay and
##     hatch, the roar, Linnea and her clutch, the gate, home), the station's story by the script (Valadares, the tracks,
##     the Teles debate kept quiet, the lure, the break-in, the fire, Teles late, the research, the canoes), the rival
##     pack's hunters, the end (a win: SHE IS HOME), the ending's if-lines, the flags kept for later missions; the
##     defeats (the Sire or the Old Mother killed); the naturalist's hub and the King's study after it.
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
	await _play("L", "left")
	await _play("T", "taken")
	await _defeats()
	await _hub_after()
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("b01_specimen: data checks out", pr.is_empty(), "; ".join(pr))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + ["Pieter (the jars)", "Dr. Lindqvist (the crate)", "Pieter", "The Old Mother",
			"The Rival Mother", "The Tyrant Sire (the clutch)"]:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	check("the clutch: a ninhada / la puesta (the Brood itself is a Ninhada / la Nidada)", String(LangPt.T.get("TAKE THE CLUTCH", "")).contains("NINHADA") and String(LangEs.T.get("TAKE THE CLUTCH", "")).contains("PUESTA"))
	var sl := Campaign.storyline_of(MID)
	check("THE NATURALIST storyline's first mission is b01", String(sl.get("id", "")) == "naturalist" and String(sl.get("title", "")) == "The Naturalist" and (sl["missions"] as Array)[0] == MID)
	check("it opens after the Crown's prologue", String(sl.get("requires", "")) == "p01_leaf")
	check("solo and versus (no co-op: one Brood side to play)", (m["modes"] as Array) == ["solo", "versus"])
	var c := Campaign.make_cfg(MID, "solo")
	var who: Array = c["slots"].map(func(s): return s["who"])
	check("solo: you are the Sire's pack; the rival pack is the Brood computer (Easy); the rest scripted",
		who == ["you", "easy", "script", "script", "script", "script", "script"], str(who))
	c = Campaign.make_cfg(MID, "versus", "p1", true)
	who = c["slots"].map(func(s): return s["who"])
	check("versus online: the friend is the rival pack", who == ["you", "remote", "script", "script", "script", "script", "script"], str(who))
	var sl0: Dictionary = c["slots"][0]
	var sl1: Dictionary = c["slots"][1]
	check("the Sire's pack GREEN Brood, the rival RED Brood, the station YELLOW, the garrison PURPLE",
		int(sl0["colour"]) == 2 and sl0["faction"] == "brood" and int(sl1["colour"]) == 1 and sl1["faction"] == "brood"
		and int(c["slots"][2]["colour"]) == 3 and c["slots"][2]["faction"] == "crown" and int(c["slots"][3]["colour"]) == 4)
	check("three sides: the Sire's pack, the rival pack, the station", Campaign.side_ids(m) == ["sire", "rival", "station"])
	check("the rival: its foe is the Sire's pack, its supply capped", String(m["teams"][1].get("ai_foe", "")) == "sire" and int(m["teams"][1].get("supply_cap", 0)) == 36)
	check("the map is the Rio Negro map, in the jungle, with the two dens and seven starts", String(m["map"]) == "campaign:rio_negro_station"
		and String(Campaign.map_data("rio_negro_station").get("biome", "")) == "jungle" and (Campaign.map_data("rio_negro_station")["starts"] as Array).size() == 7)
	check("the floor is darkened", (m.get("floor", []) as Array).size() == 3 and float(m["floor"][1]) < 0.8)
	for k in m["stills"]:
		check("still %s: its picture loads" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	for s in ["linnea_call", "forest_answer", "sire_roar"]:
		check("sound campaign/%s is in" % s, ResourceLoader.exists("res://assets/audio/campaign/%s.wav" % s))
	# (the roster ladder's NEW card is the game's own voice, not a creature: docs/campaign_roster_ladder.md)
	check("no creature speaks: every speaker is the station's or the King's", (m["speakers"] as Dictionary).keys().all(func(k): return k == "new" or String(m["speakers"][k]["side"]) == "station"))
	check("the voice folder is b01 and l_open1 is recorded (Chatterbox, 0.38.70)", String(m.get("voice", "")) == "b01" and CampaignVoice.path_of(m, "l_open1") != "")
	check("Linnea is a Brood Mother's kind, drawn at 0.3", String(Rebels.role("linnea")["kind"]) == "brood_mother" and is_equal_approx(float(Rebels.role("linnea")["scale"]), 0.3))


# ================================================================== the engine, feature by feature

func _engine() -> void:
	var g := await _start()
	var r: MissionRun = g.mission
	var me := r.team_index("sire")
	var rv := r.team_index("rival")
	var st := r.team_index("station")
	var pen_t := r.team_index("pen")
	_step(g, 0.5)
	check("one computer player: the rival pack", g.ais.size() == 1)
	check("AI_FOE: the rival computer goes for the Sire's pack, not the station", g.ais.size() == 1 and g.ais[0]._foe() == me, str(g.ais[0]._foe() if g.ais.size() == 1 else -9))
	check("SUPPLY_CAP: the rival pack's supply capped at 36, the player's not", g.max_supply(rv) == 36 and g.max_supply(me) > 36)
	check("the jungle afternoon light at the start", r.light_name == "jungle_day" and r.light_node != null)
	check("the floor tinted dark", g.ground.modulate.g < 0.8, str(g.ground.modulate))
	var om: Array = r.tagged("old_mother")
	check("HALL_TAG on a Brood team: the Old Mother tagged and named", om.size() == 1 and om[0].kind == "brood_mother" and om[0].team == me
		and String(om[0].get_meta("mission_name", "")) == "The Old Mother")
	check("...and the Rival Mother", r.tagged("rival_mother").size() == 1 and r.tagged("rival_mother")[0].team == rv)
	check("the Old Mother's standard start: rooted, a Rootmaw, grubs", BroodNew.rooted(om[0]) or om[0].tesla_mode in ["deploying", "deployed"]) 
	var sire: Unit = r.tagged("sire")[0]
	check("the Tyrant Sire is the player's, named, not rooted", sire.kind == "tyrannosaur" and sire.team == me and not BroodNew.rooted(sire)
		and String(sire.get_meta("mission_name", "")) == "The Tyrant Sire")
	check("the station's house, specimen house and garden", r.tagged("station_house").size() == 1 and r.tagged("specimen_house").size() == 1 and r.tagged("garden").size() == 1)
	check("her pen: 11 stakes and a gate, built, spared", r.tagged("pen").size() == 11 and r.tagged("pen_gate").size() == 1
		and (r.tagged("pen") + r.tagged("pen_gate")).all(func(b): return b is Building and b.built and b.spared))
	var lin: Unit = r.tagged("linnea")[0]
	check("Linnea: a Brood Mother of the pen team, on the station's side", lin.kind == "brood_mother" and lin.team == pen_t and g.allied(pen_t, st) and g.hostile(pen_t, me))
	check("Linnea drawn at 0.3", is_equal_approx(float(lin.get_meta("role_scale", 1.0)), 0.3) and lin.radius < 20.0, str(lin.radius))
	check("CAGE and SPARE: she can't move or bite, nobody can touch her", lin.m_pace == 0.0 and lin.m_unarmed and lin.spared and lin.untouchable())
	var lq: Unit = r.tagged("lindqvist")[0]
	check("the teller can't be killed, and carries no gun (he can't shoot the pack while untouchable)", lq.spared and lq.m_unarmed and is_equal_approx(lq.m_pace, 1.0))
	check("the station's hands and Pieter never fight", r.tagged("hands").all(func(u): return u.m_unarmed) and r.tagged("pieter")[0].m_unarmed)
	var p0 := lin.position
	lin.position += Vector2(60, 0)
	r._tick_held()
	check("cage: put back in her pen", lin.position.distance_to(p0) < 1.0)
	# ---- nest_free: a father may root away from his Mother's range (a person's ROOT too)
	var nest := BroodRoot.snap("tyrannosaur", r.area_rect("nest").get_center(), 1.0)
	var why := BroodRoot.place_problem(g, me, "tyrannosaur", nest, sire, false)
	check("the Sire can't nest by her pen: out of the Old Mother's range", why.begins_with("Out of range"), why)
	r.act({"nest_free": {"tag": "sire", "on": true}})
	why = BroodRoot.place_problem(g, me, "tyrannosaur", nest, sire, false)
	check("NEST_FREE: now he may (the same rule a person's ROOT ghost asks)", not why.begins_with("Out of range"), why)
	r.act({"nest_free": {"tag": "sire", "on": false}})
	check("nest_free off: out of range again", BroodRoot.place_problem(g, me, "tyrannosaur", nest, sire, false).begins_with("Out of range"))
	# ---- heel: a scripted unit walks after its leader
	var kin: Array = r._spawn({"team": "kin", "kind": "raptor", "count": 1, "at": "pen", "tag": "t_kin"})
	r.act({"order": {"tag": "t_kin", "do": "heel", "leader": "sire"}})
	check("HEEL: she walks after the leader", kin[0].order == "move" and kin[0].order_point.distance_to(sire.position) < 140.0, "%s %s" % [kin[0].order, kin[0].order_point])
	check("the kin team is the player's ally, not the player's", g.allied(kin[0].team, me) and kin[0].team != me)
	_kill(r, "t_kin")
	# ---- floor, heal, hp; scripted root and uproot (a hunters' father nesting by another side's Mother)
	var ts: Array = r._spawn({"team": "hunters", "kind": "tyrannosaur", "count": 1, "at": "nest", "tag": "t_sire"})
	r.act({"floor": {"tag": "t_sire", "share": 0.33}})
	ts[0].take_damage(5000.0, null)
	check("FLOOR: stops at a third", not ts[0].dead and absf(ts[0].hp - 330.0) < 2.0, str(ts[0].hp))
	check("hp condition", r.cond({"hp": {"tag": "t_sire", "below": 0.36}}) and not r.cond({"hp": {"tag": "t_sire", "below": 0.3}}))
	r.act({"heal": {"tag": "t_sire", "share": 0.7}})
	check("HEAL: back to 70%", absf(ts[0].hp - 700.0) < 1.0)
	r.act({"order": {"tag": "t_sire", "do": "root", "to": "nest"}})
	await _run_for(4.0)
	check("scripted ROOT beside a Mother not his side's", BroodNew.rooted(ts[0]) and r.cond({"rooted": {"tag": "t_sire"}}), "%s %s" % [ts[0].order, ts[0].tesla_mode])
	r.act({"order": {"tag": "t_sire", "do": "uproot"}})
	await _run_for(3.2)
	check("UPROOT", not BroodNew.rooted(ts[0]), ts[0].tesla_mode)
	_kill(r, "t_sire")
	# ---- carry
	r.act({"carry": {"tag": "lindqvist", "on": true, "pace": 0.6}})
	check("CARRY: slower and unarmed", is_equal_approx(lq.m_pace, 0.6) and lq.m_unarmed)
	r.act({"carry": {"tag": "lindqvist", "on": true, "pace": 1.0}})
	# ---- burn
	var spec: Building = r.tagged("specimen_house")[0]
	var h0 := spec.hp
	r.act({"burn": {"tag": "specimen_house", "secs": 10}})
	for i in 8:
		r._tick_held()
	check("BURN: the specimen house burns (spared from the pack, not from the fire)", spec.hp < h0 * 0.85 and not spec.dead and spec.spared, "%d of %d" % [spec.hp, h0])
	r._burning.clear()
	spec.hp = spec.max_hp
	# ---- counters from a count, exits after / except
	check("the people counted at the start (the station's but Lindqvist, the village, the friar)",
		int(r.counters["people"]) == r.tagged("hands").size() + r.tagged("guards").size() + 1 + r.tagged("folk").size() + 1, str(r.counters["people"]))
	_put(g, r.tagged("hands").slice(0, 2) + r.tagged("lindqvist"), r.area_rect("jetty"))
	r._tick_exits()
	check("EXIT after: the jetty takes nobody before the pen breaks", r.tagged("hands").size() == 6 and int(r.counters["saved"]) == 0)
	r.fired["broken"] = g.clock
	r._tick_exits()
	check("exit: once open it takes the hands, counted", r.tagged("hands").size() == 4 and int(r.counters["saved"]) == 2, str(r.counters["saved"]))
	check("exit except: Lindqvist waits for his crate", r.tagged("lindqvist").size() == 1)
	r.fired.erase("broken")
	# ---- lights, an egg kept as an egg
	check("the jungle lights", ["jungle_dusk", "jungle_night", "fire_night", "grey_dawn"].all(func(k): return MissionRun.LIGHTS.has(k)))
	var eg: Array = r._spawn({"team": "pen", "kind": "brood_egg", "count": 1, "at": "pen_in", "tag": "t_egg"})
	r.act({"cage": {"tag": "t_egg", "on": true}})
	await _run_for(2.0)
	check("a caged egg doesn't hatch", not eg[0].dead and float(eg[0].nb.get("t", 0.0)) == 0.0)
	_kill(r, "t_egg")
	# ---- the ending's lines by flag
	var pages := r.pages_now(Campaign.show_pages(r.data, "ending", "sire"))
	check("ending: no flags, the plain lines", (pages[0]["lines"] as Array) == ["l_end1"] and (pages[4]["lines"] as Array) == ["k_end1", "k_end2"], str(pages[0]["lines"]))
	r.flags["clutch"] = "saved"
	r.flags["pieter"] = "lost"
	pages = r.pages_now(Campaign.show_pages(r.data, "ending", "sire"))
	check("ending: saved and Pieter lost; the King's truth", (pages[0]["lines"] as Array) == ["l_end1", "l_end_saved", "l_end_nopieter"]
		and (pages[4]["lines"] as Array) == ["k_end1", "k_end2", "k_end_saved"], str(pages[0]["lines"]))
	r.flags = {"clutch": "burned", "fire": "yes", "eggs": "taken"}
	pages = r.pages_now(Campaign.show_pages(r.data, "ending", "sire"))
	check("ending: taken: Lindqvist thinks the fire took them; the King knows better", (pages[0]["lines"] as Array) == ["l_end1", "l_end_fire"]
		and (pages[4]["lines"] as Array) == ["k_end1", "k_end2", "k_end_taken"], str(pages[4]["lines"]))
	r.flags = {}


# ================================================================== the mission, played through

## Roots `u` at the first free spot round `c` (BroodRoot's own rules, as a person's ROOT), in real time.
func _root(g: Game, u: Unit, c: Vector2) -> bool:
	for rad in range(0, 9):
		for i in 16:
			var p := BroodRoot.snap(u.kind, c + Vector2(cos(TAU * i / 16.0), sin(TAU * i / 16.0)) * rad * Defs.TILE, 1.0)
			if BroodRoot.place_problem(g, u.team, u.kind, p, u, false) == "":
				u.position = p + Vector2(0, 40)
				u.give({"o": "nb_root", "p": p}, false)
				g._rebuild_hash()
				for k in 300:
					await physics_frame
					if BroodNew.rooted(u):
						return true
				return false
	return false


## One run: eggs "left" (canon: Lindqvist saves the clutch) or "taken" (the Sire carries it home).
func _play(run: String, eggs: String) -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	var g := await _start()
	var r: MissionRun = g.mission
	var me := r.team_index("sire")
	var st := r.team_index("station")
	var P := "run %s (%s): " % [run, eggs]
	for t in ["old_mother", "sire", "pieter"]:
		r.tagged(t)[0].spared = true          # (the test's own shield: real time runs while rooting)
	_step(g, 0.5)
	_step(g, 2.0)
	check(P + "the intro: Lindqvist's eyes", r.said_ids.slice(0, 2) == ["l_1", "l_2"], str(r.said_ids))
	check(P + "the teaching strip starts with ROOT", r.objectives_for("sire").map(func(o): return o["id"]) == ["mother", "sire", "root", "rival"])
	# ---- ROOT
	var sire: Unit = r.tagged("sire")[0]
	var q: Unit = r.tagged("old_mother")[0]
	var ok := await _root(g, sire, q.position + Vector2(5, 3) * Defs.TILE)
	check(P + "the Sire roots in the Old Mother's father range", ok, sire.tesla_mode)
	_step2(g, 10.0)
	check(P + "ROOT done, LAY AND HATCH next", r.obj["root"] == "done" and r.obj["lay"] == "active")
	# ---- LAY AND HATCH: two eggs (four Raptors with the two she started with)
	check(P + "the Old Mother can lay a Raptor now (the Sire rooted beside her)", BroodNew.lay_problem(g, q, "raptor") in ["", "No eggs ready.", "Not enough food."],
		BroodNew.lay_problem(g, q, "raptor"))
	r._spawn({"team": "sire", "kind": "raptor", "count": 4, "at": "sire_start", "tag": "pack"})
	_step(g, 13.0)
	_step2(g, 13.5)
	check(P + "six Raptors: the roar next", int(r.counters["raptors"]) >= 6 and r.obj["lay"] == "done" and r.obj["roar"] == "active", str(r.counters["raptors"]))
	# ---- the station's afternoon
	_step(g, 71.0)
	check(P + "she calls at sunset (Lindqvist's eyes)", r.said_ids.has("l_weigh"))
	_step(g, 141.0)
	var va: Array = r.tagged("valadares")
	check(P + "Valadares comes down the river: untouchable, unarmed", va.size() == 1 and va[0].team == st and va[0].spared and va[0].m_unarmed and int(r.counters["people"]) == 28,
		str(r.counters["people"]))
	_step(g, 160.0)
	check(P + "they meet", r.said_ids.has("v_2"))
	# ---- the hunters at the den once the Sire is out
	BroodNew.uproot(sire, false)
	await _run_for(3.0)
	_put(g, [sire], r.area_rect("edge"))
	_step(g, 161.0)
	check(P + "the pack at the forest's edge: the tracks seen (two packs)", r.said_ids.has("v_tracks") and r.said_ids.has("p_tracks2"))
	# ---- THE ROAR
	_step2(g, 162.0)
	check(P + "THE SIRE'S ROAR: done, she answers", r.obj["roar"] == "done" and r.fired.has("roar_heard") and r.said_ids.has("n_call") and r.light_name == "jungle_dusk")
	check(P + "...and now he may nest by her pen", sire.has_meta("mission_root"))
	_step(g, 165.5)
	check(P + "LINNEA next; her pen revealed", r.obj["nest"] == "active" and r.fired.has("she_answers"))
	while g.clock < 230.0:
		_step(g, g.clock + 1.0)
	check(P + "the rival pack's hunters come for her too (red, the rival's side)", r.tagged("hunters").size() == 5 and r.tagged("hunters").all(func(u): return r.side_of_team(u.team) == "rival"))
	check(P + "...and at the den, the Sire being out", r.tagged("den_raid").size() == 6)
	_kill(r, "hunters")
	_kill(r, "den_raid")
	# ---- DUSK: the Teles debate (the script's: KEEP IT QUIET)
	check(P + "THE TELES DEBATE, kept quiet by the script", r.flags.get("teles", "") == "quiet" and r.said_ids.has("l_one_night") and r.choice_open.is_empty())
	check(P + "the night, the rain, the lure", r.fired.has("eve") and r.light_name == "jungle_night" and r.said_ids.has("l_stallion")
		and String(r.tagged("pieter")[0].get_meta("mission_name", "")) == "Pieter (the jars)")
	for a in ["jar_w", "jar_c", "jar_e"]:
		_put(g, r.tagged("pieter"), r.area_rect(a))
		_step(g, g.clock + 1.0)
	_step(g, g.clock + 0.5)
	check(P + "three jars set (they pull nobody)", int(r.counters["jars"]) == 3 and r.said_ids.has("p_set") and String(r.tagged("pieter")[0].get_meta("mission_name", "")) == "Pieter")
	_put(g, r.tagged("pieter"), r.area_rect("yard"))
	# ---- THE BREAK-IN and LINNEA
	_put(g, [sire], r.area_rect("nest_wide"))
	_step(g, g.clock + 0.5)
	check(P + "the Sire in the station: the ground shook, the fire light", r.fired.has("turn") and r.said_ids.has("v_lost") and r.light_name == "fire_night")
	var turn_t := float(r.fired["turn"])
	ok = await _root(g, sire, r.area_rect("nest").get_center())
	check(P + "the Sire roots beside her pen", ok and r.area_rect("nest_wide").has_point(sire.position), sire.tesla_mode)
	_step(g, g.clock + 0.5)
	check(P + "he lay down like a groom (Lindqvist's eyes)", r.fired.has("sire_rooted") and r.said_ids.has("l_groom"))
	var t0 := g.clock
	_step(g, t0 + 8.5)
	check(P + "her first egg, caged and spared", int(r.counters["eggs"]) == 1 and r.tagged("eggs").size() == 1 and r.tagged("eggs")[0].spared)
	_step(g, g.clock + 0.1)
	check(P + "they see the eggs", r.said_ids.has("l_young") and r.said_ids.has("p_eggs"))
	for i in 4:
		_step(g, g.clock + 16.1)
	_step(g, g.clock + 0.1)
	check(P + "the clutch: five eggs; break the gate next", int(r.counters["eggs"]) == 5 and r.tagged("eggs").size() == 5 and r.obj["nest"] == "done"
		and r.obj["gate"] == "active" and not r.tagged("pen_gate")[0].spared, "%d %s" % [int(r.counters["eggs"]), r.obj["nest"]])
	_step(g, turn_t + 21.0)
	_step(g, turn_t + 61.0)
	check(P + "the fire (Valadares fires the thatch); Teles late to the causeway", r.said_ids.has("v_fire") and r.said_ids.has("t_late") and r.said_ids.has("j_raid"))
	# ---- THE GATE: she goes with him
	_kill(r, "pen_gate")
	_step(g, g.clock + 0.5)
	check(P + "THE PEN BROKEN: the stakes down, she is uncaged", r.fired.has("broken") and r.tagged("pen").is_empty() and not r.tagged("linnea")[0].has_meta("mission_caged"))
	check(P + "the station falls: its people to the jetty and the beach", r.tagged("hands").all(func(u): return u.order == "move") and r.tagged("folk").all(func(u): return u.order == "move"))
	check(P + "THE PLAYER'S CHOICE is offered", String(r.choice_open.get("id", "")) == "eggs" and String(r.choice_open.get("side", "")) == "sire")
	await process_frame
	var ui := _ui()
	check(P + "the choice panel's buttons", ui != null and ui.find_child("Choose_taken", true, false) != null and ui.find_child("Choose_left", true, false) != null)
	ui.pick_choice("eggs", eggs)
	check(P + "eggs: " + eggs, r.flags.get("eggs", "") == eggs)
	_step(g, g.clock + 1.2)
	var lin: Unit = r.tagged("linnea")[0]
	check(P + "Linnea is the pack's kin now (green, allied, not the player's to order), still untouchable", lin.team == r.team_index("kin") and g.allied(lin.team, me) and lin.spared)
	if eggs == "taken":
		check(P + "TAKEN: the eggs gone with him; the Sire carries them (slower, he cannot bite)", r.tagged("eggs").is_empty() and is_equal_approx(sire.m_pace, 0.6) and sire.m_unarmed
			and String(sire.get_meta("mission_name", "")) == "The Tyrant Sire (the clutch)")
	else:
		check(P + "LEFT: the eggs stay in the straw; the Sire free", r.tagged("eggs").size() == 5 and not sire.m_unarmed)
	_step(g, g.clock + 2.1)
	check(P + "HEEL: she walks after the Sire", r.fired.has("heel") and lin.order == "move")
	# ---- THE RESEARCH (the script's choice: SAVE IT)
	check(P + "Lindqvist goes for the straw (the scientists' debate)", r.fired.has("research_go") and r.said_ids.has("l_save"))
	_put(g, r.tagged("lindqvist"), r.area_rect("pen"))
	_step(g, g.clock + 0.5)
	_step(g, g.clock + 4.5)
	if eggs == "taken":
		check(P + "TAKEN: the straw empty: he thinks the fire took them", r.flags.get("clutch", "") == "burned" and r.flags.get("fire", "") == "yes" and r.said_ids.has("l_gone"))
	else:
		check(P + "LEFT: SAVE THE RESEARCH: he carries the crate", r.flags.get("clutch", "") == "saved" and r.tagged("eggs").is_empty() and r.said_ids.has("l_crate")
			and String(r.tagged("lindqvist")[0].get_meta("mission_name", "")) == "Dr. Lindqvist (the crate)")
	_step(g, g.clock + 0.2)
	check(P + "then to the jetty", r.fired.has("research_done"))
	# ---- the people into the boats, the canoes
	var n0 := r.tagged("hands").size() + r.tagged("folk").size()
	_put(g, r.tagged("hands"), r.area_rect("jetty"))
	_put(g, r.tagged("folk"), r.area_rect("beach"))
	_step(g, g.clock + 0.5)
	check(P + "the hands and the villagers into the boats: counted", int(r.counters["saved"]) >= n0 and r.tagged("hands").is_empty() and r.tagged("folk").is_empty(), str(r.counters["saved"]))
	_put(g, r.tagged("lindqvist") + r.tagged("valadares"), r.area_rect("jetty"))
	_step(g, g.clock + 0.5)
	_step(g, g.clock + 0.5)
	check(P + "THE CANOES: Lindqvist and Valadares aboard", int(r.counters["heroes"]) == 2 and r.fired.has("canoes") and r.said_ids.has("n_leave"))
	check(P + "the mission is not over yet (she is not home)", not g.over)
	# ---- HOME
	_put(g, [sire, lin], r.area_rect("den"))
	_step(g, g.clock + 0.5)
	_step(g, g.clock + 0.5)
	check(P + "SHE IS HOME: the last step done", r.obj["home"] == "done" and r.fired.has("home") and r.light_name == "grey_dawn")
	check(P + "the flags", r.flags.get("teles", "") == "quiet" and r.flags.get("pieter", "") == "alive" and r.flags.get("rival", "") == "standing"
		and r.flags.get("turtle", "") in ["early", "late"] and r.flags.get("clutch", "") == ("saved" if eggs == "left" else "burned") and r.flags.has("saved")
		and int(r.flags.get("saved_n", -1)) == int(r.counters["saved"]), str(r.flags))
	_step(g, g.clock + 6.5)
	check(P + "the end: the Sire's pack wins", g.over and r.winner_side == "sire")
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
		var wl: Array = ["l_end1", "l_end_saved" if eggs == "left" else "l_end_fire", "l_end_pieter", "l_end_two", "l_end_north", "l_end2", "k_end1", "k_end2",
			"k_end_saved" if eggs == "left" else "k_end_taken"]
		check(P + "the ending's lines by the flags", show.shown_ids == wl, str(show.shown_ids))
	for i in 3:
		await process_frame
	var ep := _end_panel()
	check(P + "the end screen", ep != null)
	if ep:
		var ls := _labels(ep)
		check(P + "it says VICTORY and SHE IS HOME", ls.has("VICTORY") and ls.has("She is home"), str(ls.slice(0, 3)))
		check(P + "the debrief's lines by the flags", ls.any(func(s): return s.contains("carried her clutch home" if eggs == "taken" else "carried it out of the fire")))
		check(P + "the men counted on it", ls.any(func(s): return s.contains("%d of %d" % [int(r.counters["saved"]), int(r.counters["people"])])))
	var p := Campaign.progress()
	check(P + "it counts: the mission is done", (p["done"] as Dictionary).has(MID))
	check(P + "the flags are kept for later missions", Campaign.flag(MID, "teles") == "quiet" and Campaign.flag(MID, "clutch") == ("saved" if eggs == "left" else "burned")
		and Campaign.flag(MID, "eggs") == eggs)


func _defeats() -> void:
	# the Sire killed
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	var g := await _start()
	var r: MissionRun = g.mission
	_step(g, 30.0)
	_kill(r, "sire")
	_step(g, 31.0)
	check("the Sire killed: the mission is lost (the rival pack's)", g.over and r.winner_side == "rival" and r.obj["sire"] == "failed" and r.obj["r_kill"] == "done")
	await create_timer(1.8).timeout
	var ep := _end_panel()
	check("...the end screen says DEFEAT", ep != null and _labels(ep).has("DEFEAT"))
	check("...and it does not count", not (Campaign.progress()["done"] as Dictionary).has(MID))
	# the Old Mother killed
	g = await _start()
	r = g.mission
	_step(g, 30.0)
	_kill(r, "old_mother")
	_step(g, 31.0)
	check("the Old Mother killed: the mission is lost", g.over and r.winner_side == "rival" and r.obj["mother"] == "failed")


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
