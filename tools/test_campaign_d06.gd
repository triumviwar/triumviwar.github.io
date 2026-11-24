extends SceneTree
## Act 2's "The Queen" (docs/campaign_d06_build.md):
##   - the data checks out, every text has pt and es, the Naturalist line lists it after d03 and it opens once d03 is won,
##     the seats (solo the Brood, the SOLO PICK of the fazenda, versus), the map (the island in flood) and the stills,
##     THE ROSTER LADDER's B5 (was B6: GROW to stage 3 and the BRUTE), the hub's purse;
##   - THE FLAGS at the start: d03 `hidden` (4 / 6 / 8 young), b01 `rival` (the wild pack's size), b01 / a05 / d03 `pieter`,
##     a06 `varenne` executed (Assembly keepers), b01 `clutch` (the opening's line), every flag missing (the canon);
##   - PART 1: the keepers' LEASH (loose out of a ring, held in one), all the young in the big pen: Part 2 at once;
##   - PART 2: the wild Mother lands, the keepers run home (spared), THE MOTHER'S CALL: a loose creature near another
##     Mother goes over to her ("to": "near"), one held by its own Mother's ring does not; a rival Mother down: her
##     creatures come to the strongest call and join;
##   - PART 3: the eggs held back while she grows, the Queen (stage 3): the show, the leashes gone, the eggs back, the
##     fall's objective, Lindqvist and Pieter run for the canoes (counted); the big house broken: the win and its flags;
##     the Mother dead: lost;
##   - THE MIRROR (the fazenda): three pens burned and Lindqvist at the canoes: won (brood_n few, book taken); the Queen's
##     clock out first: lost;
##   - SAVE AND LOAD in Part 2, IRONMAN, the HUB and the WAR MAP after d06; no script error anywhere.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_d06.gd [-- only=data,flags,part1,...]
## Prints CHECK lines, then "campaign_d06: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "d06_queen"
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
	print("campaign_d06: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if b01, a05, a06, a07 and d03 were won with these flags (each merged over its canon).
func _progress(b01 := {}, a05 := {}, a06 := {}, d03 := {}, diff := "normal", with_d03 := true, none := false) -> void:
	var p := {"reached": [MID], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if not none:
		var f1 := {"clutch": "saved", "eggs": "left", "pieter": "alive", "rival": "standing", "teles": "quiet", "saved": "some"}
		f1.merge(b01, true)
		p["done"]["b01_specimen"] = {"won_by": "sire", "side": "sire", "flags": f1}
		var f5 := {"cages": "some", "cages_n": 2, "eggs": "taken", "pieter": "alive", "way": "short", "crates": "seen"}
		f5.merge(a05, true)
		p["done"]["a05_specimens"] = {"won_by": "expedition", "side": "expedition", "flags": f5}
		var f6 := {"varenne": "spared", "paris": "stood"}
		f6.merge(a06, true)
		p["done"]["a06_barricades"] = {"won_by": "crown", "side": "crown", "flags": f6}
	p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}}
	if with_d03:
		var f3 := {"hidden": "some", "hidden_n": 4, "storm": "hatched", "mother": "linnea", "pieter": "alive", "dinner": "given"}
		f3.merge(d03, true)
		p["done"]["d03_fazenda"] = {"won_by": "stock", "side": "stock", "flags": f3}
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
	_step(g, 2.0)
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


func _count_kind(g: Game, r: MissionRun, team: String, kind: String) -> int:
	var t := r.team_index(team)
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind == kind).size()


## PART 1 done the quick way: every young one into the big pen (the clock steps on until Part 2 starts).
func _to_part2(g: Game, r: MissionRun) -> void:
	var i := 0
	for u in r.tagged("young"):
		u.position = _mid(r, "big_pen") + Vector2((i % 4) * 40 - 60, (i / 4) * 40 - 20 + 60)
		u.velocity = Vector2.ZERO
		u.cmd_stop()
		i += 1
	g._rebuild_hash()
	_walk(g, maxf(g.clock, 13.0) + 3.0)


