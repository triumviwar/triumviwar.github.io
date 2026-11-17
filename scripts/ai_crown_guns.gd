class_name AICrownGuns
extends RefCounted
## THE CROWN'S GUNS AND LINE, COACHED (crown-guns-coach, the owner 2026-11-15 22:20 / 2026-11-16 23:25: "focus on wall
## making and microing the army, screening with Horsemen, setting cannon before the engagement is very important, it doesn't
## help if the enemy is on top of you and the cannon is still unlimbering, that is why Horseman screening is so important";
## docs/crown_guns_coach.md). The Crown computer's FIGHTING only (no unit, price or rule number changed):
##  1. THE LINE KEEPS ITS GUNS (`gkeep:off`): the guns the line placed are the line's while it stands (forming, stepping,
##     holding, fighting, falling back): the wave's shared order loop no longer sends a gun of the line on toward the enemy's
##     base. It did every think the line handed back (a fight, or a held line waiting by its guns): an idle gun, set up or
##     setting up but with no target yet, got an attack-move on, limbered again and rolled after the wave (filmed Highmoor
##     1104 7:21 and 10:43: three guns limbered behind a formed line, the enemy 350 px off).
##  2. THE GUNS SET IN TIME (`gset:off`): a gun of the line behind its front rank unlimbers where it stands as soon as the
##     nearest enemy known will be in its reach by the time it is set (its distance less the enemy's closing speed times the
##     unlimbering + GSET_SLACK s), instead of first rolling on to its exact spot (benched: at contact the guns were still
##     limbered 0 of 9 times v Clock Soldiers).
##  3. THE GUNS FOLLOW THE LINE (`gfollow:off`): a set gun of the line with nothing in its reach, the enemy out of its
##     reach and not coming on, and the line stepped on FOLLOW_GAP behind, limbers and rolls up behind the line again.
##  4. THE HELD LINE (`gawait:off`): the coach's held line (AICrownCoach.line_holds: its guns set, the enemy coming on) is
##     a state the line keeps (AICrownLine._await) instead of falling through to the shared loop.
##  5. THE WAVE WALKS AT ITS GUNS' PACE (`gpace:off`): a Field Cannon is slower than a Musketeer (38 against 62 px/s):
##     on a long march the men drew away from the guns, and the line met the enemy with its guns 900-1,300 px behind
##     (benched). Now while the wave marches with nothing in sight, the men more than PACE_AHEAD ahead of their guns stop
##     (on HOLD) till the guns are within PACE_GO of them, then go on together.
##  6. NO COLUMN UP A RAMP (`gramp:off`): coached, Highmoor 1104 10:40 (crown-coach-measure-2): the wave climbed the
##     Clockwork's ramp as a column into its gears and was spent (army 1,625 at 10:00, 900 at 11:00). Now a marching wave
##     whose road climbs a ramp onto the enemy's high ground within RAMP_SEE stops at the ramp's foot: its line forms there
##     facing up the ramp with the guns set behind it (whatever comes down walks into the line and the guns), and it goes up
##     only with CLIMB times what it reckons stands up there (seen there, or what the enemy has not shown elsewhere); after
##     FOOT_MAX s short of that it leaves that target be (TRADE_AVOID, as a lost trade) and the wave looks for another.
##  7. THE DEFENCE'S GUNS SET (`gdef:off`): a gun of a detachment sent to a force at our buildings sets up where it is
##     once an enemy is in its reach (or about to be), instead of being sent on again and again into the raid's spot.
## Plus THE COUNT (read only, always on): every fight of the Crown's army (an armed enemy within CONTACT of one of its
## soldiers after QUIET s of none there), its guns near it, how many stood set up at contact and how many fired in its first
## FIRST s, whether it began formed, and what it killed and lost (result.json "crown_ai" via tools/qa_match.gd).
## Design: docs/design_principles.md 1 (the computer plays the player's own tools well, nothing it could not do by hand), 4
## (battles that carry the weight of the match). Switch `gunscoach:off` (all of it but the count).

const CONTACT := 260.0          # (px) an armed enemy this near a Crown soldier: a fight
const QUIET := 20.0             # (s) no contact there this long: the fight is over
const SAME := 1200.0            # (px) contact this near the fight's place is the same fight
const NEAR_GUN := 1000.0        # (px) a Crown gun this near the fight's place is one of its guns
const FIRST := 10.0             # (s) the guns firing in a fight's first FIRST s
const EVERY := 0.5              # (s) between two counts

