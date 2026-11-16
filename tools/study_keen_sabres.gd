extends SceneTree
## keen-sabres-test (docs/keen_sabres_test.md; rerun by cavalry-charge-package, docs/cavalry_charge_package.md; the owner 2026-11-15 10:03: "Why do we need Keen Sabres as a concept?
## With charge and hit and run tactics we should be able to deal enough damage."). Measuring only, no gameplay change.
## Raptors v Horsemen at EQUAL COST (a Horseman with his horse 140, a Raptor 25: 5.6 Raptors a rider), in five rider arms:
##   stand   the riders stand where they are and the Raptors come in (no orders, no micro; the old tests' "stand")
##   a       the riders attack-move in as a wave, no micro (RideBy's loop round whatever is near), no research
##   b       hit and run (AICavMicro, scripts/ai_cav_micro.gd, on the riders' side), no research
##   c       hit and run + the Cavalry Charge (since cavalry-charge-package: x2.2 on light, and the micro's SWARM RULE:
##           no galloping round for the next charge against a fast melee swarm)
##   (Keen Sabres, the old arms d and e, is gone: cavalry-charge-package)
## (alternatives, measuring only) c2 = c but the micro never plays the charge (no galloping round at all; the old f2);
## cr = c with the swarm rule off (the micro's old charge loop, with x2.2: the old f).
## on open ground ("open") and in the riders' own base ("base": a Town Hall, a Barracks and Cottages round the riders,
## the Raptors attack-move into it), with and without Pack Hunt; the Raptors keep coming (an idle Raptor is sent at the
## nearest rider every second: a Brood player chasing). And a raid: 4 Horsemen ride into Brood workers and Spitters
## ("raid": 10 grubs and 6 Spitters; "raid_guard": the same with 12 Raptors on guard), arm c.
## Each fight 60 s at most. Prints a RESULT line per fight and a table per case: riders won-drew-lost, value killed per
## value lost (the cost-trade), riders lost, Raptors left.
##   godot --headless --fixed-fps 30 --script res://tools/study_keen_sabres.gd -- [sizes:2,4,8,12] [arms:stand,a,b,c,c2,cr]
##     [ground:open,base] [pack:0,1] [seeds:4] [raids:1|0] [only_raids:1] [out:FILE.json]
var main: Node
var t := 0.0
var g
var started := false
var origin := Vector2i(-1, -1)
var args := {}
var rows: Array = []
const SECS := 60.0
var RIDER_V: int = int(Defs.UNITS["cuirassier"]["cost"]) + int(Defs.UNITS["horse"]["cost"])   # a Horseman and his horse (100 from 0.38.32)
const RAPTOR_V := 25         # half an egg


class FakeHall:
	var at := Vector2.ZERO
	func center() -> Vector2:
		return at


class StubAI:
	var team := 0
	var game = null
	var home: FakeHall = null    # (a hurt rider rides "home": to the arena's west edge, out of the fight)
	func _on_errand(_u) -> bool:
		return false
	func _halls() -> Array:
		return [] if home == null else [home]


func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	for a in OS.get_cmdline_user_args():
		var i := a.find(":")
		if i > 0:
			args[a.substr(0, i)] = a.substr(i + 1)


func _process(_delta: float) -> bool:
	t += _delta
	if t > 0.2 and main.game == null:
		main.start({"map": "hollowfen", "seed": 4242, "slots": [
			{"who": "you", "faction": "crown", "colour": 0, "side": 0},
			{"who": "easy", "faction": "brood", "colour": 1, "side": 1}]})
		return false
	if main.game == null:
		return false
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	if not started and t > 1.0:
		started = true
		for ai in g.ais:
			ai.process_mode = Node.PROCESS_MODE_DISABLED
		_run()
	return false


func at(dx: float, dy: float) -> Vector2:
	return Vector2(origin) * Defs.TILE + Vector2(dx, dy)


