#!/usr/bin/env python3
"""WIN-RATE STUDY 2026-11-15 (docs/winrate_2026_11_15.md): the queue of the 2026-11-12 study's base rounds for the Crown's
pairings and the Brood mirror, run by tools/study/qa_matches.py's run_one (the same tags, seeds and sides). A measuring tool.
    python3 tools/study/winrate_1115.py list
    python3 tools/study/winrate_1115.py run OUT --data DATA [--jobs 2] [--end 900] [--pairs crbr,crcw,brbr,brcw]
Order: round 0 then round 1, map by map, the pairings interleaved (crbr, crcw, brbr), then Clockwork v Brood (brcw) last,
so a run cut short still has every pairing on the same maps. Done games (DATA/<tag>/result.json) are skipped."""
import os, sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

FIRST = ["crbr", "crcw", "brbr"]
LATER = ["brcw"]


def queue(pairs):
    first = [p for p in FIRST if p in pairs]
    later = [p for p in LATER if p in pairs]
    q = []
    for group in (first, later):
        for r in (0, 1):
            for g in qm.base(r):
                if g[0].split("_")[-2] in group:
                    q.append(g)
    return q


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    pairs = arg("--pairs", "crbr,crcw,brbr,brcw").split(",")
    if len(sys.argv) < 2 or sys.argv[1] not in ("list", "run"):
        print(__doc__)
        sys.exit(1)
    gl = queue(pairs)
    if sys.argv[1] == "list":
        for g in gl:
            print(g[0], g[1], g[2], g[3])
        sys.exit(0)
    out = os.path.abspath(sys.argv[2])
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/winrate_2026_11_15/data")))
    end = int(arg("--end", "900"))
    print("%d games" % len(gl), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda g: qm.run_one(g, out, end, data), gl):
            print("done", t, flush=True)
