class_name WinderEscort
extends RefCounted
## WINDERS ESCORT THE ARMY (the owner's report and decision, 2026-11-15 20:11-20:15; docs/winder_escort.md).
## Before: a Winder in a group order took his own spot and, being armed (damage 7), an attack-move: he ran ahead
## (speed 74 v a Clock Soldier's 68), stopped at his spot and fought instead of winding or mending.
## Now:
## 1. AUTOMATIC ESCORT: Winders given a group order (move, attack-move, a drag-a-line, a right-click on an enemy; Shift
##    queues) together with Clockwork fighting units get the order "escort" (Unit.cmd_escort): they follow the group from
##    behind its middle, on the side away from where it goes (or from the enemy), wind and mend whoever in it (or round
##    it) needs it most, spread over the Winders, step back from enemies near them, never chase, and only fight an enemy
##    that is on them when they can't get away. When the group's order ends they stay with it until another order.
##    A group of only Winders keeps the plain orders.
## 2. WIND UP (W) on the Winder's card: the selected Winders escort the rest of the selection, or, with only Winders
##    selected, the unit tapped next (and the units round it). Game.wind_up_order.
## Only the host runs it; a guest sees the streamed order ("escort", the card says ESCORTING), work and walking.

const REPICK := 0.5          # s between two looks for the one to wind / mend
const BEHIND := 40.0         # px behind the group's rearmost man
const SIDE := 26.0           # px between two Winders side by side behind it
const ROUND := 3.0           # tiles round the group: its neighbours are wound too
const DANGER := 64.0         # px (edge to edge): an armed enemy this close to him: he steps back
const SAFE := 40.0           # px (edge to edge): a man with an armed enemy this close is left until it is safe
const PINNED := 0.8          # s with an enemy on him and nowhere to go before he fights back
const NEED_WIND := 0.95      # a construct below this charge needs winding
const DONE_WIND := 0.98      # ...and is done at this
const KEEP := 0.25           # his patient is kept unless another needs it this much more (no flicking between two)


## The fighting units of a selection a Winder escorts: ours, on the ground, not workers, not horses, not rooted.
static func fighters(us: Array) -> Array:
	return us.filter(func(u) -> bool: return u is Unit and is_instance_valid(u) and not u.dead and u.kind != "winder" \
			and not u.is_worker() and u.kind != "horse" and not u.is_air() and not BroodRoot.fixed(u) and u.aboard == null)


## A group order: the Winders in `us` with fighting units beside them escort those (toward `goal`, INF: none) instead of
## taking their own spot; returns the units still to be given the plain order (all of `us` when there is no escort).
static func split_off(us: Array, goal: Vector2, queued := false) -> Array:
	var ws: Array = us.filter(func(u) -> bool: return u is Unit and is_instance_valid(u) and u.kind == "winder" and not u.dead)
	if ws.is_empty():
		return us
	var f := fighters(us)
	f = f.filter(func(u: Unit) -> bool: return u.team == ws[0].team)
	if f.is_empty():
		return us        # (only Winders: today's plain orders)
	for w in ws:
		w.give({"o": "escort", "g": f, "p": goal}, queued)
	return us.filter(func(u) -> bool: return not ws.has(u))


## The group's middle and its men still there (dead, freed, aboard a balloon or gone to another side dropped).
static func prune(u: Unit) -> void:
	u.esc_group = u.esc_group.filter(func(o) -> bool: return o != null and is_instance_valid(o) and o is Unit and not o.dead \
			and o.team == u.team and o.aboard == null)


static func middle(g: Array) -> Vector2:
	var c := Vector2.ZERO
	for o in g:
		c += o.position
	return c / maxf(1.0, g.size())


