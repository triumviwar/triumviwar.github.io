class_name AIWr1000CrownMirror
extends RefCounted
## WR1000, THE CROWN MIRROR (wr1000-crown-mirror, the owner 2026-11-22 01:29: a fresh win-rate study done as "1000 over 10s":
## 1000 games over six jobs, blocks of 10 games, one change of the computer's play a block; docs/wr1000_crown_mirror.md).
## This job's pairing is the Crown computer against the Crown computer (Hard OPTIMAL v Hard OPTIMAL, to 20:00). Every change
## here runs ONLY when a Crown computer faces another Crown (AICrown.mirror() != null), so the five sister jobs merge beside
## it. Each change has its own switch: `-- wcm<name>:on` / `:off`; `-- wcm:off` plays the mirror as before this job. The
## changes KEPT are on by default (KEPT); the rest were measured and not kept (the doc says what each did).

const KEPT: Array[String] = []

static var _args: PackedStringArray = OS.get_cmdline_user_args()


## Is change `name` on (in the mirror; the caller checks the matchup)?
static func on(name: String) -> bool:
	if _args.has("wcm:off"):
		return false
	if _args.has("wcm%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("wcm%s:on" % name)


## The Crown computer `ai` faces another Crown (the mirror's coach is alive): this job's changes may act.
static func mirror(ai) -> bool:
	return ai != null and ai.has_method("mirror") and ai.mirror() != null


## CHANGE `cut` (block 3): the crown-rule-cleanup's CUT against the Clockwork (the army clock and floor, the fight group,
## the hold; AICrownRules.CUT["clockwork"]) played in the mirror too. That job measured them as harm for the Crown against
## the Clockwork and left the mirror open ("cannot be measured by switching both sides"): here both sides switch and the
## measure is how decisive the games get. Called by AICrownRules.cut when the enemy is a Crown.
static func cut(name: String) -> bool:
	return on("cut") and (AICrownRules.CUT["clockwork"] as Array).has(name)


## CHANGE `finish` (block 4): THE SIDE FAR AHEAD FINISHES. Block 1, Greenhold r0: from 15:00 P2 had 4,170-6,320 of army
## against P1's 350-830 (P1 had lost 72 buildings) and the game was still not over at 20:00: the mirror coach's hunt over a
## token army (AICrownMirror.hunt_anyway) wants the enemy army under 450 whatever ours is, and P2's Siege push set up its
## guns against every Palisade, Gate and Barracks in turn ("sets up against a Palisade (306 px off)" 6 times in 3 minutes).
## Now the hunt (AIHunt: the whole army for the nearest enemy hall, then the last buildings) also goes on when our fighters
## are worth FINISH_MIN or more and the enemy's under FINISH_SHARE of them, and a Siege push out ends and joins it.
const FINISH_MIN := 1500.0
const FINISH_SHARE := 0.25


## (AICrown._hunt_anyway) true = hunt now.
static func hunt(ai, foe_t: int) -> bool:
	if not on("finish") or foe_t < 0:
		return false
	var game = ai.game
	var mine := 0.0
	var theirs := 0.0
	for u in game.units:
		if AIHunt.fighter(u, ai.team):
			mine += float(Game.unit_value(u))
		elif AIHunt.fighter(u, foe_t):
			theirs += float(Game.unit_value(u))
	return mine >= FINISH_MIN and theirs < mine * FINISH_SHARE


## (AICrownSiege.tick) true = the hunt is on: the push ends (its men join the hunt) and no new one goes.
static func siege_yields(sg) -> bool:
	if not on("finish") or sg.ai.mirror() == null or sg.ai.hunt == null or not sg.ai.hunt.on:
		return false
	if sg.state != "":
		sg._end("the hunt takes over: the enemy army is a fraction of ours")
	return true


## CHANGE `press2` (block 6): THE SIDE AHEAD PRESSES SOONER. The mirror coach's press (AICrownMirror.press, rule 8) sent a
## wave 0-3 times a side a game in blocks 1-2, and armies 3-4 times the enemy's sat at home (Frostfang r1, both blocks: P1
## 1,635 against 370-385 at 12:00, its first attack at 10:46 / 11:57). Its numbers made easier: from 7:00 (8:00), 1.15
## times the enemy army it reckons (1.3), 700 of army (900), 20 s after the last wave (25), the reckoning's floor 0.5 of
## the clock's table when the enemy army was seen lately (0.7) and 0.6 when not (0.8).
const PRESS2 := {"from": 420.0, "edge": 1.15, "min": 700.0, "cool": 20.0, "floor": 0.5, "stale": 0.6}


static func press_k(k: String, today: float) -> float:
	return float(PRESS2[k]) if on("press2") else today


## CHANGE `labcap`: FEWER LABOURERS, A BIGGER ARMY. In blocks 1-4 a side had ~50 labourers and ~1,800 of army at 12:00
## (24-30 Musketeers) and 60-80 labourers later, with 100-150 of its 200 supply used: the armies that meet are small beside
## the economy, the walls hold them, and the score ratio at 14:00 is within 25% in most games. The labourers' top (AICrown.
## owner_lab_cap: 48 on two halls, 14 more a hall after) comes down to LAB_TOP on two halls and LAB_PER_HALL a hall after;
## the supply and the gold go to the army.
const LAB_TOP := 40
const LAB_PER_HALL := 8


static func lab_top(ai, top: int, built: int) -> int:
	if not on("labcap") or not mirror(ai):
		return top
	return mini(top, LAB_TOP + LAB_PER_HALL * maxi(0, built - 2))


## Called every army think in the mirror (AICrown._army, after the mirror coach's press, before the shared waves).
static func army_tick(ai) -> void:
	if on("behind"):
		_behind(ai)
	if on("maxed"):
		_maxed_go(ai)


## CHANGE `behind`: THE SIDE BEHIND KEEPS ITS ARMY. Block 3, Dune Sea r0: P1, behind after a lost field fight at 8:49
## (1,410 killed for 2,410), went on sending what it had out in small groups ("fight at 11:15 out: killed 0, lost 175",
## 11:44 "killed 0, lost 625") and was beaten at 14:52 with its labourers down from 50 to 6. Now, from BEHIND_FROM, a side
## whose fighters are worth under BEHIND_SHARE of the enemy army seen in the last BEHIND_FRESH s (BEHIND_MIN of it at
## least) sends no new wave: it holds at home, behind its walls and on its high ground, and builds up until it is not
## behind any more (the bar it had comes back). A wave already out is not called back by this (the defence's own rules do).
const BEHIND_FROM := 480.0
const BEHIND_SHARE := 0.6
const BEHIND_FRESH := 90.0
const BEHIND_MIN := 600.0
const HOLD_BAR := 990             # (under 999: the Timing plan and AICrown read 999 as "no bar set yet")


static func _behind(ai) -> void:
	var game = ai.game
	var held: bool = ai.has_meta("wcm_behind_bar")
	var behind := false
	if game.clock >= BEHIND_FROM and ai.ch != null and game.clock - float(ai.ch._last_army_t) <= BEHIND_FRESH:
		var known: float = ai.ch.foe_known()
		if known >= BEHIND_MIN:
			var mine := 0.0
			for u in game.units:
				if AIHunt.fighter(u, ai.team):
					mine += float(Game.unit_value(u))
			behind = mine < known * BEHIND_SHARE
			if behind and not held and not ai._attacking:
				ai.set_meta("wcm_behind_bar", ai._attack_at)
				ai._attack_at = HOLD_BAR
				AICrownRules.fire(ai, "wcm_behind")
				if game.mlog:
					game.mlog.add("%s is behind (%d of army against the %d it saw): it keeps its army at home and builds up (wr1000 behind)" % [game.mlog.who(ai.team), int(mine), int(known)])
				return
	if held and not behind:
		ai._attack_at = int(ai.get_meta("wcm_behind_bar"))
		ai.remove_meta("wcm_behind_bar")
		if game.mlog:
			game.mlog.add("%s is not behind any more: its waves go again (wr1000 behind)" % game.mlog.who(ai.team))
	elif held:
		ai._attack_at = maxi(ai._attack_at, HOLD_BAR)


## CHANGE `maxed`: AT THE SUPPLY CAP, THE ARMY GOES. 52 of the 200 sides of blocks 1-10 reached the 200 cap (180 or more
## of it used), 42 of them with 1,000 gold or more banked. Block 10, Greenhold r1: P1 at 200/200 from 16:00 with 3,060 of
## army against 1,585, 95 labourers, its bank 4,687 at 16:00 and 16,971 at 20:00; its waves went out with 23 supply while
## up to five balloon parties of four Musketeers each flew at Farms. The enemy was beaten only at 20:00. Now, from
## MAXED_FROM, a side within MAXED_ROOM supply of a cap of MAXED_CAP or more with MAXED_BANK gold or more sends the army it
## has ready at once (the wave's bar comes down to it, as the mirror coach's press does: 85%) and forms no new balloon
## party (the Musketeers stay with the army). A Siege push already goes at the cap by itself (AICrownSiege: "big").
const MAXED_FROM := 600.0
const MAXED_ROOM := 8
const MAXED_CAP := 180
const MAXED_BANK := 600
const MAXED_SAY := 60.0


static func maxed(ai) -> bool:
	if not on("maxed") or not mirror(ai):
		return false
	var game = ai.game
	return game.clock >= MAXED_FROM and game.max_supply(ai.team) >= MAXED_CAP \
			and game.supply_used(ai.team) >= game.max_supply(ai.team) - MAXED_ROOM and int(game.players[ai.team]["gold"]) >= MAXED_BANK


static func _maxed_go(ai) -> void:
	if ai._attacking or ai.siege != null or ai.peaceful or not maxed(ai) or ai._threat() != Vector2.INF:
		return
	var game = ai.game
	var hz = ai.harass
	var ready: Array = game.army(ai.team).filter(func(u: Unit) -> bool: return not ai._raiders.has(u) and u.kind != "powder_wagon" \
			and not u.is_worker() and u.armed() and not ai._on_errand(u) and not (hz != null and hz.has(u)) and not ai._horse_coming(u))
	var sup: int = maxi(6, int(ai._army_supply(ready) * 0.85))
	if ai._army_supply(ready) < 12 or sup >= ai._attack_at:
		return
	ai._attack_at = sup
	AICrownRules.fire(ai, "wcm_maxed")
	if game.mlog and game.clock - float(ai.get_meta("wcm_maxed_said", -99.0)) > MAXED_SAY:
		ai.set_meta("wcm_maxed_said", game.clock)
		game.mlog.add("%s is at its supply cap with %d gold: the army it has ready goes now (%d supply) (wr1000 maxed)" % [game.mlog.who(ai.team), int(game.players[ai.team]["gold"]), sup])
