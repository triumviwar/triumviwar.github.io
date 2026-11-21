extends SceneTree
## IRONMAN (the owner 2026-11-21: "Campaign in Ironman mode you can't save load scam"): a campaign with only the one
## save that goes on where you left each mission.
##   - turning it on clears every mission's own SAVE and CHECKPOINT;
##   - the match menu has no SAVE / LOAD SAVE; SAVE and a CHECKPOINT write nothing of their own (where you left it, yes);
##   - a CHOICE is saved at once (where you left it holds the choice);
##   - quitting keeps where you left it; the briefing's START is shut (CONTINUE instead), and shut for good once won;
##   - without IRONMAN all of it is as before.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_ironman.gd
## Prints CHECK lines, then "campaign_ironman: N failures"; exit code 1 on a failure. (Puts user://campaign.json back.)
var main: Node
var fails := 0
var _kept := ""
const MID := "p01_leaf"


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-70s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	if FileAccess.file_exists(Campaign.PROGRESS):
		_kept = FileAccess.get_file_as_string(Campaign.PROGRESS)
	Campaign.save_progress({"reached": [MID], "done": {}, "difficulty": "normal"})
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _finish() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	if _kept != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept)
		f.close()
	MissionSave.clear_all(MID)
	print("campaign_ironman: %d failures" % fails)
	quit(1 if fails > 0 else 0)


func _start() -> Game:
	main.start(Campaign.make_cfg(MID, "solo"))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	return g


func _labels(g: Game) -> Array:
	return g.hud._menu_list().map(func(b: Dictionary) -> String: return String(b["label"]))


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	await process_frame
	MissionSave.clear_all(MID)
	# without IRONMAN: as before
	var g: Game = await _start()
	check("off: the menu has SAVE and LOAD SAVE", _labels(g).has("SAVE") and _labels(g).has("LOAD SAVE"), str(_labels(g)))
	main.mission_save_now()
	await _frames(3)
	check("off: SAVE writes the mission's own save", MissionSave.has(MID, "save"))
	check("off: START is open", CampaignMenu.ironman_lock(MID) == "")
	main._quit_match()
	await _frames(3)
	# IRONMAN on: the kept saves go
	Campaign.set_ironman()
	check("on: IRONMAN kept in the progress", Campaign.ironman())
	check("on: turning it on clears the mission's SAVE", not MissionSave.has(MID, "save"))
	g = await _start()
	check("on: the menu has no SAVE / LOAD SAVE", not _labels(g).has("SAVE") and not _labels(g).has("LOAD SAVE"), str(_labels(g)))
	main.mission_save_now()
	main.mission_checkpoint()
	await _frames(3)
	check("on: SAVE and a CHECKPOINT write nothing of their own", not MissionSave.has(MID, "save") and not MissionSave.has(MID, "checkpoint"))
	MissionSave.clear(MID, "auto")
	g.mission.choose("families", "leave")
	await _frames(4)
	var d := MissionSave.peek(MID, "auto")
	check("on: a CHOICE is saved at once", not d.is_empty())
	check("on: ...and where you left it holds the choice", String(d.get("mission", "")).contains("families"), String(d.get("mission", "")).substr(0, 80))
	main._quit_match()
	await _frames(3)
	check("on: quitting keeps where you left it", MissionSave.has(MID, "auto"))
	check("on: the briefing's START is shut while the mission goes on", CampaignMenu.ironman_lock(MID).contains("where you left it"))
	var p := Campaign.progress()
	p["done"][MID] = {"won_by": "crown"}
	Campaign.save_progress(p)
	MissionSave.clear(MID, "auto")
	check("on: a mission won is played for good", CampaignMenu.ironman_lock(MID).contains("for good"))
	_finish()
