extends SceneTree
## player-comforts (docs/player_comforts.md): SAVING INSIDE A CAMPAIGN MISSION and its CHECKPOINTS, QUIT to the hub,
## the PAUSE keys, the questions, the phone's compact layout's rules.
##   - every Act 1 mission (p01, a01-a07, b01, c01) and Act 2's d02, d03, d06 and d08 played a little, its next part begun, SAVED and LOADED: the mission's
##     state comes back the same (flags, counters, objectives, triggers fired, clocks, tags, the denied pieces, the
##     light, weather and mist, the cages, carts, fires, sleepers, routes, disguises, the units and buildings, their
##     health and what the mission put on them), and it plays on with no script error;
##   - a CHECKPOINT is kept when a part begins; a defeat clears "where you left it", keeps the checkpoint and its end
##     panel offers RETRY FROM CHECKPOINT and RESTART MISSION; RETRY goes back to the checkpoint's time;
##   - the match menu: SAVE and LOAD in a mission (not in a skirmish, not in a lesson), QUIT TO CAMPAIGN asks first and
##     goes to the mission's hub, where its card offers CONTINUE; a victory clears the mission's saves;
##   - Pause/Break and F10 pause and resume; the main menu's EXIT asks first (Esc no, Enter yes);
##   - Settings.compact_phone / hud_scale_for: only a phone held sideways is compact.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_save.gd [-- only=<mission>]
## The full runs to the end (with and without a save in the middle, the flags compared): tools/test_campaign_save.sh.
## Prints CHECK lines, then "campaign_save: N failures"; exit code 1 on a failure. (Puts user://campaign.json back.)
var main: Node
var fails := 0
var _kept := ""
var _errs: Array = []
var only := ""
const MISSIONS := ["p01_leaf", "a01_presses", "a02_furth", "a03_plateau", "a04_visit", "a05_specimens", "a06_barricades",
	"a07_council", "b01_specimen", "c01_thirteenth", "d02_exodus", "d03_fazenda", "d06_queen", "d08_rivers"]


class Catch extends Logger:
	var out: Array
	func _init(o: Array) -> void:
		out = o
	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _en: bool, error_type: int, _bt: Array[ScriptBacktrace]) -> void:
		if error_type == 2:          # SCRIPT ERROR
			out.append("%s @ %s:%d %s" % [rationale if rationale != "" else code, file, line, function])
	func _log_message(_m: String, _e: bool) -> void:
		pass


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-70s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("only="):
			only = a.substr(5)
	OS.add_logger(Catch.new(_errs))
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	if FileAccess.file_exists(Campaign.PROGRESS):
		_kept = FileAccess.get_file_as_string(Campaign.PROGRESS)
	# every mission open (the flags missing: each mission's defaults)
	var p := {"reached": MISSIONS.duplicate(), "done": {"p01_leaf": {"won_by": "crown"}, "a04_visit": {"won_by": "visit"},
		"a05_specimens": {"won_by": "expedition"}, "a06_barricades": {"won_by": "crown"}, "a07_council": {"won_by": "crown"}}, "difficulty": "normal"}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _finish() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	if _kept != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept)
		f.close()
	for mid in MISSIONS:
		MissionSave.clear_all(mid)
	print("campaign_save: %d failures" % fails)
	quit(1 if fails > 0 else 0)


func _wait(sec: float) -> void:
	var g: Game = main.game
	var until := g.clock + sec
	var guard := 0
	while is_instance_valid(g) and g.clock < until and not g.over and guard < int(sec * 60) + 600:
		await physics_frame
		guard += 1


func _start(mid: String) -> Game:
	main.start(Campaign.make_cfg(mid, "solo"))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	return g


