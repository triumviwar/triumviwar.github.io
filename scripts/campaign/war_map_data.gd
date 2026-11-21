class_name WarMapData
extends RefCounted
## THE WAR MAP's data and rules (docs/war_map_v1.md): campaign/warmap.json read with the player's progress. One data
## file for every skin: the King's parchment (WarMap, v1), later the Clockmaker's brass map and the Naturalist's
## specimen chart. Nothing here draws: state(p) says who holds each region, which marks show, each pin's state and
## seal, and the ledger's lines; WarMap draws that.

const PATH := "res://campaign/warmap.json"
const HOLDERS := ["empire", "crown", "contested", "machine", "brood", "unrest", "unknown"]
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
## "seal" ("" / "seal" / "broken"), "won_by"}}, "ledger": [{"text", "args": [strings], "missions": [ids]}]}.
static func state(p: Dictionary = {}) -> Dictionary:
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
		pins[mid] = {"state": s, "seal": "seal" if s == "done" else "",
			"won_by": String(((p.get("done", {}) as Dictionary).get(mid, {}) as Dictionary).get("won_by", ""))}
	var ledger: Array = []
	for r in d.get("rules", []):
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
			pins[String(r["pin"])]["seal"] = String(r.get("seal", "seal"))
		if String(r.get("ledger", "")) != "":
			var args: Array = (r.get("args", []) as Array).map(func(k) -> String:
				var v: Variant = flag_in(p, String(k))
				if v is float and float(v) == floorf(float(v)):
					v = int(v)          # (a count from the saved progress comes back as 34.0)
				return "?" if v == null else str(v))
			ledger.append({"text": String(r["ledger"]), "args": args, "missions": cond_missions(r.get("if", {}))})
	return {"regions": regions, "marks": marks, "pins": pins, "ledger": ledger}


## The ledger lines of one mission (its pin card's WHAT CAME OF IT).
static func ledger_of(st: Dictionary, mid: String) -> Array:
	return (st.get("ledger", []) as Array).filter(func(e: Dictionary) -> bool:
		return not (e["missions"] as Array).is_empty() and String(e["missions"][0]) == mid)


## A ledger line in the player's language.
static func ledger_text(e: Dictionary) -> String:
	var t := Loc.t(String(e["text"]))
	var args: Array = e.get("args", [])
	return t % args if not args.is_empty() and t.contains("%s") else t


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
	for rg in d.get("regions", []):
		if not HOLDERS.has(String(rg.get("holder", "empire"))):
			out.append("region %s: unknown holder" % rg["id"])
		if region_outline(rg).size() < 3:
			out.append("region %s: no outline" % rg["id"])
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
	return out.filter(func(s: String) -> bool: return s != "")
