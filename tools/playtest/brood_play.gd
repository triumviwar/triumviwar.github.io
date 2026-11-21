extends SceneTree
## Playtest (job playtest-skirmish-brood): a WHOLE SKIRMISH PLAYED AS THE BROOD by a simulated person, through real mouse,
## key and touch input only (tools/playtest/brood_pt_lib.gd). It may read the game to decide (where its grubs are, what
## the card shows), never to act. Report: docs/playtest_2026_11_21_skirmish_brood.md.
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 --script res://tools/playtest/brood_play.gd -- \
##     who=careful|fast|confused|breaker opp=crown|clockwork|brood level=hard plan=OPTIMAL map=HOLLOWFEN mins=14 \
##     [mobile] [lang=pt] [ts=2]
const Lib := preload("res://tools/playtest/brood_pt_lib.gd")
var pt
var main: Node
var g                      # the Game
var hud
var me := 0
var o := {"who": "careful", "opp": "crown", "level": "hard", "plan": "OPTIMAL", "map": "", "mins": 14.0, "ts": 1.0, "lang": "en"}
var mobile := false
var rng := RandomNumberGenerator.new()
var findings: Array = []   # [kind, text]
var stats := {}            # counts of what the player did
var _seen := {}            # finding text -> true (each once)
var army_group := []       # (what the player thinks group 1 holds)
var log_t := 0.0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "mobile":
			mobile = true
		elif "=" in a:
			var kv := a.split("=", true, 1)
			o[kv[0]] = kv[1]
	o["mins"] = float(o["mins"])
	o["ts"] = float(o["ts"])
	rng.seed = hash(str(o)) + int(o.get("seed", "0"))
	if FileAccess.file_exists("user://settings.cfg"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://settings.cfg"))
	if o["lang"] != "en":
		Settings.language = o["lang"]
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	pt = Lib.new(self)
	pt.touch_mode = mobile
	pt.tag = "%s_%s_%s%s" % [o["who"], o["opp"], "phone" if mobile else "pc", ("_" + o["lang"]) if o["lang"] != "en" else ""]
	_run.call_deferred()


func finding(kind: String, text: String) -> void:
	if _seen.has(text):
		return
	_seen[text] = true
	findings.append([kind, text])
	pt.note("FINDING %s: %s" % [kind, text])


var _last_msg := ""
var toasts := {}
func watch_toasts() -> void:
	if hud == null:
		return
	var m := String(hud._msg)
	if m != "" and m != _last_msg:
		toasts[m] = int(toasts.get(m, 0)) + 1
		pt.note("toast @%s: %s" % [_clock(), m])
	_last_msg = m


func did(what: String) -> void:
	stats[what] = int(stats.get(what, 0)) + 1


# ------------------------------------------------------------------ reading the game (to decide only)

func mine(kind := "") -> Array:
	return g.units.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead and u.team == me and (kind == "" or u.kind == kind))


func mother() -> Unit:
	return BroodNew.queen(g, me)


func food() -> int:
	return int(g.players[me]["gold"])


func spoils() -> int:
	return int(float(g.players[me]["res2"]))


func supply() -> Vector2i:
	return Vector2i(g.supply_used(me), int(BroodNew.supply_cap(g, me)))


func enemy_units_near(p: Vector2, r: float) -> Array:
	return g.units.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead and u.team != me and u.team >= 0 \
		and g.enemies_of(me).has(u.team) and u.position.distance_to(p) < r)


func enemy_start() -> Vector2:
	for t in g.enemies_of(me):
		if t < g.starts.size():
			return g.cell_center(g.starts[t])
	return Vector2(Game.W, Game.H) * Game.T * 0.5


func army() -> Array:
	return mine().filter(func(u: Unit) -> bool: return u.kind != "grub" and not BroodNew.KINDS.has(u.kind) \
		and u.armed() and not BroodRoot.fixed(u) and not BroodNew.is_father(u.kind))


