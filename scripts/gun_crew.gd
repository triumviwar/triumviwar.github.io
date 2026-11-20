class_name GunCrew
extends RefCounted
## THE GUN CREWMAN (gun-crew-fetch, 2026-11-20; docs/gun_crew_fetch.md). The owner: "Horses are not supposed to go alone.
## Without a hauler the cannon operator should go from the foundry and get the horse on a leash back to the foundry."
##
## A Foundry entry that takes a horse (Field Cannon, Mortar, Powder Wagon: Defs.UNITS "needs_horse", not a rider) keeps a
## horse at a Horse Breeder (Game._reserve_horse). A Town Hall hauler brings it when one is free (Game.haul_dispatch).
## When none is, one GUN CREWMAN (Defs.UNITS.gun_crewman) comes out of the Foundry, walks to the breeder, waits there while
## the horse is still being bred, takes it on the haulers' leash (and the Foundry's other ready horses within HAUL.batch
## tiles, up to HAUL.horses), leads them back, hitches them by the Foundry (Game.hitch_horse) and goes back in.
##
## His job is a hauler's haul_job ({"k": "horse", "ph": "wait" | "fetch" | "deliver" | "home", "rid", "want"}), so the
## leash, the stuck-recovery and the hitching are the haulers' own (Unit._haul_horses with his Foundry as the "hall").
## Order "gun_fetch" (he takes no other); Unit.fetch_home is his Foundry. He can be attacked and killed: his horses stay
## where they are, still kept for their guns, and another crewman comes out after CREW_WAIT s (or a hauler takes over).
## A free hauler nearer to the horse than he is takes the job over (he goes back in). Cancelling the gun lets its horse go
## where it stands and sends him back. Not selectable (picking him picks his Foundry, Game.set_selection), not in any
## army or worker list, not saved (SaveGame: a new one comes out after a load). The Brood and the Clockwork have no horses.

const CREW_WAIT := 4.0         # s after a crewman of a Foundry is killed before the next one comes out


## A Foundry entry's horse (not a rider's: he fetches his own) for queue entry i of b, or 0.
static func entry_rid(b: Building, i: int) -> int:
	if i < 0 or i >= b.queue.size():
		return 0
	var k := String(b.queue[i])
	if b.is_research(k) or Defs.RIDERS.has(k) or not Defs.UNITS.has(k) or not Defs.UNITS[k].get("needs_horse", false):
		return 0
	return int(b.kit_at(i).get("rid", 0))


## Every crewman of side t.
static func crew_of_team(g: Game, t: int) -> Array:
	var out: Array = []
	for u in g.units:
		if u.team == t and not u.dead and u.kind == "gun_crewman":
			out.append(u)
	return out


## The crewman out for (or already holding) the horse of reservation `rid`, or null.
static func serving(g: Game, t: int, rid: int) -> Unit:
	for u in crew_of_team(g, t):
		if int(u.haul_job.get("rid", 0)) == rid:
			return u
		for h in (u.haul_job.get("want", []) as Array) + u.led:
			if is_instance_valid(h) and h.horse_rid == rid:
				return u
	return null


## Every Defs.HAUL.scan s (Game.haul_dispatch, after the haulers have had their pick): a crewman for each Foundry entry
## whose horse nobody brings; a free hauler nearer than a crewman takes his job over.
static func dispatch(g: Game, t: int) -> void:
	if g.faction_of(t) != "crown":
		return
	_hand_over(g, t)
	for b in g.buildings:
		if b.team != t or b.dead or not b.built or b.kind == "horse_breeder" or b.queue.is_empty():
			continue
		for i in b.queue.size():
			var rid := entry_rid(b, i)
			if rid == 0 or serving(g, t, rid) != null:
				continue
			var h := g.reserved_horse(t, rid)
			if h:
				if h.into == b or h.leader != null or Unit._claim_live(h):
					continue                 # (hitched here already, or a hauler has it)
			elif g.rid_breeder(t, rid) == null:
				continue                     # (no horse and none being bred: Game.fetch_reserved reserves a new one)
			if g.hauler_serves_rid(t, rid):
				continue                     # (a hauler is free to fetch it: Game.haul_dispatch)
			if float(b.get_meta("crew_t", -INF)) > g.clock:
				continue                     # (the last one was killed a moment ago)
			send(g, b, rid)


## Send a crewman out of Foundry b for reservation rid.
static func send(g: Game, b: Building, rid: int) -> Unit:
	var h := g.reserved_horse(b.team, rid)
	var br := g.rid_breeder(b.team, rid)
	var aim: Vector2 = h.position if h else (br.center() if br else b.center())
	var p := g.approach_point(b, aim)
	var u := g._add_unit("gun_crewman", b.team, p)
	u.fetch_home = b
	u.order = "gun_fetch"
	u.auto_work = false
	u.begin_haul({"k": "horse", "ph": "wait", "rid": rid, "want": []})
	if h and g.horse_unclaimed(h):
		_take(g, u, h)
	if g.mlog and not g._first_of.has("%d:gun_crew" % b.team):
		g._first_of["%d:gun_crew" % b.team] = true
		g.mlog.add("%s's first gun crewman went out of a %s to fetch a gun's horse (no hauler free)" % [g.mlog.who(b.team), String(b.d["name"])])
	return u


