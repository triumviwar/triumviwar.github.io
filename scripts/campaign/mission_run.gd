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
var _burning: Array = []             # {"b": building, "rate": health a second, "spread": {...} or {}, "t": seconds to the next spread, "douse": seconds of dousing so far, "dside": side that puts it out, "dsecs": dousing needed}
var out_sides := {}                  # (a07, more than two sides) side id -> the game clock it lost; the match may go on
var shows: Array = []                # (a07) every MID-MATCH SHOW played, its pages (tests)
var fires_out := 0                   # (a07) fires put out (dousing men, rain, `douse`)
# ACT 1's ENGINE STEP 0 (act1-engine0, docs/act1_engine0.md): the campaign's DIFFICULTY, the SOLO SIDE PICK, STAY timers,
# ROUTE and FOLLOW orders, SLEEP / WAKE, the MIST, CAPTURE
var difficulty := "normal"           # "easy" / "normal" / "hard" (the campaign's, from the match setup)
var mult := {"clocks": 1.0, "spawns": 1.0}      # this mission's multipliers at that difficulty (Campaign.diff_mult)
var solo_side := ""                  # solo: the side the player picked on the briefing
var _stay := {}                      # a STAY condition's key -> [game clock it began to hold, game clock last checked]
var _routes: Array = []              # {"units", "pts": [areas], "i", "attack", "loop", "name", "t"}: ROUTE orders under way
var route_done := {}                 # a route's name -> the game clock it ended
var _follows: Array = []             # {"units", "leader": tag, "within": px, "t"}: FOLLOW orders
var sleeping := {}                   # a sleep's name -> {"units", "within": px, "by": side id, "hp": [health each], "then"}
var woke := {}                       # a sleep's name -> the game clock it woke
var mist_sight := 1.0                # the MIST: units' sight times this (1: none)
var mist_teams := {}                 # team index -> true: the mist's teams ({} every team)
var captured := {}                   # a capture objective's tag -> true once its man is taken
var _capture_share := {}             # a capture objective's tag -> the share of health he is kept at (his floor)
var weather_name := ""
# Act 1's a01_presses (a01-presses, docs/campaign_a01_build.md): DISGUISED buildings (a printing house that looks like
# one of the town's houses, in the town's colour, untouchable, until the other side comes close: then it is UNMASKED)
var _disguised: Array = []           # buildings still disguised
var unmasked := {}                   # tag -> the game clock a building with it was unmasked
# Act 1's a05_specimens (a05-specimens, docs/campaign_a05_build.md): CAGE CARTS (a creature caged on a cart: carried with
# it, untouchable and harmless; freed when the cart is broken, loaded with it when the cart leaves by an exit)
var _carts: Array = []               # {"u": the creature, "cart": the cart, "freed": counter, "freed_tag": tag}
# campaign-fixes-1121: the story's must-live people are WOUNDED, not killed (scripts/campaign/mission_heroes.gd)
var heroes: MissionHeroes = null
# act2-engine0: Act 2's pieces (cargo carts, take a cart, hidden / found / tracks, the leash, lure posts, buildings that
# convert, the spreading ground, the brake, sapping, granaries, versions, the heir, the idle meter): scripts/campaign/
# mission_act2.gd (MissionAct2); its state is this dictionary, saved with the rest
var act2 := {}
var a2: MissionAct2 = null


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
	var camp: Dictionary = cfg.get("campaign", {})
	difficulty = String(camp.get("difficulty", "normal"))
	if not Campaign.DIFFICULTIES.has(difficulty):
		difficulty = "normal"
	mult = Campaign.diff_mult(m, difficulty)
	solo_side = String(camp.get("side", "")) if md == "solo" else ""
	if m.get("mist") is Dictionary:
		set_mist(m["mist"], false)      # (the picture of it comes in _ready)
	a2 = MissionAct2.new(self)
	if m.get("versions") is Dictionary:
		# (act2-engine0: the mission's VERSION, FRESH / GROWN, picked once before anything is placed)
		flags["version"] = MissionAct2.version_of(m, solo_side, difficulty)
	for o in m.get("objectives", []):
		if String(o.get("kind", "")) == "capture":
			_capture_share[String(o.get("tag", ""))] = float(o.get("share", 0.25))
	for i in team_ids.size():
		for k in Campaign.roster_denied(data, team_data(i)):      # (the ladder's allow-list and the story's deny)
			if not deny.has(i):
				deny[i] = {}
			deny[i][String(k)] = true


# ------------------------------------------------------------------ lookups

func team_data(t: int) -> Dictionary:
	return data["teams"][t] if t >= 0 and t < (data["teams"] as Array).size() else {}


## A team's supply cap (0: none): "supply_cap": n, or by the campaign's difficulty {"easy": n, "normal": n, "hard": n}
## (campaign-fixes-1121: the mirrors' foes grow with the difficulty).
func supply_cap_of(t: int) -> int:
	var c: Variant = team_data(t).get("supply_cap", 0)
	if c is Dictionary:
		return int(c.get(difficulty, c.get("normal", 0)))
	return int(c)


func team_index(team_id: String) -> int:
	return team_ids.find(team_id)


## The team a computer player goes for before the others (team "ai_foe": a team id; the Brood prologue flip: the
## rival pack goes for the Sire's, not the station); -1 when none is named. Asked by AI._foe.
func ai_foe(t: int) -> int:
	var f := String(team_data(t).get("ai_foe", ""))
	return team_index(f) if f != "" else -1


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
		"portrait": portrait_for(who, String(sp.get("name", who)), String(ln.get("portrait", sp.get("portrait", "")))), "text": txt, "still": String(ln.get("still", "")),
		"to": String(ln.get("to", ""))}


# The face in the dialogue box: the speaker's own "portrait" if the mission names one, else
# campaign/portraits/<who>_<name>.png (a key shared by several people, like "teacher"), else
# campaign/portraits/<who>.png; "" draws the initials.
static func portrait_for(who: String, nm: String, own := "") -> String:
	if own != "" and ResourceLoader.exists(own):
		return own
	var slug := nm.to_lower().replace(".", "").replace("'", "").replace(" ", "_")
	for p in ["res://campaign/portraits/%s_%s.png" % [who, slug], "res://campaign/portraits/%s.png" % who]:
		if ResourceLoader.exists(p):
			return p
	return own


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
			var q := BroodNew.queen(game, t) if game.factions[t] == "brood" else null
			if q != null:
				_tag(String(tm["hall_tag"]), q)      # (the Brood's "hall" is her Mother: the prologue flip's Old Mother)
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
	if it.has("if") and not cond(it["if"]):
		return null          # (a building only when its condition holds: a flag a mission before left, the difficulty)
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
	for tg in it.get("tags", []):
		_tag(String(tg), b)                  # (a01: more tags: "presses" and "press_3" on one house)
	if it.has("name"):
		b.set_meta("mission_name", String(it["name"]))
	if it.get("disguise") is Dictionary:
		disguise(b, it["disguise"])
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
	if it.has("if") and not cond(it["if"]):
		return out           # (units only when the condition holds: "if": {"past": ...}, {"difficulty": "easy"})
	var n := scaled_count(t, int(it.get("count", 1)), bool(it.get("fixed", false)))
	var where := _where(it.get("at", [0, 0]))
	if it.has("near"):
		# (a01: "near": tag: round the first living thing with that tag, a disguised press's men out of its door)
		var r := near_rect(String(it["near"]))
		if r.size.x > 0.0:
			where = r
	var spots := _spots(where, n)
	for i in n:
		var u := game._add_unit(k, t, spots[i % spots.size()])
		if it.has("tag"):
			_tag(String(it["tag"]), u)
		for tg in it.get("tags", []):
			_tag(String(tg), u)
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
	if _capture_share.has(tag):
		e.hp_floor = maxf(e.hp_floor, e.max_hp * float(_capture_share[tag]))      # (a man to be taken alive can't be killed)


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
	if String(data.get("weather", "")) in ["snow", "rain", "mist"]:
		set_weather(String(data["weather"]))
	elif mist_sight < 1.0 and bool(data.get("mist", {}).get("weather", true)):
		set_weather("mist")
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
	if not remote:
		_carry_cages()
		if a2 != null:
			a2.frame(_delta)


func _physics_process(delta: float) -> void:
	if game == null or remote or game.over or get_tree().paused:
		return
	_t -= delta
	if _t > 0.0:
		return
	_t = TICK
	Rebels.tick(self, TICK)
	if heroes == null:
		heroes = MissionHeroes.new(self)
	heroes.tick(TICK)
	if a2 == null:
		a2 = MissionAct2.new(self)
	a2.tick(TICK)
	_tick_turning()
	_tick_exits()
	_tick_carts()
	_tick_held()
	_tick_routes()
	_tick_sleep()
	_tick_disguise()
	_tick_auto_tags()
	if not choice_open.is_empty() and game.clock >= float(choice_open.get("until", INF)):
		choose(String(choice_open["id"]), String(choice_open.get("default", "")))      # (nobody answered: the default)
	_run_triggers()
	_check_objectives()
	_take_checkpoint()
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
	if is_part_trigger(tid):
		_want_checkpoint(tid)        # (a new part of the mission: a CHECKPOINT, player-comforts)


