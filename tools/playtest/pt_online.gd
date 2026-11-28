extends "res://tools/playtest/pt_base.gd"
## PLAYTEST, ONLINE (job playtest-menus-online): several copies of the game on one computer through the local relay,
## each driven by real clicks and keys from the main menu. tools/playtest/online.sh starts the relay and the copies.
##   role:host | guest | spec | third | wrong | rejoin    sync:<dir> (the copies leave notes there: the room code...)
##   relay:ws://127.0.0.1:8797   scen:basic | host_leave | guest_drop    secs:<match seconds to play>
## A note is a file in the sync folder; a copy waits for another's note (until()).

var role := "host"
var sync := ""
var relay := ""
var scen := "basic"
var secs := 70.0
var hud: Control
var t0 := 0.0


func play() -> void:
	role = String(args.get("role", "host"))
	sync = String(args.get("sync", "/tmp/pt_online"))
	relay = String(args.get("relay", "ws://127.0.0.1:8797"))
	scen = String(args.get("scen", "basic"))
	secs = float(args.get("secs", 70))
	DirAccess.make_dir_recursive_absolute(sync)
	tag = role + "_" + tag
	await start_main()
	if role == "chost":
		await campaign_host()
		note(role + "_done")
		return
	await to_online()
	match role:
		"host":
			await host()
		"guest", "rejoin":
			await guest()
		"cguest":
			await campaign_guest()
		"spec":
			await spectator()
		"third":
			await third()
		"wrong":
			await wrong_code()
	note(role + "_done")


# ------------------------------------------------------------------ notes between the copies

func note(n: String, text := "x") -> void:
	var f := FileAccess.open(sync + "/" + n, FileAccess.WRITE)
	f.store_string(text)
	f.close()
	print("PT NOTE-OUT %s" % n)


func has_note(n: String) -> bool:
	return FileAccess.file_exists(sync + "/" + n)


func read_note(n: String) -> String:
	return FileAccess.get_file_as_string(sync + "/" + n).strip_edges() if has_note(n) else ""


func until(n: String, timeout := 120.0) -> bool:
	var t := 0.0
	while not has_note(n):
		await wait(0.25)
		t += 0.25
		if t > timeout:
			print("PT TIMEOUT waiting for note %s" % n)
			return false
	return true


# ------------------------------------------------------------------ the pages

func lobby() -> NetLobby:
	return main.net_lobby


func to_online() -> void:
	await tap(main.menu_open("online"))
	await wait(0.5)
	await look("online_entry")
	# the relay address: tapped, all of it selected, the local relay typed in (as a tester would)
	var re: LineEdit = null
	for c in all_controls("LineEdit"):
		if (c as LineEdit).placeholder_text.begins_with("wss://"):
			re = c
	if re == null:
		find("BUG", "online", "no relay address box")
		return
	await tap(re)
	await key_tap(KEY_A, false, true)
	await type_text(relay)
	await key_tap(KEY_ENTER)
	await wait(0.3)
	if Settings.relay_url != relay:
		find("BUG", "online", "relay typed '%s' but Settings has '%s'" % [relay, Settings.relay_url])


func code_box() -> LineEdit:
	for c in all_controls("LineEdit"):
		if (c as LineEdit).placeholder_text == "ROOM CODE" or (c as LineEdit).max_length == 12:
			return c
	return null


func room_code_on_screen() -> String:
	for c in all_controls("Label"):
		var t := shown(c)
		if t.begins_with(Loc.t("ROOM") + "  "):
			return t.substr((Loc.t("ROOM") + "  ").length()).strip_edges()
	return ""


func status_line() -> String:
	return lobby().status if lobby() else "(no room)"


