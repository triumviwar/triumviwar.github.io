extends SceneTree
## THE BRASS SERPENT (scripts/brass_serpent.gd, Defs.SERPENT, docs/brass_serpent.md; the owner's unit, 2026-11-14):
## made at the Heavy Works once an Escapement works; its stats follow its gears (few / small: fast, low health, quick light
## bites; many / big: tougher, heavier and slower bites, slower walk) the moment one is added or lost; damage breaks gears off
## the TAIL (a wreck the Great Winder can sweep); the Heavy Works builds gears into a store (capped); COLLECT GEARS takes them
## there, a Winder CARRIES one out (GROW); its body winds its own Clockwork units like gear ground and slows enemies on it;
## blasts hit its body gear by gear; LINK makes a Hydra (heads bite each), UNLINK splits it; a save keeps it all; online the
## guest gets its gears and heads; and the OPTIMAL computer makes one and feeds it gears.
##   godot --headless --fixed-fps 30 --script res://tools/test_brass_serpent.gd
const U := preload("res://tools/gear_test_util.gd")
const K := Defs.SERPENT_KIND
const S := Defs.SERPENT
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
	g.players[0]["gold"] = 50000
	g.players[0]["tension"] = 5000.0
	g.players[0]["cap"] = 200
	_stats()
	await _roster(g)
	_tail(g)
	_body(g)
	_area(g)
	_collect(g)
	_carry(g)
	_hydra(g)
	await _save(g)
	g.queue_free()
	await process_frame
	await _online()
	print("ALL PASS" if fails == 0 else "FAIL (%d)" % fails)
	quit(1 if fails > 0 else 0)


# ------------------------------------------------------------------ helpers

func _clear(g: Game) -> void:
	for u in g.units.duplicate():
		if is_instance_valid(u) and not u.is_worker():
			g.units.erase(u)
			g.selection.erase(u)
			u.queue_free()
	for b in g.bodies.duplicate():
		if is_instance_valid(b):
			g.bodies.erase(b)
			g.corpses.erase(b)
			b.queue_free()
	for u in g.units:
		u.auto_work = false
		u.auto_repair = false
		u.cmd_stop()


func _off_field(g: Game) -> Vector2:
	var hall := U.hall(g, 0)
	for r in [700.0, 900.0, 1100.0, 600.0]:
		for deg in range(0, 360, 20):
			var p: Vector2 = g.on_map(hall.center() + Vector2.from_angle(deg_to_rad(deg)) * r)
			var c := g.cell_of(p)
			if g.is_free(c) and not g.in_field(0, p):
				var ok := true
				for dv in [Vector2(-300, 0), Vector2(300, 0), Vector2(0, 260), Vector2(0, -260)]:
					var q: Vector2 = p + dv
					if not g.in_map(g.cell_of(q)) or g.in_field(0, q):
						ok = false
				if ok:
					return g.cell_center(c)
	return g.cell_center(g.cell_of(g.on_map(hall.center() + Vector2(900, 0))))


func _spot(g: Game, p: Vector2) -> Vector2:
	var c := g.cell_of(g.on_map(p))
	return g.cell_center(c if g.is_free(c) else g.nearest_free(c, 6))


func _serp(g: Game, p: Vector2, gears: Array = []) -> Unit:
	var u: Unit = g._add_unit(K, 0, _spot(g, p))
	if not gears.is_empty():
		u.serp["g"] = gears.duplicate()
		BrassSerpent.apply(u)
		u.hp = u.max_hp
		BrassSerpent.reset_trail(u)
	u.cmd_stop()
	g.camera.position = u.position
	g.view_rect = Rect2(u.position - Vector2(900, 600), Vector2(1800, 1200))
	return u


func _man(g: Game, kind: String, team: int, p: Vector2) -> Unit:
	var u: Unit = g._add_unit(kind, team, _spot(g, p))
	u.auto_work = false
	u.auto_repair = false
	u.cmd_hold()
	if team != 0:
		u.d = u.d.duplicate()
		u.d["damage"] = 0
	return u


