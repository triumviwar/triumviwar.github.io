extends SceneTree
## THE CLOCK SIM (act3-warmap, docs/war_map_act3.md): Act 3 played in many orders, through WarMapData.clock itself, to see
## how many colonies fall and when, under the plan's proposed numbers and under the numbers the data now holds.
##   godot --headless --script res://tools/sim_war_clock.gd            (the summary tables)
##   godot --headless --script res://tools/sim_war_clock.gd -- detail  (every order's fallen colonies too)
## The orders: RANDOM (any open pin next), THEATRE BY THEATRE (each of the 24 theatre orders: a theatre's whole line, then
## the next), ROUND ROBIN (one mission from each theatre in turn), CAREFUL (always the theatre left alone longest, its
## optional pin as soon as it opens); each with
## the optional pins ALL played, NONE, or HALF (random); with LOSSES (a lost try is retried: the clock counts only wins)
## and MIRROR WINS (a fifth of the wins go to the danger: no colony is taken back), and with Act 2's two sparks stopped
## (d12 clean, d13 smashed) or not. Its CHECKS: the campaign never locks (every order reaches the night with every core
## mission played and every core pin still playable), the clock never takes more than one colony a year, never one from
## a settled theatre, never past the night, and with the tuned numbers a careful player keeps most colonies and a careless
## one loses several. Prints CHECK lines, then "war clock: N failures"; exit 1 on a failure.

var fails := 0
var detail := false

## The plan's proposal (docs/campaign_act3_plan.md, THE CLOCK): every win turns half a year, no grace, no head start.
const PLAN := {"per_year": 2, "optional_weight": 1.0, "grace": 0, "pass_on": true, "head_off": true, "reclaim_off": true}


func check(name: String, ok: bool, det := "") -> void:
	print("CHECK %-74s %s %s" % [name, "ok" if ok else "FAIL", det])
	if not ok:
		fails += 1


func _initialize() -> void:
	detail = OS.get_cmdline_user_args().has("detail")
	_run()
	print("war clock: %d failures" % fails)
	quit(1 if fails > 0 else 0)


## The clock's numbers for one setting (the PLAN switches the head start and the taking back off).
func _over(set: Dictionary) -> Dictionary:
	var o := {}
	for k in ["per_year", "optional_weight", "grace", "pass_on"]:
		if set.has(k):
			o[k] = set[k]
	if bool(set.get("head_off", false)) or bool(set.get("reclaim_off", false)) or set.has("head_more"):
		var ths: Array = (WarMapData.data()["clock"]["theatres"] as Array).duplicate(true)
		for t in ths:
			if bool(set.get("head_off", false)):
				t["head"] = []
			if set.has("head_more"):
				t["head"] = (t.get("head", []) as Array) + [{"if": {}, "years": int(set["head_more"].get(String(t["id"]), 0))}]
			if bool(set.get("reclaim_off", false)):
				for c in t["colonies"]:
					c.erase("reclaim")
		o["theatres"] = ths
	return o


# ------------------------------------------------------------------ the play orders

func _theatres() -> Array:
	return WarMapData.data()["clock"]["theatres"]


func _pins_open(done: Dictionary, opt_ok: Callable) -> Array:
	var out: Array = []
	for pn in WarMapData.data()["pins"]:
		var mid := String(pn["mission"])
		if done.has(mid) or not mid.begins_with("e") or bool(pn.get("night", false)) or mid in ["e19_tiber", "e20_rome"]:
			continue
		if bool(pn.get("optional", false)) and not opt_ok.call(mid):
			continue
		if (pn.get("after", []) as Array).all(func(a) -> bool: return done.has(String(a))):
			out.append(mid)
	return out


func _theatre_of(mid: String) -> String:
	var t := String(WarMapData.pin_of(mid).get("theatre", ""))
	return t if t != "" else "beyond"


