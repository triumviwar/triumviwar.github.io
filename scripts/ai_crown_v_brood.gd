class_name AICrownVBrood
extends RefCounted
## THE CROWN AGAINST THE BROOD, COACHED (crown-coach-v-brood, the owner 2026-11-15 00:28: "You need to do multiple coaching
## jobs on crown"; docs/crown-coach-v-brood.md). The Crown computer's whole game plan against the Brood computer, coached from
## filmed Hard OPTIMAL v OPTIMAL games. Everything here runs only when the Crown computer faces a Brood (AICrown.vb()); the
## Crown's code only calls in. Study switch: `-- cvb:off` plays the matchup as before this job (each part has its own too).
## Design rules (docs/design_principles.md): 2 (the defender's advantage needs defenders; a lost raid must not be a lost game)
## and 4 (every choice has an opportunity cost: a palisade with nobody behind it, a Church while the Brood masses).
##
## 1. THE LINE BEFORE THE BUILDINGS (coached: Highmoor 1103, 5:05-7:21). The Horseman rush failed at 5:24 and handed the plan
##    to Economy; from then to 7:21 the Barracks stood idle (busy 0/1 in every status line) with 0-20 gold in the bank while
##    the gold went, think after think, to the natural's palisade (30 pieces), a Foundry, a Church, two Farms, a Powder Mill
##    and Cottages: the first Musketeer came at 7:21, the Brood's wave at 7:47 met one Musketeer and a gun, and both halls
##    were gone by 10:00. The army the Crown weighed (690) was six Horsemen out raiding, so the Brood reckoning said "not
##    behind". Now, against the Brood, from LINE_FROM the HOME LINE (Musketeers and guns, not the riders) keeps up with a floor
##    by the clock (LINE_TABLE: the Brood's first big wave comes at 6:30-8:00 in the study games), bounded by the economy
##    (LINE_PER_LAB a labourer): while it is short, the soldiers' gold (line_keep: two Musketeers, a Field Cannon when a
##    Foundry may cast one) is kept from the natural's palisade, the Farms and the milestones (not from the labourers: see
##    keep_wide; not while the supply is full); the halls train a labourer only when every Barracks is busy; the milestones
##    are held as when the army lags; the Mill's crew grows for its powder (an idle Barracks for want of powder is no sign
##    that nothing wants it); no more riders. Switch: `-- cvbline:off`.

var ai = null
var game: Game = null
var team := 0
var off := false
var line_off := false
## (study switch `-- cvbkeep:wide`) the line's gold kept from everything the think stages 0 and 1 spend, the labourers and
## the opening's steps too, and the opening's army cap passed by: MEASURED AND NOT KEPT (16 games: the income at 10:00 fell
## from 0.81 to 0.63 of the Brood's, the labourers at 8:00 from 0.83 to 0.68, and the army was no bigger: 0.16 at 10:00)
var keep_wide := false

const LINE_FROM := 240.0
## [clock, home line value wanted]: 5 Musketeers by 5:00, 10 and two guns by 6:30 (the Brood's Timing wave came at 6:24-7:07
## with 23-34 supply in the coached games), then the Brood's waves keep growing
const LINE_TABLE := [[240.0, 0.0], [300.0, 300.0], [390.0, 900.0], [450.0, 1200.0], [600.0, 1900.0], [720.0, 2600.0]]
const LINE_PER_LAB := 45.0       # (gold of line a labourer at most: the economy is not starved for it)
const LINE_PER_LAB_MIN := 600.0  # (... but never under this)
var line_short_t := 0.0          # (the study) seconds the line was short
var _short_last := -1.0
var _short_cache := false
var _short_at := -1.0
var _said := -99.0
var keeps := 0                   # (tests) thinks the line's gold was kept


