extends "res://tools/playtest/pt_setup_util.gd"
## A Crown player who tries to WIN a skirmish (docs/playtest_2026_11_21_skirmish_crown.md), acting only through
## the mouse and keys: the setup screen, then labourers, a build order placed with the mouse, Musketeers and guns,
## control groups, attack-moves by the minimap, rally points, a push when the army is big enough.
##   args: opp=BROOD|CROWN|CLOCKWORK who="HARD AI" plan=OPTIMAL map=<label> mins=<game minutes cap> speed=<time scale>
##         style=careful|fast

var opp := "BROOD"
var who := "HARD AI"
var plan := "OPTIMAL"
var map_label := ""
var mins := 22.0
var speed := 2.0
var style := "careful"
var order: Array = []          # the build order still to place
var placed := {}               # kind -> count placed by us
var last_shot_min := -1
var attacking := false
var pushes := 0
var hall_cell := Vector2i.ZERO
var enemy_guess := Vector2.ZERO
var stats := {"refused": 0, "placed": 0, "trained": 0, "pushes": 0}


func run() -> void:
	opp = String(args.get("opp", opp))
	who = String(args.get("who", who)).replace("_", " ")
	plan = String(args.get("plan", plan))
	map_label = String(args.get("map", "")).replace("_", " ")
	mins = float(args.get("mins", mins))
	speed = float(args.get("speed", speed))
	style = String(args.get("style", style))
	await wait_real(1.0)
	await setup_1v1(who, opp, plan, map_label)
	await shot("setup")
	await press_button("START")
	await wait_match()
	Engine.time_scale = speed
	var g := game()
	step("match on map %s seed %s, me team %d, %s v %s %s" % [g.map_id, str(main.last_cfg.get("seed")), g.human, "crown", opp, plan])
	var hall = my_buildings("town_hall")[0]
	hall_cell = hall.cell
	enemy_guess = _enemy_start()
	order = ["cottage", "farm", "barracks", "powder_mill", "town_hall", "foundry", "cottage", "farm", "farm", "powder_mill", "horse_breeder", "barracks", "armoury", "cottage", "barracks", "town_hall", "farm", "farm", "powder_mill", "church"]
	await shot("start")
	# the first look: every group key and the camera
	while not g.over and g.clock < mins * 60.0:
		await _think()
		if int(g.clock / 60.0) != last_shot_min and int(g.clock / 60.0) % 3 == 0:
			last_shot_min = int(g.clock / 60.0)
			await shot("min%02d" % last_shot_min)
		await wait(1.5 if style == "careful" else 0.6)
	Engine.time_scale = 1.0
	step("RESULT over=%s winner=%s clock=%.0f stats=%s" % [g.over, str(g.winner), g.clock, str(stats)])
	_report_state()
	await shot("end_state")
	if g.over:
		await wait_real(3.0)
		await shot("end_screen")
		step("end screen buttons: " + list_buttons())


func _enemy_start() -> Vector2:
	var g := game()
	for b in g.buildings:
		if is_instance_valid(b) and b.team != g.human and b.team >= 0:
			return b.position
	for u in g.units:
		if is_instance_valid(u) and u.team != g.human and u.team >= 0:
			return u.position
	return Vector2(Game.W, Game.H) * Game.T - my_buildings("town_hall")[0].position


func _report_state() -> void:
	var g := game()
	var kinds := {}
	for u in my_units():
		kinds[u.kind] = int(kinds.get(u.kind, 0)) + 1
	var bk := {}
	for b in my_buildings():
		bk[b.kind] = int(bk.get(b.kind, 0)) + 1
	step("STATE %.0fs gold %d powder %d supply %d/%d units %s buildings %s" % [g.clock, int(res()["gold"]), int(res().get("res2", 0)),
		g.supply_used(g.human), int(res()["cap"]), str(kinds), str(bk)])


# ------------------------------------------------------------------ the brain