## Is a condition true now? (docs/campaign_engine.md lists them.)
func cond(c: Variant) -> bool:
	if not (c is Dictionary):
		return false
	for k in c:
		var v: Variant = c[k]
		var ok := true
		match String(k):
			"unmasked":
				# (a01) {"unmasked": tag}: a disguised building with that tag has been found (dead or alive)
				ok = unmasked.has(String(v))
			"disguised":
				# (a01) {"disguised": tag}: one with that tag still stands disguised
				ok = tagged(String(v)).any(func(e) -> bool: return e.has_meta("disguise_team"))
			"out":
				# (a07) {"out": side}: that side has lost (the match may go on without it: more than two sides)
				ok = out_sides.has(String(v))
			"burning":
				# (a07) {"burning": {"tag", "at_least" / "below"}}: buildings of the tag on fire now
				var nb := burning_count(String(v.get("tag", "")))
				ok = (not v.has("at_least") or nb >= int(v["at_least"])) and (not v.has("below") or nb < int(v["below"]))
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
				if v.has("at_most_half"):
					# (campaign-fixes-1121: at most half of another counter: a04's lost to the machine of the riot)
					ok = ok and n * 2 <= int(counters.get(String(v["at_most_half"]), 0))
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
			# ---- act1-engine0
			"difficulty":
				# {"difficulty": "easy"} or ["easy", "normal"]: the campaign's difficulty
				ok = (v if v is Array else [v]).map(func(x) -> String: return String(x)).has(difficulty)
			"playing":
				# {"playing": side}: a person plays a team of that side (solo: the side picked; versus: both)
				ok = played_sides().has(String(v))
			"stay":
				# {"stay": {"tag" / "team" / "side", "kind", "area", "secs", "count"}}: that many have stood in the area for
				# secs without a break (Lyon's square, Ferrer's workshops)
				ok = stay_held(v)
			"near":
				# {"near": {"tag" / "team" / "side", "to": tag / "to_team" / "to_side", "within": tiles}}: one of them
				# within that many tiles of one of the others
				ok = near(v)
			"seen":
				# {"seen": {"tag", "by": side}}: one of them is in that side's sight now (the walker shadowed)
				ok = false
				var st := teams_of_side(String(v.get("by", "")))
				if not st.is_empty():
					for e in tagged(String(v.get("tag", ""))):
						if game.side_sees(st[0], e.position if e is Unit else e.center()):
							ok = true
							break
			"awake":
				ok = woke.has(String(v))
			"asleep":
				ok = sleeping.has(String(v)) and not woke.has(String(v))
			"captured":
				ok = captured.has(String(v))
			"route_done":
				ok = route_done.has(String(v))
			"cargo":
				# (a05) {"cargo": {"tag": the carts, "at_least" / "below"}}: living carts with a cage on them
				var n := cargo_count(String(v.get("tag", "")))
				ok = (not v.has("at_least") or n >= int(v["at_least"])) and (not v.has("below") or n < int(v["below"]))
			"selected", "camera_moved", "zoomed", "more", "built", "rooted", "crew", "group", "did", "gear_view", \
					"placing", "order", "res", "talked":
				ok = _tutorial_cond(String(k), v)
			_:
				# (act2-engine0: Act 2's conditions, MissionAct2.cond)
				var r2: Array = a2.cond(String(k), v) if a2 != null else [false, false]
				ok = bool(r2[0]) and bool(r2[1])
		if not ok:
			return false
	return true


## How many living units (horses not counted) match: of a "tag", a "team" or a "side", inside an "area" if given;
## "buildings": true counts their buildings too ("built": true: only the finished ones).
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
				# ("built": true only finished ones: the Fürth Line's Light Works, whoever's machine runs it)
				if not b.dead and not b.ghost and teams.has(b.team) and (b.built or not bool(q.get("built", false))):
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
				if v.has("to_if"):
					# {"to_if": [{"if": cond, "to": area}, ...]}: the first that holds sends them there, else "to" (a wave to
					# its lure jar while the lure still works, then to her pen)
					v = (v as Dictionary).duplicate()
					for ti in v["to_if"]:
						if cond(ti.get("if", {})):
							v["to"] = ti["to"]
							break
				var us: Array = []
				if v.has("tag"):
					us = tagged(String(v["tag"]))
				elif v.has("team"):
					var t := team_index(String(v["team"]))
					us = game.units.filter(func(u) -> bool: return u.team == t and not u.dead)
				if v.has("kind"):
					# (a03: "kind" only those of that kind: the nest's Raptors hunt, its Spitters keep by the Mother)
					var ks: Array = v["kind"] if v["kind"] is Array else [v["kind"]]
					us = us.filter(func(e) -> bool: return ks.has(e.kind))
				if v.has("only_team"):
					# (a01: of a tag, only those still on that team: the weavers who went home, not the ones who turned)
					var ot := team_index(String(v["only_team"]))
					us = us.filter(func(e) -> bool: return e.team == ot)
				if bool(v.get("idle", false)):
					# ("idle": only those not busy with a target: the Fürth Line's machines pushed on at the tower, never
					# pulled off the tower or a fight they are in)
					us = us.filter(func(e) -> bool: return e is Unit and (e.target == null or not is_instance_valid(e.target) or e.target.dead))
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
			"unmask":
				# {"unmask": {"tag", "first"}}: the story gives them away (a weaver tells Tomasz where it is); "first":
				# only the first still disguised (the Watch saw where one runner came from)
				for e in tagged(String(v.get("tag", ""))):
					if e is Building and e.has_meta("disguise_team"):
						unmask(e)
						if bool(v.get("first", false)):
							break
			"ping":
				var p := area_rect(String(v["area"])).get_center() if v.has("area") else near_rect(String(v.get("tag", ""))).get_center()
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
				side_lost(String(v))
			"counter":
				# {"counter": {"name", "add" or "set"}}
				var cn := String(v.get("name", ""))
				if v.has("count"):
					# (set from a count, or added with "plus": the people at the station when it falls)
					counters[cn] = (int(counters.get(cn, 0)) if bool(v.get("plus", false)) else 0) + count(v["count"])
				elif v.has("add_counter"):
					# (a03: another counter's number added: the party left on the mountain plus those already down)
					counters[cn] = int(counters.get(cn, 0)) + int(counters.get(String(v["add_counter"]), 0))
				else:
					counters[cn] = int(v["set"]) if v.has("set") else int(counters.get(cn, 0)) + int(v.get("add", 1))
				if v.has("min"):
					counters[cn] = maxi(int(counters[cn]), int(v["min"]))      # (a01: the temper never under 0)
				if v.has("max"):
					counters[cn] = mini(int(counters[cn]), int(v["max"]))
				objectives_changed.emit()
				_send({"k": "cnt", "c": counters.duplicate()})
			"clock":
				# {"clock": {"name", "secs"}} starts a countdown; {"name", "add": s} moves it (later +, sooner -);
				# {"name", "stop": true} stops it
				var cn := String(v.get("name", ""))
				if bool(v.get("stop", false)):
					clocks.erase(cn)
				elif v.has("secs"):
					# (a countdown the player races is longer on EASY, shorter on HARD: the difficulty's "clocks")
					clocks[cn] = game.clock + float(v["secs"]) * (float(mult.get("clocks", 1.0)) if clock_scales(cn, v) else 1.0)
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
						# (an optional "why": what the refusal says instead of "Not in this mission." while the story holds
						# it back: a02's commissary and the stop-work; playtest-campaign-clock)
						deny[t][String(kk)] = String(v["why"]) if v.has("why") else true
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
				# ("of": another counter: the bands are SHARES of its number (a03: the party that came down, of those who
				# went up), so they hold whatever the party's size)
				var of := maxf(1.0, float(counters.get(String(v["of"]), 0))) if v.has("of") else 0.0
				for bd in v.get("bands", []):
					if (n >= float(bd[0]) * of - 0.001) if v.has("of") else n >= int(bd[0]):
						val = bd[1]
				flags[String(v.get("flag", ""))] = val
				flags[String(v.get("flag", "")) + "_n"] = n
			"weather":
				set_weather(String(v))
				_send({"k": "wx", "w": String(v)})
			"sleep":
				sleep_units(v)
			"wake":
				wake(sleep_name(v))
			"mist":
				set_mist(v)
				_send({"k": "mist", "v": v})
			"cage", "pin", "carry", "spare", "pace":
				hold(String(k), v)
			"cart":
				cart_bind(v)
			"remove":
				# (a05) {"remove": {"tag"}}: taken off the map (not killed: Lindqvist lifts the eggs into his crate)
				# ("empty": true: only those with no cage on them, the carts that caught nothing)
				for e in tagged(String(v.get("tag", ""))):
					if e is Unit:
						if bool(v.get("empty", false)) and e.has_meta("cage_cargo"):
							continue
						_drop_cart(e)
						game.consume_unit(e)
				for tt in team_ids.size():
					game._recount_supply(tt)
			"floor":
				# {"floor": {"tag", "share"}}: their health never goes under that share (0: no floor)
				for e in tagged(String(v.get("tag", ""))):
					e.hp_floor = e.max_hp * float(v.get("share", 0.0))
			"max_hp":
				# (campaign-fixes-1121) {"max_hp": {"tag", "hp"}}: their full health set to hp, and filled (a mirror's prey,
				# Valadares when the Nest is played, harder to bring down by the campaign's difficulty)
				for e in tagged(String(v.get("tag", ""))):
					e.max_hp = float(v.get("hp", e.max_hp))
					e.hp = e.max_hp
			"heal":
				# {"heal": {"tag", "share"}}: their health back up to that share at least
				for e in tagged(String(v.get("tag", ""))):
					e.hp = maxf(e.hp, e.max_hp * float(v.get("share", 1.0)))
			"wind":
				# (a04) {"wind": {"tag", "share"}}: Clockwork units wound up to that share at least (the broken ones wind each
				# other before they march: run down to nothing they would stand still)
				for e in tagged(String(v.get("tag", ""))):
					if e is Unit:
						(e as Unit).wind = maxf((e as Unit).wind, clampf(float(v.get("share", 1.0)), 0.0, 1.0))
			"burn":
				# {"burn": {"tag", "secs", "spread": {"tag", "within", "every"}, "douse_side", "douse_secs", "first"}}:
				# buildings set alight burn down in about that time (fire on them); a SPREADING FIRE (a07) also lights
				# the nearest building of the spread tag within `within` tiles every `every` seconds; men of
				# `douse_side` (the building's own side if not given) standing by it put it out (see _tick_held)
				for e in tagged(String(v.get("tag", ""))):
					if e is Building:
						set_alight(e, v)
						if bool(v.get("first", false)):
							break
			"douse":
				# (a07) {"douse": {"tag"}}: the fires on these buildings go out
				for e in tagged(String(v.get("tag", ""))):
					douse(e)
			"show":
				# (a07) {"show": {"pages": [...]}}: a MID-MATCH SHOW (stills and lines over the match; solo pauses)
				play_show(v.get("pages", []))
			"nest_free":
				# {"nest_free": {"tag", "on"}} (the Brood prologue flip): these fathers may root away from their Mother's
				# father range, as a person's ROOT too (the Sire nesting by her pen); off: the range again
				for e in tagged(String(v.get("tag", ""))):
					if e is Unit and BroodNew.is_father(e.kind):
						if bool(v.get("on", true)):
							e.set_meta("mission_root", true)
						elif e.has_meta("mission_root"):
							e.remove_meta("mission_root")
			_:
				if a2 != null:
					a2.act(String(k), v)          # (act2-engine0: Act 2's actions, MissionAct2.act)