## What a save must bring back.
func snap(g: Game) -> Dictionary:
	var r := g.mission
	var tg := {}
	for t in r.tags:
		tg[t] = r.tagged(String(t)).size()
	var sl := {}
	for nm in r.sleeping:
		sl[nm] = (r.sleeping[nm]["units"] as Array).filter(func(u) -> bool: return u != null and is_instance_valid(u) and not u.dead).size()
	var by_team := {}
	for u in g.units:
		if u.dead or u.off_field or u.kind == "gun_crewman":
			continue
		var k := "u%d" % u.team
		by_team[k] = int(by_team.get(k, 0)) + 1
		by_team[k + "hp"] = int(by_team.get(k + "hp", 0)) + int(u.hp)
	for b in g.buildings:
		if b.dead:
			continue
		var k := "b%d" % b.team
		by_team[k] = int(by_team.get(k, 0)) + 1
		by_team[k + "hp"] = int(by_team.get(k + "hp", 0)) + int(b.hp)
	var metas := {}
	for e in g.units + g.buildings:
		if e.dead:
			continue
		for mk in MissionRun.SAVE_METAS + ["torch", "cage_cart", "on_cart", "cage_cargo"]:
			if e.has_meta(mk):
				metas[mk] = int(metas.get(mk, 0)) + 1
		if e.spared:
			metas["spared"] = int(metas.get("spared", 0)) + 1
		if e.hp_floor > 0.0:
			metas["floor"] = int(metas.get("floor", 0)) + 1
		if e is Unit and (e.m_pace != 1.0 or e.m_unarmed):
			metas["held"] = int(metas.get("held", 0)) + 1
	var cl := {}
	for c in r.clocks:
		cl[c] = int(round(float(r.clocks[c])))
	var fired: Array = r.fired.keys()
	fired.sort()
	return {"flags": r.flags, "counters": r.counters, "obj": r.obj, "fired": fired, "tags": tg, "clocks": cl,
		"deny": r.deny, "light": r.light_name, "weather": r.weather_name, "mist": r.mist_sight, "sleeping": sl,
		"woke": r.woke.keys(), "lists": [r._disguised.size(), r._caged.size(), r._burning.size(), r._carts.size(),
		r._routes.size(), r._follows.size(), r._turning.size()], "teams": by_team, "metas": metas,
		"choice": String(r.choice_open.get("id", "")), "said": r.said_ids.size(), "checkpoints": r.checkpoints.keys(),
		"out": r.out_sides.keys(), "captured": r.captured.keys(), "unmasked": r.unmasked.keys(),
		"ulist": g.units.filter(func(u) -> bool: return not u.dead and not u.off_field and u.kind != "gun_crewman").map(
			func(u) -> String: return "%s t%d hp %d/%d %s" % [u.kind, u.team, int(u.hp), int(u.max_hp), u.get_meta("rebel_role", "")])}


func _diff(a: Dictionary, b: Dictionary) -> String:
	var out: Array = []
	for k in a:
		if k == "ulist":
			continue
		if str(a[k]) != str(b.get(k)) and a[k] != b.get(k):
			out.append("%s: %s -> %s" % [k, a[k], b.get(k)])
	return "; ".join(out)


func _run() -> void:
	await process_frame
	_compact_rules()
	await _menu_rules()
	for mid in MISSIONS:
		if only != "" and mid != only:
			continue
		await _round_trip(mid)
	if only == "" or only == "a02_furth":
		await _defeat_and_retry("a02_furth")
		await _quit_to_hub("c01_thirteenth")
	_finish()


func _compact_rules() -> void:
	var dev := Settings.device
	Settings.device = "pc"
	check("compact: never on a computer", not Settings.compact_phone(Vector2(844, 390)))
	Settings.device = "phone"
	check("compact: a phone held sideways (844 x 390, 780 x 360, 915 x 412)", Settings.compact_phone(Vector2(844, 390))
		and Settings.compact_phone(Vector2(780, 360)) and Settings.compact_phone(Vector2(915, 412)))
	check("compact: not a tablet (1280 x 800) or a phone upright", not Settings.compact_phone(Vector2(1280, 800)) and not Settings.compact_phone(Vector2(390, 844)))
	var us := Settings.ui_size
	Settings.ui_size = 0
	check("compact: the HUD at 1.3 there, 1.5 on a tablet", is_equal_approx(Settings.hud_scale_for(Vector2(844, 390)), 1.3)
		and is_equal_approx(Settings.hud_scale_for(Vector2(1280, 800)), 1.5))
	Settings.ui_size = 170
	check("compact: an INTERFACE SIZE chosen wins", is_equal_approx(Settings.hud_scale_for(Vector2(844, 390)), 1.7))
	Settings.ui_size = us
	Settings.device = dev


func _labels(g: Game) -> Array:
	return g.hud._menu_list().map(func(b: Dictionary) -> String: return String(b["label"]))


