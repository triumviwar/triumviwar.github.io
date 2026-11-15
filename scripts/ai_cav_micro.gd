class_name AICavMicro
extends RefCounted
## THE CROWN COMPUTER'S CAVALRY MICRO (crown-coach-cavalry, the owner 2026-11-15 00:53: "You never let your cavalry
## stay in the fight like that, you always keep microing it so you can use charge as much as possible. You never leave
## your cavalry in the fighting, they are always moving, abusing its mobility even without charge researched, but with it
## researched then it's much more useful, the microing of in and out."; docs/crown-coach-cavalry.md).
## The Horseman already fights on the move (scripts/ride_by.gd: a pass, a blow, a loop round the target). What the
## computer did badly was WHAT it rode at and HOW LONG it stayed: an attack-move into the enemy's mass looped round
## whatever was nearest (a Brute, a shield, a bayonet line) blow after blow, inside the enemy's answer, and the Cavalry
## Charge never came again after the first blow (a run counts only after RIDE_BY "calm" s without a blow).
## Now, for every Crown Horseman (and Cuirassier) in the saddle on a fighting order (attack-move, attack, or on guard with
## an enemy close; never one on a plain move, on HOLD, or on an errand: the screen, the scouts, a rearm), Normal and up:
##  1. IN: it picks its prey (pick): workers, guns and gunners, Spitters, the hurt and the ones alone first; never an
##     armoured or massive one unless it is nearly dead; never one with the enemy's answer round it (DANGER_MAX). It rides
##     at it (an attack order: the pistol goes first by itself, RideBy.blows, then the sabre in passing).
##  2. OUT: once it has struck, it rides on away from the enemy's fighters (OUT_T s) before the answer lands.
##  3. ROUND: with the Cavalry Charge drilled it keeps galloping round the fight, out of reach, until the next blow will
##     be a charge (RIDE_BY "calm" s without a blow, then CHARGE "run" s at the gallop: Unit.run_t), and comes in again
##     from where it is: another angle. Without the charge it comes straight back after OUT_T for the next prey.
##     No prey worth a pass (only a blob, a wall of shields): it circles out of reach and waits for one.
##  4. HURT: a rider under CAREFUL of its hit points only rides at prey with next to no guard and no gun on it (a
##     Horseman does not heal: sent home it only waits for the next wave to send it into the mass, unled); under HURT it
##     rides home and is left alone a while.
## The fight is released (its old order given back) when no enemy is near for RELEASE_T s.
## Design: docs/design_principles.md 1 (fair: what a player does with his riders, from what it sees; no unit numbers
## changed) and 4 (out-micro as a way to win). Everything runs on the game clock: the same in every replay.
## Study switch: `-- cavmicro:off` (the riders fight as before).

const KINDS := ["cuirassier"]    # (the Horseman; with Armour the Cuirassier is the same kind)
const SHIELDS := ["clock_soldier", "windup_soldier", "bulwark"]   # shields a sabre pass glances off: never a prey of choice
const EVERY := 0.1               # (s) looked at this often
const TAKE_R := 300.0            # (px) an enemy this near a rider on a fighting order: the micro takes it
const PICK_R := 380.0            # (px) its prey within this
const LEASH := 520.0             # (px) ... and never farther than this from where the fight was taken (or last moved to)
const RELEASE_R := 440.0         # (px) no enemy this near for RELEASE_T s: the fight is over for it
const RELEASE_T := 2.0
const GUARD_R := 115.0           # (px) the enemy's fighters this near a prey are its guard (the answer to a pass)
const DANGER_MAX := 4.5          # a prey with more guard than this is left alone (see _danger)
const OUT_T := 1.2               # (s) after a blow it rides out this long (no charge: then straight back in)
const OUT_T_CH := 2.2            # (s) ... with the Cavalry Charge: out this long, then round the fight
const OUT_D := 220.0             # (px) the point it rides out to
const ROUND_R := [190.0, 300.0]  # (px) it rides round the fight this far from the enemy's fighters
const ROUND_MAX := 14.0          # (s) round at most this long, then in anyway (a prey is waiting)
const IN_MAX := 6.0              # (s) riding in this long without a blow: it picks again
const CAREFUL := 0.45            # a rider below this share of its hit points picks only prey with no answer at hand
const CAREFUL_DANGER := 1.3      # ... at most this much guard (see _danger), and no enemy gun reaching it
const HURT := 0.15               # a rider below this share of its hit points rides home
const HOME_COOL := 40.0          # (s) ... and is left alone this long (or until it is home)

