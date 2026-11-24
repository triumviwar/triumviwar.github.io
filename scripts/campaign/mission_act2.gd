class_name MissionAct2
extends RefCounted
## ACT 2's ENGINE STEP 0 (act2-engine0, docs/act2_engine0.md; the plan: docs/campaign_act2_plan.md, "Proposed BUILD
## ORDER" 1). The mission engine's new pieces for Act 2's missions, kept apart from MissionRun (as MissionHeroes is) so
## its changes stay small: MissionRun calls tick() four times a second, frame() every frame, and asks cond(), act()
## and order() for the keys it doesn't know. Every piece is data in the mission's JSON (docs/campaign_engine.md,
## "Added by Act 2's engine step 0"):
##   CARGO CARTS ("load", the "loaded" condition, exits with "cargo"), TAKE A CART (mission "take_carts", "taken"),
##   HIDDEN ("hide", "found"), TRACKS ("tracks", order "track"), THE LEASH ("leash", its "breaks", "loose"),
##   LURE POSTS ("lure_post", "lured"), BUILDINGS THAT CONVERT ("spread_convert", "turned"), THE SPREADING GROUND
##   ("ground"), THE BRAKE ("brake"), SAPPING ("sap", "sapped"), GRANARIES (mission "granaries", "fed"), the two
##   VERSIONS (mission "versions", "version"), THE HEIR ("heir"), and the IDLE METER (NO WAITING: longest_idle()).
## Its state lives in MissionRun.act2 (a Dictionary saved with the mission: MissionRun.SAVE_KEYS), so a saved mission
## goes on where it was.

const TAKE_RING := 2.0          # TAKE A CART: tiles round the cart the takers must stand in (default)
const GUARD_RING := 3.0         # ... and no armed friend of the cart within this many tiles
const LOOSE_EVERY := 3.0        # THE LEASH: a loose creature is set on its way again this often (seconds)
const IDLE_FIGHT := 10.0        # IDLE METER: tiles: a player's unit with a living foe this near is "fighting"

var run: MissionRun
var st: Dictionary              # = run.act2
var under: Node2D = null        # drawn under the units (tracks, gear ground, the sappers' gallery)
var over: Node2D = null         # drawn over them (bars, rings, LOOSE, posts)
var _marks: Array = []          # TRACKS: [position, game clock, angle, side index, seconds it lasts] (not saved: they fade)
var _loose_t := {}              # unit -> seconds to its next loose order
var _chart := PackedByteArray() # THE UNMAPPED (d04): 1 where the chart's side has mapped the ground (st["chart"]["mask"] saved)
var _chart_sprite: Sprite2D = null
var _chart_img: Image = null
var _chart_tex: ImageTexture = null
var _chart_dirty := true
var _chart_t := 0.0


func _init(r: MissionRun) -> void:
	run = r
	st = r.act2
	for k in ["loads", "hidden", "tracks", "leashes", "posts", "spreads", "grounds", "brakes", "saps", "takes"]:
		if not st.has(k):
			st[k] = []
	for k in ["taken", "found", "lured", "turned", "sapped", "fed", "broke", "idle", "gran_t", "chart"]:
		if not st.has(k):
			st[k] = {}


# ------------------------------------------------------------------ the frame's overlays

## The two drawing layers on the Game (made on the first tick).
func ensure_nodes() -> void:
	var g := run.game
	if g == null:
		return
	if under == null or not is_instance_valid(under):
		under = Node2D.new()
		under.name = "Act2Under"
		under.z_index = -17
		under.draw.connect(_draw_under)
		g.add_child(under)
	if over == null or not is_instance_valid(over):
		over = Node2D.new()
		over.name = "Act2Over"
		over.z_index = 50
		over.draw.connect(_draw_over)
		g.add_child(over)


func _redraw() -> void:
	if under and is_instance_valid(under):
		under.queue_redraw()
	if over and is_instance_valid(over):
		over.queue_redraw()


## Who looks at the screen: the side whose eyes the fog uses (the player's own; "" everything).
func _viewer_side() -> String:
	var ft := run.game.fog_team()
	return "" if ft < 0 else run.side_of_team(ft)


func _sees_all() -> bool:
	return run.game.sees_all()


# ------------------------------------------------------------------ helpers

func _tile() -> float:
	return float(Defs.TILE)


## Units (and with `buildings` buildings) of a "tag", "team" or "side" (more tags in "tags"; "kind" filters).
func group(v: Dictionary, buildings := false) -> Array:
	var out: Array = []
	if v.has("tag"):
		out = run.tagged(String(v["tag"]))
	elif v.has("team") or v.has("side"):
		var teams: Array = [run.team_index(String(v["team"]))] if v.has("team") else run.teams_of_side(String(v["side"]))
		for u in run.game.units:
			if not u.dead and teams.has(u.team) and u.kind != "horse":
				out.append(u)
		if buildings:
			for b in run.game.buildings:
				if not b.dead and not b.ghost and teams.has(b.team):
					out.append(b)
	for tg in v.get("tags", []):
		for e in run.tagged(String(tg)):
			if not out.has(e):
				out.append(e)
	if v.has("kind"):
		var ks: Array = v["kind"] if v["kind"] is Array else [v["kind"]]
		out = out.filter(func(e) -> bool: return ks.has(e.kind))
	if not buildings:
		out = out.filter(func(e) -> bool: return e is Unit)
	return out


static func _pos(e: Entity) -> Vector2:
	return e.position if e is Unit else e.center()


func _alive(e: Variant) -> bool:
	return e != null and is_instance_valid(e) and not e.dead


## A place: an area name, [x, y] cells, or a tag (the first living thing with it).
func place(at: Variant) -> Vector2:
	if at is Array:
		return run.game.cell_center(Vector2i(int(at[0]), int(at[1])))
	var s := String(at)
	if (run.data.get("areas", {}) as Dictionary).has(s):
		return run.area_rect(s).get_center()
	var l := run.tagged(s)
	return _pos(l[0]) if not l.is_empty() else Vector2.INF


## A number that looks random but is the same on every machine and replay (nothing drawn from the match's rng).
func _noise(a: Variant, b: Variant) -> float:
	return float(absi(hash([a, b])) % 10000) / 10000.0


func _add_counter(name: String, n: int) -> void:
	if name != "" and n != 0:
		run.act({"counter": {"name": name, "add": n}})


func _say_float(p: Vector2, txt: String, col: Color, side := "") -> void:
	# (a word over the place for the player who should see it; online the host's screen only, like float_text)
	if side == "" or side == _viewer_side() or _sees_all():
		run.game.float_text(p, txt, col)


# ------------------------------------------------------------------ the tick (MissionRun._physics_process, 4 a second)

func tick(dt: float) -> void:
	ensure_nodes()
	_tick_takes(dt)
	_tick_loads()
	_tick_hidden(dt)
	_tick_tracks(dt)
	_tick_leash(dt)
	_tick_posts()
	_tick_spreads(dt)
	_tick_grounds(dt)
	_tick_brakes()
	_tick_saps()
	_tick_granaries(dt)
	_tick_chart(dt)
	_tick_idle(dt)
	_redraw()


## Every frame (MissionRun._process): the sappers move under the ground.
func frame(_dt: float) -> void:
	if st["saps"].is_empty():
		return
	var g := run.game
	for s in st["saps"]:
		var u = s.get("u")
		if not _alive(u):
			continue
		var a: Vector2 = s["from"]
		var b: Vector2 = s["to"]
		var k := clampf((g.clock - float(s["t0"])) / maxf(0.1, float(s["secs"])), 0.0, 1.0)
		u.position = a.lerp(b, k)
		g.note_move(u)
	if under and is_instance_valid(under):
		under.queue_redraw()


# ------------------------------------------------------------------ conditions

