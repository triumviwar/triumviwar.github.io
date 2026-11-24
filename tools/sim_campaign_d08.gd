extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 2's "Down the Rivers" (docs/campaign_d08_build.md) from either side with a simple bot and prints, every 30
## seconds, how it goes: the part, Nazaré's people away, the wave, the forward Mothers, the Barra's men and buildings,
## the swarm's creatures, the clocks. A balance check (the owner's three rules: NO WAITING is measured): the Barra's
## player who plays it takes the column up to Nazaré, sends each group to the canoes, comes home, holds the lower town
## and the west gate with the garrison, trains Musketeers, mends the palisade, sends the Dragoons after a walking
## forward Mother, and picks the lure book's choice (`lure=used` or the default: burned); a player who does nothing
## loses (the bluff broken) or holds by luck; the swarm's player lays Raptors, catches Nazaré's people, roots its second
## Mother opposite the Barra and goes for the guns and the church.
## At the end: the mission's longest stretch with nothing to do (target under 45 s).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_d08.gd -- [active] [side=barra|swarm]
##        [diff=easy|normal|hard] [lure=burned|used] [saved=few|some|many] [map=drawn|withheld] [brood_n=few|some|all]
##        [clutch=saved|burned] [book=left|taken] [nohunt] [low=<n>] [until=<s>] [save_at=<s>] [shots=<dir>]
##   low=n: every n-th of the Barra's men stands in the lower town (3: a third, the default; 2: half)
##   nohunt: the Barra's player never sends the Dragoons over the water after a forward Mother
## The earlier missions' flags are written into the progress file for the run (and the player's own progress put back).
var main: Node
var until := 1800.0
var active := false
var nohunt := false
var low := 3          # every low-th man stands in the lower town (low=2: half of them)
var side := "barra"
var diff := "normal"
var lure := "burned"
var b01 := {"clutch": "saved", "eggs": "left", "pieter": "alive", "rival": "standing", "teles": "quiet", "saved": "some"}
var a03 := {"map": "drawn", "party": "some", "survey": "full", "linnea": "seen", "sire_way": "east"}
var d06 := {"brood_n": "some", "brood_n_n": 4, "pieter": "alive", "lindqvist": "fled", "book": "left", "queen": "grown"}
var _saved_progress := ""
var shots := ""
var _shot_n := 0
var _shot_done := {}
var _spot := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a == "nohunt":
			nohunt = true
		elif a.begins_with("low="):
			low = int(a.substr(4))
		elif a.begins_with("shots="):
			shots = a.substr(6)
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("side="):
			side = a.substr(5)
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.begins_with("lure="):
			lure = a.substr(5)
		elif a.begins_with("saved="):
			b01["saved"] = a.substr(6)
		elif a.begins_with("clutch="):
			b01["clutch"] = a.substr(7)
		elif a.begins_with("map="):
			a03["map"] = a.substr(4)
		elif a.begins_with("brood_n="):
			d06["brood_n"] = a.substr(8)
		elif a.begins_with("book="):
			d06["book"] = a.substr(5)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["d08_rivers"], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	p["done"]["b01_specimen"] = {"won_by": "sire", "side": "sire", "flags": b01}
	p["done"]["a03_plateau"] = {"won_by": "party", "side": "party", "flags": a03}
	p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}}
	p["done"]["d03_fazenda"] = {"won_by": "stock", "side": "stock", "flags": {"hidden": "some", "hidden_n": 4, "storm": "hatched", "pieter": "alive"}}
	p["done"]["d06_queen"] = {"won_by": "brood", "side": "brood", "flags": d06}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var probs := Campaign.problems(Campaign.mission("d08_rivers"))
	if not probs.is_empty():
		print("SIM PROBLEMS ", probs)
	main.start(Campaign.make_cfg("d08_rivers", "solo", "p1", false, side))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	print("SIM side=%s diff=%s lure=%s b01=%s a03=%s d06=%s active=%s human=%d" % [side, diff, lure, str(b01), str(a03), str(d06), active, g.human])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
			_spot = {}
		if shots != "":
			await _shots(g, r)
		# the lure book's choice: the sim's answer as soon as the panel asks
		if active and side == "barra" and r.fired.has("the_choice") and not r.flags.has("lure") and not _spot.has("chose"):
			_spot["chose"] = true
			_choose(r, "lure", lure)
		if active and g.clock >= think:
			think = g.clock + 0.75
			if side == "swarm":
				_play_swarm(g, r)
			else:
				_play_barra(g, r)
		if g.clock >= next:
			next += float(OS.get_environment("SIMSTEP")) if OS.get_environment("SIMSTEP") != "" else 30.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else ("3" if not r.fired.has("dawn") else "D"))
			print("SIM t=%4d part=%s out=%d/%d called=%d wave=%d fwd(k/r)=%d/%d barra=%d swarm=%d hall=%s church=%s quarters=%d walls=%d guns=%d great=%d nazare=%s dawn=%s floods=%s gold=%d" % [
				g.clock, part, int(r.counters.get("out_n", 0)), int(r.counters.get("vill_n", 0)), int(r.counters.get("called", 0)),
				int(r.counters.get("wave_n", 0)), int(r.counters.get("fwd_killed", 0)), int(r.counters.get("fwd_rooted", 0)),
				_n(g, r, "barra"), _n(g, r, "swarm"), _hp(r, "hall"), _hp(r, "church"), r.tagged("quarters").size(),
				r.tagged("palisade").size(), r.tagged("guns").size(), r.tagged("great").size(), _left(g, r, "nazare"), _left(g, r, "dawn"),
				_left(g, r, "floods"), int(g.players[g.human]["gold"])])
			if OS.get_cmdline_user_args().has("debug"):
				for u in r.tagged("riders"):
					print("   rider %s %s order=%s hp=%d" % [u.kind, g.cell_of(u.position), u.order, u.hp])
				for tg in ["great", "fwd_m", "fwd_s", "waves"]:
					for u in r.tagged(tg):
						print("   %s %s %s order=%s hp=%d rooted=%s" % [tg, u.kind, g.cell_of(u.position), u.order, u.hp, BroodNew.rooted(u)])
	var idle: Dictionary = r.longest_idle()
	print("SIM end t=%d over=%s winner=%s flags=%s counters=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.counters, r.obj])
	print("SIM longest_idle %d s (from %d s)%s" % [int(idle.get("secs", 0.0)), int(idle.get("from", 0.0)), "" if float(idle.get("secs", 0.0)) < 45.0 else "  OVER 45 s"])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _choose(r: MissionRun, cid: String, opt: String) -> void:
	# (the choice panel's own answer path: MissionRun.choose)
	if r.has_method("choose"):
		r.choose(cid, opt)


func _hp(r: MissionRun, tag: String) -> String:
	var l: Array = r.tagged(tag)
	if l.is_empty():
		return "-"
	return "%d" % int(l[0].hp)


func _n(g: Game, r: MissionRun, team: String) -> int:
	var t := r.team_index(team)
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind != "horse").size()


