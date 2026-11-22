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
	# (its whole army: the Siege push's men are on an errand and not in `army`; block 2 never hunted for that, the push
	# being out with most of the army whenever the Clockwork was beaten down)
	var mine := 0.0
	for u in ai.game.army(ai.team):
		if AIHunt.fighter(u, ai.team):
			mine += float(Game.unit_value(u))
	var go := mine >= FINISH_OURS and theirs < mine * FINISH_SHARE and army.size() >= AIHunt.MIN_UNITS
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


# ------------------------------------------------------------------ reckon: the Clockwork's reckoning of today's Crown (block 3)

## Block 1: the Clockwork computer's pushes went out against the Crown "worth 3,970 against the 325 it reckons" and lost twice
## what they killed (26 pushes, lost 45,030, killed 22,455). Its reckoning of the Crown's army (AICwArmy.reckon) is the
## Crown row of AICwArmy.TABLES (flat at 1,500 from 12:00) less half of EVERYTHING it has killed since 0:00, or what it has
## seen lately if more; today's Crown computer has 1,700 at 12:00, 3,000 at 14:00 and 4,000 at 16:00 (the lower quarter of
## block 1). Here, against the Crown: the row goes on growing as today's Crown does (CROWN_ROW, block 1's lower quarter),
## and only what it killed in the last AICwArmy.KILL_RECENT s comes off it for a push going out (as against the Clockwork).
const CROWN_ROW := [[0.0, 0.0], [180.0, 60.0], [240.0, 200.0], [300.0, 330.0], [360.0, 480.0], [420.0, 800.0], [480.0, 1000.0],
	[600.0, 1200.0], [720.0, 1600.0], [780.0, 2000.0], [840.0, 2700.0], [960.0, 3600.0]]


static func cw_table(ai, tab: Array) -> Array:
	if on("reckon") and vs(ai, "clockwork"):
		return CROWN_ROW
	return tab


static func cw_recent(ai) -> bool:
	return on("reckon") and vs(ai, "clockwork")


# ------------------------------------------------------------------ decoy: the diversion goes back once

## Block 1, Hollowfen: the Springer timing's diversion (AISpringerRaid._decoy_tick) "goes back to the army (4 Clock Soldiers)"
## 410 times in 9 minutes: once the opening is over and the raid never leapt, the refill takes four Clock Soldiers from the
## army each think and the next think sends them back, so they walk to and fro between the army and the enemy's ramp. Here
## (the Clockwork computer against the Crown) once the diversion has gone back, it is not filled again.
static func decoy_back(raid) -> void:
	if on("decoy") and vs(raid.ai, "clockwork"):
		raid.set_meta("wcc_decoy_back", true)
		count(raid.ai, "decoy")


static func decoy_done(raid) -> bool:
	return raid.has_meta("wcc_decoy_back")


# ------------------------------------------------------------------ trade: the Clockwork's push leaves a losing fight

## Blocks 1-3: the Clockwork computer's pushes into the Crown lost about twice what they killed (lost 71,980, killed 39,015
## in block 1): they pull back only under GRIND (0.4) of what went out and joined, the "finishing" rule against the Crown
## keeps them in longer, and fresh groups walk out to join them one after another ("5 fresh units walk out to join it" while
## it lost 3,345 for 540, Ashford Crossing 12:51-14:32). Here (the Clockwork computer against the Crown) the push pulls
## back once it has lost TRADE_LOST of what went out and joined while it killed under TRADE_K of what it lost since it
## went out; the "finishing" rule no longer holds it in that case.
const TRADE_LOST := 0.3
const TRADE_K := 0.6


static func losing_trade(push, now: float) -> String:
	if not on("trade") or not vs(push.ai, "clockwork") or push.value_in <= 0.0:
		return ""
	var lost: float = push.value_in - now
	var killed := float(int(push.game.stats[push.team]["value_killed"]) - push.kill0)
	if lost >= push.value_in * TRADE_LOST and killed < lost * TRADE_K:
		count(push.ai, "trade")
		return "a losing trade: lost %d of the %d that went out and joined, killed %d" % [int(lost), int(push.value_in), int(killed)]
	return ""


# ------------------------------------------------------------------ labs: the Crown's labourers stop at LABS_MAX

## Blocks 1-4: the Crown computer reaches its 200 supply at 14:00-16:00 with 80-112 labourers (its halls' Farm posts and a
## few spare), so its army is 90-120 supply while 7,000-21,000 gold piles up unspent by 20:00; the Clockwork keeps 45-55
## Winders. Here (the Crown computer against the Clockwork) no labourer is trained past LABS_MAX: the supply goes to soldiers.
const LABS_MAX := 70


static func lab_cap(ai) -> int:
	if not on("labs") or not vs(ai, "crown"):
		return -1
	if ai.game.workers(ai.team).size() >= LABS_MAX and int(ai.game.clock) % 30 == 0:
		count(ai, "labs")        # (about once a 30 s look while it holds)
	return LABS_MAX


# ------------------------------------------------------------------ fresh: the Clockwork's next Clocktower on time

## Blocks 1-5: the Clockwork computer's Winders peak at ~52 at 10:00 and fall to ~43 by 20:00 while it goes from 3.6 to 5.6
## halls; its income a minute falls from ~2,300 (12:00-14:00) to ~2,000 (18:00-20:00) while the Crown's rises from ~2,800
## to ~3,400. Its presses run dry and the next Clocktower is only laid once fewer than 3 halls have a quarter of their brass
## left ("the brass at a Clocktower is spent" 11:30, the new one standing at 12:38; 14:20 and 15:30, Greenhold block 5):
## the posts empty and the Winders are not replaced in between. Here (the Clockwork computer against the Crown) a Clocktower
## counts as fresh only with FRESH_AT of its brass left (the Crown's own rule, AI.FRESH_CROWN) and it keeps one fresh hall
## for every 13 Winders up to NEED_MAX (3 before).
const FRESH_AT := 0.4
const NEED_MAX := 4


