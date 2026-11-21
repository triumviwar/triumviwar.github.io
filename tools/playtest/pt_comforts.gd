extends SceneTree
## PLAYTEST (player-comforts, docs/player_comforts.md): real input on the things this job built, with pictures.
##   tools/playtest/run.sh pt_comforts 1280x720 [phone] tag=<name> [what=layout|menu|all] [mission=p01_leaf]
## layout: a campaign mission (its dialogue box and objectives) and a skirmish at this screen size, pictures before /
##         after (tag=), the HUD parts' sizes printed (PT SIZE).
## menu:   in a mission: the PAUSE key (Pause/Break and F10), MENU > SAVE, LOAD (its question, Esc and Enter), the
##         QUIT question and the hub it leads to with CONTINUE on the mission's card; then the main menu's EXIT question.
const PT := preload("res://tools/playtest/pt_lib.gd")

var pt
var main: Node
var phone := false
var args := {"tag": "now", "what": "all", "mission": "p01_leaf", "lang": "en"}
var fails := 0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "phone":
			phone = true
		elif a.contains("="):
			args[a.get_slice("=", 0)] = a.substr(a.find("=") + 1)
	var cfg := ConfigFile.new()
	cfg.load("user://settings.cfg")
	cfg.set_value("input", "device", "phone" if phone else "pc")
	cfg.set_value("ui", "language", args["lang"])
	cfg.save("user://settings.cfg")
	var p := {"reached": ["p01_leaf", "b01_specimen", "c01_thirteenth"], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": "normal"}
	var f := FileAccess.open("user://campaign.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(p))
	f.close()
	pt = PT.new(self, "res://docs/shots/player_comforts/" + args["tag"])
	pt.touch = phone
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	print("PT CHECK %s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func game() -> Game:
	return main.game


func hud() -> Control:
	return main.game.hud if main.game else null


## A HUD rect (its own units) on the screen.
func hud_screen(r: Rect2) -> Rect2:
	var xf: Transform2D = hud().get_global_transform()
	return Rect2(xf * r.position, xf.basis_xform(r.size))


func _run() -> void:
	await pt.wait(1.0)
	await pt.past_crash_page()
	print("PT screen %s phone=%s" % [pt.vs(), phone])
	if args["what"] in ["layout", "all"]:
		await _layout()
	if args["what"] in ["menu", "all"]:
		await _menu()
	pt.report_errors("comforts")
	print("PT DONE fails=%d" % fails)
	quit(1 if fails > 0 else 0)


func _start_mission(mid: String) -> void:
	main.start(Campaign.make_cfg(mid, "solo"))
	await pt.wait(1.0)
	while game() == null or hud().countdown > 0.0:
		await pt.wait(0.2)


## The sizes of the HUD's parts on the screen, as shares of its height.
func _sizes(tag: String) -> void:
	var vs: Vector2 = pt.vs()
	var lay: Dictionary = hud()._layout()
	var parts := {}
	for k in ["mini", "panel", "card", "hotbar"]:
		var r := hud_screen(lay[k])
		parts[k] = "%dx%d at y %d (%.0f%%)" % [r.size.x, r.size.y, r.position.y, 100.0 * r.size.y / vs.y]
	var top_of_bottom := vs.y
	for k in ["mini", "panel", "card", "hotbar"]:
		top_of_bottom = minf(top_of_bottom, hud_screen(lay[k]).position.y)
	print("PT SIZE %s screen %s ui_scale %.2f bottom HUD from y %d (%.0f%% of the height) %s" % [tag, vs, hud().ui_scale, top_of_bottom,
		100.0 * (vs.y - top_of_bottom) / vs.y, parts])
	var mui := _mui()
	if mui:
		var box: Control = mui.get("_box")
		var ob: Control = mui.get("_obj")
		print("PT SIZE %s dialogue %s visible %s, objectives %s (%.0f%% / %.0f%% of the height)" % [tag, box.get_global_rect(), box.visible,
			ob.get_global_rect(), 100.0 * box.size.y / vs.y if box.visible else 0.0, 100.0 * ob.size.y / vs.y])


func _mui() -> MissionUi:
	for c in main.ui_layer.get_children():
		if c is MissionUi:
			return c
	return null


func _layout() -> void:
	await _start_mission(args["mission"])
	# the first lines of the mission
	var mui := _mui()
	var t := 0.0
	while t < 20.0 and not (mui.get("_box") as Control).visible:
		await pt.wait(0.25)
		t += 0.25
	await pt.wait(0.6)
	await _sizes("mission")
	await pt.shot("mission_dialogue")
	# the objectives opened (a tap on their title) and closed
	var ob: Control = mui.get("_obj")
	var head := Rect2(ob.get_global_rect().position, Vector2(ob.size.x, 30))
	await pt.click(head.get_center())
	await pt.wait(0.3)
	await _sizes("objectives_tapped")
	await pt.shot("mission_objectives_tapped")
	await pt.click(head.get_center())
	await pt.wait(0.3)
	# a building selected: the card and the panel
	for b in game().buildings:
		if b.team == game().human and not b.dead:
			game().select_only(b) if game().has_method("select_only") else null
			if game().selection.is_empty():
				game().selection = [b]
			break
	await pt.wait(0.5)
	await pt.shot("mission_selected")
	main._to_menu()
	await pt.wait(0.8)
	# a skirmish
	main.start({"map": "greenhold", "slots": [{"who": "you", "faction": "crown", "colour": 0, "side": 0},
		{"who": "easy", "faction": "brood", "colour": 1, "side": 1}]})
	await pt.wait(1.0)
	while hud().countdown > 0.0:
		await pt.wait(0.2)
	for b in game().buildings:
		if b.team == game().human and b.kind == "town_hall":
			game().selection = [b]
	await pt.wait(0.5)
	await _sizes("skirmish")
	await pt.shot("skirmish")
	main._to_menu()
	await pt.wait(0.8)


func _menu_open() -> void:
	var r := hud_screen(hud().menu_rect())
	await pt.click(r.get_center())
	await pt.wait(0.3)


## The menu's button with this label (its rect on the screen), or an empty rect.
func _menu_btn(label: String) -> Rect2:
	for b in hud()._menu_buttons():
		if String(b["label"]).begins_with(label):
			return hud_screen(b["rect"])
	return Rect2()


func _menu() -> void:
	await _start_mission(args["mission"])
	var g := game()
	# the PAUSE keys
	await pt.key(KEY_F10)
	check("f10_pauses", hud().paused and get_root().get_tree().paused)
	var c0 := g.clock
	await pt.wait(0.6)
	check("paused_clock_still", is_equal_approx(g.clock, c0), "%.2f %.2f" % [c0, g.clock])
	await pt.shot("paused_by_f10")
	await pt.key(KEY_PAUSE)
	check("pause_key_resumes", not hud().paused)
	await pt.wait(0.6)
	check("clock_runs", g.clock > c0)
	# MENU > SAVE
	await _menu_open()
	check("menu_open", hud().menu_open)
	check("menu_has_save", _menu_btn("SAVE").size.x > 0.0, str(hud()._menu_list().map(func(b) -> String: return b["label"])))
	await pt.shot("menu_in_mission")
	await pt.click(_menu_btn("SAVE").get_center())
	await pt.wait(0.4)
	var saved := MissionSave.peek(g.mission.id, "save")
	check("saved", not saved.is_empty())
	var saved_clock := float(saved.get("clock", -1))
	await pt.wait(2.0)
	# LOAD: its question; Esc says no
	await _menu_open()
	await pt.click(_menu_btn("LOAD").get_center())
	await pt.wait(0.3)
	check("load_asks", hud().get("_confirm") == "load")
	await pt.shot("load_question")
	await pt.key(KEY_ESCAPE)
	check("esc_says_no", hud().get("_confirm") == "" and game() == g)
	# LOAD again; Enter says yes
	await pt.click(_menu_btn("LOAD").get_center())
	await pt.wait(0.3)
	await pt.key(KEY_ENTER)
	await pt.wait(1.5)
	check("loaded", game() != g and game() != null and game().mission != null and absf(game().clock - saved_clock) < 1.0,
		"clock %.1f saved %.1f" % [game().clock if game() else -1.0, saved_clock])
	while hud().countdown > 0.0:
		await pt.wait(0.2)
	await pt.wait(1.0)
	g = game()
	# QUIT: its question, then the hub with CONTINUE
	await _menu_open()
	check("quit_label", _menu_btn("QUIT TO CAMPAIGN").size.x > 0.0)
	await pt.click(_menu_btn("QUIT TO CAMPAIGN").get_center())
	await pt.wait(0.3)
	check("quit_asks", hud().get("_confirm") == "quit")
	await pt.shot("quit_question")
	await pt.click(_menu_btn("YES").get_center())
	await pt.wait(1.2)
	check("left_match", main.game == null)
	await pt.shot("hub_after_quit")
	var on_hub := pt.find("Hotspot_war_table") != null or pt.find("WAR TABLE") != null
	check("at_hub", on_hub, str(pt.button_names().slice(0, 12)))
	await pt.tap("Hotspot_war_table")
	await pt.wait(0.6)
	await pt.tap("Mission_" + args["mission"])
	await pt.wait(0.6)
	var cont: BaseButton = pt.find("Campaign_Auto")
	check("card_continue", cont != null, str(pt.button_names()))
	check("card_load_save", pt.find("Campaign_Save") != null)
	await pt.shot("card_continue")
	if cont:
		await pt.tap_node(cont)
		await pt.wait(1.5)
		check("continued", game() != null and game().mission != null and game().clock > 1.0, "clock %.1f" % (game().clock if game() else -1.0))
		await pt.shot("continued")
		main._to_menu()
		await pt.wait(0.8)
	# the main menu's EXIT asks first
	main.show_menu()
	await pt.wait(0.6)
	var ex: BaseButton = pt.find("Menu_exit")
	if ex:
		await pt.tap_node(ex)
		await pt.wait(0.4)
		check("exit_asks", pt.find("Confirm_Yes") != null, str(pt.button_names()))
		await pt.shot("exit_question")
		await pt.key(KEY_ESCAPE)
		await pt.wait(0.3)
		check("exit_esc_no", pt.find("Confirm_Yes") == null and pt.find("Menu_exit") != null)
