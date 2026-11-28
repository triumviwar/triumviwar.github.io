class_name WarMap
extends Control
## THE WAR MAP drawn (docs/war_map_v1.md, docs/war_map_act2.md): WarMapData's state in a SKIN: the King's PARCHMENT,
## the Clockmaker's BRASS map, the Naturalist's specimen CHART (act2-warmap). The parchment is drawn
## in code over Natural Earth's coasts (a stand-in for the owner's painting: a skin's "base" picture, when there is
## one, is drawn instead of the land and keeps the same projection). Pan with a drag, zoom with the wheel, a pinch or
## zoom_by(); a tap on a pin emits pin_tapped (a tap on nothing: pin_tapped("")).

signal pin_tapped(mid: String)

## A skin: how each thing looks. Later skins (the Clockmaker's brass map, the Naturalist's specimen chart) add theirs
## here with the same keys; "base" (a picture covering the data's bounds) replaces the drawn land when it is set.
const SKINS := {
	"parchment": {
		"style": "parchment", "paintings": true, "paper_art": "res://campaign/warmap_art/parchment.jpg", "hill_art": true,
		"base": "",
		"paper": Color(0.86, 0.79, 0.63), "paper_edge": Color(0.55, 0.40, 0.22, 0.55),
		"sea": Color(0.62, 0.70, 0.62, 0.55), "land": Color(0.86, 0.70, 0.44, 0.34), "sea_wash": Color(0.50, 0.64, 0.64, 0.26), "coast": Color(0.26, 0.17, 0.09, 0.95),
		"shore": Color(0.55, 0.62, 0.36, 0.22),
		"river": Color(0.22, 0.34, 0.48, 0.65), "grid": Color(0.40, 0.30, 0.18, 0.10), "ink": Color(0.22, 0.15, 0.09),
		"empire": Color(0.50, 0.30, 0.62, 0.10),
		"holders": {
			"crown": {"fill": Color(0.47, 0.22, 0.62, 0.38), "line": Color(0.36, 0.14, 0.48, 0.9)},
			"contested": {"fill": Color(0.47, 0.22, 0.62, 0.30), "line": Color(0.36, 0.14, 0.48, 0.9), "hatch": Color(0.72, 0.55, 0.82, 0.75)},
			"machine": {"fill": Color(0.74, 0.16, 0.10, 0.42), "line": Color(0.52, 0.08, 0.05, 0.9), "hatch": Color(0.45, 0.05, 0.03, 0.45)},
			"brood": {"fill": Color(0.25, 0.55, 0.20, 0.42), "line": Color(0.14, 0.36, 0.10, 0.9)},
			"unrest": {"fill": Color(0.20, 0.46, 0.22, 0.30), "line": Color(0.10, 0.10, 0.08, 0.9), "hatch": Color(0.08, 0.08, 0.06, 0.65)},
			"unknown": {"fill": Color(0.92, 0.87, 0.74, 1.0), "line": Color(0.30, 0.22, 0.14, 0.7), "dashed": true},
			"guild": {"fill": Color(0.20, 0.34, 0.66, 0.36), "line": Color(0.12, 0.22, 0.48, 0.9), "hatch": Color(0.80, 0.62, 0.22, 0.7)},
		},
		"lines": {"crown": Color(0.42, 0.16, 0.55), "clockmaker": Color(0.62, 0.40, 0.10), "naturalist": Color(0.22, 0.42, 0.18),
			"all": Color(0.70, 0.52, 0.12)},
		"locked": Color(0.52, 0.47, 0.42),
	},
	## THE BRASS MAP (the Clockmaker's war table, act2-warmap): an engraved brass plate on turning rings; the regions in
	## enamel with brass rims, the machine's land a creeping ground of small gears, the pins small gears. Drawn in code;
	## "paper_art" (the plate, screen space) and "base" (the land, the data's bounds) take the owner's paintings.
	"brass": {
		"style": "brass", "paintings": true, "paint_prefix": "brass_", "paper_art": "res://campaign/warmap_art/brass_plate.jpg", "hill_art": false,
		"base": "",
		"paper": Color(0.60, 0.44, 0.19), "paper_edge": Color(0.22, 0.13, 0.04, 0.85),
		"sea": Color(0.50, 0.36, 0.15), "land": Color(0.86, 0.68, 0.33, 0.62), "sea_wash": Color(0.24, 0.15, 0.05, 0.22),
		"coast": Color(0.17, 0.10, 0.03, 0.95), "shore": Color(1.0, 0.92, 0.62, 0.20),
		"river": Color(0.20, 0.11, 0.04, 0.75), "grid": Color(0.22, 0.13, 0.04, 0.30), "ink": Color(0.15, 0.08, 0.02),
		"empire": Color(0.50, 0.30, 0.62, 0.06),
		"holders": {
			"crown": {"fill": Color(0.40, 0.17, 0.56, 0.74), "line": Color(0.98, 0.86, 0.48, 0.95)},
			"contested": {"fill": Color(0.40, 0.17, 0.56, 0.58), "line": Color(0.98, 0.86, 0.48, 0.95), "hatch": Color(0.80, 0.66, 0.90, 0.8)},
			"machine": {"fill": Color(0.68, 0.11, 0.07, 0.70), "line": Color(0.98, 0.86, 0.48, 0.95), "gears": Color(0.98, 0.80, 0.40, 0.85)},
			"brood": {"fill": Color(0.16, 0.46, 0.20, 0.72), "line": Color(0.98, 0.86, 0.48, 0.95)},
			"unrest": {"fill": Color(0.18, 0.42, 0.20, 0.55), "line": Color(0.10, 0.08, 0.04, 0.9), "hatch": Color(0.08, 0.06, 0.03, 0.75)},
			"unknown": {"fill": Color(0.50, 0.36, 0.15, 1.0), "line": Color(0.20, 0.12, 0.04, 0.8), "dashed": true},
			"guild": {"fill": Color(0.13, 0.28, 0.62, 0.78), "line": Color(0.98, 0.86, 0.48, 0.95), "hatch": Color(0.98, 0.84, 0.45, 0.55)},
		},
		"lines": {"crown": Color(0.45, 0.20, 0.60), "clockmaker": Color(0.80, 0.24, 0.14), "naturalist": Color(0.22, 0.50, 0.24),
			"all": Color(0.20, 0.32, 0.66)},
		"locked": Color(0.42, 0.42, 0.45),
	},
	## THE SPECIMEN CHART (the Naturalist's war table, act2-warmap: Lindqvist's, then Valadares'): a field chart in ink
	## and pencil, the rivers in blue ink, light watercolour washes, the creatures' land stippled in green ink by a careful
	## hand, the pins pinned specimen labels, notes in the margins.
	"chart": {
		"style": "chart", "paintings": true, "paint_prefix": "chart_", "paper_art": "res://campaign/warmap_art/chart_paper.jpg", "hill_art": false,
		"base": "",
		"paper": Color(0.93, 0.90, 0.81), "paper_edge": Color(0.45, 0.38, 0.26, 0.45),
		"sea": Color(0.91, 0.90, 0.84), "land": Color(0.82, 0.74, 0.56, 0.22), "sea_wash": Color(0.70, 0.80, 0.84, 0.14),
		"coast": Color(0.27, 0.20, 0.13, 0.9), "shore": Color(0.42, 0.58, 0.36, 0.14),
		"river": Color(0.15, 0.30, 0.58, 0.9), "grid": Color(0.36, 0.40, 0.48, 0.16), "ink": Color(0.20, 0.15, 0.10),
		"empire": Color(0.50, 0.30, 0.62, 0.04),
		"holders": {
			"crown": {"fill": Color(0.50, 0.30, 0.66, 0.20), "line": Color(0.40, 0.22, 0.55, 0.8)},
			"contested": {"fill": Color(0.50, 0.30, 0.66, 0.16), "line": Color(0.40, 0.22, 0.55, 0.8), "hatch": Color(0.55, 0.38, 0.70, 0.6)},
			"machine": {"fill": Color(0.74, 0.20, 0.14, 0.20), "line": Color(0.55, 0.12, 0.08, 0.8), "hatch": Color(0.55, 0.12, 0.08, 0.5)},
			"brood": {"fill": Color(0.24, 0.56, 0.22, 0.16), "line": Color(0.14, 0.42, 0.14, 0.9), "stipple": Color(0.12, 0.40, 0.12, 0.85)},
			"unrest": {"fill": Color(0.22, 0.48, 0.24, 0.16), "line": Color(0.12, 0.12, 0.10, 0.8), "hatch": Color(0.10, 0.10, 0.08, 0.5)},
			"unknown": {"fill": Color(0.95, 0.93, 0.86, 1.0), "line": Color(0.30, 0.24, 0.18, 0.7), "dashed": true},
			"guild": {"fill": Color(0.20, 0.36, 0.70, 0.18), "line": Color(0.14, 0.26, 0.55, 0.8), "hatch": Color(0.14, 0.26, 0.55, 0.45)},
		},
		"lines": {"crown": Color(0.42, 0.18, 0.56), "clockmaker": Color(0.62, 0.40, 0.10), "naturalist": Color(0.18, 0.42, 0.16),
			"all": Color(0.62, 0.46, 0.10)},
		"locked": Color(0.55, 0.52, 0.48),
	},
}

