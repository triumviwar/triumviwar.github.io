class_name WWWar
extends RefCounted
## ONE WORLD WAR (docs/world_war_mode.md): who holds which region, the armies, the treasuries, whose turn and season,
## and every rule that changes them (WWRules has the numbers). Nothing here draws or waits: the page (WWPage) shows
## it and asks, the computers (WWAI) give orders through the same calls a player does. Saved as plain JSON (d).

const DIR := "user://worldwar"

var d := {}                        # the whole war (saved as is)
var rng := RandomNumberGenerator.new()
var _hops := {}                    # faction -> {region: steps from its capital} (worked out once a war)


# ------------------------------------------------------------------ a new war, saving, loading

## setup = {"players": {faction: "you" | "easy" | "normal" | "hard" | "off"}, "win": kind, "heroes": bool, "seed": n,
## "keys": n, "seasons": n}. A side "off" is not in the war (its lands are free).
static func make(setup: Dictionary) -> WWWar:
	var w := WWWar.new()
	var seed := int(setup.get("seed", randi()))
	w.rng.seed = seed
	var players: Dictionary = setup.get("players", {"crown": "you", "clockwork": "normal", "brood": "normal"})
	var order: Array = WWRules.FACTIONS.filter(func(f: String) -> bool: return String(players.get(f, "off")) != "off")
	w.d = {"v": 1, "seed": seed, "season": 0, "order": order, "turn": 0, "next_id": 1, "winner": "", "log": [],
		"win": String(setup.get("win", "capitals")), "keys": int(setup.get("keys", WWRules.KEYS_NEEDED)),
		"seasons": int(setup.get("seasons", WWRules.SEASON_LIMIT)), "heroes_on": bool(setup.get("heroes", true)),
		"storms": -1, "event": "", "factions": {}, "regions": {}, "armies": {}, "heroes": {}, "name": String(setup.get("name", ""))}
	for r in WWRules.region_list():
		var id := String(r["id"])
		d_region(w, id)
	for f in order:
		w.d["factions"][f] = {"who": String(players[f]), "gold": WWRules.START_GOLD, "capital": WWRules.CAPITAL[f],
			"out": false, "income_last": 0, "upkeep_last": 0}
		for rid in WWRules.START[f]:
			w.d["regions"][rid]["owner"] = f
			w.d["regions"][rid]["unrest"] = 0.0
		var a := w.new_army(f, WWRules.CAPITAL[f], WWRules.START_ARMY[f].duplicate())
		if w.d["heroes_on"]:
			for h in WWRules.HEROES.get(f, []):
				w.d["heroes"][String(h["id"])] = {"f": f, "army": String(a["id"]), "back": 0}
	if w.d["name"] == "":
		w.d["name"] = "war_%d" % (Time.get_unix_time_from_system() as int)
	w.log_line(["The war begins: %s.", WWRules.season_name(0)])
	w.begin_turn()
	return w


static func d_region(w: WWWar, id: String) -> void:
	w.d["regions"][id] = {"owner": "", "build": "", "unrest": 0.0, "guard": WWRules.worth(id) * WWRules.FREE_GUARD + WWRules.FREE_GUARD_BASE}


static func path_of(name: String) -> String:
	return DIR + "/" + name + ".json"


func save(path := "") -> bool:
	if path == "":
		path = path_of(String(d["name"]))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))
	d["rng"] = rng.state
	d["saved"] = Time.get_unix_time_from_system()
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(d))
	return true


static func load_from(path: String) -> WWWar:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var v: Variant = JSON.parse_string(f.get_as_text())
	if not (v is Dictionary) or not (v as Dictionary).has("regions"):
		return null
	return from_dict(v)


static func from_dict(v: Dictionary) -> WWWar:
	var w := WWWar.new()
	w.d = v
	# (JSON gives every number back as a float: the counts are whole again)
	for a in w.d["armies"].values():
		for k in a["units"]:
			a["units"][k] = int(a["units"][k])
		a["vet"] = int(a.get("vet", 0))
		a["peak"] = int(a.get("peak", 0))
	for k in ["season", "turn", "next_id", "storms", "keys", "seasons", "seed"]:
		w.d[k] = int(w.d.get(k, 0))
	for fd in w.d["factions"].values():
		fd["gold"] = int(fd["gold"])
	for r in w.d["regions"].values():
		r["guard"] = int(r.get("guard", 0))
	w.rng.seed = int(w.d.get("seed", 0))
	if w.d.has("rng"):
		w.rng.state = int(w.d["rng"])
	return w


