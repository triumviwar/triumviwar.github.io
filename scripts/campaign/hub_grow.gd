class_name HubGrow
extends RefCounted
## HUBS THAT GROW (job hubs-grow, docs/hubs_grow.md; the owner 2026-11-22: "as missions pass ... more people in the hubs
## and also more rooms", "rooms that act on the game, like SC2 campaigns"). The data is campaign/hubs_grow.json:
##  - "rooms": rooms of a hub beyond its main painting (each its own layered painting, campaign/hub/rooms/<id>.json),
##    open by progress and flags; "hotspots" in them ("talk", "shop": an upgrade counter, "door").
##  - "people": a person who joins a room (a layer: their cut-out on the room) by progress and flags, with a talk.
##  - "upgrades" (bought once, for good), "choices" (one of two, switched freely between missions: like StarCraft II's
##    Laboratory), "blessings" (the Crown's chapel: one boon chosen for the next missions), "helpers" (one company
##    called into each mission: like the Cantina's mercenaries). Each line has its own purse ("currency"), earned by
##    winning its missions ("earn") and their optional objectives; what is bought reaches only that line's own
##    missions ("reach"), played SOLO on the line's own side: never skirmish, online or a mirror.
## Conditions (rooms, people, hotspots, offers, talk entries): "requires" (a mission id or a list: all finished),
## "until" (none of them finished), "flag" {"<mission>.<flag>": value or [values]} (all as left), "not_flag" (none as
## left), "sides" / "not_sides" (as CampaignMenu.sides_ok), "any": [conditions] (one holds).
## The state lives in the campaign's progress file (Campaign.progress()["hub"], ["hub_seen"]): IRONMAN keeps it as is
## (nothing here loads a mission back).

const PATH := "res://campaign/hubs_grow.json"
static var _data := {}


static func data() -> Dictionary:
	if _data.is_empty():
		var f := FileAccess.open(PATH, FileAccess.READ)
		if f:
			var d: Variant = JSON.parse_string(f.get_as_text())
			if d is Dictionary:
				_data = d
	return _data


static func line(lid: String) -> Dictionary:
	return (data().get("lines", {}) as Dictionary).get(lid, {})


# ------------------------------------------------------------------ conditions

static func _ids(v: Variant) -> Array:
	if v is Array:
		return v
	return [] if String(v) == "" else [String(v)]


static func _flag_is(p: Dictionary, fk: String, want: Variant) -> bool:
	var pr := fk.split(".")
	if pr.size() != 2:
		return false
	var e: Dictionary = (p.get("done", {}) as Dictionary).get(pr[0], {})
	var have := str(e.get("flags", {}).get(pr[1], null))
	if want is Array:
		return (want as Array).any(func(w) -> bool: return str(w) == have)
	return str(want) == have


static func ok(x: Dictionary, p: Dictionary) -> bool:
	var done: Dictionary = p.get("done", {})
	for r in _ids(x.get("requires", "")):
		if not done.has(String(r)):
			return false
	for u in _ids(x.get("until", "")):
		if done.has(String(u)):
			return false
	for fk in x.get("flag", {}):
		if not _flag_is(p, String(fk), x["flag"][fk]):
			return false
	for fk in x.get("not_flag", {}):
		if _flag_is(p, String(fk), x["not_flag"][fk]):
			return false
	if not CampaignMenu.sides_ok(x, p):
		return false
	var any: Array = x.get("any", [])
	if not any.is_empty() and not any.any(func(c: Dictionary) -> bool: return ok(c, p)):
		return false
	return true


# ------------------------------------------------------------------ rooms and people

## The rooms of a line open now: the main room first ({"id", "title", "main": true}), then the others in data order.
static func rooms_now(lid: String, p: Dictionary) -> Array:
	var ln := line(lid)
	if ln.is_empty():
		return []
	var out: Array = [{"id": String(ln.get("main", "main")), "title": String(ln.get("main_title", "")), "main": true}]
	if not ok(ln, p):
		return out          # (the Machine's City: the guild's rooms are not the machine's)
	for r in data().get("rooms", []):
		if String(r.get("line", "")) == lid and ok(r, p):
			out.append(r)
	return out


static func room(lid: String, rid: String) -> Dictionary:
	for r in data().get("rooms", []):
		if String(r.get("line", "")) == lid and String(r["id"]) == rid:
			return r
	return {}


