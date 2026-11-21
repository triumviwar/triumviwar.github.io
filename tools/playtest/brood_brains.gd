extends RefCounted
## The players' minds for brood_mission.gd: what to do next, read from the match; every order goes through the HAND.
var pt
var hand
var g: Game
var r: MissionRun
var a: Dictionary
var tree: SceneTree
var me := 0
var choices := {}


func _init(p, h, game: Game, args: Dictionary, t: SceneTree) -> void:
	pt = p
	hand = h
	g = game
	r = game.mission
	a = args
	tree = t
	me = g.human
	for c in String(a["choice"]).split(",", false):
		choices[c.get_slice(":", 0)] = c.get_slice(":", 1)
	Engine.time_scale = float(a["speed"])
	Engine.max_physics_steps_per_frame = 16


func play() -> void:
	match String(a["who"]):
		"probe":
			await probe()
		_:
			if has_method(String(a["mission"]).get_slice("_", 0) + "_" + String(a["who"])):
				await call(String(a["mission"]).get_slice("_", 0) + "_" + String(a["who"]))
			else:
				await idle()


# ------------------------------------------------------------------ shared
var _last_obj := {}
var _last_print := -100.0
var _shots_at := {}


## Once a frame-ish: watch the objectives, the lines, the choices (answered as the args say, else the default in
## time, else the first) and take a picture of each new objective state.
func tick() -> void:
	if r == null:
		return
	for k in r.obj:
		if _last_obj.get(k, "") != r.obj[k]:
			pt.note("OBJ", "%d:%02d %s -> %s" % [int(g.clock) / 60, int(g.clock) % 60, k, r.obj[k]])
			_last_obj[k] = r.obj[k]
			if String(r.obj[k]) in ["active", "done", "failed"] and a["shots"] == "1" and not _shots_at.has(k + r.obj[k]):
				_shots_at[k + r.obj[k]] = true
				await pt.shot("obj_%s_%s" % [k, r.obj[k]])
	if not r.choice_open.is_empty():
		var cid := String(r.choice_open["id"])
		var opts: Array = (r.choice_open.get("options", []) as Array).map(func(o) -> String: return String(o.get("id", "")))
		pt.note("CHOICE", "%d:%02d %s %s" % [int(g.clock) / 60, int(g.clock) % 60, cid, opts])
		await pt.shot("choice_" + cid)
		var want := String(choices.get(cid, ""))
		if want == "default":
			pass             # (nobody answers: the default in time)
		elif want != "" or not opts.is_empty():
			var o := want if want != "" else String(opts[0])
			if not await pt.tap("Choose_" + o, 2.0):
				pt.note("BUG?", "the choice %s has no button Choose_%s on screen" % [cid, o])
			await pt.wait(0.3)
	if g.clock - _last_print > 60.0:
		_last_print = g.clock
		pt.note("STATE", "%d:%02d obj=%s counters=%s flags=%s" % [int(g.clock) / 60, int(g.clock) % 60, r.obj, r.counters, r.flags])


func idle() -> void:
	var until := float(a["until"])
	while not g.over and g.clock < until:
		await tick()
		await pt.wait(0.5)
	pt.note("IDLE", "done at %d:%02d over=%s winner=%s" % [int(g.clock) / 60, int(g.clock) % 60, g.over, r.winner_side])