func _init(a) -> void:
	ai = a
	game = a.game
	team = a.team
	var args := OS.get_cmdline_user_args()
	off = args.has("cvb:off")
	line_off = off or args.has("cvbline:off")
	target_off = off or not args.has("cvbtarget:on")      # (MEASURED, NOT KEPT AS THE DEFAULT: parts 2 and 3 below)
	keep_wide = args.has("cvbkeep:wide")
	cba_off = args.has("cba:off")
	floor_off = cba_off or args.has("cbafloor:off")
	for arg in args:
		if arg.begins_with("cbafloor:k="):
			floor_k = float(arg.split("=")[1])
	counter_off = off or not args.has("cvbcounter:on")
	hold_off = cba_off or args.has("cbahold:off")
	econ_off = cba_off or args.has("cbaecon:off")
	if not cba_off and not args.has("cbacounter:off"):
		counter_off = off       # (crown-brood-army part 6: the counter after a held push is on with the hold)


static func is_line(u: Unit) -> bool:
	return Defs.MUSKETS.has(u.kind) or u.kind == "cannon" or u.kind == "mortar"


## The Musketeers and guns the Crown has (not the riders: they ride out raiding and scouting).
func home_line() -> float:
	var v := 0.0
	for u in game.army(team):
		if not u.dead and is_line(u):
			v += float(Game.unit_value(u))
	return v


func line_want() -> float:
	var t: float = game.clock
	var w: float = AICrown._lerp_table(LINE_TABLE, t)
	var cap := maxf(LINE_PER_LAB_MIN, LINE_PER_LAB * float(game.workers(team).size()))
	return maxf(minf(w, cap), floor_want())      # (crown-brood-army: the floor tied to the Brood, part 5)


## The home line is under its floor (looked at once a second).
func line_short() -> bool:
	if line_off or game.clock < LINE_FROM or ai.peaceful:
		return false
	if _short_at >= 0.0 and game.clock - _short_at < 1.0:
		return _short_cache
	_short_at = game.clock
	var have := home_line()
	var want := line_want()
	_short_cache = have < want
	if _short_cache:
		if _short_last >= 0.0 and game.clock - _short_last < 3.0:
			line_short_t += game.clock - _short_last
		_short_last = game.clock
		if game.clock - _said > 60.0:
			_said = game.clock
			ai.say("against the Brood the line comes before more buildings: %d of Musketeers and guns against the %d it wants by now" % [int(have), int(want)])
	return _short_cache


## The soldiers' gold kept from the wall, the Farms and the milestones while the line is short.
func line_keep() -> int:
	if not line_short():
		return 0
	if game.supply_used(team) >= int(game.players[team]["cap"]) - 2:
		return 0                 # (supply-blocked: the Cottage first, or no soldier can come)
	if not ai._mine("barracks").any(func(b: Building) -> bool: return b.built):
		return 0                 # (no Barracks yet: nothing to keep the gold for)
	var k := 2 * int(Defs.UNITS["musketeer"]["cost"])
	var guns := 0
	var musk := 0
	for u in game.army(team):
		if u.dead:
			continue
		if u.kind == "cannon":
			guns += 1
		elif Defs.MUSKETS.has(u.kind):
			musk += 1
	for f in ai._mine("foundry"):
		if f.built and f.queue.is_empty() and guns * 4 < musk + 4 and game.horses_at(f) > 0:
			k += int(Defs.UNITS["cannon"]["cost"])
			break
	keeps += 1
	return mini(k, int(game.players[team]["gold"]))


## 2. THE WAVE GOES FOR THE BROOD'S FAR GROUND, NOT THE MOTHER (coached: Hollowfen 1151 9:24, Highmoor 1103): a Brood has no
##    buildings, so the shared wave target (the enemy's nearest hall) fell back to its start, the Mother on her nest with
##    her fathers and the rooted turtles round her: the strongest spot on its side of the map. Its income is its Rootmaws,
##    rooted on fresh ground away from her, each a slow 450-hp lizard with a few grubs. Against the Brood the wave now
##    goes for the nearest Rootmaw it has seen rooted away from the Mother (MAW_FAR), the Mother only when there is none.
##    A study switch, `-- cvbtarget:on` (measured with part 3, see there).
const MAW_FAR := 14.0            # (tiles) a Rootmaw at least this far from the Mother is "far ground"
var target_off := false
var _tgt_t := -99.0
var _tgt := Vector2.INF
var targets := 0                 # (tests) waves sent at a far Rootmaw


