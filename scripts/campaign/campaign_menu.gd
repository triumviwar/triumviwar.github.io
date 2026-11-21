class_name CampaignMenu
extends RefCounted
## The CAMPAIGN pages (docs/campaign_engine.md): the storylines and their missions (each opens in turn; progress is
## kept in user://campaign.json), the chosen mission with SOLO / CO-OP / VERSUS where it allows them, the BRIEFING
## (a still and the side's orders) and, after a mission, its END (won or lost, the still and words of the side that
## won, where the story goes next). CO-OP and VERSUS open an online room (NetLobby.set_campaign).

static var pick := ""            # the mission chosen on the list
static var line := ""            # the storyline whose hub is shown
static var mode := "solo"
static var seat := "p1"          # versus: which side the host plays ("p1" / "p2")
static var solo_pick := ""       # solo: the side picked on the briefing (the SOLO SIDE PICK; "" the mission's own)
static var vs_pick := ""         # versus: the side the friend's seat (p2) leads when the mission has a "versus_pick" (a07)
## THE WAR MAP page (war-map-v1, docs/war_map_v1.md)
static var map_open := false     # the war map is the page the briefing and the war table go back to
static var map_home := ""        # the storyline whose hub opened it (its BACK goes there)
static var map_skin := "parchment"
static var map_pick := ""        # the pin picked on it
static var map_cam := {}         # where the map was looking ({"c", "z"}), kept while the page comes and goes


static func _side_col(m: Dictionary, side_id: String) -> Color:
	for tm in m.get("teams", []):
		if String(tm["side"]) == side_id:
			return Defs.colour_of(int(tm.get("colour", 0)))
	return Color(0.6, 0.5, 0.4)


static func _panel(parent: Control, minw := 0.0) -> VBoxContainer:
	var p := PanelContainer.new()
	p.custom_minimum_size.x = minw
	parent.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	return v


static func _wrap(t: String, sz: int, col := UiStyle.TEXT) -> Label:
	var l := UiStyle.text(t, sz, col, HORIZONTAL_ALIGNMENT_LEFT)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func _frame(main: Node, cover := true) -> VBoxContainer:
	var root: Control = main._page()
	if cover:
		# THE CAMPAIGN'S OWN LAYER (the owner, 2026-11-15 21:01): not the main menu's painting behind it: the storyline's hub
		# painting, dimmed, over the whole screen (top and bottom too), else a dark ground
		var bd: Control = main._backdrop
		if bd != null and is_instance_valid(bd):
			bd.visible = false
		var bg := ColorRect.new()
		bg.color = Color(0.06, 0.05, 0.04)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var img := String(_line_data().get("hub", {}).get("still", {}).get("image", ""))
		if img != "" and ResourceLoader.exists(img):
			var tr := TextureRect.new()
			tr.texture = load(img)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			tr.modulate = Color(0.3, 0.28, 0.26)
			tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			bg.add_child(tr)
		main.ui_layer.add_child(bg)
		main.ui_layer.move_child(bg, root.get_index())
	var m := MarginContainer.new()
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		m.add_theme_constant_override("margin_" + side, 30)
	for side in ["top", "bottom"]:
		m.add_theme_constant_override("margin_" + side, 16)
	root.add_child(m)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	m.add_child(box)
	return box


# ------------------------------------------------------------------ the WAR TABLE: the storyline's missions

