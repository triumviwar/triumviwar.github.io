extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 3's "Brazil After the Fires" (docs/campaign_e01_build.md) as the army of Brazil with a simple bot and
## prints, every 30 seconds, how it goes: the part, the army, the people walking / aboard, the danger on the map, the
## clocks. A balance check (THE THREE RULES' NO WAITING is measured: the longest stretch with nothing new):
##   - `careful` (the default player): the line and the guns at the ford, then down the road with the people (the line
##     between them and the forest, the riders on whatever comes near them), the DRUMMER walked to the group that lags
##     most, then the bluff; Musketeers at the harbour's Barracks. Should win at every difficulty, most aboard;
##   - `late`: holds the ford a minute after the front breaks and never moves the Drummer: fewer aboard;
##   - `passive`: never gives an order: the people walk alone at a walk and the danger catches them: LOST (too few).
##   - `side=fire`: the fire played (the mirror) by a bot that sends everything at the people on the road.
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_e01.gd -- [careful|late|passive] [side=fire]
##        [diff=easy|normal|hard|brutal] [first=brood|clockwork] [jungle=thin] [siege=close] [fields=burned] [barra=burned]
##        [families=leave] [colonists=fought] [until=<s>] [save_at=<s>] [shots=<dir>]
## The earlier missions' flags are written into the progress file for the run (and the player's own progress put back).
var main: Node
var until := 1100.0
var mode := "careful"
var side := ""
var diff := "normal"
var shots := ""
var _shot_n := 0
var _shot_done := {}
var _saved_progress := ""
var _trained := 0
var _late_until := -1.0
var fl := {
	"p01_leaf": ["crown", {"families": "save"}],
	"d04_concordia": ["guild", {"colonists": "parley"}],
	"d05_aldeia": ["crown", {"fields": "left"}],
	"d07_spring": ["guild", {"spring": "running", "honest": "some"}],
	"d08_rivers": ["barra", {"barra": "held", "nazare": "some", "lure": "burned"}],
	"d09_crossroads": ["crown", {"first": "brood", "fort": "held", "sertao": "some"}],
	"d10_jungle": ["crown", {"jungle": "held", "island": "burned", "inacio": "joined"}],
	"d11_siege": ["crown", {"siege": "held_off"}],
}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a in ["careful", "late", "passive"]:
			mode = a
		elif a.begins_with("side="):
			side = a.substr(5)
		elif a.begins_with("shots="):
			shots = a.substr(6)
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.begins_with("first="):
			fl["d09_crossroads"][1]["first"] = a.substr(6)
		elif a.begins_with("jungle="):
			fl["d10_jungle"][1]["jungle"] = a.substr(7)
		elif a.begins_with("siege="):
			fl["d11_siege"][1]["siege"] = a.substr(6)
		elif a.begins_with("fields="):
			fl["d05_aldeia"][1]["fields"] = a.substr(7)
		elif a.begins_with("barra="):
			fl["d08_rivers"][1]["barra"] = a.substr(6)
		elif a.begins_with("families="):
			fl["p01_leaf"][1]["families"] = a.substr(9)
		elif a.begins_with("colonists="):
			fl["d04_concordia"][1]["colonists"] = a.substr(10)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["e01_brazil"], "done": {}, "difficulty": diff}
	for mid in fl:
		p["done"][mid] = {"won_by": fl[mid][0], "side": fl[mid][0], "flags": fl[mid][1]}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var probs := Campaign.problems(Campaign.mission("e01_brazil"))
	if not probs.is_empty():
		print("SIM PROBLEMS ", probs)
	main.start(Campaign.make_cfg("e01_brazil", "solo", "p1", false, side))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	print("SIM mode=%s side=%s diff=%s version=%s map=%s human=%d people=%d" % [mode, side, diff, str(r.flags.get("version", "-")), g.map_id, g.human,
		r.tagged("people").size()])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
		if shots != "":
			await _shots(g, r)
		if mode != "passive" and g.clock >= think:
			think = g.clock + 0.75
			if side == "fire":
				_play_fire(g, r)
			else:
				_play(g, r)
		if g.clock >= next:
			next += float(OS.get_environment("SIMSTEP")) if OS.get_environment("SIMSTEP") != "" else 30.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			print("SIM t=%4d part=%s army=%d hp=%d people=%d g1=%d g2=%d g3=%d aboard=%d/%d fire=%d front=%s ships=%s gold=%d fort=%s" % [
				g.clock, part, _team(g, r, "column").size(), _team_hp(g, r, "column"), _alive(r, "people"), _alive(r, "g1"), _alive(r, "g2"),
				_alive(r, "g3"), int(r.counters.get("aboard", 0)), int(r.counters.get("people_n", 0)), _team(g, r, "fire").size(),
				_left(g, r, "front"), _left(g, r, "ships"), int(g.players[r.team_index("column")]["gold"]), _hp(r, "harbour_fort")])
	var idle: Dictionary = r.longest_idle()
	print("SIM end t=%d over=%s winner=%s flags=%s counters=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.counters, r.obj])
	print("SIM longest_idle %d s (from %d s)%s" % [int(idle.get("secs", 0.0)), int(idle.get("from", 0.0)), "" if float(idle.get("secs", 0.0)) < 45.0 else "  OVER 45 s"])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _alive(r: MissionRun, tag: String) -> int:
	return r.tagged(tag).filter(func(e): return not e.dead and not e.off_field).size()


func _hp(r: MissionRun, tag: String) -> String:
	var l: Array = r.tagged(tag).filter(func(e): return not e.dead)
	return "-" if l.is_empty() else "%d" % int(l[0].hp)


func _team(g: Game, r: MissionRun, team: String) -> Array:
	var t := r.team_index(team)
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind != "horse" and not u.off_field)


