extends "res://tools/playtest/tutorial_editor/pt_base.gd"
## THE MAP EDITOR played from the main menu (EDITOR > MAP EDITOR) with real clicks, drags, keys and taps:
## part:paint  a new map, every terrain tool, brushes, fill, mirror, props, start / hall / team / remove spots,
##             undo / redo (buttons and keys), CHECK, a name with odd characters, SAVE, LOAD, overwrite, delete;
## part:sizes  NEW at the smallest custom size, a tiny preset and the huge 256x256;
## part:play   a fair 1v1 made and PLAYED in a skirmish (and a 4-player one);
## part:break  PLAY with no starts, a start walled in by water, a map flooded with water, special names.
## (see pt_base.gd for the command line)

var ed: MapEditor


func play() -> void:
	var part := String(args.get("part", "paint"))
	await press_button("Menu_editor")
	await wait(0.5)
	await shot("editor_menu")
	await press_button("MAP EDITOR")
	await wait(1.0)
	ed = main._editor
	if not expect(ed != null and is_instance_valid(ed), "the map editor opened"):
		return
	await shot("editor_blank")
	print("PT OFFSCREEN ", off_screen())
	match part:
		"paint":
			await part_paint()
		"sizes":
			await part_sizes()
		"play":
			await part_play()
		"break":
			await part_break()
		"tools":
			await part_tools()


## The screen spot of a cell's middle.
func cell_spot(c: Vector2i) -> Vector2:
	return world_to_screen((Vector2(c) + Vector2(0.5, 0.5)) * Game.T)


func pick_tool(label: String) -> void:
	await press_button(label, ed)
	await frames(2)
	ed = main._editor


func ed_button(label: String) -> BaseButton:
	return button(label, main._editor)


func paint_line(a: Vector2i, b: Vector2i) -> void:
	if phone and not ed.pan_mode:
		await touch_drag(cell_spot(a), cell_spot(b))
	else:
		await drag(cell_spot(a), cell_spot(b))
	await frames(2)
	ed = main._editor


func put(c: Vector2i) -> void:
	await press_at(cell_spot(c))
	await frames(2)
	ed = main._editor


func status() -> String:
	return String(main._editor._status) if is_instance_valid(main._editor) else "(no editor)"


func cell_code(c: Vector2i) -> String:
	return ed.cells[c.y * ed.W + c.x]


func type_text(t: String) -> void:
	for ch in t:
		var e := InputEventKey.new()
		e.pressed = true
		e.unicode = ch.unicode_at(0)
		e.keycode = KEY_NONE
		Input.parse_input_event(e)
		await frames(1)
		var r := e.duplicate()
		r.pressed = false
		Input.parse_input_event(r)
		await frames(1)


func set_name(t: String) -> void:
	var le: LineEdit = main._editor._name_edit
	await press(le)
	await frames(2)
	await key(KEY_A, {"ctrl": true})
	await key(KEY_BACKSPACE)
	await type_text(t)
	await key(KEY_ENTER)
	await frames(2)
	note("name box now '%s', map_name '%s'" % [le.text, main._editor.map_name])


func dialog_buttons() -> Array:
	var outl: Array = []
	for c in main._editor._ui.get_children():
		if c.has_meta("dialog"):
			outl.append_array(buttons(c))
	return outl


func new_map(preset: String, plus_minus := {}) -> void:
	await press_button("NEW", ed)
	await wait(0.4)
	if dialog_buttons().is_empty():
		note("NEW asks first: '%s'" % status())
		await press_button("NEW", main._editor)
		await wait(0.4)
	if preset != "":
		await press_button(preset, ed)
		await wait(0.3)
	for k in plus_minus:
		for i in int(plus_minus[k]):
			# the "-" buttons: the first is WIDTH's, the second HEIGHT's
			var minus: Array = buttons(main._editor).filter(func(b: BaseButton) -> bool: return b is Button and (b as Button).text == k)
			if minus.size() >= 2:
				await press(minus[0])
				await frames(2)
				minus = buttons(main._editor).filter(func(b: BaseButton) -> bool: return b is Button and (b as Button).text == k)
				await press(minus[1])
				await frames(2)
	await shot("new_dialog")
	var create := button("CREATE", main._editor)
	note("create button: %s" % (create.text if create else "none"))
	await press(create)
	await wait(2.5)
	ed = main._editor
	note("new map %dx%d (Game %dx%d)" % [ed.W, ed.H, Game.W, Game.H])


