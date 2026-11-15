class_name AICrownDefence
extends RefCounted
## DEFENDING AGAINST A PUSH (crown-coach-defence, docs/crown-coach-defence.md). The owner's watched game (2026-11-15,
## Hollowfen, Hard OPTIMAL v Hard OPTIMAL, v0.38.1): the Clockwork's push (8, then 11 Clock Soldiers) left its base at
## 4:27 and came to the Crown's natural at 5:29; the Crown held the top of its ramp, but the Musketeers that were out
## (a balloon party's men that never got aboard) were sent home with a plain MOVE past the enemy and died 4 for 0.
## Three parts, each with its own switch (`-- defence:off` turns them all off):
##  1. THE ALERT (`dfwarn:off`): an enemy force seen coming (on our side of the map and closing on our buildings, or near
##     them) worth ALERT_MIN and ALERT_SHARE of our army at home: the Crown gets ready before it arrives: soldiers before
##     labourers (AICrown._army_due), no balloon party leaves and the ones still boarding come home (AICrown.party_wait),
##     and the story says so.
##  2. NO WALK PAST THE ENEMY (`dfpath:off`): a soldier sent to his post or home (the ramp post, the gate, the cliff edge,
##     the rally after a defence) whose way passes in reach of an armed enemy does not walk it with a plain move: in reach
##     of an enemy he fights (a shooter picks the weakest enemy in his reach: focus fire), else he steps round them on
##     the far side, or, boxed in, fights his way on (attack-move).
##  3. THE MUSTER (`dfmuster:off`): a force at our buildings that the army at home cannot beat (AI._defend would send
##     everyone it has, each from where he stands, one after another): the army gathers at the nearest hall on the side
##     away from the enemy, out of its reach, and fights there as one (attack-move together, focus fire) when the enemy
##     comes within reach of it, or when enough has gathered to beat it.

const ALERT_MIN := 200.0         # an enemy force worth at least this ...
const ALERT_SHARE := 0.6         # ... and this share of our army at home calls the alert
const ALERT_SEEN := 30.0         # (s) an enemy soldier seen this long ago still counts
const ALERT_NEAR := 24.0         # (tiles) an enemy force this near our nearest building calls it whichever way it walks
const ALERT_FAR := 60.0          # (tiles) ... and one closing on us (CLOSE_BY tiles since first seen), or on our half of
                                 # the map, from this far
const CLOSE_BY := 3.0            # (tiles)
const ALERT_HOLD := 30.0         # (s) the alert lasts this long after the force is no longer seen coming
const LOOK_EVERY := 2.0          # (s)

const PAD := 60.0                # (px) beyond an enemy's reach that a way past it is still in danger
const MELEE_REACH := 40.0        # (px) the reach counted for a melee enemy (its own range is 20-30)
const LOOK_R := 560.0            # (px) the armed enemies looked at round a soldier on his way
const STEP := 220.0              # (px) a step round the enemy
const HOPELESS := 2.5            # the armed enemies round him worth this times his friends near him: he gets out ...
const ESCAPE_GAP := 70.0         # (px) ... when the nearest is still this far beyond its reach
const LOCAL_R := 300.0           # (px) his friends counted this near him
const REORDER := 1.2             # (s) a steered soldier gets a new order at most this often

const MUSTER_K := 1.2            # the home army worth less than this times the force at our buildings: it musters
const MUSTER_MIN := 150.0        # ... a force of at least this
const MUSTER_BACK := 3.0         # (tiles) the muster point stands this far beyond the hall from the enemy
const MUSTER_R := 160.0          # (px) a soldier this near the muster point has gathered
const ENGAGE_R := 330.0          # (px) an armed enemy this near the muster point: the gathered army fights as one
const ENGAGE_K := 1.0            # ... or as soon as the gathered army is worth this times the force
const GATHERED := 0.6            # ... and this share of the army has gathered (the rest joins as it comes)

