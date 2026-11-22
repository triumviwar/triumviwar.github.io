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
	if bool(w.get("was_out", false)) and not ai._attacking:
		w["wave_end_t"] = ai.game.clock          # (a wave just came home: regroup)
	w["was_out"] = ai._attacking
	if on("grubs"):
		grubs_tick(ai)
	if on("chase"):
		# (the chase: the enemy army near its Mother, once a second, and what it was 2 s ago)
		var q = BroodNew.queen(ai.game, ai.team)
		if q != null:
			var fn := _foes_near(ai, q)
			var hn: Array = w.get("near_h", [])
			hn.append([fn[0], fn[1], ai.game.clock])
			if hn.size() > 3:
				hn.pop_front()
			w["near_h"] = hn
			w["near"] = hn[-1]
			w["near0"] = hn[0]


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


## The one hook in AIBroodNew._nb_army: 1 = its army goes now (a wave out of this job's rules), past the cap and plan
## rules; -1 = it holds this think; 0 = the usual rules.
static func go(ai, q, army: Array, sup: int) -> int:
	if not mirror(ai):
		return 0
	var v: float = ai._value_of(army)
	if chase(ai, q, v, sup):
		return 1
	if counter(ai, v, sup):
		return 1
	if quality_hold(ai, q, army):
		return -1
	if regroup_hold(ai, sup):
		return -1
	return 0


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
const CHASE_SEE := 44.0


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
	var fn: Array = w.get("near", [0.0, Vector2.INF, -99.0])
	var prev: Array = w.get("near0", [0.0, Vector2.INF, -99.0])
	if float(fn[0]) < 150.0 or prev[1] == Vector2.INF or fn[1] == Vector2.INF or ai.game.clock - float(fn[2]) > 1.5:
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


# ------------------------------------------------------------------ THE CAPPED ARMY GROWS UP (`wbmquality`)
## THE CAPPED ARMY (blocks 1-3: from 12:00 both sides sat at 200 supply with 2,000 to 7,000 food banked, and their waves
## were 100-130 Raptors: the cheapest creature, 38 health a supply. MATURE stopped at the cap (a Tyrant Challenger needs
## one more supply than its Raptor) and at half of each young kind). At the cap with QUALITY_FOOD food or more, it
## matures the young at home (Raptors into Tyrant Challengers, 65 health a supply; Spitters into Venom Challengers, 110)
## past the half, QUALITY_EACH a think, and when the cap stops it, offers a Raptor at home up to the Mother to make room
## (a Raptor's spoils back). Rooted creatures, grubs and the wave out are left alone.
const QUALITY_FOOD := 1500
const QUALITY_EACH := 4


static func quality(ai, q) -> bool:
	if not on("quality") or not mirror(ai):
		return false
	var g = ai.game
	var t: int = ai.team
	var capped: bool = g.supply_used(t) >= mini(int(g.players[t]["cap"]), g.max_supply(t)) - 6
	if not capped or ai._food() < QUALITY_FOOD or BroodNew.stage(q) < 1:
		return false
	var home: Vector2 = ai._qp(q)
	var n := 0
	var blocked := false
	for yk in ["spitter", "raptor"]:
		var mk := BroodMature.mature_of(yk)
		if BroodNew.stage(q) < BroodNew.unit_stage(mk):
			continue
		for u in ai._nb_mine(yk):
			if n >= QUALITY_EACH:
				break
			if u.moult_t >= 0.0 or (u.target != null and is_instance_valid(u.target)) or ai.in_wave(u) or u == ai._scout \
					or u.position.distance_to(home) > 22.0 * Defs.TILE or ai.held.has(u):
				continue
			var why := BroodMature.problem(u)
			if why == "Supply is maxed out." or why.begins_with("Need more supply"):
				blocked = true
				break
			if why != "" or ai._food() - int(BroodMature.price(g, t, u.kind)[0]) < 500:
				continue
			BroodMature.start(u)
			n += 1
	if blocked and ai.game.clock - float(ai.wbm.get("offer_t", -9.0)) > 1.0:
		# (the cap stops it: a Raptor at home offered up makes room for the next to mature)
		var rs: Array = ai._nb_mine("raptor").filter(func(u) -> bool: return u.position.distance_to(home) < 16.0 * Defs.TILE \
			and u.target == null and u.order != "sacrifice" and not ai.in_wave(u) and u != ai._scout and u.moult_t < 0.0 and u.can_sacrifice())
		if rs.size() >= 4:
			(rs[0] as Unit).cmd_sacrifice()
			ai.wbm["offer_t"] = ai.game.clock
			ai.wbm["offered"] = int(ai.wbm.get("offered", 0)) + 1
	ai.wbm["matured"] = int(ai.wbm.get("matured", 0)) + n
	if ai.game.clock - float(ai.wbm.get("q_said", -999.0)) > 120.0:
		ai.wbm["q_said"] = ai.game.clock
		ai.say("its capped army grows up: %d matured, %d Raptors offered up so far" % [int(ai.wbm["matured"]), int(ai.wbm.get("offered", 0))])
	return true


