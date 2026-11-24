extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 2's "The Queen" (docs/campaign_d06_build.md) from either side with a simple bot and prints, every 30
## seconds, how it goes: the part, the young in the big pen, loose ones, the Mothers' health, the creatures on each side,
## the clocks. A balance check (the owner's three rules: NO WAITING is measured): the Brood's player who plays it walks
## the young up with the keepers, keeps the army round its Mother while the other Mothers come, kills them, roots and
## GROWS the Mother into the Queen, lays Brutes and breaks the fazenda: it wins at EASY, NORMAL and HARD; a player who
## does nothing loses (the Mother killed in the fight); the fazenda's player who plays it burns the pens and gets
## Lindqvist out (or not).
## At the end: the mission's longest stretch with nothing to do (target under 45 s).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_d06.gd -- [active] [side=brood|fazenda]
##        [diff=easy|normal|hard] [hidden=few|some|all] [clutch=saved|burned] [rival=standing|driven]
##        [pieter=alive|lost] [varenne=spared|executed] [cages=some|all] [lazy] [until=<s>] [save_at=<s>] [shots=<dir>]
##   lazy: an active player who leaves the young in the flooded pens (Part 1 not done: they turn to the wild Mother)
## The earlier missions' flags are written into the progress file for the run (and the player's own progress put back).
var main: Node
var until := 1500.0
var active := false
var lazy := false
var side := "brood"
var diff := "normal"
var b01 := {"clutch": "saved", "eggs": "left", "pieter": "alive", "rival": "standing", "teles": "quiet", "saved": "some"}
var a05 := {"cages": "some", "cages_n": 2, "eggs": "taken", "pieter": "alive", "way": "short", "crates": "seen"}
var a06 := {"varenne": "spared", "paris": "stood"}
var d03 := {"hidden": "some", "hidden_n": 4, "storm": "hatched", "mother": "linnea", "pieter": "alive", "dinner": "given"}
var _saved_progress := ""
var shots := ""
var _shot_n := 0
var _shot_done := {}
var _spot := {}


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
		elif a.begins_with("hidden="):
			d03["hidden"] = a.substr(7)
		elif a.begins_with("clutch="):
			b01["clutch"] = a.substr(7)
		elif a.begins_with("rival="):
			b01["rival"] = a.substr(6)
		elif a.begins_with("pieter="):
			d03["pieter"] = a.substr(7)
		elif a.begins_with("varenne="):
			a06["varenne"] = a.substr(8)
		elif a.begins_with("cages="):
			a05["cages"] = a.substr(6)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["d06_queen"], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	p["done"]["b01_specimen"] = {"won_by": "sire", "side": "sire", "flags": b01}
	p["done"]["a05_specimens"] = {"won_by": "expedition", "side": "expedition", "flags": a05}
	p["done"]["a06_barricades"] = {"won_by": "crown", "side": "crown", "flags": a06}
	p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}}
	p["done"]["d03_fazenda"] = {"won_by": "stock", "side": "stock", "flags": d03}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var probs := Campaign.problems(Campaign.mission("d06_queen"))
	if not probs.is_empty():
		print("SIM PROBLEMS ", probs)
	main.start(Campaign.make_cfg("d06_queen", "solo", "p1", false, side))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	print("SIM side=%s diff=%s d03=%s b01=%s a06=%s active=%s lazy=%s human=%d" % [side, diff, str(d03), str(b01), str(a06), active, lazy, g.human])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
			_spot = {}
		if shots != "":
			await _shots(g, r)
		if OS.get_cmdline_user_args().has("debug") and r.fired.has("part2") and not _spot.has("dbg"):
			_spot["dbg"] = true
			print("SIM DEBUG fired ", r.fired)
			for u in r.tagged("young"):
				print("  young ", u.kind, " ", g.cell_of(u.position), " in big_pen=", r.area_rect("big_pen").has_point(u.position))
		if OS.get_cmdline_user_args().has("debug") and int(g.clock) % 15 == 0 and not _spot.has("d%d" % int(g.clock)):
			_spot["d%d" % int(g.clock)] = true
			for tg in ["pen_mother", "pen_pack", "wild_mother"]:
				for u in r.tagged(tg):
					print("  t=%d %s %s %s order=%s team=%d stun=%s caged=%s asleep=%s pace=%.2f" % [g.clock, tg, u.kind, g.cell_of(u.position), u.order, u.team, u.stunned if "stunned" in u else "?", u.has_meta("held"), u.has_meta("asleep"), u.m_pace])
		if active and g.clock >= think:
			think = g.clock + 0.75
			if side == "fazenda":
				_play_fazenda(g, r)
			else:
				_play_brood(g, r)
		if g.clock >= next:
			next += float(OS.get_environment("SIMSTEP")) if OS.get_environment("SIMSTEP") != "" else 30.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else ("3" if not r.fired.has("queen") else "Q"))
			print("SIM t=%4d part=%s young=%d in_pen=%d loose=%d broke=%d joined=%d down=%d M=%s W=%s E=%s stock=%d wild=%d pens=%d faz=%d walls=%d house=%s burned=%d fled=%d/%d flood=%s queen=%s gold=%d" % [
				g.clock, part, int(r.counters.get("young_n", 0)), int(r.counters.get("in_pen", 0)), r.a2.loose_count("", ""),
				int(r.counters.get("lost_n", 0)), int(r.counters.get("joined", 0)), int(r.counters.get("mothers_down", 0)),
				_hp(r, "mother"), _hp(r, "wild_mother"), _hp(r, "pen_mother"),
				_n(g, r, "stock"), _n(g, r, "wild"), _n(g, r, "pens"), _n(g, r, "fazenda"),
				r.tagged("palisade").size(), _hp(r, "big_house"), int(r.counters.get("burned", 0)),
				int(r.counters.get("fled_l", 0)), int(r.counters.get("fled_p", 0)), _left(g, r, "flood"), _left(g, r, "queen"),
				int(g.players[r.team_index("stock")]["gold"])])
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
	var e = l[0]
	var st := ""
	if e is Unit and e.kind == "brood_mother":
		st = "s%d%s" % [BroodNew.stage(e) + 1, "R" if BroodNew.rooted(e) else ""]
	return "%d%s" % [int(e.hp), st]


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


