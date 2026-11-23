class_name WWMap
extends Control
## THE WORLD WAR's map (docs/world_war_mode.md): the world on the war map's parchment (scripts/campaign/war_map.gd's
## look: the paper, a watercolour land, inked coasts), the regions striped in the colour of the side that holds them,
## capitals, key regions, buildings, sea lanes and the armies as round tokens with their strength. Drag to pan, the
## wheel / a pinch / + and - to zoom; a tap picks an army (its token) or a region.

signal region_tapped(rid: String)
signal army_tapped(aid: String)

const PARCHMENT := "res://campaign/warmap_art/parchment.jpg"
const SEA := Color(0.42, 0.55, 0.6, 0.28)
const LAND := Color(0.93, 0.86, 0.66, 0.75)
const INK := Color(0.22, 0.16, 0.1, 0.9)
const STRIPE := 0.7                 # stripe spacing in map units (degrees)

var war: WWWar
var selected_region := ""
var selected_army := ""
var targets: Array = []             # regions the selected army may go to (glowing)
var free_rect := Rect2()            # the part of the map not under the page's card (focus() centres there)
var center := Vector2.ZERO
var zoom := 1.0
var token_r := 13.0
var _land: Array = []               # [[points, tris, box]]
var _regions := {}                  # id -> {"parts": [{"pts", "tri", "closed"}], "stripes": [segments], "box", "at": map point}
var _ptex: Texture2D
var _drag := false
var _moved := 0.0
var _touches := {}
var _pinch0 := 0.0
var _zoom0 := 1.0
var _t := 0.0
var _fitted := false
var _y := 1.3


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	token_r = 13.0 if Settings.pc() else 17.0
	if ResourceLoader.exists(PARCHMENT):
		_ptex = load(PARCHMENT)
	_build()
	resized.connect(_fit)
	_fit.call_deferred()


func to_map(lon: float, lat: float) -> Vector2:
	return Vector2(lon, -lat * _y)


func pt(a: Array) -> Vector2:
	return to_map(float(a[0]), float(a[1]))


func world_rect() -> Rect2:
	var b: Array = [-170, -56, 165, 72]
	return Rect2(to_map(b[0], b[3]), Vector2.ZERO).expand(to_map(b[2], b[1]))


func _build() -> void:
	var f := FileAccess.open(WWRules.LAND, FileAccess.READ)
	var ld: Variant = JSON.parse_string(f.get_as_text()) if f else {}
	for flat in (ld.get("land", []) if ld is Dictionary else []):
		var pts := _ring(flat)
		var bx := Rect2(pts[0], Vector2.ZERO)
		for q in pts:
			bx = bx.expand(q)
		var closed := pts.duplicate()
		closed.append(pts[0])
		_land.append([pts, Geometry2D.triangulate_polygon(pts), bx, closed])
	for r in WWRules.region_list():
		var parts: Array = []
		var stripes: Array = []
		var bx := Rect2()
		var first := true
		for flat in r.get("shape", []):
			var pts := _ring(flat)
			var closed := pts.duplicate()
			closed.append(pts[0])
			parts.append({"pts": pts, "tri": Geometry2D.triangulate_polygon(pts), "closed": closed})
			for q in pts:
				if first:
					bx = Rect2(q, Vector2.ZERO)
					first = false
				bx = bx.expand(q)
		# diagonal stripes (one pattern for every region, so neighbours line up)
		for part in parts:
			var p0: Vector2 = bx.position
			var n := int((bx.size.x + bx.size.y) / STRIPE) + 2
			var k0 := int(floor((p0.x + p0.y) / STRIPE)) - 1
			for i in n:
				var c := (k0 + i) * STRIPE
				# the line x + y = c across the box
				var a := Vector2(c - (bx.end.y), bx.end.y)
				var b := Vector2(c - (bx.position.y - 1.0), bx.position.y - 1.0)
				for seg in Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([a, b]), part["pts"]):
					stripes.append(seg)
		_regions[String(r["id"])] = {"parts": parts, "stripes": stripes, "box": bx, "at": pt(r["at"])}


