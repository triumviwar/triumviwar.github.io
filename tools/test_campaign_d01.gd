extends SceneTree
## Act 2's "The Gold of Vila Rica" (docs/campaign_d01_build.md):
##   - the data checks out, every text has pt and es, the Crown's line lists it after a07 and it opens only once a07 is
##     won (`needs`), the seats (solo the Crown, versus the conspiracy), the HIGHLANDS map (the city generator in hills)
##     and the stills, THE ROSTER LADDER's C5 for the garrison (the Armoury, the Matchlock, the Socket Bayonet), the
##     hub's purse and reach (hubs-grow);
##   - THE FLAGS at the start: a07 `rome` few (the temper higher), a06 `varenne` executed (Varenne's martyrs: the temper
##     higher, the line), a01 `lyon` risen (no printer's mark, Tomasz's letter), the canon (one armoury given away);
##   - PART 1: the NEW cards, the Armoury's research, Tomasz calming the quarters (a STAY), an agitator reaching a
##     churchyard (the temper +1), a hidden armoury found by a man at its door, both closed (the ledger, the signal sooner);
##   - PART 2: the signal (`minas` tallied), the rising's bands, Tomasz calling the miners home, the rising broken;
##   - PART 3: the gold carts loaded, the ledges, the ambush, TAKE A CART and taking it back, Ramos taken alive, the carts
##     at the coast, the win (`gold`, `conspirator`), the ending and debrief; Ramos running for the hollow (fled);
##   - THE DEFEATS: the temper at the top; the Foundry House burnt; no gold at the coast;
##   - VERSUS: the conspiracy's seat, its win;
##   - SAVE AND LOAD in the middle, IRONMAN, the HUBS and the WAR MAP after d01.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_d01.gd
## Prints CHECK lines, then "campaign_d01: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "d01_minas"
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
	print("campaign_d01: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if the Crown's line was played up to a07 with these flags (each merged over its canon), at a
## difficulty. `with_a07` false: a07 not finished. `d04`: d04's flags if it was won (the ledger's cross-link).
func _progress(p01 := {}, a01 := {}, a06 := {}, a07 := {}, diff := "normal", with_a07 := true, d04 := {}) -> void:
	var p := {"reached": [MID], "done": {}, "difficulty": diff}
	var f0 := {"families": "save"}
	f0.merge(p01, true)
	p["done"]["p01_leaf"] = {"won_by": "crown", "side": "crown", "flags": f0}
	var f1 := {"lyon": "calm", "printer": "taken"}
	f1.merge(a01, true)
	p["done"]["a01_presses"] = {"won_by": "crown", "side": "crown", "flags": f1}
	var f6 := {"varenne": "spared", "paris": "stood"}
	f6.merge(a06, true)
	p["done"]["a06_barricades"] = {"won_by": "crown", "side": "crown", "flags": f6}
	if with_a07:
		var f7 := {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}
		f7.merge(a07, true)
		p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": f7}
	if not d04.is_empty():
		p["done"]["d04_concordia"] = {"won_by": "guild", "side": "guild", "flags": d04}
	Campaign.save_progress(p)


func _start(mode := "solo", online := false) -> Game:
	if main.game:
		main._to_menu()
		await process_frame
	for n in main.ui_layer.get_children():
		if n.name == "MissionEnd" or n is StillShow:
			n.queue_free()
	main.start(Campaign.make_cfg(MID, mode, "p1", online, ""))     # (online: p2's seat "remote", a person: no friend here)
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


## Steps from the clock now to `to`, a quarter second at a time (a STAY and a TAKE need every check).
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
		i += 1
	g._rebuild_hash()


func _mid(r: MissionRun, area: String) -> Vector2:
	return r.area_rect(area).get_center()


func _said(r: MissionRun, id: String) -> bool:
	return r.said_ids.has(id)


func _team_units(g: Game, r: MissionRun, team: String, kinds: Array = []) -> Array:
	var t := r.team_index(team)
	return g.units.filter(func(u): return not u.dead and u.team == t and (kinds.is_empty() or kinds.has(u.kind)))


func _alive(r: MissionRun, tag: String, team := "") -> Array:
	var t := r.team_index(team) if team != "" else -1
	return r.tagged(tag).filter(func(u): return not u.dead and (t < 0 or u.team == t))


## Tomasz in a churchyard long enough to calm it.
func _calm(g: Game, r: MissionRun, q: String) -> void:
	_put(g, r.tagged("tomasz"), _mid(r, "adro_" + q))
	_walk(g, g.clock + 5.0)


## Part 1 by the script: the four quarters calmed, both armouries closed; then the signal.
func _part1(g: Game, r: MissionRun) -> void:
	for q in ["pilar", "carmo", "rosario", "efigenia"]:
		_calm(g, r, q)
	for b in r.tagged("armouries"):
		b.die()
	_walk(g, g.clock + 1.0)
	_walk(g, float(r.clocks["signal"]) + 0.5)


## Part 2 by the script: the bands come and every one of them dies.
func _part2(g: Game, r: MissionRun) -> void:
	_walk(g, float(r.fired["signal"]) + 10.0 + 6.0 + 45.0 + 4.0)
	for u in r.tagged("rising"):
		u.die()
	_walk(g, g.clock + 2.0)


# ================================================================== the tests

func _run() -> void:
	await process_frame
	_data()
	await _flags()
	await _play()
	await _flee()
	await _defeats()
	await _versus()
	await _save_load()
	await _ironman()
	_hubs()
	check("no script error in the whole run", _errs.is_empty(), str(_errs.slice(0, 3)))
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("d01_minas: data checks out", pr.is_empty(), "; ".join(pr))
	var extra := ["TAKING THE GOLD", "GOLD TAKEN!", "TAKING IT BACK", "TAKEN BACK!", "Father Tomasz", "Captain Meneses", "Lieutenant Ramos"]
	for role in ["tomasz_minas", "meneses", "ramos", "conspirator", "martyr", "miner", "agitator", "townsman"]:
		extra.append(String(Rebels.ROLES[role]["about"]))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + extra:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission, its roles and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Crown's line lists d01 after a07", String(sl.get("id", "")) == "prologue"
		and (sl["missions"] as Array).find(MID) == (sl["missions"] as Array).find("a07_council") + 1)
	_progress({}, {}, {}, {}, "normal", false)
	check("d01 is shut until a07 is won (needs a07)", not Campaign.unlocked(MID))
	_progress()
	check("... and open once it is", Campaign.unlocked(MID))
	check("the seats: solo the Crown only; versus the Crown p1, the conspiracy p2", Campaign.solo_sides(m) == ["crown"]
		and Campaign.seat_side(m, "versus", "p1") == "crown" and Campaign.seat_side(m, "versus", "p2") == "conspiracy")
	var md := Campaign.map_data("vila_rica")
	check("the map is Vila Rica on THE HIGHLANDS, with high ground and stairs (the city generator in hills)", md.get("biome", "") == "highlands"
		and String(md.get("cells", "")).count("h") > 2000 and String(md.get("cells", "")).count("r") >= 20)
	for k in m["stills"]:
		check("still %s is in" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	var gt: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "garrison")[0]
	check("THE ROSTER LADDER C5: the garrison may have the Armoury, the Matchlock and the Socket Bayonet, all NEW (and C1-C4's pieces)",
		(gt["roster"]["allow"] as Array).has("armoury") and (gt["roster"]["allow"] as Array).has("cuirassier")
		and (gt["roster"]["new"] as Array) == ["armoury", "matchlock", "bayonet"] and (gt["roster"]["deny"] as Array).has("foundry"))
	check("hubs-grow: d01 earns ROYAL FAVOUR and the King's rooms reach it", (HubGrow.line("prologue")["earn"] as Array).has(MID)
		and HubGrow.line_for(MID) == "prologue")


