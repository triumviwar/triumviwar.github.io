extends SceneTree
## Act 2's "The Jungle Front" (d10_jungle; docs/campaign_d10_build.md):
##   - the data checks out, every text has pt and es (the roles and the hubs too), the Crown line lists it after d09, it
##     opens after d09 (and, the city first, only once d11 is won too), the seats (solo the column OR the swarm; co-op
##     Óbidos' garrison; versus the swarm), the map (the várzea at Óbidos) and the stills, THE ROSTER LADDER's C8 (the
##     OBSERVATION BALLOON) and the swarm's B7 (the MIST TOAD, FOG, MIASMA), THE BROOD IS NOT A PERSON in the texts;
##   - THE FLAGS: FRESH (d09 `first` brood) and GROWN (clockwork): Mothers, Toads, the column's kit; d05 `fields`, d08
##     `barra`/won_by (THE RECLAIM PART), a03 `map` (the creek road known);
##   - PART 1: the fog, the raids, the balloon over the lookout lifts the fog (or a canoe's word, late); PART 2: the nests'
##     clock, the waves, the lure (d08 `lure` used), every nest broken; PART 3: the island, the last wave, the ebb: WON with
##     `jungle`, `island`, `inacio`; the rains first (thin, the flood); THE RECLAIM PART; DEFEAT (the keep lost);
##   - the MIRROR (the swarm alone) both ways, VERSUS, SAVE AND LOAD, IRONMAN, the HUBS and the WAR MAP after d10.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_d10.gd [-- only=data,flags,part1,part2,part3,...]
## Prints CHECK lines, then "campaign_d10: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "d10_jungle"
const SIM := preload("res://tools/sim_campaign_d10.gd")
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
	print("campaign_d10: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if everything up to d09 was won (the sim's), `first` = d09's choice; `fl` merges flags per mission
## ("b01", "a03", "d05", "d06", "d08"); `broken` = d08 won by the swarm (a broken seal).
func _progress(first := "brood", fl := {}, broken := false, diff := "normal") -> void:
	var b01 := {"clutch": "saved"}
	var a03 := {"map": "drawn"}
	var d05 := {"fields": "left", "aldeia": "some"}
	var d06 := {"brood_n": "some"}
	var d08 := {"lure": "burned", "barra": "held", "nazare": "all"}
	for pair in [["b01", b01], ["a03", a03], ["d05", d05], ["d06", d06], ["d08", d08]]:
		for k in fl.get(pair[0], {}):
			(pair[1] as Dictionary)[k] = fl[pair[0]][k]
	Campaign.save_progress(SIM.progress_for(first, b01, a03, d05, d06, d08, diff, broken))


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


## PART 1 done the quick way: the balloon over the lookout for its look.
func _to_part2(g: Game, r: MissionRun) -> void:
	_put(g, r.tagged("inacio"), _mid(r, "lookout"))
	_walk(g, g.clock + 34.0)


## PART 2 done the quick way: every forward Mother broken (and every wave out killed).
func _to_part3(g: Game, r: MissionRun) -> void:
	_kill(r.tagged("fwd"))
	_walk(g, g.clock + 6.0)
	_kill(r.tagged("waves"))


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
	if want.call("reclaim"): await _reclaim()
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
	check("d10_jungle: data checks out", pr.is_empty(), "; ".join(pr))
	var extra := ["Father Inácio", "The old mound", "The captain of Óbidos"]
	for role in ["inacio", "river_mother", "old_mound", "obidos_captain"]:
		extra.append(String(Rebels.ROLES[role]["about"]))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + extra:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission, its roles and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	var pro: Dictionary = {}
	for s in Campaign.index()["storylines"]:
		if String(s["id"]) == "prologue":
			pro = s
	var ms: Array = pro.get("missions", [])
	check("the Crown line lists d10 after d09", ms.find(MID) == ms.find("d09_crossroads") + 1 and ms.find(MID) > 0)
	check("only the Crown line lists it (NO Brood hub, ever)", Campaign.index()["storylines"].filter(func(s): return (s["missions"] as Array).has(MID)).size() == 1)
	_progress("brood")
	check("the swarm first (FRESH): open after d09", Campaign.unlocked(MID))
	_progress("clockwork")
	var p := Campaign.progress()
	p["done"].erase("d11_siege")
	Campaign.save_progress(p)
	check("the city first (GROWN): shut while d11 is not won", not Campaign.unlocked(MID))
	_progress("clockwork")
	check("... open once it is", Campaign.unlocked(MID))
	p = Campaign.progress()
	p["done"].erase("d09_crossroads")
	p["reached"] = []
	Campaign.save_progress(p)
	check("shut before d09", not Campaign.unlocked(MID))
	check("the seats: solo the column OR the swarm", Campaign.solo_sides(m) == ["column", "swarm"])
	check("co-op: p2 Óbidos' garrison (the column's side)", Campaign.seat_side(m, "coop", "p2") == "column")
	check("versus: p2 the swarm", Campaign.seat_side(m, "versus", "p2") == "swarm" and Campaign.seat_side(m, "versus", "p1") == "column")
	var md := Campaign.map_data("obidos_front")
	check("the map is the várzea at Óbidos (the flood and the channel)", md.get("biome", "") == "varzea" and String(md.get("cells", "")).count("f") > 1000
		and String(md.get("cells", "")).count("w") > 2000)
	for k in m["stills"]:
		check("still %s is in" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	check("Father Inácio's portrait is in", ResourceLoader.exists("res://campaign/portraits/inacio.png"))
	var col: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "column")[0]
	var sw: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "swarm")[0]
	check("THE ROSTER LADDER C8: the OBSERVATION BALLOON, NEW", (col["roster"]["allow"] as Array).has("balloon") and (col["roster"]["new"] as Array) == ["balloon"])
	check("the column brings C5-C7's drills (matchlock, bayonet, charge, armour)", (col.get("techs", []) as Array) == ["matchlock", "bayonet", "charge", "armour"])
	check("the swarm's B7 (mirror/versus): the MIST TOAD, FOG, MIASMA, NEW", (sw["roster"]["new"] as Array) == ["mist_toad", "nb_fog", "nb_miasma"])
	check("the needs: Rome and d09 (d11 too when the city came first)", m.get("needs", []) == ["a07_council", "d09_crossroads"]
		and str(m.get("needs_if", [])).contains("d11_siege"))
	check("heroes: Valadares and Father Inácio are wounded, not killed", m.get("heroes", []) == ["valadares", "inacio"])
	var all := " ".join(Campaign.strings_of(m))
	var bad: Array = []
	for w in ["Linnea", "her young", "comes for", "wants", "she wants", "they want", "revenge", "hates", "her children"]:
		if all.contains(w):
			bad.append(w)
	check("THE BROOD IS NOT A PERSON: no creature named or given a reason", bad.is_empty(), str(bad))
	var dash: Array = []
	for lid in m["lines"]:
		if String(m["lines"][lid]["text"]).contains(" - ") or String(m["lines"][lid]["text"]).contains("—"):
			dash.append(lid)
	check("no dashes in the spoken lines", dash.is_empty(), str(dash))


