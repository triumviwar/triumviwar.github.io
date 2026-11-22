extends SceneTree
## THE WORLD WAR mode (docs/world_war_mode.md): the map's data is sound, a war is set up as the rules say, computers'
## turns run with auto-resolve to a winner, a saved war loads the same (and goes on the same), the cold and the rust,
## upkeep and risings, a fought battle starts with exactly the armies on the world map and carries its survivors back,
## the menu's WORLD WAR page and START THE WAR, and every text has pt and es.
##   godot --headless --script res://tools/test_world_war.gd
## Prints CHECK lines, then "world war: N failures"; exit code 1 on a failure. (Its wars are removed again.)
var main
var fails := 0


func check(name: String, ok: bool, detail: Variant = "") -> void:
	print("CHECK %-72s %s %s" % [name, "ok" if ok else "FAIL", str(detail)])
	if not ok:
		fails += 1


func _initialize() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	Settings.load_all()
	Settings.device = "pc"
	Settings.apply()
	Loc.set_lang("en")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _war(players := {"crown": "normal", "clockwork": "normal", "brood": "normal"}, extra := {}) -> WWWar:
	var s := {"players": players, "seed": 77, "name": "test_war"}
	s.merge(extra, true)
	return WWWar.make(s)


func _run() -> void:
	await process_frame
	_data()
	_setup()
	_turns()
	_save_load()
	_climate()
	_upkeep_unrest()
	_battle_rules()
	await _fight_it()
	await _menu()
	_texts()
	WWWar.delete_war("test_war")
	WWWar.delete_war("test_war2")
	print("world war: %d failures" % fails)
	quit(1 if fails > 0 else 0)


func _data() -> void:
	var rs := WWRules.region_list()
	check("40-60 regions", rs.size() >= 40 and rs.size() <= 60, rs.size())
	var bad: Array = []
	var biomes := ["temperate", "cold", "wet", "jungle", "desert"]
	for r in rs:
		var id := String(r["id"])
		if not biomes.has(String(r["biome"])) or (r["shape"] as Array).is_empty() or WWRules.neighbours(id).is_empty():
			bad.append(id)
		for n in r["land"]:
			if not WWRules.land_nb(String(n)).has(id):
				bad.append(id + "-" + String(n))
		for n in r["sea"]:
			if not WWRules.sea_nb(String(n)).has(id) or not bool(r["port"]) or not bool(WWRules.region(String(n))["port"]):
				bad.append(id + "~" + String(n))
	check("every region: a biome, a shape, neighbours both ways, lanes between ports", bad.is_empty(), bad)
	check("15 key regions, the capitals among them", WWRules.key_regions().size() == 15 and WWRules.CAPITAL.values().all(func(c) -> bool: return WWRules.is_key(c)), WWRules.key_regions())
	# every region can be reached from every capital
	var w := _war()
	var all := true
	for f in WWRules.FACTIONS:
		all = all and w.hops(f).size() == rs.size()
	check("every region reachable from every capital", all, "")
	var named := ["rome", "lisbon", "paris", "nuremberg", "vienna", "virginia", "new_spain", "amazon", "rio", "luanda", "goa", "manila", "nagasaki"]
	check("the places asked for are regions", named.all(func(n) -> bool: return not WWRules.region(n).is_empty()), "")


