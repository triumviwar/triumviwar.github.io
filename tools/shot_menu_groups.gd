extends SceneTree
## The main menu's levels as pictures (menu-groups, docs/menu_groups.md; kept in docs/shots/menu_groups/):
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1920x1080 --script res://tools/shot_menu_groups.gd -- <outdir> [pc|mobile] [prefix] [lang] [cross]
## writes <prefix>top.png, <prefix>offline.png, <prefix>online.png (and <prefix>top_continue.png with a pretend saved
## match). "cross" outlines the cross's keep-out box (Main.menu_keepout) in red, to check the layout by eye.
var main
var out := "/tmp"
var prefix := ""
var lang := ""
var cross := false


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	if a.size() > 0:
		out = a[0]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	Settings.load_all()
	Settings.device = a[1] if a.size() > 1 else "pc"
	prefix = a[2] if a.size() > 2 else ""
	lang = a[3] if a.size() > 3 else ""
	cross = a.size() > 4 and a[4] == "cross"
	Settings.apply()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _snap(name: String) -> void:
	if cross:
		var box := ReferenceRect.new()
		box.border_color = Color(1, 0.1, 0.1)
		box.border_width = 3
		box.editor_only = false
		var r: Rect2 = main.menu_keepout(main._menu_grid.size)
		box.position = r.position
		box.size = r.size
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main._menu_grid.add_child(box)
	await create_timer(0.8).timeout
	var p := "%s/%s%s.png" % [out, prefix, name]
	root.get_viewport().get_texture().get_image().save_png(p)
	print("wrote ", p)


func _level(g: String) -> void:
	main.menu_group = g
	main.show_menu()
	var c: Button = main.menu_buttons.get("continue")
	if c:
		c.queue_free()                 # (the picture without CONTINUE)
		main.menu_buttons.erase("continue")
		main._layout_menu()


func _run() -> void:
	await create_timer(1.5).timeout
	if lang != "" and lang != "-":
		Settings.language = lang     # (not saved)
		Loc.set_lang(lang)
	for g in ["", "offline", "online"]:
		_level(g)
		await _snap("top" if g == "" else g)
	_level("")
	var b: Button = main._menu_button("continue", {"version": main.version, "cfg": {"slots": [{"faction": "crown"}, {"faction": "clockwork"}]}, "clock": 754}, Settings.pc())
	main.menu_buttons["continue"] = b
	main._menu_grid.add_child(b)
	main._layout_menu()
	await _snap("top_continue")
	quit()