## (act2-engine0) Game._update_vis asks after its own loop: a HIDDEN unit stays off the screen of the side it hides from,
## a sapper under the ground off every other side's.
func after_vis(ft: int) -> void:
	if a2 != null:
		a2.after_vis(ft)


## (act2-engine0) Game._update_swamp asks: the mission's spreading swamp of a team ([centre in tiles, radius]).
func swamp_sources(t: int) -> Array:
	return a2.swamp_sources(t) if a2 != null else []


## (act2-engine0) The longest stretch so far with nothing for the player to do (a mission's sim reads it: NO WAITING).
func longest_idle() -> Dictionary:
	return a2.longest_idle() if a2 != null else {"secs": 0.0, "from": 0.0}


## Scripted orders go only to units no person plays (a co-op friend's or versus foe's units are theirs).
func _order(us: Array, v: Dictionary) -> void:
	us = us.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead and not player_teams.has(u.team))
	if us.is_empty():
		return
	# (a new order ends any ROUTE or FOLLOW these units were on)
	for r in _routes:
		r["units"] = (r["units"] as Array).filter(func(u) -> bool: return not us.has(u))
	for f in _follows:
		f["units"] = (f["units"] as Array).filter(func(u) -> bool: return not us.has(u))
	var p: Vector2 = area_rect(String(v["to"])).get_center() if v.has("to") else Vector2.INF
	match String(v.get("do", "")):
		"route":
			# {"do": "route", "route": [areas], "loop": false, "attack": false, "name"}: the waypoints in turn (a party up
			# the cliff, the cage carts down the trail); the condition {"route_done": name} once they reach the last
			var pts: Array = (v.get("route", []) as Array).map(func(x) -> String: return String(x))
			if pts.is_empty():
				return
			var rname := String(v.get("name", v.get("tag", v.get("team", "route"))))
			route_done.erase(rname)
			_routes = _routes.filter(func(r) -> bool: return String(r["name"]) != rname)
			var rt := {"units": us, "pts": pts, "i": 0, "attack": bool(v.get("attack", false)), "loop": bool(v.get("loop", false)),
				"name": rname, "t": 0.0}
			_routes.append(rt)
			game.group_move(us, area_rect(pts[0]).get_center(), rt["attack"])
		"follow":
			# {"do": "follow", "leader": tag, "within": tiles (3)}: they keep within reach of the leader (the first of the tag
			# alive), walking after it when it gets away; they stop when it is gone
			# (campaign-fixes-1121: "fight": tiles: an ESCORT: a follower with an enemy within that many tiles goes for it,
			# and keeps at it while the leader is not too far, instead of walking past it: the mirrors' scripted guards)
			_follows.append({"units": us, "leader": String(v.get("leader", "")), "within": float(v.get("within", 3)) * Defs.TILE, "t": 0.0,
				"fight": float(v.get("fight", 0)) * Defs.TILE})
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
		"heel":
			# {"do": "heel", "leader": tag} (the Brood prologue flip): each walks after the first living unit with that tag
			# (Linnea at the Sire's heels), stopping a little behind him; a rooted leader is waited for where he lies
			var lead := tagged(String(v.get("leader", "")))
			if lead.is_empty():
				return
			var lp: Vector2 = lead[0].position
			var i := 0
			for u in us:
				var spot := lp + Vector2(-50.0 - 22.0 * (i % 3), 30.0 * (i / 3) - 20.0)
				i += 1
				if u.position.distance_to(lp) > 110.0 and (u.order_point.distance_to(spot) > 60.0 or u.order == "idle"):
					game.group_move([u], spot, false)
		"hunt":
			# {"do": "hunt", "prey": a tag, "within": tiles}: each idle or walking unit goes for the nearest living unit
			# with that tag within reach (the machine going after the townsfolk in the streets)
			var prey := tagged(String(v.get("prey", "")))
			if v.has("prey_team"):
				# ("prey_team": every living unit of that team: the Fürth Line's scripted guild going for the machine's
				# player's units that came through the line, whatever he made)
				var pt := team_index(String(v["prey_team"]))
				prey = game.units.filter(func(e) -> bool: return e.team == pt and not e.dead and e.kind != "horse")
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
		_:
			if a2 != null:
				a2.order(us, v)        # (act2-engine0: "track")


## THE LIGHT (campaign-m1): the scene tinted for the time of day ("night" blue and dim, "dawn" warm, "day" as
## painted), over `secs` seconds. A CanvasModulate on the Game: the world only, never the HUD.
const LIGHTS := {"night": Color(0.40, 0.45, 0.66), "dusk": Color(0.78, 0.66, 0.70), "dawn": Color(1.0, 0.83, 0.70), "day": Color(1, 1, 1),
	# WINTER (the Clockwork prologue, Advent in Nuremberg): a cold day, a short violet dusk, a deep blue night lit by fires
	"winter_day": Color(0.88, 0.93, 1.04), "winter_dusk": Color(0.66, 0.62, 0.80), "winter_night": Color(0.36, 0.42, 0.66),
	# THE AMAZON (the Brood prologue): a heavy humid afternoon, a rainy dusk, the rain at night, the night lit by the burning
	# station, the grey before dawn
	"jungle_day": Color(0.96, 0.95, 0.84), "jungle_dusk": Color(0.74, 0.62, 0.62), "jungle_night": Color(0.52, 0.58, 0.72),
	"fire_night": Color(0.7, 0.54, 0.48), "grey_dawn": Color(0.66, 0.68, 0.74)}


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
	if opt_id == "random" and not opts.is_empty():
		# (a01: "default": "random": the match's seed picks, the same on every machine and replay of it: where the
		# Assembly's presses print when nobody plays it)
		var r := RandomNumberGenerator.new()
		r.seed = hash([int(game.rng.seed) if game and game.rng else 0, cid])
		opt_id = String(opts[r.randi() % opts.size()].get("id", ""))
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
	if Campaign.ironman() and saveable():
		checkpoint_wanted.emit("choice:" + cid)      # (IRONMAN: the choice saved at once, so leaving can't undo it)


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
	if state == "done" and bool(objective(oid).get("primary", false)) and String(objective(oid).get("side", "")) == my_side():
		_want_checkpoint("obj:" + oid)      # (a primary objective met: a CHECKPOINT, player-comforts)
	objectives_changed.emit()
	_send({"k": "obj", "o": obj.duplicate()})


func _check_objectives() -> void:
	for o in data.get("objectives", []):
		var oid := String(o["id"])
		if obj.get(oid, "") != "active":
			continue
		match String(o.get("kind", "manual")):
			"survive":
				# (an "if": what must still hold when the time is up, else it fails: the Prologue's "until dawn, with at
				# least three barns standing" was ticked done on the very defeat it caused; playtest 2026-11-21)
				if game.clock >= float(o.get("time", 0)):
					set_objective(oid, "done" if not o.has("if") or cond(o["if"]) else "failed")
			"countdown":
				# (a clock shown in the panel: "{clock:fall}" in its words; it never decides the end itself)
				var cn := String(o.get("clock", ""))
				if clocks.has(cn) and game.clock >= float(clocks[cn]):
					# ("fail": running out is the bad end: Paris's "The King's patience" was ticked green on the defeat
					# it brought; playtest 2026-11-21)
					set_objective(oid, "failed" if bool(o.get("fail", false)) else "done")
			"destroy":
				if tags.has(String(o["tag"])) and tagged(String(o["tag"])).is_empty():
					set_objective(oid, "done")
			"build":
				# every building with the tag that still stands is built (her pen's stakes and gate; a site knocked down
				# meanwhile doesn't hold it up for ever)
				var bs := tagged(String(o["tag"]))
				if not bs.is_empty() and bs.all(func(b) -> bool: return b is Building and b.built):
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
				if o.has("secs"):
					# (a STAY: that many must stand there for secs without a break)
					q["secs"] = o["secs"]
					q["count"] = int(o.get("count", 1))
					if stay_held(q, "obj:" + oid):
						set_objective(oid, "done")
				elif count(q) >= int(o.get("count", 1)):
					set_objective(oid, "done")
			"capture":
				_check_capture(o)
	check_end()


