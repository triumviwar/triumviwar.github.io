extends "res://tools/playtest/pt_mission.gd"
## Act 1's "The Printing Houses" (a01_presses, Lyon), played as a human from the main menu (the Prologue's flags as a
## won Prologue left them: progress=p01).
##   -- style=careful|idle|reckless|killer  diff=...  skip=1
##   careful : Ctrl+click a Cuirassier = the riders (group 1) go round the houses' doors; Ctrl+click a Musketeer = the
##             muskets (group 2) hunt runners and break every press found; Tomasz (group 3) to the Weavers' Hall when
##             the hill is held; then the yard, the great press and Rouvière worn down and taken.
##   idle    : touches nothing (the city must rise and the mission be lost, not stuck).
##   reckless: the whole army straight up to the yard at the start (the doors are shut: what happens?).
##   killer  : Tomasz walked alone into the yard's men first.
var _tour: Array = []
var _tour_i := 0
var _dwell := 0.0
var _groups_made := false


func setup() -> void:
	mid = "a01_presses"
	if not args.has("progress"):
		args["progress"] = "p01"
	skip_cfg()
	super.setup()


func skip_cfg() -> void:
	pass


func play() -> void:
	if not await enter("map"):
		return
	await opening(args.has("skip"))
	if g() == null:
		return
	await play_for(4.0, 2.0)
	note("layout flag: %s" % r().flags.get("layout", "?"))
	await _make_groups()
	await run_mission(float(args.get("limit", "3000")))
	await shot("07_last")
	print_said()
	note("choices seen: %s; counters %s" % [choices_seen, r().counters if r() else {}])
	await ending(not args.has("skip"))
	note("progress after: %s" % [Campaign.progress().get("done", {}).get(mid, {})])


func _make_groups() -> void:
	if style == "idle":
		return
	var riders := team_units("garrison", ["cuirassier"])
	var muskets := team_units("garrison", ["musketeer"])
	if not riders.is_empty():
		await look_at(riders[0].global_position)
		await click_at(w2win(riders[0].global_position), MOUSE_BUTTON_LEFT, {"ctrl": true})
		note("Ctrl+click a Cuirassier selects %d (%s)" % [g().selection.size(), _kinds(g().selection)])
		await group_set(1)
	if not muskets.is_empty():
		await select_all(muskets)
		note("Musketeers selected: %d of %d" % [g().selection.size(), muskets.size()])
		await group_set(2)
	var tom := r().tagged("tomasz")
	if not tom.is_empty():
		await look_at(tom[0].global_position)
		await click_at(w2win(tom[0].global_position))
		note("click on Tomasz selects %s" % [_kinds(g().selection)])
		await group_set(3)
	await shot("03_groups")
	# the riders' round: every house lot, nearest first from the garrison
	var lots: Array = []
	for nm in r().data["areas"]:
		if String(nm).begins_with("cand_") or String(nm).begins_with("home_"):
			lots.append(String(nm))
	var at_p := area("garrison_yard")
	while not lots.is_empty():
		lots.sort_custom(func(a: String, b: String) -> bool: return area(a).distance_to(at_p) < area(b).distance_to(at_p))
		_tour.append(lots[0])
		at_p = area(lots[0])
		lots.remove_at(0)
	_groups_made = true


func _kinds(list: Array) -> String:
	var d := {}
	for e in list:
		d[e.kind] = int(d.get(e.kind, 0)) + 1
	return str(d)


