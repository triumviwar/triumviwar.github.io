extends SceneTree
## THE BROOD'S FIGHTS AT EQUAL VALUE, a set-piece bench (brood-micro, docs/brood_micro.md; the owner 2026-11-25: "a gigantic
## round of battles, micro training the AI" ... "it's only fair to make this testing to all matchups"). The method of
## crown-micro's tools/bench_crown_micro.gd, the other way round: no economy, a Brood army and an enemy army of the SAME
## value (Game.unit_value) meet. The BROOD fights under its own computer (Hard: its wave, its close-ranks, its gathering,
## its defence, its Toads' spells; and the brood-micro coaching unless `bmic:off`). The ENEMY fights under its own Hard
## computer too: the Crown's wave, line, guns, screen and riders; the Clockwork's push; in the mirror another Brood
## computer (with no brood-micro coaching, so the mirror measures the coaching against the old Brood).
## Neither computer builds: their food and gold are taken away every second.
## Scenarios `<foe>:<where>-<size>-<mix>`:
##   foe    crown, clockwork, brood
##   where  open  both waves march across the open middle and meet
##          home  the Brood army stands at home by its Mother; the enemy wave walks in (the Brood defends)
##          base  the enemy army stands at home in front of its hall; the Brood wave walks in (the Brood attacks)
##   size   m (about 1,600 a side), l (about 3,000), R (the armies the computers really field at 10:00-15:00)
##   mix    the Brood's army: raptor (Raptors only), mixed (2 Raptors : 1 Spitter : 1 Tyrant Challenger), spit (Spitters
##          with a Raptor screen), real (what the Brood computer really fields against that foe, from the wr1000 data)
## The score of a fight (from the first contact, at most `fight` s, default 90): the share of the Brood army left minus the
## share of the enemy army left (hit points counted): +1 a clean Brood win, -1 a clean loss. "k/l" the value the Brood
## killed for each value it lost.
##   godot --headless --fixed-fps 30 --path . --script res://tools/bench_brood_micro.gd -- [only:crown:open-m-mixed,...|set:core]
##       [runs:3] [map:greenhold] [seed:0] [tech:1] [fight:90] [out:/abs/file.json] [shots:/abs/dir] [bmic:off ...]
## ratio:1.5 the Brood brings that many times the enemy's value. A measuring tool: it changes no rule.
var main: Node
var g: Game
var res: Array = []
var shots := ""

const SETS := {
	"crown": ["crown:open-m-raptor", "crown:open-m-mixed", "crown:open-m-spit", "crown:home-m-mixed", "crown:base-m-mixed",
		"crown:open-l-real", "crown:home-l-real", "crown:base-l-real"],
	"clockwork": ["clockwork:open-m-raptor", "clockwork:open-m-mixed", "clockwork:open-m-spit", "clockwork:home-m-mixed",
		"clockwork:base-m-mixed", "clockwork:open-l-real", "clockwork:home-l-real", "clockwork:base-l-real"],
	"brood": ["brood:open-m-raptor", "brood:open-m-mixed", "brood:open-m-spit", "brood:home-m-mixed", "brood:base-m-mixed",
		"brood:open-l-real", "brood:home-l-real", "brood:base-l-real"],
	# (the armies the computers really field, both sides with their late research: run with tech:1)
	"real": ["crown:open-R-real", "crown:home-R-real", "crown:base-R-real", "clockwork:open-R-real", "clockwork:home-R-real",
		"clockwork:base-R-real", "brood:open-R-real", "brood:home-R-real"],
}

