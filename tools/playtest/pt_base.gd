extends SceneTree
## Playtest drivers (docs/playtest_2026_11_21_skirmish_crown.md): a "player" that ACTS only through real input events
## (mouse, keys, touch) fed to the window, starting from the main menu. It may READ the game's state to decide what
## to do (where a HUD button is, where its units stand), never call game functions to act; Engine.time_scale may be
## raised to speed a match up. Scenario scripts extend this file:
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --rendering-driver opengl3 --resolution 1280x720 \
##       --script res://tools/playtest/<scenario>.gd -- out=<dir> device=pc|mobile lang=en|pt|es seed=N
## Every step prints "PT <what>"; "PT FINDING <text>" lines are things the player noticed; SCRIPT ERRORs in the same
## log are traced to the last "PT" step before them.

var main
var out := "/tmp/pt"
var device := "pc"
var lang := "en"
var seed_n := 1
var args := {}
var shots := 0
var t0 := 0
var findings: Array = []


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := String(a).split("=", true, 1)
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	out = String(args.get("out", out))
	device = String(args.get("device", device))
	lang = String(args.get("lang", lang))
	seed_n = int(args.get("seed", seed_n))
	DirAccess.make_dir_recursive_absolute(out)
	seed(seed_n)
	# a run that quit mid-session leaves the "running" marker: without this the crash page shows
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	Settings.load_all()
	Settings.device = device
	Settings.language = lang
	Settings.window_full = false
	Settings.apply()
	Settings.set_language(lang)
	t0 = Time.get_ticks_msec()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_go.call_deferred()


func _go() -> void:
	await frames(10)
	await run()
	step("END findings=%d" % findings.size())
	for f in findings:
		print("PT SUMMARY ", f)
	Engine.time_scale = 1.0
	quit()


## Scenario body (overridden).
func run() -> void:
	pass


# ------------------------------------------------------------------ log

func step(t: String) -> void:
	print("PT [%6.1fs] %s" % [(Time.get_ticks_msec() - t0) / 1000.0, t])


func finding(t: String) -> void:
	findings.append(t)
	print("PT FINDING ", t)


func frames(n: int) -> void:
	for i in n:
		await process_frame


## Waits game seconds (scaled by Engine.time_scale), in frames so input keeps flowing.
func wait(secs: float) -> void:
	await create_timer(secs).timeout


## Waits real seconds.
func wait_real(secs: float) -> void:
	await create_timer(secs, true, false, true).timeout


func shot(name: String) -> String:
	await process_frame
	await RenderingServer.frame_post_draw
	shots += 1
	var p := "%s/%02d_%s.png" % [out, shots, name]
	var img := root.get_viewport().get_texture().get_image()
	if img:
		img.save_png(p)
	step("shot " + p)
	return p


# ------------------------------------------------------------------ coordinates
## Scripts work in the root viewport's coordinates (what Controls and the HUD report); input events are in window
## pixels, so they go through the window's stretch transform.

func to_screen(vp: Vector2) -> Vector2:
	return root.get_final_transform() * vp


func vp_size() -> Vector2:
	return root.get_visible_rect().size


# ------------------------------------------------------------------ mouse

var mouse_at := Vector2(640, 360)
var _ctrl := false
var _shift := false
var _alt := false


func _mods(e: InputEventWithModifiers) -> void:
	e.ctrl_pressed = _ctrl
	e.shift_pressed = _shift
	e.alt_pressed = _alt


func move(vp: Vector2, steps := 1) -> void:
	var from := mouse_at
	for i in range(1, steps + 1):
		var p := from.lerp(vp, float(i) / steps)
		var e := InputEventMouseMotion.new()
		e.position = to_screen(p)
		e.global_position = e.position
		e.relative = to_screen(p) - to_screen(mouse_at)
		e.button_mask = _mask
		_mods(e)
		root.warp_mouse(e.position)
		Input.parse_input_event(e)
		mouse_at = p
		await process_frame


var _mask := 0


func button(vp: Vector2, idx: int, pressed: bool, double := false) -> void:
	var e := InputEventMouseButton.new()
	e.position = to_screen(vp)
	e.global_position = e.position
	e.button_index = idx
	e.pressed = pressed
	e.double_click = double
	if pressed:
		_mask |= 1 << (idx - 1)
	else:
		_mask &= ~(1 << (idx - 1))
	e.button_mask = _mask
	_mods(e)
	Input.parse_input_event(e)


func click(vp: Vector2, idx := MOUSE_BUTTON_LEFT, double := false) -> void:
	if mouse_at.distance_to(vp) > 1.0:
		await move(vp, 2)
	button(vp, idx, true, double)
	await frames(2)
	button(vp, idx, false)
	await frames(2)


func double_click(vp: Vector2) -> void:
	await click(vp)
	await click(vp, MOUSE_BUTTON_LEFT, true)


func rclick(vp: Vector2) -> void:
	await click(vp, MOUSE_BUTTON_RIGHT)


