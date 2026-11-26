extends SceneTree
## Act 2's "The Council of Gears" (docs/campaign_d07_build.md):
##   - the data checks out, every text has pt and es, the Clockmaker line lists it after d04 and it opens once d04 is won,
##     the seats (solo the honest masters, the SOLO PICK of the machine, versus), the map (the city on its mine hill) and
##     the stills, THE ROSTER LADDER's K6 (the Ticking Owl and High Leap), no dashes in the spoken lines;
##   - THE FLAGS at the start: c01 `saved` (the families' houses), a04 `broken` (the broken ones stand up, or not), d04
##     `colonists` parley (Arruda keeps his word), a06 `varenne` (Varenne or Morel), c01 `jakob` (Matthias's father),
##     c01 `gate` (the turning a year further on with the pattern), every flag missing (the canon);
##   - PART 1: the vote, the four doors (a man of ours at each: the sign, the doorway's machines turn on him), the Ticking
##     Owls (research, morph);
##   - PART 2: the thirteenth hour, the great spring's tower turns, THE TURNING building by building (its men with it),
##     the waves, a master brought out in time / lost too late, HIGH LEAP asked, the hall turning when only the machine
##     stands at its door (LOST);
##   - PART 3: the guards on both stairs, the noon clock, Hollweg at the brake, THE GREAT SPRING (running by default and
##     the canon; stopped: every machine stops); the win and its flags (`spring`, `honest`); noon with no brake: LOST;
##   - THE MIRROR (the machine): its company on the hill, turning a building by standing at it, the hall turned: WON
##     (`spring` running, `honest` few); dawn with the hall standing: LOST;
##   - SAVE AND LOAD in Part 2, IRONMAN, the HUBS and the WAR MAP after d07; no script error anywhere.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_d07.gd [-- only=data,flags,part1,...]
## Prints CHECK lines, then "campaign_d07: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "d07_spring"
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
	print("campaign_d07: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if c01, a04, a06, a07, d02 and d04 were won with these flags (each merged over its canon).
func _progress(c01 := {}, a04 := {}, a06 := {}, d04 := {}, diff := "normal", with_d04 := true) -> void:
	var p := {"reached": [MID], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	var f1 := {"bells": "quiet", "saved": "some", "jakob": "alive", "cut": "no", "gate": "pattern"}
	f1.merge(c01, true)
	p["done"]["c01_thirteenth"] = {"won_by": "guild", "side": "guild", "flags": f1}
	var f4 := {"broken": "kept", "lost_to_machine": 0, "stopworks": "found", "jakob": "alive"}
	f4.merge(a04, true)
	p["done"]["a04_visit"] = {"won_by": "visit", "side": "visit", "flags": f4}
	var f6 := {"varenne": "spared", "paris": "stood"}
	f6.merge(a06, true)
	p["done"]["a06_barricades"] = {"won_by": "crown", "side": "crown", "flags": f6}
	p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}}
	p["done"]["d02_exodus"] = {"won_by": "exodus", "side": "exodus", "flags": {"exodus": "some", "drawings": "carried", "jakob": "stayed"}}
	if with_d04:
		var fd := {"colonists": "fought", "crates": "opened"}
		fd.merge(d04, true)
		p["done"]["d04_concordia"] = {"won_by": "guild", "side": "guild", "flags": fd}
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


func _guild_men(g: Game, r: MissionRun) -> Array:
	return g.units.filter(func(u): return not u.dead and u.team == r.team_index("guild") and u.kind in ["clock_soldier", "springer", "netter"])


## PART 1 done the quick way: a man of ours at each of the four doors.
func _to_part2(g: Game, r: MissionRun) -> void:
	_walk(g, maxf(g.clock, 4.0))
	var men := _guild_men(g, r)
	for i in 4:
		var a: String = ["n_press", "f_works", "m_press", "k_press"][i]
		_put(g, [men[i]], _mid(r, a) + Vector2(0, 2.5 * Defs.TILE))
	_walk(g, g.clock + 6.0)
	_walk(g, g.clock + 12.0)


