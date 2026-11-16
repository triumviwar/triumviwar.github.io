extends "res://tools/qa_match.gd"
## (clockwork-v-brood-coach-2, docs/clockwork_v_brood_coach_2.md) qa_match with a trace of every Clockwork computer's
## spending every 5 s: cogs, what the written build puts by (_hold), Winders and their goal, the build's next step, the rush
## reaction (on, soldiers wanted), the army's value and kinds, the Clocktowers' and Works' queues, the push's phase.
## A measuring tool only.
##   godot --headless --fixed-fps 30 --script res://tools/cw_trace.gd -- <qa_match args> [switches]
## Writes <out>/cwtrace.txt beside qa_match's files.
var _next_tr := 5.0
var _lines: PackedStringArray = []


var _dl := 0


func _process(delta: float) -> bool:
	var r := super(delta)
	# every Clockwork Winder that died since the last frame: how far from its nearest building and from its nearest armed
	# unit, and what it was doing
	if g != null and g.death_log != null:
		while _dl < g.death_log.size():
			var d: Array = g.death_log[_dl]
			_dl += 1
			if d[1] != "winder" or d.size() < 8:
				continue
			var p := Vector2(float(d[5]) + 0.5, float(d[6]) + 0.5) * float(Game.T)
			var nb := INF
			for b in g.buildings:
				if b.team == int(d[2]) and not b.dead:
					nb = minf(nb, b.center().distance_to(p))
			var na := INF
			for u in g.army(int(d[2])):
				if not u.dead and float(u.d.get("damage", 0)) > 0.0:
					na = minf(na, u.position.distance_to(p))
			_lines.append("WINDER DIED %s t%d %s by %s: building %d px, armed unit %d px" % ["%d:%02d" % [int(d[0]) / 60, int(d[0]) % 60],
				int(d[2]), String(d[7]), String(d[3]), int(nb) if nb < INF else -1, int(na) if na < INF else -1])
	if g != null and g.clock >= _next_tr:
		_next_tr += 5.0
		for tm in n:
			if g.faction_of(tm) == "clockwork" and not g.eliminated[tm]:
				_trace_one(tm)
	if r and g != null:
		var f := FileAccess.open(out.path_join("cwtrace.txt"), FileAccess.WRITE)
		if f:
			f.store_string("\n".join(_lines) + "\n")
	return r


func _trace_one(tm: int) -> void:
	var a = _ai(tm)
	if a == null:
		return
	var kinds := {}
	var val := 0
	for u in g.army(tm):
		if u.dead or u.off_field:
			continue
		kinds[u.kind] = int(kinds.get(u.kind, 0)) + 1
		val += int(u.d.get("cost", 0))
	var hq := []
	for h in a._halls():
		hq.append(("" if h.built else "~") + ",".join(h.queue))
	var wq := []
	for w in a._mine(a._works()):
		wq.append(("" if w.built else "~") + ",".join(w.queue))
	var step := ""
	if a.bo_on:
		for i in a.steps.size():
			if not a.done[i]:
				step = String(a.steps[i])
				break
	var rush := ""
	if a.bte != null and a.bte.rush:
		rush = "rush n%d" % a.bte.rush_n
	var push := ""
	if "army_g" in a and a.army_g != null and "push" in a and a.push != null and "phase" in a.push:
		push = String(a.push.phase)
	var swarm := ""
	if a.swarm_ai != null:
		swarm = "swarm%s n%d v%d out%s" % ["ON" if a.swarm_ai.on() else "", a.swarm_ai._n, int(a.swarm_ai._v),
			"!" if a.swarm_ai.outmatched() else ""]
	_lines.append("%s t%d cogs %d hold %d ten %d | W %d goal %d | bo %s step [%s] %s | %s | army %d %s | halls %s | works %s | sup %d/%d | plan %s %s" % [
		"%d:%02d" % [int(g.clock) / 60, int(g.clock) % 60], tm, int(g.players[tm]["gold"]), int(a._hold),
		int(g.tension(tm)), g.workers(tm).size(), int(a.worker_goal), "on" if a.bo_on else "off", step, rush, swarm,
		val, JSON.stringify(kinds), str(hq), str(wq), g.supply_used(tm), int(g.players[tm]["cap"]), String(a.strategy), push])
