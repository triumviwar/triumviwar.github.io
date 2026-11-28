extends SceneTree
## Pictures of A WAY OUT in THE WORLD WAR (docs/ww_call_off.md): the attacker's battle question with CALL IT OFF at bad
## odds, the map after calling it off, the defender's question with RETREAT, the map after the retreat, a capital (no
## retreat), NO WAY OUT, a weak march into free land asked first, and the help's new section.
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_ww_call_off.gd -- <outdir> [pc|mobile]
var main
var out := ""


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	out = a[0]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	Settings.load_all()
	Settings.device = a[1] if a.size() > 1 else "pc"
	Settings.apply()
	if a.size() > 2:
		Loc.set_lang(a[2])
	DirAccess.make_dir_recursive_absolute(out)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _snap(name: String, wait := 0.6) -> void:
	await create_timer(wait).timeout
	await process_frame
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, name])
	print("shot ", name)


func _war() -> WWWar:
	return WWWar.make({"players": {"crown": "you", "clockwork": "normal", "brood": "normal"}, "seed": 4, "name": "shot_call_off"})


func _run() -> void:
	await create_timer(0.5).timeout
	var dev := String(Settings.device) + ("_" + Loc.lang if Loc.lang != "en" else "")
	# 1. the attacker: a small army at Milan against the Clockwork's big one at Vienna
	var w := _war()
	var cr: Dictionary = w.armies_of("crown")[0]
	var cw: Dictionary = w.armies_of("clockwork")[0]
	cr["units"] = {"musketeer": 12, "cuirassier": 3}
	cr["at"] = "milan"
	cw["at"] = "vienna"
	cw["units"] = {"clock_soldier": 48, "springer": 6, "pendulum": 6}
	var p := WWPage.show_war(main, w, " ")
	await process_frame
	p._close_overlay()
	p.map.focus("vienna", 3.0)
	p._march(String(cr["id"]), "vienna")
	await _snap("%s_1_attacker_call_off" % dev, 0.9)
	var btn: Button = p.find_child("WW_Btn_CALLITOFF", true, false)
	btn.pressed.emit()
	await _snap("%s_2_called_off" % dev, 0.5)
	# 2. the defender: the Clockwork marches on Milan; the Crown's army may retreat
	p._ask_battle({"att": String(cw["id"]), "region": "milan", "from": "vienna", "sea": false, "att_f": "clockwork",
		"def_f": "crown", "defs": [String(cr["id"])]}, func() -> void: pass)
	p.map.focus("milan", 3.0)
	await _snap("%s_3_defender_retreat" % dev, 0.9)
	(p.find_child("WW_Btn_RETREAT", true, false) as Button).pressed.emit()
	p.map.focus("milan", 3.0)
	await _snap("%s_4_retreated" % dev, 0.5)
	# 3. a capital: no retreat
	var w2 := _war()
	var c2: Dictionary = w2.armies_of("clockwork")[0]
	c2["at"] = "milan"
	c2["units"] = {"clock_soldier": 60, "pendulum": 8}
	w2.d["regions"]["milan"]["owner"] = "clockwork"
	p = WWPage.show_war(main, w2, " ")
	await process_frame
	p._close_overlay()
	p.map.focus("rome", 3.0)
	p._ask_battle({"att": String(c2["id"]), "region": "rome", "from": "milan", "sea": false, "att_f": "clockwork",
		"def_f": "crown", "defs": [String(w2.armies_of("crown")[0]["id"])]}, func() -> void: pass)
	await _snap("%s_5_capital_stands" % dev, 0.9)
	p._pending = {}
	p._close_overlay()
	# 4. NO WAY OUT: the Crown's army at Milan, Lyon lost, the Brood in Rome
	var w3 := _war()
	var d3: Dictionary = w3.armies_of("crown")[0]
	d3["at"] = "milan"
	var a3: Dictionary = w3.armies_of("clockwork")[0]
	a3["at"] = "vienna"
	a3["units"] = {"clock_soldier": 60, "pendulum": 8}
	w3.d["regions"]["lyon"]["owner"] = "clockwork"
	w3.armies_of("brood")[0]["at"] = "rome"
	p = WWPage.show_war(main, w3, " ")
	await process_frame
	p._close_overlay()
	p.map.focus("milan", 3.0)
	p._ask_battle({"att": String(a3["id"]), "region": "milan", "from": "vienna", "sea": false, "att_f": "clockwork",
		"def_f": "crown", "defs": [String(d3["id"])]}, func() -> void: pass)
	await _snap("%s_6_no_way_out" % dev, 0.9)
	p._pending = {}
	p._close_overlay()
	# 5. a weak march into free land is asked first
	var w4 := _war()
	var a4: Dictionary = w4.armies_of("crown")[0]
	a4["units"] = {"musketeer": 3}
	p = WWPage.show_war(main, w4, " ")
	await process_frame
	p._close_overlay()
	p.map.focus("andalusia", 2.5)
	p._march(String(a4["id"]), "andalusia")
	await _snap("%s_7_free_land_asked" % dev, 0.9)
	p._pending = {}
	p._close_overlay()
	# 6. the help's new section
	WWPage.show_help(main, p)
	await process_frame
	await process_frame
	var hp := p.find_child("WW_Help", false, false)
	var sc: ScrollContainer = hp.find_children("", "ScrollContainer", true, false)[0] if hp else null
	if sc:
		for l in sc.find_children("", "Label", true, false):
			if (l as Label).text == Loc.t("A WAY OUT"):
				sc.ensure_control_visible(l)
				sc.scroll_vertical = int(l.position.y) - 8
	await _snap("%s_8_help" % dev, 0.8)
	WWWar.delete_war("shot_call_off")
	quit()