func _setup() -> void:
	var w := _war()
	var ok := true
	for f in WWRules.FACTIONS:
		ok = ok and w.owner(WWRules.CAPITAL[f]) == f and w.gold(f) >= 0
		for rid in WWRules.START[f]:
			ok = ok and w.owner(rid) == f
		ok = ok and w.armies_of(f).size() == 1 and String(w.armies_of(f)[0]["at"]) == WWRules.CAPITAL[f]
	check("each side holds its start and has its army at its capital", ok, "")
	var worth := {}
	for f in WWRules.FACTIONS:
		worth[f] = w.land_worth(f)
	check("the starts are close in worth (7-9)", worth.values().all(func(v) -> bool: return int(v) >= 7 and int(v) <= 9), worth)
	check("heroes with the Crown's and the Clockwork's armies, none with the Brood",
		w.heroes_with(String(w.armies_of("crown")[0]["id"])).size() == 3 and w.heroes_with(String(w.armies_of("clockwork")[0]["id"])) == ["hollweg"]
		and w.heroes_with(String(w.armies_of("brood")[0]["id"])).is_empty(), "")
	var w2 := _war({"crown": "you", "clockwork": "normal", "brood": "off"})
	check("a side left out: its lands free, no army", w2.owner("amazon") == "" and w2.armies_of("brood").is_empty() and w2.d["order"] == ["crown", "clockwork"], w2.d["order"])
	check("a war begins on the first side's turn with its report", w2.current() == "crown" and not (w2.d["report"] as Array).is_empty(), w2.d["report"])
	# move rules
	var a: Dictionary = w2.armies_of("crown")[0]
	var mv := w2.moves_for(String(a["id"]))
	check("an army may go to its land and sea neighbours", mv.size() == WWRules.neighbours("rome").size(), mv)
	check("a march to a region not next to it is refused", String(w2.move(String(a["id"]), "amazon")["kind"]) == "refused", "")
	var res := w2.move(String(a["id"]), "lisbon")
	check("a march into free land is a battle with its militia", ["fought", "battle"].has(String(res["kind"])) and bool(a["moved"]), res.get("kind"))
	check("one march a season", w2.moves_for(String(a["id"])).is_empty(), "")


func _turns() -> void:
	var w := _war({"crown": "normal", "clockwork": "normal", "brood": "normal"}, {"seasons": 24})
	var guard := 0
	while String(w.d["winner"]) == "" and guard < 2000:
		WWAI.play_turn(w)
		w.end_turn()
		guard += 1
	check("computers' turns with auto-resolve run to a winner (by the last season, 24)", String(w.d["winner"]) != "" and int(w.d["season"]) <= 24, [w.d["winner"], w.d["season"]])
	var w2 := _war({"crown": "hard", "clockwork": "hard", "brood": "hard"}, {"win": "capitals", "seasons": 0})
	w2.d["factions"]["clockwork"]["out"] = true
	w2.d["factions"]["brood"]["out"] = true
	check("the last side left wins", w2.check_win() == "crown", w2.d["winner"])
	var w3 := _war({"crown": "normal", "clockwork": "normal", "brood": "normal"}, {"win": "keys"})
	for rid in WWRules.key_regions().slice(0, 8):
		w3.d["regions"][rid]["owner"] = "brood"
	w3.d["regions"]["amazon"]["owner"] = "brood"
	check("8 key regions win a KEY REGIONS war", w3.check_win() == "brood", w3.d["winner"])
	# a capital taken: the side is out
	var w4 := _war()
	var cw: Dictionary = w4.armies_of("clockwork")[0]
	w4.d["armies"].erase(String(w4.armies_of("crown")[0]["id"]))
	cw["at"] = "milan"
	cw["units"] = {"clock_soldier": 70, "pendulum": 10}
	w4.d["turn"] = w4.d["order"].find("clockwork")
	cw["moved"] = false
	var r := w4.move(String(cw["id"]), "rome")
	check("taking a capital puts its side out of the war", not w4.alive("crown") and w4.owner("rome") == "clockwork" and w4.regions_of("crown").is_empty(), [r.get("text"), w4.alive("crown")])


func _save_load() -> void:
	var w := _war()
	for i in 7:
		WWAI.play_turn(w)
		w.end_turn()
	check("a war saves", w.save(), "")
	var l := WWWar.load_from(WWWar.path_of("test_war"))
	check("and loads", l != null, "")
	var a := _norm(w.d)
	var b := _norm(l.d)
	check("the loaded war is the same", a == b, [a.length(), b.length()])
	for i in 9:
		WWAI.play_turn(w)
		w.end_turn()
		WWAI.play_turn(l)
		l.end_turn()
	w.d.erase("saved")
	l.d.erase("saved")
	check("and goes on the same (the dice kept)", _norm(w.d) == _norm(l.d), [w.d["season"], l.d["season"]])
	check("saved wars are listed", WWWar.saved_wars().any(func(x) -> bool: return String(x["name"]) == "test_war"), "")


