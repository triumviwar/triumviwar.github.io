extends SceneTree
## THE WHEELS' STUCK SPOTS, REPLAYED (job ai-fixes-b, docs/ai_fixes_b.md). Every spot where a Field Cannon, Mortar or Powder
## Wagon stood stuck on a move order in the study games (tools/qa_match.gd's "stuck" events, kept with the 21 x 21 cells
## round it in docs/ai_fixes_b/wheel_spots.json) is laid again on an open field of Greenhold: the buildings, walls, gates,
## cliffs and fields of the picture (not the other units: they come and go), the same gun or wagon limbered at the same
## cell, sent to the same goal, starting facing each of 8 ways, with one horse and with a team of three. With crowd=1 a
## Musketeer of its side stands where the picture had one (u).
## A trial is STUCK when it stood still 6 s or more in TIME s (moved under 6 px in 2 s, still more than 48 px from where it
## goes). It prints one line a spot and the totals.
##   godot --headless --fixed-fps 30 --script res://tools/test_wheels_replay.gd [-- only=N[,N] facings=8 teams=1,3 out=file]
var main: Node
var g
var t := 0.0
var started := false
var spots: Array = []
var only: Array = []
var facings := 8
var teams := [1, 3]
var out_path := ""
var trace := false
var crowd := false          # crowd=1: a Musketeer stands on every cell the picture had one of its side on (u)
var spots_file := "res://docs/ai_fixes_b/wheel_spots.json"
var area := Vector2i(-1, -1)
var stamped: Array = []
const TIME := 25.0
const R := 10


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"only": only = Array(kv[1].split(",")).map(func(x): return int(x))
			"facings": facings = int(kv[1])
			"teams": teams = Array(kv[1].split(",")).map(func(x): return int(x))
			"out": out_path = kv[1]
			"trace": trace = kv[1] == "1"
			"file": spots_file = kv[1]
			"crowd": crowd = kv[1] == "1"
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _process(delta: float) -> bool:
	t += delta
	if spots.is_empty():
		spots = JSON.parse_string(FileAccess.get_file_as_string(spots_file))
	if main.game == null and t > 0.2:
		seed(4242)
		main.start({"map": "greenhold", "seed": 4242, "slots": [
			{"who": "you", "faction": "crown", "colour": 0, "side": 0},
			{"who": "easy", "faction": "brood", "colour": 1, "side": 1}]})
		return false
	if main.game == null or started:
		return false
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	if t > 1.0:
		started = true
		for ai in g.ais:
			ai.process_mode = Node.PROCESS_MODE_DISABLED
		if g.controls:
			g.controls.process_mode = Node.PROCESS_MODE_DISABLED
		_run()
	return false


func _find_area() -> Vector2i:
	var n := 2 * R + 9
	for y in range(4, g.H - n - 4):
		for x in range(4, g.W - n - 4):
			var c := Vector2i(x, y)
			var h0: int = g.height[g.idx(c)]
			var ok := true
			for yy in range(n):
				for xx in range(n):
					var q := c + Vector2i(xx, yy)
					if g.solid[g.idx(q)] > 1 or g.ramp[g.idx(q)] != 0 or g.cliff[g.idx(q)] != 0 or g.height[g.idx(q)] != h0:
						ok = false
						break
				if not ok:
					break
			if ok and g.starts.all(func(s: Vector2i) -> bool: return (Vector2(s) - Vector2(c)).length() > 24.0):
				return c + Vector2i(R + 4, R + 4)
	return Vector2i(-1, -1)


func _unstamp() -> void:
	for c in stamped:
		g.gate_team.erase(g.idx(c))
		g._mark(c, Vector2i.ONE, 0)
	stamped.clear()


func _stamp(grid: Array) -> void:
	for y in grid.size():
		var row: String = grid[y]
		for x in row.length():
			var ch := row[x]
			var v := 0
			match ch:
				"B": v = 2
				"W", "w", "g": v = 4
				"G": v = 3
				"#": v = 1
				"f": v = 5
			var c: Vector2i = area + Vector2i(x - R, y - R)
			if v == 0:
				if g.solid[g.idx(c)] != 0:
					g._mark(c, Vector2i.ONE, 0)      # (a tree of the field: the picture's open ground)
				continue
			g._mark(c, Vector2i.ONE, v)
			if v == 3:
				g.gate_team[g.idx(c)] = 0
			stamped.append(c)


