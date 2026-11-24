extends SceneTree
## Act 2's "The Mission of São Rafael" (docs/campaign_d05_build.md):
##   - the data checks out, every text has pt and es, the Crown line lists it after d01 and it opens once d01 is won,
##     the seats (solo the mission, the SOLO PICK of the swarm, versus), the map (the várzea) and the stills, THE ROSTER
##     LADDER's C6 (the Dragoon and the Cavalry Charge), THE BROOD IS NOT A PERSON in the texts;
##   - THE VÁRZEA: a Musketeer wades a ford cell at half pace, a Raptor does not; nothing is built in it;
##   - THE FLAGS at the start: a07 `people` many (two more militia), d06 `brood_n` (the waves' size), d01 `gold` few (a
##     smaller relief), every flag missing (the canon);
##   - PART 1: the bell, a soldier at a field sends its people to the church, the waves, everyone in: dawn soon after;
##   - PART 2: the relief (Dragoons and Horsemen on the player's team), the hamlet freed and its people back, the flyers, the
##     Charge's objective, the granary feeding its holder;
##   - PART 3: the people follow Tomasz, the forward Mother roots, THE FIELDS choice (burned: the fire; left: the canon by
##     default), the column at the fort: the win and its flags (`aldeia`, `fields`, `forward`); all people lost: lost; the
##     church broken before the road: lost;
##   - THE MIRROR (the swarm): the people caught over half: won; the column at the fort: lost;
##   - SAVE AND LOAD in Part 2, IRONMAN, the HUB and the WAR MAP after d05; no script error anywhere.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_d05.gd [-- only=data,varzea,flags,part1,...]
## Prints CHECK lines, then "campaign_d05: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "d05_aldeia"
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
	print("campaign_d05: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if a05, a07, d01 and d06 were won with these flags (each merged over its canon).
func _progress(a07 := {}, d01 := {}, d06 := {}, a05 := {}, diff := "normal", with_d01 := true, none := false) -> void:
	var p := {"reached": [MID], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	var f7 := {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}
	f7.merge(a07, true)
	p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": f7}
	if not none:
		var f5 := {"cages": "some", "cages_n": 2, "eggs": "taken", "pieter": "alive", "way": "short", "crates": "seen"}
		f5.merge(a05, true)
		p["done"]["a05_specimens"] = {"won_by": "expedition", "side": "expedition", "flags": f5}
		var f6 := {"brood_n": "some", "pieter": "alive", "lindqvist": "fled", "book": "left", "queen": "grown"}
		f6.merge(d06, true)
		p["done"]["d06_queen"] = {"won_by": "brood", "side": "brood", "flags": f6}
	if with_d01:
		var f1 := {"minas": "quiet", "gold": "some", "conspirator": "taken"}
		f1.merge(d01, true)
		p["done"]["d01_minas"] = {"won_by": "crown", "side": "crown", "flags": f1}
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
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	_step(g, 1.0)
	_step(g, 2.5)
	return g


## The clock moved to `to` and one round of the mission's checks (as its 0.25 s tick does, Act 2's pieces included).
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
			e.take_damage(99999.0, null)


## PART 1 done the quick way: every field's people in the churchyard, the waves killed (dawn comes at once).
func _to_part2(g: Game, r: MissionRun) -> void:
	_walk(g, maxf(g.clock, 4.0))
	_put(g, r.tagged("field_folk"), _mid(r, "church_yard"))
	_walk(g, maxf(g.clock, 101.0))
	for i in 8:
		_kill(r.tagged("wave"))
		_walk(g, g.clock + 2.0)
		if r.fired.has("part2"):
			break


## PART 2 done the quick way: the hamlet's pack killed, a soldier at the hamlet, its people walked into the churchyard.
func _to_part3(g: Game, r: MissionRun) -> void:
	_walk(g, float(r.fired.get("part2", g.clock)) + 2.0)
	_kill(r.tagged("hamlet_pack"))
	_walk(g, g.clock + 1.0)
	_put(g, r.tagged("militia").slice(0, 1), _mid(r, "hamlet_in") + Vector2(0, 3 * Defs.TILE))
	_walk(g, g.clock + 1.0)
	_put(g, r.tagged("hamlet_folk"), _mid(r, "church_yard"))
	_walk(g, g.clock + 6.0)


# ================================================================== run

func _run() -> void:
	await process_frame
	var only := ""
	for a in OS.get_cmdline_user_args():
		if String(a).begins_with("only="):
			only = String(a).substr(5)
	var want := func(n: String) -> bool: return only == "" or only.split(",").has(n)
	if want.call("data"): _data()
	if want.call("varzea"): await _varzea()
	if want.call("flags"): await _flags()
	if want.call("part1"): await _part1()
	if want.call("part2"): await _part2()
	if want.call("part3"): await _part3()
	if want.call("defeat"): await _defeat()
	if want.call("mirror"): await _mirror()
	if want.call("save"): await _save_load()
	if want.call("ironman"): await _ironman()
	if want.call("hubs"): _hubs()
	check("no script error in the whole run", _errs.is_empty(), str(_errs.slice(0, 3)))
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("d05_aldeia: data checks out", pr.is_empty(), "; ".join(pr))
	var extra := ["Father Tomasz", "Brother Tiago", "Captain Sobral", "The forward Mother", "Not in the flooded forest: nothing stands in the várzea's water."]
	for role in ["tomasz_rafael", "tiago", "mission_militia", "rafael_villager", "sobral", "forward_mother"]:
		extra.append(String(Rebels.ROLES[role]["about"]))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + extra:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission, its roles and the hub has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Crown line lists d05 after d01", String(sl.get("id", "")) == "prologue"
		and (sl["missions"] as Array).find(MID) == (sl["missions"] as Array).find("d01_minas") + 1)
	check("d01's next is d05 (both sides)", str(Campaign.mission("d01_minas")["next"]) == str({"crown": MID, "conspiracy": MID}))
	_progress({}, {}, {}, {}, "normal", false)
	var pp := Campaign.progress()
	pp["reached"] = []
	Campaign.save_progress(pp)
	check("d05 is shut until d01 is won", not Campaign.unlocked(MID))
	_progress()
	check("... and open once it is", Campaign.unlocked(MID))
	check("the seats: solo the mission, the SOLO PICK the swarm", Campaign.solo_sides(m) == ["crown", "swarm"])
	var c := Campaign.make_cfg(MID, "solo", "p1", false, "swarm")
	var you: Array = (c["slots"] as Array).filter(func(s): return String(s["who"]) == "you").map(func(s): return String(s["team_id"]))
	check("the swarm picked: the swarm's team is the player's", you == ["swarm"], str(you))
	check("versus: the mission p1, the swarm p2", Campaign.seat_side(m, "versus", "p1") == "crown" and Campaign.seat_side(m, "versus", "p2") == "swarm")
	var md := Campaign.map_data("sao_rafael")
	check("the map is the várzea: the flooded forest is shallow water", md.get("biome", "") == "varzea" and String(md.get("cells", "")).count("f") > 4000,
		str(String(md.get("cells", "")).count("f")))
	for k in m["stills"]:
		check("still %s is in" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	var tm: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "mission")[0]
	check("THE ROSTER LADDER C6: the DRAGOON and the CAVALRY CHARGE, both NEW", (tm["roster"]["allow"] as Array).has("dragoon")
		and (tm["roster"]["allow"] as Array).has("charge") and (tm["roster"]["new"] as Array) == ["dragoon", "charge"]
		and not (tm["roster"]["allow"] as Array).has("armour"))
	check("the militia carry the C5 kit (Matchlock, Socket Bayonet)", (tm.get("techs", []) as Array) == ["matchlock", "bayonet"])
	check("hubs-grow: d05 earns on the Crown line", (HubGrow.line("prologue")["earn"] as Array).has(MID))
	# THE BROOD IS NOT A PERSON: no creature named, no line giving one a will
	var all := " ".join(Campaign.strings_of(m))
	check("no creature named Linnea, no 'she wants' / 'her young' / 'comes for'", not all.contains("Linnea") and not all.contains("her young")
		and not all.contains("comes for") and not all.contains("wants"))
	var dash: Array = []
	for lid in m["lines"]:
		if String(m["lines"][lid]["text"]).contains(" - ") or String(m["lines"][lid]["text"]).contains("—"):
			dash.append(lid)
	check("no dashes in the spoken lines", dash.is_empty(), str(dash))


# ================================================================== THE VÁRZEA: wading, no building

func _varzea() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	check("the mission's wade rule is on (half pace, the Brood free)", is_equal_approx(r.wade, 0.5) and r.wade_free.has("brood"))
	# a ford cell in the north flood (open water, no tree) and a dry cell in the churchyard
	var fc := Vector2i(-1, -1)
	var fr := r.area_rect("flood_nw")
	for y in range(int(fr.position.y / Defs.TILE), int(fr.end.y / Defs.TILE)):
		for x in range(int(fr.position.x / Defs.TILE), int(fr.end.x / Defs.TILE)):
			if g.mapgen.ford[g.idx(Vector2i(x, y))] == 1 and g.solid[g.idx(Vector2i(x, y))] == 0:
				fc = Vector2i(x, y)
				break
		if fc.x >= 0:
			break
	check("a ford cell in the flood", fc.x >= 0)
	var at := (Vector2(fc) + Vector2(0.5, 0.5)) * Defs.TILE
	var mus: Unit = r.tagged("militia")[0]
	var dry: float = float(mus.d["speed"]) * mus.m_pace
	mus.position = at
	mus.cmd_stop()
	mus._tick_unit(0.016)
	check("a Musketeer in the flood wades at half pace", mus.speed < dry * 0.6 and mus.speed > dry * 0.4, "%.1f of %.1f" % [mus.speed, dry])
	var rp: Unit = g._add_unit("raptor", r.team_index("swarm"), at)
	rp._tick_unit(0.016)
	check("a Raptor in the flood keeps its pace (or more)", rp.speed >= float(rp.d["speed"]) * 0.99, "%.1f of %.1f" % [rp.speed, float(rp.d["speed"])])
	var why := g.placement_problem(g.human, "barracks", fc - Vector2i(1, 1))
	check("nothing is built in the flood", why.contains("flooded") or why == "Blocked." or why != "", why)
	rp.take_damage(99999.0, null)


# ================================================================== the flags at the start

func _flags() -> void:
	_progress({}, {}, {}, {}, "normal", true, true)
	var g: Game = await _start()
	var r := g.mission
	check("every earlier flag missing (a07, d01 only): the canon: 8 militia, 30 people", r.tagged("militia").size() == 8
		and int(r.counters["people_n"]) == 30, "%d %d" % [r.tagged("militia").size(), int(r.counters["people_n"])])
	check("the player plays the mission (purple) with Tomasz and Tiago", g.human == r.team_index("mission") and r.tagged("tomasz").size() == 1
		and r.tagged("tiago").size() == 1)
	check("the C5 kit drilled (Matchlock, Socket Bayonet)", g.players[g.human]["tech"].has("matchlock") and g.players[g.human]["tech"].has("bayonet"))
	_progress({"people": "many"}, {"minas": "restless", "conspirator": "fled"})
	g = await _start()
	r = g.mission
	check("a07 people many: two more militia", r.tagged("militia").size() == 10, str(r.tagged("militia").size()))
	var pages := str(r.pages_now(Campaign.show_pages(r.data, "opening", "crown")))
	check("the opening: the frontier trusted him (many), Minas restless, Ramos fled", pages.contains("t_open_many") and pages.contains("t_open_minas")
		and pages.contains("t_open_fled"))
	# d06 brood_n: the first wave's size
	var sizes := {}
	for bn in ["few", "some", "all"]:
		_progress({}, {}, {"brood_n": bn})
		g = await _start()
		r = g.mission
		_walk(g, 21.0)
		sizes[bn] = r.tagged("w1").size()
	check("d06 brood_n few / some / all: the waves smaller / as written / bigger", sizes["few"] < sizes["some"] and sizes["some"] < sizes["all"], str(sizes))
	# d01 gold few: the relief smaller
	_progress({}, {"gold": "few"})
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	var few_n := r.tagged("relief_men").size()
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	check("d01 gold few: a smaller relief (the Governor's purse thin)", few_n < r.tagged("relief_men").size(), "%d v %d" % [few_n, r.tagged("relief_men").size()])


# ================================================================== PART 1: the first night

func _part1() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 9.0)
	check("the NEW cards for C6 are said", _said(r, "new_dragoon") and _said(r, "new_charge"))
	check("the bell and the lesson (SAY IT PLAINLY)", _said(r, "t_bell") and _said(r, "n_lesson"))
	check("the objectives: the fields, dawn's clock, the church", r.obj.get("fields_in", "") == "active" and r.obj.get("night", "") == "active"
		and r.obj.get("church_live", "") == "active")
	var fw: Array = r.tagged("folk_w")
	var p0: Vector2 = fw[0].position
	_walk(g, 12.0)
	check("the west field's people stay out while nobody fetches them", fw[0].position.distance_to(p0) < 8.0 and not r.fired.has("call_field_w"))
	_put(g, r.tagged("militia").slice(0, 1), _mid(r, "field_w"))
	_walk(g, g.clock + 1.0)
	check("a soldier at the west field: its people run for the church", r.fired.has("call_field_w") and fw[0].order != "idle" and _said(r, "t_field"))
	_walk(g, 21.0)
	check("the first wave out of the flood at the west field", r.tagged("w1").size() >= 2 and _said(r, "n_w1"))
	_walk(g, 26.0)
	check("the várzea's rule said (SAY IT PLAINLY)", _said(r, "n_varzea"))
	_put(g, r.tagged("field_folk"), _mid(r, "church_yard"))
	_walk(g, g.clock + 3.0)
	check("everyone in: the fields' objective done", r.fired.has("all_in") and r.obj.get("fields_in", "") == "done" and int(r.counters["sheltered"]) == 18,
		str(r.counters["sheltered"]))
	_walk(g, 52.0)
	check("the push on the bluff comes soon after (NO WAITING)", r.fired.has("w_push") and _said(r, "n_push"))
	for i in 6:
		_kill(r.tagged("wave"))
		_walk(g, g.clock + 2.0)
	check("the waves beaten and everyone in: dawn at once, Part 2", r.fired.has("part2"), "clock %.0f" % g.clock)


