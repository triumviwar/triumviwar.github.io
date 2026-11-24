class_name MultiplayerMenu
extends Control
## The ONLINE page of the main menu: host a game (you get a short room code), or join a friend's by
## code. Then the waiting room: slots, map and mode (host), your faction (guest), START (host).
## The logic is NetLobby; this only shows it. Needs the relay address (SETTINGS, tools/relay/README.md).

const FACS := ["crown", "brood", "clockwork", "random"]      # (as the skirmish lists them)

var main: Node                 # Main (its _button / _page helpers and start())
var code_edit: LineEdit
var _box: VBoxContainer
var _ping_lbl: Label


func build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var m := MarginContainer.new()
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		m.add_theme_constant_override("margin_" + side, 30)
	for side in ["top", "bottom"]:
		m.add_theme_constant_override("margin_" + side, 16)
	add_child(m)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 10)
	m.add_child(_box)
	_draw()


func _lobby() -> NetLobby:
	return main.net_lobby


func _draw() -> void:
	for c in _box.get_children():
		c.queue_free()
	if _lobby() == null:
		_box.add_child(UiStyle.heading("ONLINE", 42, UiStyle.TRIM))
		_draw_entry()
	else:
		_draw_room()


func _relay_set() -> bool:
	return not Settings.relay_url.contains("YOURNAME") and Settings.relay_url.strip_edges() != ""


