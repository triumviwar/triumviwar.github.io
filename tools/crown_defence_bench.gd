extends SceneTree
## CROWN DEFENCE BENCH (crown-coach-defence, docs/crown-coach-defence.md): a computer-against-computer match, headless, that
## measures how the Crown defends its home. A measuring tool only: it starts a normal match and reads it; it changes no rule.
##   godot --headless --fixed-fps 30 --script res://tools/crown_defence_bench.gd -- map:hollowfen seed:1 end:720 \
##       foe:clockwork pa:optimal pb:optimal out:/abs/dir [crown:1] [extra switches, e.g. defence:off]
## crown:1 puts the Crown on side 2 (the other start). Writes <out>/bench.json and <out>/log.txt (the match log).
## Measured, every 0.5 s:
##   home      = within HOME_R of a Crown building
##   deaths    = every Crown soldier lost: where (home or out), its order the look before, the armed value of both sides
##               within LOCAL_R of it (outmatched = the enemy's worth OUT_K times ours there), walking (a plain move order)
##   kills     = enemy soldiers killed at the Crown's home
##   arrivals  = the first moment of each visit by an enemy force worth ARRIVE or more at the Crown's home: the Crown army's
##               worth near its main hall then, and its whole army's worth, and how long before that the Crown's alert came
##               (AICrownDefence.alert_t, when it exists)
const HOME_R := 700.0
const LOCAL_R := 350.0
const OUT_K := 1.3
const ARRIVE := 250.0
const AWAY_T := 30.0            # (s) the enemy gone from home this long: the next arrival is a new visit
var main: Node
var g: Game
var map := "hollowfen"
var seed_ := 1
var end_t := 720.0
var out := "/tmp/crown_defence_bench"
var foe := "clockwork"
var pa := "optimal"
var pb := "optimal"
var diff := "hard"
var crown_side := 0
var t := 0.0
var next_s := 0.5
var ct := 0                     # the Crown's team
var ft := 1
var _last := {}                 # Unit -> [order, pos, mine, theirs, kind, value]
var _flast := {}                # enemy soldier -> [pos, value, home]
var deaths: Array = []
var kills: Array = []
var arrivals: Array = []
var _home_since := -1.0
var _away_since := -999.0
var _in_visit := false
var home_fight_t := 0.0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split(":", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"map": map = kv[1]
			"seed": seed_ = int(kv[1])
			"end": end_t = float(kv[1])
			"out": out = kv[1]
			"foe": foe = kv[1]
			"pa": pa = kv[1]
			"pb": pb = kv[1]
			"diff": diff = kv[1]
			"crown": crown_side = int(kv[1])
	DirAccess.make_dir_recursive_absolute(out)
	Settings.load_all()
	Settings.device = "pc"
	Settings.apply()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	Engine.max_fps = 0


func _process(delta: float) -> bool:
	t += delta
	if t > 0.2 and main.game == null:
		seed(seed_)
		var sl: Array = []
		var facs := ["crown", foe] if crown_side == 0 else [foe, "crown"]
		var plans := [pa, pb] if crown_side == 0 else [pb, pa]
		for i in 2:
			sl.append({"who": diff, "faction": facs[i], "colour": i, "side": i, "strategy": plans[i]})
		ct = crown_side
		ft = 1 - crown_side
		main.start({"map": map, "seed": seed_, "slots": sl})
		return false
	if main.game == null:
		return false
	g = main.game
	g.path_budget_us = 1 << 40
	if g.hud:
		g.hud.visible = false
	if g.spectator and g.spectator.process_mode != Node.PROCESS_MODE_DISABLED:
		g.spectator.process_mode = Node.PROCESS_MODE_DISABLED
	if g.controls and g.controls.process_mode != Node.PROCESS_MODE_DISABLED:
		g.controls.process_mode = Node.PROCESS_MODE_DISABLED
	if g.clock >= next_s:
		next_s += 0.5
		_look()
	if g.over or g.clock >= end_t:
		_finish()
		return true
	return false


func _soldier(u: Unit) -> bool:
	return not u.dead and not u.off_field and not u.is_worker() and (u.has_attack() or Defs.MUSKETS.has(u.kind)) \
			and not (u.kind in ["horse", "powder_wagon", "balloon"])


func _home_d(p: Vector2) -> float:
	var best := INF
	for b in g.buildings:
		if b.team == ct and not b.dead and not b.ghost:
			best = minf(best, b.center().distance_to(p))
	return best


func _val_near(tm: int, p: Vector2, r: float) -> float:
	var v := 0.0
	for o in g.units_near(p, r):
		if o.team == tm and _soldier(o):
			v += float(Game.unit_value(o))
	return v


func _crown_ai():
	for a in g.ais:
		if a.team == ct:
			return a
	return null


func _look() -> void:
	# the Crown's soldiers: deaths since the last look
	for u in _last.keys():
		if not is_instance_valid(u) or u.dead:
			var e: Array = _last[u]
			var home: bool = _home_d(e[1]) < HOME_R
			deaths.append({"t": snappedf(g.clock, 0.5), "kind": e[4], "order": e[0], "home": home, "mine": int(e[2]), "theirs": int(e[3]),
				"outmatched": float(e[3]) > float(e[2]) * OUT_K, "walking": e[0] == "move", "v": e[5]})
			_last.erase(u)
	for u in g.army(ct):
		if not _soldier(u) or u.aboard != null:
			continue
		_last[u] = [u.order, u.position, _val_near(ct, u.position, LOCAL_R), _val_near(ft, u.position, LOCAL_R), u.kind, Game.unit_value(u)]
	# the enemy's soldiers: kills at the Crown's home
	var foe_home := 0.0
	for o in _flast.keys():
		if not is_instance_valid(o) or o.dead:
			var e2: Array = _flast[o]
			if e2[2]:
				kills.append({"t": snappedf(g.clock, 0.5), "v": e2[1]})
			_flast.erase(o)
	for o in g.army(ft):
		if not _soldier(o):
			continue
		var hm := _home_d(o.position) < HOME_R
		_flast[o] = [o.position, Game.unit_value(o), hm]
		if hm:
			foe_home += float(Game.unit_value(o))
	if foe_home >= 150.0:
		home_fight_t += 0.5
	# arrivals
	if foe_home >= ARRIVE:
		_away_since = -999.0
		if not _in_visit:
			_in_visit = true
			var hall: Vector2 = g.start_mid(ct)
			var a = _crown_ai()
			var alert := -1.0
			if a != null and a.has_method("dfn_alert_t"):
				alert = float(a.dfn_alert_t())
			var mine_all := 0.0
			for u in g.army(ct):
				if _soldier(u):
					mine_all += float(Game.unit_value(u))
			arrivals.append({"t": snappedf(g.clock, 0.5), "foe": int(foe_home), "near_main": int(_val_near(ct, hall, 900.0)),
				"army": int(mine_all), "alert_t": alert, "alert_lead": (snappedf(g.clock - alert, 0.5) if alert >= 0.0 and alert <= g.clock else -1.0)})
	elif _in_visit:
		if _away_since < 0.0:
			_away_since = g.clock
		elif g.clock - _away_since > AWAY_T:
			_in_visit = false


func _finish() -> void:
	var f := FileAccess.open(out.path_join("log.txt"), FileAccess.WRITE)
	if g.mlog:
		for l in g.mlog.lines:
			f.store_line(str(l))
	f.close()
	var st_c: Dictionary = g.stats[ct]
	var st_f: Dictionary = g.stats[ft]
	var home_d := deaths.filter(func(d: Dictionary) -> bool: return d["home"])
	var bad := home_d.filter(func(d: Dictionary) -> bool: return d["outmatched"])
	var walk := home_d.filter(func(d: Dictionary) -> bool: return d["walking"])
	var lost_home := 0
	for d in home_d:
		lost_home += int(d["v"])
	var killed_home := 0
	for k in kills:
		killed_home += int(k["v"])
	var winner := -1
	if g.over:
		for tm in 2:
			if not g.eliminated[tm]:
				winner = tm
	var res := {"map": map, "seed": seed_, "foe": foe, "crown_side": crown_side, "end": int(g.clock),
		"result": ("crown" if winner == ct else (foe if winner == ft else "draw")),
		"crown_army": g.army_value(ct), "foe_army": g.army_value(ft), "crown_halls": g.halls_of(ct).size(), "foe_halls": g.halls_of(ft).size(),
		"crown_killed": int(st_c["value_killed"]), "foe_killed": int(st_f["value_killed"]),
		"crown_bld_lost": int(st_c["bld_lost"]), "foe_bld_lost": int(st_f["bld_lost"]),
		"crown_income": int(st_c["gold"]), "foe_income": int(st_f["gold"]),
		"home_deaths": home_d.size(), "home_outmatched": bad.size(), "home_walking": walk.size(),
		"home_lost_value": lost_home, "home_killed_value": killed_home, "home_fight_s": home_fight_t,
		"deaths": deaths, "arrivals": arrivals}
	var j := FileAccess.open(out.path_join("bench.json"), FileAccess.WRITE)
	j.store_string(JSON.stringify(res, " "))
	j.close()
	print("BENCH ", JSON.stringify({"result": res["result"], "end": res["end"], "home_deaths": res["home_deaths"], "outmatched": res["home_outmatched"], "walking": res["home_walking"], "lost_home": lost_home, "killed_home": killed_home}))