## The coast's ink rings out to sea, in map units (degrees), and the mountain ranges' file.
const RIPPLES := [0.3, 0.65, 1.05]
const MOUNTAINS := "res://campaign/warmap_mountains.json"

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
var _regions: Array = []           # [{id, pts, hatch: [segments], dots: [points inside], box: Rect2}]
var act := {}                      # WarMapData.act(): the act's title and the view it opens on
var _drag := false
var _press := Vector2.ZERO
var _moved := 0.0
var _touches := {}
var _pinch0 := 0.0
var _zoom0 := 1.0
var _t := 0.0
var _fitted := false
var _shown := false                # the camera has been put on its first view
var _view_rect := Rect2()
var pending_cam := {}              # {"c": center, "z": zoom, "v": painted} to put back once sized (the page came back)
## THE CATHOLIC PAINTINGS (owner 2026-11-21 21:52: "why isn't it showing the Catholic map?"): each view (THE WORLD,
## VIRGINIA, EUROPE, THE AMAZON) shows its painted sheet (data "paintings": campaign/warmap_art/painted_<view>.jpg);
## the camera then works in the sheet's pixels and the places are put on it by WarMapData.painted_px. A view without
## its painting (or a missing file) shows the drawn map as before.
var painted := ""
var _ptex: Texture2D
## TERRITORY ON THE PAINTINGS (owner 2026-11-21 23:48 "Do that"): each held region is filled with diagonal STRIPES in
## its holder's colour (gaps between, so the painting shows; two colours alternating where it is contested or in
## unrest), a thin edge in the same colour, and a FLAG at its middle. The TERRITORY button hides it all. Built once per
## sheet and state (_terr_build), in the sheet's pixels: the region cut to the coasts as on the drawn map, warped onto
## the painting by WarMapData.painted_px.
static var territory := true
const STRIPE_W := 14.0                 # a band's width in sheet pixels (every region's bands line up: one pattern)
var _terr := {}
var _terr_key := ""


static func make(skin_id := "parchment") -> WarMap:
	var w := WarMap.new()
	w.skin = skin_id if SKINS.has(skin_id) else "parchment"
	return w


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	seal_r = 13.0 if Settings.pc() else 18.0
	act = WarMapData.act()
	var start := String(pending_cam.get("v", act.get("view", "")))
	if _paint_ok(start):
		_set_painted(start)
	elif not pending_cam.has("z"):
		# (a view with no painting, or a skin without paintings: the drawn map opens on that view: Act 2 unrolls BRAZIL)
		for v in WarMapData.data().get("views", []):
			if String(v["id"]) == start:
				_view_rect = WarMapData.rect_of(v["rect"])
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
			_shown = true
			if _bring_pin != "":
				bring_into_view(_bring_pin, false)
	_shown = true
	queue_redraw()


func sk() -> Dictionary:
	if ColourAccess.mode() == 1:
		return _sk_access()
	return SKINS[skin]


## COLOUR-BLIND HELP, red-green (ui-access-phone): the skin with the machine's and the Brood's territory in the
## colour-blind faction colours (ColourAccess.holder), worked out once per skin.
static var _sk_acc := {}
func _sk_access() -> Dictionary:
	if not _sk_acc.has(skin):
		var s: Dictionary = (SKINS[skin] as Dictionary).duplicate(true)
		for h in s["holders"]:
			var hs: Dictionary = s["holders"][h]
			for k in hs:
				if hs[k] is Color:
					hs[k] = ColourAccess.holder(String(h), hs[k])
		_sk_acc[skin] = s
	return _sk_acc[skin]


func _paint_ok(id: String) -> bool:
	if not bool(sk().get("paintings", false)):
		return false
	var pt: Dictionary = WarMapData.data().get("paintings", {}).get(id, {})
	return not pt.is_empty() and ResourceLoader.exists(_pfile(id))


## The view's painted sheet for this skin: the King's (parchment) or the brass map's / the chart's own redraw of it
## (owner 2026-11-28: painted_brass_<view>.jpg, painted_chart_<view>.jpg, the same coasts, so the same fit).
func _pfile(id: String) -> String:
	var f := String(WarMapData.data()["paintings"][id]["file"])
	var pre := String(sk().get("paint_prefix", ""))
	return f.replace("/painted_", "/painted_" + pre) if pre != "" else f


func _set_painted(id: String) -> void:
	painted = id
	_ptex = load(_pfile(id)) if id != "" else null


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


