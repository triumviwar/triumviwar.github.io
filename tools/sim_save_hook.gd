extends RefCounted
## player-comforts: a SAVE and a LOAD in the middle of a campaign sim (tools/sim_campaign_*.gd), so the mission is played
## on to its end from a save (tools/test_campaign_save.sh runs every Act 1 mission with and without it and compares the
## flags written). The sims' arguments:
##   save_at=<game seconds>   at that time the mission is saved (MissionSave) and loaded again at once (Main.mission_load)
##   load=save|checkpoint     what is loaded: the save just written (the default) or the last CHECKPOINT (the mission
##                            goes back to the start of its last part: a defeat's RETRY FROM CHECKPOINT)

static var _at := -2.0
static var _kind := "save"
static var reloads := 0


static func _args() -> void:
	if _at > -2.0:
		return
	_at = -1.0
	for a in OS.get_cmdline_user_args():
		if a.begins_with("save_at="):
			_at = float(a.substr(8))
		elif a.begins_with("load="):
			_kind = a.substr(5)


## Is it time to save and load?
static func due(g: Game) -> bool:
	_args()
	return _at >= 0.0 and g != null and g.clock >= _at and not g.over


## Save, load, and hand back the new game (its mission at g.mission). The sim goes on with it.
static func reload(tree: SceneTree, main: Node) -> Game:
	_at = -1.0
	var g: Game = main.game
	var r: MissionRun = g.mission
	var before := {"clock": g.clock, "flags": r.flags.duplicate(true), "counters": r.counters.duplicate(true),
		"obj": r.obj.duplicate(true), "units": g.units.filter(func(u) -> bool: return not u.dead).size(),
		"fired": r.fired.size(), "clocks": _round(r.clocks), "tags": _tag_sizes(r), "said": r.said_ids.size()}
	var ok := MissionSave.write(g, main.last_cfg, "save")
	var cp := MissionSave.peek(r.id, "checkpoint")
	print("SIM SAVE t=%d written=%s checkpoints=%s (a checkpoint at %s) flags=%s" % [g.clock, ok, r.checkpoints.keys(),
		MissionSave.clock_text(cp) if not cp.is_empty() else "-", r.flags])
	var kind := _kind if MissionSave.has(r.id, _kind) else "save"
	main.mission_load(kind)
	for i in 4:
		await tree.process_frame
	tree.paused = false
	reloads += 1
	var g2: Game = main.game
	var r2: MissionRun = g2.mission
	print("SIM LOADED %s t=%d (was %d) units %d (was %d) fired %d (was %d) flags=%s counters=%s" % [kind, g2.clock, before["clock"],
		g2.units.filter(func(u) -> bool: return not u.dead).size(), before["units"], r2.fired.size(), before["fired"], r2.flags, r2.counters])
	if kind == "save":
		var diffs: Array = []
		for k in ["flags", "counters", "obj", "clocks", "tags"]:
			var now: Variant = {"flags": r2.flags, "counters": r2.counters, "obj": r2.obj, "clocks": _round(r2.clocks), "tags": _tag_sizes(r2)}[k]
			if now != before[k]:
				diffs.append("%s %s / %s" % [k, now, before[k]])
		if r2.fired.size() != int(before["fired"]) or r2.said_ids.size() != int(before["said"]):
			diffs.append("fired/said")
		print("SIM LOAD SAME %s" % ("yes" if diffs.is_empty() else "NO: " + "; ".join(diffs)))
	return g2


## Each tag's living members (what the triggers count).
static func _tag_sizes(r: MissionRun) -> Dictionary:
	var out := {}
	for t in r.tags:
		out[t] = r.tagged(String(t)).size()
	return out


## Clocks to a hundredth of a second (a save writes a float with a few digits fewer).
static func _round(d: Dictionary) -> Dictionary:
	var out := {}
	for k in d:
		out[k] = snappedf(float(d[k]), 0.01)
	return out