var ai = null
var game: Game = null
var on := not OS.get_cmdline_user_args().has("cavmicro:off")
var st := {}                     # Unit -> its fight: {"s": state, "t": since, "tgt", "blow", "back", "anchor", "far", "spin", "o", "p", "e"}
var _cool := {}                  # Unit -> clock until which it is left alone (sent home)
var _next := 0.0
# (the coach and the report)
var said: Array = []             # [clock, text]
var n := {"take": 0, "in": 0, "out": 0, "round": 0, "home": 0, "skip_blob": 0}


func _init(a) -> void:
	ai = a
	game = a.game


func has(u: Unit) -> bool:
	return st.has(u)


func tick() -> void:
	if not on or game == null or game.clock < _next:
		return
	_next = game.clock + EVERY
	for u in st.keys():
		if not is_instance_valid(u) or u.dead or u.off_field or u.aboard != null or not u.is_mounted():
			st.erase(u)
	for u in _cool.keys():
		if not is_instance_valid(u) or u.dead or game.clock >= float(_cool[u]):
			_cool.erase(u)
	for u in game.army(ai.team):
		if not KINDS.has(u.kind) or u.off_field or u.aboard != null or not u.is_mounted():
			continue
		if st.has(u):
			_run(u, st[u])
		elif _takes(u):
			_take(u)


# ------------------------------------------------------------------ taking and giving back

## A rider on a fighting order (or on guard) with an enemy close, not on an errand and not sent home.
func _takes(u: Unit) -> bool:
	if _cool.has(u) or u.hp < u.max_hp * HURT or u.siege_t > 0.0 or u.wall_flee_t > 0.0:
		return false
	if not u.order in ["amove", "attack", "idle"] or u.hold_fire:
		return false
	if ai._on_errand(u):
		return false
	return _foe_near(u.position, TAKE_R, true) != null


func _take(u: Unit) -> void:
	st[u] = {"s": "", "t": game.clock, "tgt": null, "blow": u.rb_last, "anchor": u.position, "far": 0.0,
		"spin": 1 if (u.serial % 2) == 0 else -1,
		"back": {"o": u.order, "p": u.order_point, "e": u.order_target if u.order == "attack" else null},
		"o": "", "p": Vector2.INF, "e": null}
	n["take"] += 1
	if not _pick_in(u, st[u]):
		_round(u, st[u])


## The fight is over for it: its old order back.
func _release(u: Unit, s: Dictionary) -> void:
	st.erase(u)
	var b: Dictionary = s["back"]
	var e = b.get("e")
	if String(b["o"]) == "attack" and e != null and is_instance_valid(e) and not e.dead and u._valid_target(e):
		u.cmd_attack(e)
	elif String(b["o"]) == "amove" and b["p"] != Vector2.INF:
		u.cmd_move(b["p"], true)
	elif u.order == "move":
		u.cmd_stop()


## Someone else gave it an order that is not a fight (a raid riding home, the wave regrouping, a rearm, HOLD): theirs.
func _taken_back(u: Unit, s: Dictionary) -> bool:
	if u.order == String(s["o"]):
		return false
	return not u.order in ["amove", "attack", "idle"]


# ------------------------------------------------------------------ the fight