func _ring(flat: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(0, flat.size() - 1, 2):
		out.append(to_map(float(flat[i]), float(flat[i + 1])))
	return out


# ------------------------------------------------------------------ the camera

func to_screen(m: Vector2) -> Vector2:
	return (m - center) * zoom + size * 0.5


func to_mapp(s: Vector2) -> Vector2:
	return (s - size * 0.5) / zoom + center


func min_zoom() -> float:
	var w := world_rect()
	return minf(size.x / w.size.x, size.y / w.size.y) if size.x > 0 else 1.0


func max_zoom() -> float:
	return min_zoom() * 9.0


func _fit() -> void:
	if size.x <= 10:
		return
	if not _fitted:
		show_rect(world_rect())
	else:
		zoom = clampf(zoom, min_zoom(), max_zoom())
		_clamp()
	queue_redraw()


func show_rect(r: Rect2) -> void:
	zoom = clampf(minf(size.x / r.size.x, size.y / r.size.y), min_zoom(), max_zoom())
	center = r.get_center()
	_clamp()
	queue_redraw()


## Glide to a region (its town in the middle), zoomed in at least `z` times the whole world.
func focus(rid: String, z := 2.2) -> void:
	if not _regions.has(rid) or size.x <= 10:
		return
	_fitted = true
	var zz := maxf(zoom, min_zoom() * z)
	# (the town in the middle of the part of the map the card leaves free: free_rect, set by the page)
	var fr := free_rect if free_rect.size.x > 100 and free_rect.size.y > 100 else Rect2(Vector2.ZERO, size)
	var goal: Vector2 = (_regions[rid]["at"] as Vector2) - (fr.get_center() - size * 0.5) / zz
	var from := center
	var z0 := zoom
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_method(func(k: float) -> void:
		center = from.lerp(goal, k)
		zoom = lerpf(z0, zz, k)
		_clamp()
		queue_redraw(), 0.0, 1.0, 0.3)


func zoom_by(f: float, at := Vector2(-1, -1)) -> void:
	_fitted = true
	if at.x < 0:
		at = size * 0.5
	var before := to_mapp(at)
	zoom = clampf(zoom * f, min_zoom(), max_zoom())
	center += before - to_mapp(at)
	_clamp()
	queue_redraw()


func _clamp() -> void:
	var w := world_rect()
	var half := size * 0.5 / zoom
	for ax in 2:
		var lo: float = w.position[ax] + half[ax]
		var hi: float = w.end[ax] - half[ax]
		center[ax] = (w.position[ax] + w.end[ax]) * 0.5 if lo > hi else clampf(center[ax], lo, hi)


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.device != InputEvent.DEVICE_ID_EMULATION:
		var mb := e as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			zoom_by(1.2, mb.position)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			zoom_by(1.0 / 1.2, mb.position)
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_drag = true
				_moved = 0.0
			else:
				_drag = false
				if _moved < 12.0:
					tap(mb.position)
		accept_event()
	elif e is InputEventMouseMotion and e.device != InputEvent.DEVICE_ID_EMULATION and _drag:
		_pan((e as InputEventMouseMotion).relative)
		accept_event()
	elif e is InputEventScreenTouch:
		var t := e as InputEventScreenTouch
		if t.pressed:
			_touches[t.index] = t.position
			if _touches.size() == 1:
				_moved = 0.0
			elif _touches.size() == 2:
				_pinch0 = (_touches.values()[0] as Vector2).distance_to(_touches.values()[1])
				_zoom0 = zoom
				_moved = 99.0
		else:
			_touches.erase(t.index)
			if _touches.is_empty() and _moved < 14.0:
				tap(t.position)
		accept_event()
	elif e is InputEventScreenDrag:
		var dr := e as InputEventScreenDrag
		_touches[dr.index] = dr.position
		if _touches.size() >= 2 and _pinch0 > 1.0:
			var vs: Array = _touches.values()
			zoom_by(_zoom0 * (vs[0] as Vector2).distance_to(vs[1]) / _pinch0 / zoom, ((vs[0] as Vector2) + (vs[1] as Vector2)) * 0.5)
		else:
			_pan(dr.relative)
		accept_event()
	elif e is InputEventMagnifyGesture:
		zoom_by((e as InputEventMagnifyGesture).factor, (e as InputEventMagnifyGesture).position)
		accept_event()
	elif e is InputEventPanGesture:
		_pan(-(e as InputEventPanGesture).delta * 12.0)
		accept_event()


func _pan(rel: Vector2) -> void:
	_fitted = true
	_moved += rel.length()
	center -= rel / zoom
	_clamp()
	queue_redraw()


## A tap: an army's token first (the nearest within reach), else the region under the finger.
func tap(at: Vector2) -> void:
	var best := ""
	var bd := token_r * 1.6
	for a in war.d["armies"].values():
		var dd := army_screen(a).distance_to(at)
		if dd < bd:
			bd = dd
			best = String(a["id"])
	if best != "":
		army_tapped.emit(best)
		return
	region_tapped.emit(region_at(to_mapp(at)))


func region_at(m: Vector2) -> String:
	for rid in _regions:
		var rg: Dictionary = _regions[rid]
		if not (rg["box"] as Rect2).grow(0.5).has_point(m):
			continue
		for part in rg["parts"]:
			if Geometry2D.is_point_in_polygon(m, part["pts"]):
				return rid
	# (a tap on the sea near a port, or on a tiny region: the nearest town within reach)
	var best := ""
	var bd := 24.0 / zoom
	for rid in _regions:
		var dd: float = (_regions[rid]["at"] as Vector2).distance_to(m)
		if dd < bd:
			bd = dd
			best = rid
	return best


## Where an army's token stands on screen: beside its region's town (two armies in one region side by side).
func army_screen(a: Dictionary) -> Vector2:
	var rid := String(a["at"])
	if not _regions.has(rid):
		return Vector2(-999, -999)
	var here: Array = war.armies_at(rid)
	var i := here.find(a)
	var base := to_screen(_regions[rid]["at"])
	return base + Vector2(token_r * 1.0 + i * token_r * 2.2, token_r * 0.9)


func town_screen(rid: String) -> Vector2:
	return to_screen(_regions[rid]["at"]) if _regions.has(rid) else Vector2(-999, -999)


func _process(dt: float) -> void:
	_t += dt
	if is_visible_in_tree() and (not targets.is_empty() or selected_army != ""):
		queue_redraw()        # (the glow breathes)


# ------------------------------------------------------------------ drawing

func _draw() -> void:
	var font := UiStyle.body_font()
	var bold := UiStyle.bold_font()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.8, 0.74, 0.6))
	if _ptex:
		draw_texture_rect(_ptex, Rect2(Vector2.ZERO, size), false)
	draw_rect(Rect2(Vector2.ZERO, size), SEA)
	var xf := Transform2D(0.0, Vector2(zoom, zoom), 0.0, size * 0.5 - center * zoom)
	var vis := Rect2(to_mapp(Vector2.ZERO), size / zoom)
	draw_set_transform_matrix(xf)
	for it in _land:
		if (it[2] as Rect2).intersects(vis):
			_poly(it[0], it[1], LAND)
	# the regions: a wash and stripes in the holder's colour; free lands only their edge
	var px := 1.0 / zoom
	for rid in _regions:
		var rg: Dictionary = _regions[rid]
		if not (rg["box"] as Rect2).intersects(vis):
			continue
		var o := war.owner(rid)
		var col: Color = WWRules.COLOUR[o]
		if o != "":
			for part in rg["parts"]:
				_poly(part["pts"], part["tri"], Color(col, 0.22))
			var sc := Color(col, 0.55)
			for seg in rg["stripes"]:
				draw_line(seg[0], seg[1], sc, 2.2 * px)
		var edge := Color(col.darkened(0.35), 0.9) if o != "" else Color(INK, 0.35)
		for part in rg["parts"]:
			draw_polyline(part["closed"], edge, (1.6 if o != "" else 1.0) * px, true)
	# the coasts
	for it in _land:
		if (it[2] as Rect2).intersects(vis):
			draw_polyline(it[3], INK, 1.2 * px, true)
	# the chosen region and where the chosen army may go
	var pulse := 0.55 + 0.45 * sin(_t * 4.0)
	for rid in targets:
		if _regions.has(rid):
			for part in _regions[rid]["parts"]:
				_poly(part["pts"], part["tri"], Color(1.0, 0.92, 0.45, 0.25 + 0.2 * pulse))
				draw_polyline(part["closed"], Color(1.0, 0.85, 0.2, 0.95), 2.6 * px, true)
	if selected_region != "" and _regions.has(selected_region):
		for part in _regions[selected_region]["parts"]:
			draw_polyline(part["closed"], Color(1, 1, 1, 0.95), 3.0 * px, true)
	draw_set_transform_matrix(Transform2D.IDENTITY)
	# sea lanes: faint dotted ink (the chosen army's lanes bright)
	var drawn := {}
	for r in WWRules.region_list():
		var a := String(r["id"])
		for b in r.get("sea", []):
			var key := a + ":" + String(b) if a < String(b) else String(b) + ":" + a
			if drawn.has(key):
				continue
			drawn[key] = true
			var hot := (targets.has(String(b)) and _army_at(a)) or (targets.has(a) and _army_at(String(b)))
			_dotted(town_screen(a), town_screen(String(b)), Color(0.15, 0.25, 0.4, 0.75 if hot else 0.28), 2.0 if hot else 1.2)
	# towns, capitals, key regions, buildings, names
	var fs := 11 if Settings.pc() else 13
	var zoomed := zoom > min_zoom() * 1.7
	for rid in _regions:
		var p := town_screen(rid)
		if p.x < -40 or p.y < -40 or p.x > size.x + 40 or p.y > size.y + 40:
			continue
		var o := war.owner(rid)
		var is_cap := false
		for f in war.d["factions"]:
			if war.alive(f) and war.capital(f) == rid:
				is_cap = true
		if is_cap:
			_star(p, 8.5, Color(1, 0.84, 0.3), INK)
		elif WWRules.is_key(rid):
			_diamond(p, 5.5, Color(1, 0.9, 0.55), INK)
		else:
			draw_circle(p, 3.2, INK)
		var bid := String(war.d["regions"][rid]["build"])
		if bid != "":
			var bp := p + Vector2(-11, 9)
			draw_circle(bp, 7.0, Color(0.15, 0.12, 0.08, 0.85))
			draw_string(bold, bp + Vector2(-4, 4), String(Loc.t(String(WWRules.building_any(bid).get("name", "?")))).substr(0, 1),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 0.92, 0.7))
		if zoomed or is_cap or rid == selected_region or targets.has(rid):
			var nm := Loc.t(String(WWRules.region(rid).get("name", rid)))
			var w := font.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			var np := p + Vector2(-w * 0.5, -9)
			draw_string_outline(font, np, nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(0.98, 0.94, 0.82, 0.85))
			draw_string(font, np, nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, INK)
		if o == "" and zoomed:
			pass
	# the armies
	for a in war.d["armies"].values():
		_draw_army(a, bold)


