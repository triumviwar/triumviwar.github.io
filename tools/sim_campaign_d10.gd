extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 2's "The Jungle Front" (docs/campaign_d10_build.md) from either side with a simple bot and prints, every 30
## seconds, how it goes: the part, the version, the forward Mothers (broken / standing), the wave, the column's men, the
## swarm's creatures, the keep, the island, the clocks. A balance check (the owner's three rules: NO WAITING is measured):
## the column's player sends Father Inácio's balloon west to the island at once, retakes the upriver battery when the
## Barra was lost, holds the west gate in Part 1, then marches the whole column (the balloon over it) from Mother to
## Mother, nearest first, trains Musketeers at Óbidos' Barracks, and in Part 3 crosses the east shallows to the island;
## a player who does nothing loses or holds by luck; the swarm's player lays at its Mothers, defends the nearest one the
## column comes at, and from 16 creatures goes for the keep.
## At the end: the mission's longest stretch with nothing to do (target under 45 s).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_d10.gd -- [active] [side=column|swarm]
##        [diff=easy|normal|hard] [first=brood|clockwork] [fields=left|burned] [lure=burned|used] [barra=held|burned]
##        [seal=broken] [map=drawn|withheld] [brood_n=few|some|all] [clutch=saved|burned] [noballoon] [until=<s>]
##        [save_at=<s>] [shots=<dir>]
##   first=clockwork: the GROWN version (d11 written as won first); noballoon: the balloon never leaves the fort
## The earlier missions' flags are written into the progress file for the run (and the player's own progress put back).
var main: Node
var until := 1800.0
var active := false
var noballoon := false
var side := "column"
var diff := "normal"
var first := "brood"
var seal := false
var b01 := {"clutch": "saved", "eggs": "left", "pieter": "alive", "rival": "standing", "teles": "quiet", "saved": "some"}
var a03 := {"map": "drawn", "party": "some", "survey": "full", "linnea": "seen", "sire_way": "east"}
var d05 := {"fields": "left", "aldeia": "some"}
var d06 := {"brood_n": "some", "brood_n_n": 4, "pieter": "alive", "lindqvist": "fled", "book": "left", "queen": "grown"}
var d08 := {"lure": "burned", "barra": "held", "nazare": "all"}
var _saved_progress := ""
var shots := ""
var _shot_n := 0
var _shot_done := {}
var _spot := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a == "noballoon":
			noballoon = true
		elif a == "seal=broken":
			seal = true
		elif a.begins_with("shots="):
			shots = a.substr(6)
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("side="):
			side = a.substr(5)
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.begins_with("first="):
			first = a.substr(6)
		elif a.begins_with("fields="):
			d05["fields"] = a.substr(7)
		elif a.begins_with("lure="):
			d08["lure"] = a.substr(5)
		elif a.begins_with("barra="):
			d08["barra"] = a.substr(6)
		elif a.begins_with("map="):
			a03["map"] = a.substr(4)
		elif a.begins_with("brood_n="):
			d06["brood_n"] = a.substr(8)
		elif a.begins_with("clutch="):
			b01["clutch"] = a.substr(7)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	Campaign.save_progress(progress_for(first, b01, a03, d05, d06, d08, diff, seal))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


## The progress as if everything up to d09 was won (with these flags); GROWN: d11 won too (the city first).
static func progress_for(fst: String, f_b01: Dictionary, f_a03: Dictionary, f_d05: Dictionary, f_d06: Dictionary, f_d08: Dictionary,
		dif := "normal", broken := false) -> Dictionary:
	var p := {"reached": ["d10_jungle"], "done": {"p01_leaf": {"won_by": "crown", "flags": {"families": "save"}}}, "difficulty": dif}
	p["done"]["b01_specimen"] = {"won_by": "sire", "side": "sire", "flags": f_b01}
	p["done"]["a03_plateau"] = {"won_by": "party", "side": "party", "flags": f_a03}
	p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}}
	p["done"]["d05_aldeia"] = {"won_by": "crown", "side": "crown", "flags": f_d05}
	p["done"]["d06_queen"] = {"won_by": "brood", "side": "brood", "flags": f_d06}
	p["done"]["d07_spring"] = {"won_by": "guild", "side": "guild", "flags": {"spring": "running", "honest": "some"}}
	p["done"]["d08_rivers"] = {"won_by": "swarm" if broken else "barra", "side": "swarm" if broken else "barra", "flags": f_d08}
	p["done"]["d09_crossroads"] = {"won_by": "crown", "side": "crown", "flags": {"first": fst, "fort": "held", "sertao": "many"}}
	if fst == "clockwork":
		p["done"]["d11_siege"] = {"won_by": "crown", "side": "crown", "flags": {"siege": "close", "jakob": "alive"}}
	return p


