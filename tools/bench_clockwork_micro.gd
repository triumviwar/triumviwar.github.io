extends SceneTree
## THE CLOCKWORK'S FIGHTS AT EQUAL VALUE, a set-piece bench (clockwork-micro, docs/clockwork_micro.md; the owner 2026-11-25:
## "a gigantic round of battles, micro training the AI... it's only fair to make this testing to all matchups"). The method of
## tools/bench_crown_micro.gd (the crown-micro job). No economy: a Clockwork army and an enemy army of the SAME value
## (Game.unit_value) meet; the Clockwork under its computer's fighting code (Hard: the push's march and fight, the one army's
## home defence, the escort Winders, the Springers' jump in, the Netters' and Pendulums' aims; and the clockwork-micro
## coaching unless `cwmic:off`), the enemy under its OWN computer's way of going in:
##   crown  the Crown computer's wave (its line, guns, rider screen, riders' hit and run), aimed at the Clockwork
##   brood  an attack-move at the Clockwork (the way the Brood's waves go in; its computer is taken off: it builds nothing)
##   cw     (the mirror) the enemy Clockwork computer's own push
## Scenarios `<where>-<size>-<foe>`:
##   where  open  the Clockwork push marches across the open middle toward the enemy's side; the enemy comes on head-on
##          home  the Clockwork army stands in front of its hall (the one army's defence); the enemy walks at the hall
##          side  as open, but the enemy comes on from the push's flank (not for the mirror)
##   size   s ~1,000, m ~2,200, l ~3,800 (the Clockwork army's value with its escort Winders; the enemy the same)
##          M, L: the armies the Clockwork computer really fields at 10:00 and 15:00-20:00 (mostly Clock Soldiers)
##   foe    crown (Musketeers, Field Cannons, Cuirassiers, a Mortar), cw (the same Clockwork army as ours),
##          raptor / mixed / late / spit / real (the Brood mixes of the crown-micro bench)
## Counts per fight (from first contact, at most `fight` s, default 90): value killed and lost, the share of each army left,
## the score (Clockwork share left - enemy share left: +1 a clean Clockwork win, -1 a clean loss).
##   godot --headless --fixed-fps 30 --path . --script res://tools/bench_clockwork_micro.gd -- [only:open-m-crown,...|set:crown]
##       [runs:3] [map:greenhold] [seed:0] [tech:1] [down:0.3] [fight:90] [out:/abs/file.json] [shots:/abs/dir] [cwmic:off ...]
## tech:1 both sides fight with their late research. down:0.3 that share of the Clockwork army starts part run down
## (wind 0.2-0.45, as a push far from its gears is). ratio:1.5 the enemy brings that many times the value.
## A measuring tool: it changes no rule.
var main: Node
var g: Game
var res: Array = []
var shots := ""

const SETS := {
	"crown": ["open-m-crown", "home-m-crown", "side-m-crown", "open-s-crown", "open-l-crown", "home-l-crown"],
	"brood": ["open-m-raptor", "open-m-mixed", "open-m-late", "home-m-mixed", "side-m-mixed", "open-m-spit", "open-l-late",
		"home-l-raptor"],
	"mirror": ["open-s-cw", "open-m-cw", "home-m-cw", "open-l-cw"],
	"mixes": ["open-B-crown", "home-B-crown", "open-P-crown", "open-S-crown", "home-S-crown", "open-B-late", "open-P-late",
		"open-S-spit", "open-B-spit", "open-P-cw", "open-B-cw", "open-S-cw"],
	"real": ["open-M-crown", "home-M-crown", "open-L-crown", "open-M-real", "home-M-real", "open-L-real", "open-M-cw",
		"open-L-cw"],
}