var ai = null
var game: Game = null
var on := not OS.get_cmdline_user_args().has("defence:off")
var warn_on := not OS.get_cmdline_user_args().has("dfwarn:off")
var path_on := not OS.get_cmdline_user_args().has("dfpath:off")
var muster_on := not OS.get_cmdline_user_args().has("dfmuster:off")
var _dbg := OS.get_cmdline_user_args().has("dfdebug")

var alert := false
var alert_t := -1.0              # when the alert came (the bench reads it: tools/crown_defence_bench.gd)
var alerts := 0                  # (tests, the coach)
var steers := 0                  # soldiers that stepped round the enemy instead of walking past it
var fights := 0                  # ... or fought back where they stood
var musters := 0                 # (tests, the coach) musters called
var engages := 0                 # ... and fought as one
var log_lines: Array = []        # [clock, text]
var _look_t := -99.0
var _last_hot := -999.0
var _first := {}                 # enemy soldier -> [clock, home distance (px)] when first seen
var _steer_t := {}               # Unit -> clock of its last steering order
var _mustering := false
var _muster_p := Vector2.INF
var _muster_hall: Building = null
var _muster_said := -99.0
var _engaged := false


func _init(a) -> void:
	ai = a
	game = a.game


func _say(s: String) -> void:
	log_lines.append([game.clock, s])
	if game.mlog:
		game.mlog.add("%s %s" % [game.mlog.who(ai.team), s])


func active() -> bool:
	return on and ai.on and ai.difficulty >= 1 and not ai.peaceful


func _home_d(p: Vector2) -> float:
	var best := INF
	for b in game.buildings:
		if b.team == ai.team and not b.dead and not b.ghost:
			best = minf(best, b.center().distance_to(p))
	return best


# ============================================================ 1. the alert

func tick() -> void:
	if not active() or not warn_on:
		return
	_boarding()
	if game.clock - _look_t < LOOK_EVERY:
		return
	_look_t = game.clock
	var T := float(Defs.TILE)
	var seen: Dictionary = ai.ch._seen if ai.ch != null else {}
	for u in _first.keys():
		if not seen.has(u):
			_first.erase(u)
	var me: Vector2 = game.start_mid(ai.team)
	var fo: int = ai._foe()
	var them: Vector2 = game.start_mid(fo) if fo >= 0 else Vector2.INF
	var force := 0.0
	var n := 0
	var nearest := INF
	var coming := 0.0            # ... of it near our buildings or closing on them (the wave's recall weighs this)
	var coming_c := Vector2.ZERO
	for u in seen:
		var e: Array = seen[u]
		if game.clock - float(e[0]) > ALERT_SEEN:
			continue
		var p: Vector2 = e[1]
		var hd := _home_d(p)
		if not _first.has(u):
			_first[u] = [float(e[0]), hd]
		var closing: bool = float(_first[u][1]) - hd >= CLOSE_BY * T
		var ours: bool = them != Vector2.INF and p.distance_to(me) < p.distance_to(them)
		if hd < ALERT_NEAR * T or (hd < ALERT_FAR * T and (closing or ours)):
			force += float(e[2])
			n += 1
			nearest = minf(nearest, hd)
			if hd < ALERT_NEAR * T or closing:
				coming += float(e[2])
				coming_c += p * float(e[2])
	var home: float = ai.ch.home_value() if ai.ch != null else float(game.army_value(ai.team))
	_coming = coming
	_home_v = home
	var hot := force >= ALERT_MIN and force >= home * ALERT_SHARE
	if hot:
		_last_hot = game.clock
		if not alert:
			alert = true
			alert_t = game.clock
			alerts += 1
			_say("sees a push coming: %d soldiers worth %d, %d tiles from its nearest building, against %d of army at home: it gets ready (soldiers before labourers, the balloons stay home, the army waits at its post)" % [n, int(force), int(nearest / T), int(home)])
			_recall()
		if coming > 0.0:
			_recall_wave(coming, coming_c / coming, home)
	elif alert and game.clock - _last_hot > ALERT_HOLD:
		alert = false
		_say("the push it saw coming is gone or held: back to its plan")


