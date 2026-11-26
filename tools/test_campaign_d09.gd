extends SceneTree
## Act 2's SECOND CROSSING, "Between Two Fires" (docs/campaign_d09_build.md):
##   - the data checks out, every text has pt and es, all three lines list it after their last Act 2 mission (d05, d07,
##     d08) and each of those leads to it, it opens only once all three are won, the seats (solo the Crown; co-op the fort;
##     VERSUS PICK the creatures or the automata), the map (the sertão) and the stills, THE ROSTER LADDER's C7 (ARMOUR and
##     the POWDER WAGON), the army's Guardsmen and Cuirassiers in their armour, THE BROOD IS NOT A PERSON in the texts;
##   - THE FLAGS at the start: p01 `families` (the Virginia volunteers), a06 `paris`, a07 `people` (lines), d06 `brood_n`
##     and d05 `fields` (the creatures' waves), d07 `spring` (the machines' waves), every flag missing (the canon);
##   - PART 1: the march, the NEW cards, two skies (both sides' flyers), the villages' people join and follow Tomasz, the
##     raids, the owls on the wagons, the fort's clock; PART 2: the siege at both gates, the ford where they meet, relieved;
##   - PART 3: the council (the rider and the envoy by the flags), THE CHOICE both ways (and unanswered: the seed picks),
##     the night's waves from the side NOT chosen, dawn: WON with `first`, `fort`, `sertao`; the magazine blown: LOST;
##   - VERSUS: the friend's side's forces, his magazine win; SAVE AND LOAD in Part 2, IRONMAN, the HUBS and the WAR MAP
##     after d09; no script error anywhere.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_d09.gd [-- only=data,flags,part1,part2,part3,...]
## Prints CHECK lines, then "campaign_d09: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "d09_crossroads"
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
	print("campaign_d09: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if the three lines' Act 2 missions were won with these flags (each merged over its canon); `without`
## leaves one of d05 / d07 / d08 out (the crossing still locked); `none` leaves every flag out but the needs (the canon).
func _progress(fl := {}, diff := "normal", without := "", none := false) -> void:
	var p := {"reached": [MID], "done": {}, "difficulty": diff}
	var canon := {
		"p01_leaf": ["crown", {"families": "save"}],
		"a06_barricades": ["crown", {"varenne": "spared", "paris": "stood"}],
		"a07_council": ["crown", {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}],
		"d01_minas": ["crown", {"minas": "quiet", "gold": "some", "conspirator": "taken"}],
		"d06_queen": ["brood", {"brood_n": "some", "pieter": "alive", "lindqvist": "fled"}],
		"d05_aldeia": ["crown", {"fields": "left", "aldeia": "some", "forward": "rooted"}],
		"d07_spring": ["guild", {"spring": "running", "honest": "some"}],
		"d08_rivers": ["barra", {"lure": "burned", "barra": "held", "nazare": "some"}],
	}
	for mid in canon:
		if mid == without:
			continue
		var f: Dictionary = {} if none else (canon[mid][1] as Dictionary).duplicate()
		if not none:
			for k in fl.get(mid, {}):
				f[k] = fl[mid][k]
		p["done"][mid] = {"won_by": canon[mid][0], "side": canon[mid][0], "flags": f}
	Campaign.save_progress(p)


func _start(mode := "solo", pick := "", mark := "") -> Game:
	if main.game:
		main._to_menu()
		await process_frame
	for n in main.ui_layer.get_children():
		if n.name == "MissionEnd" or n is StillShow:
			n.queue_free()
	main.start(Campaign.make_cfg(MID, mode, "p1", false, pick))
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


func _army(g: Game, r: MissionRun) -> Array:
	var t := r.team_index("army")
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind != "horse")


## PART 1 done the quick way: the army walked to the fort's approach (the villagers in the fort).
func _to_part2(g: Game, r: MissionRun) -> void:
	_walk(g, maxf(g.clock, 4.0))
	_put(g, _army(g, r), _mid(r, "fort_approach"))
	_put(g, r.tagged("people"), _mid(r, "fort_in"))
	_walk(g, g.clock + 2.0)


