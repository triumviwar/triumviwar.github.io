extends SceneTree
## Plays the Naturalist's prologue, "Specimen One", AS THE BROOD (docs/campaign_b01_build.md: the prologue flip), with a
## simple Brood player bot against the rival pack (the Brood computer, Easy) and the scripted station, and prints every
## minute how it goes: the step of the teaching strip, the pack, the rival pack, the station, the eggs, the people saved.
## A balance check: a player who plays the strip wins in a sensible time; the rival pack is a real fight (it costs the
## player creatures); a player who does nothing does not win (the rival comes for the Old Mother, or nothing happens).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_b01.gd [-- active] [eggs=left|taken] [until=<s>]
##        [rival=easy|normal|hard] [raid] (raid: waves at the rival Mother first)
##        [rush] (rush: go for her as soon as the strip allows, with the starting pack) [speed=<x>]
##        [shots=<dir>] (pictures of the steps; needs a window: xvfb-run, not --headless)
var main: Node
var until := 2400.0
var active := false
var rush := false
var rival_level := ""
var raid := false          # ("raid": waves at the rival Mother first, the Sire kept home)
var eggs := "left"
var shots := ""
var _shot_n := 0
var _shot_done := {}
var _go_t := -1.0          # (when the pack set off for the station)
var _maw_sent := false
var _hits := {}
var _killers := {}
var _state := "build"       # build (home, rooted), out (to the edge, the roar), clear (the yard's guns), nest, home
var _rebuilds := 0
var _dead_seen := {}
var _raid := false        # (a wave out at the rival's den)


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		if a == "rush":
			rush = true
		if a == "raid":
			raid = true
		if a.begins_with("until="):
			until = float(a.substr(6))
		if a.begins_with("rival="):
			rival_level = a.substr(6)
		if a.begins_with("eggs="):
			eggs = a.substr(5)
		if a.begins_with("shots="):
			shots = a.substr(6)
		if a.begins_with("speed="):
			Engine.time_scale = float(a.substr(6))
			Engine.max_physics_steps_per_frame = 32
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var cfg := Campaign.make_cfg("b01_specimen", "solo")
	if rival_level != "":
		cfg["slots"][1]["who"] = rival_level        # (the rival computer's level: easy as written, "rival=normal" to try)
	main.start(cfg)
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 2.0
	var me := r.team_index("sire")
	var rv := r.team_index("rival")
	var made := 0
	var seen := {}
	while g.clock < until and not g.over:
		await physics_frame
		if not r.choice_open.is_empty() and String(r.choice_open["id"]) == "eggs":
			r.choose("eggs", eggs)
		for u in g.units:
			if u.team == me and not seen.has(u.get_instance_id()):
				seen[u.get_instance_id()] = u
				made += 1
		if int(g.clock * 30.0) % 15 == 0:
			for id in seen:
				var su = seen[id]
				if not _dead_seen.has(id) and (not is_instance_valid(su) or su.dead):
					_dead_seen[id] = true
					var why: String = su.last_hit_by if is_instance_valid(su) else "?"
					_killers[why] = int(_killers.get(why, 0)) + 1
		var sl: Array = r.tagged("sire")
		if not sl.is_empty() and sl[0].last_hit_by != "":
			_hits[sl[0].last_hit_by] = int(_hits.get(sl[0].last_hit_by, 0)) + 1
			sl[0].last_hit_by = ""
		if active and g.clock >= think:
			think = g.clock + 1.0
			_play(g, r, me)
		if shots != "":
			await _shots(g, r)
		if g.clock >= next:
			next += 60.0
			var step := "root"
			for o in ["root", "lay", "roar", "nest", "gate", "home"]:
				if r.obj.get(o, "") == "active":
					step = o
			var sire: Array = r.tagged("sire")
			print("SIM t=%4d %-5s step=%-5s hunters=%2d pack=%2d raptors=%2d grubs=%d turtles=%d food=%4d supply=%d/%d | rival=%2d rival_army=%2d | station=%2d garrison=%2d folk=%2d | eggs=%d jars=%d saved=%d/%d heroes=%d | sire=%s mother=%s" % [g.clock, _state, step, r.count({"team": "hunters"}),
				_army(g, me).size(), r.count({"team": "sire", "kind": "raptor"}), r.count({"team": "sire", "kind": "grub"}), r.count({"team": "sire", "kind": "mound_turtle"}),
				int(g.players[me]["gold"]), g.supply_used(me), int(g.players[me]["cap"]),
				r.count({"team": "rival"}), _army(g, rv).size(), r.count({"team": "station"}), r.count({"team": "garrison"}), r.tagged("folk").size(),
				int(r.counters.get("eggs", 0)), int(r.counters.get("jars", 0)), int(r.counters.get("saved", 0)), int(r.counters.get("people", 0)), int(r.counters.get("heroes", 0)),
				(("rooted" if BroodNew.rooted(sire[0]) else "up") + " %d" % sire[0].hp) if not sire.is_empty() else "DEAD", _hp(r, "old_mother")])
	var lost := made - g.units.filter(func(u): return not u.dead and u.team == me).size()
	print("SIM end t=%d over=%s winner=%s went=%s rebuilds=%d flags=%s" % [g.clock, g.over, r.winner_side, ("%d" % _go_t) if _go_t >= 0.0 else "-", _rebuilds, r.flags])
	print("SIM player creatures made=%d lost=%d (some lost to sacrifice/morph count as lost) rival alive=%d rival_mother=%s" % [made, lost, r.count({"team": "rival"}), _hp(r, "rival_mother")])
	print("SIM objectives %s" % r.obj)
	for h in ["sire", "old_mother"]:
		var hs: Array = r.tagged(h, false)
		if not hs.is_empty() and is_instance_valid(hs[0]) and hs[0].dead:
			print("SIM %s died at cell %s (state %s)" % [h, g.cell_of(hs[0].position), _state])
	print("SIM the Sire was hit by (kind, samples) %s" % _hits)
	print("SIM the pack's dead, by the last hit's kind %s" % _killers)
	quit()