# ------------------------------------------------------------------ acting (input only)

func scr(p: Vector2) -> Vector2:
	return pt.w2s(g, p)


func play_rect() -> Rect2:
	# the part of the screen that is the map (not the HUD's top bar and bottom panels)
	var vs: Vector2 = pt.vsize()
	var top: float = hud.top_rect().end.y * hud.ui_scale + 6.0
	var bottom: float = minf(hud.card_rect().position.y, hud.mini_rect().position.y) * hud.ui_scale - 40.0
	return Rect2(Vector2(8, top), Vector2(vs.x - 16, bottom - top))


func visible_p(p: Vector2) -> bool:
	return play_rect().has_point(scr(p))


## bring a world point into view the way a person does: a click on the minimap there
func look(p: Vector2) -> void:
	if visible_p(p) and play_rect().grow(-60).has_point(scr(p)):
		return
	var m: Rect2 = hud.mini_rect()
	var sc: float = hud.ui_scale
	var f: Vector2 = p / (Vector2(Game.W, Game.H) * Game.T)
	var at := (m.position + f * m.size) * sc
	if mobile:
		await pt.tap(at)
	else:
		await pt.click(at)
	await pt.frames(3)
	did("minimap look")
	if not visible_p(p):
		# (the view stops at the map's edge, or a big HUD hides it): nudge with the arrow keys
		var c: Vector2 = play_rect().get_center()
		var d := scr(p) - c
		if not mobile:
			var k := KEY_RIGHT if d.x > 0 else KEY_LEFT
			if absf(d.x) > 40:
				await pt.key(k, 10)
			k = KEY_DOWN if d.y > 0 else KEY_UP
			if absf(d.y) > 40:
				await pt.key(k, 10)
		else:
			await pt.touch_drag(c, c - d * 0.6, 0, 8)


func click_world(p: Vector2, btn := MOUSE_BUTTON_LEFT) -> void:
	await look(p)
	if mobile and btn == MOUSE_BUTTON_RIGHT:
		await pt.tap(scr(p))       # (a phone has no right button: a tap with units selected is the order)
	else:
		await pt.click(scr(p), btn)


func select_unit(u: Unit, add := false) -> bool:
	if not is_instance_valid(u) or u.dead:
		return false
	var p: Vector2 = u.position
	if BroodRoot.has_fp(u) and BroodNew.rooted(u):
		p = BroodRoot.body_rect(u).get_center() if BroodRoot.body_rect(u).size.x > 0 else BroodRoot.rect_of(u).get_center()
	await look(p)
	if add and not mobile:
		pt.hold_shift(true)
	await pt.click(scr(p))
	if add and not mobile:
		pt.hold_shift(false)
	await pt.frames(2)
	var ok: bool = g.selection.has(u)
	if not ok:
		# (a person clicks again, a bit off: the feet)
		await pt.click(scr(u.position + Vector2(0, -6)))
		await pt.frames(2)
		ok = g.selection.has(u)
		if not ok and not add and BroodNew.rooted(u) and not g.selection.any(func(x) -> bool: return is_instance_valid(x) and x.kind == u.kind):
			finding("UX", "Clicking a %s did not select it (it picked %s)." % [u.kind, ", ".join(g.selection.map(func(x): return x.kind if is_instance_valid(x) else "?"))])
	did("select click")
	return ok


func select_mother() -> bool:
	var q := mother()
	if q == null:
		return false
	return await select_unit(q)


func box_select(world_pts: Array) -> void:
	if world_pts.is_empty():
		return
	var r := Rect2(world_pts[0], Vector2.ZERO)
	for p in world_pts:
		r = r.expand(p)
	r = r.grow(18)
	await look(r.get_center())
	var a := scr(r.position)
	var b := scr(r.end)
	var pr := play_rect()
	a = a.clamp(pr.position, pr.end)
	b = b.clamp(pr.position, pr.end)
	if mobile:
		await pt.touch_drag(a, b, 0, 10)
	else:
		await pt.drag(a, b)
	did("box select")


