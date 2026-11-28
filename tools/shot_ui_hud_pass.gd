extends SceneTree
## Pictures for the match HUD pass (job ui-hud-pass, docs/ui_hud_pass.md, docs/shots/ui_hud_pass/). The "before"
## pictures are the design review's (docs/shots/qa_ui_review/). A picture tool, not a test: it changes no game code.
##   xvfb-run -a -s "-screen 0 1600x900x24" godot --rendering-driver opengl3 --resolution 1600x900 \
##       --script res://tools/shot_ui_hud_pass.gd -- <outdir> <pc|mobile>
var main
var out := ""
var dev := "pc"


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	out = a[0]
	dev = a[1]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	Settings.load_all()
	Settings.device = dev
	Settings.grid_keys = false
	Settings.show_apm = true
	Settings.set_language(a[2] if a.size() > 2 else "en")
	Settings.apply()
	DirAccess.make_dir_recursive_absolute(out)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _snap(name: String, wait := 0.5) -> void:
	await create_timer(wait).timeout
	await process_frame
	await process_frame
	var img := root.get_viewport().get_texture().get_image()
	if img.get_width() > 1600:
		img.resize(1600, int(img.get_height() * 1600.0 / img.get_width()), Image.INTERPOLATE_LANCZOS)      # (small files)
	img.save_jpg("%s/%s_%s.jpg" % [out, dev, name], 0.8)
	print("shot ", name)


## A tooltip shown at once (the HUD hides an unhovered one after a moment: pinned as a phone's tap)
func _tip(hud, t: Dictionary, at: Vector2) -> void:
	if dev == "pc":
		var mm := InputEventMouseMotion.new()      # (a computer: the mouse rests there and the HUD shows it itself)
		mm.position = root.get_viewport().get_final_transform() * (at * hud.ui_scale)
		mm.global_position = mm.position
		Input.warp_mouse(mm.position)
		Input.parse_input_event(mm)
	hud._tip = t
	hud._tip_at = at
	hud._tip_ms = Time.get_ticks_msec()
	hud._sig.erase("tooltip")


func _build(g: Game, kind: String, near: Vector2i) -> Building:
	for r in range(4, 26):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var c: Vector2i = near + Vector2i(dx, dy)
				if g.placement_problem(0, kind, c) == "":
					return g._add_building(kind, 0, c, true)
	return null


func _run() -> void:
	await create_timer(0.8).timeout
	main.start({"map": "greenhold", "seed": 7, "slots": [
		{"who": "you", "faction": "crown", "colour": 0, "side": 0},
		{"who": "easy", "faction": "brood", "colour": 1, "side": 1}]})
	await process_frame
	await process_frame
	var g: Game = main.game
	var hud = g.hud
	hud.countdown = 0.0
	paused = false
	for ai in g.ais:
		ai.process_mode = Node.PROCESS_MODE_DISABLED
	g.players[0]["gold"] = 4200
	g.players[0]["res2"] = 380
	var hall: Building = g.halls_of(0)[0]
	var bks: Array = []
	for i in 4:
		bks.append(_build(g, "barracks", hall.cell + Vector2i(6, 4)))
	var arm := _build(g, "armoury", hall.cell + Vector2i(-4, 6))
	var men: Array = []
	var at: Vector2 = hall.center() + Vector2(260, 220)
	for i in 8:
		men.append(g._add_unit("musketeer", 0, at + Vector2((i % 4) * 30, (i / 4) * 30)))
	g._recount_supply(0)
	g.players[0]["cap"] = 60
	await create_timer(1.0).timeout
	g.clock = 95.0
	# gold income for the tooltip's first line
	for i in 6:
		g.clock += 5.0
		g.stats[0]["gold"] = float(g.stats[0]["gold"]) + 70.0
		g.players[0]["gold"] = float(g.players[0]["gold"]) + 25.0
		hud.alerts().sample(0)

	# 1. a Barracks and its Musketeers: the units' card first, the Barracks' buttons after (no clashing letters)
	g.camera.position = (bks[0] as Building).center() + Vector2(120, 80)
	g.set_selection(men + [bks[0]])
	hud._card_fresh = true
	await _snap("1_mixed_barracks_musketeers")
	for b in hud._card_buttons:
		if hud.card_label(b["item"]) == "MUSKETEER":
			_tip(hud, hud._tip_of({"item": b["item"]}), (b["rect"] as Rect2).get_center())
	await _snap("2_mixed_card_building_tooltip", 0.6)
	hud._tip = {}

	# 2. the Barracks alone, training: the queue with its time left, the bar on the building
	var b0: Building = bks[0]
	g.set_selection([b0])
	for k in ["musketeer", "musketeer", "dragoon"]:
		g.train(b0, k)
	await create_timer(1.5).timeout
	hud._card_fresh = true
	await _snap("3_barracks_queue")
	for b in hud._card_buttons:
		if hud.card_label(b["item"]) == "MUSKETEER":
			_tip(hud, hud._tip_of({"item": b["item"]}), (b["rect"] as Rect2).get_center())
	await _snap("4_card_tooltip_summary_first", 0.6)
	hud._tip = {}

	# 3. the gold tooltip: income and spending a minute first
	for pr in hud._pill_rects:
		if int(pr[1]) == 0:
			_tip(hud, hud._tip_of({"res": 0}), (pr[0] as Rect2).get_center())
	await _snap("5_gold_tooltip_income", 1.0)
	hud._tip = {}

	# 4. supply blocked: the supply pill flashes and the line is said once
	hud._tip = {}
	var away := InputEventMouseMotion.new()
	away.position = root.get_viewport().get_final_transform() * Vector2(1000, 500)
	Input.parse_input_event(away)
	for bb in bks:
		(bb as Building).queue.clear()
	g._recount_supply(0)
	g.players[0]["cap"] = g.supply_used(0)
	g.train(bks[1], "musketeer")
	await _snap("6_supply_blocked", 0.3)
	for pr in hud._pill_rects:
		if int(pr[1]) == 2:
			_tip(hud, hud._tip_of({"res": 2}), (pr[0] as Rect2).get_center())
	await _snap("7_supply_tooltip", 1.0)
	hud._tip = {}
	g._recount_supply(0)
	g.players[0]["cap"] = 60
	Input.warp_mouse(Vector2(800, 300))

	# 5. the glows: an idle worker (IDLE), every production building idle (MAKE), a fight (ARMY), a fresh alert
	for w in g.labourers(0):
		w.order = "idle"
		w.process_mode = Node.PROCESS_MODE_DISABLED      # (it stays idle for the picture)
		break
	men[0].hit_clock = g.clock
	hud.note_alert(hall.center() + Vector2(900, 400), "attack", "Your forces are under attack!")
	g.set_selection([])
	await _snap("8_glows_idle_army_make_alert", 0.4)

	# 6. MAKE: every production building, a long card: its page tab
	hud.bar.select_production()
	if arm:
		g.set_selection(bks + [arm, hall])
	await _snap("9_make_long_card_page_tab", 0.4)

	# 7. jump to the last alert
	hud.jump_alert()
	await _snap("10_jump_to_alert", 0.4)
	quit()
