class_name Campaign
extends RefCounted
## The campaign's data (docs/campaign_engine.md): the chapter list (campaign/campaign.json), the missions
## (campaign/missions/<id>.json), their maps (campaign/maps/<name>.json, the map editor's format, map id
## "campaign:<name>") and the player's progress (user://campaign.json). The running mission is MissionRun.

const DIR := "res://campaign"
const PROGRESS := "user://campaign.json"
const MODES := ["solo", "coop", "versus"]
const MODE_LABEL := {"solo": "SOLO", "coop": "CO-OP", "versus": "VERSUS"}
## A team's "control" per mode: "p1" (the first player: you in solo, the host online), "p2" (the friend online),
## "script" (the mission's triggers move it: no computer player), or "ai:<level>:<plan>" (the normal computer).

static var _cache := {}
## CAMPAIGN DIFFICULTY (act1-engine0, docs/act1_engine0.md): picked on the briefing, kept in the progress file. A mission
## reads it with the {"difficulty": ...} condition and through its "difficulty" multipliers: "clocks" (countdowns the
## player races: longer is easier) and "spawns" (how many units the sides no person plays get).
const DIFFICULTIES := ["easy", "normal", "hard"]
const DIFF_LABEL := {"easy": "EASY", "normal": "NORMAL", "hard": "HARD"}
const DIFF_DEFAULT := {"easy": {"clocks": 1.25, "spawns": 0.75}, "normal": {"clocks": 1.0, "spawns": 1.0},
	"hard": {"clocks": 0.85, "spawns": 1.25}}


## Tests and the hub pictures (tools/shot_hub.gd): every storyline opens, so the Clockwork and Brood hubs can be
## looked at before their acts unlock. Never set by the game itself.
static var open_all := false


static func _json(path: String) -> Dictionary:
	if _cache.has(path):
		return _cache[path]
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var d: Variant = JSON.parse_string(f.get_as_text())
	var out: Dictionary = d if d is Dictionary else {}
	_cache[path] = out
	return out


static func index() -> Dictionary:
	return _json(DIR + "/campaign.json")


## The storylines (campaign.json "storylines"): each {id, title, about, missions: [ids in order], requires: a mission
## id that opens it ("" or none: open from the start)}. The campaign branches by storylines (e.g. after the prologue,
## one line per hero), and inside a storyline by each mission's "next" (who won).
static func storylines() -> Array:
	return index().get("storylines", [])


## Every mission id, storyline by storyline.
static func mission_ids() -> Array:
	var out: Array = []
	for sl in storylines():
		for id in sl.get("missions", []):
			if not out.has(String(id)):
				out.append(String(id))      # (a crossing, a07, is in all three lines: listed once)
	return out


static func storyline_of(id: String) -> Dictionary:
	for sl in storylines():
		if (sl.get("missions", []) as Array).has(id):
			return sl
	return {}


## Is this storyline open? (Its "requires" mission is done, or it has none.)
static func storyline_open(sl: Dictionary, p: Dictionary = {}) -> bool:
	if open_all:
		return true
	if p.is_empty():
		p = progress()
	var req := String(sl.get("requires", ""))
	return req == "" or (p["done"] as Dictionary).has(req)


## The storylines a finished mission opens (their "requires").
static func opens(id: String) -> Array:
	return storylines().filter(func(sl: Dictionary) -> bool: return String(sl.get("requires", "")) == id)


static func mission(id: String) -> Dictionary:
	var path := "%s/missions/%s.json" % [DIR, id]
	var m := _json(path)
	if m.has("steps") and not m.has("_expanded"):
		expand_steps(m)          # (a TUTORIAL lesson: its steps become lines, tasks and triggers: docs/tutorial.md)
	return m


## A lesson's STEPS (docs/tutorial.md) written out as the engine's own parts, once, in place: each step's lines
## (inline texts get ids "<step>_<n>"), its task (an objective of kind "manual" with "task": true, hidden until the
## step starts), and two triggers: "start_<step>" (after the step before it is done: says the lines, shows the task,
## points, runs its "do", and marks the camera, the counts and the noted actions so its wait is measured from here)
## and "done_<step>" (its "wait" holds: the task is ticked, the pointer goes, "then" runs). After the last step the
## lesson is won ("steps_end": "win", the default) or the match goes on to its normal end ("").
static func expand_steps(m: Dictionary) -> void:
	m["_expanded"] = true
	var side := String(m.get("tutorial_side", ""))
	if side == "":
		side = String((m.get("sides", [{}]) as Array)[0].get("id", ""))
	var teacher := String(m.get("teacher", "teacher"))
	if not m.has("lines"):
		m["lines"] = {}
	if not m.has("objectives"):
		m["objectives"] = []
	if not m.has("triggers"):
		m["triggers"] = []
	var steps: Array = m["steps"]
	var prev := ""
	for i in steps.size():
		var st: Dictionary = steps[i]
		var sid := String(st.get("id", "s%d" % i))
		var ids: Array = []
		var n := 0
		for ln in st.get("say", []):
			if ln is String and (m["lines"] as Dictionary).has(ln):
				ids.append(ln)
				continue
			n += 1
			var lid := "%s_%d" % [sid, n]
			var e := {"who": String(st.get("who", teacher))}
			if ln is Dictionary:
				e["text"] = String(ln.get("pc", ln.get("text", "")))
				if ln.has("phone"):
					e["phone"] = String(ln["phone"])
			else:
				e["text"] = String(ln)
			m["lines"][lid] = e
			ids.append(lid)
		var start_do: Array = [{"mark": true}]
		if not ids.is_empty():
			start_do.append({"say": ids})
		if st.has("task"):
			var tk: Variant = st["task"]
			var o := {"id": "task_" + sid, "side": side, "kind": "manual", "primary": false, "task": true, "hidden": true,
				"text": String(tk.get("pc", tk.get("text", ""))) if tk is Dictionary else String(tk)}
			if tk is Dictionary and tk.has("phone"):
				o["phone"] = String(tk["phone"])
			m["objectives"].append(o)
			start_do.append({"objective": {"id": "task_" + sid, "set": "active"}})
		start_do.append({"point": st.get("point", {})})
		start_do.append_array(st.get("do", []))
		var when: Dictionary = {"fired": "done_" + prev} if prev != "" else {"time": 0.5}
		m["triggers"].append({"id": "start_" + sid, "when": when, "delay": float(st.get("delay", 0.5 if prev == "" else 1.0)), "do": start_do, "step": sid})
		var wait: Variant = st.get("wait", {"talked": true})
		var done_do: Array = [{"point": {}}]
		if st.has("task"):
			done_do.append({"objective": {"id": "task_" + sid, "set": "done"}})
		done_do.append_array(st.get("then", []))
		m["triggers"].append({"id": "done_" + sid, "when": {"all": [{"fired": "start_" + sid}, wait]}, "delay": float(st.get("after", 0.6)), "do": done_do})
		prev = sid
	if prev != "" and String(m.get("steps_end", "win")) == "win":
		m["triggers"].append({"id": "lesson_won", "when": {"fired": "done_" + prev}, "delay": 1.5, "do": [{"win": side}]})


