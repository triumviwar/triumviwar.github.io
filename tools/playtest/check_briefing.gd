extends SceneTree
## A check (playtest-campaign-brood): every mission's BRIEFING, each side you may lead, at this window size: START and
## BACK on screen. xvfb-run ... --resolution 1280x720 --script res://tools/playtest/check_briefing.gd -- [phone]
func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("lang="):
			Loc.set_lang(a.substr(5))
	if OS.get_cmdline_user_args().has("phone"):
		Settings.device = "phone"
		Settings.apply()
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred(main)


func _run(main) -> void:
	for i in 5:
		await process_frame
	var bad := 0
	var vs := root.get_visible_rect().size
	for mid in Campaign.mission_ids():
		var m := Campaign.mission(String(mid))
		var sides := Campaign.solo_sides(m)
		if sides.is_empty():
			sides = [""]
		for sd in sides:
			CampaignMenu.solo_pick = String(sd)
			CampaignMenu.briefing(main, String(mid))
			for i in 4:
				await process_frame
			var names := ["Briefing_Start", "Diff_easy", "Diff_hard"]
			for x in root.find_children("Side_*", "Button", true, false):
				names.append(String(x.name))
			for nm in names:
				var b: Control = root.find_child(nm, true, false)
				var ok := b != null and Rect2(Vector2.ZERO, vs).encloses(b.get_global_rect())
				if not ok:
					bad += 1
				print("BRIEF %s %s %s %s" % [mid, sd, nm, "ok" if ok else "OFF SCREEN %s" % (b.get_global_rect() if b else "missing")])
			if String(mid) == "a05_specimens" and DisplayServer.get_name() != "headless":
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("res://docs/shots/playtest_2026_11_21/campaign_brood/check_briefing_a05_%s_%dx%d.png" % [sd, int(vs.x), int(vs.y)])
	print("BRIEFINGS %s" % ("OK" if bad == 0 else "FAIL %d" % bad))
	quit()