var ai = null
var game: Game = null
var _args := OS.get_cmdline_user_args()
var off := _args.has("gunscoach:off")
var keep_on := not off and not _args.has("gkeep:off")
var set_on := not off and not _args.has("gset:off")
var follow_on := not off and not _args.has("gfollow:off")
var await_on := not off and not _args.has("gawait:off")
var pace_on := not off and not _args.has("gpace:off")
var ramp_on := not off and not _args.has("gramp:off")
var def_on := not off and not _args.has("gdef:off")
const RAMP_SEE := 900.0         # (px) along the road: a ramp up this near the wave is weighed
const RAMP_EVERY := 3.0         # (s) the road looked up again this often
const TOP_R := 700.0            # (px) the enemy known this near the ramp's top stands up there
const CLIMB := 2.0              # the wave goes up with this many times what it reckons up there ...
const RAMP_LEAVE := 250.0       # ... and never stops for less than this up there
const FOOT_BACK := 170.0        # (px) the line's front rank this far back from the ramp's foot
const FOOT_MAX := 45.0          # (s) at the foot, short of CLIMB, then it leaves the target be
const RAMP_OK := 50.0           # (s) a ramp the wave chose to climb is not weighed again this long
var _road := PackedVector2Array()
var _road_t := -99.0
var _road_to := Vector2.INF
var _foot := {}                 # the ramp the line stands at: foot, top, target, t0
var _ramp_ok := {}              # Vector2i (the top's cell) -> clock until which it is not weighed
var feet := 0                   # (tests) times the wave stopped at a ramp's foot
var climbs := 0                 # (tests) ... and went up
var leaves := 0                 # (tests) ... and left the target be
var def_sets := 0               # (tests) defence guns set where they stood
const GSET_SLACK := 0.8         # (s) on top of the unlimbering
const FOLLOW_GAP := 7.0         # (tiles) a set gun this far behind the line's front rank, nothing in reach: it follows
const PACE_AHEAD := 190.0       # (px) the men this far ahead of their guns along the road: they wait
const PACE_HOLD := 130.0        # (px) ... those of them this far ahead stop ...
const PACE_GO := 80.0          # (px) ... till the guns are this near
const PACE_GUNS_R := 1400.0     # (px) guns this near the men are the wave's (farther: reinforcements on their way)
const PACE_MAX := 25.0          # (s) a wait no longer than this (a gun stuck), then PACE_COOL s without
const PACE_COOL := 20.0
var _paced := {}                # Unit -> true: men stopped for the guns
var _pace_t := -1.0
var _pace_cool := 0.0
var sets := 0                   # (tests) guns set where they stood in time
var follows := 0                # (tests) set guns that limbered to follow the line
var paces := 0                  # (tests) waits for the guns on the march

# THE COUNT
var fights: Array = []          # [t0, home, formed, guns, set_at_contact, fired_first, killed, lost, x, y] per fight
var _cur := {}                  # the fight on: t0, p, last, guns, set, k0, l0, formed, home, done_first, fired
var _next := 0.0
var kept := 0                   # (tests) times the shared loop was kept off a line gun


func _init(owner) -> void:
	ai = owner
	game = owner.game


func _say(s: String) -> void:
	if game.mlog:
		game.mlog.add("%s%s" % [game.mlog.who(ai.team), s])


static func _mmss(c: float) -> String:
	return "%d:%02d" % [int(c) / 60, int(c) % 60]


# ------------------------------------------------------------------ 1. the line keeps its guns

## The wave's shared loop asks before it sends a man on: true = leave him be (a gun of the line while the line stands).
func keeps(u: Unit) -> bool:
	if not keep_on or ai.ln == null or not ai.ln.active():
		return false
	if not AICrownLine.is_gun(u) or ai.ln.st == "":
		return false
	if not ai.ln._spot.has(u):
		return false
	kept += 1
	return true


# ------------------------------------------------------------------ 2-3. the guns set in time, follow the line

