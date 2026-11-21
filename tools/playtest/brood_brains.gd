extends RefCounted
## The players' minds for brood_mission.gd: what to do next, read from the match; every order goes through the HAND.
var pt
var hand
var g: Game
var r: MissionRun
var a: Dictionary
var tree: SceneTree
var me := 0
var choices := {}


func _init(p, h, game: Game, args: Dictionary, t: SceneTree) -> void:
	pt = p
	hand = h
	g = game
	r = game.mission
	a = args
	tree = t
	me = g.human
	for c in String(a["choice"]).split(",", false):
		choices[c.get_slice(":", 0)] = c.get_slice(":", 1)
	Engine.time_scale = float(a["speed"])
	Engine.max_physics_steps_per_frame = 16


func play() -> void:
	match String(a["who"]):
		"probe":
			await probe()
		_:
			if has_method(String(a["mission"]).get_slice("_", 0) + "_" + String(a["who"])):
				await call(String(a["mission"]).get_slice("_", 0) + "_" + String(a["who"]))
			else:
				await idle()


# ------------------------------------------------------------------ shared
var _last_obj := {}
var _last_print := -100.0
var _shots_at := {}


## Once a frame-ish: watch the objectives, the lines, the choices (answered as the args say, else the default in
## time, else the first) and take a picture of each new objective state.
func tick() -> void:
	if r == null:
		return
	for k in r.obj:
		if _last_obj.get(k, "") != r.obj[k]:
			pt.note("OBJ", "%d:%02d %s -> %s" % [int(g.clock) / 60, int(g.clock) % 60, k, r.obj[k]])
			_last_obj[k] = r.obj[k]
			if String(r.obj[k]) in ["active", "done", "failed"] and a["shots"] == "1" and not _shots_at.has(k + r.obj[k]):
				_shots_at[k + r.obj[k]] = true
				await pt.shot("obj_%s_%s" % [k, r.obj[k]])
	if not r.choice_open.is_empty():
		var cid := String(r.choice_open["id"])
		var opts: Array = (r.choice_open.get("options", []) as Array).map(func(o) -> String: return String(o.get("id", "")))
		pt.note("CHOICE", "%d:%02d %s %s" % [int(g.clock) / 60, int(g.clock) % 60, cid, opts])
		await pt.shot("choice_" + cid)
		var want := String(choices.get(cid, ""))
		if want == "default":
			pass             # (nobody answers: the default in time)
		elif want != "" or not opts.is_empty():
			var o := want if want != "" else String(opts[0])
			if not await pt.tap("Choose_" + o, 2.0):
				pt.note("BUG?", "the choice %s has no button Choose_%s on screen" % [cid, o])
			await pt.wait(0.3)
	if g.clock - _last_print > 60.0:
		_last_print = g.clock
		pt.note("STATE", "%d:%02d obj=%s counters=%s flags=%s" % [int(g.clock) / 60, int(g.clock) % 60, r.obj, r.counters, r.flags])


func idle() -> void:
	var until := float(a["until"])
	while not g.over and g.clock < until:
		await tick()
		await pt.wait(0.5)
	pt.note("IDLE", "done at %d:%02d over=%s winner=%s" % [int(g.clock) / 60, int(g.clock) % 60, g.over, r.winner_side])


func probe() -> void:
	await pt.wait(1.0)
	await tick()
	var mine: Array = g.units.filter(func(u): return u.team == me and not u.dead)
	var kinds := {}
	for u in mine:
		kinds[u.kind] = int(kinds.get(u.kind, 0)) + 1
	pt.note("PROBE", "my units %s; tagged %s" % [kinds, r.tags.keys() if r.get("tags") is Dictionary else "?"])
	var done := {}
	for u in mine:
		if done.has(u.kind):
			continue
		done[u.kind] = true
		await hand.escape()
		if await hand.pick(u):
			pt.note("CARD", "%s: %s" % [u.kind, hand.card_labels()])
			await pt.shot("card_" + u.kind)
	# the roster (B1: the Sire and Raptors only): what the Mother's card does with the others
	var q := BroodNew.queen(g, me)
	await hand.escape()
	if await hand.pick(q):
		for lab in ["BRUTE", "SPITTERS", "MIST TOAD", "HATCHLINGS", "GROW", "LAYING", "QUICK ROOTS"]:
			await hand.card(lab)
			await pt.wait(0.2)
			pt.note("ROSTER", "%s pressed: toast '%s' queue=%s gold=%d" % [lab, g.hud.get("_msg"), q.get("queue") if q.get("queue") != null else "?", int(g.players[me]["gold"])])
			await hand.escape()
			await hand.pick(q)
		await pt.shot("roster_presses")
	var grubs: Array = g.units.filter(func(u): return u.team == me and u.kind == "grub" and not u.dead)
	if not grubs.is_empty() and await hand.pick(grubs[0]):
		await hand.card("BUILD")
		pt.note("CARD", "grub BUILD page: %s" % [hand.card_labels()])
		await pt.shot("grub_build")
		await hand.escape()
	await hand.menu()
	await pt.shot("menu")
	pt.note("MENU", str(hand.menu_labels()))
	await hand.menu_item("PAUSE")
	await pt.wait(0.5)
	await pt.shot("paused")
	await hand.menu_item("RESUME")
	await pt.wait(1.0)
	await hand.menu()
	await hand.menu_item("QUIT TO MENU")
	await pt.wait(2.0)
	await pt.shot("after_quit")
	pt.note("PROBE", "after quit: " + str(pt.button_names()))
