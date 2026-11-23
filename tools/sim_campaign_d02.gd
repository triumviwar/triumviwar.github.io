extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 2's "The Exodus" (docs/campaign_d02_build.md) from either side with a simple bot and prints, every 30
## seconds, how it goes: the part, the carts loaded, on the road, taken and out, the guild's men, the commissary's,
## the machine's, Hollweg's health, the clocks. A balance check (the owner's three rules: NO WAITING is measured):
## the guild's player who plays it gets Hollweg onto the last barge at EASY, NORMAL and HARD with most of the families;
## a player who does nothing loses (the families never loaded, or Hollweg left on the jetty); the commissary's player
## who plays it takes Hollweg alive. At the end: the mission's longest stretch with nothing to do (target under 45 s).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_d02.gd -- [active] [side=exodus|commissary]
##        [diff=easy|normal|hard] [bells=quiet|rung] [saved=few|some|many] [gate=pattern|people] [jakob=alive|lost]
##        [furth=strong|thin|fallen] [broken=kept|melted] [lost=0..] [until=<seconds>] [none] [save_at=<s>]
## The earlier missions' flags are written into the progress file for the run (and the player's own progress put back).
var main: Node
var until := 1800.0
var active := false
var side := "exodus"
var diff := "normal"
var c01 := {"bells": "quiet", "saved": "some", "jakob": "alive", "cut": "no", "gate": "pattern"}
var a02 := {"stopwork": "fitted", "furth": "strong", "jakob": "alive"}
var a04 := {"broken": "kept", "lost_to_machine": 0, "stopworks": "found", "jakob": "alive"}
var no_flags := false
var _saved_progress := ""
var _barn_of := {}
var blob := false          # a careless player: every fighter round the first cart (the convoy's others left alone)


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a == "blob":
			blob = true
		elif a == "none":
			no_flags = true
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("side="):
			side = a.substr(5)
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.begins_with("jakob="):
			c01["jakob"] = a.substr(6)
		elif a.begins_with("lost="):
			a04["lost_to_machine"] = int(a.substr(5))
		elif a.contains("=") and not a.begins_with("save_at") and not a.begins_with("load"):
			var kv := a.split("=")
			if c01.has(kv[0]):
				c01[kv[0]] = kv[1]
			elif a02.has(kv[0]):
				a02[kv[0]] = kv[1]
			elif a04.has(kv[0]):
				a04[kv[0]] = kv[1]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["d02_exodus"], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if not no_flags:
		p["done"]["c01_thirteenth"] = {"won_by": "guild", "side": "guild", "flags": c01}
		var a02w := "machine" if String(a02["furth"]) == "fallen" else "guild"
		p["done"]["a02_furth"] = {"won_by": a02w, "side": a02w, "flags": a02}
		p["done"]["a04_visit"] = {"won_by": "visit", "side": "visit", "flags": a04}
		p["done"]["a07_council"] = {"won_by": "crown", "side": "crown", "flags": {"rome": "some", "people": "some", "hollweg": "defied", "lindqvist": "defied"}}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("d02_exodus", "solo", "p1", false, side))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	if g.hud:
		g.hud.countdown = 0.0
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	print("SIM side=%s diff=%s c01=%s a02=%s a04=%s active=%s human=%d" % [side, diff, "none" if no_flags else str(c01), str(a02), str(a04), active, g.human])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
		if active and g.clock >= think:
			think = g.clock + 0.75
			if side == "commissary":
				_play_commissary(g, r)
			else:
				_play_guild(g, r)
		if g.clock >= next:
			next += 30.0
			var part := "1" if not r.fired.has("part2") else ("2" if not r.fired.has("part3") else "3")
			if OS.get_cmdline_user_args().has("debug") and part == "1":
				for i in 7:
					var bu = _barn_of.get(i, null)
					print("  barn %d loaded=%s unit=%s at %s" % [i + 1, r.fired.has("load_%d" % (i + 1)), bu.kind if bu else "-", str(g.cell_of(bu.position)) if bu else "-"])
			var hw: Array = r.tagged("hollweg")
			var carts: Array = r.tagged("convoy").map(func(c): return "%s%s" % [str(g.cell_of(c.position)), "T" if c.team != r.team_index("families") else ""])
			print("SIM t=%4d part=%s loaded=%d/%d carts=%s taken=%d retaken=%d out=%d left=%d guild=%d crown=%d machine=%d hollweg=%s hp=%d riders=%s barge=%s" % [
				g.clock, part, int(r.counters.get("loaded", 0)), int(r.counters.get("carts_n", 0)), str(carts),
				int(r.counters.get("carts_taken", 0)), int(r.counters.get("retaken", 0)), int(r.counters.get("families_out", 0)),
				int(r.counters.get("families_left", 0)), _men(g, r.team_index("guild")).size(), _men(g, r.team_index("crown")).size(),
				_men(g, r.team_index("machine")).size(), str(g.cell_of(hw[0].position)) if not hw.is_empty() else "-",
				int(hw[0].hp) if not hw.is_empty() else 0, _left(g, r, "riders"), _left(g, r, "last_barge")])
	var idle: Dictionary = r.longest_idle()
	print("SIM end t=%d over=%s winner=%s flags=%s counters=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.counters, r.obj])
	print("SIM longest_idle %d s (from %d s)%s" % [int(idle.get("secs", 0.0)), int(idle.get("from", 0.0)), "" if float(idle.get("secs", 0.0)) < 45.0 else "  OVER 45 s"])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _left(g: Game, r: MissionRun, cn: String) -> String:
	return "%ds" % int(float(r.clocks[cn]) - g.clock) if r.clocks.has(cn) else "-"


func _men(g: Game, t: int) -> Array:
	return g.units.filter(func(u): return not u.dead and u.team == t and u.has_attack())


func _nearest_foe(g: Game, p: Vector2, me: int, reach: float) -> Unit:
	var best: Unit = null
	var bd := reach
	for f in g.units:
		if f.dead or f.kind == "horse" or f.spared or f.team == me or g.allied(f.team, me) or not f.has_attack():
			continue
		var d := p.distance_to(f.position)
		if d < bd:
			bd = d
			best = f
	return best


func _go(g: Game, u: Unit, p: Vector2, attack := false) -> void:
	if u.velocity.length() < 5.0 or u.order_point.distance_to(p) > 48.0:
		g.group_move([u], p, attack)


func _busy(u: Unit) -> bool:
	return u.target != null and is_instance_valid(u.target) and not u.target.dead


## The guild's player: one man to each barn with a cart (the nearest free one), Hollweg to his barn for the drawings
## and then to Jakob; on the road every fighter keeps by a cart (its share) and fights what comes within 6 tiles of it,
## Hollweg behind the spring cart; at the landing the Winders build the turret, the fighters hold the bridge's foot
## (shields raised), and at the last call Hollweg walks onto the jetty.
func _play_guild(g: Game, r: MissionRun) -> void:
	var gt := r.team_index("guild")
	var hw: Array = r.tagged("hollweg")
	var men: Array = g.units.filter(func(u): return not u.dead and u.team == gt and u.kind != "missionary")
	var fighters: Array = men.filter(func(u): return u.kind != "winder")
	var winders: Array = men.filter(func(u): return u.kind == "winder")
	if not r.fired.has("part2"):
		# PART 1 (Fürth fallen: everyone at the seed first)
		if r.obj.get("reclaim", "") == "active":
			var seed: Array = r.tagged("seed_works")
			for u in fighters:
				if not seed.is_empty() and not _busy(u):
					u.cmd_attack(seed[0])
		var free: Array = men.duplicate()
		for i in 7:
			var cart: Array = r.tagged("cart_%d" % (i + 1))
			if cart.is_empty() or r.fired.has("load_%d" % (i + 1)):
				continue
			var at := r.area_rect("barn_%d" % (i + 1)).get_center()
			var best: Unit = _barn_of.get(i, null)
			if best == null or not is_instance_valid(best) or best.dead:
				var bd := INF
				for u in free:
					var d: float = u.position.distance_to(at)
					if d < bd:
						bd = d
						best = u
				_barn_of[i] = best
			if best:
				free.erase(best)
				_go(g, best, at)
		if not hw.is_empty():
			var h: Unit = hw[0]
			if r.obj.get("drawings", "") == "active":
				_go(g, h, r.area_rect("barn_1").get_center())
			elif r.obj.get("jakob_bye", "") == "active" and not r.tagged("jakob").is_empty():
				_go(g, h, r.tagged("jakob")[0].position)
		return
	# PART 2 / 3
	var carts: Array = r.tagged("convoy").filter(func(c): return c.team == r.team_index("families") and not c.dead)
	var taken: Array = r.tagged("taken").filter(func(c): return c.team != r.team_index("families") and not c.dead)
	var in3 := r.fired.has("part3")
	var hold := r.area_rect("brook_s").get_center()
	var i := 0
	for u in fighters:
		var anchor: Vector2
		if in3:
			anchor = hold
		elif not taken.is_empty() and i % 3 == 0:
			anchor = taken[0].position
		elif not carts.is_empty():
			anchor = carts[0 if blob else i % carts.size()].position
		else:
			anchor = hold
		i += 1
		if u.kind == "clock_soldier" and ShieldWall.can(u) and not u.shield_up and in3:
			ShieldWall.set_up(u, true)
		var f := _nearest_foe(g, anchor, gt, 6.0 * Defs.TILE)
		if f and not _busy(u):
			u.cmd_attack(f)
		elif f == null and u.position.distance_to(anchor) > 2.5 * Defs.TILE:
			_go(g, u, anchor + Vector2(randf_range(-40, 40), randf_range(-40, 40)))
	var site: Array = r.tagged("turret").filter(func(b): return b is Building and not b.built)
	for w in winders:
		if not site.is_empty():
			if w.order != "build":
				w.cmd_build(site[0])
		elif not carts.is_empty() and w.position.distance_to(carts[0].position) > 3.0 * Defs.TILE:
			_go(g, w, carts[0].position)
		elif carts.is_empty() and w.position.distance_to(hold) > 3.0 * Defs.TILE:
			_go(g, w, hold)
	if not hw.is_empty():
		var h: Unit = hw[0]
		if r.obj.get("aboard", "") == "active":
			_go(g, h, r.area_rect("barges").get_center())
		else:
			var sc: Array = r.tagged("spring_cart")
			var to: Vector2 = sc[0].position + Vector2(-30, -30) if not sc.is_empty() else r.area_rect("landing").get_center()
			if in3:
				to = r.area_rect("barges").get_center() + Vector2(64, 0)
			if h.position.distance_to(to) > 2.0 * Defs.TILE:
				_go(g, h, to)


## The commissary's player: in Part 1 the column rides for the yard; from Part 2 the riders ride for the nearest cart
## (and stand round it), the musketeers and guns go for Hollweg and whatever guards him; once he is down, a man stands by.
func _play_commissary(g: Game, r: MissionRun) -> void:
	var ct := r.team_index("crown")
	var men: Array = g.units.filter(func(u): return not u.dead and u.team == ct and u.has_attack())
	var hw: Array = r.tagged("hollweg")
	if not r.fired.has("part2"):
		for u in men:
			_go(g, u, r.area_rect("yard").get_center(), true)
		return
	var carts: Array = r.tagged("carts").filter(func(c): return not c.dead and c.team != ct and c.team != r.team_index("seized"))
	for u in men:
		if u.kind == "cuirassier" and not carts.is_empty() and u != (r.tagged("rauch")[0] if not r.tagged("rauch").is_empty() else null):
			var best: Unit = null
			for c in carts:
				if best == null or u.position.distance_to(c.position) < u.position.distance_to(best.position):
					best = c
			var f := _nearest_foe(g, u.position, ct, 2.0 * Defs.TILE)
			if f and not _busy(u):
				u.cmd_attack(f)
			elif u.position.distance_to(best.position) > 1.2 * Defs.TILE:
				_go(g, u, best.position)
		elif not hw.is_empty():
			var h: Unit = hw[0]
			if h.hp <= h.max_hp * 0.3:
				_go(g, u, h.position)
			elif not _busy(u):
				var f := _nearest_foe(g, h.position, ct, 5.0 * Defs.TILE)
				if f:
					u.cmd_attack(f)
				else:
					u.cmd_attack(h)
