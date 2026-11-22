class_name AIWr1000BroodMirror
extends RefCounted
## WR1000, THE BROOD MIRROR (wr1000-brood-mirror, the owner 2026-11-22 01:29: a fresh win-rate study as "1000 over 10s",
## blocks of 10 games, ONE change of the computer's play a block; docs/wr1000_brood_mirror.md). The Brood computer (Hard
## OPTIMAL) against the Brood computer, games to 20:00 on the 6 parity maps. Every change here runs only when a Brood
## computer faces another Brood (the mirror: AIBroodNew._foe_is("brood")), so the sister jobs of the other pairings merge
## beside it. Each change has its own switch: `-- wbm<name>:on` / `:off`; `-- wbm:off` plays the mirror as before this job.
## The changes KEPT are on by default (KEPT); the rest were measured and not kept (the doc says what each did).

const KEPT: Array[String] = []

static var _args: PackedStringArray = OS.get_cmdline_user_args()


## Is change `name` on (in the mirror; the caller checks the matchup)?
static func on(name: String) -> bool:
	if _args.has("wbm:off"):
		return false
	if _args.has("wbm%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("wbm%s:on" % name)


## Is this Brood computer in the mirror (its enemy a Brood)?
static func mirror(ai) -> bool:
	return ai._foe_is("brood")


## The kills and losses of the last WINDOW s (value), kept once a second in ai.wbm["hist"]: [clock, killed, lost].
const WINDOW := 60.0


static func note(ai) -> void:
	if not mirror(ai):
		return
	var w: Dictionary = ai.wbm
	if ai.game.clock - float(w.get("note_t", -9.0)) < 1.0:
		return
	w["note_t"] = ai.game.clock
	var foe: int = ai._foe()
	var lost := int(ai.game.stats[foe]["value_killed"]) if foe >= 0 else 0
	var h: Array = w.get("hist", [])
	h.append([ai.game.clock, int(ai.game.stats[ai.team]["value_killed"]), lost])
	while h.size() > 2 and ai.game.clock - float(h[0][0]) > WINDOW:
		h.pop_front()
	w["hist"] = h


## [killed, lost] in the last WINDOW s.
static func recent(ai) -> Array:
	var h: Array = ai.wbm.get("hist", [])
	if h.size() < 2:
		return [0, 0]
	return [int(h[-1][1]) - int(h[0][1]), int(h[-1][2]) - int(h[0][2])]


# ------------------------------------------------------------------ block 2: THE COUNTER (`wbmcounter`)
## THE COUNTER-ATTACK (block 1's games: every wave at the enemy's home lost half or more to the defender's swamp, Sires and
## rooted creatures and pulled back; the defender then sat at home until its own army was at the cap and threw it in the
## same way, so the games see-sawed to 20:00). When the enemy has just broken a wave on its home (it killed COUNTER_KILL
## of the enemy army it had seen in the last minute, and lost under COUNTER_LOSS of what it killed) and its army is worth
## COUNTER_EDGE times what it reckons the enemy has left (the biggest army seen less what it killed since), it goes at
## once, whatever its cap and its plan's wave rules say: the enemy's army is at its smallest now.
const COUNTER_KILL := 0.4
const COUNTER_LOSS := 0.7
const COUNTER_EDGE := 1.3
const COUNTER_GAP := 90.0
const COUNTER_FROM := 360.0


static func counter(ai, army_v: float, sup: int) -> bool:
	if not on("counter") or not mirror(ai) or ai._attacking or sup < 12 or ai.game.clock < COUNTER_FROM:
		return false
	var w: Dictionary = ai.wbm
	if ai.game.clock - float(w.get("counter_t", -999.0)) < COUNTER_GAP:
		return false
	var kl := recent(ai)
	var killed := float(kl[0])
	var lost := float(kl[1])
	if ai.seen_army < 300.0 or killed < ai.seen_army * COUNTER_KILL or lost > killed * COUNTER_LOSS:
		return false
	var left := maxf(0.0, ai.seen_army - killed)
	if army_v < left * COUNTER_EDGE or ai._foe_near_home > army_v * 0.25:
		return false
	w["counter_t"] = ai.game.clock
	w["counters"] = int(w.get("counters", 0)) + 1
	ai.say("counter-attacks: it broke the enemy's wave (killed %d, lost %d), %d against the %d it reckons left" % [int(killed), int(lost), int(army_v), int(left)])
	return true


## The one hook in AIBroodNew._nb_army: true = its army goes now (a wave out of this job's rules), past the cap and plan rules.
static func go(ai, _q, army: Array, sup: int) -> bool:
	if not mirror(ai):
		return false
	return counter(ai, ai._value_of(army), sup)