## The enemy's army by size (the Brood brings the same value).
const FOE := {
	"crown": {
		"m": {"musketeer": 14, "cannon": 3, "cuirassier": 3, "mortar": 1},
		"l": {"musketeer": 26, "cannon": 5, "cuirassier": 4, "mortar": 2},
		# (wr1000 crown-brood, 10:00-15:00: ~20 Musketeers, 4 Cuirassiers, 2-3 guns, a Mortar, a band now and then)
		"R": {"musketeer": 20, "cannon": 3, "cuirassier": 4, "mortar": 1, "band": 1, "band_fifer": 1, "band_piper": 1},
	},
	"clockwork": {
		"m": {"clock_soldier": 14, "springer": 2, "pendulum": 1, "netter": 1, "winder": 3},
		"l": {"clock_soldier": 24, "springer": 3, "pendulum": 2, "netter": 2, "ballista": 1, "winder": 4},
		# (wr1000 clockwork-brood, 10:00-15:00: ~24 Clock Soldiers, 2-3 Pendulums, 2 Springers, Owls, a Swift)
		"R": {"clock_soldier": 24, "springer": 2, "pendulum": 3, "ticking_owl": 2, "cuckoo": 1, "winder": 4},
	},
	"brood": {
		"m": {"raptor": 20, "spitter": 6, "tyrant_challenger": 2},
		"l": {"raptor": 36, "spitter": 10, "tyrant_challenger": 4, "brute": 1},
		# (wr1000 brood-mirror, 10:00-15:00: ~70 Raptors, ~8 Spitters, ~3 Challengers)
		"R": {"raptor": 60, "spitter": 9, "tyrant_challenger": 3, "brute": 1},
	},
}
const MIX := {
	"raptor": ["raptor"],
	"mixed": ["raptor", "raptor", "spitter", "tyrant_challenger"],
	"spit": ["spitter", "spitter", "raptor"],
}
## "real": what the Brood computer fields against each foe (wr1000 data, 10:00-15:00), a repeating pattern.
const REAL := {
	"crown": ["raptor", "raptor", "raptor", "raptor", "spitter", "raptor", "raptor", "raptor", "tyrant_challenger", "raptor",
		"raptor", "spitter", "raptor", "raptor", "brute", "raptor", "raptor", "mist_toad"],
	"clockwork": ["raptor", "spitter", "spitter", "raptor", "spitter", "raptor", "spitter", "brute", "raptor", "spitter",
		"tyrant_challenger", "spitter"],
	"brood": ["raptor", "raptor", "raptor", "raptor", "spitter", "raptor", "raptor", "raptor", "tyrant_challenger", "raptor",
		"raptor", "spitter", "raptor", "raptor", "raptor", "raptor", "spitter", "raptor", "raptor", "tyrant_challenger"],
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
		_starve()


## Neither side builds: no gold, no food, no second resource.
func _starve() -> void:
	if Engine.get_physics_frames() % 15 != 0:
		return
	for t in 2:
		g.players[t]["gold"] = 0
		if g.players[t].has("res2"):
			g.players[t]["res2"] = 0


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
		{"who": "hard", "faction": foe, "colour": 0, "side": 0, "strategy": "balanced"},
		{"who": "hard", "faction": "brood", "colour": 1, "side": 1, "strategy": "balanced"}]})
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


func _run() -> void:
	shots = _arg("shots", "")
	var only: Array = []
	var st := _arg("set", "")
	if st != "":
		for s in (["crown", "clockwork", "brood"] if st == "core" else st.split("+")):
			only += SETS[s]
	else:
		only = Array(_arg("only", "crown:open-m-mixed").split(","))
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
		print("TOTAL %-26s n %d  killed %d  lost %d  k/l %.2f  score %+.2f  brood won %d" % [k, t["n"], t["killed"], t["lost"],
			float(t["killed"]) / maxf(1.0, float(t["lost"])), t["score"] / float(t["n"]), t["wins"]])
		for f in ["n", "killed", "lost", "score", "wins"]:
			all[f] += t[f]
	print("ALL n %d killed %d lost %d k/l %.2f score %+.3f brood won %d  (%d s)" % [all["n"], all["killed"], all["lost"],
		float(all["killed"]) / maxf(1.0, float(all["lost"])), all["score"] / maxf(1.0, float(all["n"])), all["wins"],
		(Time.get_ticks_msec() - t0) / 1000])
	var out := _arg("out", "")
	if out != "":
		var f := FileAccess.open(out, FileAccess.WRITE)
		f.store_string(JSON.stringify({"args": " ".join(OS.get_cmdline_user_args()), "runs": res, "total": tot}, " "))
	quit(0)


