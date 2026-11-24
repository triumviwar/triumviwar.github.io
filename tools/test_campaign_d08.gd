extends SceneTree
## Act 2's "Down the Rivers" (docs/campaign_d08_build.md):
##   - the data checks out, every text has pt and es, the Naturalist line lists it after d06 and it opens once d06 is won,
##     d06's next is d08, the seats (solo the Barra, the SOLO PICK of the swarm, versus), the map (the two rivers) and
##     the stills, THE ROSTER LADDER's B6 (BIGGER CLUTCH, PACK HUNT, QUICK ROOTS) on the swarm, no creature given a reason;
##   - THE FLAGS at the start: b01 `saved` (6 / 10 / 14 people), a03 `map` (the shallows shown or not), a03 `party`
##     (Benedito's line), every flag missing (the canon);
##   - PART 1: a man standing by a group sends it to the canoes (counted out), the raiders, the countdown out: the
##     forward Mother roots and the canoes wait 30 s; the canoes gone: `nazare` by the share brought out;
##   - PART 2: the forward Mothers walk and root (a wave grows), one killed on the way (counted), the waves;
##   - PART 3: THE LURE BOOK: BURNED (the whole great wave) and USED (the lure post: half the wave drowned), the dawn:
##     WON, `barra` held / burned by the quarters standing; the church or the Town Hall broken: LOST;
##   - THE MIRROR (the swarm): its pieces, a Mother rooted opposite the Barra, the guns and the church broken: WON (the
##     Barra lost); the floods out first: LOST; VERSUS: the Barra holds till the floods fall;
##   - SAVE AND LOAD in Part 2, IRONMAN, the HUB (Valadares' quarters) and the WAR MAP after d08; no script error.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_d08.gd [-- only=data,flags,part1,...]
## Prints CHECK lines, then "campaign_d08: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "d08_rivers"
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
	print("campaign_d08: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if b01, a03, a07, d03 and d06 were won with these flags (each merged over its canon).
func _progress(b01 := {}, a03 := {}, d06 := {}, diff := "normal", with_d06 := true, none := false) -> void:
	var p := {"reached": [MID], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if not none:
		var f1 := {"clutch": "saved", "eggs": "left", "pieter": "alive", "rival": "standing", "teles": "quiet", "saved": "some"}
		f1.merge(b01, true)
		p["done"]["b01_specimen"] = {"won_by": "sire", "side": "sire", "flags": f1}
		var f3 := {"map": "drawn", "party": "some", "survey": "full", "linnea": "seen", "sire_way": "east"}
		f3.merge(a03, true)
		p["done"]["a03_plateau"] = {"won_by": "party", "side": "party", "flags": f3}
	p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}}
	p["done"]["d03_fazenda"] = {"won_by": "stock", "side": "stock", "flags": {"hidden": "some", "hidden_n": 4, "storm": "hatched", "pieter": "alive"}}
	if with_d06:
		var f6 := {"brood_n": "some", "brood_n_n": 4, "pieter": "alive", "lindqvist": "fled", "book": "left", "queen": "grown"}
		f6.merge(d06, true)
		p["done"]["d06_queen"] = {"won_by": "brood", "side": "brood", "flags": f6}
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


func _kill(r: MissionRun, tag: String) -> void:
	for e in r.tagged(tag):
		e.hp_floor = 0.0
		e.spared = false
		e.take_damage(999999.0, null)


## PART 1 done the quick way: a man at each group for a moment, every villager walked to the beach.
func _to_part2(g: Game, r: MissionRun) -> void:
	var col: Array = r.tagged("column")
	for grp in ["g_chapel", "g_houses", "g_fields"]:
		_put(g, [col[0]], _mid(r, grp))
		_walk(g, g.clock + 4.0)
	_put(g, [col[0]], _mid(r, "col_start"))
	for u in r.tagged("villagers"):
		u.position = _mid(r, "canoes_n")
		u.velocity = Vector2.ZERO
	g._rebuild_hash()
	_walk(g, g.clock + 2.0)
	_walk(g, maxf(g.clock, 11.0) + 2.0)


