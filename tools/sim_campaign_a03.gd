extends SceneTree
const SimSave = preload("res://tools/sim_save_hook.gd")
## Plays Act 1's "The Lost Plateau" (docs/campaign_a03_build.md) from either side with a simple bot and prints, every
## 30 seconds, how it goes: the part, the marks taken, the party left (and down), the nest's hunters, the Sire, the
## clocks. A balance check: the party's player who plays it wins on NORMAL in a sensible time; the nest's player who
## plays it kills Valadares or breaks the party; a player who does nothing loses (the party, at the rains) or lets the
## party get down (the nest).
##   godot --headless --fixed-fps 30 --script res://tools/sim_campaign_a03.gd -- [active] [side=party|nest]
##        [saved=few|some|many] [eggs=left|taken] [turtle=early|late] [rival=standing|driven] [teles=told|quiet]
##        [diff=easy|normal|hard] [map=drawn|withheld] [route=stair|split] [until=<seconds>] [none]
## The prologue's flags are written into the progress file for the run (and the player's own progress put back after).
var main: Node
var until := 1500.0
var active := false
var side := "party"
var diff := "normal"
var answer := "drawn"
var route := "stair"
var b01 := {"teles": "quiet", "clutch": "saved", "eggs": "left", "saved": "some", "pieter": "lost", "turtle": "late", "rival": "standing"}
var no_flags := false
var _saved_progress := ""
var _leg := 0
var _plan: Array = []
var _wait := 0.0
var _hunt_from := -1.0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "active":
			active = true
		elif a == "none":
			no_flags = true
		elif a.begins_with("until="):
			until = float(a.substr(6))
		elif a.begins_with("side="):
			side = a.substr(5)
		elif a.begins_with("diff="):
			diff = a.substr(5)
		elif a.begins_with("map="):
			answer = a.substr(4)
		elif a.begins_with("route="):
			route = a.substr(6)
		elif a.contains("="):
			var kv := a.split("=")
			if b01.has(kv[0]):
				b01[kv[0]] = kv[1]
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	var f := FileAccess.open(Campaign.PROGRESS, FileAccess.READ)
	if f:
		_saved_progress = f.get_as_text()
	var p := {"reached": ["a03_plateau"], "done": {"p01_leaf": {"won_by": "crown"}}, "difficulty": diff}
	if not no_flags:
		p["done"]["b01_specimen"] = {"won_by": "sire", "side": "sire", "flags": b01}
	Campaign.save_progress(p)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	main.start(Campaign.make_cfg("a03_plateau", "solo", "p1", false, side))
	await process_frame
	await process_frame
	paused = false
	var g: Game = main.game
	var r: MissionRun = g.mission
	var next := 0.0
	var think := 1.0
	var pt := r.team_index("party")
	var nt := r.team_index("nest")
	print("SIM side=%s diff=%s b01=%s active=%s map=%s route=%s human=%d" % [side, diff, "none" if no_flags else str(b01), active, answer, route, g.human])
	while g.clock < until and not g.over:
		await physics_frame
		if SimSave.due(g):
			g = await SimSave.reload(self, main)      # (save_at=: player-comforts)
			r = g.mission
		if active and g.clock >= think:
			think = g.clock + 0.75
			if side == "nest":
				_play_nest(g, r, pt, nt)
			else:
				_play_party(g, r, pt, nt)
		if g.clock >= next:
			next += 30.0
			var part := "1" if not r.fired.has("on_top") else ("2" if not r.fired.has("part3") else "3")
			var v: Array = r.tagged("valadares")
			var sire: Array = r.tagged("sire")
			print("SIM t=%4d part=%s marks=%d party=%d down=%d nest_hunters=%d patrols=%d red=%d sire=%s valadares=%s hp=%d asleep=%s rains=%s canoe=%s" % [
				g.clock, part, int(r.counters.get("marks", 0)), _people(g, pt).size(), int(r.counters.get("down", 0)),
				_hunters(g, nt).size(), r.count({"team": "patrol"}), r.count({"team": "rival"}),
				str(g.cell_of(sire[0].position)) if not sire.is_empty() else "-",
				str(g.cell_of(v[0].position)) if not v.is_empty() else "DEAD", int(v[0].hp) if not v.is_empty() else 0,
				r.cond({"asleep": "nest"}), _left(g, r, "rains"), _left(g, r, "canoe")])
	print("SIM end t=%d over=%s winner=%s flags=%s counters=%s objectives=%s" % [g.clock, g.over, r.winner_side, r.flags, r.counters, r.obj])
	if _saved_progress != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_saved_progress)
	quit()


func _left(g: Game, r: MissionRun, cn: String) -> String:
	return "%ds" % int(float(r.clocks[cn]) - g.clock) if r.clocks.has(cn) else "-"


func _people(g: Game, t: int) -> Array:
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind in ["musketeer", "labourer", "dismounted"])


func _hunters(g: Game, t: int) -> Array:
	return g.units.filter(func(u): return not u.dead and u.team == t and u.kind in ["raptor", "spitter", "tyrannosaur", "dilophosaurus"])