## PART 2 done the quick way: the night's clock run out (the hall held: ours at its door).
func _to_part3(g: Game, r: MissionRun) -> void:
	_walk(g, float(r.fired.get("part2", g.clock)) + 2.0)
	r.clocks["night"] = g.clock + 0.5
	_walk(g, g.clock + 4.0)


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
	check("d07_spring: data checks out", pr.is_empty(), "; ".join(pr))
	var extra := ["Matthias", "Master Ortlieb"]
	for role in ["matthias", "ortlieb", "concordia_citizen", "city_master"]:
		extra.append(String(Rebels.ROLES[role]["about"]))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + extra:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission, its roles and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Clockmaker line lists d07 after d04", String(sl.get("id", "")) == "clockmaker"
		and (sl["missions"] as Array).find(MID) == (sl["missions"] as Array).find("d04_concordia") + 1)
	check("d04's next is d07 (both sides)", str(Campaign.mission("d04_concordia")["next"]) == str({"guild": MID, "valley": MID}))
	_progress({}, {}, {}, {}, "normal", false)
	var pp := Campaign.progress()
	pp["reached"] = []
	Campaign.save_progress(pp)
	check("d07 is shut until d04 is won", not Campaign.unlocked(MID))
	_progress()
	check("... and open once it is", Campaign.unlocked(MID))
	check("the seats: solo the honest masters, the SOLO PICK the machine", Campaign.solo_sides(m) == ["guild", "machine"])
	var c := Campaign.make_cfg(MID, "solo", "p1", false, "machine")
	var you: Array = (c["slots"] as Array).filter(func(s): return String(s["who"]) == "you").map(func(s): return String(s["team_id"]))
	check("the machine picked: the machine's team is the player's", you == ["machine"], str(you))
	check("versus: the honest masters p1, the machine p2", Campaign.seat_side(m, "versus", "p1") == "guild" and Campaign.seat_side(m, "versus", "p2") == "machine")
	var md := Campaign.map_data("concordia_city")
	var cells := String(md.get("cells", ""))
	check("the map: the city on its mine hill (high ground and stairs), the highlands", md.get("biome", "") == "highlands" and cells.count("h") > 600
		and cells.count("r") >= 6, "%d h %d r" % [cells.count("h"), cells.count("r")])
	for k in m["stills"]:
		check("still %s is in" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	var tm: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "guild")[0]
	check("THE ROSTER LADDER K6: TICKING OWL and HIGH LEAP, both NEW", (tm["roster"]["allow"] as Array).has("owl_morph")
		and (tm["roster"]["allow"] as Array).has("high_leap") and (tm["roster"]["allow"] as Array).has("ticking_owl")
		and (tm["roster"]["new"] as Array) == ["owl_morph", "high_leap"] and not (tm["roster"]["allow"] as Array).has("ballista"))
	check("the honest masters carry K4's SHIELD WALL", (tm.get("techs", []) as Array) == ["shield_wall"])
	check("hubs-grow: d07 earns on the Clockmaker line", (HubGrow.line("clockmaker")["earn"] as Array).has(MID))
	var dash: Array = []
	for lid in m["lines"]:
		if String(m["lines"][lid]["text"]).contains(" - ") or String(m["lines"][lid]["text"]).contains("—"):
			dash.append(lid)
	check("no dashes in the spoken lines", dash.is_empty(), str(dash))
	check("the choice's default is the canon: RUNNING", JSON.stringify(m).contains("\"default\": \"running\"") or JSON.stringify(m).contains("\"default\":\"running\""))


# ================================================================== the flags read

