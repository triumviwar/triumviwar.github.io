class_name MissionAct3
extends RefCounted
## ACT 3's ENGINE STEP 0 (act3-engine0, docs/act3_engine0.md; the plan: docs/campaign_act3_plan.md, "Proposed BUILD
## ORDER" 1 and "The engine work Act 3 needs"). The mission engine's new pieces for Act 3's missions, kept apart from
## MissionRun as MissionAct2 is: MissionRun calls tick() four times a second and frame() every frame, and asks cond(),
## act() and order() for the keys neither it nor MissionAct2 knows. Every piece is data in the mission's JSON
## (docs/campaign_engine.md, "Added by Act 3's engine step 0"):
##   THE CLIMATE (mission "climate", action "climate": cold slows the Brood's hatching, its FROST LINE kills eggs and can
##   move with the day and the night; the wet runs the Clockwork's wind down faster; dry heat slows the Brood a little),
##   THE STOP-WORK ("stop_work", "stopped"), THE MADE CALL ("made_call", "called"), WARMTH ("warmth", "cold"), THE FLIGHT
##   PART ("flight", "flown", "marked"), THE LEDGER ("ledger": the count shown, its band), THE NIGHT's ORDER (the
##   "night" condition: Campaign.night_rank), THE FINAL CHOICE (a choice with "final": no timer, the match held) and
##   THE ENDING ("ending": what the credits and the hub remember).
## Its state lives in MissionRun.act3 (saved with the mission: MissionRun.SAVE_KEYS). The campaign-wide pieces (the
## ledger's marks, the night's groups, the ladder in any order, the credits) are in Campaign and CampaignCredits.

const FROST_KILL := 20.0        # THE FROST LINE: seconds an egg lives on the frozen side (default)
const COLD_EVERY := 1.0         # WARMTH: the cold bites once a second

var run: MissionRun
var st: Dictionary              # = run.act3
var under: Node2D = null        # the frost (under the units)
var over: Node2D = null         # rings, words, marks
var _cold_t := 0.0
var _card: Control = null       # the LEDGER's card while it is up


func _init(r: MissionRun) -> void:
	run = r
	st = r.act3
	for k in ["stops", "calls", "warmth", "flights"]:
		if not st.has(k):
			st[k] = []
	for k in ["stopped", "called", "marked", "flown", "climate"]:
		if not st.has(k):
			st[k] = {}
	if run.data.get("climate") is Dictionary and st["climate"].is_empty():
		st["climate"] = (run.data["climate"] as Dictionary).duplicate(true)
	_apply_pace()


# ------------------------------------------------------------------ the drawing layers

func ensure_nodes() -> void:
	var g := run.game
	if g == null:
		return
	if under == null or not is_instance_valid(under):
		under = Node2D.new()
		under.name = "Act3Under"
		under.z_index = -16
		under.draw.connect(_draw_under)
		g.add_child(under)
	if over == null or not is_instance_valid(over):
		over = Node2D.new()
		over.name = "Act3Over"
		over.z_index = 51
		over.draw.connect(_draw_over)
		g.add_child(over)


func _redraw() -> void:
	if under and is_instance_valid(under):
		under.queue_redraw()
	if over and is_instance_valid(over):
		over.queue_redraw()


func _tile() -> float:
	return float(Defs.TILE)


func _viewer() -> String:
	return run.a2._viewer_side() if run.a2 != null else ""


func _sees_all() -> bool:
	return run.game.sees_all()


func _alive(e: Variant) -> bool:
	return e != null and is_instance_valid(e) and not e.dead


func _group(v: Dictionary, buildings := false) -> Array:
	return run.a2.group(v, buildings)


func _place(at: Variant) -> Vector2:
	return run.a2.place(at)


static func _pos(e: Entity) -> Vector2:
	return e.position if e is Unit else e.center()


func _add_counter(name: String, n: int) -> void:
	if name != "" and n != 0 and run.counters.has(name):
		run.act({"counter": {"name": name, "add": n}})


static func _between(n: int, q: Dictionary) -> bool:
	return (not q.has("at_least") or n >= int(q["at_least"])) and (not q.has("below") or n < int(q["below"]))


## The units of a faction ("faction": "clockwork") or of a tag / team / side.
func _of(q: Dictionary) -> Array:
	if q.has("faction"):
		var f := String(q["faction"])
		return run.game.units.filter(func(u) -> bool: return not u.dead and String(u.d.get("faction", "")) == f and u.kind != "horse")
	return _group(q)


# ------------------------------------------------------------------ the tick

func tick(dt: float) -> void:
	ensure_nodes()
	_tick_climate(dt)
	_tick_stops()
	_tick_calls()
	_tick_warmth(dt)
	_tick_marks()
	_redraw()


## Every frame: the flyers on their flights.
func frame(dt: float) -> void:
	if st["flights"].is_empty():
		return
	var g := run.game
	for f in st["flights"]:
		if bool(f.get("done", false)):
			continue
		var u = f.get("u")
		if not _alive(u):
			f["done"] = true
			continue
		var pts: Array = f["pts"]
		var i := int(f.get("i", 0))
		if i >= pts.size():
			_flight_done(f)
			continue
		var to: Vector2 = pts[i]
		var step := float(f.get("speed", 60.0)) * dt
		var d: Vector2 = to - u.position
		if d.length() <= step:
			u.position = to
			f["i"] = i + 1
		else:
			u.position += d.normalized() * step
		u.velocity = Vector2.ZERO
		g.note_move(u)