func _team_hp(g: Game, r: MissionRun, team: String) -> int:
	var s := 0.0
	for u in _team(g, r, team):
		s += u.hp
	return int(s)


func _left(g: Game, r: MissionRun, cn: String) -> String:
	return "%ds" % int(float(r.clocks[cn]) - g.clock) if r.clocks.has(cn) else "-"


func _mid(r: MissionRun, area: String) -> Vector2:
	return r.area_rect(area).get_center()


func _go(g: Game, u: Unit, p: Vector2, attack := false) -> void:
	if u.velocity.length() < 5.0 or u.order_point.distance_to(p) > 48.0:
		g.group_move([u], p, attack)


func _nearest_foe(g: Game, t: int, p: Vector2, reach: float) -> Entity:
	var best: Entity = null
	var bd := reach
	for e in g.units:
		if e.dead or e.off_field or not g.hostile(e.team, t) or e.untouchable() or e.kind == "horse":
			continue
		var d: float = e.position.distance_to(p)
		if d < bd:
			bd = d
			best = e
	return best


func _fight_or_go(g: Game, u: Unit, t: int, p: Vector2, reach := 7.0) -> void:
	if u.kind == "powder_wagon" or u.kind == "band" or u.kind == "dismounted":
		if u.position.distance_to(p) > 2.0 * Defs.TILE:
			_go(g, u, p)
		return
	# (a line: it fights what comes near its place, it does not run after it across the ford)
	var foe := _nearest_foe(g, t, p, reach * Defs.TILE)
	if foe and u.position.distance_to(p) < (reach + 2.0) * Defs.TILE:
		if u.target == null or not is_instance_valid(u.target) or u.target.dead:
			u.cmd_attack(foe)
	elif u.position.distance_to(p) > 2.5 * Defs.TILE:
		_go(g, u, p, true)


## The middle of a group still on the road (INF when it is gone or aboard).
func _group_at(r: MissionRun, g: String) -> Vector2:
	var us: Array = r.tagged(g).filter(func(e): return not e.dead and not e.off_field)
	if us.is_empty():
		return Vector2.INF
	var s := Vector2.ZERO
	for u in us:
		s += u.position
	return s / us.size()


## The group farthest from the ships (still walking), its middle.
func _laggard(r: MissionRun) -> Vector2:
	var quay := _mid(r, "quay")
	var best := Vector2.INF
	var bd := -1.0
	for gr in ["g1", "g2", "g3"]:
		var c := _group_at(r, gr)
		if c == Vector2.INF or r.area_rect("port").has_point(c):
			continue
		var d := c.distance_to(quay)
		if d > bd:
			bd = d
			best = c
	return best