func _open_area(w: int, h: int) -> Vector2i:
	var starts: Array = []
	for b in g.buildings:
		starts.append(b.center())
	for y in range(4, g.H - h - 4):
		for x in range(4, g.W - w - 4):
			var ok := true
			var h0: int = g.height[g.idx(Vector2i(x, y))]
			for yy in h:
				for xx in w:
					var c := Vector2i(x + xx, y + yy)
					if g.solid[g.idx(c)] != 0 or g.ramp[g.idx(c)] != 0 or g.height[g.idx(c)] != h0:
						ok = false
						break
				if not ok:
					break
			if not ok:
				continue
			var p: Vector2 = g.cell_center(Vector2i(x + w / 2, y + h / 2))
			for s in starts:
				if p.distance_to(s) < 700.0:
					ok = false
			if ok:
				return Vector2i(x, y)
	return Vector2i(-1, -1)


var spawned: Array = []          # every unit a fight made: all gone before the next (strays chased far off)


func _clear() -> void:
	for b in g.buildings:
		if not b.dead and b.team >= 0:
			b.hp = b.max_hp          # (strays never wear a start base down over many fights)
	for u in spawned:
		if is_instance_valid(u) and not u.dead:
			g.consume_unit(u)
	spawned.clear()
	for u in g.units.duplicate():
		if u.position.distance_to(at(480, 320)) < 760.0:
			g.consume_unit(u)
	for b in g.buildings.duplicate():
		if not b.dead and b.team >= 0 and b.center().distance_to(at(480, 320)) < 640.0:
			b.die()
	for i in 3:
		await physics_frame


func _list(key: String, dflt: String) -> PackedStringArray:
	return str(args.get(key, dflt)).split(",")


func _run() -> void:
	for wh in [[34, 24], [32, 22], [30, 20], [28, 20]]:
		origin = _open_area(wh[0], wh[1])
		if origin.x >= 0:
			print("(open ground %d x %d tiles at %s)" % [wh[0], wh[1], str(origin)])
			break
	if origin.x < 0:
		print("FAIL: no open ground for the study")
		quit(1)
		return
	g.reveal = true
	g.path_budget_us = 1 << 40
	g.players[0]["cap"] = 999
	g.players[1]["cap"] = 999
	var seeds := int(args.get("seeds", "4"))
	if args.get("only_raids", "0") != "1":
		for ground in _list("ground", "open,base"):
			for pack in _list("pack", "0,1"):
				for sz in _list("sizes", "2,4,8,12"):
					for arm in _list("arms", "stand,a,b,c"):
						for k in seeds:
							await _fight(ground, int(sz), arm, pack == "1", k)
	if args.get("raids", "1") == "1":
		for case in ["raid", "raid_guard"]:
			for arm in ["c"]:
				for k in seeds:
					await _fight(case, 4, arm, false, k)
	_table()
	if args.has("out"):
		var f := FileAccess.open(str(args["out"]), FileAccess.WRITE)
		f.store_string(JSON.stringify(rows))
	print("STUDY DONE")
	quit(0)


func _alive(a: Array) -> Array:
	return a.filter(func(x) -> bool: return is_instance_valid(x) and not x.dead)


func _spawn(kind: String, team: int, n: int, mid: Vector2, cols: int, gap: float, rng: RandomNumberGenerator) -> Array:
	var men: Array = []
	var rows_n := int(ceil(float(n) / cols))
	for i in n:
		var p := mid + Vector2((i % cols) * gap - gap * 0.5 * (cols - 1), (i / cols) * gap - gap * 0.5 * (rows_n - 1))
		p += Vector2(rng.randf_range(-4, 4), rng.randf_range(-4, 4))
		var m: Unit = g._add_unit(kind, team, p)
		m.auto_work = false
		spawned.append(m)
		men.append(m)
	return men


func _base() -> Vector2:
	# the riders' base: a Town Hall in the middle-left, a Barracks and three Cottages round it, gaps between
	var hall: Vector2i = g.cell_of(at(200, 290))
	g._add_building("town_hall", 0, hall, true)
	g._add_building("barracks", 0, hall + Vector2i(-1, -5), true)
	g._add_building("cottage", 0, hall + Vector2i(-1, 6), true)
	g._add_building("cottage", 0, hall + Vector2i(3, 6), true)
	g._add_building("cottage", 0, hall + Vector2i(6, -4), true)
	return at(200, 290) + Vector2(80, 64)