static func war_table(main: Node) -> void:
	var box := _frame(main)
	var p := Campaign.progress()
	var sl0 := _line_data()
	# (the hub as the story has left it: after the fall the Clockmaker's war table is the barn at Fürth's, not Hollweg's
	# workshop; playtest-campaign-clock)
	box.add_child(UiStyle.heading(Loc.t(String(hub_now(sl0.get("hub", {}), p).get("title", sl0.get("title", "")))) + "  ·  " + Loc.t("WAR TABLE"), 34, UiStyle.TRIM))
	var ids: Array = (sl0.get("missions", []) as Array).map(func(x) -> String: return String(x))
	if pick == "" or not ids.has(pick) or not Campaign.unlocked(pick, p):
		pick = ""
		for x in ids:
			if Campaign.unlocked(x, p):
				pick = x
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(body)
	# left: the storylines, each with its missions
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.custom_minimum_size.x = 420
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(sc)
	var lv := VBoxContainer.new()
	lv.add_theme_constant_override("separation", 12)
	lv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(lv)
	for sl in [sl0]:
		var v := _panel(lv)
		var open := Campaign.storyline_open(sl, p)
		v.add_child(UiStyle.text(Loc.t(String(sl.get("title", ""))), 22, UiStyle.TRIM if open else UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT, true))
		v.add_child(_wrap(Loc.t(String(sl.get("about", ""))), 15, UiStyle.MUTED))
		if bool(sl.get("start", false)):
			v.add_child(_wrap(Loc.t("Start here: the story begins with the King in Rome."), 15, UiStyle.TRIM))
		if not open:
			var req := Campaign.mission(String(sl.get("requires", "")))
			v.add_child(_wrap(Loc.t("Opens after: %s") % Loc.t(String(req.get("title", ""))), 15, UiStyle.MUTED))
			continue
		if (sl.get("missions", []) as Array).is_empty():
			v.add_child(_wrap(Loc.t("The missions are being written."), 15, UiStyle.MUTED))
		for mid in sl.get("missions", []):
			var m := Campaign.mission(String(mid))
			var ok := Campaign.unlocked(String(mid), p)
			var t: String = Loc.t(String(m.get("title", mid))) if ok else Loc.t("(locked)")
			var done: Dictionary = (p["done"] as Dictionary).get(String(mid), {})
			if not done.is_empty():
				t += "   " + Loc.t("(won by %s)") % Loc.t(Campaign.side_name(m, String(done.get("won_by", ""))))
			var b: Button = main._button(t, func() -> void:
				pick = String(mid)
				war_table(main))
			b.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			# (a long title with "(won by ...)" wraps onto a second line instead of widening the list: the mission's
			# panel lost its width and pushed BACK / WAR MAP under the bottom of the screen; playtest-campaign-clock)
			b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			b.disabled = not ok
			b.name = "Mission_" + String(mid)
			if String(mid) == pick:
				UiStyle.chosen(b)
			v.add_child(b)
	# right: the chosen mission
	var rv := _panel(body)
	rv.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if pick != "":
		var m := Campaign.mission(pick)
		var modes := Campaign.modes_of(m)
		if not modes.has(mode):
			mode = "solo"
		var my_side := Campaign.seat_side(m, mode, seat, vs_pick) if mode == "versus" else (Campaign.solo_side(m, solo_pick) if mode == "solo" else Campaign.seat_side(m, mode, "p1"))
		rv.add_child(UiStyle.heading(Loc.t(String(m.get("title", pick))), 32, UiStyle.TRIM))
		var br: Dictionary = m.get("briefing", {}).get(my_side, {})
		var sv := StillView.make(m.get("stills", {}).get(String(br.get("still", "")), {}), _side_col(m, my_side))
		# (it grows into the room left; at least 140 tall, so a crossing's three VERSUS seats and their line still leave
		# BACK / WAR MAP on the screen: a07 on 1280 x 720 put them 36 px under the edge with 220; playtest-campaign-clock)
		sv.custom_minimum_size = Vector2(0, 140)
		sv.size_flags_vertical = Control.SIZE_EXPAND_FILL
		rv.add_child(sv)
		rv.add_child(_wrap(Loc.t(String(m.get("summary", ""))), 17))
		var mrow := HBoxContainer.new()
		mrow.add_theme_constant_override("separation", 8)
		rv.add_child(mrow)
		for md in Campaign.MODES:
			var b: Button = main._button(Campaign.MODE_LABEL[md], func() -> void:
				mode = md
				war_table(main))
			b.name = "Mode_" + md
			b.custom_minimum_size = Vector2(130, 50)
			b.disabled = not modes.has(md)
			if md == mode:
				UiStyle.chosen(b)
			mrow.add_child(b)
		var about := {"solo": "You against the computer.", "coop": "You and a friend online on the same side, against the computer.",
			"versus": "You and a friend online on opposite sides: the story follows whoever wins."}
		rv.add_child(_wrap(Loc.t(about[mode]), 15, UiStyle.MUTED))
		if mode == "versus":
			var srow := HBoxContainer.new()
			srow.add_theme_constant_override("separation", 8)
			rv.add_child(srow)
			srow.add_child(UiStyle.text(Loc.t("YOU PLAY:"), 16, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT, true))
			# (THE VERSUS PICK, a07: the friend's seat may lead one of several sides: a button for each)
			var seats: Array = [["p1", ""]]
			var picks := Campaign.versus_picks(m)
			if picks.is_empty():
				seats.append(["p2", ""])
			else:
				if not picks.has(vs_pick):
					vs_pick = String(picks[0])
				for pk in picks:
					seats.append(["p2", String(pk)])
			for sp in seats:
				var st := String(sp[0])
				var pk := String(sp[1])
				var sd := Campaign.seat_side(m, "versus", st, pk)
				var b: Button = main._button(Loc.t(Campaign.side_name(m, sd)).to_upper(), func() -> void:
					seat = st
					if pk != "":
						vs_pick = pk
					war_table(main))
				b.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
				b.name = "Seat_" + st + ("_" + pk if pk != "" else "")
				b.custom_minimum_size = Vector2(190, 46)
				if st == seat and (pk == "" or pk == vs_pick):
					UiStyle.chosen(b, _side_col(m, sd))
				srow.add_child(b)
			if not picks.is_empty():
				# the other side the friend could lead is scripted: say so
				var other: Array = picks.filter(func(x) -> bool: return String(x) != vs_pick)
				rv.add_child(_wrap(Loc.t("The friend's side: %s. The other is played by the computer: %s.") % [Loc.t(Campaign.side_name(m, vs_pick)),
					", ".join(other.map(func(x) -> String: return Loc.t(Campaign.side_name(m, String(x)))))], 15, UiStyle.MUTED))
		var go: Button = main._button("BRIEFING" if mode == "solo" else "OPEN AN ONLINE ROOM", func() -> void:
			if mode == "solo":
				briefing(main, pick)
			else:
				host_online(main, pick, mode, seat if mode == "versus" else "p1", vs_pick if mode == "versus" else ""))
		go.name = "Campaign_Go"
		UiStyle.primary(go)
		go.custom_minimum_size = Vector2(0, 60)
		rv.add_child(go)
	var brow := HBoxContainer.new()
	brow.add_theme_constant_override("separation", 12)
	box.add_child(brow)
	var back: Button = main._button("BACK", func() -> void:
		if map_open:
			war_map(main)
		else:
			show(main))
	main._set_back(back)
	back.custom_minimum_size = Vector2(240, 56)
	brow.add_child(back)
	# THE WAR MAP (war-map-v1): every war table can open it (the King's parchment until each hub has its own skin)
	var wm: Button = main._button("WAR MAP", func() -> void: war_map(main))
	wm.name = "WarTable_Map"
	wm.custom_minimum_size = Vector2(240, 56)
	brow.add_child(wm)


## CO-OP / VERSUS: host an online room for the mission (the friend joins with the code from ONLINE).
static func host_online(main: Node, mid: String, md: String, st: String, vp := "") -> void:
	var relay_ok: bool = not Settings.relay_url.contains("YOURNAME") and Settings.relay_url.strip_edges() != ""
	if relay_ok:
		var l := NetLobby.new()
		main.add_child(l)
		main.net_lobby = l
		l.host(Settings.relay_url, NetLink.new_code())
		l.set_campaign(mid, md, st, vp)
	main.show_online()
	var mm: Node = main.menu.get_child(0) if main.menu and main.menu.get_child_count() > 0 else null
	if mm is MultiplayerMenu and main.net_lobby:
		main.net_lobby.changed.connect((mm as MultiplayerMenu)._on_changed)
		main.net_lobby.failed.connect((mm as MultiplayerMenu)._on_failed)


# ------------------------------------------------------------------ the briefing

