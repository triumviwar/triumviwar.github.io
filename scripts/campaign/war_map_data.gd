class_name WarMapData
extends RefCounted
## THE WAR MAP's data and rules (docs/war_map_v1.md): campaign/warmap.json read with the player's progress. One data
## file for every skin: the King's parchment (WarMap, v1), later the Clockmaker's brass map and the Naturalist's
## specimen chart. Nothing here draws: state(p) says who holds each region, which marks show, each pin's state and
## seal, and the ledger's lines; WarMap draws that.

const PATH := "res://campaign/warmap.json"
const HOLDERS := ["empire", "crown", "contested", "machine", "brood", "unrest", "unknown", "guild"]
## The skins (WarMap.SKINS): the King's parchment, the Clockmaker's brass map, the Naturalist's specimen chart
## (act2-warmap, docs/war_map_act2.md). Same data; a rule may name the skins it is for ("skins").
const SKINS := ["parchment", "brass", "chart"]
const MARK_KINDS := ["dot", "village", "town", "burnt", "question", "ship", "route", "gear", "queen", "church", "church_burnt", "fort", "siege",
	"theatre", "crown", "ruin", "ruin_open"]
## Act 3's theatres (act3-warmap, docs/war_map_act3.md): THE CLOCK's four, in the data's "clock".
const THEATRES := ["americas", "africa", "indies", "seas"]
const PIN_STATES := ["planned", "locked", "open", "done"]

static var _data := {}
static var _land := {}


static func data() -> Dictionary:
	if _data.is_empty():
		_data = _read(PATH)
	return _data


static func land() -> Dictionary:
	if _land.is_empty():
		_land = _read(String(data().get("land", "")))
	return _land


static func _read(path: String) -> Dictionary:
	if path == "":
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var d: Variant = JSON.parse_string(f.get_as_text())
	return d if d is Dictionary else {}


# ------------------------------------------------------------------ the projection (shared by every skin)

## [lon, lat] to map units: x = lon, y = -lat * y_scale (a plain equirectangular map, stretched north-south a little
## so mid-latitude lands keep their shape).
static func to_map(lon: float, lat: float) -> Vector2:
	return Vector2(lon, -lat * float(data().get("projection", {}).get("y_scale", 1.0)))


static func pt(a: Array) -> Vector2:
	return to_map(float(a[0]), float(a[1]))


