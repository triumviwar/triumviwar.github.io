extends SceneTree
## Pictures of the campaign pages (the WAR TABLE with the prologue's still, the BRIEFING, the hub), for checking the
## stills keep their shape and the campaign's own backdrop covers the screen (the owner, 2026-11-15 21:01).
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1908x932 --script res://tools/shot_campaign_pages.gd -- out:/abs/dir
var main: Node
var out := "user://camp_shots"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("out:"):
			out = a.substr(4)
	DirAccess.make_dir_recursive_absolute(out)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run()


func _snap(name: String) -> void:
	for i in 20:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(out.path_join(name + ".png"))
	print("SHOT ", name)


func _run() -> void:
	for i in 20:
		await process_frame
	CampaignMenu.line = "prologue"
	CampaignMenu.pick = "p01_leaf"
	CampaignMenu.war_table(main)
	await _snap("war_table")
	CampaignMenu.briefing(main, "p01_leaf")
	await _snap("briefing")
	quit()
