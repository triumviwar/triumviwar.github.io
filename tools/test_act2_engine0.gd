extends SceneTree
## ACT 2's ENGINE STEP 0 (act2-engine0, docs/act2_engine0.md): a copy of the engine's test mission (p01_revolt) with
## every new piece in it, kept in Campaign's cache only (never a file), played with the clock moved by hand:
## the data checks (good and bad), the VERSION (FRESH / GROWN), CARGO CARTS (load, an exit with the cargo, a cart
## broken: the cargo lost), TAKE A CART (guarded: no; left alone: taken, cargo and all), HIDDEN and FOUND (asleep: only
## close; awake: in sight; off the searchers' screen), TRACKS and the "track" order, THE LEASH (held, loose, held again,
## the ring of reach) and its BREAKING, a LURE POST that pulls a wave, BUILDINGS THAT CONVERT (marked, turned, stopped),
## THE SPREADING GROUND (the Brood's real swamp, the gear plates that wind), THE BRAKE, SAPPING (off the field, up at
## the end, the mine), a GRANARY (its own side, then the side that holds it), the IDLE METER, THE HEIR and the hub
## talk's CHOICE, the save keeping it all, the briefing saying the version.
##   godot --headless --fixed-fps 30 --script res://tools/test_act2_engine0.gd
## Prints CHECK lines, then "act2-engine0: N failures"; exit code 1 on a failure. Leaves user://campaign.json as it was.
var main: Node
var fails := 0
var _kept := ""
const ID := "x_act2"


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-66s %s %s" % [name, "ok" if ok else "FAIL", detail])
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
	print("act2-engine0: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The test mission: p01_revolt with a Brood "stock" (a third side), a Clockwork "works" team, carts, a granary,
## the version, take_carts, granaries, exits.
func mission() -> Dictionary:
	var m: Dictionary = Campaign.mission("p01_revolt").duplicate(true)
	m["id"] = ID
	m["sides"].append({"id": "wild", "name": "The Wild"})
	m["teams"].append({"id": "stock", "side": "wild", "faction": "brood", "colour": 2, "start": "none", "camera": "village",
		"control": {"solo": "script", "coop": "script", "versus": "script"}})
	m["teams"].append({"id": "works", "side": "rebels", "faction": "clockwork", "colour": 6, "start": "none", "camera": "ford",
		"control": {"solo": "script", "coop": "script", "versus": "script"}})
	m["triggers"] = []
	m.erase("wiped_out")
	m["objectives"] = [{"id": "x", "side": "crown", "primary": true, "kind": "manual", "text": "x"},
		{"id": "y", "side": "rebels", "primary": true, "kind": "manual", "text": "y"}]
	m["counters"] = {"out": {"start": 0}, "lost": {"start": 0}, "found_c": {"start": 0}, "turned_c": {"start": 0},
		"fed_c": {"start": 0}, "broke_c": {"start": 0}, "taken_c": {"start": 0}}
	for b in m["buildings"]:
		b["tags"] = ["quarter"]
	m["buildings"].append({"team": "rebels", "kind": "farm", "at": "village", "tag": "granary"})
	m["units"].append({"team": "column", "kind": "powder_wagon", "count": 3, "at": "ford", "tag": "carts", "as": "family_cart"})
	m["units"].append({"team": "stock", "kind": "raptor", "count": 3, "at": "village", "tag": "stock"})
	m["units"].append({"team": "works", "kind": "clock_soldier", "count": 2, "at": "ford", "tag": "machines"})
	m["units"].append({"team": "rebels", "kind": "musketeer", "count": 2, "at": "village", "tag": "grown_only", "if": {"version": "grown"}})
	m["units"].append({"team": "rebels", "kind": "musketeer", "count": 2, "at": "village", "tag": "fresh_only", "if": {"version": "fresh"}})
	m["versions"] = {"pick": [{"if": {"difficulty": "easy"}, "id": "fresh"}], "default": "grown",
		"labels": {"fresh": "FRESH: x", "grown": "GROWN: the city has grown while the army was away."}}
	m["take_carts"] = [{"tag": "carts", "by": "rebels", "secs": 3, "counter": "taken_c"}]
	m["granaries"] = [{"tag": "granary", "gold": 10, "every": 1, "hold_within": 3, "counter": "fed_c"}]
	m["exits"] = [{"area": "east_road", "tag": "carts", "cargo": true, "cargo_counter": "out"}]
	# every new action and condition once in a trigger that never fires (the data checks read them)
	m["triggers"].append({"id": "never", "when": {"all": [{"time": 99999}, {"loaded": {"tag": "carts", "at_least": 1}},
		{"taken": "carts"}, {"found": {"name": "pens"}}, {"loose": {"name": "stock"}}, {"broke": {"name": "stock"}},
		{"lured": "decoy"}, {"turned": {"name": "city"}}, {"ground": {"name": "bog", "at_least": 3}}, {"sapped": "mine"},
		{"fed": {"team": "rebels", "at_least": 1}}, {"version": "grown"}, {"heir": "unseen"}, {"hub_flag": {"q": "a"}}]},
		"do": [{"load": {"cart": "carts", "cargo": "families", "amount": 3, "lost": "lost"}}, {"unload": {"tag": "carts"}},
			{"hide": {"tag": "militia", "from": "crown"}}, {"tracks": {"tag": "stock", "for": "crown"}},
			{"leash": {"tag": "stock", "lure": "lure", "breaks": {"near": "queen", "to": "rebels"}}},
			{"lure_post": {"tag": "decoy", "at": "camp", "pull": {"tag": "ford_guard", "then": "east_road"}}},
			{"spread_convert": {"name": "city", "from": "rebel_hall", "tag": "quarter", "to": "works"}},
			{"ground": {"name": "bog", "at": "village", "kind": "swamp", "team": "stock"}}, {"brake": {"team": "works"}},
			{"sap": {"tag": "column_foot", "to": "village"}}, {"order": {"team": "horse", "do": "track"}}]})
	return m


func _cache(m: Dictionary) -> void:
	Campaign._cache["%s/missions/%s.json" % [Campaign.DIR, ID]] = m


func _data() -> void:
	var m := mission()
	_cache(m)
	var pr := Campaign.problems(m)
	check("data: the test mission's new keys check out", pr.is_empty(), "; ".join(pr))
	var bad: Dictionary = m.duplicate(true)
	bad["take_carts"] = [{"tag": "carts", "by": "nobody"}]
	bad["versions"] = {"pick": []}
	bad["triggers"].append({"id": "b", "when": {"all": [{"heir": "prince"}, {"version": "middle"}, {"fed": {"team": "nobody"}}]},
		"do": [{"leash": {"tag": "stock"}}, {"hide": {"tag": "militia"}}, {"ground": {"name": "g", "kind": "lava", "at": "camp"}},
			{"sap": {"tag": "x"}}, {"spread_convert": {"name": "c", "tag": "quarter"}}, {"tracks": {"tag": "stock"}},
			{"lure_post": {"at": "camp"}}, {"brake": {"faction": "elves"}}, {"order": {"tag": "x", "do": "sniff"}}]})
	var bp := Campaign.problems(bad)
	for want in ["take_carts", "versions: needs a default", "unknown heir", "version middle", "fed needs a known team",
			"a leash needs its lure", "hide needs the side", "ground: unknown kind", "sap needs", "spread_convert needs",
			"tracks need the side", "a lure post needs a tag", "brake: unknown faction", "unknown order sniff"]:
		check("data: problems() catches '%s'" % want, bp.any(func(x: String) -> bool: return x.contains(want)), "")
	check("data: the version's label is a campaign text (translations)", Campaign.strings_of(m).has("GROWN: the city has grown while the army was away."))
	check("version: picked before the match (normal: grown, easy: fresh)", MissionAct2.version_of(m, "crown", "normal") == "grown" and MissionAct2.version_of(m, "crown", "easy") == "fresh")
	check("heir: unseen by default (campaign.json)", Campaign.heir() == "unseen")
	check("heir: the static condition (before the match)", Campaign.cond_before({"heir": "unseen"}, "crown", "normal") and not Campaign.cond_before({"heir": "named"}, "crown", "normal"))


func _start() -> Game:
	_cache(mission())
	main.start(Campaign.make_cfg(ID, "solo"))
	await process_frame
	await process_frame
	return main.game


## The clock moved by hand and the mission's pieces ticked (the tree stays paused by the match's 3-2-1).
func _tick(g: Game, secs: float) -> void:
	var r: MissionRun = g.mission
	var t := 0.0
	while t < secs - 0.001:
		g.clock += 0.25
		r.a2.tick(0.25)
		r.a2.frame(0.25)
		r._tick_exits()
		r._tick_turning()
		r._run_triggers()
		t += 0.25


func _away(units: Array, where: Vector2) -> void:
	var i := 0
	for u in units:
		u.position = where + Vector2((i % 6) * 18, (i / 6) * 18)
		i += 1


func _match() -> void:
	var g: Game = await _start()
	var r: MissionRun = g.mission
	check("the run has Act 2's pieces", r != null and r.a2 != null and r.act2.has("loads"))
	# ------------------------------------------------------------ VERSIONS
	check("version: GROWN at NORMAL (the flag)", String(r.flags.get("version", "")) == "grown")
	check("version: the grown-only units came, the fresh-only didn't", r.tagged("grown_only").size() == 2 and r.tagged("fresh_only").is_empty())
	check("version: the condition", r.cond({"version": "grown"}) and not r.cond({"version": "fresh"}) and r.cond({"version": ["fresh", "grown"]}))
	check("heir: the condition in the match", r.cond({"heir": "unseen"}) and not r.cond({"heir": "named"}))
	# ------------------------------------------------------------ the scene, laid out by hand
	var far := r.area_rect("camp").position + Vector2(10, 10)
	var carts: Array = r.tagged("carts")
	check("cargo carts: three family carts at their walking pace", carts.size() == 3 and carts.all(func(c) -> bool: return is_equal_approx(c.speed, 58.0) and c.has_meta("cage_cart")))
	var ford := r.area_rect("ford").get_center()
	for i in 3:
		carts[i].position = ford + Vector2(i * 6 * Defs.TILE, 0)
	_away(r.tagged("column_foot") + r.tagged("captain"), far)
	_away(r.tagged("ford_guard"), r.area_rect("ford_west").position + Vector2(6, 6))
	_away(r.tagged("machines"), r.area_rect("east_road").position + Vector2(0, 200))
	for u in g.units:
		if u.team == r.team_index("column") and not r.tagged("carts").has(u):
			u.position = far + Vector2(0, 60)
		if u.team == r.team_index("horse"):
			u.position = far + Vector2(40, 90)
	g._rebuild_hash()
	# ------------------------------------------------------------ CARGO CARTS
	r.act({"load": {"cart": "carts", "cargo": "families", "amount": 3, "lost": "lost"}})
	check("cargo: three carts, three families each", r.cond({"loaded": {"tag": "carts", "at_least": 9}}) and r.a2.loaded_count("carts", "families") == 9)
	check("cargo: the cart says what it carries (meta)", carts.all(func(c) -> bool: return String(c.get_meta("cart_load", "")) == "families"))
	carts[0].position = r.area_rect("east_road").get_center()
	_tick(g, 0.25)
	check("cargo: a cart out by the exit takes its families (counted by the load)", int(r.counters["out"]) == 3 and r.a2.loaded_count("carts", "") == 6, str(r.counters["out"]))
	# ------------------------------------------------------------ TAKE A CART
	var c1: Unit = carts[1]
	var takers: Array = r.tagged("ford_guard").slice(0, 2)
	for i in takers.size():
		takers[i].position = c1.position + Vector2(20 + i * 10, 10)
	var guard: Unit = r.tagged("column_foot")[0]
	guard.position = c1.position + Vector2(-2 * Defs.TILE, 0)
	_tick(g, 2.0)
	check("take a cart: an armed friend by it: no taking", c1.team == r.team_index("column") and r.act2["takes"].is_empty())
	guard.position = far
	_tick(g, 1.5)
	check("take a cart: the bar fills while they stand round it", r.act2["takes"].size() == 1 and float(r.act2["takes"][0]["t"]) > 1.0 and c1.team == r.team_index("column"))
	_tick(g, 2.0)
	check("take a cart: TAKEN after its seconds (to the rebels)", c1.team == r.team_index("rebels") and r.cond({"taken": "carts"}) and int(r.counters["taken_c"]) == 1, str(c1.team))
	check("take a cart: its families went with it", r.a2.loaded_count("carts", "families") == 6)
	# the third cart broken: its families lost
	carts[2].take_damage(99999.0, null)
	_tick(g, 0.25)
	check("cargo: a cart broken, its families lost (counted)", int(r.counters["lost"]) == 3 and r.a2.loaded_count("carts", "") == 3, str(r.counters["lost"]))
	_away(takers, r.area_rect("ford_west").position + Vector2(6, 6))
	# ------------------------------------------------------------ HIDDEN and FOUND
	var mil: Array = r.tagged("militia")
	var vc := r.area_rect("village").get_center()
	for i in mil.size():
		mil[i].position = vc + Vector2(-10 * Defs.TILE + i * 7 * Defs.TILE, 4 * Defs.TILE)
	r.act({"sleep": {"tag": "militia", "name": "pens", "within": 0}})
	r.act({"hide": {"tag": "militia", "from": "crown", "within": 3, "name": "pens", "counter": "found_c"}})
	check("hidden: spared and marked", mil.all(func(u) -> bool: return u.spared and r.a2.is_hidden(u)))
	r.after_vis(g.human)
	check("hidden: off the searching side's screen", mil.all(func(u) -> bool: return not u.visible))
	var cap: Unit = r.tagged("captain")[0]
	cap.position = mil[0].position + Vector2(-5 * Defs.TILE, 0)
	_tick(g, 0.5)
	check("hidden: asleep, a searcher 5 tiles off sees nothing", not r.cond({"found": {"name": "pens"}}))
	cap.position = mil[0].position + Vector2(-2 * Defs.TILE, 0)
	_tick(g, 0.25)
	check("hidden: FOUND within 3 tiles (counted, open to attack)", r.cond({"found": {"name": "pens"}}) and int(r.counters["found_c"]) >= 1 and not mil[0].spared and not r.a2.is_hidden(mil[0]))
	var others := mil.filter(func(u) -> bool: return r.a2.is_hidden(u))
	check("hidden: the others still hidden", others.size() >= 1 and others.size() < mil.size(), str(others.size()))
	# an AWAKE one: found by a searcher's own sight
	var raptors: Array = r.tagged("stock")
	r.act({"hide": {"tag": "stock", "from": "crown", "name": "wild"}})
	var rp: Unit = raptors[0]
	cap.position = rp.position + Vector2((float(cap.sight) - 1.0) * Defs.TILE, 0)
	_tick(g, 0.25)
	check("hidden: awake, seen within a searcher's sight", r.cond({"found": {"name": "wild"}}), str(cap.sight))
	r.act({"hide": {"tag": "stock", "on": false}})
	check("hidden: hide off: not hidden, not counted found", raptors.all(func(u) -> bool: return not r.a2.is_hidden(u) and not u.spared) and int(r.act2["found"].get("wild", 0)) < raptors.size())
	cap.position = far
	# ------------------------------------------------------------ TRACKS
	r.act({"tracks": {"tag": "stock", "for": "rebels", "every": 0.5, "secs": 30}})
	for k in 4:
		for u in raptors:
			u.position += Vector2(Defs.TILE * 1.5, 0)
		_tick(g, 0.5)
	check("tracks: marks where they walked (for the rebels' eyes)", r.a2.track_marks().size() >= 6, str(r.a2.track_marks().size()))
	var hr: Array = r.tagged("ford_guard")
	hr[0].cmd_stop()
	hr[0].position = raptors[0].position + Vector2(-6 * Defs.TILE, 2 * Defs.TILE)
	r.act({"order": {"tag": "ford_guard", "do": "track", "within": 10}})
	check("tracks: a searcher sent after the freshest", hr[0].order == "move", hr[0].order)
	var mid := r.a2.track_marks().size()
	_tick(g, 31.0)
	check("tracks: they fade (gone after their seconds)", r.a2.track_marks().size() < mid)
	# ------------------------------------------------------------ THE LEASH
	var vil := r.area_rect("village").get_center()
	_away(raptors, vil)
	r.act({"lure_post": {"tag": "lure", "at": "village"}})
	r.act({"leash": {"tag": "stock", "lure": "lure", "within": 6, "name": "stock"}})
	_tick(g, 0.5)
	check("leash: under the lure: held (not loose)", not r.cond({"loose": {"name": "stock"}}))
	rp = raptors[0]
	rp.position = vil + Vector2(14 * Defs.TILE, 0)
	rp.cmd_stop()
	_tick(g, 0.5)
	check("leash: out of reach: LOOSE, off on its own", r.cond({"loose": "stock"}) and rp.has_meta("leash_loose") and rp.order == "move", rp.order)
	rp.position = vil + Vector2(2 * Defs.TILE, 0)
	_tick(g, 0.5)
	check("leash: back under the lure: held, waits to be told", not rp.has_meta("leash_loose") and not r.cond({"loose": "stock"}))
	# THE BREAKING
	var rl: Unit = r.tagged("ringleader")[0]
	r._tag("queen", rl)
	r.act({"leash": {"tag": "stock", "lure": "lure", "within": 6, "name": "stock", "breaks": {"near": "queen", "within": 3, "to": "rebels", "warn": 1, "counter": "broke_c"}}})
	raptors[0].position = vil + Vector2(-5 * Defs.TILE, 0)
	raptors[2].position = vil + Vector2(0, -5 * Defs.TILE)
	raptors[1].position = vil + Vector2(4 * Defs.TILE, 0)
	rl.position = raptors[1].position + Vector2(Defs.TILE, 0)
	_tick(g, 0.25)
	check("leash breaks: near her, the leash ends (counted)", r.cond({"broke": "stock"}) and int(r.counters["broke_c"]) == 1)
	_tick(g, 1.5)
	check("leash breaks: after its stars, it changed side for good", raptors[1].team == r.team_index("rebels"), str(raptors[1].team))
	check("leash breaks: no longer on the leash", not (r.act2["leashes"][0]["units"] as Array).has(raptors[1]))
	# ------------------------------------------------------------ A LURE POST that pulls a wave
	var fg: Array = r.tagged("ford_guard")
	for u in fg:
		u.cmd_stop()
	r.act({"lure_post": {"tag": "decoy", "at": "ford", "pull": {"tag": "ford_guard", "within": 30, "then": "east_road", "name": "decoyed"}}})
	check("lure post: the wave pulled once (lured, on a route)", r.cond({"lured": "decoy"}) and r._routes.any(func(x) -> bool: return String(x["name"]) == "decoyed") and fg.any(func(u) -> bool: return u.order == "move"))
	check("lure post: its spot is an area a route can use", r.data["areas"].has("lure:decoy"))
	r.act({"lure_post": {"tag": "decoy", "remove": true}})
	check("lure post: removed", not r.act2["posts"].any(func(p) -> bool: return String(p["tag"]) == "decoy"))
	# ------------------------------------------------------------ BUILDINGS THAT CONVERT
	var q: Array = r.tagged("quarter")
	r.act({"spread_convert": {"name": "city", "from": "rebel_hall", "tag": "quarter", "to": "works", "every": 1, "warn": 1, "counter": "turned_c"}})
	_tick(g, 1.0)
	var nx = r.act2["spreads"][0]["next"]
	check("convert: the next building marked (TURNING) before it turns", nx != null and q.has(nx) and nx.team == r.team_index("rebels"))
	_tick(g, 1.25)
	check("convert: it turned (its colour, the count)", nx.team == r.team_index("works") and r.cond({"turned": {"name": "city", "at_least": 1}}) and int(r.counters["turned_c"]) == 1)
	r.act({"spread_convert": {"name": "city", "stop": true}})
	_tick(g, 4.0)
	check("convert: stopped, no more turn", int(r.act2["turned"]["city"]) == 1)
	# ------------------------------------------------------------ THE SPREADING GROUND
	var st := r.team_index("stock")
	r.act({"ground": {"name": "bog", "at": "village", "kind": "swamp", "team": "stock", "r": 2, "step": 1, "every": 1, "max": 4}})
	g._update_swamp()
	var cells0 := (g.swamp[st] as PackedByteArray).count(1)
	check("ground: the Brood's own swamp laid (a mission source)", cells0 > 0, str(cells0))
	_tick(g, 2.5)
	g._update_swamp()
	var cells1 := (g.swamp[st] as PackedByteArray).count(1)
	check("ground: it spreads (bigger)", cells1 > cells0 and r.cond({"ground": {"name": "bog", "at_least": 4}}), "%d -> %d" % [cells0, cells1])
	check("ground: a creature on it", r.cond({"ground": {"name": "bog", "on": "stock"}}))
	var mach: Array = r.tagged("machines")
	for u in mach:
		u.wind = 0.1
	r.act({"ground": {"name": "plates", "from": "machines", "kind": "gear", "r": 3, "wind": 0.5}})
	_tick(g, 1.0)
	check("ground: gear plates wind the Clockwork on them", mach.all(func(u) -> bool: return u.wind > 0.5), str(mach.map(func(u): return u.wind)))
	# ------------------------------------------------------------ THE BRAKE
	r.act({"brake": {"team": "works", "name": "spring"}})
	check("brake: every machine of the team run down at once", mach.all(func(u) -> bool: return u.wind == 0.0 and r.a2.braked(u)))
	_tick(g, 1.0)
	check("brake: they stay run down (the plates can't wind them)", mach.all(func(u) -> bool: return u.wind == 0.0))
	r.act({"brake": {"name": "spring", "on": false}})
	_tick(g, 1.0)
	check("brake: let off, they wind again", mach.all(func(u) -> bool: return u.wind > 0.0 and not r.a2.braked(u)))
	# ------------------------------------------------------------ SAPPING
	var foot: Array = r.tagged("column_foot")
	var hall: Entity = r.tagged("rebel_hall")[0]
	var hp0: float = hall.hp
	r.act({"sap": {"tag": "column_foot", "to": "village", "secs": 2, "name": "mine", "blast": {"tag": "rebel_hall", "amount": 50, "within": 14}}})
	_tick(g, 1.0)
	check("sap: under the ground (off the field, half way)", foot.all(func(u) -> bool: return u.off_field) and not r.cond({"sapped": "mine"}))
	r.after_vis(r.team_index("rebels"))
	check("sap: unseen by the other side", foot.all(func(u) -> bool: return not u.visible))
	_tick(g, 1.25)
	check("sap: up at the end of the gallery", r.cond({"sapped": "mine"}) and foot.all(func(u) -> bool: return not u.off_field and u.position.distance_to(vil) < 3 * Defs.TILE))
	check("sap: the mine went off", hall.hp < hp0, "%.0f -> %.0f" % [hp0, hall.hp])
	# ------------------------------------------------------------ THE GRANARY
	var gran: Building = r.tagged("granary")[0]
	var rt := r.team_index("rebels")
	for u in g.units:
		if u.team != r.team_index("column"):
			u.position = Vector2(30, 30)
	_away(foot, far)
	var gold0 := int(g.players[rt]["gold"])
	_tick(g, 1.0)
	check("granary: it feeds its own side", int(g.players[rt]["gold"]) >= gold0 + 10 and r.cond({"fed": {"team": "rebels", "at_least": 10}}), "%d -> %d" % [gold0, int(g.players[rt]["gold"])])
	foot[0].position = gran.center() + Vector2(0, float(gran.size.y) * Defs.TILE * 0.5 + 10)
	var ct := r.team_index("column")
	var cg0 := int(g.players[ct]["gold"])
	_tick(g, 1.0)
	check("granary: held by the other side, it feeds them", int(g.players[ct]["gold"]) >= cg0 + 10 and r.cond({"fed": {"team": "column", "at_least": 10}}), "%d -> %d" % [cg0, int(g.players[ct]["gold"])])
	# ------------------------------------------------------------ the IDLE METER
	_away(foot, far)
	gran.take_damage(99999.0, null)       # (its counter would keep the player "busy")
	_tick(g, 12.0)
	var li := r.longest_idle()
	check("idle meter: a quiet stretch is measured", float(li["secs"]) >= 8.0, str(li))
	r.act({"counter": {"name": "out", "add": 1}})
	_tick(g, 0.25)
	check("idle meter: something happening ends the stretch", float(r.act2["idle"]["now"]) == 0.0)
	# ------------------------------------------------------------ the save keeps it
	check("save: Act 2's state is in the mission's save", MissionRun.SAVE_KEYS.has("act2") and r.save_state({}, {}).contains("\"leashes\""))
	check("not over in all this", not g.over)
	main._to_menu()
	await process_frame


func _hub() -> void:
	# THE FRAME AT THE CHOICE: a hub talk with buttons; the answer kept; the option's lines follow
	var box := PanelContainer.new()
	root.add_child(box)
	CampaignMenu._talk(box, {"name": "The King", "colour": 4}, ["What would you choose?"],
		{"flag": "frame_q", "options": [{"id": "brood", "label": "THE SWARM FIRST", "lines": ["So did Ruggieri."]},
			{"id": "clock", "label": "THE CITY FIRST", "lines": ["Ruggieri did not."]}]})
	await process_frame
	var nb: Button = box.find_child("TalkNext", true, false)
	var ch: Control = box.find_child("TalkChoice", true, false)
	check("hub choice: the question's buttons, no CLOSE", nb != null and not nb.visible and ch != null and ch.visible)
	var ob: Button = box.find_child("TalkOpt_clock", true, false)
	if ob:
		ob.pressed.emit()
	await process_frame
	var tt: Label = box.find_child("TalkText", true, false)
	check("hub choice: the answer kept (hub flag)", str(Campaign.hub_flag("frame_q")) == "clock")
	check("hub choice: the option's lines follow, then CLOSE", tt != null and tt.text == Loc.t("Ruggieri did not.") and nb.visible and not ch.visible, tt.text if tt else "")
	check("hub choice: the hub_flag condition", Campaign.cond_before({"hub_flag": {"frame_q": "clock"}}, "", "normal"))
	var tk := {"entries": [{"after": "", "lines": ["x"]}, {"after": "", "heir": "named", "lines": ["y"]},
		{"after": "", "hub_flag": {"frame_q": "brood"}, "lines": ["z"]}]}
	check("hub talk: an entry by the heir and by an answer", CampaignMenu.talk_lines(tk, Campaign.progress()) == ["x"])
	box.queue_free()
	# the briefing says the version plainly
	_cache(mission())
	CampaignMenu.briefing(main, ID)
	await process_frame
	var vl: Label = main.menu.find_child("Briefing_Version", true, false)
	check("briefing: the version said plainly", vl != null and vl.text.begins_with("GROWN"), vl.text if vl else "")


func _run() -> void:
	await process_frame
	_data()
	await _match()
	await _hub()
	_finish()
