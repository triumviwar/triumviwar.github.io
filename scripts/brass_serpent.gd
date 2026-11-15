class_name BrassSerpent
extends RefCounted
## THE BRASS SERPENT (gear mode's Clockwork, the owner's unit, DECIDED 2026-11-14 20:07-20:09; Defs.SERPENT has the numbers,
## docs/brass_serpent.md the rules in plain words and the art prompts): a long serpent of linked brass gears with a biting
## head, made at the Heavy Works.
## - GEARS = SEGMENTS (stats_for / apply): its health, bite, bite rate, speed and supply are worked out from its gears (small
##   "s" or big "b") and its heads the moment one is added or lost. Each Serpent keeps its own copy of Defs.UNITS entry (u.d),
##   so every rule that reads u.d (the bite, the cooldown, the walking speed, the supply count) follows it.
## - THE BODY follows the head's path like a snake (follow: the head's trail, kept as long as the body; segments: the gears'
##   centres along it). Blasts, shells, round shot, canister, a Pendulum's arc and a Ballista's bolt look at the BODY, gear by
##   gear (area / line / cone), not at the head's point: a long Serpent is a long target. A melee blow and a single shot still
##   go to the head (its own point: the thing that bites back).
## - DAMAGE breaks gears off the TAIL (after_hit): when its health falls past the tail gear's share the gear drops off as a
##   Clockwork WRECK (a dead unit of kind serpent_gear_s / _b, swept by the Great Winder as any wreck). Winders mend it like any
##   construct; only new gears make it longer.
## - GROWING: the Heavy Works builds gears into its store (item_done, Building.serp_gears [small, big]); COLLECT GEARS walks the
##   Serpent there and it takes them (big first); GROW (or a Winder's right-click on a Serpent at full health) sends a Winder
##   to fetch one and carry it out to it (fetch_tick).
## - MOVING GEAR GROUND (tick, on_body): its own side's Clockwork units on its body wind up as on the gear field
##   (Game.in_field asks on_body); with TURNING GEARS on they are carried along it; enemy ground units crossing it are slowed
##   (Unit.serp_slow_t). The Serpent itself never runs down.
## - HYDRA (link_tick, unlink): Serpents that touch LINK into one body with a head each; every head bites on its own (bite).
##   UNLINK splits it back, the gears shared out.
## State on the Unit: `serp` {"g": gears head to tail, "h": heads} (saved, streamed online and in replays); metas "serp_tr"
## (the trail, host and guest each keep their own from where the head goes; saved), "serp_riders", "serp_t" (scan clock),
## "serp_c" (the segments, worked out once a tick). A Winder carrying a gear: meta "serp_carry" ("s" / "b").
## Nothing here uses random numbers.

const S := Defs.SERPENT
const KIND := Defs.SERPENT_KIND
const GEAR_S := Defs.SERPENT_GEAR_S
const GEAR_B := Defs.SERPENT_GEAR_B
const SCAN := 0.25              # s between two looks at what stands on its body
const TRAIL_STEP := 3.0         # px the head moves before the trail gets a new point
const BRASS := Color(0.86, 0.66, 0.3)
const BRASS_DARK := Color(0.42, 0.28, 0.12)
const DRAW_K := 1.25            # gears are drawn this much bigger than their hit circles (their teeth)
const LIFT := 6.0               # px the gears and the head stand off the ground (their shadows stay on it)


static func is_serpent(u) -> bool:
	return u is Unit and is_instance_valid(u) and (u as Unit).kind == KIND


static func is_item(k: String) -> bool:
	return k == GEAR_S or k == GEAR_B


static func gears(u: Unit) -> Array:
	return u.serp.get("g", []) as Array


static func heads(u: Unit) -> int:
	return maxi(1, int(u.serp.get("h", 1)))


static func count(u: Unit, size: String) -> int:
	return gears(u).count(size)


static func info(size: String) -> Dictionary:
	return S["big"] if size == "b" else S["small"]


static func gear_r(size: String) -> float:
	return float(info(size)["r"])


static func max_gears(u: Unit) -> int:
	return int(S["max_per_head"]) * heads(u)


static func room(u: Unit) -> int:
	return maxi(0, max_gears(u) - gears(u).size())


# ------------------------------------------------------------------ stats

## Its numbers for these gears and heads: hp, bite damage, bite cooldown, speed, supply, weight.
static func stats_for(g: Array, h: int) -> Dictionary:
	h = maxi(1, h)
	var w := 0.0
	var hp := float(S["head_hp"]) * h
	var ns := 0
	var nb := 0
	for s in g:
		var inf := info(String(s))
		w += float(inf["weight"])
		hp += float(inf["hp"])
		if String(s) == "b":
			nb += 1
		else:
			ns += 1
	var wph := w / float(h)
	return {
		"hp": hp,
		"damage": float(S["bite_base"]) + float(S["bite_per_w"]) * wph,
		"cooldown": float(S["cd_base"]) + float(S["cd_per_w"]) * wph,
		"speed": clampf(float(S["speed_max"]) - float(S["speed_per_w"]) * w, float(S["speed_min"]), float(S["speed_max"])),
		"supply": h + int(ceil(float(S["supply_small"]) * ns + float(S["supply_big"]) * nb - 0.001)),
		"weight": w,
	}


## Its stats from its gears, now (its own copy of the Defs entry; the hp kept, at most its new full health).
static func apply(u: Unit) -> void:
	var st := stats_for(gears(u), heads(u))
	var nd: Dictionary = (Defs.UNITS[KIND] as Dictionary).duplicate()
	nd["hp"] = st["hp"]
	nd["damage"] = st["damage"]
	nd["cooldown"] = st["cooldown"]
	nd["speed"] = st["speed"]
	nd["supply"] = st["supply"]
	nd["cost"] = int(S["head_cost"]) * heads(u) + _gear_cost(gears(u))     # (what it is worth: the losses, a sweep)
	u.d = nd
	u.max_hp = float(st["hp"])
	u.hp = minf(u.hp, u.max_hp)
	u.speed = float(st["speed"])
	u.radius = float(S["head_r"]) + 2.0 * float(heads(u) - 1)
	u.remove_meta("serp_c")
	u.queue_redraw()


## A new Serpent (Unit.setup): its first gears, full health, its body laid out straight behind it.
static func init(u: Unit) -> void:
	u.serp = {"g": (S["start"] as Array).duplicate(), "h": 1}
	apply(u)
	u.hp = u.max_hp
	reset_trail(u)
	if u.game:
		_reg(u.game).append(u)


static func _reg(game: Game) -> Array:
	if not game.has_meta("serpents"):
		game.set_meta("serpents", [])
	return game.get_meta("serpents")


## The live Serpents of the match (the list is pruned as it is read).
static func all(game: Game) -> Array:
	if not game.has_meta("serpents"):
		return []
	var l: Array = game.get_meta("serpents")
	var out: Array = []
	for u in l:
		if is_instance_valid(u) and not u.dead and u.is_inside_tree() and not u.is_queued_for_deletion():
			out.append(u)
	if out.size() != l.size():
		game.set_meta("serpents", out.duplicate())
	return out


static func _gear_cost(g: Array) -> int:
	var c := 0
	for s in g:
		c += int(Defs.UNITS[GEAR_B if String(s) == "b" else GEAR_S]["cost"])
	return c


# ------------------------------------------------------------------ the body

## The body's length from the head's centre to the tail gear's centre (px).
static func offsets(u: Unit) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	var gap := float(S["gap"])
	var prev_r := float(S["head_r"])
	var at := 0.0
	for s in gears(u):
		var r := gear_r(String(s))
		at += (prev_r + r) * gap
		out.append(at)
		prev_r = r
	return out


static func body_len(u: Unit) -> float:
	var o := offsets(u)
	return (o[o.size() - 1] if o.size() > 0 else 0.0) + 16.0


