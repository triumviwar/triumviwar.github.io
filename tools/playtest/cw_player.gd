extends RefCounted
## A Clockwork player's hands (job playtest-skirmish-clockwork). It READS the match (where things are, what the card
## shows, what can be afforded) and ACTS only through cw_input: the minimap and arrow keys move the camera, clicks
## and drags select, card buttons are clicked or their hotkeys pressed, right clicks command. `style` changes how:
##   careful: clicks the card buttons, checks results;   fast: hotkeys, double-clicks, control groups;
##   phone: taps, the phone's card and its drag rules.
## Every action returns whether it seemed to work; refusals and odd results go to io.note() as findings.

var io
var g: Game
var hud
var style := "careful"
var phone := false
var issues: Array = []       # [what, detail]


func _init(input, game: Game, st: String) -> void:
	io = input
	g = game
	hud = g.hud
	style = st
	phone = st == "phone"


func issue(what: String, detail := "") -> void:
	issues.append([what, detail])
	io.note("ISSUE " + what + ("  " + detail if detail != "" else ""))


func me() -> int:
	return g.human


func pl() -> Dictionary:
	return g.players[g.human]


func cogs() -> int:
	return int(pl()["gold"])


func tension() -> float:
	return float(pl().get("tension", 0.0))


func mine(kind: String, built_only := true) -> Array:
	var out: Array = []
	for e in g.units + g.buildings:
		if is_instance_valid(e) and not e.dead and e.team == me() and e.kind == kind:
			if built_only and e is Building and not (e as Building).built:
				continue
			out.append(e)
	return out


func has_kind(kind: String) -> bool:
	for e in g.buildings:
		if is_instance_valid(e) and not e.dead and e.team == me() and e.kind == kind:
			return true
	return false


# ------------------------------------------------------------------ the camera

func to_screen(w: Vector2) -> Vector2:
	return g.get_viewport().get_canvas_transform() * w


func on_field(p: Vector2) -> bool:
	return Rect2(Vector2(8, 44) * hud.ui_scale, io.vs() - Vector2(16, 52) * hud.ui_scale).has_point(p) and not hud.hud_has_screen(p)


## A HUD rectangle (the HUD works in its own space, drawn at ui_scale: bigger on a phone) on the screen.
func hs(r: Rect2) -> Rect2:
	return Rect2(r.position * hud.ui_scale, r.size * hud.ui_scale)


## Bring a world point into view: a click on the minimap (or a tap), then arrow keys if the HUD hides it.
func look_at(w: Vector2) -> Vector2:
	var p := to_screen(w)
	if on_field(p) and p.distance_to(io.vs() * Vector2(0.5, 0.4)) < io.vs().y * 0.35:
		return p
	var m: Rect2 = hs(hud.mini_rect())
	var f := (w / (Vector2(Game.W, Game.H) * Game.T)).clamp(Vector2(0.01, 0.01), Vector2(0.99, 0.99))
	var mp := m.position + f * m.size
	if phone:
		await io.tap(mp)
	else:
		await io.click(mp)
	await io.frames(2)
	p = to_screen(w)
	var tries := 0
	while not on_field(p) and tries < 12:
		tries += 1
		var k := KEY_DOWN if p.y > io.vs().y * 0.5 else KEY_UP
		if p.x < 30: k = KEY_LEFT
		elif p.x > io.vs().x - 30: k = KEY_RIGHT
		await io.hold_key(k, 0.12)
		p = to_screen(w)
	if not on_field(p):
		issue("camera", "could not bring %s into view (screen %s)" % [w, p])
	return p


func where(e: Entity) -> Vector2:
	return e.center()


## A click (or tap) on something of mine: it becomes the selection.
func select(e: Entity, add := false) -> bool:
	if not is_instance_valid(e) or e.dead:
		return false
	var p := await look_at(where(e))
	if phone:
		await io.tap(p)
	else:
		await io.click(p, MOUSE_BUTTON_LEFT, add)
	await io.frames(2)
	if not g.selection.has(e):
		# a click a little up (sprites stand above their feet)
		p = to_screen(where(e)) + Vector2(0, -10)
		if phone:
			await io.tap(p)
		else:
			await io.click(p, MOUSE_BUTTON_LEFT, add)
		await io.frames(2)
	return g.selection.has(e)


