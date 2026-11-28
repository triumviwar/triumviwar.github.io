extends SceneTree
## Pictures of THE WAR MAP's Act 3 (docs/war_map_act3.md): THE WORLD at the act's start and in the middle of it (the
## clock's plate, the theatres' names, fallen colonies), the four theatre views, a planned pin's card, the ledger with
## THE CLOCK, an optional pin the night closed, the present in EUROPE, and the same act on the Clockmaker's BRASS map and
## the Naturalist's SPECIMEN CHART (Lindqvist's notes in red ink). Keeps user://campaign.json as it was.
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_war_map_act3.gd -- <outdir> [pc|mobile]
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


func _snap(name: String, wait := 0.6) -> void:
	await create_timer(wait).timeout
	await process_frame
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, name])
	print("shot ", name)


func _p(done: Dictionary) -> Dictionary:
	var p := {"reached": [], "done": {}}
	for mid in done:
		p["done"][mid] = {"won_by": done[mid][0], "side": done[mid][0], "flags": done[mid][1]}
		if done[mid].size() > 2:
			p["done"][mid]["seq"] = done[mid][2]
		if not Campaign.storyline_of(mid).is_empty():
			var nx := Campaign.next_of(mid, String(done[mid][0]))
			if nx != "":
				p["reached"].append(nx)
	return p


## Act 1 played through (the canon-ish run), then Act 2's first two missions.
const ACT1 := {
	"p01_leaf": ["crown", {"families": "save"}],
	"c01_thirteenth": ["guild", {"bells": "rung", "saved": "many", "saved_n": 34, "jakob": "alive", "cut": "yes", "gate": "pattern"}],
	"b01_specimen": ["sire", {"teles": "quiet", "clutch": "saved", "saved": "some", "saved_n": 9, "pieter": "alive"}],
	"a02_furth": ["guild", {"furth": "strong"}],
	"a03_plateau": ["party", {"map": "drawn", "party": "some"}],
	"a01_presses": ["crown", {"lyon": "calm"}],
	"a06_barricades": ["crown", {"varenne": "spared"}],
	"a04_visit": ["visit", {"broken": "kept", "lost_to_machine": 2}],
	"a05_specimens": ["expedition", {"cages": "some", "cages_n": 2}],
	"a07_council": ["crown", {"rome": "some"}],
}


func _act(extra: Dictionary) -> Dictionary:
	var d := ACT1.duplicate(true)
	d.merge(extra, true)
	return d


func _open(done: Dictionary, skin := "parchment", view := "", pick := "") -> WarMap:
	Campaign.save_progress(_p(done))
	CampaignMenu.line = {"parchment": "prologue", "brass": "clockmaker", "chart": "naturalist"}[skin]
	CampaignMenu.map_open = false
	CampaignMenu.map_cam = {}
	CampaignMenu.map_pick = pick
	CampaignMenu.map_skin = skin
	CampaignMenu.war_map(main)
	await process_frame
	await process_frame
	var wm: WarMap = null
	for n in main.ui_layer.find_children("*", "WarMap", true, false):
		wm = n
	if view != "":
		wm.show_view(view, false)
	return wm


## Act 2 finished (both fronts), then Act 3's wins in order: [mission, {flags}].
func _act3(wins: Array) -> Dictionary:
	var d := _act({"d09_crossroads": ["crown", {"first": "brood"}], "d10_jungle": ["column", {"jungle": "held"}],
		"d11_siege": ["column", {"siege": "close", "jakob": "alive"}]})
	var seq := 10
	for w in wins:
		seq += 1
		d[String(w[0])] = ["crown", w[1] if w.size() > 1 else {}, seq]
	return d


func _run() -> void:
	await create_timer(0.5).timeout
	var dev := String(Settings.device)
	var start := _act3([])
	var mid := _act3([["e04_kongo", {"kongo": "stood"}], ["e05_river", {"nests": "found"}], ["e08_arsenal", {"matthias": "alive"}],
		["e09_nagasaki", {"stopwork": "kept", "nagasaki": "some"}], ["e12_exiles", {"exiles": "pardon"}], ["e13_gold", {"goldfields": "held"}],
		["e06_taken", {"ruin": "opened"}]])
	var night := _act3([["e04_kongo", {"kongo": "stood"}], ["e08_arsenal"], ["e01_brazil", {"colonists": "some"}], ["e12_exiles", {"exiles": "pardon"}],
		["e05_river", {"nests": "found"}], ["e09_nagasaki", {"stopwork": "kept"}], ["e03_virginia", {"fairleigh": "rode_with", "virginia": "some"}],
		["e13_gold", {"goldfields": "held"}], ["e06_taken", {"ruin": "sealed"}], ["e11_spice", {"spice": "cleared"}], ["e16_lisbon", {"lisbon": "held"}]])
	var present := night.duplicate(true)
	present["e17_goa"] = ["crown", {"goa_night": "held"}, 30]
	present["e18_port"] = ["crown", {"atlantic": "held"}, 31]
	present["e19_tiber"] = ["crown", {"deserters": "spared"}, 32]
	await _open(start)
	await _snap("%s_a3_1_parchment_world_start" % dev, 1.0)
	await _open(mid)
	await _snap("%s_a3_2_parchment_world_middle_clock" % dev)
	await _open(mid, "parchment", "americas")
	await _snap("%s_a3_3_parchment_americas" % dev)
	await _open(mid, "parchment", "africa", "e07_highlands")
	await _snap("%s_a3_4_parchment_africa_optional_card" % dev)
	await _open(mid, "parchment", "indies", "e11_spice")
	await _snap("%s_a3_5_parchment_indies_planned_card" % dev)
	await _open(mid, "parchment", "seas")
	await _snap("%s_a3_6_parchment_southern_seas" % dev)
	await _open(mid, "parchment")
	var lb: Button = main.ui_layer.find_child("WarMap_Ledger", true, false)
	lb.pressed.emit()
	await _snap("%s_a3_7_parchment_ledger_clock" % dev)
	await _open(night, "parchment", "", "e10_manila")
	await _snap("%s_a3_8_parchment_night_closed_card" % dev)
	await _open(present, "parchment")
	await _snap("%s_a3_9_parchment_present_europe" % dev)
	await _open(mid, "brass")
	await _snap("%s_a3_10_brass_world" % dev)
	var wb := await _open(mid, "brass", "indies")
	await create_timer(0.4).timeout
	wb.zoom_by(2.2, wb.pin_screen(WarMapData.pin_of("e08_arsenal")))
	await _snap("%s_a3_11_brass_indies_goa_notes" % dev)
	await _open(mid, "chart")
	await _snap("%s_a3_12_chart_world" % dev)
	var wc := await _open(mid, "chart", "africa")
	await create_timer(0.4).timeout
	wc.zoom_by(2.4, wc.pin_screen(WarMapData.pin_of("e06_taken")))
	await _snap("%s_a3_13_chart_africa_red_notes" % dev)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	if _kept != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept)
		f.close()
	quit()
