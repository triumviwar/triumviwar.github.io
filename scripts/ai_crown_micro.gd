class_name AICrownMicro
## THE CROWN'S FIGHT MICRO (crown-micro, docs/crown_micro.md; the owner 2026-11-25: "until we know the Crown is doing all it
## really can... micro training the AI"). How the Crown COMPUTER's men fight once a fight is on, against the Brood: no unit
## or balance number changes, only what the computer tells its men to do. Each part was coached on the set-piece bench
## tools/bench_crown_micro.gd (equal-value fights); KEPT (on by default) are the four that helped there: riders, brace,
## kite, gunpick (together +0.09 of the score on the real armies, k/l 2.4 -> 3.5). canister, hurt and focus measured no
## better or worse and are off (the doc has every measure). The macro (when to attack, where the wave goes) is not touched here.
## Parts (each a switch: `-- cmic:off` all of them, `-- cmic<name>:off` one; a part not KEPT is tried with `cmic<name>:on`):
##   canister  a set Field Cannon loads CANISTER when Brood soldiers are close on it and none of our men stand in its cone,
##             round shot again when they are gone (the computer never used canister: the gun's answer to a swarm)
##   focus     the Musketeers share out their volleys: no more balls into a creature than it takes to kill it, the
##             Spitters (the only Brood that shoots back from range) first (`cmicspit:` its bonus, 0 = none), then the
##             most hurt in reach; shooting the Spitters first measured WORSE (the Raptors in front must die first)
##   hurt      a badly hurt Musketeer with a creature on him steps back behind his friends (he lives to fire again)
##   riders    a Horseman standing out of the fight (on the screen's flank post, idle) while the Brood is at our men or
##             guns rides in at the creature nearest the guns (the hit and run, AICavMicro, takes him from there)
##   gunpick   a set Field Cannon's round shot goes for the armoured creatures (Brutes, Challengers: it hits them 1.75 times)
##             and a Mortar's shell for the thickest clump, never where our own men are
##   kite      a reloading Musketeer steps back from a melee creature slower than he is (the Brute)
##   brace     a Brood force coming at the marching wave: the men halt where they are and the guns set, so the Brood walks
##             into their fire instead of the men walking into it in a column
## (crown-micro-2, docs/crown_micro_2.md: the same coaching against the Clockwork and in the mirror; new parts)
##   backline  a healthy Horseman out of the fight rides for the enemy's soft back line within reach (the Clockwork's
##             Winders, Netters, Ballistas, Great Winder; the Crown's set guns, Powder Wagons and musicians) when few of
##             its fighters stand by it
##   winders   a Musketeer about to fire takes an enemy SUPPORT unit in his reach first (a Winder winding and mending the
##             Clockwork army, a Great Winder; the Crown's musicians, Powder Wagon, Missionary)
##   counter   our set guns fire at the enemy's guns first (Ballistas, Netters; Field Cannons and Mortars): the guns that
##             out-reach or stop our line
##   fieldline (where the crown-rule-cleanup cut the line: against the Clockwork) the line on the wave's march only: it
##             forms before a seen enemy, steps on with its guns set, falls back in order (AICrownLine.march); not the
##             defence's lines and posts at home, not the rider screen
##   shields   (against the Clockwork) a Musketeer about to fire leaves a Clock Soldier whose SHIELD FORWARD faces him for
##             another one in reach (side-on, the shield down, or not a Clock Soldier)
## Read only for the others: `has(u)` (a man under the micro's own order this moment).

const PARTS := ["canister", "focus", "hurt", "riders", "gunpick", "kite", "brace", "backline", "winders", "counter", "shields", "fieldline"]
## (crown-micro-2, docs/crown_micro_2.md) the parts kept, by the enemy's faction ("crown" = the mirror). A part not listed
## for a matchup is off there (`-- cmic<name>:on` tries it in every matchup).
const KEPT_BY := {
	"brood": ["riders", "brace", "kite", "gunpick"],
	"clockwork": ["gunpick", "kite", "hurt", "winders"],
	"crown": ["brace", "gunpick"],
}
const KEPT: Array[String] = ["riders", "brace", "kite", "gunpick"]      # (the Brood's: kept for old readers)
## (crown-micro-2) the bench's mirror: the enemy Crown computer fights as before (its micro off), so the bench measures
## the parts against the old Crown. Never set in a real match.
## `-- cmicoff:<team>` does the same in a real game (the mirror's study: one Crown with the parts, one without).
static var off_team := int(knob("off", -1.0))
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

