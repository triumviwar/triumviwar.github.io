class_name HudAlerts
extends RefCounted
## The match HUD's watchers (job ui-hud-pass, 2026-11-28; docs/ui_hud_pass.md), kept apart from hud.gd:
##
## - THE ALERT LOG: the latest alerts with where they happened (under attack, a building finished, a research done).
##   JUMP TO LAST ALERT (the Home key on a computer, the small ALERT button by the minimap) moves the camera to the
##   newest; pressed again within a few seconds it goes to the one before, and so on round.
## - INCOME AND SPENDING A MINUTE per resource (the top bar's tooltips): sampled every 5 s over the last minute.
## - SUPPLY BLOCKED: a production held by supply (a train or an automatic train refused for supply) makes the supply
##   number flash red, and says one short line with the announcer's "need supply" once a block (not again until the
##   supply is free and blocks again).
## - THE QUICK BUTTONS' GLOWS: IDLE while a worker is idle, ARMY while some of your army is fighting, MAKE while every
##   production building is idle.

const KEEP := 10                 # alerts kept
const MERGE_TILES := 10.0        # an alert this near an earlier one of its kind...
const MERGE_S := 12.0            # ...this soon after it only moves it to the top
const CYCLE_S := 4.0             # a second press within this goes to the alert before
const FIGHT_S := 3.0             # a unit hit or firing this recently is "fighting" (ARMY glows)
const SAMPLE_S := 5.0
const SAMPLES := 13              # 13 samples 5 s apart: the last minute

var game: Game
var list: Array = []             # newest first: {p: Vector2, kind: String, text: String, clock: float}
var _cycle := 0
var _cycle_ms := -99999
var _samples: Array = []         # [clock, bank0, bank1, in0, in1]
var block_clock := -99.0         # the game clock of the last production refused for supply
var _block_said := false
var _glow_memo := [-1, [false, false, false]]


func _init(g: Game) -> void:
	game = g


# ------------------------------------------------------------------ alerts

## A new alert at p (world). kind: "attack", "built", "research"; text: shown when jumping to it.
func add(p: Vector2, kind: String, text: String) -> void:
	if not p.is_finite():
		return
	for i in list.size():
		var a: Dictionary = list[i]
		if a["kind"] == kind and (a["p"] as Vector2).distance_to(p) < MERGE_TILES * Defs.TILE and game.clock - float(a["clock"]) < MERGE_S:
			list.remove_at(i)
			break
	list.push_front({"p": p, "kind": kind, "text": text, "clock": game.clock})
	while list.size() > KEEP:
		list.pop_back()


## Move the camera to the newest alert; pressed again soon: the one before (round). The text it says, or "" if none.
func jump(hud) -> String:
	if list.is_empty():
		return ""
	var now := Time.get_ticks_msec()
	if now - _cycle_ms < CYCLE_S * 1000.0:
		_cycle = (_cycle + 1) % list.size()
	else:
		_cycle = 0
	_cycle_ms = now
	var a: Dictionary = list[_cycle]
	hud._jump(a["p"])
	var ago := int(game.clock - float(a["clock"]))
	var where := "%d/%d" % [_cycle + 1, list.size()]
	return Loc.t("Alert %s: %s (%d s ago)") % [where, Loc.t(String(a["text"])), ago]


## The newest alert is this fresh (seconds; INF with none): the ALERT button is lit while it is under 10 s.
func newest_age() -> float:
	return game.clock - float(list[0]["clock"]) if not list.is_empty() else INF


# ------------------------------------------------------------------ income and spending

## Call often (each HUD look): a sample every 5 s of team t's banks and what it has gathered.
func sample(t: int) -> void:
	if t < 0 or t >= game.players.size():
		return
	if not _samples.is_empty() and game.clock - float(_samples.back()[0]) < SAMPLE_S and game.clock >= float(_samples.back()[0]):
		return
	if not _samples.is_empty() and game.clock < float(_samples.back()[0]):
		_samples = []            # (a loaded save, a replay jumped back)
	_samples.append(_now(t))
	while _samples.size() > SAMPLES:
		_samples.pop_front()


