extends SceneTree
## THE CLICK SWEEP (qa-click-sweep-2, the owner 2026-11-28: "make a test everything, analyse everything clickable
## routine"; report docs/qa_click_sweep.md). Presses every clickable thing it can reach and reports what breaks.
##
##   tools/qa/click_sweep.sh                 every part, en/pt/es, computer 1600x900 and a phone held sideways
##   tools/qa/click_sweep.sh --quick         every part, English, computer only (before a release)
##   tools/qa/click_sweep.sh --parts menus,settings --lang pt --size phone
## or by hand (one language, one size a run):
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1600x900 --script res://tools/qa/click_sweep.gd -- \
##       out=docs/shots/qa_click_sweep lang=en size=pc parts=menus,settings [depth=2] [budget=400] [shots=all|flags|none]
##
## PARTS (each runs alone): menus, settings, campaign, skirmish (the setup page), skirmish_crown, skirmish_clockwork,
## skirmish_brood (a real match each), editor, worldwar, tournaments, online, replays.
##
## The menu parts CRAWL: a part's root pages are shown, every visible enabled Button is clicked (a real mouse click at
## its middle, pushed through the viewport, so a control lying over it is found; an OptionButton opens and each of its
## items is picked), each press on a FRESH copy of its page (the path replayed from the root). A press that opens a page
## not seen before (its buttons' labels) is crawled in turn, to `depth` presses from the root. A press that starts a
## match is noted and the match left at once. EXIT / QUIT are never pressed.
## The match parts start a match on Greenhold with the computer switched off, rich, spawn EVERY unit and building of the
## faction (Defs), select each and press every enabled button of its command card (and of its sub pages), start and
## cancel each placement, press F1..F12 and the hotkeys, click the minimap, open the match menu and press its buttons,
## pause, save and load. 7.6 of docs/qa_ui_review.md (a stale card after a quick army -> Barracks select) is checked.
##
## FLAGS (one line each, "SWEEP <KIND> <part> | <screen> | <button> | <detail>"):
##   ERROR     a SCRIPT ERROR / push_error / engine error during the press (the message)
##   COVERED   the real click at the button's middle did not reach it (something lies over it, or it is off its scroll)
##   NOOP      the press changed nothing that can be seen (texts, states, page, match, popups): a dead button? (a
##             candidate: sounds and outside effects don't show)
##   NOBACK    a page with no BACK / CLOSE button and no Esc target (the top menu excepted)
##   OFF / CUT / OVERLAP / SQUEEZED / EN   as tools/qa_ui_audit.gd (text off screen, cut, overlapping, broken word by
##             word, English the pt/es tables lack)
##   SLOW      a press whose page took over SLOW_MS to come up (the wall clock under xvfb: slow software GL; relative)
##   STALE     (match) the card shown does not belong to the selection
## At the end "SWEEP-SUMMARY <tag> {...}" and a JSON of every row in <out>/sweep_<tag>.json (not kept in git).
## Pictures: one small JPG per new screen, <out>/<tag>_<part>_<n>_<screen>.jpg ("shots=flags": only screens that
## raised a flag; the wrapper keeps every screen only for en/pc).

const PARTS := ["menus", "settings", "campaign", "skirmish", "skirmish_crown", "skirmish_clockwork", "skirmish_brood",
	"editor", "worldwar", "tournaments", "online", "replays"]
const SLOW_MS := 2500
const NEVER := ["EXIT", "SAIR", "SALIR", "QUIT", "YES, QUIT", "SIM, SAIR", "SÍ, SALIR", "QUIT GAME"]
## Buttons that open the browser or a file manager (OS.shell_open): never pressed by a test (listed as LINK once).
const LINKS := ["WINDOWS", "ANDROID", "PLAY ON THE WEB", "JOIN THE DISCORD", "DOWNLOAD", "OPEN FOLDER"]
const BACK_RX := "(?i)\\b(back|voltar|volver|atr[aá]s|close|fechar|cerrar|cancel|cancelar|done|feito|hecho|menu|ok|leave|sair|salir|return|regressar|regresar)\\b|[✕×←‹]"

var main: Node
var out := "docs/shots/qa_click_sweep"
var lang := "en"
var size := "pc"
var tag := ""
var parts: Array = []
var depth := 2
var budget := 400
var shots := "all"
var errlog: ErrLog
var rows: Array = []
var counts := {}
var pressed_n := 0
var screens_n := 0
var shot_n := 0
var part := ""
var _part_presses := 0
var slowest: Array = []
var saved_cfg := ""


