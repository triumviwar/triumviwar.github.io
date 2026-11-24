class_name Tournament
extends RefCounted
## TOURNAMENTS (job tournament, docs/tournament.md; the owner 2026-11-24: "SC2 and other RTS have to use Challonge and
## other outside tools, let's have an in-game tool"). The bracket itself: who plays whom, the maps, the factions, the
## results, the standings, the champion. No screen and no network here (TournamentPage draws it, TournamentNet carries it
## online); everything is one JSON-safe Dictionary `d`, so the same tournament can be saved, sent, exported as a code and
## run by tools/tournament_cli.gd (the championship simulation, docs/championship_sim.md).
##
## FORMATS: "single" elimination, "double" elimination (a bracket reset if the lower-bracket player wins the grand
## final), "robin" (round robin), "swiss", "groups" (round-robin groups, then single-elimination playoffs).
## A PLAYER: {"id", "name", "faction", "who": "human" or a computer's level, "plan", "seed", "checked", "dropped", "key"}.
## A MATCH: {"id", "stage", "round", "pos", "a", "b", "from_a", "from_b", "bo", "games", "winner", "loser", "state",
##   "bans", "picks", "reports", "dispute", "room", "replays"}; a side is a player id, NONE (-2: nobody will come, a bye)
##   or WAIT (-1: not known yet). "from_a" = ["w", match id] (that match's winner) or ["l", match id] (its loser).
## A GAME: {"map", "fa", "fb", "win": "a"/"b", "how": "played"/"time"/"walkover"/"set", "len", "seed", "replay"}.

const VERSION := 1
const WAIT := -1
const NONE := -2
const FORMATS := ["single", "double", "robin", "swiss", "groups"]
const FORMAT_NAME := {"single": "Single elimination", "double": "Double elimination", "robin": "Round robin",
	"swiss": "Swiss", "groups": "Groups, then playoffs"}
const FACTION_RULES := ["free", "series", "event", "once"]
const FACTION_RULE_NAME := {"free": "Free: pick before every game", "series": "Locked for a series",
	"event": "Locked for the whole tournament", "once": "Each faction once in a series"}
const MAP_RULES := ["random", "veto", "pick"]
const MAP_RULE_NAME := {"random": "Random from the pool", "veto": "Each player bans one, then random",
	"pick": "Each player bans one, the higher seed picks game 1"}
const MODES := ["online", "offline", "computer"]
const MODE_NAME := {"online": "Online (players join by code)", "offline": "Offline / LAN (results by hand)",
	"computer": "All computer players"}
const MAX_PLAYERS := 64
const FACTIONS := ["crown", "clockwork", "brood"]
## The parity maps (qa_matches.PARITY_MAPS): a fair pool to start from.
const DEFAULT_MAPS := ["greenhold", "dune_sea", "frostfang", "ashford_crossing", "hollowfen", "cinder_steps"]
## THE TIME LIMIT'S LEAD RULE (Claude's choice, docs/tournament.md): at the bell the side whose score (income earned + 2 x
## army value, the studies' score) is at least LEAD_K times the other's wins the game; otherwise the game is played again
## on the same map with new dice (at most REPLAYS times, then the higher score wins).
const LEAD_K := 1.1
const REPLAYS := 2

var d: Dictionary = {}


# ================================================================== making one

static func make(name: String, opts := {}) -> Tournament:
	var t := Tournament.new()
	t.d = {"v": VERSION, "id": new_code(), "name": name, "format": "double", "bo": 3, "bo_final": 3,
		"maps": DEFAULT_MAPS.duplicate(), "map_rule": "veto", "loser_picks": true, "factions": "event",
		"seeding": "random", "checkin": false, "groups": 2, "advance": 2, "swiss_rounds": 0, "mode": "online",
		"time_limit": 1200, "level": "hard", "players": [], "matches": [], "state": "signup", "champion": WAIT,
		"seed": randi(), "made": Time.get_datetime_string_from_system(), "log": [], "rev": 0, "next_pid": 1}
	for k in opts:
		t.d[k] = opts[k]
	return t


static func new_code() -> String:
	var abc := "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
	var s := ""
	for i in 5:
		s += abc[randi() % abc.length()]
	return s


static func from_dict(src: Dictionary) -> Tournament:
	var t := Tournament.new()
	t.d = _ints(src.duplicate(true))
	return t


## JSON turns every number into a float: player ids, sides, rounds back to ints (the bracket compares them).
static func _ints(x):
	if x is Dictionary:
		for k in x.keys():
			x[k] = _ints(x[k])
		return x
	if x is Array:
		for i in x.size():
			x[i] = _ints(x[i])
		return x
	if x is float and x == floorf(x) and absf(x) < 1e12:
		return int(x)
	return x


func to_json() -> String:
	return JSON.stringify(d)


## A code to copy and paste (the organiser's tournament survives a restart, a friend can take it over): "TOUR1:" +
## base64 of the gzipped JSON.
func export_code() -> String:
	var raw := to_json().to_utf8_buffer()
	return "TOUR1:" + Marshalls.raw_to_base64(raw.compress(FileAccess.COMPRESSION_GZIP)) + ":" + str(raw.size())


static func import_code(code: String) -> Tournament:
	var s := code.strip_edges()
	if not s.begins_with("TOUR1:"):
		return null
	var parts := s.split(":")
	if parts.size() < 3:
		return null
	var raw := Marshalls.base64_to_raw(parts[1]).decompress(int(parts[2]), FileAccess.COMPRESSION_GZIP)
	var j = JSON.parse_string(raw.get_string_from_utf8())
	if not (j is Dictionary) or not j.has("matches"):
		return null
	return from_dict(j)


func save(dir := "user://tournaments") -> String:
	DirAccess.make_dir_recursive_absolute(dir)
	var path := "%s/%s.json" % [dir, d["id"]]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return ""
	f.store_string(to_json())
	return path


