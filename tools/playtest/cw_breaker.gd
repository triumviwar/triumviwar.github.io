extends SceneTree
## A player who tries to break things, as the Clockwork (job playtest-skirmish-clockwork), in a SANDBOX match with the
## other side's computer off: placing on cliffs, water, off the map and on top of buildings; Shift-queued sites then
## Esc; a Winder sent away while he carries a crate (the crate is dropped: does another pick it up?); a site cancelled;
## five units queued then cancelled (all paid back?); DEMOLISH pressed once and twice; a card hotkey storm with nothing
## selected; a box drag started on the HUD and out past the window; the window resized mid-match; QUIT TO MENU while
## placing and CONTINUE.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 --script res://tools/playtest/cw_breaker.gd -- out=DIR

const IN := preload("res://tools/playtest/cw_input.gd")
const SETUP := preload("res://tools/playtest/cw_setup.gd")
const PLAYER := preload("res://tools/playtest/cw_player.gd")

var io
var main: Node
var g: Game
var p
var fails := 0
var last_msg := ""


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func arg(k: String, d: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(k + "="):
			return a.substr(k.length() + 1)
	return d


func _process(_d: float) -> bool:
	if g != null and is_instance_valid(g) and g.hud != null:
		var m: String = g.hud._msg
		if m != last_msg and m != "" and g.hud._msg_t > 0.0:
			last_msg = m
			print("PT  TOAST %s" % m)
	return false


func ui(t: String) -> void:
	await io.press(t, false, true)


func _run() -> void:
	io = IN.new(self)
	io.shots_dir = arg("out", "/tmp/claude-0/pt/breaker")
	DirAccess.make_dir_recursive_absolute(io.shots_dir)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await io.frames(8)
	var su = SETUP.new(io, main, false)
	await su.to_menu()
	Settings.set_device("pc")
	main.show_menu()
	await io.frames(2)
	await su.press("EDITOR", true)
	await su.press("SANDBOX", true)
	await su.press("1V1", true)
	await su.pick(su.slot_row(0)[1], "CLOCKWORK")
	await su.pick(su.slot_row(1)[1], "CROWN")
	var dd: Array = su.dropdowns()
	await su.pick(dd[dd.size() - 1], "REDROCK CANYON")
	g = await su.start()
	p = PLAYER.new(io, g, "careful")
	Engine.time_scale = 2.0
	await ui("SANDBOX >")
	await ui("2")
	await ui("AI: ON")
	await ui("» 1")
	for i in 3:
		await ui("+1000 COGS")
	await ui("SANDBOX <")
	var hall: Building = p.mine("clocktower")[0]
	# ---- placing where it can't go
	await p.select_a_winder()
	await p.press("BUILD")
	await p.press("REGULATOR")
	var bad := {}
	for c in [Vector2i(-3, -3), Vector2i(Game.W + 2, 5), hall.cell + Vector2i(1, 1)]:
		var wp: Vector2 = p.mouse_for_cell("regulator", c)
		var sp: Vector2 = await p.look_at(wp)
		io.move_to(sp)
		await io.frames(2)
		await io.click(sp)
		await io.frames(3)
		bad[str(c)] = [g.hud.controls.mode, last_msg]
	io.note("clicks on bad spots (off the map left/top, off the map right, on the Clocktower): %s" % bad)
	check(g.hud.controls.mode == "place", "a click on a bad spot keeps the ghost (no site)")
	# a cliff or water cell near the base
	var cliff := Vector2i(-1, -1)
	for r in range(4, 30):
		for dx in range(-r, r + 1):
			var c2: Vector2i = hall.cell + Vector2i(dx, r)
			var pr: String = g.placement_problem(g.human, "regulator", c2)
			if pr.to_lower().contains("level") or pr.to_lower().contains("water") or pr.to_lower().contains("cliff") or pr.to_lower().contains("ground"):
				cliff = c2
				io.note("a refused spot at %s: '%s'" % [c2, pr])
				break
		if cliff.x >= 0:
			break
	if cliff.x >= 0:
		var sp2: Vector2 = await p.look_at(p.mouse_for_cell("regulator", cliff))
		io.move_to(sp2)
		await io.frames(2)
		await io.shot("ghost_on_bad_ground")
	await io.key(KEY_ESCAPE)
	# ---- Shift-queued sites, then Esc
	await p.select_a_winder()
	var w0: Array = g.selected_units()
	await p.press("BUILD")
	await p.press("REGULATOR")
	var n0 := g.buildings.size()
	await p.look_at(hall.center())
	io.key_down(KEY_SHIFT, true)          # (held down through the three clicks, as a hand does)
	for i in 3:
		var c3: Vector2i = p.find_spot("regulator", hall.center(), 6 + 3 * i)
		var sp3: Vector2 = p.to_screen(p.mouse_for_cell("regulator", c3))
		io.move_to(sp3, true)
		await io.frames(2)
		io.button(sp3, MOUSE_BUTTON_LEFT, true, true)
		await io.frames(1)
		io.button(sp3, MOUSE_BUTTON_LEFT, false, true)
		await io.frames(2)
	io.note("mode while Shift is still held: '%s'" % g.hud.controls.mode)
	io.key_up(KEY_SHIFT)
	await io.frames(2)
	await io.frames(3)
	io.note("Shift-placed 3 Regulators then Esc: %d new sites, mode '%s', Winder queue %d" % [g.buildings.size() - n0, g.hud.controls.mode, (w0[0].queue.size() if not w0.is_empty() and "queue" in w0[0] else -1)])
	await io.shot("shift_sites")
	# ---- a Winder carrying a crate sent away
	var carrier: Unit = null
	for i in 200:
		await io.frames(2)
		for b in g.buildings:
			if b.team == g.human and not b.dead and b.crate_carrier != null and is_instance_valid(b.crate_carrier):
				carrier = b.crate_carrier
		if carrier:
			break
	if carrier:
		io.note("carrier found: work '%s'" % carrier.work)
		await p.select(carrier)
		var away: Vector2 = carrier.global_position + Vector2(-200, 120)
		await io.rclick(p.to_screen(away))
		await io.wait(2.0)
		var crates: Array = g.crates.filter(func(c) -> bool: return is_instance_valid(c) and not c.is_queued_for_deletion())
		io.note("after sending the carrier away: %d crate(s) on the ground" % crates.size())
		await io.shot("dropped_crate")
		await io.wait(6.0)
		crates = g.crates.filter(func(c) -> bool: return is_instance_valid(c) and not c.is_queued_for_deletion())
		io.note("6 s later: %d crate(s) still on the ground" % crates.size())
	else:
		io.note("no Winder seen carrying a crate (work states: %s)" % str(p.mine("winder").map(func(u) -> String: return u.work)))
	# ---- a site cancelled
	var site: Building = null
	for b in g.buildings:
		if b.team == g.human and not b.built and not b.dead:
			site = b
	if site:
		var c0: int = p.cogs()
		await p.select(site)
		var cards: Array = p.card_labels()
		io.note("a site's card: %s" % ", ".join(cards))
		var why: String = await p.press("CANCEL")
		await io.frames(3)
		io.note("CANCEL a %s site: cogs %d -> %d (%s), site dead %s" % [site.kind, c0, p.cogs(), why, site.dead])
	# ---- 5 Winders queued, all cancelled
	await p.select(hall)
	var c1: int = p.cogs()
	for i in 5:
		await p.press("WINDER")
	var c2: int = p.cogs()
	io.note("5 Winders queued: queue %d, cogs %d -> %d" % [hall.queue.size(), c1, c2])
	for i in 6:
		await p.press("CANCEL")
	await io.frames(3)
	check(hall.queue.is_empty() and p.cogs() >= c2 + 300, "5 queued Winders cancelled: every cog back (%d -> %d -> %d)" % [c1, c2, p.cogs()])
	# ---- DEMOLISH once, then twice
	var reg: Array = p.mine("regulator")
	if not reg.is_empty():
		await p.select(reg[0])
		await p.press("DEMOLISH")
		check(not reg[0].dead, "DEMOLISH once only warns")
		await p.press("DEMOLISH")
		await io.frames(4)
		check(reg[0].dead, "DEMOLISH twice pulls it down")
	# ---- a hotkey storm with nothing selected
	await io.key(KEY_ESCAPE)
	for k in [KEY_B, KEY_A, KEY_S, KEY_H, KEY_P, KEY_G, KEY_E, KEY_W, KEY_Q, KEY_Z, KEY_X, KEY_TAB, KEY_SPACE, KEY_F1, KEY_F2, KEY_F3, KEY_QUOTELEFT, KEY_QUOTELEFT]:
		await io.key(k)
	io.note("hotkey storm with nothing selected: mode '%s', selection %d" % [g.hud.controls.mode, g.selection.size()])
	await io.key(KEY_ESCAPE)
	await io.key(KEY_ESCAPE)
	# ---- box drags from the HUD and past the window
	await io.drag(Vector2(600, 650), Vector2(400, 200))
	io.note("drag started on the HUD: selection %d" % g.selection.size())
	await io.drag(Vector2(500, 300), Vector2(1400, -50))
	io.note("drag ending past the window: selection %d, box %s" % [g.selection.size(), str(g.hud.controls._box_from)])
	# ---- the window resized
	for sz in [Vector2i(800, 600), Vector2i(1600, 900), Vector2i(1280, 720)]:
		DisplayServer.window_set_size(sz)
		await io.frames(8)
		await p.select(hall)
		await io.shot("resized_%dx%d" % [sz.x, sz.y])
	# ---- QUIT TO MENU while placing, then CONTINUE
	await p.select_a_winder()
	await p.press("BUILD")
	await p.press("REGULATOR")
	await io.click(p.hs(g.hud.menu_rect()).get_center())
	await io.frames(3)
	for b in g.hud._menu_buttons():
		if String(b.get("label", "")) == "QUIT TO MENU":
			await io.click(p.hs(b["rect"]).get_center())
	for i in 60:
		await io.frames(2)
		if io.find_button("SKIRMISH", true) != null:
			break
	var cont: BaseButton = null
	for b in io.buttons():
		if b.name == "Menu_continue":
			cont = b
	check(cont != null, "CONTINUE offered after quitting while placing")
	if cont:
		await io.click(io.centre(cont))
		for i in 300:
			await io.frames(1)
			if main.game != null and main.game != g and main.game.hud != null and main.game.hud.countdown <= 0.0:
				break
		io.note("continued: mode '%s', sandbox panel %s" % [main.game.hud.controls.mode, str(io.find_button("SANDBOX >", true) != null)])
		await io.shot("continued_after_placing")
	print("PT  BREAKER DONE %d FAIL" % fails)
	Engine.time_scale = 1.0
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	quit(0)