## Its trail laid out straight behind it (a new Serpent, or after a jump the trail cannot follow).
static func reset_trail(u: Unit) -> void:
	var back := -u.facing.normalized() if u.facing.length() > 0.1 else Vector2.UP
	var tr := PackedVector2Array()
	var n := int(ceil((body_len(u) + 24.0) / 6.0)) + 1
	for i in n:
		tr.append(u.position + back * 6.0 * i)
	u.set_meta("serp_tr", tr)
	u.remove_meta("serp_c")


## The head moved: its trail gets the new point and is cut to the body's length.
static func follow(u: Unit) -> void:
	var tr: PackedVector2Array = u.get_meta("serp_tr", PackedVector2Array())
	if tr.is_empty() or u.position.distance_to(tr[0]) > body_len(u) * 0.5 + 96.0:
		reset_trail(u)
		return
	if u.position.distance_to(tr[0]) < TRAIL_STEP:
		return
	tr.insert(0, u.position)
	var need := body_len(u) + 24.0
	var s := 0.0
	for i in range(1, tr.size()):
		s += tr[i - 1].distance_to(tr[i])
		if s > need:
			tr.resize(i + 1)
			break
	u.set_meta("serp_tr", tr)
	u.remove_meta("serp_c")


## The point `s` px back along the trail (past its end: straight on from the last bit).
static func _along(tr: PackedVector2Array, s: float) -> Vector2:
	if tr.size() < 2:
		return tr[0] if tr.size() == 1 else Vector2.ZERO
	var acc := 0.0
	for i in range(1, tr.size()):
		var l := tr[i - 1].distance_to(tr[i])
		if acc + l >= s and l > 0.0:
			return tr[i - 1].lerp(tr[i], (s - acc) / l)
		acc += l
	var last := tr[tr.size() - 1]
	var dir := (last - tr[tr.size() - 2]).normalized()
	return last + dir * (s - acc)


## Its gears' places: [[centre, radius, size], ...] from the neck to the tail (worked out once a tick; the trail is the head's
## path, so a turning Serpent curls).
static func segments(u: Unit) -> Array:
	var c = (u.get_meta("serp_c") if u.has_meta("serp_c") else null)
	if c is Array and (c as Array).size() == 2 and (c[0] as Vector2) == u.position:
		return c[1]
	var tr: PackedVector2Array = u.get_meta("serp_tr", PackedVector2Array())
	if tr.is_empty():
		reset_trail(u)
		tr = u.get_meta("serp_tr")
	var tr2 := tr.duplicate()
	if tr2[0] != u.position:
		tr2.insert(0, u.position)
	var out: Array = []
	var o := offsets(u)
	var g := gears(u)
	for i in g.size():
		out.append([_along(tr2, o[i]), gear_r(String(g[i])), String(g[i])])
	u.set_meta("serp_c", [u.position, out])
	return out


## Where each head is (the first at its own point; a Hydra's others fanned out either side of it, a little back).
static func head_points(u: Unit) -> Array:
	var out: Array = [u.position]
	var f := u.facing.normalized() if u.facing.length() > 0.1 else Vector2.DOWN
	var side := Vector2(-f.y, f.x)
	for i in range(1, heads(u)):
		var sgn := 1.0 if i % 2 == 1 else -1.0
		out.append(u.position + side * sgn * 17.0 * floorf(float(i + 1) * 0.5) - f * 6.0)
	return out


## How far p is from its body's edge (heads and gears; negative: inside).
static func gap_to(u: Unit, p: Vector2) -> float:
	var best := INF
	for h in head_points(u):
		best = minf(best, p.distance_to(h) - float(S["head_r"]))
	for sg in segments(u):
		best = minf(best, p.distance_to(sg[0]) - float(sg[1]))
	return best


## Is p on a Serpent of side t's body (Game.in_field asks for the winding: moving gear ground)?
static func on_body(game: Game, t: int, p: Vector2, margin := 4.0) -> bool:
	if not game.has_meta("serpents"):
		return false
	for u in all(game):
		if u.team != t:
			continue
		if p.distance_to(u.position) > body_len(u) + 40.0:
			continue
		for sg in segments(u):
			if p.distance_to(sg[0]) <= float(sg[1]) + margin:
				return true
	return false


# ------------------------------------------------------------------ hits on the body

## How many gears a hit caught: the damage x Defs.SERPENT "split" for each past the first (at most "split_max").
static func split_mult(n: int) -> float:
	return 1.0 + (float(S["split"]) - 1.0) * float(clampi(n, 1, int(S["split_max"])) - 1)


## The Serpents with part of their body inside the circle (p, r): [[serpent, gap of the nearest part, parts inside], ...].
## `team` -1: anyone's; else only those hostile to it. Never the shooter.
static func area(game: Game, p: Vector2, r: float, team := -1, shooter = null) -> Array:
	var out: Array = []
	for u in all(game):
		if u == shooter or u.off_field or (team >= 0 and not game.hostile(u.team, team)):
			continue
		if p.distance_to(u.position) > r + body_len(u) + 30.0:
			continue
		var best := INF
		var n := 0
		for h in head_points(u):
			var dd := p.distance_to(h) - float(S["head_r"])
			best = minf(best, dd)
			if dd <= r:
				n += 1
		for sg in segments(u):
			var dd: float = p.distance_to(sg[0]) - float(sg[1])
			best = minf(best, dd)
			if dd <= r:
				n += 1
		if n > 0:
			out.append([u, maxf(best, 0.0), n])
	return out


## The Serpents with part of their body within w of the line a-b: [[serpent, along (0 at a), parts], ...].
static func line(game: Game, a: Vector2, b: Vector2, w: float, team := -1, shooter = null) -> Array:
	var out: Array = []
	for u in all(game):
		if u == shooter or u.off_field or (team >= 0 and not game.hostile(u.team, team)):
			continue
		var n := 0
		var first := INF
		var pts: Array = []
		for h in head_points(u):
			pts.append([h, float(S["head_r"])])
		for sg in segments(u):
			pts.append([sg[0], sg[1]])
		for pr in pts:
			var q := Geometry2D.get_closest_point_to_segment(pr[0], a, b)
			if q.distance_to(pr[0]) <= float(pr[1]) + w:
				n += 1
				first = minf(first, a.distance_to(q))
		if n > 0:
			out.append([u, first, n])
	return out


## The Serpents with part of their body in the cone from `from` along `dir` (cosine `cone`) within `reach`:
## [[serpent, distance of the nearest part, parts], ...].
static func cone(game: Game, from: Vector2, dir: Vector2, reach: float, cos_cone: float, shooter = null) -> Array:
	var out: Array = []
	for u in all(game):
		if u == shooter or u.off_field:
			continue
		var n := 0
		var best := INF
		var pts: Array = []
		for h in head_points(u):
			pts.append([h, float(S["head_r"])])
		for sg in segments(u):
			pts.append([sg[0], sg[1]])
		for pr in pts:
			var to: Vector2 = (pr[0] as Vector2) - from
			if to.length() <= reach + float(pr[1]) and dir.dot(to.normalized()) > cos_cone:
				n += 1
				best = minf(best, to.length())
		if n > 0:
			out.append([u, best, n])
	return out


# ------------------------------------------------------------------ the bite

## Its blow (Unit._strike): the first head bites the target; a Hydra's other heads each bite an enemy beside their own head
## (another one if there is one in reach, else the same).
static func bite(u: Unit, e: Entity, dmg: float) -> void:
	e.take_damage(dmg, u, Entity.BLOW_MELEE)
	u.game.spawn_effect("hit", e.center() + Vector2(0, -2), 0.7)
	Sfx.play_any(["combat/serpent_bite", "combat/clock_soldier_attack", "clash"], u.position, -2.0)
	var hp := head_points(u)
	var bitten: Array = [e]
	for i in range(1, hp.size()):
		var at: Vector2 = hp[i]
		var reach := float(u.d["range"]) + float(S["head_r"]) + 14.0
		var pick: Entity = null
		var pd := INF
		for o in u.game.units_near(at, reach + 30.0):
			if o.dead or o.off_field or o.is_air() or not u.game.hostile(o.team, u.team) or bitten.has(o) or o.untouchable():
				continue
			var dd: float = o.position.distance_to(at) - o.radius
			if dd <= reach and dd < pd:
				pd = dd
				pick = o
		if pick == null:
			pick = e
		if pick == null or not is_instance_valid(pick) or pick.dead:
			continue
		bitten.append(pick)
		pick.take_damage(dmg, u, Entity.BLOW_MELEE)
		u.game.spawn_effect("hit", pick.center() + Vector2(0, -2), 0.7)
	u.set_meta("serp_bite", u.game.clock)


