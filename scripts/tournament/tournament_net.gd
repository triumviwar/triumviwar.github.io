class_name TournamentNet
extends Node
## TOURNAMENTS ONLINE (docs/tournament.md "Online"): no server of our own. The organiser's game holds the bracket and
## keeps a DESK open: a room on the same relay as the friendly rooms, its code "T" + the tournament's code. A player's
## game calls at the desk for a moment (join, check in, report a result, ban a map, choose a faction, or just look) and
## leaves again: the relay seats 7 guests in a room at a time, and a quick call keeps the desk free for 64 players.
## Each call gets the whole bracket back (no secret keys in it). A player's place is kept by a secret key the desk gave
## it when it joined (saved on its device), so the desk knows it again from another connection.
## The matches themselves are friendly rooms (NetLobby), their codes from the bracket (Tournament.room_code).

signal updated                       # the tournament changed (the desk's own, or a player's fresh copy)
signal answered(ok: bool, why: String)   # a player's call is over (ok: the desk answered)

const DESK_PREFIX := "T"
const CALL_TIMEOUT := 14.0
const FULL_RETRY := 2.0

var t: Tournament                    # desk: the tournament; player: the last copy the desk sent
var desk := false
var link: NetLink
var me := -1                         # player: my player id (-1: watching only; a team tournament: my team's id)
var mi := 0                          # player: my place in my team (0 in a 1v1 tournament)
var key := ""                        # player: my secret
var relay := ""
var status := ""
var _pending := {}                   # player: the call being made
var _timer := 0.0
var _busy := false
var _retries := 0


static func desk_code(tid: String) -> String:
	return DESK_PREFIX + tid.to_upper()


# ------------------------------------------------------------------ the desk (the organiser)

func open_desk(relay_url: String, tour: Tournament) -> void:
	desk = true
	t = tour
	relay = relay_url
	_connect(true)


func _connect(as_host: bool) -> void:
	if link:
		# (the old connection's own close must not end the new call: its signals are let go first)
		for sg in [["opened", _on_opened], ["message", _on_message], ["notice", _on_notice], ["closed", _on_closed]]:
			if link.is_connected(sg[0], sg[1]):
				link.disconnect(sg[0], sg[1])
		link.close("again")
		link.queue_free()
	link = NetLink.new()
	add_child(link)
	link.opened.connect(_on_opened)
	link.message.connect(_on_message)
	link.notice.connect(_on_notice)
	link.closed.connect(_on_closed)
	link.open(relay, desk_code(String(t.d["id"]) if t else String(_pending.get("tid", ""))), as_host)
	status = "Opening the desk..." if as_host else "Calling the desk..."


func close_desk() -> void:
	if link:
		link.close("bye")
	desk = false


func _on_opened(_id: int) -> void:
	if desk:
		status = Loc.t("The desk is open: players join with the code %s.") % t.d["id"]
		updated.emit()
	else:
		link.send(_pending)


func _on_notice(_d: Dictionary) -> void:
	pass         # (a refusal, "The room is full.", is followed by the close: _on_closed waits and calls again)


func _on_closed(why: String) -> void:
	if desk:
		status = Loc.t("The desk closed (%s). It opens again in a few seconds.") % Loc.t(why)
		updated.emit()
		get_tree().create_timer(4.0, true, false, true).timeout.connect(func() -> void:
			if desk and is_inside_tree():
				_connect(true))
	elif _busy:
		if why.contains("full"):
			_retry_full()
		else:
			_end_call(false, why)


func _retry_full() -> void:
	_retries += 1
	if _retries > 8:
		_end_call(false, "The desk is busy. Try again in a moment.")
		return
	status = "The desk is busy, waiting a moment..."
	get_tree().create_timer(FULL_RETRY + randf(), true, false, true).timeout.connect(func() -> void:
		if _busy and is_inside_tree():
			_connect(false))


## The desk: a player's call.
func _on_message(from: int, m: Dictionary) -> void:
	if not desk:
		if String(m.get("t", "")) == "ts":
			var c := Tournament.from_dict(m["d"])
			t = c
			if int(m.get("you", -1)) >= 0:
				me = int(m["you"])
				mi = int(m.get("mi", 0))
			if String(m.get("key", "")) != "":
				key = String(m["key"])
			_save_joined()
			updated.emit()
			_end_call(true, String(m.get("why", "")))
		return
	var why := handle(m)
	link.send({"t": "ts", "d": t.public_dict(), "you": int(_last_pid), "mi": _last_mi, "key": _last_key, "why": why}, from)
	t.save()
	updated.emit()


var _last_pid := -1
var _last_key := ""
var _last_mi := 0


