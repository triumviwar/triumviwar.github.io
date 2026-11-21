extends "res://tools/playtest/pt_hub.gd"
## The base of the mission players: from the main menu through the hub, the war map (the pin, BRIEFING, the
## difficulty, START), the opening's stills, the mission with real input (F2 = the army, A + a click on the minimap =
## attack-move there, a click on a building, a click on the command card's button, the dialogue's NEXT / SKIP, the
## choice's buttons) and the end screen. A mission player overrides think() (called every few game seconds).
##   -- diff=easy|normal|hard  speed=<time scale>  style=careful|idle|reckless|...
var mid := ""
var diff := "normal"
var speed := 8.0
var style := "careful"
var said: Array = []                 # every line said: [game clock, id, name, text]
var choices_seen: Array = []
var end_title := ""
var think_every := 3.0
var _last_obj := {}
var shots_every := 0.0               # a screenshot every so many game seconds (0: none but the named ones)


func setup() -> void:
	diff = String(args.get("diff", diff))
	speed = float(args.get("speed", speed))
	style = String(args.get("style", style))
	progress = String(args.get("progress", progress))
	shots_every = float(args.get("shots", shots_every))
	tag = "%s_%s_%s_%s_%s" % [mid, style, diff, device, lang]
	var p := prog_for(progress)
	p["difficulty"] = diff
	Campaign.save_progress(p)


func g() -> Game:
	return main.game if main and is_instance_valid(main.game) else null


func r() -> MissionRun:
	return g().mission if g() else null


func hud() -> Control:
	return g().hud if g() else null


# ------------------------------------------------------------------ getting there

## Main menu -> CAMPAIGN -> the Crown -> WAR TABLE -> the pin -> BRIEFING -> difficulty -> START.
func enter(via := "map") -> bool:
	await press_text("CAMPAIGN")
	await frames(6)
	await press_name("Line_prologue", false)
	await frames(6)
	await press_name("HotspotList_war_table")
	await frames(10)
	if via == "map":
		var w := by_name("WarMap") as WarMap
		if not check("the war map opens", w != null):
			return false
		if by_name("Card_Close"):
			await press_name("Card_Close")
		var pn := WarMapData.pin_of(mid)
		await press_name("View_" + String({"p01_leaf": "virginia"}.get(mid, "europe")), false)
		await wait(0.6)
		await click_at(to_window(w, w.pin_screen(pn)))
		for i in 20:
			await wait(0.2)
			if by_name("Card_Briefing"):
				break
		if not check("the %s pin opens its card" % mid, w.selected == mid and by_name("Card_Briefing") != null, "selected=" + w.selected):
			await shot("enter_fail")
			note("card: %s" % labels_text().left(400))
			return false
		await press_name("Card_Briefing")
	else:
		await press_name("WarMap_List")
		await frames(6)
		var t := Loc.t(String(Campaign.mission(mid).get("title", mid)))
		await press_text(t, true, false)
		await frames(4)
		await press_text("BRIEFING")
	await frames(8)
	if not check("%s: the briefing opens" % mid, by_name("Briefing_Start") != null):
		return false
	await press_name("Diff_" + diff)
	await frames(6)
	check("difficulty %s kept" % diff, Campaign.difficulty() == diff)
	await shot("00_briefing")
	off_screen("briefing")
	cut_text("briefing")
	flush_errors("briefing")
	await press_name("Briefing_Start")
	await frames(10)
	return true


## The opening's stills: read each page (NEXT) with a shot, or SKIP at once.
func opening(skip := false) -> void:
	var n := 0
	while by_name("StillShow") and n < 60:
		if n < 12:
			await shot("01_opening_%02d" % n)
			off_screen("opening page %d" % n)
		if skip:
			await press_name("Show_SKIP")
		else:
			await press_name("Show_NEXT")
		n += 1
		await frames(4)
	note("opening: %d presses" % n)
	var guard := 0
	while g() == null and guard < 300:
		await frames(1)
		guard += 1
	check("%s: the match starts after the opening" % mid, g() != null)
	if g():
		g().mission.said.connect(func(ln: Dictionary) -> void:
			said.append([g().clock if g() else -1.0, String(ln.get("id", "")), String(ln.get("name", "")), String(ln.get("text", ""))]))
		g().mission.choice_offered.connect(func(ch: Dictionary) -> void: choices_seen.append(String(ch.get("id", ""))))
		await frames(5)
		await shot("02_start")
		flush_errors("mission start")


# ------------------------------------------------------------------ in the match: a human's hands

