extends SceneTree
## THE BATTLE LAB (job battle-matrix, docs/battle_matrix.md; the owner 2026-11-25: "Forget economy for a while and only do
## a gigantic round of battles... all possible compositions of Crown and Brood armies fighting... We don't even know the
## best possible compositions and what counters what"). A measuring tool: it changes no rule and no number.
##
## One fight: a real match (Crown v Brood, both computers Hard and alive), the economies frozen (no money for either side,
## every think), and two armies placed facing each other away from both bases, at EQUAL VALUE (the game's own prices: gold,
## food, powder and spoils counted one for one; a Crown rider or gun counts its horse, 40; a Crown soldier counts his
## powder load and any refit fees; a Brood young counts its egg's price over the young in it). Each army is handed to its
## own computer as a WAVE, so the fighting is the computers' own: the Crown's line, guns, rider screen, cavalry hit and run
## and kiting (AICrownLine, AICrownGuns, AICrownScreen, AICavMicro, AI._micro), the Brood's wave (no chase of riders, the
## Mist Toads' FOG and TONGUE). Only the retreat is taken away: when a computer pulls its wave back the lab sends it in
## again (counted as "pulls"), so every fight is fought to the end and the trade measures the fight, not the decision to
## leave it. The fight ends when one side has nothing left that fights, or 180 s after first contact.
##
##   godot --headless --fixed-fps 30 --path . --script res://tools/battle_lab.gd -- jobs:/abs/jobs.txt out:/abs/rows.jsonl
##       [map:dune_sea] [shots:/abs/dir] [debug]
##   a job line: <crown comp> <brood comp> <size> <ground> <seed>      e.g.  MCH R1S1 1500 open 2
## Grounds: open   both march at each other on flat open ground
##          set    flat open ground; the Crown stands ready (a line two deep, its guns unlimbered behind) and the Brood
##                 comes at it: against open this tells the Crown's fighting from the numbers
##          choke  a rock wall right across the map with one gap 6 tiles wide; the Crown holds behind the gap (set as on
##                 "set"), the Brood comes through it
##          up     a ramp: the Crown holds the top (set as on "set"), the Brood comes up at it
## On set, choke and up the Crown is SET BY HAND as a careful player sets a line (two deep, guns unlimbered, every man on
## HOLD, riders going at what comes near them): the computer does not move it. Everywhere else the computers fight.
##          down   a ramp: the Brood holds the top, the Crown goes up at it
## Research by size (what each side plausibly has by then): size < 1000 early, < 2500 mid, else late (TECH below).
## One JSON line a fight to out: (python tools/study/battle_lab.py makes the jobs, runs them on every core and the tables).
var main: Node
var g: Game
var args := {}
var _out: FileAccess = null
var shots := ""

## Compositions: share of the army's VALUE by kind.
const CROWN := {
	"M": {"musketeer": 1.0},
	"MC": {"musketeer": 0.75, "cannon": 0.25},
	"MCH": {"musketeer": 0.55, "cannon": 0.3, "cuirassier": 0.15},          # (the computer's wave: line, guns, a screen)
	"MMo": {"musketeer": 0.7, "mortar": 0.3},
	"MCMo": {"musketeer": 0.6, "cannon": 0.2, "mortar": 0.2},
	"MH": {"musketeer": 0.7, "cuirassier": 0.3},
	"H": {"cuirassier": 1.0},
	"D": {"dragoon": 1.0},
	"MD": {"musketeer": 0.7, "dragoon": 0.3},
	"MO": {"musketeer": 0.7, "dismounted": 0.3},
	"MB": {"musketeer": 0.85, "band": 0.05, "band_fifer": 0.05, "band_piper": 0.05},
	"MMi": {"musketeer": 0.9, "missionary": 0.1},
	"CH": {"cannon": 0.6, "cuirassier": 0.4},
}
const BROOD := {
	"R": {"raptor": 1.0},
	"R3S1": {"raptor": 0.75, "spitter": 0.25},
	"R1S1": {"raptor": 0.5, "spitter": 0.5},
	"R1S3": {"raptor": 0.25, "spitter": 0.75},
	"S": {"spitter": 1.0},
	"B": {"brute": 1.0},
	"RSB": {"raptor": 0.35, "spitter": 0.45, "brute": 0.2},
	"TC": {"tyrant_challenger": 1.0},
	"TCS": {"tyrant_challenger": 0.4, "spitter": 0.6},
	"VC": {"venom_challenger": 1.0},
	"StC": {"storm_challenger": 1.0},
	"RSTd": {"raptor": 0.4, "spitter": 0.45, "mist_toad": 0.15},
	"RSy": {"raptor": 0.5, "spitter": 0.5, "tyrannosaur": 0.0},          # (R1S1 led by the Tyrant Sire, counted at his price)
}
## what each side has researched by then
const TECH := {
	"early": {"crown": ["bayonet"], "brood": []},
	"mid": {"crown": ["bayonet", "matchlock", "charge", "charges", "pouch"], "brood": ["nb_pack_hunt", "nb_long_spit"]},
	"late": {"crown": ["bayonet", "matchlock", "flintlock", "charge", "charges", "pouch", "armour", "quadrant"],
		"brood": ["nb_pack_hunt", "nb_long_spit", "nb_slither", "nb_battering_horns", "nb_fog", "nb_miasma", "nb_updraft"]},
}
const FRONT := ["brute", "tyrant_challenger", "raptor", "storm_challenger", "tyrannosaur", "cuirassier", "dragoon", "dismounted", "musketeer"]
const GUNS := ["cannon", "mortar"]
const RIDERS := ["cuirassier", "dragoon"]
const FIGHT_FOR := 180.0
const APPROACH := 75.0
const CONTACT := 300.0