func _run() -> void:
	await process_frame
	var probs := Campaign.problems(Campaign.mission("d10_jungle"))
	if not probs.is_empty():
		print("SIM PROBLEMS ", probs)
	main.start(Campaign.make_cfg("d10_jungle", "solo", "p1", false, side))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	print("SIM side=%s diff=%s first=%s version=%s d05=%s d08=%s seal=%s active=%s human=%d" % [side, diff, first, r.flags.get("version"),
		str(d05), str(d08), seal, active, g.human])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
			_spot = {}
		if shots != "":
			await _shots(g, r)
		if active and g.clock >= think:
			think = g.clock + 0.75
			if side == "swarm":
				_play_swarm(g, r)
			else:
				_play_column(g, r)
		if g.clock >= next:
			next += float(OS.get_environment("SIMSTEP")) if OS.get_environment("SIMSTEP") != "" else 30.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else ("3" if not r.fired.has("ebb") else "E"))
			print("SIM t=%4d part=%s fwd=%d/%d left=%d wave=%d column=%d swarm=%d keep=%s isl=%d lw=%d bat=%d nests=%s ebb=%s dry=%s gold=%d" % [
				g.clock, part, int(r.counters.get("fwd_killed", 0)), int(r.counters.get("fwd_n", 0)), int(r.counters.get("fwd_left", 0)),
				int(r.counters.get("wave_n", 0)), _n(g, r, "column"), _n(g, r, "swarm"), _hp(r, "keep"), r.tagged("isl_ground").size(),
				r.tagged("lw").size(), r.tagged("bat_swarm").size(), _left(g, r, "nests"), _left(g, r, "ebb"), _left(g, r, "dry"),
				int(g.players[g.human]["gold"])])
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


func _n(g: Game, r: MissionRun, team: String) -> int:
	var t := r.team_index(team)
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind != "horse").size()


func _left(g: Game, r: MissionRun, cn: String) -> String:
	return "%ds" % int(float(r.clocks[cn]) - g.clock) if r.clocks.has(cn) else "-"


func _go(g: Game, u: Unit, p: Vector2, attack := false) -> void:
	if u.velocity.length() < 5.0 or u.order_point.distance_to(p) > 48.0:
		g.group_move([u], p, attack)


func _alive(u) -> bool:
	return u != null and is_instance_valid(u) and not u.dead


func _mid(r: MissionRun, a: String) -> Vector2:
	return r.area_rect(a).get_center()


func _nearest(r: MissionRun, tag: String, p: Vector2) -> Entity:
	var best: Entity = null
	for e in r.tagged(tag):
		if e.dead:
			continue
		var q: Vector2 = e.position if e is Unit else e.center()
		if best == null or q.distance_to(p) < (best.position if best is Unit else best.center()).distance_to(p):
			best = e
	return best


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


## The column's player.
func _play_column(g: Game, r: MissionRun) -> void:
	var ct := r.team_index("column")
	var men: Array = g.units.filter(func(u): return not u.dead and u.team == ct and u.kind != "horse" and u.kind != "balloon")
	var balloons: Array = g.units.filter(func(u): return not u.dead and u.team == ct and u.kind == "balloon")
	# the Barracks: Musketeers while the gold lasts
	for b in r.tagged("barracks"):
		if not b.dead and b.queue.size() < 2 and int(g.players[ct]["gold"]) >= 150 and g.can_train(b, "musketeer") == "":
			g.train(b, "musketeer")
	# where the column goes now
	var goal := _mid(r, "killground")
	var attack := true
	if not r.tagged("bat_swarm").is_empty():
		goal = _mid(r, "battery_top")
	elif r.fired.has("part3"):
		goal = _mid(r, "isl_ruins") if not r.tagged("isl_ground").is_empty() else _mid(r, "isl_e")
		if r.fired.has("last_wave") and not r.tagged("lw").is_empty():
			var lw := _nearest(r, "lw", _mid(r, "isl_e"))
			if lw and lw.position.distance_to(_mid(r, "isl_ruins")) < 30.0 * Defs.TILE:
				goal = lw.position
	elif r.fired.has("part2"):
		var c := _centre(men)
		var mo := _nearest(r, "fwd", c)
		if mo:
			goal = mo.position
	var centre := _centre(men)
	for u in men:
		if u.kind in ["cannon", "mortar", "powder_wagon"]:
			# the guns and the wagon keep behind the line
			_go(g, u, centre.lerp(_mid(r, "killground"), 0.15), false)
			continue
		var foe := _nearest_foe(g, ct, u.position, 7.0 * Defs.TILE)
		if foe and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
			u.cmd_attack(foe)
			continue
		if u.target == null or not is_instance_valid(u.target) or u.target.dead:
			_go(g, u, goal + Vector2(float(u.get_instance_id() % 5) * 20.0 - 40.0, float(u.get_instance_id() % 7) * 16.0 - 48.0), attack)
	# the balloon: west to the island at once; then over the column (GROWN: first over the west creek)
	for b in balloons:
		if noballoon:
			continue
		var bp := centre + Vector2(0, -2.0 * Defs.TILE)
		if not r.fired.has("part2"):
			bp = _mid(r, "lookout")
		elif r.fired.has("west_say") and not r.fired.has("west_seen"):
			bp = _mid(r, "m4")
		_go(g, b, bp, false)


