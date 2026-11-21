class_name MissionUi
extends Control
## A campaign mission's screen parts over the HUD: the DIALOGUE BOX (top right, under the top bar: the speaker's
## portrait, name and line, a still when the line has one; lines follow one another by themselves, NEXT and SKIP
## step through them; nothing is paused, alone or online) and the OBJECTIVES panel (top left, under the resources: each
## objective with its box ticked, crossed or open, the time left on a "survive" one; its title folds it away).

var game: Game
var run: MissionRun
var queue: Array = []                # lines waiting
var current: Dictionary = {}
var line_t := 0.0                    # seconds the current line has left
var folded := false
var _box: PanelContainer
var _portrait: StillView.Portrait
var _name: Label
var _text: Label
var _still_holder: Control
var _obj: ObjectivesPanel
var _scale := 1.0
var _pointer: Pointer
## A TUTORIAL lesson (docs/tutorial.md): the teacher's last line stays up until the next step (or NEXT / SKIP), so the
## instruction can be read again while doing it; the lines stay a little longer.
var tutorial := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = UiStyle.theme()
	process_mode = Node.PROCESS_MODE_ALWAYS
	tutorial = bool(run.data.get("tutorial", false))
	_pointer = Pointer.new()
	_pointer.ui = self
	add_child(_pointer)
	_obj = ObjectivesPanel.new()
	_obj.ui = self
	add_child(_obj)
	_build_box()
	run.said.connect(_on_said)
	run.choice_offered.connect(_on_choice)
	run.objectives_changed.connect(func() -> void: _obj.queue_redraw())
	get_viewport().size_changed.connect(_layout)
	_layout()


func _pc() -> bool:
	return Settings.pc()