## The people standing in a room now (those whose conditions hold).
static func people_now(lid: String, rid: String, p: Dictionary) -> Array:
	return (data().get("people", []) as Array).filter(func(x: Dictionary) -> bool:
		return String(x.get("line", "")) == lid and String(x.get("room", "")) == rid and ok(x, p))


## A room's hotspots now: its own (by their conditions), then a talk hotspot for each person in it.
static func hotspots_now(lid: String, rid: String, p: Dictionary, room_size := Vector2(1672, 941)) -> Array:
	var out: Array = []
	var r := room(lid, rid)
	for hs in r.get("hotspots", []):
		if ok(hs, p):
			out.append(hs)
	out.append_array(people_hotspots(lid, rid, p, room_size))
	return out


static func people_hotspots(lid: String, rid: String, p: Dictionary, room_size := Vector2(1672, 941)) -> Array:
	var out: Array = []
	for pe in people_now(lid, rid, p):
		var pos: Array = pe.get("pos", [0, 0])
		var sz: Array = pe.get("size", [1, 1])
		var h := float(sz[1])
		if pe.has("behind"):
			h = minf(h, float(pe["behind"]) - float(pos[1]))
		out.append({"id": "p_" + String(pe["id"]), "kind": "talk", "label": String(pe.get("name", "")), "talk": String(pe.get("talk", "")),
			"layer": "p_" + String(pe["id"]), "person": String(pe["id"]),
			"rect": [float(pos[0]) / room_size.x, float(pos[1]) / room_size.y, float(sz[0]) / room_size.x, h / room_size.y]})
	return out


static func talk(tid: String) -> Dictionary:
	return (data().get("talks", {}) as Dictionary).get(tid, {})


## What a talk says now: the last entry that holds (its "after": a mission finished, "" always; and its conditions).
static func talk_lines(tk: Dictionary, p: Dictionary) -> Array:
	var out: Array = []
	for e in tk.get("entries", []):
		var aft := String(e.get("after", ""))
		if (aft == "" or (p.get("done", {}) as Dictionary).has(aft)) and ok(e, p):
			out = e.get("lines", [])
	return out


## A person's portrait for the talk box: the talk's own, else campaign/portraits/<id>.png when there is one.
static func portrait_of(pid: String, tk: Dictionary) -> String:
	if String(tk.get("portrait", "")) != "":
		return String(tk["portrait"])
	for pe in data().get("people", []):
		if String(pe["id"]) == pid:
			var f := "res://campaign/portraits/%s.png" % String(pe.get("portrait", pid))
			if ResourceLoader.exists(f):
				return f
	return ""


# ------------------------------------------------------------------ the NEW marks

static func seen(key: String, p: Dictionary = {}) -> bool:
	if p.is_empty():
		p = Campaign.progress()
	return (p.get("hub_seen", {}) as Dictionary).has(key)


static func mark_seen(keys: Array) -> void:
	var p := Campaign.progress()
	var s: Dictionary = p.get("hub_seen", {})
	var changed := false
	for k in keys:
		if not s.has(String(k)):
			s[String(k)] = true
			changed = true
	if changed:
		p["hub_seen"] = s
		Campaign.save_progress(p)


## What is new in a line's hub and not looked at yet: [{"key", "text", "room"}] (rooms and people with their "joined"
## line; new offers in the shops: "New at <room>: <label>").
static func news(lid: String, p: Dictionary) -> Array:
	var out: Array = []
	var rooms := rooms_now(lid, p)
	for r in rooms:
		if bool(r.get("main", false)):
			continue
		var k := "room:%s:%s" % [lid, String(r["id"])]
		if not seen(k, p):
			out.append({"key": k, "text": String(r.get("joined", "")), "room": String(r["id"])})
	for r in rooms:
		for pe in people_now(lid, String(r["id"]), p):
			var k := "person:%s:%s" % [lid, String(pe["id"])]
			if not seen(k, p):
				out.append({"key": k, "text": String(pe.get("joined", "")), "room": String(r["id"])})
	return out


static func room_is_new(lid: String, rid: String, p: Dictionary) -> bool:
	if not seen("room:%s:%s" % [lid, rid], p) and not room(lid, rid).is_empty():
		return true
	if people_now(lid, rid, p).any(func(pe: Dictionary) -> bool: return not seen("person:%s:%s" % [lid, String(pe["id"])], p)):
		return true
	var r := room(lid, rid)
	for hs in r.get("hotspots", []):
		if String(hs.get("kind", "")) == "shop" and ok(hs, p) and shop_is_new(lid, hs.get("shop", []), p):
			return true
	return false