## One tick of an escorting Winder (Unit order "escort"): the velocity he wants.
static func tick(u: Unit, delta: float) -> Vector2:
	u._esc_t -= delta
	if u._esc_t <= 0.0 or u.esc_group.is_empty():
		u._esc_t = REPICK
		prune(u)
		if u.esc_group.is_empty():
			# (the group is gone: the next queued order, else he stops where he is)
			if not u._next_order():
				u.cmd_stop()
			return Vector2.ZERO
		u.esc_patient = pick(u)
	u._ww_on = true             # (he cranks his own spring walking, as on the march)
	u.target = null
	u.war = false
	var p := u.esc_patient
	if p != null and (not is_instance_valid(p) or p.dead or not needs(p, true)):
		u.esc_patient = null
		p = null
	# an armed enemy close to him: he steps back (toward the rear of the group), never chases; on him with nowhere to
	# go (he has not got away for PINNED s): he fights it where he stands
	var th := threat(u, DANGER)
	if th != null:
		var close := th.edge_distance(u.position) < u.radius + 10.0
		if close and u.position.distance_to(u._esc_last) < u.speed * delta * 0.3:
			u._esc_pinned += delta
		elif not close:
			u._esc_pinned = 0.0
		u._esc_last = u.position
		if u._esc_pinned >= PINNED and u.can_hit(th):
			u.work = ""
			u.target = th
			return u._engage(th, delta, false)
		u.work = ""
		var away := (u.position - th.position).normalized()
		var rear := rear_spot(u)
		var to_rear := (rear - u.position).normalized() if u.position.distance_to(rear) > 4.0 else away
		var dirv := (away * 1.4 + to_rear).normalized()
		u.path = PackedVector2Array()
		return dirv * u.speed
	u._esc_pinned = 0.0
	u._esc_last = u.position
	if p != null and u.game.players[u.team]["gold"] >= 1:
		if WinderWalk.walking(p):
			return WinderWalk.tick(u, p, delta)       # (it walks: he winds it walking just behind it)
		if p.edge_distance(u.position) < u.radius + 20.0:
			u.work = "repairing"
			u.path = PackedVector2Array()
			u.facing = (p.center() - u.position).normalized()
			if u.game.players[u.team]["gold"] >= 1:
				u._repair_step(p, delta)
			return Vector2.ZERO
		u.work = ""
		return u._walk_to(p.position, delta)
	u.work = ""
	var spot := rear_spot(u)
	if u.position.distance_to(spot) < 12.0:
		u.path = PackedVector2Array()
		var c := middle(u.esc_group)
		if u.position.distance_to(c) > 1.0:
			u.facing = (c - u.position).normalized()
		return Vector2.ZERO
	return u._walk_to(spot, delta)


## Does `o` need a Winder (winding or mending)?
static func needs(o: Unit, started := false) -> bool:
	if o.has_charge() and o.wind < (DONE_WIND if started else NEED_WIND) and not o._in_field:
		return true
	return o.hp < o.max_hp - 0.5


## The one he winds or mends next: the group's man (or a neighbour within ROUND tiles of it) with the least charge or
## health, not next to an enemy, not one another escorting Winder already has (unless none else needs it); null: none.
static func pick(u: Unit) -> Unit:
	if u.game.players[u.team]["gold"] < 1:
		return null
	var g := u.esc_group
	var c := middle(g)
	var spread := 0.0
	for o in g:
		spread = maxf(spread, o.position.distance_to(c))
	var pool := {}
	for o in g:
		pool[o] = true
	for o in u.game.units_near(c, spread + ROUND * Defs.TILE):
		if o.team == u.team and not o.dead and o.kind != "winder" and not o.is_worker() and not o.is_air() and o.aboard == null:
			pool[o] = true
	var taken := {}
	for w in u.game.units_near(c, spread + 12.0 * Defs.TILE):
		if w != u and w.kind == "winder" and w.team == u.team and not w.dead:
			if w.order == "escort" and w.esc_patient != null and is_instance_valid(w.esc_patient):
				taken[w.esc_patient] = true
			elif w.order == "repair" and w.order_target != null and is_instance_valid(w.order_target):
				taken[w.order_target] = true
	var best: Unit = null
	var bs := INF
	var best_t: Unit = null
	var bts := INF
	var cur := u.esc_patient if u.esc_patient != null and is_instance_valid(u.esc_patient) else null
	var cur_s := INF
	for o in pool:
		if not u.can_repair(o) or not needs(o, o == cur):
			continue
		if threat(o, SAFE) != null:
			continue           # (in the thick of it: he waits till it is clear)
		var s: float = score(o) + o.position.distance_to(u.position) * 0.0004
		if o == cur:
			cur_s = s
		if taken.has(o):
			if s < bts:
				bts = s
				best_t = o
			continue
		if s < bs:
			bs = s
			best = o
	if cur != null and cur_s < INF and (best == null or cur_s - bs < KEEP):
		return cur
	return best if best != null else best_t


## Lower is more in need: its charge or its health share, whichever is lower (a run-down one first of all).
static func score(o: Unit) -> float:
	var s := clampf(o.hp / maxf(1.0, o.max_hp), 0.0, 1.0)
	if o.has_charge() and not o._in_field:
		s = minf(s, o.wind)
		if o.wind <= 0.0:
			s -= 0.5
	return s


