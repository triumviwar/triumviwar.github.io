extends SceneTree
## Pictures for the UI design review (job qa-ui-review, docs/qa_ui_review.md, docs/shots/qa_ui_review/). One PART a run:
##   camp          the campaign hubs of the three lines, the war map in its three skins, a briefing, p01's opening
##                 still, the mission's dialogue and objectives, a tutorial lesson
##   match_<fac>   a sandbox match of crown / clockwork / brood: the base with its buildings, the army selected, the
##                 main command cards, MAKE (every production building), a big battle, supply block, the end screen
##   misc          the ranked page, the online page, a replay playing
## Leaves user://campaign.json as it was. A picture tool, not a test: it changes no game code.
##   xvfb-run -a -s "-screen 0 1600x900x24" godot --rendering-driver opengl3 --resolution 1600x900 \
##       --script res://tools/shot_qa_ui_review.gd -- <outdir> <pc|mobile> <part>
var main
var out := ""
var dev := "pc"
var part := ""
var _kept := ""


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	out = a[0]
	dev = a[1]
	part = a[2]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	if FileAccess.file_exists(Campaign.PROGRESS):
		_kept = FileAccess.get_file_as_string(Campaign.PROGRESS)
	Settings.load_all()
	Settings.device = dev
	Settings.set_language("en")
	Settings.apply()
	DirAccess.make_dir_recursive_absolute(out)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _snap(name: String, wait := 0.6) -> void:
	await create_timer(wait).timeout
	await process_frame
	await process_frame
	root.get_viewport().get_texture().get_image().save_jpg("%s/%s_%s.jpg" % [out, dev, name], 0.85)
	print("shot ", name)


func _run() -> void:
	await create_timer(0.8).timeout
	if part == "camp":
		await _camp()
	elif part.begins_with("match_"):
		await _match(part.substr(6))
	elif part == "misc":
		await _misc()
	if _kept != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept)
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	quit()


# ------------------------------------------------------------------ campaign

const ACT1 := {
	"p01_leaf": ["crown", {"families": "save"}],
	"c01_thirteenth": ["guild", {"bells": "rung", "saved": "many", "saved_n": 34, "jakob": "alive", "cut": "yes", "gate": "pattern"}],
	"b01_specimen": ["sire", {"teles": "quiet", "clutch": "saved", "saved": "some", "saved_n": 9, "pieter": "alive"}],
	"a02_furth": ["guild", {"furth": "strong"}],
	"a03_plateau": ["party", {"map": "drawn", "party": "some"}],
	"a01_presses": ["crown", {"lyon": "calm"}],
}


func _progress(done: Dictionary) -> Dictionary:
	var p := {"reached": [], "done": {}}
	for mid in done:
		p["done"][mid] = {"won_by": done[mid][0], "side": done[mid][0], "flags": done[mid][1]}
		if not Campaign.storyline_of(mid).is_empty():
			var nx := Campaign.next_of(mid, String(done[mid][0]))
			if nx != "":
				p["reached"].append(nx)
	return p


func _camp() -> void:
	Campaign.save_progress(_progress(ACT1))
	for l in ["prologue", "clockmaker", "naturalist"]:
		CampaignMenu.line = l
		CampaignMenu.show(main)
		await _snap("camp_hub_" + l, 1.2)
	CampaignMenu.line = "prologue"
	CampaignMenu.pick = "a06_barricades"
	CampaignMenu.war_table(main)
	await _snap("camp_war_table", 1.0)
	for skin in ["parchment", "brass", "chart"]:
		CampaignMenu.line = {"parchment": "prologue", "brass": "clockmaker", "chart": "naturalist"}[skin]
		CampaignMenu.map_open = false
		CampaignMenu.map_cam = {}
		CampaignMenu.map_pick = ""
		CampaignMenu.map_skin = skin
		CampaignMenu.war_map(main)
		await _snap("camp_warmap_" + skin, 1.4)
	CampaignMenu.map_skin = "parchment"
	CampaignMenu.line = "prologue"
	CampaignMenu.map_open = false
	CampaignMenu.map_pick = "a06_barricades"
	CampaignMenu.war_map(main)
	await _snap("camp_warmap_pin_card", 1.4)
	CampaignMenu.map_open = false
	CampaignMenu.briefing(main, "a06_barricades")
	await _snap("camp_briefing", 1.0)
	# p01's opening still, then the mission itself: dialogue and objectives
	var m := Campaign.mission("p01_leaf")
	var sh := StillShow.play(main.ui_layer, m, Campaign.show_pages(m, "opening"), func() -> void: pass)
	sh.auto = false
	await _snap("camp_opening_still", 1.2)
	sh.finish()
	main.start(Campaign.make_cfg("p01_leaf", "solo"))
	await create_timer(1.0).timeout
	var g: Game = main.game
	paused = false
	for t in [6.0, 20.0, 45.0]:
		while g.clock < t:
			await create_timer(0.25).timeout
		await _snap("camp_mission_p01_%ds" % int(t), 0.1)
	main._to_menu()
	await process_frame
	# c01 a moment in (snow, the machine's town)
	main.start(Campaign.make_cfg("c01_thirteenth", "solo"))
	await create_timer(1.0).timeout
	g = main.game
	while g.clock < 15.0:
		await create_timer(0.25).timeout
	await _snap("camp_mission_c01_15s", 0.1)
	main._to_menu()
	await process_frame
	# the tutorial list and a lesson
	main.show_tutorial()
	await _snap("tut_list", 0.8)
	var ids: Array = Tutorial.lesson_ids()
	if not ids.is_empty():
		TutorialMenu.start(main, String(ids[0]))
		await create_timer(1.0).timeout
		g = main.game
		if g:
			while g.clock < 8.0:
				await create_timer(0.25).timeout
			await _snap("tut_lesson1", 0.1)
		main._to_menu()
		await process_frame
	if ids.size() > 2:
		TutorialMenu.start(main, String(ids[2]))
		await create_timer(1.0).timeout
		g = main.game
		if g:
			while g.clock < 8.0:
				await create_timer(0.25).timeout
			await _snap("tut_lesson3", 0.1)