## One Act 3 in an order chosen by `pick` (open pins, the wins so far, rng -> a mission): the progress it leaves, with the
## night begun at its end. `mirror`: the share of wins that go to the danger; `losses`: the chance a try is lost (and
## retried); `sparks_out`: Act 2's d12 and d13 played and stopped.
func _play(pick: Callable, opt_ok: Callable, rng: RandomNumberGenerator, mirror := 0.0, losses := 0.0, sparks_out := false) -> Dictionary:
	var done := {"d10_jungle": {"won_by": "crown", "seq": 1}, "d11_siege": {"won_by": "crown", "seq": 2}}
	if sparks_out:
		done["d12_luanda"] = {"won_by": "crown", "seq": 0, "flags": {"luanda": "clean"}}
		done["d13_goa"] = {"won_by": "crown", "seq": 0, "flags": {"goa_seed": "smashed"}}
	var seq := 2
	var order: Array = []
	var tries := 0
	while true:
		var open := _pins_open(done, opt_ok)
		if open.is_empty():
			break
		var mid := String(pick.call(open, order, rng))
		tries += 1
		if rng.randf() < losses:
			continue              # (a lost try: nothing recorded, the clock does not move)
		seq += 1
		var won_danger := rng.randf() < mirror
		done[mid] = {"won_by": "danger" if won_danger else "crown", "seq": seq, "flags": _flags(mid, won_danger)}
		order.append(mid)
		if tries > 400:
			break
	var p := {"done": done}
	var core_left := _core().filter(func(m) -> bool: return not done.has(m))
	# the night begins (the first port)
	seq += 1
	done["e16_lisbon"] = {"won_by": "crown", "seq": seq}
	return {"p": p, "order": order, "core_left": core_left, "tries": tries}


## The flags a mission leaves for the clock (the taking back): a Crown win holds its place, a danger's loses it.
func _flags(mid: String, lost: bool) -> Dictionary:
	match mid:
		"e02_potosi": return {"potosi": "lost" if lost else "held"}
		"e10_manila": return {"manila": "lost" if lost else "held"}
		"e11_spice": return {"spice": "burning" if lost else "cleared"}
		"e13_gold": return {"goldfields": "lost" if lost else "held"}
		"e14_shore": return {"shore": "green" if lost else "burned"}
	return {}


func _core() -> Array:
	var out: Array = []
	for t in _theatres():
		out.append_array(t["core"])
	return out


func _last_win(order: Array, t: String) -> int:
	for i in range(order.size() - 1, -1, -1):
		if _theatre_of(String(order[i])) == t or (String(order[i]) == "e15_forge" and t in ["africa", "indies"]):
			return i
	return -1


func _s_random(open: Array, _order: Array, rng: RandomNumberGenerator) -> String:
	return String(open[rng.randi() % open.size()])


func _s_by_theatre(torder: Array) -> Callable:
	return func(open: Array, _order: Array, _rng: RandomNumberGenerator) -> String:
		for t in torder + ["beyond"]:
			for m in open:
				if _theatre_of(String(m)) == t and not bool(WarMapData.pin_of(String(m)).get("optional", false)):
					return String(m)
			for m in open:
				if _theatre_of(String(m)) == t:
					return String(m)
		return String(open[0])


func _s_round_robin(open: Array, order: Array, _rng: RandomNumberGenerator) -> String:
	var ts := ["americas", "africa", "indies", "seas", "beyond"]
	var start := order.size() % 5
	for k in 5:
		var t: String = ts[(start + k) % 5]
		for m in open:
			if _theatre_of(String(m)) == t:
				return String(m)
	return String(open[0])


## CAREFUL: the open pin of the theatre left alone longest (its optional pin first: it holds the theatre for half a year).
func _s_careful(open: Array, order: Array, _rng: RandomNumberGenerator) -> String:
	var best := ""
	var bk := []
	for m in open:
		var t := _theatre_of(String(m))
		var lw := _last_win(order, t) if t != "beyond" else mini(_last_win(order, "africa"), _last_win(order, "indies"))
		var k := [lw, 0 if bool(WarMapData.pin_of(String(m)).get("optional", false)) else 1]
		if best == "" or k < bk:
			best = String(m)
			bk = k
	return best


func _opt_all(_m: String) -> bool:
	return true


func _opt_none(_m: String) -> bool:
	return false


# ------------------------------------------------------------------ the runs

