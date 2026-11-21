extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 1's "Father Ferrer's Visit" (docs/campaign_a04_build.md) with a simple bot and prints, every minute, how it
## goes: the part, the workshops seen, the night Winder, the riot, the lost to the machine, Ferrer and Hollweg. A balance
## check: a player who plays it wins on EASY / NORMAL / HARD in a sensible time and loses few automata to the machine;
## a player who does nothing loses at dusk (the works shut with the inspection unfinished).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_a04.gd -- [active] [furth=strong|thin]
##        [jakob=alive|lost] [gate=pattern|people] [diff=easy|normal|hard] [broken=melted|kept] [until=<seconds>]
##        [careless] (the party walks right up to the night Winder: it turns back every time)
## The flags are written into the progress file for the run (and the player's own progress put back after).
## The bot: Ferrer to each workshop in turn with the escort round him (and to the barn for the log); at night the party
## shadows the Winder 5 tiles behind it; at the bank the escort goes to the bridge and the south bank, the gap men
## hold the gap, Ferrer stays back by the chapel; the choice answered at once.
var main: Node
var until := 1500.0
var active := false
var careless := false
var diff := "normal"
var furth := "strong"
var jakob := "alive"
var gate := "pattern"
var broken := "kept"
var _saved_progress := ""
var _deaths := {}
var _watch: Array = []
var _p3 := 0.0
var _killed := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a == "careless":
			careless = true
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.begins_with("furth="):
			furth = a.substr(6)
		elif a.begins_with("jakob="):
			jakob = a.substr(6)
		elif a.begins_with("gate="):
			gate = a.substr(5)
		elif a.begins_with("broken="):
			broken = a.substr(7)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	Campaign.save_progress({"reached": ["a04_visit"], "done": {
		"p01_leaf": {"won_by": "crown", "side": "crown", "flags": {"families": "save"}},
		"c01_thirteenth": {"won_by": "guild", "side": "guild", "flags": {"bells": "quiet", "saved": "some", "jakob": "alive", "cut": "no", "gate": gate}},
		"a02_furth": {"won_by": "guild", "side": "guild", "flags": {"stopwork": "fitted", "furth": furth, "jakob": jakob}}}, "difficulty": diff})
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("a04_visit", "solo", "p1", false))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 2.0
	var pt := r.team_index("party")
	var mt := r.team_index("machine")
	print("SIM diff=%s furth=%s jakob=%s gate=%s active=%s careless=%s broken=%s" % [diff, furth, jakob, gate, active, careless, broken])
	print("SIM start: jakob here=%d escort=%d broken-flag=%s" % [r.tagged("jakob").size(), r.tagged("escort").size(), Campaign.flag("a02_furth", "jakob")])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
		if active and g.clock >= think:
			think = g.clock + 1.0
			_play(g, r, pt, mt)
		if active and String(r.choice_open.get("id", "")) == "broken":
			r.choose("broken", broken)
		for u in g.units:
			if not u.dead and (u.team == pt or u.team == mt) and not _watch.has(u):
				_watch.append(u)
		for u in _watch.duplicate():
			if not is_instance_valid(u):
				_watch.erase(u)
				continue
			if u.dead:
				_watch.erase(u)
				var key := "%s by %s/t%d" % [u.kind, u.last_hit_by, u.last_hit_team]
				_deaths[key] = int(_deaths.get(key, 0)) + 1
		if r.fired.has("riot") and not r.fired.has("riot_over") and g.clock >= _p3:
			_p3 = g.clock + 5.0
			var rio: Array = r.tagged("rioters")
			var pen: Array = r.tagged("g_pendulum")
			print("SIM   p3 t=%d rioters=%d %s lost=%d sortie=%d pendulum=%s" % [g.clock, rio.size(), rio.slice(0, 6).map(func(u): return [g.cell_of(u.position), int(u.hp), u.order]),
				int(r.counters["lost_to_machine"]), r.tagged("sortie").size(),
				"-" if pen.is_empty() else "%s %s %s wind %.2f" % [g.cell_of(pen[0].position), pen[0].order, pen[0].target.kind if pen[0].target and is_instance_valid(pen[0].target) else "-", pen[0].wind]])
			if not _deaths.is_empty():
				print("SIM      deaths: %s" % _deaths)
				_deaths.clear()
		if g.clock >= next:
			next += 20.0 if g.clock < 120.0 else 60.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("riot") else "3")
			var w: Array = r.tagged("night_winder")
			var fe: Array = r.tagged("ferrer")
			print("SIM t=%4d part=%s seen=%d spotted=%d winder=%s legs=%s riot=%d rioters=%d lost=%d party=%d machine=%d ferrer=%s hollweg=%s" % [
				g.clock, part, int(r.counters["inspected"]), int(r.counters["spotted"]),
				"-" if w.is_empty() else str(g.cell_of(w[0].position)),
				["leg1", "leg2", "leg3"].filter(func(k): return r.route_done.has(k)),
				int(r.counters["riot"]), r.tagged("rioters").size(), int(r.counters["lost_to_machine"]),
				r.count({"team": "party"}), r.count({"team": "machine"}),
				"DEAD" if fe.is_empty() else "%d hp" % int(fe[0].hp), "ok" if not r.tagged("hollweg").is_empty() else "DEAD"])
			if not _deaths.is_empty():
				print("SIM      deaths: %s" % _deaths)
				_deaths.clear()
	print("SIM end t=%d over=%s winner=%s flags=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.obj])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _ours(g: Game, t: int, tag_list: Array, r: MissionRun) -> Array:
	var out: Array = []
	for tg in tag_list:
		out.append_array(r.tagged(tg).filter(func(u): return u is Unit and u.team == t))
	return out


func _idle(u: Unit) -> bool:
	return (u.target == null or not is_instance_valid(u.target) or u.target.dead) and u.velocity.length() < 5.0


func _go(g: Game, us: Array, p: Vector2, attack := false, slack := 48.0) -> void:
	var far := us.filter(func(u): return u.position.distance_to(p) > slack and _idle(u))
	if not far.is_empty():
		g.group_move(far, p, attack)


func _play(g: Game, r: MissionRun, pt: int, mt: int) -> void:
	var fe: Array = r.tagged("ferrer")
	if fe.is_empty():
		return
	var ferrer: Unit = fe[0]
	var esc: Array = _ours(g, pt, ["escort", "brothers"], r)
	if not r.fired.has("part2"):
		# ---- PART 1: Ferrer to the next workshop (the log in the barn when asked), the escort round him
		var goal := Vector2.INF
		if String(r.obj.get("log", "")) == "active":
			goal = r.area_rect("barn").get_center()
		else:
			for i in 6:
				if not r.fired.has("ws_%d" % (i + 1)):
					goal = r.area_rect("ws_%d" % (i + 1)).get_center()
					break
		if goal != Vector2.INF and ferrer.position.distance_to(goal) > 20.0:
			g.group_move([ferrer], goal, false)
		_go(g, esc, ferrer.position + Vector2(0, 3 * Defs.TILE), false, 3.0 * Defs.TILE)
		return
	if not r.fired.has("riot"):
		# ---- PART 2: shadow the Winder 5 tiles behind; at the bank, Ferrer to the watch
		var w: Array = r.tagged("night_winder")
		if r.fired.has("at_bank"):
			var bw := r.area_rect("bank_watch")
			var spot := bw.position + Vector2(2, 2) * Defs.TILE
			if ferrer.position.distance_to(spot) > 20.0:
				g.group_move([ferrer], spot, false)
			_go(g, esc, spot + Vector2(-2, -2) * Defs.TILE, false, 3.0 * Defs.TILE)
			return
		if w.is_empty():
			return
		var wp: Vector2 = w[0].position
		var party := [ferrer] + esc
		var c := Vector2.ZERO
		for u in party:
			c += u.position
		c /= float(party.size())
		var keep := (2.0 if careless else 5.5) * Defs.TILE
		var spot2 := wp + (c - wp).normalized() * keep if c.distance_to(wp) > 1.0 else wp + Vector2(keep, 0)
		for u in party:
			if u.position.distance_to(spot2) > 1.5 * Defs.TILE:
				g.group_move([u], spot2, false)
		return
	# ---- PART 3: the escort at the bridge and the south bank (attack-moving the rioters), Ferrer back by the chapel
	var rio: Array = r.tagged("rioters")
	var muskets := _ours(g, pt, ["escort"], r)
	if not rio.is_empty():
		var c3 := Vector2.ZERO
		for u in rio:
			c3 += u.position
		c3 /= float(rio.size())
		# (get ahead of them: the escort to the gap, the line's men already there; whoever is left behind chases)
		var gap := r.area_rect("gap").get_center()
		_go(g, muskets, gap if c3.x < gap.x - 2 * Defs.TILE else c3, true, 2.0 * Defs.TILE)
		_go(g, _ours(g, pt, ["gate_men", "gap_men"], r), gap, true, 3.0 * Defs.TILE)
	var safe := r.area_rect("yard").get_center()
	if ferrer.position.distance_to(safe) > 3.0 * Defs.TILE:
		g.group_move([ferrer] + _ours(g, pt, ["brothers"], r), safe, false)
