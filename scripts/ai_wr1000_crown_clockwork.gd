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


# ------------------------------------------------------------------ finish: the Crown hunts a beaten Clockwork (block 2)

## Block 1 (the baseline): the Crown at its 200 supply with 4,000-5,000 of army and a bank of 7,000-21,000 gold, the
## Clockwork's army beaten down to 350-1,000, and the game still standing at 20:00 (Hollowfen, Ashford Crossing, Dune Sea):
## the shared hunt (AIHunt) only starts when the enemy has NO fighting unit, and the Clockwork always has a few. Here the
## Crown computer hunts the Clockwork's halls (nearest first, then its other buildings) while the Clockwork's fighting
## units are worth under FINISH_SHARE of its army and its army is at least FINISH_OURS (the mirror's token hunt, AICrownMirror).
const FINISH_SHARE := 0.2
const FINISH_OURS := 2000.0


static func hunt_anyway(ai, foe_t: int, army: Array) -> bool:
	if not on("finish") or not vs(ai, "crown"):
		return false
	var theirs := 0.0
	for u in ai.game.units:
		if AIHunt.fighter(u, foe_t):
			theirs += float(Game.unit_value(u))
	var mine := 0.0
	for u in army:
		mine += float(Game.unit_value(u))
	var go := mine >= FINISH_OURS and theirs < mine * FINISH_SHARE
	if go:
		count(ai, "finish")
	return go


## The hunt's goal in this pairing: the enemy's nearest hall, else the shared rule (its nearest building).
static func hunt_goal(ai, foe_t: int, from: Vector2) -> Vector2:
	var game: Game = ai.game
	var best := Vector2.INF
	var bd := INF
	for b in game.buildings:
		if b.team == foe_t and not b.dead and not b.ghost and b.kind == game.faction_hall(foe_t):
			var d: float = b.center().distance_to(from)
			if d < bd:
				bd = d
				best = b.center()
	return best if best != Vector2.INF else AIHunt._target(game, foe_t, from)
