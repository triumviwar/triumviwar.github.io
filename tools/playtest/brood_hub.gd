extends SceneTree
## PLAYTEST (playtest-campaign-brood): THE NATURALIST'S HUB from the main menu, as a human with the mouse (or a finger):
## the device page if it shows, CAMPAIGN, the Naturalist line, every hotspot (on the painting and in the GO TO list),
## every talk to its end, the SPECIMEN CHART (war table: every mission, modes, BRIEFING, difficulty, side picks, BACK),
## the WAR MAP (pins, BACK), Esc mid-screen. The campaign progress it starts from is written first (stage=...), as the
## game would have left it after those missions, so every state of the hub is seen.
##   xvfb-run -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 --script res://tools/playtest/brood_hub.gd --
##        [stage=fresh|b01_saved|b01_burned|a03_party|a03_withheld|a03_nest|a05_exp|a05_few|a05_creatures|all]
##        [lang=en|pt|es] [phone] [tag=<name>]
const PT := preload("res://tools/playtest/pt_lib.gd")
var pt
var stage := "fresh"
var lang := "en"
var phone := false
var tag := ""


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("stage="): stage = a.substr(6)
		if a.begins_with("lang="): lang = a.substr(5)
		if a == "phone": phone = true
		if a.begins_with("tag="): tag = a.substr(4)
	if tag == "":
		tag = "hub_%s_%s%s" % [stage, lang, "_phone" if phone else ""]
	_prepare()
	pt = PT.new(self, "res://docs/shots/playtest_2026_11_21/campaign_brood/" + tag)
	pt.touch = phone
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred(main)


static func progress_for(st: String) -> Dictionary:
	var done := {}
	var b01 := {"won_by": "sire", "side": "sire", "mode": "solo", "flags": {"clutch": "saved", "eggs": "taken", "rival": "standing"}}
	if st in ["b01_burned"]:
		b01["flags"] = {"clutch": "burned", "eggs": "left", "rival": "beaten"}
	if st != "fresh":
		done["b01_specimen"] = b01
	if st.begins_with("a03") or st.begins_with("a05") or st == "all":
		var a03 := {"won_by": "party", "side": "party", "mode": "solo", "flags": {"map": "drawn", "party": "some"}}
		if st == "a03_withheld": a03["flags"]["map"] = "withheld"
		if st == "a03_nest": a03 = {"won_by": "nest", "side": "nest", "mode": "solo", "flags": {"plateau": "kept"}}
		done["a03_plateau"] = a03
	if st.begins_with("a05") or st == "all":
		var a05 := {"won_by": "expedition", "side": "expedition", "mode": "solo", "flags": {"cages": "some", "cages_n": 3, "eggs": "taken", "pieter": "alive", "way": "short"}}
		if st == "a05_few": a05["flags"]["cages"] = "few"
		if st == "a05_creatures": a05 = {"won_by": "creatures", "side": "creatures", "mode": "solo", "flags": {"specimens": "freed"}}
		done["a05_specimens"] = a05
	# ("reached": what a finished mission opened, as Campaign.record leaves it)
	var reached: Array = []
	for mid in done:
		var nx := String(Campaign.next_of(mid, String(done[mid]["won_by"])))
		if nx != "" and not reached.has(nx):
			reached.append(nx)
	return {"done": done, "reached": reached}


