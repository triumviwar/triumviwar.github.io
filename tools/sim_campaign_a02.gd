extends SceneTree
## Plays Act 1's "The Fürth Line" (docs/campaign_a02_build.md) from either side with a simple bot and prints, every
## minute, how it goes: the part, the guild's army, the Franconian army, the machine's, the palisades left, the sorties
## beaten back, the mill seed, the time left on the machine's clock. A balance check: the guild's player who plays it
## wins on NORMAL in a sensible time; the machine's player who plays it can break the line before the clock; a player who
## does nothing loses (the guild) or runs out the clock (the machine).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_a02.gd -- [active] [side=guild|machine]
##        [bells=rung|quiet] [saved=few|some|many] [jakob=alive|lost] [cut=yes|no] [gate=people|pattern]
##        [diff=easy|normal|hard] [until=<seconds>] [none] (none: no c01 flags at all)
## The prologue's flags are written into the progress file for the run (and the player's own progress put back after).
var main: Node
var until := 1800.0
var active := false
var side := "guild"
var diff := "normal"
var c01 := {"bells": "quiet", "saved": "some", "jakob": "alive", "cut": "no", "gate": "pattern"}
var no_flags := false
var _saved_progress := ""


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a == "none":
			no_flags = true
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("side="):
			side = a.substr(5)
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.contains("="):
			var kv := a.split("=")
			if c01.has(kv[0]):
				c01[kv[0]] = kv[1]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["a02_furth"], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if not no_flags:
		p["done"]["c01_thirteenth"] = {"won_by": "guild", "side": "guild", "flags": c01}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("a02_furth", "solo", "p1", false, side))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 2.0
	var gt := r.team_index("guild")
	var at := r.team_index("army")
	var mt := r.team_index("machine")
	print("SIM side=%s diff=%s c01=%s active=%s human=%d" % [side, diff, "none" if no_flags else str(c01), active, g.human])
	while g.clock < until and not g.over:
		await physics_frame
		if active and g.clock >= think:
			think = g.clock + 1.5
			if side == "machine":
				_play_machine(g, r, gt, at, mt)
			else:
				_play_guild(g, r, gt, mt)
		for u in g.units:
			if not u.dead and u.team == mt:
				var was: float = u.get_meta("simx", 99999.0)
				if was >= 58.5 * Defs.TILE and u.position.x < 58.5 * Defs.TILE:
					print("SIM crossed the line at %s t=%d walls=%d solid=%s" % [g.cell_of(u.position), g.clock, r.tagged("earthworks").size(), [g.solid[g.idx(Vector2i(58, 16))], g.solid[g.idx(Vector2i(58, 17))], g.solid[g.idx(Vector2i(58, 18))], g.solid[g.idx(Vector2i(58, 19))], g.solid[g.idx(Vector2i(58, 20))]]])
				u.set_meta("simx", u.position.x)
		if g.clock >= next:
			next += 60.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			var left := ""
			if r.clocks.has("line"):
				left = "%ds" % int(float(r.clocks["line"]) - g.clock)
			print("SIM t=%4d part=%s gsoldiers=%d cogs=%d guild=%d army=%d machine=%d walls=%d sorties=%d mill=%s hollweg=%s honest=%s line_in=%s" % [g.clock, part, _army(g, gt).size(), int(g.players[gt]["gold"]),
				r.count({"team": "guild"}), r.count({"team": "army"}), r.count({"team": "machine"}), r.tagged("earthworks").size(),
				int(r.counters.get("sorties", 0)), "up" if not r.tagged("seed_mill").is_empty() else "-",
				"ok" if not r.tagged("hollweg").is_empty() else "DEAD", "ok" if not r.tagged("honest").is_empty() else "DOWN", left])
	var hw: Array = r.tagged("hollweg", false)
	if not hw.is_empty() and is_instance_valid(hw[0]):
		var lh = hw[0].get("last_hit_by")
		print("SIM hollweg at cell %s (dead %s), last hit by %s" % [g.cell_of(hw[0].position), hw[0].dead,
			(str(lh.kind) + " team " + str(lh.team) + " at " + str(g.cell_of(lh.position))) if lh is Object and is_instance_valid(lh) else str(lh)])
	print("SIM inside the line: %s" % [g.units.filter(func(u): return not u.dead and u.team == mt and u.position.x < 58 * Defs.TILE).map(func(u): return [u.kind, g.cell_of(u.position)])])
	print("SIM machine supply %d/%d, cogs %d, tension %d, buildings %s" % [g.supply_used(mt), g.max_supply(mt), int(g.players[mt]["gold"]), int(g.tension(mt)),
		g.buildings.filter(func(b): return not b.dead and b.team == mt).map(func(b): return [b.kind, b.cell, b.built, g.can_train(b, "clock_soldier") if b.kind == "movement_works" else ""])])
	print("SIM end t=%d over=%s winner=%s flags=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.obj])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _army(g: Game, t: int) -> Array:
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind in ["clock_soldier", "springer", "netter", "pendulum"])


