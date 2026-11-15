class_name RootmawSpots
extends Node2D
## ROOTMAW SPOTS (the owner, 2026-11-15; docs/brood_rootmaw_spots.md). With the other sides back on their original
## economy (2 Farms / 2 Cog Presses a hall, 0.38.12) the Brood keeps the only economy with a radius, made fair and easy:
##  - A COUNT like the others: each swamp holds so many Rootmaws, the Brood Mother's MAWS_QUEEN (3), a rooted Mound
##    Turtle's MAWS_TURTLE (2) (Defs.NB "maws_queen" / "maws_turtle"). A Rootmaw belongs to the swamp it roots on (where
##    swamps overlap, to the one with room: assign()); ROOT and morphing a grub into one are refused on a full swamp
##    (room_problem, from BroodRoot.place_problem). The Mother's and a turtle's card and the bar over them read
##    "ROOTMAWS 2/3" (label()).
##  - THE BEST SPOTS SHOWN (in the style of scripts/expansion_spots.gd: gold on the ground, the best brighter, small
##    squares on the minimap), to a Brood player only and only on his side's swamp: for every swamp with room, the
##    free spots where ALL its missing Rootmaws fit together (their circles clear of each other and of every Rootmaw
##    there), near the Mother or turtle, on open level ground, clear of the ramps and lanes (fit()). Brighter while
##    the player places a Rootmaw. NO SNAPPING (the owner: "I don't think snapping is necessary"): the marks only
##    guide. Settings.rootmaw_spots (SHOW ROOTMAW SPOTS, on by default). The Brood computer roots its Rootmaws on the
##    same spots (ai_brood_new.gd _nb_find_spot_go).
## Code-drawn (docs/art_style_inconsistency.md).

const GOLD := ExpansionSpots.GOLD
const SHADE := ExpansionSpots.SHADE
const CHECK := 0.5                 # seconds between looks for a change (a Rootmaw rooted, a turtle up, the Mother grown)

## (measuring only: tools/measure_rootmaw_fit.gd tries other circle radii without touching Defs.PIT_CLAIM)
static var r_test := 0.0

var game: Game
var shown: Array = []              # [{p: feet, rank: 1 best / 2, src: the Mother or turtle}] drawn now (tests)
var _t := 0.0
var _placing := false
var _key := "-"


# ------------------------------------------------------------------ the count

## How many Rootmaws a swamp source holds.
static func cap_of(u: Unit) -> int:
	return int(Defs.NB["maws_queen"]) if u.kind == BroodNew.QUEEN else int(Defs.NB["maws_turtle"])


## Side t's swamp sources: the Brood Mother and its Mound Turtles that are down (rooting or rooted; not up, not on their
## way up). In g.units order.
static func sources(g: Game, t: int) -> Array:
	var out: Array = []
	if not BroodNew.on(g, t):
		return out
	for u in g.units:
		if u.team != t or u.dead or not (u.kind == BroodNew.QUEEN or u.kind == BroodNew.TURTLE):
			continue
		if u.tesla_mode == "packed" or u.tesla_mode == "packing" or not BroodRoot.has_fp(u):
			continue
		out.append(u)
	return out


## Its swamp at its full reach covers the cell of feet p (BroodNew.swamp_full; the swamp's own squashed circle,
## Game._update_swamp). margin: tiles kept in from its edge.
static func covers(g: Game, src: Unit, p: Vector2, margin := 0.0) -> bool:
	var a := BroodRoot.anchor(g, src) / Defs.TILE
	var c := g.cell_of(p)
	var dx := float(c.x) + 0.5 - a.x
	var dy := (float(c.y) + 0.5 - a.y) * 1.15
	var r := BroodNew.swamp_full(src) - margin
	return dx * dx + dy * dy <= r * r


## The Rootmaws side t has or has on the way (rooting, rooted, a cocoon; one walking to root, a grub going to turn into
## one, one the computer got up to fight that keeps its spot): [unit, feet]. Not `skip`, not one on its way up.
static func maws_of(g: Game, t: int, skip: Unit = null) -> Array:
	var out: Array = []
	for u in g.units:
		if u == skip or u.team != t or u.dead:
			continue
		var pl := BroodRoot.plan_of(u)
		if not pl.is_empty():
			if String(pl[0]) == BroodNew.MAW:
				out.append([u, pl[1] as Vector2])
			continue
		if u.kind == BroodNew.MAW and u.tesla_mode != "packed" and u.tesla_mode != "packing":
			out.append([u, u.position])
	return out