## Act 2's conditions: [handled, true?]. MissionRun.cond asks here for keys it doesn't know.
func cond(k: String, v: Variant) -> Array:
	match k:
		"loaded":
			# {"loaded": {"tag": the carts, "cargo": kind, "at_least" / "below"}}: cargo aboard living carts of the tag
			var n := loaded_count(String(v.get("tag", "")), String(v.get("cargo", "")))
			return [true, _between(n, v)]
		"taken":
			# {"taken": tag} (one at least) or {"taken": {"tag", "at_least" / "below"}}: carts of the tag taken
			var q: Dictionary = v if v is Dictionary else {"tag": String(v), "at_least": 1}
			return [true, _between(int(st["taken"].get(String(q.get("tag", "")), 0)), q)]
		"found":
			# {"found": {"tag" or "name", "at_least" (1) / "below"}}: hidden ones found by the side looking for them
			var q: Dictionary = v if v is Dictionary else {"tag": String(v)}
			var key := String(q.get("name", q.get("tag", "")))
			if not q.has("at_least") and not q.has("below"):
				q = q.duplicate()
				q["at_least"] = 1
			return [true, _between(int(st["found"].get(key, 0)), q)]
		"loose":
			# {"loose": {"name" (a leash) or "tag", "at_least" (1) / "below"}}: out of the lure's reach now
			var q: Dictionary = v if v is Dictionary else {"name": String(v)}
			if not q.has("at_least") and not q.has("below"):
				q = q.duplicate()
				q["at_least"] = 1
			return [true, _between(loose_count(String(q.get("name", "")), String(q.get("tag", ""))), q)]
		"broke":
			# {"broke": {"name", "at_least" / "below"}}: creatures whose leash broke (they changed side for good)
			var q: Dictionary = v if v is Dictionary else {"name": String(v), "at_least": 1}
			return [true, _between(int(st["broke"].get(String(q.get("name", "")), 0)), q)]
		"lured":
			# {"lured": post tag}: a lure post pulled a wave (at least one unit came)
			return [true, int(st["lured"].get(String(v), 0)) > 0]
		"turned":
			# {"turned": {"name", "at_least" / "below"}}: buildings a spread has turned
			var q: Dictionary = v if v is Dictionary else {"name": String(v), "at_least": 1}
			return [true, _between(int(st["turned"].get(String(q.get("name", "")), 0)), q)]
		"ground":
			# {"ground": {"name", "at_least" / "below": tiles}}: a spreading ground's radius now; "on": tag: one of
			# them stands on it
			var gr := _ground(String(v.get("name", "")))
			if gr.is_empty():
				return [true, false]
			if v.has("on"):
				var c: Vector2 = _ground_centre(gr)
				var r := float(gr["r"]) * _tile()
				return [true, run.tagged(String(v["on"])).any(func(e) -> bool: return _pos(e).distance_to(c) <= r)]
			return [true, _between(int(floor(float(gr["r"]))), v)]
		"sapped":
			# {"sapped": name}: the sappers came up at the end of their gallery
			return [true, st["sapped"].has(String(v))]
		"fed":
			# {"fed": {"team", "at_least"}}: what the granaries gave that team so far
			return [true, _between(int(st["fed"].get(String(v.get("team", "")), 0)), v)]
		"researched":
			# (d01) {"researched": {"team", "tech": id or [ids]}}: that team has every one of those researches done
			var tm := run.team_index(String(v.get("team", "")))
			if tm < 0:
				return [true, false]
			var ts: Array = v["tech"] if v.get("tech") is Array else [v.get("tech", "")]
			return [true, ts.all(func(k) -> bool: return run.game.has_tech(tm, String(k)))]
		"brood_stage":
			# (d06) {"brood_stage": {"tag", "at_least": 3}}: one Brood Mother of the tag has grown to that stage (1 to 3)
			var need := int(v.get("at_least", 3))
			for e in run.tagged(String(v.get("tag", ""))):
				if e is Unit and not e.dead and e.kind == BroodNew.QUEEN and BroodNew.stage(e) + 1 >= need:
					return [true, true]
			return [true, false]
		"charted":
			# (d04) {"charted": {"area", "at_least": share 0..1 (0.6)}}: that share of the area's open cells is mapped;
			# without "area": of the whole map
			return [true, chart_share(String(v.get("area", ""))) >= float(v.get("at_least", 0.6))]
		"won_by":
			# (d10) {"won_by": {"<mission>": side}}: who won that mission when it was played (a mirror's win: THE RECLAIM PART)
			var done: Dictionary = Campaign.progress()["done"]
			for mk in v:
				if str((done.get(String(mk), {}) as Dictionary).get("won_by", "")) != str(v[mk]):
					return [true, false]
			return [true, true]
		"version":
			# {"version": "fresh"} (or a list): the mission's version (FRESH / GROWN), picked at the start
			var vs: Array = (v if v is Array else [v]).map(func(x) -> String: return String(x))
			return [true, vs.has(String(run.flags.get("version", "")))]
		"heir":
			# {"heir": "named" / "unseen"}: the campaign's setting for the King's listener (campaign.json "heir")
			return [true, Campaign.heir() == String(v)]
		"hub_flag":
			# {"hub_flag": {"name": value}}: an answer given in a hub talk (the frame's choice)
			for fk in v:
				if str(Campaign.hub_flag(String(fk))) != str(v[fk]):
					return [true, false]
			return [true, true]
	return [false, false]


static func _between(n: int, q: Dictionary) -> bool:
	return (not q.has("at_least") or n >= int(q["at_least"])) and (not q.has("below") or n < int(q["below"]))


# ------------------------------------------------------------------ actions

## Act 2's actions: true when handled.
func act(k: String, v: Variant) -> bool:
	match k:
		"load":
			load_carts(v)
		"unload":
			for e in run.tagged(String(v.get("tag", v.get("cart", "")))):
				_unload(e)
		"hide":
			hide(v)
		"tracks":
			set_tracks(v)
		"leash":
			leash(v)
		"lure_post":
			lure_post(v)
		"spread_convert":
			spread_convert(v)
		"ground":
			ground(v)
		"brake":
			brake(v)
		"sap":
			sap(v)
		"brood_stage":
			brood_stage(v)
		"root_now":
			root_now(v)
		"retag":
			retag(v)
		"chart":
			chart(v)
		"cast":
			cast(v)
		"tech":
			# (d10) {"tech": {"team", "id": research or [ids]}}: those researches done for that team at once (the siege
			# train's drill brought north in the GROWN jungle front)
			var t := run.team_index(String(v.get("team", "")))
			if t >= 0:
				for tk in (v["id"] if v.get("id") is Array else [v.get("id", "")]):
					run.game.players[t]["tech"][String(tk)] = true
		_:
			return false
	return true


## (d10) {"cast": {"tag", "spell": "fog" / "miasma", "near_foe": tiles}}: the SCRIPTED Mist Toads of the tag cast the
## spell on their own spot (the fog over their Mother), each only with an enemy within `near_foe` tiles (when given);
## the mission pays the energy and the research (a scripted swarm's toads lay the fog the ladder's B7 teaches).
func cast(v: Dictionary) -> void:
	var g := run.game
	var spell := String(v.get("spell", "fog"))
	var info: Dictionary = Game.spell_info(spell)
	var near := float(v.get("near_foe", 0.0)) * Defs.TILE
	for u in run.tagged(String(v.get("tag", ""))):
		if not (u is Unit) or u.dead or u.kind != "mist_toad" or u.order == "cast":
			continue
		if near > 0.0 and not g.units_near(u.position, near).any(func(o) -> bool: return not o.dead and g.hostile(o.team, u.team)):
			continue
		var rk := Game.spell_research(spell)
		if rk != "":
			g.players[u.team]["tech"][rk] = true
		u.charge = maxf(u.charge, float(info.get("cost", 0.0)))
		g.cast_spell(u, spell, u.position)


## Act 2's orders ({"order": {"do": ...}}): true when handled (only "track").
func order(us: Array, v: Dictionary) -> bool:
	match String(v.get("do", "")):
		"track":
			track_order(us, v)
			return true
		"take":
			take_order(us, v)
			return true
	return false


## (d02_exodus) {"order": {..., "do": "take", "carts": tag, "within": 60, "else": area}}: each of them rides to the
## nearest living cart of the tag held by a side it is at war with and stands by it (TAKE A CART does the rest: "take_carts");
## a man fighting someone within 4 tiles is left to his fight; none in reach: an attack-move to "else" if given. Give it
## again with "every" (the commissary's riders on the valley road).
func take_order(us: Array, v: Dictionary) -> void:
	var g := run.game
	var carts: Array = run.tagged(String(v.get("carts", v.get("prey", "")))).filter(func(c) -> bool: return c is Unit and not c.dead)
	var reach := float(v.get("within", 60)) * _tile()
	var fallback: Vector2 = run.area_rect(String(v["else"])).get_center() if v.has("else") else Vector2.INF
	for u in us:
		if not (u is Unit) or u.dead:
			continue
		if u.target != null and is_instance_valid(u.target) and not u.target.dead and u.position.distance_to(_pos(u.target)) <= 4.0 * _tile():
			continue
		var best: Unit = null
		var bd := reach
		for c in carts:
			if c.team == u.team or g.allied(u.team, c.team):
				continue
			var d: float = u.position.distance_to(c.position)
			if d < bd:
				bd = d
				best = c
		if best != null:
			if bd > 1.2 * _tile():
				g.group_move([u], best.position + Vector2(_noise(u, best) * 24.0 - 12.0, _noise(best, u) * 24.0 - 12.0), false)
		elif fallback != Vector2.INF and u.velocity.length() < 5.0:
			g.group_move([u], fallback, true)


# ================================================================== CARGO CARTS (d01's gold, d02's families)

## {"load": {"cart": tag, "cargo": "families", "amount": 1, "lost": counter, "first": false}}: every empty cart of the
## tag (or the first) takes that cargo aboard (a bundle drawn on it; "gold": a chest). A cart broken: its cargo is LOST
## (counted in "lost"). A cart leaving by an exit with "cargo": true takes it along ("cargo_counter" counts the amount).
## A cart TAKEN keeps its cargo (it changes hands with it).
func load_carts(v: Dictionary) -> void:
	for c in run.tagged(String(v.get("cart", v.get("tag", "")))):
		if not (c is Unit) or not _load_of(c).is_empty():
			continue
		st["loads"].append({"cart": c, "cargo": String(v.get("cargo", "cargo")), "n": int(v.get("amount", 1)),
			"lost": String(v.get("lost", ""))})
		c.set_meta("cart_load", String(v.get("cargo", "cargo")))
		if bool(v.get("first", false)):
			break
	run.objectives_changed.emit()


func _load_of(c: Entity) -> Dictionary:
	for it in st["loads"]:
		if it.get("cart") == c:
			return it
	return {}


func _unload(c: Entity) -> void:
	st["loads"] = (st["loads"] as Array).filter(func(it) -> bool: return it.get("cart") != c)
	if is_instance_valid(c) and c.has_meta("cart_load"):
		c.remove_meta("cart_load")


## Cargo aboard living carts of the tag ("" any), of that kind ("" any).
func loaded_count(tag: String, cargo: String) -> int:
	var n := 0
	var carts: Array = run.tagged(tag) if tag != "" else []
	for it in st["loads"]:
		var c = it.get("cart")
		if not _alive(c) or (tag != "" and not carts.has(c)) or (cargo != "" and String(it["cargo"]) != cargo):
			continue
		n += int(it["n"])
	return n


## A cart that leaves by an exit: its cargo's amount (0: none), and the cargo gone with it.
func cart_leaves(c: Entity) -> int:
	var it := _load_of(c)
	if it.is_empty():
		return 0
	_unload(c)
	return int(it["n"])


func _tick_loads() -> void:
	for it in (st["loads"] as Array).duplicate():
		var c = it.get("cart")
		if c == null or not is_instance_valid(c) or c.dead:
			st["loads"].erase(it)
			_add_counter(String(it.get("lost", "")), int(it["n"]))      # (the families scatter, the gold is spilled)
			if c != null and is_instance_valid(c):
				run.game._ping(_pos(c), Color(1.0, 0.5, 0.3))


# ================================================================== TAKE A CART (d02: the commission's horsemen)

