class_name MapThumb
## THE MAP PICTURES (job map-previews, docs/map_previews.md): a small minimap of a map made from its data
## without starting a match: the ground's colours as the in-game minimap has them (the same tiles' mean colours),
## high ground lighter, cliffs dark, ramps light, water, fords, woods and rocks, and every hall spot (where the
## land's reserves are) ringed in gold. The start spots are not in the picture: MapPreview numbers them on top.
##
## picture(id) gives the picture at once when it is known (kept in memory, a bundled assets/maps/<id>.png for
## every built-in and campaign map, the picture the map editor saved with your map, or a cached
## user://map_previews/<id>__<version>.png) and otherwise queues it and gives null: the queue makes one
## picture a frame (MapThumbWorker, no threads: the web build), saves it to the cache, and MapPreview draws it
## when it comes. render(id) makes one at once (the tool and the map editor).
##
## Versions: a built-in or campaign map's picture belongs to the game's version (the bundled ones are remade by
## tools/make_map_previews.gd); a map of your own to its file's time, so an edited map gets a new picture.
## The classic maps are laid out anew each match from its seed: their picture is one fixed layout (PREVIEW_SEED),
## with 3-4 players their own four-corner picture ("<id>_4p").

const CACHE_DIR := "user://map_previews"
const BUNDLE_DIR := "res://assets/maps"
const PREVIEW_SEED := 7          # the classic maps' preview layout
const SCALE := 2                 # picture pixels a cell
const GOLD := Color(0.95, 0.78, 0.3)

static var _mem := {}            # cache key -> Texture2D
static var _queue: Array = []    # [key, map_id, players]
static var _worker: Node = null
static var _set_avg := {}        # tile key -> its mean colour (the in-game minimap's, Game._tile_avg)
static var made := 0             # pictures made this session (the tests count them)


## The picture's own id: a classic map with 3-4 players has its four-corner layout.
static func pic_id(map_id: String, players := 2) -> String:
	if MapGen.MAPS.has(map_id) and players > 2:
		return map_id + "_4p"
	return map_id


static func _version(map_id: String) -> String:
	if map_id.begins_with("custom:"):
		return "t%d" % FileAccess.get_modified_time("%s/%s.json" % [MapGen.MAP_DIR, map_id.substr(7)])
	return String(ProjectSettings.get_setting("application/config/version", "dev"))


static func _key(map_id: String, players: int) -> String:
	return "%s__%s" % [pic_id(map_id, players).replace(":", "_").replace("/", "_"), _version(map_id)]


## Can this id have a picture (a pool or an unknown id cannot)?
static func drawable(map_id: String) -> bool:
	if MapGen.is_pool(map_id):
		return false
	if MapGen.MAPS.has(map_id) or MapData.NAMED.has(map_id):
		return true
	if map_id.begins_with("custom:"):
		return FileAccess.file_exists("%s/%s.json" % [MapGen.MAP_DIR, map_id.substr(7)])
	if map_id.begins_with("campaign:"):
		return not Campaign.map_data(map_id.substr(9)).is_empty()
	return false


## The picture if it is known, else null (and it is queued: ask again next frame).
static func picture(map_id: String, players := 2) -> Texture2D:
	if not drawable(map_id):
		return null
	var key := _key(map_id, players)
	if _mem.has(key):
		return _mem[key]
	var tex := _from_disk(map_id, players, key)
	if tex != null:
		_mem[key] = tex
		return tex
	for q in _queue:
		if q[0] == key:
			return null
	_queue.append([key, map_id, players])
	_ensure_worker()
	return null


static func pending() -> int:
	return _queue.size()


## The bundled picture's file name ("frostfang_4p", "campaign_rome_council").
static func bundle_name(map_id: String, players := 2) -> String:
	return pic_id(map_id, players).replace(":", "_")


static func _from_disk(map_id: String, players: int, key: String) -> Texture2D:
	if MapGen.MAPS.has(map_id) or MapData.NAMED.has(map_id) or map_id.begins_with("campaign:"):
		var bp := "%s/%s.png" % [BUNDLE_DIR, bundle_name(map_id, players)]
		if ResourceLoader.exists(bp):
			return load(bp)
	if map_id.begins_with("custom:"):
		# the picture the map editor saved with the map (the same minimap, without the gold hall rings): no wait
		var nm := map_id.substr(7)
		var pp := "%s/%s.png" % [MapGen.MAP_DIR, nm]
		if FileAccess.file_exists(pp) and FileAccess.get_modified_time(pp) + 5 >= FileAccess.get_modified_time("%s/%s.json" % [MapGen.MAP_DIR, nm]):
			var t := MapGen.custom_picture(nm)
			if t != null:
				return t
	var cp := "%s/%s.png" % [CACHE_DIR, key]
	if FileAccess.file_exists(cp):
		var img := Image.load_from_file(cp)
		if img != null and not img.is_empty():
			return ImageTexture.create_from_image(img)
	return null