func _have(g: Game, t: int, k: String) -> int:
	return g.buildings.filter(func(b): return not b.dead and b.team == t and b.kind == k).size()


func _build(g: Game, t: int, list: Array, near: Building, workers: Array) -> void:
	for k in list:
		if _have(g, t, k) >= list.count(k):
			continue
		if int(g.players[t]["gold"]) < int(Defs.BUILDINGS[k]["cost"]) + 10:
			return
		if g.requirement_text(t, k) != "":
			continue
		var c: Vector2i = g.find_spot(t, k, near, 4, 14)
		if c.x >= 0 and not workers.is_empty():
			if g.place_building(t, k, c, [workers[0]]) == null:
				print("SIM can't build %s: %s" % [k, g.placement_problem(t, k, c)])
		elif c.x < 0:
			print("SIM no spot for %s" % k)
		return


func _train(g: Game, t: int, kinds: Array) -> void:
	for b in g.buildings:
		if b.team == t and not b.dead and b.built and b.kind == "movement_works" and b.queue.size() < 2:
			for k in kinds:
				if int(g.players[t]["gold"]) >= (110 if k == "springer" else 80) and g.can_train(b, k) == "":
					g.train(b, k)
					break


func _fight(g: Game, army: Array, foe_t: int, reach: float, home: Vector2, spread := 160.0) -> void:
	for u in army:
		var foe := _nearest_foe(g, u, foe_t, reach)
		if foe and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
			u.cmd_attack(foe)
		elif foe == null and u.position.distance_to(home) > spread * 1.5 and u.velocity.length() < 5.0:
			g.group_move([u], home + Vector2(randf_range(-spread, spread), randf_range(-spread, spread)) * 0.5, true)


