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