## PART 2 done the quick way: every siege wave in and killed (relieved), then the show (Part 3 starts).
func _to_part3(g: Game, r: MissionRun) -> void:
	_walk(g, float(r.fired.get("part2", g.clock)) + 92.0)
	for i in 6:
		_kill(r.tagged("c_wave") + r.tagged("m_wave") + r.tagged("c_ford") + r.tagged("m_ford"))
		_walk(g, g.clock + 2.0)
		if r.fired.has("part3"):
			break
	_walk(g, g.clock + 2.0)


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
	if want.call("versus"): await _versus()
	if want.call("save"): await _save_load()
	if want.call("ironman"): await _ironman()
	if want.call("hubs"): _hubs()
	check("no script error in the whole run", _errs.is_empty(), str(_errs.slice(0, 3)))
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("d09_crossroads: data checks out", pr.is_empty(), "; ".join(pr))
	var extra := ["General Ruggieri", "Father Tomasz", "Sergeant Hollins", "Major Teixeira", "RUGGIERI'S DISPATCH", "Ruggieri's dispatch"]
	for role in ["ruggieri_general", "tomasz_vicar", "hollins_sergeant", "fort_commander", "sertanejo"]:
		extra.append(String(Rebels.ROLES[role]["about"]))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + extra:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission, its roles and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	for pair in [["prologue", "d05_aldeia"], ["clockmaker", "d07_spring"], ["naturalist", "d08_rivers"]]:
		var sl: Dictionary = {}
		for s in Campaign.index()["storylines"]:
			if String(s["id"]) == pair[0]:
				sl = s
		var ms: Array = sl.get("missions", [])
		check("the %s line lists d09 after %s" % pair, ms.find(MID) == ms.find(pair[1]) + 1 and ms.find(MID) > 0)
	check("d05, d07, d08 lead to d09 (their own side's win)", str(Campaign.mission("d05_aldeia")["next"]["crown"]) == MID
		and str(Campaign.mission("d07_spring")["next"]["guild"]) == MID and str(Campaign.mission("d08_rivers")["next"]["barra"]) == MID)
	for w in ["d05_aldeia", "d07_spring", "d08_rivers"]:
		_progress({}, "normal", w)
		var pp := Campaign.progress()
		pp["reached"] = []
		Campaign.save_progress(pp)
		check("d09 is shut while %s is not won" % w, not Campaign.unlocked(MID))
	_progress()
	check("... and open once all three are", Campaign.unlocked(MID))
	check("the seats: solo the Crown only (no solo pick)", Campaign.solo_sides(m) == ["crown"])
	check("co-op: p2 the fort's garrison", Campaign.seat_side(m, "coop", "p2") == "crown")
	check("the VERSUS PICK: p2 the creatures or the automata", Campaign.versus_picks(m) == ["creatures", "automata"]
		and Campaign.seat_side(m, "versus", "p2") == "creatures" and Campaign.seat_side(m, "versus", "p2", "automata") == "automata"
		and Campaign.seat_side(m, "versus", "p1") == "crown")
	var md := Campaign.map_data("sao_francisco")
	check("the map is the sertão, the river with its three fords", md.get("biome", "") == "sertao" and String(md.get("cells", "")).count("f") > 100,
		str(String(md.get("cells", "")).count("f")))
	for k in m["stills"]:
		check("still %s is in" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	var tm: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "army")[0]
	check("THE ROSTER LADDER C7: ARMOUR and the POWDER WAGON, both NEW", (tm["roster"]["allow"] as Array).has("armour")
		and (tm["roster"]["allow"] as Array).has("powder_wagon") and (tm["roster"]["new"] as Array) == ["armour", "powder_wagon"]
		and not (tm["roster"]["allow"] as Array).has("balloon"))
	check("the army comes with the C5 and C6 drills and Armour researched", (tm.get("techs", []) as Array) == ["matchlock", "bayonet", "charge", "armour"])
	check("the needs: Rome, d05, d07, d08", m.get("needs", []) == ["a07_council", "d05_aldeia", "d07_spring", "d08_rivers"])
	check("hubs-grow: d09 earns on the Crown line", (HubGrow.line("prologue")["earn"] as Array).has(MID))
	var all := " ".join(Campaign.strings_of(m))
	check("no creature named or given a will (Linnea, her young, wants, comes for)", not all.contains("Linnea") and not all.contains("her young")
		and not all.contains("comes for") and not all.contains("wants"))
	var dash: Array = []
	for lid in m["lines"]:
		if String(m["lines"][lid]["text"]).contains(" - ") or String(m["lines"][lid]["text"]).contains("—"):
			dash.append(lid)
	check("no dashes in the spoken lines", dash.is_empty(), str(dash))
	var ch: Dictionary = {}
	for t in m["triggers"]:
		for a in t["do"]:
			if a is Dictionary and a.has("choice"):
				ch = a["choice"]
	check("THE CHOICE has no canon: the seed picks when nobody answers", String(ch.get("default", "")) == "random"
		and (ch.get("options", []) as Array).map(func(o): return String(o["id"])) == ["brood", "clockwork"])


