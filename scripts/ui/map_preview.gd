class_name MapPreview
extends Control
## A map's small picture (job map-previews, docs/map_previews.md): its real minimap (MapThumb: ground, high ground
## and cliffs, ramps, water, woods, the hall spots ringed gold) with the start spots numbered on top. One widget
## for every place a map is picked: the skirmish lobby, the online room, the tournaments, the map editor's list,
## the campaign briefing.
##
##   var p := MapPreview.new(); p.map_id = "frostfang"; p.slots = lobby_slots   # or no slots: every start spot
##   p.custom_minimum_size = Vector2(160, 110)
##
## `slots` are the lobby's ({"side", "colour"}): each player's spot in their colour, numbered by side, allies
## together as in the match. With no slots every start spot shows, numbered by side, in grey. A random pool
## shows four of its maps under a "?". A picture not made yet comes a few frames later (MapThumb's queue).

var map_id := "random":
	set(v):
		map_id = v
		queue_redraw()
var slots: Array = []:
	set(v):
		slots = v
		queue_redraw()
var show_starts := true
var frame := true                 # the dark box round it (off for a small thumbnail on a button)
var mw := 84.0                    # the map's size in cells
var mh := 60.0
var _waiting := false


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)
	resized.connect(queue_redraw)


func _process(_delta: float) -> void:
	if _waiting:
		queue_redraw()
	else:
		set_process(false)


func _players() -> int:
	return maxi(2, slots.size())


func _fit(sz: Vector2, pad: float) -> Rect2:
	var r := Rect2(Vector2(pad, pad), size - Vector2(pad, pad) * 2.0)
	var ratio := sz.x / maxf(sz.y, 1.0)
	if r.size.x / maxf(r.size.y, 1.0) > ratio:
		var w := r.size.y * ratio
		return Rect2(r.position + Vector2((r.size.x - w) * 0.5, 0), Vector2(w, r.size.y))
	var hh := r.size.x / ratio
	return Rect2(r.position + Vector2(0, (r.size.y - hh) * 0.5), Vector2(r.size.x, hh))


func _draw() -> void:
	_waiting = false
	if MapGen.is_pool(map_id):
		_pool()
		return
	var msz := Vector2(MapGen.size_of(map_id))
	mw = msz.x
	mh = msz.y
	var pad := 4.0 if frame else 1.0
	var r := _fit(msz, pad)
	if frame:
		UiStyle.box(Color(0, 0, 0, 0.5), UiStyle.TRIM_DIM, 2, 8, 0.0).draw(get_canvas_item(), r.grow(4 if size.x > 120 else 2))
	var tex := MapThumb.picture(map_id, _players())
	if tex != null:
		draw_texture_rect(tex, r, false)
	else:
		draw_rect(r, Color(0.16, 0.15, 0.12))
		var f := ThemeDB.fallback_font
		if MapThumb.drawable(map_id):
			_waiting = true
			set_process(true)
			_centre_text(r, Loc.t("drawing the map..."), 12, UiStyle.MUTED)
		else:
			draw_string(f, r.get_center() + Vector2(-12, 22), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 64, UiStyle.MUTED)
	if show_starts:
		_starts(r)