# ================================================================== the flags at the start

func _flags() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	check("canon: the garrison (14 Musketeers, 4 riders, a gun, Captain Meneses) and Father Tomasz (360 health)",
		_team_units(g, r, "garrison", ["musketeer"]).size() == 14 and r.tagged("riders").size() == 4 and r.tagged("gun").size() == 1
		and r.tagged("meneses").size() == 1 and r.tagged("tomasz").size() == 1 and r.tagged("tomasz")[0].max_hp >= 360.0)
	check("the Armoury stands (C5), no research yet", r.tagged("armoury").size() == 1 and r.tagged("armoury")[0].built
		and not g.has_tech(r.team_index("garrison"), "bayonet"))
	check("two hidden armouries among the houses, disguised", r.tagged("armouries").size() == 2 and r.cond({"disguised": "armouries"}))
	check("the town's temper starts at 3 of 20 (NORMAL)", int(r.counters["temper"]) == 3 and int(r.counters["temper_top"]) == 20)
	check("the Foundry House stands, spared by day", r.tagged("foundry").size() == 1 and r.tagged("foundry")[0].spared)
	_walk(g, 26.0)
	check("canon (a01 printer taken): the printer's mark gives one armoury away", r.fired.has("printer_shown") and r.cond({"unmasked": "armouries"})
		and _said(r, "t_printer"))
	var pages := r.pages_now(Campaign.show_pages(r.data, "opening", "crown"))
	check("the opening: the King, Tomasz (p01 families saved: his line), the derrama", str(pages).contains("t_open_saved") and not str(pages).contains("t_open_left"))
	_progress({"families": "leave"}, {"lyon": "risen"}, {}, {"rome": "few"})
	g = await _start()
	r = g.mission
	_walk(g, 26.0)
	check("a07 rome few: the temper starts at 6", int(r.counters["temper"]) >= 6)
	check("a01 lyon risen: no printer's mark (nothing given away)", not r.fired.has("printer_shown"))
	pages = r.pages_now(Campaign.show_pages(r.data, "opening", "crown"))
	check("... Tomasz's letter from Lyon in the opening; p01 left: his line for the road", str(pages).contains("t_open_risen") and str(pages).contains("t_open_left"))
	_walk(g, 54.0)
	check("a07 rome few: Rome's pamphlet", _said(r, "t_pamphlet_rome"))
	_progress({}, {}, {"varenne": "executed"})
	g = await _start()
	r = g.mission
	_walk(g, 68.0)
	check("a06 Varenne executed: the temper starts higher, Varenne's martyrs on the pamphlets", int(r.counters["temper"]) >= 5 and _said(r, "t_martyrs"))
	_progress({}, {}, {}, {}, "hard")
	g = await _start()
	check("HARD: the temper's top 16", int(g.mission.counters["temper_top"]) == 16)
	_progress({}, {}, {}, {}, "easy")
	g = await _start()
	check("EASY: the temper's top 24", int(g.mission.counters["temper_top"]) == 24)