## Mission "take_carts": [{"tag": the carts, "by": side, "to": team, "secs": 5, "within": 2, "guard": 3, "counter",
## "as": tag}]: a cart with armed men of `by` round it (within `within` tiles) and no armed man of its own side within
## `guard` tiles for `secs` seconds changes side (to `to`, else the first team of `by` no person plays, else the first
## of `by`), cargo and all: TAKEN. The bar over it (TAKING THE CART) fills while they take it and empties when they are
## driven off. Condition {"taken": tag}.
func _tick_takes(dt: float) -> void:
	var rules: Array = run.data.get("take_carts", [])
	if rules.is_empty():
		return
	var g := run.game
	var prog := {}
	for it in st["takes"]:
		if _alive(it.get("cart")):
			prog[it["cart"]] = it
	var keep: Array = []
	var changed := {}          # (a cart taken this tick: no other rule takes it back in the same tick with its old progress)
	for rule in rules:
		var by_teams := run.teams_of_side(String(rule.get("by", "")))
		var within := float(rule.get("within", TAKE_RING)) * _tile()
		var guard := float(rule.get("guard", GUARD_RING)) * _tile()
		var secs := float(rule.get("secs", 5.0))
		for c in run.tagged(String(rule.get("tag", ""))):
			if not (c is Unit) or by_teams.has(c.team) or changed.has(c):
				continue
			var takers := 0
			var guards := 0
			for u in g.units:
				if u.dead or u.off_field or u == c or u.kind == "horse" or not u.has_attack() or u.has_meta("cage_cart"):
					continue          # (d02: a cart never takes nor guards another cart, armed wagon or not)
				var d: float = u.position.distance_to(c.position)
				if by_teams.has(u.team) and d <= within:
					takers += 1
				elif g.allied(u.team, c.team) and d <= guard:
					guards += 1
			var it: Dictionary = prog.get(c, {"cart": c, "t": 0.0})
			if takers > 0 and guards == 0:
				it["t"] = float(it["t"]) + dt
			else:
				it["t"] = maxf(0.0, float(it["t"]) - dt * 2.0)
			if float(it["t"]) >= secs:
				_take(c, rule)
				changed[c] = true
				prog.erase(c)
				continue
			if float(it["t"]) > 0.0:
				it["secs"] = secs
				it["label"] = String(rule.get("label", "TAKING THE CART"))     # (d04: "TURNING BACK" for the valley's people)
				keep.append(it)
	st["takes"] = keep


func _take(c: Unit, rule: Dictionary) -> void:
	var to := -1
	if rule.has("to"):
		to = run.team_index(String(rule["to"]))
	else:
		var ts := run.teams_of_side(String(rule.get("by", "")))
		for t in ts:
			if not run.player_teams.has(t):
				to = t
				break
		if to < 0 and not ts.is_empty():
			to = ts[0]
	if to < 0:
		return
	_off_routes(c)
	if bool(rule.get("untorch", false)) and c.has_meta("torch"):
		c.remove_meta("torch")          # (d04: a torch-bearer turned back puts his torch out)
		c.remove_meta("torch_burning")
	run._turn(c, to, String(rule.get("as", "")))
	var tag := String(rule.get("tag", ""))
	st["taken"][tag] = int(st["taken"].get(tag, 0)) + 1
	_add_counter(String(rule.get("counter", "")), 1)
	run.game._ping(c.position, Color(1.0, 0.75, 0.25))
	run._send({"k": "ping", "p": c.position})
	run.game.float_text(c.position + Vector2(0, -34), Loc.t(String(rule.get("word", "TAKEN!"))), Color(1.0, 0.7, 0.3))
	run.objectives_changed.emit()
	if run.game.mlog:
		run.game.mlog.add("(mission) a cart was taken (%s)" % tag)


## A unit taken off every scripted route and follow (it changed hands, or went under the ground).
func _off_routes(u: Unit) -> void:
	for r in run._routes:
		r["units"] = (r["units"] as Array).filter(func(x) -> bool: return x != u)
	for f in run._follows:
		f["units"] = (f["units"] as Array).filter(func(x) -> bool: return x != u)


# ================================================================== HIDDEN and FOUND (d03: the pens in the forest)

## {"hide": {"tag" / "team" / "side", "from": side, "within": 3, "awake_within": tiles, "name", "counter", "on": true}}:
## these are HIDDEN from that side: its player doesn't see them and none of its units aims at them. They are FOUND (for
## good: seen, open to attack, pinged, counted) when a unit of `from` comes within `within` tiles of one ASLEEP (b01 /
## a03's sleep), sees one AWAKE in its own sight (or within `awake_within` tiles when given), when one is hurt, or when
## one goes for one of them. {"on": false}: they are simply not hidden any more (not counted as found).
## Condition {"found": {"name" or tag, "at_least"}}.
func hide(v: Dictionary) -> void:
	var key := String(v.get("name", v.get("tag", v.get("team", v.get("side", "hidden")))))
	var list := group(v)
	if not bool(v.get("on", true)):
		for it in (st["hidden"] as Array).duplicate():
			if list.has(it.get("e")):
				_unhide(it)
				st["hidden"].erase(it)
		return
	var from := String(v.get("from", ""))
	for e in list:
		if (st["hidden"] as Array).any(func(it) -> bool: return it.get("e") == e):
			continue
		st["hidden"].append({"e": e, "from": from, "within": float(v.get("within", 3.0)),
			"awake": float(v.get("awake_within", -1.0)), "key": key, "counter": String(v.get("counter", "")),
			"spared": e.spared, "hp": e.hp, "still": float(v.get("still", -1.0)), "still_t": 0.0})
		e.spared = true          # (nobody of the searching side aims at what it doesn't know is there)
		e.set_meta("mission_hidden", from)
	run.game._vis_t = 0.0


func _unhide(it: Dictionary) -> void:
	var e = it.get("e")
	if e == null or not is_instance_valid(e):
		return
	e.spared = bool(it.get("spared", false))
	if e.has_meta("mission_hidden"):
		e.remove_meta("mission_hidden")
	run.game._vis_t = 0.0


func _tick_hidden(dt := 0.25) -> void:
	if st["hidden"].is_empty():
		return
	var g := run.game
	for it in (st["hidden"] as Array).duplicate():
		var e = it.get("e")
		if e == null or not is_instance_valid(e) or e.dead:
			st["hidden"].erase(it)
			continue
		var from_teams := run.teams_of_side(String(it["from"]))
		var p := _pos(e)
		var found: bool = e.hp < float(it.get("hp", e.hp)) - 0.5        # (hurt: the search heard it)
		if not found and e is Unit and e.target != null and is_instance_valid(e.target) and not e.target.dead \
				and from_teams.has(e.target.team):
			found = true                                                 # (it went for one of them)
		if not found:
			var asleep: bool = e.has_meta("mission_asleep")
			# (d03_fazenda) "still": secs: one that has stood still that long LIES LOW: seen only within `within` tiles,
			# as one asleep; moving, it is seen in a searcher's sight (the stock kept still in the forest)
			if float(it.get("still", -1.0)) >= 0.0 and e is Unit:
				if (e as Unit).velocity.length() < 6.0 and not (e as Unit).is_air():
					it["still_t"] = float(it.get("still_t", 0.0)) + dt
				else:
					it["still_t"] = 0.0
				if float(it["still_t"]) >= float(it["still"]):
					asleep = true
			var reach := float(it["within"]) * _tile()
			for u in g.units:
				if u.dead or u.off_field or not from_teams.has(u.team) or u.kind == "horse":
					continue
				var d: float = u.position.distance_to(p)
				if asleep or float(it["awake"]) >= 0.0:
					var r := reach if asleep else float(it["awake"]) * _tile()
					if d <= r:
						found = true
						break
				elif d <= float(run.sight_of(u, int(u.sight))) * _tile():
					found = true          # (awake and in a searcher's sight (under the mission's mist): seen)
					break
		it["hp"] = e.hp
		if found:
			st["hidden"].erase(it)
			_unhide(it)
			var key := String(it["key"])
			st["found"][key] = int(st["found"].get(key, 0)) + 1
			_add_counter(String(it.get("counter", "")), 1)
			g._ping(p, Color(1.0, 0.35, 0.3))
			run._send({"k": "ping", "p": p})
			g.float_text(p + Vector2(0, -36), "FOUND!", Color(1.0, 0.4, 0.35))
			run.objectives_changed.emit()
			if g.mlog:
				g.mlog.add("(mission) a hidden %s was found (%s)" % [e.kind, key])


## Game._update_vis asks after its own loop: a hidden one is not on the screen of the side it hides from, a sapper under
## the ground on no other side's.
func after_vis(ft: int) -> void:
	_chart_hide(ft)
	if st["hidden"].is_empty() and st["saps"].is_empty():
		return
	var g := run.game
	if g.sees_all():
		return
	var side := run.side_of_team(ft) if ft >= 0 else ""
	for it in st["hidden"]:
		var e = it.get("e")
		if e != null and is_instance_valid(e) and String(it["from"]) == side:
			e.visible = false
	for s in st["saps"]:
		var u = s.get("u")
		if u != null and is_instance_valid(u) and ft >= 0 and not g.allied(u.team, ft):
			u.visible = false


func is_hidden(e: Entity) -> bool:
	return e.has_meta("mission_hidden")


## (d03_fazenda) LYING LOW: a hidden unit with "still" that has stood still long enough (seen only close up, as asleep).
func lies_low(e: Entity) -> bool:
	for it in st["hidden"]:
		if it.get("e") == e:
			return float(it.get("still", -1.0)) >= 0.0 and float(it.get("still_t", 0.0)) >= float(it["still"])
	return false


## (d03_fazenda) {"retag": {"tag": from, "as": tag, "kind": [kinds], "first": true}}: the living units of the tag (of
## those kinds) get a second tag too (the first only: the night's restless young one is whichever is still alive).
func retag(v: Dictionary) -> void:
	var list := group({"tag": String(v.get("tag", "")), "kind": v["kind"]} if v.has("kind") else {"tag": String(v.get("tag", ""))})
	if v.has("far_from"):
		# (those farther than `within` tiles from every one of `far_from` first: the restless one is one nobody watches)
		var lures := lures_of(String(v["far_from"]))
		var reach := float(v.get("within", 4.0)) * _tile()
		var far := list.filter(func(e) -> bool: return not lures.any(func(p) -> bool: return (p as Vector2).distance_to(_pos(e)) <= reach))
		list = far + list.filter(func(e) -> bool: return not far.has(e))
	for e in list:
		if not _alive(e) or (bool(v.get("rooted_too", false)) == false and e is Unit and BroodNew.ROOTERS.has(e.kind) and e.tesla_mode == "deployed"):
			continue
		run._tag(String(v.get("as", "")), e)
		if bool(v.get("first", false)):
			return


