"""The mix pass (job music-mix-pass, 2026-11-28): the mastering chain of every generated piece.

The study (docs/music_study_classical.md) found the generated music flat (loudness range ~6.9 LU, real music ~12)
and the battles heavy below 80 Hz. The old chains caused part of it: compose.master pushed every piece into a tanh
saturator (up to 6x gain), orchestra.master_epic had a slow 2.2:1 compressor over the loudest 20%. This chain
replaces both (compose.master and orchestra.master_epic call process() while ON is True) and changes no note:

  1. peak-normalise the raw mix; "epic" pieces keep their small air lift (+2 dB above 2.5 kHz, as before);
  2. a high-pass (2nd order Butterworth run forward and back) at HP Hz;
  3. (after step 4) a low-shelf at 100 Hz stepped down 0.5 dB at a time (to -6 dB at most) until the energy share below 80 Hz is
     at most SUB_CAP (the study's band share; nothing when it is already under), as master_elevenlabs.py does;
  4. THE FADER RIDE: a slow gain curve from the piece's own short-term loudness (3 s windows, 1 s apart, smoothed
     over RIDE_SMOOTH s): every window moves k times its distance from the median, so the quiet parts get quieter
     and the climaxes stand out; k is found by bisection so the loudness range lands on its target
     (under 8 LU -> TARGET_LOW, over 10 LU -> TARGET_HIGH, in between left alone); the ride is at most
     -RIDE_DOWN / +RIDE_UP dB. Stings (under STING_S long) are not ridden;
  5. trim the silent tail and fade as the old chain did (classic 0.6 s, epic 1.2 s), so the loops are unchanged;
  6. a gain to TARGET LUFS integrated (the old median), but never more than MAX_TOTAL dB above what the true-peak
     ceiling allows; when the peaks would stand more than MAX_LIMIT dB over the ceiling, a FAST stage (2.5 ms
     look-ahead) takes the sharp attacks (harpsichord, plucks, timpani) down to MAX_LIMIT over it first; then a
     look-ahead true-peak limiter (4x oversampled peaks, 40 ms hold, 20 ms smoothing) to CEILING. Both act only on
     peaks (a few per cent of the time at most): no compressor, the loudness range is the ride's.

LAST keeps the last call's input so the driver (tools/music/mix_pass.py) can master it again with a lower ceiling
when Vorbis pushes the true peak over -1 dBTP. INFO holds the numbers of the last call.
"""
import numpy as np
from scipy.ndimage import minimum_filter1d, uniform_filter1d
from scipy.signal import butter, lfilter, resample_poly, sosfiltfilt

from synth import SR  # (32 kHz: the generators' rate)
ON = True             # False = the old chains (compose.master's saturator, orchestra.master_epic's compressor)
TARGET = -12.8        # LUFS integrated: the old median of the generated pieces
CEILING = -1.3        # dBTP before Vorbis; the driver wants <= -1.0 after
MAX_LIMIT = 4.0       # dB the slow limiter (40 ms hold) may take off at most
MAX_TOTAL = 16.0      # dB of peak reduction at most (fast + slow) to reach TARGET; else the piece stays quieter
FAST_HOLD, FAST_SMOOTH = 0.0025, 0.0015   # the fast stage: 2.5 ms look-ahead hold, 1.5 ms smoothing
HP = 35.0             # Hz
SUB_CAP = 0.25        # energy share 20-80 Hz of 20 Hz-16 kHz
TARGET_LOW = 9.0      # LU, for pieces under LRA_MIN
TARGET_HIGH = 9.7     # LU, for pieces over LRA_MAX
LRA_MIN, LRA_MAX = 8.0, 10.0
ACCEPT = (8.3, 9.9)   # the whole chain's result, else the ride is aimed again (a margin inside 8-10)
RIDE_UP, RIDE_DOWN = 5.0, 10.0
RIDE_SMOOTH = 4       # seconds (moving average over the 1 s grid)
STING_S = 30.0

LAST = None
INFO = {}
ceiling_override = None


def db(v):
    return 20 * np.log10(np.maximum(v, 1e-12))


# ----------------------------------------------------------------------------- measuring

def k_weight(x):
    import pyloudnorm as pyln
    m = pyln.Meter(SR)
    y = x.copy()
    for f in m._filters.values():
        y = f.apply_filter(y)
    return y


def block_power(xk):
    """Mean square per 100 ms block, summed over the two channels (BS.1770, G = 1)."""
    b = SR // 10
    n = len(xk) // b
    return (xk[: n * b] ** 2).reshape(n, b, -1).mean(1).sum(1)


def integrated(bp):
    """BS.1770 gated integrated loudness from 100 ms block powers (400 ms blocks, 75% overlap)."""
    if len(bp) < 4:
        return -70.0
    p4 = np.convolve(bp, np.ones(4) / 4, "valid")
    l4 = -0.691 + 10 * np.log10(p4 + 1e-15)
    g = p4[l4 > -70]
    if not len(g):
        return -70.0
    rel = -0.691 + 10 * np.log10(g.mean()) - 10
    g2 = p4[(l4 > -70) & (l4 > rel)]
    return float(-0.691 + 10 * np.log10(g2.mean() + 1e-15))