## The desk's rules for one call (also used directly by the organiser's own game and the tests). Returns "" or a
## refusal / the report's state ("waiting", "dispute").
func handle(m: Dictionary) -> String:
	_last_pid = -1
	_last_key = ""
	_last_mi = 0
	# (a player, or a team's member, is known by its secret key alone: a drawn team's members got a new entry id at the
	# start, docs/tournament_formats.md)
	var mk := t.member_by_key(String(m.get("key", "")))
	var known := not mk.is_empty()
	var pid := int(mk[0]) if known else -1
	var mix := int(mk[1]) if known else 0
	if known:
		_last_pid = pid
		_last_mi = mix
		_last_key = String(m["key"])
	if String(m.get("ver", "")) != "" and String(m.get("ver", "")) != String(ProjectSettings.get_setting("application/config/version", "dev")):
		return "The organiser plays version %s: both need the same version." % ProjectSettings.get_setting("application/config/version", "dev")
	match String(m.get("t", "")):
		"tj":
			if known or String(m.get("name", "")) == "":
				return ""      # (a known player or a spectator looks at the bracket)
			if t.d["state"] != "signup":
				return "The tournament has already started."
			if t.players().size() >= Tournament.MAX_PLAYERS:
				return "The tournament is full."
			var nm := String(m["name"]).strip_edges()
			for q in t.players():
				for mb in t.members(q):
					if String(mb["name"]).to_lower() == nm.to_lower():
						return "That name is taken in this tournament."
			var fac := String(m.get("fac", "random"))
			fac = fac if (fac in Tournament.FACTIONS or fac == "random") else "random"
			if t.team_size() > 1 and String(t.d.get("team_rule", "fixed")) == "fixed":
				# a TEAM tournament: join a team by its name (made if new)
				var tn := String(m.get("team", "")).strip_edges()
				if tn == "":
					return "Type your team's name (the same for everyone in the team)."
				var jt := t.join_team(tn, nm, fac, "human")
				if jt.is_empty():
					return "That team is full, or its name is taken."
				_last_pid = int(jt[0])
				_last_mi = int(jt[1])
				_last_key = String(jt[2])
				return "ok joined"
			var np := t.add_player(nm, fac, "human")
			_last_pid = np
			_last_key = String(t.player(np)["key"])
			return "ok joined"
		"tci":
			if not known:
				return "You are not in this tournament."
			t.check_in_member(pid, mix, true)
			return "ok"
		"tl":
			if not known:
				return "You are not in this tournament."
			if t.d["state"] == "signup":
				if t.player(pid).has("members"):
					t.leave_team(pid, mix)
				else:
					t.remove_player(pid)
			else:
				t.drop(pid)
			return "ok"
		"tr", "tb", "tp", "tf":
			if not known:
				return "You are not in this tournament."
			var mt := t.get_match(int(m.get("mid", -1)))
			if mt.is_empty():
				return "No such match."
			var side := t.side_of(mt, pid)
			if side == "":
				return "That is not your match."
			match String(m["t"]):
				"tr":
					var info: Dictionary = m.get("info", {}) if m.get("info", {}) is Dictionary else {}
					return t.player_report(int(mt["id"]), pid, String(m.get("win", "")), info)
				"tb":
					return "ok" if t.ban(mt, side, String(m.get("map", ""))) else "Not your ban now, or not a map in the pool."
				"tp":
					return "ok" if t.pick(mt, side, String(m.get("map", ""))) else "Not your pick now."
				"tf":
					return "ok" if t.choose_faction(mt, side, String(m.get("fac", ""))) else "That faction can't be played now."
	return ""


# ------------------------------------------------------------------ a player's calls

## Call the desk of tournament `tid` with `msg` (its "t" and fields; the player's id and key are added).
func call_desk(relay_url: String, tid: String, msg: Dictionary) -> void:
	relay = relay_url
	var m := msg.duplicate()
	m["pid"] = me
	m["key"] = key
	m["ver"] = ProjectSettings.get_setting("application/config/version", "dev")
	m["tid"] = tid
	_pending = m
	_busy = true
	_retries = 0
	_timer = CALL_TIMEOUT
	if t == null or String(t.d.get("id", "")) != tid:
		t = null
	_connect(false)


func _process(delta: float) -> void:
	if _busy and not desk:
		_timer -= delta
		if _timer <= 0.0:
			_end_call(false, "The desk did not answer. Is the organiser's game open?")


func _end_call(ok: bool, why: String) -> void:
	if not _busy:
		return
	_busy = false
	if link:
		link.close("done")
	status = why
	answered.emit(ok, why)


func busy() -> bool:
	return _busy


## A player's own record of a tournament it joined (its id and key), on this device.
func _save_joined() -> void:
	if t == null:
		return
	joined_save(String(t.d["id"]), {"me": me, "mi": mi, "key": key, "relay": relay, "name": String(t.d.get("name", "")), "copy": t.d})


static func joined_save(tid: String, rec: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute("user://tournaments/joined")
	var f := FileAccess.open("user://tournaments/joined/%s.json" % tid, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(rec))


static func joined_load(tid: String) -> Dictionary:
	var s := FileAccess.get_file_as_string("user://tournaments/joined/%s.json" % tid)
	var j = JSON.parse_string(s) if s != "" else null
	return j if j is Dictionary else {}


static func joined_list() -> Array:
	var out: Array = []
	var da := DirAccess.open("user://tournaments/joined")
	if da == null:
		return out
	for fn in da.get_files():
		if fn.ends_with(".json"):
			var r := joined_load(fn.get_basename())
			if not r.is_empty():
				r["tid"] = fn.get_basename()
				out.append(r)
	return out
