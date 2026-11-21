extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 1's "The Specimens" (docs/campaign_a05_build.md) from either side with a simple bot and prints, every 30
## seconds, how it goes: the part, the caged, the carts and their health, the freed, the loaded, the expedition's men,
## the raiders, the clocks. A balance check: the expedition's player who plays it wins on NORMAL in a sensible time; the
## creatures' player who plays it frees half the cages or kills the doctor; a player who does nothing loses (the
## expedition at dawn) or lets the cages get away (the creatures).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_a05.gd -- [active] [side=expedition|creatures]
##        [clutch=saved|burned] [saved=few|some|many] [pieter=alive|lost] [eggs=left|taken] [map=drawn|withheld]
##        [diff=easy|normal|hard] [until=<seconds>] [none]
## The prologue's and a03's flags are written into the progress file for the run (and the player's own progress put back after).
var main: Node
var until := 1500.0
var active := false
var side := "expedition"
var diff := "normal"
var b01 := {"teles": "quiet", "clutch": "saved", "eggs": "left", "saved": "some", "pieter": "lost", "turtle": "late", "rival": "standing"}
var a03 := {"map": "drawn", "party": "some", "survey": "full", "linnea": "seen"}
var no_flags := false
var _saved_progress := ""
var _bed := 0
var _beds: Array = []
var _eggs_done := false


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a == "none":
			no_flags = true
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("side="):
			side = a.substr(5)
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.contains("="):
			var kv := a.split("=")
			if b01.has(kv[0]):
				b01[kv[0]] = kv[1]
			elif a03.has(kv[0]):
				a03[kv[0]] = kv[1]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["a05_specimens"], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if not no_flags:
		p["done"]["b01_specimen"] = {"won_by": "sire", "side": "sire", "flags": b01}
		p["done"]["a03_plateau"] = {"won_by": "party", "side": "party", "flags": a03}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("a05_specimens", "solo", "p1", false, side))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	var et := r.team_index("expedition")
	var ct := r.team_index("creatures")
	print("SIM side=%s diff=%s b01=%s a03=%s active=%s human=%d" % [side, diff, "none" if no_flags else str(b01), "none" if no_flags else str(a03), active, g.human])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
		if active and g.clock >= think:
			think = g.clock + 0.75
			if side == "creatures":
				_play_creatures(g, r, et, ct)
			else:
				_play_expedition(g, r, et, ct)
		if g.clock >= next:
			next += 30.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			var lq: Array = r.tagged("lindqvist")
			var carts: Array = r.tagged("carts").map(func(c): return "%s:%d" % [str(g.cell_of(c.position)), int(c.hp)])
			print("SIM t=%4d part=%s caged=%d carts=%s freed=%d loaded=%d/%d men=%d raiders=%d sire=%s lindqvist=%s hp=%d asleep=%s dawn=%s canoes=%s" % [
				g.clock, part, int(r.counters.get("caged", 0)), str(carts), int(r.counters.get("freed", 0)), int(r.counters.get("cages", 0)),
				int(r.counters.get("room", 0)), _men(g, et).size(), r.tagged("raiders").size(),
				"yes" if not r.tagged("sire").is_empty() else "-",
				str(g.cell_of(lq[0].position)) if not lq.is_empty() else "DEAD", int(lq[0].hp) if not lq.is_empty() else 0,
				r.cond({"asleep": "nest"}), _left(g, r, "dawn"), _left(g, r, "canoes")])
	print("SIM end t=%d over=%s winner=%s flags=%s counters=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.counters, r.obj])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _left(g: Game, r: MissionRun, cn: String) -> String:
	return "%ds" % int(float(r.clocks[cn]) - g.clock) if r.clocks.has(cn) else "-"


func _men(g: Game, t: int) -> Array:
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind in ["musketeer", "labourer"])


func _nearest_foe(g: Game, p: Vector2, sides: Array, reach: float, r: MissionRun) -> Unit:
	var best: Unit = null
	var bd := reach
	for f in g.units:
		if f.dead or f.kind == "horse" or f.spared or f.has_meta("mission_asleep") or f.kind == "brood_egg" or not sides.has(r.side_of_team(f.team)):
			continue
		var d := p.distance_to(f.position)
		if d < bd:
			bd = d
			best = f
	return best


func _go(g: Game, u: Unit, p: Vector2) -> void:
	if u.velocity.length() < 5.0 or u.order_point.distance_to(p) > 48.0:
		g.group_move([u], p, false)