func _hp(r: MissionRun, tag: String) -> String:
	var t := r.tagged(tag)
	return "DEAD" if t.is_empty() else str(int(t[0].hp))


func _army(g: Game, t: int) -> Array:
	return g.units.filter(func(u): return not u.dead and u.team == t and not u.is_worker() and not BroodNew.ROOTERS.has(u.kind) and u.kind != "brood_egg")


func _go(g: Game, us: Array, p: Vector2, fight := true) -> void:
	var idle: Array = us.filter(func(u): return u.position.distance_to(p) > 120.0 and (u.velocity.length() < 5.0 or u.order == "idle"))
	if not idle.is_empty():
		g.group_move(idle, p, fight)


## A spot for `k` round `c` (rings out from `r0` to `r1` tiles) where `u` may root (BroodRoot's own rules).
func _spot(g: Game, t: int, k: String, c: Vector2, u: Unit, r0: int, r1: int) -> Vector2:
	for rad in range(r0, r1 + 1):
		for i in 16:
			var a := TAU * float(i) / 16.0
			var p := BroodRoot.snap(k, c + Vector2(cos(a), sin(a)) * rad * Defs.TILE, 1.0)
			if BroodRoot.place_problem(g, t, k, p, u, false, 1.0) == "":
				return p
	return Vector2.INF