# ================================================================== the flags

func _flags() -> void:
	_progress("brood")
	var g: Game = await _start()
	var r := g.mission
	check("FRESH (the swarm first): the version, three forward Mothers (the fields left)", str(r.flags.get("version")) == "fresh"
		and r.tagged("fwd").size() == 3, "%s %d" % [r.flags.get("version"), r.tagged("fwd").size()])
	check("the player is the column with Valadares and Father Inácio in his balloon", g.human == r.team_index("column") and r.tagged("valadares").size() == 1
		and r.tagged("inacio").size() == 1 and (r.tagged("inacio")[0] as Unit).kind == "balloon")
	check("no Toads, no RECLAIM PART, the C5 drills", r.tagged("toads").is_empty() and r.tagged("bat_swarm").is_empty()
		and g.players[g.human]["tech"].has("matchlock"))
	check("THE FOG ON THE RIVER: the land dark (a03 map drawn: the creek road known)", r.fired.has("fog") and r.fired.has("fog_drawn"))
	check("the Mothers rooted on their banks", r.tagged("fwd").all(func(u): return u.tesla_mode != "packed" or u.order == "nb_root"))
	var gr0: int = r.tagged("line").size()
	_progress("brood", {"d05": {"fields": "burned"}, "a03": {"map": "withheld"}})
	g = await _start()
	r = g.mission
	check("d05 fields burned: two Mothers (the north creek's starved)", r.tagged("fwd").size() == 2, str(r.tagged("fwd").size()))
	check("a03 map withheld: no creek road", not r.fired.has("fog_drawn"))
	_walk(g, 13.0)
	check("... and Valadares says his map is sealed in Rome", _said(r, "v_sealed"))
	_progress("clockwork")
	g = await _start()
	r = g.mission
	check("GROWN (the city first): the version, five Mothers, three Toads", str(r.flags.get("version")) == "grown" and r.tagged("fwd").size() == 5
		and r.tagged("toads").size() == 3, "%d %d" % [r.tagged("fwd").size(), r.tagged("toads").size()])
	check("GROWN: two Guardsmen more and the Mortar; the siege train's science (charges, quadrant)", r.tagged("line").size() == gr0 + 2
		and r.tagged("guns").any(func(u): return u.kind == "mortar") and g.players[g.human]["tech"].has("charges"))
	check("GROWN: the Mothers tougher than FRESH's? (no: older, weaker: 1600 v 2200)", r.tagged("fwd").all(func(u): return u.max_hp <= 1700.0))
	_progress("brood", {}, true)
	g = await _start()
	r = g.mission
	check("d08 won by the swarm (a broken seal): THE RECLAIM PART (the battery the swarm's)", r.tagged("bat_swarm").size() >= 6
		and r.obj.get("reclaim", "") == "active")
	_progress("clockwork", {"d08": {"barra": "burned"}})
	g = await _start()
	r = g.mission
	check("GROWN and the Barra burned in d08: THE RECLAIM PART too", r.tagged("bat_swarm").size() >= 6)
	_progress("brood", {"d08": {"barra": "burned"}})
	g = await _start()
	r = g.mission
	check("FRESH and the Barra burned: no reclaim (Valadares remembers it)", r.tagged("bat_swarm").is_empty())