static func briefing(main: Node, mid: String) -> void:
	var m := Campaign.mission(mid)
	var side := Campaign.solo_side(m, solo_pick)
	var br: Dictionary = m.get("briefing", {}).get(side, {})
	var box := _frame(main)
	box.add_child(UiStyle.heading(Loc.t("BRIEFING"), 22, UiStyle.MUTED))
	box.add_child(UiStyle.heading(Loc.t(String(m.get("title", mid))), 40, UiStyle.TRIM))
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 16)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(body)
	var sv := StillView.make(m.get("stills", {}).get(String(br.get("still", "")), {}), _side_col(m, side))
	sv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sv.size_flags_stretch_ratio = 1.3
	body.add_child(sv)
	# (the words scroll: a long briefing with a side pick, The Specimens', pushed START under the bottom edge at 1280 x
	# 720, playtest 2026-11-21)
	var bpn := PanelContainer.new()
	bpn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(bpn)
	var pv := VBoxContainer.new()            # the words (scrolling), then the side and difficulty picks (always in view)
	pv.add_theme_constant_override("separation", 10)
	bpn.add_child(pv)
	var bsc := ScrollContainer.new()
	bsc.name = "BriefingWords"
	bsc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	bsc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pv.add_child(bsc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bsc.add_child(v)
	v.add_child(UiStyle.text(Loc.t("You lead: %s") % Loc.t(Campaign.side_name(m, side)), 20, _side_col(m, side).lightened(0.35), HORIZONTAL_ALIGNMENT_LEFT, true))
	for t in br.get("text", []):
		v.add_child(_wrap(Loc.t(String(t)), 18))
	v.add_child(UiStyle.text(Loc.t("OBJECTIVES"), 18, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_LEFT, true))
	for o in m.get("objectives", []):
		if String(o.get("side", "")) == side and not bool(o.get("hidden", false)):
			var pre := "-  " if bool(o.get("primary", true)) else "-  " + Loc.t("(optional)") + " "
			v.add_child(_wrap(pre + Campaign.brief_text(m, Loc.t(String(o["text"]))), 16, UiStyle.TEXT if bool(o.get("primary", true)) else UiStyle.MUTED))
	# THE SOLO SIDE PICK (a mission that lets you lead either side alone) and the campaign's DIFFICULTY (act1-engine0)
	var sides := Campaign.solo_sides(m)
	if sides.size() > 1:
		var srow := HFlowContainer.new()
		srow.add_theme_constant_override("h_separation", 8)
		srow.add_theme_constant_override("v_separation", 6)
		pv.add_child(srow)
		srow.add_child(UiStyle.text(Loc.t("YOU PLAY:"), 16, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT, true))
		for sd in sides:
			var b: Button = main._button(Loc.t(Campaign.side_name(m, sd)).to_upper(), func() -> void:
				solo_pick = sd
				briefing(main, mid))
			b.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			b.name = "Side_" + String(sd)
			b.custom_minimum_size = Vector2(170, 46)
			if sd == side:
				UiStyle.chosen(b, _side_col(m, sd))
			srow.add_child(b)
	var drow := HFlowContainer.new()
	drow.add_theme_constant_override("h_separation", 8)
	drow.add_theme_constant_override("v_separation", 6)
	pv.add_child(drow)
	drow.add_child(UiStyle.text(Loc.t("DIFFICULTY:"), 16, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT, true))
	var dnow := Campaign.difficulty()
	for lv in Campaign.DIFFICULTIES:
		var b: Button = main._button(Campaign.DIFF_LABEL[lv], func() -> void:
			Campaign.set_difficulty(lv)
			briefing(main, mid))
		b.name = "Diff_" + String(lv)
		b.custom_minimum_size = Vector2(120, 46)
		if lv == dnow:
			UiStyle.chosen(b)
		drow.add_child(b)
	var dabout := {"easy": "More time on the clock and fewer enemies.", "normal": "The mission as it was written.",
		"hard": "Less time on the clock and more enemies."}
	pv.add_child(_wrap(Loc.t(dabout[dnow]), 15, UiStyle.MUTED))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	box.add_child(row)
	var back: Button = main._button("BACK", func() -> void:
		if map_open:
			war_map(main)
		else:
			war_table(main))
	main._set_back(back)
	back.custom_minimum_size = Vector2(200, 60)
	row.add_child(back)
	var go: Button = main._button("START", func() -> void:
		Sfx.play_any(["ui/start_match"])
		opening_then_start(main, mid, Campaign.make_cfg(mid, "solo", "p1", false, side)))
	go.name = "Briefing_Start"
	go.custom_minimum_size = Vector2(300, 60)
	go.add_theme_font_size_override("font_size", 28)
	UiStyle.primary(go)
	row.add_child(go)


## An objective's words on the briefing, before any match: its counters at their start ("0 of 4"), its clocks at their
## full length at the campaign's difficulty ("20:00"), anything only the match knows as "…". (They read "{temper}",
## "{clock:patience}" on a01-a06's briefings; playtest 2026-11-21.)
static func brief_fill(m: Dictionary, txt: String) -> String:
	if txt.find("{") < 0:
		return txt
	var cs: Dictionary = m.get("counters", {})
	for cn in cs:
		var c: Dictionary = cs[cn]
		if c.has("of"):
			txt = txt.replace("{%s.of}" % cn, MissionRun._num(c["of"]))
		if c.has("of") or float(c.get("start", 0)) != 0.0:
			txt = txt.replace("{%s}" % cn, MissionRun._num(c.get("start", 0)))
	var mult := Campaign.diff_mult(m, Campaign.difficulty())
	var timed := {}
	for o in m.get("objectives", []):
		if String(o.get("kind", "")) == "countdown":
			timed[String(o.get("clock", ""))] = true
	for tr in m.get("triggers", []):
		for a in tr.get("do", []):
			if a is Dictionary and a.has("clock") and a["clock"] is Dictionary and (a["clock"] as Dictionary).has("secs"):
				var cl: Dictionary = a["clock"]
				var cn := String(cl.get("name", ""))
				var scales: bool = bool(cl["scale"]) if cl.has("scale") else timed.has(cn)
				var secs := int(round(float(cl["secs"]) * (float(mult.get("clocks", 1.0)) if scales else 1.0)))
				txt = txt.replace("{clock:%s}" % cn, "%d:%02d" % [secs / 60, secs % 60])
	var re := RegEx.create_from_string("\\{[^}]*\\}")
	return re.sub(txt, "…", true)


## The mission's OPENING (its stills and lines: StillShow), then the match. None: straight in.
static func opening_then_start(main: Node, mid: String, cfg: Dictionary) -> void:
	var m := Campaign.mission(mid)
	var camp: Dictionary = cfg.get("campaign", {})
	var side := String(camp.get("side", Campaign.seat_side(m, String(camp.get("mode", "solo")), String(camp.get("seat", "p1")),
		String(camp.get("pick", "")))))
	var pages := Campaign.pages_before(Campaign.show_pages(m, "opening", side), side)      # (its lines with an "if" decided now)
	if pages.is_empty():
		main.start(cfg)
		return
	main._clear_ui()
	StillShow.play(main.ui_layer, m, pages, func() -> void: main.start(cfg))


## An opening's pages with their conditional lines settled before the match exists (a MissionRun without a game:
## only conditions that read the progress, {"past"}, {"difficulty"}, and their "not" / "all" / "any", make sense here).
static func opening_now(m: Dictionary, pages: Array) -> Array:
	var tmp := MissionRun.new()
	tmp.data = m
	tmp.id = String(m.get("id", ""))
	tmp.difficulty = Campaign.difficulty()
	var out := tmp.pages_now(pages)
	tmp.free()
	return out


# ------------------------------------------------------------------ the end of a mission

## Over the finished match: VICTORY / DEFEAT (versus: who won), the winners' still and words, where the story goes
## (the next mission, the storylines it opens), and NEXT MISSION / PLAY AGAIN / BATTLE REPORT / CAMPAIGN.
static func mission_end(main: Node, game: Game, winner: int, rp_path: String) -> void:
	var run := game.mission
	var m := run.data
	var mid := run.id
	var win_side := run.winner_side_of(winner) if winner >= 0 else ""
	var mine := run.my_side()
	var nxt := Campaign.record(mid, run.mode, win_side, mine, run.flags)
	var won := win_side != "" and win_side == mine
	# the mission's ENDING for the side that won (its stills and lines: StillShow), then this screen
	var ending := run.pages_now(Campaign.show_pages(m, "ending", win_side))      # (lines with an "if" said only when it holds)
	if not ending.is_empty() and (won or run.mode == "versus") and not game.has_meta("ending_shown"):
		game.set_meta("ending_shown", true)
		StillShow.play(main.ui_layer, m, ending, func() -> void:
			if is_instance_valid(game):
				_end_panel(main, game, winner, rp_path, nxt, won, win_side))
		return
	_end_panel(main, game, winner, rp_path, nxt, won, win_side)


static func _end_panel(main: Node, game: Game, winner: int, rp_path: String, nxt: String, won: bool, win_side: String) -> void:
	var run := game.mission
	var m := run.data
	var mid := run.id
	var mine := run.my_side()
	var o := Control.new()
	o.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.theme = UiStyle.theme()
	o.process_mode = Node.PROCESS_MODE_ALWAYS
	o.name = "MissionEnd"
	main.ui_layer.add_child(o)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.add_child(dim)
	var cc := CenterContainer.new()
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.add_child(cc)
	# (a phone: bigger words, as the war map's card has: at 14-17 the debrief and the objectives were a few pixels
	# high on a phone held sideways; playtest 2026-11-21)
	var ph := not Settings.pc()
	var k := 1.4 if ph else 1.0
	var v := _panel(cc, 1000 if ph else 820)
	var title := ("VICTORY" if won else "DEFEAT") if run.mode != "versus" else (Loc.t("%s WIN") % Loc.t(Campaign.side_name(m, win_side)).to_upper())
	var db: Dictionary = m.get("debrief", {}).get(win_side, {})
	# a STORY LOSS (the Clockwork prologue): the mission counts as played to its end, but the screen says the story's
	# words ("NUREMBERG IS LOST") over the debrief's "banner", in the colour of a loss
	var story_loss := db.has("banner") and won
	if story_loss:
		title = String(db["banner"])
	v.add_child(UiStyle.heading(Loc.t(title), int(44 * k), UiStyle.BAD if story_loss or not won else UiStyle.GOOD))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	v.add_child(h)
	var sv := StillView.make(m.get("stills", {}).get(String(db.get("still", "")), {}), _side_col(m, win_side))
	sv.custom_minimum_size = Vector2(380, 230) if not ph else Vector2(340, 210)
	h.add_child(sv)
	# the words and the objectives scroll when they are more than the screen holds (a won Specimen One at 1280 x 720
	# pushed NEXT MISSION and CAMPAIGN under the bottom edge: playtest 2026-11-21)
	var tsc := ScrollContainer.new()
	tsc.name = "EndWords"
	tsc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tsc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(tsc)
	var tv := VBoxContainer.new()
	tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tsc.add_child(tv)
	var fit := func() -> void:
		if not is_instance_valid(tsc):
			return
		var room: float = o.get_viewport_rect().size.y - 260.0
		tsc.custom_minimum_size.y = clampf(tv.get_combined_minimum_size().y, 230.0, maxf(230.0, room))
	tv.resized.connect(fit)
	tv.add_child(UiStyle.text(Loc.t(String(db.get("title", ""))), 24, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_LEFT, true))
	tv.add_child(_wrap(run.fill(Loc.t(String(db.get("text", "")))), 17))      # (its {counters} filled, as text_if's: a04, a07)
	for ti in db.get("text_if", []):
		if run.cond(ti.get("if", {})):
			tv.add_child(_wrap(run.fill(Loc.t(String(ti.get("text", "")))), int(16 * k)))      # (the debrief's words by the flags)
	# the objectives as they ended
	for ob in run.objectives_for(mine):
		if String(ob.get("kind", "")) == "countdown":
			continue
		var mark: String = {"done": "[+] ", "failed": "[x] ", "active": "[ ] "}.get(String(ob["state"]), "")
		tv.add_child(_wrap(mark + run.objective_text(ob), int(14 * k), UiStyle.GOOD if ob["state"] == "done" else (UiStyle.BAD if ob["state"] == "failed" else UiStyle.MUTED)))
	# where the story goes
	var story := ""
	if won or run.mode == "versus":
		if nxt != "":
			story = Loc.t("The story goes on: %s") % Loc.t(String(Campaign.mission(nxt).get("title", nxt)))
		else:
			var opened: Array = Campaign.opens(mid).map(func(sl: Dictionary) -> String: return Loc.t(String(sl.get("title", ""))))
			story = (Loc.t("New storylines open: %s") % ", ".join(opened)) if not opened.is_empty() else Loc.t("The next mission is being written.")
			# a MIRROR won (the Nest on the Lost Plateau, the creatures in The Specimens): the story goes on from the other
			# side, so say so ("being written" sent players looking for a mission that will not come: playtest 2026-11-21)
			var nx: Variant = m.get("next", null)
			if opened.is_empty() and nx is Dictionary and run.mode == "solo":
				for sd in nx:
					if String(nx[sd]) != "" and String(sd) != win_side:
						story = Loc.t("That is not how it went. To go on with the story, win it as %s.") % Loc.t(Campaign.side_name(m, String(sd)))
						break
	else:
		story = Loc.t("Try again: the story waits for a victory.")
	v.add_child(_wrap(story, int(17 * k), UiStyle.TRIM))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	v.add_child(row)
	var online: bool = game.net != null
	var btns: Array = []
	if nxt != "" and not online and Campaign.modes_of(Campaign.mission(nxt)).has("solo"):
		btns.append(["NEXT MISSION", func() -> void:
			main._to_menu()
			pick = nxt
			briefing(main, nxt)])
	if not online:
		btns.append(["PLAY AGAIN", func() -> void: main.start()])
	btns.append(["BATTLE REPORT", func() -> void:
		o.queue_free()
		main.show_battle_report(winner, rp_path)])
	btns.append(["CAMPAIGN", func() -> void:
		main._to_menu()
		show(main)])
	for bt in btns:
		var b: Button = main._button(bt[0], bt[1])
		b.custom_minimum_size = Vector2(170, 54) if not ph else Vector2(210, 70)
		if ph:
			b.add_theme_font_size_override("font_size", 24)
		b.name = "End_" + String(bt[0]).replace(" ", "_")
		row.add_child(b)


# ------------------------------------------------------------------ the HUB (the storyline's camp, ship or workshop)

## The storyline shown (the one picked, else the first open one).
static func _line_data() -> Dictionary:
	var p := Campaign.progress()
	var open: Array = Campaign.storylines().filter(func(sl: Dictionary) -> bool: return Campaign.storyline_open(sl, p))
	for sl in open:
		if String(sl["id"]) == line:
			return sl
	if open.is_empty():
		return {}
	line = String(open[0]["id"])
	return open[0]


## The CAMPAIGN page: the hub of a storyline (like StarCraft II's ship between missions): its still with HOTSPOTS to
## click (the WAR TABLE: the missions; people: a talk that changes after each mission; rooms: the ARMOURY, a stub),
## the same hotspots as a list beside it (phones, or when a hotspot is hard to see), and tabs for the storylines.
static func show(main: Node) -> void:
	map_open = false
	var box := _frame(main)
	var p := Campaign.progress()
	var sl := _line_data()
	var hub := hub_now(sl.get("hub", {}), p)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	box.add_child(top)
	var t := UiStyle.heading(Loc.t(String(hub.get("title", sl.get("title", "")))), 36, UiStyle.TRIM)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(t)
	for s in Campaign.storylines():
		var open := Campaign.storyline_open(s, p)
		var b: Button = main._button(Loc.t(String(s.get("title", ""))) + ("" if open else "  " + Loc.t("(locked)"))
				+ ("  · " + Loc.t("Start here") if bool(s.get("start", false)) else ""), func() -> void:
			line = String(s["id"])
			show(main))
		b.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		b.name = "Line_" + String(s["id"])
		b.custom_minimum_size = Vector2(150, 46)
		b.add_theme_font_size_override("font_size", 15)
		b.disabled = not open
		if open:
			b.tooltip_text = Loc.t(String(s.get("about", "")))
		else:
			b.tooltip_text = Loc.t("Opens after: %s") % Loc.t(String(Campaign.mission(String(s.get("requires", ""))).get("title", "")))
		if String(s["id"]) == line:
			UiStyle.chosen(b)
		top.add_child(b)
	box.add_child(_wrap(Loc.t(String(hub.get("about", sl.get("about", "")))), 15, UiStyle.MUTED))
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(body)
	# the scene: the still and its hotspots (fractions of the still), a talk box over its bottom
	var scene := Control.new()
	scene.name = "HubScene"
	scene.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scene.size_flags_stretch_ratio = 3.0
	body.add_child(scene)
	var col := Defs.colour_of(int(hub.get("colour", 1)))
	# a layered painting (HubScene: campaign/hub/<hub>.json) when the hub has one, else its still
	var hsc: HubScene = HubScene.make(String(hub["scene"])) if hub.has("scene") else null
	if hsc and not hsc.ok():
		hsc = null
	if hsc:
		hsc.hidden_layers = hub.get("hide_layers", [])
		if hub.has("tint"):
			var tn: Array = hub["tint"]
			hsc.modulate = Color(float(tn[0]), float(tn[1]), float(tn[2]))
	var sv: Control = hsc if hsc else StillView.make(hub.get("still", {}), col)
	sv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.add_child(sv)
	var talk_box := PanelContainer.new()
	talk_box.name = "HubTalk"
	talk_box.visible = false
	talk_box.add_theme_stylebox_override("panel", UiStyle.box(Color(0.09, 0.07, 0.05, 0.94), UiStyle.TRIM, 2, 10, 12.0))
	var spots: Array = hub.get("hotspots", [])
	var list := _panel(body, 230)
	list.add_child(UiStyle.text(Loc.t("GO TO"), 15, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT, true))
	var btns: Array = []
	for hs in spots:
		var act := func() -> void: _hotspot(main, sl, hs, talk_box, p)
		var list_only := bool(hs.get("list_only", false))
		var lb: Button = main._button(String(hs.get("label", "")), act)
		lb.name = "HotspotList_" + String(hs["id"])
		lb.custom_minimum_size = Vector2(0, 52 if Settings.pc() else 62)
		if String(hs.get("kind", "")) == "war_table":
			UiStyle.primary(lb)
		list.add_child(lb)
		if list_only:
			continue
		var hb := Button.new()
		hb.name = "Hotspot_" + String(hs["id"])
		hb.text = Loc.t(String(hs.get("label", "")))
		hb.focus_mode = Control.FOCUS_NONE
		var st := UiStyle.box(Color(0.1, 0.08, 0.05, 0.25), Color(0.95, 0.8, 0.4, 0.75), 3, 10, 6.0)
		var st_h := UiStyle.box(Color(0.95, 0.8, 0.4, 0.28), Color(1, 0.9, 0.55, 1.0), 3, 10, 6.0)
		if hsc:
			# over the painting the hotspot is the thing itself: no box, its name low on it; pointed at, the person
			# (or the map, the letter) lights up
			st = UiStyle.box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 6, 0.0)
			st_h = st
			hb.add_theme_color_override("font_color", Color(1, 0.95, 0.8, 0.0))      # its name shows when pointed at
			hb.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.0))
			hb.add_theme_color_override("font_hover_color", Color(1, 0.95, 0.8, 1.0))
			hb.add_theme_color_override("font_pressed_color", Color(1, 0.95, 0.8, 1.0))
			var lay := String(hs.get("layer", ""))
			hb.mouse_entered.connect(func() -> void:
				hsc.highlight = lay
				hsc.highlight_rect = Rect2() if lay != "" else Rect2(hb.position, hb.size))
			hb.mouse_exited.connect(func() -> void:
				hsc.highlight = ""
				hsc.highlight_rect = Rect2())
		hb.add_theme_stylebox_override("normal", st)
		hb.add_theme_stylebox_override("hover", st_h)
		hb.add_theme_stylebox_override("pressed", st_h)
		hb.add_theme_font_size_override("font_size", 18 if Settings.pc() else 22)
		if not hsc:
			hb.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
			hb.add_theme_constant_override("outline_size", 5)
		hb.pressed.connect(func() -> void:
			Sfx.play_any(["ui/click", "click"])
			act.call())
		scene.add_child(hb)
		btns.append([hb, hs])
	scene.add_child(talk_box)
	var place := func() -> void:
		var s: Vector2 = scene.size
		var big := Vector2(110, 60) if Settings.pc() else Vector2(150, 80)     # (a thumb's size at least on a phone)
		for it in btns:
			var r: Array = it[1].get("rect", [0, 0, 0.1, 0.1])
			var fr := hsc.image_rect(r) if hsc else Rect2(float(r[0]) * s.x, float(r[1]) * s.y, float(r[2]) * s.x, float(r[3]) * s.y)
			var sz := Vector2(maxf(fr.size.x, big.x), maxf(fr.size.y, big.y))
			var pos := fr.position - (sz - fr.size) * 0.5
			pos = pos.clamp(Vector2.ZERO, (s - sz).max(Vector2.ZERO))
			(it[0] as Button).position = pos
			(it[0] as Button).size = sz
		talk_box.position = Vector2(s.x * 0.05, s.y * 0.58)
		talk_box.size = Vector2(s.x * 0.9, s.y * 0.38)
	scene.resized.connect(place)
	place.call_deferred()
	_hub_difficulty(main, list)
	var back: Button = main._button("BACK", func() -> void: main.show_menu())
	main._set_back(back)
	back.custom_minimum_size = Vector2(0, 56)
	list.add_child(back)