const CW := {
	"s": {"clock_soldier": 8, "springer": 2, "netter": 1, "winder": 2},
	"m": {"clock_soldier": 18, "pendulum": 2, "springer": 3, "netter": 1, "ballista": 1, "winder": 3},
	"l": {"clock_soldier": 30, "pendulum": 3, "springer": 5, "netter": 2, "ballista": 2, "great_winder": 1, "winder": 5},
	"M": {"clock_soldier": 28, "pendulum": 2, "springer": 3, "netter": 1, "ballista": 1, "winder": 4},
	"L": {"clock_soldier": 56, "pendulum": 4, "springer": 7, "netter": 1, "ballista": 3, "great_winder": 1, "winder": 7},
	# (not what the computer builds: other mixes of about the "m" value, to ask whether a different army would do better)
	"B": {"clock_soldier": 8, "pendulum": 2, "springer": 3, "netter": 2, "ballista": 5, "winder": 4},       # machines and bolts
	"P": {"clock_soldier": 8, "pendulum": 7, "springer": 2, "netter": 1, "winder": 3},                     # Pendulums
	"S": {"clock_soldier": 6, "springer": 15, "netter": 2, "winder": 3},                                  # Springers
}
# (the Crown army is built to the value in this order, a round of the crown-micro bench's "m" army)
const CROWN_ROUND := ["musketeer", "musketeer", "musketeer", "musketeer", "cannon", "musketeer", "musketeer", "musketeer",
	"cuirassier", "musketeer", "musketeer", "musketeer", "musketeer", "cannon", "cuirassier", "musketeer", "musketeer",
	"cuirassier", "cannon", "mortar"]
const MIX := {
	"raptor": ["raptor"],
	"mixed": ["raptor", "raptor", "spitter", "tyrant_challenger"],
	"late": ["raptor", "raptor", "spitter", "tyrant_challenger", "spitter", "brute"],
	"spit": ["spitter", "spitter", "raptor"],
	"real": ["raptor", "raptor", "raptor", "tyrant_challenger", "raptor", "spitter", "raptor", "brute", "raptor", "raptor",
		"mist_toad", "tyrant_challenger"],
}


func _initialize() -> void:
	_run.call_deferred()