## PART 2 done the quick way: every wave spawned and killed (the forward Mothers left to root).
func _to_part3(g: Game, r: MissionRun) -> void:
	var p2 := float(r.fired.get("part2", g.clock))
	for i in 5:
		_walk(g, p2 + [45, 105, 165, 225, 285][i] + 7.0)
		_kill(r, "waves")
	_walk(g, g.clock + 22.0)


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
	check("d08_rivers: data checks out", pr.is_empty(), "; ".join(pr))
	var extra := ["A forward Mother", "The Barra's sergeant", "Valadares' Quarters at the Barra", "VALADARES"]
	for role in ["bank_mother", "barra_sergeant"]:
		extra.append(String(Rebels.ROLES[role]["about"]))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + extra:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission, its roles and the hub has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Naturalist line lists d08 after d06", String(sl.get("id", "")) == "naturalist"
		and (sl["missions"] as Array).find(MID) == (sl["missions"] as Array).find("d06_queen") + 1)
	check("d06's next is d08 (both sides)", str(Campaign.mission("d06_queen")["next"]) == str({"brood": MID, "fazenda": MID}))
	_progress({}, {}, {}, "normal", false)
	var pp := Campaign.progress()
	pp["reached"] = []
	Campaign.save_progress(pp)
	check("d08 is shut until d06 is won", not Campaign.unlocked(MID))
	_progress()
	check("... and open once it is", Campaign.unlocked(MID))
	check("the seats: solo the Barra, the SOLO PICK the swarm", Campaign.solo_sides(m) == ["barra", "swarm"])
	var c := Campaign.make_cfg(MID, "solo", "p1", false, "swarm")
	var you: Array = (c["slots"] as Array).filter(func(s): return String(s["who"]) == "you").map(func(s): return String(s["team_id"]))
	check("the swarm picked: the swarm's team is the player's", you == ["swarm"], str(you))
	check("versus: the Barra p1, the swarm p2", Campaign.seat_side(m, "versus", "p1") == "barra" and Campaign.seat_side(m, "versus", "p2") == "swarm")
	var md := Campaign.map_data("barra_rivers")
	check("the map: the two rivers, the shallows, the bluff", String(md.get("cells", "")).count("f") > 300 and String(md.get("cells", "")).count("h") > 700,
		"%d %d" % [String(md.get("cells", "")).count("f"), String(md.get("cells", "")).count("h")])
	for k in m["stills"]:
		check("still %s is in" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	var sw: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "swarm")[0]
	check("THE ROSTER LADDER B6: BIGGER CLUTCH, PACK HUNT, QUICK ROOTS on the swarm, all NEW",
		(sw["roster"]["new"] as Array) == ["nb_clutch_raptor", "nb_pack_hunt", "nb_quick_roots"]
		and (sw["roster"]["allow"] as Array).has("stage3") and not (sw["roster"]["allow"] as Array).has("mist_toad"))
	var ba: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "barra")[0]
	check("the Barra is not bound by the ladder (its story's deny only)", not (ba["roster"] as Dictionary).has("allow"))
	check("hubs-grow: d08 earns FIELD NOTES", (HubGrow.line("naturalist")["earn"] as Array).has(MID))
	# THE BROOD IS NOT A PERSON (and LINNEA OK, NO REASONS): no creature given a want, a reason or a plan
	var all := " ".join(Campaign.strings_of(m)).to_lower()
	var bad: Array = []
	for w in ["she wants", "they want", "comes for", "her young", "her children", "revenge", "they know", "she knows", "hungry for", "to avenge"]:
		if all.contains(w):
			bad.append(w)
	check("no creature given a reason, a want or a plan", bad.is_empty(), str(bad))


# ================================================================== the flags at the start