## The nearest armed enemy on the ground within `r` px (edge to edge) of `o`; null: none.
static func threat(o: Unit, r: float) -> Unit:
	var best: Unit = null
	var bd := INF
	for e in o.game.units_near(o.position, r + 40.0):
		if e.dead or not o.game.hostile(e.team, o.team) or e.is_air() or not e.has_attack() or e.kind == "horse":
			continue
		if e.is_worker() and e.target != o and e.order != "attack" and e.order != "amove":
			continue           # (a worker at work is no threat)
		var dd: float = e.edge_distance(o.position) - o.radius
		if dd < r and dd < bd:
			bd = dd
			best = e
	return best


## Where he walks when nobody needs him: behind the group's rearmost man, on the side away from where it goes (its
## walk, else its goal, else the nearest enemy), the escorting Winders side by side.
static func rear_spot(u: Unit) -> Vector2:
	var g := u.esc_group
	if g.is_empty():
		return u.position
	var c := middle(g)
	var v := Vector2.ZERO
	for o in g:
		v += o.velocity
	v /= g.size()
	var dir := Vector2.ZERO
	# the front: where it fights, else where it walks, else where its men are sent, else the nearest enemy, else the
	# last front seen, else where it was sent when he joined it
	var tc := Vector2.ZERO
	var tn := 0
	var oc := Vector2.ZERO
	var on := 0
	for o in g:
		if o.target != null and is_instance_valid(o.target) and not o.target.dead:
			tc += o.target.position
			tn += 1
		if (o.order == "move" or o.order == "amove") and o.order_point.distance_to(o.position) > 40.0:
			oc += o.order_point
			on += 1
		elif o.order == "attack" and o.order_target != null and is_instance_valid(o.order_target):
			oc += o.order_target.position
			on += 1
	if on > 0 and (u.esc_goal == Vector2.INF or (oc / on).distance_to(u.esc_goal) > 150.0):
		u.esc_goal = oc / on          # (its men were sent somewhere new, without him: the new goal, from here)
		u.esc_from = c
	if u.esc_goal != Vector2.INF and u.esc_from == Vector2.INF:
		u.esc_from = c
	if tn > 0 and (tc / tn).distance_to(c) > 1.0:
		dir = (tc / tn - c).normalized()
	elif v.length() > 12.0 and (u.esc_goal == Vector2.INF or u.esc_goal.distance_to(c) > 200.0):
		dir = v.normalized()
	elif u.esc_goal != Vector2.INF and u.esc_goal.distance_to(u.esc_from) > 40.0:
		dir = (u.esc_goal - u.esc_from).normalized()       # (the way it was sent: behind is where it came from)
	elif u.esc_goal != Vector2.INF and u.esc_goal.distance_to(c) > 60.0:
		dir = (u.esc_goal - c).normalized()
	elif v.length() > 12.0:
		dir = v.normalized()
	else:
		var foe: Entity = u.game.find_target(g[0], 10.0 * Defs.TILE) if is_instance_valid(g[0]) else null
		if foe != null:
			dir = (foe.position - c).normalized()
		elif u._esc_dir != Vector2.ZERO:
			dir = u._esc_dir
	if dir == Vector2.ZERO:
		# (no way to tell the front: he stays where he is, if he is close to them)
		return u.position if u.position.distance_to(c) < 90.0 else c
	u._esc_dir = dir
	var back := 0.0
	for o in g:
		back = maxf(back, -(o.position - c).dot(dir) + o.radius)
	# his place in the row of the group's escorting Winders
	var mates: Array = []
	for w in u.game.units_near(c, 12.0 * Defs.TILE):
		if w.kind == "winder" and w.team == u.team and w.order == "escort" and not w.dead and w.esc_group == g:
			mates.append(w)
	if not mates.has(u):
		mates.append(u)
	mates.sort_custom(func(a: Unit, b: Unit) -> bool: return a.get_instance_id() < b.get_instance_id())
	var i := mates.find(u)
	var side := (float(i) - (mates.size() - 1) * 0.5) * SIDE
	var spot := c - dir * (back + BEHIND) + Vector2(-dir.y, dir.x) * side
	spot = u.game.on_map(spot)
	var cell := u.game.cell_of(spot)
	if u.game.in_map(cell) and not u.game.open_cell(cell):
		spot = u.game.cell_center(u.game.nearest_free_level(cell, 4))
	return spot