# ================================================================== PART 2: the relief, the hamlet

func _part2() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_walk(g, g.clock + 2.0)
	var rel: Array = r.tagged("relief_men")
	check("the relief: the captain, Dragoons and Horsemen, on the player's team", rel.size() >= 7 and rel.all(func(u): return u.team == g.human)
		and rel.any(func(u): return u.kind == "dragoon") and rel.any(func(u): return u.kind == "cuirassier") and r.tagged("sobral").size() == 1)
	check("the hamlet's objective and its clock, the pack at Santa Luzia", r.obj.get("hamlet", "") == "active" and r.clocks.has("hamlet")
		and r.tagged("hamlet_pack").size() >= 3)
	check("the hamlet's people are shut in their chapel (untouchable)", r.tagged("hamlet_folk").all(func(u): return u.spared))
	_walk(g, g.clock + 26.0)
	check("the Charge's objective, the breeder pinged", r.obj.get("charge", "") == "active" and _said(r, "n_charge"))
	g.players[g.human]["tech"]["charge"] = true
	_walk(g, g.clock + 1.0)
	check("the Charge drilled: done", r.obj.get("charge", "") == "done")
	_walk(g, float(r.fired["part2"]) + 32.0)
	check("the flyers over the village, their objective", r.tagged("hatch").size() >= 2 and r.obj.get("hatch", "") == "active")
	# the granary feeds its holder: the mission now
	var gold0 := int(g.players[g.human]["gold"])
	_walk(g, g.clock + 11.0)
	check("the granary feeds the mission while it holds it", int(g.players[g.human]["gold"]) > gold0 or int(r.counters["fed"]) > 0)
	# the hamlet: a soldier there with the pack still in it: not yet
	_put(g, r.tagged("militia").slice(0, 1), _mid(r, "hamlet_in") + Vector2(0, 3 * Defs.TILE))
	_walk(g, g.clock + 1.0)
	check("a soldier at Santa Luzia with the pack still there: the people stay in", not r.fired.has("hamlet_free"))
	_kill(r.tagged("hamlet_pack"))
	_walk(g, g.clock + 1.5)
	check("the pack gone: the people come out and walk back, the line", r.fired.has("hamlet_free") and not r.tagged("hamlet_folk")[0].spared and _said(r, "n_free"))
	check("the flyers still circle: a flank wave at the causeway", r.fired.has("w_flank") or float(r.fired["hamlet_free"]) + 6.0 > g.clock)
	_put(g, r.tagged("hamlet_folk"), _mid(r, "church_yard"))
	_walk(g, g.clock + 6.0)
	check("the hamlet's people in: done, Part 3", r.obj.get("hamlet", "") in ["done", "hidden"] and r.fired.has("part3"))


