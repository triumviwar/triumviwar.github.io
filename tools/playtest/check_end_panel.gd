extends SceneTree
## A check (playtest-campaign-brood): a mission's end panel with every objective listed fits the screen (its
## buttons on screen). xvfb-run ... --script res://tools/playtest/check_end_panel.gd -- [mission=b01_specimen] [side=sire]
var mid := "b01_specimen"
var side := "sire"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("mission="): mid = a.substr(8)
		if a.begins_with("side="): side = a.substr(5)
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred(main)


func _run(main) -> void:
	await process_frame
	main.start(Campaign.make_cfg(mid, "solo", "p1", false, side))
	for i in 10:
		await process_frame
	var g: Game = main.game
	var r: MissionRun = g.mission
	for k in r.obj:
		r.obj[k] = "done"
	r.flags = {"clutch": "saved", "saved": "some", "saved_n": 15, "pieter": "lost", "rival": "standing", "eggs": "taken"}
	CampaignMenu._end_panel(main, g, 0, "", "a03_plateau", true, side)
	for i in 6:
		await process_frame
	var vs := root.get_visible_rect().size
	var bad := 0
	for b in root.find_children("End_*", "Button", true, false):
		var rc: Rect2 = (b as Control).get_global_rect()
		var ok := Rect2(Vector2.ZERO, vs).encloses(rc)
		print("END BUTTON %s %s %s" % [b.name, rc, "on screen" if ok else "OFF SCREEN"])
		if not ok:
			bad += 1
	await RenderingServer.frame_post_draw
	if DisplayServer.get_name() != "headless":
		root.get_texture().get_image().save_png("res://docs/shots/playtest_2026_11_21/campaign_brood/check_end_panel_%dx%d.png" % [int(vs.x), int(vs.y)])
	print("END PANEL %s" % ("OK" if bad == 0 else "FAIL %d off screen" % bad))
	quit()