func wave_target(me: Vector2) -> Vector2:
	if target_off:
		return Vector2.INF
	if game.clock - _tgt_t < 5.0:
		return _tgt
	_tgt_t = game.clock
	_tgt = Vector2.INF
	var foe: int = ai._foe()
	if foe < 0:
		return _tgt
	var mother: Unit = BroodNew.queen(game, foe)
	var mp: Vector2 = mother.position if mother != null else game.start_mid(foe)
	var bd := INF
	for u in ai._maws_seen.keys():
		if not is_instance_valid(u) or u.dead or not BroodNew.rooted(u):
			continue
		if u.position.distance_to(mp) < MAW_FAR * Defs.TILE:
			continue
		var d: float = u.position.distance_to(me)
		if d < bd:
			bd = d
			_tgt = u.position
	return _tgt


## 3. THE COUNTER AFTER A HELD WAVE (coached: Hollowfen 1151, 9:18-10:46; Highmoor 1103, 8:53-10:06; the "before" batch: at
##    10:00 the Crown's army was even with or ahead of the Brood's in 6 of 16 games, 2,120-2,195 against 1,495-3,020): the
##    Brood's wave broke on the palisade ("pulls its wave back: only 180 of 550 is left") and the Crown sat at home, "holds its
##    wave back: the enemy army it knows is bigger", its wave weighed against a reckoning of a Hard Brood by the clock
##    (AICrown.BROOD_TABLE, 3,800 at 10:00, 1.5 times that wanted) while the Brood rooted three more Rootmaws and came back
##    at the supply cap (96 supply at 10:46) and broke the line of 19 in nine seconds. A human goes out when the enemy's wave
##    has just died at his wall. So against the Brood, from COUNTER_FROM: when the Crown has killed at least COUNTER_KILL
##    of Brood in the last COUNTER_WINDOW s, or its army is COUNTER_EDGE times the Brood army seen in the last two minutes
##    (fresh scouting asked as before), and its own army is at least COUNTER_MIN, the wave goes at once, for the far ground
##    (part 2). MEASURED AND NOT KEPT AS THE DEFAULT (study switch `-- cvbcounter:on`; 16 games each, the same build but for
##    parts 2 and 3: with them W-D-L 0-4-12, the army at 10:00 and 12:00 0.36 and 0.34 of the Brood's; without, 0-5-11, 0.42
##    and 0.27: no gain within the noise): it went out
##    in 4 of 16 games, and in the films the wave took 90 s to walk to the far ground (it closed up and formed its line for a
##    150-strong guard on the way), killed 4 Rootmaws, while the Brood rebuilt from 300 to 4,030 of army in two minutes and
##    came for the halls the wave had left bare (Greenhold 1100: 44 labourers at 13:00, 8 at 14:00). What it lacks is in
##    docs/crown-coach-v-brood.md (a quick strike that does not stop to form for a token guard, a home guard left behind,
##    and the way home before the Brood's next wave).
const COUNTER_FROM := 360.0
const COUNTER_MIN := 1200.0
const COUNTER_WINDOW := 75.0
const COUNTER_KILL := 0.45       # (share of our ready army's value killed lately)
const COUNTER_EDGE := 1.4
var counter_off := false
var _kills: Array = []           # [clock, value_killed]
var counters := 0
var _counter_said := -99.0