static func cw_fresh_at(ai, fresh_at: float) -> float:
	if on("fresh") and vs(ai, "clockwork"):
		return maxf(fresh_at, FRESH_AT)
	return fresh_at


static func cw_need(ai, need: int) -> int:
	if on("fresh") and vs(ai, "clockwork"):
		var n := maxi(need, mini(NEED_MAX, ceili(ai.game.workers(ai.team).size() / 13.0)))
		if n > need:
			count(ai, "fresh")
		return n
	return need


# ------------------------------------------------------------------ turret: a Ratchet Turret at each Clocktower's presses

## Blocks 1-7 (70 games): the Clockwork computer lost 5,538 Winders, about 79 a game, 2,014 of them to the Crown's riders
## ("P1 Crown's Horseman goes after the enemy workers" every minute or two from ~5:00): one or two Horsemen ride round its
## presses while the army stays on its gears, and its Winders are rebuilt over and over. The owner's rule for static
## defence (2026-11-03): not a build, but "a later security against harass so you can concentrate your army", at the
## expansions and worker lines. Here (the Clockwork computer against the Crown) from TURRET_FROM, once enemy riders have been
## seen, each built Clocktower with no Ratchet Turret within TURRET_NEAR of its presses gets one by them (one at a time,
## with the cogs to spare, never while gold is kept for a hall).
const TURRET_FROM := 300.0
const TURRET_NEAR := 300.0
const TURRET_SPARE := 100
const TURRET_EVERY := 5.0


static func outpost_turret(ai) -> void:
	if not on("turret") or not vs(ai, "clockwork"):
		return
	var game: Game = ai.game
	if game.clock < TURRET_FROM or game.clock < float(ai.get_meta("wcc_turret_t", 0.0)):
		return
	ai.set_meta("wcc_turret_t", game.clock + TURRET_EVERY)
	var k := Defs.CW_TURRET
	if not game.requirement_met(ai.team, k) or ai._busy_building(k) or ai._keeping():
		return
	if ai._gold() < game.build_price(ai.team, k) + TURRET_SPARE:
		return
	if not _riders_seen(ai):
		return
	var turrets: Array = ai._mine(k)
	for h in ai._halls():
		if not h.built:
			continue
		var presses: Array = game.buildings.filter(func(b: Building) -> bool: return b.team == ai.team and not b.dead and b.built \
			and (b.kind == Defs.GEAR_PRESS or b.kind == "mainspring") and b.center().distance_to(h.center()) < 420.0)
		if presses.is_empty():
			continue
		var mid := Vector2.ZERO
		for p in presses:
			mid += p.center()
		mid /= float(presses.size())
		if turrets.any(func(t: Building) -> bool: return t.center().distance_to(mid) < TURRET_NEAR):
			continue
		var spot := _gear_spot(ai, k, mid)
		if spot.x < 0:
			continue
		if ai._lay(k, spot, false) != null:
			count(ai, "turret")
			ai.note("a Ratchet Turret by a Clocktower's presses against the Crown's riders")
		return


## The Clockwork side has seen an enemy rider (a Horseman or Cuirassier, a Dragoon).
static func _riders_seen(ai) -> bool:
	if ai.has_meta("wcc_riders"):
		return true
	for u in ai.game.units:
		if u.team != ai.team and not u.dead and ai.game.hostile(u.team, ai.team) and Defs.RIDERS.has(u.kind) and ai.game.is_visible_to(ai.team, u.position):
			ai.set_meta("wcc_riders", true)
			return true
	return false


## A spot for a gear building of kind k as near tgt as there is room, meshing with one of our gear buildings on its level
## (AICwBuildsA._gear_spot).
static func _gear_spot(ai, k: String, tgt: Vector2) -> Vector2i:
	var game: Game = ai.game
	var lv := game.level_of(tgt)
	var gears: Array = game.buildings.filter(func(b: Building) -> bool: return b.team == ai.team and not b.dead and b.built \
		and GearNet.has_gear(b) and game.level_of(b.center()) == lv)
	gears.sort_custom(func(a: Building, b: Building) -> bool: return a.center().distance_to(tgt) < b.center().distance_to(tgt))
	var best := Vector2i(-1, -1)
	var bd := INF
	game.set_gear_pick(ai.team, k, false)
	var size: Vector2i = Defs.BUILDINGS[k]["size"]
	for g in gears.slice(0, 6):
		var c := GearEcon.room_spot(game, ai.team, k, [g], [], tgt, true, 14)
		if c.x < 0:
			continue
		var d := (Vector2(c) * Defs.TILE + Vector2(size) * Defs.TILE * 0.5).distance_to(tgt)
		if d < bd:
			bd = d
			best = c
	return best


# ------------------------------------------------------------------ flee: the Winders do not fight the Crown's riders

## Blocks 1-8 (79 games): 1,640 Winders died to the Crown's Horsemen with an ATTACK order, about 21 a game: the round-5 rule
## (AIRound5.worker_raid) groups the Winders by a press to hit one rider together when they outweigh the riders on paper,
## and the Horsemen (100 health, a sabre, the charge) cut them down; all the Clockwork's Winders killed about 4 units a game.
## Here (the Clockwork computer against the Crown) that rule is skipped: the shared rule takes the raid (the Winders flee to
## safety and the guards come, AIRound5.guard_workers).
static func winders_flee(ai) -> bool:
	if on("flee") and vs(ai, "clockwork"):
		count(ai, "flee")
		return true
	return false
