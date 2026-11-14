class_name BandSound
extends Node
## THE MARCHING BAND's SOUND ENGINE (job band-v2, docs/band_v2.md; WHO IS HEARD redone for individual musicians in
## 0.37.0, docs/band_individuals.md; the PLAYLIST in band-repertoire; REAL RECORDINGS in band-real, docs/band_music.md
## "Real recordings (band-real)"). One node per match (made by the first musician that ticks: BandSound.need), its own
## players on the SFX bus, so the shared sound player (Sfx) is left alone. The rules:
##  - EITHER THE NEAREST BAND OR THE NEAREST FEW LONE MUSICIANS are heard, never both: whichever is nearest the middle
##    of the screen (a solo first), on screen or just off it, seen by your side (Sfx.heard: no music through the fog).
##  - THE MUSIC IS REAL RECORDINGS (owner's playtest 2026-11-14: the generated band "doesn't sound good"; he gathered
##    public-domain recordings of US military pipe bands and the Old Guard Fife and Drum Corps). A recording is a mix:
##    its parts cannot be split, so:
##     - A BAND (a Drummer, a Fifer and a Piper in each other's rings) plays FULL recordings, pipe band tunes and
##       fife-and-drum corps tunes in turn (ORDER["band"]), all bands IN STEP on one playlist (`_band`, one clock);
##     - a LONE musician plays his own instrument's recordings (ORDER["drums"]: the Old Guard's drum features and drum
##       calls; ORDER["fife"]: its fife features; ORDER["pipes"]: no recording has a solo pipe passage long enough, so
##       the lone Piper keeps the old generated piper part), OUT OF STEP: each his own playlist (`_lone_pl`), a little
##       into its tune (STEP_OFF); at most LONE_MAX of them (the nearest), never loud chaos. Two musicians who are not a
##       full band are two lone musicians.
##  - THE BAND'S OWN PIECES (owner 2026-11-14 22:12, "do it all"; tools/audio/band_own.py, Claude's melodies):
##    a full band's tune by WHAT IT IS DOING (MAIN): marching or standing about, The Pipe Calls (the pipes call, the
##    fife answers); FIGHTING, The Drums Lead; at REST (IDLE_AIR s still, no fight), The Fife Calls (a slow lament).
##    The main tune comes back after every other tune; the real recordings come round in turn between them.
##    The lone Piper's four tunes are rendered by the same tool (one piper, stereo, an outdoor room).
##  - THE PLAYLIST: one whole tune (or set), a short pause (GAP), the next, never the same twice in a row. The situation
##    only shapes it (next_tune): while the men are FIGHTING a slow air is skipped, and one playing is faded out at its
##    next phrase end (TUNES "phrases", over CUT_FADE); standing IDLE a while (IDLE_AIR s) a slow air may come next.
##  - A SOLO cannot bring one part of a recording forward: the heard music (the band's, or the soloist's own) gets
##    SOLO_DB louder for the solo and the game music goes down further (DUCK_SOLO_DB); the playlist goes on (no
##    restart); both come back smoothly afterwards (FADE, DUCK_RATE).
##    Further from the middle of the screen and zoomed out it is quieter; off past CUT px it is silent.
##  - THE GAME MUSIC GIVES WAY TO THE BAND (band-music-v2, owner 2026-11-14): while a band (or lone musicians) is heard
##    the faction/battle music is ducked STRONGLY: DUCK_DB with the band in the middle of the screen, DUCK_SOLO_DB
##    during a heard solo, less the further from the middle (duck_for: none past 640 px) and a little more zoomed in
##    (ZOOM_IN_DB); it moves DUCK_RATE dB a second. An Amplify effect on the "Music" bus, so the players' MUSIC and
##    SOUND volume sliders still set the balance; put back to 0 when the match ends.
## THE FILES: assets/audio/band/<tune>.ogg, cut and mastered by tools/audio/master_band_real.py (every file -20 LUFS,
## mono, true peak under -1 dBTP; the numbers below are what it writes to tools/audio/band_real.json). New tunes: add a
## cut there, its line here (TUNES) and its place in ORDER. Nothing else.

