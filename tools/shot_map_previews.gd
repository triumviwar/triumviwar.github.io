extends SceneTree
## Contact sheets of every map's picture (MapPreview, job map-previews, docs/map_previews.md): the classic maps
## (2 and 4 players), the named maps, the campaign maps, the random pools; then the skirmish lobby with a map
## picked, at desktop and phone sizes. Also times how long the pictures take to make (none bundled: the cache is
## cleared first, so every picture not in assets/maps is made here).
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1600x1000 --script res://tools/shot_map_previews.gd -- <outdir> [pc|mobile]
var out := ""
var dev := "pc"
const PER_PAGE := 12


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	out = a[0] if a.size() > 0 else "res://docs/shots/map_previews"
	dev = a[1] if a.size() > 1 else "pc"
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	Settings.load_all()
	Settings.device = dev
	Settings.apply()
	DirAccess.make_dir_recursive_absolute(out)
	_run.call_deferred()


func _entries() -> Array:
	var e: Array = []            # [id, players, label]
	for id in MapGen.MAPS:
		e.append([id, 2, MapGen.display_name(id) + " (1v1)"])
		e.append([id, 4, MapGen.display_name(id) + " (4 players)"])
	for id in MapData.NAMED:
		e.append([id, MapGen.max_players(id), MapGen.label(id)])
	var d := DirAccess.open("res://campaign/maps")
	if d:
		var files := Array(d.get_files()).filter(func(f: String) -> bool: return f.ends_with(".json"))
		files.sort()
		for f in files:
			var nm := String(f).trim_suffix(".json")
			e.append(["campaign:" + nm, 0, "campaign: " + nm])
	for p in MapGen.POOLS:
		e.append([p[0], 2, String(p[1])])
	return e


func _slots(n: int) -> Array:
	var s: Array = []
	for i in n:
		s.append({"side": 0 if i < n / 2 else 1, "colour": i % Defs.PALETTE.size()})
	return s


func _run() -> void:
	await process_frame
	var es := _entries()
	var page := 0
	var i := 0
	var t0 := Time.get_ticks_msec()
	while i < es.size():
		var bg := ColorRect.new()
		bg.color = UiStyle.BG
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(bg)
		var grid := GridContainer.new()
		grid.columns = 4
		grid.position = Vector2(10, 10)
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 6)
		bg.add_child(grid)
		for k in PER_PAGE:
			if i >= es.size():
				break
			var e: Array = es[i]
			i += 1
			var cell := VBoxContainer.new()
			var pv := MapPreview.new()
			pv.map_id = String(e[0])
			if int(e[1]) > 0:
				pv.slots = _slots(int(e[1]))
			else:
				pv.show_starts = false
			pv.custom_minimum_size = Vector2(300, 175)
			cell.add_child(pv)
			var l := UiStyle.text(String(e[2]), 13, UiStyle.TEXT)
			l.custom_minimum_size = Vector2(300, 0)
			l.clip_text = true
			cell.add_child(l)
			grid.add_child(cell)
		# wait for the queued pictures (one a frame)
		var guard := 0
		while (MapThumb.pending() > 0 or _worker_alive()) and guard < 2000:
			await process_frame
			guard += 1
		for f in 4:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png("%s/sheet_%d_%s.png" % [out, page, dev])
		print("sheet ", page)
		page += 1
		bg.queue_free()
		await process_frame
	print("made %d pictures in %d ms" % [MapThumb.made, Time.get_ticks_msec() - t0])
	# the lobby: one map picked, then a random pool
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await create_timer(0.5).timeout
	for id in ["frostfang", "twin_crowns", "random_1v1"]:
		main.lobby["map"] = id
		main.show_skirmish()
		for f in 6:
			await process_frame
		await create_timer(0.4).timeout
		root.get_viewport().get_texture().get_image().save_png("%s/lobby_%s_%s.png" % [out, id, dev])
		print("lobby ", id)
	quit()


func _worker_alive() -> bool:
	return MapThumb._worker != null and is_instance_valid(MapThumb._worker)
