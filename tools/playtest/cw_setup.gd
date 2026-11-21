extends RefCounted
## From the first screen to a running match, by input only (job playtest-skirmish-clockwork): the device page (when the
## settings are new), the language flag, the main menu's SKIRMISH, the 1v1 quick set-up, every slot's dropdowns
## (who / faction / colour / plan / team), the map list, START. Returns the Game once its countdown is over.

const IN := preload("res://tools/playtest/cw_input.gd")

var io
var main: Node
var phone := false


func _init(input, m: Node, is_phone: bool) -> void:
	io = input
	main = m
	phone = is_phone


func press(text: String, exact := false) -> bool:
	return await io.press(text, phone, exact)


## Open a dropdown (the button `b`) and pick the row whose text is `row`.
func pick(b: BaseButton, row: String) -> bool:
	if b == null:
		io.note("pick '%s': no dropdown" % row)
		return false
	if phone:
		await io.tap(io.centre(b))
	else:
		await io.click(io.centre(b))
	await io.frames(3)
	# the list's rows start with "√  " or five spaces
	var want := row.to_upper()
	for r in io.buttons():
		if not (r is Button):
			continue
		var t: String = (r as Button).text.replace("√", "").strip_edges().to_upper()
		if (t == want or (want.length() > 4 and t.begins_with(want + " ("))) and not r.disabled:
			var p: Vector2 = io.centre(r)
			if not Rect2(Vector2.ZERO, io.vs()).has_point(p):
				# a long list: scroll it with the wheel until the row shows
				var sc := r.get_parent().get_parent() as ScrollContainer
				if sc:
					for i in 40:
						await io.wheel(io.centre(sc), p.y < 0, 1)
						p = io.centre(r)
						if Rect2(Vector2(0, 20), io.vs() - Vector2(0, 40)).has_point(p):
							break
			if phone:
				await io.tap(p)
			else:
				await io.click(p)
			await io.frames(3)
			return true
	io.note("pick: no row '%s' in the list" % row)
	await io.key(KEY_ESCAPE)
	if is_instance_valid(main):
		pass
	return false


## The dropdowns of the skirmish page in screen order (each slot row: who, faction, colour, [plan], team; then the map).
func dropdowns() -> Array:
	var out: Array = []
	for b in io.buttons():
		if b is Button and (b as Button).text.ends_with("▼"):
			out.append(b)
	return out


## The slot row's dropdowns: [who, faction, colour, plan or null, team].
func slot_row(i: int) -> Array:
	var rows: Array = []
	for b in dropdowns():
		var row: Node = b.get_parent()
		if not rows.has(row) and row is HBoxContainer and row.get_child_count() >= 4:
			rows.append(row)
	if i >= rows.size():
		return []
	var r: HBoxContainer = rows[i]
	var bs: Array = []
	for ch in r.get_children():
		if ch is Button and (ch as Button).text.ends_with("▼"):
			bs.append(ch)
	if bs.size() == 4:
		bs.insert(3, null)
	return bs


func to_menu() -> void:
	for i in 60:
		await io.frames(2)
		if io.find_button("SKIRMISH", true) != null:
			return
		if io.find_button("COPY REPORT", true) != null and io.find_button("MENU", true) != null:
			io.note("CRASH PAGE shown at start (the last run was killed): MENU")
			await press("MENU", true)
			continue
		if io.find_button("COMPUTER", true) != null and io.find_button("MOBILE", true) != null:
			await press("MOBILE" if phone else "COMPUTER", true)
			io.note("device page: picked %s" % ("MOBILE" if phone else "COMPUTER"))


func language(code: String) -> void:
	# the flags have the language's own name as tooltip
	var name: String = {"en": "English", "pt": "Português", "es": "Español"}[code]
	for b in io.buttons():
		if b.tooltip_text == name:
			if phone:
				await io.tap(io.centre(b))
			else:
				await io.click(io.centre(b))
			await io.frames(4)
			io.note("language: " + code)
			return
	io.note("no flag for " + code)


## cfg: foe (faction), who (hard/brutal...), plan (OPTIMAL...), map (label as listed), mine (my faction label)
func skirmish(cfg: Dictionary) -> void:
	await press("SKIRMISH", true)
	await io.frames(3)
	await io.shot("lobby_open")
	await press("1V1", true)
	await io.frames(3)
	var r0 := slot_row(0)
	await pick(r0[0], "YOU")
	r0 = slot_row(0)
	await pick(r0[1], "CLOCKWORK")
	var r1 := slot_row(1)
	await pick(r1[0], String(cfg.get("who", "HARD AI")))
	r1 = slot_row(1)
	await pick(r1[1], String(cfg.get("foe", "CROWN")))
	r1 = slot_row(1)
	if r1[3] != null:
		await pick(r1[3], String(cfg.get("plan", "OPTIMAL")))
	if cfg.has("colour"):
		r0 = slot_row(0)
		await pick(r0[2], String(cfg["colour"]))
	if cfg.has("map"):
		var dd := dropdowns()
		var mapb: BaseButton = dd[dd.size() - 1]
		await pick(mapb, String(cfg["map"]))
	await io.frames(3)
	await io.shot("lobby_set")


func start() -> Game:
	await press("START", true)
	for i in 600:
		await io.frames(1)
		if main.game != null and is_instance_valid(main.game) and main.game.hud != null:
			break
	var g: Game = main.game
	if g == null:
		io.note("START: no match")
		return null
	# the countdown
	for i in 600:
		await io.frames(1)
		if g.hud.countdown <= 0.0:
			break
	return g
