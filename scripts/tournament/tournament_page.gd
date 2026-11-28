class_name TournamentPage
extends Control
## TOURNAMENTS, THE PAGES (docs/tournament.md): the list of tournaments (made here or joined), MAKE ONE (its rules),
## and a tournament's own page: BRACKET (drawn, BracketView), STANDINGS, SCHEDULE, PLAYERS, RULES; a match's card
## (its games, maps, factions, replays, bans and picks, PLAY YOUR MATCH, WATCH, the organiser's tools); the
## champion's screen. Three kinds of tournament (Tournament.MODES): ONLINE (players join by code through the relay, the
## organiser's game keeps the desk: TournamentNet), OFFLINE / LAN (the organiser types the results), ALL COMPUTER
## (computer players; each game watched or played quickly, or every game one after another).

const MAX_FIELD := Tournament.MAX_PLAYERS
const POLL := 10.0
## The computer plans offered for a computer entrant (AI.strategies_for gives the faction's own).
const LEVELS := ["easy", "normal", "hard", "brutal"]
## A game played quickly: the game runs this many times faster, its picture hidden.
const QUICK_SPEED := 4.0

var main: Node
var t: Tournament
var role := ""                 # "organiser", "player" (joined by code), "viewer"
var me := -1                   # my player id in t (-1: none; a team tournament: my team's)
var mi := 0                    # my place in my team (0 in a 1v1 tournament)
var key := ""
var tab := "bracket"
var net: TournamentNet         # a player's calls to the desk
var _box: VBoxContainer
var _bv: BracketView
var _status: Label
var _poll := POLL
var _overlay: Control
static var last_tab := "bracket"
static var toast := ""
## The map picker's filters (MAKE A TOURNAMENT), kept while the page is open again.
static var pool_players := "all"
static var pool_source := "all"
static var pool_search := ""


## "Crown", or a team's "Crown + Brood" (Tournament keeps a team's factions as "crown,brood").
static func fac_text(f: String) -> String:
	if f == "":
		return ""
	return " + ".join(Array(f.split(",")).map(func(x) -> String: return Loc.t(String(x).capitalize())))


# ================================================================== entry points (Main)

## The main menu's TOURNAMENTS.
static func show_home(m: Node) -> void:
	var p := _make(m)
	p._home()


## Back to a tournament (after a game, or from the list).
static func show_tournament(m: Node, tid: String, note := "") -> void:
	var p := _make(m)
	toast = note
	if not p._open_id(tid):
		p._home()


static func _make(m: Node) -> TournamentPage:
	var root: Control = m._page()
	m._backdrop.visible = false
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.06, 0.05)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var p := TournamentPage.new()
	p.name = "TournamentPage"
	p.main = m
	p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(p)
	return p


func _pc() -> bool:
	return Settings.pc()


func _fs(n: int) -> int:
	return n if _pc() else n + 3


func _clear() -> VBoxContainer:
	for c in get_children():
		c.queue_free()
	_bv = null
	var mc := MarginContainer.new()
	mc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right"]:
		mc.add_theme_constant_override("margin_" + s, 28 if _pc() else 16)
	for s in ["top", "bottom"]:
		mc.add_theme_constant_override("margin_" + s, 12)
	add_child(mc)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 8)
	mc.add_child(_box)
	return _box


func _btn(txt: String, cb: Callable, w := 0.0) -> Button:
	var b: Button = main._button(txt, cb)
	b.custom_minimum_size = Vector2(w, 50 if _pc() else 60)
	b.add_theme_font_size_override("font_size", _fs(17))
	return b


func _label(txt: String, sz := 16, col := UiStyle.TEXT, wrap := true) -> Label:
	var l := UiStyle.text(Loc.t(txt), _fs(sz), col, HORIZONTAL_ALIGNMENT_LEFT)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


func _head(title: String, back: Callable) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	_box.add_child(h)
	var tl := UiStyle.heading(Loc.t(title), 34 if _pc() else 30, UiStyle.TRIM)
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tl.clip_text = true
	tl.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	h.add_child(tl)
	var b := _btn("BACK", back, 130)
	b.name = "Tour_Back"
	h.add_child(b)
	main._set_back(b)
	return h


func _scroll() -> VBoxContainer:
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_box.add_child(sc)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 8)
	sc.add_child(v)
	return v


func _relay_set() -> bool:
	return not Settings.relay_url.contains("YOURNAME") and Settings.relay_url.strip_edges() != ""


# ================================================================== the list

func _home() -> void:
	t = null
	_clear()
	_head("TOURNAMENTS", func() -> void: main.show_menu())
	var v := _scroll()
	v.add_child(_label("Run a whole tournament inside the game: brackets, best-of series, map vetoes, faction rules, check-in, results reported by the games themselves, replays and spectators. Online, offline or between computer players.", 16, UiStyle.MUTED))
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 10)
	row.add_theme_constant_override("v_separation", 8)
	v.add_child(row)
	var mk := _btn("MAKE A TOURNAMENT", func() -> void: _create(), 280)
	mk.name = "Tour_Make"
	UiStyle.primary(mk)
	row.add_child(mk)
	# join by code
	var jv := VBoxContainer.new()
	v.add_child(jv)
	jv.add_child(UiStyle.heading(Loc.t("JOIN ONE"), 22, UiStyle.TRIM))
	var jr := HFlowContainer.new()
	jr.add_theme_constant_override("h_separation", 8)
	jv.add_child(jr)
	var code := LineEdit.new()
	code.name = "Tour_Code"
	code.placeholder_text = Loc.t("TOURNAMENT CODE")
	code.max_length = 6
	code.custom_minimum_size = Vector2(220, 52)
	UiStyle.touch_text(code, "TOURNAMENT CODE")
	jr.add_child(code)
	var nm := LineEdit.new()
	nm.name = "Tour_Name"
	nm.placeholder_text = Loc.t("YOUR NAME")
	nm.max_length = 24
	nm.custom_minimum_size = Vector2(220, 52)
	UiStyle.touch_text(nm, "YOUR NAME")
	jr.add_child(nm)
	var team := LineEdit.new()
	team.name = "Tour_TeamName"
	team.placeholder_text = Loc.t("TEAM (team tournaments)")
	team.max_length = 24
	team.custom_minimum_size = Vector2(240, 52)
	UiStyle.touch_text(team, "TEAM (team tournaments)")
	jr.add_child(team)
	var fac := OptionButton.new()
	fac.custom_minimum_size = Vector2(170, 52)
	for f in ["random", "crown", "clockwork", "brood"]:
		fac.add_item(Loc.t(f.capitalize()))
	jr.add_child(fac)
	var note := _label("", 15, UiStyle.BAD)
	var join := _btn("JOIN", func() -> void:
		var c := code.text.strip_edges().to_upper()
		if c.length() < 5:
			note.text = Loc.t("Type the code the organiser gave you.")
			return
		if nm.text.strip_edges() == "":
			note.text = Loc.t("Type your name.")
			return
		if not _relay_set():
			note.text = Loc.t("Set the relay address on the ONLINE page first.")
			return
		_join(c, nm.text.strip_edges(), ["random", "crown", "clockwork", "brood"][fac.selected], note, team.text.strip_edges()), 140)
	join.name = "Tour_Join"
	jr.add_child(join)
	var look := _btn("WATCH", func() -> void:
		var c := code.text.strip_edges().to_upper()
		if c.length() < 5 or not _relay_set():
			note.text = Loc.t("Type the code the organiser gave you.")
			return
		_join(c, "", "random", note), 140)
	jr.add_child(look)
	jv.add_child(note)
	# a tournament code (export) brought in
	var iv := HFlowContainer.new()
	iv.add_theme_constant_override("h_separation", 8)
	v.add_child(iv)
	var imp := LineEdit.new()
	imp.placeholder_text = Loc.t("PASTE A TOURNAMENT FILE CODE (TOUR1:...)")
	imp.custom_minimum_size = Vector2(420, 50)
	iv.add_child(imp)
	var ib := _btn("OPEN IT", func() -> void:
		var tt := Tournament.import_code(imp.text)
		if tt == null:
			note.text = Loc.t("That is not a tournament code.")
			return
		tt.save()
		_open(tt, "organiser"), 160)
	iv.add_child(ib)
	# the tournaments on this device
	var mine := Tournament.saved()
	var joined := TournamentNet.joined_list()
	if not mine.is_empty():
		v.add_child(UiStyle.heading(Loc.t("YOUR TOURNAMENTS"), 22, UiStyle.TRIM))
		for e in mine.slice(0, 20):
			var tt: Tournament = e["t"]
			v.add_child(_list_row(tt, func() -> void: _open(tt, "organiser"), func() -> void:
				main.ask("Delete this tournament?", "DELETE", func() -> void:
					DirAccess.remove_absolute(String(e["path"]))
					_home())))
	if not joined.is_empty():
		v.add_child(UiStyle.heading(Loc.t("TOURNAMENTS YOU JOINED"), 22, UiStyle.TRIM))
		for r in joined.slice(0, 20):
			var copy: Tournament = Tournament.from_dict(r.get("copy", {})) if r.get("copy", {}) is Dictionary and r.get("copy", {}).has("matches") else null
			if copy == null:
				continue
			var tid := String(r["tid"])
			v.add_child(_list_row(copy, func() -> void: _open_joined(tid), func() -> void:
				DirAccess.remove_absolute("user://tournaments/joined/%s.json" % tid)
				_home()))


func _list_row(tt: Tournament, open: Callable, del: Callable) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var st: String = {"signup": "sign-up open", "running": "under way", "done": "over"}.get(String(tt.d["state"]), "")
	var what := "%s  ·  %s %s  ·  %d %s  ·  %s" % [String(tt.d["name"]), Loc.t(Tournament.TYPE_NAME[tt.team_size()].split(" (")[0]),
		Loc.t(Tournament.FORMAT_NAME[tt.d["format"]]), tt.players().size(), Loc.t("teams") if tt.team_size() > 1 else Loc.t("players"), Loc.t(st)]
	if tt.done():
		what += "  ·  " + Loc.t("champion: %s") % tt.pname(int(tt.d["champion"]))
	var l := _label(what, 16)
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	row.add_child(l)
	row.add_child(_btn("OPEN", open, 120))
	var d := _btn("DELETE", del, 120)
	row.add_child(d)
	return row


# ================================================================== making one

var _form := {}