## A dropdown of a slot row: the n-th button whose text is one of `choices`, opened, then `pick` chosen in its list.
func pick_in_row(row_i: int, choices: Array, pick: String) -> bool:
	var found: Array = []
	for b in buttons():
		var t := shown(b).replace(" ▼", "").replace("▼", "").strip_edges()
		for ch in choices:
			if t == Loc.t(ch):
				found.append(b)
				break
	found.sort_custom(func(a: Control, b: Control) -> bool: return screen_rect(a).position.y < screen_rect(b).position.y)
	if row_i >= found.size():
		print("PT MISS dropdown row %d of %s (found %d)" % [row_i, str(choices), found.size()])
		return false
	await tap(found[row_i])
	await wait(0.4)
	await look("dropdown_open_" + pick.to_lower().replace(" ", "_"))
	var opt: BaseButton = null
	for b in buttons():
		var t := shown(b).strip_edges().replace("√", "").strip_edges()
		if t == Loc.t(pick):
			opt = b
	if opt == null:
		print("PT MISS option %s; there are %s" % [pick, str(button_texts()).substr(0, 300)])
		await key_tap(KEY_ESCAPE)
		return false
	await tap(opt)
	await wait(0.5)
	return true


# ------------------------------------------------------------------ the HUD in a match

func hud_point(local: Vector2) -> Vector2:
	return root.get_final_transform() * hud.get_global_transform_with_canvas() * local


func hud_tap(r: Rect2) -> void:
	await tap_at(hud_point(r.get_center()))


func menu_item(label: String) -> Dictionary:
	for b in hud._menu_buttons():
		if String(b["label"]).begins_with(label):
			return b
	return {}


func wait_match(timeout := 90.0) -> bool:
	var t := 0.0
	while main.game == null or main.game.hud == null:
		await wait(0.25)
		t += 0.25
		if t > timeout:
			return false
	hud = main.game.hud
	t0 = Time.get_ticks_msec() / 1000.0
	return true


func say(text: String) -> void:
	if device == "mobile":
		return              # (a phone has no typing box: its quick-chat buttons instead)
	await key_tap(KEY_ENTER)
	await wait(0.2)
	if not hud.chat_typing:
		find("BUG", role, "Enter did not open the chat box in an online match")
		return
	await type_text(text)
	await key_tap(KEY_ENTER)
	await wait(0.3)


## A minute of playing like a person: the hall picked by a click near the screen middle, a worker trained by its key,
## a right click to send what is selected, the camera moved by keys, the chat used.
func play_some(seconds: float) -> void:
	var vs := Vector2(DisplayServer.window_get_size())
	var end := Time.get_ticks_msec() / 1000.0 + seconds
	var n := 0
	while Time.get_ticks_msec() / 1000.0 < end and main.game != null:
		match n % 6:
			0:
				await click_at(vs * Vector2(0.5, 0.45))
			1:
				await key_tap(KEY_Q)            # the card's first button by position or name: whatever it trains
			2:
				await click_at(vs * Vector2(0.42 + rng.randf() * 0.2, 0.35 + rng.randf() * 0.2), MOUSE_BUTTON_RIGHT)
			3:
				await key_tap(KEY_SPACE)
			4:
				key(KEY_UP if rng.randf() < 0.5 else KEY_LEFT, true)
				await wait(0.3)
				key(KEY_UP, false)
				key(KEY_LEFT, false)
			5:
				await wait(1.0)
		n += 1
		await wait(0.6)


func room_state() -> String:
	var l := lobby()
	if l == null:
		return "(no room)"
	var f: Array = []
	for sl in l.slots:
		f.append(String(sl.get("faction", "?")))
	return "map %s mode %s factions %s" % [l.map, l.mode, str(f)]


func chat_lines() -> String:
	if main.game == null or main.game.chat == null:
		return "(no chat)"
	var t: Array = []
	for ln in main.game.chat.lines:
		t.append("%s: %s" % [String(ln.get("name", "")), String(ln.get("text", ""))])
	return str(t)


