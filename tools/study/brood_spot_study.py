#!/usr/bin/env python3
"""BROOD SPOT STUDY (brood-spot-study, docs/brood_spot_study.md): the 38 Brood mirror games of the win-rate studies
(qa_matches.base(), tags *_brbr_r0/r1, the same maps and seeds), each played twice: as before (player 1 at spot A) and with
the measuring switch `spotswap` (player 1 at spot B, player 2 at spot A). A measuring tool.
    python3 tools/study/brood_spot_study.py run OUT --data DATA [--jobs 2] [--end 720] [--extra a,b] [--suffix _x] [--only swap|plain] [--root DIR] [--pair brbr]
A game is done when DATA/<tag>/result.json exists (the swapped game's tag ends in _swap)."""
import os, sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm


def games(pair="brbr"):
    return [g for r in (0, 1) for g in qm.base(r) if g[0].split("_")[-2] == pair]


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if len(sys.argv) < 3 or sys.argv[1] != "run":
        print(__doc__)
        sys.exit(1)
    out = os.path.abspath(sys.argv[2])
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/brood_spot_study/data")))
    end = int(arg("--end", "720"))
    extra = [x for x in arg("--extra", "").split(",") if x]
    suf = arg("--suffix", "")
    only = arg("--only", "")
    pair = arg("--pair", "brbr")
    qm.RUN_ROOT = os.path.abspath(arg("--root", qm.ROOT))     # (another checkout to run: the version before a fix)
    q = []
    for g in games(pair):
        tag, m, seed, slots = g
        if only != "swap":
            q.append(((tag + suf, m, seed, slots), extra))
        if only != "plain":
            q.append(((tag + suf + "_swap", m, seed, slots), extra + ["spotswap"]))
    print("%d games" % len(q), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda x: qm.run_one(x[0], out, end, data, x[1]), q):
            print("done", t, flush=True)