static func load_from(path: String) -> Tournament:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var j = JSON.parse_string(f.get_as_text())
	return from_dict(j) if j is Dictionary else null


## The tournaments kept on this device, newest first: [{"path", "name", "state", "format", "players", "champion"}].
static func saved(dir := "user://tournaments") -> Array:
	var out: Array = []
	var da := DirAccess.open(dir)
	if da == null:
		return out
	for fn in da.get_files():
		if not fn.ends_with(".json") or fn.begins_with("_"):
			continue
		var t := load_from(dir + "/" + fn)
		if t == null:
			continue
		out.append({"path": dir + "/" + fn, "t": t, "mtime": FileAccess.get_modified_time(dir + "/" + fn)})
	out.sort_custom(func(a, b) -> bool: return a["mtime"] > b["mtime"])
	return out


func _touch(what := "") -> void:
	d["rev"] = int(d.get("rev", 0)) + 1
	if what != "":
		(d["log"] as Array).append(what)
		if d["log"].size() > 200:
			d["log"] = d["log"].slice(-200)


# ================================================================== players

func add_player(name: String, faction := "random", who := "human", plan := "") -> int:
	if d["state"] != "signup" or players().size() >= MAX_PLAYERS:
		return WAIT
	var pid := int(d["next_pid"])
	d["next_pid"] = pid + 1
	var p := {"id": pid, "name": name.strip_edges().substr(0, 24), "faction": faction, "who": who, "plan": plan,
		"seed": players().size() + 1, "checked": who != "human", "dropped": false, "key": _key()}
	d["players"].append(p)
	_touch("%s joined" % p["name"])
	return pid


static func _key() -> String:
	var s := ""
	for i in 12:
		s += "0123456789abcdef"[randi() % 16]
	return s


func players() -> Array:
	return d["players"]


func player(pid: int) -> Dictionary:
	for p in d["players"]:
		if int(p["id"]) == pid:
			return p
	return {}


func pname(pid: int) -> String:
	if pid == NONE:
		return "(bye)"
	if pid == WAIT:
		return "..."
	var p := player(pid)
	return String(p.get("name", "?"))


func remove_player(pid: int) -> void:
	if d["state"] != "signup":
		return
	d["players"] = players().filter(func(p) -> bool: return int(p["id"]) != pid)
	_reseed()


func check_in(pid: int, on := true) -> void:
	var p := player(pid)
	if not p.is_empty():
		p["checked"] = on
		_touch()


## Manual seeding: move a player up or down the list (seed 1 is the top).
func move_seed(pid: int, delta: int) -> void:
	var ps := _by_seed()
	var i := -1
	for k in ps.size():
		if int(ps[k]["id"]) == pid:
			i = k
	var j := i + delta
	if i < 0 or j < 0 or j >= ps.size():
		return
	var tmp = ps[i]
	ps[i] = ps[j]
	ps[j] = tmp
	for k in ps.size():
		ps[k]["seed"] = k + 1
	_touch()


func _by_seed() -> Array:
	var ps: Array = players().duplicate()
	ps.sort_custom(func(a, b) -> bool: return int(a["seed"]) < int(b["seed"]))
	return ps


func _reseed() -> void:
	var ps := _by_seed()
	for k in ps.size():
		ps[k]["seed"] = k + 1


func rng_for(salt: String) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = hash(str(d["seed"]) + ":" + salt)
	return r


# ================================================================== starting

## What stops the organiser from starting ("" = nothing).
func start_problem() -> String:
	var n := _entrants().size()
	if d["state"] != "signup":
		return "The tournament has already started."
	if n < 2:
		return "At least 2 players are needed (checked in)." if d["checkin"] else "At least 2 players are needed."
	if d["format"] == "groups" and n < int(d["groups"]) * 2:
		return "Each group needs at least 2 players."
	if (d["maps"] as Array).is_empty():
		return "The map pool is empty."
	return ""


func _entrants() -> Array:
	return players().filter(func(p) -> bool: return not p["dropped"] and (not d["checkin"] or p["checked"]))


func start() -> bool:
	if start_problem() != "":
		return false
	# check-in: those who did not check in are dropped
	for p in players():
		if d["checkin"] and not p["checked"]:
			p["dropped"] = true
	var ps := _entrants()
	if d["seeding"] == "random":
		var r := rng_for("seeding")
		for i in range(ps.size() - 1, 0, -1):
			var j := r.randi_range(0, i)
			var tmp = ps[i]
			ps[i] = ps[j]
			ps[j] = tmp
	else:
		ps.sort_custom(func(a, b) -> bool: return int(a["seed"]) < int(b["seed"]))
	for k in ps.size():
		ps[k]["seed"] = k + 1
	var ids: Array = ps.map(func(p) -> int: return int(p["id"]))
	d["matches"] = []
	match String(d["format"]):
		"single":
			_build_single(ids, "wb")
		"double":
			_build_double(ids)
		"robin":
			_build_robin(ids, "rr", 0)
		"swiss":
			if int(d["swiss_rounds"]) <= 0:
				d["swiss_rounds"] = maxi(1, ceili(log(float(ids.size())) / log(2.0)))
			_swiss_round(1)
		"groups":
			_build_groups(ids)
	d["state"] = "running"
	_touch("The tournament began (%d players)" % ids.size())
	_settle()
	return true


func _new_match(stage: String, rnd: int, pos: int, a := WAIT, b := WAIT) -> Dictionary:
	var m := {"id": (d["matches"] as Array).size(), "stage": stage, "round": rnd, "pos": pos, "a": a, "b": b,
		"from_a": [], "from_b": [], "bo": int(d["bo"]), "games": [], "winner": WAIT, "loser": WAIT, "state": "wait",
		"bans": [], "picks": {}, "reports": {}, "dispute": "", "group": -1, "replays": 0}
	d["matches"].append(m)
	return m