static func shop_is_new(lid: String, kinds: Array, p: Dictionary) -> bool:
	for o in offers(lid, kinds, p):
		if not seen("offer:" + String(o["id"]), p):
			return true
	return false


# ------------------------------------------------------------------ the purse and the offers

static func state(p: Dictionary = {}) -> Dictionary:
	if p.is_empty():
		p = Campaign.progress()
	var h: Dictionary = p.get("hub", {})
	for k in ["earned", "spent", "choices", "bless", "helper"]:
		if not h.has(k):
			h[k] = {}
	if not h.has("bought"):
		h["bought"] = []
	return h


static func _save_state(h: Dictionary) -> void:
	var p := Campaign.progress()
	p["hub"] = h
	Campaign.save_progress(p)


## Earned in all on a line (the best of each of its missions), and what is left to spend.
static func earned(lid: String, p: Dictionary = {}) -> int:
	var h := state(p)
	var n := 0
	for mid in line(lid).get("earn", []):
		n += int((h["earned"] as Dictionary).get(String(mid), 0))
	return n


static func purse(lid: String, p: Dictionary = {}) -> int:
	var h := state(p)
	return earned(lid, p) - int((h["spent"] as Dictionary).get(lid, 0))


## Every offer of these kinds ("upgrades", "choices", "blessings", "helpers") on a line, open now.
static func offers(lid: String, kinds: Array, p: Dictionary) -> Array:
	var out: Array = []
	for k in kinds:
		for o in data().get(String(k), []):
			if String(o.get("line", "")) == lid and ok(o, p):
				var oo: Dictionary = o.duplicate()
				oo["type"] = String(k)
				out.append(oo)
	return out


static func offer(oid: String) -> Dictionary:
	for k in ["upgrades", "choices", "blessings", "helpers"]:
		for o in data().get(k, []):
			if String(o["id"]) == oid:
				var oo: Dictionary = o.duplicate()
				oo["type"] = k
				return oo
	return {}


static func bought(oid: String, p: Dictionary = {}) -> bool:
	return (state(p)["bought"] as Array).has(oid)


## Buy an upgrade: "" done, else why not.
static func buy(oid: String) -> String:
	var o := offer(oid)
	var p := Campaign.progress()
	if o.is_empty() or o["type"] != "upgrades" or not ok(o, p):
		return "Not on offer."
	if bought(oid, p):
		return "Already bought."
	var lid := String(o["line"])
	if purse(lid, p) < int(o.get("cost", 0)):
		return "Not enough %s." % String(line(lid).get("currency", ""))
	var h := state(p)
	(h["bought"] as Array).append(oid)
	h["spent"][lid] = int((h["spent"] as Dictionary).get(lid, 0)) + int(o.get("cost", 0))
	_save_state(h)
	return ""


## A choice is open once the line has earned its "at" in all (what was brought back), and its conditions hold.
static func choice_open(o: Dictionary, p: Dictionary) -> bool:
	if test_all() != "":
		return true
	return earned(String(o.get("line", "")), p) >= int(o.get("at", 0))


static func choose(cid: String, ab: String) -> String:
	var o := offer(cid)
	var p := Campaign.progress()
	if o.is_empty() or o["type"] != "choices" or not ok(o, p) or not choice_open(o, p) or not (ab in ["a", "b", ""]):
		return "Not open yet."
	var h := state(p)
	if ab == "":
		h["choices"].erase(cid)
	else:
		h["choices"][cid] = ab
	_save_state(h)
	return ""


## The chapel's blessing or the company called for a line ("" none).
static func pick(kind: String, lid: String, oid: String) -> String:
	var p := Campaign.progress()
	if oid != "":
		var o := offer(oid)
		if o.is_empty() or o["type"] != kind or String(o["line"]) != lid or not ok(o, p):
			return "Not on offer."
	var h := state(p)
	var key := "bless" if kind == "blessings" else "helper"
	if oid == "":
		h[key].erase(lid)
	else:
		h[key][lid] = oid
	_save_state(h)
	return ""


static func picked(kind: String, lid: String, p: Dictionary = {}) -> String:
	var key := "bless" if kind == "blessings" else "helper"
	return String((state(p)[key] as Dictionary).get(lid, ""))