## Who has won: a side whose primary objective failed loses (the other side wins); a side with every primary
## objective met wins (a "protect" one counts as met while it holds; at least one other must be done); a side wiped
## out (no units nor buildings, after having some, and past its "wiped_out" time) loses (side_lost: with more than two
## sides the match may go on without it).
func check_end() -> void:
	if game.over or remote:
		return
	var wiped: Dictionary = data.get("wiped_out", {})
	for sd in Campaign.side_ids(data):
		if out_sides.has(sd):
			continue
		var alive := count({"side": sd, "buildings": true})
		if alive > 0:
			_side_had[sd] = true
		elif _side_had.has(sd) and wiped.has(sd) and game.clock >= float(wiped[sd]):
			side_lost(sd)
			if game.over:
				return
	for sd in Campaign.side_ids(data):
		if out_sides.has(sd):
			continue
		var prim := objectives_for(sd).filter(func(o: Dictionary) -> bool: return bool(o.get("primary", true)) and String(o.get("kind", "")) != "countdown")
		if prim.is_empty():
			continue
		var met := true
		var some_done := false
		var failed := false
		for o in prim:
			if o["state"] == "failed":
				failed = true
				break
			if o["state"] == "done":
				some_done = true
			elif not (o["state"] == "active" and String(o.get("kind", "")) == "protect"):
				met = false
		if failed:
			side_lost(sd)
			if game.over:
				return
			continue
		if met and some_done and not bool(data.get("manual_end", false)):
			finish(sd)      # (a "manual_end" mission is won only by its triggers' `win`: the Clockwork prologue)
			return


func _other_side(sd: String) -> String:
	for s in Campaign.side_ids(data):
		if s != sd:
			return s
	return ""


## A side has LOST (a failed primary, wiped out, a `lose`). With two sides the other wins at once (as always). With MORE
## THAN TWO (a07) the side is OUT and the winner is: a side still in with a primary objective done; else the only side
## still in that has primary objectives; else the only one of those a person plays; else nobody yet: the match goes on
## between the sides still in (the Crown against the machines after the creatures are beaten). No side with objectives
## left: the first side still in (the old rule).
func side_lost(sd: String) -> void:
	if game.over or out_sides.has(sd):
		return
	out_sides[sd] = game.clock
	if game.mlog:
		game.mlog.add("(mission) %s is out" % sd)
	var w := winner_after(sd)
	if w != "":
		finish(w)
	else:
		objectives_changed.emit()


func winner_after(sd: String) -> String:
	var all := Campaign.side_ids(data)
	var still: Array = all.filter(func(x: String) -> bool: return x != sd and not out_sides.has(x))
	if all.size() <= 2:
		return still[0] if not still.is_empty() else _other_side(sd)
	for x in still:
		if _prim(x).any(func(o: Dictionary) -> bool: return o["state"] == "done"):
			return x
	var contenders: Array = still.filter(func(x: String) -> bool: return _prim(x).any(func(o: Dictionary) -> bool: return o["state"] == "active"))
	if contenders.size() == 1:
		return contenders[0]
	if contenders.is_empty():
		return still[0] if not still.is_empty() else _other_side(sd)
	if not played_sides().has(sd):
		return ""             # (a scripted side is out: the others fight on)
	# a person's side is out: the other person's side wins (versus); nobody else plays: the first side still in
	var played: Array = contenders.filter(func(x: String) -> bool: return played_sides().has(x))
	return played[0] if played.size() == 1 else String(contenders[0])


func _prim(sd: String) -> Array:
	return objectives_for(sd).filter(func(o: Dictionary) -> bool: return bool(o.get("primary", true)) and String(o.get("kind", "")) != "countdown")


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


## What a refusal says for a denied kind: the deny action's "why" when it gave one, else "Not in this mission.".
func denied_text(t: int, k: String) -> String:
	var w: Variant = (deny.get(t, {}) as Dictionary).get(k, true)
	return String(w) if w is String and String(w) != "" else "Not in this mission."


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
		# (a05) "cargo": true: only carts with a cage on them leave, and the cage goes with them; "max": how many may
		# leave by it in all (a number or a counter's: the canoes' room), "counter" counting them
		var cargo := bool(ex.get("cargo", false))
		var room := INF
		if ex.has("max"):
			var mx := float(counters.get(String(ex["max"]), 0)) if ex["max"] is String else float(ex["max"])
			room = mx - float(counters.get(String(ex.get("counter", "")), 0))
		for u in list:
			if float(n) >= room:
				break
			if u is Unit and not u.dead and r.has_point(u.position) and not keep.has(u):
				if cargo:
					var c = u.get_meta("cage_cargo", null)
					if c == null or not is_instance_valid(c) or c.dead:
						# (act2-engine0: a cart with families or gold aboard leaves with its load, counted by its amount)
						var ld: int = a2.cart_leaves(u) if a2 != null and u.has_meta("cart_load") else 0
						if ld <= 0:
							continue
						if ex.has("cargo_counter"):
							counters[String(ex["cargo_counter"])] = int(counters.get(String(ex["cargo_counter"]), 0)) + ld
						game.consume_unit(u)
						n += 1
						continue
					_drop_cart(c)
					game.consume_unit(c)
					if ex.has("cargo_counter"):
						counters[String(ex["cargo_counter"])] = int(counters.get(String(ex["cargo_counter"]), 0)) + 1
				game.consume_unit(u)
				n += 1
		if n > 0:
			for tt in team_ids.size():
				game._recount_supply(tt)
			if ex.has("counter"):
				act({"counter": {"name": String(ex["counter"]), "add": n}})


## CAGE CARTS (a05): {"cart": {"tag": the creatures, "cart": the carts' tag, "caged": counter, "freed": counter,
## "freed_tag": tag}}: each creature with the tag not yet on a cart is caged on the nearest free cart with the cart tag
## (one creature a cart). On it the creature is carried along (MissionRun._carry_cages, every frame), can't move or
## fight, and nobody targets or hurts it; it shoves nobody (its mass near nothing). The cart broken (dead): the
## creature is FREED (on its feet, open to attack, counted in "freed", tagged "freed_tag"). The cart leaving by an exit
## with "cargo": the creature goes with it (counted by the exit). The cart is a role "cage_cart" (a Powder Wagon that
## never blows up).
func cart_bind(v: Dictionary) -> void:
	var carts: Array = tagged(String(v.get("cart", ""))).filter(func(e) -> bool: return e is Unit and not e.has_meta("cage_cargo"))
	for e in tagged(String(v.get("tag", ""))):
		if not (e is Unit) or e.has_meta("on_cart") or carts.is_empty():
			continue
		var best = carts[0]
		for c in carts:
			if c.position.distance_to(e.position) < best.position.distance_to(e.position):
				best = c
		carts.erase(best)
		var u: Unit = e
		_caged = _caged.filter(func(it) -> bool: return it[0] != u)
		u.set_meta("mission_caged", true)
		u.set_meta("on_cart", best)
		u.set_meta("cart_mass", u.nb_mass)
		best.set_meta("cage_cargo", u)
		u.cmd_stop()
		u.target = null
		u.m_pace = 0.0
		u.m_unarmed = true
		u.spared = true
		u.nb_mass = 0.001          # (it shoves nobody: the cart rolls on with it)
		var bars := CageBars.new()
		bars.name = "CageBars"
		bars.r = u.radius
		u.add_child(bars)
		_carts.append({"u": u, "cart": best, "freed": String(v.get("freed", "")), "freed_tag": String(v.get("freed_tag", ""))})
		if v.has("caged"):
			counters[String(v["caged"])] = int(counters.get(String(v["caged"]), 0)) + 1
		if game.mlog:
			game.mlog.add("(mission) a %s caged on a cart" % u.kind)
	objectives_changed.emit()
	_send({"k": "cnt", "c": counters.duplicate()})


## Living carts of the tag with a cage on them.
func cargo_count(tag: String) -> int:
	var n := 0
	for e in tagged(tag):
		var c = e.get_meta("cage_cargo", null)
		if c != null and is_instance_valid(c) and not c.dead:
			n += 1
	return n


## Each tick: a cart broken frees its creature.
func _tick_carts() -> void:
	for it in _carts.duplicate():
		var u = it["u"]
		var c = it["cart"]
		if not is_instance_valid(u) or u.dead:
			_carts.erase(it)
			continue
		if not is_instance_valid(c) or c.dead:
			_free_cage(it)


func _free_cage(it: Dictionary) -> void:
	var u: Unit = it["u"]
	_drop_cart(u)
	u.spared = false
	if not u.has_meta("mission_asleep"):
		u.m_pace = 1.0
		u.m_unarmed = false
	if String(it.get("freed_tag", "")) != "":
		_tag(String(it["freed_tag"]), u)
	if String(it.get("freed", "")) != "":
		act({"counter": {"name": String(it["freed"]), "add": 1}})
	game._ping(u.position, Color(0.4, 1.0, 0.3))
	_send({"k": "ping", "p": u.position})
	if game.mlog:
		game.mlog.add("(mission) a cage broke: a %s is free" % u.kind)


## A creature off its cart (freed, loaded, or taken off): its cage's marks gone.
func _drop_cart(u: Unit) -> void:
	_carts = _carts.filter(func(it) -> bool: return it["u"] != u)
	if not u.has_meta("on_cart"):
		return
	var c = u.get_meta("on_cart")
	if is_instance_valid(c) and c.get_meta("cage_cargo", null) == u:
		c.remove_meta("cage_cargo")
	u.remove_meta("on_cart")
	if u.has_meta("mission_caged"):
		u.remove_meta("mission_caged")
	u.nb_mass = float(u.get_meta("cart_mass", 1.0))
	var bars := u.get_node_or_null("CageBars")
	if bars:
		u.remove_child(bars)
		bars.queue_free()


## Every frame: the caged creatures ride on their carts.
func _carry_cages() -> void:
	for it in _carts:
		var u = it["u"]
		var c = it["cart"]
		if not is_instance_valid(u) or u.dead or not is_instance_valid(c) or c.dead:
			continue
		var p: Vector2 = c.position + Vector2(0, 1)
		if u.position.distance_to(p) > 0.5:
			u.position = p
			u.velocity = Vector2.ZERO
			game.note_move(u)


