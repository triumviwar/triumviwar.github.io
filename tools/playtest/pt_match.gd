extends "res://tools/playtest/pt_lib.gd"
## PLAYTEST, in a match (job playtest-campaign-clock): the hands of a player on the map. Everything goes through real input:
## the minimap moves the view (a left click) or orders the selection (a right click), units are picked with a click or a
## box drag, the command card's buttons are clicked where the HUD drew them, buildings are placed with the mouse.
## (Reads the game to know where things are: Game, MissionRun, the HUD's button rects.)

var game: Game
var run: MissionRun
var said_log: Array = []
var _obj_seen := {}
var _fired_seen := {}
var speed := 1.0


# ------------------------------------------------------------------ starting a mission from the menu

## MAIN MENU -> CAMPAIGN -> the line's tab -> its war table -> the mission -> BRIEFING -> difficulty, side -> START, then the
## opening's stills (watched page by page, or SKIPPED). Returns when the match has begun.
func start_mission(line: String, mid: String, diff := "normal", side := "", skip_show := true, watch_pages := 0) -> bool:
	if main.game != null:
		finding("start_mission: a match is still on")
	if button_text("CAMPAIGN") == null:
		main.show_menu()
		await wait(0.3)
	await press_text("CAMPAIGN")
	await wait(0.4)
	await press_name("Line_" + line)
	await wait(0.4)
	await press_name("HotspotList_war_table")
	await wait(0.4)
	if not await press_name("Mission_" + mid):
		finding("start_mission: %s not on the war table" % mid)
		return false
	await wait(0.3)
	await press_name("Mode_solo")
	await press_name("Campaign_Go")
	await wait(0.4)
	if side != "":
		await press_name("Side_" + side)
		await wait(0.3)
	await press_name("Diff_" + diff)
	await wait(0.3)
	await snap("%s_briefing_%s" % [mid, diff], 0.2)
	if not await press_name("Briefing_Start"):
		return false
	# the opening (StillShow)
	var pages := 0
	for i in 200:
		await wait(0.25)
		if main.game != null and ctrl("StillShow") == null:
			break
		var ss := ctrl("StillShow")
		if ss == null:
			continue
		if pages < watch_pages:
			pages += 1
			if pages <= 3 or pages == watch_pages:
				await snap("%s_opening_p%d" % [mid, pages], 0.4)
			layout_check("%s opening page %d" % [mid, pages])
			if ctrl("Show_NEXT", "Button"):
				await press_name("Show_NEXT")
			else:
				await key(KEY_SPACE)
			continue
		if skip_show:
			if ctrl("Show_SKIP", "Button"):
				await press_name("Show_SKIP")
			else:
				await key(KEY_ESCAPE)
	for i in 80:
		if main.game != null and main.game.mission != null:
			break
		await wait(0.25)
	game = main.game
	if game == null or game.mission == null:
		finding("start_mission: the match did not begin (page: %s)" % [page_texts(8)])
		return false
	run = game.mission
	run.said.connect(func(ln: Dictionary) -> void:
		said_log.append(ln)
		print("PT SAID %6.1f %s: %s" % [game.clock, String(ln.get("name", "")), String(ln.get("text", "")).substr(0, 140)]))
	note("mission %s begun, difficulty %s, side %s" % [mid, run.difficulty, run.my_side()])
	return true


func set_speed(s: float) -> void:
	speed = s
	Engine.time_scale = s
	Engine.max_physics_steps_per_frame = maxi(8, int(ceil(s * 2)))


## Watch the run's state: print every trigger that fired and every objective that changed.
func watch() -> void:
	if run == null or not is_instance_valid(game):
		return
	for k in run.fired:
		if not _fired_seen.has(k):
			_fired_seen[k] = true
			print("PT FIRED %6.1f %s" % [game.clock, k])
	for k in run.obj:
		if String(_obj_seen.get(k, "")) != String(run.obj[k]):
			_obj_seen[k] = run.obj[k]
			print("PT OBJ %6.1f %s -> %s" % [game.clock, k, run.obj[k]])


## Game seconds (the match's clock) pass, the run watched meanwhile; stops early when the match is over.
func play_for(game_secs: float) -> void:
	var until := game.clock + game_secs
	while is_instance_valid(game) and not game.over and game.clock < until:
		await wait(0.2)
		watch()
		await answer_choice()


## A choice on screen: the driver's pick for it (choice_picks: {choice id: option id}; "wait" lets the default come).
var choice_picks := {}


