extends "res://tools/playtest/pt_mission.gd"
## A probe: Paris's Field Cannons emptied of powder (state set by the probe), limbered or unlimbered, then RELOAD (R) with
## real input: do they go to the camp's powder and come back full?
func setup() -> void:
	mid = "a06_barricades"
	args["progress"] = "a01"
	super.setup()
	tag = "reloadprobe"


func play() -> void:
	main.start(Campaign.make_cfg(mid, "solo", "p1", false))
	await frames(10)
	await play_for(5.0, 2.0)
	var guns := team_units("army", ["cannon"])
	for u in guns:
		u.powder = 0.0
	# walk them out of the camp a little, as they were in the street
	await select_all(guns)
	await key(KEY_M)
	await click_at(mini_win(area("bar_1_front") + Vector2(6 * Defs.TILE, 0)))
	await play_for(25.0, 4.0)
	note("guns out: %s" % [guns.map(func(u: Unit) -> String: return "%s pow %.1f order %s at %s" % [u.kind, u.powder, u.order, g().cell_of(u.global_position)])])
	for unl in [false, true]:
		await select_all(guns)
		if unl:
			note("UNLIMBER: %s" % await card("UNLIMBER"))
			await play_for(4.0, 2.0)
		note("card: %s" % [card_labels()])
		await key(KEY_R)
		await play_for(2.0, 2.0)
		note("after R (%s): %s" % ["unlimbered" if unl else "limbered", guns.map(func(u: Unit) -> String: return "pow %.1f order %s" % [u.powder, u.order])])
		await play_for(40.0, 4.0)
		note("40 s later: %s" % [guns.map(func(u: Unit) -> String: return "pow %.1f order %s at %s" % [u.powder, u.order, g().cell_of(u.global_position)])])
		await shot("reload_%s" % unl)
		for u in guns:
			u.powder = 0.0
	flush_errors("reload probe")