# ------------------------------------------------------------------ hurt: the tail breaks

## After a blow (Unit.take_damage): while its health has fallen past the tail gear's share, that gear breaks off.
static func after_hit(u: Unit) -> void:
	if u.dead:
		return
	var g := gears(u)
	var lost := 0
	while not g.is_empty():
		var tail := String(g[g.size() - 1])
		if u.hp > u.max_hp - float(info(tail)["hp"]) + 0.001:
			break
		var at: Vector2 = segments(u)[g.size() - 1][0]
		g.pop_back()
		u.max_hp -= float(info(tail)["hp"])
		drop_wreck(u.game, u.team, tail, at)
		lost += 1
	if lost > 0:
		apply(u)
		if u.team == u.game.human and u.visible:
			u.game.float_text(u.position + Vector2(0, -34), "-1 gear" if lost == 1 else "-%d gears" % lost, Color(1.0, 0.7, 0.4))
		Sfx.play_any(["combat/serpent_gear_break", "combat/clock_soldier_death", "clash"], u.position, -4.0)


## A gear lying as a Clockwork wreck (a dead unit of the gear's kind, at rest: the Great Winder sweeps it like any wreck).
## Not a loss in the stats, not food for the Brood.
static func drop_wreck(game: Game, team: int, size: String, at: Vector2) -> Unit:
	var w := Unit.new()
	game._serial += 1
	w.serial = game._serial
	w.setup(game, GEAR_B if size == "b" else GEAR_S, team, at)
	game.world.add_child(w)
	w.dead = true
	w.died_at = game.clock
	w.hp = 0.0
	w.z_index = -1
	w.corpse_t = 2.0
	w._rest_in_peace()
	return w


## Killed: every gear on it falls where it was, a wreck each; the head's own wreck is worth the head alone (its cost).
static func on_death(u: Unit) -> void:
	var segs := segments(u)
	for sg in segs:
		drop_wreck(u.game, u.team, String(sg[2]), sg[0])
	var nd := u.d.duplicate()
	nd["cost"] = int(S["head_cost"])
	u.d = nd
	u.serp["g"] = []


# ------------------------------------------------------------------ every tick (the host's)

static func tick(u: Unit, delta: float) -> void:
	u.wind = 1.0                       # (it never runs down while it has gears)
	follow(u)
	var t := float(u.get_meta("serp_t", 0.0)) - delta
	if t <= 0.0:
		t = SCAN
		_scan(u)
	u.set_meta("serp_t", t)
	_carry(u, delta)
	if u.visible and u.velocity.length() > 1.0 and u.game.view_rect.has_point(u.position):
		u.queue_redraw()


## Every animation step (Unit._animate: the host's, a guest's puppet, a replay): the trail follows the head, the body is
## drawn again while it moves on screen.
static func animate(u: Unit) -> void:
	var before: Vector2 = u.get_meta("serp_ap", u.position)
	u.set_meta("serp_ap", u.position)
	follow(u)
	if u.sprite and u.sprite.visible:
		u.sprite.visible = false
	if u.visible and before != u.position:
		u.queue_redraw()


## What stands on its body: enemies are slowed, its own Clockwork units carried (TURNING GEARS) (their winding: on_body).
static func _scan(u: Unit) -> void:
	var segs := segments(u)
	var riders: Array = []
	if segs.is_empty():
		u.set_meta("serp_riders", riders)
		return
	var mid: Vector2 = segs[segs.size() >> 1][0]
	var look := body_len(u) * 0.6 + 40.0
	var turn := GearTurn.on(u.game)
	for o in u.game.units_near(mid, look):
		if o == u or o.dead or o.off_field or o.is_air() or o._k_serp or o.aboard != null:
			continue
		var k := -1
		for i in segs.size():
			if o.position.distance_to(segs[i][0]) <= float(segs[i][1]) + o.radius * 0.5 + 2.0:
				k = i
				break
		if k < 0:
			continue
		if u.game.hostile(o.team, u.team):
			o.serp_slow_t = SCAN + 0.15
		elif turn and o.team == u.team and String(o.d.get("faction", "")) == "clockwork" and GearTurn.carriable(o):
			riders.append([o, k])
	u.set_meta("serp_riders", riders)


## Its riders go with it, along the body toward the head, at Defs.SERPENT "carry" of its pace.
static func _carry(u: Unit, delta: float) -> void:
	var riders: Array = u.get_meta("serp_riders", [])
	var v := u.velocity.length()
	if riders.is_empty() or v < 2.0:
		return
	var segs := segments(u)
	for rk in riders:
		var o = rk[0]
		var k := int(rk[1])
		if not is_instance_valid(o) or o.dead or k >= segs.size():
			continue
		var toward: Vector2 = (segs[k - 1][0] if k > 0 else u.position)
		var dir: Vector2 = (toward - (segs[k][0] as Vector2)).normalized()
		o.position += dir * v * float(S["carry"]) * delta
		u.game.note_move(o)


# ------------------------------------------------------------------ the Heavy Works' gears

static func store(b: Building) -> Array:
	if b.serp_gears.size() < 2:
		b.serp_gears = [0, 0]
	return b.serp_gears


static func stored(b: Building) -> int:
	var s := store(b)
	return int(s[0]) + int(s[1])


## A gear made at the Heavy Works (Game.spawn_trained): into its store. True: it was a gear (no unit comes out).
static func item_done(game: Game, b: Building, k: String) -> bool:
	if not is_item(k):
		return false
	var s := store(b)
	if k == GEAR_B:
		s[1] = int(s[1]) + 1
	else:
		s[0] = int(s[0]) + 1
	if b.team == game.human:
		game.float_text(b.center() + Vector2(0, -40), "+1 big gear" if k == GEAR_B else "+1 small gear", BRASS)
	b.queue_redraw()
	return true


## Why that Heavy Works may not build another gear now ("" if it may): its store holds at most Defs.SERPENT "store".
static func item_problem(b: Building, k: String) -> String:
	if not is_item(k):
		return ""
	var queued := 0
	for q in b.queue:
		if is_item(String(q)):
			queued += 1
	if stored(b) + queued >= int(S["store"]):
		return "The gear store is full (%d gears)." % int(S["store"])
	return ""


## The supply its gears would add (the side must have room for it).
static func supply_after(u: Unit, add: Array) -> int:
	var g := gears(u).duplicate()
	g.append_array(add)
	return int(stats_for(g, heads(u))["supply"]) - int(u.d["supply"])


static func can_grow(u: Unit, size: String) -> String:
	if room(u) <= 0:
		return "It has all the gears it can carry (%d)." % max_gears(u)
	var more := supply_after(u, [size])
	if more > 0 and u.game.supply_used(u.team) + more > int(u.game.players[u.team]["cap"]):
		return "Not enough supply for another gear."
	return ""


## Put a gear on its tail (its stats follow; the new gear comes whole: max and hp both grow).
static func add_gear(u: Unit, size: String) -> void:
	gears(u).append(size)
	var add := float(info(size)["hp"])
	var hp0 := u.hp
	apply(u)
	u.hp = minf(hp0 + add, u.max_hp)
	u.queue_redraw()


## The nearest Heavy Works of its side with gears in store (or any, if `any`), else null.
static func works_near(game: Game, t: int, p: Vector2, any := false) -> Building:
	var best: Building = null
	var bd := INF
	for b in game.buildings:
		if b.team != t or b.dead or not b.built or b.kind != Defs.CW_HEAVY:
			continue
		if not any and stored(b) <= 0:
			continue
		var dd: float = b.center().distance_to(p)
		if dd < bd:
			bd = dd
			best = b
	return best


