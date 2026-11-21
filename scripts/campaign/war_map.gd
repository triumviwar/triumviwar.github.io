class_name WarMap
extends Control
## THE WAR MAP drawn (docs/war_map_v1.md): WarMapData's state in a SKIN. v1 has one skin, the King's PARCHMENT, drawn
## in code over Natural Earth's coasts (a stand-in for the owner's painting: a skin's "base" picture, when there is
## one, is drawn instead of the land and keeps the same projection). Pan with a drag, zoom with the wheel, a pinch or
## zoom_by(); a tap on a pin emits pin_tapped (a tap on nothing: pin_tapped("")).

signal pin_tapped(mid: String)

## A skin: how each thing looks. Later skins (the Clockmaker's brass map, the Naturalist's specimen chart) add theirs
## here with the same keys; "base" (a picture covering the data's bounds) replaces the drawn land when it is set.
const SKINS := {
	"parchment": {
		"base": "",
		"paper": Color(0.86, 0.79, 0.63), "paper_edge": Color(0.55, 0.40, 0.22, 0.55),
		"sea": Color(0.62, 0.70, 0.62, 0.55), "land": Color(0.86, 0.70, 0.44, 0.34), "sea_wash": Color(0.50, 0.64, 0.64, 0.26), "coast": Color(0.26, 0.17, 0.09, 0.95),
		"shore": Color(0.55, 0.62, 0.36, 0.22),
		"river": Color(0.22, 0.34, 0.48, 0.65), "grid": Color(0.40, 0.30, 0.18, 0.10), "ink": Color(0.22, 0.15, 0.09),
		"empire": Color(0.50, 0.30, 0.62, 0.10),
		"holders": {
			"crown": {"fill": Color(0.47, 0.22, 0.62, 0.38), "line": Color(0.36, 0.14, 0.48, 0.9)},
			"contested": {"fill": Color(0.47, 0.22, 0.62, 0.30), "line": Color(0.36, 0.14, 0.48, 0.9), "hatch": Color(0.72, 0.14, 0.10, 0.75)},
			"machine": {"fill": Color(0.74, 0.16, 0.10, 0.42), "line": Color(0.52, 0.08, 0.05, 0.9), "hatch": Color(0.45, 0.05, 0.03, 0.45)},
			"brood": {"fill": Color(0.25, 0.55, 0.20, 0.42), "line": Color(0.14, 0.36, 0.10, 0.9)},
			"unrest": {"fill": Color(0.20, 0.46, 0.22, 0.30), "line": Color(0.10, 0.10, 0.08, 0.9), "hatch": Color(0.08, 0.08, 0.06, 0.65)},
			"unknown": {"fill": Color(0.92, 0.87, 0.74, 1.0), "line": Color(0.30, 0.22, 0.14, 0.7), "dashed": true},
		},
		"lines": {"crown": Color(0.42, 0.16, 0.55), "clockmaker": Color(0.62, 0.40, 0.10), "naturalist": Color(0.22, 0.42, 0.18),
			"all": Color(0.70, 0.52, 0.12)},
		"locked": Color(0.52, 0.47, 0.42),
	},
}

## The coast's ink rings out to sea, in map units (degrees), and the mountain ranges' file.
const RIPPLES := [0.3, 0.65, 1.05]
const MOUNTAINS := "res://campaign/warmap_mountains.json"
const PARCHMENT := "res://campaign/warmap_art/parchment.jpg"

var skin := "parchment"
var selected := ""
var st := {}                       # WarMapData.state()
var center := Vector2.ZERO         # the map point at the middle of the control
var zoom := 1.0                    # pixels per map unit
var seal_r := 13.0                 # a pin's radius on screen (phones: bigger)

var _land: Array = []              # [[points, triangle indices]] in map units
var _ripples: Array = []           # the engraved coast lines out to sea: [[closed polyline, ring 0..2]] in map units
var _hills: Array = []             # the mountain ranges (campaign/warmap_mountains.json): dense points along each, map units
var _lakes: Array = []
var _rivers: Array = []
var _regions: Array = []           # [{id, pts, hatch: [segments], box: Rect2}]
var _drag := false
var _press := Vector2.ZERO
var _moved := 0.0
var _touches := {}
var _pinch0 := 0.0
var _zoom0 := 1.0
var _t := 0.0
var _fitted := false
var _view_rect := Rect2()
var pending_cam := {}              # {"c": center, "z": zoom, "v": painted} to put back once sized (the page came back)
## THE CATHOLIC PAINTINGS (owner 2026-11-21 21:52: "why isn't it showing the Catholic map?"): each view (THE WORLD,
## VIRGINIA, EUROPE, THE AMAZON) shows its painted sheet (data "paintings": campaign/warmap_art/painted_<view>.jpg);
## the camera then works in the sheet's pixels and the places are put on it by WarMapData.painted_px. A view without
## its painting (or a missing file) shows the drawn map as before.
var painted := ""
var _ptex: Texture2D


static func make(skin_id := "parchment") -> WarMap:
	var w := WarMap.new()
	w.skin = skin_id if SKINS.has(skin_id) else "parchment"
	return w


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	seal_r = 13.0 if Settings.pc() else 18.0
	var vs: Array = WarMapData.data().get("views", [])
	var start := String(pending_cam.get("v", String(vs[0]["id"]) if not vs.is_empty() else ""))
	if _paint_ok(start):
		_set_painted(start)
	_build()
	refresh()
	resized.connect(_fit_once)
	_fit_once.call_deferred()