## Is this pin, mark, region or note of an act the map has reached (its "act"; Act 3's world waits for Act 3)?
func now(x: Dictionary) -> bool:
	return int(x.get("act", 1)) <= int(act.get("act", 1))


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
	st = WarMapData.state(p, skin)
	act = WarMapData.act(p)
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
		# points spread inside the region: the brass map's creeping gears, the chart's green-ink stipple
		var dots: Array = []
		var ds := maxf(maxf(bx.size.x, bx.size.y) / 9.0, 0.12)
		var row := 0
		var yy := bx.position.y + ds * 0.5
		while yy < bx.end.y and dots.size() < 90:
			var xx := bx.position.x + ds * (0.25 if row % 2 == 0 else 0.75)
			while xx < bx.end.x:
				for part in parts:
					if Geometry2D.is_point_in_polygon(Vector2(xx, yy), part):
						dots.append(Vector2(xx, yy))
						break
				xx += ds
			yy += ds * 0.87
			row += 1
		var lab: Array = rg.get("label_at", [])
		_regions.append({"id": String(rg["id"]), "act": int(rg.get("act", 1)), "parts": out_parts, "hatch": hatch, "dots": dots, "dot_step": ds,
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
		_stop_glide()
		var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_tw = tw
		tw.tween_method(func(k: float) -> void:
			center = center.lerp(c, k)
			zoom = lerpf(zoom, z, k)
			_clamp()
			queue_redraw(), 0.0, 1.0, 0.35)
	else:
		_stop_glide()
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
	_stop_glide()
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
		if painted == "":
			# (a pin's card covers the right side or the lower part: the sheet's edge may go under it, so a pin near
			# the edge can still come out beside the card, act2-warmap)
			hi += (card_right if ax == 0 else size.y * (1.0 - card_top) if card_top > 0.0 else 0.0) / zoom
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
	_stop_glide()
	_moved += rel.length()
	center -= rel / zoom
	_clamp()
	queue_redraw()


## A tap at a screen point: the nearest pin within reach is picked (pin_tapped), else none.
func tap(at: Vector2) -> void:
	_bring_pin = ""
	var best := ""
	var bd := seal_r * 1.7
	for pn in WarMapData.data().get("pins", []):
		if not shows(pn["point"], String(pn["mission"])) or not now(pn):
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


func bring_into_view(mid: String, glide := true) -> void:
	var pn := WarMapData.pin_of(mid)
	if pn.is_empty():
		return
	_bring_pin = mid          # (the first fit, and a fit after a resize, put the view in place and then this pin)
	if size.x <= 10 or not _shown:
		return
	var fr := free_area()
	var c := pin_screen(pn)
	if fr.grow(-seal_r * 3.0).abs().has_point(c):
		return
	var want := fr.get_center()
	var goal := center + (c - want) / zoom
	if not glide or not is_inside_tree():
		_stop_glide()
		center = goal
		_clamp()
		queue_redraw()
		return
	var from := center
	_stop_glide()
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tw = tw
	tw.tween_method(func(k: float) -> void:
		center = from.lerp(goal, k)
		_clamp()
		queue_redraw(), 0.0, 1.0, 0.3)


## The part of the map the pin's card leaves seen: free_rect when the page set one, else the card's side
## (card_right pixels on the right, or the top card_top share of the height on a phone), else all of it.
var card_right := 0.0
var card_top := 0.0
var _bring_pin := ""
var _tw: Tween


## A glide still running (an older view or pin) stops: the newest camera move wins.
func _stop_glide() -> void:
	if _tw and _tw.is_valid():
		_tw.kill()
	_tw = null


func free_area() -> Rect2:
	if free_rect.size.x > 120 and free_rect.size.y > 120:
		return free_rect
	if card_right > 0.0 and size.x - card_right > 120:
		return Rect2(0, 0, size.x - card_right, size.y)
	if card_top > 0.0:
		return Rect2(0, 0, size.x, size.y * card_top)
	return Rect2(Vector2.ZERO, size)


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
	var style := String(s.get("style", "parchment"))
	var font := UiStyle.body_font()
	var tfont := UiStyle.title_font()
	if painted != "" and _ptex:
		_draw_painted(s, font)
		return
	draw_rect(Rect2(Vector2.ZERO, size), s["paper"])
	var paper := _art_file(String(s.get("paper_art", "")))
	if paper:
		# the sheet itself (screen space: the paper does not zoom, the map on it does), covering the frame
		var k := maxf(size.x / paper.get_width(), size.y / paper.get_height())
		var ps := Vector2(paper.get_width(), paper.get_height()) * k
		draw_texture_rect(paper, Rect2((size - ps) * 0.5, ps), false)
		draw_rect(Rect2(Vector2.ZERO, size), s["sea_wash"])      # the sea a little cooler than the land
	else:
		draw_rect(Rect2(Vector2.ZERO, size), s["sea"])
		_draw_sheet(s, style)
	# the land, in map units under one transform; the lines' widths are in pixels (divided by the zoom)
	draw_set_transform(size * 0.5 - center * zoom, 0.0, Vector2(zoom, zoom))
	var px := 1.0 / zoom
	var vis := Rect2(center - size * 0.5 / zoom, size / zoom).grow(2.0)
	var base_tex: Texture2D = null
	if String(s.get("base", "")) != "" and ResourceLoader.exists(String(s["base"])):
		base_tex = load(String(s["base"]))
	if base_tex:
		draw_texture_rect(base_tex, world_rect(), false)
	else:
		var bd: Array = WarMapData.data().get("bounds", [-180, -60, 180, 80])
		var gstep := 5 if style == "chart" else 10           # (the chart's pencil grid is finer)
		for lon in range(int(ceil(float(bd[0]) / gstep)) * gstep, int(bd[2]) + 1, gstep):      # (the graticule)
			draw_line(WarMapData.to_map(lon, float(bd[1])), WarMapData.to_map(lon, float(bd[3])), s["grid"], px)
			if style == "brass":
				draw_line(WarMapData.to_map(lon, float(bd[1])) + Vector2(px, 0), WarMapData.to_map(lon, float(bd[3])) + Vector2(px, 0), Color(1, 0.9, 0.6, 0.10), px)
		for lat in range(int(ceil(float(bd[1]) / gstep)) * gstep, int(bd[3]) + 1, gstep):
			draw_line(WarMapData.to_map(float(bd[0]), lat), WarMapData.to_map(float(bd[2]), lat), s["grid"], (2.0 if lat == 0 else 1.0) * px)
			if style == "brass":
				draw_line(WarMapData.to_map(float(bd[0]), lat) + Vector2(0, px), WarMapData.to_map(float(bd[2]), lat) + Vector2(0, px), Color(1, 0.9, 0.6, 0.10), px)
		# the engraved coast lines out to sea, the nearest darkest (the chart: one pencil line)
		var ralpha: Array = {"parchment": [0.42, 0.28, 0.16], "brass": [0.55, 0.36, 0.2], "chart": [0.3, 0.0, 0.0]}.get(style, [0.42, 0.28, 0.16])
		for rp in _ripples:
			if float(ralpha[rp[1]]) <= 0.0:
				continue
			var pl: PackedVector2Array = rp[0]
			var ink: Color = s["ink"]
			ink.a = ralpha[rp[1]]
			draw_polyline(pl, ink, 0.8 * px, true)
		# the land: a wash on the sheet, a band along the shore
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
			draw_polyline(r, s["river"], (2.0 if style == "chart" else 1.2) * px, true)
		_draw_hills(s, px, vis)
		if style == "parchment":
			_draw_ornaments()
	# the regions: washes, hatching, outlines (the brass map's machine: creeping gears; the chart's creatures: stipple)
	var regs: Dictionary = st.get("regions", {})
	for rg in _regions:
		var h := String(regs.get(rg["id"], "empire"))
		if h == "empire" or not (s["holders"] as Dictionary).has(h) or not now(rg):
			continue
		if not (rg["box"] as Rect2).intersects(vis):
			continue
		var hs: Dictionary = s["holders"][h]
		for part in rg["parts"]:
			if not (part["tri"] as PackedInt32Array).is_empty():
				RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), part["tri"], part["pts"], PackedColorArray([hs["fill"]]))
		if hs.has("hatch"):
			for sg in rg["hatch"]:
				draw_line(sg[0], sg[sg.size() - 1], hs["hatch"], 1.3 * px, true)
		if hs.has("gears"):
			var gr := clampf(float(rg["dot_step"]) * 0.3, 2.5 * px, 9.0 * px)
			var i := 0
			for d in rg["dots"]:
				_gear_poly(d, gr, 8, _t * (0.6 if i % 2 == 0 else -0.6) + i, hs["gears"], 1.1 * px)
				i += 1
		if hs.has("stipple"):
			var dr := clampf(float(rg["dot_step"]) * 0.06, 0.8 * px, 2.2 * px)
			var j := 0
			for d in rg["dots"]:
				var dv: Vector2 = d
				for k in 3:
					var a := float(j * 7 + k * 3) * 1.7
					draw_circle(dv + Vector2(cos(a), sin(a)) * float(rg["dot_step"]) * 0.22, dr, hs["stipple"])
				j += 1
		for part in rg["parts"]:
			var closed: PackedVector2Array = part["closed"]
			if bool(hs.get("dashed", false)):
				for i in closed.size() - 1:
					draw_dashed_line(closed[i], closed[i + 1], hs["line"], 1.4 * px, 5.0 * px)
			else:
				draw_polyline(closed, hs["line"], (2.0 if style == "brass" else 1.6) * px, true)
	if not base_tex:
		for it in _land:
			if not (it[2] as Rect2).intersects(vis):
				continue
			var c: PackedVector2Array = (it[0] as PackedVector2Array).duplicate()
			c.append(c[0])
			if style == "brass":
				# an engraved line: the cut dark, the light catching its lower lip
				draw_polyline(c, Color(1, 0.92, 0.65, 0.35), 1.2 * px, true)
				var cs := PackedVector2Array()
				for q in c:
					cs.append(q - Vector2(0, 0.8 * px))
				draw_polyline(cs, s["coast"], 1.4 * px, true)
			else:
				draw_polyline(c, s["coast"], (1.1 if style == "chart" else 1.4) * px, true)
	draw_set_transform(Vector2.ZERO)
	if style == "parchment":
		_draw_cartouche_text(s)
	# region names (where there is room)
	for rg in _regions:
		if not bool(rg["label"]) or not now(rg):
			continue
		var h := String(regs.get(rg["id"], "empire"))
		var bw: float = (rg["box"] as Rect2).size.x * zoom
		if bw < 34.0:
			continue
		var fs := int(clampf(bw * 0.09, 11, 18))
		var txt := Loc.t(String(rg["name"])).to_upper()
		var at := to_screen(rg["label_at"])
		if at.x < -200 or at.y < -40 or at.x > size.x + 200 or at.y > size.y + 40:
			continue
		var tw := tfont.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var col: Color = s["ink"]
		col.a = 0.55 if h == "empire" else 0.85
		if style == "brass":
			draw_string(tfont, at - Vector2(tw * 0.5, -fs * 0.35) + Vector2(0, 1), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 0.9, 0.6, 0.35))
		draw_string(tfont, at - Vector2(tw * 0.5, -fs * 0.35), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
	# marks
	var mks: Dictionary = st.get("marks", {})
	for mk in WarMapData.data().get("marks", []):
		if bool(mks.get(String(mk["id"]), false)) and now(mk):
			_draw_mark(mk, font)
	# the skin's notes (the chart's margin notes, the brass map's engraved words)
	_draw_notes(s, style, font)
	# pins, then their labels where they fit
	var placed: Array = []
	var order: Array = (WarMapData.data().get("pins", []) as Array).filter(func(pn: Dictionary) -> bool: return now(pn))
	order.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return String(a["mission"]) == selected and String(b["mission"]) != selected)
	for pn in order:
		_draw_pin(pn)
	var seals := {}
	for pn in order:
		var c := pin_screen(pn)
		seals[String(pn["mission"])] = Rect2(c - Vector2(seal_r, seal_r), Vector2(seal_r, seal_r) * 2)
		placed.append(seals[String(pn["mission"])])
	for pn in order:
		var c := pin_screen(pn)
		if c.x < -60 or c.y < -60 or c.x > size.x + 60 or c.y > size.y + 60:
			continue
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
		var plate: Color = Color(s["paper"], 0.75)
		if style == "brass":
			plate = Color(s["paper"].lightened(0.25), 0.85)
		draw_rect(r.grow(3), plate)
		if style == "brass":
			draw_rect(r.grow(3), Color(s["ink"], 0.6), false, 1.0)
		elif style == "chart":
			draw_rect(r.grow(3), Color(s["ink"], 0.35), false, 1.0)
		draw_string(font, r.position + Vector2(0, fs * 0.9), t1, HORIZONTAL_ALIGNMENT_CENTER, w, fs, s["ink"])
		draw_string(font, r.position + Vector2(0, fs * 1.9), t2, HORIZONTAL_ALIGNMENT_CENTER, w, fs - 2, Color(s["ink"], 0.75))
	_draw_frame(s, style)
	_draw_clock_plate(s, style, font)