func _trial(sp: Dictionary, face: Vector2, horses: int) -> Dictionary:
	var at: Vector2 = g.cell_center(area)
	var gv: Vector2i = Vector2i(int(sp["goal"][0]) - int(sp["at"][0]), int(sp["goal"][1]) - int(sp["at"][1]))
	var gc: Vector2i = area + gv
	gc = Vector2i(clampi(gc.x, 2, g.W - 3), clampi(gc.y, 2, g.H - 3))      # (a goal off this map's edge: its edge)
	var goal: Vector2 = g.cell_center(gc)
	var stop: Vector2 = Vector2.INF       # (a goal beyond the laid picture: where its first path ends)
	var men: Array = []
	if crowd:
		var grid: Array = sp["grid"]
		for y in grid.size():
			for x in String(grid[y]).length():
				if String(grid[y])[x] == "u":
					men.append(g._add_unit("musketeer", 0, g.cell_center(area + Vector2i(x - R, y - R))))
	var u: Unit = g._add_unit(String(sp["kind"]), 0, at)
	u.facing = face
	for i in horses - 1:
		u.team_horses.append({"coat": u.coat, "hp": 1.0, "m": 0.0})
	await physics_frame
	if u.order == "amove" or String(sp["order"]) == "amove":
		g.group_move([u], goal, true)
	else:
		u.cmd_move(goal)
	var tt := 0.0
	var hist: Array = []
	var still := 0.0
	var worst := 0.0
	var arrived := -1.0
	var step := 0.0
	while tt < TIME:
		await physics_frame
		tt += 1.0 / 30.0
		step += 1.0 / 30.0
		if not u.path_pending and not u.path.is_empty():
			stop = u.path[u.path.size() - 1]       # (where its way ends now)
		if stop == Vector2.INF:
			continue
		if u.position.distance_to(stop) <= 48.0 or (u.order == "idle" and u.position.distance_to(stop) <= 64.0):
			arrived = tt
			break
		if step >= 0.5:
			step = 0.0
			if trace:
				print("  %.1f cell %s off %s face %s path %d/%d %s stuck_t %.1f vel %.0f" % [tt, str(g.cell_of(u.position) - area), str((u.position - g.cell_center(g.cell_of(u.position))).round()),
					str(u.facing.snapped(Vector2(0.01, 0.01))), u.path_i, u.path.size(), str(Array(u.path).map(func(q): return g.cell_of(q) - area)), u.stuck_t, u.velocity.length()])
			hist.append(u.position)
			if hist.size() > 5:
				hist.pop_front()
			if hist.size() == 5 and (hist[0] as Vector2).distance_to(u.position) < 6.0:
				still += 0.5
				worst = maxf(worst, still)
			else:
				still = 0.0
	var res := {"arrived": arrived, "worst": worst, "order": u.order, "end": [int(u.position.x / 32) - area.x, int(u.position.y / 32) - area.y], "stop": str(g.cell_of(stop) - area) if stop != Vector2.INF else "-", "d": int(u.position.distance_to(stop)) if stop != Vector2.INF else -1}
	g.consume_unit(u)
	for m in men:
		if is_instance_valid(m) and not m.dead:
			g.consume_unit(m)
	await physics_frame
	return res


func _run() -> void:
	area = _find_area()
	if area.x < 0:
		print("no open area")
		quit(1)
		return
	for u in g.units.duplicate():
		if u.team != 0 and u.kind != BroodNew.QUEEN:
			g.consume_unit(u)
	var tot := 0
	var stuck := 0
	var spot_bad := 0
	var lines: Array = []
	var recs: Array = []
	for i in spots.size():
		if not only.is_empty() and not only.has(i):
			continue
		var sp: Dictionary = spots[i]
		_unstamp()
		_stamp(sp["grid"])
		await physics_frame
		var bad := 0
		var n := 0
		var worst := 0.0
		var fails: Array = []
		for hn in teams:
			for k in facings:
				var face := Vector2.RIGHT.rotated(TAU * float(k) / float(facings))
				var r: Dictionary = await _trial(sp, face, hn)
				n += 1
				var s: bool = float(r["worst"]) >= 6.0
				if s:
					bad += 1
					fails.append("%dh f%d %s stop %s d %d" % [hn, k, str(r["end"]), r["stop"], r["d"]])
				worst = maxf(worst, float(r["worst"]))
		tot += n
		stuck += bad
		if bad > 0:
			spot_bad += 1
		lines.append("spot %3d %-13s %-5s %s -> %s: stuck %d/%d, worst still %.1f s %s" % [i, sp["kind"], sp["order"], str(sp["at"]), str(sp["goal"]), bad, n, worst, ", ".join(fails.slice(0, 4))])
		print(lines[-1])
		recs.append({"i": i, "bad": bad, "n": n, "worst": worst})
	_unstamp()
	print("wheels replay: %d of %d spots with a stuck trial, %d of %d trials stuck" % [spot_bad, recs.size(), stuck, tot])
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		f.store_string(JSON.stringify(recs))
		f.close()
	quit(0)