# ------------------------------------------------------------------ painting everything
func part_paint() -> void:
	await new_map("84x84")
	await shot("new_84")
	var c := Vector2i(ed.W / 2, ed.H / 2)
	# the view: where are cells on screen? zoom out with the wheel / pinch to see the map
	if phone:
		await pinch(screen_size() * 0.5, false)
	else:
		await wheel(screen_size() * 0.55, false, 4)
	await wait(0.3)
	note("cell (20,20) is at %s on screen" % cell_spot(Vector2i(20, 20)))
	# HIGH ground, brush 6
	await pick_tool("HIGH")
	await press_button("6", ed)
	var u0: int = ed._undo.size()
	await paint_line(Vector2i(14, 14), Vector2i(22, 18))
	note("HIGH painted: cell(18,16)=%s, undo %d -> %d" % [cell_code(Vector2i(18, 16)), u0, ed._undo.size()])
	expect(ed._undo.size() == u0 + 1, "one stroke = one undo step (was %d, now %d)" % [u0, ed._undo.size()])
	await shot("painted_high")
	# RAMP across the plateau's edge
	await pick_tool("RAMP")
	await press_button("2", ed)
	await paint_line(Vector2i(25, 16), Vector2i(29, 16))
	note("RAMP: cell(27,16)=%s" % cell_code(Vector2i(27, 16)))
	# WATER, FORD, TREES, ROCKS
	await pick_tool("WATER")
	await press_button("3", ed)
	await paint_line(Vector2i(30, 50), Vector2i(55, 50))
	await pick_tool("FORD")
	await paint_line(Vector2i(42, 48), Vector2i(42, 52))
	await pick_tool("TREES")
	await press_button("SQUARE", ed)
	await paint_line(Vector2i(10, 60), Vector2i(20, 64))
	await pick_tool("ROCKS")
	await press_button("ROUND", ed)
	await paint_line(Vector2i(60, 20), Vector2i(64, 24))
	await shot("painted_all_terrain")
	# FILL: a box of low ground inside water, filled
	await pick_tool("WATER")
	await press_button("FILL", ed)
	var before := cell_code(Vector2i(70, 70))
	await put(Vector2i(70, 70))
	var after := cell_code(Vector2i(70, 70))
	var water := 0
	for ch in ed.cells:
		if ch == after:
			water += 1
	note("FILL at (70,70): %s -> %s, %d of %d cells now that" % [before, after, water, ed.cells.length()])
	await shot("filled_water")
	await press_button("UNDO", ed)
	await frames(3)
	note("after UNDO the fill: cell(70,70)=%s" % cell_code(Vector2i(70, 70)))
	await key(KEY_Y, {"ctrl": true})
	note("after Ctrl+Y: cell(70,70)=%s" % cell_code(Vector2i(70, 70)))
	await key(KEY_Z, {"ctrl": true})
	note("after Ctrl+Z: cell(70,70)=%s" % cell_code(Vector2i(70, 70)))
	# MIRROR: TURN 180, then start spots
	var mb: BaseButton = null
	for b in buttons(main._editor):
		if b is Button and (b as Button).text in ["OFF", "TURN 180", "LEFT | RIGHT", "TOP | BOTTOM", "4-WAY", "TURN 90"]:
			mb = b
	note("mirror shows '%s'" % ((mb as Button).text if mb else "?"))
	await pick_tool("START")
	await put(Vector2i(16, 14))
	note("after one START click: %d starts %s teams %s, says '%s'" % [ed.starts.size(), str(ed.starts), str(ed.teams), status()])
	await shot("starts")
	await pick_tool("HALL")
	await put(Vector2i(30, 30))
	note("halls %d, says '%s'" % [ed.halls.size(), status()])
	await pick_tool("TEAM")
	var t0 := str(ed.teams)
	await put(ed.starts[0] + Vector2i(2, 2))
	note("TEAM click: teams %s -> %s, says '%s'" % [t0, str(ed.teams), status()])
	expect(t0 != str(ed.teams), "TEAM changes a start's team")
	# PROPS: pick the first decoration, place one, erase it with a right click (computer)
	await pick_tool("PROPS")
	await shot("props_palette")
	var p0: int = ed.props.size()
	await put(Vector2i(50, 30))
	note("props %d -> %d, says '%s'" % [p0, ed.props.size(), status()])
	# REMOVE a hall spot
	await pick_tool("REMOVE")
	await put(ed.halls[0] + Vector2i(2, 2) if not ed.halls.is_empty() else Vector2i(30, 30))
	note("after REMOVE: halls %d" % ed.halls.size())
	# undo a lot, redo some
	var n_undo: int = ed._undo.size()
	for i in 6:
		await press_button("UNDO", ed, true)
	note("undo stack %d -> %d, redo %d" % [n_undo, ed._undo.size(), ed._redo.size()])
	for i in 3:
		await press_button("REDO", ed, true)
	note("after 3 REDO: undo %d redo %d" % [ed._undo.size(), ed._redo.size()])
	# CHECK
	await press_button("CHECK", ed)
	await wait(0.5)
	await shot("check")
	note("CHECK: %d problems: %s" % [ed.problems.size(), str(ed.problems.map(func(p: Dictionary) -> String: return String(p.get("text", "")))).substr(0, 600)])
	print("PT OFFSCREEN ", off_screen())
	# the name with odd characters, SAVE
	await set_name("Ünïcødé map: 1/2 <test>*?")
	await press_button("SAVE", ed)
	await wait(0.5)
	note("SAVE says '%s'; saved names %s" % [status(), str(MapGen.custom_names())])
	await shot("saved")
	# a second save under the same name: does it warn before overwriting?
	await pick_tool("ROCKS")
	await paint_line(Vector2i(70, 10), Vector2i(74, 10))
	await press_button("SAVE", ed)
	await wait(0.5)
	note("SAVE again (same name) says '%s'" % status())
	# LOAD dialog
	await press_button("LOAD", ed)
	await wait(0.5)
	await shot("load_dialog")
	note("LOAD dialog buttons: %s" % str(dialog_buttons().map(func(b: BaseButton) -> String: return (b as Button).text if b is Button else String(b.name))))
	var row: BaseButton = null
	for b in dialog_buttons():
		if b is Button and (b as Button).text.begins_with(ed.map_name):
			row = b
	if row:
		await press(row)
		await wait(2.5)
		ed = main._editor
		note("loaded back: name '%s' %dx%d starts %d props %d" % [ed.map_name, ed.W, ed.H, ed.starts.size(), ed.props.size()])
		await shot("loaded")
	# HELP
	await press_button("HELP", ed)
	await wait(0.4)
	await shot("help")
	await press_button("CLOSE", ed, true)
	# delete a map from LOAD (is it asked first?)
	await press_button("LOAD", ed)
	await wait(0.4)
	var before_n := MapGen.custom_names().size()
	var x: BaseButton = null
	for b in dialog_buttons():
		if b is Button and (b as Button).text == "×":
			x = b
	if x:
		await press(x)
		await wait(0.4)
		note("one press on × : maps %d -> %d (asked first? %s) says '%s'" % [before_n, MapGen.custom_names().size(), "no" if MapGen.custom_names().size() < before_n else "yes", status()])
		await shot("after_delete_once")
		var sure := button("SURE?", main._editor)
		if sure:
			await press(sure)
			await wait(0.4)
			note("SURE? pressed: maps now %d" % MapGen.custom_names().size())
			await shot("after_delete")
	await press_button("CLOSE", ed, true)
	# BACK with unsaved changes
	await pick_tool("WATER")
	await press_button("ROUND", ed)
	await paint_line(Vector2i(5, 5), Vector2i(10, 5))
	await press_button("BACK", ed)
	await wait(0.5)
	note("BACK with unsaved paint: editor open=%s, says '%s'" % [is_instance_valid(main._editor) and main._editor.is_visible_in_tree(), status()])
	await shot("back_unsaved")
	if is_instance_valid(main._editor) and main._editor.is_visible_in_tree():
		await press_button("BACK", main._editor)
		await wait(0.5)
		note("BACK again: editor open=%s, screen: %s" % [is_instance_valid(main._editor) and main._editor.is_visible_in_tree(), str(button_names()).substr(0, 200)])