func _flags() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	check("the canon: four families' houses, the broken ones will stand up, Varenne in the council", r.tagged("houses").size() == 4
		and r.tagged("varenne").size() == 1 and r.tagged("morel").is_empty())
	check("the honest masters' works stand round their own tower (a working Escapement and Aviary)", r.tagged("q_tower").size() == 1
		and r.tagged("escapement").size() == 1 and r.tagged("aviary").size() == 1 and r.tagged("spring").size() == 1)
	check("the great spring's tower is the city's until the thirteenth hour", r.tagged("spring_tower")[0].team == r.team_index("city"))
	check("nine meshed works, the city's (TEAL)", r.tagged("meshed").size() == 9 and r.tagged("meshed").all(func(b): return b.team == r.team_index("city")))
	_progress({"saved": "few"})
	g = await _start()
	r = g.mission
	var few := r.tagged("houses").size()
	_progress({"saved": "many"})
	g = await _start()
	r = g.mission
	check("c01 saved few / many: three / five houses (and one more soldier with many)", few == 3 and r.tagged("houses").size() == 5, "%d %d" % [few, r.tagged("houses").size()])
	_progress({"jakob": "lost"}, {}, {"varenne": "executed"})
	g = await _start()
	r = g.mission
	_walk(g, 5.0)
	check("c01 jakob lost: Matthias's father, God rest him", _said(r, "mt_1_lost") and not _said(r, "mt_1"))
	check("a06 executed: Citizen Morel is the council's voice", r.tagged("morel").size() == 1 and r.tagged("varenne").is_empty())
	_progress({"gate": "people"}, {"broken": "melted"}, {}, {"colonists": "parley"})
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	_walk(g, float(r.fired.get("part2", g.clock)) + 3.0)
	var every := 0.0
	for s in r.a2.st["spreads"]:
		if String(s["name"]) == "city":
			every = float(s["every"])
	check("c01 gate people: the city turns slower (no pattern to fit)", is_equal_approx(every, 16.0), str(every))
	_walk(g, float(r.fired["part2"]) + 56.0)
	check("a04 melted: no broken ones stand up", not r.fired.has("broken"))
	check("d04 parley: Captain Arruda keeps his word (the valley's men on our side)", r.fired.has("valley") and r.tagged("valley_men").size() == 5
		and r.tagged("valley_men").all(func(u): return g.allied(u.team, g.human)) and _said(r, "ar_valley"))
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	_walk(g, float(r.fired.get("part2", g.clock)) + 30.0)
	for s in r.a2.st["spreads"]:
		if String(s["name"]) == "city":
			every = float(s["every"])
	check("the canon (the pattern): the city turns a year further on (every 14 s)", is_equal_approx(every, 14.0), str(every))
	check("a04 kept: the broken ones stand up in the quarter's yard", r.fired.has("broken") and r.tagged("broken").size() == 2 and _said(r, "n_broken"))
	check("d04 fought: nobody comes up the valley road", not r.fired.has("valley"))


# ================================================================== PART 1: the vote, the doors, the owls

func _part1() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 9.0)
	check("the vote (a mid-match show), then Part 1", r.fired.has("vote") and r.fired.has("part1") and r.shows.size() >= 1)
	check("the NEW cards for K6 are said", _said(r, "new_owl_morph") and _said(r, "new_high_leap"))
	check("Matthias and Ulrich say what to do (SAY IT PLAINLY)", _said(r, "mt_1") and _said(r, "u_1"))
	check("the objectives: the four doors, the hall, the quarter", r.obj.get("find", "") == "active" and r.obj.get("hall", "") == "active"
		and r.obj.get("quarter", "") == "active")
	var men := _guild_men(g, r)
	_put(g, [men[0]], _mid(r, "n_press") + Vector2(0, 2.5 * Defs.TILE))
	_walk(g, g.clock + 5.0)
	check("a man of ours at the north road's press: its sign, counted", r.fired.has("find_north") and int(r.counters["found"]) == 1 and _said(r, "n_find_north"))
	_walk(g, g.clock + 4.0)
	check("... and the doorway's machines turn on him (the machine's now)", r.tagged("cm_north").all(func(u): return u.team == r.team_index("machine"))
		and _said(r, "n_turnon"))
	_walk(g, 26.0)
	check("THE NIGHT WATCH asked at the Aviary", r.obj.get("owls", "") == "active" and _said(r, "u_owls"))
	g.players[g.human]["tech"]["owl_morph"] = true
	_walk(g, g.clock + 1.0)
	check("TICKING OWL researched: Ulrich says how to morph", _said(r, "u_morph"))
	for i in 2:
		g._add_unit("ticking_owl", g.human, _mid(r, "camp"))
	_walk(g, g.clock + 2.0)
	check("two owls: the night watch done", r.obj.get("owls", "") == "done" and _said(r, "h_owls"))
	for i in 3:
		_put(g, [men[i + 1]], _mid(r, ["f_works", "m_press", "k_press"][i]) + Vector2(0, 2.5 * Defs.TILE))
	_walk(g, g.clock + 9.0)
	check("the four signs found: Hollweg calls it a fault, Matthias says Nuremberg", r.fired.has("found_all") and _said(r, "mt_found"),
		str([r.counters.get("found"), r.fired.keys().filter(func(k): return String(k).begins_with("find_"))]))
	_walk(g, g.clock + 10.0)
	check("... and soon the thirteenth hour (NO WAITING)", r.fired.has("part2"))
	# nobody looks: the thirteenth hour comes all the same
	_progress()
	g = await _start()
	r = g.mission
	_walk(g, 340.0)
	check("nobody at the doors: the thirteenth hour at 5:30 anyway", r.fired.has("part2") and not r.fired.has("found_all"))