# ================================================================== PART 3: the road

func _part3() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_to_part3(g, r)
	check("Part 3: the road's objective, the column's clock, the fort shown", r.obj.get("road", "") == "active" and r.clocks.has("column")
		and r.obj.get("church_live", "") == "done")
	check("the forward Mother roots on the mud bank with a Sire", r.tagged("fwd_mother").size() == 1 and r.tagged("fwd_sire").size() == 1)
	# the people follow Tomasz
	var tz: Unit = r.tagged("tomasz")[0]
	_put(g, [tz], _mid(r, "trail_2"))
	_walk(g, g.clock + 2.0)
	var pp: Unit = r.tagged("people")[0]
	check("the people follow Tomasz down the trail", pp.order != "idle" or pp.velocity.length() > 1.0, pp.order)
	_walk(g, float(r.fired["part3"]) + 17.0)
	check("THE FIELDS: the choice is asked (Sobral, Tomasz, Tiago)", _said(r, "c_burn") and r.fired.has("fields_ask"))
	# nobody answers: the default LEFT after its time
	_walk(g, g.clock + 62.0)
	check("unanswered: the fields LEFT (the canon)", str(r.flags.get("fields")) == "left", str(r.flags))
	_walk(g, float(r.fired["part3"]) + 14.0 + 26.0 * 2.0 + 1.0)
	check("the waves come at the column out of the flood", r.fired.has("w_road_0") and r.fired.has("w_road_1"))
	check("... the third bigger while the forward Mother lives and the fields feed them", r.tagged("w_road_2").size() > r.tagged("w_road_0").size() or r.tagged("w_road_2").size() >= 4,
		"%d v %d" % [r.tagged("w_road_2").size(), r.tagged("w_road_0").size()])
	_kill(r.tagged("fwd_mother"))
	_walk(g, g.clock + 1.0)
	check("the forward Mother killed: the objective, the line, the flag", r.obj.get("fwd", "") == "done" and str(r.flags.get("forward")) == "killed")
	# the column at the fort: all but four of them
	var ps: Array = r.tagged("people")
	_kill(ps.slice(0, 4))
	_put(g, ps.slice(4), _mid(r, "fort_in"))
	_walk(g, g.clock + 6.0)
	check("the column at the fort: WON for the mission", g.over and r.winner_side == "crown", "%s %s" % [g.over, r.winner_side])
	check("the flags: aldeia many, fields left, forward killed", str(r.flags.get("aldeia")) == "many" and str(r.flags.get("fields")) == "left"
		and str(r.flags.get("forward")) == "killed", str(r.flags))
	# BURN THEM: the fire takes the fields and the granary
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	_to_part3(g, r)
	_walk(g, float(r.fired["part3"]) + 17.0)
	r.choose("fields", "burned")
	_walk(g, g.clock + 40.0)
	check("BURN THEM: the flag, the line, the fields and the granary burned down", str(r.flags.get("fields")) == "burned" and _said(r, "t_burned")
		and r.tagged("fields_b").size() < 4, "%s %d" % [str(r.flags.get("fields")), r.tagged("fields_b").size()])
	# the clock out with a few at the fort: aldeia few
	var ps2: Array = r.tagged("people")
	_put(g, ps2.slice(0, 5), _mid(r, "fort_in"))
	_walk(g, g.clock + 1.0)
	r.clocks["column"] = g.clock + 0.5
	_walk(g, g.clock + 5.0)
	check("the fort's gate shut at dusk with five in: WON, aldeia few", g.over and r.winner_side == "crown" and str(r.flags.get("aldeia")) == "few", str(r.flags))