func answer_choice() -> void:
	if run == null or run.choice_open.is_empty():
		return
	var cid := String(run.choice_open["id"])
	var want := String(choice_picks.get(cid, ""))
	if want == "" or want == "wait":
		return
	var pnl := ctrl("Choice_" + cid)
	if pnl == null:
		return
	await snap("choice_%s" % cid, 0.1)
	layout_check("choice %s" % cid)
	var b: Button = pnl.find_child("Choose_" + want, true, false)
	if b == null:
		finding("choice %s has no option %s" % [cid, want])
		choice_picks[cid] = "wait"
		return
	await press(b, "choice %s=%s" % [cid, want])
	await frames(2)
	note("chose %s = %s (flag now %s)" % [cid, want, run.flags.get(cid, "?")])
	choice_picks[cid] = "done"


# ------------------------------------------------------------------ the map on screen

func w2s(w: Vector2) -> Vector2:
	return game.get_viewport().get_canvas_transform() * w


## The part of the screen the map shows (not under the HUD's bottom bar and top bar).
## (the middle of the view: the mission's objectives panel lies over the left and its dialogue box over the right, and
## a click there lands on them, not on the map)
func play_rect() -> Rect2:
	var vr := root.get_visible_rect()
	var top := vr.size.y * 0.14
	var bottom := vr.size.y * (0.70 if Settings.pc() else 0.62)
	return Rect2(Vector2(vr.size.x * 0.33, top), Vector2(vr.size.x * 0.34, bottom - top))


func on_screen(w: Vector2) -> bool:
	return play_rect().has_point(w2s(w))


## The minimap's point for a world point.
func mini_point(w: Vector2) -> Vector2:
	var m: Rect2 = game.hud.mini_rect()
	return hud_pt(m.position + m.size * (w / (Vector2(Game.W, Game.H) * Game.T)).clamp(Vector2.ZERO, Vector2.ONE))


## The HUD draws in its own scale (HUD.ui_scale: bigger on a phone): a point of its rects on the screen.
func hud_pt(p: Vector2) -> Vector2:
	return p * float(game.hud.ui_scale)


## Move the view there: a click on the minimap (as a player does).
func look_at(w: Vector2) -> void:
	await click_at(mini_point(w))
	await frames(2)
	if not on_screen(w):
		# (the minimap's click centres the view; a point near the map's edge can't be centred)
		pass


## A unit or building where a click lands on it (its sprite's middle is above its feet).
func spot_of(e: Entity) -> Vector2:
	if e is Building:
		return (e as Building).rect().get_center()
	return e.position + Vector2(0, -8)


## Select these units: one click for one, a box around them (when they fit in the view), else a click and Shift-clicks.
func select(units: Array) -> void:
	units = units.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)
	if units.is_empty():
		return
	var c := Vector2.ZERO
	for u in units:
		c += (u as Unit).position
	c /= units.size()
	if not on_screen(c):
		await look_at(c)
	if units.size() == 1:
		await click_at(w2s(spot_of(units[0])))
		return
	var r := Rect2(w2s(units[0].position), Vector2.ZERO)
	for u in units:
		r = r.expand(w2s((u as Unit).position))
	r = r.grow(22)
	if play_rect().encloses(r) and (not touch or Settings.drag_mode == "box"):
		await drag(r.position, r.end)
		return
	await click_at(w2s(spot_of(units[0])))
	if touch:
		return
	for i in range(1, units.size()):
		if on_screen(units[i].position):
			await click_at(w2s(spot_of(units[i])), MOUSE_BUTTON_LEFT, true)


## Order the selection to a world point: a right click on the minimap (a tap on the minimap with MOVE on a phone).
func order_to(w: Vector2, attack := false) -> void:
	if touch:
		if attack:
			await press_card(["ATTACK"])
		else:
			await press_card(["MOVE"])
		await click_at(mini_point(w))
		return
	if attack:
		await key(KEY_A)
		await click_at(mini_point(w))
		return
	await click_at(mini_point(w), MOUSE_BUTTON_RIGHT)


## Right click on an entity in view (attack it, or the smart command).
func order_on(e: Entity) -> void:
	if not on_screen(e.position):
		await look_at(e.position)
	if touch:
		await click_at(w2s(spot_of(e)))
	else:
		await right_click_at(w2s(spot_of(e)))


# ------------------------------------------------------------------ the command card

func card() -> Array:
	if game == null or game.hud == null:
		return []
	var out_c: Array = []
	for bt in game.hud._card_buttons:
		var it: Array = bt["item"]
		out_c.append({"icon": String(it[0]), "label": String(it[1]).trim_prefix("> ").trim_prefix("~ "), "enabled": bool(it[3]),
			"why": String(it[4]), "rect": bt["rect"]})
	return out_c


