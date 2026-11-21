extends "res://tools/playtest/pt_setup_util.gd"
## The main menu's EXIT straight away.
func run() -> void:
	await wait_real(1.5)
	await press_button("EXIT")
	await wait_real(3.0)