class ErrLog extends Logger:
	var errs: Array = []
	var mutex := Mutex.new()

	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _bt: Array[ScriptBacktrace]) -> void:
		if error_type == ERROR_TYPE_WARNING:
			return
		var msg := "%s:%d %s (%s)" % [file.get_file(), line, rationale if rationale != "" else code, function]
		# (noise of the test bed itself, not the game's)
		if msg.contains("ObjectDB instances leaked") or msg.contains("resources still in use"):
			return
		mutex.lock()
		errs.append(msg)
		mutex.unlock()

	func _log_message(message: String, error: bool) -> void:
		if error and message.contains("SCRIPT ERROR"):
			mutex.lock()
			errs.append(message.strip_edges())
			mutex.unlock()

	func take() -> Array:
		mutex.lock()
		var e := errs.duplicate()
		errs.clear()
		mutex.unlock()
		return e


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := String(a).split("=", true, 1)
		match kv[0]:
			"out": out = kv[1]
			"lang": lang = kv[1]
			"size": size = kv[1]
			"parts": parts = Array(kv[1].split(",", false))
			"depth": depth = int(kv[1])
			"budget": budget = int(kv[1])
			"shots": shots = kv[1]
	if parts.is_empty() or parts == ["all"]:
		parts = PARTS.duplicate()
	errlog = ErrLog.new()
	OS.add_logger(errlog)
	if FileAccess.file_exists(Settings.PATH):
		saved_cfg = FileAccess.get_file_as_string(Settings.PATH)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var vs := Vector2(DisplayServer.window_get_size())
	tag = "%s_%s" % [lang, size]
	DirAccess.make_dir_recursive_absolute(out)
	_reset_settings()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	print("SWEEP-START %s window %dx%d parts %s" % [tag, int(vs.x), int(vs.y), ",".join(parts)])
	_run.call_deferred()


## The settings this run plays with: the saved ones, the device and the language; put back before every root page so
## a toggle pressed earlier (a language flag, the device) does not leak into the next.
func _reset_settings() -> void:
	if saved_cfg != "":
		var f := FileAccess.open(Settings.PATH, FileAccess.WRITE)
		f.store_string(saved_cfg)
		f.close()
	Settings.load_all()
	Settings.device = "pc" if size == "pc" else "mobile"
	Settings.language = lang
	Loc.set_lang(lang)
	Settings.apply()
	if Engine.time_scale != 1.0:
		Engine.time_scale = 1.0
	paused = false


func _run() -> void:
	Loc.track = true
	await process_frame
	await process_frame
	errlog.take()        # (the start-up's own messages are not a press)
	for p in parts:
		part = p
		_part_presses = 0
		print("== PART ", p)
		var t0 := Time.get_ticks_msec()
		match p:
			"menus": await _part_menus()
			"settings": await _part_settings()
			"campaign": await _part_campaign()
			"skirmish": await _part_skirmish()
			"skirmish_crown": await _part_match("crown")
			"skirmish_clockwork": await _part_match("clockwork")
			"skirmish_brood": await _part_match("brood")
			"editor": await _part_editor()
			"worldwar": await _part_worldwar()
			"tournaments": await _part_tournaments()
			"online": await _part_online()
			"replays": await _part_replays()
			_:
				print("unknown part ", p)
		await _leave_match()
		print("== PART-DONE %s %d presses %.1f s" % [p, _part_presses, (Time.get_ticks_msec() - t0) / 1000.0])
	_finish()


func _finish() -> void:
	slowest.sort_custom(func(a: Array, b: Array) -> bool: return a[0] > b[0])
	for s in slowest.slice(0, 8):
		print("SWEEP-SLOWEST %d ms %s" % [s[0], s[1]])
	print("SWEEP-SUMMARY %s screens %d presses %d %s" % [tag, screens_n, pressed_n, JSON.stringify(counts)])
	var f := FileAccess.open("%s/sweep_%s.json" % [out, tag], FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"tag": tag, "screens": screens_n, "presses": pressed_n, "counts": counts, "rows": rows}, " "))
		f.close()
	if saved_cfg != "":
		var g := FileAccess.open(Settings.PATH, FileAccess.WRITE)
		g.store_string(saved_cfg)
		g.close()
	quit()


var _flagged := {}


func flag(kind: String, screen: String, button: String, detail: String) -> void:
	# (one line per problem: the same EN text, or the same message on the same button, only once)
	var key := kind + "|" + detail if kind == "EN" else kind + "|" + screen + "|" + button + "|" + detail
	if _flagged.has(key):
		return
	_flagged[key] = true
	counts[kind] = counts.get(kind, 0) + 1
	var row := {"kind": kind, "part": part, "screen": screen, "button": button, "detail": detail}
	rows.append(row)
	print("SWEEP %s %s | %s | %s | %s" % [kind, part, screen, button, detail.replace("\n", " ").left(300)])


func _errs(screen: String, button: String) -> bool:
	var e := errlog.take()
	var seen := {}
	for m in e:
		if seen.has(m):
			continue
		seen[m] = true
		flag("ERROR", screen, button, m)
	return not e.is_empty()


## ------------------------------------------------------------------------------------------------ the menu crawler

func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _leave_match() -> void:
	if main.game != null:
		paused = false
		if main.game.hud:
			main.game.hud.paused = false
		main._to_menu()
		await _frames(3)
	_close_windows()


func _close_windows() -> void:
	for w in root.get_children():
		if w is Window and w.visible and w != root:
			w.hide()


## Every visible, enabled button of the page, in tree order.
func _buttons() -> Array:
	var out_b: Array = []
	var stack: Array = [main]
	while not stack.is_empty():
		var n: Node = stack.pop_front()
		if n is BaseButton and (n as Control).is_visible_in_tree() and not (n as BaseButton).disabled:
			out_b.append(n)
		var kids := n.get_children()
		for i in range(kids.size() - 1, -1, -1):
			stack.push_front(kids[i])
	return out_b


func _label(b: BaseButton) -> String:
	var t := ""
	if b is Button:
		t = (b as Button).text
	if t.strip_edges() == "":
		t = b.tooltip_text if b.tooltip_text != "" else String(b.name)
	return t.replace("\n", " ").strip_edges().left(48)