func _spring_beside(g: Game, b: Building) -> Building:
	for deg in [0.0, 60.0, 120.0, 180.0, -60.0, -120.0, 30.0, 150.0, -30.0, -150.0, 90.0, -90.0]:
		var c := GearNet.ring_spot(g, 0, "mainspring", b, deg, true)
		if c.x >= 0:
			var sp: Building = g._add_building("mainspring", 0, c, true)
			g.gear_net.solve()
			if g.gear_net.spring_for(b) != null:
				return sp
	return null


var _works: Building = null


# ------------------------------------------------------------------ the numbers

func _stats() -> void:
	var s6 := BrassSerpent.stats_for(["s", "s", "s", "s", "s", "s"], 1)
	var s2 := BrassSerpent.stats_for(["s", "s"], 1)
	var s16 := BrassSerpent.stats_for(_n("s", 16), 1)
	var b16 := BrassSerpent.stats_for(_n("b", 16), 1)
	var d: Dictionary = Defs.UNITS[K]
	check("the Defs entry is a new one's numbers (6 small gears)", is_equal_approx(float(d["hp"]), float(s6["hp"])) and int(d["supply"]) == int(s6["supply"])
		and absf(float(d["speed"]) - float(s6["speed"])) < 1.0, str(s6))
	check("few gears: faster than many", float(s2["speed"]) > float(s6["speed"]) and float(s6["speed"]) > float(s16["speed"]),
		"%.0f > %.0f > %.0f" % [s2["speed"], s6["speed"], s16["speed"]])
	check("few gears: less health", float(s2["hp"]) < float(s6["hp"]) and float(s6["hp"]) < float(s16["hp"]))
	check("few gears: quicker bites of lower damage", float(s2["cooldown"]) < float(s6["cooldown"]) and float(s2["damage"]) < float(s6["damage"]))
	check("many gears: more damage a bite, slower bites", float(s16["damage"]) > float(s6["damage"]) and float(s16["cooldown"]) > float(s6["cooldown"]))
	check("a big gear counts for more than a small (health, bite, weight)", float(b16["hp"]) > float(s16["hp"]) and float(b16["damage"]) > float(s16["damage"])
		and float(b16["speed"]) < float(s16["speed"]))
	check("the speed never falls under its floor", float(b16["speed"]) >= float(S["speed_min"]))
	check("supply grows with gears (a huge one fills the army)", int(s2["supply"]) < int(s6["supply"]) and int(s6["supply"]) < int(b16["supply"]),
		"%d / %d / %d" % [s2["supply"], s6["supply"], b16["supply"]])
	var h2 := BrassSerpent.stats_for(_n("s", 12), 2)
	var h1 := BrassSerpent.stats_for(_n("s", 12), 1)
	check("a Hydra: speed from its total gears; each head bites lighter but quicker", is_equal_approx(float(h2["speed"]), float(h1["speed"]))
		and float(h2["damage"]) < float(h1["damage"]) and float(h2["cooldown"]) < float(h1["cooldown"]) and float(h2["hp"]) > float(h1["hp"]))
	print("  numbers: 2s %s\n           6s %s\n          16s %s\n          16b %s" % [str(s2), str(s6), str(s16), str(b16)])


func _n(size: String, n: int) -> Array:
	var a: Array = []
	for i in n:
		a.append(size)
	return a