func _create() -> void:
	_clear()
	_head("MAKE A TOURNAMENT", func() -> void: _home())
	var v := _scroll()
	var f := {"name": "My tournament", "mode": "online", "format": "double", "bo": 3, "bo_final": 3, "maps": Tournament.DEFAULT_MAPS.duplicate(),
		"map_rule": "veto", "loser_picks": true, "factions": "series", "seeding": "random", "checkin": false, "groups": 2, "advance": 2,
		"swiss_rounds": 0, "time_limit": 0, "level": "hard", "team_size": 1, "team_rule": "fixed"}
	if not _form.is_empty() and _form.has("team_size"):
		f = _form          # (back from the map picker's filters: the form as it was)
	_form = f
	var nm := LineEdit.new()
	nm.text = Loc.t(String(f["name"]))
	nm.max_length = 40
	nm.custom_minimum_size = Vector2(360, 50)
	nm.text_changed.connect(func(s: String) -> void: f["name"] = s)
	v.add_child(_row("NAME", nm))
	v.add_child(_row("KIND", _choice(Tournament.MODES.map(func(x) -> String: return Tournament.MODE_NAME[x]), Tournament.MODES, f, "mode",
		func() -> void: _refill_pool())))
	var ty := _choice(Tournament.TEAM_SIZES.map(func(x) -> String: return Tournament.TYPE_NAME[x]), Tournament.TEAM_SIZES, f, "team_size",
		func() -> void:
			_refill_pool()
			if _team_row:
				_team_row.visible = int(f["team_size"]) > 1)
	ty.name = "Tour_Type"
	v.add_child(_row("TYPE", ty))
	_team_row = _row("TEAMS", _choice(Tournament.TEAM_RULES.map(func(x) -> String: return Tournament.TEAM_RULE_NAME[x]), Tournament.TEAM_RULES, f, "team_rule"))
	_team_row.visible = int(f["team_size"]) > 1
	v.add_child(_team_row)
	v.add_child(_row("FORMAT", _choice(Tournament.FORMATS.map(func(x) -> String: return Tournament.FORMAT_NAME[x]), Tournament.FORMATS, f, "format")))
	v.add_child(_row("SERIES", _choice(["Best of 1", "Best of 3", "Best of 5", "Best of 7"], [1, 3, 5, 7], f, "bo")))
	v.add_child(_row("THE FINAL", _choice(["Best of 1", "Best of 3", "Best of 5", "Best of 7"], [1, 3, 5, 7], f, "bo_final")))
	v.add_child(_row("MAPS", _choice(Tournament.MAP_RULES.map(func(x) -> String: return Tournament.MAP_RULE_NAME[x]), Tournament.MAP_RULES, f, "map_rule")))
	v.add_child(_row("NEXT MAP", _choice(["The loser of a game picks the next map", "Random"], [true, false], f, "loser_picks")))
	v.add_child(_row("FACTIONS", _choice(Tournament.FACTION_RULES.map(func(x) -> String: return Tournament.FACTION_RULE_NAME[x]), Tournament.FACTION_RULES, f, "factions")))
	v.add_child(_row("SEEDING", _choice(["Random", "By hand (the players' list order)"], ["random", "manual"], f, "seeding")))
	v.add_child(_row("CHECK-IN", _choice(["No", "Yes: only those who check in play"], [false, true], f, "checkin")))
	v.add_child(_row("TIME LIMIT", _choice(["None", "15 minutes", "20 minutes", "30 minutes"], [0, 900, 1200, 1800], f, "time_limit")))
	v.add_child(_row("GROUPS", _choice(["2 groups", "4 groups", "8 groups"], [2, 4, 8], f, "groups")))
	v.add_child(_row("OUT OF EACH GROUP", _choice(["Top 2", "Top 1", "Top 4"], [2, 1, 4], f, "advance")))
	v.add_child(_label("The time limit: at the bell, the side clearly ahead (its income earned plus twice its army, at least 10% more than the other's) wins the game; with no clear leader the game is played again (at most twice, then the higher score wins). Groups apply only to 'Groups, then playoffs'.", 14, UiStyle.MUTED))
	v.add_child(_label("Teams: a team's score at the time limit is its players' added together. In a team tournament every player keeps the faction it joined with.", 14, UiStyle.MUTED))
	# the map pool (job tournament-formats: grouped by players, filtered by where the map comes from, searched, cards)
	v.add_child(UiStyle.heading(Loc.t("MAP POOL"), 22, UiStyle.TRIM))
	_pool_box = VBoxContainer.new()
	_pool_box.add_theme_constant_override("separation", 8)
	v.add_child(_pool_box)
	_refill_pool()
	var go := _btn("MAKE IT", func() -> void:
		var opts := f.duplicate(true)
		var nm2 := String(opts["name"]).strip_edges()
		opts.erase("name")
		# (only the maps that hold the type's players go into the pool)
		opts["maps"] = (opts["maps"] as Array).filter(func(x) -> bool: return _pool_ok(String(x), opts))
		if (opts["maps"] as Array).is_empty():
			opts["maps"] = _pool_ids().filter(func(x) -> bool: return _pool_ok(String(x), opts)).slice(0, 6)
		var tt := Tournament.make(nm2 if nm2 != "" else "Tournament", opts)
		_form = {}
		tt.save()
		_open(tt, "organiser"), 240)
	go.name = "Tour_MakeIt"
	UiStyle.primary(go)
	v.add_child(go)


func _row(title: String, c: Control) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	var l := UiStyle.text(Loc.t(title), _fs(16), UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT, true)
	l.custom_minimum_size = Vector2(230 if _pc() else 200, 0)
	h.add_child(l)
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(c)
	return h


func _choice(labels: Array, values: Array, f: Dictionary, k: String, then := Callable()) -> OptionButton:
	var o := OptionButton.new()
	o.custom_minimum_size = Vector2(320, 46)
	for i in labels.size():
		o.add_item(Loc.t(String(labels[i])))
		if values[i] == f[k]:
			o.select(i)
	o.item_selected.connect(func(i: int) -> void:
		f[k] = values[i]
		if then.is_valid():
			then.call())
	return o


# ------------------------------------------------------------------ the map pool picker (job tournament-formats)

var _pool_box: VBoxContainer
var _team_row: Control
const POOL_PLAYERS := [["all", "ALL"], ["2", "2 PLAYERS"], ["4", "4 PLAYERS"], ["more", "6-8 PLAYERS"]]
const POOL_SOURCES := [["all", "ALL"], ["named", "BUILT-IN"], ["classic", "CLASSIC"], ["custom", "YOUR MAPS"]]


## Every map the pool can hold: the built-in (named) maps, the classic generated ones, the player's own editor maps
## (an online tournament can't use those: the other players don't have the file).
func _pool_ids() -> Array:
	var out: Array = []
	for id in MapData.NAMED.keys():
		out.append(String(id))
	for id in MapGen.MAPS.keys():
		out.append(String(id))
	for nm in MapGen.custom_names():
		if (MapGen.load_custom(nm).get("starts", []) as Array).size() >= 2:
			out.append("custom:" + nm)
	return out


static func pool_source_of(id: String) -> String:
	if id.begins_with("custom:"):
		return "custom"
	return "named" if MapData.NAMED.has(id) else "classic"


static func pool_group_of(id: String) -> String:
	var n := MapGen.max_players(id)
	return "2" if n <= 2 else ("4" if n <= 4 else "more")


## Can this tournament (its form `f`) use the map? It must hold both sides; your own maps only offline.
func _pool_ok(id: String, f: Dictionary) -> bool:
	if not Tournament.map_holds(id, int(f.get("team_size", 1))):
		return false
	return not (id.begins_with("custom:") and String(f.get("mode", "")) == "online")


## THE MAP'S PICTURE on a card (one function, so the map-previews job's shared MapPreview can take its place: today it
## is the skirmish lobby's own picture, Main.make_map_preview, with the start spots this type would use).
func map_picture(id: String, ts: int) -> Control:
	var sl: Array = []
	for i in 2 * ts:
		sl.append({"side": 0 if i < ts else 1, "colour": i, "who": "easy", "faction": "crown"})
	var c: Control = main.make_map_preview(id, sl)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


func _refill_pool() -> void:
	if _pool_box == null or not is_instance_valid(_pool_box):
		return
	for c in _pool_box.get_children():
		c.queue_free()
	var f := _form
	var ts := int(f.get("team_size", 1))
	# the filters: players, where from, a search
	var fr := HFlowContainer.new()
	fr.add_theme_constant_override("h_separation", 6)
	fr.add_theme_constant_override("v_separation", 6)
	_pool_box.add_child(fr)
	for e in POOL_PLAYERS:
		var b := _btn(e[1], func() -> void:
			pool_players = e[0]
			_refill_pool(), 140)
		b.name = "Tour_PoolPl_" + String(e[0])
		if pool_players == e[0]:
			UiStyle.chosen(b)
		fr.add_child(b)
	var fr2 := HFlowContainer.new()
	fr2.add_theme_constant_override("h_separation", 6)
	fr2.add_theme_constant_override("v_separation", 6)
	_pool_box.add_child(fr2)
	for e in POOL_SOURCES:
		var b := _btn(e[1], func() -> void:
			pool_source = e[0]
			_refill_pool(), 140)
		b.name = "Tour_PoolSrc_" + String(e[0])
		if pool_source == e[0]:
			UiStyle.chosen(b)
		fr2.add_child(b)
	var se := LineEdit.new()
	se.name = "Tour_PoolSearch"
	se.placeholder_text = Loc.t("SEARCH A MAP")
	se.text = pool_search
	se.custom_minimum_size = Vector2(240, 50)
	se.text_submitted.connect(func(x: String) -> void:
		pool_search = x
		_refill_pool())
	fr2.add_child(se)
	fr2.add_child(_btn("FIND", func() -> void:
		pool_search = se.text
		_refill_pool(), 100))
	var shown: Array = _pool_ids().filter(func(id: String) -> bool:
		if pool_players != "all" and pool_group_of(id) != pool_players:
			return false
		if pool_source != "all" and pool_source_of(id) != pool_source:
			return false
		var q := pool_search.strip_edges().to_lower()
		return q == "" or MapGen.display_name(id).trim_prefix("custom:").to_lower().contains(q) or id.to_lower().contains(q))
	var picked: Array = (f["maps"] as Array).filter(func(x) -> bool: return _pool_ok(String(x), f))
	var sum := _label(Loc.t("%d maps in the pool. A %s tournament needs maps that hold %d players; a bigger map uses only the start spots it needs.") % [picked.size(),
		Loc.t(Tournament.TYPE_NAME[ts].split(" (")[0]), 2 * ts], 15, UiStyle.MUTED)
	sum.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_pool_box.add_child(sum)
	var ar := HFlowContainer.new()
	ar.add_theme_constant_override("h_separation", 6)
	_pool_box.add_child(ar)
	ar.add_child(_btn("ADD ALL SHOWN", func() -> void:
		for id in shown:
			if _pool_ok(String(id), f) and not (f["maps"] as Array).has(id):
				f["maps"].append(id)
		_refill_pool(), 220))
	ar.add_child(_btn("CLEAR THE POOL", func() -> void:
		f["maps"] = []
		_refill_pool(), 220))
	# the cards, grouped by players
	for grp in [["2", "2-PLAYER MAPS"], ["4", "4-PLAYER MAPS"], ["more", "MAPS FOR 6-8 PLAYERS"]]:
		var ids: Array = shown.filter(func(id: String) -> bool: return pool_group_of(id) == grp[0])
		if ids.is_empty():
			continue
		ids.sort_custom(func(a: String, b: String) -> bool: return MapGen.display_name(a) < MapGen.display_name(b))
		_pool_box.add_child(UiStyle.heading(Loc.t(grp[1]), 18, UiStyle.TRIM))
		var grid := HFlowContainer.new()
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 8)
		_pool_box.add_child(grid)
		for id in ids:
			grid.add_child(_pool_card(String(id), f, ts))
	if shown.is_empty():
		_pool_box.add_child(_label("No map matches these filters.", 15, UiStyle.MUTED))