# ------------------------------------------------------------------ orders

## COLLECT GEARS: walk to that Heavy Works (or the nearest with gears) and take what its store holds, as many as fit.
static func cmd_collect(u: Unit, b: Building = null) -> String:
	if b == null:
		b = works_near(u.game, u.team, u.position)
	if b == null:
		return "No Heavy Works has gears in store."
	u._reset_work()
	u.order = "serp_collect"
	u.order_target = b
	u.target = null
	u.path = PackedVector2Array()
	u.repath_t = 0.0
	return ""


static func collect_tick(u: Unit, delta: float) -> Vector2:
	var b = u.order_target
	if b == null or not is_instance_valid(b) or b.dead or not (b is Building):
		u.cmd_stop()
		return Vector2.ZERO
	if (b as Building).edge_distance(u.position) > u.radius + float(S["reach"]):
		return u._walk_to((b as Building).center(), delta)
	var n := take_from(u, b)
	if u.team == u.game.human:
		u.game.float_text(u.position + Vector2(0, -34), ("+1 gear" if n == 1 else "+%d gears" % n) if n > 0 else "no gears taken", BRASS if n > 0 else Color(0.8, 0.8, 0.8))
	u.cmd_stop()
	return Vector2.ZERO


## Take gears from that store (big first) while it has room and supply; returns how many.
static func take_from(u: Unit, b: Building) -> int:
	var s := store(b)
	var n := 0
	for idx in [1, 0]:
		var size := "b" if idx == 1 else "s"
		while int(s[idx]) > 0 and can_grow(u, size) == "":
			s[idx] = int(s[idx]) - 1
			add_gear(u, size)
			n += 1
	b.queue_redraw()
	return n


## GROW: the nearest free Winder of its side fetches a gear from a Heavy Works' store and carries it out to it.
static func cmd_grow(u: Unit) -> String:
	var why := can_grow(u, "s")
	if why != "":
		return why
	var b := works_near(u.game, u.team, u.position)
	if b == null:
		return "No Heavy Works has gears in store."
	var best: Unit = null
	var bd := INF
	for w in u.game.workers(u.team):
		if w.kind != "winder" or w.dead or w.has_meta("serp_carry") or w.order == "serp_fetch" or w.order == "build":
			continue
		var dd: float = w.position.distance_to(b.center())
		if dd < bd:
			bd = dd
			best = w
	if best == null:
		return "No free Winder to carry a gear."
	cmd_fetch(best, u, b)
	return ""


## A Winder's job: to the store, a gear in his arms, out to the Serpent, onto its tail.
static func cmd_fetch(w: Unit, u: Unit, b: Building = null) -> void:
	if b == null:
		b = works_near(w.game, w.team, w.position)
	w._reset_work()
	w.order = "serp_fetch"
	w.order_target = u
	w.target = null
	w.path = PackedVector2Array()
	w.repath_t = 0.0
	if b != null:
		w.set_meta("serp_from", b)


static func fetch_tick(w: Unit, delta: float) -> Vector2:
	var u = w.order_target
	if u == null or not is_instance_valid(u) or u.dead or not is_serpent(u):
		_give_back(w)
		w.cmd_stop()
		return Vector2.ZERO
	if not w.has_meta("serp_carry"):
		var b = (w.get_meta("serp_from") if w.has_meta("serp_from") else null)
		if b == null or not is_instance_valid(b) or b.dead or stored(b) <= 0:
			b = works_near(w.game, w.team, w.position)
			if b == null:
				w.remove_meta("serp_from")
				w.cmd_stop()
				return Vector2.ZERO
			w.set_meta("serp_from", b)
		if (b as Building).edge_distance(w.position) > w.radius + float(S["reach"]):
			return w._walk_to((b as Building).center(), delta)
		var s := store(b)
		var size := "b" if int(s[1]) > 0 and can_grow(u, "b") == "" else "s"
		var idx := 1 if size == "b" else 0
		if int(s[idx]) <= 0:
			w.cmd_stop()
			return Vector2.ZERO
		s[idx] = int(s[idx]) - 1
		w.set_meta("serp_carry", size)
		w.queue_redraw()
		return Vector2.ZERO
	if gap_to(u, w.position) > w.radius + float(S["reach"]):
		w.repath_t = minf(w.repath_t, 0.5)
		var aim: Vector2 = (u as Unit).position
		var sg := segments(u)
		if not sg.is_empty():
			aim = sg[sg.size() - 1][0]       # (the tail: that's where it goes on)
		return w._walk_to(aim, delta)
	var size2 := String(w.get_meta("serp_carry"))
	if can_grow(u, size2) == "":
		w.remove_meta("serp_carry")
		add_gear(u, size2)
		if u.team == u.game.human:
			u.game.float_text((u as Unit).position + Vector2(0, -34), "+1 gear", BRASS)
		Sfx.play_any(["combat/serpent_gear_on", "work/winder_crank", "ratchet"], w.position, -6.0)
	else:
		_give_back(w)
	w.remove_meta("serp_from")
	w.queue_redraw()
	w.cmd_stop()
	return Vector2.ZERO


## A Winder with a gear that has nowhere to go: it goes back into the nearest Heavy Works' store (a Winder killed with it
## drops it as a wreck instead: drop_carry).
static func _give_back(w: Unit) -> void:
	if not w.has_meta("serp_carry"):
		return
	var size := String(w.get_meta("serp_carry"))
	w.remove_meta("serp_carry")
	var b := works_near(w.game, w.team, w.position, true)
	if b != null:
		var s := store(b)
		s[1 if size == "b" else 0] = int(s[1 if size == "b" else 0]) + 1
	w.queue_redraw()


## A loaded game: a Winder had a gear in his arms (orders are not saved): it goes back into a store once the buildings are
## in (deferred).
static func give_back_later(w: Unit) -> void:
	(func() -> void:
		if is_instance_valid(w) and not w.dead:
			_give_back(w)).call_deferred()


## A Winder killed with a gear in his arms (Unit.die): it falls as a wreck.
static func drop_carry(w: Unit) -> void:
	if not w.has_meta("serp_carry"):
		return
	var size := String(w.get_meta("serp_carry"))
	w.remove_meta("serp_carry")
	drop_wreck(w.game, w.team, size, w.position + Vector2(6, 2))


## LINK: these Serpents join the one with the most heads and gears (or `into`); each walks to it and joins on touching.
static func cmd_link(list: Array, into: Unit = null) -> String:
	var ss: Array = list.filter(func(o) -> bool: return is_serpent(o) and not o.dead)
	if into != null and is_serpent(into) and not ss.has(into):
		ss.append(into)
	if ss.size() < 2:
		return "Pick two or more Brass Serpents to link."
	if into == null:
		ss.sort_custom(func(a: Unit, b: Unit) -> bool: return heads(a) * 100 + gears(a).size() > heads(b) * 100 + gears(b).size())
		into = ss[0]
	var hn := heads(into)
	var any := false
	for o in ss:
		if o == into or o.team != into.team:
			continue
		if hn + heads(o) > int(S["max_heads"]):
			continue
		hn += heads(o)
		o._reset_work()
		o.order = "serp_link"
		o.order_target = into
		o.target = null
		o.path = PackedVector2Array()
		o.repath_t = 0.0
		any = true
	if not any:
		return "A Hydra has at most %d heads." % int(S["max_heads"])
	return ""


static func link_tick(u: Unit, delta: float) -> Vector2:
	var h = u.order_target
	if h == null or not is_instance_valid(h) or h.dead or not is_serpent(h) or h == u:
		u.cmd_stop()
		return Vector2.ZERO
	if heads(u) + heads(h) > int(S["max_heads"]):
		u.cmd_stop()
		return Vector2.ZERO
	if gap_to(h, u.position) > u.radius + float(S["reach"]) * 0.5:
		u.repath_t = minf(u.repath_t, 0.5)
		return u._walk_to((h as Unit).position, delta)
	join(h, u)
	return Vector2.ZERO


