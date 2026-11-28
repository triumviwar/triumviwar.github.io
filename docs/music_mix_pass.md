# The music mix pass, and God Save the King for the Crown's victory

Job music-mix-pass, 2026-11-28. The owner said yes to two things on 2026-11-28: the study's first proposal (a mix
pass, mixing only, no note rewritten) and God Save the King as the Crown's victory music. Branch `music-mix-pass`;
the patch note sits under 0.38.999 (no version bump on the branch).

## In short

- **Every generated piece was mastered again from its generator** (69 pieces and the defeat sting; the owner's
  ElevenLabs pieces were left alone, see choice 8). No note, instrument or tempo changed.
- **Loudness range: @@LRA_B@@ LU before, @@LRA_A@@ LU after** (median, the study's own measure). @@N_IN@@ of 69 pieces now sit
  between 8 and 10 LU; before, @@N_IN_B@@ did. The quiet passages are quieter and the climaxes stand out; the pieces
  that were already wider than 10 LU (The Brood Wakes, 15.7) were brought in to about 9.5.
- **Sub-bass: @@SUB_B@@ pieces had more than a quarter of their energy below 80 Hz, @@SUB_A@@ do now** (Hunger 45% -> @@HUNGER@@%,
  The Forlorn Hope 46% -> @@FORLORN@@%, Tattoo at Dusk 45% -> @@TATTOO@@%).
- **Loudness unchanged:** median @@LUFS_B@@ LUFS before, @@LUFS_A@@ after; every piece between @@LUFS_MIN@@ and @@LUFS_MAX@@
  (before -15.0 to -10.5: the Crown's drum-bed marches were 2 LU quieter than the rest and now match). True peak at
  most @@TP_MAX@@ dBTP after Vorbis.
- **No compressor.** The old chains squashed the pieces (compose.master pushed every piece into a tanh saturator at up
  to 6x gain; orchestra.master_epic ran a 2.2:1 compressor over the loudest fifth). The new chain only rides the
  faders slowly and catches peaks. The peaks stand at least as far above the music as before: crest factor
  @@CREST_B@@ dB before, @@CREST_A@@ dB after (median).
- **God Save the King**: when the Crown wins a match the full band plays the anthem (42 s: a 5 s drum roll-off, then
  the anthem once with two pipes, three fifes and the side drums) **instead of** the victory sting.

## Task 1: the mix pass

### What the chain does

`tools/music/mixpass.py` is now the mastering of every generated piece: `compose.master` (the classic pieces) and
`orchestra.master_epic` (the orchestral ones) call `mixpass.process` while `mixpass.ON` is true, and the Clockwork's
newer pieces (clock_more.py) skip their old loudness loop. The old chains are still there (`python3
tools/music/compose.py --old-master NAME` makes a piece the old way). Per piece, on the raw mix the generator renders:

1. peak-normalise; the orchestral pieces keep their small air lift (+2 dB above 2.5 kHz), as before;
2. a high-pass at 35 Hz (2nd order Butterworth run forward and back);
3. trim the silent tail and fade the end as the old chains did (0.6 s / 1.2 s), so the loops are unchanged;
4. **the fader ride**: the piece's own short-term loudness (3 s windows, 1 s apart, BS.1770 K-weighted, the study's
   windows) gives a slow gain curve, smoothed over 4 s: every window moves k times its distance from the piece's
   median, so a soft passage gets softer and a loud one louder, by at most -10 / +5 dB. k is found by bisection so the
   range lands on its target: 9 LU for a piece under 8 LU, 9.5 LU for one over 10 LU; a piece already in 8-10 LU is
   not ridden. The ride follows the piece: its climaxes stay where the composer put them, they only stand out more;
5. **the sub-bass cap**: a low-shelf at 100 Hz stepped down 0.5 dB at a time (at most -6 dB) until at most 25% of the
   energy is below 80 Hz, the same rule as master_elevenlabs.py (it comes after the ride: riding up a bass-heavy
   climax raises the share);
6. **loudness**: a gain to -12.8 LUFS integrated (the study's median). Peaks: a fast stage (2.5 ms look-ahead) takes
   sharp attacks that would stand more than 4 dB over the ceiling down to 4 dB over it (harpsichord plucks,
   timpani, snare hits), then a true-peak limiter (4x oversampled, 40 ms hold, 20 ms smoothing) takes them to -1.3
   dBTP; the slow limiter never takes off more than 4 dB, and in all at most 16 dB of a peak (else the piece stays a
   little quieter);
7. the whole chain is measured again: when the loudness range or the sub share came out of bounds (the shelf and
   the limiter move them a little) the ride or the shelf is aimed again (at most six tries);
8. `tools/music/mix_pass.py` (the driver) encodes at the piece's own Vorbis quality, decodes, and while the true peak
   is over -1.0 dBTP lowers the ceiling by the excess and masters the same raw mix again.

### The numbers

Medians by side (the study's tools/music/study_audio.py on the files before the pass and after it; all 69 pieces
in `docs/music_mix_pass/table.md`):

@@MEDIANS@@

The study's own numbers (2026-11-14, docs/music_study/audio.json) were measured on the same files as "before" here
(no generated piece changed between the study and this pass): the study's median loudness range was 6.9 LU.

What moved most:

@@MOVED@@

### What did not change

- The notes. The generators wrote the same events; the pieces were rendered again because the old masters had
  already squashed the dynamics, which no later processing gives back. Some instruments draw their noise from an
  unseeded random source (breath, rattles), so a fresh render differs in that noise only (checked: The Orchard
  Minuet came out bit for bit the same as the old file before mastering; Ten Thousand Mouths with the same notes and
  a 0.93 correlation of its loudness curve).
- The lengths and the loops (the same trim and fades).
- The web build: the pieces are the same 70 .ogg files under the same names, a little smaller or larger; the build
  copies assets/music/*.ogg and hashes each file, so a returning player downloads each changed piece once.
  The new anthem (win_crown_anthem.ogg, 44.1 kHz, Vorbis q4, 0.4 MB) is fetched ahead with the other end-of-match
  stings (Music.match_started -> _sting_name). Music total 123 MB, as before.
- The owner's ElevenLabs pieces (choice 8) and the band's files.

## Task 2: God Save the King

`tools/audio/band_godsave.py` renders the anthem from make_band_music.py's "godsave" tune (3/4, crotchet 72, in G,
14 bars) and its solo drum beating (flams on beat 1, rolls into the phrase ends, cymbals), with the solo pipes (two in
unison, every gracenote), the fife an octave above, and the same production as the band's own pieces
(band_produce.py: three pipers, three fifers and two side drummers, each a little off in time and pitch, stereo, EQ,
an outdoor room, bus glue). Then it is mastered with master_elevenlabs.py's chain (trim, high-pass 35 Hz, sub cap
25%, -12.8 LUFS, -1 dBTP after Vorbis, no compressor): -12.9 LUFS, true peak -1.2 dBTP, 42.1 s
(`assets/music/win_crown_anthem.ogg`). make_band_music.py itself is retired (its main() would rewrite the band's
files): only its functions are called.

`scripts/music.gd`: `_sting_name("crown", true)` returns `CROWN_ANTHEM` ("win_crown_anthem") while `CROWN_ANTHEM_ON`
is true and the file is there; the Clockwork, the Brood and every defeat are unchanged. `tools/test_music_anthem.gd`
checks it.

**Instead of the sting, not after it** (choice 1): the anthem starts with the band's 5 s drum roll-off, which lies
under the herald's "Victory! God save the King!"; then the pipes strike in. After "Crown of Triumph" (28.6 s) the
anthem would start half a minute into the result screen, which most players have left by then. Crown of Triumph stays
in the files (set `CROWN_ANTHEM_ON := false` to hear it again).

## How to listen

- In the game: any match; the music is the new mix. Win a skirmish as the Crown for the anthem (an Easy computer).
- Side by side, the first minute of four pieces before and after: `docs/music_mix_pass/listen/` (The Orchard Minuet,
  the flattest; The Forlorn Hope and Hunger, the boomiest; The Brood Wakes, ridden down from 15.7 LU).
- The anthem alone: `docs/band_sound/godsave_victory.mp3`.
- The old version of any piece: `git show main:assets/music/<name>.ogg > old.ogg`.
- To make the pieces again: `python3 tools/music/mix_pass.py` (all, about 35 minutes on two cores) or with names;
  the numbers of each piece land in `docs/music_mix_pass/info/<name>.json`; `python3 tools/audio/band_godsave.py`
  for the anthem.

## Claude's choices

1. God Save the King **instead of** Crown of Triumph, not after it (above). One constant switches back.
2. The loudness-range target **9 LU** for the flat pieces (the middle of the owner's 8-10), **9.5 LU** for the wide
   ones (brought in only as far as needed: the Brood's and the Clockwork's openings, The Brood Wakes and Coiled Steel,
   were the study's best builders at 14-16 LU; at 9.5 they still build the most). Pieces already in 8-10 LU are not
   ridden at all.
3. A **fader ride** rather than rewriting dynamics into the scores: it is mixing only, it works on every piece the
   same way, and it keeps each piece's own shape (where it peaks is where its notes peak). It cannot add an arc a
   piece does not have: the climax positions are unchanged (the study's "climax at the last chord" needs the second
   proposal, a dynamic arc in the generator).
4. The ride is **slow** (3 s windows, 4 s smoothing): no pumping on beats, it acts on sections. It is capped at -10 /
   +5 dB.
5. The sub-bass cap is the **same rule as the ElevenLabs masters** (25% below 80 Hz, a 100 Hz low-shelf of at most
   -6 dB, a 35 Hz high-pass on every piece). Pieces under 25% keep their bass as it was.
6. **Peaks:** the old chains got to -12.8 LUFS by saturating and compressing. The new chain lets the slow limiter take
   at most 4 dB and gives the rest to a 2.5 ms stage that only touches sharp attacks. Measured, the peaks stand as far
   above the music as before or a little more (crest @@CREST_B@@ -> @@CREST_A@@ dB). The harpsichord pieces of the
   Crown's court (The Elector's Waltz, Waltz of the Flowers, Court Waltz by Candlelight) needed the most (10-12 dB on
   their plucks), a sign the harpsichord's attack is very hot in the synth.
7. **@@QUIET_N@@ pieces stay a little quieter** rather than being shaved more than 16 dB: @@QUIET_LIST@@.
8. **The ElevenLabs pieces were not touched.** They were mastered with no compressor already (docs/music_elevenlabs.md),
   their sub-bass is capped, and several are wide (10-18 LU). Some are as flat as the generated ones were (Campaign of
   the Crown 3.8 LU, Musketeer Charge 5.8, March of the Iron Standard 5.2, Clockmaker's Waltz 3.2), but they are the
   owner's pieces with their own prompts and remakes: the ride (`mixpass.ride`) can be added to master_elevenlabs.py
   with one line per piece if the owner wants them in 8-10 LU too.
9. **The defeat sting** (The Field Is Lost, 14 s) is not ridden: a sting is one swell.
10. The generators render at 32 kHz; the chain runs at that rate and the files stay 32 kHz as before.
11. The loudness is measured the BS.1770 way (pyloudnorm's K-weighting); the target is the study's median, -12.8
    LUFS; most pieces land at -12.8 to -13.0.

## Checked

- Boot: `godot --headless --path . --quit-after 120`: no SCRIPT ERROR, no Parse Error. (Godot 4.7 then crashes on the
  way out of this headless run, in the engine's shutdown; the same with main's scripts/music.gd: not from this job.)
- tools/test_music_anthem.gd (new), test_music_roles.gd, test_music_featured.gd, test_music_mix.gd,
  test_music_clock.gd: all pass.

## Files

- `tools/music/mixpass.py` (the chain), `tools/music/mix_pass.py` (the driver), `tools/music/mix_pass_report.py`
  (the table); `compose.py`, `orchestra.py`, `clock_more.py` call the chain.
- `tools/audio/band_godsave.py` (the anthem), `scripts/music.gd` (CROWN_ANTHEM), `tools/test_music_anthem.gd`.
- `docs/music_mix_pass/table.md` (every piece), `summary.json`, `info/` (the chain's numbers per piece), `listen/`.