## Sized (or resized): until the player moves the map it shows the view asked for (or where it was left: pending_cam);
## after that it keeps its place.
func _fit_once() -> void:
	if size.x <= 10:
		return
	if _fitted:
		zoom = clampf(zoom, min_zoom(), max_zoom())
		_clamp()
	else:
		if pending_cam.has("z"):
			center = pending_cam["c"]
			zoom = clampf(float(pending_cam["z"]), min_zoom(), max_zoom())
			_clamp()
		else:
			show_rect(_view_rect if _view_rect.has_area() else home_rect(), false)
	queue_redraw()


func sk() -> Dictionary:
	return SKINS[skin]


func _paint_ok(id: String) -> bool:
	var pt: Dictionary = WarMapData.data().get("paintings", {}).get(id, {})
	return not pt.is_empty() and ResourceLoader.exists(String(pt.get("file", "")))


func _set_painted(id: String) -> void:
	painted = id
	_ptex = load(String(WarMapData.data()["paintings"][id]["file"])) if id != "" else null


## A place (lon/lat) where the map draws it: on the painted sheet (its pixels) or the drawn map (map units).
func geo(a: Array, key := "") -> Vector2:
	if painted == "":
		return WarMapData.pt(a)
	return WarMapData.painted_px(WarMapData.data()["paintings"][painted], float(a[0]), float(a[1]), key)


## Is a pin or mark on the sheet shown now? The world sheet shows all; a region's sheet those placed on it by hand and
## those inside its view (a degree to spare).
func shows(a: Array, key := "") -> bool:
	if painted == "" or painted == "world":
		return true
	if (WarMapData.data()["paintings"][painted].get("at", {}) as Dictionary).has(key):
		return true
	for v in WarMapData.data().get("views", []):
		if String(v["id"]) == painted:
			var r: Array = v["rect"]
			return float(a[0]) >= float(r[0]) - 1.0 and float(a[0]) <= float(r[2]) + 1.0 and float(a[1]) >= float(r[1]) - 1.0 and float(a[1]) <= float(r[3]) + 1.0
	return true


## The map's whole area (the land is cut to it; the camera never shows past it).
func world_rect() -> Rect2:
	if painted != "" and _ptex:
		return Rect2(Vector2.ZERO, _ptex.get_size())
	return WarMapData.rect_of(WarMapData.data().get("bounds", [-180, -60, 180, 80]))


## The first view (THE WORLD: the act's lands): where the map opens.
func home_rect() -> Rect2:
	if painted != "":
		return world_rect()
	var vs: Array = WarMapData.data().get("views", [])
	return WarMapData.rect_of(vs[0]["rect"]) if not vs.is_empty() else world_rect()


## The progress changed (or a test set its own): read the state again.
func refresh(p: Dictionary = {}) -> void:
	st = WarMapData.state(p)
	queue_redraw()


func _build() -> void:
	var ld := WarMapData.land()
	for key in ["land", "lakes"]:
		var arr: Array = []
		for flat in ld.get(key, []):
			var pts := WarMapData.ring(flat)
			var lb := Rect2(pts[0], Vector2.ZERO)
			for q in pts:
				lb = lb.expand(q)
			arr.append([pts, Geometry2D.triangulate_polygon(pts), lb])
		if key == "land":
			_land = arr
		else:
			_lakes = arr
	for flat in ld.get("rivers", []):
		_rivers.append(WarMapData.ring(flat))
	# THE OLD MAP'S COASTS (owner 2026-11-20: a 17th-18th century map): rings of fine ink lines out to sea, as the
	# engravers drew them; made once, in map units (so they open out as the map zooms in)
	for it in _land:
		var lb: Rect2 = it[2]
		if maxf(lb.size.x, lb.size.y) < 1.2:
			continue
		for ri in RIPPLES.size():
			for poly in Geometry2D.offset_polygon(it[0], RIPPLES[ri], Geometry2D.JOIN_ROUND):
				var cl: PackedVector2Array = (poly as PackedVector2Array).duplicate()
				if Geometry2D.is_polygon_clockwise(cl) != Geometry2D.is_polygon_clockwise(it[0]):
					continue            # (a hole the offset made inside a bay: not a coast line)
				cl.append(cl[0])
				_ripples.append([cl, ri])
	if FileAccess.file_exists(MOUNTAINS):
		var mj = JSON.parse_string(FileAccess.get_file_as_string(MOUNTAINS))
		for rg in (mj.get("ranges", []) if mj is Dictionary else []):
			var pts := PackedVector2Array()
			var line: Array = rg["line"]
			for i in line.size() - 1:
				var a := WarMapData.pt(line[i])
				var b := WarMapData.pt(line[i + 1])
				var n := maxi(1, int(a.distance_to(b) / 0.35))
				for k in n:
					pts.append(a.lerp(b, float(k) / n))
			pts.append(WarMapData.pt(line[line.size() - 1]))
			_hills.append(pts)
	for rg in WarMapData.data().get("regions", []):
		var pts := WarMapData.region_outline(rg)
		var bx := Rect2(pts[0], Vector2.ZERO)
		for q in pts:
			bx = bx.expand(q)
		# the wash is painted on the land only: the outline cut by the coasts (as drawn; a painted base keeps the outline)
		var parts: Array = []
		if String(sk().get("base", "")) == "":
			for it in _land:
				var lp: PackedVector2Array = it[0]
				if not it[2].intersects(bx):
					continue
				for cut in Geometry2D.intersect_polygons(pts, lp):
					if cut.size() >= 3:
						parts.append(cut)
		if parts.is_empty():
			parts = [pts]
		var out_parts: Array = []
		var hatch: Array = []
		var step := maxf(bx.size.x, bx.size.y) / 13.0
		var n := int((bx.size.x + bx.size.y) / step) + 2
		for part in parts:
			var closed: PackedVector2Array = (part as PackedVector2Array).duplicate()
			closed.append(closed[0])
			out_parts.append({"pts": part, "tri": Geometry2D.triangulate_polygon(part), "closed": closed})
			# hatching (unrest, uneasy, the machine's): diagonal strokes cut to the outline, spaced by the region's size
			for i in n:
				var a := bx.position + Vector2(i * step - bx.size.y, 0)
				var line := PackedVector2Array([a, a + Vector2(bx.size.y + step, bx.size.y + step)])
				for seg in Geometry2D.intersect_polyline_with_polygon(line, part):
					hatch.append(seg)
		var lab: Array = rg.get("label_at", [])
		_regions.append({"id": String(rg["id"]), "parts": out_parts, "hatch": hatch,
			"box": bx, "name": String(rg.get("name", "")), "label": bool(rg.get("label", true)),
			"label_at": WarMapData.pt(lab) if lab.size() == 2 else bx.get_center()})


