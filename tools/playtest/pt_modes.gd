extends "res://tools/playtest/pt_hub.gd"
## The war table (LIST) of the Crown line: each mission's SOLO / CO-OP / VERSUS, every seat button (Rome's versus
## pick: the creatures or the automata), what the page says, then OPEN AN ONLINE ROOM (the room page, BACK out).
##   -- progress=all


func setup() -> void:
	progress = String(args.get("progress", "all"))
	tag = "modes_%s_%s_%s" % [progress, device, lang]
	Campaign.save_progress(prog_for(progress))


func play() -> void:
	await press_text("CAMPAIGN")
	await frames(6)
	await press_name("HotspotList_war_table")
	await frames(8)
	await press_name("WarMap_List")
	await frames(8)
	for mid in ["p01_leaf", "a01_presses", "a06_barricades", "a07_council"]:
		if not await press_name("Mission_" + mid, false):
			note("%s not on the list (locked?)" % mid)
			continue
		await frames(6)
		for md in ["solo", "coop", "versus"]:
			if not await press_name("Mode_" + md, false):
				note("%s: no %s" % [mid, md])
				continue
			await frames(6)
			var seats: Array = []
			for b in buttons():
				if String(b.name).begins_with("Seat_"):
					seats.append(String(b.name))
			note("%s %s: seats %s; go '%s'; page: %s" % [mid, md, seats, by_name("Campaign_Go").text if by_name("Campaign_Go") else "-",
				labels_text().left(260)])
			await shot("%s_%s" % [mid, md])
			off_screen("%s %s" % [mid, md])
			cut_text("%s %s" % [mid, md])
			for sn in seats:
				await press_name(sn)
				await frames(4)
				note("   seat %s -> %s" % [sn, labels_text().left(200)])
				if mid == "a07_council":
					await shot("%s_%s" % [mid, sn])
		flush_errors(mid)
	# an online room for Rome's versus, then BACK
	await press_name("Mission_a07_council", false)
	await frames(4)
	await press_name("Mode_versus", false)
	await frames(4)
	if by_name("Campaign_Go"):
		await press_name("Campaign_Go")
		await frames(30)
		await shot("a07_room")
		note("room page: %s" % labels_text().left(300))
		off_screen("a07 room")
		flush_errors("room")
		await key(KEY_ESCAPE)
		await frames(10)
		note("after Esc: %s" % labels_text().left(200))