## The expedition's player: Lindqvist to the egg bed alone (the men wait at the camp: far from the nest), then the men
## to each bed of young in turn until it is caged; on the trail the guns keep round the carts and fight what comes at
## them, the porters mend a hurt cart, Lindqvist walks behind the carts; at the river he goes onto the quay once the
## carts are in (or the canoes are about to leave).
func _play_expedition(g: Game, r: MissionRun, et: int, ct: int) -> void:
	var lq: Array = r.tagged("lindqvist")
	if lq.is_empty():
		return
	var doc: Unit = lq[0]
	var guns: Array = r.tagged("guns")
	var porters: Array = r.tagged("porters") + r.tagged("pieter")
	if _beds.is_empty():
		for w in ["w", "m", "e"]:
			if not r.tagged("young_" + w).is_empty():
				_beds.append(w)
	if not r.fired.has("part2"):
		# PART 1
		if not r.fired.has("eggs_taken"):
			var bed := r.area_rect("egg_bed").get_center()
			if doc.position.distance_to(bed) > 40.0:
				_go(g, doc, bed)
		else:
			_go(g, doc, r.area_rect("camp").get_center())
		while _bed < _beds.size() and r.fired.has("load_" + String(_beds[_bed])):
			_bed += 1
		if _bed < _beds.size():
			var at := r.area_rect("young_" + String(_beds[_bed])).get_center()
			for u in guns.slice(0, 3):
				_go(g, u, at)
		return
	# PART 2 / 3: the carts
	var carts: Array = r.tagged("carts")
	var loaded_or_gone := carts.is_empty() or r.cond({"cargo": {"tag": "carts", "below": 1}})
	var i := 0
	for u in guns:
		if carts.is_empty():
			_go(g, u, r.area_rect("quay").get_center())
			continue
		var c: Unit = carts[i % carts.size()]
		i += 1
		var f := _nearest_foe(g, c.position, ["creatures"], 7.0 * Defs.TILE, r)
		if f and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
			u.cmd_attack(f)
		elif f == null and u.position.distance_to(c.position) > 3.0 * Defs.TILE:
			_go(g, u, c.position + Vector2(randf_range(-50, 50), randf_range(-50, 50)))
	for u in porters:
		var hurt: Unit = null
		for c in carts:
			if c.hp < c.max_hp * 0.8 and (hurt == null or c.hp < hurt.hp):
				hurt = c
		if hurt and u.kind == "labourer" and u.order != "repair":
			u.cmd_repair(hurt)
		elif hurt == null and not carts.is_empty() and u.position.distance_to(carts[0].position) > 3.0 * Defs.TILE:
			_go(g, u, carts[0].position)
	var quay := r.area_rect("quay").get_center()
	if r.fired.has("part3") and (loaded_or_gone or r.fired.has("room_full") or r.cond({"clock_left": {"name": "canoes", "below": 40.0}})):
		_go(g, doc, quay)
	elif not carts.is_empty():
		var back: Unit = carts[carts.size() - 1]
		if doc.position.distance_to(back.position) > 2.5 * Defs.TILE:
			_go(g, doc, back.position)


## The creatures' player: asleep in Part 1 (GROW the Mother if she is rooted); from Part 2 every hunter and the Sire at
## the nearest cart with a cage (the nearest of the men when they are in the way).
func _play_creatures(g: Game, r: MissionRun, et: int, ct: int) -> void:
	var q: Array = r.tagged("mother")
	if not q.is_empty() and BroodNew.grow_problem(g, q[0]) == "":
		BroodNew.grow(g, q[0])
	if not r.fired.has("part2_go"):
		return
	var targets: Array = r.tagged("carts").filter(func(c): return c.has_meta("cage_cargo"))
	for u in g.units:
		if u.dead or u.team != ct or u.has_meta("mission_asleep") or u.has_meta("mission_caged") or u.kind in ["brood_mother", "grub", "rootmaw", "mound_turtle", "brood_egg", "food_pile"]:
			continue
		var best: Unit = null
		for c in targets:
			if best == null or u.position.distance_to(c.position) < u.position.distance_to(best.position):
				best = c
		if best == null:
			best = _nearest_foe(g, u.position, ["expedition"], 60.0 * Defs.TILE, r)
		var near := _nearest_foe(g, u.position, ["expedition"], 2.0 * Defs.TILE, r)
		if near and near.kind == "musketeer":
			best = near
		if best and (u.target == null or not is_instance_valid(u.target) or u.target.dead or u.target != best):
			u.cmd_attack(best)