## PART 2 done the quick way: both rival Mothers killed.
func _to_part3(g: Game, r: MissionRun) -> void:
	_walk(g, float(r.fired.get("part2", g.clock)) + 2.0)
	for tg in ["wild_mother", "pen_mother"]:
		for m in r.tagged(tg):
			m.hp_floor = 0.0
			m.spared = false
			m.take_damage(99999.0, null)
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
	check("d06_queen: data checks out", pr.is_empty(), "; ".join(pr))
	var extra := ["The Mother", "The east pen's Mother", "The wild Mother", "The Boat House at Óbidos"]
	for role in ["grown_mother", "pen_mother", "wild_mother"]:
		extra.append(String(Rebels.ROLES[role]["about"]))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + extra:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission, its roles and the hub has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Naturalist line lists d06 after d03", String(sl.get("id", "")) == "naturalist"
		and (sl["missions"] as Array).find(MID) == (sl["missions"] as Array).find("d03_fazenda") + 1)
	check("d03's next is d06 (both sides)", str(Campaign.mission("d03_fazenda")["next"]) == str({"stock": MID, "commission": MID}))
	_progress({}, {}, {}, {}, "normal", false)
	var pp := Campaign.progress()
	pp["reached"] = []
	Campaign.save_progress(pp)
	check("d06 is shut until d03 is won", not Campaign.unlocked(MID))
	_progress()
	check("... and open once it is", Campaign.unlocked(MID))
	check("the seats: solo the Brood, the SOLO PICK the fazenda", Campaign.solo_sides(m) == ["brood", "fazenda"])
	var c := Campaign.make_cfg(MID, "solo", "p1", false, "fazenda")
	var you: Array = (c["slots"] as Array).filter(func(s): return String(s["who"]) == "you").map(func(s): return String(s["team_id"]))
	check("the fazenda picked: the fazenda's team is the player's", you == ["fazenda"], str(you))
	check("versus: the Brood p1, the fazenda p2", Campaign.seat_side(m, "versus", "p1") == "brood" and Campaign.seat_side(m, "versus", "p2") == "fazenda")
	var md := Campaign.map_data("obidos_flood")
	check("the map is the island in flood, in the jungle", md.get("biome", "") == "jungle" and String(md.get("cells", "")).count("f") > 1000,
		str(String(md.get("cells", "")).count("f")))
	for k in m["stills"]:
		check("still %s is in" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	var st: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "stock")[0]
	check("THE ROSTER LADDER B5 (was B6): GROW to stage 3 and the BRUTE, both NEW", (st["roster"]["allow"] as Array).has("stage3")
		and (st["roster"]["allow"] as Array).has("brute") and (st["roster"]["new"] as Array) == ["stage3", "brute"]
		and not (st["roster"]["allow"] as Array).has("nb_pack_hunt"))
	check("hubs-grow: d06 earns FIELD NOTES", (HubGrow.line("naturalist")["earn"] as Array).has(MID))
	# THE BROOD IS NOT A PERSON: no creature is named Linnea, no line gives one a will
	var all := " ".join(Campaign.strings_of(m))
	check("no creature named (no Linnea) and no 'her young' in the mission's texts", not all.contains("Linnea") and not all.contains("her young")
		and not all.contains("comes for"), "")


# ================================================================== the flags at the start