# riders
const RIDE_FIGHT_R := 650.0      # (px) Brood soldiers this near our men or guns: a fight the riders join
const RIDE_IDLE_R := 300.0       # (px) a rider with no Brood soldier this near is out of the fight
const RIDE_COOL := 3.0
static var RIDE_WHO := knob("ridewho", 0.0)     # 1: only for creatures at the guns and Spitters

# gunpick
const MORTAR_CLUMP := 48.0       # (px) the shell's splash counted this wide

# backline / winders / counter / shields (crown-micro-2)
const SOFT := {
	"clockwork": ["winder", "netter", "ballista", "great_winder"],
	"crown": ["cannon", "mortar", "powder_wagon", "band", "band_fifer", "band_piper", "missionary"],
	"brood": ["spitter", "grub"],
}
const SUPPORT := {
	"clockwork": ["winder", "great_winder"],
	"crown": ["band", "band_fifer", "band_piper", "powder_wagon", "missionary"],
	"brood": [],
}
const GUNS := {
	"clockwork": ["ballista", "netter"],
	"crown": ["cannon", "mortar"],
	"brood": ["spitter"],
}
const BACK_REACH := 900.0        # (px) a back-line target this near the rider
const BACK_GUARD_R := 110.0      # (px) enemy fighters this near the target ...
const BACK_GUARD_N := 3          # ... at most this many (more: a fight he would die in)
const BACK_COOL := 4.0
const BACK_HP := 0.55

# kite
const KITE_R := 75.0
const KITE_STEP := 55.0
const KITE_T := 0.8

# brace
const BRACE_R := 620.0           # (px) a Brood force this near the wave's middle, coming on
const BRACE_SHARE := 0.25        # ... worth this share of the wave
const BRACE_MAX := 7.0           # (s) halted at most this long (the fight comes or the march goes on)
const BRACE_COOL := 25.0

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
var _ride := {}                  # rider -> clock he was last sent in
var _kite := {}                  # man -> clock his step back ends
var _brace_until := 0.0
var _brace_next := 0.0
var _braced: Array = []
var _back_t := {}                # rider -> clock he was last sent at the back line
var _picked := {}                # Musketeer -> clock the winders / shields part last chose his target


func _init(a) -> void:
	ai = a
	game = a.game


## A coaching knob: `-- cmic<name>:<number>` (the bench's variants), else `d`.
static func knob(name: String, d: float) -> float:
	var k := "cmic%s:" % name
	for a in OS.get_cmdline_user_args():       # (not _args: a static var above it may ask first)
		if a.begins_with(k) and a.substr(k.length()).is_valid_float():
			return a.substr(k.length()).to_float()
	return d


static func on(name: String, foe := "brood") -> bool:
	if _args.has("cmic:off") or _args.has("cmic%s:off" % name):
		return false
	return (KEPT_BY.get(foe, []) as Array).has(name) or _args.has("cmic%s:on" % name)


## This computer's enemy faction ("" when none): the matchup the parts are kept for.
func foe() -> String:
	var f: int = ai._foe()
	return game.faction_of(f) if f >= 0 else ""


func want(name: String) -> bool:
	return on(name, _foe_f)


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


var _foe_f := ""


func active() -> bool:
	if not ai.on or ai.difficulty < 1 or _args.has("cmic:off") or ai.team == off_team:
		return false
	_foe_f = foe()
	return KEPT_BY.has(_foe_f)


## (AICrownLine.field) the line on the march, where the cleanup cut it.
func field_line() -> bool:
	return active() and want("fieldline")


func has(u: Unit) -> bool:
	return _back.has(u) or _kite.has(u)