func _run(u: Unit, s: Dictionary) -> void:
	if _taken_back(u, s):
		st.erase(u)
		return
	if u.hp < u.max_hp * HURT:
		_home(u)
		return
	# over? (nothing near for RELEASE_T s)
	if _foe_near(u.position, RELEASE_R, true) == null:
		s["far"] = float(s["far"]) + EVERY
		if float(s["far"]) >= RELEASE_T:
			_release(u, s)
			return
	else:
		s["far"] = 0.0
	var struck: bool = u.rb_last > float(s["blow"]) + 0.01
	if struck:
		s["blow"] = u.rb_last
	match String(s["s"]):
		"in":
			var t = s["tgt"]
			if struck:
				if _melee_near(u) and not (_guns(u) and _melee_chases(u)):
					_out(u, s)       # (their answer is at hand: away before it lands)
				elif t != null and is_instance_valid(t) and not t.dead and u._valid_target(t):
					_assert(u, s)    # (only guns about: it keeps at its prey, its loop round it, blow after blow)
				elif not _pick_in(u, s, true):
					_round(u, s)     # (... and on to the next at once)
			elif t == null or not is_instance_valid(t) or t.dead or not u._valid_target(t) or game.clock - float(s["t"]) > IN_MAX:
				if not _pick_in(u, s):
					_round(u, s)
			elif _danger(t) > DANGER_MAX + _worth(u, t) + 1.5:
				n["skip_blob"] += 1
				if not _pick_in(u, s):
					_round(u, s)     # (its prey ran back into the mass: another, or round)
			else:
				_assert(u, s)
		"out":
			if game.clock - float(s["t"]) >= (OUT_T_CH if _wait_charge(u) else OUT_T):
				if _wait_charge(u) and not _charge_ready(u, null):
					_round(u, s)
				elif not _pick_in(u, s):
					_round(u, s)
			else:
				_assert(u, s)
		"round":
			var waited := game.clock - float(s["t"]) >= ROUND_MAX
			if (not _wait_charge(u) or waited) and game.clock - float(s["t"]) >= 1.0:
				if _pick_in(u, s, true):
					return
			elif game.clock - u.rb_last >= float(Defs.RIDE_BY["calm"]) - 0.6:
				var p := _pick(u, s)
				if p != null and _charge_ready(u, p):
					_go_in(u, s, p)
					return
			if game.clock >= float(s.get("next_p", 0.0)):
				_round_point(u, s)
			else:
				_assert(u, s)
		_:
			if not _pick_in(u, s):
				_round(u, s)


func _go_in(u: Unit, s: Dictionary, p: Unit) -> void:
	s["s"] = "in"
	s["t"] = game.clock
	s["tgt"] = p
	s["o"] = "attack"
	s["e"] = p
	s["anchor"] = s["anchor"].lerp(p.position, 0.35)
	n["in"] += 1
	u.cmd_attack(p)


func _pick_in(u: Unit, s: Dictionary, now := false) -> bool:
	var p := _pick(u, s)
	if p == null:
		return false
	if not now and _wait_charge(u) and not _charge_ready(u, p) and game.clock - u.rb_last < float(Defs.RIDE_BY["calm"]) + float(Defs.CHARGE["run"]) + 3.0:
		return false               # (drilled: no blow without its charge while one can be had soon)
	_go_in(u, s, p)
	return true


## Struck: ride on away from the enemy's fighters before their answer lands.
func _out(u: Unit, s: Dictionary) -> void:
	s["s"] = "out"
	s["t"] = game.clock
	s["tgt"] = null
	var away := _away(u)
	var p := _clear_point(u, away, OUT_D)
	n["out"] += 1
	_move(u, s, p)


## Round the fight out of reach (the charge building up, or waiting for a prey worth a pass).
func _round(u: Unit, s: Dictionary) -> void:
	if String(s["s"]) != "round":
		s["s"] = "round"
		s["t"] = game.clock
		n["round"] += 1
	s["tgt"] = null
	_round_point(u, s)


