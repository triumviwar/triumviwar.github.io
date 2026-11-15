extends SceneTree
## (brood-spot-study, docs/brood_spot_study.md) A MEASURING TOOL: plays one mirror match and compares the two sides in each
## other's frame (side B turned onto side A by the map's mirror, Game.sym_pt) every physics tick; prints the first ticks
## where they differ and what differs (a resource, a unit's kind, place or health).
##   godot --headless --fixed-fps 30 --path . --script res://tools/study/spot_trace.gd -- map:twin_fords seed:1116 \
##       slots:brood/optimal/0,brood/optimal/1 end:120 [tol:0.5] [max:40] [spotswap]

var main: Node
var g: Game
var map := "twin_fords"
var seed_ := 1116
var end_t := 120.0
var tol := 0.5
var max_n := 40
var slots: Array = []
var t := 0.0
var shown := 0
var last_tick := -1
var _last_key := ""


func _initialize() -> void:
	var spec := "brood/optimal/0,brood/optimal/1"
	for a in OS.get_cmdline_user_args():
		var kv := a.split(":", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"map": map = kv[1]
			"seed": seed_ = int(kv[1])
			"end": end_t = float(kv[1])
			"tol": tol = float(kv[1])
			"max": max_n = int(kv[1])
			"slots": spec = kv[1]
	for s in spec.split(","):
		var p := s.split("/")
		slots.append([p[0], p[1], int(p[2])])
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
		for i in slots.size():
			sl.append({"who": "hard", "faction": slots[i][0], "colour": i, "side": slots[i][2], "strategy": slots[i][1]})
		main.start({"map": map, "seed": seed_, "slots": sl})
		return false
	if main.game == null:
		return false
	g = main.game
	g.path_budget_us = 1 << 40
	if g.hud:
		g.hud.visible = false
	if g.clock >= end_t or g.over or shown >= max_n:
		print("END clock %.2f shown %d" % [g.clock, shown])
		return true
	if last_tick < 0:
		last_tick = 0
		print("starts ", g.starts, " flip ", g.start_flip, " W H ", Game.W, " ", Game.H)
		for u: Unit in g.units:
			if u.kind != "grub":
				print("  ", u.team, " ", u.kind, " ", u.position, " canon ", g.sym_pt(u.team, u.position))
	_compare()
	return false


func _units(tm: int) -> Dictionary:
	var out := {}
	for u: Unit in g.units:
		if u.team == tm and not u.dead:
			out[u.tserial] = u
	return out


func _desc(u: Unit) -> String:
	var tgt := ""
	if not u.path.is_empty():
		tgt = " path_end %s (%d pts, at %d)" % [str(g.sym_pt(u.team, u.path[u.path.size() - 1]).snapped(Vector2(0.01, 0.01))), u.path.size(), u.path_i]
	return "%s #%d %s/%s hp %.2f carry %d at %s v %s%s%s" % [u.kind, u.tserial, u.order, u.work, u.hp, u.carrying, str(BroodRoot.feet_k(g, u.team, u).snapped(Vector2(0.001, 0.001))),
		str(g.sym_dir(u.team, u.velocity).snapped(Vector2(0.001, 0.001))) if "velocity" in u else "", tgt, " pend" if u.path_pending else ""]


func _compare() -> void:
	var a := _units(0)
	var b := _units(1)
	var diffs: Array = []
	var pa: Dictionary = g.players[0]
	var pb: Dictionary = g.players[1]
	for k in ["gold", "res2", "cap"]:
		if pa.has(k) and absf(float(pa[k]) - float(pb[k])) > 0.001:
			diffs.append("%s %s v %s" % [k, str(pa[k]), str(pb[k])])
	for n in a:
		if not b.has(n):
			diffs.append("only side 0: " + _desc(a[n]))
			continue
		var ua: Unit = a[n]
		var ub: Unit = b[n]
		var d := BroodRoot.feet_k(g, 0, ua).distance_to(BroodRoot.feet_k(g, 1, ub))
		if ua.kind != ub.kind or ua.order != ub.order or ua.work != ub.work or d > tol or absf(ua.hp - ub.hp) > 0.01:
			diffs.append("d %.4f | %s || %s" % [d, _desc(ua), _desc(ub)])
	for n in b:
		if not a.has(n):
			diffs.append("only side 1: " + _desc(b[n]))
	if diffs.is_empty():
		return
	var key := ""
	for x in diffs:
		key += String(x).substr(0, 30) + ";"
	if key == _last_key:
		return
	_last_key = key
	shown += 1
	print("DIFF %.3f:\n  %s" % [g.clock, "\n  ".join(diffs.slice(0, 6))])
