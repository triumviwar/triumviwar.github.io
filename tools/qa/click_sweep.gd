extends SceneTree
## THE CLICK SWEEP (job qa-click-sweep, the owner 2026-11-28: "make a test everything, analyse everything clickable
## routine"; docs/qa_click_sweep.md). One language and one screen size a run:
##   1. MATCHES: a skirmish of each faction (Crown, Clockwork, Brood) against a switched-off computer, rich, with every
##      building and unit of the faction put down; every kind is selected and EVERY command card button is clicked like a
##      hand (a mouse click at its middle), and every page a button opens (BUILD, research...) too; placing is started and
##      cancelled; then the F-keys, Tab, the minimap, the in-game menu (each button, the questions answered NO), pause,
##      the Settings over the match, the autosave and CONTINUE.
##   2. MENUS: from the main menu every button of every page is clicked (the page shown fresh before each click, by
##      replaying the clicks that led to it), and every new page it opens is walked the same way (breadth first): the
##      device page, OFFLINE/ONLINE, Settings' tabs, patch notes, music, help, skirmish setup (every option, the map
##      picker), replays, editor, map editor, logs, world war, tournaments, online and ranked (loopback relay only), the
##      tutorial list, the campaign hubs of every storyline and the war map in each skin. A click that starts a match, a
##      lesson or a mission is followed by a look (2 s), a picture, and a return to the menu.
##   3. The campaign walked again with every mission finished (a made-up progress), so every hub, room and card opens.
## Each click is recorded: screen, button, what it did. Flags:
##   ERROR     a SCRIPT ERROR / push_error / engine error while the click ran (the message, file:line)
##   DEAD      a button wired to nothing (no signal connection, no script)
##   NOCHANGE  wired, but nothing on screen or in the settings changed (often fine: a sound, a copy; look)
##   COVERED   the button's middle is under another control: a hand can't click it there
##   OFFSCREEN the button's middle is outside the window (and not inside a scroll list)
##   CUT / OFF / OVERLAP / SQUEEZED / EN   each screen's text checks (as tools/qa_ui_audit.gd): text cut by its box, text
##             off the screen, two texts on top of each other, words broken letter by letter, English with no
##             translation (pt/es)
##   NOBACK    a menu page with no BACK button and Esc does nothing (it may still lead on: a SKIP, a START)
##   STUCK     a menu page none of whose buttons leads anywhere, and Esc does nothing: a dead end
##   SLOW      a click that took over SLOW_MS of real time to settle (a frame-time spike)
##   HUDOVERLAP / HUDOFF   card buttons over each other, over the minimap or panels, or outside the window (the HUD is
##             drawn by hand, so its rects are checked instead of Controls)
## Run (xvfb, one size): xvfb-run -a -s "-screen 0 1600x900x24" godot --rendering-driver opengl3 --resolution 1600x900 \
##   --script res://tools/qa/click_sweep.gd -- out=<dir> lang=en device=pc [parts=matches,menus,veteran] [shots=all|flagged|none]
## Normally through tools/qa/click_sweep.sh (all sizes and languages, or --quick). Writes <out>/<tag>.json (every click,
## page and flag) and the pictures <out>/shots/<tag>_<screen>.jpg; tools/qa/click_sweep_report.py makes the tables.

const SLOW_MS := 6000          # (software drawing under xvfb: a page that builds slowly here may be fine on a real GPU)
const MAX_DEPTH := 6
const MAX_PAGES := 260
const MAX_PRESSES_PAGE := 90
const SAME_PAGE := 0.72          # two pages whose buttons overlap this much (Jaccard) are one page
## Buttons never clicked: they quit the program, open the browser / a mail program, wipe saves, or sign in for real.
const QUIT_WORDS := ["EXIT", "SAIR", "SALIR"]          # (the main menu's: they close the program; elsewhere they leave a page)
const SKIP_WORDS := ["QUIT GAME", "YES, QUIT", "SIM, SAIR", "SÍ, SALIR", "DISCORD", "WEBSITE", "SITE", "OPEN FOLDER", "ABRIR PASTA",
		"ABRIR CARPETA", "DOWNLOAD", "BAIXAR", "DESCARGAR", "STEAM", "GITHUB", "ITCH", "DELETE ALL", "APAGAR TUDO",
		"BORRAR TODO", "RESET ALL", "REPORT A BUG", "SEND REPORT", "WINDOWS", "ANDROID", "PLAY ON THE WEB", "JOGAR NA WEB",
		"JUGAR EN LA WEB", "OPEN IN BROWSER", "ABRIR NO NAVEGADOR", "ABRIR EN EL NAVEGADOR"]
## Engine messages that only say this machine has no speech engine or sound card (the narrator asks once a run).
const KNOWN_NOISE := ["Parameter \"synth\" is null", "click_sweep.gd", "No audio"]
## A page's BACK by its words (besides main._esc_button).
const BACK_WORDS := ["BACK", "VOLTAR", "VOLVER", "LEAVE", "SAIR", "SALIR", "MENU", "CLOSE", "FECHAR", "CERRAR", "DONE", "OK", "LEAVE", "SAIR DA",
		"QUIT TO", "RETURN", "RETURN TO", "CANCEL", "CANCELAR", "<", "×", "X"]

var main: Node
var out := ""
var lang := "en"
var device := "pc"
var tag := ""
var parts: Array = ["matches", "menus", "veteran"]
var shots_mode := "all"
var factions: Array = ["crown", "clockwork", "brood"]
var errs: Array = []
var _log: Logger
var _mutex := Mutex.new()

var presses: Array = []          # {screen, button, result, flags, ms}
var pages: Array = []            # {id, route, keys, shot}
var flags: Array = []            # {kind, screen, detail}
var _flag_seen := {}
var _shot_done := {}
var _page_sets: Array = []
var _cur_page_size := 0       # [[id, keyset Dictionary]]
var _match_starts := {}          # what a press started -> count (one look a kind)
var _cfg0 := ""
var t_start := 0
var _deadline := 0


class Catch extends Logger:
	var host
	func _init(h) -> void:
		host = h
	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, script_backtrace: Array[ScriptBacktrace]) -> void:
		if error_type == ERROR_TYPE_WARNING:
			return
		var kind: String = ["ERROR", "WARNING", "SCRIPT ERROR", "SHADER ERROR"][clampi(error_type, 0, 3)]
		var where := "%s:%d %s" % [file.get_file(), line, function]
		if not script_backtrace.is_empty() and script_backtrace[0].get_frame_count() > 0:
			where = "%s:%d %s" % [script_backtrace[0].get_frame_file(0).get_file(), script_backtrace[0].get_frame_line(0), script_backtrace[0].get_frame_function(0)]
		host._add_err("%s: %s @ %s" % [kind, rationale if rationale != "" else code, where])
	func _log_message(message: String, error: bool) -> void:
		if error and message.contains("SCRIPT ERROR"):
			host._add_err(message.strip_edges().split("\n")[0])


func _add_err(s: String) -> void:
	_mutex.lock()
	errs.append(s)
	_mutex.unlock()


func _take_errs() -> Array:
	_mutex.lock()
	var e := errs.duplicate()
	errs.clear()
	_mutex.unlock()
	# (the sweep's own noise: an image saved while the window is hidden, audio with no device)
	return e.filter(func(x: String) -> bool:
		for k in KNOWN_NOISE:
			if x.contains(k):
				return false
		return true)


