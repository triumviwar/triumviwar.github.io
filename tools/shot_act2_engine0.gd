extends SceneTree
## Screenshots of Act 2's engine step 0 (docs/shots/act2_engine0/): each new piece on screen, for the owner's rule
## CHECK THE FEEL (scale, shadows, overlaps): cargo carts and a cart being taken, the leash and a lure post, tracks,
## a building about to turn, the gear plates, the swamp spreading, a sapper's gallery, a hidden pen found, a granary
## feeding, the briefing's version line and the hub's choice.
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_act2_engine0.gd -- <outdir>
## (PNGs; saved as JPEGs with PIL, quality 85, for the docs.) Leaves user://campaign.json as it was.
var main: Node
var out := "/tmp/act2_shots"
var _kept := ""
const ID := "x_act2_shot"


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	if not a.is_empty():
		out = a[0]
	DirAccess.make_dir_recursive_absolute(out)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	if FileAccess.file_exists(Campaign.PROGRESS):
		_kept = FileAccess.get_file_as_string(Campaign.PROGRESS)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	Settings.load_all()
	Settings.device = "pc"
	Settings.apply()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _shot(name: String) -> void:
	for i in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, name])
	print("wrote ", name)


func mission() -> Dictionary:
	var m: Dictionary = Campaign.mission("p01_revolt").duplicate(true)
	m["id"] = ID
	m["sides"].append({"id": "wild", "name": "The Wild"})
	m["teams"].append({"id": "stock", "side": "wild", "faction": "brood", "colour": 2, "start": "none", "camera": "village",
		"control": {"solo": "script", "coop": "script", "versus": "script"}})
	m["teams"].append({"id": "works", "side": "rebels", "faction": "clockwork", "colour": 1, "start": "none", "camera": "ford",
		"control": {"solo": "script", "coop": "script", "versus": "script"}})
	m["triggers"] = []
	m.erase("wiped_out")
	m["objectives"] = [{"id": "x", "side": "crown", "primary": true, "kind": "manual", "text": "Bring the families' carts down the road."}]
	for b in m["buildings"]:
		b["tags"] = ["quarter"]
	m["buildings"].append({"team": "rebels", "kind": "farm", "at": "village", "tag": "granary"})
	m["units"].append({"team": "column", "kind": "powder_wagon", "count": 3, "at": "ford", "tag": "carts", "as": "family_cart"})
	m["units"].append({"team": "column", "kind": "powder_wagon", "count": 1, "at": "ford", "tag": "gold", "as": "gold_cart"})
	m["units"].append({"team": "stock", "kind": "raptor", "count": 4, "at": "village", "tag": "stock"})
	m["units"].append({"team": "works", "kind": "clock_soldier", "count": 3, "at": "ford", "tag": "machines"})
	m["take_carts"] = [{"tag": "carts", "by": "rebels", "secs": 6}]
	m["granaries"] = [{"tag": "granary", "gold": 10, "every": 1, "hold_within": 3}]
	m["versions"] = {"pick": [{"if": {"difficulty": "easy"}, "id": "fresh"}], "default": "grown",
		"labels": {"fresh": "FRESH: you came here first: the swarm is still young below the Barra.",
			"grown": "GROWN: you fought the other front first: the swarm has spread down the rivers."}}
	return m


## Everyone out of the way and the words of the pictures before gone (time is held still: they would not fade).
func _clear(g: Game, all: Array) -> void:
	g._floats.clear()
	for u in all:
		if is_instance_valid(u) and not u.dead:
			u.position = Vector2(40, 40) + Vector2(randf() * 200, randf() * 100)


func _tick(g: Game, secs: float) -> void:
	var r: MissionRun = g.mission
	var t := 0.0
	while t < secs - 0.001:
		g.clock += 0.25
		r.a2.tick(0.25)
		r.a2.frame(0.25)
		r._tick_turning()
		t += 0.25