# ================================================================== PART 1: the narrows

func _part1() -> void:
	_progress("brood")
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 9.0)
	check("the NEW card for C8 (the balloon) is said", _said(r, "new_balloon"))
	check("the opening lesson (SAY IT PLAINLY): the balloon to the lookout", _said(r, "v_1") and _said(r, "i_1") and _said(r, "n_lesson"))
	check("the objectives: the balloon, hold Óbidos, the keep", r.obj.get("balloon", "") == "active" and r.obj.get("hold_o", "") == "active"
		and r.obj.get("keep_live", "") == "active")
	_walk(g, 22.0)
	check("RAID 1 at the west gate", r.tagged("raid1").size() >= 3 and _said(r, "n_raid"))
	_put(g, r.tagged("inacio"), _mid(r, "lookout"))
	_walk(g, g.clock + 1.0)
	check("over the lookout: Father Inácio looks (a count, not yet)", _said(r, "i_look") and not r.fired.has("part2"))
	_walk(g, g.clock + 32.0)
	check("THE FOG LIFTS: Part 2, the nests' clock, the show", r.fired.has("part2") and r.fired.has("p2_show") and r.clocks.has("nests")
		and r.obj.get("fwd", "") == "active" and r.obj.get("balloon", "") == "done")
	_walk(g, g.clock + 25.0)
	check("the pay chest comes downriver", _said(r, "n_pay"))
	# never sent up: a canoe's word, late (NO WAITING)
	_progress("brood")
	g = await _start()
	r = g.mission
	_walk(g, 225.0)
	check("the balloon never sent: a canoe's word at %d s, Part 2 anyway" % SIM_LIFT, r.fired.has("part2") and r.fired.has("p2_late") and _said(r, "n_lift_late"))
	# GROWN: the Hatchlings after the balloon, the west Mothers to find
	_progress("clockwork")
	g = await _start()
	r = g.mission
	_walk(g, 62.0)
	check("GROWN: Hatchlings out of the canopy after the balloon", r.tagged("sky").size() >= 2)
	_to_part2(g, r)
	_walk(g, g.clock + 16.0)
	check("GROWN: two Mothers more up west, still under the fog: the balloon must go", r.obj.get("west", "") == "active" and _said(r, "i_west"))

