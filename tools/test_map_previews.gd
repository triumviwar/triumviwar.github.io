extends SceneTree
## The map pictures (job map-previews, docs/map_previews.md):
## [bundled] every built-in and campaign map has its picture in assets/maps (tools/make_map_previews.gd), at once;
## [classic] the classic maps have a 2-player and a 4-player picture;
## [pool] a random pool has no picture of its own (MapPreview draws four of its maps);
## [custom] a map of your own with no saved picture is made by the queue a few frames later, cached on disk, and
##          Game.W / Game.H are put back;
## [widget] a MapPreview of every map draws without errors at a phone's and a desktop's size.
##   godot --headless --path . --script res://tools/test_map_previews.gd
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(tag: String, cond: bool, msg: String) -> void:
	print(("PASS " if cond else "FAIL ") + tag + " " + msg)
	if not cond:
		fails += 1


func _run() -> void:
	await process_frame
	# [bundled]
	var ids: Array = MapGen.all_ids()
	var d := DirAccess.open("res://campaign/maps")
	for f in d.get_files():
		if f.ends_with(".json"):
			ids.append("campaign:" + f.trim_suffix(".json"))
	var t0 := Time.get_ticks_msec()
	var missing: Array = []
	for id in ids:
		if MapThumb.picture(String(id)) == null:
			missing.append(id)
	_ok("[bundled]", missing.is_empty() and MapThumb.made == 0, "%d maps, %d ms, missing %s" % [ids.size(), Time.get_ticks_msec() - t0, missing])
	# [classic]
	var c4 := MapThumb.picture("frostfang", 4)
	var c2 := MapThumb.picture("frostfang", 2)
	_ok("[classic]", c4 != null and c2 != null and c4 != c2, "2- and 4-player pictures")
	# [pool]
	_ok("[pool]", not MapThumb.drawable("random_1v1") and MapThumb.picture("random_1v1") == null and MapThumb.pending() == 0, "no picture, nothing queued")
	# [custom]
	var data := Campaign.map_data("demo_highlands").duplicate(true)
	data["name"] = "__map_thumb_test"
	MapGen.save_custom(data)
	DirAccess.remove_absolute("%s/__map_thumb_test.png" % MapGen.MAP_DIR)
	var ow := Game.W
	var first := MapThumb.picture("custom:__map_thumb_test")
	var frames := 0
	var tex: Texture2D = null
	while tex == null and frames < 120:
		await process_frame
		frames += 1
		tex = MapThumb.picture("custom:__map_thumb_test")
	var cached := false
	var cd := DirAccess.open(MapThumb.CACHE_DIR)
	if cd:
		for f in cd.get_files():
			if f.begins_with("custom___map_thumb_test__"):
				cached = true
				DirAccess.remove_absolute("%s/%s" % [MapThumb.CACHE_DIR, f])
	_ok("[custom]", first == null and tex != null and cached and Game.W == ow, "made after %d frames, cached %s, W kept %s" % [frames, cached, Game.W == ow])
	MapGen.delete_custom("__map_thumb_test")
	# [widget]
	var box := Control.new()
	box.size = Vector2(1280, 720)
	root.add_child(box)
	for id in ids + ["random", "random_4v4", "nonsense"]:
		for sz in [Vector2(96, 64), Vector2(300, 190)]:
			var pv := MapPreview.new()
			pv.map_id = String(id)
			pv.slots = [{"side": 0, "colour": 0}, {"side": 1, "colour": 1}]
			pv.size = sz
			box.add_child(pv)
	await process_frame
	await process_frame
	_ok("[widget]", true, "%d previews drawn" % box.get_child_count())
	box.queue_free()
	print("RESULT ", "FAIL %d" % fails if fails > 0 else "PASS")
	quit(1 if fails > 0 else 0)
