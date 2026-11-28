"""The mix pass driver (job music-mix-pass, 2026-11-28): render every generated piece again through mixpass.py.

Usage: python3 tools/music/mix_pass.py [--jobs N] [--out DIR] [name ...]     (no names = every piece of PIECES)
       python3 tools/music/mix_pass.py --one NAME [--out DIR]                (one piece, in this process)

PIECES = the generated pieces the study measured (docs/music_study/audio.json) that compose.py still makes: the
stems the owner's ElevenLabs pieces now fill (tools/music/master_elevenlabs.py PIECES: the three victories) are
left out, so they are never overwritten. Each piece is rendered in its own process (the generators share one
random state), encoded at the piece's own Vorbis quality, decoded and measured again; while the true peak after
Vorbis is over -1.0 dBTP the ceiling drops by the excess and the piece is mastered again (the raw mix is kept, so
the notes are not rendered twice). Every piece's numbers go to docs/music_mix_pass/info/<name>.json (DIR/mixpass_info/ with --out).
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, HERE)
TP_MAX = -1.0
MUSIC = os.path.join(ROOT, "assets", "music")


def pieces():
    import compose
    import master_elevenlabs
    measured = json.load(open(os.path.join(ROOT, "docs", "music_study", "audio.json")))
    eleven = {p[0] for p in master_elevenlabs.PIECES}
    return [n for n in sorted(measured) if n in compose.SONGS and n not in eleven]


def one(name, out):
    import numpy as np
    import compose
    import mixpass

    def load(path):
        raw = subprocess.run(["ffmpeg", "-v", "quiet", "-i", path, "-f", "f32le", "-ac", "2", "-ar", str(mixpass.SR),
                              "-"], capture_output=True, check=True).stdout
        return np.frombuffer(raw, dtype=np.float32).reshape(-1, 2).astype(np.float64)
    compose.OUT = out
    song = compose.SONGS[name]()
    L, R = song.render()
    info = dict(mixpass.INFO)
    raw = mixpass.LAST
    path = os.path.join(out, name + ".ogg")
    for _ in range(6):
        compose.write_ogg(name, L, R, song.q)
        z = load(path)
        tp = mixpass.true_peak(z)
        if tp <= TP_MAX:
            break
        L, R = mixpass.process(*raw, ceiling=mixpass.INFO["ceiling_dbtp"] - (tp - TP_MAX) - 0.1)
        info = dict(mixpass.INFO)
    bp = mixpass.block_power(mixpass.k_weight(z))
    info.update(name=name, title=song.title, q=song.q, tp_out=round(tp, 2), lufs_out=round(mixpass.integrated(bp), 2),
                lra_ogg=round(mixpass.lra_of(bp), 2), sub_out=round(mixpass.sub_share(z), 3),
                length_s=round(len(z) / mixpass.SR, 2))
    idir = os.path.join(ROOT, "docs", "music_mix_pass", "info") if out == MUSIC else os.path.join(out, "mixpass_info")
    os.makedirs(idir, exist_ok=True)
    json.dump(info, open(os.path.join(idir, name + ".json"), "w"), indent=1)
    print(json.dumps(info), flush=True)


def main():
    args = sys.argv[1:]
    out = MUSIC
    jobs = 2
    if "--out" in args:
        i = args.index("--out")
        out = os.path.abspath(args[i + 1])
        del args[i:i + 2]
    if "--jobs" in args:
        i = args.index("--jobs")
        jobs = int(args[i + 1])
        del args[i:i + 2]
    if args and args[0] == "--one":
        one(args[1], out)
        return
    names = args or pieces()
    running = []
    for nm in names:
        while len(running) >= jobs:
            running = [p for p in running if p.poll() is None]
            if len(running) >= jobs:
                running[0].wait()
        running.append(subprocess.Popen([sys.executable, __file__, "--one", nm, "--out", out]))
    for p in running:
        p.wait()


if __name__ == "__main__":
    main()