## The sheet under the map when there is no painted paper: the brass plate's brushed sheen, the chart's paper.
func _draw_sheet(s: Dictionary, style: String) -> void:
	match style:
		"brass":
			# brushed brass: soft bands of light across the plate, then the concentric turning of a lathe
			for i in 8:
				var y := size.y * (float(i) / 8.0)
				draw_rect(Rect2(0, y, size.x, size.y / 8.0 + 1), Color(1, 0.88, 0.55, 0.05 * (1.0 - absf(float(i) - 3.5) / 4.0)))
			var c := size * 0.5
			var rmax := size.length() * 0.5
			var n := 26
			for i in n:
				draw_arc(c, rmax * (float(i) + 1.0) / n, 0, TAU, 96, Color(0.25, 0.15, 0.05, 0.05 if i % 2 == 0 else 0.03), 2.0, true)
		"chart":
			# the chart's paper: a faint ruled margin and the field's wear
			draw_rect(Rect2(Vector2.ZERO, size), Color(0.96, 0.94, 0.86, 0.5))
			for i in 5:
				draw_circle(Vector2(size.x * (0.15 + 0.19 * i), size.y * (0.2 + 0.13 * ((i * 3) % 5))), 60.0 + 25.0 * (i % 3), Color(0.72, 0.62, 0.42, 0.035))
		_:
			pass


## A small gear (the brass map's creeping ground and its pins): `teeth` teeth, turned by `a`.
func _gear_poly(c: Vector2, r: float, teeth: int, a: float, col: Color, w: float) -> void:
	var g := PackedVector2Array()
	for i in teeth * 2:
		var aa := a + TAU * i / (teeth * 2.0)
		g.append(c + Vector2(cos(aa), sin(aa)) * r * (1.0 if i % 2 == 0 else 0.74))
	g.append(g[0])
	draw_polyline(g, col, w, true)
	draw_arc(c, r * 0.32, 0, TAU, 10, col, w, true)


## The skin's notes (WarMapData.state "notes"): the chart's in ink with a pencil leader, the brass map's engraved.
func _draw_notes(s: Dictionary, style: String, font: Font) -> void:
	if zoom < maxf(min_zoom() * 2.2, 14.0):
		return               # (written small: they show once the map is zoomed past a whole country)
	var fs := 13 if Settings.pc() else 16
	for n in st.get("notes", []):
		if not now(n):
			continue
		var p := to_screen(geo(n["point"]))
		if p.x < -300 or p.y < -40 or p.x > size.x + 40 or p.y > size.y + 40:
			continue
		var txt := Loc.t(String(n["text"]))
		var ink: Color = s["ink"]
		if style == "brass":
			draw_string(font, p + Vector2(0, 1), txt, HORIZONTAL_ALIGNMENT_LEFT, 260, fs, Color(1, 0.9, 0.6, 0.45))
			draw_string(font, p, txt, HORIZONTAL_ALIGNMENT_LEFT, 260, fs, Color(ink, 0.9))
		else:
			# (the chart after e06: Lindqvist's annotations, taken from him, in red ink)
			var nc := Color(0.62, 0.10, 0.08, 0.9) if bool(n.get("red", false)) else Color(0.18, 0.22, 0.38, 0.85)
			draw_line(p + Vector2(-14, -4), p + Vector2(-3, -4), Color(nc, 0.6), 1.0, true)
			draw_multiline_string(font, p, txt, HORIZONTAL_ALIGNMENT_LEFT, 230, fs, -1, nc)