func _flags() -> void:
	_progress({}, {}, {}, {}, "normal", true, true)
	var g: Game = await _start()
	var r := g.mission
	check("every earlier flag missing (d03 only): the canon, 6 young, Pieter", int(r.counters["young_n"]) == 6 and r.tagged("pieter").size() == 1, str(r.counters["young_n"]))
	_progress()
	g = await _start()
	r = g.mission
	check("the canon (d03 hidden some): 6 young in the two flooded pens", int(r.counters["young_n"]) == 6, str(r.counters["young_n"]))
	check("the player plays the Brood (green) with one Mother, two Sires, two Mound Turtles", g.human == r.team_index("stock")
		and g.factions[g.human] == "brood" and r.tagged("mother").size() == 1 and r.tagged("sires").size() == 2 and r.tagged("turtles").size() == 2)
	check("the opening: the first Mother from the station's clutch", str(r.pages_now(Campaign.show_pages(r.data, "opening", "brood"))).contains("l_open_saved"))
	check("four keepers and Lindqvist and Pieter carry the lures", r.tagged("lure").size() == 6, str(r.tagged("lure").size()))
	check("the Mother at stage 2", BroodNew.stage(r.tagged("mother")[0]) == 1)
	_walk(g, 6.0)
	check("she and the Sires root where they stand (the scene as set)", r.tagged("mother")[0].order == "nb_root" or BroodNew.rooted(r.tagged("mother")[0]))
	_progress({"clutch": "burned", "pieter": "lost"}, {}, {"varenne": "executed"}, {"hidden": "all"})
	g = await _start()
	r = g.mission
	check("d03 hidden all: 8 young", int(r.counters["young_n"]) == 8, str(r.counters["young_n"]))
	check("Pieter lost: no Pieter", r.tagged("pieter").is_empty())
	check("Varenne executed: the keepers are Assembly men", r.tagged("keepers").all(func(u): return String(u.get_meta("rebel_role", "")) == "assembly_keeper"))
	check("clutch burned: the Mother netted on the mountain", str(r.pages_now(Campaign.show_pages(r.data, "opening", "brood"))).contains("l_open_burned"))
	_progress({}, {}, {}, {"hidden": "few"})
	g = await _start()
	r = g.mission
	check("d03 hidden few: 4 young", int(r.counters["young_n"]) == 4, str(r.counters["young_n"]))
	_progress({}, {}, {}, {"pieter": "lost"})
	g = await _start()
	r = g.mission
	check("d03's Pieter lost: no Pieter here either", r.tagged("pieter").is_empty())
	# b01 rival: the wild pack's size at the landing
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	var big := r.tagged("wild_pack").size()
	_progress({"rival": "driven"})
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	check("b01's rival pack standing: the wild pack is bigger", big > r.tagged("wild_pack").size(), "%d v %d" % [big, r.tagged("wild_pack").size()])


# ================================================================== PART 1: the flood, the keepers' leash

func _part1() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 9.0)
	check("the NEW cards for B5 are said", _said(r, "new_stage3") and _said(r, "new_brute"))
	check("the objectives say what to do: the flood, its clock, the Mother must live", r.obj.get("flood", "") == "active"
		and r.obj.get("flood_clock", "") == "active" and r.obj.get("mother_live", "") == "active")
	check("the intro lines teach the rings (SAY IT PLAINLY)", _said(r, "l_1") and _said(r, "p_tip1") and _said(r, "n_lesson"))
	var rp: Unit = r.tagged("young").filter(func(u): return u.kind == "raptor")[0]
	_put(g, [rp], _mid(r, "way_e") + Vector2(0, 6 * Defs.TILE))
	_walk(g, g.clock + 1.0)
	check("the leash: a raptor out of every keeper's ring is LOOSE", r.cond({"loose": {"name": "stock"}}) and rp.has_meta("leash_loose"))
	_put(g, [r.tagged("keeper_e")[0]], rp.position + Vector2(30, 0))
	_walk(g, g.clock + 1.0)
	check("... a keeper beside it: HELD again", not rp.has_meta("leash_loose"))
	_walk(g, 36.0)
	check("the call over the water at 0:35, and the line", r.fired.has("call") and _said(r, "n_call"))
	check("Part 2 not before every young one is up", not r.fired.has("part2"))
	_to_part2(g, r)
	check("all in the big pen: the flood done and Part 2 at once (NO WAITING)", r.obj.get("flood", "") == "hidden" and r.fired.has("all_in") and r.fired.has("part2"))


# ================================================================== PART 2: the Mothers fight

