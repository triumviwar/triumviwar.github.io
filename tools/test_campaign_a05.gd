extends SceneTree
## Act 1's "The Specimens" (docs/campaign_a05_build.md):
##   - the data checks out, every text has pt and es, the Naturalist line lists it after a03 and a03's party win leads
##     to it, the seats for solo (either side) and versus, the map and the stills load;
##   - THE FLAGS READ at the start (b01_specimen: clutch saved / burned, saved few / some / many, pieter alive / lost,
##     eggs taken; a03_plateau: map drawn / withheld) and none at all (the canon);
##   - THE CAGE CART (the engine): a creature caged on a cart rides with it, can't be hurt or targeted, is freed when
##     the cart breaks, and leaves with the cart by an exit (as many as the canoes hold);
##   - THE EXPEDITION played through: the eggs, the netting and the carts, the nest asleep, the trail (the short way),
##     a raid, a cart broken, the landing, the Sire, the quay counted, the win, the flags kept and the ending; the long
##     way; the defeats (Lindqvist killed, nothing caged by dawn, every cage broken, the canoes gone);
##   - THE CREATURES (the solo side pick): the nest asleep and every new hunter with it, the workers awake, the roster
##     ladder's B3 (GROW, MATURE; no Tyrant Sire of their own), the scripted expedition, the win by half the cages freed
##     and by Lindqvist killed, the loss when the cages get away;
##   - THE DIFFICULTY: the dawn and the canoes' clocks and the pack's numbers on EASY and HARD, the player's side never
##     scaled;
##   - THE HUB and THE WAR MAP after it.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_a05.gd
## Prints CHECK lines, then "campaign_a05: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "a05_specimens"
const B01 := "b01_specimen"
const A03 := "a03_plateau"
const CANON := {"teles": "quiet", "clutch": "saved", "eggs": "left", "saved": "some", "saved_n": 15, "pieter": "lost",
	"turtle": "late", "rival": "standing"}
