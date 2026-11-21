extends "res://tools/playtest/pt_base.gd"
## PLAYTEST, RANKED with the DEV sign-in (job playtest-menus-online). tools/playtest/ranked.sh starts a local relay,
## the ladder service (--dev) and two copies of the game started with ranked_dev; each plays through the menus:
## ONLINE > RANKED, the ladder address typed in, a faction, FIND A MATCH (A also CANCELs once first), the match on
## the ladder's match server, A SURRENDERs from the match MENU, the battle report with the rating, LEADERBOARD.
##   role:a | b   ladder:<url>   sync:<dir>   faction:<f>

var role := "a"
var sync := ""
var hud: Control


func play() -> void:
	role = String(args.get("role", "a"))
	sync = String(args.get("sync", "/tmp/pt_ranked"))
	tag = role + "_" + tag
	DirAccess.make_dir_recursive_absolute(sync)
	await start_main()
	await tap(main.menu_buttons["online"])
	await wait(0.5)
	await look("online_entry")
	if not await press("RANKED"):
		find("BUG", "ranked", "no RANKED button on the ONLINE page with ranked_dev")
		return
	await look("ranked_first")
	print("PT ranked page: %s" % str(button_texts()).substr(0, 300))
	# the ladder address, typed and Enter
	var le: LineEdit = null
	for c in all_controls("LineEdit"):
		if (c as LineEdit).placeholder_text.begins_with("https://ladder"):
			le = c
	if le == null:
		find("BUG", "ranked", "no LADDER ADDRESS box")
		return
	await tap(le)
	await key_tap(KEY_A, false, true)
	await type_text(String(args.get("ladder", "")))
	await key_tap(KEY_ENTER)
	for i in 40:
		await wait(0.25)
		if find_button("FIND A MATCH") != null:
			break
	await look("signed_in")
	if find_button("FIND A MATCH") == null:
		find("BUG", "ranked", "not signed in after the ladder address (buttons: %s)" % str(button_texts()).substr(0, 200))
		return
	await press(String(args.get("faction", "crown")).to_upper())
	if role == "a":
		await press("FIND A MATCH", 1.5)
		await look("searching")
		await wait(3.0)
		await press("CANCEL", 1.0)
		await look("cancelled")
		if find_button("FIND A MATCH") == null:
			find("BUG", "ranked", "CANCEL did not bring back FIND A MATCH")
		note("a_cancelled")
	else:
		await until("a_cancelled", 200)
	await press("FIND A MATCH", 1.0)
	note(role + "_queued")
	var t := 0.0
	while main.game == null and t < 240.0:
		await wait(0.5)
		t += 0.5
		if int(t * 2) % 20 == 0:
			print("PT %s waiting: %s" % [role, str(button_texts()).substr(0, 120)])
		if t == 6.0 or t == 30.0:
			await look("waiting_%d" % int(t))
	if main.game == null:
		find("BUG", "ranked", "no match after 4 minutes in the queue")
		return
	hud = main.game.hud
	await wait(6.0)
	await look("match")
	await wait(20.0)
	await look("match_20s")
	if role == "a":
		await hud_tap(hud.menu_rect())
		await wait(0.5)
		await look("menu_in_ranked")
		var s := menu_item("SURRENDER")
		if s.is_empty():
			find("BUG", "ranked", "no SURRENDER in a ranked match's menu")
		else:
			await hud_tap(s["rect"])
			await wait(0.4)
			var y := menu_item("YES")
			if not y.is_empty():
				await hud_tap(y["rect"])
	t = 0.0
	while main.game != null and not main.game.over and t < 200.0:
		await wait(0.5)
		t += 0.5
	await wait(6.0)
	await look("report")
	var texts: Array = []
	for c in all_controls("Label"):
		var st := shown(c)
		if st.contains("RATING") or st.contains("+") or st.contains("→") or st.to_upper().contains("VICTORY") or st.to_upper().contains("DEFEAT"):
			texts.append(st.replace("\n", " "))
	print("PT %s report lines: %s" % [role, str(texts).substr(0, 400)])
	await wait(6.0)
	await look("report_later")
	if await press("MENU", 1.0, true):
		await tap(main.menu_buttons["online"])
		await wait(0.5)
		await press("RANKED", 1.5)
		await look("ranked_after")
		if await press("LEADERBOARD", 2.0):
			await look("leaderboard")
			await press("BACK")
	note(role + "_done")


func note(n: String) -> void:
	var f := FileAccess.open(sync + "/" + n, FileAccess.WRITE)
	f.store_string("x")
	f.close()


func until(n: String, timeout: float) -> bool:
	var t := 0.0
	while not FileAccess.file_exists(sync + "/" + n):
		await wait(0.25)
		t += 0.25
		if t > timeout:
			return false
	return true


func hud_tap(r: Rect2) -> void:
	await tap_at(root.get_final_transform() * hud.get_global_transform_with_canvas() * r.get_center())


func menu_item(label: String) -> Dictionary:
	for b in hud._menu_buttons():
		if String(b["label"]).begins_with(label):
			return b
	return {}