static func _ensure_worker() -> void:
	if _worker != null and is_instance_valid(_worker):
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	_worker = MapThumbWorker.new()
	tree.root.add_child.call_deferred(_worker)


## One queued picture made (MapThumbWorker calls it once a frame).
static func work_one() -> bool:
	if _queue.is_empty():
		return false
	var q: Array = _queue.pop_front()
	var img := render(String(q[1]), int(q[2]))
	if img != null:
		DirAccess.make_dir_recursive_absolute(CACHE_DIR)
		img.save_png("%s/%s.png" % [CACHE_DIR, q[0]])
		_mem[q[0]] = ImageTexture.create_from_image(img)
	else:
		_mem[q[0]] = null
	return true


## Forget the pictures of a map (the map editor after a save).
static func forget(map_id: String) -> void:
	for k in _mem.keys():
		if String(k).begins_with(pic_id(map_id).replace(":", "_") + "__"):
			_mem.erase(k)


# ------------------------------------------------------------------ making a picture

## Lay the map out (the generator only: no match, no nodes in the tree) and paint its minimap. Game.W / Game.H
## are the running match's size, so they are put back after.
static func render(map_id: String, players := 2, seed := PREVIEW_SEED) -> Image:
	if not drawable(map_id):
		return null
	var ow := Game.W
	var oh := Game.H
	var msz := MapGen.size_of(map_id)
	Game.W = msz.x
	Game.H = msz.y
	var g := Game.new()
	g.map_id = map_id
	g.rng.seed = seed
	var n := players
	if MapData.NAMED.has(map_id):
		n = MapGen.max_players(map_id)
	elif map_id.begins_with("custom:"):
		n = maxi(2, (MapGen.load_custom(map_id.substr(7)).get("starts", []) as Array).size())
	elif map_id.begins_with("campaign:"):
		n = 2
	else:
		n = 4 if players > 2 else 2
	var facs: Array = []
	var sides: Array = []
	for i in n:
		facs.append("crown")
		sides.append(0 if i < n / 2 else 1)
	g.factions = facs
	g.sides = sides
	var cells := msz.x * msz.y
	for arr in ["solid", "water", "cliff", "height", "ramp"]:
		var a: PackedByteArray = g.get(arr)
		a.resize(cells)
		g.set(arr, a)
	var img: Image = null
	g.mapgen = MapGen.new(g)
	g.mapgen.generate(map_id)
	img = _paint(g)
	g.free()
	Game.W = ow
	Game.H = oh
	made += 1
	return img


