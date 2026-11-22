class_name WWPage
extends Control
## THE WORLD WAR's screens (docs/world_war_mode.md): the setup (your wars, a new war), the war's map with its top bar,
## the card of the chosen region or army, the turn banner, the battle question (FIGHT IT / AUTO-RESOLVE), the log, the
## help and the end. The rules are in WWWar; the computers' turns are WWAI's steps, shown one march at a time.

const STEP_WAIT := 0.18            # seconds between the computers' marches (a turn stays quick)
const WHO_CYCLE := ["you", "easy", "normal", "hard", "off"]
const WHO_LABEL := {"you": "YOU", "easy": "EASY COMPUTER", "normal": "NORMAL COMPUTER", "hard": "HARD COMPUTER", "off": "NOT IN THIS WAR"}
const WIN_LABEL := {"capitals": "TAKE THE ENEMY CAPITALS", "keys": "HOLD 8 OF THE 15 KEY REGIONS", "seasons": "THE MOST LAND AT THE LAST SEASON"}
const BIOME_WORDS := {
	"temperate": "Temperate land: good for everyone.",
	"cold": "Cold land: the Brood can't live here (its armies lose 30% a season, more in winter) and can't hold it.",
	"wet": "Wet land: the Clockwork rusts here (its armies lose 10% a season); the Brood fights well here.",
	"jungle": "Jungle: the Brood's home ground; the Clockwork rusts here.",
	"desert": "Desert: poor land for the Brood.",
}

static var setup := {"players": {"crown": "you", "clockwork": "normal", "brood": "normal"}, "win": "capitals",
	"seasons": WWRules.SEASON_LIMIT, "heroes": true}

var main: Node
var war: WWWar
var map: WWMap
var top_season: Label
var top_side: Label
var top_gold: Label
var end_btn: Button
var hint: Label
var card: PanelContainer
var card_box: VBoxContainer
var overlay: Control = null
var busy := false                  # a computer's turn under way (the player's buttons wait)
var _pending := {}                 # a battle waiting for the player's choice
var _after_battle := Callable()


# ------------------------------------------------------------------ the setup page