## The standard seeding order of a bracket of `size` (a power of two): 1 v size, then so the top two meet last.
static func seed_order(size: int) -> Array:
	var order: Array = [1]
	while order.size() < size:
		var n := order.size() * 2
		var nxt: Array = []
		for s in order:
			nxt.append(s)
			nxt.append(n + 1 - s)
		order = nxt
	return order


static func _pow2(n: int) -> int:
	var s := 1
	while s < n:
		s *= 2
	return s


## Single elimination for `ids` (in seed order); returns the matches of each round [[round 1], [round 2], ...].
func _build_single(ids: Array, stage: String) -> Array:
	var size := _pow2(ids.size())
	var order := seed_order(size)
	var rounds: Array = []
	var r1: Array = []
	for i in size / 2:
		var sa: int = order[2 * i]
		var sb: int = order[2 * i + 1]
		r1.append(_new_match(stage, 1, i, int(ids[sa - 1]) if sa <= ids.size() else NONE, int(ids[sb - 1]) if sb <= ids.size() else NONE))
	rounds.append(r1)
	var rnd := 2
	while (rounds[-1] as Array).size() > 1:
		var prev: Array = rounds[-1]
		var cur: Array = []
		for i in prev.size() / 2:
			var m := _new_match(stage, rnd, i)
			m["from_a"] = ["w", prev[2 * i]["id"]]
			m["from_b"] = ["w", prev[2 * i + 1]["id"]]
			cur.append(m)
		rounds.append(cur)
		rnd += 1
	(rounds[-1][0] as Dictionary)["bo"] = int(d["bo_final"])
	return rounds


## Double elimination: the winners' bracket, the losers' bracket fed by it, the grand final and its reset.
func _build_double(ids: Array) -> void:
	var wb := _build_single(ids, "wb")
	(wb[-1][0] as Dictionary)["bo"] = int(d["bo"])
	var k := wb.size()
	if k == 1:
		# two players: a grand final and its reset only (the loser of the first "final" gets a second chance)
		var gf0 := _new_match("gf", 1, 0)
		gf0["from_a"] = ["w", wb[0][0]["id"]]
		gf0["from_b"] = ["l", wb[0][0]["id"]]
		gf0["bo"] = int(d["bo_final"])
		var r0 := _new_match("gf", 2, 0)
		r0["from_a"] = ["w", gf0["id"]]
		r0["from_b"] = ["l", gf0["id"]]
		r0["bo"] = int(d["bo_final"])
		r0["reset"] = true
		return
	# losers' round 1: the losers of the winners' round 1, in pairs
	var lb: Array = []
	var cur: Array = []
	var w1: Array = wb[0]
	var lr := 1
	for i in w1.size() / 2:
		var m := _new_match("lb", lr, i)
		m["from_a"] = ["l", w1[2 * i]["id"]]
		m["from_b"] = ["l", w1[2 * i + 1]["id"]]
		cur.append(m)
	lb.append(cur)
	for wr in range(1, k):
		# a drop-in round: the losers' survivors meet the losers of winners' round wr+1 (reversed every other round so
		# two players who met in the winners' bracket don't meet again at once)
		lr += 1
		var drops: Array = wb[wr].duplicate()
		if wr % 2 == 1:
			drops.reverse()
		var prev: Array = lb[-1]
		cur = []
		for i in prev.size():
			var m := _new_match("lb", lr, i)
			m["from_a"] = ["w", prev[i]["id"]]
			m["from_b"] = ["l", drops[i]["id"]]
			cur.append(m)
		lb.append(cur)
		if cur.size() > 1:
			# a halving round among the losers' survivors
			lr += 1
			prev = cur
			cur = []
			for i in prev.size() / 2:
				var m := _new_match("lb", lr, i)
				m["from_a"] = ["w", prev[2 * i]["id"]]
				m["from_b"] = ["w", prev[2 * i + 1]["id"]]
				cur.append(m)
			lb.append(cur)
	var gf := _new_match("gf", 1, 0)
	gf["from_a"] = ["w", wb[-1][0]["id"]]
	gf["from_b"] = ["w", lb[-1][0]["id"]]
	gf["bo"] = int(d["bo_final"])
	var reset := _new_match("gf", 2, 0)
	reset["from_a"] = ["w", gf["id"]]
	reset["from_b"] = ["l", gf["id"]]
	reset["bo"] = int(d["bo_final"])
	reset["reset"] = true      # played only if the lower-bracket player won the first grand final


## Round robin (the circle method): every pair once, in rounds.
func _build_robin(ids: Array, stage: String, group: int) -> void:
	var ps: Array = ids.duplicate()
	if ps.size() % 2 == 1:
		ps.append(NONE)
	var n := ps.size()
	for r in n - 1:
		for i in n / 2:
			var a: int = ps[i]
			var b: int = ps[n - 1 - i]
			if a == NONE or b == NONE:
				continue
			var m := _new_match(stage, r + 1, i, a if r % 2 == 0 else b, b if r % 2 == 0 else a)
			m["group"] = group
		# rotate all but the first
		var last = ps.pop_back()
		ps.insert(1, last)


func _build_groups(ids: Array) -> void:
	var g := int(d["groups"])
	var groups: Array = []
	for i in g:
		groups.append([])
	# snake seeding: 1 2 3 4 / 8 7 6 5 / ...
	for i in ids.size():
		var row := i / g
		var col := i % g
		if row % 2 == 1:
			col = g - 1 - col
		groups[col].append(ids[i])
	d["group_ids"] = groups
	for gi in g:
		_build_robin(groups[gi], "grp", gi)