func _menu_rules() -> void:
	# a skirmish: no SAVE / LOAD, QUIT TO MENU asks
	main.start({"map": "greenhold", "slots": [{"who": "you", "faction": "crown", "colour": 0, "side": 0},
		{"who": "easy", "faction": "brood", "colour": 1, "side": 1}]})
	await process_frame
	await process_frame
	var g: Game = main.game
	g.hud.countdown = 0.0
	var ls := _labels(g)
	check("skirmish menu: no SAVE / LOAD, QUIT TO MENU", not ls.has("SAVE") and not ls.has("LOAD SAVE") and ls.has("QUIT TO MENU"), str(ls))
	g.hud.toggle_menu(true)
	for b in g.hud._menu_list():
		if b["label"] == "QUIT TO MENU":
			b["cb"].call()
	check("skirmish QUIT TO MENU asks first", g.hud.get("_confirm") == "quit" and main.game == g, String(g.hud._confirm_text()))
	_key(KEY_ESCAPE)
	await process_frame
	check("Esc says no", g.hud.get("_confirm") == "" and main.game == g)
	g.hud.toggle_menu(false)
	# the PAUSE keys
	_key(KEY_PAUSE)
	await process_frame
	check("Pause/Break pauses", g.hud.paused and paused)
	_key(KEY_F10)
	await process_frame
	check("F10 resumes", not g.hud.paused and not paused)
	_key(KEY_F10)
	await process_frame
	check("F10 pauses", g.hud.paused)
	_key(KEY_PAUSE)
	await process_frame
	check("Pause/Break resumes", not g.hud.paused)
	check("F10 is no camera view key now", not HotkeyBar.FKEYS.has(KEY_F10))
	# Enter answers YES: the match is left
	g.hud.toggle_menu(true)
	for b in g.hud._menu_list():
		if b["label"] == "QUIT TO MENU":
			b["cb"].call()
	_key(KEY_ENTER)
	for i in 4:
		await process_frame
	check("Enter says yes: left the match", main.game == null)
	# the main menu's EXIT asks (not the web)
	main.show_menu()
	await process_frame
	main.ask("Quit the game?", "YES, QUIT", func() -> void: check("EXIT question: Esc must not quit", false))
	await process_frame
	check("EXIT question shows", main.ask_open())
	_key(KEY_ESCAPE)
	await process_frame
	await process_frame
	check("EXIT question: Esc closes it", not main.ask_open())
	var said := [false]
	main.ask("Quit the game?", "YES, QUIT", func() -> void: said[0] = true)
	await process_frame
	_key(KEY_ENTER)
	await process_frame
	check("EXIT question: Enter says yes", said[0])
	# a lesson: no saving
	main.start(Campaign.make_cfg("t01_basics", "solo"))
	await process_frame
	await process_frame
	g = main.game
	if g and g.mission:
		check("a lesson: no SAVE / LOAD", not _labels(g).has("SAVE") and not g.mission.saveable(), str(_labels(g)))
	main._to_menu()
	await process_frame


func _key(k: Key) -> void:
	for down in [true, false]:
		var e := InputEventKey.new()
		e.keycode = k
		e.physical_keycode = k
		e.pressed = down
		Input.parse_input_event(e)
	Input.flush_buffered_events()


## The first trigger that begins a new part (part2..., not party), if the mission has one.
func _part_trigger(r: MissionRun) -> Dictionary:
	for tr in r.data.get("triggers", []):
		var tid := String(tr.get("id", ""))
		if MissionRun.is_part_trigger(tid) and not r.fired.has(tid) and r._in_mode(tr):
			return tr
	return {}


func _round_trip(mid: String) -> void:
	_errs.clear()
	MissionSave.clear_all(mid)
	var g: Game = await _start(mid)
	var r := g.mission
	check("%s: SAVE and LOAD in the menu" % mid, _labels(g).has("SAVE") and _labels(g).has("LOAD SAVE") and _labels(g).has("QUIT TO CAMPAIGN") and r.saveable(), str(_labels(g)))
	await _wait(20.0)
	# (a05's Part 2 wakes the nest on an idle party: lost; d02's Part 2 with no cart loaded: lost; d03's Part 2 with the
	# stock still in the old pens: all found, lost)
	var tr := _part_trigger(r) if not mid in ["a05_specimens", "d02_exodus", "d03_fazenda"] else {}
	if not tr.is_empty() and not g.over:
		r.fire(tr)                 # (its next part begun at once: more of the mission's machinery on show)
		await _wait(12.0)
		check("%s: a CHECKPOINT kept when %s began" % [mid, tr["id"]], MissionSave.has(mid, "checkpoint") and not r.checkpoints.is_empty(),
			str(r.checkpoints))
	if g.over:
		check("%s: still going at %d s (for the save)" % [mid, int(g.clock)], false, "won by %s" % r.winner_side)
		for l in g.mlog.lines:
			if l.contains("(mission)"):
				print("   ", l.substr(0, 150))
		main._to_menu()
		return
	var before := snap(g)
	main.mission_save_now()
	check("%s: SAVE written" % mid, MissionSave.has(mid, "save") and MissionSave.has(mid, "auto"))
	check("%s: the skirmish's autosave untouched" % mid, SaveGame.peek().get("mission_id", "") == "")
	main.mission_load("save")
	await process_frame
	await process_frame
	paused = false
	var g2: Game = main.game
	if g2 == null or g2.mission == null:
		check("%s: loaded" % mid, false)
		return
	g2.hud.countdown = 0.0
	var after := snap(g2)
	var d := _diff(before, after)
	if d.contains("teams"):
		var ua: Array = before["ulist"]
		var ub: Array = after["ulist"]
		var shown := 0
		for i in mini(ua.size(), ub.size()):
			if str(ua[i]) != str(ub[i]) and shown < 6:
				shown += 1
				print("   unit %d: %s -> %s" % [i, ua[i], ub[i]])
	check("%s: LOADED the same (%d s, %d units)" % [mid, int(g2.clock), g2.units.size()], d == "" and absf(g2.clock - g.clock) < 0.5 if is_instance_valid(g) else d == "", d)
	await _wait(25.0)
	check("%s: plays on 25 s after the load, no script error" % mid, _errs.is_empty(), str(_errs.slice(0, 3)))
	# a second save and load of the loaded game (a save of a save)
	var b2 := snap(g2)
	main.mission_save_now()
	main.mission_load("save")
	await process_frame
	await process_frame
	paused = false
	var g3: Game = main.game
	g3.hud.countdown = 0.0
	var d2 := _diff(b2, snap(g3))
	check("%s: a save of a loaded game comes back the same too" % mid, d2 == "", d2)
	main._to_menu()
	await process_frame
	check("%s: leaving keeps where you left it (CONTINUE)" % mid, MissionSave.has(mid, "auto"))


