extends "res://tools/film_coach.gd"
## FILM THE SCOUT HUNTS (scout-deny, docs/scout_deny.md): tools/film_coach.gd's film (maps every 15 s, the coach's lines),
## plus, with shots:1 under xvfb, camera pictures of every hunt after an enemy scout: the scout and its hunters when the
## hunt starts and every HUNT_GAP s while it lasts (hunt_<team>_MMSS.png, the hunting side's team), and the spot where it
## ended (huntend_<team>_MMSS.png). A measuring tool: it changes no rule.
##   xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --fixed-fps 30 --script res://tools/film_scout_deny.gd -- \
##       map:greenhold seed:1100 end:420 out:/abs/dir slots:crown/optimal/0,brood/optimal/1 shots:1 army_every:600
const HUNT_GAP := 3.0
const HUNT_MAX := 4             # pictures of one hunt at most
var _hunt_seen := {}            # prey instance id -> [shots taken, last clock, last position, team]
var _next_hunt := 0.0


func _process(delta: float) -> bool:
	var done: bool = super._process(delta)
	if g == null or done or not _shots or _shooting:
		return done
	if g.clock < _next_hunt:
		return done
	_next_hunt = g.clock + 0.5
	var live := {}
	for a in g.ais:
		if a.sd == null:
			continue
		for o in a.sd.hunts.keys():
			if not is_instance_valid(o) or o.dead:
				continue
			var id: int = o.get_instance_id()
			live[id] = true
			var e: Array = _hunt_seen.get(id, [0, -99.0, o.position, a.team])
			e[2] = o.position
			if int(e[0]) < HUNT_MAX and g.clock - float(e[1]) >= HUNT_GAP:
				e[0] = int(e[0]) + 1
				e[1] = g.clock
				_pending.append(["hunt_%d_%s.png" % [a.team, _mm(g.clock)], o.position, 1.5])
			_hunt_seen[id] = e
	for id in _hunt_seen.keys():
		if not live.has(id):
			var e: Array = _hunt_seen[id]
			_pending.append(["huntend_%d_%s.png" % [int(e[3]), _mm(g.clock)], e[2], 1.5])
			_hunt_seen.erase(id)
	return done