## (d06_queen) {"root_now": {"tag"}}: the Brood creatures of the tag (a person's too: the scene as the mission sets it,
## at its start) root where they stand (BroodRoot.start_root at their own spot, a father nesting wherever he is).
func root_now(v: Dictionary) -> void:
	for e in run.tagged(String(v.get("tag", ""))):
		if e is Unit and not e.dead and BroodNew.ROOTERS.has(e.kind) and e.tesla_mode == "packed":
			if BroodNew.is_father(e.kind):
				e.set_meta("mission_root", true)
			# (where it stands, else the nearest free spot within 4 tiles: two rooted ones never overlap)
			var at: Vector2 = e.position
			var g := run.game
			var sc := BroodRoot.scale_of(e)
			if BroodRoot.place_problem(g, e.team, e.kind, at, e, false, sc) != "":
				var found := false
				for rr in range(1, 5):
					for k in 12:
						var p: Vector2 = e.position + Vector2.from_angle(TAU * float(k) / 12.0) * float(rr) * _tile()
						if BroodRoot.place_problem(g, e.team, e.kind, p, e, false, sc) == "":
							at = p
							found = true
							break
					if found:
						break
			BroodRoot.start_root(e, at)


## (d03_fazenda) {"brood_stage": {"tag", "stage": 2}}: the Brood Mothers of the tag are at that growth stage at once (a
## mission's breeding animal kept by a naturalist: the Storm Sire's Hatchlings need her at stage 2).
func brood_stage(v: Dictionary) -> void:
	var to := clampi(int(v.get("stage", 2)) - 1, 0, (Defs.NB["stages"] as Array).size() - 1)
	for e in run.tagged(String(v.get("tag", ""))):
		if e is Unit and not e.dead and e.kind == BroodNew.QUEEN:
			e.nb["stage"] = to
			BroodNew.apply_stage(e)
			BroodNew.recount(run.game, e.team)
			run.game.swamp_dirty = true


# ================================================================== TRACKS (d03: Valadares reads them)

## {"tracks": {"tag" / "team" / "side", "for": side, "secs": 60, "every": 2, "name", "on": true}}: where they walk
## they leave TRACKS (claw marks on the ground) that last `secs` and fade; only the side `for` sees them (its player;
## an order "track" sends its scripted men after the freshest).
func set_tracks(v: Dictionary) -> void:
	var nm := String(v.get("name", v.get("tag", v.get("team", v.get("side", "tracks")))))
	st["tracks"] = (st["tracks"] as Array).filter(func(t) -> bool: return String(t["name"]) != nm)
	if not bool(v.get("on", true)):
		return
	st["tracks"].append({"name": nm, "q": v.duplicate(), "for": String(v.get("for", "")), "secs": float(v.get("secs", 60.0)),
		"every": float(v.get("every", 2.0)), "t": 0.0, "last": {}})


func _tick_tracks(dt: float) -> void:
	var g := run.game
	_marks = _marks.filter(func(m) -> bool: return g.clock - float(m[1]) < float(m[4]))
	for tr in st["tracks"]:
		tr["t"] = float(tr["t"]) - dt
		if float(tr["t"]) > 0.0:
			continue
		tr["t"] = float(tr["every"])
		var si := Campaign.side_index(run.data, String(tr["for"]))
		for u in group(tr["q"]):
			if u.off_field or u.is_air():
				continue
			var id := str(u.get_instance_id())
			var last: Variant = (tr["last"] as Dictionary).get(id, null)
			if last is Vector2 and (last as Vector2).distance_to(u.position) < _tile() * 0.8:
				continue          # (standing: no new track)
			if not (last is Vector2):
				tr["last"][id] = u.position
				continue          # (d03: the first look only notes where it stands: a creature lying still leaves no print)
			var ang: float = 0.0 if not (last is Vector2) else (u.position - (last as Vector2)).angle()
			tr["last"][id] = u.position
			_marks.append([u.position, g.clock, ang, si, float(tr["secs"])])
	if _marks.size() > 600:
		_marks = _marks.slice(_marks.size() - 600)


## The freshest track within `tiles` of a point (INF: none), for side index `si` (-1 any).
func freshest_track(p: Vector2, tiles: float, si := -1) -> Vector2:
	var best := Vector2.INF
	var bt := -INF
	for m in _marks:
		if si >= 0 and int(m[3]) != si:
			continue
		if (m[0] as Vector2).distance_to(p) <= tiles * _tile() and float(m[1]) > bt:
			bt = float(m[1])
			best = m[0]
	return best


## {"order": {..., "do": "track", "within": 14}}: each walks to the freshest track within reach (searchers on a hunch;
## repeat it with a trigger's "every"); with none near they keep on as they were.
func track_order(us: Array, v: Dictionary) -> void:
	for u in us:
		var si: int = Campaign.side_index(run.data, run.side_of_team(u.team))
		var p: Vector2 = freshest_track(u.position, float(v.get("within", 14.0)), si)
		if p != Vector2.INF and u.position.distance_to(p) > _tile():
			run.game.group_move([u], p, bool(v.get("attack", false)))


func track_marks() -> Array:
	return _marks


# ================================================================== THE LEASH and its BREAKING (d03, d06)

## {"leash": {"tag" / "team" / "side", "lure": tag, "within": 8, "loose": "wander" / "hunt" / "root" / "to", "to": area,
## "name", "breaks": {"near": tag, "within": 5, "to": team or "near", "as": tag, "counter", "warn": 2, "loose_only"},
## "on": true}}: these
## creatures OBEY (a person's orders, a script's) only within `within` tiles of a LURE: a living unit or building with
## the lure tag, or a lure post with it. Out of every lure's reach they are LOOSE: they go their own way every few
## seconds (wander round where they are, hunt the nearest foe, root where they stand, or walk to `to`), whatever
## they were told; back in reach they wait for orders again. The lures' reach is a ring on their side's screen, and a
## loose creature has LOOSE over it. A leash on a team or side takes its new units too.
## BREAKS: one that comes within `within` tiles of a unit with the `near` tag leaves the leash and changes side for
## good (after `warn` seconds of stars, as a04's convert), counted in "counter" and {"broke": name}. (d06) "to": "near"
## gives it to the team of the one it came near (several Mothers calling); "loose_only": one still held by a lure of its
## own leash never breaks.
func leash(v: Dictionary) -> void:
	var nm := String(v.get("name", v.get("tag", v.get("team", v.get("side", "leash")))))
	var old: Dictionary = {}
	for l in st["leashes"]:
		if String(l["name"]) == nm:
			old = l
	st["leashes"] = (st["leashes"] as Array).filter(func(l) -> bool: return String(l["name"]) != nm)
	var keep: Array = group(v) if bool(v.get("on", true)) else []
	for u in old.get("units", []):
		if _alive(u) and u.has_meta("leash_loose") and not keep.has(u):
			u.remove_meta("leash_loose")          # (one the new leash of that name keeps stays loose till a lure holds it)
	if not bool(v.get("on", true)):
		return
	var q := v.duplicate()
	q.erase("breaks")
	st["leashes"].append({"name": nm, "q": q, "units": group(v), "lure": String(v.get("lure", "")),
		"within": float(v.get("within", 8.0)), "loose": String(v.get("loose", "wander")), "to": String(v.get("to", "")),
		"breaks": v.get("breaks", {}), "open": v.has("team") or v.has("side")})


## The lures of a tag: their positions (units, buildings, lure posts).
func lures_of(tag: String) -> Array:
	var out: Array = []
	for e in run.tagged(tag):
		out.append(_pos(e))
	for p in st["posts"]:
		if String(p["tag"]) == tag:
			out.append(p["pos"])
	return out


func _tick_leash(dt: float) -> void:
	# (d03: a creature on two leashes is ruled by the NEWEST one: the restless young one's short leash at night overrides
	# the stock's)
	var newest := {}
	for li in (st["leashes"] as Array).size():
		for u in st["leashes"][li]["units"]:
			newest[u] = li
	for li in (st["leashes"] as Array).size():
		var l: Dictionary = st["leashes"][li]
		var units: Array = (l["units"] as Array).filter(func(u) -> bool: return _alive(u))
		if bool(l.get("open", false)):
			for u in group(l["q"]):
				if not units.has(u):
					units.append(u)
		var lures := lures_of(String(l["lure"]))
		var reach := float(l["within"]) * _tile()
		var br: Dictionary = l.get("breaks", {})
		var breakers: Array = run.tagged(String(br.get("near", ""))) if not br.is_empty() else []
		for u in units.duplicate():
			if int(newest.get(u, li)) > li:
				continue          # (a newer leash rules this one)
			if u.has_meta("leash_turning"):
				if float(u.get_meta("leash_turning")) > run.game.clock:
					units.erase(u)
					continue      # (d06: changing side already: an open leash takes it up again each round meanwhile)
				u.remove_meta("leash_turning")
			# THE BREAKING: near the one who calls them, they are hers
			var held: bool = lures.any(func(p) -> bool: return (p as Vector2).distance_to(u.position) <= reach)
			# (d06 "loose_only": a creature held by its own lure never breaks: the Mothers' fight, her call beside it)
			if not breakers.is_empty() and not (held and bool(br.get("loose_only", false))):
				var bw := float(br.get("within", 5.0)) * _tile()
				var by: Entity = null
				for b in breakers:
					if b != u and _alive(b) and _pos(b).distance_to(u.position) <= bw and (b.team != u.team or String(br.get("to", "")) != "near"):
						by = b
						break
				if by != null:
					_break(u, l, br, by)
					units.erase(u)
					continue
			if held:
				if u.has_meta("leash_loose"):
					u.remove_meta("leash_loose")
					_loose_t.erase(u)
					if u.order != "idle" and u.order != "hold":
						u.cmd_stop()        # (back under the lure: it waits to be told)
					_say_float(u.position + Vector2(0, -30), "HELD", Color(0.6, 1.0, 0.6), run.side_of_team(u.team))
				continue
			if not u.has_meta("leash_loose"):
				u.set_meta("leash_loose", true)
				_loose_t[u] = 0.0
				_say_float(u.position + Vector2(0, -52), "LOOSE!", Color(1.0, 0.6, 0.3), run.side_of_team(u.team))
			_loose_t[u] = float(_loose_t.get(u, 0.0)) - dt
			if float(_loose_t[u]) <= 0.0:
				_loose_t[u] = LOOSE_EVERY
				_go_loose(u, l)
		l["units"] = units


