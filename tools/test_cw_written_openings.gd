extends SceneTree
## THE CLOCKWORK'S WRITTEN BUILDS FROM THE COMMON OPENING, THE RUSH'S TURN (cw-written-openings; scripts/ai_clockwork.gd,
## docs/cw_written_openings.md): one game a plan, a Hard Clockwork computer on the plan against the Hard Crown OPTIMAL.
##   godot --headless --fixed-fps 30 --script res://tools/test_cw_written_openings.gd -- \
##       [plans:owls,springer,heavy,rush map:greenhold seed:2100 until:330] [cwcommon:off] [cwrushturn:off]
## Prints a line a minute (Winders, Cog Presses, Clocktowers, cogs earned) and checks (a bare run is the test):
##  - the Owl raids, Springer timing and Heavy Works push begin their own build between COMMON_FROM and COMMON_BY (the
##    match log's "plays the ... from here"), with the second Clocktower laid by HALL_BY, WINDERS_4 Winders at 4:00 and
##    PRESSES_5 Cog Presses (live) at 5:00;
##  - the Rush turns to the economy by RUSH_TURN (4:00).
## Each plan is its own game (the tool restarts the scene).
const HALL_BY := 180.0
const WINDERS_4 := 18
const PRESSES_5 := 3
var main: Node
var g
var t := 0.0
var map := "greenhold"
var seed_ := 2100
var until := 330.0
var plans: Array = ["owls", "springer", "heavy", "rush"]
var pi := 0
var cw = null
var fails := 0
var hall2 := -1.0
var mins := {}
var _started := false


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split(":", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"map": map = kv[1]
			"seed": seed_ = int(kv[1])
			"until": until = float(kv[1])
			"plans": plans = Array(kv[1].split(","))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _process(delta: float) -> bool:
	t += delta
	if not _started and t > 0.2:
		_started = true
		seed(seed_)
		main.start({"map": map, "seed": seed_, "slots": [
			{"who": "hard", "faction": "clockwork", "colour": 0, "side": 0, "strategy": plans[pi]},
			{"who": "hard", "faction": "crown", "colour": 1, "side": 1, "strategy": "optimal"}]})
		return false
	if main.game == null:
		return false
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	if cw == null:
		for ai in g.ais:
			if ai.team == 0:
				cw = ai
		return false
	if hall2 < 0.0 and g.halls_of(0, false).size() >= 2:
		hall2 = g.clock
	var m := int(g.clock / 60.0)
	if m >= 1 and not mins.has(m):
		var pr := 0
		for b in g.buildings:
			if b.team == 0 and not b.dead and b.built and b.kind == Defs.GEAR_PRESS and not b.barren():
				pr += 1
		mins[m] = [g.workers(0).size(), pr, g.halls_of(0, false).size(), int(g.stats[0]["gold"])]
		print("%s MIN %d Winders %d presses %d Clocktowers %d earned %d" % [plans[pi], m, mins[m][0], mins[m][1], mins[m][2], mins[m][3]])
	if g.clock >= until or g.over:
		_judge()
		pi += 1
		if pi >= plans.size():
			print("RESULT: %s (%d failed)" % ["PASS" if fails == 0 else "FAIL", fails])
			quit(1 if fails > 0 else 0)
			return true
		_next()
	return false


func _judge() -> void:
	var p: String = plans[pi]
	if p == "rush":
		if cw.rush_turn_on:
			_check(cw.rush_turned_at >= 0.0 and cw.rush_turned_at <= cw.RUSH_TURN + 1.0,
				"rush: turned to the economy at %.0f s (by %.0f)" % [cw.rush_turned_at, cw.RUSH_TURN])
		return
	if not cw.common_on:
		_check(cw.written_at < 0.0, "%s: cwcommon:off plays the build from 0:00" % p)
		return
	_check(cw.written_at >= cw.COMMON_FROM - 1.0 and cw.written_at <= cw.COMMON_BY + 1.0,
		"%s: its own build began at %.0f s (%.0f-%.0f)" % [p, cw.written_at, cw.COMMON_FROM, cw.COMMON_BY])
	_check(cw.strategy == p, "%s: plays its plan after the opening (%s)" % [p, cw.strategy])
	_check(hall2 >= 0.0 and hall2 <= HALL_BY, "%s: second Clocktower laid at %.0f s (by %.0f)" % [p, hall2, HALL_BY])
	_check(mins.has(4) and int(mins[4][0]) >= WINDERS_4, "%s: %d Winders at 4:00 (%d+)" % [p, int(mins.get(4, [0])[0]), WINDERS_4])
	_check(mins.has(5) and int(mins[5][1]) >= PRESSES_5, "%s: %d Cog Presses at 5:00 (%d+)" % [p, int(mins.get(5, [0, 0])[1]), PRESSES_5])


func _next() -> void:
	main.queue_free()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	g = null
	cw = null
	hall2 = -1.0
	mins = {}
	t = 0.0
	_started = false