## THE CAMPAIGN'S DIFFICULTY on the hub (campaign-fixes-1121, the owner 2026-11-21: "campaign has AI level as well in
## the hub"): EASY / NORMAL / HARD for every mission of every line, the side you lead and the mirrors alike (the clocks,
## the foe's numbers, the computer's level); the briefing shows the same choice.
static func _hub_difficulty(main: Node, list: VBoxContainer) -> void:
	var dnow := Campaign.difficulty()
	var cap := UiStyle.text(Loc.t("DIFFICULTY:") + " " + Loc.t(Campaign.DIFF_LABEL[dnow]), 15, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_LEFT, true)
	cap.name = "HubDifficulty"
	list.add_child(cap)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	list.add_child(row)
	for lv in Campaign.DIFFICULTIES:
		var b: Button = main._button(Campaign.DIFF_LABEL[lv], func() -> void:
			Campaign.set_difficulty(lv)
			show(main))
		b.name = "HubDiff_" + String(lv)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 44 if Settings.pc() else 56)
		b.add_theme_font_size_override("font_size", 13)
		if lv == dnow:
			UiStyle.chosen(b)
		row.add_child(b)
	var about := {"easy": "More time on the clock and fewer enemies.", "normal": "The mission as it was written.",
		"hard": "Less time on the clock and more enemies."}
	list.add_child(_wrap(Loc.t(about[dnow]), 13, UiStyle.MUTED))