# ------------------------------------------------------------------ sizes
func part_sizes() -> void:
	# the smallest: a preset, then "-" until it stops
	await new_map("64x64", {"-": 12})
	await shot("smallest")
	print("PT OFFSCREEN ", off_screen())
	await pick_tool("START")
	await put(Vector2i(4, 4))
	await put(Vector2i(ed.W - 6, ed.H - 6))
	note("smallest map: %dx%d, starts %d, says '%s'" % [ed.W, ed.H, ed.starts.size(), status()])
	await press_button("CHECK", ed)
	await wait(0.4)
	note("CHECK on the smallest: %s" % str(ed.problems.map(func(p: Dictionary) -> String: return String(p.get("text", "")))).substr(0, 500))
	await shot("smallest_check")
	# play the smallest map
	await set_name("Tiny")
	await press_button("PLAY", ed)
	await wait(1.5)
	if not (is_instance_valid(main._editor) and main._editor.is_inside_tree()):
		await press_button("START")
		await wait(6.0)
		var g := game()
		note("a match on the 32x32 map: %s" % ("started %dx%d" % [Game.W, Game.H] if g else "did not start"))
		await shot("tiny_match")
		if g:
			Engine.time_scale = 4.0
			await wait(20.0)
			Engine.time_scale = 1.0
			note("tiny match after %.0f s: over %s" % [g.clock, g.over])
			await shot("tiny_match_80s")
			await press_match_menu("QUIT TO MENU")
			await wait(1.0)
		await press_button("Menu_editor")
		await press_button("MAP EDITOR")
		await wait(1.0)
		ed = main._editor
	else:
		note("PLAY on the tiny map says '%s'" % status())
	# the huge one: how long does NEW take?
	var t0 := Time.get_ticks_msec()
	await new_map("256x256")
	note("NEW 256x256 took about %d ms (with waits)" % (Time.get_ticks_msec() - t0))
	await shot("huge")
	await pick_tool("HIGH")
	await press_button("8", ed)
	var t1 := Time.get_ticks_msec()
	await paint_line(Vector2i(40, 40), Vector2i(200, 200))
	note("a long stroke on 256x256 took %d ms" % (Time.get_ticks_msec() - t1))
	await pick_tool("WATER")
	await press_button("FILL", ed)
	t1 = Time.get_ticks_msec()
	await put(Vector2i(10, 240))
	note("FILL on 256x256 took %d ms" % (Time.get_ticks_msec() - t1))
	await shot("huge_painted")
	await press_button("CHECK", ed)
	await wait(1.0)
	note("CHECK on huge: %d problems" % ed.problems.size())