func _army_at(rid: String) -> bool:
	var a := war.army(selected_army)
	return not a.is_empty() and String(a["at"]) == rid


func _poly(pts: PackedVector2Array, tri: PackedInt32Array, col: Color) -> void:
	if tri.is_empty():
		return
	var cols := PackedColorArray()
	cols.resize(tri.size())
	cols.fill(col)
	var vs := PackedVector2Array()
	vs.resize(tri.size())
	for i in tri.size():
		vs[i] = pts[tri[i]]
	RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), PackedInt32Array(), vs, cols)


func _dotted(a: Vector2, b: Vector2, col: Color, w: float) -> void:
	var n := int(a.distance_to(b) / 7.0)
	for i in n:
		if i % 2 == 0:
			draw_line(a.lerp(b, float(i) / n), a.lerp(b, float(i + 1) / n), col, w)


func _star(c: Vector2, r: float, fill: Color, line: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var ang := -PI / 2 + i * PI / 5
		pts.append(c + Vector2(cos(ang), sin(ang)) * (r if i % 2 == 0 else r * 0.45))
	draw_colored_polygon(pts, fill)
	pts.append(pts[0])
	draw_polyline(pts, line, 1.2, true)


func _diamond(c: Vector2, r: float, fill: Color, line: Color) -> void:
	var pts := PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)])
	draw_colored_polygon(pts, fill)
	pts.append(pts[0])
	draw_polyline(pts, line, 1.2, true)


