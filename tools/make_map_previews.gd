extends SceneTree
## The map pictures that come with the game (job map-previews, docs/map_previews.md): every built-in map's
## and every campaign map's minimap made by MapThumb.render and saved to assets/maps/<id>.png (campaign_<name>.png) (the classic maps also <id>_4p.png, their
## four-corner layout). Run again after changing a map or the map generator, then import (godot --headless
## --import) so the new pictures get their .import files:
##   godot --headless --script res://tools/make_map_previews.gd [-- ids...]


func _initialize() -> void:
	_run.call_deferred(OS.get_cmdline_user_args())


func _run(ids: Array) -> void:
	if ids.is_empty():
		ids = MapGen.all_ids()
		var d := DirAccess.open("res://campaign/maps")
		for f in d.get_files():
			if f.ends_with(".json"):
				ids.append("campaign:" + f.trim_suffix(".json"))
	DirAccess.make_dir_recursive_absolute(MapThumb.BUNDLE_DIR)
	for id in ids:
		var counts: Array = [2, 4] if MapGen.MAPS.has(id) else [2]
		for n in counts:
			var t0 := Time.get_ticks_msec()
			var img := MapThumb.render(String(id), n)
			if img == null:
				print("preview ", id, " FAILED")
				continue
			var out := "%s/%s.png" % [MapThumb.BUNDLE_DIR, MapThumb.bundle_name(String(id), n)]
			img.save_png(out)
			print("preview %s %dx%d %d ms" % [MapThumb.pic_id(String(id), n), img.get_width(), img.get_height(), Time.get_ticks_msec() - t0])
		await process_frame
	quit()