## THE CAPPED ARMY WAITS TO GROW UP (part of `wbmquality`): at the cap, while young creatures at home are still to mature
## (or moulting) and the food is there, the banked wave waits for them, QUALITY_WAIT s at most from the first wait.
const QUALITY_WAIT := 45.0


static func quality_hold(ai, q, army: Array) -> bool:
	if not on("quality"):
		return false
	var w: Dictionary = ai.wbm
	var moulting := army.filter(func(u) -> bool: return u.moult_t >= 0.0).size()
	var young := 0
	if ai._food() >= QUALITY_FOOD:
		for u in army:
			var mk := BroodMature.mature_of(u.kind)
			if (u.kind == "raptor" or u.kind == "spitter") and BroodNew.stage(q) >= BroodNew.unit_stage(mk) and u.moult_t < 0.0:
				young += 1
	var grown := army.filter(func(u) -> bool: return u.kind in ["tyrant_challenger", "venom_challenger"]).size()
	if moulting == 0 and (young <= grown or ai._food() < QUALITY_FOOD):
		w.erase("q_wait")
		return false
	if not w.has("q_wait"):
		w["q_wait"] = ai.game.clock
	if ai.game.clock - float(w["q_wait"]) > QUALITY_WAIT:
		if ai.game.clock - float(w["q_wait"]) > QUALITY_WAIT * 3.0:
			w.erase("q_wait")          # (a fresh wait after a while)
		return false
	return true


# ------------------------------------------------------------------ THE REGROUP (`wbmregroup`)
## THE REGROUP (blocks 1-4: at the cap with food banked, a wave that pulled back with half was sent out again 3 to 30 s
## later (the BANKED rule), its survivors still walking home and the fresh eggs not hatched, into the same defence: Hollowfen
## block 1, P2 pulled back at 15:56 with 845 of 4,395 and attacked again at 15:59 with 111 supply). After a wave comes home
## it waits REGROUP s before the next one, unless it is REGROUP_SUP supply bigger than that wave was (a new army).
const REGROUP := 45.0


static func regroup_hold(ai, sup: int) -> bool:
	if not on("regroup"):
		return false
	var t := float(ai.wbm.get("wave_end_t", -999.0))
	if ai.game.clock - t > REGROUP:
		return false
	return sup < int(ai._wave_sup * 1.4)


# ------------------------------------------------------------------ FEWER GRUBS AT THE CAP (`wbmgrubs`)
## FEWER GRUBS AT THE CAP (blocks 1-4: at 200 supply with 4,000-7,000 food banked from 14:00, 57-62 grubs held 60 supply
## while the army fought at 120: food it could not spend, an army it could not grow). At the cap with GRUBS_BANK food or
## more, it lays no grub over GRUBS_KEEP and offers up a grub over GRUBS_KEEP at the Mother every GRUBS_EVERY s (a grub's
## spoils back): the room goes to warriors. Under GRUBS_LOW food it grows them back as before.
const GRUBS_BANK := 3000
const GRUBS_LOW := 1200
const GRUBS_KEEP := 44
const GRUBS_EVERY := 3.0


static func grubs_cap(ai) -> int:
	if not on("grubs") or not mirror(ai):
		return 999
	return GRUBS_KEEP if bool(ai.wbm.get("grubs_cut", false)) else 999


static func grubs_tick(ai) -> void:
	var g = ai.game
	var t: int = ai.team
	var w: Dictionary = ai.wbm
	var capped: bool = g.supply_used(t) >= mini(int(g.players[t]["cap"]), g.max_supply(t)) - 6
	if capped and ai._food() >= GRUBS_BANK:
		if not bool(w.get("grubs_cut", false)):
			ai.say("at the cap with %d food: fewer grubs (%d), more warriors" % [ai._food(), GRUBS_KEEP])
		w["grubs_cut"] = true
	elif ai._food() < GRUBS_LOW:
		w["grubs_cut"] = false
	if not bool(w.get("grubs_cut", false)) or g.clock - float(w.get("grub_off_t", -99.0)) < GRUBS_EVERY:
		return
	var q = BroodNew.queen(g, t)
	if q == null:
		return
	var grubs: Array = ai._nb_mine("grub")
	if grubs.size() <= GRUBS_KEEP:
		return
	var home: Vector2 = ai._qp(q)
	var best: Unit = null
	for u in grubs:
		if u == ai._scout or u.order == "sacrifice" or u.order == "nb_morph" or u.carrying > 0 or not u.can_sacrifice():
			continue
		if best == null or u.position.distance_to(home) < best.position.distance_to(home):
			best = u
	if best != null:
		best.cmd_sacrifice()
		w["grub_off_t"] = g.clock
		w["grubs_off"] = int(w.get("grubs_off", 0)) + 1
