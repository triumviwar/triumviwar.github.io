class_name AICrownFinish   # (used by preload: the class cache may not know it)
extends RefCounted
## THE FINISHER (crown-finish, the owner 2026-11-25, from the championship simulation; docs/crown_finish.md). The Crown
## computer got ahead and did not finish: 38 of its 54 wins in the championship came only at the 20:00 bell. Why it held
## back (docs/crown_finish.md "Why it held back"): its attacks are measured, careful things made for an even game. The
## Siege push (the plan OPTIMAL picks most) stands its line on HOLD out of reach of every building it meets and lets the guns
## shoot one Cog Press, one Pendulum, one Clocktower after another, about a minute each, while the men at home join in
## groups of 6 supply; the shared waves wait for bars, edges, kits and screens, and pull back after a bad trade; the hunt
## waits until the enemy has NO fighting unit at all. Ahead by three or four to one, the Crown kept fighting like it was
## even.
##
## Here: when the Crown is CLEARLY AHEAD it goes for the kill. AICrown asks `take(army)` from the start of AI._army; while
## the finisher is on it commands every fighter but a small guard sized to the threat at home: the army marches as one body
## (bounds toward the target, the stragglers catch up) on the enemy's halls and production buildings (the Brood: its Mother,
## then its rooted ground), nearest first, attacks each until it falls, then the next; the guns trail the body and shoot the
## target or, with canister, whatever comes at them; new men from home walk out to the body. It stops only when the army is
## lost (under LOST_K of what went out, or a bigger enemy force on what is left), when a force it can't leave hits home, or
## when no enemy building is left (the hunt's rule takes over). No unit or balance number changes.
##
## Clearly ahead (looked at every LOOK s from FROM, Normal and up, not in story missions), against the enemy army it
## RECKONS (foe_reckoned: what it has seen in the last two minutes, never under the Crown's own clock reckoning; the Brood:
## seen only, see there):
##   "edge": our fighters worth MIN_ARMY+ (the Brood: MIN_ARMY_BROOD) and EDGE (EDGE_BROOD) times the enemy army, with as
##           many halls as the enemy;
##   "crush": our fighters worth MIN_ARMY+ and CRUSH times the enemy army (its army near nothing), halls or not;
##   "cap": at the supply cap (CAP_SHORT short at most), CAP_MIN+ and CAP_EDGE times it: the army never sits at home.
## Measured in 120 games (docs/crown_finish.md): v Clockwork won outright 9 of 20 (4 before), v Brood 4 (2), mirrors
## decided 10 of 20 (7); on in every matchup.
## Switches: `-- cfin:off` plays as before this job; one part off: `cfinedge:off`, `cfincrush:off`, `cfincap:off`
## (the triggers), `cfinguard:off` (no guard kept: everyone goes). By matchup: `cfinclock:off`, `cfinbrood:off`,
## `cfinmirror:off`.

const FROM := 540.0             # (s) not before 9:00: the openings and their own rules first
const LOOK := 4.0               # (s) between looks at the balance while it is off
const MIN_ARMY := 2500.0        # (value) a smaller army never counts as clearly ahead (1,500 went out at 9:00-14:00 into
                                # Clockwork armies it had not seen: pilot f6)
const MIN_ARMY_BROOD := 2000.0  # (the Brood: the army seen only, see foe_reckoned; pilot f7 won at 14:11 from a start at 1,850)
const CAP_MIN := 1500.0         # (value) at the supply cap
const EDGE := 2.0
const EDGE_BROOD := 2.5         # (the Brood's rooted creatures fight at home too: the Crown's own CR_EDGE_BROOD is 1.5)
const CRUSH := 4.0
const CAP_EDGE := 1.5
const CAP_SHORT := 8
const COOL := 90.0              # (s) after the finisher stops, before it may start again
const COOL_LOST := 150.0        # (s) after it lost the army it went out with
const COOL_HOME := 20.0         # (s) after it turned back for a force at home
const LOST_K := 0.45            # stop when under this share of what went out ...
const LOST_FOE := 1.3           # ... or an enemy force near the body worth this many times it, while under 0.75 of it
const HOME_K := 1.3             # stop when the enemy near home is worth more than this times the guard + HOME_PLUS ...
const HOME_PLUS := 150.0
const HOME_SHARE := 0.4         # ... and at least this share of the army out
const GUARD_MAX := 0.2          # the guard is never more than this share of the army
const GUARD_K := 1.3            # the guard is worth this many times the enemy seen near home lately
const STEP := 420.0             # (px) a bound: the body's middle moves this far toward the target, the rest catch up
const CLOSE := 520.0            # (px) this near the target, everyone goes straight at it
const GUN_TRAIL := 150.0        # (px) the guns behind the body's middle on the march
const GUN_REACH := 410.0        # (px) a gun this near the target shoots it
const CANISTER_R := 170.0
const ORDERS := 2.5             # (s) between orders

