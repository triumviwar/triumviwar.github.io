class_name WkM
extends RefCounted
## WR1000, THE CLOCKWORK MIRROR (wr1000-clockwork-mirror, the owner 2026-11-22 01:29: a fresh win-rate study as "1000 over
## 10s", blocks of 10 games changing one thing in the computer's play each block; docs/wr1000_clockwork_mirror.md). The
## Clockwork computer (Hard OPTIMAL) against itself to 20:00 on 10 parity games. Every change here runs only when a Clockwork
## computer faces a Clockwork (mirror(ai, foe)), so the sister jobs of the other pairings merge beside it. Each change has
## its own switch: `-- wkm<name>:on` / `:off`; `-- wkm:off` plays the mirror as before this job. The changes KEPT are on by
## default (KEPT); the rest were measured and not kept (the doc says what each did).

const KEPT: Array[String] = []

static var _args: PackedStringArray = OS.get_cmdline_user_args()


## Is change `name` on (the caller checks the matchup with mirror())?
static func on(name: String) -> bool:
	if _args.has("wkm:off"):
		return false
	if _args.has("wkm%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("wkm%s:on" % name)


## A Clockwork computer (team t) against a Clockwork (team foe)?
static func mirror(game, t: int, foe: int) -> bool:
	return foe >= 0 and game.faction_of(t) == "clockwork" and game.faction_of(foe) == "clockwork"


## CHANGE "cap" (block 2). After a push that had to pull back the next one goes only worth 1.25 times it (AICwArmy.AFTER_FAIL).
## In the mirror that bar can never be met: both armies grow to the 200 supply cap with Clock Soldiers (~70-85 a supply), so a
## push of 7,315 that pulled back (having killed 4,590 for 4,415) asks 9,143 and the army sits at the cap worth 8,000 with 4,000-
## 6,000 cogs in the bank to 20:00 (Greenhold r0, block 1: P1 from 14:29). In the mirror the bar is waived when the army is
## (nearly) full, CAP_SUPPLY of supply in use or CAP_BANK cogs it cannot spend, or CAP_T s after that push came home; the push
## still needs its usual edge over the enemy army it reckons.
const CAP_SUPPLY := 180
const CAP_BANK := 1500
const CAP_T := 150.0


static func fail_waived(ai, army, mine: float) -> bool:
	var game = ai.game
	if not on("cap") or not mirror(game, ai.team, army._foe()):
		return false
	var why := ""
	if game.supply_used(ai.team) >= CAP_SUPPLY:
		why = "its army is full"
	elif int(game.players[ai.team]["gold"]) >= CAP_BANK:
		why = "its bank is full"
	elif game.clock - float(army._fail_t) >= CAP_T:
		why = "that push came home %d s ago" % int(game.clock - float(army._fail_t))
	if why == "":
		return false
	army.say("the last push's bar (%d) is waived: %s (worth %d)" % [int(army._fail_v * army.AFTER_FAIL), why, int(mine)], "wkmcap", 45.0)
	return true


## CHANGE "nospr" (block 3). OPTIMAL's NORMAL / UNKNOWN pick in the mirror is Balanced 3, Economy 2, Springer timing 1. The
## Springer timing switched to at 3:00 from the economy opening lays the Escapement and buys HIGH LEAP, a Clock Aviary and a
## Swift before any army: 240 worth at 5:00, 365 at 8:00 against the other side's 2,015 (Cinder Steps r0, block 1), and it lost
## all four games where it was picked (blocks 0 and 1, beaten at 11:17-13:31, a draw where it turned to Balanced). A lost game
## decided by a dice throw at 3:00 is no skill: in the mirror the pick is Balanced or Economy.
static func normal_w(w: Dictionary) -> Dictionary:
	if not on("nospr") or not w.has("springer"):
		return w
	var out := w.duplicate()
	out.erase("springer")
	return out


## CHANGE "raze" (block 4). A push that has won walks hall to hall as one block: on Ashford r1 (block 2) the push of 61 had
## nothing in front of it from 14:00 and took a Clocktower every 1:20 (12-23 s to break, a minute of walking between), the
## other side kept a hall at 20:00 and the game was a draw on paper with 8,330 against 0. In the mirror, a COMMITTED push
## worth RAZE_K times everything it can see or reckon of the enemy army (RAZE_MIN at least) splits its front into parties of
## RAZE_N or more, one at each enemy Clocktower (the nearest keeps the biggest), and each party breaks its hall at once. It
## joins up again once the enemy army is worth half of it (the usual march and retreat rules come back).
const RAZE_K := 3.0
const RAZE_MIN := 2500.0
const RAZE_N := 10
const RAZE_KEEP := 2.0          # (once split it stays so down to 2 times: in the test game it split and joined every 20 s)


static func raze(push) -> bool:
	var game = push.game
	if not on("raze") or not mirror(game, push.team, push.foe) or not push.committed:
		_raze_clear(push)
		return false
	var v: float = push._value(push.units)
	var rk: float = push.ai.army_g.reckon(true) if push.ai.get("army_g") != null and push.ai.army_g != null else 0.0
	var near: float = push._value(push._foes_near(push._front_centre(), 900.0))
	var foe_v := maxf(maxf(push.foe_mem(), near), rk)
	var split: bool = not (push.get_meta("wkm_raze", {}) as Dictionary).is_empty()
	if v < RAZE_MIN or v < foe_v * (RAZE_KEEP if split else RAZE_K):
		_raze_clear(push)
		return false
	var hall_kind: String = game.faction_hall(push.foe)
	var halls: Array = []
	for b in game.buildings:
		if b.team == push.foe and not b.dead and not b.ghost and b.kind == hall_kind:
			halls.append(b)
	var front: Array = push.units.filter(func(u: Unit) -> bool: return push._front_kind(u) or push._heavy(u))
	var k := mini(halls.size(), front.size() / RAZE_N)
	if halls.size() < 2 or k < 2:
		_raze_clear(push)
		return false
	var c: Vector2 = push._front_centre()
	halls.sort_custom(func(a, b) -> bool: return a.center().distance_to(c) < b.center().distance_to(c))
	halls = halls.slice(0, k)
	var of: Dictionary = push.get_meta("wkm_raze", {})
	for u in of.keys():
		if not is_instance_valid(u) or u.dead or not front.has(u) or not is_instance_valid(of[u]) or of[u].dead:
			of.erase(u)
	var per := {}
	for u in of:
		per[of[u]] = int(per.get(of[u], 0)) + 1
	# (the nearest hall gets what is left over: front.size() - (k - 1) * RAZE_N; the others RAZE_N each)
	var want := {}
	for i in halls.size():
		want[halls[i]] = (front.size() - (k - 1) * RAZE_N) if i == 0 else RAZE_N
	var free: Array = front.filter(func(u: Unit) -> bool: return not of.has(u) or not want.has(of[u]))
	for h in halls:
		while int(per.get(h, 0)) < int(want[h]) and not free.is_empty():
			free.sort_custom(func(a: Unit, b: Unit) -> bool: return a.position.distance_to(h.center()) < b.position.distance_to(h.center()))
			var u: Unit = free.pop_front()
			if of.has(u) and want.has(of[u]):
				per[of[u]] = int(per.get(of[u], 0)) - 1
			of[u] = h
			per[h] = int(per.get(h, 0)) + 1
	for u in free:
		of[u] = halls[0]
	for u in of:
		if u.target != of[u]:
			u.cmd_attack(of[u])
	push.set_meta("wkm_raze", of)
	push._note_once("wkmraze", "has won the field (worth %d against %d): it splits into %d parties, one at each of the enemy's nearest Clocktowers" % [int(v), int(foe_v), k], 40.0)
	return true


static func _raze_clear(push) -> void:
	if push.has_meta("wkm_raze") and not (push.get_meta("wkm_raze") as Dictionary).is_empty():
		push.set_meta("wkm_raze", {})
		push._note_once("wkmrazeend", "joins up again: the enemy army is back", 40.0)
