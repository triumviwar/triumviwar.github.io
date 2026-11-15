extends SceneTree
## escapement-research's bench (docs/escapement_research.md): what the Netter's reach does in a stand-up fight. 6 Netters
## + 10 Clock Soldiers attack-move on 12 Musketeers in a line with 2 Field Cannons behind them (holding, on open ground,
## no computers), the Netters' reach set to `range:` (180 = before 0.38.19, 150 = now, 240 = with LONG CHAIN).
##   godot --headless --fixed-fps 30 --script res://tools/bench_netter_range.gd -- range:150 [seed:0] [secs:120] [shield]
## `seed:` shifts the lines a little (several runs); `shield`: the Clock Soldiers have SHIELD WALL and raise it.
## Prints one line: BENCH range:<r> seed:<s> t:<s> | each side's units left, value lost | catches (nets that caught), enemies caught.
const U := preload("res://tools/gear_test_util.gd")
var rng := 150.0
var seed_i := 0
var secs := 120.0
var shield := false


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("range:"):
			rng = float(a.substr(6))
		elif a.begins_with("seed:"):
			seed_i = int(a.substr(5))
		elif a.begins_with("secs:"):
			secs = float(a.substr(5))
		elif a == "shield":
			shield = true
	_run.call_deferred()


func _run() -> void:
	var g := U.make(root, ["clockwork", "crown"])
	await process_frame
	await process_frame
	g.view_rect = Rect2(Vector2(-100000, -100000), Vector2(200000, 200000))
	g.explored.fill(1)
	if shield:
		g.players[0]["tech"]["shield_wall"] = true
	var hall := U.hall(g, 0)
	var at := _open_near(g, hall.center() + Vector2(0, 260))
	var sx := float(seed_i % 3 - 1) * 14.0
	var sy := float(seed_i / 3) * 12.0
	var mine: Array = []
	var theirs: Array = []
	var nets: Array = []
	for i in 10:
		var c := _add(g, "clock_soldier", 0, at + Vector2(-180 + i * 40 + sx, 0))
		mine.append(c)
	for i in 6:
		var n := _add(g, Defs.NETTER, 0, at + Vector2(-125 + i * 50 + sx, 70 + sy))
		n.d = n.d.duplicate(true)
		n.d["range"] = rng
		mine.append(n)
		nets.append(n)
	var line := at + Vector2(0, -560)
	for i in 12:
		var m := _add(g, "musketeer", 1, line + Vector2(-240 + i * 44, 0))
		m.cmd_hold()
		theirs.append(m)
	for i in 2:
		var cn := _add(g, "cannon", 1, line + Vector2(-120 + i * 240, -90))
		cn.cmd_hold()
		theirs.append(cn)
	for u in mine:
		u.cmd_move(line + Vector2(0, -60), true)          # (attack-move: a player's order)
		if shield and u.kind == "clock_soldier":
			u.set_shield(true)
	var v0 := [_value(mine), _value(theirs)]
	var t := 0.0
	var caught := {}
	var catches := 0
	var was := {}
	while t < secs:
		U.step(g, 0.25)
		t += 0.25
		for o in _alive(theirs):
			var c := Netter.caught(o)
			if c:
				caught[o] = true
				if not was.get(o, false):
					catches += 1
			was[o] = c
		if _alive(theirs).is_empty() or _alive(mine).is_empty():
			break
	var win := "clockwork" if _alive(theirs).is_empty() else ("crown" if _alive(mine).is_empty() else "none")
	print("BENCH range:%.0f seed:%d shield:%s t:%.0f win:%s | clockwork %d/%d left (netters %d/6), lost %d value | crown %d/%d left (cannons %d/2), lost %d value | catches %d, enemies caught %d" % [
			rng, seed_i, "on" if shield else "off", t, win, _alive(mine).size(), mine.size(), _alive(nets).size(), int(v0[0] - _value(mine)),
			_alive(theirs).size(), theirs.size(), _alive(theirs).filter(func(u: Unit) -> bool: return u.kind == "cannon").size(),
			int(v0[1] - _value(theirs)), catches, caught.size()])
	quit(0)


func _add(g: Game, kind: String, team: int, p: Vector2) -> Unit:
	var u: Unit = g._add_unit(kind, team, _open_near(g, p))
	u.auto_work = false
	return u


func _alive(a: Array) -> Array:
	return a.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)


func _value(a: Array) -> float:
	var s := 0.0
	for u in _alive(a):
		s += float(Game.unit_value(u))
	return s


func _open_near(g: Game, p: Vector2) -> Vector2:
	var c := g.cell_of(g.on_map(p))
	if g.is_free(c):
		return g.cell_center(c)
	return g.cell_center(g.nearest_free(c, 6))