## The alert's call home: a balloon party still boarding comes home (the men are not left walking about below).
func _recall() -> void:
	var bl = ai.bl
	if bl == null:
		return
	for p in bl.parties:
		if String(p["phase"]) == "load":
			bl._release(p, "a push is coming: the men stay home")


## THE WAVE COMES HOME: a wave out (not in a fight) while an enemy force bigger than the army at home can beat comes at
## our buildings, nearer them than the wave is: the wave is called home (the post places it; steer keeps it off the
## enemy's way) and the two meet the push together. Red Coast 5103: the Crown's wave of 1,450 marched on while a push of
## 3,185 came at its halls, and fell man by man between them.
const RECALL_HOME := 1.5         # the push worth more than this times the army at home ...
const RECALL_WAVE := 0.5         # ... and this share of the wave at least (a raid at home does not call the wave back)
const RECALL_CONTACT := 420.0    # (px) ... and no armed enemy this near a man of the wave
var recalls := 0                 # (tests, the coach)


func _recall_wave(coming: float, at: Vector2, home: float) -> void:
	if not ai._attacking or coming < home * RECALL_HOME:
		return
	var wave: Array = ai._wave_set.keys().filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)
	if wave.is_empty():
		return
	var wc := Vector2.ZERO
	var wv := 0.0
	for u in wave:
		if not _foes_near(u.position, RECALL_CONTACT).is_empty():
			return              # (in a fight: the line falls back by its own rules, AICrownLine)
		wc += u.position
		wv += ai._unit_value(u)
	wc /= float(wave.size())
	if coming < wv * RECALL_WAVE:
		return
	if _home_d(at) >= _home_d(wc):
		return                  # (the wave stands between the push and home, or nearer home than it)
	recalls += 1
	_say("calls its wave home: the push coming (%d) is more than the army at home (%d) can beat; the wave (%d) is %d tiles out and meets it at home" % [int(coming), int(home), int(wv), int(_home_d(wc) / float(Defs.TILE))])
	var back: Vector2 = ai._home_spot(ai._front())
	for u in wave:
		u.cmd_move(back + Vector2(randf_range(-70, 70), randf_range(-70, 70)))
	ai._attacking = false
	ai._release_escort()
	ai._wave_end()
	ai._wave_set.clear()


## (AICrown._wave_worth) no wave goes out while the push coming is more than the army at home can beat (it would meet the
## push on the way, or leave home to it).
var _coming := 0.0


func wave_waits(_ready: Array) -> bool:
	return active() and warn_on and alert and _coming >= _home_v * RECALL_HOME


var _home_v := 0.0


## Men walking to board a balloon are on an errand (the army, the post and the defence leave them be): an armed enemy
## near one of them (in its reach and a margin, or BOARD_R) ends the party, and the men come under the defence (the post
## places them, steer keeps them from walking past the enemy). The owner's game: three men walked 40 s to a balloon that
## never took them, past the Clockwork's push, and died.
const BOARD_R := 300.0
const BOARD_REST := 30.0         # (s) then no party forms for this long
var _board_stop_t := -99.0


func _boarding() -> void:
	var bl = ai.bl
	if bl == null:
		return
	for p in bl.parties:
		if String(p["phase"]) != "load":
			continue
		for m in p["men"]:
			if is_instance_valid(m) and not m.dead and m.aboard == null and not _foes_near(m.position, BOARD_R).is_empty():
				bl._release(p, "the enemy is at the men walking to board")
				_board_stop_t = game.clock
				break


## (AICrown._army_due) soldiers before labourers while the alert lasts. Measured (docs/crown-coach-defence.md): only while
## the force coming was more than the army at home (SOLDIERS_K 1.0, `dfsoldiers:behind`) the Crown earned 3% less than
## before but its home trade fell back to the old one (home kills per loss 1.67 v 1.65); for the whole alert it earned 7%
## less and had half again the army at 12:00 (24,190 v 15,710 in 16 games), 30% fewer buildings lost, home kills per
## loss 2.77.
const SOLDIERS_K := 1.0
var soldiers_behind := OS.get_cmdline_user_args().has("dfsoldiers:behind")


