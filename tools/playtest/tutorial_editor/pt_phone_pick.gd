extends "res://tools/playtest/tutorial_editor/pt_base.gd"
## A phone in the Crown lesson: does a tap on a working Labourer select it? (look first, then tap it)
func play() -> void:
	await press_button("Menu_tutorial")
	await wait(0.4)
	await press_button("Lesson_t10_crown")
	await wait(0.4)
	await press_button("Lesson_Start")
	await wait(4.5)
	var g := game()
	for k in 4:
		var ws: Array = g.units.filter(func(u) -> bool: return u.team == g.human and u.kind == "labourer" and not u.dead)
		var u: Unit = ws[k % ws.size()]
		note("labourer %d order %s at %s visible %s; in view %s" % [k, u.order, u.position, u.visible, in_view(u.position)])
		if not in_view(u.position):
			await look_at(u.position)
			note("  after the minimap tap: in view %s, screen %s, camera %s" % [in_view(u.position), world_to_screen(u.position), g.camera.position])
		var sp := world_to_screen(u.position)
		var hit = g.entity_at(g.get_viewport().get_canvas_transform().affine_inverse() * sp, false)
		note("  entity_at the tap: %s" % (hit.kind if hit else "nothing"))
		await tap(sp)
		await wait(0.3)
		note("  after a tap: selection %s" % str(g.selection.map(func(e) -> String: return e.kind)))
		await shot("pick_%d" % k)
		await tap(screen_size() * Vector2(0.5, 0.35))
		await wait(0.2)
