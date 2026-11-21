extends "res://tools/playtest/pt_base.gd"
## A first look: the main menu, SETTINGS by a real click, BACK by Esc.
func play() -> void:
	await start_main()
	await look("menu")
	print("PT buttons ", button_texts())
	await press("SETTINGS")
	await look("settings")
	await key_tap(KEY_ESCAPE)
	await wait(0.3)
	await look("menu_again")
	print("PT buttons2 ", button_texts())