## The cage's bars round a creature on a cart (drawn in code until the cart's own art: docs/art_style_inconsistency.md).
class CageBars extends Node2D:
	var r := 10.0

	func _ready() -> void:
		z_index = 1

	func _draw() -> void:
		var w := r + 4.0
		var h := r * 2.4 + 6.0
		var wood := Color(0.36, 0.24, 0.13, 0.95)
		draw_rect(Rect2(-w, -h, w * 2.0, h + 3.0), Color(0.1, 0.08, 0.05, 0.18))
		var n := maxi(3, int(w * 2.0 / 6.0))
		for i in n + 1:
			var x := -w + w * 2.0 * float(i) / float(n)
			draw_line(Vector2(x, -h), Vector2(x, 3.0), wood, 1.6)
		draw_line(Vector2(-w - 1, -h), Vector2(w + 1, -h), wood, 2.4)
		draw_line(Vector2(-w - 1, 3.0), Vector2(w + 1, 3.0), wood, 2.4)


## A sound for everyone (the bells tolling thirteen, the machine's off-beat tick): Sfx's name (assets/audio/<name>),
## at an area's middle when given.
func play_sound(sname: String, area := "", vol := 0.0) -> void:
	if sname == "" or not Sfx.has(sname):
		return
	Sfx.play(sname, area_rect(area).get_center() if area != "" else Vector2.INF, vol)
	_send({"k": "snd", "n": sname, "a": area, "v": vol})


## WEATHER: "snow" (flakes drifting over the screen, under the HUD), "" none.
func set_weather(w: String) -> void:
	weather_name = w
	if weather_node:
		weather_node.queue_free()
		weather_node = null
	if not w in ["snow", "rain", "mist"] or game == null or DisplayServer.get_name() == "headless":
		return
	var cl := CanvasLayer.new()
	cl.name = "MissionWeather"
	cl.layer = 1          # (over the world, under the HUD and the panels: ui_layer is 10)
	if w == "mist":
		_mist_picture(cl)
		game.add_child(cl)
		weather_node = cl
		return
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
				if not on and e.has_meta("on_cart"):
					continue          # (a05: a creature on a cage cart stays untouchable until the cart breaks)
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
			"pace":
				# {"pace": {"tag", "pace"}}: its speed times this (b01: Linnea, slow as a Brood Mother, walks home quicker)
				if e is Unit:
					e.m_pace = float(v.get("pace", 1.0))
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
	_tick_fires()


## THE FIRES (the Brood prologue's `burn`, and a07's SPREADING FIRE): each burning building loses its health in about
## its `secs`, flames on it; a spreading one lights the nearest building of its spread tag within reach every `every`
## seconds (the new fire spreads the same way); men of the dousing side (or only of `douse_teams`) standing by it (within
## 2 tiles of its edge, not asleep or caged) put it out in `douse_secs` (8) seconds of their work together (two men twice as fast), and slow it
## meanwhile (no spreading, half the burning); RAIN works as one man at every fire (and no fire spreads in it).
func _tick_fires() -> void:
	var still: Array = []
	var lit: Array = []
	var rain := weather_name == "rain"
	for it in _burning:
		var b = it["b"]
		if not is_instance_valid(b) or b.dead:
			continue
		var men := _dousers(b, String(it["dside"]), it.get("dteams", []))
		var work := float(men) + (1.0 if rain else 0.0)
		if work > 0.0:
			it["douse"] = float(it["douse"]) + work * TICK
			if float(it["douse"]) >= float(it["dsecs"]):
				fires_out += 1
				if game.mlog:
					game.mlog.add("(mission) a fire is out")
				continue
		still.append(it)
		# (the fire takes no notice of `spare`: a building kept from the enemy's attacks still burns down in its time)
		b.hp -= float(it["rate"]) * TICK * (0.5 if men > 0 else 1.0)
		b.flash = 0.12
		if b.hp <= 0.0:
			b.spared = false
			b.hp = 0.5
			b.take_damage(10.0, null)
		if randf() < 0.6:
			game.spawn_effect("fire", b.center() + Vector2(randf_range(-28, 28), randf_range(-22, 14)), 0.9)
		var sp: Dictionary = it["spread"]
		if not sp.is_empty() and men == 0 and not rain:
			it["t"] = float(it["t"]) - TICK
			if float(it["t"]) <= 0.0:
				it["t"] = float(sp.get("every", 12.0))
				var nxt: Variant = _next_to_catch(b, sp)
				if nxt != null:
					lit.append([nxt, it])
	_burning = still
	for pair in lit:
		var src: Dictionary = pair[1]
		var keys := {"secs": float(pair[0].max_hp) / maxf(float(src["rate"]), 0.01), "spread": src["spread"],
			"douse_side": src["dside"], "douse_secs": src["dsecs"]}
		set_alight(pair[0], keys)
		var it2: Dictionary = _burning[_burning.size() - 1] if not _burning.is_empty() else {}
		if not it2.is_empty() and it2["b"] == pair[0]:
			it2["dteams"] = src.get("dteams", [])


## (a07) mission "auto_tags": [{"team", "kind", "tag"}]: every unit of that team and kind (one a person trains too)
## gets the tag (the Missionaries a player trains at Rome's church lead the people as Father Tomasz does).
func _tick_auto_tags() -> void:
	for at in data.get("auto_tags", []):
		var t := team_index(String(at.get("team", "")))
		var tg := String(at.get("tag", ""))
		var have: Array = tags.get(tg, [])
		for u in game.units:
			if u.team == t and not u.dead and u.kind == String(at.get("kind", "")) and not have.has(u):
				_tag(tg, u)
				have = tags[tg]


## Set one building alight (the `burn` action's keys); already burning: nothing.
func set_alight(b: Building, v: Dictionary) -> void:
	if b == null or b.dead or is_burning(b):
		return
	var sp: Dictionary = v.get("spread", {}) if v.get("spread") is Dictionary else {}
	var ds := String(v.get("douse_side", side_of_team(b.team)))
	var dt: Array = (v.get("douse_teams", []) as Array).map(func(x) -> int: return team_index(String(x)))
	_burning.append({"dteams": dt, "b": b, "rate": b.max_hp / maxf(float(v.get("secs", 60.0)), 1.0), "spread": sp,
		"t": float(sp.get("every", 12.0)), "douse": 0.0, "dside": ds, "dsecs": maxf(float(v.get("douse_secs", 8.0)), 0.5)})
	if game.mlog:
		game.mlog.add("(mission) fire: %s" % b.kind)


func is_burning(b: Entity) -> bool:
	return _burning.any(func(it) -> bool: return it["b"] == b)


func burning_count(tag: String) -> int:
	var n := 0
	for e in tagged(tag):
		if is_burning(e):
			n += 1
	return n


## The fire on this building goes out (its health stays where the fire left it).
func douse(e: Entity) -> void:
	var n := _burning.size()
	_burning = _burning.filter(func(it) -> bool: return it["b"] != e)
	fires_out += n - _burning.size()


## Men of the side putting this fire out: living, awake, uncaged units of that side within 2 tiles of the building's
## edge (no horses; a construct doesn't carry water: only the people of a side work at it, any of its units).
func _dousers(b: Building, side: String, teams: Array = []) -> int:
	if side == "" and teams.is_empty():
		return 0
	var r: Rect2 = b.rect().grow(Defs.TILE * 2.0)
	var n := 0
	for u in game.units:
		if u.dead or u.kind == "horse" or u.has_meta("mission_caged") or u.has_meta("mission_asleep"):
			continue
		if (teams.is_empty() and side_of_team(u.team) != side) or (not teams.is_empty() and not teams.has(u.team)):
			continue
		if r.has_point(u.position):
			n += 1
	return n


## The next building a spreading fire takes: the nearest living, not burning one of the spread tag within reach.
func _next_to_catch(b: Building, sp: Dictionary) -> Variant:
	var best: Variant = null
	var bd := float(sp.get("within", 6.0)) * Defs.TILE
	for e in tagged(String(sp.get("tag", ""))):
		if e == b or not (e is Building) or is_burning(e):
			continue
		var d: float = b.center().distance_to(e.center())
		if d <= bd:
			bd = d
			best = e
	return best


## A MID-MATCH SHOW (a07): the pages (with their `if` lines) full screen over the match; a solo match is paused while it
## plays (online it doesn't stop the match). Sent to the friend online.
func play_show(pages: Array) -> void:
	var pg := pages_now(pages)
	if pg.is_empty():
		return
	shows.append(pg)
	_send({"k": "show", "pages": pages})
	_show_pages(pg)


func _show_pages(pg: Array) -> void:
	if game.hud == null or not is_instance_valid(game.hud) or game.hud.get_parent() == null or DisplayServer.get_name() == "headless":
		return
	# (the tree paused quietly, as the HUD's own pause does but without its announcer's "paused" / "resumed")
	var solo: bool = game.net == null and game.replay == null
	var paused_here := false
	if solo and not get_tree().paused:
		get_tree().paused = true
		if "paused" in game.hud:
			game.hud.paused = true
		paused_here = true
	StillShow.play(game.hud.get_parent(), data, pg, func() -> void:
		if paused_here and is_instance_valid(game) and get_tree().paused:
			get_tree().paused = false
			if is_instance_valid(game.hud) and "paused" in game.hud:
				game.hud.paused = false)


## An objective's words for the panel: translated, with the numbers put in: "{saved}" a counter, "{saved.of}" its
## "of", "{clock:fall}" the time left on a countdown (m:ss).
func objective_text(o: Dictionary) -> String:
	return fill(Loc.t(String(o.get("text", ""))))