func think() -> void:
	var rr := r()
	if rr == null or style == "idle":
		return
	if int(g().clock) % 60 < int(think_every):
		note("t=%d part %s temper %d closed %d garrison %d assembly %d tomasz %s" % [g().clock,
			"1" if not rr.fired.has("part2") else ("2" if not rr.fired.has("part3") else "3"), int(rr.counters.get("temper", 0)),
			int(rr.counters.get("closed", 0)), side_units("crown").size(), side_units("assembly").size(),
			"ok" if not rr.tagged("tomasz").is_empty() else "DEAD"])
	if style == "reckless" and not rr.fired.has("part2"):
		await army_to(area("yard"))
		return
	if style == "killer" and not has_meta("sent"):
		set_meta("sent", true)
		await group(3)
		await key(KEY_M)
		await click_at(mini_win(area("yard")))
		note("Tomasz sent alone to the yard")
	var foes := side_units("assembly")
	var found: Array = rr.tagged("presses").filter(func(b: Building) -> bool: return not b.has_meta("disguise_team"))
	if not rr.fired.has("part2"):
		# the muskets: a runner first, then a found press, else the middle of the squares
		var runners := foes.filter(func(u: Unit) -> bool: return String(u.get_meta("rebel_role", "")) == "runner" or rr.tagged("runner").has(u))
		await group(2)
		if not runners.is_empty():
			await attack_unit(nearest(runners, area("terreaux")))
		elif not found.is_empty():
			await attack_unit(nearest(found, centroid(team_units("garrison", ["musketeer"]))))
		else:
			await army_sel_to(area("terreaux"))
		# the riders: a found press near them, else on with the round of the doors
		var riders := team_units("garrison", ["cuirassier"])
		if riders.is_empty():
			return
		await group(1)
		if not found.is_empty() and nearest(found, centroid(riders)).global_position.distance_to(centroid(riders)) < 14 * Defs.TILE:
			await attack_unit(nearest(found, centroid(riders)))
			return
		var here := area(_tour[_tour_i])
		var moving := riders.any(func(u: Unit) -> bool: return u.velocity.length() > 8.0)
		if not moving and centroid(riders).distance_to(here) < 5 * Defs.TILE:
			_dwell += think_every
			if _dwell >= 4.0:
				_dwell = 0.0
				_tour_i = (_tour_i + 1) % _tour.size()
				await key(KEY_M)
				await click_at(mini_win(area(_tour[_tour_i])))
		elif not moving:
			await key(KEY_M)
			await click_at(mini_win(here))
		return
	if not rr.fired.has("part3"):
		# the hill: everyone up to the hall's square; Tomasz once the men are there
		var top := area("hall_square")
		var hill_foes := foes.filter(func(u: Unit) -> bool: return rr.area_rect("hilltop_all").grow(4 * Defs.TILE).has_point(u.global_position))
		# the muskets between the square and the stairs (the bands come up them); the riders on whoever is closest to
		# Tomasz
		await group(2)
		await army_sel_to(top + Vector2(0, 5 * Defs.TILE))
		await group(1)
		var tomp: Vector2 = rr.tagged("tomasz")[0].global_position if not rr.tagged("tomasz").is_empty() else top
		if not hill_foes.is_empty():
			await attack_unit(nearest(hill_foes, tomp))
		else:
			await army_sel_to(top + Vector2(0, 2 * Defs.TILE))
		var there := team_units("garrison", ["musketeer", "cuirassier"]).filter(func(u: Unit) -> bool: return u.global_position.distance_to(top) < 10 * Defs.TILE).size()
		if rr.obj.get("speech", "") == "done" and not has_meta("tomasz_back"):
			set_meta("tomasz_back", true)
			await group(3)
			await key(KEY_M)
			await click_at(mini_win(rr.area_rect("hall_square").position + Vector2(2.5, 1.5) * Defs.TILE))
			note("t=%d Tomasz back behind the hall after his speech" % g().clock)
		if there >= 4 and not has_meta("tomasz_up"):
			set_meta("tomasz_up", true)
			await group(3)
			await key(KEY_M)
			await click_at(mini_win(top))
			note("t=%d Tomasz sent to the hall square (%d men there)" % [g().clock, there])
		return
	# the yard: the great press and Rouvière
	var pr := rr.tagged("printer")
	var gp := rr.tagged("great_press")
	var yard_foes := foes.filter(func(u: Unit) -> bool: return u.global_position.distance_to(area("yard")) < 12 * Defs.TILE and not pr.has(u))
	for gi in [2, 1]:
		await group(gi)
		if not yard_foes.is_empty():
			await attack_unit(nearest(yard_foes, centroid(team_units("garrison", ["musketeer"]))))
		elif not pr.is_empty() and not rr.captured.has("printer"):
			await attack_unit(pr[0])
		elif not gp.is_empty():
			await attack_unit(gp[0])
		else:
			await army_sel_to(area("yard"))
