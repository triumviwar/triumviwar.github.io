extends SceneTree
## Act 2's "The Island" (docs/campaign_d03_build.md):
##   - the data checks out, every text has pt and es, the Naturalist line lists it after the Council of Rome and it opens
##     only once a07 is won (`needs`), the seats (solo the stock, the SOLO PICK of the commission, versus), the map and the
##     stills, THE ROSTER LADDER's B4 for the stock (the Storm Sire and the Hatchlings), the hub's purse and reach;
##   - THE FLAGS at the start: a05 `cages` (3 / 5 / 7 young, the young Sire with all), b01 `eggs` taken (two Raptors more),
##     b01 / a05 `pieter` (Pieter, a lure), a06 `varenne` executed (the Assembly guards), b01 `clutch` (the opening's line),
##     a03 `map` (the search's length);
##   - PART 1: THE LEASH (held in a lure's ring, loose out of it), the deep forest counted, the Storm Sire hatches (B4) and
##     the Mother is at stage 2 (Hatchlings possible), the canoes land sooner once all is hidden;
##   - PART 2: the commission lands, the stock HIDDEN from it (still: found only close up; moving: in sight), the quiet
##     rule (no creature bites, nobody shoots the fazenda's people), the dinner, a decoy (a lure post), TRACKS for the
##     commission; too much found: lost;
##   - PART 3: the restless young one (the newest leash: a lure right beside it, or it goes for the goats), brought back;
##     reaching the goats: lost; dawn: the win and its flags (`hidden`, `storm`, `mother`, `pieter`), the ending, debrief;
##   - THE MIRROR (the commission): the stock asleep in its pens, the commission's men the player's, half destroyed: won;
##     passive: dawn, lost;
##   - SAVE AND LOAD in the middle (as test_campaign_save), IRONMAN, the HUBS and the WAR MAP after d03.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_d03.gd
## Prints CHECK lines, then "campaign_d03: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "d03_fazenda"
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
	print("campaign_d03: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if b01, a03, a05, a06 and a07 were won with these flags (each merged over its canon), at a difficulty.
func _progress(b01 := {}, a03 := {}, a05 := {}, a06 := {}, diff := "normal", with_a07 := true) -> void:
	var p := {"reached": [MID], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	var f1 := {"clutch": "saved", "eggs": "left", "pieter": "alive", "rival": "standing", "teles": "quiet", "saved": "some"}
	f1.merge(b01, true)
	p["done"]["b01_specimen"] = {"won_by": "sire", "side": "sire", "flags": f1}
	var f3 := {"map": "drawn", "party": "some", "survey": "full", "linnea": "seen"}
	f3.merge(a03, true)
	p["done"]["a03_plateau"] = {"won_by": "party", "side": "party", "flags": f3}
	var f5 := {"cages": "some", "cages_n": 2, "eggs": "taken", "pieter": "alive", "way": "short", "crates": "seen"}
	f5.merge(a05, true)
	p["done"]["a05_specimens"] = {"won_by": "expedition", "side": "expedition", "flags": f5}
	var f6 := {"varenne": "spared", "paris": "stood"}
	f6.merge(a06, true)
	p["done"]["a06_barricades"] = {"won_by": "crown", "side": "crown", "flags": f6}
	if with_a07:
		p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}}
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


func _young(r: MissionRun) -> Array:
	return r.tagged("young")


## PART 1 done the quick way: every young one and the lures into the deep forest (the nest clearing), the Mother rooted,
## the Storm Sire's Hatchlings laid (the objectives set as the triggers would).
func _hide_all(g: Game, r: MissionRun) -> void:
	_put(g, r.tagged("lure"), _mid(r, "pen_5"))
	var ys := _young(r)
	var i := 0
	for u in ys:
		u.position = _mid(r, "pen_5") + Vector2((i % 3) * 40 - 40, (i / 3) * 40 - 40)
		u.velocity = Vector2.ZERO
		u.cmd_stop()
		i += 1
	g._rebuild_hash()


# ================================================================== run

