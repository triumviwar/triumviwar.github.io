extends RefCounted
## THE CLOCKWORK COMPUTER AGAINST THE BROOD, COACHED AGAIN (clockwork-v-brood-coach-2, docs/clockwork_v_brood_coach_2.md).
## The owner (2026-11-15 22:20, 2026-11-16 07:07): the Brood computer beat the Clockwork computer 26-6-6 on 0.38.14
## (docs/winrate_2026_11_15.md, K1). Filmed and traced (tools/cw_trace.gd), the Clockwork's mistakes against the Brood were:
##  1. THE READ: the Brood's first Mound Turtle on new ground is its usual opening (every Brood plan roots one at 0:00), not
##     greed; the Clock Soldier rush it picked in 38 of 38 games cut the Winders' goal to 11-12, laid a second Light Works
##     and left 400-570 cogs unspent at 3:00, then met the Brood's Raptors and was dropped for Balanced at ~3:20.
##  2. THE RUSH REACTION STARVED THE WINDERS: its soldiers (up to 8, replaced as they died) came before any Winder for as
##     long as the written build ran: 9 Winders from 4:15 to 7:00 in one film, the Brood 34 at 6:00.
##  3. THE SERPENT BEFORE THE PENDULUMS: the Heavy Works' first unit was a Brass Serpent (30 of 38 games, ~50 s after the
##     yard) and its gears kept the yard's queue busy; the Pendulums (510 Raptors killed for 9 lost in those games, the
##     best answer it has) came late or never.
##  4. TWO CLOCKTOWERS ALL GAME: its Winders are kept to two halls' posts (26) and it wants a third hall only for every 13
##     Winders, so the third came at 8:00-10:00 or never while the Brood rooted ground after ground.
## Every rule here acts only for a Clockwork computer whose enemy is the Brood; each has its switch, and `-- cvb2:off`
## turns them all off (the computer plays as on main).

static var _args := OS.get_cmdline_user_args()


static func off(key: String) -> bool:
	return _args.has("cvb2:off") or _args.has(key + ":off")


## The study switch `-- cvbgreedy:<plan>`: the Clockwork's pick on a greedy read of the Brood, to measure the openings.
static func greedy_try() -> String:
	for a in _args:
		if a.begins_with("cvbgreedy:"):
			return a.substr(10)
	return ""


## The Clockwork computer `ai` against the Brood?
static func vs_brood(ai) -> bool:
	if ai == null or ai.game == null or ai.game.faction_of(ai.team) != "clockwork":
		return false
	var f: int = ai._foe()
	return f >= 0 and ai.game.faction_of(f) == "brood"


# ------------------------------------------------------------------ 1. the read (cvbread)

## A Brood more greedy than its usual opening: TRUE_HALLS grounds seen (the Mother's and two more), or TRUE_MAWS Rootmaws.
## (As the Crown's own check, AIOptimal._true_greed_brood.)
const TRUE_HALLS := 3
const TRUE_MAWS := 5


## The Clockwork's answer to a GREEDY read of the Brood ([] = the rule on main): [plan, why].
static func greedy_pick(opt, early: bool) -> Array:
	var tr := greedy_try()
	if tr != "":
		return [tr, opt._normal_why(tr)]
	if off("cvbread"):
		return []
	var halls := 0
	var econ := 0
	if opt.ai.scout != null:
		var r: Dictionary = opt.ai.scout._evaluate()
		halls = int(r.get("halls", 0))
		econ = int(r.get("econ", 0))
	var truly := halls >= TRUE_HALLS or econ >= TRUE_MAWS
	opt.say("the Brood's greed checked: %d grounds, %d Rootmaws seen: %s" % [halls, econ, "more than its usual opening" if truly else "its usual opening"])
	if truly and early:
		return ["cs_rush", "punish the greed before its army is up"]
	# (its usual opening: the economy opening goes on, its Light Works and first soldiers on time, ready for the Raptors)
	return ["balanced", "its first ground is its usual opening: the economy goes on, a Light Works ready for its Raptors"]


# ------------------------------------------------------------------ 2. the rush reaction (cvbwind, cvbrushend)

const RUSH_CALM := 40.0          # (s) no enemy at its buildings this long after the rush came: the rush is over


