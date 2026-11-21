extends "res://tools/playtest/pt_base.gd"
## A phone (touch only): do the Settings page's sliders move under a finger? (tap and drag)
func play() -> void:
	await press_button("Menu_settings")
	await wait(0.5)
	for tab in main.SETTINGS_TABS:
		var tb := button(Loc.t(tab))
		if tb:
			await press(tb)
			await wait(0.4)
		for c in root.find_children("*", "HSlider", true, false):
			var sl := c as HSlider
			if not sl.is_visible_in_tree():
				continue
			var r := sl.get_global_rect()
			var v0 := sl.value
			await touch_drag(r.position + Vector2(4, r.size.y * 0.5), r.position + Vector2(r.size.x - 4, r.size.y * 0.5))
			var v1 := sl.value
			await tap(r.position + Vector2(r.size.x * 0.3, r.size.y * 0.5))
			note("tab %s slider %s: %.2f -> drag to the right %.2f -> tap at 30%% %.2f (range %.2f-%.2f)" % [tab, sl.get_parent().name, v0, v1, sl.value, sl.min_value, sl.max_value])
			sl.value = v0
	await shot("settings_last_tab")