## A flat [lon, lat, lon, lat, ...] list as map points.
static func ring(flat: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(0, flat.size() - 1, 2):
		out.append(to_map(float(flat[i]), float(flat[i + 1])))
	return out


## A lon/lat rectangle [lon0, lat0, lon1, lat1] in map units.
static func rect_of(r: Array) -> Rect2:
	var a := to_map(float(r[0]), float(r[1]))
	var b := to_map(float(r[2]), float(r[3]))
	return Rect2(a, Vector2.ZERO).expand(b)


## A region's outline in map units: its "poly", or its "circle" [lon, lat, radius in degrees] as a polygon.
static func region_outline(rg: Dictionary) -> PackedVector2Array:
	if rg.has("circle"):
		var c: Array = rg["circle"]
		var out := PackedVector2Array()
		for i in 24:
			var a := TAU * i / 24.0
			out.append(to_map(float(c[0]) + cos(a) * float(c[2]), float(c[1]) + sin(a) * float(c[2]) * 0.66))
		return out
	return ring(rg.get("poly", []))


## THE CATHOLIC PAINTINGS (owner 2026-11-20 23:09; wired in 2026-11-21): a place's pixel on a view's painted sheet
## (data "paintings", written by tools/campaign/fit_warmap_paintings.py): the place set by hand ("at", by pin or mark id),
## else the sheet's fit (a quadratic or affine in lon/lat, the world's two hemispheres apart, its landmarks spread back
## by inverse distance so each lands where it is painted).
static func painted_px(pt: Dictionary, lon: float, lat: float, key := "") -> Vector2:
	var at: Dictionary = pt.get("at", {})
	if key != "" and at.has(key):
		return Vector2(float(at[key][0]), float(at[key][1]))
	var c: Array = pt.get("fit", [])
	if pt.has("hemi"):
		c = pt["west"] if lon < float(pt["hemi"]) else pt["east"]
	if c.size() < 2:
		return Vector2.ZERO
	var cx: Array = c[0]
	var f: Array = [1.0, lon, lat] if cx.size() == 3 else [1.0, lon, lat, lon * lon, lon * lat, lat * lat]
	var p := Vector2.ZERO
	for i in f.size():
		p.x += float(cx[i]) * f[i]
		p.y += float(c[1][i]) * f[i]
	if c.size() > 2:
		var ws := 0.0
		var dp := Vector2.ZERO
		for r in c[2]:
			var dd := pow(lon - float(r[0]), 2) + pow(lat - float(r[1]), 2)
			if dd < 1e-9:
				return p + Vector2(float(r[2]), float(r[3]))
			ws += 1.0 / dd
			dp += Vector2(float(r[2]), float(r[3])) / dd
		p += dp / ws
	return p


static func pin_of(mid: String) -> Dictionary:
	for pn in data().get("pins", []):
		if String(pn["mission"]) == mid:
			return pn
	return {}


static func region_of(id: String) -> Dictionary:
	for rg in data().get("regions", []):
		if String(rg["id"]) == id:
			return rg
	return {}


static func mark_of(id: String) -> Dictionary:
	for mk in data().get("marks", []):
		if String(mk["id"]) == id:
			return mk
	return {}


# ------------------------------------------------------------------ the rules

## A finished mission's flag (as Campaign.flag, but from the progress given: tests pass their own).
static func flag_in(p: Dictionary, key: String) -> Variant:
	var pr := key.split(".")
	if pr.size() != 2:
		return null
	var e: Dictionary = (p.get("done", {}) as Dictionary).get(pr[0], {})
	return (e.get("flags", {}) as Dictionary).get(pr[1], null)


## A rule's "if" (every key must hold; {} always holds):
##   "done": mission (finished, by any side) or [missions]      "not_done": mission or [missions]
##   "won_by": {mission: side}                                   "flag": {"mission.flag": value or [values]}
##   "flag_at_least": {"mission.flag": number}                   "any": [conditions] (one of them)
static func cond_ok(c: Dictionary, p: Dictionary) -> bool:
	var done: Dictionary = p.get("done", {})
	for k in c:
		var v: Variant = c[k]
		match String(k):
			"done":
				for mid in (v if v is Array else [v]):
					if not done.has(String(mid)):
						return false
			"not_done":
				for mid in (v if v is Array else [v]):
					if done.has(String(mid)):
						return false
			"won_by":
				for mid in v:
					if String((done.get(mid, {}) as Dictionary).get("won_by", "")) != String(v[mid]):
						return false
			"flag":
				for fk in v:
					var have: Variant = flag_in(p, String(fk))
					if have == null:
						return false
					var want: Array = v[fk] if v[fk] is Array else [v[fk]]
					if not want.map(func(x) -> String: return str(x)).has(str(have)):
						return false
			"flag_at_least":
				for fk in v:
					var have: Variant = flag_in(p, String(fk))
					if have == null or float(str(have)) < float(v[fk]):
						return false
			"any":
				var one := false
				for sub in v:
					if cond_ok(sub, p):
						one = true
						break
				if not one:
					return false
			_:
				return false
	return true


## The missions a rule's condition names (the pin card shows a rule's ledger line under the first of them).
static func cond_missions(c: Dictionary) -> Array:
	var out: Array = []
	for k in c:
		var v: Variant = c[k]
		match String(k):
			"done", "not_done":
				for mid in (v if v is Array else [v]):
					out.append(String(mid))
			"won_by":
				for mid in v:
					out.append(String(mid))
			"flag", "flag_at_least":
				for fk in v:
					out.append(String(fk).split(".")[0])
			"any":
				for sub in v:
					out.append_array(cond_missions(sub))
	return out


## A pin's state: "planned" (no such mission yet: not in campaign.json), "locked" (written, not open to play yet),
## "open" (playable), "done" (finished: Campaign.record).
static func pin_state(mid: String, p: Dictionary) -> String:
	if (p.get("done", {}) as Dictionary).has(mid):
		return "done"
	if Campaign.storyline_of(mid).is_empty():
		return "planned"
	return "open" if Campaign.unlocked(mid, p) else "locked"


## The map as the progress leaves it: {"regions": {id: holder}, "marks": {id: shown}, "pins": {mission: {"state",
## "seal" ("" / "seal" / "broken"), "won_by", "clock" (the diamond's waiting front: its words, or "")}},
## "ledger": [{"text", "args": [strings], "missions": [ids]}], "notes": [the skin's margin notes shown]}.
## `skin`: a rule with "skins" runs only for those (Concórdia turns red on the King's parchment and the Naturalist's
## chart; Hollweg's brass map never shows it red: docs/war_map_act2.md).
static func state(p: Dictionary = {}, skin := "parchment") -> Dictionary:
	if p.is_empty():
		p = Campaign.progress()
	var d := data()
	var regions := {}
	for rg in d.get("regions", []):
		regions[String(rg["id"])] = String(rg.get("holder", "empire"))
	var marks := {}
	for mk in d.get("marks", []):
		marks[String(mk["id"])] = bool(mk.get("shown", false))
	var pins := {}
	for pn in d.get("pins", []):
		var mid := String(pn["mission"])
		var s := pin_state(mid, p)
		pins[mid] = {"state": s, "seal": "seal" if s == "done" else "", "clock": "",
			"won_by": String(((p.get("done", {}) as Dictionary).get(mid, {}) as Dictionary).get("won_by", ""))}
	var ledger: Array = []
	for r in d.get("rules", []):
		if r.has("skins") and not (r["skins"] as Array).has(skin):
			continue
		if not cond_ok(r.get("if", {}), p):
			continue
		var to := String(r.get("to", ""))
		var rids: Array = r.get("regions", [])
		if r.has("region"):
			rids = rids + [r["region"]]
		for id in rids:
			regions[String(id)] = to
		var mids: Array = r.get("marks", [])
		if r.has("mark"):
			mids = mids + [r["mark"]]
		for id in mids:
			marks[String(id)] = bool(r.get("show", true))
		if r.has("pin") and pins.has(String(r["pin"])):
			if r.has("clock"):
				pins[String(r["pin"])]["clock"] = String(r["clock"])
			else:
				pins[String(r["pin"])]["seal"] = String(r.get("seal", "seal"))
		if String(r.get("ledger", "")) != "":
			var args: Array = (r.get("args", []) as Array).map(func(k) -> String:
				var v: Variant = flag_in(p, String(k))
				if v is float and float(v) == floorf(float(v)):
					v = int(v)          # (a count from the saved progress comes back as 34.0)
				return "?" if v == null else str(v))
			ledger.append({"text": String(r["ledger"]), "args": args, "missions": cond_missions(r.get("if", {}))})
	# THE CLOCK (act3-warmap): the colonies it took, the ones taken back, the year; the optional pins closed by the night
	var ck := clock(p)
	if bool(ck["on"]):
		for f in ck["fallen"]:
			regions[String(f["region"])] = String(f["to"])
			ledger.append({"text": String(d["clock"]["fell"][String(f["to"])]), "args": [str(f["year"]), String(region_of(String(f["region"])).get("name", ""))],
				"loc_args": [1], "missions": [], "clock": true})
		for b in ck["reclaimed"]:
			regions[String(b["region"])] = "crown"
			ledger.append({"text": String(d["clock"]["back"]), "args": [str(b["year"]), String(region_of(String(b["region"])).get("name", ""))],
				"loc_args": [1], "missions": [String(b["mission"])], "clock": true})
		if bool(ck["stopped"]):
			for pn in d.get("pins", []):
				var mid := String(pn["mission"])
				if bool(pn.get("optional", false)) and pins.has(mid) and String(pins[mid]["state"]) != "done":
					pins[mid]["closed"] = true
	var notes: Array = []
	for n in d.get("notes", []):
		if (n.get("skins", SKINS) as Array).has(skin) and cond_ok(n.get("if", {}), p):
			notes.append(n)
	return {"regions": regions, "marks": marks, "pins": pins, "ledger": ledger, "notes": notes, "clock": ck}


## THE ACT the progress has reached (data "acts", a later one wins): {"act", "act_title", "view"} (the view the map
## opens on: Act 2 unrolls BRAZIL).
static func act(p: Dictionary = {}) -> Dictionary:
	if p.is_empty():
		p = Campaign.progress()
	var d := data()
	var vs: Array = d.get("views", [])
	var out := {"act": int(d.get("act", 1)), "act_title": String(d.get("act_title", "")), "view": String(vs[0]["id"]) if not vs.is_empty() else ""}
	for a in d.get("acts", []):
		if cond_ok(a.get("if", {}), p):
			for k in ["act", "act_title", "view"]:
				if a.has(k):
					out[k] = a[k]
	return out


## A skin's title (THE WAR MAP, THE BRASS MAP, THE SPECIMEN CHART).
static func skin_title(skin: String) -> String:
	return String(data().get("skins", {}).get(skin, {}).get("title", data().get("title", "THE WAR MAP")))


## The ledger lines of one mission (its pin card's WHAT CAME OF IT).
static func ledger_of(st: Dictionary, mid: String) -> Array:
	return (st.get("ledger", []) as Array).filter(func(e: Dictionary) -> bool:
		return not (e["missions"] as Array).is_empty() and String(e["missions"][0]) == mid)


## A ledger line in the player's language.
static func ledger_text(e: Dictionary) -> String:
	var t := Loc.t(String(e["text"]))
	var args: Array = (e.get("args", []) as Array).duplicate()
	for i in e.get("loc_args", []):
		args[int(i)] = Loc.t(String(args[int(i)]))
	return t % args if not args.is_empty() and t.contains("%s") else t


# ------------------------------------------------------------------ THE CLOCK (act3-warmap, docs/war_map_act3.md)

## The views the act shows (a view's "acts"; none = every act): Act 3 swaps THE WORLD's painted sheet for the whole globe
## and the four theatres.
static func views_for(act_n: int) -> Array:
	return (data().get("views", []) as Array).filter(func(v: Dictionary) -> bool:
		return not v.has("acts") or (v["acts"] as Array).map(func(x) -> int: return int(x)).has(act_n))


## A theatre's data ("clock" "theatres"), or {}.
static func theatre(id: String) -> Dictionary:
	for t in data().get("clock", {}).get("theatres", []):
		if String(t["id"]) == id:
			return t
	return {}


## The theatres a won mission keeps from neglect: its pin's "theatre" (core or optional), or the clock's "attention"
## (e15, the Cold Forge, beyond every theatre: Africa and the Indies).
static func attention_of(mid: String, ck: Dictionary = {}) -> Array:
	if ck.is_empty():
		ck = data().get("clock", {})
	if (ck.get("attention", {}) as Dictionary).has(mid):
		return ck["attention"][mid]
	var t := String(pin_of(mid).get("theatre", ""))
	return [t] if t != "" else []


## The Act 3 wins in the order they were won: Campaign.record keeps "seq" on each mission it records (older saves without
## it: the pins' order, after the numbered ones).
static func won_order(p: Dictionary, ck: Dictionary) -> Array:
	var done: Dictionary = p.get("done", {})
	var rows: Array = []
	var i := 0
	for pn in data().get("pins", []):
		var mid := String(pn["mission"])
		i += 1
		if done.has(mid) and not attention_of(mid, ck).is_empty():
			var e: Dictionary = done[mid]
			rows.append([float(e["seq"]) if e.has("seq") else 100000.0 + i, mid])
	rows.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	return rows.map(func(r: Array) -> String: return String(r[1]))


## THE CLOCK as the progress leaves it (`over` replaces any of the clock's numbers: tools/sim_war_clock.gd):
## {"on" (Act 3 has opened), "stopped" (the night has begun), "year" (2781 + the turns), "turns", "fallen":
## [{"region", "theatre", "to", "year"}], "reclaimed": [{"region", "theatre", "year", "mission"}], "settled": [theatres],
## "neglect": {theatre: whole years since its last win}, "risk": the theatre that loses a colony at the next turn ("" none),
## "risk_region", "wins" (the clock's count, optional ones counting their weight), "to_turn" (wins left to the next turn),
## "held": {theatre: [regions standing]}}.
static func clock(p: Dictionary, over: Dictionary = {}) -> Dictionary:
	var ck: Dictionary = (data().get("clock", {}) as Dictionary).duplicate()
	for k in over:
		ck[k] = over[k]
	var first := int(ck.get("first_year", 2781))
	var out := {"on": false, "stopped": false, "year": first, "turns": 0, "fallen": [], "reclaimed": [], "settled": [],
		"neglect": {}, "risk": "", "risk_region": "", "wins": 0.0, "to_turn": 0.0, "held": {}}
	if ck.is_empty() or not cond_ok(ck.get("start", {}), p):
		return out
	out["on"] = true
	var per := maxf(0.01, float(ck.get("per_year", 2)))
	var ow := float(ck.get("optional_weight", 1.0))
	var grace := int(ck.get("grace", 0))
	var pass_on := bool(ck.get("pass_on", true))
	var max_turns := int(ck.get("max_turns", 8))
	var tie: Array = ck.get("tie", THEATRES)
	var ths: Array = ck.get("theatres", [])
	var last := {}
	for t in ths:
		var head := 0
		for h in t.get("head", []):
			if cond_ok(h.get("if", {}), p):
				head += int(h.get("years", 0))
		last[String(t["id"])] = -head
	var night_seq := INF
	var done: Dictionary = p.get("done", {})
	for nm in ["e16_lisbon", "e17_goa", "e18_port"]:
		if done.has(nm) and (done[nm] as Dictionary).has("seq"):
			night_seq = minf(night_seq, float(done[nm]["seq"]))
	out["stopped"] = cond_ok(ck.get("stop", {"any": []}), p) if ck.has("stop") else false
	var seen := {}
	var fallen: Array = []
	var gone := {}            # regions fallen or safe (taken back): out of the clock's reach
	var safe := {}
	var turns := 0
	var wins := 0.0
	for mid in won_order(p, ck):
		var e: Dictionary = done[mid]
		if e.has("seq") and float(e["seq"]) > night_seq:
			continue              # (an optional one played after the night began: the clock had stopped)
		seen[mid] = true
		var prev := wins
		var opt := bool(pin_of(mid).get("optional", false))
		wins += ow if opt else 1.0
		for t in attention_of(mid, ck):
			last[String(t)] = turns + 1
		# a fallen colony taken back by the mission at its place (and safe from then on)
		for t in ths:
			for c in t["colonies"]:
				var rc: Dictionary = c.get("reclaim", {})
				if rc.is_empty() or not cond_missions(rc).has(mid) or not cond_ok(rc, p):
					continue
				var rid := String(c["region"])
				safe[rid] = true
				for f in fallen:
					if String(f["region"]) == rid:
						fallen.erase(f)
						out["reclaimed"].append({"region": rid, "theatre": String(t["id"]), "year": first + turns, "mission": mid})
						break
		if floor(wins / per + 1e-6) > floor(prev / per + 1e-6) and turns < max_turns:
			turns += 1
			var pick := _clock_pick(ths, seen, last, fallen, safe, turns, grace, pass_on, tie, p)
			if not pick.is_empty():
				pick["year"] = first + turns
				fallen.append(pick)
	out["turns"] = turns
	out["year"] = first + turns
	out["wins"] = wins
	out["to_turn"] = per - fmod(wins + 1e-6, per)
	out["fallen"] = fallen
	for t in ths:
		var tid := String(t["id"])
		out["neglect"][tid] = turns - int(last[tid])
		if (t["core"] as Array).all(func(m) -> bool: return seen.has(String(m))):
			out["settled"].append(tid)
		var held: Array = []
		for c in t["colonies"]:
			if not fallen.any(func(f: Dictionary) -> bool: return String(f["region"]) == String(c["region"])):
				held.append(String(c["region"]))
		out["held"][tid] = held
	if not bool(out["stopped"]):
		var nxt := _clock_pick(ths, seen, last, fallen, safe, turns + 1, grace, pass_on, tie, p)
		out["risk"] = String(nxt.get("theatre", ""))
		out["risk_region"] = String(nxt.get("region", ""))
	return out


## The colony that falls at this turn: the unsettled theatre left alone longest (at least `grace` whole years), with a
## colony left; ties to the one whose next colony goes to the creatures (the swarm is quicker than the machine), then the
## `tie` order. `pass_on` false: only the longest-neglected theatre may lose (an emptied one loses nothing more).
static func _clock_pick(ths: Array, seen: Dictionary, last: Dictionary, fallen: Array, safe: Dictionary, turn: int, grace: int,
		pass_on: bool, tie: Array, p: Dictionary) -> Dictionary:
	var cand: Array = []
	for t in ths:
		var tid := String(t["id"])
		if (t["core"] as Array).all(func(m) -> bool: return seen.has(String(m))):
			continue              # SETTLED: its fate is in its flags
		var neg := turn - int(last[tid])
		if neg < grace:
			continue
		var next := {}
		for c in t["colonies"]:
			var rid := String(c["region"])
			if safe.has(rid) or fallen.any(func(f: Dictionary) -> bool: return String(f["region"]) == rid):
				continue
			next = c
			break
		if next.is_empty() and pass_on:
			continue
		var to := String(next.get("to", "brood"))
		for ti in next.get("to_if", []):
			if cond_ok(ti.get("if", {}), p):
				to = String(ti["to"])
		cand.append({"neg": neg, "brood": 0 if to == "brood" else 1, "tie": tie.find(tid), "theatre": tid,
			"region": String(next.get("region", "")), "to": to})
	if cand.is_empty():
		return {}
	cand.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["neg"]) != int(b["neg"]):
			return int(a["neg"]) > int(b["neg"])
		if int(a["brood"]) != int(b["brood"]):
			return int(a["brood"]) < int(b["brood"])
		return int(a["tie"]) < int(b["tie"]))
	var c0: Dictionary = cand[0]
	if String(c0["region"]) == "":
		return {}                 # (pass_on false: the longest-neglected theatre has nothing left to lose)
	return {"theatre": c0["theatre"], "region": c0["region"], "to": c0["to"]}


