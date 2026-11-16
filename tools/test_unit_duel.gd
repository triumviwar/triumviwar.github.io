extends SceneTree
## A STAND-UP FIGHT BETWEEN TWO GROUPS (balance-raptor-horseman, docs/balance_raptor_horseman.md): N units of one kind
## (team 0) against M of another (team 1) on the flat, open patch of Greenhold that tools/test_raptor_rider_fight.gd
## finds, both sides attack-moving into each other. Sandbox, no computers. Reports wins, the health and the gold left.
## Args: a:cuirassier:2  b:musketeer:4  trials:6  tech0:charge  tech1:nb_pack_hunt  armour0:1  armour1:1
##   set:cuirassier.hp=140,raptor.hp=36  (a number tried for this run only, on each unit's own copy of its stats)
##   godot --headless --fixed-fps 30 --script res://tools/test_unit_duel.gd -- a:cuirassier:2 b:clock_soldier:4
var main: Node
var args := {}


func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_go.call_deferred()


func _alive(a: Array) -> Array:
	return a.filter(func(x): return is_instance_valid(x) and not x.dead)


func _go() -> void:
	await process_frame
	for a in OS.get_cmdline_user_args():
		var kv := a.split(":", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else "1"
	var sa: PackedStringArray = str(args.get("a", "cuirassier:2")).split(":")
	var sb: PackedStringArray = str(args.get("b", "raptor:10")).split(":")
	var trials := int(args.get("trials", "6"))
	var wins := [0, 0]
	var left := [0.0, 0.0]
	var hpl := [0.0, 0.0]
	var tsum := 0.0
	var lines: Array = []
	for trial in trials:
		var r := await _fight(sa[0], int(sa[1]), sb[0], int(sb[1]), trial)
		if r["n1"] == 0 and r["n0"] > 0:
			wins[0] += 1
		elif r["n0"] == 0 and r["n1"] > 0:
			wins[1] += 1
		left[0] += r["n0"]
		left[1] += r["n1"]
		hpl[0] += r["hp0"]
		hpl[1] += r["hp1"]
		tsum += r["t"]
		lines.append("  trial %d: %.0fs, %s left %d (%.0f hp), %s left %d (%.0f hp)" % [trial, r["t"], sa[0], r["n0"], r["hp0"], sb[0], r["n1"], r["hp1"]])
	print("DUEL %d %s v %d %s%s%s%s: %s won %d, %s won %d, of %d; left on average %.1f (%.0f hp) v %.1f (%.0f hp); %.0f s" % [
		int(sa[1]), sa[0], int(sb[1]), sb[0], (" [" + str(args["set"]) + "]") if args.has("set") else "",
		(" tech0 " + str(args["tech0"])) if args.has("tech0") else "", (" tech1 " + str(args["tech1"])) if args.has("tech1") else "",
		sa[0], wins[0], sb[0], wins[1], trials, left[0] / trials, hpl[0] / trials, left[1] / trials, hpl[1] / trials, tsum / trials])
	for l in lines:
		print(l)
	quit()


func _fight(ka: String, na: int, kb: String, nb: int, trial: int) -> Dictionary:
	main.start({"seed": 21 + trial, "map": "greenhold", "sandbox": true, "slots": [{"who": "you", "faction": "crown", "colour": 0, "side": 0},
		{"who": "easy", "faction": String(Defs.UNITS[kb]["faction"]), "colour": 1, "side": 1}]})
	var g = main.game
	await create_timer(0.3).timeout
	g.hud.countdown = 0.0
	paused = false
	for a in g.ais:
		a.set_process(false)
		a.set_physics_process(false)
	for side in 2:
		if args.has("tech%d" % side):
			for k in str(args["tech%d" % side]).split(","):
				g.players[side]["tech"][k] = true
	var c: Vector2 = load("res://tools/test_raptor_rider_fight.gd")._flat_spot(g)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1000 + trial
	var sides := [[], []]
	for i in na:
		sides[0].append(g._add_unit(ka, 0, c + Vector2(-20 * (na - 1) + i * 40 + rng.randf_range(-4, 4), rng.randf_range(-10, 10))))
	for i in nb:
		sides[1].append(g._add_unit(kb, 1, c + Vector2(rng.randf_range(-80, 80), 240 + rng.randf_range(0, 50))))
	await process_frame
	for side in 2:
		if args.get("armour%d" % side, "") == "1":
			for u in sides[side]:
				u.put_on_armour()
	if args.has("set"):
		for kv in str(args["set"]).split(","):
			var ks: PackedStringArray = kv.split("=")
			var ku: PackedStringArray = ks[0].split(".")
			for u in sides[0] + sides[1]:
				if u.kind != ku[0]:
					continue
				var dd: Dictionary = u.d.duplicate()
				dd[ku[1]] = float(ks[1])
				u.d = dd
				if ku[1] == "hp":
					u.max_hp = float(ks[1]) + (float(Defs.ARMOURED[u.kind]["hp"]) if u.armoured and Defs.ARMOURED.has(u.kind) else 0.0)
					u.hp = u.max_hp
	for g_apply in sides[0] + sides[1]:
		g.apply_drills(g_apply)
	for u in sides[1]:
		u.cmd_move(c, true)
	for u in sides[0]:
		u.cmd_move(c + Vector2(0, 160), true)
	var t := 0.0
	while t < 120.0:
		await create_timer(0.25).timeout
		t += 0.25
		if _alive(sides[0]).is_empty() or _alive(sides[1]).is_empty():
			break
		if int(t * 4) % 20 == 0:
			# (stragglers: keep both sides walking at each other)
			var a0: Array = _alive(sides[0])
			var a1: Array = _alive(sides[1])
			for u in a0:
				if u.order == "idle":
					u.cmd_move(a1[0].position, true)
			for u in a1:
				if u.order == "idle":
					u.cmd_move(a0[0].position, true)
	var out := {"t": t}
	for side in 2:
		var al: Array = _alive(sides[side])
		out["n%d" % side] = al.size()
		out["hp%d" % side] = al.reduce(func(acc, u): return acc + u.hp, 0.0)
	return out