## Every army think while the wave's line is out (AICrownLine.march, before its own rules).
func line_tick(ln, ground: Array, foes: Array) -> void:
	if ln.st == "" or ln.st == "close":
		if not _paced.is_empty() and ln.st != "":
			_paced.clear()
		return
	if not _paced.is_empty():
		_paced.clear()           # (the line has them now)
	if ln._face == Vector2.ZERO or ln._c == Vector2.INF:
		return
	var T := float(Defs.TILE)
	for u in ln._spot.keys():
		if not ln._ok(u) or not AICrownLine.is_gun(u):
			continue
		var rng := float(u.d.get("range", 430))
		var min_r := float(u.d.get("min_range", 0))
		var nd := INF
		var close := 0.0
		for o in foes:
			if not is_instance_valid(o) or o.dead:
				continue
			var p: Vector2 = ln._pos(o)
			var d: float = p.distance_to(u.position)
			if d < nd:
				nd = d
				close = maxf(0.0, (o.velocity as Vector2).dot((u.position - p).normalized()))
		var back: float = (u.position - ln._c).dot(ln._face)
		if set_on and u.tesla_mode == "packed" and nd < INF and back < -AICrownLine.GUN_MIN_BACK * T:
			var pred: float = nd - close * (Defs.CANNON_SWITCH + GSET_SLACK)
			if pred < rng - 20.0 and nd > min_r + 20.0:
				u.cmd_deploy()
				ln._spot[u] = u.position
				sets += 1
				continue
		if follow_on and u.tesla_mode == "deployed" and ln.st in ["step", "advance", "fight"] and back < -FOLLOW_GAP * T:
			var target_ok: bool = u.target != null and is_instance_valid(u.target) and not u.target.dead
			if not target_ok and nd > rng + 150.0 and close < 20.0:
				var perp := Vector2(-ln._face.y, ln._face.x)
				var side: float = clampf((u.position - ln._c).dot(perp), -3.0 * T, 3.0 * T)
				var sp: Vector2 = ln._same_level(ln._c - ln._face * (AICrownLine.GUN_BACK * T) + perp * side, game.level_of(ln._c), ln._c)
				ln._spot[u] = sp
				u.cmd_pack()
				follows += 1


## A gun of the line set (or setting up) with an enemy known in its reach (or coming into it while it would limber): it
## stays where it is (the line's steps and the mirror's guns-at-the-hall leave it be).
func stays(ln, u: Unit, foes: Array) -> bool:
	if not set_on or not AICrownLine.is_gun(u) or u.tesla_mode == "packed" or u.tesla_mode == "packing":
		return false
	if u.target != null and is_instance_valid(u.target) and not u.target.dead:
		return true
	var rng := float(u.d.get("range", 430))
	for o in foes:
		if not is_instance_valid(o) or o.dead:
			continue
		var p: Vector2 = ln._pos(o)
		var close: float = maxf(0.0, (o.velocity as Vector2).dot((u.position - p).normalized()))
		if p.distance_to(u.position) - close * (Defs.CANNON_SWITCH + GSET_SLACK) < rng - 20.0:
			return true
	return false


## Any gun of the line stays (stays()): the line does not step on away from it.
func any_stays(ln, foes: Array) -> bool:
	for u in ln._spot.keys():
		if ln._ok(u) and stays(ln, u, foes):
			return true
	return false


## (the mirror's guns at the enemy hall, AICrownMirror.guns_at_hall) a gun the standing line keeps for its fight.
func busy(u: Unit) -> bool:
	if not keep_on or ai.ln == null or not ai.ln._spot.has(u) or ai.ln.st in ["", "close"]:
		return false
	return true


# ------------------------------------------------------------------ 5. the wave walks at its guns' pace

