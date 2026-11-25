class_name AIBroodMicro
extends RefCounted
## THE BROOD'S FIGHT MICRO (brood-micro, docs/brood_micro.md; the owner 2026-11-25: "micro training the AI... until we know
## [each side] is doing all it really can", "it's only fair to make this testing to all matchups"). Only how the Brood
## computer's creatures fight once a fight is on: no unit or balance number, no macro (when the waves go, where, what is
## laid, the economy stay as they are). The Brood computer had no unit micro at all (AIBroodNew._tick_ai never ran
## AI._micro): its creatures bit the nearest enemy and kept at it.
## Each part has a switch: `-- bmic:off` all of them, `-- bmic<name>:off` one; a part not kept is tried with
## `-- bmic<name>:on`. Parts (see the doc for their numbers):
##   spread  a biter whose target it can't reach (others in the way) bites an enemy at its side instead
##   focus   in reach of several enemies, a creature bites or spits at the most hurt one (no blows wasted on a fresh one)
##   guns    a biter close to an enemy gun (cannon, Mortar, Ballista) goes for the gun
##   pack    a wave about to meet an enemy army waits for its slow ones (Spitters, Challengers) before it goes in
##   kite    a Spitter that has just spat steps back from a slower biter (a Clock Soldier, a Brute) on it
##   hurt    a badly hurt big creature (Challenger, Brute) with an enemy on it steps back behind its friends

const EVERY := 0.25             # s between looks
## The parts on by default (kept after the bench) and the ones only tried. Filled in from the measurements.
const KEPT := ["spread", "focus", "guns", "pack", "kite"]
const TRIED := ["hurt"]

static var counts := {}
static var _t := {}             # team -> time to the next look
static var _mem := {}           # team -> {unit: data} (spread: [target, since out of reach])
static var _pack := {}          # team -> {"on": bool, "t": clock it began, "done": bool}


static func reset_counters() -> void:
	counts = {}
	_mem = {}
	_pack = {}


static func counters(t: int) -> Dictionary:
	return counts.get(t, {}).duplicate()


static func _count(t: int, k: String, n := 1) -> void:
	if not counts.has(t):
		counts[t] = {}
	counts[t][k] = int(counts[t].get(k, 0)) + n


static var _args := {}
static var _teams = null


## `-- bmicteam:0`: only that team's Brood computer uses the micro (the real games of the mirror).
static func _team_ok(t: int) -> bool:
	if _teams == null:
		_teams = []
		for x in OS.get_cmdline_user_args():
			if x.begins_with("bmicteam:"):
				for y in x.substr(9).split("+"):
					_teams.append(int(y))
	return _teams.is_empty() or _teams.has(t)


static func on(name: String) -> bool:
	if _args.has(name):
		return _args[name]
	var a := OS.get_cmdline_user_args()
	var v: bool
	var only := ""
	for x in a:
		if x.begins_with("bmiconly:"):
			only = x.substr(9)
	if only != "":
		v = only.split("+").has(name)         # (the bench: these parts alone)
	elif a.has("bmic:off"):
		v = false
	elif KEPT.has(name):
		v = not a.has("bmic%s:off" % name)
	else:
		v = a.has("bmic%s:on" % name)
	_args[name] = v
	return v


