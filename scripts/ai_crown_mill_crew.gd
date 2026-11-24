class_name AICrownMillCrew
extends RefCounted
## THE MILLS' FULL CREW (crown-mill-crew, the owner 2026-11-20 20:41: "YES" to coaching the Crown computer to put a full crew
## of 6 labourers on each Powder Mill when its army's powder runs low; docs/crown_mill_crew.md). AI play only, no number.
##
## Why: the powder study (docs/crown_powder_study.md) found the Crown computer keeping 6 to 9 hands on 4 or 5 Mills while
## 4,300-6,600 saltpetre lay unspent in its halls at 16:00 and its musket men stood with no shots. Two things kept the
## hands off: the Mill's crew follows the powder BANK only while a Barracks or Foundry trains (AICrown._mill_feedback), so
## the army's own refills (a dry Musketeer takes 10 from the bank at a Mill, Barracks or Town Hall) never asked for more
## hands; and the shared mover (AI._balance_mill) only ever fills the FIRST Mill, so the second to fifth Mills stood with 0-1.
##
## The rule: once the opening is over (5:00), when the powder is LOW (the bank under half of what the army needs: the
## Barracks' and Foundry's want plus the shots the army's firearms are missing, and the army really missing some: 30
## powder of shots, or 2 musket men dry, or a Barracks waiting for powder), every Mill on a hall with saltpetre left is
## filled toward a full crew of 6, nearest Mill first, at most MOVE_A_THINK hands a think, idle hands first, then from the
## Farm with the most hands (never one carrying a harvest, never into danger). The Farms are not starved: the Mills take
## at most SHARE of the labourers (SHARE_DRY while 6 or more musket men are dry). Not while a rush is defended. Released
## when the bank holds what the army needs; then the extra hands go back one every STEP_BACK seconds (no swing back and
## forth). `-- millcrew:off` plays as before; `-- millcrew:on` forces it on where it is off by default (MATCHUPS).

## Where it is on by default (the enemy's faction; the mirror is "crown"), set from the measure (docs/crown_mill_crew.md):
## against the Clockwork it helped (40 games, both versions: won or led 34 v 14 of 20, won outright 13 v 3 of 20); against
## the Brood it changed nothing and in the mirror the two Crowns ended further apart (a snowball), so there it is off.
const MATCHUPS := ["clockwork"]
const START := 300.0             # (s) after the opening
const FULL := 6                  # a Mill's full crew (Defs powder_mill crew)
const SHARE := 0.35              # the most of the labourers on the Mills ...
const SHARE_DRY := 0.5           # ... while many musket men are dry
const DRY_MANY := 6
const MOVE_A_THINK := 3
const MISSING := 30.0            # powder of shots missing in the army that counts as "the army wants powder"
const DRY_FEW := 2
const NEED_CAP := 120.0          # the army's missing shots count up to this much powder (men far out in the field
                                 # cannot refill: counted whole, the first version kept the Mills full while 150-430 lay banked)
const HOLD := 20.0               # (s) on for at least this long
const STEP_BACK := 2.0           # (s) one hand back to the Farms at most this often after release
## `-- millcrew:v1`: the first version measured (no cap on the missing shots, on for 30 s at least, a hand back every 6 s)
var v1 := OS.get_cmdline_user_args().has("millcrew:v1")

var ai                           # the AICrown
var game
var off := OS.get_cmdline_user_args().has("millcrew:off")
var forced := OS.get_cmdline_user_args().has("millcrew:on")
var active := false
var _on_t := -999.0
var _floor := 0                  # the Mills' crew the rule holds (while on: its target; after: decaying)
var _step_t := -999.0
var _need := 0.0                 # (the last think's) the powder the army needs
var _dry := 0
# the report (result.json crown_ai "millcrew")
var on_s := 0.0                  # seconds on
var moved := 0                   # hands sent to a Mill
var times := 0                   # times switched on
var _last_t := -1.0


func _init(a) -> void:
	ai = a
	game = a.game


## On for this match: the switch, Normal and up, the coached computer, the enemy's faction in MATCHUPS.
func enabled() -> bool:
	if off or not ai.on or ai.difficulty < 1:
		return false
	if forced:
		return true
	var f: int = ai._foe()
	if f >= 0 and game.faction_of(f) == "brood" and preload("res://scripts/ai_crown_brood_late.gd").mills_on(ai):
		return true             # (crown-brood-late "cap": against the Brood from 10:00, the powder of the late army)
	return f >= 0 and MATCHUPS.has(game.faction_of(f))


func _live_mills() -> Array:
	return ai._mine("powder_mill").filter(func(m: Building) -> bool: return m.built and not m.dead and m.lode_left() > 0.0)


func _crew() -> int:
	var n := 0
	for m in ai._mine("powder_mill"):
		if m.built:
			n += m.crew.size()
	return n