func _now(t: int) -> Array:
	var pl: Dictionary = game.players[t]
	var st: Dictionary = game.stats[t]
	var tension := game.faction_of(t) == "clockwork" and Defs.gear_mode
	var b1 := float(pl.get("tension", 0.0)) if tension else float(pl.get("res2", 0.0))
	var i1 := float(st.get("tension_in", 0.0)) if tension else float(st.get("res2_in", 0.0))
	return [game.clock, float(pl.get("gold", 0.0)), b1, float(st.get("gold", 0.0)), i1]


## Resource i (0 the first, 1 the second) of team t over about the last minute: Vector2(income a minute, spent a minute).
## Spent = what came in less what the bank grew by (so it also counts losses, e.g. powder fired).
func rates(t: int, i: int) -> Vector2:
	sample(t)
	if _samples.is_empty():
		return Vector2.ZERO
	var a: Array = _samples[0]
	var b := _now(t)
	var dt := float(b[0]) - float(a[0])
	if dt < 1.0:
		return Vector2.ZERO
	var gained := float(b[3 + i]) - float(a[3 + i])
	var bank := float(b[1 + i]) - float(a[1 + i])
	return Vector2(gained, maxf(gained - bank, 0.0)) * (60.0 / dt)


# ------------------------------------------------------------------ supply blocked

## A production of the human's refused (why: its reason). Supply reasons start a block.
func note_refused(t: int, why: String) -> void:
	if t != game.human or game.demo:
		return
	var low := why.to_lower()
	if not (low.begins_with("need more supply") or low.begins_with("supply is maxed")):
		return
	block_clock = game.clock
	if not _block_said and game.hud:
		_block_said = true
		var maxed := low.begins_with("supply is maxed")
		var fac := game.faction_of(t)
		var line := Loc.t("SUPPLY BLOCKED: production is waiting.") + " " + (Loc.t("Supply is maxed out.") if maxed else Loc.t(why))
		game.hud.toast(line, false)
		Sfx.announce(fac, "no_supply", 5.0)


## Blocked now: a refusal in the last 8 s and the supply still full. The block ends (and may be said again) once
## there is room for another unit.
func blocked() -> bool:
	var t := game.human
	if t < 0 or game.demo:
		return false
	var room: int = int(game.players[t]["cap"]) - game.supply_used(t)
	if room >= 2 or game.clock - block_clock > 30.0:
		_block_said = false
	return game.clock - block_clock < 8.0 and room < 2


# ------------------------------------------------------------------ glows

## [IDLE glows, ARMY glows, MAKE glows] for the human (worked out at most once a game tick).
func glows(idle_n: int) -> Array:
	var f := Engine.get_physics_frames()
	if int(_glow_memo[0]) == f:
		return _glow_memo[1]
	var t := game.human
	var fight := false
	if t >= 0 and not game.demo:
		for u in game.units:
			if u.team != t or u.dead or u.is_worker() or u.kind == "horse":
				continue
			if game.clock - u.hit_clock < FIGHT_S or game.clock - u.fired_t < FIGHT_S or (is_instance_valid(u.target) and not u.target.dead and game.hostile(u.target.team, t) and u.position.distance_to(u.target.position) < 9.0 * Defs.TILE):
				fight = true
				break
	var make := false
	if t >= 0 and not game.demo and game.hud and game.hud.bar:
		var pb: Array = game.hud.bar.production_buildings()
		if not pb.is_empty() and game.clock > 20.0:
			make = true
			for b in pb:
				if b is Building:
					if not (b as Building).queue.is_empty():
						make = false
						break
				elif b is Unit:
					# the Brood: her eggs laid (or a research) = busy; eggs ready and nothing growing = idle
					var q := b as Unit
					if int(q.nb.get("eggs", 0)) < 1 or BroodResearch.busy(q):
						make = false
						break
	var out := [idle_n > 0 and t >= 0 and not game.demo, fight, make]
	_glow_memo = [f, out]
	return out
