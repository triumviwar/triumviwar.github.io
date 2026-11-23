extends SceneTree
## Act 2's "The Exodus" (docs/campaign_d02_build.md):
##   - the data checks out, every text has pt and es, the Clockmaker line lists it after the Council of Rome and it opens
##     only once a07 is won (`needs`), the seats (solo, the SOLO PICK of the commissary, versus), the map and the stills,
##     THE ROSTER LADDER's K4 for the guild (the Ratchet Turret and the Shield Wall, drilled from the start: a team's
##     "techs"), the hub's purse and reach (hubs-grow) for d02;
##   - THE FLAGS at the start: c01 `saved` (3 / 5 / 7 carts, missing = 5), `gate` (the drawings cart), `jakob` (c01, a02,
##     a04 lost: no Jakob), a02 `furth` fallen (the reclaim: the machine's seed in the works), a04 `broken` and
##     `lost_to_machine` (the column's guns, the sortie);
##   - PART 1: a man at a barn loads its cart, Hollweg loads the drawings, Jakob's word, the start of Part 2 once all is
##     done; a cart nobody loaded stays behind (counted);
##   - PART 2: the road, the riders, TAKE A CART (and taken back), von Rauch's minute (c01 `bells` rung), the machine's
##     sortie; PART 3: the travelling clock, the turret's site, the barges (families counted), the quiet bank, the last
##     barge and Hollweg aboard: the win and its flags (`exodus`, `drawings`, `jakob`), the ending and debrief;
##   - THE DEFEATS: nothing loaded; the last barge gone without Hollweg; the rearguard broken and Hollweg taken;
##   - THE MIRROR (the commissary): its column at Part 2, Hollweg taken alive (`hollweg` taken), its passive loss;
##   - SAVE AND LOAD in the middle (as test_campaign_save), IRONMAN (no SAVE in the menu), the HUBS and the WAR MAP after
##     d02.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_d02.gd
## Prints CHECK lines, then "campaign_d02: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
const MID := "d02_exodus"
const C01_DEF := {"bells": "quiet", "saved": "some", "jakob": "alive", "cut": "no", "gate": "pattern"}
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
	print("campaign_d02: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress as if c01, a02, a04 and a07 were won with these flags (each merged over its canon), at a difficulty.
## `a02w`: who won a02 ("machine": Fürth fell). `with_a07` false: a07 not finished.
func _progress(c01 := {}, a02 := {}, a04 := {}, diff := "normal", a02w := "guild", with_a07 := true) -> void:
	var p := {"reached": [MID], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	var f1: Dictionary = C01_DEF.duplicate()
	f1.merge(c01, true)
	p["done"]["c01_thirteenth"] = {"won_by": "guild", "side": "guild", "flags": f1}
	var f2 := {"stopwork": "fitted", "furth": "strong", "jakob": "alive"}
	f2.merge(a02, true)
	p["done"]["a02_furth"] = {"won_by": a02w, "side": a02w, "flags": f2}
	var f4 := {"broken": "kept", "lost_to_machine": 0, "stopworks": "found", "jakob": "alive"}
	f4.merge(a04, true)
	p["done"]["a04_visit"] = {"won_by": "visit", "side": "visit", "flags": f4}
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


func _guild_fighters(g: Game, r: MissionRun) -> Array:
	return _team_units(g, r, "guild", ["clock_soldier", "springer", "netter", "pendulum"])


## Part 1 by the script: a man at each barn with a cart, Hollweg at his barn (the drawings), then to Jakob.
func _part1(g: Game, r: MissionRun) -> void:
	var man: Unit = _team_units(g, r, "guild", ["winder"])[0]
	for i in 7:
		if r.tagged("cart_%d" % (i + 1)).is_empty():
			continue
		_put(g, [man], _mid(r, "barn_%d" % (i + 1)))
		_walk(g, g.clock + 3.5)
	_put(g, [man], _mid(r, "muster"))
	var hw: Unit = r.tagged("hollweg")[0]
	if not r.tagged("drawings_cart").is_empty():
		_put(g, [hw], _mid(r, "barn_1"))
		_walk(g, g.clock + 4.5)
	_put(g, [hw], _mid(r, "muster"))
	if not r.tagged("jakob").is_empty():
		_walk(g, maxf(g.clock, 53.0))
		_put(g, [hw], r.tagged("jakob")[0].position + Vector2(20, 0))
		_walk(g, g.clock + 1.0)


func _run() -> void:
	await process_frame
	_data()
	await _flags()
	await _play()
	await _take_and_minute()
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
	check("d02_exodus: data checks out", pr.is_empty(), "; ".join(pr))
	var extra := ["The spring cart", "The drawings cart", "Commissary Brandt", "Colonel von Rauch", "The travelling clock",
		"The Main", "February 2771", "The guild's ships, to Brazil"]
	for role in ["spring_cart", "drawings_cart", "brandt", "rauch"]:
		extra.append(String(Rebels.ROLES[role]["about"]))
	var miss: Array = []
	for t in Campaign.strings_of(m) + Campaign.index_strings() + extra:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every text of the mission, its roles and the hubs has pt and es", miss.is_empty(), " | ".join(miss))
	var sl := Campaign.storyline_of(MID)
	check("the Clockmaker line lists d02 after the Council of Rome", String(sl.get("id", "")) == "clockmaker"
		and (sl["missions"] as Array).find(MID) == (sl["missions"] as Array).find("a07_council") + 1)
	_progress({}, {}, {}, "normal", "guild", false)
	check("d02 is shut until the Council of Rome is won (needs a07)", not Campaign.unlocked(MID))
	_progress()
	check("... and open once it is", Campaign.unlocked(MID))
	check("the seats: solo the guild, the SOLO PICK the commissary", Campaign.solo_sides(m) == ["exodus", "commissary"])
	var c := Campaign.make_cfg(MID, "solo", "p1", false, "commissary")
	var you: Array = (c["slots"] as Array).filter(func(s): return String(s["who"]) == "you").map(func(s): return String(s["team_id"]))
	check("the commissary picked: the Crown's team is the player's", you == ["crown"], str(you))
	check("versus: the guild p1, the commissary p2", Campaign.seat_side(m, "versus", "p1") == "exodus" and Campaign.seat_side(m, "versus", "p2") == "commissary")
	check("the map is the snowy Fürth with the valley road", Campaign.map_data("furth_exodus").get("biome", "") == "snow")
	for k in m["stills"]:
		check("still %s is in" % k, ResourceLoader.exists(String(m["stills"][k]["image"])))
	var gt: Dictionary = (m["teams"] as Array).filter(func(t): return String(t["id"]) == "guild")[0]
	check("THE ROSTER LADDER K4: the guild may have the Ratchet Turret and the Shield Wall, both NEW",
		(gt["roster"]["allow"] as Array).has("ratchet_turret") and (gt["roster"]["new"] as Array) == ["ratchet_turret", "shield_wall"])
	check("hubs-grow: d02 earns GUILD MARKS and the guild's rooms reach it", (HubGrow.line("clockmaker")["earn"] as Array).has(MID)
		and HubGrow.line_for(MID) == "clockmaker" and HubGrow.line_for(MID, "commissary") == "")


# ================================================================== the flags at the start

func _flags() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	check("canon: 5 family carts (c01 saved some), the drawings cart, the spring cart", r.tagged("fcarts").size() == 5
		and r.tagged("drawings_cart").size() == 1 and r.tagged("spring_cart").size() == 1 and int(r.counters["carts_n"]) == 5)
	check("canon: Jakob is there", r.tagged("jakob").size() == 1)
	check("the guild's Clock Soldiers are drilled to SHIELD WALL (a team's techs: +10 health)",
		g.has_tech(r.team_index("guild"), "shield_wall") and _team_units(g, r, "guild", ["clock_soldier"])[0].max_hp >= 85.0)
	check("the spring cart's brass plates wind the guild (a gear ground that follows it)",
		(r.act2["grounds"] as Array).any(func(x): return String(x["name"]) == "spring" and String(x["kind"]) == "gear"))
	check("the works are left behind: a Winder may make nothing", g.mission.denied(r.team_index("guild"), "winder")
		and g.mission.denied(r.team_index("guild"), "clocktower"))
	check("the carts can be taken, not harmed (spared)", r.tagged("carts").all(func(c): return c.spared))
	check("no reclaim part when Fürth stood", r.obj.get("reclaim", "") == "hidden" and r.tagged("seed_works").is_empty())
	_progress({"saved": "few", "gate": "people"})
	g = await _start()
	r = g.mission
	check("c01 saved few: 3 carts; gate people: no drawings cart", r.tagged("fcarts").size() == 3 and r.tagged("drawings_cart").is_empty())
	_progress({"saved": "many", "jakob": "lost"})
	g = await _start()
	r = g.mission
	check("c01 saved many: 7 carts; Jakob lost at Nuremberg: no Jakob", r.tagged("fcarts").size() == 7 and r.tagged("jakob").is_empty()
		and str(r.flags.get("jakob")) == "lost")
	_progress({}, {}, {"jakob": "lost"})
	g = await _start()
	check("Jakob lost at a04: no Jakob", g.mission.tagged("jakob").is_empty())
	_progress({}, {"furth": "fallen"}, {}, "normal", "machine")
	g = await _start()
	r = g.mission
	check("a02 lost (Fürth fell): THE RECLAIM: the machine's seed in the works, its objective shown",
		r.tagged("seed_works").size() == 1 and r.obj.get("reclaim", "") == "active" and r.tagged("honest").is_empty())
	check("... and the riders come later", float(r.clocks.get("riders", 0.0)) - g.clock > 300.0)


# ================================================================== the play through

func _play() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, 9.0)
	check("the NEW card for K4 is said", _said(r, "new_ratchet_turret") and _said(r, "new_shield_wall"))
	var man: Unit = _team_units(g, r, "guild", ["winder"])[0]
	_put(g, [man], _mid(r, "barn_2"))
	_walk(g, g.clock + 3.5)
	check("a man at a barn a moment: the family climbs in (loaded 1)", int(r.counters["loaded"]) == 1 and r.fired.has("load_2")
		and r.tagged("cart_2")[0].has_meta("cart_load"))
	_part1(g, r)
	check("every cart loaded, the drawings aboard (Hollweg at his barn)", int(r.counters["loaded"]) == 5 and r.fired.has("draw_load")
		and int(r.counters["to_load"]) == 0)
	check("Jakob's word said: he stays (flag jakob stayed)", r.fired.has("jakob_talk") and str(r.flags.get("jakob")) == "stayed")
	_walk(g, g.clock + 4.0)
	check("all done: Part 2 begins at once (no waiting for the riders)", r.fired.has("part2") and r.obj.get("road", "") == "active"
		and not r.clocks.has("riders"))
	check("the carts set out on the road", r._routes.any(func(x): return String(x["name"]) == "road"))
	_walk(g, g.clock + 16.0)
	check("the column comes into the works, the riders down the track, the machine's sortie",
		r.fired.has("column") and r.fired.has("riders1") and r.fired.has("sortie") and not r.tagged("riders").is_empty())
	# Part 3: the carts at the landing
	_put(g, r.tagged("convoy"), _mid(r, "landing"))
	_walk(g, g.clock + 1.0)
	check("Part 3: the travelling clock is up, the turret's site, the last barge's clock", r.fired.has("part3")
		and r.tagged("travelling_clock").size() == 1 and r.tagged("turret").size() == 1 and not (r.tagged("turret")[0] as Building).built
		and r.clocks.has("last_barge"))
	check("the guild has the coins for its turret", int(g.players[r.team_index("guild")]["gold"]) >= 200)
	_put(g, r.tagged("fcarts") + r.tagged("drawings_cart"), _mid(r, "barges"))
	_walk(g, g.clock + 1.0)
	check("the barges take the carts: 5 families out, the drawings out", int(r.counters["families_out"]) == 5 and int(r.counters["drawings_out"]) == 1)
	# the bank quiet: the last barge is loaded sooner
	for u in _team_units(g, r, "crown") + _team_units(g, r, "machine"):
		u.die()
	var left0 := float(r.clocks["last_barge"]) - g.clock
	_walk(g, g.clock + 31.0)
	for u in _team_units(g, r, "crown") + _team_units(g, r, "machine"):
		u.die()          # (the commissary's last push came down the track meanwhile)
	_walk(g, g.clock + 20.0)
	check("the bank quiet (every enemy gone): the bargemen hurry (NO WAITING)", r.fired.has("push") and r.fired.has("quiet")
		and float(r.clocks.get("last_barge", 0.0)) - g.clock < left0 - 100.0)
	_walk(g, float(r.clocks["last_barge"]) + 0.5)
	check("the last barge loaded: Hollweg must come aboard", r.obj.get("aboard", "") == "active" and r.clocks.has("cast_off"))
	_put(g, r.tagged("hollweg"), _mid(r, "barges"))
	_walk(g, g.clock + 8.0)
	check("Hollweg aboard: the exodus is won", g.over and r.winner_side == "exodus", r.winner_side)
	check("the flags: exodus many (5 of 5), drawings carried, jakob stayed", str(r.flags.get("exodus")) == "many" and int(r.flags.get("exodus_n", 0)) == 5
		and str(r.flags.get("drawings")) == "carried" and str(r.flags.get("jakob")) == "stayed")
	var pages := r.pages_now(Campaign.show_pages(r.data, "ending", "exodus"))
	check("the ending has its pages", pages.size() == 2)
	check("the debrief fills its numbers", r.fill(String(r.data["debrief"]["exodus"]["text"])).contains("5 of 5"))


# ================================================================== take a cart, von Rauch's minute

func _take_and_minute() -> void:
	_progress({"bells": "rung"})
	var g: Game = await _start()
	var r := g.mission
	_part1(g, r)
	_walk(g, g.clock + 30.0)
	var cart: Unit = r.tagged("cart_3")[0]
	for u in _guild_fighters(g, r) + _team_units(g, r, "guild", ["winder", "missionary"]):
		u.position = _mid(r, "camp")
	_put(g, [cart], _mid(r, "s3"))
	var riders: Array = r.tagged("riders").filter(func(u): return not u.dead)
	check("riders came down the track", not riders.is_empty())
	_put(g, riders.slice(0, 2), cart.position + Vector2(30, 0))
	r._routes.clear()
	var took := false
	for i in 28:
		_step(g, g.clock + 0.25)
		took = took or cart.team == r.team_index("seized")
		if OS.get_cmdline_user_args().has("debug") and i % 4 == 0:
			print("  take ", r.act2["takes"], " riders ", riders.slice(0, 2).map(func(u): return "%s d%d" % [u.dead, int(u.position.distance_to(cart.position))]), " near guild ",
				g.units.filter(func(u): return not u.dead and g.allied(u.team, cart.team) and u.has_attack() and not u.has_meta("cage_cart") and u.position.distance_to(cart.position) < 120).map(func(u): return u.kind))
	check("TAKE A CART: riders round a cart with no guild fighter by it take it", took and int(r.counters["carts_taken"]) >= 1
		and cart.has_meta("cart_load"), "team %d taken %d" % [cart.team, int(r.counters["carts_taken"])])
	_put(g, [cart], _mid(r, "s3"))
	for u in riders:
		u.die()
	var fighters := _guild_fighters(g, r)
	_put(g, fighters.slice(0, 2), cart.position + Vector2(-30, 0))
	_walk(g, g.clock + 5.0)
	check("... and the guild takes it back (it turns for the Main)", cart.team == r.team_index("families") and int(r.counters["retaken"]) >= 1)
	_walk(g, float(r.fired.get("column", g.clock)) + 31.0)
	check("c01 bells rung: von Rauch's minute (the Crown's men stand)", r.fired.has("minute") and _said(r, "r_minute"))
	_walk(g, float(r.clocks.get("minute", g.clock)) + 1.0)
	check("... and after it they come on", r.fired.has("minute_end") and int(r.counters["minute"]) == 0)


# ================================================================== the defeats

func _defeats() -> void:
	_progress()
	var g: Game = await _start()
	var r := g.mission
	_walk(g, float(r.clocks["riders"]) + 5.0)
	check("nothing loaded when the riders came: the exodus is lost", g.over and r.winner_side != "exodus" and r.obj.get("load", "") == "failed",
		r.winner_side)
	check("... every unloaded family counted as left", int(r.counters["families_left"]) == 5)
	_progress()
	g = await _start()
	r = g.mission
	_part1(g, r)
	_walk(g, g.clock + 4.0)
	_put(g, r.tagged("convoy"), _mid(r, "landing"))
	_walk(g, g.clock + 1.0)
	_walk(g, float(r.clocks["last_barge"]) + 0.5)
	_put(g, r.tagged("hollweg"), _mid(r, "camp"))
	_walk(g, float(r.clocks["cast_off"]) + 2.0)
	check("the last barge gone without Hollweg: lost", g.over and r.winner_side != "exodus" and r.obj.get("aboard", "") == "failed")
	# the rearguard broken: the commissary's men on the landing, no guild fighter: they take Hollweg
	_progress()
	g = await _start()
	r = g.mission
	_part1(g, r)
	_walk(g, g.clock + 4.0)
	_put(g, r.tagged("convoy"), _mid(r, "landing"))
	_walk(g, g.clock + 1.0)
	for u in _guild_fighters(g, r):
		u.die()
	var men: Array = _team_units(g, r, "crown")
	if men.size() < 3:
		r.act({"spawn": {"team": "crown", "kind": "musketeer", "count": 3, "at": "landing", "tag": "test_men"}})
		men = _team_units(g, r, "crown")
	var hw: Unit = r.tagged("hollweg")[0]
	_put(g, [hw], _mid(r, "barges"))
	_put(g, men.slice(0, 4), hw.position + Vector2(40, 0))
	r._routes.clear()
	_walk(g, g.clock + 9.0)
	check("the rearguard broken: Hollweg may be taken", r.fired.has("rearguard_gone") and r.obj.get("c_hollweg", "") == "active")
	hw.hp = hw.max_hp * 0.2
	_put(g, men.slice(0, 1), hw.position + Vector2(20, 0))
	_walk(g, g.clock + 6.0)
	check("... taken alive: the commissary wins (flag hollweg taken)", g.over and r.winner_side == "commissary" and str(r.flags.get("hollweg")) == "taken")


# ================================================================== the commissary's mirror

func _mirror() -> void:
	_progress()
	var g: Game = await _start("commissary")
	var r := g.mission
	check("the commissary picked: the player leads the Crown's team", g.human == r.team_index("crown"))
	check("Part 1: the families load themselves (the guild scripted); Hollweg can't be taken yet", r.obj.get("c_hollweg", "") == "hidden")
	_walk(g, 34.0)
	check("Part 2 at 30 s: the column rides in at the camp, Hollweg may be taken now", r.fired.has("part2") and r.fired.has("column_c")
		and r.obj.get("c_hollweg", "") == "active" and not r.tagged("brandt").is_empty())
	check("every family loaded by the guild's own hands", int(r.counters["loaded"]) == 5)
	var hw: Unit = r.tagged("hollweg")[0]
	for u in _guild_fighters(g, r):
		u.die()
	hw.hp = hw.max_hp * 0.2
	var men := _team_units(g, r, "crown", ["musketeer"])
	_put(g, men.slice(0, 1), hw.position + Vector2(20, 0))
	_walk(g, g.clock + 6.0)
	check("Hollweg taken alive: the commissary wins", g.over and r.winner_side == "commissary" and str(r.flags.get("hollweg")) == "taken")
	var pages := r.pages_now(Campaign.show_pages(r.data, "ending", "commissary"))
	check("the commissary's ending: the King says that is not how it went", pages.size() == 2)


# ================================================================== save and load in the middle

func _snap(g: Game) -> Dictionary:
	var r := g.mission
	var tg := {}
	for t in r.tags:
		tg[t] = r.tagged(String(t)).size()
	var loads: Array = (r.act2.get("loads", []) as Array).map(func(x): return "%s:%d" % [x.get("cargo", ""), int(x.get("n", 0))])
	loads.sort()
	return {"flags": r.flags, "counters": r.counters, "obj": r.obj, "tags": tg, "loads": loads,
		"grounds": (r.act2.get("grounds", []) as Array).size(), "deny": r.deny.get(r.team_index("guild"), {}).size(),
		"tech": g.has_tech(r.team_index("guild"), "shield_wall")}


func _save_load() -> void:
	_progress()
	MissionSave.clear_all(MID)
	var g: Game = await _start()
	var r := g.mission
	_part1(g, r)
	_walk(g, g.clock + 8.0)
	var before := _snap(g)
	main.mission_save_now()
	check("SAVE written in the middle of the road", MissionSave.has(MID, "save"))
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
	check("LOADED the same: flags, counters, objectives, the carts' loads, the spring's ground, the denied, the drill", diff.is_empty(), "; ".join(diff))
	var gr: Array = (g2.mission.act2.get("grounds", []) as Array).filter(func(x): return String(x["name"]) == "spring")
	var sc: Array = g2.mission.tagged("spring_cart")
	check("after the load the spring's plates still follow the spring cart", not gr.is_empty() and not sc.is_empty() and gr[0].get("src") == sc[0],
		str(gr[0].get("src") if not gr.is_empty() else null))
	var loads_ok: bool = (g2.mission.act2.get("loads", []) as Array).all(func(x): return x.get("cart") is Unit and is_instance_valid(x["cart"]))
	check("after the load every cart's load is on a real cart", loads_ok)
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


# ================================================================== the hubs and the war map after d02

func _hubs() -> void:
	_progress()
	Campaign.record(MID, "solo", "exodus", "exodus", {"exodus": "many", "exodus_n": 5, "drawings": "carried", "jakob": "stayed"})
	var p := Campaign.progress()
	var sl := Campaign.storyline_of(MID)
	var hw: Dictionary = sl["hub"]["talks"]["hollweg"]
	check("the hub: Hollweg talks of the river after d02", str(CampaignMenu.talk_lines(hw, p)).contains("river"))
	var people: Array = (HubGrow.people_now("clockmaker", "workshop", p) + HubGrow.people_now("clockmaker", "yard", p)).map(func(x): return String(x["id"]))
	check("the hub: Jakob, Ferrer, von Rauch and Brother Anselm stayed at Fürth; Ulrich came", not people.has("jakob") and not people.has("ferrer")
		and not people.has("rauch") and not people.has("anselm") and people.has("ulrich"), str(people))
	check("the hub: Ulrich talks of the barge", str(HubGrow.talk_lines(HubGrow.talk("ulrich"), p)).contains("barge"))
	var led: Array = WarMapData.state(p).get("ledger", []).map(func(x): return String(x.get("text", "")))
	check("the war map's ledger: the guild left the Crown, the families counted", led.has("The guild left Fürth by night and went down the Main to the sea: it has left the Crown.")
		and led.has("Families who left Fürth with the guild: %s."))
	check("the war map's data has no problem", WarMapData.problems().is_empty(), "; ".join(WarMapData.problems()))
	_progress()
	Campaign.record(MID, "solo", "commissary", "commissary", {"hollweg": "taken", "exodus": "few", "exodus_n": 0})
	p = Campaign.progress()
	check("a commissary's win: Hollweg in custody in the hub (not how it went)", str(CampaignMenu.talk_lines(hw, p)).contains("commissary has me"))
	var st: Dictionary = WarMapData.state(p)
	check("... and the war map's seal is broken", str(st).contains("broken"))