## Box-select around a world rectangle's centre (computer: left drag; phone: one-finger drag in BOX mode).
func box(wa: Vector2, wb: Vector2) -> int:
	await look_at((wa + wb) * 0.5)
	var a := to_screen(wa)
	var b := to_screen(wb)
	if phone:
		await io.swipe(a, b)
	else:
		await io.drag(a, b)
	await io.frames(2)
	return g.selection.size()


# ------------------------------------------------------------------ the card

func card() -> Array:
	return hud._card_buttons


func card_labels() -> Array:
	var out: Array = []
	for b in card():
		out.append(String(b["item"][1]).trim_prefix("> ").trim_prefix("~ "))
	return out


static func norm(l: String) -> String:
	var s := l.trim_prefix("> ").trim_prefix("~ ").to_upper().strip_edges()
	var re := RegEx.create_from_string(" \\d+/\\d+$")
	return re.sub(s, "").strip_edges()


func card_find(label: String) -> Dictionary:
	await io.frames(2)
	var want := label.to_upper()
	for b in card():
		if norm(String(b["item"][1])) == want:
			return b
	for b in card():
		var n := norm(String(b["item"][1]))
		if n.length() >= 3 and want.begins_with(n + " "):
			return b
	return {}


## Press a card button by its label: click it (careful, phone: tap) or its hotkey (fast). Returns "" or why not.
func press(label: String, shift := false) -> String:
	var b := await card_find(label)
	if b.is_empty():
		# a long card: Tab pages on a computer, a drag on a phone
		if not phone:
			await io.key(KEY_TAB)
			b = await card_find(label)
		if b.is_empty():
			return "no '%s' on the card (%s)" % [label, ", ".join(card_labels())]
	var it: Array = b["item"]
	var why := "" if it[3] else String(it[4])
	var key := String(it[6]) if it.size() > 6 else ""
	if style == "fast" and key.length() == 1 and not phone:
		await io.key(OS.find_keycode_from_string(key), shift)
	else:
		var r: Rect2 = hs(b["rect"])
		if phone:
			await io.tap(r.get_center())
		else:
			await io.click(r.get_center(), MOUSE_BUTTON_LEFT, shift)
	await io.frames(2)
	return why


# ------------------------------------------------------------------ building

func free_winder(near := Vector2.INF) -> Unit:
	var best: Unit = null
	var bd := INF
	for u in mine("winder"):
		var busy: bool = u.order in ["build", "repair"]
		var score := 0.0 if u.order in ["", "idle"] else (1e6 if busy else 1e5)
		if near.is_finite():
			score += u.global_position.distance_to(near)
		if score < bd:
			bd = score
			best = u
	return best


## A Winder to give an order to: one out on the field (a click on him), else the WINDERS label over a press or the
## Mainspring (a click on it picks its crew, as a player pulls hands off a press).
func select_a_winder(near := Vector2.INF) -> bool:
	var best: Unit = null
	var bd := INF
	for u in mine("winder"):
		if u.off_field or not u.visible or u.work == "manning":
			continue
		var d := 0.0 if u.order in ["", "idle"] else 5000.0
		if near.is_finite():
			d += u.global_position.distance_to(near)
		if d < bd:
			bd = d
			best = u
	if best != null and await select(best):
		return true
	for k in [Defs.GEAR_PRESS, "mainspring"]:
		for b in mine(k):
			if b.crew.is_empty():
				continue
			var L: Dictionary = WorkerLabels.layout(g, b)
			if L.is_empty() or not L.has("rect"):
				continue
			var wp: Vector2 = (L["rect"] as Rect2).get_center()
			await look_at(wp)
			var sp := to_screen(wp)
			if phone:
				await io.tap(sp)
			else:
				await io.click(sp)
			await io.frames(2)
			if g.selected_units().any(func(x: Unit) -> bool: return x.kind == "winder"):
				return true
			issue("worker label", "a click on the %s's WINDERS label did not pick its crew" % k)
	return false


