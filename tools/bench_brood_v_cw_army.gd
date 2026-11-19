extends SceneTree
## BROOD v CLOCKWORK ARMY BENCH (job brood-v-clockwork-army, docs/brood_v_clockwork_army.md; the owner 2026-11-19 07:26:
## "Why does it lose to clockwork this easily? Is it making enough spitters?"). A measuring tool: no game number changed.
## Controlled fights at EQUAL COST (cogs + Tension against food + spoils, counted 1:1): a Clockwork army of the mix the
## Clockwork computer has at 8:00-10:00 (Clock Soldiers, Springers, Pendulums, Winders that escort and mend) against
## each Brood mix (Raptors, Spitters, Challengers, Brutes, Mist Toads), on open flat ground (dune_sea, its middle).
##   godot --headless --fixed-fps 30 --script res://tools/bench_brood_v_cw_army.gd -- [budget:2000] [seeds:3]
##       [cw:std|cs|pend] [scene:line|open] [only:R,S,...] [tech:early|late] [out:/abs/rows.jsonl]
## Scenes: line = the Clockwork stands where it is (its Winders escorting it) and the Brood attack-moves in (a Brood
##   wave into a Clockwork army at home); open = both attack-move at each other.
## Clockwork mixes (by cost): std = the computer's 8:00-10:00 army: 55% Clock Soldiers, 20% Springers, 15% Pendulums,
##   10% Winders; cs = Clock Soldiers and Winders (its 5:00-7:00 army); pend = 40% Clock Soldiers, 15% Springers,
##   35% Pendulums, 10% Winders (its 10:00+ army against Raptors).
## tech: early = none; late = SHIELD WALL (raised by the computer's own rule) for the Clockwork, PACK HUNT, LONG SPIT,
##   SLITHER for the Brood.
## One JSON line a fight to out:, a RESULT line to the console and a table at the end.
var main: Node
var g: Game
var t := 0.0
var begun := false
var started := false
var args := {}
var budget := 2000.0
var n_seeds := 3
var scene := "line"
var cwmix := "std"
var tech := "early"
var only: Array = []
var _out: FileAccess = null
var _field_cache: Array = []
var rows: Array = []

## Brood mixes: share of the budget by cost per kind
const MIXES := {
	"R": {"raptor": 1.0},
	"R3S1": {"raptor": 0.75, "spitter": 0.25},
	"R1S1": {"raptor": 0.5, "spitter": 0.5},
	"R1S3": {"raptor": 0.25, "spitter": 0.75},
	"S": {"spitter": 1.0},
	"SB": {"spitter": 0.7, "brute": 0.3},
	"RSB": {"raptor": 0.35, "spitter": 0.45, "brute": 0.2},
	"TC": {"tyrant_challenger": 1.0},
	"TCS": {"tyrant_challenger": 0.4, "spitter": 0.6},
	"VC": {"venom_challenger": 1.0},
	"VCS": {"venom_challenger": 0.4, "spitter": 0.6},
	"B": {"brute": 1.0},
	"STd": {"spitter": 0.85, "mist_toad": 0.15},
}
const CW := {
	"std": {"clock_soldier": 0.55, "springer": 0.2, "pendulum": 0.15, "winder": 0.1},
	"cs": {"clock_soldier": 0.9, "winder": 0.1},
	"pend": {"clock_soldier": 0.4, "springer": 0.15, "pendulum": 0.35, "winder": 0.1},
}
## the price of ONE unit (an egg's young each: Raptors 2 to 50 food, Spitters 2 to 90 + 5; a Challenger is a young one
## matured: its own price in Defs is the whole price; Tension counted as cogs)
const PRICE := {"raptor": 25.0, "spitter": 47.5, "brute": 170.0, "tyrant_challenger": 110.0, "venom_challenger": 170.0,
	"mist_toad": 125.0, "clock_soldier": 70.0, "springer": 125.0, "pendulum": 275.0, "winder": 60.0}


func _initialize() -> void:
	Settings.load_all()
	for a in OS.get_cmdline_user_args():
		var i := a.find(":")
		if i > 0:
			args[a.substr(0, i)] = a.substr(i + 1)
	budget = float(args.get("budget", "2000"))
	n_seeds = int(args.get("seeds", "3"))
	scene = String(args.get("scene", "line"))
	cwmix = String(args.get("cw", "std"))
	tech = String(args.get("tech", "early"))
	if args.has("only"):
		only = String(args["only"]).split(",")
	if args.has("out"):
		_out = FileAccess.open(String(args["out"]), FileAccess.WRITE)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _process(delta: float) -> bool:
	t += delta
	if not begun:
		if t > 0.2:
			begun = true
			root.add_child(SilentSfx.new())
			main.start({"map": "dune_sea", "seed": 4242, "slots": [
				{"who": "easy", "faction": "clockwork", "colour": 0, "side": 0},
				{"who": "easy", "faction": "brood", "colour": 1, "side": 1}]})
			if main.game:
				for ai in main.game.ais:
					ai.process_mode = Node.PROCESS_MODE_DISABLED
				main.game.path_budget_us = 1 << 40
				if Music.me:
					Music.me._faction = ""
		return false
	if main.game == null:
		return false
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	if not started and t > 1.0:
		started = true
		_run()
	return false


