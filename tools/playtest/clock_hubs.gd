extends "res://tools/playtest/pt_lib.gd"
## PLAYTEST, the Clockmaker's hubs (job playtest-campaign-clock): from the MAIN MENU, CAMPAIGN, the Clockmaker tab, every
## hotspot (in the painting and in the GO TO list), every talk read to its end, the BRASS MAP (war table) with each mission,
## its CO-OP / VERSUS seats, the BRIEFING (sides, difficulties), the WAR MAP, BACK and Esc; in each state of the story:
##   s0 nothing played (the line is locked), s1 the Crown's prologue done, s2 c01 done, s3 a02 won by the guild,
##   s4 a02 won as the Machine, s5 a04 done (a07 still locked: a05 and a06 not played), s6 everything before a07 done.
## Args: states=s0,s1,... (default all), plus pt_lib's.

const C01 := {"bells": "rung", "saved": "some", "saved_n": 40, "jakob": "alive", "cut": "yes", "gate": "people"}
const A02G := {"furth": "strong"}
const A02M := {"furth": "fallen"}
const A04 := {"broken": "kept", "lost_to_machine": 2, "stopworks": "found", "jakob": "alive"}


func states() -> Dictionary:
	var p01 := {"p01_leaf": ["crown", {"families": "save"}]}
	var s2 := p01.duplicate(true)
	s2["c01_thirteenth"] = ["guild", C01]
	var s3 := s2.duplicate(true)
	s3["a02_furth"] = ["guild", A02G]
	var s4 := s2.duplicate(true)
	s4["a02_furth"] = ["machine", A02M]
	var s5 := s3.duplicate(true)
	s5["a04_visit"] = ["visit", A04]
	var s6 := s5.duplicate(true)
	s6["a05_specimens"] = ["expedition", {"cages": "some"}]
	s6["a06_barricades"] = ["crown", {"varenne": "spared", "paris": "stood"}]
	s6["b01_specimen"] = ["sire", {"clutch": "saved"}]
	s6["a03_plateau"] = ["party", {"map": "drawn"}]
	s6["a01_presses"] = ["crown", {"lyon": "calm"}]
	return {"s0": {}, "s1": p01, "s2": s2, "s3": s3, "s4": s4, "s5": s5, "s6": s6}


func play() -> void:
	var want := arg("states", "s0,s1,s2,s3,s4,s5,s6").split(",")
	await snap("main_menu", 0.8)
	layout_check("main menu")
	var st := states()
	for s in want:
		await one_state(s, st[s])
		await to_menu()


func to_menu() -> void:
	# Esc until the main menu (the pages' BACK)
	for i in 6:
		if button_text("CAMPAIGN") != null and ctrl("Line_*") == null:
			return
		await key(KEY_ESCAPE)
		await wait(0.2)
	if button_text("CAMPAIGN") == null:
		finding("Esc did not lead back to the main menu (page: %s)" % [page_texts(6)])
		main.show_menu()
		await wait(0.3)