## The repertoire: length in samples at 44.1 kHz, which playlist it belongs to ("set": band / drums / fife / pipes),
## its kind (march / quick / air), for the band's the style (a pipe band or a fife-and-drum corps) and, for the slow airs, the phrase ends (s) where it may be cut short.
const TUNES := {
	# the band's own pieces (tools/audio/band_own.py): by what the band is doing (MAIN)
	"band_pipecalls": {"style": "both", "title": "The Pipe Calls", "set": "band", "kind": "march", "n": 2555395},
	"band_drumslead": {"style": "both", "title": "The Drums Lead", "set": "band", "kind": "march", "n": 1865886},
	"band_lament": {"style": "both", "title": "The Fife Calls", "set": "band", "kind": "air", "n": 3810240,
		"phrases": [12.5, 17.5, 27.5, 32.5, 52.5, 62.5, 67.5, 77.5]},
	# a full band: pipe band (USAF Reserve Pipe Band) and fife-and-drum corps (the Old Guard) tunes
	"band_scotland": {"style": "pipes", "title": "Scotland the Brave", "set": "band", "kind": "march", "n": 4020654},
	"band_brandywine": {"style": "fifes", "title": "Brandywine Quickstep", "set": "band", "kind": "quick", "n": 4860146},
	"band_minstrel": {"style": "pipes", "title": "Let Erin Remember, High Road to Gairloch, The Minstrel Boy", "set": "band", "kind": "march", "n": 5644502},
	"band_farewell": {"style": "fifes", "title": "Soldiers' Farewell, Montezuma, March of War, Windsor Park", "set": "band", "kind": "march", "n": 5923605},
	"band_dundee": {"style": "pipes", "title": "Glendaruel, The Old Rustic Bridge, Bonnie Dundee, Campbell's Farewell", "set": "band", "kind": "march", "n": 8908785},
	"band_yankee": {"style": "fifes", "title": "Reveille, Drum Calls, the Scotches, Yankee Doodle", "set": "band", "kind": "march", "n": 6045453},
	"band_green": {"style": "pipes", "title": "God Save Ireland, The Boy from Killane, Wearing of the Green", "set": "band", "kind": "march", "n": 5730131},
	"band_paddy": {"style": "fifes", "title": "Paddy on the Handcar", "set": "band", "kind": "quick", "n": 2160517},
	"band_mist": {"style": "pipes", "title": "The Mist Covered Mountains", "set": "band", "kind": "air", "n": 5515124,
		"phrases": [16.41, 18.69, 25.7, 29.53, 37.71, 40.94, 47.38, 55.65, 60.2, 67.24, 73.13, 77.44, 85.16, 89.03, 98.02, 106.83, 115.83]},
	# a lone Drummer
	"drums_cornwallis": {"title": "The Rage of Cornwallis", "set": "drums", "kind": "march", "n": 5100418},
	"drums_generations": {"title": "Generations", "set": "drums", "kind": "march", "n": 4548151},
	"drums_calls": {"title": "Drum calls", "set": "drums", "kind": "march", "n": 1582085},
	# a lone Fifer
	"fife_lowlands": {"title": "Lowlands Away", "set": "fife", "kind": "air", "n": 1419679, "phrases": [14.13, 21.75]},
	"fife_trenton": {"title": "Trenton", "set": "fife", "kind": "quick", "n": 2665926},
	"fife_hornpipe": {"title": "Fisher's Hornpipe, Guilderoy, Red Haired Boy", "set": "fife", "kind": "quick", "n": 6615440},
	# a lone Piper (no solo pipe recording: his tunes rendered for one piper by tools/audio/band_own.py)
	"pipes_scotland": {"title": "Scotland the Brave", "set": "pipes", "kind": "march", "n": 1618871},
	"pipes_grenadiers": {"title": "The British Grenadiers", "set": "pipes", "kind": "march", "n": 1746360},
	"pipes_garryowen": {"title": "Garry Owen", "set": "pipes", "kind": "quick", "n": 1507025},
	"pipes_minstrel": {"title": "The Minstrel Boy", "set": "pipes", "kind": "air", "n": 2498580, "phrases": [14.19, 27.9, 41.61]},
}
## The playlists, in turn: the band's mixes pipe band and fife-and-drum corps tunes.
const ORDER := {
	"band": ["band_pipecalls", "band_scotland", "band_brandywine", "band_minstrel", "band_farewell", "band_dundee",
		"band_yankee", "band_green", "band_paddy", "band_lament", "band_mist", "band_drumslead"],
	"drums": ["drums_cornwallis", "drums_calls", "drums_generations"],
	"fife": ["fife_lowlands", "fife_trenton", "fife_hornpipe"],
	"pipes": ["pipes_scotland", "pipes_grenadiers", "pipes_garryowen", "pipes_minstrel"],
}
## A list's MAIN tunes, by what the band is doing: it comes back after every other tune (the others in turn between).
## "rest" is a slow air: the idle rule brings it (it is the list's first air).
const MAIN := {"band": {"march": "band_pipecalls", "fight": "band_drumslead", "rest": "band_lament"}}
const BAND_DB := -6.0       # a full band (files at -20 LUFS)
const LONE_DB := -9.0      # a lone musician: one man, quieter than a corps
const SOLO_DB := 6.0        # a SOLO: the heard music this much louder (owner may tune)
const CUT := 760.0          # screen px from the middle of the screen past which a band is not heard
const NEAR := 160.0         # screen px within which it is at full level
const ZOOM_OUT := 0.85      # zoomed out further than this: quieter (a band is small on the screen)
const DUCK_DB := -12.0      # the game music while a band is heard in the middle of the screen (the band leads)
const DUCK_SOLO_DB := -16.0 # ... while its solo is heard
const ZOOM_IN_DB := -2.0    # ... and up to this much more zoomed in (zoom 1 -> 2)
const DUCK_RATE := 10.0     # dB a second the music's duck moves by (-12 dB in 1.2 s; smooth, no pumping)
const FADE := 6.0           # dB a tenth of a second the levels move by (no clicks, no jumps)
const CUT_FADE := 1.2       # s: a slow air cut short at a phrase end fades out over this
const GAP := 2.0            # s of quiet between two tunes (a real band's pause)
const SWITCH := 90.0        # px: another band (or lone group) must be this much nearer to take over (no flip-flopping)
const LONE_MAX := 3         # lone musicians heard at once at most (the nearest)
const STEP_OFF := [0.23, 0.41, 0.62, 0.79]      # s into its tune a lone musician's playlist starts (by his number)
const IDLE_AIR := 30.0      # s standing still: the slow air may come next
const FIGHT_FOR := 6.0      # s since a musician was last hit: still fighting
const FIGHT_NEAR := 7.0     # tiles: an enemy this near the musicians = fighting
const SR := 44100.0