# ================================================================== PART 2: the city turns

func _part2() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_walk(g, float(r.fired["part2"]) + 3.0)
	check("the thirteenth hour: the great spring's tower is the machine's", r.tagged("spring_tower")[0].team == r.team_index("machine") and _said(r, "n_13"))
	check("the hill's automata go with it", r.tagged("cm_upper").all(func(u): return u.team == r.team_index("machine")))
	check("the objectives: the turning, the masters; the three masters at home", r.obj.get("turning", "") == "active" and r.obj.get("masters", "") == "active"
		and r.tagged("masters").size() == 3)
	_walk(g, float(r.fired["part2"]) + 36.0)
	check("THE TURNING: the nearest works to the spring turned, counted", int(r.counters["turned"]) >= 1
		and r.tagged("meshed").any(func(b): return b.team == r.team_index("machine")), str(r.counters["turned"]))
	check("the upper town's quarter turned: its machines come down", r.fired.has("q_turned_upper") and r.tagged("wave_upper").size() >= 2)
	check("HIGH LEAP asked before dawn", r.obj.get("leap", "") == "active" and _said(r, "u_leap"))
	# a master brought out in time: a man of ours at his house
	var kessler: Unit = r.tagged("master_forge")[0]
	var men := _guild_men(g, r)
	_put(g, [men[0]], kessler.position + Vector2(20, 0))
	_walk(g, g.clock + 1.5)
	check("Kessler reached before the forge turns: he comes to our quarter", kessler.team == r.team_index("quarter") and int(r.counters["honest_n"]) == 1
		and _said(r, "ms_in"))
	# a master reached too late: his quarter turned first
	for b in r.tagged("qb_mill"):
		b.team = r.team_index("machine")
	_walk(g, g.clock + 6.0)
	var brandl: Unit = r.tagged("master_mill")[0]
	check("the mill turned before anybody reached Brandl: he stays with his machines", brandl.team == r.team_index("machine") and int(r.counters["lost_masters"]) == 1
		and _said(r, "n_master_lost"))
	check("... and the mill's machines march on the square", r.fired.has("q_turned_mill") and r.tagged("wave_mill").size() >= 2)
	# a turned workshop sends more until it is broken
	_walk(g, g.clock + 52.0)
	check("a turned workshop sends machines; break it (the owls' task)", r.fired.has("works_say") and r.obj.get("break_works", "") == "active")
	# the hall: only the machine at its door, a while
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	_walk(g, float(r.fired["part2"]) + 3.0)
	for u in _guild_men(g, r):
		if r.area_rect("hall_yard").has_point(u.position):
			_put(g, [u], _mid(r, "camp"))
	var mt := r.team_index("machine")
	var foes: Array = []
	for i in 3:
		foes.append(g._add_unit("clock_soldier", mt, _mid(r, "hall_door")))
	_put(g, foes, _mid(r, "hall_door"))
	_walk(g, g.clock + 4.0)
	check("machines at the hall's door: the warning", _said(r, "n_hall"))
	var men2 := _guild_men(g, r)
	_put(g, [men2[0]], _mid(r, "hall_yard") + Vector2(-60, 0))
	_walk(g, g.clock + 12.0)
	check("one of ours by the hall: it does not turn", not r.fired.has("hall_lost"))
	_put(g, [men2[0]], _mid(r, "camp"))
	_put(g, foes, _mid(r, "hall_door"))
	_walk(g, g.clock + 14.0)
	check("nobody of ours by it: the hall turns and the mission is LOST", r.fired.has("hall_lost") and g.over and r.winner_side != "guild",
		"%s %s %s" % [r.fired.has("hall_lost"), g.over, r.winner_side])


# ================================================================== PART 3: the great spring