func _build_box() -> void:
	_box = PanelContainer.new()
	_box.add_theme_stylebox_override("panel", UiStyle.box(Color(0.09, 0.07, 0.05, 0.93), UiStyle.TRIM, 2, 10, 10.0))
	_box.mouse_filter = Control.MOUSE_FILTER_STOP
	_box.visible = false
	add_child(_box)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	_box.add_child(v)
	_still_holder = Control.new()
	_still_holder.visible = false
	v.add_child(_still_holder)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	v.add_child(h)
	_portrait = StillView.Portrait.new()
	_portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	h.add_child(_portrait)
	var tv := VBoxContainer.new()
	tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tv.add_theme_constant_override("separation", 2)
	h.add_child(tv)
	_name = UiStyle.text("", 16, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_LEFT, true)
	_name.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	tv.add_child(_name)
	_text = UiStyle.text("", 16, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	tv.add_child(_text)
	var bv := VBoxContainer.new()
	bv.add_theme_constant_override("separation", 6)
	h.add_child(bv)
	_page = UiStyle.text("", 13, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
	_page.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_page.visible = false
	tv.add_child(_page)
	_box.gui_input.connect(func(e: InputEvent) -> void:
		# (a tap on the box's words: the next page of a long line on a phone held sideways, player-comforts)
		if compact and ((e is InputEventScreenTouch and (e as InputEventScreenTouch).pressed) \
				or (e is InputEventMouseButton and (e as InputEventMouseButton).pressed and (e as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT)):
			next_page()
			_box.accept_event())
	for it in [["NEXT", func() -> void: next_page()], ["SKIP", func() -> void: skip_all()]]:
		var b := Button.new()
		b.text = it[0]
		b.name = "Dialogue_" + String(it[0])
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(it[1])
		bv.add_child(b)


func _layout() -> void:
	var vs := get_viewport_rect().size
	# (the HUD's scale for this screen: asked of Settings, as the HUD itself may not have fitted the new size yet)
	var hud_scale: float = Settings.hud_scale_for(vs) if game and game.hud else 1.0
	_scale = hud_scale
	var was := compact
	compact = Settings.compact_phone(vs)
	if compact and not was and not _fold_chosen:
		folded = true              # (a phone held sideways: the objectives start as one line; a tap opens them)
	var top := 40.0 * hud_scale
	var fs := int((16 if _pc() else 19) * hud_scale)
	var w := minf(vs.x * (0.42 if _pc() else 0.5), 600.0 * hud_scale)
	var ps := 64.0 * hud_scale if _pc() else 76.0 * hud_scale
	var bh := (30 if _pc() else 40) * hud_scale
	if compact:
		# A PHONE HELD SIDEWAYS (player-comforts): a narrower, shorter box (a smaller portrait, 3 lines at a time: a tap
		# or NEXT shows the rest), the buttons still a thumb's size (36 x 1.3 = 47 of the screen's units)
		fs = int(19 * hud_scale)
		w = minf(vs.x * 0.46, 600.0 * hud_scale)
		ps = 50.0 * hud_scale
		bh = 36.0 * hud_scale
	_box.position = Vector2(vs.x - w - 8.0 * hud_scale, top)
	_box.custom_minimum_size = Vector2(w, 0)
	_box.size = Vector2(w, 0)
	_portrait.custom_minimum_size = Vector2(ps, ps)
	_text.custom_minimum_size.x = maxf(120.0, w - ps - (96.0 if compact else 130.0) * hud_scale)      # (a width to wrap at, or the box grows tall)
	_text.max_lines_visible = COMPACT_LINES if compact else -1
	_name.add_theme_font_size_override("font_size", fs)
	_text.add_theme_font_size_override("font_size", fs)
	_page.add_theme_font_size_override("font_size", int(fs * 0.8))
	for b in _box.find_children("Dialogue_*", "Button", true, false):
		(b as Button).add_theme_font_size_override("font_size", int(fs * 0.85))
		(b as Button).custom_minimum_size = Vector2((70 if compact else 80) * hud_scale, bh)
	var sh := (w - 24) * 0.42
	if compact:
		sh = minf(sh, vs.y * 0.22)     # (a still with a line: smaller, the map still seen)
	_still_holder.custom_minimum_size = Vector2(sh / 0.42 if compact else w - 24, sh)
	_obj.position = Vector2(8.0 * hud_scale, top)
	_obj.fs = fs - 1
	_obj.queue_redraw()
	_paginate()


## COMPACT (a phone held sideways): the line's pages of COMPACT_LINES lines; "2/3" in the corner while there are more.
const COMPACT_LINES := 3
var compact := false
var _fold_chosen := false          # the player folded or opened the objectives himself
var _page: Label


## The page shown of a long line on a phone held sideways (Label.lines_skipped), and its "1/2".
func _paginate() -> void:
	if _page == null:
		return
	var n := _text.get_line_count() if compact else 0
	var pages := int(ceil(float(n) / COMPACT_LINES)) if compact else 1
	_page.visible = compact and pages > 1
	if _page.visible:
		_page.text = "%d/%d" % [_text.lines_skipped / COMPACT_LINES + 1, pages]


## More of this line to show (a phone held sideways)?
func _more_pages() -> bool:
	return compact and _text.lines_skipped + COMPACT_LINES < _text.get_line_count()


## NEXT, or a tap on the box: the line's next page on a phone held sideways, else the next line.
func next_page() -> void:
	if _more_pages():
		_text.lines_skipped += COMPACT_LINES
		line_t = maxf(line_t, _page_secs())
		_paginate()
		return
	advance()


## Time to read a page of the line: its share of the whole line's.
func _page_secs() -> float:
	var n := maxi(1, _text.get_line_count())
	return maxf(3.0, _line_secs * float(COMPACT_LINES) / float(n))


var _line_secs := 4.5


func _on_said(ln: Dictionary) -> void:
	if tutorial:
		# (a lesson: lines of a step the player has already done, still waiting their turn, are dropped, and a line of
		# a done step on show gives way after a moment: a quick player read "zoom with the wheel" while the task said
		# "defeat the bandits", four steps behind; playtest 2026-11-21)
		queue = queue.filter(func(q: Dictionary) -> bool: return not _step_done(q))
	queue.append(ln)
	if current.is_empty() or (tutorial and (line_t <= 0.0 or (_step_done(current) and _shown >= 1.5)) and queue.size() == 1):
		advance()           # (a lesson's held line gives way to the next step's first)
	run.talk_busy = true


var _shown := 0.0           # seconds the current line has been on show


## A lesson's line belongs to a step whose task is already done (its id is "<step>_<n>": Campaign.expand_steps).
func _step_done(ln: Dictionary) -> bool:
	var id := String(ln.get("id", ""))
	var cut := id.rfind("_")
	if cut <= 0:
		return false
	return String(run.obj.get("task_" + id.substr(0, cut), "")) == "done"


## The next line now (the current one is done).
func advance() -> void:
	if queue.is_empty():
		current = {}
		_box.visible = false
		return
	current = queue.pop_front()
	_shown = 0.0
	var txt := Loc.t(String(current["text"]))
	line_t = maxf(4.5, 2.0 + txt.length() / 14.0) * (1.3 if tutorial else 1.0)
	_line_secs = line_t
	_text.lines_skipped = 0
	_name.text = Loc.t(String(current["name"]))
	_text.text = txt
	var col := _side_colour(String(current.get("side", "")))
	_name.add_theme_color_override("font_color", col.lightened(0.45))
	_portrait.set_speaker(String(current["name"]), col, String(current.get("portrait", "")))
	for c in _still_holder.get_children():
		c.queue_free()
	var sid := String(current.get("still", ""))
	_still_holder.visible = sid != ""
	if sid != "":
		var sv := StillView.make(run.still(sid), col, false)
		sv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_still_holder.add_child(sv)
	_box.visible = true
	_box.size = Vector2(_box.custom_minimum_size.x, 0)
	_box.reset_size.call_deferred()
	_paginate.call_deferred()
	if compact:
		_fit_first_page.call_deferred()
	var vsec := CampaignVoice.play(self, run.data, String(current.get("id", "")))      # (a recorded line, if there is one)
	if vsec > 0.0:
		line_t = maxf(line_t, vsec + 0.6)
	else:
		Sfx.play_any(["ui/click", "click"], Vector2.INF, -10.0)


## A long line on a phone held sideways: its first page gets its share of the reading time (the rest comes page by page).
func _fit_first_page() -> void:
	if _more_pages():
		line_t = _page_secs()
	_paginate()


## A CHOICE (MissionRun.offer_choice, campaign-m1): a panel in the middle of the top with the question and a button per
## option (its label and what it means); the match goes on meanwhile; nobody answering takes the default in time.
var _choice: PanelContainer = null


func _on_choice(ch: Dictionary) -> void:
	if _choice:
		_choice.queue_free()
	var vs := get_viewport_rect().size
	_choice = PanelContainer.new()
	_choice.name = "Choice_" + String(ch.get("id", ""))
	_choice.add_theme_stylebox_override("panel", UiStyle.box(Color(0.09, 0.07, 0.05, 0.95), UiStyle.TRIM, 2, 10, 14.0))
	_choice.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_choice)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_choice.add_child(v)
	var fs := int((17 if _pc() else 20) * _scale)
	var w := minf(vs.x * 0.56, 720.0 * _scale)
	var t := UiStyle.text(Loc.t(String(ch.get("title", ""))), fs + 3, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_CENTER, true)
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.custom_minimum_size.x = w
	v.add_child(t)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	v.add_child(row)
	for o in ch.get("options", []):
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(col)
		var b := Button.new()
		b.text = Loc.t(String(o.get("label", o.get("id", ""))))
		b.name = "Choose_" + String(o.get("id", ""))
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(0, (44 if _pc() else 56) * _scale)
		b.add_theme_font_size_override("font_size", fs)
		var cid := String(ch.get("id", ""))
		var oid := String(o.get("id", ""))
		b.pressed.connect(func() -> void: pick_choice(cid, oid))
		col.add_child(b)
		var ab := UiStyle.text(Loc.t(String(o.get("about", ""))), fs - 3, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
		ab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ab.custom_minimum_size.x = w * 0.45
		col.add_child(ab)
	_choice.reset_size()
	_choice.position = Vector2((vs.x - w) * 0.5 - 14.0, vs.y * 0.30)


## The player's answer (a button, or a test).
func pick_choice(cid: String, oid: String) -> void:
	run.choose(cid, oid)
	if _choice:
		_choice.queue_free()
		_choice = null


## SKIP: this line and every one waiting.
func skip_all() -> void:
	queue.clear()
	advance()


func _process(delta: float) -> void:
	if is_instance_valid(game) and game.over and _box.visible:
		skip_all()             # (the mission's end screen takes over)
	# the match MENU / SETTINGS open over the match: the dialogue, the objectives and a choice step aside (they were drawn
	# over the PAUSED panel and its music list, and took its clicks: playtest 2026-11-21)
	var over := is_instance_valid(game) and game.hud != null and (bool(game.hud.get("menu_open")) or bool(game.hud.get("settings_open")))
	if visible == over:
		visible = not over
	run.talk_busy = not queue.is_empty() or (not current.is_empty() and line_t > 0.0)
	if _choice and run.choice_open.is_empty():
		_choice.queue_free()          # (answered by the default in time, or the match ended)
		_choice = null
	if current.is_empty() or get_tree().paused and not (game and game.net):
		return
	if over and not (game and game.net):
		return             # (a line is not used up unseen behind the menu)
	line_t -= delta
	_shown += delta
	if line_t <= 0.0 and _more_pages():
		next_page()         # (a phone held sideways: the line's next page)
	elif line_t <= 0.0 and not (tutorial and queue.is_empty()):
		advance()           # (a lesson's last line stays: it says what to do now)
	elif tutorial and _shown >= 1.5 and not queue.is_empty() and _step_done(current):
		advance()           # (a done step's line gives way to the next step's)


## A side's colour: its first team's colour in this match.
func _side_colour(side_id: String) -> Color:
	for t in run.team_ids.size():
		if run.side_of_team(t) == side_id:
			return game.team_colour(t)
	return Color(0.6, 0.55, 0.45)


## The OBJECTIVES panel (drawn by hand: a box per objective).
class ObjectivesPanel extends Control:
	var ui: MissionUi
	var fs := 15
	var _rows_h := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		process_mode = Node.PROCESS_MODE_ALWAYS

	func _process(_d: float) -> void:
		if Engine.get_process_frames() % 15 == 0:
			queue_redraw()          # (the time left on a survive objective)

	func _gui_input(e: InputEvent) -> void:
		if (e is InputEventMouseButton and (e as InputEventMouseButton).pressed and (e as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT) \
				or (e is InputEventScreenTouch and (e as InputEventScreenTouch).pressed):
			if e.position.y < fs + 14 or (ui.compact and ui.folded):
				ui.folded = not ui.folded
				ui._fold_chosen = true
				queue_redraw()
			accept_event()

	func _draw() -> void:
		var run := ui.run
		var list := run.objectives_for(run.my_side())
		# a lesson's TASKS (docs/tutorial.md): the one being done and the last one ticked, not the whole list
		var tasks := list.filter(func(o: Dictionary) -> bool: return bool(o.get("task", false)))
		if not tasks.is_empty():
			var done := tasks.filter(func(o: Dictionary) -> bool: return o["state"] == "done")
			var keep: Array = tasks.filter(func(o: Dictionary) -> bool: return o["state"] == "active")
			if not done.is_empty():
				keep.push_front(done[-1])
			list = list.filter(func(o: Dictionary) -> bool: return not bool(o.get("task", false)) or keep.has(o))
		var font := UiStyle.body_font()
		var bold := UiStyle.bold_font()
		var w := clampf(ui.get_viewport_rect().size.x * 0.30, 260.0, 440.0 * ui._scale)
		if ui.compact:
			w = clampf(ui.get_viewport_rect().size.x * (0.40 if ui.folded else 0.34), 260.0, 520.0 * ui._scale)
		var rh := fs + 10.0
		var lines: Array = []          # [objective, wrapped lines]
		var total := fs + 14.0
		if not ui.folded:
			for o in list:
				var txt := run.objective_text(o)      # (the numbers put in: counters, a countdown)
				if not bool(o.get("primary", true)) and not bool(o.get("task", false)):
					txt = Loc.t("(optional)") + " " + txt
				if String(o.get("kind", "")) == "survive" and o["state"] == "active":
					var left := maxi(0, int(ceil(float(o.get("time", 0)) - run.game.clock)))
					txt += "  %d:%02d" % [left / 60, left % 60]
				var wrapped := _wrap(font, txt, w - fs - 26)
				lines.append([o, wrapped])
				total += wrapped.size() * (fs + 4) + 6
		size = Vector2(w, total + 6)
		if ui.folded and ui.compact:
			size.y = maxf(size.y, 46.0)      # (a thumb's height to tap it open)
		UiStyle.draw_panel(self, Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0), 0.85)
		var head := Loc.t("LESSON" if ui.tutorial else "OBJECTIVES") + ("  +" if ui.folded else "  -")
		draw_string(bold, Vector2(10, fs + 6), head, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiStyle.TRIM)
		if ui.folded and ui.compact:
			# (folded on a phone held sideways: the first objective still open on the same line, cut to fit; a tap on the
			# line opens the list: player-comforts)
			var now: Array = list.filter(func(o: Dictionary) -> bool: return o["state"] == "active" and bool(o.get("primary", true)))
			if now.is_empty():
				now = list.filter(func(o: Dictionary) -> bool: return o["state"] == "active")
			var x0 := 10.0 + bold.get_string_size(head, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 10.0
			var room := w - x0 - 10.0
			if not now.is_empty() and room > 40.0:
				var t1 := run.objective_text(now[0])
				var shown := t1
				while shown.length() > 4 and font.get_string_size(shown + "...", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > room:
					shown = shown.substr(0, shown.length() - 2)
				if shown != t1:
					shown = shown.strip_edges() + "..."
				draw_string(font, Vector2(x0, fs + 6), shown, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiStyle.TEXT)
		var y := fs + 16.0
		for row in lines:
			var o: Dictionary = row[0]
			var st := String(o["state"])
			var col := UiStyle.TEXT if st == "active" else (UiStyle.GOOD if st == "done" else UiStyle.BAD)
			if not bool(o.get("primary", true)) and st == "active" and not bool(o.get("task", false)):
				col = UiStyle.MUTED
			elif bool(o.get("task", false)) and st == "active":
				col = UiStyle.TRIM           # (the lesson's task now: bright)
			var bx := Rect2(10, y + 3, fs - 2, fs - 2)
			draw_rect(bx, Color(0, 0, 0, 0.4))
			draw_rect(bx, col, false, 2.0)
			if st == "done":
				draw_polyline(PackedVector2Array([bx.position + Vector2(2, bx.size.y * 0.5), bx.position + Vector2(bx.size.x * 0.4, bx.size.y - 2),
					bx.position + Vector2(bx.size.x + 2, -2)]), UiStyle.GOOD, 3.0)
			elif st == "failed":
				draw_line(bx.position + Vector2(2, 2), bx.end - Vector2(2, 2), UiStyle.BAD, 3.0)
				draw_line(Vector2(bx.end.x - 2, bx.position.y + 2), Vector2(bx.position.x + 2, bx.end.y - 2), UiStyle.BAD, 3.0)
			for ln in row[1]:
				draw_string(font, Vector2(fs + 18, y + fs), ln, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
				y += fs + 4
			y += 6
		_rows_h = y

	func _wrap(font: Font, txt: String, w: float) -> Array:
		var out: Array = []
		var cur := ""
		for word in txt.split(" "):
			var t := word if cur == "" else cur + " " + word
			if font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > w and cur != "":
				out.append(cur)
				cur = word
			else:
				cur = t
		if cur != "":
			out.append(cur)
		return out


## The TUTORIAL's POINTER (docs/tutorial.md; drawn in code, docs/art_style_inconsistency.md): where the teacher points
## (MissionRun.pointer): a gold ring pulsing on the ground under an area, a tagged thing or the player's first of a
## kind, with an arrow bobbing over it (at the screen's edge, pointing the way, when it is out of view); or a frame
## round a part of the HUD (the minimap, the command card, the group bar, the top bar) with an arrow at it.
class Pointer extends Control:
	var ui: MissionUi
	const GOLD := Color(1.0, 0.84, 0.3)

	func _ready() -> void:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		process_mode = Node.PROCESS_MODE_ALWAYS

	func _process(_d: float) -> void:
		queue_redraw()

	## The pointer's target on this screen: [kind "world" / "ui" / "", a point or a Rect2].
	func target() -> Array:
		var run := ui.run
		var p: Dictionary = run.pointer
		var g := ui.game
		if p.is_empty() or not is_instance_valid(g) or g.over:
			return ["", null]
		if p.has("ui"):
			var hud: Control = g.hud
			if hud == null:
				return ["", null]
			var rects: Dictionary = hud._layout()
			var key: String = {"minimap": "mini", "card": "card", "hotbar": "hotbar", "groups": "hotbar", "objectives": ""}.get(String(p["ui"]), "")
			var r := Rect2()
			if String(p["ui"]) == "objectives":
				r = Rect2(ui._obj.position, ui._obj.size)
				return ["ui", r]
			if String(p["ui"]) == "top":
				r = Rect2(0, 0, hud.size.x, 40)
			elif p.has("icon") and _card_button(hud, String(p["icon"])).size.x > 0.0:
				r = _card_button(hud, String(p["icon"]))      # (one button of the card: its icon, e.g. "ab_canister")
			elif rects.has(key):
				r = rects[key]
			else:
				return ["", null]
			var xf: Transform2D = hud.get_global_transform()
			return ["ui", Rect2(xf * r.position, xf.basis_xform(r.size))]
		var w := Vector2.INF
		if p.has("area"):
			w = run.area_rect(String(p["area"])).get_center()
		elif p.has("tag"):
			for e in run.tagged(String(p["tag"])):
				w = e.position if e is Unit else e.center()
				break
		elif p.has("kind"):
			for e in g.units + g.buildings:
				if e.team == g.human and not e.dead and e.kind == String(p["kind"]):
					w = e.position if e is Unit else e.center()
					break
		if not w.is_finite():
			return ["", null]
		return ["world", get_viewport().get_canvas_transform() * w]

	## The rect of the command card's button with this icon ({} none on the card now).
	func _card_button(hud: Control, icon: String) -> Rect2:
		for b in hud.get("_card_buttons"):
			var it: Variant = b.get("item", [])
			if it is Array and not (it as Array).is_empty() and String(it[0]) == icon:
				return b["rect"]
		return Rect2()

	func _draw() -> void:
		var tg := target()
		if tg[0] == "":
			return
		var t := Time.get_ticks_msec() / 1000.0
		var pulse := 0.5 + 0.5 * sin(t * 5.0)
		var s := ui._scale
		var vs := get_viewport_rect().size
		if tg[0] == "ui":
			var r: Rect2 = (tg[1] as Rect2).grow(4.0 + 4.0 * pulse)
			draw_rect(r, Color(GOLD, 0.12 + 0.1 * pulse))
			draw_rect(r, Color(0, 0, 0, 0.6), false, 7.0 * s)
			draw_rect(r, GOLD, false, 4.0 * s)
			# the arrow points at the frame from the screen's middle side
			var c := r.get_center()
			var dir := (c - vs * 0.5).normalized()
			if dir == Vector2.ZERO:
				dir = Vector2.DOWN
			var tip := c - dir * (minf(r.size.x, r.size.y) * 0.5 + 10.0 + 8.0 * pulse)
			if not r.has_point(tip):
				tip = _edge_of(r, -dir)
			_arrow(tip - dir * (8.0 * pulse), dir, s)
			return
		var p: Vector2 = tg[1]
		var view := _view_rect(vs)
		var inside := view.grow(-24.0 * s).has_point(p)
		if inside:
			var rad := (26.0 + 10.0 * pulse) * s
			_ring(p, rad, Color(0, 0, 0, 0.55), 7.0 * s)
			_ring(p, rad, GOLD, 4.0 * s)
			_ring(p, rad * 0.55, Color(GOLD, 0.5), 2.0 * s)
			_arrow(p - Vector2(0, rad + (10.0 + 12.0 * pulse) * s), Vector2.DOWN, s)
		else:
			var c := view.get_center()
			var dir := (p - c).normalized()
			var box := view.grow(-56.0 * s)
			var tip := _edge_of(box, dir, c)
			_arrow(tip + dir * (6.0 * pulse * s), dir, s)

	## The part of the screen where the map is seen: under the top bar, above the HUD's bottom row (the group bar,
	## the command card, the minimap). A spot behind the HUD counts as out of view: the arrow at the edge shows the way.
	func _view_rect(vs: Vector2) -> Rect2:
		var top := 44.0 * ui._scale
		var bottom := vs.y
		var hud: Control = ui.game.hud if is_instance_valid(ui.game) else null
		if hud != null:
			var rects: Dictionary = hud._layout()
			var xf: Transform2D = hud.get_global_transform()
			for k in ["hotbar", "card", "mini"]:
				if rects.has(k):
					var r: Rect2 = rects[k]
					var y: float = (xf * r.position).y
					if y > vs.y * 0.45:
						bottom = minf(bottom, y)
		return Rect2(0, top, vs.x, maxf(80.0, bottom - top))

	## Where a ray from the rect's middle (or `from`) along `dir` leaves it.
	func _edge_of(r: Rect2, dir: Vector2, from := Vector2.INF) -> Vector2:
		var c := r.get_center() if not from.is_finite() else from
		var tx := INF
		var ty := INF
		if absf(dir.x) > 0.001:
			tx = ((r.end.x if dir.x > 0 else r.position.x) - c.x) / dir.x
		if absf(dir.y) > 0.001:
			ty = ((r.end.y if dir.y > 0 else r.position.y) - c.y) / dir.y
		return c + dir * minf(tx, ty)

	func _ring(c: Vector2, rad: float, col: Color, w: float) -> void:
		var pts := PackedVector2Array()
		for i in 33:
			var a := TAU * i / 32.0
			pts.append(c + Vector2(cos(a) * rad, sin(a) * rad * 0.55))
		draw_polyline(pts, col, w, true)

	## A fat arrow whose tip is at `tip`, pointing along `dir`.
	func _arrow(tip: Vector2, dir: Vector2, s: float) -> void:
		var n := Vector2(-dir.y, dir.x)
		var L := 46.0 * s
		var hw := 20.0 * s
		var sw := 8.0 * s
		var base := tip - dir * L * 0.5
		var pts := PackedVector2Array([tip, base + n * hw, base + n * sw, tip - dir * L + n * sw, tip - dir * L - n * sw, base - n * sw, base - n * hw])
		draw_colored_polygon(pts, GOLD)
		var o := pts.duplicate()
		o.append(tip)
		draw_polyline(o, Color(0.1, 0.07, 0.03, 0.95), 3.0 * s, true)