## Every saved war, newest first: [{"name", "path", "season", "order", "saved", "winner"}].
static func saved_wars() -> Array:
	var out: Array = []
	var da := DirAccess.open(DIR)
	if da == null:
		return out
	for fn in da.get_files():
		if not fn.ends_with(".json"):
			continue
		var w := load_from(DIR + "/" + fn)
		if w == null:
			continue
		out.append({"name": fn.get_basename(), "path": DIR + "/" + fn, "season": int(w.d["season"]), "order": w.d["order"],
			"saved": float(w.d.get("saved", 0)), "winner": String(w.d.get("winner", "")), "players": w.players()})
	out.sort_custom(func(a, b) -> bool: return float(a["saved"]) > float(b["saved"]))
	return out


static func delete_war(name: String) -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path_of(name)))


# ------------------------------------------------------------------ reading the war

func current() -> String:
	return String(d["order"][int(d["turn"])])


func who(f: String) -> String:
	return String(d["factions"].get(f, {}).get("who", "off"))


func is_human(f: String) -> bool:
	return who(f) == "you"


func players() -> Dictionary:
	var out := {}
	for f in d["order"]:
		out[f] = who(f)
	return out


func alive(f: String) -> bool:
	return d["factions"].has(f) and not bool(d["factions"][f]["out"])


func owner(rid: String) -> String:
	return String(d["regions"][rid]["owner"])


func gold(f: String) -> int:
	return int(d["factions"][f]["gold"])


func capital(f: String) -> String:
	return String(d["factions"][f]["capital"])


func regions_of(f: String) -> Array:
	var out: Array = []
	for rid in d["regions"]:
		if owner(rid) == f:
			out.append(rid)
	return out


func armies_at(rid: String, f := "") -> Array:
	var out: Array = []
	for a in d["armies"].values():
		if String(a["at"]) == rid and (f == "" or String(a["f"]) == f):
			out.append(a)
	return out


func armies_of(f: String) -> Array:
	return d["armies"].values().filter(func(a) -> bool: return String(a["f"]) == f)


func army(id: String) -> Dictionary:
	return d["armies"].get(id, {})


func heroes_with(aid: String) -> Array:
	var out: Array = []
	for hid in d["heroes"]:
		if String(d["heroes"][hid]["army"]) == aid:
			out.append(hid)
	return out


func has_hero(aid: String, hid: String) -> bool:
	return d["heroes"].has(hid) and String(d["heroes"][hid]["army"]) == aid


func army_value(a: Dictionary) -> int:
	return WWRules.units_value(a["units"])


## Steps (land or sea) from a side's capital to every region.
func hops(f: String) -> Dictionary:
	if not _hops.has(f):
		var dist := {WWRules.CAPITAL[f]: 0}
		var q: Array = [WWRules.CAPITAL[f]]
		while not q.is_empty():
			var r: String = q.pop_front()
			for n in WWRules.neighbours(r):
				if not dist.has(n):
					dist[n] = int(dist[r]) + 1
					q.append(n)
		_hops[f] = dist
	return _hops[f]


func is_muster(rid: String, f: String) -> bool:
	if owner(rid) != f:
		return false
	if rid == capital(f):
		return true
	return bool(WWRules.building(f, String(d["regions"][rid]["build"])).get("muster", false))


## The income a side would get now, before upkeep: [raw, bent (the total)].
func income(f: String) -> Array:
	var raw := 0.0
	for rid in regions_of(f):
		raw += region_income(rid, f)
	var bent := raw * WWRules.INCOME_K / (raw + WWRules.INCOME_K) if raw > 0 else 0.0
	return [int(raw), int(round(bent * float(WWRules.AI_INCOME.get(who(f), 1.0))))]


func region_income(rid: String, f: String) -> float:
	var b := WWRules.building(f, String(d["regions"][rid]["build"]))
	var bio := WWRules.biome(rid)
	var g := float(WWRules.worth(rid) * WWRules.WORTH_GOLD) * float(WWRules.BIOME_INCOME[f].get(bio, 1.0))
	var mult := 1.0 + float(b.get("income", 0.0))
	if bool(b.get("trade", false)):
		for n in WWRules.neighbours(rid):
			if owner(n) == f and String(d["regions"][n]["build"]) == String(b["id"]):
				mult += WWRules.TRADE_LINK
	return g * mult


func upkeep(f: String) -> int:
	var u := 0.0
	for a in armies_of(f):
		u += army_value(a) * (float(WWRules.UPKEEP_SIDE.get(f, WWRules.UPKEEP)) + WWRules.UPKEEP_VET * int(a["vet"]))
	var hp := hops(f)
	for rid in regions_of(f):
		u += WWRules.FAR_GOLD * maxi(0, int(hp.get(rid, 9)) - WWRules.FAR_HOPS)
	return int(round(u))


func biome_now(rid: String) -> String:
	return WWRules.biome(rid) if String(d["regions"][rid].get("build", "")) != "swamp" else "wet"


