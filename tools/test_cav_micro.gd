extends SceneTree
## crown-coach-cavalry (docs/crown-coach-cavalry.md): 4 Crown Horsemen against set enemy groups on open ground, the
## riders on an attack-move as the computer's waves send them, OFF (as before: RideBy's loop round whatever is near) and
## ON (AICavMicro's hit and run), each without and with the Cavalry Charge drilled.
##   godot --headless --fixed-fps 30 --script res://tools/test_cav_micro.gd [-- only:<case>]
## Cases: raptors (16 on guard), raptors_spitters (8 Raptors before 5 Spitters), brutes_spitters (3 Brutes before 5
## Spitters), shields_winders (6 Clock Soldiers before 6 Winders), line_hands (6 Musketeers on guard before 5
## Labourers). Prints a RESULT line per case and mode and a table: the enemy's value killed, riders lost, their health
## left, sabre blows (plain / charged), seconds a rider stood still at sabre's reach of an enemy fighter.
## The checks: with the micro the riders do better (value killed per rider's health lost, all cases summed), strike charged
## blows again and again with the charge (not only the first), and lose fewer riders.
var main: Node
var t := 0.0
var g
var started := false
var fails := 0
var origin := Vector2i(-1, -1)
var only := ""
var film := ""                  # film:DIR a picture every FILM_EVERY s of each case (under xvfb-run, not --headless)
const FILM_EVERY := 0.6
var reps := 3                    # reps:N each case and mode played N times (the fights are noisy: summed)
var rows: Array = []


class StubAI:
	var team := 0
	var game = null
	func _on_errand(_u) -> bool:
		return false
	func _halls() -> Array:
		return []


func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("only:"):
			only = a.substr(5)
		if a.begins_with("reps:"):
			reps = int(a.substr(5))
		if a.begins_with("film:"):
			film = a.substr(5)
			DirAccess.make_dir_recursive_absolute(film)


func _process(_delta: float) -> bool:
	t += _delta
	if t > 0.2 and main.game == null:
		main.start({"map": "hollowfen", "seed": 4242, "slots": [
			{"who": "you", "faction": "crown", "colour": 0, "side": 0},
			{"who": "easy", "faction": "brood", "colour": 1, "side": 1}]})
		return false
	if main.game == null:
		return false
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	if not started and t > 1.0:
		started = true
		for ai in g.ais:
			ai.process_mode = Node.PROCESS_MODE_DISABLED
		_run()
	return false


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func at(dx: float, dy: float) -> Vector2:
	return Vector2(origin) * Defs.TILE + Vector2(dx, dy)


func _open_area(w: int, h: int) -> Vector2i:
	var starts: Array = []
	for b in g.buildings:
		starts.append(b.center())
	for y in range(4, g.H - h - 4):
		for x in range(4, g.W - w - 4):
			var ok := true
			var h0: int = g.height[g.idx(Vector2i(x, y))]
			for yy in h:
				for xx in w:
					var c := Vector2i(x + xx, y + yy)
					if g.solid[g.idx(c)] != 0 or g.ramp[g.idx(c)] != 0 or g.height[g.idx(c)] != h0:
						ok = false
						break
				if not ok:
					break
			if not ok:
				continue
			var p: Vector2 = g.cell_center(Vector2i(x + w / 2, y + h / 2))
			for s in starts:
				if p.distance_to(s) < 700.0:
					ok = false
			if ok:
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func _clear() -> void:
	for u in g.units.duplicate():
		if u.position.distance_to(at(450, 320)) < 1300.0:
			g.consume_unit(u)
	for b in g.buildings.duplicate():
		if not b.dead and b.team >= 0 and b.center().distance_to(at(450, 320)) < 1000.0:
			b.die()
	for i in 3:
		await physics_frame


