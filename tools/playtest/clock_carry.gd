extends "res://tools/playtest/pt_match.gd"
## PLAYTEST, the flags carried forward along the Clockmaker line (job playtest-campaign-clock): for each set of earlier
## choices the next mission is started from the main menu (CAMPAIGN, the war table, BRIEFING, START, the opening
## skipped), its start is read a few seconds in, and the mission is left with QUIT TO MENU. c01 -> a02 (the bells, the
## saved, Jakob, the links, the gate), a02 -> a04 (the line strong / thin, Jakob), c01 / a04 -> a07 (the broken ones, lost
## to the machine, the gate, the bells).

func play() -> void:
	set_speed(1.0)
	# ---- c01 -> a02
	var combos := [
		{"bells": "rung", "saved": "many", "saved_n": 80, "jakob": "alive", "cut": "yes", "gate": "pattern"},
		{"bells": "quiet", "saved": "few", "saved_n": 10, "jakob": "lost", "cut": "no", "gate": "people"},
	]
	for c in combos:
		set_progress({"p01_leaf": ["crown", {}], "c01_thirteenth": ["guild", c]})
		if not await start_mission("clockmaker", "a02_furth", "normal", "guild"):
			continue
		await wait(4.0)
		var muskets := run.count({"team": "army", "kind": "musketeer"})
		var guns := run.count({"team": "army", "kind": "cannon"})
		var jak := run.tagged("jakob").size()
		var commissary := run.tagged("commissary").size()
		var lw := game.requirement_text(game.human, "movement_works")
		note("a02 with c01 %s: musketeers %d, cannons %d, jakob %d, commissary %d, light works '%s', cogs %d, refugees' cottages %d, diggers %d" % [c,
			muskets, guns, jak, commissary, lw, gold(), run.count({"team": "town", "kind": "cottage"}), run.count({"tag": "diggers"})])
		if c["bells"] == "rung":
			check("a02 after rung bells: 16 Musketeers and 2 Field Cannons at the line", muskets >= 16 and guns >= 2, "%d %d" % [muskets, guns])
			check("a02 after rung bells: the Light Works allowed at once", lw == "", lw)
		else:
			check("a02 after quiet bells: the commissary at the Honest One", commissary >= 1)
			check("a02 after quiet bells: no Light Works before the stop-work", lw != "", lw)
		check("a02 Jakob there only if he lived in c01", (jak > 0) == (c["jakob"] == "alive"), str(jak))
		await snap("carry_a02_%s_%s" % [c["bells"], c["saved"]], 0.2)
		await menu_item("QUIT TO MENU")
		await wait(1.0)
	# ---- a02 -> a04
	for furth in ["strong", "thin"]:
		for jk in ["alive", "lost"]:
			set_progress({"p01_leaf": ["crown", {}], "c01_thirteenth": ["guild", {"jakob": jk, "gate": "people" if jk == "lost" else "pattern"}],
				"a02_furth": ["guild", {"furth": furth, "jakob": jk}]})
			if not await start_mission("clockmaker", "a04_visit", "normal"):
				continue
			await wait(4.0)
			var esc := run.tagged("escort").size()
			var jak := run.tagged("jakob").size()
			note("a04 with furth %s, jakob %s: escort %d, jakob %d, broken %d" % [furth, jk, esc, jak, run.tagged("broken").size()])
			check("a04 escort by a02's line (%s)" % furth, esc == (8 if furth == "strong" else 5), str(esc))
			check("a04 Jakob only if alive (%s)" % jk, (jak > 0) == (jk == "alive"), str(jak))
			await menu_item("QUIT TO MENU")
			await wait(1.0)
	# ---- into a07 (Rome): the Clockmaker's war table lists it once a04, a05 and a06 are done
	for broken in ["kept", "melted"]:
		var done := {"p01_leaf": ["crown", {"families": "save"}],
			"c01_thirteenth": ["guild", {"bells": "rung", "gate": "pattern", "jakob": "alive", "saved": "many"}],
			"a02_furth": ["guild", {"furth": "strong"}],
			"a04_visit": ["visit", {"broken": broken, "lost_to_machine": 5, "lost_to_machine_n": 5, "stopworks": "found", "jakob": "alive"}],
			"b01_specimen": ["sire", {"clutch": "saved", "teles": "quiet"}], "a03_plateau": ["party", {"map": "drawn"}],
			"a05_specimens": ["expedition", {"cages": "some", "eggs": "taken"}],
			"a01_presses": ["crown", {"lyon": "calm"}], "a06_barricades": ["crown", {"varenne": "spared"}]}
		set_progress(done)
		if not await start_mission("clockmaker", "a07_council", "normal", "", true, 0):
			continue
		await wait(5.0)
		var aut := run.count({"team": "automata"})
		note("a07 with a04 broken=%s lost_to_machine=5: automata units %d, pendulum? %d" % [broken, aut, run.count({"team": "automata", "kind": "pendulum"})])
		_a07[broken] = aut
		await snap("carry_a07_%s" % broken, 0.2)
		await menu_item("QUIT TO MENU")
		await wait(1.0)
	note("a07 automata by a04's broken: %s" % [_a07])


var _a07 := {}
