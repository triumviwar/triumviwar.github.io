extends "res://tools/playtest/pt_lib.gd"
## PLAYTEST: the Clockmaker missions' CO-OP and VERSUS seats from the war table to OPEN AN ONLINE ROOM (job
## playtest-campaign-clock). The room itself is the online job's; this looks at what a player gets after the button.

func play() -> void:
	set_progress({"p01_leaf": ["crown", {}], "c01_thirteenth": ["guild", {"gate": "pattern"}], "a02_furth": ["guild", {"furth": "strong"}]})
	for pair in [["a02_furth", "coop", ""], ["a02_furth", "versus", "Seat_p2"], ["a04_visit", "versus", "Seat_p1"], ["c01_thirteenth", "coop", ""]]:
		if button_text("CAMPAIGN") == null:
			main.show_menu()
			await wait(0.3)
		await press_text("CAMPAIGN")
		await wait(0.3)
		await press_name("Line_clockmaker")
		await wait(0.3)
		await press_name("HotspotList_war_table")
		await wait(0.3)
		await press_name("Mission_" + pair[0])
		await wait(0.2)
		await press_name("Mode_" + pair[1])
		await wait(0.2)
		if pair[2] != "":
			await press_name(pair[2])
			await wait(0.2)
		await press_name("Campaign_Go")
		await wait(2.0)
		note("%s %s %s -> page: %s" % [pair[0], pair[1], pair[2], page_texts(14)])
		await snap("online_%s_%s" % [pair[0], pair[1]], 0.3)
		layout_check("online room %s %s" % [pair[0], pair[1]])
		for i in 4:
			await key(KEY_ESCAPE)
			await wait(0.3)
		main.show_menu()
		await wait(0.3)