# ------------------------------------------------------------------ setup

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := String(a).split("=", true, 1)
		match kv[0]:
			"out": out = kv[1]
			"lang": lang = kv[1]
			"device": device = kv[1]
			"parts": parts = Array(kv[1].split(","))
			"shots": shots_mode = kv[1]
			"factions": factions = Array(kv[1].split(","))
	if out == "":
		out = ProjectSettings.globalize_path("user://click_sweep")
	DirAccess.make_dir_recursive_absolute(out + "/shots")
	_log = Catch.new(self)
	OS.add_logger(_log)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	Settings.load_all()
	Settings.device = device
	Settings.language = lang
	Settings.relay_url = "ws://127.0.0.1:9"          # (online pages: a relay nobody answers, refused at once)
	Settings.ladder_url = ""
	Settings.narrator = false
	Loc.set_lang(lang)
	Settings.apply()
	Settings.save_all()
	_cfg0 = FileAccess.get_file_as_string(Settings.PATH) if FileAccess.file_exists(Settings.PATH) else ""
	var vs := Vector2(DisplayServer.window_get_size())
	tag = "%s_%s_%dx%d" % [lang, device, int(vs.x), int(vs.y)]
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	t_start = Time.get_ticks_msec()
	_deadline = t_start + 150 * 60 * 1000
	_run.call_deferred()


func _process(_d: float) -> bool:
	if Time.get_ticks_msec() > _deadline:
		print("WATCHDOG: gave up after 150 min")
		_write()
		quit(2)
	return false


## The settings as the sweep started (a click on a switch changed them): put back, with this run's language and device.
func _restore_settings() -> void:
	var now := FileAccess.get_file_as_string(Settings.PATH) if FileAccess.file_exists(Settings.PATH) else ""
	if now == _cfg0 and Settings.language == lang and Settings.device == device and Loc.lang == lang:
		return
	var f := FileAccess.open(Settings.PATH, FileAccess.WRITE)
	f.store_string(_cfg0)
	f.close()
	Settings.load_all()
	Settings.device = device
	Settings.language = lang
	Loc.set_lang(lang)
	Settings.apply()


func _frames(n := 1) -> void:
	for i in n:
		await process_frame


func _wait(sec: float) -> void:
	await create_timer(sec, true, false, true).timeout


func _run() -> void:
	await _frames(3)
	Loc.track = true
	print("SWEEP %s parts %s" % [tag, str(parts)])
	if "matches" in parts:
		for fac in factions:
			await _match_sweep(fac)
			_write()
	if "menus" in parts:
		await _crawl("", _seeds())
		_write()
	if "veteran" in parts:
		_veteran_progress()
		await _crawl("vet:", _campaign_seeds())
		_write()
	_restore_settings()
	_write()
	print("SWEEP DONE %s: %d pages, %d clicks, %d flags, %.1f min" % [tag, pages.size(), presses.size(), flags.size(), (Time.get_ticks_msec() - t_start) / 60000.0])
	quit(0)


# ------------------------------------------------------------------ records

func _flag(kind: String, screen: String, detail: String) -> void:
	var k := kind + "|" + screen + "|" + detail
	if _flag_seen.has(k):
		return
	_flag_seen[k] = true
	flags.append({"kind": kind, "screen": screen, "detail": detail})
	print("FLAG %s [%s] %s" % [kind, screen, detail])


func _write() -> void:
	var d := {"tag": tag, "lang": lang, "device": device, "size": [int(root.get_visible_rect().size.x), int(root.get_visible_rect().size.y)],
		"minutes": (Time.get_ticks_msec() - t_start) / 60000.0, "pages": pages, "presses": presses, "flags": flags}
	var f := FileAccess.open(out + "/" + tag + ".json", FileAccess.WRITE)
	f.store_string(JSON.stringify(d, " "))
	f.close()


func _snap(screen: String, flagged := false) -> String:
	if shots_mode == "none" or DisplayServer.get_name() == "headless":
		return ""
	if shots_mode == "flagged" and not flagged:
		return ""
	var nm := RegEx.create_from_string("[^A-Za-z0-9_]+").sub(screen.replace("/", "_"), "_", true).strip_edges().left(60)
	if _shot_done.has(nm):
		return _shot_done[nm]
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	if img == null or img.is_empty():
		return ""
	if img.get_width() > 1280:
		img.resize(1280, int(img.get_height() * 1280.0 / img.get_width()), Image.INTERPOLATE_BILINEAR)
	var p := "%s/shots/%s_%s.jpg" % [out, tag, nm]
	img.save_jpg(p, 0.6)
	_shot_done[nm] = p.get_file()
	return p.get_file()


# ------------------------------------------------------------------ the text checks of a screen (as tools/qa_ui_audit.gd)

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


func _rect(c: Control) -> Rect2:
	return c.get_global_rect() if c.get_canvas_layer_node() == null else c.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, c.size)


func _vis_rect(c: Control) -> Rect2:
	var r := _rect(c)
	var p := c.get_parent()
	while p != null and not (p is Window or p is CanvasLayer):
		if p is ScrollContainer or (p is Control and (p as Control).clip_contents):
			r = r.intersection(_rect(p as Control))
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


func _path(c: Node) -> String:
	var s := String(c.name)
	var p := c.get_parent()
	var n := 0
	while p != null and n < 3:
		s = String(p.name) + "/" + s
		p = p.get_parent()
		n += 1
	return s