## a card button by its label (clicked or tapped at its place on the card)
func card(label: String) -> bool:
	await pt.frames(2)
	var b: Dictionary = await pt.card_click(hud, label)
	if b.is_empty():
		return false
	did("card " + label)
	if not b["enabled"] and b["why"] != "":
		pt.note("card %s refused: %s" % [label, b["why"]])
	return b["enabled"]


func card_key(label: String) -> bool:
	# the same button by its letter, as a computer player does
	hud._redraw_t = 0.0
	await pt.frames(2)
	var b: Dictionary = pt.card_find(hud, label)
	if b.is_empty() or b["key"] == "" or mobile:
		return await card(label)
	await pt.letter(b["key"])
	did("key " + label)
	return b["enabled"]


# ------------------------------------------------------------------ the Brood's jobs

var _maw_cost := 0
func place_root(kind: String, world: Vector2, morph := true) -> bool:
	# the ghost follows the mouse; a click confirms (the cell centred on the pointer)
	var aim := BroodRoot.rect_for(kind, world).get_center()
	await look(aim)
	var s := scr(aim)
	if mobile:
		await pt.tap(s)
		await pt.frames(3)
		# a phone confirms with the card's PLACE button (if it has one)
		if g.controls.mode == "nb_root":
			if not await card("PLACE"):
				await card("ROOT HERE")
	else:
		pt.move(s)
		await pt.frames(3)
		await pt.click(s)
	await pt.frames(3)
	if g.controls.mode == "nb_root":
		pt.note("still placing after the click: %s" % hud._msg)
		if mobile:
			await pt.tap(scr(aim))
		else:
			await pt.click(scr(aim), MOUSE_BUTTON_RIGHT)    # (cancel)
		return false
	return true


## a spot for kind near `c` (within r tiles) that the game would take: read the game's rules to choose, as a person
## looks at the green/red ghost before clicking
var spot_why := {}
func find_spot(kind: String, c: Vector2, r_min: float, r_max: float, extra := Callable()) -> Vector2:
	spot_why = {}
	for ring in range(int(r_min), int(r_max) + 1):
		for k in 24:
			var a := TAU * k / 24.0 + ring * 0.3
			var p := c + Vector2(cos(a), sin(a)) * ring * Defs.TILE
			var feet := BroodRoot.feet_at(kind, BroodRoot.cell_centred(kind, BroodRoot.rect_for(kind, p).get_center()))
			var why: String = BroodRoot.place_problem(g, me, kind, feet, null, false)
			if why == "" and (not extra.is_valid() or extra.call(feet)):
				return feet
			var w := why.split(":")[0].substr(0, 50)
			spot_why[w] = int(spot_why.get(w, 0)) + 1
	pt.note("no spot for %s near %s: %s" % [kind, str(c / Defs.TILE), str(spot_why)])
	return Vector2.INF


func grub_to(kind: String, where: Vector2) -> bool:
	var grubs := mine("grub").filter(func(u: Unit) -> bool: return not BroodRoot.in_cocoon(u) and u.order != "nb_morph")
	if grubs.is_empty():
		return false
	grubs.sort_custom(func(a, b) -> bool: return a.position.distance_to(where) < b.position.distance_to(where))
	if not await select_unit(grubs[0]):
		return false
	if rng.randf() < 0.5 and not mobile:
		await pt.key(KEY_B)
	else:
		await card("BUILD")
	await pt.frames(2)
	var lab := String(Defs.UNITS[kind]["name"]).to_upper()
	var b: Dictionary = pt.card_find(hud, lab)
	if b.is_empty():
		finding("BUG", "The grub's BUILD page has no %s (it shows %s)." % [lab, ", ".join(pt.card_labels(hud))])
		await pt.key(KEY_ESCAPE)
		return false
	if not b["enabled"]:
		pt.note("%s refused: %s" % [lab, b["why"]])
		await card(lab)          # (a person clicks it anyway and reads the toast)
		await card("BACK")
		return false
	await card(lab)
	var ok := await place_root(kind, where)
	if ok:
		did("morph " + kind)
		pt.note("%s ordered at %s (food %d)" % [kind, str(where / Defs.TILE), food()])
	return ok


