extends SceneTree
## Plays Act 1's "The Barricades of Paris" (docs/campaign_a06_build.md) with a simple bot and prints, every minute, how
## it goes: the part, the barricades taken, the bridges, Notre-Dame's health, the army, the Assembly's men, Varenne. A
## balance check: a player who plays it wins on NORMAL in a sensible time; a player who does nothing does not win (the
## Assembly holds its barricades: the mission waits, as the plan's "take them with lines and guns" asks; it is lost only
## if the Field Marshal or the priest walk into them).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_a06.gd -- [active] [families=save|leave]
##        [lyon=calm|sullen|risen] [diff=easy|normal|hard] [verdict=spared|executed] [until=<seconds>]
## The flags are written into the progress file for the run (and the player's own progress put back after).
## The bot: the guns set up out of musket reach before each barricade (the mortar on its men, the cannons on its
## palisades, canister when they rush), the line behind the guns, in when the barricade's men are down; then the
## bridges and the parvis (riders and muskets for the torches); then the guns on the hall's palisade, everyone in, the
## riders after Varenne; the choice answered at once.
var main: Node
var until := 1800.0
var active := false
var diff := "normal"
var families := "save"
var lyon := "calm"
var verdict := "spared"
var _saved_progress := ""


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.begins_with("families="):
			families = a.substr(9)
		elif a.begins_with("lyon="):
			lyon = a.substr(5)
		elif a.begins_with("verdict="):
			verdict = a.substr(8)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	Campaign.save_progress({"reached": ["a06_barricades"], "done": {
		"p01_leaf": {"won_by": "crown", "side": "crown", "flags": {"families": families}},
		"a01_presses": {"won_by": "crown", "side": "crown", "flags": {"lyon": lyon, "printer": "taken"}}}, "difficulty": diff})
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("a06_barricades", "solo", "p1", false))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 2.0
	var gt := r.team_index("army")
	var at := r.team_index("assembly")
	print("SIM diff=%s families=%s lyon=%s active=%s verdict=%s" % [diff, families, lyon, active, verdict])
	while g.clock < until and not g.over:
		await physics_frame
		if active and g.clock >= think:
			think = g.clock + 1.0
			_play(g, r, gt, at)
		if active and String(r.choice_open.get("id", "")) == "varenne":
			r.choose("varenne", verdict)
		if g.clock >= next:
			next += 60.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			var nd: Array = r.tagged("notre_dame")
			var va: Array = r.tagged("varenne")
			print("SIM t=%4d part=%s taken=%d bridges=%d nd=%s army=%d (muskets %d, guns %d) assembly=%d torches=%d gold=%d varenne=%s fairleigh=%s tomasz=%s" % [
				g.clock, part, int(r.counters["taken"]), int(r.counters["bridges"]), "BURNT" if nd.is_empty() else str(int(nd[0].hp)),
				r.count({"team": "army"}), _of(g, gt, ["musketeer"]).size(), _of(g, gt, ["cannon", "mortar"]).size(),
				r.count({"team": "assembly"}), r.tagged("torches").size(), int(g.players[gt]["gold"]),
				"taken" if r.captured.has("varenne") else ("-" if va.is_empty() else "%d hp at %s" % [int(va[0].hp), g.cell_of(va[0].position)]),
				"ok" if not r.tagged("fairleigh").is_empty() else "DEAD", "ok" if not r.tagged("tomasz").is_empty() else "DEAD"])
			print("SIM      walls left %s, ring %d" % [["bar_1", "bar_2", "bar_3"].map(func(b): return r.tagged(b + "_wall").size()), r.tagged("ring").size()])
	print("SIM end t=%d over=%s winner=%s flags=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.obj])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _of(g: Game, t: int, kinds: Array) -> Array:
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind in kinds)


func _idle(u: Unit) -> bool:
	return (u.target == null or not is_instance_valid(u.target) or u.target.dead) and u.velocity.length() < 5.0


func _nearest_foe(g: Game, p: Vector2, t: int, reach: float) -> Unit:
	var best: Unit = null
	var bd := reach
	for f in g.units:
		if f.dead or f.team != t or f.kind == "horse" or f.spared:
			continue
		var d := p.distance_to(f.position)
		if d < bd:
			bd = d
			best = f
	return best


## Soldiers: fight what comes within reach, else go to `home` (spread round it).
func _hold(g: Game, us: Array, at: int, home: Vector2, reach := 230.0, spread := 60.0) -> void:
	for i in us.size():
		var u: Unit = us[i]
		var foe := _nearest_foe(g, u.position, at, reach)
		if foe:
			if u.target == null or not is_instance_valid(u.target) or u.target.dead:
				u.cmd_attack(foe)
			continue
		var spot := home + Vector2(((i % 5) - 2) * spread * 0.5, ((i / 5) % 4 - 1.5) * spread * 0.5)
		if u.position.distance_to(spot) > spread and _idle(u):
			g.group_move([u], spot, true)


## A gun: to its spot (packed), set up there, then its target (or canister on whoever closes in).
func _gun(g: Game, u: Unit, at: int, spot: Vector2, tgt: Entity) -> void:
	var near := _nearest_foe(g, u.position, at, 170.0)
	if u.kind == "cannon":
		u.set_canister(near != null)
	if u.position.distance_to(spot) > 48.0 and near == null:
		if _idle(u) or u.order != "move":
			g.group_move([u], spot, false)
		return
	if u.tesla_mode == "packed":
		u.cmd_deploy()
		return
	if u.tesla_mode != "deployed":
		return
	var t: Entity = near if near else tgt
	if t and (u.target != t or u.target == null) and is_instance_valid(t) and not t.dead:
		u.cmd_attack(t)