func probe() -> void:
	await pt.wait(1.0)
	await tick()
	var mine: Array = g.units.filter(func(u): return u.team == me and not u.dead)
	var kinds := {}
	for u in mine:
		kinds[u.kind] = int(kinds.get(u.kind, 0)) + 1
	pt.note("PROBE", "my units %s; tagged %s" % [kinds, r.tags.keys() if r.get("tags") is Dictionary else "?"])
	var done := {}
	for u in mine:
		if done.has(u.kind):
			continue
		done[u.kind] = true
		await hand.escape()
		if await hand.pick(u):
			pt.note("CARD", "%s: %s" % [u.kind, hand.card_labels()])
			await pt.shot("card_" + u.kind)
	# the roster (B1: the Sire and Raptors only): what the Mother's card does with the others
	var q := BroodNew.queen(g, me)
	await hand.escape()
	if await hand.pick(q):
		for lab in ["BRUTE", "SPITTERS", "MIST TOAD", "HATCHLINGS", "GROW", "LAYING", "QUICK ROOTS"]:
			await hand.card(lab)
			await pt.wait(0.2)
			pt.note("ROSTER", "%s pressed: toast '%s' queue=%s gold=%d" % [lab, g.hud.get("_msg"), q.get("queue") if q.get("queue") != null else "?", int(g.players[me]["gold"])])
			await hand.escape()
			await hand.pick(q)
		await pt.shot("roster_presses")
	var grubs: Array = g.units.filter(func(u): return u.team == me and u.kind == "grub" and not u.dead)
	if not grubs.is_empty() and await hand.pick(grubs[0]):
		await hand.card("BUILD")
		pt.note("CARD", "grub BUILD page: %s" % [hand.card_labels()])
		await pt.shot("grub_build")
		await hand.escape()
	await hand.menu()
	await pt.shot("menu")
	pt.note("MENU", str(hand.menu_labels()))
	await hand.menu_item("PAUSE")
	await pt.wait(0.5)
	await pt.shot("paused")
	await hand.menu_item("RESUME")
	await pt.wait(1.0)
	await hand.menu()
	await hand.menu_item("QUIT TO MENU")
	await pt.wait(2.0)
	await pt.shot("after_quit")
	pt.note("PROBE", "after quit: " + str(pt.button_names()))


# ------------------------------------------------------------------ helpers for the Brood player
func army_units() -> Array:
	return g.units.filter(func(u): return not u.dead and u.team == me and not u.is_worker() and not BroodNew.ROOTERS.has(u.kind) and u.kind != "brood_egg")


func tagged1(t: String):
	var l: Array = r.tagged(t)
	return l[0] if not l.is_empty() and is_instance_valid(l[0]) and not l[0].dead else null


func area_c(n: String) -> Vector2:
	return r.area_rect(n).get_center()


## A spot for `k` round `c` where `u` may root (the same rules the ROOT ghost checks).
func spot(k: String, c: Vector2, u: Unit, r0: int, r1: int) -> Vector2:
	for rad in range(r0, r1 + 1):
		for i in 16:
			var ang := TAU * float(i) / 16.0
			var p := BroodRoot.snap(k, c + Vector2(cos(ang), sin(ang)) * rad * Defs.TILE, 1.0)
			if BroodRoot.place_problem(g, me, k, p, u, false, 1.0) == "":
				return p
	return Vector2.INF


## ROOT a creature at a spot: pick it, ROOT on its card, click the spot.
func root_at(u: Unit, p: Vector2) -> bool:
	await hand.escape()
	if not await hand.pick(u):
		return false
	if not await hand.card("ROOT"):
		return false
	await hand.ground(p)
	await pt.wait(0.3)
	if u.order != "nb_root" and not BroodNew.rooted(u):
		pt.note("HAND", "ROOT at %s didn't take (order %s, toast '%s')" % [p, u.order, g.hud.get("_msg")])
		await hand.escape()
		return false
	return true


func uproot(u: Unit) -> void:
	await hand.escape()
	if await hand.pick(u):
		await hand.card("UPROOT")


## The Mother lays (her card's egg button).
func lay(what: String) -> void:
	var q := BroodNew.queen(g, me)
	if q == null:
		return
	if not g.selection.has(q) or g.selection.size() != 1:
		await hand.escape()
		if not await hand.pick(q):
			return
	await hand.card(what)


## A grub turned into a rooted creature (its BUILD page: ROOTMAW, MOUND TURTLE...).
func morph(grub: Unit, what: String, p: Vector2) -> void:
	await hand.escape()
	if not await hand.pick(grub):
		return
	if not await hand.card("BUILD"):
		return
	if not await hand.card(what):
		await hand.escape()
		return
	await hand.ground(p)
	await pt.wait(0.2)
	await hand.escape()


## The whole army (F2) attack-moves (or moves) to `w`.
func army_to(w: Vector2, attack := true) -> void:
	await hand.escape()
	await hand.army()
	if g.selection.is_empty():
		return
	await hand.go(w, attack)


func wait_tick(sec: float) -> void:
	var t := 0.0
	while t < sec and not g.over:
		await tick()
		await pt.wait(0.25)
		t += 0.25 * Engine.time_scale


# ------------------------------------------------------------------ b01: SPECIMEN ONE (played as the Sire's pack)
var _state := "build"


