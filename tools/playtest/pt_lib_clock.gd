extends SceneTree
## PLAYTEST LIBRARY (job playtest-campaign-clock, docs/playtest_2026_11_21_campaign_clock.md): the shared helpers of the
## playtest drivers in tools/playtest/. A driver plays like a person: it starts from the MAIN MENU and feeds REAL input
## events (mouse moves, clicks, keys, screen touches) through Input.parse_input_event at the window's pixels of the
## Control it wants, so every press goes through Godot's GUI and the game's own input code. Game state is only READ
## (to know where things are and to check results); Engine.time_scale speeds the match up.
##
## Arguments after "--": key=value pairs, read by arg():
##   out=<dir>          screenshots go here (default docs/shots/playtest_2026_11_21/campaign_clock)
##   device=pc|mobile   the control scheme (mobile = touches instead of the mouse)
##   lang=en|pt|es      the game language
##   tag=<text>         a prefix for the screenshot names
## Run with a window (screenshots need one):
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --rendering-driver opengl3 --resolution 1280x720 \
##       --script res://tools/playtest/<driver>.gd -- device=pc lang=en
## Every line the driver prints starts with "PT "; a finding with "PT FINDING". Errors are Godot's own (SCRIPT ERROR,
## ERROR:) on the console: the run script greps them.

var main: Node
var args := {}
var out := "res://docs/shots/playtest_2026_11_21/campaign_clock"
var tag := ""
var shot_n := 0
var findings: Array = []
var _kept_progress := ""
var _had_progress := false
var touch := false


func arg(k: String, d := "") -> String:
	return String(args.get(k, d))


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var i := String(a).find("=")
		if i > 0:
			args[String(a).substr(0, i)] = String(a).substr(i + 1)
		else:
			args[String(a)] = "1"
	out = arg("out", out)
	tag = arg("tag", "")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out) if out.begins_with("res://") else out)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	_had_progress = FileAccess.file_exists(Campaign.PROGRESS)
	if _had_progress:
		_kept_progress = FileAccess.get_file_as_string(Campaign.PROGRESS)
	Settings.load_all()
	Settings.device = arg("device", "pc")
	touch = Settings.device == "mobile"
	Settings.apply()
	Settings.set_language(arg("lang", "en"))
	Loc.track = true
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_go.call_deferred()


func _go() -> void:
	await wait(1.0)
	await play()
	finish()


## The driver's play: override.
func play() -> void:
	pass


func finish(code := 0) -> void:
	Engine.time_scale = 1.0
	if _had_progress:
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept_progress)
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	if arg("lang", "en") != "en" and not Loc.misses.is_empty():
		# (Godot asks again for texts already in the language: a label's text set from Loc.t; those are no misses)
		var vals := {}
		for v in Loc.table(arg("lang")).values():
			vals[String(v)] = true
		var ks: Array = Loc.misses.keys().filter(func(k) -> bool: return not vals.has(String(k)) and not _looks_translated(String(k)))
		ks.sort()
		for k in ks:
			print("PT UNTRANSLATED [%s] %s" % [arg("lang"), String(k).c_escape().substr(0, 160)])
	var lang_was := Settings.language
	Settings.set_language("en")      # (the next run starts in English unless told)
	print("PT language was %s" % lang_was)
	print("PT findings: %d" % findings.size())
	for f in findings:
		print("PT FINDING ", f)
	print("PT END")
	quit(code)


## A text that is already the game language's (no English words in it): a translated text with its blanks filled.
func _looks_translated(t: String) -> bool:
	var en := [" the ", " and ", " of ", "The ", " is ", " with ", " your ", " you ", " for ", " it "]
	for w in en:
		if (" " + t + " ").contains(w):
			return false
	return true


func note(s: String) -> void:
	print("PT ", s)


func finding(s: String) -> void:
	findings.append(s)
	print("PT FINDING ", s)