func _prepare() -> void:
	var cfg := ConfigFile.new()
	cfg.load("user://settings.cfg")
	cfg.set_value("input", "device", "phone" if phone else "pc")
	cfg.set_value("ui", "language", lang)
	cfg.save("user://settings.cfg")
	var p := progress_for(stage)
	var old := FileAccess.get_file_as_string("user://campaign.json")
	if old != "":
		var pd = JSON.parse_string(old)
		if pd is Dictionary:
			for k in pd:
				if k != "done":
					p[k] = pd[k]
	var f := FileAccess.open("user://campaign.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(p))
	f.close()


func _run(main: Node) -> void:
	await pt.wait(1.5)
	await pt.past_crash_page()
	await pt.shot("menu")
	if not await pt.tap("Menu_campaign", 8.0):
		pt.note("FAIL", "no CAMPAIGN button: " + str(pt.button_names()))
		_end()
		return
	await pt.wait(0.8)
	await pt.shot("hub_first")
	await pt.tap("Line_naturalist")
	await pt.wait(0.8)
	await pt.shot("naturalist_hub")
	pt.note("HUB", "title/labels: " + pt.labels_text().replace("\n", " | ").substr(0, 400))
	# every hotspot on the painting, then each one from the list
	var spots: Array = pt.buttons().filter(func(b) -> bool: return String(b.name).begins_with("Hotspot_") and not String(b.name).begins_with("HotspotList_"))
	var names: Array = spots.map(func(b) -> String: return String(b.name))
	pt.note("HUB", "%d hotspots on the painting: %s" % [names.size(), names])
	# two hotspots on the same spot: one hides the other
	for i in spots.size():
		for j in range(i + 1, spots.size()):
			var ri: Rect2 = pt.rect_of(spots[i])
			var rj: Rect2 = pt.rect_of(spots[j])
			if ri.intersects(rj) and ri.intersection(rj).get_area() > 0.5 * minf(ri.get_area(), rj.get_area()):
				pt.note("OVERLAP", "%s and %s cover the same place (%s / %s)" % [spots[i].name, spots[j].name, ri, rj])
	for nm in names:
		if nm == "Hotspot_war_table":
			continue
		await _talk(nm)
	var lst: Array = pt.buttons().filter(func(b) -> bool: return String(b.name).begins_with("HotspotList_"))
	for b in lst:
		var nm := String(b.name)
		if nm == "HotspotList_war_table":
			continue
		await _talk(nm)
	# the war table
	await pt.tap("Hotspot_war_table")
	await pt.wait(0.8)
	await pt.shot("war_table")
	var mb: Array = pt.buttons().filter(func(b) -> bool: return String(b.name).begins_with("Mission_"))
	pt.note("TABLE", "missions: " + str(mb.map(func(b) -> String: return "%s '%s'%s" % [b.name, b.text, " off" if b.disabled else ""])))
	var mnames: Array = mb.filter(func(b) -> bool: return not b.disabled).map(func(b) -> String: return String(b.name))
	for nm in mnames:
		await pt.tap(nm)
		await pt.wait(0.5)
		await pt.shot("table_" + nm)
		for md in ["Mode_coop", "Mode_versus", "Mode_solo"]:
			var mbn = pt.find(md)
			if mbn:
				await pt.tap_node(mbn)
				await pt.wait(0.3)
				if md == "Mode_versus":
					await pt.shot("table_%s_versus" % nm)
		if await pt.tap("Campaign_Go", 2.0):
			await pt.wait(0.6)
			await pt.shot("briefing_" + nm)
			var sides: Array = pt.buttons().filter(func(x) -> bool: return String(x.name).begins_with("Side_"))
			pt.note("BRIEF", "%s sides %s; text: %s" % [nm, sides.map(func(x) -> String: return x.text), pt.labels_text().replace("\n", " | ").substr(0, 600)])
			for s in sides.map(func(x) -> String: return String(x.name)):
				await pt.tap(s)
				await pt.wait(0.4)
				await pt.shot("briefing_%s_%s" % [nm, s])
			for d in ["Diff_easy", "Diff_hard", "Diff_normal"]:
				await pt.tap(d)
				await pt.wait(0.2)
			await pt.tap("BACK")
			await pt.wait(0.5)
	# the war map from the war table
	if await pt.tap("WarTable_Map", 3.0):
		await pt.wait(1.0)
		await pt.shot("war_map")
		pt.note("MAP", "buttons: " + str(pt.button_names()).substr(0, 600))
		await pt.key(KEY_ESCAPE)
		await pt.wait(0.5)
		await pt.shot("after_esc_on_map")
	await pt.tap("BACK", 2.0)
	await pt.wait(0.5)
	await pt.shot("back")
	_end()


func _talk(nm: String) -> void:
	var b = pt.find(nm)
	if b == null:
		return
	await pt.tap_node(b)
	await pt.wait(0.4)
	var i := 0
	while i < 8:
		var nx = pt.find("TalkNext")
		if nx == null:
			break
		var txt := ""
		var tt = root.find_child("TalkText", true, false)
		if tt:
			txt = tt.text
		pt.note("TALK", "%s #%d: %s" % [nm, i, txt])
		if i == 0:
			await pt.shot("talk_" + nm)
		await pt.tap_node(nx)
		await pt.wait(0.25)
		i += 1


func _end() -> void:
	pt.report_errors(tag)
	print("PT END %s clicks=%d covered=%d errors=%d" % [tag, pt.clicks, pt.misses, pt.errs.size()])
	quit()