func _defeat() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 6.0)
	for c in r.tagged("church"):
		c.take_damage(999999.0, null)
	_walk(g, g.clock + 3.0)
	check("the church broken in the night: LOST", g.over and r.winner_side != "crown", "%s %s" % [g.over, r.winner_side])
	_progress()
	g = await _start()
	r = g.mission
	_walk(g, 6.0)
	_kill(r.tagged("people"))
	_walk(g, g.clock + 3.0)
	check("every one of the people dead: LOST", g.over and r.winner_side != "crown", "%s %s" % [g.over, r.winner_side])


# ================================================================== THE MIRROR: the swarm

func _mirror() -> void:
	_progress()
	var g: Game = await _start("swarm")
	var r := g.mission
	check("the swarm picked: its team is the player's, the village scripted", g.human == r.team_index("swarm"))
	check("the forward Mother on the mud bank, her two Sires and a pack", r.tagged("fwd_mother").size() == 1 and r.tagged("sires").size() == 2
		and r.tagged("pack").size() >= 8)
	_walk(g, 3.0)
	check("its objectives: the Mother lives, the raid", r.obj.get("s_mother", "") == "active" and r.obj.get("s_hunt", "") == "active")
	check("no scripted waves when the swarm is played", true)
	_walk(g, 25.0)
	check("... none at 0:25", r.tagged("w1").is_empty())
	check("the village hears the bell by itself (the people go in)", r.fired.has("m_bell"))
	var ps: Array = r.tagged("people")
	_kill(ps.slice(0, 16))
	_walk(g, g.clock + 3.0)
	check("more than half of the people caught: WON for the swarm", g.over and r.winner_side == "swarm", "%s %s dead %d half %d" % [g.over, r.winner_side,
		int(r.counters["dead_p"]), int(r.counters["half"])])
	check("the mirror's flags: aldeia few", str(r.flags.get("aldeia")) == "few")
	# the column at the fort first: lost
	_progress()
	g = await _start("swarm")
	r = g.mission
	_walk(g, 151.0)
	check("the mirror's timetable: the relief at 2:30", r.fired.has("part2") and r.tagged("relief_men").size() >= 7)
	_walk(g, 306.0)
	check("... the road at 5:00 (Tomasz walks the trail)", r.fired.has("part3") and r.fired.has("m_road"))
	for p in r.tagged("people"):
		p.spared = true
	for k in 3:
		_put(g, r.tagged("people"), _mid(r, "fort_in"))
		_walk(g, g.clock + 2.0)
	_walk(g, g.clock + 4.0)
	check("the column safe at the fort: LOST for the swarm", g.over and r.winner_side != "swarm", "%s %s %s %s %d" % [g.over, r.winner_side, r.counters, r.fired.has("road_done"), r.tagged("people").size()])


