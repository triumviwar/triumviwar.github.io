extends SceneTree
## Pictures of THE WORLD WAR mode (docs/world_war_mode.md): the setup page, a new war's map, an army picked with
## where it may march, a region's card (build / raise soldiers), the battle question, the help, a war some years on,
## the end, and the battle fought on the field with the armies placed. Saves nothing of the player's (the war is
## written under user://worldwar as "shot_war" and removed).
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_world_war.gd -- <outdir> [pc|mobile]
var main
var out := ""


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	out = a[0]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
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


func _page() -> WWPage:
	for n in main.ui_layer.find_children("WorldWar", "WWPage", true, false):
		return n
	return null


func _run() -> void:
	await create_timer(0.5).timeout
	var dev := String(Settings.device)
	WWPage.show_setup(main)
	await _snap("%s_1_setup" % dev, 0.8)
	var w := WWWar.make({"players": {"crown": "you", "clockwork": "normal", "brood": "normal"}, "seed": 4, "name": "shot_war"})
	var p := WWPage.show_war(main, w)
	await _snap("%s_2_turn_banner" % dev, 1.0)
	p._close_overlay()
	p._select("", "")
	await _snap("%s_3_new_war" % dev)
	var cap: Array = w.armies_at("rome", "crown")
	p.map.focus("rome", 3.0)
	p._select(String(cap[0]["id"]), "rome")
	await _snap("%s_4_army_picked" % dev, 0.8)
	p._select("", "milan")
	await _snap("%s_5_region_card" % dev)
	# a few years on (every side played by the computer), then the Crown's turn again
	w.d["factions"]["crown"]["who"] = "normal"
	for i in 36:
		WWAI.play_turn(w)
		w.end_turn()
		if String(w.d["winner"]) != "":
			break
	while w.current() != "crown" and String(w.d["winner"]) == "":
		WWAI.play_turn(w)
		w.end_turn()
	w.d["factions"]["crown"]["who"] = "you"
	p = WWPage.show_war(main, w, " ")
	await process_frame
	p._close_overlay()
	p.map.show_rect(p.map.world_rect())
	await _snap("%s_6_years_on" % dev)
	p._show_log()
	await _snap("%s_7_log" % dev)
	p._close_overlay()
	# a battle question: the Crown's biggest army against a neighbour's army (made up if need be)
	var mine: Array = w.armies_of("crown")
	if mine.is_empty():
		mine = [w.new_army("crown", w.capital("crown") if w.alive("crown") else "rome", {"musketeer": 18, "cuirassier": 3, "cannon": 2})]
	var a: Dictionary = mine[0]
	var to := ""
	for n in WWRules.neighbours(String(a["at"])):
		if w.owner(n) != "crown":
			to = n
			break
	if to == "":
		to = String(WWRules.neighbours(String(a["at"]))[0])
	var foe := "clockwork" if w.owner(to) != "brood" else "brood"
	if w.armies_at(to).filter(func(x) -> bool: return String(x["f"]) != "crown").is_empty():
		w.new_army(foe, to, WWRules.START_ARMY[foe].duplicate())
	var defs: Array = w.armies_at(to).filter(func(x) -> bool: return String(x["f"]) != "crown")
	var b := {"att": String(a["id"]), "region": to, "from": String(a["at"]), "sea": false, "att_f": "crown",
		"def_f": String(defs[0]["f"]), "defs": defs.map(func(x) -> String: return String(x["id"]))}
	p.map.focus(to, 3.0)
	p._ask_battle(b, func() -> void: pass)
	await _snap("%s_8_battle_question" % dev, 0.8)
	p._close_overlay()
	WWPage.show_help(main, p)
	await _snap("%s_9_help" % dev)
	for n in p.find_children("WW_Help", "", false, false):
		n.queue_free()
	# the battle fought on the field: the armies beside each start
	var wb := WWBattle.new()
	wb.war = w
	wb.battle = b
	wb.begin(main)
	await create_timer(2.0).timeout
	if main.game:
		main.game.camera.position = main.game.cell_center(main.game.starts[0]) + (Vector2(main.game.W, main.game.H) * Game.T * 0.5 - main.game.cell_center(main.game.starts[0])).normalized() * 7 * Game.T
		main.game.camera.zoom = Vector2(1.0, 1.0)
	await _snap("%s_10_battle_field" % dev, 1.5)
	main._quit_match()
	await create_timer(0.5).timeout
	await _snap("%s_11_after_battle" % dev, 0.8)
	# the end
	w.d["winner"] = "crown"
	p = WWPage.show_war(main, w, " ")
	await _snap("%s_12_victory" % dev, 1.0)
	WWWar.delete_war("shot_war")
	quit()