func _run() -> void:
	await process_frame
	_data()
	await _flags()
	await _part1()
	await _part2()
	await _part3()
	await _defeats()
	await _mirror()
	await _save_load()
	await _ironman()
	_hubs()
	check("no script error in the whole run", _errs.is_empty(), str(_errs.slice(0, 3)))
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("d03_fazenda: data checks out", pr.is_empty(), "; ".join(pr))
	var extra := ["The young Mother", "Keeper", "Assembly guard", "Desembargador Fonseca", "Lindqvist's fazenda", "The island",
		"Dry season 2772", "The Fazenda's Study"]
	for role in ["young_mother", "keeper", "assembly_keeper", "fonseca"]:
		extra.append(String(Rebels.ROLES[role]["about"]))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + extra:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission, its roles and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Naturalist line lists d03 after the Council of Rome", String(sl.get("id", "")) == "naturalist"
		and (sl["missions"] as Array).find(MID) == (sl["missions"] as Array).find("a07_council") + 1)
	_progress({}, {}, {}, {}, "normal", false)
	check("d03 is shut until the Council of Rome is won (needs a07)", not Campaign.unlocked(MID))
	_progress()
	check("... and open once it is", Campaign.unlocked(MID))
	check("the seats: solo the stock, the SOLO PICK the commission", Campaign.solo_sides(m) == ["stock", "commission"])
	var c := Campaign.make_cfg(MID, "solo", "p1", false, "commission")
	var you: Array = (c["slots"] as Array).filter(func(s): return String(s["who"]) == "you").map(func(s): return String(s["team_id"]))
	check("the commission picked: the commission's team is the player's", you == ["commission"], str(you))
	check("versus: the stock p1, the commission p2", Campaign.seat_side(m, "versus", "p1") == "stock" and Campaign.seat_side(m, "versus", "p2") == "commission")
	check("the map is the island in the jungle", Campaign.map_data("obidos_island").get("biome", "") == "jungle")
	for k in m["stills"]:
		check("still %s is in" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	var st: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "stock")[0]
	check("THE ROSTER LADDER B4: the stock may have the Storm Sire and the Hatchlings, both NEW",
		(st["roster"]["allow"] as Array).has("pterodactyl") and (st["roster"]["new"] as Array) == ["pterodactyl", "hatchlings"])
	check("hubs-grow: d03 earns FIELD NOTES and the Naturalist's rooms reach it", (HubGrow.line("naturalist")["earn"] as Array).has(MID)
		and HubGrow.line_for(MID) == "naturalist" and HubGrow.line_for(MID, "commission") == "")


# ================================================================== the flags at the start

func _count_kind(g: Game, r: MissionRun, team: String, kind: String) -> int:
	var t := r.team_index(team)
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind == kind).size()


func _flags() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	check("the canon (cages some): the young Mother and 5 young", int(r.counters["young_n"]) == 6 and r.tagged("mother").size() == 1, str(r.counters["young_n"]))
	check("Lindqvist, Pieter and two keepers carry the lures", r.tagged("lure").size() == 4 and r.tagged("pieter").size() == 1)
	check("the opening: Linnea's daughter (clutch saved)", str(r.pages_now(Campaign.show_pages(r.data, "opening", "stock"))).contains("l_open_linnea"))
	check("the player plays the stock (Brood, green)", g.human == r.team_index("stock") and g.factions[g.human] == "brood")
	check("the young Mother is at stage 2 (the Hatchlings need it)", BroodNew.stage(r.tagged("mother")[0]) == 1)
	_progress({"eggs": "taken", "clutch": "burned", "pieter": "lost"}, {}, {"cages": "all"}, {"varenne": "executed"})
	g = await _start()
	r = g.mission
	check("cages all + eggs taken: 7 young, the young Sire among them, two Raptors more", int(r.counters["young_n"]) == 10
		and _count_kind(g, r, "stock", "tyrannosaur") == 1, str(r.counters["young_n"]))
	check("Pieter lost: no Pieter, the two keepers and Lindqvist carry the lures", r.tagged("pieter").is_empty() and r.tagged("lure").size() == 3)
	check("Varenne executed: two Assembly guards at the house", r.tagged("guards").size() == 2)
	check("clutch burned: the Mother netted on the plateau", str(r.pages_now(Campaign.show_pages(r.data, "opening", "stock"))).contains("l_open_plateau"))
	_progress({}, {}, {"cages": "few"})
	g = await _start()
	r = g.mission
	check("cages few: the young Mother and 3 young", int(r.counters["young_n"]) == 4, str(r.counters["young_n"]))
	_progress({}, {"map": "withheld"})
	g = await _start()
	r = g.mission
	_walk(g, float(r.clocks["boat"]) + 1.0)
	check("a03's map withheld: the search runs longer (5:30)", r.clocks.has("dusk") and float(r.clocks["dusk"]) - g.clock > 320.0,
		str(float(r.clocks.get("dusk", 0.0)) - g.clock))