func _think() -> void:
	var g := game()
	if g.over:
		return
	var halls_built := my_buildings("town_hall").filter(func(b) -> bool: return b.built).size()
	if my_buildings("farm").size() < 2 * halls_built and not order.has("farm"):
		order.push_front("farm")
	if my_buildings("powder_mill").size() < halls_built and not order.has("powder_mill") and halls_built >= 2:
		order.append("powder_mill")
	if int(g.clock) % 30 < 2:
		_report_state()
	await _defend()
	await _workers()
	await _build_next()
	await _train_army()
	await _research()
	await _attack()


func _supply_free() -> int:
	var g := game()
	return int(res()["cap"]) - g.supply_used(g.human)


## Labourers: the hall trains while under ~ 8 per hall + 6 for the Mill; idle ones go back to work.
func _workers() -> void:
	var halls := my_buildings("town_hall").filter(func(b) -> bool: return b.built)
	var labs := my_units("labourer").size()
	var want := mini(22 * halls.size(), 66)
	if labs < want and int(res()["gold"]) >= 50 and _supply_free() >= 1:
		for h in halls:
			if (h.queue as Array).size() < 2:
				await select_ent(h)
				var r := await card("LABOURER")
				if r == "ok":
					stats["trained"] += 1
				break
	# idle workers: F1, then right-click a farm (or the mill) with room
	var bar = hud().bar
	var idle := my_units("labourer").filter(func(u) -> bool: return u.order == "idle" or u.order == "")
	if idle.size() > 0:
		await key(KEY_F1)
		await settle()
		var target = _work_target()
		if target:
			var p := await look_at(ent_point(target))
			await rclick(p)
			step("idle labourers (%d) sent to %s" % [idle.size(), target.kind])


func _work_target():
	for k in ["powder_mill", "farm"]:
		for b in my_buildings(k):
			if b.built and b.working_crew() < b.crew_max():
				return b
	var fs := my_buildings("farm")
	return fs[0] if not fs.is_empty() else null


## Places the next building of the order with a labourer, as a player does: select one, B, the button, click a spot.
func _build_next() -> void:
	if order.is_empty():
		return
	var k: String = order[0]
	var price: int = game().build_price(game().human, k)
	if int(res()["gold"]) < price:
		return
	# a building of the order still a ghost (nobody went): wait
	var spot := _spot_for(k)
	if spot.x < 0:
		step("no spot yet for %s: later" % k)
		order.pop_front()
		if k in ["farm", "powder_mill"] and int(placed.get("deferred_" + k, 0)) < 6:
			placed["deferred_" + k] = int(placed.get("deferred_" + k, 0)) + 1
			order.append(k)
		return
	var lab = _a_labourer()
	if lab == null:
		return
	await select_ent(lab)
	if not game().selection.has(lab):
		step("clicked for a labourer, got %s" % str(game().selection.map(func(x) -> String: return x.kind)))
	if find_card("BUILD").is_empty():
		return
	await card("BUILD")
	await settle()
	var label := _build_label(k)
	var r := await card(label)
	if r != "ok":
		stats["refused"] += 1
		if r == "missing":
			finding("BUILD: no '%s' button on the build page (card: %s)" % [label, ", ".join(card_labels())])
			order.pop_front()
		await key(KEY_ESCAPE)
		return
	var size: Vector2i = Defs.BUILDINGS[k]["size"]
	var w := Vector2(spot) * Defs.TILE + Vector2(size) * Defs.TILE * 0.5
	var p := await look_at(w)
	p = w2s(w)
	await move(p, 3)
	await frames(2)
	var before := my_buildings(k).size()
	await click(p)
	await settle()
	if my_buildings(k).size() > before:
		stats["placed"] += 1
		placed[k] = int(placed.get(k, 0)) + 1
		step("placed %s at %s" % [k, str(spot)])
		order.pop_front()
	else:
		stats["refused"] += 1
		step("placing %s at %s refused: toast '%s' mode '%s'" % [k, str(spot), toast_text(), hud().controls.mode])
		await key(KEY_ESCAPE)


