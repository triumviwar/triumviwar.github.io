extends "res://tools/playtest/pt_match.gd"
## PLAYTEST: every mission's OPENING from its briefing's START, with every flag combination a player can reach that its
## conditional lines read: the show must come up with its words and its buttons (a01, a05, a06, a07 came up blank
## before the fix), each page watched to the match (job playtest-campaign-clock).

func play() -> void:
	var base := {"p01_leaf": ["crown", {"families": "save"}],
		"c01_thirteenth": ["guild", {"bells": "rung", "gate": "people", "jakob": "alive", "saved": "many"}],
		"a02_furth": ["guild", {"furth": "thin"}], "a04_visit": ["visit", {"broken": "melted", "lost_to_machine": 3}],
		"b01_specimen": ["sire", {"clutch": "burned", "teles": "told"}], "a03_plateau": ["party", {"map": "withheld"}],
		"a05_specimens": ["expedition", {"cages": "few"}], "a01_presses": ["crown", {"lyon": "sullen", "printer": "taken"}],
		"a06_barricades": ["crown", {"varenne": "executed"}]}
	set_progress(base)
	for pair in [["prologue", "a01_presses"], ["prologue", "a06_barricades"], ["naturalist", "a05_specimens"], ["clockmaker", "a07_council"],
			["clockmaker", "c01_thirteenth"], ["clockmaker", "a02_furth"], ["clockmaker", "a04_visit"]]:
		var mid: String = pair[1]
		if button_text("CAMPAIGN") == null:
			main.show_menu()
			await wait(0.3)
		await press_text("CAMPAIGN")
		await wait(0.3)
		await press_name("Line_" + pair[0])
		await wait(0.3)
		await press_name("HotspotList_war_table")
		await wait(0.3)
		if not await press_name("Mission_" + mid):
			continue
		await press_name("Mode_solo")
		await press_name("Campaign_Go")
		await wait(0.3)
		await press_name("Briefing_Start")
		await wait(0.6)
		var ss := ctrl("StillShow")
		check("%s: the opening comes up" % mid, ss != null)
		if ss == null:
			continue
		var names: Array = []
		for i in 40:
			var ss2 := ctrl("StillShow")
			if ss2 == null:
				break
			var nb := ctrl("Show_NEXT", "Button")
			if i == 0:
				check("%s: the opening has its buttons" % mid, nb != null)
				await snap("opening_%s_p1" % mid, 0.3)
			var texts := page_texts(6)
			names.append(" | ".join(texts.slice(0, 2)))
			if nb == null:
				await key(KEY_ESCAPE)
				break
			await press(nb, "NEXT")
			await wait(0.2)
		note("%s opening (%d pages): %s" % [mid, names.size(), names])
		for i in 40:
			if main.game != null:
				break
			await wait(0.25)
		check("%s: the match begins after the opening" % mid, main.game != null)
		if main.game:
			game = main.game
			await wait(1.0)
			await menu_item("QUIT TO MENU")
			await wait(0.8)