static func map_data(name: String) -> Dictionary:
	return _json("%s/maps/%s.json" % [DIR, name])


static func modes_of(m: Dictionary) -> Array:
	return (m.get("modes", ["solo"]) as Array).filter(func(x) -> bool: return MODES.has(String(x)))


static func side_ids(m: Dictionary) -> Array:
	return (m.get("sides", []) as Array).map(func(s: Dictionary) -> String: return String(s["id"]))


static func side_index(m: Dictionary, side_id: String) -> int:
	return side_ids(m).find(side_id)


static func side_name(m: Dictionary, side_id: String) -> String:
	for s in m.get("sides", []):
		if String(s["id"]) == side_id:
			return String(s.get("name", side_id))
	return side_id


static func control_of(team: Dictionary, mode: String, pick := "", m: Dictionary = {}) -> String:
	var c: Variant = team.get("control", "script")
	var out := String((c as Dictionary).get(mode, "script")) if c is Dictionary else String(c)
	# THE VERSUS PICK (a07): in versus the friend's seat (p2) goes to ONE of the mission's "versus_pick" sides; the
	# other picked sides' p2 teams are scripted. `pick` "" = the first of them.
	if mode == "versus" and out == "p2" and not m.is_empty() and not versus_picks(m).is_empty():
		var pk := pick if versus_picks(m).has(pick) else String(versus_picks(m)[0])
		if String(team.get("side", "")) != pk:
			return "script"
	return out


## THE VERSUS PICK (a07): the sides the versus friend (seat p2) may lead (mission "versus_pick": [side ids]); [] none.
static func versus_picks(m: Dictionary) -> Array:
	return (m.get("versus_pick", []) as Array).map(func(x) -> String: return String(x)).filter(func(x: String) -> bool: return side_ids(m).has(x))


## CAMPAIGN-ONLY FACTIONS (e.g. the human tribes, planned, design pending): a mission declares them in "factions":
## {"tribes": {"name": "...", "stand_in": "crown", "campaign_only": true}}; a team may then say "faction": "tribes".
## They never appear in the skirmish or online lobbies (those list Main.FACS / NetLobby.FACTIONS, playable factions
## only). Until the faction exists in Defs.FACTIONS (with "campaign_only": true) the match plays its "stand_in".
static func engine_faction(m: Dictionary, f: String) -> String:
	if Defs.FACTIONS.has(f):
		return f
	return String(m.get("factions", {}).get(f, {}).get("stand_in", "crown"))


static func faction_known(m: Dictionary, f: String) -> bool:
	return Defs.FACTIONS.has(f) or Defs.FACTIONS.has(String(m.get("factions", {}).get(f, {}).get("stand_in", "")))


## THE SOLO SIDE PICK (act1-engine0): the sides a solo player may lead ("solo_sides": [side ids]; none: only the side
## of the solo "p1" team). The first is the mission's own default.
static func solo_sides(m: Dictionary) -> Array:
	var d := seat_side(m, "solo", "p1")
	var out: Array = []
	for sd in m.get("solo_sides", []):
		if side_ids(m).has(String(sd)) and not out.has(String(sd)):
			out.append(String(sd))
	out.erase(d)
	out.push_front(d)
	return out


## Who moves a team in a solo game where the player leads `side`. The mission's default side: its "solo" control. Another
## picked side: the team's "control" may say it outright ("solo:<side>": "p1" / "script" / "ai:..."); else the teams of
## that side a person plays in versus become yours, the default player's teams become their "foe" control ("script"
## if none), and every other team keeps its solo control.
static func solo_control(m: Dictionary, tm: Dictionary, side := "") -> String:
	var base := control_of(tm, "solo")
	if side == "" or side == seat_side(m, "solo", "p1"):
		return base
	var c: Variant = tm.get("control", "script")
	if c is Dictionary and (c as Dictionary).has("solo:" + side):
		return String(c["solo:" + side])
	if String(tm.get("side", "")) == side:
		return "p1" if control_of(tm, "versus") in ["p1", "p2"] else base
	if base == "p1":
		return String((c as Dictionary).get("foe", "script")) if c is Dictionary else "script"
	return base


## The side a solo player leads: `side` when the mission lets them pick it, else the default.
static func solo_side(m: Dictionary, side := "") -> String:
	return side if side != "" and solo_sides(m).has(side) else seat_side(m, "solo", "p1")


## The campaign's difficulty ("easy" / "normal" / "hard"), kept in the progress file.
static func difficulty() -> String:
	var d := String(progress().get("difficulty", "normal"))
	return d if DIFFICULTIES.has(d) else "normal"


static func set_difficulty(d: String) -> void:
	if not DIFFICULTIES.has(d):
		return
	var p := progress()
	p["difficulty"] = d
	save_progress(p)


## A mission's multipliers at a difficulty: {"clocks", "spawns"} (the mission's "difficulty": {level: {...}} over
## DIFF_DEFAULT).
static func diff_mult(m: Dictionary, level: String) -> Dictionary:
	var out: Dictionary = (DIFF_DEFAULT.get(level, DIFF_DEFAULT["normal"]) as Dictionary).duplicate()
	var own: Variant = (m["difficulty"] as Dictionary).get(level, {}) if m.get("difficulty") is Dictionary else {}
	if own is Dictionary:
		for k in own:
			out[String(k)] = float(own[k])
	return out


