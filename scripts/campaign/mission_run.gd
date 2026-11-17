class_name MissionRun
extends Node
## A campaign mission being played (docs/campaign_engine.md): made by Main.start from the mission's data and put on
## the Game (game.mission) before the map is built. It places the teams' starting units and buildings
## (Game._start_positions asks it), keeps the tagged units and buildings, runs the triggers, checks the objectives
## and decides who won (Game._check_end leaves the end to it). Online, the host's runs everything and sends what the
## friend must see (lines, objectives, reveals, pings: "camp" messages); a guest's (`remote`) only shows them.

signal said(line: Dictionary)        # a line of dialogue for this screen: {"id", "who", "name", "side", "text", "still"}
signal objectives_changed
signal pointer_changed               # the TUTORIAL's pointer moved (MissionUi draws it): `pointer`
signal choice_offered(ch: Dictionary) # a CHOICE for this screen's player (MissionUi shows its buttons): the "choice" action

const TICK := 0.25                   # seconds between trigger and objective checks
const SYNC_EVERY := 2.0              # host: the objectives are sent to the guests again this often (a lost message heals)

var game: Game
var data: Dictionary = {}
var id := ""
var mode := "solo"
var remote := false                  # online guest: the host runs the triggers
var team_ids: Array = []             # team index -> the mission's team id
var player_teams := {}               # team index -> true: a person plays it (never given scripted orders)
var tags := {}                       # tag -> [Entity, ...] (dead ones stay: "all dead" needs them)
var obj := {}                        # objective id -> "hidden" | "active" | "done" | "failed"
var fired := {}                      # trigger id -> game clock when it fired
var _met := {}                       # trigger id -> game clock its condition first held (for "delay")
var reveals: Array = []              # [side index, cell, radius, until (game clock)]
var said_ids: Array = []             # every line said so far, in order (tests, the match log)
var winner_side := ""
var _side_had := {}                  # side id -> true once it had a unit or a building
var _t := 0.0
var _sync_t := 0.0
# the TUTORIAL (docs/tutorial.md): what the player did since the step began ("mark": the camera, the counts, the notes)
var pointer := {}                    # where the teacher points: {"area"}, {"tag"}, {"kind"}, {"ui"} ({} none)
var noted := {}                      # action name -> times since the mark: "minimap", "group_set", "group_select", "hotkey"
var talk_busy := false               # MissionUi: a line is still being read (the "talked" condition waits for it)
var _cam0 := Vector2.ZERO
var _zoom0 := Vector2.ONE
var _base := {}                      # kind -> how many the player had at the mark (the "more" condition)
# the story's CHOICES and FLAGS (campaign-m1): flags are kept with the mission's progress (Campaign.record) for later
# missions ("past" condition); a choice offered and not yet answered waits in `choice_open`
var flags := {}                      # name -> value (a choice's answer: its option id)
var choice_open := {}                # the choice on offer ({} none): its data plus "until" (game clock: then the default)
var light_node: CanvasModulate = null
var light_name := "day"
# the Clockwork prologue's engine (clockwork-prologue-build, docs/campaign_c01_build.md): COUNTERS (townsfolk saved,
# seeds burnt), CLOCKS (a countdown the triggers read: the city strikes thirteen), REPEATING triggers ("every"), units
# that CHANGE SIDES after a warning (`convert`), a ROSTER per team (what it may not build or train; `unlock`)
var counters := {}                   # name -> int (data "counters": {name: {"start", "of"}})
var clocks := {}                     # name -> the game clock it runs out at
var deny := {}                       # team index -> {kind: true}: not in this mission (a team's "roster": {"deny": [kinds]})
var _next := {}                      # a repeating trigger's id -> the game clock it may fire again
var _times := {}                     # trigger id -> how often it has fired
var _turning: Array = []             # [unit, team index, game clock it changes side, tag]: `convert` waiting out its warning
var weather_node: Node = null
# the Brood prologue's engine (brood-prologue-build, docs/campaign_b01_build.md): units held by the story (`cage`: in
# place and harmless; `spare`: untouchable), buildings set ALIGHT (`burn`), a health FLOOR, scripted ROOT / UPROOT
var _caged: Array = []               # [unit, the spot it is kept at]
var _burning: Array = []             # [building, health a second it loses]


func setup(m: Dictionary, md: String, cfg: Dictionary, guest := false) -> void:
	data = m
	id = String(m.get("id", ""))
	mode = md
	remote = guest
	team_ids = (m.get("teams", []) as Array).map(func(t: Dictionary) -> String: return String(t["id"]))
	var slots: Array = cfg.get("slots", [])
	for i in slots.size():
		if String(slots[i].get("who", "")) in ["you", "remote"]:
			player_teams[i] = true
	for o in m.get("objectives", []):
		obj[String(o["id"])] = "hidden" if bool(o.get("hidden", false)) else "active"
	for cn in m.get("counters", {}):
		counters[String(cn)] = int(m["counters"][cn].get("start", 0))
	for i in team_ids.size():
		for k in team_data(i).get("roster", {}).get("deny", []):
			if not deny.has(i):
				deny[i] = {}
			deny[i][String(k)] = true


# ------------------------------------------------------------------ lookups

func team_data(t: int) -> Dictionary:
	return data["teams"][t] if t >= 0 and t < (data["teams"] as Array).size() else {}


func team_index(team_id: String) -> int:
	return team_ids.find(team_id)


func side_of_team(t: int) -> String:
	return String(team_data(t).get("side", ""))


func teams_of_side(side_id: String) -> Array:
	var out: Array = []
	for t in team_ids.size():
		if side_of_team(t) == side_id:
			out.append(t)
	return out


func my_side() -> String:
	return side_of_team(game.human)


func area_rect(name: String) -> Rect2:
	var a: Array = data.get("areas", {}).get(name, [0, 0, 1, 1])
	return Rect2(float(a[0]) * Defs.TILE, float(a[1]) * Defs.TILE, float(a[2]) * Defs.TILE, float(a[3]) * Defs.TILE)


func _where(at: Variant) -> Rect2:
	if at is Array:
		return Rect2(float(at[0]) * Defs.TILE, float(at[1]) * Defs.TILE, Defs.TILE, Defs.TILE)
	return area_rect(String(at))


func _in_mode(it: Dictionary) -> bool:
	return not it.has("modes") or (it["modes"] as Array).has(mode)


func objective(oid: String) -> Dictionary:
	for o in data.get("objectives", []):
		if String(o["id"]) == oid:
			return o
	return {}


## The objectives a side sees, in order: [{data..., "state"}] (hidden ones left out).
func objectives_for(side_id: String) -> Array:
	var out: Array = []
	for o in data.get("objectives", []):
		var st := String(obj.get(String(o["id"]), "hidden"))
		if String(o.get("side", "")) == side_id and st != "hidden":
			var c: Dictionary = o.duplicate()
			c["state"] = st
			if c.has("phone") and not Settings.pc():
				c["text"] = c["phone"]
			out.append(c)
	return out


