class_name AICwMicro
## THE CLOCKWORK'S FIGHT MICRO (clockwork-micro, docs/clockwork_micro.md; the owner 2026-11-25: "micro training the AI...
## it's only fair to make this testing to all matchups"). How the Clockwork COMPUTER's machines fight once a fight is on,
## against the Crown, the Brood and the Clockwork: no unit or balance number changes, only what the computer tells its
## machines to do. Each part was coached on the set-piece bench tools/bench_clockwork_micro.gd (equal-value fights) and kept
## only if it helped there beyond the noise (the doc has every measure). The macro (when to attack, what to build, where
## the push goes) is not touched here.
## Every part is a switch: `-- cwmic:off` all of them, `-- cwmic<name>:off` one; a part not KEPT is tried with
## `cwmic<name>:on`. The parts are listed in PARTS with what each does in its own section below.

##   close     a Clock Soldier or Pendulum standing in the enemy's fire (a shooter that reaches it) with nothing of its own
##             in reach goes for the nearest shooter (the push's screen held it still while Spitters and Musketeers shot it)
##   mend      a hurt machine (Pendulum, Netter, Springer, Ballista under MEND_AT of its health) in a fight steps back to
##             the nearest escort Winder out of the enemy's reach, and goes back in mended
##   springpick a ready Springer jumps at the enemy's guns (Field Cannon, Mortar) or its Spitters, not only the nearest foe
##   bail      the push pulls back early from a fight it is clearly losing (it has lost BAIL_LOST of its value there and
##             killed less than BAIL_K of what it lost), before the rest is shot down on the way home
##   pick      a Clock Soldier on a melee foe with a shooter just beside it goes for the shooter
##   charge    the push in a fight with enemy shooters standing off out of its screen: the whole front goes at them together
##             (its anchor moves onto them), not each machine on its own (that was `close`: worse)
##   flank     the enemy's guns and shooters stand behind its melee front (the bench: 0 of 13 Spitters, 0 of 4 Field
##             Cannons ever reached): a FLANK GROUP (a share of the Clock Soldiers on the outer end of the line, and the
##             Springers) walks round the side of the fight and falls on that back line
##   safe      the escort Winders keep out of the enemy shooters' reach: no winding or mending a machine that stands in
##             it (unless it has run down), and a Winder standing in it steps back (real games v the Crown: ~80 Winders
##             lost a game, 236 of 470 to Musketeers, a fifth of them while winding)

const PARTS := ["close", "mend", "springpick", "bail", "pick", "charge", "flank", "safe"]
const KEPT: Array[String] = []
const EVERY := 0.2               # (s) looked at this often

static var _args: PackedStringArray = OS.get_cmdline_user_args()
static var _n := {}               # team -> {counter -> n}
static var ONLY_TEAM := knob("team", -1.0)

var ai
var game: Game
var team := 0
var _t := 0.0
var _mine := {}                  # Unit -> clock: the micro's own order until then (the push and the army leave it be)
var _mend := {}                  # Unit -> clock it stepped back
var _fight_v := -1.0             # the push's value when its fight began (bail)
var _fight_k := 0.0
var _fight_t := 0.0

const MELEE := ["clock_soldier", "pendulum"]
const CLOSE_R := 380.0           # (px) a shooter this near (and reaching us) is gone for
const CLOSE_T := 4.0             # (s) the order is the micro's this long
const MEND_AT := 0.4
const MEND_BACK := 520.0         # (px) a Winder this near
const MEND_DONE := 0.75
const MEND_MAX := 14.0
const SPRING_LAND := 0.75        # lands this share of its reach from the target
static var BAIL_LOST := knob("baillost", 0.35)
static var BAIL_K := knob("bailk", 0.45)
const BAIL_AFTER := 5.0
static var CHARGE_SHARE := knob("chargeshare", 0.35)  # the shooters this share of the foes near at least
const CHARGE_R := 560.0          # (px) shooters this near the anchor
const CHARGE_GAP := 200.0        # (px) the nearest shooter farther than this from the anchor: the front is not on them
const CHARGE_STEP := 160.0       # (px) the anchor moves this far toward them a look
static var PICK_R := knob("pickr", 90.0)        # (px) a shooter this near ...
static var PICK_N := knob("pickn", 1.0)         # ... and at least this many shooters that near          # (s) of fight at least