## A wave of `list` sent at `goal` under the computer of team t (forced: the bench decides when, the computer how).
func _send(t: int, list: Array, goal: Vector2) -> void:
	var ai = _ai(t)
	var fac: String = g.factions[t]
	if fac == "brood":
		ai._wave = list.duplicate()
		ai._wave_target = goal
		ai._wave_v0 = ai._value_of(ai._wave)
		ai._wave_t0 = g.clock
		ai._wave_kills0 = int(g.stats[t]["value_killed"])
		ai._wave_sup = 0
		for u in list:
			ai._wave_sup += int(u.d["supply"])
		ai._attacking = true
		ai._first_out = true
		for u in list:
			u.cmd_move(goal, true)
		ai._nb_close_start(false)
	elif fac == "clockwork":
		if ai.push != null:
			ai.push._launch(list.filter(func(u: Unit) -> bool: return u.kind != "winder") + list.filter(func(u: Unit) -> bool: return u.kind == "winder"))
		else:
			for u in list:
				u.cmd_move(goal, true)
	else:
		ai._attacking = true
		ai._wave_target = goal
		ai._wave_set.clear()
		for u in list:
			ai._wave_set[u] = true
			u.cmd_move(goal, true)


## The army of `comp` ({kind: n}) for team t in rows facing `front` round `at`.
func _place(t: int, comp: Dictionary, at: Vector2, front: Vector2) -> Array:
	var side := Vector2(-front.y, front.x)
	var out: Array = []
	var back := ["cannon", "mortar", "ballista", "winder", "band", "band_fifer", "band_piper", "spitter", "mist_toad"]
	var i := 0
	for k in comp:
		for j in int(comp[k]):
			var row := float(i / 14)
			var p: Vector2 = at + side * (float(i % 14) - 6.5) * 26.0 - front * row * 28.0
			if back.has(k):
				p = at - front * (90.0 + row * 20.0) + side * (float(j) - float(comp[k] - 1) * 0.5) * 60.0
			elif k == "cuirassier":
				p = at - front * 50.0 + side * (j % 2 * 2 - 1) * (190.0 + float(j / 2) * 40.0)
			else:
				i += 1
			out.append(_spawn(k, t, p))
	return out