func _left(g: Game, r: MissionRun, cn: String) -> String:
	return "%ds" % int(float(r.clocks[cn]) - g.clock) if r.clocks.has(cn) else "-"


func _go(g: Game, u: Unit, p: Vector2, attack := false) -> void:
	if u.velocity.length() < 5.0 or u.order_point.distance_to(p) > 48.0:
		g.group_move([u], p, attack)


func _alive(u) -> bool:
	return u != null and is_instance_valid(u) and not u.dead


func _nearest_foe(g: Game, t: int, p: Vector2, reach: float, buildings := false) -> Entity:
	var best: Entity = null
	var bd := reach
	for e in g.units:
		if e.dead or e.off_field or not g.hostile(e.team, t) or e.untouchable() or e.kind == "horse":
			continue
		var d: float = e.position.distance_to(p)
		if d < bd:
			bd = d
			best = e
	if buildings:
		for b in g.buildings:
			if b.dead or b.ghost or not g.hostile(b.team, t) or b.untouchable():
				continue
			var d2: float = b.center().distance_to(p)
			if d2 < bd:
				bd = d2
				best = b
	return best


func _mid(r: MissionRun, a: String) -> Vector2:
	return r.area_rect(a).get_center()


## The Barra's player.
func _play_barra(g: Game, r: MissionRun) -> void:
	var bt := r.team_index("barra")
	var men: Array = g.units.filter(func(u): return not u.dead and u.team == bt and u.kind != "horse" and u.kind != "labourer")
	var labs: Array = g.units.filter(func(u): return not u.dead and u.team == bt and u.kind == "labourer")
	# the hands: three on each Farm at first, then the hurt palisade and houses mended
	var farms: Array = r.tagged("farms")
	if not _spot.has("farms") and not farms.is_empty():
		_spot["farms"] = true
		for i in labs.size():
			labs[i].cmd_gather(farms[i % farms.size()])
	if r.fired.has("part2"):
		var hurt: Entity = null
		for b in r.tagged("palisade") + r.tagged("quarters"):
			if not b.dead and b.hp < b.max_hp * 0.7 and _nearest_foe(g, bt, b.center(), 4.0 * Defs.TILE) == null:
				hurt = b
				break
		if hurt:
			for u in labs.slice(0, 2):
				if u.order != "repair":
					u.cmd_repair(hurt)
	# the Barracks: Musketeers while the gold lasts
	for b in r.tagged("barracks"):
		if not b.dead and b.queue.size() < 2 and int(g.players[bt]["gold"]) >= 120 and g.can_train(b, "musketeer") == "":
			g.train(b, "musketeer")
	var column: Array = r.tagged("column")
	if not r.fired.has("part2"):
		# PART 1: the riders to the fields, the rest to the chapel then the houses; fight what comes near
		var order := ["g_chapel", "g_houses"]
		for u in column:
			if not _alive(u):
				continue
			var foe := _nearest_foe(g, bt, u.position, 7.0 * Defs.TILE)
			if foe and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
				u.cmd_attack(foe)
				continue
			var goal := "g_fields" if u.kind == "dragoon" else ("g_chapel" if not r.fired.has("call_g_chapel") else ("g_houses" if not r.fired.has("call_g_houses") else "beach"))
			if u.kind == "dragoon" and r.fired.has("call_g_fields"):
				goal = "rapids_e"
			if u.target == null or not is_instance_valid(u.target) or u.target.dead:
				_go(g, u, _mid(r, goal), true)
		return
	# PART 2 / 3: the column home, the garrison at the west gate and in the lower town, the guns hold
	var home := _mid(r, "west_gate") + Vector2(3.0 * Defs.TILE, 0)
	var lower := _mid(r, "s_e") + Vector2(2.0 * Defs.TILE, 0)
	var hunters: Array = []
	if OS.get_cmdline_user_args().has("debug") and not _spot.has("colk"):
		_spot["colk"] = true
		print("  column kinds ", column.map(func(u): return "%s dead=%s" % [u.kind, u.dead] if is_instance_valid(u) else "freed"))
	if not nohunt:
		for m in ["fwd_m", "fwd_s"]:
			for mo in r.tagged(m):
				if _alive(mo) and not BroodNew.rooted(mo) and not r.fired.has(m + "_root"):
					hunters = column.filter(func(u): return _alive(u) and u.kind != "dismounted")
					for u in hunters:
						if u.position.distance_to(mo.position) < 6.0 * Defs.TILE:
							if u.target != mo:
								u.cmd_attack(mo)
						else:
							_go(g, u, mo.position, false)
	var i := 0
	for u in men:
		if hunters.has(u) or u.kind == "cannon":
			continue
		i += 1
		var foe := _nearest_foe(g, bt, u.position, 8.0 * Defs.TILE)
		if foe:
			if u.target == null or not is_instance_valid(u.target) or u.target.dead:
				u.cmd_attack(foe)
			continue
		var spot := lower if i % low == 0 else home
		if u.position.distance_to(spot) > 3.0 * Defs.TILE:
			_go(g, u, spot + Vector2(float(i % 4) * 20.0 - 30.0, float(i % 5) * 18.0 - 36.0), true)