## The guild's player: Hollweg to the tower, a Light Works and a Regulator, Clock Soldiers and Springers; the army split
## between the two gates in Part 2; in Part 3 everything at the mill seed.
func _play_guild(g: Game, r: MissionRun, gt: int, mt: int) -> void:
	var hall: Building = r.tagged("honest")[0] if not r.tagged("honest").is_empty() else null
	var winders: Array = g.units.filter(func(u): return not u.dead and u.team == gt and u.kind == "winder")
	var hol: Array = r.tagged("hollweg")
	if not hol.is_empty() and r.obj.get("stopwork", "") == "active" and not r.area_rect("honest_ring").has_point(hol[0].position) and hol[0].velocity.length() < 5.0:
		g.group_move(hol, r.area_rect("honest_ring").get_center(), false)
	elif not hol.is_empty() and r.obj.get("stopwork", "") != "active" and not r.area_rect("town").has_point(hol[0].position) and hol[0].velocity.length() < 5.0:
		g.group_move(hol, r.area_rect("town").get_center(), false)      # (the stop-work fitted: the hero back in the town)
	if hall:
		_build(g, gt, ["movement_works", "regulator", "movement_works", "regulator", "mainspring", "regulator", "heavy_works", "regulator"], hall, winders)
	_train(g, gt, ["springer", "clock_soldier"] if g.tension(gt) >= 30.0 else ["clock_soldier"])
	for b in g.buildings:
		if b.team == gt and not b.dead and b.built and b.kind == "heavy_works" and b.queue.is_empty() and int(g.players[gt]["gold"]) >= 260:
			g.train(b, "pendulum")
	var army := _army(g, gt)
	# anything through the line: everyone goes for it
	var inside: Unit = null
	for u in g.units:
		if not u.dead and u.team == mt and u.position.x < 57 * Defs.TILE:
			inside = u
			break
	if inside:
		for u in army:
			var foe := _nearest_foe(g, u, mt, 900.0)
			if foe and foe.position.x < 60 * Defs.TILE and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
				u.cmd_attack(foe)
		return
	if not r.fired.has("part3"):
		# hold the gate the machine is coming at (as Jakob's warnings say): the bank with most machines west of the
		# old bridge; a quarter of the army stays at the other gate
		var north := 0
		var south := 0
		for u in g.units:
			if not u.dead and u.team == mt and u.position.x < 100 * Defs.TILE:
				if u.position.y < 36 * Defs.TILE:
					north += 1
				else:
					south += 1
		var main_gate := "road_gate" if north > south else "meadow_gate"
		var other := "meadow_gate" if main_gate == "road_gate" else "road_gate"
		for i in army.size():
			var gate := other if i % 4 == 3 else main_gate
			_fight(g, [army[i]], mt, 330.0, r.area_rect(gate).get_center() - Vector2(4 * Defs.TILE, 0))
		return
	# part 3: the mill seed, with everything (a small guard stays at the meadow gate)
	var seed: Array = r.tagged("seed_mill")
	for i in army.size():
		var u: Unit = army[i]
		if i < 3:
			_fight(g, [u], mt, 300.0, r.area_rect("inside_s").get_center())
			continue
		var foe := _nearest_foe(g, u, mt, 220.0)
		if foe and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
			u.cmd_attack(foe)
		elif foe == null and not seed.is_empty() and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
			if army.size() >= 10 or u.position.distance_to(seed[0].center()) < 400.0:
				u.cmd_attack(seed[0])


## The machine's player: Clock Soldiers and Springers at its Light Works by the south gate, the army gathered at the
## gate, then a push along the south bank at the meadow gate's palisade and on to the Honest One (Hollweg if in reach).
func _play_machine(g: Game, r: MissionRun, gt: int, at: int, mt: int) -> void:
	var winders: Array = g.units.filter(func(u): return not u.dead and u.team == mt and u.kind == "winder")
	var seed: Array = r.tagged("seed_s")
	if not seed.is_empty():
		_build(g, mt, ["movement_works", "regulator", "regulator", "movement_works", "regulator", "regulator"], seed[0], winders)
	_train(g, mt, ["springer", "clock_soldier"] if g.tension(mt) >= 30.0 else ["clock_soldier"])
	var army := _army(g, mt)
	var gather := r.area_rect("meadow_mid").get_center()
	var pushing := army.size() >= 30 or g.clock > 720.0
	for u in army:
		var foe := _nearest_foe(g, u, gt, 240.0)
		if foe == null:
			foe = _nearest_foe(g, u, at, 240.0)
		if foe and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
			u.cmd_attack(foe)
			continue
		if u.target != null and is_instance_valid(u.target) and not u.target.dead:
			continue
		if not pushing:
			if u.position.distance_to(gather) > 260.0 and u.velocity.length() < 5.0:
				g.group_move([u], gather, true)
			continue
		# the push: the nearest palisade or gate of the meadow stretch, then the Honest One
		var wall := _nearest_building(g, u, at, 900.0)
		var hon: Array = r.tagged("honest")
		if wall and u.position.x > 56 * Defs.TILE:
			u.cmd_attack(wall)
		elif not hon.is_empty():
			u.cmd_attack(hon[0])


func _nearest_foe(g: Game, u: Unit, t: int, reach: float) -> Unit:
	var best: Unit = null
	var bd := reach
	for f in g.units:
		if f.dead or f.team != t or f.kind == "horse":
			continue
		var d := u.position.distance_to(f.position)
		if d < bd:
			bd = d
			best = f
	return best


func _nearest_building(g: Game, u: Unit, t: int, reach: float) -> Building:
	var best: Building = null
	var bd := reach
	for b in g.buildings:
		if b.dead or b.team != t:
			continue
		var d := u.position.distance_to(b.center())
		if d < bd:
			bd = d
			best = b
	return best