# ================================================================== the flags at the start

func _flags() -> void:
	_progress({}, "normal", "", true)
	var g: Game = await _start()
	var r := g.mission
	check("every earlier flag missing: the canon: the Virginia volunteers, 16 people", r.tagged("volunteers").size() == 5
		and int(r.counters["people_n"]) == 16, "%d %d" % [r.tagged("volunteers").size(), int(r.counters["people_n"])])
	check("the player is the army (purple) with Ruggieri and Tomasz", g.human == r.team_index("army") and r.tagged("ruggieri").size() == 1
		and r.tagged("tomasz").size() == 1)
	var arm: Array = r.tagged("armoured")
	check("NEW C7: Guardsmen and Cuirassiers come out armoured", arm.size() == 7 and arm.all(func(u): return u.armoured), str(arm.size()))
	check("two powder wagons, the C5 drills", r.tagged("wagons").size() == 2 and g.players[g.human]["tech"].has("matchlock")
		and g.players[g.human]["tech"].has("armour"))
	_progress({"p01_leaf": {"families": "leave"}})
	g = await _start()
	r = g.mission
	check("p01 families left: no volunteers", r.tagged("volunteers").is_empty())
	_progress({"a07_council": {"people": "many"}})
	g = await _start()
	r = g.mission
	var pages := str(r.pages_now(Campaign.show_pages(r.data, "opening", "crown")))
	check("the opening: the volunteers, Paris' colours, the villages trust the priest (many)", pages.contains("t_open_vol") and pages.contains("t_open_paris")
		and pages.contains("t_open_many"))
	# the creatures' first raid by d06 brood_n
	var sizes := {}
	for bn in ["few", "some", "all"]:
		_progress({"d06_queen": {"brood_n": bn}})
		g = await _start()
		r = g.mission
		_walk(g, 67.0)
		sizes[bn] = r.tagged("r1").size()
	check("d06 brood_n few / some / all: the raids smaller / as written / bigger", sizes["few"] < sizes["some"] and sizes["some"] < sizes["all"], str(sizes))
	# the siege's creatures by d05 fields, its machines by d07 spring
	var sc := {}
	var sm := {}
	for v in [["left", "running"], ["burned", "stopped"]]:
		_progress({"d05_aldeia": {"fields": v[0]}, "d07_spring": {"spring": v[1]}})
		g = await _start()
		r = g.mission
		_to_part2(g, r)
		sc[v[0]] = r.tagged("siege_c1").size()
		sm[v[1]] = r.tagged("siege_m1").size()
	check("d05 fields left (the swarm fed): the siege's creatures bigger than burned", sc["left"] > sc["burned"], str(sc))
	check("d07 spring stopped (dead brass): the siege's machines smaller than running", sm["stopped"] < sm["running"], str(sm))


# ================================================================== PART 1: the road

