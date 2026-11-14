"""Cut and master the REAL band recordings for the Marching Band (job band-real, docs/band_music.md "Real recordings").

Usage: python3 tools/audio/master_band_real.py [stem ...]     (no stems = every cut)
       python3 tools/audio/master_band_real.py --json OUT.json (also write what scripts/band_sound.gd's TUNES needs)

Sources: art/audio_src/band_real/ (the owner's public-domain downloads, SOURCES.txt) and, for the LONE PIPER only,
art/audio_src/band/generated_piper/ (the old generated piper parts: no recording has a solo pipe passage long enough).
Output: assets/audio/band/<stem>.ogg (Vorbis -q:a 4, 44.1 kHz, mono: the stereo recordings folded down).

The chain (master_elevenlabs.py's, one line per cut in CUTS):
  1. cut [a, b] s of the source (b None = to the end); a cut made of several pieces is joined with GAP s of silence;
  2. trim the leading silence (below -50 dBFS, 30 ms kept) and the trailing silence (below -60 dBFS, 0.4 s kept);
  3. a 10 ms fade-in; a fade-out of `fade` s when the cut ends inside the music (natural endings keep their decay);
  4. a high-pass at 35 Hz (2nd order Butterworth both ways);
  5. a gain to TARGET LUFS but at most MAX_LIMIT dB of true-peak limiting (dynamic cuts stay a little quieter);
  6. encode, decode, measure the true peak; over -1 dBTP: lower the ceiling and again.
For the slow airs it also finds PHRASE ENDS (the quietest moment in each window of ~PHRASE s, past the first 8 s):
BandSound cuts an air short there when fighting starts.
"""
import json
import os
import subprocess
import sys

import numpy as np
from scipy.signal import butter, sosfiltfilt

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "music"))
from master_elevenlabs import SR, limit, lufs, true_peak  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SRC = os.path.join(ROOT, "art", "audio_src", "band_real")
GEN = os.path.join(ROOT, "art", "audio_src", "band", "generated_piper")
OUT = os.path.join(ROOT, "assets", "audio", "band")
TARGET = -20.0      # LUFS for every cut (BandSound sets the band / lone levels: BAND_DB, LONE_DB)
CEILING = -1.3
TP_MAX = -1.0
MAX_LIMIT = 6.0     # (the Old Guard's drums are peaky: a little more limiting keeps every cut at TARGET)
GAP = 1.2           # s of silence between the pieces of a joined cut (the drum calls)
PHRASE = 9.0