## The building's footprint top-left cell for a world point under the mouse (Controls._move_ghost backwards).
func mouse_for_cell(kind: String, c: Vector2i) -> Vector2:
	var size: Vector2i = Defs.BUILDINGS[kind]["size"]
	return Vector2(c) * Defs.TILE + Vector2(size) * Defs.TILE * 0.5


## A good free cell for `kind` round `anchor` (what a player sees as the green ghost). Nearest first.
func find_spot(kind: String, anchor: Vector2, rmin := 2, rmax := 22) -> Vector2i:
	var ac := g.cell_of(anchor)
	for r in range(rmin, rmax):
		var cands: Array = []
		for dx in range(-r, r + 1):
			for dy in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				cands.append(ac + Vector2i(dx, dy))
		cands.shuffle()
		for c in cands:
			if g.placement_problem(me(), kind, c) == "":
				return c
	return Vector2i(-1, -1)


## Select a Winder, BUILD, the building's button, (G for a big gear), move the ghost, click. Returns "" or why not.
func build(kind: String, anchor: Vector2, big := false, rmin := 2) -> String:
	var name := String(Defs.BUILDINGS[kind]["name"]).to_upper()
	if not await select_a_winder(anchor):
		return "could not select a Winder"
	var why := await press("BUILD")
	if why != "":
		return "BUILD: " + why
	await io.frames(2)
	why = await press(name)
	if why != "":
		await io.key(KEY_ESCAPE)
		return "%s: %s" % [name, why]
	if hud.controls.mode != "place":
		await io.key(KEY_ESCAPE)
		return "%s pressed but no ghost (mode '%s')" % [name, hud.controls.mode]
	if GearNet.pickable(kind) and g.gear_big_for(me(), kind) != big:
		if style == "fast":
			await io.key(KEY_G)
		else:
			await press("BIG GEAR" if not big else "SMALL GEAR")
	var c := find_spot(kind, anchor, rmin)
	if c.x < 0:
		await io.key(KEY_ESCAPE)
		return "no free spot for %s near %s" % [name, anchor]
	var wp := mouse_for_cell(kind, c)
	var p := await look_at(wp)
	io.move_to(p)
	await io.frames(2)
	if hud.controls.ghost_cell != c:
		io.move_to(p + Vector2(1, 1))
		await io.frames(2)
	var prob: String = g.placement_problem(me(), kind, hud.controls.ghost_cell)
	if prob != "":
		issue("ghost", "%s: the ghost sits at %s, wanted %s: %s" % [name, hud.controls.ghost_cell, c, prob])
	var n_before := g.buildings.size()
	if phone:
		# a phone places with the PLACE button after the ghost is dragged (or tapped) there
		await io.tap(p)
		why = await press("PLACE")
	else:
		await io.click(p)
	await io.frames(3)
	if hud.controls.mode == "place":
		await io.key(KEY_ESCAPE)
		return "%s still placing after the click (%s)" % [name, prob]
	io.note("BUILD %s%s at %s (cogs %d)" % [name, " BIG" if big else "", c, cogs()])
	return ""


## Right-click a building with the selection (Winders to a press: WORK).
func work(units: Array, b: Building) -> void:
	if units.is_empty():
		return
	await select(units[0])
	for u in units.slice(1):
		await select(u, true)
	var p := await look_at(where(b))
	if phone:
		await io.tap(p)
	else:
		await io.rclick(p)
	await io.frames(2)


func train(b: Building, label: String, n := 1) -> String:
	if not await select(b):
		return "could not select " + b.kind
	var why := ""
	for i in n:
		why = await press(label)
		if why != "":
			return why
	return ""