## A page's identity: its buttons' labels (numbers and ON/OFF words dropped, so a toggle or a counter is the same page).
func _sig() -> String:
	var ls: PackedStringArray = []
	var rx := RegEx.create_from_string("[0-9%:.]+|\\b(ON|OFF|LIGADO|DESLIGADO|ACTIVADO|DESACTIVADO|SIM|NÃO|SÍ|NO|YES)\\b")
	for b in _buttons():
		ls.append(rx.sub(_label(b), "", true))
	var head := ""
	if main.game != null:
		head = "MATCH "
	return head + str(hash("|".join(ls)))


## What a press can visibly change: texts, states, the page, the match, popups.
func _state() -> int:
	var parts_s: PackedStringArray = []
	parts_s.append(str(main.menu.get_instance_id()) if is_instance_valid(main.menu) else "-")
	parts_s.append("g" if main.game != null else "")
	for w in root.get_children():
		if w is Window and w.visible and w != root:
			parts_s.append("W" + String(w.name))
	var stack: Array = [main]
	var n_ctl := 0
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		for ch in n.get_children():
			stack.append(ch)
		if not n is CanvasItem or not (n as CanvasItem).is_visible_in_tree():
			continue
		n_ctl += 1
		if n is Label:
			parts_s.append((n as Label).text)
		elif n is Button:
			parts_s.append((n as Button).text + ("*" if (n as Button).button_pressed else "") + ("d" if (n as Button).disabled else ""))
			if n is OptionButton:
				parts_s.append(str((n as OptionButton).selected))
		elif n is Range:
			parts_s.append(str((n as Range).value))
		elif n is LineEdit:
			parts_s.append((n as LineEdit).text)
		elif n is RichTextLabel:
			parts_s.append(str((n as RichTextLabel).text.hash()))
		elif n is TextureRect:
			parts_s.append(str((n as TextureRect).texture.get_instance_id() if (n as TextureRect).texture else 0))
		elif n is Control and (n as Control).has_method("_draw"):
			parts_s.append(str((n as Control).get("view")) + str((n as Control).get("selected")) + str((n as Control).get("zoom")))
	parts_s.append(str(n_ctl))
	return hash("|".join(parts_s))


func _skip(b: BaseButton) -> bool:
	var l := _label(b).to_upper()
	if l in NEVER or String(b.name) == "Menu_exit" or l.begins_with("QUIT") or l.contains("QUIT THE GAME"):
		return true
	# (a link out of the game: never open the browser from a test)
	if b is LinkButton:
		return true
	for x in LINKS:
		if l == x or l == Loc.t(x).to_upper():
			return true
	return false


## The ways to press one button: a plain click; an OptionButton's items each (at most 10).
func _targets(b: BaseButton) -> Array:
	if b is OptionButton:
		var ob := b as OptionButton
		var t: Array = []
		for k in mini(ob.item_count, 10):
			if not ob.is_item_disabled(k) and not ob.is_item_separator(k) and k != ob.selected:
				t.append(k)
		return t
	return [-1]


## A real click at the button's middle; true when it reached the button. A button inside a ScrollContainer is
## scrolled to first.
func _click(b: BaseButton) -> bool:
	var p := b.get_parent()
	while p != null and not (p is Window):
		if p is ScrollContainer:
			(p as ScrollContainer).ensure_control_visible(b)
			break
		p = p.get_parent()
	await process_frame
	if not is_instance_valid(b) or not b.is_visible_in_tree():
		return false
	var r := b.get_global_rect()
	var at := r.get_center()
	# (keep inside the button when it is mostly scrolled away)
	var vr := _vis_rect(b)
	if vr.size.x > 2 and vr.size.y > 2:
		at = vr.get_center()
	var hit := [false]
	var cb := func() -> void: hit[0] = true
	var sig := "toggled" if b.toggle_mode else "pressed"
	if b.toggle_mode:
		b.toggled.connect(func(_v: bool) -> void: hit[0] = true, CONNECT_ONE_SHOT)
	else:
		b.pressed.connect(cb, CONNECT_ONE_SHOT)
	if b is OptionButton:
		(b as OptionButton).get_popup().about_to_popup.connect(cb, CONNECT_ONE_SHOT)
	var mv := InputEventMouseMotion.new()
	mv.position = at
	mv.global_position = at
	root.push_input(mv, true)
	for down in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = down
		ev.position = at
		ev.global_position = at
		root.push_input(ev, true)
		if is_instance_valid(b) and not hit[0]:
			await process_frame
	if not is_instance_valid(b):
		return hit[0]
	if not hit[0]:
		if b.toggle_mode and b.toggled.is_connected(cb):
			pass
		for c in b.get_signal_connection_list(sig):
			if c["callable"] == cb:
				b.disconnect(sig, cb)
	return hit[0]


## Press target `t` of button `b`. Returns false when the click had to be forced.
func _press(b: BaseButton, t: int) -> bool:
	var reached: bool = await _click(b)
	if not is_instance_valid(b):
		return reached
	if not reached:
		if b is OptionButton:
			pass
		elif b.toggle_mode:
			b.button_pressed = not b.button_pressed
			if is_instance_valid(b):
				b.pressed.emit()
		else:
			b.pressed.emit()
	if b is OptionButton and t >= 0 and is_instance_valid(b):
		var pop := (b as OptionButton).get_popup()
		pop.index_pressed.emit(t)
		pop.hide()
	return reached


