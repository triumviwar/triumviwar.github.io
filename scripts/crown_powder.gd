class_name CrownPowder
## THE CROWN'S POWDER STUDY (crown-powder-study, docs/crown_powder_study.md; the owner 2026-11-20 01:09: "Measure").
## crown-1000-clockwork found each Town Hall's saltpetre (Defs.LODE 1,320 powder) spent in ~11 minutes by a worked Mill, the
## Mill then at Defs.POWDER_FLOOR 15%, and from ~9:00 the Crown's powder bank at 0-30 while its gold piled up to thousands.
## Four design options, each a MATCH SWITCH, all OFF by default (the owner decides):
##   `-- powder:salt2500`  A: a Town Hall holds 2,500 saltpetre (was 1,320)
##   `-- powder:floor35`   B: a Mill on spent saltpetre grinds at 35% (was 15%)
##   `-- powder:nitre`     C: NITRE BEDS, a small Crown building that turns gold into powder slowly (scripts below)
##   `-- powder:buy`       D: BUY POWDER at the Town Hall: 50 powder for 150 gold, a short wait between buys
## Several at once: `-- powder:salt2500+nitre`. Nothing else in the game changes.

static var _args: PackedStringArray = OS.get_cmdline_user_args()
static var opts: Dictionary = _parse(_args)


static func _parse(args: PackedStringArray) -> Dictionary:
	var d := {}
	for a in args:
		if a.begins_with("powder:"):
			for p in a.substr(7).split("+", false):
				d[p] = true
	return d


static func on(name: String) -> bool:
	return opts.has(name)


## (tests) set the options as if from the command line ("" none).
static func set_opts(s: String) -> void:
	opts = _parse(PackedStringArray(["powder:" + s]) if s != "" else PackedStringArray())


# ------------------------------------------------------------------ A. more saltpetre (salt2500)

const SALT := 2500.0


## A hall's full lode (Building.lode_full, Game.lode_at_spot): Defs.LODE, the Town Hall's saltpetre SALT with `salt2500`.
static func lode_full(kind: String) -> float:
	if kind == "town_hall" and on("salt2500"):
		return SALT
	return float(Defs.LODE.get(kind, 0.0))


# ------------------------------------------------------------------ B. a higher floor (floor35)

const FLOOR := 0.35


## The Powder Mill's yield share on spent saltpetre (Game.draw_lode, the cards): Defs.POWDER_FLOOR, FLOOR with `floor35`.
static func powder_floor() -> float:
	return FLOOR if on("floor35") else Defs.POWDER_FLOOR


# ------------------------------------------------------------------ C. NITRE BEDS (nitre)

## A small Crown building (Defs.BUILDINGS "nitre_beds", 3 x 2, 125 gold, 25 s; stand-in art tools/draw_nitre_beds.py): beds of
## dung and earth that grow saltpetre. By itself (no crew) it turns gold into powder: BEDS_PRICE gold a powder, one powder
## every BEDS_EVERY s (40 a minute, 120 gold a minute). A fresh Mill with its 6 labourers grinds ~119 a minute for no gold,
## and a spent one 18 (35% floor: 42): the beds never beat a fresh Mill, and they cost gold the army wanted.
## It must stand by a Farm or a Horse Breeder (BEDS_NEAR tiles, centre to centre) within a Town Hall's ECON_RANGE; one per
## Town Hall (the hall nearest it); it rests while BEDS_REST powder is banked (the beds are full).
const BEDS := "nitre_beds"
const BEDS_PRICE := 3
const BEDS_EVERY := 1.5
const BEDS_REST := 400.0
const BEDS_NEAR := 8.0


## The refusal for Nitre Beds at cell c ("" fits), past the usual footprint checks (Game.placement_problem).
static func place_problem(g, t: int, c: Vector2i) -> String:
	var size: Vector2i = Defs.BUILDINGS[BEDS]["size"]
	var mid := (Vector2(c) + Vector2(size) * 0.5) * Defs.TILE
	var h: Building = g.nearest_hall(mid, t)
	if h == null or h.edge_distance(mid) > Defs.ECON_RANGE * Defs.TILE:
		return "Must be near your Town Hall."
	for b in g.buildings:
		if b.team == t and b.kind == BEDS and not b.dead and g.nearest_hall(b.center(), t) == h:
			return "This Town Hall already has its Nitre Beds (1/1). Build near another Town Hall."
	if not _fed(g, t, mid):
		return "Nitre Beds must stand by a Farm or a Horse Breeder (their dung feeds the beds)."
	return ""


