extends "res://tools/qa_match.gd"
## THE CROWN'S ARMY AND ITS TIMING (crown-coach-army, docs/crown-coach-army.md): a qa_match.gd game (same arguments) that
## also looks every second at each Crown computer's production and every 15 s at both armies, and writes <out>/army.json:
##   per Crown team: seconds each built Barracks / Foundry stood idle (no queue) by minute, seconds supply-blocked, seconds
##   a Barracks stood idle with a Musketeer's gold but not its powder, the gold and powder banks; per team the army's value
##   every 15 s. A measuring tool only: it changes no rule.
var _sec := 1.0
var army_track := {}       # team -> [[t, army value], ...]
var prod := {}             # team -> {"brk_idle": [per minute], "fdy_idle": [...], "sup_block": [...], "pw_wait": [...], "gold": [...], "pw": [...]}
var _next15 := 15.0


func _process(delta: float) -> bool:
	var r := super(delta)
	if g == null or r:
		return r
	if g.clock >= _sec:
		_sec += 1.0
		_per_second()
	if g.clock >= _next15:
		_next15 += 15.0
		for tm in n:
			if not army_track.has(tm):
				army_track[tm] = []
			(army_track[tm] as Array).append([int(g.clock), g.army_value(tm)])
	return r


func _per_second() -> void:
	var m := int(g.clock / 60.0)
	for a in g.ais:
		if g.faction_of(a.team) != "crown":
			continue
		if not prod.has(a.team):
			prod[a.team] = {"brk_idle": [], "fdy_idle": [], "sup_block": [], "pw_wait": [], "gold": [], "pw": [], "brk": []}
		var p: Dictionary = prod[a.team]
		for k in p:
			while (p[k] as Array).size() <= m:
				(p[k] as Array).append(0)
		var bi := 0
		var nb := 0
		var fi := 0
		for b in g.buildings:
			if b.team != a.team or b.dead or not b.built:
				continue
			if b.kind == "barracks":
				nb += 1
				if b.queue.is_empty():
					bi += 1
			elif b.kind == "foundry" and b.queue.is_empty():
				fi += 1
		p["brk_idle"][m] += bi
		p["fdy_idle"][m] += fi
		p["brk"][m] = nb
		var cap := int(g.players[a.team]["cap"])
		if g.supply_used(a.team) >= cap and cap < 200:
			p["sup_block"][m] += 1
		if bi > 0 and a._gold() >= 60 and a._res2() < 10.0:
			p["pw_wait"][m] += 1
		if int(g.clock) % 60 == 59:
			p["gold"][m] = a._gold()
			p["pw"][m] = int(a._res2())


func _finish() -> void:
	super()
	var res := {"army": army_track, "prod": prod, "map": map, "seed": seed_}
	var f := FileAccess.open(out.path_join("army.json"), FileAccess.WRITE)
	f.store_string(JSON.stringify(res))
	f.close()