## Which swamp each Rootmaw belongs to: {source instance id: [count, cap, source]}, "maw" -> {unit id: source id}.
## A Rootmaw on several swamps belongs to the one with the most room left (then the nearest middle); one on none
## belongs to none. Worked out in the order of g.units (the same on every machine).
static func assign(g: Game, t: int, skip: Unit = null) -> Dictionary:
	var out := {}
	var srcs := sources(g, t)
	for s in srcs:
		out[s.get_instance_id()] = [0, cap_of(s), s]
	var of := {}
	for e in maws_of(g, t, skip):
		var best: Unit = null
		var room := -999
		for s in srcs:
			if not covers(g, s, e[1]):
				continue
			var r: int = int(out[s.get_instance_id()][1]) - int(out[s.get_instance_id()][0])
			if r > room or (r == room and best != null and BroodRoot.anchor(g, s).distance_to(e[1]) < BroodRoot.anchor(g, best).distance_to(e[1])):
				best = s
				room = r
		if best != null:
			out[best.get_instance_id()][0] = int(out[best.get_instance_id()][0]) + 1
			of[(e[0] as Unit).get_instance_id()] = best.get_instance_id()
	out["maw"] = of
	return out


## [count, cap] of the swamp source u (a Mother or a turtle); [0, 0] for anything else.
static func count_at(g: Game, u: Unit) -> Array:
	if u == null or not (u.kind == BroodNew.QUEEN or u.kind == BroodNew.TURTLE):
		return [0, 0]
	var a := assign(g, u.team)
	var e = a.get(u.get_instance_id())
	return [int(e[0]), int(e[1])] if e != null else [0, cap_of(u)]


## "ROOTMAWS 2/3" for the Mother's or a rooted turtle's card and bar ("" for anything else, or a turtle that is up).
static func label(g: Game, u: Unit) -> String:
	if u == null or u.dead or not (u.kind == BroodNew.QUEEN or u.kind == BroodNew.TURTLE) or not BroodNew.on(g, u.team):
		return ""
	if not sources(g, u.team).has(u):
		return ""
	var n := count_at(g, u)
	return Loc.t("ROOTMAWS %d/%d") % [n[0], n[1]]


static var _ac_key: Array = []
static var _ac := {}


## Why a Rootmaw of side t can't root with its feet at p for the count ("" = it can): every swamp under it is full.
## Off every source's swamp it says nothing (the swamp rule says why). `me`: the one rooting (it does not count itself).
static func room_problem(g: Game, t: int, p: Vector2, me: Unit = null) -> String:
	var a: Dictionary
	if BroodRoot.in_batch(g, t):
		# (a search batch: nothing changes meanwhile, the count is worked out once per batch and `me`)
		var key := [BroodRoot._bt_n, me.get_instance_id() if me != null else 0]
		if _ac_key != key:
			_ac_key = key
			_ac = assign(g, t, me)
		a = _ac
	else:
		a = assign(g, t, me)
	var full: Unit = null
	for s in sources(g, t):
		if not covers(g, s, p):
			continue
		var e: Array = a[s.get_instance_id()]
		if int(e[0]) < int(e[1]):
			return ""
		if full == null:
			full = s
	if full == null:
		return ""
	if full.kind == BroodNew.QUEEN:
		return Loc.t("Full: the Brood Mother's swamp holds %d Rootmaws (%d/%d). Root a Mound Turtle for more.") % [cap_of(full), cap_of(full), cap_of(full)]
	return Loc.t("Full: a Mound Turtle's swamp holds %d Rootmaws (%d/%d). Root another turtle for more.") % [cap_of(full), cap_of(full), cap_of(full)]


# ------------------------------------------------------------------ the best spots