func fill(txt: String) -> String:
	if txt.find("{") < 0:
		return txt
	for cn in counters:
		# (a counter with an "of" reads "n of N": past N it says N, not "22 of 6 Raptors", playtest 2026-11-21)
		var of: Variant = data.get("counters", {}).get(cn, {}).get("of", null)
		var n := int(counters[cn])
		if of != null and (of is int or of is float) and txt.contains("{%s} of" % cn):
			n = mini(n, int(of))
		txt = txt.replace("{%s}" % cn, str(n))
		txt = txt.replace("{%s.of}" % cn, (str(int(of)) if (of is int or of is float) else str(of)) if of != null else "")
	for cn in clocks:
		var left := maxi(0, int(ceil(float(clocks[cn]) - game.clock)))
		txt = txt.replace("{clock:%s}" % cn, "%d:%02d" % [left / 60, left % 60])
	if txt.find("{") >= 0:
		txt = _UNSET.sub(txt, "…", true)       # (a clock not started yet: a06's "{clock:patience}" in its first second)
	return txt


static var _UNSET := RegEx.create_from_string("\\{[^}]*\\}")


## A number for the player's eyes: a whole one without ".0" (the data's numbers are floats once read: a07's "Saved: 13
## of 18.0"; playtest 2026-11-21).
static func _num(v: Variant) -> String:
	if v is float and is_equal_approx(v, roundf(v)):
		return str(int(roundf(v)))
	return str(v)


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


# ------------------------------------------------------------------ act 1's engine step 0 (docs/act1_engine0.md)

## The sides a person plays in this game (solo: the one picked; co-op: the friends'; versus: both).
func played_sides() -> Array:
	var out: Array = []
	for t in player_teams:
		var sd := side_of_team(int(t))
		if not out.has(sd):
			out.append(sd)
	return out


## How many units an entry or a spawn really gives: the DIFFICULTY's "spawns" for the sides nobody plays (EASY fewer,
## HARD more), never under 1; a single unit (a hero) and an entry with "fixed": true stay as written.
func scaled_count(t: int, n: int, fixed := false) -> int:
	var sm := float(mult.get("spawns", 1.0))
	if fixed or n < 2 or is_equal_approx(sm, 1.0) or played_sides().has(side_of_team(t)):
		return n
	return maxi(1, roundi(n * sm))


## Does a countdown take the DIFFICULTY's "clocks"? Its own "scale" says so; else yes when an objective of kind
## "countdown" shows it (the clock the player races), no for the mission's own timers.
func clock_scales(cn: String, v: Dictionary) -> bool:
	if v.has("scale"):
		return bool(v["scale"])
	for o in data.get("objectives", []):
		if String(o.get("kind", "")) == "countdown" and String(o.get("clock", "")) == cn:
			return true
	return false


## STAY: {"tag" / "team" / "side", "kind", "area", "count" (1), "secs"}: that many have stood in the area for secs
## without a break. The timer runs while the condition is asked (each check); a gap in the asking starts it again.
func stay_held(q: Dictionary, key := "") -> bool:
	if key == "":
		key = JSON.stringify(q)
	var c: Dictionary = q.duplicate()
	c.erase("secs")
	var n := int(c.get("count", 1))
	c.erase("count")
	if not c.has("area") or count(c) < n:
		_stay.erase(key)
		return false
	var it: Array = _stay.get(key, [])
	if it.is_empty() or game.clock - float(it[1]) > TICK * 2.0 + 0.01:
		it = [game.clock, game.clock]
	it[1] = game.clock
	_stay[key] = it
	return game.clock - float(it[0]) >= float(q.get("secs", 0.0))


## Living units (and, for a tag, buildings) by a tag, a team or a side (horses not counted).
func group_of(tag: String, team: String, side: String) -> Array:
	if tag != "":
		return tagged(tag)
	var ts: Array = []
	if team != "":
		ts = [team_index(team)]
	elif side != "":
		ts = teams_of_side(side)
	return game.units.filter(func(u) -> bool: return not u.dead and ts.has(u.team) and u.kind != "horse")


func _pos(e: Entity) -> Vector2:
	return e.position if e is Unit else (e as Building).center()


## NEAR: {"tag" / "team" / "side", "to": tag / "to_team" / "to_side", "within": tiles (3)}.
func near(v: Dictionary) -> bool:
	var a := group_of(String(v.get("tag", "")), String(v.get("team", "")), String(v.get("side", "")))
	var b := group_of(String(v.get("to", "")), String(v.get("to_team", "")), String(v.get("to_side", "")))
	var r := float(v.get("within", 3)) * Defs.TILE
	for x in a:
		for y in b:
			if x != y and _pos(x).distance_to(_pos(y)) <= r:
				return true
	return false


## ROUTE and FOLLOW under way (MissionRun._order starts them): a route moves on when half its living units are at the
## waypoint (a tile round its area), and sends the stragglers on now and then; a follower walks after its leader when
## it is more than "within" away.
func _tick_routes() -> void:
	var keep: Array = []
	for r in _routes:
		var us: Array = (r["units"] as Array).filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)
		r["units"] = us
		if us.is_empty():
			continue
		var pts: Array = r["pts"]
		var rect := area_rect(String(pts[int(r["i"])])).grow(Defs.TILE)
		var inside := us.filter(func(u) -> bool: return rect.has_point(u.position)).size()
		if inside * 2 >= us.size():
			r["i"] = int(r["i"]) + 1
			if int(r["i"]) >= pts.size():
				if bool(r["loop"]):
					r["i"] = 0
				else:
					route_done[String(r["name"])] = game.clock
					if game.mlog:
						game.mlog.add("(mission) route %s done" % r["name"])
					continue
			game.group_move(us, area_rect(String(pts[int(r["i"])])).get_center(), bool(r["attack"]))
			r["t"] = 0.0
		else:
			r["t"] = float(r["t"]) + TICK
			if float(r["t"]) >= 4.0:
				r["t"] = 0.0
				var idle := us.filter(func(u) -> bool: return u.order == "idle")
				if not idle.is_empty():
					game.group_move(idle, rect.get_center(), bool(r["attack"]))
		keep.append(r)
	_routes = keep
	var fk: Array = []
	for f in _follows:
		var us: Array = (f["units"] as Array).filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)
		f["units"] = us
		if us.is_empty():
			continue
		var lead := tagged(String(f["leader"]))
		if lead.is_empty():
			for u in us:
				u.cmd_stop()      # (the one they followed is gone)
			continue
		f["t"] = float(f["t"]) + TICK
		if float(f["t"]) >= 1.0:
			f["t"] = 0.0
			var lp := _pos(lead[0])
			var fr := float(f.get("fight", 0.0))
			if fr > 0.0:
				for u in us:
					if u.target != null and is_instance_valid(u.target) and not u.target.dead:
						continue
					var foe := _foe_near(u, fr)
					if foe and foe.position.distance_to(lp) < fr + float(f["within"]):
						u.cmd_attack(foe)
			var far: Array = []
			for u in us:
				if u.position.distance_to(lp) <= float(f["within"]):
					continue
				if fr > 0.0 and u.target != null and is_instance_valid(u.target) and not u.target.dead and u.position.distance_to(lp) < fr + float(f["within"]) * 2.0:
					continue      # (an escort at its quarry, its leader not too far)
				far.append(u)
			if not far.is_empty():
				game.group_move(far, lp, false)
		fk.append(f)
	_follows = fk


## The nearest living enemy unit within r of u (an escort's quarry), or null.
func _foe_near(u: Unit, r: float) -> Unit:
	var best: Unit = null
	var bd := r
	for e in game.units_near(u.position, r):
		if e.dead or not game.hostile(u.team, e.team) or e.untouchable() or e.kind == "horse":
			continue
		var d: float = u.position.distance_to(e.position)
		if d < bd:
			bd = d
			best = e
	return best


## A SLEEP's name: its "name", else its tag, team or side.
func sleep_name(v: Dictionary) -> String:
	return String(v.get("name", v.get("tag", v.get("team", v.get("side", "sleep")))))


## SLEEP: {"tag" / "team" / "side", "name", "within": tiles (6; 0: only a trigger or a wound wakes them), "by": the
## side whose units wake them (any other side), "hurt": true (a wound wakes them), "then": an order on waking}. The
## units hold where they are and don't fight (a person's own too: the nest asleep) until the group wakes.
## (a03_plateau) "except_kinds": [kinds] leave those awake (the nest's Mother, grubs and Rootmaws keep working while its
## hunters sleep); "keep": true puts every NEW unit of the group to sleep too while it sleeps (the hatchlings of a
## person's sleeping nest).
func sleep_units(v: Dictionary) -> void:
	var nm := sleep_name(v)
	var us := _sleep_group(v)
	for u in us:
		_put_to_sleep(u, nm)
	sleeping[nm] = {"units": us, "within": float(v.get("within", 6)) * Defs.TILE, "by": String(v.get("by", "")),
		"hurt": bool(v.get("hurt", true)), "hp": us.map(func(u) -> float: return u.hp), "then": v.get("then", {}),
		"keep": bool(v.get("keep", false)), "q": v}
	woke.erase(nm)
	if game.mlog:
		game.mlog.add("(mission) %s asleep (%d)" % [nm, us.size()])


func _sleep_group(v: Dictionary) -> Array:
	var no: Array = v.get("except_kinds", [])
	# (a05: "except_tags": those with the tags sleep apart: the young in the ferns, netted, never wake the nest)
	var apart: Array = []
	for tg in v.get("except_tags", []):
		apart.append_array(tags.get(String(tg), []))
	return group_of(String(v.get("tag", "")), String(v.get("team", "")), String(v.get("side", ""))).filter(
		func(e) -> bool: return e is Unit and not no.has(e.kind) and not apart.has(e))


func _put_to_sleep(u: Unit, nm: String) -> void:
	u.set_meta("mission_asleep", nm)
	u.cmd_stop()
	u.target = null
	u.m_pace = 0.0
	u.m_unarmed = true