func key_count(f: String) -> int:
	var n := 0
	for rid in WWRules.key_regions():
		if owner(rid) == f:
			n += 1
	return n


func land_worth(f: String) -> int:
	var n := 0
	for rid in regions_of(f):
		n += WWRules.worth(rid)
	return n


# ------------------------------------------------------------------ the log (lines kept as [English template, args...])

func log_line(line: Array) -> void:
	(d["log"] as Array).append({"s": int(d.get("season", 0)), "line": line})
	while (d["log"] as Array).size() > 80:
		(d["log"] as Array).pop_front()


static func line_text(line: Array) -> String:
	var tpl := Loc.t(String(line[0]))
	var args: Array = []
	for i in range(1, line.size()):
		var a: Variant = line[i]
		args.append(Loc.t(a) if a is String else a)
	if args.is_empty():
		return tpl
	return tpl % args


func rname(rid: String) -> String:
	return String(WWRules.region(rid).get("name", rid))


func fname(f: String) -> String:
	return String(WWRules.NAME.get(f, f))


# ------------------------------------------------------------------ armies

func new_army(f: String, at: String, units: Dictionary) -> Dictionary:
	var id := "a%d" % int(d["next_id"])
	d["next_id"] = int(d["next_id"]) + 1
	var a := {"id": id, "f": f, "at": at, "units": units, "vet": 0, "moved": false, "peak": WWRules.units_value(units)}
	d["armies"][id] = a
	return a


func remove_army(id: String) -> void:
	for hid in heroes_with(id):
		d["heroes"][hid]["army"] = ""
		d["heroes"][hid]["back"] = int(d["season"]) + WWRules.HERO_BACK
		log_line(["%s is wounded and carried back to %s.", WWRules.hero(hid).get("name", hid), rname(capital(String(d["heroes"][hid]["f"])))])
	d["armies"].erase(id)


## Take a share of an army's units (rounded fairly by the war's dice); an army left with nothing is gone.
func lose(a: Dictionary, share: float) -> void:
	share = clampf(share, 0.0, 1.0)
	for k in a["units"].keys():
		var n := int(a["units"][k])
		var gone := n * share
		var whole := int(floor(gone))
		if rng.randf() < gone - whole:
			whole += 1
		a["units"][k] = maxi(0, n - whole)
		if int(a["units"][k]) == 0:
			a["units"].erase(k)
	if WWRules.units_count(a["units"]) == 0 and d["armies"].has(String(a["id"])):
		remove_army(String(a["id"]))


func grow(a: Dictionary, share: float) -> void:
	var room := int(a.get("peak", 0)) - army_value(a)
	if room <= 0:
		return
	var added := 0
	for k in a["units"].keys():
		var n := int(a["units"][k])
		var more := maxi(1, int(round(n * share))) if n > 0 else 0
		while more > 0 and added + int(WWRules.UNIT_VALUE[k]) <= room:
			a["units"][k] = int(a["units"][k]) + 1
			added += int(WWRules.UNIT_VALUE[k])
			more -= 1


func add_units(a: Dictionary, units: Dictionary) -> void:
	for k in units:
		a["units"][k] = int(a["units"].get(k, 0)) + int(units[k])
	a["peak"] = maxi(int(a.get("peak", 0)), army_value(a))


## Split an army in two (half of each kind goes to a new one in the same region; heroes stay).
func split(aid: String) -> Dictionary:
	var a := army(aid)
	if a.is_empty() or WWRules.units_count(a["units"]) < 2:
		return {}
	var half := {}
	for k in a["units"]:
		var n := int(a["units"][k]) / 2
		if n > 0:
			half[k] = n
	if half.is_empty():
		var k0: String = a["units"].keys()[0]
		half[k0] = 1
	for k in half:
		a["units"][k] = int(a["units"][k]) - int(half[k])
		if int(a["units"][k]) <= 0:
			a["units"].erase(k)
	var b := new_army(String(a["f"]), String(a["at"]), half)
	b["vet"] = a["vet"]
	b["moved"] = a["moved"]
	a["peak"] = army_value(a)
	return b


## Where an army may go this turn: [{"to", "sea"}] (its land and sea neighbours; none once it has moved).
func moves_for(aid: String) -> Array:
	var a := army(aid)
	if a.is_empty() or bool(a["moved"]) or String(a["f"]) != current():
		return []
	var out: Array = []
	for n in WWRules.land_nb(String(a["at"])):
		out.append({"to": n, "sea": false})
	for n in WWRules.sea_nb(String(a["at"])):
		out.append({"to": n, "sea": true})
	return out


