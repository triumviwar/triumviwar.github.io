"""GOD SAVE THE KING, THE CROWN'S VICTORY MUSIC (job music-mix-pass, owner 2026-11-28 "yes"; docs/music_mix_pass.md).

The full band plays the anthem once: make_band_music.py's "godsave" tune (3/4, crotchet 72, in G; the traditional
melody) and its solo drum beating (flams on beat 1, rolls into the phrase ends, the cymbal), with the solo pipes (two
in unison, every gracenote) and the fife an octave above, through band_produce.py's production (a section of players
a part, stereo, body and presence EQ, an outdoor room, bus glue), as tools/audio/band_own.py makes the band's own
pieces. Then it is mastered like the other pieces (tools/music/master_elevenlabs.py's chain: trimmed, high-passed at
35 Hz, the sub-bass capped at 25%, -12.8 LUFS with at most 4 dB of peak limiting, -1 dBTP after Vorbis, no compressor).

  python3 tools/audio/band_godsave.py            -> assets/music/win_crown_anthem.ogg
  python3 tools/audio/band_godsave.py --listen   -> docs/band_sound/godsave_victory.mp3 too

make_band_music.py itself is RETIRED (its main() would rewrite assets/audio/band/): only its functions are used here.
Needs numpy, scipy, soundfile, soxr, pyloudnorm, ffmpeg.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "music"))
import numpy as np  # noqa: E402
from scipy.signal import butter, sosfiltfilt  # noqa: E402
import make_band_music as M  # noqa: E402
import band_produce as P  # noqa: E402
import band_own as O  # noqa: E402
import master_elevenlabs as ME  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
STEM = "win_crown_anthem"
SR = M.SR
TAIL = 1.2            # seconds of the room after the last chord
MAX_LIMIT = 4.0


def render():
    """The full band, stereo, at -15 LUFS (band_produce.finish's chain, without its file)."""
    tu = M.prepare(M.all_tunes()["godsave"])
    tu.N += int(TAIL * SR)
    N = tu.N
    pipes = P.ensemble(lambda: P.eq(M.render_pipes(tu, True), P.PIPE_EQ), N, P.PIPERS, 700)
    fife = P.ensemble(lambda: P.eq(M.render_fife(tu, True), P.FIFE_EQ), N, P.FIFERS, 800)
    roll, beat, bass, tenor, cym = M.score_of(tu, True)
    six, t0 = tu.six, tu.roll_s
    bass_hits = [(t0 + p * six, v) for p, v in sorted(bass.items())]
    nroll = len(roll)
    bass_hits += [((i - nroll) * six + t0, 0.75) for i, c in enumerate(roll) if c == "A"]
    tenor_hits = [(t0 + p * six, v) for p, v in sorted(tenor.items())]
    sn, low = O.drums_stems(six, t0, N, roll, beat, bass_hits, tenor_hits, 1.0, seed=900)
    k = M.kit()
    cy = M.Buf(N)
    for p in cym + [len(beat) - 6 * 1]:          # (and one on the last chord: the end of the anthem)
        cy.add(k.hit("crash", 0.6) * 0.55, t0 + p * six + M.jit(2))
    low = low + P.pan(cy.y, 0.25) * 0.4
    # the band's own levels (as band_own.calls: the pipes a little back, the fife's tune on top, the drums under)
    tmp = os.path.join("/tmp", "godsave_mix.ogg")
    mix = P.finish([(pipes, -20.5), (fife, -19.0), (sn, -24.0), (low, -26.0)], tmp, -15.0, wet=0.24)
    os.remove(tmp)
    return mix, tu


def master(x):
    """master_elevenlabs.py's chain on the band's mix (44.1 kHz)."""
    info = {}
    x, info["lead_trim_s"], info["tail_trim_s"] = ME.trim(x)
    x = sosfiltfilt(butter(2, 35, btype="highpass", fs=SR, output="sos"), x, axis=0)
    shelf_db = 0.0
    base = x
    while shelf_db > -6.0 and ME.sub_share(x) > 0.25:
        shelf_db -= 0.5
        x = ME.shelf(base, 100, shelf_db, "low")
    info["low_shelf_db"] = shelf_db
    n = int(1.5 * SR)                    # the room dies away into the result screen
    x[-n:] *= (np.cos(np.linspace(0, np.pi, n)) * 0.5 + 0.5)[:, None]
    loud, tp = ME.lufs(x), ME.true_peak(x)
    ceiling = ME.CEILING
    path = os.path.join(ROOT, "assets", "music", STEM + ".ogg")
    for _ in range(5):
        gain = min(ME.TARGET - loud, ceiling - tp + MAX_LIMIT)
        y, lim = ME.limit(x * 10 ** (gain / 20), ceiling)
        ME.encode(y, path)
        z = ME.load(path)
        tp_out = ME.true_peak(z)
        if tp_out <= ME.TP_MAX:
            break
        ceiling -= tp_out - ME.TP_MAX + 0.1
    info.update(gain_db=round(gain, 2), limit_db=round(lim, 2), lufs_out=round(ME.lufs(z), 2), tp_out=round(tp_out, 2),
                length_s=round(len(z) / SR, 2), sub_out=round(ME.sub_share(z), 3))
    return z, info


def main():
    mix, tu = render()
    z, info = master(mix)
    info.update(tune=tu.title, bpm=tu.bpm, bars=tu.n_bars, roll_off_s=round(tu.roll_s, 2))
    print(info)
    if "--listen" in sys.argv:
        os.makedirs(os.path.join(ROOT, "docs", "band_sound"), exist_ok=True)
        M.write_mp3(os.path.join(ROOT, "docs", "band_sound", "godsave_victory.mp3"), z.reshape(-1), stereo=True,
                    rate="160k")


if __name__ == "__main__":
    main()
