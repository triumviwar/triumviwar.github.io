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
	counter_off = off or not args.has("cvbcounter:on")


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
	return minf(w, cap)


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
