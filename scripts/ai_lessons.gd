class_name AILessons
## THE LESSONS OF THE BATTLE TESTS IN THE MAIN COMPUTERS (job ai-lessons, docs/ai_lessons.md). The battle matrices
## (docs/battle_matrix.md, docs/battle_matrix_all.md) and the micro jobs (crown-micro, crown-micro-2, clockwork-micro,
## brood-micro) found what beats what and where the computers fight badly. This file holds the switches of the lessons
## put into the computers, one each:
##   dragoonwave  (a fix) a Dragoon of a wave getting off his horse to fire, or back on, stays in the wave's count: the
##                wave no longer ends and goes home when its Dragoons dismount (AI._army)
##   riderpull    (a fix) the screen's riders pull back from in front of the muskets whenever the wave's muskets are in a
##                fight, not only while the line's state says so (AICrownScreen._screen)
##   cbcomp / ckcomp / kccomp / kbcomp / bcomp: the army mixes by the counter tables (see each file's own notes)
## Switches: `-- ail:off` all off; `-- ail<name>:off` one off; `-- ail<name>:on` one on that is off by default.
const ON_BY_DEFAULT := ["dragoonwave", "riderpull", "cbcomp", "ckcomp", "kccomp"]

static var _args: PackedStringArray = OS.get_cmdline_user_args()


static func on(name: String) -> bool:
	if _args.has("ail:off") or _args.has("ail%s:off" % name):
		return false
	if _args.has("ail%s:on" % name):
		return true
	return ON_BY_DEFAULT.has(name)


## A Dragoon, mounted or on foot after getting off to fire (his own horse still close by), or getting on or off.
static func dragoon(u: Unit) -> bool:
	if u.kind == "dragoon":
		return true
	return u.kind == "musketeer" and u.auto_mount and u.steed != null and is_instance_valid(u.steed) and not u.steed.dead \
			and u.steed.position.distance_to(u.position) < Unit.STEED_FAR * Defs.TILE


# ------------------------------------------------------------------ the army mixes (lesson 4)
## The battle matrices (equal-value fights, no economy) said which army beats which. Each switch here is a matchup's mix
## for the computer that plays it; every plan keeps its own build and timings (the owner trains against each plan), only
## the share of each soldier in its army moves.
##   cbcomp  the Crown v the Brood: Musketeers and Horsemen about 70 / 30 (the best Crown army v the Brood), one Mortar at
##           most in the field (they trade badly: slow, set late), no spare-horse Dragoons in the field army (Dragoon
##           armies lose to everything; the Dragoon RAIDS plan keeps its riders)
##   ckcomp  the Crown v the Clockwork: plain lines of Musketeers with Officers (MO, the best Crown army there), no
##           Mortars, no spare-horse Dragoons; the Officers stay on foot
##   kccomp  the Clockwork v the Crown: Spring Ballistas in place of many Clock Soldiers (5 Ballistas for 10 Clock Soldiers
##           closed most of the gap, docs/clockwork_micro.md), more Pendulums (its real fighters), fewer Springers and
##           Netters, no Brass Serpent (they lose to nearly everything)
##   kbcomp  the Clockwork v the Brood: Pendulums and Ballistas (KB and P are its best mixes there), fewer Springers and
##           Netters, no Brass Serpent
##   bcomp / bkcomp  the Brood v the Crown / v the Clockwork: Venom Challengers are its strongest value there: a Spitter
##           for each Raptor (they grow into Venom Challengers)
## By matchup: the computer's enemy faction decides; a mirror is left as it is.

static func foe_f(ai) -> String:
	if ai == null or ai.game == null:
		return ""
	var f: int = ai._foe()
	return ai.game.faction_of(f) if f >= 0 else ""


static func mine_f(ai) -> String:
	return ai.game.faction_of(ai.team) if ai != null and ai.game != null else ""


## The mix switch that plays for computer `ai` now ("" none).
static func comp(ai) -> String:
	var me := mine_f(ai)
	var foe := foe_f(ai)
	var k := ""
	match [me, foe]:
		["crown", "brood"]:
			k = "cbcomp"
		["crown", "clockwork"]:
			k = "ckcomp"
		["clockwork", "crown"]:
			k = "kccomp"
		["clockwork", "brood"]:
			k = "kbcomp"
		["brood", "crown"]:
			k = "bcomp"
		["brood", "clockwork"]:
			k = "bkcomp"
	return k if k != "" and on(k) else ""


## The Crown: is a Horseman due (horse riders of `n` army units)? null: the old rule decides.
static func crown_horse(ai, horse: int, n: int) -> Variant:
	if comp(ai) != "cbcomp":
		return null
	return horse * 10 < n * 3 + 3      # (about 30 of every 100 of the army)


static func crown_horse_odds(ai, old: float) -> float:
	return 0.75 if comp(ai) == "cbcomp" else old


## The Crown's Mortars in the field: at most this many.
static func crown_mortars(ai, old: int) -> int:
	match comp(ai):
		"cbcomp":
			return mini(old, 1)
		"ckcomp":
			return 0
	return old


## The Crown v the Clockwork: an Officer due (Musketeers with Officers, 70 / 30 of the line)?
static func crown_officer(ai, officers: int, muskets: int) -> bool:
	return comp(ai) == "ckcomp" and muskets >= 3 and officers * 7 < muskets * 3


## No spare-horse Dragoons in the field army (the Dragoon raids plan keeps its own).
static func crown_no_dragoons(ai) -> bool:
	var c := comp(ai)
	return (c == "cbcomp" or c == "ckcomp") and ai.strategy != "dragoon"


## The Crown v the Clockwork: an Officer stays on foot (a line man, not a rider).
static func officer_walks(ai, u: Unit) -> bool:
	return u.kind == "dismounted" and comp(ai) == "ckcomp"


## The Clockwork: the Spring Ballistas wanted (`others` = Clock Soldiers and Springers).
static func cw_ballistas(ai, old: int, others: int) -> int:
	var c := comp(ai)
	if c == "kccomp":
		return maxi(old, mini(6, 1 + others / 3))      # (a Ballista for every 3 others, up to 6)
	if c == "kbcomp":
		return maxi(old, mini(4, 1 + others / 5))
	return old


## The Clockwork: its Pendulum cap (null: the old rule).
static func cw_pend_cap(ai, old: int, others: int) -> int:
	var c := comp(ai)
	if c == "kccomp" or c == "kbcomp":
		return maxi(old, mini(8, 2 + others / 3))
	return old


static func cw_comp(ai) -> bool:
	var c := comp(ai)
	return c == "kccomp" or c == "kbcomp"


## The Clockwork: a Springer due? (fewer: one for every 3 Clock Soldiers, was 2 for 3)
static func cw_springer(ai, springers: int, soldiers: int, old: bool) -> bool:
	if not cw_comp(ai):
		return old
	return springers * 3 < soldiers + 1


static func cw_netters(ai, old: int) -> int:
	return mini(old, 1) if cw_comp(ai) else old


static func cw_serpents(ai, old: int) -> int:
	return 0 if cw_comp(ai) else old


## The Brood: one Spitter for this many Raptors (Venom Challengers when grown).
static func brood_venom_share(ai, old: int) -> int:
	var c := comp(ai)
	return 1 if c == "bcomp" or c == "bkcomp" else old