func _part1() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 10.0)
	check("the NEW cards for C7 are said", _said(r, "new_armour") and _said(r, "new_powder_wagon"))
	check("the march and its lesson (SAY IT PLAINLY)", _said(r, "r_march") and _said(r, "n_road"))
	check("the objectives: the march, the fort's clock, the people, the magazine", r.obj.get("march", "") == "active" and r.obj.get("fort_clock", "") == "active"
		and r.obj.get("people", "") == "active" and r.obj.get("magazine", "") == "active" and r.clocks.has("fort"))
	_walk(g, 21.0)
	check("two skies: the swarm's Hatchlings and the city's Swifts over the road", r.tagged("sky_c").size() >= 3 and r.tagged("sky_m").size() >= 2
		and _said(r, "n_skies"))
	check("the two flyers' sides are enemies", g.hostile(r.team_index("creatures"), r.team_index("automata")))
	_walk(g, 33.0)
	check("the wagons' lesson", _said(r, "n_wagon"))
	var v1: Array = r.tagged("folk_v1")
	check("Riacho Seco's people wait in their village", not r.fired.has("join_folk_v1"))
	_put(g, r.tagged("tomasz") + r.tagged("line").slice(0, 2), _mid(r, "riacho_in") + Vector2(0, 4 * Defs.TILE))
	_walk(g, g.clock + 1.0)
	check("the army reaches Riacho Seco: its people join the column (they follow Tomasz)", r.fired.has("join_folk_v1") and _said(r, "n_v1")
		and r.tagged("column").size() == v1.size())
	_walk(g, g.clock + 8.0)
	check("RAID 1: Raptors out of the scrub at Riacho Seco", r.tagged("r1").size() >= 4 and _said(r, "n_r1"))
	_kill(r.tagged("r1"))
	_put(g, r.tagged("tomasz") + r.tagged("line").slice(0, 2), _mid(r, "lagoa_in") + Vector2(0, 5 * Defs.TILE))
	_walk(g, g.clock + 1.5)
	check("Lagoa Branca's people join too, and the machines come out of the thorns", r.fired.has("join_folk_v2") and r.fired.has("m1")
		and r.tagged("m1").size() >= 4)
	check("... wound full (the city's plates)", r.tagged("m1").all(func(u): return u.wind > 0.9))
	_walk(g, g.clock + 30.0)
	check("the owls go for the powder wagons, their objective", r.tagged("owls").size() == 2 and r.obj.get("owls", "") == "active" and _said(r, "n_owls"))
	_kill(r.tagged("owls"))
	_walk(g, g.clock + 1.0)
	check("the owls down: done", r.obj.get("owls", "") == "done")
	_put(g, _army(g, r).slice(0, 3), _mid(r, "road_west"))
	_walk(g, g.clock + 1.0)
	check("RAID 3: Raptors and a big one between the army and the fort", r.tagged("r2").size() >= 4 and r.tagged("r2").any(func(u): return u.kind == "tyrant_challenger"))
	# the people at the fort are counted in
	_put(g, r.tagged("folk_v1"), _mid(r, "fort_in"))
	_walk(g, g.clock + 1.0)
	check("the road's people in the fort counted", int(r.counters["in_fort"]) == v1.size(), str(r.counters["in_fort"]))
	_put(g, _army(g, r), _mid(r, "fort_approach"))
	_walk(g, g.clock + 1.0)
	check("the army at the fort: Part 2, the pay chest", r.fired.has("part2") and r.obj.get("march", "") == "done" and r.obj.get("siege", "") == "active")
	# the fort's clock out before the army arrives: the siege begins without it
	_progress()
	g = await _start()
	r = g.mission
	r.clocks["fort"] = g.clock + 0.5
	_walk(g, g.clock + 2.0)
	check("the fort's clock out: the siege begins without the army", r.fired.has("part2") and _said(r, "n_fort_late"))


# ================================================================== PART 2: the fort

func _part2() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_walk(g, g.clock + 2.0)
	check("the siege at both gates: creatures north, machines south", r.tagged("siege_c1").size() >= 5 and r.tagged("siege_m1").size() >= 4
		and _said(r, "n_arrive") and _said(r, "n_siege"))
	check("the pay chest: gold for the night", int(g.players[g.human]["gold"]) >= 500, str(g.players[g.human]["gold"]))
	_walk(g, float(r.fired["part2"]) + 22.0)
	check("a band of each at the fort's ford", r.tagged("c_ford").size() >= 3 and r.tagged("m_ford").size() >= 3)
	var cf: Unit = r.tagged("c_ford")[0]
	_put(g, r.tagged("m_ford").slice(0, 1), cf.position + Vector2(40, 0))
	_walk(g, g.clock + 1.0)
	check("they meet at the ford: the line (they fight each other)", r.fired.has("ford_fight") and _said(r, "n_ford"))
	_walk(g, float(r.fired["part2"]) + 47.0)
	check("the second waves over the fords", r.fired.has("siege_c2") and r.fired.has("siege_m2"))
	check("not relieved while the last waves have not come", not r.fired.has("relieved"))
	_to_part3(g, r)
	check("RELIEVED: the siege's objective done, Part 3", r.fired.has("relieved") and r.obj.get("siege", "") in ["done", "hidden"] and r.fired.has("part3"))
	# dusk comes first: both draw back anyway
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	r.clocks["siege"] = g.clock + 0.5
	_walk(g, g.clock + 8.0)
	check("dusk before relief: both draw back, Part 3 anyway (NO WAITING)", r.fired.has("draw_back") and r.fired.has("part3"))