func b01_careful() -> void:
	var until := float(a["until"])
	var want := int(a.get("want", "24"))
	var last_eco := -10.0
	var maw_sent := false
	var roared_at := -1.0
	while not g.over and g.clock < until:
		await wait_tick(1.5)
		if g.over:
			break
		var q := BroodNew.queen(g, me)
		var sire: Unit = tagged1("sire")
		if q == null or sire == null:
			continue
		var army := army_units().filter(func(u): return u != sire)
		var grubs: Array = g.units.filter(func(u): return not u.dead and u.team == me and u.kind == "grub" and u.order != "nb_morph")
		var home_nest := sire.position.distance_to(q.position) < 9.0 * Defs.TILE
		# the economy, while she is in her pen
		if not r.fired.has("broken") and g.clock - last_eco > 4.0 and _state in ["build", "out"]:
			last_eco = g.clock
			var room := int(g.players[me]["cap"]) - g.supply_used(me)
			var gold := int(g.players[me]["gold"])
			var turtles := r.count({"team": "sire", "kind": "mound_turtle"}) + g.units.filter(func(u): return u.team == me and u.order == "nb_morph").size()
			if room < 4 and turtles < 3 and not grubs.is_empty() and gold >= 100:
				var tp := spot("mound_turtle", q.position, grubs[0], 8, 14)
				if tp != Vector2.INF:
					await morph(grubs[0], "MOUND TURTLE", tp)
			elif not maw_sent and g.clock > 40.0 and gold >= 75 and not grubs.is_empty():
				var mp := spot("rootmaw", q.position, grubs[0], 5, 12)
				if mp != Vector2.INF:
					await morph(grubs[0], "ROOTMAW", mp)
					maw_sent = true
			elif r.count({"team": "sire", "kind": "grub"}) < 9 and gold >= 50:
				await lay("GRUB")
			elif BroodNew.rooted(sire) and home_nest and gold >= 50:
				await lay("RAPTORS")
		match _state:
			"build":
				if not BroodNew.rooted(sire):
					if sire.order != "nb_root":
						var p := spot("tyrannosaur", q.position, sire, 3, 7)
						if p != Vector2.INF:
							await root_at(sire, p)
					continue
				if r.fired.has("laid") and (army.size() >= want or g.clock > 1100.0):
					_state = "out"
					pt.note("PLAN", "%d:%02d the pack goes out (%d)" % [int(g.clock) / 60, int(g.clock) % 60, army.size()])
					await uproot(sire)
			"out":
				if BroodNew.rooted(sire):
					await uproot(sire)
					continue
				var west := area_c("jar_w")
				var above := Vector2(62, 47) * Defs.TILE
				var to := west if not r.fired.has("roar_heard") else above
				if sire.position.distance_to(to) > 120.0 and (sire.order == "idle" or sire.velocity.length() < 5.0):
					await army_to(to)
				if r.fired.has("roar_heard") and roared_at < 0.0:
					roared_at = g.clock
					await pt.shot("roar")
				if r.fired.has("roar_heard") and sire.position.distance_to(above) < 200.0:
					_state = "clear"
			"clear":
				# the yard's guns first (the Sire roots only once they are down)
				var pen := area_c("pen")
				var foes := [r.team_index("station"), r.team_index("garrison")]
				var guns: Array = g.units.filter(func(u): return not u.dead and foes.has(u.team) and u.kind in ["musketeer", "dismounted"] and not u.spared and u.position.distance_to(pen) < 560.0)
				if guns.is_empty():
					_state = "nest"
				else:
					var busy := army.filter(func(u): return u.target != null and is_instance_valid(u.target) and not u.target.dead).size()
					if busy < army.size() / 2:
						await hand.escape()
						await hand.army()
						await hand.hit(guns[0])
			"nest":
				var pen := area_c("pen")
				if not BroodNew.rooted(sire) and sire.order != "nb_root" and not r.fired.has("broken"):
					var p := spot("tyrannosaur", area_c("nest"), sire, 0, 6)
					if p != Vector2.INF:
						await root_at(sire, p)
					else:
						await hand.escape()
						await hand.pick(sire)
						await hand.go(area_c("nest"))
				var gate = tagged1("pen_gate")
				var threats: Array = g.units.filter(func(u): return not u.dead and g.hostile(u.team, me) and not u.spared and u.kind != "brood_egg" and u.position.distance_to(sire.position) < 300.0)
				if not threats.is_empty():
					threats.sort_custom(func(x, y): return x.position.distance_to(sire.position) < y.position.distance_to(sire.position))
					await hand.escape()
					await hand.army()
					await hand.hit(threats[0])
					continue
				var idle_army := army.filter(func(u): return u.target == null or not is_instance_valid(u.target) or u.target.dead)
				if r.obj.get("gate", "") == "active" and gate != null and army.is_empty():
					# the pack is gone: the Sire gets up and breaks the gate himself
					if BroodNew.rooted(sire):
						await uproot(sire)
						continue
					await hand.escape()
					await hand.pick(sire)
					await hand.hit(gate)
					if not _shots_at.has("sire_gate"):
						_shots_at["sire_gate"] = true
						pt.note("PLAN", "%d:%02d no pack left: the Sire breaks the gate himself (target %s)" % [int(g.clock) / 60, int(g.clock) % 60, sire.target.kind if sire.target else "none"])
				elif r.obj.get("gate", "") == "active" and gate != null:
					await hand.escape()
					await hand.army()
					var nsel: int = g.selection.size()
					await hand.hit(gate)
					await pt.wait(0.3)
					var on := army.filter(func(u): return u.target == gate).size()
					if not _shots_at.has("gatehit"):
						_shots_at["gatehit"] = true
						pt.note("GATE", "right-click on the gate (%s, team %d, hp %d, at %s, hostile %s): %d selected, %d now target it; orders %s" % [gate.kind, gate.team, gate.hp, gate.center(), g.hostile(gate.team, me), nsel, on, army.map(func(u): return u.order).slice(0, 6)])
						await pt.shot("gate_hit")
				elif idle_army.size() > army.size() / 2:
					await army_to(pen + Vector2(60, -60))
				if r.fired.has("broken"):
					_state = "home"
					await pt.shot("gate_broken")
			"home":
				if BroodNew.rooted(sire):
					await uproot(sire)
					continue
				var den := area_c("den")
				var west := area_c("jar_w")
				var to := den if sire.position.y < 44.0 * Defs.TILE or sire.position.distance_to(west) < 200.0 else west
				if sire.position.distance_to(to) > 120.0 and (sire.order == "idle" or sire.velocity.length() < 5.0):
					await army_to(to, false)
		# the pack spent: home to rebuild (also at the pen, before the clutch is laid)
		if (_state == "out" and army.size() < 3 and not r.fired.has("roar_heard")) \
				or (_state in ["clear", "nest"] and army.size() < 4 and not r.fired.has("broken") and int(r.counters.get("eggs", 0)) < 4):
			_state = "build"
			pt.note("PLAN", "%d:%02d the pack is spent: home" % [int(g.clock) / 60, int(g.clock) % 60])
			if BroodNew.rooted(sire):
				await uproot(sire)
			await army_to(q.position, false)
	var sl: Array = r.tagged("sire", false)
	if not sl.is_empty() and is_instance_valid(sl[0]) and sl[0].dead:
		pt.note("RESULT", "the Sire died; last hit by %s at %s (state %s)" % [sl[0].last_hit_by, g.cell_of(sl[0].position), _state])
	pt.note("RESULT", "%d:%02d over=%s winner=%s flags=%s obj=%s" % [int(g.clock) / 60, int(g.clock) % 60, g.over, r.winner_side, r.flags, r.obj])
	await pt.shot("final")


