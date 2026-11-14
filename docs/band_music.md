# The Marching Band's music (jobs band-music 0.37.1, band-music-v2 0.37.4, band-repertoire and band-real)

## Real recordings (band-real)

The owner's playtest of 0.37.9 (2026-11-14 19:17): the generated band "unfortunately doesn't sound good". He gathered
real public-domain recordings (art/audio_src/band_real/, SOURCES.txt) and this job rebuilt the band's sound around them.
The game rules are unchanged (docs/band_individuals.md): a Drummer, a Fifer and a Piper in each other's rings FORM A
BAND, in step; lone musicians are out of step; SOLO; the game music ducks under a band (BandSound.duck_for).

### What plays when (scripts/band_sound.gd)

A real recording is a mix: its parts can't be split. So:

- **A full band** (all three in step) plays FULL recordings from one playlist, pipe band tunes and fife-and-drum corps
  tunes in turn (ORDER["band"]: Scotland the Brave, Brandywine Quickstep, the Minstrel Boy set, Soldiers' Farewell /
  March of War, the Bonnie Dundee set, the Scotch / Yankee Doodle medley, the Wearing of the Green set, Paddy on the
  Handcar, The Mist Covered Mountains). Every band has all three instruments, so both kinds are in the one list,
  alternating; never the same tune twice in a row. All bands share that playlist (one clock), as before.
- **A lone Drummer** plays the drums-only recordings (ORDER["drums"]): The Rage of Cornwallis, Drum calls (three
  drum-only passages cut from other Old Guard pieces, joined with 1.2 s pauses), Generations.
- **A lone Fifer** plays the Old Guard's fife features (ORDER["fife"]): Lowlands Away (a slow air), Trenton, Fisher's
  Hornpipe / Guilderoy / Red Haired Boy.
- **A lone Piper**: NO recording has a solo pipe passage long enough. Measured: every pipe band track opens with the
  drums' roll, the pipes strike in with the drums, and the cleanest pipe-only stretches (no snare between the pipe
  harmonics) last 1-2 s. So the lone Piper keeps the OLD generated piper part (Scotland the Brave, The British
  Grenadiers, Garry Owen, The Minstrel Boy; the 0.37.9 files moved to art/audio_src/band/generated_piper/, re-levelled
  and trimmed of their roll-off silence). Only the lone Piper uses them.
- **Two musicians** (not a full band) and lone musicians of different instruments near each other: each plays his own
  instrument's list on his own playlist (started on a tune by his number, a little into it: STEP_OFF), so they stay
  out of step, as before; at most LONE_MAX (3) heard.
- **Between tunes** a pause of GAP (2 s), like a real band's. FIGHTING skips the slow airs (The Mist Covered
  Mountains, Lowlands Away, the piper's Minstrel Boy); one playing when fighting starts fades out over CUT_FADE (1.2 s)
  at its next phrase end (TUNES "phrases": the quietest moment in each ~9 s window, found by the script). Standing
  IDLE 30 s, a slow air may come next.
- **A SOLO**: a part of a mix can't come forward, so the heard music (the band's recording, or the lone soloist's own)
  gets SOLO_DB (+6 dB, the owner can tune it) louder for the solo's length and the game music goes to DUCK_SOLO_DB
  (-16 dB); the playlist goes on (no restart), then both come back smoothly.
- **Levels**: every file -20 LUFS; a band plays at BAND_DB -6 dB, a lone musician at LONE_DB -9 dB (one man is quieter
  than a corps); the game music's duck as before (-12 dB centred, -16 during a solo).

### The cuts (tools/audio/master_band_real.py; the numbers in tools/audio/band_real.json)

Each cut: the source's times below (after trimming silence), a 10 ms fade-in, a fade-out only where the cut ends
inside the music (the drum calls 0.25 s, Lowlands Away 0.3 s; whole pieces keep their own ending), a 35 Hz high-pass,
FOLDED TO MONO (a band in the game is one point; half the size), gained to -20 LUFS with at most 6 dB of look-ahead
true-peak limiting (the Old Guard's drums are peaky: Soldiers' Farewell got 5.6 dB, the drum calls 5.1, the Yankee
Doodle medley 4.5, The Rage of Cornwallis 4.0; the pipe bands none), true peak under -1 dBTP after Vorbis -q:a 4.
All 19 land within -19.97 to -20.9 LUFS.