# ================================================================== PART 3: the council, the choice, the night

func _part3() -> void:
	for first in ["brood", "clockwork"]:
		_progress({"a06_barricades": {"varenne": "spared"}, "d08_rivers": {"barra": "burned", "lure": "used"}})
		var g: Game = await _start()
		var r := g.mission
		_to_part2(g, r)
		_to_part3(g, r)
		var shown := str(r.pages_now(r.data["triggers"].filter(func(t): return String(t["id"]) == "part3")[0]["do"].filter(func(a): return a.has("show"))[0]["show"]["pages"]))
		check("the council: the rider (fed, the Barra burned, the lure), Varenne under a white flag, the King's frame", shown.contains("ms_left")
			and shown.contains("ms_barra_burned") and shown.contains("ms_lure") and shown.contains("v_1") and shown.contains("k_frame")
			and not shown.contains("n_letter"))
		check("THE CHOICE asked (the King's question)", r.fired.has("first_ask") and not r.choice_open.is_empty() and String(r.choice_open.get("id", "")) == "first")
		check("the siege's leftovers gone back over the river", r.tagged("c_wave").is_empty() and r.tagged("m_wave").is_empty())
		r.choose("first", first)
		_walk(g, g.clock + 3.0)
		check("%s first: the flag, the King says so" % first, str(r.flags.get("first")) == first and _said(r, "k_brood" if first == "brood" else "k_clock"))
		check("the night: its objective and dawn's clock", r.fired.has("night") and r.obj.get("night", "") == "active" and r.clocks.has("dawn"))
		_walk(g, float(r.fired["night"]) + 8.0)
		var mine := "n_m0" if first == "brood" else "n_c0"
		var not_mine := "n_c0" if first == "brood" else "n_m0"
		check("%s first: the OTHER fire strikes the fort (%s), not the chosen" % [first, mine], r.tagged(mine).size() >= 4 and r.tagged(not_mine).is_empty())
		_walk(g, float(r.fired["night"]) + 92.0)
		check("the night's last and biggest wave", _said(r, "n_night_big"))
		_kill(r.tagged("c_wave") + r.tagged("m_wave"))
		r.clocks["dawn"] = g.clock + 0.5
		_walk(g, g.clock + 5.0)
		check("dawn: WON for the Crown", g.over and r.winner_side == "crown", "%s %s" % [g.over, r.winner_side])
		check("the flags: first, fort held, sertao many (everyone in)", str(r.flags.get("first")) == first and str(r.flags.get("fort")) == "held"
			and str(r.flags.get("sertao")) == "many", str(r.flags))
	# Varenne executed: the letter on the ford's post; nobody answers: the seed picks
	_progress({"a06_barricades": {"varenne": "executed"}, "d05_aldeia": {"fields": "burned"}})
	var g2: Game = await _start()
	var r2 := g2.mission
	_to_part2(g2, r2)
	_to_part3(g2, r2)
	var shown2 := str(r2.pages_now(r2.data["triggers"].filter(func(t): return String(t["id"]) == "part3")[0]["do"].filter(func(a): return a.has("show"))[0]["show"]["pages"]))
	check("Varenne executed: no envoy, the letter; the fields burned: the swarm starved", shown2.contains("n_letter") and not shown2.contains("v_1")
		and shown2.contains("ms_burned"))
	r2.choice_open["until"] = g2.clock + 0.5
	_walk(g2, g2.clock + 2.0)
	check("unanswered: the match's seed picks one (no canon)", ["brood", "clockwork"].has(str(r2.flags.get("first"))), str(r2.flags.get("first")))
	# few of the road's people in: sertao few
	_progress()
	g2 = await _start()
	r2 = g2.mission
	_walk(g2, 4.0)
	_put(g2, r2.tagged("people").slice(0, 3), _mid(r2, "fort_in"))
	_kill(r2.tagged("people").slice(3))
	_put(g2, _army(g2, r2), _mid(r2, "fort_approach"))
	_walk(g2, g2.clock + 2.0)
	_to_part3(g2, r2)
	r2.choose("first", "brood")
	_walk(g2, g2.clock + 3.0)
	r2.clocks["dawn"] = g2.clock + 0.5
	_walk(g2, g2.clock + 5.0)
	check("three of sixteen in the fort: WON, sertao few", g2.over and r2.winner_side == "crown" and str(r2.flags.get("sertao")) == "few", str(r2.flags))