## A Farm or a Horse Breeder of t stands within BEDS_NEAR tiles of p.
static func _fed(g, t: int, p: Vector2) -> bool:
	for b in g.buildings:
		if b.team == t and not b.dead and (b.kind == "farm" or b.kind == "horse_breeder") and b.center().distance_to(p) <= BEDS_NEAR * Defs.TILE:
			return true
	return false


## Every tick of built Nitre Beds (Building._econ).
static func beds_tick(b: Building, delta: float) -> void:
	var g = b.game
	var t: int = b.team
	if g == null or float(g.players[t]["res2"]) >= BEDS_REST:
		return
	var acc: float = float(b.get_meta("nitre_t", 0.0)) + delta
	var fed_t: float = float(b.get_meta("nitre_fed_t", -1.0))
	if fed_t < 0.0 or g.clock - fed_t > 3.0:
		b.set_meta("nitre_fed_t", g.clock)
		b.set_meta("nitre_fed", _fed(g, t, b.center()))
	if not bool(b.get_meta("nitre_fed", true)):
		b.set_meta("nitre_t", 0.0)
		return          # (its Farm or Horse Breeder is gone: the beds go hungry)
	if acc >= BEDS_EVERY:
		if int(g.players[t]["gold"]) < BEDS_PRICE:
			b.set_meta("nitre_t", BEDS_EVERY)
			return
		acc -= BEDS_EVERY
		g.players[t]["gold"] -= BEDS_PRICE
		g.stats[t]["spent"] += BEDS_PRICE
		g.players[t]["res2"] = float(g.players[t]["res2"]) + 1.0
		var st: Dictionary = g.stats[t]
		st["nitre_powder"] = float(st.get("nitre_powder", 0.0)) + 1.0
		st["nitre_gold"] = float(st.get("nitre_gold", 0.0)) + BEDS_PRICE
	b.set_meta("nitre_t", acc)


# ------------------------------------------------------------------ D. BUY POWDER (buy)

## BUY POWDER on a Town Hall's card: BUY_POWDER powder for BUY_GOLD gold at once (3 gold a powder, the beds' price), then
## BUY_WAIT s before the side may buy again (one wait for the whole side, not per hall: at most 100 powder a minute, under
## a fresh Mill's ~119).
const BUY_POWDER := 50
const BUY_GOLD := 150
const BUY_WAIT := 30.0


## Why team t can't buy now ("" it can).
static func buy_problem(g, t: int) -> String:
	if not on("buy") or g.faction_of(t) != "crown":
		return "Not in this match."
	if g.halls_of(t).is_empty():
		return "Needs a Town Hall."
	var left := float(g.stats[t].get("buy_next", 0.0)) - float(g.clock)
	if left > 0.0:
		return "The powder merchant comes again in %d s." % int(ceil(left))
	if int(g.players[t]["gold"]) < BUY_GOLD:
		return "Needs %d gold." % BUY_GOLD
	return ""


## Buy (Game.buy_powder, which an online guest forwards to the host). Returns "" or the refusal.
static func buy(g, t: int) -> String:
	var why := buy_problem(g, t)
	if why != "":
		return why
	var st: Dictionary = g.stats[t]
	g.players[t]["gold"] -= BUY_GOLD
	st["spent"] += BUY_GOLD
	g.players[t]["res2"] = float(g.players[t]["res2"]) + float(BUY_POWDER)
	st["buy_next"] = float(g.clock) + BUY_WAIT
	st["bought_powder"] = float(st.get("bought_powder", 0.0)) + BUY_POWDER
	st["buy_gold"] = float(st.get("buy_gold", 0.0)) + BUY_GOLD
	return ""


