class_name AICrownVClock
## THE CROWN COMPUTER AGAINST THE CLOCKWORK (crown-1000-clockwork, docs/crown_1000_clockwork.md; the owner 2026-11-19 07:26:
## "The Crown's computer is the weak one... 1000 crown games, every 10 games changing something"). Every change of that job
## is here, behind its own switch, and plays only when the Crown computer's enemy is the Clockwork (the sister job
## crown-1000-brood has the Brood). No number of the game changes: the computer's play only.
## A change KEPT by the study is on by default (KEPT) and `-- cvc<name>:off` turns it off; one not kept is off and
## `-- cvc:<name>` turns it on (to measure it again). `-- cvc:off` turns every one off.

## The kept changes (see the doc's log for each one's block and numbers)
const KEPT := {}

static var _args: PackedStringArray = OS.get_cmdline_user_args()


static func on(name: String) -> bool:
	if _args.has("cvc:off"):
		return false
	if _args.has("cvc:" + name):
		return true
	return bool(KEPT.get(name, false)) and not _args.has("cvc" + name + ":off")


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
	return mine < HOLD_K * float(ai.foe_reckon())