## An objective's words before the match (the BRIEFING): its numbers are not known yet, so "{clock:<name>}" is the
## clock's length at this difficulty (its first "clock" action), a "(... {counter} ...)" aside goes, "{<counter>.of}" is
## its "of" and any other "{<counter>}" its start. (They showed raw, "Dawn in {clock:dawn}", playtest 2026-11-21.)
static func brief_text(m: Dictionary, txt: String) -> String:
	if txt.find("{") < 0:
		return txt
	var mult := float(diff_mult(m, difficulty()).get("clocks", 1.0))
	var re := RegEx.create_from_string("\\{clock:([a-z_0-9]+)\\}")
	for mt in re.search_all(txt):
		var secs := _first_clock(m, mt.get_string(1))
		var rep := "%d:%02d" % [int(secs * mult) / 60, int(secs * mult) % 60] if secs > 0.0 else "..."
		txt = txt.replace(mt.get_string(0), rep)
	var cs: Dictionary = m.get("counters", {})
	txt = RegEx.create_from_string("\\s*\\([^()]*\\{[a-z_0-9]+\\}[^()]*\\)").sub(txt, "", true)
	for cn in cs:
		var of: Variant = cs[cn].get("of", "")
		txt = txt.replace("{%s.of}" % cn, str(int(of)) if (of is float or of is int) else str(of))
		txt = txt.replace("{%s}" % cn, str(int(cs[cn].get("start", 0))))
	return txt


static func _first_clock(v: Variant, name: String) -> float:
	if v is Dictionary:
		var c: Variant = (v as Dictionary).get("clock", null)
		if c is Dictionary and String((c as Dictionary).get("name", "")) == name and (c as Dictionary).has("secs"):
			return float(c["secs"])
		for k in v:
			var f := _first_clock(v[k], name)
			if f > 0.0:
				return f
	elif v is Array:
		for x in v:
			var f := _first_clock(x, name)
			if f > 0.0:
				return f
	return 0.0


## The side a player seat plays in this mode ("p1" / "p2"): the side of its first team ("" none).
static func seat_side(m: Dictionary, mode: String, seat: String, pick := "") -> String:
	for tm in m.get("teams", []):
		if control_of(tm, mode, pick, m) == seat:
			return String(tm["side"])
	return ""


## The match setup Main.start takes: the map, one slot per team (who / faction / colour / side), and "campaign".
## `host_seat`: the seat this machine plays ("p1" normally; online versus the host may take "p2"). `online`: the
## other seat is a friend ("remote"); offline only "p1" teams are yours and a "p2" team falls back to its solo control.
## `side` (solo only): the side the player picked on the briefing (the SOLO SIDE PICK); "" the default.
static func make_cfg(id: String, mode: String, host_seat := "p1", online := false, side := "") -> Dictionary:
	var m := mission(id)
	var slots: Array = []
	if mode == "solo":
		side = solo_side(m, side)
	for tm in m.get("teams", []):
		var ctl := solo_control(m, tm, side) if mode == "solo" else control_of(tm, mode, side, m)
		var slot := {"faction": engine_faction(m, String(tm.get("faction", "crown"))), "colour": int(tm.get("colour", Defs.COLOUR_RANDOM)),
			"side": maxi(0, side_index(m, String(tm["side"]))), "team_id": String(tm["id"])}
		if ctl == host_seat:
			slot["who"] = "you"
		elif ctl == "p1" or ctl == "p2":
			slot["who"] = "remote" if online else "script"
		elif ctl.begins_with("ai"):
			var p := ctl.split(":")
			slot["who"] = p[1] if p.size() > 1 and ["easy", "normal", "hard", "brutal"].has(p[1]) else "normal"
			slot["strategy"] = p[2] if p.size() > 2 else "balanced"
			# (campaign-fixes-1121: a computer foe may play stronger at the campaign's NORMAL / HARD: "ai_by_difficulty":
			# {"normal": "easy", "hard": "normal"}; the owner: the campaign has an AI level, chosen in the hub)
			var abd: Variant = tm.get("ai_by_difficulty", {})
			if abd is Dictionary and (abd as Dictionary).has(difficulty()):
				slot["who"] = String(abd[difficulty()])
		else:
			slot["who"] = "script"
		slots.append(slot)
	var camp := {"mission": id, "mode": mode, "seat": host_seat, "difficulty": difficulty()}
	if mode == "solo":
		camp["side"] = side
	elif mode == "versus" and not versus_picks(m).is_empty():
		camp["pick"] = side if versus_picks(m).has(side) else String(versus_picks(m)[0])      # (the friend's side: the versus pick)
	return {"map": String(m.get("map", "random")), "slots": slots, "campaign": camp}


# ------------------------------------------------------------------ progress

static func progress() -> Dictionary:
	var f := FileAccess.open(PROGRESS, FileAccess.READ)
	if f == null:
		return {"reached": [], "done": {}}
	var d: Variant = JSON.parse_string(f.get_as_text())
	var p: Dictionary = d if d is Dictionary else {}
	if not p.has("reached"):
		p["reached"] = []
	if not p.has("done"):
		p["done"] = {}
	return p


static func save_progress(p: Dictionary) -> void:
	var f := FileAccess.open(PROGRESS, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(p, "\t"))


## Open to play: the first mission of an open storyline, any mission a finished one led to, any mission already
## finished.
static func unlocked(id: String, p: Dictionary = {}) -> bool:
	if p.is_empty():
		p = progress()
	var sl := storyline_of(id)
	if (p["done"] as Dictionary).has(id):
		return true
	# a CROSSING (a07: "needs": [missions]): open only once every one of them is finished, whichever led to it
	var needs: Array = mission(id).get("needs", []) if not sl.is_empty() else []
	if not needs.is_empty():
		return open_all or needs.all(func(n) -> bool: return (p["done"] as Dictionary).has(String(n)))
	if not sl.is_empty() and storyline_open(sl, p) and String((sl["missions"] as Array)[0]) == id:
		return true
	return (p["reached"] as Array).has(id)


## The mission after `id` when `side_id` won it ("" none: not written yet). "next" is {side: id} (the story's branch
## by who won) or one id for every outcome; without it, the next mission of the same storyline. ("" also when the
## story goes on in the storylines this mission opens: `opens`.)
static func next_of(id: String, side_id: String) -> String:
	var m := mission(id)
	if m.has("next"):
		var n: Variant = m["next"]
		if n is Dictionary:
			return String((n as Dictionary).get(side_id, ""))
		return String(n)
	var ids: Array = storyline_of(id).get("missions", [])
	var i := ids.find(id)
	return String(ids[i + 1]) if i >= 0 and i + 1 < ids.size() else ""