static func show_setup(m: Node) -> void:
	var root: Control = m._page()
	m._backdrop.visible = false
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.06, 0.05)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var pc: bool = Settings.pc()
	var sc := ScrollContainer.new()
	sc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(sc)
	var mc := MarginContainer.new()
	mc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for s in ["left", "right"]:
		mc.add_theme_constant_override("margin_" + s, 40 if pc else 24)
	for s in ["top", "bottom"]:
		mc.add_theme_constant_override("margin_" + s, 16)
	sc.add_child(mc)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	mc.add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	var t := UiStyle.heading("WORLD WAR", 38, UiStyle.TRIM)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(t)
	var help: Button = m._button("HOW TO PLAY", func() -> void: show_help(m, root))
	help.custom_minimum_size = Vector2(170, 46)
	head.add_child(help)
	var back: Button = m._button("BACK", func() -> void: m.show_menu())
	back.custom_minimum_size = Vector2(130, 46)
	head.add_child(back)
	m._set_back(back)
	var about := UiStyle.text(Loc.t("The Crown, the Clockwork and the Brood fight for the whole world, region by region. One turn is a season: march your armies, raise new ones, build, and fight every battle on the field or let it be decided at once. Not the campaign's story: a war of your own."), 16 if pc else 18, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	about.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(about)
	# your wars
	var wars := WWWar.saved_wars()
	if not wars.is_empty():
		box.add_child(UiStyle.heading("YOUR WARS", 22, UiStyle.TRIM))
		for wd in wars.slice(0, 6):
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 8)
			box.add_child(row)
			var sides: Array = []
			for f in wd["players"]:
				sides.append(Loc.t(WWRules.NAME[f]) + " (" + Loc.t(String(WHO_LABEL.get(String(wd["players"][f]), ""))).to_lower() + ")")
			var what := Loc.t("%s, season %d") % [WWRules.season_name(int(wd["season"])), int(wd["season"]) + 1]
			if String(wd["winner"]) != "":
				what += " · " + (Loc.t("won by %s") % Loc.t(WWRules.NAME.get(String(wd["winner"]), "no one")))
			var l := UiStyle.text(what + "\n" + ", ".join(sides), 14 if pc else 16, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			row.add_child(l)
			var path := String(wd["path"])
			var cont: Button = m._button("CONTINUE", func() -> void:
				var w := WWWar.load_from(path)
				if w:
					show_war(m, w))
			cont.custom_minimum_size = Vector2(150, 48)
			cont.name = "WW_Continue"
			UiStyle.primary(cont)
			row.add_child(cont)
			var nm := String(wd["name"])
			var del: Button = m._button("DELETE", func() -> void:
				m.ask("Delete this war for good?", "DELETE", func() -> void:
					WWWar.delete_war(nm)
					show_setup(m)))
			del.custom_minimum_size = Vector2(110, 48)
			row.add_child(del)
	# a new war
	box.add_child(UiStyle.heading("A NEW WAR", 22, UiStyle.TRIM))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)
	var note := UiStyle.text("", 15, UiStyle.BAD, HORIZONTAL_ALIGNMENT_LEFT)
	for f in WWRules.FACTIONS:
		var l := UiStyle.text(Loc.t(WWRules.NAME[f]) + "  ·  " + Loc.t(_capital_line(f)), 17 if pc else 19, WWRules.COLOUR[f].lightened(0.35), HORIZONTAL_ALIGNMENT_LEFT)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		grid.add_child(l)
		var b: Button = m._button(WHO_LABEL[setup["players"][f]], func() -> void: pass)
		b.name = "WW_Who_" + f
		b.custom_minimum_size = Vector2(250, 46)
		b.pressed.connect(func() -> void:
			var i := WHO_CYCLE.find(String(setup["players"][f]))
			setup["players"][f] = WHO_CYCLE[(i + 1) % WHO_CYCLE.size()]
			b.text = WHO_LABEL[setup["players"][f]])
		grid.add_child(b)
	var wl := UiStyle.text("HOW TO WIN", 17 if pc else 19, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	grid.add_child(wl)
	var wb: Button = m._button(WIN_LABEL[setup["win"]], func() -> void: pass)
	wb.custom_minimum_size = Vector2(250, 46)
	wb.pressed.connect(func() -> void:
		var i := WWRules.WIN_KINDS.find(String(setup["win"]))
		setup["win"] = WWRules.WIN_KINDS[(i + 1) % WWRules.WIN_KINDS.size()]
		wb.text = WIN_LABEL[setup["win"]])
	grid.add_child(wb)
	grid.add_child(UiStyle.text("THE LAST SEASON", 17 if pc else 19, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT))
	var sb: Button = m._button(_limit_label(int(setup["seasons"])), func() -> void: pass)
	sb.custom_minimum_size = Vector2(250, 46)
	sb.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	sb.pressed.connect(func() -> void:
		var i := WWRules.SEASON_CHOICES.find(int(setup["seasons"]))
		setup["seasons"] = WWRules.SEASON_CHOICES[(i + 1) % WWRules.SEASON_CHOICES.size()]
		sb.text = _limit_label(int(setup["seasons"])))
	grid.add_child(sb)
	grid.add_child(UiStyle.text("STORY HEROES", 17 if pc else 19, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT))
	var hb: Button = m._button("ON" if setup["heroes"] else "OFF", func() -> void: pass)
	hb.custom_minimum_size = Vector2(250, 46)
	hb.pressed.connect(func() -> void:
		setup["heroes"] = not bool(setup["heroes"])
		hb.text = "ON" if setup["heroes"] else "OFF")
	grid.add_child(hb)
	var expl := UiStyle.text(Loc.t("A war always ends at its last season: then the side holding the most land wins. Story heroes lead armies: Lord Fairleigh, Captain Ruggieri and Lieutenant Valadares for the Crown, Meister Hollweg for the Clockwork (+10% to the army each leads). The Brood has no heroes: its armies grow back in its swamps."), 14 if pc else 16, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	expl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(expl)
	box.add_child(note)
	var go: Button = m._button("START THE WAR", func() -> void:
		var n := 0
		for f in WWRules.FACTIONS:
			if String(setup["players"][f]) != "off":
				n += 1
		if n < 2:
			note.text = Loc.t("At least two sides must be in the war.")
			return
		var s := setup.duplicate(true)
		s["seed"] = randi()
		show_war(m, WWWar.make(s)))
	go.name = "WW_Start"
	go.custom_minimum_size = Vector2(260, 56)
	UiStyle.primary(go)
	box.add_child(go)


static func _capital_line(f: String) -> String:
	return {"crown": "capital Rome; forts, churches, markets", "clockwork": "capital Nuremberg; works and trade posts; rusts in the wet",
		"brood": "its Queen in the Amazon; nests and swamps; can't live in the cold"}[f]


static func _limit_label(n: int) -> String:
	if n <= 0:
		return Loc.t("NO LAST SEASON")
	return Loc.t("%d SEASONS (%d YEARS)") % [n, n / 4]


# ------------------------------------------------------------------ the war's page

static func show_war(m: Node, w: WWWar, note := "") -> WWPage:
	var root: Control = m._page()
	m._backdrop.visible = false
	var p := WWPage.new()
	p.main = m
	p.war = w
	p.name = "WorldWar"
	p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(p)
	p._build()
	# a battle the game was closed in the middle of: decided at once now
	if w.d.has("fighting"):
		var b: Dictionary = w.d["fighting"]
		w.d.erase("fighting")
		if not w.army(String(b.get("att", ""))).is_empty():
			note = String(w.resolve(b).get("text", ""))
	p.refresh()
	if note != "":
		p._toast(note)
	p._start_turn.call_deferred(note == "")
	return p


func _build() -> void:
	var pc: bool = Settings.pc()
	map = WWMap.new()
	map.war = war
	map.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(map)
	map.region_tapped.connect(_on_region)
	map.army_tapped.connect(_on_army)
	# the top bar
	var top := PanelContainer.new()
	top.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.PANEL, UiStyle.TRIM_DIM, 1, 0, 6.0))
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	add_child(top)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 10)
	top.add_child(bar)
	top_season = UiStyle.text("", 17 if pc else 19, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_LEFT, true)
	top_season.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	bar.add_child(top_season)
	top_side = UiStyle.text("", 17 if pc else 19, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT, true)
	top_side.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	bar.add_child(top_side)
	top_gold = UiStyle.text("", 15 if pc else 17, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	top_gold.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	top_gold.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_gold.clip_text = true
	bar.add_child(top_gold)
	var bh := 40 if pc else 50
	for it in [["-", func() -> void: map.zoom_by(1.0 / 1.4)], ["+", func() -> void: map.zoom_by(1.4)],
			["HELP", func() -> void: show_help(main, self)], ["LOG", func() -> void: _show_log()],
			["SAVE & LEAVE", func() -> void: _leave()]]:
		var b: Button = main._button(String(it[0]), it[1])
		b.custom_minimum_size = Vector2(44 if String(it[0]).length() == 1 else 0, bh)
		b.add_theme_font_size_override("font_size", 15 if pc else 17)
		b.name = "WW_" + String(it[0]).replace(" ", "").replace("&", "")
		bar.add_child(b)
		if String(it[0]) == "SAVE & LEAVE":
			main._set_back(b)          # (Esc and the phone's back: an open panel closes first, then SAVE & LEAVE)
	end_btn = main._button("END TURN", func() -> void: _end_turn())
	end_btn.custom_minimum_size = Vector2(150 if pc else 170, bh)
	end_btn.name = "WW_EndTurn"
	UiStyle.primary(end_btn)
	bar.add_child(end_btn)
	# the hint along the bottom
	var hp := PanelContainer.new()
	hp.add_theme_stylebox_override("panel", UiStyle.box(Color(0.08, 0.065, 0.05, 0.85), UiStyle.TRIM_DIM, 1, 6, 6.0))
	hp.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	hp.grow_vertical = Control.GROW_DIRECTION_BEGIN
	hp.offset_left = 10
	hp.offset_bottom = -10
	hp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hp)
	hint = UiStyle.text("", 15 if pc else 17, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(520 if pc else 460, 0)
	hint.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	hp.add_child(hint)
	_hint_panel = hp
	# the card (right on a computer, along the bottom on a phone)
	card = PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.PANEL, UiStyle.TRIM_DIM, 2, 10, 10.0))
	if pc:
		card.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
		card.offset_left = -360
		card.offset_right = -8
		card.offset_top = 64
		card.offset_bottom = -8
	else:
		card.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		card.anchor_top = 0.56
		card.offset_top = 0
		card.offset_left = 8
		card.offset_right = -8
		card.offset_bottom = -8
	add_child(card)
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card.add_child(sc)
	card_box = VBoxContainer.new()
	card_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_box.add_theme_constant_override("separation", 6)
	sc.add_child(card_box)
	card.visible = false


