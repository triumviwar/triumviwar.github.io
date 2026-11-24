class_name WWAI
extends RefCounted
## THE WORLD WAR's computer (docs/world_war_mode.md): a simple strategist for one side's turn on the world map. It gives
## its orders one at a time through the same calls a player uses (WWWar.build / recruit / move), so the page can show
## each march and stop when a player's army is attacked (FIGHT IT or AUTO-RESOLVE). Fought battles use the skirmish's
## own computers. Easy wants 1.6 times the enemy's strength before it attacks, Normal 1.25, Hard 1.05 (and Hard earns
## 10% more, Easy 10% less: WWRules.AI_INCOME).


## One order for the current side: {"kind": "build" | "recruit" | "move" | "done", ...the move's result}. "done" when
## the side has nothing more to do this turn.
static func step(w: WWWar) -> Dictionary:
	var f := w.current()
	var lvl := w.who(f)
	var margin := w.numf("AI_MARGIN", lvl, null, 1.25)
	var st: Dictionary = w.d.get("ai_turn", {})
	if int(st.get("s", -1)) != int(w.d["season"]) or String(st.get("f", "")) != f:
		st = {"s": int(w.d["season"]), "f": f, "phase": 0, "done": []}
		w.d["ai_turn"] = st
	# 1. an army big enough for its lands first, then buildings, then more soldiers with what is left
	if int(st["phase"]) == 0:
		var want := w.numf("AI_WANT_BASE") + w.numf("AI_WANT_REGION") * w.regions_of(f).size()
		var have := 0.0
		for a in w.armies_of(f):
			have += w.army_value(a)
		if have < want * w.numf("AI_BUILD_AT"):
			var r0 := _recruit_one(w, f, 120)
			if not r0.is_empty():
				return r0
		st["phase"] = 1
	if int(st["phase"]) == 1:
		var b := _build_one(w, f)
		if not b.is_empty():
			return b
		st["phase"] = 2
	if int(st["phase"]) == 2:
		var r := _recruit_one(w, f, -1)
		if not r.is_empty():
			return r
		st["phase"] = 3
	# 2. march: the biggest armies first, each once
	var armies: Array = w.armies_of(f).filter(func(a) -> bool: return not bool(a["moved"]) and not (st["done"] as Array).has(String(a["id"])))
	armies.sort_custom(func(a, b) -> bool: return w.army_value(a) > w.army_value(b))
	for a in armies:
		(st["done"] as Array).append(String(a["id"]))
		var to := _target(w, a, margin)
		if to != "":
			var res := w.move(String(a["id"]), to)
			res["kind_move"] = res.get("kind", "")
			res["kind"] = "move"
			res["army"] = String(a["id"])
			res["to"] = to
			return res
	w.d.erase("ai_turn")
	return {"kind": "done"}


## Play the side's whole turn with every battle auto-resolved (the simulations, tests and computer-only wars).
static func play_turn(w: WWWar) -> void:
	for _i in 200:
		var r := step(w)
		if String(r.get("kind", "")) == "done":
			return
		if String(r.get("kind_move", "")) == "battle":
			w.resolve(r["battle"])


static func _threat(w: WWWar, rid: String, f: String) -> float:
	var t := 0.0
	for n in WWRules.neighbours(rid):
		for a in w.armies_at(n):
			if String(a["f"]) != f:
				t = maxf(t, float(w.army_value(a)) * (1.0 + w.numf("VET_STEP") * int(a["vet"])))
	return t


static func _defence_here(w: WWWar, rid: String, f: String) -> float:
	var D := 0.0
	for a in w.armies_at(rid, f):
		D += w.army_value(a) * (1.0 + w.numf("VET_STEP") * int(a["vet"]))
	D += WWRules.worth(rid) * w.numf("GUARD") + float(WWRules.building(f, String(w.d["regions"][rid]["build"])).get("defence", 0))
	if rid == w.capital(f):
		D += w.capital_guard(f)
	return D * (w.numf("DEFEND_CAPITAL") if rid == w.capital(f) else w.numf("DEFEND"))


static func _frontier(w: WWWar, rid: String, f: String) -> bool:
	for n in WWRules.neighbours(rid):
		if w.owner(n) != f:
			return true
	return false