## One playlist: its set (band / drums / fife / pipes), the tune it is on, when that tune started (ms,
## Time.get_ticks_msec), where it is cut short (s; -1 played to its end), the tune before, and what it knows of its men.
class Playlist:
	var group := "band"
	var tune := "band_scotland"
	var start := 0
	var cut := -1.0
	var prev := ""
	var fighting := false
	var still_since := 0
	var where := Vector2.INF
	var played := 0          # tunes played through (tests)

static var me: BandSound

var game: Game
var focus: Unit = null       # the band heard now (its Drummer), or the nearest lone musician heard (null none)
var heard: Array = []        # the musicians heard now
var t0 := 0                  # the band's clock's start (ms)
var _band: Playlist          # every band's playlist (one: bands are in step with each other)
var _lone_pl := {}           # musician instance id -> his own Playlist
var _players := {}           # key -> AudioStreamPlayer: the band "B", the lone slots "L<i>"
var _target := {}            # key -> the level it is moving to (dB; -80 silent)
var _src := {}               # key -> the Playlist it plays
var _off := {}               # key -> how far into its tune its playlist started (s; 0 for the band)
var _lone := []              # lone slot i -> [musician, instrument] (or null)
var _streams := {}           # file -> its stream (decoded once, shared)
var _duck := 0.0
var _duck_target := 0.0
var _fx_idx := -1
var _sit_t := 0              # ms: the situation was last looked at (once a second)


