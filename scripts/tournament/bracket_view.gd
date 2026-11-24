class_name BracketView
extends Control
## THE BRACKET, DRAWN (docs/tournament.md): every match a box (the two players, their factions' colours, the series
## score; the winner bright, the loser dim; a match to play now gold-edged, my own matches marked), joined by lines to
## the matches they feed. Elimination: the upper bracket on top, the lower bracket under it, the grand final to the
## right; the playoffs of a groups tournament the same way; a round robin, Swiss or a group stage as columns of rounds.
## Drag (one finger) to move, the wheel / a pinch / the + and - buttons to zoom; a tap on a box opens that match.

signal match_pressed(mid: int)

const BOX := Vector2(236, 62)
const GAP := Vector2(64, 16)
const HEAD := 34.0

var t: Tournament
var me := -1
var zoom := 1.0
var pan := Vector2(20, 20)
var _boxes := {}          # mid -> Rect2 (bracket space)
var _links: Array = []    # [from Rect2, to Rect2]
var _heads: Array = []    # [pos, text]
var _extent := Rect2()
var _drag := false
var _drag_from := Vector2.ZERO
var _moved := 0.0
var _touches := {}
var _pinch0 := 0.0
var _zoom0 := 1.0
var _font: Font


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_font = UiStyle.body_font()
	layout()


func set_tournament(tour: Tournament, my_id := -1) -> void:
	t = tour
	me = my_id
	layout()
	queue_redraw()


## Where every box goes.
func layout() -> void:
	_boxes = {}
	_links = []
	_heads = []
	if t == null or (t.d["matches"] as Array).is_empty():
		_extent = Rect2()
		return
	var y := 0.0
	var right := 0.0
	match String(t.d["format"]):
		"single":
			var r := _tree("wb", Vector2(0, y), "")
			right = r.end.x
		"double":
			var up := _tree("wb", Vector2(0, 0), "UPPER BRACKET")
			var lo := _tree("lb", Vector2(0, up.end.y + 40), "LOWER BRACKET")
			var x := maxf(up.end.x, lo.end.x) + GAP.x
			var wf := t._last_of("wb")
			var lf := t._last_of("lb")
			var cy := HEAD
			if not wf.is_empty() and not lf.is_empty() and _boxes.has(int(wf["id"])) and _boxes.has(int(lf["id"])):
				cy = ((_boxes[int(wf["id"])] as Rect2).get_center().y + (_boxes[int(lf["id"])] as Rect2).get_center().y) * 0.5 - BOX.y * 0.5
			_heads.append([Vector2(x, cy - 30), "GRAND FINAL"])
			for m in t.rounds_of("gf"):
				for g in m:
					var rr := Rect2(Vector2(x, cy), BOX)
					_boxes[int(g["id"])] = rr
					for s in ["from_a", "from_b"]:
						var src: Array = g[s]
						if src.size() == 2 and _boxes.has(int(src[1])) and src[0] == "w":
							_links.append([_boxes[int(src[1])], rr])
					x += BOX.x + GAP.x
			right = x
		"groups":
			var gx := 0.0
			for gi in int(t.d["groups"]):
				var rr := _columns("grp", Vector2(gx, 0), "GROUP %s" % char(65 + gi), gi)
				gx = rr.end.x + GAP.x
			var gy := 0.0
			for b in _boxes.values():
				gy = maxf(gy, (b as Rect2).end.y)
			if t.d.has("playoffs"):
				_tree("po", Vector2(0, gy + 50), "PLAYOFFS")
		_:
			_columns("rr" if t.d["format"] == "robin" else "sw", Vector2(0, 0), "")
	_extent = Rect2()
	for b in _boxes.values():
		_extent = (b as Rect2) if _extent.size == Vector2.ZERO else _extent.merge(b)
	for h in _heads:
		_extent = _extent.expand(h[0])


