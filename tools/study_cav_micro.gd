extends SceneTree
## crown-coach-cavalry's measure (docs/crown-coach-cavalry.md): a computer-against-computer match, headless, and what the
## Crown's Horsemen did in it. A measuring tool only: it starts a normal match and reads it; it changes no rule.
##   godot --headless --fixed-fps 30 --script res://tools/study_cav_micro.gd -- a:crown b:brood map:greenhold seed:1 \
##       end:900 out:/abs/file.json [diff:hard] [pa:optimal pb:optimal]      (add cavmicro:off for the old riders)
## Writes one JSON object: per Crown side its Horsemen's sabre blows (plain, charged), pistol shots, sabre damage, riders
## lost (killed or unhorsed), riders made, the seconds riders stood still in a melee, the hit points they lost, the
## micro's counts, when the Cavalry Charge was drilled; and the result.
var main: Node
var g: Game
var fa := "crown"
var fb := "brood"
var map := "greenhold"
var seed_ := 1
var end_t := 900.0
var out := "/tmp/cav.json"
var diff := "hard"
var pa := "optimal"
var pb := "optimal"
var t := 0.0
var _next := 0.0
const LOOK := 0.25
var seen := [{}, {}]            # per team: instance id -> last hp (a Horseman in the saddle)
var made := [0, 0]
var lost := [0, 0]
var stood := [0.0, 0.0]         # seconds a rider stood (under 30% of its speed) with an enemy fighter at sabre's reach
var hp_lost := [0.0, 0.0]
var charge_at := [-1.0, -1.0]


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split(":", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"a": fa = kv[1]
			"b": fb = kv[1]
			"map": map = kv[1]
			"seed": seed_ = int(kv[1])
			"end": end_t = float(kv[1])
			"out": out = kv[1]
			"diff": diff = kv[1]
			"pa": pa = kv[1]
			"pb": pb = kv[1]
	Settings.load_all()
	Settings.device = "pc"
	Settings.apply()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	Engine.max_fps = 0


func _process(delta: float) -> bool:
	t += delta
	if t > 0.2 and main.game == null:
		seed(seed_)
		main.start({"map": map, "seed": seed_, "slots": [
			{"who": diff, "faction": fa, "colour": 0, "side": 0, "strategy": pa},
			{"who": diff, "faction": fb, "colour": 1, "side": 1, "strategy": pb}]})
		return false
	if main.game == null:
		return false
	g = main.game
	g.path_budget_us = 1 << 40
	if g.hud:
		g.hud.visible = false
	if g.spectator and g.spectator.process_mode != Node.PROCESS_MODE_DISABLED:
		g.spectator.process_mode = Node.PROCESS_MODE_DISABLED
	if g.controls and g.controls.process_mode != Node.PROCESS_MODE_DISABLED:
		g.controls.process_mode = Node.PROCESS_MODE_DISABLED
	if g.clock >= _next:
		_next = g.clock + LOOK
		_look()
	if g.over or g.clock >= end_t:
		_finish()
		return true
	return false


func _look() -> void:
	for tm in 2:
		if g.faction_of(tm) != "crown":
			continue
		if charge_at[tm] < 0.0 and g.has_tech(tm, "charge"):
			charge_at[tm] = g.clock
		var now := {}
		for u in g.units:
			if u.team != tm or u.dead or u.kind != "cuirassier" or u.aboard != null:
				continue
			var id := u.get_instance_id()
			now[id] = u.hp
			if not seen[tm].has(id):
				made[tm] += 1
			else:
				hp_lost[tm] += maxf(0.0, float(seen[tm][id]) - u.hp)
			if u.velocity.length() < u.speed * 0.3:
				for o in g.units_near(u.position, 60.0):
					if not o.dead and g.hostile(o.team, tm) and Game.fights_back(o) and not o.is_air() \
							and o.edge_distance(u.position) - u.radius <= 30.0:
						stood[tm] += LOOK
						break
		for id in seen[tm]:
			if not now.has(id):
				lost[tm] += 1
		seen[tm] = now


func _finish() -> void:
	var res := {"a": fa, "b": fb, "map": map, "seed": seed_, "end": g.clock, "over": g.over, "off": OS.get_cmdline_user_args().has("cavmicro:off"),
		"winner": -1, "sides": []}
	for tm in 2:
		if not g.eliminated[tm] and g.over:
			res["winner"] = tm
	for tm in 2:
		var st: Dictionary = g.stats[tm] if tm < g.stats.size() else {}
		var side := {"faction": g.faction_of(tm), "blows": st.get("cav_blows", 0.0), "charged": st.get("cav_charged", 0.0),
			"pistol": st.get("cav_pistol", 0.0), "dmg": st.get("cav_dmg", 0.0), "made": made[tm], "lost": lost[tm],
			"stood": stood[tm], "hp_lost": hp_lost[tm], "charge_at": charge_at[tm], "alive": seen[tm].size()}
		for a in g.ais:
			if a.team == tm and a is AICrown and a.cav != null:
				side["micro"] = a.cav.n
		res["sides"].append(side)
	var f := FileAccess.open(out, FileAccess.WRITE)
	f.store_string(JSON.stringify(res))
	f.close()
	print(JSON.stringify(res))