func _swiss_round(r: int) -> void:
	var stand := standings()
	var order: Array = stand.filter(func(s) -> bool: return not player(int(s["id"]))["dropped"]).map(func(s) -> int: return int(s["id"]))
	if r == 1:
		order = _by_seed().filter(func(p) -> bool: return not p["dropped"] and int(p["seed"]) > 0).map(func(p) -> int: return int(p["id"]))
		# round 1: the top half against the bottom half (1 v n/2+1 ...)
		var half := order.size() / 2
		var top: Array = order.slice(0, half)
		var bot: Array = order.slice(half)
		order = []
		for i in half:
			order.append(top[i])
			order.append(bot[i])
		if bot.size() > half:
			order.append(bot[-1])
	var met := {}
	var had_bye := {}
	for m in d["matches"]:
		if m["stage"] == "sw":
			met[_pair_key(int(m["a"]), int(m["b"]))] = true
			if int(m["b"]) == NONE:
				had_bye[int(m["a"])] = true
	var pool: Array = order.duplicate()
	var pos := 0
	if pool.size() % 2 == 1:
		# the bye to the lowest-ranked player who has not had one
		for i in range(pool.size() - 1, -1, -1):
			if not had_bye.has(int(pool[i])):
				var who: int = pool[i]
				pool.remove_at(i)
				var bm := _new_match("sw", r, 999, who, NONE)
				bm["pos"] = 999
				break
	var pairs := _swiss_pair(pool, met, r == 1)
	for pr in pairs:
		_new_match("sw", r, pos, pr[0], pr[1])
		pos += 1
	d["swiss_now"] = r


static func _pair_key(a: int, b: int) -> String:
	return "%d-%d" % [mini(a, b), maxi(a, b)]


## Pair a ranked list, top down, each with the next one it has not met (backtracking when the end can't be paired).
static func _swiss_pair(pool: Array, met: Dictionary, in_order: bool) -> Array:
	if pool.is_empty():
		return []
	if in_order:
		var out: Array = []
		for i in range(0, pool.size() - 1, 2):
			out.append([pool[i], pool[i + 1]])
		return out
	var a: int = pool[0]
	for j in range(1, pool.size()):
		var b: int = pool[j]
		if met.has(_pair_key(a, b)):
			continue
		var rest: Array = pool.duplicate()
		rest.remove_at(j)
		rest.remove_at(0)
		var sub := _swiss_pair(rest, met, false)
		if sub.size() * 2 == rest.size():
			return [[a, b]] + sub
	# no pairing without a rematch: allow one with the nearest
	var rest2: Array = pool.duplicate()
	rest2.remove_at(1)
	rest2.remove_at(0)
	return [[a, pool[1]]] + _swiss_pair(rest2, {}, false)


# ================================================================== playing

func get_match(mid: int) -> Dictionary:
	if mid >= 0 and mid < (d["matches"] as Array).size():
		return d["matches"][mid]
	return {}


func wins_needed(m: Dictionary) -> int:
	return int(m["bo"]) / 2 + 1


## [games won by a, games won by b]
func score(m: Dictionary) -> Array:
	var wa := 0
	var wb := 0
	for g in m["games"]:
		if g["win"] == "a":
			wa += 1
		elif g["win"] == "b":
			wb += 1
	return [wa, wb]


## The matches that can be played now (both players known, not finished), in order.
func ready_matches() -> Array:
	return (d["matches"] as Array).filter(func(m) -> bool: return m["state"] == "ready" or m["state"] == "live")


## The next game of a match: {"map", "fa", "fb", "seed", "game": index} (map and factions as far as the rules decide
## them now: "" = still to choose).
func next_game(m: Dictionary) -> Dictionary:
	var gi: int = (m["games"] as Array).size()
	return {"game": gi, "map": map_for(m, gi), "fa": faction_for(m, "a"), "fb": faction_for(m, "b"),
		"seed": game_seed(m, gi)}


func game_seed(m: Dictionary, gi: int) -> int:
	return absi(hash("%s:%d:%d:%d" % [d["seed"], int(m["id"]), gi, int(m.get("replays", 0))])) % 2000000000


## The maps still in play for a series (the pool less the bans).
func open_maps(m: Dictionary) -> Array:
	return (d["maps"] as Array).filter(func(x) -> bool: return not (m["bans"] as Array).has(x))


## Who bans next ("a"/"b") or "" when the bans are done (one each, the higher seed first; none with the random rule or
## a pool too small to leave a map for every game).
func ban_turn(m: Dictionary) -> String:
	if d["map_rule"] == "random" or not (m["games"] as Array).is_empty():
		return ""
	if (d["maps"] as Array).size() - (m["bans"] as Array).size() <= 1:
		return ""
	var n: int = (m["bans"] as Array).size()
	if n >= 2:
		return ""
	return "a" if n == 0 else "b"


func ban(m: Dictionary, side: String, map_id: String) -> bool:
	if ban_turn(m) != side or not open_maps(m).has(map_id):
		return false
	(m["bans"] as Array).append(map_id)
	_touch("%s bans %s" % [pname(int(m[side])), map_id])
	return true


## Who picks the next game's map ("a"/"b"), or "" when the dice choose.
func pick_turn(m: Dictionary) -> String:
	if ban_turn(m) != "":
		return ""
	var gi: int = (m["games"] as Array).size()
	if (m["picks"] as Dictionary).has(str(gi)):
		return ""
	if gi == 0:
		return "a" if d["map_rule"] == "pick" else ""
	if d["loser_picks"]:
		var last: Dictionary = m["games"][gi - 1]
		return "b" if last["win"] == "a" else "a"
	return ""


func pick(m: Dictionary, side: String, map_id: String) -> bool:
	if pick_turn(m) != side or not open_maps(m).has(map_id):
		return false
	m["picks"][str((m["games"] as Array).size())] = map_id
	_touch("%s picks %s" % [pname(int(m[side])), map_id])
	return true