## A hub as the story has left it (clockwork-prologue-build): "after": {mission id: {"title", "about", "still",
## "hide_layers": [layer ids of the painting], "tint": [r, g, b]}} replaces those once that mission is finished (the
## later one wins), and a hotspot with "requires": a mission shows only after it, one with "until": a mission only
## before it (Hollweg's workshop after the fall: he is gone, the machine keeps it).
static func hub_now(hub: Dictionary, p: Dictionary) -> Dictionary:
	var out: Dictionary = hub.duplicate()
	var done: Dictionary = p.get("done", {})
	for mid in hub.get("after", {}):
		var af: Dictionary = hub["after"][mid]
		if done.has(mid) and sides_ok(af, p):
			for k in af:
				if not (k in ["sides", "not_sides"]):
					out[k] = af[k]
	out["hotspots"] = (hub.get("hotspots", []) as Array).filter(func(hs: Dictionary) -> bool:
		return (String(hs.get("requires", "")) == "" or done.has(String(hs["requires"]))) \
			and (String(hs.get("until", "")) == "" or not done.has(String(hs["until"]))) and flags_ok(hs.get("flag", {}), p) \
			and sides_ok(hs, p))
	return out


## A hub "after" entry's, hotspot's or talk entry's "sides": {"<mission>": side} (that mission finished with this
## player on that side: Campaign.record's "side") and "not_sides" (not on it). The Fürth Line (a02-furth): a player who
## led the Machine keeps the Machine's City as the Clockmaker's hub; the guild's player moves to Fürth.
static func sides_ok(x: Dictionary, p: Dictionary) -> bool:
	var done: Dictionary = p.get("done", {})
	for mid in x.get("sides", {}):
		if String((done.get(mid, {}) as Dictionary).get("side", "")) != String(x["sides"][mid]):
			return false
	for mid in x.get("not_sides", {}):
		if String((done.get(mid, {}) as Dictionary).get("side", "")) == String(x["not_sides"][mid]):
			return false
	return true