func _arg(k: String, d: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(k + ":"):
			return a.substr(k.length() + 1)
	return d


func _until(clock: float) -> void:
	while g.clock < clock and not g.over:
		await physics_frame


func _foe_faction(foe: String) -> String:
	return "crown" if foe == "crown" else ("clockwork" if foe == "cw" else "brood")


func _start(sd: int, map: String, foe: String) -> void:
	if main != null:
		main.queue_free()
		await process_frame
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	seed(sd)
	main.start({"map": map, "seed": sd, "slots": [
		{"who": "hard", "faction": "clockwork", "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "hard", "faction": _foe_faction(foe), "colour": 1, "side": 1, "strategy": "balanced"}]})
	await process_frame
	await process_frame
	g = main.game
	g.path_budget_us = 1 << 40
	if g.hud:
		g.hud.countdown = 0.0
		if shots != "":
			g.hud.visible = false
	if g.spectator:
		g.spectator.process_mode = Node.PROCESS_MODE_DISABLED
	if g.controls:
		g.controls.process_mode = Node.PROCESS_MODE_DISABLED
	paused = false
	if _foe_faction(foe) == "brood":
		for a in g.ais.duplicate():
			if a.team == 1:
				g.ais.erase(a)


func _ai(t: int):
	for a in g.ais:
		if a.team == t:
			return a
	return null


func _spawn(kind: String, t: int, p: Vector2) -> Unit:
	var c: Vector2i = g.nearest_free(g.cell_of(g.on_map(p)), 8)
	return g._add_unit(kind, t, g.cell_center(c))


func _alive(list: Array) -> Array:
	return list.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)


func _value(list: Array) -> float:
	var v := 0.0
	for u in _alive(list):
		v += float(Game.unit_value(u)) * clampf(u.hp / maxf(1.0, u.max_hp), 0.0, 1.0)
	return v


func _centre(list: Array) -> Vector2:
	var c := Vector2.ZERO
	var n := 0
	for u in _alive(list):
		c += u.position
		n += 1
	return c / float(n) if n > 0 else Vector2.INF


func _run() -> void:
	shots = _arg("shots", "")
	var only: Array = []
	var st := _arg("set", "")
	if st != "":
		for s in st.split("+"):
			only.append_array(SETS[s])
	else:
		only = Array(_arg("only", "open-m-crown").split(","))
	var runs := int(_arg("runs", "3"))
	var map := _arg("map", "greenhold")
	var s0 := int(_arg("seed", "0"))
	var t0 := Time.get_ticks_msec()
	for sc in only:
		for r in runs:
			await _one(sc, s0 + r, map)
	var tot := {}
	for x in res:
		var k: String = x["sc"]
		if not tot.has(k):
			tot[k] = {"n": 0, "killed": 0, "lost": 0, "score": 0.0, "wins": 0}
		var t: Dictionary = tot[k]
		t["n"] += 1
		t["killed"] += x["killed"]
		t["lost"] += x["lost"]
		t["score"] += x["score"]
		t["wins"] += 1 if x["score"] > 0.0 else 0
	var all := {"n": 0, "killed": 0, "lost": 0, "score": 0.0, "wins": 0}
	for k in tot:
		var t: Dictionary = tot[k]
		print("TOTAL %-15s n %d  killed %d  lost %d  k/l %.2f  score %+.2f  clockwork won %d" % [k, t["n"], t["killed"], t["lost"],
			float(t["killed"]) / maxf(1.0, float(t["lost"])), t["score"] / float(t["n"]), t["wins"]])
		for f in ["n", "killed", "lost", "score", "wins"]:
			all[f] += t[f]
	print("ALL n %d killed %d lost %d k/l %.2f score %+.3f clockwork won %d  (%d s)" % [all["n"], all["killed"], all["lost"],
		float(all["killed"]) / maxf(1.0, float(all["lost"])), all["score"] / maxf(1.0, float(all["n"])), all["wins"],
		(Time.get_ticks_msec() - t0) / 1000])
	var out := _arg("out", "")
	if out != "":
		var f := FileAccess.open(out, FileAccess.WRITE)
		f.store_string(JSON.stringify({"args": " ".join(OS.get_cmdline_user_args()), "runs": res, "total": tot}, " "))
	quit(0)


func _one(sc: String, r: int, map: String) -> void:
	var parts := sc.split("-")
	var where := parts[0]
	var size := parts[1]
	var foe := parts[2]
	await _start(9100 + r * 31 + sc.hash() % 997, map, foe)
	var ai = _ai(0)
	ai.peaceful = true
	if ai.get("bo_on") == true:
		ai._end_build("bench")
	var eai = _ai(1)
	if eai != null:
		eai.peaceful = true
		if eai.has_method("line_ai"):
			eai.line_ai()
		if eai.get("bo_on") == true:
			eai._end_build("bench")
	await _until(g.clock + 1.5)
	var mid := Vector2(Game.W, Game.H) * Defs.TILE * 0.5
	var halls: Array = ai._halls()
	var hall: Vector2 = halls[0].center() if not halls.is_empty() else Vector2(g.starts[0]) * Defs.TILE
	var goal: Vector2 = Vector2(g.starts[1]) * Defs.TILE
	var to_goal: Vector2 = (goal - mid).normalized()
	var at: Vector2
	var front: Vector2
	if where == "home":
		var out_dir: Vector2 = (mid - hall).normalized()
		at = hall + out_dir * 260.0
		front = out_dir
	else:
		at = mid - to_goal * 900.0
		front = to_goal
	var side := Vector2(-front.y, front.x)
	var tech := _arg("tech", "0") == "1"
	if tech:
		# (late research: the Clockwork's SHIELD WALL, HIGH LEAP, LONG CHAIN; the Crown's Cavalry Charge, Prepared Charges,
		# Gunner's Quadrant; the Brood's Pack Hunt, Battering Horns, Slither, Long Spit)
		for k in ["shield_wall", "high_leap", "long_chain"]:
			g.players[0]["tech"][k] = true
		match _foe_faction(foe):
			"crown":
				for k in ["charge", "charges", "quadrant"]:
					g.players[1]["tech"][k] = true
			"brood":
				for k in ["nb_pack_hunt", "nb_battering_horns", "nb_slither", "nb_long_spit"]:
					g.players[1]["tech"][k] = true
			"clockwork":
				for k in ["shield_wall", "high_leap", "long_chain"]:
					g.players[1]["tech"][k] = true
	g.players[0]["tension"] = 250.0
	if _foe_faction(foe) == "clockwork":
		g.players[1]["tension"] = 250.0
	var down := float(_arg("down", "0"))
	var army := _cw_army(0, size, at, front, side, down)
	var cv := _value(army)
	AICwMicro.reset_counters()
	await _until(g.clock + 1.0)
	var fighters: Array = _alive(army).filter(func(u: Unit) -> bool: return not u.is_worker())
	if where != "home" and ai.push != null:
		ai.push._launch(fighters)
	# THE ENEMY
	var foe_at: Vector2
	match where:
		"home":
			foe_at = at + front * 1300.0
		"side":
			foe_at = at + side * 1100.0 + front * 250.0
		_:
			foe_at = at + front * 1500.0
	var foes: Array = []
	var ff := _foe_faction(foe)
	var ratio := float(_arg("ratio", "1"))
	if ff == "clockwork":
		foes = _cw_army(1, "m" if size in ["B", "P", "S"] else size, foe_at, -front, -side, down)
		while _value(foes) < cv * ratio - 60.0:
			foes.append(_spawn("clock_soldier", 1, foe_at - side * 200.0))
	elif ff == "crown":
		var bv := 0.0
		var i := 0
		var nm := 0
		while bv < cv * ratio and i < 600:
			var k: String = CROWN_ROUND[i % CROWN_ROUND.size()]
			var p: Vector2
			if k == "musketeer":
				p = foe_at + side * (float(nm % 14) - 6.5) * 26.0 + front * float(nm / 14) * 28.0
				nm += 1
			elif k == "cuirassier":
				p = foe_at + front * 50.0 + side * float(i % 2 * 2 - 1) * (210.0 + float(i % 5) * 30.0)
			else:
				p = foe_at + front * (100.0 + (60.0 if k == "mortar" else 0.0)) + side * float((i * 37) % 7 - 3) * 60.0
			var f := _spawn(k, 1, p)
			foes.append(f)
			bv += float(Game.unit_value(f))
			i += 1
		if size == "L":
			for k in ["band", "band_fifer", "band_piper"]:
				foes.append(_spawn(k, 1, foe_at + front * 60.0 + side * (["band", "band_fifer", "band_piper"].find(k) - 1) * 24.0))
	else:
		var kinds: Array = MIX[foe]
		var bv := 0.0
		var i := 0
		while bv < cv * ratio and i < 1200:
			var k: String = kinds[i % kinds.size()]
			var f := _spawn(k, 1, foe_at + side * float((i % 14) - 7) * 30.0 + front * float(i / 14) * 30.0)
			foes.append(f)
			f.cmd_hold()
			bv += float(Game.unit_value(f))
			i += 1
	var ev := _value(foes)
	await _until(g.clock + (2.0 if where == "home" else 3.0))
	var target: Vector2 = hall if where == "home" else at
	var foe_fighters: Array = _alive(foes).filter(func(u: Unit) -> bool: return not u.is_worker())
	if ff == "clockwork":
		if eai != null and eai.push != null:
			eai.push._launch(foe_fighters)
	elif ff == "crown":
		eai._attacking = true
		eai._wave_target = target
		eai._wave_set.clear()
		for u in foe_fighters:
			eai._wave_set[u] = true
			u.cmd_move(target, true)
	else:
		for f in foe_fighters:
			f.cmd_move(target, true)
	var contact_t := -1.0
	var fight := float(_arg("fight", "90"))
	var t_end := g.clock + 150.0
	var k0 := 0.0
	var l0 := 0.0
	var next_shot := 0.0
	var shot_i := 0
	while g.clock < t_end and not g.over:
		await physics_frame
		if contact_t < 0.0 and Engine.get_physics_frames() % 5 == 0:
			for u in _alive(army):
				for o in g.units_near(u.position, 260.0):
					if o.team == 1 and not o.dead:
						contact_t = g.clock
						break
				if contact_t >= 0.0:
					break
			if contact_t >= 0.0:
				t_end = g.clock + fight
				k0 = float(g.stats[0]["value_killed"])
				l0 = float(g.stats[1]["value_killed"])
				next_shot = g.clock + 2.0
		if shots != "" and contact_t >= 0.0 and g.clock >= next_shot and shot_i < 8:
			next_shot = g.clock + 6.0
			await _shot("%s_r%d_%02d.png" % [sc, r, shot_i], army, foes)
			shot_i += 1
		if _arg("trace", "") == "1" and contact_t >= 0.0 and Engine.get_physics_frames() % 60 == 0:
			_trace(ai, army, foes)
		if _alive(foes).filter(func(u: Unit) -> bool: return not u.is_worker()).is_empty() \
				or _alive(army).filter(func(u: Unit) -> bool: return not u.is_worker()).is_empty():
			break
		if Engine.get_physics_frames() % 60 == 0 and ff != "clockwork":
			# (the enemy keeps coming: idle ones walk on at the Clockwork army, the Crown's wave aims at its middle)
			var cc := _centre(army.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead and not u.is_worker()))
			if where == "home" or cc == Vector2.INF:
				cc = target
			if ff == "crown":
				eai._attacking = true
				eai._wave_target = cc
			for o in _alive(foes):
				if o.order == "idle" and o.target == null:
					o.cmd_move(cc, true)
	var cl := _value(army)
	var bl := _value(foes)
	var x := {"sc": sc, "run": r, "cw_value": int(cv), "foe_value": int(ev), "foes": foes.size(),
		"contact": snappedf(contact_t, 0.1), "secs": snappedf(g.clock - maxf(0.0, contact_t), 0.1),
		"killed": int(float(g.stats[0]["value_killed"]) - k0), "lost": int(float(g.stats[1]["value_killed"]) - l0),
		"cw_left": snappedf(cl / maxf(1.0, cv), 0.01), "foe_left": snappedf(bl / maxf(1.0, ev), 0.01),
		"score": snappedf(cl / maxf(1.0, cv) - bl / maxf(1.0, ev), 0.01),
		"down_end": _alive(army).filter(func(u: Unit) -> bool: return u.powered_down()).size(),
		"micro": AICwMicro.counters(0), "dead": _dead_by_kind(army), "foe_dead": _dead_by_kind(foes)}
	res.append(x)
	print("  %s run %d: %s" % [sc, r, str(x)])


## "kind": "dead/all" of a list (who fell).
func _dead_by_kind(list: Array) -> Dictionary:
	var all := {}
	var dead := {}
	for u in list:
		var k: String = u.kind if is_instance_valid(u) else "?"
		all[k] = int(all.get(k, 0)) + 1
		if not is_instance_valid(u) or u.dead:
			dead[k] = int(dead.get(k, 0)) + 1
	var o := {}
	for k in all:
		o[k] = "%d/%d" % [int(dead.get(k, 0)), int(all[k])]
	return o


## A Clockwork army of `size` at `at`: the fighters in rows facing `front`, the machines behind, the Winders behind them.
func _cw_army(t: int, size: String, at: Vector2, front: Vector2, side: Vector2, down: float) -> Array:
	var comp: Dictionary = CW[size]
	var out: Array = []
	var n := 0
	for k in ["clock_soldier", "pendulum", "springer", "netter"]:
		for i in int(comp.get(k, 0)):
			var row := n / 14
			out.append(_spawn(k, t, at + side * (float(n % 14) - 6.5) * 28.0 - front * float(row) * 30.0))
			n += 1
	var back := float(n / 14 + 1) * 30.0
	for i in int(comp.get("ballista", 0)):
		out.append(_spawn("ballista", t, at - front * (back + 90.0) + side * (float(i) - float(comp["ballista"] - 1) * 0.5) * 80.0))
	for i in int(comp.get("great_winder", 0)):
		out.append(_spawn("great_winder", t, at - front * (back + 160.0)))
	for i in int(comp.get("winder", 0)):
		out.append(_spawn("winder", t, at - front * (back + 60.0) + side * (float(i) - float(comp["winder"] - 1) * 0.5) * 50.0))
	if down > 0.0:
		var cons: Array = out.filter(func(u: Unit) -> bool: return not u.is_worker() and u.kind != Defs.GREAT_WINDER_KIND)
		var nd := int(round(float(cons.size()) * down))
		for j in nd:
			var u: Unit = cons[j * cons.size() / maxi(1, nd)]
			u.wind = 0.2 + 0.25 * float(j % 4) / 3.0
	return out


## trace:1 every 2 s: what the Clockwork army is doing (the films in numbers).
func _trace(ai, army: Array, foes: Array) -> void:
	var by := {}
	var engaged := 0
	var idle_far := 0
	var down := 0
	var hurt := 0
	var shield := 0
	var wind := 0.0
	var n := 0
	var ec := _centre(foes)
	for u in _alive(army):
		if u.is_worker():
			by["W:" + u.order] = int(by.get("W:" + u.order, 0)) + 1
			continue
		n += 1
		wind += u.wind
		var k: String = u.kind.substr(0, 4) + ":" + u.order
		by[k] = int(by.get(k, 0)) + 1
		var nd := INF
		for o in g.units_near(u.position, 450.0):
			if o.team == 1 and not o.dead:
				nd = minf(nd, o.position.distance_to(u.position))
		if nd <= float(u.d["range"]) + u.radius + 24.0:
			engaged += 1
		elif u.order == "idle" and nd > 260.0:
			idle_far += 1
		if u.powered_down():
			down += 1
		if u.hp < u.max_hp * 0.4:
			hurt += 1
		if u.shield_up:
			shield += 1
		if _arg("trace2", "") == "1" and u.kind == "clock_soldier":
			var tg = u.target
			print("      cs %s %s tgt %s d %d nd %d cd %.1f st %s" % [u.order, str(u.velocity.length()).left(4), (tg.kind if tg != null and is_instance_valid(tg) else "-"),
				int(tg.position.distance_to(u.position)) if tg != null and is_instance_valid(tg) else -1, int(nd), u.cooldown, str(u.get("stun_t"))])
	var fk := {}
	for o in _alive(foes):
		fk[o.kind.substr(0, 4)] = int(fk.get(o.kind.substr(0, 4), 0)) + 1
	var ph: String = ai.push.phase if ai.push != null else "-"
	print("    t%5.1f push %-6s cw %2d engaged %2d idle_far %2d down %d hurt %d shield %d wind %.2f gap %4d | %s | foes %s" % [g.clock, ph, n, engaged,
		idle_far, down, hurt, shield, wind / maxf(1.0, n), int(_centre(army).distance_to(ec)) if ec != Vector2.INF else -1, str(by), str(fk)])


func _shot(file: String, wave: Array, foes: Array) -> void:
	var c := Vector2.ZERO
	var n := 0
	for u in _alive(wave) + _alive(foes):
		c += u.position
		n += 1
	if n == 0:
		return
	var cam: Camera2D = g.camera
	cam.position = c / float(n)
	cam.zoom = Vector2(0.9, 0.9)
	cam.reset_smoothing()
	for k in 3:
		await process_frame
	var img := root.get_viewport().get_texture().get_image()
	img.save_jpg(shots.path_join(file.replace(".png", ".jpg")), 0.8)