## The map of game `gi`: a pick, else the dice among the open maps not played yet in the series.
func map_for(m: Dictionary, gi: int) -> String:
	if (m["picks"] as Dictionary).has(str(gi)):
		return String(m["picks"][str(gi)])
	if gi < (m["games"] as Array).size():
		return String(m["games"][gi]["map"])
	var open := open_maps(m)
	var played: Array = (m["games"] as Array).map(func(g) -> String: return String(g["map"]))
	var fresh: Array = open.filter(func(x) -> bool: return not played.has(x))
	if fresh.is_empty():
		fresh = open
	if fresh.is_empty():
		return String(d["maps"][0])
	var r := rng_for("map:%d:%d" % [int(m["id"]), gi])
	return String(fresh[r.randi_range(0, fresh.size() - 1)])


## The faction a side plays in the match's next game ("" = the player chooses it before the game).
func faction_for(m: Dictionary, side: String) -> String:
	var pid := int(m[side])
	var p := player(pid)
	if p.is_empty():
		return ""
	if d["factions"] == "event" or p["who"] != "human":
		return String(p["faction"]) if String(p["faction"]) != "random" else _dice_faction(m, side)
	var gi: int = (m["games"] as Array).size()
	var chosen: Dictionary = m.get("fac", {})
	if chosen.has("%s%d" % [side, gi]):
		return String(chosen["%s%d" % [side, gi]])
	if d["factions"] == "series" and gi > 0:
		return String(m["games"][0]["f" + side])
	return ""


func _dice_faction(m: Dictionary, side: String) -> String:
	var r := rng_for("fac:%d:%s" % [int(m["id"]), side])
	return FACTIONS[r.randi_range(0, 2)]


## The factions a side may still choose for the next game.
func faction_choices(m: Dictionary, side: String) -> Array:
	var gi: int = (m["games"] as Array).size()
	match String(d["factions"]):
		"event":
			return [faction_for(m, side)]
		"series":
			return FACTIONS.duplicate() if gi == 0 else [String(m["games"][0]["f" + side])]
		"once":
			var used: Array = (m["games"] as Array).map(func(g) -> String: return String(g["f" + side]))
			var left: Array = FACTIONS.filter(func(f) -> bool: return not used.has(f))
			return left if not left.is_empty() else FACTIONS.duplicate()
	return FACTIONS.duplicate()


func choose_faction(m: Dictionary, side: String, f: String) -> bool:
	if not faction_choices(m, side).has(f):
		return false
	if not m.has("fac"):
		m["fac"] = {}
	m["fac"]["%s%d" % [side, (m["games"] as Array).size()]] = f
	_touch()
	return true


## A game is over. `win` "a"/"b"; `info` may carry "len", "replay", "how" ("played", "time", "set", "walkover").
## Returns false if the match can't take it.
func report_game(mid: int, win: String, info := {}) -> bool:
	var m := get_match(mid)
	if m.is_empty() or m["state"] == "done" or not (win in ["a", "b"]) or int(m["a"]) < 0 or int(m["b"]) < 0:
		return false
	var nx := next_game(m)
	var g := {"map": String(info.get("map", nx["map"])), "fa": String(info.get("fa", nx["fa"])), "fb": String(info.get("fb", nx["fb"])),
		"win": win, "how": String(info.get("how", "played")), "len": int(info.get("len", 0)), "seed": int(info.get("seed", nx["seed"])),
		"replay": String(info.get("replay", ""))}
	(m["games"] as Array).append(g)
	m["replays"] = 0
	m["reports"] = {}
	m["dispute"] = ""
	m["state"] = "live"
	var sc := score(m)
	_touch("%s %d-%d %s" % [pname(int(m["a"])), sc[0], sc[1], pname(int(m["b"]))])
	if sc[0] >= wins_needed(m) or sc[1] >= wins_needed(m):
		_finish(m, "a" if sc[0] > sc[1] else "b")
	_settle()
	return true


## The bell came with no clear leader: the game is played again (another seed); after REPLAYS the higher score wins.
## `score_a` / `score_b` are the sides' scores (income earned + 2 x army). Returns "a", "b" or "again".
func time_verdict(m: Dictionary, score_a: float, score_b: float) -> String:
	if score_a >= LEAD_K * score_b and score_a > 0:
		return "a"
	if score_b >= LEAD_K * score_a and score_b > 0:
		return "b"
	if int(m.get("replays", 0)) >= REPLAYS:
		return "a" if score_a >= score_b else "b"
	return "again"


func replay_game(mid: int) -> void:
	var m := get_match(mid)
	if not m.is_empty():
		m["replays"] = int(m.get("replays", 0)) + 1
		_touch("%s v %s: a game is played again (no clear leader at the bell)" % [pname(int(m["a"])), pname(int(m["b"]))])


## The organiser sets a whole match (a dispute settled, a result entered by hand): `wa`-`wb` games.
func set_result(mid: int, wa: int, wb: int) -> bool:
	var m := get_match(mid)
	if m.is_empty() or int(m["a"]) < 0 or int(m["b"]) < 0 or wa == wb:
		return false
	if m["state"] == "done" and not _undo_ok(m):
		return false
	if m["state"] == "done":
		_unfinish(m)
	m["games"] = []
	for i in wa:
		m["games"].append({"map": "", "fa": "", "fb": "", "win": "a", "how": "set", "len": 0, "seed": 0, "replay": ""})
	for i in wb:
		m["games"].append({"map": "", "fa": "", "fb": "", "win": "b", "how": "set", "len": 0, "seed": 0, "replay": ""})
	m["reports"] = {}
	m["dispute"] = ""
	_touch("The organiser set %s %d-%d %s" % [pname(int(m["a"])), wa, wb, pname(int(m["b"]))])
	_finish(m, "a" if wa > wb else "b")
	_settle()
	return true


## A walkover: `side` wins without playing (the other did not come).
func walkover(mid: int, side: String) -> bool:
	var m := get_match(mid)
	if m.is_empty() or m["state"] == "done" or int(m["a"]) < 0 or int(m["b"]) < 0:
		return false
	m["walkover"] = true
	_touch("%s wins by walkover" % pname(int(m[side])))
	_finish(m, side)
	_settle()
	return true