## WAKE: the group gets up (and carries out its "then" order).
func wake(nm: String) -> void:
	if not sleeping.has(nm) or woke.has(nm):
		return
	woke[nm] = game.clock
	var live: Array = []
	for u in sleeping[nm]["units"]:
		if not is_instance_valid(u) or u.dead:
			continue
		live.append(u)
		u.remove_meta("mission_asleep")
		if not u.has_meta("mission_caged"):
			u.m_pace = 1.0
			u.m_unarmed = false
	var th: Variant = sleeping[nm].get("then", {})
	if th is Dictionary and not (th as Dictionary).is_empty():
		_order(live, th)
	if game.mlog:
		game.mlog.add("(mission) %s woke" % nm)


func _tick_sleep() -> void:
	for nm in sleeping:
		if woke.has(nm):
			continue
		var sl: Dictionary = sleeping[nm]
		var us: Array = sl["units"]
		if bool(sl.get("keep", false)):
			# (a03: newcomers to a sleeping group sleep too: the hatchlings of a person's nest)
			for u in _sleep_group(sl["q"]):
				if not us.has(u) and not u.dead:
					_put_to_sleep(u, nm)
					us.append(u)
					(sl["hp"] as Array).append(u.hp)
		var wake_now := false
		for i in us.size():
			var u = us[i]
			if not is_instance_valid(u) or u.dead or (bool(sl["hurt"]) and u.hp < float(sl["hp"][i]) - 0.01):
				wake_now = bool(sl["hurt"])
				if wake_now:
					break
		var r := float(sl["within"])
		if not wake_now and r > 0.0:
			var live := us.filter(func(u) -> bool: return is_instance_valid(u) and not u.dead)
			if not live.is_empty():
				var my := side_of_team(live[0].team)
				var by := String(sl["by"])
				for e in game.units:
					if e.dead or e.team < 0 or e.kind == "horse":
						continue
					var sd := side_of_team(e.team)
					if sd == my or (by != "" and sd != by):
						continue
					for u in live:
						if u.position.distance_to(e.position) <= r:
							wake_now = true
							break
					if wake_now:
						break
		if wake_now:
			wake(nm)


## THE MIST: {"sight": share of their sight (1 clears it), "team" or "side" (none: everyone), "weather": true (the grey
## over the screen)}. Unit._physics reads sight_of.
func set_mist(v: Dictionary, picture := true) -> void:
	mist_sight = clampf(float(v.get("sight", 1.0)), 0.1, 1.0)
	mist_teams = {}
	if v.has("team"):
		mist_teams[team_index(String(v["team"]))] = true
	elif v.has("side"):
		for t in teams_of_side(String(v["side"])):
			mist_teams[t] = true
	if picture and bool(v.get("weather", true)):
		if mist_sight < 1.0:
			set_weather("mist")
		elif weather_name == "mist":
			set_weather("")
	if game:
		game._vis_t = 0.0


## A unit's sight (tiles) under the mission's MIST.
func sight_of(u: Unit, base: int) -> int:
	if mist_sight >= 1.0 or (not mist_teams.is_empty() and not mist_teams.has(u.team)):
		return base
	return maxi(2, roundi(base * mist_sight))


func _mist_picture(cl: CanvasLayer) -> void:
	var veil := ColorRect.new()
	veil.color = Color(0.8, 0.82, 0.84, 0.26)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cl.add_child(veil)
	var vs := game.get_viewport().get_visible_rect().size if game.is_inside_tree() else Vector2(1600, 900)
	var p := CPUParticles2D.new()
	p.position = vs * 0.5
	p.amount = 24
	p.lifetime = 16.0
	p.preprocess = 16.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = vs * 0.6
	p.direction = Vector2(1, 0)
	p.spread = 20.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 6.0
	p.initial_velocity_max = 16.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 1.6
	var tex := GradientTexture2D.new()
	tex.width = 360
	tex.height = 220
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	var gr := Gradient.new()
	gr.set_color(0, Color(1, 1, 1, 0.22))
	gr.set_color(1, Color(1, 1, 1, 0))
	tex.gradient = gr
	p.texture = tex
	p.color = Color(0.9, 0.92, 0.94, 1)
	cl.add_child(p)


## CAPTURE (objective {"kind": "capture", "tag", "share": 0.25, "within": tiles (3), "by": side (the objective's)}):
## the man can't be brought under that share of his health; there, with one of the capturing side near, he is taken
## (caged and spared: he stays where he was taken, harmless); done when all of the tag are taken, failed if all die.
# ------------------------------------------------------------------ DISGUISED buildings (a01_presses)

## A rectangle round the first living thing with the tag (a building's footprint and two cells round it; a unit's two
## cells round); an empty rectangle when there is none.
func near_rect(tag: String) -> Rect2:
	for e in tagged(tag):
		if e is Building:
			return e.rect().grow(Defs.TILE * 2.0)
		return Rect2(e.position - Vector2(Defs.TILE, Defs.TILE) * 2.0, Vector2(Defs.TILE, Defs.TILE) * 4.0)
	return Rect2()


## A building DISGUISED ("disguise": {"as": team id, "within": tiles, "by": side, "secs": s}): to every other side it
## wears the team `as`'s colour (on the map, the minimap, its card), nobody targets it or hurts it (spared), until a unit
## of a side hostile to it (of `by` only, if given) stands within `within` tiles (3) of its edge for `secs` seconds (0:
## at once; a man marching past doesn't see in, one who stops at the door does): then it is UNMASKED.
func disguise(b: Entity, v: Dictionary) -> void:
	var dt := team_index(String(v.get("as", "")))
	if dt < 0 or b == null:
		return
	b.set_meta("disguise_team", dt)
	b.set_meta("disguise", {"within": float(v.get("within", 3.0)) * Defs.TILE, "by": String(v.get("by", "")), "secs": float(v.get("secs", 0.0))})
	b.spared = true
	b.refresh_cloth()
	if not _disguised.has(b):
		_disguised.append(b)


## Given away: its own colour, open to attack, a ping; `unmasked` keeps its tags (the condition).
func unmask(b: Entity) -> void:
	_disguised.erase(b)
	if not is_instance_valid(b) or not b.has_meta("disguise_team"):
		return
	b.remove_meta("disguise_team")
	b.remove_meta("disguise")
	b.spared = false
	b.refresh_cloth()
	b.queue_redraw()
	for tg in tags:
		if (tags[tg] as Array).has(b):
			unmasked[String(tg)] = game.clock
	game._ping(b.center(), Color(1.0, 0.55, 0.3))
	_send({"k": "ping", "p": b.center()})
	if game.mlog:
		game.mlog.add("(mission) unmasked %s" % String(b.get_meta("mission_tag", b.kind)))


func _tick_disguise() -> void:
	if _disguised.is_empty():
		return
	for b in _disguised.duplicate():
		if not is_instance_valid(b) or b.dead:
			_disguised.erase(b)
			continue
		var dv: Dictionary = b.get_meta("disguise", {})
		var within := float(dv.get("within", 3.0 * Defs.TILE))
		var by := String(dv.get("by", ""))
		var secs := float(dv.get("secs", 0.0))
		var near_one := false
		for u in game.units:
			if u.dead or u.off_field or not game.hostile(u.team, b.team):
				continue
			if by != "" and side_of_team(u.team) != by:
				continue
			if b.edge_distance(u.position) <= within:
				near_one = true
				break
		if not near_one:
			if b.has_meta("disguise_since"):
				b.remove_meta("disguise_since")
			continue
		if not b.has_meta("disguise_since"):
			b.set_meta("disguise_since", game.clock)
		if game.clock - float(b.get_meta("disguise_since")) >= secs - 0.001:
			unmask(b)


func _check_capture(o: Dictionary) -> void:
	var oid := String(o["id"])
	var tag := String(o.get("tag", ""))
	var share := float(o.get("share", 0.25))
	var r := float(o.get("within", 3)) * Defs.TILE
	var by := String(o.get("by", o.get("side", "")))
	var us := tagged(tag)
	if us.is_empty():
		if tags.has(tag) and not captured.has(tag):
			set_objective(oid, "failed")
		return
	var all_taken := true
	for e in us:
		if e.has_meta("mission_captured"):
			continue
		var fl: float = e.max_hp * share
		e.hp_floor = maxf(e.hp_floor, fl)
		if e.hp <= fl + 0.5 and group_of("", "", by).any(func(c) -> bool: return c != e and c.position.distance_to(_pos(e)) <= r):
			take_captive(e)
		else:
			all_taken = false
	if all_taken:
		captured[tag] = true
		set_objective(oid, "done")


## A man taken: he stays where he was taken (caged), harmless and spared.
func take_captive(e: Entity) -> void:
	e.set_meta("mission_captured", true)
	e.spared = true
	if e is Unit:
		e.cmd_stop()
		e.m_pace = 0.0
		e.m_unarmed = true
		e.set_meta("mission_caged", true)
		_caged.append([e, e.position])
	if game.mlog:
		game.mlog.add("(mission) a %s taken alive" % e.kind)


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


## Worked out: a Mill or Farm whose ground is spent, a Rootmaw that has drunk its swamp dry. It takes no crew, so a
## lesson's "2 on each" counts it as done (a slow player's home Rootmaw ran dry and "Put 2 grubs on each Rootmaw"
## could never be done; playtest 2026-11-21).
func _spent(e: Entity) -> bool:
	if e is Building:
		return (e as Building).barren()
	if e is Unit and BroodNew.is_source(e):
		var u := e as Unit
		return float(u.nb.get("food", 0.0)) < 1.0 and BroodNew.ground_left(game, u) < 1.0
	return false


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
				if e.team == game.human and not e.dead and kinds.has(e.kind) \
						and (WorkerLabels.workers(game, e).size() >= at_least or _spent(e)):
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