func _round_point(u: Unit, s: Dictionary) -> void:
	s["next_p"] = game.clock + 0.4
	if not _wait_charge(u) and _melee_near(u):
		# (nothing worth a pass and biters on its heels: straight away, so the chase strings them out, not round them)
		_move(u, s, _clear_point(u, _away(u), 200.0))
		s["next_p"] = game.clock + 1.0
		return
	if _guns(u):
		_move(u, s, _clear_point(u, _away(u), 200.0))     # (nothing worth a pass and a gun on it: out of its reach)
		return
	var c := _foe_middle(u)
	if c == Vector2.INF:
		c = s["anchor"]
	var r := clampf(u.position.distance_to(c), float(ROUND_R[0]), float(ROUND_R[1]))
	var spin := int(s["spin"])
	var a := (u.position - c).angle() + float(spin) * (130.0 / r)     # (about 130 px on along the circle)
	var p: Vector2 = c + Vector2.from_angle(a) * r
	# (a cliff, water or a wall that way: the other way round)
	if not game.line_clear(u.position, p, u._path_margin()) or game.level_of(p) != game.level_of(u.position):
		s["spin"] = -spin
		a = (u.position - c).angle() - float(spin) * (130.0 / r)
		p = c + Vector2.from_angle(a) * r
		if not game.line_clear(u.position, p, u._path_margin()):
			p = _clear_point(u, _away(u), 160.0)
	# (never farther than the leash from where the fight is)
	var an: Vector2 = s["anchor"]
	if p.distance_to(an) > LEASH:
		p = an + (p - an).normalized() * LEASH
	_move(u, s, p)


func _move(u: Unit, s: Dictionary, p: Vector2) -> void:
	s["o"] = "move"
	u.cmd_move(p)
	s["p"] = u.order_point if u.order == "move" else p


func _home(u: Unit) -> void:
	var s: Dictionary = st[u]
	st.erase(u)
	_cool[u] = game.clock + HOME_COOL
	n["home"] += 1
	var halls: Array = ai._halls()
	var home: Vector2 = halls[0].center() if not halls.is_empty() else game.center_of_team(ai.team)
	u.cmd_move(home + Vector2(float(u.serial % 5) * 12.0 - 24.0, float(u.serial % 3) * 12.0 - 12.0))
	_say("sends a hurt Horseman home (%d%% health)" % int(100.0 * u.hp / maxf(1.0, u.max_hp)))
	s.clear()


## Its own order again if someone else's crept in (the wave's think re-sends attack-moves every few seconds).
func _assert(u: Unit, s: Dictionary) -> void:
	if String(s["o"]) == "attack":
		var e = s["e"]
		if e != null and is_instance_valid(e) and (u.order != "attack" or u.order_target != e):
			u.cmd_attack(e)
	elif String(s["o"]) == "move":
		if u.order != "move" or u.order_point.distance_to(s["p"]) > 8.0:
			u.cmd_move(s["p"])


# ------------------------------------------------------------------ the charge

func _charge(u: Unit) -> bool:
	return game.has_tech(u.team, "charge")


## It waits for its charge between passes: drilled, and no enemy gun has it in reach (riding round under the muskets or
## the Spitters' spit only feeds them: there it keeps at its prey, blow after blow).
func _wait_charge(u: Unit) -> bool:
	return _charge(u) and not _guns(u)


## An enemy gunner (a reach of 100 or more) has it, or will have it within a few strides.
func _guns(u: Unit) -> bool:
	for o in game.units_near(u.position, 420.0):
		if o.dead or o.off_field or not game.hostile(o.team, ai.team) or not Game.fights_back(o) or float(o.d["range"]) < 100.0:
			continue
		if not o.can_hit(u):
			continue
		if o.edge_distance(u.position) - u.radius <= float(o.d["range"]) + 80.0:
			return true
	return false


## Under fire with a fast biter on it (a Raptor runs nearly as fast as a horse): riding out only gives the guns their
## shots, it fights on.
func _melee_chases(u: Unit) -> bool:
	for o in game.units_near(u.position, 130.0):
		if o.dead or o.off_field or o.is_air() or not game.hostile(o.team, ai.team) or not Game.fights_back(o):
			continue
		if float(o.d["range"]) < 60.0 and o.can_hit(u) and o.speed >= u.speed * 0.75:
			return true
	return false