func drag(a: Vector2, b: Vector2, idx := MOUSE_BUTTON_LEFT, steps := 8) -> void:
	await move(a, 2)
	button(a, idx, true)
	await frames(2)
	await move(b, steps)
	await frames(2)
	button(b, idx, false)
	await frames(2)


func wheel(vp: Vector2, up: bool, n := 1) -> void:
	await move(vp, 1)
	for i in n:
		button(vp, MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN, true)
		await process_frame
		button(vp, MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN, false)
		await process_frame


# ------------------------------------------------------------------ keys

func key_down(code: int, down: bool) -> void:
	var e := InputEventKey.new()
	e.keycode = code as Key
	e.physical_keycode = code as Key
	e.pressed = down
	if code >= KEY_A and code <= KEY_Z:
		e.unicode = code + 32 if not _shift else code
	_mods(e)
	match code:
		KEY_CTRL: _ctrl = down
		KEY_SHIFT: _shift = down
		KEY_ALT: _alt = down
	Input.parse_input_event(e)


func key(code: int, hold_frames := 2) -> void:
	key_down(code, true)
	await frames(hold_frames)
	key_down(code, false)
	await frames(2)


func ctrl_key(code: int) -> void:
	key_down(KEY_CTRL, true)
	await process_frame
	await key(code)
	key_down(KEY_CTRL, false)
	await process_frame


func shift_key(code: int) -> void:
	key_down(KEY_SHIFT, true)
	await process_frame
	await key(code)
	key_down(KEY_SHIFT, false)
	await process_frame


## Hold a key for some real seconds (arrow panning).
func hold_key(code: int, secs: float) -> void:
	key_down(code, true)
	await wait_real(secs)
	key_down(code, false)
	await frames(2)


func type_text(t: String) -> void:
	for ch in t:
		var e := InputEventKey.new()
		e.unicode = ch.unicode_at(0)
		e.keycode = OS.find_keycode_from_string(ch.to_upper()) if ch != " " else KEY_SPACE
		e.pressed = true
		Input.parse_input_event(e)
		await process_frame
		e = e.duplicate()
		e.pressed = false
		Input.parse_input_event(e)
		await process_frame


# ------------------------------------------------------------------ touch

func touch(vp: Vector2, pressed: bool, idx := 0) -> void:
	var e := InputEventScreenTouch.new()
	e.index = idx
	e.position = to_screen(vp)
	e.pressed = pressed
	Input.parse_input_event(e)


func touch_move(vp: Vector2, idx := 0, rel := Vector2.ZERO) -> void:
	var e := InputEventScreenDrag.new()
	e.index = idx
	e.position = to_screen(vp)
	e.relative = rel
	Input.parse_input_event(e)


func tap(vp: Vector2) -> void:
	touch(vp, true)
	await frames(3)
	touch(vp, false)
	await frames(3)


func double_tap(vp: Vector2) -> void:
	await tap(vp)
	await frames(2)
	await tap(vp)


func long_press(vp: Vector2, secs := 0.8) -> void:
	touch(vp, true)
	await wait_real(secs)
	touch(vp, false)
	await frames(3)


func swipe(a: Vector2, b: Vector2, steps := 10, idx := 0) -> void:
	touch(a, true, idx)
	await frames(2)
	var last := a
	for i in range(1, steps + 1):
		var p := a.lerp(b, float(i) / steps)
		touch_move(p, idx, p - last)
		last = p
		await process_frame
	touch(b, false, idx)
	await frames(3)


func pinch(c: Vector2, d0: float, d1: float, steps := 10) -> void:
	var a0 := c - Vector2(d0 / 2, 0)
	var b0 := c + Vector2(d0 / 2, 0)
	touch(a0, true, 0)
	touch(b0, true, 1)
	await frames(2)
	for i in range(1, steps + 1):
		var d := lerpf(d0, d1, float(i) / steps)
		touch_move(c - Vector2(d / 2, 0), 0)
		touch_move(c + Vector2(d / 2, 0), 1)
		await process_frame
	touch(c - Vector2(d1 / 2, 0), false, 0)
	touch(c + Vector2(d1 / 2, 0), false, 1)
	await frames(3)


## Press: a click on a computer, a tap on a phone.
func press(vp: Vector2) -> void:
	if device == "mobile":
		await tap(vp)
	else:
		await click(vp)


# ------------------------------------------------------------------ menus (Control nodes)

func all_controls(n: Node, out_a: Array, cls := "BaseButton") -> void:
	for ch in n.get_children():
		if ch is Control and ch.is_class(cls) and (ch as Control).is_visible_in_tree():
			out_a.append(ch)
		all_controls(ch, out_a, cls)


func buttons() -> Array:
	var a: Array = []
	all_controls(root, a)
	return a


func button_text(b: BaseButton) -> String:
	var t := ""
	if b is Button:
		t = (b as Button).text
	return t