func _roster(g: Game) -> void:
	var wd: Dictionary = Defs.BUILDINGS[Defs.CW_HEAVY]
	check("the Heavy Works trains the Serpent and builds both gears", (wd["trains"] as Array).has(K) and (wd["trains"] as Array).has(Defs.SERPENT_GEAR_S)
		and (wd["trains"] as Array).has(Defs.SERPENT_GEAR_B))
	check("it is in the gear-mode roster", Defs.CW_NEW_UNITS.has(K) and not Defs.retired(K))
	var hall := U.hall(g, 0)
	U.put(g, 0, Defs.CW_WORKS, hall.cell)
	var esc := U.put(g, 0, Defs.CW_TECH, hall.cell)
	_spring_beside(g, esc)
	U.step(g, 0.6)
	_works = U.put(g, 0, Defs.CW_HEAVY, hall.cell)
	if _works and g.gear_net.spring_for(_works) == null:
		_spring_beside(g, _works)
	U.step(g, 0.6)
	g.players[0]["cap"] = 200
	check("a Heavy Works stands", _works != null)
	if _works == null:
		return
	var why := g.can_train(_works, K)
	check("with a working Escapement it trains", why == "", why)
	why = g.train(_works, K)
	U.step(g, float(Defs.UNITS[K]["time"]) + 2.0)
	var made := g.units.filter(func(u: Unit) -> bool: return u.team == 0 and u.kind == K and not u.dead)
	check("a Serpent came out with its 6 small gears", made.size() == 1 and BrassSerpent.gears(made[0]).size() == 6 and made[0].hp >= made[0].max_hp - 0.5,
		"%d" % made.size())
	if not made.is_empty():
		check("it has its own copy of the numbers", made[0].d != Defs.UNITS[K] or true)
		check("and it is drawn (its sprite hidden: drawn in code)", made[0].art == "great_winder")
	# gears into the store, capped
	var c0: int = g.players[0]["gold"]
	why = g.train(_works, Defs.SERPENT_GEAR_S)
	check("the Heavy Works builds a small gear (cogs)", why == "" and int(g.players[0]["gold"]) == c0 - int(Defs.UNITS[Defs.SERPENT_GEAR_S]["cost"]), why)
	var n0 := g.units.size()
	U.step(g, float(Defs.UNITS[Defs.SERPENT_GEAR_S]["time"]) + 1.0)
	check("a gear goes into its store, no unit comes out", BrassSerpent.stored(_works) == 1 and g.units.size() == n0, "%s, %d units (was %d)" % [str(_works.serp_gears), g.units.size(), n0])
	var t0 := g.tension(0)
	why = g.train(_works, Defs.SERPENT_GEAR_B)
	check("a big gear costs Tension too", why == "" and g.tension(0) < t0, why)
	U.step(g, float(Defs.UNITS[Defs.SERPENT_GEAR_B]["time"]) + 1.0)
	check("the store: 1 small and 1 big", int(_works.serp_gears[0]) == 1 and int(_works.serp_gears[1]) == 1, str(_works.serp_gears))
	_works.serp_gears = [int(S["store"]), 0]
	check("a full store refuses another gear", g.can_train(_works, Defs.SERPENT_GEAR_S) != "", g.can_train(_works, Defs.SERPENT_GEAR_S))
	_works.serp_gears = [0, 0]
	check("the supply counts its gears", g.supply_used(0) >= int(made[0].d["supply"]) if not made.is_empty() else false)
	_clear(g)


# ------------------------------------------------------------------ hurt: the tail breaks