func line(lid: String) -> Dictionary:
	var ln: Dictionary = data.get("lines", {}).get(lid, {})
	if ln.is_empty():
		return {}
	var who := String(ln.get("who", ""))
	var sp: Dictionary = data.get("speakers", {}).get(who, {})
	var txt := String(ln.get("text", ""))
	if ln.has("phone") and not Settings.pc():
		txt = String(ln["phone"])          # (a line with its own words for a phone: the controls differ)
	return {"id": lid, "who": who, "name": String(sp.get("name", who)), "side": String(sp.get("side", "")),
		"portrait": String(sp.get("portrait", "")), "text": txt, "still": String(ln.get("still", "")),
		"to": String(ln.get("to", ""))}


func still(sid: String) -> Dictionary:
	return data.get("stills", {}).get(sid, {})


# ------------------------------------------------------------------ the start (host; Game._start_positions)

## Before the starting layout: each team with a "hall" gets that spot as its start.
func before_start() -> void:
	for t in team_ids.size():
		var tm := team_data(t)
		if tm.has("hall") and t < game.starts.size():
			game.starts[t] = Vector2i(int(tm["hall"][0]), int(tm["hall"][1]))
		elif tm.has("camera") and t < game.starts.size():
			game.starts[t] = game.cell_of(area_rect(String(tm["camera"])).get_center())


## Does this team get the normal start (hall, economy building, workers)?
func standard_start(t: int) -> bool:
	return String(team_data(t).get("start", "standard")) == "standard"


## After the starting layout: the mission's units and buildings, resources, the hall's tag.
func after_start() -> void:
	for t in team_ids.size():
		var tm := team_data(t)
		if tm.has("hall_tag"):
			for b in game.buildings:
				if b.team == t and b.kind == game.faction_hall(t):
					_tag(String(tm["hall_tag"]), b)
		if not standard_start(t):
			game.players[t]["gold"] = 0
			game.players[t]["res2"] = float(Defs.START_POWDER) if game.factions[t] == "crown" else 0.0
		if tm.has("gold"):
			game.players[t]["gold"] = int(tm["gold"])
		if tm.has("powder"):
			game.players[t]["res2"] = float(tm["powder"])
	for b in data.get("buildings", []):
		if _in_mode(b):
			_place_building(b)
	for u in data.get("units", []):
		if _in_mode(u):
			_spawn(u)
	for t in team_ids.size():
		game._recount_supply(t)


func _place_building(it: Dictionary) -> Building:
	var t := team_index(String(it["team"]))
	var k := String(it["kind"])
	if t < 0 or not Defs.BUILDINGS.has(k):
		return null
	var size: Vector2i = Defs.BUILDINGS[k]["size"]
	var c := Vector2i(-1, -1)
	if it.get("at") is Array:
		c = Vector2i(int(it["at"][0]), int(it["at"][1]))
	else:
		c = _free_spot(area_rect(String(it.get("at", ""))), size)
	if c.x < 0:
		push_warning("mission %s: no room for a %s" % [id, k])
		return null
	var site := bool(it.get("site", false))
	var b := game._add_building(k, t, c, not site)
	if not site:
		game.on_building_complete(b)      # ("site": a building site, paid for, the team's workers build it)
	if it.has("tag"):
		_tag(String(it["tag"]), b)
	return b


## A footprint of `size` in the area, nearest its middle, on level free ground with a free cell all round.
func _free_spot(r: Rect2, size: Vector2i) -> Vector2i:
	var c0 := game.cell_of(r.position)
	var c1 := game.cell_of(r.end - Vector2(1, 1))
	var mid := r.get_center() / Defs.TILE
	var best := Vector2i(-1, -1)
	var bd := INF
	for y in range(c0.y, c1.y - size.y + 2):
		for x in range(c0.x, c1.x - size.x + 2):
			var d := (Vector2(x, y) + Vector2(size) * 0.5).distance_squared_to(mid)
			if d >= bd:
				continue
			if _footprint_ok(Vector2i(x, y), size):
				bd = d
				best = Vector2i(x, y)
	return best


func _footprint_ok(c: Vector2i, size: Vector2i) -> bool:
	var h := -1
	for y in range(-1, size.y + 1):
		for x in range(-1, size.x + 1):
			var cc := c + Vector2i(x, y)
			if not game.in_map(cc) or not game._walkable(cc) or game.solid[game.idx(cc)] != 0 or game.ramp[game.idx(cc)] == 1:
				return false
			var hh: int = game.height[game.idx(cc)]
			if h < 0:
				h = hh
			elif hh != h:
				return false
	return true


## Units of a kind for a team in an area (a "units" entry or a "spawn" action): spread over its free cells.
func _spawn(it: Dictionary) -> Array:
	var t := team_index(String(it.get("team", "")))
	var k := String(it.get("kind", ""))
	var out: Array = []
	if t < 0 or not Defs.UNITS.has(k):
		return out
	var n := int(it.get("count", 1))
	var spots := _spots(_where(it.get("at", [0, 0])), n)
	for i in n:
		var u := game._add_unit(k, t, spots[i % spots.size()])
		if it.has("tag"):
			_tag(String(it["tag"]), u)
		if it.has("as"):
			Rebels.apply(u, String(it["as"]))       # (a rebel's role: its art, name, torch: scripts/campaign/rebels.gd)
		if it.has("name"):
			u.set_meta("mission_name", String(it["name"]))
		out.append(u)
	var ord: Variant = it.get("order", null)
	if ord is String:
		_order(out, {"do": ord})
	elif ord is Dictionary:
		_order(out, ord)
	return out


## `n` places in a rectangle, a cell apart, nearest its middle first (walkable ground; its middle if none).
func _spots(r: Rect2, n: int) -> Array:
	var cells: Array = []
	var c0 := game.cell_of(r.position)
	var c1 := game.cell_of(r.end - Vector2(1, 1))
	for y in range(c0.y, c1.y + 1):
		for x in range(c0.x, c1.x + 1):
			var c := Vector2i(x, y)
			if game._walkable(c) and game.solid[game.idx(c)] == 0:
				cells.append(c)
	var mid := r.get_center()
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return game.cell_center(a).distance_squared_to(mid) < game.cell_center(b).distance_squared_to(mid))
	var out: Array = []
	for c in cells:
		if (c.x + c.y) % 2 == 0 or cells.size() < n * 2:
			out.append(game.cell_center(c))
			if out.size() >= n:
				break
	if out.is_empty():
		out.append(mid)
	return out


func _tag(tag: String, e: Entity) -> void:
	if not tags.has(tag):
		tags[tag] = []
	tags[tag].append(e)
	e.set_meta("mission_tag", tag)


func tagged(tag: String, alive_only := true) -> Array:
	var out: Array = []
	for e in tags.get(tag, []):
		if is_instance_valid(e) and (not alive_only or not e.dead):
			out.append(e)
	return out


