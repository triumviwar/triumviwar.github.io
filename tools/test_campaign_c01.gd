extends SceneTree
## The Clockwork prologue, "The Thirteenth Hour" (docs/campaign_c01_build.md), and the engine it needed:
##   - the data checks out, every text has pt and es, the seats for solo / co-op / versus, the storyline opens after the
##     Crown's prologue and lists c01, the stills and the sounds load;
##   - the ENGINE, each feature on its own: counters and their words in an objective, an exit area that counts, a countdown
##     ("clock", moved, read by "clock_out" / "clock_left", shown in the panel), a repeating trigger ("every", "times"),
##     `convert` with its warning, the roster (`deny`, `unlock`; Game.can_train / requirement_text), `sound`, `name`,
##     `tally`, the "hunt" order, "netted", the winter lights and the snow, "manual_end", the story loss's banner, lines with
##     an "if" in an ending, the debrief's "text_if", the hub after a mission ("after", "requires", "until");
##   - THE MISSION played through, both ways of each choice: run A (bells RUNG, gate PEOPLE: Jakob fetched the drawings),
##     run B (bells QUIET, gate PATTERN), run C (no drawings: the gate is PEOPLE by default; Jakob lost); each part's
##     beats (the order, the gift, the mill found, the children turning red, the mill seed, night, the countdown, the
##     townsfolk out of the gate and counted, the seeds and the links putting the stroke back, the stroke with Hollweg at
##     the gate); the story's loss counts (progress, flags, NUREMBERG IS LOST on the end screen, the ending's if-lines);
##     the clockmaker hub after it; and the two real defeats (Hollweg killed; Hollweg trapped inside at the stroke).
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_c01.gd
## Prints CHECK lines, then "campaign_c01: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "c01_thirteenth"
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
	print("campaign_c01: %d failures" % fails)
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
	return main.game


## The clock moved to `to` and one round of the mission's checks (as its 0.25 s tick does).
func _step(g: Game, to: float) -> void:
	g.clock = to
	var r := g.mission
	r._tick_turning()
	r._tick_exits()
	if not r.choice_open.is_empty() and g.clock >= float(r.choice_open.get("until", INF)):
		r.choose(String(r.choice_open["id"]), String(r.choice_open.get("default", "")))
	r._run_triggers()
	r._check_objectives()


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


func _end_panel() -> Node:
	return main.ui_layer.find_child("MissionEnd", true, false)


func _labels(n: Node) -> Array:
	var out: Array = []
	for c in n.find_children("*", "Label", true, false):
		out.append(String((c as Label).text))
	return out