## (saved as JSON every number is read back as a float: compared as written)
func _norm(d: Dictionary) -> String:
	return JSON.stringify(JSON.parse_string(JSON.stringify(d)))


func _turn_of(w: WWWar, f: String) -> void:
	w.d["turn"] = (w.d["order"] as Array).find(f)


func _climate() -> void:
	var w := _war()
	var br: Dictionary = w.armies_of("brood")[0]
	br["at"] = "patagonia"
	br["units"] = {"raptor": 100}
	w.d["season"] = 1
	_turn_of(w, "brood")
	w.begin_turn()
	check("the cold: a Brood army loses 30% a season", int(br["units"]["raptor"]) == 70, br["units"])
	w.d["season"] = 3
	w.begin_turn()
	check("in winter 45%", absi(int(br["units"]["raptor"]) - 38) <= 1, br["units"])
	# the Brood can't hold the cold
	br["units"] = {"raptor": 200, "brute": 10}
	br["at"] = "plata"
	br["moved"] = false
	w.d["regions"]["plata"]["owner"] = "brood"
	var res := w.move(String(br["id"]), "patagonia")
	check("a Brood win in the cold lays the land waste (free)", w.owner("patagonia") == "" and String(br["at"]) == "patagonia", res.get("text"))
	# rust
	var cw: Dictionary = w.armies_of("clockwork")[0]
	for h in w.heroes_with(String(cw["id"])):
		w.d["heroes"][h]["army"] = ""
	cw["at"] = "rhineland"
	cw["units"] = {"clock_soldier": 50}
	_turn_of(w, "clockwork")
	w.d["season"] = 1
	w.begin_turn()
	check("the wet: a Clockwork army rusts 10% a season", int(cw["units"]["clock_soldier"]) == 45, cw["units"])
	w.d["heroes"]["hollweg"]["army"] = String(cw["id"])
	w.begin_turn()
	check("Hollweg's army never rusts", int(cw["units"]["clock_soldier"]) == 45, cw["units"])
	cw["at"] = "saxony"
	w.begin_turn()
	check("no rust on temperate land", int(cw["units"]["clock_soldier"]) == 45, cw["units"])
	check("a Swamp makes the land wet", (func() -> bool:
		w.d["regions"]["minas"]["build"] = "swamp"
		return w.biome_now("minas") == "wet").call(), "")