## A mission ended: who won (the side id), in which mode, and which side this player played. A win for your side (or
## any end of a versus match: the story follows who won) unlocks the branch it leads to.
static func record(id: String, mode: String, winner_side: String, my_side: String, flags: Dictionary = {}) -> String:
	var p := progress()
	var counts := winner_side != "" and (winner_side == my_side or mode == "versus")
	var nxt := next_of(id, winner_side) if counts else ""
	if counts:
		var done: Dictionary = p["done"]
		var e: Dictionary = done.get(id, {})
		e["won_by"] = winner_side
		e["mode"] = mode
		e["side"] = my_side      # (the side this player led: the Fürth Line's machine player keeps the Machine's City hub)
		e["played"] = int(e.get("played", 0)) + 1
		if not flags.is_empty():
			e["flags"] = flags.duplicate()      # (the story's choices, for the missions after it: flag())
		done[id] = e
		if nxt != "" and not (p["reached"] as Array).has(nxt):
			(p["reached"] as Array).append(nxt)
		save_progress(p)
	return nxt


## A flag a finished mission left (its choices: MissionRun.flags), or null. Later missions read it with the "past"
## condition, e.g. {"past": {"p01_leaf.families": "save"}}.
static func flag(mission_id: String, name: String) -> Variant:
	var e: Dictionary = (progress()["done"] as Dictionary).get(mission_id, {})
	return e.get("flags", {}).get(name, null)


## A mission's OPENING or ENDING (StillShow): its pages [{"still", "lines": [line ids]}] (the ending: for the side that
## won, `side`).
static func show_pages(m: Dictionary, which: String, side := "") -> Array:
	var v: Variant = m.get(which, [])
	if v is Dictionary:
		v = (v as Dictionary).get(side, [])
	return v if v is Array else []


## A mission's OPENING before its match exists: the pages with their conditional lines ({"id", "if"}) decided by what
## can be known from the menu: "past" (the flags of missions played before), "difficulty", "playing" (the side
## picked), and "all" / "any" / "not" of those. (MissionRun.pages_now does it for the shows during and after a match;
## the opening handed StillShow the raw {"id", "if"} dictionaries and its _ready stopped on them: a01, a05, a06 and a07
## opened on stills with no words and no buttons; playtest-campaign-clock.)
static func pages_before(pages: Array, side: String, diff := "") -> Array:
	if diff == "":
		diff = difficulty()
	var out: Array = []
	for pg in pages:
		var ids: Array = []
		for ln in pg.get("lines", []):
			if ln is Dictionary:
				if cond_before(ln.get("if", {}), side, diff):
					ids.append(String(ln.get("id", "")))
			else:
				ids.append(String(ln))
		if ids.is_empty() and not (pg.get("lines", []) as Array).is_empty():
			continue
		var c: Dictionary = (pg as Dictionary).duplicate()
		c["lines"] = ids
		out.append(c)
	return out


static func cond_before(c: Variant, side: String, diff: String) -> bool:
	if not (c is Dictionary):
		return false
	var ok := true
	for k in c:
		var v: Variant = c[k]
		match String(k):
			"all":
				for x in v:
					ok = ok and cond_before(x, side, diff)
			"any":
				var a := false
				for x in v:
					a = a or cond_before(x, side, diff)
				ok = ok and a
			"not":
				ok = ok and not cond_before(v, side, diff)
			"past":
				for fk in v:
					var pr := String(fk).split(".")
					ok = ok and pr.size() == 2 and str(flag(pr[0], pr[1])) == str(v[fk])
			"difficulty":
				ok = ok and (v if v is Array else [v]).map(func(x) -> String: return String(x)).has(diff)
			"playing":
				ok = ok and String(v) == side
			_:
				push_warning("Campaign.cond_before: '%s' can't be decided before the match (taken as false)" % k)
				ok = false
	return ok


# ------------------------------------------------------------------ text

## Every player-facing string of campaign.json: storylines, hubs (hotspots, talks), rooms.
static func index_strings() -> Array:
	var out: Array = [String(index().get("title", ""))]
	for sl in storylines():
		out.append_array([String(sl.get("title", "")), String(sl.get("about", ""))])
		var hub: Dictionary = sl.get("hub", {})
		out.append(String(hub.get("title", "")))
		out.append(String(hub.get("still", {}).get("caption", "")))
		for hs in hub.get("hotspots", []):
			out.append(String(hs.get("label", "")))
		for mid in hub.get("after", {}):
			var af: Dictionary = hub["after"][mid]
			out.append_array([String(af.get("title", "")), String(af.get("about", "")), String(af.get("still", {}).get("caption", ""))])
		for k in hub.get("talks", {}):
			var tk: Dictionary = hub["talks"][k]
			out.append(String(tk.get("name", "")))
			for e in tk.get("entries", []):
				for ln in e.get("lines", []):
					out.append(String(ln))
	for k in index().get("rooms", {}):
		out.append_array([String(index()["rooms"][k].get("title", "")), String(index()["rooms"][k].get("text", ""))])
	return out.filter(func(s: String) -> bool: return s != "")


## Every player-facing string of a mission (the translation check: tools/test_campaign.gd).
static func strings_of(m: Dictionary) -> Array:
	var out: Array = [String(m.get("title", "")), String(m.get("summary", ""))]
	for s in m.get("sides", []):
		out.append(String(s.get("name", "")))
		if s.has("about"):
			out.append(String(s["about"]))
	for o in m.get("objectives", []):
		out.append(String(o.get("text", "")))
		out.append(String(o.get("phone", "")))
	for k in m.get("speakers", {}):
		out.append(String(m["speakers"][k].get("name", "")))
	for k in m.get("lines", {}):
		out.append(String(m["lines"][k].get("text", "")))
		out.append(String(m["lines"][k].get("phone", "")))
	for k in m.get("stills", {}):
		out.append(String(m["stills"][k].get("caption", "")))
	for k in m.get("briefing", {}):
		for t in m["briefing"][k].get("text", []):
			out.append(String(t))
	for k in m.get("debrief", {}):
		out.append(String(m["debrief"][k].get("title", "")))
		out.append(String(m["debrief"][k].get("text", "")))
		out.append(String(m["debrief"][k].get("banner", "")))
		for ti in m["debrief"][k].get("text_if", []):
			out.append(String(ti.get("text", "")))
	for tr in m.get("triggers", []):
		for a in tr.get("do", []):
			if a is Dictionary and a.has("deny") and a["deny"] is Dictionary:
				out.append(String(a["deny"].get("why", "")))          # (the refusal's words while the story holds it back)
			if a is Dictionary and a.has("choice"):
				out.append(String(a["choice"].get("title", "")))
				for o in a["choice"].get("options", []):
					out.append(String(o.get("label", "")))
					out.append(String(o.get("about", "")))
	for x in m.get("learn", []):
		out.append(String(x))          # (a TUTORIAL lesson's list of what it teaches, and its words after a loss)
	out.append(String(m.get("lost", "")))
	return out.filter(func(s: String) -> bool: return s != "")


