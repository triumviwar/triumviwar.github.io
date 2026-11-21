extends "res://tools/playtest/pt_mission.gd"
## The Prologue, "The Leaf and the Fire" (p01_leaf), played as a human from the main menu.
##   -- style=careful|idle|reckless|killer  families=save|leave|none  diff=...  skip=1 (skip the stills)
##   careful : the army hunts the torch-bearers near the barns at night, the Barracks trains Musketeers, then the camps,
##             the choice, the gate, canister on the charge.
##   idle    : touches nothing after START (the mission must be lost, not stuck).
##   reckless: marches the whole army at the fort at once and leaves the plantation (should lose the barns or the night).
##   killer  : plays careful but sends Fairleigh and Tomasz alone into the rebels first (scripted people dead early).
var families := "save"
var skip := false
var _sent_heroes := false


func setup() -> void:
	mid = "p01_leaf"
	families = String(args.get("families", "save"))
	skip = args.has("skip")
	super.setup()
	tag += "_" + families


func play() -> void:
	if not await enter("map" if not args.has("list") else "list"):
		return
	await opening(skip)
	if g() == null:
		return
	note("card with the army: %s" % [card_labels()])
	await key(KEY_F2)
	await frames(2)
	note("F2 selects %d: %s" % [g().selection.size(), g().selection.map(func(e: Entity) -> String: return e.kind)])
	await shot("03_army")
	await play_for(4.0, 2.0)
	if style != "idle":
		# two groups as a player would make them: the left and the right halves of the line, boxed
		var army := team_units("governor", ["musketeer", "dismounted", "cannon"])
		army.sort_custom(func(a: Unit, b: Unit) -> bool: return a.global_position.x < b.global_position.x)
		var half := army.size() / 2
		await box_select(army.slice(0, half))
		note("box 1 selects %d" % g().selection.size())
		await group_set(2)
		await box_select(army.slice(half))
		note("box 2 selects %d" % g().selection.size())
		await group_set(3)
		await shot("03b_groups")
	await run_mission(float(args.get("limit", "2400")))
	await shot("07_last")
	print_said()
	note("choices seen: %s" % [choices_seen])
	await ending(not skip)
	note("progress after: %s" % [Campaign.progress().get("done", {}).get(mid, {})])


func think() -> void:
	var rr := r()
	if rr == null:
		return
	if style == "idle":
		return
	# a choice on screen
	if by_name("Choice_families") and families != "none":
		await choose_if("families", families)
	var reb := side_units("rebels")
	var dawn := rr.fired.has("dawn")
	if int(g().clock) % 20 < int(think_every):
		var bs: Array = rr.tagged("barns").map(func(b: Building) -> String: return "%d@%s" % [b.hp, b.cell])
		note("t=%d barns %s crown=%d rebels=%d torches=%d g2=%d g3=%d" % [g().clock, bs, side_units("crown").size(), reb.size(),
			reb.filter(func(u: Unit) -> bool: return u.has_meta("torch")).size(), g().groups[1].size(), g().groups[2].size()])
	if style == "reckless" and not dawn:
		await army_to(area("before_gate"))
		return
	if style == "killer" and not _sent_heroes and g().clock > 20.0:
		_sent_heroes = true
		for tg in ["fairleigh", "tomasz"]:
			var u: Array = rr.tagged(tg)
			if not u.is_empty():
				await look_at(u[0].global_position)
				await click_at(w2win(u[0].global_position))
				await key(KEY_M)
				await click_at(mini_win(area("camp1")))
				note("sent %s alone to camp1" % tg)
	await _train()
	if not dawn:
		var zone := rr.area_rect("plantation").grow(6 * Defs.TILE)
		var near := reb.filter(func(u: Unit) -> bool: return zone.has_point(u.global_position))
		if near.is_empty():
			await army_to(area("lawn"))
			return
		# the whole army (F2) right-clicks the most urgent foe: a torch-bearer counts as if 2.5 times nearer a barn
		var keep: Array = rr.tagged("barns") + rr.tagged("manor")
		near.sort_custom(func(a: Unit, b: Unit) -> bool:
			var da: float = a.global_position.distance_to(nearest(keep, a.global_position).global_position) * (0.4 if a.has_meta("torch") else 1.0)
			var db: float = b.global_position.distance_to(nearest(keep, b.global_position).global_position) * (0.4 if b.has_meta("torch") else 1.0)
			return da < db)
		await key(KEY_F2)
		await attack_unit(near[0])
		return
	# day: the camps, Hollins, the gate
	if not rr.tagged("camp1").is_empty():
		await army_to(centroid(rr.tagged("camp1")))
		return
	if families == "save" and rr.flags.get("families", "") == "save" and not rr.tagged("raiders").is_empty():
		await army_to(centroid(rr.tagged("raiders")))
		return
	if not rr.tagged("camp2").is_empty():
		await army_to(centroid(rr.tagged("camp2")))
		return
	if rr.obj.get("gate", "") == "active":
		await army_to(area("before_gate"), false)
		return
	if rr.obj.get("charge", "") == "active":
		# canister on the guns, then hold the line before the gate; once they come, fire at them
		var guns := team_units("governor", ["cannon"])
		if not guns.is_empty() and not has_meta("canister"):
			set_meta("canister", true)
			await look_at(guns[0].global_position)
			await click_at(w2win(guns[0].global_position))
			note("cannon picked: card %s" % [card_labels()])
			var st := await card("CANISTER")
			note("CANISTER on the card: %s" % st)
			await shot("05_canister")
		var mass := rr.tagged("mass")
		var charging := mass.filter(func(u: Unit) -> bool: return rr.area_rect("kill_zone").grow(4 * Defs.TILE).has_point(u.global_position))
		if not charging.is_empty():
			await army_to(centroid(charging))
		elif rr.fired.has("charge_go"):
			await army_to(centroid(mass) if not mass.is_empty() else area("fort"))
		else:
			await key(KEY_F2)
			await key(KEY_H)
		return
	# anything left: the fort
	if not reb.is_empty():
		await army_to(centroid(reb))


func _train() -> void:
	var gov := r().team_index("governor")
	if not has_meta("rally"):
		set_meta("rally", true)
		for b in g().buildings:
			if not b.dead and b.team == gov and b.kind == "barracks" and await pick(b):
				var st := await card("RALLY")
				await click_at(mini_win(Vector2(12.0, 47.0) * Defs.TILE))
				note("RALLY: %s -> %s" % [st, b.rally if "rally" in b else "?"])
	if int(g().players[gov]["gold"]) < 70:
		return
	for b in g().buildings:
		if not b.dead and b.team == gov and b.kind == "barracks" and b.queue.size() < 2:
			var st := await train(b, "MUSKETEER")
			if not has_meta("trained_note"):
				set_meta("trained_note", true)
				note("Barracks card: %s; MUSKETEER %s" % [card_labels(), st])
				await shot("04_barracks")
			return