func track() -> void:
	var k := float(game.stats[team]["value_killed"])
	if _kills.is_empty() or float(_kills[-1][1]) != k:
		_kills.append([game.clock, k])
	while _kills.size() > 2 and game.clock - float(_kills[0][0]) > COUNTER_WINDOW + 5.0:
		_kills.pop_front()


func killed_lately() -> float:
	if _kills.is_empty():
		return 0.0
	var old := float(_kills[-1][1])
	for e in _kills:
		if game.clock - float(e[0]) <= COUNTER_WINDOW:
			old = float(e[1])
			break
	return float(game.stats[team]["value_killed"]) - old


## The wave may go though the Brood reckoning is bigger: its wave just died, or the army seen lately is far smaller.
func counter_ok(mine: float) -> bool:
	if counter_off or game.clock < COUNTER_FROM or mine < COUNTER_MIN:
		return false
	var kl := killed_lately()
	var seen: float = ai.ch.foe_known()
	var why := ""
	if kl >= mine * COUNTER_KILL and seen * 1.0 < mine:
		why = "its wave just died at our line (%d killed in %d s)" % [int(kl), int(COUNTER_WINDOW)]
	elif seen > 0.0 and mine >= seen * COUNTER_EDGE:
		why = "our army is %.1f times the Brood army seen lately (%d)" % [mine / seen, int(seen)]
	if why == "":
		return false
	counters += 1
	if game.clock - _counter_said > 30.0:
		_counter_said = game.clock
		ai.say("against the Brood the wave goes out now (%d of army): %s" % [int(mine), why])
	return true


## 4. NO CHURCH BEFORE THE LINE (coached: Highmoor 1103 at 5:41, Hollowfen 1151 at 5:55, every rush game of the "before"
##    batch): during the Horseman rush's long build order the shared rule (AI._build_up: a Church after 3:40 on Hard while
##    the plan's own milestones are not yet in charge) put up a Church for 150 gold at 4:00-4:30 and its Missionaries after,
##    while the Barracks had no Musketeer. Against the Brood the Church waits until CHURCH_FROM and the line is not short
##    (the plans' own milestones put it up at 34-40 labourers on two halls). Switch: `-- cvbline:off`.
const CHURCH_FROM := 600.0
var church_held := 0


func church_waits() -> bool:
	if line_off:
		return false
	if game.clock < CHURCH_FROM or line_short():
		church_held += 1
		return true
	return false