func lay(kind: String, n := 1) -> int:
	if not await select_mother():
		return 0
	var lab := Defs.train_name(kind).to_upper()
	var done := 0
	for i in n:
		var b: Dictionary = pt.card_find(hud, lab)
		if b.is_empty():
			hud._redraw_t = 0.0
			await pt.frames(2)
			b = pt.card_find(hud, lab)
		if b.is_empty() or not b["enabled"]:
			if not b.is_empty() and kind != "grub":
				pt.note("lay %s refused: %s" % [lab, b["why"]])
			break
		if rng.randf() < 0.5 and not mobile:
			await card_key(lab)
		else:
			await card(lab)
		done += 1
	if done > 0:
		did("lay " + kind)
	return done


func idle_grubs_to_work() -> void:
	var idle := mine("grub").filter(func(u: Unit) -> bool: return u.order == "idle" and not BroodRoot.in_cocoon(u))
	if idle.is_empty():
		return
	# F1 = IDLE (a computer); a phone taps the IDLE button on the bar
	if mobile:
		var r: Rect2 = hud.bar.rect_of(0) if hud.bar.has_method("rect_of") else Rect2()
		if r.size.x > 0:
			await pt.tap(r.get_center() * hud.ui_scale)
		else:
			await select_unit(idle[0])
	else:
		await pt.key(KEY_F1)
	await pt.frames(2)
	var maws := mine(BroodNew.MAW).filter(func(u: Unit) -> bool: return BroodNew.rooted(u))
	if maws.is_empty():
		return
	maws.sort_custom(func(a, b) -> bool: return _crew(a) < _crew(b))
	await click_world(BroodRoot.rect_of(maws[0]).get_center(), MOUSE_BUTTON_RIGHT)
	did("idle grubs to work")


func _crew(m: Unit) -> int:
	return g.units.filter(func(u) -> bool: return is_instance_valid(u) and u.kind == "grub" and u.team == me and u.target == m).size()


# ------------------------------------------------------------------ the plan of a decent Brood player

var plan_t := {}
func due(key: String, every: float) -> bool:
	if float(g.clock) - float(plan_t.get(key, -999.0)) >= every:
		plan_t[key] = g.clock
		return true
	return false