## The powder the army's firearms miss (at what a shot costs) and its musket men with no shot.
func _missing() -> void:
	var miss := 0.0
	var dry := 0
	var costs: Dictionary = Defs.POWDER["cost"]
	for u in game.units:
		if u.team != ai.team or u.dead or u._pmax <= 0.0 or u.ammo_weapon() == "":
			continue
		var c := 1.0
		for k in costs:
			if String(u.kind).begins_with(String(k)):
				c = float(costs[k])
				break
		miss += maxf(0.0, u._pmax - u.powder) * c
		if (String(u.kind).begins_with("musketeer") or String(u.kind).begins_with("dragoon")) and u.powder < 1.0:
			dry += 1
	_need = miss
	_dry = dry


## Called each think (stage 0, before the hands move): decides on or off and the crew to hold.
func tick() -> void:
	var now: float = game.clock
	if _last_t >= 0.0 and active:
		on_s += minf(now - _last_t, 5.0)
	_last_t = now
	if not enabled() or now < START:
		active = false
		_floor = 0
		return
	var mills := _live_mills()
	var crew := _crew()
	_missing()
	var want: float = ai.POWDER_WANT + 15.0 * (ai._mine("barracks").size() + ai._mine("foundry").size())
	var need: float = want + (_need if v1 else minf(_need, NEED_CAP))
	var bank: float = ai._res2()
	var asks: bool = _need >= MISSING or _dry >= DRY_FEW or ai.ca_powder_wait()
	var blocked: bool = mills.is_empty() or (ai.scout != null and ai.scout.verdict == "rush" and now < 420.0) or ai._defending()
	if active:
		if blocked or (bank >= need and now - _on_t >= (30.0 if v1 else HOLD)):
			active = false
			_floor = crew
			_step_t = now
			AICrownRules.fire(ai, "millcrew_off")
	elif not blocked and asks and bank < need * 0.5:
		active = true
		_on_t = now
		times += 1
		AICrownRules.fire(ai, "millcrew_on")
	if active:
		var labs: int = game.workers(ai.team).size()
		var share := SHARE_DRY if _dry >= DRY_MANY else SHARE
		_floor = mini(FULL * mills.size(), maxi(crew, int(labs * share)))
	elif _floor > 0 and now - _step_t >= (6.0 if v1 else STEP_BACK):
		_step_t = now
		_floor = mini(_floor, crew) - 1
		if _floor <= 0:
			_floor = 0


## The Mills' crew the rule holds now (0: none; AICrown._mill_cap takes the larger of this and its own).
func floor_crew() -> int:
	return _floor


## Fills the live Mills toward their full crew (AICrown._balance_mill, while on). True when it moved the hands this think.
func fill(labs: Array) -> bool:
	if not active:
		return false
	var mills := _live_mills()
	var crew := _crew()
	var short := _floor - crew
	if short <= 0 or mills.is_empty():
		return true
	# who goes: idle hands first, then hands of the Farm with the most hands (never one carrying)
	var cand: Array = []
	var farm_n := {}
	for u in labs:
		if u.dead or u.carrying > 0 or not u.can_gather():
			continue
		if ai.scout != null and ai.scout.is_scout(u):
			continue
		if ai._fled.has(u) or ai._escort.has(u):
			continue
		var site = u.home_mine
		if u.order == "idle":
			cand.append([0, u])
		elif u.order == "gather" and site is Building and (site as Building).kind == "farm":
			farm_n[site] = int(farm_n.get(site, 0)) + 1
			cand.append([1, u])
	cand.sort_custom(func(a: Array, b: Array) -> bool:
		if a[0] != b[0]:
			return a[0] < b[0]
		if a[0] == 1:
			var fa: int = farm_n.get(a[1].home_mine, 0)
			var fb: int = farm_n.get(b[1].home_mine, 0)
			if fa != fb:
				return fa > fb
		return false)
	var room := {}
	for m in mills:
		room[m] = m.crew_max() - m.crew.size()
	var sent := 0
	for e in cand:
		if sent >= mini(short, MOVE_A_THINK):
			break
		var u: Unit = e[1]
		var best: Building = null
		var bd := INF
		for m in mills:
			if int(room[m]) <= 0:
				continue
			var d: float = m.center().distance_to(u.position)
			if d < bd and not ai._unsafe(m.center(), u.position):
				bd = d
				best = m
		if best == null:
			continue
		var was = u.home_mine
		u.cmd_gather(best)
		room[best] = int(room[best]) - 1
		if e[0] == 1:
			farm_n[was] = int(farm_n.get(was, 0)) - 1
		sent += 1
	moved += sent
	return true


## result.json crown_ai "millcrew" (tools/qa_match.gd)
func report() -> Dictionary:
	return {"on_s": int(on_s), "moved": moved, "times": times, "enabled": enabled()}