# ================================================================== PART 1: the leash, the deep forest, the Storm Sire

func _part1() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 9.0)
	check("the NEW cards for B4 are said", _said(r, "new_pterodactyl") and _said(r, "new_hatchlings"))
	check("the objectives say what to do: move the stock, root the Mother, the canoes' clock", r.obj.get("hide_stock", "") == "active"
		and r.obj.get("root_mother", "") == "active" and r.obj.get("boat_clock", "") == "active")
	# THE LEASH: a raptor walked away from every lure goes LOOSE; back beside a keeper it is HELD
	var rp: Unit = r.tagged("leashed").filter(func(u): return u.kind == "raptor")[0]
	_put(g, [rp], _mid(r, "fields_e"))
	_walk(g, g.clock + 1.0)
	check("the leash: a raptor out of every lure's ring is LOOSE", r.cond({"loose": {"name": "stock"}}) and rp.has_meta("leash_loose"))
	_walk(g, g.clock + 4.0)
	check("... and a line explains it (SAY IT PLAINLY)", _said(r, "n_loose"))
	_put(g, [r.tagged("keeper")[0]], rp.position + Vector2(30, 0))
	_walk(g, g.clock + 1.0)
	check("... a keeper beside it: HELD again", not rp.has_meta("leash_loose"))
	# the deep forest counted
	_hide_all(g, r)
	_walk(g, g.clock + 2.5)
	check("the deep forest counted: every young one there", int(r.counters["deep"]) == int(r.counters["young_n"]), "%d / %d" % [r.counters["deep"], r.counters["young_n"]])
	# the Storm Sire hatches (B4)
	_walk(g, 46.0)
	check("the Storm Sire hatches at 0:45 (the objective, the food for the Hatchlings)", r.tagged("storm_sire").size() == 1 and r.obj.get("storm", "") == "active"
		and int(g.players[g.human]["gold"]) >= 400 and str(r.flags.get("storm")) == "hatched")
	var mo: Unit = r.tagged("mother")[0]
	var ss: Unit = r.tagged("storm_sire")[0]
	check("the Hatchlings: not laid without the Storm Sire rooted by her", BroodNew.lay_problem(g, mo, "hatchlings") != "")
	# root them both for real (the game's own rooting, a few seconds)
	var mspot := _mid(r, "nest")
	for off in [Vector2(0, -24), Vector2(0, 0), Vector2(40, -24), Vector2(-40, -24), Vector2(0, 40)]:
		if BroodRoot.place_problem(g, mo.team, mo.kind, _mid(r, "nest") + off, mo, false, BroodRoot.scale_of(mo)) == "":
			mspot = _mid(r, "nest") + off
			break
	_put(g, [mo], mspot)
	_put(g, [ss], mspot + Vector2(0, 5.0 * Defs.TILE))
	_put(g, r.tagged("lindqvist"), mspot + Vector2(-3.0 * Defs.TILE, 2.0 * Defs.TILE))      # (a lure by them: the leash holds them)
	BroodRoot.start_root(mo, mspot)
	for i in 2400:
		await physics_frame
		if BroodNew.rooted(mo):
			break
	check("the young Mother roots in the nest clearing", BroodNew.rooted(mo), "%s order=%s mode=%s pos=%s spot=%s pace=%s" % [BroodRoot.place_problem(g, mo.team, mo.kind, mspot, mo, false, BroodRoot.scale_of(mo)), mo.order, mo.tesla_mode, str(mo.position / Defs.TILE), str(mspot / Defs.TILE), mo.m_pace])
	var spot := Vector2.INF
	for off in [Vector2(130, 0), Vector2(-130, 0), Vector2(0, 110), Vector2(0, -110), Vector2(160, 60)]:
		if BroodRoot.place_problem(g, ss.team, ss.kind, mo.position + off, ss, false, BroodRoot.scale_of(ss)) == "":
			spot = mo.position + off
			break
	check("there is room beside her for the Storm Sire", spot != Vector2.INF)
	if spot != Vector2.INF:
		_put(g, [ss], spot)
		BroodRoot.start_root(ss, spot)
		for i in 400:
			await physics_frame
			if BroodNew.rooted(ss):
				break
	check("the Storm Sire roots beside her", BroodNew.rooted(ss))
	mo.nb["eggs"] = maxi(1, int(mo.nb.get("eggs", 0)))
	check("... and the Hatchlings may be laid now (B4)", BroodNew.lay_problem(g, mo, "hatchlings") == "", BroodNew.lay_problem(g, mo, "hatchlings"))
	_walk(g, g.clock + 1.0)
	check("the Mother rooted in the deep forest: its objective ticked", r.obj.get("root_mother", "") == "done")
	r.act({"spawn": {"team": "stock", "kind": "hatchlings", "count": 2, "at": "nest", "tag": "test_hatch"}})
	_walk(g, g.clock + 4.0)
	check("Hatchlings out: the Storm Sire's objective done, they are the commission's 'birds' (spared)", r.obj.get("storm", "") == "done"
		and r.tagged("hatchling").all(func(u): return u.spared))
	_hide_all(g, r)
	_walk(g, g.clock + 1.5)
	check("all hidden, the Mother and the Storm Sire rooted: the canoes land at once (NO WAITING)", r.fired.has("ready"))
	_walk(g, g.clock + 2.0)
	check("Part 2: the commission lands", r.fired.has("part2") and r.tagged("valadares").size() == 1)


