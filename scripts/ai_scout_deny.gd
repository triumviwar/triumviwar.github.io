class_name AIScoutDeny
extends RefCounted
## DENY THE SCOUT (the owner, 2026-11-18 11:42, watching Crown OPTIMAL v Brood OPTIMAL: "Why is the Brood not killing the
## labourer scouting? Denying scouting should also be a priority for all factions." The Crown's Labourer walked the Brood's
## base from 0:02 on and read it GREEDY at 1:30 while 16 Raptors stood by). Job scout-deny, docs/scout_deny.md.
##
## Every computer (the Crown's, the Clockwork's, the Brood's; Normal and up) looks each think for an enemy SCOUT in or near
## its base (within ZONE_R tiles of its buildings, its rooted creatures or its Mother): a worker (a Labourer, a Winder, a
## grub), an unarmed unit (a Messenger, a balloon), or a lone fast or flying soldier of little worth with no armed friend
## near it (a Horseman, a Raptor, a Swift on a scouting loop). It sends the nearest fit hunters after it: soldiers that can
## catch it (as fast, or a shooter already in reach) and can hit it (a flyer needs anti-air), at most MAX_PER a scout and
## MAX_ALL in all, never a whole army, never a unit out on a wave, in a defence, on an errand or rooted. Early, when no
## soldier can, one or two workers next to it go at a scout on foot (a short chase: WORKER_T). A hunter gives up when the
## scout is LEASH tiles past its base, after CHASE_T s, when the scout has been out of sight LOST_T s, or when enemy fighters
## stronger than the hunters are near it; then it goes back (soldiers to where they were taken from, workers to work).
## Armed intruders that are not scouts stay with the defence (AI._defend, AIBroodNew._nb_defend); the Brood leaves riders
## to its own anti-rider doctrine (no chase: AIBroodNew._nb_defend_riders).
##
## MEASURING SWITCH `scoutdeny:off`: plays as 0.38.61 (nobody is sent after a scout by this rule).

static var on := not OS.get_cmdline_user_args().has("scoutdeny:off")

const ZONE_R := 11.0            # (tiles) our base: this near one of our buildings, rooted creatures or the Mother
const LEASH := 6.0              # (tiles) a chase goes on only this far past our base
const CHASE_T := 30.0           # (s) a soldier's chase at most
const WORKER_T := 10.0          # (s) a worker's chase at most
const LOST_T := 3.0             # (s) the scout out of sight this long: it got away
const SEND_R := 30.0            # (tiles) hunters come from within this of the scout
const WORKER_R := 9.0           # (tiles) ... workers only from this near
const WORKERS_BY := 420.0       # (s) workers go at a scout only this early in the game (later it is the army's job)
const MAX_PER := 2
const MAX_ALL := 4
const ARMED_LONE_R := 16.0      # (tiles) ... an armed one with none this near
const LONE_R := 9.0             # (tiles) a soldier is a scout only with no armed friend this near
const SCOUT_SPEED := 88.0       # an armed scout is this quick ...
const SCOUT_VALUE := 180.0      # ... and worth no more than this (a Horseman, a Raptor, a Swift; not a Ticking Owl's raid)
const SLOW := 40.0              # an unarmed machine slower than this is no scout (the Great Winder)
const HUNTER_MIN := 50.0        # a hunter at least this quick (no Spring Ballista or Pendulum sent after a scout)
const CATCH := 0.85             # a hunter this quick against the scout's pace can cut a scout's loop off (AI._defend's rule)
const EVERY := 0.5              # (s) looked at at most this often
const COOL := 20.0              # (s) a scout that got away is left alone this long (unless it comes deeper in)

var ai = null                   # AI or AIBroodNew
var game: Game = null
var hunts := {}                 # prey Unit -> {"by": [Unit], "t0", "seen", "workers": bool, "name", "fac"}
var hunters := {}               # our Unit -> {"prey": Unit, "back": Vector2, "worker": bool}
var cool := {}                  # prey Unit -> clock until which it is left alone
var said: Array = []            # [clock, text] (tests and the study read it)
## counters for the study (tools/qa_match.gd writes them into result.json "scout_deny")
var n := {"seen": 0, "sent": 0, "killed": 0, "escaped": 0, "workers_sent": 0, "workers_lost": 0, "hunters_lost": 0, "none_fit": 0}
var kills: Array = []           # [clock, kind of the scout]
var _next := 0.0
var _seen_ids := {}             # prey instance id -> true (each scout counted once in "seen")
var _pts: Array = []            # this look's base points


func _init(a) -> void:
	ai = a
	game = a.game


func active() -> bool:
	return on and ai != null and game != null and ai.difficulty >= 1 and not ai.peaceful