const NOT_FIGHTING := ["band", "band_fifer", "band_piper", "missionary"]
var _wide := false         # (ground "set": the Crown's foot in a line two deep)
var _orig := {}            # Unit -> [its kind when placed, its value] (a Horseman unhorsed is an Officer, at the Horseman's price)
var _ramp_cache := {}
var _field_cache := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var i := a.find(":")
		if i > 0:
			args[a.substr(0, i)] = a.substr(i + 1)
		else:
			args[a] = "1"
	if args.has("out"):
		_out = FileAccess.open(String(args["out"]), FileAccess.READ_WRITE if FileAccess.file_exists(String(args["out"])) else FileAccess.WRITE)
		if _out:
			_out.seek_end()
	shots = String(args.get("shots", ""))
	_run.call_deferred()


func _run() -> void:
	if args.has("probe"):
		for m in String(args["probe"]).split(","):
			await _start(1, m)
			_field_cache.clear()
			_ramp_cache.clear()
			print("PROBE %s size %dx%d" % [m, Game.W, Game.H])
			_field()
			_ramp()
			var far := 0
			for i in g.ramp.size():
				if g.ramp[i] != 0:
					var cc := Vector2i(i % Game.W, i / Game.W)
					var dmin := 999.0
					for st in g.starts:
						dmin = minf(dmin, Vector2(st).distance_to(Vector2(cc)))
					if dmin > 24.0:
						far += 1
			print("ramp cells %d far from the starts %d; starts %s" % [g.ramp.count(1) + g.ramp.count(2) + g.ramp.count(3), far, str(g.starts)])
		quit(0)
		return
	if args.has("prices"):
		await _start(1, "dune_sea")
		var out := {}
		for band in TECH:
			for k in TECH[band]["crown"]:
				g.players[0]["tech"][k] = true
			var row := {}
			for k in ["musketeer", "cannon", "mortar", "cuirassier", "dragoon", "dismounted", "band", "band_fifer", "band_piper", "missionary"]:
				row[k] = price(0, k)
			for k in ["raptor", "spitter", "brute", "tyrant_challenger", "venom_challenger", "storm_challenger", "mist_toad", "tyrannosaur"]:
				row[k] = price(1, k)
			out[band] = row
		print("PRICES " + JSON.stringify(out))
		quit(0)
		return
	var jobs: Array = []
	if args.has("jobs"):
		var f := FileAccess.open(String(args["jobs"]), FileAccess.READ)
		while f and not f.eof_reached():
			var ln := f.get_line().strip_edges()
			if ln != "" and not ln.begins_with("#"):
				jobs.append(ln.split(" ", false))
	else:
		jobs.append([String(args.get("crown", "MCH")), String(args.get("brood", "R1S1")), String(args.get("size", "1500")),
			String(args.get("ground", "open")), String(args.get("seed", "0"))])
	for j in jobs:
		var r: Dictionary = await _fight(String(j[0]), String(j[1]), int(j[2]), String(j[3]), int(j[4]))
		print("ROW " + JSON.stringify(r))
		if _out:
			_out.store_line(JSON.stringify(r))
			_out.flush()
	if main:
		main.queue_free()
		await process_frame
	quit(0)


# ------------------------------------------------------------------ the match