## A finished match may be changed only while nothing after it has been played.
func _undo_ok(m: Dictionary) -> bool:
	for n in d["matches"]:
		if (n["from_a"] as Array).size() == 2 and int(n["from_a"][1]) == int(m["id"]) and not (n["games"] as Array).is_empty():
			return false
		if (n["from_b"] as Array).size() == 2 and int(n["from_b"][1]) == int(m["id"]) and not (n["games"] as Array).is_empty():
			return false
	return true


func _unfinish(m: Dictionary) -> void:
	m["state"] = "ready"
	m["winner"] = WAIT
	m["loser"] = WAIT
	for n in d["matches"]:
		for s in ["a", "b"]:
			var src: Array = n["from_" + s]
			if src.size() == 2 and int(src[1]) == int(m["id"]):
				n[s] = WAIT
				n["state"] = "wait"
	d["champion"] = WAIT
	if d["state"] == "done":
		d["state"] = "running"


## A player leaves (or is dropped by the organiser): every match of theirs still to play is a walkover.
func drop(pid: int) -> void:
	var p := player(pid)
	if p.is_empty():
		return
	p["dropped"] = true
	_touch("%s left the tournament" % p["name"])
	if d["state"] != "running":
		return
	_settle()


func _finish(m: Dictionary, side: String) -> void:
	m["winner"] = int(m[side])
	m["loser"] = int(m["b" if side == "a" else "a"])
	m["state"] = "done"


## Fill in whoever is known, settle byes and walkovers, open the next Swiss round or the playoffs, crown the champion.
func _settle() -> void:
	if d["state"] != "running":
		return
	var changed := true
	while changed:
		changed = false
		for m in d["matches"]:
			if m["state"] == "done" or m.get("skip", false):
				continue
			for s in ["a", "b"]:
				var src: Array = m["from_" + s]
				if int(m[s]) == WAIT and src.size() == 2:
					var f := get_match(int(src[1]))
					if f["state"] == "done" or f.get("skip", false):
						m[s] = int(f["winner"] if src[0] == "w" else f["loser"])
						changed = true
			# the grand final's reset: only if the lower-bracket player won the first grand final
			if m.get("reset", false) and int(m["a"]) >= 0 and int(m["b"]) >= 0:
				var gf := get_match(int(m["from_a"][1]))
				if gf["state"] == "done" and int(gf["winner"]) == int(gf["a"]):
					m["skip"] = true
					m["state"] = "done"
					m["winner"] = int(gf["winner"])
					m["loser"] = int(gf["loser"])
					changed = true
					continue
			var a := int(m["a"])
			var b := int(m["b"])
			if a == WAIT or b == WAIT:
				m["state"] = "wait"
				continue
			# a bye or a player who left: the other goes through; nobody at all: nobody goes through
			var a_out := a == NONE or bool(player(a).get("dropped", false))
			var b_out := b == NONE or bool(player(b).get("dropped", false))
			if a_out or b_out:
				if a_out and b_out:
					# nobody to play (two byes, or two who left): nobody goes on from here
					m["winner"] = NONE
					m["loser"] = NONE
					m["state"] = "done"
					m["bye"] = true
				else:
					m["winner"] = b if a_out else a
					m["loser"] = a if a_out else b
					if a != NONE and b != NONE:
						m["walkover"] = true
					else:
						m["bye"] = true
					m["state"] = "done"
				changed = true
				continue
			if m["state"] == "wait":
				m["state"] = "ready"
				changed = true
	# the formats that grow as they go
	if d["format"] == "swiss":
		var now := int(d.get("swiss_now", 1))
		var open := (d["matches"] as Array).any(func(m) -> bool: return m["stage"] == "sw" and m["state"] != "done")
		if not open and now < int(d["swiss_rounds"]):
			_swiss_round(now + 1)
			_settle()
			return
	if d["format"] == "groups" and not d.has("playoffs"):
		var open2 := (d["matches"] as Array).any(func(m) -> bool: return m["stage"] == "grp" and m["state"] != "done")
		if not open2:
			_build_playoffs()
			_settle()
			return
	_maybe_done()


func _build_playoffs() -> void:
	var g := int(d["groups"])
	var k := int(d["advance"])
	var tables: Array = []
	for gi in g:
		tables.append(standings(gi))
	# cross seeding: every group's first, then every group's second in reverse group order, ...
	var ids: Array = []
	for place in k:
		var row: Array = []
		for gi in g:
			if place < (tables[gi] as Array).size():
				row.append(int(tables[gi][place]["id"]))
		if place % 2 == 1:
			row.reverse()
		ids.append_array(row)
	d["playoffs"] = ids
	_build_single(ids, "po")


func _maybe_done() -> void:
	if (d["matches"] as Array).any(func(m) -> bool: return m["state"] != "done"):
		return
	var champ := WAIT
	match String(d["format"]):
		"single":
			champ = int(_last_of("wb")["winner"])
		"groups":
			champ = int(_last_of("po")["winner"])
		"double":
			var reset := _last_of("gf")
			champ = int(reset["winner"])
		_:
			var st := standings()
			champ = int(st[0]["id"]) if not st.is_empty() else WAIT
	d["champion"] = champ
	d["state"] = "done"
	_touch("%s is the champion" % pname(champ))


func _last_of(stage: String) -> Dictionary:
	var best := {}
	for m in d["matches"]:
		if m["stage"] == stage and (best.is_empty() or int(m["round"]) >= int(best["round"])):
			best = m
	return best


# ================================================================== tables

