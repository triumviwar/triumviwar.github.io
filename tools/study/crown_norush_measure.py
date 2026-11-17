#!/usr/bin/env python3
"""CROWN NORUSH MEASURE (crown-norush-measure, docs/crown_norush_measure.md; after tools/study/crown_brood_measure.py):
the Crown's blind Horseman rush v the Brood, on 0.38.46, with the win-rate design (qa_matches.base(): 19 maps x round 0
and 1, Hard OPTIMAL Crown v Hard OPTIMAL Brood, to 12:00). Arms (existing switches only, no game code changed):
  A  as is
  N  `optlean:off greedybrood:balanced`: the blind rush off alone (no lean to the rush before the scout; a GREEDY read of
     the Brood picks Balanced): exactly what AICrownCoach.no_rush_v_brood() does, without broodecon:on's economy rules
  R  `optlean:off truegreed:on`: no lean; the rush on a GREEDY read only when the scout saw a truly greedy Brood
     (3+ grounds or 5+ Rootmaws), else the Economy race (the existing study switch's fallback)
    python3 tools/study/crown_norush_measure.py list
    python3 tools/study/crown_norush_measure.py run OUT --data DATA [--jobs 1] [--end 720]
Order: round 0 then round 1, map by map, crbr then crcw, each game's arms next to each other, so a run cut short
still has paired data. DATA/<arm>/<tag>/result.json done = skipped (resumable)."""
import os, sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

ARMS = [("A", []), ("N", ["optlean:off", "greedybrood:balanced"]), ("R", ["optlean:off", "truegreed:on"])]
ARM_PAIRS = {"A": ["crbr"], "N": ["crbr"], "R": ["crbr"]}
PAIRS = ["crbr"]


def queue():
    q = []
    for r in (0, 1):
        for g in qm.base(r):
            if g[0].split("_")[-2] in PAIRS:
                for arm, extra in ARMS:
                    if g[0].split("_")[-2] in ARM_PAIRS[arm]:
                        q.append((arm, extra, g))
    return q


def run(item, out, end, data):
    arm, extra, g = item
    return arm + " " + run_one(g, os.path.join(out, arm), end, os.path.join(data, arm), extra)


def run_one(g, out, end, data, extra):
    """qa_matches.run_one with its own extra args (passed per call: thread safe)"""
    return qm.run_one(g, out, end, data, list(extra))


# (crown-brood-measure, kept) every game under timeout 2400 s instead of qa_matches' 3000
_Popen = qm.subprocess.Popen


def _popen(cmd, *a, **k):
    if cmd[:2] == ["timeout", "3000"]:
        cmd = ["timeout", "2400"] + cmd[2:]
    return _Popen(cmd, *a, **k)


qm.subprocess.Popen = _popen


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if len(sys.argv) < 2 or sys.argv[1] not in ("list", "run"):
        print(__doc__)
        sys.exit(1)
    gl = queue()
    if sys.argv[1] == "list":
        for a, e, g in gl:
            print(a, g[0], g[1], g[2], g[3])
        sys.exit(0)
    out = os.path.abspath(sys.argv[2])
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/crown_norush_measure/data")))
    end = int(arg("--end", "720"))
    print("%d games" % len(gl), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "1"))) as ex:
        for t in ex.map(lambda it: run(it, out, end, data), gl):
            print("done", t, flush=True)