# ------------------------------------------------------------------ the match

func _ready() -> void:
	# the camera starts on this player's team's "camera" area
	var tm := team_data(game.human)
	if tm.has("camera") and game.camera:
		game.camera.position = area_rect(String(tm["camera"])).get_center()
	if data.has("light"):
		set_light(String(data["light"]), 0.0)      # (the scene's light at the start: "night", "dawn", "day")
	if String(data.get("weather", "")) in ["snow", "rain"]:
		set_weather(String(data["weather"]))
	if data.has("floor") and game.ground:
		# THE FLOOR's tint (the Brood prologue: the jungle floor darkened so the green pack reads on it)
		var f: Array = data["floor"]
		game.ground.modulate = Color(float(f[0]), float(f[1]), float(f[2]))


func _process(_delta: float) -> void:
	# (a torch's flame flickers: the few torch-bearers redraw every frame)
	if game == null:
		return
	for u in game.units:
		if not u.dead and u.has_meta("torch"):
			u.queue_redraw()


func _physics_process(delta: float) -> void:
	if game == null or remote or game.over or get_tree().paused:
		return
	_t -= delta
	if _t > 0.0:
		return
	_t = TICK
	Rebels.tick(self, TICK)
	_tick_turning()
	_tick_exits()
	_tick_held()
	if not choice_open.is_empty() and game.clock >= float(choice_open.get("until", INF)):
		choose(String(choice_open["id"]), String(choice_open.get("default", "")))      # (nobody answered: the default)
	_run_triggers()
	_check_objectives()
	_sync_t -= TICK
	if _sync_t <= 0.0:
		_sync_t = SYNC_EVERY
		_send({"k": "obj", "o": obj.duplicate(), "c": counters.duplicate(), "cl": clocks.duplicate()})


func _run_triggers() -> void:
	for tr in data.get("triggers", []):
		var tid := String(tr.get("id", ""))
		if not _in_mode(tr):
			continue
		if fired.has(tid):
			# a REPEATING trigger ("every": seconds, "times": at most): again while its condition ("while", else
			# "when") holds
			if not tr.has("every") or game.clock < float(_next.get(tid, INF)):
				continue
			if tr.has("times") and int(_times.get(tid, 0)) >= int(tr["times"]):
				continue
			if not cond(tr.get("while", tr.get("when", {}))):
				continue
			fire(tr)
			if game.over:
				return
			continue
		if not _met.has(tid):
			if not cond(tr.get("when", {})):
				continue
			_met[tid] = game.clock
		if game.clock - float(_met[tid]) < float(tr.get("delay", 0.0)):
			continue
		fire(tr)
		if game.over:
			return


## Run a trigger's actions now (tests call it directly too).
func fire(tr: Dictionary) -> void:
	var tid := String(tr.get("id", ""))
	fired[tid] = game.clock
	_times[tid] = int(_times.get(tid, 0)) + 1
	if tr.has("every"):
		_next[tid] = game.clock + maxf(float(tr["every"]), TICK)
	if game.mlog:
		game.mlog.add("(mission) trigger %s" % tr.get("id", ""))
	for a in tr.get("do", []):
		act(a)


## Is a condition true now? (docs/campaign_engine.md lists them.)
func cond(c: Variant) -> bool:
	if not (c is Dictionary):
		return false
	for k in c:
		var v: Variant = c[k]
		var ok := true
		match String(k):
			"time":
				ok = game.clock >= float(v)
			"dead":
				ok = tags.has(String(v)) and tagged(String(v)).is_empty()
			"hurt":
				ok = false
				for e in tagged(String(v), false):
					if e.dead or e.hp < e.max_hp:
						ok = true
			"count":
				var q: Dictionary = v
				var n := count(q)
				ok = (not q.has("at_least") or n >= int(q["at_least"])) and (not q.has("below") or n < int(q["below"]))
			"done":
				ok = obj.get(String(v), "") == "done"
			"failed":
				ok = obj.get(String(v), "") == "failed"
			"fired":
				ok = fired.has(String(v))
			"all":
				for s in v:
					ok = ok and cond(s)
			"any":
				ok = false
				for s in v:
					ok = ok or cond(s)
			"not":
				ok = not cond(v)
			"flag":
				# {"flag": {"name": value}}: this mission's flags (a choice's answer)
				for fk in v:
					ok = ok and flags.has(String(fk)) and str(flags[String(fk)]) == str(v[fk])
			"past":
				# {"past": {"<mission>.<flag>": value}}: a flag kept from a mission played before (Campaign.flag)
				for fk in v:
					var pr := String(fk).split(".")
					ok = ok and pr.size() == 2 and str(Campaign.flag(pr[0], pr[1])) == str(v[fk])
			"counter":
				# {"counter": {"name", "at_least", "below"}}: a mission number (townsfolk saved, seeds burnt)
				var n := int(counters.get(String(v.get("name", "")), 0))
				ok = (not v.has("at_least") or n >= int(v["at_least"])) and (not v.has("below") or n < int(v["below"]))
			"hp":
				# {"hp": {"tag", "below": share}}: one of them has less than that share of its health (the Sire hurt)
				ok = false
				for e in tagged(String(v.get("tag", ""))):
					if e.hp < e.max_hp * float(v.get("below", 0.5)):
						ok = true
			"rooted" when v is Dictionary and v.has("tag"):
				# {"rooted": {"tag"}}: one of them is rooted now (the Sire by the pen, the turtle at the creek)
				ok = tagged(String(v["tag"])).any(func(e) -> bool: return e is Unit and BroodNew.rooted(e))
			"netted":
				# {"netted": {"team"}}: one of that team's units is caught in a net now (a Netter's catch)
				var t := team_index(String(v.get("team", "")))
				ok = false
				for u in game.units:
					if u.team == t and not u.dead and u.net_t > 0.0:
						ok = true
						break
			"clock_out":
				# {"clock_out": name}: that countdown has run out (it was started and its time has come)
				ok = clocks.has(String(v)) and game.clock >= float(clocks[String(v)])
			"clock_left":
				# {"clock_left": {"name", "below": s}}: that countdown is running and has less than s seconds left
				var cn := String(v.get("name", ""))
				ok = clocks.has(cn) and float(clocks[cn]) - game.clock < float(v.get("below", 0.0)) and game.clock < float(clocks[cn])
			"selected", "camera_moved", "zoomed", "more", "built", "rooted", "crew", "group", "did", "gear_view", \
					"placing", "order", "res", "talked":
				ok = _tutorial_cond(String(k), v)
			_:
				ok = false
		if not ok:
			return false
	return true


