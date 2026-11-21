extends SceneTree
## The skirmish page, every option, by input (job playtest-skirmish-clockwork): every quick set-up, + ADD PLAYER and the
## x, each slot's who / faction / colour / plan / team lists (the Clockwork's plan list read out), the map arrows and list,
## Esc with a list open, a right-click, a resized window, and a "confused" player clicking at random and pressing Esc.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 --script res://tools/playtest/cw_lobby.gd -- out=DIR

const IN := preload("res://tools/playtest/cw_input.gd")
const SETUP := preload("res://tools/playtest/cw_setup.gd")

var io
var main: Node
var fails := 0


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


func on_lobby() -> bool:
	return io.find_button("+  ADD PLAYER", true) != null or io.find_button("START", true) != null


func list_open() -> bool:
	return is_instance_valid(main._list_shade) and main._list_shade.is_inside_tree() and not main._list_shade.is_queued_for_deletion()


func _run() -> void:
	io = IN.new(self)
	io.shots_dir = arg("out", "/tmp/claude-0/pt/lobby")
	DirAccess.make_dir_recursive_absolute(io.shots_dir)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await io.frames(8)
	var su = SETUP.new(io, main, false)
	await su.to_menu()
	await su.press("SKIRMISH", true)
	# Esc with a list open closes the list, not the page
	var r0: Array = su.slot_row(0)
	await io.click(io.centre(r0[1]))
	await io.frames(3)
	check(list_open(), "a faction list opens")
	await io.key(KEY_ESCAPE)
	await io.frames(3)
	check(not list_open() and on_lobby(), "Esc closes the list and stays on the skirmish page")
	# every quick set-up
	for pr in ["2V2", "3V3", "4V4", "1V2", "1V3", "FFA", "1V1"]:
		await su.press(pr, true)
		await io.frames(3)
		await io.shot("preset_" + pr)
		io.note("%s: %d slots, map %s, START %s" % [pr, main.lobby["slots"].size(), main.lobby["map"], "on" if not io.find_button("START", true).disabled else "off (%s)" % main._lobby_problem()])
	# the Clockwork computer's plans
	await su.press("1V1", true)
	var r1: Array = su.slot_row(1)
	await su.pick(r1[1], "CLOCKWORK")
	r1 = su.slot_row(1)
	await io.click(io.centre(r1[3]))
	await io.frames(3)
	var plans: Array = []
	for b in io.buttons():
		if b is Button and (b as Button).text.begins_with("  ") or (b is Button and (b as Button).text.begins_with("√")):
			plans.append(io.btn_text(b))
	io.note("Clockwork plans: %s" % ", ".join(plans))
	await io.shot("cw_plans")
	await io.key(KEY_ESCAPE)
	# colours: pick the same colour for both (the taken one is greyed?)
	r0 = su.slot_row(0)
	await su.pick(r0[2], "RED")
	r1 = su.slot_row(1)
	await io.click(io.centre(r1[2]))
	await io.frames(3)
	var red_row: BaseButton = null
	for b in io.buttons():
		if io.btn_text(b).to_upper() == "RED":
			red_row = b
	check(red_row != null and red_row.disabled, "a colour taken by another slot is greyed in the list")
	await io.key(KEY_ESCAPE)
	# both on team 1: START?
	r1 = su.slot_row(1)
	await su.pick(r1[4], "TEAM 1")
	await io.frames(3)
	io.note("both on team 1: START %s, problem '%s'" % ["off" if io.find_button("START", true).disabled else "ON", main._lobby_problem()])
	await io.shot("same_team")
	r1 = su.slot_row(1)
	await su.pick(r1[4], "TEAM 2")
	# random faction and random plan
	r0 = su.slot_row(0)
	await su.pick(r0[1], "RANDOM")
	await io.shot("random_me")
	r0 = su.slot_row(0)
	await su.pick(r0[1], "CLOCKWORK")
	# map arrows
	var m0: String = main.lobby["map"]
	await su.press(">", true)
	await su.press(">", true)
	await su.press("<", true)
	io.note("map arrows: %s -> %s" % [m0, main.lobby["map"]])
	# add players to 8, remove two
	for i in 7:
		if io.find_button("+  ADD PLAYER", true) == null:
			break
		await su.press("+  ADD PLAYER", true)
	io.note("after ADD PLAYER x7: %d slots" % main.lobby["slots"].size())
	await io.shot("eight_slots")
	for i in 2:
		await su.press("×", true)
	io.note("after x x2: %d slots" % main.lobby["slots"].size())
	await su.press("1V1", true)
	# a resized window (computer)
	DisplayServer.window_set_size(Vector2i(1024, 600))
	await io.frames(6)
	await io.shot("lobby_1024x600")
	DisplayServer.window_set_size(Vector2i(1280, 720))
	await io.frames(6)
	# a confused player: random clicks and Esc
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 40:
		var p := Vector2(rng.randf_range(0, io.vs().x), rng.randf_range(0, io.vs().y))
		if rng.randf() < 0.15:
			await io.key(KEY_ESCAPE)
		elif rng.randf() < 0.2:
			await io.rclick(p)
		else:
			await io.click(p)
		await io.frames(2)
		if main.game != null:
			io.note("confused clicks started a match at click %d" % i)
			break
	await io.shot("after_confused")
	io.note("confused player ended on: %s" % ("a match" if main.game != null else ("skirmish" if on_lobby() else "another page")))
	print("PT  LOBBY DONE %d FAIL" % fails)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	quit(0)