func _centre(us: Array) -> Vector2:
	var c := Vector2.ZERO
	var n := 0
	for u in us:
		if u.kind in ["cannon", "mortar", "powder_wagon"]:
			continue
		c += u.position
		n += 1
	return c / maxf(1.0, float(n))


## The swarm's player.
func _play_swarm(g: Game, r: MissionRun) -> void:
	var st := r.team_index("swarm")
	var moms: Array = r.tagged("fwd").filter(func(u): return _alive(u))
	if moms.is_empty():
		return
	for m in moms:
		if BroodNew.rooted(m):
			BroodNew.lay(g, m, "raptor")
			BroodNew.lay(g, m, "spitter")
	var isl: Array = r.tagged("isl_guard")
	var army: Array = g.units.filter(func(u): return not u.dead and u.team == st and not (u.kind in BroodNew.ROOTERS) and u.has_attack() and u.kind != "grub" and not isl.has(u))
	# the Mother the column comes at
	var col: Array = r.tagged("line") + r.tagged("riders")
	var threat: Entity = null
	for m in moms:
		for c in col:
			if _alive(c) and c.position.distance_to(m.position) < 14.0 * Defs.TILE:
				threat = m
	var go: bool = (army.size() >= 24 and g.clock > 540.0) or _spot.has("go")
	if go:
		_spot["go"] = true
	for u in army:
		if u.target != null and is_instance_valid(u.target) and not u.target.dead:
			continue
		if threat:
			_go(g, u, threat.position, true)
		elif go:
			var k := _nearest(r, "keep", u.position)
			if k and u.position.distance_to(k.center()) < 10.0 * Defs.TILE:
				u.cmd_attack(k)
			else:
				_go(g, u, _mid(r, "keep_go"), true)
		else:
			_go(g, u, _mid(r, "m1"))


## CHECK THE FEEL: pictures of each part (docs/shots/d10_jungle/).
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(id: String, after: float) -> bool: return r.fired.has(id) and g.clock > float(r.fired.get(id, 0)) + after
	var want := {"start": g.clock > 3.0, "fog": g.clock > 20.0, "raid": f.call("raid_1", 14.0), "balloon": g.clock > 40.0 and not r.fired.has("part2"),
		"reclaim": f.call("reclaim_on", 20.0), "lift": f.call("part2", 1.0), "nest": f.call("part2", 40.0), "wave": f.call("wave_2_go", 16.0),
		"toad": f.call("toad_say", 1.0), "lured": f.call("lured_say", 2.0), "west": f.call("west_seen", 1.0), "island": f.call("part3", 30.0),
		"last": f.call("lw_go", 25.0), "smell": f.call("smell_go", 10.0), "ebb": f.call("ebb", 3.0), "s_attack": g.clock > 400.0 and side == "swarm"}
	for k in want:
		if not want[k] or _shot_done.has(k):
			continue
		_shot_done[k] = true
		var at := Vector2.INF
		match k:
			"start", "fog":
				at = _mid(r, "col_start") + Vector2(-8 * Defs.TILE, 0)
			"raid", "wave", "lured", "smell", "s_attack":
				at = _mid(r, "killground")
			"reclaim":
				at = _mid(r, "battery")
			"balloon", "lift":
				var b: Array = r.tagged("inacio")
				at = b[0].position if not b.is_empty() else _mid(r, "lookout")
			"nest", "toad":
				var mo := _nearest(r, "fwd", _mid(r, "m1"))
				at = mo.position if mo else _mid(r, "m1")
			"west":
				at = _mid(r, "m4")
			"island", "ebb":
				at = _mid(r, "isl_ruins")
			"last":
				at = _mid(r, "isl_w")
		if at == Vector2.INF:
			at = _mid(r, "obidos_mid")
		g.camera.position = at
		for i in 4:
			await process_frame
		var img := root.get_viewport().get_texture().get_image()
		_shot_n += 1
		img.save_jpg("%s/%d_%s_%s.jpg" % [shots, _shot_n, side, k], 0.85)
		print("SIM shot %s" % k)