func wait(sec: float) -> void:
	var end: float = g.clock + sec
	while g.clock < end:
		await physics_frame


func counts(mix: Dictionary) -> Dictionary:
	var out := {}
	for k in mix:
		var n := int(round(budget * float(mix[k]) / float(PRICE[k])))
		if k in ["raptor", "spitter"]:
			n = int(round(n / 2.0)) * 2          # (whole eggs)
		out[k] = maxi(1 if float(mix[k]) > 0.0 else 0, n)
	return out


func _free_near(p: Vector2, lv: int) -> Vector2:
	for r in 14:
		for i in maxi(1, r * 6):
			var q: Vector2 = p + Vector2.from_angle(TAU * i / maxf(1.0, r * 6.0)) * r * 8.0
			var c: Vector2i = g.cell_of(q)
			if g.in_map(c) and g._walkable(c) and g.ramp[g.idx(c)] == 0 and int(g.height[g.idx(c)]) == lv and g._clear_at(q, 8.0, 0):
				return q
	return p


func _rect_ok(c: Vector2i, dv: Vector2i) -> bool:
	if not g.in_map(c):
		return false
	var lv := int(g.height[g.idx(c)])
	var perp := Vector2i(-dv.y, dv.x)
	for a in range(-12, 26):
		for b in range(-9, 10):
			var cc: Vector2i = c + dv * a + perp * b
			if not g.in_map(cc) or not g._walkable(cc) or g.ramp[g.idx(cc)] != 0 or int(g.height[g.idx(cc)]) != lv or g.solid[g.idx(cc)] != 0:
				return false
	return true


func _field() -> Array:
	var best := [Vector2.ZERO, Vector2.RIGHT]
	var best_d := INF
	var mid := Vector2(g.W, g.H) * 0.5
	for y in range(12, g.H - 12, 2):
		for x in range(12, g.W - 12, 2):
			var c := Vector2i(x, y)
			var dd: float = Vector2(c).distance_to(mid)
			if dd >= best_d:
				continue
			for dv in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if _rect_ok(c, dv):
					best_d = dd
					best = [g.cell_center(c), Vector2(dv)]
					break
	return best


func _add(k: String, team: int, p: Vector2, lv: int, list: Array) -> Unit:
	var u: Unit = g._add_unit(k, team, _free_near(p, lv))
	u.auto_work = false
	u._sep_n = list.size() % 3
	u.scan_t = float(list.size() % 10) / 30.0
	list.append(u)
	return u


func _alive(list: Array) -> Array:
	return list.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)


func _block(kinds: Array, n: Dictionary, team: int, at: Vector2, dir: Vector2, lv: int, list: Array, rng: RandomNumberGenerator, back := 0.0) -> void:
	var perp := Vector2(-dir.y, dir.x)
	var depth := back
	for k in kinds:
		var c: int = int(n.get(k, 0))
		if c <= 0:
			continue
		var sp := 30.0 if k in ["pendulum", "brute", "venom_challenger", "mist_toad"] else 20.0
		var cols := maxi(1, int(ceil(sqrt(c * 2.2))))
		for i in c:
			var row := i / cols
			var col := i % cols
			var p: Vector2 = at + dir * (depth + row * sp) + perp * ((col - (cols - 1) / 2.0) * sp)
			p += Vector2(rng.randf_range(-3, 3), rng.randf_range(-3, 3))
			_add(k, team, p, lv, list)
		depth += (int(ceil(float(c) / cols)) + 0.6) * sp