## March (or sail) an army to a neighbouring region. Returns {"kind": "move" | "merge" | "taken" | "fought" | "battle"
## | "refused", "text", "battle": {...} (a battle waiting for the player to choose: fight it or auto-resolve), "result"}.
func move(aid: String, to: String) -> Dictionary:
	var a := army(aid)
	var ok := false
	var sea := false
	for m in moves_for(aid):
		if String(m["to"]) == to:
			ok = true
			sea = bool(m["sea"])
	if not ok:
		return {"kind": "refused", "text": "That army can't go there this turn."}
	var f := String(a["f"])
	var from := String(a["at"])
	a["moved"] = true
	if sea:
		var storm := WWRules.STORM * (3.0 if int(d["storms"]) == int(d["season"]) else 1.0)
		if not has_hero(aid, "valadares") and rng.randf() < storm:
			log_line(["A storm at sea: %s's army sailing to %s loses a fifth of its men.", fname(f), rname(to)])
			lose(a, WWRules.STORM_LOSS)
		if f == "clockwork" and not has_hero(aid, "hollweg") and d["armies"].has(aid):
			lose(a, WWRules.SEA_RUST)
		if not d["armies"].has(aid):
			return {"kind": "lost", "text": "The army was lost at sea."}
	var foes: Array = armies_at(to).filter(func(x) -> bool: return String(x["f"]) != f)
	var own := owner(to)
	if foes.is_empty() and (own == f or (own == "" and false)):
		# into its own land: join an army there if there is one (and room)
		var mates: Array = armies_at(to, f)
		a["at"] = to
		if not mates.is_empty():
			var m: Dictionary = mates[0]
			if WWRules.units_count(m["units"]) + WWRules.units_count(a["units"]) <= WWRules.ARMY_CAP:
				add_units(m, a["units"])
				m["vet"] = int(a["vet"]) if army_value(a) > army_value(m) else int(m["vet"])
				for hid in heroes_with(aid):
					d["heroes"][hid]["army"] = String(m["id"])
				d["armies"].erase(aid)
				return {"kind": "merge", "text": "The armies join.", "army": String(m["id"])}
		return {"kind": "move", "text": "", "army": aid}
	var b := {"att": aid, "region": to, "from": from, "sea": sea, "att_f": f,
		"def_f": String(foes[0]["f"]) if not foes.is_empty() else own,
		"defs": foes.map(func(x) -> String: return String(x["id"]))}
	if not foes.is_empty() and fight_offered(b):
		return {"kind": "battle", "battle": b, "text": ""}
	var res := resolve(b)
	return {"kind": "fought", "result": res, "text": String(res.get("text", "")), "battle": b}


## A battle the player may fight on the field: there is an army on both sides and exactly one side is a player's.
func fight_offered(b: Dictionary) -> bool:
	if (b.get("defs", []) as Array).is_empty():
		return false
	return is_human(String(b["att_f"])) != is_human(String(b["def_f"]))


## The strength each side brings to a battle: [attacker, defender] before the dice (and their parts for the card).
func strengths(b: Dictionary) -> Dictionary:
	var to := String(b["region"])
	var att := army(String(b["att"]))
	var af := String(b["att_f"])
	var df := String(b["def_f"])
	var bio := biome_now(to)
	var A := float(army_value(att)) * (1.0 + WWRules.VET_STEP * int(att.get("vet", 0)))
	if not heroes_with(String(att["id"])).is_empty():
		A *= WWRules.HERO_BONUS
	A *= float(WWRules.BIOME_FIGHT.get(af, {}).get(bio, 1.0))
	if has_hero(String(att["id"]), "valadares") and bio == "jungle":
		A *= 1.1 / float(WWRules.BIOME_FIGHT.get(af, {}).get(bio, 1.0))
	if has_hero(String(att["id"]), "ruggieri") and (String(d["regions"][to]["build"]) != "" or (df != "" and capital(df) == to)):
		A *= 1.15
	var D := 0.0
	var army_part := 0.0
	var hero_def := false
	var vet_def := 0
	for did in b.get("defs", []):
		var da := army(String(did))
		if da.is_empty():
			continue
		army_part += army_value(da)
		vet_def = maxi(vet_def, int(da.get("vet", 0)))
		if not heroes_with(String(did)).is_empty():
			hero_def = true
	var guard := 0.0
	var own := owner(to)
	if own == df:
		if own == "":
			guard = float(d["regions"][to]["guard"])
		else:
			guard = float(WWRules.worth(to) * WWRules.GUARD)
			guard += float(WWRules.building(own, String(d["regions"][to]["build"])).get("defence", 0))
			if capital(own) == to:
				guard += WWRules.CAPITAL_GUARD
	D = army_part * (1.0 + WWRules.VET_STEP * vet_def) * (WWRules.HERO_BONUS if hero_def else 1.0) + guard
	if df != "":
		D *= float(WWRules.BIOME_FIGHT.get(df, {}).get(bio, 1.0))
	D *= WWRules.DEFEND_CAPITAL if (own != "" and own == df and capital(own) == to) else WWRules.DEFEND
	return {"att": A, "def": D, "guard": guard, "army": army_part}