func _draw_entry() -> void:
	var cc := CenterContainer.new()
	cc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_box.add_child(cc)
	var pn := PanelContainer.new()
	pn.custom_minimum_size.x = 700
	cc.add_child(pn)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	pn.add_child(v)
	var note := UiStyle.text("Play a friend over the internet: web and Android can play together. One of you hosts and tells the other the room code. The host's device runs the match, so the host has no delay; the guest feels the internet's delay.", 17, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(note)
	var rrow := HBoxContainer.new()
	rrow.add_theme_constant_override("separation", 10)
	var rl := UiStyle.text("RELAY ADDRESS", 18, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT, true)
	rrow.add_child(rl)
	var re := LineEdit.new()
	re.text = Settings.relay_url
	re.placeholder_text = "wss://pocketrts-relay.salgarellius-rts.workers.dev"
	re.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	re.custom_minimum_size = Vector2(0, 52)
	re.text_changed.connect(func(t: String) -> void:
		Settings.relay_url = t.strip_edges()
		Settings.save_all())
	UiStyle.touch_text(re, "RELAY ADDRESS")
	rrow.add_child(re)
	v.add_child(rrow)
	if not _relay_set():
		var w := UiStyle.text("Set the relay address first (the one `wrangler deploy` printed, see tools/relay/README.md).", 16, UiStyle.BAD, HORIZONTAL_ALIGNMENT_LEFT)
		w.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(w)
	var host: Button = main._button("HOST A GAME", func() -> void:
		var l := NetLobby.new()
		main.add_child(l)
		main.net_lobby = l
		l.changed.connect(_on_changed)
		l.failed.connect(_on_failed)
		l.host(Settings.relay_url, NetLink.new_code())
		_draw())
	UiStyle.primary(host)
	host.custom_minimum_size = Vector2(0, 64)
	host.disabled = not _relay_set()
	v.add_child(host)
	var jrow := HBoxContainer.new()
	jrow.add_theme_constant_override("separation", 10)
	code_edit = LineEdit.new()
	code_edit.placeholder_text = "ROOM CODE"
	code_edit.max_length = 12
	code_edit.custom_minimum_size = Vector2(240, 64)
	code_edit.add_theme_font_size_override("font_size", 30)
	code_edit.text_changed.connect(func(t: String) -> void:
		var up := t.to_upper()
		if up != t:
			code_edit.text = up
			code_edit.caret_column = up.length())
	UiStyle.touch_text(code_edit, "ROOM CODE")
	jrow.add_child(code_edit)
	# (JOIN or WATCH with no code, or one too short, did nothing at all: say what is missing, playtest 2026-11-21)
	var code_hint := UiStyle.text("", 16, UiStyle.BAD, HORIZONTAL_ALIGNMENT_LEFT)
	code_hint.visible = false
	var need_code := func() -> bool:
		if code_edit.text.strip_edges().length() >= 3:
			return true
		code_hint.text = Loc.t("Type the room code your friend gave you.")
		code_hint.visible = true
		return false
	var join: Button = main._button("JOIN", func() -> void:
		var c := code_edit.text.strip_edges()
		if not need_code.call():
			return
		var l := NetLobby.new()
		main.add_child(l)
		main.net_lobby = l
		l.changed.connect(_on_changed)
		l.failed.connect(_on_failed)
		l.start_now.connect(func(cfg: Dictionary) -> void:
			main.start(cfg))
		l.join(Settings.relay_url, c)
		_draw())
	join.custom_minimum_size = Vector2(200, 64)
	join.disabled = not _relay_set()
	jrow.add_child(join)
	# WATCH: join as a spectator from the start (a full room, or a match under way, seats one anyway)
	var watch: Button = main._button("WATCH", func() -> void:
		var c := code_edit.text.strip_edges()
		if not need_code.call():
			return
		var l := NetLobby.new()
		main.add_child(l)
		main.net_lobby = l
		l.want_spec = true
		l.changed.connect(_on_changed)
		l.failed.connect(_on_failed)
		l.start_now.connect(func(cfg: Dictionary) -> void:
			main.start(cfg))
		l.join(Settings.relay_url, c)
		_draw())
	watch.custom_minimum_size = Vector2(160, 64)
	watch.tooltip_text = Loc.t("Join as a SPECTATOR: watch every side, give no orders. Also joins a match already under way.")
	watch.disabled = not _relay_set()
	jrow.add_child(watch)
	v.add_child(jrow)
	v.add_child(code_hint)
	if Identity.available():
		# RANKED (docs/online_ranked.md): on our servers, Steam players only (or a test server's DEV sign-in)
		var rk: Button = main._button("RANKED", func() -> void: main.show_ranked())
		rk.custom_minimum_size = Vector2(0, 60)
		v.add_child(rk)
	var back: Button = main._button("BACK", func() -> void: main.show_menu())
	main._set_back(back)
	back.custom_minimum_size = Vector2(240, 58)
	_box.add_child(back)


func _on_changed() -> void:
	if is_inside_tree():
		_draw()


func _on_pinged() -> void:
	var l := _lobby()
	if l and is_instance_valid(_ping_lbl) and _ping_lbl.is_inside_tree():
		_ping_lbl.text = l.ping_text()
		_ping_lbl.add_theme_color_override("font_color", UiStyle.MUTED if l.ping_ms < 120 else (Color(1, 0.85, 0.3) if l.ping_ms < 250 else UiStyle.BAD))


func _on_failed(_why: String) -> void:
	if is_inside_tree():
		_draw()


func _draw_room() -> void:
	var l := _lobby()
	if not l.campaign.is_empty():
		_draw_campaign_room(l)
		return
	var host := l.is_host
	# Title, room code and the quick set-ups (the skirmish's top bar)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	_box.add_child(top)
	var t := UiStyle.heading(Loc.t("ROOM") + "  " + l.code, 38, Color(1, 0.9, 0.55))
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	top.add_child(t)
	# (the button is passed in: a lambda takes a copy of `cp` when it is made, still null then, so pressing COPY
	# stopped with a SCRIPT ERROR before it could say COPIED, playtest 2026-11-21)
	var cp: Button = main._button("COPY", func() -> void: pass)
	cp.pressed.connect(func() -> void:
		DisplayServer.clipboard_set(l.code)
		cp.text = Loc.t("COPIED"))
	cp.custom_minimum_size = Vector2(130, 44)
	cp.add_theme_font_size_override("font_size", 17)
	top.add_child(cp)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(gap)
	for preset in [["1v1", "1v1"], ["coop", "CO-OP"]]:
		var pm: String = preset[0]
		var b: Button = main._button(String(preset[1]), func() -> void:
			l.set_mode(pm))
		b.custom_minimum_size = Vector2(84, 44)
		b.add_theme_font_size_override("font_size", 17)
		b.disabled = not host
		if l.mode == pm:
			UiStyle.chosen(b)
		top.add_child(b)
	if not l.tour.is_empty():
		# (a room made from a tournament's bracket, docs/tournament.md: its map and factions are the bracket's)
		var tn := UiStyle.text(Loc.t("TOURNAMENT MATCH: the map and the factions come from the bracket; the result goes to the organiser when the game ends."), 16, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_LEFT)
		tn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_box.add_child(tn)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_box.add_child(body)
	# Players
	var pp := PanelContainer.new()
	pp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(pp)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 8)
	pp.add_child(pv)
	var hdr := HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 8)
	for col in [["PLAYER", 170], ["FACTION", 190], ["COLOUR", 110], ["PLAN", 150], ["TEAM", 80]]:
		var hl := UiStyle.text(col[0], 14, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER, true)
		hl.custom_minimum_size.x = col[1]
		hl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hl.size_flags_stretch_ratio = col[1] / 100.0
		hdr.add_child(hl)
	pv.add_child(hdr)
	var rows_scroll := ScrollContainer.new()
	rows_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rows_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pv.add_child(rows_scroll)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows_scroll.add_child(rows)
	for i in l.slots.size():
		rows.add_child(_slot_row(l, i))
	# the SPECTATORS, in a group of their own below the players (they don't take a player's place)
	_spec_rows(l, rows)
	var st := UiStyle.text(l.status, 15, UiStyle.BAD if l.refused != "" or not l.online else UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	st.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pv.add_child(st)
	# the round trip to the other player, kept up to date without redrawing the page (NetLobby.pinged)
	var pg := UiStyle.text(l.ping_text(), 15, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	pv.add_child(pg)
	if not l.pinged.is_connected(_on_pinged):
		l.pinged.connect(_on_pinged)
	_ping_lbl = pg
	var hint := "Same TEAM number = allies.  The host sets the teams, the computer's level and plan, and the map; everyone picks their own faction and colour." if host else "Same TEAM number = allies.  You pick your own faction and colour; the host sets the teams and the map."
	if not host and l.spectating:
		hint = "You are a SPECTATOR: you will see every side and give no orders. Pick a faction under SPECTATORS to take a free seat."
	elif not host:
		hint = Loc.t(hint) + "  " + Loc.t("SPECTATOR in your FACTION list: watch instead of playing.")
	var note := UiStyle.text(hint, 15, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pv.add_child(note)
	# Map
	var mp := PanelContainer.new()
	mp.custom_minimum_size.x = 300
	body.add_child(mp)
	var mv := VBoxContainer.new()
	mv.add_theme_constant_override("separation", 8)
	mp.add_child(mv)
	mv.add_child(UiStyle.text("MAP", 14, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER, true))
	# the random pools, then every map by name that holds everyone in the room
	var ids: Array = []
	for p in MapGen.POOLS:
		ids.append(p[0])
	ids += MapGen.all_ids()
	ids = ids.filter(func(id) -> bool: return l.map_fits(id))
	if not ids.has(l.map):
		ids.append(l.map)
	var cur: int = ids.find(l.map)
	var mrow := HBoxContainer.new()
	mrow.add_theme_constant_override("separation", 6)
	mv.add_child(mrow)
	var prev: Button = main._button("<", func() -> void: l.set_map(ids[(cur - 1 + ids.size()) % ids.size()]))
	prev.custom_minimum_size = Vector2(46, 46)
	prev.disabled = not host
	mrow.add_child(prev)
	var mid: String = l.map
	var mname := MapGen.label(mid) if MapGen.is_pool(mid) else MapGen.display_name(mid)
	var map_opts: Array = []
	for mi in ids:
		map_opts.append([MapGen.label(mi), mi, false])
	var ml: Button = main._dropdown(mname.to_upper(), 160, map_opts, func(v) -> void: l.set_map(String(v)), 470.0, MapGen.label(mid), _nothing)
	ml.add_theme_font_size_override("font_size", 18)
	ml.disabled = not host
	mrow.add_child(ml)
	var nxt: Button = main._button(">", func() -> void: l.set_map(ids[(cur + 1) % ids.size()]))
	nxt.custom_minimum_size = Vector2(46, 46)
	nxt.disabled = not host
	mrow.add_child(nxt)
	var prv: Control = main.make_map_preview(mid, l.slots)
	prv.custom_minimum_size = Vector2(270, 190)
	prv.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mv.add_child(prv)
	var dl := UiStyle.text(_map_desc(mid, l.slots.size()), 15, UiStyle.MUTED)
	dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mv.add_child(dl)
	# the same delay for both players (the host's choice): the host's own orders wait as long as the friend's take
	var sd: Button = main._button("SAME DELAY FOR BOTH PLAYERS: ON" if l.same_delay else "SAME DELAY FOR BOTH PLAYERS: OFF", func() -> void: l.set_same_delay(not l.same_delay))
	sd.custom_minimum_size = Vector2(0, 46)
	sd.add_theme_font_size_override("font_size", 16)
	sd.disabled = not host
	sd.add_theme_color_override("font_disabled_color", UiStyle.TEXT)
	if l.same_delay:
		UiStyle.chosen(sd)
	mv.add_child(sd)
	# spectators may talk to the players? (the host's choice, off: a spectator sees every side, its words could help one)
	var tk: Button = main._button("SPECTATORS TALK TO PLAYERS: ON" if l.spec_talk else "SPECTATORS TALK TO PLAYERS: OFF", func() -> void: l.set_spec_talk(not l.spec_talk))
	tk.custom_minimum_size = Vector2(0, 40)
	tk.add_theme_font_size_override("font_size", 14)
	tk.disabled = not host
	tk.add_theme_color_override("font_disabled_color", UiStyle.TEXT)
	tk.tooltip_text = Loc.t("Off: spectators chat among themselves only. They see every side, so their words could help a player.")
	if l.spec_talk:
		UiStyle.chosen(tk)
	mv.add_child(tk)
	var sdn := UiStyle.text("On: the host's own orders wait as long as the friend's take to arrive over the internet, so neither side reacts faster.", 13, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	sdn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mv.add_child(sdn)
	# Bottom row
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_box.add_child(row)
	var back: Button = main._button("LEAVE", func() -> void:
		l.dispose()
		main.net_lobby = null
		_draw())
	back.custom_minimum_size = Vector2(200, 60)
	row.add_child(back)
	var problem := l.problem() if host else ""
	var go: Button = main._button("START", func() -> void:
		Sfx.play_any(["ui/start_match"])
		main.start(l.make_cfg()))
	go.custom_minimum_size = Vector2(300, 60)
	go.add_theme_font_size_override("font_size", 28)
	UiStyle.primary(go)
	go.disabled = (not host) or problem != ""
	row.add_child(go)
	if problem != "":
		row.add_child(UiStyle.text(problem, 16, UiStyle.BAD))
	elif not host:
		row.add_child(UiStyle.text("The host starts the game.", 16, UiStyle.MUTED))


func _nothing() -> void:
	pass


## The map's one-line story, as under the skirmish's map picker.
func _map_desc(mid: String, n: int) -> String:
	if MapGen.is_pool(mid):
		return MapGen.pool_desc(mid, n)
	if MapData.NAMED.has(mid):
		var sz := MapGen.size_of(mid)
		return Loc.t("%s, %dx%d, up to %d players. %s  %s.") % [MapGen.mode_of(mid), sz.x, sz.y, MapGen.max_players(mid),
			Loc.t(String(MapData.NAMED[mid].get("about", ""))), main._biome(MapGen.biome_of(mid))]
	if MapGen.MAPS.has(mid):
		var d := Loc.t({"crossroads": "Open ground around a central hill.", "highlands": "Main bases on high ground, one ramp down.",
			"rivers": "Rivers you can only cross at the fords."}[MapGen.MAPS[mid][1]])
		return d + Loc.t("  110x80, up to 4 players.  ") + main._biome(String(MapGen.MAPS[mid][2])) + "."
	return ""


func _slot_row(l: NetLobby, i: int) -> Control:
	var s: Dictionary = l.slots[i]
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	var who := String(s["who"])
	var mine := (l.is_host and who == "you") or (not l.is_host and i == l.my_slot)
	var can := l.is_host or mine            # the host sets his own and the computers'; a friend only his own
	var colour: Color = Defs.colour_of(int(s.get("colour", Defs.COLOUR_FITS_MAP)))
	# who
	var name_txt := ""
	if who == "you":
		name_txt = "YOU (HOST)" if l.is_host else "HOST"
	elif who == "remote":
		var here: bool = (int(s.get("peer", -1)) >= 0) if l.is_host else bool(s.get("here", false))
		name_txt = ("YOU" if mine else "FRIEND") if here else "waiting..."
	var wb: Button
	if who == "you" or who == "remote":
		wb = Button.new()
		wb.text = Loc.t(name_txt)
		wb.custom_minimum_size = Vector2(170, 58)
		wb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		wb.size_flags_stretch_ratio = 1.7
		wb.add_theme_font_size_override("font_size", 18)
		wb.add_theme_font_override("font", UiStyle.bold_font())
		wb.clip_text = true
		wb.disabled = true
		wb.add_theme_color_override("font_disabled_color", Color(1, 0.9, 0.55) if mine else UiStyle.TEXT)
	else:
		var lv_opts: Array = []
		for lv in NetLobby.LEVELS:
			lv_opts.append([String(main.WHO_LABEL[lv]), lv, false])
		wb = main._dropdown(String(main.WHO_LABEL.get(who, who.to_upper())), 170, lv_opts, func(v) -> void: l.set_level(i, String(v)), 240.0, "", _nothing)
		wb.disabled = not l.is_host
		wb.add_theme_color_override("font_disabled_color", UiStyle.TEXT)
		if who == "brutal":
			wb.add_theme_color_override("font_color", UiStyle.BAD)
	h.add_child(wb)
	# faction
	var f := String(s["faction"])
	var fac_opts: Array = []
	for ff in FACS:
		fac_opts.append(["RANDOM" if ff == "random" else String(Defs.FACTIONS[ff]["name"]).to_upper(), ff, false])
	if mine and not l.is_host and who == "remote":
		fac_opts.append([Loc.t("SPECTATOR (WATCH)"), "spectator", false])      # (leave this seat and watch every side)
	var pick_fac := func(v) -> void:
		if l.is_host:
			l.set_faction(i, String(v))
		else:
			l.choose_faction(String(v))
	var fb: Button = main._dropdown("RANDOM" if f == "random" else String(Defs.FACTIONS[f]["name"]).to_upper(), 190, fac_opts, pick_fac, 240.0, "", _nothing)
	if f != "random":
		fb.icon = main._faction_icon(f)
		fb.expand_icon = false
		fb.add_theme_constant_override("icon_max_width", 30)
		fb.add_theme_color_override("font_color", UiStyle.accent(f).lightened(0.4))
		fb.add_theme_color_override("font_disabled_color", UiStyle.accent(f).lightened(0.4))
	else:
		fb.add_theme_color_override("font_disabled_color", UiStyle.TEXT)
	fb.disabled = not can
	h.add_child(fb)
	# colour (a pick someone else already has is greyed out; the host double-checks)
	var col_opts: Array = []
	for c in [Defs.COLOUR_FITS_MAP, Defs.COLOUR_RANDOM] + range(Defs.PALETTE.size()):
		col_opts.append([Defs.colour_name(int(c)).to_upper(), int(c), l.colour_taken(int(c), i)])
	var pick_col := func(v) -> void:
		if l.is_host:
			l.set_colour(i, int(v))
		else:
			l.choose_colour(int(v))
	var cb: Button = main._dropdown(Defs.colour_name(int(s.get("colour", Defs.COLOUR_FITS_MAP))).to_upper(), 110, col_opts, pick_col, 240.0, "", _nothing)
	for stn in ["normal", "hover", "pressed", "disabled"]:
		cb.add_theme_stylebox_override(stn, UiStyle.box(colour.darkened(0.25 if stn in ["normal", "disabled"] else 0.1), Color(1, 1, 1, 0.5 if stn in ["normal", "disabled"] else 0.9), 2))
	cb.add_theme_color_override("font_color", Color(1, 1, 1))
	cb.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	cb.add_theme_color_override("font_disabled_color", Color(1, 1, 1))
	cb.disabled = not can
	h.add_child(cb)
	# plan (computers only; the host sets it)
	if who != "you" and who != "remote":
		var plans: Array = ["random"] + AI.lobby_plans(f)
		var stg := String(s.get("strategy", "balanced"))
		if not plans.has(stg):
			stg = "balanced"                    # (shown as Balanced; the host's start falls back the same way)
		var st_opts: Array = []
		for o in plans:
			st_opts.append(["RANDOM PLAN" if o == "random" else String(AI.STRATEGIES[o]["name"]).to_upper(), o, false])
		var sb: Button = main._dropdown("RANDOM PLAN" if stg == "random" else String(AI.STRATEGIES[stg]["name"]).to_upper(), 150, st_opts, func(v) -> void: l.set_strategy(i, String(v)), 240.0, "", _nothing)
		sb.tooltip_text = "How this computer player plays. The list shows the plans of this player's faction."
		if stg == "optimal":
			sb.tooltip_text = AI.OPTIMAL_TIP
		sb.add_theme_color_override("font_disabled_color", UiStyle.TEXT)
		sb.disabled = not l.is_host
		h.add_child(sb)
	else:
		var sp := Control.new()
		sp.custom_minimum_size.x = 150
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sp.size_flags_stretch_ratio = 1.5
		h.add_child(sp)
	# team (only the host sets it)
	var team_opts: Array = []
	for k in l.slots.size():
		team_opts.append([Loc.t("TEAM %d") % (k + 1), k, false])
	var tb: Button = main._dropdown(str(int(s["side"]) + 1), 80, team_opts, func(v) -> void: l.set_side(i, int(v)), 240.0, "", _nothing)
	tb.add_theme_font_size_override("font_size", 22)
	tb.add_theme_color_override("font_disabled_color", UiStyle.TEXT)
	tb.disabled = not l.is_host
	h.add_child(tb)
	return h


## The SPECTATORS group under the players: a title with the count, a row each (name, round trip to the host), and for a
## guest who watches a list to take a free seat back. Nothing when nobody watches.
func _spec_rows(l: NetLobby, rows: VBoxContainer) -> void:
	_spec_lbls = []
	if l.specs.is_empty():
		return
	rows.add_child(HSeparator.new())
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	head.add_child(UiStyle.text(Loc.t("SPECTATORS (%d)") % l.specs.size(), 16, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT, true))
	head.add_child(UiStyle.text(Loc.t("watching: every side, no orders"), 14, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT))
	rows.add_child(head)
	for sp in l.specs:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 12)
		var me: bool = not l.is_host and l.spectating and int(sp.get("n", 0)) == l.my_spec
		var nm := UiStyle.text(Loc.t("YOU (SPECTATOR)") if me else Loc.t("SPECTATOR %d") % int(sp.get("n", 0)), 18,
			Color(1, 0.9, 0.55) if me else Color(0.72, 0.78, 0.86), HORIZONTAL_ALIGNMENT_LEFT, true)
		nm.custom_minimum_size.x = 230
		h.add_child(nm)
		var pl := UiStyle.text(_spec_ping(l, sp), 15, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT)
		pl.custom_minimum_size.x = 120
		pl.set_meta("spec", int(sp.get("peer", -1)) if l.is_host else int(sp.get("n", 0)))
		_spec_lbls.append(pl)
		h.add_child(pl)
		if me:
			var free := false
			for s in l.slots:
				if String(s["who"]) == "remote" and not bool(s.get("here", true)):
					free = true
			if free:
				var opts: Array = []
				for ff in FACS:
					opts.append(["RANDOM" if ff == "random" else String(Defs.FACTIONS[ff]["name"]).to_upper(), ff, false])
				var take: Button = main._dropdown(Loc.t("TAKE A SEAT"), 200, opts, func(v) -> void: l.choose_faction(String(v)), 240.0, "", _nothing)
				take.tooltip_text = Loc.t("Pick a faction to play in the free seat.")
				h.add_child(take)
		rows.add_child(h)
	if not l.spec_pinged.is_connected(_on_spec_pinged):
		l.spec_pinged.connect(_on_spec_pinged)
	if not l.pinged.is_connected(_on_spec_pinged):
		l.pinged.connect(_on_spec_pinged)


var _spec_lbls: Array = []


func _spec_ping(l: NetLobby, sp: Dictionary) -> String:
	var ms := int(l.ping_of.get(int(sp.get("peer", -1)), -1)) if l.is_host else int(sp.get("ping", -1))
	return Loc.t("ping %d ms") % ms if ms >= 0 else ""


func _on_spec_pinged() -> void:
	var l := _lobby()
	if l == null:
		return
	for lb in _spec_lbls:
		if not is_instance_valid(lb):
			continue
		var key := int(lb.get_meta("spec", -1))
		for sp in l.specs:
			if (int(sp.get("peer", -1)) if l.is_host else int(sp.get("n", 0))) == key:
				lb.text = _spec_ping(l, sp)


## A CAMPAIGN room (a mission played in co-op or versus, made from the CAMPAIGN page): the mission, the mode, who
## plays which side; no faction, colour or map choices (the mission sets them). The host starts.
func _draw_campaign_room(l: NetLobby) -> void:
	var host := l.is_host
	var mid := String(l.campaign.get("mission", ""))
	var md := String(l.campaign.get("mode", "coop"))
	var m := Campaign.mission(mid)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	_box.add_child(top)
	var t := UiStyle.heading(Loc.t("ROOM") + "  " + l.code, 38, Color(1, 0.9, 0.55))
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	top.add_child(t)
	# (the button is passed in: a lambda takes a copy of `cp` when it is made, still null then, so pressing COPY
	# stopped with a SCRIPT ERROR before it could say COPIED, playtest 2026-11-21)
	var cp: Button = main._button("COPY", func() -> void: pass)
	cp.pressed.connect(func() -> void:
		DisplayServer.clipboard_set(l.code)
		cp.text = Loc.t("COPIED"))
	cp.custom_minimum_size = Vector2(130, 44)
	top.add_child(cp)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_box.add_child(body)
	var pp := PanelContainer.new()
	pp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(pp)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 10)
	pp.add_child(pv)
	pv.add_child(UiStyle.text(Loc.t("CAMPAIGN") + ": " + Loc.t(Campaign.MODE_LABEL.get(md, md)), 16, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT, true))
	pv.add_child(UiStyle.heading(Loc.t(String(m.get("title", mid))), 30, UiStyle.TRIM))
	var sm := UiStyle.text(String(m.get("summary", "")), 17, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	sm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pv.add_child(sm)
	# who plays what: the host's seat and the friend's
	for i in l.slots.size():
		var s: Dictionary = l.slots[i]
		var who := String(s["who"])
		if who != "you" and who != "remote":
			continue
		var mine := (host and who == "you") or (not host and i == l.my_slot)
		var here: bool = who == "you" or ((int(s.get("peer", -1)) >= 0) if host else bool(s.get("here", false)))
		var nm := ("YOU" if mine else ("HOST" if who == "you" else "FRIEND")) if here else "waiting..."
		var side_id := ""
		for tm in m.get("teams", []):
			if String(tm["id"]) == String(s.get("team_id", "")):
				side_id = String(tm["side"])
		var row := UiStyle.text(Loc.t(nm) + "  ·  " + Loc.t(Campaign.side_name(m, side_id)), 20, Defs.colour_of(int(s.get("colour", 0))).lightened(0.35), HORIZONTAL_ALIGNMENT_LEFT, true)
		pv.add_child(row)
	var st := UiStyle.text(l.status, 15, UiStyle.BAD if l.refused != "" or not l.online else UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	st.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pv.add_child(st)
	var hint := UiStyle.text("Tell your friend the room code: they join from ONLINE with it.", 15, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pv.add_child(hint)
	var mp := PanelContainer.new()
	mp.custom_minimum_size = Vector2(360, 0)
	body.add_child(mp)
	var bv := VBoxContainer.new()
	mp.add_child(bv)
	var my_side := ""
	var me := l.my_slot
	if host:
		for i in l.slots.size():
			if String(l.slots[i]["who"]) == "you":
				me = i
	for tm in m.get("teams", []):
		var sl: Dictionary = l.slots[clampi(me, 0, l.slots.size() - 1)]
		if String(tm["id"]) == String(sl.get("team_id", "")):
			my_side = String(tm["side"])
	var br: Dictionary = m.get("briefing", {}).get(my_side, {})
	var sv := StillView.make(m.get("stills", {}).get(String(br.get("still", "")), {}), Color(0.7, 0.2, 0.2))
	sv.custom_minimum_size = Vector2(340, 200)
	sv.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bv.add_child(sv)
	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 16)
	row2.alignment = BoxContainer.ALIGNMENT_CENTER
	_box.add_child(row2)
	var back: Button = main._button("LEAVE", func() -> void:
		l.dispose()
		main.net_lobby = null
		_draw())
	back.custom_minimum_size = Vector2(200, 60)
	row2.add_child(back)
	var problem := l.problem() if host else ""
	var go: Button = main._button("START", func() -> void:
		Sfx.play_any(["ui/start_match"])
		main.start(l.make_cfg()))
	go.custom_minimum_size = Vector2(300, 60)
	go.add_theme_font_size_override("font_size", 28)
	UiStyle.primary(go)
	go.disabled = (not host) or problem != ""
	row2.add_child(go)
	if problem != "":
		row2.add_child(UiStyle.text(problem, 16, UiStyle.BAD))
	elif not host:
		row2.add_child(UiStyle.text("The host starts the game.", 16, UiStyle.MUTED))
