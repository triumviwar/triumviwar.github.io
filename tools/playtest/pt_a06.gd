extends "res://tools/playtest/pt_mission.gd"
## Act 1's "The Barricades of Paris" (a06_barricades), played as a human from the main menu (progress=a01: the
## Prologue and Lyon won).
##   -- style=careful|idle|reckless|killer  varenne=spared|executed|none  diff=...  skip=1
##   careful : Ctrl+click picks the riders (1), the muskets (2), the Field Cannons (4), the Mortar (5). Each barricade:
##             the guns on its palisade, the Mortar on the men behind, the muskets before it, CANISTER for the rush,
##             then in; the bridges; the riders on the Petit Pont's torch-bearers; the hall's ring broken, Varenne
##             worn down and taken; the verdict.
##   idle    : touches nothing (the King's patience must run out: lost, not stuck).
##   reckless: the whole army down the street at once.
##   killer  : Fairleigh walked alone into the first barricade.
var verdict := "spared"


func setup() -> void:
	mid = "a06_barricades"
	if not args.has("progress"):
		args["progress"] = "a01"
	verdict = String(args.get("varenne", verdict))
	super.setup()
	tag += "_" + verdict


func play() -> void:
	if not await enter("map"):
		return
	await opening(args.has("skip"))
	if g() == null:
		return
	await play_for(4.0, 2.0)
	if style != "idle":
		for it in [[1, ["cuirassier"]], [2, ["musketeer"]], [4, ["cannon"]], [5, ["mortar"]]]:
			var us := team_units("army", it[1]).filter(func(u: Unit) -> bool: return not r().tagged("volunteers").has(u))
			if us.is_empty():
				continue
			await select_all(us)
			note("Ctrl+click / Shift+double-click: %d of %d %s selected (%s)" % [g().selection.size(), us.size(), it[1][0], _kinds(g().selection)])
			await group_set(int(it[0]))
		# the two who must live stay in the camp: HOLD (an idle Missionary walks off by himself to the wounded and
		# the fallen, into the fight: that is how Tomasz died in the first runs)
		if not args.has("nohold"):
			for tg in ["tomasz", "fairleigh"]:
				var u: Array = r().tagged(tg)
				if not u.is_empty():
					await look_at(u[0].global_position)
					await click_at(w2win(u[0].global_position))
					await key(KEY_H)
					note("%s on HOLD (selected: %s, order %s)" % [tg, _kinds(g().selection), u[0].order])
		await shot("03_groups")
		note("volunteers (the Hollins): %d" % r().tagged("volunteers").size())
	await run_mission(float(args.get("limit", "3600")))
	await shot("07_last")
	print_said()
	note("choices seen: %s; counters %s; flags %s" % [choices_seen, r().counters if r() else {}, r().flags if r() else {}])
	await ending(not args.has("skip"))
	note("progress after: %s" % [Campaign.progress().get("done", {}).get(mid, {})])
	await after_win()


