extends SceneTree
## Pictures of THE WAR MAP's Act 2 (docs/war_map_act2.md): the BRAZIL view on the King's parchment at the act's start
## and late in the act, the diamond's clock, a planned pin's card, the same act on the Clockmaker's BRASS map and the
## Naturalist's SPECIMEN CHART, and the world painting with Act 2's seals. Keeps user://campaign.json as it was.
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_war_map_act2.gd -- <outdir> [pc|mobile]
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


func _run() -> void:
	await create_timer(0.5).timeout
	var dev := String(Settings.device)
	var start := _act({"d02_exodus": ["exodus", {"exodus": "some", "exodus_n": 5, "drawings": "carried"}],
		"d03_fazenda": ["stock", {"hidden": "some", "hidden_n": 6, "storm": "hatched"}]})
	var late := _act({"d02_exodus": ["exodus", {"exodus": "some", "exodus_n": 5, "drawings": "carried"}],
		"d03_fazenda": ["stock", {"hidden": "some", "hidden_n": 6, "storm": "hatched"}],
		"d01_minas": ["crown", {"minas": "restless", "gold": "some", "conspirator": "fled"}],
		"d04_concordia": ["guild", {"colonists": "fought", "crates": "opened"}],
		"d05_aldeia": ["crown", {"fields": "burned", "aldeia": "some"}],
		"d06_queen": ["brood", {"brood_n": "some", "pieter": "alive"}],
		"d07_spring": ["honest", {"spring": "running", "honest": "some"}],
		"d08_rivers": ["barra", {"lure": "burned", "barra": "held", "nazare": "some"}],
		"d09_crossroads": ["crown", {"first": "brood", "sertao": "some", "fort": "held"}]})
	var done := late.duplicate(true)
	done["d10_jungle"] = ["column", {"jungle": "held"}]
	done["d11_siege"] = ["column", {"siege": "close", "jakob": "alive"}]
	await _open(start)
	await _snap("%s_a2_1_parchment_brazil_start" % dev, 1.0)
	await _open(late, "parchment", "", "d11_siege")
	await _snap("%s_a2_2_parchment_late_clock_card" % dev)
	await _open(start, "parchment", "", "d01_minas")
	await _snap("%s_a2_3_parchment_planned_card" % dev)
	await _open(done, "parchment")
	var lb: Button = main.ui_layer.find_child("WarMap_Ledger", true, false)
	lb.pressed.emit()
	await _snap("%s_a2_4_parchment_act_done_ledger" % dev)
	await _open(late, "parchment", "world")
	await _snap("%s_a2_5_parchment_world_painting" % dev)
	await _open(late, "brass")
	await _snap("%s_a2_6_brass_brazil" % dev)
	var wb := await _open(late, "brass", "", "d07_spring")
	await create_timer(0.5).timeout
	wb.zoom_by(2.5, wb.pin_screen(WarMapData.pin_of("d07_spring")))
	await _snap("%s_a2_7_brass_concordia_zoomed" % dev)
	await _open(late, "brass", "europe")
	await _snap("%s_a2_8_brass_europe" % dev)
	await _open(late, "chart")
	await _snap("%s_a2_9_chart_brazil" % dev)
	await _open(late, "chart", "amazon")
	await _snap("%s_a2_10_chart_amazon_notes" % dev)
	await _open({"p01_leaf": ["crown", {"families": "save"}], "b01_specimen": ["sire", {"saved": "some", "saved_n": 9}]}, "chart", "amazon")
	await _snap("%s_a2_11_chart_act1" % dev)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	if _kept != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept)
		f.close()
	quit()
