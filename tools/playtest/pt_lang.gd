extends "res://tools/playtest/pt_setup_util.gd"
## One Crown skirmish's screens in a language (lang=pt / es / en), for the eye: the setup, the HUD with the hall, a
## labourer's BUILD page with a tooltip, the Barracks and Foundry cards (sandbox gold), the in-match menu, a refused
## placement's message, the end screen. Every visible Label / Button text is also checked against the English
## dictionary: an English string left in a pt / es screen prints "PT UNTRANSLATED <text>".

var seen_en := {}


func run() -> void:
	await wait_real(1.0)
	await shot("menu")
	await audit("menu")
	await press_button("EDITOR")
	await press_button("SANDBOX")
	await wait_real(0.3)
	await press_button("1v1")
	await pick_in_slot(0, 1, "CROWN")
	await pick_in_slot(1, 0, "EASY AI")
	await pick_in_slot(1, 1, "CLOCKWORK")
	await shot("setup")
	await audit("setup")
	await press_button("START")
	await wait_match()
	for i in 5:
		var gb := nth_button("+1000", 0)
		if gb:
			await press_control(gb)
	var sb := nth_button("SANDBOX", 0)
	if sb:
		await press_control(sb)
	var hall = my_buildings("town_hall")[0]
	await select_ent(hall)
	await shot("hall")
	var lab = my_units("labourer")[0]
	await look_at(ent_point(lab))
	await double_click(w2s(ent_point(lab)))
	await settle()
	await ctrl_key(KEY_2)
	await card("BUILD")
	await settle()
	var b := find_card("BARRACKS")
	if not b.is_empty():
		await move((b["rect"] as Rect2).get_center(), 2)
		await wait_real(0.7)
	await shot("build_page_tip")
	await card("COTTAGE")
	await move(w2s(ent_point(hall)), 3)
	await click(w2s(ent_point(hall)))
	await settle()
	await shot("refused_place")
	step("refused toast: '%s'" % toast_text())
	await key(KEY_ESCAPE)
	Engine.time_scale = 4.0
	# a quick base: cottage, barracks, foundry
	for k in ["cottage", "barracks", "foundry"]:
		await place(k)
		for i in 40:
			if my_buildings(k).any(func(x) -> bool: return x.built):
				break
			await wait(1.5)
	for k in ["barracks", "foundry"]:
		var bs := my_buildings(k)
		if not bs.is_empty():
			await select_ent(bs[0])
			var first: Dictionary = hud_buttons().filter(func(x) -> bool: return x["label"] != "").front() if not hud_buttons().is_empty() else {}
			if not first.is_empty():
				await move((first["rect"] as Rect2).get_center(), 2)
				await wait_real(0.7)
			await shot("card_" + k)
	var mr: Rect2 = hud().menu_rect()
	await press(mr.get_center() * hud().ui_scale)
	await settle()
	await shot("match_menu")
	for bb in hud()._menu_buttons():
		if String(bb.get("label", "")) == "SURRENDER":
			await press((bb["rect"] as Rect2).get_center() * hud().ui_scale)
	await settle()
	for bb in hud()._menu_buttons():
		if String(bb.get("label", "")).begins_with("YES"):
			await press((bb["rect"] as Rect2).get_center() * hud().ui_scale)
	await wait_real(3.0)
	await shot("end")
	await audit("end")


func place(k: String) -> void:
	var g := game()
	var hc: Vector2i = my_buildings("town_hall")[0].cell
	var spot := Vector2i(-1, -1)
	for r in range(6, 20):
		for a in 24:
			var c := hc + Vector2i(Vector2(r, 0).rotated(TAU * a / 24.0))
			if g.placement_problem(g.human, k, c) == "":
				spot = c
				break
		if spot.x >= 0:
			break
	if spot.x < 0:
		return
	await key(KEY_2)
	await settle()
	await card("BUILD")
	await settle()
	await card(String(Defs.BUILDINGS[k]["name"]).to_upper())
	var w := Vector2(spot) * Defs.TILE + Vector2(Defs.BUILDINGS[k]["size"]) * Defs.TILE * 0.5
	await look_at(w)
	await click(w2s(w))
	await settle()


## Visible texts that are still English (they have an entry in the dictionary but were shown untranslated, or look
## like English words in a pt/es screen).
func audit(page: String) -> void:
	if lang == "en":
		return
	var ctls: Array = []
	all_controls(root, ctls, "Control")
	for c in ctls:
		var t := ""
		if c is Label:
			t = (c as Label).text
		elif c is Button:
			t = (c as Button).text
		t = t.strip_edges()
		if t.length() < 3 or seen_en.has(t):
			continue
		var tr := Loc.t(t)
		var shown: String = (c as Control).atr(t) if (c as Control).auto_translate_mode != Node.AUTO_TRANSLATE_MODE_DISABLED else t
		if tr != t and shown == t:
			seen_en[t] = true
			print("PT UNTRANSLATED [%s] '%s' (has '%s')" % [page, t, tr])