## A loose creature goes its own way (its player's orders don't hold it).
func _go_loose(u: Unit, l: Dictionary) -> void:
	var g := run.game
	var how := String(l["loose"])
	if how == "hunt":
		var best: Unit = null
		var bd := 12.0 * _tile()
		for o in g.units:
			if o.dead or o.off_field or not g.hostile(o.team, u.team) or o.kind == "horse" or o.untouchable():
				continue
			var d: float = o.position.distance_to(u.position)
			if d < bd:
				bd = d
				best = o
		if best:
			u.cmd_attack(best)
			return
	if how == "root" and BroodNew.ROOTERS.has(u.kind):
		if u.tesla_mode == "packed":
			BroodRoot.start_root(u, u.position)
		return
	if how == "to" and String(l["to"]) != "":
		g.group_move([u], run.area_rect(String(l["to"])).get_center(), false)
		return
	if u.tesla_mode == "deployed":
		return          # (a rooted one stays where it is)
	var a: float = _noise(u.get_instance_id(), int(g.clock)) * TAU
	var r := (1.5 + _noise(int(g.clock), u.get_instance_id()) * 3.5) * _tile()
	var p := u.position + Vector2(cos(a), sin(a)) * r
	var c := g.cell_of(p)
	if g.in_map(c) and g._walkable(c):
		g.group_move([u], p, false)


func _break(u: Unit, l: Dictionary, br: Dictionary, by: Entity = null) -> void:
	if u.has_meta("leash_loose"):
		u.remove_meta("leash_loose")
	# (d06 "to": "near": the side of the one it came near: whichever Mother's call is strongest there)
	var to := by.team if String(br.get("to", "")) == "near" and by != null else run.team_index(String(br.get("to", "")))
	if to < 0 or u.team == to:
		return
	_off_routes(u)
	var warn := float(br.get("warn", 2.0))
	u.set_meta("leash_turning", run.game.clock + warn + 0.5)
	u.stun(warn, true)
	run._turning.append([u, to, run.game.clock + warn, String(br.get("as", ""))])
	var nm := String(l["name"])
	st["broke"][nm] = int(st["broke"].get(nm, 0)) + 1
	_add_counter(String(br.get("counter", "")), 1)
	run.game.float_text(u.position + Vector2(0, -36), "THE LEASH BREAKS", Color(0.6, 1.0, 0.4))
	run.objectives_changed.emit()


func loose_count(name: String, tag: String) -> int:
	var n := 0
	var tg: Array = run.tagged(tag) if tag != "" else []
	for l in st["leashes"]:
		if name != "" and String(l["name"]) != name:
			continue
		for u in l["units"]:
			if _alive(u) and u.has_meta("leash_loose") and (tag == "" or tg.has(u)):
				n += 1
	return n


# ================================================================== LURE POSTS (d03's decoy, d08 / d10's drowned wave)

## {"lure_post": {"tag": "post", "at": area / [x, y] / a tag, "secs": 0, "pull": {"tag" / "team" / "side", "within": 20,
## "then": area, "name", "attack": false}}}: a LURE POST (a pole with a jar) set there: a lure for every leash whose
## lure is that tag, and, with "pull", it draws the scripted units of that group within `within` tiles to it ONCE (a
## wave leaves its road), then on to `then`; {"lured": tag} once one came, {"route_done": name} when they reach `then`
## (or the post). "secs": the post is gone after that long (0: it stays). {"lure_post": {"tag", "remove": true}}.
func lure_post(v: Dictionary) -> void:
	var tag := String(v.get("tag", "lure_post"))
	if bool(v.get("remove", false)):
		st["posts"] = (st["posts"] as Array).filter(func(p) -> bool: return String(p["tag"]) != tag)
		return
	var p := place(v.get("at", ""))
	if p == Vector2.INF:
		return
	var until: float = run.game.clock + float(v["secs"]) if float(v.get("secs", 0.0)) > 0.0 else INF
	st["posts"].append({"tag": tag, "pos": p, "until": until})
	# its spot as an area, so a route can go through it
	var c := run.game.cell_of(p)
	if not run.data.has("areas"):
		run.data["areas"] = {}
	(run.data["areas"] as Dictionary)["lure:" + tag] = [c.x - 1, c.y - 1, 3, 3]
	var pull: Variant = v.get("pull", null)
	if pull is Dictionary:
		var reach := float(pull.get("within", 20.0)) * _tile()
		var us := group(pull).filter(func(u) -> bool: return u.position.distance_to(p) <= reach and not run.player_teams.has(u.team))
		if not us.is_empty():
			st["lured"][tag] = int(st["lured"].get(tag, 0)) + us.size()
			var pts: Array = ["lure:" + tag]
			if pull.has("then"):
				pts.append(String(pull["then"]))
			run._order(us, {"do": "route", "route": pts, "name": String(pull.get("name", tag)), "attack": bool(pull.get("attack", false))})
			if run.game.mlog:
				run.game.mlog.add("(mission) the lure post %s pulled %d" % [tag, us.size()])
	run.game._ping(p, Color(0.5, 1.0, 0.4))
	run._send({"k": "ping", "p": p})


func _tick_posts() -> void:
	var g := run.game
	st["posts"] = (st["posts"] as Array).filter(func(p) -> bool: return g.clock < float(p["until"]))


# ================================================================== BUILDINGS THAT CONVERT (d07: the city turns)

## {"spread_convert": {"name", "from": tag (where it starts: a building or unit), "tag": the buildings that may turn,
## "to": team, "every": 20, "first": s, "warn": 5, "units": tag, "counter", "max", "stop": false}}: every `every` seconds
## the building of the tag NEAREST to the source or to one already turned is marked (a red ring and TURNING with its
## count for `warn` seconds, so the player sees where it goes next and can get there), then it changes side, and the
## units with the `units` tag within 4 tiles of it go with it. {"turned": {"name", "at_least"}}. "stop": the spread
## stops (the brake pulled; the quarter held).
func spread_convert(v: Dictionary) -> void:
	var nm := String(v.get("name", v.get("tag", "spread")))
	if bool(v.get("stop", false)):
		for s in st["spreads"]:
			if String(s["name"]) == nm:
				s["stopped"] = true
				s["next"] = null
		return
	st["spreads"] = (st["spreads"] as Array).filter(func(s) -> bool: return String(s["name"]) != nm)
	st["spreads"].append({"name": nm, "from": String(v.get("from", "")), "tag": String(v.get("tag", "")),
		"to": String(v.get("to", "")), "every": float(v.get("every", 20.0)), "warn": float(v.get("warn", 5.0)),
		"units": String(v.get("units", "")), "counter": String(v.get("counter", "")), "t": float(v.get("first", v.get("every", 20.0))),
		"seeds": [], "next": null, "due": 0.0, "stopped": false, "max": int(v.get("max", 9999))})


func _tick_spreads(dt: float) -> void:
	var g := run.game
	for s in st["spreads"]:
		if bool(s["stopped"]):
			continue
		var to := run.team_index(String(s["to"]))
		if to < 0:
			continue
		var nx = s.get("next")
		if nx != null:
			if not _alive(nx) or nx.team == to:
				s["next"] = null
			elif g.clock >= float(s["due"]):
				_turn_building(nx, to, s)
				s["next"] = null
			continue
		if int(st["turned"].get(String(s["name"]), 0)) >= int(s["max"]):
			continue
		s["t"] = float(s["t"]) - dt
		if float(s["t"]) > 0.0:
			continue
		s["t"] = float(s["every"])
		# the next: the nearest of the tag to the source or to any turned one
		var from: Array = []
		for e in run.tagged(String(s["from"])):
			from.append(_pos(e))
		for b in s["seeds"]:
			if _alive(b):
				from.append(_pos(b))
		var best: Entity = null
		var bd := INF
		for b in run.tagged(String(s["tag"])):
			if not (b is Building) or b.team == to:
				continue
			for p in from:
				var d: float = (p as Vector2).distance_to(b.center())
				if d < bd:
					bd = d
					best = b
		if best != null:
			s["next"] = best
			s["due"] = g.clock + float(s["warn"])
			g._ping(best.center(), Color(1.0, 0.3, 0.25))
			run._send({"k": "ping", "p": best.center()})


func _turn_building(b: Building, to: int, s: Dictionary) -> void:
	var g := run.game
	var was := b.team
	b.team = to
	b.queue.clear()
	b.refresh_cloth()
	g.selection.erase(b)
	b.selected = false
	b.queue_redraw()
	s["seeds"].append(b)
	g._recount_supply(was)
	g._recount_supply(to)
	g._vis_t = 0.0
	# its own men go with it
	if String(s["units"]) != "":
		for u in run.tagged(String(s["units"])):
			if u is Unit and u.team == was and b.edge_distance(u.position) <= 4.0 * _tile():
				run._turn(u, to, "")
	var nm := String(s["name"])
	st["turned"][nm] = int(st["turned"].get(nm, 0)) + 1
	_add_counter(String(s["counter"]), 1)
	g.float_text(b.center() + Vector2(0, -40), "TURNED", Color(1.0, 0.35, 0.3))
	run.objectives_changed.emit()
	if g.mlog:
		g.mlog.add("(mission) a %s turned: %d -> %d" % [b.kind, was, to])


# ================================================================== THE SPREADING GROUND (d04's plates, d08's swamp)