# ================================================================== PART 2: the search

func _to_part2(g: Game, r: MissionRun) -> void:
	_hide_all(g, r)
	r.act({"objective": {"id": "root_mother", "set": "done"}})
	r.act({"objective": {"id": "storm", "set": "done"}})
	_walk(g, float(r.clocks["boat"]) + 6.0)


func _part2() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	check("the commission's parties, the riders, Valadares with his guard", r.tagged("party_a").size() == 4 and r.tagged("party_b").size() == 4
		and r.tagged("party_c").size() == 4 and r.tagged("riders").size() == 4 and r.tagged("v_guard").size() == 2)
	var ys := _young(r)
	check("the stock is HIDDEN from the commission", ys.all(func(u): return r.a2.is_hidden(u)), str(ys.filter(func(u): return not r.a2.is_hidden(u)).map(func(u): return u.kind)))
	_walk(g, g.clock + 15.0)
	check("the quiet rule: the stock bites nobody, the fazenda's people fire no shot and are not shot",
		ys.all(func(u): return u.m_unarmed) and r.tagged("people").all(func(u): return u.m_unarmed and u.spared),
		str(ys.filter(func(u): return not u.m_unarmed).map(func(u): return u.kind)) + str(r.tagged("people").filter(func(u): return not (u.m_unarmed and u.spared)).map(func(u): return u.kind)))
	check("the forest's shade: the commission sees less far", r.mist_sight < 1.0 and r.mist_teams.has(r.team_index("commission")))
	# STILL: found only close up
	var y: Unit = ys.filter(func(u): return u.kind == "raptor")[0]
	var man: Unit = r.tagged("party_a")[0]
	r._routes.clear()
	for u in r.tagged("searchers") + r.tagged("valadares"):
		u.cmd_stop()
		u.position = _mid(r, "landing")
	g._rebuild_hash()
	_walk(g, g.clock + 4.0)
	check("a still raptor lies low", r.a2.lies_low(y))
	man.position = y.position + Vector2(3.2 * Defs.TILE, 0)
	g._rebuild_hash()
	_walk(g, g.clock + 1.0)
	check("... a searcher 3 tiles off sees nothing", r.a2.is_hidden(y) and int(r.counters["found"]) == 0)
	man.position = y.position + Vector2(1.5 * Defs.TILE, 0)
	g._rebuild_hash()
	_walk(g, g.clock + 0.5)
	check("... at a step and a half: FOUND (counted, open to the musket)", not r.a2.is_hidden(y) and int(r.counters["found"]) == 1 and _said(r, "n_found"))
	# MOVING: seen in a searcher's sight
	var y2: Unit = ys.filter(func(u): return u != y and u.kind != "brood_mother" and u.kind != "pterodactyl")[0]
	man.position = y2.position + Vector2(4.0 * Defs.TILE, 0)
	g._rebuild_hash()
	y2.velocity = Vector2(60, 0)
	_step(g, g.clock + 0.25)
	check("a moving one is seen as far as a searcher sees (4 tiles in the shade)", not r.a2.is_hidden(y2) and int(r.counters["found"]) == 2)
	man.position = _mid(r, "landing")
	# TRACKS for the commission
	check("the commission reads tracks (set for it)", (r.act2.get("tracks", []) as Array).any(func(t): return String(t["for"]) == "commission"))
	# THE DINNER: Lindqvist at the door
	_walk(g, g.clock + 25.0)
	check("the dinner is offered (an objective, a line)", r.obj.get("dinner", "") == "active" and _said(r, "l_dinner"))
	_put(g, r.tagged("lindqvist"), _mid(r, "house_door"))
	_walk(g, g.clock + 6.0)
	check("THE DINNER: the magistrate and his party go to the house (flag dinner given)", r.fired.has("dinner") and str(r.flags.get("dinner")) == "given"
		and r.tagged("party_b").all(func(u): return u.order_point.distance_to(_mid(r, "house")) < 6.0 * Defs.TILE))
	# A DECOY: a keeper at the chapel
	_walk(g, g.clock + 15.0)
	check("the decoy is offered", r.obj.get("decoy", "") == "active")
	_put(g, r.tagged("keeper").slice(0, 1), _mid(r, "chapel"))
	_walk(g, g.clock + 5.0)
	check("A DECOY: a lure post at the chapel, the objective done", r.fired.has("decoy_chapel") and r.obj.get("decoy", "") == "done"
		and (r.act2.get("posts", []) as Array).any(func(p): return String(p["tag"]) == "decoy_chapel"))
	# the warning: a party near a pen with the stock in it
	_hide_all(g, r)
	_put(g, r.tagged("party_c").slice(0, 1), _mid(r, "pen_5") + Vector2(0, 7.5 * Defs.TILE))
	_walk(g, g.clock + 1.0)
	check("a party near a pen: pinged, a line (SAY IT PLAINLY, NO WAITING)", r.fired.has("warn_pen_5") and int(r.counters["warned"]) >= 1)