static func _build_one(w: WWWar, f: String) -> Dictionary:
	var gold := w.gold(f)
	var reserve := 100
	var best := ""
	var best_b := ""
	var best_score := -1.0
	for rid in w.regions_of(f):
		if String(w.d["regions"][rid]["build"]) != "":
			continue
		var front := _frontier(w, rid, f)
		var pick := ""
		var score := float(WWRules.worth(rid))
		var unrest := float(w.d["regions"][rid]["unrest"])
		if unrest > 30.0:
			pick = {"crown": "church", "clockwork": "regulator", "brood": "nest"}[f]
			score += 4.0
		elif front and _threat(w, rid, f) > 0.0 and rid != w.capital(f):
			pick = WWRules.BUILDINGS[f][0]["id"]
			score += 3.0
		else:
			pick = {"crown": "market", "clockwork": "trade_post", "brood": "swamp"}[f]
			if f == "brood" and not ["temperate", "wet", "jungle"].has(WWRules.biome(rid)):
				pick = "nest"
			score += 1.0 + w.numf("BIOME_INCOME", f, WWRules.biome(rid), 1.0)
		# a muster place near the front when the only one is far
		if pick != WWRules.BUILDINGS[f][0]["id"] and front and not _has_muster_near(w, f, rid):
			pick = WWRules.BUILDINGS[f][0]["id"]
			score += 2.0
		var cost := int(WWRules.building(f, pick)["cost"])
		if gold - cost < reserve or w.build_problem(rid, pick) != "":
			continue
		if score > best_score:
			best_score = score
			best = rid
			best_b = pick
	if best == "":
		return {}
	w.build(best, best_b)
	return {"kind": "build", "region": best, "build": best_b}


static func _has_muster_near(w: WWWar, f: String, rid: String) -> bool:
	if w.is_muster(rid, f):
		return true
	for n in WWRules.neighbours(rid):
		if w.is_muster(n, f):
			return true
	return false


static func _recruit_one(w: WWWar, f: String, keep_at := -1) -> Dictionary:
	var regs: Array = WWRules.REGIMENTS[f]
	# where: the muster place under the most threat, else the one nearest the enemy
	var best := ""
	var best_score := -INF
	for rid in w.regions_of(f):
		if not w.is_muster(rid, f):
			continue
		var s := _threat(w, rid, f) - _defence_here(w, rid, f) * 0.5
		if _frontier(w, rid, f):
			s += 300.0
		if rid == w.capital(f):
			s += 100.0
		if s > best_score:
			best_score = s
			best = rid
	if best == "":
		return {}
	# the mix: mostly the first regiment, a second and third kind in turn
	var mates := w.armies_at(best, f)
	var have := {}
	if not mates.is_empty():
		have = mates[0]["units"]
	var pick := String(regs[0]["id"])
	var v0 := 0
	var v1 := 0
	var v2 := 0
	for k in have:
		var v := int(WWRules.UNIT_VALUE[k]) * int(have[k])
		if (regs[0]["units"] as Dictionary).has(k):
			v0 += v
		elif (regs[1]["units"] as Dictionary).has(k):
			v1 += v
		else:
			v2 += v
	if v1 < v0 * 0.35:
		pick = String(regs[1]["id"])
	elif v2 < v0 * 0.25:
		pick = String(regs[2]["id"])
	var keep := 150 if _threat(w, best, f) > _defence_here(w, best, f) else 350
	if keep_at >= 0:
		keep = keep_at
	var r := WWRules.regiment(f, pick)
	if w.gold(f) - WWRules.regiment_cost(r) < keep or w.recruit_problem(best, pick) != "":
		return {}
	w.recruit(best, pick)
	return {"kind": "recruit", "region": best, "regiment": pick}