# ================================================================== the play through

func _play() -> void:
	_progress({}, {}, {}, {}, "normal", true, {"colonists": "fought", "crates": "opened"})
	var g: Game = await _start()
	var r := g.mission
	var gt := r.team_index("garrison")
	_walk(g, 9.0)
	check("the NEW cards for C5 are said", _said(r, "new_armoury") and _said(r, "new_matchlock") and _said(r, "new_bayonet"))
	_walk(g, 31.0)
	check("the Armoury's lesson: the research objective shows", r.obj.get("research", "") == "active" and _said(r, "m_armoury"))
	var why := ""
	g.players[gt]["tech"]["matchlock"] = true
	g.players[gt]["tech"]["bayonet"] = true
	_walk(g, g.clock + 1.0)
	check("both researched: the objective done", r.obj.get("research", "") == "done", why)
	# an agitator reaching a churchyard
	var t0 := int(r.counters["temper"])
	r.act({"spawn": {"team": "conspiracy", "kind": "labourer", "as": "agitator", "count": 1, "fixed": True, "at": "adro_carmo", "tag": "runner_x", "tags": ["runner"]}})
	_walk(g, g.clock + 1.0)
	check("an agitator who reaches a churchyard raises the temper", int(r.counters["temper"]) == t0 + 1, str([t0, r.counters["temper"]]))
	# Tomasz calms the quarters
	var t1 := int(r.counters["temper"])
	_calm(g, r, "pilar")
	check("Tomasz a moment in the Pilar's churchyard: the quarter calmed, the temper down 3", r.fired.has("calm_pilar") and int(r.counters["calmed"]) == 1
		and int(r.counters["temper"]) <= maxi(0, t1 - 3) + 1 and _said(r, "t_calm_pilar"))
	for q in ["carmo", "rosario", "efigenia"]:
		_calm(g, r, q)
	check("all four quarters calmed", int(r.counters["calmed"]) == 4 and r.obj.get("calm", "") == "done")
	# a hidden armoury found by a man at its door
	var hb: Building = r.tagged("armouries")[1]
	_put(g, _team_units(g, r, "garrison", ["musketeer"]).slice(0, 2), hb.center() + Vector2(0, 70))
	_walk(g, g.clock + 4.0)
	check("a man at a hidden armoury's door: it is found (its men come out)", r.cond({"unmasked": "armouries"}) and not r.tagged("armoury_men").is_empty())
	var sig0 := float(r.clocks["signal"])
	for b in r.tagged("armouries"):
		b.die()
	_walk(g, g.clock + 1.5)
	check("both armouries closed: the ledger read (flag), the signal sooner", int(r.counters["closed"]) == 2 and str(r.flags.get("ledger")) == "found"
		and _said(r, "t_ledger") and float(r.clocks["signal"]) < sig0 - 60.0)
	_walk(g, g.clock + 2.0)
	check("d04 played (the crates opened): Tomasz reads Concórdia's name in the ledger", _said(r, "t_ledger_d04"))
	_walk(g, float(r.clocks["signal"]) + 0.5)
	check("THE SIGNAL: the night, the temper tallied (quiet: under 10)", r.fired.has("signal") and str(r.flags.get("minas")) == "quiet", str(r.flags))
	_walk(g, float(r.fired["signal"]) + 10.5)
	check("PART 2: the Foundry House open to blows, the rising's objectives", r.fired.has("part2") and not r.tagged("foundry")[0].spared
		and r.obj.get("rising", "") == "active" and r.obj.get("foundry", "") == "active")
	_walk(g, g.clock + 10.0)
	check("the bands from the Rosário and the diggings (muskets and miners)", r.fired.has("band_r") and r.fired.has("band_e")
		and r.tagged("rising").size() >= 12 and r.tagged("miners").size() >= 4, str(r.tagged("rising").size()))
	_put(g, r.tagged("tomasz"), _mid(r, "adro_rosario"))
	_walk(g, g.clock + 5.0)
	check("Tomasz in the Rosário's churchyard: the miners go home (they change side, no fight)", r.fired.has("miners_home")
		and _alive(r, "miners", "conspiracy").is_empty() and not _alive(r, "gone_home", "calmed").is_empty())
	_part2(g, r)
	check("the rising broken on the stairs", r.fired.has("rising_broken") and r.obj.get("rising", "") == "done")
	_walk(g, float(r.fired["rising_broken"]) + 15.5)
	check("PART 3 at dawn: four gold carts at the Foundry House, gold aboard, spared", r.fired.has("part3") and r.tagged("carts").size() == 4
		and r.cond({"loaded": {"tag": "carts", "cargo": "gold", "at_least": 4}}) and r.tagged("carts").all(func(c): return c.spared))
	check("... the ledges manned, Ramos on the road past the gorge, his capture asked", r.tagged("ledge_men").size() >= 7
		and r.tagged("ramos").size() == 1 and r.obj.get("ramos", "") == "active" and r.obj.get("ledges", "") == "active")
	for u in r.tagged("ledge_men"):
		u.die()
	_walk(g, g.clock + 3.0)
	check("the ledges cleared", r.obj.get("ledges", "") == "done")
	_walk(g, float(r.clocks["carts"]) + 1.0)
	check("the carts leave on the gold road", r.fired.has("cart_go"))
	var carts: Array = r.tagged("carts")
	_put(g, carts, _mid(r, "gorge_w"))
	_walk(g, g.clock + 1.0)
	check("THE AMBUSH: Ramos's men come for the carts", r.fired.has("ambush") and _said(r, "r_ambush"))
	# TAKE A CART: conspirators round a cart, no soldier of the Crown near
	for u in _team_units(g, r, "garrison"):
		if u.position.distance_to(_mid(r, "gorge_w")) < 12 * Defs.TILE:
			u.position = _mid(r, "camp")
	var c0: Unit = carts[0]
	c0.position = _mid(r, "road_mid")
	r._routes.clear()
	_put(g, r.tagged("takers").slice(0, 2), c0.position + Vector2(30, 0))
	g._rebuild_hash()
	_walk(g, g.clock + 6.0)
	check("TAKE A CART: the conspirators take a gold cart (gold and all)", c0.team == r.team_index("seized") and int(r.counters["carts_taken"]) >= 1)
	for u in r.tagged("takers"):
		u.die()
	_put(g, _team_units(g, r, "garrison", ["musketeer"]).slice(0, 3), c0.position + Vector2(-30, 0))
	_walk(g, g.clock + 5.0)
	check("... and the Crown's men round it take it back", c0.team == r.team_index("treasury") and int(r.counters["retaken"]) >= 1)
	# Ramos taken alive
	var ra: Unit = r.tagged("ramos")[0]
	ra.hp = ra.max_hp * 0.2
	_put(g, _team_units(g, r, "garrison", ["musketeer"]).slice(3, 4), ra.position + Vector2(20, 0))
	_walk(g, g.clock + 1.0)
	check("RAMOS TAKEN ALIVE (worn down, a man of the Crown beside him)", r.captured.has("ramos") and str(r.flags.get("conspirator")) == "taken")
	# the carts at the coast
	for c in r.tagged("carts"):
		if not c.dead:
			c.position = _mid(r, "coast")
	g._rebuild_hash()
	_walk(g, g.clock + 6.0)
	check("the gold at the coast: 4 of 4", int(r.counters["gold_out"]) == 4, str(r.counters["gold_out"]))
	_walk(g, g.clock + 8.0)
	check("the road done: the Crown wins", g.over and r.winner_side == "crown", r.winner_side)
	check("the flags: gold all, conspirator taken, minas quiet, ledger found", str(r.flags.get("gold")) == "all" and str(r.flags.get("conspirator")) == "taken"
		and str(r.flags.get("minas")) == "quiet" and str(r.flags.get("ledger")) == "found", str(r.flags))
	var ep := r.pages_now(Campaign.show_pages(r.data, "ending", "crown"))
	check("the ending has its pages (the King's for Ramos taken)", ep.size() == 2 and str(ep).contains("k_end1") and not str(ep).contains("k_end_fled"))
	check("the debrief fills its numbers", r.fill(String(r.data["debrief"]["crown"]["text"])).contains("4 of 4"))