const GUNS := ["cannon", "mortar"]

static var _args: PackedStringArray = OS.get_cmdline_user_args()

var ai                          # the AICrown
var game: Game
var active := false
var men := {}                   # Unit -> true: the finisher's army
var v0 := 0.0                   # what went out (and joined)
var t0 := 0.0
var why := ""                   # the trigger
var target = null               # the building (or rooted creature) it goes for
var _next := 0.0
var _orders_t := 0.0
var _cool_until := -1.0
var _said_t := -99.0
var _lead := Vector2.INF        # the body's waypoint
# the count, for the study (docs/crown_finish.md): starts, by trigger; how each ended; what fell while it was on
var starts := {}
var ends := {}
var broke := 0
var on_s := 0.0
var _broke_seen := {}
var _broke0 := 0                # broke at this start
var from_t := -1.0              # (tests) when set, the start time instead of FROM


## (tests) `cfinfrom:<s>` moves FROM.
static func _from() -> float:
	for a in _args:
		if a.begins_with("cfinfrom:"):
			return float(a.substr(9))
	return FROM


## Is part `name` on? (all on by default; `cfin:off` all off)
static func on(name: String) -> bool:
	return not _args.has("cfin:off") and not _args.has("cfin%s:off" % name)


func _init(a) -> void:
	ai = a
	game = a.game


func say(s: String) -> void:
	ai.say("finisher: " + s)


## May the finisher play this game at all?
func allowed() -> bool:
	if not on("") or not ai.on or ai.difficulty < 1 or ai.peaceful or game.mission != null:
		return false
	var fe: int = ai._foe()
	if fe < 0:
		return false
	if ai._foe_is("clockwork"):
		return on("clock")
	if ai._foe_is("brood"):
		return on("brood")
	if ai._foe_is("crown"):
		return on("mirror")
	return true


## The fighters' worth (no workers, no flyers, no wagons).
static func value(list: Array) -> float:
	var v := 0.0
	for u in list:
		if is_instance_valid(u) and not u.dead:
			v += float(Game.unit_value(u))
	return v


func _fighter(u: Unit) -> bool:
	return is_instance_valid(u) and not u.dead and not u.off_field and u.has_attack() and not u.is_worker() and not u.is_air() \
		and u.kind != "powder_wagon" and u.aboard == null


## Every fighter of ours the finisher may take: the whole army (the siege push's men too, they are let go when it starts),
## not the raiders, the harass, the balloons, the rider scouts and screen, nor a man walking to refit or reload.
func pool() -> Array:
	var out: Array = []
	for u in game.army(ai.team):
		if not _fighter(u) or u.order in ["courier", "overload", "board", "unload", "heal", "revive", "refit", "restock", "mount"]:
			continue
		if ai._raiders.has(u) or (ai.harass != null and ai.harass.has(u)) or ai.am.rearming.has(u) or ai.ch.is_scout(u) \
				or ai._screen_has(u) or (ai.bl != null and ai.bl.has(u)) or (ai.dr != null and ai.dr.has(u)):
			continue
		if ai.sd != null and ai.sd.has(u):
			continue
		out.append(u)
	return out


## The enemy's halls we know of (the Brood: its Mother and its Mound Turtles rooted).
func foe_halls() -> int:
	var fe: int = ai._foe()
	if fe < 0:
		return 0
	if BroodNew.on(game, fe):
		var n := 0
		for u in game.units:
			if u.team == fe and not u.dead and (u.kind == BroodNew.QUEEN or u.kind == BroodNew.TURTLE and BroodNew.rooted(u)):
				n += 1
		return n
	var hk: String = game.faction_hall(fe)
	var n2 := 0
	for b in game.buildings:
		if b.team == fe and not b.dead and not b.ghost and b.kind == hk:
			n2 += 1
	return n2


