extends RefCounted
## WR1000, THE CLOCKWORK V THE BROOD (wr1000-clockwork-brood, docs/wr1000_clockwork_brood.md). The owner, 2026-11-22
## 01:29: a fresh win-rate study done as "1000 over 10s", blocks of 10 Hard OPTIMAL v Hard OPTIMAL games to 20:00, one
## change of the computer's play a block, kept only when the block is clearly better than the best so far. Every change
## here acts only when a Clockwork computer faces a Brood (or a Brood computer faces a Clockwork), so the five sister jobs
## merge beside it. Each change has its switch: `-- wkb<name>:on` / `:off`; `-- wkb:off` plays as before this job. The
## changes KEPT are on by default (KEPT); the rest were measured and left off (the doc says what each did).

const KEPT: Array[String] = ["owls"]      # (owls: blocks 4 and 10, kept after block 10; it brings `springs`)

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
	if not (on("springs") or on("owls") or on("pends")) or not cw_v_brood(ai):
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


# ------------------------------------------------------------------ sire (block 5)
## SIRE: the Brood's Venom Sire stood unrooted beside the Mother all game in some games (hollowfen r0: hatched at 7:09,
## never rooted to 20:00, 0 Spitters laid, 1,000-2,700 food banked, 88 Raptors fed to the Pendulums): every nest in his
## 7-tile range was taken by the Mound Turtles rooted round her for supply (110 of 120 places on her rings "Blocked: a
## rooted creature is in the way", the rest on her own ground), so AIBroodNew._nb_father_spot found none, and a Sire
## without a nest fertilises no eggs (no Spitters: AIBroodVCw.warrior waits on him). Now, against the Clockwork, a Sire
## with no nest for SIRE_WAIT s gets one: the supply Mound Turtle rooted nearest his best ring round her gets up and walks
## SIRE_AWAY tiles out (left alone for SIRE_HOLD s, then the computer roots it again where there is room), and he nests
## where it stood.
const SIRE_WAIT := 12.0
const SIRE_AWAY := 9.0
const SIRE_HOLD := 25.0
static var _no_nest := {}          # father -> clock when he first found no nest
static var _moved := {}            # turtle -> [clock it was moved, the ai]


static func sire_room(ai, q: Unit, f: Unit) -> void:
	if not on("sire") or not brood_v_cw(ai):
		return
	var g = ai.game
	_release(ai)
	var t0 = _no_nest.get(f)
	if t0 == null:
		_no_nest[f] = g.clock
		return
	if g.clock - float(t0) < SIRE_WAIT:
		return
	for t in _moved.keys():
		if _moved[t][1] == ai:
			return          # (one turtle at a time)
	var reach := float(Defs.NB["father_r"]) * Defs.TILE
	var qk: Vector2 = BroodRoot.feet_k(g, ai.team, q)
	var best: Unit = null
	var bd := INF
	for t in g.units:
		if t.dead or t.team != ai.team or t.kind != BroodNew.TURTLE or not BroodNew.rooted(t) or ai.held.has(t):
			continue
		var d: float = BroodRoot.feet_k(g, ai.team, t).distance_to(qk)
		if d > reach * 1.05:
			continue
		var dd: float = absf(d - reach * 0.75)
		if dd < bd:
			bd = dd
			best = t
	if best == null:
		return
	best.cmd_uproot(false)
	ai.held.append(best)
	_moved[best] = [g.clock, ai]
	_no_nest[f] = g.clock          # (the next one, if he still finds none, after another wait)
	if g.mlog:
		g.mlog.add("%s's Brood: the %s found no nest by the Mother for %d s: a supply Mound Turtle gets up to make room [wkbsire]" % [g.mlog.who(ai.team), String(Defs.UNITS[f.kind]["name"]), int(SIRE_WAIT)])


## A Sire that has his nest: forget his wait.
static func sire_nested(ai, f: Unit) -> void:
	_no_nest.erase(f)
	if not _moved.is_empty():
		_release(ai)


## The moved turtles: walked out once up, let go after SIRE_HOLD s.
static func _release(ai) -> void:
	var g = ai.game
	var q := BroodNew.queen(g, ai.team)
	for t in _moved.keys():
		var e: Array = _moved[t]
		if e[1] != ai:
			continue
		if not is_instance_valid(t) or t.dead or g.clock - float(e[0]) > SIRE_HOLD:
			ai.held.erase(t)
			_moved.erase(t)
			continue
		if t.tesla_mode == "packed" and t.order != "move" and q != null:
			var away: Vector2 = t.position - q.position
			if away.length() < 1.0:
				away = Vector2.RIGHT
			t.cmd_move(t.position + away.normalized() * SIRE_AWAY * Defs.TILE)


# ------------------------------------------------------------------ table (block 6)
## TABLE: the Clockwork's reckoning of the Brood's army has a floor from a table of what a Brood has by that minute
## (AICwArmy.TABLES "brood": 10:00 1,900, 12:00 2,700). In this pairing's games (blocks 1-3, 30 games) the Brood's army
## was 2,430 at 10:00 and 3,805 at 12:00 (medians), so the push went out at about 1.1 times the real army and "pressed on
## to finish" with a reckoning of half the truth (dune sea r0 12:13: reckoned 1,795, the Brood had 3,870), met the
## Spitters in the open and was shot in the back on the way home. The floor is now the median of those games (lower than
## the old table before 9:00, where the Brood's army was smaller than it said).
const BROOD_TABLE := [[0.0, 0.0], [180.0, 150.0], [300.0, 450.0], [360.0, 600.0], [420.0, 800.0], [480.0, 1000.0],
	[540.0, 1600.0], [600.0, 2400.0], [660.0, 3200.0], [720.0, 3800.0]]


