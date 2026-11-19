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
const EDGE := 1.15               # a wave goes with this much of the biggest Clockwork army it has seen lately
const SPOILS_FOR := 30.0         # spoils kept for the line's eggs and maturing


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
		if raptors >= cap and BroodNew.count_of(g, t, BroodNew.DILO) > 0:
			return ""
		return "-"
	var spit_due := raptors >= cap or spitters < raptors * SPIT_PER_RAPTOR
	if spit_due:
		if spoils >= float(sp[1]) and spend >= int(sp[0]):
			return "spitter"
		return ""          # (food kept for the Spitters' egg; the spoils come from harvests and offered-up Raptors)
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