## The match's band sound, made on first use (MarchingBand.look_tick; host, online guest and replay alike).
static func need(g: Game) -> BandSound:
	if me != null and is_instance_valid(me) and me.game == g:
		return me
	var n := BandSound.new()
	n.name = "BandSound"
	n.game = g
	g.add_child(n)
	me = n
	return n


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	t0 = Time.get_ticks_msec()
	_band = Playlist.new()
	_band.group = "band"
	_band.tune = ORDER["band"][0]
	_band.start = t0
	_band.still_since = t0
	_add_player("B")
	for i in LONE_MAX:
		_lone.append(null)
		_add_player("L%d" % i)


## The file of a tune (res://assets/audio/<file>.ogg).
static func file(tune: String) -> String:
	return "band/%s" % tune


## A tune's length (s).
static func length(tune: String) -> float:
	return float(TUNES[tune]["n"]) / SR


## The playlist an instrument's lone musician plays from.
static func set_of(ins: String) -> String:
	return ins if ORDER.has(ins) else "drums"


func _stream(f: String) -> AudioStream:
	if _streams.has(f):
		return _streams[f]
	var st: AudioStream = null
	var path := "res://assets/audio/%s.ogg" % f
	if ResourceLoader.exists(path):
		st = (load(path) as AudioStream).duplicate()
		if st is AudioStreamOggVorbis:
			(st as AudioStreamOggVorbis).loop = false
	_streams[f] = st
	return st


func _add_player(key: String) -> void:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX" if AudioServer.get_bus_index("SFX") >= 0 else "Master"
	if OS.has_feature("web"):
		p.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	p.volume_db = -80.0
	add_child(p)
	_players[key] = p
	_target[key] = -80.0
	_off[key] = 0.0


func _exit_tree() -> void:
	_set_duck(0.0)
	if me == self:
		me = null


# ---------------------------------------------------------------- the playlist

## The tune after `cur` in its set's list: the next in turn, never `cur` again; FIGHTING skips the slow airs; standing
## IDLE a while brings a slow air next (unless one was just played).
static func next_tune(cur: String, fighting: bool, idle: bool, prev := "", group := "") -> String:
	if group == "":
		group = String(TUNES[cur]["set"]) if TUNES.has(cur) else "band"
	var list: Array = ORDER[group]
	if idle and not fighting and not _is_air(cur) and not _is_air(prev):
		for c in list:
			if _is_air(c) and c != cur:
				return c
	var mains: Dictionary = MAIN.get(group, {})
	var main_list: Array = mains.values()
	if not mains.is_empty():
		var want: String = String(mains["fight"] if fighting else mains["march"])
		if cur != want and not main_list.has(cur):
			return want          # (the main tune for what they are doing, between every two others)
		if fighting and cur != want and main_list.has(cur):
			return want          # (a fight breaks out after the march's or the rest's main tune: the fight's next)
	var ref := cur
	if main_list.has(cur) and prev != "" and not main_list.has(prev) and list.has(prev):
		ref = prev           # (after a main tune: on from the tune before it)
	var i := list.find(ref)
	for k in range(1, list.size() + 1):
		var c: String = list[(i + k) % list.size()] if i >= 0 else list[(k - 1) % list.size()]
		if c == cur or main_list.has(c):
			continue
		if fighting and _is_air(c):
			continue
		if _is_air(c) and (_is_air(cur) or _is_air(prev)):
			continue             # (never two slow airs one after the other)
		return c
	return list[0] if cur != list[0] else list[1]


static func _is_air(t: String) -> bool:
	return TUNES.has(t) and String(TUNES[t]["kind"]) == "air"


## Where a playlist is in its tune now (s; past the tune's end: the pause before the next).
func pos(pl: Playlist) -> float:
	return float(Time.get_ticks_msec() - pl.start) / 1000.0


## Where its tune ends (s): its length, or the phrase end it is cut short at.
static func end_of(pl: Playlist) -> float:
	return pl.cut if pl.cut > 0.0 else length(pl.tune)