## The marching wave (the line's state "", nothing seen): true = the men wait for their guns this think.
func pace(ln, ground: Array, bc: Vector2, target: Vector2) -> bool:
	if not pace_on or target == Vector2.INF:
		return _pace_release(target)
	if game.clock < _pace_cool:
		return false
	var men: Array = []
	var guns: Array = []
	var mc := Vector2.ZERO
	for u in ground:
		if AICrownLine.is_gun(u):
			continue
		if u.is_mounted():
			continue
		men.append(u)
		mc += u.position
	if men.size() < AICrownLine.LINE_MIN:
		return _pace_release(target)
	mc /= men.size()
	var gc := Vector2.ZERO
	for u in ground:
		if AICrownLine.is_gun(u) and u.tesla_mode == "packed" and u.position.distance_to(mc) < PACE_GUNS_R:
			guns.append(u)
			gc += u.position
	if guns.is_empty():
		return _pace_release(target)
	gc /= guns.size()
	var dir: Vector2 = (target - gc).normalized()
	if dir == Vector2.ZERO or gc.distance_to(target) < 700.0:
		return _pace_release(target)
	var lead: float = (mc - gc).dot(dir)
	if _paced.is_empty():
		if lead <= PACE_AHEAD:
			return false
		_pace_t = game.clock
		paces += 1
		if game.clock - _pace_said > 30.0:
			_pace_said = game.clock
			_say("'s wave waits for its guns on the march (%d px ahead of them)" % int(lead))
	if lead < PACE_GO or game.clock - _pace_t > PACE_MAX:
		if game.clock - _pace_t > PACE_MAX:
			_pace_cool = game.clock + PACE_COOL
		return _pace_release(target)
	for u in men:
		if (u.position - gc).dot(dir) > PACE_HOLD:
			if u.order != "hold" and (u.target == null or u.order in ["move", "amove", "idle"]):
				u.cmd_hold()
			_paced[u] = true
		elif _paced.has(u) and u.order == "hold" and (u.position - gc).dot(dir) < PACE_GO:
			_paced.erase(u)
			u.cmd_move(target + Vector2(randf_range(-50, 50), randf_range(-50, 50)), true)
	for u in guns:
		if u.order == "idle":
			u.cmd_move(target + Vector2(randf_range(-50, 50), randf_range(-50, 50)), true)
	for u in men:
		if not _paced.has(u) and u.order == "idle":
			u.cmd_move(target + Vector2(randf_range(-50, 50), randf_range(-50, 50)), true)
	return true


var _pace_said := -99.0


func _pace_release(target: Vector2) -> bool:
	if _paced.is_empty():
		return false
	for u in _paced.keys():
		if is_instance_valid(u) and not u.dead and u.order == "hold" and target != Vector2.INF:
			u.cmd_move(target + Vector2(randf_range(-50, 50), randf_range(-50, 50)), true)
	_paced.clear()
	return false


# ------------------------------------------------------------------ 6. no column up a ramp

func _ramp_on_road(from: Vector2, target: Vector2) -> Dictionary:
	if game.clock - _road_t > RAMP_EVERY or _road_to.distance_to(target) > 100.0 or _road.is_empty() or _road[0].distance_to(from) > 300.0:
		_road_t = game.clock
		_road_to = target
		_road = game.find_path(from, target, false, 7.0, ai.team)
	var walked := 0.0
	var prev: Vector2 = from
	var foot := Vector2.INF
	for i in _road.size():
		var p: Vector2 = _road[i]
		walked += prev.distance_to(p)
		if walked > RAMP_SEE + 600.0:
			break
		var c: Vector2i = game.cell_of(p)
		if not game.in_map(c):
			prev = p
			continue
		var on_ramp: bool = game.ramp[game.idx(c)] != 0
		if foot == Vector2.INF:
			if on_ramp and game.level_of(prev) == 0:
				if walked > RAMP_SEE:
					return {}
				foot = prev
		elif not on_ramp:
			if game.level_of(p) == 1:
				return {"foot": foot, "top": p}
			return {}
		prev = p
	return {}


## What the wave reckons stands on the high ground past the ramp's top: the enemy soldiers seen there (AICrownHold._seen,
## the line's own memory), or, by the enemy's own base, what the enemy has (the Crown's reckoning) less what it has shown
## elsewhere lately, whichever is more.
func _top_reckon(top: Vector2, target: Vector2) -> float:
	var here := 0.0
	var elsewhere := 0.0
	var seen: Dictionary = ai.ch._seen if ai.ch != null else {}
	for o in seen.keys():
		if not is_instance_valid(o) or o.dead:
			continue
		var e: Array = seen[o]
		if game.clock - float(e[0]) > 90.0:
			continue
		if (e[1] as Vector2).distance_to(top) < TOP_R:
			here += float(e[2])
		else:
			elsewhere += float(e[2])
	for o in game.units_near(top, TOP_R):
		if not seen.has(o) and game.hostile(o.team, ai.team) and not o.dead and not o.is_worker() and o.has_attack() \
				and game.is_visible_to(ai.team, o.position):
			here += float(Game.unit_value(o))
	if top.distance_to(target) < 1500.0:
		here = maxf(here, (ai.foe_reckon() - elsewhere) * 0.6)
	return here


