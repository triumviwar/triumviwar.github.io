extends RefCounted
## Real input for the playtest drivers (job playtest-skirmish-clockwork, docs/playtest_2026_11_21_skirmish_clockwork.md).
## Everything goes through Input.parse_input_event as the OS would send it: mouse buttons and motion (the engine
## makes the emulated touches from them, as on a real computer), keys with modifiers, and real screen touches for a
## phone. Positions are in the root viewport's coordinates (what Control.get_global_rect and the HUD's rects give);
## win() turns them into window coordinates, which is what the OS events carry.

var tree: SceneTree
var mouse := Vector2(640, 360)
var held_mask := 0
var log_lines: Array = []
var shots_dir := ""
var shot_n := 0


func _init(t: SceneTree) -> void:
	tree = t


func win(p: Vector2) -> Vector2:
	return tree.root.get_final_transform() * p


func vs() -> Vector2:
	return tree.root.get_visible_rect().size


func frames(n := 1) -> void:
	for i in n:
		await tree.process_frame


func wait(secs: float) -> void:
	# real seconds, as a player waits (Engine.time_scale still speeds the match up)
	var until := Time.get_ticks_msec() + int(secs * 1000.0)
	while Time.get_ticks_msec() < until:
		await tree.process_frame


func note(s: String) -> void:
	log_lines.append(s)
	print("PT  " + s)


# ------------------------------------------------------------------ mouse

func _mods(e: InputEventWithModifiers, shift: bool, ctrl: bool, alt := false) -> void:
	e.shift_pressed = shift
	e.ctrl_pressed = ctrl
	e.alt_pressed = alt


func move_to(p: Vector2, shift := false, ctrl := false) -> void:
	var e := InputEventMouseMotion.new()
	e.position = win(p)
	e.global_position = win(p)
	e.relative = win(p) - win(mouse)
	e.button_mask = held_mask
	_mods(e, shift, ctrl)
	mouse = p
	Input.parse_input_event(e)


func button(p: Vector2, btn: int, pressed: bool, shift := false, ctrl := false, dbl := false, alt := false) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = btn as MouseButton
	e.pressed = pressed
	e.double_click = dbl
	e.position = win(p)
	e.global_position = win(p)
	var bit := 0
	match btn:
		MOUSE_BUTTON_LEFT: bit = MOUSE_BUTTON_MASK_LEFT
		MOUSE_BUTTON_RIGHT: bit = MOUSE_BUTTON_MASK_RIGHT
		MOUSE_BUTTON_MIDDLE: bit = MOUSE_BUTTON_MASK_MIDDLE
	if pressed:
		held_mask |= bit
	else:
		held_mask &= ~bit
	e.button_mask = held_mask
	_mods(e, shift, ctrl, alt)
	Input.parse_input_event(e)


## A click as a hand makes it: move there, press, a frame, let go.
func click(p: Vector2, btn := MOUSE_BUTTON_LEFT, shift := false, ctrl := false, alt := false) -> void:
	move_to(p, shift, ctrl)
	await frames(1)
	if shift:
		key_down(KEY_SHIFT)
	if ctrl:
		key_down(KEY_CTRL)
	button(p, btn, true, shift, ctrl, false, alt)
	await frames(1)
	button(p, btn, false, shift, ctrl, false, alt)
	await frames(1)
	if shift:
		key_up(KEY_SHIFT)
	if ctrl:
		key_up(KEY_CTRL)


func rclick(p: Vector2, shift := false) -> void:
	await click(p, MOUSE_BUTTON_RIGHT, shift)


func dclick(p: Vector2) -> void:
	move_to(p)
	await frames(1)
	button(p, MOUSE_BUTTON_LEFT, true)
	await frames(1)
	button(p, MOUSE_BUTTON_LEFT, false)
	await frames(2)
	button(p, MOUSE_BUTTON_LEFT, true, false, false, true)
	await frames(1)
	button(p, MOUSE_BUTTON_LEFT, false)
	await frames(2)


## Press at a, move in steps to b, let go (a box select with the left button, a line with the right).
func drag(a: Vector2, b: Vector2, btn := MOUSE_BUTTON_LEFT, steps := 8, shift := false) -> void:
	move_to(a, shift)
	await frames(1)
	if shift:
		key_down(KEY_SHIFT)
	button(a, btn, true, shift)
	await frames(1)
	for i in steps:
		move_to(a.lerp(b, float(i + 1) / steps), shift)
		await frames(1)
	button(b, btn, false, shift)
	await frames(1)
	if shift:
		key_up(KEY_SHIFT)
	await frames(1)


func wheel(p: Vector2, up: bool, n := 1) -> void:
	move_to(p)
	for i in n:
		button(p, MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN, true)
		await frames(1)
		button(p, MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN, false)
		await frames(1)


# ------------------------------------------------------------------ keys

func _key(kc: int, pressed: bool, shift := false, ctrl := false, alt := false) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = kc as Key
	e.physical_keycode = kc as Key
	e.pressed = pressed
	if kc >= KEY_A and kc <= KEY_Z:
		e.unicode = kc + 32 if not shift else kc
	_mods(e, shift, ctrl, alt)
	return e