func _upkeep_unrest() -> void:
	var w := _war()
	var f := "crown"
	var want := 0.0
	for a in w.armies_of(f):
		want += w.army_value(a) * (WWRules.UPKEEP + WWRules.UPKEEP_VET * int(a["vet"]))
	check("upkeep: 8% of the armies' worth", w.upkeep(f) == int(round(want)), [w.upkeep(f), want])
	# a far region costs more
	w.d["regions"]["goa"]["owner"] = f
	var far := WWRules.FAR_GOLD * (int(w.hops(f)["goa"]) - WWRules.FAR_HOPS)
	check("a far region adds its upkeep", w.upkeep(f) == int(round(want)) + far and far > 0, [w.upkeep(f), far])
	var cwu := w.upkeep("clockwork")
	var cwv := 0.0
	for a in w.armies_of("clockwork"):
		cwv += w.army_value(a) * 0.10
	check("the Clockwork's upkeep is 10% (it must be wound)", cwu == int(round(cwv)), [cwu, cwv])
	# income is bent: twice the land is not twice the gold
	var i1: int = w.income("crown")[1]
	for rid in ["paris", "brittany", "castile", "andalusia", "vienna", "hungary", "low_countries"]:
		w.d["regions"][rid]["owner"] = "crown"
	var raw2: int = w.income("crown")[0]
	var i2: int = w.income("crown")[1]
	check("income grows slower than the land (anti-snowball)", float(i2) / raw2 < float(i1) / maxf(1.0, float(w.income("clockwork")[0])) + 0.05 and i2 < raw2, [i1, i2, raw2])
	# unrest grows far away and a region may rise
	_turn_of(w, "crown")
	var u0 := float(w.d["regions"]["goa"]["unrest"])
	w.begin_turn()
	check("unrest grows in a far region with no army", float(w.d["regions"]["goa"]["unrest"]) > u0 or w.owner("goa") == "", w.d["regions"]["goa"]["unrest"])
	w.d["regions"]["goa"]["unrest"] = 100.0
	var rose := false
	for i in 12:
		w.begin_turn()
		if w.owner("goa") != "crown":
			rose = true
			break
		w.d["regions"]["goa"]["unrest"] = 100.0
	check("a region at 100 unrest rises and becomes free", rose and w.owner("goa") == "", w.owner("goa"))
	# a Church calms
	w.d["regions"]["paris"]["unrest"] = 30.0
	w.d["regions"]["paris"]["build"] = "church"
	w.begin_turn()
	check("a Church calms its region", float(w.d["regions"]["paris"]["unrest"]) < 30.0, w.d["regions"]["paris"]["unrest"])
	# empty treasury: soldiers desert
	w.d["factions"]["crown"]["gold"] = -100000
	var a: Dictionary = w.armies_of("crown")[0]
	a["units"] = {"musketeer": 100}
	for rid in w.regions_of("crown"):
		if rid != "rome":
			w.d["regions"][rid]["owner"] = ""
	w.d["factions"]["crown"]["gold"] = 0
	a["units"] = {"musketeer": 300}
	w.begin_turn()
	check("an unpaid army deserts (15%)", int(a["units"].get("musketeer", 0)) < 300, a["units"])


func _battle_rules() -> void:
	var w := _war()
	var cr: Dictionary = w.armies_of("crown")[0]
	cr["units"] = {"musketeer": 10}
	var cw: Dictionary = w.armies_of("clockwork")[0]
	cw["at"] = "milan"
	var b := {"att": String(cw["id"]), "region": "rome", "att_f": "clockwork", "def_f": "crown", "defs": [String(cr["id"])]}
	var s := w.strengths(b)
	check("a capital's guard and walls count for the defender", float(s["guard"]) >= WWRules.CAPITAL_GUARD and float(s["def"]) > (600 + float(s["guard"])) * 1.3, s)
	# a building adds its defence
	w.d["regions"]["milan"]["build"] = "fort"
	var b2 := {"att": String(cw["id"]), "region": "milan", "att_f": "clockwork", "def_f": "crown", "defs": []}
	check("a Fort adds 400 to the guard", int(w.strengths(b2)["guard"]) == 2 * WWRules.GUARD + 400, w.strengths(b2))
	# veterans
	cr["vet"] = 2
	var s2 := w.strengths(b)
	check("veterans fight harder", float(s2["def"]) > float(s["def"]), [s["def"], s2["def"]])
	# a beaten army falls back home when it can
	var w2 := _war()
	_turn_of(w2, "clockwork")
	var att: Dictionary = w2.armies_of("clockwork")[0]
	att["at"] = "vienna"
	att["moved"] = false
	w2.d["regions"]["vienna"]["owner"] = "clockwork"
	var dfd: Dictionary = w2.armies_of("crown")[0]
	dfd["at"] = "milan"
	dfd["units"] = {"musketeer": 6}
	att["units"] = {"clock_soldier": 60}
	var res := w2.move(String(att["id"]), "milan")
	check("the stronger attacker wins and takes the region", w2.owner("milan") == "clockwork" and String(att["at"]) == "milan", res.get("text"))
	check("the beaten army fell back to its own land, or was lost", not w2.d["armies"].has(String(dfd["id"])) or ["rome", "lyon"].has(String(dfd["at"])), dfd.get("at"))
	check("the winner became a veteran", int(att["vet"]) == 1, att["vet"])