## The swarm's player.
func _play_swarm(g: Game, r: MissionRun) -> void:
	var st := r.team_index("swarm")
	var moms: Array = r.tagged("fwd").filter(func(u): return _alive(u))
	if moms.is_empty():
		return
	for m in moms:
		if BroodNew.rooted(m):
			BroodNew.lay(g, m, "raptor")
			BroodNew.lay(g, m, "spitter")
	# the second Mother down the far bank to root opposite the Barra
	for m in r.tagged("fwd_m"):
		if not _alive(m) or BroodNew.rooted(m) or m.order == "nb_root":
			continue
		var spot := _mid(r, "fb_s_spot")
		if m.position.distance_to(spot) > 2.0 * Defs.TILE:
			_go(g, m, spot)
		elif m.velocity.length() < 5.0:
			BroodRoot.start_root(m, m.position)
	var army: Array = g.units.filter(func(u): return not u.dead and u.team == st and not (u.kind in BroodNew.ROOTERS) and u.has_attack() and u.kind != "grub")
	var attack: bool = army.size() >= 16 or _spot.has("go")
	if attack:
		_spot["go"] = true
	for u in army:
		if u.target != null and is_instance_valid(u.target) and not u.target.dead:
			continue
		if g.clock < 140.0 and not r.fired.has("part2"):
			# Nazaré's people first: over the rapids
			var vil := _nearest_target(g, r, "villagers", u.position)
			if vil:
				u.cmd_attack(vil)
			else:
				_go(g, u, _mid(r, "nazare"), true)
		elif attack:
			var tgt := _nearest_target(g, r, "guns", u.position)
			if tgt == null:
				tgt = _nearest_target(g, r, "church", u.position)
			if tgt and u.position.distance_to(tgt.position if tgt is Unit else tgt.center()) < 10.0 * Defs.TILE:
				u.cmd_attack(tgt)
			else:
				_go(g, u, _mid(r, "west_gate") if r.tagged("guns").size() > 0 else _mid(r, "church_go"), true)
		else:
			_go(g, u, _mid(r, "fb_s"))