## The best free spots for the Rootmaws swamp source `src` still has room for, all of them together: [feet, ...], best
## first. Each spot is legal for a Rootmaw now (BroodRoot.place_problem as the computer asks it: the footprint, the
## level, the ramps and the lanes kept clear, clear of every Rootmaw circle and plan) and under the source's swamp at its
## full reach; together they are a circle's width apart (Defs.PIT_CLAIM x 2). Scored for open ground round the spot, the
## source's own level and region, and a short walk to it. When the full number can't fit, as many as fit.
## n < 0: the source's room (cap less the Rootmaws it has). Mirror-fair: the spots are looked for in side t's first-start
## frame (Game.sym_*) and snapped back, as the computer's spot finders do.
static func fit(g: Game, src: Unit, n := -1, skip: Unit = null) -> Array:
	var t := src.team
	if n < 0:
		var c := count_at(g, src)
		n = int(c[1]) - int(c[0])
	if n <= 0:
		return []
	var cands := candidates(g, src, skip)
	return pick(cands, n, _fixed(g, t, skip))


## Every Rootmaw circle on the map that a new one must keep clear of (any side's open Rootmaws; side t's plans).
static func _fixed(g: Game, t: int, skip: Unit = null) -> Array:
	var out: Array = []
	for u in g.units:
		if u == skip or u.dead:
			continue
		var pl: Array = BroodRoot.plan_of(u) if u.team == t else []
		if not pl.is_empty():
			if String(pl[0]) == BroodNew.MAW:
				out.append(pl[1] as Vector2)
			continue
		if u.kind == BroodNew.MAW and u.tesla_mode != "packed":
			out.append(u.position)
	return out


## The legal spots under src's swamp, scored: [[feet, score], ...] best first.
static func candidates(g: Game, src: Unit, skip: Unit = null) -> Array:
	var t := src.team
	var T := float(Defs.TILE)
	var full := BroodNew.swamp_full(src)
	var ck := BroodRoot.feet_k(g, t, src)          # (its feet in side t's first-start frame)
	var sc := g.sym_rect(t, g.cell_of(ck), Vector2i.ONE)
	var h := int(g.height[g.idx(g.cell_of(BroodRoot.anchor(g, src)))])
	var home := BroodRoot.home_region(g, src.position)
	var seen := {}
	var out: Array = []
	var ri := int(ceil(full)) + 1
	BroodRoot.batch_begin(g, t)
	for dy in range(-ri, ri + 1):
		for dx in range(-ri, ri + 1):
			var pr: Vector2 = ck + Vector2(dx, dy) * T
			var p := BroodRoot.sym_snap(g, t, BroodNew.MAW, pr)
			if seen.has(p):
				continue
			seen[p] = true
			if not covers(g, src, p) or not Rect2(Vector2.ZERO, Vector2(Game.W, Game.H) * T).grow(-T).has_point(p):
				continue
			if BroodRoot.place_problem(g, t, BroodNew.MAW, p, skip, true, 1.0, false) != "":
				continue
			var cc := g.cell_of(p)
			# open ground round it: the cells within 2 tiles walkable and on its level (grubs come and go on its flanks)
			var room := 0
			for ex in range(-2, 3):
				for ey in range(-2, 3):
					var c2 := cc + Vector2i(ex, ey)
					if g.in_map(c2) and g._walkable(c2) and int(g.height[g.idx(c2)]) == int(g.height[g.idx(cc)]):
						room += 1
			var d := p.distance_to(src.position) / T
			var s := float(room) * 1.0 - d * 0.35
			if int(g.height[g.idx(cc)]) != h:
				s -= 12.0
			if g.region_of(cc) != home:
				s -= 25.0
			# (a tiny tie-break by the frame's order, the same on both mirrored starts)
			out.append([p, s - float(out.size()) * 0.00001])
	BroodRoot.batch_end()
	out.sort_custom(func(a: Array, b: Array) -> bool: return float(a[1]) > float(b[1]))
	return out


## The best set of up to n candidates a circle's width apart (and from the fixed circles): the most spots first, then the
## highest total score. A small exhaustive search over the pool (n is 2 or 3).
static func pick(cands: Array, n: int, fixed: Array) -> Array:
	var apart := circle_r() * 2.0 * Defs.TILE
	var ok: Array = []
	for c in cands:
		if fixed.all(func(f: Vector2) -> bool: return f.distance_to(c[0]) >= apart):
			ok.append(c)
	var best := {"n": 0, "s": -INF, "set": []}
	_dfs(ok, 0, [], 0.0, n, apart, best)
	var out: Array = []
	for i in best["set"]:
		out.append(ok[i][0])
	return out