func has(u: Unit) -> bool:
	return hunters.has(u)


## Is this enemy being hunted now? (AI._threat leaves an UNARMED scout to the hunters: no army is held at home and no hands
## are pulled off work for it. An armed one stays a threat for the defence as well: if the hunters are not enough, the
## defence's own answer still comes.)
func hunted(o: Unit) -> bool:
	return hunts.has(o) and not (hunts[o]["by"] as Array).is_empty() and (o.is_worker() or not _armed(o))


func _brood() -> bool:
	return ai is AIBroodNew


# ------------------------------------------------------------------ the look

func tick() -> void:
	if not active() or game.over:
		return
	if game.clock < _next:
		return
	_next = game.clock + EVERY
	_tidy()
	_pts = _base_points()
	if _pts.is_empty():
		return
	for o in _scouts():
		if hunts.has(o) or float(cool.get(o, -1.0)) > game.clock:
			continue
		_start(o)
	for o in hunts.keys():
		_follow(o)


func _tidy() -> void:
	for u in hunters.keys():
		if not is_instance_valid(u) or u.dead:
			var e: Dictionary = hunters[u]
			n["hunters_lost"] += 1
			if bool(e["worker"]):
				n["workers_lost"] += 1
			hunters.erase(u)
	for o in cool.keys():
		if not is_instance_valid(o) or o.dead or float(cool[o]) <= game.clock:
			cool.erase(o)


## Where our base is: our buildings, rooted creatures and the Mother.
func _base_points() -> Array:
	var out: Array = []
	if _brood():
		var q := BroodNew.queen(game, ai.team)
		if q != null:
			out.append(q.position)
		for u in game.units:
			if u.team == ai.team and not u.dead and BroodNew.ROOTERS.has(u.kind) and u.kind != BroodNew.QUEEN and BroodNew.rooted(u):
				out.append(u.position)
	for b in game.buildings:
		if b.team == ai.team and not b.dead:
			out.append(b.center())
	return out


## How far past our base a point is (0 or less: inside it).
func base_dist(p: Vector2) -> float:
	var best := INF
	for q in _pts:
		best = minf(best, (q as Vector2).distance_to(p))
	return best - ZONE_R * Defs.TILE


static func _spd(u: Unit) -> float:
	return maxf(float(u.d.get("speed", 60)), u.speed)


func _armed(o: Unit) -> bool:
	return not o.is_worker() and (o.has_attack() or Defs.MUSKETS.has(o.kind))


## The enemy scouts in or near our base, seen right now.
func _scouts() -> Array:
	var out: Array = []
	var raid := -1              # (-1 not looked yet, 0 no, 1 yes: enemy fighters in our base that are no scouts)
	for o in game.units:
		if o.dead or o.off_field or o.team < 0 or o.aboard != null or not game.hostile(o.team, ai.team):
			continue
		if not is_scout(o):
			continue
		if base_dist(o.position) > 0.0 or not game.is_visible_to(ai.team, o.position):
			continue
		if not _lone(o):
			continue                    # (a worker or a Winder with fighters about is an attack's escort: the defence's)
		if _armed(o):
			# (an armed scout only while no other enemy fighter is in our base or near it: the first Raptors of a wave
			# coming in strung out are the wave's, not scouts; clockwork-home's test lost its army's focus to them)
			if raid < 0:
				raid = 1 if _raid_on() else 0
			if raid == 1 or not _lone(o, ARMED_LONE_R):
				continue
		out.append(o)
	return out


## What a scout looks like from the outside (no peeking at the enemy's computer): a worker, an unarmed unit, or a quick
## soldier (or flyer) of little worth.
func is_scout(o: Unit) -> bool:
	if float(o.d.get("speed", 0)) <= 0.0 or o.kind == "horse" or o.kind == BroodNew.EGG or o.kind == BroodNew.PILE:
		return false
	if BroodNew.ROOTERS.has(o.kind) or BroodNew.is_father(o.kind):
		return false
	if o.is_worker():
		return true
	if not _armed(o):
		return float(o.d.get("speed", 0)) >= SLOW         # (a Messenger, a balloon, a Missionary; not a Great Winder)
	if float(Game.unit_value(o)) > SCOUT_VALUE:
		return false
	if _brood() and AIBroodNew.is_rider(o):
		return false                # (the Brood's own anti-rider doctrine: no chase, AIBroodNew._nb_defend_riders)
	return o.is_air() or float(o.d.get("speed", 60)) >= SCOUT_SPEED