# ------------------------------------------------------------------ a match

const BUILD := {
	"crown": ["farm", "farm", "powder_mill", "barracks", "barracks", "foundry", "horse_breeder", "armoury", "cottage", "church"],
	"clockwork": ["cog_press", "cog_press", "mainspring", "movement_works", "movement_works", "escapement", "heavy_works", "regulator", "cuckoo_house", "ratchet_turret"],
	"brood": [],
}
const ARMY := {
	"crown": {"musketeer": 16, "cuirassier": 4, "cannon": 3, "mortar": 1, "dragoon": 3, "band": 1},
	"clockwork": {"clock_soldier": 12, "springer": 4, "netter": 3, "pendulum": 3, "ballista": 2, "winder": 3},
	"brood": {"raptor": 16, "spitter": 8, "brute": 3, "tyrant_challenger": 1, "venom_challenger": 1, "skywing": 3},
}
const CARDS := {
	"crown": ["barracks", "foundry", "horse_breeder", "armoury", "musketeer", "cannon", "cuirassier", "labourer"],
	"clockwork": ["movement_works", "heavy_works", "escapement", "winder", "clock_soldier", "springer", "pendulum"],
	"brood": ["brood_mother", "grub", "raptor", "spitter", "tyrannosaur", "rootmaw", "mound_turtle"],
}


func _spot(g: Game, near: Vector2i, size: Vector2i) -> Vector2i:
	for r in range(4, 30):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if absi(dx) != r and absi(dy) != r:
					continue
				var c := near + Vector2i(dx, dy)
				if not g.in_map(c) or not g.margin_free(c, size):
					continue
				var ok := true
				for yy in range(-1, size.y + 1):
					for xx in range(-1, size.x + 1):
						if not g.in_map(c + Vector2i(xx, yy)) or not g.is_free(c + Vector2i(xx, yy)):
							ok = false
				if ok:
					return c
	return Vector2i(-1, -1)