| File (assets/audio/band/) | List | Kind | What | Source and times | Length |
|---|---|---|---|---|---|
| `band_scotland` | band | march | Scotland the Brave (USAF Reserve Pipe Band) | scotland_the_brave_usafr_pipe_band.mp3 0.41-91.58 s | 91.2 s |
| `band_brandywine` | band | quick | Brandywine Quickstep (Old Guard Fife and Drum Corps) | oldguard_10_brandywine_quickstep_from_the_minstrel_boy_show.mp3 0.45-110.66 s | 110.2 s |
| `band_minstrel` | band | march | Let Erin Remember, High Road to Gairloch, The Minstrel Boy (USAF Reserve Pipe Band) | let_erin_remember_high_road_to_gairloch_minstrel_boy_usafr_pipe_band.mp3 0.45-128.44 s | 128.0 s |
| `band_farewell` | band | march | Soldiers' Farewell, Fanfare, Montezuma, March of War, Windsor Park (Old Guard) | oldguard_07_soldiers_farewell_fanfaremontezumamarch_of_warwindsor_park.mp3 0.51-134.84 s | 134.3 s |
| `band_dundee` | band | march | The Dream Valley of Glendaruel, The Old Rustic Bridge, Bonnie Dundee, Campbell's Farewell (USAFR) | dream_valley_old_rustic_bridge_bonnie_dundee_campbells_farewell_usafr_pipe_band.mp3 0.39-202.40 s | 202.0 s |
| `band_yankee` | band | march | Reveille, Drum Calls, Slow and Quick Scotch, Yankee Doodle (Old Guard) | oldguard_09_reveille_variationdrum_callslow_scotchquick_scotchyankee_doodlemont.mp3 0.50-137.59 s | 137.1 s |
| `band_green` | band | march | God Save Ireland, The Boy from Killane, Wearing of the Green (USAF Reserve Pipe Band) | god_save_ireland_boy_from_killane_wearing_of_the_green_usafr_pipe_band.mp3 0.40-130.33 s | 129.9 s |
| `band_paddy` | band | quick | Paddy on the Handcar (Old Guard Fife and Drum Corps) | oldguard_12_paddy_on_the_handcar_from_the_minstrel_boy_show.mp3 0.49-49.48 s | 49.0 s |
| `band_mist` | band | air | The Mist Covered Mountains (USAF Reserve Pipe Band) | mist_covered_mountains_usafr_pipe_band.mp3 0.40-125.46 s | 125.1 s |
| `drums_cornwallis` | drums | march | The Rage of Cornwallis (Old Guard drum feature) | oldguard_06_drum_feature_the_rage_of_cornwallis_from_the_george_washington_show.mp3 0.00-115.66 s | 115.7 s |
| `drums_generations` | drums | march | Generations (Old Guard drum feature) | oldguard_16_drum_feature_generations_from_the_simple_gifts_show.mp3 0.00-103.13 s | 103.1 s |
| `drums_calls` | drums | march | Drum calls (the drums alone in three Old Guard pieces) | oldguard_09_reveille_variationdrum_callslow_scotchquick_scotchyankee_doodlemont.mp3 0.50-10.15 s; oldguard_07_soldiers_farewell_fanfaremontezumamarch_of_warwindsor_park.mp3 20.12-29.45 s; oldguard_15_simple_giftssimple_interludestorm_in_the_valley_from_the_simple_gifts_show.mp3 72.40-86.90 s | 35.9 s |
| `fife_lowlands` | fife | air | Lowlands Away (Old Guard fife feature) | oldguard_04_fife_feature_lowlands_awaytrenton_from_the_george_washington_show.mp3 0.71-32.90 s | 32.2 s |
| `fife_trenton` | fife | quick | Trenton (Old Guard fife feature) | oldguard_04_fife_feature_lowlands_awaytrenton_from_the_george_washington_show.mp3 33.55-94.00 s | 60.5 s |
| `fife_hornpipe` | fife | quick | Fisher's Hornpipe, Guilderoy, Red Haired Boy (Old Guard fife feature) | oldguard_11_fife_feature_fishers_hornpipe_variationguilderoyred_haired_boy.mp3 0.46-150.47 s | 150.0 s |
| `pipes_scotland` | pipes | march | Scotland the Brave (generated piper) | scotland_pipes.ogg 2.46-40.17 s | 37.7 s |
| `pipes_grenadiers` | pipes | march | The British Grenadiers (generated piper) | grenadiers_pipes.ogg 2.25-43.50 s | 41.2 s |
| `pipes_garryowen` | pipes | quick | Garry Owen (generated piper) | garryowen_pipes.ogg 0.40-35.31 s | 34.9 s |
| `pipes_minstrel` | pipes | air | The Minstrel Boy (generated piper) | minstrel_pipes.ogg 0.80-59.19 s | 58.4 s |

**Left out**: the US Army Field Band's Garryowen, the USMC Band's Scotland the Brave and the Royal Regiment of Canada
Band's British Grenadiers are CONCERT / brass bands (brass and low reeds fill the whole spectrum), not pipes, fifes and
drums; the Canadian file's public-domain reason could not be checked from here either (the Commons page could not be
fetched), so it is not used in any case. The second USAF Scotland the Brave (1995) is a second take of the same tune
(not used: two Scotlands could come one after the other). The Old Guard's Three Little Drummers (its fifes join after
10 s, then stops and starts), Simple Gifts / Storm in the Valley (only its drum-only passage, in the drum calls) and the
Eraf/Naf fanfare are not in the lists. The owner's earlier note: Yankee Doodle and the Revolution's tunes fit the Crown
badly (it is the rebels' tune): the Scotch / Yankee Doodle medley is in the band's list because this job's brief named
it; drop `band_yankee` from ORDER["band"] if it jars.

### How it was measured

No one listened (a cloud job): every source was measured (tools/music/study_audio.py-style loudness; spectrograms;
a TONALITY measure, the share of the 700-4500 Hz energy in its strongest 2% of bins, per half second: drums alone
0.12-0.2, any fife 0.4-1.0, which found the drum-only passages; and the noise floor between the pipe harmonics at
5-10 kHz, which found no pipe-only passage longer than 2 s). The cut points of the drum calls and of Lowlands Away /
Trenton are at those boundaries (Lowlands Away ends in a 0.4 s silence at 32.9 s). Listen to the files before merging:
if a cut is off by a beat it is one number in CUTS.

### Size

assets/audio/band/ was 10.0 MB (60 generated files), now 17.0 MB (19 files, mono): the web art pack grows ~7 MB.
In stereo it would be ~27 MB.

### Checked

- tools/test_band_music.gd: every file exists at its exact length; four lists, every tune in its own; the band's list
  never three of one kind running; per list: never the same tune twice, no slow air while fighting, every tune comes
  round, idle brings the air; the pause between tunes; the slow air cut at a phrase end and faded; with the movie
  writer mixing: every file begins with sound and ends quietly, all within 6 dB of each other mid-tune, players in step.
- tools/test_marching_band.gd (the sound part): a band near the middle = ONE recording heard (its three men), on the
  band's clock and playlist; the duck; a SOLO keeps the tune and raises it SOLO_DB; lone musicians each their own
  file, out of step, at most 3; a lone Drummer plays a drums-only recording at LONE_DB.

### The listening files (docs/band_sound/, mp3; LIST.txt has one line each)

| File | What you hear |
|---|---|
| `01_lone_drummer` | the end of his drum calls, the pause, the start of Generations (-18 LUFS) |
| `01_lone_fifer` | the end of Lowlands Away, the pause, the start of Trenton (-18 LUFS) |
| `01_lone_piper` | the old generated piper part (Scotland the Brave) he keeps (-18 LUFS) |
| `02_full_band_two_changes` | the end of Wearing of the Green, the pause, all of Paddy on the Handcar, the pause, the start of The Mist Covered Mountains (-18 LUFS) |
| `03_full_band_over_battle_music` | Scotland the Brave over the Crown's Musketeer Charge, the band centred, the music ducked 12 dB: the game's mix at its own level |
| `04_solo_over_battle_music` | the same with a SOLO from 15 s to 30 s: the band +6 dB, the music -16 dB, then back |

To remake: `python3 tools/audio/master_band_real.py --json tools/audio/band_real.json` (then copy the "n" and
"phrases" numbers into BandSound.TUNES) and `python3 tools/audio/band_real_listen.py`. Needs ffmpeg, numpy, scipy,
pyloudnorm. tools/audio/make_band_music.py (the generated band) is kept but no longer writes files the game plays.

### Credits

All recordings are performances by US military bands, works of the US federal government (public domain in the US):
the US Army Old Guard Fife and Drum Corps' album "Celebrating 50 Years" (2014, Free Music Archive, Public Domain Mark
1.0) and the US Air Force Reserve Band's Pipe Band (Wikimedia Commons, marked public domain). Rows in
docs/audio_credits.md.