const A03_CANON := {"map": "drawn", "party": "some", "party_n": 4, "survey": "full", "linnea": "seen"}
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
	print("campaign_a05: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if b01 and a03 were won with these flags ({} the canon; null: neither in the progress).
func _progress(b01: Variant, a03: Variant = {}, diff := "normal") -> void:
	var p := {"reached": [MID], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if b01 is Dictionary:
		var f: Dictionary = CANON.duplicate()
		f.merge(b01, true)
		p["done"][B01] = {"won_by": "sire", "side": "sire", "flags": f}
	if a03 is Dictionary:
		var f3: Dictionary = A03_CANON.duplicate()
		f3.merge(a03, true)
		p["done"][A03] = {"won_by": "party", "side": "party", "flags": f3}
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
	return main.game


## The clock moved to `to` and one round of the mission's checks (as its 0.25 s tick does).
func _step(g: Game, to: float) -> void:
	g.clock = to
	var r := g.mission
	r._tick_turning()
	r._tick_exits()
	r._tick_carts()
	r._tick_held()
	r._tick_routes()
	r._tick_sleep()
	if not r.choice_open.is_empty() and g.clock >= float(r.choice_open.get("until", INF)):
		r.choose(String(r.choice_open["id"]), String(r.choice_open.get("default", "")))
	r._run_triggers()
	r._check_objectives()
	r._carry_cages()


func _walk(g: Game, to: float) -> void:
	var t := g.clock
	while t < to and not g.over:
		t = minf(to, t + 0.25)
		_step(g, t)


func _kill(r: MissionRun, tag: String) -> void:
	for e in r.tagged(tag):
		if e is Building:
			e.take_damage(1e9, null)
		else:
			e.die()


func _put(g: Game, us: Array, at: Rect2) -> void:
	var i := 0
	for u in us:
		u.position = at.get_center() + Vector2((i % 4) * 14 - 21, (i / 4) * 14 - 14)
		u.velocity = Vector2.ZERO
		i += 1
	g._rebuild_hash()


func _route_has(r: MissionRun, nm: String, wp: String) -> bool:
	for rt in r._routes:
		if String(rt["name"]) == nm and (rt["pts"] as Array).has(wp):
			return true
	return false


func _n(g: Game, t: int, kind: String) -> int:
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind == kind).size()


func _run() -> void:
	await process_frame
	_data()
	await _flags()
	await _cart()
	await _expedition_play()
	await _long_way()
	await _defeats()
	await _creatures_play()
	await _difficulty()
	await _hub()
	_finish()


# ================================================================== the data

func _data() -> void:
	var m := Campaign.mission(MID)
	var pr := Campaign.problems(m)
	check("a05_specimens: data checks out", pr.is_empty(), "; ".join(pr))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings():
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	for t in ["The Mother", "Young", "Cage cart", "The young Sire", "Dr. Lindqvist (the eggs)", "The Tyrant Sire"]:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(t)
	check("every text of the mission, the hubs and its names has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Naturalist line: b01, a03, then a05", String(sl.get("id", "")) == "naturalist" and (sl["missions"] as Array).slice(0, 3) == [B01, A03, MID])
	check("a03 won by the party leads to a05 (the nest's win does not)", Campaign.next_of(A03, "party") == MID and Campaign.next_of(A03, "nest") == "")
	check("a05 leads nowhere yet (a07 is not built)", Campaign.next_of(MID, "expedition") == "" and Campaign.next_of(MID, "creatures") == "")
	Campaign.save_progress({"reached": [], "done": {"p01_leaf": {}, B01: {"side": "sire", "flags": CANON}}})
	check("a05 is locked before a03", not Campaign.unlocked(MID))
	Campaign.record(A03, "solo", "party", "party", A03_CANON)
	check("...and open once a03 is won by the party", Campaign.unlocked(MID))
	check("solo sides: the expedition (default) and the creatures", Campaign.solo_sides(m) == ["expedition", "creatures"])
	var c := Campaign.make_cfg(MID, "solo")
	check("solo as the expedition: you; the convoy, the nest and the pack scripted", c["slots"].map(func(s): return s["who"]) == ["you", "script", "script", "script"])
	c = Campaign.make_cfg(MID, "solo", "p1", false, "creatures")
	check("solo as the creatures: you are green; the expedition scripted", c["slots"].map(func(s): return s["who"]) == ["script", "script", "you", "script"]
		and String(c["campaign"]["side"]) == "creatures")
	c = Campaign.make_cfg(MID, "versus", "p1", true)
	check("versus online: the friend is the creatures", c["slots"].map(func(s): return s["who"]) == ["you", "script", "remote", "script"])
	check("the expedition and its convoy YELLOW, the creatures GREEN", int(c["slots"][0]["colour"]) == 3 and int(c["slots"][1]["colour"]) == 3
		and int(c["slots"][2]["colour"]) == 2 and int(c["slots"][3]["colour"]) == 2)
	var md := Campaign.map_data("plateau_descent")
	check("the map is the plateau's descent, jungle, 128 x 150", String(m["map"]) == "campaign:plateau_descent" and String(md.get("biome", "")) == "jungle"
		and (md.get("size", []) as Array).map(func(x): return int(x)) == [128, 150])
	for k in m["stills"]:
		check("still %s: its picture loads" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	check("the opening and the ending per side", (m["opening"] as Dictionary).has("expedition") and (m["opening"] as Dictionary).has("creatures")
		and (m["ending"] as Dictionary).has("expedition") and (m["ending"] as Dictionary).has("creatures"))
	check("no creature speaks: the creatures' pages are the King's", (m["opening"]["creatures"] as Array).all(func(pg): return (pg["lines"] as Array).all(
		func(l): return String(m["lines"][l]["who"]) == "king")) and (m["ending"]["creatures"] as Array).all(func(pg): return (pg["lines"] as Array).all(
		func(l): return String(m["lines"][l]["who"]) == "king")))
	check("no line is said to the creatures but the NEW cards", (m["lines"] as Dictionary).values().all(func(l): return String(l.get("to", "")) != "creatures" or String(l["who"]) == "new"))
	check("NO CHOICE in this mission (the counts carry)", not JSON.stringify(m["triggers"]).contains("\"choice\""))
	var ros: Dictionary = m["teams"][2].get("roster", {})
	check("the creatures bound to the ladder's B3: GROW (stage2) and MATURE new; the Sire the story's deny", (ros.get("new", []) as Array) == ["stage2", "tyrant_challenger", "venom_challenger"]
		and (ros.get("deny", []) as Array) == ["tyrannosaur"])
	check("the expedition not bound (no production)", not (m["teams"][0] as Dictionary).has("roster"))


# ================================================================== the flags read at the start

func _flags() -> void:
	for which in ["canon", "none"]:
		if which == "canon":
			_progress({})
		else:
			_progress(null, null)
		var g := await _start()
		var r: MissionRun = g.mission
		var ct := r.team_index("creatures")
		_step(g, 0.5)
		_step(g, 1.0)
		var P := "flags %s: " % which
		check(P + "Lindqvist (320 health) and no Pieter", r.tagged("lindqvist").size() == 1 and is_equal_approx(r.tagged("lindqvist")[0].max_hp, 320.0)
			and r.tagged("pieter").is_empty())
		check(P + "a breeding stock: eight guns (the short way's two more), four porters", r.tagged("guns").size() == 8 and r.tagged("porters").size() == 4, str(r.tagged("guns").size()))
		check(P + "three cage carts (Powder Wagons that never blow up), on the convoy", r.tagged("carts").size() == 3
			and r.tagged("carts").all(func(u): return u.kind == "powder_wagon" and u.has_meta("cage_cart") and u.team == r.team_index("convoy")))
		check(P + "three young asleep in the ferns, a young Sire among them, spared", r.tagged("young").size() == 3
			and r.tagged("young_m").size() == 1 and r.tagged("young_m")[0].kind == "tyrannosaur"
			and is_equal_approx(float(r.tagged("young_m")[0].get_meta("role_scale", 0.0)), 0.55)
			and r.tagged("young").all(func(u): return u.spared and u.has_meta("mission_asleep")), str(r.tagged("young").size()))
		check(P + "the young counted (3)", int(r.counters["young0"]) == 3)
		check(P + "the egg bed: five eggs, caged and spared", r.tagged("egg_bed").size() == 5 and r.tagged("egg_bed").all(func(u): return u.kind == "brood_egg" and u.has_meta("mission_caged") and u.spared))
		check(P + "the nest: its Mother, spared; its hunters and grown ones asleep", r.tagged("mother").size() == 1 and r.tagged("mother")[0].spared
			and _n(g, ct, "raptor") == 7 and _n(g, ct, "tyrant_challenger") == 2 and _n(g, ct, "venom_challenger") == 1
			and r.tagged("nest_guard").all(func(u): return u.has_meta("mission_asleep")), "%d raptors" % _n(g, ct, "raptor"))
		check(P + "the canoes hold three cages (Nazaré's paddlers: some)", int(r.counters["room"]) == 3)
		check(P + "Benedito at the river, pinned and spared", r.tagged("benedito").size() == 1 and r.tagged("benedito")[0].m_pace == 0.0 and r.tagged("benedito")[0].spared)
		check(P + "dawn in 10:00", r.clocks.has("dawn") and is_equal_approx(float(r.clocks["dawn"]) - float(r.fired["start"]), 600.0))
		check(P + "night, a light mist", r.light_name == "jungle_night" and is_equal_approx(r.mist_sight, 0.75))
		check(P + "the expedition is yours", g.human == r.team_index("expedition"))
		_walk(g, 45.0)
		check(P + "the lines: the young Sire, the short way", r.said_ids.has("l_sire") and not r.said_ids.has("l_fresh"))
		check(P + "the mapmaker's road (drawn)", r.said_ids.has("l_short") and not r.said_ids.has("l_long"))
		check(P + "Pieter lost: Lindqvist keeps the book himself", r.said_ids.has("l_pieter") and not r.said_ids.has("p_book"))
	# ---- the clutch burned, the map withheld, saved few, Pieter alive, the eggs taken
	_progress({"clutch": "burned", "saved": "few", "pieter": "alive", "eggs": "taken"}, {"map": "withheld"})
	var g := await _start()
	var r: MissionRun = g.mission
	var ct := r.team_index("creatures")
	_step(g, 0.5)
	_walk(g, 45.0)
	check("burned: a fresh start: two carts, two young, no young Sire", r.tagged("carts").size() == 2 and r.tagged("young").size() == 2
		and r.tagged("young_m").is_empty() and int(r.counters["young0"]) == 2 and r.said_ids.has("l_fresh"))
	check("burned + withheld: four guns, two porters", r.tagged("guns").size() == 4 and r.tagged("porters").size() == 2, str(r.tagged("guns").size()))
	check("withheld: the long way", r.said_ids.has("l_long"))
	check("few saved: room for two cages", int(r.counters["room"]) == 2)
	check("Pieter alive: he keeps the specimen book", r.tagged("pieter").size() == 1 and r.said_ids.has("p_book"))
	check("eggs taken at the station: more young in the nest", _n(g, ct, "raptor") == 6 + 4 + 1 and r.said_ids.has("l_taken"))
	_progress({"saved": "many"})
	g = await _start()
	r = g.mission
	_step(g, 0.5)
	check("many saved: room for four cages", int(r.counters["room"]) == 4)


# ================================================================== the cage cart (the engine)

func _cart() -> void:
	_progress({})
	var g := await _start()
	var r: MissionRun = g.mission
	_step(g, 0.5)
	var cart: Unit = r.tagged("cart_w")[0]
	var y: Unit = r.tagged("young_w")[0]
	var mass := y.nb_mass
	_put(g, [cart], Rect2(y.position + Vector2(-20, -10), Vector2(10, 10)))
	r.act({"cart": {"tag": "young_w", "cart": "cart_w", "caged": "caged", "freed": "freed", "freed_tag": "freed"}})
	check("cart: the creature on it (caged, spared, harmless), the cart has its cargo", y.has_meta("on_cart") and y.has_meta("mission_caged") and y.spared
		and y.m_pace == 0.0 and y.m_unarmed and cart.get_meta("cage_cargo") == y and int(r.counters["caged"]) == 1)
	check("cart: the cage's bars drawn round it", y.get_node_or_null("CageBars") != null)
	check("cart: it shoves nobody", y.nb_mass < 0.01)
	check("cart: one creature a cart (a second goes to another)", r.cargo_count("carts") == 1)
	cart.position += Vector2(96, 64)
	r._carry_cages()
	check("cart: the creature rides with the cart", y.position.distance_to(cart.position) < 3.0)
	r.act({"spare": {"tag": "young", "on": false}})
	check("cart: lifting the young's spare leaves the caged one untouchable", y.spared)
	cart.die()
	_step(g, 1.0)
	check("cart: the cart broken frees it (on its feet, open to attack, counted, tagged)", not y.has_meta("on_cart") and not y.has_meta("mission_caged")
		and not y.spared and int(r.counters["freed"]) == 1 and r.tagged("freed").has(y) and is_equal_approx(y.nb_mass, mass)
		and y.get_node_or_null("CageBars") == null)
	check("cart: a cage cart never blows up (its powder stays)", r.tagged("young_e").all(func(u): return not u.dead) and r.tagged("lindqvist")[0].hp == r.tagged("lindqvist")[0].max_hp)
	# the exit: the canoes' room (3); a cart with no cage is never taken
	var c2: Unit = r.tagged("cart_m")[0]
	var c3: Unit = r.tagged("cart_e")[0]
	r.act({"cart": {"tag": "young_m", "cart": "cart_m"}})
	r.act({"cart": {"tag": "young_e", "cart": "cart_e"}})
	check("cart: each on its own cart", r.tagged("young_m")[0].get_meta("on_cart") == c2 and r.tagged("young_e")[0].get_meta("on_cart") == c3)
	r.counters["room"] = 1
	r.fired["part3"] = g.clock
	_put(g, [c2, c3], r.area_rect("quay"))
	r._carry_cages()
	r._tick_exits()
	check("cart: by the exit, as many as the canoes hold (1 of 2), the cage with the cart", int(r.counters["cages"]) == 1
		and r.tagged("carts").size() == 1 and r.tagged("young").filter(func(u): return u.has_meta("on_cart")).size() == 1, str(r.counters))
	r.counters["room"] = 3
	r._tick_exits()
	check("cart: room again: the other goes too", int(r.counters["cages"]) == 2 and r.tagged("carts").is_empty())


# ================================================================== the expedition, played through

## Part 1: the eggs, then each bed of young netted and caged (the carts brought to them for the test).
func _taking(g: Game, r: MissionRun, P: String, beds: Array) -> void:
	_step(g, 2.0)
	check(P + "the intro", r.said_ids.has("l_1") and r.said_ids.has("tip_1"))
	check(P + "THE TAKING's objectives; the trail hidden", r.obj["take"] == "active" and r.obj["eggs"] == "active" and r.obj["trail"] == "hidden")
	var lq: Unit = r.tagged("lindqvist")[0]
	var speed0 := lq.m_pace
	_put(g, [lq], r.area_rect("egg_bed"))
	var t := g.clock
	_walk(g, t + 6.0)
	check(P + "the eggs: not yet after 6 s", not r.fired.has("eggs_taken"))
	_walk(g, t + 9.0)
	check(P + "THE EGGS TAKEN (8 s): off the ground, Lindqvist carries them (slow, unarmed)", r.fired.has("eggs_taken") and r.tagged("egg_bed").is_empty()
		and lq.m_pace < speed0 and lq.m_unarmed and r.flags.get("eggs", "") == "taken" and r.obj["eggs"] == "done")
	check(P + "the nest still asleep", r.cond({"asleep": "nest"}))
	_put(g, [lq], r.area_rect("camp"))
	for w in beds:
		var men: Array = r.tagged("guns").slice(0, 2)
		_put(g, men, r.area_rect("young_" + w))
		_walk(g, g.clock + 5.0)
		check(P + "bed %s: netted (the men 4 s by it), its cart sent" % w, r.fired.has("net_" + w) and r.said_ids.has("l_net_" + w))
		_put(g, r.tagged("cart_" + w), Rect2(r.tagged("young_" + w)[0].position + Vector2(-30, -6), Vector2(4, 4)))
		_step(g, g.clock + 0.5)
		check(P + "bed %s: CAGED on its cart" % w, r.fired.has("load_" + w) and r.tagged("young_" + w)[0].has_meta("on_cart"))
		_put(g, men, r.area_rect("camp"))


func _expedition_play() -> void:
	# ---- run S: the canon (the clutch saved, the map drawn: the short way)
	_progress({})
	var g := await _start()
	var r: MissionRun = g.mission
	var ct := r.team_index("creatures")
	var P := "expedition S: "
	await _taking(g, r, P, ["w", "m", "e"])
	check(P + "three caged", int(r.counters["caged"]) == 3 and r.objective_text(r.objective("take")).contains("3 of 3"))
	_walk(g, g.clock + 4.0)
	check(P + "PART 2: every young caged: the nest wakes, the carts set off by the short way", r.fired.has("part2") and r.fired.has("part2_go")
		and r.cond({"awake": "nest"}) and r.flags.get("way", "") == "short" and _route_has(r, "trail", "s3"))
	check(P + "the trail's objective, dawn's clock stopped, the mist gone", r.obj["take"] == "done" and r.obj["trail"] == "active"
		and not r.clocks.has("dawn") and is_equal_approx(r.mist_sight, 1.0))
	check(P + "three cages on the road", int(r.counters["cages0"]) == 3 and r.cargo_count("carts") == 3)
	check(P + "the carts slow (an ox's pace)", r.tagged("carts").all(func(u): return u.m_pace < 0.6))
	check(P + "the hunters awake", r.tagged("nest_guard").all(func(u): return not u.has_meta("mission_asleep") and u.m_pace > 0.0))
	check(P + "the caged ones still caged after the wake", r.tagged("young").all(func(u): return u.has_meta("on_cart") and u.m_pace == 0.0 and u.spared))
	var t0 := float(r.fired["part2_go"])
	_walk(g, t0 + 52.0)
	check(P + "THE FIRST RAID (at 0:50): four Raptors from the trees, hunting the carts", r.fired.has("raid1") and r.tagged("raiders").size() == 4
		and r.tagged("raiders").all(func(u): return u.team == r.team_index("pack")) and r.said_ids.has("l_raid1"))
	_walk(g, t0 + 162.0)
	check(P + "the second raid brings a grown one (a Tyrant Challenger)", r.fired.has("raid2") and r.tagged("raiders").any(func(u): return u.kind == "tyrant_challenger")
		and r.said_ids.has("l_grown"))
	# a cart broken on the trail: its creature free, and on the men
	var c_e: Unit = r.tagged("cart_e")[0]
	var y_e: Unit = r.tagged("young_e")[0]
	c_e.die()
	_walk(g, g.clock + 4.0)
	check(P + "a cart broken: its creature FREE (counted), Lindqvist's line", int(r.counters["freed"]) == 1 and not y_e.has_meta("on_cart")
		and r.said_ids.has("l_freed") and r.fired.has("freed_hunt"))
	# PART 3: a cart at the river
	var c_w: Unit = r.tagged("cart_w")[0]
	_put(g, [c_w], r.area_rect("landing_near"))
	_step(g, g.clock + 0.5)
	check(P + "PART 3: the landing, the canoes' countdown (3:00), the crates", r.fired.has("part3") and r.obj["landing"] == "active"
		and is_equal_approx(float(r.clocks["canoes"]) - float(r.fired["part3"]), 180.0) and r.said_ids.has("b_crates"))
	_walk(g, g.clock + 21.0)
	check(P + "THE TYRANT SIRE comes down for the last cart", r.tagged("sire").size() == 1 and r.tagged("sire")[0].kind == "tyrannosaur"
		and r.tagged("sire")[0].team == ct and r.said_ids.has("l_sire_comes"))
	_put(g, r.tagged("carts"), r.area_rect("quay"))
	_step(g, g.clock + 0.5)
	check(P + "the carts on the quay loaded, cage and all (2)", int(r.counters["cages"]) == 2 and r.tagged("carts").is_empty()
		and r.said_ids.has("b_load"))
	_put(g, r.tagged("lindqvist"), r.area_rect("quay"))
	_walk(g, g.clock + 3.0)
	check(P + "Lindqvist last: the end, SOME (2 of 3)", r.fired.has("the_end") and r.flags.get("cages", "") == "some" and int(r.flags.get("cages_n", 0)) == 2)
	_walk(g, g.clock + 6.0)
	check(P + "THE EXPEDITION WINS", g.over and r.winner_side == "expedition")
	check(P + "the flags: eggs taken, Pieter lost, the short way, the crates seen", r.flags.get("eggs", "") == "taken" and r.flags.get("pieter", "") == "lost"
		and r.flags.get("way", "") == "short" and r.flags.get("crates", "") == "seen")
	await create_timer(1.8).timeout
	var show: StillShow = null
	for n in main.ui_layer.get_children():
		if n is StillShow:
			show = n
	check(P + "the expedition's ending plays", show != null)
	if show:
		for i in 20:
			if is_instance_valid(show) and not show.is_queued_for_deletion():
				show.next()
		check(P + "the ending's lines by the flags", show.shown_ids == ["l_end_some", "l_end_eggs", "l_end_saved", "k_end1", "k_end2"], str(show.shown_ids))
	var p := Campaign.progress()
	check(P + "it counts: done, by the expedition, the flags kept", (p["done"] as Dictionary).has(MID) and String(p["done"][MID]["side"]) == "expedition"
		and Campaign.flag(MID, "cages") == "some" and int(Campaign.flag(MID, "cages_n")) == 2)
	# ---- run A: every cage down (all), Pieter alive
	_progress({"pieter": "alive"})
	g = await _start()
	r = g.mission
	P = "expedition A: "
	await _taking(g, r, P, ["w", "m", "e"])
	_walk(g, g.clock + 4.0)
	_put(g, [r.tagged("cart_w")[0]], r.area_rect("landing_near"))
	_step(g, g.clock + 0.5)
	_put(g, r.tagged("carts"), r.area_rect("quay"))
	_step(g, g.clock + 0.5)
	_put(g, r.tagged("lindqvist"), r.area_rect("quay"))
	_walk(g, g.clock + 3.0)
	check(P + "every cage down: ALL (3 of 3), Pieter counted them", r.flags.get("cages", "") == "all" and int(r.flags.get("cages_n", 0)) == 3
		and r.flags.get("pieter", "") == "alive" and r.said_ids.has("p_count"))
	_walk(g, g.clock + 6.0)
	check(P + "...the win", g.over and r.winner_side == "expedition")
	await create_timer(1.8).timeout
	# ---- run F: the canoes full (few paddlers): the third cart stays on the quay
	_progress({"saved": "few"})
	g = await _start()
	r = g.mission
	P = "expedition F: "
	await _taking(g, r, P, ["w", "m", "e"])
	_walk(g, g.clock + 4.0)
	_put(g, [r.tagged("cart_w")[0]], r.area_rect("landing_near"))
	_step(g, g.clock + 0.5)
	_put(g, r.tagged("carts"), r.area_rect("quay"))
	_walk(g, g.clock + 13.0)
	check(P + "room for two: two loaded, one cart left on the quay, Benedito: full", int(r.counters["cages"]) == 2 and r.tagged("carts").size() == 1
		and r.said_ids.has("b_full") and r.said_ids.has("b_room_few"))
	_put(g, r.tagged("lindqvist"), r.area_rect("quay"))
	_walk(g, g.clock + 3.0)
	check(P + "the canoes full: the end, SOME (2 of 3)", r.fired.has("the_end") and r.flags.get("cages", "") == "some")
	_walk(g, g.clock + 6.0)
	await create_timer(1.8).timeout


func _long_way() -> void:
	_progress({"clutch": "burned"}, {"map": "withheld"})
	var g := await _start()
	var r: MissionRun = g.mission
	var P := "long way: "
	await _taking(g, r, P, ["w", "e"])
	_walk(g, g.clock + 4.0)
	check(P + "two caged: the carts go by the long way (west along the top, the forest)", r.flags.get("way", "") == "long"
		and _route_has(r, "trail", "long_top") and _route_has(r, "trail", "l5"))
	var t0 := float(r.fired["part2_go"])
	_walk(g, t0 + 52.0)
	check(P + "the pack waits along the long way", r.tagged("raiders").size() == 4 and r.tagged("raiders").all(func(u): return r.area_rect("rl_a").grow(96).has_point(u.position)))
	# woken early: Part 2 with what was caged (here: nothing yet in a fresh run)
	_progress({})
	g = await _start()
	r = g.mission
	_step(g, 2.0)
	var men: Array = r.tagged("guns").slice(0, 2)
	_put(g, men, r.area_rect("young_w"))
	_walk(g, g.clock + 5.0)
	_put(g, r.tagged("cart_w"), Rect2(r.tagged("young_w")[0].position + Vector2(-30, -6), Vector2(4, 4)))
	_step(g, g.clock + 0.5)
	_put(g, r.tagged("guns"), r.area_rect("nest_core"))
	_walk(g, g.clock + 4.0)
	check("woken early: the nest awake, walk softly failed, the carts go with one cage", r.cond({"awake": "nest"}) and r.obj["softly"] == "failed"
		and r.fired.has("part2_go") and int(r.counters["cages0"]) == 1 and r.said_ids.has("l_woke"), "%s %s %s" % [r.obj, r.counters, r.said_ids])
	check("woken early: the empty carts stay on the mountain", r.tagged("carts").size() == 1 and r.flags.get("eggs", "") == "left" and r.obj["eggs"] == "failed")


# ================================================================== the defeats

func _defeats() -> void:
	_progress({})
	var g := await _start()
	var r: MissionRun = g.mission
	_step(g, 2.0)
	_kill(r, "lindqvist")
	_step(g, 3.0)
	check("Lindqvist killed: a loss", g.over and r.winner_side == "creatures" and r.obj["lindqvist"] == "failed")
	await create_timer(1.8).timeout
	check("...it does not count", not (Campaign.progress()["done"] as Dictionary).has(MID))
	# dawn with nothing caged (the passive player)
	_progress({})
	g = await _start()
	r = g.mission
	_step(g, 2.0)
	_walk(g, 607.0)
	check("DAWN with nothing caged: the nest wakes, a loss", g.over and r.winner_side == "creatures" and r.obj["take"] == "failed" and r.said_ids.has("l_empty"), "%s %s %s" % [g.over, r.winner_side, r.obj])
	await create_timer(1.8).timeout
	# every cage broken
	g = await _start()
	r = g.mission
	await _taking(g, r, "all broken: ", ["w", "m", "e"])
	_walk(g, g.clock + 4.0)
	_kill(r, "carts")
	_walk(g, g.clock + 3.0)
	check("every cage broken: three freed, a loss", g.over and r.winner_side == "creatures" and int(r.counters["freed"]) == 3 and r.obj["trail"] == "failed"
		and r.said_ids.has("l_lost"))
	await create_timer(1.8).timeout
	# the canoes gone without Lindqvist
	g = await _start()
	r = g.mission
	await _taking(g, r, "canoes run: ", ["w", "m", "e"])
	_walk(g, g.clock + 4.0)
	_put(g, [r.tagged("cart_w")[0]], r.area_rect("landing_near"))
	_step(g, g.clock + 0.5)
	_step(g, float(r.clocks["canoes"]) + 0.5)
	check("the canoes gone without Lindqvist: a loss", g.over and r.winner_side == "creatures" and r.obj["landing"] == "failed" and r.said_ids.has("b_gone"))
	await create_timer(1.8).timeout


# ================================================================== the creatures (the solo side pick)

func _creatures_play() -> void:
	_progress({})
	var g := await _start("creatures")
	var r: MissionRun = g.mission
	var ct := r.team_index("creatures")
	check("creatures: you lead the green team", g.human == ct and r.solo_side == "creatures")
	_step(g, 0.5)
	_step(g, 1.5)
	check("creatures: your objectives, the hunt still hidden", r.obj["c_mother"] == "active" and r.obj["c_sleep"] == "active" and r.obj["c_free"] == "hidden")
	check("creatures: no expedition lines shown", not r.said_ids.has("l_1"))
	check("creatures: your hunters asleep, the workers awake", r.tagged("nest_guard").all(func(u): return u.has_meta("mission_asleep"))
		and g.units.filter(func(u): return not u.dead and u.team == ct and u.kind in ["grub", "brood_mother", "rootmaw"]).all(func(u): return not u.has_meta("mission_asleep")))
	check("creatures: the Mother not spared (yours to lose)", not r.tagged("mother")[0].spared)
	check("creatures: B3: GROW (stage 2) and MATURE open; stage 3 and a Tyrant Sire not", not r.denied(ct, "stage2") and not r.denied(ct, "tyrant_challenger")
		and not r.denied(ct, "venom_challenger") and r.denied(ct, "stage3") and r.denied(ct, "tyrannosaur"))
	var q: Unit = r.tagged("mother")[0]
	check("creatures: GROW is not refused by the mission", not BroodNew.grow_problem(g, q).contains("mission"), BroodNew.grow_problem(g, q))
	var nu: Unit = g._add_unit("raptor", ct, r.area_rect("nest_core").get_center())
	_step(g, 2.0)
	check("creatures: a new hunter falls asleep with the rest", nu.has_meta("mission_asleep") and nu.m_pace == 0.0)
	_step(g, 3.5)
	check("creatures: the expedition goes for the eggs by itself (a route), its men following", r._routes.any(func(rt): return String(rt["name"]) == "x1"))
	# the scripted expedition: the eggs, then each bed (moved there for the test)
	_put(g, r.tagged("lindqvist"), r.area_rect("egg_bed"))
	_walk(g, g.clock + 9.0)
	check("creatures: the doctor took the eggs", r.fired.has("eggs_taken") and r.tagged("egg_bed").is_empty())
	_walk(g, g.clock + 2.0)
	check("creatures: ...and goes on to the first bed", r._routes.any(func(rt): return String(rt["name"]) == "x2"))
	for w in ["w", "m", "e"]:
		_put(g, r.tagged("lindqvist") + r.tagged("guns").slice(0, 2), r.area_rect("young_" + w))
		_walk(g, g.clock + 5.0)
		_put(g, r.tagged("cart_" + w), Rect2(r.tagged("young_" + w)[0].position + Vector2(-30, -6), Vector2(4, 4)))
		_walk(g, g.clock + 1.5)
	check("creatures: your young caged on the carts (3)", int(r.counters["caged"]) == 3)
	var caged: Unit = r.tagged("young_w")[0]
	check("creatures: a caged young can't MATURE", BroodMature.problem(caged) == "It is caged.")
	_walk(g, g.clock + 4.0)
	check("creatures: THE HUNT: the carts set off, your nest awake, the objective", r.fired.has("part2_go") and r.obj["c_sleep"] == "done" and r.obj["c_free"] == "active"
		and nu.m_pace > 0.0 and not nu.has_meta("mission_asleep"))
	_walk(g, g.clock + 3.0)
	check("creatures: the doctor follows the carts", r._follows.any(func(f): return (f["units"] as Array).has(r.tagged("lindqvist")[0])))
	check("creatures: no scripted raids (the hunt is yours)", r.tagged("raiders").is_empty())
	# one cart broken: one of three, not yet half
	r.tagged("cart_w")[0].die()
	_walk(g, g.clock + 1.5)
	check("creatures: one freed: yours again, not yet half", int(r.counters["freed"]) == 1 and caged.team == ct and not caged.spared and not g.over)
	r.tagged("cart_m")[0].die()
	_walk(g, g.clock + 1.5)
	check("creatures: HALF THE CAGES FREED (2 of 3): you win", g.over and r.winner_side == "creatures" and r.obj["c_free"] == "done", str(r.counters))
	await create_timer(1.8).timeout
	var p := Campaign.progress()
	check("creatures: it counts for the creatures' player", (p["done"] as Dictionary).has(MID) and String(p["done"][MID]["side"]) == "creatures"
		and Campaign.flag(MID, "specimens") == "freed")
	# the doctor killed wins too
	_progress({})
	g = await _start("creatures")
	r = g.mission
	_step(g, 2.0)
	_kill(r, "lindqvist")
	_step(g, 3.0)
	check("creatures: the doctor killed wins too", g.over and r.winner_side == "creatures")
	await create_timer(1.8).timeout
	# the cages get away: the creatures lose
	_progress({})
	g = await _start("creatures")
	r = g.mission
	_step(g, 2.0)
	_put(g, r.tagged("lindqvist"), r.area_rect("egg_bed"))
	_walk(g, g.clock + 9.0)
	for w in ["w", "m", "e"]:
		_put(g, r.tagged("lindqvist") + r.tagged("guns").slice(0, 2), r.area_rect("young_" + w))
		_walk(g, g.clock + 5.0)
		_put(g, r.tagged("cart_" + w), Rect2(r.tagged("young_" + w)[0].position + Vector2(-30, -6), Vector2(4, 4)))
		_walk(g, g.clock + 1.5)
	_walk(g, g.clock + 4.0)
	_put(g, [r.tagged("cart_w")[0]], r.area_rect("landing_near"))
	_step(g, g.clock + 0.5)
	_put(g, r.tagged("carts"), r.area_rect("quay"))
	_step(g, g.clock + 0.5)
	_put(g, r.tagged("lindqvist"), r.area_rect("quay"))
	_walk(g, g.clock + 3.0)
	check("creatures: the cages away: the hunt failed", r.fired.has("the_end") and r.obj["c_free"] == "failed")
	_walk(g, g.clock + 6.0)
	check("creatures: ...the expedition wins, the loss does not count", g.over and r.winner_side == "expedition" and not (Campaign.progress()["done"] as Dictionary).has(MID))
	await create_timer(1.8).timeout


# ================================================================== the difficulty

func _difficulty() -> void:
	for d in [["easy", 3, 750.0, 225.0], ["hard", 5, 540.0, 162.0]]:
		_progress({}, {}, d[0])
		var g := await _start()
		var r: MissionRun = g.mission
		var ct := r.team_index("creatures")
		_step(g, 0.5)
		check("%s: dawn in %s" % [d[0], d[2]], is_equal_approx(float(r.clocks["dawn"]) - float(r.fired["start"]), float(d[2])), str(r.clocks["dawn"]))
		check("%s: the expedition never scaled (8 guns)" % d[0], r.tagged("guns").size() == 8)
		check("%s: the young never scaled (3)" % d[0], r.tagged("young").size() == 3)
		await _taking(g, r, "%s: " % d[0], ["w", "m", "e"])
		_walk(g, g.clock + 4.0)
		_walk(g, float(r.fired["part2_go"]) + 52.0)
		check("%s: the first raid scaled (%d Raptors)" % [d[0], d[1]], r.tagged("raiders").size() == int(d[1]), str(r.tagged("raiders").size()))
		_put(g, [r.tagged("cart_w")[0]], r.area_rect("landing_near"))
		_step(g, g.clock + 0.5)
		check("%s: the canoes' countdown %s" % [d[0], d[3]], is_equal_approx(float(r.clocks["canoes"]) - float(r.fired["part3"]), float(d[3])))
		g = await _start("creatures")
		r = g.mission
		_step(g, 0.5)
		check("%s, as the creatures: your own hunters never scaled (6 Raptors)" % d[0], r.tagged("nest_guard").filter(func(u): return u.kind == "raptor").size() == 6)
		check("%s, as the creatures: the expedition's guns scaled" % d[0], r.tagged("guns").size() == (7 if d[0] == "easy" else 9), str(r.tagged("guns").size()))
	Campaign.set_difficulty("normal")


# ================================================================== the hub and the war map

func _hub() -> void:
	main._to_menu()
	await process_frame
	var sl := Campaign.storyline_of(MID)
	var hub: Dictionary = sl["hub"]
	var prog := {"done": {B01: {"side": "sire"}, A03: {"side": "party", "flags": A03_CANON}, MID: {"side": "expedition", "flags": {"cages": "all", "cages_n": 3}}}}
	var after := CampaignMenu.hub_now(hub, prog)
	check("hub after a05: the warehouse with the cages", String(after["title"]) == "The Warehouse at the Barra" and String(after["about"]).contains("cages"))
	var lq: Dictionary = hub["talks"]["lindqvist"]
	check("Lindqvist after a05: the cages in the cellar", String(CampaignMenu.talk_lines(lq, prog)[0]).contains("cages"))
	prog["done"][MID] = {"side": "expedition", "flags": {"cages": "few", "cages_n": 1}}
	check("Lindqvist after a05, few: few is enough", CampaignMenu.talk_lines(lq, prog).any(func(l): return String(l).contains("Few is enough")))
	prog["done"][MID] = {"side": "creatures", "flags": {"specimens": "freed"}}
	check("Lindqvist after a05 won by the creatures: the carts came down empty", String(CampaignMenu.talk_lines(lq, prog)[0]).contains("empty"))
	check("the egg and the specimen jar in the hub after a05", (hub["hotspots"] as Array).filter(func(h): return String(h.get("requires", "")) == MID).size() == 2)
	# the war map
	var st := WarMapData.state({"reached": [], "done": {"p01_leaf": {"won_by": "crown"}, B01: {"won_by": "sire", "side": "sire", "flags": CANON}}})
	check("war map: a05's pin locked until a03", st["pins"][MID]["state"] == "locked")
	st = WarMapData.state({"reached": [MID], "done": {"p01_leaf": {"won_by": "crown"}, B01: {"won_by": "sire", "flags": CANON}, A03: {"won_by": "party", "flags": A03_CANON}}})
	check("war map: a05's pin open after a03", st["pins"][MID]["state"] == "open")
	st = WarMapData.state({"reached": [], "done": {"p01_leaf": {"won_by": "crown"}, B01: {"won_by": "sire", "flags": CANON}, A03: {"won_by": "party", "flags": A03_CANON},
		MID: {"won_by": "expedition", "side": "expedition", "flags": {"cages": "all", "cages_n": 3}}}})
	check("war map: a05 done, every cage counted in the ledger", st["pins"][MID]["state"] == "done" and st["pins"][MID]["seal"] == "seal"
		and (st["ledger"] as Array).any(func(e): return WarMapData.ledger_text(e).contains("breeding stock")))
	st = WarMapData.state({"reached": [], "done": {"p01_leaf": {"won_by": "crown"}, B01: {"won_by": "sire", "flags": CANON}, A03: {"won_by": "party", "flags": A03_CANON},
		MID: {"won_by": "creatures", "side": "creatures", "flags": {"specimens": "freed"}}}})
	check("war map: the creatures' win breaks the seal", st["pins"][MID]["seal"] == "broken")
