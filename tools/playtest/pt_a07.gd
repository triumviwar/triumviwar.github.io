extends "res://tools/playtest/pt_mission.gd"
## Act 1's "The Council of Rome" (a07_council), played as a human from the main menu, the Crown's side (progress=all:
## every Act 1 mission before it won on its canon).
##   -- style=careful|idle|reckless|killer  diff=...  skip=1
##   careful : the verdict (the mid-match show) read; Tomasz (group 3) with the riders (1) calls each quarter's people
##             (Campo Marzio, Parione, Regola); the muskets (2) put out the nearest fire; from Part 3 the muskets hold
##             the Ponte Sant'Angelo, the guns (4) the Ponte Ripetta, the riders the Ponte Sisto, till dawn.
##   idle    : touches nothing (what happens: the creatures cross? the King dies? stuck?).
##   reckless: the whole army over the river to the stables at once.
##   killer  : the young King walked alone over the Ponte Sant'Angelo.
var _quarters := ["popolo_square", "navona", "campo_fiori"]
var _qi := 0


func setup() -> void:
	mid = "a07_council"
	if not args.has("progress"):
		args["progress"] = "all"
	super.setup()


func play() -> void:
	if not await enter("map"):
		return
	await opening(args.has("skip"))
	if g() == null:
		return
	await play_for(1.5, 2.0)
	# the verdict: a show in the match (it pauses the match); read it page by page
	var n := 0
	for i in 200:
		await frames(2)
		if by_name("StillShow"):
			break
	while by_name("StillShow") and n < 30:
		await shot("04_verdict_%02d" % n)
		await press_name("Show_NEXT")
		n += 1
		await frames(4)
	note("the verdict show: %d pages read; shows recorded %d" % [n, r().shows.size() if r() else -1])
	if style != "idle":
		for it in [[1, ["cuirassier"]], [2, ["musketeer"]], [4, ["cannon"]]]:
			var us := team_units("guard", it[1])
			if us.is_empty():
				continue
			await select_all(us)
			note("%d of %d %s selected" % [g().selection.size(), us.size(), it[1][0]])
			await group_set(int(it[0]))
		var tom := r().tagged("tomasz")
		if not tom.is_empty():
			await look_at(tom[0].global_position)
			await click_at(w2win(tom[0].global_position))
			await group_set(3)
		await shot("03_groups")
	await run_mission(float(args.get("limit", "3600")))
	await shot("07_last")
	print_said()
	note("counters %s; flags %s; fires out %d" % [r().counters if r() else {}, r().flags if r() else {}, r().fires_out if r() else -1])
	await ending(not args.has("skip"))
	note("progress after: %s" % [Campaign.progress().get("done", {}).get(mid, {})])


func think() -> void:
	var rr := r()
	if rr == null or style == "idle" or by_name("StillShow"):
		return
	if int(g().clock) % 60 < int(think_every):
		note("t=%d part %s saved %d stood %d burning %d crown %d creatures %d automata %d assembly %d king %s tomasz %s dawn %s" % [
			g().clock, "3" if rr.fired.has("part3") else ("2" if rr.fired.has("part2") else "1"), int(rr.counters.get("saved", 0)),
			int(rr.counters.get("stood", 0)), rr.burning_count("houses"), side_units("crown").size(), side_units("creatures").size(),
			side_units("automata").size(), side_units("assembly").size(), "ok" if not rr.tagged("king").is_empty() else "DEAD",
			"ok" if not rr.tagged("tomasz").is_empty() else "DEAD", rr.clocks.get("dawn", "-")])
	if style == "reckless":
		await army_to(area("stables"))
		return
	if style == "killer" and not has_meta("sent"):
		set_meta("sent", true)
		var k := rr.tagged("king")
		if not k.is_empty():
			await look_at(k[0].global_position)
			await click_at(w2win(k[0].global_position))
			await key(KEY_M)
			await click_at(mini_win(area("navona")))
			note("the King sent alone to the Navona")
	if not rr.fired.has("part2"):
		return
	if not rr.fired.has("part3"):
		# Tomasz to the next quarter (the riders with him), once its people are called or fled
		while _qi < _quarters.size():
			var q := String(["campo_marzio", "parione", "regola"][_qi])
			if rr.fired.has("call_" + q) or rr.fired.has("flee_" + q) or rr.fired.has("smoke_" + q):
				_qi += 1
				continue
			break
		if _qi < _quarters.size():
			var to := area(_quarters[_qi])
			await group(3)
			await key(KEY_M)
			await click_at(mini_win(to))
			await group(1)
			await army_sel_to(to + Vector2(2 * Defs.TILE, 2 * Defs.TILE))
		else:
			await group(3)
			await key(KEY_M)
			await click_at(mini_win(area("piazza_in")))
		# the muskets: the nearest fire
		var fires: Array = []
		for it in rr._burning:
			if is_instance_valid(it["b"]) and not it["b"].dead:
				fires.append(it["b"])
		await group(2)
		if not fires.is_empty():
			var f: Node2D = nearest(fires, centroid(team_units("guard", ["musketeer"])))
			await key(KEY_M)
			await click_at(mini_win(f.global_position + Vector2(0, 2.5 * Defs.TILE)))
		return
	# Part 3: the bridges
	for it in [[2, "ponte_sant_angelo_w"], [4, "ponte_ripetta_w"], [1, "ponte_sisto_w"], [3, "piazza_in"]]:
		await group(int(it[0]))
		if int(it[0]) == 3:
			await key(KEY_M)
			await click_at(mini_win(area(String(it[1]))))
		else:
			await army_sel_to(area(String(it[1])))