## How many living units (horses not counted) match: of a "tag", a "team" or a "side", inside an "area" if given;
## "buildings": true counts their buildings too.
func count(q: Dictionary) -> int:
	var area := area_rect(String(q["area"])) if q.has("area") else Rect2()
	var list: Array = []
	if q.has("tag"):
		list = tagged(String(q["tag"]))
	else:
		var teams: Array = []
		if q.has("team"):
			teams = [team_index(String(q["team"]))]
		elif bool(q.get("mine", false)):
			teams = [game.human]
		elif q.has("side"):
			teams = teams_of_side(String(q["side"]))
		for u in game.units:
			if not u.dead and teams.has(u.team) and u.kind != "horse":
				list.append(u)
		if bool(q.get("buildings", false)):
			for b in game.buildings:
				if not b.dead and not b.ghost and teams.has(b.team):
					list.append(b)
	var kinds: Array = (q["kind"] if q["kind"] is Array else [q["kind"]]) if q.has("kind") else []
	var n := 0
	for e in list:
		if q.has("area") and not area.has_point(e.position if e is Unit else e.center()):
			continue
		if not kinds.is_empty() and not kinds.has(e.kind):
			continue
		n += 1
	return n


## Carry out one action ({name: value}; docs/campaign_engine.md lists them).
func act(a: Dictionary) -> void:
	for k in a:
		var v: Variant = a[k]
		match String(k):
			"say":
				say(v if v is Array else [v])
			"spawn":
				_spawn(v)
			"order":
				var us: Array = []
				if v.has("tag"):
					us = tagged(String(v["tag"]))
				elif v.has("team"):
					var t := team_index(String(v["team"]))
					us = game.units.filter(func(u) -> bool: return u.team == t and not u.dead)
				_order(us.filter(func(e) -> bool: return e is Unit), v)
			"objective":
				set_objective(String(v["id"]), String(v.get("set", "active")))
			"reveal":
				var r := area_rect(String(v["area"]))
				var si := Campaign.side_index(data, String(v.get("side", my_side())))
				var rad := int(ceil(maxf(r.size.x, r.size.y) / Defs.TILE * 0.5)) + 1
				var until := game.clock + float(v.get("secs", 1e9))
				reveals.append([si, game.cell_of(r.get_center()), rad, until])
				game._vis_t = 0.0
				_send({"k": "reveal", "r": [si, game.cell_of(r.get_center()), rad, until]})
			"ping":
				var p := area_rect(String(v["area"])).get_center()
				game._ping(p, Color(1, 0.85, 0.3))
				_send({"k": "ping", "p": p})
			"camera":
				var side := String(v.get("side", ""))
				if side == "" or side == my_side():
					game.camera.position = area_rect(String(v["area"])).get_center()
				_send({"k": "cam", "p": area_rect(String(v["area"])).get_center(), "s": side})
			"give":
				var t := team_index(String(v["team"]))
				if t >= 0:
					game.players[t]["gold"] = int(game.players[t]["gold"]) + int(v.get("gold", 0))
					game.players[t]["res2"] = float(game.players[t]["res2"]) + float(v.get("powder", 0))
					if v.has("tension"):
						game.add_tension(t, float(v["tension"]))
			"mark":
				mark()
			"point":
				pointer = v if v is Dictionary else {}
				pointer_changed.emit()
			"build":
				_place_building(v)
			"hurt":
				# {"hurt": {"tag", "amount"}}: damage to everything with the tag (a farm set alight by the story)
				for e in tagged(String(v.get("tag", ""))):
					e.take_damage(float(v.get("amount", 100.0)), null)
			"flag":
				for fk in v:
					flags[String(fk)] = v[fk]
			"choice":
				offer_choice(v)
			"light":
				var lv: Dictionary = v if v is Dictionary else {"to": String(v)}
				set_light(String(lv.get("to", "day")), float(lv.get("secs", 0.0)))
				_send({"k": "light", "to": String(lv.get("to", "day")), "secs": float(lv.get("secs", 0.0))})
			"win":
				finish(String(v))
			"lose":
				finish(_other_side(String(v)))
			"counter":
				# {"counter": {"name", "add" or "set"}}
				var cn := String(v.get("name", ""))
				if v.has("count"):
					# (set from a count, or added with "plus": the people at the station when it falls)
					counters[cn] = (int(counters.get(cn, 0)) if bool(v.get("plus", false)) else 0) + count(v["count"])
				else:
					counters[cn] = int(v["set"]) if v.has("set") else int(counters.get(cn, 0)) + int(v.get("add", 1))
				objectives_changed.emit()
				_send({"k": "cnt", "c": counters.duplicate()})
			"clock":
				# {"clock": {"name", "secs"}} starts a countdown; {"name", "add": s} moves it (later +, sooner -);
				# {"name", "stop": true} stops it
				var cn := String(v.get("name", ""))
				if bool(v.get("stop", false)):
					clocks.erase(cn)
				elif v.has("secs"):
					clocks[cn] = game.clock + float(v["secs"])
				elif clocks.has(cn):
					clocks[cn] = maxf(game.clock, float(clocks[cn]) + float(v.get("add", 0.0)))
				objectives_changed.emit()
				_send({"k": "clk", "cl": clocks.duplicate()})
			"convert":
				convert_tag(v)
			"sound":
				# {"sound": {"name": a sound (Sfx: assets/audio/<name>), "area": where (none: everywhere), "vol"}}
				play_sound(String(v.get("name", "")), String(v.get("area", "")), float(v.get("vol", 0.0)))
			"unlock", "deny":
				# {"unlock": {"team", "kind"}}: the team may build / train it again; "deny" takes it away
				var t := team_index(String(v.get("team", "")))
				for kk in (v["kind"] if v.get("kind") is Array else [v.get("kind", "")]):
					if k == "deny":
						if not deny.has(t):
							deny[t] = {}
						deny[t][String(kk)] = true
					elif deny.has(t):
						(deny[t] as Dictionary).erase(String(kk))
			"name":
				# {"name": {"tag", "name"}}: the name over their bars (Jakob carrying the drawings)
				for e in tagged(String(v.get("tag", ""))):
					e.set_meta("mission_name", String(v.get("name", "")))
					e.queue_redraw()
			"tally":
				# {"tally": {"flag", "counter", "bands": [[at least, value], ...]}}: a flag from a counter (saved: few /
				# some / many); the number itself is kept as "<flag>_n"
				var n := int(counters.get(String(v.get("counter", "")), 0))
				var val: Variant = null
				for bd in v.get("bands", []):
					if n >= int(bd[0]):
						val = bd[1]
				flags[String(v.get("flag", ""))] = val
				flags[String(v.get("flag", "")) + "_n"] = n
			"weather":
				set_weather(String(v))
				_send({"k": "wx", "w": String(v)})
			"cage", "pin", "carry", "spare":
				hold(String(k), v)
			"floor":
				# {"floor": {"tag", "share"}}: their health never goes under that share (0: no floor)
				for e in tagged(String(v.get("tag", ""))):
					e.hp_floor = e.max_hp * float(v.get("share", 0.0))
			"heal":
				# {"heal": {"tag", "share"}}: their health back up to that share at least
				for e in tagged(String(v.get("tag", ""))):
					e.hp = maxf(e.hp, e.max_hp * float(v.get("share", 1.0)))
			"burn":
				# {"burn": {"tag", "secs"}}: buildings set alight burn down in about that time (fire on them)
				for e in tagged(String(v.get("tag", ""))):
					if e is Building and not _burning.any(func(it) -> bool: return it[0] == e):
						_burning.append([e, e.max_hp / maxf(float(v.get("secs", 60.0)), 1.0)])