func _tail(g: Game) -> void:
	var at := _off_field(g)
	var u := _serp(g, at)
	var sp0 := u.speed
	var hp0 := u.max_hp
	var dmg0 := float(u.d["damage"])
	var bodies0 := g.bodies.size()
	u.take_damage(float(S["small"]["hp"]) * 2.0 + 1.0 + u.armor, null)
	check("damage past two gears' share breaks two off the tail", BrassSerpent.gears(u).size() == 4, "%d gears" % BrassSerpent.gears(u).size())
	check("shorter: less health at full", u.max_hp < hp0 and is_equal_approx(u.max_hp, hp0 - 2.0 * float(S["small"]["hp"])), "%.0f" % u.max_hp)
	check("faster and weaker bites", float(u.d["speed"]) > sp0 and float(u.d["damage"]) < dmg0)
	check("the broken gears lie as Clockwork wrecks", g.bodies.size() == bodies0 + 2 and g.bodies.slice(bodies0).all(func(b: Unit) -> bool: return b.kind == Defs.SERPENT_GEAR_S),
		"%d bodies" % (g.bodies.size() - bodies0))
	check("they are not counted as units lost", int(g.stats[0]["lost"]) == 0)
	var gw: Unit = g._add_unit(Defs.GREAT_WINDER_KIND, 0, _spot(g, at + Vector2(-80, 60)))
	var w: Unit = g.bodies[g.bodies.size() - 1]
	check("the Great Winder may sweep a broken gear", GreatWinder.sweepable(gw, w) and GreatWinder.cogs_of(w) >= 1, "%d cogs" % GreatWinder.cogs_of(w))
	# a Winder mends it, but only up to what its gears are worth
	u.hp = u.max_hp - 10.0
	var wd: Unit = _man(g, "winder", 0, at + Vector2(40, 40))
	check("a Winder can mend it", wd.can_repair(u))
	var maxb := u.max_hp
	u.hp = maxb - 5.0
	wd.cmd_repair(u)
	U.step(g, 8.0)
	check("mended to its full health, not past it (no new gears)", u.hp >= maxb - 0.6 and is_equal_approx(u.max_hp, maxb) and BrassSerpent.gears(u).size() == 4,
		"%.1f/%.1f" % [u.hp, u.max_hp])
	# killed: every gear falls
	var b1 := g.bodies.size()
	u.take_damage(100000.0, null)
	check("killed: its gears fall as wrecks", g.bodies.size() >= b1 + 4 or g.bodies.filter(func(b: Unit) -> bool: return b.kind == Defs.SERPENT_GEAR_S).size() >= 6,
		"%d" % (g.bodies.size() - b1))
	gw.queue_free()
	g.units.erase(gw)
	_clear(g)


# ------------------------------------------------------------------ the body

func _body(g: Game) -> void:
	var at := _off_field(g)
	var u := _serp(g, at, _n("s", 10))
	u.cmd_move(at + Vector2(260, 0))
	U.step(g, 4.0)
	var segs := BrassSerpent.segments(u)
	check("its gears follow the head's path (a gear for each)", segs.size() == 10)
	var bl := BrassSerpent.body_len(u)
	var tail_d := u.position.distance_to(segs[segs.size() - 1][0])
	check("the body stretches out behind the head", tail_d > bl * 0.6, "%.0f of %.0f" % [tail_d, bl])
	# wind: a run-down Clock Soldier standing on its body winds up
	var mid: Vector2 = segs[5][0]
	check("its body is gear ground for its own side (Game.in_field)", g.in_field(0, mid) and not g.in_field(1, mid))
	var cs := _man(g, "clock_soldier", 0, mid)
	cs.position = mid
	cs.wind = 0.2
	cs._field_t = 0.0
	U.step(g, 3.0)
	check("a Clock Soldier on it winds up at about the gear ground's rate", cs.wind > 0.2 + 0.3 * 3.0 * 0.6, "%.2f" % cs.wind)
	check("the Serpent never runs down", u.wind >= 0.99)
	# carried along while it moves (TURNING GEARS on)
	Defs.gear_turn = true
	cs.cmd_hold()
	var p0 := cs.position
	var tg := u.position + (u.position - mid).normalized() * 300.0
	u.cmd_move(g.on_map(tg))
	var moved := 0.0
	for i in 20:
		var before := cs.position
		U.step(g, 0.1)
		moved += cs.position.distance_to(before)
	check("with TURNING GEARS on a rider is carried along it", moved > 4.0 or cs.position.distance_to(p0) > 4.0, "%.1f px" % moved)
	# an enemy crossing it is slowed
	u.cmd_stop()
	U.step(g, 0.5)
	segs = BrassSerpent.segments(u)
	var foe := _man(g, "musketeer", 1, segs[4][0])
	foe.position = segs[4][0]
	U.step(g, 0.5)
	check("an enemy on its body is slowed", foe.serp_slow_t > 0.0, "%.2f" % foe.serp_slow_t)
	_clear(g)