## Auto-resolve a battle now (and apply it). Returns {"won": attacker won, "text", "att_loss", "def_loss"}.
func resolve(b: Dictionary) -> Dictionary:
	var s := strengths(b)
	var A: float = float(s["att"]) * (1.0 + rng.randf_range(-WWRules.LUCK, WWRules.LUCK))
	var D: float = float(s["def"]) * (1.0 + rng.randf_range(-WWRules.LUCK, WWRules.LUCK))
	var won := A > D
	var hi := maxf(A, D)
	var lo := minf(A, D)
	var r := lo / maxf(hi, 1.0)
	var win_loss := 0.05 + 0.55 * r * r
	return apply_result(b, won, win_loss, WWRules.LOSER_LOSS)


## The battle's outcome on the map: the winner's losses (a share), the loser's (a share; it falls back if it can).
## (A fought battle passes the survivors instead: apply_fought.)
func apply_result(b: Dictionary, att_won: bool, win_loss: float, lose_loss: float) -> Dictionary:
	var att := army(String(b["att"]))
	var to := String(b["region"])
	var af := String(b["att_f"])
	var df := String(b["def_f"])
	var defs: Array = (b.get("defs", []) as Array).map(func(x) -> Dictionary: return army(String(x))).filter(func(x) -> bool: return not x.is_empty())
	if att_won:
		lose(att, win_loss)
		for da in defs:
			_beaten(da, lose_loss, to, af)
		if d["armies"].has(String(att["id"])):
			att["vet"] = mini(WWRules.VET_MAX, int(att["vet"]) + 1)
		var txt := ["%s wins at %s.", fname(af), rname(to)]
		if d["armies"].has(String(att["id"])):
			att["at"] = to
			_take(to, af)
		log_line(txt)
		return {"won": true, "text": WWWar.line_text(txt)}
	# the defender holds
	for da in defs:
		lose(da, win_loss)
		if d["armies"].has(String(da["id"])):
			da["vet"] = mini(WWRules.VET_MAX, int(da["vet"]) + 1)
	if df == "" and defs.is_empty():
		var g := int(d["regions"][to]["guard"])
		d["regions"][to]["guard"] = maxi(WWRules.FREE_GUARD_BASE, int(g * (1.0 - win_loss * 0.5)))
	var share := lose_loss * (0.5 if has_hero(String(att["id"]), "fairleigh") else 1.0)
	lose(att, share)
	if d["armies"].has(String(att["id"])):
		att["at"] = String(b["from"])
	var txt2 := ["%s holds %s against %s.", fname(df), rname(to), fname(af)]
	log_line(txt2)
	return {"won": false, "text": WWWar.line_text(txt2)}


## A beaten army loses its share and falls back to a neighbouring region of its own with no enemy in it, or is lost.
func _beaten(a: Dictionary, share: float, at: String, foe: String) -> void:
	var f := String(a["f"])
	if has_hero(String(a["id"]), "fairleigh"):
		share *= 0.5
	lose(a, share)
	if not d["armies"].has(String(a["id"])):
		return
	for n in WWRules.land_nb(at):
		if owner(n) == f and armies_at(n).all(func(x) -> bool: return String(x["f"]) == f):
			a["at"] = n
			a["moved"] = true
			log_line(["%s's army falls back to %s.", fname(f), rname(n)])
			return
	log_line(["%s's army has nowhere to fall back to and is lost.", fname(f)])
	remove_army(String(a["id"]))


## A region changes hands after a won battle (the old side's building is pulled down). The Brood can't hold the cold:
## it lays the land waste and leaves it free.
func _take(rid: String, f: String) -> void:
	var old := owner(rid)
	var reg: Dictionary = d["regions"][rid]
	if f == "brood" and WWRules.biome(rid) == "cold":
		reg["owner"] = ""
		reg["build"] = ""
		reg["guard"] = WWRules.FREE_GUARD_BASE
		log_line(["The Brood can't live in the cold: %s is laid waste and left free.", rname(rid)])
	else:
		reg["owner"] = f
		if old != f:
			reg["build"] = ""
			reg["unrest"] = 30.0 if old != "" else 15.0
	if old != "" and old != f and capital(old) == rid:
		_fall(old, f)