func _build_label(k: String) -> String:
	match k:
		"powder_mill": return "POWDER"
		"farm": return "FARM"
		"wall": return "PALISADE"
	return String(Defs.BUILDINGS[k]["name"]).to_upper()


func _a_labourer():
	var best = null
	for u in my_units("labourer"):
		if u.order == "haul" or (u.has_method("is_hauler") and u.is_hauler()):
			continue
		if best == null or u.position.distance_to(Vector2(hall_cell) * Defs.TILE) < best.position.distance_to(Vector2(hall_cell) * Defs.TILE):
			best = u
	return best


## A free spot near the right hall (a second Town Hall: the expansion spot the game tints gold).
func _spot_for(k: String) -> Vector2i:
	var g := game()
	if k == "town_hall":
		var best := Vector2i(-1, -1)
		if g.exp_spots:
			var spots: Array = g.exp_spots.spots.filter(func(s: Dictionary) -> bool: return int(s["team"]) == g.human)
			spots.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["rank"]) < int(b["rank"]))
			for sp in spots:
				if g.placement_problem(g.human, k, sp["c"]) == "":
					return sp["c"]
		for r in range(16, 34):
			for a in 48:
				var c := hall_cell + Vector2i(Vector2(r, 0).rotated(TAU * a / 48.0))
				if g.placement_problem(g.human, k, c) == "":
					return c
		return best
	var centres: Array = [hall_cell]
	if k in ["farm", "powder_mill"]:
		centres = []
		for h in my_buildings("town_hall"):
			if h.built:
				centres.append(h.cell)
	for hc in centres:
		var ring_from := 5 if k in ["farm", "powder_mill"] else 6
		for r in range(ring_from, 22 if k not in ["farm", "powder_mill"] else 12):
			for a in 32:
				var c: Vector2i = hc + Vector2i(Vector2(r, 0).rotated(TAU * (a + seed_n) / 32.0))
				if g.placement_problem(g.human, k, c) == "":
					return c
	return Vector2i(-1, -1)


## Production through F3 (MAKE: every building that makes something), as the HOW TO PLAY suggests: one press of
## MUSKETEER queues at the least busy Barracks.
func _train_army() -> void:
	var going_up := my_buildings("cottage").filter(func(b) -> bool: return not b.built).size()
	var need := 6 + 3 * my_buildings("barracks").size()
	if _supply_free() < need and going_up == 0 and (order.is_empty() or order[0] != "cottage") and int(res()["cap"]) < 200:
		order.push_front("cottage")
	if _supply_free() < 2:
		return
	var rax := my_buildings("barracks").filter(func(b) -> bool: return b.built)
	var fdy := my_buildings("foundry").filter(func(b) -> bool: return b.built)
	if rax.is_empty():
		return
	var idle_rax := rax.filter(func(b) -> bool: return (b.queue as Array).size() < 2).size()
	if idle_rax == 0 and (fdy.is_empty() or (fdy[0].queue as Array).size() > 0):
		return
	await key(KEY_F3)
	await settle()
	for i in idle_rax:
		if int(res()["gold"]) < 60:
			break
		var want := "MUSKETEER"
		if not my_buildings("horse_breeder").is_empty() and my_units("cuirassier").size() < 4 and randf() < 0.25:
			want = "HORSEMAN"
		var r := await card(want)
		if r == "ok":
			stats["trained"] += 1
	if not fdy.is_empty() and (fdy[0].queue as Array).is_empty() and int(res()["gold"]) > 260 and my_units("cannon").size() < 5:
		var r2 := await card("FIELD CANNON")
		if r2 == "ok":
			stats["trained"] += 1
	for b in rax:
		if not b.has_meta("pt_rally"):
			await select_ent(b)
			if game().selection.has(b) and not find_card("RALLY").is_empty():
				await card("RALLY")
				var w: Vector2 = my_buildings("town_hall")[0].position.lerp(enemy_guess, 0.15)
				await click(await look_at(w))
				b.set_meta("pt_rally", true)


