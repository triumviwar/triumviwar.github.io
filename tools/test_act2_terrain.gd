extends SceneTree
## Act 2's Brazilian ground looks (docs/act2_terrain_art.md): VÁRZEA, HIGHLANDS and SERTÃO.
## Every ground set, cliff face, tree, bush, decoration and group the three biomes name has its
## picture; the data file (TerrainAct2) matches the pictures; the map editor lists the biomes and
## the examples; each demo map loads, builds its ground and passes the map editor's CHECK.
##   godot --headless --script res://tools/test_act2_terrain.gd

const NEW := ["varzea", "highlands", "sertao"]

var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _pic(set_name: String) -> String:
	var good: Array = TerrainData.GOOD.get(set_name, TerrainData2.GOOD.get(set_name, TerrainAct2.GOOD.get(set_name, [0])))
	return "res://assets/terrain/%s_%d.png" % [set_name, good[0]]


func _run() -> void:
	# --- the data file and its pictures
	for s in TerrainAct2.COUNTS:
		var n: int = TerrainAct2.COUNTS[s]
		var want := 32 if (String(s).ends_with("_face") or String(s).ends_with("_top")) else 64
		var ok := n >= 2
		for k in n:
			var p := "res://assets/terrain/%s_%d.png" % [s, k]
			if not ResourceLoader.exists(p):
				ok = false
				continue
			var t: Texture2D = load(p)
			ok = ok and t.get_width() == want and t.get_height() == want
		check(ok, "%s: %d pictures of %d px" % [s, n, want])
		check((TerrainAct2.GOOD[s] as Array).size() == n, "%s: every variant ranked" % s)
		check(not TerrainData.COUNTS.has(s) and not TerrainData2.COUNTS.has(s), "%s: a new name (no clash with the older atlases)" % s)
	for nm in TerrainAct2.PROPS:
		var p := "res://assets/props/%s.png" % nm
		var ok := ResourceLoader.exists(p)
		if ok:
			var t: Texture2D = load(p)
			var a: Array = TerrainAct2.PROPS[nm]
			ok = t.get_width() == int(a[0]) and t.get_height() == int(a[1])
		check(ok and not PropData.PROPS.has(nm), "decoration %s: its picture, its size, a new name" % nm)
		check(TerrainAct2.KIND.has(nm) and MapEditor.KIND_ORDER.has(TerrainAct2.KIND[nm]), "decoration %s: in a palette group" % nm)

	# --- the biomes
	for b in NEW:
		check(MapGen.BIOMES.has(b), "biome %s exists" % b)
		var bi: Dictionary = MapGen.BIOMES[b]
		for key in ["base", "high", "face", "water", "ford"]:
			check(ResourceLoader.exists(_pic(String(bi[key]))), "%s: its %s ground %s has a picture" % [b, key, bi[key]])
		for s in bi["low"]:
			check(ResourceLoader.exists(_pic(String(s))), "%s: low ground %s has a picture" % [b, s])
		for key in ["tree_art", "bush_art", "scatter"]:
			for nm in bi[key]:
				check(MapGen.has_prop(String(nm)) and ResourceLoader.exists("res://assets/props/%s.png" % nm),
					"%s: %s %s is a decoration" % [b, key, nm])
		for kit in bi["kits"]:
			var ok: bool = MapGen.KITS.has(kit)
			for it in MapGen.KITS.get(kit, []):
				ok = ok and MapGen.has_prop(String(it[0]))
			check(ok, "%s: group %s and its decorations exist" % [b, kit])
		check(MapEditor.BIOME_LIST.has(b), "the map editor's LAND lists %s" % b)
		check(Defs.BIOME_AVOID.has(b), "%s: the lobby knows which colours blend into it" % b)
	check(MapEditor.biome_title("varzea") == "VÁRZEA" and MapEditor.biome_title("sertao") == "SERTÃO"
		and MapEditor.biome_title("highlands") == "HIGHLANDS", "the editor spells the names with their accents")
	check(MapGen.prop_cells("araucaria") == 1 and MapGen.prop_cells("mist_wisp") == 0 and MapGen.prop_cells("oak") == 1,
		"decoration feet read from both atlases")

	# --- the demo maps
	for ex in MapGen.EXAMPLES:
		var d := Campaign.map_data(String(ex))
		check(not d.is_empty(), "%s loads" % ex)
		if d.is_empty():
			continue
		var bn := String(d.get("biome", ""))
		check(NEW.has(bn), "%s is a %s map" % [ex, bn])
		var missing := 0
		for it in d.get("props", []):
			if not MapGen.has_prop(String(it[0])):
				missing += 1
		check(missing == 0, "%s: every decoration exists" % ex)
		var g := Game.new()
		g.map_id = "campaign:" + String(ex)
		g.demo = true
		g.edit_mode = true
		g.factions = ["crown", "brood"]
		g.sides = [0, 1]
		root.add_child(g)
		await process_frame
		check(g.mapgen.biome_a == bn, "%s builds on the %s ground" % [ex, bn])
		var placed: int = g.mapgen.props.filter(func(p: Dictionary) -> bool: return not p["dead"]).size()
		check(placed >= int((d["props"] as Array).size() * 0.8), "%s: %d of %d decorations stand" % [ex, placed, (d["props"] as Array).size()])
		var waters := 0
		for i in Game.W * Game.H:
			waters += g.water[i]
		check(waters > 30, "%s has water (%d cells)" % [ex, waters])
		var halls: Array = g.base_sites.filter(func(s: Vector2i) -> bool: return not g.starts.has(s))
		var probs := MapCheck.run(g, g.starts, halls, String(d["cells"]), String(d["mirror"]))
		var bad := probs.filter(func(p: Dictionary) -> bool: return not p["warn"])
		for p in probs:
			print("      %s %s" % ["warning:" if p["warn"] else "PROBLEM:", p["text"]])
		check(bad.is_empty(), "%s passes the map editor's CHECK" % ex)
		# the ground picture came out of the biome's own sets (the minimap's colours)
		var mc: Color = g.minimap_img.get_pixel(Game.W / 2 - 20, Game.H / 2 + 4) if g.minimap_img else Color.BLACK
		check(mc.a > 0.5, "%s: the ground was painted" % ex)
		g.queue_free()
		await process_frame
	print("%d failures" % fails)
	quit(1 if fails > 0 else 0)