func _run() -> void:
	origin = _open_area(32, 22)
	if origin.x < 0:
		origin = _open_area(28, 20)
	if origin.x < 0:
		print("FAIL: no open ground for the test")
		quit(1)
		return
	g.reveal = true
	g.path_budget_us = 1 << 40      # (no pathing cut short by the wall clock: the same fight every run)
	g.players[0]["cap"] = 300
	g.players[1]["cap"] = 300
	var cases := ["raptors", "raptors_spitters", "brutes_spitters", "shields_winders", "line_hands"]
	for c in cases:
		if only != "" and c != only:
			continue
		for ch in [false, true]:
			for on in [false, true]:
				for k in reps:
					seed(1000 + k)
					await _case(c, on, ch, k)
	print("")
	print("| case | charge | micro | killed (value, summed) | riders lost | health left (mean) | blows plain / charged | stood (s) |")
	print("|---|---|---|---|---|---|---|---|")
	var sums: Array = []
	for r in rows:
		var m := {}
		for q in sums:
			if q["case"] == r["case"] and q["on"] == r["on"] and q["charge"] == r["charge"]:
				m = q
		if m.is_empty():
			m = {"case": r["case"], "on": r["on"], "charge": r["charge"], "killed": 0, "lost": 0, "hp": 0.0, "plain": 0, "charged": 0, "stood": 0.0, "n": 0}
			sums.append(m)
		for key in ["killed", "lost", "plain", "charged"]:
			m[key] += int(r[key])
		m["hp"] += float(r["hp"])
		m["stood"] += float(r["stood"])
		m["n"] += 1
	for m in sums:
		m["hp"] = int(round(float(m["hp"]) / maxf(1.0, m["n"])))
		print("| %s | %s | %s | %d | %d of %d | %d%% | %d / %d | %.1f |" % [m["case"], "yes" if m["charge"] else "no", "on" if m["on"] else "off",
			m["killed"], m["lost"], 4 * int(m["n"]), m["hp"], m["plain"], m["charged"], m["stood"]])
	rows = sums
	_checks()
	print("ALL PASS" if fails == 0 else "%d FAILED" % fails)
	quit(0 if fails == 0 else 1)


func _row(c: String, on: bool, ch: bool) -> Dictionary:
	for r in rows:
		if r["case"] == c and r["on"] == on and r["charge"] == ch:
			return r
	return {}


## value killed per rider's health lost (more is better), 1 hp lost at least
func _trade(r: Dictionary) -> float:
	return float(r["killed"]) / maxf(20.0, 560.0 * float(r["n"]) * (1.0 - float(r["hp"]) / 100.0))


func _checks() -> void:
	# (the enemy's value killed for the riders' health lost, over every case: the fights are noisy one by one)
	var k_on := 0.0
	var k_off := 0.0
	var h_on := 0.0
	var h_off := 0.0
	for r in rows:
		var lost := 560.0 * float(r["n"]) * (1.0 - float(r["hp"]) / 100.0)
		if r["on"]:
			k_on += float(r["killed"])
			h_on += lost
		else:
			k_off += float(r["killed"])
			h_off += lost
	check(k_on / maxf(1.0, h_on) >= k_off / maxf(1.0, h_off), "the micro kills as much or more for the riders' health (%.2f a point, before %.2f)" % [
		k_on / maxf(1.0, h_on), k_off / maxf(1.0, h_off)])
	var ch_on := 0
	var ch_off := 0
	var lo_on := 0
	var lo_off := 0
	for r in rows:
		if r["charge"]:
			if r["on"]:
				ch_on += int(r["charged"])
			else:
				ch_off += int(r["charged"])
		if r["on"]:
			lo_on += int(r["lost"])
		else:
			lo_off += int(r["lost"])
	if only == "":
		check(ch_on > ch_off, "with the charge drilled, the micro strikes more charged blows (%d, before %d)" % [ch_on, ch_off])
		check(lo_on < lo_off, "the micro loses fewer riders (%d, before %d)" % [lo_on, lo_off])


func _spawn(kind: String, n: int, mid: Vector2, cols := 4, work := false) -> Array:
	var men: Array = []
	for i in n:
		var p := mid + Vector2((i % cols) * 26.0 - 13.0 * (cols - 1), (i / cols) * 26.0 - 13.0)
		var m: Unit = g._add_unit(kind, 1, p)
		m.auto_work = false
		men.append(m)
	return men