func think() -> void:
	var rr := r()
	if rr == null or style == "idle":
		return
	if int(g().clock) % 60 < int(think_every):
		note("t=%d taken %d bridges %d army %d assembly %d fairleigh %s tomasz %s patience %s nd %s" % [g().clock,
			int(rr.counters.get("taken", 0)), int(rr.counters.get("bridges", 0)), side_units("crown").size(),
			side_units("assembly").size(), "ok" if not rr.tagged("fairleigh").is_empty() else "DEAD",
			"ok" if not rr.tagged("tomasz").is_empty() else "DEAD", rr.clocks.get("patience", "-"),
			int(rr.tagged("notre_dame")[0].hp) if not rr.tagged("notre_dame").is_empty() else -1])
	if int(g().clock) % 60 < int(think_every) and not rr.fired.has("part2"):
		for k in [1, 2, 3]:
			var ms: Array = rr.tagged("bar_%d_men" % k)
			note("   bar %d: wall %s, men %d at %s" % [k, rr.tagged("bar_%d_wall" % k).map(func(b: Building) -> Vector2i: return b.cell), ms.size(),
				ms.map(func(u: Unit) -> Vector2i: return g().cell_of(u.global_position))])
	if by_name("Choice_varenne") and verdict != "none":
		await choose_if("varenne", verdict)
	if style == "reckless" and not rr.fired.has("part2"):
		await army_to(area("rue_saint_antoine"))
		return
	if style == "killer" and not has_meta("sent"):
		set_meta("sent", true)
		var f := rr.tagged("fairleigh")
		if not f.is_empty():
			await look_at(f[0].global_position)
			await click_at(w2win(f[0].global_position))
			await key(KEY_M)
			await click_at(mini_win(area("bar_1_behind")))
			note("Fairleigh sent alone to the first barricade")
	var foes := side_units("assembly")
	if not rr.fired.has("part2"):
		var i := 0
		for k in [1, 2, 3]:
			if not rr.tagged("bar_%d_men" % k).is_empty() or rr.tagged("bar_%d_wall" % k).size() > 4:
				i = k
				break
		if i == 0:
			return
		var wall: Array = rr.tagged("bar_%d_wall" % i)
		if wall.size() <= 4:
			wall = []          # (a way through: in)
		var men := rr.tagged("bar_%d_men" % i)
		var rush := foes.filter(func(u: Unit) -> bool: return rr.tagged("rush").has(u) or rr.tagged("sortie").has(u))
		var near_rush := rush.filter(func(u: Unit) -> bool: return u.global_position.x > area("bar_%d" % i).x - 6 * Defs.TILE)
		# canister on the guns once the first rush comes
		if not near_rush.is_empty() and not has_meta("canister"):
			set_meta("canister", true)
			await group(4)
			note("t=%d rush: guns' card %s" % [g().clock, card_labels()])
			note("CANISTER: %s" % await card("CANISTER"))
			await shot("05_canister")
		await group(2)
		if not near_rush.is_empty():
			await attack_unit(nearest(near_rush, area("bar_%d_front" % i)))
		elif not wall.is_empty():
			await army_sel_to(area("bar_%d_front" % i) + Vector2(5 * Defs.TILE, 0))
		else:
			await army_sel_to(area("bar_%d_behind" % i))
		# guns out of powder (the toast says so): RELOAD (R) sends them to the nearest powder and back
		var dry := team_units("army", ["cannon", "mortar"]).filter(func(u: Unit) -> bool: return u.powder < 1.0 and u.order != "reload")
		if not dry.is_empty() and not has_meta("reload_%d" % int(g().clock / 30.0)):
			set_meta("reload_%d" % int(g().clock / 30.0), true)
			await group(4)
			note("t=%d %d guns dry: RELOAD %s" % [g().clock, dry.size(), await card("RELOAD")])
		# (only what the player can see: a palisade in the fog is no target, a right-click there is a walk; the riders
		# go ahead to show it)
		var seen_wall := wall.filter(func(b: Building) -> bool: return g().shown_to_commander(b))
		if not wall.is_empty() and seen_wall.is_empty():
			await group(1)
			await army_sel_to(area("bar_%d_front" % i) + Vector2(2 * Defs.TILE, 0))
		wall = seen_wall
		if not wall.is_empty():
			await group(4)
			var wt: Node2D = nearest(wall, area("bar_%d_front" % i))
			var guns := team_units("army", ["cannon"])
			if not guns.is_empty() and centroid(guns).distance_to(wt.global_position) < 9 * Defs.TILE and card_labels().has("UNLIMBER"):
				note("t=%d guns in reach of the palisade: UNLIMBER %s" % [g().clock, await card("UNLIMBER")])
			await attack_unit(wt)
		else:
			await group(4)
			await army_sel_to(area("bar_%d_front" % i) + Vector2(4 * Defs.TILE, 0))
		if not men.is_empty():
			await group(5)
			await attack_unit(nearest(men, area("bar_%d" % i)))
		if not seen_wall.is_empty() or rr.tagged("bar_%d_wall" % i).size() <= 4:
			await group(1)
			await army_sel_to(area("bar_%d_front" % i) + Vector2(7 * Defs.TILE, 0))
		return
	if not rr.fired.has("part3"):
		var torches := rr.tagged("torches")
		await group(1)
		if not torches.is_empty():
			await attack_unit(nearest(torches, area("notre_dame")))
		else:
			await army_sel_to(area("parvis"))
		await group(2)
		var nd_men := rr.tagged("bridge_nd_men")
		var ch_men := rr.tagged("bridge_ch_men")
		if not nd_men.is_empty():
			await army_sel_to(centroid(nd_men))
		elif not ch_men.is_empty():
			await army_sel_to(centroid(ch_men))
		else:
			await army_sel_to(area("parvis"))
		await group(4)
		await army_sel_to(area("north_bank_bridges"))
		return
	# the hall: the ring's palisade, the square, Varenne
	var ring := rr.tagged("ring")
	var va := rr.tagged("varenne")
	await group(1)
	await army_sel_to(area("port"))
	if not ring.is_empty() and rr.count({"side": "crown", "area": "hall_square"}) == 0:
		await group(4)
		await attack_unit(nearest(ring, area("rue_saint_antoine")))
		await group(2)
		await army_sel_to(area("rue_saint_antoine"))
		return
	var hall_foes := foes.filter(func(u: Unit) -> bool: return not va.has(u) and u.global_position.distance_to(area("greve")) < 14 * Defs.TILE)
	await group(2)
	if not hall_foes.is_empty():
		await attack_unit(nearest(hall_foes, centroid(team_units("army", ["musketeer"]))))
	elif not va.is_empty() and not rr.captured.has("varenne"):
		await attack_unit(va[0])
	await group(4)
	await army_sel_to(area("greve"))


func _kinds(list: Array) -> String:
	var d := {}
	for e in list:
		d[e.kind] = int(d.get(e.kind, 0)) + 1
	return str(d)


## The palisade pieces across the street's middle (rows 30-32): those must go for a way through.
func _mid(ws: Array) -> Array:
	return ws.filter(func(b: Building) -> bool: return is_instance_valid(b) and b.cell.y >= 29 and b.cell.y <= 32)