## Where an army marches, or "" (it stays: guarding, or nothing worth the risk).
static func _target(w: WWWar, a: Dictionary, margin: float) -> String:
	var f := String(a["f"])
	var at := String(a["at"])
	var mine := float(w.army_value(a)) * (1.0 + w.numf("VET_STEP") * int(a["vet"]))
	if not w.heroes_with(String(a["id"])).is_empty():
		mine *= w.numf("HERO_BONUS")
	# a guard at home: the capital's army stays while an enemy next door could take it
	if at == w.capital(f):
		var th := _threat2(w, at, f)
		var without := _defence_here(w, at, f) - mine * w.numf("DEFEND_CAPITAL")
		if th > without * 0.9:
			# (only a part may go: the rest keeps the capital safe; WWWar.split leaves half)
			if mine > th * 2.2 and WWRules.units_count(a["units"]) >= 8:
				w.split(String(a["id"]))
			return ""
	# the climate hurts here: leave
	var hurt := w.numf("ATTRITION", f, w.biome_now(at), 0.0) > 0.0
	var best := ""
	var best_score := 0.5 if hurt else 0.0
	var ed := _enemy_dist(w, f)
	# THE MARCH ON A CAPITAL: a big army (AI_MARCH and more) later in the war heads for the nearest enemy capital
	var march := mine >= w.numf("AI_MARCH") and int(w.d["season"]) >= int(w.numf("AI_MARCH_FROM"))
	var cd := _capital_dist(w, f) if march else {}
	for m in w.moves_for(String(a["id"])):
		var to := String(m["to"])
		var own := w.owner(to)
		var bio := w.biome_now(to)
		var climate := w.numf("ATTRITION", f, bio, 0.0)
		var score := 0.0
		if own == f:
			# to a threatened region of its own, or to join a bigger army near the front
			var th := _threat(w, to, f) if to != w.capital(f) else _threat2(w, to, f)
			var dh := _defence_here(w, to, f)
			if th > dh:
				score = 2.0 + (4.0 if to == w.capital(f) else 0.0)
			elif hurt and climate == 0.0:
				score = 1.0
			elif not w.armies_at(to, f).is_empty() and WWRules.units_count(a["units"]) + WWRules.units_count(w.armies_at(to, f)[0]["units"]) <= w.numf("ARMY_CAP") \
					and (mine < 500.0 or _frontier(w, to, f)):
				score = 0.6 if mine < 500.0 else 1.1          # (armies gather into one big enough to take a capital)
			elif march and int(cd.get(to, 99)) < int(cd.get(at, 99)):
				score = 1.3          # (on toward the enemy capital)
			elif mine >= 1200.0 and int(ed.get(to, 99)) < int(ed.get(at, 99)):
				score = 0.9          # (a strong army marches toward the enemy)
			score -= climate * 6.0
		else:
			var b := {"att": String(a["id"]), "region": to, "att_f": f, "def_f": own,
				"defs": w.armies_at(to).filter(func(x) -> bool: return String(x["f"]) != f).map(func(x) -> String: return String(x["id"]))}
			var s := w.strengths(b)
			var need := margin * (w.numf("AI_CAPITAL_MARGIN") if own != "" and w.capital(own) == to else 1.0)
			if float(s["att"]) < float(s["def"]) * need:
				continue
			if f == "brood" and WWRules.biome(to) == "cold" and (b["defs"] as Array).is_empty():
				continue          # (nothing to win there: the cold land can't be held)
			score = float(WWRules.worth(to)) + (3.0 if WWRules.is_key(to) else 0.0)
			if own != "" and w.capital(own) == to:
				score += 20.0
			if not (b["defs"] as Array).is_empty():
				score += 1.5
			if own != "":
				score += 1.0
				var lead := _leader(w, f)
				var real := not w.rule_on("AI_LEADER_REAL") or w.land_worth(lead) > w.land_worth(f)
				if own == lead and real:
					score += w.numf("AI_LEADER")          # (the side with the most land is everyone's first enemy: anti-snowball)
				elif own != lead and lead != "" and real and w.land_worth(lead) >= w.numf("AI_TRUCE_GAP") * w.land_worth(own) \
						and w.capital(own) != to:
					score -= w.numf("AI_TRUCE")          # (THE COALITION: while one side runs ahead, the others leave each other be)
			score -= climate * 8.0
			if march and int(cd.get(to, 99)) < int(cd.get(at, 99)):
				score += 2.0
			if bool(m["sea"]):
				score -= 1.5
			score -= w.numf("AI_FAR") * maxi(0, int(w.hops(f).get(to, 9)) - 3)          # (far lands cost upkeep and rise: stay near)
			# leaving the capital bare to an enemy next door: not worth it
			if at == w.capital(f) and _threat(w, at, f) > 0.0:
				score -= 2.0
		if score > best_score:
			best_score = score
			best = to
	return best


## Steps from every region to the nearest region an enemy side holds (its capital counts double: half the steps).
static func _enemy_dist(w: WWWar, f: String) -> Dictionary:
	var dist := {}
	var q: Array = []
	for rid in w.d["regions"]:
		var o := w.owner(rid)
		if o != "" and o != f and w.alive(o):
			dist[rid] = 0
			q.append(rid)
	while not q.is_empty():
		var r: String = q.pop_front()
		for n in WWRules.neighbours(r):
			if not dist.has(n):
				dist[n] = int(dist[r]) + 1
				q.append(n)
	return dist


## Steps from every region to the nearest capital of a side still in the war (not f's).
static func _capital_dist(w: WWWar, f: String) -> Dictionary:
	var dist := {}
	var q: Array = []
	for o in w.d["order"]:
		if o != f and w.alive(o):
			dist[w.capital(o)] = 0
			q.append(w.capital(o))
	while not q.is_empty():
		var r: String = q.pop_front()
		for n in WWRules.neighbours(r):
			if not dist.has(n):
				dist[n] = int(dist[r]) + 1
				q.append(n)
	return dist


## The strongest enemy force within two steps of a region (what could reach it in two seasons).
static func _threat2(w: WWWar, rid: String, f: String) -> float:
	var t := _threat(w, rid, f)
	for n in WWRules.neighbours(rid):
		t = maxf(t, _threat(w, n, f) * 0.9)
	return t


## The side (not f) holding the most worth of land.
static func _leader(w: WWWar, f: String) -> String:
	var best := ""
	for o in w.d["order"]:
		if o != f and w.alive(o) and (best == "" or w.land_worth(o) > w.land_worth(best)):
			best = o
	return best
