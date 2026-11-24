class_name AICrownBroodLate   # (used by preload: the class cache may not know it)
extends RefCounted
## THE CROWN AGAINST THE BROOD, LATE GAME (crown-brood-late, the owner 2026-11-24, from two filmed games Crown OPTIMAL v Brood
## OPTIMAL, Hard, Greenhold seed 11; docs/crown_brood_late.md). The Crown COMPUTER only, against the Brood only (the caller
## checks the faction, `vs_brood` the rest); no unit, price or rule number changed. Three parts, each with its own switch:
## `-- cbl<name>:off` / `:on`; `-- cbl:off` plays as before this job. The parts KEPT are on by default (KEPT).
##  1. GUNS SET BEFORE THE ATTACK (`cblguns`): the press waits for its guns (it went with none: 8:33, 26 men, 0 guns, killed
##     1,475 for 1,800); the siege push marches with a rider out in front as its EYES; a Brood force seen near the march while
##     the guns are limbered BRACES the push: the line halts on HOLD, the guns come up behind it and unlimber, and only then
##     does the push set up against that force (it set up at contact, the guns still limbered: "5 guns near, 0 set at contact").
##  2. FILL THE SUPPLY CAP (`cblcap`): see cap_* below (the cause found in the games, docs/crown_brood_late.md).
##  3. NO EMPTY HOME (`cblhome`): from GUARD_FROM a push or a wave leaves a HOME GUARD sized to the Brood army it knows (the
##     nearest Musketeers, a gun of three), and the siege push comes home when a Brood force heads for our buildings that the
##     army at home WITHOUT the push cannot beat (the push's own rule counted the push itself as "home").
## Design: docs/design_principles.md 1 (the computer plays the player's own tools well) and 2 (retreat: a lost battle is a lost
## territory, not a lost game).

const KEPT: Array[String] = ["guns", "cap", "home"]

static var _args: PackedStringArray = OS.get_cmdline_user_args()
static var _n := {}             # team -> {counter -> n} (qa_match's result.json "crown_ai")