func _fight_it() -> void:
	var w := _war({"crown": "you", "clockwork": "hard", "brood": "normal"})
	var cr: Dictionary = w.armies_of("crown")[0]
	var cw: Dictionary = w.armies_of("clockwork")[0]
	cw["at"] = "milan"
	w.d["regions"]["milan"]["owner"] = "clockwork"
	cr["moved"] = false
	var res := w.move(String(cr["id"]), "milan")
	check("a battle between a player's army and an army is offered (FIGHT IT / AUTO-RESOLVE)", String(res["kind"]) == "battle", res.get("kind"))
	var wb := WWBattle.new()
	wb.war = w
	wb.battle = res["battle"]
	var page := WWPage.show_war(main, w)
	await process_frame
	wb.begin(main)
	await process_frame
	await process_frame
	var g: Game = main.game
	check("the battle is a skirmish on a map of the land's kind", g != null and WWBattle.MAPS[w.biome_now("milan")].has(g.map_id), g.map_id if g else null)
	var on := {0: {}, 1: {}}
	for u in g.units:
		if u.has_meta("ww"):
			on[u.team][u.kind] = int(on[u.team].get(u.kind, 0)) + 1
	check("the player's side has exactly its world-map army", JSON.stringify(on[0]) == JSON.stringify(cr["units"]), [on[0], cr["units"]])
	check("the foe has exactly its world-map army", JSON.stringify(on[1]) == JSON.stringify(cw["units"]), [on[1], cw["units"]])
	check("the foe is played by its side's computer at the war's level (Hard)", g.ais.size() == 1 and g.ais[0].difficulty == 2, g.ais.size())
	# some die, the player wins: the survivors go back
	var killed := 0
	for u in g.units:
		if u.team == 0 and u.kind == "musketeer" and killed < 5:
			u.dead = true
			killed += 1
		if u.team == 1 and u.has_meta("ww"):
			u.dead = true
	var left := int(cr["units"]["musketeer"]) - 5
	main._on_end(0)
	await create_timer(1.6).timeout
	check("after the battle the war's page is back", main.game == null and main.ww_battle == null and main.ui_layer.find_children("WorldWar", "WWPage", true, false).size() == 1, main.game)
	var cr2 := w.army(String(cr["id"]))
	check("the survivors are carried back (5 musketeers fewer; the region's guard may cost a few more)", not cr2.is_empty() and int(cr2["units"].get("musketeer", 0)) <= left and int(cr2["units"].get("musketeer", 0)) >= left - 3, [cr2.get("units"), left])
	check("the won battle takes the region (or the guard held)", String(cr2.get("at", "")) == "milan" or w.owner("milan") == "clockwork", [cr2.get("at"), w.owner("milan")])
	check("no skirmish CONTINUE save is left by the battle", SaveGame.peek().is_empty(), "")
	# leaving a battle: lost for the player
	var w2 := _war({"crown": "you", "clockwork": "normal", "brood": "normal"})
	w2.d["name"] = "test_war2"
	var a2: Dictionary = w2.armies_of("crown")[0]
	var c2: Dictionary = w2.armies_of("clockwork")[0]
	c2["at"] = "milan"
	w2.d["regions"]["milan"]["owner"] = "clockwork"
	var r2 := w2.move(String(a2["id"]), "milan")
	var wb2 := WWBattle.new()
	wb2.war = w2
	wb2.battle = r2["battle"]
	var before := w2.army_value(a2)
	wb2.begin(main)
	await process_frame
	main._quit_match()
	await process_frame
	check("leaving the battle loses it: the army falls back, smaller", w2.owner("milan") == "clockwork" and (w2.army(String(a2["id"])).is_empty() or w2.army_value(w2.army(String(a2["id"]))) < before), w2.army(String(a2["id"])).get("at"))


