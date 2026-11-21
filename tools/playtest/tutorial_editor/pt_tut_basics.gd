extends "res://tools/playtest/tutorial_editor/pt_base.gd"
## THE BASICS lesson (t01_basics) played from the main menu by a NEW player who follows the teacher and the pointer.
##   player:careful (default) does each step as asked; player:wrong does steps out of order, idles, loses men, presses
##   Esc, leaves and restarts the lesson.
## (see pt_base.gd for the command line)

var who := "careful"


func play() -> void:
	who = String(args.get("player", "careful"))
	await shot("menu")
	var t := button("Menu_tutorial")
	expect(t != null, "TUTORIAL button on the main menu")
	await press(t)
	await wait(0.6)
	await shot("lesson_list")
	print("PT OFFSCREEN ", off_screen())
	await press_button("Lesson_t01_basics")
	await wait(0.4)
	await shot("basics_card")
	await press_button("Lesson_Start")
	await wait(4.0)            # (the 3-2-1)
	var g := game()
	if not expect(g != null and g.mission != null, "the lesson started"):
		return
	note(lesson_state())
	await shot("step_camera")
	if who == "wrong":
		await play_wrong()
	else:
		await play_careful()


func recruits() -> Array:
	return game().mission.tagged("recruits")


func recruit_centre() -> Vector2:
	var c := Vector2.ZERO
	var rs := recruits()
	for u in rs:
		c += u.position
	return c / maxf(1, rs.size())


func wait_step(task: String, secs := 20.0) -> bool:
	var t := 0.0
	while t < secs:
		if String(game().mission.obj.get("task_" + task, "")) == "done":
			return true
		await wait(0.25)
		t += 0.25
	return false


func do_camera() -> void:
	if phone:
		await two_finger_drag(screen_size() * 0.5, Vector2(-300, -120))
		await two_finger_drag(screen_size() * 0.5, Vector2(-200, 0))
	else:
		await key(KEY_RIGHT, {}, 1.2)


func do_zoom() -> void:
	if phone:
		await pinch(screen_size() * 0.45, false)
	else:
		await wheel(screen_size() * 0.45, false, 3)


func pick_one() -> void:
	var u: Unit = recruits()[0]
	if not in_view(u.position):
		await look_at(u.position)
	await press_at(world_to_screen(u.position))


func pick_all() -> void:
	var rs := recruits()
	if phone:
		var p := world_to_screen(rs[0].position)
		await tap(p)
		await frames(2)
		await tap(p)
		return
	var lo := Vector2(INF, INF)
	var hi := -lo
	for u in rs:
		var p := world_to_screen(u.position)
		lo = lo.min(p)
		hi = hi.max(p)
	await drag(lo - Vector2(40, 40), hi + Vector2(40, 40))


func order_at(w: Vector2) -> void:
	if not in_view(w):
		await look_at(w)
	var p := world_to_screen(w)
	if phone:
		await tap(p)
	else:
		await click(p, MOUSE_BUTTON_RIGHT)


func play_careful() -> void:
	var g := game()
	await read_lines()
	await do_camera()
	expect(await wait_step("camera", 6), "camera step done by moving the view")
	await wait(1.0)
	note(lesson_state())
	await do_zoom()
	expect(await wait_step("zoom", 6), "zoom step done")
	await wait(1.5)
	note(lesson_state())
	await shot("step_select_one")
	var pt := pointer_target()
	note("pointer: %s" % str(pt))
	await pick_one()
	expect(await wait_step("select_one", 6), "one Musketeer selected by a click on it")
	await wait(1.5)
	note(lesson_state())
	await shot("step_select_all")
	await pick_all()
	if not await wait_step("select_all", 5):
		find("select_all: the box / double tap did not select all five (selected %d)" % g.selection.size())
		await pick_all()
		expect(await wait_step("select_all", 5), "select all on the second try")
	await wait(1.5)
	note(lesson_state())
	await shot("step_move")
	var flag: Vector2 = g.mission.area_rect("flag").get_center()
	await order_at(flag)
	expect(await wait_step("move", 30), "the men reached the gold ring")
	await wait(1.5)
	note(lesson_state())
	await read_lines()
	await shot("step_attack")
	var bandits: Array = g.mission.tagged("bandits")
	note("bandits %d" % bandits.size())
	if bandits.size() > 0:
		await order_at(bandits[0].position)
	expect(await wait_step("attack", 60), "the bandits beaten")
	await wait(1.5)
	await read_lines()
	note(lesson_state())
	await shot("step_card")
	if g.selection.size() < 3:
		await pick_all()
	if phone:
		await press_card("HOLD")
	else:
		await key(KEY_H)
	expect(await wait_step("card", 6), "HOLD pressed")
	await wait(1.5)
	note(lesson_state())
	await shot("step_minimap")
	await press_at(mini_spot(Vector2(Game.W, Game.H) * Game.T * 0.5))
	expect(await wait_step("minimap", 6), "minimap clicked")
	await wait(1.5)
	note(lesson_state())
	await shot("step_group_set")
	await look_at(recruit_centre())
	await pick_all()
	if phone:
		var slot := group_slot(1).get_center()
		touch(slot, true)
		await wait(1.0)
		touch(slot, false)
		await frames(3)
	else:
		await key(KEY_1, {"ctrl": true})
	expect(await wait_step("group_set", 6), "group 1 set")
	await wait(1.5)
	note(lesson_state())
	await shot("step_group_select")
	await press_at(world_to_screen(recruit_centre()) + Vector2(0, -120))      # (click empty ground: nothing selected)
	if phone:
		await tap(group_slot(1).get_center())
	else:
		await key(KEY_1)
	expect(await wait_step("group_select", 6), "group 1 selected")
	await wait(2.0)
	await read_lines()
	var tw := 0.0
	while tw < 40.0 and root.find_child("LessonEnd", true, false) == null:
		await wait(0.5)
		tw += 0.5
	note("LESSON DONE came %.1f s after the last task" % (tw + 2.0))
	await shot("end")
	var end := root.find_child("LessonEnd", true, false)
	expect(end != null, "the LESSON DONE panel shows")
	print("PT OFFSCREEN ", off_screen())
	if end:
		await press_button("End_NEXT_LESSON")
		await wait(4.0)
		note("after NEXT LESSON: " + lesson_state())
		await shot("next_lesson")