const SIM_LIFT := 220


# ================================================================== PART 2: the nests

func _part2() -> void:
	_progress("brood", {"d08": {"lure": "used"}})
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	var p2 := float(r.fired["part2"])
	_walk(g, p2 + 40.0)
	check("WAVE 1 from every rooted Mother, down the levee", r.tagged("w1").size() >= 3 and _said(r, "n_wave"))
	_walk(g, p2 + 95.0)
	check("WAVE 2: d08 lure used: THE LURE ONCE MORE under Óbidos' guns", r.fired.has("lure_set") and _said(r, "v_lure"))
	_put(g, r.tagged("line").slice(0, 4), r.tagged("fwd_m1")[0].position + Vector2(5 * Defs.TILE, 0))
	_walk(g, g.clock + 1.0)
	check("the column at a Mother: her defenders out", r.fired.has("defend_m1") and r.tagged("def_m1").size() >= 4)
	_kill(r.tagged("fwd_m1"))
	_walk(g, g.clock + 1.0)
	check("one Mother broken: counted", int(r.counters["fwd_killed"]) == 1 and int(r.counters["fwd_left"]) == 2 and _said(r, "n_fwd_dead"))
	_kill(r.tagged("fwd"))
	_walk(g, g.clock + 5.0)
	check("EVERY NEST BROKEN before the rains: Part 3, `jungle` held", r.fired.has("nests_broken") and r.fired.has("part3")
		and str(r.flags.get("jungle")) == "held" and r.obj.get("fwd", "") == "done" and r.obj.get("island", "") == "active")
	check("no flood when every nest is broken", not r.fired.has("flood"))
	# GROWN: the Toads lay their fog when the column comes near
	_progress("clockwork")
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	var toad: Unit = r.tagged("toads")[0]
	_put(g, r.tagged("line").slice(0, 3), toad.position + Vector2(4 * Defs.TILE, 0))
	_walk(g, g.clock + 16.0)
	check("GROWN: a Mist Toad lays its fog by its Mother (the column near)", r.fired.has("toad_fog") and _said(r, "n_toad_fog"))
	# the rains: the nests' clock out
	r.clocks["nests"] = g.clock + 0.5
	_walk(g, g.clock + 12.0)
	check("THE RAINS before the nests are broken: `jungle` thin, the flood at Óbidos", str(r.flags.get("jungle")) == "thin" and r.fired.has("flood")
		and r.tagged("flood").size() >= 5 and r.obj.get("fwd", "") == "failed")


# ================================================================== PART 3: the island, the last wave, the ebb

func _part3() -> void:
	_progress("brood")
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_to_part3(g, r)
	_walk(g, g.clock + 1.0)
	check("THE ISLAND: its objective, the fords pinged", r.obj.get("island", "") == "active" and _said(r, "v_island"))
	_kill(r.tagged("isl_ground"))
	_walk(g, g.clock + 1.0)
	check("the old ground burned: `island` burned", r.fired.has("isl_broken") and str(r.flags.get("island")) == "burned")
	_walk(g, g.clock + 6.0)
	check("THE LAST WAVE down the levee (the Sire with it: the clutch saved), the ebb's clock", r.fired.has("last_wave") and r.tagged("lw").size() >= 12
		and r.tagged("lw").any(func(u): return u.kind == "tyrannosaur") and r.clocks.has("ebb"))
	_walk(g, float(r.fired["last_wave"]) + 6.0)
	_kill(r.tagged("lw"))
	_walk(g, g.clock + 14.0)
	check("the last wave broken: THE EBB, WON for the column", g.over and r.winner_side == "column", "%s %s" % [g.over, r.winner_side])
	check("the flags: jungle held, island burned, inacio joined", str(r.flags.get("jungle")) == "held" and str(r.flags.get("island")) == "burned"
		and str(r.flags.get("inacio")) == "joined", str(r.flags))
	# the island left standing: the last wave comes anyway (NO WAITING), the ebb's clock out: won, island standing
	_progress("brood", {"b01": {"clutch": "burned"}, "d08": {"lure": "used"}})
	g = await _start()
	r = g.mission
	_to_part2(g, r)
	_to_part3(g, r)
	_walk(g, float(r.fired["part3"]) + 150.0)
	check("the island left alone: the last wave comes anyway; no Sire (b01's clutch burned)", r.fired.has("last_wave")
		and not r.tagged("lw").any(func(u): return u.kind == "tyrannosaur"))
	_walk(g, float(r.fired["last_wave"]) + 50.0)
	check("d08 lure used: they come to the smell of it, one wave more", r.fired.has("smell") and _said(r, "n_smell"))
	r.clocks["ebb"] = g.clock + 0.5
	_walk(g, g.clock + 12.0)
	check("the ebb's clock out: WON, `island` standing", g.over and r.winner_side == "column" and str(r.flags.get("island")) == "standing", str(r.flags))


