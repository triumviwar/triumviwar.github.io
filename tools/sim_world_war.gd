extends SceneTree
## THE WORLD WAR mode's simulation (docs/world_war_mode.md): computers against computers, every battle auto-resolved.
## For each war: who won, in which season, and every side's regions every 8 seasons (does one side run away?).
##   godot --headless --script res://tools/sim_world_war.gd -- wars=20 level=normal win=capitals limit=80
var args := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var p := String(a).split("=")
		if p.size() == 2:
			args[p[0]] = p[1]
	var wars := int(args.get("wars", "20"))
	var lvl := String(args.get("level", "normal"))
	var limit := int(args.get("limit", "80"))
	var wins := {}
	var ends: Array = []
	var peak := {}
	var endr := {}
	for i in wars:
		var levels := {"crown": lvl, "clockwork": lvl, "brood": lvl}
		if args.has("crown"):
			levels["crown"] = args["crown"]
		if args.has("off"):
			levels[String(args["off"])] = "off"
		var w := WWWar.make({"players": levels, "win": String(args.get("win", "capitals")), "seed": 1000 + i, "heroes": args.get("heroes", "1") == "1",
			"seasons": int(args.get("seasons", "40"))})
		var line := "war %2d:" % i
		var guard := 0
		while String(w.d["winner"]) == "" and int(w.d["season"]) < limit and guard < 5000:
			guard += 1
			var s0 := int(w.d["season"])
			var al := (w.d["order"] as Array).filter(func(f) -> bool: return w.alive(f)).size()
			WWAI.play_turn(w)
			w.end_turn()
			if args.has("falls") and (w.d["order"] as Array).filter(func(f) -> bool: return w.alive(f)).size() != al:
				for e in (w.d["log"] as Array).slice(-6):
					var t := WWWar.line_text(e["line"])
					if t.contains("fallen") or t.contains("Queen is dead"):
						print("     s%d %s" % [int(e["s"]), t])
			if int(w.d["season"]) != s0 and int(w.d["season"]) % 8 == 0:
				line += "  s%d " % int(w.d["season"])
				for f in WWRules.FACTIONS:
					var n := w.regions_of(f).size()
					var av := 0
					for a in w.armies_of(f):
						av += w.army_value(a)
					line += "%s%d/%d/%dk/%d " % [f.substr(0, 2), n, w.gold(f) if w.alive(f) else 0, av / 1000, w.armies_of(f).size()]
					peak[f] = maxi(int(peak.get(f, 0)), n)
		var win := String(w.d["winner"])
		if win == "":
			win = "none_by_%d" % limit
		wins[win] = int(wins.get(win, 0)) + 1
		ends.append(int(w.d["season"]))
		if args.has("lands"):
			for f in WWRules.FACTIONS:
				print("    ", f, " ", w.regions_of(f))
		for f in WWRules.FACTIONS:
			endr[f] = int(endr.get(f, 0)) + w.regions_of(f).size()
		print(line, "  -> ", win, " at season ", int(w.d["season"]))

	ends.sort()
	print("WINS ", wins, "  median end season ", ends[ends.size() / 2], "  peak regions ", peak, "  regions at the end (sum) ", endr)
	quit()