func _flags() -> void:
	_progress({}, {}, {}, "normal", true, true)
	var g: Game = await _start()
	var r := g.mission
	check("every earlier flag missing (d06 only): the canon, 10 people", int(r.counters["vill_n"]) == 10, str(r.counters["vill_n"]))
	_progress()
	g = await _start()
	r = g.mission
	check("the player plays the Barra (purple) with Valadares, the column, the garrison, two guns", g.human == r.team_index("barra")
		and r.tagged("valadares").size() == 1 and r.tagged("guns").size() == 2 and r.tagged("column").size() == 9)
	check("the Barra stands: hall, church, palisade, six quarters", r.tagged("hall").size() == 1 and r.tagged("church").size() == 1
		and r.tagged("quarters").size() == 6 and int(r.counters["q_n"]) == 6)
	check("b01 saved some: 10 of Nazaré's people, Benedito at the beach", int(r.counters["vill_n"]) == 10 and r.tagged("benedito").size() == 1)
	check("the forward Mother across from Nazaré, not rooted yet, spared", r.tagged("fwd_n").size() == 1 and not BroodNew.rooted(r.tagged("fwd_n")[0])
		and r.tagged("fwd_n")[0].spared)
	check("the opening: the King's line from a03 linnea seen", str(r.pages_now(Campaign.show_pages(r.data, "opening", "barra"))).contains("k_linnea"))
	_walk(g, 13.0)
	check("a03 map drawn: Valadares knows the shallows (the line)", _said(r, "v_map") and not _said(r, "v_sealed"))
	_progress({"saved": "few"}, {"map": "withheld", "party": "few"})
	g = await _start()
	r = g.mission
	check("b01 saved few: 6 people", int(r.counters["vill_n"]) == 6, str(r.counters["vill_n"]))
	_walk(g, 36.0)
	check("a03 map withheld: the sealed map's line", _said(r, "v_sealed") and not _said(r, "v_map"))
	check("a03 party few: Benedito's line", _said(r, "b_party_few"))
	_progress({"saved": "many"})
	g = await _start()
	r = g.mission
	check("b01 saved many: 14 people", int(r.counters["vill_n"]) == 14, str(r.counters["vill_n"]))


# ================================================================== PART 1

func _part1() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	check("the Nazaré objective and its countdown", r.obj.get("nazare", "") == "active" and r.clocks.has("nazare"))
	var col: Array = r.tagged("column")
	_put(g, [col[0]], _mid(r, "g_chapel"))
	_walk(g, g.clock + 1.0)
	check("a man by the chapel's people for a moment: not yet", not r.fired.has("call_g_chapel"))
	_walk(g, g.clock + 3.0)
	check("... three seconds: they go to the canoes (and say so)", r.fired.has("call_g_chapel") and _said(r, "g_chapel")
		and r.tagged("g_chapel").all(func(u): return u.order == "move"), str(r.tagged("g_chapel").map(func(u): return u.order)))
	var nch: int = r.tagged("g_chapel").size()
	for u in r.tagged("g_chapel"):
		u.position = _mid(r, "canoes_n")
		u.velocity = Vector2.ZERO
	g._rebuild_hash()
	_walk(g, g.clock + 1.0)
	check("at the beach they are away: counted out", int(r.counters["out_n"]) == nch and nch == 3 and r.tagged("g_chapel").is_empty(), str(r.counters["out_n"]))
	_walk(g, 31.0)
	check("the first raiders come over the rapids for the people", r.fired.has("raid_1") and r.tagged("raiders").size() >= 2)
	r.clocks["nazare"] = g.clock + 0.3
	_walk(g, g.clock + 2.0)
	check("the countdown out: the forward Mother roots (spared no more), the canoes wait", r.fired.has("rooted_n") and not r.tagged("fwd_n")[0].spared
		and r.clocks.has("canoes") and _said(r, "b_wait"))
	_walk(g, g.clock + 7.0)
	var fn: Unit = r.tagged("fwd_n")[0]
	check("... she roots (her ground with her)", (fn.order == "nb_root" or BroodNew.rooted(fn)) and (r.act2.get("grounds", []) as Array).size() >= 1,
		"%s %s" % [fn.order, r.act2.keys()])
	r.clocks["canoes"] = g.clock + 0.3
	_walk(g, g.clock + 2.0)
	check("the canoes gone: Part 2; the people left behind lost; nazare few (3 of 10)", r.fired.has("part2") and r.tagged("villagers").is_empty()
		and str(r.flags.get("nazare")) == "few" and int(r.counters["out_n"]) == 3, str(r.flags))
	check("... the Nazaré objective failed and the line said", r.obj.get("nazare", "") == "failed" and _said(r, "n_left"))
	# all brought out
	_progress()
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	check("every group sent and away: Part 2 at once, nazare all, the objective done", r.fired.has("part2") and str(r.flags.get("nazare")) == "all"
		and r.obj.get("nazare", "") == "done", str(r.flags))
	check("Benedito comes down to the Barra's landing", r.tagged("benedito").size() == 1
		and r.area_rect("landing_s").grow(64).has_point(r.tagged("benedito")[0].position))


