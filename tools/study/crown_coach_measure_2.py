#!/usr/bin/env python3
"""CROWN COACH MEASURE 2 (crown-coach-measure-2, docs/crown_coach_measure_2.md; after tools/study/crown_coach_measure.py
of branch crown-coach-measure): the Crown coach (scripts/ai_crown_coach.gd, with the army floor and farm first) measured
with the win-rate design (qa_matches.base(): 19 maps x round 0 and 1, Hard OPTIMAL v Hard OPTIMAL). Arms:
  A  as is (crbr, crcw)
  B  `norush:off` (the coach with the Horseman rush v a GREEDY Brood kept; crbr only)
  C  `coach:off` (crbr, crcw)
    python3 tools/study/crown_coach_measure_2.py list
    python3 tools/study/crown_coach_measure_2.py run OUT --data DATA [--jobs 2] [--end 720]
Order: round 0 then round 1, map by map, crbr then crcw, each game's arms next to each other, so a run cut short
still has paired data. DATA/<arm>/<tag>/result.json done = skipped (resumable)."""
import os, sys, types
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

ARMS = [("A", []), ("B", ["norush:off"]), ("C", ["coach:off"])]
ARM_PAIRS = {"A": ["crbr", "crcw"], "B": ["crbr"], "C": ["crbr", "crcw"]}
PAIRS = ["crbr", "crcw"]


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
    """qa_matches.run_one with its own extra args (its module global EXTRA, copied per call: thread safe)"""
    f = types.FunctionType(qm.run_one.__code__, dict(qm.run_one.__globals__, EXTRA=list(extra)))
    return f(g, out, end, data)


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
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/crown_coach_measure_2/data")))
    end = int(arg("--end", "720"))
    print("%d games" % len(gl), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda it: run(it, out, end, data), gl):
            print("done", t, flush=True)
