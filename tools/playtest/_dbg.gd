extends "res://tools/playtest/pt_base.gd"
func play() -> void:
	await start_main()
	await tap(main.menu_buttons["settings"])
	await wait(0.5)
	for t in ["Tab_DISPLAY", "Tab_GAMEPLAY", "Tab_SOUND"]:
		for c in all_controls():
			if String(c.name) == t:
				await tap(c)
		await wait(0.5)
		for c in all_controls("ScrollContainer"):
			var p: Control = c.get_parent().get_parent()
			print("PT %s scroll %s min %s panel %s vis %s" % [t, (c as Control).get_global_rect(), (c as Control).custom_minimum_size, p.get_global_rect(), root.get_visible_rect()])
	await shot("dbg")