## The colonies as the clock leaves them, {region: holder} (Campaign.record writes it into the progress as "colonies":
## the ledger's last mark, Campaign.colonies_share). {} before Act 3.
static func colonies(p: Dictionary) -> Dictionary:
	var ck := clock(p)
	if not bool(ck["on"]):
		return {}
	var regs: Dictionary = state(p).get("regions", {})
	var out := {}
	for t in data().get("clock", {}).get("theatres", []):
		for c in t["colonies"]:
			var rid := String(c["region"])
			var h := String(regs.get(rid, "crown"))
			out[rid] = "crown" if h in ["crown", "contested", "empire"] else h
	return out


# ------------------------------------------------------------------ checks (tools/test_war_map.gd, test_campaign.gd)

## The flags a mission can leave (its "flag" actions and tallies, "<flag>_n" for a tally's count).
static func mission_flags(m: Dictionary) -> Dictionary:
	var out := {}
	_walk_flags(m, out)
	return out


static func _walk_flags(x: Variant, out: Dictionary) -> void:
	if x is Dictionary:
		if x.has("flag") and x["flag"] is Dictionary:
			for k in x["flag"]:
				if not out.has(k):
					out[k] = []
				if not (out[k] as Array).has(str(x["flag"][k])):
					(out[k] as Array).append(str(x["flag"][k]))
		if x.has("tally") and x["tally"] is Dictionary:
			var fl := String(x["tally"].get("flag", ""))
			if not out.has(fl):
				out[fl] = []
			for b in x["tally"].get("bands", []):
				if not (out[fl] as Array).has(str(b[1])):
					(out[fl] as Array).append(str(b[1]))
			out[fl + "_n"] = ["*"]
		for v in x.values():
			_walk_flags(v, out)
	elif x is Array:
		for v in x:
			_walk_flags(v, out)


