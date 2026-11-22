class_name AIWr1000BroodMirror
extends RefCounted
## WR1000, THE BROOD MIRROR (wr1000-brood-mirror, the owner 2026-11-22 01:29: a fresh win-rate study as "1000 over 10s",
## blocks of 10 games, ONE change of the computer's play a block; docs/wr1000_brood_mirror.md). The Brood computer (Hard
## OPTIMAL) against the Brood computer, games to 20:00 on the 6 parity maps. Every change here runs only when a Brood
## computer faces another Brood (the mirror: AIBroodNew._foe_is("brood")), so the sister jobs of the other pairings merge
## beside it. Each change has its own switch: `-- wbm<name>:on` / `:off`; `-- wbm:off` plays the mirror as before this job.
## The changes KEPT are on by default (KEPT); the rest were measured and not kept (the doc says what each did).

const KEPT: Array[String] = []

static var _args: PackedStringArray = OS.get_cmdline_user_args()


## Is change `name` on (in the mirror; the caller checks the matchup)?
static func on(name: String) -> bool:
	if _args.has("wbm:off"):
		return false
	if _args.has("wbm%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("wbm%s:on" % name)


## Is this Brood computer in the mirror (its enemy a Brood)?
static func mirror(ai) -> bool:
	return ai._foe_is("brood")


## The kills and losses of the last WINDOW s (value), kept once a second in ai.wbm["hist"]: [clock, killed, lost].
const WINDOW := 60.0


static func note(ai) -> void:
	if not mirror(ai):
		return
	var w: Dictionary = ai.wbm
	if ai.game.clock - float(w.get("note_t", -9.0)) < 1.0:
		return
	w["note_t"] = ai.game.clock
	var foe: int = ai._foe()
	var lost := int(ai.game.stats[foe]["value_killed"]) if foe >= 0 else 0
	var h: Array = w.get("hist", [])
	h.append([ai.game.clock, int(ai.game.stats[ai.team]["value_killed"]), lost])
	while h.size() > 2 and ai.game.clock - float(h[0][0]) > WINDOW:
		h.pop_front()
	w["hist"] = h


## [killed, lost] in the last WINDOW s.
static func recent(ai) -> Array:
	var h: Array = ai.wbm.get("hist", [])
	if h.size() < 2:
		return [0, 0]
	return [int(h[-1][1]) - int(h[0][1]), int(h[-1][2]) - int(h[0][2])]


# ------------------------------------------------------------------ block 2: THE COUNTER (`wbmcounter`)
## THE COUNTER-ATTACK (block 1's games: every wave at the enemy's home lost half or more to the defender's swamp, Sires and
## rooted creatures and pulled back; the defender then sat at home until its own army was at the cap and threw it in the
## same way, so the games see-sawed to 20:00). When the enemy has just broken a wave on its home (it killed COUNTER_KILL
## of the enemy army it had seen in the last minute, and lost under COUNTER_LOSS of what it killed) and its army is worth
## COUNTER_EDGE times what it reckons the enemy has left (the biggest army seen less what it killed since), it goes at
## once, whatever its cap and its plan's wave rules say: the enemy's army is at its smallest now.
const COUNTER_KILL := 0.4
const COUNTER_LOSS := 0.7
const COUNTER_EDGE := 1.3
const COUNTER_GAP := 90.0
const COUNTER_FROM := 360.0


static func counter(ai, army_v: float, sup: int) -> bool:
	if not on("counter") or not mirror(ai) or ai._attacking or sup < 12 or ai.game.clock < COUNTER_FROM:
		return false
	var w: Dictionary = ai.wbm
	if ai.game.clock - float(w.get("counter_t", -999.0)) < COUNTER_GAP:
		return false
	var kl := recent(ai)
	var killed := float(kl[0])
	var lost := float(kl[1])
	if ai.seen_army < 300.0 or killed < ai.seen_army * COUNTER_KILL or lost > killed * COUNTER_LOSS:
		return false
	var left := maxf(0.0, ai.seen_army - killed)
	if army_v < left * COUNTER_EDGE or ai._foe_near_home > army_v * 0.25:
		return false
	w["counter_t"] = ai.game.clock
	w["counters"] = int(w.get("counters", 0)) + 1
	ai.say("counter-attacks: it broke the enemy's wave (killed %d, lost %d), %d against the %d it reckons left" % [int(killed), int(lost), int(army_v), int(left)])
	return true


## The one hook in AIBroodNew._nb_army: true = its army goes now (a wave out of this job's rules), past the cap and plan rules.
static func go(ai, q, army: Array, sup: int) -> bool:
	if not mirror(ai):
		return false
	var v: float = ai._value_of(army)
	if chase(ai, q, v, sup):
		return true
	return counter(ai, v, sup)


# ------------------------------------------------------------------ THE OUTER GROUND (`wbmouter`)
## THE WAVE'S GOAL (block 1's games: against another Brood the wave's goal was the enemy's START, its Mother: the Brood has
## no buildings, so AIBroodNew._nb_wave_goal never found a nearer one. Every wave walked into her swamp, her Sires and her
## whole army and traded 1 for 3: 70 of 80 waves pulled back with half or less, killing a quarter of what they lost). Now
## the wave goes for the enemy's OUTER ground: the rooted creature it has seen (a Mound Turtle, a Rootmaw) farthest from the
## enemy Mother, OUTER_MIN tiles from her at least, the nearer to its own Mother the better. Razed, the next one; none
## known: the Mother as before.
const OUTER_MIN := 16.0


static func outer_goal(ai, q, from: Vector2) -> Vector2:
	if not on("outer") or not mirror(ai):
		return Vector2.INF
	var foe: int = ai._foe()
	if foe < 0:
		return Vector2.INF
	var fq: Unit = BroodNew.queen(ai.game, foe)
	var fqp: Vector2 = fq.position if fq != null else (Vector2(ai.game.starts[foe]) + Vector2(2.5, 2.0)) * Defs.TILE
	var mine: Vector2 = ai._qp(q)
	var best := Vector2.INF
	var bs := -INF
	for u in ai._foe_nb_seen.keys():
		if not is_instance_valid(u) or u.dead or u.team != foe or not (u.kind in [BroodNew.TURTLE, BroodNew.MAW]):
			continue
		var dq: float = u.position.distance_to(fqp)
		if dq < OUTER_MIN * Defs.TILE or u.position.distance_to(from) < 3.0 * Defs.TILE:
			continue
		var s: float = dq - 0.5 * u.position.distance_to(mine) - 0.3 * u.position.distance_to(from)
		if s > bs:
			bs = s
			best = u.position
	return best


# ------------------------------------------------------------------ THE CHASE (`wbmchase`)
## THE CHASE (blocks 1-3: a broken wave walked home through open ground with nobody after it: the defender stood down at
## DEF_LEASH and went back to its rally, so the attacker kept a third to half of its wave and refilled it from its bank
## in a minute). When an enemy army it has just beaten at home (it killed CHASE_KILL of the enemy army seen lately in
## the last minute and lost less than it killed) is seen walking AWAY from its Mother, worth under CHASE_EDGE of its own
## army, its army follows and bites it on the road: the chase's goal is that group, retaken every 2 s; it stops once the
## wave is CHASE_STOP tiles from the enemy Mother (her swamp, her Sires), the group is out of sight 6 s, or after CHASE_MAX s.
const CHASE_KILL := 0.3
const CHASE_EDGE := 0.7
const CHASE_STOP := 22.0
const CHASE_MAX := 50.0
const CHASE_SEE := 34.0


## The enemy fighters seen within CHASE_SEE tiles of its Mother (not rooted, not flyers): [value, middle].
static func _foes_near(ai, q) -> Array:
	var c: Vector2 = ai._qp(q)
	var v := 0.0
	var m := Vector2.ZERO
	for u in ai.game.units_near(c, CHASE_SEE * Defs.TILE):
		if u.dead or u.off_field or u.team < 0 or not ai.game.hostile(u.team, ai.team) or not u.has_attack() or u.is_worker():
			continue
		if u._k_nb or u.is_air() or not ai.game.is_visible_to(ai.team, u.position):
			continue
		var uv := float(Game.unit_value(u))
		v += uv
		m += u.position * uv
	return [v, m / v if v > 0.0 else Vector2.INF]


static func chase(ai, q, army_v: float, sup: int) -> bool:
	var w: Dictionary = ai.wbm
	if bool(w.get("chasing", false)) and not ai._attacking and ai.game.clock - float(w.get("chase_t", 0.0)) > 1.5:
		w["chasing"] = false          # (a chase that never left, or a wave ended some other way)
	if not on("chase") or ai._attacking or sup < 8:
		return false
	var fn := _foes_near(ai, q)
	var prev: Array = w.get("near", [0.0, Vector2.INF, -99.0])
	w["near"] = [fn[0], fn[1], ai.game.clock]
	if float(fn[0]) < 150.0 or prev[1] == Vector2.INF or fn[1] == Vector2.INF or ai.game.clock - float(prev[2]) > 3.0:
		return false
	var c: Vector2 = ai._qp(q)
	var away: bool = (fn[1] as Vector2).distance_to(c) > (prev[1] as Vector2).distance_to(c) + 8.0
	if not away or float(fn[0]) > army_v * CHASE_EDGE:
		return false
	var kl := recent(ai)
	if float(kl[0]) < ai.seen_army * CHASE_KILL or float(kl[1]) >= float(kl[0]):
		return false
	w["chase_t"] = ai.game.clock
	w["chasing"] = true
	w["chase_seen"] = ai.game.clock
	w["chases"] = int(w.get("chases", 0)) + 1
	ai.say("chases a beaten enemy army of %d going home with %d" % [int(fn[0]), int(army_v)])
	return true


## The chase's goal for the wave about to leave (Vector2.INF: not a chase).
static func chase_goal(ai, q) -> Vector2:
	if not bool(ai.wbm.get("chasing", false)) or ai._attacking:
		return Vector2.INF
	var fn: Array = ai.wbm.get("near", [0.0, Vector2.INF])
	return fn[1]


## The chase on the road: true = it steered the wave this think (the rest of _nb_wave_tick is skipped).
static func chase_tick(ai, q, mid: Vector2) -> bool:
	if not bool(ai.wbm.get("chasing", false)):
		return false
	var w: Dictionary = ai.wbm
	var foe: int = ai._foe()
	var fq: Unit = BroodNew.queen(ai.game, foe) if foe >= 0 else null
	var near_her: bool = fq != null and mid.distance_to(fq.position) < CHASE_STOP * Defs.TILE
	var best: Unit = null
	for u in ai.game.units_near(mid, 16.0 * Defs.TILE):
		if u.dead or u.off_field or u.team < 0 or not ai.game.hostile(u.team, ai.team) or not u.has_attack() or u.is_worker():
			continue
		if u._k_nb or u.is_air() or not ai.game.is_visible_to(ai.team, u.position):
			continue
		if fq != null and u.position.distance_to(fq.position) < CHASE_STOP * Defs.TILE:
			continue
		if best == null or u.position.distance_to(mid) < best.position.distance_to(mid):
			best = u
	if best != null:
		w["chase_seen"] = ai.game.clock
	if near_her or ai.game.clock - float(w.get("chase_seen", 0.0)) > 6.0 or ai.game.clock - float(w.get("chase_t", 0.0)) > CHASE_MAX:
		w["chasing"] = false
		ai.say("ends its chase (%s)" % ("at the enemy's swamp" if near_her else "nothing left to bite"))
		ai._wave_end_nb(q, false)
		return true
	if best != null and ai.game.clock - float(w.get("chase_steer", -9.0)) > 2.0:
		w["chase_steer"] = ai.game.clock
		ai._wave_target = best.position
		for u in ai._wave:
			if u.target == null or u.order != "attack":
				u.cmd_move(best.position, true)
	return false


## The one hook in AIBroodNew._nb_wave_goal: this job's goal for a wave leaving now (Vector2.INF: the usual one).
static func wave_goal(ai, q) -> Vector2:
	if not mirror(ai):
		return Vector2.INF
	var cg := chase_goal(ai, q)
	if cg != Vector2.INF:
		return cg
	return outer_goal(ai, q, ai._qp(q))