func _defeat_and_retry(mid: String) -> void:
	MissionSave.clear_all(mid)
	var g: Game = await _start(mid)
	var r := g.mission
	await _wait(20.0)
	var tr := _part_trigger(r)
	if not tr.is_empty():
		r.fire(tr)
	await _wait(5.0)
	var cp := MissionSave.peek(mid, "checkpoint")
	check("retry: a checkpoint kept", not cp.is_empty())
	await _wait(10.0)
	r.side_lost(r.my_side())          # (lost: the end screen)
	for i in 120:
		await process_frame
		if main.ui_layer.get_node_or_null("MissionEnd") != null:
			break
	await create_timer(1.5).timeout
	var end: Node = main.ui_layer.get_node_or_null("MissionEnd")
	check("retry: the defeat's end panel", end != null)
	check("retry: where you left it is cleared, the checkpoint kept", not MissionSave.has(mid, "auto") and MissionSave.has(mid, "checkpoint"))
	var retry: Button = end.find_child("End_RETRY_FROM_CHECKPOINT", true, false) if end else null
	check("retry: RETRY FROM CHECKPOINT and RESTART MISSION offered", retry != null and end.find_child("End_RESTART_MISSION", true, false) != null)
	if retry:
		retry.pressed.emit()
		await process_frame
		await process_frame
		var g2: Game = main.game
		check("retry: back at the checkpoint's time", g2 != null and g2.mission != null and absf(g2.clock - float(cp.get("clock", -1))) < 0.5 and not g2.over,
			"%.1f / %.1f" % [g2.clock if g2 else -1.0, float(cp.get("clock", -1))])
		# a victory clears the mission's saves
		if g2 and g2.mission:
			g2.hud.countdown = 0.0
			g2.mission.finish(g2.mission.my_side())
			for i in 30:
				await process_frame
			check("a victory clears CONTINUE and the checkpoint", not MissionSave.has(mid, "auto") and not MissionSave.has(mid, "checkpoint"))
	main._to_menu()
	await process_frame


func _quit_to_hub(mid: String) -> void:
	MissionSave.clear_all(mid)
	var g: Game = await _start(mid)
	await _wait(10.0)
	CampaignMenu.line = "crown"
	g.hud.toggle_menu(true)
	for b in g.hud._menu_list():
		if b["label"] == "QUIT TO CAMPAIGN":
			b["cb"].call()
	check("QUIT TO CAMPAIGN asks first", g.hud.get("_confirm") == "quit", g.hud._confirm_text())
	g.hud._confirm_yes()
	for i in 6:
		await process_frame
	check("QUIT TO CAMPAIGN: the match is left", main.game == null)
	check("QUIT TO CAMPAIGN: the mission's own hub (%s)" % CampaignMenu.line, Campaign.storyline_of(mid).get("id", "") == CampaignMenu.line)
	check("QUIT TO CAMPAIGN: on the hub", main.ui_layer.find_child("Hotspot_*", true, false) != null or main.ui_layer.find_child("Line_*", true, false) != null)
	check("QUIT TO CAMPAIGN: the mission kept (CONTINUE)", MissionSave.has(mid, "auto"))
	# the war table's card: CONTINUE
	CampaignMenu.pick = mid
	CampaignMenu.mode = "solo"
	CampaignMenu.war_table(main)
	await process_frame
	var cont: Button = main.ui_layer.find_child("Campaign_Auto", true, false)
	check("the mission's card: CONTINUE", cont != null)
	if cont:
		cont.pressed.emit()
		await process_frame
		await process_frame
		check("CONTINUE: back in the mission where it was left", main.game != null and main.game.mission != null and main.game.clock >= 9.0,
			"clock %.1f" % (main.game.clock if main.game else -1.0))
	main._to_menu()
	await process_frame