### For the owner

- Is +6 dB right for a solo, and -6 / -9 dB for a band / a lone musician (a band now sits ~5 dB louder than the old
  generated parts did together)?
- The Mist Covered Mountains is treated as a slow air (skipped while fighting); is it?
- Yankee Doodle in the Crown's band: keep or drop?
- A lone Piper still plays the generated part: if a recording of a solo piper turns up (a pipe major's solo, a
  lament), it goes in ORDER["pipes"] and the generated files can go.

## Repertoire and playlist (job band-repertoire; replaced by the real recordings above: its files and listening files are gone, the lone Piper keeps its piper part)

The owner's playtest (2026-11-14 13:18): (1) a lone DRUMMER played nothing in the background while the Piper and the
Fifer each had a quiet part; (2) the FIFE and the DRUMS were barely audible next to the pipes; (3) no single tune on
loop: the musicians go through a list of tunes; (4) a SOLO does not switch the tune: the tune playing gets louder (the
soloist's part forward) and the game music goes down further, then both come back; (5) keep the duck of the game music
when the band is near the middle of the screen. All five are in. (Branched from origin/main, which already had
band-music-v2.)

### Why the Drummer was silent and the fife and drums were faint

Not a missing file: the always-on drum loop was there and BandSound played it. But every file had been levelled by its
**loudest 0.3 s** (the old make_mix.py measure). For a steady sound (the pipes) that is close to how loud it sounds; for
drums (short loud strokes with silence between) it is far above it, so the drum files were turned far down. Measured
(integrated loudness, LUFS, ITU-R BS.1770), as the game played them (the always-on files at QUIET_DB -15):

| 0.37.5 | drums | fife | pipes | the band |
|---|---|---|---|---|
| each alone (LUFS) | **-48.3** | -40.2 | -37.3 | -35.3 |

The Drummer was 11 LU under the Piper, at the edge of hearing under any battle (and a BandSound fade-in rounding edge
case could keep a part from starting at exactly 60 frames a second: fixed too, a part now always starts when it is
wanted).

### The rebalance (measured)

Every file is now levelled by its **integrated loudness** (pyloudnorm), with a soft look-ahead limiter on the drum
peaks: background (always-on) files at -27 LUFS, solo files 4 LU louder (-23), the pipes 2 LU back and the fife 0.5 up
(the pipes' drones fill every band and cover the others), the drums 1 up; the background pipes' drones 3 dB further
back and their top (3.3 kHz) 4 dB down, the snare's wires a little brighter. BandSound plays the background parts at
QUIET_DB -9 (was -15: the files are quieter now, the Piper sounds about as before), a solo at LEAD_DB -3 (was -1), the
others under a solo at UNDER_DB -10 (was -19: the tune goes on as it was).

| (as the game plays them) | drums | fife | pipes | the band | the fife's tune over the rest | the snare over the rest |
|---|---|---|---|---|---|---|
| BEFORE (0.37.5) | -48.3 | -40.2 | -37.3 | -35.3 | +12.7 dB | **-10.0 dB** |
| Scotland the Brave | -35.0 | -35.5 | -38.0 | -31.6 | +15.7 dB | +7.1 dB |
| The British Grenadiers | -35.0 | -35.5 | -38.0 | -31.4 | +17.1 dB | +3.6 dB |
| Garry Owen | -35.0 | -35.5 | -38.0 | -31.3 | +16.8 dB | +3.0 dB |
| The Minstrel Boy | -39.9 (a muffled drum) | -35.5 | -38.0 | -33.4 | +17.2 dB | (no snare) |
| God Save the King | -35.0 | -35.5 | -38.0 | -32.1 | +17.9 dB | +5.8 dB |

The three parts alone are within **3 LU** (the brief: about 3). "The fife's tune over the rest": the fife's strongest
partial between 600 and 1,800 Hz (its melody) against the drums and pipes at the same pitch, each 0.1 s, the median.
"The snare over the rest": the drums against the others in 2-8 kHz on the strongest tenth of the drums' 12 ms frames
(the strokes). Both: the snare's strokes now stand 3-7 dB over the pipes' brightness where they were 10 dB under it.
Made by `python3 tools/audio/band_balance.py`. In the engine (tools/test_band_music.gd, the mixer's own output, a
rough loudness: RMS after a high-pass) the background parts alone are within 4 dB in every tune (3.0-3.6; at the merge, 0.37.9, Scotland and God Save the King measured 4.7 and 4.6, so PART_LU went from pipes -2.0 / fife +0.5 to pipes -1.5 / fife 0.0).

### The tunes

| Tune | Metre, tempo | Written | Sounds in | Bars | File | Notes |
|---|---|---|---|---|---|---|
| The British Grenadiers | 2/4, crotchet 100 | G | **A** | 32 + pick-up | 43.5 s | from the owner's score ("half note = 50": read as crotchet 100; his reference recording was ~108); A A B A' |
| Scotland the Brave | 4/4, 110 | D | **E** | 16 | 40.2 s | as band-music-v2 made it from the owner's score (now exactly 110: no loop to fit) |
| Garry Owen | 6/8, dotted crotchet 118 | A dorian (one sharp) | **F# dorian** | 32 + pick-up | 35.3 s | the quickstep; both strains repeated; the ABC ends every strain on A, so it is read as A dorian, not G |
| The Minstrel Boy | 4/4, crotchet 70 | G | **G** | 16 + pick-up | 59.2 s | the slow air: A A B A; the B part's last bar ("e>d ef gf e", seven eighths) gets a D, the pick-up back into A; the last A ends on a held G |
| God Save the King | 3/4, crotchet 72 | G | **G** | 14 | 40.9 s | the extra (below) |

Keys: each tune where the recorded chanter fits it with the least retuning (the chanter's measured takes run from about
E4 to G5; the fife sounds an octave over the pipes): every tune's notes lie within about 1.3 semitones of a take (Garry
Owen's top B, G#5 here, is the furthest). The drones are the recorded G drones moved to each tune's tonic (A: up 2, E:
down 3, F#: down 1, G: as recorded); just intonation over them (Garry Owen's dorian with a 6/5 third and a 9/5 seventh).
The tunes change key between them, as a fife and drum corps does; the roll-off between them gives the ear a moment.

**Each tune is one file per part**: `assets/audio/band/<tune>_<drums|fife|pipes>[_lead].ogg` (30 files, 10.4 MB; Ogg
Vorbis q3, mono), each `[the roll-off][the tune once][0.9 s tail]`, all six of a tune exactly the same length
(BandSound.TUNES "n" samples). The ROLL-OFF is in the new tune's tempo: two rolls, each into an accent (4/4: two
3-beat buzz rolls; 2/4: two 2-bar rolls, the second's accent on the pick-up's beat; 6/8: two rolls, then a 7-stroke
roll into bar 1; 3/4: one long roll swelling into the first beat; the slow air: one soft roll, snares off, and the
muffled drum). The pipes **strike in** during the roll-off (the drones, then the chanter on the fifth for the last beat,
as a pipe band does); the fife waits for the tune. So a lone Fifer has a short rest between tunes, a lone Piper his
drones, a lone Drummer his roll-off.

**The drum beatings are our own**, written in the style of the Twin City Fife and Drum Corps' parts (the owner has
copies; they are their arrangements, NOT in the repo and NOT copied; only the style description in the brief was used):
- Garry Owen (6/8 quickstep): a 7-stroke roll into bar 1's accent; straight quavers accented on the dotted-crotchet
  beats (flams); at the 2-bar phrase ends a six-note semiquaver run into an accented dotted crotchet, or two 7-stroke
  rolls; the second strain with more flams and rolls; the end an accented crotchet and rest; the bass drum on the
  dotted-crotchet beats (the solo doubles the quavers now and then).
- The British Grenadiers (2/4): flams on the beats, 5- and 7-stroke rolls into beat 2 at phrase ends, drags, a buzz
  roll into the last strain's pick-up; the solo with ghost notes and 9-stroke rolls; the bass on both beats.
- God Save the King (3/4): a flam on beat 1, taps on 2 and 3, a roll swelling from beat 3 into the next bar at phrase
  ends; the bass on 1.
- The Minstrel Boy (slow air): no snare beating; a muffled bass drum (a cloth on the head) on beat 1, a soft roll
  (snares off) over the last two beats of each phrase; the solo adds a soft beat 3 and tenor strokes. Its drums sit
  5 LU under the others' on purpose (a muffled drum, not a beating).
- Scotland the Brave keeps band-music-v2's pattern (after the owner's score), now ending on the cadence instead of
  rolling back into the loop.