# ------------------------------------------------------------------ the camera

func to_screen(m: Vector2) -> Vector2:
	return (m - center) * zoom + size * 0.5


func to_mapp(s: Vector2) -> Vector2:
	return (s - size * 0.5) / zoom + center


func min_zoom() -> float:
	var w := world_rect()
	if painted != "" and size.x > 0:
		return minf(size.x / w.size.x, size.y / w.size.y)       # (the whole sheet, its saints and frame, in view)
	return maxf(size.x / w.size.x, size.y / w.size.y) if size.x > 0 else 1.0


func max_zoom() -> float:
	return min_zoom() * (4.0 if painted != "" else 60.0)


## Show a map rectangle (a view's), with a short glide when `glide`.
func show_rect(r: Rect2, glide := true) -> void:
	_view_rect = r
	if size.x <= 10:
		return
	var z := clampf(minf(size.x / r.size.x, size.y / r.size.y) * (1.0 if painted != "" else 0.92), min_zoom(), max_zoom())
	var c := r.get_center()
	if glide and is_inside_tree():
		var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_method(func(k: float) -> void:
			center = center.lerp(c, k)
			zoom = lerpf(zoom, z, k)
			_clamp()
			queue_redraw(), 0.0, 1.0, 0.35)
	else:
		center = c
		zoom = z
		_clamp()
		queue_redraw()


func show_view(id: String, glide := true) -> void:
	if _paint_ok(id) or painted != "":
		# a painted sheet for each view: the sheet changes (a quick fade), whole in view
		_set_painted(id if _paint_ok(id) else "")
		_fitted = false
		modulate.a = 0.35
		if is_inside_tree():
			create_tween().tween_property(self, "modulate:a", 1.0, 0.25)
		if painted != "":
			show_rect(world_rect(), false)
			return
		glide = false
	for v in WarMapData.data().get("views", []):
		if String(v["id"]) == id:
			show_rect(WarMapData.rect_of(v["rect"]), glide)


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
		if lo > hi and painted != "":
			center[ax] = clampf(center[ax], hi, lo)        # (a sheet smaller than the view slides inside it: room for the card)
		else:
			center[ax] = (w.position[ax] + w.end[ax]) * 0.5 if lo > hi else clampf(center[ax], lo, hi)


# ------------------------------------------------------------------ input

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
				_press = mb.position
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
				_press = t.position
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
			var mid: Vector2 = ((vs[0] as Vector2) + (vs[1] as Vector2)) * 0.5
			zoom_by(_zoom0 * (vs[0] as Vector2).distance_to(vs[1]) / _pinch0 / zoom, mid)
		else:
			_pan(dr.relative)
		accept_event()
	elif e is InputEventMagnifyGesture:
		var mg := e as InputEventMagnifyGesture
		zoom_by(mg.factor, mg.position)
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


## A tap at a screen point: the nearest pin within reach is picked (pin_tapped), else none.
func tap(at: Vector2) -> void:
	var best := ""
	var bd := seal_r * 1.7
	for pn in WarMapData.data().get("pins", []):
		if not shows(pn["point"], String(pn["mission"])):
			continue
		var dd := pin_screen(pn).distance_to(at)
		if dd < bd:
			bd = dd
			best = String(pn["mission"])
	selected = best
	queue_redraw()
	pin_tapped.emit(best)


## The pin's card covers part of the map (the page sets `free_rect`, the part still seen): glide so the pin stands in it.
var free_rect := Rect2()