## Called every physics tick by the Brood computer (AIBroodNew._tick_ai).
static func tick(ai, delta: float) -> void:
	if ai.bmic_off or ai.difficulty < 2 or not _team_ok(ai.team):
		return
	var tm: int = ai.team
	var left: float = float(_t.get(tm, 0.0)) - delta
	if left > 0.0:
		_t[tm] = left
		return
	_t[tm] = EVERY
	var g: Game = ai.game
	if not _mem.has(tm):
		_mem[tm] = {}
	var mem: Dictionary = _mem[tm]
	for k in mem.keys():
		if not is_instance_valid(k) or k.dead:
			mem.erase(k)
	if on("pack"):
		_pack_tick(ai)
	for u in g.army(tm):
		if u.has_meta("bmic_back") and not u.dead:
			_back_tick(ai, u)
		if u.dead or u.off_field or u._k_nb or u.is_worker() or u.tesla_mode != "packed" or u.is_air():
			continue
		if ai.held.has(u) or u == ai._scout or u.order in ["move", "cast", "tongue", "hold"] or u.tongue_stage != "":
			continue
		if u.kind in ["mist_toad", "grub", "hatchlings"] or not u.has_attack():
			continue
		if u.order != "amove" and u.order != "idle" and u.order != "attack":
			continue
		var melee := float(u.d["range"]) < 50.0
		if on("hurt") and _hurt(ai, u):
			continue
		if not melee and on("kite") and _kite(ai, u, mem):
			continue
		if melee and on("guns") and _guns(ai, u):
			continue
		if on("focus") and _focus(ai, u, melee):
			continue
		if melee and on("spread"):
			_spread(ai, u, mem)


static func _foe_ok(ai, u: Unit, o) -> bool:
	return o is Unit and not o.dead and not o.off_field and ai.game.hostile(o.team, ai.team) and u.can_hit(o) \
			and not o.untouchable() and o.kind != "horse"


## SPREAD: a biter (on attack-move) whose target stays out of its reach for SPREAD_T s (the others round the target are in
## the way) takes an enemy within SPREAD_R of its own edge instead, the one fewest of ours are biting.
const SPREAD_T := 0.75
const SPREAD_R := 26.0


static func _spread(ai, u: Unit, mem: Dictionary) -> void:
	var t = u.target
	if t == null or not is_instance_valid(t) or not (t is Unit) or u.phase != "":
		mem.erase(u)
		return
	var reach: float = float(u.d["range"]) + u.radius + 6.0
	if t.edge_distance(u.position) <= reach:
		mem.erase(u)
		return
	var m = mem.get(u)
	if m == null or m[0] != t:
		mem[u] = [t, ai.game.clock]
		return
	if ai.game.clock - float(m[1]) < SPREAD_T:
		return
	var best: Unit = null
	var bs := INF
	for o in ai.game.units_near(u.position, reach + SPREAD_R + 30.0):
		if o == t or not _foe_ok(ai, u, o):
			continue
		var dd: float = o.edge_distance(u.position)
		if dd > reach + SPREAD_R:
			continue
		var s: float = dd + 25.0 * float(_biters(ai, o))
		if s < bs:
			bs = s
			best = o
	if best != null:
		u.target = best
		mem.erase(u)
		_count(ai.team, "spread")


static func _biters(ai, o: Unit) -> int:
	var n := 0
	for f in ai.game.units_near(o.position, 60.0):
		if f.team == ai.team and not f.dead and f.target == o:
			n += 1
	return n


## FOCUS: a creature with several enemies in its reach bites or spits at the most hurt one (the fewest hit points left),
## a fighter before a man who doesn't fight back; only when that one would die sooner than its target now.
static func _focus(ai, u: Unit, melee: bool) -> bool:
	var t = u.target
	if t == null or not is_instance_valid(t) or u.phase != "":
		return false
	var reach: float = float(u.d["range"]) + u.radius + (4.0 if melee else 0.0)
	var best: Unit = null
	var bh := INF
	for o in ai.game.units_near(u.position, reach + 40.0):
		if not _foe_ok(ai, u, o):
			continue
		if o.edge_distance(u.position) > reach:
			continue
		var h: float = o.hp + (300.0 if not Game.fights_back(o) else 0.0)
		if h < bh:
			bh = h
			best = o
	if best == null or best == t:
		return false
	var th: float = (t.hp if t is Unit else 9999.0) + (300.0 if t is Unit and not Game.fights_back(t) else 0.0)
	if t is Unit and t.edge_distance(u.position) <= reach and bh >= th * 0.8:
		return false
	u.target = best
	_count(ai.team, "focus")
	return true