# ================================================================== PART 3: the last night, dawn, the win

func _part3() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	r._routes.clear()
	for u in r.tagged("searchers") + r.tagged("valadares"):
		u.cmd_stop()
		u.position = _mid(r, "camp")
	g._rebuild_hash()
	# keep every lure far from the young (the restless one is one nobody watches)
	_put(g, r.tagged("lure"), _mid(r, "pen_3"))
	_walk(g, float(r.clocks["dusk"]) + 1.0)
	check("Part 3: night, the commission camps, the night's objective", r.fired.has("part3") and r.obj.get("night", "") == "active"
		and r.obj.get("search", "") == "done" and r.clocks.has("dawn"))
	_walk(g, g.clock + 13.0)
	var rs: Array = r.tagged("restless")
	check("the restless young one is up (one of them, tagged)", rs.size() == 1 and r.obj.get("restless", "") == "active" and _said(r, "p_restless"))
	_walk(g, g.clock + 4.0)
	check("... out of every lure's reach it goes for the goats (LOOSE, its own short leash)", r.fired.has("restless_went") and rs[0].has_meta("leash_loose")
		and rs[0].order_point.distance_to(_mid(r, "goats")) < 3.0 * Defs.TILE, "%s %s %s" % [r.fired.has("restless_went"), rs[0].has_meta("leash_loose"), str(rs[0].order_point / Defs.TILE)])
	var k: Unit = r.tagged("keeper")[0]
	_put(g, [k], rs[0].position + Vector2(4.5 * Defs.TILE, 0))
	_walk(g, g.clock + 4.0)
	check("... a keeper 4 tiles off does not hold it (3 at night)", rs[0].has_meta("leash_loose"))
	_put(g, [k], rs[0].position + Vector2(1.5 * Defs.TILE, 0))
	_walk(g, g.clock + 1.0)
	check("... a keeper right beside it: HELD", r.fired.has("restless_held") and not rs[0].has_meta("leash_loose"))
	var dawn0 := float(r.clocks["dawn"])
	_put(g, [k, rs[0]], _mid(r, "pen_5"))
	_walk(g, g.clock + 1.0)
	check("... walked back into the deep forest: done, its leash the stock's again, and dawn comes sooner", r.fired.has("restless_back")
		and r.obj.get("restless", "") == "done" and float(r.clocks["dawn"]) < dawn0 - 60.0)
	_walk(g, float(r.clocks["dawn"]) + 18.0)
	check("dawn: the commission leaves, the stock wins", g.over and r.winner_side == "stock", r.winner_side)
	check("the flags: hidden (some or all), storm hatched, mother linnea, pieter alive", ["some", "all"].has(str(r.flags.get("hidden")))
		and str(r.flags.get("storm")) == "hatched" and str(r.flags.get("mother")) == "linnea" and str(r.flags.get("pieter")) == "alive", str(r.flags))
	check("hidden_n is the young never found", int(r.flags.get("hidden_n", -1)) == int(r.counters["young_n"]) - int(r.counters["found"]))
	var pages := r.pages_now(Campaign.show_pages(r.data, "ending", "stock"))
	check("the ending: Lindqvist's account, then the King's correction", pages.size() == 2)
	check("Valadares never leaves by the canoes' exit (his protect stands)", r.obj.get("c_valadares", "") != "failed")


