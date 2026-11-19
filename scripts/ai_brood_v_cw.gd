extends RefCounted
class_name AIBroodVCw
## THE BROOD COMPUTER AGAINST THE CLOCKWORK (job brood-v-clockwork-army, docs/brood_v_clockwork_army.md). The owner
## (2026-11-19 07:26): "Why does it lose to clockwork this easily? Is it making enough spitters?" It was not:
##  1. THE MIX. Against the Clockwork it laid Raptors and almost nothing else (Balanced: 215 Raptors and 4.5 Spitters lost a
##     game by 12:00; 104 of those Raptors to Pendulums). The bench (tools/bench_brood_v_cw_army.gd) at equal cost against
##     the Clockwork's army from ~9:00 (Clock Soldiers with SHIELD WALL, Springers, Pendulums, Winders mending): Raptors
##     kill 0.2-0.4 of what they lose, Spitters 1.6-11, Venom Challengers and Brutes more; early (no Pendulums, no shields)
##     everything wins.
##  2. NO SPOILS FOR SPITTERS. A Spitter egg costs 5 spoils; against the Clockwork it kept none for them (only against a
##     wall), so the eggs it could lay were Raptors.
##  3. THE WAVES. It sent small early waves ("steady Raptor pressure": 14 supply from 5:00, going with 0.3 of the biggest
##     Clockwork army it had seen): a median wave left with 0.75 of the Clockwork's army and was pulled back with 57-70%
##     lost, into a base where Winders mend and the units come out at a few seconds' notice.
## The rules (every one only for a Brood computer whose enemy is the Clockwork; `-- bvc:off` turns them all off, each has
## its own switch):
##   bvcmix    the mix: Spitters lead once the Venom Sire stands (two for every Raptor; Raptors held at RAPTOR_CAP), Brutes
##             at her stage 3 (one for every 8 Spitters, up to BRUTE_MAX), Spitters matured into Venom Challengers
##   bvcspoils the spoils for that: Spitter eggs, maturing and Brutes (grubs harvest, spare Raptors offered up)
##   bvcsire   the Venom Sire early (VENOM_AT) and its line's research soon (Long Spit out-reaches the Springer)
##   bvcwave   the waves: no small early waves; a wave goes with EDGE times the biggest Clockwork army seen lately (or at
##             the supply cap), Raptors stay home when Pendulums have been seen (the waves are the shooters and the tanks)

static var _args := OS.get_cmdline_user_args()

const RAPTOR_CAP := 16           # Raptors kept once the Venom Sire stands (a home guard, the screen, the raids)
const RAPTOR_EARLY := 24         # ... before the Clockwork has shown a Pendulum or shields
const SPIT_PER_RAPTOR := 2       # Spitters laid for each Raptor beyond the cap
const BRUTE_MAX := 8
const BRUTE_EVERY := 8           # a Brute for every this many Spitters
const VENOM_AT := 210.0          # the Venom Sire's lure from this time (the Spitter timing's)
const FULL_CAP := 186            # (supply: only at the game's own cap must the army go; at a turtle cap it roots more turtles)
const EDGE := 1.15               # a wave goes with this much of the biggest Clockwork army it has seen lately
const SPOILS_FOR := 40.0         # spoils kept for the line's eggs and maturing
const BANK_MAX := 400            # food above this is never kept waiting for the Venom Sire: a Raptor is better than a bank


static func off(key: String) -> bool:
	return _args.has("bvc:off") or _args.has(key + ":off")


## The Brood computer `ai` against the Clockwork?
static func on(ai) -> bool:
	if ai == null or ai.game == null:
		return false
	var f: int = ai._foe()
	return f >= 0 and ai.game.faction_of(f) == "clockwork"


## Has it seen what makes Raptors die: a Pendulum, or SHIELD WALL? (a Pendulum sweeps light units for x1.5)
static func heavy_seen(ai) -> bool:
	return int(ai.seen_pend) > 0 or (ai.game.has_tech(ai._foe(), "shield_wall") and ai.game.clock >= 480.0)


# ------------------------------------------------------------------ the plan (bvcwave, bvcsire)