## Moves a playlist on: GAP s after its tune's end the next tune (next_tune, by what its men are doing). While they
## fight a slow air is cut short at its next phrase end.
func advance(pl: Playlist) -> void:
	var idle := float(Time.get_ticks_msec() - pl.still_since) / 1000.0 >= IDLE_AIR
	if pl.fighting and pl.cut < 0.0 and _is_air(pl.tune):
		var p := pos(pl)
		for ph in TUNES[pl.tune].get("phrases", []):
			if float(ph) > p + CUT_FADE + 0.05:
				pl.cut = float(ph)
				break
	var guard := 0
	while pos(pl) >= end_of(pl) + GAP and guard < 64:
		pl.start += int(round((end_of(pl) + GAP) * 1000.0))
		var nx := next_tune(pl.tune, pl.fighting, idle, pl.prev, pl.group)
		pl.prev = pl.tune
		pl.tune = nx
		pl.cut = -1.0
		pl.played += 1
		guard += 1


## dB to add for a playlist cut short: down to -60 over its last CUT_FADE s (no click at the phrase end).
func env_db(pl: Playlist) -> float:
	if pl.cut <= 0.0:
		return 0.0
	var left := pl.cut - pos(pl)
	return 0.0 if left >= CUT_FADE else -60.0 * clampf(1.0 - left / CUT_FADE, 0.0, 1.0)


## What the musicians `ms` are doing: hit lately, or an enemy near them = fighting; standing still since when.
func look(pl: Playlist, ms: Array) -> void:
	if ms.is_empty() or game == null:
		return
	var c := MarchingBand.centre(ms)
	var now := Time.get_ticks_msec()
	if pl.where == Vector2.INF or c.distance_to(pl.where) > 6.0:
		pl.where = c
		pl.still_since = now
	var f := false
	for m in ms:
		if is_instance_valid(m) and game.clock - float((m as Unit).hit_clock) < FIGHT_FOR:
			f = true
	if not f:
		var team := int((ms[0] as Unit).team)
		for o in game.units_near(c, FIGHT_NEAR * Defs.TILE):
			if o is Unit and not (o as Unit).dead and game.hostile((o as Unit).team, team):
				f = true
				break
	pl.fighting = f


## A lone musician's own playlist (made the first time he is heard): his instrument's list, started on a tune by his
## number and a little into it (offset_of), so two of them never play together.
func lone_list(u: Unit) -> Playlist:
	var k := u.get_instance_id()
	if not _lone_pl.has(k):
		var pl := Playlist.new()
		pl.group = set_of(MarchingBand.ins_of(u))
		var list: Array = ORDER[pl.group]
		var n := int(u.band.get("id", 0))
		pl.tune = list[n % list.size()]
		if _is_air(pl.tune):
			pl.tune = list[(n + 1) % list.size()]
		pl.start = Time.get_ticks_msec() - int(offset_of(u) * 1000.0)
		pl.still_since = Time.get_ticks_msec()
		_lone_pl[k] = pl
		if _lone_pl.size() > 64:        # (forget the long gone)
			for kk in _lone_pl.keys():
				if not is_instance_valid(instance_from_id(kk)):
					_lone_pl.erase(kk)
	return _lone_pl[k]


## Where the band's clock is in its tune now (s); `off`: an offset added. (tests)
func phase(off := 0.0) -> float:
	return pos(_band) + off


## How far into his tune a lone musician's playlist starts (s): by his number.
static func offset_of(u: Unit) -> float:
	return float(STEP_OFF[int(u.band.get("id", 0)) % STEP_OFF.size()])


## (tests) the band's playlist.
func band_list() -> Playlist:
	return _band