## The standings of the round robin / Swiss / a group (`group` >= 0) as rows {"id", "w", "l", "gw", "gl", "pts",
## "buch", "place"}, best first. Tie-breaks: match wins, then (Swiss) Buchholz, then game difference, then games won,
## then head-to-head between exactly two tied players, then the seed.
func standings(group := -1) -> Array:
	var rows := {}
	var ids: Array = []
	if group >= 0:
		ids = d.get("group_ids", [])[group] if d.has("group_ids") else []
	else:
		ids = players().filter(func(p) -> bool: return int(p["seed"]) > 0).map(func(p) -> int: return int(p["id"]))
	for pid in ids:
		rows[int(pid)] = {"id": int(pid), "w": 0, "l": 0, "gw": 0, "gl": 0, "played": 0, "buch": 0, "byes": 0}
	var opps := {}
	for m in d["matches"]:
		if not (m["stage"] in ["rr", "sw", "grp"]) or m["state"] != "done":
			continue
		if group >= 0 and int(m["group"]) != group:
			continue
		var w := int(m["winner"])
		var l := int(m["loser"])
		if rows.has(w):
			rows[w]["w"] += 1
			rows[w]["played"] += 1
			if l == NONE:
				rows[w]["byes"] += 1
		if rows.has(l):
			rows[l]["l"] += 1
			rows[l]["played"] += 1
		var sc := score(m)
		for s in [["a", 0, 1], ["b", 1, 0]]:
			var pid := int(m[s[0]])
			if rows.has(pid):
				rows[pid]["gw"] += int(sc[s[1]])
				rows[pid]["gl"] += int(sc[s[2]])
				var other := int(m["b" if s[0] == "a" else "a"])
				if other >= 0:
					if not opps.has(pid):
						opps[pid] = []
					opps[pid].append(other)
	for pid in rows:
		var b := 0
		for o in opps.get(pid, []):
			if rows.has(o):
				b += int(rows[o]["w"])
		rows[pid]["buch"] = b
	var out: Array = rows.values()
	var seed_of := func(pid: int) -> int: return int(player(pid).get("seed", 999))
	var swiss: bool = d["format"] == "swiss"
	out.sort_custom(func(x, y) -> bool:
		if x["w"] != y["w"]:
			return x["w"] > y["w"]
		if swiss and x["buch"] != y["buch"]:
			return x["buch"] > y["buch"]
		var dx: int = x["gw"] - x["gl"]
		var dy: int = y["gw"] - y["gl"]
		if dx != dy:
			return dx > dy
		if x["gw"] != y["gw"]:
			return x["gw"] > y["gw"]
		var h := _h2h(int(x["id"]), int(y["id"]))
		if h != 0:
			return h > 0
		return seed_of.call(int(x["id"])) < seed_of.call(int(y["id"])))
	for i in out.size():
		out[i]["place"] = i + 1
	return out


## Head to head: +1 if `a` beat `b` (in the table's matches), -1 if `b` beat `a`, 0 if they did not meet.
func _h2h(a: int, b: int) -> int:
	for m in d["matches"]:
		if m["state"] == "done" and m["stage"] in ["rr", "sw", "grp"] and ((int(m["a"]) == a and int(m["b"]) == b) or (int(m["a"]) == b and int(m["b"]) == a)):
			return 1 if int(m["winner"]) == a else -1
	return 0


## Final places for an elimination bracket: [{"id", "place"}] (the champion 1, the runner-up 2, then by how far each
## got; players knocked out in the same round share the place).
func placings() -> Array:
	if d["format"] in ["robin", "swiss"]:
		return standings().map(func(s) -> Dictionary: return {"id": s["id"], "place": s["place"]})
	var out_at := {}     # pid -> how far (bigger = later)
	var order := {}
	var n := 0
	for m in d["matches"]:
		order[int(m["id"])] = n
		n += 1
	for m in d["matches"]:
		if m["state"] != "done" or m.get("skip", false):
			continue
		var l := int(m["loser"])
		if l < 0:
			continue
		var eliminating: bool = m["stage"] in ["lb", "po", "gf"] or d["format"] == "single"
		if m["stage"] == "gf" and not m.get("reset", false):
			eliminating = int(m["loser"]) == int(m["b"])      # (the upper-bracket player who loses the first final plays the reset)
		if eliminating:
			out_at[l] = _depth(m)
	var ids: Array = out_at.keys()
	ids.sort_custom(func(x, y) -> bool: return out_at[x] > out_at[y])
	var res: Array = []
	if int(d["champion"]) >= 0:
		res.append({"id": int(d["champion"]), "place": 1})
	var place := 2
	var i := 0
	while i < ids.size():
		var j := i
		while j < ids.size() and out_at[ids[j]] == out_at[ids[i]]:
			j += 1
		for k in range(i, j):
			res.append({"id": ids[k], "place": place})
		place += j - i
		i = j
	return res


func _depth(m: Dictionary) -> int:
	match String(m["stage"]):
		"gf":
			return 1000 + int(m["round"])
		"lb":
			return 100 + int(m["round"]) * 2
		"po", "wb":
			return 100 + int(m["round"]) * 2 + (1 if d["format"] == "single" or m["stage"] == "po" else 0)
	return int(m["round"])


## A short name for a match's place in the bracket ("Winners' round 2", "Grand final"...).
func match_label(m: Dictionary) -> String:
	match String(m["stage"]):
		"wb":
			if d["format"] == "single":
				return _round_name(m, "wb", "Round %d")
			return _round_name(m, "wb", "Upper round %d", "Upper final")
		"lb":
			return _round_name(m, "lb", "Lower round %d", "Lower final")
		"gf":
			return "Grand final (reset)" if m.get("reset", false) else "Grand final"
		"po":
			return _round_name(m, "po", "Playoff round %d")
		"rr":
			return "Round %d" % int(m["round"])
		"sw":
			return "Swiss round %d" % int(m["round"])
		"grp":
			return "Group %s, round %d" % [char(65 + int(m["group"])), int(m["round"])]
	return ""