## Scripted orders go only to units no person plays (a co-op friend's or versus foe's units are theirs).
func _order(us: Array, v: Dictionary) -> void:
	us = us.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead and not player_teams.has(u.team))
	if us.is_empty():
		return
	var p: Vector2 = area_rect(String(v["to"])).get_center() if v.has("to") else Vector2.INF
	match String(v.get("do", "")):
		"attack":
			game.group_move(us, p, true)
		"move":
			game.group_move(us, p, false)
		"hold":
			for u in us:
				u.cmd_hold()
		"stop":
			for u in us:
				u.cmd_stop()
		"patrol":
			for u in us:
				u.cmd_patrol(p)
		"root":
			# {"do": "root", "to": area}: a Brood creature walks there and roots (the Mound Turtle at the creek's mouth, the
			# Sire by her pen: a father may nest by a Mother who is not his side's)
			for u in us:
				if BroodNew.ROOTERS.has(u.kind) and u.tesla_mode == "packed":
					u.set_meta("mission_root", true)
					BroodRoot.start_root(u, p)
		"uproot":
			for u in us:
				if u.tesla_mode == "deployed":
					BroodNew.uproot(u, false)
		"hunt":
			# {"do": "hunt", "prey": a tag, "within": tiles}: each idle or walking unit goes for the nearest living unit
			# with that tag within reach (the machine going after the townsfolk in the streets)
			var prey := tagged(String(v.get("prey", "")))
			if v.has("spare"):
				var safe := area_rect(String(v["spare"]))      # (prey inside this area is left alone: under the gate's guns)
				prey = prey.filter(func(e) -> bool: return not safe.has_point(e.position))
			var reach := float(v.get("within", 12)) * Defs.TILE
			for u in us:
				if u.target != null and is_instance_valid(u.target) and not u.target.dead and prey.has(u.target):
					continue
				var best: Entity = null
				var bd := reach
				for e in prey:
					var dd: float = u.position.distance_to(e.position)
					if dd < bd:
						bd = dd
						best = e
				if best:
					u.cmd_attack(best)


## THE LIGHT (campaign-m1): the scene tinted for the time of day ("night" blue and dim, "dawn" warm, "day" as
## painted), over `secs` seconds. A CanvasModulate on the Game: the world only, never the HUD.
const LIGHTS := {"night": Color(0.40, 0.45, 0.66), "dusk": Color(0.78, 0.66, 0.70), "dawn": Color(1.0, 0.83, 0.70), "day": Color(1, 1, 1),
	# WINTER (the Clockwork prologue, Advent in Nuremberg): a cold day, a short violet dusk, a deep blue night lit by fires
	"winter_day": Color(0.88, 0.93, 1.04), "winter_dusk": Color(0.66, 0.62, 0.80), "winter_night": Color(0.36, 0.42, 0.66),
	# THE AMAZON (the Brood prologue): a heavy humid afternoon, a rainy dusk, the rain at night, the night lit by the burning
	# station, the grey before dawn
	"jungle_day": Color(0.96, 0.95, 0.84), "jungle_dusk": Color(0.74, 0.62, 0.62), "jungle_night": Color(0.42, 0.48, 0.62),
	"fire_night": Color(0.62, 0.46, 0.42), "grey_dawn": Color(0.66, 0.68, 0.74)}


func set_light(to: String, secs: float) -> void:
	light_name = to
	if game == null:
		return
	if light_node == null:
		light_node = CanvasModulate.new()
		light_node.name = "MissionLight"
		light_node.color = Color(1, 1, 1)
		game.add_child(light_node)
	var col: Color = LIGHTS.get(to, Color(1, 1, 1))
	if secs <= 0.0 or not light_node.is_inside_tree():
		light_node.color = col
		return
	var tw := light_node.create_tween()
	tw.tween_property(light_node, "color", col, secs)


## A CHOICE (campaign-m1): {"id", "side", "line": a line id said with it, "options": [{"id", "label", "about", "do":
## [actions]}], "default": an option id, "time": seconds before the default is taken (90)}. The player of that side on
## this machine gets the buttons (MissionUi); a side no one here plays takes its default at once (online, the host
## decides: if the guest plays the choosing side, the default is taken; docs/campaign_m1_build.md).
func offer_choice(ch: Dictionary) -> void:
	if remote or flags.has(String(ch.get("id", ""))):
		return
	if ch.has("line"):
		say([String(ch["line"])])
	var side := String(ch.get("side", ""))
	if side != "" and side != my_side():
		choose(String(ch["id"]), String(ch.get("default", "")))
		return
	choice_open = ch.duplicate()
	choice_open["until"] = game.clock + float(ch.get("time", 90.0))
	if game.mlog:
		game.mlog.add("(mission) choice %s offered" % ch.get("id", ""))
	choice_offered.emit(choice_open)


## The answer to a choice: its flag is set and the option's actions run (an unknown option: the default, else the first).
func choose(cid: String, opt_id: String) -> void:
	if flags.has(cid):
		return
	var ch: Dictionary = choice_open if String(choice_open.get("id", "")) == cid else _find_choice(cid)
	var opts: Array = ch.get("options", [])
	var opt := _opt(opts, opt_id)
	if opt.is_empty():
		opt = _opt(opts, String(ch.get("default", "")))
	if opt.is_empty() and not opts.is_empty():
		opt = opts[0]
	flags[cid] = String(opt.get("id", opt_id))
	if String(choice_open.get("id", "")) == cid:
		choice_open = {}
	if game and game.mlog:
		game.mlog.add("(mission) choice %s: %s" % [cid, flags[cid]])
	for a in opt.get("do", []):
		act(a)
	objectives_changed.emit()


func _opt(opts: Array, oid: String) -> Dictionary:
	for o in opts:
		if String(o.get("id", "")) == oid:
			return o
	return {}


## A choice's data by id, wherever a trigger offers it.
func _find_choice(cid: String) -> Dictionary:
	for tr in data.get("triggers", []):
		for a in tr.get("do", []):
			if a is Dictionary and a.has("choice") and String(a["choice"].get("id", "")) == cid:
				return a["choice"]
	return {}


## Lines of dialogue: shown here (those meant for this player's side) and sent to the friends online.
func say(ids: Array) -> void:
	for lid in ids:
		var ln := line(String(lid))
		if ln.is_empty():
			continue
		said_ids.append(String(lid))
		if game.mlog:
			game.mlog.add("(mission) %s: %s" % [ln["name"], ln["text"]])
		_show(ln)
	_send({"k": "say", "ids": ids})