func bring_into_view(mid: String) -> void:
	var pn := WarMapData.pin_of(mid)
	if pn.is_empty() or size.x <= 10:
		return
	var fr := free_rect if free_rect.size.x > 120 and free_rect.size.y > 120 else Rect2(Vector2.ZERO, size)
	var c := pin_screen(pn)
	if fr.grow(-seal_r * 3.0).abs().has_point(c):
		return
	var want := fr.get_center()
	var goal := center + (c - want) / zoom
	_fitted = true
	var from := center
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_method(func(k: float) -> void:
		center = from.lerp(goal, k)
		_clamp()
		queue_redraw(), 0.0, 1.0, 0.3)


## Where a pin's seal stands on screen: its point, moved by its "nudge" (pixels: pins on the same town side by side).
func pin_screen(pn: Dictionary) -> Vector2:
	var nd: Array = pn.get("nudge", [0, 0])
	var k := seal_r / 13.0
	return to_screen(geo(pn["point"], String(pn["mission"]))) + Vector2(float(nd[0]), float(nd[1])) * k


func _process(dt: float) -> void:
	_t += dt
	if is_visible_in_tree():
		queue_redraw()        # (the open pins' halo breathes)


# ------------------------------------------------------------------ drawing

func _draw() -> void:
	var s: Dictionary = sk()
	var font := UiStyle.body_font()
	var tfont := UiStyle.title_font()
	if painted != "" and _ptex:
		_draw_painted(s, font)
		return
	draw_rect(Rect2(Vector2.ZERO, size), s["paper"])
	var paper := _art_file(PARCHMENT)
	if paper:
		# the sheet itself (screen space: the paper does not zoom, the map on it does), covering the frame
		var k := maxf(size.x / paper.get_width(), size.y / paper.get_height())
		var ps := Vector2(paper.get_width(), paper.get_height()) * k
		draw_texture_rect(paper, Rect2((size - ps) * 0.5, ps), false)
		draw_rect(Rect2(Vector2.ZERO, size), s["sea_wash"])      # the sea a little cooler than the land
	else:
		draw_rect(Rect2(Vector2.ZERO, size), s["sea"])
	# the land, in map units under one transform; the lines' widths are in pixels (divided by the zoom)
	draw_set_transform(size * 0.5 - center * zoom, 0.0, Vector2(zoom, zoom))
	var px := 1.0 / zoom
	var base_tex: Texture2D = null
	if String(s.get("base", "")) != "" and ResourceLoader.exists(String(s["base"])):
		base_tex = load(String(s["base"]))
	if base_tex:
		draw_texture_rect(base_tex, world_rect(), false)
	else:
		var bd: Array = WarMapData.data().get("bounds", [-180, -60, 180, 80])
		for lon in range(int(ceil(float(bd[0]) / 10.0)) * 10, int(bd[2]) + 1, 10):      # (the graticule: every 10 degrees)
			draw_line(WarMapData.to_map(lon, float(bd[1])), WarMapData.to_map(lon, float(bd[3])), s["grid"], px)
		for lat in range(int(ceil(float(bd[1]) / 10.0)) * 10, int(bd[3]) + 1, 10):
			draw_line(WarMapData.to_map(float(bd[0]), lat), WarMapData.to_map(float(bd[2]), lat), s["grid"], (2.0 if lat == 0 else 1.0) * px)
		# the engraved coast lines out to sea, the nearest darkest
		var vis := Rect2(center - size * 0.5 / zoom, size / zoom).grow(2.0)
		for rp in _ripples:
			var pl: PackedVector2Array = rp[0]
			var ink: Color = s["ink"]
			ink.a = [0.42, 0.28, 0.16][rp[1]]
			draw_polyline(pl, ink, 0.8 * px, true)
		# the land: a watercolour wash on the paper, a deeper band along the shore
		for it in _land:
			if not (it[1] as PackedInt32Array).is_empty():
				RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), it[1], it[0], PackedColorArray([s["land"]]))
				RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), it[1], it[0], PackedColorArray([s["empire"]]))
		for it in _land:
			if not (it[2] as Rect2).intersects(vis):
				continue
			var c: PackedVector2Array = (it[0] as PackedVector2Array).duplicate()
			c.append(c[0])
			draw_polyline(c, s["shore"], 5.0 * px, true)
		for it in _lakes:
			if not (it[1] as PackedInt32Array).is_empty():
				RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), it[1], it[0], PackedColorArray([s["sea"]]))
		for r in _rivers:
			draw_polyline(r, s["river"], 1.2 * px, true)
		_draw_hills(s, px, vis)
		_draw_ornaments()
	# the regions: washes, hatching, outlines
	var regs: Dictionary = st.get("regions", {})
	for rg in _regions:
		var h := String(regs.get(rg["id"], "empire"))
		if h == "empire" or not (s["holders"] as Dictionary).has(h):
			continue
		var hs: Dictionary = s["holders"][h]
		for part in rg["parts"]:
			if not (part["tri"] as PackedInt32Array).is_empty():
				RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), part["tri"], part["pts"], PackedColorArray([hs["fill"]]))
		if hs.has("hatch"):
			for sg in rg["hatch"]:
				draw_line(sg[0], sg[sg.size() - 1], hs["hatch"], 1.3 * px, true)
		for part in rg["parts"]:
			var closed: PackedVector2Array = part["closed"]
			if bool(hs.get("dashed", false)):
				for i in closed.size() - 1:
					draw_dashed_line(closed[i], closed[i + 1], hs["line"], 1.4 * px, 5.0 * px)
			else:
				draw_polyline(closed, hs["line"], 1.6 * px, true)
	if not base_tex:
		for it in _land:
			var c: PackedVector2Array = (it[0] as PackedVector2Array).duplicate()
			c.append(c[0])
			draw_polyline(c, s["coast"], 1.4 * px, true)
	draw_set_transform(Vector2.ZERO)
	_draw_cartouche_text(s)
	# region names (where there is room)
	for rg in _regions:
		if not bool(rg["label"]):
			continue
		var h := String(regs.get(rg["id"], "empire"))
		var bw: float = (rg["box"] as Rect2).size.x * zoom
		if bw < 34.0:
			continue
		var fs := int(clampf(bw * 0.09, 11, 18))
		var txt := Loc.t(String(rg["name"])).to_upper()
		var at := to_screen(rg["label_at"])
		var tw := tfont.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var col: Color = s["ink"]
		col.a = 0.55 if h == "empire" else 0.85
		draw_string(tfont, at - Vector2(tw * 0.5, -fs * 0.35), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
	# marks
	var mks: Dictionary = st.get("marks", {})
	for mk in WarMapData.data().get("marks", []):
		if bool(mks.get(String(mk["id"]), false)):
			_draw_mark(mk, font)
	# pins, then their labels where they fit
	var placed: Array = []
	var order: Array = (WarMapData.data().get("pins", []) as Array).duplicate()
	order.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return String(a["mission"]) == selected and String(b["mission"]) != selected)
	for pn in WarMapData.data().get("pins", []):
		_draw_pin(pn)
	var seals := {}
	for pn in order:
		var c := pin_screen(pn)
		seals[String(pn["mission"])] = Rect2(c - Vector2(seal_r, seal_r), Vector2(seal_r, seal_r) * 2)
		placed.append(seals[String(pn["mission"])])
	for pn in order:
		var c := pin_screen(pn)
		var fs := 15 if Settings.pc() else 18
		var t1 := Loc.t(String(pn["place"]))
		var t2 := Loc.t(String(pn["date"]))
		var w := maxf(font.get_string_size(t1, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x, font.get_string_size(t2, HORIZONTAL_ALIGNMENT_LEFT, -1, fs - 2).x)
		var r := Rect2(c + Vector2(-w * 0.5, seal_r + 2), Vector2(w, fs * 2.1))
		var free := true
		for q in placed:
			if (q as Rect2).intersects(r) and q != seals[String(pn["mission"])]:
				free = false
				break
		if String(pn["mission"]) != selected and not free:
			continue
		placed.append(r)
		draw_rect(r.grow(3), Color(s["paper"], 0.75))
		draw_string(font, r.position + Vector2(0, fs * 0.9), t1, HORIZONTAL_ALIGNMENT_CENTER, w, fs, s["ink"])
		draw_string(font, r.position + Vector2(0, fs * 1.9), t2, HORIZONTAL_ALIGNMENT_CENTER, w, fs - 2, Color(s["ink"], 0.75))
	# the frame: a dark edge like an old sheet's, and the compass rose
	for i in 6:
		draw_rect(Rect2(Vector2(i, i) * 3.0, size - Vector2(i, i) * 6.0), Color(s["paper_edge"], 0.22 - i * 0.03), false, 3.0)
	_draw_rose(Vector2(size.x - 60, size.y - 64), 38.0, s)


## The painted sheet: the painting, its marks and seals, their names, and the act's title in its cartouche.
func _draw_painted(s: Dictionary, font: Font) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.09, 0.07, 0.05))
	var r := Rect2(to_screen(Vector2.ZERO), _ptex.get_size() * zoom)
	draw_texture_rect(_ptex, r, false)
	var mks: Dictionary = st.get("marks", {})
	for mk in WarMapData.data().get("marks", []):
		if bool(mks.get(String(mk["id"]), false)) and shows(mk["point"], String(mk["id"])):
			_draw_mark(mk, font)
	var pins: Array = []
	for pn in WarMapData.data().get("pins", []):
		if shows(pn["point"], String(pn["mission"])):
			pins.append(pn)
			_draw_pin(pn)
	var order := pins.duplicate()
	order.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return String(a["mission"]) == selected and String(b["mission"]) != selected)
	var placed: Array = []
	var seals := {}
	for pn in order:
		var c := pin_screen(pn)
		seals[String(pn["mission"])] = Rect2(c - Vector2(seal_r, seal_r), Vector2(seal_r, seal_r) * 2)
		placed.append(seals[String(pn["mission"])])
	for pn in order:
		var c := pin_screen(pn)
		var fs := 15 if Settings.pc() else 18
		var t1 := Loc.t(String(pn["place"]))
		var t2 := Loc.t(String(pn["date"]))
		var w := maxf(font.get_string_size(t1, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x, font.get_string_size(t2, HORIZONTAL_ALIGNMENT_LEFT, -1, fs - 2).x)
		var lr := Rect2(c + Vector2(-w * 0.5, seal_r + 2), Vector2(w, fs * 2.1))
		var free := true
		for q in placed:
			if (q as Rect2).intersects(lr) and q != seals[String(pn["mission"])]:
				free = false
				break
		if String(pn["mission"]) != selected and not free:
			continue
		placed.append(lr)
		draw_rect(lr.grow(3), Color(s["paper"], 0.8))
		draw_string(font, lr.position + Vector2(0, fs * 0.9), t1, HORIZONTAL_ALIGNMENT_CENTER, w, fs, s["ink"])
		draw_string(font, lr.position + Vector2(0, fs * 1.9), t2, HORIZONTAL_ALIGNMENT_CENTER, w, fs - 2, Color(s["ink"], 0.75))
	# the act's title in the sheet's crowned cartouche
	var cart: Array = WarMapData.data()["paintings"][painted].get("cart", [])
	if cart.size() == 3:
		_cartouche_words(s, to_screen(Vector2(float(cart[0]), float(cart[1]))), float(cart[2]) * zoom * 1.25)


func _draw_mark(mk: Dictionary, font: Font) -> void:
	var s: Dictionary = sk()
	var c := to_screen(geo(mk["point"], String(mk.get("id", ""))))
	var ink: Color = s["ink"]
	match String(mk.get("kind", "dot")):
		"dot":
			draw_circle(c, 4.5, s["lines"]["crown"])
			draw_arc(c, 5.0, 0, TAU, 16, ink, 1.2, true)
		"village", "town":
			var r := 4.0 if String(mk["kind"]) == "village" else 6.0
			draw_rect(Rect2(c - Vector2(r, r * 0.6), Vector2(r * 2, r * 1.4)), Color(0.55, 0.36, 0.2))
			draw_colored_polygon(PackedVector2Array([c + Vector2(-r - 1, -r * 0.6), c + Vector2(0, -r * 1.6), c + Vector2(r + 1, -r * 0.6)]), Color(0.4, 0.22, 0.12))
		"burnt":
			for i in 5:
				var a := TAU * i / 5.0 + 0.3
				draw_line(c, c + Vector2(cos(a), sin(a)) * 8.0, Color(0.15, 0.08, 0.04, 0.8), 2.0, true)
			draw_circle(c, 4.0, Color(0.75, 0.25, 0.05))
		"question":
			var fq := UiStyle.title_font()
			var fs := 26 if Settings.pc() else 32
			draw_string(fq, c + Vector2(-fs * 0.3, fs * 0.35), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(ink, 0.8))
		"ship":
			draw_colored_polygon(PackedVector2Array([c + Vector2(-9, 0), c + Vector2(9, 0), c + Vector2(6, 5), c + Vector2(-6, 5)]), Color(0.35, 0.22, 0.12))
			draw_line(c, c + Vector2(0, -12), ink, 1.5)
			draw_colored_polygon(PackedVector2Array([c + Vector2(1, -11), c + Vector2(8, -3), c + Vector2(1, -3)]), Color(0.95, 0.92, 0.85))
	var lab := Loc.t(String(mk.get("label", "")))
	if lab != "" and zoom > min_zoom() * 2.2:
		var fs := 13 if Settings.pc() else 16
		draw_string(font, c + Vector2(9, -6), lab, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(ink, 0.9))


## A wax seal: the line's colour when open or done, grey when locked, a dashed ring when only planned; a crack across a
## broken one (a place lost); the line's sign pressed in it.
func _draw_pin(pn: Dictionary) -> void:
	var s: Dictionary = sk()
	var mid := String(pn["mission"])
	var ps: Dictionary = st.get("pins", {}).get(mid, {"state": "planned", "seal": ""})
	var state := String(ps["state"])
	var c := pin_screen(pn)
	var truep := to_screen(geo(pn["point"], mid))
	var r := seal_r
	var ink: Color = s["ink"]
	if c.distance_to(truep) > 2.0:
		draw_line(truep, c, Color(ink, 0.6), 1.2, true)
		draw_circle(truep, 2.5, Color(ink, 0.8))
	if mid == selected:
		draw_circle(c, r + 7, Color(1, 0.85, 0.35, 0.55))
	if state == "open":
		var k := 0.5 + 0.5 * sin(_t * 3.0)
		draw_arc(c, r + 3 + k * 4, 0, TAU, 32, Color(0.95, 0.75, 0.25, 0.9 - k * 0.5), 2.5, true)
	if state == "planned":
		draw_circle(c, r * 0.8, Color(s["paper"], 0.8))
		var n := 14
		for i in n:
			if i % 2 == 0:
				draw_arc(c, r * 0.8, TAU * i / n, TAU * (i + 1) / n, 4, Color(ink, 0.55), 1.6, true)
		_draw_sign(String(pn["line"]), c, r * 0.45, Color(ink, 0.45))
		return
	var col: Color = s["locked"] if state == "locked" else s["lines"].get(String(pn["line"]), s["locked"])
	var broken := String(ps.get("seal", "")) == "broken"
	var tex := _art("seal_%s%s" % [String(pn["line"]), "_broken" if broken else ""])
	if tex:
		# the painted seal (campaign/warmap_art, tools/campaign/import_warmap_art.py); greyed when locked
		var mod := Color(0.62, 0.58, 0.55) if state == "locked" else Color.WHITE
		draw_texture_rect(tex, Rect2(c - Vector2(r, r) * 1.15, Vector2(r, r) * 2.3), false, mod)
		if state == "done" and not broken:
			draw_arc(c, r + 2.5, 0, TAU, 28, Color(0.95, 0.8, 0.35, 0.9), 1.5, true)
		if state == "locked":
			draw_rect(Rect2(c + Vector2(r * 0.35, r * 0.25), Vector2(r * 0.6, r * 0.5)), Color(0.2, 0.18, 0.15))
			draw_arc(c + Vector2(r * 0.65, r * 0.25), r * 0.2, PI, TAU, 8, Color(0.2, 0.18, 0.15), 1.6)
		return
	# the wax: a blob with a soft scalloped edge
	var blob := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		blob.append(c + Vector2(cos(a), sin(a)) * r * (1.0 + 0.07 * sin(a * 5.0 + float(mid.hash() % 7))))
	draw_colored_polygon(blob, col.darkened(0.15))
	draw_circle(c, r * 0.78, col)
	draw_arc(c, r * 0.78, 0, TAU, 24, col.darkened(0.35), 1.4, true)
	draw_arc(c + Vector2(-1, -1), r * 0.9, PI * 1.05, PI * 1.6, 8, Color(1, 1, 1, 0.25), 1.6, true)
	_draw_sign(String(pn["line"]), c, r * 0.5, col.darkened(0.45))
	if String(ps.get("seal", "")) == "broken":
		draw_polyline(PackedVector2Array([c + Vector2(-r, -r * 0.3), c + Vector2(-r * 0.2, 0.1 * r), c + Vector2(0.1 * r, -0.2 * r), c + Vector2(r, r * 0.4)]), Color(0.1, 0.05, 0.02, 0.9), 2.2, true)
	elif state == "done":
		draw_arc(c, r + 1.5, 0, TAU, 28, Color(0.95, 0.8, 0.35, 0.9), 1.5, true)
	if state == "locked":
		draw_rect(Rect2(c + Vector2(r * 0.35, r * 0.25), Vector2(r * 0.6, r * 0.5)), Color(0.2, 0.18, 0.15))
		draw_arc(c + Vector2(r * 0.65, r * 0.25), r * 0.2, PI, TAU, 8, Color(0.2, 0.18, 0.15), 1.6)


## The line's sign: a crown (the Crown), a gear (the Clockmaker), a reptile's eye (the Naturalist), a star (all three).
func _draw_sign(line: String, c: Vector2, r: float, col: Color) -> void:
	match line:
		"crown":
			draw_colored_polygon(PackedVector2Array([c + Vector2(-r, r * 0.6), c + Vector2(-r, -r * 0.4), c + Vector2(-r * 0.5, r * 0.05),
				c + Vector2(0, -r * 0.7), c + Vector2(r * 0.5, r * 0.05), c + Vector2(r, -r * 0.4), c + Vector2(r, r * 0.6)]), col)
		"clockmaker":
			var g := PackedVector2Array()
			for i in 16:
				var a := TAU * i / 16.0
				g.append(c + Vector2(cos(a), sin(a)) * r * (1.0 if i % 2 == 0 else 0.72))
			draw_colored_polygon(g, col)
			draw_circle(c, r * 0.3, col.lightened(0.5))
		"naturalist":
			# a reptile's eye (the game's emblem): an almond with a slit pupil
			var eye := PackedVector2Array()
			for i in 16:
				var a := TAU * i / 16.0
				eye.append(c + Vector2(cos(a) * r, sin(a) * r * 0.55))
			draw_colored_polygon(eye, col)
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r * 0.5), c + Vector2(r * 0.14, 0), c + Vector2(0, r * 0.5),
				c + Vector2(-r * 0.14, 0)]), col.lightened(0.5))
		_:
			var stp := PackedVector2Array()
			for i in 10:
				var a := TAU * i / 10.0 - PI / 2
				stp.append(c + Vector2(cos(a), sin(a)) * r * (1.0 if i % 2 == 0 else 0.45))
			draw_colored_polygon(stp, col)