# ================================================================== THE CLIMATE (e02, e04, e07, e08, e10, e15, e20)

## {"climate": {"cold": {"hatch": 0.5, "frost": {"row": 40, "side": "north", "kill": 20, "night_row": 60, "period": 240,
## "phase": 0}}, "wet": {"wind": 1.6}, "heat": {"pace": 0.9, "faction": "brood"}}} (the mission's key, or an action
## that changes it mid-match; {"climate": {"off": true}} lifts it). THE COLD: every Brood egg on the map hatches at
## `hatch` of its pace (incubation and the father's breath are not slowed: only the time to hatch); the FROST LINE
## (a row of cells, the frozen side "north" = rows above it, "south" = below) kills an egg that lies on the frozen
## side `kill` seconds. With "night_row" and "period" the line moves from `row` (noon) to `night_row` (midnight) and
## back, as the highland nights come down (e07). THE WET: every Clockwork machine's wind runs down `wind` times as fast
## (the Winders who wind themselves too). THE HEAT: the faction (the Brood) walks at `pace`.
func climate(v: Dictionary) -> void:
	if bool(v.get("off", false)):
		st["climate"] = {}
	else:
		var c: Dictionary = st["climate"]
		for k in v:
			c[String(k)] = v[k]
		st["climate"] = c
	_apply_pace()
	if run.game and run.game.mlog:
		run.game.mlog.add("(mission) climate: %s" % str(st["climate"].keys()))


func _apply_pace() -> void:
	run.climate_pace = {}
	var h: Variant = st["climate"].get("heat", null)
	if h is Dictionary:
		run.climate_pace[String(h.get("faction", "brood"))] = clampf(float(h.get("pace", 0.9)), 0.2, 1.0)


## The frost line now: [row, frozen side ("north" / "south")], or [] none.
func frost_line() -> Array:
	var cd: Variant = st["climate"].get("cold", null)
	if not (cd is Dictionary) or not (cd.get("frost", null) is Dictionary):
		return []
	var fr: Dictionary = cd["frost"]
	var row := float(fr.get("row", 0))
	if fr.has("night_row") and float(fr.get("period", 0.0)) > 0.0:
		var clock := run.game.clock if run.game else 0.0
		var k := 0.5 - 0.5 * cos(TAU * (clock + float(fr.get("phase", 0.0))) / float(fr["period"]))     # 0 noon .. 1 midnight
		row = lerpf(row, float(fr["night_row"]), k)
	return [row, String(fr.get("side", "north"))]


## A place on the frozen side of the frost line.
func frozen_at(p: Vector2) -> bool:
	var fl := frost_line()
	if fl.is_empty():
		return false
	var r := p.y / _tile()
	return r < float(fl[0]) if String(fl[1]) == "north" else r > float(fl[0])


func _tick_climate(dt: float) -> void:
	var c: Dictionary = st["climate"]
	if c.is_empty():
		return
	var g := run.game
	var cd: Variant = c.get("cold", null)
	if cd is Dictionary:
		var hk := clampf(float(cd.get("hatch", 1.0)), 0.0, 1.0)
		var kill := float((cd.get("frost", {}) as Dictionary).get("kill", FROST_KILL)) if cd.get("frost") is Dictionary else FROST_KILL
		for e in g.units:
			if e.dead or e.kind != BroodNew.EGG or e.nb.has("out"):
				continue
			if hk < 1.0 and int(e.nb.get("fert", 0)) != 1:
				# (the egg's own clock is moved on by BroodNew.egg_tick: here it is held back by the cold's share)
				e.nb["t"] = maxf(0.0, float(e.nb.get("t", 0.0)) - dt * (1.0 - hk))
			if frozen_at(e.position):
				var ft := float(e.get_meta("act3_frost", 0.0)) + dt
				e.set_meta("act3_frost", ft)
				if ft >= kill:
					_add_counter(String((cd.get("frost", {}) as Dictionary).get("counter", "")), 1)
					st["marked"]["frost"] = int(st["marked"].get("frost", 0)) + 1
					run.a2._say_float(e.position + Vector2(0, -20), "FROZEN", Color(0.7, 0.9, 1.0))
					e.take_damage(e.hp + 999.0, null)
			elif e.has_meta("act3_frost"):
				e.remove_meta("act3_frost")
	var wt: Variant = c.get("wet", null)
	if wt is Dictionary:
		var extra := maxf(0.0, float(wt.get("wind", 1.5)) - 1.0) * Defs.WIND_DECAY * dt
		if extra > 0.0:
			for u in g.units:
				if not u.dead and String(u.d.get("faction", "")) == "clockwork" and u.wind > 0.0:
					u.wind = maxf(0.0, u.wind - extra * float(u.d.get("wind_drain", 1.0)))