# ------------------------------------------------------------------ a map made and played
func part_play() -> void:
	var four := args.has("four")
	await new_map("158x158" if four else "104x104")
	await pick_tool("START")
	var spots: Array = [Vector2i(14, 14), Vector2i(ed.W - 20, ed.H - 20)]
	if four:
		spots += [Vector2i(ed.W - 20, 14), Vector2i(14, ed.H - 20)]
	# with the mirror (TURN 180 by default) one click places two
	await put(spots[0])
	note("after one START: %d starts (mirror '%s')" % [ed.starts.size(), ed.mirror])
	if four:
		await put(spots[2])
		note("after two START: %d starts teams %s mode %s" % [ed.starts.size(), str(ed.teams), ed.mode()])
	await pick_tool("HALL")
	await put(Vector2i(ed.W / 2 - 20, ed.H / 2))
	await set_name("Playtest %s" % ("four" if four else "duel"))
	await press_button("CHECK", ed)
	await wait(0.5)
	note("CHECK: %s" % str(ed.problems.map(func(p: Dictionary) -> String: return String(p.get("text", "")))).substr(0, 500))
	await shot("before_play")
	await press_button("PLAY", ed)
	await wait(1.0)
	if is_instance_valid(main._editor) and main._editor.is_inside_tree():
		note("PLAY asks first: '%s'" % status())
		await press_button("PLAY", main._editor)
	await wait(1.5)
	await shot("lobby_after_play")
	note("after PLAY: editor %s, lobby map %s, slots %d" % [is_instance_valid(main._editor) and main._editor.is_inside_tree(), main.lobby.get("map"), main.lobby["slots"].size()])
	print("PT OFFSCREEN ", off_screen())
	var st := button("START") if button("START") else button("START MATCH")
	if not expect(st != null, "the lobby has START"):
		note(str(button_names()))
		return
	await press(st)
	await wait(5.0)
	var g := game()
	if not expect(g != null and not g.edit_mode, "the match on the made map started"):
		return
	note("match map %s %dx%d teams %d" % [g.map_id, Game.W, Game.H, g.n_players()])
	await shot("match_start")
	Engine.time_scale = 4.0
	await wait(60.0)
	Engine.time_scale = 1.0
	note("after 4 min game time: clock %.0f over %s" % [g.clock, g.over])
	var per: Array = []
	for t in g.n_players():
		var nb := 0
		var nu := 0
		for b in g.buildings:
			if b.team == t and not b.dead:
				nb += 1
		for u in g.units:
			if u.team == t and not u.dead:
				nu += 1
		per.append("P%d %s: %d buildings %d units" % [t + 1, g.factions[t] if "factions" in g else "?", nb, nu])
	note("sides: %s" % str(per))
	await shot("match_4min")
	await press_match_menu("QUIT TO MENU")
	await wait(1.5)
	await shot("after_quit")