## Show the root page and replay `path` ([[index, item, label], ...]) on it. False when the page is no longer there.
func _goto(show: Callable, path: Array) -> bool:
	await _leave_match()
	if Settings.language != lang or Settings.device != ("pc" if size == "pc" else "mobile"):
		_reset_settings()        # (a flag or the device page pressed before: back to this run's)
	show.call()
	await _frames(3)
	for step in path:
		var bs := _buttons()
		var i: int = step[0]
		var b: BaseButton = null
		if i < bs.size() and _label(bs[i]) == step[2]:
			b = bs[i]
		else:
			for x in bs:
				if _label(x) == step[2]:
					b = x
					break
		if b == null:
			return false
		await _press(b, step[1])
		await _frames(3)
		_close_windows()
		if main.game != null:
			return false
	return true


func _has_back() -> bool:
	if is_instance_valid(main._esc_button) and main._esc_button.is_visible_in_tree():
		return true
	var rx := RegEx.create_from_string(BACK_RX)
	for b in _buttons():
		if rx.search(_label(b)) != null:
			return true
	return false


func _is_top_menu() -> bool:
	return main.menu_buttons.has("g_offline") and main.menu_group == ""


## A page seen for the first time: its picture, the layout checks, a way back.
func _visit(screen: String) -> void:
	screens_n += 1
	var before := counts.duplicate()
	if not _is_top_menu() and main.game == null and not _has_back():
		flag("NOBACK", screen, "", "no BACK/CLOSE button and no Esc target")
	_audit(screen)
	var flagged := counts.hash() != before.hash()
	if shots == "all" or (shots == "flags" and flagged):
		await _snap(screen)


func _snap(screen: String) -> void:
	shot_n += 1
	var img := root.get_viewport().get_texture().get_image()
	if img == null:
		return
	var w := 640 if size == "pc" else 720
	img.resize(w, int(img.get_height() * float(w) / img.get_width()), Image.INTERPOLATE_BILINEAR)
	var safe := RegEx.create_from_string("[^A-Za-z0-9_]+").sub(screen, "_", true).left(40)
	img.save_jpg("%s/%s_%s_%02d_%s.jpg" % [out, tag, part, shot_n, safe], 0.55)


## Crawl one root page to `depth` presses.
func crawl(root_name: String, show: Callable, max_depth := -1, max_pages := 30) -> void:
	if max_depth < 0:
		max_depth = depth
	_reset_settings()
	if not await _goto(show, []):
		return
	_errs(root_name, "(show the page)")
	var seen := {_sig(): true}
	await _visit(root_name)
	var queue: Array = [[[], root_name]]
	var pages := 1
	while not queue.is_empty():
		var item: Array = queue.pop_front()
		var path: Array = item[0]
		var where: String = item[1]
		if not await _goto(show, path):
			continue
		var bs := _buttons()
		var plan: Array = []
		for i in bs.size():
			var b: BaseButton = bs[i]
			if _skip(b):
				continue
			for t in _targets(b):
				plan.append([i, t, _label(b)])
		print("  page %s: %d buttons, %d presses" % [where, bs.size(), plan.size()])
		for step in plan:
			if _part_presses >= budget:
				print("  (budget of %d presses reached)" % budget)
				return
			if not await _goto(show, path):
				break
			errlog.take()
			var cur := _buttons()
			var b: BaseButton = null
			if step[0] < cur.size() and _label(cur[step[0]]) == step[2]:
				b = cur[step[0]]
			if b == null:
				continue
			var what := String(step[2]) + ("" if step[1] < 0 else " #%d" % step[1])
			if b is OptionButton and step[1] >= 0:
				what = String(step[2]) + " -> '" + (b as OptionButton).get_item_text(step[1]).left(30) + "'"
			var s0 := _state()
			var sig0 := _sig()
			var t0 := Time.get_ticks_msec()
			var reached: bool = await _press(b, step[1])
			await _frames(4)
			var ms := Time.get_ticks_msec() - t0
			pressed_n += 1
			_part_presses += 1
			var new_page := false
			var popup := false
			for w in root.get_children():
				if w is Window and w.visible and w != root:
					popup = true
			_errs(where, what)
			if not reached and not (b is OptionButton):
				flag("COVERED", where, what, "the click at its middle did not reach it (pressed by signal)")
			var started := main.game != null
			if started:
				print("   %s -> a match started" % what)
			else:
				var sig1 := _sig()
				if sig1 != sig0:
					new_page = true
				if _state() == s0 and not popup:
					flag("NOOP", where, what, "nothing visible changed")
				if new_page and not seen.has(sig1) and pages < max_pages:
					seen[sig1] = true
					pages += 1
					var nm := where + " > " + what.left(24)
					await _visit(nm)
					if path.size() + 1 < max_depth:
						queue.append([path + [step], nm])
			if ms > SLOW_MS:
				flag("SLOW", where, what, "%d ms" % ms)
			slowest.append([ms, where + " | " + what])
			if slowest.size() > 40:
				slowest.sort_custom(func(a: Array, c: Array) -> bool: return a[0] > c[0])
				slowest.resize(20)
			_close_windows()


## ------------------------------------------------------------------------------------------------ the parts

