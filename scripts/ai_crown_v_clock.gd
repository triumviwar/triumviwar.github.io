class_name AICrownVClock
## THE CROWN COMPUTER AGAINST THE CLOCKWORK (crown-1000-clockwork, docs/crown_1000_clockwork.md; the owner 2026-11-19 07:26:
## "The Crown's computer is the weak one... 1000 crown games, every 10 games changing something"). Every change of that job
## is here, behind its own switch, and plays only when the Crown computer's enemy is the Clockwork (the sister job
## crown-1000-brood has the Brood). No number of the game changes: the computer's play only.
## A change KEPT by the study is on by default (KEPT) and `-- cvc<name>:off` turns it off; one not kept is off and
## `-- cvc:<name>` turns it on (to measure it again). `-- cvc:off` turns every one off.

## The kept changes (see the doc's log for each one's block and numbers)
const KEPT := {"pick": true, "hall2": true, "tech3": true, "dry": true}

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


static func pick_w() -> Dictionary:
	return PICK


# (crown-rule-cleanup, docs/crown_rule_cleanup.md: the job's twelve changes not kept (2 share, 3 hall3, 4 hold, 7 labs,
# 8 guns, 9 powder, 10 foundry2, 11 stand, 12 spend, 13 trade, 15 richlabs, and the pick's timingonly) were off by default and
# never acted; their code and switches are deleted. git history before 0.38.87 has them, docs/crown_1000_clockwork.md
# what each did.)


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


# ------------------------------------------------------------------ 14. no powder, a big bank (AI._produce, AICrownAmmo)

## Traced (Mirewood 9269 with `hall2`, 9:00-15:40): the powder bank was 0-22 from 9:00 while the gold grew 584 -> 9,127, the
## Barracks and the Foundries idle (the Mills grind less as their halls' saltpetre runs down, AICrown's Mills at 15% when it
## is spent); the supply filled with labourers to 200. In blocks 5, 14 and 15 the surviving Crowns sat on 5,000-14,700 gold
## at 16:00-18:00 with an army of 1,100-3,300. The shared production skips the Foundries when the powder is short
## (AI._produce: short_powder) though a Field Cannon costs gold only and fires no powder, and the Musketeers wait for a full
## load. Here against the Clockwork, with the powder under a Musketeer's load and DRY_BANK gold banked: the Foundries cast
## Field Cannons, and the Barracks train Musketeers with the bayonet (they fill up when the powder comes, the owner's rule).
const DRY_BANK := 400
static var dry_bank: int = _num("cvcdrybank=", DRY_BANK)      # (study switch `-- cvcdrybank=200`)


static func _num(key: String, dflt: int) -> int:
	for a in _args:
		if a.begins_with(key):
			return int(a.substr(key.length()))
	return dflt


static func dry_guns(ai) -> bool:
	return on("dry") and vs(ai) and ai._gold() >= dry_bank and not AICrownRules.dropped(ai, "cvcdry:off")


static func dry_musket(ai) -> bool:
	if not on("dry") or not vs(ai) or ai._gold() < dry_bank or AICrownRules.dropped(ai, "cvcdry:off"):
		return false
	if ai._res2() >= float(Defs.ammo_load("musketeer")):
		return false
	count(ai, "dry_musket")
	return true
