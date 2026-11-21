extends SceneTree
## THE MOTHER GETS UP (brood-mother-uproot, docs/brood_mother_uproot.md; the owner 2026-11-21 15:43):
##  [linger]   the Brood Mother uproots: her swamp LINGERS (BroodNew.LINGER s) where she was; the Rootmaw on it stays
##             rooted and WAITS (no food, "waiting", its card WAITING: THE MOTHER IS UP; hers HER SWAMP LINGERS);
##  [back]     she roots again on it: her own swamp takes over, the linger ends, the Rootmaw feeds again;
##  [gone]     up past the linger: the swamp recedes and the Rootmaw uproots as before (it keeps its spot, nb "home");
##  [auto]     she roots again: when the swamp is back under its spot the Rootmaw roots there again BY ITSELF;
##  [order]    an order given to an uprooted Rootmaw meanwhile: it does not root back by itself;
##  [off]      `broodlinger:off` (BroodNew.linger_on false): as before (the Rootmaw uproots within seconds).
##   godot --headless --fixed-fps 30 --script res://tools/test_brood_mother_uproot.gd
var main: Node
var g: Game
var fails := 0


func check(ok: bool, name: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + name)
	if not ok:
		fails += 1


func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func wait(sec: float) -> void:
	var end: float = g.clock + sec
	var n := 0
	while g.clock < end and n < int(sec * 60) + 300:
		await physics_frame
		n += 1


func wait_for(f: Callable, sec: float) -> bool:
	var end: float = g.clock + sec
	var n := 0
	while g.clock < end and n < int(sec * 60) + 300:
		if f.call():
			return true
		await physics_frame
		n += 1
	return f.call()


func the_maw() -> Unit:
	for u in g.units:
		if u.team == 0 and u.kind == BroodNew.MAW and not u.dead:
			return u
	return null


func _run() -> void:
	await process_frame
	main.start({"map": "hollowfen", "seed": 4242, "slots": [
		{"who": "you", "faction": "brood", "colour": 0, "side": 0},
		{"who": "you", "faction": "clockwork", "colour": 1, "side": 1}]})
	await process_frame
	await process_frame
	g = main.game
	paused = false
	for a in g.ais:
		a.set_process(false)
	BroodNew.linger_on = true
	BroodNew.LINGER = 20.0
	var q: Unit = BroodNew.queen(g, 0)
	var m := the_maw()
	await wait(4.0)
	check(m != null and BroodNew.rooted(m) and BroodNew.rooted(q), "the start: the Mother and a Rootmaw rooted")
	var home := m.position
	# ---- [linger]
	q.cmd_uproot(false)
	await wait(q.switch_time() + 2.0)
	check(q.tesla_mode == "packed", "the Mother is up")
	check(BroodNew.linger_left(g, q) > 10.0, "[linger] her swamp lingers (%.1f s left)" % BroodNew.linger_left(g, q))
	check(BroodNew.maw_on_swamp(g, 0, m.position), "[linger] the swamp is still under the Rootmaw")
	await wait(1.0)
	var f0 := BroodNew.ground_left(g, m)
	await wait(4.0)
	check(BroodNew.rooted(m), "[linger] the Rootmaw stays rooted")
	check(m.nb.has("wait"), "[linger] it waits")
	check(absf(BroodNew.ground_left(g, m) - f0) < 0.01, "[linger] it drinks nothing from its ground meanwhile (%.2f -> %.2f)" % [f0, BroodNew.ground_left(g, m)])
	check(String(BroodNew.progress(g, m).get("label", "")) == "WAITING: THE MOTHER IS UP", "[linger] its card: WAITING: THE MOTHER IS UP")
	check(String(BroodNew.progress(g, q).get("label", "")) == "HER SWAMP LINGERS", "[linger] hers: HER SWAMP LINGERS")
	check(BroodNew.linger_fade(Vector2(m.position / Defs.TILE), BroodNew.linger_sources(g, 0), BroodNew.swamp_sources(g, 0)) < 1.0, "[linger] its swamp is drawn fading")
	# ---- [back]
	q.cmd_deploy()
	var back := await wait_for(func() -> bool: return BroodNew.rooted(q) and not q.nb.has("lgu") and not m.nb.has("wait"), q.switch_time() + 12.0)
	check(back, "[back] rooted again on it: the linger ends, the Rootmaw no longer waits")
	f0 = BroodNew.ground_left(g, m)
	await wait(3.0)
	check(BroodNew.ground_left(g, m) < f0 - 0.1 or float(m.nb.get("food", 0.0)) >= float(Defs.NB["maw_cap"]) - 0.5, "[back] it drinks again (ground %.1f -> %.1f)" % [f0, BroodNew.ground_left(g, m)])
	# ---- [gone]
	q.cmd_uproot(false)
	await wait(q.switch_time() + 1.0)
	var qhome := q.position
	q.cmd_move(q.position + Vector2(0, 7) * Defs.TILE)      # (she walks off: she will root again where she was)
	var gone := await wait_for(func() -> bool: return m.tesla_mode == "packed", BroodNew.LINGER + 30.0)
	check(gone, "[gone] past the linger the swamp recedes: the Rootmaw uproots")
	check(m.nb.has("home"), "[gone] it keeps its spot")
	await wait(2.0)
	check(m.tesla_mode == "packed", "[gone] it stays up while there is no swamp")
	# ---- [auto]
	q.cmd_move(qhome)
	await wait_for(func() -> bool: return q.position.distance_to(qhome) < 6.0 or q.order == "idle", 20.0)
	q.cmd_deploy()
	var auto := await wait_for(func() -> bool: return BroodNew.rooted(m), q.switch_time() + 40.0)
	check(auto, "[auto] she roots again: the Rootmaw roots again by itself")
	check(m.position.distance_to(home) < 2.0, "[auto] on its own spot (%.1f px off)" % m.position.distance_to(home))
	# ---- [order]
	q.cmd_uproot(false)
	await wait_for(func() -> bool: return m.tesla_mode == "packed", q.switch_time() + BroodNew.LINGER + 30.0)
	await wait(1.0)
	m.cmd_move(m.position + Vector2(3, 0) * Defs.TILE)
	await wait(3.0)
	check(not m.nb.has("home"), "[order] moved by the player: it no longer roots back by itself")
	m.cmd_move(home)
	await wait(4.0)
	# ---- [off]
	BroodNew.linger_on = false
	q.cmd_move(qhome)
	await wait(5.0)
	q.cmd_deploy()
	await wait_for(func() -> bool: return BroodRoot.fixed(q) and float(q.nb.get("swr", 0.0)) >= BroodNew.swamp_full(q) - 0.01, 40.0)
	m.cmd_deploy()
	await wait_for(func() -> bool: return BroodNew.rooted(m), 20.0)
	check(BroodNew.rooted(m), "[off] the Rootmaw rooted again by hand")
	q.cmd_uproot(false)
	var t0 := g.clock
	var off_up := await wait_for(func() -> bool: return m.tesla_mode != "deployed", q.switch_time() + 25.0)
	check(off_up and not q.nb.has("lgu"), "[off] no linger: the Rootmaw uproots %.0f s after she got up" % (g.clock - t0))
	check(not m.nb.has("home"), "[off] and does not keep a spot to root back on")
	BroodNew.linger_on = true
	BroodNew.LINGER = 45.0
	main._to_menu()
	print("ALL OK" if fails == 0 else "SOME FAILED (%d)" % fails)
	quit(1 if fails else 0)