## A new player who does things in the wrong order, idles, presses Esc, leaves mid-lesson and starts again.
func play_wrong() -> void:
	var g := game()
	# do later steps first: select all and order a move before the camera step
	await pick_all()
	await order_at(g.mission.area_rect("flag").get_center())
	await press_at(mini_spot(Vector2(Game.W, Game.H) * Game.T * 0.3))
	await key(KEY_1, {"ctrl": true})
	await wait(2.0)
	note("after doing later steps first: " + lesson_state())
	await shot("wrong_order")
	# idle a minute
	await wait(60.0)
	note("after a minute idle: " + lesson_state())
	await shot("idle_minute")
	# Esc: does it open a menu? Esc again
	await key(KEY_ESCAPE)
	await wait(0.5)
	await shot("esc_once")
	note("Esc: menu_open=%s paused=%s" % [hud().menu_open, hud().paused])
	await key(KEY_ESCAPE)
	await wait(0.5)
	await do_camera()
	await do_zoom()
	await wait(2.0)
	note("camera+zoom done late: " + lesson_state())
	# now the remaining steps: the men already stand in the ring?
	await pick_one()
	await wait(1.0)
	await pick_all()
	await wait(4.0)
	note("after selects: " + lesson_state())
	await shot("wrong_after_selects")
	# walk them away from the flag before the move step is checked, then into the bandits without the order
	var bandits: Array = g.mission.tagged("bandits", false)
	note("bandits known now: %d" % bandits.size())
	# lose units: march them straight into the bandits' area before being told, one at a time
	var tg: Rect2 = g.mission.area_rect("targets")
	await order_at(tg.get_center())
	await wait(30.0)
	note("after marching into the bandits early: %s ; recruits alive %d" % [lesson_state(), recruits().size()])
	await shot("wrong_early_fight")
	await wait(20.0)
	note("later: " + lesson_state())
	# leave mid-lesson via the menu, then start it again from the list
	await press_match_menu("QUIT TO MENU")
	await wait(1.5)
	await shot("after_quit")
	note("after quit: game=%s screen buttons %s" % [game() != null, str(button_names()).substr(0, 300)])
	if button("Menu_tutorial"):
		await press_button("Menu_tutorial")
		await wait(0.5)
		await shot("list_after_quit")
		await press_button("Lesson_Start")
		await wait(4.0)
		note("restarted: " + lesson_state())
		await shot("restarted")
		# kill the recruits: what does the lesson do when its men are gone?
		for u in recruits():
			u.take_damage(99999.0, null)
		await wait(5.0)
		note("all recruits dead: over=%s %s" % [game().over if game() else "-", lesson_state()])
		await shot("recruits_dead")
		await wait(20.0)
		note("20 s later: over=%s %s" % [game().over if game() else "-", lesson_state()])
		await shot("recruits_dead_later")
		await wait(60.0)
		note("80 s later: over=%s LessonEnd=%s %s" % [game().over if game() else "-", root.find_child("LessonEnd", true, false) != null, lesson_state()])
		await shot("recruits_dead_80s")
