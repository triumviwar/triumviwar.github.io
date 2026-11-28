extends SceneTree
## The Crown's victory music (job music-mix-pass): when the Crown wins the band plays God Save the King
## (assets/music/win_crown_anthem.ogg, tools/audio/band_godsave.py); the other sides keep their stings, and every
## defeat is unchanged.
##   godot --headless --script res://tools/test_music_anthem.gd
var fails := 0


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	check(Music.has_piece(Music.CROWN_ANTHEM), "the anthem's file is there (%s)" % Music.CROWN_ANTHEM)
	var s: AudioStream = load(Music.MUSIC_PATH % Music.CROWN_ANTHEM)
	check(s != null and s.get_length() > 35.0 and s.get_length() < 50.0,
		"it loads, about 40 s long (%.1f s)" % (s.get_length() if s else 0.0))
	check(Music._sting_name("crown", true) == Music.CROWN_ANTHEM, "the Crown's victory plays the anthem")
	check(Music._sting_name("clockwork", true) == "win_clockwork", "the Clockwork's victory keeps its sting")
	check(Music._sting_name("brood", true) == "win_brood", "the Brood's victory keeps its sting")
	check(Music._sting_name("crown", false) == "defeat_crown", "the Crown's defeat is unchanged")
	check(Music.has_piece("win_crown"), "Crown of Triumph (win_crown) is still there for CROWN_ANTHEM_ON false")
	print("ALL PASS" if fails == 0 else "%d FAILED" % fails)
	quit(1 if fails else 0)