func _part2() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_walk(g, g.clock + 4.0)
	check("the wild Mother lands with her pack, the line", r.tagged("wild_mother").size() == 1 and r.tagged("wild_pack").size() >= 3 and _said(r, "n_wild"))
	check("the objective: the Mothers fight, the ring explained", r.obj.get("mothers", "") == "active" and _said(r, "n_mring"))
	var kp: Unit = r.tagged("keepers")[0]
	check("the keepers run for the house and nobody targets them (the truce)", kp.spared and kp.order != "idle")
	var wm: Unit = r.tagged("wild_mother")[0]
	var mo: Unit = r.tagged("mother")[0]
	# a creature far from its Mother and near the wild one goes over to her
	var ys: Array = r.tagged("young")
	var far: Unit = ys[0]
	_put(g, [wm], _mid(r, "pen_1"))
	_put(g, [far], wm.position + Vector2(2.0 * Defs.TILE, 0))
	var held: Unit = ys[1]
	_walk(g, g.clock + 1.0)
	check("a young one out of her ring is loose", far.has_meta("leash_loose") or far.has_meta("leash_turning"))
	_walk(g, g.clock + 3.5)
	check("... near the wild Mother: THE LEASH BREAKS, it is hers", far.team == r.team_index("wild") and int(r.counters["lost_n"]) >= 1,
		"team %d lost %d" % [far.team, int(r.counters["lost_n"])])
	check("... and a line says so", _said(r, "n_lost"))
	# one held inside its own Mother's ring does not break, even next to the other Mother
	_put(g, [wm], mo.position + Vector2(9.0 * Defs.TILE, 0))
	_put(g, [held], mo.position + Vector2(6.0 * Defs.TILE, 0))
	_walk(g, g.clock + 4.0)
	check("one inside its own Mother's ring stays hers beside the wild Mother", held.dead or held.team == r.team_index("stock"))
	_put(g, [wm], _mid(r, "pen_1"))
	# the wild Mother down: her creature comes to the strongest call and joins
	wm.take_damage(99999.0, null)
	_walk(g, g.clock + 1.0)
	check("the wild Mother down: counted, the line", int(r.counters["mothers_down"]) == 1 and _said(r, "n_wild_down"))
	_put(g, [far], mo.position + Vector2(4.0 * Defs.TILE, 0))
	_walk(g, g.clock + 4.0)
	check("... her creature near the Mother joins the Brood", far.dead or far.team == r.team_index("stock"), "team %d" % far.team)
	check("the east pen's Mother breaks out at its time", r.fired.has("east_go") or float(r.fired["part2"]) + 75.0 > g.clock)
	_walk(g, float(r.fired["part2"]) + 76.0)
	check("... she is out of her pen and coming, the line", r.fired.has("east_go") and _said(r, "n_east") and not r.tagged("pen_mother")[0].spared)


# ================================================================== PART 3: the Queen, the fall