func _play(g: Game, r: MissionRun, gt: int, at: int) -> void:
	var muskets: Array = _of(g, gt, ["musketeer"])
	var riders: Array = _of(g, gt, ["cuirassier"])
	var guns: Array = _of(g, gt, ["cannon", "mortar"])
	var heads: Array = r.tagged("fairleigh") + r.tagged("tomasz") + r.tagged("ruggieri") + r.tagged("wagon")
	var T := float(Defs.TILE)
	# the camp: the Foundry casts a mortar (then another), the Barracks trains Musketeers with the rest
	for b in r.tagged("foundry"):
		if not b.dead and b.queue.is_empty() and _of(g, gt, ["mortar"]).size() < 3 and int(g.players[gt]["gold"]) >= 200 and g.can_train(b, "mortar") == "":
			g.train(b, "mortar")
	for b in r.tagged("barracks"):
		if not b.dead and b.queue.size() < 2 and int(g.players[gt]["gold"]) >= 260 and g.can_train(b, "musketeer") == "":
			g.train(b, "musketeer")
	# ---------------- part 1: the barricade still standing nearest the camp
	if not r.fired.has("part2"):
		var cur := ""
		for b in ["bar_1", "bar_2", "bar_3"]:
			if not r.tagged(b + "_men").is_empty():
				cur = b
				break
		if cur == "":
			return
		var bar := r.area_rect(cur)
		var by := bar.get_center().y
		var bx := bar.position.x
		var walls: Array = r.tagged(cur + "_wall")
		var men: Array = r.tagged(cur + "_men")
		# the guns 7-8 tiles east of the barricade's line (the men behind it 2-5 tiles west: inside the mortar's 5-11)
		for i in guns.size():
			var u: Unit = guns[i]
			var spot := Vector2(bx + (8.5 + (i % 2)) * T, by + ((i % 3) - 1) * 1.3 * T)
			var tgt: Entity = null
			if u.kind == "mortar":
				tgt = men[0] if not men.is_empty() else null
			else:
				tgt = walls[0] if not walls.is_empty() else (men[0] if not men.is_empty() else null)
			_gun(g, u, at, spot, tgt)
		var line := Vector2(bx + 12.0 * T, by)
		var open := walls.size() <= 2
		var go_in := open and men.size() <= 4
		if go_in:
			_hold(g, muskets + riders, at, Vector2(bx - 3.0 * T, by), 260.0)
		else:
			_hold(g, muskets, at, line, 150.0)
			_hold(g, riders, at, line + Vector2(3.0 * T, 0), 120.0)
		_hold(g, heads, at, line + Vector2(6.0 * T, 0), 0.0)
		return
	# ---------------- part 2: the bridges and the parvis
	if not r.fired.has("part3"):
		var nb := r.area_rect("north_bank_bridges").get_center()
		var parvis := r.area_rect("parvis").get_center()
		var torches: Array = r.tagged("torches")
		var bridge_men: Array = r.tagged("bridge_nd_men") + r.tagged("bridge_ch_men")
		for i in guns.size():
			_gun(g, guns[i], at, nb + Vector2((i - 1.5) * 2.0 * T, -4.0 * T), bridge_men[0] if not bridge_men.is_empty() else null)
		if not bridge_men.is_empty():
			_hold(g, muskets, at, nb + Vector2(0, -1.0 * T), 260.0)
		else:
			_hold(g, muskets, at, parvis, 260.0)
		# the riders go for the torch-bearers (over a bridge once one is taken)
		for u in riders:
			var best: Unit = null
			var bd := INF
			for t in torches:
				var d: float = t.position.distance_to(u.position)
				if d < bd:
					bd = d
					best = t
			if best and (u.target != best):
				u.cmd_attack(best)
			elif best == null:
				_hold(g, [u], at, parvis if r.counters["bridges"] >= 1 else nb, 200.0)
		_hold(g, heads, at, nb + Vector2(0, -6.0 * T), 0.0)
		return
	# ---------------- part 3: the hall's palisade, then everyone in, the riders after Varenne
	var ring: Array = r.tagged("ring")
	var va: Array = r.tagged("varenne")
	var rr := r.area_rect("ring")
	var east := Vector2(rr.end.x, rr.get_center().y)
	var piece: Building = null
	var pd := INF
	for b in ring:
		var d: float = b.center().distance_to(east + Vector2(8 * T, 0))
		if d < pd:
			pd = d
			piece = b
	for i in guns.size():
		_gun(g, guns[i], at, east + Vector2((7.5 + i % 2) * T, ((i % 3) - 1) * 1.5 * T), piece)
	var hall_men: Array = r.tagged("hall_men")
	if r.fired.has("breached"):
		_hold(g, muskets, at, r.area_rect("hall_square").get_center(), 280.0)
	else:
		_hold(g, muskets, at, east + Vector2(10 * T, 0), 200.0)
	if not va.is_empty() and not r.captured.has("varenne"):
		for u in riders:
			if r.fired.has("breached") or va[0].position.distance_to(u.position) < 300.0:
				if u.target != va[0]:
					u.cmd_attack(va[0])
			else:
				_hold(g, [u], at, east + Vector2(10 * T, 4 * T), 150.0)
		# (once he runs, half the muskets cut along the quay to the port)
		if r.fired.has("flight_" + diff):
			_hold(g, muskets.slice(0, muskets.size() / 2), at, va[0].position, 280.0)
	_hold(g, heads, at, east + Vector2(14 * T, 0), 0.0)