static func _dfs(ok: Array, from: int, cur: Array, s: float, n: int, apart: float, best: Dictionary) -> void:
	if cur.size() > int(best["n"]) or (cur.size() == int(best["n"]) and s > float(best["s"])):
		best["n"] = cur.size()
		best["s"] = s
		best["set"] = cur.duplicate()
	if cur.size() >= n:
		return
	for i in range(from, ok.size()):
		var p: Vector2 = ok[i][0]
		var fits := true
		for j in cur:
			if (ok[j][0] as Vector2).distance_to(p) < apart:
				fits = false
				break
		if not fits:
			continue
		cur.append(i)
		_dfs(ok, i + 1, cur, s + float(ok[i][1]), n, apart, best)
		cur.pop_back()


# ------------------------------------------------------------------ the marks

## A Rootmaw's circle (tiles): Defs.PIT_CLAIM.
static func circle_r() -> float:
	return r_test if r_test > 0.0 else float(Defs.PIT_CLAIM)


## Every spot to show for side t now: [{p, rank, src}] (rank 1 for each swamp's first spot, 2 for the rest).
static func spots_for(g: Game, t: int) -> Array:
	var out: Array = []
	var a := assign(g, t)
	for s in sources(g, t):
		if not BroodNew.rooted(s):
			continue          # (its swamp starts once it is rooted)
		var e: Array = a[s.get_instance_id()]
		var n := int(e[1]) - int(e[0])
		if n <= 0:
			continue
		var i := 0
		for p in fit(g, s, n):
			if BroodNew.on_swamp(g, t, p) or BroodNew.swamp_coming(g, t, p):
				out.append({"p": p, "rank": 1 if i == 0 else 2, "src": s})
				i += 1
	return out


## spots_for, kept while nothing that changes it has changed (the sources, every Rootmaw and plan, the grid): the marks
## and the Brood computer ask for the same answer.
static var _sc := {}


static func spots_cached(g: Game, t: int) -> Array:
	var key := str(g.solid_log.size()) + "|"
	for s in sources(g, t):
		key += "%d:%s:%d:%s;" % [s.get_instance_id(), str(s.position), int(BroodNew.rooted(s)), str(BroodNew.swamp_full(s))]
	for p in _fixed(g, t):
		key += str(p)
	var ck := [g.get_instance_id(), t]
	var e = _sc.get(ck)
	if e != null and String(e[0]) == key:
		return e[1]
	if _sc.size() > 16:
		_sc.clear()
	var got := spots_for(g, t)
	_sc[ck] = [key, got]
	return got


## Should the marks show at all: a Brood player (not watching, not the editor), Settings.rootmaw_spots on.
func active() -> bool:
	if not Settings.rootmaw_spots or game == null or game.edit_mode or game.demo or game.replay != null:
		return false
	return game.human >= 0 and game.human < game.n_players() and BroodNew.on(game, game.human)


func _placing_maw() -> bool:
	var ctl = game.controls if game else null
	if ctl == null or game.human < 0:
		return false
	var m := String(ctl.mode)
	return (m == "nb_root" or m == "nb_morph") and String(ctl.place_kind) == BroodNew.MAW


func _process(delta: float) -> void:
	if game == null:
		return
	var p := _placing_maw()
	_t -= delta
	if p != _placing or _t <= 0.0:
		_t = CHECK
		_placing = p
		refresh()


## What changes the marks: the side's sources (where, how far their swamp reaches), every Rootmaw and plan.
func _state_key() -> String:
	var t := game.human
	var k := str(_placing) + "|"
	for s in sources(game, t):
		k += "%d:%s:%d:%s;" % [s.get_instance_id(), str(s.position), int(BroodNew.rooted(s)), str(BroodNew.swamp_full(s))]
	for p in _fixed(game, t):
		k += str(p)
	return k


func refresh() -> void:
	var now: Array = []
	var key := "off"
	if active():
		key = _state_key()
		if key == _key:
			return
		now = spots_cached(game, game.human)
	if key != _key:
		_key = key
		shown = now
		queue_redraw()


