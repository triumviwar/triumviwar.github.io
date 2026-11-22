extends RefCounted
## WR1000, THE CLOCKWORK V THE BROOD (wr1000-clockwork-brood, docs/wr1000_clockwork_brood.md). The owner, 2026-11-22
## 01:29: a fresh win-rate study done as "1000 over 10s", blocks of 10 Hard OPTIMAL v Hard OPTIMAL games to 20:00, one
## change of the computer's play a block, kept only when the block is clearly better than the best so far. Every change
## here acts only when a Clockwork computer faces a Brood (or a Brood computer faces a Clockwork), so the five sister jobs
## merge beside it. Each change has its switch: `-- wkb<name>:on` / `:off`; `-- wkb:off` plays as before this job. The
## changes KEPT are on by default (KEPT); the rest were measured and left off (the doc says what each did).

const KEPT: Array[String] = []

static var _args: PackedStringArray = OS.get_cmdline_user_args()


## Is change `name` on? (the caller checks the matchup)
static func on(name: String) -> bool:
	if _args.has("wkb:off"):
		return false
	if _args.has("wkb%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("wkb%s:on" % name)


## A Clockwork computer facing the Brood?
static func cw_v_brood(ai) -> bool:
	if ai == null or ai.game == null or ai.game.faction_of(ai.team) != "clockwork":
		return false
	var f: int = ai._foe()
	return f >= 0 and ai.game.faction_of(f) == "brood"


## A Brood computer facing the Clockwork?
static func brood_v_cw(ai) -> bool:
	if ai == null or ai.game == null or ai.game.faction_of(ai.team) != "brood":
		return false
	var f: int = ai._foe()
	return f >= 0 and ai.game.faction_of(f) == "clockwork"


# ------------------------------------------------------------------ springs (block 3)
## SPRINGS: against the Brood the Clockwork ran 4 Clocktowers on 2 Mainsprings all game (a new one only once the old ones
## were fatigued): Tension sat near 0, so the army was ~90 Clock Soldiers and 1-3 Springers, and the Brood's Spitters
## (165 reach, acid) cut it down at 12:00-14:00. From SPRINGS_AT, every built Clocktower with fresh spring life and no
## Mainspring drawing on it gets one (one laid at a time; its crew comes from the economy's own posts, AICwMacro).
const SPRINGS_AT := 300.0
static var _springs_t := {}


static func more_springs(ai) -> void:
	if not on("springs") or not cw_v_brood(ai):
		return
	var g = ai.game
	if g.clock < SPRINGS_AT or g.clock < float(_springs_t.get(ai, 0.0)):
		return
	_springs_t[ai] = g.clock + 5.0
	if not ai._spring_ok() or ai._busy_building("mainspring"):
		return
	var drawn := {}
	for sp in ai._mine("mainspring"):
		var h = g.soil_hall(sp)
		if h != null:
			drawn[h] = true
	for h in ai._halls():
		if not h.built or drawn.has(h) or h.soil_left() < 0.4:
			continue
		var c: Vector2i = GearEcon.room_spot(g, ai.team, "mainspring", [h])
		if c.x < 0:
			continue
		var cost := int(Defs.BUILDINGS["mainspring"]["cost"])
		if ai._gold() >= cost + 20:
			ai._construct("mainspring", c)
			if g.mlog and ai._busy_building("mainspring"):
				g.mlog.add("%s builds a Mainspring by a Clocktower that had none (Tension against the Brood) [wkbsprings]" % g.mlog.who(ai.team))
		elif ai._threat() == Vector2.INF or ai._holds_line():
			ai._reserve = maxi(ai._reserve, cost + 20)
		return
