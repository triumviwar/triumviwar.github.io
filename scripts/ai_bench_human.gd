class_name BenchHuman
extends RefCounted
## THE HUMAN-LIKE BENCHMARK PLAYER (ai-opponent-review, docs/ai_opponent_review.md). A measuring tool, never in a real
## match: tools/qa_match.gd puts it on a slot ("crown/balanced/0/average") to see where each computer difficulty sits
## against an ordinary player.
##
## It plays a STANDARD BUILD (the faction's Balanced plan, with the Hard computer's build knowledge) through the computer's
## own decisions, but with a person's limits:
##  - REACTION: it looks at the game only every `period` seconds (0.6-1.5 s, with jitter), not every 0.4-0.7 s;
##  - ATTENTION: each look it manages ONE place: the economy and production at home ("macro") OR its army ("army"). It
##    looks at its army now and then, and always once it has NOTICED an attack on its base, which takes `notice` seconds;
##  - FORGETS: some looks at home it forgets to make workers (`forget`) or to queue soldiers (`lapse`); its workers stop
##    at `cap` (a novice never saturates three bases);
##  - NO PERFECT MICRO: no focus fire, kiting or pulling back hurt units (the Hard computer's _micro), no rider hit-and-
##    run; the novice uses no abilities at all; only the good player hunts a scout in its base.
## It attacks when its plan says it has a decent army (the Balanced plan's waves).
## What it is NOT: a person. It shares the computer's build logic and so its blind spots (it never cheeses the computer,
## never baits it, never finds the computer's habits). It is a yardstick of "a player of this strength", not the owner.

const STRENGTHS := {
	# period: seconds between looks; army: chance a calm look goes to the army; notice: seconds before an attack on the
	# base is noticed; forget: a look at home without workers; lapse: a look at home without soldiers; cap: most workers
	"novice": {"period": 1.5, "army": 0.25, "notice": 6.0, "forget": 0.35, "lapse": 0.35, "cap": 24, "abil": false, "deny": false},
	"average": {"period": 1.0, "army": 0.30, "notice": 3.0, "forget": 0.15, "lapse": 0.15, "cap": 36, "abil": true, "deny": false},
	"good": {"period": 0.6, "army": 0.35, "notice": 1.2, "forget": 0.05, "lapse": 0.05, "cap": 48, "abil": true, "deny": true},
}

var strength := "average"
var p: Dictionary
var rng := RandomNumberGenerator.new()
var _t := 0.0
var _chk := 0.0
var _seen_at := -1.0           # when the current attack on the base was first there (-1 = none)
var looks := {"macro": 0, "army": 0, "forgot": 0, "lapsed": 0}


static func valid(s: String) -> bool:
	return STRENGTHS.has(s)


func _init(s: String, seed_: int) -> void:
	strength = s
	p = STRENGTHS[s]
	rng.seed = seed_


## Every physics tick instead of the computer's own _tick_ai.
func tick(ai: AI, delta: float) -> void:
	var g := ai.game
	if g == null or g.over:
		return
	_chk -= delta
	if _chk <= 0.0:
		_chk = 0.5
		if _attack_at(ai):
			if _seen_at < 0.0:
				_seen_at = g.clock
		else:
			_seen_at = -1.0
	_t -= delta
	if _t > 0.0:
		return
	_t = float(p["period"]) * rng.randf_range(0.7, 1.3)
	ai._think_dt = _t
	var noticed := _seen_at >= 0.0 and g.clock - _seen_at >= float(p["notice"])
	var army_look := noticed or rng.randf() < float(p["army"])
	ai.bench_flags = {
		"no_workers": rng.randf() < float(p["forget"]),
		"no_produce": rng.randf() < float(p["lapse"]),
		"cap": int(p["cap"]), "abil": bool(p["abil"]), "deny": bool(p["deny"]),
	}
	if army_look:
		looks["army"] += 1
	else:
		looks["macro"] += 1
		if ai.bench_flags["no_workers"]:
			looks["forgot"] += 1
		if ai.bench_flags["no_produce"]:
			looks["lapsed"] += 1
	if ai.opt != null:
		ai.opt.tick()
	if bool(p["deny"]):
		ai.sdn().tick()
	ai.bench_look(army_look)


## An enemy army (not a lone worker) at one of its buildings or rooted creatures: what makes a player look home.
func _attack_at(ai: AI) -> bool:
	var g := ai.game
	var v := 0.0
	for u in g.units:
		if u.dead or u.off_field or not g.hostile(u.team, ai.team) or u.is_worker() or not u.has_attack():
			continue
		if not g.is_visible_to(ai.team, u.position):
			continue
		for b in g.units_near(u.position, 300.0):
			if b.team == ai.team and not b.dead and (b.is_worker() or b.kind == BroodNew.QUEEN or BroodNew.rooted(b)):
				v += float(Game.unit_value(u))
				break
		if v >= 100.0:
			return true
	for b in g.buildings:
		if b.team == ai.team and not b.dead and b.built and b.last_hit_team >= 0 and g.hostile(b.last_hit_team, ai.team) and b.hp < b.max_hp:
			for u in g.units_near(b.center(), 330.0):
				if not u.dead and g.hostile(u.team, ai.team) and u.has_attack():
					return true
	return v >= 100.0


func summary() -> Dictionary:
	return {"strength": strength, "looks": looks}