## The level each player should play at now (all -80 when nothing is heard), and what it plays (_src). Also the music
## duck. Lone slots are (re)assigned to the musicians heard.
func targets() -> Dictionary:
	var out := {}
	for k in _players:
		out[k] = -80.0
	_duck_target = 0.0
	heard = pick()
	focus = heard[0] if not heard.is_empty() else null
	var now := Time.get_ticks_msec()
	var looking := now - _sit_t >= 1000
	if looking:
		_sit_t = now
	if heard.is_empty() or not MarchingBand.in_band(heard[0]):
		if looking:
			_band.fighting = false
			_band.still_since = now      # (idle means a band heard standing still, not a band nobody hears)
			_band.where = Vector2.INF
	if heard.is_empty():
		for i in LONE_MAX:
			_lone[i] = null
		return out
	var solo_on := false
	if MarchingBand.in_band(heard[0]):
		# the band: one full recording, on the band's playlist
		if looking:
			look(_band, heard)
		var lvl := level(MarchingBand.centre(heard))
		if lvl <= -60.0:
			return out
		for m in heard:
			if MarchingBand.lead(m) != "":
				solo_on = true
		_src["B"] = _band
		out["B"] = BAND_DB + lvl + (SOLO_DB if solo_on else 0.0)
		for i in LONE_MAX:
			_lone[i] = null
		_duck_target = duck_for(lvl, solo_on)
		return out
	# lone musicians: each his own instrument's recordings, on his own playlist
	var keep := {}
	for i in LONE_MAX:
		var sl = _lone[i]
		if sl != null and heard.has(sl[0]):
			keep[sl[0]] = i
		else:
			_lone[i] = null
	var best_lvl := -80.0
	for m in heard:
		var i := int(keep.get(m, -1))
		if i < 0:
			i = _lone.find(null)
			if i < 0:
				continue
			_lone[i] = [m, MarchingBand.ins_of(m)]
		var lvl2 := level(m.position)
		best_lvl = maxf(best_lvl, lvl2)
		var pl := lone_list(m)
		if looking:
			look(pl, [m])
		_src["L%d" % i] = pl
		_off["L%d" % i] = offset_of(m)
		var so := MarchingBand.lead(m) != ""
		solo_on = solo_on or so
		out["L%d" % i] = LONE_DB + lvl2 + (SOLO_DB if so else 0.0)
	_duck_target = duck_for(best_lvl, solo_on)
	return out


## How far the game music is ducked (dB) under music heard at level `lvl` (level(): 0 in the middle of the screen,
## down to -30 at CUT, less zoomed out): the full DUCK_DB / DUCK_SOLO_DB near the middle, fading out by lvl -24 (640 px
## from the middle), plus up to ZOOM_IN_DB zoomed in.
func duck_for(lvl: float, solo: bool) -> float:
	var near := clampf(1.0 + lvl / 24.0, 0.0, 1.0)
	var d := (DUCK_SOLO_DB if solo else DUCK_DB) * near
	var cam: Camera2D = game.camera if game != null and game.get("camera") != null else null
	if cam != null and is_instance_valid(cam) and cam.zoom.x > 1.0:
		d += ZOOM_IN_DB * clampf(cam.zoom.x - 1.0, 0.0, 1.0) * near
	return d


## (tests) the game music's duck now and where it is moving to (dB).
func duck_now() -> Vector2:
	return Vector2(_duck, _duck_target)


## Who is heard: the nearest BAND (its members) or the nearest LONE_MAX lone musicians, whichever is nearest the middle
## of the screen (a solo counts 400 px nearer); what is heard now keeps it unless the other is SWITCH px nearer.
func pick() -> Array:
	if game == null or not is_instance_valid(game) or Sfx.hush:
		return []
	var bands := {}         # key -> [score, members]
	var lones: Array = []   # [score, musician]
	for u in game.units:
		if not MarchingBand.is_musician(u) or u.dead or not u.visible or u.band.is_empty() or MarchingBand.legacy(u):
			continue
		var d := screen_dist(u.position)
		if d > CUT or not Sfx.heard("band/drums", u.position):
			continue
		var sc := d - (400.0 if MarchingBand.lead(u) != "" else 0.0)
		if MarchingBand.in_band(u):
			var key := "%d:%d" % [u.team, MarchingBand.band_key(u)]
			if not bands.has(key):
				bands[key] = [INF, MarchingBand.mates(u)]
			bands[key][0] = minf(float(bands[key][0]), sc)
		else:
			lones.append([sc, u])
	var best_band: Array = []
	var bb := INF
	var cur_key := ""
	for k in bands:
		if not heard.is_empty() and is_instance_valid(heard[0]) and (bands[k][1] as Array).has(heard[0]):
			cur_key = k
		if float(bands[k][0]) < bb:
			bb = float(bands[k][0])
			best_band = bands[k][1]
	if cur_key != "" and float(bands[cur_key][0]) < bb + SWITCH:
		best_band = bands[cur_key][1]       # (the band heard now keeps it unless another is SWITCH px nearer)
		bb = float(bands[cur_key][0])
	lones.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	var bl := float(lones[0][0]) if not lones.is_empty() else INF
	if not best_band.is_empty() and bb <= bl:
		return best_band
	var out: Array = []
	for i in mini(LONE_MAX, lones.size()):
		out.append(lones[i][1])
	return out