func _show(ln: Dictionary) -> void:
	if String(ln.get("to", "")) == "" or String(ln["to"]) == my_side():
		said.emit(ln)


func set_objective(oid: String, state: String) -> void:
	if not obj.has(oid) or obj[oid] == state:
		return
	if obj[oid] in ["done", "failed"] and not state in ["active", "hidden"]:
		return          # (a settled objective may still be taken off the panel: the Clockwork prologue's Part 3)
	obj[oid] = state
	if game.mlog:
		game.mlog.add("(mission) objective %s: %s" % [oid, state])
	objectives_changed.emit()
	_send({"k": "obj", "o": obj.duplicate()})


func _check_objectives() -> void:
	for o in data.get("objectives", []):
		var oid := String(o["id"])
		if obj.get(oid, "") != "active":
			continue
		match String(o.get("kind", "manual")):
			"survive":
				if game.clock >= float(o.get("time", 0)):
					set_objective(oid, "done")
			"countdown":
				# (a clock shown in the panel: "{clock:fall}" in its words; it never decides the end itself)
				var cn := String(o.get("clock", ""))
				if clocks.has(cn) and game.clock >= float(clocks[cn]):
					set_objective(oid, "done")
			"destroy":
				if tags.has(String(o["tag"])) and tagged(String(o["tag"])).is_empty():
					set_objective(oid, "done")
			"build":
				# every building with the tag stands built (her pen's stakes and gate)
				var bs := tagged(String(o["tag"]))
				if not bs.is_empty() and bs.size() == (tags.get(String(o["tag"]), []) as Array).size() and bs.all(func(b) -> bool: return b is Building and b.built):
					set_objective(oid, "done")
			"protect":
				if tags.has(String(o["tag"])) and tagged(String(o["tag"])).is_empty():
					set_objective(oid, "failed")
			"reach":
				var q := {"area": String(o["area"])}
				if o.has("unit_kind"):
					q["kind"] = o["unit_kind"]     # (only units of that kind count: six Clock Soldiers at the wagons)
				if o.has("tag"):
					q["tag"] = o["tag"]
				elif o.has("team"):
					q["team"] = o["team"]
				else:
					q["side"] = String(o.get("side_units", o["side"]))
				if count(q) >= int(o.get("count", 1)):
					set_objective(oid, "done")
	check_end()


## Who has won: a side whose primary objective failed loses (the other side wins); a side with every primary
## objective met wins (a "protect" one counts as met while it holds; at least one other must be done); a side wiped
## out (no units nor buildings, after having some, and past its "wiped_out" time) loses.
func check_end() -> void:
	if game.over or remote:
		return
	var wiped: Dictionary = data.get("wiped_out", {})
	for sd in Campaign.side_ids(data):
		var alive := count({"side": sd, "buildings": true})
		if alive > 0:
			_side_had[sd] = true
		elif _side_had.has(sd) and wiped.has(sd) and game.clock >= float(wiped[sd]):
			finish(_other_side(sd))
			return
	for sd in Campaign.side_ids(data):
		var prim := objectives_for(sd).filter(func(o: Dictionary) -> bool: return bool(o.get("primary", true)) and String(o.get("kind", "")) != "countdown")
		if prim.is_empty():
			continue
		var met := true
		var some_done := false
		for o in prim:
			if o["state"] == "failed":
				finish(_other_side(sd))
				return
			if o["state"] == "done":
				some_done = true
			elif not (o["state"] == "active" and String(o.get("kind", "")) == "protect"):
				met = false
		if met and some_done and not bool(data.get("manual_end", false)):
			finish(sd)      # (a "manual_end" mission is won only by its triggers' `win`: the Clockwork prologue)
			return


func _other_side(sd: String) -> String:
	for s in Campaign.side_ids(data):
		if s != sd:
			return s
	return ""


## The mission is over: `side_id` won. Game.ended goes out (Main shows the mission's end; an online guest learns it
## from the next snapshot).
func finish(side_id: String) -> void:
	if game.over:
		return
	winner_side = side_id
	var w := -1
	for t in team_ids.size():
		if side_of_team(t) == side_id:
			w = t
			break
	# the objectives left open are settled for the screen: the winners' protects held, the losers' are failed
	for o in data.get("objectives", []):
		var oid := String(o["id"])
		if obj[oid] == "active" and String(o.get("kind", "")) == "protect" and String(o["side"]) == side_id:
			obj[oid] = "done"
	if game.mlog:
		game.mlog.add("(mission) %s won" % side_id)
	_send({"k": "obj", "o": obj.duplicate()})
	game.over = true
	game.winner = w
	game.ended.emit(w)


## The winner of a finished match, as a side id (a guest learns the team from the snapshot).
func winner_side_of(team: int) -> String:
	return winner_side if winner_side != "" else side_of_team(team)


# ------------------------------------------------------------------ the Clockwork prologue's engine (docs/campaign_c01_build.md)

## Is this kind kept from this team in this mission? (Game.can_train and Game.requirement_text ask; a team's "roster":
## {"deny": [kinds]}, changed by the `unlock` and `deny` actions.)
func denied(t: int, k: String) -> bool:
	return deny.has(t) and (deny[t] as Dictionary).has(k)


## `convert`: {"tag", "to": team id, "warn": seconds (5), "as": a new tag}: the tagged units stutter for the warning
## (stunned, the stun stars, a sound), then change side (MissionRun._turn). Never a person's team's own trained units
## unless they carry the tag (the mission tags only the ones it means: the Perpetual's gift).
func convert_tag(v: Dictionary) -> void:
	var to := team_index(String(v.get("to", "")))
	if to < 0:
		return
	var warn := float(v.get("warn", 5.0))
	var list := tagged(String(v.get("tag", "")))
	if v.has("area"):
		# (or by place: up to "count" units of team "from" (of "kind") standing in the area: the order handed over)
		var r := area_rect(String(v["area"]))
		var ft := team_index(String(v.get("from", "")))
		var kk := String(v.get("kind", ""))
		list = game.units.filter(func(u) -> bool: return not u.dead and u.team == ft and r.has_point(u.position) and (kk == "" or u.kind == kk))
		list = list.slice(0, int(v.get("count", list.size())))
	for u in list:
		if not (u is Unit) or u.team == to:
			continue
		(u as Unit).stun(warn, true)
		_turning.append([u, to, game.clock + warn, String(v.get("as", ""))])
	if not _turning.is_empty():
		play_sound(String(v.get("sound", "campaign/off_beat")), "", 0.0)


func _tick_turning() -> void:
	var keep: Array = []
	for it in _turning:
		var u = it[0]
		if not is_instance_valid(u) or u.dead:
			continue
		if game.clock < float(it[2]):
			keep.append(it)
			continue
		_turn(u, int(it[1]), String(it[3]))
	_turning = keep