# ================================================================== PART 2

func _part2() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	var p2 := float(r.fired["part2"])
	_walk(g, p2 + 7.0)
	check("the bluff's objective, the forward Mothers' objective, the first Mother walking", r.obj.get("bluff", "") == "active"
		and r.obj.get("fwd", "") == "active" and r.tagged("fwd_m").size() == 1 and not BroodNew.rooted(r.tagged("fwd_m")[0]))
	_kill(r, "fwd_m")
	_walk(g, g.clock + 1.0)
	check("one killed on the way: counted, said, the objective done", int(r.counters["fwd_killed"]) == 1 and _said(r, "n_fwd_dead")
		and r.obj.get("fwd", "") == "done")
	_walk(g, p2 + float(70) + 2.0)
	var fs: Array = r.tagged("fwd_s")
	check("the second sets off down the far bank", fs.size() == 1)
	_put(g, fs, _mid(r, "far_stage"))
	_walk(g, g.clock + 2.0)
	_put(g, fs, _mid(r, "fb_s_spot"))
	_walk(g, g.clock + 3.0)
	check("at her clearing she roots: counted, her ground creeps", r.fired.has("fwd_s_root") and int(r.counters["fwd_rooted"]) == 1)
	_walk(g, p2 + 105.0 + 1.0)
	check("wave 2: over both shallows, her two Raptors in it (she is rooted)", r.fired.has("wave_2") and r.tagged("w2s").size() >= 6
		and r.tagged("w2m").size() >= 3, "%d %d" % [r.tagged("w2s").size(), r.tagged("w2m").size()])
	_walk(g, p2 + 105.0 + 8.0)
	check("... they cross (a route through the shallows)", r.fired.has("wave_2_go") and r.tagged("w2s").any(func(u): return u.order in ["amove", "move", "attack"]),
		str(r.tagged("w2s").map(func(u): return u.order)))


# ================================================================== PART 3: the lure book, the night, the dawn