func _fight(ground: String, nr: int, arm: String, pack: bool, k: int) -> void:
	await _clear()
	seed(7000 + k * 31 + nr)
	var rng := RandomNumberGenerator.new()
	rng.seed = 9000 + k * 17 + nr
	var tech := {}
	if arm in ["c", "c2", "cr"]:
		tech["charge"] = true
	g.players[0]["tech"] = tech
	g.players[1]["tech"] = {"nb_pack_hunt": true} if pack else {}
	var raid := ground.begins_with("raid")
	var nb := int(round(nr * float(RIDER_V) / RAPTOR_V))
	var riders: Array = []
	var foes: Array = []
	var fighters: Array = []     # the Brood's fighting units (a win = all of them dead)
	var rmid := at(240, 320)
	var fmid := at(720, 320)
	var base_mid := Vector2.INF
	if ground == "base":
		base_mid = _base()
		rmid = base_mid + Vector2(130, 0)
		fmid = at(820, 320)
	var cols := clampi(int(ceil(sqrt(nr * 1.0))), 1, 4)
	for i in nr:
		var p := rmid + Vector2((i / cols) * -34.0, (i % cols) * 34.0 - 17.0 * (cols - 1))
		riders.append(g._add_unit("cuirassier", 0, p))
		spawned.append(riders[-1])
	if raid:
		var grubs := _spawn("grub", 1, 10, fmid + Vector2(60, 0), 5, 22.0, rng)
		var spit := _spawn("spitter", 1, 6, fmid - Vector2(10, 0), 3, 26.0, rng)
		foes = grubs + spit
		fighters = spit.duplicate()
		if ground == "raid_guard":
			var guard := _spawn("raptor", 1, 12, fmid - Vector2(90, 0), 4, 18.0, rng)
			foes += guard
			fighters += guard
		nb = 0
	else:
		foes = _spawn("raptor", 1, nb, fmid, clampi(int(ceil(sqrt(nb * 1.0))), 3, 9), 18.0, rng)
		fighters = foes.duplicate()
	var costs: Array = []
	for m in foes:
		costs.append(int(Defs.UNITS[m.kind]["cost"]) / maxi(1, int(Defs.UNITS[m.kind].get("spawn", 1))))
	await physics_frame
	var micro: AICavMicro = null
	if arm in ["b", "c", "c2", "cr"]:
		var stub := StubAI.new()
		stub.game = g
		stub.home = FakeHall.new()
		stub.home.at = at(10, 320)
		micro = AICavMicro.new(stub)
		micro.on = true
		micro.charge_play = arm != "c2"
		micro.swarm_rule = arm != "cr"
	if not raid:
		for x in foes:
			x.cmd_move(base_mid if ground == "base" else rmid, true)
	var go_to := fmid
	if arm != "stand":
		for r in riders:
			r.cmd_move(go_to, true)
	var hp_all := 0.0
	for r in riders:
		hp_all += r.max_hp
	var b0: float = float(g.stats[0].get("cav_blows", 0.0))
	var c0: float = float(g.stats[0].get("cav_charged", 0.0))
	var bhp0 := 0.0
	for b in g.buildings:
		if b.team == 0 and not b.dead and b.center().distance_to(at(480, 320)) < 640.0:
			bhp0 += b.hp
	var t0: float = g.clock
	var look := 0.0
	var frames := 0
	while g.clock - t0 < SECS:
		await physics_frame
		frames += 1
		for i in g.helpless_t.size():
			g.helpless_t[i] = 0.0      # (the sandbox's sides own nothing here: never BEATEN as helpless)
		if g.over or frames > int(SECS * 60):
			print("FAIL: the match ended or the clock stopped (over %s, winner %d, eliminated %s)" % [str(g.over), g.winner, str(g.eliminated)])
			quit(1)
			return
		if micro != null:
			micro.tick()
		if g.clock - t0 >= look:
			look = g.clock - t0 + 1.0
			var rr := _alive(riders)
			if arm != "stand":
				# (riders the micro let go of, with prey left: the wave's think sends them on again)
				var fa := _alive(fighters if not raid else foes)
				for r in rr:
					if r.order == "idle" and (micro == null or not micro.has(r)) and not fa.is_empty():
						r.cmd_move(fa[0].position, true)
			if not raid:
				# (the Brood chases: an idle Raptor goes at the nearest rider)
				for x in _alive(foes):
					var rin := rr.filter(func(r) -> bool: return r.position.distance_to(at(480, 320)) < 720.0)
					if x.order == "idle" and x.target == null and not rin.is_empty():
						var best: Unit = rin[0]
						for r in rin:
							if r.position.distance_to(x.position) < best.position.distance_to(x.position):
								best = r
						x.cmd_move(best.position, true)
		if _alive(riders).is_empty() or _alive(fighters).is_empty():
			if not raid or _alive(riders).is_empty() or _alive(foes).is_empty():
				break
			# (raid: the guard is dead; the riders finish the workers, the clock runs on)
	var killed := 0
	for i in foes.size():
		if not is_instance_valid(foes[i]) or foes[i].dead:
			killed += int(costs[i])
	var rl := riders.filter(func(r) -> bool: return not is_instance_valid(r) or r.dead).size()
	var hp_left := 0.0
	for r in _alive(riders):
		hp_left += r.hp
	var bhp1 := 0.0
	for b in g.buildings:
		if b.team == 0 and not b.dead and b.center().distance_to(at(480, 320)) < 640.0:
			bhp1 += b.hp
	var fl := _alive(fighters).size()
	var res := "D"
	if fl == 0 and rl < nr:
		res = "W"
	elif rl == nr:
		res = "L"
	var grubs_killed := 0
	if raid:
		for x in foes:
			if (not is_instance_valid(x) or x.dead) and x.kind == "grub":
				grubs_killed += 1
	var row := {"ground": ground, "size": nr, "raptors": nb, "arm": arm, "pack": pack, "seed": k, "res": res,
		"killed": killed, "lost_v": rl * RIDER_V, "riders_lost": rl, "fighters_left": fl, "hp_left": int(round(100.0 * hp_left / hp_all)),
		"blows": int(float(g.stats[0].get("cav_blows", 0.0)) - b0), "charged": int(float(g.stats[0].get("cav_charged", 0.0)) - c0),
		"bld_dmg": int(bhp0 - bhp1), "grubs": grubs_killed, "secs": snappedf(g.clock - t0, 0.1)}
	rows.append(row)
	print("RESULT %s %dv%d arm:%s pack:%s seed:%d -> %s killed %d, riders lost %d of %d (health left %d%%), Brood fighters left %d, blows %d/%d charged, buildings -%d, grubs %d, %.0f s" % [
		ground, nr, nb, arm, pack, k, res, killed, rl, nr, row["hp_left"], fl, row["blows"], row["charged"], row["bld_dmg"], grubs_killed, row["secs"]])