func macro() -> void:
	var q := mother()
	if q == null:
		return
	var su := supply()
	var grubs := mine("grub").size()
	var maws := mine(BroodNew.MAW).size()
	var turtles := mine(BroodNew.TURTLE).size()
	var sire := BroodNew.father(g, me, BroodNew.FATHER)
	var dilo := BroodNew.father(g, me, BroodNew.DILO)
	var st := BroodNew.stage(q)
	# 1) idle grubs back to work
	if due("idle", 6.0):
		await idle_grubs_to_work()
	# 2) supply: a Mound Turtle when close to the cap (at home first; later on new ground)
	var turtles_coming := mine("grub").filter(func(u: Unit) -> bool: return u.order == "nb_morph").size() + mine(BroodNew.TURTLE).filter(func(u: Unit) -> bool: return BroodRoot.in_cocoon(u)).size()
	if su.y - su.x <= (10 if food() > 400 else 5) and food() >= 100 and su.y < 200 and turtles_coming <= (1 if food() > 500 else 0) and due("turtle", 15.0):
		var where := q.position
		var spot := Vector2.INF
		if turtles >= 1 and g.exp_spots != null:
			# the expansion: the best Mound Turtle spot the game marks gold
			for s in ExpansionSpots.nb_pick(g, me, g.exp_spots):
				spot = find_spot(BroodNew.TURTLE, BroodRoot.feet_at(BroodNew.TURTLE, s["tc"]), 0, 3)
				if spot != Vector2.INF:
					break
		if spot == Vector2.INF:
			spot = find_spot(BroodNew.TURTLE, where, 7, 18)
		if spot == Vector2.INF:
			for t2 in mine(BroodNew.TURTLE):
				spot = find_spot(BroodNew.TURTLE, t2.position, 5, 12)
				if spot != Vector2.INF:
					break
		if spot != Vector2.INF:
			await grub_to(BroodNew.TURTLE, spot)
	# 3) grubs: the Mother lays them while the Rootmaws want more
	var want_grubs := mini(maws * 7 + 2, 40)
	if grubs < want_grubs and food() >= 50 and su.x < su.y and due("grubs", 4.0):
		await lay("grub", clampi((food() - 50) / 50, 1, 3))
	# 4) Rootmaws on the gold spots
	var spots: Array = RootmawSpots.spots_for(g, me)
	if not spots.is_empty() and food() >= 125 and maws < 9 and grubs >= maws * 5 and due("maw", 12.0):
		spots.sort_custom(func(a, b) -> bool: return int(a["rank"]) < int(b["rank"]))
		await grub_to(BroodNew.MAW, spots[0]["p"])
	# 5) the Tyrant Sire beside her
	if sire == null and maws >= 2 and food() >= 150 and due("sire", 20.0):
		var sp := find_spot(BroodNew.FATHER, q.position, 3, 7)
		if sp != Vector2.INF:
			await grub_to(BroodNew.FATHER, sp)
		else:
			finding("UX", "No room found for the Tyrant Sire within the father range at %s." % str(q.position / Defs.TILE))
	# 6) research at a rooted Sire (PACK HUNT ...)
	if sire != null and BroodNew.rooted(sire) and food() >= 150 and due("research", 40.0):
		await select_unit(sire)
		for b in pt.card(hud):
			if b["enabled"] and b["icon"] != "" and not (b["label"] in ["UPROOT", "RALLY", "STOP RESEARCH"]) and b["label"] == b["label"].to_upper() \
					and Defs.RESEARCH.values().any(func(r) -> bool: return String(r.get("name", "")).to_upper() == b["label"] or Defs.research_label(_rkey(r)) == b["label"]):
				await card(b["label"])
				pt.note("research " + b["label"])
				break
	# 7) grow her
	if st == 0 and g.clock > 300.0 and food() >= 300 and due("grow", 30.0):
		await select_mother()
		await card("GROW")
	if st == 1 and g.clock > 540.0 and food() >= 500 and spoils() >= 75 and due("grow", 30.0):
		await select_mother()
		await card("GROW")
	# 8) the Venom Sire after the first push is out
	if dilo == null and sire != null and maws >= 3 and food() >= 220 and due("dilo", 30.0):
		if spoils() < 25:
			# spoils for him: offer up a grub (SACRIFICE), as a person does without bodies
			var gs2 := mine("grub")
			if gs2.size() > 12 and await select_unit(gs2[gs2.size() - 1]):
				await card("SACRIFICE")
				await card("SACRIFICE")
	if dilo == null and sire != null and maws >= 3 and food() >= 220 and spoils() >= 25 and due("dilo2", 20.0):
		var sp2 := find_spot(BroodNew.DILO, q.position, 3, 7)
		if sp2 != Vector2.INF:
			await grub_to(BroodNew.DILO, sp2)
	# 9) warriors
	if sire != null and BroodNew.rooted(sire) and su.x < su.y - 1 and grubs >= mini(want_grubs, 14) and due("army", 5.0):
		var k := "raptor"
		if dilo != null and BroodNew.rooted(dilo) and rng.randf() < 0.35:
			k = "spitter"
		if st >= 2 and rng.randf() < 0.3:
			k = "brute"
		await lay(k, clampi(food() / 100, 1, 6))
	# 10) spoils: grubs harvest the bodies near home
	var bodies: Array = g.corpses.filter(func(c) -> bool: return is_instance_valid(c) and c.position.distance_to(q.position) < 18 * Defs.TILE and g.is_seen(me, c.position)) if g.has_method("is_seen") else g.corpses.filter(func(c) -> bool: return is_instance_valid(c) and c.position.distance_to(q.position) < 18 * Defs.TILE)
	if spoils() < 120 and bodies.size() >= 2 and due("harvest", 30.0) and grubs > 6:
		var gs := mine("grub").filter(func(u: Unit) -> bool: return u.order in ["gather", "idle"])
		gs.sort_custom(func(a, b) -> bool: return a.position.distance_to(bodies[0].position) < b.position.distance_to(bodies[0].position))
		if gs.size() >= 2:
			await select_unit(gs[0])
			await select_unit(gs[1], true)
			await card("HARVEST")
	# 11) mature young when she can
	if st >= 1 and food() >= 200 and due("mature", 50.0):
		var young := army().filter(func(u: Unit) -> bool: return BroodMature.mature_of(u.kind) != "" and BroodMature.problem(u) == "")
		if not young.is_empty():
			await select_unit(young[0])
			await card("MATURE")


