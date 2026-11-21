extends SceneTree
## Pictures of THE WAR MAP (docs/war_map_v1.md) in a few states of the campaign: new, after the prologues, Europe
## with the Fürth Line held thin, the Amazon with the plateau drawn or withheld, a pin's card, the ledger, and the
## whole act played (the planned missions' flags faked). Keeps user://campaign.json as it was.
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_war_map.gd -- <outdir> [pc|mobile]
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


const PRO := {
	"p01_leaf": ["crown", {"families": "save"}],
	"c01_thirteenth": ["guild", {"bells": "rung", "saved": "many", "saved_n": 34, "jakob": "alive", "cut": "yes", "gate": "pattern"}],
	"b01_specimen": ["sire", {"teles": "quiet", "clutch": "saved", "saved": "some", "saved_n": 9, "pieter": "alive"}],
}


func _open(done: Dictionary, view := "", pick := "") -> WarMap:
	Campaign.save_progress(_p(done))
	CampaignMenu.line = "prologue"
	CampaignMenu.map_open = false
	CampaignMenu.map_cam = {}
	CampaignMenu.map_pick = pick
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
	await _open({})
	await _snap("%s_1_new" % dev, 1.0)
	await _open(PRO)
	await _snap("%s_2_prologues" % dev)
	var d := PRO.duplicate(true)
	d["a02_furth"] = ["guild", {"furth": "thin"}]
	await _open(d, "europe", "a02_furth")
	await _snap("%s_3_europe_furth_thin_card" % dev)
	d = PRO.duplicate(true)
	d["a03_plateau"] = ["party", {"map": "drawn", "party": "some"}]
	await _open(d, "amazon", "a03_plateau")
	await _snap("%s_4_amazon_plateau_drawn" % dev)
	d["a03_plateau"] = ["party", {"map": "withheld", "party": "all"}]
	await _open(d, "amazon")
	await _snap("%s_5_amazon_plateau_withheld" % dev)
	d = PRO.duplicate(true)
	d["p01_leaf"] = ["crown", {"families": "leave"}]
	d["a02_furth"] = ["machine", {"furth": "fallen"}]
	d["a03_plateau"] = ["party", {"map": "drawn", "party": "few"}]
	d["a01_presses"] = ["crown", {"lyon": "sullen"}]
	d["a06_barricades"] = ["crown", {"varenne": "executed"}]
	d["a04_visit"] = ["guild", {"broken": "kept", "lost_to_machine": 6}]
	await _open(d, "europe")
	var lb: Button = main.ui_layer.find_child("WarMap_Ledger", true, false)
	lb.pressed.emit()
	await _snap("%s_6_europe_ledger_harsh_act" % dev)
	var wm8 := await _open(d, "europe")
	await _snap("%s_8_europe_territory" % dev)
	wm8.zoom_by(2.0)
	await _snap("%s_9_europe_territory_zoomed" % dev)
	await _open(d, "virginia", "p01_leaf")
	await _snap("%s_7_virginia_families_left" % dev)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	if _kept != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept)
		f.close()
	quit()