## The frame: the parchment's dark edge and compass rose; the brass plate's rim, rivets and turning rings; the
## chart's ruled border, a pencil scale and a plain north arrow.
func _draw_frame(s: Dictionary, style: String) -> void:
	match style:
		"brass":
			var rim := Color(0.30, 0.19, 0.06)
			draw_rect(Rect2(Vector2.ZERO, size), rim, false, 10.0)
			draw_rect(Rect2(Vector2(5, 5), size - Vector2(10, 10)), Color(1, 0.88, 0.5, 0.45), false, 2.0)
			draw_rect(Rect2(Vector2(9, 9), size - Vector2(18, 18)), Color(0.2, 0.12, 0.04, 0.7), false, 1.5)
			for q in [Vector2(18, 18), Vector2(size.x - 18, 18), Vector2(18, size.y - 18), Vector2(size.x - 18, size.y - 18)]:
				draw_circle(q, 5.5, Color(0.75, 0.58, 0.28))
				draw_arc(q, 5.5, 0, TAU, 14, rim, 1.2, true)
				draw_line(q - Vector2(3, 3), q + Vector2(3, 3), rim, 1.2, true)
			# the turning rings: an engraved dial in the corner, its outer ring of teeth turning slowly
			var c := Vector2(size.x - 64, size.y - 66)
			var r := 42.0
			draw_circle(c, r, Color(0.62, 0.46, 0.20, 0.85))
			_gear_poly(c, r, 28, _t * 0.08, rim, 2.0)
			draw_arc(c, r * 0.78, 0, TAU, 48, Color(1, 0.9, 0.6, 0.5), 1.2, true)
			draw_arc(c, r * 0.74, 0, TAU, 48, rim, 1.2, true)
			for i in 12:
				var a := -_t * 0.05 + TAU * i / 12.0
				draw_line(c + Vector2(cos(a), sin(a)) * r * 0.5, c + Vector2(cos(a), sin(a)) * r * 0.7, rim, 1.2, true)
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r * 0.62), c + Vector2(5, 0), c + Vector2(0, 6), c + Vector2(-5, 0)]), rim)
			draw_string(UiStyle.title_font(), c + Vector2(-5, -r * 0.3), "N", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 0.9, 0.6, 0.9))
		"chart":
			var ink: Color = s["ink"]
			draw_rect(Rect2(Vector2(6, 6), size - Vector2(12, 12)), Color(ink, 0.55), false, 1.5)
			draw_rect(Rect2(Vector2(11, 11), size - Vector2(22, 22)), Color(ink, 0.35), false, 1.0)
			# a pencil scale: a hundred leagues (a degree at the equator ~ 20 leagues, near enough for a field chart)
			var deg := 5.0 * zoom
			if deg > 20.0 and deg < size.x * 0.4:
				var a := Vector2(size.x * 0.5 - deg * 0.5, size.y - 24)
				draw_line(a, a + Vector2(deg, 0), Color(ink, 0.7), 1.5)
				for i in 6:
					draw_line(a + Vector2(deg * i / 5.0, -4 if i % 5 == 0 else -2), a + Vector2(deg * i / 5.0, 0), Color(ink, 0.7), 1.0)
				draw_string(UiStyle.body_font(), a + Vector2(deg + 6, 4), Loc.t("100 leagues"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(ink, 0.7))
			var c := Vector2(size.x - 44, size.y - 70)
			draw_line(c + Vector2(0, 26), c + Vector2(0, -26), Color(ink, 0.75), 1.4, true)
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -30), c + Vector2(6, -16), c + Vector2(-6, -16)]), Color(ink, 0.75))
			draw_string(UiStyle.title_font(), c + Vector2(-5, -34), "N", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(ink, 0.8))
		_:
			for i in 6:
				draw_rect(Rect2(Vector2(i, i) * 3.0, size - Vector2(i, i) * 6.0), Color(s["paper_edge"], 0.22 - i * 0.03), false, 3.0)
			_draw_rose(Vector2(size.x - 60, size.y - 64), 38.0, s)


## The bands' colours for a holder on the paintings: [first, second] (second clear: a gap); [] = no stripes.
func _stripe_cols(h: String, hs: Dictionary) -> Array:
	match h:
		"contested":
			return [Color(hs["line"], 0.50), Color(hs["hatch"], 0.30)]      # (the Crown's, uneasy: purple only, red is the machine's)
		"unrest":
			return [ColourAccess.holder("unrest", Color(0.20, 0.50, 0.22, 0.55)), Color(0.06, 0.06, 0.05, 0.45)]
		"unknown":
			return []
	return [Color(hs["line"], 0.50), Color(0, 0, 0, 0)]


func _terr_build() -> Dictionary:
	var key := painted + "|" + str(st.get("regions", {})) + "|cb%d" % ColourAccess.mode()
	if key == _terr_key:
		return _terr
	_terr_key = key
	var pt: Dictionary = WarMapData.data()["paintings"][painted]
	var sh := _ptex.get_size()
	var rect := PackedVector2Array([Vector2.ZERO, Vector2(sh.x, 0), sh, Vector2(0, sh.y)])
	var ys := float(WarMapData.data().get("projection", {}).get("y_scale", 1.0))
	var s := sk()
	var regs: Dictionary = st.get("regions", {})
	var fills: Array = []
	var edges: Array = []
	var flags: Array = []
	var nv := Vector2(1, -1).normalized()
	var uv := Vector2(1, 1).normalized()
	for rg in _regions:
		var h := String(regs.get(rg["id"], "empire"))
		if h == "empire" or not (s["holders"] as Dictionary).has(h) or not now(rg):
			continue
		var hs: Dictionary = s["holders"][h]
		var cols := _stripe_cols(h, hs)
		var on_sheet := false
		for part in rg["parts"]:
			var src: PackedVector2Array = part["pts"]
			var pp := PackedVector2Array()
			for i in src.size():
				var a: Vector2 = src[i]
				var b: Vector2 = src[(i + 1) % src.size()]
				var n := maxi(1, int(a.distance_to(b) / 0.4))
				for k in n:
					var q := a.lerp(b, float(k) / n)
					pp.append(WarMapData.painted_px(pt, q.x, -q.y / ys))
			for cut in Geometry2D.intersect_polygons(pp, rect):
				if (cut as PackedVector2Array).size() < 3 or Geometry2D.is_polygon_clockwise(cut) != Geometry2D.is_polygon_clockwise(pp):
					continue
				on_sheet = true
				var cl: PackedVector2Array = (cut as PackedVector2Array).duplicate()
				cl.append(cl[0])
				edges.append([cl, Color(hs["line"], 0.8), bool(hs.get("dashed", false))])
				if cols.is_empty():
					continue
				var t0 := INF
				var t1 := -INF
				var s0 := INF
				var s1 := -INF
				for q in cut:
					t0 = minf(t0, q.dot(nv))
					t1 = maxf(t1, q.dot(nv))
					s0 = minf(s0, q.dot(uv))
					s1 = maxf(s1, q.dot(uv))
				for k in range(int(floor(t0 / STRIPE_W)), int(ceil(t1 / STRIPE_W)) + 1):
					var col: Color = cols[posmod(k, 2)]
					if col.a <= 0.0:
						continue
					var quad := PackedVector2Array([nv * k * STRIPE_W + uv * (s0 - 2), nv * (k + 1) * STRIPE_W + uv * (s0 - 2),
						nv * (k + 1) * STRIPE_W + uv * (s1 + 2), nv * k * STRIPE_W + uv * (s1 + 2)])
					for piece in Geometry2D.intersect_polygons(cut, quad):
						var tri := Geometry2D.triangulate_polygon(piece)
						if not tri.is_empty():
							fills.append([piece, tri, col])
		if on_sheet and h != "unknown":
			var la: Vector2 = rg["label_at"]
			var fp := WarMapData.painted_px(pt, la.x, -la.y / ys)
			if Rect2(Vector2.ZERO, sh).has_point(fp):
				flags.append([fp, h, String(rg["name"])])
	_terr = {"fills": fills, "edges": edges, "flags": flags}
	return _terr


## A region's flag: a pole and a swallowtail pennant in the holder's colour (split for contested, banded for unrest).
func _draw_flag(p: Vector2, h: String, name: String, s: Dictionary, font: Font) -> void:
	var hs: Dictionary = s["holders"][h]
	var k := 1.0 if Settings.pc() else 1.25
	var ink: Color = s["ink"]
	var top := p + Vector2(0, -30) * k
	draw_line(p + Vector2(0, 1), top, Color(0.25, 0.16, 0.08), 2.2 * k, true)
	draw_circle(top, 2.2 * k, Color(0.80, 0.62, 0.22))
	var w := 26.0 * k
	var fh := 15.0 * k
	var fl := PackedVector2Array([top + Vector2(1, 2) * k, top + Vector2(w, 2 * k), top + Vector2(w - 7 * k, 2 * k + fh * 0.5),
		top + Vector2(w, 2 * k + fh), top + Vector2(1 * k, 2 * k + fh)])
	var main: Color = Color(hs["line"], 1.0)
	if h == "unrest":
		main = Color(0.20, 0.50, 0.22)
	draw_colored_polygon(fl, main)
	if h == "contested" or h == "unrest":
		var second: Color = Color(hs["hatch"], 1.0) if h == "contested" else Color(0.06, 0.06, 0.05)
		draw_colored_polygon(PackedVector2Array([top + Vector2(1, 2 + fh * 0.5) * Vector2(k, 1) , fl[2], fl[3], fl[4]]), second)
	var ol := fl.duplicate()
	ol.append(fl[0])
	draw_polyline(ol, ink, 1.0, true)
	draw_circle(p, 2.5 * k, ink)
	if painted == "world" and zoom < min_zoom() * 1.6:
		return
	var fs := 12 if Settings.pc() else 15
	var txt := Loc.t(name).to_upper()
	var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var lr := Rect2(p + Vector2(-tw * 0.5 - 4, 4), Vector2(tw + 8, fs + 6))
	draw_rect(lr, Color(s["paper"], 0.85))
	draw_rect(lr, Color(main, 0.9), false, 1.0)
	draw_string(font, lr.position + Vector2(4, fs + 1), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)