## One map's card: its picture with the start spots this type uses, its name, players, size and where it comes from;
## a tap puts it in the pool or takes it out. A map that can't hold the type (or a map of yours online) is greyed.
func _pool_card(id: String, f: Dictionary, ts: int) -> Control:
	var ok := _pool_ok(id, f)
	var on := ok and (f["maps"] as Array).has(id)
	var b := Button.new()
	b.name = "Tour_Pool_" + id.replace(":", "_")
	var w := 190.0 if _pc() else 170.0
	b.custom_minimum_size = Vector2(w, 214)
	b.toggle_mode = true
	b.button_pressed = on
	b.disabled = not ok
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_stylebox_override("normal", UiStyle.box(Color(0.12, 0.1, 0.08), UiStyle.TRIM_DIM, 1, 8, 6.0))
	b.add_theme_stylebox_override("hover", UiStyle.box(Color(0.16, 0.13, 0.1), UiStyle.TRIM, 1, 8, 6.0))
	b.add_theme_stylebox_override("pressed", UiStyle.box(Color(0.2, 0.17, 0.08), UiStyle.GOOD, 3, 8, 6.0))
	b.add_theme_stylebox_override("hover_pressed", UiStyle.box(Color(0.22, 0.19, 0.1), UiStyle.GOOD, 3, 8, 6.0))
	b.add_theme_stylebox_override("disabled", UiStyle.box(Color(0.08, 0.07, 0.06), UiStyle.TRIM_DIM, 1, 8, 6.0))
	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.offset_left = 6
	vb.offset_right = -6
	vb.offset_top = 6
	vb.offset_bottom = -6
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", 2)
	b.add_child(vb)
	var pic := map_picture(id, ts if ok else 1)
	pic.custom_minimum_size = Vector2(0, 118)
	pic.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if not ok:
		pic.modulate = Color(1, 1, 1, 0.35)
	vb.add_child(pic)
	var nm := UiStyle.text(MapGen.display_name(id).trim_prefix("custom:") if not id.begins_with("custom:") else id.substr(7), _fs(15),
		UiStyle.GOOD if on else (UiStyle.TEXT if ok else UiStyle.MUTED), HORIZONTAL_ALIGNMENT_LEFT, true)
	nm.clip_text = true
	nm.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(nm)
	var sz := MapGen.size_of(id)
	var src: String = {"named": "built-in", "classic": "classic", "custom": "your map"}[pool_source_of(id)]
	var info := "%d %s · %dx%d · %s" % [MapGen.max_players(id), Loc.t("players"), sz.x, sz.y, Loc.t(src)]
	if not ok:
		info = Loc.t("online: your maps can't be sent") if Tournament.map_holds(id, ts) else Loc.t("holds %d players") % MapGen.max_players(id)
	var il := UiStyle.text(info, _fs(12), UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	il.clip_text = true
	il.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	il.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(il)
	b.toggled.connect(func(pr: bool) -> void:
		if pr and not (f["maps"] as Array).has(id):
			f["maps"].append(id)
		elif not pr:
			f["maps"].erase(id)
		_refill_pool.call_deferred())
	return b


# ================================================================== a tournament

func _open_id(tid: String) -> bool:
	var path := "user://tournaments/%s.json" % tid
	if FileAccess.file_exists(path):
		var tt := Tournament.load_from(path)
		if tt:
			_open(tt, "organiser")
			return true
	if not TournamentNet.joined_load(tid).is_empty():
		_open_joined(tid)
		return true
	return false


func _open(tt: Tournament, r: String) -> void:
	t = tt
	role = r
	me = int(t.d.get("org_pid", -1)) if r == "organiser" else me
	if r == "organiser" and me >= 0:
		key = String(t.d.get("org_key", t.player(me).get("key", "")))
		var mk := t.member_by_key(key)
		if not mk.is_empty():
			me = int(mk[0])
			mi = int(mk[1])
	if r == "organiser" and t.d["mode"] == "online" and _relay_set():
		_desk_for(t)
	tab = last_tab
	_draw_tour()


func _open_joined(tid: String) -> void:
	var rec := TournamentNet.joined_load(tid)
	t = Tournament.from_dict(rec.get("copy", {}))
	role = "player" if int(rec.get("me", -1)) >= 0 else "viewer"
	me = int(rec.get("me", -1))
	mi = int(rec.get("mi", 0))
	key = String(rec.get("key", ""))
	_ensure_net()
	net.me = me
	net.mi = mi
	net.key = key
	net.t = t
	tab = last_tab
	_draw_tour()
	_call({"t": "tj"})


func _join(code: String, nm: String, fac: String, note: Label, team := "") -> void:
	_ensure_net()
	var rec := TournamentNet.joined_load(code)
	net.me = int(rec.get("me", -1))
	net.mi = int(rec.get("mi", 0))
	net.key = String(rec.get("key", ""))
	note.text = Loc.t("Calling the desk...")
	note.add_theme_color_override("font_color", UiStyle.MUTED)
	net.answered.connect(func(ok: bool, why: String) -> void:
		if not is_inside_tree():
			return
		if ok and net.t:
			t = net.t
			me = net.me
			mi = net.mi
			key = net.key
			role = "player" if me >= 0 else "viewer"
			toast = why if not why.begins_with("ok") else ""
			_draw_tour()
		else:
			note.text = Loc.t(why)
			note.add_theme_color_override("font_color", UiStyle.BAD), CONNECT_ONE_SHOT)
	net.call_desk(Settings.relay_url, code, {"t": "tj", "name": nm, "fac": fac, "team": team})


func _ensure_net() -> void:
	if net == null:
		net = TournamentNet.new()
		net.name = "TourCalls"
		add_child(net)


## The organiser's desk (kept on Main, so it stays open while the organiser plays or watches a game).
func _desk_for(tt: Tournament) -> void:
	var dk: TournamentNet = main.get("tour_desk")
	if dk and is_instance_valid(dk) and dk.t and String(dk.t.d["id"]) == String(tt.d["id"]):
		t = dk.t           # (the desk's copy is the live one)
		return
	if dk and is_instance_valid(dk):
		dk.close_desk()
		dk.queue_free()
	dk = TournamentNet.new()
	dk.name = "TourDesk"
	main.add_child(dk)
	main.set("tour_desk", dk)
	dk.open_desk(Settings.relay_url, tt)


func _desk() -> TournamentNet:
	var dk: TournamentNet = main.get("tour_desk")
	if dk and is_instance_valid(dk) and t and dk.t == t:
		return dk
	return null


func _process(delta: float) -> void:
	if t == null:
		return
	var dk := _desk()
	if dk and not dk.updated.is_connected(_on_desk):
		dk.updated.connect(_on_desk)
	if role != "organiser" and net and not net.busy():
		_poll -= delta
		if _poll <= 0.0:
			_poll = POLL
			_call({"t": "tj"}, false)
	if _status and is_instance_valid(_status):
		var s := ""
		if dk:
			s = dk.status
		elif net:
			s = net.status
		if s != "" and _status.text != Loc.t(s):
			_status.text = Loc.t(s)


func _on_desk() -> void:
	if is_inside_tree() and not is_instance_valid(_overlay):
		_draw_tour()


func _save() -> void:
	if role == "organiser":
		t.save()


## A player's word to the desk (an organiser who plays answers it at once).
func _call(msg: Dictionary, redraw := true) -> void:
	if role == "organiser":
		var dk := _desk()
		var m := msg.duplicate()
		m["pid"] = me
		m["key"] = key
		var why := ""
		if dk:
			why = dk.handle(m)
		else:
			var tmp := TournamentNet.new()
			tmp.t = t
			why = tmp.handle(m)
			tmp.free()
		_save()
		if redraw:
			toast = why if not why.begins_with("ok") and why != "taken" else ""
			_draw_tour()
		return
	_ensure_net()
	if net.busy():
		return
	net.answered.connect(func(ok: bool, why: String) -> void:
		if not is_inside_tree():
			return
		if ok and net.t:
			var changed := t == null or int(net.t.d.get("rev", 0)) != int(t.d.get("rev", 0))
			t = net.t
			me = net.me
			mi = net.mi
			if redraw or changed:
				if why != "" and not why.begins_with("ok") and why != "taken":
					toast = why
				if not is_instance_valid(_overlay):
					_draw_tour()
		elif redraw:
			toast = why
			_draw_tour(), CONNECT_ONE_SHOT)
	net.call_desk(Settings.relay_url, String(t.d["id"]), msg)


func _draw_tour() -> void:
	if t == null:
		_home()
		return
	_clear()
	_head(String(t.d["name"]), func() -> void: _home())
	# the line under the title: format, code, state
	var info := HFlowContainer.new()
	info.add_theme_constant_override("h_separation", 14)
	_box.add_child(info)
	var line := "%s  ·  %s  ·  %s  ·  %s" % [Loc.t(Tournament.TYPE_NAME[t.team_size()].split(" (")[0]), Loc.t(Tournament.FORMAT_NAME[t.d["format"]]),
		Loc.t("Best of %d") % int(t.d["bo"]), Loc.t(Tournament.MODE_NAME[t.d["mode"]])]
	if t.d["mode"] == "online":
		line += "  ·  " + Loc.t("CODE %s") % String(t.d["id"])
	var il := _label(line, 16, UiStyle.TEXT, false)
	il.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	info.add_child(il)
	if t.d["mode"] == "online":
		var cp := _btn("COPY CODE", func() -> void: DisplayServer.clipboard_set(String(t.d["id"])), 150)
		info.add_child(cp)
	_status = _label("", 14, UiStyle.MUTED)
	_box.add_child(_status)
	if toast != "":
		var tl := _label(toast, 16, UiStyle.BAD)
		_box.add_child(tl)
		toast = ""
	# my next match, plainly
	if me >= 0 and not t.done():
		for m in t.matches_of(me):
			if m["state"] == "ready" or m["state"] == "live":
				var other := t.pname(int(m["b"] if int(m["a"]) == me else m["a"]))
				var nb := _btn(Loc.t("YOUR MATCH: against %s  ›") % other, func() -> void: _open_match(int(m["id"])))
				nb.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
				UiStyle.primary(nb)
				_box.add_child(nb)
				break
	# the tabs
	var tabs := HFlowContainer.new()
	tabs.add_theme_constant_override("h_separation", 6)
	_box.add_child(tabs)
	for tb in [["bracket", "BRACKET"], ["standings", "STANDINGS"], ["schedule", "SCHEDULE"], ["players", "PLAYERS"], ["rules", "RULES"]]:
		var b := _btn(tb[1], func() -> void:
			tab = tb[0]
			last_tab = tab
			_draw_tour(), 150)
		b.name = "Tour_Tab_" + String(tb[0])
		if tab == tb[0]:
			UiStyle.chosen(b)
		tabs.add_child(b)
	if t.done():
		var ch := _btn("THE CHAMPION", func() -> void: _champion(), 200)
		UiStyle.primary(ch, Color("#8a6a1f"))
		tabs.add_child(ch)
	match tab:
		"bracket":
			_tab_bracket()
		"standings":
			_tab_standings()
		"schedule":
			_tab_schedule()
		"players":
			_tab_players()
		"rules":
			_tab_rules()


func _tab_bracket() -> void:
	if t.d["state"] == "signup":
		_box.add_child(_label("The bracket is drawn when the organiser starts the tournament. Until then players join on the PLAYERS tab.", 17, UiStyle.MUTED))
		_tab_players()
		return
	var holder := Control.new()
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.custom_minimum_size = Vector2(0, 300)
	_box.add_child(holder)
	_bv = BracketView.new()
	_bv.name = "Tour_Bracket"
	_bv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	holder.add_child(_bv)
	_bv.set_tournament(t, me)
	_bv.match_pressed.connect(_open_match)
	var zr := HBoxContainer.new()
	zr.add_theme_constant_override("separation", 6)
	zr.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	zr.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	zr.offset_right = -8
	zr.offset_top = 8
	holder.add_child(zr)
	for z in [["+", 1.25], ["-", 0.8]]:
		var zb := _btn(String(z[0]), func() -> void: _bv.zoom_by(float(z[1])), 52)
		zr.add_child(zb)
	zr.add_child(_btn("FIT", func() -> void: _bv.fit(), 80))
	if t.d["mode"] == "computer" and role == "organiser" and not t.done():
		var ar := HFlowContainer.new()
		ar.add_theme_constant_override("h_separation", 8)
		_box.add_child(ar)
		var all := _btn("PLAY EVERY GAME QUICKLY", func() -> void: _computer_next(true, true), 320)
		all.name = "Tour_PlayAll"
		UiStyle.primary(all)
		ar.add_child(all)
		ar.add_child(_btn("WATCH THE NEXT GAME", func() -> void: _computer_next(false, false), 300))


func _tab_standings() -> void:
	var v := _scroll()
	if t.d["state"] == "signup":
		v.add_child(_label("Nothing played yet.", 17, UiStyle.MUTED))
		return
	if t.d["format"] in ["robin", "swiss"]:
		_table(v, t.standings(), "")
	elif t.d["format"] == "groups":
		for gi in int(t.d["groups"]):
			_table(v, t.standings(gi), "GROUP %s" % char(65 + gi))
		if t.d.has("playoffs"):
			_places(v)
	else:
		_places(v)
	# the factions' record in the games played so far
	var by := {}
	for g in t.all_games():
		for s in [["a", "fa"], ["b", "fb"]]:
			for f in String(g[s[1]]).split(","):
				if f == "":
					continue
				if not by.has(f):
					by[f] = [0, 0]
				by[f][0 if g["win"] == s[0] else 1] += 1
	if not by.is_empty():
		v.add_child(UiStyle.heading(Loc.t("THE FACTIONS' GAMES"), 20, UiStyle.TRIM))
		for f in by:
			var l := _label("%s: %d %s, %d %s" % [Loc.t(String(f).capitalize()), by[f][0], Loc.t("won"), by[f][1], Loc.t("lost")], 16)
			l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			v.add_child(l)


func _table(v: VBoxContainer, rows: Array, title: String) -> void:
	if title != "":
		v.add_child(UiStyle.heading(Loc.t(title.split(" ")[0]) + (" " + title.split(" ")[1] if title.contains(" ") else ""), 20, UiStyle.TRIM))
	var g := GridContainer.new()
	g.columns = 6 if t.d["format"] != "swiss" else 7
	g.add_theme_constant_override("h_separation", 18)
	v.add_child(g)
	var heads := ["#", "PLAYER", "WON", "LOST", "GAMES", "DIFF"]
	if t.d["format"] == "swiss":
		heads.append("BUCHHOLZ")
	for h in heads:
		g.add_child(UiStyle.text(Loc.t(h), _fs(15), UiStyle.TRIM, HORIZONTAL_ALIGNMENT_LEFT, true))
	for r in rows:
		var p := t.player(int(r["id"]))
		var cells := [str(r["place"]), "%s (%s)" % [p.get("name", "?"), fac_text(String(p.get("faction", "")))], str(r["w"]), str(r["l"]),
			"%d-%d" % [r["gw"], r["gl"]], "%+d" % (int(r["gw"]) - int(r["gl"]))]
		if t.d["format"] == "swiss":
			cells.append(str(r["buch"]))
		for c in cells:
			var l := UiStyle.text(String(c), _fs(15), UiStyle.GOOD if int(r["id"]) == me else UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
			l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			g.add_child(l)


func _places(v: VBoxContainer) -> void:
	v.add_child(UiStyle.heading(Loc.t("FINAL PLACES") if t.done() else Loc.t("KNOCKED OUT SO FAR"), 20, UiStyle.TRIM))
	if t.placings().is_empty():
		v.add_child(_label("Nobody is out yet.", 16, UiStyle.MUTED))
	for pl in t.placings():
		var p := t.player(int(pl["id"]))
		var l := _label("%d.  %s  (%s)" % [int(pl["place"]), p.get("name", "?"), fac_text(String(p.get("faction", "")))], 16,
			UiStyle.GOOD if int(pl["id"]) == me else UiStyle.TEXT)
		l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		v.add_child(l)


func _tab_schedule() -> void:
	var v := _scroll()
	var groups := [["PLAY NOW", ["ready", "live"]], ["WAITING FOR PLAYERS", ["wait"]], ["PLAYED", ["done"]]]
	for gr in groups:
		var ms: Array = (t.d["matches"] as Array).filter(func(m) -> bool: return (gr[1] as Array).has(m["state"]) and not m.get("skip", false) and not (m.get("bye", false) and int(m["winner"]) == Tournament.NONE))
		if ms.is_empty():
			continue
		v.add_child(UiStyle.heading(Loc.t(gr[0]), 20, UiStyle.TRIM))
		for m in ms.slice(0, 80):
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 8)
			var sc := t.score(m)
			var txt := "%s:  %s  %d - %d  %s" % [Loc.t(t.match_label(m)), t.pname(int(m["a"])), sc[0], sc[1], t.pname(int(m["b"]))]
			if m.get("bye", false):
				txt = "%s:  %s  (%s)" % [Loc.t(t.match_label(m)), t.pname(int(m["winner"])), Loc.t("a bye")]
			if String(m.get("dispute", "")) != "":
				txt += "  ·  " + Loc.t("DISPUTED")
			var l := _label(txt, 16, UiStyle.TEXT, false)
			l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			row.add_child(l)
			row.add_child(_btn("OPEN", func() -> void: _open_match(int(m["id"])), 110))
			v.add_child(row)


func _tab_players() -> void:
	var v := _scroll()
	var org := role == "organiser"
	var signup: bool = t.d["state"] == "signup"
	var teams := t.team_size() > 1 and (not signup or String(t.d.get("team_rule", "fixed")) == "fixed")
	if teams:
		v.add_child(UiStyle.heading(Loc.t("TEAMS (%d of %d)") % [t.players().size(), MAX_FIELD], 22, UiStyle.TRIM))
		if signup:
			v.add_child(_label(Loc.t("A %s tournament: %d players a team. Players join a team by typing its name when they join (the first one makes it).") % [Loc.t(Tournament.TYPE_NAME[t.team_size()].split(" (")[0]), t.team_size()], 15, UiStyle.MUTED))
	else:
		v.add_child(UiStyle.heading(Loc.t("PLAYERS (%d of %d)") % [t.players().size(), MAX_FIELD], 22, UiStyle.TRIM))
		if signup and t.team_size() > 1:
			v.add_child(_label(Loc.t("A %s tournament with drawn teams: everyone signs up alone; the teams of %d are drawn when the tournament starts.") % [Loc.t(Tournament.TYPE_NAME[t.team_size()].split(" (")[0]), t.team_size()], 15, UiStyle.MUTED))
	if signup and t.d["mode"] == "online":
		v.add_child(_label("Players join from TOURNAMENTS > JOIN with the code %s and their name. Keep this page open (or the game running) while they join: your game is the tournament's desk." % t.d["id"], 15, UiStyle.MUTED))
	for p in t._by_seed():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		var who := Loc.t("person") if p["who"] == "human" else "%s %s" % [Loc.t(String(p["who"]).capitalize()), Loc.t(AI.STRATEGIES.get(String(p["plan"]), {}).get("name", String(p["plan"])))]
		var txt := "%d.  %s  ·  %s  ·  %s" % [int(p["seed"]), p["name"], fac_text(String(p["faction"])), who]
		if p.has("members"):
			txt = "%d.  %s  (%d/%d)" % [int(p["seed"]), p["name"], (p["members"] as Array).size(), t.team_size()]
		if t.d["checkin"] and signup:
			txt += "  ·  " + (Loc.t("checked in") if p["checked"] else Loc.t("not checked in"))
		if p["dropped"]:
			txt += "  ·  " + Loc.t("left")
		var l := _label(txt, 16, UiStyle.GOOD if int(p["id"]) == me else UiStyle.TEXT, false)
		l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		row.add_child(l)
		var pid := int(p["id"])
		if org and signup:
			if t.d["seeding"] == "manual":
				row.add_child(_btn("▲", func() -> void:
					t.move_seed(pid, -1)
					_save()
					_draw_tour(), 50))
				row.add_child(_btn("▼", func() -> void:
					t.move_seed(pid, 1)
					_save()
					_draw_tour(), 50))
			if t.d["checkin"]:
				row.add_child(_btn("CHECK IN" if not p["checked"] else "UNDO", func() -> void:
					t.check_in(pid, not p["checked"])
					_save()
					_draw_tour(), 130))
			row.add_child(_btn("REMOVE", func() -> void:
				t.remove_player(pid)
				_save()
				_draw_tour(), 120))
		elif org and not p["dropped"] and not t.done():
			row.add_child(_btn("DROP", func() -> void:
				main.ask(Loc.t("Drop %s? Their matches still to play are lost by walkover.") % p["name"], "DROP", func() -> void:
					t.drop(pid)
					_save()
					_draw_tour()), 110))
		if pid == me and signup and t.d["checkin"] and not p["checked"] and not org:
			row.add_child(_btn("CHECK IN", func() -> void: _call({"t": "tci"}), 140))
		v.add_child(row)
		if p.has("members"):
			for k in (p["members"] as Array).size():
				var mb: Dictionary = p["members"][k]
				var mw := Loc.t("person") if String(mb["who"]) == "human" else "%s %s" % [Loc.t(String(mb["who"]).capitalize()), Loc.t(AI.STRATEGIES.get(String(mb["plan"]), {}).get("name", String(mb["plan"])))]
				var mt := "      %s  ·  %s  ·  %s" % [mb["name"], fac_text(String(mb["faction"])) if String(mb["faction"]) in Tournament.FACTIONS else Loc.t("Random"), mw]
				if t.d["checkin"] and signup and String(mb["who"]) == "human":
					mt += "  ·  " + (Loc.t("checked in") if bool(mb.get("checked", false)) else Loc.t("not checked in"))
				var ml := _label(mt, 15, UiStyle.GOOD if (pid == me and k == mi) else UiStyle.MUTED, false)
				ml.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
				v.add_child(ml)
	if not signup:
		return
	if org:
		_add_players(v)
		var prob := t.start_problem()
		var go := _btn("START THE TOURNAMENT", func() -> void:
			if t.start():
				t.computer_turns()
				_save()
				tab = "bracket"
				last_tab = tab
				_draw_tour(), 340)
		go.name = "Tour_Start"
		UiStyle.primary(go)
		go.disabled = prob != ""
		v.add_child(go)
		if prob != "":
			v.add_child(_label(prob, 15, UiStyle.MUTED))
	elif me >= 0:
		v.add_child(_btn("LEAVE THE TOURNAMENT", func() -> void: _call({"t": "tl"}), 300))


## The organiser adds players: a person by name (offline, or the organiser himself online), or a computer.
func _add_players(v: VBoxContainer) -> void:
	v.add_child(UiStyle.heading(Loc.t("ADD A PLAYER"), 20, UiStyle.TRIM))
	var r := HFlowContainer.new()
	r.add_theme_constant_override("h_separation", 8)
	r.add_theme_constant_override("v_separation", 6)
	v.add_child(r)
	var fac := OptionButton.new()
	fac.custom_minimum_size = Vector2(160, 50)
	for f in ["crown", "clockwork", "brood", "random"]:
		fac.add_item(Loc.t(f.capitalize()))
	var ts := t.team_size()
	var fixed := ts > 1 and String(t.d.get("team_rule", "fixed")) == "fixed"
	if fixed and t.d["mode"] == "offline":
		_add_team_by_hand(v)
		return
	if fixed and t.d["mode"] == "online":
		var tn := LineEdit.new()
		tn.placeholder_text = Loc.t("YOUR TEAM")
		tn.max_length = 24
		tn.custom_minimum_size = Vector2(220, 50)
		r.add_child(tn)
		var nm1 := LineEdit.new()
		nm1.placeholder_text = Loc.t("YOUR NAME")
		nm1.max_length = 24
		nm1.custom_minimum_size = Vector2(220, 50)
		r.add_child(nm1)
		r.add_child(fac)
		var am := _btn("ADD MYSELF", func() -> void:
			if nm1.text.strip_edges() == "" or tn.text.strip_edges() == "":
				return
			var jt := t.join_team(tn.text, nm1.text, ["crown", "clockwork", "brood", "random"][fac.selected], "human")
			if jt.is_empty():
				toast = "That team is full, or its name is taken."
			else:
				t.d["org_pid"] = int(jt[0])
				t.d["org_key"] = String(jt[2])
				me = int(jt[0])
				mi = int(jt[1])
				key = String(jt[2])
			_save()
			_draw_tour(), 180)
		am.name = "Tour_AddPerson"
		am.disabled = int(t.d.get("org_pid", -1)) >= 0
		r.add_child(am)
		return
	if t.d["mode"] != "computer":
		var nm := LineEdit.new()
		nm.placeholder_text = Loc.t("NAME")
		nm.max_length = 24
		nm.custom_minimum_size = Vector2(220, 50)
		r.add_child(nm)
		r.add_child(fac)
		var add := _btn("ADD" if t.d["mode"] == "offline" else "ADD MYSELF", func() -> void:
			var n := nm.text.strip_edges()
			if n == "":
				return
			var pid := t.add_player(n, ["crown", "clockwork", "brood", "random"][fac.selected], "human")
			if t.d["mode"] == "online" and int(t.d.get("org_pid", -1)) < 0:
				t.d["org_pid"] = pid
				me = pid
				key = String(t.player(pid)["key"])
				t.d["org_key"] = key
			_save()
			_draw_tour(), 180)
		add.name = "Tour_AddPerson"
		if t.d["mode"] == "online" and int(t.d.get("org_pid", -1)) >= 0:
			add.disabled = true
		r.add_child(add)
	# computers (an ALL COMPUTER tournament only: in the others a person plays every match)
	if t.d["mode"] != "computer":
		return
	var r2 := HFlowContainer.new()
	r2.add_theme_constant_override("h_separation", 8)
	v.add_child(r2)
	var fac2 := OptionButton.new()
	fac2.custom_minimum_size = Vector2(160, 50)
	for f in ["crown", "clockwork", "brood"]:
		fac2.add_item(Loc.t(f.capitalize()))
	r2.add_child(fac2)
	var plan := OptionButton.new()
	plan.custom_minimum_size = Vector2(220, 50)
	var fill_plans := func() -> void:
		plan.clear()
		for s in AI.strategies_for(["crown", "clockwork", "brood"][fac2.selected]):
			plan.add_item(Loc.t(String(AI.STRATEGIES[s]["name"])))
			plan.set_item_metadata(plan.item_count - 1, s)
		for i in plan.item_count:
			if plan.get_item_metadata(i) == "optimal":
				plan.select(i)
	fill_plans.call()
	fac2.item_selected.connect(func(_i: int) -> void: fill_plans.call())
	r2.add_child(plan)
	var lvl := OptionButton.new()
	lvl.custom_minimum_size = Vector2(150, 50)
	for l in LEVELS:
		lvl.add_item(Loc.t(l.capitalize()))
	lvl.select(2)
	r2.add_child(lvl)
	var addc := _btn("ADD A COMPUTER", func() -> void:
		var f: String = ["crown", "clockwork", "brood"][fac2.selected]
		var s := String(plan.get_item_metadata(plan.selected))
		var nm := "%s %s" % [Loc.t(f.capitalize()), Loc.t(String(AI.STRATEGIES[s]["name"]))]
		var n := 2
		var base := nm
		while t.players().any(func(p) -> bool: return p["name"] == nm):
			nm = "%s %d" % [base, n]
			n += 1
		if ts > 1:
			var mbs: Array = []
			for k in ts:
				mbs.append({"name": "%s %d" % [nm, k + 1], "faction": f, "who": LEVELS[lvl.selected], "plan": s})
			t.add_team(nm, mbs)
		else:
			t.add_player(nm, f, LEVELS[lvl.selected], s)
		_save()
		_draw_tour(), 220)
	addc.name = "Tour_AddComputer"
	if ts > 1:
		addc.text = Loc.t("ADD A COMPUTER TEAM")
	r2.add_child(addc)
	if t.d["mode"] == "computer":
		var fill := _btn("FILL WITH A FIELD OF 16" if ts == 1 else "FILL WITH A FIELD OF 8 TEAMS", func() -> void:
			if ts == 1:
				for e in DEFAULT_FIELD:
					if t.players().size() >= MAX_FIELD:
						break
					t.add_player("%s %s" % [Loc.t(String(e[0]).capitalize()), Loc.t(String(AI.STRATEGIES[e[1]]["name"]))], e[0], "hard", e[1])
			else:
				fill_teams(t, 8)
			_save()
			_draw_tour(), 360)
		fill.name = "Tour_Fill16"
		v.add_child(fill)


## The organiser types a whole team (offline, fixed teams): its name and each player's name and faction.
func _add_team_by_hand(v: VBoxContainer) -> void:
	var ts := t.team_size()
	var r := HFlowContainer.new()
	r.add_theme_constant_override("h_separation", 8)
	r.add_theme_constant_override("v_separation", 6)
	v.add_child(r)
	var tn := LineEdit.new()
	tn.name = "Tour_TeamNameAdd"
	tn.placeholder_text = Loc.t("TEAM NAME")
	tn.max_length = 24
	tn.custom_minimum_size = Vector2(220, 50)
	r.add_child(tn)
	var names: Array = []
	var facs: Array = []
	for k in ts:
		var nm := LineEdit.new()
		nm.placeholder_text = Loc.t("PLAYER %d") % (k + 1)
		nm.max_length = 24
		nm.custom_minimum_size = Vector2(180, 50)
		r.add_child(nm)
		names.append(nm)
		var fo := OptionButton.new()
		fo.custom_minimum_size = Vector2(150, 50)
		for f in ["crown", "clockwork", "brood", "random"]:
			fo.add_item(Loc.t(f.capitalize()))
		r.add_child(fo)
		facs.append(fo)
	var add := _btn("ADD THE TEAM", func() -> void:
		if tn.text.strip_edges() == "":
			return
		var mbs: Array = []
		for k in ts:
			var n: String = (names[k] as LineEdit).text.strip_edges()
			mbs.append({"name": n if n != "" else "%s %d" % [tn.text.strip_edges(), k + 1],
				"faction": ["crown", "clockwork", "brood", "random"][(facs[k] as OptionButton).selected], "who": "human", "plan": ""})
		t.add_team(tn.text, mbs)
		_save()
		_draw_tour(), 220)
	add.name = "Tour_AddTeam"
	r.add_child(add)


## A field of `n` computer teams (the championship simulation's plans dealt in turn, so each team mixes factions).
static func fill_teams(tt: Tournament, n: int) -> void:
	var ts := tt.team_size()
	var k := 0
	for i in n:
		if tt.players().size() >= MAX_FIELD:
			break
		var mbs: Array = []
		for j in ts:
			var e: Array = DEFAULT_FIELD[(k * 5) % DEFAULT_FIELD.size()]
			k += 1
			mbs.append({"name": "%s %s" % [Loc.t(String(e[0]).capitalize()), Loc.t(String(AI.STRATEGIES[e[1]]["name"]))], "faction": e[0], "who": "hard", "plan": e[1]})
		tt.add_team(Loc.t("Team %d") % (tt.players().size() + 1), mbs)


## The championship simulation's field (docs/championship_sim.md "The field"), offered as one button.
const DEFAULT_FIELD := [["crown", "optimal"], ["crown", "balanced"], ["crown", "economy"], ["crown", "timing"], ["crown", "siege"],
	["clockwork", "optimal"], ["clockwork", "balanced"], ["clockwork", "economy"], ["clockwork", "rush"], ["clockwork", "owls"],
	["clockwork", "heavy"], ["brood", "optimal"], ["brood", "balanced"], ["brood", "economy"], ["brood", "rush"], ["brood", "spitter"]]


func _tab_rules() -> void:
	var v := _scroll()
	var lines := [
		["Type", Tournament.TYPE_NAME[t.team_size()] + ((", " + Loc.t(Tournament.TEAM_RULE_NAME[String(t.d.get("team_rule", "fixed"))])) if t.team_size() > 1 else "")],
		["Format", Tournament.FORMAT_NAME[t.d["format"]]],
		["Series", Loc.t("Best of %d") % int(t.d["bo"]) + ", " + Loc.t("the final best of %d") % int(t.d["bo_final"])],
		["Maps", Tournament.MAP_RULE_NAME[t.d["map_rule"]] + (", " + Loc.t("the loser picks the next map") if t.d["loser_picks"] else "")],
		["Map pool", ", ".join((t.d["maps"] as Array).map(func(x) -> String: return MapGen.display_name(String(x))))],
		["Factions", Tournament.FACTION_RULE_NAME[t.d["factions"]]],
		["Seeding", "Random" if t.d["seeding"] == "random" else "By hand"],
		["Check-in", "Yes" if t.d["checkin"] else "No"],
		["Time limit", (Loc.t("%d minutes") % (int(t.d["time_limit"]) / 60)) if int(t.d["time_limit"]) > 0 else "None"],
	]
	for ln in lines:
		var l := _label("%s:  %s" % [Loc.t(ln[0]), Loc.t(String(ln[1]))], 16)
		l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		v.add_child(l)
	if role == "organiser":
		v.add_child(UiStyle.heading(Loc.t("KEEP IT SAFE"), 20, UiStyle.TRIM))
		v.add_child(_label("The tournament is saved on this device after every change. Its file code below holds all of it: paste it on TOURNAMENTS to open it again on another device (a new organiser), or keep it as a record.", 15, UiStyle.MUTED))
		var code := TextEdit.new()
		code.text = t.export_code()
		code.editable = false
		code.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		code.custom_minimum_size = Vector2(0, 110)
		v.add_child(code)
		v.add_child(_btn("COPY THE FILE CODE", func() -> void: DisplayServer.clipboard_set(t.export_code()), 280))
	if not (t.d["log"] as Array).is_empty():
		v.add_child(UiStyle.heading(Loc.t("WHAT HAPPENED"), 20, UiStyle.TRIM))
		var lg: Array = (t.d["log"] as Array).slice(-25)
		lg.reverse()
		for e in lg:
			var l2 := _label(String(e), 14, UiStyle.MUTED)
			l2.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			v.add_child(l2)


# ================================================================== a match's card

func _open_match(mid: int) -> void:
	var m := t.get_match(mid)
	if m.is_empty():
		return
	if is_instance_valid(_overlay):
		_overlay.queue_free()
	var o := Control.new()
	o.name = "Tour_Match"
	o.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(o)
	_overlay = o
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.add_child(dim)
	var pan := PanelContainer.new()
	pan.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var mg := 60 if _pc() else 14
	pan.offset_left = mg
	pan.offset_right = -mg
	pan.offset_top = 20
	pan.offset_bottom = -20
	o.add_child(pan)
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	pan.add_child(sc)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 8)
	sc.add_child(v)
	var close := func() -> void:
		o.queue_free()
		_overlay = null
		_draw_tour()
	var top := HBoxContainer.new()
	v.add_child(top)
	var title := UiStyle.heading(Loc.t(t.match_label(m)), 28, UiStyle.TRIM)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	var cb := _btn("CLOSE", close, 130)
	cb.name = "Tour_MatchClose"
	top.add_child(cb)
	main._set_back(cb)
	var sc2 := t.score(m)
	var fa := t.faction_for(m, "a") if int(m["a"]) >= 0 else ""
	var fb := t.faction_for(m, "b") if int(m["b"]) >= 0 else ""
	var vs := _label("%s %s   %d - %d   %s %s" % [t.pname(int(m["a"])), ("(" + fac_text(fa) + ")") if fa != "" else "",
		sc2[0], sc2[1], t.pname(int(m["b"])), ("(" + fac_text(fb) + ")") if fb != "" else ""], 22, UiStyle.TEXT)
	vs.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	v.add_child(vs)
	if t.team_size() > 1:
		for s in ["a", "b"]:
			if int(m[s]) >= 0:
				var tl := _label("%s:  %s" % [t.pname(int(m[s])), ", ".join(t.members(t.player(int(m[s]))).map(func(x) -> String:
					return "%s (%s)" % [x["name"], fac_text(String(x["faction"])) if String(x["faction"]) in Tournament.FACTIONS else Loc.t("Random")]))], 15, UiStyle.MUTED)
				tl.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
				v.add_child(tl)
	v.add_child(_label(Loc.t("Best of %d") % int(m["bo"]) + ("  ·  " + Loc.t("winner: %s") % t.pname(int(m["winner"])) if m["state"] == "done" else ""), 15, UiStyle.MUTED))
	if String(m.get("dispute", "")) != "":
		v.add_child(_label(Loc.t("DISPUTE: ") + String(m["dispute"]), 16, UiStyle.BAD))
	if (m["reports"] as Dictionary).size() == 1:
		var who := t.pname(int(m[(m["reports"] as Dictionary).keys()[0]]))
		v.add_child(_label(Loc.t("%s reported the game; waiting for the other player (or the organiser).") % who, 15, UiStyle.MUTED))
	if not (m["bans"] as Array).is_empty():
		v.add_child(_label(Loc.t("Banned: %s") % ", ".join((m["bans"] as Array).map(func(x) -> String: return MapGen.display_name(String(x)))), 15, UiStyle.MUTED))
	# the games
	for gi in (m["games"] as Array).size():
		var g: Dictionary = m["games"][gi]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		v.add_child(row)
		var how: String = {"played": "", "time": Loc.t("at the time limit"), "walkover": Loc.t("walkover"), "set": Loc.t("set by the organiser")}.get(String(g["how"]), "")
		var txt := Loc.t("Game %d") % (gi + 1) + ":  "
		if String(g["map"]) != "":
			txt += MapGen.display_name(String(g["map"])) + "  ·  "
		if String(g["fa"]) != "":
			txt += "%s v %s  ·  " % [fac_text(String(g["fa"])), fac_text(String(g["fb"]))]
		txt += Loc.t("won by %s") % t.pname(int(m[g["win"]]))
		if int(g["len"]) > 0:
			txt += "  ·  %d:%02d" % [int(g["len"]) / 60, int(g["len"]) % 60]
		if how != "":
			txt += "  ·  " + how
		var gl := _label(txt, 15, UiStyle.TEXT, false)
		gl.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		row.add_child(gl)
		var rp := String(g.get("replay", ""))
		if rp != "" and FileAccess.file_exists(ReplayFile.DIR + "/" + rp):
			row.add_child(_btn("WATCH REPLAY", func() -> void:
				main.start_replay(ReplayFile.DIR + "/" + rp), 200))
		elif rp != "":
			row.add_child(_label("(replay on a player's device)", 13, UiStyle.MUTED, false))
	if m["state"] == "done" or int(m["a"]) < 0 or int(m["b"]) < 0:
		if m["state"] != "done":
			v.add_child(_label("Waiting for the matches before it.", 16, UiStyle.MUTED))
		_organiser_tools(v, m)
		return
	# the next game
	var ng := t.next_game(m)
	var my_side := t.side_of(m, me)
	var org := role == "organiser"
	var acts_for: Array = []        # the sides this device may act for (bans, picks, factions)
	if my_side != "":
		acts_for.append(my_side)
	if org and t.d["mode"] != "online":
		acts_for = ["a", "b"]
	v.add_child(UiStyle.heading(Loc.t("GAME %d") % (int(ng["game"]) + 1), 22, UiStyle.TRIM))
	var bt := t.ban_turn(m)
	var pt := t.pick_turn(m)
	if bt != "":
		v.add_child(_label(Loc.t("%s bans a map.") % t.pname(int(m[bt])), 16))
		if acts_for.has(bt) and t.is_human(t.player(int(m[bt]))):
			v.add_child(_map_buttons(t.open_maps(m), func(id: String) -> void:
				if org and t.d["mode"] != "online":
					t.ban(m, bt, id)
					_save()
					_open_match(mid)
				else:
					_call_then_match({"t": "tb", "mid": mid, "map": id}, mid)))
		return
	if pt != "":
		v.add_child(_label(Loc.t("%s picks the map.") % t.pname(int(m[pt])), 16))
		if acts_for.has(pt) and t.is_human(t.player(int(m[pt]))):
			var played: Array = (m["games"] as Array).map(func(g) -> String: return String(g["map"]))
			v.add_child(_map_buttons(t.open_maps(m).filter(func(x) -> bool: return not played.has(x)) if t.open_maps(m).size() > played.size() else t.open_maps(m), func(id: String) -> void:
				if org and t.d["mode"] != "online":
					t.pick(m, pt, id)
					_save()
					_open_match(mid)
				else:
					_call_then_match({"t": "tp", "mid": mid, "map": id}, mid)))
		return
	v.add_child(_label(Loc.t("Map: %s") % MapGen.display_name(String(ng["map"])), 18))
	# factions still to choose
	var need: Array = []
	for s in ["a", "b"]:
		if t.faction_for(m, s) == "":
			need.append(s)
	for s in need:
		var nm := t.pname(int(m[s]))
		if acts_for.has(s):
			v.add_child(_label(Loc.t("%s: choose your faction for this game.") % nm, 16))
			var fr := HFlowContainer.new()
			fr.add_theme_constant_override("h_separation", 8)
			v.add_child(fr)
			for f in t.faction_choices(m, s):
				fr.add_child(_btn(String(f).capitalize(), func() -> void:
					if org and t.d["mode"] != "online":
						t.choose_faction(m, s, f)
						_save()
						_open_match(mid)
					else:
						_call_then_match({"t": "tf", "mid": mid, "fac": f}, mid), 170))
		else:
			v.add_child(_label(Loc.t("Waiting for %s to choose a faction (they see it on their own screen).") % nm, 15, UiStyle.MUTED))
	if not need.is_empty():
		_organiser_tools(v, m)
		return
	v.add_child(_label("%s (%s)  v  %s (%s)" % [t.pname(int(m["a"])), fac_text(t.faction_for(m, "a")), t.pname(int(m["b"])), fac_text(t.faction_for(m, "b"))], 18))
	var acts := HFlowContainer.new()
	acts.add_theme_constant_override("h_separation", 8)
	acts.add_theme_constant_override("v_separation", 8)
	v.add_child(acts)
	match String(t.d["mode"]):
		"computer":
			if org:
				var w := _btn("WATCH THIS GAME", func() -> void: _play_computer(mid, false, false), 260)
				w.name = "Tour_WatchGame"
				UiStyle.primary(w)
				acts.add_child(w)
				acts.add_child(_btn("PLAY IT QUICKLY", func() -> void: _play_computer(mid, true, false), 240))
		"offline":
			if org:
				v.add_child(_label("Play the game on your own devices (a skirmish or a friendly room), then enter who won.", 15, UiStyle.MUTED))
				for s in ["a", "b"]:
					var wb := _btn(Loc.t("%s WON THIS GAME") % t.pname(int(m[s])).to_upper(), func() -> void:
						t.report_game(mid, s, {"how": "played"})
						_save()
						_after_change(mid), 300)
					wb.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
					acts.add_child(wb)
		"online":
			var room := t.room_code(m)
			if my_side != "":
				var p := _btn("PLAY YOUR MATCH", func() -> void: _play_online(mid, my_side), 280)
				p.name = "Tour_Play"
				UiStyle.primary(p)
				p.disabled = not _relay_set()
				acts.add_child(p)
				var hosting := my_side == "a" and mi == 0
				if t.team_size() > 1:
					v.add_child(_label(("You host the room %s: your team-mates and the other team join it from here." if hosting else "%s's first player hosts the room %s: you join it from here, in your own seat (wait until the host is in it).") % ([room] if hosting else [t.members(t.player(int(m["a"])))[0]["name"], room]), 15, UiStyle.MUTED))
				else:
					v.add_child(_label(("You host the room %s: your opponent joins it from here." if my_side == "a" else "Your opponent hosts the room %s: you join it from here (wait until they are in it).") % room, 15, UiStyle.MUTED))
				# a report by hand, if the game's own report went missing
				acts.add_child(_btn("I WON THIS GAME", func() -> void: _call_then_match({"t": "tr", "mid": mid, "win": my_side, "info": {"game": int(ng["game"]), "how": "played"}}, mid), 230))
				acts.add_child(_btn("I LOST THIS GAME", func() -> void: _call_then_match({"t": "tr", "mid": mid, "win": "b" if my_side == "a" else "a", "info": {"game": int(ng["game"]), "how": "played"}}, mid), 230))
			var wt := _btn("WATCH", func() -> void: _spectate(mid), 150)
			wt.disabled = not _relay_set()
			acts.add_child(wt)
	_organiser_tools(v, m)