func _part3() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_to_part3(g, r)
	check("dawn: Part 3, the brake's objective, the noon clock", r.fired.has("part3") and r.obj.get("brake", "") == "active" and r.clocks.has("noon")
		and r.obj.get("hall", "") == "done")
	check("both stairs held: guards on top, soldiers at the foot, the yard", r.tagged("guard_w").size() >= 2 and r.tagged("guard_s").size() >= 2
		and r.tagged("foot_w").size() >= 2 and r.tagged("yard").size() >= 2)
	_walk(g, g.clock + 15.0)
	check("Ulrich tells how to leap (SAY IT PLAINLY)", _said(r, "u_3"))
	var hw: Unit = r.tagged("hollweg")[0]
	_put(g, [hw], _mid(r, "brake"))
	_walk(g, g.clock + 5.0)
	check("Hollweg at the brake: the lines, Matthias asks for it", r.fired.has("at_brake") and _said(r, "h_brake") and _said(r, "mt_brake"))
	_walk(g, g.clock + 2.0)
	check("THE GREAT SPRING: the choice is offered", String(r.choice_open.get("id", "")) == "spring")
	_put(g, [hw], _mid(r, "camp"))
	_walk(g, g.clock + 62.0)
	check("unanswered: LET IT RUN (the canon)", str(r.flags.get("spring")) == "running" and _said(r, "n_run"), str(r.flags))
	_walk(g, g.clock + 12.0)
	check("WON: the flags (spring running, honest few with nobody brought out)", g.over and r.winner_side == "guild" and str(r.flags.get("honest")) == "few", str(r.flags))
	# STOP IT: every machine stops, ours with theirs
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	var men := _guild_men(g, r)
	for q in ["forge", "mill"]:
		_put(g, [men[0]], r.tagged("master_" + q)[0].position + Vector2(20, 0))
		_walk(g, g.clock + 1.0)
	_to_part3(g, r)
	_put(g, [r.tagged("hollweg")[0]], _mid(r, "brake"))
	_walk(g, g.clock + 7.0)
	r.choose("spring", "stopped")
	_walk(g, g.clock + 1.0)
	var mt := r.team_index("machine")
	var wound: Array = g.units.filter(func(u): return not u.dead and String(u.d.get("faction", "")) == "clockwork" and u.wind > 0.01)
	check("STOP IT: every machine in the city stops, ours too", _said(r, "n_stop") and wound.is_empty(), str(wound.size()))
	_walk(g, g.clock + 12.0)
	check("WON: spring stopped, honest some (two of three)", g.over and r.winner_side == "guild" and str(r.flags.get("spring")) == "stopped"
		and str(r.flags.get("honest")) == "some", str(r.flags))
	var pages := str(r.pages_now(Campaign.show_pages(r.data, "ending", "guild")))
	check("the ending by the flag: the coast road, the King on the first thing he stopped", pages.contains("h_end_stop") and pages.contains("k_end_stop")
		and not pages.contains("h_end_run"))


func _defeat() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 6.0)
	_kill(r.tagged("q_tower"))
	_walk(g, g.clock + 6.0)
	check("the Nuremberg quarter's tower broken: LOST", g.over and r.winner_side != "guild", "%s %s" % [g.over, r.winner_side])
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	_to_part3(g, r)
	r.clocks["noon"] = g.clock + 0.5
	_walk(g, g.clock + 6.0)
	check("noon with nobody at the brake: LOST", g.over and r.winner_side != "guild" and _said(r, "n_noon"), "%s %s" % [g.over, r.winner_side])


# ================================================================== THE MIRROR: the machine

func _mirror() -> void:
	_progress()
	var g: Game = await _start("machine")
	var r := g.mission
	check("the machine picked: its team is the player's, the honest masters scripted", g.human == r.team_index("machine"))
	check("the great spring's tower and a meshed company on the hill are the machine's", r.tagged("spring_tower")[0].team == g.human
		and r.tagged("machine_men").size() >= 10)
	check("its objectives: the hall, dawn's clock", r.obj.get("m_hall", "") == "active" and r.obj.get("m_dawn", "") == "active" and r.clocks.has("dawn_m"))
	check("the honest masters hold the hall by themselves", r.tagged("hall_guard").size() == 3)
	_walk(g, 70.0)
	check("the thirteenth hour on the mirror's clock (1:00)", r.fired.has("part2") and r.obj.get("m_turn", "") == "active")
	# the machine's men at a building of the city: it turns at once
	var men: Array = r.tagged("machine_men").filter(func(u): return u.kind == "clock_soldier").slice(0, 2)
	_put(g, men, _mid(r, "k_press") + Vector2(0, 2.5 * Defs.TILE))
	_walk(g, g.clock + 8.0)
	check("stand at the market's press a moment: it turns at once (choose which)", r.tagged("w_k_press")[0].team == g.human)
	# the hall turned: won
	_kill(r.tagged("hall_guard"))
	var three: Array = r.tagged("machine_men").filter(func(u): return u.kind == "clock_soldier").slice(0, 3)
	for k in 6:
		_put(g, three, _mid(r, "hall_door"))
		_walk(g, g.clock + 2.0)
	_walk(g, g.clock + 6.0)
	check("three at the hall's door, none of theirs: the hall turns, WON for the machine", g.over and r.winner_side == "machine", "%s %s" % [g.over, r.winner_side])
	check("the machine's flags (canon-compatible): spring running, honest few", str(r.flags.get("spring")) == "running" and str(r.flags.get("honest")) == "few", str(r.flags))
	# dawn with the hall standing: lost
	_progress()
	g = await _start("machine")
	r = g.mission
	_walk(g, 5.0)
	r.clocks["dawn_m"] = g.clock + 0.5
	_walk(g, g.clock + 6.0)
	check("dawn with the hall and the quarter standing: LOST for the machine", g.over and r.winner_side != "machine" and _said(r, "n_m_lost"),
		"%s %s" % [g.over, r.winner_side])


