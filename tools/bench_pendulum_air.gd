extends SceneTree
## pendulum-air's bench (docs/pendulum_air.md): Clockwork Pendulums against enemy FLYERS, before (`pendair:off`, ground
## only) and after (flyers in the arc take 3/4 of the blow). One scripted fight on open ground, no computers:
##   balloon   2 Pendulums + 4 Winders at work under 2 Observation Balloons, 4 Musketeers aboard each, hovering (the
##             Crown's Balloon harass where it is caught: the Pendulums walk under them)
##   challenger 3 Pendulums v 4 Storm Challengers
##   sire      3 Pendulums v 2 Storm Sires
##   hatch     3 Pendulums + 3 Swifts v 10 Hatchlings (Hatchlings hit only flyers: they go for the Swifts over the Pendulums)
##   godot --headless --fixed-fps 30 --script res://tools/bench_pendulum_air.gd -- scen:challenger [pendair:off] [secs:90]
## Prints one line: BENCH <scen> air:<on/off> t:<s> | each side's units left, hp left, value lost.
const U := preload("res://tools/gear_test_util.gd")
var scen := "challenger"
var secs := 90.0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("scen:"):
			scen = a.substr(5)
		elif a.begins_with("secs:"):
			secs = float(a.substr(5))
	_run.call_deferred()


func _run() -> void:
	var foe_fac := "crown" if scen == "balloon" else "brood"
	var g := U.make(root, ["clockwork", foe_fac])
	await process_frame
	await process_frame
	g.view_rect = Rect2(Vector2(-100000, -100000), Vector2(200000, 200000))
	var hall := U.hall(g, 0)
	var at := _open_near(g, hall.center() + Vector2(0, 300))
	var mine: Array = []
	var theirs: Array = []
	var np := 2 if scen == "balloon" else 3
	for i in np:
		mine.append(_add(g, Defs.PENDULUM, 0, at + Vector2(-50 + i * 50, 0)))
	match scen:
		"balloon":
			for i in 4:
				var w := _add(g, "winder", 0, at + Vector2(-60 + i * 40, -80))
				w.cmd_hold()
				mine.append(w)
			for i in 2:
				var b := _add(g, "balloon", 1, at + Vector2(-40 + i * 80, -90))
				for j in 4:
					var m := _add(g, "musketeer", 1, b.position)
					b.take_aboard(m)
					theirs.append(m)
				b.cmd_hold()
				theirs.append(b)
			for p in mine:
				if p.kind == Defs.PENDULUM:
					p.cmd_move(at + Vector2(0, -90), true)
		"hatch":
			for i in 3:
				var s := _add(g, Defs.CUCKOO, 0, at + Vector2(-40 + i * 40, -10))
				s.cmd_hold()
				mine.append(s)
			for i in 10:
				theirs.append(_add(g, "hatchlings", 1, at + Vector2(-200 + i * 40, -420)))
		"challenger":
			for i in 4:
				theirs.append(_add(g, "storm_challenger", 1, at + Vector2(-90 + i * 60, -420)))
		"sire":
			for i in 2:
				theirs.append(_add(g, "pterodactyl", 1, at + Vector2(-60 + i * 120, -420)))
	if scen != "balloon":
		for o in theirs:
			o.cmd_move(at, true)
		for p in mine:
			if p.kind == Defs.PENDULUM:
				p.cmd_move(at + Vector2(0, -200), true)     # (they walk to meet them, attack-moving: a player's order)
	var v0 := [_value(mine), _value(theirs)]
	var t := 0.0
	var pend_hits := 0
	var swings := 0
	while t < secs:
		U.step(g, 0.5)
		t += 0.5
		if _alive(theirs).is_empty() or _alive(mine.filter(func(u: Unit) -> bool: return u.kind == Defs.PENDULUM)).is_empty():
			break
	for p in mine:
		if p.kind == Defs.PENDULUM:
			swings += p.swings
	print("BENCH %s air:%s t:%.0f | clockwork %d/%d left (hp %d), lost %d value | %s %d/%d left (hp %d), lost %d value | pendulum swings %d" % [
			scen, "on" if Pendulum.air_on else "off", t, _alive(mine).size(), mine.size(), int(_hp(mine)), int(v0[0] - _value(mine)),
			foe_fac, _alive(theirs).size(), theirs.size(), int(_hp(theirs)), int(v0[1] - _value(theirs)), swings])
	quit(0)


func _add(g: Game, kind: String, team: int, p: Vector2) -> Unit:
	var u: Unit = g._add_unit(kind, team, _open_near(g, p))
	u.auto_work = false
	return u


func _alive(a: Array) -> Array:
	return a.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)


func _hp(a: Array) -> float:
	var s := 0.0
	for u in _alive(a):
		s += u.hp
	return s


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