func _map_buttons(ids: Array, cb: Callable) -> Control:
	var fr := HFlowContainer.new()
	fr.add_theme_constant_override("h_separation", 8)
	fr.add_theme_constant_override("v_separation", 8)
	for id in ids:
		var cell := VBoxContainer.new()          # (the map's picture over its button: MapPreview, job map-previews)
		cell.add_theme_constant_override("separation", 2)
		var pv := MapPreview.new()
		pv.map_id = String(id)
		pv.custom_minimum_size = Vector2(210, 120)
		cell.add_child(pv)
		var b := _btn(MapGen.display_name(String(id)), func() -> void: cb.call(String(id)), 210)
		b.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		cell.add_child(b)
		fr.add_child(cell)
	return fr


func _call_then_match(msg: Dictionary, mid: int) -> void:
	if role == "organiser":
		_call(msg, false)
		_after_change(mid)
		return
	_ensure_net()
	if net.busy():
		return
	net.answered.connect(func(ok: bool, why: String) -> void:
		if not is_inside_tree():
			return
		if ok and net.t:
			t = net.t
		if why != "" and why != "ok" and why != "taken":
			toast = why
		_after_change(mid), CONNECT_ONE_SHOT)
	net.call_desk(Settings.relay_url, String(t.d["id"]), msg)