func _reclaim() -> void:
	_progress("brood", {}, true)
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 4.0)
	check("THE RECLAIM PART said: the battery the swarm's", _said(r, "s_bat") and _said(r, "v_bat"))
	_kill(r.tagged("bat_swarm"))
	_walk(g, g.clock + 3.0)
	check("the battery taken back: `reclaim` barra, the Barra's survivors join", str(r.flags.get("reclaim")) == "barra" and r.obj.get("reclaim", "") == "done"
		and r.tagged("survivors").size() == 4)


func _defeat() -> void:
	_progress("brood")
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 5.0)
	var v: Unit = r.tagged("valadares")[0]
	v.take_damage(99999.0, null)
	_walk(g, g.clock + 1.0)
	check("Valadares hit hard: wounded, not killed (a story hero)", not v.dead)
	for b in r.tagged("keep"):
		b.take_damage(9999999.0, null)
	_walk(g, g.clock + 4.0)
	check("the keep lost: LOST", g.over and r.winner_side != "column" and _said(r, "n_keep_lost"), "%s %s" % [g.over, r.winner_side])


# ================================================================== the swarm: the solo pick, versus

func _mirror() -> void:
	for first in ["brood", "clockwork"]:
		_progress(first)
		var g: Game = await _start("solo", "swarm")
		var r := g.mission
		_walk(g, 10.0)
		check("the swarm alone (%s): the player is the swarm, its objectives, the dry season's clock" % first, g.human == r.team_index("swarm")
			and r.obj.get("s_hold", "") == "active" and r.obj.get("s_obidos", "") == "active" and r.clocks.has("dry")
			and r.obj.get("balloon", "hidden") == "hidden")
		check("... the Sires rooted by the Mothers, grubs, raiders, a Toad; the creek mouth GROWN", r.tagged("sires").size() == 2
			and r.tagged("grubs").size() == 4 and r.tagged("s_toads").size() == 1)
		check("... the NEW cards for B7", _said(r, "new_mist_toad"))
		if first == "brood":
			_walk(g, 50.0)
			check("the column's riders probe a nest early (NO WAITING)", r.fired.has("sc_probe") and _said(r, "n_s_probe"))
			r.clocks["dry"] = g.clock + 0.5
			_walk(g, g.clock + 8.0)
			check("the dry season with two Mothers: WON for the swarm (thin)", g.over and r.winner_side == "swarm" and str(r.flags.get("jungle")) == "thin",
				"%s %s" % [g.over, r.winner_side])
		else:
			var fw: Array = r.tagged("fwd")
			_kill(fw.slice(0, fw.size() - 1))
			_walk(g, g.clock + 8.0)
			check("down to one Mother: LOST for the swarm (the column wins)", g.over and r.winner_side == "column", "%s %s" % [g.over, r.winner_side])


func _versus() -> void:
	_progress("brood")
	var g: Game = await _start("versus", "", "swarm")
	var r := g.mission
	_walk(g, 4.0)
	check("versus: both objectives (break to one / hold two), no scripted waves", r.obj.get("v_break", "") == "active" and r.obj.get("s_hold", "") == "active"
		and not r.fired.has("raid_1"))
	_walk(g, 30.0)
	check("... the solo column's raids are off", not r.fired.has("raid_1"))
	var fw: Array = r.tagged("fwd")
	_kill(fw.slice(0, fw.size() - 1))
	_walk(g, g.clock + 8.0)
	check("versus: the column breaks the nests to one: WON for the column", g.over and r.winner_side == "column", "%s %s" % [g.over, r.winner_side])


