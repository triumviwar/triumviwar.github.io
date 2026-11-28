extends RefCounted
## AI FIXES B, the measure (job ai-fixes-b, docs/ai_fixes_b.md). A measuring tool only: tools/qa_match.gd calls tick()
## once a second and puts report() into result.json "afb". It changes no rule.
##  WHEELS: every Field Cannon, Mortar and Powder Wagon of every side, every second it has somewhere to go (a move or
##    attack-move order more than 48 px from its point, or an attack on a target out of reach; not waiting for its path,
##    not packing or deploying): a "stuck second" when it moved under 6 px in the last 2 s (as tools/test_pathing_match.gd).
##    Runs of 10 s or more are kept with the cell, the kind, the order, whether limbered, and the ground round it.
##  HOME: every Crown hall BELOW its main's level (the natural, the third...) with 200+ of enemy army within HOME_R:
##    an episode, until the enemy near is under 100 for 20 s or the hall falls. Kept: the enemy at its peak, the Crown's
##    army in all and near the hall, the value each side lost within LOSS_R of the hall, the hall standing or not.

const WHEELS := ["cannon", "mortar", "powder_wagon"]
const HOME_R := 520.0
const LOSS_R := 760.0
const NEAR_R := 640.0

var g: Game
var qa = null                 # the qa_match tree (its _stuck_dbg for the ground round a stuck gun)
var n := 2
var _hist := {}               # unit id -> [positions of the last 3 s]
var _run := {}                # unit id -> seconds in the current stuck run
var wheel_s := {}             # team -> wheeled unit-seconds with somewhere to go
var stuck_s := {}             # team -> stuck seconds
var gun_ids := {}             # team -> {id: true} every wheeled unit seen
var runs: Array = []          # stuck runs of 10 s or more
var _last := {}               # unit id -> [team, value, pos] last second (for losses)
var losses: Array = []        # this second's deaths: [team, value, pos]
var _ep := {}                 # hall id -> open episode
var episodes: Array = []
var main_h := {}              # team -> main level


func _init(game: Game, tree, players: int) -> void:
	g = game
	qa = tree
	n = players
	for tm in n:
		wheel_s[tm] = 0.0
		stuck_s[tm] = 0.0
		gun_ids[tm] = {}


func tick() -> void:
	_losses()
	_wheels()
	_home()


func _losses() -> void:
	losses.clear()
	var now := {}
	for u in g.units:
		if u.dead or u.team < 0 or u.team >= n or u.off_field or u.is_worker() or not u.has_attack():
			continue
		if u._k_nb and (u.kind == BroodNew.QUEEN or BroodNew.rooted(u)):
			continue
		now[u.get_instance_id()] = [u.team, Game.unit_value(u), u.position]
	for id in _last:
		if not now.has(id):
			losses.append(_last[id])
	_last = now


func _wants_move(u: Unit) -> bool:
	if u.path_pending:
		return false
	if u.tesla_mode == "packing" or u.tesla_mode == "deploying":
		return false
	if u.order == "move" or u.order == "amove":
		if u.order == "amove" and u.target != null and is_instance_valid(u.target) and not u.target.dead:
			return false
		return u.position.distance_to(u.order_point) > 48.0
	if u.order == "attack" and u.target != null and is_instance_valid(u.target) and not u.target.dead:
		if u.kind == "powder_wagon":
			return false
		return u.target.edge_distance(u.position) > float(u.d.get("range", 0.0)) + 20.0
	return false


func _wheels() -> void:
	for u in g.units:
		if u.dead or u.team < 0 or u.team >= n or not WHEELS.has(u.kind):
			continue
		var id: int = u.get_instance_id()
		gun_ids[u.team][id] = true
		var h: Array = _hist.get(id, [])
		h.append(u.position)
		if h.size() > 3:
			h.pop_front()
		_hist[id] = h
		if not _wants_move(u) or h.size() < 3:
			_end_run(u, id)
			continue
		wheel_s[u.team] += 1.0
		if (h[0] as Vector2).distance_to(u.position) < 6.0:
			stuck_s[u.team] += 1.0
			_run[id] = float(_run.get(id, 0.0)) + 1.0
			if is_equal_approx(float(_run[id]), 10.0):
				var rec := {"t": int(g.clock) - 10, "p": u.team, "kind": String(u.kind), "order": u.order,
					"mode": u.tesla_mode, "harness": u.harnessed, "at": [int(u.position.x / Defs.TILE), int(u.position.y / Defs.TILE)],
					"goal": [int(u.order_point.x / Defs.TILE), int(u.order_point.y / Defs.TILE)], "len": 10}
				if qa != null and qa.has_method("_stuck_dbg"):
					rec["dbg"] = qa._stuck_dbg(u)
				rec["why"] = _why(u)
				if OS.get_cmdline_user_args().has("afbdbg:1"):
					_dbg(u)
				runs.append(rec)
				u.set_meta("afb_run", runs.size() - 1)
		else:
			_end_run(u, id)