# ================================================================== THE DEFEATS

func _defeats() -> void:
	# found three quarters: Rome's order carried out
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	r.counters["found"] = int(r.counters["young_n"])
	_walk(g, g.clock + 3.0)
	check("three quarters found: lost (Rome's order carried out)", g.over and r.winner_side != "stock" and r.obj.get("search", "") == "failed", r.winner_side)
	# the restless one reaches the goats: the camp is up
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	_put(g, r.tagged("lure"), _mid(r, "pen_3"))
	_walk(g, float(r.clocks["dusk"]) + 14.0)
	var rs: Array = r.tagged("restless")
	_put(g, rs, _mid(r, "goats"))
	_walk(g, g.clock + 1.0)
	check("the restless one among the goats: everything found, lost", g.over and r.winner_side != "stock" and r.obj.get("night", "") == "failed"
		and _young(r).all(func(u): return not r.a2.is_hidden(u)))
	# the passive player: the stock left in the old pens by the house
	_progress()
	g = await _start()
	r = g.mission
	_walk(g, float(r.clocks["boat"]) + 1.0)
	check("a passive player: the canoes land on the stock in the old pens", r.fired.has("part2") and int(r.counters["deep"]) == 0)


# ================================================================== the commission's mirror

func _mirror() -> void:
	_progress()
	var g: Game = await _start("commission")
	var r := g.mission
	check("the commission picked: the player leads the commission", g.human == r.team_index("commission"))
	check("the stock scripted: asleep in its deep pens", _young(r).filter(func(u): return u.has_meta("mission_asleep")).size() >= 4)
	_walk(g, 24.0)
	check("the canoes land at 0:20: the commission's men are the player's", r.fired.has("part2") and r.fired.has("part2_c")
		and r.tagged("searchers").filter(func(u): return u.kind == "musketeer").size() == 12 and r.obj.get("c_find", "") == "active")
	check("half the stock to destroy", int(r.counters["half"]) == ceili(float(r.counters["young_n"]) / 2.0), "%d of %d" % [r.counters["half"], r.counters["young_n"]])
	var ys := _young(r)
	for i in int(r.counters["half"]):
		ys[i].die()
	_walk(g, g.clock + 8.0)
	check("half destroyed: the commission wins (flag hidden by what was found)", g.over and r.winner_side == "commission" and r.flags.has("hidden"), r.winner_side)
	_progress()
	g = await _start("commission")
	r = g.mission
	_walk(g, 24.0)
	_walk(g, float(r.clocks["dusk"]) + 1.0)
	_walk(g, float(r.clocks["dawn"]) + 18.0)
	check("a passive commission: dawn, the canoes leave, lost", g.over and r.winner_side == "stock" and r.obj.get("c_find", "") == "failed", r.winner_side)