func _after_change(mid: int) -> void:
	if t.done():
		_champion()
		return
	if t.get_match(mid)["state"] == "done":
		if is_instance_valid(_overlay):
			_overlay.queue_free()
		_overlay = null
		_draw_tour()
	else:
		_open_match(mid)


## The organiser's tools on a match: set the result, a walkover, accept a lone report, drop a player.
func _organiser_tools(v: VBoxContainer, m: Dictionary) -> void:
	if role != "organiser" or int(m["a"]) < 0 or int(m["b"]) < 0 or m.get("skip", false) or m.get("bye", false):
		return
	var mid := int(m["id"])
	v.add_child(UiStyle.heading(Loc.t("ORGANISER"), 20, UiStyle.TRIM))
	var r := HFlowContainer.new()
	r.add_theme_constant_override("h_separation", 8)
	r.add_theme_constant_override("v_separation", 8)
	v.add_child(r)
	if (m["reports"] as Dictionary).size() == 1 and m["state"] != "done":
		r.add_child(_btn("ACCEPT THE REPORT", func() -> void:
			t.accept_report(mid)
			_save()
			_after_change(mid), 260))
	var need := t.wins_needed(m)
	var opts := []
	for l in need:
		opts.append([need, l])
		opts.append([l, need])
	for o in opts:
		var sb := _btn(Loc.t("SET %d-%d") % [o[0], o[1]], func() -> void:
			main.ask(Loc.t("Set %s %d-%d %s?") % [t.pname(int(m["a"])), o[0], o[1], t.pname(int(m["b"]))], "SET", func() -> void:
				if t.set_result(mid, o[0], o[1]):
					_save()
				else:
					toast = "A result can't be changed once a match after it has been played."
				_after_change(mid)), 120)
		r.add_child(sb)
	if m["state"] != "done":
		for s in ["a", "b"]:
			var wo := _btn(Loc.t("WALKOVER TO %s") % t.pname(int(m[s])).to_upper(), func() -> void:
				t.walkover(mid, s)
				_save()
				_after_change(mid), 260)
			wo.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			r.add_child(wo)