## The marching wave (the line's state ""): true = the line stops at a ramp's foot this think.
func ramp(ln, ground: Array, bc: Vector2, target: Vector2) -> bool:
	if not ramp_on or target == Vector2.INF or game.level_of(bc) != 0:
		return false
	var cut: Vector2i = game.cell_of(target)
	if not game.in_map(cut) or game.level_of(target) != 1:
		return false
	var r := _ramp_on_road(bc, target)
	if r.is_empty():
		return false
	var top: Vector2 = r["top"]
	var key: Vector2i = game.cell_of(top)
	if float(_ramp_ok.get(key, -1.0)) > game.clock:
		return false
	var mine: float = ln._value(ground)
	var est := _top_reckon(top, target)
	if est < RAMP_LEAVE or mine >= CLIMB * est:
		_ramp_ok[key] = game.clock + RAMP_OK
		if est >= RAMP_LEAVE:
			climbs += 1
			_say("'s wave goes up the ramp: %d against the %d it reckons up there" % [int(mine), int(est)])
		return false
	var foot: Vector2 = r["foot"]
	var face: Vector2 = (top - foot).normalized()
	if face == Vector2.ZERO:
		return false
	var c: Vector2 = ln._same_level(foot - face * FOOT_BACK, 0, foot)
	ln._face = face
	ln._c = c
	ln._t0 = game.clock
	ln._last_form = game.clock
	ln.st = "foot"
	if ln.lay(ground, c, face, false) == 0:
		ln.st = ""
		return false
	_foot = {"foot": foot, "top": top, "target": target, "t0": game.clock, "key": key}
	feet += 1
	_say("'s wave stops at the foot of the ramp up to the enemy (%d against the %d it reckons up there): its line forms facing up it, the guns behind" % [int(mine), int(est)])
	return true


## The line at the ramp's foot (AICrownLine.march, state "foot").
func foot_tick(ln, ground: Array, target: Vector2, contact: bool, foes: Array) -> bool:
	ln.settle(ln._face)
	if contact:
		return ln._fight_begin(ground)
	if _foot.is_empty():
		return ln._reset(ground, target, "")
	var top: Vector2 = _foot["top"]
	var mine: float = ln._value(ground)
	var est := _top_reckon(top, target)
	var waited: float = game.clock - float(_foot["t0"])
	if (mine >= CLIMB * est or est < RAMP_LEAVE) and waited > 5.0:
		_ramp_ok[_foot["key"]] = game.clock + RAMP_OK
		climbs += 1
		_say("'s wave goes up the ramp: %d against the %d it reckons up there" % [int(mine), int(est)])
		_foot = {}
		return ln._reset(ground, target, "")
	if waited > FOOT_MAX:
		leaves += 1
		ai._bad_spots[target] = game.clock + ai.TRADE_AVOID
		ai._open_t = -99.0
		_say("'s wave will not climb into the enemy's base (%d against the %d it reckons up there): it leaves that target be and looks for another" % [int(mine), int(est)])
		_ramp_ok[_foot["key"]] = game.clock + 20.0
		_foot = {}
		return ln._reset(ground, target, "")
	return true


# ------------------------------------------------------------------ 7. the defence's guns set

## AI._defend's follow loop asks before it sends a detachment's man on to the raid's spot: true = leave this gun be.
func def_gun(u: Unit) -> bool:
	if not def_on or not AICrownLine.is_gun(u):
		return false
	if u.tesla_mode != "packed":
		return u.tesla_mode != "packing"
	var rng := float(u.d.get("range", 430))
	var min_r := float(u.d.get("min_range", 0))
	for o in game.units_near(u.position, rng + 250.0):
		if o.dead or o.off_field or not game.hostile(o.team, ai.team) or o.is_worker() or not o.has_attack():
			continue
		if not game.is_visible_to(ai.team, o.position):
			continue
		var d: float = o.position.distance_to(u.position)
		var close: float = maxf(0.0, (o.velocity as Vector2).dot((u.position - o.position).normalized()))
		if d - close * (Defs.CANNON_SWITCH + GSET_SLACK) < rng - 20.0 and d > min_r + 20.0:
			u.cmd_deploy()
			def_sets += 1
			return true
	return false


# ------------------------------------------------------------------ the count

