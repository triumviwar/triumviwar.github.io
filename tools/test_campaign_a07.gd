extends SceneTree
## Act 1's "The Council of Rome" (docs/campaign_a07_build.md) and the engine it brought:
##   - the data checks out, every text has pt and es, it is in all three lines once, it opens only when a04, a05 AND a06
##     are won (its "needs"), each of them leads to it, the seats for solo, co-op and versus (THE VERSUS PICK: the friend
##     leads the creatures or the automata), the map (the city generator's Rome: three bridges and no other way over),
##     the stills, the war map's pin and rules, THE ROSTER LADDER's C4 (the Church, the Missionary);
##   - THE FLAGS AT THE START: c01 `gate` / `bells`, a03 `map`, b01 `clutch` / `teles` (the opening's lines), a05
##     `cages` / `eggs` (the specimens), a04 `broken` / `lost_to_machine` (the automata), a06 `varenne` (the torches);
##   - PART 1: the MID-MATCH SHOW (the verdict), the walk-out, `hollweg` / `lindqvist` defied;
##   - PART 2: the first fire, THE SPREADING FIRE (spreads, put out by men by it, by rain, lit by a torch), the people
##     called by Father Tomasz or a trained Missionary (auto_tags), saved at the steps, fleeing the machines, the mob,
##     the specimens loose, the demonstration gone wrong (kept) / failed (melted), creatures and machines hostile;
##   - PART 3 and DAWN: the bridges, the tallies (`rome`, `people`), the win, the ending, the progress;
##   - MORE THAN TWO SIDES: the machines in the square win it (the Crown out, the winner the side whose objective is
##     done), the King dead in solo, versus: a scripted side out (the match goes on), the person's side out (the other
##     person wins);
##   - THE DIFFICULTY (the dawn clock, the waves), THE HUBS after Rome.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_a07.gd
## Prints CHECK lines, then "campaign_a07: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "a07_council"
var main: Node
var fails := 0
var _kept := ""


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-74s %s %s" % [name, "ok" if ok else "FAIL", detail])
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
	print("campaign_a07: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if the three lines had been played up to Rome with these flags (missing keys: not in the progress).
func _progress(fl := {}, diff := "normal") -> void:
	var p := {"reached": [MID], "done": {}, "difficulty": diff}
	var by := {"c01_thirteenth": ["guild", ["gate", "bells", "jakob"]], "a03_plateau": ["party", ["map"]],
		"b01_specimen": ["sire", ["clutch", "teles"]], "a04_visit": ["visit", ["broken", "lost_to_machine"]],
		"a05_specimens": ["expedition", ["cages", "eggs"]], "a06_barricades": ["crown", ["varenne"]]}
	for mid in by:
		var f := {}
		for k in by[mid][1]:
			if fl.has(k):
				f[k] = fl[k]
		p["done"][mid] = {"won_by": by[mid][0], "side": by[mid][0], "flags": f}
	Campaign.save_progress(p)


func _start(mode := "solo", pick := "") -> Game:
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
	_step(g, 1.0)
	return g


func _step(g: Game, to: float) -> void:
	g.clock = to
	var r := g.mission
	r._tick_turning()
	r._tick_exits()
	r._tick_held()
	r._tick_auto_tags()
	r._tick_routes()
	r._run_triggers()
	r._check_objectives()


func _walk(g: Game, to: float) -> void:
	var t := g.clock
	while t < to and not g.over:
		t = minf(to, t + 0.25)
		_step(g, t)


func _kill(r: MissionRun, tag: String) -> void:
	for e in r.tagged(tag):
		if e is Building:
			e.spared = false
			e.take_damage(1e9, null)
		else:
			e.spared = false
			e.die()


func _put(g: Game, us: Array, at: Vector2) -> void:
	var i := 0
	for u in us:
		u.position = at + Vector2((i % 4) * 14 - 21, (i / 4) * 14 - 14)
		u.velocity = Vector2.ZERO
		u.cmd_stop()
		i += 1
	g._rebuild_hash()


func _said(r: MissionRun, id: String) -> bool:
	return r.said_ids.has(id)


func _run() -> void:
	await process_frame
	_data()
	await _flags()
	await _parts()
	await _fire()
	await _sides()
	await _dawn()
	await _difficulty()
	_hub()
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("a07_council: data checks out", pr.is_empty(), "; ".join(pr))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings():
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	for sl in Campaign.storylines():
		# (Act 2 goes on after Rome: d02_exodus on the clockmaker line; every mission after Rome needs it)
		var ms: Array = sl["missions"]
		var after_ok := ms.has(MID)
		for i in range(ms.find(MID) + 1, ms.size()):
			after_ok = after_ok and (Campaign.mission(String(ms[i])).get("needs", []) as Array).has(MID)
		check("the %s line reaches Rome (Act 2 after it)" % sl["id"], after_ok)
	check("Rome listed once among the missions", Campaign.mission_ids().count(MID) == 1)
	for a in [["a04_visit", "visit"], ["a05_specimens", "expedition"], ["a06_barricades", "crown"]]:
		check("%s won by the %s leads to Rome" % a, Campaign.next_of(a[0], a[1]) == MID)
	# THE CROSSING'S NEEDS: open only when all three are won, whichever led to it
	Campaign.save_progress({"reached": [], "done": {}})
	Campaign.record("a06_barricades", "solo", "crown", "crown", {"varenne": "spared"})
	check("Rome is locked with only a06 won (though reached)", (Campaign.progress()["reached"] as Array).has(MID) and not Campaign.unlocked(MID))
	Campaign.record("a04_visit", "solo", "visit", "visit", {"broken": "kept"})
	check("...still locked with a04 and a06", not Campaign.unlocked(MID))
	Campaign.record("a05_specimens", "solo", "expedition", "expedition", {"cages": "some"})
	check("...open once a05 is won too", Campaign.unlocked(MID))
	check("solo: the Crown only (no solo side pick)", Campaign.solo_sides(m) == ["crown"])
	var c := Campaign.make_cfg(MID, "solo")
	check("solo: you are the guard; the garrison, the town, the creatures, the automata, the cell scripted",
		c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "script", "script", "script"])
	c = Campaign.make_cfg(MID, "coop", "p1", true)
	check("co-op online: the friend has the garrison of the east bank", c["slots"].map(func(s): return s["who"]) == ["you", "remote", "script", "script", "script", "script"])
	c = Campaign.make_cfg(MID, "versus", "p1", true)
	check("versus online, no pick: the friend leads the creatures (the first pick)", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "remote", "script", "script"]
		and String(c["campaign"].get("pick", "")) == "creatures")
	c = Campaign.make_cfg(MID, "versus", "p1", true, "automata")
	check("THE VERSUS PICK: the friend leads the automata, the creatures scripted", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "script", "remote", "script"]
		and String(c["campaign"].get("pick", "")) == "automata")
	check("the versus seats: p2 is the creatures or the automata by the pick", Campaign.seat_side(m, "versus", "p2") == "creatures"
		and Campaign.seat_side(m, "versus", "p2", "automata") == "automata" and Campaign.seat_side(m, "versus", "p1", "automata") == "crown")
	c = Campaign.make_cfg(MID, "versus", "p2", true, "automata")
	check("versus, the host takes the automata: the friend the Crown", c["slots"].map(func(s): return s["who"]) == ["remote", "script", "script", "script", "you", "script"])
	check("the guard PURPLE, the town YELLOW, the creatures GREEN, the automata RED, the cell ORANGE",
		c["slots"].map(func(s): return int(s["colour"])) == [4, 0, 3, 2, 1, 5])
	var md := Campaign.map_data("rome_council")
	check("the map is the city generator's Rome, 128 x 96", String(m["map"]) == "campaign:rome_council" and (md.get("size", []) as Array).map(func(x): return int(x)) == [128, 96]
		and (md.get("props", []) as Array).size() > 500)
	for k in m["stills"]:
		check("still %s: its picture loads" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	check("an opening and an ending for every side but the cell", ["crown", "creatures", "automata"].all(func(s): return (m["opening"] as Dictionary).has(s) and (m["ending"] as Dictionary).has(s)))
	var guard: Dictionary = m["teams"][0]
	check("THE ROSTER LADDER C4: the guard may build the Church and train the Missionary, new here", (guard["roster"]["new"] as Array) == ["church", "missionary"]
		and (guard["roster"]["allow"] as Array).has("mortar") and not (guard["roster"]["allow"] as Array).has("armoury"))
	check("the NEW cards to the Crown", m["lines"].has("new_church") and m["lines"].has("new_missionary") and String(m["lines"]["new_church"]["to"]) == "crown")
	var wp := WarMapData.problems()
	check("the war map: no problems", wp.is_empty(), "; ".join(wp))
	var p := {"reached": [], "done": {MID: {"won_by": "crown", "side": "crown", "flags": {"rome": "few", "people": "some", "people_n": 9, "hollweg": "defied"}}}}
	var st := WarMapData.state(p)
	check("the war map: Rome's pin done, the Papal States contested with `rome` few", String(st["pins"][MID]["state"]) == "done" and String(st["regions"]["papal_states"]) == "contested")
	p["done"][MID] = {"won_by": "automata", "side": "automata", "flags": {"rome": "few"}}
	st = WarMapData.state(p)
	check("the war map: the machines' win breaks Rome's seal", String(st["pins"][MID]["seal"]) == "broken" and String(st["regions"]["papal_states"]) == "machine")


# ================================================================== the flags

func _flags() -> void:
	# the canon (nothing in the progress for the flags): pattern, quiet, drawn, saved+quiet, kept, spared, some cages
	_progress({})
	var g: Game = await _start()
	var r: MissionRun = g.mission
	var lines := _opening(r, "crown")
	check("canon opening: Ferrer's drawings, the quarrel, Valadares drew, Hollweg accused, the eggs found, Varenne's letter",
		["f_pattern", "f_quarrel", "v_drawn", "k_hollweg_quiet", "k_eggs_found", "k_varenne_spared", "l_oldest", "h_brass"].all(func(x): return lines.has(x))
		and not lines.has("f_people") and not lines.has("k_varenne_exec"), str(lines))
	check("canon: the specimens are some (4 Raptors, 2 Spitters)", _kinds(r, "specimens") == {"raptor": 4, "spitter": 2}, str(_kinds(r, "specimens")))
	check("canon: Hollweg's demonstration kept (5 Clock Soldiers, 2 Springers, a Pendulum, 2 Winders)",
		_kinds(r, "demo") == {"clock_soldier": 5, "springer": 2, "pendulum": 1, "winder": 2}, str(_kinds(r, "demo")))
	check("the specimens caged and spared, the demonstration too", r.tagged("specimens").all(func(u): return u.has_meta("mission_caged") and u.spared)
		and r.tagged("demo").all(func(u): return u.has_meta("mission_caged") and u.spared))
	_progress({"gate": "people", "bells": "rung", "map": "withheld", "clutch": "burned", "cages": "all", "eggs": "taken",
		"broken": "melted", "lost_to_machine": 3, "varenne": "executed"})
	g = await _start()
	r = g.mission
	lines = _opening(r, "crown")
	check("the other flags: Ferrer's report, Valadares withheld, Hollweg a witness, the eggs ashes, Varenne dead",
		["f_people", "v_withheld", "k_hollweg_rung", "k_eggs_ashes", "k_varenne_exec"].all(func(x): return lines.has(x)) and not lines.has("f_pattern")
		and not lines.has("k_eggs_found"), str(lines))
	var sk := _kinds(r, "specimens")
	check("a05 cages all and eggs taken: 7 Raptors, 2 Spitters, a Challenger, the young Sire", sk == {"raptor": 7, "spitter": 2, "tyrant_challenger": 1, "tyrannosaur": 1}, str(sk))
	check("a04 melted + lost 3: two Clock Soldiers and the Machine's two Springers", _kinds(r, "demo") == {"clock_soldier": 2, "springer": 2}
		and r.tagged("machine_own").size() == 2, str(_kinds(r, "demo")))
	_progress({"clutch": "saved", "teles": "told", "cages": "few"})
	g = await _start()
	r = g.mission
	lines = _opening(r, "crown")
	check("b01 saved + told: the eggs were no secret", lines.has("k_eggs_told") and not lines.has("k_eggs_found"), str(lines))
	check("a05 cages few: 3 Raptors and a Spitter", _kinds(r, "specimens") == {"raptor": 3, "spitter": 1})
	check("the creatures' opening and the automata's", _opening(r, "creatures").has("cr_1") and _opening(r, "automata").has("au_1"))


func _opening(r: MissionRun, side: String) -> Array:
	var out: Array = []
	for pg in r.pages_now(Campaign.show_pages(r.data, "opening", side)):
		for l in pg.get("lines", []):
			out.append(String(l))
	return out


func _kinds(r: MissionRun, tag: String) -> Dictionary:
	var out := {}
	for u in r.tagged(tag):
		out[u.kind] = int(out.get(u.kind, 0)) + 1
	return out


# ================================================================== the parts

func _parts() -> void:
	_progress({"varenne": "executed", "broken": "kept", "lost_to_machine": 2})
	var g: Game = await _start()
	var r: MissionRun = g.mission
	_walk(g, 2.5)
	check("PART 1: the verdict is a MID-MATCH SHOW (its lines in order)", r.shows.size() == 1 and r.shows[0][0]["lines"] == ["c_verdict1", "c_verdict2"]
		and r.shows[0][1]["lines"] == ["h_defy", "l_defy", "k_letgo"], str(r.shows))
	_walk(g, 6.0)
	check("the walk-out: Hollweg and Lindqvist leave, both defied", r.fired.has("walk_out") and r.flags.get("hollweg") == "defied" and r.flags.get("lindqvist") == "defied")
	_walk(g, 34.0)
	check("the King's tips and the bridges pinged", r.fired.has("tips") and _said(r, "k_tip_bridges"))
	check("Ferrer and Valadares go into the basilica (removed)", r.tagged("ferrer").is_empty() and r.tagged("valadares").is_empty())
	check("the NEW cards are said", _said(r, "new_church") and _said(r, "new_missionary"))
	_walk(g, 50.5)
	check("PART 2 at 0:50: the first fire in the Campo Marzio", r.fired.has("part2") and r.burning_count("q_campo_marzio") == 1)
	check("the people and the fires objectives shown", r.obj["people"] == "active" and r.obj["fires"] == "active")
	check("the people no longer spared (the beasts can reach them)", r.tagged("people").all(func(u): return not u.spared))
	_walk(g, 63.0)
	check("executed: the cell burns Rome for Varenne", _said(r, "n_cell_exec") and not _said(r, "n_cell_spared"))
	# the people: Father Tomasz near the Piazza Navona calls Parione's
	var tz: Unit = r.tagged("tomasz")[0]
	_put(g, [tz], r.area_rect("navona").get_center())
	_step(g, g.clock + 0.25)
	check("Father Tomasz near the people of Parione calls them (they make for Saint Peter's)", r.fired.has("call_parione") and _said(r, "t_call"))
	# a Missionary trained at Santo Spirito leads too (auto_tags)
	var guard := r.team_index("guard")
	var mis: Unit = g._add_unit("missionary", guard, r.area_rect("campo_fiori").get_center())
	_step(g, g.clock + 0.25)
	check("a trained Missionary is a leader (auto_tags) and calls Regola's people", r.tagged("leaders").has(mis) and r.fired.has("call_regola"))
	# saved at the steps
	var ppl: Array = r.tagged("people_parione")
	_put(g, ppl.slice(0, 2), r.area_rect("steps").get_center())
	_step(g, g.clock + 0.25)
	check("people at the basilica's steps are saved (counted)", int(r.counters["saved"]) == 2 and _said(r, "n_saved"), str(r.counters["saved"]))
	# the Romans fear the machines: an automaton by the Campo Marzio's people sends them running; in Parione the mob
	var aut: Array = r.tagged("demo")
	r.act({"cage": {"tag": "demo", "on": false}})
	_put(g, [aut[0]], r.area_rect("popolo_square").get_center() + Vector2(3 * Defs.TILE, 0))
	_step(g, g.clock + 0.25)
	check("an automaton by the people of the Campo Marzio: they flee for the bridge", r.fired.has("flee_campo_marzio") and _said(r, "n_flee"))
	_put(g, [aut[1]], r.area_rect("navona").get_center() + Vector2(2 * Defs.TILE, 0))
	_step(g, g.clock + 0.25)
	check("an automaton in Parione: the Romans turn on it (the mob, hunting)", r.fired.has("mob") and r.tagged("mob").size() == 4 and _said(r, "n_mob"))
	r.act({"cage": {"tag": "demo", "on": true}})
	_walk(g, 50.0 + 70.5)
	check("+1:10: the specimens break loose (uncaged, on their routes)", r.fired.has("loose") and r.tagged("specimens").all(func(u): return not u.has_meta("mission_caged") and not u.spared))
	_walk(g, 50.0 + 110.5)
	check("+1:50: Hollweg's demonstration goes wrong (kept)", r.fired.has("demo_wrong") and _said(r, "h_demo") and not r.fired.has("demo_fail"))
	_walk(g, 50.0 + 121.0)
	check("the Machine's own among them (lost_to_machine 2): the King's line", _said(r, "k_machine_own"))
	check("the torches: four groups with `varenne` executed (two without)", r.fired.has("torch_1") and r.fired.has("torch_3"))
	check("creatures and machines are enemies (and both the Crown's)", g.hostile(r.team_index("creatures"), r.team_index("automata"))
		and g.hostile(r.team_index("creatures"), guard) and g.hostile(r.team_index("automata"), guard) and g.hostile(r.team_index("assembly"), r.team_index("automata")))
	_walk(g, 50.0 + 110.0 + 61.0)
	check("PART 3: the bridges' objective and the dawn clock", r.fired.has("part3") and r.obj["bridges"] == "active" and r.clocks.has("dawn"))
	_walk(g, g.clock + 25.0)
	check("Part 3's waves come (the creatures from the stables)", r.fired.has("cre_wave_6a") and r.tagged("cre_wave_a").size() == 6)


# ================================================================== the spreading fire

func _fire() -> void:
	_progress({})
	var g: Game = await _start()
	var r: MissionRun = g.mission
	_walk(g, 50.5)
	var houses: Array = r.tagged("q_campo_marzio")
	var lit: Array = houses.filter(func(b): return r.is_burning(b))
	check("THE SPREADING FIRE: one house alight at the start of Part 2", lit.size() == 1)
	_walk(g, 50.0 + 19.0)
	check("...18 s later it has taken the next house (within 7 tiles)", r.burning_count("houses") >= 2, str(r.burning_count("houses")))
	check("a burning house loses its health (spared from blows, not from fire)", lit[0].hp < lit[0].max_hp and lit[0].spared)
	# men by it put it out: the guard's muskets beside the first house
	var men: Array = r.tagged("guard_men").slice(0, 4)
	var b0: Building = lit[0]
	_put(g, men, b0.center() + Vector2(0, b0.rect().size.y * 0.5 + 20))
	var hp0: float = b0.hp
	var out0 := r.fires_out
	_walk(g, g.clock + 4.5)
	check("four men by it put it out in about 14/4 s (its health kept where the fire left it)", not r.is_burning(b0) and r.fires_out > out0 and b0.hp > 0.0 and b0.hp < hp0 + 1.0)
	# the people of the town team don't put it out (douse_teams: the guard and the garrison)
	var other: Variant = null
	for b in r.tagged("houses"):
		if r.is_burning(b):
			other = b
	if other != null:
		var ppl: Array = r.tagged("people_campo_marzio")
		_put(g, ppl, other.center() + Vector2(0, other.rect().size.y * 0.5 + 20))
		_walk(g, g.clock + 5.0)
		check("the town's people by a fire don't put it out (only the guard and the garrison)", r.is_burning(other))
	# a torch-bearer at a house sets it alight (torch_fire), spared or not
	var cold: Array = r.tagged("q_regola").filter(func(b): return not r.is_burning(b))
	var torch: Array = r._spawn({"team": "assembly", "kind": "labourer", "as": "torch", "count": 1, "at": "campo_fiori", "tag": "t_test"})
	_put(g, torch, cold[0].center() + Vector2(0, cold[0].rect().size.y * 0.5 + 10))
	Rebels.tick(r, 0.25)
	check("a torch-bearer at a house sets it ALIGHT (a spreading fire)", r.is_burning(cold[0]) and r.burning_count("q_regola") >= 1)
	# rain puts every fire out in time
	var n := r.burning_count("houses")
	r.act({"weather": "rain"})
	_walk(g, g.clock + 40.0)
	check("RAIN puts the fires out (%d alight before)" % n, r.burning_count("houses") == 0 and n > 0)
	r.act({"weather": ""})
	# `burning` condition and `douse` action
	r.act({"burn": {"tag": "q_parione", "secs": 60}})
	check("condition burning: the whole of Parione alight", r.cond({"burning": {"tag": "q_parione", "at_least": 5}}))
	r.act({"douse": {"tag": "q_parione"}})
	check("action douse: Parione's fires out", r.cond({"burning": {"tag": "q_parione", "below": 1}}))
	# a burned-down house
	r.act({"burn": {"tag": "q_borgo", "secs": 2}})
	_walk(g, g.clock + 4.0)
	check("a fire left alone burns a house down", r.tagged("q_borgo").size() < 2)


# ================================================================== more than two sides

func _sides() -> void:
	# the machines in Saint Peter's Square (solo): their objective done, the Crown's failed, the winner the automata
	_progress({})
	var g: Game = await _start()
	var r: MissionRun = g.mission
	_walk(g, 2.0)
	r.act({"cage": {"tag": "demo", "on": false}})
	_put(g, r.tagged("demo").slice(0, 3), r.area_rect("piazza_in").get_center())
	_step(g, g.clock + 0.25)
	_step(g, g.clock + 1.5)
	check("MORE THAN TWO SIDES: three machines in the square win it for the automata (the Crown out)", g.over and r.winner_side == "automata"
		and r.obj["m_cross"] == "done" and r.obj["bridges"] == "failed" and r.out_sides.has("crown"), "%s %s" % [r.winner_side, r.out_sides])
	# the King killed in solo: the Crown out, nobody's objective done: the first side still in
	g = await _start()
	r = g.mission
	_kill(r, "king")
	_step(g, g.clock + 0.25)
	check("the King killed: the Crown loses (the first other side takes it)", g.over and r.winner_side == "creatures" and r.obj["king"] == "failed")
	# VERSUS with the friend on the automata (the friend's team marked as a person's, as online)
	g = await _start("versus", "automata")
	r = g.mission
	r.player_teams[r.team_index("automata")] = true
	r.side_lost("creatures")
	check("versus: a scripted side out (the creatures): the match goes on", not g.over and r.out_sides.has("creatures") and r.cond({"out": "creatures"}))
	r.act({"lose": "automata"})
	check("versus: the friend's side out: the other person's side (the Crown) wins", g.over and r.winner_side == "crown")
	# the old rule still holds for two sides (test_campaign covers the missions); winner_after with three in solo
	g = await _start()
	r = g.mission
	r.side_lost("assembly")
	check("a side with no objectives out (the cell): the match goes on", not g.over and r.out_sides.has("assembly"))


# ================================================================== dawn

func _dawn() -> void:
	_progress({"broken": "melted"})
	var g: Game = await _start()
	var r: MissionRun = g.mission
	while g.clock < 50.0 + 112.0:
		_walk(g, minf(g.clock + 5.0, 50.0 + 112.0))
		r.act({"douse": {"tag": "houses"}})      # (the guard at the fires as they start)
	check("melted: the two pieces fail anyway", r.fired.has("demo_fail") and _said(r, "h_demo_melted") and not r.fired.has("demo_wrong"))
	_walk(g, 50.0 + 110.0 + 61.0)
	check("melted: no automata waves in Part 3", r.fired.has("part3") and not r.data["triggers"].filter(func(t): return String(t["id"]).begins_with("aut_wave")).any(func(t): return r.fired.has(t["id"])))
	# keep the guard alive and the square clear: the waves sent away (killed) as they come
	_kill(r, "specimens")
	_kill(r, "demo")
	_kill(r, "q_regola")        # (a quarter burned down: it did not stand)
	var ppl: Array = r.tagged("people_parione") + r.tagged("people_regola").slice(0, 2)
	_put(g, ppl, r.area_rect("steps").get_center())
	var dawn := float(r.clocks["dawn"])
	while g.clock < dawn - 1.0 and not g.over:
		_walk(g, g.clock + 10.0)
		for t in ["cre_wave_a", "cre_wave_b", "cell", "torches", "bridge_cell"]:
			_kill(r, t)
		r.act({"douse": {"tag": "houses"}})      # (the guard at the fires)
	check("rain before dawn", r.fired.has("dawn_near") and r.weather_name == "rain")
	_walk(g, dawn + 9.0)
	check("DAWN: the bridges held, the Crown wins", g.over and r.winner_side == "crown" and r.obj["bridges"] == "done")
	check("the tallies: `rome` some (4 of 5 quarters) and `people` (8 of 18 saved: some)", r.flags.get("rome") == "some" and int(r.flags.get("rome_n", -1)) == 4
		and r.flags.get("people") == "some" and int(r.flags.get("people_n", -1)) == 8, str(r.flags))
	check("the ending: the verdict stood, some of Rome burned, the defiance", r.pages_now(Campaign.show_pages(r.data, "ending", "crown")).any(func(pg): return (pg["lines"] as Array).has("k_end_rome_some"))
		and r.pages_now(Campaign.show_pages(r.data, "ending", "crown")).any(func(pg): return (pg["lines"] as Array).has("k_end_defiance")))
	await create_timer(1.8).timeout
	var p := Campaign.progress()
	check("the progress: Rome won by the Crown with its flags", (p["done"] as Dictionary).has(MID) and String(p["done"][MID]["won_by"]) == "crown"
		and String(p["done"][MID]["flags"].get("rome", "")) == "some" and String(p["done"][MID]["flags"].get("hollweg", "")) == "defied")


# ================================================================== the difficulty

func _difficulty() -> void:
	for d in [["easy", 0.8, 4], ["hard", 1.2, 8]]:
		_progress({}, d[0])
		var g: Game = await _start()
		var r: MissionRun = g.mission
		check("%s: the guard is the player's: never scaled" % d[0], r.tagged("guard_men").size() == 14)
		_walk(g, 50.0 + 110.0 + 61.0)
		var want := 540.0 * float(d[1])
		check("%s: dawn in %d s" % [d[0], int(want)], absf(float(r.clocks.get("dawn", 0.0)) - float(r.fired["part3"]) - want) < 2.0, str(r.clocks))
		_walk(g, g.clock + 25.0)
		check("%s: the creatures' first wave scaled (%d)" % [d[0], d[2]], r.tagged("cre_wave_a").size() == int(d[2]), str(r.tagged("cre_wave_a").size()))


# ================================================================== the hubs

func _hub() -> void:
	var after := {"done": {MID: {"side": "crown", "flags": {"rome": "all"}}, "a04_visit": {"side": "visit", "flags": {"broken": "kept"}},
		"a06_barricades": {"side": "crown", "flags": {"varenne": "spared"}}, "a05_specimens": {"side": "expedition"}}}
	for sl in Campaign.storylines():
		var hub: Dictionary = sl["hub"]
		for k in hub["talks"]:
			var es: Array = hub["talks"][k]["entries"]
			if es.any(func(e): return String(e.get("after", "")) == MID):
				var tl: Array = CampaignMenu.talk_lines(hub["talks"][k], after)
				var want: Array = es.filter(func(e): return String(e.get("after", "")) == MID)[0]["lines"]
				check("hub %s, %s: the talk after Rome" % [sl["id"], k], tl == want, str(tl))
