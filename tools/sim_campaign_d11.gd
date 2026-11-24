extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 2's "The Siege of Concórdia" (docs/campaign_d11_build.md) as the southern column with a simple bot and prints,
## every 30 seconds, how it goes: the part, the column, the earthworks dug, the city's men outside the wall, the sorties,
## the mine or the great sortie, the clocks. A balance check (the owner's three rules: NO WAITING is measured):
##   - the column's player who plays it sends the pioneers to dig every earthwork (the nearest first), sets the guns and
##     the line behind the earthworks (two-thirds at the west battery, the rest at the north), keeps Jakob and Ferrer back
##     at the camp, researches PREPARED CHARGES and the QUADRANT, fights what comes out of the gates; FRESH: walks two
##     pioneers to the old mine's mouth and holds it; GROWN: holds the camp and stands men at the mine's mouth before the
##     diggers come up. It should win at EASY, NORMAL and HARD, both versions;
##   - a player who does nothing (`lazy`): the earthworks undug, the guns at the camp; the night comes by its clock, then
##     the sorties, then Part 3 by its clock: FRESH never sends the pioneers down (the mine waits: the sim ends at `until`),
##     GROWN the great sortie at the park.
## At the end: the mission's longest stretch with nothing to do (target under 45 s).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_d11.gd -- [active] [lazy] [diff=easy|normal|hard]
##        [first=brood|clockwork] [jakob=lost] [stopworks=logged] [spring=stopped] [colonists=fought] [until=<s>]
##        [save_at=<s>] [shots=<dir>]
## The earlier missions' flags are written into the progress file for the run (and the player's own progress put back).
var main: Node
var until := 1200.0
var active := false
var lazy := false
var diff := "normal"
var shots := ""
var _shot_n := 0
var _shot_done := {}
var _saved_progress := ""
var _trained := 0
var fl := {
	"c01_thirteenth": ["guild", {"jakob": "alive", "bells": "quiet", "saved": "some", "gate": "pattern"}],
	"a04_visit": ["visit", {"broken": "kept", "stopworks": "found", "jakob": "alive"}],
	"a07_council": ["crown", {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}],
	"d04_concordia": ["guild", {"colonists": "parley"}],
	"d07_spring": ["guild", {"spring": "running", "honest": "some"}],
	"d09_crossroads": ["crown", {"first": "brood", "fort": "held", "sertao": "some"}],
	"d10_jungle": ["crown", {"jungle": "held"}],
}


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
			fl["d09_crossroads"][1]["first"] = a.substr(6)
		elif a.begins_with("jakob="):
			fl["c01_thirteenth"][1]["jakob"] = a.substr(6)
		elif a.begins_with("stopworks="):
			fl["a04_visit"][1]["stopworks"] = a.substr(10)
		elif a.begins_with("spring="):
			fl["d07_spring"][1]["spring"] = a.substr(7)
		elif a.begins_with("colonists="):
			fl["d04_concordia"][1]["colonists"] = a.substr(10)
	if String(fl["d09_crossroads"][1]["first"]) != "brood":
		fl.erase("d10_jungle")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["d11_siege"], "done": {}, "difficulty": diff}
	for mid in fl:
		p["done"][mid] = {"won_by": fl[mid][0], "side": fl[mid][0], "flags": fl[mid][1]}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var probs := Campaign.problems(Campaign.mission("d11_siege"))
	if not probs.is_empty():
		print("SIM PROBLEMS ", probs)
	main.start(Campaign.make_cfg("d11_siege", "solo", "p1", false, ""))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	print("SIM diff=%s active=%s lazy=%s flags=%s human=%d" % [diff, active, lazy, str(fl.values().map(func(x): return x[1])), g.human])
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
		if g.clock >= next:
			next += float(OS.get_environment("SIMSTEP")) if OS.get_environment("SIMSTEP") != "" else 30.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			var dug := r.tagged("earthworks").filter(func(b): return not b.dead and b.built).size()
			print("SIM t=%4d part=%s version=%s column=%d hp=%d dug=%d/12 city_out=%d sortie=%d park=%s spring=%s jakob=%s dusk=%s dawn=%s mine=%s relief=%s gold=%d tech=%s" % [
				g.clock, part, str(r.flags.get("version", "-")), _team(g, r, "column").size(), _team_hp(g, r, "column"), dug, int(r.counters.get("out_n", 0)),
				int(r.counters.get("sortie_n", 0)), _hp(r, "park"), _hp(r, "spring"), "yes" if not r.tagged("jakob").filter(func(u): return not u.dead).is_empty() else "no",
				_left(g, r, "dusk"), _left(g, r, "dawn"), _left(g, r, "mine"), _left(g, r, "relief"), int(g.players[r.team_index("column")]["gold"]),
				"charges" if g.has_tech(r.team_index("column"), "charges") else "-"])
	var idle: Dictionary = r.longest_idle()
	print("SIM end t=%d over=%s winner=%s flags=%s counters=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.counters, r.obj])
	print("SIM longest_idle %d s (from %d s)%s" % [int(idle.get("secs", 0.0)), int(idle.get("from", 0.0)), "" if float(idle.get("secs", 0.0)) < 45.0 else "  OVER 45 s"])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


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
	if u.kind == "powder_wagon" or u.kind == "missionary" or u.kind == "labourer":
		if u.position.distance_to(p) > 2.0 * Defs.TILE:
			_go(g, u, p)
		return
	var foe := _nearest_foe(g, t, u.position, reach * Defs.TILE)
	if foe:
		if u.target == null or not is_instance_valid(u.target) or u.target.dead:
			u.cmd_attack(foe)
	elif u.position.distance_to(p) > 2.5 * Defs.TILE:
		_go(g, u, p, true)


## The column's player.
func _play(g: Game, r: MissionRun) -> void:
	var t := r.team_index("column")
	var men: Array = _team(g, r, "column")
	if men.is_empty():
		return
	# the Armoury: the charges, then the quadrant; the Barracks: Musketeers with what is left over
	for b in r.tagged("c_armoury"):
		if b.dead:
			continue
		for k in ["charges", "quadrant"]:
			if not g.has_tech(t, k) and not g.researching(t, k):
				g.start_research(b, k)
	if int(g.players[t]["gold"]) >= 150 and _trained < 16:
		for b in r.tagged("c_barracks"):
			if not b.dead and g.train(b, "musketeer") == "":
				_trained += 1
	var sites: Array = r.tagged("earthworks").filter(func(b): return not b.dead and not b.built)
	var pios: Array = r.tagged("pioneers").filter(func(u): return not u.dead and not u.off_field)
	var p3 := r.fired.has("part3")
	var fresh := str(r.flags.get("version", "")) == "fresh"
	var mouth := _mid(r, "mine_mouth")
	var i := 0
	for u in pios:
		if p3 and fresh and not r.fired.has("sap_said"):
			_go(g, u, mouth + Vector2((i % 2) * 20 - 10, 0))
		elif not sites.is_empty() and not p3:
			var s: Building = sites[i % sites.size()]
			if u.target != s:
				u.cmd_build(s)
		elif u.position.distance_to(_mid(r, "camp_mid")) > 3 * Defs.TILE:
			_go(g, u, _mid(r, "camp_mid"))
		i += 1
	# the army: the west battery (two thirds) and the north; Part 3: the mine's mouth (FRESH) or the camp (GROWN)
	var bat_w := _mid(r, "bat_w") + Vector2(-2 * Defs.TILE, 0)
	var bat_n := _mid(r, "bat_n") + Vector2(-2 * Defs.TILE, 0)
	var bat_s := _mid(r, "bat_s") + Vector2(-2 * Defs.TILE, 0)
	var j := 0
	for u in men:
		if u.kind == "labourer":
			continue
		var goal := bat_w if j % 3 != 0 else (bat_n if j % 2 == 0 else bat_s)
		if u.kind == "missionary" or u.kind == "dismounted":
			goal = _mid(r, "camp_mid")
		elif p3 and fresh and not r.fired.has("spring_down"):
			goal = mouth + Vector2(4 * Defs.TILE, 2 * Defs.TILE)
		elif p3 and not fresh:
			goal = _mid(r, "park_near") if j % 3 == 0 and not r.fired.has("dig_up") else _mid(r, "camp_mid") + Vector2(6 * Defs.TILE, 0)
		var off := Vector2(cos(j * 1.3), sin(j * 1.3)) * (1.0 + float(j % 3)) * Defs.TILE
		_fight_or_go(g, u, t, goal + off, 9.0)
		j += 1


## CHECK THE FEEL: pictures of each part (docs/shots/d11_siege/).
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(id: String, after: float) -> bool: return r.fired.has(id) and g.clock > float(r.fired.get(id, 0)) + after
	var want := {"start": g.clock > 3.0, "lines": g.clock > 30.0, "probe": f.call("probe1", 8.0), "hollweg": f.call("hollweg_seen", 1.0),
		"owls": f.call("owls_camp", 5.0), "dug": f.call("lines_done", 1.0), "night": f.call("s1", 8.0), "dawn": f.call("s2", 10.0),
		"sortie3": f.call("s3", 10.0), "mine": f.call("mine_on", 2.0), "under": f.call("sap_said", 15.0), "spring": f.call("spring_down", 1.5),
		"great": f.call("hold_on", 15.0), "diggers": f.call("dig_up", 2.0), "big": f.call("g3", 10.0), "dusk": f.call("held_off", 2.0)}
	for k in want:
		if not want[k] or _shot_done.has(k):
			continue
		_shot_done[k] = true
		var at := Vector2.INF
		match k:
			"start", "owls", "great":
				at = _mid(r, "camp_mid") + Vector2(6 * Defs.TILE, 0)
			"lines", "dug":
				at = _mid(r, "bat_w") + Vector2(2 * Defs.TILE, 0)
			"probe":
				at = _mid(r, "bat_n") + Vector2(3 * Defs.TILE, 0)
			"hollweg", "spring":
				at = _mid(r, "spring_top")
			"night", "sortie3":
				at = _mid(r, "west_out")
			"dawn":
				at = _mid(r, "north_out")
			"diggers":
				at = _mid(r, "park_near")
			"mine", "under":
				at = _mid(r, "mine_mouth") + Vector2(4 * Defs.TILE, 2 * Defs.TILE)
			"big", "dusk":
				at = _mid(r, "camp_mid") + Vector2(8 * Defs.TILE, 0)
		g.camera.position = at
		for i in 4:
			await process_frame
		var img := root.get_viewport().get_texture().get_image()
		_shot_n += 1
		img.save_jpg("%s/%d_%s.jpg" % [shots, _shot_n, k], 0.85)
		print("SIM shot %s" % k)