func fight(mix_name: String, s: int) -> Dictionary:
	seed(1000 + s * 7919)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77 + s * 131
	for k in ["shield_wall"]:
		g.players[0]["tech"][k] = tech == "late"
	for k in ["nb_pack_hunt", "nb_long_spit", "nb_slither"]:
		g.players[1]["tech"][k] = tech == "late"
	if _field_cache.is_empty():
		_field_cache = _field()
	var mid: Vector2 = _field_cache[0]
	var dir: Vector2 = _field_cache[1]
	var cw_at: Vector2 = mid - dir * 120.0
	var br_at: Vector2 = mid + dir * 360.0
	var lv := int(g.height[g.idx(g.cell_of(mid))])
	var cw: Array = []
	var br: Array = []
	var cn := counts(CW[cwmix])
	var bn := counts(MIXES[mix_name])
	# the Clockwork: soldiers in front (toward the Brood), Pendulums among them, Springers behind, Winders at the back
	_block(["clock_soldier", "pendulum"], cn, 0, cw_at, dir, lv, cw, rng, 0.0)
	_block(["springer", "winder"], cn, 0, cw_at, -dir, lv, cw, rng, 40.0)
	# the Brood: melee in front, shooters behind
	_block(["brute", "tyrant_challenger", "raptor"], bn, 1, br_at, -dir, lv, br, rng, 0.0)
	_block(["mist_toad", "venom_challenger", "spitter"], bn, 1, br_at, dir, lv, br, rng, 50.0)
	await wait(0.5)
	var fighters := cw.filter(func(u) -> bool: return u.kind != "winder")
	for u in cw:
		u.wind = 1.0
		if u.kind == "winder":
			u.cmd_escort(fighters)
		elif scene == "open":
			u.cmd_move(br_at, true)
	for u in br:
		u.cmd_move(cw_at, true)
	var t0: float = g.clock
	while g.clock - t0 < 150.0:
		await wait(0.5)
		if tech == "late":
			ShieldWall.think(g, 0)
		var a0 := _alive(cw).filter(func(u) -> bool: return u.kind != "winder")
		var a1 := _alive(br)
		if a0.is_empty() or a1.is_empty():
			break
		var at := Vector2.ZERO
		for u in a0:
			at += u.position
		at /= a0.size()
		for u in a1:
			if u.order == "idle" and u.target == null:
				u.cmd_move(at, true)
		if scene == "open":
			var bt := Vector2.ZERO
			for u in a1:
				bt += u.position
			bt /= a1.size()
			for u in a0:
				if u.order == "idle" and u.target == null:
					u.cmd_move(bt, true)
	var r := {"mix": mix_name, "seed": s, "budget": budget, "scene": scene, "cw": cwmix, "tech": tech,
		"time": snapped(g.clock - t0, 0.5), "cw_n": cn, "br_n": bn}
	for side in [["cw", cw], ["br", br]]:
		var cost := 0.0
		var lost := 0.0
		var alive := {}
		var lost_k := {}
		for u in side[1]:
			var p: float = PRICE[u.kind]
			cost += p
			if not is_instance_valid(u) or u.dead:
				lost += p
				lost_k[u.kind] = int(lost_k.get(u.kind, 0)) + 1
			else:
				lost += p * (1.0 - u.hp / maxf(1.0, u.max_hp)) * 0.0
				alive[u.kind] = int(alive.get(u.kind, 0)) + 1
		r[side[0] + "_cost"] = cost
		r[side[0] + "_lost"] = lost
		r[side[0] + "_alive"] = alive
		r[side[0] + "_lost_k"] = lost_k
	var w := "draw"
	if _alive(br).is_empty():
		w = "cw"
	elif _alive(cw).filter(func(u) -> bool: return u.kind != "winder").is_empty():
		w = "brood"
	r["winner"] = w
	r["trade"] = snapped(r["cw_lost"] / maxf(1.0, r["br_lost"]), 0.01)      # (value the Brood killed per value it lost)
	for u in cw + br:
		if is_instance_valid(u):
			g.consume_unit(u)
	for u in g.units.duplicate():
		if is_instance_valid(u) and u.dead:
			g.consume_unit(u)
	await wait(1.0)
	return r


func _run() -> void:
	var names: Array = MIXES.keys() if only.is_empty() else only
	print("field %s; budget %d scene %s cw %s tech %s" % [str(_field()), budget, scene, cwmix, tech])
	for m in names:
		for s in n_seeds:
			var r := await fight(String(m), s)
			rows.append(r)
			print("RESULT %s s%d %s %.1fs trade %.2f | brood lost %d/%d %s | cw lost %d/%d %s" % [m, s, r["winner"], r["time"],
				r["trade"], r["br_lost"], r["br_cost"], str(r["br_lost_k"]), r["cw_lost"], r["cw_cost"], str(r["cw_lost_k"])])
			if _out:
				_out.store_line(JSON.stringify(r))
				_out.flush()
	print("\n| Brood mix (%s, %d, cw %s, %s) | units | won-drew-lost | Brood killed per value lost |" % [scene, budget, cwmix, tech])
	print("|---|---|---|---|")
	for m in names:
		var ww := [0, 0, 0]
		var kl := 0.0
		var ls := 0.0
		var nn := {}
		for r in rows:
			if r["mix"] != m:
				continue
			nn = r["br_n"]
			ww[{"brood": 0, "draw": 1, "cw": 2}[r["winner"]]] += 1
			kl += r["cw_lost"]
			ls += r["br_lost"]
		print("| %s | %s | %d-%d-%d | %.2f |" % [m, str(nn), ww[0], ww[1], ww[2], kl / maxf(1.0, ls)])
	quit(0)