## Screen px from the middle of the screen to a place.
func screen_dist(at: Vector2) -> float:
	var cam: Camera2D = game.camera if game.get("camera") != null else null
	if cam == null or not is_instance_valid(cam):
		return 0.0
	return at.distance_to(cam.get_screen_center_position()) * cam.zoom.x


## dB to add for where the music is: 0 near the middle of the screen, down to -30 at CUT; zoomed far out a little less.
func level(at: Vector2) -> float:
	var d := screen_dist(at)
	var db := -30.0 * clampf((d - NEAR) / (CUT - NEAR), 0.0, 1.0)
	var cam: Camera2D = game.camera if game.get("camera") != null else null
	if cam != null and is_instance_valid(cam) and cam.zoom.x < ZOOM_OUT:
		db -= (ZOOM_OUT - cam.zoom.x) * 18.0
	return db


func _process(delta: float) -> void:
	var paused := get_tree().paused or game == null or not is_instance_valid(game)
	_target = {} if paused else targets()
	if paused:
		for f in _players:
			_target[f] = -80.0
		_duck_target = 0.0
	advance(_band)
	var step := FADE * delta * 10.0
	var any := false
	var moved := {}
	for f in _players:
		var p: AudioStreamPlayer = _players[f]
		var want := float(_target.get(f, -80.0))
		var cur := p.volume_db if p.playing else -80.0
		var pl = _src.get(f)
		if pl == null:
			if p.playing:
				p.stop()
			continue
		if not moved.has(pl):
			advance(pl)
			moved[pl] = true
		var nv := move_toward(cur, want, step)
		if nv <= -79.0 and want <= -79.0:
			if p.playing:
				p.stop()
			continue
		var st := _stream(file((pl as Playlist).tune))
		if st == null:
			continue
		var ph := pos(pl)
		if p.stream != st:
			p.stop()
			p.stream = st
		any = true
		var env := env_db(pl)
		p.volume_db = nv + env
		if ph >= end_of(pl) - 0.02:
			if p.playing:
				p.stop()             # (the pause between two tunes: the next starts when the playlist moves on)
			continue
		if not p.playing:
			p.play(ph)               # (the band on the band's clock; a lone musician on his own playlist)
		elif absf(p.get_playback_position() - ph) > 0.08:
			p.seek(ph)               # (drifted: back where it should be)
	_duck = move_toward(_duck, _duck_target if any else 0.0, DUCK_RATE * delta)
	_set_duck(_duck)


## The game music's duck: an Amplify effect on the Music bus (added once; the volume slider is left alone).
func _set_duck(db: float) -> void:
	var bus := AudioServer.get_bus_index("Music")
	if bus < 0:
		return
	if _fx_idx < 0 or _fx_idx >= AudioServer.get_bus_effect_count(bus) or not (AudioServer.get_bus_effect(bus, _fx_idx) is AudioEffectAmplify) \
			or AudioServer.get_bus_effect(bus, _fx_idx).resource_name != "band_duck":
		_fx_idx = -1
		for i in AudioServer.get_bus_effect_count(bus):
			var e := AudioServer.get_bus_effect(bus, i)
			if e is AudioEffectAmplify and e.resource_name == "band_duck":
				_fx_idx = i
		if _fx_idx < 0:
			if absf(db) < 0.01:
				return
			var amp := AudioEffectAmplify.new()
			amp.resource_name = "band_duck"
			AudioServer.add_bus_effect(bus, amp)
			_fx_idx = AudioServer.get_bus_effect_count(bus) - 1
	(AudioServer.get_bus_effect(bus, _fx_idx) as AudioEffectAmplify).volume_db = db


## (tests) the level each player is moving to now.
func levels() -> Dictionary:
	return targets()


## (tests) how far into its tune each player's playlist started (s).
func offsets() -> Dictionary:
	return _off.duplicate()


## (tests) the tune each player plays now ("" none).
func tunes_now() -> Dictionary:
	var out := {}
	for k in _players:
		var s = _src.get(k)
		out[k] = (s as Playlist).tune if s != null else ""
	return out