## Every problem with the data: unknown regions, marks, pins, holders, missions, sides or flags in the rules; a mission
## in campaign.json with no pin; a pin with no place or date. [] when it is sound.
static func problems() -> Array:
	var out: Array = []
	var d := data()
	if d.is_empty():
		return ["campaign/warmap.json does not load"]
	if land().get("land", []).is_empty():
		out.append("the land (%s) does not load" % String(d.get("land", "")))
	var pins := {}
	for pn in d.get("pins", []):
		var mid := String(pn.get("mission", ""))
		pins[mid] = pn
		for k in ["line", "place", "date", "point"]:
			if not pn.has(k):
				out.append("pin %s: no %s" % [mid, k])
		if not d.get("lines", {}).has(String(pn.get("line", ""))):
			out.append("pin %s: unknown line %s" % [mid, pn.get("line", "")])
		if Campaign.storyline_of(mid).is_empty() and String(pn.get("title", "")) == "":
			out.append("pin %s: a planned mission needs a title" % mid)
	for pn in d.get("pins", []):
		for a in pn.get("after", []):
			if not pins.has(String(a)):
				out.append("pin %s: after %s, which has no pin" % [pn["mission"], a])
	for mid in Campaign.mission_ids():
		if not pins.has(mid):
			out.append("mission %s has no pin on the war map" % mid)
	for mk in d.get("marks", []):
		if not MARK_KINDS.has(String(mk.get("kind", "dot"))):
			out.append("mark %s: unknown kind %s" % [mk["id"], mk.get("kind", "")])
		if String(mk.get("kind", "")) == "route" and (mk.get("points", []) as Array).size() < 2:
			out.append("mark %s: a route needs points" % mk["id"])
	for v in d.get("views", []):
		if (v.get("rect", []) as Array).size() != 4:
			out.append("view %s: no rect" % v.get("id", "?"))
	var vids: Array = (d.get("views", []) as Array).map(func(v) -> String: return String(v["id"]))
	var ai := 0
	for a in d.get("acts", []):
		if a.has("view") and not vids.has(String(a["view"])):
			out.append("act %d: unknown view %s" % [ai, a["view"]])
		_check_cond(a.get("if", {}), "act %d" % ai, pins, out)
		ai += 1
	var ni := 0
	for n in d.get("notes", []):
		for sk in n.get("skins", []):
			if not SKINS.has(String(sk)):
				out.append("note %d: unknown skin %s" % [ni, sk])
		if (n.get("point", []) as Array).size() != 2 or String(n.get("text", "")) == "":
			out.append("note %d: no point or text" % ni)
		_check_cond(n.get("if", {}), "note %d" % ni, pins, out)
		ni += 1
	for rg in d.get("regions", []):
		if not HOLDERS.has(String(rg.get("holder", "empire"))):
			out.append("region %s: unknown holder" % rg["id"])
		if region_outline(rg).size() < 3:
			out.append("region %s: no outline" % rg["id"])
	var ckd: Dictionary = d.get("clock", {})
	if not ckd.is_empty():
		_check_cond(ckd.get("start", {}), "clock start", pins, out)
		_check_cond(ckd.get("stop", {}), "clock stop", pins, out)
		for k in ["fell", "back", "year"]:
			if not ckd.has(k):
				out.append("clock: no %s" % k)
		var tids: Array = []
		for t in ckd.get("theatres", []):
			tids.append(String(t["id"]))
			for m in t.get("core", []) + t.get("optional", []):
				if not pins.has(String(m)):
					out.append("clock %s: %s has no pin" % [t["id"], m])
				elif String(pins[String(m)].get("theatre", "")) != String(t["id"]):
					out.append("clock %s: %s's pin names another theatre" % [t["id"], m])
			for m in t.get("optional", []):
				if pins.has(String(m)) and not bool(pins[String(m)].get("optional", false)):
					out.append("clock %s: %s is not marked optional" % [t["id"], m])
			for c in t.get("colonies", []):
				if region_of(String(c.get("region", ""))).is_empty():
					out.append("clock %s: unknown colony %s" % [t["id"], c.get("region", "")])
				if not ["brood", "machine"].has(String(c.get("to", ""))):
					out.append("clock %s: %s falls to %s" % [t["id"], c.get("region", ""), c.get("to", "")])
				if c.has("reclaim"):
					_check_cond(c["reclaim"], "clock reclaim %s" % c["region"], pins, out)
				for ti in c.get("to_if", []):
					_check_cond(ti.get("if", {}), "clock %s" % c["region"], pins, out)
			for h in t.get("head", []):
				_check_cond(h.get("if", {}), "clock head %s" % t["id"], pins, out)
		for tid in THEATRES:
			if not tids.has(tid):
				out.append("clock: no theatre %s" % tid)
		for tt in ckd.get("tie", []):
			if not tids.has(String(tt)):
				out.append("clock: unknown tie %s" % tt)
	for v in d.get("views", []):
		for a in v.get("acts", []):
			if int(a) < 1 or int(a) > 4:
				out.append("view %s: unknown act %s" % [v["id"], a])
	var i := 0
	for r in d.get("rules", []):
		var w := "rule %d" % i
		i += 1
		var rids: Array = r.get("regions", []) + ([r["region"]] if r.has("region") else [])
		for id in rids:
			if region_of(String(id)).is_empty():
				out.append("%s: unknown region %s" % [w, id])
		if not rids.is_empty() and not HOLDERS.has(String(r.get("to", ""))):
			out.append("%s: unknown holder %s" % [w, r.get("to", "")])
		for id in r.get("marks", []) + ([r["mark"]] if r.has("mark") else []):
			if mark_of(String(id)).is_empty():
				out.append("%s: unknown mark %s" % [w, id])
		if r.has("pin") and not pins.has(String(r["pin"])):
			out.append("%s: unknown pin %s" % [w, r["pin"]])
		if r.has("clock") and not r.has("pin"):
			out.append("%s: a clock needs a pin" % w)
		for sk in r.get("skins", []):
			if not SKINS.has(String(sk)):
				out.append("%s: unknown skin %s" % [w, sk])
		_check_cond(r.get("if", {}), w, pins, out)
	return out