func _look(g: Game, p: Vector2) -> void:
	g.camera.position = p
	g.camera.reset_smoothing()
	g.camera.force_update_scroll()
	root.get_viewport().warp_mouse(Vector2(1279, 300))       # (no hover card over the picture)
	g._rebuild_hash()
	g.refresh_fog()
	g.queue_redraw()


func _run() -> void:
	await create_timer(1.5).timeout
	Campaign._cache["%s/missions/%s.json" % [Campaign.DIR, ID]] = mission()
	main.start(Campaign.make_cfg(ID, "solo"))
	await create_timer(5.0).timeout          # (the 3-2-1)
	Engine.time_scale = 0.001        # (near still: the pieces are ticked by hand; the camera and the drawing go on)
	var g: Game = main.game
	var r: MissionRun = g.mission
	g.reveal = true
	var ford := r.area_rect("ford").get_center()
	var vil := r.area_rect("village").get_center()
	var far := Vector2(40, 40)
	# out of the way: everyone but what each picture shows
	var all: Array = g.units.duplicate()
	_clear(g, all)
	# 1 CARGO CARTS and TAKE A CART
	var carts: Array = r.tagged("carts")
	var gold: Unit = r.tagged("gold")[0]
	for i in carts.size():
		carts[i].position = ford + Vector2(-90 + i * 90, 0)
	gold.position = ford + Vector2(180, 0)
	r.act({"load": {"cart": "carts", "cargo": "families", "amount": 3}})
	r.act({"load": {"cart": "gold", "cargo": "gold", "amount": 1}})
	var fg: Array = r.tagged("ford_guard")
	fg[0].position = carts[0].position + Vector2(-30, 20)
	fg[1].position = carts[0].position + Vector2(-34, -16)
	var foot: Array = r.tagged("column_foot")
	for i in 4:
		foot[i].position = ford + Vector2(60 + i * 26, 60)
	_look(g, ford)
	_tick(g, 3.0)
	await _shot("1_cargo_and_take")
	_tick(g, 3.5)
	await _shot("2_cart_taken")
	_clear(g, all)
	# 3 THE LEASH and a LURE POST
	var raps: Array = r.tagged("stock")
	var spot := g.cell_center(g.cell_of(vil)) + Vector2(7 * Defs.TILE, 2 * Defs.TILE)
	for i in raps.size():
		raps[i].position = spot + Vector2(-50 + i * 34, 40)
	raps[raps.size() - 1].position = spot + Vector2(300, -40)
	var sc := g.cell_of(spot)
	r.act({"lure_post": {"tag": "lure", "at": [sc.x, sc.y]}})
	r.act({"leash": {"tag": "stock", "lure": "lure", "within": 6, "name": "stock"}})
	_look(g, spot + Vector2(120, 0))
	_tick(g, 0.5)
	await _shot("3_leash_lure_post")
	# 4 TRACKS (for the rebels' eyes: shown to everyone with all vision on)
	r.act({"tracks": {"tag": "stock", "for": "rebels", "every": 0.25, "secs": 60}})
	for k in 14:
		for u in raps:
			u.position += Vector2(18, 6 * sin(k * 0.7))
		_tick(g, 0.25)
	_look(g, spot + Vector2(250, 30))
	await _shot("4_tracks")
	_clear(g, all)
	# 5 BUILDINGS THAT CONVERT
	r.act({"spread_convert": {"name": "city", "from": "rebel_hall", "tag": "quarter", "to": "works", "every": 1, "warn": 6}})
	_tick(g, 1.25)
	_tick(g, 7.0)
	_tick(g, 2.0)
	var q: Array = r.tagged("quarter")
	_look(g, q[0].center().lerp(q[q.size() - 1].center(), 0.5))
	await _shot("5_buildings_convert")
	r.act({"spread_convert": {"name": "city", "stop": true}})
	# 6 THE GEAR PLATES
	var mach: Array = r.tagged("machines")
	for i in mach.size():
		mach[i].position = ford + Vector2(i * 40 - 40, 0)
	r.act({"ground": {"name": "plates", "from": "machines", "kind": "gear", "r": 2, "step": 1, "every": 1, "max": 4}})
	_tick(g, 3.0)
	_look(g, ford)
	await _shot("6_gear_ground")
	# 7 THE SWAMP spreading
	r.act({"ground": {"name": "bog", "at": "ford_west", "kind": "swamp", "team": "stock", "r": 2, "step": 1, "every": 1, "max": 5}})
	_tick(g, 4.0)
	g._update_swamp()
	g.swamp_layer.queue_redraw()
	g.swamp_layer_b.queue_redraw()
	_look(g, r.area_rect("ford_west").get_center())
	await _shot("7_swamp_ground")
	_clear(g, all)
	# 8 SAPPING: the gallery under the ground
	for i in 3:
		foot[i].position = r.area_rect("camp").get_center() + Vector2(i * 20, 0)
	r.act({"sap": {"tag": "column_foot", "to": "ford", "secs": 10, "name": "mine"}})
	_tick(g, 5.0)
	_look(g, r.area_rect("camp").get_center().lerp(ford, 0.5))
	await _shot("8_sap_gallery")
	_tick(g, 6.0)
	_clear(g, all)
	# 9 HIDDEN and FOUND (the Crown's own fog)
	g.reveal = false
	var mil: Array = r.tagged("militia")
	for i in mil.size():
		mil[i].position = vil + Vector2(60 + i * 90, 110)
	r.act({"sleep": {"tag": "militia", "name": "pens", "within": 0}})
	r.act({"hide": {"tag": "militia", "from": "crown", "within": 3, "name": "pens"}})
	var cap: Unit = r.tagged("captain")[0]
	cap.position = mil[0].position + Vector2(-60, 10)
	for i in 3:
		foot[i].position = mil[0].position + Vector2(-90, 40 + i * 20)
	_tick(g, 0.5)
	_look(g, vil + Vector2(100, 0))
	await _shot("9_hidden_found")
	g.reveal = true
	_clear(g, all)
	# 10 A GRANARY held by the other side
	var gran: Building = r.tagged("granary")[0]
	for i in 3:
		foot[i].position = gran.center() + Vector2(-30 + i * 30, float(gran.size.y) * Defs.TILE * 0.5 + 14)
	_tick(g, 1.0)
	_look(g, gran.center())
	await _shot("10_granary_held")
	# 11 the briefing's VERSION line; 12 the hub's CHOICE
	Engine.time_scale = 1.0
	main._to_menu()
	await create_timer(0.5).timeout
	Campaign._cache["%s/missions/%s.json" % [Campaign.DIR, ID]] = mission()
	CampaignMenu.briefing(main, ID)
	await create_timer(0.5).timeout
	await _shot("11_briefing_version")
	main.show_campaign()
	await create_timer(0.5).timeout
	var box: PanelContainer = null
	for n in main.menu.find_children("*", "PanelContainer", true, false):
		if n.find_child("TalkText", true, false) != null or String(n.name).contains("Talk"):
			box = n
	if box == null:
		box = PanelContainer.new()
		box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
		box.custom_minimum_size = Vector2(900, 160)
		box.position = Vector2(190, 520)
		main.menu.add_child(box)
	CampaignMenu._talk(box, {"name": "King Constantine IV", "colour": 4}, ["I will tell you what we chose. First tell me what you would choose."],
		{"flag": "frame_q", "options": [{"id": "brood", "label": "THE SWARM FIRST", "lines": ["So did Ruggieri."]},
			{"id": "clock", "label": "THE CITY FIRST", "lines": ["Ruggieri did not."]}]})
	await create_timer(0.4).timeout
	await _shot("12_hub_choice")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	if _kept != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept)
		f.close()
	quit()