# ================================================================== THE STOP-WORK (e09, e17, e20)

## {"stop_work": {"at": area / [x, y] / tag, "within": 12, "secs": 60, "faction": "clockwork" (default) / "team" / "side" /
## "tag", "spare": side (its machines go on: the guild's own), "name", "counter"}}: Hollweg's pattern rung on a bell:
## every Clockwork machine of them within `within` tiles of the bell runs down to nothing and stays so for `secs`
## seconds (one that walks into the ring stops too); then the Winders and fields wind them as ever. THE BRAKE with a
## radius and an end. {"stopped": {"name", "at_least"}}: machines it stopped; {"stopping": name}: it rings now.
func stop_work(v: Dictionary) -> void:
	var p := _place(v.get("at", ""))
	if p == Vector2.INF:
		return
	var nm := String(v.get("name", "stop_work"))
	var q: Dictionary = v.duplicate()
	if not (q.has("faction") or q.has("team") or q.has("side") or q.has("tag")):
		q["faction"] = "clockwork"
	st["stops"] = (st["stops"] as Array).filter(func(s) -> bool: return String(s["name"]) != nm)
	st["stops"].append({"name": nm, "q": q, "pos": p, "r": float(v.get("within", 12.0)) * _tile(),
		"t0": run.game.clock, "until": run.game.clock + float(v.get("secs", 60.0)), "hit": []})
	if not st["stopped"].has(nm):
		st["stopped"][nm] = 0
	run.play_sound("campaign/bell_toll", "", 0.0)
	run.game._ping(p, Color(1.0, 0.85, 0.4))
	run._send({"k": "ping", "p": p})
	run.a2._say_float(p + Vector2(0, -40), "STOP-WORK", Color(1.0, 0.85, 0.4))
	_tick_stops()


func _tick_stops() -> void:
	var g := run.game
	var keep: Array = []
	for s in st["stops"]:
		if g.clock >= float(s["until"]):
			if g.mlog:
				g.mlog.add("(mission) the stop-work %s ends (%d stopped)" % [s["name"], int(st["stopped"].get(s["name"], 0))])
			continue
		keep.append(s)
		var spare := String(s["q"].get("spare", ""))
		var hit: Array = s["hit"]
		for u in _of(s["q"]):
			if String(u.d.get("faction", "")) != "clockwork" or (spare != "" and run.side_of_team(u.team) == spare):
				continue
			if u.position.distance_to(s["pos"]) > float(s["r"]):
				continue
			u.wind = 0.0
			if not hit.has(u):
				hit.append(u)        # (the unit itself: saved as {"@u": n}, so a loaded game goes on counting)
				st["stopped"][s["name"]] = int(st["stopped"].get(s["name"], 0)) + 1
				_add_counter(String(s["q"].get("counter", "")), 1)
	st["stops"] = keep


func stopping(u: Unit) -> bool:
	for s in st["stops"]:
		if u.position.distance_to(s["pos"]) <= float(s["r"]) and String(u.d.get("faction", "")) == "clockwork":
			return true
	return false


# ================================================================== THE MADE CALL (e20; the ruin opened)

## {"made_call": {"at", "within": 25, "secs": 60, "tag" / "team" / "side" (default every Brood team), "to": area, "name",
## "counter"}}: Lindqvist's call from the records: for `secs` seconds every SCRIPTED creature of them that comes within
## `within` tiles of the caller turns off its road and goes to `to` (the marsh), once each (a person's creatures are
## never pulled: the call is for waves). d08's lure post with a time instead of one pull. {"called": {"name",
## "at_least"}}; {"calling": name}: it sounds now.
func made_call(v: Dictionary) -> void:
	var p := _place(v.get("at", ""))
	if p == Vector2.INF or not (run.data.get("areas", {}) as Dictionary).has(String(v.get("to", ""))):
		return
	var nm := String(v.get("name", "made_call"))
	var q: Dictionary = v.duplicate()
	if not (q.has("team") or q.has("side") or q.has("tag")):
		q["faction"] = "brood"
	st["calls"] = (st["calls"] as Array).filter(func(s) -> bool: return String(s["name"]) != nm)
	st["calls"].append({"name": nm, "q": q, "pos": p, "r": float(v.get("within", 25.0)) * _tile(),
		"t0": run.game.clock, "until": run.game.clock + float(v.get("secs", 60.0)), "to": String(v["to"]), "hit": []})
	if not st["called"].has(nm):
		st["called"][nm] = 0
	run.play_sound("campaign/linnea_call", "", 0.0)
	run.game._ping(p, Color(0.5, 1.0, 0.4))
	run._send({"k": "ping", "p": p})
	run.a2._say_float(p + Vector2(0, -40), "THE MADE CALL", Color(0.6, 1.0, 0.5))
	_tick_calls()