func _rkey(r: Dictionary) -> String:
	for k in Defs.RESEARCH:
		if Defs.RESEARCH[k] == r:
			return k
	return ""


var attacking := false
func war() -> void:
	var q := mother()
	if q == null:
		return
	var a := army()
	# keep group 1 = the army (F2 ARMY, then Ctrl+1)
	if a.size() > army_group.size() and due("group", 10.0):
		if mobile:
			await select_army_phone()
		else:
			await pt.key(KEY_F2)
			pt.hold_ctrl(true)
			await pt.key(KEY_1)
			pt.hold_ctrl(false)
		army_group = a.duplicate()
		did("group army")
	# defend: enemies near her, near a Rootmaw or a turtle
	var threat: Array = []
	for b in mine().filter(func(u: Unit) -> bool: return BroodNew.rooted(u)):
		threat += enemy_units_near(b.position, 12 * Defs.TILE)
	if not threat.is_empty() and due("defend", 4.0):
		var c: Vector2 = threat[0].position
		await recall_army()
		await attack_move(c)
		pt.note("defend at %s (%d enemies)" % [str(c / Defs.TILE), threat.size()])
		did("defend")
		# she gets up to fight when they are at her
		if enemy_units_near(q.position, 5 * Defs.TILE).size() >= 3 and BroodNew.rooted(q) and due("mother_up", 30.0):
			await select_mother()
			await card("UPROOT")
			finding("NOTE", "Had to UPROOT the Mother to fight at %s." % _clock())
		return
	if not BroodNew.rooted(q) and threat.is_empty() and enemy_units_near(q.position, 14 * Defs.TILE).is_empty() and due("mother_root", 8.0):
		# root her again (ROOT, then a click on the ghost where she stands)
		await select_mother()
		if await card("ROOT"):
			await place_root(BroodNew.QUEEN, q.position, false)
	var power := 0
	for u in a:
		power += int(Defs.UNITS[u.kind].get("supply", 1))
	if power >= 24 and due("attack", 50.0):
		await recall_army()
		await attack_move(enemy_start())
		attacking = true
		pt.note("ATTACK with %d supply of army at %s" % [power, _clock()])
		did("attack")


func select_army_phone() -> void:
	var r: Rect2 = Rect2()
	if hud.bar.has_method("rect_of"):
		r = hud.bar.rect_of(1)
	if r.size.x > 0:
		await pt.tap(r.get_center() * hud.ui_scale)


func recall_army() -> void:
	if mobile:
		await select_army_phone()
	else:
		await pt.key(KEY_1)
	await pt.frames(2)