## The visible button whose text matches (exact, then begins-with, case-insensitive).
func find_button(text: String) -> BaseButton:
	var bs := buttons()
	var want := text.to_upper()
	var tr := Loc.t(text).to_upper()
	if tr != want:
		for b in bs:
			if button_text(b).to_upper().strip_edges() == tr:
				return b
	for b in bs:
		if button_text(b).to_upper().strip_edges() == want:
			return b
	for b in bs:
		if button_text(b).to_upper().strip_edges().begins_with(want):
			return b
	return null


func ctl_center(c: Control) -> Vector2:
	return c.get_global_transform_with_canvas() * (c.size / 2.0)


func press_control(c: Control) -> void:
	await press(ctl_center(c))


func press_button(text: String) -> bool:
	var b := find_button(text)
	if b == null:
		finding("UI: no button '%s' on screen" % text)
		return false
	step("press '%s'" % text)
	await press_control(b)
	await frames(3)
	return true


func list_buttons() -> String:
	var t: Array = []
	for b in buttons():
		var s := button_text(b).replace("\n", " ")
		if s != "":
			t.append(s)
	return ", ".join(t)


# ------------------------------------------------------------------ the match

func game() -> Game:
	return main.game


func hud():
	return main.game.hud if main.game else null


## The HUD's buttons (rects in viewport pixels) with their card labels.
func hud_buttons() -> Array:
	var h = hud()
	if h == null:
		return []
	var res: Array = []
	for b in h._all_buttons():
		var lab := ""
		if b.has("item"):
			var it: Array = b["item"]
			lab = String(it[1]) if it.size() > 1 else ""
		var r: Rect2 = b["rect"]
		res.append({"label": lab, "rect": Rect2(r.position * h.ui_scale, r.size * h.ui_scale), "enabled": bool(b.get("enabled", true)), "why": String(b.get("why", "")), "raw": b})
	return res


func clean_label(s: String) -> String:
	return s.trim_prefix("> ").trim_prefix("~ ").split("\n")[0].strip_edges().to_upper()


func card_labels() -> Array:
	var a: Array = []
	if hud() and hud().has_method("_build_card"):
		pass
	for b in hud_buttons():
		if b["label"] != "":
			a.append(clean_label(b["label"]) + ("" if b["enabled"] else "(x)"))
	return a


func find_card(label: String) -> Dictionary:
	var want := label.to_upper()
	for b in hud_buttons():
		if clean_label(b["label"]) == want:
			return b
	for b in hud_buttons():
		if clean_label(b["label"]).begins_with(want):
			return b
	return {}


## Press a command card button by its label. Returns "ok", "refused: <why>" or "missing".
func card(label: String) -> String:
	var b := find_card(label)
	if b.is_empty():
		step("card '%s' missing; card: %s" % [label, ", ".join(card_labels())])
		return "missing"
	await press((b["rect"] as Rect2).get_center())
	await frames(2)
	if not b["enabled"]:
		step("card '%s' refused: %s" % [label, b["why"]])
		return "refused: " + String(b["why"])
	step("card '%s'" % label)
	return "ok"


func toast_text() -> String:
	var h = hud()
	return String(h._msg) if h else ""


func me() -> int:
	return game().human


func my_units(kind := "") -> Array:
	var g := game()
	return g.units.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead and u.team == g.human and (kind == "" or u.kind == kind))


func my_buildings(kind := "") -> Array:
	var g := game()
	return g.buildings.filter(func(b) -> bool: return is_instance_valid(b) and not b.dead and b.team == g.human and (kind == "" or b.kind == kind))


func res() -> Dictionary:
	return game().players[game().human]


## A world point on screen (viewport pixels).
func w2s(w: Vector2) -> Vector2:
	return game().get_viewport().get_canvas_transform() * w


func on_screen(vp: Vector2, margin := 10.0) -> bool:
	var r := Rect2(Vector2.ZERO, vp_size()).grow(-margin)
	var h = hud()
	return r.has_point(vp) and not (h and h.hud_has_screen(vp))


## Moves the camera with the minimap so a world point is on screen (as a player does); returns its screen spot.
func look_at(w: Vector2) -> Vector2:
	var p := w2s(w)
	if on_screen(p, 40):
		return p
	var h = hud()
	var m: Rect2 = h.mini_rect()
	var f := w / (Vector2(Game.W, Game.H) * Game.T)
	var mp: Vector2 = (m.position + f * m.size) * h.ui_scale
	await press(mp)
	await frames(4)
	return w2s(w)


## Click (select) an entity of mine on screen.
func select_ent(e) -> void:
	var p := await look_at(ent_point(e))
	await press(p)
	await settle()


## Where a player clicks an entity: a building's middle, a unit's body.
func ent_point(e) -> Vector2:
	if e is Building:
		return (e as Building).rect().get_center()
	return e.position + Vector2(0, -12)


## Lets the HUD catch up (its card is rebuilt on its own beat).
func settle() -> void:
	await frames(4)
	await wait_real(0.12)


func errors_seen() -> void:
	pass