## Enemy fighters in or by our base that are no scout (an attack, a raid: then no armed unit is taken for a scout).
func _raid_on() -> bool:
	var n_armed := 0
	for o in game.units:
		if o.dead or o.off_field or o.team < 0 or o.aboard != null or not game.hostile(o.team, ai.team) or not _armed(o):
			continue
		if base_dist(o.position) > LEASH * Defs.TILE or not game.is_visible_to(ai.team, o.position):
			continue
		n_armed += 1
		if n_armed >= 2 or not is_scout(o):
			return true
	return false


## No armed friend of the scout near it (else it is a raid: the defence's).
func _lone(o: Unit, r := LONE_R) -> bool:
	for f in game.units_near(o.position, r * Defs.TILE):
		if f != o and f.team == o.team and not f.dead and not f.off_field and _armed(f):
			return false
	return true


# ------------------------------------------------------------------ the hunters

## May this unit of ours be sent? (not on a wave, in a defence, on an errand, rooted, held...)
func is_free(u: Unit) -> bool:
	if hunters.has(u) or u.dead or u.off_field or u.aboard != null:
		return false
	if u.kind == "powder_wagon" or u.kind == Defs.GREAT_WINDER_KIND or u.kind == "cannon" or u.kind == "mortar" or u.kind == "balloon":
		return false
	if not u.has_attack() or u.order == "sacrifice":
		return false
	if _brood():
		if BroodNew.ROOTERS.has(u.kind) or BroodNew.is_father(u.kind) or u.moult_t >= 0.0 or BroodRoot.in_cocoon(u):
			return false
		if u == ai._scout or ai.held.has(u) or ai._def.has(u) or (ai._attacking and ai._wave.has(u)):
			return false
		if ai.has_method("maw_fighting") and ai.maw_fighting(u):
			return false
		return true
	if ai._on_errand(u) or ai._raiders.has(u) or ai._det.has(u):
		return false
	if ai._attacking and ai._wave_set.has(u):
		return false
	if ai.harass != null and ai.harass.has(u):
		return false
	if ai.scout != null and ai.scout.is_scout(u):
		return false
	if ai.r5 != null and ai.r5.busy(u):
		return false
	if "cav" in ai and ai.cav != null and ai.cav.has(u):
		return false
	if u.order == "attack" and u.target != null and is_instance_valid(u.target) and not u.target.dead:
		return false                # (in a fight already)
	return true


func _fit(u: Unit, o: Unit) -> bool:
	if not u.can_hit(o) or float(u.d.get("speed", 60)) < HUNTER_MIN:
		return false
	var d := u.position.distance_to(o.position)
	if d > SEND_R * Defs.TILE:
		return false
	if _spd(u) >= _spd(o) * CATCH:
		return true
	var r := float(u.d.get("range", 0))
	return r >= 120.0 and d <= r + 90.0          # (a shooter it already has in reach)


func _start(o: Unit) -> void:
	var id := o.get_instance_id()
	if not _seen_ids.has(id):
		_seen_ids[id] = true
		n["seen"] += 1
	if hunters.size() >= MAX_ALL:
		return
	var want := mini(MAX_PER, MAX_ALL - hunters.size())
	var pool: Array = []
	for u in game.army(ai.team):
		if is_free(u) and _fit(u, o):
			pool.append(u)
	pool.sort_custom(func(a: Unit, b: Unit) -> bool: return a.position.distance_squared_to(o.position) < b.position.distance_squared_to(o.position))
	var by: Array = pool.slice(0, want)
	var workers := false
	if by.is_empty() and not o.is_air() and game.clock < WORKERS_BY and (o.is_worker() or not _armed(o)):
		# (no soldier can: early, the hands next to it go at a scout on foot)
		var hands: Array = []
		for w in game.workers(ai.team):
			if _worker_free(w) and w.position.distance_to(o.position) < WORKER_R * Defs.TILE and w.can_hit(o):
				hands.append(w)
		hands.sort_custom(func(a: Unit, b: Unit) -> bool: return a.position.distance_squared_to(o.position) < b.position.distance_squared_to(o.position))
		by = hands.slice(0, want)
		workers = not by.is_empty()
	if by.is_empty():
		n["none_fit"] += 1
		cool[o] = game.clock + 4.0          # (look again soon: a hunter may come free)
		return
	var fac := String(game.faction_of(o.team)).capitalize()
	var name := String(Defs.UNITS[o.kind]["name"]) if Defs.UNITS.has(o.kind) else o.kind
	hunts[o] = {"by": by, "t0": game.clock, "seen": game.clock, "workers": workers, "name": name, "fac": fac}
	for u in by:
		hunters[u] = {"prey": o, "back": u.position, "worker": workers}
		if workers:
			u.set_meta("guard", true)
		u.cmd_attack(o)
	n["sent"] += 1
	if workers:
		n["workers_sent"] += by.size()
	_say("sends %d %s after the %s's scouting %s" % [by.size(), _names(by), fac, name])


