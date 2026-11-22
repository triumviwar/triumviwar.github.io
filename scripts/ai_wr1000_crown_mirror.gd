class_name AIWr1000CrownMirror
extends RefCounted
## WR1000, THE CROWN MIRROR (wr1000-crown-mirror, the owner 2026-11-22 01:29: a fresh win-rate study done as "1000 over 10s":
## 1000 games over six jobs, blocks of 10 games, one change of the computer's play a block; docs/wr1000_crown_mirror.md).
## This job's pairing is the Crown computer against the Crown computer (Hard OPTIMAL v Hard OPTIMAL, to 20:00). Every change
## here runs ONLY when a Crown computer faces another Crown (AICrown.mirror() != null), so the five sister jobs merge beside
## it. Each change has its own switch: `-- wcm<name>:on` / `:off`; `-- wcm:off` plays the mirror as before this job. The
## changes KEPT are on by default (KEPT); the rest were measured and not kept (the doc says what each did).

const KEPT: Array[String] = []

static var _args: PackedStringArray = OS.get_cmdline_user_args()


## Is change `name` on (in the mirror; the caller checks the matchup)?
static func on(name: String) -> bool:
	if _args.has("wcm:off"):
		return false
	if _args.has("wcm%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("wcm%s:on" % name)


## The Crown computer `ai` faces another Crown (the mirror's coach is alive): this job's changes may act.
static func mirror(ai) -> bool:
	return ai != null and ai.has_method("mirror") and ai.mirror() != null


## CHANGE `cut` (block 3): the crown-rule-cleanup's CUT against the Clockwork (the army clock and floor, the fight group,
## the hold; AICrownRules.CUT["clockwork"]) played in the mirror too. That job measured them as harm for the Crown against
## the Clockwork and left the mirror open ("cannot be measured by switching both sides"): here both sides switch and the
## measure is how decisive the games get. Called by AICrownRules.cut when the enemy is a Crown.
static func cut(name: String) -> bool:
	return on("cut") and (AICrownRules.CUT["clockwork"] as Array).has(name)


## CHANGE `finish` (block 4): THE SIDE FAR AHEAD FINISHES. Block 1, Greenhold r0: from 15:00 P2 had 4,170-6,320 of army
## against P1's 350-830 (P1 had lost 72 buildings) and the game was still not over at 20:00: the mirror coach's hunt over a
## token army (AICrownMirror.hunt_anyway) wants the enemy army under 450 whatever ours is, and P2's Siege push set up its
## guns against every Palisade, Gate and Barracks in turn ("sets up against a Palisade (306 px off)" 6 times in 3 minutes).
## Now the hunt (AIHunt: the whole army for the nearest enemy hall, then the last buildings) also goes on when our fighters
## are worth FINISH_MIN or more and the enemy's under FINISH_SHARE of them, and a Siege push out ends and joins it.
const FINISH_MIN := 1500.0
const FINISH_SHARE := 0.25


## (AICrown._hunt_anyway) true = hunt now.
static func hunt(ai, foe_t: int) -> bool:
	if not on("finish") or foe_t < 0:
		return false
	var game = ai.game
	var mine := 0.0
	var theirs := 0.0
	for u in game.units:
		if AIHunt.fighter(u, ai.team):
			mine += float(Game.unit_value(u))
		elif AIHunt.fighter(u, foe_t):
			theirs += float(Game.unit_value(u))
	return mine >= FINISH_MIN and theirs < mine * FINISH_SHARE


## (AICrownSiege.tick) true = the hunt is on: the push ends (its men join the hunt) and no new one goes.
static func siege_yields(sg) -> bool:
	if not on("finish") or sg.ai.mirror() == null or sg.ai.hunt == null or not sg.ai.hunt.on:
		return false
	if sg.state != "":
		sg._end("the hunt takes over: the enemy army is a fraction of ours")
	return true


## CHANGE `press2` (block 6): THE SIDE AHEAD PRESSES SOONER. The mirror coach's press (AICrownMirror.press, rule 8) sent a
## wave 0-3 times a side a game in blocks 1-2, and armies 3-4 times the enemy's sat at home (Frostfang r1, both blocks: P1
## 1,635 against 370-385 at 12:00, its first attack at 10:46 / 11:57). Its numbers made easier: from 7:00 (8:00), 1.15
## times the enemy army it reckons (1.3), 700 of army (900), 20 s after the last wave (25), the reckoning's floor 0.5 of
## the clock's table when the enemy army was seen lately (0.7) and 0.6 when not (0.8).
const PRESS2 := {"from": 420.0, "edge": 1.15, "min": 700.0, "cool": 20.0, "floor": 0.5, "stale": 0.6}


static func press_k(k: String, today: float) -> float:
	return float(PRESS2[k]) if on("press2") else today
