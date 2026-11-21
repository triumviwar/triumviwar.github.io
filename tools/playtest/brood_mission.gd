extends SceneTree
## PLAYTEST (playtest-campaign-brood): a Naturalist-line mission played from the MAIN MENU by a "player" with real
## input (pt_lib / pt_hand): CAMPAIGN, the Naturalist, the SPECIMEN CHART, the mission, BRIEFING, the side and the
## DIFFICULTY, START, the opening (watched with NEXT, or skipped), the match, the end screen and where it leads.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 --script res://tools/playtest/brood_mission.gd --
##     mission=b01_specimen [side=<id>] [diff=easy|normal|hard] [who=careful|idle|reckless|probe|fast|confused]
##     [choice=<choice id>:<option>,...] [lang=en] [phone] [speed=3] [until=<game s>] [stage=<hub stage>] [opening=watch|skip|esc]
##     [shots=0|1] [tag=<name>]
## Players (who=): careful plays the mission's own steps; idle sits there (the passive loss / the clock); reckless sends
## the hero into the enemy (the loss on purpose); probe opens the match, lists the cards, pauses, resumes, quits to menu.
const PT := preload("res://tools/playtest/pt_lib.gd")
const HAND := preload("res://tools/playtest/pt_hand.gd")
const HUB := preload("res://tools/playtest/brood_hub.gd")
const BRAINS := preload("res://tools/playtest/brood_brains.gd")

var pt
var hand
var main: Node
var args := {"mission": "b01_specimen", "side": "", "diff": "normal", "who": "careful", "choice": "", "lang": "en",
	"speed": "3", "until": "1500", "stage": "", "opening": "watch", "shots": "1", "tag": ""}