func net_line() -> String:
	var g: Game = main.game
	if g == null or g.net == null:
		return "(no match)"
	var s: NetSession = g.net
	return "clock %.1f ping %s" % [g.clock, str(s.get("ping_ms")) if "ping_ms" in s else "?"]


# ------------------------------------------------------------------ host

func host() -> void:
	if not await press("HOST A GAME"):
		return
	for i in 40:
		await wait(0.25)
		if room_code_on_screen() != "" and lobby() and lobby().online:
			break
	var code := room_code_on_screen()
	print("PT host room code '%s' status '%s'" % [code, status_line()])
	await look("room_open")
	if code == "":
		find("BUG", "host", "no room code shown after HOST A GAME (status: %s)" % status_line())
		return
	note("code", code)
	await press("COPY", 0.3)
	if DisplayServer.clipboard_get() != code:
		print("PT NOTE clipboard after COPY '%s' (the virtual screen may have no clipboard)" % DisplayServer.clipboard_get())
	# my own faction: CROWN
	await pick_in_row(0, ["RANDOM", "CROWN", "BROOD", "CLOCKWORK"], "CROWN")
	if not await until("guest_seated", 120):
		find("BUG", "host", "the guest never got a seat (status: %s)" % status_line())
		await look("no_guest")
		return
	await wait(1.0)
	await look("room_with_guest")
	print("PT host sees: %s | %s" % [status_line(), lobby().ping_text()])
	if lobby().ping_text() == "":
		find("UX", "room", "no ping shown with the friend seated")
	# CO-OP and back, the map stepped once
	await press("CO-OP", 0.6)
	await look("room_coop")
	await press("1v1", 0.6)
	await press(">", 0.5, true)
	await look("room_map_next")
	if not await until("guest_ready", 90):
		return
	if scen == "full":
		await until("third_done", 120)
		await look("room_after_third")
	if has_note("spec_watching") or scen == "spec":
		await until("spec_watching", 60)
		await wait(1.0)
		await look("room_with_spec")
	await wait(1.0)
	print("PT host room at START: %s" % room_state())
	note("host_room", room_state())
	if not await press("START", 0.3, true):
		find("BUG", "host", "START not pressable: %s" % lobby().problem())
		return
	if not await wait_match():
		find("BUG", "host", "START pressed, no match")
		return
	note("started")
	await wait(4.0)
	await look("match_begin")
	await say("hello from the host! çãé")
	await play_some(secs * 0.5)
	await look("match_mid")
	print("PT host mid %s" % net_line())
	match scen:
		"host_leave":
			await hud_tap(hud.menu_rect())
			await wait(0.4)
			await look("host_menu")
			var q := menu_item("QUIT TO MENU")
			await hud_tap(q["rect"])
			await wait(0.4)
			await look("host_quit_ask")
			var y := menu_item("YES")
			if y.is_empty():
				find("BUG", "host", "online QUIT TO MENU did not ask first")
			else:
				await hud_tap(y["rect"])
			await wait(1.5)
			note("host_left")
			await look("host_after_leave")
		"guest_drop":
			await until("guest_dropped", 120)
			for i in 8:
				await wait(2.5)
				print("PT host after drop %s" % net_line())
			await look("host_guest_gone")
			if has_note("rejoin_seated") or await until("rejoin_seated", 90):
				await wait(5.0)
				await look("host_after_rejoin")
			await play_some(15)
		_:
			await play_some(secs * 0.5)
			await look("match_end")
	print("PT host end %s" % net_line())
	print("PT host chat %s" % chat_lines())
	await until("guest_done", 90)


# ------------------------------------------------------------------ guest

