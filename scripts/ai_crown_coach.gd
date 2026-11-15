extends RefCounted
class_name AICrownCoach
## THE CROWN COACH, 2026-11-16 (the owner 2026-11-15 22:20: "Coach the Crown computer, do all that [the win-rate study's
## C1-C3] and focus on wall making and microing the army, screening with Horsemen, setting cannon before the engagement";
## docs/crown_coach_2026_11_16.md). Coached by Claude in the session, not a cloud job. Each rule has its own switch; all off
## with `-- coach:off`.
##
## 1. LABOURERS FIRST (the win-rate study's C1: "it never fills its own economy"; tools/crown_econ_trace.gd on Greenhold
##    1101 v the Clockwork: a hall idle 301 of the first 600 s while Farm posts stood free, 268 of them with under 50 gold:
##    a harvest went to the first attack's soldiers, the next hall's reserve and the buildings first). Now, before ANY
##    think stage spends, every built hall with a free Farm post (on live soil, less the labourers queued) trains a
##    labourer if the bank has 50, two deep, and that gold is held from the other stages until it is spent. Only an armed
##    enemy AT our buildings now (AI._threat with an armed unit), a rush being defended or supply at the cap stops it.
##    Every plan, every matchup, the opening too (a plan's own labourer count no longer holds a hall idle with Farm posts
##    free). Switch `labsfirst:off`.
## 2. HALLS ON TIME (C1's second half: the economy bench's Crown, halls at 0 / 4 / 8 / 12 minutes, earns 1.6x the computer;
##    the computer waited for one hall per 16 labourers, and its labourers waited for the Farm posts the halls give: on
##    Greenhold 1101 it stood on 2 halls at 10:00 to the Clockwork's 4). The fresh halls it wants (AI._hall_first's need)
##    are at least 2 from HALL2_T, 3 from HALL3_T, 4 from HALL4_T, unless an armed enemy is at our buildings or a rush is
##    being defended (the hall's gold is held as _hall_first holds it). In the opening: once the main's Farms are full
##    (one free post or none) from FULL_T on, the plan's next Town Hall step comes before the steps ahead of it (Greenhold
##    1101: the main full at 4:20 with the Horse Breeder step ahead of the hall: the second hall stood at 5:50). Not past a
##    plan's attack step (the rush and the timing keep their order). Switch `hallsontime:off`.
## 3. AN HONEST RECKONING (C3: against the Brood it reckoned 2-3x the army that was there and held back while ahead, 11 of
##    38 games; Ashford 1164: 2,935 against 1,120 and "holds its wave back"). AICrown.foe_estimate never went under
##    BROOD_TABLE (2,200 at 8:00, 3,800 at 10:00, 5,000 at 12:00: the coached games' Hard Brood), whatever its scouts saw.
##    Now the table is only a guess for what it has NOT seen: TABLE_FRESH of it while the Brood's army was seen within
##    FRESH_S s (what was seen counts in full, as before), TABLE_STALE of it when not; and the wave goes at EDGE_BROOD
##    times that (was 1.5). Switch `honest:off`.

var ai          # the AICrown
var game: Game
var team := 0

var args := OS.get_cmdline_user_args()
var off := args.has("coach:off")
var labs_first_on := not off and not args.has("labsfirst:off")

var halls_on_time_on := not off and not args.has("hallsontime:off")
var honest_off := off or args.has("honest:off")

var labs_first_n := 0          # (the report) labourers this rule trained
var labs_first_held_t := 0.0   # (the report) seconds it held gold for a labourer


func _init(a) -> void:
	ai = a
	game = a.game
	team = a.team


func active() -> bool:
	return not off and ai.on and ai.difficulty >= 1 and not ai.peaceful


# ------------------------------------------------------------------ 1. labourers first

const LAB_DEPTH := 2


## The free Farm posts on live soil less the labourers already queued.
func free_posts() -> int:
	var free := 0
	for f in ai._mine("farm"):
		if f.built and not f.barren():
			free += maxi(0, f.crew_max() - f.crew.size())
	return free - ai._labs_queued()