# ================================================================== Ramos runs (fled); a cart taken over the ford

func _flee() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_part1(g, r)
	_part2(g, r)
	_walk(g, float(r.fired["rising_broken"]) + 15.5)
	_walk(g, float(r.clocks["carts"]) + 1.0)
	_put(g, r.tagged("carts"), _mid(r, "gorge_w"))
	_walk(g, g.clock + 1.0)
	for u in r.tagged("takers"):
		u.die()
	_walk(g, g.clock + 1.0)
	check("his takers down: Ramos runs for the hollow beyond the east ford", r.fired.has("ramos_run") and _said(r, "r_run"))
	_put(g, r.tagged("ramos"), _mid(r, "hollow"))
	_walk(g, g.clock + 2.0)
	check("over the ford: he is gone (conspirator fled), the capture failed", str(r.flags.get("conspirator")) == "fled" and r.obj.get("ramos", "") == "failed")
	# one cart taken off to the hollow, three to the coast
	var cs: Array = r.tagged("carts")
	var c0: Unit = cs[0]
	for u in _team_units(g, r, "garrison"):
		if u.position.distance_to(c0.position) < 12 * Defs.TILE:
			u.position = _mid(r, "camp")
	r.act({"spawn": {"team": "conspiracy", "kind": "musketeer", "as": "conspirator", "count": 2, "fixed": True, "at": "gorge_w", "tag": "x_takers"}})
	_put(g, r.tagged("x_takers"), c0.position + Vector2(30, 0))
	_walk(g, g.clock + 6.0)
	check("TAKE A CART: taken by the conspirators", c0.team == r.team_index("seized"))
	for u in r.tagged("x_takers"):
		u.die()
	c0.position = _mid(r, "hollow")
	for c in cs.slice(1):
		c.position = _mid(r, "coast")
	g._rebuild_hash()
	_walk(g, g.clock + 8.0)
	check("one cart's gold lost over the ford, three at the coast", int(r.counters["gold_lost"]) == 1 and int(r.counters["gold_out"]) == 3,
		str([r.counters["gold_lost"], r.counters["gold_out"]]))
	_walk(g, g.clock + 8.0)
	check("won with gold some, conspirator fled; the King's lines for the fled man", g.over and r.winner_side == "crown" and str(r.flags.get("gold")) == "some"
		and str(r.pages_now(Campaign.show_pages(r.data, "ending", "crown"))).contains("k_end_fled"))