func _part_menus() -> void:
	await crawl("menu", func() -> void:
		main.menu_group = ""
		main.show_menu(), 2)
	await crawl("menu_offline", func() -> void:
		main.menu_group = "offline"
		main.show_menu(), 1)
	await crawl("menu_online", func() -> void:
		main.menu_group = "online"
		main.show_menu(), 1)
	await crawl("device", func() -> void: main.show_device(), 1)
	await crawl("patch_notes", func() -> void: main.show_patch_notes(true), 1)
	await crawl("music", func() -> void: main.show_music(), 1)
	await crawl("layout", func() -> void: main.show_layout(), 1)
	await crawl("anim_viewer", func() -> void: main.show_anim_viewer(), 1)
	await crawl("logs", func() -> void: main.show_logs(), 1)
	await crawl("editor_menu", func() -> void: main.show_editor_menu(), 1)
	for k in main.HELP:
		await crawl("help_" + String(k), func() -> void: main.show_help(k), 1)
	await crawl("tutorial", func() -> void: main.show_tutorial(), 2)


func _part_settings() -> void:
	for t in main.SETTINGS_TABS:
		await crawl("settings_" + String(t).to_lower(), func() -> void: main.show_settings(t), 2)


func _part_campaign() -> void:
	for s in Campaign.storylines():
		var id := String(s["id"])
		await crawl("hub_" + id, func() -> void:
			CampaignMenu.line = id
			CampaignMenu.map_open = false
			main.show_campaign(), 2, 20)
	for skin in ["parchment", "brass", "chart"]:
		await crawl("warmap_" + skin, func() -> void:
			CampaignMenu.map_skin = skin
			CampaignMenu.map_pick = ""
			CampaignMenu.war_map(main), 2, 20)
	# a mission card of every mission that has a pin (the briefing): the first of each line
	var n := 0
	for s in Campaign.storylines():
		for mid in s.get("missions", []):
			await crawl("briefing_" + String(mid), func() -> void: CampaignMenu.briefing(main, String(mid)), 1, 4)
			n += 1
			if n % 3 == 0:
				break


func _part_skirmish() -> void:
	for p in ["1v1", "2v2", "FFA"]:
		await crawl("lobby_" + p, func() -> void:
			main._preset(p)
			main.lobby["map"] = main._preset_pool(p)
			main.show_skirmish(), 2, 25)


func _part_editor() -> void:
	await crawl("map_editor", func() -> void: main.show_map_editor(), 2, 20)


func _part_worldwar() -> void:
	await crawl("worldwar_setup", func() -> void: WWPage.show_setup(main), 2, 25)


func _part_tournaments() -> void:
	await crawl("tournaments", func() -> void: TournamentPage.show_home(main), 2, 25)


func _part_online() -> void:
	# (no real sign-in: the rooms page and ranked as they come up with no network)
	await crawl("online", func() -> void: main.show_online(), 1, 10)
	await crawl("ranked", func() -> void: main.show_ranked(), 1, 10)


func _part_replays() -> void:
	await crawl("replays", func() -> void: main.show_replays(), 2, 15)


## ------------------------------------------------------------------------------------------------ a real match

const FOE := {"crown": "brood", "clockwork": "crown", "brood": "clockwork"}
var g: Game


func _rich() -> void:
	var p: Dictionary = g.players[0]
	p["gold"] = 100000
	p["res2"] = 100000.0
	p["tension"] = 100000.0
	p["cap"] = 200
	if g.faction_of(0) == "clockwork" and g.has_method("give_batteries"):
		g.give_batteries(0, 200)


func _card_sig() -> String:
	var ls: PackedStringArray = []
	for it in g.hud._build_card():
		ls.append(String(it[1]))
	return "|".join(ls)


func _gstate() -> String:
	var p: Dictionary = g.players[0]
	var sel: PackedStringArray = []
	for e in g.selection:
		if is_instance_valid(e):
			sel.append(str(e.get_instance_id()) + str(e.get("order")) + str(e.get("state")) + str(e.get("queue")))
	return "%s|%s|%s|%s|%s|%d|%d|%s|%s|%s" % [p["gold"], p["res2"], p.get("tension", 0), g.hud.page, g.controls.mode,
		g.units.size(), g.buildings.size(), ",".join(sel), g.hud._msg, _card_sig()]