## GUNS: a biter within GUNS_R of an enemy gun (a set or limbered cannon, a Mortar, a Ballista) that nobody of ours bites
## yet goes for it, unless what it bites now is nearly dead.
const GUNS_R := 150.0
const GUNS := ["cannon", "mortar", "ballista", "tesla_cart", "arc_thrower"]


static func _guns(ai, u: Unit) -> bool:
	var t = u.target
	if t != null and is_instance_valid(t) and t is Unit and GUNS.has(t.kind):
		return false
	if t != null and is_instance_valid(t) and t is Unit and t.hp < t.max_hp * 0.25 and t.edge_distance(u.position) < 40.0:
		return false
	var best: Unit = null
	var bd := GUNS_R
	for o in ai.game.units_near(u.position, GUNS_R + 30.0):
		if not GUNS.has(o.kind) or not _foe_ok(ai, u, o):
			continue
		var dd: float = o.edge_distance(u.position)
		if dd < bd and _biters(ai, o) < 4:
			bd = dd
			best = o
	if best == null:
		return false
	u.target = best
	_count(ai.team, "guns")
	return true


## KITE: a Spitter that has just spat (its next spit more than KITE_CD s off) with an enemy biter on it (within KITE_R) that
## is slower than itself steps KITE_STEP back, away from it, and spits again.
const KITE_CD := 0.6
const KITE_R := 70.0
const KITE_STEP := 55.0


static func _kite(ai, u: Unit, mem: Dictionary) -> bool:
	if u.cooldown < KITE_CD or u.phase != "":
		return false
	var close: Unit = null
	var cd := KITE_R
	for o in ai.game.units_near(u.position, KITE_R + 30.0):
		if not (o is Unit) or o.dead or o.off_field or not ai.game.hostile(o.team, ai.team) or float(o.d["range"]) >= 50.0:
			continue
		if not o.can_hit(u) or o.speed >= u.speed * 0.95:
			continue
		var dd: float = o.position.distance_to(u.position) - o.radius - u.radius
		if dd < cd:
			cd = dd
			close = o
	if close == null:
		return false
	var away := (u.position - close.position).normalized()
	var to: Vector2 = u.position + away * KITE_STEP
	if ai.game.cell_of(to) == Vector2i(-1, -1):
		return false
	if not ai.game._walkable(ai.game.cell_of(to)):
		return false
	u.cmd_move(to)
	_count(ai.team, "kite")
	_kite_back(ai, u)
	return true


## (a kiting Spitter goes back to its attack-move once its step is done: the wave's goal; AIBroodMicro.tick)
static func _kite_back(ai, u: Unit) -> void:
	u.set_meta("bmic_back", ai.game.clock + 0.5)


static func _back_tick(ai, u: Unit) -> void:
	if ai.game.clock < float(u.get_meta("bmic_back")):
		return
	u.remove_meta("bmic_back")
	if u.order == "move" or u.order == "idle":
		u.cmd_move(ai._wave_target if ai._attacking and ai._wave.has(u) else u.position, true)


## HURT: a Challenger or Brute under HURT_K of its health with an enemy biting it steps back HURT_STEP toward its friends'
## middle (out of the front), once per HURT_GAP s.
const HURT_K := 0.3
const HURT_STEP := 90.0


static func _hurt(ai, u: Unit) -> bool:
	if not u.kind in ["tyrant_challenger", "brute", "venom_challenger"] or u.hp > u.max_hp * HURT_K:
		return false
	if u.has_meta("bmic_hurt"):
		return false
	var c := Vector2.ZERO
	var n := 0
	for f in ai.game.units_near(u.position, 300.0):
		if f.team == ai.team and not f.dead and not f.is_worker() and f != u:
			c += f.position
			n += 1
	if n < 3:
		return false
	c /= float(n)
	var to: Vector2 = u.position + (c - u.position).normalized() * HURT_STEP
	u.set_meta("bmic_hurt", true)
	u.cmd_move(to)
	_count(ai.team, "hurt")
	_kite_back(ai, u)
	return true