# ================================================================== save and load, ironman

func _snap(g: Game) -> Dictionary:
	var r := g.mission
	var tags := {}
	for k in r.tags:
		tags[k] = r.tagged(k).size()
	return {"flags": r.flags, "counters": r.counters, "obj": r.obj, "tags": tags, "fired": r.fired.keys().size()}


func _save_load() -> void:
	_progress("clockwork")
	MissionSave.clear_all(MID)
	var g: Game = await _start()
	var r := g.mission
	_to_part2(g, r)
	_walk(g, g.clock + 5.0)
	for i in 600:
		await physics_frame          # (the game itself runs a while: the Mothers finish rooting)
	var before := _snap(g)
	var rooted0: int = r.tagged("fwd").filter(func(u): return BroodNew.rooted(u)).size()
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
	var rooted1: int = g2.mission.tagged("fwd").filter(func(u): return BroodNew.rooted(u)).size()
	check("... the Mothers rooted as they were", rooted1 == rooted0, "%d -> %d of %d" % [rooted0, rooted1, g2.mission.tagged("fwd").size()])
	for i in 90:
		await physics_frame
	check("plays on after the load with no script error", _errs.is_empty(), str(_errs.slice(0, 3)))
	main._to_menu()
	await process_frame
	MissionSave.clear_all(MID)


func _ironman() -> void:
	_progress("brood")
	Campaign.set_ironman()
	var g: Game = await _start()
	var labels: Array = g.hud._menu_list().map(func(b: Dictionary) -> String: return String(b["label"]))
	check("IRONMAN: no SAVE nor LOAD SAVE in the match menu", not labels.has("SAVE") and not labels.has("LOAD SAVE"), str(labels))
	main._to_menu()
	await process_frame
	_progress("brood")


# ================================================================== the hubs and the war map after d10

func _hubs() -> void:
	_progress("brood")
	Campaign.record(MID, "solo", "column", "column", {"version": "fresh", "jungle": "held", "island": "burned", "inacio": "joined"})
	var p := Campaign.progress()
	var pro: Dictionary = {}
	var nat: Dictionary = {}
	for s in Campaign.index()["storylines"]:
		match String(s["id"]):
			"prologue": pro = s
			"naturalist": nat = s
	check("the King's study: the King on the nests broken", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["king"], p)).contains("broke every nest"))
	check("the King's study: Ruggieri's dispatch from Óbidos", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["dispatch"], p)).contains("Óbidos"))
	check("Valadares at the Barra: the island burned", str(CampaignMenu.talk_lines(nat["hub"]["talks"]["valadares"], p)).contains("old ground on"))
	var st := WarMapData.state(p)
	var led: Array = st.get("ledger", []).map(func(x): return String(x.get("text", "")))
	check("the war map: the lower river contested, the island's line in the ledger", String(st["regions"]["lower_amazon"]) == "contested"
		and led.has("The swarm's oldest ground on Lindqvist's island was burned with the fazenda's ruins."), str(led.slice(-3)))
	check("the war map's data has no problem", WarMapData.problems().is_empty(), "; ".join(WarMapData.problems()))
	_progress("brood", {}, true)
	Campaign.record(MID, "solo", "column", "column", {"version": "fresh", "jungle": "thin", "island": "standing", "reclaim": "barra"})
	p = Campaign.progress()
	st = WarMapData.state(p)
	check("thin: the lower river the swarm's; the reclaim mends d08's seal", String(st["regions"]["lower_amazon"]) == "brood"
		and String(st["pins"]["d08_rivers"]["seal"]) != "broken", str(st["pins"]["d08_rivers"]))
	check("thin: the King says some nests outlived the rains", str(CampaignMenu.talk_lines(pro["hub"]["talks"]["king"], p)).contains("outlived the rains"))
	_progress("brood")
	Campaign.record(MID, "solo", "swarm", "swarm", {"jungle": "thin", "island": "standing"})
	p = Campaign.progress()
	check("the swarm's win: the seal broken (not how it went), Valadares says so", String(WarMapData.state(p)["pins"][MID]["seal"]) == "broken"
		and str(CampaignMenu.talk_lines(nat["hub"]["talks"]["valadares"], p)).contains("stayed green"))