func _init(a) -> void:
	ai = a
	game = a.game
	team = a.team


## A coaching knob: `-- cwmic<name>:<number>` (the bench's variants), else `d`.
static func knob(name: String, d: float) -> float:
	var k := "cwmic%s:" % name
	for a in _args:
		if a.begins_with(k) and a.substr(k.length()).is_valid_float():
			return a.substr(k.length()).to_float()
	return d


static func on(name: String) -> bool:
	if _args.has("cwmic:off") or _args.has("cwmic%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("cwmic%s:on" % name)


static func count(t: int, k: String, by := 1) -> void:
	if not _n.has(t):
		_n[t] = {}
	_n[t][k] = int(_n[t].get(k, 0)) + by


static func counters(t: int) -> Dictionary:
	var o := {}
	var d: Dictionary = _n.get(t, {})
	for k in d:
		o["cwmic_" + k] = d[k]
	return o


static func reset_counters() -> void:
	_n.clear()


## Every physics tick (AIClockwork._cav_tick); the parts look every EVERY s.
func tick(delta: float) -> void:
	if ONLY_TEAM >= 0 and team != int(ONLY_TEAM):
		return              # (`-- cwmicteam:0`: only that team's computer coached: the mirror's measures)
	_t -= delta
	if _t > 0.0:
		return
	_t = EVERY

	if game.over:
		return
	var army: Array = game.army(team)
	for u in _mine.keys():
		if not is_instance_valid(u) or u.dead or game.clock > float(_mine[u]):
			_mine.erase(u)
	if on("bail"):
		_bail()
	if on("mend"):
		_mend_tick(army)
	if on("springpick"):
		_spring_pick(army)
	if on("close"):
		_close(army)
	if on("pick"):
		_pick(army)
	if on("charge"):
		_charge()
	if on("flank"):
		_flank()
	if on("safe"):
		_safe()


## The micro's own order this moment: the push and the one army leave the unit be.
func has(u: Unit) -> bool:
	return _mine.has(u) or _mend.has(u)


func _hostile_unit(o) -> bool:
	return o is Unit and not o.dead and not o.off_field and game.hostile(o.team, team) and not o.is_worker() \
			and o.has_attack() and game.is_visible_to(team, o.position)


func _shooter(o: Unit) -> bool:
	return float(o.d.get("range", 0.0)) >= 100.0


func _in_reach(u: Unit, t) -> bool:
	return t != null and is_instance_valid(t) and not t.dead and t.edge_distance(u.position) <= u._range() + u.radius + 10.0


func _busy(u: Unit) -> bool:
	if u.powered_down() or u.net_t > 0.0 or u.siege_t > 0.0 or u.order == "cast":
		return true
	if ai.push != null and ai.push.has(u):
		return false        # (the push's: the micro's to fight with)
	return ai._on_errand(u)     # (the Springer raid, the rush, the Owl raids: their own fights)


# ------------------------------------------------------------------ close: no standing still in the enemy's fire

func _close(army: Array) -> void:
	for u in army:
		if not MELEE.has(u.kind) or _busy(u) or has(u) or u.is_air():
			continue
		if _in_reach(u, u.target):
			continue
		var best: Unit = null
		var bd := CLOSE_R
		var shot := false
		var melee_near := false
		for o in game.units_near(u.position, CLOSE_R):
			if not _hostile_unit(o):
				continue
			var dd: float = o.position.distance_to(u.position)
			if not _shooter(o):
				if dd < 70.0 and u.can_hit(o):
					melee_near = true
				continue
			if dd <= float(o.d["range"]) + 40.0:
				shot = true
			if dd < bd and u.can_hit(o) and game.level_of(o.position) <= game.level_of(u.position):
				bd = dd
				best = o
		if not shot or melee_near or best == null:
			continue
		u.cmd_attack(best)
		_mine[u] = game.clock + CLOSE_T
		count(team, "close")


# ------------------------------------------------------------------ pick: the shooter beside the melee foe

func _pick(army: Array) -> void:
	for u in army:
		if u.kind != "clock_soldier" or _busy(u) or _mend.has(u):
			continue
		var t = u.target
		if t == null or not is_instance_valid(t) or t.dead or not (t is Unit) or _shooter(t):
			continue
		var best: Unit = null
		var bd := PICK_R
		var n := 0
		for o in game.units_near(u.position, PICK_R):
			if _hostile_unit(o) and _shooter(o) and u.can_hit(o):
				n += 1
				var dd: float = o.position.distance_to(u.position)
				if dd < bd:
					bd = dd
					best = o
		if best != null and n >= int(PICK_N):
			u.cmd_attack(best)
			_mine[u] = game.clock + 3.0
			count(team, "pick")


# ------------------------------------------------------------------ mend: hurt machines back to the Winders

func _mend_tick(army: Array) -> void:
	for u in _mend.keys():
		if not is_instance_valid(u) or u.dead or u.hp >= u.max_hp * MEND_DONE or game.clock - float(_mend[u]) > MEND_MAX:
			if is_instance_valid(u) and not u.dead:
				var back_to: Vector2 = ai.push.anchor if ai.push != null and ai.push.has(u) and ai.push.anchor != Vector2.INF else u.position
				u.cmd_move(back_to, true)
			_mend.erase(u)
	var esc: Array = ai._escort.filter(func(w) -> bool: return is_instance_valid(w) and not w.dead)
	if esc.is_empty():
		return
	for u in army:
		if _mend.has(u) or not (u.kind in [Defs.PENDULUM, Defs.NETTER, Defs.SPRINGER, Defs.BALLISTA_KIND]) or _busy(u):
			continue
		if u.hp >= u.max_hp * MEND_AT or u.target == null:
			continue
		var best: Unit = null
		var bd := MEND_BACK
		for w in esc:
			var dd: float = w.position.distance_to(u.position)
			if dd < bd and not ai._enemy_near(w.position, 170.0):
				bd = dd
				best = w
		if best == null:
			continue
		_mend[u] = game.clock
		u.cmd_move(best.position + (best.position - u.position).normalized() * 30.0)
		if not best.order == "repair":
			best.cmd_repair(u)
		count(team, "mend")


# ------------------------------------------------------------------ springpick: the guns and the Spitters

func _spring_pick(army: Array) -> void:
	var jr := float(Defs.SPRINGER_JUMP["range"])
	for u in army:
		if u.kind != Defs.SPRINGER or _busy(u) or _mend.has(u) or u.hp < u.max_hp * 0.6 or Springer.ready_problem(u) != "":
			continue
		var rng: float = float(u.d["range"])
		var best: Unit = null
		var bs := 0.0
		for o in game.units_near(u.position, rng + jr):
			if not _hostile_unit(o):
				continue
			var w := 0.0
			if o.kind == "cannon" or o.kind == "mortar":
				w = 3.0
			elif o.kind == "spitter" or o.kind == Defs.BALLISTA_KIND:
				w = 1.5
			if w <= 0.0:
				continue
			var dd: float = o.position.distance_to(u.position)
			if dd <= rng:
				best = null
				break           # (one in reach already: it shoots from where it is)
			var sc := w / (1.0 + dd / 200.0)
			if sc > bs:
				bs = sc
				best = o
		if best == null:
			continue
		var land: Vector2 = best.position + (u.position - best.position).normalized() * rng * SPRING_LAND
		var melee := 0
		for o in game.units_near(land, 90.0):
			if _hostile_unit(o) and not _shooter(o):
				melee += 1
		if melee >= 2:
			continue
		var l: Dictionary = Springer.landing(u, land)
		if not l.has("at"):
			continue
		Springer.start(u, l["at"])
		u.target = best
		_mine[u] = game.clock + 3.0
		count(team, "springpick")


# ------------------------------------------------------------------ bail: out of a lost fight early

func _bail() -> void:
	var p = ai.push
	if p == null or p.phase != "fight":
		_fight_v = -1.0
		return
	var now: float = p._value(p.units)
	if _fight_v < 0.0:
		_fight_v = now
		_fight_k = float(game.stats[team]["value_killed"])
		_fight_t = game.clock
		return
	if game.clock - _fight_t < BAIL_AFTER:
		return
	var lost := _fight_v - now
	var killed := float(game.stats[team]["value_killed"]) - _fight_k
	if lost >= _fight_v * BAIL_LOST and killed < lost * BAIL_K:
		var fv: float = p._value(p._foes_near(p._front_centre(), 500.0))
		if fv < now * 0.6:
			return              # (they are nearly done too: it fights on)
		count(team, "bail")
		p._retreat("micro: a losing fight, lost %d of %d here, killed %d" % [int(lost), int(_fight_v), int(killed)])
		_fight_v = -1.0


# ------------------------------------------------------------------ charge: the whole front at the shooters

var _charging := false


func _charge() -> void:
	var p = ai.push
	if p == null or p.phase != "fight" or p.anchor == Vector2.INF:
		_charging = false
		return
	var foes: Array = p._foes_near(p.anchor, CHARGE_R)
	if foes.is_empty():
		return
	var sv := 0.0
	var fv := 0.0
	var c := Vector2.ZERO
	var nd := INF
	var lv: int = game.level_of(p.anchor)
	for o in foes:
		var v: float = ai._unit_value(o)
		fv += v
		if _shooter(o) and game.level_of(o.position) <= lv:
			sv += v
			c += o.position * v
			nd = minf(nd, o.position.distance_to(p.anchor))
	if sv <= 0.0 or sv < fv * CHARGE_SHARE or nd <= CHARGE_GAP:
		return
	c /= sv
	var to: Vector2 = p.anchor.move_toward(c, CHARGE_STEP)
	if game.level_of(to) > lv:
		return
	p.anchor = to
	if not _charging:
		_charging = true
		count(team, "charge")


# ------------------------------------------------------------------ flank: round the side onto the back line

static var FLANK_SHARE := knob("flankshare", 0.33)   # of the push's Clock Soldiers
static var FLANK_BACK := knob("flankback", 100.0)       # (px) a shooter this far behind the enemy's nearest to us is "the back line"
const FLANK_WIDE := 260.0        # (px) the way round passes this far out to the side of the back line
const FLANK_MIN := 6             # Clock Soldiers at least in the push
const FLANK_T := 20.0            # (s) a flank lasts at most this
var _flank_g := {}               # Unit -> {"stage", "wp"}
var _flank_t := -99.0


func _flank() -> void:
	var p = ai.push
	for u in _flank_g.keys():
		if not is_instance_valid(u) or u.dead:
			_flank_g.erase(u)
	if p == null or p.phase != "fight" or p.anchor == Vector2.INF:
		for u in _flank_g.keys():
			_mine.erase(u)
		_flank_g.clear()
		return
	if not _flank_g.is_empty():
		_flank_go()
		return
	if game.clock - _flank_t < FLANK_T:
		return
	var foes: Array = p._foes_near(p.anchor, 700.0)
	var front: Array = p.units.filter(func(u: Unit) -> bool: return u.kind == "clock_soldier" and not _busy(u))
	if foes.is_empty() or front.size() < FLANK_MIN:
		return
	var fc: Vector2 = p._centre(front)
	var near_d := INF
	for o in foes:
		near_d = minf(near_d, o.position.distance_to(fc))
	var back: Array = foes.filter(func(o: Unit) -> bool: return (_shooter(o) or o.kind in ["cannon", "mortar"]) and o.position.distance_to(fc) > near_d + FLANK_BACK)
	var bv := 0.0
	var fv := 0.0
	for o in foes:
		fv += ai._unit_value(o)
	for o in back:
		bv += ai._unit_value(o)
	if back.size() < 2 or bv < fv * 0.18:
		return
	var bc: Vector2 = p._centre(back)
	var dir: Vector2 = (bc - fc).normalized()
	var side := Vector2(-dir.y, dir.x)
	# (round the side with fewer enemies; the units at that end of our line go)
	var lv := 0.0
	for o in foes:
		lv += signf((o.position - fc).dot(side)) * ai._unit_value(o)
	var sgn := -1.0 if lv > 0.0 else 1.0
	front.sort_custom(func(a: Unit, b: Unit) -> bool: return (a.position - fc).dot(side) * sgn > (b.position - fc).dot(side) * sgn)
	var n := maxi(3, int(round(float(front.size()) * FLANK_SHARE)))
	var group: Array = front.slice(0, n)
	for u in p.units:
		if u.kind == Defs.SPRINGER and not _busy(u):
			group.append(u)
	var wp: Vector2 = bc + side * sgn * FLANK_WIDE - dir * 60.0
	if game.level_of(wp) != game.level_of(bc):
		wp = bc + side * sgn * FLANK_WIDE * 0.6
	for u in group:
		_flank_g[u] = {"stage": 0, "wp": wp, "bc": bc, "t": game.clock}
		u.cmd_move(wp, false)
		_mine[u] = game.clock + FLANK_T
	_flank_t = game.clock
	count(team, "flank")
	count(team, "flank_units", group.size())


func _flank_go() -> void:
	for u in _flank_g.keys():
		var e: Dictionary = _flank_g[u]
		if game.clock - float(e["t"]) > FLANK_T:
			_flank_g.erase(u)
			_mine.erase(u)
			continue
		_mine[u] = game.clock + 1.0
		if int(e["stage"]) == 0:
			if u.position.distance_to(e["wp"]) < 70.0 or game.clock - float(e["t"]) > 7.0 or (u.order == "idle"):
				e["stage"] = 1
				var best: Unit = null
				var bd := 520.0
				for o in game.units_near(u.position, 520.0):
					if _hostile_unit(o) and (_shooter(o) or o.kind in ["cannon", "mortar"]):
						var dd: float = o.position.distance_to(e["bc"])
						if dd < bd:
							bd = dd
							best = o
				if best != null:
					u.cmd_attack(best)
				else:
					u.cmd_move(e["bc"], true)
		elif u.target == null or not is_instance_valid(u.target) or u.target.dead:
			var best2: Unit = null
			var bd2 := 300.0
			for o in game.units_near(u.position, 300.0):
				if _hostile_unit(o):
					var dd2: float = o.position.distance_to(u.position) - (120.0 if _shooter(o) else 0.0)
					if dd2 < bd2:
						bd2 = dd2
						best2 = o
			if best2 != null:
				u.cmd_attack(best2)


# ------------------------------------------------------------------ safe: the Winders out of the shooters' reach

const SAFE_MARGIN := 30.0        # (px) past a shooter's reach
const SAFE_STEP := 110.0         # (px) a Winder in reach steps back this far


## The nearest visible enemy shooter that reaches p (with SAFE_MARGIN), or null.
func _shot_at(p: Vector2) -> Unit:
	for e in game.units_near(p, 300.0):
		if e.dead or e.off_field or not game.hostile(e.team, team) or e.is_worker() or not e.has_attack():
			continue
		var r := float(e.d.get("range", 0.0))
		if r < 100.0 or r > 260.0 or e.position.distance_to(p) > r + SAFE_MARGIN or not game.is_visible_to(team, e.position):
			continue
		return e
	return null


## (AI._escort_wind asks) a machine the escort should not go to now: it stands in reach of an enemy shooter (a run-down
## one is still fetched: it is lost for good otherwise).
func unsafe(o: Unit) -> bool:
	if not on("safe") or o.powered_down():
		return false
	if _shot_at(o.position) != null:
		count(team, "safe_skip")
		return true
	return false


func _safe() -> void:
	for w in ai._escort:
		if not is_instance_valid(w) or w.dead or w.order == "build":
			continue
		var t = w.order_target if w.order == "repair" else null
		if t != null and is_instance_valid(t) and t is Unit and t.powered_down():
			continue
		var e := _shot_at(w.position)
		if e == null:
			continue
		w.cmd_move(w.position + (w.position - e.position).normalized() * SAFE_STEP)
		count(team, "safe_step")