# ================================================================== the defeats

func _defeats() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	r.act({"counter": {"name": "temper", "set": 20}})
	_walk(g, g.clock + 6.0)
	check("THE TOWN'S TEMPER at its top: Vila Rica rises, lost", g.over and r.winner_side != "crown" and r.obj.get("temper", "") == "failed", r.winner_side)
	_progress()
	g = await _start()
	r = g.mission
	_part1(g, r)
	_walk(g, float(r.fired["signal"]) + 11.0)
	r.tagged("foundry")[0].die()
	_walk(g, g.clock + 6.0)
	check("the Royal Foundry House burnt at night: lost", g.over and r.winner_side != "crown" and r.obj.get("foundry", "") == "failed")
	_progress()
	g = await _start()
	r = g.mission
	_part1(g, r)
	_part2(g, r)
	_walk(g, float(r.fired["rising_broken"]) + 15.5)
	_walk(g, float(r.clocks["carts"]) + 1.0)
	for c in r.tagged("carts"):
		c.die()
	_walk(g, g.clock + 4.0)
	check("no gold at the coast: lost", g.over and r.winner_side != "crown" and r.obj.get("gold", "") == "failed")


# ================================================================== versus: the conspiracy

func _versus() -> void:
	_progress()
	var g: Game = await _start("versus", true)
	var r := g.mission
	check("versus: the garrison is the host's (p1); the conspiracy is p2's, with Ramos and men in the Rosário",
		g.human == r.team_index("garrison") and r.tagged("ramos").size() == 1 and r.tagged("v_men").size() >= 4,
		str([g.human, r.team_index("garrison"), r.tagged("ramos").size(), r.tagged("v_men").size()]))
	r.act({"counter": {"name": "temper", "set": 20}})
	_walk(g, g.clock + 6.0)
	check("the conspiracy raises the town: the conspiracy wins", g.over and r.winner_side == "conspiracy", r.winner_side)
	var pages := r.pages_now(Campaign.show_pages(r.data, "ending", "conspiracy"))
	check("the conspiracy's ending: the King says that is not how it went", pages.size() == 2)