func guest() -> void:
	if not await until("code", 120):
		return
	var code := read_note("code")
	var box := code_box()
	await tap(box)
	await type_text(code.to_lower())        # typed in small letters: the box makes them capitals
	await wait(0.2)
	if box.text != code:
		find("BUG", "join", "typed '%s', the box shows '%s'" % [code.to_lower(), box.text])
	await look("join_typed")
	if not await press("JOIN"):
		return
	for i in 60:
		await wait(0.25)
		if lobby() and lobby().online:
			break
	await look("joined")
	print("PT %s joined: %s | %s" % [role, status_line(), lobby().ping_text() if lobby() else ""])
	if lobby() == null or not lobby().online:
		find("BUG", "join", "not seated after 15 s: %s" % status_line())
		return
	if role == "rejoin":
		note("rejoin_seated")
		await wait(2.0)
		await look("rejoin_room")
		print("PT rejoin sees: %s | game %s" % [status_line(), main.game != null])
		await wait(4.0)
		print("PT rejoin 6 s on: %s refused '%s'" % [status_line(), lobby().refused if lobby() else ""])
		await look("rejoin_room_later")
		if await wait_match(30):
			await wait(5.0)
			await look("rejoin_match")
			await play_some(10)
		return
	note("guest_seated")
	await pick_in_row(0, ["RANDOM", "CROWN", "BROOD", "CLOCKWORK"], "CLOCKWORK")     # (the host's row is not the guest's to change)
	# the colour: the host's colour first (taken), then another
	await look("guest_room")
	note("guest_ready")
	if not await wait_match(180):
		find("BUG", "guest", "the match never started on the guest's side")
		return
	await wait(4.0)
	await look("match_begin")
	await say("hi host, guest here")
	await play_some(secs * 0.5)
	await look("match_mid")
	print("PT guest mid %s" % net_line())
	match scen:
		"guest_drop":
			note("guest_dropped")
			print("PT guest drops out (online.sh kills this program: no goodbye to anyone)")
			await wait(600.0)
			return
		"host_leave":
			await until("host_left", 120)
			for i in 12:
				await wait(2.5)
				print("PT guest after host left: game %s over %s gone '%s' %s" % [main.game != null, main.game.over if main.game else "-", main.game.net.gone_why if main.game and main.game.net else "-", net_line()])
			await look("guest_after_host_left")
		_:
			await play_some(secs * 0.5)
			await look("match_end")
	print("PT guest end %s" % net_line())
	print("PT guest chat %s" % chat_lines())


# ------------------------------------------------------------------ the others

func spectator() -> void:
	if not await until("guest_seated", 150):
		return
	var code := read_note("code")
	await tap(code_box())
	await type_text(code)
	if not await press("WATCH"):
		return
	for i in 60:
		await wait(0.25)
		if lobby() and lobby().online:
			break
	await look("spec_room")
	print("PT spec room: %s spectating=%s" % [status_line(), lobby().spectating if lobby() else false])
	note("spec_watching")
	await wait(8.0)
	await look("spec_room_later")
	print("PT spec room 8 s later: %s" % room_state())
	if not await wait_match(180):
		find("BUG", "spec", "the spectator never saw the match start")
		return
	await wait(5.0)
	await look("spec_match")
	await say("spectator says hi")
	await wait(3.0)
	await look("spec_after_say")
	print("PT spec room at start (host's): %s" % read_note("host_room"))
	await wait(secs * 0.5)
	await look("spec_match_late")
	print("PT spec chat %s" % chat_lines())


func third() -> void:
	if not await until("guest_ready", 150):
		return
	await tap(code_box())
	await type_text(read_note("code"))
	await press("JOIN")
	for i in 40:
		await wait(0.25)
		if lobby() and (lobby().online or lobby().refused != ""):
			break
	await wait(1.0)
	await look("third_in_full_room")
	print("PT third: status '%s' refused '%s' spectating %s" % [status_line(), lobby().refused if lobby() else "", lobby().spectating if lobby() else false])


