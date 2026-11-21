extends "res://tools/playtest/pt_hub.gd"
## Player 1 + the fiddler: the WAR MAP from the King's study: every view, + / -, the wheel, a drag, a pinch (phone),
## the LEDGER, every pin tapped (its card: state, BRIEFING, CO-OP / VERSUS, CLOSE), LIST and back, Esc, a tap in the
## sea (no pin), dragging off the map's edge, mashing the zoom.
##   -- progress=fresh|p01|a01|a06|all


func setup() -> void:
	progress = String(args.get("progress", "fresh"))
	tag = "map_%s_%s_%s" % [progress, device, lang]
	Campaign.save_progress(prog_for(progress))


func wm() -> WarMap:
	return by_name("WarMap") as WarMap


func play() -> void:
	await press_text("CAMPAIGN")
	await frames(6)
	await press_name("HotspotList_war_table")
	await frames(12)
	check("the war map opens", wm() != null)
	if wm() == null:
		return
	await shot("00_open")
	off_screen("war map")
	cut_text("war map")
	flush_errors("map open")
	var m := wm()
	note("zoom %.3f centre %s size %s" % [m.zoom, m.center, m.size])
	# the views
	for v in WarMapData.data().get("views", []):
		await press_name("View_" + String(v["id"]))
		await wait(0.6)
		await shot("01_view_" + String(v["id"]))
		note("view %s: zoom %.2f centre %s" % [v["id"], wm().zoom, wm().center])
	# zoom buttons, mashed
	var z0 := wm().zoom
	for i in 6:
		await press_name("Zoom_in")
	check("+ zooms in", wm().zoom > z0, "%.2f -> %.2f" % [z0, wm().zoom])
	for i in 30:
		await press_name("Zoom_out")
	check("- mashed: zoom stops at the whole world", is_equal_approx(wm().zoom, wm().min_zoom()), "%.3f v min %.3f" % [wm().zoom, wm().min_zoom()])
	await shot("02_zoomed_out")
	# wheel
	var mc := centre_of(wm())
	if device == "pc":
		await wheel_at(mc, true, 8)
		check("the wheel zooms in", wm().zoom > wm().min_zoom())
	# a drag far off every edge
	var zz := wm().zoom
	await drag(mc, mc + Vector2(3000, 2000))
	await drag(mc, mc + Vector2(-5000, -4000))
	var wr := wm().world_rect()
	var half := wm().size * 0.5 / wm().zoom
	check("dragging off the edge keeps the map on screen", wr.grow(1).has_point(wm().center - half) and wr.grow(1).has_point(wm().center + half),
		"centre %s zoom %.2f" % [wm().center, zz])
	await shot("03_dragged")
	# a pinch (the phone) out and in
	if device == "phone":
		var zb := wm().zoom
		await pinch(mc, 80, 300)
		check("pinch out zooms in", wm().zoom > zb, "%.2f -> %.2f" % [zb, wm().zoom])
		var za := wm().zoom
		await pinch(mc, 300, 60)
		check("pinch in zooms out", wm().zoom < za, "%.2f -> %.2f" % [za, wm().zoom])
	# the ledger
	await press_name("WarMap_Ledger")
	await frames(4)
	await shot("04_ledger")
	check("LEDGER opens", by_name("WarLedger") != null)
	off_screen("ledger")
	await press_name("WarMap_Ledger")
	await frames(4)
	check("LEDGER closes", by_name("WarLedger") == null)
	# a tap on nothing
	await press_name("View_world")
	await wait(0.6)
	# every pin: fit the world, then tap each seal where it is drawn
	var st: Dictionary = wm().st
	for pn in WarMapData.data().get("pins", []):
		var mid := String(pn["mission"])
		await press_name("View_world")
		await wait(0.5)
		# zoom in on the pin's own view so pins on one town are apart
		var p := wm().pin_screen(pn)
		var w := wm()
		await click_at(to_window(w, p))
		await wait(0.5)
		var card := by_name("WarCard")
		var stt := String(st.get("pins", {}).get(mid, {}).get("state", "?"))
		if not check("pin %s (%s) tapped opens its card" % [mid, stt], card != null and w.selected == mid, "selected=%s" % w.selected):
			continue
		var title := by_name("CardTitle") as Label
		var cst := by_name("CardState") as Label
		note("pin %s: '%s' / %s" % [mid, title.text if title else "?", cst.text if cst else "?"])
		await shot("05_pin_" + mid)
		off_screen("card " + mid)
		var br := by_name("Card_Briefing")
		var co := by_name("Card_Modes")
		if stt in ["open", "done"]:
			check("pin %s open: BRIEFING there" % mid, br != null)
		else:
			check("pin %s %s: no BRIEFING" % [mid, stt], br == null)
		if co != null and mid in ["p01_leaf", "a01_presses", "a06_barricades", "a07_council"]:
			await press(co)
			await frames(8)
			await shot("06_modes_" + mid)
			note("CO-OP/VERSUS page for %s: %s" % [mid, labels_text().left(300)])
			off_screen("modes " + mid)
			await key(KEY_ESCAPE)
			await frames(8)
			check("Esc from the war table returns to the map", wm() != null, "map_open=%s" % CampaignMenu.map_open)
			if wm() == null:
				await press_name("HotspotList_war_table", false)
				await frames(8)
			st = wm().st
			continue
		if br != null and mid in ["p01_leaf", "a01_presses", "a06_barricades", "a07_council"]:
			await press(br)
			await frames(8)
			await shot("07_brief_" + mid)
			off_screen("briefing " + mid)
			cut_text("briefing " + mid)
			note("briefing %s: %s" % [mid, labels_text().left(500)])
			await key(KEY_ESCAPE)
			await frames(8)
			check("Esc from %s's briefing: back to the map" % mid, wm() != null)
			if wm() == null:
				await press_name("HotspotList_war_table", false)
				await frames(8)
			st = wm().st
			continue
		await press_name("Card_Close", false)
		await frames(3)
	flush_errors("pins")
	# a tap in the empty sea closes the card
	await press_name("View_world")
	await wait(0.5)
	await click_at(to_window(wm(), Vector2(8, wm().size.y - 8)))
	await frames(3)
	check("a tap on no pin: no card", by_name("WarCard") == null)
	# LIST and back
	await press_name("WarMap_List")
	await frames(8)
	await shot("08_list")
	off_screen("list")
	note("LIST page: " + labels_text().left(400))
	await key(KEY_ESCAPE)
	await frames(8)
	check("Esc from LIST: the map again", wm() != null)
	await key(KEY_ESCAPE)
	await frames(8)
	check("Esc from the map: the hub", by_name("HubScene") != null)
