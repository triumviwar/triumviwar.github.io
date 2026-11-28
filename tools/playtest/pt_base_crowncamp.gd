extends SceneTree
## The base of the playtest drivers (job playtest-campaign-crown, docs/playtest_2026_11_21_campaign_crown.md): a
## "player" that starts at the MAIN MENU and plays with REAL input events (mouse clicks and drags, keys, touches) sent to
## the window at the screen rect of the real buttons; it only reads the game's state to check what happened, and speeds
## time up (Engine.time_scale) where a human would just wait.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 --script res://tools/playtest/<x>.gd
##        -- [lang=en|pt|es] [device=pc|phone] [out=docs/shots/playtest_2026_11_21/campaign_crown] [tag=<name>]
## Headless works too (no screenshots): godot --headless --path . --script ...
## Every engine error and warning is caught (a Logger) and printed at the end as FINDING lines; CHECK lines are the
## driver's own checks. The player's campaign progress and settings are put back as they were at the end.
class Catch extends Logger:
	var errors: Array = []
	var mutex := Mutex.new()

	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool,
			error_type: int, _backtraces: Array[ScriptBacktrace]) -> void:
		var kind: String = ["ERROR", "WARNING", "SCRIPT ERROR", "SHADER ERROR"][clampi(error_type, 0, 3)]
		var msg := "%s: %s %s (%s:%d %s)" % [kind, code, rationale, file.get_file(), line, function]
		mutex.lock()
		errors.append(msg)
		mutex.unlock()

	func _log_message(_message: String, _error: bool) -> void:
		pass


var main: Node
var lang := "en"
var device := "pc"
var out := "docs/shots/playtest_2026_11_21/campaign_crown"
var tag := "run"
var args: Dictionary = {}
var catch := Catch.new()
var fails := 0
var checks := 0
var shots: Array = []
var _kept_progress := ""
var _kept_settings := ""
var _seen_err := 0
var headless := false


func _initialize() -> void:
	OS.add_logger(catch)
	headless = DisplayServer.get_name() == "headless"
	for a in OS.get_cmdline_user_args():
		var kv := String(a).split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else "1"
	lang = String(args.get("lang", lang))
	device = String(args.get("device", device))
	out = String(args.get("out", out))
	tag = String(args.get("tag", tag))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://" + out))
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	if FileAccess.file_exists(Campaign.PROGRESS):
		_kept_progress = FileAccess.get_file_as_string(Campaign.PROGRESS)
	if FileAccess.file_exists(Settings.PATH):
		_kept_settings = FileAccess.get_file_as_string(Settings.PATH)
	Settings.load_all()
	Settings.device = device
	Settings.set_language(lang)
	Settings.save_all()
	setup()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_go.call_deferred()


## Before main loads: write the progress the run starts from (override).
func setup() -> void:
	pass


## The run (override); awaits allowed.
func play() -> void:
	pass


func _go() -> void:
	await frames(3)
	await play()
	finish()


func finish() -> void:
	flush_errors("end")
	if FileAccess.file_exists(Campaign.PROGRESS):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	if _kept_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept_progress)
		f.close()
	if _kept_settings != "":
		var g := FileAccess.open(Settings.PATH, FileAccess.WRITE)
		g.store_string(_kept_settings)
		g.close()
	print("PLAYTEST %s: %d checks, %d failed, %d engine errors, %d shots" % [tag, checks, fails, catch.errors.size(), shots.size()])
	quit(1 if fails > 0 else 0)


# ------------------------------------------------------------------ reporting