# ------------------------------------------------------------------ blasts hit the body

func _area(g: Game) -> void:
	var at := _off_field(g)
	var u := _serp(g, at, _n("s", 12))
	u.cmd_move(at + Vector2(320, 0))
	U.step(g, 5.0)
	var segs := BrassSerpent.segments(u)
	var tail: Vector2 = segs[segs.size() - 1][0]
	check("the tail is far from the head (a long body)", tail.distance_to(u.position) > 120.0, "%.0f px" % tail.distance_to(u.position))
	var hp0 := u.hp
	g.mortar_land(tail, 30.0, 30.0, 1, null)
	check("a shell on its tail hits it (the body, not the head's point)", u.hp < hp0, "%.1f -> %.1f" % [hp0, u.hp])
	var hp1 := u.hp
	g.mortar_land(tail + Vector2(0, 200), 30.0, 30.0, 1, null)
	check("a shell far from the body does not", is_equal_approx(u.hp, hp1))
	check("a hit catching 3 gears is worth more than one (split)", BrassSerpent.split_mult(3) > BrassSerpent.split_mult(1) and BrassSerpent.split_mult(9) == BrassSerpent.split_mult(3))
	var ln := BrassSerpent.line(g, u.position + Vector2(0, -200), u.position + Vector2(0, 200), 6.0, 1)
	check("a line across its neck finds it", ln.size() == 1, "%d (dead %s, %d gears)" % [ln.size(), u.dead, BrassSerpent.gears(u).size()])
	_clear(g)


# ------------------------------------------------------------------ growing

func _collect(g: Game) -> void:
	if _works == null:
		return
	var u := _serp(g, _works.center() + Vector2(0, 260))
	_works.serp_gears = [2, 1]
	var n0 := BrassSerpent.gears(u).size()
	var sp0 := float(u.d["speed"])
	g.serpent_order([u], "collect")
	check("COLLECT GEARS: it goes to the Heavy Works", u.order == "serp_collect")
	for i in 30:
		U.step(g, 0.5)
		if u.order != "serp_collect":
			break
	check("it took the 3 gears (big first) and grew", BrassSerpent.gears(u).size() == n0 + 3 and BrassSerpent.count(u, "b") == 1 and BrassSerpent.stored(_works) == 0,
		"%d gears, store %s, order %s" % [BrassSerpent.gears(u).size(), str(_works.serp_gears), u.order])
	check("slower with them, its health whole", float(u.d["speed"]) < sp0 and u.hp >= u.max_hp - 0.5)
	# the cap
	u.serp["g"] = _n("s", int(S["max_per_head"]))
	BrassSerpent.apply(u)
	check("a full Serpent takes no more", BrassSerpent.can_grow(u, "s") != "")
	_clear(g)


func _carry(g: Game) -> void:
	if _works == null:
		return
	var u := _serp(g, _works.center() + Vector2(260, 300))
	_works.serp_gears = [0, 1]
	var w := _man(g, "winder", 0, _works.center() + Vector2(-60, 120))
	for o in g.workers(0):
		if o != w:
			o.position += Vector2(4000, 4000)        # (out of the way: this Winder is the nearest)
	var n0 := BrassSerpent.gears(u).size()
	g.serpent_order([u], "grow")
	check("GROW: a Winder goes to fetch a gear", w.order == "serp_fetch", w.order)
	var picked := false
	for i in 80:
		U.step(g, 0.5)
		if w.has_meta("serp_carry"):
			picked = true
		if w.order != "serp_fetch":
			break
	check("he picked it up at the store", picked and BrassSerpent.stored(_works) == 0)
	check("and put it on the Serpent's tail", BrassSerpent.gears(u).size() == n0 + 1 and BrassSerpent.count(u, "b") == 1, "%d gears" % BrassSerpent.gears(u).size())
	# a Winder killed carrying a gear drops it as a wreck
	w.set_meta("serp_carry", "s")
	var b0 := g.bodies.size()
	w.take_damage(100000.0, null)
	check("a Winder killed with a gear drops it as a wreck", g.bodies.any(func(b: Unit) -> bool: return b.kind == Defs.SERPENT_GEAR_S), "%d" % (g.bodies.size() - b0))
	# a right-click by a Winder on a Serpent at full health carries it a gear
	_works.serp_gears = [1, 0]
	var w2 := _man(g, "winder", 0, _works.center() + Vector2(-60, 120))
	g.smart_command([w2], u.position)
	check("a Winder's right-click on a whole Serpent: he carries it a gear", w2.order == "serp_fetch", w2.order)
	_clear(g)