# ================================================================== save and load, ironman

func _snap(g: Game) -> Dictionary:
	var r := g.mission
	var tags := {}
	for k in r.tags:
		tags[k] = r.tagged(k).size()
	var teams := []
	for b in r.tagged("meshed"):
		teams.append(b.team)
	return {"flags": r.flags, "counters": r.counters, "obj": r.obj, "tags": tags, "fired": r.fired.keys().size(), "turned": teams}


func _save_load() -> void:
	_progress()
	MissionSave.clear_all(MID)
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_walk(g, float(r.fired["part2"]) + 40.0)
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
	check("LOADED the same: flags, counters, objectives, tags, the turned works", diff.is_empty(), "; ".join(diff))
	var sp := false
	for s in g2.mission.a2.st["spreads"]:
		if String(s["name"]) == "city" and not bool(s["stopped"]):
			sp = true
	check("... THE TURNING goes on after the load", sp)
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


# ================================================================== the hubs and the war map after d07

func _hubs() -> void:
	_progress()
	Campaign.record(MID, "solo", "guild", "guild", {"spring": "stopped", "honest": "many", "honest_n": 3})
	var p := Campaign.progress()
	var sl := Campaign.storyline_of(MID)
	var hw: Dictionary = sl["hub"]["talks"]["hollweg"]
	check("the hub after the spring stopped: a fisherman's house on the coast", String(CampaignMenu.hub_now(sl["hub"], p).get("title", "")) == "A Fisherman's House on the Coast")
	check("... Hollweg: the first thing he ever stopped", str(CampaignMenu.talk_lines(hw, p)).contains("never heard it quiet"))
	var st := WarMapData.state(p)
	var led: Array = st.get("ledger", []).map(func(x): return String(x.get("text", "")))
	check("the war map: Concórdia the machine's, the honest masters at the coast, the ledger", String(st["regions"]["concordia"]) == "machine"
		and st["marks"]["honest_coast"] and led.has("Most of the honest masters stood with Hollweg."), str(led.slice(-3)))
	check("the war map's data has no problem", WarMapData.problems().is_empty(), "; ".join(WarMapData.problems()))
	_progress()
	Campaign.record(MID, "solo", "guild", "guild", {"spring": "running", "honest": "some", "honest_n": 2})
	p = Campaign.progress()
	check("running: the council hall still (no coast), Hollweg calls it concord", String(CampaignMenu.hub_now(sl["hub"], p).get("title", "")) == "Concórdia's Council Hall"
		and str(CampaignMenu.talk_lines(hw, p)).contains("I tell myself that is concord"))
	st = WarMapData.state(p)
	check("running: the King's map keeps Concórdia blue until the crossing (what he knew)", String(st["regions"]["concordia"]) == "guild")
	_progress()
	Campaign.record(MID, "solo", "machine", "machine", {"spring": "running", "honest": "few"})
	p = Campaign.progress()
	check("the machine's win: its hub is the great spring's tower, and no broken seal (canon-compatible)",
		String(CampaignMenu.hub_now(sl["hub"], p).get("title", "")) == "The Great Spring's Tower"
		and String(WarMapData.state(p)["pins"][MID]["seal"]) != "broken", String(WarMapData.state(p)["pins"][MID]["seal"]))