## Is part `name` on?
static func on(name: String) -> bool:
	if _args.has("cbl:off") or _args.has("cbl%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("cbl%s:on" % name)


## A Crown computer (Normal and up) facing a Brood, with part `name` on.
static func vs_brood(ai, name: String) -> bool:
	return on(name) and ai.on and ai.difficulty >= 1 and ai._foe_is("brood")


static func count(team: int, k: String, by := 1) -> void:
	if not _n.has(team):
		_n[team] = {}
	_n[team][k] = int(_n[team].get(k, 0)) + by


static func counters(team: int) -> Dictionary:
	var o := {}
	var d: Dictionary = _n.get(team, {})
	for k in d:
		o["cbl_" + k] = d[k]
	return o


static func _alive(u) -> bool:
	return u != null and is_instance_valid(u) and not u.dead


# ================================================================== 1. the guns set before the attack

const PRESS_GUNS := 2           # guns at home before the press goes (one a Field Cannon at least)
const PRESS_GUN_WAIT := 50.0    # (s) ... waited for this long at most
static var _press_wait_t := {}  # team -> clock the press first waited for its guns
const EYE_D := 330.0            # (px) the eyes ride this far ahead of the line toward the goal
const EYE_BACK := 220.0         # (px) a Brood soldier this near the eyes: they ride back to the guns
const BRACE_D := 560.0          # (px) a Brood force seen this near the line's middle while the guns are limbered: brace
const BRACE_MIN := 150.0        # (value) ... worth this much at least ...
const BRACE_SHARE := 0.12       # ... or this share of the push
const BRACE_SEEN := 4.0         # (s) a Brood soldier seen this lately counts (the eyes report it)
const BRACE_GUN_R := 700.0      # (px) the guns this near the line are the push's main body
const BRACE_UP := 210.0         # (px) a gun farther than this from the line's middle comes up first
const BRACE_GUN_BACK := 110.0   # (px) ... to this far behind the line on its trail
const BRACE_MAX := 14.0         # (s) a brace lasts this long at most (a gun that cannot set: the push goes on as before)
const BRACE_COOL := 10.0        # (s) after a brace that met nothing, none for this long
const ARMY_HOLD_D := 620.0      # (px) a braced push stays set against a Brood force this near (the usual 510 let it limber
                                # and roll on while the swarm stood just out of sight)
static var _brace := {}         # AICrownSiege -> {"t0", "cool"}


## AICrownBroodFix.press_push asks: the press may go with the guns at home? (false: it waits for them)
static func press_guns_ok(ai, siege, home: Array) -> bool:
	if not vs_brood(ai, "guns"):
		return true
	var g := 0
	var c := 0
	for u in home:
		if u.kind == "cannon":
			c += 1
			g += 1
		elif u.kind == "mortar":
			g += 1
	if g >= PRESS_GUNS and c >= 1:
		return true
	# (it waits PRESS_GUN_WAIT s at most from the first think the press could have gone: a gun takes its horse, and a
	# trial game waited from 8:52 to 11:00 for one while the Brood grew: then the press goes as before)
	var since: float = float(_press_wait_t.get(ai.team, -1.0))
	if since < 0.0:
		_press_wait_t[ai.team] = ai.game.clock
	elif ai.game.clock - since > PRESS_GUN_WAIT:
		count(ai.team, "press_gun_gaveup")
		return true
	count(ai.team, "press_gun_waits")
	if int(_n[ai.team]["press_gun_waits"]) % 10 == 1:
		siege.say("the press waits for its guns: %d at home, it wants %d" % [g, PRESS_GUNS])
	return false


## The push's eyes on the march: its first rider rides EYE_D ahead of the line toward `goal`, back to the guns when the
## Brood is near it. Returns the rider (the march's own rider loop leaves it alone) or null.
static func eye(siege, line: Array, mid: Vector2, goal: Vector2) -> Unit:
	if not vs_brood(siege.ai, "guns") or goal == Vector2.INF:
		return null
	var riders := line.filter(func(u: Unit) -> bool: return u.kind == "cuirassier" and u.hp > 0.5 * u.max_hp)
	if riders.is_empty():
		return null
	var dir := goal - mid
	if dir.length() < 80.0:
		return null
	dir = dir.normalized()
	var to: Vector2 = mid + dir * EYE_D
	var e: Unit = riders[0]
	for r in riders:
		if r.position.distance_to(to) < e.position.distance_to(to):
			e = r
	var near: Array = siege._visible_foes(e.position, EYE_BACK).filter(func(o: Unit) -> bool: return not o.is_worker() and not o.is_air())
	if not near.is_empty():
		var back: Vector2 = siege._behind(BRACE_GUN_BACK)
		if e.position.distance_to(back) > 60.0 and (e.order != "move" or e.order_point.distance_to(back) > 50.0):
			e.cmd_move(back)
		return e
	if e.position.distance_to(to) > 70.0 and (e.order != "move" or e.order_point.distance_to(to) > 60.0):
		e.cmd_move(to)
		count(siege.ai.team, "eye_orders")
	return e


## The Brood force seen lately within `r` of `p` (the computer's own memory of what it saw: AICrownHold._seen): [value, nearest].
static func _seen_near(ai, p: Vector2, r: float) -> Array:
	var v := 0.0
	var best := Vector2.INF
	if ai.ch == null:
		return [0.0, best]
	for u in ai.ch._seen:
		var e: Array = ai.ch._seen[u]
		if ai.game.clock - float(e[0]) > BRACE_SEEN:
			continue
		if not is_instance_valid(u) or u.dead or u.is_worker() or u.is_air():
			continue
		var q: Vector2 = u.position if ai.game.is_visible_to(ai.team, u.position) else e[1]
		if q.distance_to(p) < r:
			v += float(e[2])
			if best == Vector2.INF or q.distance_to(p) < best.distance_to(p):
				best = q
	return [v, best]


## THE BRACE (AICrownSiege._march and _siege_set ask first; true: it took the push this think). A Brood force seen near the
## line while the push's guns are limbered: the line halts, the guns come up and unlimber; once they are set the push sets up
## against that force (AICrownSiege._set_up).
static func brace(siege, line: Array, guns: Array, mid: Vector2) -> bool:
	if not vs_brood(siege.ai, "guns"):
		return false
	var ai = siege.ai
	var game: Game = siege.game
	var b: Dictionary = _brace.get(siege, {})
	var near_guns := guns.filter(func(g: Unit) -> bool: return g.position.distance_to(mid) < BRACE_GUN_R)
	if near_guns.is_empty():
		_brace.erase(siege)
		return false
	var s: Array = _seen_near(ai, mid, BRACE_D)
	var fv: float = s[0]
	var pv: float = siege._value(siege.men.keys())
	if fv < maxf(BRACE_MIN, BRACE_SHARE * pv):
		if not b.is_empty() and b.has("t0"):
			_brace[siege] = {"cool": game.clock + BRACE_COOL}
		return false
	var packed := near_guns.filter(func(g: Unit) -> bool: return g.tesla_mode != "deployed")
	if packed.is_empty():
		if b.has("t0"):
			# the guns are set: the push sets up against the force
			_brace[siege] = {"cool": game.clock + BRACE_COOL}
			var foes: Array = siege._visible_foes(mid, BRACE_D).filter(func(o: Unit) -> bool: return not o.is_worker() and not o.is_air())
			if not foes.is_empty():
				var a: Unit = foes[0]
				for f in foes:
					if f.position.distance_to(mid) < a.position.distance_to(mid):
						a = f
				count(ai.team, "brace_sets")
				siege._set_up(a, mid)
				return true
		return false
	if not b.has("t0"):
		if game.clock < float(b.get("cool", -1.0)):
			return false
		b = {"t0": game.clock}
		_brace[siege] = b
		count(ai.team, "braces")
		siege.say("braces: a Brood force (%d) %d px off and its guns limbered: the line halts, the guns set up" % [int(fv), int((s[1] as Vector2).distance_to(mid))])
	elif game.clock - float(b["t0"]) > BRACE_MAX:
		_brace[siege] = {"cool": game.clock + BRACE_COOL}
		count(ai.team, "brace_timeouts")
		return false
	# the line halts (on HOLD it still fires at what comes in reach); the riders by the guns
	var gmid: Vector2 = siege._mid(near_guns)
	for u in line:
		if u.kind == "cuirassier":
			if u.target == null and u.position.distance_to(gmid) > 120.0 and u.order != "move":
				u.cmd_move(gmid + Vector2(randf_range(-60, 60), randf_range(-60, 60)))
			continue
		if u.target == null and u.order != "hold":
			u.cmd_hold()
	for g in packed:
		if g.tesla_mode != "packed":
			continue
		if g.position.distance_to(mid) > BRACE_UP:
			var to: Vector2 = siege._behind(BRACE_GUN_BACK)
			if g.order != "move" or g.order_point.distance_to(to) > 50.0:
				g.cmd_move(to)
		else:
			g.cmd_deploy()
	return true


## THE BOUNDS (AICrownSiege._march asks, every order think; true: it gave the line's and the guns' orders). The brace alone
## did not set the guns before contact (out of home, 3-7% of the guns near were set when the fight began, as before): a Brood
## soldier is first seen at a musket's sight (256 px), and a Raptor covers that before a gun unlimbers. So near the Brood
## (a Brood soldier seen lately, a Rootmaw known, or the march's goal within DANGER_D) the push goes forward in BOUNDS, as
## guns and foot do: the guns stand set; the line walks on toward the goal but no man goes more than COVER ahead of the set
## guns (he halts on HOLD there); when the line stands at that edge, the rearmost set gun limbers, rolls up to BOUND_BACK
## behind the line and sets again, one gun at a time (with one gun, the line waits while it moves). Whatever comes at the
## line meets it with guns set behind it.
const DANGER_D := 950.0         # (px) the Brood this near the line's middle: the push goes in bounds
const DANGER_SEEN := 25.0       # (s) a Brood soldier seen this lately counts
const DANGER_HOLD := 15.0       # (s) in bounds this long after the last danger
const COVER := 230.0            # (px) the line's men at most this far ahead of the set guns (a gun reaches 430)
const BOUND_BACK := 100.0       # (px) a gun rolls up to this far behind the line's middle
const BOUND_EDGE := 50.0        # (px) the line at COVER less this: the next gun goes up
static var _bound := {}         # AICrownSiege -> {"until": clock, "moving": {gun: spot}}


static func _danger(siege, mid: Vector2, goal: Vector2) -> bool:
	var ai = siege.ai
	var game: Game = siege.game
	if goal != Vector2.INF and goal.distance_to(mid) < DANGER_D:
		return true
	if ai.ch != null:
		for u in ai.ch._seen:
			var e: Array = ai.ch._seen[u]
			if game.clock - float(e[0]) <= DANGER_SEEN and (e[1] as Vector2).distance_to(mid) < DANGER_D:
				return true
	for u in ai._maws_seen.keys():
		if is_instance_valid(u) and not u.dead and u.position.distance_to(mid) < DANGER_D:
			return true
	return false


static func bounds(siege, line: Array, guns: Array, mid: Vector2, goal: Vector2, eye: Unit) -> bool:
	var ai = siege.ai
	if not vs_brood(ai, "guns") or goal == Vector2.INF:
		return false
	var game: Game = siege.game
	var st: Dictionary = _bound.get(siege, {})
	var near_guns := guns.filter(func(g: Unit) -> bool: return g.position.distance_to(mid) < BRACE_GUN_R)
	if near_guns.is_empty():
		_bound.erase(siege)
		return false
	if _danger(siege, mid, goal):
		if st.is_empty():
			st = {"moving": {}}
			count(ai.team, "bounds")
			siege.say("goes on in bounds: the Brood is near, the guns stand set and the line keeps within their cover")
		st["until"] = game.clock + DANGER_HOLD
		_bound[siege] = st
	elif st.is_empty() or game.clock > float(st.get("until", 0.0)):
		_bound.erase(siege)
		return false
	var dir := goal - mid
	if dir.length() < 1.0:
		return false
	dir = dir.normalized()
	var side := Vector2(-dir.y, dir.x)
	var moving: Dictionary = st["moving"]
	for g in moving.keys():
		if not _alive(g) or not near_guns.has(g):
			moving.erase(g)
	var set_guns := near_guns.filter(func(g: Unit) -> bool: return g.tesla_mode == "deployed" and not moving.has(g))
	# the guns: a moving gun rolls to its spot and sets there; a limbered gun not moving sets where it stands (near the line)
	# or rolls up first
	for g in near_guns:
		if moving.has(g):
			var sp: Vector2 = moving[g]
			if g.tesla_mode == "deployed":
				moving.erase(g)
			elif g.tesla_mode == "packed":
				if g.position.distance_to(sp) < 50.0:
					g.cmd_deploy()
				elif g.order != "move" or g.order_point.distance_to(sp) > 40.0:
					g.cmd_move(sp)
			continue
		if g.tesla_mode == "packed":
			if g.position.distance_to(mid) > COVER:
				var sp2: Vector2 = siege._spot(mid - dir * BOUND_BACK + side * randf_range(-60.0, 60.0))
				moving[g] = sp2
				g.cmd_move(sp2)
			else:
				g.cmd_deploy()
	# the line: on toward the goal, none more than COVER ahead of the set guns
	var foot := line.filter(func(u: Unit) -> bool: return u.kind != "cuirassier" and u != eye)
	var front := -INF
	if set_guns.is_empty():
		for u in foot:
			if u.target == null and u.order != "hold":
				u.cmd_hold()
	else:
		var gm: Vector2 = siege._mid(set_guns)
		for u in foot:
			var proj: float = (u.position - gm).dot(dir)
			front = maxf(front, proj)
			if proj > COVER:
				if u.target == null and u.order != "hold":
					u.cmd_hold()
			elif u.order in ["idle", "hold"] or u.order_point.distance_to(goal) > 120.0:
				u.cmd_move(goal + Vector2(randf_range(-50, 50), randf_range(-50, 50)), true)
		# the line at the edge of the cover: the rearmost set gun goes up (one at a time; all of them set first)
		if front >= COVER - BOUND_EDGE and moving.is_empty() and set_guns.size() == near_guns.size():
			var back: Unit = set_guns[0]
			for g in set_guns:
				if (g.position - gm).dot(dir) < (back.position - gm).dot(dir):
					back = g
			var sp3: Vector2 = siege._spot(mid - dir * BOUND_BACK + side * randf_range(-60.0, 60.0))
			moving[back] = sp3
			back.cmd_move(sp3)
			count(ai.team, "bound_steps")
	# the riders by the guns
	var gmid: Vector2 = siege._mid(near_guns)
	for u in line:
		if u.kind == "cuirassier" and u != eye and u.target == null and u.position.distance_to(gmid) > 120.0 and u.order != "move":
			u.cmd_move(gmid + Vector2(randf_range(-60, 60), randf_range(-60, 60)))
	return true


## AICrownSiege._siege_set: a braced push set against a Brood force keeps it while it stands this near (else it would
## limber and roll on while the swarm waits just out of sight).
static func army_hold_d(siege) -> float:
	return ARMY_HOLD_D if vs_brood(siege.ai, "guns") else 0.0


# ================================================================== 2. fill the supply cap

## (the cause, docs/crown_brood_late.md: not the Cottages and not gold banked: the bank stays under 100 from 10:00 and a
## Barracks "stands idle for want of gold"; the Crown's labourers grow with its halls (AICrown.owner_lab_cap, the halls'
## saturation: 58-99 at 16:00-18:00) and from 12:00 the Brood's Raptors kill about 40 of them a game, so the gold of the
## late game goes on labourers who die walking, on their halls and Farms again, while the army sits at 60-70 supply.)
## And in a quarter of the games the POWDER ran dry from 13:00-14:00 (0 banked) while the gold piled up (1,000-5,000) and
## the army was not rebuilt: 4-8 hands on 4 Mills with thousands of saltpetre left. So:
##  a. from LABS_FROM, against the Brood, the labourers stop at LATE_LABS: every coin past that goes to the army;
##  b. from MILLS_FROM the Mill crew (AICrownMillCrew, on by default against the Clockwork only) works against the Brood
##     too: when the army wants powder, every Mill is crewed toward its full 6.
const LABS_FROM := 660.0        # (s) from 11:00
const LATE_LABS := 60
const MILLS_FROM := 600.0       # (s) from 10:00


## AICrownMillCrew.enabled asks: the Mill crew on against the Brood now?
static func mills_on(ai) -> bool:
	return vs_brood(ai, "cap") and ai.game.clock >= MILLS_FROM


## The most labourers the Crown trains now (-1: no ceiling from this part).
static func lab_top(ai) -> int:
	if not vs_brood(ai, "cap") or ai.game.clock < LABS_FROM:
		return -1
	if ai.game.workers(ai.team).size() >= LATE_LABS and ai.game.clock >= float(ai.get_meta("cbl_labs_said", -99.0)):
		ai.set_meta("cbl_labs_said", ai.game.clock + 60.0)
		count(ai.team, "labs_capped")
		if ai.game.mlog:
			ai.game.mlog.add("%s's labourers stop at %d against the Brood: the gold goes to the army (%d/%d supply)" % [
				ai.game.mlog.who(ai.team), LATE_LABS, ai.game.supply_used(ai.team), int(ai.game.players[ai.team]["cap"])])
	return LATE_LABS


# ================================================================== 3. no empty home

const GUARD_FROM := 540.0       # (s) from 9:00
const GUARD_MAX := 0.35         # the guard at most this share of the army going
const GUARD_EST := 0.5          # the guard worth the Brood army seen lately, or this share of the clock's reckoning
const RECALL_K := 1.0           # the push comes home: the Brood coming worth this many times the army at home without it ...
const RECALL_PAD := 150.0       # ... plus this
const RECALL_SHARE := 0.3       # ... and this share of the push at least


## The guard a push or a wave leaves at home: the units of `army` (Musketeers nearest our front first, then one gun when
## there are three) worth what the Brood army known calls for. {} when none is wanted.
static func guard_of(ai, army: Array) -> Dictionary:
	if not vs_brood(ai, "home") or ai.game.clock < GUARD_FROM:
		return {}
	var total := 0.0
	for u in army:
		total += float(Game.unit_value(u))
	var want := minf(GUARD_MAX * total, maxf(float(ai.ch.foe_known()), GUARD_EST * float(ai.foe_estimate())))
	if want <= 0.0:
		return {}
	var front: Vector2 = ai._front()
	var musk := army.filter(func(u: Unit) -> bool: return Defs.MUSKETS.has(u.kind))
	musk.sort_custom(func(a: Unit, b: Unit) -> bool: return a.position.distance_to(front) < b.position.distance_to(front))
	var keep := {}
	var v := 0.0
	var guns := army.filter(func(u: Unit) -> bool: return u.kind == "cannon")
	if guns.size() >= 3:
		guns.sort_custom(func(a: Unit, b: Unit) -> bool: return a.position.distance_to(front) < b.position.distance_to(front))
		keep[guns[0]] = true
		v += float(Game.unit_value(guns[0]))
	for u in musk:
		if v >= want:
			break
		keep[u] = true
		v += float(Game.unit_value(u))
	return keep


## AICrownSiege._go: the push leaves its guard home (the push's _c1kb_keep holds it out of the joins).
static func push_guard(siege, home: Array) -> Array:
	var keep := guard_of(siege.ai, home)
	if keep.is_empty():
		return home
	siege._c1kb_keep = keep
	count(siege.ai.team, "push_guards")
	count(siege.ai.team, "guard_units", keep.size())
	siege.say("leaves a home guard: %d units against the %d of Brood it knows" % [keep.size(), int(siege.ai.ch.foe_known())])
	return home.filter(func(u: Unit) -> bool: return not keep.has(u))


## AI._army (through AICrown.late_ready): the wave's ready men without the guard (recomputed every few s while no wave is out).
static func wave_ready(ai, ready: Array) -> Array:
	if not vs_brood(ai, "home") or ai.game.clock < GUARD_FROM:
		return ready
	if not ai._attacking and ai.game.clock >= float(ai.get_meta("cbl_guard_t", -99.0)):
		ai.set_meta("cbl_guard_t", ai.game.clock + 5.0)
		ai.set_meta("cbl_guard", guard_of(ai, ready))
	var keep: Dictionary = ai.get_meta("cbl_guard", {})
	if keep.is_empty():
		return ready
	return ready.filter(func(u: Unit) -> bool: return not keep.has(u))


## AICrownSiege._lost: the push comes home for its base ("" while it need not).
static func home_call(siege, mid: Vector2) -> String:
	var ai = siege.ai
	if not vs_brood(ai, "home"):
		return ""
	var dfn = ai.defence()
	if dfn == null:
		return ""
	var coming: float = float(dfn._coming)
	if coming <= 0.0 and ai._threat() == Vector2.INF:
		return ""
	coming = maxf(coming, float(ai.ch.foe_near()) if ai._threat() != Vector2.INF else 0.0)
	var home := 0.0
	for u in ai.game.army(ai.team):
		if siege.men.has(u) or u.dead or not u.has_attack() or u.kind == "powder_wagon" or ai._raiders.has(u):
			continue
		if ai._attacking and ai._wave_set.has(u):
			continue
		home += float(Game.unit_value(u))
	var now: float = siege._value(siege.men.keys())
	if coming < home * RECALL_K + RECALL_PAD or coming < now * RECALL_SHARE:
		return ""
	# (the push itself nearer the Brood coming than our buildings are: it is in the way already)
	if dfn._home_d(mid) < 18.0 * Defs.TILE:
		return ""
	count(ai.team, "home_calls")
	return "the Brood heads for our buildings (%d coming) and the army at home without the push (%d) cannot beat it" % [int(coming), int(home)]