## {"ground": {"name", "from": tag (or "at"), "kind": "swamp" / "gear", "team", "r": 2, "step": 1, "every": 10, "max":
## 10, "wind": 0.04, "stop": false}}: ground that SPREADS by itself (its radius in tiles grows by `step` every `every`
## seconds up to `max`; it stays where the source stood if the source dies). "swamp": the Brood's own swamp for `team`
## (a Brood team: its creatures root and drink on it). "gear": brass gear plates (drawn), on which `team`'s Clockwork
## units are wound up (`wind` a second: no Clocktower needed). {"ground": {"name", "at_least": tiles}},
## {"ground": {"name", "on": tag}}.
func ground(v: Dictionary) -> void:
	var nm := String(v.get("name", v.get("from", "ground")))
	if bool(v.get("stop", false)):
		for gr in st["grounds"]:
			if String(gr["name"]) == nm:
				gr["stopped"] = true
		return
	st["grounds"] = (st["grounds"] as Array).filter(func(x) -> bool: return String(x["name"]) != nm)
	var src: Array = run.tagged(String(v.get("from", "")))
	var p: Vector2 = _pos(src[0]) if not src.is_empty() else place(v.get("at", ""))
	if p == Vector2.INF:
		return
	var t: int = run.team_index(String(v["team"])) if v.has("team") else (src[0].team if not src.is_empty() else -1)
	st["grounds"].append({"name": nm, "src": src[0] if not src.is_empty() else null, "at": p, "kind": String(v.get("kind", "gear")),
		"team": t, "r": float(v.get("r", 2.0)), "step": float(v.get("step", 1.0)), "every": float(v.get("every", 10.0)),
		"max": float(v.get("max", 10.0)), "wind": float(v.get("wind", 0.04)), "t": float(v.get("every", 10.0)), "stopped": false})
	run.game.swamp_dirty = true


func _ground(nm: String) -> Dictionary:
	for gr in st["grounds"]:
		if String(gr["name"]) == nm:
			return gr
	return {}


func _ground_centre(gr: Dictionary) -> Vector2:
	var s = gr.get("src")
	if _alive(s):
		gr["at"] = _pos(s)
	return gr["at"]


func _tick_grounds(dt: float) -> void:
	var g := run.game
	for gr in st["grounds"]:
		var c := _ground_centre(gr)
		if not bool(gr["stopped"]) and float(gr["r"]) < float(gr["max"]):
			gr["t"] = float(gr["t"]) - dt
			if float(gr["t"]) <= 0.0:
				gr["t"] = float(gr["every"])
				gr["r"] = minf(float(gr["max"]), float(gr["r"]) + float(gr["step"]))
				if String(gr["kind"]) == "swamp":
					g.swamp_dirty = true
		if String(gr["kind"]) == "gear" and float(gr["wind"]) > 0.0:
			var r := float(gr["r"]) * _tile()
			for u in g.units:
				if u.dead or u.team != int(gr["team"]) or String(u.d.get("faction", "")) != "clockwork":
					continue
				if u.position.distance_to(c) <= r:
					u.wind = minf(1.0, u.wind + float(gr["wind"]) * dt)


## Game._update_swamp asks: the mission's swamp grounds of a team, as [centre in tiles, radius in tiles].
func swamp_sources(t: int) -> Array:
	var out: Array = []
	for gr in st["grounds"]:
		if String(gr["kind"]) == "swamp" and int(gr["team"]) == t:
			out.append([_ground_centre(gr) / _tile(), float(gr["r"])])
	return out


# ================================================================== THE BRAKE (d07: the Great Spring stopped)

## {"brake": {"team" / "tag" / "side" / "faction": "clockwork", "on": true, "name"}}: every Clockwork unit of them (new
## ones too) runs down to nothing at once and stays run down (a construct with no wind stands still) until the brake
## is let off ({"on": false}); then Winders and fields wind them again as usual.
func brake(v: Dictionary) -> void:
	var nm := String(v.get("name", v.get("tag", v.get("team", v.get("side", v.get("faction", "brake"))))))
	st["brakes"] = (st["brakes"] as Array).filter(func(b) -> bool: return String(b["name"]) != nm)
	if bool(v.get("on", true)):
		st["brakes"].append({"name": nm, "q": v.duplicate()})
		_tick_brakes()
		run.play_sound("campaign/off_beat", "", 0.0)


func _braked_units(q: Dictionary) -> Array:
	if q.has("faction"):
		return run.game.units.filter(func(u) -> bool: return not u.dead and String(u.d.get("faction", "")) == String(q["faction"]))
	return group(q)


func _tick_brakes() -> void:
	for b in st["brakes"]:
		for u in _braked_units(b["q"]):
			if String(u.d.get("faction", "")) == "clockwork":
				u.wind = 0.0


func braked(u: Unit) -> bool:
	for b in st["brakes"]:
		if _braked_units(b["q"]).has(u):
			return true
	return false


# ================================================================== SAPPING (d11: the old galleries)

## {"sap": {"tag", "to": area / [x, y], "secs": 30, "name", "blast": {"tag", "amount", "within": 3}}}: the units go
## UNDER THE GROUND (off the field: nobody sees them but their own side, who see the gallery dug as a dotted line and
## a mound moving along it; nothing can hit them; walls and water don't stop them) straight to the place over `secs`
## seconds, then come up there ({"sapped": name}); with "blast" a mine goes off as they come up: everything of the
## blast's tag within `within` tiles takes `amount`. It works on a person's men too (the story's action).
func sap(v: Dictionary) -> void:
	var to := place(v.get("to", ""))
	if to == Vector2.INF:
		return
	var nm := String(v.get("name", v.get("tag", "sap")))
	var g := run.game
	for u in run.tagged(String(v.get("tag", ""))):
		if not (u is Unit) or u.off_field:
			continue
		_off_routes(u)
		u.cmd_stop()
		u.off_field = true
		u.visible = g.sees_all() or g.allied(u.team, g.fog_team())
		u.modulate.a = 0.35
		u.selected = false
		g.selection.erase(u)
		var jit := Vector2(_noise(u.get_instance_id(), 1) * 30.0 - 15.0, _noise(2, u.get_instance_id()) * 30.0 - 15.0)
		st["saps"].append({"u": u, "from": u.position, "to": to + jit, "t0": g.clock, "secs": float(v.get("secs", 30.0)),
			"name": nm, "blast": v.get("blast", {})})


func _tick_saps() -> void:
	var g := run.game
	for s in (st["saps"] as Array).duplicate():
		var u = s.get("u")
		if not _alive(u):
			st["saps"].erase(s)
			continue
		if g.clock < float(s["t0"]) + float(s["secs"]):
			continue
		st["saps"].erase(s)
		u.off_field = false
		u.modulate.a = 1.0
		u.position = s["to"]
		g.note_move(u)
		u.velocity = Vector2.ZERO
		g._vis_t = 0.0
		var nm := String(s["name"])
		if not st["sapped"].has(nm):
			st["sapped"][nm] = g.clock
			g.spawn_effect("dust", u.position, 1.0)
			var bl: Dictionary = s.get("blast", {})
			if not bl.is_empty():
				var r := float(bl.get("within", 3.0)) * _tile()
				g.spawn_effect("blast", u.position, 1.0)
				for e in run.tagged(String(bl.get("tag", ""))):
					var d: float = e.edge_distance(u.position) if e is Building else _pos(e).distance_to(u.position)
					if d <= r:
						e.take_damage(float(bl.get("amount", 400.0)), null)
			run.objectives_changed.emit()
			if g.mlog:
				g.mlog.add("(mission) the sappers came up (%s)" % nm)


# ================================================================== GRANARIES (d05: the fields that feed the swarm)

## Mission "granaries": [{"tag": building(s), "gold": 10, "powder": 0, "every": 10, "hold_within": 4, "counter"}]: a
## granary FEEDS whoever holds it: its own team while it stands, or, when men of another side stand within
## `hold_within` tiles of it and none of its own (a Brood swarm round the barns), the team of the nearest of them.
## A "+10" over it each time for that player. {"fed": {"team", "at_least"}} counts what each team got.
func _tick_granaries(dt: float) -> void:
	var rules: Array = run.data.get("granaries", [])
	if rules.is_empty():
		return
	var g := run.game
	for i in rules.size():
		var rule: Dictionary = rules[i]
		var key: String = str(i)
		var t := float(st["gran_t"].get(key, float(rule.get("every", 10.0)))) - dt
		if t > 0.0:
			st["gran_t"][key] = t
			continue
		st["gran_t"][key] = float(rule.get("every", 10.0))
		for b in run.tagged(String(rule.get("tag", ""))):
			if not (b is Building) or b.ghost:
				continue
			var holder: int = holder_of(b, float(rule.get("hold_within", 4.0)) * _tile())
			if holder < 0 or holder >= g.players.size():
				continue
			var gold := int(rule.get("gold", 10))
			g.players[holder]["gold"] = int(g.players[holder]["gold"]) + gold
			g.players[holder]["res2"] = float(g.players[holder]["res2"]) + float(rule.get("powder", 0))
			var tid: String = String(run.team_ids[holder]) if holder < run.team_ids.size() else ""
			st["fed"][tid] = int(st["fed"].get(tid, 0)) + gold
			_add_counter(String(rule.get("counter", "")), gold)
			if holder == g.fog_team() or g.sees_all():
				g.float_text(b.center() + Vector2(0, -30), "+%d" % gold, Color(1.0, 0.9, 0.45))


## Who holds a building now: men of another side round it and none of its own: the nearest's team; else its own.
func holder_of(b: Building, ring: float) -> int:
	var g := run.game
	var own := 0
	var best := -1
	var bd := INF
	for u in g.units:
		if u.dead or u.off_field or u.kind == "horse" or u.is_air():
			continue
		var d: float = b.edge_distance(u.position)
		if d > ring:
			continue
		if g.allied(u.team, b.team):
			own += 1
		elif d < bd:
			bd = d
			best = u.team
	if own > 0 or best < 0:
		return b.team
	return best


# ================================================================== the IDLE METER (the owner's rule 2: NO WAITING)

