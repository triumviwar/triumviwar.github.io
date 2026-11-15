extends RefCounted
## THE CROWN'S ARMY ON TIME (crown-coach-army, docs/crown-coach-army.md; the owner's Hollowfen watch 2026-11-15 00:28, Hard
## OPTIMAL v Hard OPTIMAL 0.38.1: at 4:00 the Crown had 3 Musketeers (180) to the Clockwork's 4 Clock Soldiers, at 5:00 5
## to 8, at 6:00 3 to 11). The batch before the change: against the Clockwork the Barracks stood idle two thirds of the
## time from 1:30 to 6:00 (the labourers, the Cottages and the steps took every coin first), its first Musketeer came at
## 3:00-3:30 for want of powder (the Mill kept ONE hand while nothing trained: a deadlock in AICrown._mill_feedback), and the
## opening's army caps (8 supply on the Balloon plan) held it while the enemy's army doubled.
## What this does (the Crown computer, Normal and up, the new computer; `-- crownarmy:off` plays as before):
##  1. THE ARMY CLOCK: from FROM to UNTIL the army (with what trains) is kept at SHARE of the army a Hard computer of the
##     enemy's faction usually has LEAD s from now (TABLE, measured: the median of its OPTIMAL army in games against the
##     Crown), or SHARE_SEEN of what our scout saw if that is more. behind() says when it is not.
##  2. While behind(), with a Barracks that has room and can train a Musketeer (idle_barracks): in the opening a labourer
##     waits for the soldier (AICrown._soldiers_first), the opening's army cap does not hold, the soldiers start at once if
##     the plan's "army" step has not come yet, the next step's gold leaves the soldier's price (step_release), the natural's
##     palisade does not take the gold first (AICrown.wall_first) and no Church is bought for a wall slot (slot_waits).
##  3. POWDER FOR THE FIRST MUSKETEERS: while behind, the plan's Powder Mill step comes now (mill_first), the Mill takes three
##     hands while a Barracks waits for powder, and a Musketeer may come out with his bayonet while the Mill starts (dry_ok);
##     in every matchup, a Barracks idle with a Musketeer's gold but not his powder counts as using the powder
##     (powder_wait, AICrown._mill_feedback), so the Mill's crew grows.
## Gated by matchup: the clock plays against the Clockwork and the Crown (TABLE has no Brood row: against the Brood the
## Crown has its own reckoning, AICrown.army_behind / vb_line_short).
## Design: docs/design_principles.md 1 (fairness: no numbers change, the computer only spends its gold in time).

const FROM := 150.0             # (s) not before this (the opening's first labourers and the Barracks itself)
const SHARE := 0.6              # of the usual enemy army (0.75 was measured on 0.38.5; 0.6 on 0.38.11 kept more of the
                                # economy: the doc's batches)
const SHARE_SEEN := 0.6         # of what our scout saw lately (when it is more than the table)
const MIN_LABS := 10            # never with fewer labourers than this (a hall's first Farm's hands)
const UNTIL := 390.0            # (s) and not after this: the clock is for the first push (it reaches our base at 5:30-8:30,
                                # mean 6:40-6:50); after it the plan's own army rules (army_lags) hold, as a clock that kept
                                # the labourers waiting all game lost the late game (15:00 batch: L 5 -> 10, docs)
const LEAD := 45.0              # (s) the clock looks this far ahead: a soldier trains in 15 s and walks to his post, and the
                                # enemy's push is at our base before its army stops growing (the batch: it arrives at 6:40-8:20
                                # with 1,150 against our 980)
## The usual army of a Hard OPTIMAL computer against the Crown at each time [s, value] (crown-coach-army's baseline batch,
## 0.38.1, 16 games each: the median at the minute)
const TABLE := {
	"clockwork": [[0.0, 0.0], [180.0, 0.0], [240.0, 150.0], [300.0, 400.0], [360.0, 700.0], [420.0, 1100.0], [480.0, 1600.0], [600.0, 2400.0], [720.0, 3000.0]],
	"crown": [[0.0, 0.0], [180.0, 0.0], [240.0, 120.0], [300.0, 250.0], [360.0, 400.0], [420.0, 600.0], [480.0, 850.0], [600.0, 1300.0]],
}

var ai                          # AICrown
var lags_hook := OS.get_cmdline_user_args().has("crownarmy:lags")  # (AICrown.army_lags also behind the clock: a study switch)
var until := UNTIL              # (study switch `-- crownarmy:until=900`)
var share := SHARE              # (study switch `-- crownarmy:share=0.9`)
var room := ROOM                # (study switch `-- crownarmy:room=1`)
var off := OS.get_cmdline_user_args().has("crownarmy:off")
var clock_off := OS.get_cmdline_user_args().has("crownarmy:noclock")    # (the clock off, the powder fix kept: a study switch)
var lead_off := OS.get_cmdline_user_args().has("crownlead:off")    # (the clock without its look ahead: the WIP of 03:45)
var behind_t := 0.0             # (the report) seconds it was behind
var _last := -1.0
var _cache_t := -1.0
var _cache := false
var said := -99.0


func _init(owner) -> void:
	ai = owner
	for a in OS.get_cmdline_user_args():
		if a.begins_with("crownarmy:share="):
			share = float(a.split("=")[1])
		elif a.begins_with("crownarmy:until="):
			until = float(a.split("=")[1])
		elif a.begins_with("crownarmy:room="):
			room = int(a.split("=")[1])


func active() -> bool:
	if off or clock_off or not ai.on or ai.difficulty < 1 or ai.peaceful:
		return false
	var foe: int = ai._foe()
	return foe >= 0 and TABLE.has(ai.game.faction_of(foe))