## A hub hotspot's or talk entry's "flag": {"<mission>.<flag>": value, ...}: every one as a finished mission left it
## (the Brood prologue: the crate of eggs in the warehouse only if they were saved). {} holds.
static func flags_ok(f: Dictionary, p: Dictionary) -> bool:
	for fk in f:
		var pr := String(fk).split(".")
		if pr.size() != 2:
			return false
		var e: Dictionary = (p.get("done", {}) as Dictionary).get(pr[0], {})
		if str(e.get("flags", {}).get(pr[1], null)) != str(f[fk]):
			return false
	return true


## A hotspot pressed: the war table opens the missions, a person talks, a room shows its page (a stub for now).
static func _hotspot(main: Node, sl: Dictionary, hs: Dictionary, talk_box: PanelContainer, p: Dictionary) -> void:
	match String(hs.get("kind", "")):
		"war_table":
			if String(hs.get("map", "")) != "":
				map_skin = String(hs["map"])
				war_map(main)
			else:
				war_table(main)
		"talk":
			var tk: Dictionary = sl.get("hub", {}).get("talks", {}).get(String(hs.get("talk", "")), {})
			_talk(talk_box, tk, talk_lines(tk, p))
		"room":
			var rm: Dictionary = Campaign.index().get("rooms", {}).get(String(hs.get("room", "")), {})
			_talk(talk_box, {"name": String(rm.get("title", "")), "colour": 3}, [String(rm.get("text", ""))])


## What a person in the hub says now: the entry for the latest finished mission it lists ("after": a mission id,
## "" before any). So the talk changes after each mission.
static func talk_lines(tk: Dictionary, p: Dictionary) -> Array:
	var out: Array = []
	for e in tk.get("entries", []):
		var aft := String(e.get("after", ""))
		if (aft == "" or (p["done"] as Dictionary).has(aft)) and flags_ok(e.get("flag", {}), p) and sides_ok(e, p):
			out = e.get("lines", [])
	return out


static func _talk(box: PanelContainer, tk: Dictionary, lines: Array) -> void:
	for c in box.get_children():
		c.queue_free()
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	box.add_child(h)
	var por := StillView.Portrait.new()
	por.custom_minimum_size = Vector2(80, 80)
	por.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	por.set_speaker(String(tk.get("name", "")), Defs.colour_of(int(tk.get("colour", 1))), String(tk.get("portrait", "")))
	h.add_child(por)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	v.add_child(UiStyle.text(Loc.t(String(tk.get("name", ""))), 18, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_LEFT, true))
	var txt := _wrap("", 17)
	txt.name = "TalkText"
	txt.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	v.add_child(txt)
	var state := {"i": 0}
	var nb := Button.new()
	nb.name = "TalkNext"
	nb.focus_mode = Control.FOCUS_NONE
	nb.custom_minimum_size = Vector2(110, 50)
	nb.size_flags_vertical = Control.SIZE_SHRINK_END
	var show_line := func() -> void:
		txt.text = "..." if lines.is_empty() else Loc.t(String(lines[state["i"]]))
		nb.text = Loc.t("NEXT") if state["i"] < lines.size() - 1 else Loc.t("CLOSE")
	nb.pressed.connect(func() -> void:
		Sfx.play_any(["ui/click", "click"])
		if state["i"] < lines.size() - 1:
			state["i"] += 1
			show_line.call()
		else:
			box.visible = false)
	h.add_child(nb)
	show_line.call()
	box.visible = true


