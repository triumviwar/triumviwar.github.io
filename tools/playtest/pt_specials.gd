extends "res://tools/playtest/pt_card_cover.gd"
## The Crown's special buttons used for real (docs/playtest_2026_11_21_skirmish_crown.md), in a SANDBOX match: the
## Horse Breeder (HORSE, the CAVALRY CHARGE), the band (Drummer, Fifer, Piper standing together, SELECT BAND, a SOLO,
## Ctrl+SOLO), the Field Cannon (UNLIMBER / LIMBER, CANISTER / ROUND SHOT), the Mortar (DEPLOY), the balloon (LOAD
## Musketeers, fly, UNLOAD), RELOAD with empty Musketeers (ARM WITH POWDER off), ATTACK GROUND, rally points.
## Units come from the sandbox panel's spawn list (as a player using SANDBOX would).

var fails := 0
var nokey := true


func check(name: String, ok: bool, detail := "") -> void:
	print("PT CHECK %s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1
		finding("SPECIALS %s: %s" % [name, detail])


func sel_kinds() -> Array:
	return game().selection.filter(func(x) -> bool: return is_instance_valid(x)).map(func(x) -> String: return x.kind)


## The sandbox spawn list: press the row with this name, then a click on the map.
func spawn(name: String, w: Vector2, n := 1) -> void:
	var sb := nth_button("SANDBOX >", 0)
	if sb:
		await press_control(sb)
		await frames(3)
	for i in n:
		var row := nth_button("  " + name, 0)
		if row == null:
			for b in buttons():
				if button_text(b).strip_edges().to_upper() == name.to_upper():
					row = b
					break
		if row == null:
			finding("SANDBOX: no spawn row '%s'" % name)
			break
		var sc: ScrollContainer = row.get_parent().get_parent() as ScrollContainer
		if sc:
			sc.ensure_control_visible(row)
			await frames(2)
		await press_control(row)
		await frames(2)
		var at := w + Vector2(i % 4, i / 4) * 26.0
		if not on_screen(w2s(at), 60) or w2s(at).x > vp_size().x - 340:
			# (the panel covers the right: move the view with the arrow keys so the spot sits left of it)
			game().camera.position = at + Vector2(200, 0) if false else game().camera.position
			await look_at(at)
		await click(w2s(at))
		await frames(2)
		step("spawn %s: %s" % [name, toast_text()])
	var sc2 := nth_button("SANDBOX <", 0)
	if sc2:
		await press_control(sc2)
		await frames(3)


func run() -> void:
	await wait_real(1.0)
	await press_button("EDITOR")
	await press_button("SANDBOX")
	await press_button("1v1")
	await pick_in_slot(0, 1, "CROWN")
	await pick_in_slot(1, 0, "EASY AI")
	await pick_in_slot(1, 1, "BROOD")
	await press_button("START")
	await wait_match()
	for i in 6:
		await press_control(nth_button("+1000", 0))
	for i in 4:
		await press_control(nth_button("+200", 0))
	await press_button("2")
	await press_button("AI: ON")
	await press_button("» 1")
	await press_button("SANDBOX <")
	var g := game()
	var hall = my_buildings("town_hall")[0]
	var l0 = free_labourer()
	await look_at(ent_point(l0))
	await double_click(w2s(ent_point(l0)))
	await settle()
	await ctrl_key(KEY_2)
	Engine.time_scale = 4.0
	for stage in [["cottage", "horse_breeder", "cottage"], ["barracks"], ["armoury", "foundry"]]:
		for k in stage:
			await build_one(k)
		for k in stage:
			await wait_built(k)
	var base: Vector2 = hall.position + Vector2(200, 200)
	await shot("sandbox_base")
	step("buildings: %s" % str(my_buildings().map(func(b) -> String: return "%s%s" % [b.kind, "" if b.built else "(site)"])))
	Engine.time_scale = 3.0
	# ---- the Horse Breeder
	var br := my_buildings("horse_breeder")
	if not br.is_empty():
		await select_ent(br[0])
		step("BREEDER card: " + ", ".join(card_labels()))
		await shot("card_breeder")
		await card("HORSE")
		await card("CHARGE")
		await settle()
		step("breeder queue: %s" % str(br[0].queue))
	# ---- the band: train each musician at the Armoury, stand them together
	var arm := my_buildings("armoury")
	if not arm.is_empty():
		await select_ent(arm[0])
		step("ARMOURY card: " + ", ".join(card_labels()))
		for m in ["DRUMMER", "FIFER", "PIPER"]:
			var r := await card(m)
			step("train %s: %s" % [m, r])
		await card("RALLY")
		await click(w2s(base + Vector2(60, 60)))
		await wait(60)
		var musicians := my_units().filter(func(u) -> bool: return u.kind in ["band", "band_fifer", "band_piper"])
		step("musicians: %s" % str(musicians.map(func(u) -> String: return u.kind)))
		check("band_trained", musicians.size() == 3, str(musicians.map(func(u) -> String: return u.kind)))
		if musicians.size() >= 2:
			# select them all with a box, move them together
			var rr := Rect2(w2s(musicians[0].position), Vector2.ZERO)
			for u in musicians:
				rr = rr.expand(w2s(u.position + Vector2(0, -12)))
			await look_at(musicians[0].position)
			rr = Rect2(w2s(musicians[0].position), Vector2.ZERO)
			for u in musicians:
				rr = rr.expand(w2s(u.position + Vector2(0, -12)))
			await drag(rr.position - Vector2(30, 30), rr.end + Vector2(30, 30))
			await settle()
			await wait(8)
			step("band selection %s card %s" % [str(sel_kinds()), ", ".join(card_labels())])
			await rclick(w2s(base + Vector2(100, 40)))
			await wait(6)
			await shot("band_together")
			await key(KEY_ESCAPE)
			await select_ent(musicians[0])
			var sb := find_card("SELECT BAND")
			check("band_formed", not sb.is_empty() and sb["enabled"], "card %s" % ", ".join(card_labels()))
			if not sb.is_empty() and sb["enabled"]:
				await card("SELECT BAND")
				await settle()
				check("select_band", game().selection.size() == 3, str(sel_kinds()))
			var solo := ""
			for l in card_labels():
				if String(l).contains("SOLO"):
					solo = String(l).trim_suffix("(x)")
			if solo != "":
				await card(solo)
				await settle()
				step("SOLO '%s': toast '%s'" % [solo, toast_text()])
				await shot("solo")
				_ctrl = true
				await card(solo)
				_ctrl = false
				await settle()
				step("Ctrl+SOLO: toast '%s'" % toast_text())
	# ---- guns: spawn a Field Cannon and a Mortar
	var fd := my_buildings("foundry")
	if not fd.is_empty():
		await select_ent(fd[0])
		await card("FIELD CANNON")
		await card("MORTAR")
		await card("OBSERVATION BALLOON")
		await wait(110)
	var guns := my_units("cannon")
	if not guns.is_empty():
		var c = guns[0]
		await select_ent(c)
		step("CANNON card: " + ", ".join(card_labels()))
		await card("UNLIMBER")
		await wait(5)
		await settle()
		step("after UNLIMBER: card %s" % ", ".join(card_labels()))
		check("unlimber", not find_card("LIMBER").is_empty(), ", ".join(card_labels()))
		await card("CANISTER")
		await settle()
		step("after CANISTER: card %s toast '%s'" % [", ".join(card_labels()), toast_text()])
		check("canister_toggles", not find_card("ROUND SHOT").is_empty(), ", ".join(card_labels()))
		await card("ROUND SHOT")
		await card("LIMBER")
		await wait(5)
		await settle()
		check("limber", not find_card("UNLIMBER").is_empty(), ", ".join(card_labels()))
		await shot("cannon")
	var mortars := my_units("mortar")
	if not mortars.is_empty():
		await select_ent(mortars[0])
		step("MORTAR card: " + ", ".join(card_labels()))
		await card("DEPLOY")
		await wait(5)
		await settle()
		check("mortar_deploy", not find_card("PACK").is_empty(), ", ".join(card_labels()))
		# attack ground with the mortar (Ctrl+A, a spot)
		await ctrl_key(KEY_A)
		await click(w2s(base + Vector2(300, 200)))
		await settle()
		step("mortar Ctrl+A: order '%s' toast '%s'" % [mortars[0].order, toast_text()])
	# ---- Musketeers with no powder: ARM WITH POWDER off, RELOAD
	var rax := my_buildings("barracks")
	if not rax.is_empty():
		await select_ent(rax[0])
		await card("ARM WITH POWDER")
		await settle()
		step("ARM WITH POWDER off: toast '%s'" % toast_text())
		for i in 4:
			await card("MUSKETEER")
		await card("ARM WITH POWDER")
		await wait(70)
		var muskets := my_units("musketeer")
		step("musketeers: %d, shots %s" % [muskets.size(), str(muskets.map(func(u) -> int: return int(u.powder)))])
		if not muskets.is_empty():
			await select_ent(muskets[0])
			_ctrl = true
			await click(w2s(ent_point(muskets[0])))
			_ctrl = false
			await settle()
			var rl := find_card("RELOAD")
			step("RELOAD button: %s" % (("enabled" if rl["enabled"] else "off: " + rl["why"]) if not rl.is_empty() else "missing"))
			await key(KEY_R)
			await settle()
			step("R: toast '%s' orders %s" % [toast_text(), str(muskets.map(func(u) -> String: return u.order))])
			await wait(15)
			step("after reload: shots %s" % str(muskets.map(func(u) -> int: return int(u.powder))))
	# ---- the balloon: LOAD musketeers, fly, UNLOAD
	var balloons := my_units("balloon")
	var muskets2 := my_units("musketeer")
	if not balloons.is_empty() and muskets2.size() >= 2:
		var bl = balloons[0]
		await select_ent(bl)
		await card("LOAD")
		await click(w2s(ent_point(muskets2[0])))
		await settle()
		step("LOAD then a musketeer: mode '%s' toast '%s'" % [hud().controls.mode, toast_text()])
		await wait(8)
		var aboard: int = bl.passengers.size()
		step("aboard after 8 s: %d" % aboard)
		check("balloon_load", aboard >= 1, "aboard %d" % aboard)
		await select_ent(bl)
		await rclick(w2s(base + Vector2(-400, -200)))
		await wait(8)
		await select_ent(bl)
		await card("UNLOAD")
		await settle()
		step("UNLOAD: mode '%s' toast '%s'" % [hud().controls.mode, toast_text()])
		if hud().controls.mode == "unload":
			await click(w2s(bl.position + Vector2(60, 40)))
		await wait(6)
		aboard = bl.passengers.size()
		check("balloon_unload", aboard == 0, "aboard %d" % aboard)
		await shot("balloon")
	step("CHECKS failed %d" % fails)
