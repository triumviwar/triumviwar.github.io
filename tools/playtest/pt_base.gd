extends SceneTree
## PLAYTEST DRIVER BASE (docs/playtest_2026_11_21_tutorial_editor.md): the game is started from its main scene and
## played through REAL input events (mouse, keys, touch) sent through Input.parse_input_event at the screen spots of
## the real buttons, as a person would. Scripts extend this file and write their run in `play()`.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --rendering-driver opengl3 --audio-driver Dummy \
##       --resolution 1280x720 --script res://tools/playtest/<script>.gd -- [lang:pt] [phone] [out:<dir>] [seed:<n>]
## Every engine error and warning seen while it runs is counted (a Logger) and listed at the end with "PT ERROR".
## Lines: "PT STEP ...", "PT NOTE ...", "PT FIND ..." (a finding to look at), "PT SHOT <path>".

var main: Node
var out := "res://docs/shots/playtest_2026_11_21/tutorial_editor"
var lang := "en"
var phone := false
var tag := ""                 # file name prefix (the size and language)
var seed_n := 1
var args := {}
var errors: Array = []        # [text]
var finds: Array = []
var _shot_n := 0
var _logger: PTLogger


class PTLogger extends Logger:
	var owner_ref: WeakRef

	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool,
			error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		var o = owner_ref.get_ref()
		if o == null:
			return
		var kind: String = ["ERROR", "WARNING", "SCRIPT ERROR", "SHADER ERROR"][clampi(error_type, 0, 3)]
		var t := "%s %s: %s (%s:%d %s)" % [kind, code, rationale, file, line, function]
		o.errors.append(t)

	func _log_message(_message: String, _error: bool) -> void:
		pass


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var s := String(a)
		if s.contains(":"):
			args[s.get_slice(":", 0)] = s.substr(s.find(":") + 1)
		else:
			args[s] = true
	lang = String(args.get("lang", "en"))
	phone = args.has("phone")
	seed_n = int(args.get("seed", "1"))
	if args.has("out"):
		out = String(args["out"])
	tag = "%s_%s_" % ["phone" if phone else "pc", lang]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	_logger = PTLogger.new()
	_logger.owner_ref = weakref(self)
	OS.add_logger(_logger)
	if not args.has("keepcrash"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	Settings.load_all()
	Settings.device = "mobile" if phone else "pc"
	Settings.set_language(lang)
	Settings.save_all()
	Settings.apply()
	seed(seed_n)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_go.call_deferred()


func _go() -> void:
	await wait(1.5)
	var ok := true
	await play()
	finish()


## The script's run (override).
func play() -> void:
	pass


func finish() -> void:
	print("PT ======== summary (%s) ========" % tag)
	var seen := {}
	for e in errors:
		var k := String(e).substr(0, 220)
		seen[k] = int(seen.get(k, 0)) + 1
	for k in seen:
		print("PT ERROR x%d %s" % [seen[k], k])
	for f in finds:
		print("PT FIND ", f)
	print("PT DONE errors=%d finds=%d" % [errors.size(), finds.size()])
	OS.remove_logger(_logger)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	quit(0)


# ------------------------------------------------------------------ time
func wait(sec: float) -> void:
	await create_timer(sec, true, false, true).timeout


func frames(n := 2) -> void:
	for i in n:
		await process_frame


# ------------------------------------------------------------------ notes
func step(t: String) -> void:
	print("PT STEP ", t)


func note(t: String) -> void:
	print("PT NOTE ", t)


func find(t: String) -> void:
	finds.append(t)
	print("PT FIND ", t)


func expect(ok: bool, what: String) -> bool:
	print("PT CHECK %-4s %s" % ["ok" if ok else "FAIL", what])
	if not ok:
		find("check failed: " + what)
	return ok


func shot(name: String) -> String:
	await frames(2)
	await RenderingServer.frame_post_draw
	_shot_n += 1
	var p := "%s/%s%02d_%s.jpg" % [out, tag, _shot_n, name]
	var img := root.get_viewport().get_texture().get_image()
	if img:
		img.save_jpg(ProjectSettings.globalize_path(p), 0.85)
		print("PT SHOT ", p)
	return p


# ------------------------------------------------------------------ finding things on screen
## Every visible Button in the tree (under `from`, default the whole root).
func buttons(from: Node = null) -> Array:
	var outl: Array = []
	for b in (from if from else root).find_children("*", "BaseButton", true, false):
		if (b as Control).is_visible_in_tree():
			outl.append(b)
	return outl


## A visible button by node name (exact) or by its text (case-insensitive, the shown text). null none.
func button(what: String, from: Node = null) -> BaseButton:
	var bs := buttons(from)
	for b in bs:
		if String(b.name) == what:
			return b
	# (a button's text may be the English key, shown translated, or already translated: Loc.t)
	for w in [what.to_lower(), Loc.t(what).to_lower(), Loc.t(what + " SPOT").to_lower()]:
		for b in bs:
			if b is Button and String((b as Button).text).strip_edges().to_lower() == w:
				return b
	for w in [what.to_lower(), Loc.t(what).to_lower()]:
		for b in bs:
			if b is Button and String((b as Button).text).to_lower().contains(w):
				return b
	return null


func texts_on_screen() -> Array:
	var outl: Array = []
	for c in root.find_children("*", "Control", true, false):
		var cc := c as Control
		if not cc.is_visible_in_tree():
			continue
		if c is Label and (c as Label).text != "":
			outl.append((c as Label).text)
		elif c is Button and (c as Button).text != "":
			outl.append((c as Button).text)
	return outl


## Controls whose rect leaves the screen (a layout check), not counting things inside a ScrollContainer.
func off_screen() -> Array:
	var vs := root.get_visible_rect()
	var outl: Array = []
	for c in root.find_children("*", "Control", true, false):
		var cc := c as Control
		if not cc.is_visible_in_tree() or cc.size.x < 2 or cc.size.y < 2:
			continue
		if not (cc is Button or cc is Label):
			continue
		var p := cc.get_parent()
		var in_scroll := false
		while p:
			if p is ScrollContainer:
				in_scroll = true
				break
			p = p.get_parent()
		if in_scroll:
			continue
		var r := cc.get_global_rect()
		if r.position.x < vs.position.x - 2 or r.position.y < vs.position.y - 2 or r.end.x > vs.end.x + 2 or r.end.y > vs.end.y + 2:
			var t := String(cc.text) if (cc is Label or cc is Button) else ""
			outl.append("%s '%s' %s" % [cc.name, t.substr(0, 40), r])
	return outl


## Labels whose text does not fit (clipped / overrunning) as far as Godot can tell.
func clipped_labels() -> Array:
	var outl: Array = []
	for c in root.find_children("*", "Button", true, false):
		var b := c as Button
		if not b.is_visible_in_tree() or b.text == "" or b.clip_text == false:
			continue
		var f := b.get_theme_font("font")
		var fs := b.get_theme_font_size("font_size")
		if f and f.get_string_size(b.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > b.size.x - 4:
			outl.append("%s '%s'" % [b.name, b.text])
	return outl


# ------------------------------------------------------------------ input
func to_window(p: Vector2) -> Vector2:
	return root.get_final_transform() * p


func move_mouse(p: Vector2) -> void:
	var e := InputEventMouseMotion.new()
	e.position = to_window(p)
	e.global_position = e.position
	Input.warp_mouse(e.position)
	Input.parse_input_event(e)


func mouse_button(p: Vector2, btn := MOUSE_BUTTON_LEFT, pressed := true, dbl := false, mods := {}) -> void:
	var e := InputEventMouseButton.new()
	e.position = to_window(p)
	e.global_position = e.position
	e.button_index = btn
	e.pressed = pressed
	e.double_click = dbl
	e.ctrl_pressed = bool(mods.get("ctrl", false))
	e.shift_pressed = bool(mods.get("shift", false))
	if pressed:
		e.button_mask = {MOUSE_BUTTON_LEFT: MOUSE_BUTTON_MASK_LEFT, MOUSE_BUTTON_RIGHT: MOUSE_BUTTON_MASK_RIGHT,
			MOUSE_BUTTON_MIDDLE: MOUSE_BUTTON_MASK_MIDDLE}.get(btn, 0)
	Input.parse_input_event(e)


func click(p: Vector2, btn := MOUSE_BUTTON_LEFT, mods := {}) -> void:
	move_mouse(p)
	await frames(1)
	mouse_button(p, btn, true, false, mods)
	await frames(1)
	mouse_button(p, btn, false, false, mods)
	await frames(2)


func double_click(p: Vector2) -> void:
	await click(p)
	mouse_button(p, MOUSE_BUTTON_LEFT, true, true)
	await frames(1)
	mouse_button(p, MOUSE_BUTTON_LEFT, false)
	await frames(2)


func drag(a: Vector2, b: Vector2, btn := MOUSE_BUTTON_LEFT, steps := 8) -> void:
	move_mouse(a)
	await frames(1)
	mouse_button(a, btn, true)
	await frames(1)
	for i in range(1, steps + 1):
		var p := a.lerp(b, float(i) / steps)
		var e := InputEventMouseMotion.new()
		e.position = to_window(p)
		e.global_position = e.position
		e.relative = (b - a) / steps
		e.button_mask = {MOUSE_BUTTON_LEFT: MOUSE_BUTTON_MASK_LEFT, MOUSE_BUTTON_RIGHT: MOUSE_BUTTON_MASK_RIGHT,
			MOUSE_BUTTON_MIDDLE: MOUSE_BUTTON_MASK_MIDDLE}.get(btn, 0)
		Input.parse_input_event(e)
		await frames(1)
	mouse_button(b, btn, false)
	await frames(2)


func wheel(p: Vector2, up := true, n := 3) -> void:
	move_mouse(p)
	for i in n:
		mouse_button(p, MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN, true)
		await frames(1)
		mouse_button(p, MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN, false)
		await frames(1)


func touch(p: Vector2, pressed: bool, idx := 0) -> void:
	var e := InputEventScreenTouch.new()
	e.position = to_window(p)
	e.index = idx
	e.pressed = pressed
	Input.parse_input_event(e)


func tap(p: Vector2) -> void:
	touch(p, true)
	await frames(2)
	touch(p, false)
	await frames(3)


func touch_drag(a: Vector2, b: Vector2, idx := 0, steps := 8) -> void:
	touch(a, true, idx)
	await frames(1)
	for i in range(1, steps + 1):
		var e := InputEventScreenDrag.new()
		e.position = to_window(a.lerp(b, float(i) / steps))
		e.relative = (b - a) / steps
		e.index = idx
		Input.parse_input_event(e)
		await frames(1)
	touch(b, false, idx)
	await frames(2)


## A two-finger drag (both fingers move by `d`).
func two_finger_drag(c: Vector2, d: Vector2, spread := 60.0, steps := 8) -> void:
	var a0 := c - Vector2(spread, 0)
	var a1 := c + Vector2(spread, 0)
	touch(a0, true, 0)
	touch(a1, true, 1)
	await frames(2)
	for i in range(1, steps + 1):
		for k in 2:
			var e := InputEventScreenDrag.new()
			var base := a0 if k == 0 else a1
			e.position = to_window(base + d * float(i) / steps)
			e.relative = d / steps
			e.index = k
			Input.parse_input_event(e)
		await frames(1)
	touch(a0 + d, false, 0)
	touch(a1 + d, false, 1)
	await frames(2)


## Pinch: the two fingers move apart (out=true) or together.
func pinch(c: Vector2, out_ := true, steps := 8) -> void:
	var s0 := 40.0 if out_ else 160.0
	var s1 := 160.0 if out_ else 40.0
	touch(c - Vector2(s0, 0), true, 0)
	touch(c + Vector2(s0, 0), true, 1)
	await frames(2)
	for i in range(1, steps + 1):
		var s := lerpf(s0, s1, float(i) / steps)
		for k in 2:
			var e := InputEventScreenDrag.new()
			e.position = to_window(c + Vector2(s if k == 1 else -s, 0))
			e.index = k
			e.relative = Vector2((s1 - s0) / steps * (1 if k == 1 else -1), 0)
			Input.parse_input_event(e)
		await frames(1)
	touch(c - Vector2(s1, 0), false, 0)
	touch(c + Vector2(s1, 0), false, 1)
	await frames(2)


## Press the thing a person would: a click on a computer, a tap on a phone.
func press_at(p: Vector2) -> void:
	if phone:
		await tap(p)
	else:
		await click(p)


func press(c: Control) -> bool:
	if c == null or not is_instance_valid(c):
		return false
	await scroll_into_view(c)
	var r := c.get_global_rect()
	await press_at(r.get_center())
	await frames(2)
	return true


## Press a button found by name or text; false (and a finding) if it is not on screen.
func press_button(what: String, from: Node = null, quiet := false) -> bool:
	var b := button(what, from)
	if b == null:
		if not quiet:
			find("no button '%s' on screen (screen has: %s)" % [what, str(button_names()).substr(0, 400)])
		return false
	if b.disabled:
		note("button '%s' is disabled" % what)
	step("press " + what)
	await press(b)
	return true


func button_names() -> Array:
	var outl: Array = []
	for b in buttons():
		outl.append(String((b as Button).text) if b is Button and (b as Button).text != "" else String(b.name))
	return outl


func key(k: Key, mods := {}, hold := 0.0) -> void:
	var e := InputEventKey.new()
	e.keycode = k
	e.physical_keycode = k
	e.pressed = true
	e.ctrl_pressed = bool(mods.get("ctrl", false))
	e.shift_pressed = bool(mods.get("shift", false))
	e.alt_pressed = bool(mods.get("alt", false))
	Input.parse_input_event(e)
	await frames(1)
	if hold > 0.0:
		await wait(hold)
	var r := e.duplicate()
	r.pressed = false
	Input.parse_input_event(r)
	await frames(2)


func screen_size() -> Vector2:
	return root.get_visible_rect().size


# ------------------------------------------------------------------ the game world
func game() -> Game:
	return main.game if main and is_instance_valid(main.game) else null


## The screen spot of a world point (the game's camera).
func world_to_screen(w: Vector2) -> Vector2:
	return root.get_canvas_transform() * w


# ------------------------------------------------------------------ the HUD (drawn by hand: its "buttons" are rects)
func hud() -> Control:
	var g := game()
	return g.hud if g else null


## A HUD-local rect on the screen.
func hud_rect(r: Rect2) -> Rect2:
	var h := hud()
	var xf: Transform2D = h.get_global_transform()
	return Rect2(xf * r.position, xf.basis_xform(r.size))


func hud_layout_rect(key_: String) -> Rect2:
	var h := hud()
	var rects: Dictionary = h._layout()
	return hud_rect(rects[key_]) if rects.has(key_) else Rect2()


## The screen spot of a world point on the minimap.
func mini_spot(w: Vector2) -> Vector2:
	var m := hud_layout_rect("mini")
	var f := w / (Vector2(Game.W, Game.H) * Game.T)
	return m.position + f * m.size


## The command card's buttons now: [{icon, label, rect (screen)}].
func card() -> Array:
	var h := hud()
	if h == null:
		return []
	h._refresh_card()
	var outl: Array = []
	for b in h.get("_card_buttons"):
		var it: Variant = b.get("item", [])
		if it is Array and not (it as Array).is_empty():
			outl.append({"icon": String(it[0]), "label": String(it[1]).trim_prefix("> ").trim_prefix("~ "),
				"enabled": bool(b.get("enabled", true)), "rect": hud_rect(b["rect"])})
	return outl


func card_labels() -> Array:
	return card().map(func(c: Dictionary) -> String: return c["label"])


## Press a command card button by its label (case-insensitive) or icon id.
func press_card(what: String) -> bool:
	var w := what.to_lower()
	var cs := card()
	var hit: Dictionary = {}
	for c in cs:
		if String(c["label"]).to_lower() == w or String(c["icon"]) == what:
			hit = c
	if hit.is_empty():
		for c in cs:          # ("POWDER 0/1" for POWDER MILL, "FARM 1/2"..., "RAPTORS" for RAPTOR: the first word)
			var f := String(c["label"]).to_lower().get_slice(" ", 0)
			if f == w.get_slice(" ", 0) or (f.begins_with(w) and f.length() <= w.length() + 1):
				hit = c
	if not hit.is_empty():
		step("card %s (shown '%s')" % [what, hit["label"]])
		await press_at((hit["rect"] as Rect2).get_center())
		return true
	find("no card button '%s' (card: %s)" % [what, str(card_labels())])
	return false


## The match menu (MENU top right) and its buttons.
func open_match_menu() -> void:
	var h := hud()
	await press_at(hud_rect(h.menu_rect()).get_center())


func press_match_menu(label: String) -> bool:
	var h := hud()
	if not h.menu_open:
		await open_match_menu()
	for b in h._menu_buttons():
		if String(b["label"]).to_upper().begins_with(label.to_upper()):
			step("menu " + label)
			await press_at(hud_rect(b["rect"]).get_center())
			return true
	find("no match menu button '%s'" % label)
	return false


## Is a world point on screen (in the map's view, not behind the HUD)?
func in_view(w: Vector2) -> bool:
	var p := world_to_screen(w)
	var vs := screen_size()
	if phone:          # (a phone: the lesson's two panels and the HUD leave a band in the middle)
		return Rect2(vs.x * 0.05, vs.y * 0.33, vs.x * 0.9, vs.y * 0.27).has_point(p)
	return Rect2(Vector2(20, 60), vs - Vector2(40, 60 + vs.y * 0.3)).has_point(p)


## Look at a world point as a player would: a click (tap) on the minimap there.
func look_at(w: Vector2) -> void:
	await press_at(mini_spot(w))
	await wait(0.3)


# ------------------------------------------------------------------ missions and lessons
func mission_ui() -> MissionUi:
	for n in main.ui_layer.get_children():
		if n is MissionUi:
			return n
	return null


## What the lesson shows now: the teacher's line and the active tasks.
func lesson_state() -> String:
	var g := game()
	if g == null or g.mission == null:
		return "(no mission)"
	var ui := mission_ui()
	var line := ""
	if ui and not ui.current.is_empty():
		line = Loc.t(String(ui.current.get("text", "")))
	var tasks: Array = []
	for o in g.mission.objectives_for(g.mission.my_side()):
		var st := String(g.mission.obj.get(String(o.get("id", "")), ""))
		if st == "active":
			tasks.append(g.mission.objective_text(o))
	return "LINE: %s | TASKS: %s | POINTER: %s" % [line, str(tasks), str(g.mission.pointer)]


func task_ids_active() -> Array:
	var g := game()
	var out_: Array = []
	if g == null or g.mission == null:
		return out_
	for k in g.mission.obj:
		if String(g.mission.obj[k]) == "active":
			out_.append(String(k))
	return out_


## The pointer's target on screen: ["world"|"ui"|"", Vector2 or Rect2].
func pointer_target() -> Array:
	var ui := mission_ui()
	if ui == null:
		return ["", null]
	return ui._pointer.target()


## Read on: NEXT pressed until the step's last line (as a reader would), at most n times.
func read_lines(n := 6) -> void:
	var ui := mission_ui()
	for i in n:
		if ui == null or ui.queue.is_empty():
			return
		var b := button("Dialogue_NEXT")
		if b == null:
			return
		await press(b)
		await wait(0.3)


## The screen rect of the group bar's button for group n (1-9, 0).
func group_slot(n: int) -> Rect2:
	var h := hud()
	var i := HotkeyBar.GROUP0 + (9 if n == 0 else n - 1)
	return hud_rect(h.bar.button_rect(i))


## A control inside a scrolled list that is out of the list's view: the list is scrolled as a person would (the
## wheel over it, a finger drag on a phone) until it shows.
func scroll_into_view(c: Control) -> void:
	var p := c.get_parent()
	var sc: ScrollContainer = null
	while p:
		if p is ScrollContainer:
			sc = p
			break
		p = p.get_parent()
	if sc == null:
		return
	for i in 12:
		var vr := sc.get_global_rect()
		var r := c.get_global_rect()
		if vr.encloses(r) or r.size.y > vr.size.y:
			return
		var down := r.get_center().y > vr.get_center().y
		var before := sc.scroll_vertical
		if phone:
			var mid := vr.get_center()
			await touch_drag(mid, mid + Vector2(0, -120 if down else 120))
		if sc.scroll_vertical == before:
			if phone and i == 0:
				note("a finger drag did not scroll the list here (no touchscreen in this test machine?): the wheel instead")
			await wheel(vr.get_center(), not down, 2)
		await frames(2)