## He is going for horse h: it is claimed for him, with the Foundry's other ready horses within HAUL.batch tiles of it.
static func _take(g: Game, u: Unit, h: Unit) -> void:
	var want: Array = [h]
	h.claimed = u
	var b := u.fetch_home
	for i in b.queue.size():
		if want.size() >= int(Defs.HAUL["horses"]):
			break
		var rid := entry_rid(b, i)
		if rid == 0 or rid == h.horse_rid:
			continue
		var o := g.reserved_horse(u.team, rid)
		if o and g.horse_unclaimed(o) and not want.has(o) and serving(g, u.team, rid) == null \
				and o.position.distance_to(h.position) < float(Defs.HAUL["batch"]) * Defs.TILE:
			want.append(o)
			o.claimed = u
	u.haul_job["want"] = want
	u.haul_job["ph"] = "fetch"


## A free hauler nearer to the horse (or its breeder) than the crewman going for it takes it over; the crewman goes back.
static func _hand_over(g: Game, t: int) -> void:
	var crews := crew_of_team(g, t)
	if crews.is_empty() or g.haulers_of(t).is_empty():
		return
	var free: Array = g.haulers_of(t).filter(func(h: Unit) -> bool: return h.haul_job.is_empty() \
		or (String(h.haul_job.get("ph", "")) == "home" and h.led.is_empty() and not h.keg))
	for u in crews:
		if free.is_empty():
			return
		var ph := String(u.haul_job.get("ph", ""))
		if not u.led.is_empty() or (ph != "wait" and ph != "fetch"):
			continue
		var want: Array = u.haul_job.get("want", [])
		var at := Vector2.INF
		if not want.is_empty() and is_instance_valid(want[0]):
			at = (want[0] as Unit).position
		else:
			var br := g.rid_breeder(t, int(u.haul_job.get("rid", 0)))
			if br:
				at = br.center()
		if at == Vector2.INF:
			continue
		var best: Unit = null
		var bd := INF
		for h in free:
			var dd: float = h.position.distance_to(at)
			if dd < bd:
				bd = dd
				best = h
		if best and bd + 2.0 * Defs.TILE < u.position.distance_to(at):
			free.erase(best)
			go_home(u)


## His job is over (cancelled, handed over, nothing left to fetch): claims let go, any horse on his leash stays where it
## stands (still kept for its gun), and he walks back in.
static func go_home(u: Unit) -> void:
	u._haul_abort()
	u.begin_haul({"k": "horse", "ph": "home", "want": []})


## Killed: the next crewman of his Foundry waits CREW_WAIT s.
static func on_death(u: Unit) -> void:
	if is_instance_valid(u.fetch_home) and not u.fetch_home.dead:
		u.fetch_home.set_meta("crew_t", u.game.clock + CREW_WAIT)


## Order "gun_fetch" (Unit's order match): the walk to the breeder, the wait, the leash, the hitch and the way back in.
static func tick(u: Unit, delta: float) -> Vector2:
	var g := u.game
	var b := u.fetch_home
	if b == null or not is_instance_valid(b) or b.dead:
		b = _new_home(u)
		if b == null:
			u._haul_abort()
			g.consume_unit(u)        # (no Foundry or Town Hall left to go back to: he is gone)
			return Vector2.ZERO
		u.fetch_home = b
		if not u.led.is_empty() or not (u.haul_job.get("want", []) as Array).is_empty():
			go_home(u)
	var j := u.haul_job
	if j.is_empty():
		u._haul_abort()
		g.consume_unit(u)            # (home: back inside the Foundry, part of the gun's crew)
		return Vector2.ZERO
	# horses no longer kept for this Foundry (the gun cancelled): not his to fetch
	var want: Array = j.get("want", [])
	for h in want.duplicate():
		if not is_instance_valid(h) or h.dead or g.rid_owner(u.team, h.horse_rid) != b:
			want.erase(h)
			if is_instance_valid(h) and h.claimed == u:
				h.claimed = null
	u.work = "hauling"
	match String(j.get("ph", "")):
		"wait":
			var rid := int(j.get("rid", 0))
			if g.rid_owner(u.team, rid) != b:
				go_home(u)
				return Vector2.ZERO
			var h := g.reserved_horse(u.team, rid)
			if h:
				if h.into == b:
					go_home(u)       # (it got here some other way)
				elif g.horse_unclaimed(h) or h.claimed == u:
					_take(g, u, h)
				elif h.leader != null or Unit._claim_live(h):
					go_home(u)       # (a hauler has it)
				return Vector2.ZERO
			var br := g.rid_breeder(u.team, rid)
			if br == null:
				go_home(u)
				return Vector2.ZERO
			# by the breeder while the horse is bred
			if br.edge_distance(u.position) < u.radius + float(Defs.HAUL["reach"]) + 10.0:
				u.path = PackedVector2Array()
				var to_b: Vector2 = br.center() - u.position
				if to_b.length() > 1.0:
					u.facing = to_b.normalized()
				return Vector2.ZERO
			return u._walk_to(g.approach_point(br, u.position), delta)
		"fetch":
			if want.is_empty() and u.led.is_empty():
				go_home(u)
				return Vector2.ZERO
	return u._haul_horses(b, delta)


## His Foundry is gone: the nearest built Foundry or Town Hall of his side to go back into, or null.
static func _new_home(u: Unit) -> Building:
	var best: Building = null
	var bd := INF
	for b in u.game.buildings:
		if b.team != u.team or b.dead or not b.built or (b.kind != "foundry" and b.kind != "town_hall"):
			continue
		var dd: float = b.edge_distance(u.position)
		if dd < bd:
			bd = dd
			best = b
	return best


## For his card (never shown: he can't be picked) and the tests.
static func text(u: Unit) -> String:
	match String(u.haul_job.get("ph", "")):
		"wait":
			return "Gun crewman: waiting at the Horse Breeder for the gun's horse."
		"fetch":
			return "Gun crewman: going for the gun's horse."
		"deliver":
			return "Gun crewman: leading the horse to the Foundry."
	return "Gun crewman: going back into the Foundry."
