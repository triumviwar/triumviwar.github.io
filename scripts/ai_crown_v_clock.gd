class_name AICrownVClock
## THE CROWN COMPUTER AGAINST THE CLOCKWORK (crown-1000-clockwork, docs/crown_1000_clockwork.md; the owner 2026-11-19 07:26:
## "The Crown's computer is the weak one... 1000 crown games, every 10 games changing something"). Every change of that job
## is here, behind its own switch, and plays only when the Crown computer's enemy is the Clockwork (the sister job
## crown-1000-brood has the Brood). No number of the game changes: the computer's play only.
## A change KEPT by the study is on by default (KEPT) and `-- cvc<name>:off` turns it off; one not kept is off and
## `-- cvc:<name>` turns it on (to measure it again). `-- cvc:off` turns every one off.

## The kept changes (see the doc's log for each one's block and numbers)
const KEPT := {"pick": true, "hall2": true}

static var _args: PackedStringArray = OS.get_cmdline_user_args()


static func on(name: String) -> bool:
	if _args.has("cvc:off"):
		return false
	if _args.has("cvc:" + name):
		return true
	return bool(KEPT.get(name, false)) and not _args.has("cvc" + name + ":off")


## A change acted once more (result.json "crown_ai" "cvc", tools/qa_match.gd).
static func count(ai, name: String) -> void:
	var d: Dictionary = ai.get_meta("cvc", {})
	d[name] = int(d.get(name, 0)) + 1
	ai.set_meta("cvc", d)


## The Crown computer `ai` (AI / AICrown) plays the Clockwork.
static func vs(ai) -> bool:
	if ai == null or ai.game == null:
		return false
	var f: int = ai._foe()
	return f >= 0 and ai.game.faction_of(f) == "clockwork" and ai.game.faction_of(ai.team) == "crown"


# ------------------------------------------------------------------ 1. the pick (block 1)

## OPTIMAL's pick against the Clockwork, NORMAL or GREEDY read (docs/plan_matrix_crown.md: Timing x1.47 and Siege x1.38 of
## OPTIMAL's score, Siege survived 7 of 12; Balloon x0.92, Economy x0.91). Timing or Siege, half and half.
const PICK := {"timing": 1.0, "siege": 1.0}


# ------------------------------------------------------------------ 2. the army clock's share (AICrownArmy.want)

## The army clock (AICrownArmy) keeps 0.6 of a Hard Clockwork's usual army 45 s ahead until 6:30, soldiers before labourers;
## against the Clockwork the Crown's halls stood idle with free Farm posts most for that (docs/crown_build_stack.md). Here
## a smaller share, so more labourers come in the first minutes.
const SHARE := 0.4


# ------------------------------------------------------------------ 3. the third hall (AICrown.owner_hall_ok)

## The owner's rule for the third hall (40 labourers and an army of 0.7 a labourer, AICrown.owner_hall_ok) held it to a
## mean ~11:00 against the Clockwork's ~6:30 (block 0). Here: HALL3_LABS labourers and no enemy at our buildings.
const HALL3_LABS := 28


static func hall_ok(ai) -> bool:
	var labs: int = ai.game.workers(ai.team).size()
	var built: int = ai._halls().filter(func(h) -> bool: return h.built).size()
	return labs >= HALL3_LABS + 10 * maxi(0, built - 2) and not ai._defending() and ai._threat() == Vector2.INF


# ------------------------------------------------------------------ 4. no wave into a bigger army (AI._army)

## The Crown's waves against the Clockwork went out at 7:30-13:30 into a Clockwork army the same size or bigger and met it
## at its gears ("its whole army defends its base"): 1,610 -> 544 in two minutes on Cinder Steps (block 0). Here the wave
## waits until it is worth HOLD_K of the enemy army it reckons (AICrown.foe_reckon); the army at the supply cap still goes.
const HOLD_K := 1.3


static func hold_wave(ai, ready: Array) -> bool:
	if not on("hold") or not vs(ai) or not ai.has_method("foe_reckon"):
		return false
	var mine := 0.0
	for u in ready:
		if is_instance_valid(u) and not u.dead and u.has_attack():
			mine += float(ai.game.unit_value(u))
	var held: bool = mine < HOLD_K * float(ai.foe_reckon())
	if held:
		count(ai, "hold")
	return held


# ------------------------------------------------------------------ 5. the second hall next (AICrown.opt_switch)

## The Crown's second hall came at ~4:30-5:00 against the Clockwork's second Clocktower at ~2:30 (block 0): OPTIMAL's pick at
## ~1:30 puts its build order's hall step after the Foundry or the army (Timing's from two halls at 12 labourers behind the
## army step; the Siege and Balloon plans have none). Here the pick's next step is the second hall, at HALL2_LABS labourers.
const HALL2_LABS := 11


