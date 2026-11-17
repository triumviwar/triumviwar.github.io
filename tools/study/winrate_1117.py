#!/usr/bin/env python3
"""WIN-RATE STUDY 2026-11-17 (docs/winrate_2026_11_17.md): all nine matchups (the six pairings of qa_matches.base(): Crown
v Brood, Crown v Clockwork, Clockwork v Brood and the three mirrors) on the same tags, seeds and sides as the 2026-11-12 and
2026-11-15 studies, Hard OPTIMAL v Hard OPTIMAL, run by tools/study/qa_matches.py's run_one. A measuring tool.
    python3 tools/study/winrate_1117.py list
    python3 tools/study/winrate_1117.py run OUT --data DATA [--jobs 1] [--end 720] [--crcr-end 900] [--pairs ...]
    python3 tools/study/winrate_1117.py long OUT --data DATA [--jobs 1]      (the Crown mirror to 20:00, round 0, 19 games)
Order: round 0 map by map with every pairing, then round 1, so a run cut short still has every pairing on the same maps.
Done games (DATA/<tag>/result.json) are skipped. The Crown mirror runs to --crcr-end (15:00, the mirror coach's proposal);
the others to --end (12:00)."""
import os, sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

ALL = ["crbr", "crcw", "brcw", "crcr", "brbr", "cwcw"]


def queue(pairs):
    q = []
    for r in (0, 1):
        for g in qm.base(r):
            if g[0].split("_")[-2] in pairs:
                q.append(g)
    return q


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    pairs = arg("--pairs", ",".join(ALL)).split(",")
    if len(sys.argv) < 2 or sys.argv[1] not in ("list", "run", "long"):
        print(__doc__)
        sys.exit(1)
    gl = queue(pairs)
    if sys.argv[1] == "long":
        gl = [g for g in qm.base(0) if g[0].split("_")[-2] == "crcr"]
    if sys.argv[1] == "list":
        for g in gl:
            print(g[0], g[1], g[2], g[3])
        sys.exit(0)
    out = os.path.abspath(sys.argv[2])
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/winrate_2026_11_17/data")))
    end = int(arg("--end", "720"))
    crcr_end = int(arg("--crcr-end", "900"))
    if sys.argv[1] == "long":
        end = crcr_end = 1200
    print("%d games" % len(gl), flush=True)

    def one(g):
        e = crcr_end if g[0].split("_")[-2] == "crcr" else end
        return qm.run_one(g, out, e, data)

    with ThreadPoolExecutor(int(arg("--jobs", "1"))) as ex:
        for t in ex.map(one, gl):
            print("done", t, flush=True)