## Every order under one setting: {name: [fallen counts]}, and the structural checks counted.
func _sweep(set: Dictionary, label: String, quiet := false) -> Dictionary:
	var over := _over(set)
	var res := {}
	var bad := {"lock": 0, "two_a_year": 0, "settled": 0, "after_night": 0, "runs": 0}
	var when := {}
	var which := {}
	var torders: Array = []
	_perms(["americas", "africa", "indies", "seas"], [], torders)
	var plans: Array = []
	for i in 200:
		plans.append(["random, all optional", Callable(self, "_s_random"), Callable(self, "_opt_all"), i, 0.0, 0.0])
		plans.append(["random, no optional", Callable(self, "_s_random"), Callable(self, "_opt_none"), i, 0.0, 0.0])
		plans.append(["random, half the optional", Callable(self, "_s_random"), Callable(), i, 0.0, 0.0])
		plans.append(["random, losses and mirror wins", Callable(self, "_s_random"), Callable(), i, 0.2, 0.3])
	for to in torders:
		plans.append(["theatre by theatre, no optional", _s_by_theatre(to), Callable(self, "_opt_none"), 0, 0.0, 0.0])
		plans.append(["theatre by theatre, all optional", _s_by_theatre(to), Callable(self, "_opt_all"), 0, 0.0, 0.0])
	plans.append(["round robin, all optional", Callable(self, "_s_round_robin"), Callable(self, "_opt_all"), 0, 0.0, 0.0])
	plans.append(["round robin, no optional", Callable(self, "_s_round_robin"), Callable(self, "_opt_none"), 0, 0.0, 0.0])
	plans.append(["careful, all optional", Callable(self, "_s_careful"), Callable(self, "_opt_all"), 0, 0.0, 0.0])
	plans.append(["careful, no optional", Callable(self, "_s_careful"), Callable(self, "_opt_none"), 0, 0.0, 0.0])
	for sparks in [false, true]:
		for pl in plans:
			var rng := RandomNumberGenerator.new()
			rng.seed = 7919 * int(pl[3]) + (1 if sparks else 0)
			var oo: Callable = pl[2]
			if not oo.is_valid():
				var half := {}
				for m in ["e02_potosi", "e07_highlands", "e10_manila", "e14_shore", "e15_forge"]:
					half[m] = rng.randf() < 0.5
				oo = func(m: String) -> bool: return bool(half.get(m, false))
			var run := _play(pl[1], oo, rng, float(pl[4]), float(pl[5]), sparks)
			var ck := WarMapData.clock(run["p"], over)
			bad["runs"] += 1
			if not (run["core_left"] as Array).is_empty():
				bad["lock"] += 1
			var years := {}
			for f in ck["fallen"]:
				years[int(f["year"])] = int(years.get(int(f["year"]), 0)) + 1
				when[int(f["year"])] = int(when.get(int(f["year"]), 0)) + 1
				which[String(f["region"])] = int(which.get(String(f["region"]), 0)) + 1
			if years.values().any(func(n) -> bool: return int(n) > 1):
				bad["two_a_year"] += 1
			# never from a theatre already settled when it fell: replay the clock up to each win
			var p2: Dictionary = run["p"]
			var core := _core()
			for f in ck["fallen"]:
				var th := WarMapData.theatre(String(f["theatre"]))
				var turn := int(f["year"]) - int(WarMapData.data()["clock"]["first_year"])
				var settled_at := _turn_settled(run["order"], th, over)
				if settled_at >= 0 and turn > settled_at:
					bad["settled"] += 1
			if not bool(ck["stopped"]):
				bad["after_night"] += 1
			var name := String(pl[0]) + (", sparks stopped" if sparks else "")
			if not res.has(name):
				res[name] = []
			(res[name] as Array).append((ck["fallen"] as Array).size())
			if detail:
				print("  %s | %s | %s" % [name, ",".join((run["order"] as Array).map(func(m) -> String: return String(m).substr(0, 3))),
					", ".join((ck["fallen"] as Array).map(func(f) -> String: return "%s %s" % [f["year"], f["region"]]))])
	if quiet:
		return {"res": res, "bad": bad}
	print("")
	print("== %s  %s" % [label, JSON.stringify(set)])
	print("   %-58s %6s %4s %4s  (of 12 colonies)" % ["order", "mean", "min", "max"])
	var names: Array = res.keys()
	names.sort()
	for n in names:
		var v: Array = res[n]
		var sum := 0.0
		for x in v:
			sum += float(x)
		print("   %-58s %6.2f %4d %4d" % [n, sum / v.size(), v.min(), v.max()])
	var ys: Array = when.keys()
	ys.sort()
	print("   falls by year (all %d runs): %s" % [bad["runs"], ", ".join(ys.map(func(y) -> String: return "%d: %d" % [y, when[y]]))])
	var ws: Array = which.keys()
	ws.sort_custom(func(x, y) -> bool: return int(which[x]) > int(which[y]))
	print("   falls by colony: %s" % ", ".join(ws.map(func(r) -> String: return "%s %d" % [r, which[r]])))
	return {"res": res, "bad": bad}


## The turn after which a theatre was settled in this order (-1: never), counting the clock's own weights.
func _turn_settled(order: Array, th: Dictionary, over: Dictionary) -> int:
	var ck: Dictionary = WarMapData.data()["clock"]
	var per := float(over.get("per_year", ck["per_year"]))
	var ow := float(over.get("optional_weight", ck["optional_weight"]))
	var wins := 0.0
	var seen := {}
	for m in order:
		wins += ow if bool(WarMapData.pin_of(String(m)).get("optional", false)) else 1.0
		seen[String(m)] = true
		if (th["core"] as Array).all(func(c) -> bool: return seen.has(String(c))):
			return int(floor(wins / per + 1e-6))
	return -1