## The painted sheet: the painting, its marks and seals, their names, and the act's title in its cartouche.
func _draw_painted(s: Dictionary, font: Font) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.09, 0.07, 0.05))
	var r := Rect2(to_screen(Vector2.ZERO), _ptex.get_size() * zoom)
	draw_texture_rect(_ptex, r, false)
	if territory:
		var tc := _terr_build()
		draw_set_transform(to_screen(Vector2.ZERO), 0.0, Vector2(zoom, zoom))
		for f in tc["fills"]:
			RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), f[1], f[0], PackedColorArray([f[2]]))
		for e in tc["edges"]:
			var cl: PackedVector2Array = e[0]
			if bool(e[2]):
				for i in cl.size() - 1:
					draw_dashed_line(cl[i], cl[i + 1], e[1], 1.6 / zoom, 6.0 / zoom)
			else:
				draw_polyline(cl, e[1], 2.4 / zoom, true)
		draw_set_transform(Vector2.ZERO)
		# a flag steps aside from the seals and the flags already planted
		var taken: Array = []
		for pn in WarMapData.data().get("pins", []):
			if shows(pn["point"], String(pn["mission"])) and now(pn):
				taken.append(pin_screen(pn))
		for f in tc["flags"]:
			var at := to_screen(f[0])
			for off in [Vector2.ZERO, Vector2(-34, -4), Vector2(34, -4), Vector2(0, -40), Vector2(-34, 30), Vector2(34, 30)]:
				var ok := true
				for q in taken:
					if (q as Vector2).distance_to(at + off) < seal_r + 18.0:
						ok = false
						break
				if ok:
					at += off
					break
			taken.append(at)
			_draw_flag(at, String(f[1]), String(f[2]), s, font)
	var mks: Dictionary = st.get("marks", {})
	for mk in WarMapData.data().get("marks", []):
		if bool(mks.get(String(mk["id"]), false)) and shows(mk["point"], String(mk["id"])) and now(mk):
			_draw_mark(mk, font)
	var pins: Array = []
	for pn in WarMapData.data().get("pins", []):
		if shows(pn["point"], String(pn["mission"])) and now(pn):
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
	_draw_clock_plate(s, String(s.get("style", "parchment")), font)


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
		# act2-warmap's marks
		"route":
			# a dashed line by sea or land (the guild's ships, Varenne's exile, the conspirator's road)
			var pts: Array = mk.get("points", [])
			for i in pts.size() - 1:
				var a := to_screen(geo(pts[i]))
				var b := to_screen(geo(pts[i + 1]))
				draw_dashed_line(a, b, Color(ink, 0.7), 1.6, 7.0, true)
			if pts.size() >= 2:
				var e := to_screen(geo(pts[pts.size() - 1]))
				var dv := (e - to_screen(geo(pts[pts.size() - 2]))).normalized()
				draw_colored_polygon(PackedVector2Array([e, e - dv * 9 + dv.orthogonal() * 4, e - dv * 9 - dv.orthogonal() * 4]), Color(ink, 0.75))
			return
		"gear":
			var gc: Color = s["lines"]["clockmaker"]
			var g := PackedVector2Array()
			for i in 20:
				var a := TAU * i / 20.0 + _t * 0.2
				g.append(c + Vector2(cos(a), sin(a)) * (8.0 if i % 2 == 0 else 6.0))
			draw_colored_polygon(g, gc)
			draw_circle(c, 2.6, Color(s["paper"], 0.9))
			g.append(g[0])
			draw_polyline(g, Color(ink, 0.8), 1.0, true)
		"queen":
			# the Queen: a green crown on a dark disc (where nobody has been)
			draw_circle(c, 9.0, Color(0.10, 0.22, 0.08, 0.85))
			draw_colored_polygon(PackedVector2Array([c + Vector2(-6, 4), c + Vector2(-6, -3), c + Vector2(-3, 0), c + Vector2(0, -6),
				c + Vector2(3, 0), c + Vector2(6, -3), c + Vector2(6, 4)]), Color(0.45, 0.85, 0.30))
			draw_arc(c, 9.0, 0, TAU, 20, Color(0.45, 0.85, 0.30, 0.8), 1.2, true)
		"church", "church_burnt":
			var wall := Color(0.95, 0.93, 0.86) if String(mk["kind"]) == "church" else Color(0.35, 0.25, 0.18)
			draw_rect(Rect2(c + Vector2(-5, -3), Vector2(10, 8)), wall)
			draw_rect(Rect2(c + Vector2(-5, -3), Vector2(10, 8)), Color(ink, 0.8), false, 1.0)
			draw_line(c + Vector2(0, -3), c + Vector2(0, -12), Color(ink, 0.9), 1.4)
			draw_line(c + Vector2(-3, -9), c + Vector2(3, -9), Color(ink, 0.9), 1.4)
			if String(mk["kind"]) == "church_burnt":
				draw_circle(c + Vector2(4, -2), 3.0, Color(0.85, 0.35, 0.08, 0.8))
		"fort":
			var star := PackedVector2Array()
			for i in 8:
				var a := TAU * i / 8.0 + PI / 8.0
				star.append(c + Vector2(cos(a), sin(a)) * (8.0 if i % 2 == 0 else 5.0))
			draw_colored_polygon(star, s["lines"]["crown"])
			star.append(star[0])
			draw_polyline(star, Color(ink, 0.9), 1.2, true)
		# act3-warmap's marks
		"theatre":
			_draw_theatre(mk, c, s)
			return
		"crown":
			# an ally's crown: gold on a small disc of the Crown's purple
			draw_circle(c, 8.0, Color(s["lines"]["crown"], 0.85))
			draw_colored_polygon(PackedVector2Array([c + Vector2(-5, 3), c + Vector2(-5, -2), c + Vector2(-2.5, 0.5), c + Vector2(0, -5),
				c + Vector2(2.5, 0.5), c + Vector2(5, -2), c + Vector2(5, 3)]), Color(0.98, 0.82, 0.30))
			draw_arc(c, 8.0, 0, TAU, 18, Color(ink, 0.8), 1.0, true)
		"ruin", "ruin_open":
			# the old lab's ruin: a sealed stone, or an open book
			if String(mk["kind"]) == "ruin":
				draw_rect(Rect2(c - Vector2(7, 5), Vector2(14, 10)), Color(0.55, 0.52, 0.46))
				draw_rect(Rect2(c - Vector2(7, 5), Vector2(14, 10)), Color(ink, 0.85), false, 1.2)
				draw_line(c + Vector2(0, -4), c + Vector2(0, 4), Color(ink, 0.8), 1.4)
				draw_line(c + Vector2(-3, -1), c + Vector2(3, -1), Color(ink, 0.8), 1.4)
			else:
				draw_colored_polygon(PackedVector2Array([c, c + Vector2(-8, -3), c + Vector2(-8, 6), c + Vector2(0, 8)]), Color(0.95, 0.92, 0.82))
				draw_colored_polygon(PackedVector2Array([c, c + Vector2(8, -3), c + Vector2(8, 6), c + Vector2(0, 8)]), Color(0.92, 0.88, 0.78))
				draw_polyline(PackedVector2Array([c + Vector2(-8, -3), c, c + Vector2(8, -3), c + Vector2(8, 6), c + Vector2(0, 8), c + Vector2(-8, 6), c + Vector2(-8, -3)]),
					Color(0.62, 0.10, 0.08, 0.9), 1.2, true)
		"siege":
			# the siege lines: a purple ring round the city
			var rr := maxf(16.0, 0.6 * zoom) if painted == "" else 18.0
			for i in 16:
				if i % 2 == 0:
					draw_arc(c, rr, TAU * i / 16.0, TAU * (i + 1) / 16.0, 4, s["lines"]["crown"], 3.0, true)
	var lab := Loc.t(String(mk.get("label", "")))
	# (on the drawn map, names only once zoomed past a whole country: BRAZIL's view keeps them off its crowded rivers)
	if lab != "" and zoom > (min_zoom() * 2.2 if painted != "" else maxf(min_zoom() * 2.2, 14.0)):
		var fs := 13 if Settings.pc() else 16
		draw_string(font, c + Vector2(9, -6), lab, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(ink, 0.9))