## The mountains as an old map draws them: little inked hills along each range, the light from the left (the right
## flank hatched). Their size is held between 11 and 20 px on screen; along a range they are spaced by that size.
func _draw_hills(s: Dictionary, px: float, vis: Rect2) -> void:
	var hs := clampf(2.0 * zoom, 28.0, 44.0)         # a mountain's width on screen
	var step := maxi(1, int(ceil(hs * 0.7 / (0.35 * zoom))))
	var ink: Color = s["ink"]
	var painted := _art("mountain_0") != null
	for pts in _hills:
		for i in range(0, (pts as PackedVector2Array).size(), step):
			var p: Vector2 = pts[i]
			if not vis.has_point(p):
				continue
			var w := hs * px * (0.85 + 0.3 * absf(sin(float(i) * 1.7)))
			if painted:
				# ChatGPT's inked peaks (campaign/warmap_art/mountain_0..7), one picked by the place on the range
				var tex := _art("mountain_%d" % (int(absf(p.x * 7.0 + p.y * 3.0)) % 8))
				var h := w * tex.get_height() / tex.get_width()
				draw_texture_rect(tex, Rect2(p - Vector2(w * 0.5, h * 0.8), Vector2(w, h)), false)
				continue
			var h2 := w * (0.75 + 0.35 * absf(cos(float(i) * 2.3)))
			var l := p + Vector2(-w * 0.5, 0)
			var r := p + Vector2(w * 0.5, 0)
			var top := p + Vector2(w * 0.06, -h2)
			draw_colored_polygon(PackedVector2Array([l, top, r]), Color(s["paper"], 0.85))
			for k in 3:                                    # the shaded flank
				var f := 0.3 + 0.22 * k
				draw_line(top.lerp(r, f), top.lerp(r, f) + Vector2(-w * 0.12, h2 * 0.22), Color(ink, 0.55), 0.8 * px, true)
			draw_polyline(PackedVector2Array([l, l.lerp(top, 0.5) + Vector2(-w * 0.04, 0), top, r]), Color(ink, 0.85), 1.1 * px, true)