func _table() -> void:
	var sums := {}
	var order: Array = []
	for r in rows:
		var key := "%s|%s|%d|%s" % [r["ground"], r["pack"], r["size"], r["arm"]]
		if not sums.has(key):
			sums[key] = {"ground": r["ground"], "pack": r["pack"], "size": r["size"], "raptors": r["raptors"], "arm": r["arm"],
				"W": 0, "D": 0, "L": 0, "killed": 0, "lost_v": 0, "riders_lost": 0, "fighters_left": 0, "hp_left": 0, "grubs": 0, "bld": 0, "n": 0}
			order.append(key)
		var s: Dictionary = sums[key]
		s[r["res"]] += 1
		for f in ["killed", "lost_v", "riders_lost", "fighters_left", "hp_left", "grubs"]:
			s[f] += int(r[f])
		s["bld"] += int(r["bld_dmg"])
		s["n"] += 1
	print("")
	print("| ground | Pack Hunt | riders v Brood | arm | W-D-L (riders) | trade (value killed / lost) | riders lost (of) | Brood fighters left (mean) | rider health left | grubs killed | building damage |")
	print("|---|---|---|---|---|---|---|---|---|---|---|")
	for key in order:
		var s: Dictionary = sums[key]
		var n: int = s["n"]
		var trade := "%.2f" % (float(s["killed"]) / s["lost_v"]) if s["lost_v"] > 0 else "no loss (%d killed)" % s["killed"]
		print("| %s | %s | %d v %d | %s | %d-%d-%d | %s | %d (%d) | %.1f | %d%% | %.1f | %d |" % [s["ground"], "yes" if s["pack"] else "no",
			s["size"], s["raptors"], s["arm"], s["W"], s["D"], s["L"], trade, s["riders_lost"], s["size"] * n,
			float(s["fighters_left"]) / n, s["hp_left"] / n, float(s["grubs"]) / n, s["bld"] / n])
