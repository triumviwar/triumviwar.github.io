extends SceneTree
## Pictures of Act 2's demo maps (docs/act2_terrain_art.md): a real match on each, the computers
## stopped, everything shown, a few soldiers of the three sides stood about so the ground's
## scale, shadows and readability can be judged next to units.
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1600x900 --fixed-fps 30 \
##       --script res://tools/shot_act2_terrain.gd -- /abs/dir demo_varzea
## Writes dir/<map>_base.png (the start, its hall and workers), _middle.png (the middle of the map),
## _cliff.png (a cliff face at the main's ramp), _close.png (soldiers among the trees, 3x) and
## _overview.png (zoomed out).
var main: Node
var g
var out := ""
var map_id := "demo_varzea"
var t := 0.0
var started := false


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	out = a[0]
	if a.size() > 1:
		map_id = a[1]
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _process(delta: float) -> bool:
	t += delta
	if t > 0.2 and main.game == null:
		main.start({"map": "campaign:" + map_id, "seed": 4242, "slots": [
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


## Open low ground near p (in cells) for a few soldiers.
func _open_near(p: Vector2i, r: int) -> Array:
	var out_c: Array = []
	for y in range(p.y - r, p.y + r + 1):
		for x in range(p.x - r, p.x + r + 1):
			var c := Vector2i(x, y)
			if g.in_map(c) and g.solid[g.idx(c)] == 0 and g.water[g.idx(c)] == 0 and g.ramp[g.idx(c)] == 0:
				out_c.append(c)
	return out_c


func _shot(name: String, at: Vector2, zoom: float) -> void:
	g.camera.zoom = Vector2(zoom, zoom)
	g.camera.position = at
	await create_timer(0.5).timeout
	root.get_viewport().get_texture().get_image().save_png("%s/%s_%s.png" % [out, map_id, name])


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(out)
	g.reveal = true
	g.explored.fill(1)
	g.fog_base_dirty = true
	g.hud.visible = false
	var st: Vector2i = g.starts[0]
	# soldiers in the middle of the map and by the trees nearest it (one side each kind: nobody fights)
	var mid := Vector2i(g.W / 2, g.H / 2)
	var spots := _open_near(mid + Vector2i(-6, -6), 5)
	var row := ["musketeer", "musketeer", "cuirassier", "mortar", "clock_soldier", "raptor", "raptor", "brute"]
	for i in mini(row.size(), spots.size()):
		var c: Vector2i = spots[(i * 7) % spots.size()]
		var u = g._add_unit(String(row[i]), 0, g.cell_center(c))
		if u:
			u.facing = Vector2(1, 1).normalized()
			u.hold_fire = true
	# a tree next to open ground for the close look
	var tree_c := mid
	var best := INF
	for i in g._terrain_kind:
		if g._terrain_kind[i] == "tree":
			var c := Vector2i(i % g.W, i / g.W)
			var d := Vector2(c).distance_to(Vector2(mid))
			if d < best and not _open_near(c, 2).is_empty():
				best = d
				tree_c = c
	var near_tree := _open_near(tree_c, 2)
	for i in mini(3, near_tree.size()):
		var u = g._add_unit(["musketeer", "raptor", "clock_soldier"][i], 0, g.cell_center(near_tree[(i * 5) % near_tree.size()]))
		if u:
			u.hold_fire = true
	await create_timer(0.3).timeout
	await _shot("base", g.cell_center(st + Vector2i(2, 4)), 1.6)
	await _shot("middle", g.cell_center(mid + Vector2i(-6, -6)), 1.6)
	# the main's cliff face at its ramp (the ramp of the demo maps runs south out of the main)
	await _shot("cliff", g.cell_center(Vector2i(20, 26)), 2.0)
	await _shot("close", g.cell_center(tree_c), 3.0)
	await _shot("overview", Vector2(g.W, g.H) * Defs.TILE * 0.5, 0.42)
	print("wrote %s/%s_*.png" % [out, map_id])
	quit()