# ------------------------------------------------------------------ what reaches a mission

## The line whose rooms reach this mission ("" none): it must be in the line's "reach", played solo on the mission's
## own default side (never a mirror), and the line's own conditions hold (the Machine's City has none).
static func line_for(mid: String, side := "") -> String:
	for lid in data().get("lines", {}):
		if (line(lid).get("reach", []) as Array).has(mid):
			var m := Campaign.mission(mid)
			if m.is_empty():
				return ""
			var own := Campaign.seat_side(m, "solo", "p1")
			if side != "" and side != own:
				return ""
			return String(lid) if ok(line(lid), Campaign.progress()) else ""
	return ""


## Everything a mission gets from its line's hub: {"line", "mods": {kind: {stat: value}}, "gold", "helper": {...} or
## {}, "items": [[label, about]] (the briefing's list)}.
static func loadout(mid: String, side := "", p: Dictionary = {}) -> Dictionary:
	if p.is_empty():
		p = Campaign.progress()
	var lid := line_for(mid, side)
	var out := {"line": lid, "mods": {}, "gold": 0, "helper": {}, "items": []}
	if lid == "":
		return out
	var h := state(p)
	var all := test_all()
	if all != "":
		h = _all_state(lid, p, all, _p1_faction(mid))
	for o in offers(lid, ["upgrades"], p):
		if (h["bought"] as Array).has(String(o["id"])):
			_add_mods(out, o.get("mods", {}))
			out["items"].append([String(o["label"]), String(o["about"])])
	for o in offers(lid, ["choices"], p):
		var ab := String((h["choices"] as Dictionary).get(String(o["id"]), ""))
		if ab != "" and choice_open(o, p):
			var side_o: Dictionary = o.get(ab, {})
			_add_mods(out, side_o.get("mods", {}))
			out["items"].append([String(side_o.get("label", "")), String(side_o.get("about", ""))])
	var bl := offer(String((h["bless"] as Dictionary).get(lid, "")))
	if not bl.is_empty() and ok(bl, p):
		_add_mods(out, bl.get("mods", {}))
		out["gold"] = int(out["gold"]) + int(bl.get("gold", 0))
		out["items"].append([String(bl["label"]), String(bl["about"])])
	var hp := offer(String((h["helper"] as Dictionary).get(lid, "")))
	if not hp.is_empty() and ok(hp, p):
		out["helper"] = hp
		out["items"].append([String(hp["label"]), String(hp["about"])])
	return out


## A TEST SWITCH (the mission sims, docs/hubs_grow.md "Checks"): `-- hubgrow:a` (or `hubgrow:b`) plays a mission as if the
## line had every upgrade open now, each choice on its a (b) side, the first blessing and the first company open. Never in a
## real game.
static func test_all() -> String:
	for x in OS.get_cmdline_user_args():
		if String(x) in ["hubgrow:a", "hubgrow:b"]:
			return String(x).substr(8)
	return ""


static func _p1_faction(mid: String) -> String:
	var m := Campaign.mission(mid)
	for tm in m.get("teams", []):
		if Campaign.solo_control(m, tm) == "p1":
			return Campaign.engine_faction(m, String(tm.get("faction", "crown")))
	return ""


static func _all_state(lid: String, p: Dictionary, ab: String, fac := "") -> Dictionary:
	var h := {"bought": [], "choices": {}, "bless": {}, "helper": {}, "earned": {}, "spent": {}}
	for o in offers(lid, ["upgrades"], p):
		h["bought"].append(String(o["id"]))
	for o in offers(lid, ["choices"], p):
		h["choices"][String(o["id"])] = ab
	var bls := offers(lid, ["blessings"], p)
	if not bls.is_empty():
		h["bless"][lid] = String(bls[0]["id"])
	var hps := offers(lid, ["helpers"], p).filter(func(o: Dictionary) -> bool: return fac == "" or String(o.get("faction", fac)) == fac)
	if not hps.is_empty():
		h["helper"][lid] = String(hps[-1]["id"])      # (the latest company met: the one a player most likely calls)
	return h