func wants_soldiers() -> bool:
	return active() and warn_on and alert and (not soldiers_behind or _coming >= _home_v * SOLDIERS_K)


## (AICrown.party_wait) no balloon party forms while the alert lasts (or BOARD_REST s after one was called off).
func party_wait() -> bool:
	return active() and warn_on and (alert or game.clock - _board_stop_t < BOARD_REST)


# ============================================================ 2. no walk past the enemy

## The armed enemies in sight round this soldier.
func _foes_near(p: Vector2, r: float) -> Array:
	var out: Array = []
	for o in game.units_near(p, r):
		if game.hostile(o.team, ai.team) and not o.dead and not o.off_field and not o.is_air() and ai._armed(o) and ai._sighted(o):
			out.append(o)
	return out


func _value_near(team: int, p: Vector2, r: float) -> float:
	var v := 0.0
	for o in game.units_near(p, r):
		if o.team == team and not o.dead and not o.off_field and ai._armed(o):
			v += ai._unit_value(o)
	return v


func _value_of(list: Array) -> float:
	var v := 0.0
	for o in list:
		v += ai._unit_value(o)
	return v


func _reach(o: Unit) -> float:
	return maxf(float(o.d.get("range", 20)), MELEE_REACH)


## The soldier is sent to `dest` (his post, home): true = this gave him an order instead (he fights where he is, or steps
## round the enemy); false = the way is clear, the caller orders as before.
func steer(u: Unit, dest: Vector2) -> bool:
	if not active() or not path_on or u == null or u.aboard != null or u.dead:
		return false
	if u.kind in ["cannon", "mortar"]:
		return false            # (a gun goes where it is sent: limbered it cannot fight, and it sets up behind the line)
	var foes := _foes_near(u.position, LOOK_R)
	if foes.is_empty():
		return false
	var from: Vector2 = u.position
	var danger := false
	for o in foes:
		var q: Vector2 = o.position
		var r := _reach(o) + PAD
		if Geometry2D.get_closest_point_to_segment(q, from, dest).distance_to(q) < r:
			danger = true
			break
	if not danger:
		return false
	if game.clock - float(_steer_t.get(u, -99.0)) < REORDER and u.order != "idle" and u.order != "hold":
		return true             # (he has his order: let him carry it out)
	_steer_t[u] = game.clock
	# in reach of an enemy (his or theirs): he fights; a shooter takes the weakest enemy in his reach (focus fire)
	var my_r := float(u.d.get("range", 20)) + u.radius
	var best: Unit = null
	var best_hp := INF
	var closest := INF
	for o in foes:
		var d: float = o.position.distance_to(from)
		closest = minf(closest, d - _reach(o))
		if d <= my_r + o.radius and o.hp < best_hp:
			best_hp = o.hp
			best = o
	# hopeless where he stands (the enemy in reach worth HOPELESS times his friends there) and still a step from them: he
	# gets out instead (Hollowfen 5101, 10:11-10:22: six Musketeers alone at the natural's Barracks died one by one to
	# 1,945 of Clock Soldiers)
	var hopeless := closest > ESCAPE_GAP and _value_near(ai.team, from, LOCAL_R) * HOPELESS < _value_of(foes)
	if best != null and not hopeless and (closest < 30.0 or u.has_attack()):
		if not (u.order == "attack" and u.target == best):
			u.cmd_attack(best)
		fights += 1
		return true
	# else round them: the step that keeps out of every enemy's reach and gains the most on the way to dest
	var T := float(Defs.TILE)
	var best_p := Vector2.INF
	var best_s := -INF
	for k in 12:
		var a := TAU * float(k) / 12.0
		var p: Vector2 = from + Vector2.RIGHT.rotated(a) * STEP
		var c: Vector2i = game.cell_of(p)
		if not game.in_map(c) or not game.open_cell(c):
			continue
		var clear := INF
		for o in foes:
			clear = minf(clear, o.position.distance_to(p) - _reach(o) - PAD)
		if clear < 0.0:
			continue
		var s := (from.distance_to(dest) - p.distance_to(dest)) + 0.5 * minf(clear, 3.0 * T)
		if s > best_s:
			best_s = s
			best_p = p
	if best_p == Vector2.INF:
		if best != null:
			u.cmd_attack(best)      # (boxed in: he fights where he stands)
			fights += 1
			return true
		u.cmd_move(dest, true)      # (boxed in: he fights his way on)
		fights += 1
		return true
	u.cmd_move(best_p)
	steers += 1
	return true


