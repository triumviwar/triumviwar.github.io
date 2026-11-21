extends RefCounted
## Playtest helper for the Brood skirmish playtest (job playtest-skirmish-brood, docs/playtest_2026_11_21_skirmish_brood.md).
## A "hand" that plays the game through REAL input events only (mouse, keys, touch), like a person at the screen:
## Input.parse_input_event / warp_mouse. It may READ the game (where a button is, where a unit stands) to decide.
## Used by tools/playtest/brood_*.gd drivers (each extends SceneTree and makes one of these).

var tree: SceneTree
var root: Window
var shots_dir := "res://docs/shots/playtest_2026_11_21/skirmish_brood/"
var tag := "pt"                # a prefix for screenshots (player type)
var log_lines: Array = []      # the driver's own notes (also printed)
var mouse := Vector2(640, 360)
var shift := false
var ctrl := false
var touch_mode := false        # phone: taps instead of clicks


func _init(t: SceneTree) -> void:
	tree = t
	root = t.root
	Input.use_accumulated_input = false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(shots_dir))


func note(s: String) -> void:
	var line := "[PT %s] %s" % [tag, s]
	log_lines.append(line)
	print(line)


# ------------------------------------------------------------------ time

func frames(n := 1) -> void:
	for i in n:
		await tree.process_frame


## Real seconds (scaled by Engine.time_scale as game time)
func secs(t: float) -> void:
	await tree.create_timer(t, true, false, false).timeout


# ------------------------------------------------------------------ coordinates

## canvas (viewport) coordinates -> window coordinates (what a real event carries)
func win(p: Vector2) -> Vector2:
	return root.get_final_transform() * p


func vsize() -> Vector2:
	return root.get_visible_rect().size


## a world point on screen (viewport coordinates), with the game's camera
func w2s(game: Node, p: Vector2) -> Vector2:
	return game.get_viewport().get_canvas_transform() * p


func on_screen(p: Vector2, margin := 4.0) -> bool:
	return Rect2(Vector2.ZERO, vsize()).grow(-margin).has_point(p)


# ------------------------------------------------------------------ mouse

func _mask(btn: int) -> int:
	return {MOUSE_BUTTON_LEFT: MOUSE_BUTTON_MASK_LEFT, MOUSE_BUTTON_RIGHT: MOUSE_BUTTON_MASK_RIGHT,
		MOUSE_BUTTON_MIDDLE: MOUSE_BUTTON_MASK_MIDDLE}.get(btn, 0)


func _mods(ev: InputEventWithModifiers) -> void:
	ev.shift_pressed = shift
	ev.ctrl_pressed = ctrl


func move(p: Vector2, held_mask := 0) -> void:
	var rel := p - mouse
	mouse = p
	root.warp_mouse(p)
	var ev := InputEventMouseMotion.new()
	ev.position = win(p)
	ev.global_position = win(p)
	ev.relative = rel
	ev.button_mask = held_mask
	_mods(ev)
	Input.parse_input_event(ev)


func button(p: Vector2, btn: int, pressed: bool, dbl := false) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = btn
	ev.pressed = pressed
	ev.double_click = dbl and pressed
	ev.position = win(p)
	ev.global_position = win(p)
	ev.button_mask = _mask(btn) if pressed else 0
	_mods(ev)
	Input.parse_input_event(ev)


func click(p: Vector2, btn := MOUSE_BUTTON_LEFT, hold_frames := 2) -> void:
	if touch_mode and btn == MOUSE_BUTTON_LEFT:
		await tap(p)
		return
	move(p)
	await frames(1)
	button(p, btn, true)
	await frames(hold_frames)
	button(p, btn, false)
	await frames(2)


func rclick(p: Vector2) -> void:
	await click(p, MOUSE_BUTTON_RIGHT)


func dbl_click(p: Vector2) -> void:
	move(p)
	await frames(1)
	button(p, MOUSE_BUTTON_LEFT, true)
	await frames(1)
	button(p, MOUSE_BUTTON_LEFT, false)
	await frames(2)
	button(p, MOUSE_BUTTON_LEFT, true, true)
	await frames(1)
	button(p, MOUSE_BUTTON_LEFT, false)
	await frames(2)