func _perms(items: Array, acc: Array, out: Array) -> void:
	if items.is_empty():
		out.append(acc)
		return
	for i in items.size():
		var rest := items.duplicate()
		rest.remove_at(i)
		_perms(rest, acc + [items[i]], out)


func _mean(res: Dictionary, prefix: String) -> float:
	var sum := 0.0
	var n := 0
	for k in res:
		if String(k).begins_with(prefix) and not String(k).ends_with("sparks stopped"):
			for x in res[k]:
				sum += float(x)
				n += 1
	return sum / maxf(1, n)


func _max(res: Dictionary, prefix: String) -> int:
	var m := 0
	for k in res:
		if String(k).begins_with(prefix):
			m = maxi(m, int((res[k] as Array).max()))
	return m


## `-- grid`: the settings tried while tuning (one line each: careful, theatre by theatre, random, the worst).
func _grid() -> void:
	var quiet := true
	for hm in [{}, {"americas": 1, "seas": 1}, {"americas": 1, "africa": 1, "indies": 1, "seas": 1}]:
		for g in [2, 3]:
			for ow in [0.5, 1.0]:
				for po in [true]:
					var per := 2.0
					var set := {"per_year": per, "grace": g, "optional_weight": ow, "pass_on": po, "head_more": hm}
					var r: Dictionary = _sweep(set, "GRID", quiet)["res"]
					print(JSON.stringify(hm), " GRID per %.1f grace %d opt %.1f pass_on %s | careful %.2f round robin %.2f theatre-by-theatre %.2f random %.2f worst %d" % [
						per, g, ow, po, _mean(r, "careful, all"), _mean(r, "round robin"), _mean(r, "theatre by theatre"), _mean(r, "random"), _max(r, "")])


func _run() -> void:
	if OS.get_cmdline_user_args().has("grid"):
		_grid()
		return
	var before := _sweep(PLAN, "BEFORE: the plan's proposal")
	var tuned := {}
	var ck: Dictionary = WarMapData.data()["clock"]
	for k in ["per_year", "optional_weight", "grace", "pass_on"]:
		tuned[k] = ck[k]
	var after := _sweep(tuned, "AFTER: the numbers in campaign/warmap.json")
	var a: Dictionary = after["res"]
	var b: Dictionary = before["res"]
	print("")
	for which in [["before", before], ["after", after]]:
		var bd: Dictionary = which[1]["bad"]
		check("%s: every order reaches the night, every core mission played (%d runs)" % [which[0], bd["runs"]], int(bd["lock"]) == 0, str(bd["lock"]))
		check("%s: never two colonies in one year" % which[0], int(bd["two_a_year"]) == 0, str(bd["two_a_year"]))
		check("%s: never a colony from a settled theatre" % which[0], int(bd["settled"]) == 0, str(bd["settled"]))
		check("%s: the clock stops at the night" % which[0], int(bd["after_night"]) == 0, str(bd["after_night"]))
	var care := _mean(a, "careful, all")
	var rush := _mean(a, "theatre by theatre")
	var rnd := _mean(a, "random")
	check("after: a careful player keeps most colonies (loses 2 or fewer of 12)", care <= 2.0, "%.2f" % care)
	check("after: a careless order loses several (theatre by theatre: 2.5 or more on average)", rush >= 2.5, "%.2f" % rush)
	check("after: the order matters (careful loses at least 2 fewer than theatre by theatre)", rush - care >= 2.0, "%.2f v %.2f" % [care, rush])
	check("after: no order loses every colony of the act (at most 7 of 12)", _max(a, "") <= 7, str(_max(a, "")))
	check("after: stopping Act 2's sparks helps (careful + theatre by theatre lose less)",
		_mean(a, "careful, all optional, sparks") <= care and _mean(a, "theatre by theatre, no optional, sparks") <= _mean(a, "theatre by theatre, no optional"), "")
	check("before: the plan's numbers barely tell a careful order from a careless one (the reason for the tuning)",
		absf(_mean(b, "careful, all") - _mean(b, "theatre by theatre")) < 1.5, "%.2f v %.2f" % [_mean(b, "careful, all"), _mean(b, "theatre by theatre")])
	print("SUMMARY before careful %.2f rushed %.2f random %.2f | after careful %.2f rushed %.2f random %.2f" % [
		_mean(b, "careful, all"), _mean(b, "theatre by theatre"), _mean(b, "random"), care, rush, rnd])