var _hint_panel: PanelContainer


func _process(_dt: float) -> void:
	# keep the hint clear of the card on a phone; the map knows what the card leaves free
	_update_free()


func _update_free() -> void:
	if _hint_panel and card:
		_hint_panel.visible = not (card.visible and not Settings.pc())
		var top := 56.0
		if card.visible and not Settings.pc():
			map.free_rect = Rect2(0, top, size.x, card.position.y - top)
		elif card.visible:
			map.free_rect = Rect2(0, top, card.position.x, size.y - top)
		else:
			map.free_rect = Rect2(0, top, size.x, size.y - top)


func refresh() -> void:
	var f := war.current()
	top_season.text = WWRules.season_name(int(war.d["season"])) + "  " + (Loc.t("(season %d of %d)") % [int(war.d["season"]) + 1, int(war.d["seasons"])] if int(war.d["seasons"]) > 0 else "")
	top_side.text = Loc.t("%s's turn") % Loc.t(WWRules.NAME[f])
	top_side.add_theme_color_override("font_color", WWRules.COLOUR[f].lightened(0.4))
	var inc := war.income(f)
	top_gold.text = Loc.t("Gold %d  ·  income %d, upkeep %d a season  ·  lands %d, key regions %d") % [war.gold(f), int(inc[1]), war.upkeep(f), war.regions_of(f).size(), war.key_count(f)]
	end_btn.disabled = busy or not war.is_human(f) or String(war.d["winner"]) != ""
	_update_hint()
	map.queue_redraw()