## RECKLESS: the Sire alone into the rival's den (the loss on purpose).
func b01_reckless() -> void:
	await pt.wait(1.0)
	var sire: Unit = tagged1("sire")
	await hand.escape()
	await hand.pick(sire)
	await hand.go(area_c("rival_den"), true)
	var until := float(a["until"])
	while not g.over and g.clock < until:
		await wait_tick(2.0)
		var s2 = tagged1("sire")
		if s2 and s2.order == "idle":
			await hand.escape()
			await hand.pick(s2)
			await hand.go(area_c("rival_den"), true)
	pt.note("RESULT", "%d:%02d over=%s winner=%s flags=%s" % [int(g.clock) / 60, int(g.clock) % 60, g.over, r.winner_side, r.flags])
	await pt.shot("final")


# ------------------------------------------------------------------ a03: THE LOST PLATEAU
## The whole party in group 1: a box round the camp at the start (Valadares, the men, the guides).
func party_group(team_tag := "party") -> void:
	var mine: Array = g.units.filter(func(u): return u.team == me and not u.dead and u.kind != "powder_wagon")
	if mine.is_empty():
		return
	var lo: Vector2 = mine[0].position
	var hi: Vector2 = mine[0].position
	for u in mine:
		lo = lo.min(u.position)
		hi = hi.max(u.position)
	await hand.escape()
	await hand.box(lo - Vector2(40, 50), hi + Vector2(40, 30))
	var got := g.selection.size()
	pt.note("HAND", "a box round the party picked %d of %d" % [got, mine.size()])
	if got < mine.size():
		for u in mine:
			if not g.selection.has(u):
				await hand.pick(u, true)
	await hand.group_set(1)


