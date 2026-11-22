class_name AIWccr
extends RefCounted
## WIN RATE 1000, CROWN v CLOCKWORK (wr1000-crown-clockwork, docs/wr1000_crown_clockwork.md; the owner 2026-11-22 01:29:
## "1000 over 10s"): blocks of 10 Hard OPTIMAL games, one change of a computer's play a block. Every change of that job is
## here, behind its own switch, and plays only in the Crown v Clockwork pairing (either computer: the Crown computer whose
## enemy is the Clockwork, or the Clockwork computer whose enemy is the Crown). No number of the game changes.
## A change KEPT by the study is on by default (KEPT) and `-- wcc<name>:off` turns it off; one not kept is off and
## `-- wcc<name>:on` turns it on (to measure it again). `-- wcc:off` turns every one off.

const KEPT := {}

static var _args: PackedStringArray = OS.get_cmdline_user_args()


static func on(name: String) -> bool:
	if _args.has("wcc:off"):
		return false
	if _args.has("wcc" + name + ":on"):
		return true
	return bool(KEPT.get(name, false)) and not _args.has("wcc" + name + ":off")


## A change acted once more (result.json "wcc", counted on the computer's node meta).
static func count(ai, name: String) -> void:
	var d: Dictionary = ai.get_meta("wcc", {})
	d[name] = int(d.get(name, 0)) + 1
	ai.set_meta("wcc", d)


## The computer `ai` plays in the Crown v Clockwork pairing, as `me` ("crown" or "clockwork").
static func vs(ai, me: String) -> bool:
	if ai == null or ai.game == null:
		return false
	var f: int = ai._foe()
	if f < 0 or ai.game.faction_of(ai.team) != me:
		return false
	return ai.game.faction_of(f) == ("clockwork" if me == "crown" else "crown")
