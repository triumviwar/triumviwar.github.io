extends SceneTree
## A check (playtest-campaign-brood): every mission's OPENING for every side, shown as the briefing's START shows it
## (CampaignMenu.opening_then_start's pages) and stepped through with NEXT: no script error, no empty line.
##   godot --headless --path . --script res://tools/playtest/check_openings.gd
var errs: Array = []


class Catch extends Logger:
	var out: Array
	func _init(o: Array) -> void:
		out = o
	func _log_error(_f: String, file: String, line: int, code: String, rationale: String, _e: bool, error_type: int, _bt: Array[ScriptBacktrace]) -> void:
		if error_type == 2:
			out.append("%s:%d %s" % [file, line, rationale if rationale != "" else code])


func _initialize() -> void:
	OS.add_logger(Catch.new(errs))
	_run.call_deferred()


func _run() -> void:
	var holder := Control.new()
	root.add_child(holder)
	var bad := 0
	for mid in Campaign.mission_ids():
		var m := Campaign.mission(String(mid))
		for sd in Campaign.side_ids(m):
			var pages := Campaign.pages_before(Campaign.show_pages(m, "opening", String(sd)))
			if pages.is_empty():
				continue
			var e0 := errs.size()
			var done := {"v": false}
			var s := StillShow.play(holder, m, pages, func() -> void: done["v"] = true)
			await process_frame
			var n := 0
			var empty := 0
			while not done["v"] and n < 60:
				if s._text.text.strip_edges() == "":
					empty += 1
				s.next()
				await process_frame
				n += 1
			var ok := errs.size() == e0 and empty == 0
			if not ok:
				bad += 1
			print("OPENING %s %s: %d lines%s%s" % [mid, sd, n, "" if errs.size() == e0 else " ERRORS " + str(errs.slice(e0)), (" %d empty" % empty) if empty else ""])
	print("OPENINGS %s" % ("OK" if bad == 0 else "FAIL %d" % bad))
	quit()