## An armed enemy at our buildings now (a scout or a worker is none).
func _armed_threat() -> bool:
	for b in game.buildings:
		if b.team != team or b.dead:
			continue
		for u in game.units_near(b.center(), 330.0):
			if game.hostile(u.team, team) and not u.dead and not u.off_field and not u.is_worker() and u.armed() \
					and ai._threat_seen(u, b):
				return true
	return false


var _threat_t := -9.0
var _threat_v := false


func _threat_now() -> bool:
	if game.clock - _threat_t >= 1.0:
		_threat_t = game.clock
		_threat_v = _armed_threat()
	return _threat_v


func labs_wanted() -> bool:
	if not labs_first_on or not active():
		return false
	if ai._defending() or _threat_now():
		return false
	if ai.dfn != null and ai.dfn.wants_soldiers():
		return false
	if game.supply_used(team) >= int(game.players[team]["cap"]) - 1:
		return false
	return free_posts() > 0


## Trains what it can now and returns the gold to hold for the rest (a labourer's price for each slot still open).
func labs_first() -> int:
	if not labs_wanted():
		return 0
	var worker: String = ai._f()["worker"]
	var cost := int(Defs.UNITS[worker]["cost"])
	var free := free_posts()
	var want := 0
	for h in ai._halls():
		if not h.built or free <= 0:
			continue
		while h.queue.size() < LAB_DEPTH and free > 0:
			if int(game.players[team]["gold"]) >= cost and game.supply_used(team) < int(game.players[team]["cap"]) - 1:
				if game.train(h, worker) == "":
					labs_first_n += 1
					free -= 1
					continue
			if h.queue.is_empty():
				want += 1           # (an idle hall: its labourer's gold is held)
			break
	if want > 0:
		labs_first_held_t += 0.1
	return mini(want * cost, int(game.players[team]["gold"]))


# ------------------------------------------------------------------ 2. halls on time

const HALL2_T := 210.0
const HALL3_T := 450.0
const HALL4_T := 690.0


func halls_need() -> int:
	if not halls_on_time_on or not active() or ai._defending() or _threat_now():
		return 0
	if ai.dfn != null and ai.dfn.wants_soldiers():
		return 0
	var t: float = game.clock
	return 4 if t >= HALL4_T else (3 if t >= HALL3_T else (2 if t >= HALL2_T else 1))


const FULL_T := 150.0


func bo_hall_now() -> bool:
	if not halls_on_time_on or not active() or _threat_now() or game.clock < FULL_T:
		return false
	if ai._halls().size() != 1 or free_posts() > 1 or ai._mine("farm").filter(func(f: Building) -> bool: return f.built).size() < 2:
		return false
	var plan: Array = ai._bo_plan
	var i: int = ai.bo_i
	if i >= plan.size() or String(plan[i]["do"]) == "hall":
		return false
	for k in range(i + 1, plan.size()):
		var d := String(plan[k]["do"])
		if d == "attack":
			return false
		if d == "hall":
			if ai._st_done(plan[k]):
				return false
			var st: Dictionary = plan[k]
			plan.remove_at(k)
			plan.insert(i, st)
			ai._step_t = -1.0
			ai._bo_log("the main's Farms are full: the next Town Hall first (the coach)")
			bo_hall_moved.append([int(game.clock), String(plan[i + 1]["do"]) if i + 1 < plan.size() else ""])
			return true
	return false


var bo_hall_moved: Array = []     # (the report) [clock, the step it went before]


# ------------------------------------------------------------------ 3. an honest reckoning

const TABLE_FRESH := 0.4
const TABLE_STALE := 0.75
const FRESH_S := 60.0
const EDGE_BROOD := 1.25


func honest_on() -> bool:
	return not honest_off and active()


func table_share() -> float:
	var seen_t: float = ai.ch._last_army_t if ai.ch != null else -1.0
	if seen_t >= 0.0 and game.clock - seen_t <= FRESH_S:
		return TABLE_FRESH
	return TABLE_STALE


func edge_brood() -> float:
	return EDGE_BROOD
