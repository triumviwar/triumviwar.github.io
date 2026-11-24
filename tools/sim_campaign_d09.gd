extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 2's second crossing, "Between Two Fires" (docs/campaign_d09_build.md), as the Crown with a simple bot and prints,
## every 30 seconds, how it goes: the part, the army, the people (with the column, in the fort, alive), the raids, the
## siege, the night, the clocks. A balance check (the owner's three rules: NO WAITING is measured):
##   - the army's player who plays it marches the road as one body (the wagons behind the line, Tomasz in the middle so the
##     villagers follow him), fights each raid where it comes, splits the army between the two gates at the fort, answers
##     the choice (first=brood|clockwork, else the seed's pick), trains Guardsmen at the fort's Barracks with the pay chest
##     and holds the night's gate: it wins at EASY, NORMAL and HARD;
##   - a player who does nothing (`lazy`): the army stands on the road; the fort's clock runs out and the siege begins
##     without it; the magazine should go up (lost) or the villagers never come in (`sertao` few).
## At the end: the mission's longest stretch with nothing to do (target under 45 s).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_d09.gd -- [active] [lazy] [diff=easy|normal|hard]
##        [first=brood|clockwork] [families=save|leave] [fields=left|burned] [spring=running|stopped] [brood_n=few|some|all]
##        [varenne=spared|executed] [until=<s>] [save_at=<s>] [shots=<dir>]
## The earlier missions' flags are written into the progress file for the run (and the player's own progress put back).
var main: Node
var until := 1500.0
var active := false
var lazy := false
var diff := "normal"
var first := ""
var shots := ""
var _shot_n := 0
var _shot_done := {}
var _saved_progress := ""
var _wp := 0
var _trained := 0
var fl := {
	"p01_leaf": ["crown", {"families": "save"}],
	"a06_barricades": ["crown", {"varenne": "spared", "paris": "stood"}],
	"a07_council": ["crown", {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}],
	"d01_minas": ["crown", {"minas": "quiet", "gold": "some", "conspirator": "taken"}],
	"d06_queen": ["brood", {"brood_n": "some", "pieter": "alive", "lindqvist": "fled"}],
	"d05_aldeia": ["crown", {"fields": "left", "aldeia": "some", "forward": "rooted"}],
	"d07_spring": ["guild", {"spring": "running", "honest": "some"}],
	"d08_rivers": ["barra", {"lure": "burned", "barra": "held", "nazare": "some"}],
}
const ROAD := [Vector2i(146, 47), Vector2i(136, 45), Vector2i(128, 43), Vector2i(120, 46), Vector2i(112, 51), Vector2i(104, 55),
	Vector2i(96, 57), Vector2i(88, 53), Vector2i(76, 50), Vector2i(62, 49), Vector2i(54, 48)]


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a == "lazy":
			lazy = true
		elif a.begins_with("shots="):
			shots = a.substr(6)
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.begins_with("first="):
			first = a.substr(6)
		elif a.begins_with("families="):
			fl["p01_leaf"][1]["families"] = a.substr(9)
		elif a.begins_with("fields="):
			fl["d05_aldeia"][1]["fields"] = a.substr(7)
		elif a.begins_with("spring="):
			fl["d07_spring"][1]["spring"] = a.substr(7)
		elif a.begins_with("brood_n="):
			fl["d06_queen"][1]["brood_n"] = a.substr(8)
		elif a.begins_with("varenne="):
			fl["a06_barricades"][1]["varenne"] = a.substr(8)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["d09_crossroads"], "done": {}, "difficulty": diff}
	for mid in fl:
		p["done"][mid] = {"won_by": fl[mid][0], "side": fl[mid][0], "flags": fl[mid][1]}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var probs := Campaign.problems(Campaign.mission("d09_crossroads"))
	if not probs.is_empty():
		print("SIM PROBLEMS ", probs)
	main.start(Campaign.make_cfg("d09_crossroads", "solo", "p1", false, ""))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	print("SIM diff=%s first=%s active=%s lazy=%s flags=%s human=%d" % [diff, first, active, lazy, str(fl.values().map(func(x): return x[1])), g.human])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
		if shots != "":
			await _shots(g, r)
		if active and not lazy and g.clock >= think:
			think = g.clock + 0.75
			_play(g, r)
		if first != "" and not r.choice_open.is_empty() and String(r.choice_open.get("id", "")) == "first":
			r.choose("first", first)
		if g.clock >= next:
			next += float(OS.get_environment("SIMSTEP")) if OS.get_environment("SIMSTEP") != "" else 30.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			print("SIM t=%4d part=%s army=%d hp=%d people=%d/%d column=%d fort=%d creatures=%d machines=%d siege_left=%d wagons=%d magazine=%s fort=%s siege=%s dawn=%s gold=%d first=%s" % [
				g.clock, part, _army(g, r).size(), _army_hp(g, r), r.tagged("people").size(), int(r.counters.get("people_n", 0)), r.tagged("column").size(),
				int(r.counters.get("in_fort", 0)), _n(g, r, "creatures"), _n(g, r, "automata"), int(r.counters.get("siege_left", 0)),
				r.tagged("wagons").size(), _hp(r, "magazine"), _left(g, r, "fort"), _left(g, r, "siege"), _left(g, r, "dawn"),
				int(g.players[r.team_index("army")]["gold"]), str(r.flags.get("first", "-"))])
	var idle: Dictionary = r.longest_idle()
	print("SIM end t=%d over=%s winner=%s flags=%s counters=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.counters, r.obj])
	print("SIM longest_idle %d s (from %d s)%s" % [int(idle.get("secs", 0.0)), int(idle.get("from", 0.0)), "" if float(idle.get("secs", 0.0)) < 45.0 else "  OVER 45 s"])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _hp(r: MissionRun, tag: String) -> String:
	var l: Array = r.tagged(tag)
	return "-" if l.is_empty() else "%d" % int(l[0].hp)


func _army(g: Game, r: MissionRun) -> Array:
	var t := r.team_index("army")
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind != "horse")