## What is wrong with a mission's data ([] = nothing): names that point nowhere, unknown kinds, conditions and actions.
## THE ROSTER LADDER (docs/campaign_roster_ladder.md): every piece of a faction a team's roster can name: its units,
## buildings and researches (Defs), and for the Brood the Mother's growth stages as "stage2" / "stage3" (her GROW).
static func roster_items(faction: String) -> Array:
	var out: Array = []
	for d in [Defs.UNITS, Defs.BUILDINGS, Defs.RESEARCH]:
		for k in d:
			if String(d[k].get("faction", "")) == faction:
				out.append(String(k))
	if faction == "brood":
		out.append_array(ROSTER_STAGES)
	return out


const ROSTER_STAGES := ["stage2", "stage3"]


## What a team may not build, train, research (or, the Brood, grow to) in this mission: with an ALLOW-LIST (the
## ladder: "roster": {"allow": [...]}) everything of its faction not on it, plus the roster's "deny" (the story's own
## refusals on top of the ladder). `m` gives the campaign-only factions' stand-ins.
static func roster_denied(m: Dictionary, tm: Dictionary) -> Array:
	var r: Dictionary = tm.get("roster", {})
	var out: Array = []
	if r.has("allow"):
		var allow: Array = r["allow"]
		for k in roster_items(engine_faction(m, String(tm.get("faction", "crown")))):
			if not allow.has(k):
				out.append(k)
	for k in r.get("deny", []):
		if not out.has(String(k)):
			out.append(String(k))
	return out


## A roster name the ladder may use: a unit, building or research, or a Brood growth stage.
static func roster_known(k: String) -> bool:
	return Defs.UNITS.has(k) or Defs.BUILDINGS.has(k) or Defs.RESEARCH.has(k) or ROSTER_STAGES.has(k)