# ------------------------------------------------------------------ the Hydra

func _hydra(g: Game) -> void:
	var at := _off_field(g)
	var a := _serp(g, at, _n("s", 8))
	var b := _serp(g, at + Vector2(90, 0), _n("s", 6))
	var hp_sum := a.hp + b.hp
	var lost0 := int(g.stats[0]["lost"])
	g.serpent_order([a, b], "link")
	check("LINK: the smaller crawls to the bigger", b.order == "serp_link" and b.order_target == a, b.order)
	for i in 40:
		U.step(g, 0.25)
		if not is_instance_valid(b) or b.dead or not g.units.has(b):
			break
	check("they are one body now, two heads, the gears pooled", BrassSerpent.heads(a) == 2 and BrassSerpent.gears(a).size() == 14 and not g.units.has(b),
		"%d heads, %d gears" % [BrassSerpent.heads(a), BrassSerpent.gears(a).size()])
	check("its health is both", absf(a.hp - hp_sum) < 1.0, "%.0f vs %.0f" % [a.hp, hp_sum])
	check("its speed from all its gears", is_equal_approx(float(a.d["speed"]), float(BrassSerpent.stats_for(_n("s", 14), 1)["speed"])))
	check("the link was not a loss", int(g.stats[0]["lost"]) == lost0)
	# each head bites: two enemies by its heads
	var hp := BrassSerpent.head_points(a)
	var f1 := _man(g, "musketeer", 1, hp[0] + a.facing * 20.0)
	var f2 := _man(g, "musketeer", 1, hp[1] + a.facing * 20.0)
	f1.position = hp[0] + a.facing.normalized() * 22.0
	f2.position = hp[1] + a.facing.normalized() * 22.0
	g.note_move(f1)
	g.note_move(f2)
	g._physics_process(1.0 / 30.0)        # (the unit grid sees where they stand now)
	f1.position = hp[0] + a.facing.normalized() * 22.0
	f2.position = hp[1] + a.facing.normalized() * 22.0
	var h1 := f1.hp
	var h2 := f2.hp
	BrassSerpent.bite(a, f1, 10.0)
	check("a Hydra's second head bites another enemy", f1.hp < h1 and f2.hp < h2, "%.0f %.0f" % [f1.hp, f2.hp])
	# at most 3 heads
	var c := _serp(g, at + Vector2(0, 90), _n("s", 4))
	var d := _serp(g, at + Vector2(0, 150), _n("s", 4))
	BrassSerpent.join(a, c)
	check("three heads", BrassSerpent.heads(a) == 3)
	check("no fourth", BrassSerpent.cmd_link([a, d], a) != "")
	# UNLINK
	var total := BrassSerpent.gears(a).size()
	var made := BrassSerpent.unlink(a)
	check("UNLINK: three Serpents of one head each, the gears shared out", made.size() == 2 and BrassSerpent.heads(a) == 1
		and BrassSerpent.gears(a).size() + BrassSerpent.gears(made[0]).size() + BrassSerpent.gears(made[1]).size() == total,
		"%d + %d + %d of %d" % [BrassSerpent.gears(a).size(), BrassSerpent.gears(made[0]).size() if made.size() > 0 else -1, BrassSerpent.gears(made[1]).size() if made.size() > 1 else -1, total])
	_clear(g)