func _round_name(m: Dictionary, stage: String, fmt: String, last := "") -> String:
	var top := 0
	for x in d["matches"]:
		if x["stage"] == stage:
			top = maxi(top, int(x["round"]))
	var r := int(m["round"])
	if stage != "lb" and (d["format"] == "single" or stage == "po"):
		if r == top:
			return "Final"
		if r == top - 1:
			return "Semi-finals"
		if r == top - 2:
			return "Quarter-finals"
	if r == top and last != "":
		return last
	return fmt % r


## The rounds of a stage, for drawing: [[match, ...], ...] by round (empty rounds left out).
func rounds_of(stage: String, group := -1) -> Array:
	var by := {}
	for m in d["matches"]:
		if m["stage"] == stage and (group < 0 or int(m["group"]) == group):
			var r := int(m["round"])
			if not by.has(r):
				by[r] = []
			by[r].append(m)
	var keys: Array = by.keys()
	keys.sort()
	var out: Array = []
	for k in keys:
		var col: Array = by[k]
		col.sort_custom(func(x, y) -> bool: return int(x["pos"]) < int(y["pos"]))
		out.append(col)
	return out


## The matches a player still has to play (ready ones first).
func matches_of(pid: int) -> Array:
	return (d["matches"] as Array).filter(func(m) -> bool: return int(m["a"]) == pid or int(m["b"]) == pid)


## Every game played, for the tables of the report: [{"match", "game", ...}].
func all_games() -> Array:
	var out: Array = []
	for m in d["matches"]:
		for gi in (m["games"] as Array).size():
			var g: Dictionary = m["games"][gi]
			if g["how"] == "set":
				continue
			var row: Dictionary = g.duplicate()
			row["match"] = int(m["id"])
			row["game"] = gi
			row["pa"] = int(m["a"])
			row["pb"] = int(m["b"])
			row["stage"] = m["stage"]
			out.append(row)
	return out


func side_of(m: Dictionary, pid: int) -> String:
	if int(m["a"]) == pid:
		return "a"
	if int(m["b"]) == pid:
		return "b"
	return ""


# ================================================================== reports (online: both players say who won)

## A player's report of a game ("a"/"b" won). The match takes it at once when the loser says so (or both agree); a
## winner's word alone waits for the other or the organiser; two different words make a dispute for the organiser.
## Returns "taken", "waiting" or "dispute".
func player_report(mid: int, pid: int, win: String, info := {}) -> String:
	var m := get_match(mid)
	if m.is_empty() or m["state"] == "done":
		return "taken"
	var side := side_of(m, pid)
	if side == "":
		return "waiting"
	var gi: int = (m["games"] as Array).size()
	if int(info.get("game", gi)) != gi:
		return "taken"      # (that game is already in)
	m["reports"][side] = {"win": win, "info": info}
	var other := "b" if side == "a" else "a"
	if win != side:
		report_game(mid, win, info)      # the loser says they lost: that is enough
		return "taken"
	if (m["reports"] as Dictionary).has(other):
		var ow: String = m["reports"][other]["win"]
		if ow == win:
			report_game(mid, win, info)
			return "taken"
		m["dispute"] = "%s and %s both say they won game %d" % [pname(int(m["a"])), pname(int(m["b"])), gi + 1]
		_touch("Dispute: " + String(m["dispute"]))
		return "dispute"
	_touch()
	return "waiting"


## The organiser accepts a waiting report as it is (the other player never reported).
func accept_report(mid: int) -> bool:
	var m := get_match(mid)
	if m.is_empty() or (m["reports"] as Dictionary).size() != 1:
		return false
	var only: Dictionary = (m["reports"] as Dictionary).values()[0]
	return report_game(mid, String(only["win"]), only["info"])


## The computers' bans and map picks in every match ready now (by the tournament's dice: a computer has no favourite
## map). Returns true if anything changed.
func computer_turns() -> bool:
	var any := false
	for m in ready_matches():
		for _i in 4:
			var bt := ban_turn(m)
			var pt := pick_turn(m)
			var side := bt if bt != "" else pt
			if side == "" or String(player(int(m[side])).get("who", "human")) == "human":
				break
			var open := open_maps(m)
			if bt != "":
				var r := rng_for("ban:%d:%d" % [int(m["id"]), (m["bans"] as Array).size()])
				ban(m, side, String(open[r.randi_range(0, open.size() - 1)]))
			else:
				var played: Array = (m["games"] as Array).map(func(g) -> String: return String(g["map"]))
				var fresh: Array = open.filter(func(x) -> bool: return not played.has(x))
				if fresh.is_empty():
					fresh = open
				var r2 := rng_for("pick:%d:%d" % [int(m["id"]), (m["games"] as Array).size()])
				pick(m, side, String(fresh[r2.randi_range(0, fresh.size() - 1)]))
			any = true
	return any


## Which side starts in the first start spot (slot 0) in a game: the higher seed in odd games, the other in even ones,
## so neither player keeps the same spot all series.
func swap_spots(m: Dictionary, gi: int) -> bool:
	return (gi + int(m["id"])) % 2 == 1


## A room code for a game of a match (the relay takes 3-12 letters): the tournament code, M, the match, the game.
func room_code(m: Dictionary) -> String:
	return ("%sM%s%d" % [d["id"], _b36(int(m["id"])), (m["games"] as Array).size() + 10 * int(m.get("replays", 0))]).substr(0, 12)


static func _b36(n: int) -> String:
	var abc := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	if n == 0:
		return "0"
	var s := ""
	while n > 0:
		s = abc[n % 36] + s
		n /= 36
	return s


## A slimmer copy to send to players (no secret keys).
func public_dict() -> Dictionary:
	var c := d.duplicate(true)
	for p in c["players"]:
		p.erase("key")
	return c


## Is the tournament over?
func done() -> bool:
	return d["state"] == "done"