# ============================================================ 3. the muster

## Called by AI._army before AI._defend (AICrown._def_hold): true = the army musters (AI._defend is skipped).
func muster(army: Array, spots: Array) -> bool:
	if not active() or not muster_on or ai.ch == null:
		if _mustering:
			_end_muster()
		return false
	var home: Array = army.filter(func(u: Unit) -> bool: return not (ai._attacking and ai._wave_set.has(u)) and u.kind != "balloon")
	var foe: float = ai.ch.force_at(spots)
	var mine := 0.0
	for u in home:
		mine += ai._unit_value(u)
	if home.is_empty() or foe < MUSTER_MIN or mine >= foe * MUSTER_K:
		if _mustering:
			_end_muster()
		return false
	# the enemy's middle, and where to gather: the far side of a hall (the nearest to the enemy first, then the others) or
	# where most of the army stands, the first with no armed enemy within SAFE_R of it, nearest the army's men (Red Coast
	# 5103 10:55: the hall's far side had the push on it already and 18 men were called into it)
	var c := Vector2.ZERO
	var nc := 0
	for sp in spots:
		c += sp
		nc += 1
	c /= float(maxi(1, nc))
	if not _mustering or not _foes_near(_muster_p, SAFE_R * 0.6).is_empty() and _gathered(home) < 0.5:
		var mp := _pick_muster(home, c)
		if mp == Vector2.INF:
			if _mustering:
				_end_muster()
			return false        # (no hall and no army: AI._defend as before)
		_muster_p = mp          # (fixed while it lasts: a point that follows the enemy's middle walks the army about)
	if not _mustering:
		_mustering = true
		_engaged = false
		musters += 1
	if not ai._det.is_empty():
		ai._end_defence()
	# who has gathered, and the enemy near the muster
	var near_foes := _foes_near(_muster_p, ENGAGE_R)
	var got := 0.0
	var got_n := 0
	for u in home:
		if u.position.distance_to(_muster_p) < MUSTER_R:
			got += ai._unit_value(u)
			got_n += 1
			if near_foes.is_empty() and u.target != null and is_instance_valid(u.target) and not u.target.dead \
					and u.target is Unit and ai._armed(u.target):
				near_foes = [u.target]      # (a gathered man is already shooting at them)
	var go := not near_foes.is_empty() or (got >= foe * ENGAGE_K and float(got_n) >= GATHERED * float(home.size()))
	if _dbg:
		print("  [dfn %.1f] muster foe %d mine %d got %d/%d near %d go %s at %s; %s" % [game.clock, int(foe), int(mine), got_n, home.size(), near_foes.size(), str(go), str(_muster_p.round()),
			", ".join(home.map(func(u) -> String: return "%s %d" % [u.order, int(u.position.distance_to(_muster_p))]))])
	if game.clock - _muster_said > 30.0:
		_muster_said = game.clock
		_say("musters at its hall: the force at its buildings (%d) is more than its army at home (%d) can beat one by one; it gathers out of reach and fights there as one" % [int(foe), int(mine)])
	if go and not _engaged and got_n >= 2:
		_engaged = true
		engages += 1
		_say("fights as one at its hall: %d gathered (%d of %d soldiers) against %d" % [int(got), got_n, home.size(), int(foe)])
	# the focus: the weakest enemy in reach of the gathered body, else the nearest to the muster
	var focus: Unit = null
	if go:
		var pool: Array = near_foes if not near_foes.is_empty() else _foes_near(_muster_p, 900.0)
		var best := INF
		for o in pool:
			var s: float = o.hp + o.position.distance_to(_muster_p) * 0.2
			if s < best:
				best = s
				focus = o
	for u in home:
		var d: float = u.position.distance_to(_muster_p)
		if go and d < MUSTER_R * 2.0 and focus != null:
			if u.target == null or not is_instance_valid(u.target) or u.target.dead or u.order != "attack":
				if u.position.distance_to(focus.position) < float(u.d.get("range", 20)) + 120.0:
					u.cmd_attack(focus)
				else:
					u.cmd_move(focus.position, true)
			continue
		if d < MUSTER_R:
			if u.target != null and is_instance_valid(u.target) and not u.target.dead:
				continue            # (busy fighting what came in reach)
			if u.order != "hold" and d < MUSTER_R * 0.6:
				u.cmd_hold()
			elif u.order != "hold" and u.order != "move":
				u.cmd_move(_muster_p + Vector2(randf_range(-40, 40), randf_range(-40, 40)))
			continue
		if steer(u, _muster_p):
			continue
		if u.order != "move" or (u.order_point as Vector2).distance_to(_muster_p) > MUSTER_R:
			u.cmd_move(_muster_p + Vector2(randf_range(-40, 40), randf_range(-40, 40)))
	return true