Snare velocity layers by the stroke's force (ghost notes, accents, rolls as soft alternating strokes swelling into the
accent), flams as a grace stroke 26 ms before the main one, drags 62 and 40 ms before.

### The playlist (scripts/band_sound.gd)

- **The list** (`BandSound.ORDER`): The British Grenadiers, Scotland the Brave, Garry Owen, The Minstrel Boy, in turn.
- **Claude's choice: the situation only shapes the order** (the owner had chosen "tunes by situation"; with point 3,
  combined this way): while the band's men are **fighting** (one was hit in the last 6 s, or an enemy is within 7
  tiles) the slow air is skipped, and if it is already playing it **stops at its next phrase end** (BandSound.TUNES
  "phrases": the 4-bar phrase ends, at the next phrase's pick-up; a 0.18 s fade, no click) and a march or the quickstep
  follows; **standing idle** 30 s (a heard band that has not moved) the slow air comes next (unless it was just played);
  otherwise in turn. **Never the same tune twice in a row.** Tunes change only at a tune's end (or that phrase end).
- **A band** (any band: they share one playlist and one clock, so a band heard after another is in step and the music
  does not restart) plays all its parts from the same place in the same tune.
- **Lone musicians** keep their own playlists, each started a little off the band's clock (STEP_OFF 0.23-0.79 s, by
  his number) and moved on by his own situation, so they still sound out of step as before: each plays his own part
  of whatever tune his own playlist is on.