## A unit changes side (as Game.steal_horse does for a horse): its colour, out of every selection and group, its
## orders dropped, both sides' supply counted again.
func _turn(u: Unit, to: int, new_tag: String) -> void:
	var was := u.team
	u.team = to
	u.cmd_stop()
	if u._mat:
		u._mat.set_shader_parameter("team", u.cloth_colour())
	game.selection.erase(u)
	u.selected = false
	for gr in game.groups:
		gr.erase(u)
	if new_tag != "":
		_tag(new_tag, u)
	game._recount_supply(was)
	game._recount_supply(to)
	u.queue_redraw()
	if game.mlog:
		game.mlog.add("(mission) a %s changed side: %d -> %d" % [u.kind, was, to])


## EXITS (data "exits": [{"area", "tag" or "team", "counter"}]): units of that tag (or team) that walk into the area
## leave the map (not a loss) and are counted (townsfolk out of the west gate).
func _tick_exits() -> void:
	for ex in data.get("exits", []):
		if ex.has("after") and not fired.has(String(ex["after"])):
			continue          # (an exit opens once that trigger has fired: the canoes take people only once the station falls)
		var r := area_rect(String(ex.get("area", "")))
		var list: Array = []
		if ex.has("tag"):
			list = tagged(String(ex["tag"]))
		else:
			var t := team_index(String(ex.get("team", "")))
			list = game.units.filter(func(u) -> bool: return u.team == t and not u.dead)
		var n := 0
		var keep: Array = []
		for xt in ex.get("except", []):
			keep.append_array(tagged(String(xt)))      # (the heroes stay: they must be there at the end)
		for u in list:
			if u is Unit and not u.dead and r.has_point(u.position) and not keep.has(u):
				game.consume_unit(u)
				n += 1
		if n > 0:
			for tt in team_ids.size():
				game._recount_supply(tt)
			if ex.has("counter"):
				act({"counter": {"name": String(ex["counter"]), "add": n}})


## A sound for everyone (the bells tolling thirteen, the machine's off-beat tick): Sfx's name (assets/audio/<name>),
## at an area's middle when given.
func play_sound(sname: String, area := "", vol := 0.0) -> void:
	if sname == "" or not Sfx.has(sname):
		return
	Sfx.play(sname, area_rect(area).get_center() if area != "" else Vector2.INF, vol)
	_send({"k": "snd", "n": sname, "a": area, "v": vol})


## WEATHER: "snow" (flakes drifting over the screen, under the HUD), "" none.
func set_weather(w: String) -> void:
	if weather_node:
		weather_node.queue_free()
		weather_node = null
	if not w in ["snow", "rain"] or game == null or DisplayServer.get_name() == "headless":
		return
	var cl := CanvasLayer.new()
	cl.name = "MissionWeather"
	cl.layer = 1          # (over the world, under the HUD and the panels: ui_layer is 10)
	var p := CPUParticles2D.new()
	var vs := game.get_viewport().get_visible_rect().size if game.is_inside_tree() else Vector2(1600, 900)
	p.position = Vector2(vs.x * 0.5, -20)
	p.amount = 260
	p.lifetime = 9.0
	p.preprocess = 9.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(vs.x * 0.65, 10)
	p.direction = Vector2(0.25, 1)
	p.spread = 12.0
	p.gravity = Vector2(6, 22)
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 80.0
	p.scale_amount_min = 1.2
	p.scale_amount_max = 3.0
	p.color = Color(1, 1, 1, 0.75)
	if w == "rain":
		# RAIN (the Brood prologue's night): long, fast, thin grey-blue streaks
		p.amount = 420
		p.lifetime = 1.4
		p.preprocess = 1.4
		p.direction = Vector2(0.12, 1)
		p.spread = 3.0
		p.gravity = Vector2(0, 600)
		p.initial_velocity_min = 700.0
		p.initial_velocity_max = 900.0
		p.scale_amount_min = 1.0
		p.scale_amount_max = 1.6
		p.color = Color(0.72, 0.8, 0.95, 0.38)
		var tex := GradientTexture2D.new()
		tex.width = 2
		tex.height = 18
		tex.fill_from = Vector2(0, 0)
		tex.fill_to = Vector2(0, 1)
		var gr := Gradient.new()
		gr.set_color(0, Color(1, 1, 1, 0))
		gr.set_color(1, Color(1, 1, 1, 1))
		tex.gradient = gr
		p.texture = tex
	cl.add_child(p)
	game.add_child(cl)
	weather_node = cl


## `cage` (in place, harmless: Linnea in her pen, her eggs kept as eggs), `pin` (can't move, still fights: the fort's
## gun with no horse), `carry` (slower, can't attack: Lindqvist with the egg crate; "pace"), `spare` (nobody targets it,
## nothing hurts it). {"tag", "on": true / false}.
func hold(what: String, v: Dictionary) -> void:
	var on := bool(v.get("on", true))
	for e in tagged(String(v.get("tag", ""))):
		match what:
			"spare":
				e.spared = on
			"cage":
				if e is Unit:
					e.m_pace = 0.0 if on else 1.0
					e.m_unarmed = on
					_caged = _caged.filter(func(it) -> bool: return it[0] != e)
					if on:
						e.set_meta("mission_caged", true)
						e.cmd_stop()
						_caged.append([e, e.position])
					elif e.has_meta("mission_caged"):
						e.remove_meta("mission_caged")
			"pin":
				if e is Unit:
					e.m_pace = 0.0 if on else 1.0
			"carry":
				if e is Unit:
					e.m_pace = float(v.get("pace", 0.65)) if on else 1.0
					e.m_unarmed = on
					if on:
						e.target = null


## Each tick: the caged stay where they were put (nothing shoves them out of the pen), the burning burn.
func _tick_held() -> void:
	var keep: Array = []
	for it in _caged:
		var u = it[0]
		if not is_instance_valid(u) or u.dead or not u.has_meta("mission_caged"):
			continue
		keep.append(it)
		if u.position.distance_to(it[1]) > 1.0:
			u.position = it[1]
			u.velocity = Vector2.ZERO
			game.note_move(u)
	_caged = keep
	var still: Array = []
	for it in _burning:
		var b = it[0]
		if not is_instance_valid(b) or b.dead:
			continue
		still.append(it)
		b.take_damage(float(it[1]) * TICK + maxf(float(b.armor), 0.0), null)
		if randf() < 0.6:
			game.spawn_effect("fire", b.center() + Vector2(randf_range(-28, 28), randf_range(-22, 14)), 0.9)
	_burning = still


## An objective's words for the panel: translated, with the numbers put in: "{saved}" a counter, "{saved.of}" its
## "of", "{clock:fall}" the time left on a countdown (m:ss).
func objective_text(o: Dictionary) -> String:
	return fill(Loc.t(String(o.get("text", ""))))


