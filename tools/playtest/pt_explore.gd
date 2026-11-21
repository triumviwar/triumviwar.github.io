extends "res://tools/playtest/pt_setup_util.gd"
## Exploration: set up Crown v Hard Brood, look at every card the start gives.

func run() -> void:
	await wait_real(1.0)
	await setup_1v1("HARD AI", "BROOD", "OPTIMAL")
	await shot("setup")
	step("setup: " + list_buttons())
	await press_button("START")
	await wait_match()
	await shot("start")
	var hall = my_buildings("town_hall")[0]
	await select_ent(hall)
	step("HALL card: " + ", ".join(card_labels()))
	await shot("hall_card")
	var lab = my_units("labourer")[0]
	await select_ent(lab)
	step("LABOURER card: " + ", ".join(card_labels()))
	await key(KEY_B)
	await settle()
	step("BUILD page: " + ", ".join(card_labels()))
	await shot("build_page")
	for b in hud_buttons():
		if not b["enabled"]:
			step("  disabled %s: %s" % [clean_label(b["label"]), b["why"]])