- **A solo** plays the soloist's solo file of **the same tune at the same place**: his part comes forward (LEAD_DB -3
  on a file 4 LU louder: about 10 dB over his background part), the others go on just under it (UNDER_DB -10), and the
  game music goes down to DUCK_SOLO_DB -16 (from -12); at the solo's end both come back at the usual speeds (FADE 60
  dB/s for the parts, DUCK_RATE 10 dB/s for the music). The tune never changes for a solo.
- **The duck** of the game music near the middle of the screen is as band-music-v2 made it (-12 dB, less further out).
- Light: the 30 files load once each into one shared cache (compressed in memory, ~10 MB (was 2 MB for the six loops: the web build's art pack grows by ~8 MB); decoded while playing, as
  before), the same 12 players as before (a band's 6, the lone slots' 6); the situation is looked at once a second.

**God Save the King** is rendered (its six files are in assets/audio/band/) but **not used yet**: a Crown victory ends
the match into the result screen, where the band's sound engine is not running; playing it there would be a new path
(the Music player's victory music, not the band). A decision for the owner (a victory sting? the result screen?).

### Checked

- `tools/test_band_music.gd` (with the movie writer, every check; all pass): every tune's six files, each exactly the
  tune's length; the playlist (4,000 random situations: never a repeat, never the slow air while fighting, every tune
  comes round; in turn when marching; idle brings the slow air; a playlist at a tune's end carries its clock into the
  next tune; fighting during the slow air cuts it at its next phrase end, faded, then a march); the background parts
  alone within 4 dB of each other in every tune (the drummer clearly heard), each solo part louder than its background
  part; every tune change in the list, every part, without a click, each tune ending quietly in its tail and the next
  beginning with the roll-off; two parts in step (2.5 ms) and with the band's clock (9 ms).
- `tools/test_marching_band.gd` (now 95 checks, all pass; new ones): a band's three parts on the band's playlist, the
  same tune; a SOLO does not change the tune (the fife's solo part of the tune playing comes forward, its background
  part off, the others still heard, the music -16 dB); a LONE DRUMMER is heard, his background beating at the
  background level on a tune of the list. `test_files.gd`: pass. `test_marching_band_match.gd` FAILS, on main
  too (checked with main's band scripts): the Hard Crown computer trains no musicians at all in the match (v the Brood
  it loses first; `vs:crown` 12 min, none either), so its band checks find nothing: an AI matter, not the sound.
- Pitch (tools: the fife and the pipes' solo files, every note of every tune, at its middle): within 50 cents of the
  note, all but Garry Owen's top B where the tracker reads the octave (the spectrum shows the right note).

### The listening files (docs/band_sound/, mp3, LIST.txt has one line each)

| File | What you hear |
|---|---|
| `01_lone_drummer_background`, `01_lone_fifer_background`, `01_lone_piper_background` | each lone musician's background part: the end of The British Grenadiers, the roll-off, Scotland the Brave |
| `02_full_band_background` | the full band playing along over the same change |
| `03_playlist_two_changes` | 60 s: the end of Scotland the Brave, the roll-off, all of Garry Owen, the roll-off, the start of The Minstrel Boy |
| `04_fife_solo_over_battle_music`, `04_drums_solo_...`, `04_pipes_solo_...` | The British Grenadiers over the Crown's battle music, the band centred (the music -12 dB); one instrument solos from 15 s to 30 s: the same tune, his part forward, the music -16 dB, then back |
| `05a_BEFORE_full_band_over_battle_music`, `05b_BEFORE_lone_drummer_...` | 0.37.5's files at 0.37.5's levels in the same scene |
| `05c_AFTER_full_band_over_battle_music`, `05d_AFTER_lone_drummer_...` | the same scene now |
| `06_<tune>_full_band` | each other tune, the full band playing along |

The 01-03 and 06 files are levelled to -18 LUFS to hear; the 04 and 05 files are the game's mix (the music at its
level and the MUSIC slider's default, BandSound's levels) all raised by the same 3 dB, so BEFORE and AFTER compare.
To remake: `python3 tools/audio/make_band_music.py` (files and listening files; `--no-docs`, `--docs-only`,
`--only <tune,...>`); the balance numbers: `python3 tools/audio/band_balance.py`. Needs numpy, scipy, soundfile,
soxr, pyloudnorm, ffmpeg.

### Sources

The melodies are traditional (public domain): The British Grenadiers with the notes of a score the owner supplied (not
in the repo), Garry Owen, The Minstrel Boy and God Save the King from the traditional melodies given in the brief (ABC),
Scotland the Brave as before (the owner's score, not in the repo). The drum beatings are our own, in the style of the
Twin City Fife and Drum Corps' parts (the owner owns copies; not in the repo, not copied). The instruments are the same
samples as before (FreePats bagpipe CC0, MuldjordKit CC BY 4.0, VCSL recorder CC0): docs/audio_credits.md.

### For the owner (not built)

- His set also has American revolutionary and Union tunes (Yankee Doodle, The World Turned Upside Down, Jefferson and
  Liberty, Battle Hymn of the Republic, Rally Round the Flag, Road to Boston). The Crown is monarchist, so they do not
  fit the Crown's band; they could become the rebel **Free Assembly's** tunes in the campaign.
- Other Crown candidates for later: The Duke of York's March, The Governor King's March, The Rakes of Mallow, York
  Fusiliers. Grandfather's Clock could be a joke tune for the Clockwork.
- Questions: is 100 right for the Grenadiers (the score's "half note = 50"; the reference recording ~108)? God Save the
  King for a Crown victory, and where? Is the slow air's 30 s of standing still right? Are the pipes now too far back?

## Before band-repertoire

What follows describes Scotland the Brave as band-music-v2 made it: ONE tune on loop (the files `band/drums.ogg` ...
are gone; it is now `band/scotland_*.ogg`, with a roll-off, and no longer a loop), levelled by the loudest moment.


The owner (2026-11-14): the 4 s band loops were "a cacophony", so band-music (0.37.1) made six loops of Scotland the
Brave from real samples. His verdict on it (09:57): "almost good job, but try again now you have the proper
information": he sent a reference score of the tune (pipes, second pipes, snare, bass drum). The score is someone
else's arrangement and is NOT in the repo; only the traditional melody's notes and the drum pattern's shape were taken
from it. And (09:58, after hearing 07_over_crown_battle_music): "if we are hovering our camera near the band the game
music has to drop down so the main piece is the band's music". band-music-v2 did both.

## In short (0.37.4)

- **The tune**: Scotland the Brave **note for note as the reference score has it**: 16 bars of 4/4, A (1-4), A' (5-8),
  B (9-12), A' (13-16), no pick-up. The score plays it twice and ends on a flourish; a loop needs neither.
- **Tempo: 110** quarter notes a minute, as the score has it (exactly 109.91: see the loop below).
- **Key: E.** The score is written in D. The tune spans C#4 to F#5 written: a tenth and a half step, more than the
  chanter's nine notes. Measured, the owner's FreePats set has takes at almost every semitone from about E4 to G5
  (the file names are not all right: some "A4" takes are a semitone off, they were measured by pitch). In E every note
  of the tune lands within 1.7 semitones of a recorded take (most within 0.7); in G (0.37.1's key) the top notes would
  need +4 semitones, in F +2.3. The only thing moved further is the drones: the recorded G drones down 3 semitones to E
  (a steady buzzing tone takes that well).
- **Each loop is the tune once**: 16 bars = 34.94 s = **1,540,800 samples** at 44.1 kHz = exactly 2,880 cycles of the
  low drone (E2, 535 samples a cycle) and 5,760 of the tenor drone, so the drones run on through the loop point. That
  is why the tempo is 109.91, not 110.00 (110.00 would be 1,539,491 samples, not a whole number of drone cycles).
- **One place lists it all**: `BandSound.PARTS`, `BandSound.BARS` (16), `BandSound.PHRASE` (1,540,800 / 44,100 s) and
  `BandSound.BPM` (worked out from them) in scripts/band_sound.gd; `Defs.MARCHING_BAND["phrase"]` (34.94).
- **The game music gives way to the band** (below): -12 dB under a band in the middle of the screen, -16 dB under a
  solo, fading in and out over about 1.2-1.6 s.

## What changed from 0.37.1, note by note

0.37.1 played the tune from a Highland pipe setting found as text (an ABC file). Against the reference score (written
in D; 0.37.1's notes given in the same written pitches, pipe low A = D4):

| Bar | 0.37.1 played | The score (0.37.4 plays) | What was wrong |
|---|---|---|---|
| (pick-up) | A4 eighth before bar 1 | none | the score starts on the downbeat |
| 1, 5, 13 | D q, D e., E s, F# e, D e, F# e, A e | the same | right |
| 2, 6, 14 | D5 q, D5 q, D5 e, A4 e, F#4 e, D4 e | D5 q, **D5 e., C#5 s**, D5 e, A4 e, **F#4 q** | the dotted D5-C#5 figure was a plain D5 quarter; the bar ended F#4 D4 eighths instead of an F#4 quarter |
| 3, 7, 15 | G q, B e., G s, F# e, A e, F# e, D e | the same | right |
| 4 | E4 q, A4 q, A4 e., B4 s, a turn A G F# E | E4 q, **A4 e., B4 s, A4 half** | an extra A4 quarter, and a running turn where the phrase holds A4 (open, on the dominant) |
| 8, 16 | E4 q, D4 e., **E4** s, D4 q, F#4 e, A4 e | E4 q, D4 e., **C#4** s, **D4 half** | E4 where the leading note C#4 (the pipes' low G) belongs; the home D4 cut short by a run back up |
| 9 | D5 q, D5 q, D5 e, A4 e, F#4 e, D4 e (Part A's bar 2 again) | **E5 q, E5 e., D#5 s, E5 e, C#5 e, A4 q** | the whole Part B was wrong: the score's B climbs ABOVE the pipes' high A (E5, F#5) with a chromatic D#5 |
| 10 | D5 q, D5 q, D5 e, A4 e, F#4 e, A4 e | **D5 q, F#5 e., E5 s**, D5 e, A4 e, **F#4 q** | the leap to F#5 was missing |
| 11 | D5 q, D5 e., C5 s, B4 q, D5 e., C5 s | **D5 q, D5 q, C#5 q**, D5 e., C#5 s | rhythm, and C natural (the pipes' flat high G) where the score has C# |
| 12 | B4 e, D5 e, C5 e, B4 e, A4 e, G4 e, a turn | B4 e, D5 e, **C#5 q, A4 q** (staccato), F#4 e, E4 e | the staccato quarters and the line down into bar 13 |
| all | 98 a minute, in G | **110**, in E | the score's tempo |

The fife plays the same melody an octave up, so all of this applies to it too.

## The six loops (0.37.4)

| File | What it plays |
|---|---|
| `pipes.ogg` (always-on) | the drones (E2, E3) and the melody **plain**: one gracenote (high G, or the note above for the top notes) on the long and repeated notes only; the chanter a little back |
| `pipes_lead.ogg` (solo) | the drones and the melody with the **pipe gracenotes**: doublings on the long notes on the beat (high G, the note, then a D or E gracenote), grips (low G, D, low G) between repeated low notes (bar 1's D D, bar 11's D5 D5 take a high G), the E gracenote stepping down to low A / B; **a second pipe in unison** (another take, 8 ms behind, plainer) that **rests in Part B** (bars 9-12) as the score's second pipes do the first time through; the score's **lower voice** quietly under it as half notes (bars 1-3: D/F#, F#/D, D/D; bar 4: C#/E; bar 8: C#/D; bars 9-12: A/E, F#/D, F#/A, E/D); the chanter forward |
| `fife.ogg` (always-on) | the melody an octave over the pipes, plain and a little detached; bar 12's two quarters staccato |
| `fife_lead.ogg` (solo) | the same with ornaments: a roll (a turn) into the long notes, a cut where the pipes have a gracenote |
| `drums.ogg` (always-on) | the score's snare pattern (below), plainly; the bass drum on 1 and 3, in Part B a grace into an accented 1 |
| `drums_lead.ogg` (solo) | the same pattern filled out: ghost notes between the eighths, 5- and 7-stroke rolls into the accents, buzz rolls through the cadences' rests and Part B's rests, drags at bar ends; extra bass and tenor drum strokes, the cymbal at bar 1 and at Part B |

**The snare pattern** (one character a sixteenth, F = flam, t = tap, D = drag, . = rest), after the score's:
Part A bars `F.t.t.t.F.t.t.tt` / `F.t.t.t.F.t.t.D.` (constant eighths, a flam on 1 and 3, a sixteenth pair or a drag at
the bar's end); the last bar of each 4-bar phrase (4, 8, 16) `F.t.F.t.........` (flam eighth, flam eighth, rest); Part
B bars 9-10 `F...t...F.t.....` (quarter, quarter, eighth eighth, rest, flams on 1 and the first eighth of beat 3);
bars 11-12 straight eighths `A.t.t.t.A.t.t.t.`.

The always-on loops are levelled 3 dB under the solos in the file itself, the solos at the game sounds' loudness, as in
0.37.1. Every loop works alone and with any other.

## The game music gives way to the band

In scripts/band_sound.gd (the duck is an Amplify effect named band_duck on the Music bus, as since band-v2):

| | 0.37.1 | 0.37.4 |
|---|---|---|
| a band (or lone musicians) heard, in the middle of the screen | -2.5 dB | **-12 dB** (`DUCK_DB`) |
| ... its solo heard | -6 dB | **-16 dB** (`DUCK_SOLO_DB`) |
| further from the middle | scaled by level/20 | `duck_for`: full within NEAR (160 screen px), fading to none at level -24 dB (640 screen px from the middle; CUT is 760) |
| zoomed in | - | up to **-2 dB more** (`ZOOM_IN_DB`, zoom 1 -> 2); zoomed out the band's level is lower, so the duck is less |
| how fast | 30 dB a second (a jump) | **10 dB a second** (`DUCK_RATE`): -12 dB in 1.2 s, back up from a solo in 1.6 s |

The players keep the balance: the duck never touches the MUSIC and SOUND volume sliders (the Music and SFX buses), so
anyone who wants more or less battle music under the band moves the MUSIC slider. With the default sliders (MUSIC 0.5 =
-6 dB, SOUND 1.0) a band playing along now sits about 5 dB OVER the ducked battle music (it was about 10 dB under it in
0.37.1), and a solo about 20 dB over it.

## Checked

- `tools/test_band_music.gd`: 16 bars at 110 (109.91), all six files exactly one phrase (34.9388 s); with the movie
  writer (the engine mixes sound): every file plays on through its loop point with no click (the check now skips the
  first 20 ms of the capture: starting playback mid-wave is a step of its own, which 0.37.1's check counted by luck),
  two parts on the shared clock stay 2.5 ms apart at worst and within 9 ms of the clock. The old "never quiet near the
  loop point" check was dropped: the score's snare rests in each phrase's last bar, a rest, not a drop-out.
- `tools/test_marching_band.gd` (91 checks, all pass; new ones): a band in the middle of the screen sets the music's duck to -12 dB; it
  gets there smoothly within 1.6 s; the Music bus's band_duck effect is under -10 dB; a solo takes it to -16 dB; the
  band off to the side ducks it less; the camera leaving brings it back up smoothly (still under -8 dB right after, 0
  within 2 s). `test_i18n`, `test_files`: pass.
- In the script (measured on the files, autocorrelation per note): fife solo 79 of 80 notes and fife always-on 80 of 80
  within 45 cents of the score's note (the one miss is 49 cents, the tracker's resolution at 1.3 kHz); the pipes' solo
  80 of 80 (octave-folded: the drones are under it).

## The listening files (docs/band_sound/, 45 s each, mp3)

The band levels are BandSound's own (always-on -15 dB, a solo -1 dB with the others at -19 dB); the 07 files are the
game's mix NOW: the music at its level (-8 dB) and the MUSIC slider's default (-6 dB), ducked as above, the band's parts
fading in and out at BandSound's speed. `docs/band_sound/LIST.txt` has one line each.

| File | What you hear |
|---|---|
| `01_*_solo_alone`, `02_*_always_on_alone` | each solo loop and each always-on loop by itself |
| `03_full_band_always_on`, `04_full_band_*_solo` | all three playing along; all three with one soloing |
| `05_drummer_and_piper`, `05_drummer_and_fifer` | the smaller bands |
| `06_two_bands_one_clock` | two bands on the one clock (left a pipe solo, right playing along): in step |
| `07_over_crown_battle_music`, `07_over_clockwork_battle_music`, `07_over_brood_battle_music` | the band centred on the screen the whole file over each faction's battle music, the music ducked 12 dB; the pipes' solo from halfway (16 dB) |
| `07b_camera_comes_and_goes` | the Crown's battle music; the camera reaches a band playing along at 15 s and leaves at 30 s: the duck in and out |
| `08_OLD_*` | before 0.37.1: the old 4 s loops |
| `09_PREVIOUS_*` | 0.37.1's listening files (in G at 98, the old tune text, the music ducked only 2.5 / 6 dB), kept to compare |

To remake them: `python3 tools/audio/make_band_music.py` (the loops and the listening files) or `--docs-only` (the
09_PREVIOUS_ files are kept).

## How each part is made

All in Python (numpy, scipy, soundfile, soxr; ffmpeg writes the files). The loops are rendered "folded": anything that
rings past the end comes back in at the start, so every file loops seamlessly, rooms and all. Every note and stroke is
a few ms off the grid and a little uneven in force, seeded, so the script makes the same music each run.

**Pipes** (FreePats bagpipe, Gilles Sadowski, CC0): every chanter take's pitch is measured; a note uses the takes
nearest its pitch, retuned to **just intonation over the drones** (E, F# 9/8, G# 5/4, A 4/3, B 3/2, C# 5/3, the
leading notes D# 15/8 and the score's D#5 as the leading note into E5 (135/64 over the octave), E 2, F# 9/4, G# 5/2,
low D# 15/16). The chanter never stops: each note runs until the next, joined by a 6 ms crossfade, from the steady
middle of a take. Gracenotes (28-32 ms) come just before the beat, taking their time from the note before. The drones:
one seamless loop each (E3: 576 cycles in 3.49 s, E2: 144 cycles in 1.75 s), cut where the recording matches itself
best. A little room around the whole pipe.

**Fife** (VCSL Baroque Soprano Recorder, Versilian Studios, CC0), made fife-like as in 0.37.1 (saturation, a brighter
top, a puff of breath at each tongued note): the melody an octave over the pipes (E5 to G#6) in the same intonation.

**Drums** (MuldjordKit, Lars Muldjord, CC BY 4.0): the kit reworked as in 0.37.1 (the snare tuned up 2.5 semitones,
tightened, wire snap; the kick down 5 semitones with a felt beater and a big room; the floor tom as the tenor; the
crash). Velocity layers by the stroke's force, never the same file twice in a row; flams, drags, 5- and 7-stroke rolls,
buzz rolls.

## Sources and licences

| What | Source | Licence | Credit |
|---|---|---|---|
| Bagpipe chanter and drones | FreePats Bagpipe, Gilles Sadowski (art/audio_src/band/freepats_bagpipe/) | CC0 1.0 | not required (credited) |
| Snare, rim, bass drum, tenor, cymbal | MuldjordKit, Lars Muldjord, FreePats version (art/audio_src/band/muldjord_drums/) | CC BY 4.0 | **required**: "MuldjordKit drum samples by Lars Muldjord, CC BY 4.0" |
| Fife | VCSL Baroque Soprano Recorder, Versilian Studios (art/audio_src/band/vcsl/) | CC0 1.0 | not required (credited) |
| The tune | Scotland the Brave, traditional; the notes as in a reference score the owner supplied (an arrangement by someone else, not in the repo: only the traditional melody and the shape of the drum pattern were taken) | public domain melody | none |

All in docs/audio_credits.md.

## Claude's choices (say if wrong)

1. **E, not G**: the key where the recorded chanter fits the score's range best (above); the drones moved down 3
   semitones for it.
2. **109.91 a minute** instead of exactly 110, so the loop is a whole number of drone cycles (no seam in the drones).
3. **Bar 1's rhythm**: the brief's transcription of bar 1 ("D q, D q, E s, F# e., D e, F# e, A e") adds up to nine
   eighths; the score's bars 3, 5 and 13 and the familiar opening have D q, D e., E s, F# e, D e, F# e, A e (eight),
   which is what plays.
4. **The tune once** (16 bars, 34.9 s), not twice with the flourish: the loop repeats it anyway.
5. **Gracenotes for the notes over high A** (E5, F#5: the score's Part B is beyond a real chanter): E5 takes an F#5
   gracenote, F#5 a strike from D5; the D#5 sixteenth none.
6. **The second pipes and the lower voice only in the solo**; the always-on pipes are one plain chanter, so a band
   playing along stays quiet and clear.
7. **The duck numbers**: -12 dB (a band) and -16 dB (a solo), 10 dB a second, none past 640 screen px from the middle (CUT is 760);
   no new slider (the MUSIC slider balances it).

## Questions for the owner

1. Is the duck right: should the battle music drop more (or less) under a band playing along (-12 dB now)?
2. Is E (a little lower than a Highland pipe's B-flat) a good key for the band, or would you rather hear it nearer
   B-flat (the chanter's top notes would then be moved further)?
3. Do the second pipes and the harmony line make the Piper's solo better, or muddier?
4. 0.37.1's open questions still stand: the snare and bass drum sound, the fife (a recorder made brighter), one tune or
   more, the always-on playing.