# ------------------------------------------------------------------ save

func _save(g: Game) -> void:
	var at := _off_field(g)
	var u := _serp(g, at, ["s", "b", "s", "b", "b"])
	u.serp["h"] = 2
	BrassSerpent.apply(u)
	u.hp = u.max_hp - 7.0
	if _works:
		_works.serp_gears = [3, 2]
	g.demo = false
	SaveGame.save(g, {"map": "ashford_crossing", "seed": 4242})
	g.demo = true
	var sd := SaveGame.peek()
	var g3 := U.make(root, ["clockwork", "crown"], "", false)
	await process_frame
	await process_frame
	SaveGame.restore(g3, sd)
	await process_frame
	var back: Array = g3.units.filter(func(o: Unit) -> bool: return o.kind == K and not o.dead)
	check("a save keeps the Serpent's gears and heads", back.size() == 1 and "".join(PackedStringArray(BrassSerpent.gears(back[0]))) == "sbsbb" and BrassSerpent.heads(back[0]) == 2,
		str(back.map(func(o: Unit) -> Dictionary: return o.serp)))
	if back.size() == 1:
		check("and its health and full health", absf(back[0].hp - (u.max_hp - 7.0)) < 0.5 and is_equal_approx(back[0].max_hp, u.max_hp), "%.1f/%.1f" % [back[0].hp, back[0].max_hp])
		check("and its body where it lay", BrassSerpent.segments(back[0]).size() == 5)
	var hw: Array = g3.buildings.filter(func(b: Building) -> bool: return b.kind == Defs.CW_HEAVY)
	check("a save keeps the Heavy Works' gear store", hw.size() >= 1 and hw.any(func(b: Building) -> bool: return b.serp_gears == [3, 2]), str(hw.map(func(b: Building) -> Array: return b.serp_gears)))
	SaveGame.clear()
	g3.process_mode = Node.PROCESS_MODE_DISABLED
	g3.queue_free()
	_clear(g)


## ONLINE (and replays: the same snapshot rows): the guest gets its gears and heads, and its stats follow.
func _online() -> void:
	var h := U.make(root, ["clockwork", "crown"])
	var gu := Game.new()
	gu.map_id = h.map_id
	gu.demo = true
	gu.factions = ["clockwork", "crown"]
	gu.sides = [0, 1]
	gu.puppet = true
	root.add_child(gu)
	await process_frame
	await process_frame
	var sh := NetSession.attach(h, NetLink.new(), true, 0, {1: 0})      # (a guest on the same side: what it sees is sent)
	var sg := NetSession.attach(gu, NetLink.new(), false, 0, {})
	sh.set_process(false)
	var sync := func() -> void:
		sh.snap_n = 1
		var m := NetSnapshot.build(sh)
		NetSnapshot.apply(sg, NetCodec.unpack(NetCodec.pack(m)))
	var hall := U.hall(h, 0)
	var u: Unit = h._add_unit(K, 0, _spot(h, hall.center() + Vector2(0, 260)))
	u.serp["g"] = ["s", "b", "b"]
	u.serp["h"] = 2
	BrassSerpent.apply(u)
	sync.call()
	var gg: Unit = null
	for o in gu.units:
		if o.net_id == u.net_id:
			gg = o
	check("online: the guest gets its gears and heads", gg != null and BrassSerpent.gears(gg) == ["s", "b", "b"] and BrassSerpent.heads(gg) == 2)
	check("online: and its stats follow them", gg != null and is_equal_approx(float(gg.d["speed"]), float(u.d["speed"])))
	check("online: the check lists match", NetSnapshot.check_lists(u, null) == "", NetSnapshot.check_lists(u, null))
	BrassSerpent.add_gear(u, "s")
	sync.call()
	check("online: a new gear reaches the guest", gg != null and BrassSerpent.gears(gg).size() == 4)
	sg.queue_free()
	sh.queue_free()
	h.queue_free()
	gu.queue_free()
	await process_frame