# ================================================================== playing

## An ALL COMPUTER tournament's game: watched, or quickly (the picture hidden, the game run QUICK_SPEED times faster).
## `chain`: when it ends, the next one starts by itself until the tournament is over (PLAY EVERY GAME QUICKLY).
func _play_computer(mid: int, quick: bool, chain: bool) -> void:
	t.computer_turns()
	var m := t.get_match(mid)
	var ng := t.next_game(m)
	var gi: int = ng["game"]
	var swap := t.swap_spots(m, gi)
	# (job tournament-formats: a team is several slots, each member with its faction and plan; Tournament.game_slots)
	var slots: Array = t.game_slots(m, swap).map(func(x: Dictionary) -> Dictionary:
		return {"who": String(x["who"]), "faction": String(x["faction"]), "strategy": String(x["strategy"]), "side": int(x["side"]), "colour": int(x["colour"])})
	main.set("tour_game", {"tid": String(t.d["id"]), "mid": mid, "gi": gi, "kind": "computer", "swap": swap, "quick": quick, "chain": chain,
		"limit": int(t.d.get("time_limit", 0)), "replays": int(m.get("replays", 0)), "n": t.team_size()})
	_save()
	main.start({"map": String(ng["map"]), "seed": int(ng["seed"]), "slots": slots})