## What a gun stuck 10 s stands in, for finding the cause: its heading, the next waypoint, whether its body and team are
## clear where it stands and toward the waypoint, the units pressing on it.
func _why(u: Unit) -> Dictionary:
	var wp: Vector2 = u.path[u.path_i] if u.path_i < u.path.size() else u.path_goal
	var to: Vector2 = (wp - u.position).normalized() if wp != Vector2.INF and wp.distance_to(u.position) > 0.5 else Vector2.ZERO
	var own := 0
	var foe := 0
	for o in g.units_near(u.position, u.radius + 70.0):
		if o == u or o.dead or o.is_air():
			continue
		if o.team == u.team:
			own += 1
		else:
			foe += 1
	var towed: bool = u._towed()
	return {"face": [snappedf(u.facing.x, 0.01), snappedf(u.facing.y, 0.01)], "to": [snappedf(to.x, 0.01), snappedf(to.y, 0.01)],
		"vel": snappedf(u.velocity.length(), 0.1), "push": snappedf(u._push.length(), 0.1), "stuck_t": snappedf(u.stuck_t, 0.1),
		"towed": towed, "horses": u.horse_count() if u.has_method("horse_count") else 0,
		"clear_here": u._tow_clear(u.position, u.facing) if towed else g._clear_at(u.position, u.ground_r(), u.team),
		"clear_turn": u._tow_clear(u.position, to) if towed and to != Vector2.ZERO else true,
		"clear_ahead": u._tow_clear(u.position + to * 6.0, u.facing) if towed and to != Vector2.ZERO else true,
		"own_near": own, "foe_near": foe, "path": u.path.size(), "path_i": u.path_i,
		"wp": [int(wp.x / Defs.TILE), int(wp.y / Defs.TILE)] if wp != Vector2.INF else [], "work": String(u.work),
		"supplying": bool(u.supplying) if "supplying" in u else false, "squeezed": u.squeezed}


## (afbdbg:1) everything about a gun stuck 10 s, printed: where in its cell, its fold, the step it wants and why each try fails.
func _dbg(u: Unit) -> void:
	var c: Vector2i = g.cell_of(u.position)
	var wp: Vector2 = u.path[u.path_i] if u.path_i < u.path.size() else u.path_goal
	var to: Vector2 = (wp - u.position).normalized()
	var step: Vector2 = u.position + to * 4.0
	print("AFBDBG t %.0f %s cell %s off %s face %s fold %.2f wp %s to %s body_here %s body_step %s tow_step %s tow_turn_here %s corner %s units %s" % [
		g.clock, u.kind, str(c), str((u.position - g.cell_center(c)).round()), str(u.facing.snapped(Vector2(0.01, 0.01))),
		float(u.get("tow_fold")) if u.get("tow_fold") != null else -1.0, str(g.cell_of(wp)), str(to.snapped(Vector2(0.01, 0.01))),
		g._clear_at(u.position, u._tow_body(), u.team), g._clear_at(step, u._tow_body(), u.team), u._tow_clear(step, u.facing),
		u._tow_clear(u.position, to), g._wall_corner(u.position, step, u.team),
		str(g.units_near(u.position, 40.0).filter(func(o) -> bool: return o != u and not o.dead).map(func(o) -> String: return "%s:%s:%s" % [o.kind, o.order, str((o.position - u.position).round())]))])
	for dy in range(-2, 3):
		var row := ""
		for dx in range(-2, 3):
			var q := c + Vector2i(dx, dy)
			row += str(g.solid[g.idx(q)]) if g.in_map(q) else " "
		print("AFBDBG   " + row)


func _end_run(u: Unit, id: int) -> void:
	if _run.has(id) and float(_run[id]) >= 10.0 and u.has_meta("afb_run"):
		runs[int(u.get_meta("afb_run"))]["len"] = int(_run[id])
		u.remove_meta("afb_run")
	_run.erase(id)


