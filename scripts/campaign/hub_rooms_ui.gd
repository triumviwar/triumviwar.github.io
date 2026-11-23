class_name HubRoomsUi
extends RefCounted
## The hub's ROOMS, the people who join them, the NEW marks and the counters of the rooms that act on the game (job
## hubs-grow, docs/hubs_grow.md; the data and the rules: HubGrow). CampaignMenu.show asks view() what to draw, adds the
## room tabs and the NEW line (add_tabs), the people's layers (add_people), and sends the hotspots it does not know
## (a person's talk, a counter, a door) to act().

static var room_of := {}             # line id -> the room shown (the main room when absent)


## What the hub page shows now: {"lid", "rid", "main", "title", "scene", "spots", "people", "rooms"}.
static func view(sl: Dictionary, hub: Dictionary, p: Dictionary) -> Dictionary:
	var lid := String(sl.get("id", ""))
	var rooms := HubGrow.rooms_now(lid, p)
	var rid := String(room_of.get(lid, ""))
	var main_id := String(rooms[0]["id"]) if not rooms.is_empty() else ""
	if rid == "" or not rooms.any(func(r: Dictionary) -> bool: return String(r["id"]) == rid):
		rid = main_id
	var out := {"lid": lid, "rid": rid, "main": rid == main_id, "rooms": rooms, "title": Loc.t(String(hub.get("title", sl.get("title", ""))))}
	if rid == main_id:
		var spots: Array = (hub.get("hotspots", []) as Array).duplicate()
		var ppl := HubGrow.people_now(lid, rid, p)
		if not _sides_hide(hub):
			spots.append_array(_mine(HubGrow.people_hotspots(lid, rid, p)))
		else:
			ppl = []
		for r in rooms.slice(1):
			spots.append({"id": "door_" + String(r["id"]), "kind": "door", "label": String(r["title"]), "room": String(r["id"]), "list_only": true, "grow": true})
		out["spots"] = spots
		out["people"] = ppl
		out["scene"] = String(hub.get("scene", ""))
	else:
		var r := HubGrow.room(lid, rid)
		out["scene"] = String(r.get("scene", ""))
		out["people"] = HubGrow.people_now(lid, rid, p)
		var spots := _mine(HubGrow.hotspots_now(lid, rid, p))
		spots.append({"id": "door_back", "kind": "door", "label": Loc.t("BACK TO %s") % Loc.t(String(rooms[0].get("title", ""))),
			"room": main_id, "list_only": true, "grow": true})
		out["spots"] = spots
	return out


## Hotspots from hubs_grow.json, marked as this module's (copies: the data stays as it was read).
static func _mine(spots: Array) -> Array:
	return spots.map(func(hs: Dictionary) -> Dictionary:
		var c := hs.duplicate()
		c["grow"] = true
		return c)


## (the Machine's City: whoever won a02 as the Machine keeps Nuremberg; the guild's people are not there)
static func _sides_hide(hub: Dictionary) -> bool:
	return (hub.get("hide_layers", []) as Array).has("hollweg")


## The room tabs (when more than the main room is open) and the plain NEW line under the hub's title.
static func add_tabs(main: Node, box: VBoxContainer, v: Dictionary, p: Dictionary, redraw: Callable) -> void:
	var lid := String(v["lid"])
	var news := HubGrow.news(lid, p)
	if not news.is_empty():
		var nl := UiStyle.text("", 15, UiStyle.GOOD, HORIZONTAL_ALIGNMENT_LEFT, true)
		nl.name = "HubNews"
		nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		nl.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		var parts: Array = news.slice(0, 3).map(func(n: Dictionary) -> String: return Loc.t(String(n["text"])))
		nl.text = Loc.t("NEW IN THE HUB") + ":  " + "  ".join(parts) + ("  (+%d)" % (news.size() - 3) if news.size() > 3 else "")
		box.add_child(nl)
	var rooms: Array = v["rooms"]
	if rooms.size() < 2:
		return
	var row := HFlowContainer.new()
	row.name = "HubRooms"
	row.add_theme_constant_override("h_separation", 6)
	box.add_child(row)
	for r in rooms:
		var rid := String(r["id"])
		var t := Loc.t(String(r.get("title", "")))
		var is_new := not bool(r.get("main", false)) and HubGrow.room_is_new(lid, rid, p)
		if bool(r.get("main", false)) and HubGrow.people_now(lid, rid, p).any(func(pe: Dictionary) -> bool:
				return not HubGrow.seen("person:%s:%s" % [lid, String(pe["id"])], p)):
			is_new = true
		var b: Button = main._button(t + ("  • " + Loc.t("NEW") if is_new else ""), func() -> void:
			room_of[lid] = rid
			redraw.call())
		b.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		b.name = "Room_" + rid
		b.custom_minimum_size = Vector2(130, 40)
		b.add_theme_font_size_override("font_size", 14)
		if rid == String(v["rid"]):
			UiStyle.chosen(b)
		elif is_new:
			b.add_theme_color_override("font_color", UiStyle.GOOD)
		row.add_child(b)
	# entering a room: it is not new any more
	if not bool(v["main"]):
		HubGrow.mark_seen(["room:%s:%s" % [lid, String(v["rid"])]])