func _computer_next(quick: bool, chain: bool) -> void:
	t.computer_turns()
	var r := t.ready_matches()
	if r.is_empty():
		return
	_play_computer(int(r[0]["id"]), quick, chain)


## PLAY YOUR MATCH: the higher seed (side a) hosts a friendly room with the bracket's code; the other joins it. The
## room's map and factions come from the bracket and can't be changed there.
func _play_online(mid: int, side: String) -> void:
	var m := t.get_match(mid)
	var ng := t.next_game(m)
	var code := t.room_code(m)
	var l := NetLobby.new()
	main.add_child(l)
	main.net_lobby = l
	l.tour = {"tid": String(t.d["id"]), "mid": mid, "gi": int(ng["game"])}
	main.set("tour_game", {"tid": String(t.d["id"]), "mid": mid, "gi": int(ng["game"]), "kind": "online", "side": side,
		"limit": int(t.d.get("time_limit", 0)), "me": me, "key": key, "role": role, "relay": Settings.relay_url, "n": t.team_size()})
	# online the start spots are not swapped (the host is always slot 0, side a's first player)
	var gs := t.game_slots(m, false)
	var seat := 0
	for i in gs.size():
		if String(gs[i]["s"]) == side and int(gs[i]["mi"]) == mi:
			seat = i
	if seat == 0 and side == "a":
		l.host(Settings.relay_url, code)
		if t.team_size() > 1:
			l.tour_setup(String(ng["map"]), gs)
		else:
			l.set_map(String(ng["map"]))
			l.slots[0]["faction"] = String(ng["fa"])
			l.slots[1]["faction"] = String(ng["fb"])
			l.tour_lock = true
	else:
		l.tour_seat = seat if t.team_size() > 1 else -1
		l.start_now.connect(func(cfg: Dictionary) -> void: main.start(cfg))
		l.join(Settings.relay_url, code)
	main.show_online()


func _spectate(mid: int) -> void:
	var m := t.get_match(mid)
	var l := NetLobby.new()
	main.add_child(l)
	main.net_lobby = l
	l.want_spec = true
	main.set("tour_game", {"tid": String(t.d["id"]), "mid": mid, "gi": (m["games"] as Array).size(), "kind": "spectate"})
	l.start_now.connect(func(cfg: Dictionary) -> void: main.start(cfg))
	l.join(Settings.relay_url, t.room_code(m))
	main.show_online()


# ================================================================== a game of the tournament under way (Main)

## A game of the tournament has started: the time limit, the quick speed.
static func watch_game(m: Node) -> void:
	var tg: Dictionary = m.get("tour_game")
	if tg.is_empty() or m.game == null:
		return
	var w := TourWatch.new()
	w.name = "TourWatch"
	w.main = m
	w.tg = tg
	m.game.add_child(w)
	if bool(tg.get("quick", false)):
		Engine.time_scale = QUICK_SPEED
		w.cover()


## The score of a side for the time limit's lead rule: income earned + 2 x its army's value (a rooted Brood is no army).
static func side_score(g: Game, tm: int) -> float:
	var v := 0
	for u in g.army(tm):
		if not u._k_nb or not (u.kind == BroodNew.QUEEN or BroodNew.rooted(u)):
			v += Game.unit_value(u)
	return float(g.stats[tm]["gold"]) + 2.0 * v