func _army_hp(g: Game, r: MissionRun) -> int:
	var s := 0.0
	for u in _army(g, r):
		s += u.hp
	return int(s)


func _n(g: Game, r: MissionRun, team: String) -> int:
	var t := r.team_index(team)
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind != "horse").size()


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
	if u.kind == "powder_wagon" or u.kind == "missionary":
		if u.position.distance_to(p) > 2.0 * Defs.TILE:
			_go(g, u, p)
		return
	var foe := _nearest_foe(g, t, u.position, reach * Defs.TILE)
	if foe:
		if u.target == null or not is_instance_valid(u.target) or u.target.dead:
			u.cmd_attack(foe)
	elif u.position.distance_to(p) > 2.5 * Defs.TILE:
		_go(g, u, p, true)


func _cell(g: Game, c: Vector2i) -> Vector2:
	return g.cell_center(c)


## The army's player.
func _play(g: Game, r: MissionRun) -> void:
	var at := r.team_index("army")
	var men: Array = _army(g, r)
	if men.is_empty():
		return
	var sum := Vector2.ZERO
	for u in men:
		sum += u.position
	var mid := sum / float(men.size())
	if not r.fired.has("part2"):
		# PART 1: march the road as one body; the next waypoint once the body's middle is near the current one
		var wp: Vector2 = _cell(g, ROAD[mini(_wp, ROAD.size() - 1)])
		if _wp < ROAD.size() - 1 and mid.distance_to(wp) < 5.0 * Defs.TILE:
			_wp += 1
			wp = _cell(g, ROAD[_wp])
		# (the column's people follow Tomasz: he walks with the body; the slowest (guns, wagons) set the pace)
		var slow := mid.lerp(wp, 0.35)
		var i := 0
		for u in men:
			var goal := wp
			if u.kind in ["cannon", "mortar", "powder_wagon", "missionary"]:
				goal = slow
			var off := Vector2(cos(i * 1.7), sin(i * 1.7)) * (1.5 + float(i % 3)) * Defs.TILE
			_fight_or_go(g, u, at, goal + off, 8.0)
			i += 1
		return
	# PART 2 and the NIGHT: split between the gates; the night: everyone at the gate it comes to
	var gate_n := _mid(r, "north_in") + Vector2(0, -2 * Defs.TILE)
	var gate_s := _mid(r, "south_in") + Vector2(0, 2 * Defs.TILE)
	var night_gate := Vector2.INF
	if r.fired.has("night"):
		night_gate = gate_n if str(r.flags.get("first", "")) == "clockwork" else gate_s
		# the pay chest: Guardsmen at the fort's Barracks
		if int(g.players[at]["gold"]) >= 120 and _trained < 8:
			for b in r.tagged("f_barracks"):
				if g.train(b, "musketeer") == "":
					_trained += 1
	var i := 0
	for u in men:
		var goal: Vector2 = night_gate if night_gate != Vector2.INF else (gate_n if i % 2 == 0 else gate_s)
		if u.kind == "powder_wagon" or u.kind == "missionary":
			goal = _mid(r, "fort_mid")
		var off := Vector2(cos(i * 1.3), sin(i * 1.3)) * (1.0 + float(i % 3)) * Defs.TILE
		_fight_or_go(g, u, at, goal + off, 9.0)
		i += 1


## CHECK THE FEEL: pictures of each part, the camera on what matters then (docs/shots/d09_crossroads/).
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(id: String, after: float) -> bool: return r.fired.has(id) and g.clock > float(r.fired.get(id, 0)) + after
	var want := {"start": g.clock > 3.0, "skies": f.call("skies", 9.0), "village": f.call("join_folk_v1", 2.0), "raid1": f.call("r1", 5.0),
		"machines": f.call("m1", 6.0), "owls": f.call("owls", 4.0), "raid3": f.call("r2", 5.0), "fort": f.call("part2", 4.0),
		"ford": f.call("ford_fight", 1.0), "siege": f.call("siege_c2", 8.0), "council": f.call("part3", 0.5), "choice": f.call("first_ask", 0.5),
		"night": f.call("night", 12.0), "night2": f.call("night", 75.0), "dawn": f.call("dawn", 2.0)}
	for k in want:
		if not want[k] or _shot_done.has(k):
			continue
		_shot_done[k] = true
		var at := Vector2.INF
		match k:
			"skies":
				var sk: Array = r.tagged("sky_c") + r.tagged("sky_m")
				at = sk[0].position if not sk.is_empty() else _mid(r, "sky_meet")
			"village":
				at = _mid(r, "riacho")
			"raid1":
				at = _mid(r, "riacho")
			"machines", "owls":
				at = _mid(r, "lagoa")
			"raid3":
				at = _mid(r, "road_west")
			"fort", "siege", "council", "choice", "dawn":
				at = _mid(r, "fort") + Vector2(2 * Defs.TILE, 0)
			"ford":
				at = _mid(r, "ford_east")
			"night", "night2":
				at = _mid(r, "north_gate") if str(r.flags.get("first", "")) == "clockwork" else _mid(r, "south_gate")
		if at == Vector2.INF:
			var men := _army(g, r)
			at = men[0].position if not men.is_empty() else _mid(r, "road_start")
		g.camera.position = at
		for i in 4:
			await process_frame
		var img := root.get_viewport().get_texture().get_image()
		_shot_n += 1
		img.save_jpg("%s/%d_%s.jpg" % [shots, _shot_n, k], 0.85)
		print("SIM shot %s" % k)