static func reckon_table(ai, tab: Array) -> Array:
	if on("table") and cw_v_brood(ai):
		return BROOD_TABLE
	return tab


# ------------------------------------------------------------------ brace (block 8)
## BRACE: most of the Clockwork's army died in the middle of the map (9:00-15:00, blocks 1-5: 2,190 of its fighters' deaths
## away from both bases against 1,040 at its base), when its push met the Brood's Spitter wave in the open (frostfang r1
## b02: the Brood attacked at 10:44, the push went at 10:46 and pulled back with half). Against the Brood, from BRACE_FROM
## to BRACE_TO, the push goes only as a COUNTER (AICwArmy._counter_ok: a Brood wave just broken on its gears) or at the
## supply cap; meanwhile the army waits on its gears, where the Winders mend it and the turrets help.
const BRACE_FROM := 480.0
const BRACE_TO := 960.0
const BRACE_SLACK := 12


static func brace(ai, army) -> bool:
	if not on("brace") or not cw_v_brood(ai):
		return false
	var g = ai.game
	if g.clock < BRACE_FROM or g.clock > BRACE_TO:
		return false
	if g.supply_used(ai.team) >= g.max_supply(ai.team) - BRACE_SLACK:
		return false
	army.say("holds on its gears: against the Brood it waits for its wave and counter-attacks after it [wkbbrace]", "wkbbrace", 60.0)
	return true


# ------------------------------------------------------------------ stuck (block 9)
## STUCK: a written Clockwork build that does no step for 60 s with 1,000 cogs banked hands over to the shared rules
## (AIClockwork._stuck_hand_over). Against the Brood that fired 17 times in blocks 1-6, mostly in the Owl raids build at
## 5:00-7:15, with 1,000-2,500 cogs in the bank by then (greenhold r0 b06: 1,317 cogs at 6:27, the army 820, then the
## Brood's 37 Raptors at 6:49 killed 32 Winders by 8:00). Against the Brood it now hands over after STUCK_T s with
## STUCK_BANK cogs.
const STUCK_T := 20.0
const STUCK_BANK := 450


static func stuck_t(ai, t: float) -> float:
	return STUCK_T if on("stuck") and cw_v_brood(ai) else t


static func stuck_bank(ai, b: int) -> int:
	return STUCK_BANK if on("stuck") and cw_v_brood(ai) else b


# ------------------------------------------------------------------ pends (block 11)
## PENDS: the Pendulum is the Clockwork's best killer against the Brood (blocks 1-5: ~3,100 of the Brood's Raptors and
## Tyrant Challengers to Pendulums, 1,800 to Clock Soldiers who are 10 times as many), and its blades cut Spitters (light)
## for x1.5 too once they reach them; it had 3-9 (AICwBrood: one for every 5 others, up to 8), with Tension the limit.
## Against the Brood: one for every PENDS_PER others, up to PENDS_MAX, and the Mainspring at every Clocktower (`springs`)
## for the Tension.
const PENDS_PER := 3
const PENDS_MAX := 12


static func pend_target(ai, others: int, t: int) -> int:
	if not on("pends") or not cw_v_brood(ai) or t <= 0:
		return t
	return clampi(2 + others / PENDS_PER, 2, PENDS_MAX)


# ------------------------------------------------------------------ works (block 12)
## WORKS: against the Brood the Clockwork had ONE Light Works until 6:00-8:30 (blocks 1 and 9: the second at 5:10-8:33,
## ashford r1 b09 none until 10:32), so its army could not grow faster than one Clock Soldier every 16 s through the
## Brood's timing attacks of 6:00-7:00 (28-37 supply of Raptors: 20-58 Winders lost in those games). One Works makes
## about 260 cogs of army a minute while the Clockwork earns 800-1,000 at 6:00. Against the Brood its second Light Works
## from WORKS2_AT, a third from WORKS3_AT (one going up at a time, with the cogs at hand and room for its supply).
const WORKS2_AT := 240.0
const WORKS3_AT := 390.0


static func more_works(ai) -> void:
	if not on("works") or not cw_v_brood(ai):
		return
	var g = ai.game
	var want := 1
	if g.clock >= WORKS3_AT:
		want = 3
	elif g.clock >= WORKS2_AT:
		want = 2
	var have: int = ai._mine(ai._works()).size()
	if have == 0 or have >= want or ai._busy_building(ai._works()):
		return
	var cost := int(Defs.BUILDINGS[ai._works()]["cost"])
	if ai._gold() < cost + 30:
		ai._reserve = maxi(ai._reserve, cost + 30)        # (saved for, like the tech: the Winders and the army wait a moment)
		return
	ai._construct(ai._works())
	if g.mlog and ai._busy_building(ai._works()):
		g.mlog.add("%s lays Light Works %d against the Brood's timing [wkbworks]" % [g.mlog.who(ai.team), have + 1])


## The Works is due and its cogs are short: the Winders wait (AIClockwork._train_workers) so the cogs gather for it.
static func works_wait(ai) -> bool:
	if not on("works") or not cw_v_brood(ai):
		return false
	var g = ai.game
	var want := 3 if g.clock >= WORKS3_AT else (2 if g.clock >= WORKS2_AT else 1)
	var have: int = ai._mine(ai._works()).size()
	if have == 0 or have >= want or ai._busy_building(ai._works()):
		return false
	return ai._gold() < int(Defs.BUILDINGS[ai._works()]["cost"]) + 30
