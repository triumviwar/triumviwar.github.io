extends "res://tools/playtest/pt_setup_util.gd"
## A short match, QUIT TO MENU, then the main menu's EXIT: does the program close cleanly?

func run() -> void:
	await wait_real(1.0)
	await setup_1v1("EASY AI", "CROWN", "BALANCED")
	await press_button("START")
	await wait_match()
	await wait_real(2.0)
	var mr: Rect2 = hud().menu_rect()
	await click(mr.get_center() * hud().ui_scale)
	await settle()
	for b in hud()._menu_buttons():
		if String(b.get("label", "")) == "QUIT TO MENU":
			await click((b["rect"] as Rect2).get_center() * hud().ui_scale)
	await wait_real(1.5)
	step("pressing EXIT")
	await press_button("EXIT")
	await wait_real(3.0)
	step("still running after EXIT: " + list_buttons().substr(0, 120))