## The Musketeer's target is the focus's to pick (AI._micro leaves it be).
func focuses(u: Unit) -> bool:
	if not u.foot_musket() or not active():
		return false
	return want("focus") or game.clock - float(_picked.get(u, -99.0)) < 0.6


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
	if want("brace"):
		_brace(mine)
	if want("hurt"):
		_hurt_tick(mine)
	if want("kite"):
		_kite_tick(mine)
	if want("riders"):
		_riders(mine)
	if want("gunpick"):
		for u in mine:
			if u.kind == "cannon" or u.kind == "mortar":
				_gunpick(u)
	if want("canister"):
		for u in mine:
			if u.kind == "cannon":
				_canister(u)
	if want("focus"):
		_focus(mine)
	if want("backline"):
		_backline(mine)
	if want("counter"):
		for u in mine:
			if u.kind == "cannon" or u.kind == "mortar":
				_counter(u)
	if want("winders") or want("shields"):
		_pick_shots(mine)


func _foes_near(p: Vector2, r: float) -> Array:
	var o: Array = []
	for e in game.units_near(p, r):
		if e.dead or e.off_field or not game.hostile(e.team, ai.team) or e.untouchable() or e.is_air():
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


# ------------------------------------------------------------------ riders

func _riders(mine: Array) -> void:
	var anchors: Array = mine.filter(func(u: Unit) -> bool: return u.has_attack() and not u.kind in ["cuirassier", "dragoon"])
	for u in mine:
		if u.kind != "cuirassier" or u.is_worker():
			continue
		var screened: bool = ai.sc != null and ai.sc.has(u)
		if u.hp < u.max_hp * 0.4 or (ai._on_errand(u) and not screened) or (ai.cav != null and ai.cav.has(u)):
			continue
		if game.clock - float(_ride.get(u, -99.0)) < RIDE_COOL:
			continue
		if not u.order in ["idle", "move", "hold"]:
			continue
		if not _foes_near(u.position, RIDE_IDLE_R).is_empty():
			continue
		# the fight: Brood soldiers at our men or guns, within reach of a ride
		var best: Unit = null
		var bs := INF
		for a in anchors:
			if a.position.distance_to(u.position) > RIDE_FIGHT_R + 400.0:
				continue
			for e in _foes_near(a.position, 200.0 if a.kind in ["cannon", "mortar"] else 140.0):
				if not e.has_attack():
					continue
				if RIDE_WHO >= 1.0 and not (a.kind in ["cannon", "mortar"] or e.kind == "spitter"):
					continue          # (the line's own fight is the Musketeers': the riders come for the guns and the Spitters)
				var s: float = e.position.distance_to(u.position) - (250.0 if a.kind in ["cannon", "mortar"] else 0.0) \
						- (150.0 if e.kind == "spitter" else 0.0) + (200.0 if e.kind == "brute" else 0.0)
				if s < bs:
					bs = s
					best = e
		if best == null:
			continue
		_ride[u] = game.clock
		if screened:
			ai.sc._release(u, "")         # (off the screen: the fight is here)
			count(ai.team, "riders_screen")
		u.cmd_move(best.position, true)
		count(ai.team, "riders")


# ------------------------------------------------------------------ gunpick

func _gunpick(u: Unit) -> void:
	if u.tesla_mode != "deployed" or u.mode == "canister" or u.phase != "" or u.cooldown > 0.5 or u.hold_fire:
		return
	if not u.order in ["hold", "amove", "idle"]:
		return
	var r: float = u._range()
	var min_r := float(u.d.get("min_range", 0.0))
	var best: Unit = null
	var bs := 0.0
	for e in _foes_near(u.position, r + 30.0):
		var dd: float = e.edge_distance(u.position) - u.radius
		if dd > r or dd < min_r or not u.can_hit(e) or not game.side_sees(ai.team, e.position):
			continue
		var s := 0.0
		if u.kind == "cannon":
			var arm: bool = e.armor >= 1.0 if _foe_f == "brood" else (e.d.get("tags", []) as Array).has("armored")
			s = 1.0 + (1.2 if arm else 0.0) + (0.8 if e.kind == "brute" else 0.0)
			# (the ball tears through the line behind it)
			var dir: Vector2 = (e.position - u.position).normalized()
			for o in _foes_near(e.position, 90.0):
				if o != e and dir.dot((o.position - e.position).normalized()) > 0.85:
					s += 0.3
		else:
			for o in _foes_near(e.position, MORTAR_CLUMP):
				s += 1.0
		if s <= bs or not game.aoe_worth_it(u, e):
			continue
		bs = s
		best = e
	if best != null and best != u.target:
		u.target = best
		u.scan_t = maxf(u.scan_t, EVERY + 0.15)
		count(ai.team, "gunpick")
	elif best != null:
		u.scan_t = maxf(u.scan_t, EVERY + 0.15)


