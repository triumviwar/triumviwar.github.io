class_name AICrownMicro
## THE CROWN'S FIGHT MICRO (crown-micro, docs/crown_micro.md; the owner 2026-11-25: "until we know the Crown is doing all it
## really can... micro training the AI"). How the Crown COMPUTER's men fight once a fight is on, against the Brood: no unit
## or balance number changes, only what the computer tells its men to do. Each part was coached on the set-piece bench
## tools/bench_crown_micro.gd (equal-value fights) and kept only if it helped there beyond the noise (the doc has every
## measure). The macro (when to attack, where the wave goes) is not touched here.
## Parts (each a switch: `-- cmic:off` all of them, `-- cmic<name>:off` one; a part not KEPT is tried with `cmic<name>:on`):
##   canister  a set Field Cannon loads CANISTER when Brood soldiers are close on it and none of our men stand in its cone,
##             round shot again when they are gone (the computer never used canister: the gun's answer to a swarm)
##   focus     the Musketeers share out their volleys: no more balls into a creature than it takes to kill it, the
##             Spitters (the only Brood that shoots back from range) first, then the most hurt in reach
##   hurt      a badly hurt Musketeer with a creature on him steps back behind his friends (he lives to fire again)
## Read only for the others: `has(u)` (a man under the micro's own order this moment).

const PARTS := ["canister", "focus", "hurt"]
const KEPT: Array[String] = ["canister", "focus", "hurt"]
const EVERY := 0.2               # (s) looked at this often

# canister
const CAN_R := 165.0             # (px) Brood this near a set gun: canister (it reaches 150 + 30)
const CAN_OFF_R := 230.0         # (px) none this near for CAN_OFF_T s: round shot again
const CAN_OFF_T := 2.5
const CAN_MIN := 2               # creatures in the cone at least (or one Brute / Challenger at the gun)
const CAN_CONE := 0.78           # (a bit wider than the shot's own 0.82: own men at the cone's edge count)
const CAN_REACH := 200.0

# focus
const FOCUS_R := 40.0            # (px) beyond the musket's reach still looked at (the volley's next target)
static var SPIT_B := knob("spit", 80.0)         # the score won by a Spitter (the only Brood that shoots back from range)
static var MUSKET_DMG := knob("dmg", 17.0)      # (20 a ball, 85% of balls hit)
static var NEAR_W := knob("near", 0.15)         # the score lost a pixel of distance
static var LOW_W := knob("low", 0.4)            # ... a hit point left
static var KILL_B := knob("kill", 60.0)         # ... won by a kill with this ball

# hurt
const HURT := 0.35               # a Musketeer under this share of his hit points ...
const HURT_FOE_R := 80.0         # ... with a melee creature this near ...
const HURT_BACK := 150.0         # (px) steps back this far, behind his friends ...
const HURT_T := 3.0              # ... for this long, then back to his order
const HURT_COOL := 6.0

static var _args: PackedStringArray = OS.get_cmdline_user_args()
static var _n := {}               # team -> {counter -> n}

var ai
var game: Game
var _t := 0.0
var _can_quiet := {}             # gun -> clock when Brood were last near
var _back := {}                  # man -> {"until": t, "o": order, "p": point, "cool": t}


func _init(a) -> void:
	ai = a
	game = a.game


## A coaching knob: `-- cmic<name>:<number>` (the bench's variants), else `d`.
static func knob(name: String, d: float) -> float:
	var k := "cmic%s:" % name
	for a in _args:
		if a.begins_with(k) and a.substr(k.length()).is_valid_float():
			return a.substr(k.length()).to_float()
	return d


