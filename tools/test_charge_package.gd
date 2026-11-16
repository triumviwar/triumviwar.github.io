extends SceneTree
## THE CHARGE PACKAGE (cavalry-charge-package, the owner 2026-11-15 21:34; docs/cavalry_charge_package.md). Sandbox.
##   gone      no Keen Sabres anywhere: no research, no tooltip, no text in pt/es, no Horse Breeder button
##   charge    the Cavalry Charge is researched at the HORSE BREEDER (not the Armoury), 60 gold, 25 s
##   blow      a charged sabre blow: x2.2 on a light unit (one charge kills a 38-hp Raptor), x2 on an armoured one
##             (a Brute); a plain blow 18
##   swarm     the computer's riders (AICavMicro) don't wait round for the next charge against a fast melee swarm
##             (4+ Raptors near, Pack Hunt or not); against 2 Raptors or against Brutes they still do
##   price     an Officer + a horse == a Horseman (+ his horse) in gold and powder, the armoured pair too, by the
##             numbers and by real training at the Barracks / the Horse Breeder
##   godot --headless --fixed-fps 30 --script res://tools/test_charge_package.gd
var main: Node
var fails := 0


class StubAI:
	var team := 0
	var game = null
	func _on_errand(_u) -> bool:
		return false
	func _halls() -> Array:
		return []


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

	# ---- gone
	check(not Defs.RESEARCH.has("keen_sabres") and not Defs.TIPS.has("keen_sabres"), "no KEEN SABRES research or tooltip")
	var stale := 0
	for d in [LangPt.T, LangEs.T]:
		for k in d:
			if String(k).to_lower().contains("keen sabres") or String(d[k]).contains("AFIAD") or String(d[k]).contains("AFILAD"):
				stale += 1
	check(stale == 0, "no Keen Sabres text left in pt/es (%d)" % stale)
	check(not ResourceLoader.exists("res://assets/icons/research_keen_sabres.png"), "its stand-in icon is gone")

	# ---- charge: where it is researched
	var ch: Dictionary = Defs.RESEARCH["charge"]
	check(ch["at"] == "horse_breeder" and int(ch["cost"]) == 60 and float(ch["time"]) == 25.0, "the Cavalry Charge at the Horse Breeder, 60 gold, 25 s")
	g.players[0]["gold"] = 5000
	g.players[0]["res2"] = 500.0
	var cell: Vector2i = g.cell_of(c)
	var arm: Building = g._add_building("armoury", 0, cell + Vector2i(-14, -10), true)
	var brd: Building = g._add_building("horse_breeder", 0, cell + Vector2i(10, -10), true)
	var bar: Building = g._add_building("barracks", 0, cell + Vector2i(-14, 8), true)
	await process_frame
	check(g.research_problem(arm, "charge") != "", "the Armoury can't drill it (%s)" % g.research_problem(arm, "charge"))
	check(g.research_problem(brd, "charge") == "", "the Horse Breeder can (%s)" % g.research_problem(brd, "charge"))
	var btn := []
	g.hud._research_buttons(btn, brd)
	check(btn.size() == 1, "the Horse Breeder's card has one research button: the Charge (%d)" % btn.size())

	# ---- blow
	var rider: Unit = g._add_unit("cuirassier", 0, c)
	await process_frame
	var dummy := func(kind: String) -> Unit:
		var u: Unit = g._add_unit(kind, 1, c + Vector2(20, 0))
		u.max_hp = 1000.0
		u.hp = 1000.0
		return u
	var blow := func(e: Entity, run: float) -> float:
		var h := e.hp
		rider.mode = ""
		rider.run_t = run
		rider._strike(e)
		return h - e.hp
	var rap: Unit = dummy.call("raptor")
	var br: Unit = dummy.call("brute")
	await process_frame
	g.players[0]["tech"]["charge"] = true
	var r0: float = blow.call(rap, 0.0)
	var r1: float = blow.call(rap, 3.0)
	var b0: float = blow.call(br, 0.0)
	var b1: float = blow.call(br, 3.0)
	check(is_equal_approx(r0, 18.0), "a plain blow on a Raptor: 18 (%.1f)" % r0)
	check(is_equal_approx(r1, 18.0 * 2.2) and r1 >= 38.0, "a charged blow on a Raptor (light): x2.2 = %.1f, more than its 38" % r1)
	check(is_equal_approx(b1 - b0, 18.0), "a charged blow on a Brute (armoured): x2, one plain blow more (%.1f -> %.1f)" % [b0, b1])
	var real: Unit = g._add_unit("raptor", 1, c + Vector2(0, 26))
	await process_frame
	check(is_equal_approx(real.hp, 38.0), "a fresh Raptor has 38 (%.0f)" % real.hp)
	blow.call(real, 3.0)
	check(real.dead or real.hp <= 0.0, "one charge kills it (%.1f left)" % real.hp)
	g.players[0]["tech"].erase("charge")
	var r2: float = blow.call(rap, 3.0)
	check(r2 < 20.0, "without the drill no charge (%.1f: the plain blow, a little veterancy on it)" % r2)
	for u in [rap, br]:
		u.take_damage(99999.0, null)
	await physics_frame

	# ---- swarm: the micro's charge play
	g.players[0]["tech"]["charge"] = true
	var stub := StubAI.new()
	stub.game = g
	var mic := AICavMicro.new(stub)
	mic.on = true
	var far := c + Vector2(0, 600)
	var r2u: Unit = g._add_unit("cuirassier", 0, far)
	var two: Array = []
	for i in 2:
		two.append(g._add_unit("raptor", 1, far + Vector2(160, -20 + 40 * i)))
	for i in 3:
		await physics_frame
	check(mic._charge(r2u) and not mic._swarm(r2u), "2 Raptors: it still plays the charge")
	var more: Array = []
	for i in 6:
		more.append(g._add_unit("raptor", 1, far + Vector2(200 + 20 * (i % 3), -40 + 30 * i)))
	for i in 3:
		await physics_frame
	g.clock += 0.1
	check(mic._swarm(r2u) and not mic._charge(r2u) and not mic._wait_charge(r2u), "8 Raptors near: no waiting round for the charge (takes each blow as it comes)")
	g.players[1]["tech"]["nb_pack_hunt"] = true
	for x in two + more:
		x.speed = 114.0         # (Pack Hunt's pace; the research applies it to new ones)
	g.clock += 0.1
	check(mic._swarm(r2u), "with Pack Hunt too")
	mic.swarm_rule = false
	g.clock += 0.1
	check(mic._charge(r2u), "the study switch cavswarm:off plays the old charge loop")
	mic.swarm_rule = true
	for x in two + more:
		x.take_damage(99999.0, null)
	for i in 3:
		await physics_frame
	var brutes: Array = []
	for i in 6:
		brutes.append(g._add_unit("brute", 1, far + Vector2(200, -60 + 30 * i)))
	for i in 3:
		await physics_frame
	g.clock += 0.1
	check(not mic._swarm(r2u) and mic._charge(r2u), "6 Brutes (slow, armoured): the charge play stays")

	# ---- price
	var off_p: Array = g.unit_price(0, "dismounted")
	var hm_p: Array = g.unit_price(0, Defs.train_key("cuirassier", false))
	var horse := int(Defs.UNITS["horse"]["cost"])
	check(off_p[0] == hm_p[0] and off_p[1] == hm_p[1], "an Officer costs the Horseman's own price (%s v %s), the horse 40 more either way" % [str(off_p), str(hm_p)])
	check(off_p[0] + horse == 100 and hm_p[0] + horse == 100, "Officer + horse = Horseman + his horse = 100 gold")
	check(int(Defs.POWDER["cuirassier"]) == int(Defs.POWDER["dismounted"]) and Defs.AMMO["cuirassier"] == Defs.AMMO["dismounted"], "the same pistol and charges")
	check(float(Defs.POWDER["cost"]["cuirassier"]) == float(Defs.POWDER["cost"]["dismounted"]), "the same powder a charge")
	var fees: Dictionary = Defs.RESEARCH["armour"]["fees"]
	check(fees["cuirassier"] == fees["dismounted"], "the same Armour fee (%s v %s)" % [str(fees["cuirassier"]), str(fees["dismounted"])])
	g.players[0]["tech"]["armour"] = true
	var ao: Array = g.unit_price(0, Defs.train_key("dismounted", true))
	var cu: Array = g.unit_price(0, Defs.train_key("cuirassier", true))
	check(ao == cu, "Armoured Officer + horse == Cuirassier + horse (%s v %s)" % [str(ao), str(cu)])
	# by real training: an Officer, a horse at the breeder, a Horseman whose horse the breeder trains
	g.players[0]["tech"].erase("armour")
	g.players[0]["res2"] = 0.0
	g.players[0]["cap"] = 999
	var gold0 := int(g.players[0]["gold"])
	check(g.train(bar, "dismounted") == "", "the Barracks trains an Officer")
	var paid_off := gold0 - int(g.players[0]["gold"])
	gold0 = int(g.players[0]["gold"])
	check(g.train(brd, "horse") == "", "the Horse Breeder trains a horse")
	var paid_horse := gold0 - int(g.players[0]["gold"])
	gold0 = int(g.players[0]["gold"])
	var hk := Defs.train_key("cuirassier", false)
	var why := g.train(bar, hk)
	var paid_hm := gold0 - int(g.players[0]["gold"])
	check(why == "" and paid_off + paid_horse == paid_hm, "trained: Officer %d + horse %d == Horseman with his horse %d (%s)" % [paid_off, paid_horse, paid_hm, why])
	print("RESULT %s (%d failed)" % ["PASS" if fails == 0 else "FAIL", fails])
	quit(1 if fails > 0 else 0)
