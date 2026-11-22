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
	if not (on("springs") or on("owls")) or not cw_v_brood(ai):
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


# ------------------------------------------------------------------ owls (block 4)
## OWLS: the Brood's army against the Clockwork is led by Spitters (AIBroodVCw "bvcmix"), and a Spitter never spits at a
## flyer. The Ticking Owl (a Swift morphed: 175 cogs + 65 Tension in all) swoops on ground units and only the Brood's
## Venom Challengers, Dilophosaurus, Pterodactyls, Hatchlings and Storm Challengers can touch it. With Spitters seen
## (OWL_SPITS or more lately), the Clockwork lays its Aviary at once, researches the Owl and keeps Swifts coming to morph,
## up to one Owl for every OWL_PER Spitters seen (OWL_MAX), fewer once the Brood shows flyer-killers. It comes with
## `springs` (the Tension for it); `wkbowls:on` turns both on.
const OWL_SPITS := 10
const OWL_PER := 4
const OWL_MAX := 10
const AA_KINDS := ["venom_challenger", "dilophosaurus", "pterodactyl", "hatchlings", "storm_challenger"]
static var _seen := {}       # ai -> {"t": next look, "spit": n, "spit_t": when, "aa": n, "aa_t": when}


static func _look(ai) -> Dictionary:
	var g = ai.game
	var s: Dictionary = _seen.get(ai, {"t": 0.0, "spit": 0, "spit_t": -999.0, "aa": 0, "aa_t": -999.0})
	if g.clock >= float(s["t"]):
		s["t"] = g.clock + 3.0
		var sp := 0
		var aa := 0
		for u in g.units:
			if u.dead or not g.hostile(u.team, ai.team) or not g.is_visible_to(ai.team, u.position):
				continue
			if u.kind == "spitter":
				sp += 1
			elif AA_KINDS.has(u.kind):
				aa += 1
		if sp >= int(s["spit"]) or g.clock - float(s["spit_t"]) > 120.0:
			s["spit"] = sp
			s["spit_t"] = g.clock
		if aa >= int(s["aa"]) or g.clock - float(s["aa_t"]) > 120.0:
			s["aa"] = aa
			s["aa_t"] = g.clock
		_seen[ai] = s
	return s


## The Owls the Clockwork wants now against the Brood (0 = the rule is off or not called for).
static func owl_target(ai) -> int:
	if not on("owls") or not cw_v_brood(ai):
		return 0
	var s := _look(ai)
	if int(s["spit"]) < OWL_SPITS:
		return 0
	var n := mini(OWL_MAX, int(s["spit"]) / OWL_PER)
	n -= int(s["aa"]) / 2          # (flyer-killers seen: fewer Owls)
	return maxi(0, n)


static func owls_have(ai) -> int:
	var n := 0
	for u in ai.game.army(ai.team):
		if u.kind == "ticking_owl" or (u.kind == Defs.CUCKOO and u.owl_t >= 0.0):
			n += 1
	return n


## (_air's time) Against the Brood's Spitters the Aviary and the Owl research come at once: a later time is handed back.
static func air_t(ai, t: float) -> float:
	if owl_target(ai) > 0:
		return maxf(t, 2000.0)
	return t


## (the Aviary's Swifts in _produce) Swifts to morph into the Owls still wanted.
static func swift_want(ai, want: int, swifts: int) -> int:
	var tg := owl_target(ai)
	if tg <= 0 or not ai.game.has_tech(ai.team, "owl_morph"):
		return want
	var need := tg - owls_have(ai)
	if need <= 0:
		return want
	return maxi(want, _morphing(ai) + mini(need, 2))


static func _morphing(ai) -> int:
	var n := 0
	for u in ai.game.army(ai.team):
		if u.kind == Defs.CUCKOO and u.owl_t >= 0.0:
			n += 1
	return n


## (_produce's Tension kept from the Springers) a morph's Tension while Owls are wanted.
static func owl_keep(ai) -> float:
	var tg := owl_target(ai)
	if tg <= 0 or owls_have(ai) >= tg:
		return 0.0
	if not ai.game.has_tech(ai.team, "owl_morph"):
		return float(Defs.RESEARCH["owl_morph"]["tension"])
	return float(Defs.OWL_MORPH["tension"])