func _part3() -> void:
	for opt in ["burned", "used"]:
		_progress()
		var g: Game = await _start()
		var r := g.mission
		_to_part2(g, r)
		_to_part3(g, r)
		check("[%s] dusk: Part 3, the book (d06 book left: the fazenda's ruins), the choice offered" % opt, r.fired.has("part3")
			and _said(r, "b_book") and String(r.choice_open.get("id", "")) == "lure", str(r.choice_open.get("id", "")))
		r.choose("lure", opt)
		_walk(g, g.clock + 6.0)
		check("[%s] the great wave gathers on the far bank; the dawn clock" % opt, r.tagged("great").size() >= 12 and r.clocks.has("dawn"), str(r.tagged("great").size()))
		if opt == "used":
			_walk(g, g.clock + 4.0)
			check("[used] the lure post on the far point pulls half the wave (lured)", r.cond({"lured": "far_lure"}))
			for a in ["far_point", "drowned"]:
				for u in r.tagged("great_a"):
					u.position = _mid(r, a)
					u.velocity = Vector2.ZERO
				g._rebuild_hash()
				_walk(g, g.clock + 2.0)
			_walk(g, g.clock + 6.0)
			check("[used] into the flooded forest: they drown their road (removed)", r.tagged("great_a").is_empty() and _said(r, "n_drowned"))
		_walk(g, float(r.fired["great"]) + 22.0)
		check("[%s] the wave goes over the Barra shallows" % opt, r.fired.has("great_go"))
		_kill(r, "great")
		_walk(g, g.clock + 7.0)
		check("[%s] broken: first light, the objectives" % opt, r.fired.has("broken") and r.fired.has("dawn") and r.obj.get("night", "") == "done",
			"%s %s %s %d" % [r.fired.has("broken"), r.fired.has("dawn"), r.obj.get("night", ""), r.tagged("great").size()])
		_walk(g, g.clock + 8.0)
		check("[%s] WON for the Barra; lure %s, barra held (every quarter), nazare all" % [opt, opt], g.over and r.winner_side == "barra"
			and str(r.flags.get("lure")) == opt and str(r.flags.get("barra")) == "held" and str(r.flags.get("nazare")) == "all", str(r.flags))
	# the lower town burned: barra burned
	_progress({}, {}, {"book": "taken"})
	var g2: Game = await _start()
	var r2 := g2.mission
	_to_part2(g2, r2)
	_to_part3(g2, r2)
	check("d06 book taken: the book left at the Barra's warehouse (the other line)", _said(r2, "b_book_taken") and not _said(r2, "b_book"))
	_kill(r2, "quarters")
	_walk(g2, g2.clock + 80.0)
	check("unanswered: the default, BURNED", str(r2.flags.get("lure")) == "burned")
	_kill(r2, "great")
	_walk(g2, g2.clock + 30.0)
	check("the lower town burned: barra burned (and still WON)", g2.over and r2.winner_side == "barra" and str(r2.flags.get("barra")) == "burned", str(r2.flags))


func _defeat() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_kill(r, "church")
	_walk(g, g.clock + 2.0)
	check("the church broken: LOST (the swarm's)", g.over and r.winner_side == "swarm", "%s %s" % [g.over, r.winner_side])
	_progress()
	g = await _start()
	r = g.mission
	_kill(r, "hall")
	_walk(g, g.clock + 2.0)
	check("the Town Hall broken: LOST", g.over and r.winner_side == "swarm")
	_progress()
	g = await _start()
	r = g.mission
	var v: Unit = r.tagged("valadares")[0]
	v.take_damage(99999.0, null)
	_walk(g, g.clock + 2.0)
	check("Valadares is a hero: wounded, not killed", not v.dead and not g.over)


# ================================================================== THE MIRROR: the swarm

func _mirror() -> void:
	_progress()
	var g: Game = await _start("swarm")
	var r := g.mission
	check("the swarm picked: its team is the player's, the Barra scripted", g.human == r.team_index("swarm"))
	_walk(g, 4.0)
	check("two forward Mothers, the Sires, grubs, raiders; the first rooted", r.tagged("fwd").size() == 2 and r.tagged("sires").size() == 2
		and r.tagged("grubs").size() == 4 and r.tagged("raiders").size() == 8)
	check("the swarm's objectives and the floods' clock; the Barra's hidden from it", r.obj.get("s_barra", "") == "active" and r.clocks.has("floods")
		and r.obj.get("bluff", "") != "active")
	_walk(g, 40.0)
	check("the scripted Barra: the column goes up the trail, Nazaré's people walk to the canoes", r.fired.has("sb_column") and r.fired.has("self_g_chapel"))
	var fm: Array = r.tagged("fwd_m")
	_put(g, fm, _mid(r, "fb_s_spot"))
	BroodRoot.start_root(fm[0], fm[0].position)
	for i in 300:
		await physics_frame
		if BroodNew.rooted(fm[0]):
			break
	_walk(g, g.clock + 3.0)
	check("a Mother rooted opposite the Barra: the far bank's objective", r.obj.get("s_root", "") == "done" and _said(r, "n_s_root"), str(r.obj.get("s_root")))
	_kill(r, "guns")
	_walk(g, g.clock + 3.0)
	check("one gun is not enough", not g.over)
	_kill(r, "church")
	_walk(g, g.clock + 8.0)
	check("the guns and the church broken: WON for the swarm, barra burned", g.over and r.winner_side == "swarm" and str(r.flags.get("barra")) == "burned",
		"%s %s %s" % [g.over, r.winner_side, r.flags])
	_progress()
	g = await _start("swarm")
	r = g.mission
	_walk(g, 4.0)
	r.clocks["floods"] = g.clock + 0.5
	_walk(g, g.clock + 8.0)
	check("the floods fall first: LOST for the swarm (the Barra holds)", g.over and r.winner_side == "barra", "%s %s" % [g.over, r.winner_side])