## The people's cut-outs on the room's painting.
static func add_people(hsc: HubScene, v: Dictionary) -> void:
	for pe in v.get("people", []):
		hsc.add_person(pe)


## Is this hotspot new (a person not talked to yet, a counter with an offer not looked at)?
static func is_new(v: Dictionary, hs: Dictionary, p: Dictionary) -> bool:
	var lid := String(v["lid"])
	if hs.has("person"):
		return not HubGrow.seen("person:%s:%s" % [lid, String(hs["person"])], p)
	if String(hs.get("kind", "")) == "shop":
		return HubGrow.shop_is_new(lid, hs.get("shop", []), p)
	if String(hs.get("kind", "")) == "door":
		return HubGrow.room_is_new(lid, String(hs.get("room", "")), p)
	return false


## A small green NEW on a button's corner.
static func badge(b: Button) -> void:
	var l := Label.new()
	l.name = "NewBadge"
	l.text = Loc.t("NEW")
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", Color(0.1, 0.1, 0.05))
	var st := UiStyle.box(UiStyle.GOOD, UiStyle.GOOD, 0, 6, 3.0)
	l.add_theme_stylebox_override("normal", st)
	l.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	l.position = Vector2(-44, -6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(l)


## Does this module handle the hotspot? (people from hubs_grow.json, its counters and doors)
static func handles(hs: Dictionary) -> bool:
	return bool(hs.get("grow", false))


static func act(main: Node, v: Dictionary, hs: Dictionary, talk_box: PanelContainer, scene: Control, redraw: Callable) -> void:
	var lid := String(v["lid"])
	var p := Campaign.progress()
	match String(hs.get("kind", "")):
		"door":
			room_of[lid] = String(hs.get("room", ""))
			redraw.call()
		"shop":
			shop(main, scene, lid, hs.get("shop", []), String(hs.get("label", "")), redraw)
		_:
			var tk := HubGrow.talk(String(hs.get("talk", "")))
			if tk.is_empty():
				return
			if hs.has("person"):
				HubGrow.mark_seen(["person:%s:%s" % [lid, String(hs["person"])]])
				tk = tk.duplicate()
				tk["portrait"] = HubGrow.portrait_of(String(hs["person"]), tk)
			CampaignMenu._talk(talk_box, tk, HubGrow.talk_lines(tk, p))


# ------------------------------------------------------------------ the counters (upgrades, choices, blessings, company)

static func shop(main: Node, scene: Control, lid: String, kinds: Array, title: String, redraw: Callable) -> void:
	var old := scene.get_node_or_null("HubShop")
	if old:
		old.name = "HubShopOld"      # (rebuilt from one of its own buttons: freed once that press is over)
		old.queue_free()
	var p := Campaign.progress()
	var offs := HubGrow.offers(lid, kinds, p)
	HubGrow.mark_seen(offs.map(func(o: Dictionary) -> String: return "offer:" + String(o["id"])))
	var pan := PanelContainer.new()
	pan.name = "HubShop"
	pan.add_theme_stylebox_override("panel", UiStyle.box(Color(0.08, 0.065, 0.05, 0.96), UiStyle.TRIM, 2, 10, 12.0))
	var s := scene.size
	pan.position = Vector2(s.x * 0.04, s.y * 0.04)
	pan.size = Vector2(s.x * 0.92, s.y * 0.92)
	scene.add_child(pan)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	pan.add_child(outer)
	var head := HBoxContainer.new()
	outer.add_child(head)
	var t := UiStyle.heading(Loc.t(title), 26, UiStyle.TRIM)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(t)
	var close: Button = main._button("CLOSE", func() -> void:
		pan.queue_free()
		redraw.call())
	close.name = "ShopClose"
	close.custom_minimum_size = Vector2(120, 44)
	head.add_child(close)
	var cur := String(HubGrow.line(lid).get("currency", ""))
	var money := UiStyle.text(Loc.t("%s to spend: %d (%d earned in all)") % [Loc.t(cur), HubGrow.purse(lid, p), HubGrow.earned(lid, p)],
		17, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT, true)
	money.name = "ShopPurse"
	money.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	outer.add_child(money)
	outer.add_child(CampaignMenu._wrap(Loc.t("Earn more by winning this line's missions and their optional objectives.") + " "
		+ Loc.t("Only in this line's own missions, played solo."), 13, UiStyle.MUTED))
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(sc)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 6)
	sc.add_child(list)
	var again := func() -> void: shop(main, scene, lid, kinds, title, redraw)
	var msg := UiStyle.text("", 14, UiStyle.BAD, HORIZONTAL_ALIGNMENT_LEFT, true)
	msg.name = "ShopMsg"
	for kind in kinds:
		var these: Array = offs.filter(func(o: Dictionary) -> bool: return o["type"] == kind)
		if these.is_empty():
			continue
		var cap := {"upgrades": "UPGRADES: bought once, for good.",
			"choices": "CHOOSE ONE",
			"blessings": "BLESSING: one at a time, for every mission of this line until you change it.",
			"helpers": "COMPANY: one at a time, called into every mission of this line until you change it."}
		list.add_child(UiStyle.text(Loc.t(cap[kind]), 15, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_LEFT, true))
		for o in these:
			match String(kind):
				"upgrades":
					var have := HubGrow.bought(String(o["id"]), p)
					var b: Button = main._button((Loc.t("BOUGHT") if have else Loc.t("BUY  (%d)") % int(o.get("cost", 0))), func() -> void:
						var why := HubGrow.buy(String(o["id"]))
						if why == "":
							again.call()
						else:
							msg.text = Loc.t(why) if why.find("%") < 0 else Loc.t("Not enough %s.") % Loc.t(cur))
					b.name = "Buy_" + String(o["id"])
					b.disabled = have or HubGrow.purse(lid, p) < int(o.get("cost", 0))
					_row(list, String(o["label"]), String(o["about"]), [b])
				"choices":
					var open := HubGrow.choice_open(o, p)
					var now := String((HubGrow.state(p)["choices"] as Dictionary).get(String(o["id"]), ""))
					list.add_child(UiStyle.text(Loc.t(String(o["label"])) + ("" if open else "  " + Loc.t("Opens when %d have been earned in all.") % int(o.get("at", 0))),
						15, UiStyle.TEXT if open else UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT, true))
					for ab in ["a", "b"]:
						var sd: Dictionary = o[ab]
						var b: Button = main._button(Loc.t("PICKED") if now == ab else Loc.t("PICK"), func() -> void:
							HubGrow.choose(String(o["id"]), "" if now == ab else ab)
							again.call())
						b.name = "Choose_%s_%s" % [String(o["id"]), ab]
						b.disabled = not open
						if now == ab:
							UiStyle.chosen(b)
						_row(list, String(sd.get("label", "")), String(sd.get("about", "")), [b])
				"blessings", "helpers":
					var now := HubGrow.picked(String(kind), lid, p)
					var b: Button = main._button(Loc.t("PICKED") if now == String(o["id"]) else Loc.t("PICK"), func() -> void:
						HubGrow.pick(String(kind), lid, "" if now == String(o["id"]) else String(o["id"]))
						again.call())
					b.name = "Pick_" + String(o["id"])
					if now == String(o["id"]):
						UiStyle.chosen(b)
					_row(list, String(o["label"]), String(o["about"]), [b])
	if offs.is_empty():
		list.add_child(CampaignMenu._wrap(Loc.t("Not open yet."), 15, UiStyle.MUTED))
	outer.add_child(msg)