## Multipliers multiply ("hp", "damage", "speed", "wind_drain"); "sight" and "armor" add.
static func _add_mods(out: Dictionary, mods: Dictionary) -> void:
	for k in mods:
		if not (out["mods"] as Dictionary).has(k):
			out["mods"][k] = {}
		var cur: Dictionary = out["mods"][k]
		for st in mods[k]:
			var v := float(mods[k][st])
			if st in ["sight", "armor"]:
				cur[st] = float(cur.get(st, 0.0)) + v
			else:
				cur[st] = float(cur.get(st, 1.0)) * v


## The briefing's lines: what this mission gets from the hub ([] nothing).
static func brief_lines(mid: String, side := "") -> Array:
	var lo := loadout(mid, side)
	return (lo["items"] as Array).map(func(it: Array) -> String: return Loc.t(String(it[0])) + ": " + Loc.t(String(it[1])))


# ------------------------------------------------------------------ in the match (Game's two hooks)

## The match's loadout, worked out once (solo campaign missions only: not online, not a lesson, not a replay).
static func _game_loadout(g: Game) -> Dictionary:
	if g.has_meta("hub_loadout"):
		return g.get_meta("hub_loadout")
	var lo := {}
	var run := g.mission
	if run != null and run.mode == "solo" and g.net == null and not bool(run.data.get("tutorial", false)) and not g.puppet:
		lo = loadout(run.id, run.solo_side)
		var teams: Array = []
		for t in run.player_teams:
			teams.append(int(t))
		lo["teams"] = teams
	g.set_meta("hub_loadout", lo)
	return lo


## Game._add_unit: a unit of the player's team gets the line's upgrades for its kind (its own copy of its numbers).
static func on_unit(g: Game, u: Unit) -> void:
	var lo := _game_loadout(g)
	if lo.is_empty() or not (lo.get("teams", []) as Array).has(u.team):
		return
	var md: Dictionary = (lo.get("mods", {}) as Dictionary).get(u.kind, {})
	if md.is_empty():
		return
	apply_mods(u, md)


static func apply_mods(u: Unit, md: Dictionary) -> void:
	if is_same(u.d, Defs.UNITS.get(u.kind, {})):
		u.d = u.d.duplicate(true)
	for st in md:
		var v := float(md[st])
		match String(st):
			"hp":
				u.d["hp"] = float(u.d["hp"]) * v
				u.max_hp = float(u.d["hp"])
				u.hp = u.max_hp
			"damage":
				u.d["damage"] = float(u.d.get("damage", 0.0)) * v
			"speed":
				u.d["speed"] = float(u.d["speed"]) * v
				u.speed = float(u.d["speed"])
			"wind_drain":
				u.d["wind_drain"] = float(u.d.get("wind_drain", 1.0)) * v
			"sight":
				u.d["sight"] = float(u.d["sight"]) + v
				u.sight = int(round(float(u.d["sight"])))
			"armor":
				u.d["armor"] = float(u.d["armor"]) + v
				u.armor = float(u.d["armor"])
	u.set_meta("hub_mods", md)


## Game._start_positions, after the mission's own start: the blessing's gold and the company called (by the player's
## first team's men, if the mission lets that kind in).
static func on_start(g: Game) -> void:
	var lo := _game_loadout(g)
	if lo.is_empty() or (lo.get("teams", []) as Array).is_empty():
		return
	var t := int(lo["teams"][0])
	if int(lo.get("gold", 0)) > 0:
		g.players[t]["gold"] = int(g.players[t]["gold"]) + int(lo["gold"])
	var hp: Dictionary = lo.get("helper", {})
	if hp.is_empty():
		return
	var k := String(hp.get("kind", ""))
	if not Defs.UNITS.has(k) or g.factions[t] != String(hp.get("faction", g.factions[t])) or g.mission.denied(t, k):
		lo["helper_skipped"] = k
		return
	var at := _muster_point(g, t)
	var n := int(hp.get("count", 1))
	var made: Array = []
	for i in n:
		var off := Vector2(cos(float(i) * 2.4), sin(float(i) * 2.4)) * (40.0 + 18.0 * float(i))
		var u := g._add_unit(k, t, _walkable_near(g, at + off))
		u.set_meta("mission_name", String(hp.get("label", "")))
		made.append(u)
	lo["helper_units"] = made
	g._recount_supply(t)
	if g.mlog:
		g.mlog.add("(hub) %s: %d %s" % [String(hp["id"]), n, k])