## The army of Brazil's player.
func _play(g: Game, r: MissionRun) -> void:
	var t := r.team_index("column")
	var men: Array = _team(g, r, "column")
	if men.is_empty():
		return
	var p2 := r.fired.has("part2")
	var p3 := r.fired.has("part3")
	if p2 and mode == "late" and _late_until < 0.0:
		_late_until = g.clock + 60.0
	var hold := (not p2) or (mode == "late" and g.clock < _late_until)
	# the harbour's Barracks: Musketeers with the treasury
	if p3 and int(g.players[t]["gold"]) >= 150 and _trained < 12:
		for b in r.tagged("port_barracks"):
			if not b.dead and g.train(b, "musketeer") == "":
				_trained += 1
	var lag := _laggard(r)
	var j := 0
	for u in men:
		var goal: Vector2
		if hold:
			goal = _mid(r, "ford_hold")
		elif p3 or lag == Vector2.INF:
			goal = _mid(r, "bluff_front") if j % 3 != 0 else _mid(r, "bluff_mid")
		else:
			goal = lag
		if u.kind == "band":
			if mode == "late":
				continue
			if not hold and lag != Vector2.INF:
				_go(g, u, lag)
			elif u.position.distance_to(goal) > 3 * Defs.TILE:
				_go(g, u, goal)
			continue
		var amb: Array = r.tagged("ambush").filter(func(e): return not e.dead)
		if p2 and not p3 and not hold and not amb.is_empty() and (j % 3 != 0 or u.kind == "dragoon"):
			goal = amb[0].position
		if u.kind == "cannon" and p3:
			goal = _mid(r, "guns_1") if j % 2 == 0 else _mid(r, "guns_2")
		var off := Vector2(cos(j * 1.3), sin(j * 1.3)) * (1.0 + float(j % 3)) * Defs.TILE
		_fight_or_go(g, u, t, goal + off, 8.0)
		j += 1


## The fire played: everything at the people (or the ford while the front holds).
func _play_fire(g: Game, r: MissionRun) -> void:
	var t := r.team_index("fire")
	var lag := _laggard(r)
	for u in _team(g, r, "fire"):
		var goal := _mid(r, "ford_hold") if not r.fired.has("part2") else (lag if lag != Vector2.INF else _mid(r, "bluff_mid"))
		var foe := _nearest_foe(g, t, u.position, 6.0 * Defs.TILE)
		if foe:
			if u.target == null or not is_instance_valid(u.target) or u.target.dead:
				u.cmd_attack(foe)
		elif u.position.distance_to(goal) > 2.5 * Defs.TILE:
			_go(g, u, goal, true)


## CHECK THE FEEL: pictures of each part (docs/shots/e01_brazil/).
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(id: String, after: float) -> bool: return r.fired.has(id) and g.clock > float(r.fired.get(id, 0)) + after
	var want := {"start": g.clock > 4.0, "fall": g.clock > 30.0, "ford": f.call("fwave_1", 14.0), "ford2": f.call("fwave_3", 12.0),
		"break": f.call("part2", 6.0), "drum": f.call("drum_say", 2.0), "raid": f.call("raid_1", 8.0), "road": f.call("part2", 70.0),
		"port": f.call("part3", 4.0), "assault": f.call("assault_1", 25.0), "quay": f.call("part3", 60.0), "sail": f.call("sail", 2.0)}
	for k in want:
		if not want[k] or _shot_done.has(k):
			continue
		_shot_done[k] = true
		var at := Vector2.INF
		match k:
			"start", "ford", "ford2":
				at = _mid(r, "ford")
			"fall":
				at = _mid(r, "ford_far")
			"break", "drum", "raid", "road":
				var l := _laggard(r)
				at = l if l != Vector2.INF else _mid(r, "r3")
			"port", "assault":
				at = _mid(r, "bluff_front")
			"quay", "sail":
				at = _mid(r, "quay")
		g.camera.position = at
		for i in 4:
			await process_frame
		var img := root.get_viewport().get_texture().get_image()
		_shot_n += 1
		img.save_jpg("%s/%d_%s.jpg" % [shots, _shot_n, k], 0.85)
		print("SIM shot %s" % k)