# ------------------------------------------------------------------ kite

func _kite_tick(mine: Array) -> void:
	for u in _kite.keys():
		if not _ok(u):
			_kite.erase(u)
		elif game.clock >= float(_kite[u]):
			_kite.erase(u)
			if u.order == "move":
				if ai._attacking and ai._wave_set.has(u):
					u.cmd_move(ai._wave_target, true)
				else:
					u.cmd_hold()
	for u in mine:
		if not u.foot_musket() or _kite.has(u) or _back.has(u) or u.phase != "" or u.cooldown < 0.9:
			continue
		if not (u.order in ["hold", "amove", "idle"]):
			continue
		var close: Unit = null
		var cd := KITE_R
		for e in _foes_near(u.position, KITE_R + 20.0):
			if not _melee(e) or e.speed >= u.speed * 0.97:
				continue
			var d: float = e.position.distance_to(u.position)
			if d < cd:
				cd = d
				close = e
		if close == null:
			continue
		u.cmd_move(game.on_map(u.position + (u.position - close.position).normalized() * KITE_STEP))
		_kite[u] = game.clock + KITE_T
		count(ai.team, "kite")


# ------------------------------------------------------------------ brace

func _brace(mine: Array) -> void:
	if not _braced.is_empty() and (game.clock >= _brace_until or _contact(_braced)):
		for u in _braced:
			if _ok(u) and u.order == "hold" and ai._attacking and ai._wave_set.has(u):
				u.cmd_move(ai._wave_target, true)
		if game.clock >= _brace_until:
			count(ai.team, "brace_timeout")
		_braced.clear()
		return
	if not _braced.is_empty() or game.clock < _brace_next or not ai._attacking:
		return
	var wave: Array = mine.filter(func(u: Unit) -> bool: return ai._wave_set.has(u) and u.has_attack())
	if wave.size() < 4:
		return
	var mid := Vector2.ZERO
	var wv := 0.0
	for u in wave:
		mid += u.position
		wv += float(Game.unit_value(u))
	mid /= float(wave.size())
	if _contact(wave):
		return
	var fv := 0.0
	for e in _foes_near(mid, BRACE_R):
		if e.has_attack() and game.side_sees(ai.team, e.position) and e.velocity.dot(mid - e.position) > 0.0:
			fv += float(Game.unit_value(e))
	if fv < wv * BRACE_SHARE:
		return
	_braced = []
	for u in wave:
		if u.kind == "cuirassier":
			continue
		if u.deploys():
			if u.tesla_mode == "packed":
				u.cmd_deploy()
		elif u.order in ["amove", "move"]:
			u.cmd_hold()
		_braced.append(u)
	_brace_until = game.clock + BRACE_MAX
	_brace_next = game.clock + BRACE_COOL
	count(ai.team, "brace")


func _contact(list: Array) -> bool:
	for u in list:
		if _ok(u) and not _foes_near(u.position, 200.0).filter(func(e: Unit) -> bool: return e.has_attack()).is_empty():
			return true
	return false


# ------------------------------------------------------------------ backline (crown-micro-2)

