extends SceneTree
## THE WAR MAP v1 (docs/war_map_v1.md): its data checks out (WarMapData.problems: every rule's region, mark and pin,
## every flag a real mission sets, every mission pinned), every text has pt and es, every pin's and region's state for
## the prologues' and Act 1's flags, every flag combination of the missions built so far draws a sound state, the map
## opens from the King's study (the war table hotspot) and from a war table, a tap on a seal opens its card, and a
## playable pin's BRIEFING starts its mission.
##   godot --headless --fixed-fps 30 --script res://tools/test_war_map.gd
## Prints CHECK lines, then "war map: N failures"; exit code 1 on a failure. (Leaves user://campaign.json as it was.)
var main: Node
var fails := 0
var _kept := ""


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
	print("war map: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## A progress with these missions done: {mission: [won_by, {flags}]}.
func _p(done: Dictionary) -> Dictionary:
	var p := {"reached": [], "done": {}}
	for mid in done:
		p["done"][mid] = {"won_by": done[mid][0], "side": done[mid][0], "flags": done[mid][1] if done[mid].size() > 1 else {}}
		if not Campaign.storyline_of(mid).is_empty():
			var nx := Campaign.next_of(mid, String(done[mid][0]))
			if nx != "":
				p["reached"].append(nx)
	return p


const PRO := {
	"p01_leaf": ["crown", {"families": "save"}],
	"c01_thirteenth": ["guild", {"bells": "rung", "saved": "many", "saved_n": 34, "jakob": "alive", "cut": "yes", "gate": "pattern"}],
	"b01_specimen": ["sire", {"teles": "quiet", "clutch": "saved", "saved": "some", "saved_n": 9, "pieter": "alive", "eggs": "taken"}],
}


func _with(extra: Dictionary) -> Dictionary:
	var d := PRO.duplicate(true)
	d.merge(extra, true)
	return _p(d)


func _data() -> void:
	var pr := WarMapData.problems()
	check("the war map's data checks out", pr.is_empty(), "; ".join(pr))
	check("the land loads (coasts, lakes, rivers)", WarMapData.land().get("land", []).size() > 20 and WarMapData.land().get("rivers", []).size() > 5)
	var miss: Array = []
	var page := ["THE LEDGER", "Nothing yet: the ledger fills as the missions are played.", "WHAT CAME OF IT", "Not written yet.",
		"Open: ready to play.", "WAR MAP", "LEDGER", "LIST", "CO-OP / VERSUS", "CLOSE",
		"Drag to move the map, the wheel or a pinch to zoom; tap a seal for its mission.", "Drag to move the map, pinch to zoom; tap a seal for its mission."]
	for t in WarMapData.strings() + page:
		if not LangPt.T.has(t) or not LangEs.T.has(t):
			miss.append(String(t).left(50))
	check("every war map text has pt and es", miss.is_empty(), " | ".join(miss))
	check("the Brood is the Ninhada / the Nidada (pt / es)", LangPt.T.get("The creatures'", "").contains("Ninhada") and LangEs.T.get("The creatures'", "").contains("Nidada"))
	# a planned mission's flag a rule names, checked: a typo in a built mission's flag is a problem
	var bad := {"if": {"flag": {"a03_plateau.maps": "drawn"}}, "ledger": "x"}
	(WarMapData.data()["rules"] as Array).append(bad)
	check("a rule naming a flag the mission never sets is caught", not WarMapData.problems().is_empty())
	(WarMapData.data()["rules"] as Array).erase(bad)


func _states() -> void:
	# ---- a new campaign: only the prologue is open
	var st := WarMapData.state(_p({}))
	var pins: Dictionary = st["pins"]
	check("new: the Prologue's pin is open", pins["p01_leaf"]["state"] == "open")
	check("new: the Clockmaker and Naturalist prologues open (owner 2026-11-18)", pins["c01_thirteenth"]["state"] == "open" and pins["b01_specimen"]["state"] == "open")
	check("new: a02 and a03 locked", pins["a02_furth"]["state"] == "locked" and pins["a03_plateau"]["state"] == "locked")
	check("new: a01 (built) locked until the Prologue", pins["a01_presses"]["state"] == "locked")
	check("new: a06 (built) locked until a01", pins["a06_barricades"]["state"] == "locked")
	check("new: a04 (built) locked until a02", pins["a04_visit"]["state"] == "locked")
	check("new: a05 (built) locked until a03", pins["a05_specimens"]["state"] == "locked")
	check("new: a07 (built, the crossing) locked until a04, a05 and a06", pins["a07_council"]["state"] == "locked")
	st = WarMapData.state(_p({"a04_visit": ["visit"], "a06_barricades": ["crown"]}))
	check("a07 still locked with a04 and a06 but not a05", st["pins"]["a07_council"]["state"] == "locked")
	st = WarMapData.state(_p({"a04_visit": ["visit"], "a05_specimens": ["expedition"], "a06_barricades": ["crown"]}))
	check("a07 open once all three are won", st["pins"]["a07_council"]["state"] == "open")
	st = WarMapData.state(_p({}))
	check("new: Virginia purple, Franconia the empire's, the plateau blank", st["regions"]["virginia"] == "crown" and st["regions"]["franconia"] == "empire" and st["regions"]["plateau"] == "unknown")
	check("new: no marks, an empty ledger", st["marks"].values().count(true) == 0 and (st["ledger"] as Array).is_empty())
	# ---- after the three prologues (the canon-ish run)
	st = WarMapData.state(_with({}))
	pins = st["pins"]
	check("prologues: p01 done with a whole seal", pins["p01_leaf"]["state"] == "done" and pins["p01_leaf"]["seal"] == "seal")
	check("prologues: Nuremberg's seal broken (the city lost)", pins["c01_thirteenth"]["state"] == "done" and pins["c01_thirteenth"]["seal"] == "broken")
	check("prologues: the station's seal broken (it burned)", pins["b01_specimen"]["seal"] == "broken")
	check("prologues: a02 and a03 open", pins["a02_furth"]["state"] == "open" and pins["a03_plateau"]["state"] == "open")
	check("prologues: a01 open (p01 leads to it)", pins["a01_presses"]["state"] == "open")
	check("prologues: Franconia red, Fürth purple", st["regions"]["franconia"] == "machine" and st["regions"]["furth"] == "crown")
	check("prologues: the loyal village (families saved)", st["marks"]["loyal_village"] and st["regions"]["virginia_interior"] == "empire")
	check("prologues: the loyal quarter in Nuremberg (many saved)", st["marks"]["loyal_quarter"])
	check("prologues: the burnt station, the question north, the Barra, Nazaré", st["marks"]["burnt_station"] and st["marks"]["plateau_question"] and st["marks"]["barra"] and st["marks"]["nazare"])
	var counted := (st["ledger"] as Array).filter(func(e: Dictionary) -> bool: return (e["args"] as Array).has("34"))
	check("prologues: the ledger counts the townsfolk (34)", counted.size() == 1 and WarMapData.ledger_text(counted[0]).contains("34"))
	check("prologues: the card's lines are the mission's own", WarMapData.ledger_of(st, "c01_thirteenth").size() >= 3 and WarMapData.ledger_of(st, "p01_leaf").size() == 2)
	# ---- the prologues' other values
	st = WarMapData.state(_with({"p01_leaf": ["crown", {"families": "leave"}]}))
	check("families left: the interior in unrest, no village", st["regions"]["virginia_interior"] == "unrest" and not st["marks"]["loyal_village"])
	st = WarMapData.state(_with({"p01_leaf": ["rebels", {}]}))
	check("the rebels won Virginia (versus): all Virginia in unrest, the seal broken", st["regions"]["virginia"] == "unrest" and st["pins"]["p01_leaf"]["seal"] == "broken")
	st = WarMapData.state(_with({"c01_thirteenth": ["guild", {"saved": "few", "saved_n": 3}]}))
	check("few saved: no loyal quarter", not st["marks"]["loyal_quarter"])
	# ---- a02 the Fürth Line
	for it in [["strong", "guild", "crown", "seal"], ["thin", "guild", "contested", "seal"], ["fallen", "machine", "machine", "broken"]]:
		st = WarMapData.state(_with({"a02_furth": [it[1], {"furth": it[0]}]}))
		check("a02 furth %s: Fürth %s, the seal %s" % [it[0], it[2], it[3]], st["regions"]["furth"] == it[2] and st["pins"]["a02_furth"]["seal"] == it[3]
			and st["pins"]["a04_visit"]["state"] == ("open" if it[1] == "guild" else "locked"))
	# ---- a03 the Lost Plateau
	st = WarMapData.state(_with({"a03_plateau": ["party", {"map": "drawn", "party": "some"}]}))
	check("a03 map drawn: the plateau drawn in (the creatures'), no question mark", st["regions"]["plateau"] == "brood" and not st["marks"]["plateau_question"])
	st = WarMapData.state(_with({"a03_plateau": ["party", {"map": "withheld", "party": "all"}]}))
	check("a03 map withheld: the plateau stays blank, the question stays", st["regions"]["plateau"] == "unknown" and st["marks"]["plateau_question"])
	st = WarMapData.state(_with({"a03_plateau": ["nest", {"plateau": "kept"}]}))
	check("a03 won by the nest: blank, the seal broken", st["regions"]["plateau"] == "unknown" and st["pins"]["a03_plateau"]["seal"] == "broken")
	# ---- the planned missions' rules (their flags as the plan names them)
	st = WarMapData.state(_with({"a01_presses": ["crown", {"lyon": "sullen"}]}))
	check("a01 lyon sullen: Lyon uneasy, the pin done", st["regions"]["lyon"] == "contested" and st["pins"]["a01_presses"]["state"] == "done")
	st = WarMapData.state(_with({"a01_presses": ["crown", {"lyon": "calm"}]}))
	check("a01 lyon calm: Lyon purple", st["regions"]["lyon"] == "crown")
	st = WarMapData.state(_with({"a01_presses": ["assembly", {"lyon": "risen"}]}))
	check("a01 won by the Assembly (versus): Lyon in unrest, the seal broken", st["regions"]["lyon"] == "unrest" and st["pins"]["a01_presses"]["seal"] == "broken")
	st = WarMapData.state(_with({"a01_presses": ["crown", {"lyon": "calm", "printer": "taken"}]}))
	check("a06 (built) open once a01 is won", st["pins"]["a06_barricades"]["state"] == "open")
	st = WarMapData.state(_with({"a06_barricades": ["assembly", {}]}))
	check("a06 won by the Assembly (versus): Paris in unrest, the seal broken", st["regions"]["paris"] == "unrest" and st["pins"]["a06_barricades"]["seal"] == "broken")
	st = WarMapData.state(_with({"a06_barricades": ["crown", {"varenne": "spared"}]}))
	check("a06 Varenne spared: Paris purple, his ship into exile", st["regions"]["paris"] == "crown" and st["marks"]["varenne_exile"] and st["regions"]["brittany"] == "empire")
	st = WarMapData.state(_with({"a06_barricades": ["crown", {"varenne": "executed"}]}))
	check("a06 Varenne executed: Paris marked, two risings", st["regions"]["paris"] == "contested" and st["regions"]["brittany"] == "unrest" and st["regions"]["provence"] == "unrest")
	st = WarMapData.state(_with({"a04_visit": ["visit", {"broken": "kept", "lost_to_machine": 5, "lost_to_machine_n": 5}]}))
	check("a04 many lost to the machine: the red spreads east", st["regions"]["franconia_more"] == "machine" and st["pins"]["a04_visit"]["state"] == "done")
	check("a04 kept: the ledger says so", WarMapData.ledger_of(st, "a04_visit").any(func(e) -> bool: return WarMapData.ledger_text(e).contains("kept for study")))
	st = WarMapData.state(_with({"a04_visit": ["visit", {"broken": "melted", "lost_to_machine": 1, "lost_to_machine_n": 1}]}))
	check("a04 few lost: no spread", st["regions"]["franconia_more"] == "empire")
	check("a04 melted: the ledger says so", WarMapData.ledger_of(st, "a04_visit").any(func(e) -> bool: return WarMapData.ledger_text(e).contains("melted")))
	# ---- every flag combination of the missions built so far: a sound state each
	var n := 0
	var bad: Array = []
	for fam in ["save", "leave"]:
		for sv in ["few", "some", "many"]:
			for bells in ["rung", "quiet"]:
				for bs in ["few", "some", "many"]:
					for a2 in [[], ["guild", "strong"], ["guild", "thin"], ["machine", "fallen"]]:
						for a3 in [[], ["party", "drawn"], ["party", "withheld"], ["nest", ""]]:
							var d := {"p01_leaf": ["crown", {"families": fam}],
								"c01_thirteenth": ["guild", {"saved": sv, "saved_n": 5, "bells": bells, "gate": "people", "jakob": "lost"}],
								"b01_specimen": ["sire", {"saved": bs, "saved_n": 4, "clutch": "burned"}]}
							if not a2.is_empty():
								d["a02_furth"] = [a2[0], {"furth": a2[1]}]
							if not a3.is_empty():
								d["a03_plateau"] = [a3[0], {"map": a3[1]} if a3[1] != "" else {"plateau": "kept"}]
							var s := WarMapData.state(_p(d))
							n += 1
							for k in s["regions"]:
								if not WarMapData.HOLDERS.has(String(s["regions"][k])):
									bad.append("%s=%s" % [k, s["regions"][k]])
							for k in s["pins"]:
								if not WarMapData.PIN_STATES.has(String(s["pins"][k]["state"])):
									bad.append("pin %s" % k)
							if s["regions"]["franconia"] != "machine" or (s["marks"]["loyal_quarter"] != (sv != "few")):
								bad.append("franconia/quarter %s" % sv)
							if s["regions"]["plateau"] != ("brood" if a3.size() > 1 and a3[1] == "drawn" else "unknown"):
								bad.append("plateau %s" % str(a3))
							for e in s["ledger"]:
								if WarMapData.ledger_text(e).contains("%"):
									bad.append("ledger " + String(e["text"]).left(30))
	check("every flag combination (%d) gives a sound map" % n, bad.is_empty(), " ".join(bad.slice(0, 8)))


func _wm() -> WarMap:
	for n in main.menu.find_children("*", "WarMap", true, false):
		return n
	for n in main.ui_layer.find_children("*", "WarMap", true, false):
		return n
	return null


func _find(nm: String) -> Node:
	return main.ui_layer.find_child(nm, true, false)


func _ui() -> void:
	Campaign.save_progress(_with({}))
	main.show_campaign()
	await process_frame
	var hs: Button = _find("Hotspot_war_table")
	check("the King's study: the war table hotspot", hs != null)
	if hs:
		hs.pressed.emit()
	await process_frame
	await process_frame
	var wm := _wm()
	check("the war table hotspot opens THE WAR MAP", wm != null and CampaignMenu.map_open)
	if wm == null:
		return
	await process_frame
	check("the map is sized and fitted", wm.size.x > 100 and wm.zoom > 0.5, "%s zoom %.2f" % [wm.size, wm.zoom])
	check("its views, LEDGER and LIST", _find("View_europe") != null and _find("View_amazon") != null and _find("WarMap_Ledger") != null and _find("WarMap_List") != null)
	check("the world opens on its Catholic painting", wm.painted == "world")
	check("TERRITORY on: the legend lists the holders over the painting", _find("WarLegend") != null and (_find("WarLegend") as Control).visible and WarMap.territory)
	var tc := wm._terr_build()
	check("the holders' stripes and flags are on the sheet", not (tc["fills"] as Array).is_empty() and not (tc["flags"] as Array).is_empty(), "%d fills, %d flags" % [tc["fills"].size(), tc["flags"].size()])
	(_find("WarMap_Territory") as Button).button_pressed = false
	await process_frame
	check("TERRITORY off: no legend, the painting clean", not WarMap.territory and not (_find("WarLegend") as Control).visible)
	(_find("WarMap_Territory") as Button).button_pressed = true
	await process_frame
	(_find("WarMap_Ledger") as Button).pressed.emit()
	await process_frame
	check("LEDGER folds out", (_find("WarLedger") as Control).visible)
	(_find("View_europe") as Button).pressed.emit()
	await create_timer(0.5).timeout
	check("EUROPE shows Europe's painting, whole", wm.painted == "europe" and absf(wm.zoom - wm.min_zoom()) < 0.01, "%s %.2f" % [wm.painted, wm.zoom])
	var rome := wm.to_screen(wm.geo([12.48, 41.9], "a07_council"))
	check("Rome stands in Italy on it", rome.x > wm.size.x * 0.5 and rome.y > wm.size.y * 0.5, str(rome))
	var z0 := wm.zoom
	wm.zoom_by(1.5)
	check("zoom in", wm.zoom > z0)
	# a locked pin: its card, no play button
	wm.tap(wm.pin_screen(WarMapData.pin_of("a07_council")))
	await process_frame
	var card: Control = _find("WarCard")
	check("a tap on Rome's seal opens its card", card != null and card.visible and CampaignMenu.map_pick == "a07_council")
	var cs: Label = _find("CardState")
	check("Rome: locked, opens after its three missions", cs != null and cs.text.contains(Loc.t("(locked)")) and _find("Card_Briefing") == null)
	# an open pin: BRIEFING
	wm.show_view("world", false)
	await process_frame
	wm.tap(wm.pin_screen(WarMapData.pin_of("a03_plateau")))
	await process_frame
	var br: Button = _find("Card_Briefing")
	check("the plateau's seal: open, with BRIEFING and CO-OP / VERSUS", br != null and _find("Card_Modes") != null)
	if br == null:
		return
	br.pressed.emit()
	await process_frame
	check("BRIEFING from the map: the mission's briefing, its line's hub behind", _find("Briefing_Start") != null and CampaignMenu.line == "naturalist" and CampaignMenu.pick == "a03_plateau")
	_press_back()
	await process_frame
	await process_frame
	check("BACK from the briefing: the map again, the pin still picked", _wm() != null and CampaignMenu.map_pick == "a03_plateau" and (_find("WarCard") as Control).visible)
	(_find("WarMap_List") as Button).pressed.emit()
	await process_frame
	check("LIST: the war table, with WAR MAP back", _find("Mission_a03_plateau") != null and _find("WarTable_Map") != null)
	(_find("WarTable_Map") as Button).pressed.emit()
	await process_frame
	check("WAR MAP from the war table", _wm() != null)
	# a tap on nothing closes the card
	wm = _wm()
	await process_frame
	wm.tap(Vector2(4, 4))
	await process_frame
	check("a tap on the sea: the card goes", not (_find("WarCard") as Control).visible)
	# BACK: the King's study again
	_press_back()
	await process_frame
	check("BACK: the hub it came from", _wm() == null and _find("Hotspot_war_table") != null and CampaignMenu.line == "prologue" and not CampaignMenu.map_open)
	# the other hubs: the map from their war table
	Campaign.open_all = true
	CampaignMenu.line = "clockmaker"
	CampaignMenu.war_table(main)
	await process_frame
	(_find("WarTable_Map") as Button).pressed.emit()
	await process_frame
	check("the Clockmaker's war table opens the map too", _wm() != null)
	Campaign.open_all = false
	# start a mission from a pin
	wm = _wm()
	await process_frame
	wm.tap(wm.pin_screen(WarMapData.pin_of("a02_furth")))
	await process_frame
	(_find("Card_Briefing") as Button).pressed.emit()
	await process_frame
	var go: Button = _find("Briefing_Start")
	check("a02 from its pin: the briefing", go != null and CampaignMenu.pick == "a02_furth")
	if go:
		go.pressed.emit()
		await process_frame
		await process_frame
		var shown := false
		for n in main.ui_layer.get_children():
			if n is StillShow:
				shown = true
				(n as StillShow).queue_free()
		check("START: the mission's opening plays (then the match)", shown or main.game != null)
		await process_frame
		main.start(Campaign.make_cfg("a02_furth", "solo"))
		await process_frame
		await process_frame
		check("the match from the pin is the Fürth Line", main.game != null and main.game.mission != null and main.game.mission.id == "a02_furth")
		main._to_menu()
		await process_frame


func _press_back() -> void:
	for b in main.ui_layer.find_children("*", "Button", true, false):
		if (b as Button).text == Loc.t("BACK") and (b as Button).is_visible_in_tree():
			(b as Button).pressed.emit()
			return


func _run() -> void:
	await process_frame
	_data()
	_states()
	_act2()
	await _ui()
	await _ui_act2()
	_finish()


# ------------------------------------------------------------------ ACT 2 (act2-warmap, docs/war_map_act2.md)

## Act 1 played through (the canon-ish run): Act 2's pins open from here.
const ACT1 := {
	"a02_furth": ["guild", {"furth": "strong"}],
	"a03_plateau": ["party", {"map": "drawn", "party": "some"}],
	"a01_presses": ["crown", {"lyon": "calm"}],
	"a06_barricades": ["crown", {"varenne": "spared"}],
	"a04_visit": ["visit", {"broken": "kept", "lost_to_machine": 2}],
	"a05_specimens": ["expedition", {"cages": "some", "cages_n": 2}],
	"a07_council": ["crown", {"rome": "some"}],
}

const ACT2_PINS := ["d01_minas", "d02_exodus", "d03_fazenda", "d04_concordia", "d05_aldeia", "d06_queen", "d07_spring",
	"d08_rivers", "d09_crossroads", "d10_jungle", "d11_siege", "d12_luanda", "d13_goa"]


func _act1(extra: Dictionary) -> Dictionary:
	var d := PRO.duplicate(true)
	d.merge(ACT1, true)
	d.merge(extra, true)
	return _p(d)


## Is a place (lon, lat) on land (Natural Earth's coasts, as the drawn map has them)?
func _on_land(pt: Array) -> bool:
	var q := WarMapData.pt(pt)
	for flat in WarMapData.land().get("land", []):
		if Geometry2D.is_point_in_polygon(q, WarMapData.ring(flat)):
			return true
	return false


func _act2() -> void:
	var d := WarMapData.data()
	# ---- the view, the act, the skins
	var vids: Array = (d["views"] as Array).map(func(v) -> String: return String(v["id"]))
	check("act 2: a BRAZIL view, second after THE WORLD", vids.size() >= 2 and vids[1] == "brazil")
	var br := WarMapData.rect_of(d["views"][1]["rect"])
	for pl in [[-43.5, -20.39], [-51.6, -27.3], [-55.5, -1.95], [-60.0, -3.1], [-38.5, -12.97]]:
		check("act 2: the Brazil view holds %s" % str(pl), br.has_point(WarMapData.pt(pl)))
	check("act 2: before Rome the map opens on THE WORLD, Act 1", WarMapData.act(_with({}))["view"] == "world" and int(WarMapData.act(_with({}))["act"]) == 1)
	var a2 := WarMapData.act(_act1({}))
	check("act 2: after Rome the map opens on BRAZIL, Act 2's title", a2["view"] == "brazil" and int(a2["act"]) == 2 and String(a2["act_title"]).begins_with("Act 2"))
	for sk in WarMapData.SKINS:
		var ok: bool = WarMap.SKINS.has(sk)
		for h in WarMapData.HOLDERS:
			if h != "empire" and ok and not (WarMap.SKINS[sk]["holders"] as Dictionary).has(h):
				ok = false
		check("skin %s: drawn, every holder has its colours" % sk, ok)
		check("skin %s: a title (%s)" % [sk, WarMapData.skin_title(sk)], WarMapData.skin_title(sk) != "")
	check("every skin shows its own painted sheets (the brass and chart with their own prefix)", WarMap.SKINS["parchment"]["paintings"] and WarMap.SKINS["brass"].get("paint_prefix", "") == "brass_" and WarMap.SKINS["chart"].get("paint_prefix", "") == "chart_")
	check("no Brood skin (owner 2026-11-22: no Brood war map, ever)", not WarMap.SKINS.has("brood") and not WarMap.SKINS.has("nest"))
	check("each line's hub reads its own skin", CampaignMenu.skin_for("prologue") == "parchment" and CampaignMenu.skin_for("clockmaker") == "brass" and CampaignMenu.skin_for("naturalist") == "chart")
	# ---- the pins: every Act 2 mission, on land, with a place, a date and what it is about
	var off: Array = []
	for mid in ACT2_PINS:
		var pn := WarMapData.pin_of(mid)
		if pn.is_empty():
			off.append(mid + " (no pin)")
			continue
		if not _on_land(pn["point"]):
			off.append(mid)
		if Campaign.storyline_of(mid).is_empty() and String(pn.get("about", "")) == "":
			off.append(mid + " (no about)")
	check("act 2: every pin (d01-d13) is there, on land, and a planned one says what it is about", off.is_empty(), " ".join(off))
	var moff: Array = []
	for mk in d["marks"]:
		if bool(mk.get("act2", false)) and String(mk["kind"]) != "route" and not _on_land(mk["point"]):
			moff.append(String(mk["id"]))
	check("act 2: its marks stand on land (the routes go by sea)", moff.is_empty(), " ".join(moff))
	# ---- states: Rome won opens the three lines' first Act 2 missions
	var st := WarMapData.state(_act1({}))
	check("act 2: after Rome d01, d02 and d03 (built) are open", st["pins"]["d01_minas"]["state"] == "open" and st["pins"]["d02_exodus"]["state"] == "open"
		and st["pins"]["d03_fazenda"]["state"] == "open")
	check("act 2: d05, d07, d08, d09, d10 and d11 (built) locked until the mission before", st["pins"]["d05_aldeia"]["state"] == "locked"
		and st["pins"]["d07_spring"]["state"] == "locked" and st["pins"]["d08_rivers"]["state"] == "locked" and st["pins"]["d09_crossroads"]["state"] == "locked"
		and st["pins"]["d10_jungle"]["state"] == "locked" and st["pins"]["d11_siege"]["state"] == "locked",
		"d08 %s d09 %s d10 %s d11 %s" % [st["pins"]["d08_rivers"]["state"], st["pins"]["d09_crossroads"]["state"], st["pins"]["d10_jungle"]["state"], st["pins"]["d11_siege"]["state"]])
	check("act 2: d05 open once d01 is won", WarMapData.state(_act1({"d01_minas": ["crown", {"minas": "quiet"}]}))["pins"]["d05_aldeia"]["state"] == "open")
	check("act 2: Salvador on the map once Brazil is unrolled", st["marks"]["salvador"] and not WarMapData.state(_with({}))["marks"]["salvador"])
	check("act 2: Brazil's regions start as the empire's", st["regions"]["minas"] == "empire" and st["regions"]["concordia"] == "empire" and st["regions"]["lower_amazon"] == "empire")
	# d02 won: the ships' line from Hamburg
	st = WarMapData.state(_act1({"d02_exodus": ["exodus", {"exodus": "some", "exodus_n": 5}]}))
	check("d02 won: the guild's ships from Hamburg (a line by sea)", st["marks"]["exodus_route"] and st["marks"]["hamburg"])
	# d01
	st = WarMapData.state(_act1({"d01_minas": ["crown", {"minas": "restless", "gold": "some", "conspirator": "fled"}]}))
	check("d01 restless: Minas uneasy, the conspirator's road south", st["regions"]["minas"] == "contested" and st["marks"]["ramos_road"])
	st = WarMapData.state(_act1({"d01_minas": ["crown", {"minas": "quiet", "gold": "all", "conspirator": "taken"}]}))
	check("d01 quiet: Minas purple, no road", st["regions"]["minas"] == "crown" and not st["marks"]["ramos_road"] and WarMapData.ledger_of(st, "d01_minas").size() == 4)
	st = WarMapData.state(_act1({"d01_minas": ["conspiracy", {}]}))
	check("d01 won by the conspiracy: Minas in unrest, the seal broken", st["regions"]["minas"] == "unrest" and st["pins"]["d01_minas"]["seal"] == "broken")
	# d04 / d07: Concórdia, and what each map knows
	var base := {"d02_exodus": ["exodus", {}], "d04_concordia": ["guild", {"colonists": "fought", "crates": "opened"}]}
	st = WarMapData.state(_act1(base))
	check("d04 won: Concórdia the free city's (blue), its gear and the mine", st["regions"]["concordia"] == "guild" and st["marks"]["concordia_city"] and st["marks"]["crates_mine"])
	check("d04 colonists fought: the valley uneasy", st["regions"]["valley"] == "contested")
	check("d04 with Varenne spared: his ship's line ends at Concórdia", st["marks"]["varenne_route"])
	var b7 := base.duplicate(true)
	b7["d07_spring"] = ["honest", {"spring": "running", "honest": "some"}]
	for sk in WarMapData.SKINS:
		check("d07 running, before d09: Concórdia still blue on the %s (what was known)" % sk, WarMapData.state(_act1(b7), sk)["regions"]["concordia"] == "guild")
	b7["d09_crossroads"] = ["crown", {"first": "brood", "sertao": "some"}]
	check("d07 running, after d09: the King's parchment shows Concórdia red", WarMapData.state(_act1(b7), "parchment")["regions"]["concordia"] == "machine")
	check("d07 running, after d09: the chart too", WarMapData.state(_act1(b7), "chart")["regions"]["concordia"] == "machine")
	check("d07 running, after d09: Hollweg's brass map never shows it red", WarMapData.state(_act1(b7), "brass")["regions"]["concordia"] == "guild")
	var b7s := base.duplicate(true)
	b7s["d07_spring"] = ["honest", {"spring": "stopped", "honest": "many"}]
	st = WarMapData.state(_act1(b7s))
	check("d07 stopped: red at once on the parchment, the honest masters at the coast", st["regions"]["concordia"] == "machine" and st["marks"]["honest_coast"])
	check("d07 stopped: still blue on the brass map", WarMapData.state(_act1(b7s), "brass")["regions"]["concordia"] == "guild")
	# the diamond's clock
	st = WarMapData.state(_act1(b7))
	check("d09 the Brood first: the siege's pin wears the clock, the jungle's does not", String(st["pins"]["d11_siege"]["clock"]) != "" and String(st["pins"]["d10_jungle"]["clock"]) == "")
	check("d09: the fort and the sertão", st["marks"]["fort"] and st["regions"]["sertao"] == "crown")
	var b9 := b7.duplicate(true)
	b9["d09_crossroads"] = ["crown", {"first": "clockwork", "sertao": "few"}]
	st = WarMapData.state(_act1(b9))
	check("d09 the Clockwork first: the jungle's pin wears the clock", String(st["pins"]["d10_jungle"]["clock"]) != "" and String(st["pins"]["d11_siege"]["clock"]) == "")
	b9["d10_jungle"] = ["column", {"jungle": "thin"}]
	st = WarMapData.state(_act1(b9))
	check("the waiting front fought: its clock stops", String(st["pins"]["d10_jungle"]["clock"]) == "" and st["regions"]["lower_amazon"] == "brood")
	# d05, d06, d08
	st = WarMapData.state(_act1({"d05_aldeia": ["crown", {"fields": "burned", "aldeia": "some"}]}))
	check("d05 fields burned: the Tapajós uneasy, the burnt church", st["regions"]["tapajos"] == "contested" and st["marks"]["sao_rafael_burnt"] and not st["marks"]["sao_rafael"])
	st = WarMapData.state(_act1({"d05_aldeia": ["crown", {"fields": "left", "aldeia": "many"}]}))
	check("d05 fields left: the Tapajós the creatures', the church standing", st["regions"]["tapajos"] == "brood" and st["marks"]["sao_rafael"] and not st["marks"]["sao_rafael_burnt"])
	st = WarMapData.state(_act1({"d03_fazenda": ["stock", {"hidden": "some"}], "d06_queen": ["brood", {"brood_n": "some", "pieter": "lost"}]}))
	check("d06: the island green, the fazenda fallen, the Queen's mark", st["regions"]["island"] == "brood" and st["marks"]["fazenda_burnt"] and st["marks"]["queen"] and not st["marks"]["fazenda"])
	st = WarMapData.state(_act1({"d08_rivers": ["barra", {"barra": "held", "lure": "burned", "nazare": "some"}]}))
	check("d08 the Barra held: the Barra purple, the upper river the creatures'", st["regions"]["barra_rio_negro"] == "crown" and st["regions"]["upper_rio_negro"] == "brood")
	st = WarMapData.state(_act1({"d08_rivers": ["swarm", {}]}))
	check("d08 won by the swarm: the Barra the creatures', the seal broken", st["regions"]["barra_rio_negro"] == "brood" and st["pins"]["d08_rivers"]["seal"] == "broken")
	st = WarMapData.state(_act1({"d11_siege": ["column", {"siege": "close", "jakob": "lost"}]}))
	check("d11 close: Concórdia red with the siege lines round it", st["regions"]["concordia"] == "machine" and st["marks"]["siege_ring"])
	check("d11 close: the brass map keeps it blue (and no siege lines change that)", WarMapData.state(_act1({"d04_concordia": ["guild", {}], "d11_siege": ["column", {"siege": "close"}]}), "brass")["regions"]["concordia"] == "guild")
	st = WarMapData.state(_act1({"d12_luanda": ["garrison", {"luanda": "escaped"}], "d13_goa": ["ferrer", {"goa_seed": "smashed"}]}))
	check("d12 some got away: Luanda uneasy; d13 smashed: Goa purple", st["regions"]["luanda"] == "contested" and st["regions"]["goa"] == "crown")
	# notes: the chart's and the brass map's own
	var cn: Array = WarMapData.state(_act1({"d06_queen": ["brood", {}]}), "chart")["notes"]
	check("the chart's notes: the station and the Queen's forest", cn.size() >= 3 and cn.any(func(n) -> bool: return String(n["text"]).contains("No one has gone")))
	check("the King's parchment has no margin notes", (WarMapData.state(_act1({"d06_queen": ["brood", {}]}), "parchment")["notes"] as Array).is_empty())
	check("the brass map's words: Concórdia founded", (WarMapData.state(_act1(base), "brass")["notes"] as Array).any(func(n) -> bool: return String(n["text"]).contains("CONCORDIA")))
	# ---- every combination of Act 2's flags (the plan's names): a sound map in every skin
	var n := 0
	var bad: Array = []
	for mn in ["quiet", "restless"]:
		for fields in ["burned", "left"]:
			for spring in ["running", "stopped"]:
				for barra in ["held", "burned"]:
					for first in ["brood", "clockwork"]:
						for jungle in ["held", "thin"]:
							for siege in ["close", "held_off"]:
								var x := {"d01_minas": ["crown", {"minas": mn, "gold": "some", "conspirator": "fled"}],
									"d02_exodus": ["exodus", {"exodus": "some", "exodus_n": 5}],
									"d04_concordia": ["guild", {"colonists": "parley", "crates": "opened"}],
									"d05_aldeia": ["crown", {"fields": fields, "aldeia": "some"}],
									"d06_queen": ["brood", {"brood_n": "some"}],
									"d07_spring": ["honest", {"spring": spring, "honest": "some"}],
									"d08_rivers": ["barra", {"barra": barra, "lure": "burned", "nazare": "all"}],
									"d09_crossroads": ["crown", {"first": first, "sertao": "some"}],
									"d10_jungle": ["column", {"jungle": jungle}],
									"d11_siege": ["column", {"siege": siege}]}
								for sk in WarMapData.SKINS:
									var s2 := WarMapData.state(_act1(x), sk)
									n += 1
									for k in s2["regions"]:
										if not WarMapData.HOLDERS.has(String(s2["regions"][k])):
											bad.append("%s=%s" % [k, s2["regions"][k]])
									if s2["regions"]["concordia"] != ("guild" if sk == "brass" else "machine"):
										bad.append("concordia %s %s" % [sk, spring])
									for k in s2["pins"]:
										if String(s2["pins"][k]["clock"]) != "":
											bad.append("clock left on %s" % k)
									for e in s2["ledger"]:
										if WarMapData.ledger_text(e).contains("%"):
											bad.append("ledger " + String(e["text"]).left(30))
	check("every Act 2 flag combination (%d maps, three skins) gives a sound map" % n, bad.is_empty(), " ".join(bad.slice(0, 8)))


func _ui_act2() -> void:
	# the Clockmaker's hub: its war table opens THE BRASS MAP on Brazil
	Campaign.save_progress(_act1({"d02_exodus": ["exodus", {}]}))
	CampaignMenu.map_open = false
	CampaignMenu.map_cam = {}
	CampaignMenu.map_pick = ""
	CampaignMenu.line = "clockmaker"
	CampaignMenu.show(main)
	await process_frame
	var hs: Button = _find("Hotspot_war_table")
	check("act 2: the Clockmaker's hub has its war table", hs != null)
	if hs:
		hs.pressed.emit()
	await process_frame
	await process_frame
	var wm := _wm()
	check("the Clockmaker's war table opens THE BRASS MAP", wm != null and wm.skin == "brass")
	if wm == null:
		return
	await process_frame
	check("the brass map opens on BRAZIL (its own engraved sheet)", wm.painted == "brazil" and _find("View_brazil") != null, wm.painted)
	# a planned pin's card: what it is about; the clock
	wm.tap(wm.pin_screen(WarMapData.pin_of("d05_aldeia")))
	await process_frame
	check("a planned pin's card says what, where and when (SAY IT PLAINLY)", _find("CardAbout") != null and _find("Card_Briefing") == null)
	_press_back()
	await process_frame
	# the Naturalist's war table (the list) opens THE SPECIMEN CHART
	CampaignMenu.line = "naturalist"
	CampaignMenu.war_table(main)
	await process_frame
	(_find("WarTable_Map") as Button).pressed.emit()
	await process_frame
	wm = _wm()
	check("the Naturalist's war table opens THE SPECIMEN CHART", wm != null and wm.skin == "chart")
	_press_back()
	await process_frame
	# the King's parchment after the crossing: the clock on the waiting front's card
	Campaign.save_progress(_act1({"d07_spring": ["honest", {"spring": "running"}], "d09_crossroads": ["crown", {"first": "brood"}]}))
	CampaignMenu.line = "prologue"
	CampaignMenu.map_skin = "parchment"
	CampaignMenu.map_open = false
	CampaignMenu.map_pick = "d11_siege"
	CampaignMenu.war_map(main)
	await process_frame
	await process_frame
	wm = _wm()
	check("the King's parchment opens on BRAZIL in Act 2 (painted)", wm != null and wm.painted != "" and String(wm.act.get("view", "")) == "brazil")
	check("the waiting front's card wears the clock", _find("CardClock") != null)
	for sk in WarMapData.SKINS:
		wm.skin = sk
		wm.refresh()
		wm.queue_redraw()
		await process_frame
	check("every skin draws Act 2 without an error", true)
	_press_back()
	await process_frame
	CampaignMenu.map_skin = "parchment"