## `o` joins `h`: one body, its heads and gears added (the health too), `o` gone (not a loss).
static func join(h: Unit, o: Unit) -> void:
	var hp := h.hp + o.hp
	gears(h).append_array(gears(o))
	while gears(h).size() > int(S["max_per_head"]) * (heads(h) + heads(o)):
		gears(h).pop_back()
	h.serp["h"] = heads(h) + heads(o)
	if o.selected:
		h.game.selection.erase(o)
	h.game.consume_unit(o)
	apply(h)
	h.hp = minf(hp, h.max_hp)
	reset_trail(h)
	if h.team == h.game.human:
		h.game.float_text(h.position + Vector2(0, -40), "HYDRA: %d heads" % heads(h), BRASS)
	Sfx.play_any(["combat/serpent_link", "work/winder_crank", "ratchet"], h.position, -4.0)


## UNLINK: a Hydra splits back into Serpents of one head each, the gears shared out (front ones to the first head), the
## health in step with the gears each takes.
static func unlink(u: Unit) -> Array:
	var n := heads(u)
	if n < 2 or u.dead:
		return []
	var g := gears(u).duplicate()
	var frac := u.hp / maxf(u.max_hp, 1.0)
	var segs := segments(u)
	var per := int(ceil(float(g.size()) / float(n)))
	var made: Array = []
	u.serp["g"] = g.slice(0, mini(per, g.size()))
	u.serp["h"] = 1
	apply(u)
	u.hp = maxf(1.0, u.max_hp * frac)
	reset_trail(u)
	for i in range(1, n):
		var part := g.slice(mini(i * per, g.size()), mini((i + 1) * per, g.size()))
		var at: Vector2 = u.position
		var k := mini(i * per, segs.size() - 1)
		if k >= 0 and k < segs.size():
			at = segs[k][0]
		at = u.game.cell_center(u.game.nearest_free(u.game.cell_of(at), 4)) if not u.game.is_free(u.game.cell_of(at)) else at
		var o: Unit = u.game._add_unit(KIND, u.team, at)
		o.serp = {"g": part, "h": 1}
		o.facing = u.facing
		apply(o)
		o.hp = maxf(1.0, o.max_hp * frac)
		reset_trail(o)
		o.cmd_stop()
		made.append(o)
	Sfx.play_any(["combat/serpent_link", "work/winder_crank", "ratchet"], u.position, -4.0)
	return made


## A right-click (Game.smart_command): Serpents on their own Heavy Works COLLECT; on another of their own Serpents LINK;
## Winders on a Serpent at full health carry it a gear. True when it was taken.
static func smart(game: Game, us: Array, e, _p: Vector2) -> bool:
	if e == null or not is_instance_valid(e):
		return false
	var mine := us.filter(func(o: Unit) -> bool: return o.kind == KIND)
	var only := not mine.is_empty() and mine.size() == us.size()      # (a mixed selection: the usual right-click for all)
	if only and e is Building and (e as Building).kind == Defs.CW_HEAVY and (e as Building).team == mine[0].team:
		if (e as Building).built:
			for o in mine:
				cmd_collect(o, e)
			return true
		return false
	if only and is_serpent(e) and (e as Unit).team == mine[0].team and not mine.has(e):
		var why := cmd_link(mine, e)
		if why != "":
			game.tell(mine[0].team, why)
		return true
	if is_serpent(e) and (e as Unit).team == us[0].team and (e as Unit).hp >= (e as Unit).max_hp - 0.5:
		var ws := us.filter(func(o: Unit) -> bool: return o.kind == "winder")
		if not ws.is_empty() and ws.size() == us.size():
			var why2 := can_grow(e, "s")
			if why2 == "" and works_near(game, (e as Unit).team, (e as Unit).position) == null:
				why2 = "No Heavy Works has gears in store."
			if why2 != "":
				game.tell(us[0].team, why2)
				return true
			ws.sort_custom(func(a: Unit, b: Unit) -> bool: return a.position.distance_squared_to((e as Unit).position) < b.position.distance_squared_to((e as Unit).position))
			cmd_fetch(ws[0], e)
			return true
	return false


# ------------------------------------------------------------------ save, online

static func save(u: Unit) -> Dictionary:
	var out := {"g": "".join(PackedStringArray(gears(u))), "h": heads(u)}
	var tr: PackedVector2Array = u.get_meta("serp_tr", PackedVector2Array())
	var flat: Array = []
	for p in tr:
		flat.append(snappedf(p.x, 0.1))
		flat.append(snappedf(p.y, 0.1))
	out["tr"] = flat
	return out


static func load_state(u: Unit, sd: Dictionary) -> void:
	var g: Array = []
	for c in String(sd.get("g", "")):
		g.append("b" if c == "b" else "s")
	u.serp = {"g": g, "h": maxi(1, int(sd.get("h", 1)))}
	apply(u)
	var flat: Array = sd.get("tr", []) if sd.get("tr") is Array else []
	if flat.size() >= 4:
		var tr := PackedVector2Array()
		for i in range(0, flat.size() - 1, 2):
			tr.append(Vector2(float(flat[i]), float(flat[i + 1])))
		u.set_meta("serp_tr", tr)
	else:
		reset_trail(u)


## The value streamed online and in replays (NetSnapshot "serp"): its gears and heads (the trail each side keeps itself).
static func net_val(u: Unit) -> Dictionary:
	return u.serp.duplicate(true) if u._k_serp else u.serp


static func net_load(u: Unit, v) -> void:
	if not (v is Dictionary) or (v as Dictionary).is_empty() or not u._k_serp:
		return
	var same: bool = (v as Dictionary).get("g", []) == u.serp.get("g", []) and int((v as Dictionary).get("h", 1)) == int(u.serp.get("h", 1))
	if same:
		return
	var hp := u.hp
	u.serp = (v as Dictionary).duplicate(true)
	apply(u)
	u.hp = minf(hp, u.max_hp)


# ------------------------------------------------------------------ the card

static func card_line(u: Unit) -> String:
	var ns := count(u, "s")
	var nb := count(u, "b")
	var dm := int(round(float(u.d["damage"])))
	var sp := int(round(float(u.d["speed"])))
	if heads(u) > 1:
		return "HYDRA of %d heads: %d small + %d big gears (of %d) · each head bites %d every %.1f s · speed %d" % [heads(u), ns, nb,
			max_gears(u), dm, float(u.d["cooldown"]), sp]
	return "%d small + %d big gears (of %d) · bites %d every %.1f s · speed %d" % [ns, nb, max_gears(u), dm, float(u.d["cooldown"]), sp]


## The Heavy Works' line: its gear store.
static func works_line(b: Building) -> String:
	var s := store(b)
	return "Gear store: %d small, %d big (of %d)." % [int(s[0]), int(s[1]), int(S["store"])]


## Its command card (HUD._ability_buttons): COLLECT GEARS, GROW, LINK, UNLINK.
static func card(hud, list: Array, units: Array) -> void:
	var ss := units.filter(func(o: Unit) -> bool: return o.kind == KIND and o.team == hud.game.human)
	if ss.is_empty():
		return
	var game: Game = hud.game
	hud._tip_for["COLLECT"] = ["Collect gears", "The Serpent goes back to the nearest Heavy Works with gears in store and takes as many as fit (big ones first): more health and heavier bites, but slower. Right-click a Heavy Works to pick one."]
	hud._tip_for["GROW"] = ["Grow", "The nearest free Winder fetches a gear from a Heavy Works' store and carries it out to the Serpent, wherever it is. (A Winder's right-click on a Serpent at full health does the same.)"]
	hud._tip_for["LINK"] = ["Link into a Hydra", "The selected Serpents crawl together and join into one HYDRA: one body, a head each (at most %d), the gears pooled; every head bites on its own. Right-click one of your Serpents with others selected to link them to it." % int(S["max_heads"])]
	hud._tip_for["UNLINK"] = ["Unlink", "The Hydra splits back into Serpents of one head each, its gears shared out between them."]
	list.append(["ab_serpent_collect", "COLLECT", func() -> void:
		game.serpent_order(game.selected_units(), "collect", null), true, "", ""])
	list.append(["ab_serpent_grow", "GROW", func() -> void:
		game.serpent_order(game.selected_units(), "grow", null), true, "", ""])
	if ss.size() >= 2:
		list.append(["ab_serpent_link", "LINK", func() -> void:
			game.serpent_order(game.selected_units(), "link", null), true, "", ""])
	if ss.any(func(o: Unit) -> bool: return heads(o) > 1):
		list.append(["ab_serpent_unlink", "UNLINK", func() -> void:
			game.serpent_order(game.selected_units(), "unlink", null), true, "", ""])