func _part_match(fac: String) -> void:
	_reset_settings()
	await _leave_match()
	main.start({"map": "greenhold", "seed": 5, "slots": [
		{"who": "you", "faction": fac, "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "easy", "faction": FOE[fac], "colour": 1, "side": 1, "strategy": "balanced"}]})
	await _frames(3)
	g = main.game
	if g == null:
		flag("ERROR", "match_" + fac, "start", "no match")
		return
	g.hud.countdown = 0.0
	paused = false
	for a in g.ais:
		a.process_mode = Node.PROCESS_MODE_DISABLED
	await create_timer(1.0).timeout
	_errs("match_" + fac, "(start)")
	await _visit("match_" + fac)
	_rich()
	var hall: Building = null
	for b in g.buildings:
		if b.team == 0 and b.kind == g.faction_hall(0) and not b.dead:
			hall = b
	var at: Vector2 = hall.center() if hall else g.camera.position
	# every building of the faction, finished, round the hall
	var things: Array = []
	if fac != "brood":
		for k in Defs.BUILDINGS:
			if String(Defs.BUILDINGS[k].get("faction", "")) != fac:
				continue
			var c: Vector2i = g.find_spot(0, k, hall, 4, 30) if hall else Vector2i(-1, -1)
			if c.x < 0:
				continue
			var b: Building = g._add_building(k, 0, c, true)
			if b:
				things.append(b)
		_errs("match_" + fac, "(spawn buildings)")
	# every unit of the faction
	var off := 0
	for k in Defs.UNITS:
		var d: Dictionary = Defs.UNITS[k]
		if String(d.get("faction", "")) != fac or d.get("campaign_only", false):
			continue
		var u: Unit = g._add_unit(k, 0, at + Vector2(90 + (off % 8) * 34, -120 + (off / 8) * 34))
		off += 1
		if u:
			u.auto_work = false
			if Defs.AMMO.has(k):
				u.set_ammo(Defs.ammo_full(k))
			if "wind" in u:
				u.wind = 1.0
			things.append(u)
	await create_timer(0.5).timeout
	_errs("match_" + fac, "(spawn units)")
	print("  %d things to select" % things.size())
	var done_kinds := {}
	for e in things:
		if not is_instance_valid(e) or e.dead:
			continue
		if done_kinds.has(e.kind):
			continue
		done_kinds[e.kind] = true
		await _card_of(e, fac)
		if _part_presses >= budget * 3:
			print("  (budget reached)")
			break
	await _stale_card_check(fac)
	await _keys(fac)
	await _minimap(fac)
	await _match_menu(fac)
	g = null


## Every enabled button of `e`'s card (and of its sub pages, one level), each on a fresh selection.
func _card_of(e: Node, fac: String, sub := "", depth_left := 1) -> void:
	var screen := "card_%s%s" % [e.kind, (":" + sub) if sub != "" else ""]
	g.hud.page = ""
	if g.controls.mode != "":
		g.controls.cancel_mode()
	g.set_selection([e])
	await _frames(2)
	if sub != "":
		g.hud.page = sub
		await _frames(1)
	var items: Array = g.hud._build_card()
	if sub == "":
		screens_n += 1
	var labels: Array = []
	for it in items:
		labels.append(String(it[1]))
	for li in labels.size():
		if not is_instance_valid(e) or e.dead:
			return
		_rich()
		g.hud.page = ""
		if g.controls.mode != "":
			g.controls.cancel_mode()
		g.set_selection([e])
		await process_frame
		if sub != "":
			g.hud.page = sub
		var cur: Array = g.hud._build_card()
		var it: Array = []
		for x in cur:
			if String(x[1]) == labels[li]:
				it = x
		if it.is_empty() or not bool(it[3]):
			continue
		var lab := String(it[1])
		var up := lab.to_upper()
		if up.contains("DEMOLISH") or up.contains("DELETE") or up.contains("DISBAND") or up.contains("RECYCLE") or up.contains("SALVAGE"):
			continue      # (would take the thing away from the rest of the sweep)
		errlog.take()
		var s0 := _gstate()
		var page0: String = g.hud.page
		var t0 := Time.get_ticks_msec()
		var cb: Callable = it[2]
		cb.call()
		await _frames(3)
		pressed_n += 1
		_part_presses += 1
		_errs(screen, lab)
		var mode := String(g.controls.mode)
		if mode != "":
			# a placement or a target: started, then cancelled (Esc), like a player changing his mind
			var ev := InputEventKey.new()
			ev.keycode = KEY_ESCAPE
			ev.pressed = true
			root.push_input(ev)
			await process_frame
			if g.controls.mode != "":
				g.controls.cancel_mode()
			await process_frame
			_errs(screen, lab + " (cancel)")
		elif g.hud.page != page0 and depth_left > 0:
			await _card_of(e, fac, g.hud.page, depth_left - 1)
		elif _gstate() == s0:
			flag("NOOP", screen, lab, "nothing changed (money, page, mode, queue, orders, message, card)")
		var ms := Time.get_ticks_msec() - t0
		if ms > SLOW_MS:
			flag("SLOW", screen, lab, "%d ms" % ms)
	if g.hud.page != "":
		g.hud.page = ""


## 7.6 of docs/qa_ui_review.md: select the whole army, then a production building within 0.4 s; the card must be the
## building's.
func _stale_card_check(fac: String) -> void:
	var army: Array = []
	var prod: Node = null
	for u in g.units:
		if u.team == 0 and not u.dead and is_instance_valid(u):
			army.append(u)
	for b in g.buildings:
		if b.team == 0 and not b.dead and b.kind != g.faction_hall(0) and not (Defs.BUILDINGS.get(b.kind, {}).get("trains", []) as Array).is_empty():
			prod = b
			break
	if prod == null:
		for b in g.buildings:
			if b.team == 0 and not b.dead:
				prod = b
				break
	if prod == null or army.is_empty():
		return
	for delay in [0.0, 0.05, 0.2, 0.4]:
		g.set_selection(army)
		await process_frame
		var army_card := _card_sig()
		if delay > 0.0:
			await create_timer(delay).timeout
		g.set_selection([prod])
		await process_frame
		var c1 := _card_sig()
		await _frames(3)
		var c2 := _card_sig()
		# what the HUD actually holds for its buttons (drawn from _card_buttons)
		var shown: PackedStringArray = []
		for x in g.hud._card_buttons:
			shown.append(String(x.get("label", x.get("item", [null, ""])[1] if x.has("item") else "")))
		print("  7.6 check delay %.2f: card %s / after 3 frames %s" % [delay, "same as army" if c1 == army_card else "building's", "same as army" if c2 == army_card else "building's"])
		if c2 == army_card and army_card != "":
			flag("STALE", "match_" + fac, "army -> %s (%.2f s)" % [prod.kind, delay], "the card still shows the army's buttons")
	_errs("match_" + fac, "7.6 check")


func _key(code: int, ctrl := false, shift := false) -> void:
	for down in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = code
		ev.physical_keycode = code
		ev.pressed = down
		ev.ctrl_pressed = ctrl
		ev.shift_pressed = shift
		root.push_input(ev)
		await process_frame


func _keys(fac: String) -> void:
	var halls: Array = g.halls_of(0)
	var codes := [KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5, KEY_F6, KEY_F7, KEY_F8, KEY_F9, KEY_F11, KEY_F12,
		KEY_TAB, KEY_SPACE, KEY_BACKSPACE, KEY_PERIOD, KEY_COMMA, KEY_H, KEY_A, KEY_S, KEY_B, KEY_QUOTELEFT, KEY_1]
	for c in codes:
		if not halls.is_empty():
			g.set_selection([halls[0]])
		await process_frame
		errlog.take()
		var s0 := _gstate() + str(g.camera.position) + str(g.hud.view_open) + str(g.hud.menu_open)
		await _key(c)
		await _frames(2)
		pressed_n += 1
		_part_presses += 1
		var nm := OS.get_keycode_string(c)
		_errs("match_" + fac + " keys", nm)
		var s1 := _gstate() + str(g.camera.position) + str(g.hud.view_open) + str(g.hud.menu_open)
		print("   key %s -> %s" % [nm, "changed" if s1 != s0 else "no change"])
		# undo what a key opened
		if g.hud.menu_open:
			g.hud.toggle_menu(false)
		if g.hud.paused:
			g.hud.set_paused(false)
		if g.controls.mode != "":
			g.controls.cancel_mode()
		g.hud.page = ""
	# control groups: Ctrl+1 then 1
	var us: Array = g.workers(0)
	if not us.is_empty():
		g.set_selection(us)
		await _key(KEY_2, true)
		g.set_selection([])
		await _key(KEY_2)
		await _frames(2)
		if g.selection.size() != us.size():
			flag("NOOP", "match_" + fac + " keys", "Ctrl+2 then 2", "the group did not come back (%d of %d)" % [g.selection.size(), us.size()])
		_errs("match_" + fac + " keys", "control group")


func _minimap(fac: String) -> void:
	var r: Rect2 = g.hud.mini_rect()
	if r.size.x < 4:
		flag("NOOP", "match_" + fac, "minimap", "no minimap rect")
		return
	var cam0: Vector2 = g.camera.position
	for at in [r.position + r.size * 0.2, r.position + r.size * 0.8]:
		for down in [true, false]:
			var ev := InputEventMouseButton.new()
			ev.button_index = MOUSE_BUTTON_LEFT
			ev.pressed = down
			ev.position = at
			ev.global_position = at
			root.push_input(ev, true)
			await process_frame
		pressed_n += 1
		_part_presses += 1
	await _frames(2)
	_errs("match_" + fac, "minimap click")
	if g.camera.position.distance_to(cam0) < 4:
		flag("NOOP", "match_" + fac, "minimap click", "the camera did not move")


func _match_menu(fac: String) -> void:
	var screen := "match_" + fac + " menu"
	g.hud.toggle_menu(true)
	await _frames(3)
	await _visit(screen)
	var labels: Array = []
	for b in g.hud._menu_buttons():
		labels.append(String(b.get("label", "")))
	print("  match menu: %s" % ", ".join(labels))
	for lab in labels:
		var up := String(lab).to_upper()
		if up.begins_with("QUIT") or up.contains("SAIR") or up.contains("SALIR") or up.contains("SURRENDER") or up.contains("RENDER") or up.contains("MENU"):
			continue      # (leaving the match: done at the end)
		if g == null or main.game == null:
			return
		g.hud.toggle_menu(true)
		await process_frame
		var b: Dictionary = {}
		for x in g.hud._menu_buttons():
			if String(x.get("label", "")) == lab:
				b = x
		if b.is_empty() or not b.get("enabled", true) or not b.has("cb"):
			continue
		errlog.take()
		(b["cb"] as Callable).call()
		await _frames(4)
		pressed_n += 1
		_part_presses += 1
		_errs(screen, lab)
		# a page opened over the match (settings) or a question: closed again
		_close_windows()
		if main.game == null:
			print("   %s left the match" % lab)
			return
		if g.hud.paused:
			g.hud.set_paused(false)
		if is_instance_valid(main._esc_button):
			main._esc_button.pressed.emit()
			await _frames(2)
	if main.game == null:
		return
	g.hud.toggle_menu(false)
	# pause and back
	g.hud.set_paused(true)
	await _frames(2)
	await _visit("match_" + fac + " paused")
	g.hud.set_paused(false)
	_errs("match_" + fac, "pause")
	# save, leave, CONTINUE
	main._autosave()
	await _frames(2)
	main._to_menu()
	await _frames(3)
	_errs("match_" + fac, "save + leave")
	var cont: Button = main.menu_buttons.get("continue")
	if cont == null:
		flag("NOOP", "menu", "CONTINUE", "no CONTINUE after a save of a %s match" % fac)
		return
	cont.pressed.emit()
	await _frames(4)
	await create_timer(0.5).timeout
	_errs("match_" + fac, "CONTINUE (load)")
	if main.game == null:
		flag("ERROR", "menu", "CONTINUE", "the saved match did not load")
	else:
		print("  CONTINUE loaded the %s match" % fac)
	await _leave_match()


## ------------------------------------------------------------------------------------------------ layout checks
## (the same checks as tools/qa_ui_audit.gd)

func _vis_rect(c: Control) -> Rect2:
	var r := c.get_global_rect()
	var p := c.get_parent()
	while p != null and not (p is Window or p is CanvasLayer):
		if p is ScrollContainer or (p is Control and (p as Control).clip_contents):
			r = r.intersection((p as Control).get_global_rect())
		p = p.get_parent()
	return r


func _clipped_by_parent(c: Control) -> bool:
	var p := c.get_parent()
	while p != null:
		if p is ScrollContainer or (p is Control and (p as Control).clip_contents):
			return true
		if p is Window or p is CanvasLayer:
			break
		p = p.get_parent()
	return false


func _shown(c: Control) -> String:
	var t := ""
	if c is Label:
		t = (c as Label).text
	elif c is Button:
		t = (c as Button).text
	elif c is RichTextLabel:
		t = (c as RichTextLabel).get_parsed_text()
	if c.auto_translate_mode != Node.AUTO_TRANSLATE_MODE_DISABLED and not c is RichTextLabel:
		t = c.atr(t)
	return t


func _path(c: Node) -> String:
	var s := String(c.name)
	var p := c.get_parent()
	var n := 0
	while p != null and n < 2:
		s = String(p.name) + "/" + s
		p = p.get_parent()
		n += 1
	return s


func _audit(screen: String) -> void:
	var vp := root.get_visible_rect()
	var texts: Array = []
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		for ch in n.get_children():
			stack.append(ch)
		if not n is Control:
			continue
		var c := n as Control
		if not c.is_visible_in_tree() or c.modulate.a < 0.05:
			continue
		if not (c is Label or c is Button or c is RichTextLabel):
			continue
		var t := _shown(c)
		if t.strip_edges() == "":
			continue
		var r := c.get_global_rect()
		if r.size.x < 1 or r.size.y < 1:
			continue
		texts.append(c)
		var f: Font = c.get_theme_font("font") if not c is RichTextLabel else c.get_theme_font("normal_font")
		var fs: int = c.get_theme_font_size("font_size") if not c is RichTextLabel else c.get_theme_font_size("normal_font_size")
		var one := t.replace("\n", " ").substr(0, 50)
		if c is Label:
			var l := c as Label
			if l.autowrap_mode == TextServer.AUTOWRAP_OFF and (l.clip_text or l.text_overrun_behavior != TextServer.OVERRUN_NO_TRIMMING):
				var w := 0.0
				for ln in t.split("\n"):
					w = maxf(w, f.get_string_size(ln, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
				if w > r.size.x + 2:
					flag("CUT", screen, _path(c), "'%s' text %d > box %d" % [one, int(w), int(r.size.x)])
			elif l.autowrap_mode != TextServer.AUTOWRAP_OFF:
				var longest := 0.0
				for word in t.split(" ", false):
					longest = maxf(longest, f.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
				if longest > r.size.x + 2 and t.length() > 3:
					flag("SQUEEZED", screen, _path(c), "'%s' word %d > box %d" % [one, int(longest), int(r.size.x)])
		elif c is Button:
			var b := c as Button
			var st: StyleBox = b.get_theme_stylebox("normal")
			var mx := 0.0
			if st:
				mx = st.get_margin(SIDE_LEFT) + st.get_margin(SIDE_RIGHT)
			var icon_w := 0.0
			if b.icon != null and not b.expand_icon:
				icon_w = b.icon.get_width() + b.get_theme_constant("h_separation")
			var w := 0.0
			for ln in t.split("\n"):
				w = maxf(w, f.get_string_size(ln, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
			if (b.clip_text or b.text_overrun_behavior != TextServer.OVERRUN_NO_TRIMMING) and b.autowrap_mode == TextServer.AUTOWRAP_OFF and w + mx + icon_w > r.size.x + 3:
				flag("CUT", screen, _path(c), "button '%s' text %d > room %d" % [one, int(w), int(r.size.x - mx - icon_w)])
		if not vp.grow(2).encloses(r) and not _clipped_by_parent(c):
			flag("OFF", screen, _path(c), "'%s' rect %s" % [one, str(r)])
	for i in texts.size():
		var a: Control = texts[i]
		var ra := _vis_rect(a)
		for j in range(i + 1, texts.size()):
			var b: Control = texts[j]
			if a.is_ancestor_of(b) or b.is_ancestor_of(a):
				continue
			var rb := _vis_rect(b)
			var x := ra.intersection(rb)
			if x.get_area() <= 0:
				continue
			var small := minf(ra.get_area(), rb.get_area())
			if x.get_area() > 0.25 * small and x.size.x > 6 and x.size.y > 6:
				flag("OVERLAP", screen, "", "'%s' x '%s'" % [_shown(a).replace("\n", " ").substr(0, 40), _shown(b).replace("\n", " ").substr(0, 40)])
	if lang != "en":
		for k in Loc.misses:
			flag("EN", screen, "", "'%s'" % String(k).replace("\n", "\\n").substr(0, 90))
	Loc.misses.clear()


## A script error stops _run where it is: never hang (wall-clock time).
var _deadline := Time.get_ticks_msec() + 5400000


func _process(_delta: float) -> bool:
	if Time.get_ticks_msec() > _deadline:
		print("WATCHDOG: gave up after 90 min")
		_finish()
	return false