func _play(g: Game, r: MissionRun, me: int) -> void:
	var q := BroodNew.queen(g, me)
	var sire_l: Array = r.tagged("sire")
	if q == null or sire_l.is_empty():
		return
	var sire: Unit = sire_l[0]
	var army := _army(g, me).filter(func(u): return u != sire)
	var grubs: Array = g.units.filter(func(u): return not u.dead and u.team == me and u.kind == "grub" and u.order != "nb_morph")
	var turtles := r.count({"team": "sire", "kind": "mound_turtle"}) + g.units.filter(func(u): return u.team == me and u.order == "nb_morph").size()
	var den := r.area_rect("den").get_center()
	var home_nest := sire.position.distance_to(q.position) < 9.0 * Defs.TILE
	# THE ECONOMY (while she is not out of her pen): grubs to 10, a second Rootmaw, Mound Turtles when the supply runs
	# short, Raptors with the rest (only while the Sire is rooted beside the Old Mother)
	if not r.fired.has("broken"):
		var room := int(g.players[me]["cap"]) - g.supply_used(me)
		var maws := r.count({"team": "sire", "kind": "rootmaw"}) + g.units.filter(func(u): return u.team == me and u.order == "nb_morph" and String(u.nb.get("mk", "")) == "rootmaw").size()
		if room < 4 and turtles < 4 and not grubs.is_empty() and int(g.players[me]["gold"]) >= 100:
			var tp := _spot(g, me, "mound_turtle", q.position, grubs[0], 8, 14)
			if tp != Vector2.INF:
				BroodRoot.start_morph(grubs[0], "mound_turtle", tp)
		elif maws < 2 and g.clock > 40.0 and int(g.players[me]["gold"]) >= 75 and not grubs.is_empty() and not _maw_sent:
			var mp := _spot(g, me, "rootmaw", q.position, grubs[0], 5, 12)
			if mp != Vector2.INF:
				BroodRoot.start_morph(grubs[0], "rootmaw", mp)
				_maw_sent = true
		elif r.count({"team": "sire", "kind": "grub"}) < 10 and int(g.players[me]["gold"]) >= 50:
			BroodNew.lay(g, q, "grub")
		elif BroodNew.rooted(sire) and home_nest:
			BroodNew.lay(g, q, "raptor")
	# 1. ROOT the Sire in the Old Mother's father range (and again whenever he comes home to rebuild)
	var want := 6 if rush else 24
	if _state == "build":
		if not BroodNew.rooted(sire):
			if sire.order != "nb_root":
				var p := _spot(g, me, "tyrannosaur", q.position, sire, 3, 7)
				if p != Vector2.INF:
					sire.give({"o": "nb_root", "p": p}, false)
			return
		_go(g, army, den + Vector2(220, 60))
		if r.fired.has("laid") and (army.size() >= want or g.clock > 1200.0):
			_state = "out"
			if _go_t < 0.0:
				_go_t = g.clock
		return
	# the pack spent: the Sire goes home to rebuild (his nest by the Old Mother) unless she is already out
	if army.size() < 4 and not r.fired.has("broken") and not (BroodNew.rooted(sire) and int(r.counters.get("eggs", 0)) >= 4):
		_state = "build"
		_rebuilds += 1
		if BroodNew.rooted(sire):
			BroodNew.uproot(sire, false)
		return
	if BroodNew.rooted(sire) and _state in ["out", "home"]:
		BroodNew.uproot(sire, false)
		return
	var west := r.area_rect("jar_w").get_center()
	var above := Vector2(62, 47) * Defs.TILE
	if _state == "out":
		# by the west: the forest's edge at the west jar (away from the rival's den), the roar there, then east above the station
		var to := west if not r.fired.has("roar_heard") else above
		_lead(g, sire, army, to)
		if r.fired.has("roar_heard") and sire.position.distance_to(above) < 160.0:
			_state = "clear"
		return
	if r.fired.has("broken"):
		_state = "home"
	if _state == "clear":
		var pen := r.area_rect("pen").get_center()
		var foes := [r.team_index("station"), r.team_index("garrison")]
		var guns: Array = g.units.filter(func(u): return not u.dead and foes.has(u.team) and u.kind in ["musketeer", "dismounted"] and not u.spared and u.position.distance_to(pen) < 560.0)
		if guns.is_empty():
			_state = "nest"
		else:
			for u in army:
				if u.target == null or not is_instance_valid(u.target) or u.target.dead:
					u.cmd_attack(guns[0])
			return
	if _state == "nest":
		var pen := r.area_rect("pen").get_center()
		# the pack keeps round him: anything that comes at the rooted Sire first, then the gate
		# (only what is coming at the pack or close by: a garrison holding in its fort out of reach is not a threat, and
		# chasing it kept the pack off the gate for good: roster-ladder's runs, on main too)
		var threats: Array = g.units.filter(func(u): return _threat(g, u, me, sire))
		if not threats.is_empty():
			threats.sort_custom(func(a, b): return a.position.distance_to(sire.position) < b.position.distance_to(sire.position))
			for u in army:
				if u.target == null or not is_instance_valid(u.target) or u.target.dead or u.target is Building:
					u.cmd_attack(threats[0])
			return
		_go(g, army, pen + Vector2(60, -60))
		if not BroodNew.rooted(sire) and sire.order != "nb_root":
			var p := _spot(g, me, "tyrannosaur", r.area_rect("nest").get_center(), sire, 0, 6)
			if p != Vector2.INF:
				sire.give({"o": "nb_root", "p": p}, false)
			else:
				g.group_move([sire], r.area_rect("nest").get_center(), false)
		var gate: Array = r.tagged("pen_gate")
		if r.obj.get("gate", "") == "active" and not gate.is_empty():
			for u in army:
				if u.target != gate[0]:
					u.cmd_attack(gate[0])
		return
	if _state == "home":
		# 6. HOME: the Sire up and back to the den by the west; the pack round him. A fight at the den (the rival's push
		# at the Old Mother): the pack goes in first, the Sire waits out of it
		var at_den: Array = g.units.filter(func(u): return not u.dead and g.hostile(u.team, me) and u.position.distance_to(q.position) < 14.0 * Defs.TILE)
		if not at_den.is_empty() and army.size() >= 3:
			_go(g, army, at_den[0].position)
			if sire.position.distance_to(q.position) < 24.0 * Defs.TILE and sire.position.distance_to(at_den[0].position) < 10.0 * Defs.TILE:
				g.group_move([sire], sire.position + (sire.position - at_den[0].position).normalized() * 160.0, false)
			elif sire.position.distance_to(q.position) < 22.0 * Defs.TILE:
				g.group_move([sire], sire.position, false)
			return
		var to := den if sire.position.y < 44.0 * Defs.TILE or sire.position.distance_to(west) < 200.0 else west
		if sire.position.x < 40.0 * Defs.TILE and sire.position.y > 40.0 * Defs.TILE:
			to = Vector2(24, 30) * Defs.TILE if sire.position.y > 32.0 * Defs.TILE else den
		_lead(g, sire, army, to)