## A THEATRE's name (act3-warmap): large spaced letters on THE WORLD, and under them the clock's word for it: SETTLED,
## the years it has been left alone, or the small clock when it is the next to lose a colony.
func _draw_theatre(mk: Dictionary, c: Vector2, s: Dictionary) -> void:
	var tid := String(mk.get("theatre", ""))
	var ck: Dictionary = st.get("clock", {})
	var ink: Color = s["ink"]
	var tf := UiStyle.title_font()
	var up := Loc.t(String(mk.get("label", ""))).to_upper()
	var txt := ""
	for i in up.length():
		txt += up[i] + (" " if i < up.length() - 1 else "")
	var fs := int(clampf(zoom * 3.2, 14, 30)) if painted == "" else 22
	var tw := tf.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	if String(s.get("style", "")) == "brass":
		draw_string(tf, c + Vector2(-tw * 0.5, 1), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 0.9, 0.6, 0.45))
	draw_string(tf, c + Vector2(-tw * 0.5, 0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(ink, 0.72))
	if not bool(ck.get("on", false)):
		return
	var sub := ""
	var col := Color(ink, 0.8)
	var fs2 := maxi(12, int(fs * 0.62))
	if (ck.get("settled", []) as Array).has(tid):
		sub = Loc.t("SETTLED")
		col = Color(0.20, 0.42, 0.18)
	else:
		var n := int(ck.get("neglect", {}).get(tid, 0))
		sub = Loc.t("Fought this year") if n <= 0 else (Loc.t("Left alone %s years") % str(n) if n != 1 else Loc.t("Left alone 1 year"))
		if String(ck.get("risk", "")) == tid and not bool(ck.get("stopped", false)):
			col = Color(0.62, 0.12, 0.08)
			sub = Loc.t("NEXT TO FALL") + "  ·  " + sub
	var sw := UiStyle.body_font().get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, fs2).x
	draw_string(UiStyle.body_font(), c + Vector2(-sw * 0.5, fs2 + 6), sub, HORIZONTAL_ALIGNMENT_LEFT, -1, fs2, col)
	if String(ck.get("risk", "")) == tid and not bool(ck.get("stopped", false)):
		_draw_clock(c + Vector2(-sw * 0.5 - fs2, fs2 * 0.65 + 6), fs2 * 0.55, ink)


## A wax seal: the line's colour when open or done, grey when locked, a dashed ring when only planned; a crack across a
## broken one (a place lost); the line's sign pressed in it.
func _draw_pin(pn: Dictionary) -> void:
	var s: Dictionary = sk()
	var mid := String(pn["mission"])
	var ps: Dictionary = st.get("pins", {}).get(mid, {"state": "planned", "seal": ""})
	var state := String(ps["state"])
	if bool(ps.get("closed", false)) and state != "planned":
		state = "locked"          # (act3-warmap: an optional pin the night closed)
	var c := pin_screen(pn)
	var truep := to_screen(geo(pn["point"], mid))
	var r := seal_r
	var ink: Color = s["ink"]
	if bool(pn.get("optional", false)):
		_draw_ribbon(c + Vector2(0, r * 0.95), r, s, bool(ps.get("closed", false)))
	if c.distance_to(truep) > 2.0:
		draw_line(truep, c, Color(ink, 0.6), 1.2, true)
		draw_circle(truep, 2.5, Color(ink, 0.8))
	if mid == selected:
		draw_circle(c, r + 7, Color(1, 0.85, 0.35, 0.55))
	if state == "open":
		var k := 0.5 + 0.5 * sin(_t * 3.0)
		draw_arc(c, r + 3 + k * 4, 0, TAU, 32, Color(0.95, 0.75, 0.25, 0.9 - k * 0.5), 2.5, true)
	if String(ps.get("clock", "")) != "":
		_draw_clock(c + Vector2(r * 1.45, -r * 1.15), r * 0.5, ink)
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
	match String(s.get("style", "parchment")):
		"brass":
			_draw_gear_pin(c, r, col, state, broken, ps, String(pn["line"]), ink)
			return
		"chart":
			_draw_tag_pin(c, r, col, state, broken, ps, String(pn["line"]), ink)
			return
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


## THE OPTIONAL RIBBON (act3-warmap): a small gold ribbon under an optional pin's seal (greyed once the night closed it).
func _draw_ribbon(c: Vector2, r: float, s: Dictionary, closed: bool) -> void:
	var col := Color(0.55, 0.52, 0.48) if closed else (Color(0.92, 0.78, 0.36) if String(s.get("style", "")) != "chart" else Color(0.78, 0.62, 0.22))
	var w := r * 1.1
	var h := r * 0.34
	draw_colored_polygon(PackedVector2Array([c + Vector2(-w, -h), c + Vector2(w, -h), c + Vector2(w * 0.8, 0), c + Vector2(w, h),
		c + Vector2(-w, h), c + Vector2(-w * 0.8, 0)]), col)
	draw_polyline(PackedVector2Array([c + Vector2(-w, -h), c + Vector2(w, -h), c + Vector2(w * 0.8, 0), c + Vector2(w, h),
		c + Vector2(-w, h), c + Vector2(-w * 0.8, 0), c + Vector2(-w, -h)]), Color(s["ink"], 0.7), 1.0, true)