## 5. THE ARMY FLOOR TIED TO THE BROOD (crown-brood-army, the owner 2026-11-16 23:25 "start all coaching jobs needed";
##    docs/crown_brood_army.md). The line's floor above (LINE_TABLE, capped LINE_PER_LAB a labourer) is the Crown's own
##    table: 300 at 5:00, 700 at 6:00, and the cap held it under 900 till 8:00 on 20 labourers. The Brood's Timing reaches the
##    Crown at 6:20-8:00 with 600-1,400 of army (crown-coach-measure-2; this job's baseline: Saltmarsh r1 6:20 1,400 against
##    480, Redrock r0 6:50 985 against 590). And the line was short every minute from 4:30 to 8:00 while the gold went to the
##    natural's palisade (27 pieces), a Foundry, a second Mill, Farms, a Cottage and the Cavalry Charge, with the Barracks
##    idle (Dune Sea r1, 5:30-7:00: two Barracks, busy 0, 25 gold in the bank): the line's keep holds only some of the ways
##    the gold goes. Now, from FLOOR_FROM to FLOOR_UNTIL:
##    - the floor follows the Brood: what its scouts saw of the Brood's army lately (FLOOR_SEEN of it) and, by the read, the
##      push to come FLOOR_LEAD s ahead (FLOOR_TABLE: ~500 by 6:00, ~1,000 by 7:30, whatever the read: the Crown reads
##      the Brood GREEDY at ~1:40 in nearly every game, its turtle on new ground being the usual opening, and the Timing
##      still came; FLOOR_BLIND of it before any read), bounded by the economy (FLOOR_PER_LAB a labourer);
##    - while the line (with what trains) is under it, every idle Barracks trains a Musketeer and an idle Foundry a Field
##      Cannon (one for FLOOR_GUN_PER Musketeers) BEFORE any think stage spends, and their price is held from everything else
##      (the walls, the steps, the milestones, the labourers) until they can: the gold of idle production only, so a busy
##      Barracks lets the economy go on;
##    - every Barracks and Foundry busy and still FLOOR_MORE short: one more Barracks (up to FLOOR_BARRACKS);
##    - no Brood soldier seen for FLOOR_LOOK s between 4:00 and 6:30: a scout goes to look (AICrown.want_look);
##    - once a Brood push has broken on our line (part 6) the table counts FLOOR_HELD of itself: what is seen leads.
##    Switches `cbafloor:off` (this part), `cba:off` (the whole job), `cbafloor:k=<x>` (the table times x).
##    Design rule 2 (the defender's advantage needs defenders: a palisade with nobody behind it) and 4 (the opportunity cost:
##    an idle Barracks while the walls go up).
var cba_off := false
var floor_off := false
var floor_k := 1.0
const FLOOR_FROM := 240.0
const FLOOR_UNTIL := 570.0
const FLOOR_LEAD := 30.0
## [clock, home line wanted] after a NORMAL (or AGGRESSIVE) read: the Brood's Timing push
const FLOOR_TABLE := [[240.0, 0.0], [300.0, 250.0], [360.0, 500.0], [450.0, 1000.0], [540.0, 1300.0], [600.0, 1500.0]]
const FLOOR_BLIND := 0.6
const FLOOR_HELD := 0.5
const FLOOR_SEEN := 1.0
const FLOOR_PER_LAB := 55.0
const FLOOR_PER_LAB_MIN := 500.0
const FLOOR_GUN_PER := 4
const FLOOR_DEPTH := 2
const FLOOR_MORE := 200.0
const FLOOR_BARRACKS := 3
const FLOOR_BUSY := 10.0
const FLOOR_LOOK := 75.0
var floor_trained := 0           # (the report) Musketeers and guns the floor trained
var floor_held_t := 0.0          # (the report) seconds it held gold for idle production
var floor_built := 0             # (the report) Barracks the floor put up
var floor_looks := 0             # (the report) looks it asked for
var _floor_t := -1.0
var _floor_v := 0.0
var _busy_from := -1.0
var _floor_said := -99.0


func floor_on() -> bool:
	return not floor_off and not ai.peaceful and game.clock >= FLOOR_FROM and game.clock < FLOOR_UNTIL


func floor_want() -> float:
	if not floor_on():
		return 0.0
	if game.clock - _floor_t < 1.0:
		return _floor_v
	_floor_t = game.clock
	var t: float = game.clock
	var read := String(ai.scout.verdict) if ai.scout != null else ""
	var tab := AICrown._lerp_table(FLOOR_TABLE, t + FLOOR_LEAD) * floor_k
	if read == "pending" or read == "":
		tab *= FLOOR_BLIND       # (no read yet; a GREEDY read at 1:40 is the Brood's usual opening, its Timing still comes)
	if held_t >= 0.0 and not hold_off:
		tab *= FLOOR_HELD        # (its first push broken on our line: the table's guess gives way to what is seen, part 6)
	var seen: float = ai.ch.foe_known() if ai.ch != null else 0.0
	var w := maxf(tab, seen * FLOOR_SEEN)
	var cap := maxf(FLOOR_PER_LAB_MIN, FLOOR_PER_LAB * float(game.workers(team).size()))
	_floor_v = minf(w, cap)
	if t < 390.0 and ai.ch != null and t - float(ai.ch._last_army_t) > FLOOR_LOOK:
		var was: int = ai.looks_asked
		ai.want_look("the army floor (a look at the Brood's army)")
		if ai.looks_asked > was:
			floor_looks += 1
	return _floor_v