## Called from AI._army with the army it has (raiders, errands, harass already out). Returns null while off; while on, the
## men left to the shared computer (the guard and anything the finisher does not take).
func take(army: Array) -> Variant:
	if not allowed():
		return null
	for u in men.keys():
		if not is_instance_valid(u) or u.dead or u.off_field:
			men.erase(u)
	if not active:
		if game.clock < _next or game.clock < (from_t if from_t >= 0.0 else _from()) or game.clock < _cool_until:
			return null
		_next = game.clock + LOOK
		var w := _ahead(pool())
		if w == "":
			return null
		if ai._threat() != Vector2.INF and float(ai.ch.foe_near()) > value(pool()) * HOME_SHARE:
			return null           # (a force at home it would turn back for at once: the shared defence first)
		_start(pool(), w)
	return _tick(army)


## Why the Crown is clearly ahead ("" while it is not).
func _ahead(fighters: Array) -> String:
	var mine := value(fighters)
	var foe := foe_reckoned()
	var halls_ok: bool = ai._halls().size() >= foe_halls()
	var edge := EDGE_BROOD if ai._foe_is("brood") else EDGE
	if on("cap") and game.supply_used(ai.team) >= game.max_supply(ai.team) - CAP_SHORT and mine >= CAP_MIN \
			and mine >= foe * CAP_EDGE * (EDGE_BROOD / EDGE if ai._foe_is("brood") else 1.0):
		return "cap"
	if mine < min_army():
		return ""
	if on("crush") and mine >= foe * CRUSH:
		return "crush"
	if on("edge") and halls_ok and mine >= foe * edge:
		return "edge"
	return ""


## The enemy army it reckons: what it has seen in the last two minutes, never under the Crown's own reckoning from the clock
## (AICrown.foe_reckon against the Clockwork and the Crown: its table less half what we killed; foe_estimate against the
## Brood). Seen alone, armies it had not met counted for nothing (pilot f6: three false starts).
func foe_reckoned() -> float:
	if ai._foe_is("brood"):
		return float(ai.ch.foe_known())     # (the Brood table, AICrown.foe_estimate, reckons 5,000 by 12:00 whatever was killed:
		                                    # the finisher would never start; its edge and floor are higher instead)
	return float(ai.foe_reckon())


func min_army() -> float:
	return MIN_ARMY_BROOD if ai._foe_is("brood") else MIN_ARMY


func _start(army: Array, w: String) -> void:
	active = true
	why = w
	t0 = game.clock
	men.clear()
	target = null
	_lead = Vector2.INF
	_orders_t = 0.0
	starts[w] = int(starts.get(w, 0)) + 1
	_broke0 = broke
	# the other controllers let go of their men: the wave, the siege push, the hunt
	if ai._attacking:
		ai._attacking = false
		ai._release_escort()
		ai._wave_set.clear()
		ai._wave_end()
	for p in [ai.siege, ai.cbf_push]:
		if p != null and p.state != "":
			p._end("the finisher takes the army")
	var fighters := army
	var guard := _guard(fighters)
	for u in fighters:
		if not guard.has(u):
			men[u] = true
	v0 = value(men.keys())
	say("the Crown is clearly ahead (%s): %d of army against the %d of the enemy it reckons, %d halls to %d: the whole army goes for the kill (%d stay home)" % [
		w, int(value(fighters)), int(foe_reckoned()), ai._halls().size(), foe_halls(), int(value(guard.keys()))])


## The guard: the men nearest home worth GUARD_K times the enemy seen near home lately (never more than GUARD_MAX of the
## army); none when nothing has come near.
func _guard(fighters: Array) -> Dictionary:
	var out := {}
	if not on("guard"):
		return out
	var want: float = minf(float(ai.ch.foe_near()) * GUARD_K, value(fighters) * GUARD_MAX)
	if want <= 0.0:
		return out
	var home: Vector2 = ai._front()
	var by := fighters.duplicate()
	by.sort_custom(func(a: Unit, b: Unit) -> bool: return a.position.distance_to(home) < b.position.distance_to(home))
	var v := 0.0
	for u in by:
		if v >= want:
			break
		if men.has(u):
			continue
		out[u] = true
		v += float(Game.unit_value(u))
	return out