func _run() -> void:
	await process_frame
	_data()
	await _engine()
	await _play("A", "rung", "people", true)
	await _play("B", "quiet", "pattern", true)
	await _play("C", "quiet", "", false)
	await _defeats()
	await _hub_after()
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("c01_thirteenth: data checks out", pr.is_empty(), "; ".join(pr))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + ["Not in this mission.", "Jakob (the drawings)"]:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Clockwork storyline's first mission is c01", String(sl.get("id", "")) == "clockmaker" and (sl["missions"] as Array) == [MID])
	check("it opens after the Crown's prologue", String(sl.get("requires", "")) == "p01_leaf")
	var c := Campaign.make_cfg(MID, "solo")
	check("solo: you are the guild; the Watch, the town and the machine are scripted", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "script"])
	c = Campaign.make_cfg(MID, "coop", "p1", true)
	check("co-op online: the friend is the Watch", c["slots"].map(func(s): return s["who"]) == ["you", "remote", "script", "script"])
	c = Campaign.make_cfg(MID, "versus", "p1", true)
	check("versus online: the friend is the machine", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "remote"])
	check("the guild BLUE, the machine RED, both Clockwork", int(c["slots"][0]["colour"]) == 0 and int(c["slots"][3]["colour"]) == 1
		and c["slots"][0]["faction"] == "clockwork" and c["slots"][3]["faction"] == "clockwork")
	check("the map is the Nuremberg map, in snow", String(m["map"]) == "campaign:nuremberg_advent" and String(Campaign.map_data("nuremberg_advent").get("biome", "")) == "snow")
	for k in m["stills"]:
		check("still %s: its picture loads" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	check("the bells and the off-beat tick are in", ResourceLoader.exists("res://assets/audio/campaign/bell_toll.wav") and ResourceLoader.exists("res://assets/audio/campaign/off_beat.wav"))
	check("the voice folder is c01 (no recordings yet: silent)", String(m.get("voice", "")) == "c01" and CampaignVoice.path_of(m, "h_open1") == "")
	check("campaign roles: citizen, hollweg, jakob, ferrer", ["citizen", "hollweg", "jakob", "ferrer"].all(func(r): return Defs.UNITS.has(String(Rebels.role(r).get("kind", "")))))


# ================================================================== the engine, feature by feature

func _engine() -> void:
	var g := await _start()
	var r: MissionRun = g.mission
	var gt := r.team_index("guild")
	var mt := r.team_index("machine")
	check("no computer player (everything but the guild is scripted)", g.ais.is_empty())
	check("winter day light at the start", r.light_name == "winter_day" and r.light_node != null)
	check("the Perpetual is the guild's Clocktower, tagged", r.tagged("perpetual").size() == 1 and r.tagged("perpetual")[0].kind == "clocktower")
	check("Hollweg and Jakob are the guild's, named", r.tagged("hollweg")[0].team == gt and String(r.tagged("hollweg")[0].get_meta("mission_name", "")) == "Meister Hollweg"
		and String(r.tagged("jakob")[0].get_meta("mission_name", "")) == "Jakob")
	check("Father Ferrer is the town's", r.tagged("ferrer")[0].team == r.team_index("town"))
	check("manual_end: the order done does not end the mission", bool(r.data.get("manual_end", false)))
	# ---- the roster
	var hall: Building = r.tagged("perpetual")[0]
	check("roster: no Heavy Works for the guild", g.requirement_text(gt, "heavy_works") == "Not in this mission.")
	check("roster: no Clock Aviary", g.requirement_text(gt, "cuckoo_house") == "Not in this mission.")
	check("roster: the Light Works is allowed", g.requirement_text(gt, "movement_works") == "")
	check("roster: the machine is not limited", g.requirement_text(mt, "heavy_works") != "Not in this mission.")
	r.act({"unlock": {"team": "guild", "kind": "heavy_works"}})
	check("unlock: the Heavy Works may be built again", not r.denied(gt, "heavy_works"))
	r.act({"deny": {"team": "guild", "kind": "heavy_works"}})
	check("deny: and taken away again", r.denied(gt, "heavy_works"))
	check("a denied unit can't be trained (Game.can_train)", r.denied(gt, "pendulum"))
	# ---- counters, exits and their words
	check("counters start at 0", int(r.counters["saved"]) == 0 and int(r.counters["townsfolk"]) == 0)
	r.act({"counter": {"name": "townsfolk", "add": 5}})
	var folk: Array = r._spawn({"team": "town", "kind": "labourer", "as": "citizen", "count": 3, "at": "road_w", "tag": "folk"})
	check("a citizen is a Labourer stand-in of the town", folk.size() == 3 and folk[0].kind == "labourer" and String(folk[0].get_meta("rebel_role", "")) == "citizen")
	_put(g, folk.slice(0, 2), r.area_rect("out_west"))
	r._tick_exits()
	check("an exit takes the townsfolk off the map and counts them", int(r.counters["saved"]) == 2 and r.tagged("folk").size() == 1, str(r.counters))
	var o := r.objective("people")
	check("an objective's words with the counters in", r.objective_text(o) == "Get the townsfolk out of the west gate: 2 saved of 5.", r.objective_text(o))
	r.act({"counter": {"name": "saved", "set": 30}})
	check("counter condition", r.cond({"counter": {"name": "saved", "at_least": 30}}) and not r.cond({"counter": {"name": "saved", "below": 30}}))
	r.act({"tally": {"flag": "saved", "counter": "saved", "bands": [[0, "few"], [25, "some"], [60, "many"]]}})
	check("tally: a flag from a counter (30 -> some), and the number", r.flags.get("saved", "") == "some" and int(r.flags.get("saved_n", 0)) == 30)
	r.flags.clear()
	r.counters["saved"] = 0
	r.counters["townsfolk"] = 0
	# ---- a countdown
	g.clock = 100.0
	r.act({"clock": {"name": "fall", "secs": 300}})
	check("a countdown runs", r.clocks.has("fall") and not r.cond({"clock_out": "fall"}))
	r.set_objective("fall", "active")
	check("the countdown in the objective's words", r.objective_text(r.objective("fall")).ends_with("in 5:00."), r.objective_text(r.objective("fall")))
	r.act({"clock": {"name": "fall", "add": 60}})
	check("pushed back a minute", is_equal_approx(float(r.clocks["fall"]), 460.0))
	g.clock = 400.0
	check("clock_left below 90", r.cond({"clock_left": {"name": "fall", "below": 90}}) and not r.cond({"clock_left": {"name": "fall", "below": 50}}))
	g.clock = 461.0
	check("clock_out when its time has come", r.cond({"clock_out": "fall"}))
	r._check_objectives()
	check("the countdown objective is ticked when out, and never ends the mission", r.obj["fall"] == "done" and not g.over)
	r.clocks.clear()
	r.obj["fall"] = "hidden"
	# ---- a repeating trigger
	var rep := {"id": "rep_test", "when": {"time": 1}, "every": 10, "times": 3, "do": [{"counter": {"name": "seeds", "add": 1}}]}
	(r.data["triggers"] as Array).append(rep)
	g.clock = 470.0
	r._run_triggers()
	r._run_triggers()
	check("every: fires once, then waits", int(r.counters["seeds"]) == 1)
	g.clock = 480.5
	r._run_triggers()
	g.clock = 491.0
	r._run_triggers()
	g.clock = 502.0
	r._run_triggers()
	check("every: again each 10 s, at most 3 times", int(r.counters["seeds"]) == 3, str(r.counters["seeds"]))
	(r.data["triggers"] as Array).erase(rep)
	r.counters["seeds"] = 0
	# ---- convert (with its warning)
	var kids: Array = r._spawn({"team": "guild", "kind": "winder", "count": 2, "at": "yard", "tag": "conv_test"})
	g.set_selection(kids)
	r.act({"convert": {"tag": "conv_test", "to": "machine", "warn": 5, "as": "conv_turned"}})
	check("convert: a warning first (stunned, still the guild's)", kids.all(func(u): return u.team == gt and u.stun_t > 4.0))
	g.clock += 5.5
	r._tick_turning()
	check("convert: then the machine's, out of the selection, re-tagged", kids.all(func(u): return u.team == mt) and g.selection.is_empty() and r.tagged("conv_turned").size() == 2)
	check("convert: in the machine's colour", kids[0].cloth_colour() == g.team_colour(mt))
	for u in kids:
		u.die()
	# ---- the hunt
	var hunter: Array = r._spawn({"team": "machine", "kind": "clock_soldier", "count": 1, "at": "road_w", "tag": "hunt_test"})
	r.act({"order": {"tag": "hunt_test", "do": "hunt", "prey": "folk", "within": 30}})
	check("hunt: a machine goes for the nearest townsman", hunter[0].target != null and r.tagged("folk").has(hunter[0].target))
	hunter[0].die()
	_kill(r, "folk")
	# ---- netted
	var caught: Array = r._spawn({"team": "machine", "kind": "clock_soldier", "count": 1, "at": "market", "tag": "net_test"})
	check("netted: not yet", not r.cond({"netted": {"team": "machine"}}))
	caught[0].net_t = 3.0
	check("netted: a machine in a net", r.cond({"netted": {"team": "machine"}}))
	caught[0].die()
	# ---- name, sound, weather, lights
	r.act({"name": {"tag": "jakob", "name": "Jakob (the drawings)"}})
	check("name: over Jakob's bar", String(r.tagged("jakob")[0].get_meta("mission_name", "")) == "Jakob (the drawings)")
	r.act({"name": {"tag": "jakob", "name": "Jakob"}})
	r.act({"sound": {"name": "campaign/bell_toll"}})
	check("sound: plays without error (headless: nothing heard)", true)
	check("the winter lights", MissionRun.LIGHTS.has("winter_dusk") and MissionRun.LIGHTS.has("winter_night") and MissionRun.LIGHTS["winter_night"].b > MissionRun.LIGHTS["winter_night"].r)
	r.set_light("winter_night", 0.0)
	check("night falls", r.light_name == "winter_night" and r.light_node.color.is_equal_approx(MissionRun.LIGHTS["winter_night"]))
	check("snow is asked for (drawn only with a window)", String(r.data.get("weather", "")) == "snow")
	# ---- the ending's lines by flag
	var pages := r.pages_now(Campaign.show_pages(r.data, "ending", "guild"))
	check("ending: with no flags only the plain lines", (pages[0]["lines"] as Array) == ["h_end1"], str(pages[0]["lines"]))
	r.flags["gate"] = "pattern"
	r.flags["jakob"] = "lost"
	pages = r.pages_now(Campaign.show_pages(r.data, "ending", "guild"))
	check("ending: the pattern and Jakob lost", (pages[0]["lines"] as Array) == ["h_end1", "h_end_pattern", "h_end_nojakob"], str(pages[0]["lines"]))
	r.flags.clear()


# ================================================================== the mission, played through

## One run through the three parts. bells: "rung" / "quiet"; gate: "people" / "pattern" ("" = Jakob never fetches the
## drawings and dies, so the gate is people by default).
func _play(run: String, bells: String, gate: String, drawings: bool) -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	var g := await _start()
	var r: MissionRun = g.mission
	var gt := r.team_index("guild")
	var mt := r.team_index("machine")
	var P := "run %s (%s, %s): " % [run, bells, gate if gate != "" else "no drawings"]
	_step(g, 2.0)
	check(P + "the intro lines", r.said_ids.slice(0, 3) == ["h_1", "f_1", "tip_1"], str(r.said_ids))
	check(P + "objectives: the order and Hollweg", r.objectives_for("guild").map(func(o): return o["id"]) == ["order", "hollweg"])
	# ---------------------------------------------------------------- PART 1: the order and the gift
	var cs: Array = r._spawn({"team": "guild", "kind": "clock_soldier", "count": 2, "at": "yard"})
	var six: Array = r.tagged("guard") + cs
	_put(g, six, r.area_rect("wagons"))
	_step(g, 120.0)
	_step(g, 120.5)
	check(P + "six Clock Soldiers at the wagons: the order is filled", r.obj["order"] == "done" and r.fired.has("order_done") and not g.over)
	_step(g, 121.0)
	check(P + "the six are handed over to the Watch", six.all(func(u): return u.team == r.team_index("watch")), str(six.map(func(u): return u.team)))
	check(P + "the Crown pays", int(g.players[gt]["gold"]) >= 600)
	_step(g, 240.5)
	check(P + "THE GIFT: the Perpetual raises Winders by itself", r.fired.has("gift") and r.tagged("children").size() == 2 and r.tagged("children")[0].team == gt)
	for t in [256.0, 271.0, 286.0, 301.0]:
		_step(g, t)
	check(P + "the gift goes on: 8 children, the guild's", r.tagged("children").size() == 8 and r.tagged("children").all(func(u): return u.team == gt), str(r.tagged("children").size()))
	_step(g, 311.0)
	check(P + "a child faces the river (Jakob)", r.said_ids.has("j_odd"))
	# ---------------------------------------------------------------- PART 2: dusk, the mill island
	_step(g, 312.0)
	_step(g, 322.0)
	check(P + "dusk: the light turns", r.fired.has("dusk") and r.light_name == "winter_dusk")
	check(P + "seeds on the mill island and at the bath houses (red)", r.tagged("seed_mill").size() == 1 and r.tagged("seed_baths").size() == 1 and r.tagged("seed_mill")[0].team == mt)
	check(P + "three links on the bridges", r.tagged("links").size() == 3)
	check(P + "a Netter given", r.tagged("netter").size() == 1 and r.tagged("netter")[0].team == gt)
	check(P + "go and look", r.obj["look"] == "active")
	_put(g, r.tagged("jakob"), r.area_rect("mill_bank"))
	_step(g, 330.0)
	_step(g, 330.5)
	check(P + "found: too late, a whole works", r.fired.has("found") and r.obj["look"] == "done" and r.obj["mill"] == "active" and r.said_ids.has("h_found"))
	_step(g, 338.5)
	check(P + "the turn: the children stutter first", r.fired.has("turn") and r.tagged("children").all(func(u): return u.team == gt and u.stun_t > 0.0))
	_step(g, 344.0)
	check(P + "the turn: the children are the machine's now", r.tagged("children").all(func(u): return u.team == mt) and r.tagged("turned").size() == 8)
	check(P + "...but never the units the player made", r.tagged("netter")[0].team == gt and r.tagged("hollweg")[0].team == gt)
	_step(g, 345.0)
	check(P + "the turned go for the workshop", r.fired.has("turned_go"))
	r.tagged("mill_guard")[0].net_t = 3.0
	_step(g, 346.0)
	check(P + "a red machine in a net: caught", r.obj["catch"] == "done" and r.said_ids.has("h_net"))
	_step(g, 355.0)
	check(P + "THE BELLS: the choice is offered", String(r.choice_open.get("id", "")) == "bells")
	await process_frame
	var ui: MissionUi = null
	for n in main.ui_layer.get_children():
		if n is MissionUi:
			ui = n
	check(P + "the choice panel's buttons", ui != null and ui.find_child("Choose_rung", true, false) != null and ui.find_child("Choose_quiet", true, false) != null)
	ui.pick_choice("bells", bells)
	check(P + "the bells: " + bells, r.flags.get("bells", "") == bells)
	if bells == "rung":
		check(P + "RUNG: the Watch comes in force", r.tagged("watch_w").size() == 8 and r.tagged("watch_m").size() == 7)
	else:
		check(P + "QUIET: the Pendulum and Tension for the guild", r.tagged("showpiece").size() == 1 and g.tension(gt) >= 150.0)
	_step(g, 400.0)
	check(P + "the seeds grow while they live", r.tagged("mach_mill_grow").size() >= 2 and r.tagged("mach_baths_grow").size() >= 2)
	_kill(r, "seed_mill")
	_step(g, 401.0)
	check(P + "the mill seed burnt: a small win", r.obj["mill"] == "done" and r.said_ids.has("h_mill_down"))
	_step(g, 405.0)
	check(P + "night falls: seeds at the market and the east gate", r.fired.has("night") and r.tagged("seed_market").size() == 1 and r.tagged("seed_east").size() == 1)
	# ---------------------------------------------------------------- PART 3: the thirteenth hour
	_step(g, 418.0)
	check(P + "PART 3: told plainly, with the countdown", r.fired.has("lost") and r.said_ids.has("h_lost") and r.obj["fall"] == "active" and r.clocks.has("fall"))
	var lost_t := float(r.fired["lost"])
	check(P + "the fall in 9:00", is_equal_approx(float(r.clocks["fall"]), lost_t + 540.0))
	check(P + "the panel shows the time left", r.objective_text(r.objective("fall")).ends_with("in 9:00."), r.objective_text(r.objective("fall")))
	check(P + "the part 1-2 objectives leave the panel", not r.objectives_for("guild").map(func(o): return o["id"]).has("look"))
	check(P + "part 3's objectives", ["fall", "out", "people", "cut", "jakob", "drawings"].all(func(k): return r.obj[k] == "active"))
	if bells == "rung":
		check(P + "RUNG: the city already on the road (20 townsfolk)", r.tagged("folk").size() == 20 and int(r.counters["townsfolk"]) == 20)
	else:
		check(P + "QUIET: nobody on the road yet", r.tagged("folk").is_empty())
	_step(g, lost_t + 120.0)
	var out_n := r.tagged("folk").size()
	check(P + "townsfolk come out of the houses", int(r.counters["townsfolk"]) > (20 if bells == "rung" else 0) and out_n > 0)
	check(P + "...and walk to the west gate", r.tagged("folk").all(func(u): return u.order == "move"))
	_put(g, r.tagged("folk"), r.area_rect("out_west"))
	_step(g, lost_t + 121.0)
	check(P + "out of the gate: counted as saved", int(r.counters["saved"]) == out_n and r.tagged("folk").is_empty(), str(r.counters))
	check(P + "the hunt is on", r.fired.has("hunt"))
	# the seeds and the links put the stroke back
	var t0 := float(r.clocks["fall"])
	_kill(r, "seed_baths")
	_step(g, lost_t + 122.0)
	check(P + "a seed burnt: the stroke a minute later", is_equal_approx(float(r.clocks["fall"]), t0 + 60.0))
	_kill(r, "links")
	_step(g, lost_t + 123.0)
	_step(g, lost_t + 123.5)
	check(P + "the links cut: 90 s more, the cut done", r.obj["cut"] == "done" and is_equal_approx(float(r.clocks["fall"]), t0 + 150.0))
	# Jakob and the drawings
	if drawings:
		_put(g, r.tagged("jakob"), r.area_rect("guildhouse"))
		_step(g, lost_t + 125.0)
		check(P + "Jakob has the drawings", r.obj["drawings"] == "done" and r.flags.get("drawings", "") == "taken"
			and String(r.tagged("jakob")[0].get_meta("mission_name", "")) == "Jakob (the drawings)")
	else:
		_kill(r, "jakob")
		_step(g, lost_t + 125.0)
		check(P + "Jakob is lost", r.obj["jakob"] == "failed" and r.said_ids.has("h_jakob") and not g.over)
	# the last minutes
	var fall := float(r.clocks["fall"])
	_step(g, fall - 119.0)
	check(P + "two minutes left: Ferrer warns", r.said_ids.has("f_warn"))
	_step(g, fall - 74.0)
	if drawings:
		check(P + "THE GATE: the choice is offered", String(r.choice_open.get("id", "")) == "gate")
		await process_frame
		ui.pick_choice("gate", gate)
		check(P + "the gate: " + gate, r.flags.get("gate", "") == gate)
		if gate == "people":
			check(P + "PEOPLE: the last townsfolk at the gate", r.said_ids.has("h_people") and String(r.tagged("jakob")[0].get_meta("mission_name", "")) == "Jakob")
	else:
		check(P + "no drawings: no choice, the drawings burn", r.choice_open.is_empty() and r.flags.get("gate", "") == "people")
	_put(g, r.tagged("hollweg"), r.area_rect("gate_in"))
	var saved_before := int(r.counters["saved"])
	_put(g, r.tagged("folk"), r.area_rect("out_west"))
	_step(g, fall - 70.0)
	check(P + "the last of them out", int(r.counters["saved"]) >= saved_before)
	_step(g, fall + 0.1)
	check(P + "THE STROKE: Hollweg at the gate", r.fired.has("stroke") and r.said_ids.has("cap_13") and r.obj["hollweg"] == "done" and not g.over)
	check(P + "the saved tallied", r.flags.has("saved") and int(r.flags.get("saved_n", -1)) == int(r.counters["saved"]))
	check(P + "the flags: jakob " + ("alive" if drawings else "lost") + ", cut yes",
		r.flags.get("jakob", "") == ("alive" if drawings else "lost") and r.flags.get("cut", "") == "yes", str(r.flags))
	for i in 14:
		_step(g, fall + 0.1 + 1.25 * (i + 1))
	check(P + "the bells toll thirteen", int(r._times.get("toll", 0)) == 13, str(r._times.get("toll", 0)))
	_step(g, fall + 18.0)
	check(P + "the story's end: the guild 'wins' the mission", g.over and r.winner_side == "guild" and r.obj["out"] == "done")
	await create_timer(1.8).timeout
	# the ending's stills with the lines the flags allow, then the end screen
	var show: StillShow = null
	for n in main.ui_layer.get_children():
		if n is StillShow:
			show = n
	check(P + "the ending plays", show != null)
	if show:
		for i in 20:
			if is_instance_valid(show) and not show.is_queued_for_deletion():
				show.next()
		var want: Array = ["h_end1", "h_end_" + (gate if gate != "" else "people"), "h_end_jakob" if drawings else "h_end_nojakob", "h_end2", "k_end1", "k_end2"]
		check(P + "the ending's lines by the flags", show.shown_ids == want, str(show.shown_ids))
	for i in 3:
		await process_frame
	var ep := _end_panel()
	check(P + "the end screen", ep != null)
	if ep:
		var ls := _labels(ep)
		check(P + "it says NUREMBERG IS LOST, not VICTORY", ls.has("NUREMBERG IS LOST") and not ls.has("VICTORY"), str(ls.slice(0, 2)))
		check(P + "the debrief's lines by the flags", ls.any(func(s): return s.contains("The bells were " + ("rung" if bells == "rung" else "kept quiet"))))
		check(P + "the townsfolk counted on it", ls.any(func(s): return s.contains("%d of %d" % [int(r.counters["saved"]), int(r.counters["townsfolk"])])))
		check(P + "no countdown in its objective list", not ls.any(func(s): return s.contains("strikes thirteen in")))
	var p := Campaign.progress()
	check(P + "the story's loss COUNTS: the mission is done", (p["done"] as Dictionary).has(MID))
	check(P + "the flags are kept for later missions", Campaign.flag(MID, "bells") == bells and Campaign.flag(MID, "gate") == (gate if gate != "" else "people")
		and Campaign.flag(MID, "cut") == "yes")


func _defeats() -> void:
	# Hollweg killed: the one real loss (retry)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	var g := await _start()
	var r: MissionRun = g.mission
	_step(g, 30.0)
	_kill(r, "hollweg")
	_step(g, 31.0)
	check("Hollweg killed: the mission is lost", g.over and r.winner_side == "machine" and r.obj["hollweg"] == "failed")
	await create_timer(1.8).timeout
	var ep := _end_panel()
	check("...the end screen says DEFEAT", ep != null and _labels(ep).has("DEFEAT"))
	check("...and it does not count", not (Campaign.progress()["done"] as Dictionary).has(MID))
	# trapped at the stroke
	g = await _start()
	r = g.mission
	for tr in r.data["triggers"]:
		if String(tr["id"]) in ["dusk", "night"]:
			r.fire(tr)
	g.clock = 500.0
	r.act({"clock": {"name": "part3", "stop": true}})
	r.act({"clock": {"name": "part3", "secs": 1}})
	_step(g, 502.0)
	check("trapped: part 3 started", r.fired.has("lost"))
	_put(g, r.tagged("hollweg"), r.area_rect("yard"))
	_step(g, float(r.clocks["fall"]) + 0.1)
	_step(g, float(r.clocks["fall"]) + 1.0)
	check("Hollweg inside the walls at the stroke: lost", g.over and r.winner_side == "machine" and r.obj["out"] == "failed" and r.said_ids.has("cap_trapped"))


func _hub_after() -> void:
	main._to_menu()
	await process_frame
	var sl := Campaign.storyline_of(MID)
	var before := CampaignMenu.hub_now(sl["hub"], {"done": {}})
	check("hub before: Hollweg's Workshop, Hollweg in it", String(before["title"]) == "Hollweg's Workshop" and (before["hotspots"] as Array).any(func(h): return h["id"] == "hollweg")
		and not (before["hotspots"] as Array).any(func(h): return h["id"] == "letter"))
	var after := CampaignMenu.hub_now(sl["hub"], {"done": {MID: {}}})
	check("hub after: the machine's city, Hollweg gone, his letter", String(after["title"]) == "Nuremberg, the Machine's City" and (after["hide_layers"] as Array).has("hollweg")
		and not (after["hotspots"] as Array).any(func(h): return h["id"] == "hollweg") and (after["hotspots"] as Array).any(func(h): return h["id"] == "letter"))
	var tk: Dictionary = sl["hub"]["talks"]["clock"]
	check("the great clock's talk after c01", String(CampaignMenu.talk_lines(tk, {"done": {MID: {}}})[0]).contains("thirteen"))
	var king: Dictionary = Campaign.storylines()[0]["hub"]
	check("the King's study after c01: Hollweg in exile there", (CampaignMenu.hub_now(king, {"done": {MID: {}}})["hotspots"] as Array).any(func(h): return h["id"] == "hollweg_exile")
		and not (CampaignMenu.hub_now(king, {"done": {}})["hotspots"] as Array).any(func(h): return h["id"] == "hollweg_exile"))
	# the page itself, opened on the clockmaker storyline with c01 done
	Campaign.save_progress({"reached": [], "done": {"p01_leaf": {}, MID: {}}})
	CampaignMenu.line = "clockmaker"
	CampaignMenu.show(main)
	await process_frame
	await process_frame
	var hs: HubScene = main.find_child("HubScene", true, false).get_child(0) as HubScene if main.find_child("HubScene", true, false) else null
	check("the hub page: the painting without Hollweg", hs != null and hs.hidden_layers.has("hollweg"))
	check("the hub page: HOLLWEG'S LETTER listed", main.find_child("HotspotList_letter", true, false) != null and main.find_child("HotspotList_hollweg", true, false) == null)