def short_term(bp):
    """3 s windows, 1 s apart, as tools/music/study_audio.py measures them."""
    st = []
    for i in range(0, max(1, len(bp) - 30), 10):
        st.append(-0.691 + 10 * np.log10(bp[i:i + 30].mean() + 1e-15))
    return np.array(st)


def lra_of(bp):
    """The study's loudness range: 95th - 10th percentile of the short-term values above integrated - 20."""
    st = short_term(bp)
    gated = st[st > integrated(bp) - 20]
    return float(np.percentile(gated, 95) - np.percentile(gated, 10)) if len(gated) > 3 else 0.0


def sub_share(x):
    mono = x.mean(1)
    nfft = 8192
    P = np.zeros(nfft // 2 + 1)
    for i in range(0, len(mono) - nfft, nfft * 4):
        P += np.abs(np.fft.rfft(mono[i:i + nfft] * np.hanning(nfft))) ** 2
    fr = np.fft.rfftfreq(nfft, 1 / SR)
    return float(P[(fr >= 20) & (fr < 80)].sum() / (P[(fr >= 20) & (fr < 16000)].sum() + 1e-12))


def true_peak(x):
    return float(db(np.max(np.abs(resample_poly(x, 4, 1, axis=0)))))


# ----------------------------------------------------------------------------- the chain

def shelf(x, f0, gain_db, kind, q=0.707):
    A = 10 ** (gain_db / 40)
    w = 2 * np.pi * f0 / SR
    al = np.sin(w) / (2 * q)
    c = np.cos(w)
    s = 2 * np.sqrt(A) * al
    if kind == "low":
        b = [A * ((A + 1) - (A - 1) * c + s), 2 * A * ((A - 1) - (A + 1) * c), A * ((A + 1) - (A - 1) * c - s)]
        a = [(A + 1) + (A - 1) * c + s, -2 * ((A - 1) + (A + 1) * c), (A + 1) + (A - 1) * c - s]
    else:
        b = [A * ((A + 1) + (A - 1) * c + s), -2 * A * ((A - 1) + (A + 1) * c), A * ((A + 1) + (A - 1) * c - s)]
        a = [(A + 1) - (A - 1) * c + s, 2 * ((A - 1) - (A + 1) * c), (A + 1) - (A - 1) * c - s]
    return lfilter(np.array(b) / a[0], np.array(a) / a[0], x, axis=0)


def _ride_curve(bp, k):
    """The ride's gain in dB on the 1 s grid (window centres at 1.5 s, 2.5 s, ...)."""
    st = short_term(bp)
    I = integrated(bp)
    gated = st[st > I - 20]
    ref = float(np.median(gated)) if len(gated) else I
    s = np.maximum(st, I - 20)
    g = np.clip((k - 1.0) * (s - ref), -RIDE_DOWN, RIDE_UP)
    if RIDE_SMOOTH > 1 and len(g) > RIDE_SMOOTH:
        g = uniform_filter1d(g, RIDE_SMOOTH, mode="nearest")
    return g


def _gain_blocks(g, nblocks):
    centres = 1.5 + np.arange(len(g))           # seconds
    t = (np.arange(nblocks) + 0.5) / 10.0
    return np.interp(t, centres, g)


def ride(x, sting, goal="auto"):
    """Returns (x ridden, info). goal: "auto" (by the piece's own range: under LRA_MIN -> TARGET_LOW, over LRA_MAX ->
    TARGET_HIGH, else not ridden), None (not ridden) or a loudness range in LU."""
    xk = k_weight(x)
    bp = block_power(xk)
    before = lra_of(bp)
    info = {"lra_raw": round(before, 2)}
    if goal == "auto":
        goal = TARGET_LOW if before < LRA_MIN else TARGET_HIGH if before > LRA_MAX else None
    if sting or len(bp) < 100 or goal is None or abs(goal - before) < 0.05:
        info.update(ride_k=1.0, lra_target=None)
        return x, info

    def lra_k(k):
        gb = _gain_blocks(_ride_curve(bp, k), len(bp))
        return lra_of(bp * 10 ** (gb / 10))

    lo, hi = (1.0, 5.0) if goal > before else (0.2, 1.0)
    for _ in range(30):
        mid = (lo + hi) / 2
        if lra_k(mid) < goal:          # the range grows with k
            lo = mid
        else:
            hi = mid
    k = (lo + hi) / 2
    g = _ride_curve(bp, k)
    centres = 1.5 + np.arange(len(g))
    gs = np.interp(np.arange(len(x)) / SR, centres, g)
    info.update(ride_k=round(k, 3), lra_target=round(goal, 2), ride_min_db=round(float(g.min()), 1),
                ride_max_db=round(float(g.max()), 1))
    return x * (10 ** (gs / 20))[:, None], info


def limit(x, ceiling_db, hold_s=0.04, smooth_s=0.02):
    c = 10 ** (ceiling_db / 20)
    up = np.abs(resample_poly(x, 4, 1, axis=0)).max(1)
    pk = up[: len(x) * 4].reshape(-1, 4).max(1)
    if len(pk) < len(x):
        pk = np.pad(pk, (0, len(x) - len(pk)))
    need = np.minimum(1.0, c / np.maximum(pk, 1e-12))
    hold, smooth = max(1, int(hold_s * SR)), max(1, int(smooth_s * SR))
    g = minimum_filter1d(need, size=hold + smooth, mode="nearest")
    g = uniform_filter1d(g, size=smooth, mode="nearest")
    y = x * g[:, None]
    return np.clip(y, -c * 1.02, c * 1.02), float(-db(g.min()))


def _trim_fade(x, mode):
    mono = x.mean(1)
    loud_idx = np.where(np.abs(mono) > (0.0015 if mode == "epic" else 0.002))[0]
    cut = min(len(x), (loud_idx[-1] if len(loud_idx) else len(x)) + int(0.3 * SR))
    x = x[:cut].copy()
    f = int(0.01 * SR)
    x[:f] *= np.linspace(0, 1, f)[:, None]
    if mode == "epic":
        fo = int(1.2 * SR)
        x[-fo:] *= (np.linspace(1, 0, fo) ** 1.5)[:, None]
    else:
        fo = int(0.6 * SR)
        x[-fo:] *= np.linspace(1, 0, fo)[:, None]
    return x


def _ride_shelf_limit(x, sting, goal, ceil):
    info = {}
    x, rinfo = ride(x, sting, goal)    # (before the shelf: riding up bass-heavy climaxes raises the sub share)
    info.update(rinfo)
    info["sub_ridden"] = round(sub_share(x), 3)
    shelf_db = 0.0
    if info["sub_ridden"] > SUB_CAP:
        base = x
        while shelf_db > -6.0 and sub_share(x) > SUB_CAP:
            shelf_db -= 0.5
            x = shelf(base, 100, shelf_db, "low")
    info["low_shelf_db"] = shelf_db
    loud = integrated(block_power(k_weight(x)))
    tp = true_peak(x)
    gain = min(TARGET - loud, ceil - tp + MAX_TOTAL)
    for _ in range(5):
        z = x * 10 ** (gain / 20)
        fast = 0.0
        if tp + gain - ceil > MAX_LIMIT:
            # plucks and hits whose peaks stand far above the music (harpsichords, timpani): a fast stage takes
            # their attacks down to MAX_LIMIT over the ceiling first, so the slow limiter never ducks the music more
            z, fast = limit(z, ceil + MAX_LIMIT, FAST_HOLD, FAST_SMOOTH)
        y, lim = limit(z, ceil)
        got = integrated(block_power(k_weight(y)))
        # (the limiting takes a little loudness away: make it up, within MAX_TOTAL)
        more = min(TARGET - got, ceil - tp + MAX_TOTAL - gain)
        if more < 0.15:
            break
        gain += more
    info.update(gain_db=round(gain, 2), fast_db=round(fast, 2), limit_db=round(lim, 2), ceiling_dbtp=round(ceil, 2))
    return y, info


def process(l, r, mode="classic", ceiling=None):
    """The whole chain; l, r the raw mix (any level). Returns (L, R) ready to encode."""
    global LAST, INFO
    LAST = (np.array(l, float), np.array(r, float), mode)
    x = np.stack([LAST[0], LAST[1]], 1)
    info = {"mode": mode}
    if mode == "epic":
        from orchestra import _highpass
        x = np.stack([x[:, 0] + 0.25 * _highpass(x[:, 0], 2500), x[:, 1] + 0.25 * _highpass(x[:, 1], 2500)], 1)
    x = x / max(np.max(np.abs(x)), 1e-9)
    x = sosfiltfilt(butter(2, HP, btype="highpass", fs=SR, output="sos"), x, axis=0)
    x = _trim_fade(x, mode)            # (first: a silent tail would count in the loudness range)
    info["sub_raw"] = round(sub_share(x), 3)
    sting = len(x) < STING_S * SR
    ceil = ceiling if ceiling is not None else (ceiling_override if ceiling_override is not None else CEILING)
    goal = "auto"
    for attempt in range(4):
        y, step = _ride_shelf_limit(x, sting, goal, ceil)
        lra_y = lra_of(block_power(k_weight(y)))
        step["lra_out"] = round(lra_y, 2)
        # (the shelf and the limiter move the range a little: aim the ride again until the result is in 8-10 LU)
        if sting or ACCEPT[0] <= lra_y <= ACCEPT[1]:
            break
        base = step["lra_target"] if step["lra_target"] is not None else step["lra_raw"]
        goal = base + ((TARGET_LOW if lra_y < ACCEPT[0] else TARGET_HIGH) - lra_y)
    step["ride_tries"] = attempt + 1
    info.update(step)
    INFO = info
    return y[:, 0].copy(), y[:, 1].copy()
