extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 2's "The Mission of São Rafael" (docs/campaign_d05_build.md) from either side with a simple bot and prints,
## every 30 seconds, how it goes: the part, the people (in the churchyard, at the fort, alive), the waves, the relief, the
## clocks. A balance check (the owner's three rules: NO WAITING is measured):
##   - the mission's player who plays it sends a soldier to each field, holds the bluff, rides to the hamlet with the
##     relief and some militia, drills the Charge, then walks Tomasz down the trail a little ahead of the people with the
##     soldiers round the column: it wins at EASY, NORMAL and HARD;
##   - a player who does nothing (`lazy`): the people in the fields die in the night, the hamlet falls, nobody walks the
##     road (the gate shuts at dusk): lost or `aldeia` few;
##   - the swarm's player (side=swarm) who plays it lays Raptors, raids the fields at night and the column on the road.
## At the end: the mission's longest stretch with nothing to do (target under 45 s).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_d05.gd -- [active] [side=crown|swarm]
##        [diff=easy|normal|hard] [people=some|many] [brood_n=few|some|all] [gold=few|some|all] [cages=some|all]
##        [minas=quiet|restless] [fields=burned|left] [lazy] [until=<s>] [save_at=<s>] [shots=<dir>]
## The earlier missions' flags are written into the progress file for the run (and the player's own progress put back).
var main: Node
var until := 1500.0
var active := false
var lazy := false
var side := "crown"
var diff := "normal"
var fields := ""
var a05 := {"cages": "some", "cages_n": 2, "eggs": "taken", "pieter": "alive", "way": "short", "crates": "seen"}
var a07 := {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}
var d01 := {"minas": "quiet", "gold": "some", "conspirator": "taken"}
var d06 := {"brood_n": "some", "pieter": "alive", "lindqvist": "fled", "book": "left", "queen": "grown"}
var _saved_progress := ""
var shots := ""
var _shot_n := 0
var _shot_done := {}
var _job := {}          # unit -> its job ("field_w" ...)
var _wp := 0            # Tomasz's waypoint on the trail
const TRAIL := ["trail_1", "trail_2", "trail_3", "trail_4", "trail_5", "trail_6", "trail_7", "fort_gate", "fort_in"]


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
		elif a.begins_with("side="):
			side = a.substr(5)
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.begins_with("fields="):
			fields = a.substr(7)
		elif a.begins_with("people="):
			a07["people"] = a.substr(7)
		elif a.begins_with("brood_n="):
			d06["brood_n"] = a.substr(8)
		elif a.begins_with("gold="):
			d01["gold"] = a.substr(5)
		elif a.begins_with("minas="):
			d01["minas"] = a.substr(6)
		elif a.begins_with("cages="):
			a05["cages"] = a.substr(6)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["d05_aldeia"], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	p["done"]["a05_specimens"] = {"won_by": "expedition", "side": "expedition", "flags": a05}
	p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": a07}
	p["done"]["d01_minas"] = {"won_by": "crown", "side": "crown", "flags": d01}
	p["done"]["d06_queen"] = {"won_by": "brood", "side": "brood", "flags": d06}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var probs := Campaign.problems(Campaign.mission("d05_aldeia"))
	if not probs.is_empty():
		print("SIM PROBLEMS ", probs)
	main.start(Campaign.make_cfg("d05_aldeia", "solo", "p1", false, side))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	print("SIM side=%s diff=%s a07=%s d01=%s d06=%s a05=%s active=%s lazy=%s fields=%s human=%d" % [side, diff, str(a07), str(d01), str(d06),
		str(a05["cages"]), active, lazy, fields, g.human])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
			_job = {}
		if shots != "":
			await _shots(g, r)
		if active and g.clock >= think:
			think = g.clock + 0.75
			if side == "swarm":
				_play_swarm(g, r)
			elif not lazy:
				_play_crown(g, r)
		if fields != "" and r.fired.has("fields_ask") and not r.flags.has("fields") and side == "crown":
			r.choose("fields", fields)
		if g.clock >= next:
			next += float(OS.get_environment("SIMSTEP")) if OS.get_environment("SIMSTEP") != "" else 30.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			print("SIM t=%4d part=%s people=%d/%d church=%s sheltered=%d/%d hamlet=%d/%d fort=%d dead=%d swarm=%d mission=%d relief=%d hatch=%d fwd=%s waves=%d night=%s hamlet=%s column=%s gold=%d fed=%d tomasz=%s" % [
				g.clock, part, r.tagged("people").size(), int(r.counters.get("people_n", 0)), _hp(r, "church"),
				int(r.counters.get("sheltered", 0)), int(r.counters.get("field_n", 0)), int(r.counters.get("hamlet_in", 0)), int(r.counters.get("hamlet_n", 0)),
				int(r.counters.get("at_fort", 0)), int(r.counters.get("dead_p", 0)), _n(g, r, "swarm"), _n(g, r, "mission"), r.tagged("relief_men").size(),
				r.tagged("hatch").size(), _hp(r, "fwd_mother"), r.fired.keys().filter(func(k): return String(k).begins_with("w")).size(),
				_left(g, r, "night"), _left(g, r, "hamlet"), _left(g, r, "column"), int(g.players[r.team_index("mission")]["gold"]), int(r.counters.get("fed", 0)),
				_where(g, r, "tomasz")])
	var idle: Dictionary = r.longest_idle()
	print("SIM end t=%d over=%s winner=%s flags=%s counters=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.counters, r.obj])
	print("SIM longest_idle %d s (from %d s)%s" % [int(idle.get("secs", 0.0)), int(idle.get("from", 0.0)), "" if float(idle.get("secs", 0.0)) < 45.0 else "  OVER 45 s"])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _hp(r: MissionRun, tag: String) -> String:
	var l: Array = r.tagged(tag)
	if l.is_empty():
		return "-"
	return "%d" % int(l[0].hp)


func _where(g: Game, r: MissionRun, tag: String) -> String:
	var l: Array = r.tagged(tag)
	return "-" if l.is_empty() else str(g.cell_of(l[0].position))


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
	var foe := _nearest_foe(g, t, u.position, reach * Defs.TILE)
	if foe:
		if u.target == null or not is_instance_valid(u.target) or u.target.dead:
			u.cmd_attack(foe)
	elif u.position.distance_to(p) > 2.5 * Defs.TILE:
		_go(g, u, p, true)


## The mission's player.
func _play_crown(g: Game, r: MissionRun) -> void:
	var mt := r.team_index("mission")
	var heroes: Array = r.tagged("tomasz") + r.tagged("tiago")
	var men: Array = g.units.filter(func(u): return not u.dead and u.team == mt and u.kind != "horse" and not heroes.has(u))
	var tz: Array = r.tagged("tomasz")
	if not r.fired.has("part2"):
		# PART 1: one soldier to each field (two to the west, where the first wave comes), the rest on the bluff
		var fields_out := {"field_w": "folk_w", "field_n": "folk_n", "field_r": "folk_r"}
		var sent := {}
		for u in men:
			if _job.has(u):
				sent[_job[u]] = int(sent.get(_job[u], 0)) + 1
		for fa in fields_out:
			var want := 2
			while int(sent.get(fa, 0)) < want:
				var free: Array = men.filter(func(u): return not _job.has(u))
				if free.is_empty():
					break
				_job[free[0]] = fa
				sent[fa] = int(sent.get(fa, 0)) + 1
		for u in men:
			var j: String = String(_job.get(u, ""))
			if j != "" and r.tagged(fields_out[j]).any(func(p): return not r.area_rect("church_yard").has_point(p.position)):
				# escort the field's people in: stand by the last of them
				var last: Unit = null
				for p in r.tagged(fields_out[j]):
					if not r.area_rect("church_yard").has_point(p.position) and (last == null or p.position.distance_to(_mid(r, "church_yard")) > last.position.distance_to(_mid(r, "church_yard"))):
						last = p
				_fight_or_go(g, u, mt, last.position if last else _mid(r, j), 6.0)
			else:
				_fight_or_go(g, u, mt, _mid(r, "bluff_s"), 8.0)
		return
	if not r.fired.has("part3"):
		# PART 2: the relief and four militia ride to the hamlet; the Charge drilled; the rest hold the churchyard
		if not g.has_tech(mt, "charge") and not g.researching(mt, "charge"):
			for b in r.tagged("breeder"):
				g.start_research(b, "charge")
		var hamlet_party: Array = men.filter(func(u): return r.tagged("relief_men").has(u))
		var militia: Array = men.filter(func(u): return not r.tagged("relief_men").has(u))
		hamlet_party += militia.slice(0, 4)
		for u in men:
			if hamlet_party.has(u):
				var goal := _mid(r, "hamlet") if not r.fired.has("hamlet_free") else _mid(r, "causeway")
				if r.fired.has("hamlet_free"):
					# walk back beside the hamlet's people
					var hf: Array = r.tagged("hamlet_folk").filter(func(p): return not r.area_rect("church_yard").has_point(p.position))
					if not hf.is_empty():
						goal = hf[0].position
					else:
						goal = _mid(r, "church_yard")
				_fight_or_go(g, u, mt, goal, 7.0)
			else:
				_fight_or_go(g, u, mt, _mid(r, "church_yard"), 9.0)
		return
	# PART 3: Tomasz walks the trail a little ahead of the people; the soldiers round the column
	if tz.is_empty():
		return
	var t0: Unit = tz[0]
	var ppl: Array = r.tagged("people")
	var back := t0.position
	if not ppl.is_empty():
		var sum := Vector2.ZERO
		for p in ppl:
			sum += p.position
		back = sum / float(ppl.size())
	if _wp < TRAIL.size() and t0.position.distance_to(_mid(r, TRAIL[_wp])) < 2.0 * Defs.TILE:
		_wp += 1
	var wp: Vector2 = _mid(r, TRAIL[mini(_wp, TRAIL.size() - 1)])
	# (wait for the people when they fall behind: 7 tiles)
	if t0.position.distance_to(back) < 7.0 * Defs.TILE or _wp >= TRAIL.size() - 1:
		_go(g, t0, wp)
	elif t0.velocity.length() > 5.0:
		t0.cmd_stop()
	var i := 0
	for u in men:
		var off := Vector2(cos(i * 1.3), sin(i * 1.3)) * (2.0 + float(i % 3)) * Defs.TILE
		_fight_or_go(g, u, mt, back.lerp(t0.position, 0.4) + off, 8.0)
		i += 1
	for ti in r.tagged("tiago"):
		_go(g, ti, back)


func _mid(r: MissionRun, area: String) -> Vector2:
	return r.area_rect(area).get_center()


## The swarm's player: Raptors laid, the pack at the fields at night, the bluff, then the column.
func _play_swarm(g: Game, r: MissionRun) -> void:
	var st := r.team_index("swarm")
	var mom: Array = r.tagged("fwd_mother")
	if mom.is_empty():
		return
	var q: Unit = mom[0]
	if int(g.players[st]["gold"]) >= 160:
		BroodNew.lay(g, q, "raptor")
	var pack: Array = g.units.filter(func(u): return not u.dead and u.team == st and u != q and not (u.kind in BroodNew.ROOTERS) and u.has_attack())
	var prey: Array = r.tagged("people").filter(func(p): return not p.untouchable())
	for u in pack:
		if u.target != null and is_instance_valid(u.target) and not u.target.dead:
			continue
		var best: Unit = null
		for p in prey:
			if best == null or p.position.distance_to(u.position) < best.position.distance_to(u.position):
				best = p
		if best and pack.size() >= 6:
			u.cmd_attack(best)
		elif u.position.distance_to(_mid(r, "mud_bank")) > 6.0 * Defs.TILE and pack.size() < 6:
			_go(g, u, _mid(r, "mud_bank"))


## CHECK THE FEEL: pictures of each part, the camera on what matters then (docs/shots/d05_aldeia/).
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(id: String, after: float) -> bool: return r.fired.has(id) and g.clock > float(r.fired.get(id, 0)) + after
	var want := {"start": g.clock > 3.0, "field": f.call("call_field_w", 3.0), "wave1": f.call("w1", 6.0), "push": f.call("w_push", 8.0),
		"relief": f.call("part2", 3.0), "hatch": f.call("hatch", 4.0), "hamlet": f.call("hamlet_free", 2.0), "flank": f.call("w_flank", 5.0),
		"part3": f.call("part3", 6.0), "mother": f.call("fwd_root", 3.0), "road": f.call("w_road_1", 6.0), "choice": f.call("fields_ask", 2.0),
		"burn": r.flags.get("fields", "") == "burned" and f.call("fields_ask", 30.0), "fort": f.call("fort_first", 2.0), "end": f.call("road_done", 1.0)}
	for k in want:
		if not want[k] or _shot_done.has(k):
			continue
		_shot_done[k] = true
		var at := Vector2.INF
		match k:
			"start", "push":
				at = _mid(r, "church_yard")
			"field", "wave1":
				at = _mid(r, "field_w")
			"relief":
				at = _mid(r, "relief_in")
			"hatch":
				var hs: Array = r.tagged("hatch")
				at = hs[0].position if not hs.is_empty() else _mid(r, "village")
			"hamlet", "flank":
				at = _mid(r, "hamlet") + Vector2(6 * Defs.TILE, -4 * Defs.TILE)
			"mother":
				at = _mid(r, "mud_bank")
			"burn":
				at = _mid(r, "granary")
			"part3", "road", "choice", "fort", "end":
				var tz: Array = r.tagged("tomasz")
				at = tz[0].position if not tz.is_empty() else _mid(r, "trail_3")
		if at == Vector2.INF:
			at = _mid(r, "village")
		g.camera.position = at
		for i in 4:
			await process_frame
		var img := root.get_viewport().get_texture().get_image()
		_shot_n += 1
		img.save_jpg("%s/%d_%s_%s.jpg" % [shots, _shot_n, side, k], 0.85)
		print("SIM shot %s" % k)