func _tick_calls() -> void:
	var g := run.game
	var keep: Array = []
	for s in st["calls"]:
		if g.clock >= float(s["until"]):
			continue
		keep.append(s)
		var hit: Array = s["hit"]
		var us: Array = []
		for u in _of(s["q"]):
			if run.player_teams.has(u.team) or u.kind == BroodNew.EGG or u.position.distance_to(s["pos"]) > float(s["r"]):
				continue
			if hit.has(u):
				continue
			hit.append(u)
			us.append(u)
		if not us.is_empty():
			st["called"][s["name"]] = int(st["called"].get(s["name"], 0)) + us.size()
			_add_counter(String(s["q"].get("counter", "")), us.size())
			run._order(us, {"do": "move", "to": String(s["to"])})
			if g.mlog:
				g.mlog.add("(mission) the made call %s turned %d" % [s["name"], us.size()])
	st["calls"] = keep


# ================================================================== WARMTH (e15: the Cold Forge)

## {"warmth": {"tag" / "team" / "side": who feels the cold, "fires": tag (a brazier, a building, a man with a torch),
## "within": 5, "loss": 1.0 (% of the unit's health a second out of every fire's ring), "floor": 0.0 (a share it never
## goes under: 0 = the cold can kill), "name", "counter" (counts the cold's dead), "on"}}: out of every warm ring, a
## unit loses its health slowly (COLD over it, for its own side); back by a fire it stops. {"cold": {"name",
## "at_least"}}: how many are out in the cold now.
func warmth(v: Dictionary) -> void:
	var nm := String(v.get("name", v.get("fires", "warmth")))
	st["warmth"] = (st["warmth"] as Array).filter(func(w) -> bool: return String(w["name"]) != nm)
	if bool(v.get("on", true)):
		st["warmth"].append({"name": nm, "q": v.duplicate(), "cold": 0})


func _fires(tag: String) -> Array:
	return run.tagged(tag).filter(func(e) -> bool: return _alive(e))


func warm_at(w: Dictionary, p: Vector2) -> bool:
	var r := float(w["q"].get("within", 5.0)) * _tile()
	for f in _fires(String(w["q"].get("fires", ""))):
		if _pos(f).distance_to(p) <= r + (float(f.radius) if f is Unit else 0.0):
			return true
	return false


func _tick_warmth(dt: float) -> void:
	if st["warmth"].is_empty():
		return
	_cold_t -= dt
	var bite := _cold_t <= 0.0
	if bite:
		_cold_t = COLD_EVERY
	for w in st["warmth"]:
		var n := 0
		var q: Dictionary = w["q"]
		var loss := float(q.get("loss", 1.0)) / 100.0
		var floor_k := float(q.get("floor", 0.0))
		for u in _group(q):
			if u.dead or u.kind == "horse" or warm_at(w, u.position):
				if u.has_meta("act3_cold"):
					u.remove_meta("act3_cold")
				continue
			n += 1
			u.set_meta("act3_cold", true)
			if bite:
				var amt: float = u.max_hp * loss * COLD_EVERY
				if floor_k > 0.0:
					amt = minf(amt, maxf(0.0, u.hp - u.max_hp * floor_k))
				if amt > 0.0:
					var dies: bool = u.hp <= amt
					u.take_damage(amt, null)
					if dies or u.dead:
						_add_counter(String(q.get("counter", "")), 1)
		w["cold"] = n


func cold_count(nm: String) -> int:
	for w in st["warmth"]:
		if String(w["name"]) == nm:
			return int(w.get("cold", 0))
	return 0


# ================================================================== THE FLIGHT PART (e05: Father Inácio's flight)

## {"flight": {"tag": the flyer (the balloon), "route": [areas or [x, y]], "speed": 60 (px a second), "mark": tag (what
## its watchers mark), "within": 8 (tiles it sees to mark), "for": side (whose marks: the flyer's), "reveal": true (a
## marked one stays on that side's screen), "name", "counter"}}: the flyer goes along the route by itself (its route,
## not its orders: the story's flight), and every one of the `mark` tag that comes within `within` tiles is MARKED
## for good: pinged, a ring round it, counted. {"flown": name} at the end of the route; {"marked": {"name",
## "at_least"}}. The flyer's own sight lifts the fog as it goes, as any flyer's.
func flight(v: Dictionary) -> void:
	var us: Array = run.tagged(String(v.get("tag", ""))).filter(func(e) -> bool: return e is Unit and not e.dead)
	if us.is_empty():
		return
	var u: Unit = us[0]
	var pts: Array = []
	for w in v.get("route", []):
		var p := _place(w)
		if p != Vector2.INF:
			pts.append(p)
	var nm := String(v.get("name", v.get("tag", "flight")))
	st["flights"] = (st["flights"] as Array).filter(func(f) -> bool: return String(f["name"]) != nm)
	var side := String(v.get("for", run.side_of_team(u.team)))
	st["flights"].append({"name": nm, "u": u, "pts": pts, "i": 0, "speed": float(v.get("speed", 60.0)),
		"mark": String(v.get("mark", "")), "r": float(v.get("within", 8.0)) * _tile(), "side": side,
		"reveal": bool(v.get("reveal", true)), "counter": String(v.get("counter", "")), "done": false, "seen": []})
	if not st["marked"].has(nm):
		st["marked"][nm] = 0
	u.set_meta("act3_flight", nm)
	if u.has_method("cmd_stop"):
		u.cmd_stop()