static func hall2_first(ai) -> void:
	if not on("hall2") or not vs(ai) or ai._halls().size() >= 2:
		return
	var plan: Array = ai._bo_plan
	var i0: int = ai.bo_i
	var st := {"do": "hall", "n": 2}
	for j in range(i0, plan.size()):
		if String((plan[j] as Dictionary).get("do", "")) == "hall":
			st = plan[j]
			plan.remove_at(j)
			break
	st["at"] = {"labs": HALL2_LABS}
	plan.insert(i0, st)
	count(ai, "hall2")


# ------------------------------------------------------------------ 6. the tech after the third hall (AICrown._mid_tick)

## The milestones put up a Church and an Armoury at 7:00-9:00 (block 0) while the third hall waited for 40 labourers. Here
## the Church and the Armoury wait for the third hall to stand.
static func tech_waits(ai, k: String, halls: int) -> bool:
	return (k == "church" or k == "armoury") and halls < 3 and on("tech3") and vs(ai)


# ------------------------------------------------------------------ 7. labourers before the army clock (AICrownCoach)

## The coach's LABOURERS FIRST (a labourer for an idle hall's free Farm post before any stage spends) yields to the army
## clock (AICrownCoach.army_short). Here, against the Clockwork, it yields only to an enemy at our buildings (the coach's own
## checks) until LABS_UNTIL, and after it while the labourers are under LABS_UNDER.
const LABS_UNTIL := 360.0
const LABS_UNDER := 30


static func labs_free(ai) -> bool:
	if not on("labs") or not vs(ai):
		return false
	return ai.game.clock < LABS_UNTIL or ai.game.workers(ai.team).size() < LABS_UNDER


# ------------------------------------------------------------------ 8. guns with the line (AICrown._gun_share)

## Blocks 1 and 3, the deaths before 15:00: the Crown's Field Cannons killed 606 Clockwork units for 58 lost (10 a gun), its
## Musketeers 1,118 for 539 (2 a man). Against the Clockwork the guns came three first, then one for every four of the whole
## army (AI._produce); against the Brood one for every GUN_SHARE_BROOD 4 Musketeers with the Barracks waiting for its gold.
## Here against the Clockwork the same rule with GUN_SHARE Musketeers a gun.
const GUN_SHARE := 3


# ------------------------------------------------------------------ 9. the powder piles up (AICrown._mill_farm_cap)

## (Block 11. Its premise was read from result.json's "res2", which is the powder ground so far, not the bank: the powder
## does not pile up; late it runs out, see 14.) With POWDER_BANK or more banked, the Mills keep one hand each and the rest
## go to the free Farm posts on live soil (no fewer than the cap less those posts). Not kept.
const POWDER_BANK := 250.0


static func mill_cap(ai, cap: int) -> int:
	if ai._res2() < POWDER_BANK:
		return cap
	var free := 0
	for f in ai._mine("farm"):
		if f.built and not f.barren():
			free += maxi(0, f.crew_max() - f.crew.size())
	var mills: int = ai._mine("powder_mill").filter(func(m) -> bool: return m.built).size()
	return maxi(mills, cap - free)


# ------------------------------------------------------------------ 10. the second Foundry sooner (AICrown._mid_tick)

## Block 9 (`guns`: the Barracks waiting for a gun's gold) thinned the line. The guns without the wait: a second Foundry as
## a milestone at FOUNDRY2_LABS labourers and two halls (the plans have it at 40-44 labourers and three halls), so more
## Field Cannons come from the shared rule (one for every four of the army, AI._produce) while the Barracks train on.
const FOUNDRY2_LABS := 26


static func mid_at(ai, k: String, n: int, at: Dictionary) -> Dictionary:
	if k == "foundry" and n == 2 and on("foundry2") and vs(ai):
		return {"labs": FOUNDRY2_LABS, "halls": 2}
	return at


# ------------------------------------------------------------------ 11. stand at the halls (AICrown.hold_beat, AICrownDefence)

## The decisive minutes are 9:00-13:00: in the games the Crown lost its army at 8:00 was the survivors' (1,052 v 1,223) and
## by 12:00 it was 980 v 1,544 with the Clockwork's 4,395 v 3,434 (blocks 0-9, 60 games). The stories: "holds the top of its
## ramp: against the force below (1,895) its army (1,575) goes down only at 2,464", "gathers its army at its hall, out of
## reach: the force at its buildings (2,260) is more than its army (2,280) can beat one by one", and the natural falls
## without a fight (Cinder Steps r1, lost in 7 of 9 blocks). Here against the Clockwork the army goes down to an expansion
## against a force up to 1/STAND_BEAT of itself (was 1/1.3) and musters only under STAND_MUSTER of the force (was 1.2).
const STAND_BEAT := 0.9
const STAND_MUSTER := 0.85