## An elimination tree of one stage from `at`; its rect.
func _tree(stage: String, at: Vector2, title: String) -> Rect2:
	var rounds := t.rounds_of(stage)
	var top := at.y + (HEAD if title != "" else 0.0)
	if title != "":
		_heads.append([at, title])
	var ext := Rect2(at, Vector2.ZERO)
	for ri in rounds.size():
		var x := at.x + ri * (BOX.x + GAP.x)
		var col: Array = rounds[ri]
		_heads.append([Vector2(x, top - 4), "  " + t.match_label(col[0])])
		for i in col.size():
			var m: Dictionary = col[i]
			var ys: Array = []
			for s in ["from_a", "from_b"]:
				var src: Array = m[s]
				if src.size() == 2 and _boxes.has(int(src[1])) and t.get_match(int(src[1]))["stage"] == stage:
					ys.append((_boxes[int(src[1])] as Rect2).position.y)
			var yy := top + 22 + i * (BOX.y + GAP.y)
			if not ys.is_empty():
				yy = 0.0
				for v in ys:
					yy += float(v)
				yy /= ys.size()
			var rr := Rect2(Vector2(x, yy), BOX)
			_boxes[int(m["id"])] = rr
			for s in ["from_a", "from_b"]:
				var src2: Array = m[s]
				if src2.size() == 2 and _boxes.has(int(src2[1])) and t.get_match(int(src2[1]))["stage"] == stage:
					_links.append([_boxes[int(src2[1])], rr])
			ext = ext.merge(rr)
	return ext


## Rounds as plain columns (round robin, Swiss, a group).
func _columns(stage: String, at: Vector2, title: String, group := -1) -> Rect2:
	var rounds := t.rounds_of(stage, group)
	var top := at.y + (HEAD if title != "" else 0.0)
	if title != "":
		_heads.append([at, title])
	var ext := Rect2(at, Vector2.ZERO)
	for ri in rounds.size():
		var x := at.x + ri * (BOX.x + 24)
		var col: Array = rounds[ri]
		_heads.append([Vector2(x, top - 4), "  " + Loc.t("Round %d") % (ri + 1)])
		for i in col.size():
			var rr := Rect2(Vector2(x, top + 22 + i * (BOX.y + GAP.y)), BOX)
			_boxes[int(col[i]["id"])] = rr
			ext = ext.merge(rr)
	return ext


## Fit the whole bracket in view.
func fit() -> void:
	if _extent.size == Vector2.ZERO or size.x < 10:
		return
	var z := minf((size.x - 40) / maxf(1.0, _extent.size.x), (size.y - 40) / maxf(1.0, _extent.size.y))
	zoom = clampf(z, 0.25, 1.4)
	pan = Vector2(20, 20) - _extent.position * zoom
	queue_redraw()


func zoom_by(k: float, at := Vector2.INF) -> void:
	if at == Vector2.INF:
		at = size * 0.5
	var before := (at - pan) / zoom
	zoom = clampf(zoom * k, 0.2, 3.0)
	pan = at - before * zoom
	queue_redraw()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		var mb := e as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			zoom_by(1.12, mb.position)
			accept_event()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			zoom_by(1.0 / 1.12, mb.position)
			accept_event()
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_drag = true
				_drag_from = mb.position
				_moved = 0.0
			else:
				_drag = false
				if _moved < 8.0:
					_tap(mb.position)
			accept_event()
	elif e is InputEventMouseMotion and _drag and _touches.size() < 2:
		var mm := e as InputEventMouseMotion
		pan += mm.relative
		_moved += mm.relative.length()
		queue_redraw()
		accept_event()
	elif e is InputEventScreenTouch:
		var st := e as InputEventScreenTouch
		if st.pressed:
			_touches[st.index] = st.position
		else:
			_touches.erase(st.index)
		if _touches.size() == 2:
			var ps: Array = _touches.values()
			_pinch0 = (ps[0] as Vector2).distance_to(ps[1])
			_zoom0 = zoom
	elif e is InputEventScreenDrag:
		var sd := e as InputEventScreenDrag
		_touches[sd.index] = sd.position
		if _touches.size() == 2 and _pinch0 > 1.0:
			var ps2: Array = _touches.values()
			var dist := (ps2[0] as Vector2).distance_to(ps2[1])
			var mid := ((ps2[0] as Vector2) + (ps2[1] as Vector2)) * 0.5
			zoom_by((_zoom0 * dist / _pinch0) / zoom, mid)
			_moved += 100.0
	elif e is InputEventMagnifyGesture:
		zoom_by((e as InputEventMagnifyGesture).factor, (e as InputEventMagnifyGesture).position)


