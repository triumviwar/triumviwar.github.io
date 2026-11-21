class_name MissionSave
## A campaign mission's own saves (player-comforts, docs/player_comforts.md). Three files a mission, in user://missions/:
##   <id>.json             where you left it: written every 15 s, when you leave (QUIT TO CAMPAIGN, the phone putting the
##                         game away) and kept until the mission ends; the mission's card offers CONTINUE.
##   <id>_save.json        the match menu's SAVE (your own save); its LOAD, and LOAD SAVE on the card.
##   <id>_checkpoint.json  a CHECKPOINT: kept by itself when a part of the mission begins or a primary objective is met;
##                         RETRY FROM CHECKPOINT after a defeat, FROM CHECKPOINT on the card.
## A skirmish's autosave (user://autosave.json, CONTINUE on the main menu) is apart: a mission never writes over it.
## Saves are the match's own (SaveGame.capture with the mission's state) and only for this version of the game.

const DIR := "user://missions/"
const KINDS := ["auto", "save", "checkpoint"]


static func path(mid: String, kind := "auto") -> String:
	return DIR + mid + ("" if kind == "auto" else "_" + kind) + ".json"


## The save of this kind for this mission, checked ({} when there is none, or it is from another version).
static func peek(mid: String, kind := "auto") -> Dictionary:
	if mid == "":
		return {}
	var d := SaveGame.peek_file(path(mid, kind))
	if d.is_empty() or String(d.get("mission_id", "")) != mid or not (d.get("mission") is String):
		return {}
	if String(d.get("version", "")) != String(ProjectSettings.get_setting("application/config/version", "dev")):
		return {}
	return d


static func has(mid: String, kind := "auto") -> bool:
	return not peek(mid, kind).is_empty()


static func clear(mid: String, kind := "auto") -> void:
	SaveGame.wait()
	if FileAccess.file_exists(path(mid, kind)):
		DirAccess.remove_absolute(path(mid, kind))


static func clear_all(mid: String) -> void:
	for k in KINDS:
		clear(mid, k)


## The match set up to go on from this save (Main.start takes it: cfg["resume"]).
static func resume_cfg(d: Dictionary) -> Dictionary:
	var cfg: Dictionary = (d.get("cfg", {}) as Dictionary).duplicate(true)
	cfg["resume"] = d
	return cfg


## The game's mission may be saved now (solo, not a lesson, not over).
static func can_save(game: Game) -> bool:
	return game != null and is_instance_valid(game) and game.mission != null and game.mission.saveable() and not game.over \
		and not game.edit_mode


## Write this mission's save of that kind now; true when written.
static func write(game: Game, cfg: Dictionary, kind := "auto") -> bool:
	if not can_save(game):
		return false
	var c := cfg.duplicate(true)
	c.erase("resume")
	return SaveGame.save(game, c, path(game.mission.id, kind))


## The game minutes and seconds of a save, for a button ("12:40").
static func clock_text(d: Dictionary) -> String:
	var secs := int(d.get("clock", 0))
	return "%d:%02d" % [secs / 60, secs % 60]


## A mission left part-played (its "where you left it" save), the newest; "" when none. (The crash page says where
## to find it.)
static func newest_auto() -> String:
	var best := ""
	var bt := 0
	var da := DirAccess.open(DIR)
	if da == null:
		return ""
	for f in da.get_files():
		if not f.ends_with(".json") or f.ends_with("_save.json") or f.ends_with("_checkpoint.json"):
			continue
		var mid := f.trim_suffix(".json")
		var t := FileAccess.get_modified_time(DIR + f)
		if t > bt and has(mid):
			bt = t
			best = mid
	return best