func drag(a: Vector2, b: Vector2, btn := MOUSE_BUTTON_LEFT, steps := 8) -> void:
	if touch_mode and btn == MOUSE_BUTTON_LEFT:
		await touch_drag(a, b, 0, steps)
		return
	move(a)
	await frames(1)
	button(a, btn, true)
	await frames(1)
	for i in range(1, steps + 1):
		move(a.lerp(b, float(i) / steps), _mask(btn))
		await frames(1)
	button(b, btn, false)
	await frames(2)


func wheel(p: Vector2, up: bool, n := 1) -> void:
	move(p)
	for i in n:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN
		ev.pressed = true
		ev.position = win(p)
		ev.global_position = win(p)
		Input.parse_input_event(ev)
		var ev2 := ev.duplicate()
		ev2.pressed = false
		Input.parse_input_event(ev2)
		await frames(1)


# ------------------------------------------------------------------ keys

func key(code: int, hold_frames := 1) -> void:
	var ev := InputEventKey.new()
	ev.keycode = code
	ev.physical_keycode = code
	ev.pressed = true
	_mods(ev)
	Input.parse_input_event(ev)
	await frames(hold_frames)
	var up := ev.duplicate()
	up.pressed = false
	Input.parse_input_event(up)
	await frames(1)


func key_down(code: int, down: bool) -> void:
	var ev := InputEventKey.new()
	ev.keycode = code
	ev.physical_keycode = code
	ev.pressed = down
	_mods(ev)
	Input.parse_input_event(ev)


## a modifier held (Shift / Ctrl) for the next events: sends the key itself too, as a keyboard does
func hold_shift(on: bool) -> void:
	shift = on
	key_down(KEY_SHIFT, on)


func hold_ctrl(on: bool) -> void:
	ctrl = on
	key_down(KEY_CTRL, on)


func letter(s: String) -> void:
	await key(OS.find_keycode_from_string(s))


# ------------------------------------------------------------------ touch

func touch(p: Vector2, idx: int, pressed: bool) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = idx
	ev.position = win(p)
	ev.pressed = pressed
	Input.parse_input_event(ev)


func touch_move(p: Vector2, idx: int, rel := Vector2.ZERO) -> void:
	var ev := InputEventScreenDrag.new()
	ev.index = idx
	ev.position = win(p)
	ev.relative = rel
	Input.parse_input_event(ev)


func tap(p: Vector2, hold_frames := 2) -> void:
	touch(p, 0, true)
	await frames(hold_frames)
	touch(p, 0, false)
	await frames(3)


func double_tap(p: Vector2) -> void:
	await tap(p, 1)
	await tap(p, 1)


func long_press(p: Vector2, t := 0.7) -> void:
	touch(p, 0, true)
	await secs(t)
	touch(p, 0, false)
	await frames(3)


func touch_drag(a: Vector2, b: Vector2, idx := 0, steps := 10) -> void:
	touch(a, idx, true)
	await frames(1)
	var last := a
	for i in range(1, steps + 1):
		var p := a.lerp(b, float(i) / steps)
		touch_move(p, idx, p - last)
		last = p
		await frames(1)
	touch(b, idx, false)
	await frames(3)


## two fingers: out = spread (zoom in)
func pinch(c: Vector2, from_d: float, to_d: float, steps := 10) -> void:
	var a0 := c - Vector2(from_d / 2, 0)
	var b0 := c + Vector2(from_d / 2, 0)
	touch(a0, 0, true)
	touch(b0, 1, true)
	await frames(1)
	for i in range(1, steps + 1):
		var d := lerpf(from_d, to_d, float(i) / steps)
		touch_move(c - Vector2(d / 2, 0), 0)
		touch_move(c + Vector2(d / 2, 0), 1)
		await frames(1)
	touch(c - Vector2(to_d / 2, 0), 0, false)
	touch(c + Vector2(to_d / 2, 0), 1, false)
	await frames(3)


# ------------------------------------------------------------------ menus (Controls)

func all_buttons(n: Node, out: Array = []) -> Array:
	for ch in n.get_children():
		if ch is BaseButton and (ch as Control).is_visible_in_tree():
			out.append(ch)
		all_buttons(ch, out)
	return out


func _norm(s: String) -> String:
	return s.replace("▼", "").replace("√", "").strip_edges().to_upper()