func _nearest_foe(g: Game, t: int, p: Vector2, reach: float, buildings := false) -> Entity:
	var best: Entity = null
	var bd := reach
	for e in g.units:
		if e.dead or e.off_field or not g.hostile(e.team, t) or e.untouchable() or e.kind == "horse":
			continue
		var d: float = e.position.distance_to(p)
		if d < bd:
			bd = d
			best = e
	if buildings:
		for b in g.buildings:
			if b.dead or b.ghost or not g.hostile(b.team, t) or b.untouchable():
				continue
			var d2: float = b.center().distance_to(p)
			if d2 < bd:
				bd = d2
				best = b
	return best


## The Brood's player.
func _play_brood(g: Game, r: MissionRun) -> void:
	var st := r.team_index("stock")
	var mom: Array = r.tagged("mother")
	if mom.is_empty():
		return
	var q: Unit = mom[0]
	var army: Array = g.units.filter(func(u): return not u.dead and u.team == st and u != q and not (u.kind in BroodNew.ROOTERS) and u.has_attack())
	if not r.fired.has("part2"):
		# PART 1: each young walks after the nearest keeper (inside his ring), and into the big pen once he is there
		if lazy:
			return
		var pen := r.area_rect("big_pen")
		for u in r.tagged("young"):
			if not _alive(u):
				continue
			if pen.has_point(u.position):
				continue
			var best: Unit = null
			for k in r.tagged("lure"):
				if _alive(k) and (best == null or k.position.distance_to(u.position) < best.position.distance_to(u.position)):
					best = k
			if best == null:
				continue
			if pen.grow(-32).has_point(best.position):
				_go(g, u, pen.get_center() + Vector2(float(u.get_instance_id() % 7) * 20.0 - 60.0, float(u.get_instance_id() % 5) * 16.0 - 32.0))
			elif best.position.distance_to(u.position) > 1.5 * Defs.TILE:
				_go(g, u, best.position)
		return
	# the Tyrant Sire rooted beside her again if he got up (his line: Raptors, and at her third stage the Brutes)
	for sire in r.tagged("tyrant_sire"):
		if r.fired.has("part3") and not BroodNew.rooted(sire) and sire.order != "nb_root" and BroodNew.rooted(q):
			for off in [Vector2(-180, -60), Vector2(180, 60), Vector2(0, 150), Vector2(-150, 90), Vector2(150, -90), Vector2(0, -160)]:
				var pp: Vector2 = q.position + off
				if BroodRoot.place_problem(g, sire.team, sire.kind, pp, sire, false, BroodRoot.scale_of(sire)) == "":
					BroodRoot.start_root(sire, pp)
					break
	# THE QUEEN: grow her once she is rooted in the big pen
	if r.fired.has("part3") and not r.fired.has("queen"):
		if BroodNew.rooted(q):
			BroodNew.grow(g, q)
		elif q.order != "nb_root":
			BroodRoot.start_root(q, q.position if r.area_rect("big_pen").has_point(q.position) else r.area_rect("mother_spot").get_center())
	if r.fired.has("fall"):
		var why := BroodNew.lay(g, q, "brute")
		if OS.get_cmdline_user_args().has("debug") and why != "" and int(g.clock) % 10 == 0:
			print("  brute: ", why, " sires=", r.tagged("tyrant_sire").map(func(u): return "%s %s" % [g.cell_of(u.position), BroodNew.rooted(u)]))
		if army.size() < 30:
			BroodNew.lay(g, q, "raptor")
		# THE FALL: the Brutes at the west gate of the palisade, the rest after them on to the house
		var house: Array = r.tagged("big_house")
		var gate := r.area_rect("house").get_center() + Vector2(-9.5 * Defs.TILE, 0)
		var wall: Entity = null
		for w in r.tagged("palisade"):
			if wall == null or w.center().distance_to(gate) < wall.center().distance_to(gate):
				wall = w
		var breached: bool = r.fired.has("breach")
		var ready: bool = army.filter(func(u): return u.kind == "brute").size() >= 2 or g.clock > float(r.fired.get("fall", 0)) + 70.0
		for u in army:
			if u.target != null and is_instance_valid(u.target) and not u.target.dead:
				continue
			var foe := _nearest_foe(g, st, u.position, 5.0 * Defs.TILE)
			if foe:
				u.cmd_attack(foe)
			elif not ready:
				_go(g, u, gate + Vector2(-7.0 * Defs.TILE, 0))       # (wait for the Brutes out of the guns' reach)
			elif not breached and wall:
				u.cmd_attack(wall)
			else:
				_go(g, u, (house[0].center() if not house.is_empty() else gate), true)
		return
	# PART 2 / 3: the army keeps round her (her ring) and fights what comes in; the rival Mothers when near
	var foe_m: Entity = null
	for m in r.tagged("rival_mother"):
		if _alive(m) and m.position.distance_to(q.position) < 15.0 * Defs.TILE:
			foe_m = m
	# the Mothers fight: she gets up for a rival Mother near her, and goes back to root once it is over
	if foe_m and foe_m.position.distance_to(q.position) < 13.0 * Defs.TILE:
		if BroodNew.rooted(q):
			BroodNew.uproot(q, false)
		elif q.target != foe_m:
			q.cmd_attack(foe_m)
	elif not BroodNew.rooted(q) and q.order != "nb_root" and q.velocity.length() < 5.0 and not r.fired.has("part3"):
		BroodRoot.start_root(q, r.area_rect("mother_spot").get_center())
	for u in army:
		var foe := _nearest_foe(g, st, u.position, 9.0 * Defs.TILE)
		if foe_m and u.position.distance_to(q.position) < 11.0 * Defs.TILE:
			if u.target != foe_m:
				u.cmd_attack(foe_m)
		elif foe and foe.position.distance_to(q.position) < 11.0 * Defs.TILE:
			if u.target == null or not is_instance_valid(u.target) or u.target.dead:
				u.cmd_attack(foe)
		elif u.position.distance_to(q.position) > 6.0 * Defs.TILE:
			if not _spot.has(u):
				var a := float(_spot.size()) * 0.9
				_spot[u] = Vector2(cos(a), sin(a)) * (3.0 + float(_spot.size() % 3)) * Defs.TILE
			_go(g, u, q.position + _spot[u])
	# her eggs while the fight goes on
	if g.clock > float(r.fired.get("part2", 0)) + 5.0 and army.size() < 24:
		var why := BroodNew.lay(g, q, "raptor")
		if why != "" and OS.get_cmdline_user_args().has("debug") and int(g.clock) % 10 == 0:
			print("  raptor: ", why)


