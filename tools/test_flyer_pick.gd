extends SceneTree
## A flyer is picked where it is drawn (playtest-skirmish-clockwork, 2026-11-21): a click on a Swift's or an Owl's body,
## high over its shadow, picks it (Game.entity_at), as does a click on its shadow; a ground unit is still picked at its feet.
##   godot --headless --fixed-fps 30 --script res://tools/test_flyer_pick.gd
const U := preload("res://tools/gear_test_util.gd")
var fails := 0


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var g := U.make(root)
	await process_frame
	await process_frame
	var hall := U.hall(g, 0)
	var at := hall.center() + Vector2(0, 260)
	for k in [Defs.CUCKOO, Defs.OWL]:
		var b: Unit = g._add_unit(k, 0, at)
		U.step(g, 0.5)
		var body := b.center()
		check(g.entity_at(body) == b, "%s: a click on its body (%.0f px over its shadow) picks it" % [k, b.position.y - body.y])
		check(g.entity_at(b.position) == b, "%s: a click on its shadow picks it" % k)
		b.die()
		U.step(g, 3.0)
	var w: Unit = g._add_unit("winder", 0, at + Vector2(200, 0))
	U.step(g, 0.3)
	check(g.entity_at(w.position + Vector2(0, -10)) == w, "a Winder is picked at his feet")
	print("DONE %d FAIL" % fails)
	quit(1 if fails > 0 else 0)