## The line with what trains (the queues of the Barracks and Foundries).
func line_with_queued() -> float:
	var v := home_line()
	for b in ai._mine("barracks") + ai._mine("foundry"):
		for k in b.queue:
			if Defs.MUSKETS.has(String(k)) or String(k) == "cannon" or String(k) == "mortar":
				v += float(Defs.UNITS[String(k)]["cost"]) if Defs.UNITS.has(String(k)) else 60.0
	return v


## Trains into idle production while the line (with its queues) is under the floor; returns the gold to hold for the rest.
func floor_produce() -> int:
	if not floor_on():
		return 0
	var want := floor_want()
	var have := line_with_queued()
	if have >= want:
		_busy_from = -1.0
		return 0
	if game.supply_used(team) >= int(game.players[team]["cap"]) - 2:
		return 0                 # (supply-blocked: the Cottage first)
	var hold := 0
	var musk := 0
	var guns := 0
	for u in game.army(team):
		if u.dead:
			continue
		if u.kind == "cannon":
			guns += 1
		elif Defs.MUSKETS.has(u.kind):
			musk += 1
	var all_busy := true
	for f in ai._mine("foundry"):
		if not f.built:
			continue
		if not (f.queue as Array).is_empty():
			continue
		if guns * FLOOR_GUN_PER >= musk + FLOOR_GUN_PER or game.horses_at(f) <= 0 or have >= want:
			continue
		all_busy = false
		var gp := int(game.unit_price(team, "cannon")[0])
		if int(game.players[team]["gold"]) >= gp and game.train(f, "cannon") == "":
			floor_trained += 1
			guns += 1
			have += float(gp)
			all_busy = true
		else:
			hold += gp
	var mp := int(game.unit_price(team, "musketeer")[0])
	for b in ai._mine("barracks"):
		if not b.built:
			continue
		if (b.queue as Array).is_empty():
			all_busy = false
		if ai._res2() < float(Defs.ammo_load("musketeer")) or not ai.am.musket_ok(b, "musketeer"):
			continue             # (no powder for his shots: no dry Musketeer for the floor; the Mill's crew grows for it)
		# two deep, as the halls' labourers (AICrownCoach.LAB_DEPTH): the gold comes in harvests ~20 s apart and a Musketeer
		# trains in 15 s, so with one in the queue the Barracks stood idle half the time (Greenhold 1100, 6:08-7:20)
		while (b.queue as Array).size() < FLOOR_DEPTH and have < want:
			if int(game.players[team]["gold"]) < mp:
				hold += mp       # (his gold first, from the next harvest)
				break
			var k: String = ai._soldier_key(b, "musketeer")
			if k == "" or game.train(b, k) != "":
				break            # (he cannot be trained here now for another reason)
			floor_trained += 1
			have += float(game.unit_price(team, k)[0])
	if hold > 0:
		floor_held_t += 0.1
	# every Barracks and Foundry busy and still far short: one more Barracks
	if all_busy and want - have >= FLOOR_MORE:
		if _busy_from < 0.0:
			_busy_from = game.clock
		elif game.clock - _busy_from >= FLOOR_BUSY and ai._mine("barracks").size() < FLOOR_BARRACKS \
				and not ai._busy_building("barracks") and game.requirement_met(team, "barracks"):
			var cost := int(Defs.BUILDINGS["barracks"]["cost"])
			if int(game.players[team]["gold"]) >= cost:
				var n0: int = ai._mine("barracks").size()
				ai._construct("barracks")
				if ai._mine("barracks").size() > n0:
					floor_built += 1
					_busy_from = -1.0
					ai.say("against the Brood the line needs more Barracks: %d of line against the %d the Brood's army asks for" % [int(have), int(want)])
			else:
				hold += cost
	else:
		_busy_from = -1.0
	if OS.get_cmdline_user_args().has("cbadebug"):
		var q := []
		for b in ai._mine("barracks"):
			q.append((b.queue as Array).duplicate())
		print("FLOOR %.1f want %d have %d gold %d hold %d busy %s q %s powder %d" % [game.clock, int(want), int(have), int(game.players[team]["gold"]), hold, str(all_busy), str(q), int(ai._res2())])
	if game.clock - _floor_said > 60.0 and hold > 0:
		_floor_said = game.clock
		ai.say("the army floor against the Brood: %d of line (with what trains) against the %d its scouting asks for: the soldiers' gold first" % [int(have), int(want)])
	return mini(hold, int(game.players[team]["gold"]))