## An enemy gun reaches the spot `o` stands at (a pass on it rides into that fire).
func _gun_on(o: Unit) -> bool:
	for q in game.units_near(o.position, 300.0):
		if q.dead or q.off_field or q.team != o.team or not Game.fights_back(q) or float(q.d["range"]) < 100.0:
			continue
		if q.position.distance_to(o.position) <= float(q.d["range"]) + 20.0:
			return true
	return false


## The enemy's answer at hand: a fighter that strikes up close (a reach under 60) by it.
func _melee_near(u: Unit) -> bool:
	for o in game.units_near(u.position, 130.0):
		if o.dead or o.off_field or o.is_air() or not game.hostile(o.team, ai.team) or not Game.fights_back(o):
			continue
		if float(o.d["range"]) < 60.0 and o.can_hit(u):
			return true
	return false


## The next blow on `p` (null: any) will be a charge: calm since the last blow, and the run full by the time it gets there.
func _charge_ready(u: Unit, p: Unit) -> bool:
	if game.clock - u.rb_last < float(Defs.RIDE_BY["calm"]):
		return false
	var eta := 0.0 if p == null else maxf(0.0, p.position.distance_to(u.position) - 40.0) / maxf(u.speed, 1.0)
	return u.run_t + eta * 0.8 >= float(Defs.CHARGE["run"]) + 0.15


# ------------------------------------------------------------------ the prey

## Its prey: the best enemy man within PICK_R (and the leash), by what a pass on it is worth.
func _pick(u: Unit, s: Dictionary) -> Unit:
	var best: Unit = null
	var bs := 1.5
	var lv := game.level_of(u.position)
	var an: Vector2 = s["anchor"]
	var shot := _guns(u)
	var careful := u.hp < u.max_hp * CAREFUL
	for o in game.units_near(u.position, PICK_R):
		if o.dead or o.off_field or o.is_air() or not game.hostile(o.team, ai.team) or o.kind == "horse" or not u.can_hit(o) or o.untouchable():
			continue
		if o.position.distance_to(an) > LEASH or not game.is_visible_to(ai.team, o.position):
			continue
		var v := _worth(u, o)
		if v <= 0.0:
			continue
		if shot:
			# (under fire: the guns that shoot it first, the nearest of them; the hands behind them can wait)
			if Game.fights_back(o) and float(o.d["range"]) >= 100.0 and o.can_hit(u):
				v *= 1.4
			elif o.is_worker():
				v *= 0.4
		var dg := _danger(o)
		if dg > DANGER_MAX + v:
			continue
		if careful and (dg > CAREFUL_DANGER or _gun_on(o)):
			continue               # (hurt: only what cannot answer)               # (the more a pass is worth, the more guard it is worth riding past)
		var sc: float = v * 10.0 - dg * 3.0 - o.position.distance_to(u.position) / (25.0 if shot else 40.0)
		if game.level_of(o.position) != lv:
			sc -= 6.0              # (up or down a ramp: a long way round)
		if o == s.get("tgt"):
			sc += 1.0
		if sc > bs or (sc == bs and best != null and o.serial < best.serial):
			bs = sc
			best = o
	return best


## What one pass of `u` on `o` is worth: the light and the precious first, the hurt more; nothing for armour or mass (unless
## nearly dead).
func _worth(u: Unit, o: Unit) -> float:
	var frac := o.hp / maxf(1.0, o.max_hp)
	var tags: Array = o.d.get("tags", [])
	var heavy := tags.has("armored") or tags.has("massive") or float(o.d["hp"]) >= 300.0
	var bon := float(u.d.get("bonus", {}).get(o.kind, 1.0))
	if bon > 1.0:
		return 3.0 * bon * (1.0 + 1.2 * (1.0 - frac))     # (what the sabre is made for: guns, Spitters, Arc Throwers)
	if heavy and frac > 0.3:
		return 0.0
	var v := 1.0
	if o.is_worker():
		v = 3.0
	elif not Game.fights_back(o):
		v = 1.6
	elif float(o.d["range"]) >= 100.0:
		v = 2.4                    # (guns and gunners: Musketeers, Spitters, cannons, Arc Throwers, Netters...)
	if float(o.d.get("bonus", {}).get("cuirassier", 1.0)) > 1.0:
		v *= 0.4                   # (a pike: made to stop horses)
	if heavy:
		v *= 0.6
	if SHIELDS.has(o.kind):
		v *= 0.35
	return v * (1.0 + 1.2 * (1.0 - frac))