OG = "oldguard_%s.mp3"
# stem, set (band / drums / fife / pipes), kind (march / quick / air), title, [(source, a, b), ...], fade-out s
CUTS = [
    # A FULL BAND: pipe band tunes (USAF Reserve Pipe Band) and fife-and-drum corps tunes (the Old Guard)
    ("band_scotland", "band", "march", "Scotland the Brave (USAF Reserve Pipe Band)",
     [("scotland_the_brave_usafr_pipe_band.mp3", 0.0, None)], 0),
    ("band_brandywine", "band", "quick", "Brandywine Quickstep (Old Guard Fife and Drum Corps)",
     [(OG % "10_brandywine_quickstep_from_the_minstrel_boy_show", 0.0, None)], 0),
    ("band_minstrel", "band", "march", "Let Erin Remember, High Road to Gairloch, The Minstrel Boy (USAF Reserve Pipe Band)",
     [("let_erin_remember_high_road_to_gairloch_minstrel_boy_usafr_pipe_band.mp3", 0.0, None)], 0),
    ("band_farewell", "band", "march", "Soldiers' Farewell, Fanfare, Montezuma, March of War, Windsor Park (Old Guard)",
     [(OG % "07_soldiers_farewell_fanfaremontezumamarch_of_warwindsor_park", 0.0, None)], 0),
    ("band_dundee", "band", "march", "The Dream Valley of Glendaruel, The Old Rustic Bridge, Bonnie Dundee, Campbell's Farewell (USAFR)",
     [("dream_valley_old_rustic_bridge_bonnie_dundee_campbells_farewell_usafr_pipe_band.mp3", 0.0, None)], 0),
    ("band_yankee", "band", "march", "Reveille, Drum Calls, Slow and Quick Scotch, Yankee Doodle (Old Guard)",
     [(OG % "09_reveille_variationdrum_callslow_scotchquick_scotchyankee_doodlemont", 0.0, None)], 0),
    ("band_green", "band", "march", "God Save Ireland, The Boy from Killane, Wearing of the Green (USAF Reserve Pipe Band)",
     [("god_save_ireland_boy_from_killane_wearing_of_the_green_usafr_pipe_band.mp3", 0.0, None)], 0),
    ("band_paddy", "band", "quick", "Paddy on the Handcar (Old Guard Fife and Drum Corps)",
     [(OG % "12_paddy_on_the_handcar_from_the_minstrel_boy_show", 0.0, None)], 0),
    ("band_mist", "band", "air", "The Mist Covered Mountains (USAF Reserve Pipe Band)",
     [("mist_covered_mountains_usafr_pipe_band.mp3", 0.0, None)], 0),
    # A LONE DRUMMER: the Old Guard's drum features and drum-only passages
    ("drums_cornwallis", "drums", "march", "The Rage of Cornwallis (Old Guard drum feature)",
     [(OG % "06_drum_feature_the_rage_of_cornwallis_from_the_george_washington_show", 0.0, None)], 0),
    ("drums_generations", "drums", "march", "Generations (Old Guard drum feature)",
     [(OG % "16_drum_feature_generations_from_the_simple_gifts_show", 0.0, None)], 0),
    ("drums_calls", "drums", "march", "Drum calls (the drums alone in three Old Guard pieces)",
     [(OG % "09_reveille_variationdrum_callslow_scotchquick_scotchyankee_doodlemont", 0.4, 10.15),
      (OG % "07_soldiers_farewell_fanfaremontezumamarch_of_warwindsor_park", 19.95, 29.45),
      (OG % "15_simple_giftssimple_interludestorm_in_the_valley_from_the_simple_gifts_show", 72.4, 86.9)], 0.25),
    # A LONE FIFER: the Old Guard's fife features
    ("fife_lowlands", "fife", "air", "Lowlands Away (Old Guard fife feature)",
     [(OG % "04_fife_feature_lowlands_awaytrenton_from_the_george_washington_show", 0.0, 32.9)], 0.3),
    ("fife_trenton", "fife", "quick", "Trenton (Old Guard fife feature)",
     [(OG % "04_fife_feature_lowlands_awaytrenton_from_the_george_washington_show", 33.25, None)], 0),
    ("fife_hornpipe", "fife", "quick", "Fisher's Hornpipe, Guilderoy, Red Haired Boy (Old Guard fife feature)",
     [(OG % "11_fife_feature_fishers_hornpipe_variationguilderoyred_haired_boy", 0.0, None)], 0),
    # A LONE PIPER: the old generated piper part (no recording has a solo pipe passage: docs/band_music.md)
    ("pipes_scotland", "pipes", "march", "Scotland the Brave (generated piper)", [("@scotland_pipes.ogg", 0.0, None)], 0),
    ("pipes_grenadiers", "pipes", "march", "The British Grenadiers (generated piper)", [("@grenadiers_pipes.ogg", 0.0, None)], 0),
    ("pipes_garryowen", "pipes", "quick", "Garry Owen (generated piper)", [("@garryowen_pipes.ogg", 0.0, None)], 0),
    ("pipes_minstrel", "pipes", "air", "The Minstrel Boy (generated piper)", [("@minstrel_pipes.ogg", 0.0, None)], 0),
]


def load(path, a=0.0, b=None, ch=2):
    cmd = ["ffmpeg", "-v", "quiet", "-ss", str(a)]
    if b is not None:
        cmd += ["-t", str(b - a)]
    cmd += ["-i", path, "-f", "f32le", "-ac", str(ch), "-ar", str(SR), "-"]
    raw = subprocess.run(cmd, capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype=np.float32).reshape(-1, ch).astype(np.float64)