func _part3() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_to_part3(g, r)
	check("both rival Mothers down: Part 3, the Queen's objective, the food given", r.fired.has("part3") and r.obj.get("queen", "") == "active"
		and int(g.players[g.human]["gold"]) >= 500, str(g.players[g.human]["gold"]))
	var mo: Unit = r.tagged("mother")[0]
	check("the eggs are held back while she grows (the food is for GROW)", BroodNew.lay_problem(g, mo, "raptor").begins_with("Not now"), BroodNew.lay_problem(g, mo, "raptor"))
	check("GROW is open to her (stage 3 on the ladder)", not g.mission.denied(mo.team, "stage3"))
	check("the fazenda wakes: the keepers are no longer spared", not r.tagged("keepers")[0].spared)
	# she grows (as GROW would end: stage 3)
	r.a2.brood_stage({"tag": "mother", "stage": 3})
	_walk(g, g.clock + 1.0)
	check("the Queen: stage 3, the flag, the show, her name", r.fired.has("queen") and str(r.flags.get("queen")) == "grown"
		and String(mo.get_meta("mission_name", "")) == "The Queen")
	check("... the eggs back, every leash gone", BroodNew.lay_problem(g, mo, "raptor") == "" or not BroodNew.lay_problem(g, mo, "raptor").begins_with("Not now")
		and r.a2.loose_count("", "") == 0)
	_walk(g, g.clock + 4.0)
	check("the fall's objective and its line", r.obj.get("fall", "") == "active" and _said(r, "n_fall"))
	_walk(g, g.clock + 4.0)
	check("Lindqvist and Pieter run for the canoes; the lure book left", r.fired.has("run_go") and str(r.flags.get("book")) == "left")
	# they reach the canoes: counted
	_put(g, r.tagged("runners"), _mid(r, "canoes"))
	_walk(g, g.clock + 1.0)
	check("... at the canoes they are gone, counted", int(r.counters["fled_l"]) == 1 and int(r.counters["fled_p"]) == 1)
	_walk(g, g.clock + 10.0)
	check("food comes in after the Queen (the fall never stalls)", r.fired.has("queen_food"))
	# the big house broken
	for h in r.tagged("big_house"):
		h.take_damage(999999.0, null)
	_walk(g, g.clock + 8.0)
	check("the big house broken: WON for the Brood", g.over and r.winner_side == "brood", "%s %s" % [g.over, r.winner_side])
	check("the flags: brood_n, pieter alive, lindqvist fled, book left", r.flags.has("brood_n") and str(r.flags.get("pieter")) == "alive"
		and str(r.flags.get("lindqvist")) == "fled" and str(r.flags.get("book")) == "left", str(r.flags))
	# Pieter caught before the canoes
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	_to_part3(g, r)
	r.a2.brood_stage({"tag": "mother", "stage": 3})
	_walk(g, g.clock + 12.0)
	for p in r.tagged("pieter"):
		p.take_damage(99999.0, null)
	_walk(g, g.clock + 1.0)
	for h in r.tagged("big_house"):
		h.take_damage(999999.0, null)
	_walk(g, g.clock + 8.0)
	check("Pieter killed before the canoes: pieter lost, the line", str(r.flags.get("pieter")) == "lost" and _said(r, "n_pieter_lost"), str(r.flags))


func _defeat() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	var mo: Unit = r.tagged("mother")[0]
	mo.take_damage(999999.0, null)
	_walk(g, g.clock + 3.0)
	check("the Mother dead: LOST", g.over and r.winner_side != "brood", "%s %s" % [g.over, r.winner_side])


# ================================================================== THE MIRROR: the fazenda

func _mirror() -> void:
	_progress()
	var g: Game = await _start("fazenda")
	var r := g.mission
	check("the fazenda picked: its team is the player's, the Brood scripted", g.human == r.team_index("fazenda"))
	_walk(g, 18.0)
	check("Part 2 comes quickly (no flood to walk), the burn and canoes objectives, the Queen's clock",
		r.fired.has("part2") and r.obj.get("f_burn", "") == "active" and r.obj.get("f_canoes", "") == "active" and r.clocks.has("queen"))
	check("the Mothers can't be killed by muskets (a floor)", r.tagged("mother")[0].hp_floor > 0.0)
	var men: Array = r.tagged("keepers")
	for a in ["burn_big", "pen_2", "pen_3"]:
		for u in r.tagged("young"):
			if r.area_rect(a).grow(4 * Defs.TILE).has_point(u.position):
				u.take_damage(99999.0, null)        # (the guns cleared it)
		_put(g, men.slice(0, 2), _mid(r, a))
		_walk(g, g.clock + 5.0)
	check("three pens burned", int(r.counters["burned"]) == 3 and r.obj.get("f_burn", "") == "done", str(r.counters["burned"]))
	_put(g, r.tagged("lindqvist"), _mid(r, "canoes"))
	_walk(g, g.clock + 6.0)
	check("Lindqvist at the canoes: WON for the fazenda", g.over and r.winner_side == "fazenda", "%s %s" % [g.over, r.winner_side])
	check("the mirror's flags: brood_n few, book taken, lindqvist fled", str(r.flags.get("brood_n")) == "few" and str(r.flags.get("book")) == "taken"
		and str(r.flags.get("lindqvist")) == "fled", str(r.flags))
	# the Queen's clock out first: lost
	_progress()
	g = await _start("fazenda")
	r = g.mission
	_walk(g, 18.0)
	r.clocks["queen"] = g.clock + 0.5
	_walk(g, g.clock + 3.0)
	check("the Queen grows before the pens burn: LOST", g.over and r.winner_side != "fazenda" and str(r.flags.get("queen")) == "grown", "%s %s" % [g.over, r.winner_side])