func _draw() -> void:
	var T := float(Game.T)
	var sz: Vector2i = BroodRoot.fp(BroodNew.MAW)[0]
	var k := 1.6 if _placing else 1.0
	for s in shown:
		var best := int(s["rank"]) == 1
		var r := BroodRoot.rect_for(BroodNew.MAW, s["p"])
		var fill := (0.3 if best else 0.2) * k
		var edge := (0.85 if best else 0.6) * minf(k, 1.15)
		for y in sz.y:
			for x in sz.x:
				var cell := Rect2(r.position + Vector2(x, y) * T + Vector2(2, 2), Vector2(T - 4, T - 4))
				draw_rect(cell, Color(SHADE, fill * 0.6))
				draw_rect(cell, Color(GOLD, fill))
		draw_rect(r.grow(-1.0), Color(0, 0, 0, 0.35 * edge), false, 3.5)
		draw_rect(r.grow(-1.0), Color(GOLD, edge), false, 1.75 if best else 1.25)
		if _placing:
			# while placing: the circle it would drink from (no other Rootmaw may root inside it)
			draw_arc(s["p"], float(Defs.PIT_CLAIM) * T, 0, TAU, 72, Color(GOLD, 0.4 if best else 0.28), 2.0)


## The label on each mark (Game's overlay, as ExpansionSpots.draw_labels): zoomed in, or while placing a Rootmaw.
func draw_labels(ci: CanvasItem) -> void:
	if game.camera == null or not active():
		return
	var z := game.camera.zoom.x
	if z < ExpansionSpots.LABEL_ZOOM and not _placing:
		return
	var fs := clampi(int(round(ExpansionSpots.LABEL_PX / maxf(z, 0.3))), 7, 20)
	var font := UiStyle.bold_font()
	if _placing:
		# while placing a Rootmaw: each swamp's count over its Mother or turtle ("ROOTMAWS 2/3")
		for src: Unit in sources(game, game.human):
			var lt := label(game, src)
			if lt == "" or not game.view_rect.grow(200.0).has_point(src.position):
				continue
			var n := count_at(game, src)
			var full := int(n[0]) >= int(n[1])
			var lw := font.get_string_size(lt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			var lp := src.position + Vector2(-lw * 0.5, float(fs) * 1.6)
			var lpad := float(fs) * 0.35
			var lpill := Rect2(lp + Vector2(-lpad, -float(fs) * 0.85), Vector2(lw + lpad * 2.0, float(fs) * 1.15))
			ci.draw_rect(lpill, Color(0.08, 0.05, 0.0, 0.7))
			ci.draw_rect(lpill, Color(GOLD, 0.6), false, maxf(1.0, float(fs) / 12.0))
			ci.draw_string(font, lp, lt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 0.5, 0.42) if full else GOLD.lightened(0.4))
	var txt := Loc.t("ROOTMAW SPOT")
	var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	for s in shown:
		var r := BroodRoot.rect_for(BroodNew.MAW, s["p"])
		if not game.view_rect.grow(200.0).has_point(r.get_center()):
			continue
		var best := int(s["rank"]) == 1
		var p := Vector2(r.get_center().x - w * 0.5, r.end.y + float(fs) * 0.95)
		var a := 1.0 if _placing else (0.95 if best else 0.8)
		var pad := float(fs) * 0.35
		var pill := Rect2(p + Vector2(-pad, -float(fs) * 0.85), Vector2(w + pad * 2.0, float(fs) * 1.15))
		ci.draw_rect(pill, Color(0.08, 0.05, 0.0, 0.62 * a))
		ci.draw_rect(pill, Color(GOLD, 0.55 * a), false, maxf(1.0, float(fs) / 12.0))
		ci.draw_string(font, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(GOLD.lightened(0.4 if best else 0.2), a))


## The minimap's marks (hud.gd): small gold dots on the spots shown now.
func draw_on_minimap(ci: CanvasItem, m: Rect2) -> void:
	var k := m.size / (Vector2(Game.W, Game.H) * float(Game.T))
	for s in shown:
		var mid: Vector2 = m.position + (s["p"] as Vector2) * k
		var h := 2.0 if int(s["rank"]) == 1 else 1.5
		ci.draw_rect(Rect2(mid - Vector2(h, h), Vector2(h, h) * 2.0), Color(0, 0, 0, 0.6), false, 2.0)
		ci.draw_rect(Rect2(mid - Vector2(h, h), Vector2(h, h) * 2.0), Color(GOLD, 0.95 if int(s["rank"]) == 1 else 0.7), false, 1.0)