static func on(name: String) -> bool:
	if _args.has("cmic:off") or _args.has("cmic%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("cmic%s:on" % name)


static func count(team: int, k: String, by := 1) -> void:
	if not _n.has(team):
		_n[team] = {}
	_n[team][k] = int(_n[team].get(k, 0)) + by


static func counters(team: int) -> Dictionary:
	var o := {}
	var d: Dictionary = _n.get(team, {})
	for k in d:
		o["cmic_" + k] = d[k]
	return o


static func reset_counters() -> void:
	_n.clear()


static func _ok(u) -> bool:
	return u != null and is_instance_valid(u) and not u.dead


func active() -> bool:
	return ai.on and ai.difficulty >= 1 and ai._foe_is("brood") and not _args.has("cmic:off")


func has(u: Unit) -> bool:
	return _back.has(u)


## The Musketeer's target is the focus's to pick (AI._micro leaves it be).
func focuses(u: Unit) -> bool:
	return on("focus") and u.foot_musket() and active()


func tick() -> void:
	if not active():
		return
	_t -= game.get_physics_process_delta_time()
	if _t > 0.0:
		return
	_t = EVERY
	var t: int = ai.team
	var mine: Array = []
	for u in game.units:
		if u.team == t and not u.dead and not u.off_field and not u.aboard:
			mine.append(u)
	if on("hurt"):
		_hurt_tick(mine)
	if on("canister"):
		for u in mine:
			if u.kind == "cannon":
				_canister(u)
	if on("focus"):
		_focus(mine)


func _foes_near(p: Vector2, r: float) -> Array:
	var o: Array = []
	for e in game.units_near(p, r):
		if e.dead or e.off_field or not game.hostile(e.team, ai.team) or e.untouchable() or e.is_air():
			continue
		if game.faction_of(e.team) != "brood":
			continue
		o.append(e)
	return o


static func _melee(e: Unit) -> bool:
	return float(e.d.get("range", 0.0)) < 60.0 and e.has_attack()


# ------------------------------------------------------------------ canister

func _canister(u: Unit) -> void:
	if u.tesla_mode != "deployed":
		return
	var foes := _foes_near(u.position, CAN_OFF_R)
	if not foes.is_empty():
		_can_quiet[u] = game.clock
	var close: Array = foes.filter(func(e: Unit) -> bool: return e.position.distance_to(u.position) <= CAN_R + e.radius)
	if u.mode != "canister":
		if close.is_empty():
			return
		# the best line into them: toward their middle; own men in that cone hold it back
		var c := Vector2.ZERO
		for e in close:
			c += e.position
		c /= float(close.size())
		var best: Unit = null
		var best_n := 0
		for e in close:
			var dir: Vector2 = (e.position - u.position).normalized()
			var n := 0
			var big := false
			for o in close:
				var to: Vector2 = o.position - u.position
				if to.length() <= CAN_REACH and dir.dot(to.normalized()) > CAN_CONE:
					n += 1
					big = big or o.kind in ["brute", "tyrant_challenger"]
			if n < CAN_MIN and not (big and e.position.distance_to(u.position) < 90.0):
				continue
			if _friends_in_cone(u, dir):
				continue
			if n > best_n:
				best_n = n
				best = e
		if best == null:
			return
		u.set_canister(true)
		u.target = best
		count(ai.team, "canister")
		return
	# loaded with canister: round shot again once they are gone (or our men walked into its cone)
	if close.is_empty() and game.clock - float(_can_quiet.get(u, 0.0)) > CAN_OFF_T:
		u.set_canister(false)
		count(ai.team, "roundshot")
		return
	if u.phase == "" and _ok(u.target):
		var dir: Vector2 = (u.target.position - u.position).normalized()
		if _friends_in_cone(u, dir):
			# another creature in reach with a clear cone, else round shot again
			for e in close:
				if not _friends_in_cone(u, (e.position - u.position).normalized()):
					u.target = e
					return
			u.set_canister(false)
			count(ai.team, "roundshot")


func _friends_in_cone(u: Unit, dir: Vector2) -> bool:
	for o in game.units_near(u.position, CAN_REACH + 20.0):
		if o == u or o.dead or o.is_air() or o.team != ai.team:
			continue
		var to: Vector2 = o.position - u.position
		if to.length() < 12.0:
			continue
		if dir.dot(to.normalized()) > CAN_CONE - 0.08:
			return true
	return false


# ------------------------------------------------------------------ focus

func _focus(mine: Array) -> void:
	var incoming := {}           # creature -> damage on its way this moment
	var shooters: Array = []
	for u in mine:
		if not u.foot_musket() or u.mode == "bayonet" or u.hold_fire or _back.has(u):
			continue
		if not (u.order in ["hold", "amove", "idle"]):
			continue
		if u._pmax > 0.0 and u.powder < 1.0:
			continue
		shooters.append(u)
		if u.phase == "aim" and _ok(u.target) and u.target.is_unit():
			incoming[u.target] = float(incoming.get(u.target, 0.0)) + MUSKET_DMG
	if shooters.is_empty():
		return
	# the ones about to fire choose (aiming men keep their mark)
	for u in shooters:
		if u.phase != "" or u.cooldown > 0.6:
			continue
		var r: float = u._range()
		var best: Unit = null
		var bs := -INF
		for e in _foes_near(u.position, r + FOCUS_R + 30.0):
			var dd: float = e.edge_distance(u.position) - u.radius
			if dd > r or not u.can_hit(e) or not game.target_seen(u.team, e, u.position):
				continue
			var left: float = e.hp - float(incoming.get(e, 0.0))
			var s := 0.0
			if left <= 0.0:
				s = -dd                   # (dead already on the balls coming: only if nothing else)
			else:
				var kill_now := left <= MUSKET_DMG
				s = 1000.0 + (KILL_B if kill_now else 0.0) - left * LOW_W - dd * NEAR_W
				if e.kind == "spitter":
					s += SPIT_B
			if s > bs:
				bs = s
				best = e
		if best == null:
			continue
		if best != u.target:
			u.target = best
			count(ai.team, "focus")
		u.scan_t = maxf(u.scan_t, EVERY + 0.15)
		incoming[best] = float(incoming.get(best, 0.0)) + MUSKET_DMG


# ------------------------------------------------------------------ hurt

func _hurt_tick(mine: Array) -> void:
	for u in _back.keys():
		var s: Dictionary = _back[u]
		if not _ok(u):
			_back.erase(u)
			continue
		if s["until"] > 0.0 and game.clock >= s["until"]:
			s["until"] = 0.0
			if u.order == "move":
				if String(s["o"]) == "amove":
					u.cmd_move(s["p"], true)
				elif String(s["o"]) == "hold":
					u.cmd_hold()
				else:
					u.cmd_stop()
		if s["until"] <= 0.0 and game.clock >= s["cool"]:
			_back.erase(u)
	for u in mine:
		if not u.foot_musket() or _back.has(u) or u.hp > u.max_hp * HURT:
			continue
		if not (u.order in ["hold", "amove", "idle"]):
			continue
		var foes := _foes_near(u.position, HURT_FOE_R).filter(func(e: Unit) -> bool: return _melee(e))
		if foes.is_empty():
			continue
		var c := Vector2.ZERO
		for e in foes:
			c += e.position
		c /= float(foes.size())
		# away from them, toward the friends behind him
		var fr := Vector2.ZERO
		var nf := 0
		for o in game.units_near(u.position, 300.0):
			if o.team == u.team and o != u and not o.dead and o.has_attack():
				fr += o.position
				nf += 1
		var away: Vector2 = (u.position - c).normalized()
		if nf > 0:
			away = (away + (fr / float(nf) - u.position).normalized() * 0.5).normalized()
		var p: Vector2 = game.on_map(u.position + away * HURT_BACK)
		_back[u] = {"until": game.clock + HURT_T, "o": u.order, "p": u.order_point, "cool": game.clock + HURT_T + HURT_COOL}
		u.cmd_move(p)
		count(ai.team, "hurt")