# ================================================================== save and load in the middle

func _snap(g: Game) -> Dictionary:
	var r := g.mission
	var tg := {}
	for t in r.tags:
		tg[t] = r.tagged(String(t)).size()
	var hidden := _young(r).filter(func(u): return r.a2.is_hidden(u)).size()
	return {"flags": r.flags, "counters": r.counters, "obj": r.obj, "tags": tg, "hidden": hidden,
		"leashes": (r.act2.get("leashes", []) as Array).map(func(l): return String(l["name"])),
		"deny": r.deny.get(r.team_index("stock"), {}).size()}


func _save_load() -> void:
	_progress()
	MissionSave.clear_all(MID)
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_walk(g, g.clock + 5.0)
	var before := _snap(g)
	main.mission_save_now()
	check("SAVE written in the middle of the search", MissionSave.has(MID, "save"))
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
	check("LOADED the same: flags, counters, objectives, tags, the hidden, the leashes, the denied", diff.is_empty(), "; ".join(diff))
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


# ================================================================== the hubs and the war map after d03

func _hubs() -> void:
	_progress()
	Campaign.record(MID, "solo", "stock", "stock", {"hidden": "some", "hidden_n": 4, "storm": "hatched", "mother": "linnea", "pieter": "alive"})
	var p := Campaign.progress()
	var sl := Campaign.storyline_of(MID)
	var lq: Dictionary = sl["hub"]["talks"]["lindqvist"]
	check("the hub: Lindqvist talks of the Storm Sire and Valadares' word after d03", str(CampaignMenu.talk_lines(lq, p)).contains("Storm Sire")
		and str(CampaignMenu.talk_lines(lq, p)).contains("made, not born"))
	check("the hub is the fazenda's study now", String(CampaignMenu.hub_now(sl["hub"], p).get("title", "")) == "The Fazenda's Study", str(CampaignMenu.hub_now(sl["hub"], p).get("title", "")))
	check("the hub: Pieter keeps the stud book, Benedito paddled the commission", str(HubGrow.talk_lines(HubGrow.talk("pieter"), p)).contains("stud book")
		and str(HubGrow.talk_lines(HubGrow.talk("benedito"), p)).contains("Óbidos"))
	var led: Array = WarMapData.state(p).get("ledger", []).map(func(x): return String(x.get("text", "")))
	check("the war map's ledger: the island, some found, the young never found, the Storm Sire", led.has("Lindqvist breeds the specimens on an island below Óbidos, against Rome's verdict.")
		and led.has("The commission found some of Lindqvist's stock and burned it; the rest was never found.") and led.has("Young never found on the island: %s.")
		and led.has("A Storm Sire hatched on the island: the first bred by a man."), str(led))
	check("the war map's data has no problem", WarMapData.problems().is_empty(), "; ".join(WarMapData.problems()))
	_progress()
	Campaign.record(MID, "solo", "commission", "commission", {"hidden": "few", "hidden_n": 2, "storm": "hatched"})
	p = Campaign.progress()
	check("a commission's win: Lindqvist says Valadares burned half", str(CampaignMenu.talk_lines(lq, p)).contains("Valadares found half"))
	led = WarMapData.state(p).get("ledger", []).map(func(x): return String(x.get("text", "")))
	check("... and the war map counts it (not a broken seal: Valadares found some)", led.has("Valadares' commission destroyed half of Lindqvist's stock.")
		and String(WarMapData.state(p)["pins"][MID]["seal"]) != "broken")
