extends RefCounted
## The player's HAND in a match (playtest-campaign-brood): every order given the way a person gives it, with real
## input events: the view moved by a click on the minimap, a creature picked by clicking it (Shift-click to add), the
## army by F2, a command card button clicked at its rect, a point or an enemy right-clicked, attack-move with A + click.
## Reading the game's state (where a unit is, what the card holds) is allowed; changing it is not.
##   var hand = preload("res://tools/playtest/pt_hand.gd").new(pt, game)

var pt
var g: Game
var fails := 0


func _init(p, game: Game) -> void:
	pt = p
	g = game


func hud() -> Control:
	return g.hud


func on_screen(w: Vector2, margin := 60.0) -> bool:
	var s: Vector2 = pt.to_screen(g, w)
	var v: Vector2 = pt.vs()
	# (inside the view and off the HUD's bottom panel, the minimap and the card)
	if not Rect2(Vector2(margin, margin), v - Vector2(margin, margin) * 2.0).has_point(s):
		return false
	for k in ["mini", "card", "panel", "hotbar"]:
		var r: Rect2 = _hud_rect(k)
		if r.grow(8).has_point(s):
			return false
	return true


func _hud_rect(k: String) -> Rect2:
	var h := hud()
	if h == null:
		return Rect2()
	var rects: Dictionary = h._layout()
	if not rects.has(k):
		return Rect2()
	var xf: Transform2D = h.get_global_transform()
	var r: Rect2 = rects[k]
	return Rect2(xf * r.position, xf.basis_xform(r.size))


## Move the view to a world point: a click on the minimap (as a player does).
func look(w: Vector2) -> void:
	var m := _hud_rect("mini")
	if m.size.x <= 0.0:
		return
	var f := (w / (Vector2(Game.W, Game.H) * Game.T)).clamp(Vector2.ZERO, Vector2.ONE)
	await pt.click(m.position + f * m.size)
	await pt.frames(3)


func see(w: Vector2) -> void:
	if not on_screen(w):
		await look(w)


func screen(w: Vector2) -> Vector2:
	return pt.to_screen(g, w)


## Pick one unit by clicking it (shift: add it to the selection).
func pick(u: Entity, shift := false) -> bool:
	if u == null or not is_instance_valid(u) or u.dead:
		return false
	await see(u.position if u is Unit else u.center())
	var p := screen(u.position if u is Unit else u.center())
	if u is Unit:
		p += Vector2(0, -6)       # (a creature's body is drawn above its feet)
	await pt.click(p, MOUSE_BUTTON_LEFT, false, shift)
	await pt.frames(2)
	if not g.selection.has(u):
		# a second try a little higher (big creatures)
		await pt.click(p + Vector2(0, -14), MOUSE_BUTTON_LEFT, false, shift)
		await pt.frames(2)
	if not g.selection.has(u):
		fails += 1
		pt.note("HAND", "a click on %s at %s didn't pick it (picked: %s)" % [u.kind, p, g.selection.map(func(x): return x.kind if is_instance_valid(x) else "?")])
		return false
	return true


## The army (F2: the hotkey bar's ARMY).
func army() -> void:
	await pt.key(KEY_F2)


func escape() -> void:
	await pt.key(KEY_ESCAPE)


## The labels on the command card now.
func card_labels() -> Array:
	var h := hud()
	if h == null:
		return []
	var out: Array = []
	for b in h.get("_card_buttons"):
		var it: Variant = b.get("item", [])
		if it is Array and (it as Array).size() > 1:
			out.append(_lab(it))
	return out


func _card_btn(what: String) -> Dictionary:
	var h := hud()
	if h == null:
		return {}
	for b in h.get("_card_buttons"):
		var it: Variant = b.get("item", [])
		if not (it is Array) or (it as Array).size() < 2:
			continue
		if String(it[0]) == what or _lab(it).to_upper() == what.to_upper():
			return b
	for b in h.get("_card_buttons"):
		var it: Variant = b.get("item", [])
		if it is Array and (it as Array).size() > 1 and _lab(it).to_upper().begins_with(what.to_upper()):
			return b
	return {}


## Press a command card button (by its icon or label).
func card(what: String) -> bool:
	await pt.frames(2)
	var b := _card_btn(what)
	if b.is_empty():
		pt.note("HAND", "no '%s' on the card (it has %s)" % [what, card_labels()])
		fails += 1
		return false
	var h := hud()
	var xf: Transform2D = h.get_global_transform()
	var r: Rect2 = b["rect"]
	await pt.click(xf * r.get_center())
	await pt.frames(2)
	return true


## Click on the ground (left: a placement or a point for a waiting order; right: move / attack there).
func ground(w: Vector2, btn := MOUSE_BUTTON_LEFT, shift := false) -> void:
	await see(w)
	if btn == MOUSE_BUTTON_LEFT and not pt.touch:
		pt.move(screen(w))          # (a placing ghost follows the mouse)
		await pt.frames(2)
	await pt.click(screen(w), btn, false, shift)


## The selection moves to `w` (right click), or attack-moves there (A, then a click).
func go(w: Vector2, attack := false) -> void:
	if attack:
		await see(w)
		await pt.key(KEY_A)
		await ground(w)
	else:
		await ground(w, MOUSE_BUTTON_RIGHT)


## The selection attacks `e` (a right click on it).
func hit(e: Entity) -> void:
	if e == null or not is_instance_valid(e) or e.dead:
		return
	var w: Vector2 = e.position if e is Unit else e.center()
	await see(w)
	await pt.click(screen(w) + Vector2(0, -6), MOUSE_BUTTON_RIGHT)


## Select a group by dragging a box round it.
func box(a: Vector2, b: Vector2) -> void:
	await see((a + b) * 0.5)
	await pt.drag(screen(a), screen(b))


static func _lab(it: Array) -> String:
	return String(it[1]).trim_prefix("> ").trim_prefix("~ ")


## The match menu (top right MENU) and one of its items by its label (PAUSE, RESUME, QUIT TO MENU, YES...).
func menu() -> void:
	var h := hud()
	if bool(h.get("menu_open")):
		return
	var xf: Transform2D = h.get_global_transform()
	await pt.click(xf * h.menu_rect().get_center())
	await pt.frames(3)


func menu_labels() -> Array:
	return hud()._menu_buttons().map(func(b) -> String: return String(b["label"]))


func menu_item(label: String) -> bool:
	var h := hud()
	var xf: Transform2D = h.get_global_transform()
	for b in h._menu_buttons():
		if String(b["label"]).to_upper().begins_with(label.to_upper()):
			await pt.click(xf * (b["rect"] as Rect2).get_center())
			await pt.frames(3)
			return true
	pt.note("HAND", "no menu item '%s' (menu: %s)" % [label, menu_labels()])
	fails += 1
	return false
