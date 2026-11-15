extends SceneTree
## The Pendulum hits FLYERS (pendulum-air, owner 2026-11-15, docs/pendulum_air.md): every swing cuts every enemy flyer in
## its arc for Defs.PENDULUM_SWING "vs_air" (3/4) of the blow, the light bonus on top (a light flyer x0.75 x1.5), several
## at once, never its own flyers and never one behind it; it may pick a flyer as its target (can_hit, find_target: the
## nearest enemy, ground or air, so a nearer ground enemy first); ground enemies in the same arc still take the full blow.
##   godot --headless --fixed-fps 30 --script res://tools/test_pendulum_air.gd
const U := preload("res://tools/gear_test_util.gd")
var fails := 0


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-74s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var g := U.make(root)
	await process_frame
	await process_frame
	g.view_rect = Rect2(Vector2(-100000, -100000), Vector2(200000, 200000))
	var P := Defs.PENDULUM
	var d: Dictionary = Defs.UNITS[P]
	check("Defs: the Pendulum is anti-air, not ground only", bool(d.get("anti_air", false)) and not bool(d.get("ground_only", false)))
	check("Defs: flyers take 3/4 of the blow", absf(float(Defs.PENDULUM_SWING["vs_air"]) - 0.75) < 0.001)
	check("its card says it hits flyers", UnitStats._hits(P, d).has("air"), str(UnitStats._hits(P, d)))
	var hall := U.hall(g, 0)
	var at := _open_near(g, hall.center() + Vector2(0, 260))
	var pd: Unit = g._add_unit(P, 0, at)
	pd.cmd_stop()
	var polar := func(deg: float, dist: float) -> Vector2: return at + Vector2.from_angle(deg_to_rad(deg)) * dist
	# 1. a Balloon alone in front: it can hit it and picks it by itself
	var balloon: Unit = _foe(g, "balloon", polar.call(0.0, 44.0))
	for i in 3:
		U.step(g, 1.0 / 30.0)
	check("can_hit an enemy Balloon", pd.can_hit(balloon))
	check("finds the Balloon as its target when nothing else is near", g.find_target(pd, 200.0) == balloon)
	# a ground enemy nearer: it goes first (the nearest, ground or air)
	var sol: Unit = _foe(g, "musketeer", polar.call(-60.0, 34.0))
	sol.d = sol.d.duplicate()
	sol.d["damage"] = 0
	for i in 3:
		U.step(g, 1.0 / 30.0)
	check("a nearer ground soldier is picked first", g.find_target(pd, 200.0) == sol, str(g.find_target(pd, 200.0)))
	g.units.erase(sol)
	sol.queue_free()
	var lab: Unit = _foe(g, "labourer", polar.call(10.0, 30.0))
	# 2. one swing: the Balloon, three Hatchlings and an armoured Owl in the arc, the labourer on the ground, its own Swift
	# in the arc and an enemy Hatchling behind
	var hs: Array = []
	for a in [-25.0, 0.0, 25.0]:
		hs.append(_foe(g, "hatchlings", polar.call(a, 36.0)))
	var owl: Unit = _foe(g, "ticking_owl", polar.call(-15.0, 50.0))
	var own: Unit = g._add_unit("cuckoo", 0, _open_near(g, polar.call(15.0, 40.0)))
	own.cmd_hold()
	var behind: Unit = _foe(g, "hatchlings", polar.call(180.0, 40.0))
	var all: Array = [balloon, lab, owl, own, behind] + hs
	for o in all:
		o.max_hp = 5000.0
		o.hp = 5000.0
		o.d = o.d.duplicate()
		o.d["damage"] = 0
	pd.facing = Vector2.RIGHT
	pd.cmd_attack(balloon)
	var t := 0.0
	while pd.swings < 1 and t < 6.0:
		U.step(g, 1.0 / 30.0)
		t += 1.0 / 30.0
	check("it swung at the Balloon by itself (attack order)", pd.swings >= 1, "%.1f s" % t)
	check("and the Balloon took a blow", balloon.hp < 5000.0, "%.1f" % (5000.0 - balloon.hp))
	# (the flyers drift apart while it winds up: the arc test is one blow on the spot, Pendulum.swing as Unit._strike calls it)
	var spots := {balloon: polar.call(0.0, 44.0), owl: polar.call(-15.0, 50.0), own: polar.call(15.0, 40.0), behind: polar.call(180.0, 40.0),
			lab: polar.call(10.0, 30.0), hs[0]: polar.call(-25.0, 36.0), hs[1]: polar.call(0.0, 30.0), hs[2]: polar.call(25.0, 36.0)}
	for o in all:
		o.position = spots[o]
		o.hp = 5000.0
	pd.position = at
	g.note_move(pd)
	for o in all:
		g.note_move(o)
	Pendulum.swing(pd, balloon, float(d["damage"]))
	var dmg := float(d["damage"])
	var va := float(Defs.PENDULUM_SWING["vs_air"])
	var vl := float(Defs.PENDULUM_SWING["vs_light"])
	var got := func(o: Unit) -> float: return 5000.0 - o.hp
	var want_light_air := dmg * va * vl - balloon.armor
	check("the Balloon (light flyer) took 3/4 of the blow with the light bonus", absf(got.call(balloon) - want_light_air) < 0.6, "%.1f, want %.1f" % [got.call(balloon), want_light_air])
	var hok := hs.all(func(h: Unit) -> bool: return absf(got.call(h) - (dmg * va * vl - h.armor)) < 0.6)
	check("all three Hatchlings in the arc were cut at once, the same", hok, str(hs.map(func(h: Unit) -> float: return got.call(h))))
	var want_owl := dmg * va - owl.armor
	check("the armoured Ticking Owl took 3/4 of the blow, no light bonus", absf(got.call(owl) - want_owl) < 0.6, "%.1f, want %.1f" % [got.call(owl), want_owl])
	var want_lab := dmg * vl - lab.armor
	check("the labourer on the ground in the same arc took the full blow", absf(got.call(lab) - want_lab) < 0.6, "%.1f, want %.1f" % [got.call(lab), want_lab])
	check("its own Swift in the arc was not hit", got.call(own) == 0.0, "%.1f" % got.call(own))
	check("the enemy Hatchling behind it was not hit", got.call(behind) == 0.0, "%.1f" % got.call(behind))
	check("last_air_hits counted the flyers (5)", pd.last_air_hits == 5, str(pd.last_air_hits))
	check("Pendulum.blow_k: light flyer %.3f, ground light %.2f" % [Pendulum.blow_k(balloon), Pendulum.blow_k(lab)],
			absf(Pendulum.blow_k(balloon) - va * vl) < 0.001 and absf(Pendulum.blow_k(lab) - vl) < 0.001)
	# 3. a netted flyer is on the ground: the full blow (it is not in the air then)
	balloon.net_t = 3.0
	check("a netted flyer counts as on the ground (the full blow)", absf(Pendulum.blow_k(balloon) - vl) < 0.001)
	balloon.net_t = 0.0
	print("ALL PASS" if fails == 0 else "FAIL (%d)" % fails)
	quit(1 if fails else 0)


func _foe(g: Game, kind: String, p: Vector2) -> Unit:
	var u: Unit = g._add_unit(kind, 1, _open_near(g, p))
	u.auto_work = false
	u.cmd_hold()
	return u


func _open_near(g: Game, p: Vector2) -> Vector2:
	var c := g.cell_of(g.on_map(p))
	if g.is_free(c):
		return g.cell_center(c)
	return g.cell_center(g.nearest_free(c, 6))
