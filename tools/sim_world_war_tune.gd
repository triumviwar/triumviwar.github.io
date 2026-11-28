extends SceneTree
## THE WORLD WAR's tuning simulation (docs/world_war_tune.md): many computer wars on fixed seeds, every battle
## auto-resolved, summed up in one line a block (who won, how, when, how much land was left free).
##   godot --headless --script res://tools/sim_world_war_tune.gd -- wars=100 sides=crown,clockwork,brood limit=48
##   [level=normal] [win=capitals] [seasons=48] [seed=1000] [tune=off|<switch>:off,...] [csv=path]
## limit = when the simulation stops (the war's own last season is "seasons"; seasons=0 = no last season).
## HOW a war ended: "conquest" (one side left), "keys", "land" (the most land at the last season), "none" (still on).
var args := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var p := String(a).split("=")
		if p.size() == 2:
			args[p[0]] = p[1]
	var wars := int(args.get("wars", "100"))
	var lvl := String(args.get("level", "normal"))
	var sides: Array = String(args.get("sides", "crown,clockwork,brood")).split(",")
	var seasons := int(args.get("seasons", "48"))
	var limit := int(args.get("limit", str(seasons if seasons > 0 else 80)))
	var seed0 := int(args.get("seed", "1000"))
	var tune := String(args.get("tune", ""))
	var wins := {}
	var how := {}
	var falls := 0
	var ends: Array = []
	var free_n := 0
	var free_w := 0
	var peak := 0
	var lead_share := 0.0
	var held := {}
	var freec := {}
	var fellby := {}
	var ownc := {}
	var ways := {}
	for i in wars:
		var players := {}
		for f in WWRules.FACTIONS:
			players[f] = lvl if sides.has(f) else "off"
		var setup := {"players": players, "win": String(args.get("win", "capitals")), "seed": seed0 + i,
			"heroes": args.get("heroes", "1") == "1", "seasons": seasons, "name": "sim"}
		if tune.begins_with("v1"):
			setup["rv"] = 1
			setup["tune"] = tune.substr(3)
		elif tune != "":
			setup["tune"] = tune
		var w := WWWar.make(setup)
		var guard := 0
		var alive0 := sides.size()
		while String(w.d["winner"]) == "" and int(w.d["season"]) < limit and guard < 8000:
			guard += 1
			WWAI.play_turn(w)
			w.end_turn()
			for f in w.d["order"]:
				peak = maxi(peak, w.regions_of(f).size())
		var alive1 := (w.d["order"] as Array).filter(func(f) -> bool: return w.alive(f)).size()
		falls += alive0 - alive1
		for f in w.d["order"]:
			if not w.alive(f):
				fellby[f] = int(fellby.get(f, 0)) + 1
		for f in w.d.get("ways_out", {}):
			for k in w.d["ways_out"][f]:
				ways[k] = int(ways.get(k, 0)) + int(w.d["ways_out"][f][k])
		var win := String(w.d["winner"])
		var kind := "none"
		if win != "":
			if alive1 <= 1:
				kind = "conquest"
			elif String(w.d["win"]) == "keys" and w.key_count(win) >= int(w.d["keys"]):
				kind = "keys"
			else:
				kind = "land"
		else:
			win = "none"
		wins[win] = int(wins.get(win, 0)) + 1
		how[kind] = int(how.get(kind, 0)) + 1
		ends.append(int(w.d["season"]))
		var total := 0
		var top := 0
		for f in w.d["order"]:
			var lw := w.land_worth(f) if w.alive(f) else 0
			total += lw
			top = maxi(top, lw)
			held[f] = int(held.get(f, 0)) + (w.regions_of(f).size() if w.alive(f) else 0)
		for rid in w.d["regions"]:
			if w.owner(rid) != "":
				ownc[w.owner(rid) + ":" + rid] = int(ownc.get(w.owner(rid) + ":" + rid, 0)) + 1
			if w.owner(rid) == "":
				freec[rid] = int(freec.get(rid, 0)) + 1
				free_n += 1
				free_w += WWRules.worth(rid)
		lead_share += float(top) / maxf(1.0, float(total))
		if args.has("each"):
			print("war %3d -> %s (%s) s%d" % [i, win, kind, int(w.d["season"])])
	ends.sort()
	var hl := {}
	for f in held:
		hl[f] = snappedf(float(held[f]) / wars, 0.1)
	var line := "SUMMARY sides=%s tune=%s wars=%d seasons=%d limit=%d | wins %s | how %s | capitals fell %d %s | median end s%d | free regions %.1f (worth %.1f) | regions held %s | peak %d | leader share of held land %.2f | ways out a war: retreats %.1f, called off %.1f" % [
		",".join(sides), tune if tune != "" else "-", wars, seasons, limit, wins, how, falls, fellby, ends[ends.size() / 2],
		float(free_n) / wars, float(free_w) / wars, hl, peak, lead_share / wars,
		float(ways.get("retreat", 0)) / wars, float(ways.get("call_off", 0)) / wars]
	print(line)
	if args.has("ownlist"):
		for f in WWRules.FACTIONS:
			var ks: Array = ownc.keys().filter(func(k) -> bool: return String(k).begins_with(f + ":"))
			ks.sort_custom(func(a, b) -> bool: return int(ownc[a]) > int(ownc[b]))
			if not ks.is_empty():
				print("HELD BY %s: " % f, ", ".join(ks.map(func(k) -> String: return "%s %d" % [String(k).split(":")[1], int(ownc[k])])))
	if args.has("freelist"):
		var ks: Array = freec.keys()
		ks.sort_custom(func(a, b) -> bool: return int(freec[a]) > int(freec[b]))
		print("FREE AT THE END (wars of %d): " % wars, ", ".join(ks.map(func(k) -> String: return "%s %d" % [k, int(freec[k])])))
	if args.has("csv"):
		var fa := FileAccess.open(String(args["csv"]), FileAccess.READ_WRITE if FileAccess.file_exists(String(args["csv"])) else FileAccess.WRITE)
		fa.seek_end()
		fa.store_line(line)
	quit()
