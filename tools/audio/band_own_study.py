# The study behind band_own.py (2026-11-14): my pieces v the real recordings and ElevenLabs, measured (docs/band_music.md).
import os, sys, subprocess, json, numpy as np, librosa, pyloudnorm as pyln
R = os.path.join(os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")), "art", "audio_src", "band_real") + "/"
import os
ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
D = os.path.join(ROOT, "docs", "band_sound") + "/"
FILES = {
 "own: The Pipe Calls": D + "own_the_pipe_calls.mp3",
 "own: The Fife Calls": D + "own_the_fife_calls.mp3",
 "own: The Drums Lead": D + "own_the_drums_lead.mp3",
 "real: USAF pipes Scotland": R + "scotland_the_brave_usafr_pipe_band.mp3",
 "real: Old Guard Brandywine": R + "oldguard_10_brandywine_quickstep_from_the_minstrel_boy_show.mp3",
 "real: Old Guard drums Cornwallis": R + "oldguard_06_drum_feature_the_rage_of_cornwallis_from_the_george_washington_show.mp3",
}
def load(f):
    r = subprocess.run(["ffmpeg", "-v", "quiet", "-i", f, "-t", "60", "-f", "f32le", "-ac", "2", "-ar", "44100", "-"], capture_output=True)
    return np.frombuffer(r.stdout, np.float32).reshape(-1, 2)
out = {}
import sys as _s
only=_s.argv[1:]
for name, f in FILES.items():
    if only and not any(o in name for o in only):
        continue
    st = load(f); m = st.mean(1); sr = 44100
    L, Rr = st[:, 0], st[:, 1]
    side = (L - Rr) / 2
    width = float(np.sqrt(np.mean(side ** 2)) / (np.sqrt(np.mean(m ** 2)) + 1e-9))
    corr = float(np.corrcoef(L, Rr)[0, 1]) if np.std(L) > 0 and np.std(Rr) > 0 else 1.0
    meter = pyln.Meter(sr)
    lufs = meter.integrated_loudness(st.astype(np.float64))
    # loudness range-ish: short-term (3 s) loudness spread, 10th..95th pct
    w = 3 * sr; sl = []
    for a in range(0, len(m) - w, sr // 2):
        sl.append(meter.integrated_loudness(st[a:a + w].astype(np.float64)) if np.any(st[a:a + w]) else -70)
    sl = np.array([x for x in sl if x > -60])
    lra = float(np.percentile(sl, 95) - np.percentile(sl, 10)) if len(sl) else 0
    S_ = np.abs(librosa.stft(m, n_fft=4096, hop_length=1024)) ** 2
    fr = librosa.fft_frequencies(sr=sr, n_fft=4096)
    tot = S_.sum()
    bands = {}
    for lo, hi, k in [(20, 120, "sub+bass"), (120, 500, "low-mid"), (500, 2000, "mid"), (2000, 6000, "presence"), (6000, 16000, "air")]:
        bands[k] = round(float(S_[(fr >= lo) & (fr < hi)].sum() / tot * 100), 1)
    cent = float(np.mean(librosa.feature.spectral_centroid(S=np.sqrt(S_), sr=sr)))
    flat = float(np.mean(librosa.feature.spectral_flatness(S=np.sqrt(S_))))
    crest = float(20 * np.log10(np.max(np.abs(m)) / (np.sqrt(np.mean(m ** 2)) + 1e-9)))
    # reverb tail: energy decay after onsets -> median time for the envelope to fall 20 dB (rough room size)
    env = librosa.onset.onset_strength(y=m, sr=sr)
    rms = librosa.feature.rms(y=m, frame_length=2048, hop_length=512)[0]
    db = 20 * np.log10(rms + 1e-9)
    noise_floor = float(np.percentile(db, 5) - np.percentile(db, 95))   # dB between quiet frames and loud frames
    # timing: onset intervals' irregularity against the beat grid
    tempo, beats = librosa.beat.beat_track(y=m, sr=sr)
    bt = librosa.frames_to_time(beats, sr=sr)
    ibi = np.diff(bt)
    tempo_cv = float(np.std(ibi) / np.mean(ibi) * 100) if len(ibi) > 3 else 0
    # micro dynamics: variation of the onset-strength peaks (accent contrast)
    pk = librosa.util.peak_pick(env, pre_max=3, post_max=3, pre_avg=3, post_avg=5, delta=0.5, wait=5)
    acc = float(np.std(env[pk]) / np.mean(env[pk])) if len(pk) > 5 else 0
    # pitch stability of the top line (pyin on the 1-4 kHz melody band): vibrato / drift
    f0, vf, _ = librosa.pyin(librosa.effects.preemphasis(m[: sr * 30]), fmin=300, fmax=2400, sr=sr, frame_length=2048)
    f0 = f0[vf] if vf.any() else np.array([])
    cents = 1200 * np.log2(f0 / librosa.midi_to_hz(np.round(librosa.hz_to_midi(f0)))) if len(f0) else np.array([0])
    out[name] = dict(lufs=round(lufs, 1), LRA_approx=round(lra, 1), width_side_mid=round(width, 3), LR_corr=round(corr, 3),
                     bands_pct=bands, centroid_hz=round(cent), flatness=round(flat, 4), crest_db=round(crest, 1),
                     quiet_vs_loud_db=round(noise_floor, 1), tempo=round(float(np.atleast_1d(tempo)[0]), 1),
                     beat_cv_pct=round(tempo_cv, 2), accent_contrast=round(acc, 2),
                     pitch_dev_cents_sd=round(float(np.std(cents)), 1))
    print(name, json.dumps(out[name]))
json.dump(out, open("study_%s.json" % ("_".join(only) or "all"), "w"), indent=1)
