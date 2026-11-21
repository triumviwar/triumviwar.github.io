extends RefCounted
## Helpers for the human-like PLAYTEST drivers (playtest-campaign-brood, 2026-11-21): real input events (mouse or
## touch) fed through Input.parse_input_event, buttons found in the scene tree and clicked at their screen rect,
## screenshots, and a logger that collects every error and warning the engine prints, with the game clock.
##   var pt = preload("res://tools/playtest/pt_lib.gd").new(self, "res://docs/shots/playtest_2026_11_21/campaign_brood")

var tree: SceneTree
var shots := ""
var touch := false              # (a phone: taps are touches)
var shot_n := 0
var notes: Array = []           # [[tag, text]] things the driver saw (printed as PT lines too)
var errs: Array = []            # the logger's catch
var _log: Logger = null
var clicks := 0
var misses := 0                 # (a button that wasn't the control under its own centre: covered)


class Catch extends Logger:
	var out: Array
	func _init(o: Array) -> void:
		out = o
	func _log_error(function: String, file: String, line: int, code: String, rationale: String, editor_notify: bool, error_type: int, script_backtrace: Array[ScriptBacktrace]) -> void:
		var kind: String = ["ERROR", "WARNING", "SCRIPT ERROR", "SHADER ERROR"][clampi(error_type, 0, 3)]
		var msg := rationale if rationale != "" else code
		var where := "%s:%d %s" % [file, line, function]
		if not script_backtrace.is_empty():
			where += " | " + script_backtrace[0].format().split("\n")[0] if script_backtrace[0].get_frame_count() > 0 else ""
		out.append("%s: %s @ %s" % [kind, msg, where])
	func _log_message(_message: String, _error: bool) -> void:
		pass


func _init(t: SceneTree, dir: String) -> void:
	tree = t
	shots = dir
	if shots != "":
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(shots))
	_log = Catch.new(errs)
	OS.add_logger(_log)


func note(tag: String, text: String) -> void:
	notes.append([tag, text])
	print("PT %s: %s" % [tag, text])


func vs() -> Vector2:
	return tree.root.get_visible_rect().size


# ------------------------------------------------------------ time
func frames(n := 1) -> void:
	for i in n:
		await tree.process_frame


func wait(sec: float) -> void:
	await tree.create_timer(sec, true, false, true).timeout


## Game seconds (with the engine's time scale): the clock of the match.
func wait_game(sec: float) -> void:
	await tree.create_timer(sec, true, false, false).timeout


# ------------------------------------------------------------ input
func _flush() -> void:
	Input.flush_buffered_events()


func move(p: Vector2) -> void:
	if touch:
		return
	var e := InputEventMouseMotion.new()
	e.position = p
	e.global_position = p
	Input.parse_input_event(e)
	_flush()


func press(p: Vector2, down: bool, btn := MOUSE_BUTTON_LEFT, dbl := false, shift := false) -> void:
	if touch and btn == MOUSE_BUTTON_LEFT:
		var t := InputEventScreenTouch.new()
		t.position = p
		t.pressed = down
		t.index = 0
		t.double_tap = dbl
		Input.parse_input_event(t)
	else:
		var e := InputEventMouseButton.new()
		e.position = p
		e.global_position = p
		e.button_index = btn
		e.pressed = down
		e.double_click = dbl
		e.shift_pressed = shift
		e.button_mask = (MOUSE_BUTTON_MASK_LEFT if btn == MOUSE_BUTTON_LEFT else (MOUSE_BUTTON_MASK_RIGHT if btn == MOUSE_BUTTON_RIGHT else 0)) if down else 0
		Input.parse_input_event(e)
	_flush()


func click(p: Vector2, btn := MOUSE_BUTTON_LEFT, dbl := false, shift := false) -> void:
	clicks += 1
	move(p)
	await frames(1)
	press(p, true, btn, dbl, shift)
	await frames(1)
	press(p, false, btn, false, shift)
	await frames(2)


## A drag from a to b (a box on the map, a slider): moved in steps like a hand.
func drag(a: Vector2, b: Vector2, btn := MOUSE_BUTTON_LEFT, steps := 8) -> void:
	move(a)
	await frames(1)
	press(a, true, btn)
	await frames(1)
	for i in range(1, steps + 1):
		var p := a.lerp(b, float(i) / steps)
		if touch:
			var d := InputEventScreenDrag.new()
			d.position = p
			d.index = 0
			d.relative = (b - a) / steps
			Input.parse_input_event(d)
		else:
			var m := InputEventMouseMotion.new()
			m.position = p
			m.global_position = p
			m.relative = (b - a) / steps
			m.button_mask = MOUSE_BUTTON_MASK_LEFT if btn == MOUSE_BUTTON_LEFT else MOUSE_BUTTON_MASK_RIGHT
			Input.parse_input_event(m)
		_flush()
		await frames(1)
	press(b, false, btn)
	await frames(2)