def trim(x):
    m = np.max(np.abs(x), 1)
    on = np.where(m > 10 ** (-50 / 20))[0]
    a = max(0, on[0] - int(0.03 * SR)) if len(on) else 0
    on2 = np.where(m > 10 ** (-60 / 20))[0]
    b = min(len(x), on2[-1] + int(0.4 * SR)) if len(on2) else len(x)
    return x[a:b], a / SR, b / SR


def fade_out(x, s):
    n = min(len(x), int(s * SR))
    if n > 0:
        x[-n:] *= (np.cos(np.linspace(0, np.pi, n)) * 0.5 + 0.5)[:, None]
    return x


def phrases(x):
    """Phrase ends for an air: the quietest 0.25 s in each PHRASE-s window after the first 8 s."""
    m = x.mean(1)
    w = int(0.25 * SR)
    e = np.sqrt(np.convolve(m ** 2, np.ones(w) / w, mode="same"))
    out, t = [], 8.0
    L = len(m) / SR
    while t + PHRASE < L - 6.0:
        a, b = int((t + 2.0) * SR), int((t + PHRASE) * SR)
        i = a + int(np.argmin(e[a:b:256]) * 256)
        out.append(round(i / SR, 2))
        t = i / SR
    return out


def encode(x, path):
    ch = x.shape[1]
    pcm = np.clip(x, -1, 1).astype(np.float32).tobytes()
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "f32le", "-ar", str(SR), "-ac", str(ch), "-i", "-",
                    "-c:a", "libvorbis", "-q:a", "4", path], input=pcm, check=True)


def master(stem, pieces, fade):
    parts, info = [], {"pieces": []}
    ch = 1             # mono: a band in the game is one point; half the size of stereo (the web art pack)
    for src, a, b in pieces:
        path = os.path.join(GEN, src[1:]) if src.startswith("@") else os.path.join(SRC, src)
        x = load(path, a, b, ch)
        x, ta, tb = trim(x)
        info["pieces"].append([src.lstrip("@"), round(a + ta, 2), round(a + tb, 2)])
        x[: int(0.01 * SR)] *= np.linspace(0, 1, int(0.01 * SR))[:, None]
        if b is not None and fade:
            x = fade_out(x, fade)
        if parts:
            parts.append(np.zeros((int(GAP * SR), ch)))
        parts.append(x)
    x = np.concatenate(parts)
    x = sosfiltfilt(butter(2, 35, btype="highpass", fs=SR, output="sos"), x, axis=0)
    loud, tp = lufs(x), true_peak(x)
    ceiling = CEILING
    path = os.path.join(OUT, stem + ".ogg")
    for _ in range(5):
        gain = min(TARGET - loud, ceiling - tp + MAX_LIMIT)
        y, lim = limit(x * 10 ** (gain / 20), ceiling)
        encode(y, path)
        z = load(path, ch=ch)
        tp_out = true_peak(z)
        if tp_out <= TP_MAX:
            break
        ceiling -= tp_out - TP_MAX + 0.1
    info.update(n=len(z), length_s=round(len(z) / SR, 3), gain_db=round(gain, 2), limit_db=round(lim, 2),
                lufs_in=round(loud, 2), lufs_out=round(lufs(z), 2), tp_out=round(tp_out, 2),
                kb=round(os.path.getsize(path) / 1024), channels=ch)
    return info, z


def main():
    args = sys.argv[1:]
    js = None
    if "--json" in args:
        i = args.index("--json")
        js = args[i + 1]
        del args[i:i + 2]
    out = {}
    for stem, st, kind, title, pieces, fade in CUTS:
        if args and stem not in args:
            continue
        info, z = master(stem, pieces, fade)
        info.update(set=st, kind=kind, title=title)
        if kind == "air":
            info["phrases"] = phrases(z)
        print(json.dumps(info))
        out[stem] = info
    if js:
        with open(js, "w") as f:
            json.dump(out, f, indent=1)


if __name__ == "__main__":
    main()