# ------------------------------------------------------------------ SAVING A MISSION (player-comforts)
# A mission is saved with the match (SaveGame.capture: "mission"): every number, flag, clock and list the triggers
# read, with the units and buildings it holds written as their place in the save's own lists ({"@u": n}, {"@b": n}).
# Godot's var_to_str keeps whole numbers whole (a flag 3 stays 3, never 3.0) and Vector2s as they are. Each unit and
# building also keeps what the mission put on it ("mx": its tag, name, role, cage, sleep, disguise, floor...). Saved in
# a solo match only (not online, not a tutorial lesson): docs/player_comforts.md.

## The MissionRun's own state that a save keeps (everything else comes from the mission's data again).
const SAVE_KEYS := ["obj", "fired", "_met", "reveals", "said_ids", "winner_side", "_side_had", "flags", "choice_open",
	"light_name", "counters", "clocks", "deny", "_next", "_times", "_turning", "_caged", "_burning", "out_sides", "fires_out",
	"_stay", "route_done", "_routes", "_follows", "sleeping", "woke", "mist_sight", "mist_teams", "captured", "weather_name",
	"_disguised", "unmasked", "_carts", "tags", "checkpoints", "act2"]
## The metas the mission puts on a unit or building that a save keeps (object metas, "on_cart" / "cage_cargo", come back
## from the carts' list).
const SAVE_METAS := ["mission_tag", "mission_name", "rebel_role", "torch_burning", "torch_t", "disguise_team", "disguise",
	"disguise_since", "mission_asleep", "mission_caged", "mission_captured", "mission_root", "cart_mass"]

signal checkpoint_wanted(why: String)      # a part began or a primary objective was met: Main keeps a CHECKPOINT
var checkpoints := {}                       # why -> game clock: the checkpoints taken so far (one each)
var _cp_due := ""                           # a checkpoint asked for, taken at the end of this tick


## May this mission be saved? Solo, not a lesson, not a guest's or a replay's copy.
func saveable() -> bool:
	return mode == "solo" and not remote and not bool(data.get("tutorial", false)) and game != null \
		and game.net == null and game.replay == null and not game.demo


## The state as text (var_to_str), entities as their numbers in the save's lists (`uid`: unit -> n, `bid`: building -> n).
func save_state(uid: Dictionary, bid: Dictionary) -> String:
	var st := {}
	for k in SAVE_KEYS:
		st[k] = pack(get(k), uid, bid)
	return var_to_str(st)


## A value with its units and buildings turned into {"@u": n} / {"@b": n} (gone or not saved: null).
static func pack(v: Variant, uid: Dictionary, bid: Dictionary) -> Variant:
	match typeof(v):
		TYPE_OBJECT:
			if v == null or not is_instance_valid(v):
				return null
			if uid.has(v):
				return {"@u": uid[v]}
			if bid.has(v):
				return {"@b": bid[v]}
			return null
		TYPE_ARRAY:
			var out: Array = []
			for x in v:
				out.append(pack(x, uid, bid))
			return out
		TYPE_DICTIONARY:
			var od := {}
			for k in v:
				od[k] = pack(v[k], uid, bid)
			return od
	return v


## The other way: {"@u": n} back to the unit made for it (`mu`: the units in the save's order, `mb`: the buildings).
static func unpack(v: Variant, mu: Array, mb: Array) -> Variant:
	match typeof(v):
		TYPE_ARRAY:
			var out: Array = []
			for x in v:
				out.append(unpack(x, mu, mb))
			return out
		TYPE_DICTIONARY:
			if v.size() == 1 and (v.has("@u") or v.has("@b")):
				var i := int(v["@u"] if v.has("@u") else v["@b"])
				var lst: Array = mu if v.has("@u") else mb
				var e: Variant = lst[i] if i >= 0 and i < lst.size() else null
				return e if e != null and is_instance_valid(e) else null
			var od := {}
			for k in v:
				od[k] = unpack(v[k], mu, mb)
			return od
	return v


## What the mission put on one unit or building (SaveGame.capture's "mx"), as text; "" when nothing.
func save_entity(e: Entity, uid: Dictionary, bid: Dictionary) -> String:
	var x := {}
	for mk in SAVE_METAS:
		if e.has_meta(mk):
			x["m:" + mk] = e.get_meta(mk)
	if e.spared:
		x["spared"] = true
	if e.hp_floor > 0.0:
		x["floor"] = e.hp_floor
	if e is Unit:
		var u: Unit = e
		if u.m_pace != 1.0:
			x["pace"] = u.m_pace
		if u.m_unarmed:
			x["unarmed"] = true
		if u.nb_mass != 1.0 and not u.has_meta("on_cart"):
			x["mass"] = u.nb_mass
		# (its order: a scripted wave on the march goes on after a load; a save of a skirmish drops orders)
		if u.order in ["move", "amove", "attack", "hold"]:
			x["o"] = [u.order, u.order_point, pack(u.order_target, uid, bid)]
	if x.is_empty():
		return ""
	x["hp"] = e.hp       # (a hero's role raises his health above the stand-in's: his health is set again after it)
	return var_to_str(x)


## After SaveGame.restore made every unit and building again: the mission's state and what it put on each.
## `d`: the save; `mu` / `mb`: the made units and buildings in the save's order (null where one couldn't be made).
func load_state(d: Dictionary, mu: Array, mb: Array) -> void:
	# what the mission put on each one: its role first (a hero's art, scale and health), then the rest
	var lists := [[d.get("units", []), mu], [d.get("buildings", []), mb]]
	var orders: Array = []
	for pair in lists:
		var src: Array = pair[0]
		var made: Array = pair[1]
		for i in mini(src.size(), made.size()):
			var e = made[i]
			var s := String((src[i] as Dictionary).get("mx", ""))
			if e == null or not is_instance_valid(e) or s == "":
				continue
			var x: Variant = str_to_var(s)
			if not (x is Dictionary):
				continue
			if e is Unit and x.has("m:rebel_role"):
				Rebels.apply(e, String(x["m:rebel_role"]))
			for k in x:
				if String(k).begins_with("m:"):
					e.set_meta(String(k).substr(2), x[k])
			e.spared = bool(x.get("spared", false))
			e.hp_floor = float(x.get("floor", 0.0))
			e.hp = minf(float(x.get("hp", e.hp)), e.max_hp)
			if e is Unit:
				e.m_pace = float(x.get("pace", 1.0))
				e.m_unarmed = bool(x.get("unarmed", false))
				if x.has("mass"):
					e.nb_mass = float(x["mass"])
				if x.get("o") is Array:
					orders.append([e, x["o"]])
			if e.has_meta("disguise_team") and e is Building:
				e.refresh_cloth()
			e.queue_redraw()
	var st: Variant = str_to_var(String(d.get("mission", "")))
	if not (st is Dictionary):
		return
	for k in SAVE_KEYS:
		if (st as Dictionary).has(k):
			set(k, unpack(st[k], mu, mb))
	a2 = MissionAct2.new(self)      # (act2-engine0: its state was loaded; the marks it keeps on units put back)
	a2.after_load()
	# the cages on the carts: their bars and ties back
	for it in _carts:
		var u = it.get("u")
		var c = it.get("cart")
		if u == null or c == null:
			continue
		u.set_meta("on_cart", c)
		u.set_meta("mission_caged", true)
		c.set_meta("cage_cargo", u)
		u.nb_mass = 0.001
		if u.get_node_or_null("CageBars") == null:
			var bars := CageBars.new()
			bars.name = "CageBars"
			bars.r = u.radius
			u.add_child(bars)
	# the orders under way (a wave sent at the barns walks on)
	for o in orders:
		var u: Unit = o[0]
		var ov: Array = unpack(o[1], mu, mb)
		var tgt = ov[2] if ov.size() > 2 else null
		match String(ov[0]):
			"move", "amove":
				u._start({"o": String(ov[0]), "p": ov[1]})
			"attack":
				if tgt != null and is_instance_valid(tgt) and not tgt.dead:
					u._start({"o": "attack", "e": tgt})
			"hold":
				u.cmd_hold()
	# the scene as it was: the light, the weather, the mist
	set_light(light_name, 0.0)
	if weather_name != "":
		set_weather(weather_name)
	elif weather_node:
		set_weather("")
	for t in team_ids.size():
		game._recount_supply(t)
	_t = 0.0
	objectives_changed.emit()
	if not choice_open.is_empty():
		choice_offered.emit(choice_open)
	if game.mlog:
		game.mlog.add("(mission) continued from a save")


## A CHECKPOINT is due: a trigger called "part..." fired (Part 2, Part 3: "part2", "part3_go"; not "party"), or a primary
## objective of the player's side was met. Taken at the end of the tick (Main writes it: Main.mission_checkpoint).
func _want_checkpoint(why: String) -> void:
	if not saveable() or checkpoints.has(why) or game.over:
		return
	_cp_due = why


func _take_checkpoint() -> void:
	if _cp_due == "" or game.over:
		_cp_due = ""
		return
	var why := _cp_due
	_cp_due = ""
	checkpoints[why] = game.clock
	if game.mlog:
		game.mlog.add("(mission) checkpoint: %s" % why)
	checkpoint_wanted.emit(why)


static func is_part_trigger(tid: String) -> bool:
	return tid.begins_with("part") and not tid.begins_with("party")


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
		"mist":
			if m.get("v") is Dictionary:
				set_mist(m["v"])
		"wx":
			set_weather(String(m.get("w", "")))
		"show":
			var pg := pages_now(m.get("pages", []))
			if not pg.is_empty():
				shows.append(pg)
				_show_pages(pg)
		"cam":
			var s := String(m.get("s", ""))
			if s == "" or s == my_side():
				game.camera.position = m.get("p", game.camera.position)