func _centre_text(r: Rect2, t: String, fs: int, col: Color) -> void:
	var f := ThemeDB.fallback_font
	var w := f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(f, r.get_center() + Vector2(-w * 0.5, fs * 0.35), t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


## A random pool: four of its maps side by side and a big "?" (which one is picked when the match starts).
func _pool() -> void:
	var r := _fit(Vector2(4, 3), 4.0 if frame else 1.0)
	if frame:
		UiStyle.box(Color(0, 0, 0, 0.5), UiStyle.TRIM_DIM, 2, 8, 0.0).draw(get_canvas_item(), r.grow(4))
	draw_rect(r, Color(0.12, 0.11, 0.09))
	var ids: Array = MapGen.pool_maps(map_id, _players())
	var n := mini(4, ids.size())
	var cols := 1 if n == 1 else 2
	var rows := 1 if n <= 2 else 2
	var cell := r.size / Vector2(cols, rows)
	for k in n:
		# (spread over the pool, not just its first four)
		var id := String(ids[int(k * ids.size() / float(n))])
		var cr := Rect2(r.position + Vector2(k % cols, k / cols) * cell, cell).grow(-2)
		var tex := MapThumb.picture(id, _players())
		var sz := Vector2(MapGen.size_of(id))
		var ratio := sz.x / sz.y
		var fr := cr
		if cr.size.x / cr.size.y > ratio:
			fr.size.x = cr.size.y * ratio
			fr.position.x += (cr.size.x - fr.size.x) * 0.5
		else:
			fr.size.y = cr.size.x / ratio
			fr.position.y += (cr.size.y - fr.size.y) * 0.5
		if tex != null:
			draw_texture_rect(tex, fr, false, Color(1, 1, 1, 0.55))
		else:
			_waiting = true
			set_process(true)
			draw_rect(fr, Color(0.2, 0.18, 0.14))
	_centre_text(r, "?", int(clampf(r.size.y * 0.45, 20, 90)), Color(1, 1, 1, 0.85))


## The start spots: each player's in its colour (by the lobby's slots), else every spot in grey; numbered by side.
func _starts(r: Rect2) -> void:
	var k := r.size / Vector2(mw, mh)
	var rad := clampf(minf(r.size.x, r.size.y) * 0.045, 4.0, 9.0)
	var fs := int(clampf(rad * 1.5, 8, 13))
	if slots.is_empty():
		for s in MapThumb.start_spots(map_id):
			_dot(r.position + (Vector2(s[0]) + Vector2(2.5, 2)) * k, rad, Color(0.85, 0.85, 0.85), int(s[1]) + 1, fs)
		return
	var sides: Array = slots.map(func(s: Dictionary) -> int: return int(s["side"]))
	var st: Array = []
	if MapData.NAMED.has(map_id):
		if sides.size() > MapGen.max_players(map_id):
			return
		st = MapGen.named_starts(map_id, sides)
	elif map_id.begins_with("custom:") or map_id.begins_with("campaign:"):
		var d := MapGen.load_custom(map_id.substr(7)) if map_id.begins_with("custom:") else Campaign.map_data(map_id.substr(9))
		if slots.size() > (d.get("starts", []) as Array).size():
			return
		st = MapGen.custom_starts(d, sides)
	elif MapGen.MAPS.has(map_id):
		_classic_starts(r)
		return
	else:
		if slots.size() <= 4:
			_classic_starts(r)
		return
	for i in st.size():
		_dot(r.position + (Vector2(st[i]) + Vector2(2.5, 2)) * k, rad, Defs.colour_of(int(slots[i]["colour"])), int(slots[i]["side"]) + 1, fs)


func _dot(p: Vector2, rad: float, col: Color, n: int, fs: int) -> void:
	draw_circle(p, rad + 2.0, Color(0, 0, 0, 0.6))
	draw_circle(p, rad, col)
	var f := ThemeDB.fallback_font
	var t := str(n)
	var w := f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(f, p + Vector2(-w * 0.5, fs * 0.36), t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE if col.get_luminance() < 0.7 else Color.BLACK)


## A classic map (laid out anew each match): two opposite corners, or all four with 3-4 players, allies on a side.
func _classic_starts(r: Rect2) -> void:
	var k := r.size / Vector2(mw, mh)
	var rad := clampf(minf(r.size.x, r.size.y) * 0.045, 4.0, 9.0)
	var fs := int(clampf(rad * 1.5, 8, 13))
	var corners: Array = [Vector2(8, 8), Vector2(mw - 8, mh - 8)]
	if slots.size() > 2:
		corners = [Vector2(8, 8), Vector2(8, mh - 8), Vector2(mw - 8, 8), Vector2(mw - 8, mh - 8)]
	var order: Array = range(slots.size())
	order.sort_custom(func(a: int, b: int) -> bool:
		return int(slots[a]["side"]) < int(slots[b]["side"]) or (slots[a]["side"] == slots[b]["side"] and a < b))
	var use: Array = [0, 1, 2, 3]
	if slots.size() == 3:
		var cnt := {}
		for s in slots:
			cnt[int(s["side"])] = int(cnt.get(int(s["side"]), 0)) + 1
		use = [0, 3, 2]
		if cnt.size() == 2:
			use = [0, 1, 3] if int(cnt[int(slots[order[0]]["side"])]) == 2 else [0, 2, 3]
	for i in mini(order.size(), 4):
		var s: Dictionary = slots[order[i]]
		_dot(r.position + corners[use[i]] * k, rad, Defs.colour_of(int(s["colour"])), int(s["side"]) + 1, fs)