func check(name: String, ok: bool, detail := "") -> bool:
	print("PT CHECK %-60s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		finding("check failed: %s %s" % [name, detail])
	return ok


# ------------------------------------------------------------------ time

## Real seconds (scaled by Engine.time_scale, as the game's own timers are).
func wait(sec: float) -> void:
	await create_timer(sec, true, false, true).timeout


func frames(n: int) -> void:
	for i in n:
		await process_frame


# ------------------------------------------------------------------ pictures

func snap(name: String, settle := 0.25) -> String:
	await wait(settle)
	await process_frame
	await process_frame
	shot_n += 1
	var fn := "%s/%s%02d_%s.png" % [out, (tag + "_") if tag != "" else "", shot_n, name]
	var img := root.get_viewport().get_texture().get_image()
	if img == null:
		return ""
	img.save_png(fn)
	print("PT SHOT ", fn)
	return fn


# ------------------------------------------------------------------ input (window pixels)

## A point of the root viewport's canvas (what get_global_rect() gives) in window pixels.
func to_window(p: Vector2) -> Vector2:
	return root.get_final_transform() * p


func _mouse_move(wp: Vector2) -> void:
	var e := InputEventMouseMotion.new()
	e.position = wp
	e.global_position = wp
	Input.parse_input_event(e)
	Input.warp_mouse(wp)


func _mouse_btn(wp: Vector2, btn: int, down: bool, shift := false, dbl := false) -> void:
	var e := InputEventMouseButton.new()
	e.position = wp
	e.global_position = wp
	e.button_index = btn
	e.pressed = down
	e.shift_pressed = shift
	e.double_click = dbl
	e.button_mask = (1 << (btn - 1)) if down else 0
	Input.parse_input_event(e)


func _touch(wp: Vector2, down: bool, idx := 0) -> void:
	var e := InputEventScreenTouch.new()
	e.position = wp
	e.pressed = down
	e.index = idx
	Input.parse_input_event(e)


## A left click (a tap on a phone) at a canvas point.
func click_at(p: Vector2, btn := MOUSE_BUTTON_LEFT, shift := false) -> void:
	var wp := to_window(p)
	if touch and btn == MOUSE_BUTTON_LEFT:
		_touch(wp, true)
		await frames(2)
		_touch(wp, false)
		await frames(2)
		return
	_mouse_move(wp)
	await frames(1)
	_mouse_btn(wp, btn, true, shift)
	await frames(2)
	_mouse_btn(wp, btn, false, shift)
	await frames(2)


func double_click_at(p: Vector2) -> void:
	var wp := to_window(p)
	_mouse_move(wp)
	_mouse_btn(wp, MOUSE_BUTTON_LEFT, true)
	_mouse_btn(wp, MOUSE_BUTTON_LEFT, false)
	await frames(1)
	_mouse_btn(wp, MOUSE_BUTTON_LEFT, true, false, true)
	_mouse_btn(wp, MOUSE_BUTTON_LEFT, false)
	await frames(2)


func right_click_at(p: Vector2, shift := false) -> void:
	await click_at(p, MOUSE_BUTTON_RIGHT, shift)


## A left drag from a to b (the box select), in steps.
func drag(a: Vector2, b: Vector2, steps := 8) -> void:
	var wa := to_window(a)
	var wb := to_window(b)
	if touch:
		_touch(wa, true)
		await frames(1)
		for i in range(1, steps + 1):
			var e := InputEventScreenDrag.new()
			e.position = wa.lerp(wb, float(i) / steps)
			e.relative = (wb - wa) / steps
			e.index = 0
			Input.parse_input_event(e)
			await frames(1)
		_touch(wb, false)
		await frames(2)
		return
	_mouse_move(wa)
	_mouse_btn(wa, MOUSE_BUTTON_LEFT, true)
	await frames(1)
	for i in range(1, steps + 1):
		var e := InputEventMouseMotion.new()
		e.position = wa.lerp(wb, float(i) / steps)
		e.global_position = e.position
		e.relative = (wb - wa) / steps
		e.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(e)
		await frames(1)
	_mouse_btn(wb, MOUSE_BUTTON_LEFT, false)
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
		await frames(1)


# ------------------------------------------------------------------ finding controls

## Every visible Control under root whose name matches (a glob like "Mission_*").
func ctrls(pattern: String, type := "Control") -> Array:
	return root.find_children(pattern, type, true, false).filter(func(c) -> bool:
		return c is Control and (c as Control).is_visible_in_tree())


func ctrl(pattern: String, type := "Control") -> Control:
	var a := ctrls(pattern, type)
	return a[0] if not a.is_empty() else null


## A visible Button showing this English text (in the game's language now).
func button_text(english: String) -> Button:
	preload("res://tools/playtest/menu_reveal.gd").reveal(root, english)      # (menu-groups)
	var want := Loc.t(english)
	for b in root.find_children("*", "Button", true, false):
		if not (b as Button).is_visible_in_tree():
			continue
		var t := (b as Button).text
		if t == english or t == want or (b as Button).get_meta("en", "") == english:
			return b
	for b in root.find_children("*", "Button", true, false):
		if (b as Button).is_visible_in_tree() and ((b as Button).text.begins_with(want) or (b as Button).text.begins_with(english)):
			return b
	return null


## Click a Control at the middle of its rect (only if it is visible, on screen and not disabled). True when clicked.
func press(c: Control, why := "") -> bool:
	if c == null or not is_instance_valid(c):
		finding("could not press %s: not there" % why)
		return false
	if not c.is_visible_in_tree():
		finding("could not press %s (%s): hidden" % [why, c.name])
		return false
	if c is BaseButton and (c as BaseButton).disabled:
		note("press %s (%s): disabled" % [why, c.name])
		return false
	var r := c.get_global_rect()
	var vr := root.get_visible_rect()
	var pt := r.get_center()
	if not vr.has_point(pt):
		finding("%s (%s) is off screen: its middle %s, the screen %s" % [why, c.name, pt, vr.size])
		return false
	await click_at(pt)
	await frames(2)
	return true


func press_text(english: String) -> bool:
	return await press(button_text(english), english)


func press_name(pattern: String) -> bool:
	return await press(ctrl(pattern, "BaseButton"), pattern)


# ------------------------------------------------------------------ layout checks

## Visible texts cut off or outside the screen: every visible Label / Button on screen whose text needs more room than it
## has (clip_text, or a label not wrapping and wider than its rect) or whose rect leaves the screen.
func layout_check(where: String) -> void:
	var vr := root.get_visible_rect()
	var seen := {}
	for c in root.find_children("*", "Control", true, false):
		var cc := c as Control
		if not cc.is_visible_in_tree() or cc.size.x <= 1 or cc.size.y <= 1:
			continue
		if cc.get_global_rect().size == Vector2.ZERO:
			continue
		var gr := cc.get_global_rect()
		if (cc is Button or cc is Label) and not _clipped_by_scroll(cc):
			if gr.end.x > vr.end.x + 2 or gr.end.y > vr.end.y + 2 or gr.position.x < -2 or gr.position.y < -2:
				var t := _text_of(cc)
				if t != "" and not seen.has("off" + t):
					seen["off" + t] = true
					finding("[%s] off screen: %s '%s' rect %s (screen %s)" % [where, cc.get_class(), t.substr(0, 60), gr, vr.size])
		if cc is Label:
			var l := cc as Label
			if l.autowrap_mode == TextServer.AUTOWRAP_OFF and l.text != "" and not l.clip_text and l.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING:
				pass
			if l.get_line_count() > 0 and l.autowrap_mode != TextServer.AUTOWRAP_OFF and l.get_visible_line_count() < l.get_line_count() and l.max_lines_visible < 0:
				if not seen.has("cut" + l.text):
					seen["cut" + l.text] = true
					finding("[%s] label cut: '%s' shows %d of %d lines" % [where, l.text.substr(0, 60), l.get_visible_line_count(), l.get_line_count()])
		if cc is Button:
			var b := cc as Button
			if b.text != "" and b.clip_text:
				var f := b.get_theme_font("font")
				var fs := b.get_theme_font_size("font_size")
				var w := 0.0
				for ln in b.text.split("\n"):
					w = maxf(w, f.get_string_size(ln, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x if f else 0.0)
				if w > b.size.x - 8 and not seen.has("btn" + b.text):
					seen["btn" + b.text] = true
					finding("[%s] button text cut: '%s' needs %d px, has %d" % [where, b.text.substr(0, 60), int(w), int(b.size.x)])


func _clipped_by_scroll(c: Control) -> bool:
	var p := c.get_parent()
	while p != null:
		if p is ScrollContainer:
			return true
		p = p.get_parent()
	return false


func _text_of(c: Control) -> String:
	if c is Button:
		return (c as Button).text
	if c is Label:
		return (c as Label).text
	return ""


## The visible texts of a page (for the log: what a player reads).
func page_texts(limit := 40) -> Array:
	var out_t: Array = []
	for c in root.find_children("*", "Control", true, false):
		if (c is Label or c is Button) and (c as Control).is_visible_in_tree():
			var t := _text_of(c).strip_edges()
			if t != "" and not out_t.has(t):
				out_t.append(t)
		if out_t.size() >= limit:
			break
	return out_t


# ------------------------------------------------------------------ campaign progress

## Write the campaign's progress as if these missions were finished: {mid: [side won by and played, flags]}.
func set_progress(done: Dictionary, extra := {}) -> void:
	var p := {"reached": [], "done": {}}
	for mid in done:
		p["done"][mid] = {"won_by": done[mid][0], "side": done[mid][0], "flags": done[mid][1], "mode": "solo"}
		if not Campaign.storyline_of(mid).is_empty():
			var nx := Campaign.next_of(mid, String(done[mid][0]))
			if nx != "" and not (p["reached"] as Array).has(nx):
				p["reached"].append(nx)
	for k in extra:
		p[k] = extra[k]
	Campaign.save_progress(p)
	note("progress set: done %s" % [done.keys()])
