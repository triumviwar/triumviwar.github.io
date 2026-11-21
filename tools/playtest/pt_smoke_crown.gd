extends "res://tools/playtest/pt_base_crown.gd"
## Smoke: main menu -> SKIRMISH -> START, a look at the HUD.

func run() -> void:
	await wait_real(1.5)
	await shot("menu")
	step("menu buttons: " + list_buttons())
	await press_button("SKIRMISH")
	await wait_real(0.5)
	await shot("skirmish")
	step("skirmish buttons: " + list_buttons())
	await press_button("START")
	await wait_real(3.0)
	await shot("match_start")
	step("fps %d, card: %s" % [Engine.get_frames_per_second(), ", ".join(card_labels())])
	await wait_real(3.0)
	step("fps %d" % Engine.get_frames_per_second())