func _stop(w: String, cool := true) -> void:
	var key := w.split(":")[0]
	ends[key] = int(ends.get(key, 0)) + 1
	on_s += game.clock - t0
	say("stops (%s) after %d s: %d of the %d that went out is left; %d enemy buildings fell meanwhile" % [
		w, int(game.clock - t0), int(value(men.keys())), int(v0), broke - _broke0])
	var back: Vector2 = ai._home_spot(ai._front())
	if w != "no target":
		for u in men:
			if is_instance_valid(u) and not u.dead:
				u.cmd_move(back + Vector2(randf_range(-70, 70), randf_range(-70, 70)))
	men.clear()
	active = false
	target = null
	if cool:
		_cool_until = game.clock + COOL


## Everything that is ours and fights joins the body (the guard aside); the men left over are returned.
func _tick(army: Array) -> Variant:
	var fighters := pool()
	var guard := _guard(fighters.filter(func(u: Unit) -> bool: return not men.has(u)))
	for u in fighters:
		if not men.has(u) and not guard.has(u):
			men[u] = true
			v0 += float(Game.unit_value(u))
	var rest: Array = army.filter(func(u: Unit) -> bool: return not men.has(u))
	var body: Array = men.keys()
	if body.is_empty():
		_stop("the army is gone")
		return rest
	_count_broke()
	var now := value(body)
	var mid := _middle(body)
	var near := _foes_near(mid, 520.0)
	var fv := value(near)
	if now < v0 * LOST_K:
		_stop("lost: %d of %d is left" % [int(now), int(v0)])
		_cool_until = game.clock + COOL_LOST
		return army
	if fv > now * LOST_FOE and now < v0 * 0.75:
		_stop("the enemy here (%d) outweighs what is left (%d)" % [int(fv), int(now)])
		_cool_until = game.clock + COOL_LOST
		return army
	var hn: float = ai.ch.foe_near()
	if ai._threat() != Vector2.INF and hn > (value(guard.keys()) + value(rest.filter(func(u: Unit) -> bool: return _fighter(u)))) * HOME_K + HOME_PLUS \
			and hn > now * HOME_SHARE:
		_stop("an enemy force of %d is at home" % int(hn), false)
		_cool_until = game.clock + COOL_HOME
		return army
	if not _alive(target):
		target = _pick(mid)
		if target == null:
			_stop("no target", false)
			return army
		_lead = Vector2.INF
		_orders_t = 0.0
		if game.clock - _said_t > 15.0:
			_said_t = game.clock
			var nm := _name(target)
			var art := ("an" if "AEIOU".contains(nm.substr(0, 1).to_upper()) else "a") if target is Building else "the"
			say("goes for %s %s (%d px off)" % [art, nm, int(_pos(target).distance_to(mid))])
	if game.clock >= _orders_t:
		_orders_t = game.clock + ORDERS
		_order(body, mid)
	return rest


func _count_broke() -> void:
	for e in _broke_seen.keys():
		if not is_instance_valid(e) or e.dead:
			broke += 1
			_broke_seen.erase(e)
	if _alive(target):
		_broke_seen[target] = true


static func _alive(e) -> bool:
	return e != null and is_instance_valid(e) and not e.dead and not (e is Building and e.ghost)


func _pos(e) -> Vector2:
	return e.center() if e is Building else e.position


func _name(e) -> String:
	return String(e.d["name"]) if e.d.has("name") else String(e.kind)


func _middle(list: Array) -> Vector2:
	# (the median of the men's positions: one straggler does not drag the body's middle)
	var xs: Array = []
	var ys: Array = []
	for u in list:
		xs.append(u.position.x)
		ys.append(u.position.y)
	xs.sort()
	ys.sort()
	return Vector2(xs[xs.size() / 2], ys[ys.size() / 2])


func _foes_near(p: Vector2, r: float) -> Array:
	var out: Array = []
	for u in game.units_near(p, r):
		if not u.dead and not u.off_field and game.hostile(u.team, ai.team) and not u.is_worker() and u.has_attack() \
				and game.is_visible_to(ai.team, u.position):
			out.append(u)
	return out


