extends "res://tools/qa_match.gd"
## (crown-coach-economy, docs/crown-coach-economy.md) qa_match with a second-by-second trace of every Crown computer's
## economy: gold, powder, the halls' queues, labourers and what they do (Farm, Mill, building, scouting, other), the Farm
## and Mill posts, supply, the opening's step and the gold it keeps. A measuring tool only.
##   godot --headless --fixed-fps 30 --script res://tools/crown_econ_trace.gd -- <qa_match args> [switches]
## Writes <out>/trace.json ({team: [[clock, gold, powder, halls, hall_idle, queued, labs, farm, mill, build, scout,
## other, farm_posts, mill_posts, supply, cap, step, reserve], ...]}) beside qa_match's files.
var _trace := {}
var _next_tr := 1.0


func _process(delta: float) -> bool:
	var r := super(delta)
	if g != null and g.clock >= _next_tr:
		_next_tr += 1.0
		for tm in n:
			if g.faction_of(tm) == "crown" and not g.eliminated[tm]:
				_trace_one(tm)
	return r


func _trace_one(tm: int) -> void:
	var a = _ai(tm)
	var halls := 0
	var idle := 0
	var queued := 0
	for h in g.halls_of(tm):
		if h.built:
			halls += 1
			if h.queue.is_empty():
				idle += 1
			queued += h.queue.count("labourer")
	var fp := 0
	var mp := 0
	var farm := 0
	var mill := 0
	for b in g.buildings:
		if b.team != tm or b.dead or not b.built:
			continue
		if b.kind == "farm" and b.soil_left() > 0.0:
			fp += b.crew_max()
			farm += b.working_crew()
		elif b.kind == "powder_mill":
			mp += b.crew_max()
			mill += b.working_crew()
	var build := 0
	var sc := 0
	var labs := g.workers(tm)
	for w in labs:
		if a != null and a.scout != null and a.scout.is_scout(w):
			sc += 1
		elif w.order == "build" or w.order == "repair":
			build += 1
	var step := ""
	if a != null and "bo_done" in a and not a.bo_done and a.bo_i < a._bo_plan.size():
		step = a._st_text(a._bo_plan[a.bo_i])
	var row := [int(g.clock), int(g.players[tm]["gold"]), int(g.players[tm].get("res2", 0)), halls, idle, queued, labs.size(),
		farm, mill, build, sc, labs.size() - farm - mill - build - sc, fp, mp, g.supply_used(tm), int(g.players[tm]["cap"]),
		step, int(a.bo_reserve) if a != null and "bo_reserve" in a else 0,
		_flags(a)]
	if not _trace.has(tm):
		_trace[tm] = []
	_trace[tm].append(row)


## what holds the labourers: p = free Farm posts first (opening), s = soldiers first, d = defending, t = a threat, r = raided,
## a = the army due (after the opening), h = the hall's gold kept
func _flags(a) -> String:
	if a == null or not a.has_method("_bo_posts_first"):
		return ""
	var f := ""
	if a._bo_posts_first(): f += "p"
	if a._soldiers_first(): f += "s"
	if a._defending(): f += "d"
	if a._threat() != Vector2.INF: f += "t"
	if a._raided(): f += "r"
	if a.bo_done and a._army_due(): f += "a"
	if a._hall_reserve: f += "h"
	return f


func _finish() -> void:
	var f := FileAccess.open(out.path_join("trace.json"), FileAccess.WRITE)
	f.store_string(JSON.stringify(_trace))
	f.close()
	super()
