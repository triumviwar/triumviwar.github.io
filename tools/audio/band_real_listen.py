"""The owner's listening files for the REAL band recordings (job band-real): docs/band_sound/*.mp3 and LIST.txt.

Usage: python3 tools/audio/band_real_listen.py     (after tools/audio/master_band_real.py)

01-02: what a lone musician / a full band plays, levelled to -18 LUFS to hear. 03-04: the game's mix as BandSound makes
it (the band centred: BandSound.BAND_DB, SOLO_DB; the Crown's battle music at music.gd VOL with the MUSIC slider's
default and the duck, DUCK_DB / DUCK_SOLO_DB moving DUCK_RATE dB a second), at the game's own level (LISTEN_GAIN 0).
"""
import os
import shutil
import subprocess
import sys

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "music"))
from master_elevenlabs import SR, lufs  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
BAND = os.path.join(ROOT, "assets", "audio", "band")
OUT = os.path.join(ROOT, "docs", "band_sound")
BAND_DB, SOLO_DB, LONE_DB = -6.0, 6.0, -9.0        # scripts/band_sound.gd
DUCK, DUCK_SOLO, DUCK_RATE = -12.0, -16.0, 10.0
MUSIC_VOL, MUSIC_SLIDER = -8.0, 20 * np.log10(0.5)  # scripts/music.gd VOL and the slider's default (0.5)
GAP = 2.0
LISTEN_GAIN = 0.0         # (the game's own level: a solo's peaks reach -1 dBFS)
BATTLE = "crown_battle_13"                         # Musketeer Charge: the Crown's skirmish piece


def decode(path):
    raw = subprocess.run(["ffmpeg", "-v", "quiet", "-i", path, "-f", "f32le", "-ac", "1", "-ar", str(SR), "-"],
                         capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype=np.float32).astype(np.float64)


def tune(t):
    return decode(os.path.join(BAND, t + ".ogg"))


def db(v):
    return 10 ** (v / 20)


def sec(x, a, b=None):
    return x[int(a * SR):(int(b * SR) if b is not None else None)]


def gap():
    return np.zeros(int(GAP * SR))


def fade(x, s=1.5):
    n = int(s * SR)
    x = x.copy()
    x[-n:] *= np.linspace(1, 0, n)
    return x


def curve(n, pts, rate):
    """A level (dB) that moves toward each point's value from its time on at `rate` dB a second."""
    out = np.zeros(n)
    cur = pts[0][1]
    want = cur
    k = 0
    step = rate / SR
    for i in range(n):
        while k < len(pts) and i >= int(pts[k][0] * SR):
            want = pts[k][1]
            k += 1
        cur = min(want, cur + step) if want > cur else max(want, cur - step)
        out[i] = cur
    return out


LIST = []


def put(name, x, text, game=False):
    if game:
        y = x * db(LISTEN_GAIN)
    else:
        y = x * db(-18.0 - lufs(x[:, None].repeat(2, 1)))
    y = np.clip(y, -0.99, 0.99)
    path = os.path.join(OUT, name + ".mp3")
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "f64le", "-ar", str(SR), "-ac", "1", "-i", "-",
                    "-c:a", "libmp3lame", "-q:a", "4", path], input=y.astype(np.float64).tobytes(), check=True)
    LIST.append("%s.mp3  %s" % (name, text))
    print(name, round(len(y) / SR, 1), "s")


def main():
    if os.path.isdir(OUT):
        shutil.rmtree(OUT)
    os.makedirs(OUT)
    d = tune("drums_calls")
    put("01_lone_drummer", np.concatenate([sec(d, len(d) / SR - 14), gap(), fade(sec(tune("drums_generations"), 0, 34))]),
        "a lone Drummer: the end of his drum calls, the pause, the start of Generations (Old Guard drum feature)")
    f = tune("fife_lowlands")
    put("01_lone_fifer", np.concatenate([sec(f, len(f) / SR - 16), gap(), fade(sec(tune("fife_trenton"), 0, 30))]),
        "a lone Fifer: the end of Lowlands Away, the pause, the start of Trenton (Old Guard fife feature)")
    p = tune("pipes_scotland")
    put("01_lone_piper", fade(sec(p, 0, 37)),
        "a lone Piper: no recording has a solo pipe long enough, so he keeps the OLD generated part (Scotland the Brave)")
    g = tune("band_green")
    put("02_full_band_two_changes", np.concatenate([sec(g, len(g) / SR - 18), gap(), tune("band_paddy"), gap(),
                                                    fade(sec(tune("band_mist"), 0, 24))]),
        "a full band across two tune changes: the end of Wearing of the Green (pipe band), the pause, all of Paddy on "
        "the Handcar (fife and drum corps), the pause, the start of The Mist Covered Mountains (pipe band)")
    S = 45.0
    n = int(S * SR)
    mus = decode(os.path.join(ROOT, "assets", "music", BATTLE + ".ogg"))[int(20 * SR):int(20 * SR) + n]
    b = sec(tune("band_scotland"), 0, S)
    gm = db(MUSIC_VOL + MUSIC_SLIDER + DUCK)
    put("03_full_band_over_battle_music", fade(mus * gm + b * db(BAND_DB)),
        "a full band in the middle of the screen over the Crown's battle music (the music ducked 12 dB): Scotland the "
        "Brave, the game's mix", game=True)
    bl = db(curve(n, [(0, BAND_DB), (15, BAND_DB + SOLO_DB), (30, BAND_DB)], 60.0))
    ml = db(curve(n, [(0, DUCK), (15, DUCK_SOLO), (30, DUCK)], DUCK_RATE) + MUSIC_VOL + MUSIC_SLIDER)
    put("04_solo_over_battle_music", fade(mus * ml + b * bl),
        "the same, a SOLO from 15 s to 30 s: the band %d dB louder, the music down to -16 dB, the tune going on, then "
        "back" % SOLO_DB, game=True)
    with open(os.path.join(OUT, "LIST.txt"), "w") as fh:
        fh.write("\n".join(LIST) + "\n")


if __name__ == "__main__":
    main()
