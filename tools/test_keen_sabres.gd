extends SceneTree
## BALANCE: RAPTOR v HORSEMAN (balance-raptor-horseman, docs/balance_raptor_horseman.md, 2026-11-15). Sandbox, no computers.
##   numbers   Raptor 38 hp, speed 92, Pack Hunt +22 (114); Horseman 100 hp, 100 gold; Cuirassier 130 (+30)
##   keen      KEEN SABRES is researched at the Horse Breeder; a Horseman's sabre blow does 18 to a Raptor without it
##             (three blows to kill one) and 24 with it (two); a Clock Soldier (light) takes +6, a Brute (armoured)
##             and a building nothing more; the pistol shot is not changed; an Officer's sabre on foot is not changed
##   mount     mounting and dismounting keep the health SHARE: a full Officer (80) rides as a full Horseman (100) and
##             back; a half-health Horseman gets off as a half-health Officer; the armoured pair 110 <-> 130
##   godot --headless --fixed-fps 30 --script res://tools/test_keen_sabres.gd
var main: Node
var fails := 0


func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_go.call_deferred()


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _go() -> void:
	await process_frame
	main.start({"seed": 7, "map": "greenhold", "sandbox": true, "slots": [{"who": "you", "faction": "crown", "colour": 0, "side": 0},
		{"who": "easy", "faction": "brood", "colour": 1, "side": 1}]})
	var g: Game = main.game
	await create_timer(0.3).timeout
	g.hud.countdown = 0.0
	paused = false
	for a in g.ais:
		a.set_process(false)
		a.set_physics_process(false)
	var c := Vector2(Game.W, Game.H) * Game.T * 0.5

	# ---- numbers
	check(int(Defs.UNITS["raptor"]["hp"]) == 38 and int(Defs.UNITS["raptor"]["speed"]) == 92, "Raptor 38 health, speed 92")
	check(is_equal_approx(92.0 + float(Defs.RESEARCH["nb_pack_hunt"]["speed"]["raptor"]), 114.0)
		and float(Defs.RESEARCH["nb_pack_hunt"]["speed"]["tyrant_challenger"]) == 14.0 and float(Defs.RESEARCH["nb_pack_hunt"]["speed"]["tyrannosaur"]) == 11.0,
		"Pack Hunt: a Raptor 114 (faster than a Horseman's %d), the Challenger and the Sire unchanged" % int(Defs.UNITS["cuirassier"]["speed"]))
	check(int(Defs.UNITS["cuirassier"]["hp"]) == 100 and int(Defs.UNITS["cuirassier"]["cost"]) == 100
		and int(Defs.UNITS["cuirassier"]["hp"]) + int(Defs.ARMOURED["cuirassier"]["hp"]) == 130, "Horseman 100 health and 100 gold; the Cuirassier 130")
	var ks: Dictionary = Defs.RESEARCH["keen_sabres"]
	check(ks["at"] == "horse_breeder" and ks["faction"] == "crown" and float(ks["light"]) == 6.0, "KEEN SABRES at the Horse Breeder, +6 on light units")

	# ---- keen: the blows
	var rider: Unit = g._add_unit("cuirassier", 0, c)
	await process_frame
	var dummy := func(kind: String) -> Unit:
		var u: Unit = g._add_unit(kind, 1, c + Vector2(20, 0))
		u.max_hp = 1000.0
		u.hp = 1000.0
		return u
	var blow := func(e: Entity) -> float:
		var h := e.hp
		rider.mode = ""
		rider.run_t = 0.0
		rider._strike(e)
		return h - e.hp
	var rap: Unit = dummy.call("raptor")
	var cs: Unit = dummy.call("clock_soldier")
	var br: Unit = dummy.call("brute")
	await process_frame
	var r0: float = blow.call(rap)
	var b0: float = blow.call(br)
	g.players[0]["tech"]["keen_sabres"] = true
	var r1: float = blow.call(rap)
	var c1: float = blow.call(cs)
	var b1: float = blow.call(br)
	g.players[0]["tech"].erase("keen_sabres")
	var c0: float = blow.call(cs)
	check(is_equal_approx(r0, 18.0) and ceili(38.0 / r0) == 3, "without it: 18 a blow on a Raptor, three blows to kill one (%.0f)" % r0)
	check(is_equal_approx(r1, 24.0) and ceili(38.0 / r1) == 2, "with KEEN SABRES: 24 a blow, two blows kill a Raptor (%.0f)" % r1)
	check(is_equal_approx(c1 - c0, 6.0), "a Clock Soldier (light) takes 6 more (%.0f -> %.0f)" % [c0, c1])
	check(is_equal_approx(b1, b0), "a Brute (armoured) takes nothing more (%.0f -> %.0f)" % [b0, b1])
	g.players[0]["tech"]["keen_sabres"] = true
	var off: Unit = g._add_unit("dismounted", 0, c + Vector2(-20, 0))
	await process_frame
	var h0 := rap.hp
	off.mode = "bayonet"
	off._strike(rap)
	check(is_equal_approx(h0 - rap.hp, 18.0), "an Officer's sabre on foot is unchanged (%.0f)" % (h0 - rap.hp))

	# ---- mount: the health share across the saddle
	var o2: Unit = g._add_unit("dismounted", 0, c + Vector2(0, 80))
	var h2: Unit = g._add_unit("horse", 0, c + Vector2(10, 80))
	await process_frame
	o2.cmd_mount(h2)
	var t := 0.0
	while t < 8.0 and o2.kind != "cuirassier":
		await create_timer(0.25).timeout
		t += 0.25
	check(o2.kind == "cuirassier" and is_equal_approx(o2.max_hp, 100.0) and is_equal_approx(o2.hp, 100.0),
		"a full Officer (80) mounts as a full Horseman (%s %.0f/%.0f)" % [o2.kind, o2.hp, o2.max_hp])
	o2.hp = 50.0
	o2.cmd_dismount()
	t = 0.0
	while t < 6.0 and o2.kind != "dismounted":
		await create_timer(0.25).timeout
		t += 0.25
	check(o2.kind == "dismounted" and is_equal_approx(o2.max_hp, 80.0) and absf(o2.hp - 40.0) < 0.6,
		"a half-health Horseman gets off as a half-health Officer (%s %.1f/%.0f)" % [o2.kind, o2.hp, o2.max_hp])
	o2.put_on_armour()
	check(is_equal_approx(o2.max_hp, 110.0), "an Armoured Officer has 110 (%.0f)" % o2.max_hp)
	o2.morph("cuirassier")
	check(is_equal_approx(o2.max_hp, 130.0) and o2.armoured, "and rides as a Cuirassier with 130 (%.0f)" % o2.max_hp)
	print("RESULT %s (%d failed)" % ["PASS" if fails == 0 else "FAIL", fails])
	quit(1 if fails > 0 else 0)