# ------------------------------------------------------------------ trying to break it
func part_break() -> void:
	for nm in ["Walled in", "Flooded", "Keep me", "_CON", "aaaaaaaaaaaaaaaaaaaaaaaa", "名前のマップ"]:
		MapGen.delete_custom(nm)
	await new_map("84x84")
	# PLAY with no start spots
	await press_button("PLAY", ed)
	await wait(0.4)
	note("PLAY with no starts says '%s'" % status())
	await shot("play_no_starts")
	# a start walled in by water
	await pick_tool("START")
	await put(Vector2i(14, 14))
	await pick_tool("WATER")
	await press_button("SQUARE", ed)
	await press_button("2", ed)
	await paint_line(Vector2i(8, 8), Vector2i(26, 8))
	await paint_line(Vector2i(26, 8), Vector2i(26, 26))
	await paint_line(Vector2i(26, 26), Vector2i(8, 26))
	await paint_line(Vector2i(8, 26), Vector2i(8, 8))
	await shot("walled_start")
	await set_name("Walled in")
	await press_button("PLAY", ed)
	await wait(0.6)
	note("PLAY with a walled-in start says '%s', still in editor %s" % [status(), is_instance_valid(main._editor) and main._editor.is_inside_tree()])
	await shot("play_walled")
	# flood the whole map with water
	await press_button("FILL", ed)
	await put(Vector2i(50, 50))
	var w := 0
	for ch in ed.cells:
		if ch == "w":
			w += 1
	note("flooded: %d of %d cells water" % [w, ed.cells.length()])
	await press_button("CHECK", ed)
	await wait(0.5)
	note("CHECK flooded: %s" % str(ed.problems.map(func(p: Dictionary) -> String: return String(p.get("text", "")))).substr(0, 500))
	await shot("flooded")
	await set_name("Flooded")
	await press_button("PLAY", ed)
	await wait(0.5)
	note("PLAY a flooded map says '%s'; editor open %s; problems %s" % [status(), is_instance_valid(main._editor) and main._editor.is_inside_tree(), str(main._editor.problems.map(func(p: Dictionary) -> String: return String(p.get("text", ""))))])
	await shot("play_flooded")
	if not (is_instance_valid(main._editor) and main._editor.is_inside_tree()):
		await shot("flooded_lobby")
		var st := button("START")
		if st:
			await press(st)
			await wait(6.0)
			note("flooded match: game %s over %s" % [game() != null, game().over if game() else "-"])
			await shot("flooded_match")
			if game():
				await press_match_menu("QUIT TO MENU")
				await wait(1.0)
		return
	# a NEW map saved under the name of another map: is it asked first?
	MapGen.save_custom({"name": "Keep me", "size": [64, 64], "cells": ".".repeat(64 * 64), "starts": [], "halls": [], "props": []})
	await set_name("Keep me")
	await press_button("SAVE", ed)
	await wait(0.3)
	var kept := MapGen.load_custom("Keep me")
	note("SAVE under an existing map's name says '%s'; the other map still %s" % [status(), "64x64 (kept)" if MapGen.custom_size(kept) == Vector2i(64, 64) else "REPLACED"])
	# names: empty, spaces only, very long, dots
	for nm in ["", "   ", "..", "CON", "a".repeat(40), "名前のマップ"]:
		await set_name(nm)
		await press_button("SAVE", ed)
		await wait(0.3)
		note("SAVE with name '%s' -> map_name '%s' says '%s'" % [nm, main._editor.map_name, status()])
	note("maps now: %s" % str(MapGen.custom_names()))
	# spam: NEW, CANCEL, LOAD, CLOSE, HELP many times quickly, and press keys while the name box has focus
	for i in 4:
		await press_button("NEW", ed, true)
		await press_button("LOAD", ed, true)
		await press_button("HELP", ed, true)
	await shot("spam_dialogs")
	note("dialogs open after spam: %d" % main._editor._ui.get_children().filter(func(c: Node) -> bool: return c.has_meta("dialog")).size())


