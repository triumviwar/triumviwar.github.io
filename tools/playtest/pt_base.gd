extends SceneTree
## PLAYTEST base (job playtest-menus-online, docs/playtest_2026_11_21_menus_online.md): a driver that plays the game
## the way a person does. It starts the real main scene and feeds REAL input events (mouse moves, clicks, keys,
## touches) at the screen position of the button it wants; game functions are only called to READ state.
## Drivers extend this script:  extends "res://tools/playtest/pt_base.gd"
## Run them with a window (screenshots need one):
##   xvfb-run -a godot --resolution 1280x720 --script res://tools/playtest/<driver>.gd -- [args]
## Common args: out:<dir> (screenshots), lang:en|pt|es, device:pc|mobile, size:WxH, seed:<n>, keep_settings
## Every line a driver prints for the report starts "PT ": "PT FIND", "PT ERROR", "PT CUT", "PT OFF", "PT EN"...

var main: Node
var args := {}
var out := ""
var lang := "en"
var device := "pc"
var tag := ""
var rng := RandomNumberGenerator.new()
var findings := 0
var errors: Array = []                 # errors the engine logged while the driver ran (_PTLogger)
var _saved_cfg := ""
var _had_cfg := false
var shots := 0


class _PTLogger extends Logger:
	var sink: Array
	func _init(s: Array) -> void:
		sink = s
	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtrace: Array[ScriptBacktrace]) -> void:
		var kind: String = ["ERROR", "WARNING", "SCRIPT ERROR", "SHADER ERROR"][clampi(error_type, 0, 3)]
		sink.append("%s: %s %s (%s:%d %s)" % [kind, rationale, code, file, line, function])
	func _log_message(_message: String, _error: bool) -> void:
		pass


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var k := String(a)
		var i := k.find(":")
		if i < 0:
			args[k] = true
		else:
			args[k.substr(0, i)] = k.substr(i + 1)
	out = String(args.get("out", ""))
	lang = String(args.get("lang", "en"))
	device = String(args.get("device", "pc"))
	rng.seed = int(args.get("seed", 1))
	if out != "":
		DirAccess.make_dir_recursive_absolute(out)
	OS.add_logger(_PTLogger.new(errors))
	if args.has("size"):
		var p := String(args["size"]).split("x")
		DisplayServer.window_set_size(Vector2i(int(p[0]), int(p[1])))
	# keep the tester's own settings: put back at the end (pt_end)
	_had_cfg = FileAccess.file_exists(Settings.PATH)
	if _had_cfg:
		_saved_cfg = FileAccess.get_file_as_string(Settings.PATH)
	if not args.has("keep_running"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	if not args.has("raw_settings"):
		Settings.load_all()
		Settings.device = device
		Settings.language = lang
		Loc.set_lang(lang)
		Settings.apply()
		Settings.save_all()
	var vs := DisplayServer.window_get_size()
	tag = "%s_%s_%dx%d" % [lang, device, vs.x, vs.y]
	_go.call_deferred()


func _go() -> void:
	await process_frame
	await process_frame
	await play()
	pt_end()


## The driver's body (await-able).
func play() -> void:
	pass


func start_main() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await wait(0.6)


func pt_end(code := 0) -> void:
	check_errors("end")
	print("PT DONE findings=%d errors=%d shots=%d" % [findings, errors.size(), shots])
	if not args.has("keep_settings"):
		if _had_cfg:
			var f := FileAccess.open(Settings.PATH, FileAccess.WRITE)
			f.store_string(_saved_cfg)
			f.close()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	quit(code)


# ------------------------------------------------------------------ waiting

func wait(s: float) -> void:
	await create_timer(s, true, false, true).timeout


func frames(n: int) -> void:
	for i in n:
		await process_frame


# ------------------------------------------------------------------ finding things on screen

## What the control shows (translated as on screen).
func shown(c: Control) -> String:
	var t := ""
	if c is Label:
		t = (c as Label).text
	elif c is Button:
		t = (c as Button).text
	elif c is RichTextLabel:
		t = (c as RichTextLabel).get_parsed_text()
	elif c is LineEdit:
		t = (c as LineEdit).text
	if c.auto_translate_mode != Node.AUTO_TRANSLATE_MODE_DISABLED and not c is RichTextLabel and not c is LineEdit:
		t = c.atr(t)
	return t


func all_controls(cls := "Control") -> Array:
	var res: Array = []
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		for ch in n.get_children():
			stack.append(ch)
		if n is Control and n.is_class(cls) and (n as Control).is_visible_in_tree():
			res.append(n)
	return res


func buttons() -> Array:
	var res: Array = []
	for c in all_controls("BaseButton"):
		var b := c as BaseButton
		if not b.disabled and on_screen(b):
			res.append(b)
	return res


func on_screen(c: Control) -> bool:
	var r := screen_rect(c)
	return r.size.x > 1 and r.size.y > 1 and Rect2(Vector2.ZERO, Vector2(DisplayServer.window_get_size())).intersects(r)


## The control's rectangle in window pixels (the canvas_items stretch included).
func screen_rect(c: Control) -> Rect2:
	var xf := root.get_final_transform() * c.get_global_transform_with_canvas()
	return Rect2(xf * Vector2.ZERO, xf.basis_xform(c.size))


## A visible, enabled button whose shown text is `t` (exact, ignoring case), else one that contains it; English
## keys work in every language (the button's own text, before translation, is compared too).
func find_button(t: String, exact_only := false) -> BaseButton:
	var bs := buttons()
	var lt := t.to_lower()
	for b in bs:
		var raw: String = (b as Button).text if b is Button else ""
		if shown(b).strip_edges().to_lower() == lt or raw.strip_edges().to_lower() == lt or String(b.name).to_lower() == lt:
			return b
	if exact_only:
		return null
	for b in bs:
		var raw2: String = (b as Button).text if b is Button else ""
		if shown(b).to_lower().contains(lt) or raw2.to_lower().contains(lt):
			return b
	return null


func button_texts() -> Array:
	var r: Array = []
	for b in buttons():
		r.append(shown(b).replace("\n", " "))
	return r


# ------------------------------------------------------------------ real input

func _pos_of(c: Control, frac := Vector2(0.5, 0.5)) -> Vector2:
	var r := screen_rect(c)
	return r.position + r.size * frac


func mouse_move(p: Vector2) -> void:
	var m := InputEventMouseMotion.new()
	m.position = p
	m.global_position = p
	Input.parse_input_event(m)
	await process_frame


func mouse_button(p: Vector2, pressed: bool, which := MOUSE_BUTTON_LEFT, dbl := false) -> void:
	var e := InputEventMouseButton.new()
	e.position = p
	e.global_position = p
	e.button_index = which
	e.pressed = pressed
	e.double_click = dbl
	e.button_mask = (1 << (which - 1)) if pressed else 0
	Input.parse_input_event(e)


func click_at(p: Vector2, which := MOUSE_BUTTON_LEFT) -> void:
	await mouse_move(p)
	mouse_button(p, true, which)
	await process_frame
	mouse_button(p, false, which)
	await process_frame


func touch_at(p: Vector2, idx := 0) -> void:
	var e := InputEventScreenTouch.new()
	e.position = p
	e.index = idx
	e.pressed = true
	Input.parse_input_event(e)
	await process_frame
	var u := InputEventScreenTouch.new()
	u.position = p
	u.index = idx
	u.pressed = false
	Input.parse_input_event(u)
	await process_frame


## Press on screen the way this device does: a mouse click on a computer, a finger tap on a phone.
func tap_at(p: Vector2) -> void:
	if device == "mobile":
		await touch_at(p)
	else:
		await click_at(p)


func tap(c: Control, frac := Vector2(0.5, 0.5)) -> void:
	await tap_at(_pos_of(c, frac))


func double_click(c: Control) -> void:
	var p := _pos_of(c)
	await mouse_move(p)
	mouse_button(p, true)
	await process_frame
	mouse_button(p, false)
	await process_frame
	mouse_button(p, true, MOUSE_BUTTON_LEFT, true)
	await process_frame
	mouse_button(p, false)
	await process_frame


## Finds the button and presses it; false (and a PT MISS line) when it isn't on screen.
func press(t: String, settle := 0.35, exact_only := false) -> bool:
	var b := find_button(t, exact_only)
	if b == null:
		print("PT MISS no button '%s' on screen; there are: %s" % [t, str(button_texts()).substr(0, 600)])
		return false
	print("PT PRESS '%s'" % shown(b).replace("\n", " "))
	await tap(b)
	await wait(settle)
	return true


func key(code: Key, pressed := true, shift := false, ctrl := false, alt := false, unicode := 0) -> void:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = pressed
	e.shift_pressed = shift
	e.ctrl_pressed = ctrl
	e.alt_pressed = alt
	e.unicode = unicode
	Input.parse_input_event(e)


func key_tap(code: Key, shift := false, ctrl := false, alt := false) -> void:
	key(code, true, shift, ctrl, alt)
	await process_frame
	key(code, false, shift, ctrl, alt)
	await process_frame


## Types text into whatever has focus, one key at a time.
func type_text(s: String) -> void:
	for ch in s:
		var u := ch.unicode_at(0)
		var e := InputEventKey.new()
		e.unicode = u
		e.keycode = OS.find_keycode_from_string(ch.to_upper()) if ch.length() == 1 and ch.to_upper() >= "A" and ch.to_upper() <= "Z" else KEY_NONE
		e.pressed = true
		Input.parse_input_event(e)
		await process_frame
		var e2 := e.duplicate() as InputEventKey
		e2.pressed = false
		Input.parse_input_event(e2)
	await process_frame


func scroll_at(p: Vector2, down := true, n := 3) -> void:
	await mouse_move(p)
	for i in n:
		mouse_button(p, true, MOUSE_BUTTON_WHEEL_DOWN if down else MOUSE_BUTTON_WHEEL_UP)
		await process_frame
		mouse_button(p, false, MOUSE_BUTTON_WHEEL_DOWN if down else MOUSE_BUTTON_WHEEL_UP)
		await process_frame


## A slider dragged by the mouse from where it is to `frac` of its width.
func drag_slider(s: HSlider, frac: float) -> void:
	var r := screen_rect(s)
	var gx := func(f: float) -> float: return r.position.x + 6.0 + (r.size.x - 12.0) * clampf(f, 0, 1)
	var from := Vector2(gx.call(float(s.ratio)), r.position.y + r.size.y * 0.5)
	var to := Vector2(gx.call(frac), r.position.y + r.size.y * 0.5)
	await mouse_move(from)
	mouse_button(from, true)
	await process_frame
	for i in 6:
		var p := from.lerp(to, (i + 1) / 6.0)
		var m := InputEventMouseMotion.new()
		m.position = p
		m.global_position = p
		m.button_mask = MOUSE_BUTTON_MASK_LEFT
		m.relative = (to - from) / 6.0
		Input.parse_input_event(m)
		await process_frame
	mouse_button(to, false)
	await process_frame


# ------------------------------------------------------------------ looking

func shot(name: String) -> String:
	if out == "" or DisplayServer.get_name() == "headless":
		return ""
	await frames(2)
	var img := root.get_texture().get_image()
	var p := "%s/%s_%s.jpg" % [out, tag, name]
	img.save_jpg(p, 0.85)
	shots += 1
	return p


func find(kind: String, where: String, detail: String) -> void:
	findings += 1
	print("PT %s [%s] %s" % [kind, where, detail])


## New engine errors since the last look become findings.
var _errs_seen := 0
func check_errors(where: String) -> void:
	while _errs_seen < errors.size():
		var e: String = errors[_errs_seen]
		_errs_seen += 1
		if e.begins_with("WARNING") and (e.contains("ObjectDB") or e.contains("leaked")):
			find("LEAK", where, e)
		elif e.begins_with("WARNING"):
			print("PT WARN [%s] %s" % [where, e])
		else:
			find("ERROR", where, e)


# ------------------------------------------------------------------ the text audit (cut, off screen, overlap, English left)

func _clipped_by_parent(c: Control) -> bool:
	var p := c.get_parent()
	while p != null:
		if p is ScrollContainer or (p is Control and (p as Control).clip_contents):
			return true
		if p is Window or p is CanvasLayer:
			break
		p = p.get_parent()
	return false


func _vis_rect(c: Control) -> Rect2:
	var r := screen_rect(c)
	var p := c.get_parent()
	while p != null and not (p is Window or p is CanvasLayer):
		if p is ScrollContainer or (p is Control and (p as Control).clip_contents):
			r = r.intersection(screen_rect(p as Control))
		p = p.get_parent()
	return r


func _path(c: Node) -> String:
	var s := String(c.name)
	var p := c.get_parent()
	var n := 0
	while p != null and n < 3:
		s = String(p.name) + "/" + s
		p = p.get_parent()
		n += 1
	return s


func audit(name: String) -> void:
	check_errors(name)
	var vp := Rect2(Vector2.ZERO, Vector2(DisplayServer.window_get_size()))
	var texts: Array = []
	for c in all_controls():
		if (c as Control).modulate.a < 0.05:
			continue
		if not (c is Label or c is Button or c is RichTextLabel):
			continue
		var t := shown(c)
		if t.strip_edges() == "":
			continue
		var r := screen_rect(c)
		if r.size.x < 1 or r.size.y < 1:
			continue
		var k := (c as Control).get_global_transform_with_canvas().get_scale().x
		texts.append(c)
		var f: Font = c.get_theme_font("font") if not c is RichTextLabel else c.get_theme_font("normal_font")
		var fs: int = c.get_theme_font_size("font_size") if not c is RichTextLabel else c.get_theme_font_size("normal_font_size")
		var one := t.replace("\n", " ").substr(0, 60)
		var box: Vector2 = (c as Control).size
		if c is Label:
			var l := c as Label
			if l.autowrap_mode == TextServer.AUTOWRAP_OFF and (l.clip_text or l.text_overrun_behavior != TextServer.OVERRUN_NO_TRIMMING):
				var w := 0.0
				for ln in t.split("\n"):
					w = maxf(w, f.get_string_size(ln, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
				if w > box.x + 2:
					find("CUT", name, "%s '%s' text %d > box %d" % [_path(c), one, int(w), int(box.x)])
			elif l.autowrap_mode != TextServer.AUTOWRAP_OFF:
				var longest := 0.0
				for word in t.split(" ", false):
					longest = maxf(longest, f.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
				if longest > box.x + 2 and t.length() > 3:
					find("SQUEEZED", name, "%s '%s' word %d > box %d" % [_path(c), one, int(longest), int(box.x)])
		elif c is Button:
			var b := c as Button
			var st: StyleBox = b.get_theme_stylebox("normal")
			var mx := 0.0
			if st:
				mx = st.get_margin(SIDE_LEFT) + st.get_margin(SIDE_RIGHT)
			var icon_w := 0.0
			if b.icon != null and not b.expand_icon:
				icon_w = b.icon.get_width() + b.get_theme_constant("h_separation")
			var w := 0.0
			for ln in t.split("\n"):
				w = maxf(w, f.get_string_size(ln, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
			if (b.clip_text or b.text_overrun_behavior != TextServer.OVERRUN_NO_TRIMMING) and b.autowrap_mode == TextServer.AUTOWRAP_OFF and w + mx + icon_w > box.x + 3:
				find("CUT", name, "%s button '%s' text %d > room %d" % [_path(c), one, int(w), int(box.x - mx - icon_w)])
		if not vp.grow(2).encloses(r) and not _clipped_by_parent(c):
			find("OFF", name, "%s '%s' rect %s (screen %s)" % [_path(c), one, str(r), str(vp.size)])
	for i in texts.size():
		var a: Control = texts[i]
		var ra := _vis_rect(a)
		for j in range(i + 1, texts.size()):
			var b2: Control = texts[j]
			if a.is_ancestor_of(b2) or b2.is_ancestor_of(a):
				continue
			var rb := _vis_rect(b2)
			var x := ra.intersection(rb)
			if x.get_area() <= 0:
				continue
			var small := minf(ra.get_area(), rb.get_area())
			if x.get_area() > 0.25 * small and x.size.x > 6 and x.size.y > 6:
				find("OVERLAP", name, "'%s' x '%s'" % [shown(a).replace("\n", " ").substr(0, 40), shown(b2).replace("\n", " ").substr(0, 40)])
	if lang != "en":
		for k in Loc.misses:
			find("EN", name, "'%s'" % String(k).replace("\n", "\\n").substr(0, 90))
	Loc.misses.clear()


## Look at the screen: a picture and the text audit.
func look(name: String, settle := 0.4) -> void:
	await wait(settle)
	await shot(name)
	audit(name)