## The party (group 1) walks to `w` and waits until Valadares is there (or `secs` pass).
func party_to(w: Vector2, hero: String, secs := 120.0, attack := false) -> bool:
	var h = tagged1(hero)
	if h == null:
		return false
	await hand.group(1)
	if g.selection.is_empty():
		await party_group()
		await hand.group(1)
	await hand.go(w, attack)
	var t0 := g.clock
	var last_order := g.clock
	while not g.over and g.clock - t0 < secs:
		await wait_tick(1.0)
		h = tagged1(hero)
		if h == null:
			return false
		if h.position.distance_to(w) < 90.0:
			return true
		if h.order == "idle" and g.clock - last_order > 6.0:
			last_order = g.clock
			await hand.group(1)
			await hand.go(w, attack)
	return false


func stay(secs: float) -> void:
	var t0 := g.clock
	while not g.over and g.clock - t0 < secs:
		await wait_tick(1.0)


func a03_careful() -> void:
	await pt.wait(1.0)
	await party_group()
	var way_up := ["trail_w", "stair_foot", "stair_top"] if a.get("way", "stair") == "stair" else ["trail_e", "split_foot", "split_top"]
	for ar in way_up:
		await party_to(area_c(ar), "valadares")
	var marks := ["cairn", "source", "rim", "lookout"] if a.get("way", "stair") == "stair" else ["lookout", "rim", "source", "cairn"]
	for mk in marks:
		if g.over or r.fired.has("part3"):
			break
		await party_to(area_c(mk), "valadares", 150.0)
		pt.note("PLAN", "%d:%02d at %s, marks %d" % [int(g.clock) / 60, int(g.clock) % 60, mk, int(r.counters.get("marks", 0))])
		await pt.shot("mark_" + mk)
		var t0 := g.clock
		while not g.over and g.clock - t0 < 48.0 and not r.fired.has("part3"):
			await wait_tick(1.0)
	# down: by the way the Sire is not coming (the other way from where we are)
	var v = tagged1("valadares")
	var down := ["split_in", "split_top", "split_foot", "trail_e", "landing"] if v and v.position.x > 64 * Defs.TILE else ["stair_top", "stair_foot", "trail_w", "landing"]
	pt.note("PLAN", "%d:%02d going down by %s" % [int(g.clock) / 60, int(g.clock) % 60, down])
	for ar in down:
		if g.over:
			break
		await party_to(area_c(ar), "valadares", 150.0)
	while not g.over and g.clock < float(a["until"]):
		await wait_tick(2.0)
	await _result()


## Valadares walks straight into the nest's hollow (the loss on purpose / waking the nest early).
func a03_reckless() -> void:
	await pt.wait(1.0)
	await party_group()
	await party_to(area_c("stair_top"), "valadares")
	await party_to(area_c("nest_core"), "valadares", 200.0, true)
	while not g.over and g.clock < float(a["until"]):
		await wait_tick(2.0)
	await _result()


## THE NEST (the mirror): lay and grow, and from THE HUNT send everything at the mapmaker.
func a03_nest() -> void:
	var until := float(a["until"])
	var last_eco := -10.0
	while not g.over and g.clock < until:
		await wait_tick(2.0)
		var q := BroodNew.queen(g, me)
		if q == null:
			continue
		var gold := int(g.players[me]["gold"])
		if g.clock - last_eco > 5.0:
			last_eco = g.clock
			var grubs: Array = g.units.filter(func(u): return not u.dead and u.team == me and u.kind == "grub" and u.order != "nb_morph")
			var room := int(g.players[me]["cap"]) - g.supply_used(me)
			if room < 4 and not grubs.is_empty() and gold >= 100:
				var tp := spot("mound_turtle", q.position, grubs[0], 8, 14)
				if tp != Vector2.INF:
					await morph(grubs[0], "MOUND TURTLE", tp)
			elif r.count({"team": "nest", "kind": "grub"}) < 8 and gold >= 50:
				await lay("GRUB")
			elif gold >= 90:
				await lay("SPITTERS")
				await lay("RAPTORS")
		if r.obj.get("n_hunt", "") == "active":
			var v = r.tagged("valadares")
			if not v.is_empty():
				await army_to(v[0].position)
	await _result()