## An army's token: a disc in its side's colour, its strength inside ("1.3k"), a gold ring while it may still march
## (the side whose turn it is), a white ring when chosen, a star with a hero, chevrons for its veteran rank.
func _draw_army(a: Dictionary, font: Font) -> void:
	var p := army_screen(a)
	if p.x < -40 or p.y < -40 or p.x > size.x + 40 or p.y > size.y + 40:
		return
	var f := String(a["f"])
	var col: Color = WWRules.COLOUR[f]
	var r := token_r
	draw_circle(p + Vector2(1.5, 2), r, Color(0, 0, 0, 0.35))
	draw_circle(p, r, col)
	var mine := f == war.current() and war.is_human(f) and not bool(a["moved"])
	if String(a["id"]) == selected_army:
		draw_arc(p, r + 3.0, 0, TAU, 32, Color(1, 1, 1, 0.95), 3.0, true)
	elif mine:
		draw_arc(p, r + 2.5, 0, TAU, 32, Color(1, 0.85, 0.25, 0.6 + 0.4 * sin(_t * 3.0)), 2.2, true)
	draw_arc(p, r, 0, TAU, 32, Color(0.08, 0.06, 0.05, 0.9), 1.4, true)
	var v := war.army_value(a)
	var txt := str(v) if v < 1000 else "%.1fk" % (v / 1000.0)
	var fs := 10 if Settings.pc() else 12
	var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(font, p + Vector2(-w * 0.5, fs * 0.36), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
	if not war.heroes_with(String(a["id"])).is_empty():
		_star(p + Vector2(r * 0.75, -r * 0.8), 5.0, Color(1, 0.85, 0.3), Color(0.1, 0.08, 0.05))
	for i in int(a.get("vet", 0)):
		var c := p + Vector2(-r * 0.6 + i * 5.0, r + 4.0)
		draw_polyline(PackedVector2Array([c + Vector2(-2.5, -1.5), c, c + Vector2(2.5, -1.5)]), Color(1, 0.85, 0.3), 1.6)