func _case(c: String, on: bool, ch: bool, k := 0) -> void:
	await _clear()
	g.players[0]["tech"] = {"charge": true} if ch else {}
	var mid := at(620, 320 + (k - 1) * 40)
	var men: Array = []
	var secs := 45.0
	match c:
		"raptors":
			men = _spawn("raptor", 16, mid, 4)
		"raptors_spitters":
			men = _spawn("raptor", 8, mid - Vector2(40, 0), 4) + _spawn("spitter", 5, mid + Vector2(100, 0), 3)
		"brutes_spitters":
			men = _spawn("brute", 3, mid - Vector2(40, 0), 3) + _spawn("spitter", 5, mid + Vector2(100, 0), 3)
		"shields_winders":
			men = _spawn("clock_soldier", 6, mid - Vector2(50, 0), 3) + _spawn("winder", 6, mid + Vector2(90, 0), 3)
		"line_hands":
			men = _spawn("musketeer", 6, mid - Vector2(40, 0), 6) + _spawn("labourer", 5, mid + Vector2(110, 0), 5)
	var costs: Array = []
	for m in men:
		costs.append(int(Defs.UNITS[m.kind]["cost"]))
	var riders: Array = []
	for i in 4:
		var r: Unit = g._add_unit("cuirassier", 0, at(150, 270 + i * 34))
		riders.append(r)
	var hp_all := 0.0
	for r in riders:
		hp_all += r.max_hp
	await physics_frame
	var stub := StubAI.new()
	stub.game = g
	var micro := AICavMicro.new(stub)
	micro.on = on
	var b0: float = float(g.stats[0].get("cav_blows", 0.0))
	var c0: float = float(g.stats[0].get("cav_charged", 0.0))
	for r in riders:
		r.cmd_move(mid, true)
	var t0: float = g.clock
	var stood := 0.0
	var look := 0.0
	var shot_t := 0.0
	var shot_n := 0
	while g.clock - t0 < secs:
		await physics_frame
		micro.tick()
		if film != "" and k == 0 and g.clock - t0 >= shot_t:
			shot_t = g.clock - t0 + FILM_EVERY
			await _shot(riders, men, "%s/%s_%s_%s_%03d.jpg" % [film, c, "charge" if ch else "plain", "on" if on else "off", shot_n])
			shot_n += 1
		if g.clock - t0 >= look:
			look = g.clock - t0 + 0.25
			for r in riders:
				if is_instance_valid(r) and not r.dead and r.velocity.length() < r.speed * 0.3:
					for o in g.units_near(r.position, 60.0):
						if not o.dead and o.team == 1 and Game.fights_back(o) and o.edge_distance(r.position) - r.radius <= 30.0:
							stood += 0.25
							break
			# (riders the micro let go of, with prey left: the wave's think would send them on again)
			for r in riders:
				if is_instance_valid(r) and not r.dead and r.order == "idle" and not micro.has(r):
					r.cmd_move(mid, true)
		var alive := riders.filter(func(r) -> bool: return is_instance_valid(r) and not r.dead).size()
		var left := men.filter(func(m) -> bool: return is_instance_valid(m) and not m.dead).size()
		if alive == 0 or left == 0:
			break
	var killed := 0
	for i in men.size():
		if not is_instance_valid(men[i]) or men[i].dead:
			killed += int(costs[i])
	var lost := riders.filter(func(r) -> bool: return not is_instance_valid(r) or r.dead).size()
	var hp_left := 0.0
	for r in riders:
		if is_instance_valid(r) and not r.dead:
			hp_left += r.hp
	var row := {"case": c, "on": on, "charge": ch, "killed": killed, "lost": lost, "hp": int(round(100.0 * hp_left / hp_all)),
		"plain": int(float(g.stats[0].get("cav_blows", 0.0)) - b0), "charged": int(float(g.stats[0].get("cav_charged", 0.0)) - c0),
		"stood": stood, "secs": g.clock - t0}
	rows.append(row)
	print("RESULT %s charge:%s micro:%s killed %d, riders lost %d, health left %d%%, blows %d / %d charged, stood %.1f s (%.0f s)" % [
		c, ch, on, killed, lost, row["hp"], row["plain"], row["charged"], stood, row["secs"]])


## (film:) a picture of the fight: the camera on the middle of the riders and the enemy left, the frame drawn, saved.
func _shot(riders: Array, men: Array, file: String) -> void:
	var c := Vector2.ZERO
	var k := 0
	for u in riders + men:
		if is_instance_valid(u) and not u.dead:
			c += u.position
			k += 1
	if k == 0:
		return
	var cam: Camera2D = g.camera
	cam.position = c / k
	cam.zoom = Vector2(1.1, 1.1)
	cam.reset_smoothing()
	await process_frame
	await process_frame
	var img := root.get_viewport().get_texture().get_image()
	img.save_jpg(file, 0.8)
