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

const PARTS := ["close", "mend", "springpick", "bail", "pick"]
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
const BAIL_AFTER := 5.0          # (s) of fight at least


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
		var bd := 90.0
		for o in game.units_near(u.position, 90.0):
			if _hostile_unit(o) and _shooter(o) and u.can_hit(o):
				var dd: float = o.position.distance_to(u.position)
				if dd < bd:
					bd = dd
					best = o
		if best != null:
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
