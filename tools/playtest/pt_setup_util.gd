extends "res://tools/playtest/pt_base.gd"
## Skirmish-setup helpers: everything through the setup screen's own buttons.

## The n-th visible button whose text begins with `text` (dropdowns read "RANDOM  ▼").
func nth_button(text: String, n := 0) -> BaseButton:
	var k := 0
	for b in buttons():
		var bt := button_text(b).to_upper().strip_edges()
		if bt.begins_with(text.to_upper()) or bt.begins_with(Loc.t(text).to_upper()):
			if k == n:
				return b
			k += 1
	return null


## Open the dropdown that is the n-th button starting with `text`, pick `item` in its list.
func dropdown(text: String, n: int, item: String) -> bool:
	var b := nth_button(text, n)
	if b == null:
		finding("SETUP: dropdown '%s' #%d not found (buttons: %s)" % [text, n, list_buttons()])
		return false
	await press_control(b)
	await frames(4)
	var it := find_button(item)
	if it == null:
		finding("SETUP: dropdown item '%s' not in the list (buttons: %s)" % [item, list_buttons()])
		await key(KEY_ESCAPE)
		return false
	step("dropdown '%s'#%d -> '%s'" % [text, n, item])
	await press_control(it)
	await frames(4)
	return true


## A row's button by slot index and column (0 who, 1 faction, 2 colour, 3 plan/spacer, 4 team) read from main's layout.
func slot_buttons(i: int) -> Array:
	# rows are HBoxContainers inside the scroll's VBox, in slot order
	var rows: Array = []
	_rows(root, rows)
	if i >= rows.size():
		return []
	var res: Array = []
	for ch in (rows[i] as Node).get_children():
		if ch is Button:
			res.append(ch)
	return res


func _rows(n: Node, out_a: Array) -> void:
	for ch in n.get_children():
		if ch is HBoxContainer and ch.get_parent() is VBoxContainer and ch.get_parent().get_parent() is ScrollContainer:
			out_a.append(ch)
		_rows(ch, out_a)


func pick_in_slot(i: int, col: int, item: String) -> bool:
	var bs := slot_buttons(i)
	if col >= bs.size():
		finding("SETUP: slot %d has no column %d" % [i, col])
		return false
	await press_control(bs[col])
	await frames(4)
	var it := find_button(item)
	if it == null:
		finding("SETUP: slot %d col %d: no item '%s' (%s)" % [i, col, item, list_buttons()])
		await key(KEY_ESCAPE)
		await frames(2)
		return false
	step("slot %d col %d -> %s" % [i, col, item])
	await press_control(it)
	await frames(4)
	return true


## Main menu -> SKIRMISH -> 1v1, you Crown, the computer `who` `faction` `plan`, map `map_label` ("" = keep), START.
func setup_1v1(who: String, faction: String, plan: String, map_label := "") -> void:
	await press_button("SKIRMISH")
	await wait_real(0.3)
	await press_button("1v1")
	await wait_real(0.3)
	await pick_in_slot(0, 1, "CROWN")
	await pick_in_slot(1, 0, who)
	await pick_in_slot(1, 1, faction)
	await pick_in_slot(1, 3, plan)
	if map_label != "":
		var mb := nth_button("RANDOM 1V1", 0)
		var bs := buttons()
		# the map dropdown is the button between "<" and ">"
		for i in bs.size():
			if button_text(bs[i]) == "<" and i + 1 < bs.size():
				mb = bs[i + 1]
				break
		await press_control(mb)
		await frames(4)
		var it := find_button(map_label)
		if it:
			await press_control(it)
		else:
			finding("SETUP: map '%s' not in the list" % map_label)
			await key(KEY_ESCAPE)
		await frames(4)


## Waits until the match is on (the HUD up and the countdown done).
func wait_match() -> void:
	for i in 200:
		if main.game and main.game.hud and main.game.hud.countdown <= 0.0 and main.game.clock > 0.2:
			return
		await wait_real(0.1)