func _one(sc: String, r: int, map: String) -> void:
	var fp := sc.split(":")
	var foe: String = fp[0]
	var parts := fp[1].split("-")
	var where := parts[0]
	var size := parts[1]
	var mix := parts[2]
	await _start(9100 + r * 31 + sc.hash() % 997, map, foe)
	var bai = _ai(1)
	var fai = _ai(0)
	bai.peaceful = true
	fai.peaceful = true
	if foe == "crown":
		fai.line_ai()
	if foe == "brood":
		fai.bmic_off = true          # (the mirror: the other Brood is the old one, without the coaching)
	await _until(g.clock + 1.0)
	var mid := Vector2(Game.W, Game.H) * Defs.TILE * 0.5
	var home0: Vector2 = Vector2(g.starts[0]) * Defs.TILE
	var home1: Vector2 = Vector2(g.starts[1]) * Defs.TILE
	var bq: Unit = BroodNew.queen(g, 1)
	if bq != null:
		home1 = bq.position
	var halls: Array = fai._halls() if foe != "brood" else []
	if not halls.is_empty():
		home0 = halls[0].center()
	elif foe == "brood" and BroodNew.queen(g, 0) != null:
		home0 = BroodNew.queen(g, 0).position
	var dir: Vector2 = (home1 - home0).normalized()        # (from the enemy toward the Brood)
	var fat: Vector2
	var bat: Vector2
	match where:
		"home":
			bat = home1 - dir * 300.0
			fat = bat - dir * 1500.0
		"base":
			fat = home0 + dir * 320.0
			bat = fat + dir * 1500.0
		_:
			fat = mid - dir * 750.0
			bat = mid + dir * 750.0
	if _arg("tech", "0") == "1":
		for k in ["nb_pack_hunt", "nb_battering_horns", "nb_slither", "nb_long_spit", "nb_fog", "nb_miasma"]:
			g.players[1]["tech"][k] = true
			if foe == "brood":
				g.players[0]["tech"][k] = true
		if foe == "crown":
			for k in ["charge", "charges", "quadrant"]:
				g.players[0]["tech"][k] = true
		elif foe == "clockwork":
			for k in ["high_leap", "shield_wall", "long_chain"]:
				g.players[0]["tech"][k] = true
	var fw: Array = _place(0, FOE[foe][size], fat, dir)
	var fv := _value(fw)
	var kinds: Array = REAL[foe] if mix == "real" else MIX[mix]
	var bw: Array = []
	var bv := 0.0
	var i := 0
	var ratio := float(_arg("ratio", "1"))
	var bside := Vector2(-dir.y, dir.x)
	while bv < fv * ratio and i < 1200:
		var k: String = kinds[i % kinds.size()]
		var back := 1.0 if k in ["spitter", "mist_toad"] else 0.0
		var f := _spawn(k, 1, bat + bside * float((i % 14) - 7) * 30.0 + dir * (float(i / 14) * 30.0 + back * 60.0))
		bw.append(f)
		bv += float(Game.unit_value(f))
		i += 1
	for u in bw:
		if u.kind == "mist_toad":
			u.charge = 200.0
	AIBroodMicro.reset_counters()
	var dry := float(_arg("dry", "0"))
	if dry > 0.0:
		var mk: Array = fw.filter(func(u: Unit) -> bool: return u.kind == "musketeer")
		for j in int(round(float(mk.size()) * dry)):
			mk[j * mk.size() / maxi(1, int(round(float(mk.size()) * dry)))].powder = 0.0
	await _until(g.clock + 1.5)
	match where:
		"home":
			_send(0, _alive(fw), home1)
		"base":
			_send(1, _alive(bw), home0)
		_:
			_send(0, _alive(fw), home1)
			_send(1, _alive(bw), home0)
	var contact_t := -1.0
	var fight := float(_arg("fight", "90"))
	var t_end := g.clock + 150.0
	var k0 := 0.0
	var l0 := 0.0
	var next_shot := 0.0
	var shot_i := 0
	while g.clock < t_end and not g.over:
		await physics_frame
		_starve()
		if contact_t < 0.0 and Engine.get_physics_frames() % 5 == 0:
			for u in _alive(bw):
				for o in g.units_near(u.position, 260.0):
					if o.team == 0 and not o.dead and fw.has(o):
						contact_t = g.clock
						break
				if contact_t >= 0.0:
					break
			if contact_t >= 0.0:
				t_end = g.clock + fight
				k0 = float(g.stats[1]["value_killed"])
				l0 = float(g.stats[0]["value_killed"])
				next_shot = g.clock + 2.0
		if shots != "" and contact_t >= 0.0 and g.clock >= next_shot and shot_i < 10:
			next_shot = g.clock + 5.0
			await _shot("%s_r%d_%02d.png" % [sc.replace(":", "_"), r, shot_i], bw, fw)
			shot_i += 1
		if _alive(fw).is_empty() or _alive(bw).is_empty():
			break
		# (an army left standing still after its wave ended goes on at the other: a fight is fought to its end)
		if Engine.get_physics_frames() % 90 == 0 and contact_t >= 0.0:
			if where != "base":
				for o in _alive(fw):
					if o.order == "idle" and o.target == null:
						o.cmd_move(home1, true)
			if where != "home":
				for o in _alive(bw):
					if o.order == "idle" and o.target == null and not bai._attacking:
						o.cmd_move(home0, true)
	var bl := _value(bw)
	var fl := _value(fw)
	var x := {"sc": sc, "run": r, "brood_value": int(bv), "foe_value": int(fv), "brood_n": bw.size(),
		"contact": snappedf(contact_t, 0.1), "secs": snappedf(g.clock - maxf(0.0, contact_t), 0.1),
		"killed": int(float(g.stats[1]["value_killed"]) - k0), "lost": int(float(g.stats[0]["value_killed"]) - l0),
		"brood_left": snappedf(bl / maxf(1.0, bv), 0.01), "foe_left": snappedf(fl / maxf(1.0, fv), 0.01),
		"score": snappedf(bl / maxf(1.0, bv) - fl / maxf(1.0, fv), 0.01), "micro": AIBroodMicro.counters(1)}
	res.append(x)
	print("  %s run %d: %s" % [sc, r, str(x)])


func _shot(file: String, bw: Array, fw: Array) -> void:
	var c := Vector2.ZERO
	var n := 0
	for u in _alive(bw) + _alive(fw):
		c += u.position
		n += 1
	if n == 0:
		return
	var cam: Camera2D = g.camera
	cam.position = c / float(n)
	cam.zoom = Vector2(0.8, 0.8)
	cam.reset_smoothing()
	for k in 3:
		await process_frame
	var img := root.get_viewport().get_texture().get_image()
	img.save_jpg(shots.path_join(file.replace(".png", ".jpg")), 0.8)