func one_state(s: String, done: Dictionary) -> void:
	note("=== state %s" % s)
	set_progress(done)
	CampaignMenu.line = "prologue"
	if not await press_text("CAMPAIGN"):
		return
	await wait(0.4)
	var lb: Button = ctrl("Line_clockmaker", "Button")
	if not check("%s: the Clockmaker tab is there" % s, lb != null):
		return
	if s == "s0":
		# (0.38.73: all three prologues are open from the start, the Crown's marked "Start here")
		check("s0: the Clockmaker open from the start (0.38.73)", not lb.disabled, lb.text)
	check("%s: the Clockmaker tab open" % s, not lb.disabled)
	await press(lb, "Clockmaker tab")
	await wait(0.5)
	var title := page_texts(3)
	note("%s hub page: %s" % [s, title])
	await snap("%s_hub" % s, 0.6)
	layout_check("%s hub" % s)
	# the painting's hotspots: hover each (the name lights up), then the list
	var spots := ctrls("Hotspot_*", "Button")
	note("%s painting hotspots: %s" % [s, spots.map(func(b): return b.name)])
	for hb in spots:
		var r: Rect2 = (hb as Control).get_global_rect()
		_mouse_move(to_window(r.get_center()))
		await frames(3)
	var names := ctrls("HotspotList_*", "Button").map(func(b): return String(b.name))
	note("%s GO TO list: %s" % [s, names])
	for n in names:
		if n == "HotspotList_war_table":
			continue
		var b: Button = ctrl(n, "Button")
		if b == null:
			finding("%s: %s vanished from the list" % [s, n])
			continue
		await press(b, n)
		await wait(0.3)
		var tb := ctrl("HubTalk", "PanelContainer")
		if tb == null:
			finding("%s: %s opened no talk box" % [s, n])
			continue
		var txt: Label = tb.find_child("TalkText", true, false)
		var lines: Array = []
		for i in 30:
			if txt and not lines.has(txt.text):
				lines.append(txt.text)
			if i == 0:
				await snap("%s_talk_%s" % [s, n.trim_prefix("HotspotList_")], 0.3)
				layout_check("%s talk %s" % [s, n])
			var nb: Button = tb.find_child("TalkNext", true, false)
			if nb == null or not tb.visible:
				break
			await press(nb, "talk NEXT")
			await wait(0.1)
			if not tb.visible:
				break
		if tb.visible:
			finding("%s: the talk %s never closed" % [s, n])
		note("%s talk %s: %d lines: %s" % [s, n, lines.size(), lines])
		if lines.size() == 1 and String(lines[0]) == "...":
			finding("%s: %s says only '...' (no talk entry for this state)" % [s, n])
	# also the painting's own hotspot for a talk (clicked on the person), once
	for hb in ctrls("Hotspot_*", "Button"):
		if String(hb.name) != "Hotspot_war_table":
			await press(hb, String(hb.name))
			await wait(0.2)
			var tb := ctrl("HubTalk", "PanelContainer")
			check("%s: clicking %s in the painting opens its talk" % [s, hb.name], tb != null and tb.visible)
			break
	# the war table (BRASS MAP)
	await press_name("HotspotList_war_table")
	await wait(0.5)
	await snap("%s_war_table" % s, 0.4)
	layout_check("%s war table" % s)
	var mids := ctrls("Mission_*", "Button")
	note("%s missions: %s" % [s, mids.map(func(b): return "%s%s '%s'" % [b.name, " (disabled)" if b.disabled else "", b.text])])
	for mb in mids.map(func(b): return String(b.name)):
		var b: Button = ctrl(mb, "Button")
		if b == null or b.disabled:
			continue
		await press(b, mb)
		await wait(0.35)
		await snap("%s_table_%s" % [s, mb.trim_prefix("Mission_")], 0.3)
		layout_check("%s table %s" % [s, mb])
		for md in ["coop", "versus"]:
			var mbtn: Button = ctrl("Mode_" + md, "Button")
			if mbtn and not mbtn.disabled:
				await press(mbtn, "Mode_" + md)
				await wait(0.3)
				var seats := ctrls("Seat_*", "Button").map(func(x): return "%s '%s'" % [x.name, x.text])
				note("%s %s %s seats: %s" % [s, mb, md, seats])
				if md == "versus":
					for sn in ctrls("Seat_*", "Button").map(func(x): return String(x.name)):
						await press_name(sn)
						await wait(0.25)
					await snap("%s_table_%s_versus" % [s, mb.trim_prefix("Mission_")], 0.3)
					layout_check("%s %s versus" % [s, mb])
		await press_name("Mode_solo")
		await wait(0.2)
		# the briefing
		await press_name("Campaign_Go")
		await wait(0.4)
		await snap("%s_briefing_%s" % [s, mb.trim_prefix("Mission_")], 0.3)
		layout_check("%s briefing %s" % [s, mb])
		for sd in ctrls("Side_*", "Button").map(func(x): return String(x.name)):
			await press_name(sd)
			await wait(0.3)
			await snap("%s_briefing_%s_%s" % [s, mb.trim_prefix("Mission_"), sd], 0.3)
			layout_check("%s briefing %s %s" % [s, mb, sd])
		for dn in ["Diff_easy", "Diff_hard", "Diff_normal"]:
			await press_name(dn)
			await wait(0.2)
		check("%s %s: the difficulty kept" % [s, mb], Campaign.difficulty() == "normal")
		if ctrl("Side_guild", "Button"):
			await press_name("Side_guild")      # (leave the pick as a player would find it)
		await key(KEY_ESCAPE)      # back to the war table
		await wait(0.35)
		check("%s %s: Esc from the briefing goes back to the war table" % [s, mb], ctrl("Mission_*", "Button") != null)
	# the WAR MAP from the war table
	if await press_name("WarTable_Map"):
		await wait(0.8)
		await snap("%s_war_map" % s, 0.6)
		layout_check("%s war map" % s)
		note("%s war map page: %s" % [s, page_texts(20)])
	await key(KEY_ESCAPE)
	await wait(0.3)
	note("%s after Esc from the war map: %s" % [s, page_texts(4)])