func attack_move(p: Vector2) -> void:
	if g.selected_units().is_empty() or not g.selected_units().any(func(u) -> bool: return army().has(u)):
		return
	if mobile:
		await card("ATTACK")
		await click_world(p)
	else:
		await pt.key(KEY_A)
		# by the minimap when far (a person does): the click on the minimap gives the order
		var m: Rect2 = hud.mini_rect()
		var f: Vector2 = p / (Vector2(Game.W, Game.H) * Game.T)
		await pt.click((m.position + f * m.size) * hud.ui_scale)
	did("attack-move")


func _clock() -> String:
	return "%d:%02d" % [int(g.clock) / 60, int(g.clock) % 60]


# ------------------------------------------------------------------ the odd players

func confused_step() -> void:
	var r := rng.randf()
	var vs: Vector2 = pt.vsize()
	var p := Vector2(rng.randf() * vs.x, rng.randf() * vs.y)
	if r < 0.3:
		await pt.click(p)
	elif r < 0.45:
		await pt.click(p, MOUSE_BUTTON_RIGHT)
	elif r < 0.55:
		await pt.key(KEY_ESCAPE)
	elif r < 0.62:
		await pt.letter("QWERTASDFGZXCVBHMP"[rng.randi() % 18])
	elif r < 0.7:
		await pt.drag(p, p + Vector2(rng.randf_range(-300, 300), rng.randf_range(-200, 200)))
	elif r < 0.75:
		await pt.wheel(p, rng.randf() < 0.5, 3)
	elif r < 0.8:
		# the card: a random button
		var cb: Array = pt.card(hud)
		if not cb.is_empty():
			await pt.click((cb[rng.randi() % cb.size()]["rect"] as Rect2).get_center())
	elif r < 0.84:
		await pt.click((hud.menu_rect().get_center()) * hud.ui_scale)     # the MENU
		await pt.frames(10)
		await pt.shot("confused_menu")
		await pt.key(KEY_ESCAPE)
	elif r < 0.88:
		await pt.dbl_click(p)
	elif r < 0.9 and not mobile:
		root.size = Vector2i(rng.randi_range(900, 1400), rng.randi_range(500, 800))
		await pt.frames(10)
		did("resize")
	else:
		await pt.key([KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_SPACE, KEY_TAB][rng.randi() % 6])
	did("confused")


func breaker_step() -> void:
	var r := rng.randf()
	var q := mother()
	if r < 0.2:
		# a Rootmaw off the swamp / on a cliff / on the enemy: placed where it can't go
		var grubs := mine("grub")
		if not grubs.is_empty() and await select_unit(grubs[0]):
			await pt.key(KEY_B)
			await card("ROOTMAW")
			var bad := enemy_start() if rng.randf() < 0.5 else Vector2(rng.randf() * Game.W, rng.randf() * Game.H) * Game.T
			await click_world(bad)
			pt.note("bad place toast: %s" % hud._msg)
			await pt.key(KEY_ESCAPE)
	elif r < 0.35:
		# drag a box from the map over the HUD and off the window
		var vs: Vector2 = pt.vsize()
		await pt.drag(Vector2(vs.x * 0.5, vs.y * 0.4), Vector2(vs.x + 50, vs.y + 60))
	elif r < 0.5 and q:
		# UPROOT the Mother and at once ROOT / GROW / lay
		await select_mother()
		await card("UPROOT")
		await card("GROW")
		await card("GRUB")
		await pt.secs(0.5)
		await card("ROOT")
		await place_root(BroodNew.QUEEN, q.position, false)
	elif r < 0.6:
		# cancel a cocoon or an egg at an odd moment: select it and press Esc / Delete
		var c := mine().filter(func(u: Unit) -> bool: return BroodRoot.in_cocoon(u) or u.kind == BroodNew.EGG)
		if not c.is_empty():
			await select_unit(c[0])
			await pt.shot("breaker_cocoon_card")
			await pt.key(KEY_DELETE)
			await pt.key(KEY_ESCAPE)
	elif r < 0.7:
		# a right-click drag line with rooted creatures selected (a rally) and Shift queues on grubs
		await select_mother()
		var p: Vector2 = scr(q.position) + Vector2(200, 60)
		await pt.drag(p, p + Vector2(200, 0), MOUSE_BUTTON_RIGHT)
		var grubs := mine("grub")
		if grubs.size() > 2:
			await select_unit(grubs[0])
			pt.hold_shift(true)
			for i in 4:
				await pt.click(scr(grubs[0].position) + Vector2(i * 40, 30), MOUSE_BUTTON_RIGHT)
			pt.hold_shift(false)
	elif r < 0.8:
		# SACRIFICE everything selected, eggs and all
		await pt.key(KEY_F2)
		await card("SACRIFICE")
	else:
		# pause and unpause fast, menu during it
		await pt.key(KEY_PAUSE)
		await pt.key(KEY_F10)
		await pt.key(KEY_ESCAPE)
	did("breaker")