func _backline(mine: Array) -> void:
	var soft: Array = SOFT.get(_foe_f, [])
	for u in mine:
		if not (u.kind in ["cuirassier", "dragoon"]) or u.is_worker() or u.hp < u.max_hp * BACK_HP:
			continue
		if ai._on_errand(u) and not (ai.sc != null and ai.sc.has(u)):
			continue
		if game.clock - float(_back_t.get(u, -99.0)) < BACK_COOL:
			continue
		# already on a soft target: let him finish it
		if _ok(u.target) and u.target is Unit and soft.has(u.target.kind) and u.order == "attack":
			continue
		if not u.order in ["idle", "move", "hold", "amove"]:
			continue
		var best: Unit = null
		var bs := INF
		for e in _foes_near(u.position, BACK_REACH):
			if not soft.has(e.kind) or not game.side_sees(ai.team, e.position):
				continue
			var guard := 0
			for o in _foes_near(e.position, BACK_GUARD_R):
				if o != e and o.has_attack() and not soft.has(o.kind) and not o.is_worker():
					guard += 1
			if guard > BACK_GUARD_N:
				continue
			var sc: float = e.position.distance_to(u.position) + float(guard) * 120.0 - (200.0 if e.kind in GUNS.get(_foe_f, []) else 0.0)
			if sc < bs:
				bs = sc
				best = e
		if best == null:
			continue
		if ai.sc != null and ai.sc.has(u):
			ai.sc._release(u, "")
		_back_t[u] = game.clock
		u.cmd_attack(best)
		count(ai.team, "backline")


# ------------------------------------------------------------------ counter (crown-micro-2)

func _counter(u: Unit) -> void:
	if u.tesla_mode != "deployed" or u.mode == "canister" or u.phase != "" or u.cooldown > 0.5 or u.hold_fire:
		return
	if not u.order in ["hold", "amove", "idle"]:
		return
	var guns: Array = GUNS.get(_foe_f, [])
	var r: float = u._range()
	var min_r := float(u.d.get("min_range", 0.0))
	var best: Unit = null
	var bd := INF
	for e in _foes_near(u.position, r + 30.0):
		if not guns.has(e.kind):
			continue
		var dd: float = e.edge_distance(u.position) - u.radius
		if dd > r or dd < min_r or not u.can_hit(e) or not game.side_sees(ai.team, e.position):
			continue
		if u.kind == "mortar" and not game.aoe_worth_it(u, e):
			continue
		if dd < bd:
			bd = dd
			best = e
	if best == null:
		return
	if best != u.target:
		u.target = best
		count(ai.team, "counter")
	u.scan_t = maxf(u.scan_t, EVERY + 0.15)


# ------------------------------------------------------------------ winders / shields (crown-micro-2)

func _shielded_at(e: Unit, from: Vector2) -> bool:
	return e.kind == ShieldWall.KIND and e.shield_up and e.facing.dot((from - e.position).normalized()) > 0.3


func _pick_shots(mine: Array) -> void:
	var sup: Array = SUPPORT.get(_foe_f, []) if want("winders") else []
	var sh := want("shields") and _foe_f == "clockwork"
	for u in mine:
		if not u.foot_musket() or u.mode == "bayonet" or u.hold_fire or _back.has(u) or _kite.has(u):
			continue
		if u.phase != "" or u.cooldown > 0.6 or not (u.order in ["hold", "amove", "idle"]):
			continue
		if u._pmax > 0.0 and u.powder < 1.0:
			continue
		var cur: Unit = u.target if _ok(u.target) and u.target is Unit else null
		var bad_cur: bool = cur == null or (sh and _shielded_at(cur, u.position))
		if cur != null and sup.has(cur.kind):
			continue
		var r: float = u._range()
		var best: Unit = null
		var bs := -INF
		for e in _foes_near(u.position, r + 30.0):
			var dd: float = e.edge_distance(u.position) - u.radius
			if dd > r or not u.can_hit(e) or not game.target_seen(u.team, e, u.position):
				continue
			var s: float = -dd * 0.1 - e.hp * 0.05
			if sup.has(e.kind):
				s += 1000.0
			elif not bad_cur:
				continue          # (only a support unit is worth leaving a good mark for)
			if sh and _shielded_at(e, u.position):
				s -= 500.0
			if s > bs:
				bs = s
				best = e
		if best == null or best == cur or (sh and _shielded_at(best, u.position) and not sup.has(best.kind)):
			continue
		u.target = best
		u.scan_t = maxf(u.scan_t, EVERY + 0.15)
		_picked[u] = game.clock
		count(ai.team, "winders" if sup.has(best.kind) else ("shields" if sh else "pick"))
