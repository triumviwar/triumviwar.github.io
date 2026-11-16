extends SceneTree
## (brood-spot-study, docs/brood_spot_study.md) A MEASURING TOOL: is the ground round the two starts of a 2-player map a
## mirror image? For each map (and seed) a Brood mirror is set up and every cell within `r` tiles of spot A is compared
## with its twin round spot B (Game.sym_rect of side 1): walkable or not, height, ramp, water, swamp, a tree / rock /
## decoration. Prints the counts of cells that differ (and which side is the more open) per map.
##   godot --headless --fixed-fps 30 --path . --script res://tools/study/map_mirror_check.gd -- [maps:a,b,...] [seed:1116] [r:30]

var main: Node
var maps: Array = []
var seed_ := 1116
var r := 30
var i := -1
var t := 0.0
var started := false

const ALL := ["greenhold", "highmoor", "dune_sea", "frostfang", "twin_fords", "ashfall", "mirewood", "border_march", "red_coast",
	"ashford_crossing", "kestrel_rise", "thornwood_maze", "redrock_canyon", "saltmarsh_isles", "glimmerdeep", "frostmere",
	"cinder_steps", "hollowfen", "amberfall_vale"]


func _initialize() -> void:
	maps = ALL.duplicate()
	for a in OS.get_cmdline_user_args():
		var kv := a.split(":", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"maps": maps = Array(kv[1].split(","))
			"seed": seed_ = int(kv[1])
			"r": r = int(kv[1])
	Settings.load_all()
	Settings.device = "pc"
	Settings.apply()
	Engine.max_fps = 0


func _process(delta: float) -> bool:
	t += delta
	if main != null and main.game != null and main.game.clock > 0.1:
		_check(main.game)
		main.queue_free()
		main = null
		return false
	if main != null:
		return false
	i += 1
	if i >= maps.size():
		return true
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	seed(seed_)
	var sl: Array = []
	for k in 2:
		sl.append({"who": "hard", "faction": "brood", "colour": k, "side": k, "strategy": "optimal"})
	main.start({"map": maps[i], "seed": seed_, "slots": sl})
	return false


func _check(g: Game) -> void:
	var a: Vector2i = g.starts[0] + Vector2i(2, 2)
	var n := 0
	var walk_a := 0
	var walk_b := 0
	var kinds := {}
	var near := {}
	for y in range(a.y - r, a.y + r + 1):
		for x in range(a.x - r, a.x + r + 1):
			var c := Vector2i(x, y)
			if not g.in_map(c) or Vector2(c).distance_to(Vector2(a)) > r:
				continue
			var m := g.sym_rect(1, c, Vector2i.ONE)
			if not g.in_map(m):
				continue
			n += 1
			var ia := g.idx(c)
			var ib := g.idx(m)
			var wa := g._walkable(c)
			var wb := g._walkable(m)
			if wa != wb:
				walk_a += 1 if wa else 0
				walk_b += 1 if wb else 0
				var d := int(Vector2(c).distance_to(Vector2(a)) / 10.0) * 10
				near[d] = int(near.get(d, 0)) + 1
			for f in ["height", "ramp", "water", "cliff"]:
				var arr = g.get(f)
				if arr is PackedByteArray or arr is PackedInt32Array or arr is Array:
					if arr.size() > maxi(ia, ib) and arr[ia] != arr[ib]:
						kinds[f] = int(kinds.get(f, 0)) + 1
			if g._terrain_kind.has(ia) != g._terrain_kind.has(ib):
				kinds["tree/rock"] = int(kinds.get("tree/rock", 0)) + 1
	print("MAPCHECK %s seed %d flips %s: %d cells within %d tiles; walkable only at A %d, only at B %d (by distance %s); other %s"
		% [g.map_id if "map_id" in g else "?", seed_, str(g.start_flip), n, r, walk_a, walk_b, str(near), str(kinds)])