# ------------------------------------------------------------------ mirrors, biomes, props, the phone's DRAG
func mirror_button() -> Button:
	for b in buttons(main._editor):
		if b is Button and String((b as Button).text) in ["OFF", "TURN 180", "LEFT | RIGHT", "TOP | BOTTOM", "4-WAY", "TURN 90"]:
			return b
	return null


func part_tools() -> void:
	for sz in ["128x96", "104x104"]:
		await new_map(sz)
		var seen: Array = []
		for i in 7:
			var mb := mirror_button()
			if mb == null:
				break
			seen.append((mb as Button).text)
			await press(mb)
			await frames(2)
		note("MIRROR on %s cycles: %s" % [sz, str(seen)])
	# 4-WAY: one START click
	while mirror_button() and mirror_button().text != "4-WAY":
		await press(mirror_button())
	await pick_tool("START")
	await put(Vector2i(14, 14))
	note("4-WAY START: %d starts, teams %s, mode %s" % [ed.starts.size(), str(ed.teams), ed.mode()])
	await shot("four_way_starts")
	# LAND and MIX
	await press_button("GRASS", ed)
	await wait(0.4)
	await shot("land_dialog")
	note("LAND dialog: %s" % str(dialog_buttons().map(func(b: BaseButton) -> String: return (b as Button).text if b is Button else "")).substr(0, 300))
	var snow := button("SNOW", main._editor)
	if snow:
		await press(snow)
		await wait(2.5)
		ed = main._editor
	note("biome now %s / %s" % [ed.biome_a, ed.biome_b])
	await press_button("MIX", ed)
	await wait(0.4)
	var vol := button("VOLCANIC", main._editor)
	if vol:
		await press(vol)
		await wait(2.5)
		ed = main._editor
	note("mix now %s + %s (%s); WATER tool reads '%s'" % [ed.biome_a, ed.biome_b, ed.mix, "LAVA" if button("LAVA", main._editor) else "WATER"])
	await shot("mixed_biomes")
	var bl := button("BLEND", main._editor)
	if bl:
		await press(bl)
		await wait(2.0)
		note("BLEND now %s" % main._editor.mix)
		await shot("blend")
	# props: place, ERASE mode, erase it
	await pick_tool("PROPS")
	var before: int = ed.props.size()
	await put(Vector2i(60, 30))
	note("a prop placed: %d -> %d" % [before, ed.props.size()])
	await press_button("ERASE", ed)
	await put(Vector2i(60, 30))
	note("ERASE click: %d props" % ed.props.size())
	if not phone:
		await press_button("PLACE", ed)
		await put(Vector2i(70, 40))
		var n1: int = ed.props.size()
		await click(cell_spot(Vector2i(70, 40)), MOUSE_BUTTON_RIGHT)
		note("a right click on a prop: %d -> %d" % [n1, ed.props.size()])
	# the phone's DRAG: PAN, then a finger drag must move the view, not paint
	if phone:
		await pick_tool("HIGH")
		var dp := button("DRAG", main._editor)
		if dp:
			await press(dp)
			ed = main._editor
			var cam0: Vector2 = game().camera.position if game() else Vector2.ZERO
			var u0: int = ed._undo.size()
			await touch_drag(screen_size() * 0.5, screen_size() * 0.5 + Vector2(-200, -80))
			note("DRAG: PAN, a finger drag: camera moved %s, undo %d -> %d (painted? %s)" % [str((game().camera.position - cam0) if game() else Vector2.ZERO), u0, ed._undo.size(), ed._undo.size() > u0])
			# and a pinch in PAINT mode paints nothing (the fix)
			await press(button("DRAG", main._editor))
			ed = main._editor
			u0 = ed._undo.size()
			var c0 := ed.cells
			await pinch(screen_size() * 0.5, true)
			note("DRAG: PAINT, a pinch: undo %d -> %d, cells changed %s" % [u0, ed._undo.size(), ed.cells != c0])
	await shot("tools_end")