## A side's capital is taken: it is out of the war; its lands become free, its armies scatter.
func _fall(f: String, by: String) -> void:
	d["factions"][f]["out"] = true
	if f == "brood":
		log_line(["The Queen is dead: %s took %s and the Brood is broken.", fname(by), rname(capital(f))])
	else:
		log_line(["%s has fallen: %s took %s.", fname(f), fname(by), rname(capital(f))])
	for rid in regions_of(f):
		d["regions"][rid]["owner"] = ""
		d["regions"][rid]["build"] = ""
		d["regions"][rid]["guard"] = WWRules.worth(rid) * WWRules.GUARD + WWRules.FREE_GUARD_BASE
	for a in armies_of(f):
		remove_army(String(a["id"]))
	for hid in d["heroes"].keys():
		if String(d["heroes"][hid]["f"]) == f:
			d["heroes"].erase(hid)
	check_win()


## A fought battle (WWBattle) ends: the survivors of each side as counted on the field. The winner keeps its own and
## the region (if it attacked); the loser's survivors fall back (or are lost).
func apply_fought(b: Dictionary, att_won: bool, att_units: Dictionary, def_units: Dictionary) -> Dictionary:
	var att := army(String(b["att"]))
	var defs: Array = (b.get("defs", []) as Array).map(func(x) -> Dictionary: return army(String(x))).filter(func(x) -> bool: return not x.is_empty())
	if not att.is_empty():
		att["units"] = _cap_kinds(att["units"], att_units)
	# the defenders' survivors shared back over their armies (the first takes what is left)
	var left := def_units.duplicate()
	for i in defs.size():
		var da: Dictionary = defs[i]
		var keep := {}
		for k in da["units"]:
			var n := mini(int(da["units"][k]), int(left.get(k, 0))) if i < defs.size() - 1 else int(left.get(k, 0))
			if n > 0:
				keep[k] = n
				left[k] = int(left.get(k, 0)) - n
		da["units"] = keep
	for da in defs:
		if WWRules.units_count(da["units"]) == 0:
			remove_army(String(da["id"]))
	if not att.is_empty() and WWRules.units_count(att["units"]) == 0:
		remove_army(String(att["id"]))
		att = {}
	defs = defs.filter(func(x) -> bool: return d["armies"].has(String(x["id"])))
	b["defs"] = defs.map(func(x) -> String: return String(x["id"]))
	if att.is_empty():
		b["att"] = ""
	return _after_fought(b, att_won)


func _after_fought(b: Dictionary, att_won: bool) -> Dictionary:
	var to := String(b["region"])
	var af := String(b["att_f"])
	var df := String(b["def_f"])
	var att := army(String(b.get("att", "")))
	if att_won:
		for did in b["defs"]:
			var da := army(String(did))
			if not da.is_empty():
				_beaten(da, 0.0, to, af)
		var txt := ["%s wins the battle of %s.", fname(af), rname(to)]
		log_line(txt)
		if not att.is_empty():
			att["vet"] = mini(WWRules.VET_MAX, int(att["vet"]) + 1)
			# the region's own guard (and a capital's walls) still stand against what is left of the army
			if owner(to) == df and df != "":
				var rest := resolve({"att": String(att["id"]), "region": to, "from": String(b["from"]), "sea": false,
					"att_f": af, "def_f": df, "defs": []})
				return {"won": bool(rest["won"]), "text": WWWar.line_text(txt) + " " + String(rest["text"])}
			att["at"] = to
			_take(to, af)
		return {"won": true, "text": WWWar.line_text(txt)}
	for did in b["defs"]:
		var da := army(String(did))
		if not da.is_empty():
			da["vet"] = mini(WWRules.VET_MAX, int(da["vet"]) + 1)
	if not att.is_empty():
		att["at"] = String(b["from"])
	var txt2 := ["%s holds %s in the battle against %s.", fname(df), rname(to), fname(af)]
	log_line(txt2)
	return {"won": false, "text": WWWar.line_text(txt2)}


## Survivors are counted only in the kinds the army brought (units trained during the battle join, up to a quarter
## more of each kind).
func _cap_kinds(had: Dictionary, now: Dictionary) -> Dictionary:
	var out := {}
	for k in had:
		var n := mini(int(now.get(k, 0)), int(ceil(int(had[k]) * 1.25)))
		if n > 0:
			out[k] = n
	return out


# ------------------------------------------------------------------ building and recruiting

## Why a building can't go up there now ("" = it can).
func build_problem(rid: String, bid: String) -> String:
	var f := current()
	var b := WWRules.building(f, bid)
	if b.is_empty():
		return "Not one of your buildings."
	if owner(rid) != f:
		return "You don't hold this region."
	if String(d["regions"][rid]["build"]) != "":
		return "This region already has a building."
	if bool(d["regions"][rid].get("built_now", false)):
		return "Something was built here this season."
	if bool(b.get("swamp", false)) and not ["temperate", "wet", "jungle"].has(WWRules.biome(rid)):
		return "No swamp grows here (too cold or too dry)."
	if not armies_at(rid).filter(func(x) -> bool: return String(x["f"]) != f).is_empty():
		return "An enemy army stands here."
	if gold(f) < int(b["cost"]):
		return "Not enough gold."
	return ""