static func problems(m: Dictionary) -> Array:
	var out: Array = []
	if m.is_empty():
		return ["the mission file is missing or not valid JSON"]
	var sides := side_ids(m)
	var teams: Array = (m.get("teams", []) as Array).map(func(t: Dictionary) -> String: return String(t["id"]))
	var areas: Dictionary = m.get("areas", {})
	var lines: Dictionary = m.get("lines", {})
	var objs: Array = (m.get("objectives", []) as Array).map(func(o: Dictionary) -> String: return String(o["id"]))
	var trig: Array = (m.get("triggers", []) as Array).map(func(t: Dictionary) -> String: return String(t.get("id", "")))
	var mp := String(m.get("map", ""))
	if mp.begins_with("campaign:") and map_data(mp.substr(9)).is_empty():
		out.append("map %s: no file campaign/maps/%s.json" % [mp, mp.substr(9)])
	elif not mp.begins_with("campaign:") and not MapData.NAMED.has(mp) and not MapGen.MAPS.has(mp):
		out.append("map %s: unknown" % mp)
	for tm in m.get("teams", []):
		if not sides.has(String(tm.get("side", ""))):
			out.append("team %s: unknown side %s" % [tm["id"], tm.get("side")])
		if not faction_known(m, String(tm.get("faction", "crown"))):
			out.append("team %s: unknown faction" % tm["id"])
		if tm.has("ai_foe") and not teams.has(String(tm["ai_foe"])):
			out.append("team %s: ai_foe names an unknown team %s" % [tm["id"], tm["ai_foe"]])
		if tm.has("camera") and not areas.has(String(tm["camera"])):
			out.append("team %s: unknown camera area %s" % [tm["id"], tm["camera"]])
		for md in modes_of(m):
			var c := control_of(tm, md)
			if not (c in ["p1", "p2", "script"] or c.begins_with("ai")):
				out.append("team %s: unknown control %s" % [tm["id"], c])
	for md in modes_of(m):
		if seat_side(m, md, "p1") == "":
			out.append("mode %s: no team for p1" % md)
		if md != "solo" and seat_side(m, md, "p2") == "":
			out.append("mode %s: no team for p2" % md)
	if m.has("modes") and (m["modes"] as Array).has("versus") and seat_side(m, "versus", "p1") == seat_side(m, "versus", "p2"):
		out.append("versus: p1 and p2 are on the same side")
	# a07: THE VERSUS PICK and a crossing's "needs"
	for sd in m.get("versus_pick", []):
		if not sides.has(String(sd)):
			out.append("versus_pick: unknown side %s" % sd)
		elif not (m.get("teams", []) as Array).any(func(tm: Dictionary) -> bool: return String(tm.get("side", "")) == String(sd) and control_of(tm, "versus") == "p2"):
			out.append("versus_pick: no p2 team on side %s" % sd)
	if m.has("torch_fire") and not (m["torch_fire"] is Dictionary and String(m["torch_fire"].get("tag", "")) != ""):
		out.append("torch_fire: needs the tag of the buildings a torch sets alight")
	for at in m.get("auto_tags", []):
		if not teams.has(String(at.get("team", ""))) or String(at.get("tag", "")) == "" or not Defs.UNITS.has(String(at.get("kind", ""))):
			out.append("auto_tags: needs a known team, a unit kind and a tag")
	for n in m.get("needs", []):
		if mission(String(n)).is_empty():
			out.append("needs: unknown mission %s" % n)
	# the SOLO SIDE PICK, the DIFFICULTY and the MIST (act1-engine0)
	for sd in m.get("solo_sides", []):
		if not sides.has(String(sd)):
			out.append("solo_sides: unknown side %s" % sd)
		elif not (m.get("teams", []) as Array).any(func(tm: Dictionary) -> bool: return String(tm.get("side", "")) == String(sd) and solo_control(m, tm, String(sd)) == "p1"):
			out.append("solo_sides: no team for the player on side %s" % sd)
	if m.has("difficulty"):
		if not (m["difficulty"] is Dictionary):
			out.append("difficulty: must be {level: {clocks, spawns}}")
		else:
			for lv in m["difficulty"]:
				if not DIFFICULTIES.has(String(lv)):
					out.append("difficulty: unknown level %s" % lv)
				elif m["difficulty"][lv] is Dictionary:
					for k in m["difficulty"][lv]:
						if not String(k) in ["clocks", "spawns"]:
							out.append("difficulty %s: unknown multiplier %s" % [lv, k])
	if m.has("mist"):
		_check_mist(m["mist"], "mist", out, sides, teams)
	for list_key in ["units", "buildings"]:
		for it in m.get(list_key, []):
			if not teams.has(String(it.get("team", ""))):
				out.append("%s: unknown team %s" % [list_key, it.get("team")])
			var k := String(it.get("kind", ""))
			if (list_key == "units" and not Defs.UNITS.has(k)) or (list_key == "buildings" and not Defs.BUILDINGS.has(k)):
				out.append("%s: unknown kind %s" % [list_key, k])
			if it.get("at") is String and not areas.has(String(it["at"])):
				out.append("%s: unknown area %s" % [list_key, it["at"]])
			if it.has("as") and String(Rebels.role(String(it["as"])).get("kind", "")) != k:
				out.append("%s: role %s doesn't fit kind %s" % [list_key, it["as"], k])
			if it.has("if"):
				_check_cond(it["if"], list_key, out, sides, teams, areas, objs, trig)
			_check_placed(it, list_key, out, teams)
	for k in lines:
		var ln: Dictionary = lines[k]
		if not (m.get("speakers", {}) as Dictionary).has(String(ln.get("who", ""))):
			out.append("line %s: unknown speaker %s" % [k, ln.get("who")])
		if ln.has("to") and not sides.has(String(ln["to"])):
			out.append("line %s: unknown side %s" % [k, ln["to"]])
		if ln.has("still") and not (m.get("stills", {}) as Dictionary).has(String(ln["still"])):
			out.append("line %s: unknown still %s" % [k, ln["still"]])
	for which in ["opening", "ending"]:
		var all: Array = []
		if m.get(which) is Dictionary:
			for sd in m[which]:
				if not sides.has(String(sd)):
					out.append("%s: unknown side %s" % [which, sd])
				all.append_array(m[which][sd])
		elif m.get(which) is Array:
			all = m[which]
		for pg in all:
			if not (m.get("stills", {}) as Dictionary).has(String(pg.get("still", ""))):
				out.append("%s: unknown still %s" % [which, pg.get("still")])
			for lid in pg.get("lines", []):
				if lid is Dictionary:
					if not lines.has(String(lid.get("id", ""))):
						out.append("%s: unknown line %s" % [which, lid.get("id")])
					_check_cond(lid.get("if", {}), which, out, sides, teams, areas, objs, trig)
				elif not lines.has(String(lid)):
					out.append("%s: unknown line %s" % [which, lid])
	for o in m.get("objectives", []):
		if not sides.has(String(o.get("side", ""))):
			out.append("objective %s: unknown side" % o["id"])
		if not ["survive", "destroy", "protect", "reach", "manual", "countdown", "build", "capture"].has(String(o.get("kind", ""))):
			out.append("objective %s: unknown kind %s" % [o["id"], o.get("kind")])
		if o.has("area") and not areas.has(String(o["area"])):
			out.append("objective %s: unknown area" % o["id"])
		if String(o.get("kind", "")) == "capture" and String(o.get("tag", "")) == "":
			out.append("objective %s: a capture needs a tag" % o["id"])
		if o.has("by") and not sides.has(String(o["by"])):
			out.append("objective %s: unknown side %s" % [o["id"], o["by"]])
	for tr in m.get("triggers", []):
		_check_cond(tr.get("when", {}), "trigger %s" % tr.get("id", "?"), out, sides, teams, areas, objs, trig)
		for a in tr.get("do", []):
			_check_action(a, "trigger %s" % tr.get("id", "?"), out, m, sides, teams, areas, lines, objs)
	for k in m.get("briefing", {}):
		if not sides.has(String(k)):
			out.append("briefing: unknown side %s" % k)
	for k in m.get("debrief", {}):
		if not sides.has(String(k)):
			out.append("debrief: unknown side %s" % k)
		for ti in m["debrief"][k].get("text_if", []):
			_check_cond(ti.get("if", {}), "debrief %s" % k, out, sides, teams, areas, objs, trig)
	var counters: Dictionary = m.get("counters", {})
	for ex in m.get("exits", []):
		if not areas.has(String(ex.get("area", ""))):
			out.append("exit: unknown area %s" % ex.get("area"))
		if ex.has("counter") and not counters.has(String(ex["counter"])):
			out.append("exit: unknown counter %s" % ex["counter"])
		if ex.has("team") and not teams.has(String(ex["team"])):
			out.append("exit: unknown team %s" % ex["team"])
		if ex.get("max") is String and not counters.has(String(ex["max"])):
			out.append("exit: unknown max counter %s" % ex["max"])
		if ex.has("cargo_counter") and not counters.has(String(ex["cargo_counter"])):
			out.append("exit: unknown cargo counter %s" % ex["cargo_counter"])
	for tm in m.get("teams", []):
		for key in ["deny", "allow", "new"]:
			for k in tm.get("roster", {}).get(key, []):
				if not roster_known(String(k)):
					out.append("team %s: roster %s of unknown kind %s" % [tm["id"], key, k])
		for k in tm.get("roster", {}).get("new", []):
			if tm.get("roster", {}).has("allow") and not (tm["roster"]["allow"] as Array).has(k):
				out.append("team %s: roster new %s is not on its allow-list" % [tm["id"], k])
	for o in m.get("objectives", []):
		if String(o.get("kind", "")) == "countdown" and String(o.get("clock", "")) == "":
			out.append("objective %s: a countdown needs a clock" % o["id"])
	return out


## a01's keys on a unit, a building, a spawn or a build: "tags" (a list), "near" (a tag), "disguise" ({"as": team}).
static func _check_placed(it: Dictionary, where: String, out: Array, teams: Array) -> void:
	if it.has("tags") and not (it["tags"] is Array):
		out.append("%s: tags must be a list" % where)
	if it.has("near") and String(it["near"]) == "":
		out.append("%s: near needs a tag" % where)
	if it.has("disguise"):
		if not (it["disguise"] is Dictionary) or not teams.has(String(it["disguise"].get("as", ""))):
			out.append("%s: disguise as an unknown team" % where)


