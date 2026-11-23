extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 2's "The Island" (docs/campaign_d03_build.md) from either side with a simple bot and prints, every 30
## seconds, how it goes: the part, the young in the deep forest, loose, found, the commission's men, the clocks. A
## balance check (the owner's three rules: NO WAITING is measured): the stock's player who plays it walks the stock into
## the deep forest under the lures, roots the Mother and the Storm Sire, lays Hatchlings, gives the dinner and a decoy,
## keeps still, and brings the restless one back: it keeps the stock until dawn at EASY, NORMAL and HARD; a player who
## does nothing loses (the stock found in the old pens); the commission's player who plays it destroys half the stock.
## At the end: the mission's longest stretch with nothing to do (target under 45 s).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_d03.gd -- [active] [side=stock|commission]
##        [diff=easy|normal|hard] [clutch=saved|burned] [eggs=left|taken] [cages=few|some|all] [pieter=alive|lost]
##        [map=drawn|withheld] [varenne=spared|executed] [lazy] [none] [until=<s>] [save_at=<s>] [shots=<dir>] [debug]
##   lazy: an active player who never brings the restless one back (the night's loss)
## The earlier missions' flags are written into the progress file for the run (and the player's own progress put back).
var main: Node
var until := 1800.0
var active := false
var lazy := false
var side := "stock"
var diff := "normal"
var b01 := {"clutch": "saved", "eggs": "left", "pieter": "alive", "rival": "standing", "teles": "quiet", "saved": "some"}
var a03 := {"map": "drawn", "party": "some", "survey": "full", "linnea": "seen"}
var a05 := {"cages": "some", "cages_n": 2, "eggs": "taken", "pieter": "alive", "way": "short", "crates": "seen"}
var a06 := {"varenne": "spared", "paris": "stood"}
var no_flags := false
var _saved_progress := ""
var shots := ""
var _shot_n := 0
var _shot_done := {}
var _groups := {}          # lure unit -> [creatures]
var _target := {}          # lure unit -> pen area
var _home := {}            # creature -> its spot in its pen
var _stage := 0
var _seen_found := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a == "lazy":
			lazy = true
		elif a.begins_with("shots="):
			shots = a.substr(6)
		elif a == "none":
			no_flags = true
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("side="):
			side = a.substr(5)
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.begins_with("clutch="):
			b01["clutch"] = a.substr(7)
		elif a.begins_with("eggs="):
			b01["eggs"] = a.substr(5)
		elif a.begins_with("pieter="):
			b01["pieter"] = a.substr(7)
			a05["pieter"] = a.substr(7)
		elif a.begins_with("cages="):
			a05["cages"] = a.substr(6)
		elif a.begins_with("map="):
			a03["map"] = a.substr(4)
		elif a.begins_with("varenne="):
			a06["varenne"] = a.substr(8)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["d03_fazenda"], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if not no_flags:
		p["done"]["b01_specimen"] = {"won_by": "sire", "side": "sire", "flags": b01}
		p["done"]["a03_plateau"] = {"won_by": "party", "side": "party", "flags": a03}
		p["done"]["a05_specimens"] = {"won_by": "expedition", "side": "expedition", "flags": a05}
		p["done"]["a06_barricades"] = {"won_by": "crown", "side": "crown", "flags": a06}
	p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var probs := Campaign.problems(Campaign.mission("d03_fazenda"))
	if not probs.is_empty():
		print("SIM PROBLEMS ", probs)
	main.start(Campaign.make_cfg("d03_fazenda", "solo", "p1", false, side))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	print("SIM side=%s diff=%s b01=%s a03=%s a05=%s a06=%s active=%s human=%d" % [side, diff, "none" if no_flags else str(b01), str(a03), str(a05), str(a06), active, g.human])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
			_groups = {}
		if shots != "":
			await _shots(g, r)
		if OS.get_cmdline_user_args().has("debug") and r.fired.has("part2"):
			for u in r.tagged("young"):
				if _alive(u) and not r.a2.is_hidden(u) and not _seen_found.has(u):
					_seen_found[u] = true
					var bd := INF
					var bu: Unit = null
					for e in g.units:
						if not e.dead and e.team == r.team_index("commission") and e.position.distance_to(u.position) < bd:
							bd = e.position.distance_to(u.position)
							bu = e
					print("  FOUND t=%d %s at %s vel=%d order=%s nearest %s at %.1f tiles target=%s" % [g.clock, u.kind, str(g.cell_of(u.position)), int(u.velocity.length()), u.order, bu.kind if bu else "-", bd / Defs.TILE, str(u.target.kind) if u.target and is_instance_valid(u.target) else "-"])
		if active and g.clock >= think:
			think = g.clock + 0.75
			if side == "commission":
				_play_commission(g, r)
			else:
				_play_stock(g, r)
		if g.clock >= next:
			next += 30.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			var st := r.team_index("stock")
			var ct := r.team_index("commission")
			print("SIM t=%4d part=%s young=%d deep=%d loose=%d found=%d destroyed=%d hatch=%d mother_rooted=%s storm_rooted=%s com=%d boat=%s dusk=%s dawn=%s restless=%s gold=%d" % [
				g.clock, part, int(r.counters.get("young_n", 0)), int(r.counters.get("deep", 0)), r.a2.loose_count("", ""),
				int(r.counters.get("found", 0)), int(r.counters.get("destroyed", 0)),
				g.units.filter(func(u): return not u.dead and u.team == st and u.kind == "hatchlings").size(),
				str(r.cond({"rooted": {"tag": "mother"}})), str(r.cond({"rooted": {"tag": "storm_sire"}})),
				g.units.filter(func(u): return not u.dead and u.team == ct).size(),
				_left(g, r, "boat"), _left(g, r, "dusk"), _left(g, r, "dawn"),
				str(r.tagged("restless").map(func(u): return str(g.cell_of(u.position)))), int(g.players[st]["gold"])])
			if OS.get_cmdline_user_args().has("debug"):
				for u in r.tagged("young") + r.tagged("lindqvist") + r.tagged("keeper"):
					if _alive(u):
						if u.kind == "brood_mother" or u.kind == "pterodactyl":
							print("   place: ", BroodRoot.place_problem(g, u.team, u.kind, u.position if u.kind == "brood_mother" else u.position, u, false, BroodRoot.scale_of(u)))
						print("  %s %s order=%s rooted=%s loose=%s hidden=%s low=%s sp=%s" % [u.kind, str(g.cell_of(u.position)), u.order, BroodNew.rooted(u) if u.kind in BroodNew.ROOTERS else "-", u.has_meta("leash_loose"), r.a2.is_hidden(u), r.a2.lies_low(u), str(int(u.velocity.length()))])
	var idle: Dictionary = r.longest_idle()
	print("SIM end t=%d over=%s winner=%s flags=%s counters=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.counters, r.obj])
	print("SIM longest_idle %d s (from %d s)%s" % [int(idle.get("secs", 0.0)), int(idle.get("from", 0.0)), "" if float(idle.get("secs", 0.0)) < 45.0 else "  OVER 45 s"])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _left(g: Game, r: MissionRun, cn: String) -> String:
	return "%ds" % int(float(r.clocks[cn]) - g.clock) if r.clocks.has(cn) else "-"


func _go(g: Game, u: Unit, p: Vector2, attack := false) -> void:
	if u.velocity.length() < 5.0 or u.order_point.distance_to(p) > 48.0:
		g.group_move([u], p, attack)


func _alive(u) -> bool:
	return u != null and is_instance_valid(u) and not u.dead


## The stock's groups: each lure (a keeper, Lindqvist) leads its share of the young to its pen; Lindqvist takes the
## Mother (and the Storm Sire) to the nest; Pieter is kept free for the decoy.
func _make_groups(g: Game, r: MissionRun) -> void:
	_groups = {}
	_target = {}
	var lures: Array = r.tagged("keeper").filter(func(u): return _alive(u))
	var lq: Array = r.tagged("lindqvist")
	var pens := ["pen_5", "pen_2", "pen_3", "pen_4", "pen_1"]
	for i in lures.size():
		_groups[lures[i]] = []
		_target[lures[i]] = pens[i % pens.size()]
	if not lq.is_empty():
		_groups[lq[0]] = r.tagged("mother").duplicate()
		_target[lq[0]] = "nest"
	var young: Array = r.tagged("young").filter(func(u): return _alive(u) and u.kind != "brood_mother" and u.kind != "pterodactyl")
	var i := 0
	for u in young:
		if lures.is_empty():
			_groups[lq[0]].append(u)
		else:
			_groups[lures[i % lures.size()]].append(u)
		i += 1


func _spot(r: MissionRun, u: Unit, pen: String, k: int) -> Vector2:
	if not _home.has(u):
		var c := r.area_rect(pen).get_center()
		var a := float(k) * 2.1 + 0.5
		_home[u] = c + Vector2(cos(a), sin(a) * 0.7) * (4.3 + 0.8 * float(k % 2)) * Defs.TILE
	return _home[u]


func _play_stock(g: Game, r: MissionRun) -> void:
	if _groups.is_empty():
		_make_groups(g, r)
	var st := r.team_index("stock")
	var storm: Array = r.tagged("storm_sire").filter(func(u): return _alive(u))
	var lq: Array = r.tagged("lindqvist")
	var mother: Array = r.tagged("mother").filter(func(u): return _alive(u))
	if not storm.is_empty() and not lq.is_empty() and not (_groups[lq[0]] as Array).has(storm[0]):
		_groups[lq[0]].append(storm[0])
	# PART 3: the restless one
	var rest: Array = r.tagged("restless").filter(func(u): return _alive(u))
	if r.fired.has("restless") and not r.fired.has("restless_back") and not rest.is_empty() and not lazy:
		var ru: Unit = rest[0]
		var best: Unit = null
		for l in _groups:
			if _alive(l) and (best == null or l.position.distance_to(ru.position) < best.position.distance_to(ru.position)):
				best = l
		if best:
			if best.position.distance_to(ru.position) > 2.0 * Defs.TILE and not r.fired.has("restless_held"):
				_go(g, best, ru.position)
			elif r.fired.has("restless_held"):
				var to := r.area_rect(String(_target.get(best, "pen_5"))).get_center()
				if best.position.distance_to(ru.position) > 2.0 * Defs.TILE:
					_go(g, best, ru.position)
				else:
					_go(g, best, to)
					_go(g, ru, best.position)
			return
	var in2 := r.fired.has("part2")
	for l in _groups:
		if not _alive(l):
			continue
		var pen := String(_target[l])
		var at := r.area_rect(pen).get_center()
		var grp: Array = (_groups[l] as Array).filter(func(u): return _alive(u))
		# (Lindqvist's errand: the dinner, once his Mother is rooted)
		if l == (lq[0] if not lq.is_empty() else null) and r.obj.get("dinner", "") == "active" and not mother.is_empty() and BroodNew.rooted(mother[0]) \
				and (storm.is_empty() or BroodNew.rooted(storm[0])):
			_go(g, l, r.area_rect("house_door").get_center())
			continue
		if l == (lq[0] if not lq.is_empty() else null) and r.fired.has("dinner") and l.position.distance_to(at) > 3.0 * Defs.TILE:
			_go(g, l, at)
			continue
		var behind := false
		for u in grp:
			if u.position.distance_to(l.position) > 5.0 * Defs.TILE and not BroodNew.rooted(u):
				behind = true
		var there: bool = l.position.distance_to(at) < 2.5 * Defs.TILE
		if not there and not behind:
			_go(g, l, at)
		elif behind and l.velocity.length() > 5.0:
			l.cmd_stop()
		var k := 0
		for u in grp:
			k += 1
			if u.kind == "brood_mother":
				if there and not BroodNew.rooted(u) and u.order != "nb_root" and u.position.distance_to(at) < 4.0 * Defs.TILE:
					BroodRoot.start_root(u, at + Vector2(0, -24))
				elif not BroodNew.rooted(u) and u.order != "nb_root" and u.position.distance_to(l.position) > 2.0 * Defs.TILE:
					_go(g, u, l.position)
				continue
			if u.kind == "pterodactyl":
				if not BroodNew.rooted(u) and u.order != "nb_root" and not mother.is_empty() and BroodNew.rooted(mother[0]):
					for off in [Vector2(130, 0), Vector2(-130, 0), Vector2(0, 110), Vector2(0, -110), Vector2(160, 60), Vector2(-160, 60), Vector2(110, -90)]:
						var pp: Vector2 = mother[0].position + off
						if BroodRoot.place_problem(g, u.team, u.kind, pp, u, false, BroodRoot.scale_of(u)) == "":
							BroodRoot.start_root(u, pp)
							break
				elif not BroodNew.rooted(u) and u.order != "nb_root" and u.position.distance_to(l.position) > 2.0 * Defs.TILE:
					_go(g, u, l.position)
				continue
			if there:
				var sp := _spot(r, u, pen, k)
				if u.position.distance_to(sp) > 1.0 * Defs.TILE and not (in2 and u.velocity.length() < 5.0 and u.position.distance_to(at) < 5.0 * Defs.TILE):
					_go(g, u, sp)
			elif u.position.distance_to(l.position) > 2.0 * Defs.TILE:
				_go(g, u, l.position)
	# the Hatchlings: laid as soon as she can; then they fly over the forest
	if not mother.is_empty() and r.obj.get("storm", "") == "active":
		BroodNew.lay(g, mother[0], "hatchlings")
	# Pieter: the decoy at the chapel
	var pt: Array = r.tagged("pieter").filter(func(u): return _alive(u))
	if not pt.is_empty() and r.obj.get("decoy", "") == "active":
		_go(g, pt[0], r.area_rect("chapel").get_center())


## The commission's player: the three parties walk the deep pens in turn; Valadares and the riders with the middle one;
## whatever is found and awake is shot.
func _play_commission(g: Game, r: MissionRun) -> void:
	var ct := r.team_index("commission")
	var men: Array = g.units.filter(func(u): return not u.dead and u.team == ct and u.has_attack())
	if men.is_empty():
		return
	var pens := ["pen_5", "pen_1", "pen_2", "pen_6", "pen_3", "pen_4"]
	_stage = int(g.clock / 40.0)
	var i := 0
	for u in men:
		var grp := i % 3
		i += 1
		var pen: String = pens[(_stage + grp * 2) % pens.size()]
		var target: Unit = null
		for e in g.units:
			if e.dead or e.team == ct or not g.hostile(e.team, ct) or e.untouchable() or e.kind == "horse":
				continue
			if e.position.distance_to(u.position) < 9.0 * Defs.TILE:
				target = e
				break
		if target and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
			u.cmd_attack(target)
		elif target == null:
			_go(g, u, r.area_rect(pen).get_center(), true)


## CHECK THE FEEL: pictures of each part, the camera on what matters then (docs/shots/d03_fazenda/).
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(id: String, after: float) -> bool: return r.fired.has(id) and g.clock > float(r.fired.get(id, 0)) + after
	var want := {"start": g.clock > 3.0, "walk": g.clock > 35.0, "storm": f.call("storm_hatch", 4.0), "rooted": f.call("mother_rooted", 3.0),
		"hatchlings": f.call("hatched", 6.0), "landing": f.call("part2", 10.0), "search": f.call("part2", 70.0), "found": f.call("found_1", 0.5),
		"dinner": f.call("dinner", 12.0), "decoy": f.call("decoy_chapel", 6.0) or f.call("decoy_west", 6.0), "night": f.call("part3", 25.0),
		"restless": f.call("restless_went", 6.0), "held": f.call("restless_held", 3.0), "dawn": f.call("dawn_go", 6.0)}
	for k in want:
		if not want[k] or _shot_done.has(k):
			continue
		_shot_done[k] = true
		var at := Vector2.INF
		match k:
			"start", "walk", "dinner":
				var lq: Array = r.tagged("lindqvist")
				if not lq.is_empty():
					at = lq[0].position
			"storm", "rooted", "hatchlings":
				var m: Array = r.tagged("mother")
				if not m.is_empty():
					at = m[0].position
			"landing", "dawn":
				at = r.area_rect("landing").get_center()
			"search", "found":
				var v: Array = r.tagged("valadares")
				if not v.is_empty():
					at = v[0].position
			"decoy":
				at = r.area_rect("chapel").get_center()
			"night", "restless", "held":
				var rs: Array = r.tagged("restless")
				if not rs.is_empty():
					at = rs[0].position
		if at == Vector2.INF:
			at = r.area_rect("house").get_center()
		g.camera.position = at
		for i in 4:
			await process_frame
		var img := root.get_viewport().get_texture().get_image()
		_shot_n += 1
		img.save_jpg("%s/%d_%s_%s.jpg" % [shots, _shot_n, side, k], 0.85)
		print("SIM shot %s" % k)