## The old map's ornaments in the empty seas (ChatGPT's, campaign/warmap_art): [picture, lon, lat, width in degrees].
const ORNAMENTS := [["ship_big", -40.0, 31.0, 18.0], ["ship_small", -18.0, -8.0, 12.0], ["serpent", -122.0, -2.0, 22.0],
	["cartouche", -138.0, 33.0, 34.0]]


func _draw_ornaments() -> void:
	for o in ORNAMENTS:
		var tex := _art(String(o[0]))
		if tex == null:
			continue
		var c := WarMapData.to_map(float(o[1]), float(o[2]))
		var w: float = o[3]
		var h := w * tex.get_height() / tex.get_width()
		draw_texture_rect(tex, Rect2(c - Vector2(w, h) * 0.5, Vector2(w, h)), false, Color(1, 1, 1, 0.92))


## The cartouche's words: the act's title, in ink, inside the frame (drawn after the land, on screen).
func _draw_cartouche_text(s: Dictionary) -> void:
	var tex := _art("cartouche")
	if tex == null:
		return
	var o: Array = ORNAMENTS[3]
	_cartouche_words(s, to_screen(WarMapData.to_map(float(o[1]), float(o[2]))), float(o[3]) * zoom)


func _cartouche_words(s: Dictionary, c: Vector2, w: float) -> void:
	if w < 90.0:
		return
	var t1 := Loc.t(String(WarMapData.data().get("title", ""))).to_upper()
	var t2 := Loc.t(String(WarMapData.data().get("act_title", "")))
	var f := UiStyle.title_font()
	var fs := int(clampf(w * 0.095, 11, 40))
	# (the words shrink to fit the frame: drawn at a fixed size they were cut, "THE WAR MA", playtest 2026-11-21)
	while fs > 8 and f.get_string_size(t1, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > w * 0.62:
		fs -= 1
	var fs2 := int(fs * 0.7)
	while fs2 > 7 and f.get_string_size(t2, HORIZONTAL_ALIGNMENT_LEFT, -1, fs2).x > w * 0.62:
		fs2 -= 1
	var ink: Color = s["ink"]
	draw_string(f, c + Vector2(-w * 0.32, fs * 0.15), t1, HORIZONTAL_ALIGNMENT_CENTER, w * 0.64, fs, Color(ink, 0.9))
	draw_string(f, c + Vector2(-w * 0.32, fs * 1.25), t2, HORIZONTAL_ALIGNMENT_CENTER, w * 0.64, fs2, Color(ink, 0.8))


func _art_file(p: String) -> Texture2D:
	if not _art_cache.has(p):
		_art_cache[p] = load(p) if ResourceLoader.exists(p) else null
	return _art_cache[p]


## A painted picture for the map (campaign/warmap_art/<name>.png), or null: the code draws its own.
var _art_cache := {}
func _art(name: String) -> Texture2D:
	if not _art_cache.has(name):
		var p := "res://campaign/warmap_art/%s.png" % name
		_art_cache[name] = load(p) if ResourceLoader.exists(p) else null
	return _art_cache[name]


func _draw_rose(c: Vector2, r: float, s: Dictionary) -> void:
	var ink: Color = s["ink"]
	var tex := _art("rose")
	if tex:
		draw_texture_rect(tex, Rect2(c - Vector2(r, r) * 1.45, Vector2(r, r) * 2.9), false, Color(1, 1, 1, 0.92))
		return
	draw_circle(c, r * 0.75, Color(s["paper"], 0.6))
	draw_arc(c, r * 0.75, 0, TAU, 32, Color(ink, 0.6), 1.2, true)
	for i in 8:
		var a := TAU * i / 8.0 - PI / 2
		var l := r if i % 2 == 0 else r * 0.55
		var d := Vector2(cos(a), sin(a))
		var n := Vector2(-d.y, d.x) * r * 0.12
		draw_colored_polygon(PackedVector2Array([c + n, c + d * l, c - n]), Color(ink, 0.75 if i % 2 == 0 else 0.45))
	draw_string(UiStyle.title_font(), c + Vector2(-6, -r - 4), "N", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(ink, 0.8))