func _match(fac: String) -> void:
	var foe := "brood" if fac != "brood" else "crown"
	main.start({"map": "greenhold", "seed": 7, "slots": [
		{"who": "you", "faction": fac, "colour": 0, "side": 0},
		{"who": "easy", "faction": foe, "colour": 1, "side": 1}]})
	await process_frame
	await process_frame
	var g: Game = main.game
	g.hud.countdown = 0.0
	paused = false
	for ai in g.ais:
		ai.process_mode = Node.PROCESS_MODE_DISABLED
	g.players[0]["gold"] = 6400
	if g.players[0].has("tension"):
		g.players[0]["tension"] = 800.0
	var halls: Array = g.halls_of(0)
	if halls.is_empty():
		for u in g.units:
			if is_instance_valid(u) and u.team == 0 and String(u.kind) == "brood_mother":
				halls.append(u)
	var hall = halls[0]
	var things := {}
	things[String(hall.kind)] = hall
	for k in BUILD[fac]:
		if fac == "clockwork":
			var b = load("res://tools/gear_test_util.gd").put(g, 0, k, hall.cell, k == "heavy_works")
			if b:
				things[k] = b
			continue
		var size: Vector2i = Defs.BUILDINGS[k]["size"]
		var c := _spot(g, hall.cell, size)
		if c.x >= 0:
			var b = g._add_building(k, 0, c, true)
			things[k] = b
	if fac == "brood":
		for k in ["rootmaw", "rootmaw", "mound_turtle", "tyrannosaur"]:
			var u = g._add_unit(k, 0, hall.center() + Vector2(randf_range(-260, 260), randf_range(120, 260)))
			if u:
				things[k] = u
	g._recount_supply(0)
	var army: Array = []
	var at: Vector2 = hall.center() + Vector2(380, 180)
	var i := 0
	for k in ARMY[fac]:
		for n in int(ARMY[fac][k]):
			var u = g._add_unit(k, 0, at + Vector2((i % 8) * 34, (i / 8) * 34))
			if u:
				army.append(u)
				things[k] = u
			i += 1
	for w in g.workers(0):
		things[String(w.kind)] = w
	g._recount_supply(0)
	g.players[0]["cap"] = 200
	await create_timer(1.5).timeout
	# the base, a hall selected
	g.camera.position = hall.center() + Vector2(160, 40)
	g.set_selection([hall])
	await _snap("%s_base_hall" % fac)
	# the army selected
	g.camera.position = at + Vector2(120, 60)
	g.set_selection(army)
	await _snap("%s_army_selected" % fac)
	# the command cards
	for k in CARDS[fac]:
		if not things.has(k) or not is_instance_valid(things[k]):
			continue
		var e = things[k]
		g.set_selection([e])
		g.camera.position = e.center() if e.has_method("center") else e.position
		await _snap("%s_card_%s" % [fac, k], 0.4)
	# MAKE: every production building
	g.hud.bar.select_production()
	await _snap("%s_make" % fac, 0.4)
	# a zoomed-out view (minimap and the whole base)
	var z: Vector2 = g.camera.zoom
	g.camera.zoom = z * 0.55
	g.camera.position = hall.center() + Vector2(200, 100)
	g.set_selection([])
	await _snap("%s_zoomed_out" % fac, 0.6)
	g.camera.zoom = z
	# a big battle in the open: our army against a foe's of the same size
	var mid: Vector2 = hall.center() + Vector2(1100, 300)
	var foes: Array = []
	var j := 0
	for k in ARMY[foe]:
		for n in int(ARMY[foe][k]):
			var u = g._add_unit(k, 1, mid + Vector2(160 + (j % 8) * 30, -120 + (j / 8) * 30))
			if u:
				foes.append(u)
			j += 1
	var k2 := 0
	for u in army:
		if is_instance_valid(u):
			u.position = mid + Vector2(-260 - (k2 % 8) * 30, -120 + (k2 / 8) * 30)
			g.note_move(u)
		k2 += 1
	g.set_selection(army.filter(func(x): return is_instance_valid(x)))
	for u in army:
		if is_instance_valid(u):
			u.cmd_move(mid + Vector2(300, 0), true)
	for u in foes:
		if is_instance_valid(u):
			u.cmd_move(mid + Vector2(-300, 0), true)
	g.camera.position = mid
	await create_timer(3.5).timeout
	g.set_selection(army.filter(func(x): return is_instance_valid(x)))
	await _snap("%s_battle" % fac, 0.1)
	await create_timer(3.0).timeout
	await _snap("%s_battle_late" % fac, 0.1)
	# the in-game menu and the score
	g.hud.toggle_menu(true)
	await _snap("%s_menu" % fac, 0.4)
	g.hud.toggle_menu(false)
	# the end: a win
	g.over = true
	g._sample_stats()
	main._on_end(0)
	await _snap("%s_end" % fac, 2.0)


# ------------------------------------------------------------------ misc

func _misc() -> void:
	main.show_online()
	await _snap("online", 0.8)
	main.show_ranked()
	await _snap("ranked", 0.8)
	main.show_replays()
	await _snap("replays", 0.8)
	main.show_help("BASICS")
	await _snap("help_basics", 0.6)
	main.show_settings("GAMEPLAY")
	await _snap("settings_gameplay", 0.6)
	main.show_layout()
	await _snap("layout", 0.6)
	main.show_editor_menu()
	await _snap("editor_menu", 0.6)
	main.show_map_editor()
	await _snap("map_editor", 1.2)
	main.show_menu()
	await _snap("menu", 0.8)
	main.show_device()
	await _snap("device", 0.6)
	main.show_skirmish()
	await _snap("skirmish", 0.6)
