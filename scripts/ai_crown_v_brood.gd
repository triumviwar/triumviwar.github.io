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
##    (LINE_PER_LAB a labourer): while it is short, the soldiers' gold (LINE_KEEP: two Musketeers, a Field Cannon when a
##    Foundry may cast one) is kept from the wall, the Farms and the milestones; the halls train a labourer only when every
##    Barracks is busy; the milestones are held as when the army lags; no more riders. Switch: `-- cvbline:off`.

var ai = null
var game: Game = null
var team := 0
var off := false
var line_off := false

const LINE_FROM := 270.0
## [clock, home line value wanted]: 5 Musketeers by 5:30, 10 and two guns by 7:00, then the Brood's waves keep growing
const LINE_TABLE := [[270.0, 0.0], [330.0, 300.0], [420.0, 1000.0], [480.0, 1300.0], [600.0, 1900.0], [720.0, 2600.0]]
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