## The Sire walks to `to` with the pack round him (attack-moving), waiting for stragglers.
func _lead(g: Game, sire: Unit, army: Array, to: Vector2) -> void:
	var near := army.filter(func(u): return u.position.distance_to(sire.position) < 260.0).size()
	if near < army.size() / 2 and sire.position.distance_to(to) > 200.0:
		g.group_move([sire], sire.position, false)
		_go(g, army, sire.position)
		return
	if sire.position.distance_to(to) > 90.0 and (sire.order == "idle" or sire.velocity.length() < 5.0 or sire.order_point.distance_to(to) > 60.0):
		g.group_move([sire], to, true)
	_go(g, army, sire.position + (to - sire.position).limit_length(120.0))


## Pictures of the steps (with a window): the den, the Sire rooted, the pack out, the roar, the Sire by her pen, the
## clutch, the pen broken, the way home, home.
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(t: String, d: float) -> bool: return r.fired.has(t) and g.clock > float(r.fired.get(t, 0)) + d
	var want := {"den": g.clock > 3.0, "rooted": f.call("rooted_1", 3.0), "roar": f.call("roar_heard", 2.0),
		"breakin": f.call("turn", 6.0), "nest": f.call("sire_rooted", 4.0), "clutch": f.call("eggs", 50.0),
		"broken": f.call("broken", 3.0), "fire": f.call("broken", 20.0), "home": f.call("home", 1.0)}
	var where := {"den": "den", "rooted": "den", "roar": "edge", "breakin": "nest_wide", "nest": "nest", "clutch": "pen",
		"broken": "pen", "fire": "yard", "home": "den"}
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


## A threat to the rooted Sire (the "nest" step): an enemy within 420 px that is close (200) or going for the pack.
func _threat(g: Game, u: Unit, me: int, sire: Unit) -> bool:
	if u.dead or not g.hostile(u.team, me) or u.spared or u.kind == "brood_egg":
		return false
	var d := u.position.distance_to(sire.position)
	if d >= 420.0:
		return false
	if d < 200.0:
		return true
	return u.target != null and is_instance_valid(u.target) and not u.target.dead and u.target.team == me