func tick() -> void:
	if game.clock < _next:
		return
	_next = game.clock + EVERY
	var army: Array = game.army(ai.team)
	var hit := Vector2.INF
	var hit_d := INF
	for u in army:
		if u.dead or u.off_field or u.is_worker() or not u.has_attack() or u.is_air() or u.aboard != null:
			continue
		if AICrownLine.is_gun(u):
			continue
		for o in game.units_near(u.position, CONTACT):
			if o.dead or o.off_field or not game.hostile(o.team, ai.team) or o.is_worker() or not o.has_attack():
				continue
			if not game.is_visible_to(ai.team, o.position):
				continue
			var d: float = 0.0 if _cur.is_empty() else (o.position as Vector2).distance_to(_cur["p"])
			if d < hit_d:
				hit_d = d
				hit = (u.position + o.position) * 0.5
			break
	if not _cur.is_empty():
		if hit != Vector2.INF and hit_d < SAME:
			_cur["last"] = game.clock
		if not _cur["done_first"] and game.clock - float(_cur["t0"]) >= FIRST:
			_cur["done_first"] = true
			var f := 0
			for gun in _cur["guns"]:
				if is_instance_valid(gun) and float(gun.fired_t) >= float(_cur["t0"]) - 0.5:
					f += 1
			_cur["fired"] = f
		if game.clock - float(_cur["last"]) > QUIET:
			_end()
		elif hit != Vector2.INF and hit_d >= SAME:
			_end()
	if _cur.is_empty() and hit != Vector2.INF:
		_begin(hit, army)


func _begin(p: Vector2, army: Array) -> void:
	var guns: Array = []
	var set_n := 0
	for u in army:
		if u.dead or u.off_field or u.aboard != null or not AICrownLine.is_gun(u):
			continue
		if u.position.distance_to(p) < NEAR_GUN:
			guns.append(u)
			if u.tesla_mode == "deployed":
				set_n += 1
	var home := false
	for h in ai._halls():
		if h.center().distance_to(p) < 900.0:
			home = true
			break
	var formed := false
	if ai.ln != null:
		formed = ai.ln.st in ["form", "step", "set", "await", "advance", "back"] or not ai.ln._def_spot.is_empty()
	_cur = {"t0": game.clock, "p": p, "last": game.clock, "guns": guns, "set": set_n, "home": home, "formed": formed,
		"k0": float(game.stats[ai.team]["value_killed"]), "l0": float(ai._lost_value()), "done_first": false, "fired": 0}


func _end() -> void:
	var k: float = float(game.stats[ai.team]["value_killed"]) - float(_cur["k0"])
	var l: float = float(ai._lost_value()) - float(_cur["l0"])
	if not _cur["done_first"]:
		var f := 0
		for gun in _cur["guns"]:
			if is_instance_valid(gun) and float(gun.fired_t) >= float(_cur["t0"]) - 0.5 and float(gun.fired_t) <= float(_cur["t0"]) + FIRST:
				f += 1
		_cur["fired"] = f
	if k + l >= 60.0:           # (a skirmish worth nothing is not a fight)
		var p: Vector2 = _cur["p"]
		fights.append([snappedf(float(_cur["t0"]), 0.1), _cur["home"], _cur["formed"], (_cur["guns"] as Array).size(),
				_cur["set"], _cur["fired"], int(k), int(l), int(p.x), int(p.y)])
		_say("'s fight at %s %s (%s): %d gun%s near, %d set at contact, %d fired in its first %d s; killed %d, lost %d" % [
			_mmss(float(_cur["t0"])), "at home" if _cur["home"] else "out", "formed" if _cur["formed"] else "unformed",
			(_cur["guns"] as Array).size(), "" if (_cur["guns"] as Array).size() == 1 else "s", _cur["set"], _cur["fired"],
			int(FIRST), int(k), int(l)])
	_cur = {}


## The count so far (tools/qa_match.gd "crown_ai").
func counters() -> Dictionary:
	if not _cur.is_empty():
		_end()
	var o := {"fights": fights.duplicate(), "kept": kept, "sets": sets, "follows": follows, "paces": paces, "feet": feet,
		"climbs": climbs, "leaves": leaves, "def_sets": def_sets}
	var n := 0
	var withg := 0
	var fired := 0
	var formed := 0
	for f in fights:
		n += 1
		if int(f[3]) > 0:
			withg += 1
			if int(f[5]) > 0:
				fired += 1
		if f[2]:
			formed += 1
	o["n"] = n
	o["with_guns"] = withg
	o["guns_fired"] = fired
	o["formed"] = formed
	return o