## The Town Hall card's BUY POWDER button (HUD).
static func card(hud, list: Array) -> void:
	if not on("buy"):
		return
	var g = hud.game
	var why := buy_problem(g, g.human)
	hud._tip_for["BUY POWDER"] = ["Buy powder", "%d powder for %d gold at once (3 gold a powder); the merchant comes again %d s later. A study option (crown-powder-study, match switch powder:buy)." % [BUY_POWDER, BUY_GOLD, int(BUY_WAIT)]]
	list.append(["ab_buy_powder", "BUY POWDER", func() -> void:
		var w: String = g.buy_powder(g.human)
		if w != "":
			hud.toast(w), why == "", why, str(BUY_GOLD)])


# ------------------------------------------------------------------ the computer (C and D)

## The computer's trigger, the same for both: gold banked and little powder (`dry` against the Clockwork uses 400 too), after
## the opening (AI_FROM).
const AI_GOLD := 400
const AI_POWDER := 60.0
## Not before this clock (s). The owner's sketch was "at a hall whose saltpetre is low"; traced (Mirewood 9269 v the
## Clockwork, `nitre`), the bank was dry from ~10:00 with every hall still holding over a third of its saltpetre (4,500 in
## the ground at 13:00): the Mills could not grind fast enough for the army, so no hall was ever "low" and no beds were laid.
## So the trigger is the dry bank after the opening; the beds go by the hall with the least saltpetre left first.
const AI_FROM := 360.0
## (C) a new bed no sooner than this after the last was laid (s): the dry bank must last
const AI_BEDS_GAP := 60.0


## Think stage 1 of the Crown computer (AICrown._think_stage_crown). BUY POWDER with AI_GOLD banked; the beds, a lasting
## building, as soon as their price can be paid (traced, Mirewood 9269 v the Clockwork: the bank sat at 200-370 from 12:00
## with the powder at 0, so a 400-gold trigger would have laid none until 16:00).
static func ai_tick(ai) -> void:
	if not (on("nitre") or on("buy")) or ai.game == null or ai.game.faction_of(ai.team) != "crown":
		return
	var g = ai.game
	var t: int = ai.team
	if ai._res2() >= AI_POWDER:
		return
	if float(g.clock) < AI_FROM:
		return          # (the opening's empty bank before the first Mill is not the problem these answer)
	if on("buy") and ai._gold() >= AI_GOLD and buy_problem(g, t) == "":
		buy(g, t)
		_count(ai, "buy")
	if on("nitre"):
		_ai_beds(ai)


static func _ai_beds(ai) -> void:
	var g = ai.game
	var t: int = ai.team
	if ai._gold() < int(Defs.BUILDINGS[BEDS]["cost"]) + 50:
		return
	for b in g.buildings:
		if b.team == t and b.kind == BEDS and not b.dead and not b.built:
			return          # (one site at a time)
	if float(g.clock) - float(ai.get_meta("powder_beds_t", -999.0)) < AI_BEDS_GAP:
		return
	var halls: Array = ai._halls().filter(func(h: Building) -> bool: return h.built)
	halls.sort_custom(func(a: Building, b: Building) -> bool: return a.lode_left() < b.lode_left())
	for h in halls:
		var has := false
		for b in g.buildings:
			if b.team == t and b.kind == BEDS and not b.dead and g.nearest_hall(b.center(), t) == h:
				has = true
				break
		if has:
			continue
		var spot: Vector2i = g.find_spot(t, BEDS, h, 2, Defs.ECON_RANGE - 2, "near", true)
		if spot.x < 0:
			spot = g.find_spot(t, BEDS, h, 2, Defs.ECON_RANGE - 2, "near")
		if spot.x < 0:
			continue
		ai._construct(BEDS, spot)
		ai.set_meta("powder_beds_t", float(g.clock))
		_count(ai, "beds")
		return


static func _count(ai, name: String) -> void:
	var d: Dictionary = ai.get_meta("powder_opt", {})
	d[name] = int(d.get(name, 0)) + 1
	ai.set_meta("powder_opt", d)


# ------------------------------------------------------------------ the measure

## What the options made for team tm so far (result.json, tools/qa_match.gd): powder from Nitre Beds and bought.
static func made_of(g, tm: int) -> Dictionary:
	var st: Dictionary = g.stats[tm]
	return {"nitre": int(st.get("nitre_powder", 0.0)), "bought": int(st.get("bought_powder", 0.0)),
		"nitre_gold": int(st.get("nitre_gold", 0.0)), "buy_gold": int(st.get("buy_gold", 0.0)), "opts": "+".join(opts.keys())}
