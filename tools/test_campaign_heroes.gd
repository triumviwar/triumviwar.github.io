extends SceneTree
## campaign-fixes-1121 (docs/campaign_fixes_1121.md): THE STORY'S MUST-LIVE PEOPLE ARE WOUNDED, NOT KILLED
## (scripts/campaign/mission_heroes.gd). In the Prologue Lord Fairleigh and Father Tomasz can't be killed: a deadly blow
## leaves them wounded (untouchable, falling back), they heal and come back; they are not in ARMY (F2); Tomasz tends only
## the wounded close by. Played as the Nest (a03's mirror) Valadares is the prey: not protected, he dies.
##   godot --headless --fixed-fps 30 --script res://tools/test_campaign_heroes.gd
## Also the MIRRORS by the campaign's difficulty: a03's escort when the Nest is played, a05's hired guns when the creatures
## are, b01's rival pack (its cap, its computer's level).
## Prints CHECK lines, then "campaign_heroes: N failures". (Leaves user://campaign.json as it was.)
var main: Node
var fails := 0
var _kept := ""


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-66s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://running.txt"))
	if FileAccess.file_exists(Campaign.PROGRESS):
		_kept = FileAccess.get_file_as_string(Campaign.PROGRESS)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _start(mid: String, mode: String, side := "") -> Game:
	if main.game:
		main._to_menu()
		await process_frame
	var cfg: Dictionary = Campaign.make_cfg(mid, mode, "p1", false, side) if side != "" else Campaign.make_cfg(mid, mode, "p1")
	main.start(cfg)
	await process_frame
	await process_frame
	paused = false
	return main.game


func _ticks(g: Game, secs: float) -> void:
	var r: MissionRun = g.mission
	var n := int(secs / MissionRun.TICK)
	for i in n:
		g.clock += MissionRun.TICK
		r.heroes.tick(MissionRun.TICK)


func _run() -> void:
	await process_frame
	var g := await _start("p01_leaf", "solo")
	var r: MissionRun = g.mission
	await physics_frame
	for i in 12:
		await physics_frame
	if r.heroes == null:
		r.heroes = MissionHeroes.new(r)      # (the run's tick makes it; here the test steps it by hand)
	r.heroes.tick(1.0)
	check("the heroes are found (Fairleigh, Tomasz)", r.heroes != null and r.heroes.heroes.size() == 2, str(r.heroes.heroes.size() if r.heroes else -1))
	r.heroes.tick(1.0)
	var fl: Unit = r.tagged("fairleigh")[0]
	var tz: Unit = r.tagged("tomasz")[0]
	check("they carry the hero mark", fl.has_meta("story_hero") and tz.has_meta("story_hero"))
	fl.take_damage(1e6, null)
	check("a deadly blow leaves Fairleigh alive", not fl.dead and fl.hp > 0.0, str(fl.hp))
	_ticks(g, 0.5)
	check("...and WOUNDED: untouchable, falling back", fl.has_meta("mission_wounded") and fl.spared and r.heroes.wounds == 1)
	var hp0 := fl.hp
	fl.take_damage(500.0, null)
	check("nothing hurts him while wounded", fl.hp == hp0)
	_ticks(g, 50.0)
	check("he heals and comes back to the fight", not fl.has_meta("mission_wounded") and not fl.spared and fl.hp >= fl.max_hp * 0.6, str(fl.hp))
	var ua := g.army(g.human)
	var hb: HotkeyBar = g.hud.bar if g.hud else null
	if hb:
		hb.select_army()
		check("ARMY (F2) leaves the heroes out", not g.selection.has(fl) and not g.selection.has(tz) and not g.selection.is_empty(), str(g.selection.size()))
	else:
		check("ARMY (F2) leaves the heroes out (hotkey bar found)", false)
	check("(the army has them for the computer's own counts)", ua.has(fl))
	# ---------------------------------------------------------------- the Nest (a03's mirror): Valadares is the prey
	g = await _start("a03_plateau", "solo", "nest")
	r = g.mission
	for i in 12:
		await physics_frame
	if r.heroes == null:
		r.heroes = MissionHeroes.new(r)
	r.heroes.tick(1.0)
	var va: Array = r.tagged("valadares")
	check("played as the Nest, Valadares is not protected", not va.is_empty() and not va[0].has_meta("story_hero"))
	if not va.is_empty():
		va[0].take_damage(1e6, null)
		check("...a deadly blow kills him", va[0].dead)
	g = await _start("a03_plateau", "solo", "party")
	r = g.mission
	for i in 12:
		await physics_frame
	if r.heroes == null:
		r.heroes = MissionHeroes.new(r)
	r.heroes.tick(1.0)
	va = r.tagged("valadares")
	check("played as the party, Valadares is protected", not va.is_empty() and va[0].has_meta("story_hero"))
	check("(played as the party: no mirror escort)", r.tagged("escort").is_empty())
	# ---------------------------------------------------------------- THE MIRRORS BY THE DIFFICULTY (campaign-fixes-1121)
	for d in [["easy", 2, 5, 28, "easy"], ["normal", 6, 10, 36, "easy"], ["hard", 12, 15, 50, "normal"]]:
		Campaign.set_difficulty(String(d[0]))
		var cfg := Campaign.make_cfg("b01_specimen", "solo")
		check("b01 %s: the rival pack's computer plays %s" % [d[0], d[4]], String(cfg["slots"][1]["who"]) == String(d[4]), String(cfg["slots"][1]["who"]))
		g = await _start("a03_plateau", "solo", "nest")
		r = g.mission
		check("a03 %s, the Nest played: the party's escort is %d" % [d[0], d[1]], r.tagged("escort").size() == int(d[1]), str(r.tagged("escort").size()))
		g = await _start("a05_specimens", "solo", "creatures")
		r = g.mission
		var base := 0
		for u in r.tagged("guns"):
			base += 1
		check("a05 %s, the creatures played: %d hired guns (the six scaled, and the mirror's own)" % [d[0], d[2]], base == int(d[2]), str(base))
		g = await _start("b01_specimen", "solo")
		r = g.mission
		check("b01 %s: the rival pack's cap is %d" % [d[0], d[3]], r.supply_cap_of(r.team_index("rival")) == int(d[3]) and g.max_supply(r.team_index("rival")) == int(d[3]))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Campaign.PROGRESS))
	if _kept != "":
		var f := FileAccess.open(Campaign.PROGRESS, FileAccess.WRITE)
		f.store_string(_kept)
		f.close()
	print("campaign_heroes: %d failures" % fails)
	quit(1 if fails > 0 else 0)