# ================================================================== save and load in the middle

func _snap(g: Game) -> Dictionary:
	var r := g.mission
	var tg := {}
	for t in r.tags:
		tg[t] = r.tagged(String(t)).size()
	return {"flags": r.flags, "counters": r.counters, "obj": r.obj, "tags": tg, "disguised": r.cond({"disguised": "armouries"}),
		"deny": r.deny.get(r.team_index("garrison"), {}).size(), "tech": g.has_tech(r.team_index("garrison"), "bayonet")}


func _save_load() -> void:
	_progress()
	MissionSave.clear_all(MID)
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 30.0)
	_calm(g, r, "pilar")
	g.players[r.team_index("garrison")]["tech"]["bayonet"] = true
	_walk(g, g.clock + 1.0)
	var before := _snap(g)
	main.mission_save_now()
	check("SAVE written in Part 1", MissionSave.has(MID, "save"))
	main.mission_load("save")
	await process_frame
	await process_frame
	paused = false
	var g2: Game = main.game
	if g2.hud:
		g2.hud.countdown = 0.0
	g2.mission._physics_process(MissionRun.TICK)
	var after := _snap(g2)
	var diff: Array = []
	for k in before:
		if JSON.stringify(before[k], "", true) != JSON.stringify(after[k], "", true):
			diff.append("%s: %s -> %s" % [k, before[k], after[k]])
	check("LOADED the same: flags, counters, objectives, tags, the armouries' disguise, the denied, the research", diff.is_empty(), "; ".join(diff))
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


# ================================================================== the hubs and the war map after d01

func _hubs() -> void:
	_progress()
	Campaign.record(MID, "solo", "crown", "crown", {"minas": "restless", "gold": "some", "conspirator": "fled", "ledger": "found"})
	var p := Campaign.progress()
	var sl := Campaign.storyline_of(MID)
	var kt: Dictionary = sl["hub"]["talks"]["king"]
	check("the hub: the King talks of Tomasz's letter from Minas, and the man who went south", str(CampaignMenu.talk_lines(kt, p)).contains("stayed behind with the miners")
		and str(CampaignMenu.talk_lines(kt, p)).contains("city of gears"))
	var tt: Dictionary = sl["hub"]["talks"]["tomasz"]
	check("the hub: the Cardinal remembers Minas", str(CampaignMenu.talk_lines(tt, p)).contains("Staying afterwards is the work"))
	var st: Dictionary = WarMapData.state(p)
	check("the war map: Minas uneasy (restless), the road south for the man who fled", st["regions"]["minas"] == "contested" and st["marks"]["ramos_road"])
	var led: Array = st.get("ledger", []).map(func(x): return String(x.get("text", "")))
	check("the war map's ledger: the rising broken, the gold some", led.has("The rising of the mines was broken at Vila Rica on the day of the tax.")
		and led.has("Some of the Foundry House's gold reached the coast; the gorge took the rest."), str(led.slice(-4)))
	check("the war map's data has no problem", WarMapData.problems().is_empty(), "; ".join(WarMapData.problems()))