func build(rid: String, bid: String) -> bool:
	if build_problem(rid, bid) != "":
		return false
	var f := current()
	var b := WWRules.building(f, bid)
	d["factions"][f]["gold"] = gold(f) - int(b["cost"])
	d["regions"][rid]["build"] = bid
	d["regions"][rid]["built_now"] = true
	return true


func recruit_problem(rid: String, reg_id: String) -> String:
	var f := current()
	var r := WWRules.regiment(f, reg_id)
	if r.is_empty():
		return "Not one of your regiments."
	if not is_muster(rid, f):
		return "Armies are raised only at your capital and your %s." % Loc.t(String(WWRules.BUILDINGS[f][0]["name"]))
	if not armies_at(rid).filter(func(x) -> bool: return String(x["f"]) != f).is_empty():
		return "An enemy army stands here."
	if gold(f) < WWRules.regiment_cost(r):
		return "Not enough gold."
	return ""


## Recruit a regiment at a muster region: it joins the army there (or is a new army, which may march this turn).
func recruit(rid: String, reg_id: String) -> Dictionary:
	if recruit_problem(rid, reg_id) != "":
		return {}
	var f := current()
	var r := WWRules.regiment(f, reg_id)
	d["factions"][f]["gold"] = gold(f) - WWRules.regiment_cost(r)
	# (it joins the army there with room for it; with none, or all full, it is a new army)
	var mates: Array = armies_at(rid, f).filter(func(x) -> bool: return WWRules.units_count(x["units"]) + WWRules.units_count(r["units"]) <= WWRules.ARMY_CAP)
	if mates.is_empty():
		var na := new_army(f, rid, (r["units"] as Dictionary).duplicate())
		na["moved"] = true          # (new soldiers march next season)
		return na
	var a: Dictionary = mates[0]
	var before := army_value(a)
	add_units(a, r["units"])
	if WWRules.regiment_cost(r) > before:
		a["vet"] = maxi(0, int(a["vet"]) - 1)          # (more recruits than veterans: the army's rank thins)
	return a


# ------------------------------------------------------------------ turns and seasons

## The start of the current side's turn: its income and upkeep, the climate on its armies, unrest and risings in its
## lands, heroes back. Returns the report's lines.
func begin_turn() -> Array:
	var f := current()
	var rep: Array = []
	var fd: Dictionary = d["factions"][f]
	for rid in d["regions"]:
		d["regions"][rid].erase("built_now")
	for a in armies_of(f):
		a["moved"] = false
	var inc: Array = income(f)
	var up := upkeep(f)
	var g := gold(f) + int(inc[1]) - up
	fd["income_last"] = int(inc[1])
	fd["upkeep_last"] = up
	rep.append(["Income %d gold, upkeep of armies and far lands %d.", int(inc[1]), up])
	if g < 0:
		g = 0
		rep.append(["The treasury is empty: unpaid soldiers desert (each army loses %d%%).", int(WWRules.DEBT_LOSS * 100)])
		for a in armies_of(f):
			lose(a, WWRules.DEBT_LOSS)
	fd["gold"] = g
	# the climate
	var winter := int(d["season"]) % 4 == 3
	for a in armies_of(f):
		var bio := biome_now(String(a["at"]))
		var loss := float(WWRules.ATTRITION.get(f, {}).get(bio, 0.0))
		if f == "brood" and bio == "cold" and winter:
			loss *= WWRules.WINTER_COLD
		if has_hero(String(a["id"]), "hollweg"):
			loss = 0.0
		if loss > 0.0:
			rep.append(["Rust: the army at %s loses %d%% of its men." if f == "clockwork" else "Cold: the army at %s loses %d%% of its creatures.", rname(String(a["at"])), int(round(loss * 100))])
			lose(a, loss)
	# mending: an army at its capital or at one of its side's mending buildings
	for a in armies_of(f):
		var at := String(a["at"])
		if owner(at) != f:
			continue
		if at == capital(f) or (WWRules.MEND_AT[f] as Array).has(String(d["regions"][at]["build"])):
			grow(a, WWRules.MEND)
	# heroes back from their wounds join an army at the capital
	for hid in d["heroes"]:
		var h: Dictionary = d["heroes"][hid]
		if String(h["f"]) == f and String(h["army"]) == "" and int(d["season"]) >= int(h["back"]):
			var at_cap := armies_at(capital(f), f)
			if not at_cap.is_empty():
				h["army"] = String(at_cap[0]["id"])
				rep.append(["%s is back and leads the army at %s.", WWRules.hero(hid).get("name", hid), rname(capital(f))])
	# unrest and risings
	var hp := hops(f)
	var held := regions_of(f)
	var stretch := WWRules.UNREST_SIZE * maxi(0, held.size() - WWRules.UNREST_SIZE_FROM)
	for rid in held:
		if rid == capital(f):
			continue
		var reg: Dictionary = d["regions"][rid]
		var u := float(reg["unrest"]) + stretch
		u += WWRules.UNREST_FAR * maxi(0, int(hp.get(rid, 9)) - 2)
		if (WWRules.HATED[f] as Array).has(WWRules.biome(rid)):
			u += WWRules.UNREST_CLIMATE
		if not armies_at(rid, f).is_empty():
			u -= WWRules.UNREST_ARMY
		u -= float(WWRules.building(f, String(reg["build"])).get("calm", 0))
		u -= WWRules.UNREST_FALL
		if String(d.get("event", "")) == "council" and f == "crown" and owner("rome") == "crown" and int(d.get("event_s", -1)) == int(d["season"]):
			u -= 20.0
		reg["unrest"] = clampf(u, 0.0, 100.0)
		if float(reg["unrest"]) > WWRules.REBEL_FROM and armies_at(rid, f).is_empty():
			var chance := (float(reg["unrest"]) - WWRules.REBEL_FROM) / WWRules.REBEL_DIV
			if rng.randf() < chance:
				reg["owner"] = ""
				reg["build"] = ""
				reg["unrest"] = 0.0
				reg["guard"] = WWRules.worth(rid) * 150 + WWRules.FREE_GUARD_BASE
				rep.append(["%s rises against %s and is free again.", rname(rid), fname(f)])
				log_line(["%s rises against %s and is free again.", rname(rid), fname(f)])
	return rep