## Where the company comes in: among the team's men (their middle), else at its start.
static func _muster_point(g: Game, t: int) -> Vector2:
	var sum := Vector2.ZERO
	var n := 0
	for u in g.units:
		if u.team == t and not u.dead and not u.is_worker():
			sum += u.position
			n += 1
	if n > 0:
		return sum / float(n)
	if t < g.starts.size():
		return (Vector2(g.starts[t]) + Vector2(2, 4)) * Defs.TILE
	return Vector2.ZERO


static func _walkable_near(g: Game, pos: Vector2) -> Vector2:
	var c := g.cell_of(pos)
	for r in 6:
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var cc := c + Vector2i(dx, dy)
				if g.in_map(cc) and g._walkable(cc) and g.solid[g.idx(cc)] == 0:
					return (Vector2(cc) + Vector2(0.5, 0.5)) * Defs.TILE
	return pos


# ------------------------------------------------------------------ earning (the mission's end)

## A mission won on its own side: its line earns "win" + "optional" for each optional objective of that side done. The
## best run of each mission counts (playing it again never pays twice). Returns {"line", "got" (this run), "new" (added
## to the purse), "currency"} or {} when nothing is earned.
static func award(mid: String, run_side: String, won: bool, optional_done: int, mode: String) -> Dictionary:
	if not won or mode == "versus":
		return {}
	var lid := ""
	for l in data().get("lines", {}):
		if (line(l).get("earn", []) as Array).has(mid):
			lid = String(l)
			break
	if lid == "":
		return {}
	var m := Campaign.mission(mid)
	if run_side != Campaign.seat_side(m, "solo", "p1"):
		return {}
	var e: Dictionary = data().get("earn", {})
	var got := int(e.get("win", 2)) + int(e.get("optional", 1)) * optional_done
	var p := Campaign.progress()
	var h := state(p)
	var before := int((h["earned"] as Dictionary).get(mid, 0))
	if got > before:
		h["earned"][mid] = got
		p["hub"] = h
		Campaign.save_progress(p)
	return {"line": lid, "got": got, "new": maxi(0, got - before), "currency": String(line(lid).get("currency", ""))}


## The optional objectives of a side done in a finished run.
static func optional_done(run: MissionRun, side: String) -> int:
	var n := 0
	for o in run.objectives_for(side):
		if not bool(o.get("primary", true)) and String(o.get("state", "")) == "done" and String(o.get("kind", "")) != "countdown":
			n += 1
	return n


# ------------------------------------------------------------------ texts (the translation check)

static func strings() -> Array:
	var out: Array = []
	for lid in data().get("lines", {}):
		out.append_array([String(line(lid).get("main_title", "")), String(line(lid).get("currency", ""))])
	for r in data().get("rooms", []):
		out.append_array([String(r.get("title", "")), String(r.get("joined", ""))])
		for hs in r.get("hotspots", []):
			out.append(String(hs.get("label", "")))
	for pe in data().get("people", []):
		out.append_array([String(pe.get("name", "")), String(pe.get("joined", ""))])
	for k in ["upgrades", "blessings", "helpers"]:
		for o in data().get(k, []):
			out.append_array([String(o.get("label", "")), String(o.get("about", ""))])
	for o in data().get("choices", []):
		out.append(String(o.get("label", "")))
		for ab in ["a", "b"]:
			out.append_array([String(o[ab].get("label", "")), String(o[ab].get("about", ""))])
	for tk in data().get("talks", {}).values():
		out.append(String(tk.get("name", "")))
		for e in tk.get("entries", []):
			for ln in e.get("lines", []):
				out.append(String(ln))
	out.append_array(UI_STRINGS)
	return out.filter(func(s: String) -> bool: return s != "")


## The words the hub's rooms and counters show (HubRoomsUi), for the translation check.
const UI_STRINGS := ["NEW", "NEW IN THE HUB", "%s to spend: %d (%d earned in all)", "BUY  (%d)", "BOUGHT", "PICK", "PICKED",
	"Opens when %d have been earned in all.", "CHOOSE ONE", "UPGRADES: bought once, for good.",
	"BLESSING: one at a time, for every mission of this line until you change it.",
	"COMPANY: one at a time, called into every mission of this line until you change it.", "NONE",
	"Earn more by winning this line's missions and their optional objectives.", "FROM THE HUB (solo):",
	"(change them in the hub)", "+%d %s (best run of this mission: %d)", "CLOSE", "Not enough %s.", "Already bought.",
	"Not on offer.", "Not open yet.", "Only in this line's own missions, played solo.", "BACK TO %s"]
