extends "res://tools/qa_match.gd"
## (wr1000-clockwork-brood, docs/wr1000_clockwork_brood.md) qa_match with a trace every 10 s of each Brood computer's Sires
## (where, rooted, how far from the Mother, researching), its warriors by kind and its food and spoils; and each Clockwork
## computer's army by kind and its Tension. A measuring tool only.
##   godot --headless --fixed-fps 30 --script res://tools/wkb_trace.gd -- <qa_match args> [switches]
## Writes <out>/wkbtrace.txt beside qa_match's files.
var _next_tr := 10.0
var _lines: PackedStringArray = []


func _process(delta: float) -> bool:
	var r := super(delta)
	if g != null and g.clock >= _next_tr:
		_next_tr += 10.0
		for tm in n:
			if g.eliminated[tm]:
				continue
			var kinds := {}
			for u in g.army(tm):
				if not u.dead:
					kinds[u.kind] = int(kinds.get(u.kind, 0)) + 1
			var s := "%d:%02d t%d %s" % [int(g.clock) / 60, int(g.clock) % 60, tm, g.faction_of(tm)]
			if g.faction_of(tm) == "brood":
				var q := BroodNew.queen(g, tm)
				for k in [BroodNew.FATHER, BroodNew.DILO, BroodNew.PTERO]:
					var f := BroodNew.father(g, tm, k)
					if f != null and q != null:
						if not BroodNew.rooted(f) and f.tesla_mode == "packed" and int(g.clock) % 60 < 10:
							s += " [why: %s]" % _nest_why(tm, q, f)
							var a = _ai(tm)
							if a != null and a is AIBroodNew:
								var b = a
								s += " [ai: wave %s def %s target %s threat %s spot %s]" % [f in b._wave, b._def.has(f), f.target, b._nb_threat(q), b._nb_father_spot(q, f, f.kind)]
						s += " | %s rooted %s d %.1f near %s busy %s order %s" % [k, BroodNew.rooted(f), BroodNew.fdist(g, f, q) / Defs.TILE,
							BroodNew.father_near(g, tm, k), BroodResearch.line_busy(g, tm, k), f.order]
				s += " | food %d spoils %d" % [int(g.players[tm]["gold"]), int(g.players[tm].get("res2", 0))]
			else:
				s += " | tension %d" % int(g.tension(tm))
			s += " | " + str(kinds)
			_lines.append(s)
	if r and g != null:
		var f := FileAccess.open(out.path_join("wkbtrace.txt"), FileAccess.WRITE)
		if f:
			f.store_string("\n".join(_lines) + "\n")
	return r


## Why a Sire finds no nest: the place_problem answers round her (frac x 24 angles), counted.
func _nest_why(tm: int, q: Unit, f: Unit) -> String:
	var reach := float(Defs.NB["father_r"]) * Defs.TILE
	var qk := BroodRoot.feet_k(g, tm, q)
	var c := {}
	for frac in [0.75, 0.6, 0.9, 0.5, 1.0]:
		for i in 24:
			var pr: Vector2 = qk + Vector2.from_angle(TAU * i / 24.0) * reach * frac
			var p: Vector2 = BroodRoot.sym_snap(g, tm, f.kind, pr)
			var why := BroodRoot.place_problem(g, tm, f.kind, p, f, true)
			if why == "":
				why = "OK"
			c[why] = int(c.get(why, 0)) + 1
	return str(c)