## The plan against the Clockwork (from _make_plan; not the rushes, not the written builds' own timing).
static func plan(ai, p: Dictionary) -> void:
	if not off("bvcsire"):
		p["venom"] = minf(float(p["venom"]), VENOM_AT)
	if not off("bvcmix"):
		p["mix"] = "venom"
		p["mature"] = "push"
	if not off("bvcwave"):
		p["wave"] = maxi(int(p["wave"]), 24)
		p["wave_t"] = maxf(float(p["wave_t"]), 390.0)
		p["step"] = maxi(int(p["step"]), 10)
		p["edge"] = EDGE


# ------------------------------------------------------------------ the mix (bvcmix)

## Which warrior egg: "-" = no opinion (the usual mix), "" = save for the next, else the kind. Only once the Venom Sire
## stands beside her: before him the Raptors are its army and its defence.
static func warrior(ai, spend: int, spoils: float, trex: bool, dilo: bool, brutes_ok: bool) -> String:
	if off("bvcmix"):
		return "-"
	var g = ai.game
	var t: int = ai.team
	var raptors: int = BroodNew.count_of(g, t, "raptor") + BroodNew.count_of(g, t, "tyrant_challenger")
	var spitters: int = BroodNew.count_of(g, t, "spitter") + BroodNew.count_of(g, t, "venom_challenger")
	var brutes: int = BroodNew.count_of(g, t, "brute")
	var bp: Array = g.unit_price(t, "brute")
	var sp: Array = g.unit_price(t, "spitter")
	if brutes_ok and brutes < mini(BRUTE_MAX, 1 + spitters / BRUTE_EVERY):
		if spend >= int(bp[0]) and ai._spoils() >= float(bp[1]):
			return "brute"
	var cap := RAPTOR_CAP if heavy_seen(ai) else RAPTOR_EARLY
	if not dilo:
		# (the Venom Sire away or researching: Raptors as before up to the cap; past that the food waits for him (his
		# research is a minute at most), a Brute, maturing, her growth and the grubs. Dead: Raptors as before)
		if raptors >= cap and BroodNew.count_of(g, t, BroodNew.DILO) > 0 and spend < BANK_MAX:
			return ""
		return "-"
	var spit_due := raptors >= cap or spitters < raptors * SPIT_PER_RAPTOR
	if spit_due:
		# (the spoils kept for her stage 3 do not hold the Spitters back: 5 an egg, they are the army; the frostfang trace had
		# 30-55 spoils for minutes, all kept, and laid 72 Raptors to 4 Spitters)
		spoils = maxf(spoils, ai._spoils())
		if spoils >= float(sp[1]) and spend >= int(sp[0]):
			return "spitter"
		if spoils < float(sp[1]):
			return "-"          # (no spoils for the egg: a Raptor, and the spare Raptors at home are offered up for spoils)
		return ""          # (food kept for the Spitters' egg)
	return "-"


## Spoils wanted (bvcspoils): the line's eggs and maturing, and Brutes at her stage 3.
static func spoils_want(ai, q: Unit) -> float:
	if off("bvcspoils") or off("bvcmix"):
		return 0.0
	if BroodNew.count_of(ai.game, ai.team, BroodNew.DILO) == 0:
		return 0.0
	var w := SPOILS_FOR
	if BroodNew.stage(q) >= BroodNew.unit_stage("brute"):
		w += 20.0
	return w


# ------------------------------------------------------------------ the waves (bvcwave)

## THE RECKONING: the Clockwork's army is at home on its gears, out of sight; what the creatures saw of it lately
## (seen_army) is most often a part of it. So the reckoning is the most it has seen or what a Clockwork computer has by
## this minute (CW_TABLE: the lower quartile of the 72 plan-matrix games, docs/plan_matrix_brood), less what the Brood
## killed in the last KILLS_FOR s (a beaten push is a chance: the counter goes), never under a third of it.
const CW_TABLE := [[360.0, 650.0], [420.0, 1290.0], [480.0, 2075.0], [540.0, 2355.0], [600.0, 2800.0],
	[660.0, 3065.0], [720.0, 3725.0], [780.0, 4000.0]]
const KILLS_FOR := 90.0
const KILLS_BIG := 400.0


static func table_at(c: float) -> float:
	var v := 0.0
	for e in CW_TABLE:
		if c >= float(e[0]):
			v = float(e[1])
	return v


