extends "res://tools/playtest/pt_mission.gd"
## A probe: the mid-match show of a07 (the verdict): does a click on NEXT, a tap, Space or Esc move it on?
func setup() -> void:
	mid = "a07_council"
	args["progress"] = "all"
	super.setup()
	tag = "showprobe_" + device


func play() -> void:
	main.start(Campaign.make_cfg(mid, "solo", "p1", false))
	for i in 400:
		await frames(1)
		if by_name("StillShow"):
			break
	var s: Node = by_name("StillShow")
	if not check("the verdict show comes", s != null):
		return
	await shot("a")
	note("parent %s (layer %s), tree paused %s, auto %s" % [s.get_parent(), s.get_parent().get("layer"), paused, s.get("auto")])
	var i0: int = s._i
	await press_name("Show_NEXT")
	await frames(3)
	check("a click on NEXT moves the show on", s._i > i0, "%d -> %d" % [i0, s._i])
	var nb := by_name("Show_NEXT")
	var vp := root.gui_get_hovered_control() if root.has_method("gui_get_hovered_control") else null
	note("NEXT at %s; control under the mouse: %s" % [centre_of(nb), vp])
	i0 = s._i
	await key(KEY_SPACE)
	check("Space moves the show on", s._i > i0, "%d -> %d" % [i0, s._i])
	i0 = s._i
	await click_at(Vector2(640, 200))
	check("a click on the picture moves the show on", s._i > i0, "%d -> %d" % [i0, s._i])
	await key(KEY_ESCAPE)
	await frames(3)
	check("Esc ends the show", not is_instance_valid(s) or s.is_queued_for_deletion() or by_name("StillShow") == null)
	check("the match runs again after the show", not paused)