func _start(sd: int, map: String) -> void:
	if main != null:
		main.queue_free()
		await process_frame
		await process_frame
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	seed(sd)
	main.start({"map": map, "seed": 4242, "slots": [
		{"who": "hard", "faction": "crown", "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "hard", "faction": "brood", "colour": 1, "side": 1, "strategy": "balanced"}]})
	await process_frame
	await process_frame
	g = main.game
	g.path_budget_us = 1 << 40           # (no time limit on the path queue: the same fight every run)
	if g.hud:
		g.hud.countdown = 0.0
		if shots == "":
			g.hud.visible = false
	if shots != "":
		if g.hud:
			g.hud.visible = false
		if g.spectator:
			g.spectator.process_mode = Node.PROCESS_MODE_DISABLED
		if g.controls:
			g.controls.process_mode = Node.PROCESS_MODE_DISABLED
	paused = false
	if Music.me:
		Music.me._faction = ""


func _ai(t: int) -> AI:
	for a in g.ais:
		if a.team == t:
			return a
	return null


func _broke() -> void:
	for t in 2:
		g.players[t]["gold"] = 0
		g.players[t]["res2"] = 0.0


func _wait(sec: float) -> void:
	var end: float = g.clock + sec
	while g.clock < end and not g.over:
		_broke()
		await physics_frame


func _alive(list: Array) -> Array:
	return list.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)


func _fighters(list: Array) -> Array:
	return _alive(list).filter(func(u: Unit) -> bool: return not String(_orig.get(u, [u.kind])[0]) in NOT_FIGHTING)


func _centre(list: Array, dflt: Vector2) -> Vector2:
	var a := _alive(list)
	if a.is_empty():
		return dflt
	var c := Vector2.ZERO
	for u in a:
		c += u.position
	return c / a.size()


# ------------------------------------------------------------------ prices

## The value of one unit of a kind for side t at the game's own prices (see the head of the file).
func price(t: int, k: String) -> float:
	var d: Dictionary = Defs.UNITS[k]
	if t == 1:
		return (float(d["cost"]) + float(d.get("cost2", 0))) / maxf(1.0, float(d.get("spawn", 1)))
	var p: Array = g.unit_price(0, k)
	var v := float(p[0]) + float(p[1])
	if d.get("needs_horse", false) or k in RIDERS:
		v += float(Defs.UNITS["horse"]["cost"])
	if Defs.AMMO.has(k):
		v += float(Defs.ammo_load(k))
	elif k == "cannon" or k == "mortar":
		v += float(Defs.POWDER[k]) * Defs.ammo_price(k)
	return v


## How many of each kind make `budget` of this composition (whole eggs for the Brood's two-to-an-egg young).
func counts(t: int, mix: Dictionary, budget: float) -> Dictionary:
	var out := {}
	var left := budget
	var kinds: Array = mix.keys()
	kinds.sort_custom(func(a, b) -> bool: return price(t, a) > price(t, b))
	for k in kinds:
		if float(mix[k]) <= 0.0:
			continue
		var n := int(round(budget * float(mix[k]) / price(t, k)))
		if int(Defs.UNITS[k].get("spawn", 1)) > 1:
			n = int(round(n / 2.0)) * 2
		n = maxi(1, n)
		out[k] = n
		left -= n * price(t, k)
	# the cheapest kind takes up (or gives back) what is left, so the total is as near the budget as it goes
	var cheap: String = kinds[kinds.size() - 1]
	for k in kinds:
		if float(mix[k]) > 0.0 and price(t, k) < price(t, cheap):
			cheap = k
	var step := price(t, cheap) * (2.0 if int(Defs.UNITS[cheap].get("spawn", 1)) > 1 else 1.0)
	var guard := 0
	while left >= step * 0.5 and guard < 400:
		out[cheap] = int(out.get(cheap, 0)) + (2 if int(Defs.UNITS[cheap].get("spawn", 1)) > 1 else 1)
		left -= step
		guard += 1
	while left <= -step * 0.5 and int(out.get(cheap, 0)) > (2 if step > price(t, cheap) else 1) and guard < 800:
		out[cheap] = int(out[cheap]) - (2 if int(Defs.UNITS[cheap].get("spawn", 1)) > 1 else 1)
		left += step
		guard += 1
	return out


func value_of(t: int, n: Dictionary) -> float:
	var v := 0.0
	for k in n:
		v += price(t, k) * int(n[k])
	return v


# ------------------------------------------------------------------ the ground

func _free_near(p: Vector2, lv: int) -> Vector2:
	for r in 16:
		for i in maxi(1, r * 6):
			var q: Vector2 = p + Vector2.from_angle(TAU * i / maxf(1.0, r * 6.0)) * r * 9.0
			var c: Vector2i = g.cell_of(q)
			if g.in_map(c) and g._walkable(c) and g.ramp[g.idx(c)] == 0 and (lv < 0 or int(g.height[g.idx(c)]) == lv) and g._clear_at(q, 8.0, 0):
				return q
	return p


func _rect_ok(c: Vector2i, dv: Vector2i, a0: int, a1: int, half: int) -> bool:
	if not g.in_map(c):
		return false
	var lv := int(g.height[g.idx(c)])
	var perp := Vector2i(-dv.y, dv.x)
	for a in range(a0, a1):
		for b in range(-half, half + 1):
			var cc: Vector2i = c + dv * a + perp * b
			if not g.in_map(cc) or not g._walkable(cc) or g.ramp[g.idx(cc)] != 0 or int(g.height[g.idx(cc)]) != lv or g.solid[g.idx(cc)] != 0:
				return false
	return true


## The open field: the flat open rectangle (60 tiles long, 21 wide) nearest the map's middle. [middle, direction]
func _field() -> Array:
	var key := g.map_name if "map_name" in g else "m"
	if _field_cache.has(key):
		return _field_cache[key]
	var best := [Vector2(Game.W, Game.H) * Defs.TILE * 0.5, Vector2.RIGHT]
	var best_d := INF
	var mid := Vector2(Game.W, Game.H) * 0.5
	for half in [10, 8, 6]:
		for y in range(8, Game.H - 8):
			for x in range(8, Game.W - 8):
				var c := Vector2i(x, y)
				var dd: float = Vector2(c).distance_to(mid)
				if dd >= best_d:
					continue
				for dv in [Vector2i(1, 0), Vector2i(0, 1)]:
					if _rect_ok(c, dv, -30, 30, half):
						best_d = dd
						best = [g.cell_center(c), Vector2(dv)]
						break
		if best_d < INF:
			break
	_field_cache[key] = best
	print("LAB field %s dir %s" % [str(best[0]), str(best[1])])
	return best


## THE CHOKE: rock (terrain) right across the map through the field's middle, two tiles thick, with one gap 6 tiles wide.
func _make_choke(mid: Vector2, dir: Vector2) -> void:
	var c0: Vector2i = g.cell_of(mid)
	var dv := Vector2i(int(dir.x), int(dir.y))
	var perp := Vector2i(-dv.y, dv.x)
	for s in range(-200, 201):
		if absi(s) <= 3:
			continue          # (the gap: 6 tiles, -3..3 exclusive of the ends)
		for th in 2:
			var cc: Vector2i = c0 + perp * s + dv * th
			if g.in_map(cc) and g.solid[g.idx(cc)] == 0 and g.cliff[g.idx(cc)] == 0:
				g._mark(cc, Vector2i(1, 1), 1)
	if "_pq_cache" in g:
		g._pq_cache.clear()


## THE RAMP: the ramp nearest the map's middle with flat room above it and below it. [top spot, bottom spot, up direction]
func _ramp() -> Array:
	var key := g.map_name if "map_name" in g else "m"
	if _ramp_cache.has(key):
		return _ramp_cache[key]
	var mid := Vector2(Game.W, Game.H) * 0.5
	var cands: Array = []
	for y in range(4, Game.H - 4):
		for x in range(4, Game.W - 4):
			var c := Vector2i(x, y)
			if g.ramp[g.idx(c)] == 0:
				continue
			# the way up: the neighbour step (4 ways, 6 cells out) that ends highest, the way down the lowest
			for dv in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var hi: Vector2i = c + dv * 6
				var lo: Vector2i = c - dv * 6
				if not g.in_map(hi) or not g.in_map(lo) or g.ramp[g.idx(hi)] != 0 or g.ramp[g.idx(lo)] != 0:
					continue
				if int(g.height[g.idx(hi)]) <= int(g.height[g.idx(lo)]):
					continue
				cands.append([Vector2(c).distance_to(mid), c, dv])
	cands.sort_custom(func(a, b) -> bool: return a[0] < b[0])
	var res := []
	var starts: Array = []
	for st in g.starts:
		starts.append(Vector2(st))
	for cd in cands:
		var c: Vector2i = cd[1]
		var dv: Vector2i = cd[2]
		if starts.any(func(s0: Vector2) -> bool: return s0.distance_to(Vector2(c)) < 24.0):
			continue          # (not a main's own ramp: the bases stay out of it)
		var hi: Vector2i = c
		while g.in_map(hi) and g.ramp[g.idx(hi)] != 0:
			hi += dv
		var lo: Vector2i = c
		while g.in_map(lo) and g.ramp[g.idx(lo)] != 0:
			lo -= dv
		var top: Vector2i = hi + dv * 4
		var bot: Vector2i = lo - dv * 7
		if _rect_ok(hi + dv, dv, 0, 7, 4) and _rect_ok(lo - dv, -dv, 0, 12, 5):
			res = [g.cell_center(top), g.cell_center(bot), Vector2(dv)]
			break
	if res.is_empty():
		res = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
	_ramp_cache[key] = res
	print("LAB ramp top %s bottom %s up %s" % [str(res[0]), str(res[1]), str(res[2])])
	return res


# ------------------------------------------------------------------ placing the armies

func _add(k: String, team: int, p: Vector2, lv: int, list: Array, kit: Dictionary) -> Unit:
	var u: Unit = g._add_unit(k, team, _free_near(p, lv))
	u.auto_work = false
	if not kit.is_empty():
		u.set_kit(kit)
	_orig[u] = [k, price(team, k)]
	list.append(u)
	return u


## A block of kinds in rows, `dir` pointing at the enemy, starting `back` px behind `at`.
func _block(kinds: Array, n: Dictionary, team: int, at: Vector2, dir: Vector2, lv: int, list: Array, rng: RandomNumberGenerator, back: float) -> float:
	var perp := Vector2(-dir.y, dir.x)
	var depth := back
	for k in kinds:
		var c: int = int(n.get(k, 0))
		if c <= 0:
			continue
		var sp := 34.0 if k in ["brute", "venom_challenger", "mist_toad", "cuirassier", "dragoon", "tyrannosaur"] else 22.0
		if k in GUNS:
			sp = 64.0
		var cols := maxi(1, int(ceil(sqrt(c * 3.0)))) if not k in GUNS else mini(c, 6)
		if _wide and team == 0 and k in ["musketeer", "dismounted"]:
			cols = maxi(1, int(ceil(c / 2.0)))       # (the formed line: two ranks)
			sp = 24.0
		var kit: Dictionary = g.kit_all(team, k) if team == 0 else {}
		for i in c:
			var row := i / cols
			var col := i % cols
			var p: Vector2 = at - dir * (depth + row * sp) + perp * ((col - (cols - 1) / 2.0) * sp)
			p += Vector2(rng.randf_range(-3, 3), rng.randf_range(-3, 3))
			_add(k, team, p, lv, list, kit)
		depth += (int(ceil(float(c) / cols)) + 0.6) * sp
	return depth


func _place(team: int, n: Dictionary, at: Vector2, dir: Vector2, lv: int, rng: RandomNumberGenerator) -> Array:
	var list: Array = []
	var perp := Vector2(-dir.y, dir.x)
	if team == 0:
		var d := _block(["musketeer", "dismounted"], n, 0, at, dir, lv, list, rng, 0.0)
		d = _block(["band", "band_fifer", "band_piper", "missionary"], n, 0, at, dir, lv, list, rng, d + 10.0)
		_block(["cannon", "mortar"], n, 0, at, dir, lv, list, rng, d + 40.0)
		# the riders on the flanks
		for k in RIDERS:
			var c := int(n.get(k, 0))
			var kit: Dictionary = g.kit_all(0, k)
			for i in c:
				var side := 1.0 if i % 2 == 0 else -1.0
				var p: Vector2 = at + perp * side * (170.0 + float(i / 2 % 4) * 34.0) - dir * (float(i / 8) * 34.0 + 20.0)
				_add(k, 0, p, lv, list, kit)
	else:
		var d := _block(["tyrannosaur", "brute", "tyrant_challenger", "storm_challenger", "raptor"], n, 1, at, dir, lv, list, rng, 0.0)
		_block(["mist_toad", "venom_challenger", "spitter"], n, 1, at, dir, lv, list, rng, d + 10.0)
	return list


# ------------------------------------------------------------------ one fight

func _size_band(size: int) -> String:
	return "early" if size < 1000 else ("mid" if size < 2500 else "late")


func _fight(cc: String, bc: String, size: int, ground: String, sd: int) -> Dictionary:
	var map := String(args.get("map", "dune_sea"))
	if ground in ["up", "down"]:
		map = String(args.get("rampmap", "jade_wilds"))      # (a ramp out in the open, away from both bases)
	var wall0 := Time.get_ticks_msec()
	await _start(9000 + sd * 7919 + size, map)
	var band := _size_band(size)
	for k in TECH[band]["crown"]:
		g.players[0]["tech"][k] = true
	for k in TECH[band]["brood"]:
		g.players[1]["tech"][k] = true
	var ca: AI = _ai(0)
	var ba: AI = _ai(1)
	ca.peaceful = true
	ba.peaceful = true
	if ca.has_method("line_ai"):
		ca.line_ai()
	_broke()
	await _wait(1.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77 + sd * 131 + size
	# where
	var fld := _field()
	var mid: Vector2 = fld[0]
	var dir: Vector2 = fld[1]
	var c_at: Vector2
	var b_at: Vector2
	var c_dir: Vector2         # the Crown faces this way (at the Brood)
	var hold := Vector2.INF    # the side holding: its spot
	var holder := -1
	match ground:
		"set":
			# (THE FORMED LINE: the Crown stands ready as a careful player sets it, a line two deep across the way the
			# Brood comes, its guns unlimbered behind it; the Brood comes at it. Against "open" this tells the fighting
			# from the numbers: the same armies, only the Crown's readiness differs)
			_wide = true
			c_at = mid - dir * 12.0 * Defs.TILE
			b_at = mid + dir * 22.0 * Defs.TILE
			c_dir = dir
			hold = c_at
			holder = 0
		"choke":
			_make_choke(mid, dir)
			_wide = true
			c_at = mid - dir * 8.0 * Defs.TILE
			b_at = mid + dir * 26.0 * Defs.TILE
			c_dir = dir
			hold = c_at
			holder = 0
		"up", "down":
			var rp := _ramp()
			if rp[2] == Vector2.ZERO:
				return {"err": "no ramp", "crown": cc, "brood": bc, "size": size, "ground": ground, "seed": sd}
			var top: Vector2 = rp[0]
			var bot: Vector2 = rp[1]
			var up: Vector2 = rp[2]
			if ground == "up":
				_wide = true
				c_at = top
				b_at = bot - up * 4.0 * Defs.TILE
				c_dir = -up
				hold = top
				holder = 0
			else:
				b_at = top
				c_at = bot - up * 4.0 * Defs.TILE
				c_dir = up
				hold = top
				holder = 1
		_:
			c_at = mid - dir * 19.0 * Defs.TILE
			b_at = mid + dir * 19.0 * Defs.TILE
			c_dir = dir
	var lvc := int(g.height[g.idx(g.cell_of(c_at))])
	var lvb := int(g.height[g.idx(g.cell_of(b_at))])
	var cn := counts(0, CROWN[cc], float(size))
	var cv := value_of(0, cn)
	var bmix: Dictionary = BROOD[bc]
	var bn: Dictionary
	if bmix.has("tyrannosaur"):
		var rest := bmix.duplicate()
		rest.erase("tyrannosaur")
		bn = counts(1, rest, cv - price(1, "tyrannosaur"))
		bn["tyrannosaur"] = 1
	else:
		bn = counts(1, bmix, cv)
	var bv := value_of(1, bn)
	var cl := _place(0, cn, c_at, c_dir, lvc, rng)
	var bl := _place(1, bn, b_at, -c_dir, lvb, rng)
	var set_at := {}           # (the Crown set by hand: each man's place)
	if _wide:
		_wide = false
		for u in cl:
			set_at[u] = u.position
			if u.kind in GUNS:
				u.cmd_deploy()
			else:
				u.cmd_hold()
	for u in cl:
		if Defs.AMMO.has(u.kind) or u.kind in GUNS:
			pass       # (they come out loaded: Unit.setup fills a recruit's shots)
	await _wait(0.6)
	# hand each army to its computer as a wave
	var cl_t: Vector2 = hold if holder == 0 else _centre(bl, b_at)
	var bl_t: Vector2 = hold if holder == 1 else _centre(cl, c_at)
	if set_at.is_empty():
		_crown_wave(ca, cl, cl_t, true)
	else:
		ca.process_mode = Node.PROCESS_MODE_DISABLED       # (the set line: the Crown's computer has no say over it)
	_brood_wave(ba, bl, bl_t, true)
	var t0: float = g.clock
	var contact := -1.0
	var pulls := [0, 0]
	var guns: Array = cl.filter(func(u: Unit) -> bool: return u.kind in GUNS)
	var guns_set_contact := -1
	var guns_set_10 := -1
	var guns_fired_20 := -1
	var shot_n := 0
	var next_shot := 0.0
	while not g.over:
		await _wait(0.5)
		var cf := _fighters(cl)
		var bf := _fighters(bl)
		if args.has("debug"):
			var st := {}
			for u in _alive(cl):
				var key := "%s/%s/%s" % [u.kind, u.order, "T" if u.target else "-"]
				st[key] = int(st.get(key, 0)) + 1
			var sb := {}
			for u in _alive(bl):
				var key := "%s/%s/%s" % [u.kind, u.order, "T" if u.target else "-"]
				sb[key] = int(sb.get(key, 0)) + 1
			print("t %.1f crown %s | brood %s | att %s %s" % [g.clock - t0, str(st), str(sb), ca._attacking, ba._attacking])
		if cf.is_empty() or bf.is_empty():
			break
		var cc_p := _centre(cf, c_at)
		var bc_p := _centre(bf, b_at)
		if contact < 0.0:
			var near := false
			for u in cf:
				for o in g.units_near(u.position, CONTACT):
					if o.team == 1 and not o.dead and o.position.distance_to(u.position) <= CONTACT and bl.has(o):
						near = true
						break
				if near:
					break
			if near:
				contact = g.clock
				guns_set_contact = _guns_set(guns)
			elif g.clock - t0 > APPROACH:
				# (nobody met: the holder goes at the other)
				hold = Vector2.INF
				holder = -1
		else:
			if guns_set_10 < 0 and g.clock - contact >= 10.0:
				guns_set_10 = _guns_set(guns)
			if guns_fired_20 < 0 and g.clock - contact >= 20.0:
				guns_fired_20 = guns.filter(func(u) -> bool: return is_instance_valid(u) and float(u.fired_t) >= contact).size()
			if g.clock - contact > FIGHT_FOR:
				break
		if contact < 0.0 and g.clock - t0 > APPROACH + 60.0:
			break
		# the holder keeps to its spot (its men fight whatever comes in reach); the other goes at it
		var c_goal: Vector2 = hold if holder == 0 else bc_p
		var b_goal: Vector2 = hold if holder == 1 else cc_p
		if not set_at.is_empty():
			# THE SET LINE (set, choke, up): the Crown stands as it was set, as a player's line on HOLD; nobody walks off
			# (the computer has no say over it: it would take a hold at a spot of its own for a march's end). Riders
			# go at whatever comes within 5 tiles of them.
			for u in _alive(cl):
				var sp: Vector2 = set_at.get(u, u.position)
				if u.kind in RIDERS:
					if u.target == null and u.order != "amove":
						for o in g.units_near(u.position, 5.0 * Defs.TILE):
							if o.team == 1 and not o.dead and bl.has(o) and o.position.distance_to(u.position) < 5.0 * Defs.TILE:
								u.cmd_move(o.position, true)
								break
					continue
				if u.deploys():
					if u.tesla_mode == "packed" and u.order == "idle":
						u.cmd_deploy()
					continue
				if u.target == null and u.order != "hold" and u.position.distance_to(sp) > 3.0 * Defs.TILE:
					u.cmd_move(sp)
				elif u.order == "idle":
					u.cmd_hold()
		elif not ca._attacking:
			pulls[0] += 1
			_crown_wave(ca, _alive(cl), c_goal, true)
		else:
			ca._wave_target = c_goal
			for u in _alive(cl):
				ca._wave_set[u] = true
				if u.order == "idle" and u.target == null and not u.deploys() and (holder != 0 or u.position.distance_to(hold) > 10.0 * Defs.TILE):
					u.cmd_move(c_goal, true)
		if not ba._attacking:
			pulls[1] += 1
			_brood_wave(ba, _alive(bl), b_goal, true)
		else:
			ba._wave_target = b_goal
			for u in _alive(bl):
				if not ba._wave.has(u):
					ba._wave.append(u)
				if u.order == "idle" and u.target == null:
					u.cmd_move(b_goal, true)
		if shots != "" and contact >= 0.0 and g.clock >= next_shot and shot_n < int(args.get("nshots", "6")):
			next_shot = g.clock + float(args.get("shotgap", "6"))
			await _shoot("%s_%s_%d_%s_s%d_%02d.jpg" % [cc, bc, size, ground, sd, shot_n], (cc_p + bc_p) * 0.5, size)
			shot_n += 1
	# the result
	var r := {"crown": cc, "brood": bc, "size": size, "ground": ground, "seed": sd, "band": band,
		"crown_n": cn, "brood_n": bn, "crown_value": cv, "brood_value": bv,
		"contact": snappedf(contact - t0, 0.5) if contact >= 0.0 else -1.0,
		"time": snappedf(g.clock - (contact if contact >= 0.0 else t0), 0.5), "pulls": pulls,
		"guns": guns.size(), "guns_set_contact": guns_set_contact, "guns_set_10": guns_set_10, "guns_fired_20": guns_fired_20}
	for side in [["c", cl, 0], ["b", bl, 1]]:
		var lost := 0.0
		var left := 0.0
		var left_hp := 0.0
		var lost_k := {}
		var alive_k := {}
		for u in side[1]:
			var ok: String = _orig[u][0]
			var p: float = _orig[u][1]
			if not is_instance_valid(u) or u.dead:
				lost += p
				lost_k[ok] = int(lost_k.get(ok, 0)) + 1
			else:
				left += p
				left_hp += p * clampf(u.hp / maxf(1.0, u.max_hp), 0.0, 1.0)
				alive_k[ok] = int(alive_k.get(ok, 0)) + 1
		r[side[0] + "_lost"] = lost
		r[side[0] + "_left"] = left
		r[side[0] + "_left_hp"] = snappedf(left_hp, 0.1)
		r[side[0] + "_lost_k"] = lost_k
		r[side[0] + "_alive_k"] = alive_k
	var cfe := _fighters(cl).is_empty()
	var bfe := _fighters(bl).is_empty()
	var w := "draw"
	if bfe and not cfe:
		w = "crown"
	elif cfe and not bfe:
		w = "brood"
	elif not cfe and not bfe:
		# time: the side with clearly more left (health counted) is ahead
		var cs: float = r["c_left_hp"] / maxf(1.0, cv)
		var bs: float = r["b_left_hp"] / maxf(1.0, bv)
		w = "crown_t" if cs > bs + 0.1 else ("brood_t" if bs > cs + 0.1 else "draw")
	r["winner"] = w
	# the score: the share of the fight the Crown won, by value (0 = all the Crown lost, nothing of the Brood; 1 = the
	# reverse): what the Brood lost over what both lost
	r["score"] = snappedf(r["b_lost"] / maxf(1.0, r["b_lost"] + r["c_lost"]), 0.001)
	r["trade"] = snappedf(r["b_lost"] / maxf(1.0, r["c_lost"]), 0.01)       # value the Crown killed per value it lost
	r["riders_lost"] = 0
	for k in RIDERS:
		r["riders_lost"] += int(r["c_lost_k"].get(k, 0))
	r["guns_lost"] = int(r["c_lost_k"].get("cannon", 0)) + int(r["c_lost_k"].get("mortar", 0))
	_orig.clear()
	r["map"] = map
	r["wall_s"] = snappedf((Time.get_ticks_msec() - wall0) / 1000.0, 0.1)
	r["ver"] = String(ProjectSettings.get_setting("application/config/version", ""))
	return r


func _guns_set(guns: Array) -> int:
	var n := 0
	for u in guns:
		if is_instance_valid(u) and not u.dead and u.tesla_mode == "deployed":
			n += 1
	return n


func _crown_wave(ca: AI, list: Array, goal: Vector2, send: bool) -> void:
	ca._attacking = true
	ca._wave_target = goal
	ca._wave_set.clear()
	for u in _alive(list):
		ca._wave_set[u] = true
		if send and not (u.deploys() and u.tesla_mode != "packed"):
			u.cmd_move(goal, true)        # (a gun set up is left to the computer's gun code)


func _brood_wave(ba: AI, list: Array, goal: Vector2, send: bool) -> void:
	var al := _alive(list)
	ba._wave = al.duplicate()
	ba._wave_target = goal
	ba._wave_v0 = ba._value_of(al)
	ba._wave_t0 = g.clock
	ba._wave_kills0 = int(g.stats[1]["value_killed"])
	ba._wave_sup = 0
	for u in al:
		ba._wave_sup += int(u.d["supply"])
	ba._attacking = true
	if send:
		for u in al:
			u.cmd_move(goal, true)


# ------------------------------------------------------------------ pictures

func _shoot(file: String, at: Vector2, size: int) -> void:
	var cam: Camera2D = g.camera
	cam.position = at
	var z := 1.0 if size < 1000 else (0.8 if size < 2500 else 0.6)
	cam.zoom = Vector2(z, z)
	cam.reset_smoothing()
	for i in 3:
		await process_frame
	var img := root.get_viewport().get_texture().get_image()
	if img:
		img.save_jpg(shots.path_join(file), 0.85)
	print("SHOT " + file)