func _worker_free(w: Unit) -> bool:
	if hunters.has(w) or w.dead:
		return false
	if w.order == "build" or w.keg or w.crate_site != null:
		return false
	if _brood():
		return w != ai._scout and w.order == "gather" and w.cocoon <= 0.0
	if ai._escort.has(w) or ai._held_worker(w) or (ai.scout != null and ai.scout.is_scout(w)) or ai._fled.has(w):
		return false
	return w.order == "gather" or w.order == "idle"


func _names(list: Array) -> String:
	var kinds := {}
	for u in list:
		var nm := String(Defs.UNITS[(u as Unit).kind]["name"])
		kinds[nm] = int(kinds.get(nm, 0)) + 1
	var parts: Array = []
	for k in kinds:
		parts.append(k + ("" if int(kinds[k]) == 1 or k.ends_with("s") else "s"))
	return " and ".join(parts)


# ------------------------------------------------------------------ the chase

func _follow(o: Unit) -> void:
	var h: Dictionary = hunts[o]
	var by: Array = (h["by"] as Array).filter(func(u) -> bool: return is_instance_valid(u) and not u.dead and hunters.has(u))
	h["by"] = by
	if not is_instance_valid(o) or o.dead:
		n["killed"] += 1
		kills.append([game.clock, String(h["name"])])
		_say("killed the %s's scouting %s at %s" % [h["fac"], h["name"], _mmss()])
		_end(o, "")
		return
	if o.off_field or o.aboard != null:
		_end(o, "it got away")
		return
	if game.is_visible_to(ai.team, o.position):
		h["seen"] = game.clock
	var why := ""
	if by.is_empty():
		why = "its hunters fell"
	elif game.clock - float(h["seen"]) > LOST_T:
		why = "out of sight"
	elif base_dist(o.position) > LEASH * Defs.TILE:
		why = "away past the leash"
	elif game.clock - float(h["t0"]) > (WORKER_T if bool(h["workers"]) else CHASE_T):
		why = "the chase took too long"
	elif _guarded(o, by):
		why = "its friends are near"
	if why != "":
		n["escaped"] += 1
		cool[o] = game.clock + COOL
		_say("lets the %s's scouting %s go (%s)" % [h["fac"], h["name"], why])
		_end(o, why)
		return
	for u in by:
		var cu := u as Unit
		if cu.order != "attack" or cu.order_target != o:
			cu.cmd_attack(o)


## Enemy fighters near the scout, more than the hunters are worth: no chase into an army.
func _guarded(o: Unit, by: Array) -> bool:
	var theirs := 0.0
	for f in game.units_near(o.position, LONE_R * Defs.TILE):
		if f != o and f.team == o.team and not f.dead and not f.off_field and _armed(f):
			theirs += float(Game.unit_value(f))
	if theirs <= 0.0:
		return false
	var mine := 0.0
	for u in by:
		mine += float(Game.unit_value(u))
	return theirs >= mine * 0.6


func _end(o, _why: String) -> void:
	var h: Dictionary = hunts.get(o, {})
	hunts.erase(o)
	for u in h.get("by", []):
		if not is_instance_valid(u) or u.dead or not hunters.has(u):
			continue
		var e: Dictionary = hunters[u]
		hunters.erase(u)
		_back(u, e)


## Back to where it was taken from: a soldier to its spot (the army's code takes it from there), a worker to work.
func _back(u: Unit, e: Dictionary) -> void:
	if bool(e["worker"]):
		u.set_meta("guard", false)
		if _brood():
			u.cmd_stop()                # (WORK finds a grub a Rootmaw)
		else:
			u.cmd_stop()
			ai._resume(u)
		return
	if _brood():
		var r: Vector2 = ai._rally if ai._rally != Vector2.INF else e["back"]
		u.cmd_move(r)
		return
	u.cmd_move(e["back"], true)


## Let everything go at once (the army needs its units: a wave, a big defence).
func release(u: Unit) -> void:
	if not hunters.has(u):
		return
	var o = hunters[u]["prey"]
	hunters.erase(u)
	if hunts.has(o):
		(hunts[o]["by"] as Array).erase(u)


func _mmss() -> String:
	return "%d:%02d" % [int(game.clock) / 60, int(game.clock) % 60]


func _say(msg: String) -> void:
	said.append([game.clock, msg])
	if game.mlog:
		game.mlog.add("%s %s" % [game.mlog.who(ai.team), msg])


## (tools/qa_match.gd) what it did, for result.json
func report() -> Dictionary:
	return {"n": n.duplicate(), "kills": kills.duplicate(), "said": said.slice(maxi(0, said.size() - 40))}