## The fazenda's player: the men and the guns go together pen by pen (the north pen, the big pen, the east pen),
## shoot what wakes, stand in the pen to burn it; then Lindqvist and Pieter to the canoes.
func _play_fazenda(g: Game, r: MissionRun) -> void:
	var ft := r.team_index("fazenda")
	var men: Array = g.units.filter(func(u): return not u.dead and u.team == ft and u.kind != "horse")
	if men.is_empty() or not r.fired.has("part2_f"):
		return
	var order := ["pen_2", "burn_big", "pen_3"]
	var done := {"pen_2": r.flags.has("burned_north"), "burn_big": r.flags.has("burned_big"), "pen_3": r.flags.has("burned_east")}
	var target := ""
	for a in order:
		if not done[a]:
			target = a
			break
	if target == "":
		for u in men:
			_go(g, u, r.area_rect("canoes").get_center())
		return
	var at := r.area_rect(target).get_center()
	for u in men:
		var foe := _nearest_foe(g, ft, u.position, (13.0 if u.kind == "cannon" else 7.0) * Defs.TILE)
		if foe and not (foe is Unit and foe.kind == "brood_mother"):
			if u.target == null or not is_instance_valid(u.target) or u.target.dead:
				u.cmd_attack(foe)
		else:
			_go(g, u, at + (Vector2(0, 3.0 * Defs.TILE) if u.kind == "cannon" else Vector2.ZERO))