func _nearest_target(g: Game, r: MissionRun, tag: String, p: Vector2) -> Entity:
	var best: Entity = null
	for e in r.tagged(tag):
		if e.dead:
			continue
		var q: Vector2 = e.position if e is Unit else e.center()
		if best == null or q.distance_to(p) < (best.position if best is Unit else best.center()).distance_to(p):
			best = e
	return best


## CHECK THE FEEL: pictures of each part, the camera on what matters then (docs/shots/d08_rivers/).
func _shots(g: Game, r: MissionRun) -> void:
	var f := func(id: String, after: float) -> bool: return r.fired.has(id) and g.clock > float(r.fired.get(id, 0)) + after
	var want := {"start": g.clock > 3.0, "trail": g.clock > 30.0, "nazare": f.call("call_g_chapel", 3.0), "raid": f.call("raid_1", 12.0),
		"canoes": f.call("first_out", 2.0), "rooted": f.call("rooted_n", 4.0), "part2": f.call("part2", 3.0), "fwd": f.call("fwd_m_walk", 20.0),
		"wave1": f.call("wave_1_go", 18.0), "wave3": f.call("wave_3_go", 20.0), "fwd_root": f.call("fwd_s_root", 3.0),
		"choice": f.call("the_choice", 2.0), "night": f.call("great", 6.0), "lured": f.call("lured_say", 4.0),
		"great": f.call("great_go", 20.0), "dawn": f.call("dawn", 3.0), "s_root": f.call("s_rooted", 2.0), "s_attack": g.clock > 420.0 and side == "swarm"}
	for k in want:
		if not want[k] or _shot_done.has(k):
			continue
		_shot_done[k] = true
		var at := Vector2.INF
		match k:
			"start":
				at = _mid(r, "col_start")
			"trail":
				var v: Array = r.tagged("valadares")
				if not v.is_empty():
					at = v[0].position
			"nazare", "canoes", "raid":
				at = _mid(r, "nazare")
			"rooted":
				at = _mid(r, "fb_n") + Vector2(12 * Defs.TILE, 0)
			"part2", "wave1", "wave3", "great", "dawn", "s_attack":
				at = _mid(r, "s_e") + Vector2(4 * Defs.TILE, 0)
			"fwd":
				var m: Array = r.tagged("fwd_m")
				at = m[0].position if not m.is_empty() else _mid(r, "fb_m")
			"fwd_root", "s_root":
				at = _mid(r, "fb_s")
			"choice", "night", "lured":
				at = _mid(r, "far_point")
		if at == Vector2.INF:
			at = _mid(r, "bluff_mid")
		g.camera.position = at
		for i in 4:
			await process_frame
		var img := root.get_viewport().get_texture().get_image()
		_shot_n += 1
		img.save_jpg("%s/%d_%s_%s.jpg" % [shots, _shot_n, side, k], 0.85)
		print("SIM shot %s" % k)