func _main_level(tm: int) -> int:
	if main_h.has(tm):
		return int(main_h[tm])
	if tm >= g.starts.size():
		return -1
	var c: Vector2i = g.starts[tm]
	if not g.in_map(c):
		return -1
	main_h[tm] = int(g.height[g.idx(c)])
	return int(main_h[tm])


func _foe_near(tm: int, p: Vector2, r: float) -> float:
	var v := 0.0
	for o in g.units_near(p, r):
		if o.dead or o.off_field or o.team < 0 or not g.hostile(o.team, tm) or o.is_worker() or not o.has_attack():
			continue
		if o._k_nb and (o.kind == BroodNew.QUEEN or BroodNew.rooted(o)):
			continue
		v += Game.unit_value(o)
	return v


func _own_near(tm: int, p: Vector2, r: float) -> float:
	var v := 0.0
	for o in g.units_near(p, r):
		if o.dead or o.off_field or o.team != tm or o.is_worker() or not o.has_attack():
			continue
		v += Game.unit_value(o)
	return v


func _army(tm: int) -> float:
	var v := 0.0
	for u in g.army(tm):
		if not u.is_worker() and u.has_attack():
			v += Game.unit_value(u)
	return v


func _home() -> void:
	for tm in n:
		if g.faction_of(tm) != "crown" or g.eliminated[tm]:
			continue
		var mh := _main_level(tm)
		for b in g.halls_of(tm):
			if b.dead or g.level_of(b.center()) >= mh:
				continue
			var id: int = b.get_instance_id()
			var foe := _foe_near(tm, b.center(), HOME_R)
			if not _ep.has(id):
				if foe >= 200.0:
					_ep[id] = {"t": int(g.clock), "p": tm, "hall": b, "at": [int(b.center().x / Defs.TILE), int(b.center().y / Defs.TILE)],
						"foe0": int(foe), "foe_max": int(foe), "army0": int(_army(tm)), "near_max": 0, "near_end": 0,
						"lost_own": 0, "lost_foe": 0, "quiet": 0, "bld0": int(g.stats[tm]["bld_lost"])}
				continue
		for id in _ep.keys():
			var e: Dictionary = _ep[id]
			if int(e["p"]) != tm:
				continue
			var b: Building = e["hall"]
			var c: Vector2 = Vector2(e["at"][0], e["at"][1]) * Defs.TILE + Vector2(Defs.TILE, Defs.TILE) * 0.5
			for l in losses:
				if (l[2] as Vector2).distance_to(c) > LOSS_R:
					continue
				if int(l[0]) == tm:
					e["lost_own"] = int(e["lost_own"]) + int(l[1])
				elif g.hostile(int(l[0]), tm):
					e["lost_foe"] = int(e["lost_foe"]) + int(l[1])
			var dead: bool = not is_instance_valid(b) or b.dead
			var foe := 0.0 if dead else _foe_near(tm, c, HOME_R)
			e["foe_max"] = maxi(int(e["foe_max"]), int(foe))
			var near := _own_near(tm, c, NEAR_R)
			e["near_max"] = maxi(int(e["near_max"]), int(near))
			e["quiet"] = int(e["quiet"]) + 1 if foe < 100.0 else 0
			if dead or int(e["quiet"]) >= 20:
				_close(id, dead)


func _close(id: int, dead: bool) -> void:
	var e: Dictionary = _ep[id]
	_ep.erase(id)
	var tm: int = int(e["p"])
	e.erase("hall")
	e["t1"] = int(g.clock)
	e["hall_lost"] = dead
	e["bld_lost"] = int(g.stats[tm]["bld_lost"]) - int(e["bld0"])
	e.erase("bld0")
	e.erase("quiet")
	e["won"] = not dead and int(e["lost_foe"]) >= int(e["lost_own"])
	episodes.append(e)


func report() -> Dictionary:
	for id in _ep.keys():
		var e: Dictionary = _ep[id]
		var b = e["hall"]
		_close(id, not is_instance_valid(b) or b.dead)
	for u in g.units:
		if not u.dead and WHEELS.has(u.kind):
			_end_run(u, u.get_instance_id())
	var w := {}
	for tm in n:
		w[str(tm)] = {"guns": (gun_ids[tm] as Dictionary).size(), "moving_s": int(wheel_s[tm]), "stuck_s": int(stuck_s[tm])}
	return {"wheels": w, "runs": runs, "home": episodes}