## The current side is done: the next one's turn begins (and after the last, a new season: events, the win check).
## Returns the next side's report.
func end_turn() -> Array:
	if String(d["winner"]) != "":
		return []
	var n: int = (d["order"] as Array).size()
	for _i in n:
		d["turn"] = int(d["turn"]) + 1
		if int(d["turn"]) >= n:
			d["turn"] = 0
			_new_season()
			if String(d["winner"]) != "":
				return []
		if alive(current()):
			break
	return begin_turn()


func _new_season() -> void:
	d["season"] = int(d["season"]) + 1
	check_win()
	if String(d["winner"]) != "":
		return
	d["event"] = ""
	if rng.randf() < WWRules.EVENT_CHANCE:
		var ev: String = WWRules.EVENTS[rng.randi() % WWRules.EVENTS.size()]
		d["event"] = ev
		d["event_s"] = int(d["season"])
		match ev:
			"plague":
				log_line(["A plague year: every army in the jungle or the wetlands loses a tenth."])
				for a in d["armies"].values().duplicate():
					if ["jungle", "wet"].has(biome_now(String(a["at"]))):
						lose(a, 0.1)
			"council":
				log_line(["A council meets in Rome: the Crown's lands grow calmer this season." if owner("rome") == "crown" else "A council meets in Rome, but Rome is not the Crown's: nothing comes of it."])
			"storms":
				d["storms"] = int(d["season"])
				log_line(["A season of storms: sea crossings meet storms three times as often."])
			"harvest":
				log_line(["A good harvest: every side gets 100 gold."])
				for f in d["factions"]:
					if alive(f):
						d["factions"][f]["gold"] = gold(f) + 100
	log_line(["%s begins.", WWRules.season_name(int(d["season"]))])


## Is the war won? Sets d.winner (a side) when it is.
func check_win() -> String:
	if String(d["winner"]) != "":
		return String(d["winner"])
	var left: Array = (d["order"] as Array).filter(func(f: String) -> bool: return alive(f))
	if left.size() == 1:
		d["winner"] = left[0]
	elif left.is_empty():
		d["winner"] = "none"
	elif String(d["win"]) == "keys":
		for f in left:
			if key_count(f) >= int(d["keys"]):
				d["winner"] = f
	if String(d["winner"]) == "" and left.size() > 1 and int(d["seasons"]) > 0 and int(d["season"]) >= int(d["seasons"]):
		var best := ""
		for f in left:
			if best == "" or land_worth(f) > land_worth(best):
				best = f
		d["winner"] = best
	if String(d["winner"]) != "":
		log_line(["The war is over: %s wins." if String(d["winner"]) != "none" else "The war is over: no one is left.", fname(String(d["winner"]))])
	return String(d["winner"])