## Before the rush reaction's soldiers: one Clocktower keeps its Winders coming (one in its queue) while the Winders are
## short of the build's goal. The other Clocktowers' cogs go to the soldiers first, as before.
static func rush_winders(ai) -> void:
	if off("cvbwind") or not vs_brood(ai):
		return
	var w := String(ai._f()["worker"])
	var have: int = ai.game.workers(ai.team).size()
	var queued := 0
	for h in ai._halls():
		queued += (h.queue as Array).count(w)
	if have + queued >= int(ai.worker_goal) or queued > 0:
		return
	var price := int(Defs.UNITS[w]["cost"])
	if ai._gold() < price:
		ai._hold += price
		return
	for h in ai._halls():
		if h.built and (h.queue as Array).is_empty() and ai.game.train(h, w) == "":
			return


## The rush is over: it came RUSH_CALM s ago or more and no enemy has stood at its buildings for RUSH_CALM s: the reaction's
## soldiers are no longer replaced ahead of the build (the army's own rules make soldiers from here).
static func rush_over(bte) -> bool:
	if off("cvbrushend") or not vs_brood(bte.ai):
		return false
	var ai = bte.ai
	var now: float = ai.game.clock
	if ai._threat() != Vector2.INF:
		bte.set_meta("cvb_calm_from", now)
		return false
	var since: float = float(bte.get_meta("cvb_calm_from", bte.rush_at))
	if now - since < RUSH_CALM:
		return false
	if not bte.has_meta("cvb_over_said"):
		bte.set_meta("cvb_over_said", true)
		ai.note("the rush is over (no enemy at its buildings for %d s): its soldiers no longer come before the economy" % int(RUSH_CALM))
	return true


# ------------------------------------------------------------------ 3. the Pendulums before the Serpent (cvbserp)

## The Brass Serpent waits while the Pendulums against the swarm are short (AISwarm.pend_want, at least 2 against the Brood).
static func serpent_waits(ai) -> bool:
	if off("cvbserp") or not vs_brood(ai):
		return false
	var pends := 0
	for u in ai.game.army(ai.team):
		if u.kind == Defs.PENDULUM and not u.dead:
			pends += 1
	for w in ai._mine(Defs.CW_HEAVY):
		pends += (w.queue as Array).count(Defs.PENDULUM)
	var want: int = 2
	if ai._sw():
		want = maxi(want, int(ai.swm().pend_want()))
	return pends < want


# ------------------------------------------------------------------ 4. the third Clocktower (cvbhall)

const HALL3_AT := 360.0          # (s) from here a third Clocktower is wanted against the Brood
const HALL3_WINDERS := 20        # ... once it has this many Winders


## How many fresh halls the Clockwork wants against the Brood (`need` = the rule on main's): a third from HALL3_AT once
## two stand and its Winders are near two halls' posts, so the Winders have posts to go to.
static func halls_need(ai, need: int) -> int:
	if off("cvbhall") or not vs_brood(ai):
		return need
	if ai.game.clock < HALL3_AT or ai.game.workers(ai.team).size() < HALL3_WINDERS:
		return need
	var built: int = ai._halls().filter(func(h) -> bool: return h.built).size()
	if built < 2:
		return need
	return maxi(need, 3)


# ------------------------------------------------------------------ 5. the Pendulums (cvbpend)
## Measured in the 38 games of 0.38.14: the Clockwork's Pendulums killed 510 Raptors for 9 lost; its Clock Soldiers 902
## for 823, its Springers 673 for 219. Yet a game had 0-2 of them: the shared rule wants one Pendulum for every 6 others
## (4 at most) and two against the Brood, and its Springers and Netters spent the Tension first (a Pendulum takes 75; the
## pool stood at 8-60 from 7:00 in the films while the Heavy Works waited).
const PEND_PER := 5              # against the Brood: a Pendulum for every PEND_PER Clock Soldiers and Springers ...
const PEND_MAX := 8              # ... up to this many
const PEND_MIN := 2


## The Pendulums wanted against the Brood (0 when off: the shared rule's own number stands).
static func pend_target(ai, others: int) -> int:
	if off("cvbpend") or not vs_brood(ai):
		return 0
	return clampi(PEND_MIN + others / PEND_PER, PEND_MIN, PEND_MAX)


## More Pendulums wanted (the shared rule's swarm branch then makes them first at the Heavy Works).
static func pend_more(ai, pends: int, others: int) -> bool:
	return pends < pend_target(ai, others)


## The Tension the Light Works keep for the next Pendulum: once a Heavy Works is laid and Pendulums are short, one
## Pendulum's price (75) stays in the pool (the Springers and Netters take only what is above it).
static func pend_keep(ai, pends: int, cap: int) -> float:
	if off("cvbtension") or not vs_brood(ai) or pends >= cap:
		return 0.0
	if ai._mine(Defs.CW_HEAVY).is_empty():
		return 0.0
	return float(Defs.tension_cost(Defs.UNITS[Defs.PENDULUM]))