func _result() -> void:
	for h in ["valadares", "lindqvist", "sire", "old_mother", "pieter"]:
		var hs: Array = r.tagged(h, false)
		if not hs.is_empty() and is_instance_valid(hs[0]) and hs[0].dead:
			pt.note("RESULT", "%s died; last hit by %s at %s" % [h, hs[0].last_hit_by, g.cell_of(hs[0].position)])
	pt.note("RESULT", "%d:%02d over=%s winner=%s flags=%s counters=%s obj=%s" % [int(g.clock) / 60, int(g.clock) % 60, g.over, r.winner_side, r.flags, r.counters, r.obj])
	await pt.shot("final")


# ------------------------------------------------------------------ a05: THE SPECIMENS
func a05_careful() -> void:
	await pt.wait(1.0)
	await party_group()
	# the young: west, middle, east (a stay by each); the eggs if `eggs=1`
	for ar in ["young_m", "young_w", "young_e"]:
		if g.over or r.fired.has("dawn") or r.fired.has("part2"):
			break
		var w := area_c(ar) + Vector2(0, 2.5 * Defs.TILE)
		await party_to(w, "lindqvist", 150.0)
		pt.note("PLAN", "%d:%02d by %s caged=%d" % [int(g.clock) / 60, int(g.clock) % 60, ar, int(r.counters.get("caged", 0))])
		await pt.shot("net_" + ar)
		var t0 := g.clock
		var c0 := int(r.counters.get("caged", 0))
		while not g.over and g.clock - t0 < 25.0 and int(r.counters.get("caged", 0)) == c0:
			await wait_tick(1.0)
	if a.get("eggs", "") == "1" and not g.over:
		await party_to(area_c("hollow_w"), "lindqvist", 150.0)
		await party_to(area_c("egg_bed"), "lindqvist", 150.0)
		await stay(12.0)
	# then guard the carts down the trail (follow the first cart, attack-moving) and onto the quay
	var guard_t := 0.0
	while not g.over and g.clock < float(a["until"]):
		await wait_tick(2.0)
		var carts: Array = r.tagged("carts")
		var l = tagged1("lindqvist")
		if l == null:
			continue
		var to: Vector2
		if r.obj.get("landing", "") == "active" or carts.is_empty():
			to = area_c("quay")
		else:
			carts.sort_custom(func(x, y): return x.position.y < y.position.y)
			to = carts[carts.size() / 2].position + Vector2(0, 2 * Defs.TILE)
		if g.clock - guard_t > 6.0 and l.position.distance_to(to) > 140.0:
			guard_t = g.clock
			await hand.group(1)
			await hand.go(to, true)
	await _result()


func a05_reckless() -> void:
	await pt.wait(1.0)
	await party_group()
	await party_to(area_c("nest_core"), "lindqvist", 200.0, true)
	while not g.over and g.clock < float(a["until"]):
		await wait_tick(2.0)
	await _result()


## THE CREATURES (the mirror): grow, and once the carts roll send everything at the carts.
func a05_creatures() -> void:
	var until := float(a["until"])
	var last_eco := -10.0
	while not g.over and g.clock < until:
		await wait_tick(2.0)
		var q := BroodNew.queen(g, me)
		if q != null and g.clock - last_eco > 5.0:
			last_eco = g.clock
			var gold := int(g.players[me]["gold"])
			if r.count({"team": "creatures", "kind": "grub"}) < 8 and gold >= 50:
				await lay("GRUB")
			elif gold >= 90:
				await lay("RAPTORS")
		if r.obj.get("c_free", "") == "active":
			var carts: Array = r.tagged("carts")
			if not carts.is_empty():
				await hand.escape()
				await hand.army()
				await hand.hit(carts[0])
	await _result()