# ------------------------------------------------------------------ drawing: the owner's ChatGPT art

# (tools/serpent/import_art.py cuts it into assets/units/brass_serpent/, its sizes in scripts/serpent_art.gd; the pieces are
# drawn on a child node of the unit with the unit's own team material, so the red enamel takes the side's colour and the
# hit flash, as a sprite does. A missing picture falls back to the code drawing below.)
const ART := "res://assets/units/brass_serpent/%s.png"
const ART_LIFT := 4.0            # px the body and the head stand off the ground (their shadows stay on it)
const HEAD_FWD := 3.0            # px the head's picture sits ahead of its point (its neck reaches back to the first gear)
const JOINT_BACK := 12.0         # px a Hydra's joint sits behind its heads' line
const BITE_FRAME := 0.08         # s a bite frame shows (4 frames)
const FAN := 0.7                 # rad a Hydra's side heads turn out from its facing
const FAN_R := 26.0              # px from its joint to a side head
const DIRS8 := ["e", "se", "s", "sw", "w", "nw", "n", "ne"]
static var art_off := false      # (tests: the code drawing)
static var _ok := -1


static func _tex(name: String) -> Texture2D:
	if not SerpentArt.P.has(name):
		return null
	var p := ART % name
	if not ResourceLoader.exists(p):
		return null
	return Game.tex(p)


## Every picture there (else the whole Serpent is drawn in code: one look, not a mix).
static func art_ok() -> bool:
	if art_off:
		return false
	if _ok < 0:
		_ok = 1
		for k in SerpentArt.P:
			if _tex(String(k)) == null:
				_ok = 0
				break
	return _ok == 1


## The child node the pictures are drawn on (made the first time).
static func _art_node(u: Unit) -> Node2D:
	var n = u.get_meta("serp_art") if u.has_meta("serp_art") else null
	if n is Node2D and is_instance_valid(n):
		return n
	var nn := Node2D.new()
	nn.name = "SerpentArt"
	nn.material = u.team_material()
	nn.draw.connect(func() -> void: _paint(u, nn))
	u.add_child(nn)
	u.set_meta("serp_art", nn)
	return nn


## The unit drew itself (Unit._draw_unit): its pictures again too.
static func redraw_art(u: Unit) -> void:
	var n = u.get_meta("serp_art") if u.has_meta("serp_art") else null
	if n is Node2D and is_instance_valid(n):
		(n as Node2D).queue_redraw()


## One picture: `name`'s frame `fr`, its anchor at `at`, turned `rot`, mirrored.
static func _put(n: CanvasItem, name: String, at: Vector2, rot := 0.0, fx := false, fy := false, fr := 0, mod := Color.WHITE, k := 1.0) -> void:
	var t := _tex(name)
	if t == null:
		return
	var p: Array = SerpentArt.P[name]
	var w := float(p[0])
	var h := float(p[1])
	if rot == 0.0:
		at = at.round()
	n.draw_set_transform(at, rot, Vector2(-k if fx else k, -k if fy else k))
	n.draw_texture_rect_region(t, Rect2(-float(p[2]), -float(p[3]), w, h), Rect2(w * fr, 0.0, w, h), mod)
	n.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## The view of a long piece (a section: either way along; the tail: toward its tip) that best fits `ang` (screen degrees):
## [name, rotation (rad), mirror x, mirror y]. Its h, v and d pictures, each mirrored, then turned the rest of the way.
static func _view(kind: String, ang: float, directed: bool) -> Array:
	var best: Array = []
	var bd := INF
	var per := 360.0 if directed else 180.0
	for v in ["h", "v", "d"]:
		var name := kind + "_" + String(v)
		var a0 := float(SerpentArt.P[name][5])
		for m in [[false, false, a0], [true, false, 180.0 - a0], [false, true, -a0], [true, true, a0 + 180.0]]:
			var diff := fposmod(ang - float(m[2]) + per * 0.5, per) - per * 0.5
			var cost := absf(diff) + (4.0 if m[1] else 0.0)      # (mirrored upside down only when it fits much better: the light)
			if cost < bd:
				bd = cost
				best = [name, deg_to_rad(diff), m[0], m[1]]
	return best


## The facing's 8-way view: [picture direction, mirror x] (W, SW, NW: E, SE, NE mirrored).
static func _dir8(f: Vector2) -> Array:
	var i := posmod(int(round(rad_to_deg(f.angle()) / 45.0)), 8)
	var d: String = DIRS8[i]
	match d:
		"w": return ["e", true]
		"sw": return ["se", true]
		"nw": return ["ne", true]
	return [d, false]


static func _shadow(n: CanvasItem, at: Vector2, rx: float, a := 1.0) -> void:
	n.draw_set_transform(at, 0.0, Vector2(1.0, 0.42))
	n.draw_circle(Vector2.ZERO, rx, Color(0, 0, 0, 0.28 * a))
	n.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _paint(u: Unit, n: Node2D) -> void:
	if not is_instance_valid(u):
		return
	if u.dead:
		if u._k_serp or u.kind == GEAR_S or u.kind == GEAR_B:
			_paint_wreck(u, n)
		return
	if u._k_serp:
		_paint_body(u, n)
	if u.has_meta("serp_carry"):
		var size := String(u.get_meta("serp_carry", "s"))
		_put(n, ("big" if size == "b" else "small") + "_h", Vector2(0, -36), 0.0, false, false, 0, Color.WHITE, 0.75)


## What its body is drawn as, in drawing order (nearest the viewer last): [y, "sec" / "tail" / "head" / "joint", data].
## `step`: the crawl moves on (once a drawing: the parent's, which draws the shadows).
static func _items(u: Unit, step: bool) -> Array:
	var segs := segments(u)
	var f := u.facing.normalized() if u.facing.length() > 0.1 else Vector2.DOWN
	var moving := u.velocity.length() > 1.0
	var crawl := float(u.get_meta("serp_crawl", 0.0))
	if step:
		if moving:
			crawl += u.position.distance_to(u.get_meta("serp_lastp", u.position)) / 7.0
			u.set_meta("serp_crawl", crawl)
		u.set_meta("serp_lastp", u.position)
	var lift := Vector2(0, -ART_LIFT)
	var pts: Array = [Vector2.ZERO]
	for sg in segs:
		pts.append((sg[0] as Vector2) - u.position)
	var items: Array = []         # [y, kind, data]
	# the gears' sections, each lying along the body there (from the one in front to the one behind)
	for i in segs.size():
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[i + 2] if i + 2 < pts.size() else pts[i + 1] * 2.0 - pts[i]
		var tan := a - b
		var ang := rad_to_deg(tan.angle()) if tan.length() > 0.5 else rad_to_deg(f.angle())
		var big := String(segs[i][2]) == "b"
		var bob := Vector2(0, -roundf(sin(crawl - float(i) * 1.3) * 0.6 + 0.4)) if moving else Vector2.ZERO
		items.append([(pts[i + 1] as Vector2).y, "sec", [pts[i + 1] + lift + bob, _view("big" if big else "small", ang, false), float(segs[i][1])]])
	# the tail beyond the last gear, pointing away
	if segs.size() > 0:
		var last: Vector2 = pts[pts.size() - 1]
		var away: Vector2 = last - (pts[pts.size() - 2] as Vector2)
		away = away.normalized() if away.length() > 0.5 else -f
		var at := last + away * (float(segs[segs.size() - 1][1]) * 0.7 + 9.0)
		items.append([at.y - 0.5, "tail", [at + lift, _view("tail", rad_to_deg(away.angle()), true)]])
	var hp := head_points(u)
	var bite_t := u.game.clock - float(u.get_meta("serp_bite", -9.0)) if u.game else 9.0
	var fr := int(bite_t / BITE_FRAME) if bite_t >= 0.0 and bite_t < BITE_FRAME * 4.0 else -1
	var d8 := _dir8(f)
	var jat := -f * JOINT_BACK
	for i in hp.size():
		# (a Hydra's other heads fan out from its joint's necks, each turned that way: drawn a little wider than the
		# points they bite from, head_points, so the heads don't sit on one another)
		var at := f * HEAD_FWD
		var hd := d8
		if i > 0:
			var sgn := 1.0 if i % 2 == 1 else -1.0
			var fd := f.rotated(sgn * FAN)
			at = jat + fd * FAN_R
			hd = _dir8(fd)
		items.append([at.y + 2.0, "head", [at + lift + Vector2(0, -2), hd, fr]])
	if hp.size() > 1:
		items.append([jat.y - 4.0, "joint", [jat + lift, d8]])
	items.sort_custom(func(x: Array, y: Array) -> bool: return float(x[0]) < float(y[0]))
	return items