## PACK: a wave on the road (nobody of it fighting yet, more than PACK_GOAL tiles from its goal) keeps together: a creature
## more than PACK_GAP tiles ahead of the wave's bulk (the point 7 in 10 of it have passed: the slow Spitters and
## Challengers, the ones held up round a hill) waits on the spot until the bulk comes up. At the first contact (an enemy fighter within reach of any of the wave) all go in
## together. Knows nothing it has not seen: it is how the wave walks, not a reaction to the enemy. (The Brood computer's own
## close-ranks, AIBroodNew._nb_close_ranks, does it only against the Clockwork and only for its first 75 s; its gathering
## only against another Brood: not while either is on.)
const PACK_GAP := 3.0
const PACK_GOAL := 12.0
const PACK_MIN := 2
const SLOW := ["spitter", "tyrant_challenger", "brute", "venom_challenger", "mist_toad", "storm_challenger"]


static func _pack_tick(ai) -> void:
	var tm: int = ai.team
	var st: Dictionary = _pack.get(tm, {"on": false, "w": -1.0, "done": false})
	_pack[tm] = st
	if not ai._attacking or ai._wave.size() < 8 or ai._closing or ai._gather_w_on or ai._nb_hunting:
		if st["on"]:
			_pack_release(ai, st)
		return
	if float(st["w"]) != ai._wave_t0:
		st["w"] = ai._wave_t0          # (a new wave)
		st["done"] = false
	if st["done"]:
		return
	var g: Game = ai.game
	var goal: Vector2 = ai._wave_target
	var wave: Array = ai._wave.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)
	var slow: Array = wave.filter(func(u) -> bool: return SLOW.has(u.kind))
	var fast: Array = wave.filter(func(u) -> bool: return not SLOW.has(u.kind))
	if slow.size() < PACK_MIN or fast.is_empty():
		_pack_release(ai, st)
		st["done"] = true
		return
	var ds: Array = []
	var lead := INF
	for u in wave:
		var d0: float = u.position.distance_to(goal)
		ds.append(d0)
		lead = minf(lead, d0)
	ds.sort()
	var sd: float = ds[mini(ds.size() - 1, int(ds.size() * 0.7))]       # (the bulk: 7 in 10 of the wave are ahead of it)
	var contact := lead < PACK_GOAL * Defs.TILE
	if not contact:
		for u in wave:
			if u.order == "hold" and u.has_meta("bmic_pack"):
				pass
			for o in g.units_near(u.position, float(u.d["range"]) + u.radius + 140.0):
				if o.team >= 0 and not o.dead and not o.off_field and g.hostile(o.team, tm) and o.has_attack() and not o.is_worker() 						and g.is_visible_to(tm, o.position):
					contact = true
					break
			if contact:
				break
	if contact:
		_pack_release(ai, st)
		st["done"] = true          # (once the fight is on, the wave fights: no waiting again)
		return
	var waiting := 0
	for u in wave:
		var d: float = u.position.distance_to(goal)
		if d < sd - PACK_GAP * Defs.TILE:
			if u.order == "amove":
				u.set_meta("bmic_pack", true)
				u.cmd_hold()
				_count(tm, "pack_wait")
			waiting += 1
		elif u.order == "hold" and u.has_meta("bmic_pack"):
			u.remove_meta("bmic_pack")
			u.cmd_move(goal, true)
	if waiting > 0 and not st["on"]:
		_count(tm, "pack")
	st["on"] = waiting > 0


static func _pack_release(ai, st: Dictionary) -> void:
	st["on"] = false
	for u in ai._wave:
		if is_instance_valid(u) and not u.dead and u.has_meta("bmic_pack"):
			u.remove_meta("bmic_pack")
			if u.order == "hold":
				u.cmd_move(ai._wave_target, true)


static func _mid(list: Array) -> Vector2:
	var c := Vector2.ZERO
	var n := 0
	for u in list:
		c += u.position
		n += 1
	return c / float(n) if n > 0 else Vector2.ZERO
