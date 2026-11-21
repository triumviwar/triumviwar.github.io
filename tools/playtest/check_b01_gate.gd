extends SceneTree
## A check (playtest-campaign-brood): in "Specimen One", what does a right-click on the pen's gate give the pack?
##   godot --headless --path . --script res://tools/playtest/check_b01_gate.gd
func _initialize() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred(main)


func _run(main) -> void:
	await process_frame
	main.start(Campaign.make_cfg("b01_specimen", "solo"))
	await process_frame
	await process_frame
	var g: Game = main.game
	var r: MissionRun = g.mission
	var gate = r.tagged("pen_gate")[0]
	var me := g.human
	var raps: Array = g.units.filter(func(u): return u.team == me and u.kind == "raptor")
	print("GATE kind=%s team=%d hostile=%s spared=%s center=%s cell=%s size=%s" % [gate.kind, gate.team, g.hostile(gate.team, me), gate.get("spared"), gate.center(), gate.cell if "cell" in gate else "?", gate.get("size")])
	for b in g.buildings:
		if b.position.distance_to(gate.position) < 160.0:
			b.visible = true          # (as when the pack stands by the pen: no fog)
			print("near: %s team %d cell %s rect %s spared %s hp %d" % [b.kind, b.team, g.cell_of(b.center()), b.rect(), b.get("spared"), b.hp])
	for d in [Vector2.ZERO, Vector2(0, -6), Vector2(8, 0), Vector2(0, 10), Vector2(-10, 0)]:
		var e = g.entity_at(gate.center() + d)
		print("entity_at center+%s -> %s %s" % [d, e.kind if e else "null", (e.team if e else -1)])
	for u in raps:
		u.position = gate.center() + Vector2(-200, 0)
	g.smart_command(raps, gate.center())
	await process_frame
	print("after smart_command: ", raps.map(func(u): return [u.order, u.target.kind if u.target else null]))
	for i in 300:
		await physics_frame
	print("5 s later: ", raps.map(func(u): return [u.order, u.target.kind if u.target else null, int(u.position.distance_to(gate.center()))]), " gate hp ", gate.hp)
	quit()