func _flight_done(f: Dictionary) -> void:
	f["done"] = true
	st["flown"][String(f["name"])] = true
	var u = f.get("u")
	if _alive(u) and u.has_meta("act3_flight"):
		u.remove_meta("act3_flight")
	run.objectives_changed.emit()
	if run.game.mlog:
		run.game.mlog.add("(mission) the flight %s is flown (%d marked)" % [f["name"], int(st["marked"].get(f["name"], 0))])


func _tick_marks() -> void:
	var g := run.game
	for f in st["flights"]:
		var u = f.get("u")
		if bool(f.get("done", false)) or not _alive(u) or String(f["mark"]) == "":
			continue
		for e in run.tagged(String(f["mark"])):
			if not _alive(e) or e.has_meta("act3_marked"):
				continue
			if _pos(e).distance_to(u.position) <= float(f["r"]):
				e.set_meta("act3_marked", [String(f["side"]), bool(f["reveal"])])
				f["seen"].append(e)
				st["marked"][f["name"]] = int(st["marked"].get(f["name"], 0)) + 1
				_add_counter(String(f["counter"]), 1)
				if f["side"] == _viewer() or _sees_all():
					g._ping(_pos(e), Color(1.0, 0.95, 0.5))
					g.float_text(_pos(e) + Vector2(0, -30), "MARKED", Color(1.0, 0.95, 0.5))
				run.objectives_changed.emit()


## Game._update_vis asks after its own loop (through MissionRun.after_vis): a marked one stays on its marker's screen.
func after_vis(ft: int) -> void:
	if ft < 0:
		return
	var side := run.side_of_team(ft)
	for f in st["flights"]:
		if String(f["mark"]) == "" or not bool(f["reveal"]) or String(f["side"]) != side:
			continue
		for e in run.tagged(String(f["mark"])):
			if _alive(e) and e.has_meta("act3_marked"):
				e.visible = true


# ================================================================== THE LEDGER (e20)

## {"ledger": {"counter": name (set to the count), "show": true (the card: every mark, held or not, and the band),
## "title", "flag": "ledger_band"}}: Campaign.ledger() counted now; the mission keeps the count in its flags ("ledger"
## and the band in "ledger_band", or the flag named), so every unit, wave and line can read {"ledger": {"band"}} /
## {"ledger": {"mark"}} / {"ledger": {"at_least"}}; solo the card holds the match until CLOSE.
func ledger(v: Dictionary) -> void:
	var lg := Campaign.ledger()
	run.flags["ledger"] = int(lg["count"])
	run.flags[String(v.get("flag", "ledger_band"))] = String(lg["band"])
	if String(v.get("counter", "")) != "":
		run.counters[String(v["counter"])] = int(lg["count"])
	if run.game and run.game.mlog:
		run.game.mlog.add("(mission) the ledger: %d marks, %s" % [int(lg["count"]), lg["band"]])
	run.objectives_changed.emit()
	if bool(v.get("show", true)) and not run.remote:
		show_ledger(lg, String(v.get("title", "THE LEDGER")))


