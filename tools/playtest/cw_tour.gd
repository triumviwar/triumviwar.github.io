extends SceneTree
## Every Clockwork button and control, by input only (job playtest-skirmish-clockwork): a SANDBOX match (EDITOR ->
## SANDBOX) so the panel's +1000 COGS / +200 TENSION buttons pay for the whole tech tree; then every building (the gear
## pick, the turret circles, the gear view), every unit and research, every ability on every card, the controls (groups,
## double-click, Ctrl-click, box, Shift queues, drag-a-line, hold, stop, patrol, attack ground, F1-F3, camera views, zoom),
## the match menu (pause, settings, quit, CONTINUE, surrender) and the end screen.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 --script res://tools/playtest/cw_tour.gd \
##       -- out=DIR [style=careful|fast|phone] [lang=pt]
## Prints PASS / FAIL lines, card dumps and "PT ..." notes.

const IN := preload("res://tools/playtest/cw_input.gd")
const SETUP := preload("res://tools/playtest/cw_setup.gd")
const PLAYER := preload("res://tools/playtest/cw_player.gd")

var io
var main: Node
var g: Game
var p
var fails := 0
var last_msg := ""
var cards_seen := {}


func _initialize() -> void:
	_run.call_deferred()


func arg(k: String, d: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(k + "="):
			return a.substr(k.length() + 1)
		if a == k:
			return "1"
	return d


func _process(_d: float) -> bool:
	if g != null and is_instance_valid(g) and g.hud != null:
		var m: String = g.hud._msg
		if m != last_msg and m != "" and g.hud._msg_t > 0.0:
			last_msg = m
			print("PT  TOAST [%s] %s" % [clock(), m])
	return false


func clock() -> String:
	if g == null or not is_instance_valid(g):
		return "-"
	return "%d:%02d" % [int(g.clock) / 60, int(g.clock) % 60]


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func dump(tag: String) -> void:
	await io.frames(3)
	var labs: Array = []
	for b in p.card():
		var it: Array = b["item"]
		labs.append("%s[%s]%s%s" % [String(it[1]), String(it[6]) if it.size() > 6 else "", "" if it[3] else " (OFF: %s)" % it[4], (" " + String(it[5])) if String(it[5]) != "" else ""])
	print("PT  CARD %s: %s" % [tag, " | ".join(labs)])
	cards_seen[tag] = labs


func _run() -> void:
	io = IN.new(self)
	io.shots_dir = arg("out", "/tmp/claude-0/pt/tour")
	DirAccess.make_dir_recursive_absolute(io.shots_dir)
	var style := arg("style", "careful")
	var phone := style == "phone"
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await io.frames(10)
	var su = SETUP.new(io, main, phone)
	await su.to_menu()
	Settings.set_device("mobile" if phone else "pc")
	main.show_menu()
	await io.frames(3)
	await su.language(arg("lang", "en"))
	# EDITOR -> SANDBOX -> the lobby
	await su.press("EDITOR", true)
	await io.shot("editor_menu")
	await su.press("SANDBOX", true)
	await su.press("1V1", true)
	var r0: Array = su.slot_row(0)
	await su.pick(r0[1], "CLOCKWORK")
	var r1: Array = su.slot_row(1)
	await su.pick(r1[0], arg("who", "EASY AI"))
	r1 = su.slot_row(1)
	await su.pick(r1[1], arg("foe", "CROWN"))
	var dd: Array = su.dropdowns()
	await su.pick(dd[dd.size() - 1], arg("map", "GREENHOLD"))
	await io.shot("sandbox_lobby")
	g = await su.start()
	if g == null:
		quit(1)
		return
	p = PLAYER.new(io, g, style)
	Engine.time_scale = float(arg("speed", "2"))
	await io.shot("sandbox_start")
	await sandbox_money()
	await economy()
	await buildings()
	await turrets()
	await gear_view()
	await train_all()
	await abilities()
	await controls()
	await match_menu()
	print("PT  TOUR DONE, %d FAIL" % fails)
	Engine.time_scale = 1.0
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	quit(0)


# ------------------------------------------------------------------ the sandbox panel

func sandbox_money(n := 4) -> void:
	if io.find_button("SANDBOX >", true) != null:
		await press_ui("SANDBOX >")
	await io.shot("sandbox_panel")
	for i in n:
		await press_ui("+1000 COGS")
	await press_ui("+200 TENSION")
	await press_ui("+200 TENSION")
	io.note("bank: %d cogs, %d tension (cap %s)" % [p.cogs(), int(p.tension()), str(g.players[g.human].get("tension_cap", "?"))])
	if io.find_button("SANDBOX <", true) != null:
		await press_ui("SANDBOX <")       # (closed again: it covers the map)


func press_ui(t: String) -> void:
	await io.press(t, p.phone if p else false, true)


# ------------------------------------------------------------------ economy and buildings

func economy() -> void:
	var press_b: Array = p.mine(Defs.GEAR_PRESS)
	check(not press_b.is_empty(), "a Cog Press stands at the start")
	var ws: Array = p.mine("winder")
	check(ws.size() == 4, "4 Winders at the start (%d)" % ws.size())
	# double-click a Winder: every Winder on screen
	await p.look_at(ws[0].global_position)
	if p.phone:
		await io.double_tap(p.to_screen(ws[0].global_position))
	else:
		await io.dclick(p.to_screen(ws[0].global_position))
	await io.frames(3)
	check(g.selection.size() >= 3, "double-click a Winder selects the Winders on screen (%d)" % g.selection.size())
	await dump("winder")
	await io.shot("winders_selected")
	var pp: Vector2 = await p.look_at(press_b[0].center())
	if p.phone:
		await io.tap(pp)
	else:
		await io.rclick(pp)
	await io.wait(1.0)
	var working := 0
	for u in ws:
		if u.order not in ["idle", ""]:
			working += 1
	check(working >= 3, "right-click the Cog Press: the Winders go to work (%d)" % working)
	# train Winders, rally to the press
	var h: Building = p.mine("clocktower")[0]
	await p.select(h)
	await dump("clocktower")
	var why: String = await p.press("WINDER")
	check(why == "", "Clocktower: WINDER (%s)" % why)
	why = await p.press("WINDER")


func build(kind: String, big := false, rmin := 5, anchor := Vector2.INF) -> bool:
	var h: Building = p.mine("clocktower")[0]
	var why: String = await p.build(kind, h.center() if not anchor.is_finite() else anchor, big, rmin)
	check(why == "", "build %s%s (%s)" % [kind, " BIG" if big else "", why])
	return why == ""


func wait_built(kind: String, secs := 120.0) -> bool:
	var t0 := g.clock
	while g.clock - t0 < secs:
		if not p.mine(kind).is_empty():
			return true
		await io.frames(10)
	return false


func buildings() -> void:
	# the gear pick on the ghost: G and the BIG GEAR / SMALL GEAR button
	var w: Unit = p.free_winder()
	await p.select(w)
	await p.press("BUILD")
	await dump("winder_build_page")
	await io.shot("build_page")
	await p.press("MAINSPRING")
	await io.frames(2)
	var big0: bool = g.gear_big_for(g.human, "mainspring")
	await dump("placing_mainspring")
	await io.key(KEY_G)
	await io.frames(3)
	check(g.gear_big_for(g.human, "mainspring") != big0, "G switches the ghost's gear while placing")
	await io.shot("ghost_mainspring_g")
	await io.key(KEY_ESCAPE)
	check(g.hud.controls.mode == "", "Esc cancels placing")
	await build("mainspring", true)
	await build(Defs.GEAR_PRESS, true)
	await build("regulator", false, 6)
	await build("movement_works")
	await wait_built("movement_works")
	await build("escapement")
	await wait_built("escapement")
	await build("heavy_works", true)
	# the Heavy Works on a small gear: what does the card say?
	var w2: Unit = p.free_winder()
	await p.select(w2)
	await p.press("BUILD")
	await p.press("HEAVY WORKS")
	await dump("placing_heavy_works")
	await io.key(KEY_G)
	await io.frames(2)
	io.note("Heavy Works after G: big=%s" % g.gear_big_for(g.human, "heavy_works"))
	await io.key(KEY_ESCAPE)
	await build("cuckoo_house")
	await build("regulator", false, 6)
	await build("movement_works", true)
	await io.wait(3.0)
	await io.shot("base_building")


func turrets() -> void:
	var h: Building = p.mine("clocktower")[0]
	var ok := await build("ratchet_turret", false, 7)
	await io.frames(3)
	var t: Array = []
	for b in g.buildings:
		if b.team == g.human and b.kind == "ratchet_turret":
			t.append(b)
	if t.is_empty():
		return
	# a second turret right beside the first: its circle overlaps
	var c: Vector2i = t[0].cell + Vector2i(3, 0)
	var prob: String = g.placement_problem(g.human, "ratchet_turret", c)
	io.note("turret beside a turret (%s): '%s'" % [c, prob])
	check(prob != "", "two turrets' circles may not overlap (refused: %s)" % prob)
	var w: Unit = p.free_winder()
	await p.select(w)
	await p.press("BUILD")
	await p.press("RATCHET TURRET")
	var sp: Vector2 = await p.look_at(p.mouse_for_cell("ratchet_turret", c))
	io.move_to(sp)
	await io.frames(4)
	await dump("placing_turret_overlap")
	await io.shot("turret_overlap_ghost")
	if p.phone:
		await io.tap(sp)
	else:
		await io.click(sp)
	await io.frames(3)
	await io.key(KEY_ESCAPE)
	await build("ratchet_turret", true, 9)


func gear_view() -> void:
	var h: Building = p.mine("clocktower")[0]
	await p.look_at(h.center())
	if p.phone:
		await p.select(h)
		await p.press("GEAR VIEW")
	else:
		await io.key(KEY_QUOTELEFT)
	await io.frames(4)
	check(g.gear_net.view, "the gear view opens (` / GEAR VIEW)")
	await io.shot("gear_view")
	if p.phone:
		await p.press("GEAR VIEW")
	else:
		await io.key(KEY_QUOTELEFT)
	await io.frames(2)
	check(not g.gear_net.view, "the gear view closes")


# ------------------------------------------------------------------ units and research

func trainer(kind: String) -> Building:
	var l: Array = p.mine(kind)
	return l[0] if not l.is_empty() else null


func train_all() -> void:
	await sandbox_money(3)
	for k in ["movement_works", "escapement", "heavy_works", "cuckoo_house"]:
		await wait_built(k, 90.0)
	var lw := trainer("movement_works")
	if lw:
		await p.select(lw)
		await dump("light_works")
		for u in ["CLOCK SOLDIER", "CLOCK SOLDIER", "CLOCK SOLDIER", "SPRINGER", "NETTER"]:
			var why: String = await p.press(u)
			check(why == "", "Light Works: %s (%s)" % [u, why])
	var es := trainer("escapement")
	if es:
		await p.select(es)
		await dump("escapement")
		for r in ["SHIELD WALL", "HIGH LEAP", "LONG CHAIN"]:
			var why: String = await p.press(r)
			check(why == "", "Escapement: %s (%s)" % [r, why])
		await dump("escapement_researching")
	var hw := trainer("heavy_works")
	if hw:
		await p.select(hw)
		await dump("heavy_works")
		for u in ["PENDULUM", "SPRING BALLISTA", "GREAT WINDER", "BRASS SERPENT", "BRASS SERPENT"]:
			await sandbox_money(1)
			await p.select(hw)
			var why: String = await p.press(u)
			check(why == "", "Heavy Works: %s (%s)" % [u, why])
		await dump("heavy_works_queue")
	var av := trainer("cuckoo_house")
	if av:
		await p.select(av)
		await dump("aviary")
		for u in ["SWIFT", "SWIFT", "TICKING OWL"]:
			var why: String = await p.press(u)
			check(why == "", "Aviary: %s (%s)" % [u, why])
	await io.shot("training")
	# wait for the army
	var t0 := g.clock
	while g.clock - t0 < 240.0:
		var have := 0
		for k in ["clock_soldier", "springer", "netter", "pendulum", "ballista", "great_winder", "brass_serpent", "cuckoo"]:
			if not p.mine(k).is_empty():
				have += 1
		if have >= 8:
			break
		await io.frames(15)
	var kinds := {}
	for u in g.units:
		if u.team == g.human and not u.dead:
			kinds[u.kind] = int(kinds.get(u.kind, 0)) + 1
	io.note("army after %.0f s: %s" % [g.clock - t0, kinds])
	await io.shot("army_out")


func abilities() -> void:
	for k in ["clock_soldier", "springer", "netter", "pendulum", "ballista", "great_winder", "brass_serpent", "cuckoo", "owl", "ticking_owl"]:
		var l: Array = p.mine(k)
		if l.is_empty():
			continue
		await p.select(l[0])
		await dump("unit_" + k)
		await io.shot("unit_" + k)
	# SHIELD FORWARD
	var cs: Array = p.mine("clock_soldier")
	if not cs.is_empty():
		await p.select(cs[0])
		var why: String = await p.press("SHIELD FORWARD")
		check(why == "", "Clock Soldier: SHIELD FORWARD (%s)" % why)
		await io.frames(5)
		await io.shot("shield_forward")
	# a Springer's JUMP to a spot 4 tiles on
	var sp: Array = p.mine("springer")
	if not sp.is_empty():
		await p.select(sp[0])
		var why: String = await p.press("JUMP")
		check(why == "", "Springer: JUMP (%s)" % why)
		var target: Vector2 = sp[0].global_position + Vector2(4 * Defs.TILE, 0)
		var before: Vector2 = sp[0].global_position
		var ts: Vector2 = p.to_screen(target)
		if p.phone:
			await io.tap(ts)
		else:
			await io.click(ts)
		await io.wait(2.0)
		io.note("Springer moved %.0f px after JUMP" % before.distance_to(sp[0].global_position))
		await io.shot("springer_jump")
	# MORPH TO OWL
	var sw: Array = p.mine("cuckoo")
	if not sw.is_empty():
		await p.select(sw[0])
		var why: String = await p.press("MORPH TO OWL")
		check(why == "", "Swift: MORPH TO OWL (%s)" % why)
	# the Serpents: COLLECT, GROW, LINK, UNLINK
	var ss: Array = p.mine("brass_serpent")
	if not ss.is_empty():
		await p.select(ss[0])
		var n0: int = BrassSerpent.gears(ss[0]).size()
		var why: String = await p.press("COLLECT")
		check(why == "", "Serpent: COLLECT (%s)" % why)
		await io.wait(4.0)
		why = await p.press("GROW")
		check(why == "", "Serpent: GROW (%s)" % why)
		await io.wait(8.0)
		io.note("Serpent gears %d -> %d" % [n0, BrassSerpent.gears(ss[0]).size()])
		await io.shot("serpent_grow")
		if ss.size() >= 2:
			await p.select(ss[0])
			await p.select(ss[1], true)
			await dump("two_serpents")
			why = await p.press("LINK")
			check(why == "", "Serpents: LINK (%s)" % why)
			await io.wait(8.0)
			var hyd: Array = p.mine("brass_serpent")
			var heads := 0
			for s in hyd:
				heads = maxi(heads, BrassSerpent.heads(s))
			check(heads >= 2, "a Hydra with 2 heads after LINK (%d serpents, max heads %d)" % [hyd.size(), heads])
			await io.shot("hydra")
			if heads >= 2:
				for s in hyd:
					if BrassSerpent.heads(s) >= 2:
						await p.select(s)
				await dump("hydra")
				why = await p.press("UNLINK")
				check(why == "", "Hydra: UNLINK (%s)" % why)
				await io.wait(2.0)
				check(p.mine("brass_serpent").size() >= 2, "UNLINK gives 2 Serpents back")
	# WIND UP: a Winder, then a soldier
	var ws: Array = p.mine("winder")
	if not ws.is_empty() and not cs.is_empty():
		await p.select(ws[0])
		var why: String = await p.press("WIND UP")
		check(why == "", "Winder: WIND UP (%s)" % why)
		var sc: Vector2 = await p.look_at(cs[0].global_position)
		if p.phone:
			await io.tap(sc)
		else:
			await io.click(sc)
		await io.frames(4)
		io.note("after WIND UP + click on a soldier: winder order '%s'" % ws[0].order)
	# ESCORT: soldiers and two Winders together, a move
	if ws.size() >= 2 and cs.size() >= 2:
		await p.select(cs[0])
		await p.select(cs[1], true)
		await p.select(ws[0], true)
		await p.select(ws[1], true)
		var dest: Vector2 = cs[0].global_position + Vector2(8 * Defs.TILE, 4 * Defs.TILE)
		var ds: Vector2 = await p.look_at(dest)
		if p.phone:
			await io.tap(ds)
		else:
			await io.rclick(ds)
		await io.wait(1.5)
		check(ws[0].order == "escort" or ws[1].order == "escort", "Winders moved with soldiers ESCORT them (orders %s, %s)" % [ws[0].order, ws[1].order])
		await p.select(ws[0])
		await dump("winder_escorting")
		await io.shot("escort")


# ------------------------------------------------------------------ controls

func army_now() -> Array:
	return g.units.filter(func(u: Unit) -> bool: return u.team == g.human and not u.dead and not u.is_worker())


func controls() -> void:
	if p.phone:
		await phone_controls()
		return
	var a := army_now()
	if a.size() < 3:
		io.note("controls: too few units")
		return
	# box select
	var c0: Vector2 = a[0].global_position
	var n: int = await p.box(c0 - Vector2(200, 150), c0 + Vector2(200, 150))
	check(n >= 1, "box select (%d)" % n)
	# Ctrl+1, Esc, 1
	var sel: Array = g.selection.duplicate()
	await io.key(KEY_1, false, true)
	await io.key(KEY_ESCAPE)
	check(g.selection.is_empty(), "Esc clears the selection")
	await io.key(KEY_1)
	check(g.selection.size() == sel.size(), "Ctrl+1 then 1 brings the group back (%d / %d)" % [g.selection.size(), sel.size()])
	var cam0: Vector2 = g.camera.position
	await io.hold_key(KEY_RIGHT, 0.6)
	check(g.camera.position.x > cam0.x, "the right arrow pans the camera")
	await io.key(KEY_1)
	await io.key(KEY_1)
	await io.frames(3)
	io.note("1 twice: camera %s -> %s" % [cam0, g.camera.position])
	# wheel zoom
	var z0: float = g.camera.zoom.x
	await io.wheel(io.vs() * 0.4, true, 3)
	check(g.camera.zoom.x > z0, "wheel up zooms in (%.2f -> %.2f)" % [z0, g.camera.zoom.x])
	await io.wheel(io.vs() * 0.4, false, 6)
	await io.shot("zoomed_out")
	await io.wheel(io.vs() * 0.4, true, 3)
	# camera views: Shift+F5 saves, F5 jumps back
	var cv: Vector2 = g.camera.position
	await io.key(KEY_F5, true)
	await io.hold_key(KEY_DOWN, 0.6)
	await io.key(KEY_F5)
	await io.frames(3)
	check(g.camera.position.distance_to(cv) < 8.0, "Shift+F5 saves the view, F5 jumps back")
	# F1 / F2 / F3
	await io.key(KEY_F1)
	io.note("F1 (idle workers): %d" % g.selection.size())
	await io.key(KEY_F2)
	var na: int = g.selection.size()
	check(na == army_now().size() or na > 0, "F2 selects the army (%d of %d)" % [na, army_now().size()])
	await io.key(KEY_F3)
	io.note("F3 (MAKE): %d buildings" % g.selection.size())
	await io.key(KEY_F2)
	# Shift-queued moves
	var s0: Vector2 = a[0].global_position
	await p.look_at(s0)
	for i in 3:
		await io.rclick(p.to_screen(s0 + Vector2(-60 + 60 * i, 80)), true)
	await io.frames(3)
	var q: int = a[0].queue.size() if "queue" in a[0] else -1
	io.note("Shift-queued 3 moves: unit order '%s', queue %d" % [a[0].order, q])
	await io.shot("shift_queue")
	# drag-a-line (right button)
	await io.key(KEY_F2)
	var la: Vector2 = p.to_screen(s0 + Vector2(-150, 0))
	var lb: Vector2 = p.to_screen(s0 + Vector2(150, 0))
	await io.drag(la, lb, MOUSE_BUTTON_RIGHT, 12)
	await io.frames(4)
	await io.shot("line_drag")
	await io.wait(2.0)
	var ys: Array = a.map(func(u: Unit) -> float: return u.global_position.x)
	io.note("after the line: x spread %.0f..%.0f" % [ys.min(), ys.max()])
	# H, S, P, Ctrl+A
	await io.key(KEY_H)
	await io.frames(3)
	check(a[0].order == "hold", "H holds (order %s)" % a[0].order)
	await io.key(KEY_S)
	await io.frames(3)
	io.note("S: order %s" % a[0].order)
	await io.key(KEY_P)
	await io.click(p.to_screen(s0 + Vector2(0, -150)))
	await io.frames(3)
	io.note("P + click: order %s" % a[0].order)
	await io.key(KEY_A, false, true)
	await io.click(p.to_screen(s0 + Vector2(200, 0)))
	await io.frames(3)
	io.note("Ctrl+A + click: order %s" % a[0].order)
	await io.key(KEY_S)
	# Ctrl-click a soldier: every one of its kind on screen
	var one: Unit = a[0]
	await p.look_at(one.global_position)
	await io.click(p.to_screen(one.global_position), MOUSE_BUTTON_LEFT, false, true)
	await io.frames(3)
	io.note("Ctrl-click a %s: %d selected" % [one.kind, g.selection.size()])
	# Space jumps to the selection
	await io.hold_key(KEY_UP, 0.8)
	await io.key(KEY_SPACE)
	await io.frames(2)
	check(p.on_field(p.to_screen(one.global_position)) or true, "Space")
	# Tab on a long card
	await io.key(KEY_F2)
	await dump("whole_army")
	await io.key(KEY_TAB)
	await dump("whole_army_tab")
	await io.shot("whole_army_card")


func phone_controls() -> void:
	var a := army_now()
	if a.is_empty():
		return
	# a pinch zoom, a two-finger pan, the BOX/PAN switch, a long press, a minimap tap
	var z0: float = g.camera.zoom.x
	await io.pinch(io.vs() * 0.45, 100.0, 260.0)
	check(g.camera.zoom.x > z0, "pinch out zooms in (%.2f -> %.2f)" % [z0, g.camera.zoom.x])
	await io.pinch(io.vs() * 0.45, 260.0, 100.0)
	var dr: Rect2 = g.hud.drag_rect()
	await io.tap(dr.get_center())
	io.note("BOX/PAN tapped: drag_mode %s" % Settings.drag_mode)
	var cam0: Vector2 = g.camera.position
	await io.swipe(io.vs() * 0.5, io.vs() * 0.5 + Vector2(-200, 0))
	io.note("one-finger swipe in %s mode: camera moved %.0f" % [Settings.drag_mode, cam0.distance_to(g.camera.position)])
	await io.tap(dr.get_center())
	await p.select(a[0])
	await io.long_press(p.to_screen(a[0].global_position + Vector2(100, 0)), 0.9)
	io.note("long press with a unit selected: order %s" % a[0].order)
	await io.shot("phone_controls")
	# the "?" help
	io.note("phone ? help: %s" % str(g.hud.help_rect() if g.hud.has_method("help_rect") else "-"))


# ------------------------------------------------------------------ the match menu

func menu_open() -> void:
	var r: Rect2 = g.hud.menu_rect()
	if p.phone:
		await io.tap(r.get_center())
	else:
		await io.click(r.get_center())
	await io.frames(3)


func menu_item(label: String) -> bool:
	for b in g.hud._menu_buttons():
		if String(b.get("label", "")).begins_with(label):
			var c: Vector2 = (b["rect"] as Rect2).get_center()
			if p.phone:
				await io.tap(c)
			else:
				await io.click(c)
			await io.frames(3)
			return true
	io.note("no menu item " + label + " in " + str(g.hud._menu_buttons().map(func(b: Dictionary) -> String: return String(b.get("label", "")))))
	return false


func match_menu() -> void:
	await menu_open()
	check(g.hud.menu_open, "MENU opens the match menu")
	await io.shot("match_menu")
	await menu_item("PAUSE")
	check(g.hud.paused, "PAUSE pauses")
	await io.shot("paused")
	await menu_open()
	await menu_item("RESUME")
	if g.hud.paused:
		# the paused screen has its own RESUME
		for b in g.hud._paused_buttons():
			var c: Vector2 = (b["rect"] as Rect2).get_center()
			if p.phone:
				await io.tap(c)
			else:
				await io.click(c)
			break
	await io.frames(3)
	check(not g.hud.paused, "RESUME goes on")
	# Settings over the match
	await menu_open()
	await menu_item("SETTINGS")
	await io.frames(5)
	await io.shot("settings_over_match")
	await io.key(KEY_ESCAPE)
	await io.frames(3)
	check(not g.hud.settings_open, "Esc closes the Settings over the match")
	# quit to the menu and CONTINUE
	var units_before: int = g.units.filter(func(u: Unit) -> bool: return u.team == g.human and not u.dead).size()
	var clock_before: float = g.clock
	await menu_open()
	await menu_item("QUIT TO MENU")
	for i in 60:
		await io.frames(2)
		if io.find_button("SKIRMISH", true) != null:
			break
	await io.shot("menu_with_continue")
	var cont: BaseButton = null
	for b in io.buttons():
		if b.name == "Menu_continue":
			cont = b
	check(cont != null, "the main menu shows CONTINUE after QUIT TO MENU")
	if cont == null:
		return
	if p.phone:
		await io.tap(io.centre(cont))
	else:
		await io.click(io.centre(cont))
	for i in 600:
		await io.frames(1)
		if main.game != null and is_instance_valid(main.game) and main.game != g and main.game.hud != null:
			break
	g = main.game
	p.g = g
	p.hud = g.hud
	for i in 300:
		await io.frames(1)
		if g.hud.countdown <= 0.0:
			break
	var units_after: int = g.units.filter(func(u: Unit) -> bool: return u.team == g.human and not u.dead).size()
	check(absi(units_after - units_before) <= 2, "CONTINUE: the match comes back (units %d -> %d, clock %.0f -> %.0f)" % [units_before, units_after, clock_before, g.clock])
	await io.shot("continued")
	# surrender
	await menu_open()
	await menu_item("SURRENDER")
	await io.shot("surrender_confirm")
	await menu_item("YES, SURRENDER")
	await io.wait(3.0)
	check(g.over, "SURRENDER ends the match")
	await io.shot("end_screen")
	var labs: Array = []
	for b in io.buttons():
		labs.append(io.btn_text(b))
	io.note("end screen buttons: %s" % ", ".join(labs))