# ================================================================== save and load, ironman

func _snap(g: Game) -> Dictionary:
	var r := g.mission
	var tags := {}
	for k in r.tags:
		tags[k] = r.tagged(k).size()
	return {"flags": r.flags, "counters": r.counters, "obj": r.obj, "tags": tags, "fired": r.fired.keys().size(),
		"leashes": (r.act2.get("leashes", []) as Array).map(func(l): return String(l["name"]))}


func _save_load() -> void:
	_progress()
	MissionSave.clear_all(MID)
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_walk(g, g.clock + 5.0)
	var before := _snap(g)
	main.mission_save_now()
	check("SAVE written in the Mothers' fight", MissionSave.has(MID, "save"))
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
	check("LOADED the same: flags, counters, objectives, tags, the leashes", diff.is_empty(), "; ".join(diff))
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


# ================================================================== the hub and the war map after d06

func _hubs() -> void:
	_progress()
	Campaign.record(MID, "solo", "brood", "brood", {"brood_n": "some", "brood_n_n": 6, "pieter": "alive", "lindqvist": "fled", "book": "left", "queen": "grown"})
	var p := Campaign.progress()
	var sl := Campaign.storyline_of(MID)
	var lq: Dictionary = sl["hub"]["talks"]["lindqvist"]
	check("the hub: Lindqvist blames the flood, and the lure book is in the house", str(CampaignMenu.talk_lines(lq, p)).contains("flood did it")
		and str(CampaignMenu.talk_lines(lq, p)).contains("lure book"))
	check("the hub is the boat house at Óbidos now", String(CampaignMenu.hub_now(sl["hub"], p).get("title", "")) == "The Boat House at Óbidos", str(CampaignMenu.hub_now(sl["hub"], p).get("title", "")))
	var st := WarMapData.state(p)
	var led: Array = st.get("ledger", []).map(func(x): return String(x.get("text", "")))
	check("the war map: the island the Brood's, the Queen's mark, the ledger", String(st["regions"]["island"]) == "brood" and st["marks"]["queen"]
		and led.has("Some of the bred creatures went to the Queen."), str(led.slice(-4)))
	check("the war map's data has no problem", WarMapData.problems().is_empty(), "; ".join(WarMapData.problems()))
	_progress()
	Campaign.record(MID, "solo", "brood", "brood", {"brood_n": "few", "pieter": "lost", "lindqvist": "fled", "book": "left", "queen": "grown"})
	p = Campaign.progress()
	check("Pieter lost: Lindqvist is alone, and the war map says so", str(CampaignMenu.talk_lines(lq, p)).contains("Pieter stayed")
		and WarMapData.state(p).get("ledger", []).map(func(x): return String(x.get("text", ""))).has("Pieter did not reach the canoes."))
	_progress()
	Campaign.record(MID, "solo", "fazenda", "fazenda", {"brood_n": "few", "pieter": "alive", "lindqvist": "fled", "book": "taken"})
	p = Campaign.progress()
	check("a fazenda's win: Lindqvist burned three pens; not a broken seal", str(CampaignMenu.talk_lines(lq, p)).contains("burned three pens")
		and String(WarMapData.state(p)["pins"][MID]["seal"]) != "broken")