## The next thing to kill: the enemy's halls and the buildings that train its army (the Brood: its Mother first when the
## body is within reach of her, else its rooted Mound Turtles and Rootmaws, then the Mother), nearest to the body first;
## else any of its buildings; else its nearest unit.
func _pick(mid: Vector2):
	var fe: int = ai._foe()
	if fe < 0:
		return null
	var best = null
	var bd := INF
	if BroodNew.on(game, fe):
		var q: Unit = BroodNew.queen(game, fe)
		for u in game.units:
			if u.team == fe and not u.dead and not u.off_field and (u.kind == BroodNew.QUEEN or BroodNew.rooted(u) and (u.kind == BroodNew.TURTLE or u.kind == BroodNew.MAW)):
				var dd: float = u.position.distance_to(mid) * (0.7 if u == q else 1.0)
				if dd < bd:
					bd = dd
					best = u
		return best if best != null else q
	var hk: String = game.faction_hall(fe)
	for b in game.buildings:
		if b.team != fe or b.dead or b.ghost:
			continue
		if b.kind != hk and (b.d.get("trains", []) as Array).is_empty():
			continue
		var dd: float = b.center().distance_to(mid)
		if dd < bd:
			bd = dd
			best = b
	if best != null:
		return best
	for b in game.buildings:
		if b.team == fe and not b.dead and not b.ghost:
			var dd: float = b.center().distance_to(mid)
			if dd < bd:
				bd = dd
				best = b
	return best


func _order(body: Array, mid: Vector2) -> void:
	var tp := _pos(target)
	var dist := mid.distance_to(tp)
	var dir := (tp - mid).normalized() if dist > 1.0 else Vector2.ZERO
	var close := dist < CLOSE
	# the bound: a waypoint STEP ahead of the body's middle; renewed when the middle has come near it
	if close:
		_lead = tp
	elif _lead == Vector2.INF or mid.distance_to(_lead) < STEP * 0.45 or _lead.distance_to(tp) > dist + 60.0:
		_lead = mid + dir * minf(STEP, dist)
	var guns: Array = []
	for u in body:
		if GUNS.has(u.kind):
			guns.append(u)
			continue
		if u.target != null and is_instance_valid(u.target) and not u.target.dead and u.order in ["attack", "amove", "d_amove"] \
				and u.position.distance_to(mid) < 900.0:
			continue              # (fighting something on the way: it finishes it)
		if close and u.position.distance_to(tp) < 360.0:
			if u.order != "attack" or u.order_target != target:
				u.cmd_attack(target)
			continue
		var goal := _lead
		if u.position.distance_to(mid) > 900.0:
			goal = mid            # (a straggler or a man from home: to the body first)
		if u.order not in ["amove", "d_amove"] or u.order_point.distance_to(goal) > 110.0:
			u.cmd_move(goal + Vector2(randf_range(-55, 55), randf_range(-55, 55)), true)
	for g in guns:
		_gun(g, mid, dir, tp, close)


func _gun(g: Unit, mid: Vector2, dir: Vector2, tp: Vector2, close: bool) -> void:
	if g.kind == "cannon":
		var foes := _foes_near(g.position, CANISTER_R).filter(func(e: Unit) -> bool: return not e.is_air())
		if not foes.is_empty():
			if g.mode != "canister":
				g.set_canister(true)
			foes = foes.filter(func(e: Unit) -> bool: return game.aoe_worth_it(g, e))
			if not foes.is_empty():
				if g.order != "attack" or not _alive(g.order_target) or not foes.has(g.order_target):
					g.cmd_attack(foes[0])
				return
		elif g.mode == "canister":
			g.set_canister(false)
	if g.target != null and is_instance_valid(g.target) and not g.target.dead and g.order == "attack" and g.target is Unit:
		return                    # (shooting at the enemy army: it goes on)
	if g.position.distance_to(tp) < GUN_REACH and game.is_visible_to(ai.team, tp):
		if g.order != "attack" or g.order_target != target:
			g.cmd_attack(target)
		return
	var spot := mid - dir * GUN_TRAIL
	if close:
		spot = tp - (tp - g.position).normalized() * (GUN_REACH - 40.0)
	if g.position.distance_to(spot) > 80.0 and (g.order not in ["move", "amove"] or g.order_point.distance_to(spot) > 70.0):
		g.cmd_move(spot, true)