# ------------------------------------------------------------------ THE WAR MAP (war-map-v1, docs/war_map_v1.md)

## The war map page: the map (WarMap) with its views, the LEDGER, the LIST (the old war table) and a card for the pin
## picked: its mission, date and line, what came of it, and BRIEFING / WAR TABLE to play it (or what opens it).
static func war_map(main: Node) -> void:
	if not map_open:
		map_home = line
	map_open = true
	var pc: bool = Settings.pc()
	var box := _frame(main)
	var d := WarMapData.data()
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	box.add_child(top)
	var t := UiStyle.heading(Loc.t(String(d.get("title", "THE WAR MAP"))) + "  ·  " + Loc.t(String(d.get("act_title", ""))), 30 if pc else 22, UiStyle.TRIM)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.clip_text = true
	top.add_child(t)
	var holder := Control.new()
	holder.name = "WarMapHolder"
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(holder)
	var wm := WarMap.make(map_skin)
	wm.name = "WarMap"
	wm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wm.selected = map_pick
	if not map_cam.is_empty():
		wm.pending_cam = map_cam
	holder.add_child(wm)
	var keep_cam := func() -> void:
		map_cam = {"c": wm.center, "z": wm.zoom}
	# the views (THE WORLD, VIRGINIA, EUROPE, THE AMAZON)
	for v in d.get("views", []):
		var vid := String(v["id"])
		var b: Button = main._button(String(v["label"]), func() -> void: wm.show_view(vid))
		b.name = "View_" + vid
		b.custom_minimum_size = Vector2(0, 46 if pc else 56)
		b.add_theme_font_size_override("font_size", 15 if pc else 17)
		top.add_child(b)
	# the ledger: a fold-out panel over the map's left side
	var ledger := PanelContainer.new()
	ledger.name = "WarLedger"
	ledger.visible = false
	ledger.add_theme_stylebox_override("panel", UiStyle.box(Color(0.12, 0.09, 0.06, 0.95), UiStyle.TRIM, 2, 10, 14.0))
	ledger.anchor_bottom = 1.0
	ledger.offset_left = 10
	ledger.offset_top = 10
	ledger.offset_bottom = -10
	ledger.offset_right = 10 + (380 if pc else 470)
	holder.add_child(ledger)
	var lsc := ScrollContainer.new()
	lsc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ledger.add_child(lsc)
	var lv := VBoxContainer.new()
	lv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lv.add_theme_constant_override("separation", 8)
	lsc.add_child(lv)
	var zr := VBoxContainer.new()
	var leg := PanelContainer.new()
	var lb: Button = main._button("LEDGER", func() -> void:
		ledger.visible = not ledger.visible
		zr.visible = not ledger.visible
		leg.visible = not ledger.visible and leg.get_child(0).get_child_count() > 0)
	lb.name = "WarMap_Ledger"
	lb.custom_minimum_size = Vector2(0, 46 if pc else 56)
	top.add_child(lb)
	var lst: Button = main._button("LIST", func() -> void:
		keep_cam.call()
		war_table(main))
	lst.name = "WarMap_List"
	lst.custom_minimum_size = Vector2(0, 46 if pc else 56)
	top.add_child(lst)
	# zoom buttons, top left over the map
	zr.add_theme_constant_override("separation", 6)
	zr.position = Vector2(14, 14)
	holder.add_child(zr)
	for z in [["+", 1.5], ["−", 1.0 / 1.5]]:
		var zb: Button = main._button(String(z[0]), func() -> void: wm.zoom_by(float(z[1])))
		zb.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		zb.name = "Zoom_" + ("in" if float(z[1]) > 1 else "out")
		zb.custom_minimum_size = Vector2(46, 46) if pc else Vector2(62, 62)
		zb.add_theme_font_size_override("font_size", 24)
		zr.add_child(zb)
	# the legend: the holders on the map now
	leg.name = "WarLegend"
	leg.add_theme_stylebox_override("panel", UiStyle.box(Color(0.12, 0.09, 0.06, 0.82), UiStyle.TRIM_DIM, 1, 8, 8.0))
	leg.anchor_top = 1.0
	leg.anchor_bottom = 1.0
	leg.grow_vertical = Control.GROW_DIRECTION_BEGIN
	leg.offset_left = 14
	leg.offset_bottom = -14
	holder.add_child(leg)
	var lgv := VBoxContainer.new()
	lgv.add_theme_constant_override("separation", 2)
	leg.add_child(lgv)
	# the card for the pin picked
	var card := PanelContainer.new()
	card.name = "WarCard"
	card.visible = false
	card.add_theme_stylebox_override("panel", UiStyle.box(Color(0.11, 0.085, 0.06, 0.96), UiStyle.TRIM, 2, 10, 16.0))
	if pc:
		card.anchor_left = 1.0
		card.anchor_right = 1.0
		card.anchor_bottom = 1.0
		card.offset_left = -430
		card.offset_right = -10
		card.offset_top = 10
		card.offset_bottom = -10
	else:
		card.anchor_top = 0.42
		card.anchor_right = 1.0
		card.anchor_bottom = 1.0
		card.offset_left = 10
		card.offset_right = -10
		card.offset_bottom = -6
	holder.add_child(card)
	var fill := func() -> void:
		var stt: Dictionary = wm.st
		for c in lv.get_children():
			c.queue_free()
		lv.add_child(UiStyle.text(Loc.t("THE LEDGER"), 22, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_LEFT, true))
		lv.add_child(_wrap(Loc.t(String(d.get("act_title", ""))), 15, UiStyle.MUTED))
		var ls: Array = stt.get("ledger", [])
		if ls.is_empty():
			lv.add_child(_wrap(Loc.t("Nothing yet: the ledger fills as the missions are played."), 16, UiStyle.MUTED))
		for e in ls:
			var l := _wrap("-  " + WarMapData.ledger_text(e), 16 if pc else 19)
			l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			lv.add_child(l)
		for c in lgv.get_children():
			c.queue_free()
		var shown := {}
		for k in stt.get("regions", {}):
			shown[String(stt["regions"][k])] = true
		for h in WarMapData.HOLDERS:
			if h == "empire" or not shown.has(h):
				continue
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 6)
			var sw := ColorRect.new()
			var hc: Dictionary = WarMap.SKINS[wm.skin]["holders"][h]
			sw.color = Color(hc["fill"], 0.9) if h != "unknown" else hc["fill"]
			sw.custom_minimum_size = Vector2(16, 16)
			sw.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			row.add_child(sw)
			row.add_child(UiStyle.text(Loc.t(String(d.get("holders", {}).get(h, h))), 14 if pc else 16, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT))
			lgv.add_child(row)
		leg.visible = lgv.get_child_count() > 0
	fill.call()
	var show_card := func(mid: String) -> void:
		map_pick = mid
		keep_cam.call()
		for c in card.get_children():
			c.queue_free()
		card.visible = mid != ""
		if mid != "":
			_pin_card(main, card, mid, wm.st, pc, keep_cam)
			wm.free_rect = Rect2(0, 0, wm.size.x - 440, wm.size.y) if pc else Rect2(0, 0, wm.size.x, wm.size.y * 0.42)
			wm.bring_into_view.call_deferred(mid)
	wm.pin_tapped.connect(show_card)
	if map_pick != "":
		show_card.call(map_pick)
	var bot := HBoxContainer.new()
	bot.add_theme_constant_override("separation", 12)
	box.add_child(bot)
	var back: Button = main._button("BACK", func() -> void:
		map_cam = {}
		map_pick = ""
		map_open = false
		if map_home != "":
			line = map_home
		show(main))
	main._set_back(back)
	back.custom_minimum_size = Vector2(240, 52 if pc else 60)
	bot.add_child(back)
	var hint := _wrap(Loc.t("Drag to move the map, the wheel or a pinch to zoom; tap a seal for its mission.") if pc else
		Loc.t("Drag to move the map, pinch to zoom; tap a seal for its mission."), 14 if pc else 16, UiStyle.MUTED)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bot.add_child(hint)