## CHECK THE FEEL: pictures of each part, the camera on what matters then (docs/shots/d06_queen/).
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(id: String, after: float) -> bool: return r.fired.has(id) and g.clock > float(r.fired.get(id, 0)) + after
	var want := {"start": g.clock > 3.0, "walk": g.clock > 40.0, "call": f.call("call", 4.0), "in_pen": f.call("all_in", 1.0),
		"wild": f.call("part2", 6.0), "east": f.call("east_go", 5.0), "fight": f.call("fight_say", 3.0), "lost": f.call("lost_say", 1.0),
		"down": f.call("wild_down", 2.0), "joined": f.call("joined_say", 2.0), "part3": f.call("part3", 4.0),
		"queen": f.call("queen", 1.0), "fall": f.call("fall", 20.0), "breach": f.call("breach", 2.0), "run": f.call("run_go", 6.0),
		"house": f.call("house_down", 1.0), "f_burn": f.call("burn_big", 1.0) or f.call("burn_north", 1.0)}
	for k in want:
		if not want[k] or _shot_done.has(k):
			continue
		_shot_done[k] = true
		var at := Vector2.INF
		match k:
			"start", "walk", "call":
				var kp: Array = r.tagged("keeper_w")
				if not kp.is_empty():
					at = kp[0].position
			"in_pen", "part3", "queen", "joined":
				at = r.area_rect("big_pen").get_center()
			"wild":
				at = r.area_rect("nw_shore").get_center()
			"east":
				at = r.area_rect("pen_3").get_center()
			"fight", "lost", "down":
				var m: Array = r.tagged("mother")
				if not m.is_empty():
					at = m[0].position
			"fall", "breach", "house":
				at = r.area_rect("house").get_center() + Vector2(-8 * Defs.TILE, 0)
			"run":
				at = r.area_rect("landing").get_center()
			"f_burn":
				at = r.area_rect("big_pen").get_center()
		if at == Vector2.INF:
			at = r.area_rect("big_pen").get_center()
		g.camera.position = at
		for i in 4:
			await process_frame
		var img := root.get_viewport().get_texture().get_image()
		_shot_n += 1
		img.save_jpg("%s/%d_%s_%s.jpg" % [shots, _shot_n, side, k], 0.85)
		print("SIM shot %s" % k)
