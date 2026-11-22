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


## (qa_match's result.json "crown_ai": what this job's changes did)
static func counters(team: int) -> Dictionary:
	return {"wcb_arm_freed": int(arm_freed.get(team, 0))}