## a visible button whose text (as shown, translated) starts with `text` (or equals it when exact)
func find_button(text: String, exact := false, under: Node = null) -> BaseButton:
	var want := _norm(text)
	var want_tr := _norm(Loc.t(text))      # (some pages set their text already translated)
	var best: BaseButton = null
	for b in all_buttons(under if under else root):
		var t := ""
		if b is Button:
			t = _norm((b as Button).text)
			var shown := _norm(b.atr((b as Button).text))
			if shown == want or t == want or t == want_tr:
				return b
			if not exact and best == null and (t.begins_with(want) or shown.begins_with(want) or t.begins_with(want_tr)):
				best = b
	return best


func button_texts(under: Node = null) -> Array:
	var out: Array = []
	for b in all_buttons(under if under else root):
		if b is Button:
			out.append(_norm((b as Button).text))
	return out


## a person scrolls a list (the mouse wheel, or a finger drag on a phone) until the control shows
func scroll_into_view(c: Control) -> void:
	var sc: ScrollContainer = null
	var n := c.get_parent()
	while n != null:
		if n is ScrollContainer:
			sc = n
			break
		n = n.get_parent()
	if sc == null:
		return
	for i in 60:
		var view := sc.get_global_rect()
		var r := c.get_global_rect()
		if view.encloses(r):
			return
		var down := r.get_center().y > view.get_center().y
		var before := sc.scroll_vertical
		if touch_mode:
			var mid := view.get_center()
			await touch_drag(mid, mid + Vector2(0, -view.size.y * 0.3 if down else view.size.y * 0.3), 0, 6)
		if sc.scroll_vertical == before:
			# (a finger drag doesn't scroll a list on a machine with no touch screen, as here under xvfb: the wheel then)
			await wheel(view.get_center(), not down, 1)
		await frames(1)


func click_control(c: Control) -> void:
	await scroll_into_view(c)
	var r := c.get_global_rect()
	await click(r.get_center())


func click_text(text: String, exact := false, under: Node = null) -> bool:
	var b := find_button(text, exact, under)
	if b == null:
		note("NO BUTTON '%s' (have: %s)" % [text, ", ".join(button_texts(under).slice(0, 40))])
		return false
	if b.disabled:
		note("button '%s' is disabled" % text)
	await click_control(b)
	return true


# ------------------------------------------------------------------ the HUD's command card (drawn, not Controls)

## [{label, rect (screen), enabled, why, key}] of the card as drawn now
func card(hud: Node) -> Array:
	var out: Array = []
	var sc: float = hud.ui_scale
	for b in hud._card_buttons:
		var it: Array = b["item"]
		var r: Rect2 = b["rect"]
		out.append({"label": String(it[1]).trim_prefix("> ").trim_prefix("~ "), "raw": String(it[1]), "rect": Rect2(r.position * sc, r.size * sc),
			"enabled": bool(it[3]), "why": String(it[4]) if it.size() > 4 else "", "key": String(it[6]) if it.size() > 6 else "", "icon": String(it[0])})
	return out


func card_labels(hud: Node) -> Array:
	return card(hud).map(func(b: Dictionary) -> String: return b["label"])


func card_find(hud: Node, label: String) -> Dictionary:
	var want := label.to_upper()
	for b in card(hud):
		if b["label"] == want or String(b["label"]).begins_with(want):
			return b
	return {}


## click a card button by its label (through its screen rect); returns its entry ({} if none)
func card_click(hud: Node, label: String, btn := MOUSE_BUTTON_LEFT) -> Dictionary:
	hud._redraw_t = 0.0
	await frames(2)
	var b := card_find(hud, label)
	if b.is_empty():
		note("card has no '%s' (has: %s)" % [label, ", ".join(card_labels(hud))])
		return {}
	await click((b["rect"] as Rect2).get_center(), btn)
	return b


# ------------------------------------------------------------------ pictures

var _shot_n := 0
func shot(name: String) -> String:
	await frames(2)
	_shot_n += 1
	var img := root.get_texture().get_image()
	if img == null:
		return ""
	var path := shots_dir + "%s_%02d_%s.jpg" % [tag, _shot_n, name]
	if img.get_width() > 1400:
		img.resize(img.get_width() / 2, img.get_height() / 2)
	img.save_jpg(ProjectSettings.globalize_path(path), 0.82)
	note("shot " + path)
	return path


# ------------------------------------------------------------------ the way into a match (main menu -> SKIRMISH -> START)

