extends "res://tools/playtest/brood_probe.gd"
## Playtest (job brood-mother-uproot, docs/brood_mother_uproot.md): the Mother gets up and roots again, BY HAND (input
## only, the sandbox with the enemy's computer off): two more Rootmaws on her swamp, UPROOT her (her swamp lingers, the
## Rootmaws wait: pictures of the fading swamp, the "waiting" marks, their card and hers), ROOT her again on it (they
## feed again), then up and away past the linger (they uproot), back and ROOT (they root again by themselves).
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 --script res://tools/playtest/brood_linger.gd -- [mobile] [lang=pt]
## Pictures: docs/shots/brood_mother_uproot/ (pt.shots_dir).


func _run() -> void:
	pt.shots_dir = "res://docs/shots/brood_mother_uproot/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pt.shots_dir))
	pt.tag = "linger_%s%s" % ["phone" if mobile else "pc", ("_" + o["lang"]) if o["lang"] != "en" else ""]
	await pt.frames(5)
	if not await pt.into_match(main, {"opp": "crown", "who": "easy", "plan": "BALANCED", "map": "HOLLOWFEN", "sandbox": true, "lang": o["lang"]}):
		_end(1)
		return
	g = main.game
	hud = g.hud
	me = g.human
	await pt.secs(4.0)
	await sandbox_panel(true)
	for b in pt.all_buttons(root):
		if b is Button and String((b as Button).text).strip_edges().trim_prefix("»").strip_edges() == "2":
			await pt.click_control(b)
			break
	await pt.click_text("AI: ON")
	for b in pt.all_buttons(root):
		if b is Button and String((b as Button).text).strip_edges().trim_prefix("»").strip_edges() == "1":
			await pt.click_control(b)
			break
	await sandbox_panel(false)
	Engine.time_scale = 2.0
	await give(2, 0)
	var q := mother()
	# two more Rootmaws on her swamp (grubs turned into them, by hand)
	for i in 2:
		var spot := find_spot(BroodNew.MAW, q.position, 6.0, 12.0)
		if spot != Vector2.INF:
			await grub_to(BroodNew.MAW, spot)
	await wait_game(40.0)
	var before := rooted_maws()
	probe(before >= 2, "Rootmaws rooted on her swamp: %d" % before)
	await look(q.position)
	await pt.shot("rooted")
	# UPROOT her
	await select_mother()
	await card("UPROOT")
	await wait_game(q.switch_time() + 6.0)
	probe(rooted_maws() == before, "UPROOT: 6 s after she is up the Rootmaws stay rooted (%d of %d)" % [rooted_maws(), before])
	probe(mine(BroodNew.MAW).all(func(m: Unit) -> bool: return not BroodNew.rooted(m) or m.nb.has("wait")), "and they all wait")
	await select_mother()
	await pt.shot("up_mother_card")
	var m0: Unit = mine(BroodNew.MAW).filter(func(m: Unit) -> bool: return m.nb.has("wait"))[0] if mine(BroodNew.MAW).any(func(m: Unit) -> bool: return m.nb.has("wait")) else null
	if m0:
		await select_unit(m0)
		await pt.shot("waiting_rootmaw_card")
	await wait_game(BroodNew.LINGER - 22.0)
	await pt.key(KEY_ESCAPE)
	await look(q.position)
	await pt.shot("lingering_fading")
	probe(rooted_maws() == before, "%d s up: still rooted (%d)" % [int(BroodNew.LINGER - 8.0), rooted_maws()])
	# ROOT her again where she stands (on her lingering swamp)
	await select_mother()
	if await card("ROOT"):
		await place_root(BroodNew.QUEEN, mother().position, false)
	await wait_game(q.switch_time() + 8.0)
	probe(BroodNew.rooted(q) and not q.nb.has("lgu"), "rooted again on it: her own swamp took over")
	probe(not mine(BroodNew.MAW).any(func(m: Unit) -> bool: return m.nb.has("wait")), "no Rootmaw waits any more")
	await pt.shot("rooted_again")
	# up and away past the linger
	await select_mother()
	await card("UPROOT")
	await wait_game(q.switch_time() + 1.0)
	var home := q.position
	await click_world(home + Vector2(0, 8) * Defs.TILE, MOUSE_BUTTON_RIGHT)
	await wait_game(BroodNew.LINGER + 12.0)
	probe(rooted_maws() == 0, "away past the linger: the Rootmaws uprooted (%d rooted)" % rooted_maws())
	await look(home)
	await pt.shot("swamp_gone")
	await select_mother()
	await click_world(home, MOUSE_BUTTON_RIGHT)
	await wait_game(12.0)
	await select_mother()
	if await card("ROOT"):
		await place_root(BroodNew.QUEEN, mother().position, false)
	await wait_game(q.switch_time() + 30.0)
	probe(rooted_maws() == before, "she roots again: the Rootmaws rooted again by themselves (%d of %d)" % [rooted_maws(), before])
	await look(home)
	await pt.shot("rooted_back_by_themselves")
	Engine.time_scale = 1.0
	_end(0)
