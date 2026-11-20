extends SceneTree
## THE CROWN COMPUTER AGAINST THE CLOCKWORK (crown-1000-clockwork, docs/crown_1000_clockwork.md; scripts/ai_crown_v_clock.gd
## AICrownVClock): the kept changes' rules, and their gate.
##   [kept]   pick, hall2, tech3 and dry are on by default; the others are off; `cvc:off` would turn all off
##   [gate]   they play only for a Crown computer whose enemy is the Clockwork (not against the Brood, nor the mirror)
##   [pick]   OPTIMAL's NORMAL / GREEDY pick against the Clockwork is Timing or Siege
##   [hall2]  after the pick the second hall is the build order's next step, at 11 labourers
##   [tech3]  the Church and the Armoury wait for the third hall; a Barracks does not
##   [dry]    no powder and 400+ gold: Musketeers with the bayonet and Field Cannons; not with less gold or with powder
##   godot --headless --fixed-fps 30 --script res://tools/test_crown_v_clock.gd
const U := preload("res://tools/gear_test_util.gd")
var fails := 0


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-70s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func _ai(g: Game, t: int) -> AICrown:
	var ai := AICrown.new()
	ai.game = g
	ai.team = t
	ai.difficulty = 2
	g.add_child(ai)
	ai.set_process(false)
	ai.set_physics_process(false)
	return ai


func _run() -> void:
	# [kept]
	for k in ["pick", "hall2", "tech3", "dry"]:
		check("[kept] %s on by default" % k, AICrownVClock.on(k))
	for k in ["foundry2", "spend", "trade", "richlabs"]:
		check("[kept] %s off by default" % k, not AICrownVClock.on(k))
	check("[pick] Timing or Siege", AICrownVClock.pick_w().keys().all(func(k) -> bool: return k in ["timing", "siege"]))

	var g := U.make(root, ["crown", "clockwork"], "greenhold")
	U.step(g, 0.5)
	var ai := _ai(g, 0)
	check("[gate] a Crown against the Clockwork", AICrownVClock.vs(ai))
	# [cut] (crown-rule-cleanup: the rules AICrownRules.CUT turns off against the Clockwork)
	for r in ["crownarmy", "armyfloor", "gunscoach", "gunsfirst", "line", "screen", "cavmicro", "defence"]:
		check("[cut] %s cut against the Clockwork" % r, AICrownRules.cut(ai, r))
	check("[cut] the hold kept against the Clockwork", not AICrownRules.cut(ai, "hold"))
	# [hall2]
	ai._bo_plan = [{"do": "build", "k": "foundry", "at": {"labs": 13}}, {"do": "army", "k": "musketeer", "cap": 8},
		{"do": "hall", "n": 2, "at": {"labs": 17}}]
	ai.bo_i = 0
	AICrownVClock.hall2_first(ai)
	var st: Dictionary = ai._bo_plan[0]
	check("[hall2] the hall step is next", String(st["do"]) == "hall" and int(st["at"]["labs"]) == AICrownVClock.HALL2_LABS, str(st))
	check("[hall2] no step lost", ai._bo_plan.size() == 3)
	# [tech3]
	check("[tech3] a Church waits on two halls", AICrownVClock.tech_waits(ai, "church", 2))
	check("[tech3] an Armoury waits on two halls", AICrownVClock.tech_waits(ai, "armoury", 2))
	check("[tech3] not on three halls", not AICrownVClock.tech_waits(ai, "church", 3))
	check("[tech3] a Barracks never waits", not AICrownVClock.tech_waits(ai, "barracks", 1))
	# [dry]
	g.players[0]["res2"] = 0.0
	g.players[0]["gold"] = 500
	check("[dry] no powder, 500 gold: a bayonet Musketeer", AICrownVClock.dry_musket(ai))
	check("[dry] ... and the guns", AICrownVClock.dry_guns(ai))
	g.players[0]["gold"] = 300
	check("[dry] no powder, 300 gold: no", not AICrownVClock.dry_musket(ai))
	g.players[0]["gold"] = 900
	g.players[0]["res2"] = 200.0
	check("[dry] powder in the bank: no", not AICrownVClock.dry_musket(ai))
	g.queue_free()

	for foe in ["brood", "crown"]:
		var g2 := U.make(root, ["crown", foe], "greenhold")
		U.step(g2, 0.5)
		var a2 := _ai(g2, 0)
		check("[gate] not against the %s" % foe, not AICrownVClock.vs(a2))
		check("[cut] the army clock not cut against the %s" % foe, not AICrownRules.cut(a2, "crownarmy"))
		check("[cut] the line not cut against the %s" % foe, not AICrownRules.cut(a2, "line"))
		g2.players[0]["res2"] = 0.0
		g2.players[0]["gold"] = 900
		check("[gate] no bayonet rule against the %s" % foe, not AICrownVClock.dry_musket(a2))
		check("[gate] no tech hold against the %s" % foe, not AICrownVClock.tech_waits(a2, "church", 2))
		a2._bo_plan = [{"do": "build", "k": "foundry"}, {"do": "hall", "n": 2}]
		a2.bo_i = 0
		AICrownVClock.hall2_first(a2)
		check("[gate] the build order untouched against the %s" % foe, String(a2._bo_plan[0]["do"]) == "build")
		g2.queue_free()

	print("test_crown_v_clock: %s (%d failed)" % ["ALL PASS" if fails == 0 else "FAILED", fails])
	quit(1 if fails > 0 else 0)