func card_text() -> String:
	return ", ".join(card().map(func(b) -> String: return "%s%s" % [b["label"], "" if b["enabled"] else "(x)"]))


## Click the first card button whose label (English) is one of these, or whose icon is. True when pressed.
func press_card(labels: Array, quiet := false) -> bool:
	game.hud._refresh_card()
	for b in card():
		if labels.has(b["label"]) or labels.has(b["icon"]) or labels.has(Loc.t(String(b["label"]))):
			if not b["enabled"]:
				if not quiet:
					note("card button %s disabled: %s" % [b["label"], b["why"]])
				return false
			await click_at(hud_pt((b["rect"] as Rect2).get_center()))
			await frames(2)
			return true
	if not quiet:
		note("no card button %s (card: %s)" % [labels, card_text()])
	return false


## Build: with a worker selected, BUILD (if the card has it), the building's button, then a click on the cell.
func build(worker: Unit, kind: String, cell: Vector2i) -> bool:
	await select([worker])
	await frames(2)
	var name_en := String(Defs.BUILDINGS[kind].get("name", kind))
	var labels := [kind, name_en, name_en.to_upper(), "b_" + kind]
	if not await press_card(labels, true):
		if not await press_card(["BUILD", "build", "ab_build"], true):
			note("build %s: no BUILD on the card (%s)" % [kind, card_text()])
			return false
		await frames(2)
		if not await press_card(labels, true):
			# (the build pages: try the next page)
			await press_card(["MORE", "NEXT", "ab_more"], true)
			if not await press_card(labels):
				return false
	# (the ghost's cell is its top-left: the mouse goes to the footprint's middle, as Controls._move_ghost reads it)
	var w := Vector2(cell) * Game.T + Vector2(Defs.BUILDINGS[kind]["size"]) * Game.T * 0.5
	if not on_screen(w):
		await look_at(w)
	var sp := w2s(w)
	_mouse_move(to_window(sp))
	await frames(2)
	if game.controls.ghost_cell != cell:
		note("build %s: the ghost is at %s, wanted %s" % [kind, game.controls.ghost_cell, cell])
	await click_at(sp)
	await frames(3)
	if game.controls.mode == "place":
		note("build %s at %s: still placing (%s)" % [kind, cell, game.placement_problem(game.human, kind, game.controls.ghost_cell)])
		await key(KEY_ESCAPE)
		return false
	return true


func mine(kind := "") -> Array:
	return game.units.filter(func(u) -> bool: return not u.dead and u.team == game.human and (kind == "" or u.kind == kind))


func my_buildings(kind := "") -> Array:
	return game.buildings.filter(func(b) -> bool: return not b.dead and b.team == game.human and (kind == "" or b.kind == kind))


func gold() -> int:
	return int(game.players[game.human]["gold"])


# ------------------------------------------------------------------ the pause menu

## The HUD's menu (MENU in the top bar or Esc), then one of its items by label.
func menu_item(label: String) -> bool:
	if not game.hud.menu_open:
		await click_at(hud_pt(game.hud.menu_rect().get_center()))
		await frames(3)
	for b in game.hud._menu_buttons():
		if String(b["label"]).begins_with(label):
			await click_at(hud_pt((b["rect"] as Rect2).get_center()))
			await frames(3)
			return true
	finding("pause menu has no %s (%s)" % [label, game.hud._menu_buttons().map(func(x): return x["label"])])
	return false


## The end of the mission: wait for the ending's stills (watched or skipped) and the end panel; returns its title.
func await_end(watch_pages := 2) -> String:
	for i in 600:
		if not is_instance_valid(game) or game.over:
			break
		await wait(0.25)
		watch()
	set_speed(1.0)
	var pages := 0
	for i in 160:
		await wait(0.25)
		var me := ctrl("MissionEnd")
		if me:
			await wait(0.5)
			var t := page_texts(30)
			note("END PANEL: %s" % [t])
			await snap("end_panel", 0.3)
			layout_check("end panel")
			return String(t[0]) if not t.is_empty() else ""
		if ctrl("StillShow"):
			pages += 1
			if pages <= watch_pages:
				await snap("ending_p%d" % pages, 0.4)
				layout_check("ending page %d" % pages)
				await key(KEY_SPACE)
			else:
				await key(KEY_ESCAPE)
	finding("the mission's end panel never came")
	return ""
