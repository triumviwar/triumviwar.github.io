extends "res://tools/playtest/pt_mission.gd"
## A probe (Paris): can a player break a barricade's palisade with the Field Cannons the way a player would? Select the
## guns, march them 8 tiles before the first barricade, UNLIMBER, right-click a palisade piece; then (if nothing breaks)
## ATTACK GROUND (Ctrl+A) on it. Walls counted after each.
func setup() -> void:
	mid = "a06_barricades"
	args["progress"] = "a01"
	super.setup()
	tag = "wallprobe"


func play() -> void:
	main.start(Campaign.make_cfg(mid, "solo", "p1", false))
	await frames(10)
	await play_for(5.0, 2.0)
	var guns := team_units("army", ["cannon"])
	await select_all(guns)
	await key(KEY_M)
	await click_at(mini_win(area("bar_2") + Vector2(7 * Defs.TILE, 0)))
	await play_for(30.0, 4.0)
	note("guns at %s (bar at %s), orders %s" % [guns.map(func(u: Unit) -> Vector2i: return g().cell_of(u.global_position)), r().area_rect("bar_2"), guns.map(func(u: Unit) -> String: return u.order)])
	await select_all(guns)
	note("UNLIMBER: %s" % await card("UNLIMBER"))
	await play_for(5.0, 2.0)
	var walls: Array = r().tagged("bar_2_wall")
	var w0 := walls.size()
	var wt: Node2D = nearest(walls, centroid(guns))
	note("the piece at %s: shown to me %s, a ghost %s, entity_at its middle %s; distance to the guns %.1f tiles" % [wt.cell,
		g().shown_to_commander(wt), g().hidden_ghost(wt, g().human), g().entity_at((wt as Building).center()),
		centroid(guns).distance_to((wt as Building).center()) / Defs.TILE])
	await select_all(guns)
	await attack_unit(wt)
	await frames(3)
	note("right-click on a palisade piece: orders %s, targets %s, tesla %s" % [guns.map(func(u: Unit) -> String: return u.order),
		guns.map(func(u: Unit) -> String: return u.target.kind if u.target and is_instance_valid(u.target) else "-"), guns.map(func(u: Unit) -> String: return String(u.tesla_mode))])
	await shot("a_rightclick")
	await play_for(20.0, 2.0)
	walls = r().tagged("bar_2_wall")
	check("right-click: the guns break palisade pieces in 20 s", walls.size() < w0, "%d -> %d; powder %s" % [w0, walls.size(), guns.map(func(u: Unit) -> float: return u.powder)])
	await shot("b_after")
	if walls.size() >= w0 and not walls.is_empty():
		wt = nearest(walls, centroid(guns))
		await select_all(guns)
		await look_at((wt as Building).center())
		await key(KEY_A, {"ctrl": true})
		await click_at(w2win((wt as Building).center()))
		await play_for(20.0, 2.0)
		check("ATTACK GROUND on it breaks pieces in 20 s", r().tagged("bar_2_wall").size() < w0, "%d -> %d" % [w0, r().tagged("bar_2_wall").size()])
	flush_errors("wall probe")
