## THE MARCHING BAND's MUSIC (jobs band-music, band-music-v2, band-repertoire and band-real, docs/band_music.md): the
## REAL RECORDINGS BandSound plays (assets/audio/band/<tune>.ogg, cut and mastered by tools/audio/master_band_real.py)
## must:
##  - all exist, each exactly its TUNES length; every tune in its own list (ORDER: band / drums / fife / pipes), the
##    slow airs with phrase ends inside them;
##  - be levelled together: mid-tune, every file within LOUD_SPREAD dB of the others (a rough loudness: the mixer's RMS
##    after a high-pass, K-weighting's main step; the files are levelled by LUFS in the script);
##  - begin with sound (no long silence at the start) and end quietly (no cut-off note before the pause);
##  - stay in step (a player started on the band's clock stays within a few ms of it);
##  - the PLAYLISTS: never the same tune twice in a row, no slow air while fighting (and one playing cut short at a
##    phrase end, faded, if fighting starts), a slow air may come next when the men stand idle; a pause (GAP) between
##    two tunes; a SOLO raises the level and keeps the tune (checked in test_marching_band.gd).
##   xvfb-run -a godot --rendering-driver opengl3 --write-movie /tmp/band_test/out.png --fixed-fps 30 --resolution 320x180 \
##       --script res://tools/test_band_music.gd        (the movie writer mixes the sound: every check runs)
##   godot --headless --fixed-fps 30 --script res://tools/test_band_music.gd   (no sound is mixed headless: the file and
##       playlist checks run, the sound checks are skipped with a note)
extends SceneTree
var fails := 0
const LOUD_SPREAD := 6.0


func check(name: String, ok: bool, detail := "") -> void:
	print("CHECK %-78s %s %s" % [name, "ok" if ok else "FAIL", detail])
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


func stream(f: String) -> AudioStream:
	var st: AudioStream = (load("res://assets/audio/%s.ogg" % f) as AudioStream).duplicate()
	if st is AudioStreamOggVorbis:
		(st as AudioStreamOggVorbis).loop = false
	return st