func _update_hint() -> void:
	var f := war.current()
	if String(war.d["winner"]) != "":
		hint.text = Loc.t("The war is over.")
	elif busy or not war.is_human(f):
		hint.text = Loc.t("%s is moving...") % Loc.t(WWRules.NAME[f])
	elif map.selected_army != "" and not map.targets.is_empty():
		hint.text = Loc.t("Tap a glowing region to march there (a dotted line is a sea crossing). Tap the army again to let it go.")
	elif map.selected_army != "":
		hint.text = Loc.t("This army has marched this season. Pick another army, or END TURN.")
	else:
		hint.text = Loc.t("Your armies are the discs with a gold ring. Tap one, then a glowing region to march. Tap a region of yours to build or raise soldiers. Then END TURN.")


# ------------------------------------------------------------------ the player's taps

func _on_army(aid: String) -> void:
	if busy or overlay != null:
		return
	var a := war.army(aid)
	if a.is_empty():
		return
	if map.selected_army == aid:
		_select("", String(a["at"]))
		return
	_select(aid, String(a["at"]))


func _on_region(rid: String) -> void:
	if busy or overlay != null:
		return
	if rid != "" and map.targets.has(rid) and map.selected_army != "":
		_march(map.selected_army, rid)
		return
	if rid == "":
		_select("", "")
		return
	# a region of the side playing with an army of its own that can still march: pick that army too
	var f := war.current()
	var aid := ""
	if war.is_human(f):
		for a in war.armies_at(rid, f):
			if not bool(a["moved"]):
				aid = String(a["id"])
				break
	_select(aid, rid)


func _select(aid: String, rid: String) -> void:
	map.selected_army = aid
	map.selected_region = rid
	map.targets = []
	var a := war.army(aid)
	if not a.is_empty() and String(a["f"]) == war.current() and war.is_human(war.current()):
		for m in war.moves_for(aid):
			map.targets.append(String(m["to"]))
	_fill_card(rid)
	refresh()
	_update_free()
	if rid != "" and not map.free_rect.grow(-70).has_point(map.town_screen(rid)):
		map.focus(rid, 1.0)


func _march(aid: String, to: String) -> void:
	var res := war.move(aid, to)
	match String(res.get("kind", "")):
		"battle":
			_ask_battle(res["battle"], func() -> void:
				_after_move())
			return
		"fought", "lost":
			_toast(String(res.get("text", "")))
		"refused":
			_toast(Loc.t(String(res.get("text", ""))))
	_after_move()


func _after_move() -> void:
	var w := war.check_win()
	_select("", map.selected_region)
	if w != "":
		_victory()