# ================================================================== save and load, ironman

func _snap(g: Game) -> Dictionary:
	var r := g.mission
	var tags := {}
	for k in r.tags:
		tags[k] = r.tagged(k).size()
	return {"flags": r.flags, "counters": r.counters, "obj": r.obj, "tags": tags, "fired": r.fired.keys().size()}


func _save_load() -> void:
	_progress()
	MissionSave.clear_all(MID)
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_walk(g, g.clock + 5.0)
	var before := _snap(g)
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
	check("LOADED the same: flags, counters, objectives, tags", diff.is_empty(), "; ".join(diff))
	check("... the wade rule still on after the load", g2.mission.wade < 1.0)
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


# ================================================================== the hub and the war map after d05

func _hubs() -> void:
	_progress()
	Campaign.record(MID, "solo", "crown", "crown", {"fields": "left", "aldeia": "some", "aldeia_n": 15, "forward": "rooted"})
	var p := Campaign.progress()
	var sl := Campaign.storyline_of(MID)
	var kg: Dictionary = sl["hub"]["talks"]["king"]
	var tz: Dictionary = sl["hub"]["talks"]["tomasz"]
	check("the hub: the King on the fields left", str(CampaignMenu.talk_lines(kg, p)).contains("left the fields standing"))
	check("the hub: the Cardinal on the swarm that eats", str(CampaignMenu.talk_lines(tz, p)).contains("It eats"))
	var st := WarMapData.state(p)
	var led: Array = st.get("ledger", []).map(func(x): return String(x.get("text", "")))
	check("the war map: the Tapajós the creatures', the church standing, the ledger", String(st["regions"]["tapajos"]) == "brood" and st["marks"]["sao_rafael"]
		and led.has("Some of São Rafael's people reached the river fort."), str(led.slice(-3)))
	check("the war map's data has no problem", WarMapData.problems().is_empty(), "; ".join(WarMapData.problems()))
	_progress()
	Campaign.record(MID, "solo", "crown", "crown", {"fields": "burned", "aldeia": "many", "forward": "killed"})
	p = Campaign.progress()
	check("fields burned: the King on the fire, the burnt church on the map", str(CampaignMenu.talk_lines(kg, p)).contains("burned the fields")
		and WarMapData.state(p)["marks"]["sao_rafael_burnt"])
	_progress()
	Campaign.record(MID, "solo", "swarm", "swarm", {"aldeia": "few", "fields": "left"})
	p = Campaign.progress()
	check("a swarm's win: the seal broken (not how it went)", String(WarMapData.state(p)["pins"][MID]["seal"]) == "broken")
