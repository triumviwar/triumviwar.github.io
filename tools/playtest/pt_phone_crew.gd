extends "res://tools/playtest/pt_base.gd"
## A phone in the Crown lesson: two Labourers sent into a Powder Mill by taps (select one, tap the Mill), as the
## lesson asks. Prints what each tap did.
func play() -> void:
	await press_button("Menu_tutorial")
	await wait(0.4)
	await press_button("Lesson_t10_crown")
	await wait(0.4)
	await press_button("Lesson_Start")
	await wait(4.5)
	var g := game()
	var hall: Building = g.mission.tagged("hall")[0]
	var c := g.find_spot(g.human, "powder_mill", hall, 3, 10)
	for dx in range(4, 14):
		var cc := g.cell_of(hall.center()) + Vector2i(dx, 3)
		if g.placement_problem(g.human, "powder_mill", cc) == "":
			c = cc
			break
	var mill: Building = g.place_building(g.human, "powder_mill", c, [])
	mill.built = true
	mill.hp = mill.max_hp
	await wait(1.0)
	var lab = WorkerLabels.at(g, mill.center())
	note("mill cell %s rect %s centre %s sprite %s; hall cell %s rect %s sprite %s; label at the centre: %s" % [mill.cell, mill.rect(), mill.center(), mill.sprite_rect(), hall.cell, hall.rect(), hall.sprite_rect(), lab.kind if lab else "none"])
	for b in g.buildings:
		if b.team == g.human:
			note("  building %s cell %s rect %s sprite %s" % [b.kind, b.cell, b.rect(), b.sprite_rect() if b.sprite and b.sprite.texture else Rect2()])
	for k in 1:
		var ws: Array = g.units.filter(func(u) -> bool: return u.team == g.human and u.kind == "labourer" and not u.dead and not WorkerLabels.workers(g, mill).has(u))
		var u: Unit = ws[0]
		if not in_view(u.position):
			await look_at(u.position)
		await tap(world_to_screen(u.position))
		await wait(0.6)
		note("tap %d on a labourer: selection %s" % [k, str(g.selection.map(func(e) -> String: return e.kind))])
		if not in_view(mill.center()):
			await look_at(mill.center())
		var at = g.entity_at(mill.center(), false)
		note("  entity_at the Mill's middle: %s" % (at.kind if at else "nothing"))
		await tap(world_to_screen(mill.center()))
		await wait(0.6)
		note("  tap on the Mill: selection %s; that labourer's order %s target %s; the Mill's workers %d" % [str(g.selection.map(func(e) -> String: return e.kind)), u.order, str(u.get("target")), WorkerLabels.workers(g, mill).size()])
		await wait(4.0)
		note("  4 s later the Mill's workers %d" % WorkerLabels.workers(g, mill).size())
		await shot("crew_%d" % k)
