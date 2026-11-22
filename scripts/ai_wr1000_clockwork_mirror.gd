class_name WkM
extends RefCounted
## WR1000, THE CLOCKWORK MIRROR (wr1000-clockwork-mirror, the owner 2026-11-22 01:29: a fresh win-rate study as "1000 over
## 10s", blocks of 10 games changing one thing in the computer's play each block; docs/wr1000_clockwork_mirror.md). The
## Clockwork computer (Hard OPTIMAL) against itself to 20:00 on 10 parity games. Every change here runs only when a Clockwork
## computer faces a Clockwork (mirror(ai, foe)), so the sister jobs of the other pairings merge beside it. Each change has
## its own switch: `-- wkm<name>:on` / `:off`; `-- wkm:off` plays the mirror as before this job. The changes KEPT are on by
## default (KEPT); the rest were measured and not kept (the doc says what each did).

const KEPT: Array[String] = []

static var _args: PackedStringArray = OS.get_cmdline_user_args()


## Is change `name` on (the caller checks the matchup with mirror())?
static func on(name: String) -> bool:
	if _args.has("wkm:off"):
		return false
	if _args.has("wkm%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("wkm%s:on" % name)


## A Clockwork computer (team t) against a Clockwork (team foe)?
static func mirror(game, t: int, foe: int) -> bool:
	return foe >= 0 and game.faction_of(t) == "clockwork" and game.faction_of(foe) == "clockwork"


## CHANGE "cap" (block 2). After a push that had to pull back the next one goes only worth 1.25 times it (AICwArmy.AFTER_FAIL).
## In the mirror that bar can never be met: both armies grow to the 200 supply cap with Clock Soldiers (~70-85 a supply), so a
## push of 7,315 that pulled back (having killed 4,590 for 4,415) asks 9,143 and the army sits at the cap worth 8,000 with 4,000-
## 6,000 cogs in the bank to 20:00 (Greenhold r0, block 1: P1 from 14:29). In the mirror the bar is waived when the army is
## (nearly) full, CAP_SUPPLY of supply in use or CAP_BANK cogs it cannot spend, or CAP_T s after that push came home; the push
## still needs its usual edge over the enemy army it reckons.
const CAP_SUPPLY := 180
const CAP_BANK := 1500
const CAP_T := 150.0


static func fail_waived(ai, army, mine: float) -> bool:
	var game = ai.game
	if not on("cap") or not mirror(game, ai.team, army._foe()):
		return false
	var why := ""
	if game.supply_used(ai.team) >= CAP_SUPPLY:
		why = "its army is full"
	elif int(game.players[ai.team]["gold"]) >= CAP_BANK:
		why = "its bank is full"
	elif game.clock - float(army._fail_t) >= CAP_T:
		why = "that push came home %d s ago" % int(game.clock - float(army._fail_t))
	if why == "":
		return false
	army.say("the last push's bar (%d) is waived: %s (worth %d)" % [int(army._fail_v * army.AFTER_FAIL), why, int(mine)], "wkmcap", 45.0)
	return true


## CHANGE "nospr" (block 3). OPTIMAL's NORMAL / UNKNOWN pick in the mirror is Balanced 3, Economy 2, Springer timing 1. The
## Springer timing switched to at 3:00 from the economy opening lays the Escapement and buys HIGH LEAP, a Clock Aviary and a
## Swift before any army: 240 worth at 5:00, 365 at 8:00 against the other side's 2,015 (Cinder Steps r0, block 1), and it lost
## all four games where it was picked (blocks 0 and 1, beaten at 11:17-13:31, a draw where it turned to Balanced). A lost game
## decided by a dice throw at 3:00 is no skill: in the mirror the pick is Balanced or Economy.
static func normal_w(w: Dictionary) -> Dictionary:
	if not on("nospr") or not w.has("springer"):
		return w
	var out := w.duplicate()
	out.erase("springer")
	return out
