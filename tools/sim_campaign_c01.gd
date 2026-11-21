extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays the Clockwork prologue, "The Thirteenth Hour" (docs/campaign_c01_build.md), with a simple player bot and prints,
## every minute, how it goes: the part, the guild's army, the machine's, the seeds, the townsfolk saved, the time left. A
## balance check: Parts 1-2 must be winnable by a player who plays them (the order filled, the mill seed burnt), Part 3 a
## fair retreat (Hollweg out, the people saved depending on play), and a player who does nothing must lose.
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_c01.gd [-- active] [bells=rung|quiet] [gate=people|pattern]
##        [until=<seconds>] [shots=<dir>] [speed=<x>] (shots: pictures of the parts; needs a window: xvfb-run, not --headless;
##        speed: the match runs that many times faster than it draws)
var main: Node
var until := 2400.0
var active := false      # ("active": the bot builds a Light Works and a Regulator, trains Clock Soldiers, fills the order,
                         # takes Jakob and the army to the mill, burns the seeds it can, and in Part 3 walks Hollweg to the
                         # west gate while the army guards the road and Jakob fetches the drawings)
var bells := "quiet"
var gate := "pattern"
var shots := ""
var _shot_n := 0
var _shot_done := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		if a.begins_with("until="):
			until = float(a.substr(6))
		if a.begins_with("bells="):
			bells = a.substr(6)
		if a.begins_with("gate="):
			gate = a.substr(5)
		if a.begins_with("shots="):
			shots = a.substr(6)
		if a.begins_with("speed="):
			Engine.time_scale = float(a.substr(6))           # (filming: the match runs faster than it draws)
			Engine.max_physics_steps_per_frame = 32
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("c01_thirteenth", "solo"))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 2.0
	var gt := r.team_index("guild")
	var mt := r.team_index("machine")
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
		if not r.choice_open.is_empty():
			var cid := String(r.choice_open["id"])
			if cid == "bells":
				r.choose(cid, bells)
			elif cid == "gate":
				r.choose(cid, gate)
		if active and g.clock >= think:
			think = g.clock + 1.5
			_play(g, r, gt, mt)
		if shots != "":
			await _shots(g, r)
		if g.clock >= next:
			next += 60.0
			var part := "1" if not r.fired.has("dusk") else ("2" if not r.fired.has("lost") else "3")
			var seeds := ["seed_mill", "seed_baths", "seed_market", "seed_east"].filter(func(s): return not r.tagged(s).is_empty())
			var left := ""
			if r.clocks.has("fall"):
				left = "%ds" % int(float(r.clocks["fall"]) - g.clock)
			print("SIM t=%4d part=%s guild=%d machine=%d seeds=%s folk=%d saved=%d/%d hollweg=%s jakob=%s fall_in=%s" % [g.clock, part,
				r.count({"team": "guild"}), r.count({"team": "machine"}), ",".join(seeds.map(func(s): return s.trim_prefix("seed_"))),
				r.tagged("folk").size(), int(r.counters.get("saved", 0)), int(r.counters.get("townsfolk", 0)),
				"ok" if not r.tagged("hollweg").is_empty() else "DEAD", "ok" if not r.tagged("jakob").is_empty() else "dead", left])
	var hw: Array = r.tagged("hollweg", false)
	if not hw.is_empty() and is_instance_valid(hw[0]):
		var lh = hw[0].get("last_hit_by")
		var near := g.units.filter(func(u): return not u.dead and u.team == mt and u.position.distance_to(hw[0].position) < 320.0)
		print("SIM hollweg at cell %s (dead %s), last hit by %s, machines within 10 tiles: %s" % [g.cell_of(hw[0].position), hw[0].dead,
			(str(lh.kind) + " team " + str(lh.team)) if lh is Object and is_instance_valid(lh) else str(lh), near.map(func(u): return u.kind)])
	print("SIM end t=%d over=%s winner=%s flags=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.obj])
	quit()


func _army(g: Game, gt: int) -> Array:
	return g.units.filter(func(u): return not u.dead and u.team == gt and u.kind in ["clock_soldier", "springer", "netter", "pendulum"])


func _play(g: Game, r: MissionRun, gt: int, mt: int) -> void:
	var hall: Building = r.tagged("perpetual")[0] if not r.tagged("perpetual").is_empty() else null
	var winders: Array = g.units.filter(func(u): return not u.dead and u.team == gt and u.kind == "winder")
	# build: a Light Works, then a Regulator, then a second Light Works when rich
	var have := func(k: String) -> int: return g.buildings.filter(func(b): return not b.dead and b.team == gt and b.kind == k).size()
	if hall and not winders.is_empty() and not r.fired.has("lost"):
		for k in ["movement_works", "regulator", "regulator", "movement_works"]:
			var want := ["movement_works", "regulator", "regulator", "movement_works"].count(k)
			if have.call(k) >= want:
				continue
			if int(g.players[gt]["gold"]) < int(Defs.BUILDINGS[k]["cost"]) + 10 or g.requirement_text(gt, k) != "":
				break
			var c: Vector2i = g.find_spot(gt, k, hall, 4, 14)
			if c.x >= 0:
				g.place_building(gt, k, c, [winders[0]])
			break
	for b in g.buildings:
		if b.team == gt and not b.dead and b.built and b.kind == "movement_works" and b.queue.size() < 2 and int(g.players[gt]["gold"]) >= 80:
			g.train(b, "clock_soldier")
	var army := _army(g, gt)
	var jak: Array = r.tagged("jakob")
	var hol: Array = r.tagged("hollweg")
	if not r.fired.has("dusk"):
		# part 1: six to the wagons
		if r.obj.get("order", "") == "active" and army.size() >= 6:
			g.group_move(army.slice(0, 6), r.area_rect("wagons").get_center(), false)
		return
	if not r.fired.has("lost"):
		# part 2: Jakob and the army to the mill bank, then the island and its seed
		if r.obj.get("look", "") == "active":
			if not jak.is_empty():
				g.group_move(jak, r.area_rect("mill_bank").get_center(), false)
			g.group_move(army, r.area_rect("mill_bank").get_center(), true)
		elif not r.tagged("seed_mill").is_empty():
			var seed: Building = r.tagged("seed_mill")[0]
			for u in army:
				if u.target == null or not is_instance_valid(u.target) or u.target.dead:
					var foe := _nearest_foe(g, u, mt, 260.0)
					if foe:
						u.cmd_attack(foe)
					else:
						u.cmd_attack(seed)
			if not jak.is_empty():
				g.group_move(jak, r.area_rect("yard").get_center(), false)
		else:
			g.group_move(army, r.area_rect("bridge_w_s").get_center(), true)
		return
	# part 3: Hollweg to the gate; Jakob fetches the drawings, then follows; the army guards the road west
	if not hol.is_empty() and not r.area_rect("gate_in").has_point(hol[0].position) and hol[0].velocity.length() < 5.0:
		g.group_move(hol, r.area_rect("gate_in").get_center(), false)
	if not jak.is_empty():
		var j: Unit = jak[0]
		var to := "guildhouse" if r.obj.get("drawings", "") == "active" else "gate_in"
		if not r.area_rect(to).has_point(j.position) and j.velocity.length() < 5.0:
			g.group_move(jak, r.area_rect(to).get_center(), false)
	var guard := r.area_rect("road_w").grow(4 * Defs.TILE)
	if not hol.is_empty() and hol[0].hp < hol[0].max_hp * 0.7:
		# (Hollweg hurt: half the army goes to him)
		for i in range(0, army.size(), 2):
			var foe := _nearest_foe(g, hol[0], mt, 360.0)
			if foe:
				army[i].cmd_attack(foe)
			else:
				g.group_move([army[i]], hol[0].position, true)
	for u in army:
		var foe := _nearest_foe(g, u, mt, 300.0)
		if foe and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
			u.cmd_attack(foe)
		elif foe == null and not guard.has_point(u.position) and u.velocity.length() < 5.0:
			g.group_move([u], r.area_rect("road_w").get_center() + Vector2(randf_range(-200, 300), randf_range(-60, 60)), true)


func _nearest_foe(g: Game, u: Unit, mt: int, reach: float) -> Unit:
	var best: Unit = null
	var bd := reach
	for f in g.units:
		if f.dead or f.team != mt:
			continue
		var d := u.position.distance_to(f.position)
		if d < bd:
			bd = d
			best = f
	return best


## Pictures of the parts (with a window): the city at the start, the gift, the mill found, the turn, Part 3's countdown,
## the stroke.
func _shots(g: Game, r: MissionRun) -> void:
	var want := {"start": g.clock > 3.0, "gift": r.fired.has("gift") and g.clock > float(r.fired.get("gift", 0)) + 20,
		"found": r.fired.has("found") and g.clock > float(r.fired.get("found", 0)) + 3,
		"turn": r.fired.has("turned_go") and g.clock > float(r.fired.get("turned_go", 0)) + 4,
		"night": r.fired.has("lost") and g.clock > float(r.fired.get("lost", 0)) + 90,
		"spread": r.fired.has("lost") and g.clock > float(r.fired.get("lost", 0)) + 300,
		"stroke": r.fired.has("stroke") and g.clock > float(r.fired.get("stroke", 0)) + 3}
	var where := {"start": "yard", "gift": "workshop", "found": "mill_island", "turn": "workshop", "night": "road_w", "spread": "market", "stroke": "gate_in"}
	for k in want:
		if want[k] and not _shot_done.has(k):
			_shot_done[k] = true
			g.camera.position = r.area_rect(where[k]).get_center()
			for i in 4:
				await process_frame
			var img := root.get_viewport().get_texture().get_image()
			_shot_n += 1
			img.save_jpg("%s/%d_%s.jpg" % [shots, _shot_n, k], 0.85)
			print("SIM shot %s" % k)