## The in-game minimap's colours (Game._render_ground's), then the lobby's marks: high ground lighter, cliffs dark,
## ramps light, hall spots ringed gold. Twice the cells' size.
static func _paint(g: Game) -> Image:
	var W := Game.W
	var H := Game.H
	var mg: MapGen = g.mapgen
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	var near_base := func(c: Vector2i) -> bool:
		for st in g.starts:
			if (Vector2(c) - (Vector2(st) + Vector2(2.5, 2))).length() < 6.5:
				return true
		return false
	for y in H:
		for x in W:
			var i := y * W + x
			var bn := mg.biome_at(x, y)
			var b: Dictionary = MapGen.BIOMES.get(bn, MapGen.BIOMES["grass"])
			var rnd := int(abs(sin(x * 12.9898 + y * 78.233) * 43758.5453))
			var set_name: String
			var shade := 1.0
			if g.water[i] == 1:
				set_name = mg.water_set if mg.water_set != "" else b["water"]
			elif mg.ford.size() > i and mg.ford[i] == 1:
				set_name = mg.ford_set if mg.ford_set != "" else b["ford"]
			elif g.ramp[i] == 1:
				set_name = b["high"]
			elif g.cliff[i] == 1:
				var face: bool = y + 1 < H and g.height[i + W] == 0 and g.ramp[i + W] == 0
				set_name = b["face"] if face else b["high"]
				shade = 1.0 if face else 0.72
				if not face:
					var rim: Array = b["low"]
					set_name = rim[int(g._value_noise(x + 500, y, 4.0) * rim.size() * 0.999)] if b.get("patches", false) else rim[rnd % rim.size()]
					shade = 1.07
			elif g.height[i] == 1:
				var low_h: Array = b["low"]
				var hi := rnd % low_h.size()
				if b.get("patches", false):
					hi = int(g._value_noise(x + 500, y, 4.0) * low_h.size() * 0.999)
				set_name = low_h[hi]
				shade = 1.07
			elif near_base.call(Vector2i(x, y)):
				set_name = b["base"]
			else:
				var low: Array = b["low"]
				var li := rnd % low.size()
				if b.get("patches", false):
					li = int(g._value_noise(x + 500, y, 4.0) * low.size() * 0.999)
				set_name = low[li]
			var mc := _avg(g, set_name, rnd / 7) * shade
			if g.cliff[i] == 1 and set_name != b["face"]:
				mc *= 0.73
			var kind: String = g._terrain_kind.get(i, "")
			if kind == "tree":
				mc = mc.darkened(0.45)
			elif kind == "rock" or kind == "prop":
				mc = Color(0.45, 0.45, 0.45)
			# (the lobby's marks, as the old pictures had them)
			if g.cliff[i] == 1:
				mc = mc.darkened(0.6)
			elif g.ramp[i] == 1:
				mc = mc.lightened(0.35)
			elif g.height[i] == 1:
				mc = mc.lightened(0.18)
			img.set_pixel(x, y, Color(mc.r, mc.g, mc.b, 1.0))
	img.resize(W * SCALE, H * SCALE, Image.INTERPOLATE_NEAREST)
	# every hall spot (the land's reserves): a gold ring round its footprint
	var seen := {}
	for s in g.base_sites + g.expansions + g.starts:
		var c := Vector2i(s)
		if seen.has(c) or c.x < 0 or c.y < 0:
			continue
		seen[c] = true
		var r := Rect2i(c * SCALE, MapGen.HALL * SCALE)
		_ring(img, r, GOLD)
	return img


static func _ring(img: Image, r: Rect2i, col: Color) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for x in range(r.position.x, r.end.x):
		for y in [r.position.y, r.end.y - 1]:
			if x >= 0 and x < w and y >= 0 and y < h:
				img.set_pixel(x, y, col)
	for y in range(r.position.y, r.end.y):
		for x in [r.position.x, r.end.x - 1]:
			if x >= 0 and x < w and y >= 0 and y < h:
				img.set_pixel(x, y, col)


## A ground tile's mean colour, as the in-game minimap takes it (loaded once a session for every map).
static func _avg(g: Game, set_name: String, rnd: int) -> Color:
	var key := g._tile_key(set_name, rnd)
	if not _set_avg.has(key):
		g._tile(set_name, rnd)
		for k in g._tile_avg:
			_set_avg[k] = g._tile_avg[k]
		if not _set_avg.has(key):
			_set_avg[key] = Color(0.3, 0.5, 0.2)
	return _set_avg[key]


# ------------------------------------------------------------------ start spots

## Every start spot of a map as [cell, side], for a picture with no players chosen (a tournament's pool, a list).
static func start_spots(map_id: String) -> Array:
	var out: Array = []
	if MapData.NAMED.has(map_id):
		var n := MapGen.max_players(map_id)
		var sides: Array = []
		for i in n:
			sides.append(0 if i < n / 2 else 1)
		var st := MapGen.named_starts(map_id, sides)
		for i in st.size():
			out.append([st[i], sides[i]])
	elif map_id.begins_with("custom:") or map_id.begins_with("campaign:"):
		var d := MapGen.load_custom(map_id.substr(7)) if map_id.begins_with("custom:") else Campaign.map_data(map_id.substr(9))
		var teams := MapGen.custom_teams(d)
		var st: Array = d.get("starts", [])
		for i in st.size():
			out.append([Vector2i(int(st[i][0]), int(st[i][1])), int(teams[i]) if i < teams.size() else i])
	elif MapGen.MAPS.has(map_id):
		var sz := MapGen.CLASSIC
		out = [[Vector2i(6, 6), 0], [sz - Vector2i(11, 10), 1]]
	return out
