class_name AIWr1000BroodMirror
extends RefCounted
## WR1000, THE BROOD MIRROR (wr1000-brood-mirror, the owner 2026-11-22 01:29: a fresh win-rate study as "1000 over 10s",
## blocks of 10 games, ONE change of the computer's play a block; docs/wr1000_brood_mirror.md). The Brood computer (Hard
## OPTIMAL) against the Brood computer, games to 20:00 on the 6 parity maps. Every change here runs only when a Brood
## computer faces another Brood (the mirror: AIBroodNew._foe_is("brood")), so the sister jobs of the other pairings merge
## beside it. Each change has its own switch: `-- wbm<name>:on` / `:off`; `-- wbm:off` plays the mirror as before this job.
## The changes KEPT are on by default (KEPT); the rest were measured and not kept (the doc says what each did).

const KEPT: Array[String] = []

static var _args: PackedStringArray = OS.get_cmdline_user_args()


## Is change `name` on (in the mirror; the caller checks the matchup)?
static func on(name: String) -> bool:
	if _args.has("wbm:off"):
		return false
	if _args.has("wbm%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("wbm%s:on" % name)