## The capture's frames as a mono PackedFloat32Array.
func mono(fr: PackedVector2Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(fr.size())
	for i in fr.size():
		out[i] = (fr[i].x + fr[i].y) * 0.5
	return out


## A rough loudness (dB): RMS after a first-order high-pass at 120 Hz (the low end counts less, as in K-weighting).
func loud(x: PackedFloat32Array) -> float:
	var a := exp(-TAU * 120.0 / 44100.0)
	var y := 0.0
	var px := 0.0
	var s := 0.0
	for v in x:
		y = a * (y + v - px)
		px = v
		s += y * y
	return 10.0 * log(s / maxf(1.0, x.size()) + 1e-12) / log(10.0)


func playlist_checks() -> void:
	var bs := BandSound.new()
	check("four lists: a full band, a lone drummer, a lone fifer, a lone piper", BandSound.ORDER.keys().size() == 4 and ["band", "drums", "fife", "pipes"].all(func(k) -> bool: return BandSound.ORDER.has(k) and (BandSound.ORDER[k] as Array).size() >= 2), str(BandSound.ORDER.keys()))
	var listed := {}
	for g in BandSound.ORDER:
		for t in BandSound.ORDER[g]:
			listed[t] = int(listed.get(t, 0)) + 1
	check("every tune in exactly one list, its own", BandSound.TUNES.keys().all(func(t) -> bool: return int(listed.get(t, 0)) == 1 and (BandSound.ORDER[String(BandSound.TUNES[t]["set"])] as Array).has(t)), str(listed))
	check("the band's list mixes pipe band and fife-and-drum corps tunes in turn (never the same kind 3 times running)", _alternates(BandSound.ORDER["band"]), str(BandSound.ORDER["band"]))
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for g in BandSound.ORDER:
		var cur: String = BandSound.ORDER[g][0]
		var prev := ""
		var twice := 0
		var air_fight := 0
		var seen := {}
		for i in 4000:
			var f := rng.randf() < 0.3
			var idle := rng.randf() < 0.2
			var nx := BandSound.next_tune(cur, f, idle, prev)
			if nx == cur:
				twice += 1
			if f and String(BandSound.TUNES[nx]["kind"]) == "air":
				air_fight += 1
			if String(BandSound.TUNES[nx]["set"]) != g:
				twice += 1000
			seen[nx] = true
			prev = cur
			cur = nx
		check("%s: never the same tune twice in a row, never another list's (4000 picks)" % g, twice == 0, "%d" % twice)
		check("%s: fighting, never a slow air next" % g, air_fight == 0, "%d" % air_fight)
		check("%s: every tune of the list comes round" % g, seen.size() == (BandSound.ORDER[g] as Array).size(), str(seen.keys()))
		var air := ""
		for t in BandSound.ORDER[g]:
			if String(BandSound.TUNES[t]["kind"]) == "air":
				air = t
		if air != "":
			var other: String = BandSound.ORDER[g][0] if BandSound.ORDER[g][0] != air else BandSound.ORDER[g][1]
			var idle_nx := BandSound.next_tune(other, false, true)
			check("%s: standing idle a while, a slow air may come next (and not another after it)" % g, BandSound._is_air(idle_nx) and not BandSound._is_air(BandSound.next_tune(idle_nx, false, true)))
	check("in turn when marching: the band's list from the first tune to the second", BandSound.next_tune(BandSound.ORDER["band"][0], false, false) == BandSound.ORDER["band"][1])
	# the band's own pieces by what it is doing (MAIN): marching The Pipe Calls, fighting The Drums Lead, at rest the lament
	var mn: Dictionary = BandSound.MAIN["band"]
	check("marching: The Pipe Calls after every other tune", BandSound.next_tune("band_scotland", false, false, "band_pipecalls", "band") == mn["march"] and BandSound.next_tune("band_brandywine", false, false, "band_pipecalls", "band") == mn["march"])
	check("marching: after The Pipe Calls the recordings go on in turn", BandSound.next_tune(mn["march"], false, false, "band_scotland", "band") == "band_brandywine")
	check("fighting: The Drums Lead after every other tune, and straight after a march's main tune", BandSound.next_tune("band_scotland", true, false, "", "band") == mn["fight"] and BandSound.next_tune(mn["march"], true, false, "band_paddy", "band") == mn["fight"])
	check("at rest: the lament comes next", BandSound.next_tune("band_scotland", false, true, "band_pipecalls", "band") == mn["rest"])
	check("never two slow airs in a row (the lament, then not The Mist Covered Mountains)", not BandSound._is_air(BandSound.next_tune(mn["rest"], false, false, "band_green", "band")))
	# a playlist moving on: GAP s after a tune's end the next starts, its clock carried on (no restart)
	var pl := BandSound.Playlist.new()
	var now := Time.get_ticks_msec()
	pl.group = "band"
	pl.tune = BandSound.ORDER["band"][0]
	pl.start = now - int((BandSound.length(pl.tune) + BandSound.GAP) * 1000.0) - 2000
	pl.still_since = now
	bs.advance(pl)
	check("a playlist after a tune's end and the pause goes on to the next, its clock carried on", pl.tune == BandSound.ORDER["band"][1] and absf(bs.pos(pl) - 2.0) < 0.05, "%s at %.2f s" % [pl.tune, bs.pos(pl)])
	pl.start = Time.get_ticks_msec() - int((BandSound.length(pl.tune) + 0.5) * 1000.0)
	var t_before := pl.tune
	bs.advance(pl)
	check("... in the pause between two tunes the playlist waits (a real band's breath)", pl.tune == t_before, pl.tune)
	# fighting starts during the slow air: it is cut short at its next phrase end, faded, then a march
	pl.tune = "band_mist"
	pl.prev = "band_paddy"
	pl.cut = -1.0
	pl.start = Time.get_ticks_msec() - 20000
	pl.fighting = true
	bs.advance(pl)
	var ph: Array = BandSound.TUNES["band_mist"]["phrases"]
	check("fighting during the slow air: it stops at its next phrase end (not mid-phrase)", pl.tune == "band_mist" and ph.has(pl.cut) and pl.cut > 20.0, "cut at %.2f" % pl.cut)
	pl.start = Time.get_ticks_msec() - int((pl.cut - 0.05) * 1000.0)
	check("... fading over its last moment (no click)", bs.env_db(pl) < -20.0, "%.1f dB" % bs.env_db(pl))
	pl.start = Time.get_ticks_msec() - int((pl.cut + BandSound.GAP + 0.3) * 1000.0)
	bs.advance(pl)
	check("... then a march or a quickstep", pl.tune != "band_mist" and String(BandSound.TUNES[pl.tune]["kind"]) != "air" and pl.cut < 0.0 and absf(bs.pos(pl) - 0.3) < 0.05, "%s at %.2f" % [pl.tune, bs.pos(pl)])
	bs.free()


## The band's list: no three pipe band or three fife-and-drum tunes running (TUNES "style").
func _alternates(list: Array) -> bool:
	var run := 0
	var last := ""
	for t in list:
		var k := String(BandSound.TUNES[t].get("style", ""))
		if k == "":
			return false
		run = run + 1 if k == last else 1
		last = k
		if run >= 3:
			return false
	return true


func _run() -> void:
	# 1. the files
	for t in BandSound.TUNES:
		var f := BandSound.file(t)
		if not ResourceLoader.exists("res://assets/audio/%s.ogg" % f):
			check("%s exists" % f, false)
			continue
		var st := stream(f)
		check("%s is exactly its length" % f, absf(st.get_length() - BandSound.length(t)) < 0.003, "%.4f s (%.4f)" % [st.get_length(), BandSound.length(t)])
		if String(BandSound.TUNES[t]["kind"]) == "air":
			var ph: Array = BandSound.TUNES[t].get("phrases", [])
			check("%s (a slow air): its phrase ends inside it, in order" % t, ph.size() >= 2 and ph.all(func(v) -> bool: return float(v) > 2.0 and float(v) < BandSound.length(t)) and _sorted(ph))
	playlist_checks()

	# the engine's mixer: a bus with a capture on it
	var bus := AudioServer.bus_count
	AudioServer.add_bus(bus)
	AudioServer.set_bus_name(bus, "BandTest")
	var cap := AudioEffectCapture.new()
	cap.buffer_length = 8.0
	AudioServer.add_bus_effect(bus, cap)
	var probe := AudioStreamPlayer.new()
	probe.bus = "BandTest"
	probe.stream = stream(BandSound.file(BandSound.ORDER["band"][0]))
	root.add_child(probe)
	probe.play(10.0)
	await create_timer(0.3).timeout
	var mixing := cap.get_frames_available() > 0
	probe.stop()
	cap.clear_buffer()
	if not mixing:
		print("NOTE the audio driver mixes nothing here (run with --write-movie, see the top of this file): the sound checks are skipped")
	else:
		var p := AudioStreamPlayer.new()
		p.bus = "BandTest"
		root.add_child(p)
		# 2. loudness: every file mid-tune (4 s from 40% in); its first second; its last moment
		var lv := {}
		for t in BandSound.TUNES:
			p.stream = stream(BandSound.file(t))
			cap.clear_buffer()
			p.play(BandSound.length(t) * 0.4)
			await create_timer(4.0).timeout
			lv[t] = loud(mono(cap.get_buffer(cap.get_frames_available())))
			p.stop()
			cap.clear_buffer()
			p.play(0.0)
			await create_timer(1.0).timeout
			var head := loud(mono(cap.get_buffer(cap.get_frames_available())))
			p.stop()
			check("%s begins with sound (no long silence before it)" % t, head > -45.0, "%.1f dB" % head)
			cap.clear_buffer()
			p.play(BandSound.length(t) - 0.35)
			await create_timer(0.4).timeout
			var x := mono(cap.get_buffer(cap.get_frames_available()))
			p.stop()
			var e := 0.0
			var m := mini(x.size(), 4410)
			for k in range(maxi(0, x.size() - 4410 - 2205), maxi(0, x.size() - 2205)):
				e += x[k] * x[k]
			e = sqrt(e / maxf(1, m))
			check("%s ends quietly (its decay or a fade, then the pause)" % t, e < 0.03, "RMS %.4f" % e)
		var vals: Array = lv.values()
		var spread: float = float(vals.max()) - float(vals.min())
		check("every recording mid-tune within %.0f dB of the others (levelled together)" % LOUD_SPREAD, spread <= LOUD_SPREAD, str(lv))
		# 3. in step: a player joining on the band's clock stays with it
		var a2 := AudioStreamPlayer.new()
		var b2 := AudioStreamPlayer.new()
		a2.stream = stream(BandSound.file(BandSound.ORDER["band"][0]))
		b2.stream = stream(BandSound.file(BandSound.ORDER["band"][0]))
		a2.bus = "BandTest"
		b2.bus = "BandTest"
		root.add_child(a2)
		root.add_child(b2)
		var clock := [10.0]
		a2.play(clock[0])
		for k in 8:
			await process_frame
			clock[0] += root.get_process_delta_time()
		b2.play(clock[0])                        # (a second band's player joining later, on the same clock)
		var worst := 0.0
		var worst_clock := 0.0
		for k in 90:
			await process_frame
			clock[0] += root.get_process_delta_time()
			worst = maxf(worst, absf(a2.get_playback_position() - b2.get_playback_position()))
			worst_clock = maxf(worst_clock, absf(a2.get_playback_position() - clock[0]))
		check("two players stay in step", worst < 0.05, "worst %.1f ms apart" % (worst * 1000.0))
		check("and with the band's clock (BandSound puts a player back past 80 ms)", worst_clock < 0.08, "worst %.1f ms" % (worst_clock * 1000.0))
	print("RESULT %s (%d failed)" % ["PASS" if fails == 0 else "FAIL", fails])
	quit(1 if fails > 0 else 0)


func _sorted(a: Array) -> bool:
	for i in range(1, a.size()):
		if float(a[i]) <= float(a[i - 1]):
			return false
	return true