## Main._on_end: a game of the tournament is over: its result into the bracket (or to the desk), then back to the
## tournament (or the next game, when playing every game).
static func game_over(m: Node, g: Game, winner: int, rp_path: String) -> void:
	var tg: Dictionary = m.get("tour_game")
	m.set("tour_game", {})
	var tid := String(tg.get("tid", ""))
	var note := ""
	var len_s := int(g.clock)
	var rp := rp_path.get_file() if rp_path != "" else ""
	if rp_path != "":
		ReplayFile.set_kept(rp_path, true)       # (a tournament's replays are never pruned)
	match String(tg.get("kind", "")):
		"computer":
			var path := "user://tournaments/%s.json" % tid
			var t := Tournament.load_from(path)
			var dk: TournamentNet = m.get("tour_desk")
			if t:
				var mt := t.get_match(int(tg["mid"]))
				if not mt.is_empty() and mt["state"] != "done" and (mt["games"] as Array).size() == int(tg["gi"]):
					var again := bool(tg.get("again", false))
					if again:
						t.replay_game(int(mt["id"]))
						note = "No clear leader at the time limit: the game is played again."
					else:
						var w_side := ""
						if winner >= 0:
							var slot_a := int(tg.get("n", 1)) if bool(tg.get("swap", false)) else 0
							w_side = "a" if g.sides[winner] == g.sides[slot_a] else "b"
						else:
							w_side = String(tg.get("verdict", "a"))
						var ng := t.next_game(mt)
						t.report_game(int(mt["id"]), w_side, {"map": ng["map"], "fa": ng["fa"], "fb": ng["fb"], "len": len_s,
							"replay": rp, "how": "time" if bool(tg.get("timed", false)) else "played"})
					t.computer_turns()
					t.save()
			if bool(tg.get("chain", false)) and t and not t.done():
				m.call_deferred("_tour_next_quick", tid)
				return
		"online":
			var won := winner >= 0 and g.allied(winner, g.human)
			var side := String(tg["side"])
			var w_side2 := side if won else ("b" if side == "a" else "a")
			var info := {"game": int(tg["gi"]), "len": len_s, "replay": rp, "how": "time" if bool(tg.get("timed", false)) else "played"}
			var msg := {"t": "tr", "mid": int(tg["mid"]), "win": w_side2, "info": info}
			if bool(tg.get("again", false)):
				msg["win"] = "again"
			if String(tg.get("role", "")) == "organiser":
				var dk2: TournamentNet = m.get("tour_desk")
				if dk2 and dk2.t:
					msg["pid"] = int(tg["me"])
					msg["key"] = String(tg["key"])
					dk2.handle(msg)
					dk2.t.save()
			else:
				_report_later(m, tid, msg, tg)
			note = "Your result was sent to the organiser." if String(tg.get("role", "")) != "organiser" else ""
	m._tour_back(tid, note)


## A player's report, sent from a small node that outlives the match page.
static func _report_later(m: Node, tid: String, msg: Dictionary, tg: Dictionary) -> void:
	var rec := TournamentNet.joined_load(tid)
	var n := TournamentNet.new()
	n.name = "TourReport"
	m.add_child(n)
	n.me = int(rec.get("me", tg.get("me", -1)))
	n.key = String(rec.get("key", tg.get("key", "")))
	n.answered.connect(func(_ok: bool, _why: String) -> void: n.queue_free(), CONNECT_ONE_SHOT)
	n.call_desk(String(tg.get("relay", Settings.relay_url)), tid, msg)


## The time limit and the quick mode while a tournament game runs (a child of the game).
class TourWatch extends Node:
	var main: Node
	var tg: Dictionary
	var _cover: Control
	var _lbl: Label

	func _ready() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS

	func cover() -> void:
		var g: Game = main.game
		if g == null:
			return
		var layer := CanvasLayer.new()
		layer.layer = 50
		add_child(layer)
		_cover = ColorRect.new()
		(_cover as ColorRect).color = Color(0.06, 0.05, 0.04, 1.0)
		_cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		layer.add_child(_cover)
		_lbl = UiStyle.text("", 26, UiStyle.TRIM)
		_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		_lbl.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_lbl.grow_vertical = Control.GROW_DIRECTION_BOTH
		_lbl.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		_cover.add_child(_lbl)
		var stop: Button = main._button("STOP AFTER THIS GAME", func() -> void: tg["chain"] = false)
		stop.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
		stop.offset_top = -120
		stop.offset_bottom = -60
		stop.offset_left = -170
		stop.offset_right = 170
		_cover.add_child(stop)

	func _process(_d: float) -> void:
		var g: Game = main.game
		if g == null or g.over:
			return
		if _lbl:
			_lbl.text = "%s\n%s  %d:%02d" % [Loc.t("PLAYING A TOURNAMENT GAME QUICKLY"), Loc.t("game time"), int(g.clock) / 60, int(g.clock) % 60]
		var lim := int(tg.get("limit", 0))
		if lim <= 0 or g.clock < lim:
			return
		if g.net and not g.net.is_host:
			return          # (online: the host's game decides, the guest hears it)
		# the bell: the side clearly ahead wins; else played again
		# (a team's score is its players' added: job tournament-formats; slot 0's side against the other)
		var s0 := 0.0
		var s1 := 0.0
		for tm in g.n_players():
			if g.sides[tm] == g.sides[0]:
				s0 += TournamentPage.side_score(g, tm)
			else:
				s1 += TournamentPage.side_score(g, tm)
		var other := 1
		for tm in g.n_players():
			if g.sides[tm] != g.sides[0]:
				other = tm
				break
		var k := Tournament.LEAD_K
		var w := -1
		if s0 >= k * s1 and s0 > 0:
			w = 0
		elif s1 >= k * s0 and s1 > 0:
			w = other
		elif int(tg.get("replays", 0)) >= Tournament.REPLAYS:
			w = 0 if s0 >= s1 else other
		tg["timed"] = true
		if w < 0:
			tg["again"] = true
		else:
			var slot_a := int(tg.get("n", 1)) if bool(tg.get("swap", false)) else 0
			tg["verdict"] = "a" if g.sides[w] == g.sides[slot_a] else "b"
		if g.mlog:
			g.mlog.add("Tournament time limit (%d:%02d): scores %d and %d, %s" % [lim / 60, lim % 60, int(s0), int(s1), ("won by slot %d" % w) if w >= 0 else "no clear leader: played again"])
		g.end_note = "time limit"
		g.over = true
		g.winner = w
		g.ended.emit(w)


# ================================================================== the champion

func _champion() -> void:
	if is_instance_valid(_overlay):
		_overlay.queue_free()
	var o := Control.new()
	o.name = "Tour_Champion"
	o.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(o)
	_overlay = o
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.03, 0.02, 0.94)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.add_child(bg)
	var tro := Trophy.new()
	tro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	o.add_child(tro)
	var v := VBoxContainer.new()
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_END
	v.offset_bottom = -24
	v.add_theme_constant_override("separation", 8)
	o.add_child(v)
	var ch := int(t.d["champion"])
	var p := t.player(ch)
	tro.faction = String(p.get("faction", "crown"))
	var h := UiStyle.heading(Loc.t("CHAMPION"), 44, UiStyle.TRIM)
	v.add_child(h)
	var n := UiStyle.heading(String(p.get("name", "?")), 52, UiStyle.TEXT)
	n.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	v.add_child(n)
	var sub := UiStyle.text("%s  ·  %s" % [Loc.t(String(p.get("faction", "")).capitalize()), String(t.d["name"])], 20, UiStyle.MUTED)
	sub.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	v.add_child(sub)
	var pl := t.placings()
	var podium: PackedStringArray = []
	for e in pl.slice(1, 4):
		podium.append("%d. %s" % [int(e["place"]), t.pname(int(e["id"]))])
	var pd := UiStyle.text("   ".join(podium), 18, UiStyle.TEXT)
	pd.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	v.add_child(pd)
	var cc := CenterContainer.new()
	v.add_child(cc)
	var cb := _btn("THE BRACKET", func() -> void:
		o.queue_free()
		_overlay = null
		tab = "bracket"
		_draw_tour(), 260)
	cb.name = "Tour_ChampionClose"
	cc.add_child(cb)
	main._set_back(cb)
	Sfx.play_any(["ui/victory", "victory", "ui/click"])


## The trophy, drawn: a gold cup on a dark plinth with the champion's colour in a ribbon.
class Trophy extends Control:
	var faction := "crown"
	var _t := 0.0

	func _process(d: float) -> void:
		_t += d
		queue_redraw()

	func _draw() -> void:
		var c := Vector2(size.x * 0.5, size.y * 0.33)
		var s := minf(size.x, size.y) / 700.0
		var gold := Color("#d9b24c")
		var dark := Color("#8a6a1f")
		var light := Color("#f6e29a")
		# rays
		for i in 16:
			var a := _t * 0.15 + i * TAU / 16.0
			var p1 := c + Vector2(cos(a), sin(a)) * 60 * s
			var p2 := c + Vector2(cos(a + 0.09), sin(a + 0.09)) * 300 * s
			var p3 := c + Vector2(cos(a - 0.09), sin(a - 0.09)) * 300 * s
			draw_colored_polygon(PackedVector2Array([p1, p2, p3]), Color(1, 0.85, 0.4, 0.05))
		# plinth
		draw_rect(Rect2(c + Vector2(-90, 150) * s, Vector2(180, 46) * s), Color(0.15, 0.1, 0.06))
		draw_rect(Rect2(c + Vector2(-70, 118) * s, Vector2(140, 34) * s), Color(0.2, 0.14, 0.08))
		draw_rect(Rect2(c + Vector2(-70, 128) * s, Vector2(140, 10) * s), UiStyle.ACCENT.get(faction, gold))
		# stem and foot
		draw_colored_polygon(PackedVector2Array([c + Vector2(-50, 118) * s, c + Vector2(50, 118) * s, c + Vector2(28, 96) * s, c + Vector2(-28, 96) * s]), dark)
		draw_rect(Rect2(c + Vector2(-12, 40) * s, Vector2(24, 58) * s), gold)
		draw_circle(c + Vector2(0, 44) * s, 22 * s, gold)
		# the bowl
		var bowl := PackedVector2Array()
		for i in 21:
			var a := PI * float(i) / 20.0
			bowl.append(c + Vector2(cos(a) * 92, -100 + sin(a) * 130) * s)
		bowl.append(c + Vector2(-92, -100) * s)
		draw_colored_polygon(bowl, gold)
		draw_rect(Rect2(c + Vector2(-100, -114) * s, Vector2(200, 18) * s), dark)
		draw_line(c + Vector2(-60, -90) * s, c + Vector2(-40, 10) * s, light, 6 * s)
		# handles
		for sx in [-1.0, 1.0]:
			draw_arc(c + Vector2(sx * 100, -50) * s, 42 * s, -PI * 0.5 if sx > 0 else PI * 0.5, PI * 0.5 if sx > 0 else PI * 1.5, 20, gold, 12 * s)
		# a star on the bowl
		var star := PackedVector2Array()
		for i in 10:
			var a := -PI * 0.5 + i * TAU / 10.0
			var r := (26.0 if i % 2 == 0 else 11.0) * s
			star.append(c + Vector2(0, -40) * s + Vector2(cos(a), sin(a)) * r)
		draw_colored_polygon(star, light)