static func _check_cond(c: Variant, where: String, out: Array, sides: Array, teams: Array, areas: Dictionary, objs: Array, trig: Array) -> void:
	if not (c is Dictionary) or (c as Dictionary).is_empty():
		out.append("%s: no condition" % where)
		return
	for k in c:
		match String(k):
			"time", "dead", "hurt", "flag", "past", "clock_out", "clock_left", "counter", "netted", "hp", "awake", "asleep", \
					"captured", "route_done", "unmasked", "disguised":
				pass
			"out":
				# (a07) {"out": side}: that side has lost (more than two sides: the match may go on without it)
				if not sides.has(String(c[k])):
					out.append("%s: unknown side %s" % [where, c[k]])
			"burning":
				# (a07) {"burning": {"tag", "at_least" / "below"}}: buildings of the tag on fire now
				if not (c[k] is Dictionary and c[k].has("tag")):
					out.append("%s: burning needs a tag" % where)
			"cargo":
				# (a05) {"cargo": {"tag": the carts' tag, "at_least" / "below"}}: living carts with a cage on them
				if not (c[k] is Dictionary and c[k].has("tag")):
					out.append("%s: cargo needs a tag" % where)
			# act1-engine0: the difficulty, who is played, STAY, NEAR, SEEN
			"difficulty":
				for lv in (c[k] if c[k] is Array else [c[k]]):
					if not DIFFICULTIES.has(String(lv)):
						out.append("%s: unknown difficulty %s" % [where, lv])
			"playing":
				if not sides.has(String(c[k])):
					out.append("%s: unknown side %s" % [where, c[k]])
			"stay", "near", "seen":
				var q: Variant = c[k]
				if not (q is Dictionary):
					out.append("%s: %s needs {...}" % [where, k])
				else:
					if k == "stay" and not areas.has(String(q.get("area", ""))):
						out.append("%s: stay in unknown area %s" % [where, q.get("area")])
					for sk in ["side", "to_side", "by"]:
						if q.has(sk) and not sides.has(String(q[sk])):
							out.append("%s: unknown side %s" % [where, q[sk]])
					if q.has("team") and not teams.has(String(q["team"])):
						out.append("%s: unknown team %s" % [where, q["team"]])
			# the TUTORIAL's conditions (what the player did: docs/tutorial.md)
			"selected", "camera_moved", "zoomed", "more", "built", "rooted", "crew", "group", "did", "gear_view", \
					"placing", "order", "res", "talked":
				var q: Variant = c[k]
				if q is Dictionary and q.has("kind"):
					for kk in (q["kind"] if q["kind"] is Array else [q["kind"]]):
						if not (String(kk) in ["any", "army"] or Defs.UNITS.has(String(kk)) or Defs.BUILDINGS.has(String(kk))):
							out.append("%s: %s of unknown kind %s" % [where, k, kk])
			"all", "any":
				for s in c[k]:
					_check_cond(s, where, out, sides, teams, areas, objs, trig)
			"not":
				_check_cond(c[k], where, out, sides, teams, areas, objs, trig)
			"count":
				var q: Dictionary = c[k]
				if q.has("area") and not areas.has(String(q["area"])):
					out.append("%s: unknown area %s" % [where, q["area"]])
				if q.has("side") and not sides.has(String(q["side"])):
					out.append("%s: unknown side %s" % [where, q["side"]])
				if q.has("team") and not teams.has(String(q["team"])):
					out.append("%s: unknown team %s" % [where, q["team"]])
			"done", "failed":
				if not objs.has(String(c[k])):
					out.append("%s: unknown objective %s" % [where, c[k]])
			"fired":
				if not trig.has(String(c[k])):
					out.append("%s: unknown trigger %s" % [where, c[k]])
			_:
				out.append("%s: unknown condition %s" % [where, k])