## The enemy's answer to a pass on `o`: its fighters round it (itself too), the heavy and the horse-killers counting more.
func _danger(o: Unit) -> float:
	var dg := 0.0
	for q in game.units_near(o.position, GUARD_R):
		if q.dead or q.off_field or q.team != o.team or not Game.fights_back(q) or q.is_air():
			continue
		var w := 1.0 if float(q.d["range"]) < 60.0 else 0.3     # (a gun shoots it wherever it rides: the guard is the blades)
		w *= clampf(q.hp / 60.0, 0.4, 1.5)          # (two sabre blows kill a Raptor: a light biter is less of an answer)
		var tags: Array = q.d.get("tags", [])
		if tags.has("armored") or tags.has("massive"):
			w = 2.0
		if float(q.d.get("bonus", {}).get("cuirassier", 1.0)) > 1.0:
			w *= 2.0
		if SHIELDS.has(q.kind):
			w *= 1.5
		if q.kind == "musketeer" and q.mode == "bayonet":
			w *= 1.5               # (a bayonet hurts a horse: Defs.BAYONET bonus)
		dg += w
	return dg


# ------------------------------------------------------------------ helpers

## The nearest enemy (a fighter, if `fighters`) seen within `r`.
func _foe_near(p: Vector2, r: float, any := false) -> Unit:
	var best: Unit = null
	var bd := INF
	for o in game.units_near(p, r):
		if o.dead or o.off_field or o.is_air() or not game.hostile(o.team, ai.team) or o.kind == "horse":
			continue
		if not any and not Game.fights_back(o):
			continue
		if not game.is_visible_to(ai.team, o.position):
			continue
		var dd: float = o.position.distance_to(p)
		if dd < bd:
			bd = dd
			best = o
	return best


## The middle of the enemy's fighters near it (INF: none).
func _foe_middle(u: Unit) -> Vector2:
	var c := Vector2.ZERO
	var k := 0
	for o in game.units_near(u.position, PICK_R):
		if o.dead or o.off_field or o.is_air() or not game.hostile(o.team, ai.team) or not Game.fights_back(o):
			continue
		c += o.position
		k += 1
	return c / k if k > 0 else Vector2.INF


## Away from the enemy's fighters near it (their middle), else on along its heading.
func _away(u: Unit) -> Vector2:
	var c := Vector2.ZERO
	var w := 0.0
	for o in game.units_near(u.position, 300.0):
		if o.dead or o.off_field or o.is_air() or not game.hostile(o.team, ai.team) or not Game.fights_back(o):
			continue
		var k := 1.0 / maxf(30.0, o.position.distance_to(u.position))
		c += o.position * k
		w += k
	if w <= 0.0:
		return u.rb_head if u.rb_head != Vector2.ZERO else Vector2.RIGHT
	var d := u.position - c / w
	if d.length() < 1.0:
		return u.rb_head if u.rb_head != Vector2.ZERO else Vector2.RIGHT
	# (a little along its heading: it rides on out of the pass rather than turning on the spot)
	var h := u.rb_head if u.rb_head != Vector2.ZERO else d.normalized()
	return (d.normalized() * 0.7 + h * 0.3).normalized()


## A point `dist` px off toward `dir` it can ride to straight (a cliff or a wall: turned a little each way).
func _clear_point(u: Unit, dir: Vector2, dist: float) -> Vector2:
	var lv := game.level_of(u.position)
	for a in [0.0, 0.5, -0.5, 1.0, -1.0, 1.6, -1.6, 2.4, -2.4]:
		var p: Vector2 = u.position + dir.rotated(a) * dist
		if game.line_clear(u.position, p, u._path_margin()) and game.level_of(p) == lv:
			return p
	return u.position + dir * dist * 0.4


func _say(text: String) -> void:
	said.append([game.clock, text])
	if said.size() > 200:
		said.pop_front()
