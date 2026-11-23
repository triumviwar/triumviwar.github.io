extends SceneTree
## THE HUBS THAT GROW (job hubs-grow, docs/hubs_grow.md): campaign/hubs_grow.json checks out (every room's painting and
## every person's cut-out loads, every text has pt and es), a made-up progress shows the right rooms, people and
## hotspots by the missions finished and their flags (Varenne spared or executed, Jakob alive or lost, the map drawn or
## withheld, the Machine's City), the NEW marks come and go, the purse is earned once per mission (the best run), the
## counters buy, choose and pick, the loadout reaches only the line's own missions on their own side, and in a real
## mission start an upgrade changes the unit and the company called comes in (and nothing without them). The hub page
## with its room tabs, a room, a shop and the briefing's list are built through the real menu.
##   godot --headless --fixed-fps 30 --script res://tools/test_hubs_grow.gd
## Prints CHECK lines, then "hubs-grow: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
var main: Node
var fails := 0
var _kept := ""


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-72s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	if FileAccess.file_exists(Campaign.PROGRESS):
		_kept = FileAccess.get_file_as_string(Campaign.PROGRESS)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _done() -> void:
	if _kept != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept)
		f.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	print("hubs-grow: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## A progress with these missions finished: {id: {flag: value}} (side: the mission's own; "side" in the flags overrides).
func _prog(done: Dictionary, hub := {}) -> Dictionary:
	var p := {"reached": [], "done": {}}
	for mid in done:
		var fl: Dictionary = (done[mid] as Dictionary).duplicate()
		var side := String(fl.get("side", Campaign.seat_side(Campaign.mission(mid), "solo", "p1")))
		fl.erase("side")
		p["done"][mid] = {"won_by": side, "side": side, "mode": "solo", "played": 1, "flags": fl}
	if not hub.is_empty():
		p["hub"] = hub
	return p


func _ids(a: Array) -> Array:
	return a.map(func(x: Dictionary) -> String: return String(x["id"]))


func _run() -> void:
	await create_timer(0.3).timeout
	_data()
	_rooms_people()
	_marks_and_purse()
	_loadout()
	await _in_match()
	await _menu()
	_done()


func _data() -> void:
	var d := HubGrow.data()
	check("hubs_grow.json loads", not d.is_empty() and d.has("rooms") and d.has("people"))
	for r in d["rooms"]:
		var hs := HubScene.make(String(r["scene"]))
		check("room %s: its painting loads" % r["id"], hs.ok())
		hs.free()
	for pe in d["people"]:
		check("person %s: the cut-out exists" % pe["id"], ResourceLoader.exists(String(pe["image"])))
		check("person %s: has a talk" % pe["id"], not HubGrow.talk(String(pe.get("talk", ""))).is_empty())
	for hs in d["rooms"].reduce(func(acc: Array, r: Dictionary) -> Array: return acc + r["hotspots"], []):
		if String(hs.get("kind", "")) == "talk":
			check("hotspot %s: its talk exists" % hs["id"], not HubGrow.talk(String(hs["talk"])).is_empty())
	var miss: Array = []
	for t in HubGrow.strings():
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every hubs-grow text has pt and es", miss.is_empty(), " | ".join(miss))
	# every unit kind named in an offer is a real one
	var bad: Array = []
	for k in ["upgrades", "blessings", "choices"]:
		for o in d[k]:
			var ms: Array = [o.get("mods", {})]
			if k == "choices":
				ms = [o["a"].get("mods", {}), o["b"].get("mods", {})]
			for m in ms:
				for kind in m:
					if not Defs.UNITS.has(kind):
						bad.append(kind)
	for h in d["helpers"]:
		if not Defs.UNITS.has(String(h["kind"])):
			bad.append(h["kind"])
	check("every kind in the offers is a unit", bad.is_empty(), str(bad))


func _rooms_people() -> void:
	# THE CROWN: nothing before the Prologue, the armoury and chapel after it, the gallery after Paris
	var p := _prog({})
	check("before the Prologue: only the study", _ids(HubGrow.rooms_now("prologue", p)) == ["study"])
	p = _prog({"p01_leaf": {"families": "save"}})
	check("after the Prologue: the armoury and the chapel open", _ids(HubGrow.rooms_now("prologue", p)) == ["study", "armoury", "chapel"])
	check("after the Prologue: Ruggieri in the armoury", _ids(HubGrow.people_now("prologue", "armoury", p)) == ["ruggieri"])
	check("after the Prologue: no Fairleigh in the study yet", HubGrow.people_now("prologue", "study", p).is_empty())
	var vt := HubGrow.talk_lines(HubGrow.talk("votive"), p)
	check("the votive candles remember the families saved", vt.size() == 1 and String(vt[0]).find("Hollins") >= 0)
	p = _prog({"p01_leaf": {}, "a01_presses": {"lyon": "calm", "printer": "taken"}, "a06_barricades": {"varenne": "spared"}})
	check("after Paris: the gallery opens", _ids(HubGrow.rooms_now("prologue", p)).has("gallery"))
	check("after Paris: Fairleigh in the study", _ids(HubGrow.people_now("prologue", "study", p)) == ["fairleigh"])
	check("after Lyon: Delorme in the armoury", _ids(HubGrow.people_now("prologue", "armoury", p)).has("delorme"))
	var gh := _ids(HubGrow.hotspots_now("prologue", "gallery", p))
	check("Varenne spared: his letter, no sentence; the type case taken", gh.has("varenne_letter") and not gh.has("sentence") and gh.has("type_case"), str(gh))
	p = _prog({"p01_leaf": {}, "a01_presses": {"lyon": "sullen"}, "a06_barricades": {"varenne": "executed"}})
	gh = _ids(HubGrow.hotspots_now("prologue", "gallery", p))
	check("Varenne executed: the sentence, no letter; no type case without the printer", gh.has("sentence") and not gh.has("varenne_letter") and not gh.has("type_case"), str(gh))
	var dl := HubGrow.talk_lines(HubGrow.talk("delorme"), p)
	check("Delorme's talk follows Lyon's temper (sullen)", dl.size() == 1 and String(dl[0]).find("sullen") >= 0)
	check("the Council's decree only after Rome", not gh.has("council_decree"))
	# THE CLOCKMAKER: Jakob by his flags; the Machine's City has no guild rooms
	p = _prog({"c01_thirteenth": {"jakob": "alive", "drawings": "taken"}})
	check("c01, Jakob alive: in the barn; the yard open", _ids(HubGrow.people_now("clockmaker", "workshop", p)) == ["jakob"]
		and _ids(HubGrow.rooms_now("clockmaker", p)) == ["workshop", "yard"])
	p = _prog({"c01_thirteenth": {"jakob": "lost"}})
	check("c01, Jakob lost: not in the barn", HubGrow.people_now("clockmaker", "workshop", p).is_empty())
	p = _prog({"c01_thirteenth": {"jakob": "alive"}, "a02_furth": {"jakob": "lost", "furth": "thin", "stopwork": "fitted"}})
	check("a02, Jakob lost there: gone; von Rauch in the yard; the Honest One stands", HubGrow.people_now("clockmaker", "workshop", p).is_empty()
		and _ids(HubGrow.people_now("clockmaker", "yard", p)).has("rauch") and _ids(HubGrow.hotspots_now("clockmaker", "yard", p)).has("honest_one"))
	p = _prog({"c01_thirteenth": {"jakob": "alive"}, "a02_furth": {"side": "machine", "furth": "fallen"}})
	check("the Machine's City: no guild rooms", _ids(HubGrow.rooms_now("clockmaker", p)) == ["workshop"])
	p = _prog({"c01_thirteenth": {}, "a02_furth": {"furth": "strong"}, "a04_visit": {"broken": "melted"}})
	var yh := _ids(HubGrow.hotspots_now("clockmaker", "yard", p))
	check("a04, the broken ones melted: the ingot, not the tarpaulin", yh.has("broken_melted") and not yh.has("broken_kept"))
	check("a04: Ferrer in the barn, Anselm in the yard", _ids(HubGrow.people_now("clockmaker", "workshop", p)).has("ferrer")
		and _ids(HubGrow.people_now("clockmaker", "yard", p)).has("anselm"))
	# THE NATURALIST: Pieter by b01 and a05, the chart room only with the map drawn
	p = _prog({"b01_specimen": {"pieter": "alive"}})
	check("b01, Pieter alive: at the warehouse table; the store open", _ids(HubGrow.people_now("naturalist", "station", p)) == ["pieter"]
		and _ids(HubGrow.rooms_now("naturalist", p)) == ["station", "store"])
	p = _prog({"b01_specimen": {"pieter": "alive"}, "a03_plateau": {"map": "withheld"}})
	check("a03, the map withheld: no chart room, no Valadares", not _ids(HubGrow.rooms_now("naturalist", p)).has("chart"))
	p = _prog({"b01_specimen": {"pieter": "alive"}, "a03_plateau": {"map": "drawn"}, "a05_specimens": {"pieter": "lost", "cages": "few"}})
	check("a03 map drawn: the chart room and Valadares", _ids(HubGrow.rooms_now("naturalist", p)).has("chart")
		and _ids(HubGrow.people_now("naturalist", "chart", p)) == ["valadares"])
	check("a05, Pieter lost: gone from the table", HubGrow.people_now("naturalist", "station", p).is_empty())
	var cg := HubGrow.talk_lines(HubGrow.talk("cages"), p)
	check("the cages remember a05's cages (few)", cg.size() == 1 and String(cg[0]).find("empty") >= 0)
	# a person's hotspot sits on his cut-out (fractions of the room)
	var ph := HubGrow.people_hotspots("naturalist", "chart", p)
	check("a person's hotspot is on his layer", ph.size() == 1 and String(ph[0]["layer"]) == "p_valadares" and float(ph[0]["rect"][2]) > 0.05)


func _marks_and_purse() -> void:
	var p := _prog({"p01_leaf": {}})
	Campaign.save_progress(p)
	var news := HubGrow.news("prologue", Campaign.progress())
	check("NEW: the two rooms and Ruggieri are news", news.size() == 3, str(news.map(func(n): return n["key"])))
	HubGrow.mark_seen(["room:prologue:armoury", "person:prologue:ruggieri"])
	news = HubGrow.news("prologue", Campaign.progress())
	check("NEW: seen ones go", news.size() == 1 and String(news[0]["key"]) == "room:prologue:chapel")
	check("NEW: the armoury still has new offers", HubGrow.room_is_new("prologue", "armoury", Campaign.progress()))
	# the purse: the Prologue won with 1 optional objective = 3; played again with fewer, nothing more; with more, the difference
	var a := HubGrow.award("p01_leaf", "crown", true, 1, "solo")
	check("earned: the Prologue's win + 1 optional = 3", int(a.get("got", 0)) == 3 and int(a.get("new", 0)) == 3 and HubGrow.purse("prologue") == 3)
	a = HubGrow.award("p01_leaf", "crown", true, 0, "solo")
	check("earned: a worse run adds nothing", int(a.get("new", -1)) == 0 and HubGrow.purse("prologue") == 3)
	check("earned: a loss earns nothing", HubGrow.award("a01_presses", "crown", false, 2, "solo").is_empty())
	check("earned: the other side earns nothing (the Assembly)", HubGrow.award("a01_presses", "assembly", true, 1, "versus").is_empty())
	check("earned: a mirror earns nothing (the nest)", HubGrow.award("a03_plateau", "nest", true, 0, "solo").is_empty())
	check("buy: too dear", HubGrow.buy("cr_breastplates") != "")      # (not open before Lyon)
	check("buy: Paper Cartridges for 3", HubGrow.buy("cr_cartridges") == "" and HubGrow.purse("prologue") == 0 and HubGrow.bought("cr_cartridges"))
	check("buy: not twice", HubGrow.buy("cr_cartridges") != "")
	check("buy: no favour left", HubGrow.buy("cr_boots") != "")
	check("choice: closed before 4 earned", HubGrow.choose("crc_line", "a") != "")
	HubGrow.award("a01_presses", "crown", true, 1, "solo")
	check("earned: Lyon on its own side (3 more)", HubGrow.earned("prologue") == 6)
	var pr := Campaign.progress()
	pr["done"]["a01_presses"] = {"won_by": "crown", "side": "crown", "mode": "solo", "played": 1, "flags": {"lyon": "calm"}}
	Campaign.save_progress(pr)
	check("choice: open at 4, the Steady Line", HubGrow.choose("crc_line", "a") == "")
	check("blessing: Saint Barbara", HubGrow.pick("blessings", "prologue", "bl_barbara") == "" and HubGrow.picked("blessings", "prologue") == "bl_barbara")
	check("company: Delorme's riders", HubGrow.pick("helpers", "prologue", "h_delorme") == "" and HubGrow.picked("helpers", "prologue") == "h_delorme")
	check("company: not one not met yet (Ruggieri's crew)", HubGrow.pick("helpers", "prologue", "h_ruggieri") != "")


func _loadout() -> void:
	var lo := HubGrow.loadout("a06_barricades")
	var mm: Dictionary = lo["mods"].get("musketeer", {})
	check("a06's loadout: cartridges x1.10, Steady Line x1.12", is_equal_approx(float(mm.get("damage", 0)), 1.10) and is_equal_approx(float(mm.get("hp", 0)), 1.12), str(mm))
	check("a06's loadout: Saint Barbara on the guns", is_equal_approx(float(lo["mods"].get("cannon", {}).get("damage", 0)), 1.08))
	check("a06's loadout: Delorme's riders called", String(lo["helper"].get("id", "")) == "h_delorme")
	check("a06's loadout: the briefing lists 4 things", HubGrow.brief_lines("a06_barricades").size() == 4, str(HubGrow.brief_lines("a06_barricades")))
	check("the Prologue itself gets nothing (the first mission)", HubGrow.loadout("p01_leaf")["line"] == "")
	check("another line's mission gets nothing (a02)", (HubGrow.loadout("a02_furth")["mods"] as Dictionary).is_empty())
	check("a mirror side gets nothing (a03's nest)", HubGrow.loadout("a03_plateau", "nest")["line"] == "")


## A real mission start (Lyon, solo): the musketeers hit harder, and two Horsemen more come in; then the same start with
## the hub's things put back: nothing changes.
func _in_match() -> void:
	main.start(Campaign.make_cfg("a01_presses", "solo", "p1", false))
	await process_frame
	await process_frame
	var g: Game = main.game
	var t := int(g.mission.player_teams.keys()[0])
	var mus: Array = g.units.filter(func(u: Unit) -> bool: return u.team == t and u.kind == "musketeer" and not u.dead)
	check("in the match: a musketeer hits 10% harder", not mus.is_empty() and is_equal_approx(float(mus[0].d["damage"]), float(Defs.UNITS["musketeer"]["damage"]) * 1.10),
		str(mus[0].d["damage"]) if not mus.is_empty() else "none")
	check("in the match: his health 12% more (the Steady Line)", not mus.is_empty() and is_equal_approx(mus[0].max_hp, float(Defs.UNITS["musketeer"]["hp"]) * 1.12))
	check("in the match: the Defs are untouched", is_equal_approx(float(Defs.UNITS["musketeer"]["damage"]), 20.0))
	var cu := g.units.filter(func(u: Unit) -> bool: return u.team == t and u.kind == "cuirassier" and not u.dead).size()
	var helpers := g.units.filter(func(u: Unit) -> bool: return u.team == t and String(u.get_meta("mission_name", "")) == "DELORME'S RIDERS").size()
	check("in the match: Delorme's two riders came in", helpers == 2, "cuirassiers %d" % cu)
	var foe := g.units.filter(func(u: Unit) -> bool: return u.team != t and u.kind == "musketeer" and not u.dead)
	check("in the match: other teams untouched", foe.is_empty() or is_equal_approx(float(foe[0].d["damage"]), 20.0))
	main._to_menu()
	await process_frame
	var p := Campaign.progress()
	p.erase("hub")
	Campaign.save_progress(p)
	main.start(Campaign.make_cfg("a01_presses", "solo", "p1", false))
	await process_frame
	await process_frame
	g = main.game
	t = int(g.mission.player_teams.keys()[0])
	mus = g.units.filter(func(u: Unit) -> bool: return u.team == t and u.kind == "musketeer" and not u.dead)
	check("without the hub's things: a plain musketeer", not mus.is_empty() and is_equal_approx(float(mus[0].d["damage"]), 20.0))
	check("without the hub's things: no riders called", g.units.filter(func(u: Unit) -> bool: return String(u.get_meta("mission_name", "")) == "DELORME'S RIDERS").is_empty())
	main._to_menu()
	await process_frame


## Through the real menu: the hub's room tabs, the NEW line, a room with its counter, buying there, the briefing's list.
func _menu() -> void:
	var p := _prog({"p01_leaf": {"families": "save"}, "a01_presses": {"lyon": "calm", "printer": "taken"}})
	p["hub"] = {"earned": {"p01_leaf": 3, "a01_presses": 3}}
	Campaign.save_progress(p)
	CampaignMenu.line = "prologue"
	HubRoomsUi.room_of = {}
	main.show_campaign()
	await process_frame
	check("menu: the room tabs", main.menu.find_child("Room_armoury", true, false) != null and main.menu.find_child("Room_chapel", true, false) != null)
	var nl: Label = main.menu.find_child("HubNews", true, false)
	check("menu: the NEW line says who joined", nl != null and nl.text.find("Ruggieri") >= 0)
	(main.menu.find_child("Room_armoury", true, false) as Button).pressed.emit()
	await process_frame
	check("menu: the armoury shows Ruggieri and Delorme", main.menu.find_child("HotspotList_p_ruggieri", true, false) != null
		and main.menu.find_child("HotspotList_p_delorme", true, false) != null)
	var hs: HubScene = null
	for n in main.menu.find_children("*", "HubScene", true, false):
		hs = n
	check("menu: their cut-outs are layers of the room", hs != null and hs._tex.has("p_ruggieri") and hs._tex.has("p_delorme"))
	(main.menu.find_child("HotspotList_racks", true, false) as Button).pressed.emit()
	await process_frame
	var buy: Button = main.menu.find_child("Buy_cr_breastplates", true, false)
	check("menu: the racks' counter offers the breastplates", buy != null and not buy.disabled)
	buy.pressed.emit()
	await process_frame
	check("menu: bought (6 - 3 = 3 left)", HubGrow.bought("cr_breastplates") and HubGrow.purse("prologue") == 3)
	(main.menu.find_child("HotspotList_p_ruggieri", true, false) as Button).pressed.emit()
	await process_frame
	var tt: Label = main.menu.find_child("TalkText", true, false)
	check("menu: Ruggieri talks", tt != null and tt.text.length() > 10)
	check("menu: talking marks him seen", HubGrow.seen("person:prologue:ruggieri"))
	CampaignMenu.briefing(main, "a06_barricades")
	await process_frame
	check("menu: the briefing lists what the hub gives", main.menu.find_child("BriefHub", true, false) != null)
	HubRoomsUi.room_of = {}