static func _check_action(a: Variant, where: String, out: Array, m: Dictionary, sides: Array, teams: Array, areas: Dictionary, lines: Dictionary, objs: Array) -> void:
	if not (a is Dictionary) or (a as Dictionary).size() != 1:
		out.append("%s: an action must be one {name: value}" % where)
		return
	var k := String((a as Dictionary).keys()[0])
	var v: Variant = a[k]
	match k:
		"say":
			for id in v:
				if not lines.has(String(id)):
					out.append("%s: unknown line %s" % [where, id])
		"spawn", "build":
			if not teams.has(String(v.get("team", ""))):
				out.append("%s: %s for unknown team" % [where, k])
			if v.has("if"):
				_check_cond(v["if"], where, out, sides, teams, areas, objs, (m.get("triggers", []) as Array).map(func(t: Dictionary) -> String: return String(t.get("id", ""))))
			_check_placed(v, where, out, teams)
			if k == "build":
				if not Defs.BUILDINGS.has(String(v.get("kind", ""))):
					out.append("%s: build of unknown kind %s" % [where, v.get("kind")])
				if v.get("at") is String and not areas.has(String(v["at"])):
					out.append("%s: unknown area %s" % [where, v["at"]])
				return
			if v.has("as") and String(Rebels.role(String(v["as"])).get("kind", "")) != String(v.get("kind", "")):
				out.append("%s: role %s doesn't fit kind %s" % [where, v["as"], v.get("kind")])
			if not Defs.UNITS.has(String(v.get("kind", ""))):
				out.append("%s: spawn of unknown kind %s" % [where, v.get("kind")])
			if v.get("at") is String and not areas.has(String(v["at"])):
				out.append("%s: unknown area %s" % [where, v["at"]])
		"order":
			if not ["attack", "move", "hold", "stop", "patrol", "hunt", "root", "uproot", "route", "follow", "heel"].has(String(v.get("do", ""))):
				out.append("%s: unknown order %s" % [where, v.get("do")])
			if String(v.get("do", "")) == "route":
				if (v.get("route", []) as Array).is_empty():
					out.append("%s: a route needs its waypoints" % where)
				for w in v.get("route", []):
					if not areas.has(String(w)):
						out.append("%s: route through unknown area %s" % [where, w])
			if String(v.get("do", "")) == "follow" and String(v.get("leader", "")) == "":
				out.append("%s: follow needs a leader tag" % where)
			if v.has("to") and not areas.has(String(v["to"])):
				out.append("%s: unknown area %s" % [where, v["to"]])
			for ti in v.get("to_if", []):
				if not areas.has(String(ti.get("to", ""))):
					out.append("%s: unknown area %s" % [where, ti.get("to")])
		"objective":
			if not objs.has(String(v.get("id", ""))):
				out.append("%s: unknown objective %s" % [where, v.get("id")])
		"unmask":
			if not (v is Dictionary and v.has("tag")):
				out.append("%s: unmask needs a tag" % where)
		"ping" when v is Dictionary and v.has("tag") and not v.has("area"):
			pass          # (a01: a ping at the first living thing with the tag)
		"reveal", "ping", "camera":
			if not areas.has(String(v.get("area", ""))):
				out.append("%s: unknown area %s" % [where, v.get("area")])
		"give":
			if not teams.has(String(v.get("team", ""))):
				out.append("%s: give to unknown team" % where)
		"win", "lose":
			if not sides.has(String(v)):
				out.append("%s: unknown side %s" % [where, v])
		"mark", "flag", "clock", "counter", "tally", "name":
			pass
		"cart":
			# (a05) {"cart": {"tag": the creatures, "cart": the carts' tag, "freed": counter, "freed_tag", "caged": counter}}
			if not (v is Dictionary and v.has("tag") and v.has("cart")):
				out.append("%s: cart needs a tag and a cart" % where)
			for ck in ["freed", "caged"]:
				if v is Dictionary and v.has(ck) and not (m.get("counters", {}) as Dictionary).has(String(v[ck])):
					out.append("%s: cart: unknown counter %s" % [where, v[ck]])
		"cage", "pin", "carry", "spare", "floor", "heal", "max_hp", "burn", "nest_free", "wind", "remove", "douse":
			if not (v is Dictionary and v.has("tag")):
				out.append("%s: %s needs a tag" % [where, k])
			elif k == "burn" and v.get("spread") is Dictionary and String(v["spread"].get("tag", "")) == "":
				out.append("%s: a spreading fire needs the tag it spreads to" % where)
			elif k == "burn" and v.has("douse_side") and not sides.has(String(v["douse_side"])):
				out.append("%s: burn: unknown douse side %s" % [where, v["douse_side"]])
		"show":
			# (a07) {"show": {"pages": [{"still", "lines"}]}}: a MID-MATCH SHOW
			if not (v is Dictionary) or (v.get("pages", []) as Array).is_empty():
				out.append("%s: a show needs its pages" % where)
			else:
				for pg in v["pages"]:
					if not (m.get("stills", {}) as Dictionary).has(String(pg.get("still", ""))):
						out.append("%s: show: unknown still %s" % [where, pg.get("still")])
					for lid in pg.get("lines", []):
						var li := String(lid.get("id", "")) if lid is Dictionary else String(lid)
						if not lines.has(li):
							out.append("%s: show: unknown line %s" % [where, li])
		"convert":
			if not teams.has(String(v.get("to", ""))):
				out.append("%s: convert to unknown team %s" % [where, v.get("to")])
			if v.has("area") and not areas.has(String(v["area"])):
				out.append("%s: unknown area %s" % [where, v["area"]])
		"unlock", "deny":
			if not teams.has(String(v.get("team", ""))):
				out.append("%s: %s for unknown team" % [where, k])
			for kk in (v["kind"] if v.get("kind") is Array else [v.get("kind", "")]):
				if not roster_known(String(kk)):
					out.append("%s: %s of unknown kind %s" % [where, k, kk])
		"sound":
			var sn := String(v.get("name", ""))
			if not (ResourceLoader.exists("res://assets/audio/%s.wav" % sn) or ResourceLoader.exists("res://assets/audio/%s.ogg" % sn)):
				out.append("%s: unknown sound %s" % [where, sn])
			if v.has("area") and not areas.has(String(v["area"])):
				out.append("%s: unknown area %s" % [where, v["area"]])
		"sleep", "wake":
			if not (v is Dictionary) or not (v.has("tag") or v.has("team") or v.has("side") or v.has("name")):
				out.append("%s: %s needs a tag, team, side or name" % [where, k])
			elif v.has("team") and not teams.has(String(v["team"])):
				out.append("%s: %s of unknown team %s" % [where, k, v["team"]])
			elif (v.has("side") and not sides.has(String(v["side"]))) or (v.has("by") and not sides.has(String(v["by"]))):
				out.append("%s: %s with an unknown side" % [where, k])
		"mist":
			_check_mist(v, where, out, sides, teams)
		"weather":
			if not ["snow", "rain", "mist", ""].has(String(v)):
				out.append("%s: unknown weather %s" % [where, v])
		"hurt":
			if not (v is Dictionary and v.has("tag")):
				out.append("%s: hurt needs a tag" % where)
		"light":
			var to := String(v.get("to", "")) if v is Dictionary else String(v)
			if not MissionRun.LIGHTS.has(to):
				out.append("%s: unknown light %s" % [where, to])
		"choice":
			if not (v is Dictionary) or String(v.get("id", "")) == "" or (v.get("options", []) as Array).is_empty():
				out.append("%s: a choice needs an id and options" % where)
			elif v.has("line") and not lines.has(String(v["line"])):
				out.append("%s: choice line %s unknown" % [where, v["line"]])
			elif v.has("side") and not sides.has(String(v["side"])):
				out.append("%s: choice for unknown side %s" % [where, v["side"]])
			else:
				for o in v["options"]:
					for a2 in o.get("do", []):
						_check_action(a2, where + " (choice %s)" % o.get("id", "?"), out, m, sides, teams, areas, lines, objs)
		"point":
			if v is Dictionary and v.has("area") and not areas.has(String(v["area"])):
				out.append("%s: point at unknown area %s" % [where, v["area"]])
			if v is Dictionary and v.has("ui") and not ["minimap", "card", "hotbar", "top", "groups", "objectives"].has(String(v["ui"])):
				out.append("%s: point at unknown ui %s" % [where, v["ui"]])
			if v is Dictionary and v.has("kind") and not (Defs.UNITS.has(String(v["kind"])) or Defs.BUILDINGS.has(String(v["kind"]))):
				out.append("%s: point at unknown kind %s" % [where, v["kind"]])
		_:
			out.append("%s: unknown action %s" % [where, k])


static func _check_mist(v: Variant, where: String, out: Array, sides: Array, teams: Array) -> void:
	if not (v is Dictionary) or not v.has("sight"):
		out.append("%s: mist needs {\"sight\": share}" % where)
		return
	if v.has("side") and not sides.has(String(v["side"])):
		out.append("%s: mist on unknown side %s" % [where, v["side"]])
	if v.has("team") and not teams.has(String(v["team"])):
		out.append("%s: mist on unknown team %s" % [where, v["team"]])
