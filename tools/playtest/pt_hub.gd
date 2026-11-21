extends "res://tools/playtest/pt_base.gd"
## Player 1 (careful): the main menu -> CAMPAIGN -> the King's study: every hotspot on the painting and in the GO TO
## list, every talk read to its end, the ARMOURY room, the other storylines' buttons, BACK and Esc.
##   -- progress=fresh|p01|a01|a06|all   (what the campaign has seen: Campaign progress written before the start)
var progress := "fresh"


func setup() -> void:
	progress = String(args.get("progress", "fresh"))
	tag = "hub_%s_%s_%s" % [progress, device, lang]
	Campaign.save_progress(prog_for(progress))


static func prog_for(k: String) -> Dictionary:
	var crown := {"won_by": "crown", "side": "crown"}
	var done := {}
	var reached: Array = []
	if k in ["p01", "a01", "a06", "all"]:
		done["p01_leaf"] = crown.merged({"flags": {"families": "save"}})
		reached.append("a01_presses")
	if k in ["a01", "a06", "all"]:
		done["a01_presses"] = crown.merged({"flags": {"lyon": "calm", "printer": "taken"}})
		reached.append("a06_barricades")
	if k in ["a06", "all"]:
		done["a06_barricades"] = crown.merged({"flags": {"varenne": "spared", "paris": "stood"}})
	if k == "all":
		# (the other lines as a player who won them on their canon would leave them: Campaign.record's shape)
		done["c01_thirteenth"] = {"won_by": "guild", "side": "guild", "flags": {"bells": "rung", "gate": "people", "saved": "some", "jakob": "alive", "cut": "some"}}
		done["b01_specimen"] = {"won_by": "sire", "side": "sire", "flags": {"clutch": "saved", "eggs": "left", "rival": "standing"}}
		done["a02_furth"] = {"won_by": "guild", "side": "guild", "flags": {"furth": "strong"}}
		done["a03_plateau"] = {"won_by": "party", "side": "party", "flags": {"map": "drawn", "party": "some"}}
		done["a04_visit"] = {"won_by": "visit", "side": "visit", "flags": {"broken": "kept", "lost_to_machine": 2, "stopworks": "found", "jakob": "alive"}}
		done["a05_specimens"] = {"won_by": "expedition", "side": "expedition", "flags": {"cages": "some", "cages_n": 3, "eggs": "taken", "pieter": "alive", "way": "short", "crates": "seen"}}
		for m2 in ["a02_furth", "a03_plateau", "a04_visit", "a05_specimens", "a07_council"]:
			reached.append(m2)
	return {"reached": reached, "done": done}


func play() -> void:
	await shot("00_menu")
	off_screen("main menu")
	check("main menu: CAMPAIGN button", by_text("CAMPAIGN") != null)
	await press_text("CAMPAIGN")
	await frames(10)
	await shot("01_hub")
	flush_errors("hub open")
	off_screen("hub")
	cut_text("hub")
	var titles := labels_text()
	note("hub labels: " + titles.left(400))
	# every storyline button
	for b in buttons():
		if String(b.name).begins_with("Line_"):
			note("storyline button %s disabled=%s text='%s' tip='%s'" % [b.name, b.disabled, Loc.t(b.text), b.tooltip_text])
	# every hotspot in the GO TO list (the painting's ones are the same ids)
	var ids: Array = []
	for b in buttons():
		if String(b.name).begins_with("HotspotList_"):
			ids.append(String(b.name).trim_prefix("HotspotList_"))
	note("hotspots: " + ", ".join(ids))
	var painting: Array = []
	for b in buttons():
		if String(b.name).begins_with("Hotspot_"):
			painting.append(String(b.name).trim_prefix("Hotspot_"))
	note("on the painting: " + ", ".join(painting))
	for id in ids:
		if id == "war_table":
			continue
		# the painting's own button when there is one (a human clicks the person), else the list's
		var nm: String = ("Hotspot_" + id) if id in painting else ("HotspotList_" + id)
		await press_name(nm)
		await frames(4)
		var tb := by_name("HubTalk")
		check("hotspot %s opens the talk box" % id, tb != null)
		if tb == null:
			continue
		var first := String((by_name("TalkText") as Label).text) if by_name("TalkText") else ""
		check("hotspot %s says something" % id, first != "" and first != "...", first.left(60))
		await shot("02_talk_%s" % id)
		off_screen("talk " + id)
		var n := 0
		var said_lines: Array = [first]
		while by_name("HubTalk") and n < 30:
			await press_name("TalkNext")
			n += 1
			if by_name("TalkText"):
				said_lines.append(String((by_name("TalkText") as Label).text))
		note("talk %s: %s" % [id, " / ".join(said_lines)])
		check("hotspot %s talk closes after its lines" % id, by_name("HubTalk") == null, "%d presses" % n)
	flush_errors("hotspots")
	# the other storylines
	var lines_n: Array = []
	for b in buttons():
		if String(b.name).begins_with("Line_") and not b.disabled:
			lines_n.append(String(b.name))
	for nm in lines_n:
			await press_name(nm)
			await frames(6)
			await shot("03_" + nm)
			off_screen(nm)
	await press_name("Line_prologue", false)
	await frames(4)
	# the war table from the painting
	await press_name("Hotspot_war_table", false)
	await frames(10)
	await shot("04_warmap")
	flush_errors("war map open")
	check("the war table opens the war map", CampaignMenu.map_open)
	# Esc back to the hub, Esc back to the menu
	await key(KEY_ESCAPE)
	await frames(6)
	check("Esc from the war map: back at the hub", by_name("HubScene") != null)
	await key(KEY_ESCAPE)
	await frames(6)
	check("Esc from the hub: the main menu", by_text("CAMPAIGN") != null)
