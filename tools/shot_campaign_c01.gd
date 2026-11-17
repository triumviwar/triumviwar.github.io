extends SceneTree
## Pictures of the Clockwork prologue's shows (docs/campaign_c01_build.md): the opening's first still with its line, the
## BELLS choice panel, the ending's first still, and the end screen (NUREMBERG IS LOST). The parts in play are filmed by
## tools/sim_campaign_c01.gd (shots=). Needs a window:
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --fixed-fps 30 --resolution 1280x720 --script res://tools/shot_campaign_c01.gd -- out=<dir>
const MID := "c01_thirteenth"
var main: Node
var out := "res://docs/shots/campaign_c01"
var _kept := ""


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("out="):
			out = a.substr(4)
	if FileAccess.file_exists(Campaign.PROGRESS):
		_kept = FileAccess.get_file_as_string(Campaign.PROGRESS)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _shot(name: String) -> void:
	for i in 6:
		await process_frame
	var img := root.get_viewport().get_texture().get_image()
	img.save_jpg("%s/%s.jpg" % [ProjectSettings.globalize_path(out) if out.begins_with("res://") else out, name], 0.85)
	print("SHOT ", name)


func _step(g: Game, to: float) -> void:
	g.clock = to
	g.mission._tick_turning()
	g.mission._run_triggers()
	g.mission._check_objectives()


func _run() -> void:
	await process_frame
	var m := Campaign.mission(MID)
	var sh := StillShow.play(main.ui_layer, m, Campaign.show_pages(m, "opening"), func() -> void: pass)
	await _shot("0_opening")
	sh.queue_free()
	main.start(Campaign.make_cfg(MID, "solo"))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	for tid in ["dusk"]:
		for tr in r.data["triggers"]:
			if tr["id"] == tid:
				r.fire(tr)
	r.set_light("winter_dusk", 0.0)
	for tr in r.data["triggers"]:
		if String(tr["id"]) in ["found", "bells"]:
			r.fire(tr)
	g.camera.position = r.area_rect("mill_island").get_center()
	await _shot("7_bells_choice")
	r.choose("bells", "quiet")
	for tr in r.data["triggers"]:
		if String(tr["id"]) in ["night"]:
			r.fire(tr)
	r.set_light("winter_night", 0.0)
	_step(g, 600.0)
	_step(g, 601.0)
	r.flags["drawings"] = "taken"
	var hw: Unit = r.tagged("hollweg")[0]
	hw.position = r.area_rect("gate_in").get_center()
	g._rebuild_hash()
	r.counters["saved"] = 41
	r.counters["townsfolk"] = 58
	var fall := float(r.clocks["fall"])
	_step(g, fall - 74.0)
	r.choose("gate", "pattern")
	_step(g, fall + 0.1)
	g.camera.position = r.area_rect("gate_in").get_center()
	await _shot("8_stroke_bells")
	_step(g, fall + 18.0)
	await create_timer(1.8).timeout
	await _shot("9_ending")
	var show: Node = main.ui_layer.find_child("StillShow", true, false)
	for i in 12:
		if show and is_instance_valid(show) and not show.is_queued_for_deletion():
			(show as StillShow).next()
	await create_timer(0.5).timeout
	await _shot("10_end_screen")
	if _kept != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept)
		f.close()
	quit()