# ------------------------------------------------------------------ 12. a big bank late: more Barracks (AICrown stage 1)

## Blocks 5 and 14 (with `hall2`): the Crown's bank grew from 12:00 (a mean 811 at 12:00, 2,218 at 14:00, 3,280 at 16:00,
## 3,916 at 18:00) while its army fell (1,828 -> 1,227) and the Clockwork's pushes took its halls: the gold was there, the
## production was not (AICrown._scale_prod sits behind the milestones' think, which a threat at home or a hall's saving
## stops). Here, from SPEND_FROM, with SPEND_BANK banked and every Barracks built and busy, another Barracks goes down (one
## at a time, SPEND_MAX at most); the soldiers then come from the shared rules.
const SPEND_FROM := 480.0
const SPEND_BANK := 500
const SPEND_MAX := 8



static func spend(ai) -> void:
	if _args.has("cvc:dbg") and vs(ai) and ai.game.clock >= 540.0 and int(ai.game.clock) % 20 == 0:
		var qs := []
		for b in ai._mine("barracks") + ai._mine("foundry"):
			qs.append("%s%s:%d" % [b.kind.substr(0, 1), "" if b.built else "*", (b.queue as Array).size()])
		print("[cvc %d] gold %d res2 %d reserve %d saving %s hallres %s lags %s def %s threat %s attacking %s army %d sup %d/%d prod %s" % [int(ai.game.clock), ai._gold(), int(ai._res2()), ai._reserve, str(ai._saving), str(ai._hall_reserve), str(ai.army_lags()), str(ai._defending()), str(ai._threat() != Vector2.INF), str(ai._attacking), ai.game.army_value(ai.team), ai.game.supply_used(ai.team), int(ai.game.players[ai.team]["cap"]), " ".join(qs)])
	if not on("spend") or not vs(ai) or ai.game.clock < SPEND_FROM or ai._gold() < SPEND_BANK:
		return
	var bs: Array = ai._mine("barracks")
	if bs.size() >= SPEND_MAX or ai._busy_building("barracks"):
		return
	for b in bs:
		if not b.built or (b.queue as Array).size() < 2:
			return
	if ai._gold() < int(Defs.BUILDINGS["barracks"]["cost"]) + 100:
		return
	var n0: int = bs.size()
	ai._construct("barracks")
	if ai._mine("barracks").size() > n0:
		count(ai, "spend")
		ai.say("a big bank (%d): another Barracks (%d)" % [ai._gold(), n0 + 1])
		if ai.game.mlog:
			ai.game.mlog.add("%s has a big bank (%d gold): another Barracks (%d)" % [ai.game.mlog.who(ai.team), ai._gold(), n0 + 1])


# ------------------------------------------------------------------ 13. the wave pulls back sooner (AI._losing_trade)

## A test game (Frostfang 9236, `hall2`, 9:00-14:20): the wave was out the whole time, the army 3,020 at 11:40 and 1,175 at
## 14:00; a wave pulls back only when it lost 2.2 times what it killed over 30 s (AI.TRADE_RATIO, made for the Clockwork's
## own waves). Here the Crown's wave against the Clockwork pulls back at TRADE_RATIO.
const TRADE_RATIO := 1.3
const TRADE_MIN := 250.0


# ------------------------------------------------------------------ 14. no powder, a big bank (AI._produce, AICrownAmmo)

## Traced (Mirewood 9269 with `hall2`, 9:00-15:40): the powder bank was 0-22 from 9:00 while the gold grew 584 -> 9,127, the
## Barracks and the Foundries idle (the Mills grind less as their halls' saltpetre runs down, AICrown's Mills at 15% when it
## is spent); the supply filled with labourers to 200. In blocks 5, 14 and 15 the surviving Crowns sat on 5,000-14,700 gold
## at 16:00-18:00 with an army of 1,100-3,300. The shared production skips the Foundries when the powder is short
## (AI._produce: short_powder) though a Field Cannon costs gold only and fires no powder, and the Musketeers wait for a full
## load. Here against the Clockwork, with the powder under a Musketeer's load and DRY_BANK gold banked: the Foundries cast
## Field Cannons, and the Barracks train Musketeers with the bayonet (they fill up when the powder comes, the owner's rule).
const DRY_BANK := 400


static func dry_guns(ai) -> bool:
	return on("dry") and vs(ai) and ai._gold() >= DRY_BANK


static func dry_musket(ai) -> bool:
	if not on("dry") or not vs(ai) or ai._gold() < DRY_BANK:
		return false
	if ai._res2() >= float(Defs.ammo_load("musketeer")):
		return false
	count(ai, "dry_musket")
	return true
