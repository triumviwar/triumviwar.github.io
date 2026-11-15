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


func _sig(tm: int) -> Array:
	var out: Array = []
	for u: Unit in g.units:
		if u.team != tm or u.dead:
			continue
		var p := BroodRoot.feet_k(g, tm, u)      # (a rooted creature's footprint is mirrored, its feet hang below it)
		out.append([String(u.kind), p, u.hp, String(u.order) if "order" in u else ""])
	out.sort_custom(func(a: Array, b: Array) -> bool:
		if a[0] != b[0]:
			return a[0] < b[0]
		if absf(a[1].x - b[1].x) > 0.01:
			return a[1].x < b[1].x
		return a[1].y < b[1].y)
	return out


func _compare() -> void:
	var a := _sig(0)
	var b := _sig(1)
	var diffs: Array = []
	var pa: Dictionary = g.players[0]
	var pb: Dictionary = g.players[1]
	for k in ["gold", "res2", "cap"]:
		if pa.has(k) and absf(float(pa[k]) - float(pb[k])) > 0.001:
			diffs.append("%s %s v %s" % [k, str(pa[k]), str(pb[k])])
	if a.size() != b.size():
		diffs.append("units %d v %d" % [a.size(), b.size()])
	else:
		for i in a.size():
			if a[i][0] != b[i][0] or (a[i][1] as Vector2).distance_to(b[i][1]) > tol or absf(float(a[i][2]) - float(b[i][2])) > 0.01:
				diffs.append("%s %s hp%.1f [%s] v %s %s hp%.1f [%s]" % [a[i][0], str(a[i][1]), a[i][2], a[i][3], b[i][0], str(b[i][1]), b[i][2], b[i][3]])
				if diffs.size() > 6:
					break
	if diffs.is_empty():
		return
	shown += 1
	print("DIFF %.3f: %s" % [g.clock, " | ".join(diffs)])
	if shown == 1:
		for tm in 2:
			for u: Unit in g.units:
				if u.team == tm and not u.dead and u.order == "nb_morph" and u.nb.has("mk"):
					var k := String(u.nb["mk"])
					var sz: Vector2i = BroodRoot.fp(k)[0]
					var tgt := BroodRoot.feet_at(k, g.sym_rect(tm, BroodRoot.cell_for(k, u.order_point), sz))
					print("  MORPH team %d %s from %s to %s" % [tm, k, str(g.sym_pt(tm, u.position)), str(tgt)])