static func reckon(ai) -> float:
	var base := maxf(float(ai.seen_army), table_at(ai.game.clock))
	var k := 0.0
	var now := float(ai.game.stats[ai.team]["value_killed"])
	for e in ai.bvc_kills:
		if ai.game.clock - float(e[0]) <= KILLS_FOR:
			k = now - float(e[1])
			break
	if k < KILLS_BIG:
		k = 0.0          # (a few raiders or a scout killed at home are not a beaten push)
	return maxf(base - k, base / 3.0)


## (once a second, from _nb_observe) the kills' record for the reckoning
static func note_kills(ai) -> void:
	ai.bvc_kills.append([ai.game.clock, float(ai.game.stats[ai.team]["value_killed"])])
	while ai.bvc_kills.size() > 0 and ai.game.clock - float(ai.bvc_kills[0][0]) > KILLS_FOR + 5.0:
		ai.bvc_kills.pop_front()


## Does a wave of `mine_v` go?
static func wave_ok(ai, mine_v: float) -> bool:
	return mine_v >= EDGE * reckon(ai)


## The wave about to leave: the Raptors stay home once Pendulums or shields have been seen and the shooters are there
## (they are the home guard, the screen, and the Pendulums' food).
static func wave_filter(ai, wave: Array) -> Array:
	if off("bvcwave") or not heavy_seen(ai):
		return wave
	var shooters := wave.filter(func(u: Unit) -> bool: return u.kind in ["spitter", "venom_challenger", "brute"])
	if shooters.size() < 8:
		return wave
	return wave.filter(func(u: Unit) -> bool: return u.kind != "raptor")


# ------------------------------------------------------------------ the raids (bvcraid)

## THE RAPTOR RAID: once the waves are shooters and tanks (Pendulums or shields seen), the Raptors at home beyond a
## guard go after the Clockwork's WINDERS at a Cog Press or Clocktower away from its army (a Winder, 74, can't outrun a
## Raptor, 92): RAID_MIN of them at most every RAID_GAP s, never under an alarm, a threat at the Mother or with a wave out.
## They bite Winders first (cmd_attack on the nearest within RAID_PREY tiles), walk past buildings, and come home when
## armed enemies near them are worth more than RAID_OUTMATCH of the pack, when half the pack is gone or after RAID_TIME s.
const RAID_MIN := 8
const RAID_MAX := 16
const RAID_GUARD := 4
const RAID_GAP := 75.0
const RAID_TIME := 70.0
const RAID_PREY := 9.0
const RAID_OUTMATCH := 0.8
const RAID_CLEAR := 14.0         # tiles: the Clockwork's army last seen this near the raid's way or its goal: no raid


const RAID_GUARDED := 140.0      # armed enemies worth this much within RAID_GUARD_R tiles of a Winder: it is not chased
const RAID_GUARD_R := 6.0


## Armed enemies' value near p (seen).
static func guarded(ai, p: Vector2) -> float:
	var g = ai.game
	var v := 0.0
	for o in g.units_near(p, RAID_GUARD_R * Defs.TILE):
		if g.hostile(o.team, ai.team) and not o.dead and o.has_attack() and not o.is_worker() and g.is_visible_to(ai.team, o.position):
			v += float(Game.unit_value(o))
	return v


static func raid_has(ai, u: Unit) -> bool:
	return ai.bvc_raid.has("units") and (ai.bvc_raid["units"] as Array).has(u)


