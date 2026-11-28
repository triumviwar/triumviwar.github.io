extends SceneTree
## ACT 3's ENGINE STEP 0 (act3-engine0, docs/act3_engine0.md): a copy of the engine's test mission (p01_revolt) with
## every new piece in it, kept in Campaign's cache only (never a file), played with the clock moved by hand:
## the data checks (good and bad), THE CLIMATE (the cold holding an egg back, the FROST LINE killing one and moving
## with the night, the wet running the machines down, the heat's pace), THE STOP-WORK (a ring, a spared side, its end),
## THE MADE CALL (a scripted wave turned, a person's creatures not), WARMTH (out of the fires' rings the cold bites),
## THE FLIGHT PART (on its route, marking, flown), THE LEDGER (its marks from the progress, the bands, the card, its
## conditions before and in the match), THE NIGHT's ORDER (fresh / normal / grown, the rank kept), THE LADDER IN ANY
## ORDER (every order of every line's Act 3 rungs, from the doc's CHECKED TABLE), THE FINAL CHOICE (no timer, the
## match held and let go), THE ENDING (kept in the progress) and THE CREDITS (the map, the names, the King's study,
## after the last mission's end), the save keeping it.
##   godot --headless --fixed-fps 30 --script res://tools/test_act3_engine0.gd
## Prints CHECK lines, then "act3-engine0: N failures"; exit code 1 on a failure. Leaves user://campaign.json as it was.
var main: Node
var fails := 0
var _kept := ""
const ID := "x_act3"


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-70s %s %s" % [name, "ok" if ok else "FAIL", detail])
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
	print("act3-engine0: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The progress file set by hand: {mission: flags} won (by the crown).
func _progress(done: Dictionary) -> void:
	var p := {"reached": [], "done": {}}
	for mk in done:
		p["done"][mk] = {"won_by": "crown", "mode": "solo", "side": "crown", "played": 1, "flags": done[mk]}
	Campaign.save_progress(p)


func mission() -> Dictionary:
	var m: Dictionary = Campaign.mission("p01_revolt").duplicate(true)
	m["id"] = ID
	m["sides"].append({"id": "wild", "name": "The Wild"})
	m["teams"].append({"id": "swarm", "side": "wild", "faction": "brood", "colour": 2, "start": "none", "camera": "village",
		"control": {"solo": "script", "coop": "script", "versus": "script"}})
	m["teams"].append({"id": "works", "side": "rebels", "faction": "clockwork", "colour": 6, "start": "none", "camera": "ford",
		"control": {"solo": "script", "coop": "script", "versus": "script"}})
	m["teams"].append({"id": "guild", "side": "crown", "faction": "clockwork", "colour": 4, "start": "none", "camera": "camp",
		"control": {"solo": "script", "coop": "script", "versus": "script"}})
	m["triggers"] = []
	m.erase("wiped_out")
	m.erase("ending")
	m["objectives"] = [{"id": "x", "side": "crown", "primary": true, "kind": "manual", "text": "x"},
		{"id": "y", "side": "rebels", "primary": true, "kind": "manual", "text": "y"}]
	m["counters"] = {"frozen_c": {"start": 0}, "stopped_c": {"start": 0}, "called_c": {"start": 0}, "cold_dead": {"start": 0},
		"marks": {"start": 0}, "ledger_n": {"start": 0}}
	m["units"].append({"team": "swarm", "kind": "raptor", "count": 4, "at": "ford", "tag": "wave"})
	m["units"].append({"team": "works", "kind": "clock_soldier", "count": 3, "at": "ford", "tag": "machines"})
	m["units"].append({"team": "guild", "kind": "clock_soldier", "count": 2, "at": "ford", "tag": "honest"})
	m["units"].append({"team": "column", "kind": "balloon", "count": 1, "at": "camp", "tag": "inacio"})
	m["climate"] = {"cold": {"hatch": 0.5, "frost": {"row": 10, "side": "north", "kill": 6, "counter": "frozen_c"}},
		"wet": {"wind": 3.0}, "heat": {"pace": 0.8}}
	m["credits"] = true
	# every new action and condition once in a trigger that never fires (the data checks read them)
	m["triggers"].append({"id": "never", "when": {"all": [{"time": 99999}, {"stopped": "bells"}, {"stopping": "bells"},
		{"called": {"name": "call", "at_least": 1}}, {"calling": "call"}, {"cold": {"name": "forge"}}, {"flown": "flight"},
		{"marked": {"name": "flight", "at_least": 2}}, {"frozen": {"at_least": 1}}, {"ledger": {"band": "strong"}},
		{"ledger": {"mark": "lisbon"}}, {"night": "fresh"}, {"ending": "rome_holds"}, {"won": "p01_leaf"},
		{"colonies": {"share": 0.5}}]},
		"do": [{"climate": {"wet": {"wind": 2.0}}}, {"stop_work": {"at": "ford", "within": 10, "secs": 30, "spare": "crown", "name": "bells", "counter": "stopped_c"}},
			{"made_call": {"at": "ford", "to": "east_road", "secs": 30, "name": "call", "counter": "called_c"}},
			{"warmth": {"team": "column", "fires": "brazier", "within": 4, "loss": 5, "name": "forge", "counter": "cold_dead"}},
			{"flight": {"tag": "inacio", "route": ["ford", "village"], "mark": "militia", "name": "flight", "counter": "marks"}},
			{"ledger": {"counter": "ledger_n"}}, {"ending": "rome_holds"},
			{"choice": {"id": "final", "final": true, "options": [{"id": "hold", "label": "HOLD ROME"}, {"id": "flock", "label": "SAVE THE FLOCK"}]}}]})
	return m


func _cache(m: Dictionary) -> void:
	Campaign._cache["%s/missions/%s.json" % [Campaign.DIR, ID]] = m


func _data() -> void:
	var m := mission()
	_cache(m)
	var pr := Campaign.problems(m)
	check("data: the test mission's new keys check out", pr.is_empty(), "; ".join(pr))
	var bad: Dictionary = m.duplicate(true)
	bad["climate"] = {"snow": {}, "cold": {"frost": {"row": 3, "night_row": 9}}}
	bad["triggers"].append({"id": "b", "when": {"all": [{"ledger": {"band": "huge"}}, {"ledger": {"mark": "atlantis"}},
		{"night": "dawn"}, {"stopped": {}}]},
		"do": [{"stop_work": {"within": 3}}, {"made_call": {"at": "ford", "to": "nowhere"}}, {"warmth": {"team": "column"}},
			{"flight": {"tag": "inacio"}}, {"ending": "rome_burns"}, {"stop_work": {"at": "ford", "faction": "elves"}},
			{"flight": {"tag": "inacio", "route": ["ford", "moon"]}}, {"ledger": {"counter": "nope"}}]})
	var bp := Campaign.problems(bad)
	for want in ["unknown climate snow", "a moving frost line needs a period", "ledger: unknown band huge",
			"ledger: unknown mark atlantis", "unknown night dawn", "stopped needs a name", "stop_work needs \"at\"",
			"made_call needs \"to\"", "warmth needs its fires' tag", "flight needs the flyer's tag and a route",
			"unknown ending rome_burns", "stop_work: unknown faction elves", "route through unknown area moon",
			"ledger: unknown counter nope"]:
		check("data: problems() catches '%s'" % want, bp.any(func(x: String) -> bool: return x.contains(want)), "")
	# the campaign's own data: the ledger's marks, the night group, the credits
	var lg: Dictionary = Campaign.index().get("ledger", {})
	check("campaign.json: the ledger's 17 marks, bands and the King's three lines", (lg.get("marks", []) as Array).size() == 17 and lg.get("lines", {}).size() == 3)
	check("campaign.json: the night's group of three", Campaign.night_group("e17_goa").size() == 3)
	check("campaign.json: the credits' sections and last lines", (Campaign.credits().get("sections", []) as Array).size() >= 3 and Campaign.credits().get("last", {}).size() == 3)
	var strs := Campaign.index_strings()
	check("strings: the ledger's labels and the credits' headings are campaign texts", strs.has("Lisbon held: the fleet in the Tiber's mouth") and strs.has("THANK YOU FOR PLAYING") and strs.has("Some are coming. Not all I wrote to."))


## THE LEDGER and THE NIGHT's ORDER (decided from the progress, before any match).
func _ledger_night() -> void:
	_progress({})
	var lg := Campaign.ledger()
	check("ledger: nothing played: 0 marks, WEAK", int(lg["count"]) == 0 and String(lg["band"]) == "weak" and String(lg["line"]) == "I wrote to everyone. Two answered.")
	_progress({"e16_lisbon": {"lisbon": "held"}, "e17_goa": {"goa_night": "held"}, "e04_kongo": {"kongo": "stood"},
		"p01_leaf": {"families": "save"}, "e03_virginia": {"virginia": "some", "fairleigh": "rode_with"},
		"d10_jungle": {"inacio": "joined"}})
	lg = Campaign.ledger()
	check("ledger: six things brought: 6 marks, MIDDLE (the volunteers need both flags; 'some' is one of the list)", int(lg["count"]) == 6 and String(lg["band"]) == "middle", "%d %s" % [lg["count"], lg["band"]])
	check("ledger: the mark held and one not", Campaign.ledger_holds({"mark": "volunteers"}, lg) and not Campaign.ledger_holds({"mark": "exiles"}, lg))
	check("ledger: before the match (cond_before)", Campaign.cond_before({"ledger": {"band": "middle"}}, "", "normal") and Campaign.cond_before({"ledger": {"at_least": 6}}, "", "normal") and not Campaign.cond_before({"ledger": {"band": ["strong", "weak"]}}, "", "normal"))
	var more := {"e16_lisbon": {"lisbon": "held"}, "e17_goa": {"goa_night": "held"}, "e18_port": {"atlantic": "held"},
		"e04_kongo": {"kongo": "stood"}, "e09_nagasaki": {"stopwork": "kept"}, "e06_taken": {"ruin": "opened"},
		"e12_exiles": {"exiles": "pardon"}, "e01_brazil": {"colonists": "many"}, "d11_siege": {"jakob": "alive"},
		"e19_tiber": {"deserters": "spared", "campagna": "some"}}
	_progress(more)
	lg = Campaign.ledger()
	check("ledger: eleven things brought: STRONG", int(lg["count"]) == 11 and String(lg["band"]) == "strong", "%d" % lg["count"])
	check("colonies: no clock yet: the mark not held", not Campaign.ledger_holds({"mark": "colonies"}, lg))
	var p := Campaign.progress()
	p["colonies"] = {"caribbean": "brood", "potosi": "crown", "luanda": "crown", "malacca": "clockwork"}
	Campaign.save_progress(p)
	check("colonies: half still the Crown's: the mark held", Campaign.colonies_share() == 0.5 and Campaign.ledger_holds({"mark": "colonies"}, Campaign.ledger()))
	# THE NIGHT's ORDER
	_progress({})
	check("night: none played: Lisbon is FRESH", Campaign.night_word("e16_lisbon") == "fresh")
	_progress({"e16_lisbon": {}})
	check("night: one played: Goa is NORMAL", Campaign.night_word("e17_goa") == "normal" and Campaign.night_is("normal", "e17_goa"))
	_progress({"e16_lisbon": {}, "e17_goa": {}})
	check("night: two played: the port is GROWN", Campaign.night_word("e18_port") == "grown" and Campaign.night_is(["normal", "grown"], "e18_port"))
	Campaign.asking = "e18_port"
	check("night: before the match (the asking mission)", Campaign.cond_before({"night": "grown"}, "", "normal"))
	check("night: not a night mission: no rank", Campaign.night_rank("p01_leaf") == -1 and Campaign.night_word("p01_leaf") == "")
	# the rank kept as it was won: Goa won second stays NORMAL when replayed with all three done
	_progress({"e16_lisbon": {}})
	Campaign.record("e17_goa", "solo", "crown", "crown", {})
	Campaign.record("e18_port", "solo", "crown", "crown", {})
	check("night: the rank kept as won (Goa second: NORMAL, the port last: GROWN)", Campaign.night_word("e17_goa") == "normal" and Campaign.night_word("e18_port") == "grown" and int(Campaign.progress()["done"]["e17_goa"]["night_rank"]) == 1)
	# THE ENDING kept by the record
	Campaign.record("e20_rome", "solo", "crown", "crown", {"ending": "rome_falls", "final": "flock"})
	check("ending: kept in the progress (Campaign.ending)", Campaign.ending() == "rome_falls")


## The doc's CHECKED TABLE rows: {step, mission, new, with, allow, faction}.
func _table() -> Array:
	var out: Array = []
	var on := false
	for line in FileAccess.get_file_as_string("res://docs/campaign_roster_ladder.md").split("\n"):
		if line.begins_with("## THE CHECKED TABLE"):
			on = true
			continue
		if on and line.begins_with("## "):
			break
		if not on or not line.begins_with("| ") or line.begins_with("| step") or line.begins_with("| ---"):
			continue
		var c := line.split("|")
		var w := func(s: String) -> Array:
			return Array(s.strip_edges().split(" ", false)).filter(func(x) -> bool: return x != "-")
		var step := String(c[1]).strip_edges()
		out.append({"step": step, "mission": String(c[2]).strip_edges(), "new": w.call(c[4]), "with": w.call(c[5]),
			"allow": w.call(c[6]), "faction": {"C": "crown", "K": "clockwork", "B": "brood"}[step.left(1)]})
	return out


func _perms(a: Array) -> Array:
	if a.size() <= 1:
		return [a.duplicate()]
	var out: Array = []
	for i in a.size():
		var rest := a.duplicate()
		var x = rest.pop_at(i)
		for p in _perms(rest):
			out.append([x] + p)
	return out


## THE LADDER IN ANY ORDER: every order of each line's Act 3 rungs gives the same kit at its end, and each mission's
## kit is the line's Act 2 kit + every rung won before + its own.
func _ladder() -> void:
	var rows := _table()
	var any_from := {"crown": 10, "clockwork": 8, "brood": 8}
	for f in ["crown", "clockwork", "brood"]:
		var act3 := rows.filter(func(r) -> bool: return r["faction"] == f and int(String(r["step"]).substr(1)) >= int(any_from[f]))
		var act2 := rows.filter(func(r) -> bool: return r["faction"] == f and int(String(r["step"]).substr(1)) < int(any_from[f]))
		var base: Array = act2[-1]["allow"]
		check("ladder %s: Act 3's rungs have their missions" % f, act3.size() >= 2 and act3.all(func(r) -> bool: return String(r["mission"]).begins_with("e")))
		var ok := true
		var why := ""
		for order in _perms(act3):
			var won: Array = []
			_progress({})
			for r in order:
				# the mission's team as roster_ladder.apply writes it: the table's allow + if_won of the others
				var iw := {}
				for r2 in act3:
					if r2 != r:
						iw[r2["mission"]] = (r2["new"] as Array) + (r2["with"] as Array)
				var tm := {"faction": f, "roster": {"allow": r["allow"], "new": r["new"], "if_won": iw}}
				var want: Array = base.duplicate()
				for r3 in won:
					want.append_array((r3["new"] as Array) + (r3["with"] as Array))
				want.append_array((r["new"] as Array) + (r["with"] as Array))
				var denied := Campaign.roster_denied({}, tm)
				for k in Campaign.roster_items(f):
					if (not want.has(k)) != denied.has(k):
						ok = false
						why = "%s after %s: %s" % [r["step"], won.map(func(x): return x["step"]), k]
				won.append(r)
				var p := Campaign.progress()
				p["done"][r["mission"]] = {"won_by": "crown", "flags": {}}
				Campaign.save_progress(p)
		check("ladder %s: every order of its Act 3 rungs gives each mission the kit won so far + its own" % f, ok, why)
	_progress({})


func _start() -> Game:
	_cache(mission())
	main.start(Campaign.make_cfg(ID, "solo"))
	await process_frame
	await process_frame
	return main.game


func _tick(g: Game, secs: float) -> void:
	var r: MissionRun = g.mission
	var t := 0.0
	while t < secs - 0.001:
		g.clock += 0.25
		r.a2.tick(0.25)
		r.a3.tick(0.25)
		r.a3.frame(0.25)
		r._run_triggers()
		t += 0.25


## The column's men (horses not counted) farther than `reach` from the fire (what WARMTH counts as out in the cold).
func _out_of(g: Game, r: MissionRun, at: Vector2, reach: float) -> int:
	var n := 0
	for u in g.units:
		if not u.dead and u.team == r.team_index("column") and u.kind != "horse" and u.position.distance_to(at) > reach + u.radius:
			n += 1
	return n


func _away(units: Array, where: Vector2) -> void:
	var i := 0
	for u in units:
		u.position = where + Vector2((i % 6) * 18, (i / 6) * 18)
		i += 1


func _match() -> void:
	_progress({})
	var g: Game = await _start()
	var r: MissionRun = g.mission
	var T := float(Defs.TILE)
	check("the run has Act 3's pieces", r != null and r.a3 != null and r.act3.has("stops"))
	var far := r.area_rect("camp").position + Vector2(10, 10)
	var ford := r.area_rect("ford").get_center()
	# ------------------------------------------------------------ THE CLIMATE
	check("climate: the heat's pace for the Brood", is_equal_approx(float(r.climate_pace.get("brood", 1.0)), 0.8))
	var st := r.team_index("swarm")
	var warm := Vector2(ford.x, 20.0 * T)          # (row 20: south of the frost line at row 10)
	var e1 := g._add_unit(BroodNew.EGG, st, warm)
	e1.nb = {"k": "grub", "t": 5.0, "fert": 0, "wait": 0.0}
	var e2 := g._add_unit(BroodNew.EGG, st, Vector2(ford.x, 4.0 * T))      # (row 4: frozen)
	e2.nb = {"k": "grub", "t": 0.0, "fert": 0, "wait": 0.0}
	check("frost: the line at row 10, the north frozen", r.a3.frost_line() == [10.0, "north"] and r.a3.frozen_at(e2.position) and not r.a3.frozen_at(e1.position))
	var mach: Array = r.tagged("machines")
	for u in mach:
		u.wind = 1.0
	_away(mach, far + Vector2(0, 400))
	_tick(g, 2.0)
	check("cold: an egg's hatching held back to half its pace", absf(float(e1.nb["t"]) - 4.0) < 0.01, str(e1.nb["t"]))
	check("frost: an egg on the frozen side counts its seconds", not e2.dead and float(e2.get_meta("act3_frost", 0.0)) >= 1.9)
	var w0: float = mach[0].wind
	_tick(g, 4.5)
	check("frost: killed after its seconds (FROZEN, counted)", e2.dead and int(r.counters["frozen_c"]) == 1 and r.cond({"frozen": {"at_least": 1}}))
	check("wet: the machines ran down faster (x3 the decay over the ticks)", mach[0].wind < w0 - 0.05, "%.3f -> %.3f" % [w0, mach[0].wind])
	# a moving frost line: noon at row 10, midnight at row 30
	r.act({"climate": {"cold": {"frost": {"row": 10, "night_row": 30, "period": 100, "side": "north", "kill": 6}}}})
	var c0 := g.clock
	g.clock = 100.0 * ceil(c0 / 100.0) + 50.0       # (midnight: half a period from noon)
	check("frost: the line comes down at night", absf(float(r.a3.frost_line()[0]) - 30.0) < 0.5 and r.a3.frozen_at(e1.position), str(r.a3.frost_line()))
	g.clock = 100.0 * ceil(c0 / 100.0) + 100.0
	check("frost: back up at noon", absf(float(r.a3.frost_line()[0]) - 10.0) < 0.5)
	g.clock = c0
	r.act({"climate": {"off": true}})
	check("climate off: no frost, no pace", r.a3.frost_line().is_empty() and r.climate_pace.is_empty())
	# ------------------------------------------------------------ THE STOP-WORK
	var honest: Array = r.tagged("honest")
	for u in mach + honest:
		u.wind = 1.0
	_away(mach, ford)
	_away(honest, ford + Vector2(0, 40))
	var far_m: Unit = mach[2]
	far_m.position = ford + Vector2(30 * T, 0)
	g._rebuild_hash()
	r.act({"stop_work": {"at": "ford", "within": 10, "secs": 5, "spare": "crown", "name": "bells", "counter": "stopped_c"}})
	_tick(g, 1.0)
	check("stop-work: the machines in the ring run down to nothing", mach[0].wind == 0.0 and mach[1].wind == 0.0)
	check("stop-work: the guild's (the spared side) go on", honest.all(func(u) -> bool: return u.wind > 0.5))
	check("stop-work: one out of the ring goes on", far_m.wind > 0.5)
	check("stop-work: counted, ringing now", r.cond({"stopped": {"name": "bells", "at_least": 2}}) and r.cond({"stopping": "bells"}) and int(r.counters["stopped_c"]) == 2)
	far_m.position = ford + Vector2(3 * T, 0)
	_tick(g, 0.5)
	check("stop-work: one that walks in stops too", far_m.wind == 0.0 and r.cond({"stopped": {"name": "bells", "at_least": 3}}))
	_tick(g, 4.0)
	check("stop-work: over after its seconds", not r.cond({"stopping": "bells"}))
	mach[0].wind = 0.6
	_tick(g, 0.5)
	check("stop-work: after it, the machines are wound again as ever (not held)", mach[0].wind > 0.5)
	_away(mach, far + Vector2(0, 400))
	# ------------------------------------------------------------ THE MADE CALL
	var wave: Array = r.tagged("wave")
	_away(wave, ford)
	g._rebuild_hash()
	r.act({"made_call": {"at": "ford", "within": 12, "to": "east_road", "secs": 10, "name": "call", "counter": "called_c"}})
	_tick(g, 0.5)
	check("made call: the scripted wave in reach turned (counted)", r.cond({"called": {"name": "call", "at_least": 4}}) and int(r.counters["called_c"]) == 4 and r.cond({"calling": "call"}))
	var moving := wave.filter(func(u) -> bool: return not u.dead and String(u.order) == "move")
	check("made call: they walk to the marsh (a move order)", moving.size() == 4, str(wave.map(func(u): return u.order)))
	_tick(g, 2.0)
	check("made call: each turned once", int(r.counters["called_c"]) == 4)
	_tick(g, 8.0)
	check("made call: over after its seconds", not r.cond({"calling": "call"}))
	_away(wave, far + Vector2(900, 0))
	# ------------------------------------------------------------ WARMTH
	var foot: Array = r.tagged("column_foot")
	var brazier: Unit = r.tagged("captain")[0]
	r._tag("brazier", brazier)          # (the captain carries the fire: a brazier is any living thing with the tag)
	_away(foot, far + Vector2(1200, 0))
	brazier.position = far + Vector2(1200, 0)
	var near_u: Unit = foot[0]
	var cold_u: Unit = foot[7]
	cold_u.position = far + Vector2(1200 + 12 * T, 0)
	g._rebuild_hash()
	r.act({"warmth": {"team": "column", "fires": "brazier", "within": 4, "loss": 5, "name": "forge", "counter": "cold_dead"}})
	var hn := near_u.hp
	var hc := cold_u.hp
	_tick(g, 3.0)
	check("warmth: the fire found by its tag", r.a3._fires("brazier").size() == 1, str(r.tagged("brazier").size()))
	check("warmth: by the fire no loss", near_u.hp >= hn - 0.01, "%.1f -> %.1f" % [hn, near_u.hp])
	check("warmth: out in the cold it bites (5%% a second)", cold_u.hp < hc - cold_u.max_hp * 0.1, "%.1f -> %.1f" % [hc, cold_u.hp])
	check("warmth: the cold condition counts who is out now", r.cond({"cold": {"name": "forge", "at_least": 1}}) and r.a3.cold_count("forge") == _out_of(g, r, brazier.position, 4.0 * T), "%d" % r.a3.cold_count("forge"))
	r.act({"warmth": {"name": "forge", "on": false}})
	check("warmth: off", not r.cond({"cold": {"name": "forge"}}))
	# ------------------------------------------------------------ THE FLIGHT PART
	var bal: Unit = r.tagged("inacio")[0]
	var mil: Array = r.tagged("militia")
	bal.position = r.area_rect("camp").get_center()
	r.act({"flight": {"tag": "inacio", "route": ["ford", "village"], "speed": 600, "mark": "militia", "within": 8, "name": "flight", "counter": "marks"}})
	_tick(g, 0.5)
	check("flight: on its way, not flown yet", not r.cond({"flown": "flight"}) and bal.position.distance_to(r.area_rect("camp").get_center()) > 50.0)
	for i in 120:
		_tick(g, 0.25)
		if r.cond({"flown": "flight"}):
			break
	check("flight: flown to the end of its route", r.cond({"flown": "flight"}) and bal.position.distance_to(r.area_rect("village").get_center()) < 4.0)
	var mk := mil.filter(func(u) -> bool: return not u.dead and u.has_meta("act3_marked")).size()
	check("flight: what it passed over is MARKED (counted)", mk >= 2 and r.cond({"marked": {"name": "flight", "at_least": 2}}) and int(r.counters["marks"]) == mk, "%d" % mk)
	# ------------------------------------------------------------ THE LEDGER in the match
	_progress({"e16_lisbon": {"lisbon": "held"}, "e04_kongo": {"kongo": "stood"}})
	r.act({"ledger": {"counter": "ledger_n"}})
	await process_frame
	var card: Control = g.hud.get_parent().find_child("LedgerCard", true, false)
	check("ledger: counted into the flags and the counter", int(r.flags["ledger"]) == 2 and String(r.flags["ledger_band"]) == "weak" and int(r.counters["ledger_n"]) == 2)
	check("ledger: the condition in the match", r.cond({"ledger": {"band": "weak"}}) and r.cond({"ledger": {"mark": "lisbon"}}) and not r.cond({"ledger": {"mark": "goa"}}))
	check("ledger: the card shows every mark and the band", card != null and card.find_child("Mark_lisbon", true, false) != null and card.find_child("Mark_colonies", true, false) != null and card.find_child("Band", true, false) != null)
	var was := paused
	r.a3.close_ledger()
	await process_frame
	check("ledger: CLOSE puts the match back as it was", paused == was and not is_instance_valid(card) or card.is_queued_for_deletion())
	# ------------------------------------------------------------ THE FINAL CHOICE
	paused = false
	r.offer_choice({"id": "final", "final": true, "options": [{"id": "hold", "label": "HOLD ROME"}, {"id": "flock", "label": "SAVE THE FLOCK"}], "default": "flock"})
	check("final choice: no timer (nobody's default taken)", float(r.choice_open.get("until", 0.0)) >= 1e17)
	check("final choice: it holds the match", paused)
	g.clock += 500.0
	r._physics_process(0.3)
	check("final choice: still open after a long wait", not r.choice_open.is_empty() and not r.flags.has("final"))
	r.choose("final", "hold")
	check("final choice: answered, the match let go", String(r.flags.get("final", "")) == "hold" and not paused)
	r.offer_choice({"id": "plain", "time": 0, "options": [{"id": "a", "label": "A"}]})
	check("a choice with time 0 has no timer either (and does not hold the match)", float(r.choice_open.get("until", 0.0)) >= 1e17 and not paused)
	r.choose("plain", "a")
	paused = true
	# ------------------------------------------------------------ THE ENDING
	r.act({"ending": "rome_holds"})
	check("ending: the flag and the condition", String(r.flags.get("ending", "")) == "rome_holds" and r.cond({"ending": "rome_holds"}))
	# ------------------------------------------------------------ the save keeps it
	var sv := r.save_state({}, {})
	check("save: Act 3's state is in the mission's save", MissionRun.SAVE_KEYS.has("act3") and sv.contains("\"flights\"") and sv.contains("\"stops\""))
	check("not over in all this", not g.over)
	# ------------------------------------------------------------ THE CREDITS after the last mission
	r.finish("crown")
	await process_frame
	CampaignMenu.mission_end(main, g, r.team_index("column"), "")
	await process_frame
	var cr: CampaignCredits = main.ui_layer.find_child("CampaignCredits", true, false)
	check("credits: rolled after the last mission (\"credits\": true)", cr != null and cr.ending == "rome_holds")
	check("ending: the record kept it in the progress", Campaign.ending() == "rome_holds")
	if cr:
		check("credits: over the war map, the names rolling", cr.find_child("CreditsMap", true, false) != null and cr.find_child("Roll", true, false).get_child_count() > 10)
		cr.to_study()
		await process_frame
		var ll: Label = cr.find_child("LastLine", true, false)
		check("credits: the King's study (the pipe) and the ending's last line", cr.find_child("CreditsStudy", true, false) != null and ll != null and ll.text == Loc.t(String(Campaign.credits()["last"]["rome_holds"])))
		cr.finish()
		await process_frame
		check("credits: then the mission's end screen", main.ui_layer.find_child("MissionEnd", true, false) != null)
	main._to_menu()
	await process_frame


func _hub() -> void:
	# THE CREDITS from the war table once the campaign has its ending
	CampaignMenu.line = "prologue"
	CampaignMenu.show(main)
	await process_frame
	CampaignMenu.war_table(main)
	await process_frame
	var cb: Button = main.menu.find_child("WarTable_Credits", true, false)
	check("hub: THE CREDITS on the war table once the campaign is finished", cb != null)
	if cb:
		cb.pressed.emit()
		await process_frame
		var cr: CampaignCredits = main.ui_layer.find_child("CampaignCredits", true, false)
		check("hub: THE CREDITS roll from it", cr != null)
		if cr:
			cr.finish()
	_progress({})
	CampaignMenu.show(main)
	await process_frame
	CampaignMenu.war_table(main)
	await process_frame
	check("hub: no CREDITS before the end", main.menu.find_child("WarTable_Credits", true, false) == null)


func _run() -> void:
	await process_frame
	_data()
	_ledger_night()
	_ladder()
	await _match()
	await _hub()
	_finish()
