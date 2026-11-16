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
## 4. NO BLIND HORSEMAN RUSH AGAINST THE BROOD (C2: the rush rode in 35 of 38 games and failed in 25; the Brood sees the
##    Horse Breeder at ~1:30). OPTIMAL no longer leans to the rush before it scouts the Brood, and a GREEDY Brood read picks
##    Balanced (measured: AIOptimal._punish). Riders still come for the screen, the picket and the raids of the plans.
##    Switch `norush:off` (the owner's rule before: the Horse Breeder to punish a greedy Brood).
## 5. THE SCREEN BEFORE THE WAVE (the owner 2026-11-15 22:20: "screening with Horsemen... it doesn't help if the enemy is
##    on top of you and the cannon is still unlimbering, that is why Horseman screening is so important"). Filmed, Kestrel
##    Rise 1130 v the Brood: the Horse Breeder stood from ~5:00 but no screen rider was trained before 9:27 (the screen's
##    own training wanted 180 gold to spare and the Musketeers took every harvest); the 9:06 wave "meets the enemy before
##    its line is formed: 27 muskets deploy under fire", and at 9:59 the Raptors were in the line with a gun still on its
##    horse. Now the screen's Horseman (AICrownScreen.wants_rider) is trained before the soldiers, its gold held as the
##    labourers' is; and a wave waits for its screen up to SCREEN_WAIT s while one is in training or can be (a Horse
##    Breeder stands). Switch `screenfirst:off`.
## 6. GUNS SET BEFORE CONTACT (the owner, the same message). The formed line stepped on with its guns limbered until the
##    nearest enemy known was GUN_SET (330 px) from its front rank; a Raptor comes 230 px in a gun's 2.5 s to unlimber.
##    Now the guns set up that much sooner against an enemy that can close fast or is coming on: GUN_SET plus its speed
##    times (the unlimbering + GUN_SLACK s), and once they stand, a line facing an enemy that comes on HOLDS by its guns
##    and lets it walk into their fire (it went on alone to musket reach before). Switch `gunsfirst:off`.

var ai          # the AICrown
var game: Game
var team := 0

var args := OS.get_cmdline_user_args()
var off := args.has("coach:off")
var labs_first_on := not off and not args.has("labsfirst:off")

var halls_on_time_on := not off and not args.has("hallsontime:off")
var honest_off := off or args.has("honest:off")
var screen_first_on := not off and not args.has("screenfirst:off")
var floor_off := args.has("armyfloor:off")
var screen_trained := 0
var guns_first_on := not off and not args.has("gunsfirst:off")
var guns_early_n := 0


static func no_rush_v_brood() -> bool:
	var a := OS.get_cmdline_user_args()
	return not a.has("coach:off") and not a.has("norush:off")

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
	if army_short():
		return false
	return free_posts() > 0


## THE ARMY FLOOR (crown-coach-measure 2026-11-16, docs/crown_coach_measure.md: v the Brood LABOURERS FIRST left the Crown
## naked: army at 5:00 a median 90 (off: 360), 0.41 of the Brood's at 8:00 (off: 0.83), the first Brood arrival (7:40, 550)
## killed 28 units and 5 buildings in 90 s; paired worse in 15 of 38, better in 3, p 0.008). Labourers first yields while the
## army is short of what the Crown's own army rules want by now: v the Brood the line (AICrownVBrood.line_short), every
## matchup the army clock (AICrownArmy.behind). Switch `armyfloor:off`.
func army_short() -> bool:
	if floor_off:
		return false
	if ai.vb() != null and ai.vbr.line_short():
		return true
	return ai.ca_behind()


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


# ------------------------------------------------------------------ 5. the screen before the wave

const SCREEN_WAIT := 45.0


## Trains the screen's Horseman now if it can; returns the gold to hold for it.
func screen_first() -> int:
	if not screen_first_on or not active() or _threat_now():
		return 0
	var sc = ai.screen()
	if sc == null or not sc.wants_rider():
		return 0
	var price := 0
	for b in ai._mine("barracks"):
		if not b.built or (b.queue as Array).size() >= 2:
			continue
		var hk: String = ai._soldier_key(b, "cuirassier")
		if hk == "":
			continue
		price = int(game.unit_price(team, hk)[0])
		if int(game.players[team]["gold"]) >= price and game.train(b, hk) == "":
			screen_trained += 1
			return 0
	return mini(price, int(game.players[team]["gold"]))