func _dropdowns(main: Node) -> Array:
	var out: Array = []
	for b in all_buttons(main.menu):
		if b is Button and String((b as Button).text).ends_with("▼"):
			out.append(b)
	return out


func pick_list(main: Node, dd: Button, item: String) -> bool:
	await click_control(dd)
	await frames(3)
	var shade: Node = main.ui_layer.get_child(main.ui_layer.get_child_count() - 1)
	var ok: bool = await click_text(item, false, shade)
	await frames(4)
	if not ok:
		await click(Vector2(4, 4))      # (close the list)
		await frames(3)
	return ok


## from the device page or the main menu to a started match. o: {opp: crown|clockwork|brood, who: hard|..., plan: OPTIMAL|..,
## map: list label start, e.g. "HOLLOWFEN" (or "" = the random pool), lang}
func into_match(main: Node, o: Dictionary) -> bool:
	await frames(8)
	var lang := String(o.get("lang", "en"))
	if lang != "en" and Settings.language != lang:
		# the flags in the corner of the first page (their tooltips name the language)
		for b in all_buttons(main.menu):
			if String(b.tooltip_text) == Loc.NATIVE[lang]:
				var was0 := touch_mode
				touch_mode = false
				await click_control(b)
				touch_mode = was0
				break
		await frames(8)
		note("language now %s" % Settings.language)
	var dev := "MOBILE" if touch_mode else "COMPUTER"
	if find_button(dev, true) != null and find_button("SKIRMISH") == null:
		var was := touch_mode
		touch_mode = false
		await click_text(dev, true)
		touch_mode = was
		await frames(8)
	if o.get("sandbox", false):
		if not await click_text("EDITOR"):
			return false
		await frames(6)
		if not await click_text("SANDBOX"):
			return false
	elif not await click_text("SKIRMISH"):
		return false
	await frames(8)
	await click_text("1v1", true)
	await frames(6)
	var dds := _dropdowns(main)
	await pick_list(main, dds[1], Defs.faction_label("brood").to_upper())
	var rows := func() -> Array:
		var d := _dropdowns(main)
		var y0: float = d[0].get_global_rect().position.y
		return d.filter(func(b: Button) -> bool: return b.get_global_rect().position.y > y0 + 20 and b.get_global_rect().position.x < vsize().x * 0.7)
	await pick_list(main, rows.call()[0], String(o.get("who", "hard")).to_upper() + " AI")
	await pick_list(main, rows.call()[1], Defs.faction_label(String(o.get("opp", "crown"))).to_upper())
	await pick_list(main, rows.call()[3], String(o.get("plan", "OPTIMAL")).to_upper())
	if String(o.get("map", "")) != "":
		var mapdd: Button = null
		for b in _dropdowns(main):
			if b.get_global_rect().position.x > vsize().x * 0.6:
				mapdd = b
		await pick_list(main, mapdd, String(o["map"]).to_upper())
	await shot("lobby")
	note("lobby: %s" % JSON.stringify(main.lobby))
	var go := find_button("START", true)
	if go == null or go.disabled:
		note("START missing or disabled")
		return false
	await click_control(go)
	for i in 600:
		await frames(1)
		if main.game != null and main.game.is_inside_tree():
			break
	await secs(1.0)
	return main.game != null


# ------------------------------------------------------------------ the in-match MENU (drawn by the HUD)

func menu_labels(hud: Node) -> Array:
	return hud._menu_buttons().map(func(b: Dictionary) -> String: return String(b["label"]))


func menu_click(hud: Node, label: String) -> bool:
	if not hud.menu_open:
		await click(hud.menu_rect().get_center() * hud.ui_scale)
		await frames(4)
	for b in hud._menu_buttons():
		if String(b["label"]).begins_with(label):
			await click((b["rect"] as Rect2).get_center() * hud.ui_scale)
			await frames(4)
			return true
	note("menu has no '%s' (has %s)" % [label, ", ".join(menu_labels(hud))])
	return false


## hover a card button long enough for its tooltip, and return the screenshot path
func hover_card(hud: Node, label: String, name: String) -> String:
	var b := card_find(hud, label)
	if b.is_empty():
		return ""
	move((b["rect"] as Rect2).get_center())
	await secs(1.2)
	hud._redraw_t = 0.0
	await frames(3)
	return await shot(name)