## The LEDGER's card: the marks the campaign brought (held: bright with a tick; not: dim), the count and the band in
## plain words (SAY IT PLAINLY: the heir sees the real stakes before the choice).
func show_ledger(lg: Dictionary, title := "THE LEDGER") -> void:
	if run.game == null or run.game.hud == null:
		return
	if _card and is_instance_valid(_card):
		_card.queue_free()
	var parent: Node = run.game.hud.get_parent()
	var o := Control.new()
	o.name = "LedgerCard"
	o.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.theme = UiStyle.theme()
	o.process_mode = Node.PROCESS_MODE_ALWAYS
	o.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(o)
	_card = o
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.add_child(dim)
	var cc := CenterContainer.new()
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.add_child(cc)
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", UiStyle.box(Color(0.09, 0.07, 0.05, 0.96), UiStyle.TRIM, 2, 10, 16.0))
	cc.add_child(pc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	pc.add_child(v)
	var ph := not Settings.pc()
	var fs := 21 if ph else 16
	v.add_child(UiStyle.heading(Loc.t(title), 30 if ph else 24, UiStyle.TRIM))
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.custom_minimum_size = Vector2(620 if not ph else 820, minf(420.0, o.get_viewport_rect().size.y - 260.0))
	v.add_child(sc)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(list)
	for mk in lg["marks"]:
		var held := bool(mk["held"])
		var l := UiStyle.text(("[+] " if held else "[  ] ") + Loc.t(String(mk["label"])), fs, UiStyle.GOOD if held else UiStyle.MUTED, HORIZONTAL_ALIGNMENT_LEFT)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		l.name = "Mark_" + String(mk["id"])
		list.add_child(l)
	var band := String(lg["band"])
	var bl := UiStyle.text(Loc.t("%d MARKS: %s") % [int(lg["count"]), Loc.t(band.to_upper())], fs + 4, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_CENTER, true)
	bl.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	bl.name = "Band"
	v.add_child(bl)
	var said := String(lg.get("line", ""))
	if said != "":
		var sl := UiStyle.text(Loc.t(said), fs, UiStyle.TRIM, HORIZONTAL_ALIGNMENT_CENTER)
		sl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sl.custom_minimum_size.x = 560
		v.add_child(sl)
	var solo := run.mode == "solo" and run.game.net == null
	var tree := run.game.get_tree()
	var b := Button.new()
	b.text = Loc.t("CLOSE")
	b.name = "LedgerClose"
	b.custom_minimum_size = Vector2(180, 56 if ph else 46)
	b.pressed.connect(func() -> void:
		if is_instance_valid(o):
			o.queue_free()
		if solo and tree:
			tree.paused = false)
	v.add_child(b)
	if solo and tree:
		tree.paused = true          # (solo: the card holds the match; online it is only over the screen)


func close_ledger() -> void:
	if _card and is_instance_valid(_card):
		var b: Button = _card.find_child("LedgerClose", true, false)
		if b:
			b.pressed.emit()


# ------------------------------------------------------------------ conditions, actions

## Act 3's conditions: [handled, true?]. MissionRun.cond asks here after MissionAct2.
func cond(k: String, v: Variant) -> Array:
	match k:
		"stopped":
			var q: Dictionary = v if v is Dictionary else {"name": String(v), "at_least": 1}
			if not q.has("at_least") and not q.has("below"):
				q = q.duplicate()
				q["at_least"] = 1
			return [true, _between(int(st["stopped"].get(String(q.get("name", "")), 0)), q)]
		"stopping":
			return [true, (st["stops"] as Array).any(func(s) -> bool: return String(s["name"]) == String(v))]
		"called":
			var q: Dictionary = v if v is Dictionary else {"name": String(v), "at_least": 1}
			if not q.has("at_least") and not q.has("below"):
				q = q.duplicate()
				q["at_least"] = 1
			return [true, _between(int(st["called"].get(String(q.get("name", "")), 0)), q)]
		"calling":
			return [true, (st["calls"] as Array).any(func(s) -> bool: return String(s["name"]) == String(v))]
		"cold":
			var q: Dictionary = v if v is Dictionary else {"name": String(v), "at_least": 1}
			if not q.has("at_least") and not q.has("below"):
				q = q.duplicate()
				q["at_least"] = 1
			return [true, _between(cold_count(String(q.get("name", ""))), q)]
		"flown":
			return [true, st["flown"].has(String(v))]
		"marked":
			var q: Dictionary = v if v is Dictionary else {"name": String(v), "at_least": 1}
			if not q.has("at_least") and not q.has("below"):
				q = q.duplicate()
				q["at_least"] = 1
			return [true, _between(int(st["marked"].get(String(q.get("name", "")), 0)), q)]
		"frozen":
			# {"frozen": {"at_least"}}: eggs the frost has killed so far
			var q: Dictionary = v if v is Dictionary else {"at_least": 1}
			return [true, _between(int(st["marked"].get("frost", 0)), q)]
		"ledger":
			return [true, Campaign.ledger_holds(v, Campaign.ledger())]
		"night":
			return [true, Campaign.night_is(v, run.id)]
		"ending":
			return [true, String(run.flags.get("ending", "")) == String(v)]
		"won":
			return [true, (Campaign.progress()["done"] as Dictionary).has(String(v))]
		"colonies":
			return [true, Campaign.colonies_share() >= float(v.get("share", 0.5)) if v is Dictionary else false]
	return [false, false]


## Act 3's actions: true when handled.
func act(k: String, v: Variant) -> bool:
	match k:
		"climate":
			climate(v if v is Dictionary else {})
		"stop_work":
			stop_work(v)
		"made_call":
			made_call(v)
		"warmth":
			warmth(v)
		"flight":
			flight(v)
		"ledger":
			ledger(v if v is Dictionary else {})
		"ending":
			# {"ending": "rome_holds" / "rome_falls" / "hard_way"}: the campaign's ending, kept with the mission's flags
			# (Campaign.record writes it into the progress: the hub's THE CREDITS and the war map's last state)
			run.flags["ending"] = String(v.get("id", "")) if v is Dictionary else String(v)
			if run.game and run.game.mlog:
				run.game.mlog.add("(mission) ending: %s" % run.flags["ending"])
		_:
			return false
	return true


## The data checks of Act 3's mission keys (Campaign.problems).
static func problems(m: Dictionary, sides: Array, teams: Array, areas: Dictionary) -> Array:
	var out: Array = []
	if m.has("climate"):
		out.append_array(_climate_problems(m["climate"], "climate"))
	return out


static func _climate_problems(c: Variant, where: String) -> Array:
	var out: Array = []
	if not (c is Dictionary):
		return ["%s: needs a dictionary" % where]
	for k in c:
		if not ["cold", "wet", "heat", "off"].has(String(k)):
			out.append("%s: unknown climate %s (cold / wet / heat)" % [where, k])
	var cd: Variant = c.get("cold", null)
	if cd is Dictionary and cd.has("frost"):
		var fr: Variant = cd["frost"]
		if not (fr is Dictionary) or not fr.has("row"):
			out.append("%s: a frost line needs its row" % where)
		elif not ["north", "south"].has(String(fr.get("side", "north"))):
			out.append("%s: frost side must be north or south" % where)
		elif fr.has("night_row") and float(fr.get("period", 0.0)) <= 0.0:
			out.append("%s: a moving frost line needs a period" % where)
	return out


## Act 3's condition checks: [handled, problem or ""].
static func check_cond(k: String, v: Variant, sides: Array, teams: Array) -> Array:
	match k:
		"stopped", "called", "cold", "marked":
			if not (v is String or (v is Dictionary and v.has("name"))):
				return [true, "%s needs a name" % k]
			return [true, ""]
		"stopping", "calling", "flown", "ending", "won":
			return [true, "" if String(v) != "" else "%s needs a name" % k]
		"frozen":
			return [true, ""]
		"ledger":
			if not (v is Dictionary) or not (v.has("band") or v.has("mark") or v.has("at_least") or v.has("below")):
				return [true, "ledger needs band, mark, at_least or below"]
			if v.has("band") and not Campaign.LEDGER_BANDS.has(String(v["band"])):
				return [true, "ledger: unknown band %s" % v["band"]]
			if v.has("mark") and not Campaign.ledger_ids().has(String(v["mark"])):
				return [true, "ledger: unknown mark %s" % v["mark"]]
			return [true, ""]
		"night":
			for x in (v if v is Array else [v]):
				if not Campaign.NIGHT_RANKS.has(String(x)):
					return [true, "unknown night %s (fresh / normal / grown)" % x]
			return [true, ""]
		"colonies":
			return [true, "" if v is Dictionary else "colonies needs {\"share\"}"]
	return [false, ""]


## Act 3's action checks: [handled, problem or ""].
static func check_action(k: String, v: Variant, sides: Array, teams: Array, areas: Dictionary, counters: Dictionary) -> Array:
	match k:
		"climate":
			var pr := _climate_problems(v, "climate")
			return [true, "" if pr.is_empty() else pr[0]]
		"stop_work", "made_call":
			if not (v is Dictionary) or not v.has("at"):
				return [true, "%s needs \"at\"" % k]
			if v["at"] is String and not areas.has(String(v["at"])) and String(v["at"]) == "":
				return [true, "%s needs \"at\"" % k]
			if k == "made_call" and not areas.has(String(v.get("to", ""))):
				return [true, "made_call needs \"to\" (an area)"]
			if v.has("team") and not teams.has(String(v["team"])):
				return [true, "%s: unknown team %s" % [k, v["team"]]]
			for sk in ["side", "spare"]:
				if v.has(sk) and not sides.has(String(v[sk])):
					return [true, "%s: unknown side %s" % [k, v[sk]]]
			if v.has("faction") and not Defs.FACTIONS.has(String(v["faction"])):
				return [true, "%s: unknown faction %s" % [k, v["faction"]]]
			if v.has("counter") and not counters.has(String(v["counter"])):
				return [true, "%s: unknown counter %s" % [k, v["counter"]]]
			return [true, ""]
		"warmth":
			if not (v is Dictionary) or not (v.has("tag") or v.has("team") or v.has("side") or v.has("name")):
				return [true, "warmth needs a tag, team or side"]
			if bool(v.get("on", true)) and String(v.get("fires", "")) == "":
				return [true, "warmth needs its fires' tag"]
			if v.has("team") and not teams.has(String(v["team"])):
				return [true, "warmth: unknown team %s" % v["team"]]
			if v.has("side") and not sides.has(String(v["side"])):
				return [true, "warmth: unknown side %s" % v["side"]]
			if v.has("counter") and not counters.has(String(v["counter"])):
				return [true, "warmth: unknown counter %s" % v["counter"]]
			return [true, ""]
		"flight":
			if not (v is Dictionary) or String(v.get("tag", "")) == "" or (v.get("route", []) as Array).is_empty():
				return [true, "flight needs the flyer's tag and a route"]
			for w in v["route"]:
				if w is String and not areas.has(String(w)):
					return [true, "flight: route through unknown area %s" % w]
			if v.has("for") and not sides.has(String(v["for"])):
				return [true, "flight: unknown side %s" % v["for"]]
			if v.has("counter") and not counters.has(String(v["counter"])):
				return [true, "flight: unknown counter %s" % v["counter"]]
			return [true, ""]
		"ledger":
			if v is Dictionary and v.has("counter") and not counters.has(String(v["counter"])):
				return [true, "ledger: unknown counter %s" % v["counter"]]
			return [true, ""]
		"ending":
			var e := String(v.get("id", "")) if v is Dictionary else String(v)
			return [true, "" if Campaign.ENDINGS.has(e) else "unknown ending %s" % e]
	return [false, ""]


# ------------------------------------------------------------------ drawing

func _draw_under() -> void:
	var fl := frost_line()
	if fl.is_empty() or under == null:
		return
	var g := run.game
	var t := _tile()
	var y := float(fl[0]) * t
	var w := float(Game.W) * t
	var h := float(Game.H) * t
	var rect := Rect2(0, 0, w, y) if String(fl[1]) == "north" else Rect2(0, y, w, h - y)
	under.draw_rect(rect, Color(0.80, 0.90, 1.0, 0.13))
	# the line itself: a pale edge with the frost's ticks on the frozen side
	under.draw_line(Vector2(0, y), Vector2(w, y), Color(0.85, 0.95, 1.0, 0.55), 3.0)
	var dir := -1.0 if String(fl[1]) == "north" else 1.0
	var x := 0.0
	while x < w:
		under.draw_line(Vector2(x, y), Vector2(x + 6.0, y + dir * 9.0), Color(0.85, 0.95, 1.0, 0.4), 2.0)
		x += 22.0
	if g == null:
		return


func _draw_over() -> void:
	if over == null:
		return
	var g := run.game
	var font := UiStyle.bold_font()
	var me := _viewer()
	var all := _sees_all()
	# THE STOP-WORK's rings (the bell's beat going out), THE MADE CALL's
	for s in st["stops"]:
		var r := float(s["r"])
		var k := fposmod(g.clock - float(s["t0"]), 1.2) / 1.2
		over.draw_arc(s["pos"], r, 0.0, TAU, 72, Color(1.0, 0.85, 0.4, 0.55), 3.0)
		over.draw_arc(s["pos"], r * k, 0.0, TAU, 48, Color(1.0, 0.85, 0.4, 0.5 * (1.0 - k)), 2.5)
		_label(font, s["pos"] + Vector2(0, -r - 8), "%s %d" % [Loc.t("STOP-WORK"), int(ceil(float(s["until"]) - g.clock))], Color(1.0, 0.88, 0.45))
	for s in st["calls"]:
		var r := float(s["r"])
		var k := fposmod(g.clock - float(s["t0"]), 2.0) / 2.0
		over.draw_arc(s["pos"], r, 0.0, TAU, 72, Color(0.55, 1.0, 0.45, 0.45), 2.5)
		over.draw_arc(s["pos"], r * (1.0 - k), 0.0, TAU, 48, Color(0.55, 1.0, 0.45, 0.5 * k), 2.0)
		_label(font, s["pos"] + Vector2(0, -r - 8), Loc.t("THE MADE CALL"), Color(0.6, 1.0, 0.5))
	# WARMTH: the fires' rings (to the side that feels the cold) and COLD over those out of them
	for w in st["warmth"]:
		var q: Dictionary = w["q"]
		var who := String(q.get("side", run.side_of_team(run.team_index(String(q["team"]))) if q.has("team") else ""))
		if not all and who != "" and who != me:
			continue
		var r := float(q.get("within", 5.0)) * _tile()
		for f in _fires(String(q.get("fires", ""))):
			over.draw_circle(_pos(f), r, Color(1.0, 0.6, 0.25, 0.07))
			over.draw_arc(_pos(f), r, 0.0, TAU, 56, Color(1.0, 0.65, 0.3, 0.5), 2.0)
		for u in _group(q):
			if u.has_meta("act3_cold") and u.visible:
				_label(font, u.position + Vector2(0, -float(u.radius) - 22), Loc.t("COLD"), Color(0.7, 0.88, 1.0))
	# THE FLIGHT: the way still to fly (dashed) and the marked ones' rings
	for f in st["flights"]:
		if String(f["side"]) != me and not all:
			continue
		var u = f.get("u")
		if not bool(f.get("done", false)) and _alive(u):
			var a: Vector2 = u.position
			for i in range(int(f["i"]), (f["pts"] as Array).size()):
				var b: Vector2 = f["pts"][i]
				over.draw_dashed_line(a, b, Color(1.0, 0.95, 0.6, 0.5), 2.0, 10.0)
				a = b
		for e in run.tagged(String(f["mark"])):
			if _alive(e) and e.has_meta("act3_marked"):
				over.draw_arc(_pos(e), 18.0 + (float(e.radius) if e is Unit else 24.0), 0.0, TAU, 32, Color(1.0, 0.95, 0.5, 0.75), 2.0)
	# THE FROST: a frozen egg's seconds left
	var cd: Variant = st["climate"].get("cold", null)
	if cd is Dictionary and cd.get("frost") is Dictionary:
		var kill := float(cd["frost"].get("kill", FROST_KILL))
		for e in g.units:
			if not e.dead and e.kind == BroodNew.EGG and e.has_meta("act3_frost") and e.visible:
				_label(font, e.position + Vector2(0, -26), "%s %d" % [Loc.t("FROST"), int(ceil(kill - float(e.get_meta("act3_frost"))))], Color(0.75, 0.92, 1.0))


func _label(font: Font, p: Vector2, txt: String, col: Color) -> void:
	var fs := 14
	var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_CENTER, -1, fs).x
	over.draw_string_outline(font, p - Vector2(w * 0.5, 0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(0, 0, 0, 0.85))
	over.draw_string(font, p - Vector2(w * 0.5, 0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


## After a load: the flights' flyers found again by their meta (units are rebuilt).
func after_load() -> void:
	for f in st["flights"]:
		var u = f.get("u")
		if _alive(u) and not bool(f.get("done", false)):
			u.set_meta("act3_flight", String(f["name"]))
		for e in f.get("seen", []):
			if _alive(e):
				e.set_meta("act3_marked", [String(f["side"]), bool(f["reveal"])])
	_apply_pace()