func _built(b) -> bool:
	return b.built


var researched := {}


func _research() -> void:
	for a in my_buildings("armoury"):
		if not _built(a) or (a.queue as Array).size() > 0:
			continue
		await select_ent(a)
		for r in ["MATCHLOCK", "BAYONET", "FLINTLOCK", "ARMOUR", "POUCH", "CHARGES"]:
			if researched.has(r):
				continue
			var b := find_card(r)
			if not b.is_empty() and b["enabled"]:
				await card(r)
				researched[r] = true
				return


func _army() -> Array:
	return my_units().filter(func(u) -> bool: return not u.is_worker() and u.kind != "horse" and u.kind != "gun_crewman" and u.kind != "missionary")


func _attack() -> void:
	var army := _army()
	var g := game()
	var asup := 0
	for u in army:
		asup += int(u.d.get("supply", 1))
	if (asup >= 44 + pushes * 10 or _supply_free() < 4 and asup > 30) and not attacking:
		attacking = true
		pushes += 1
		stats["pushes"] += 1
		step("PUSH %d with %d" % [pushes, army.size()])
		await key(KEY_F2)
		await settle()
		await ctrl_key(KEY_1)
		await key(KEY_A)
		var m: Rect2 = hud().mini_rect()
		var f := enemy_guess / (Vector2(Game.W, Game.H) * Game.T)
		await press((m.position + f * m.size) * hud().ui_scale)
		await shot("push%d" % pushes)
	elif attacking and army.size() < 6:
		attacking = false
		step("push %d over, army down to %d" % [pushes, army.size()])
	elif attacking and int(g.clock) % 20 < 2:
		# keep them going: recall group 1 and attack-move again (new units join with F2)
		await key(KEY_F2)
		await settle()
		await key(KEY_A)
		var target := _nearest_enemy_building()
		var m: Rect2 = hud().mini_rect()
		var f := target / (Vector2(Game.W, Game.H) * Game.T)
		await press((m.position + f * m.size) * hud().ui_scale)


func _nearest_enemy_building() -> Vector2:
	var g := game()
	var best := enemy_guess
	var bd := INF
	var home: Vector2 = my_buildings("town_hall")[0].position if not my_buildings("town_hall").is_empty() else Vector2.ZERO
	for b in g.buildings:
		if is_instance_valid(b) and not b.dead and b.team >= 0 and b.team != g.human and g.is_visible_to(g.human, b.position):
			var d := home.distance_to(b.position)
			if d < bd:
				bd = d
				best = b.position
	for u in g.units:
		if is_instance_valid(u) and not u.dead and u.team >= 0 and u.team != g.human and u.kind == "brood_mother":
			return u.position
	return best


func _foes_near(p: Vector2) -> int:
	var g := game()
	var n := 0
	for u in g.units:
		if is_instance_valid(u) and not u.dead and u.team >= 0 and u.team != g.human and not u.is_worker() and u.position.distance_to(p) < 8 * Defs.TILE:
			n += 1
	return n


## Enemies near home: the army comes back (F2, A, click at home).
func _defend() -> void:
	var g := game()
	var halls := my_buildings("town_hall")
	if halls.is_empty():
		return
	for u in g.units:
		if is_instance_valid(u) and not u.dead and u.team >= 0 and u.team != g.human and not u.is_worker():
			for h in halls:
				if u.position.distance_to(h.position) < 14 * Defs.TILE and _foes_near(u.position) >= 3:
					if attacking and _army().size() > 12:
						return
					attacking = false
					await key(KEY_F2)
					await settle()
					await key(KEY_A)
					await click(await look_at(u.position))
					step("defend at %s against %s" % [str(Vector2i(u.position / Defs.TILE)), u.kind])
					return
