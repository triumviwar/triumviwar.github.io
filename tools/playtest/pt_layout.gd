extends "res://tools/playtest/pt_base.gd"
## PLAYTEST, the interface layout and hotkeys page (job playtest-menus-online): a player who tries to break it.
## Settings > INTERFACE LAYOUT & HOTKEYS: CUSTOM 1, the minimap dragged far off the screen, SELECTION − many times,
## HOTKEYS: MOVE bound to the digit 1 (a control group's key), ATTACK bound to the same letter as STOP, F1 tried,
## USE THIS LAYOUT, then a skirmish to see what the card shows and what the keys do.
##   tools/playtest/run.sh pt_layout 1280x720 out:<dir>

var ed: Control


func play() -> void:
	await start_main()
	await tap(main.menu_open("settings"))
	await wait(0.4)
	for c in all_controls():
		if (c as Control).has_meta("setting") and String((c as Control).get_meta("setting")) == "layout":
			await tap(c.find_children("*", "BaseButton", true, false)[0])
			break
	await wait(0.5)
	await look("layout_page")
	if not await press("CUSTOM 1", 0.4, true):
		await press("» CUSTOM 1", 0.4, true)
	await look("custom1")
	# drag the minimap far beyond the left and bottom edges
	ed = null
	for c in all_controls():
		if c.get_script() != null and String(c.get_script().resource_path).ends_with("layout_editor.gd"):
			ed = c
	if ed == null:
		find("BUG", "layout", "no layout editor on screen")
		return
	var rs: Dictionary = ed._rects()
	var k: float = ed._scale()
	var mini: Rect2 = rs["mini"]
	var from := root.get_final_transform() * ed.get_global_transform_with_canvas() * (mini.get_center() * k)
	var to := from + Vector2(-900, 900)
	await mouse_move(from)
	mouse_button(from, true)
	await process_frame
	for i in 10:
		var p := from.lerp(to, (i + 1) / 10.0)
		var m := InputEventMouseMotion.new()
		m.position = p
		m.global_position = p
		m.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(m)
		await process_frame
	mouse_button(to, false)
	await wait(0.3)
	await look("mini_dragged_off")
	var r2: Rect2 = ed._rects()["mini"]
	print("PT minimap after the drag: %s (screen %s)" % [str(r2), str(ed._hud_size())])
	if not Rect2(Vector2.ZERO, ed._hud_size()).grow(1).encloses(r2):
		find("BUG", "layout", "the minimap can be dragged off the screen: %s" % str(r2))
	for i in 12:
		await press("SELECTION −", 0.1, true)
	await look("selection_narrowest")
	# hotkeys
	await press("HOTKEYS", 0.4, true)
	await look("hotkeys")
	await rebind("MOVE", KEY_1)
	await rebind("ATTACK", KEY_S)
	await rebind("HOLD", KEY_F1)
	await rebind("CANCEL", KEY_SPACE)
	await look("hotkeys_after")
	print("PT keys now: MOVE '%s' ATTACK '%s' STOP '%s' HOLD '%s' CANCEL '%s'" % [UiLayout.data("CUSTOM 1").get("keys", {}).get("MOVE", ""), UiLayout.data("CUSTOM 1").get("keys", {}).get("ATTACK", ""),
		UiLayout.data("CUSTOM 1").get("keys", {}).get("STOP", ""), UiLayout.data("CUSTOM 1").get("keys", {}).get("HOLD", ""), UiLayout.data("CUSTOM 1").get("keys", {}).get("CANCEL", "")])
	if not await press("USE THIS LAYOUT", 0.4, true):
		print("PT (CUSTOM 1 already in use from an earlier run)")
	await press("BACK", 0.4, true)
	await key_tap(KEY_ESCAPE)
	await wait(0.5)
	# a skirmish with this layout
	await tap(main.menu_open("skirmish"))
	await wait(0.6)
	await press("START", 0.3, true)
	for i in 120:
		await wait(0.25)
		if main.game != null and main.game.clock > 3.0:
			break
	if main.game == null:
		find("BUG", "layout", "no match")
		return
	await look("match_with_custom_layout", 1.0)
	# select everything of ours on screen (Ctrl+A is not a thing: a box over the screen middle), then press 1
	var vs := Vector2(DisplayServer.window_get_size())
	# a box dragged over the middle of the screen (the workers by the hall)
	var a := vs * Vector2(0.05, 0.1)
	var b2 := vs * Vector2(0.75, 0.75)
	await mouse_move(a)
	mouse_button(a, true)
	await process_frame
	for i in 8:
		var m := InputEventMouseMotion.new()
		m.position = a.lerp(b2, (i + 1) / 8.0)
		m.global_position = m.position
		m.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(m)
		await process_frame
	mouse_button(b2, false)
	await wait(0.4)
	await look("box_selected")
	var g: Game = main.game
	print("PT selected %d" % g.selection.size())
	await key_tap(KEY_1)
	await wait(0.3)
	await look("pressed_1_with_selection")
	print("PT after 1 with a selection: selection %d, command mode '%s'" % [g.selection.size(), str(g.hud.controls.mode)])
	await key_tap(KEY_ESCAPE)
	var sel_before := g.selection.size()
	await key_tap(KEY_1, false, true)       # Ctrl+1: put the selection in group 1
	await key_tap(KEY_ESCAPE)
	await key_tap(KEY_1)                    # 1: the group back, or the custom MOVE?
	await wait(0.3)
	await look("after_pressing_1")
	print("PT selection before %d, after Ctrl+1, Esc, 1: %d; command mode '%s'" % [sel_before, g.selection.size(), str(g.hud.controls.mode)])


func rebind(cmd: String, code: Key) -> void:
	var lab: Control = null
	for c in all_controls("Label"):
		if shown(c) == cmd.capitalize() or (c as Label).text == cmd.capitalize():
			lab = c
	if lab == null:
		print("PT MISS no hotkey row for %s" % cmd)
		return
	# the button is the next child in the grid
	var grid := lab.get_parent()
	var b: Control = grid.get_child(lab.get_index() + 1)
	await tap(b)
	await wait(0.2)
	await key_tap(code)
	await wait(0.3)