## Where a world point is in the window.
func w2win(p: Vector2) -> Vector2:
	return root.get_final_transform() * (g().get_viewport().get_canvas_transform() * p)


## Where a world point is on the minimap, in the window.
func mini_win(p: Vector2) -> Vector2:
	var m: Rect2 = hud().mini_rect()
	var f := p / (Vector2(Game.W, Game.H) * Game.T)
	return to_window(hud(), m.position + f.clamp(Vector2.ZERO, Vector2.ONE) * m.size)


## F2 (the army), A, a click on the minimap at the point: the army attack-moves there.
func army_to(p: Vector2, attack := true) -> void:
	await key(KEY_F2)
	await key(KEY_A if attack else KEY_M)
	await click_at(mini_win(p))


## A right-click on a unit (the camera taken there first): the selection attacks it.
func attack_unit(u: Node2D) -> void:
	if u == null or not is_instance_valid(u):
		return
	await look_at(u.global_position)
	await click_at(w2win(u.global_position), MOUSE_BUTTON_RIGHT)


## A control group: Ctrl+n sets it from the selection, n selects it.
func group_set(n: int) -> void:
	await key(KEY_0 + n as Key, {"ctrl": true})


func group(n: int) -> void:
	await key(KEY_0 + n as Key)


## A box dragged with the left mouse around these units (their screen points), the camera on them first.
func box_select(us: Array) -> void:
	if us.is_empty():
		return
	await look_at(centroid(us))
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for u in us:
		var p := w2win((u as Node2D).global_position)
		lo = lo.min(p)
		hi = hi.max(p)
	await drag(lo - Vector2(14, 22), hi + Vector2(14, 10))


## The selection (whatever it is) attack-moves to a point: A and a click on the minimap.
func army_sel_to(p: Vector2) -> void:
	await key(KEY_A)
	await click_at(mini_win(p))


## Every one of these units selected as a player would: Ctrl+click one (all of its kind on screen), then
## Shift+double-click one still left out (adds its kind on that screen), until all are in or 8 tries.
func select_all(us: Array) -> void:
	us = us.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)
	if us.is_empty():
		return
	await look_at(us[0].global_position)
	await click_at(w2win(us[0].global_position), MOUSE_BUTTON_LEFT, {"ctrl": true})
	for i in 8:
		var left := us.filter(func(u) -> bool: return is_instance_valid(u) and not g().selection.has(u))
		if left.is_empty():
			break
		await look_at(left[0].global_position)
		await double_click_at(w2win(left[0].global_position), {"shift": true})


## The camera there: a click on the minimap.
func look_at(p: Vector2) -> void:
	await click_at(mini_win(p))
	await frames(2)


## A building picked with the mouse (the camera taken there first).
func pick(e: Node2D) -> bool:
	if not is_instance_valid(e) or e.dead:
		return false
	await look_at(e.global_position)
	var up := Vector2(0, -0.6 * Defs.TILE)
	await click_at(w2win(e.global_position + up))
	await frames(2)
	if not g().selection.has(e):
		await click_at(w2win(e.global_position + up * 2.0))
		await frames(2)
	return g().selection.has(e)


## The command card's button whose label holds `t` (case-insensitive), clicked. Its state when found.
func card(t: String) -> String:
	if hud() == null:
		return "none"
	hud()._refresh_card()
	for bt in hud()._card_buttons:
		var lab := String(bt["item"][1]).to_upper()
		if lab.find(t.to_upper()) >= 0:
			var rc: Rect2 = bt["rect"]
			await click_at(to_window(hud(), rc.get_center()))
			return "pressed" if bt["enabled"] else "disabled: " + String(bt.get("why", ""))
	return "none"


func card_labels() -> Array:
	if hud() == null:
		return []
	hud()._refresh_card()
	return hud()._card_buttons.map(func(bt: Dictionary) -> String:
		return String(bt["item"][1]) + ("" if bt["enabled"] else " (off: %s)" % String(bt.get("why", ""))))


## The in-match MENU (top right), then one of its buttons by label (its start).
func menu_open() -> void:
	await click_at(to_window(hud(), hud().menu_rect().get_center()))
	await frames(3)


func menu_labels() -> Array:
	return hud()._menu_buttons().map(func(b: Dictionary) -> String: return String(b["label"]))


func menu_press(label: String) -> bool:
	for b in hud()._menu_buttons():
		if String(b["label"]).begins_with(label):
			await click_at(to_window(hud(), (b["rect"] as Rect2).get_center()))
			await frames(3)
			return true
	check("menu button there: " + label, false, str(menu_labels()))
	return false