var phone := false


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "phone":
			phone = true
		elif a.contains("="):
			args[a.get_slice("=", 0)] = a.substr(a.find("=") + 1)
	if args["stage"] == "":
		args["stage"] = {"b01_specimen": "fresh", "a03_plateau": "b01_saved", "a05_specimens": "a03_party"}.get(args["mission"], "fresh")
	if args["tag"] == "":
		args["tag"] = "%s_%s_%s_%s%s" % [args["mission"].get_slice("_", 0), args["side"] if args["side"] != "" else "main", args["who"], args["diff"], "_" + args["lang"] if args["lang"] != "en" else ""] + ("_phone" if phone else "")
	_prepare()
	pt = PT.new(self, ("res://docs/shots/playtest_2026_11_21/campaign_brood/" + args["tag"]) if args["shots"] == "1" else "")
	pt.touch = phone
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _prepare() -> void:
	var cfg := ConfigFile.new()
	cfg.load("user://settings.cfg")
	cfg.set_value("input", "device", "phone" if phone else "pc")
	cfg.set_value("ui", "language", args["lang"])
	cfg.save("user://settings.cfg")
	var p := HUB.progress_for(args["stage"])
	p["difficulty"] = "normal"
	var f := FileAccess.open("user://campaign.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(p))
	f.close()


func _run() -> void:
	await pt.wait(1.0)
	await pt.past_crash_page()
	await pt.tap("Menu_campaign", 8.0)
	await pt.wait(0.6)
	await pt.tap("Line_naturalist")
	await pt.wait(0.5)
	await pt.tap("Hotspot_war_table")
	await pt.wait(0.5)
	if not await pt.tap("Mission_" + args["mission"]):
		pt.note("FAIL", "mission %s not on the war table: %s" % [args["mission"], pt.button_names()])
		_end()
		return
	await pt.wait(0.4)
	await pt.tap("Campaign_Go")
	await pt.wait(0.6)
	if args["side"] != "":
		await pt.tap("Side_" + args["side"])
		await pt.wait(0.4)
	await pt.tap("Diff_" + args["diff"])
	await pt.wait(0.4)
	await pt.shot("briefing")
	if args.get("fast", "") == "1":
		# the button masher: START three times in a row, then NEXT as fast as the mouse goes
		var st = pt.find("Briefing_Start")
		if st:
			var c: Vector2 = pt.rect_of(st).get_center()
			for i in 3:
				await pt.click(c, MOUSE_BUTTON_LEFT, i > 0)
		for i in 30:
			var nx = pt.find("Show_NEXT")
			if nx == null:
				break
			await pt.click(pt.rect_of(nx).get_center(), MOUSE_BUTTON_LEFT, i % 2 == 1)
		pt.note("FAST", "after mashing: StillShows %d, games %d" % [root.find_children("StillShow", "", true, false).size(), root.find_children("*", "Game", true, false).size()])
	else:
		await pt.tap("Briefing_Start")
	await _opening()
	# the match
	var t := 0.0
	while (main.game == null or not is_instance_valid(main.game) or main.game.mission == null) and t < 30.0:
		await pt.wait(0.2)
		t += 0.2
	if main.game == null or main.game.mission == null:
		pt.note("FAIL", "no match after START")
		_end()
		return
	var g: Game = main.game
	hand = HAND.new(pt, g)
	await pt.wait(1.0)
	await pt.shot("match_start")
	var brain = BRAINS.new(pt, hand, g, args, self)
	await brain.play()
	await _after_end(g)
	_end()


func _opening() -> void:
	var t := 0.0
	while root.find_child("StillShow", true, false) == null and t < 4.0:
		await pt.wait(0.1)
		t += 0.1
	var n := 0
	var seen: Array = []
	while root.find_child("StillShow", true, false) != null and n < 40:
		var txt: String = pt.labels_text().replace("\n", " | ")
		if not seen.has(txt):
			seen.append(txt)
			pt.note("OPENING", "%d: %s" % [n, txt.substr(0, 300)])
			if n < 14:
				await pt.shot("opening_%02d" % n)
		match args["opening"]:
			"skip":
				await pt.tap("Show_SKIP", 1.0)
			"esc":
				await pt.key(KEY_ESCAPE)
			_:
				if n == 3:
					await pt.click(pt.vs() * Vector2(0.5, 0.3))     # (a click on the picture: the next line)
				else:
					await pt.tap("Show_NEXT", 1.0)
		await pt.wait(0.5)
		n += 1


func _after_end(g) -> void:
	# the ending show (won) and the end panel
	await pt.wait(1.0)
	if not is_instance_valid(g):
		return
	var n := 0
	while _show_up() and n < 40:
		var txt: String = pt.labels_text().replace("\n", " | ")
		pt.note("ENDING", "%d: %s" % [n, txt.substr(0, 300)])
		if n < 8:
			await pt.shot("ending_%02d" % n)
		await pt.tap("Show_NEXT", 1.0)
		await pt.wait(0.4)
		n += 1
	await pt.wait(1.0)
	await pt.shot("end_panel")
	pt.note("END", "end panel: " + pt.labels_text().replace("\n", " | ").substr(0, 700))
	pt.note("END", "buttons: " + str(pt.button_names()))
	var p := Campaign.progress()
	pt.note("PROGRESS", JSON.stringify(p.get("done", {}).get(args["mission"], {})) + " reached=" + str(p.get("reached", [])))
	# where the end panel leads: NEXT MISSION (its briefing), else CAMPAIGN (the hub as the mission left it)
	if pt.find("End_NEXT_MISSION") != null:
		await pt.tap("End_NEXT_MISSION")
		await pt.wait(1.0)
		await pt.shot("next_mission_briefing")
		pt.note("NEXT", pt.labels_text().replace("\n", " | ").substr(0, 300))
		await pt.tap("BACK", 2.0)
		await pt.wait(0.8)
	elif pt.find("End_CAMPAIGN") != null:
		await pt.tap("End_CAMPAIGN")
		await pt.wait(1.0)
	await pt.shot("after_end_hub")
	pt.note("HUB", pt.labels_text().replace("\n", " | ").substr(0, 300))


func _end() -> void:
	pt.report_errors(args["tag"])
	print("PT END %s clicks=%d covered=%d hand_fails=%d errors=%d" % [args["tag"], pt.clicks, pt.misses, hand.fails if hand else -1, pt.errs.size()])
	Engine.time_scale = 1.0
	quit()


func _show_up() -> bool:
	for n in root.find_children("*", "Control", true, false):
		if n is StillShow and is_instance_valid(n) and not n.is_queued_for_deletion():
			return true
	return false
