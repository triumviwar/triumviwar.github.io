extends "res://tools/playtest/pt_mission.gd"
## A phone player (taps only) in the Crown missions' screens: p01's opening read with taps on the picture, the match's
## HUD with the dialogue box, a tap on ARMY and on the command card, the MENU (PAUSE, RESUME), the two story CHOICES
## shown on this screen (families, then Varenne: offered by the driver itself, a shortcut to see their layout), the
## objectives folded, SURRENDER, the end panel, the battle report. Then Rome's verdict (the show over the match).
##   -- device=phone lang=en|pt|es   (run at 844x390)


func setup() -> void:
	mid = "p01_leaf"
	args["progress"] = "all"
	super.setup()
	tag = "phone_%s_%s" % [device, lang]


func play() -> void:
	if not await enter("map"):
		return
	# the opening: taps on the picture (not the buttons)
	var n := 0
	while by_name("StillShow") and n < 40:
		if n < 3:
			await shot("01_opening_%d" % n)
		await tap_at(Vector2(root.get_visible_rect().size.x * 0.5, root.get_visible_rect().size.y * 0.3))
		n += 1
		await frames(3)
	note("opening: %d taps on the picture" % n)
	for i in 300:
		await frames(1)
		if g():
			break
	if not check("the match starts", g() != null):
		return
	g().mission.said.connect(func(ln: Dictionary) -> void: said.append([0.0, String(ln.get("id", "")), String(ln.get("name", "")), String(ln.get("text", ""))]))
	await play_for(8.0, 2.0)
	await shot("02_hud_dialogue")
	off_screen("phone hud")
	# ARMY on the hotkey bar (a tap), then the card's first button
	var hb: Variant = hud().bar
	note("hud scale %.2f; minimap %s; card %s" % [hud().ui_scale, hud().mini_rect(), hud().card_rect()])
	if hb and hb.has_method("rect_of"):
		await tap_at(to_window(hud(), hb.rect_of(1).get_center()))
	else:
		await key(KEY_F2)
	await frames(3)
	note("after ARMY: %d selected; card %s" % [g().selection.size(), card_labels()])
	await shot("03_army")
	# MENU: PAUSE, then RESUME from the small panel
	await menu_open()
	await shot("04_menu")
	off_screen("phone menu")
	note("menu: %s" % [menu_labels()])
	await menu_press("PAUSE")
	await menu_press("BACK TO THE MATCH")
	await shot("05_paused")
	var pb: Array = hud()._paused_buttons()
	if not pb.is_empty():
		await tap_at(to_window(hud(), (pb[0]["rect"] as Rect2).get_center()))
	await frames(5)
	check("RESUME by a tap", not paused and not hud().paused)
	# the families choice, as it comes after the first camp (offered here to see it on a phone)
	var fam := {}
	for t in r().data["triggers"]:
		if String(t["id"]) == "camp1_down":
			for a in t["do"]:
				if a.has("choice"):
					fam = a["choice"]
	r().offer_choice(fam)
	await frames(5)
	await shot("06_choice_families")
	off_screen("phone choice families")
	cut_text("phone choice families")
	note("choice on a phone: %s" % labels_text().left(300))
	await tap_at(centre_of(by_name("Choose_save")))
	await frames(3)
	check("a tap on SAVE THE FAMILIES answers", r().flags.get("families", "") == "save", str(r().flags))
	# SURRENDER, the end panel, the report
	await menu_open()
	await menu_press("SURRENDER")
	await menu_press("YES, SURRENDER")
	await ending(false)
	await press_name("End_BATTLE_REPORT")
	await frames(10)
	await shot("10_report")
	off_screen("phone battle report")
	flush_errors("phone p01")
	# back to the campaign: Rome, its verdict over the match on a phone
	main._to_menu()
	await frames(5)
	main.start(Campaign.make_cfg("a07_council", "solo", "p1", false))
	for i in 400:
		await frames(1)
		if by_name("StillShow"):
			break
	await shot("20_verdict")
	off_screen("phone verdict")
	var s: Node = by_name("StillShow")
	if s:
		var i0: int = s._i
		await tap_at(centre_of(by_name("Show_NEXT")))
		check("phone: a tap on the verdict's NEXT moves it on", s._i > i0)
		await tap_at(centre_of(by_name("Show_SKIP")))
		await frames(3)
		check("phone: SKIP ends the verdict", by_name("StillShow") == null)
	# a06's Varenne verdict on a phone
	main._to_menu()
	await frames(5)
	Campaign.save_progress(prog_for("a01"))
	main.start(Campaign.make_cfg("a06_barricades", "solo", "p1", false))
	await frames(30)
	var ch := {}
	for t in r().data["triggers"]:
		if String(t["id"]) == "verdict":
			for a in t["do"]:
				if a.has("choice"):
					ch = a["choice"]
	r().offer_choice(ch)
	await frames(5)
	await shot("21_choice_varenne")
	off_screen("phone choice varenne")
	note("Varenne's choice on a phone: %s" % labels_text().left(300))
	flush_errors("phone end")