var _wave_wait_from := -1.0


## A wave about to go waits for its screen (true = wait).
func wave_waits_screen() -> bool:
	if not screen_first_on or not active():
		return false
	var sc = ai.screen()
	if sc == null or ai._mine("horse_breeder").filter(func(b: Building) -> bool: return b.built).is_empty():
		return false
	var have := 0
	for u in game.army(team):
		if not u.dead and u.kind == "cuirassier" and u.hp >= u.max_hp * 0.5:
			have += 1
	for b in ai._mine("barracks"):
		have += (b.queue as Array).count("cuirassier")
	if have >= 2:
		_wave_wait_from = -1.0
		return false
	if _wave_wait_from < 0.0:
		_wave_wait_from = game.clock
	if game.clock - _wave_wait_from > SCREEN_WAIT:
		return false
	return true


# ------------------------------------------------------------------ 6. guns set before contact

const GUN_SLACK := 1.5
const FAST := 75.0              # (px/s) an enemy this fast can close on a limbered gun
const COMING := 20.0            # (px/s) toward the line: it is coming on


func _closing(o: Unit, c: Vector2) -> float:
	var to_line: Vector2 = (c - o.position).normalized()
	return o.velocity.dot(to_line)


func gun_set(foes: Array, c: Vector2, face: Vector2, base: float) -> float:
	if not guns_first_on or not active():
		return base
	var extra := 0.0
	for o in foes:
		if not is_instance_valid(o) or o.dead:
			continue
		var sp := float(o.d.get("speed", 60.0))
		if sp >= FAST or _closing(o, c) >= COMING:
			extra = maxf(extra, sp * (Defs.CANNON_SWITCH + GUN_SLACK))
	if extra > 0.0:
		guns_early_n += 1
	return base + extra


func line_holds(foes: Array, c: Vector2, face: Vector2) -> bool:
	if not guns_first_on or not active():
		return false
	for o in foes:
		if is_instance_valid(o) and not o.dead and _closing(o, c) >= COMING and (o.position - c).length() < 900.0:
			return true
	return false


# ------------------------------------------------------------------ 7. (measuring) the second Farm before the Barracks

## THE SECOND FARM BEFORE THE BARRACKS (the owner DECIDED 2026-11-16 08:01, after "test both, then I decide" at 07:13): the
## OPTIMAL opening was his of 2026-11-06 (Cottage, Gate, Barracks, then the second Farm: 8 Farm posts until ~2:20); now the
## second Farm comes right after the Gate and the Barracks after it. Measured, 5 pairs of games (same map and seed): income at
## 5:00 up in all five (v Clockwork 0.56 -> 0.85, 0.61 -> 0.77, 0.63 -> 0.72 of the enemy's; v Brood 0.87 -> 0.99, 1.26 ->
## 1.38), the army at 5:00 about the same, no early collapse; v Clockwork better in 2 of 3 games, even in 1; v Brood even.
## A seen rush still puts the Barracks and soldiers first (_bo_defence). Switch `farmfirst:off` for the old order.
static func farm_first() -> bool:
	var a := OS.get_cmdline_user_args()
	return not a.has("coach:off") and not a.has("farmfirst:off")


static func farm_before_barracks(plan: Array) -> void:
	var bi := -1
	var fi := -1
	for i in plan.size():
		var st: Dictionary = plan[i]
		if String(st.get("do", "")) == "build" and String(st.get("k", "")) == "barracks" and bi < 0:
			bi = i
		if String(st.get("do", "")) == "build" and String(st.get("k", "")) == "farm" and fi < 0:
			fi = i
	if bi < 0 or fi < 0 or fi < bi:
		return
	var farm: Dictionary = plan[fi]
	plan.remove_at(fi)
	farm["at"] = {"labs": 7}
	plan.insert(bi, farm)
	(plan[bi + 1] as Dictionary)["at"] = {"labs": 8}