func _versus() -> void:
	_progress()
	var m := Campaign.mission(MID)
	var c := Campaign.make_cfg(MID, "versus", "p1", false, "")
	check("versus makes a game of the Barra (p1) and the swarm (p2)", (c["slots"] as Array).size() >= 2)


# ================================================================== save and load, ironman

func _snap(g: Game) -> Dictionary:
	var r := g.mission
	var tags := {}
	for k in r.tags:
		tags[k] = r.tagged(k).size()
	return {"flags": r.flags, "counters": r.counters, "obj": r.obj, "tags": tags, "fired": r.fired.keys().size(),
		"grounds": (r.act2.get("grounds", []) as Array).size()}


func _save_load() -> void:
	_progress()
	MissionSave.clear_all(MID)
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_walk(g, float(r.fired["part2"]) + 50.0)
	var before := _snap(g)
	main.mission_save_now()
	check("SAVE written in the waves", MissionSave.has(MID, "save"))
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
	check("LOADED the same: flags, counters, objectives, tags, the spreading ground", diff.is_empty(), "; ".join(diff))
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


# ================================================================== the hub and the war map after d08

func _hubs() -> void:
	_progress()
	Campaign.record(MID, "solo", "barra", "barra", {"lure": "burned", "barra": "held", "nazare": "all", "nazare_n": 10})
	var p := Campaign.progress()
	var sl := Campaign.storyline_of(MID)
	var va: Dictionary = sl["hub"]["talks"]["valadares"]
	check("the hub: Valadares burned the book, Nazaré in the church", str(CampaignMenu.talk_lines(va, p)).contains("burned the book")
		and str(CampaignMenu.talk_lines(va, p)).contains("in the church"))
	check("the hub is Valadares' quarters at the Barra now", String(CampaignMenu.hub_now(sl["hub"], p).get("title", "")) == "Valadares' Quarters at the Barra",
		str(CampaignMenu.hub_now(sl["hub"], p).get("title", "")))
	var st := WarMapData.state(p)
	var led: Array = st.get("ledger", []).map(func(x): return String(x.get("text", "")))
	check("the war map: the Barra the Crown's, the ledger (held, burned book, all of Nazaré)", String(st["regions"]["barra_rio_negro"]) == "crown"
		and led.has("Valadares held the Barra, every quarter standing.") and led.has("The lure book was burned, as Rome ordered.")
		and led.has("All of Nazaré was brought down the river."), str(led.slice(-4)))
	check("the war map's data has no problem", WarMapData.problems().is_empty(), "; ".join(WarMapData.problems()))
	_progress()
	Campaign.record(MID, "solo", "barra", "barra", {"lure": "used", "barra": "burned", "nazare": "few"})
	p = Campaign.progress()
	check("the book used, the lower town burned: Valadares' penance, the rebuilding", str(CampaignMenu.talk_lines(va, p)).contains("penance")
		and str(CampaignMenu.talk_lines(va, p)).contains("lower town burned"))
	check("... the war map: the Barra contested", String(WarMapData.state(p)["regions"]["barra_rio_negro"]) == "contested")
	_progress()
	Campaign.record(MID, "solo", "swarm", "swarm", {"lure": "burned", "barra": "burned", "nazare": "few"})
	p = Campaign.progress()
	check("a swarm's win: the Barra the Brood's, a broken seal", String(WarMapData.state(p)["regions"]["barra_rio_negro"]) == "brood"
		and String(WarMapData.state(p)["pins"][MID]["seal"]) == "broken")
	check("... Valadares: that is not how it went", str(CampaignMenu.talk_lines(va, p)).contains("In mine it stood"))