func _fill_card(rid: String) -> void:
	for c in card_box.get_children():
		c.queue_free()
	if rid == "":
		card.visible = false
		return
	card.visible = true
	var pc: bool = Settings.pc()
	var fs := 15 if pc else 17
	var r := WWRules.region(rid)
	var o := war.owner(rid)
	var f := war.current()
	var reg: Dictionary = war.d["regions"][rid]
	var head := HBoxContainer.new()
	card_box.add_child(head)
	var t := UiStyle.heading(Loc.t(String(r["name"])), 24, UiStyle.TRIM)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	head.add_child(t)
	var x: Button = main._button("X", func() -> void: _select("", ""))
	x.custom_minimum_size = Vector2(40, 36)
	head.add_child(x)
	var lines: Array = []
	var who := Loc.t(WWRules.NAME[o])
	var tags: Array = []
	for ff in war.d["factions"]:
		if war.alive(ff) and war.capital(ff) == rid:
			tags.append(Loc.t("capital"))
	if WWRules.is_key(rid):
		tags.append(Loc.t("key region"))
	if bool(r.get("port", false)):
		tags.append(Loc.t("port"))
	lines.append(Loc.t("Held by: %s") % who + ("  (" + ", ".join(tags) + ")" if not tags.is_empty() else ""))
	lines.append(Loc.t(BIOME_WORDS.get(war.biome_now(rid), "")))
	if o != "":
		lines.append(Loc.t("Worth %d: %d gold a season to %s.") % [WWRules.worth(rid), int(war.region_income(rid, o)), who])
		if rid != war.capital(o):
			lines.append(Loc.t("Unrest %d of 100 (from 40 it may rise and break free).") % int(reg["unrest"]))
		var bd := WWRules.building(o, String(reg["build"]))
		lines.append(Loc.t("Building: %s.") % (Loc.t(String(bd["name"])) if not bd.is_empty() else Loc.t("none")))
	else:
		lines.append(Loc.t("Worth %d. Free land, held by its own militia (strength %d).") % [WWRules.worth(rid), int(reg["guard"])])
	for l in lines:
		var lb := UiStyle.text(l, fs, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
		lb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lb.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		card_box.add_child(lb)
	# the armies here
	for a in war.armies_at(rid):
		card_box.add_child(_army_box(a, fs))
	if not war.is_human(f) or busy or String(war.d["winner"]) != "":
		return
	if o == f:
		# build
		if String(reg["build"]) == "":
			card_box.add_child(UiStyle.heading("BUILD (one a region)", 18, UiStyle.TRIM))
			for b in WWRules.BUILDINGS[f]:
				card_box.add_child(_action(Loc.t("%s  (%d gold)") % [Loc.t(String(b["name"])), int(b["cost"])], _build_words(b),
					war.build_problem(rid, String(b["id"])), func() -> void:
						war.build(rid, String(b["id"]))
						_fill_card(rid)
						refresh()))
		# recruit
		if war.is_muster(rid, f):
			card_box.add_child(UiStyle.heading("RAISE SOLDIERS", 18, UiStyle.TRIM))
			for rg in WWRules.REGIMENTS[f]:
				var units: Dictionary = rg["units"]
				var desc := ""
				for k in units:
					desc = Loc.t("%d %s, strength %d.") % [int(units[k]), Loc.t(WWRules.UNIT_NAME[k]), WWRules.regiment_cost(rg)]
				card_box.add_child(_action(Loc.t("%s  (%d gold)") % [Loc.t(String(rg["name"])), WWRules.regiment_cost(rg)], desc,
					war.recruit_problem(rid, String(rg["id"])), func() -> void:
						war.recruit(rid, String(rg["id"]))
						_select(map.selected_army, rid)))
		else:
			var nb := UiStyle.text(Loc.t("Soldiers are raised at your capital and in regions with your %s.") % Loc.t(String(WWRules.BUILDINGS[f][0]["name"])), fs - 1, UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT)
			nb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			card_box.add_child(nb)


func _army_box(a: Dictionary, fs: int) -> Control:
	var v := VBoxContainer.new()
	var f := String(a["f"])
	var head := UiStyle.text(Loc.t("%s's army: strength %d") % [Loc.t(WWRules.NAME[f]), war.army_value(a)] + ("  " + "★".repeat(int(a["vet"])) if int(a["vet"]) > 0 else ""), fs + 1, WWRules.COLOUR[f].lightened(0.45), HORIZONTAL_ALIGNMENT_LEFT, true)
	head.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	v.add_child(head)
	var parts: Array = []
	for k in a["units"]:
		parts.append("%d %s" % [int(a["units"][k]), Loc.t(WWRules.UNIT_NAME.get(k, k))])
	var heroes: Array = war.heroes_with(String(a["id"])).map(func(h) -> String: return Loc.t(String(WWRules.hero(h).get("name", h))))
	var body := ", ".join(parts)
	if int(a["vet"]) > 0:
		body += "\n" + Loc.t("Veterans: +%d%% strength.") % int(a["vet"] * 10)
	if not heroes.is_empty():
		body += "\n" + Loc.t("Led by %s.") % ", ".join(heroes)
		for h in war.heroes_with(String(a["id"])):
			body += "\n  " + Loc.t(String(WWRules.hero(h).get("gift", "")))
	var mine := f == war.current() and war.is_human(f)
	if mine:
		body += "\n" + (Loc.t("It has marched this season.") if bool(a["moved"]) else Loc.t("It can march: tap a glowing region."))
	var l := UiStyle.text(body, fs, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	v.add_child(l)
	if mine and not busy:
		var row := HBoxContainer.new()
		v.add_child(row)
		if String(a["id"]) != map.selected_army and not bool(a["moved"]):
			var pick: Button = main._button("MARCH WITH THIS ARMY", func() -> void: _select(String(a["id"]), String(a["at"])))
			pick.add_theme_font_size_override("font_size", fs)
			row.add_child(pick)
		var sp: Button = main._button("SPLIT IN TWO", func() -> void:
			war.split(String(a["id"]))
			_select(map.selected_army, String(a["at"])))
		sp.add_theme_font_size_override("font_size", fs)
		sp.disabled = WWRules.units_count(a["units"]) < 2
		sp.tooltip_text = Loc.t("Half of each kind of soldier forms a second army here.")
		row.add_child(sp)
	return v


func _build_words(b: Dictionary) -> String:
	var w: Array = []
	if bool(b.get("muster", false)):
		w.append(Loc.t("soldiers can be raised here"))
	if int(b.get("defence", 0)) > 0:
		w.append(Loc.t("+%d to its defence") % int(b["defence"]))
	if int(b.get("calm", 0)) > 0:
		w.append(Loc.t("-%d unrest a season") % int(b["calm"]))
	if float(b.get("income", 0.0)) > 0.0:
		w.append(Loc.t("+%d%% income") % int(round(float(b["income"]) * 100)))
	if bool(b.get("trade", false)):
		w.append(Loc.t("+10%% more for each Trade Post next to it"))
	if bool(b.get("swamp", false)):
		w.append(Loc.t("the land becomes wet: the Clockwork rusts in it"))
	if WWRules.MEND_AT.get(war.current(), []).has(String(b["id"])):
		w.append(Loc.t("armies here get back 10% a season"))
	var txt := ", ".join(w)
	return (txt.substr(0, 1).to_upper() + txt.substr(1) + ".") if txt != "" else ""


func _action(title: String, words: String, problem: String, cb: Callable) -> Control:
	var v := VBoxContainer.new()
	var b: Button = main._button(title, cb)
	b.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	b.custom_minimum_size = Vector2(0, 42 if Settings.pc() else 50)
	b.add_theme_font_size_override("font_size", 15 if Settings.pc() else 17)
	b.disabled = problem != ""
	v.add_child(b)
	var l := UiStyle.text(words + ("  " + Loc.t(problem) if problem != "" else ""), 13 if Settings.pc() else 15, UiStyle.MUTED if problem == "" else UiStyle.BAD, HORIZONTAL_ALIGNMENT_LEFT)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	v.add_child(l)
	return v


# ------------------------------------------------------------------ turns

## A side's turn begins: the banner for a player (what came in, what happened), or the computer plays.
func _start_turn(banner := true) -> void:
	if not is_inside_tree():
		return
	refresh()
	if String(war.d["winner"]) != "":
		_victory()
		return
	var f := war.current()
	if war.is_human(f):
		busy = false
		refresh()
		if not banner:
			return
		var lines: Array = []
		var humans := war.players().values().filter(func(x) -> bool: return String(x) == "you").size()
		if humans > 1:
			lines.append(Loc.t("Pass the device to the player of %s.") % Loc.t(WWRules.NAME[f]))
		for e in war.d.get("report", []):
			lines.append(WWWar.line_text(e))
		for e in _news():
			lines.append(e)
		if int(war.d["season"]) == 0:
			lines.append(Loc.t("New to this? Press HELP at the top at any time."))
		_banner(Loc.t("%s: %s's turn") % [WWRules.season_name(int(war.d["season"])), Loc.t(WWRules.NAME[f])], lines,
			WWRules.COLOUR[f], func() -> void:
				var caps := war.armies_of(f).filter(func(a) -> bool: return String(a["at"]) == war.capital(f))
				map.focus(war.capital(f), 1.8)
				_select(String(caps[0]["id"]) if not caps.is_empty() else "", war.capital(f)))
	else:
		busy = true
		refresh()
		_ai_next()


## What happened since this side last played (the log's newer lines, at most 10).
func _news() -> Array:
	var f := war.current()
	var seen := int(war.d.get("seen_" + f, 0))
	var out: Array = []
	for e in war.d["log"]:
		if int(e.get("n", 0)) > seen:
			out.append(WWWar.line_text(e["line"]))
	war.d["seen_" + f] = int(war.d.get("log_n", 0))
	return out.slice(maxi(0, out.size() - 10))


func _ai_next() -> void:
	if not is_inside_tree() or String(war.d["winner"]) != "":
		busy = false
		refresh()
		if String(war.d["winner"]) != "":
			_victory()
		return
	var r := WWAI.step(war)
	match String(r.get("kind", "")):
		"done":
			_next_side()
			return
		"move":
			map.selected_region = String(r.get("to", ""))
			if String(r.get("kind_move", "")) == "battle":
				_ask_battle(r["battle"], func() -> void: _ai_later())
				return
			if String(r.get("kind_move", "")) == "fought" and _involves_human(r.get("battle", {})):
				_toast(String(r.get("text", "")))
			refresh()
			_ai_later()
		_:
			_ai_next.call_deferred()


func _ai_later() -> void:
	if not is_inside_tree():
		return
	get_tree().create_timer(STEP_WAIT).timeout.connect(_ai_next)


func _involves_human(b: Dictionary) -> bool:
	return not b.is_empty() and (war.is_human(String(b.get("att_f", ""))) or war.is_human(String(b.get("def_f", ""))))


func _end_turn() -> void:
	if busy or overlay != null:
		return
	_select("", "")
	_next_side()


func _next_side() -> void:
	war.d["report"] = war.end_turn()
	war.save()
	map.selected_region = ""
	_start_turn()


func _leave() -> void:
	if overlay != null and is_instance_valid(overlay):
		_close_overlay()
		return
	var hp := find_child("WW_Help", false, false)
	if hp:
		hp.queue_free()
		return
	if busy:
		return
	war.save()
	show_setup(main)


# ------------------------------------------------------------------ battles

## A battle with a player's army on one side: FIGHT IT (the skirmish) or AUTO-RESOLVE.
func _ask_battle(b: Dictionary, then: Callable) -> void:
	_pending = b
	_after_battle = then
	var s := war.strengths(b)
	var att := war.army(String(b["att"]))
	var to := String(b["region"])
	var af := String(b["att_f"])
	var df := String(b["def_f"])
	var lines: Array = []
	lines.append(Loc.t("%s attacks %s, held by %s.") % [Loc.t(WWRules.NAME[af]), Loc.t(String(WWRules.region(to)["name"])), Loc.t(WWRules.NAME[df])])
	lines.append(Loc.t("Attacker: %s (strength %d with its bonuses).") % [_units_words(att["units"]), int(s["att"])])
	var du := {}
	for did in b["defs"]:
		for k in war.army(String(did))["units"]:
			du[k] = int(du.get(k, 0)) + int(war.army(String(did))["units"][k])
	lines.append(Loc.t("Defender: %s, and the region's guard %d (strength %d with its bonuses).") % [_units_words(du), int(s["guard"]), int(s["def"])])
	var me := af if war.is_human(af) else df
	var chance := _chance(float(s["att"]), float(s["def"]))
	if me == df:
		chance = 100 - chance
	lines.append(Loc.t("If it is decided at once, your side wins about %d times in 100.") % chance)
	lines.append(Loc.t("FIGHT IT: play the battle yourself on a %s map with exactly these armies; the survivors go back to the world map.") % Loc.t(war.biome_now(to)))
	_banner(Loc.t("BATTLE OF %s") % Loc.t(String(WWRules.region(to)["name"])).to_upper(), lines, Color(0.75, 0.3, 0.2), Callable(),
		[["AUTO-RESOLVE", func() -> void:
			var res := war.resolve(_pending)
			_pending = {}
			_toast(String(res.get("text", "")))
			var cb := _after_battle
			_after_battle = Callable()
			refresh()
			if war.check_win() != "":
				_victory()
				return
			cb.call()],
		["FIGHT IT", func() -> void:
			var wb := WWBattle.new()
			wb.war = war
			wb.battle = _pending
			_pending = {}
			war.d["resume_ai"] = not war.is_human(war.current())
			wb.begin(main)]])


static func _chance(A: float, D: float) -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var won := 0
	for i in 400:
		if A * (1.0 + rng.randf_range(-WWRules.LUCK, WWRules.LUCK)) > D * (1.0 + rng.randf_range(-WWRules.LUCK, WWRules.LUCK)):
			won += 1
	return int(round(won / 4.0))


func _units_words(u: Dictionary) -> String:
	var parts: Array = []
	for k in u:
		parts.append("%d %s" % [int(u[k]), Loc.t(WWRules.UNIT_NAME.get(k, k))])
	return ", ".join(parts) if not parts.is_empty() else Loc.t("no army")


# ------------------------------------------------------------------ overlays

func _close_overlay() -> void:
	if overlay != null and is_instance_valid(overlay):
		overlay.queue_free()
	overlay = null


## A panel over the map: a title, lines, and buttons [[label, callable]] (just OK when none).
func _banner(title: String, lines: Array, col: Color, on_ok: Callable, buttons: Array = []) -> void:
	_close_overlay()
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.45)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	overlay = shade
	var cc := CenterContainer.new()
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.add_child(cc)
	var pan := PanelContainer.new()
	pan.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.PANEL, col, 3, 12, 18.0))
	pan.custom_minimum_size = Vector2(minf(620, size.x - 40), 0)
	cc.add_child(pan)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	pan.add_child(v)
	var t := UiStyle.heading(title, 26, col.lightened(0.45))
	t.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(t)
	var sc := ScrollContainer.new()
	var rows := 0
	var per := int((pan.custom_minimum_size.x - 40) / (8.5 if Settings.pc() else 9.5))
	for l in lines:
		rows += 1 + String(l).length() / maxi(20, per)
	sc.custom_minimum_size = Vector2(0, mini(rows * (24 if Settings.pc() else 27) + 12, int(size.y * 0.55)))
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(sc)
	var lv := VBoxContainer.new()
	lv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(lv)
	for l in lines:
		var lb := UiStyle.text(String(l), 16 if Settings.pc() else 18, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
		lb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lb.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		lv.add_child(lb)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", 10)
	v.add_child(row)
	if buttons.is_empty():
		buttons = [["OK", on_ok]]
	for it in buttons:
		var cb: Callable = it[1]
		var b: Button = main._button(String(it[0]), func() -> void:
			_close_overlay()
			if cb.is_valid():
				cb.call())
		b.name = "WW_Btn_" + String(it[0]).replace(" ", "").replace("-", "")
		b.custom_minimum_size = Vector2(170, 52)
		if it == buttons[buttons.size() - 1]:
			UiStyle.primary(b)
		row.add_child(b)


func _toast(text: String) -> void:
	if text.strip_edges() == "":
		return
	var l := UiStyle.text(text, 18 if Settings.pc() else 20, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_CENTER, true)
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiStyle.box(Color(0.1, 0.08, 0.06, 0.92), UiStyle.TRIM, 2, 8, 10.0))
	p.add_child(l)
	p.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	p.offset_top = 70
	p.custom_minimum_size = Vector2(minf(560, size.x - 40), 0)
	p.offset_left = -p.custom_minimum_size.x * 0.5
	p.offset_right = p.custom_minimum_size.x * 0.5
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(p)
	var tw := p.create_tween()
	tw.tween_interval(2.6)
	tw.tween_property(p, "modulate:a", 0.0, 0.6)
	tw.tween_callback(p.queue_free)