## Its shadows, on the ground (on the unit itself: the team material would paint them white).
static func _shadows(u: Unit) -> void:
	var lift := Vector2(0, -ART_LIFT)
	for it in _items(u, true):
		var dd: Array = it[2]
		var r := 9.0
		match String(it[1]):
			"sec": r = float(dd[2]) * 1.1
			"tail": r = 5.0
			"head": r = 13.0
			"joint": r = 15.0
		_shadow(u, (dd[0] as Vector2) - lift + Vector2(0, 4), r)


## Its body, tail, Hydra joint and heads.
static func _paint_body(u: Unit, n: Node2D) -> void:
	var mod := Color.WHITE
	for it in _items(u, false):
		var dd: Array = it[2]
		match String(it[1]):
			"sec", "tail":
				var vw: Array = dd[1]
				_put(n, String(vw[0]), dd[0], float(vw[1]), bool(vw[2]), bool(vw[3]), 0, mod)
			"head":
				var vd: Array = dd[1]
				if int(dd[2]) >= 0:
					_put(n, "bite_" + String(vd[0]), dd[0], 0.0, bool(vd[1]), false, mini(int(dd[2]), 3), mod)
				else:
					_put(n, "head_" + String(vd[0]), dd[0], 0.0, bool(vd[1]), false, 0, mod)
			"joint":
				var vj: Array = dd[1]
				var jd := String(vj[0])
				var jx := bool(vj[1])
				var jy := false
				# (no picture facing away: the S and SE ones turned upside down, their necks to the heads)
				if jd == "n":
					jd = "s"
					jy = true
				elif jd == "ne":
					jd = "se"
					jy = true
				_put(n, "joint_" + jd, dd[0], 0.0, jx, jy, 0, mod)


## A gear broken off (serpent_gear_s / _b) or its fallen head: their wreck pictures (dented, burnt: already darker).
static func _paint_wreck(u: Unit, n: Node2D) -> void:
	var name := "wreck_head" if u._k_serp else ("wreck_big" if u.kind == GEAR_B else "wreck_small")
	_put(n, name, Vector2(0, -2), 0.0, u.serial % 2 == 1, false)


# ------------------------------------------------------------------ drawing in code (the stand-in, kept as the fallback)

static func _ring_tex(size: String) -> Array:
	if GearArt.disabled:
		return []
	return GearArt.ring("big" if size == "b" else "small", 10 if size == "b" else 8)