## 6. HOLD THE FIRST PUSH, THEN COUNTER (crown-brood-army). With the floor the Crown had 1,000-1,300 of army at 7:00-8:00
##    and its wave went out at the first edge over the Brood army it reckoned (EDGE_BROOD 1.25 of the honest reckoning): Redrock
##    r0 7:55, 1,200 of army against 990 known, 16 Musketeers formed for a guard of 100, lost the field 480 for 100 with the
##    Brood's army coming on behind; the Brood came back at 10:10 with 2,360 against 720 and took both halls. A human holds
##    the first push at his wall and guns (the defender's advantage, design rule 2) and goes out when it has broken there.
##    So against the Brood, until HOLD_UNTIL: no wave goes before a push has been held (HELD_KILL of Brood killed within
##    AICrownVBrood.COUNTER_WINDOW s, or the alert of a push seen coming has ended with the army still standing), unless
##    the army is HOLD_EDGE times the Brood army it reckons; once one has been held, the counter (part 3 above, measured
##    without the floor and not kept then) goes as soon as the Brood's wave has died at our line. Switches `cbahold:off`,
##    `cbacounter:off`.
var hold_off := false
const HOLD_UNTIL := 600.0
const HOLD_EDGE := 2.0
const HELD_KILL := 450.0
var held_t := -1.0               # when a Brood push was first held
var hold_waits := 0              # (the report) thinks a wave waited for the first push
var _hold_said := -99.0


## (AICrown._wave_worth) true: the wave waits at home for the Brood's first push.
func hold_first(mine: float, est: float) -> bool:
	if hold_off or game.clock >= HOLD_UNTIL:
		return false
	if held_t < 0.0 and killed_lately() >= HELD_KILL:
		held_t = game.clock
		ai.say("against the Brood its push has broken on our line (%d killed in %d s): from now the counter may go" % [int(killed_lately()), int(COUNTER_WINDOW)])
	if held_t >= 0.0 or mine >= est * HOLD_EDGE:
		return false
	hold_waits += 1
	if game.clock - _hold_said > 60.0:
		_hold_said = game.clock
		ai.say("against the Brood the army holds at home for its first push: %d of army against the %d it reckons (out at %d before the push is held)" % [int(mine), int(est), int(est * HOLD_EDGE)])
	return true



## 7. THE ECONOMY AFTER THE HOLD (crown-brood-army). With the floor and the hold the Crown kept its halls (Redrock r0,
##    Saltmarsh r1, Border March r1: built halls lost 5 -> 0) but stood on 2 halls to 12:00 against the Brood's 4 and earned
##    0.7-0.9 of its income: still a trailing draw. The coach's economy rules (AICrownCoach 1 LABOURERS FIRST and 2 HALLS ON
##    TIME, `broodecon:on`) from the start leave it thin when the push comes (army at 5:00 60-180, Saltmarsh r1 lost). So
##    against the Brood they come on once the first push has been held (part 6), or from ECON_AFTER if none has come.
##    Switch `cbaecon:off`.
var econ_off := false
const ECON_AFTER := 540.0


func econ_after_hold() -> bool:
	if econ_off or ai.peaceful:
		return false
	return (held_t >= 0.0 and not hold_off) or game.clock >= ECON_AFTER