## A pin's card: the mission (or the one still being written), its line, place and date, its state, what came of it
## (the ledger's lines of that mission) and the buttons to play it.
static func _pin_card(main: Node, card: PanelContainer, mid: String, stt: Dictionary, pc: bool, keep_cam: Callable) -> void:
	var pn := WarMapData.pin_of(mid)
	var ps: Dictionary = stt.get("pins", {}).get(mid, {"state": "planned"})
	var state := String(ps.get("state", "planned"))
	var built := state != "planned"
	var m: Dictionary = Campaign.mission(mid) if built else {}
	var lines_d: Dictionary = WarMapData.data().get("lines", {})
	var col: Color = WarMap.SKINS["parchment"]["lines"].get(String(pn.get("line", "")), UiStyle.TRIM)
	var outer: BoxContainer = VBoxContainer.new() if pc else HBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	card.add_child(outer)
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_child(sc)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 6)
	sc.add_child(v)
	var title := String(m.get("title", pn.get("title", mid)))
	var hl := UiStyle.heading(Loc.t(title), 26 if pc else 24, UiStyle.TRIM)
	hl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	hl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hl.name = "CardTitle"
	v.add_child(hl)
	v.add_child(UiStyle.text(Loc.t(String(lines_d.get(String(pn.get("line", "")), {}).get("name", ""))).to_upper(), 15 if pc else 17,
		col.lightened(0.45), HORIZONTAL_ALIGNMENT_LEFT, true))
	v.add_child(_wrap(Loc.t(String(pn.get("place", ""))) + "  ·  " + Loc.t(String(pn.get("date", ""))), 16 if pc else 18, UiStyle.MUTED))
	var after: Array = pn.get("after", [])
	if after.is_empty() and built:
		var sl := Campaign.storyline_of(mid)
		var i := (sl.get("missions", []) as Array).find(mid)
		if i > 0:
			after = [sl["missions"][i - 1]]
		elif String(sl.get("requires", "")) != "":
			after = [sl["requires"]]
	var after_t: Array = after.map(func(a) -> String:
		var am := Campaign.mission(String(a)) if not Campaign.storyline_of(String(a)).is_empty() else {}
		return Loc.t(String(am.get("title", WarMapData.pin_of(String(a)).get("title", a)))))
	var stxt := ""
	match state:
		"planned":
			stxt = Loc.t("Not written yet.") + (" " + Loc.t("Opens after: %s") % ", ".join(after_t) if not after_t.is_empty() else "")
		"locked":
			stxt = Loc.t("(locked)") + (" " + Loc.t("Opens after: %s") % ", ".join(after_t) if not after_t.is_empty() else "")
		"open":
			stxt = Loc.t("Open: ready to play.")
		"done":
			stxt = Loc.t("(won by %s)") % Loc.t(Campaign.side_name(m, String(ps.get("won_by", ""))))
	var sl2 := _wrap(stxt, 16 if pc else 18, UiStyle.GOOD if state in ["open", "done"] else UiStyle.MUTED)
	sl2.name = "CardState"
	sl2.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	v.add_child(sl2)
	if state in ["open", "done"]:
		v.add_child(_wrap(Loc.t(String(m.get("summary", ""))), 16 if pc else 18))
	var came := WarMapData.ledger_of(stt, mid)
	if not came.is_empty():
		v.add_child(UiStyle.text(Loc.t("WHAT CAME OF IT"), 15, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_LEFT, true))
		for e in came:
			var l := _wrap("-  " + WarMapData.ledger_text(e), 15 if pc else 17)
			l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			v.add_child(l)
	var bv := VBoxContainer.new()
	bv.add_theme_constant_override("separation", 8)
	if not pc:
		bv.custom_minimum_size.x = 260
	outer.add_child(bv)
	if state in ["open", "done"]:
		var sl := Campaign.storyline_of(mid)
		var go: Button = main._button("BRIEFING", func() -> void:
			keep_cam.call()
			line = String(sl["id"])
			pick = mid
			mode = "solo"
			solo_pick = ""
			briefing(main, mid))
		go.name = "Card_Briefing"
		UiStyle.primary(go)
		go.custom_minimum_size = Vector2(0, 56 if pc else 64)
		bv.add_child(go)
		if Campaign.modes_of(m).size() > 1:
			var wt: Button = main._button("CO-OP / VERSUS", func() -> void:
				keep_cam.call()
				line = String(sl["id"])
				pick = mid
				war_table(main))
			wt.name = "Card_Modes"
			wt.custom_minimum_size = Vector2(0, 50 if pc else 60)
			bv.add_child(wt)
	var cl: Button = main._button("CLOSE", func() -> void:
		map_pick = ""
		card.visible = false)
	cl.name = "Card_Close"
	cl.custom_minimum_size = Vector2(0, 46 if pc else 58)
	bv.add_child(cl)