## THE CLOCK's plate (act3-warmap, docs/war_map_act3.md): on screen, top middle, in every skin once Act 3 has opened:
## the year, the colonies still held, and which theatre loses a colony when the year next turns (SAY IT PLAINLY).
func _draw_clock_plate(s: Dictionary, style: String, font: Font) -> void:
	var ck: Dictionary = st.get("clock", {})
	if not bool(ck.get("on", false)):
		return
	var cd: Dictionary = WarMapData.data().get("clock", {})
	var held := 0
	var total := 0
	for t in ck.get("held", {}):
		held += (ck["held"][t] as Array).size()
	for t in cd.get("theatres", []):
		total += (t["colonies"] as Array).size()
	var l1 := (Loc.t(String(cd.get("year", "The year %s"))) % str(ck["year"])).to_upper()
	var l2 := Loc.t("Colonies held: %s of %s") % [str(held), str(total)]
	var l3 := ""
	var bad := false
	if bool(ck.get("stopped", false)):
		l3 = Loc.t("The night has come: the clock has stopped.")
	elif String(ck.get("risk", "")) != "":
		var th := WarMapData.theatre(String(ck["risk"]))
		var rn := Loc.t(String(WarMapData.region_of(String(ck["risk_region"])).get("name", "")))
		var wl := float(ck.get("to_turn", 0.0))
		var wn := str(int(ceil(wl - 1e-6))) if absf(wl - roundf(wl)) < 0.01 else "%.1f" % wl
		l3 = Loc.t("Next to fall, in %s wins: %s (%s)") % [wn, Loc.t(String(th.get("name", ""))), rn]
		bad = true
	else:
		l3 = Loc.t("No colony is at risk at the next turn of the year.")
	var fs := 16 if Settings.pc() else 19
	var tf := UiStyle.title_font()
	var w := maxf(tf.get_string_size(l1, HORIZONTAL_ALIGNMENT_LEFT, -1, fs + 4).x, maxf(font.get_string_size(l2, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x,
		font.get_string_size(l3, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)) + 56
	w = minf(w, size.x - 20)
	var box := Rect2(Vector2((size.x - w) * 0.5, 8), Vector2(w, fs * 3.9 + 10))
	var paper: Color = s["paper"]
	var ink: Color = s["ink"]
	match style:
		"brass":
			draw_rect(box, Color(paper.lightened(0.18), 0.92))
			draw_rect(box, Color(0.22, 0.13, 0.04, 0.9), false, 2.0)
			draw_rect(box.grow(-3), Color(1, 0.9, 0.6, 0.4), false, 1.0)
		"chart":
			draw_rect(box, Color(0.98, 0.97, 0.92, 0.94))
			draw_rect(box, Color(ink, 0.5), false, 1.0)
		_:
			draw_rect(box, Color(paper, 0.93))
			draw_rect(box, Color(ink, 0.75), false, 2.0)
			draw_rect(box.grow(-4), Color(ink, 0.35), false, 1.0)
	_draw_clock(box.position + Vector2(22, fs * 1.0 + 6), fs * 0.62, ink)
	draw_string(tf, box.position + Vector2(40, fs * 1.25 + 4), l1, HORIZONTAL_ALIGNMENT_LEFT, w - 48, fs + 4, ink)
	draw_string(font, box.position + Vector2(40, fs * 2.4 + 6), l2, HORIZONTAL_ALIGNMENT_LEFT, w - 48, fs, Color(ink, 0.85))
	draw_string(font, box.position + Vector2(40, fs * 3.5 + 6), l3, HORIZONTAL_ALIGNMENT_LEFT, w - 48, fs,
		Color(0.62, 0.12, 0.08) if bad else Color(ink, 0.85))


## THE BRASS MAP's pin: a small gear in brass with the line's enamel in its middle (a crack across it when broken).
func _draw_gear_pin(c: Vector2, r: float, col: Color, state: String, broken: bool, ps: Dictionary, line: String, ink: Color) -> void:
	var g := PackedVector2Array()
	var turn := _t * 0.4 if state == "open" else 0.0
	for i in 24:
		var a := TAU * i / 24.0 + turn
		g.append(c + Vector2(cos(a), sin(a)) * r * (1.05 if i % 2 == 0 else 0.86))
	var brass := Color(0.88, 0.70, 0.34) if state != "locked" else Color(0.55, 0.55, 0.58)
	draw_colored_polygon(g, brass)
	g.append(g[0])
	draw_polyline(g, Color(ink, 0.9), 1.2, true)
	draw_circle(c, r * 0.66, col)
	draw_arc(c, r * 0.66, 0, TAU, 24, Color(1, 0.92, 0.6, 0.8), 1.2, true)
	_draw_sign(line, c, r * 0.42, Color(1, 0.92, 0.65, 0.95))
	if broken:
		draw_polyline(PackedVector2Array([c + Vector2(-r, -r * 0.3), c + Vector2(-r * 0.2, 0.1 * r), c + Vector2(0.1 * r, -0.2 * r), c + Vector2(r, r * 0.4)]), Color(0.1, 0.05, 0.02, 0.95), 2.2, true)
	elif state == "done":
		draw_arc(c, r * 1.2, 0, TAU, 28, Color(1, 0.9, 0.5, 0.9), 1.5, true)
	if state == "locked":
		_draw_lock(c, r)


## THE SPECIMEN CHART's pin: a specimen label pinned to the chart: a pin's head in the line's colour, a paper tag with
## the line's sign (the tag torn across when broken).
func _draw_tag_pin(c: Vector2, r: float, col: Color, state: String, broken: bool, ps: Dictionary, line: String, ink: Color) -> void:
	var tag := Rect2(c + Vector2(-r * 0.95, -r * 0.55), Vector2(r * 1.9, r * 1.3))
	draw_rect(Rect2(tag.position + Vector2(2, 2), tag.size), Color(0, 0, 0, 0.18))
	draw_rect(tag, Color(0.98, 0.97, 0.92) if state != "locked" else Color(0.82, 0.80, 0.76))
	draw_rect(tag, Color(ink, 0.7), false, 1.0)
	draw_line(tag.position + Vector2(0, tag.size.y * 0.32), tag.position + Vector2(tag.size.x, tag.size.y * 0.32), Color(col, 0.8), 1.5)
	_draw_sign(line, c + Vector2(0, r * 0.2), r * 0.38, Color(col, 0.95) if state != "locked" else Color(0.45, 0.43, 0.4))
	var head := c + Vector2(0, -r * 0.62)
	draw_circle(head + Vector2(1, 1), r * 0.3, Color(0, 0, 0, 0.25))
	draw_circle(head, r * 0.3, col if state != "locked" else Color(0.5, 0.5, 0.52))
	draw_circle(head + Vector2(-r * 0.09, -r * 0.09), r * 0.09, Color(1, 1, 1, 0.6))
	if broken:
		draw_polyline(PackedVector2Array([tag.position + Vector2(0, tag.size.y * 0.7), tag.position + Vector2(tag.size.x * 0.4, tag.size.y * 0.45),
			tag.position + Vector2(tag.size.x * 0.6, tag.size.y * 0.75), tag.end - Vector2(0, tag.size.y * 0.5)]), Color(0.45, 0.12, 0.08, 0.95), 2.0, true)
	elif state == "done":
		draw_line(tag.position + Vector2(tag.size.x * 0.62, tag.size.y * 0.78), tag.position + Vector2(tag.size.x * 0.74, tag.size.y * 0.92), Color(0.15, 0.4, 0.15), 1.8, true)
		draw_line(tag.position + Vector2(tag.size.x * 0.74, tag.size.y * 0.92), tag.position + Vector2(tag.size.x * 0.95, tag.size.y * 0.58), Color(0.15, 0.4, 0.15), 1.8, true)
	if state == "locked":
		_draw_lock(c, r)


func _draw_lock(c: Vector2, r: float) -> void:
	draw_rect(Rect2(c + Vector2(r * 0.35, r * 0.25), Vector2(r * 0.6, r * 0.5)), Color(0.2, 0.18, 0.15))
	draw_arc(c + Vector2(r * 0.65, r * 0.25), r * 0.2, PI, TAU, 8, Color(0.2, 0.18, 0.15), 1.6)


## THE DIAMOND'S CLOCK (d09's choice): a small clock face on the front that waits ("the longer it waits, the worse").
func _draw_clock(c: Vector2, r: float, ink: Color) -> void:
	draw_circle(c, r + 1.5, Color(ink, 0.9))
	draw_circle(c, r, Color(0.97, 0.94, 0.84))
	for i in 4:
		var a := TAU * i / 4.0
		draw_line(c + Vector2(cos(a), sin(a)) * r * 0.75, c + Vector2(cos(a), sin(a)) * r * 0.95, ink, 1.0)
	var m := _t * 0.9
	draw_line(c, c + Vector2(cos(m - PI / 2), sin(m - PI / 2)) * r * 0.8, ink, 1.2, true)
	draw_line(c, c + Vector2(cos(m / 12.0 - PI / 2), sin(m / 12.0 - PI / 2)) * r * 0.5, ink, 1.6, true)


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
	var painted := _art("mountain_0") != null and bool(s.get("hill_art", true))
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
	var t1 := Loc.t(WarMapData.skin_title(skin)).to_upper()
	var t2 := Loc.t(String(act.get("act_title", WarMapData.data().get("act_title", ""))))
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
