"""(job band-own, the owner 2026-11-14 21:57-22:12; docs/band_music.md "The band's own pieces") The production chain the study asked for: an ENSEMBLE (several players a part, each a little off in time and pitch),
STEREO placement, EQ for body and presence, a stereo outdoor room, gentle bus glue, a faint room tone."""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
from scipy import signal
import make_band_music as M
SR = M.SR


def pan(x, p):
    """mono -> stereo, p in -1..1, equal power."""
    a = (p + 1) * np.pi / 4
    return np.stack([x * np.cos(a), x * np.sin(a)], 1)


def fit(x, n):
    return x[:n] if len(x) >= n else np.concatenate([x, np.zeros(n - len(x))])


def ensemble(render, n_total, players, seed):
    """players: [(pan, delay ms, detune cents, gain)]; render() makes one take (its own randomness each call)."""
    out = np.zeros((n_total, 2))
    for k, (p, ms, cents, g) in enumerate(players):
        M.rng = np.random.default_rng(seed + 97 * k)
        y = render()
        if cents:
            y = M.shift(y, 2 ** (cents / 1200))
        d = int(ms / 1000 * SR)
        y = np.concatenate([np.zeros(d), y]) if d > 0 else y
        out += pan(fit(y, n_total), p) * g
    return out


def stereo_room(x, seconds=1.8, tau=0.42, bright=6500, pre_ms=18, seedL=21, seedR=22):
    irL, irR = M.room(seconds, tau, bright, seedL), M.room(seconds, tau, bright, seedR)
    d = int(pre_ms / 1000 * SR)
    m = x.mean(1)
    wl = np.concatenate([np.zeros(d), signal.fftconvolve(m, irL)])[:len(x)]
    wr = np.concatenate([np.zeros(d), signal.fftconvolve(m, irR)])[:len(x)]
    return np.stack([wl, wr], 1)


def early(x, seed=31):
    """A few early reflections (a parade ground's buildings): short, wide."""
    r = np.random.default_rng(seed)
    out = np.zeros_like(x)
    for _ in range(8):
        d = int(r.uniform(0.008, 0.045) * SR)
        g = r.uniform(0.08, 0.18)
        ch = r.integers(0, 2)
        out[d:, ch] += x[:-d, 1 - ch] * g
    return out


def eq(x, steps):
    for kind, *a in steps:
        x = {"hp": M.hp, "lp": M.lp, "peq": M.peq}[kind](x, *a)
    return x


def eq_st(x, steps):
    return np.stack([eq(x[:, 0], steps), eq(x[:, 1], steps)], 1)


def glue(x, thr_db=-18.0, ratio=2.0, att=0.01, rel=0.25):
    """A gentle RMS bus compressor (both channels together)."""
    lvl = np.sqrt(np.mean(x ** 2, 1))
    a, r = np.exp(-1 / (att * SR)), np.exp(-1 / (rel * SR))
    env = signal.lfilter([1 - r], [1, -r], lvl ** 2) ** 0.5     # smooth
    db = 20 * np.log10(env + 1e-9)
    over = np.maximum(0, db - thr_db)
    gain = 10 ** (-(over - over / ratio) / 20)
    return x * gain[:, None]


def tape(x, drive=1.3):
    return np.tanh(x * drive) / np.tanh(drive)


def lufs_st(x):
    return M.METER.integrated_loudness(x)


def level_st(x, target):
    return x * 10 ** ((target - lufs_st(x)) / 20)


def finish(stems, path, target=-14.5, wet=0.2):
    """stems: [(stereo, LUFS)] -> one stereo master written to path (.mp3 a listening file, .ogg a game file:
    Vorbis q4, stereo, at `target` LUFS)."""
    n = max(len(s) for s, _ in stems)
    mix = np.zeros((n, 2))
    for s, l in stems:
        mix[:len(s)] += level_st(s, l)
    mix = mix + early(mix) + stereo_room(mix) * wet
    tone = np.random.default_rng(5).standard_normal((n, 2))
    tone = np.stack([M.lp(tone[:, 0], 900), M.lp(tone[:, 1], 900)], 1)
    mix += level_st(tone, -58)                       # the open air: a faint room tone
    mix = glue(mix)
    mix = level_st(mix, target - 1.0)
    mix = tape(mix * 1.0)
    mix = level_st(mix, target)
    pk = np.abs(mix).max()
    if pk > 0.95:
        mix *= 0.95 / pk
    if path.endswith(".ogg"):
        import subprocess
        subprocess.run(["ffmpeg", "-y", "-v", "quiet", "-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", "-",
                        "-c:a", "libvorbis", "-q:a", "4", path], input=mix.astype(np.float32).tobytes(), check=True)
    else:
        M.write_mp3(path, mix.reshape(-1), stereo=True, rate="192k")
    return mix

# the players: a pipe section of three, a fife section of three, two side drummers (pan, delay ms, cents, gain)
PIPERS = [(-0.45, 0, 0, 1.0), (-0.2, 14, 6, 0.8), (-0.65, 27, -5, 0.7)]
FIFERS = [(0.35, 0, 0, 1.0), (0.6, 11, -7, 0.8), (0.15, 22, 8, 0.7)]
FIFE_LEAD = [(0.1, 0, 0, 1.0), (0.4, 12, -6, 0.6), (-0.2, 21, 7, 0.55)]
SNARES = [(-0.12, 0, 0, 1.0), (0.18, 9, 0, 0.75)]
PIPE_EQ = [("hp", 140), ("peq", 1200, -2.5, 0.8), ("peq", 3400, 2.5, 0.9), ("peq", 300, 1.5, 0.7)]
FIFE_EQ = [("hp", 450), ("peq", 1600, -2.0, 1.0), ("peq", 4500, 2.0, 0.8)]
SNARE_EQ = [("hp", 90), ("peq", 220, 3.0, 0.9), ("peq", 5000, 2.0, 0.8)]
BASS_EQ = [("hp", 42), ("peq", 65, -4.0, 0.9), ("peq", 160, 3.0, 0.8), ("peq", 900, 2.0, 1.0)]