## Train one unit at a building (picked with the mouse, then its card button).
func train(b: Node2D, label: String) -> String:
	if not await pick(b):
		return "not picked"
	return await card(label)


## A choice on screen: its option pressed.
func choose_if(cid: String, oid: String) -> bool:
	var p := by_name("Choice_" + cid)
	if p == null:
		return false
	await shot("choice_" + cid)
	off_screen("choice " + cid)
	note("choice %s on screen: %s" % [cid, labels_text().left(300)])
	return await press_name("Choose_" + oid)


func team_units(team_id: String, kinds: Array = []) -> Array:
	var t := r().team_index(team_id)
	return g().units.filter(func(u: Unit) -> bool: return not u.dead and u.team == t and (kinds.is_empty() or u.kind in kinds))


func side_units(side_id: String) -> Array:
	var ts := r().teams_of_side(side_id)
	return g().units.filter(func(u: Unit) -> bool: return not u.dead and u.team in ts)


func nearest(list: Array, to: Vector2) -> Node2D:
	var best: Node2D = null
	var bd := INF
	for e in list:
		if not is_instance_valid(e):
			continue
		var d: float = (e as Node2D).global_position.distance_to(to)
		if d < bd:
			bd = d
			best = e
	return best


func centroid(list: Array) -> Vector2:
	var c := Vector2.ZERO
	list = list.filter(func(e) -> bool: return is_instance_valid(e))
	for e in list:
		c += (e as Node2D).global_position
	return c / maxf(1.0, list.size())


func area(n: String) -> Vector2:
	return r().area_rect(n).get_center()


## The objectives as the player sees them (state and text), printed when they change.
func watch_objectives() -> void:
	var now := {}
	for o in r().objectives_for(r().my_side()):
		now[String(o["id"])] = String(o["state"])
		if String(_last_obj.get(String(o["id"]), "")) != String(o["state"]):
			note("t=%d objective %s -> %s: %s" % [g().clock, o["id"], o["state"], r().objective_text(o)])
	_last_obj = now


# ------------------------------------------------------------------ the loop

## Play until the match ends (or `limit` game seconds): think() every think_every game seconds at `speed`.
func run_mission(limit := 2400.0) -> void:
	var next_think := 0.0
	var next_shot := shots_every
	var next_flush := 30.0
	Engine.time_scale = speed
	var guard := 0
	while g() and not g().over and g().clock < limit and guard < 2000000:
		guard += 1
		await process_frame
		if g() == null or g().over:
			break
		if g().clock >= next_think:
			next_think = g().clock + think_every
			watch_objectives()
			Engine.time_scale = 1.0
			await think()
			Engine.time_scale = speed
		if shots_every > 0.0 and g() and g().clock >= next_shot:
			next_shot += shots_every
			Engine.time_scale = 1.0
			await shot("t%04d" % int(g().clock))
			Engine.time_scale = speed
		if g() and g().clock >= next_flush:
			next_flush += 30.0
			flush_errors("t=%d" % int(g().clock))
	Engine.time_scale = 1.0
	if g():
		watch_objectives()
		note("match over=%s at t=%d winner_side='%s' flags=%s" % [g().over, g().clock, r().winner_side, r().flags])


func think() -> void:
	pass


## The end: the ending's stills (read through), the end panel (shot, its buttons, the story line).
func ending(read := true) -> String:
	var guard := 0
	while guard < 600 and by_name("StillShow") == null and by_name("MissionEnd") == null:
		await frames(1)
		guard += 1
	var n := 0
	while by_name("StillShow") and n < 40:
		if n < 8:
			await shot("08_ending_%02d" % n)
		await press_name("Show_NEXT" if read else "Show_SKIP")
		n += 1
		await frames(4)
	guard = 0
	while guard < 300 and by_name("MissionEnd") == null:
		await frames(1)
		guard += 1
	var me := by_name("MissionEnd")
	if not check("%s: the end screen" % mid, me != null):
		return ""
	await shot("09_end")
	off_screen("end screen")
	cut_text("end screen")
	var txt := labels_text()
	note("end screen: " + txt.left(700))
	end_title = txt.split(" | ")[0] if txt != "" else ""
	flush_errors("end")
	return txt


func print_said() -> void:
	var ids: Array = said.map(func(s: Array) -> String: return String(s[1]))
	note("lines said (%d): %s" % [said.size(), ", ".join(ids)])
	for s in said:
		if String(s[3]).strip_edges() == "" or String(s[2]).strip_edges() == "":
			print("FINDING empty line text or name: %s" % [s])
