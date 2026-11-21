extends "res://tools/playtest/tutorial_editor/pt_base.gd"
## A phone in the Brood lesson: a grub sent to a Rootmaw by taps (select it, tap the Rootmaw), as the lesson asks.
func play() -> void:
	await press_button("Menu_tutorial")
	await wait(0.4)
	await press_button("Lesson_t30_brood")
	await wait(0.4)
	await press_button("Lesson_Start")
	await wait(4.5)
	var g := game()
	var maw: Unit = null
	for u in g.units:
		if u.team == g.human and u.kind == BroodNew.MAW and not u.dead:
			maw = u
	note("the Rootmaw: %s, its grubs %d" % [maw.position, WorkerLabels.workers(g, maw).size()])
	# a grub not on it
	var gs: Array = g.units.filter(func(u) -> bool: return u.team == g.human and u.kind == "grub" and not u.dead)
	for k in 2:
		var gr: Unit = gs[k]
		gr.cmd_stop() if gr.has_method("cmd_stop") else null
		await wait(0.5)
		if not in_view(gr.position):
			await look_at(gr.position)
		await tap(world_to_screen(gr.position))
		await wait(0.6)
		note("tap on a grub: selection %s" % str(g.selection.map(func(e) -> String: return e.kind)))
		var at = g.entity_at(maw.position, false)
		note("  entity_at the Rootmaw: %s" % (at.kind if at else "nothing"))
		await tap(world_to_screen(maw.position))
		await wait(0.6)
		note("  tap on the Rootmaw: selection %s; grub order %s; the Rootmaw's grubs %d" % [str(g.selection.map(func(e) -> String: return e.kind)), gr.order, WorkerLabels.workers(g, maw).size()])
		await shot("grub_%d" % k)