static func _draw_gear(ci: CanvasItem, at: Vector2, r: float, size: String, phase: float, tint: Color, a: float) -> void:
	# a little bigger than its hit circle (the teeth stick out), standing a little off the ground, squashed in y like the
	# gear field (seen from above at a slant): the shadow first, then a brass face with spokes, then the painted ring
	r *= DRAW_K
	var sq := 0.72
	ci.draw_set_transform(at + Vector2(0, r * 0.35), 0.0, Vector2(1.0, 0.42))
	ci.draw_circle(Vector2.ZERO, r * 1.05, Color(0, 0, 0, 0.3 * a))
	var c := at + Vector2(0, -LIFT)
	ci.draw_set_transform(c, 0.0, Vector2(1.0, sq))
	var face := Color(tint.r * BRASS.r * 0.82, tint.g * BRASS.g * 0.82, tint.b * BRASS.b * 0.82, a)
	var dark := Color(BRASS_DARK.r, BRASS_DARK.g, BRASS_DARK.b, a)
	ci.draw_circle(Vector2.ZERO, r * 0.86, dark)
	ci.draw_circle(Vector2.ZERO, r * 0.78, face)
	var sp := 5 if size == "b" else 4
	for i in sp:
		var an := phase + TAU * float(i) / float(sp)
		ci.draw_line(Vector2.from_angle(an) * r * 0.3, Vector2.from_angle(an) * r * 0.72, dark, 2.2 if size == "b" else 1.6)
	var rt := _ring_tex(size)
	if rt.size() >= 4 and rt[0] != null:
		var half := float(rt[3])
		var tip := float(rt[2])
		var k := r / maxf(tip, 1.0)
		ci.draw_set_transform_matrix(Transform2D(0.0, Vector2(1.0, sq), 0.0, c) * Transform2D(phase, Vector2(k, k), 0.0, Vector2.ZERO))
		ci.draw_texture_rect(rt[0], Rect2(Vector2(-half, -half), Vector2(half, half) * 2.0), false, Color(tint.r, tint.g, tint.b, a))
		ci.draw_set_transform(c, 0.0, Vector2(1.0, sq))
	else:
		# (no ring art: headless tests, or the strips missing) the teeth in code
		var n := 10 if size == "b" else 8
		for i in n:
			var an := phase + TAU * float(i) / float(n)
			ci.draw_line(Vector2.from_angle(an) * r * 0.8, Vector2.from_angle(an) * r * 1.0, dark, 3.0)
	ci.draw_circle(Vector2.ZERO, r * 0.3, dark)
	ci.draw_circle(Vector2(-r * 0.06, -r * 0.06), r * 0.14, Color(0.98, 0.84, 0.5, a))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Its head (code: a brass box skull with a jaw that opens on a bite, two red eyes, the team's colour on its brow).
static func _draw_head(u: Unit, ci: CanvasItem, at: Vector2, f: Vector2, a: float) -> void:
	var side := Vector2(-f.y, f.x)
	var bite_t := u.game.clock - float(u.get_meta("serp_bite", -9.0))
	var open := clampf(1.0 - absf(bite_t - 0.12) / 0.12, 0.0, 1.0) if bite_t < 0.3 else 0.15
	var lift := Vector2(0, -LIFT - 3.0)
	var c := at + lift - f * 3.0
	ci.draw_set_transform(at + Vector2(0, 4), 0.0, Vector2(1.0, 0.45))
	ci.draw_circle(Vector2.ZERO, 14.0, Color(0, 0, 0, 0.3 * a))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var skull := PackedVector2Array([c - f * 10.0 + side * 9.0, c + f * 5.0 + side * 9.0, c + f * 14.0 + side * 4.5,
		c + f * 14.0 - side * 4.5, c + f * 5.0 - side * 9.0, c - f * 10.0 - side * 9.0])
	ci.draw_colored_polygon(skull, Color(BRASS.r, BRASS.g, BRASS.b, a))
	ci.draw_polyline(skull + PackedVector2Array([skull[0]]), Color(BRASS_DARK.r, BRASS_DARK.g, BRASS_DARK.b, a), 1.5)
	# the jaw under it, open on a bite
	var jaw_c := c + f * 4.0 + Vector2(0, 5.0 + open * 6.0)
	var jaw := PackedVector2Array([jaw_c - f * 6.0 + side * 6.0, jaw_c + f * 11.0 + side * 3.0, jaw_c + f * 11.0 - side * 3.0, jaw_c - f * 6.0 - side * 6.0])
	ci.draw_colored_polygon(jaw, Color(BRASS_DARK.r * 1.3, BRASS_DARK.g * 1.3, BRASS_DARK.b * 1.3, a))
	for i in 3:
		var tp := jaw_c + f * (2.0 + 4.0 * i) - Vector2(0, 1.5)
		ci.draw_line(tp, tp - Vector2(0, 3.0 + open * 2.0), Color(0.95, 0.95, 0.85, a), 1.2)
	var team_c := u.cloth_colour()
	ci.draw_line(c - f * 6.0 + side * 6.0, c - f * 6.0 - side * 6.0, Color(team_c.r, team_c.g, team_c.b, a), 3.0)
	for sg in [1.0, -1.0]:
		ci.draw_circle(c + f * 7.0 + side * 4.5 * sg - Vector2(0, 2), 2.2, Color(1.0, 0.25, 0.15, a))


## Its body and heads (Unit._draw_unit; local to the unit's node). Gears turn as it crawls.
static func draw(u: Unit) -> void:
	if u.sprite:
		u.sprite.visible = false
	if art_ok():
		_shadows(u)
		_art_node(u).queue_redraw()
		return
	var a := 1.0
	var segs := segments(u)
	var phase := float(u.get_meta("serp_phase", 0.0))
	var dist := u.position.distance_to(u.get_meta("serp_lastp", u.position))
	phase += dist / 9.0
	u.set_meta("serp_phase", phase)
	u.set_meta("serp_lastp", u.position)
	var tint := Color(1, 1, 1)
	if u.flash > 0.0:
		tint = Color(1.6, 1.4, 1.4)
	# the iron links from pin to pin, under the gears (the head's neck to the first)
	var prev: Vector2 = Vector2(0, -LIFT)
	for sg in segs:
		var q: Vector2 = (sg[0] as Vector2) - u.position + Vector2(0, -LIFT)
		u.draw_line(prev, q, Color(0.2, 0.17, 0.15, a), 4.0)
		u.draw_line(prev, q, Color(0.45, 0.4, 0.36, a), 1.6)
		prev = q
	# tail first (drawn under the gears in front of it), alternate gears turning the other way (they mesh)
	for i in range(segs.size() - 1, -1, -1):
		var sg: Array = segs[i]
		var sp := phase * (1.0 if i % 2 == 0 else -1.0) * (9.0 / float(sg[1]))
		_draw_gear(u, (sg[0] as Vector2) - u.position, float(sg[1]), String(sg[2]), sp, tint, a)
	var f := u.facing.normalized() if u.facing.length() > 0.1 else Vector2.DOWN
	var hp := head_points(u)
	for i in range(hp.size() - 1, -1, -1):
		_draw_head(u, u, (hp[i] as Vector2) - u.position, f, a)


## A broken gear lying on the ground (a wreck: serpent_gear_s / _b), or a Serpent's fallen head.
static func draw_wreck(u: Unit) -> void:
	if u.sprite:
		u.sprite.visible = false
	if art_ok():
		_shadow(u, Vector2(0, 3), 11.0 if u._k_serp else 8.0, 0.8)
		_art_node(u).queue_redraw()
		return
	if u._k_serp:
		_draw_head(u, u, Vector2.ZERO, Vector2.RIGHT, 0.75)
		return
	var size := "b" if u.kind == GEAR_B else "s"
	_draw_gear(u, Vector2.ZERO, gear_r(size) * 0.95, size, float(u.serial % 7), Color(0.62, 0.55, 0.5), 1.0)


## A Winder carrying a gear: it on his back, over his head.
static func draw_carry(u: Unit) -> void:
	if art_ok():
		_art_node(u).queue_redraw()
		return
	var size := String(u.get_meta("serp_carry", "s"))
	_draw_gear(u, Vector2(0, -34), gear_r(size) * 0.7, size, 0.0, Color(1, 1, 1), 1.0)


# ------------------------------------------------------------------ the computer (OPTIMAL only; `-- serpent:off` off)

const AI_WANT := {"crown": 2, "clockwork": 2, "brood": 1}
const AI_GEAR_CAP := 400          # cogs it keeps beyond a gear's price before building one
const AI_HYDRA_AT := 720.0        # s into the match before it links Hydras


static func ai_on(ai) -> bool:
	return Defs.gear_mode and ai.opt != null and not OS.get_cmdline_user_args().has("serpent:off")


## OPTIMAL's Serpents (AIClockwork._produce): a few by matchup from a Heavy Works with a Mainspring, gears built into the
## store while a Serpent has room, a Winder carries them out (or it collects when idle at home), and late on, two big
## Serpents near each other link into a Hydra. Returns true when it spent cogs this think.
static func ai_produce(ai) -> bool:
	if not ai_on(ai):
		return false
	var game: Game = ai.game
	var t: int = ai.team
	var foe: int = ai._foe()
	var want := int(AI_WANT.get(game.faction_of(foe) if foe >= 0 else "crown", 1))
	var mine: Array = all(game).filter(func(o: Unit) -> bool: return o.team == t)
	var works: Array = game.buildings.filter(func(b: Building) -> bool: return b.team == t and b.kind == Defs.CW_HEAVY and b.built and not b.dead)
	if works.is_empty():
		return false
	var queued := 0
	for w in works:
		queued += (w.queue as Array).count(KIND)
	var spent := false
	if mine.size() + queued < want:
		for w in works:
			if (w.queue as Array).is_empty() and game.gear_net.spring_for(w) != null and game.can_train(w, KIND) == "":
				if game.train(w, KIND) == "":
					ai.note("OPTIMAL: a Brass Serpent from the Heavy Works (%s)" % game.faction_of(foe))
					spent = true
				break
	# gears: while a Serpent has room, keep one or two in store (big ones once it has the Tension)
	var room_n := 0
	for o in mine:
		room_n += room(o)
	var in_store := 0
	for w in works:
		in_store += stored(w) + (w.queue as Array).filter(func(k) -> bool: return is_item(String(k))).size()
	if room_n > in_store and in_store < 2:
		for w in works:
			if (w.queue as Array).size() >= 1:
				continue
			var k := GEAR_B if game.tension(t) > 80.0 else GEAR_S
			if game.players[t]["gold"] >= int(Defs.UNITS[k]["cost"]) + AI_GEAR_CAP and game.can_train(w, k) == "" and item_problem(w, k) == "":
				game.train(w, k)
				spent = true
				break
	# a Winder carries a stored gear to a Serpent with room (one at a time)
	var carrying := game.workers(t).filter(func(w: Unit) -> bool: return w.order == "serp_fetch").size()
	if carrying == 0:
		for o in mine:
			if room(o) > 0 and can_grow(o, "s") == "" and works_near(game, t, o.position) != null:
				if o.order == "idle" and works_near(game, t, o.position).center().distance_to(o.position) < 600.0:
					cmd_collect(o)
				elif cmd_grow(o) == "":
					ai.note("a Winder carries a gear out to its Brass Serpent")
				break
	# late on: two Serpents with many gears, near each other, link into a Hydra
	if game.clock >= AI_HYDRA_AT and mine.size() >= 2:
		for i in mine.size():
			for j in range(i + 1, mine.size()):
				var p: Unit = mine[i]
				var q: Unit = mine[j]
				if p.order == "serp_link" or q.order == "serp_link" or heads(p) + heads(q) > int(S["max_heads"]):
					continue
				if gears(p).size() + gears(q).size() >= 16 and p.position.distance_to(q.position) < 260.0 and p.target == null and q.target == null:
					if cmd_link([p, q]) == "":
						ai.note("links two Brass Serpents into a Hydra")
						return spent
	return spent