func _show_log() -> void:
	var lines: Array = []
	var lg: Array = war.d["log"]
	for i in range(lg.size() - 1, maxi(-1, lg.size() - 30), -1):
		lines.append(WWRules.season_name(int(lg[i]["s"])) + ": " + WWWar.line_text(lg[i]["line"]))
	_banner(Loc.t("WHAT HAPPENED (newest first)"), lines, UiStyle.TRIM, Callable())


func _victory() -> void:
	busy = false
	refresh()
	var wf := String(war.d["winner"])
	var lines: Array = []
	for f in war.d["order"]:
		lines.append(Loc.t("%s: %d regions, %d key regions%s.") % [Loc.t(WWRules.NAME[f]), war.regions_of(f).size(), war.key_count(f), "" if war.alive(f) else Loc.t(" (fallen)")])
	var title := Loc.t("%s WINS THE WAR") % Loc.t(WWRules.NAME.get(wf, "No one")).to_upper() if wf != "none" else Loc.t("NO ONE WINS THE WAR")
	_banner(title, lines, WWRules.COLOUR.get(wf, UiStyle.TRIM), Callable(),
		[["LOOK AT THE MAP", func() -> void: pass], ["BACK TO THE WARS", func() -> void: show_setup(main)]])


# ------------------------------------------------------------------ help (plain words)