func wrong_code() -> void:
	await tap(code_box())
	await type_text("ZQZQ")
	await press("JOIN")
	await wait(3.0)
	await look("wrong_code_3s")
	await wait(12.0)
	await look("wrong_code_15s")
	print("PT wrong code: status '%s' online %s refused '%s'" % [status_line(), lobby().online if lobby() else false, lobby().refused if lobby() else ""])
	# a code too short: JOIN does nothing?
	if await press("LEAVE", 0.5, true) or await press("BACK", 0.5, true):
		pass
	await to_online_again()
	var box := code_box()
	if box:
		await tap(box)
		await type_text("AB")
		await press("JOIN")
		await wait(1.0)
		await look("short_code")
		print("PT short code: lobby %s, buttons %s" % [lobby() != null, str(button_texts()).substr(0, 200)])


func to_online_again() -> void:
	if main.on_menu():
		await tap(main.menu_open("online"))
		await wait(0.5)


# ------------------------------------------------------------------ a campaign mission played by two (CO-OP / VERSUS)

func set_relay_in_settings() -> void:
	# the relay is typed in Settings > GAMEPLAY > ONLINE RELAY ADDRESS (the campaign's room uses the saved one)
	await tap(main.menu_open("settings"))
	await wait(0.4)
	var re: LineEdit = null
	for c in all_controls("LineEdit"):
		re = c
	await tap(re)
	await key_tap(KEY_A, false, true)
	await type_text(relay)
	await key_tap(KEY_ESCAPE)
	await wait(0.4)
	if not main.on_menu():
		await key_tap(KEY_ESCAPE)
		await wait(0.4)


func campaign_host() -> void:
	await set_relay_in_settings()
	await tap(main.menu_open("campaign"))
	await wait(0.8)
	if not await press("WAR TABLE"):
		return
	await look("war_table")
	if find_button("LIST", true) != null:          # (the war table opens on the war map; LIST shows the missions)
		await press("LIST", 0.6, true)
		await look("war_table_list")
	var md := "coop" if scen == "coop" else "versus"
	var mb := find_button("Mode_" + md, true)
	if mb == null or mb.disabled:
		find("BUG", "campaign online", "no %s mode for the first mission" % md)
		return
	await tap(mb)
	await wait(0.5)
	await look("war_table_" + md)
	if not await press("Campaign_Go", 0.5, true):
		return
	for i in 40:
		await wait(0.25)
		if room_code_on_screen() != "" and lobby() and lobby().online:
			break
	var code := room_code_on_screen()
	await look("campaign_room")
	print("PT chost room '%s': %s" % [code, status_line()])
	if code == "":
		find("BUG", "campaign online", "no room code (status %s)" % status_line())
		return
	note("code", code)
	if not await until("guest_ready", 150):
		return
	await wait(1.5)
	await look("campaign_room_full")
	if not await press("START", 0.3, true):
		find("BUG", "campaign online", "START not pressable: %s" % lobby().problem())
		return
	if not await wait_match(120):
		find("BUG", "campaign online", "no match after START")
		return
	note("started")
	await wait(3.0)
	await look("campaign_match_begin")
	# the opening's lines: SKIP if offered
	await press("SKIP", 0.8, true)
	await look("campaign_match_skipped")
	await play_some(secs * 0.6)
	await look("campaign_match_mid")
	print("PT chost mid %s chat %s" % [net_line(), chat_lines()])
	await until("cguest_done", 120)


func campaign_guest() -> void:
	if not await until("code", 200):
		return
	var box := code_box()
	await tap(box)
	await type_text(read_note("code"))
	if not await press("JOIN"):
		return
	for i in 60:
		await wait(0.25)
		if lobby() and lobby().online:
			break
	await wait(1.0)
	await look("campaign_guest_room")
	print("PT cguest room: %s" % status_line())
	note("guest_ready")
	if not await wait_match(200):
		find("BUG", "campaign online", "the guest's mission never started")
		return
	await wait(3.0)
	await look("campaign_guest_begin")
	await press("SKIP", 0.8, true)
	await play_some(secs * 0.6)
	await look("campaign_guest_mid")
	print("PT cguest mid %s" % net_line())