static func _row(list: VBoxContainer, label: String, about: String, btns: Array) -> void:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	list.add_child(h)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	v.add_child(UiStyle.text(Loc.t(label), 16, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_LEFT, true))
	v.add_child(CampaignMenu._wrap(Loc.t(about), 14, UiStyle.MUTED))
	for b in btns:
		(b as Button).auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		(b as Button).custom_minimum_size = Vector2(130, 44)
		(b as Button).size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(b)


# ------------------------------------------------------------------ the briefing and the end

## The briefing: what this mission gets from the hub (only when something does).
static func brief(v: VBoxContainer, mid: String, side: String) -> void:
	var ls := HubGrow.brief_lines(mid, side)
	if ls.is_empty():
		return
	var cap := UiStyle.text(Loc.t("FROM THE HUB (solo):") + "  " + Loc.t("(change them in the hub)"), 18, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_LEFT, true)
	cap.name = "BriefHub"
	cap.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	v.add_child(cap)
	for l in ls:
		var w := CampaignMenu._wrap("-  " + String(l), 15, UiStyle.GOOD)
		w.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		v.add_child(w)


## The end of a mission: its line's purse grows (the best run counts); a line for the end panel ("" none).
static func end_line(game: Game, won: bool) -> String:
	if game.has_meta("hub_award"):
		return String(game.get_meta("hub_award"))
	var run := game.mission
	var out := ""
	if run != null and game.net == null:
		var a := HubGrow.award(run.id, run.my_side(), won, HubGrow.optional_done(run, run.my_side()), run.mode)
		if not a.is_empty():
			out = Loc.t("+%d %s (best run of this mission: %d)") % [int(a["new"]), Loc.t(String(a["currency"])), int(a["got"])]
	game.set_meta("hub_award", out)
	return out