const SAFE_R := 420.0             # (px) a muster point with an armed enemy this near it is not taken


func _gathered(home: Array) -> float:
	if home.is_empty() or _muster_p == Vector2.INF:
		return 0.0
	return float(home.filter(func(u: Unit) -> bool: return u.position.distance_to(_muster_p) < MUSTER_R).size()) / float(home.size())


func _pick_muster(home: Array, c: Vector2) -> Vector2:
	var T := float(Defs.TILE)
	var cands: Array = []
	var halls: Array = ai._halls().filter(func(h) -> bool: return (h as Building).built)
	halls.sort_custom(func(a, b) -> bool: return (a as Building).center().distance_to(c) < (b as Building).center().distance_to(c))
	for h in halls:
		var away: Vector2 = ((h as Building).center() - c).normalized()
		if away == Vector2.ZERO:
			away = Vector2.UP
		for k in [MUSTER_BACK * T + 64.0, 80.0]:
			var p: Vector2 = (h as Building).center() + away * k
			var pc: Vector2i = game.cell_of(p)
			if game.in_map(pc) and game.open_cell(pc):
				cands.append(p)
				break
	# where the army stands (its middle man)
	if not home.is_empty():
		var mid := Vector2.ZERO
		for u in home:
			mid += u.position
		mid /= float(home.size())
		var best_u: Unit = home[0]
		for u in home:
			if u.position.distance_to(mid) < best_u.position.distance_to(mid):
				best_u = u
		cands.append(best_u.position)
	var best := Vector2.INF
	var best_s := INF
	var far := Vector2.INF       # (none out of reach: the one farthest from them)
	var far_d := -1.0
	for p in cands:
		var near := _foes_near(p, SAFE_R)
		if not near.is_empty():
			var dmin := INF
			for o in near:
				dmin = minf(dmin, o.position.distance_to(p))
			if dmin > far_d:
				far_d = dmin
				far = p
			continue
		var s := 0.0
		for u in home:
			s += minf(u.position.distance_to(p), 1600.0)
		if s < best_s:
			best_s = s
			best = p
	return best if best != Vector2.INF else far


func _end_muster() -> void:
	_mustering = false
	_muster_hall = null
	_engaged = false
	_muster_p = Vector2.INF


func mustering() -> bool:
	return _mustering