## How long the player has had nothing to do: no line said, no objective or counter changed, no choice open, none of
## the player's units fighting (one with a living target within IDLE_FIGHT tiles, or hurt), nothing new made. A
## mission's sim reads longest_idle() at its end (target: under 45 s).
func _tick_idle(dt: float) -> void:
	var g := run.game
	var idle: Dictionary = st["idle"]
	var sig := str([run.said_ids.size(), run.obj, run.counters])
	var busy: bool = sig != String(idle.get("sig", "")) or not run.choice_open.is_empty()
	idle["sig"] = sig
	var mine := 0
	var hp := 0.0
	for u in g.units:
		if u.dead or not run.player_teams.has(u.team):
			continue
		mine += 1
		hp += u.hp
		if not busy and u.target != null and is_instance_valid(u.target) and not u.target.dead \
				and u.target.position.distance_to(u.position) <= IDLE_FIGHT * _tile():
			busy = true
	for b in g.buildings:
		if not b.dead and run.player_teams.has(b.team):
			mine += 1
	if mine > int(idle.get("mine", 0)) or hp < float(idle.get("hp", 0.0)) - 1.0:
		busy = true           # (something new made, or the player's men hurt: a fight)
	idle["mine"] = mine
	idle["hp"] = hp
	if busy:
		idle["now"] = 0.0
	else:
		idle["now"] = float(idle.get("now", 0.0)) + dt
		if float(idle["now"]) > float(idle.get("max", 0.0)):
			idle["max"] = float(idle["now"])
			idle["at"] = g.clock - float(idle["now"])


## The longest stretch so far with nothing for the player to do: {"secs", "from" (the game clock it began)}.
func longest_idle() -> Dictionary:
	var idle: Dictionary = st["idle"]
	return {"secs": float(idle.get("max", 0.0)), "from": float(idle.get("at", 0.0))}


# ================================================================== VERSIONS (d10, d11)

## Mission "versions": {"pick": [{"if": cond, "id": "fresh"}], "default": "grown", "labels": {id: words}}: the
## mission's VERSION, picked once at the start (the first `pick` whose condition holds: a `past` flag, the difficulty,
## the side, the heir), kept in the flag "version"; units, buildings, waves and lines read it with
## {"version": "grown"}. Static so the briefing can say which one it is before the match (its label).
static func version_of(m: Dictionary, side := "", diff := "") -> String:
	var vs: Variant = m.get("versions", null)
	if not (vs is Dictionary):
		return ""
	for pk in vs.get("pick", []):
		if Campaign.cond_before(pk.get("if", {}), side, diff if diff != "" else Campaign.difficulty()):
			return String(pk.get("id", ""))
	return String(vs.get("default", ""))



# ================================================================== THE UNMAPPED (d04_concordia)

## {"chart": {"side": whose map, "team" (else the side's teams): whose FLYERS map it, "known": [areas mapped from the
## start], "dark": 0.62, "on": false}}: THE FOG OF THE UNMAPPED. The side's screen shows the land dark where nobody has
## mapped it yet, and the other sides' units there are not on its screen at all (nor its minimap); the ground is mapped
## only where a FLYER of the team has flown (its sight round it), and in the known areas. "on": false lifts it (the map
## stays as it is drawn; nothing is hidden any more). Condition {"charted": {"area", "at_least"}}.
func chart(v: Dictionary) -> void:
	var g := run.game
	if not bool(v.get("on", true)):
		st["chart"]["on"] = false
		_chart_dirty = true
		return
	var c: Dictionary = st["chart"]
	c["on"] = true
	c["side"] = String(v.get("side", ""))
	c["team"] = String(v.get("team", ""))
	c["dark"] = float(v.get("dark", 0.62))
	if _chart.size() != g.W * g.H:
		_chart = PackedByteArray()
		_chart.resize(g.W * g.H)
	for a in v.get("known", []):
		_chart_rect(run.area_rect(String(a)))
	_chart_dirty = true
	_chart_save()


func _chart_on() -> bool:
	return bool(st["chart"].get("on", false)) and _chart.size() == run.game.W * run.game.H


func _chart_rect(r: Rect2) -> void:
	var g := run.game
	var a := g.cell_of(r.position)
	var b := g.cell_of(r.end)
	for y in range(maxi(0, a.y), mini(g.H - 1, b.y) + 1):
		for x in range(maxi(0, a.x), mini(g.W - 1, b.x) + 1):
			_chart[y * g.W + x] = 1


## Is the cell under p mapped (or is there no chart)?
func charted_at(p: Vector2) -> bool:
	if not _chart_on():
		return true
	var g := run.game
	var c := g.cell_of(p)
	return not g.in_map(c) or _chart[g.idx(c)] == 1


## The share of the area's open cells (no water, no rock) that is mapped.
func chart_share(area: String) -> float:
	var g := run.game
	if _chart.size() != g.W * g.H:
		return 0.0
	var r := run.area_rect(area) if area != "" else Rect2(Vector2.ZERO, Vector2(g.W, g.H) * _tile())
	var a := g.cell_of(r.position)
	var b := g.cell_of(r.end - Vector2.ONE)
	var n := 0
	var m := 0
	for y in range(maxi(0, a.y), mini(g.H - 1, b.y) + 1):
		for x in range(maxi(0, a.x), mini(g.W - 1, b.x) + 1):
			n += 1
			m += _chart[y * g.W + x]
	return float(m) / float(maxi(1, n))


func _tick_chart(dt: float) -> void:
	if not _chart_on():
		if _chart_sprite and is_instance_valid(_chart_sprite):
			_chart_sprite.visible = false
		return
	var g := run.game
	var c: Dictionary = st["chart"]
	var teams: Array = [run.team_index(String(c["team"]))] if String(c["team"]) != "" else run.teams_of_side(String(c["side"]))
	var changed := false
	for u in g.units:
		if u.dead or u.off_field or not teams.has(u.team) or not u.is_air():
			continue
		var cc := g.cell_of(u.position)
		var r := int(u.sight)
		for dy in range(-r, r + 1):
			var y := cc.y + dy
			if y < 0 or y >= g.H:
				continue
			for dx in range(-r, r + 1):
				var x := cc.x + dx
				if x < 0 or x >= g.W or dx * dx + dy * dy > r * r:
					continue
				var i := y * g.W + x
				if _chart[i] == 0:
					_chart[i] = 1
					changed = true
	if changed:
		_chart_dirty = true
	_chart_t -= dt
	if _chart_dirty and _chart_t <= 0.0:
		_chart_t = 0.5
		_chart_dirty = false
		_chart_save()
		_chart_draw()


func _chart_save() -> void:
	st["chart"]["mask"] = Marshalls.raw_to_base64(_chart.compress(FileAccess.COMPRESSION_DEFLATE))
	st["chart"]["n"] = _chart.size()


func _chart_load() -> void:
	var c: Dictionary = st["chart"]
	if not c.has("mask"):
		return
	var raw := Marshalls.base64_to_raw(String(c["mask"]))
	_chart = raw.decompress(int(c.get("n", 0)), FileAccess.COMPRESSION_DEFLATE)
	_chart_dirty = true


## The dark over the unmapped land (the chart's side's screen only), a picture of the map one pixel a cell under the
## units: drawn soft at its edges.
func _chart_draw() -> void:
	var g := run.game
	if g == null:
		return
	if _chart_sprite == null or not is_instance_valid(_chart_sprite):
		_chart_sprite = Sprite2D.new()
		_chart_sprite.name = "Unmapped"
		_chart_sprite.centered = false
		_chart_sprite.scale = Vector2(_tile(), _tile())
		_chart_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		_chart_sprite.z_index = -15          # (over the ground and its marks, under every building and unit)
		g.add_child(_chart_sprite)
	var a := int(clampf(float(st["chart"].get("dark", 0.62)), 0.0, 1.0) * 255.0)
	var px := PackedByteArray()
	px.resize(g.W * g.H * 2)
	for i in g.W * g.H:
		px[i * 2] = 18
		px[i * 2 + 1] = 0 if _chart[i] == 1 else a
	if _chart_img == null:
		_chart_img = Image.create_from_data(g.W, g.H, false, Image.FORMAT_LA8, px)
		_chart_tex = ImageTexture.create_from_image(_chart_img)
		_chart_sprite.texture = _chart_tex
	else:
		_chart_img.set_data(g.W, g.H, false, Image.FORMAT_LA8, px)
		_chart_tex.update(_chart_img)
	_chart_sprite.visible = _chart_viewer()


## Does the screen's own side read this chart?
func _chart_viewer() -> bool:
	return _chart_on() and not _sees_all() and _viewer_side() == String(st["chart"].get("side", ""))


## (after_vis) the other sides' units on unmapped land are not on the chart side's screen.
func _chart_hide(ft: int) -> void:
	if _chart_sprite and is_instance_valid(_chart_sprite):
		_chart_sprite.visible = _chart_viewer()
	if not _chart_viewer():
		return
	var g := run.game
	for u in g.units:
		if u.visible and ft >= 0 and not g.allied(u.team, ft) and not charted_at(u.position):
			u.visible = false


# ================================================================== after a save is loaded

## The marks a save doesn't keep, put back from the state (MissionRun.load_state).
func after_load() -> void:
	_chart_load()
	for it in st["loads"]:
		if _alive(it.get("cart")):
			it["cart"].set_meta("cart_load", String(it["cargo"]))
	for it in st["hidden"]:
		var e = it.get("e")
		if _alive(e):
			e.spared = true
			e.set_meta("mission_hidden", String(it["from"]))
	for s in st["saps"]:
		var u = s.get("u")
		if _alive(u):
			u.off_field = true
			u.modulate.a = 0.35
	for l in st["leashes"]:
		for u in l.get("units", []):
			if _alive(u) and u.has_meta("leash_loose"):
				_loose_t[u] = 0.0


# ================================================================== drawing