func _menu() -> void:
	main.show_menu()
	await process_frame
	main.menu_buttons["worldwar"].pressed.emit()
	await process_frame
	var start: Button = main.ui_layer.find_child("WW_Start", true, false)
	check("WORLD WAR opens the setup page with START THE WAR", start != null, "")
	WWPage.setup["players"] = {"crown": "you", "clockwork": "easy", "brood": "easy"}
	start.pressed.emit()
	await process_frame
	var pages: Array = main.ui_layer.find_children("WorldWar", "WWPage", true, false)
	check("START THE WAR opens the war's map", pages.size() == 1, pages.size())
	var p: WWPage = pages[0]
	var name := String(p.war.d["name"])
	await process_frame
	p._close_overlay()
	var endb: Button = p.find_child("WW_EndTurn", true, false)
	endb.pressed.emit()
	var t := 0
	while (p.busy or p.war.current() != "crown") and t < 400:
		await process_frame
		t += 1
	check("END TURN: the computers play and it is the player's turn again, a season on", p.war.current() == "crown" and int(p.war.d["season"]) == 1 and not p.busy, [p.war.current(), p.war.d["season"], t])
	check("the war was saved at the end of the turn", FileAccess.file_exists(WWWar.path_of(name)), name)
	p._close_overlay()
	var hl: Button = p.find_child("WW_HELP", true, false)
	hl.pressed.emit()
	await process_frame
	check("HELP opens", p.find_child("WW_Help", false, false) != null, "")
	WWWar.delete_war(name)


## Every text of the mode has its pt and es lines (the strings in Loc.t("...") and the buttons' and headings' words).
func _texts() -> void:
	var re := RegEx.create_from_string("(?:Loc\\.t\\(|_button\\(|heading\\(|UiStyle\\.text\\()\"((?:[^\"\\\\]|\\\\.)+)\"")
	var re2 := RegEx.create_from_string("\"(?:name|gift)\": \"((?:[^\"\\\\]|\\\\.)+)\"")
	var keys := {}
	for fn in ["ww_page.gd", "ww_war.gd", "ww_rules.gd", "ww_map.gd", "ww_battle.gd"]:
		var src := FileAccess.get_file_as_string("res://scripts/worldwar/" + fn)
		for m in re.search_all(src):
			keys[m.get_string(1).c_unescape()] = true
		for m in re2.search_all(src):
			keys[m.get_string(1).c_unescape()] = true
		# the war's own lines (the log, the reports, the refusals): every string with a space in ww_war.gd
		if fn == "ww_war.gd":
			for line in src.split("\n"):
				if line.strip_edges().begins_with("#"):
					continue
				for m in RegEx.create_from_string("\"((?:[^\"\\\\]|\\\\.)*)\"").search_all(line):
					var k := m.get_string(1)
					if k.contains(" ") and k.strip_edges() != "" and not k.begins_with("res:") and not k.begins_with("user:"):
						keys[k.c_unescape()] = true
	for k in WWPage.WHO_LABEL.values() + WWPage.WIN_LABEL.values() + WWPage.BIOME_WORDS.values() + WWRules.NAME.values() + WWRules.UNIT_NAME.values() + WWRules.SEASONS:
		keys[k] = true
	for it in WWPage.HELP:
		keys[it[0]] = true
		keys[it[1]] = true
	for r in WWRules.region_list():
		keys[String(r["name"])] = true
	var miss: Array = []
	for k in keys:
		if k.strip_edges() == "" or k == "X" or k == "-" or k == "+" or k == "%s, %s" or k == "OK":
			continue
		for lang in ["pt", "es"]:
			if not Loc.table(lang).has(k) and not miss.has(k):
				miss.append(k)
	check("every text of the mode has pt and es (%d texts)" % keys.size(), miss.is_empty(), miss.slice(0, 12))
