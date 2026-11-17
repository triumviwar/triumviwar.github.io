extends "res://tools/crown_econ_trace.gd"
## (crown-brood-army, docs/crown_brood_army.md) crown_econ_trace with the Crown computer's ARMY against the Brood every 5 s,
## in <out>/army.json ({team: [[clock, gold, army, home_line, line_want, brood_army_true, brood_seen, barracks, barracks_busy,
## foundries, foundry_busy, guns, muskets, riders, palisade, halls, labs, supply, cap, read, plan, flags], ...]}).
## Flags: S = the line short, F = the floor wants more (crown-brood-army), K = the line's gold kept.
## A measuring tool only.
var _army := {}
var _next_ar := 5.0
var _seen_ids := {}
var _spend := {}       # team -> {"b:<kind>"/"u:<kind>": [n, gold, gold before 6:30 (390 s)]}


func _process(delta: float) -> bool:
	var r := super(delta)
	if g != null and g.clock >= _next_ar:
		_next_ar += 5.0
		for tm in n:
			if g.faction_of(tm) == "crown" and not g.eliminated[tm]:
				_army_one(tm)
	return r


func _army_one(tm: int) -> void:
	var a = _ai(tm)
	var foe := -1
	for t2 in n:
		if t2 != tm and g.faction_of(t2) == "brood":
			foe = t2
	var bk := 0
	var bkb := 0
	var fd := 0
	var fdb := 0
	var pal := 0
	for b in g.buildings:
		if b.team != tm or b.dead or not b.built:
			continue
		if b.kind == "barracks":
			bk += 1
			if not (b.queue as Array).is_empty():
				bkb += 1
		elif b.kind == "foundry":
			fd += 1
			if not (b.queue as Array).is_empty():
				fdb += 1
		elif b.kind == "wall" or b.kind == "gate":
			pal += 1
	var guns := 0
	var musk := 0
	var riders := 0
	for u in g.army(tm):
		if u.dead:
			continue
		if u.kind == "cannon" or u.kind == "mortar":
			guns += 1
		elif Defs.MUSKETS.has(u.kind):
			musk += 1
		elif u.kind == "cuirassier" or u.kind == "dragoon":
			riders += 1
	var line := 0.0
	var want := 0.0
	var seen := 0.0
	var fl := ""
	var read := ""
	if a != null and a.has_method("vb") and a.vb() != null:
		line = a.vbr.home_line()
		want = a.vbr.line_want()
		if a.vbr.line_short():
			fl += "S"
		if a.vbr.has_method("floor_want") and a.vbr.floor_want() > 0.0:
			fl += "F"
	if a != null and "ch" in a and a.ch != null:
		seen = a.ch.foe_known()
	if a != null and "scout" in a and a.scout != null:
		read = String(a.scout.verdict)
	var row := [int(g.clock), int(g.players[tm]["gold"]), g.army_value(tm), int(line), int(want),
		g.army_value(foe) if foe >= 0 else 0, int(seen), bk, bkb, fd, fdb, guns, musk, riders, pal, g.halls_of(tm).size(),
		g.workers(tm).size(), g.supply_used(tm), int(g.players[tm]["cap"]), read,
		String(a.strategy) if a != null and "strategy" in a else "", fl]
	if not _army.has(tm):
		_army[tm] = []
	_army[tm].append(row)
	if not _spend.has(tm):
		_spend[tm] = {}
	for b in g.buildings:
		if b.team == tm and not _seen_ids.has(b.get_instance_id()):
			_seen_ids[b.get_instance_id()] = true
			_add(tm, "b:" + b.kind, int(Defs.BUILDINGS[b.kind].get("cost", 0)))
	for u in g.units:
		if u.team == tm and not _seen_ids.has(u.get_instance_id()):
			_seen_ids[u.get_instance_id()] = true
			if g.clock > 6.0:
				_add(tm, "u:" + u.kind, int(Defs.UNITS[u.kind].get("cost", 0)) if Defs.UNITS.has(u.kind) else 0)


func _add(tm: int, k: String, c: int) -> void:
	var e: Array = _spend[tm].get(k, [0, 0, 0])
	e[0] += 1
	e[1] += c
	if g.clock <= 390.0:
		e[2] += c
	_spend[tm][k] = e


func _finish() -> void:
	var f := FileAccess.open(out.path_join("army.json"), FileAccess.WRITE)
	f.store_string(JSON.stringify({"rows": _army, "spend": _spend}))
	f.close()
	super()
