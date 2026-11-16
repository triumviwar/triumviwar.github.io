#!/usr/bin/env python3
"""CROWN FARM FIRST, MEASURED (docs/crown_farmfirst_measure.md): the win-rate design of docs/winrate_2026_11_15.md
(qa_matches.base(): the 19 two-player maps, round 0 and round 1, Hard OPTIMAL v Hard OPTIMAL) for Crown v Brood and
Crown v Clockwork, every game played twice: arm "ff" as is (the second Farm before the Barracks, AICrownCoach.farm_first)
and arm "off" with the switch farmfirst:off (the old order). A measuring tool; it changes no rule.
    python3 tools/study/farmfirst_measure.py list
    python3 tools/study/farmfirst_measure.py run OUT --data DATA [--jobs 2] [--end 720]
Order: round 0 then round 1, map by map, crbr then crcw, each game's two arms back to back, so a run cut short still
has whole pairs. Done games (DATA/<arm>/<tag>/result.json) are skipped."""
import os, sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

PAIRS = ["crbr", "crcw"]
ARMS = {"ff": [], "off": ["farmfirst:off"]}


def queue():
    q = []
    for r in (0, 1):
        for g in qm.base(r):
            if g[0].split("_")[-2] in PAIRS:
                for arm in ARMS:
                    q.append((arm, g))
    return q


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if len(sys.argv) < 2 or sys.argv[1] not in ("list", "run"):
        print(__doc__)
        sys.exit(1)
    gl = queue()
    if sys.argv[1] == "list":
        for arm, g in gl:
            print(arm, g[0], g[1], g[2], g[3])
        sys.exit(0)
    out = os.path.abspath(sys.argv[2])
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/crown_farmfirst_measure/data")))
    end = int(arg("--end", "720"))
    print("%d games" % len(gl), flush=True)

    def one(x):
        arm, g = x
        return arm + " " + qm.run_one(g, os.path.join(out, arm), end, os.path.join(data, arm), ARMS[arm])

    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(one, gl):
            print("done", t, flush=True)
