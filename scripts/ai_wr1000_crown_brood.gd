class_name AIWr1000CrownBrood   # (used by preload: the class cache may not know it)
extends RefCounted
## WIN RATE 1000 OVER 10s, CROWN v BROOD (wr1000-crown-brood, the owner 2026-11-22 01:29: a fresh win-rate study "1000 over
## 10s", blocks of 10 games, one change of the computer's play a block; docs/wr1000_crown_brood.md). Every change here runs
## only when a Crown computer faces a Brood (the caller checks it), so the five sister jobs' changes merge beside these. Each
## change has its own switch: `-- wcb<name>:on` / `:off`; `-- wcb:off` plays the matchup as before this job. The changes KEPT
## are on by default (KEPT); the rest were measured and not kept (the doc says what each did).

const KEPT: Array[String] = []

static var _args: PackedStringArray = OS.get_cmdline_user_args()


## Is change `name` on?
static func on(name: String) -> bool:
	if _args.has("wcb:off") or _args.has("wcb%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("wcb%s:on" % name)


## A Crown computer (Normal and up) facing a Brood, with change `name` on.
static func vs_brood(ai, name: String) -> bool:
	return on(name) and ai.on and ai.difficulty >= 1 and ai._foe_is("brood")


# ------------------------------------------------------------------ change "arm": the Armoury and its research in time
## (block 1, the baseline: the Armoury milestone waited all game in 3 of 6 games with "the army comes first (1800 against
## the 2842 of Brood it estimates)" while the Crown's army was 3x the Brood's at 8:00 (the clock's table, BROOD_TABLE, not
## what it saw); the Crown met the Brood's capped army at 15:00-19:00 with no Matchlock, no Bayonet, no Armour.) From ARM_FROM,
## while the army is at least ARM_MIN and ARM_K times the Brood army it has SEEN lately (AICrownHold.foe_known), the Armoury
## is not held back by the army-first rules, and its research (Matchlock, Bayonet, Armour, Flintlock, Prepared Charges...) is
## not held back by "far behind the Brood" (AICrown._research). Nothing else changes: the research still waits for its men
## (AI.RESEARCH_AT) and its gold.
const ARM_FROM := 420.0
const ARM_MIN := 900.0
const ARM_K := 1.5
static var arm_freed := {}       # team -> times the Armoury or a research went because of this change (the counters)


static func armed_lead(ai) -> bool:
	if not vs_brood(ai, "arm") or ai.game.clock < ARM_FROM:
		return false
	var mine := float(ai.game.army_value(ai.team))
	return mine >= ARM_MIN and mine >= ARM_K * float(ai.ch.foe_known())


## AICrown._mid_ok_lagging asks: the Armoury goes now?
static func armoury_now(ai, k: String) -> bool:
	if k != "armoury" or not armed_lead(ai):
		return false
	arm_freed[ai.team] = int(arm_freed.get(ai.team, 0)) + 1
	return true


## AICrown._research asks: the research may go though the reckoning says the army is behind?
static func research_now(ai) -> bool:
	return armed_lead(ai)


# ------------------------------------------------------------------ change "cap": the push goes as a big army
## (block 1: the Siege push went out with 36-53 supply at 9:10-11:30 (AICrownSiege.BIG_GO 50 lets any push that big go),
## set up against Rootmaws and Mound Turtles on the rooted ground, lost 1,100-3,600 of army for 700-3,400 killed and came
## home; the Brood rebuilt to its cap by 13:00-14:00 and its waves broke the Crown at 15:00-19:00. The two games with no
## push survived.) Against the Brood the push goes only with CAP_SUP supply at home, or with the Crown's supply full.
const CAP_SUP := 110
static var cap_waits := {}      # team -> thinks the push waited for it


static func push_waits(ai, sup: int, siege) -> bool:
	if not vs_brood(ai, "cap"):
		return false
	if sup >= CAP_SUP or ai.game.supply_used(ai.team) >= ai.game.max_supply(ai.team) - 6:
		return false
	cap_waits[ai.team] = int(cap_waits.get(ai.team, 0)) + 1
	if int(cap_waits[ai.team]) % 30 == 1:
		siege.say("waits for a big army against the Brood: %d supply at home, it wants %d" % [sup, CAP_SUP])
	return true


# ------------------------------------------------------------------ change "counter": strike back after a beaten wave
## (block 1: the Brood's waves broke on the Crown's line at home ("Brood pulls its wave back: only 170 of 400 is left",
## Dune Sea r1 10:38) while the Crown stood 2-4 times its army, and the push waited QUIET (60 s) after any enemy force at
## its buildings: by then the Brood had laid its next eggs.) Against the Brood, within COUNTER_WINDOW s of a wave at our
## buildings that is gone now, with the army at home worth COUNTER_K times the Brood army seen lately (never under
## COUNTER_FOE_MIN) and COUNTER_SUP supply, the push goes at once (the counter-attack), guns or not.
const COUNTER_WINDOW := 45.0
const COUNTER_K := 2.0
const COUNTER_FOE_MIN := 300.0
const COUNTER_SUP := 40
static var counters_sent := {}  # team -> counter-attacks sent


## (change "counterw", block 9: the same, wider: COUNTERW_WINDOW s, COUNTERW_K, COUNTERW_SUP; "counter" fired 0-2 times a game)
const COUNTERW_WINDOW := 90.0
const COUNTERW_K := 1.5
const COUNTERW_SUP := 30


static func counter_now(ai, siege, mine: float, sup: int, since_threat: float) -> bool:
	var wide := vs_brood(ai, "counterw")
	if not (wide or vs_brood(ai, "counter")) or since_threat < 0.0:
		return false
	if since_threat > (COUNTERW_WINDOW if wide else COUNTER_WINDOW):
		return false
	if sup < (COUNTERW_SUP if wide else COUNTER_SUP) or mine < (COUNTERW_K if wide else COUNTER_K) * maxf(COUNTER_FOE_MIN, float(ai.ch.foe_known())):
		return false
	counters_sent[ai.team] = int(counters_sent.get(ai.team, 0)) + 1
	siege.say("strikes back: the Brood's wave at its buildings is beaten (%d of army against the %d of Brood it knows)" % [
		int(mine), int(ai.ch.foe_known())])
	return true


# ------------------------------------------------------------------ change "home": the push comes home for its base
## (block 5, Hollowfen r0: the push went out at 10:13; the Brood attacked the Crown's base with 82 supply at 10:54; the
## push set up against a Rootmaw at 11:41 while the natural fell at 11:46, and fell back only at 11:51. The siege push's
## "base attacked" rule weighs the Brood force near home against AICrownHold.home_value, which counts the push's own men
## too: with the army out the rule could hardly fire.) Against the Brood the push comes home when an enemy force is at our
## buildings (AICrown._threat) and the Brood seen on our side lately (foe_near) is worth HOME_K times what is at home
## WITHOUT the push, plus HOME_PAD.
const HOME_K := 0.8
const HOME_PAD := 150.0
static var home_calls := {}     # team -> pushes called home


static func home_call(ai, push_men: Dictionary) -> String:
	if not vs_brood(ai, "home") or ai._threat() == Vector2.INF:
		return ""
	var near: float = ai.ch.foe_near()
	var home := 0.0
	for u in ai.game.army(ai.team):
		if push_men.has(u) or u.dead or not u.has_attack() or u.kind == "powder_wagon" or ai._raiders.has(u):
			continue
		home += float(Game.unit_value(u))
	if near <= home * HOME_K + HOME_PAD:
		return ""
	home_calls[ai.team] = int(home_calls.get(ai.team, 0)) + 1
	return "the Brood is at its buildings (%d near home, %d at home without the push)" % [int(near), int(home)]


# ------------------------------------------------------------------ change "labs": the labourers go on while far ahead
## (blocks 1-9: the Crown's income stays at 1,100-1,900 a minute from 8:00 while the Brood's grows to 2,000-3,000 from 9:00-10:00;
## at 10:00-12:00 the Crown had 44-88 Farm posts and only 24-42 labourers on them, and its halls held their labourers for the
## army ("army_due" in up to 12 of 12 looks): AICrown.army_grows and army_behind weigh the army against the CLOCK's reckoning
## of the Brood (BROOD_TABLE: 3,800 at 10:00) while the Brood army it had seen was a third of its own.) Against the Brood
## from LABS_FROM, while the army is at least LABS_MIN and LABS_K times the Brood army seen lately, those two rules do not
## hold the labourers back (the home line's floor, the defence's alert and an army far behind still do).
const LABS_FROM := 360.0
const LABS_MIN := 800.0
const LABS_K := 2.0
static var labs_looks := {}     # team -> thinks the rules were lifted


static func labs_free(ai) -> bool:
	if not vs_brood(ai, "labs") or ai.game.clock < LABS_FROM:
		return false
	var mine := float(ai.game.army_value(ai.team))
	if mine < LABS_MIN or mine < LABS_K * float(ai.ch.foe_known()):
		return false
	labs_looks[ai.team] = int(labs_looks.get(ai.team, 0)) + 1
	return true


# ------------------------------------------------------------------ change "evac": the labourers leave a hall the Brood comes to
## (blocks 1 and 3, 20 games: the Crown lost 1,098 labourers, about 50 a game, 1,000 of them from 12:00 on, while the
## Brood's capped waves took one outlying hall after another; a labourer (74) cannot outrun a Raptor (92, 114 with Pack
## Hunt), and AI._worker_safety only runs them once the creatures are within FLEE_R of them.) Against the Brood, when a
## Brood force worth EVAC_MIN or more is in sight within EVAC_R tiles of one of our built halls and the soldiers there are
## worth less than EVAC_K times it, the labourers within EVAC_WORK tiles of that hall walk to the safest other hall (the
## farthest from the force, not threatened itself) and come back to their posts once the force there is gone (or after
## EVAC_MAX s).
const EVAC_MIN := 400.0
const EVAC_R := 16.0
const EVAC_WORK := 15.0
const EVAC_K := 1.0
const EVAC_MAX := 90.0
static var evac := {}           # team -> {labourer: {"since", "hall", "e"}}
static var evac_sent := {}      # team -> labourers sent away (the counter)
static var _evac_t := {}        # team -> clock of the last look


static func _threat_at(ai, h: Building) -> Array:
	var c: Vector2 = h.center()
	var foe := 0.0
	var mid := Vector2.ZERO
	var n := 0
	var mine := 0.0
	for u in ai.game.units_near(c, EVAC_R * Defs.TILE):
		if u.dead or u.off_field or not u.has_attack() or u.is_worker():
			continue
		if ai.game.hostile(u.team, ai.team):
			if ai.game.is_visible_to(ai.team, u.position) and not AIHarass.is_static(u):
				foe += float(Game.unit_value(u))
				mid += u.position
				n += 1
		elif u.team == ai.team and u.kind != "powder_wagon":
			mine += float(Game.unit_value(u))
	return [foe, mid / float(maxi(1, n)), mine]


static func evac_tick(ai) -> void:
	if not (ai is AICrown) or not vs_brood(ai, "evac"):
		return
	var t: int = ai.team
	if ai.game.clock - float(_evac_t.get(t, -9.0)) < 1.0:
		return
	_evac_t[t] = ai.game.clock
	if not evac.has(t):
		evac[t] = {}
	var mine_e: Dictionary = evac[t]
	var halls: Array = ai._halls().filter(func(h: Building) -> bool: return h.built and not h.dead)
	var hot := {}
	for h in halls:
		var th := _threat_at(ai, h)
		if float(th[0]) >= EVAC_MIN and float(th[2]) < EVAC_K * float(th[0]):
			hot[h] = th
	# the labourers of a hot hall go
	for h in hot:
		var th: Array = hot[h]
		var safe: Building = null
		var bd := -1.0
		for o in halls:
			if hot.has(o):
				continue
			var d: float = o.center().distance_to(th[1])
			if d > bd:
				bd = d
				safe = o
		if safe == null:
			continue        # (every hall is hit: AI._worker_safety's own running is all that is left)
		for w in ai.game.workers(t):
			if w.dead or mine_e.has(w) or w.keg or ai._escort.has(w) or ai._fighters.has(w):
				continue
			if ai.scout != null and ai.scout.is_scout(w):
				continue
			if w.position.distance_to(h.center()) > EVAC_WORK * Defs.TILE:
				continue
			var e := {"since": ai.game.clock, "site": w.home_mine if w.order == "gather" else null,
				"build": w.order_target if w.order == "build" else null}
			mine_e[w] = {"since": ai.game.clock, "hall": h, "e": e}
			evac_sent[t] = int(evac_sent.get(t, 0)) + 1
	# keep them away while their hall is hot; back to work once it is calm
	for w in mine_e.keys():
		if not is_instance_valid(w) or w.dead:
			mine_e.erase(w)
			continue
		var r: Dictionary = mine_e[w]
		var h = r["hall"]
		var calm: bool = not is_instance_valid(h) or h.dead or not hot.has(h)
		if calm or ai.game.clock - float(r["since"]) > EVAC_MAX:
			mine_e.erase(w)
			ai._fled.erase(w)
			ai._resume(w, r["e"])
			continue
		var th: Array = hot[h]
		var safe: Building = null
		var bd := -1.0
		for o in halls:
			if hot.has(o):
				continue
			var d: float = o.center().distance_to(th[1])
			if d > bd:
				bd = d
				safe = o
		if safe == null:
			continue
		ai._fled[w] = r["e"].merged({"since": ai.game.clock})
		if w.order != "move" and w.position.distance_to(safe.center()) > 3.0 * Defs.TILE:
			w.cmd_move(safe.center() + Vector2(randf_range(-60, 60), randf_range(-60, 60)))


## (qa_match's result.json "crown_ai": what this job's changes did)
static func counters(team: int) -> Dictionary:
	return {"wcb_arm_freed": int(arm_freed.get(team, 0)), "wcb_cap_waits": int(cap_waits.get(team, 0)),
		"wcb_counters": int(counters_sent.get(team, 0)), "wcb_home_calls": int(home_calls.get(team, 0)),
		"wcb_labs_looks": int(labs_looks.get(team, 0)), "wcb_evac_sent": int(evac_sent.get(team, 0))}