func _audit(screen: String) -> int:
	var found := 0
	var vp := root.get_visible_rect()
	var texts: Array = []
	var top: Node = _top_modal() if main.game == null else main.ui_layer
	var stack: Array = [root if top == main.ui_layer else top]
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
		if not c is RichTextLabel and c.get_theme_color("font_color").a < 0.05:
			continue        # (a name that shows only when pointed at: the hubs' hotspots over the painting)
		var r := _rect(c)
		if r.size.x < 1 or r.size.y < 1:
			continue
		texts.append(c)
		var f: Font = c.get_theme_font("font") if not c is RichTextLabel else c.get_theme_font("normal_font")
		var fs: int = c.get_theme_font_size("font_size") if not c is RichTextLabel else c.get_theme_font_size("normal_font_size")
		var one := t.replace("\n", " ").substr(0, 60)
		if c is Label:
			var l := c as Label
			if l.autowrap_mode == TextServer.AUTOWRAP_OFF and (l.clip_text or l.text_overrun_behavior != TextServer.OVERRUN_NO_TRIMMING):
				var w := 0.0
				for ln in t.split("\n"):
					w = maxf(w, f.get_string_size(ln, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
				if w > r.size.x + 2:
					_flag("CUT", screen, "%s '%s' text %d > box %d" % [_path(c), one, int(w), int(r.size.x)])
					found += 1
			elif l.autowrap_mode != TextServer.AUTOWRAP_OFF:
				var longest := 0.0
				for word in t.split(" ", false):
					longest = maxf(longest, f.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
				if longest > r.size.x + 2 and t.length() > 3:
					_flag("SQUEEZED", screen, "%s '%s' word %d > box %d" % [_path(c), one, int(longest), int(r.size.x)])
					found += 1
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
				_flag("CUT", screen, "%s button '%s' text %d > room %d" % [_path(c), one, int(w), int(r.size.x - mx - icon_w)])
				found += 1
		if not vp.grow(2).encloses(r) and not _clipped_by_parent(c):
			_flag("OFF", screen, "%s '%s' rect %s" % [_path(c), one, str(r)])
			found += 1
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
				_flag("OVERLAP", screen, "'%s' x '%s'" % [_shown(a).replace("\n", " ").substr(0, 40), _shown(b).replace("\n", " ").substr(0, 40)])
				found += 1
	found += _en_misses(screen)
	return found




## A text Loc.t found no translation for that is still English: not already Portuguese / Spanish (a translated text
## going through Loc.t again: the patch notes, a counter built from translated parts), not a number or a name alone.
## Its words are weighed: more words only the English texts use than words only the translations use = English.
var _en_words := {}
var _tr_words := {}


func _words(t: String) -> Array:
	var out_w: Array = []
	for m in RegEx.create_from_string("[A-Za-zÀ-ÿ]{3,}").search_all(t.to_lower()):
		out_w.append(m.get_string())
	return out_w


var _titles := {}


func _english(t: String) -> bool:
	if _titles.is_empty():
		# (the music's titles and the maps' names stay English in every language, by design)
		var mt: Script = load("res://scripts/music_tracks.gd")
		if mt != null:
			for v in mt.get_script_constant_map().get("TRACKS", {}).values():
				_titles[String(v)] = true
		_titles["-"] = true
	if _titles.has(t.trim_prefix("> ").strip_edges()):
		return false
	if _en_words.is_empty():
		var tab := Loc.table(lang)
		var pn: Dictionary = PatchPt.N if lang == "pt" else (PatchEs.N if lang == "es" else {})
		var tr_texts: Array = tab.values()
		for v in pn.values():
			tr_texts.append_array(v)
		for k in tab.keys():
			for w in _words(String(k)):
				_en_words[w] = true
		for v in tr_texts:
			for w in _words(str(v)):
				_tr_words[w] = true
		for w in _en_words.keys():
			if _tr_words.has(w):
				_en_words.erase(w)
				_tr_words.erase(w)
	# each piece by itself ("Pólvora 120/120 shots · ABASTECER ligado"): a piece with English words as many as its
	# translated ones is English left on screen
	for piece in RegEx.create_from_string("\\n|  ·  | · |  ").sub(t, "\n", true).split("\n"):
		var en := 0
		var tr := 0
		for w in _words(piece):
			if _en_words.has(w):
				en += 1
			elif _tr_words.has(w):
				tr += 1
		if en >= 1 and en >= tr:
			return true
	return false


func _loc_clear() -> void:
	Loc.misses.clear()
	Loc.shown.clear()


func _en_misses(screen: String) -> int:
	var n := 0
	if lang != "en":
		for k in Loc.shown:
			if not _english(String(k)):
				continue
			_flag("EN", screen, "'%s'" % String(k).replace("\n", "\\n").substr(0, 90))
			n += 1
	_loc_clear()
	return n


# ------------------------------------------------------------------ the menu crawler

## The pages the crawl starts from: [name, Callable that shows it].
func _seeds() -> Array:
	var s: Array = [["menu", func() -> void: main.show_menu()],
		["device", func() -> void: main.show_device()],
		["ranked_dev", func() -> void: main.show_ranked()]]
	s.append_array(_campaign_seeds())
	return s


func _campaign_seeds() -> Array:
	var s: Array = []
	for sl in Campaign.storylines():
		var id := String(sl["id"])
		s.append(["hub_" + id, func() -> void:
			CampaignMenu.map_open = false
			CampaignMenu.line = id
			main.show_campaign()])
	for skin in ["parchment", "brass", "chart"]:
		var sk: String = skin
		s.append(["warmap_" + skin, func() -> void:
			CampaignMenu.map_skin = sk
			CampaignMenu.map_pick = ""
			CampaignMenu.war_map(main)])
	s.append(["tutorial", func() -> void: main.show_tutorial()])
	return s


## The buttons a hand could click now: visible, enabled, taking the mouse (menus: on the UI layer; popups too).
func _buttons() -> Array:
	var out_b: Array = []
	var stack: Array = [_top_modal()]
	for w in root.get_children():
		if w is Window and (w as Window).visible:
			stack.append(w)
	while not stack.is_empty():
		var n: Node = stack.pop_front()
		if n is CanvasItem and not (n as CanvasItem).visible:
			continue
		if n is BaseButton:
			var b := n as BaseButton
			if b.is_visible_in_tree() and not b.disabled and b.mouse_filter != Control.MOUSE_FILTER_IGNORE and _rect(b).size.x > 2:
				out_b.append(b)
		for ch in n.get_children():
			stack.append(ch)
	return out_b


func _btext(b: BaseButton) -> String:
	var t := ""
	if b is Button:
		t = (b as Button).text
		if b.auto_translate_mode != Node.AUTO_TRANSLATE_MODE_DISABLED:
			t = b.atr(t)
	if t.strip_edges() == "":
		t = b.tooltip_text if b.tooltip_text != "" else "<" + String(b.name) + ">"
	return t.replace("\n", " ").strip_edges().substr(0, 48)


## What a hand can reach now: an open dropdown list's shade, else the topmost full-screen layer that takes the mouse
## and holds buttons (a question box over the page), else the whole UI layer.
func _top_modal() -> Node:
	if is_instance_valid(main._list_shade) and main._list_shade.is_inside_tree() and not main._list_shade.is_queued_for_deletion():
		return main._list_shade
	var vp := root.get_visible_rect()
	var kids: Array = main.ui_layer.get_children()
	kids.reverse()
	for c in kids:
		if not c is Control or not (c as Control).visible or c.is_queued_for_deletion():
			continue
		var cc := c as Control
		if cc == main.menu:
			break
		var r := _rect(cc)
		if cc.mouse_filter == Control.MOUSE_FILTER_STOP and r.get_area() > 0.8 * vp.get_area() and _has_button(cc):
			return cc
	return main.ui_layer


func _has_button(n: Node) -> bool:
	for ch in n.get_children():
		if ch is BaseButton or _has_button(ch):
			return true
	return false


## A button's key: its text, and which one of the buttons with that text it is.
func _keys(bs: Array) -> Array:
	var count := {}
	var ks: Array = []
	for b in bs:
		var t := _btext(b)
		var n: int = count.get(t, 0)
		count[t] = n + 1
		ks.append(t + "#" + str(n))
	return ks


## The words of a page for "is it the same page": the buttons' texts without numbers, values and switches.
func _norm(t: String) -> String:
	t = t.to_upper().split("#")[0]
	t = t.split(":")[0].split("  ")[0]
	var r := RegEx.create_from_string("[0-9%.,+\\-x×]")
	t = r.sub(t, "", true)
	for w in [" ON", " OFF", " LIGADO", " DESLIGADO", " ACTIVADO", " DESACTIVADO", "> ", "✓"]:
		t = t.replace(w, "")
	return t.strip_edges()


func _page_set() -> Dictionary:
	var s := {}
	for b in _buttons():
		s[_norm(_btext(b))] = true
	for c in main.ui_layer.get_children():
		if c.get_script() != null:
			s["@" + String((c.get_script() as Script).resource_path.get_file())] = true
		for cc in c.get_children():
			if cc.get_script() != null:
				s["@" + String((cc.get_script() as Script).resource_path.get_file())] = true
	return s


## Same page? Small pages (a box with two buttons) change a lot when one label changes (COPY -> COPIED!): a lower bar.
func _same(a: Dictionary, b: Dictionary) -> bool:
	return _similar(a, b) >= (SAME_PAGE if mini(a.size(), b.size()) >= 6 else 0.3)


func _similar(a: Dictionary, b: Dictionary) -> float:
	var inter := 0
	for k in a:
		if b.has(k):
			inter += 1
	var uni := a.size() + b.size() - inter
	return 1.0 if uni == 0 else float(inter) / uni


## An id for the page shown now, and whether it is new.
func _page_id(prefix: String, set: Dictionary, route_name: String) -> Array:
	for p in _page_sets:
		if String(p[0]).begins_with(prefix) and _same(p[1], set):
			return [p[0], false]
	var id := prefix + route_name
	_page_sets.append([id, set])
	return [id, true]


## Everything a click could change on screen: every visible text, every switch, the settings file, the page.
func _state_hash() -> int:
	var parts_s: Array = []
	var stack: Array = [main.ui_layer]
	for w in root.get_children():
		if w is Window and (w as Window).visible:
			stack.append(w)
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		for ch in n.get_children():
			stack.append(ch)
		if n is CanvasItem and not (n as CanvasItem).is_visible_in_tree():
			continue
		if n is Label:
			parts_s.append((n as Label).text)
		elif n is Button:
			parts_s.append((n as Button).text + str((n as Button).button_pressed) + str((n as Button).disabled))
		elif n is RichTextLabel:
			parts_s.append((n as RichTextLabel).text.left(200))
		elif n is Range:
			parts_s.append(str((n as Range).value))
		if n is Control:
			parts_s.append(str(int((n as Control).position.x)) + "," + str(int((n as Control).position.y)))
	parts_s.append(FileAccess.get_file_as_string(Settings.PATH) if FileAccess.file_exists(Settings.PATH) else "")
	parts_s.append(str(main.menu.get_instance_id() if is_instance_valid(main.menu) else 0))
	parts_s.append(str(Music.me.current if Music.me and "current" in Music.me else ""))
	return hash("|".join(parts_s))


## The screen, small and grey: what a custom-drawn control (a map, a picture) changed shows here.
func _small_image() -> Image:
	if DisplayServer.get_name() == "headless":
		return null
	var img := root.get_texture().get_image()
	if img == null or img.is_empty():
		return null
	img.resize(96, 54, Image.INTERPOLATE_BILINEAR)
	img.convert(Image.FORMAT_L8)
	return img


func _image_diff(a: Image, b: Image) -> float:
	if a == null or b == null:
		return 0.0
	var da := a.get_data()
	var db := b.get_data()
	var changed := 0
	for i in mini(da.size(), db.size()):
		if absi(int(da[i]) - int(db[i])) > 24:
			changed += 1
	return float(changed) / maxi(1, da.size())


func _skip(t: String) -> bool:
	var u := t.to_upper()
	for w in SKIP_WORDS:
		if u == w or u.begins_with(w + " ") or u.ends_with(" " + w) or u.contains(w + " ") and w.length() > 5:
			return true
	return false


func _hooked(b: BaseButton) -> bool:
	for sig in ["pressed", "toggled", "button_down", "button_up", "gui_input", "item_selected"]:
		if b.has_signal(sig) and not b.get_signal_connection_list(sig).is_empty():
			return true
	return b is OptionButton or b is MenuButton or b is CheckBox or b is CheckButton or b.get_script() != null


## A match (or a lesson, a mission, a replay) under way; the map editor, though it runs a Game, is a page to walk.
func _in_match() -> bool:
	return main.game != null and not main.game.edit_mode


func _leave_match() -> void:
	if main.game != null:
		paused = false
		Engine.time_scale = 1.0
		main._to_menu()
		await _frames(3)


var _lobby0 := {}
var _cm0 := {}
var _progress0 := ""


## The state a page is built from, as the crawl (or the veteran part) started: the skirmish setup, the campaign page's
## picks, the campaign progress (a click on IRONMAN or a mission's choice changes them; every route starts from the same).
func _keep_state() -> void:
	_lobby0 = main.lobby.duplicate(true)
	_cm0 = {"pick": CampaignMenu.pick, "line": CampaignMenu.line, "mode": CampaignMenu.mode, "seat": CampaignMenu.seat,
		"solo_pick": CampaignMenu.solo_pick, "vs_pick": CampaignMenu.vs_pick, "map_open": CampaignMenu.map_open,
		"map_home": CampaignMenu.map_home, "map_skin": CampaignMenu.map_skin, "map_pick": CampaignMenu.map_pick,
		"map_cam": CampaignMenu.map_cam.duplicate(true)}
	_progress0 = FileAccess.get_file_as_string(Campaign.PROGRESS) if FileAccess.file_exists(Campaign.PROGRESS) else ""


func _reset_state() -> void:
	main.lobby = _lobby0.duplicate(true)
	CampaignMenu.pick = _cm0["pick"]
	CampaignMenu.line = _cm0["line"]
	CampaignMenu.mode = _cm0["mode"]
	CampaignMenu.seat = _cm0["seat"]
	CampaignMenu.solo_pick = _cm0["solo_pick"]
	CampaignMenu.vs_pick = _cm0["vs_pick"]
	CampaignMenu.map_open = _cm0["map_open"]
	CampaignMenu.map_home = _cm0["map_home"]
	CampaignMenu.map_skin = _cm0["map_skin"]
	CampaignMenu.map_pick = _cm0["map_pick"]
	CampaignMenu.map_cam = (_cm0["map_cam"] as Dictionary).duplicate(true)
	var now := FileAccess.get_file_as_string(Campaign.PROGRESS) if FileAccess.file_exists(Campaign.PROGRESS) else ""
	if now != _progress0:
		if _progress0 == "":
			DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
		else:
			var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
			f.store_string(_progress0)
			f.close()


## Shows the route's page: the seed's page, then the clicks. False if a click on the way is not there any more.
func _goto(seed: Callable, route: Array) -> bool:
	await _leave_match()
	_close_popups()
	_reset_state()
	seed.call()
	await _frames(3)
	for k in route:
		var bs := _buttons()
		var ks := _keys(bs)
		var i := ks.find(k)
		if i < 0:
			return false
		_emit(bs[i])
		await _frames(3)
		if _in_match():
			return false
	return true


func _close_popups() -> void:
	for w in root.get_children():
		if w is Window and (w as Window).visible and w != root:
			(w as Window).hide()


func _emit(b: BaseButton) -> void:
	if b is OptionButton:
		var ob := b as OptionButton
		if ob.item_count > 1:
			var nxt := (ob.selected + 1) % ob.item_count
			ob.select(nxt)
			ob.item_selected.emit(nxt)
		return
	if b.toggle_mode:
		b.button_pressed = not b.button_pressed
	else:
		b.pressed.emit()


## The nearest scroll list round b: scrolled so b shows.
func _reveal(b: Control) -> void:
	var p := b.get_parent()
	while p != null:
		if p is ScrollContainer:
			(p as ScrollContainer).ensure_control_visible(b)
		if p is CanvasLayer or p is Window:
			break
		p = p.get_parent()


## Esc pressed on the page shown (the phone's back does the same: GameData sends Esc): does it leave the page?
func _esc_works() -> bool:
	var set0 := _page_set()
	var m0: int = main.menu.get_instance_id() if is_instance_valid(main.menu) else 0
	var e := InputEventKey.new()
	e.keycode = KEY_ESCAPE
	e.physical_keycode = KEY_ESCAPE
	e.pressed = true
	Input.parse_input_event(e)
	Input.flush_buffered_events()
	await process_frame
	e = e.duplicate()
	e.pressed = false
	Input.parse_input_event(e)
	Input.flush_buffered_events()
	await _frames(4)
	var m1: int = main.menu.get_instance_id() if is_instance_valid(main.menu) else 0
	var left := _in_match() or m1 != m0 or not _same(set0, _page_set())
	_take_errs()
	return left


## A real click (move, press, release) at the middle of b. Returns [clicked by the hand?, what was under it].
func _hand_click(b: BaseButton) -> Array:
	_reveal(b)
	await _frames(2)
	if not is_instance_valid(b) or not b.is_visible_in_tree():
		return [false, "gone"]
	var r := _rect(b)
	var c := r.get_center()
	var vp := root.get_visible_rect()
	if not vp.has_point(c):
		return [false, "offscreen"]
	var hit := [0]
	var cb := func(_a = null) -> void: hit[0] += 1
	var sigs := ["pressed", "button_down", "toggled"]
	if b is OptionButton:
		sigs.append("item_selected")
	for s in sigs:
		b.connect(s, cb)
	var wp: Vector2 = root.get_final_transform() * c
	var mm := InputEventMouseMotion.new()
	mm.position = wp
	mm.global_position = wp
	Input.parse_input_event(mm)
	Input.flush_buffered_events()
	await _frames(2)
	var hov: Control = root.gui_get_hovered_control()
	var under := ""
	if hov != null and hov != b and not b.is_ancestor_of(hov):
		under = "%s (%s)" % [_path(hov), hov.get_class()]
		if _rect(hov).get_area() > 0.6 * vp.get_area() and not hov is BaseButton:
			under = "box"          # (a box over the whole page, a banner or a question: the page waits for it, by design)
	for down in [true, false]:
		var e := InputEventMouseButton.new()
		e.position = wp
		e.global_position = wp
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = down
		e.button_mask = MOUSE_BUTTON_MASK_LEFT if down else 0
		Input.parse_input_event(e)
		Input.flush_buffered_events()
		await process_frame
	await _frames(2)
	if is_instance_valid(b):
		for s in sigs:
			if b.is_connected(s, cb):
				b.disconnect(s, cb)
	return [hit[0] > 0, under]


func _crawl(prefix: String, seeds: Array) -> void:
	_keep_state()
	var queue: Array = []          # [seed_name, seed callable, route]
	for s in seeds:
		queue.append([s[0], s[1], []])
	while not queue.is_empty() and pages.size() < MAX_PAGES and Time.get_ticks_msec() < _deadline - 60000:
		var item: Array = queue.pop_front()
		var seed_name: String = item[0]
		var seed: Callable = item[1]
		var route: Array = item[2]
		if not await _goto(seed, route):
			print("ROUTE LOST %s %s" % [seed_name, str(route)])
			continue
		_take_errs()
		var pid_new := _page_id(prefix, _page_set(), seed_name + ("/" + "/".join(route.map(func(k: String) -> String: return k.split("#")[0])) if not route.is_empty() else ""))
		var pid: String = pid_new[0]
		if not pid_new[1]:
			continue
		var bs := _buttons()
		var ks := _keys(bs)
		print("== PAGE %s (%d buttons) via %s %s" % [pid, bs.size(), seed_name, str(route)])
		_loc_clear()
		await _frames(2)
		var nflag := _audit(pid)
		var shot := await _snap(pid, nflag > 0)
		pages.append({"id": pid, "seed": seed_name, "route": route, "buttons": ks.size(), "shot": shot})
		# no way back?
		# (the main menu, however reached, and the device page, the first start's own choice, have no way back by design)
		var is_root: bool = (route.is_empty() and seed_name in ["menu", "device"]) or (is_instance_valid(main._menu_grid) and main._menu_grid.is_visible_in_tree())
		var esc_leaves := false
		if not is_root and not _in_match():
			esc_leaves = await _esc_works()
			if not esc_leaves:
				var has_back := false
				for k in ks:
					var u := String(k).split("#")[0].to_upper()
					for w in BACK_WORDS:
						if u == w or u.begins_with(w + " ") or u.begins_with("< ") or u.begins_with("← "):
							has_back = true
				_flag("NOBACK", pid, ("Esc / the phone's back does nothing, though it has a %s button" if has_back else "no BACK button and Esc / the phone's back does nothing") % ("BACK-like" if has_back else ""))
			if not await _goto(seed, route):
				continue
		_cur_page_size = ks.size()       # (a long page's own pages are not walked: a tool's list, the music's songs)
		var n := mini(ks.size(), MAX_PRESSES_PAGE)
		if ks.size() > 60:
			n = 30        # (a long list of the same kind of button: the map picker, the animation viewer's units, the
			              # music player's songs; the first 30 stand for the rest)
			print("   (long page: %d of %d buttons clicked)" % [n, ks.size()])
		for i in n:
			if Time.get_ticks_msec() > _deadline - 60000:
				break
			var key: String = ks[i]
			var label := key.split("#")[0]
			if int(key.split("#")[1]) >= 2:
				continue        # (a third WATCH, EXPORT, a third row's same button: the first two stand for the rest)
			var on_main: bool = is_instance_valid(main._menu_grid) and main._menu_grid.is_visible_in_tree()
			if _skip(label) or (on_main and label.to_upper() in QUIT_WORDS):
				presses.append({"screen": pid, "button": key, "result": "skipped (leaves the program / the browser / wipes saves)", "flags": []})
				continue
			if i > 0 and not await _goto(seed, route):
				print("ROUTE LOST %s %s" % [seed_name, str(route)])
				break
			var cur := _buttons()
			var ck := _keys(cur)
			var at := ck.find(key)
			if at < 0:
				continue
			var b: BaseButton = cur[at]
			await _press_menu_button(prefix, pid, seed_name, seed, route, key, b, queue)
		# stuck: nothing on the page leads anywhere (no page opens, nothing starts) and Esc does nothing
		if not is_root and n > 0:
			var leaves := false
			for pr in presses:
				if pr["screen"] == pid and (String(pr["result"]).begins_with("opens") or String(pr["result"]).begins_with("started") or String(pr["result"]).begins_with("skipped")):
					leaves = true
			if not leaves and not esc_leaves:
				_flag("STUCK", pid, "no button on it leads to another page and Esc does nothing")
		_restore_settings()


func _press_menu_button(prefix: String, pid: String, seed_name: String, seed: Callable, route: Array, key: String, b: BaseButton, queue: Array) -> void:
	var fl: Array = []
	if not _hooked(b):
		fl.append("DEAD")
		_flag("DEAD", pid, "'%s' %s is wired to nothing" % [key, _path(b)])
	var in_list: bool = _top_modal() != main.ui_layer and is_instance_valid(main._list_shade) and _top_modal() == main._list_shade
	var before := _state_hash()
	var img_before := _small_image()
	var set_before := _page_set()
	var menu_before: int = main.menu.get_instance_id() if is_instance_valid(main.menu) else 0
	_take_errs()
	var t0 := Time.get_ticks_msec()
	var hc: Array = await _hand_click(b)
	if not hc[0]:
		if hc[1] == "offscreen":
			fl.append("OFFSCREEN")
			_flag("OFFSCREEN", pid, "'%s' %s: its middle is outside the window" % [key, _path(b)])
		elif hc[1] != "gone" and hc[1] != "box":
			fl.append("COVERED")
			_flag("COVERED", pid, "'%s' %s: a click at its middle lands on %s" % [key, _path(b), hc[1]])
		if is_instance_valid(b) and b.is_visible_in_tree() and not b.disabled:
			_emit(b)          # (pressed the way the code does, to go on)
	await _frames(4)
	var ms := Time.get_ticks_msec() - t0
	var result := "same page"
	var e := _take_errs()
	if Loc.lang != lang or Settings.device != device:
		result = "switches the language / device (put back)"
		_restore_settings()
		await _goto(seed, route)
	elif _in_match():
		var what := "a match"
		if main.game.mission != null:
			what = "mission " + String(main.game.mission.id)
		elif main.game.replay != null:
			what = "a replay"
		result = "started " + what
		# a short look at what it started (once a kind: every mission, one replay, one skirmish)
		if not _match_starts.has(what):
			_match_starts[what] = true
			paused = false
			await _wait(2.0)
			e.append_array(_take_errs())
			var mn := "started_" + what.replace(" ", "_")
			_loc_clear()
			await _wait(0.3)
			var fn := _en_misses(mn)
			await _snap(mn, fn > 0 or not e.is_empty())
		await _leave_match()
		e.append_array(_take_errs())
	else:
		var after := _state_hash()
		var set_after := _page_set()
		var menu_after: int = main.menu.get_instance_id() if is_instance_valid(main.menu) else 0
		if in_list:
			result = "picks an option" if not (is_instance_valid(main._list_shade) and main._list_shade.is_inside_tree()) else "list stays open"
		elif not _same(set_before, set_after) or menu_after != menu_before:
			result = "new page"
			var p2 := _page_id(prefix, set_after, "?")
			var known := false
			for p in _page_sets:
				if p[0] == p2[0] and not p2[1]:
					known = true
			if p2[1]:
				_page_sets.pop_back()          # (named and walked when it comes out of the queue)
			result = "opens " + (String(p2[0]) if known else "a new page")
			if not known and route.size() < MAX_DEPTH and _cur_page_size <= 40:
				var r2 := route.duplicate()
				r2.append(key)
				queue.append([seed_name, seed, r2])
		elif after == before and _image_diff(img_before, _small_image()) < 0.02:
			result = "nothing changed"
			if not fl.has("DEAD") and not fl.has("COVERED"):
				fl.append("NOCHANGE")
				_flag("NOCHANGE", pid, "'%s' %s: no text, switch, setting or page changed" % [key, _path(b) if is_instance_valid(b) else ""])
		else:
			result = "changed this page"
	_close_popups()
	for er in e:
		fl.append("ERROR")
		_flag("ERROR", pid, "'%s': %s" % [key, er])
	if ms > SLOW_MS:
		fl.append("SLOW")
		_flag("SLOW", pid, "'%s' took %d ms" % [key, ms])
	presses.append({"screen": pid, "button": key, "result": result, "flags": fl, "ms": ms})
	print("   PRESS [%s] '%s' -> %s %s (%d ms)" % [pid, key, result, str(fl) if not fl.is_empty() else "", ms])
	_restore_settings()


## Every mission finished (a made-up progress, kept apart from a player's): every hub, room and card opens.
func _veteran_progress() -> void:
	for id in Campaign.mission_ids():
		var m := Campaign.mission(id)
		var sides := Campaign.side_ids(m)
		var s := String(sides[0]) if not sides.is_empty() else "crown"
		Campaign.record(id, "versus", s, s, {})
	CampaignMenu.line = ""


# ------------------------------------------------------------------ the match sweep

const FOE := {"crown": "brood", "clockwork": "crown", "brood": "clockwork"}
var g: Game


func _rich() -> void:
	var p: Dictionary = g.players[0]
	p["gold"] = 100000
	p["res2"] = 100000.0
	p["tension"] = 100000.0
	p["cap"] = 200
	if g.faction_of(0) == "clockwork":
		g.give_batteries(0, 200)


func _live_kind(k: String, fac: String) -> bool:
	var d: Dictionary = Defs.UNITS[k]
	if String(d.get("faction", "")) != fac or d.get("campaign_only", false) or Defs.retired(k):
		return false
	if Defs.cw_roster == false and Defs.CW_KINDS.has(k):
		return false
	if fac == "brood" and not (BroodNew.hatch_list().has(k) or BroodNew.KINDS.has(k) \
			or (Defs.NB["mature"] as Dictionary).values().has(k) or k in ["grub"]):
		return false
	return true


func _hud() -> Node:
	return g.hud


## The card's buttons now (rects on the screen), after the HUD has drawn the selection.
func _card_now() -> Array:
	await _frames(3)
	var hud = _hud()
	var out_c: Array = []
	for bt in hud._card_buttons:
		out_c.append(bt)
	return out_c


func _card_label(bt: Dictionary) -> String:
	var it: Array = bt.get("item", [])
	return (String(it[1]).trim_prefix("> ").trim_prefix("~ ") if it.size() > 1 else "?").replace("\n", " ")


## A point of the HUD's own drawing space (scaled up on phones: Hud.ui_scale) on the screen.
func _hud_pt(p: Vector2) -> Vector2:
	return (_hud() as Control).get_global_transform_with_canvas() * p


## A hand's click on a HUD rect's middle (the HUD's coordinates).
func _hud_click(r: Rect2, btn := MOUSE_BUTTON_LEFT) -> void:
	await _world_click(_hud_pt(r.get_center()), btn)


## A hand's click on the match screen at p (viewport coordinates).
func _world_click(p: Vector2, btn := MOUSE_BUTTON_LEFT) -> void:
	var wp: Vector2 = root.get_final_transform() * p
	var mm := InputEventMouseMotion.new()
	mm.position = wp
	mm.global_position = wp
	Input.parse_input_event(mm)
	Input.flush_buffered_events()
	await process_frame
	for down in [true, false]:
		var e := InputEventMouseButton.new()
		e.position = wp
		e.global_position = wp
		e.button_index = btn
		e.pressed = down
		e.button_mask = (MOUSE_BUTTON_MASK_LEFT if btn == MOUSE_BUTTON_LEFT else MOUSE_BUTTON_MASK_RIGHT) if down else 0
		Input.parse_input_event(e)
		Input.flush_buffered_events()
		await process_frame
	await _frames(2)


func _key(code: Key, shift := false, ctrl := false) -> void:
	for down in [true, false]:
		var e := InputEventKey.new()
		e.keycode = code
		e.physical_keycode = code
		e.pressed = down
		e.shift_pressed = shift
		e.ctrl_pressed = ctrl
		Input.parse_input_event(e)
		Input.flush_buffered_events()
		await process_frame
	await _frames(2)


func _match_state(sel: Array) -> String:
	var hud = _hud()
	var q := 0
	for b in g.buildings:
		if b.team == 0 and not b.dead:
			q += b.queue.size()
	var cards := ",".join(hud._card_buttons.map(func(bt: Dictionary) -> String:
		var it: Array = bt.get("item", [])
		return (str(it[1]) if it.size() > 1 else "") + str(bt.get("enabled", true))))
	var props: Array = []
	for e in sel:
		if not is_instance_valid(e):
			props.append("gone")
			continue
		for pn in ["order", "hold_fire", "stance", "kind", "auto_work", "dead", "mounted", "limbered", "packed", "rooted", "auto_train", "arm_powder", "workers", "rally", "solo_t"]:
			if pn in e:
				props.append(str(e.get(pn)))
	return "%s|%s|%s|%d|%s|%s|%d|%d|%s|%s" % [g.hud.controls.mode, hud.page, str(hud.menu_open), q, cards, str(g.selection.size()),
		int(g.players[0]["gold"]), g.units.size(), hud._msg if hud._msg_t > 0 else "", ",".join(props)]


## The card's rects: over each other, over the minimap / the panel / the top bar, or outside the window.
func _hud_geometry(screen: String, card: Array) -> void:
	var hud = _hud()
	var vp := Rect2(Vector2.ZERO, (hud as Control).size)       # (the HUD's own space)
	for i in card.size():
		var r: Rect2 = card[i]["rect"]
		if not vp.grow(1).encloses(r):
			_flag("HUDOFF", screen, "card button '%s' %s is outside the window %s" % [_card_label(card[i]), str(r), str(vp.size)])
		for j in range(i + 1, card.size()):
			var r2: Rect2 = card[j]["rect"]
			var x := r.intersection(r2)
			if x.size.x > 3 and x.size.y > 3:
				_flag("HUDOVERLAP", screen, "card buttons '%s' and '%s' overlap" % [_card_label(card[i]), _card_label(card[j])])
		for other in [["minimap", hud.mini_rect()], ["top bar", hud.top_rect()]]:
			var x2 := r.intersection(other[1])
			if x2.size.x > 3 and x2.size.y > 3:
				_flag("HUDOVERLAP", screen, "card button '%s' is over the %s" % [_card_label(card[i]), other[0]])


## Selects `ent` (a fresh pick: the card's main page), shows it.
func _select(ents: Array) -> void:
	var hud = _hud()
	if hud.controls.mode != "":
		hud.controls.cancel_mode()
	g.set_selection([])
	await _frames(1)
	ents = ents.filter(func(x) -> bool: return is_instance_valid(x) and not x.dead)
	g.set_selection(ents)
	if not ents.is_empty() and is_instance_valid(ents[0]):
		g.camera.position = ents[0].position if ents[0] is Unit else ents[0].center()
	await _frames(2)


func _cancel() -> void:
	var hud = _hud()
	if hud.controls.mode != "":
		hud.controls.cancel_mode()
	if hud.menu_open:
		hud.toggle_menu(false)
	if hud.paused:
		hud.set_paused(false)
	if g.hud.quick_open:
		g.hud.quick_open = false
	_restore_settings()


## One card button of the selection clicked like a hand; then (if it opened a page of the card) every button there.
func _press_card(screen: String, ents: Array, path: Array, depth := 0) -> void:
	await _select(ents)
	for lab in path:          # the page the button is on: its opening buttons clicked again
		var card0: Array = await _card_now()
		var f := card0.filter(func(bt: Dictionary) -> bool: return _card_label(bt) == lab)
		if f.is_empty():
			return
		await _hud_click(f[0]["rect"])
	var card: Array = await _card_now()
	if depth == 0 or not path.is_empty():
		_hud_geometry(screen + ("/" + "/".join(path) if not path.is_empty() else ""), card)
	for i in card.size():
		if Time.get_ticks_msec() > _deadline - 60000:
			return
		if i > 0:
			await _select(ents)
			for lab in path:
				var c1: Array = await _card_now()
				var f1 := c1.filter(func(bt: Dictionary) -> bool: return _card_label(bt) == lab)
				if f1.is_empty():
					return
				await _hud_click(f1[0]["rect"])
			card = await _card_now()
			if i >= card.size():
				break
		var bt: Dictionary = card[i]
		var lab := _card_label(bt)
		if _card_skip(lab):
			# (it would take the selection away under the sweep's feet; tools/test_content_all.gd presses these)
			presses.append({"screen": screen, "button": lab, "result": "skipped (removes the selection)", "flags": []})
			continue
		var before := _match_state(ents)
		var page_before: String = _hud().page
		_take_errs()
		var t0 := Time.get_ticks_msec()
		await _hud_click(bt["rect"])
		var ms := Time.get_ticks_msec() - t0
		var fl: Array = []
		var hud = _hud()
		var result := "nothing changed"
		var mode: String = hud.controls.mode
		if mode != "":
			result = "mode " + mode
			# a placement started: the ghost moved over the map and cancelled (right click)
			await _world_click(root.get_visible_rect().size * Vector2(0.45, 0.4), MOUSE_BUTTON_RIGHT)
			if hud.controls.mode != "":
				hud.controls.cancel_mode()
		elif hud.page != page_before:
			result = "opens page " + String(hud.page)
			if depth < 1:
				var p2 := path.duplicate()
				p2.append(lab)
				await _press_card(screen, ents, p2, depth + 1)
		elif _match_state(ents) != before:
			result = "acted"
		elif not bt.get("enabled", true):
			result = "refused: " + String(bt.get("why", ""))
		var e := _take_errs()
		for er in e:
			fl.append("ERROR")
			_flag("ERROR", screen, "card '%s': %s" % [lab, er])
		if result == "nothing changed" and bt.get("enabled", true) and not lab.to_upper() in ["STOP", "HOLD"]:
			fl.append("NOCHANGE")
			_flag("NOCHANGE", screen, "card '%s' (enabled): nothing changed" % lab)
		if ms > SLOW_MS:
			fl.append("SLOW")
			_flag("SLOW", screen, "card '%s' took %d ms" % [lab, ms])
		presses.append({"screen": screen, "button": ("/".join(path) + "/" if not path.is_empty() else "") + lab, "result": result, "flags": fl, "ms": ms})
		print("   CARD [%s] '%s' -> %s %s" % [screen, lab, result, str(fl) if not fl.is_empty() else ""])
		_cancel()


func _card_skip(lab: String) -> bool:
	var u := Loc.t(lab).to_upper()
	for w in ["DEMOLISH", "ABANDON", "RECYCLE", "SURRENDER", "DISBAND", "SCRAP", "DELETE", "SACRIFICE"]:
		if lab.to_upper().begins_with(w) or u.begins_with(Loc.t(w).to_upper()):
			return true
	return false


func _match_sweep(fac: String) -> void:
	print("\n==== MATCH %s" % fac)
	await _leave_match()
	main.show_menu()
	await _frames(2)
	_take_errs()
	main.start({"map": "greenhold", "seed": 11, "slots": [
		{"who": "you", "faction": fac, "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "easy", "faction": FOE[fac], "colour": 1, "side": 1, "strategy": "balanced"}]})
	await _frames(3)
	g = main.game
	if g.hud:
		g.hud.countdown = 0.0
	paused = false
	for a in g.ais:
		a.process_mode = Node.PROCESS_MODE_DISABLED
	await _wait(1.0)
	var scr := "match_" + fac
	for er in _take_errs():
		_flag("ERROR", scr, "start: " + er)
	_rich()
	var hall: Building = null
	for b in g.buildings:
		if b.team == 0 and b.kind == g.faction_hall(0) and not b.dead:
			hall = b
	# every building of the faction, standing, near the hall
	if hall != null and fac != "brood":
		for k in Defs.BUILDINGS:
			var d: Dictionary = Defs.BUILDINGS[k]
			if String(d.get("faction", "")) != fac or d.get("campaign_only", false) or Defs.retired(k) or d.get("line", false):
				continue
			if not g.buildings.filter(func(x) -> bool: return x.team == 0 and x.kind == k and not x.dead).is_empty():
				continue
			var c := g.find_spot(0, k, hall, 3, 44)
			if c.x >= 0:
				g._add_building(k, 0, c, true)
				await process_frame
	# every unit of the faction, beside the hall
	var at: Vector2 = hall.center() if hall != null else g.units[0].position
	var n := 0
	for k in Defs.UNITS:
		if not _live_kind(k, fac):
			continue
		var p := g.cell_center(g.nearest_free(g.cell_of(at + Vector2(-260 + (n % 8) * 70, 200 + (n / 8) * 70)), 12))
		var u: Unit = g._add_unit(k, 0, p)
		if Defs.AMMO.has(k):
			u.set_ammo(Defs.ammo_full(k))
		if "wind" in u:
			u.wind = 1.0
		n += 1
	await _wait(1.5)
	for er in _take_errs():
		_flag("ERROR", scr, "setting up: " + er)
	_rich()
	# the screen with the base: its picture and its checks
	if hall != null:
		await _select([hall])
	_loc_clear()
	await _wait(0.4)
	var nf := _en_misses(scr)
	await _snap(scr + "_base", nf > 0)
	pages.append({"id": scr, "seed": "match", "route": [], "buttons": 0, "shot": _shot_done.get((scr + "_base").validate_filename(), "")})
	# every kind selected: its card clicked through
	var kinds := {}
	for b in g.buildings:
		if b.team == 0 and not b.dead and b.built and not kinds.has("b:" + b.kind):
			kinds["b:" + b.kind] = [b]
	for u in g.units:
		if u.team == 0 and not u.dead and not kinds.has("u:" + u.kind):
			kinds["u:" + u.kind] = [u]
	# a mixed selection (several kinds) and every worker
	var ws: Array = g.workers(0)
	if ws.size() > 1:
		kinds["mixed:workers"] = ws
	var army: Array = g.units.filter(func(u) -> bool: return u.team == 0 and not u.dead and not ws.has(u))
	if army.size() > 1:
		kinds["mixed:army"] = army
	for kk in kinds:
		if Time.get_ticks_msec() > _deadline - 60000:
			break
		var ents: Array = kinds[kk].filter(func(x) -> bool: return is_instance_valid(x) and not x.dead)
		if ents.is_empty():
			continue
		_rich()
		var screen := scr + "/" + String(kk)
		print("== CARD %s" % screen)
		_loc_clear()
		await _press_card(screen, ents, [])
		_en_misses(screen)
		if shots_mode == "all" and kk in ["b:" + g.faction_hall(0), "mixed:army"]:
			await _select(ents)
			await _snap(screen.replace("/", "_"))
	await _match_keys(scr)
	await _match_menu(scr)
	# the autosave and CONTINUE
	_take_errs()
	main._autosave()
	await _wait(1.0)
	await _leave_match()
	await _frames(3)
	var cb: Variant = main.menu_buttons.get("continue") if main.game == null else null
	if cb == null or not is_instance_valid(cb):
		var pk := SaveGame.peek()
		_flag("STUCK", "menu", "no CONTINUE on the main menu after leaving a %s match (save found: %s, version %s)" % [fac, str(not pk.is_empty()), str(pk.get("version", "-"))])
	else:
		var hc: Array = await _hand_click(cb)
		if not hc[0]:
			_flag("COVERED", "menu", "CONTINUE: a click at its middle lands on %s" % hc[1])
			_emit(cb)
		await _wait(2.0)
		var ok := main.game != null
		presses.append({"screen": "menu", "button": "CONTINUE (%s)" % fac, "result": "match continued" if ok else "nothing", "flags": [] if ok else ["NOCHANGE"]})
		if not ok:
			_flag("NOCHANGE", "menu", "CONTINUE after a %s match did not bring the match back" % fac)
		await _leave_match()
	for er in _take_errs():
		_flag("ERROR", scr, "save / continue: " + er)


## The keys and the minimap: F1-F9, F10 (pause), Tab, Space, the control groups, the minimap's corners.
func _match_keys(scr: String) -> void:
	var hud = _hud()
	_take_errs()
	var keys := [KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5, KEY_F6, KEY_F7, KEY_F8, KEY_F9, KEY_F10, KEY_F12, KEY_TAB, KEY_SPACE, KEY_BACKSPACE, KEY_PERIOD, KEY_COMMA]
	for k in keys:
		var t0 := Time.get_ticks_msec()
		await _key(k)
		var fl: Array = []
		for er in _take_errs():
			fl.append("ERROR")
			_flag("ERROR", scr + "/keys", "%s: %s" % [OS.get_keycode_string(k), er])
		presses.append({"screen": scr + "/keys", "button": OS.get_keycode_string(k), "result": "pressed", "flags": fl, "ms": Time.get_ticks_msec() - t0})
		_cancel()
		if k == KEY_F10 and hud.paused:
			hud.set_paused(false)
	# control groups: Ctrl+1 on the army, then 1
	var army: Array = g.units.filter(func(u) -> bool: return u.team == 0 and not u.dead)
	if not army.is_empty():
		g.set_selection(army.slice(0, 6))
		await _key(KEY_1, false, true)
		g.set_selection([])
		await _key(KEY_1)
		presses.append({"screen": scr + "/keys", "button": "Ctrl+1, 1", "result": "group %d" % g.selection.size(), "flags": [] if g.selection.size() > 0 else ["NOCHANGE"]})
	var mr: Rect2 = hud.mini_rect()
	for f in [Vector2(0.1, 0.1), Vector2(0.9, 0.9), Vector2(0.5, 0.5)]:
		var cam0: Vector2 = g.camera.position
		await _world_click(_hud_pt(mr.position + mr.size * f))
		presses.append({"screen": scr + "/minimap", "button": "minimap %s" % str(f), "result": "camera moved" if g.camera.position != cam0 else "camera still", "flags": []})
	for er in _take_errs():
		_flag("ERROR", scr + "/minimap", er)


## The in-game menu: each of its buttons; the questions answered NO; Settings over the match and back.
func _match_menu(scr: String) -> void:
	var hud = _hud()
	hud.toggle_menu(true)
	await _frames(3)
	_loc_clear()
	await _wait(0.3)
	_en_misses(scr + "/menu")
	await _snap(scr + "_menu")
	var labels: Array = hud._menu_buttons().map(func(b: Dictionary) -> String: return String(b["label"]))
	for i in labels.size():
		hud.toggle_menu(true)
		await _frames(2)
		var bs: Array = hud._menu_buttons()
		if i >= bs.size():
			break
		var b: Dictionary = bs[i]
		var lab := String(b["label"])
		if b.has("slider"):
			continue
		_take_errs()
		await _hud_click(b["rect"])
		var result := "menu closed" if not hud.menu_open else ("asks: " + String(hud._confirm) if hud._confirm != "" else "menu stays")
		var fl: Array = []
		if hud._confirm != "":
			# the question: NO
			var no: Array = hud._menu_buttons().filter(func(x: Dictionary) -> bool: return String(x["label"]) == "NO")
			if no.is_empty():
				_flag("STUCK", scr + "/menu", "the question after '%s' has no NO" % lab)
			else:
				await _hud_click(no[0]["rect"])
				if hud._confirm != "":
					_flag("NOCHANGE", scr + "/menu", "NO after '%s' did nothing" % lab)
		if main.game == null:
			result = "left the match"
		elif main._match_settings or (not hud.menu_open and main.menu != null and is_instance_valid(main.menu) and main.menu.is_visible_in_tree()):
			result = "opens a page over the match"
			_loc_clear()
			await _wait(0.3)
			_audit(scr + "/menu/" + lab)
			await _snap(scr + "_over_" + lab)
		for er in _take_errs():
			fl.append("ERROR")
			_flag("ERROR", scr + "/menu", "'%s': %s" % [lab, er])
		presses.append({"screen": scr + "/menu", "button": lab, "result": result, "flags": fl})
		print("   MENU [%s] '%s' -> %s" % [scr, lab, result])
		if main.game == null:
			return
		g = main.game
		# a page over the match (SETTINGS): its BACK
		if main._match_settings or (is_instance_valid(main.menu) and main.menu.is_visible_in_tree() and main.game != null and not hud.menu_open):
			if not main.menu_back():
				var bk := _buttons().filter(func(x: BaseButton) -> bool: return x is Button and _norm((x as Button).text) in ["BACK", "VOLTAR", "VOLVER", "BACK TO THE MATCH"])
				if bk.is_empty():
					_flag("STUCK", scr + "/menu/" + lab, "no BACK on the page over the match")
				else:
					_emit(bk[0])
			await _frames(3)
		_cancel()
	hud.toggle_menu(false)
	# pause and resume
	hud.set_paused(true)
	await _frames(3)
	await _snap(scr + "_paused")
	var rb: Array = hud._paused_buttons()
	if not rb.is_empty():
		await _hud_click(rb[0]["rect"])
	presses.append({"screen": scr, "button": "pause, RESUME", "result": "resumed" if not hud.paused else "still paused", "flags": [] if not hud.paused else ["NOCHANGE"]})
	if hud.paused:
		_flag("NOCHANGE", scr, "RESUME on the pause panel did not resume")
		hud.set_paused(false)
