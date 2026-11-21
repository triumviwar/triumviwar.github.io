extends SceneTree
## A check (playtest-campaign-brood): the briefing's objective words with their numbers put in (Campaign.brief_text).
func _initialize() -> void:
	for mid in Campaign.mission_ids():
		var m := Campaign.mission(String(mid))
		for o in m.get("objectives", []):
			var t := String(o.get("text", ""))
			if t.contains("{") and not bool(o.get("hidden", false)):
				var b := Campaign.brief_text(m, t)
				print("%s %s: %s" % [mid, o.get("id"), b])
				if b.contains("{"):
					print("  STILL RAW")
	quit()