func _nearest_foe(g: Game, u: Unit, sides: Array, reach: float, r: MissionRun) -> Unit:
	var best: Unit = null
	var bd := reach
	for f in g.units:
		if f.dead or f.kind == "horse" or f.spared or f.has_meta("mission_asleep") or not sides.has(r.side_of_team(f.team)):
			continue
		var d := u.position.distance_to(f.position)
		if d < bd:
			bd = d
			best = f
	return best


## The party's player: up the stair (or the split), the four marks with the men round Valadares (fighting what comes
## near him), the map answered, then down the split to the canoe with everyone; Benedito waits at the landing.
func _play_party(g: Game, r: MissionRun, pt: int, nt: int) -> void:
	var v: Array = r.tagged("valadares")
	if v.is_empty():
		return
	var val: Unit = v[0]
	if not r.choice_open.is_empty() and String(r.choice_open.get("id", "")) == "map":
		r.choose("map", answer)
	var escort: Array = _people(g, pt).filter(func(u): return u != val and u.kind != "labourer")
	var others: Array = _people(g, pt).filter(func(u): return u != val and u.kind == "labourer")
	if _plan.is_empty():
		var up := ["stair_foot", "stair_top"] if route == "stair" else ["trail_e", "split_foot", "split_top", "split_in"]
		var marks := ["cairn", "source", "rim", "lookout"] if route == "stair" else ["lookout", "rim", "source", "cairn"]
		_plan = up + marks
		_leg = 0
	if r.fired.has("part3") and _hunt_from < 0.0 and r.flags.has("sire_way"):
		_hunt_from = g.clock
		# (down the way the Sire did NOT come up: across the top)
		if String(r.flags.get("sire_way", "stair")) == "stair":
			_plan = ["mid_top", "split_in", "split_top", "split_foot", "trail_e", "landing"]
		else:
			_plan = ["mid_top", "cairn", "stair_top", "stair_foot", "trail_w", "landing"]
		_leg = 0
		print("SIM part 3 at %d: the Sire up the %s, down by %s (Valadares at %s, sire_w at %s, sire at %s)" % [g.clock, r.flags.get("sire_way", "?"), _plan[1],
			g.cell_of(val.position), r.fired.get("sire_w", -1), g.cell_of(r.tagged("sire")[0].position) if not r.tagged("sire").is_empty() else "-"])
	var goal := r.area_rect(String(_plan[_leg]))
	var here := goal.grow(-8).has_point(val.position)
	if here:
		var wp := String(_plan[_leg])
		if wp in ["cairn", "source", "rim", "lookout"] and not r.fired.has("mark_" + wp):
			pass        # (he stays until the mark is taken)
		elif _leg + 1 < _plan.size():
			_leg += 1
			goal = r.area_rect(String(_plan[_leg]))
			here = false
	# the hero walks; the escort keeps round him and fights what comes near him
	if not here and (val.velocity.length() < 5.0 or val.order_point.distance_to(goal.get_center()) > 40.0):
		g.group_move([val], goal.get_center(), false)
	for u in escort:
		var f := _nearest_foe(g, u, ["nest", "rival"], 6.0 * Defs.TILE, r)
		if f and (u.target == null or not is_instance_valid(u.target) or u.target.dead):
			u.cmd_attack(f)
		elif f == null and u.position.distance_to(val.position) > 3.0 * Defs.TILE:
			g.group_move([u], val.position + Vector2(randf_range(-40, 40), randf_range(-40, 40)), false)
	for u in others:
		if r.tagged("benedito").has(u):
			if r.fired.has("part3") and not r.area_rect("landing").has_point(u.position) and u.velocity.length() < 5.0:
				g.group_move([u], r.area_rect("landing").get_center(), false)
			continue
		if u.position.distance_to(val.position) > 2.5 * Defs.TILE:
			g.group_move([u], val.position, false)
	# at the landing: everyone in, then Valadares
	if r.fired.has("part3") and r.area_rect("landing").has_point(val.position):
		for u in escort + others:
			if u.velocity.length() < 5.0:
				g.group_move([u], r.area_rect("landing").get_center(), false)


## The nest's player: nothing to do while it sleeps (the grubs gather by themselves); from Part 3 every hunter and the
## Sire at Valadares (the nearest of the party on the way).
func _play_nest(g: Game, r: MissionRun, pt: int, nt: int) -> void:
	if not r.fired.has("part3"):
		return
	var v: Array = r.tagged("valadares")
	for u in _hunters(g, nt):
		if u.has_meta("mission_asleep"):
			continue
		var f := _nearest_foe(g, u, ["party"], 5.0 * Defs.TILE, r)
		if f == null and not v.is_empty():
			f = v[0]
		if f and (u.target == null or not is_instance_valid(u.target) or u.target.dead or u.target != f):
			if u.target == null or not is_instance_valid(u.target) or u.target.dead or u.target == v[0] or f.position.distance_to(u.position) < 3.0 * Defs.TILE:
				u.cmd_attack(f)