func key_down(kc: int, shift := false, ctrl := false, alt := false) -> void:
	Input.parse_input_event(_key(kc, true, shift, ctrl, alt))


func key_up(kc: int, shift := false, ctrl := false, alt := false) -> void:
	Input.parse_input_event(_key(kc, false, shift, ctrl, alt))


## A key tapped (modifiers held around it, as fingers do).
func key(kc: int, shift := false, ctrl := false, alt := false) -> void:
	if shift: key_down(KEY_SHIFT, true)
	if ctrl: key_down(KEY_CTRL, shift, true)
	if alt: key_down(KEY_ALT, shift, ctrl, true)
	await frames(1)
	key_down(kc, shift, ctrl, alt)
	await frames(2)
	key_up(kc, shift, ctrl, alt)
	await frames(1)
	if alt: key_up(KEY_ALT, shift, ctrl)
	if ctrl: key_up(KEY_CTRL, shift)
	if shift: key_up(KEY_SHIFT)
	await frames(1)


## A key held for a while (arrow keys pan the camera).
func hold_key(kc: int, secs: float) -> void:
	key_down(kc)
	await wait(secs)
	key_up(kc)
	await frames(1)


# ------------------------------------------------------------------ touch (phone)

func touch(i: int, p: Vector2, pressed: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = i
	e.position = win(p)
	e.pressed = pressed
	Input.parse_input_event(e)


func touch_move(i: int, p: Vector2, from: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = i
	e.position = win(p)
	e.relative = win(p) - win(from)
	Input.parse_input_event(e)


func tap(p: Vector2) -> void:
	touch(0, p, true)
	await frames(2)
	touch(0, p, false)
	await frames(2)


func double_tap(p: Vector2) -> void:
	await tap(p)
	await tap(p)


func long_press(p: Vector2, secs := 0.8) -> void:
	touch(0, p, true)
	await wait(secs)
	touch(0, p, false)
	await frames(2)


func swipe(a: Vector2, b: Vector2, steps := 10) -> void:
	touch(0, a, true)
	await frames(1)
	var prev := a
	for i in steps:
		var q := a.lerp(b, float(i + 1) / steps)
		touch_move(0, q, prev)
		prev = q
		await frames(1)
	touch(0, b, false)
	await frames(2)


## Two fingers: apart (zoom in) or together.
func pinch(c: Vector2, d0: float, d1: float, steps := 10) -> void:
	var a0 := c - Vector2(d0 / 2, 0)
	var b0 := c + Vector2(d0 / 2, 0)
	touch(0, a0, true)
	touch(1, b0, true)
	await frames(1)
	var pa := a0
	var pb := b0
	for i in steps:
		var d := lerpf(d0, d1, float(i + 1) / steps)
		var a := c - Vector2(d / 2, 0)
		var b := c + Vector2(d / 2, 0)
		touch_move(0, a, pa)
		touch_move(1, b, pb)
		pa = a
		pb = b
		await frames(1)
	touch(1, pb, false)
	touch(0, pa, false)
	await frames(2)


# ------------------------------------------------------------------ finding things on screen

func _walk(n: Node, out: Array) -> void:
	for ch in n.get_children():
		if ch is BaseButton and (ch as Control).is_visible_in_tree():
			out.append(ch)
		_walk(ch, out)


func buttons() -> Array:
	var out: Array = []
	_walk(tree.root, out)
	return out


func btn_text(b: BaseButton) -> String:
	var t := ""
	if b is Button:
		t = (b as Button).text
	if t == "":
		t = b.tooltip_text
	return t.replace("▼", "").replace("√", "").strip_edges()


## The visible button whose text matches (exactly, ignoring case and the dropdown arrow; else starting with it).
func find_button(text: String, exact := false) -> BaseButton:
	var want := text.to_upper()
	var starts: BaseButton = null
	for b in buttons():
		var t := btn_text(b).to_upper()
		if t == want:
			return b
		if not exact and starts == null and t.begins_with(want):
			starts = b
	return starts


func centre(c: Control) -> Vector2:
	return c.get_global_rect().get_center()


## Press a menu button as a player would: the mouse (computer) or a tap (phone).
func press(text: String, phone := false, exact := false) -> bool:
	var b := find_button(text, exact)
	if b == null:
		note("NO BUTTON '%s' on screen" % text)
		return false
	if b.disabled:
		note("BUTTON '%s' is disabled" % text)
	var p := centre(b)
	if not Rect2(Vector2.ZERO, vs()).has_point(p):
		note("BUTTON '%s' is OFF SCREEN at %s (screen %s)" % [text, p, vs()])
	if phone:
		await tap(p)
	else:
		await click(p)
	await frames(2)
	return true


# ------------------------------------------------------------------ pictures

func shot(name: String) -> String:
	if shots_dir == "":
		return ""
	shot_n += 1
	await RenderingServer.frame_post_draw
	var img := tree.root.get_texture().get_image()
	if img == null:
		return ""
	var path := "%s/%03d_%s.png" % [shots_dir, shot_n, name]
	img.save_png(path)
	note("SHOT " + path)
	return path