func key(code: Key, shift := false, ctrl := false) -> void:
	for down in [true, false]:
		var e := InputEventKey.new()
		e.keycode = code
		e.physical_keycode = code
		e.pressed = down
		e.shift_pressed = shift
		e.ctrl_pressed = ctrl
		Input.parse_input_event(e)
		_flush()
		await frames(1)
	await frames(1)


# ------------------------------------------------------------ the UI
func _all(n: Node, out: Array, cls: String) -> void:
	if n is CanvasItem and not (n as CanvasItem).is_visible_in_tree():
		return
	if n.is_class(cls):
		out.append(n)
	for c in n.get_children():
		_all(c, out, cls)


func buttons() -> Array:
	var out: Array = []
	_all(tree.root, out, "BaseButton")
	return out


func labels_text() -> String:
	var out: Array = []
	_all(tree.root, out, "Label")
	var parts: PackedStringArray = []
	for l in out:
		parts.append((l as Label).text)
	return "\n".join(parts)


func button_names() -> Array:
	return buttons().map(func(b: BaseButton) -> String: return "%s[%s]%s" % [b.name, (b as Button).text if b is Button else "", " (off)" if b.disabled else ""])


## A visible button by its node name (exact), else by its text (contains, case-blind).
func find(pat: String, enabled_only := true) -> BaseButton:
	var bs := buttons()
	for b in bs:
		if String(b.name) == pat and (not enabled_only or not b.disabled):
			return b
	for b in bs:
		if b is Button and (b as Button).text.to_lower().contains(pat.to_lower()) and (not enabled_only or not b.disabled):
			return b
	return null


func wait_for(pat: String, timeout := 10.0) -> BaseButton:
	var t := 0.0
	while t < timeout:
		var b := find(pat)
		if b:
			return b
		await wait(0.1)
		t += 0.1
	return null


func rect_of(c: Control) -> Rect2:
	return c.get_global_rect() if c.get_canvas_layer_node() == null else c.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, c.size)


## Click a button like a hand: at the middle of its rect. Says if something else was under the finger.
func tap(pat: String, timeout := 6.0) -> bool:
	var b := await wait_for(pat, timeout)
	if b == null:
		note("MISS", "no button '%s' on screen" % pat)
		return false
	return await tap_node(b)


func tap_node(b: Control) -> bool:
	var r := rect_of(b)
	var c := r.get_center()
	var v := vs()
	if not Rect2(Vector2.ZERO, v).has_point(c):
		note("OFFSCREEN", "button %s '%s' centre %s outside the screen %s" % [b.name, b.get("text"), c, v])
	move(c)
	await frames(2)
	var hov: Control = tree.root.gui_get_hovered_control() if not touch else null
	if not touch and hov != null and hov != b and not b.is_ancestor_of(hov):
		misses += 1
		note("COVERED", "button %s '%s' at %s is under %s (%s)" % [b.name, b.get("text"), c, hov.name, hov.get_class()])
	var before := clicks
	await click(c)
	return clicks > before


# ------------------------------------------------------------ pictures
func shot(name: String) -> String:
	if shots == "" or DisplayServer.get_name() == "headless":
		return ""
	await RenderingServer.frame_post_draw
	var img := tree.root.get_texture().get_image()
	shot_n += 1
	var p := "%s/%02d_%s.png" % [shots, shot_n, name]
	img.save_png(p)
	print("PT SHOT %s" % p)
	return p


# ------------------------------------------------------------ the world
func to_screen(game: Node2D, world: Vector2) -> Vector2:
	return game.get_viewport().get_canvas_transform() * world


func errors_since(i: int) -> Array:
	return errs.slice(i)


func report_errors(tag: String) -> void:
	var seen := {}
	for e in errs:
		seen[e] = int(seen.get(e, 0)) + 1
	for e in seen:
		print("PT ERR[%s] x%d %s" % [tag, seen[e], e])


## After a run that was killed, the game opens on THE GAME CLOSED UNEXPECTEDLY: a human presses MENU.
func past_crash_page() -> void:
	await wait(1.0)
	if find("COPY REPORT") != null:
		note("CRASHPAGE", "the crash-report page showed at start (the last run was killed): MENU")
		await tap("MENU")
		await wait(1.0)
