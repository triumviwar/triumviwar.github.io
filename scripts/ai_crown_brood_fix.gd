class_name AICrownBroodFix   # (used by preload: the class cache may not know it)
extends RefCounted
## CROWN V BROOD FIX (crown-brood-fix, the owner 2026-11-22 21:27-21:29: "we can't just let it be so lopsided", "Do it";
## docs/crown_brood_fix.md). The Crown computer against the Brood only: every change here runs only for a Crown computer
## (Normal and up) facing a Brood (the caller checks the faction, `vs_brood` checks the rest). Each change has its own
## switch: `-- cbf<name>:on` / `:off`; `-- cbf:off` plays as before this job. The changes KEPT are on by default.
##
## The balance switch of this job (the far-Rootmaw pay, `farmaw:X`) is not here: it is a match switch read by Game
## (Game.food_bonus) and changes no default.

const KEPT: Array[String] = []

static var _args: PackedStringArray = OS.get_cmdline_user_args()


## Is change `name` on?
static func on(name: String) -> bool:
	if _args.has("cbf:off") or _args.has("cbf%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("cbf%s:on" % name)


## A Crown computer (Normal and up) facing a Brood, with change `name` on.
static func vs_brood(ai, name: String) -> bool:
	return on(name) and ai.on and ai.difficulty >= 1 and ai._foe_is("brood")


# ------------------------------------------------------------------ change "press": THE CROWN SPENDS ITS LEAD
## (wr1000-crown-brood: at 8:00 the Crown had 3 times the Brood's army and 1.4 times its income, then waited: the siege push
## wanted its 3 guns and 10 Musketeers and 60 quiet seconds, the wave waited on the clock's reckoning of the Brood
## (BROOD_TABLE, ~3,000-3,800 at 9:00-10:00) while 375-500 of Brood had been seen; from 10:00 the Brood out-earned it.)
## From PRESS_FROM to PRESS_UNTIL, while the army at home is worth PRESS_MIN or more AND PRESS_K times the Brood army it has
## SEEN lately (AICrownHold.foe_known, never under PRESS_FOE_MIN), with PRESS_SUP supply, and no Brood force at our
## buildings: the whole army goes at once for the Brood Mother herself (the siege push in its "queen" march, guns or not;
## outside the siege plan the wave goes and the reckoning does not hold it). It sets up only against the Brood army on the
## line, what blocks its way (PRESS_STOP of the usual reach) and her; the line does not wait for its guns (they follow);
## the push's usual retreat rules stand.
## At most PRESS_MAX such pushes a game. With no Brood soldier seen lately it asks the scout for a look first.
const PRESS_FROM := 480.0
const PRESS_UNTIL := 660.0
const PRESS_MIN := 1000.0
const PRESS_K := 2.0
const PRESS_FOE_MIN := 400.0
const PRESS_SUP := 30
const PRESS_STOP := 0.35
const PRESS_MAX := 2
static var presses := {}         # team -> pushes sent by this change (the counters)
static var press_waves := {}     # team -> waves let go by it outside the siege plan
static var press_looks := {}     # team -> looks asked for it


## The army at home is far ahead of the Brood seen lately, in the window: true when the press may go now.
static func press_ok(ai, mine: float, sup: int) -> bool:
	if not vs_brood(ai, "press"):
		return false
	var c: float = ai.game.clock
	if c < PRESS_FROM or c > PRESS_UNTIL or int(presses.get(ai.team, 0)) + int(press_waves.get(ai.team, 0)) >= PRESS_MAX:
		return false
	if mine < PRESS_MIN or sup < PRESS_SUP:
		return false
	if not ai.ch.army_known_lately():
		press_looks[ai.team] = int(press_looks.get(ai.team, 0)) + 1
		ai.want_look("the press on the Brood")
		return false
	if mine < PRESS_K * maxf(PRESS_FOE_MIN, float(ai.ch.foe_known())):
		return false
	if ai._threat() != Vector2.INF and float(ai.ch.foe_near()) >= 250.0:
		return false
	if BroodNew.queen(ai.game, ai._foe()) == null:
		return false
	return true


## AICrownSiege._maybe_go asks: the siege push goes now for the Mother?
static func press_push(ai, siege, home: Array, sup: int) -> bool:
	var raw := 0.0
	for u in home:
		raw += float(Game.unit_value(u))
	if not press_ok(ai, raw, sup):
		return false
	presses[ai.team] = int(presses.get(ai.team, 0)) + 1
	siege.say("presses its lead on the Brood: %d of army against the %d of Brood seen lately: the whole army goes for the Brood Mother" % [
		int(raw), int(ai.ch.foe_known())])
	return true


## AICrown._wave_worth asks (outside the siege plan): the wave goes though the reckoning says wait?
static func press_wave(ai, ready: Array) -> bool:
	var raw := 0.0
	for u in ready:
		raw += float(Game.unit_value(u))
	if not press_ok(ai, raw, ai._army_supply(ready)):
		return false
	press_waves[ai.team] = int(press_waves.get(ai.team, 0)) + 1
	ai.say("presses its lead on the Brood: %d of army against the %d of Brood seen lately: the wave goes now" % [int(raw), int(ai.ch.foe_known())])
	return true


## (qa_match's result.json "crown_ai": what this job's changes did)
static func counters(team: int) -> Dictionary:
	return {"cbf_presses": int(presses.get(team, 0)), "cbf_press_waves": int(press_waves.get(team, 0)),
		"cbf_press_looks": int(press_looks.get(team, 0))}