func fill(txt: String) -> String:
	if txt.find("{") < 0:
		return txt
	for cn in counters:
		txt = txt.replace("{%s}" % cn, str(counters[cn]))
		txt = txt.replace("{%s.of}" % cn, str(data.get("counters", {}).get(cn, {}).get("of", "")))
	for cn in clocks:
		var left := maxi(0, int(ceil(float(clocks[cn]) - game.clock)))
		txt = txt.replace("{clock:%s}" % cn, "%d:%02d" % [left / 60, left % 60])
	return txt


## An OPENING's or ENDING's pages as this run left them: a line may be {"id", "if": a condition} (said only when it
## holds: the ending's "if the drawings burned" lines); pages left with no lines are dropped.
func pages_now(pages: Array) -> Array:
	var out: Array = []
	for pg in pages:
		var ids: Array = []
		for ln in pg.get("lines", []):
			if ln is Dictionary:
				if cond(ln.get("if", {})):
					ids.append(String(ln.get("id", "")))
			else:
				ids.append(String(ln))
		if ids.is_empty() and not (pg.get("lines", []) as Array).is_empty():
			continue
		var c: Dictionary = (pg as Dictionary).duplicate()
		c["lines"] = ids
		out.append(c)
	return out


# ------------------------------------------------------------------ the TUTORIAL (docs/tutorial.md)

## A step begins: what the player does from now on is measured against this moment.
func mark() -> void:
	noted.clear()
	if game.camera:
		_cam0 = game.camera.position
		_zoom0 = game.camera.zoom
	_base = _my_counts()


## Something the player did that the map can't show (the HUD and the hotkey bar call it): "minimap", "group_set",
## "group_select". Game.note_tutorial passes it on.
func note(what: String) -> void:
	noted[what] = int(noted.get(what, 0)) + 1


## The player's units and buildings by kind (buildings placed but not yet started count: a ghost site).
func _my_counts() -> Dictionary:
	var out := {}
	for u in game.units:
		if u.team == game.human and not u.dead:
			out[u.kind] = int(out.get(u.kind, 0)) + 1
	for b in game.buildings:
		if b.team == game.human and not b.dead:
			out[b.kind] = int(out.get(b.kind, 0)) + 1
	return out


func _kinds(q: Variant) -> Array:
	if q is String:
		return [q]
	if q is Dictionary and q.has("kind"):
		return q["kind"] if q["kind"] is Array else [q["kind"]]
	return ["any"]


func _kind_ok(e: Entity, kinds: Array) -> bool:
	if kinds.has("any") or kinds.has(e.kind):
		return true
	return kinds.has("army") and e is Unit and not (e as Unit).is_worker()


func _need(q: Variant) -> int:
	return int(q.get("count", 1)) if q is Dictionary else 1


func _tutorial_cond(k: String, v: Variant) -> bool:
	match k:
		"selected":
			var sel: Array = game.selection.filter(func(e) -> bool: return is_instance_valid(e) and not e.dead and e.team == game.human)
			if v is Dictionary and bool(v.get("none", false)):
				return sel.is_empty()
			var kinds := _kinds(v)
			return sel.filter(func(e) -> bool: return _kind_ok(e, kinds)).size() >= _need(v)
		"camera_moved":
			return game.camera != null and game.camera.position.distance_to(_cam0) >= float(v)
		"zoomed":
			return game.camera != null and absf(game.camera.zoom.x - _zoom0.x) >= 0.08
		"more":
			var now := _my_counts()
			var n := 0
			for kk in _kinds(v):
				n += int(now.get(kk, 0)) - int(_base.get(kk, 0))
			return n >= _need(v)
		"built":
			var kinds := _kinds(v)
			return game.buildings.filter(func(b) -> bool: return b.team == game.human and not b.dead and b.built and kinds.has(b.kind)).size() >= _need(v)
		"rooted":
			var kinds := _kinds(v)
			return game.units.filter(func(u) -> bool: return u.team == game.human and not u.dead and kinds.has(u.kind) and BroodNew.rooted(u)).size() >= _need(v)
		"crew":
			var kinds := _kinds(v)
			var at_least := int(v.get("at_least", 1)) if v is Dictionary else 1
			var n := 0
			for e in game.buildings + game.units:
				if e.team == game.human and not e.dead and kinds.has(e.kind) and WorkerLabels.workers(game, e).size() >= at_least:
					n += 1
			return n >= _need(v)
		"group":
			for gr in game.groups:
				if (gr as Array).filter(func(x) -> bool: return is_instance_valid(x) and not x.dead).size() >= int(v):
					return true
			return false
		"did":
			var what := String(v.get("name", "")) if v is Dictionary else String(v)
			return int(noted.get(what, 0)) >= _need(v)
		"gear_view":
			return game.gear_net != null and game.gear_net.view == bool(v)
		"placing":
			var c := game.controls
			if c == null:
				return false
			var kinds := _kinds(v)
			return c.mode in ["place", "nb_root"] and (kinds.has("any") or kinds.has(String(c.place_kind)))
		"order":
			var us := tagged(String(v.get("tag", "")))
			return us.filter(func(u) -> bool: return u is Unit and String(u.order) == String(v.get("is", ""))).size() >= _need(v)
		"res":
			var p: Dictionary = game.players[game.human]
			for key in v:          # ("gold", "res2": powder or spoils, "tension": the Clockwork's)
				if float(p.get(String(key), 0)) < float(v[key]):
					return false
			return true
		"talked":
			return not talk_busy
	return false


# ------------------------------------------------------------------ fog: revealed areas (Game._update_vis)

func stamp_reveals() -> void:
	var keep: Array = []
	for r in reveals:
		if game.clock >= float(r[3]):
			continue
		keep.append(r)
		for t in game.n_players():
			if int(game.sides[t]) == int(r[0]):
				game._reveal_air(t, r[1], int(r[2]))
	reveals = keep


# ------------------------------------------------------------------ online

func _send(m: Dictionary) -> void:
	if remote or game == null or game.net == null or not game.net.is_host or game.net.link == null:
		return
	m["t"] = "camp"
	game.net.link.send(m, 0)


## Guest: a message from the host's mission (NetSession._on_message routes "camp" here).
func on_net(m: Dictionary) -> void:
	match String(m.get("k", "")):
		"say":
			for lid in m.get("ids", []):
				var ln := line(String(lid))
				if not ln.is_empty():
					said_ids.append(String(lid))
					_show(ln)
		"obj":
			var o: Variant = m.get("o", {})
			if o is Dictionary and o != obj:
				obj = (o as Dictionary).duplicate()
				objectives_changed.emit()
		"reveal":
			var r: Array = m.get("r", [])
			if r.size() == 4:
				reveals.append(r)
		"ping":
			game._ping(m.get("p", Vector2.ZERO), Color(1, 0.85, 0.3))
		"light":
			set_light(String(m.get("to", "day")), float(m.get("secs", 0.0)))
		"cam":
			var s := String(m.get("s", ""))
			if s == "" or s == my_side():
				game.camera.position = m.get("p", game.camera.position)