func check(what: String, ok: bool, detail := "") -> bool:
	checks += 1
	print("CHECK %-70s %s %s" % [what, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1
	return ok


func note(t: String) -> void:
	print("NOTE ", t)


## New engine errors since the last call, printed with where we were.
func flush_errors(where: String) -> void:
	catch.mutex.lock()
	var n: int = catch.errors.size()
	for i in range(_seen_err, n):
		print("FINDING [%s] %s" % [where, catch.errors[i]])
	_seen_err = n
	catch.mutex.unlock()


func shot(name: String) -> void:
	await frames(2)
	if headless:
		return
	var img := root.get_texture().get_image()
	var p := "%s/%s_%s.png" % [out, tag, name]
	img.save_png(ProjectSettings.globalize_path("res://" + p))
	shots.append(p)
	print("SHOT ", p)


# ------------------------------------------------------------------ time

func frames(n := 1) -> void:
	for i in n:
		await process_frame


## Real seconds (scaled by Engine.time_scale like the game; a timer that ignores the pause).
func wait(s: float) -> void:
	await create_timer(s, true, false, true).timeout


## Game seconds at a given speed: the match's clock must move s seconds.
func play_for(s: float, speed := 8.0) -> void:
	var g: Game = main.game
	if g == null:
		await wait(s)
		return
	var t0: float = g.clock
	Engine.time_scale = speed
	var guard := 0
	while is_instance_valid(main.game) and main.game.clock - t0 < s and guard < 200000:
		await process_frame
		guard += 1
	Engine.time_scale = 1.0


# ------------------------------------------------------------------ finding things

func all_nodes(n: Node = null) -> Array:
	var outl: Array = []
	var st: Array = [root if n == null else n]
	while not st.is_empty():
		var x: Node = st.pop_back()
		outl.append(x)
		for c in x.get_children():
			st.append(c)
	return outl


func visible_ctl(c: Node) -> bool:
	return c is Control and is_instance_valid(c) and (c as Control).is_visible_in_tree()


## The first visible Control named so (exact) or whose name begins so ("Line_*").
func by_name(nm: String) -> Control:
	for x in all_nodes():
		if visible_ctl(x):
			var s := String(x.name)
			if s == nm or (nm.ends_with("*") and s.begins_with(nm.trim_suffix("*"))):
				return x
	return null


## The first visible Button whose text (raw or translated) equals / contains t.
func by_text(t: String, exact := true) -> Control:
	preload("res://tools/playtest/menu_reveal.gd").reveal(root, t)      # (menu-groups)
	for x in all_nodes():
		if visible_ctl(x) and x is BaseButton and "text" in x:
			var s := String(x.text)
			var tr: String = Loc.t(s) if s != "" else ""
			var tt: String = Loc.t(t)
			if exact and (s == t or tr == t or s.strip_edges() == t or s == tt or s.strip_edges() == tt):
				return x
			if not exact and (s.find(t) >= 0 or tr.find(t) >= 0 or s.find(tt) >= 0):
				return x
	return null


func buttons() -> Array:
	return all_nodes().filter(func(x: Node) -> bool: return visible_ctl(x) and x is BaseButton)


func labels_text() -> String:
	var a: PackedStringArray = []
	for x in all_nodes():
		if visible_ctl(x) and (x is Label or x is RichTextLabel):
			a.append(String(x.text))
	return " | ".join(a)


# ------------------------------------------------------------------ input

## Where a Control's point is in the window (canvas layer and the stretch).
func to_window(c: CanvasItem, local: Vector2) -> Vector2:
	var p: Vector2 = c.get_global_transform_with_canvas() * local
	return root.get_final_transform() * p


func centre_of(c: Control) -> Vector2:
	return to_window(c, c.size * 0.5)


func _mouse_move(p: Vector2, mask := 0) -> void:
	var m := InputEventMouseMotion.new()
	m.position = p
	m.global_position = p
	m.button_mask = mask
	Input.parse_input_event(m)


func _mouse_btn(p: Vector2, btn: int, down: bool, dbl := false, mods := {}) -> void:
	var e := InputEventMouseButton.new()
	e.position = p
	e.global_position = p
	e.button_index = btn
	e.pressed = down
	e.double_click = dbl
	e.shift_pressed = bool(mods.get("shift", false))
	e.ctrl_pressed = bool(mods.get("ctrl", false))
	e.button_mask = (1 << (btn - 1)) if down else 0
	Input.parse_input_event(e)


## A click at a window point (left by default). Waits a couple of frames so the GUI sees it.
func click_at(p: Vector2, btn := MOUSE_BUTTON_LEFT, mods := {}) -> void:
	if device == "phone" and btn == MOUSE_BUTTON_LEFT and mods.is_empty():
		await tap_at(p)
		return
	_mouse_move(p)
	await frames(1)
	_mouse_btn(p, btn, true, false, mods)
	await frames(1)
	_mouse_btn(p, btn, false, false, mods)
	await frames(2)


func double_click_at(p: Vector2, mods := {}) -> void:
	_mouse_move(p)
	await frames(1)
	_mouse_btn(p, MOUSE_BUTTON_LEFT, true, false, mods)
	await frames(1)
	_mouse_btn(p, MOUSE_BUTTON_LEFT, false, false, mods)
	await frames(1)
	_mouse_btn(p, MOUSE_BUTTON_LEFT, true, true, mods)
	await frames(1)
	_mouse_btn(p, MOUSE_BUTTON_LEFT, false, false, mods)
	await frames(2)


## A finger tap (the phone): touch down / up (Godot turns it into a mouse click for the GUI as on a real phone).
func tap_at(p: Vector2, idx := 0) -> void:
	var t := InputEventScreenTouch.new()
	t.index = idx
	t.position = p
	t.pressed = true
	Input.parse_input_event(t)
	await frames(1)
	var u := InputEventScreenTouch.new()
	u.index = idx
	u.position = p
	u.pressed = false
	Input.parse_input_event(u)
	await frames(2)


## Two fingers apart / together around a point (a pinch zoom).
func pinch(c: Vector2, from_gap: float, to_gap: float, steps := 8) -> void:
	for i in 2:
		var t := InputEventScreenTouch.new()
		t.index = i
		t.position = c + Vector2((-1 if i == 0 else 1) * from_gap * 0.5, 0)
		t.pressed = true
		Input.parse_input_event(t)
	await frames(1)
	for s in range(1, steps + 1):
		var g := lerpf(from_gap, to_gap, float(s) / steps)
		for i in 2:
			var d := InputEventScreenDrag.new()
			d.index = i
			var prev := lerpf(from_gap, to_gap, float(s - 1) / steps)
			d.position = c + Vector2((-1 if i == 0 else 1) * g * 0.5, 0)
			d.relative = Vector2((-1 if i == 0 else 1) * (g - prev) * 0.5, 0)
			Input.parse_input_event(d)
		await frames(1)
	for i in 2:
		var u := InputEventScreenTouch.new()
		u.index = i
		u.position = c + Vector2((-1 if i == 0 else 1) * to_gap * 0.5, 0)
		u.pressed = false
		Input.parse_input_event(u)
	await frames(2)


## A drag with the mouse (or a finger on the phone) from a to b.
func drag(a: Vector2, b: Vector2, btn := MOUSE_BUTTON_LEFT, steps := 10) -> void:
	if device == "phone" and btn == MOUSE_BUTTON_LEFT:
		var t := InputEventScreenTouch.new()
		t.position = a
		t.pressed = true
		Input.parse_input_event(t)
		await frames(1)
		for s in range(1, steps + 1):
			var d := InputEventScreenDrag.new()
			d.position = a.lerp(b, float(s) / steps)
			d.relative = (b - a) / steps
			Input.parse_input_event(d)
			await frames(1)
		var u := InputEventScreenTouch.new()
		u.position = b
		u.pressed = false
		Input.parse_input_event(u)
		await frames(2)
		return
	_mouse_move(a)
	_mouse_btn(a, btn, true)
	await frames(1)
	for s in range(1, steps + 1):
		var m := InputEventMouseMotion.new()
		m.position = a.lerp(b, float(s) / steps)
		m.global_position = m.position
		m.relative = (b - a) / steps
		m.button_mask = 1 << (btn - 1)
		Input.parse_input_event(m)
		await frames(1)
	_mouse_btn(b, btn, false)
	await frames(2)


func wheel_at(p: Vector2, up: bool, n := 1) -> void:
	_mouse_move(p)
	for i in n:
		_mouse_btn(p, MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN, true)
		_mouse_btn(p, MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN, false)
	await frames(2)


func key(code: Key, mods := {}) -> void:
	for down in [true, false]:
		var e := InputEventKey.new()
		e.keycode = code
		e.physical_keycode = code
		e.pressed = down
		e.shift_pressed = bool(mods.get("shift", false))
		e.ctrl_pressed = bool(mods.get("ctrl", false))
		Input.parse_input_event(e)
		await frames(1)
	await frames(1)


## Click (or tap) a Control's middle. False (and a CHECK fail if must) when it isn't there.
func press(c: Control, what := "", must := true) -> bool:
	if c == null or not is_instance_valid(c):
		if must:
			check("button there: " + what, false)
		return false
	await click_at(centre_of(c))
	return true


func press_name(nm: String, must := true) -> bool:
	var c := by_name(nm)
	return await press(c, nm, must)


func press_text(t: String, must := true, exact := true) -> bool:
	var c := by_text(t, exact)
	return await press(c, t, must)


# ------------------------------------------------------------------ layout checks

## Every visible Control that pokes out of the window (beyond 2 px), outside a ScrollContainer or a clipping parent.
func off_screen(where: String) -> Array:
	var vs: Vector2 = root.get_visible_rect().size
	var bad: Array = []
	for x in all_nodes():
		if not visible_ctl(x):
			continue
		var c := x as Control
		if c.size.x < 2 or c.size.y < 2:
			continue
		if not (c is BaseButton or c is Label):
			continue
		var clipped := false
		var p := c.get_parent()
		while p:
			if p is ScrollContainer or (p is Control and (p as Control).clip_contents):
				clipped = true
				break
			p = p.get_parent()
		if clipped:
			continue
		var r: Rect2 = c.get_global_rect()
		var xf: Transform2D = c.get_global_transform_with_canvas()
		r = Rect2(xf * Vector2.ZERO, c.size * xf.get_scale())
		if r.position.x < -2 or r.position.y < -2 or r.end.x > vs.x + 2 or r.end.y > vs.y + 2:
			var txt := String(x.text) if "text" in x else ""
			bad.append("%s '%s' %s" % [c.name, txt.left(30), r])
	if not bad.is_empty():
		print("FINDING [%s] off screen: %s" % [where, "; ".join(bad.slice(0, 8))])
	return bad


## Labels / buttons whose text is cut (a Label with clip or overrun, or a Button whose text is wider than itself).
func cut_text(where: String) -> Array:
	var bad: Array = []
	for x in all_nodes():
		if not visible_ctl(x):
			continue
		if x is Button and not (x as Button).clip_text and (x as Button).autowrap_mode == TextServer.AUTOWRAP_OFF:
			var b := x as Button
			if b.text == "" or b.icon != null:
				continue
			var f := b.get_theme_font("font")
			var fs := b.get_theme_font_size("font_size")
			var w: float = f.get_string_size(Loc.t(b.text), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			if w > b.size.x - 4:
				bad.append("%s '%s' %d>%d" % [b.name, Loc.t(b.text).left(30), int(w), int(b.size.x)])
	if not bad.is_empty():
		print("FINDING [%s] text wider than its button: %s" % [where, "; ".join(bad.slice(0, 8))])
	return bad