func _draw_under() -> void:
	var g := run.game
	var cv := under
	var mysi := Campaign.side_index(run.data, _viewer_side())
	var ft := g.fog_team()
	# THE SPREADING GROUND: gear plates (the swamp is the Game's own)
	for gr in st["grounds"]:
		if String(gr["kind"]) != "gear":
			continue
		var c := _ground_centre(gr)
		var r := float(gr["r"]) * _tile()
		var step := _tile()
		var n := int(ceil(r / step))
		for y in range(-n, n + 1):
			for x in range(-n, n + 1):
				var p := c + Vector2(x, y) * step
				if p.distance_to(c) > r:
					continue
				var cell := g.cell_of(p)
				if not g.in_map(cell) or not g._walkable(cell):
					continue
				var pc := g.cell_center(cell)
				if not _sees_all() and ft >= 0 and not g.allied(int(gr["team"]), ft) and not g.is_visible_to(ft, pc):
					continue
				var shade := 0.85 + 0.15 * _noise(cell.x, cell.y)
				cv.draw_rect(Rect2(pc - Vector2(step, step) * 0.47, Vector2(step, step) * 0.94), Color(0.62 * shade, 0.48 * shade, 0.22 * shade, 0.55))
				cv.draw_arc(pc, step * 0.28, 0.0, TAU, 10, Color(0.35, 0.25, 0.1, 0.6), 1.5)
				for k in 6:
					var a := TAU * float(k) / 6.0 + float(cell.x + cell.y)
					cv.draw_line(pc + Vector2(cos(a), sin(a)) * step * 0.28, pc + Vector2(cos(a), sin(a)) * step * 0.38, Color(0.35, 0.25, 0.1, 0.6), 2.0)
	# THE SPREADING SWAMP of a Brood team the Game doesn't paint (it paints the first two teams' swamp only: a mission's
	# Brood is often its third or fourth team): its cells drawn here with the swamp's own picture
	for gr in st["grounds"]:
		var tm := int(gr["team"])
		if String(gr["kind"]) != "swamp" or tm < 2 or tm >= g.swamp.size():
			continue
		var tx: Texture2D = Game.tex("res://assets/tiles/swamp.png")
		var sw: PackedByteArray = g.swamp[tm]
		var c := _ground_centre(gr) / _tile()
		var rr := float(gr["r"]) + 1.0
		var tc := g.team_colour(tm)
		for y in range(int(c.y - rr), int(c.y + rr) + 1):
			for x in range(int(c.x - rr), int(c.x + rr) + 1):
				if x < 0 or y < 0 or x >= Game.W or y >= Game.H or sw[y * Game.W + x] != 1 or g.cliff[y * Game.W + x] != 0:
					continue
				var cp := g.cell_center(Vector2i(x, y))
				if not _sees_all() and ft >= 0 and not g.allied(tm, ft) and not g.is_visible_to(ft, cp):
					continue
				var rect := Rect2(Vector2(x, y) * _tile(), Vector2(_tile(), _tile()))
				if tx:
					cv.draw_texture_rect(tx, rect, false, Color(1, 1, 1, 0.9).lerp(tc, 0.15))
				else:
					cv.draw_rect(rect, Color(0.25, 0.35, 0.15, 0.8))
	# TRACKS: only the side that reads them (or a spectator)
	for m in _marks:
		if not _sees_all() and int(m[3]) != mysi:
			continue
		var age := (g.clock - float(m[1])) / maxf(1.0, float(m[4]))
		var al := clampf(1.0 - age, 0.0, 1.0) * 0.95
		var p: Vector2 = m[0]
		var ang: float = m[2]
		var fwd := Vector2(cos(ang), sin(ang))
		var sidev := fwd.orthogonal() * 6.0
		for sgn in [-1.0, 1.0]:
			var q: Vector2 = p + sidev * sgn + fwd * (4.0 if sgn > 0.0 else -4.0)
			cv.draw_circle(q, 3.5, Color(0.95, 0.88, 0.62, 0.35 * al))      # (a pale scuff so the print reads on dark grass)
			for t in 3:
				var ta := ang + (float(t) - 1.0) * 0.5
				var tip := q + Vector2(cos(ta), sin(ta)) * 8.0
				cv.draw_line(q, tip, Color(0.95, 0.88, 0.62, 0.3 * al), 4.5)
				cv.draw_line(q, tip, Color(0.16, 0.1, 0.04, al), 2.5)
	# SAPPING: the gallery dug, for its own side
	for s in st["saps"]:
		var u = s.get("u")
		if not _alive(u):
			continue
		if not _sees_all() and not g.allied(u.team, ft):
			continue
		var a2: Vector2 = s["from"]
		var b2: Vector2 = s["to"]
		var now: Vector2 = u.position
		var ln := a2.distance_to(now)
		var dirv := (b2 - a2).normalized()
		var d := 0.0
		cv.draw_line(a2, now, Color(0.12, 0.08, 0.04, 0.55), 9.0)          # (the gallery dug so far: a dark trench)
		while d < ln:
			cv.draw_line(a2 + dirv * d, a2 + dirv * minf(d + 10.0, ln), Color(0.55, 0.4, 0.2, 0.95), 4.0)
			d += 16.0
		cv.draw_dashed_line(now, b2, Color(1.0, 0.9, 0.55, 0.7), 2.0, 8.0)   # (the way still to dig)
		cv.draw_arc(b2, 12.0, 0.0, TAU, 24, Color(1.0, 0.9, 0.55, 0.8), 2.0)
		cv.draw_circle(now, 11.0, Color(0.3, 0.2, 0.1, 0.95))              # (the mound over the sappers)
		cv.draw_circle(now + Vector2(-3, -3), 5.0, Color(0.6, 0.46, 0.28, 0.95))


func _draw_over() -> void:
	var g := run.game
	var cv := over
	var font := ThemeDB.fallback_font
	var my := _viewer_side()
	var ft := g.fog_team()
	# THE LEASH: the lures' reach (for the side that holds the leash), LOOSE over a loose creature
	for l in st["leashes"]:
		var units: Array = l["units"]
		if units.is_empty() or not _alive(units[0]):
			continue
		var lside: String = run.side_of_team(units[0].team)
		if not _sees_all() and lside != my:
			continue
		var reach := float(l["within"]) * _tile()
		for p in lures_of(String(l["lure"])):
			cv.draw_arc(p, reach, 0.0, TAU, 96, Color(0.1, 0.2, 0.05, 0.35), 4.5)
			cv.draw_arc(p, reach, 0.0, TAU, 96, Color(0.6, 1.0, 0.5, 0.6), 2.0)
		for u in units:
			if _alive(u) and u.has_meta("leash_loose") and u.visible:
				_label(cv, font, u.position + Vector2(0, -u.radius - 22.0), Loc.t("LOOSE"), Color(1.0, 0.62, 0.3))
	# LURE POSTS: a pole with a jar
	for p in st["posts"]:
		var pp: Vector2 = p["pos"]
		if not _sees_all() and ft >= 0 and not g.is_visible_to(ft, pp):
			continue
		cv.draw_line(pp + Vector2(0, 6), pp + Vector2(0, -26), Color(0.32, 0.22, 0.12), 3.0)
		cv.draw_circle(pp + Vector2(0, -30), 6.0, Color(0.45, 0.7, 0.35, 0.95))
		cv.draw_arc(pp + Vector2(0, -30), 6.0, 0.0, TAU, 16, Color(0.15, 0.25, 0.1), 1.5)
		var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) / 300.0)
		cv.draw_arc(pp, 14.0 + 6.0 * pulse, 0.0, TAU, 32, Color(0.6, 1.0, 0.5, 0.5 - 0.3 * pulse), 2.0)
		_label(cv, font, pp + Vector2(0, -44), Loc.t("LURE POST"), Color(0.7, 1.0, 0.6))
	# TAKE A CART: the bar filling over a cart being taken
	for it in st["takes"]:
		var c = it.get("cart")
		if not _alive(c) or not c.visible:
			continue
		var k := clampf(float(it["t"]) / maxf(0.1, float(it.get("secs", 5.0))), 0.0, 1.0)
		var top: Vector2 = c.position + Vector2(-26, c.radius + 8.0)      # (under the cart: its name and bar stay clear)
		cv.draw_rect(Rect2(top, Vector2(52, 7)), Color(0, 0, 0, 0.7))
		cv.draw_rect(Rect2(top + Vector2(1, 1), Vector2(50 * k, 5)), Color(1.0, 0.6, 0.2))
		_label(cv, font, top + Vector2(26, 22), Loc.t(String(it.get("label", "TAKING THE CART"))), Color(1.0, 0.7, 0.35))
	# CARGO: a bundle (families) or a chest (gold) on a cart
	for it in st["loads"]:
		var c = it.get("cart")
		if not _alive(c) or not c.visible:
			continue
		var p: Vector2 = c.position + Vector2(c.radius + 12.0, -14.0)      # (beside the cart, clear of its name and flag)
		cv.draw_circle(p, 13.0, Color(0, 0, 0, 0.45))
		if String(it["cargo"]) == "gold":
			cv.draw_rect(Rect2(p - Vector2(9, 6), Vector2(18, 12)), Color(0.45, 0.28, 0.12))
			cv.draw_rect(Rect2(p - Vector2(9, 6), Vector2(18, 4)), Color(0.95, 0.78, 0.25))
		else:
			cv.draw_circle(p + Vector2(-5, 0), 6.0, Color(0.55, 0.45, 0.32))
			cv.draw_circle(p + Vector2(5, 1), 5.0, Color(0.42, 0.36, 0.28))
			cv.draw_circle(p + Vector2(0, -5), 5.0, Color(0.62, 0.5, 0.35))
		if int(it["n"]) > 1:
			_label(cv, font, p + Vector2(0, 26), "x%d" % int(it["n"]), Color(1, 1, 1))
	# BUILDINGS THAT CONVERT: the next to turn
	for s in st["spreads"]:
		var b = s.get("next")
		if not _alive(b) or not b.visible:
			continue
		var left := maxf(0.0, float(s["due"]) - g.clock)
		var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) / 160.0)
		var rad: float = float(maxi(b.size.x, b.size.y)) * _tile() * 0.62
		cv.draw_arc(b.center(), rad, 0.0, TAU, 48, Color(1.0, 0.25, 0.2, 0.5 + 0.4 * pulse), 3.0)
		_label(cv, font, b.center() + Vector2(0, -rad - 10.0), Loc.t("TURNING") + " %d" % int(ceil(left)), Color(1.0, 0.4, 0.35))


func _label(cv: CanvasItem, font: Font, p: Vector2, txt: String, col: Color) -> void:
	var fs := 13
	var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	cv.draw_string_outline(font, p - Vector2(w * 0.5, 0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(0, 0, 0, 0.8))
	cv.draw_string(font, p - Vector2(w * 0.5, 0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
