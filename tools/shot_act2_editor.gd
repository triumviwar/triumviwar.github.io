extends SceneTree
## The map editor with Act 2's biomes (docs/act2_terrain_art.md): the LAND list and LOAD's
## EXAMPLES, and the sertão example opened in the editor.
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1600x900 --script res://tools/shot_act2_editor.gd -- /abs/dir
var main: Node
var out := ""


func _initialize() -> void:
	out = OS.get_cmdline_user_args()[0]
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _snap(name: String) -> void:
	await create_timer(0.6).timeout
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, name])


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(out)
	await create_timer(0.5).timeout
	main.show_map_editor("", Campaign.map_data("demo_sertao"))
	await create_timer(1.0).timeout
	var ed = main._editor
	await _snap("editor_sertao")
	ed._show_biomes(false)
	await _snap("editor_land")
	ed._build_ui()
	ed._show_load()
	await _snap("editor_load")
	print("wrote %s/editor_*.png" % out)
	quit()