func _defeat() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 6.0)
	for b in r.tagged("magazine"):
		b.take_damage(999999.0, null)
	_walk(g, g.clock + 3.0)
	check("the magazine blown: LOST", g.over and r.winner_side != "crown" and _said(r, "n_mag_down"), "%s %s" % [g.over, r.winner_side])


# ================================================================== VERSUS: the friend leads the creatures or the automata

func _versus() -> void:
	for pick in ["creatures", "automata"]:
		_progress()
		var g: Game = await _start("versus", pick, pick)
		var r := g.mission
		_walk(g, 3.0)
		var band := "c_band" if pick == "creatures" else "m_band"
		check("versus %s: the friend's band on its bank" % pick, r.tagged(band).size() >= 8, str(r.tagged(band).size()))
		check("... his objective (the magazine), the other side scripted", r.obj.get("c_raid" if pick == "creatures" else "m_raid", "") == "active"
			and r.cond({"playing": pick}))
		_walk(g, 70.0)
		var w := "r1" if pick == "creatures" else "skies"
		check("... his side's raids are his (on his team)", r.tagged(w).is_empty() or r.tagged(w).all(func(u): return u.team == r.team_index(pick))
			or r.fired.has(w))
		for b in r.tagged("magazine"):
			b.take_damage(999999.0, null)
		_walk(g, g.clock + 3.0)
		check("versus %s: the magazine blown: WON for the friend" % pick, g.over and r.winner_side == pick and str(r.flags.get("fort")) == "fallen",
			"%s %s" % [g.over, r.winner_side])


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
	var arm0: int = r.tagged("armoured").filter(func(u): return u.armoured).size()
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
	check("... the armoured men still armoured", g2.mission.tagged("armoured").filter(func(u): return u.armoured).size() == arm0)
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


# ================================================================== the hubs and the war map after d09

func _hubs() -> void:
	_progress()
	Campaign.record(MID, "solo", "crown", "crown", {"first": "brood", "fort": "held", "sertao": "some", "sertao_n": 9})
	var p := Campaign.progress()
	var pro: Dictionary = {}
	var nat: Dictionary = {}
	var clk: Dictionary = {}
	for s in Campaign.index()["storylines"]:
		match String(s["id"]):
			"prologue": pro = s
			"naturalist": nat = s
			"clockmaker": clk = s
	check("the King's study: the King on the swarm first", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["king"], p)).contains("You chose the swarm first"))
	check("the King's study: the Cardinal on the general who chose", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["tomasz"], p)).contains("which way to march"))
	check("the King's study: Ruggieri's dispatch (north)", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["dispatch"], p)).contains("marches north"))
	check("Valadares at the Barra: the army is coming north", str(CampaignMenu.talk_lines(nat["hub"]["talks"]["valadares"], p)).contains("coming north"))
	check("Hollweg (the spring running): the masters agree at once", str(CampaignMenu.talk_lines(clk["hub"]["talks"]["hollweg"], p)).contains("at once"))
	var st := WarMapData.state(p)
	var led: Array = st.get("ledger", []).map(func(x): return String(x.get("text", "")))
	check("the war map: the sertão the Crown's, the fort, the siege's pin waits with its clock", String(st["regions"]["sertao"]) == "crown" and st["marks"]["fort"]
		and String(st["pins"]["d11_siege"]["clock"]) != "" and led.has("Ruggieri chose the swarm first: the army went up the rivers."), str(led.slice(-3)))
	check("the war map's data has no problem", WarMapData.problems().is_empty(), "; ".join(WarMapData.problems()))
	_progress()
	Campaign.record(MID, "solo", "crown", "crown", {"first": "clockwork", "fort": "held", "sertao": "many"})
	p = Campaign.progress()
	check("the city first: the King, the dispatch south, the jungle's pin waits", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["king"], p)).contains("the city first")
		and str(CampaignMenu.talk_lines(pro["hub"]["talks"]["dispatch"], p)).contains("marches south")
		and String(WarMapData.state(p)["pins"]["d10_jungle"]["clock"]) != "")
	_progress()
	Campaign.record(MID, "versus", "creatures", "creatures", {"fort": "fallen"})
	p = Campaign.progress()
	check("a versus friend's win: the seal broken (not how it went)", String(WarMapData.state(p)["pins"][MID]["seal"]) == "broken")