# ------------------------------------------------------------------ the match

func _run() -> void:
	await pt.frames(5)
	if not await pt.into_match(main, {"opp": o["opp"], "who": o["level"], "plan": o["plan"], "map": o["map"]}):
		pt.note("could not start the match")
		_end(1)
		return
	g = main.game
	hud = g.hud
	me = g.human
	pt.note("match: me %d (%s) v %s, map %s, size %s" % [me, g.faction_of(me), str(g.enemies_of(me).map(func(t): return g.faction_of(t))), str(g.get("map_id")), str(pt.vsize())])
	await pt.secs(4.0)     # (the countdown)
	await pt.shot("start")
	Engine.time_scale = o["ts"]
	var shot_t := 0.0
	var end_at: float = o["mins"] * 60.0
	var think := 0
	while not g.over and g.clock < end_at and is_instance_valid(g):
		think += 1
		match o["who"]:
			"careful":
				await macro()
				await war()
			"fast":
				await macro()
				await war()
				# spam: re-select, double-click a grub, mash keys
				var gr := mine("grub")
				if not gr.is_empty():
					await look(gr[0].position)
					await pt.dbl_click(scr(gr[0].position))
				await pt.key(KEY_SPACE)
				await pt.key(KEY_F2)
			"confused":
				if think % 3 == 0:
					await macro()
				for i in 3:
					await confused_step()
			"breaker":
				await macro()
				await war()
				if think % 2 == 0:
					await breaker_step()
		watch_toasts()
		if g.clock - shot_t >= 60.0:
			shot_t = g.clock
			pt.note("t %s food %d spoils %d supply %s grubs %d maws %d turtles %d army %d stage %d | %s" % [_clock(), food(), spoils(), str(supply()),
				mine("grub").size(), mine(BroodNew.MAW).size(), mine(BroodNew.TURTLE).size(), army().size(), BroodNew.stage(mother()) if mother() else -1,
				", ".join(g.enemies_of(me).map(func(t): return "%s %d units" % [g.faction_of(t), g.units.filter(func(u): return is_instance_valid(u) and u.team == t and not u.dead).size()]))])
			var orders := {}
			for u in mine("grub"):
				orders[u.order] = int(orders.get(u.order, 0)) + 1
			pt.note("grub orders %s, fps %d" % [str(orders), Engine.get_frames_per_second()])
			await pt.shot("t%02d" % int(g.clock / 60))
		await pt.secs(0.4)
	Engine.time_scale = 1.0
	pt.note("END at %s: over %s winner %s (me %d)" % [_clock(), str(g.over), str(g.winner), me])
	await pt.secs(3.0)
	await pt.shot("end")
	_end(0)


func _end(code: int) -> void:
	print("== STATS ", JSON.stringify(stats))
	print("== TOASTS ", JSON.stringify(toasts))
	for f in findings:
		print("== FINDING %s | %s" % [f[0], f[1]])
	quit(code)