const HELP := [
	["WHAT THIS IS", "A war for the whole world. Each side holds regions; each turn is one season. On your turn you march your armies, raise soldiers and put up buildings, then press END TURN. The computers then play their turns quickly."],
	["ARMIES", "An army is a disc on the map in its side's colour; the number is its strength (the worth of its soldiers in gold). A gold ring means it can still march this season. Tap it, then tap a glowing region next to it. A dotted line is a sea lane between two ports: armies may sail along it (one crossing in ten meets a storm and loses a fifth of its men)."],
	["BATTLES", "Marching into a region held by another side, or by free militia, starts a battle. If both sides have armies and one is yours, you choose: FIGHT IT (play it yourself as a skirmish on a map of that kind of land, with exactly the armies on the world map, and the survivors are carried back) or AUTO-RESOLVE (decided at once: strength against strength, the defender's bonus, the land, a little luck). The loser falls back to a region of its own next door, or is lost. Winners become veterans: +10% strength a rank, up to three."],
	["DEFENCE", "A defender gets +20% (+35% at a capital), and the region's own guard: its worth x 100, a capital 1,500 more, and a Fort, Works or Nest adds 400. Capitals are hard to take."],
	["MONEY", "Each region pays gold every season (its worth x 50, less where your side lives badly). The more land you hold, the less each new region adds. Armies cost 8% of their worth a season to keep (the Clockwork 10%: it must be wound), and regions far from your capital cost more."],
	["UNREST", "Regions far from your capital, or in a climate your side hates, grow restless; a big empire is restless everywhere. Above 40 a region may rise and become free again. An army standing there, a Church, a Regulator or a Nest calm it."],
	["THE SIDES", "THE CROWN (purple) holds Rome; it fights a little better in temperate land; Churches calm its lands, Forts raise its soldiers. THE CLOCKWORK (red) holds Nuremberg; it RUSTS in wet land and the jungle (10% a season), and its Trade Posts earn more side by side. THE BROOD (green) is the creatures of its Queen in the Amazon; it CAN'T LIVE IN THE COLD (30% a season, and it can't hold cold land), it fights well in the jungle and the wetlands, and its Swamps turn land wet."],
	["WINNING", "A side whose capital is taken is out of the war (for the Brood: the Queen is dead). The war ends when one side is left, or (by the setup) when a side holds 8 of the 15 key regions (the diamonds; capitals are stars), and always at the last season: then the most land wins."],
	["SAVING", "The war is saved at the end of every turn. SAVE & LEAVE goes back to your wars; CONTINUE there brings it back."],
]


static func show_help(m: Node, parent: Control) -> void:
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.6)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.name = "WW_Help"
	parent.add_child(shade)
	var mc := MarginContainer.new()
	mc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right", "top", "bottom"]:
		mc.add_theme_constant_override("margin_" + s, 30 if Settings.pc() else 14)
	shade.add_child(mc)
	var pan := PanelContainer.new()
	pan.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.PANEL, UiStyle.TRIM, 2, 12, 18.0))
	mc.add_child(pan)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	pan.add_child(v)
	var head := HBoxContainer.new()
	v.add_child(head)
	var t := UiStyle.heading("HOW THE WORLD WAR WORKS", 28, UiStyle.TRIM)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	head.add_child(t)
	var close: Button = m._button("CLOSE", func() -> void: shade.queue_free())
	close.custom_minimum_size = Vector2(130, 46)
	close.name = "WW_HelpClose"
	head.add_child(close)
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(sc)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 4)
	sc.add_child(body)
	for it in HELP:
		body.add_child(UiStyle.heading(String(it[0]), 19, UiStyle.TRIM))
		var l := UiStyle.text(Loc.t(String(it[1])), 16 if Settings.pc() else 18, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.add_child(l)