## The army it wants now (0: none yet).
func want() -> float:
	var g: Game = ai.game
	var foe: int = ai._foe()
	if foe < 0:
		return 0.0
	var tab: Array = TABLE.get(g.faction_of(foe), [])
	if tab.is_empty():
		return 0.0
	var w: float = share * ai._lerp_table(tab, g.clock + (0.0 if lead_off else LEAD))
	var seen: float = ai.ch.foe_known() if ai.ch != null else 0.0
	w = maxf(w, SHARE_SEEN * seen)
	return maxf(0.0, w - 0.5 * float(g.stats[ai.team]["value_killed"]))


## Our army's value with what trains in the Barracks and the Foundries.
func have() -> float:
	var g: Game = ai.game
	var v := 0.0
	for u in g.army(ai.team):
		if not u.dead and u.has_attack():
			v += float(g.unit_value(u))       # (the balloons, the wagons and the horses are not soldiers)
	for b in ai._mine("barracks") + ai._mine("foundry"):
		for k in b.queue:
			if Defs.UNITS.has(k) and k != "observation_balloon" and k != "balloon":
				v += float(Defs.UNITS[k].get("cost", 0))
	return v


## The army is behind the clock (looked at at most twice a second).
func behind() -> bool:
	if not active():
		return false
	var g: Game = ai.game
	if g.clock < FROM or g.clock > until:
		return false
	if absf(g.clock - _cache_t) < 0.5:
		return _cache
	_cache_t = g.clock
	var labs: int = g.workers(ai.team).size()
	var w := want()
	_cache = labs >= MIN_LABS and w >= float(Defs.UNITS["musketeer"]["cost"]) and have() < w      # (a Musketeer's worth at least)
	if _cache:
		if _last >= 0.0:
			behind_t += minf(2.0, g.clock - _last)
		_last = g.clock
		if g.clock - said > 60.0:
			said = g.clock
			ai.say("the army on time: %d of army (with what trains) against the %d it wants by now (%d%% of a Hard %s's usual army): soldiers before more labourers" % [int(have()), int(w), int(share * 100.0), g.faction_of(ai._foe()).capitalize()])
	else:
		_last = -1.0
	return _cache


## A Barracks stands idle with a Musketeer's gold but not his powder (the Mill's crew should grow: AICrown._mill_feedback).
func powder_wait() -> bool:
	if off or not ai.on:
		return false
	if ai._res2() >= float(Defs.ammo_load("musketeer")):
		return false
	if ai._gold() < int(Defs.UNITS["musketeer"]["cost"]):
		return false
	if not (ai.bo_army or ai.bo_done):
		return false
	return ai._mine("barracks").any(func(b: Building) -> bool: return b.built and b.queue.is_empty())


## The gold the opening's next step leaves to the soldiers while behind (AICrown._think_stage 2): a Musketeer's price for
## each idle Barracks, once the soldiers train (bo_army) and no rush plan's riders come first.
func step_release() -> int:
	if not ai.bo_army or ai.bo_army_first:
		return 0
	return idle_barracks() * int(Defs.UNITS["musketeer"]["cost"])


## The built Barracks standing idle that could train a Musketeer now: its powder is in the bank (AICrownAmmo.musket_ok; the
## gold is what the clock frees). One waiting for powder does not count: the labourers then go on (on 0.38.10, with the
## Mills' hands sent to the Farms by the economy's rule, counting it held both the labourers and the soldiers: 123 s of
## the first 6 minutes waiting for powder, the army half of before at 8:00).
## A Barracks with fewer than ROOM soldiers queued has room. ROOM 2 (a second soldier queued before a labourer) kept more
## soldiers early but cost 14% of the income at 8:00 on 0.38.11 (docs); 1: an empty Barracks only.
const ROOM := 1


func idle_barracks() -> int:
	var n := 0
	for b in ai._mine("barracks"):
		if b.built and b.queue.size() < room and ai.am.musket_ok(b, "musketeer"):
			n += 1
	return n


## No Church bought for the natural's wall slot while the army is behind (AIExpandWall: a Church at 5:20 took two and a
## half Musketeers' gold before the Clockwork's first push).
func slot_waits(kind: String) -> bool:
	return kind == "church" and behind()


## THE MILL BEFORE ITS STEP (AICrown._bo_tick): behind the clock, with a Barracks built and no Powder Mill (nor its site), the
## opening's own Powder Mill step (still to come in `steps`) is laid now. Not on a plan without one (the Horseman rush), nor
## while its riders come first.
func mill_first(steps: Array) -> bool:
	if ai.bo_army_first or not ai._mine("powder_mill").is_empty():
		return false
	if not ai._mine("barracks").any(func(b: Building) -> bool: return b.built):
		return false
	return steps.any(func(st: Dictionary) -> bool: return String(st.get("do", "")) == "build" and String(st.get("k", "")) == "powder_mill")


## A MUSKETEER WITH HIS BAYONET NOW (AICrownAmmo.musket_ok, the owner's ammunition rule: trained with gold only he comes out
## with no shots and fills up at a reloading point when the powder comes): behind the clock, with a Powder Mill laid or
## standing but under a Musketeer's load in the bank. The Economy plan's Mill stood at 3:45 and its first Musketeer came at
## 5:35, 450 gold in the bank at 4:00 waiting for 10 powder while the Clockwork's push walked over. `-- crownarmy:nodry` off.
var dry_off := OS.get_cmdline_user_args().has("crownarmy:nodry")


func dry_ok() -> bool:
	if dry_off or not behind():
		return false
	if ai._res2() >= float(Defs.ammo_load("musketeer")):
		return false
	return not ai._mine("powder_mill").is_empty()