func _tap(p: Vector2) -> void:
	var q := (p - pan) / zoom
	for mid in _boxes:
		if (_boxes[mid] as Rect2).has_point(q):
			match_pressed.emit(int(mid))
			return


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.06, 0.05, 0.04, 0.92))
	if t == null:
		return
	if _boxes.is_empty():
		draw_string(_font, Vector2(24, 40), Loc.t("The bracket is drawn when the tournament starts."), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, UiStyle.MUTED)
		return
	draw_set_transform(pan, 0.0, Vector2(zoom, zoom))
	for l in _links:
		var a: Rect2 = l[0]
		var b: Rect2 = l[1]
		var p0 := Vector2(a.end.x, a.get_center().y)
		var p1 := Vector2(b.position.x, b.get_center().y)
		var mx := (p0.x + p1.x) * 0.5
		var col := Color(0.79, 0.64, 0.29, 0.5)
		draw_polyline(PackedVector2Array([p0, Vector2(mx, p0.y), Vector2(mx, p1.y), p1]), col, 2.0)
	for h in _heads:
		draw_string(_font, (h[0] as Vector2) + Vector2(0, 18), Loc.t(String(h[1]).strip_edges()), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, UiStyle.TRIM)
	for mid in _boxes:
		_box(t.get_match(int(mid)), _boxes[mid])
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _box(m: Dictionary, r: Rect2) -> void:
	var ready: bool = m["state"] == "ready" or m["state"] == "live"
	var mine := me >= 0 and (int(m["a"]) == me or int(m["b"]) == me)
	var skipped: bool = m.get("skip", false) or (m.get("bye", false) and int(m["winner"]) == Tournament.NONE)
	var bg := Color(0.13, 0.11, 0.085, 0.95) if not skipped else Color(0.1, 0.09, 0.07, 0.5)
	var border := Color(0.79, 0.64, 0.29, 0.35)
	if ready:
		border = UiStyle.TRIM
	if mine:
		border = Color(0.45, 0.8, 1.0)
	if String(m.get("dispute", "")) != "":
		border = UiStyle.BAD
	draw_rect(r, bg)
	draw_rect(r, border, false, 3.0 if (ready or mine) else 1.5)
	var sc := t.score(m)
	var half := r.size.y * 0.5
	for i in 2:
		var side := "a" if i == 0 else "b"
		var pid := int(m[side])
		var row := Rect2(r.position + Vector2(0, i * half), Vector2(r.size.x, half))
		var p := t.player(pid)
		var fac := String(p.get("faction", ""))
		if pid >= 0 and UiStyle.ACCENT.has(fac):
			draw_rect(Rect2(row.position + Vector2(2, 3), Vector2(6, half - 6)), UiStyle.ACCENT[fac])
		var won: bool = m["state"] == "done" and int(m["winner"]) == pid and pid >= 0
		var lost: bool = m["state"] == "done" and int(m["loser"]) == pid and pid >= 0
		var col := UiStyle.TEXT
		if won:
			col = UiStyle.GOOD
		elif lost:
			col = Color(0.95, 0.9, 0.78, 0.4)
		elif pid < 0:
			col = Color(0.95, 0.9, 0.78, 0.35)
		var nm := t.pname(pid)
		if pid >= 0 and int(p.get("seed", 0)) > 0:
			nm = "%d  %s" % [int(p["seed"]), nm]
		draw_string(_font, row.position + Vector2(14, half * 0.5 + 7), nm, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 58, 17, col)
		if not (m["games"] as Array).is_empty() or m["state"] == "done":
			var s := str(sc[i])
			if m.get("walkover", false):
				s = "W" if won else "-"
			elif m.get("bye", false) or m.get("skip", false):
				s = ""
			draw_string(_font, row.position + Vector2(r.size.x - 32, half * 0.5 + 8), s, HORIZONTAL_ALIGNMENT_CENTER, 26, 19, col)
	draw_line(r.position + Vector2(10, half), r.position + Vector2(r.size.x - 10, half), Color(1, 1, 1, 0.08), 1.0)
	if m["state"] == "live":
		draw_circle(r.position + Vector2(r.size.x - 8, 8), 4.0, UiStyle.BAD)
	if m.get("reset", false) and m.get("skip", false):
		draw_string(_font, r.get_center() + Vector2(-60, 6), Loc.t("not needed"), HORIZONTAL_ALIGNMENT_CENTER, 120, 15, UiStyle.MUTED)


var _fitted := false


## The first time the view has its real size, the whole bracket is fitted into it (then the player's zoom stays).
func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and not _fitted and _extent.size != Vector2.ZERO and size.x > 100 and size.y > 100:
		_fitted = true
		fit()