static func _check_cond(c: Dictionary, w: String, pins: Dictionary, out: Array) -> void:
	for k in c:
		var v: Variant = c[k]
		match String(k):
			"done", "not_done":
				for mid in (v if v is Array else [v]):
					if not pins.has(String(mid)):
						out.append("%s: %s %s has no pin" % [w, k, mid])
			"won_by":
				for mid in v:
					if not pins.has(String(mid)):
						out.append("%s: won_by %s has no pin" % [w, mid])
					var m := Campaign.mission(String(mid)) if not Campaign.storyline_of(String(mid)).is_empty() else {}
					if not m.is_empty() and not Campaign.side_ids(m).has(String(v[mid])):
						out.append("%s: %s has no side %s" % [w, mid, v[mid]])
			"flag", "flag_at_least":
				for fk in v:
					var pr := String(fk).split(".")
					if pr.size() != 2 or not pins.has(pr[0]):
						out.append("%s: flag %s: no such pin" % [w, fk])
						continue
					if Campaign.storyline_of(pr[0]).is_empty():
						continue          # (a planned mission: its flags are the plan's, checked when it is built)
					var fl := mission_flags(Campaign.mission(pr[0]))
					if not fl.has(pr[1]):
						out.append("%s: %s never sets the flag %s" % [w, pr[0], pr[1]])
					elif k == "flag":
						for want in (v[fk] if v[fk] is Array else [v[fk]]):
							if not (fl[pr[1]] as Array).has(str(want)) and not (fl[pr[1]] as Array).has("*"):
								out.append("%s: %s never sets %s to %s" % [w, pr[0], pr[1], want])
			"any":
				for sub in v:
					_check_cond(sub, w, pins, out)
			_:
				out.append("%s: unknown condition %s" % [w, k])


