extends SceneTree
## Pictures of the hubs that grow (job hubs-grow, docs/hubs_grow.md): each hub at several points of the story (a made-up
## progress for each), its new rooms with the people in them, a counter open, and a briefing's FROM THE HUB list.
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_hubs_grow.gd -- <outdir> [pc|mobile]
## (Leaves user://campaign.json as it was.)
var main
var out := ""
var _kept := ""


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	out = a[0]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	if FileAccess.file_exists(Campaign.PROGRESS):
		_kept = FileAccess.get_file_as_string(Campaign.PROGRESS)
	Settings.load_all()
	Settings.device = a[1] if a.size() > 1 else "pc"
	Settings.apply()
	DirAccess.make_dir_recursive_absolute(out)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _snap(name: String, wait := 0.8) -> void:
	await create_timer(wait).timeout
	await process_frame
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, name])
	print("shot ", name)


func _prog(done: Dictionary, hub := {}) -> void:
	var p := {"reached": [], "done": {}}
	for mid in done:
		var fl: Dictionary = (done[mid] as Dictionary).duplicate()
		var side := String(fl.get("side", Campaign.seat_side(Campaign.mission(mid), "solo", "p1")))
		fl.erase("side")
		p["done"][mid] = {"won_by": side, "side": side, "mode": "solo", "played": 1, "flags": fl}
	p["hub"] = hub
	Campaign.save_progress(p)


func _hub(line: String, room: String, name: String) -> void:
	CampaignMenu.line = line
	HubRoomsUi.room_of = {line: room}
	main.show_campaign()
	await _snap(name)


func _press(n: String) -> void:
	var b: Button = main.menu.find_child(n, true, false)
	if b:
		b.pressed.emit()


func _run() -> void:
	await create_timer(0.5).timeout
	# THE CROWN
	_prog({})
	await _hub("prologue", "study", "crown_0_start")
	_prog({"p01_leaf": {"families": "save"}}, {"earned": {"p01_leaf": 3}})
	await _hub("prologue", "study", "crown_1_after_p01_study")
	await _hub("prologue", "armoury", "crown_1_after_p01_armoury")
	_press("HotspotList_racks")
	await _snap("crown_1_after_p01_armoury_shop")
	await _hub("prologue", "chapel", "crown_1_after_p01_chapel")
	_press("HotspotList_altar")
	await _snap("crown_1_after_p01_chapel_altar")
	var a06 := {"p01_leaf": {"families": "save"}, "a01_presses": {"lyon": "calm", "printer": "taken"}, "a06_barricades": {"varenne": "spared"}}
	_prog(a06, {"earned": {"p01_leaf": 3, "a01_presses": 3, "a06_barricades": 3}, "bought": ["cr_cartridges"], "spent": {"prologue": 3},
		"choices": {"crc_line": "a"}, "bless": {"prologue": "bl_barbara"}, "helper": {"prologue": "h_ruggieri"}})
	await _hub("prologue", "study", "crown_3_after_a06_study")
	await _hub("prologue", "armoury", "crown_3_after_a06_armoury")
	await _hub("prologue", "gallery", "crown_3_after_a06_gallery")
	CampaignMenu.briefing(main, "a07_council")
	await _snap("crown_3_briefing_a07")
	# THE CLOCKMAKER
	_prog({"c01_thirteenth": {"jakob": "alive", "drawings": "taken"}}, {"earned": {"c01_thirteenth": 5}})
	await _hub("clockmaker", "workshop", "clock_1_after_c01_barn")
	await _hub("clockmaker", "yard", "clock_1_after_c01_yard")
	_press("HotspotList_drawings")
	await _snap("clock_1_after_c01_drawings")
	_prog({"c01_thirteenth": {"jakob": "alive"}, "a02_furth": {"furth": "strong", "stopwork": "fitted"}, "a04_visit": {"broken": "kept"}},
		{"earned": {"c01_thirteenth": 5, "a02_furth": 3, "a04_visit": 4}})
	await _hub("clockmaker", "workshop", "clock_3_after_a04_barn")
	await _hub("clockmaker", "yard", "clock_3_after_a04_yard")
	# THE NATURALIST
	_prog({"b01_specimen": {"pieter": "alive", "clutch": "saved"}}, {"earned": {"b01_specimen": 4}})
	await _hub("naturalist", "station", "nat_1_after_b01_warehouse")
	await _hub("naturalist", "store", "nat_1_after_b01_store")
	_prog({"b01_specimen": {"pieter": "alive"}, "a03_plateau": {"map": "drawn"}, "a05_specimens": {"cages": "some", "crates": "seen"}},
		{"earned": {"b01_specimen": 4, "a03_plateau": 3, "a05_specimens": 4}})
	await _hub("naturalist", "chart", "nat_3_after_a05_chart")
	await _hub("naturalist", "store", "nat_3_after_a05_store")
	if _kept != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept)
		f.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	HubRoomsUi.room_of = {}
	quit()