## From _nb_army: the raid going on, or a new one. Returns the units the raid holds (the army leaves them be).
static func raid_tick(ai, q: Unit, army: Array) -> void:
	if off("bvcraid"):
		return
	var g = ai.game
	var r: Dictionary = ai.bvc_raid
	if r.has("units"):
		var pack: Array = (r["units"] as Array).filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)
		r["units"] = pack
		if pack.is_empty():
			ai.say("its Raptor raid is gone (killed %d)" % int(float(g.stats[ai.team]["value_killed"]) - float(r["k0"])))
			ai.bvc_raid = {}
			return
		var mid := Vector2.ZERO
		for u in pack:
			mid += u.position
		mid /= pack.size()
		var armed := 0.0
		for o in g.units_near(mid, 9.0 * Defs.TILE):
			if g.hostile(o.team, ai.team) and not o.dead and o.has_attack() and not o.is_worker() and g.is_visible_to(ai.team, o.position):
				armed += float(Game.unit_value(o))
		var home: bool = r.get("home", false)
		if not home:
			var why := ""
			if armed > ai._value_of(pack) * RAID_OUTMATCH:
				why = "an army of %d near" % int(armed)
			elif pack.size() * 2 <= int(r["n0"]):
				why = "half the pack lost"
			elif g.clock - float(r["t0"]) > RAID_TIME:
				why = "out long enough"
			if why != "":
				r["home"] = true
				home = true
				ai.say("its Raptor raid comes home (%s; killed %d)" % [why, int(float(g.stats[ai.team]["value_killed"]) - float(r["k0"]))])
				for u in pack:
					u.cmd_move(ai._qp(q))
		if home:
			for u in pack.duplicate():
				if u.position.distance_to(ai._qp(q)) < 14.0 * Defs.TILE:
					pack.erase(u)
			r["units"] = pack
			if pack.is_empty():
				ai.bvc_raid = {}
			return
		# bite the Winders: each Raptor with no worker in its jaws goes for the nearest Winder in reach
		for u in pack:
			if u.target != null and is_instance_valid(u.target) and u.target is Unit and (u.target as Unit).is_worker() \
					and guarded(ai, (u.target as Unit).position) < RAID_GUARDED:
				continue
			var best: Unit = null
			var bd := RAID_PREY * Defs.TILE
			for o in g.units_near(u.position, RAID_PREY * Defs.TILE):
				if g.hostile(o.team, ai.team) and not o.dead and o.is_worker() and g.is_visible_to(ai.team, o.position):
					var d: float = o.position.distance_to(u.position)
					if d < bd and guarded(ai, o.position) < RAID_GUARDED:
						bd = d
						best = o
			if best != null:
				u.cmd_attack(best)
			elif u.order == "idle" or u.order == "attack" or (u.target != null and u.target is Building):
				u.cmd_move(r["goal"])          # (a plain walk: past the buildings, to the press)
		return
	# a new raid?
	if not heavy_seen(ai) or ai._attacking or ai._alarm_on() or ai._nb_threat(q) != Vector2.INF or float(ai._foe_near_home) > 100.0:
		return
	if g.clock - float(ai.bvc_raid_t) < RAID_GAP:
		return
	var home_r: Array = army.filter(func(u: Unit) -> bool: return u.kind == "raptor" and u.moult_t < 0.0 \
		and u.position.distance_to(ai._qp(q)) < 24.0 * Defs.TILE and (u.target == null or not is_instance_valid(u.target)))
	if home_r.size() < RAID_MIN + RAID_GUARD:
		return
	var goal := raid_goal(ai)
	if goal == Vector2.INF:
		return
	if ai.bvc_army_at != Vector2.INF:
		var cp := Geometry2D.get_closest_point_to_segment(ai.bvc_army_at, ai._qp(q), goal)
		if cp.distance_to(ai.bvc_army_at) < RAID_CLEAR * Defs.TILE:
			return          # (its army stands on the way, or by the press)
	var pack := home_r.slice(0, mini(RAID_MAX, home_r.size() - RAID_GUARD))
	ai.bvc_raid = {"units": pack, "t0": g.clock, "goal": goal, "n0": pack.size(), "k0": float(g.stats[ai.team]["value_killed"])}
	ai.bvc_raid_t = g.clock
	for u in pack:
		u.cmd_move(goal)
	ai.say("sends %d Raptors to raid the Winders at a %s (%d tiles out)" % [pack.size(), String(r.get("what", "Cog Press")),
		int(ai._qp(q).distance_to(goal) / Defs.TILE)])


## The raid's goal: the known Cog Press (or Clocktower) farthest from where the Clockwork's army was last seen (else from
## its start), not one seen with armed units by it.
static func raid_goal(ai) -> Vector2:
	var g = ai.game
	var foe: int = ai._foe()
	if foe < 0:
		return Vector2.INF
	var army_at: Vector2 = ai.bvc_army_at if ai.bvc_army_at != Vector2.INF else (Vector2(g.starts[foe]) + Vector2(2.5, 2.0)) * Defs.TILE
	var best := Vector2.INF
	var bd := -1.0
	for b in ai._foe_blds:
		if not is_instance_valid(b) or b.dead or not b.kind in ["cog_press", "clocktower"]:
			continue
		var p: Vector2 = ai._foe_blds[b]
		var d := p.distance_to(army_at) + (300.0 if b.kind == "cog_press" else 0.0)
		if d > bd:
			bd = d
			best = p
	return best