## Every player-facing text of the war map (the translation check).
static func strings() -> Array:
	var d := data()
	var out: Array = [String(d.get("title", "")), String(d.get("act_title", ""))]
	for v in d.get("views", []):
		out.append(String(v.get("label", "")))
	for k in d.get("lines", {}):
		out.append(String(d["lines"][k].get("name", "")))
	for k in d.get("holders", {}):
		out.append(String(d["holders"][k]))
	for rg in d.get("regions", []):
		out.append(String(rg.get("name", "")))
	for mk in d.get("marks", []):
		out.append(String(mk.get("label", "")))
	for pn in d.get("pins", []):
		out.append_array([String(pn.get("place", "")), String(pn.get("date", "")), String(pn.get("title", ""))])
	for r in d.get("rules", []):
		out.append(String(r.get("ledger", "")))
		out.append(String(r.get("clock", "")))
	for pn in d.get("pins", []):
		out.append(String(pn.get("about", "")))
	for a in d.get("acts", []):
		out.append(String(a.get("act_title", "")))
	for k in d.get("skins", {}):
		out.append(String(d["skins"][k].get("title", "")))
	for n in d.get("notes", []):
		out.append(String(n.get("text", "")))
	var ckd: Dictionary = d.get("clock", {})
	for k in ckd.get("fell", {}):
		out.append(String(ckd["fell"][k]))
	out.append_array([String(ckd.get("back", "")), String(ckd.get("year", ""))])
	for t in ckd.get("theatres", []):
		out.append(String(t.get("name", "")))
	return out.filter(func(s: String) -> bool: return s != "")
