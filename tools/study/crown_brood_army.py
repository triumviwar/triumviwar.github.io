#!/usr/bin/env python3
"""CROWN BROOD ARMY measure (crown-brood-army, docs/crown_brood_army.md; after tools/study/crown_coach_measure_2.py): the
Crown computer against the Brood with this job's changes (scripts/ai_crown_v_brood.gd parts 5-7) measured with the win-rate
design (qa_matches.base(): 19 maps x round 0 and 1, Hard OPTIMAL v Hard OPTIMAL, Crown v Brood only). Arms:
  F  as is (this job's changes on)
  O  `cba:off` (the Crown v the Brood as on main 0.38.38)
  E  `broodecon:on` (this job's changes and the coach's economy rules back v the Brood)
    python3 tools/study/crown_brood_army.py list [--arms F,O]
    python3 tools/study/crown_brood_army.py run OUT --data DATA [--jobs 2] [--end 720] [--arms F,O] [--root CHECKOUT]
Order: round 0 then round 1, map by map, each game's arms next to each other, so a run cut short still has paired data.
DATA/<arm>/<tag>/result.json done = skipped (resumable)."""
import os, sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

ARMS = [("F", []), ("O", ["cba:off"]), ("E", ["broodecon:on"])]
ARM_PAIRS = {"F": ["crbr"], "O": ["crbr"], "E": ["crbr"]}
PAIRS = ["crbr"]


def queue(arms=None):
    q = []
    for r in (0, 1):
        for g in qm.base(r):
            if g[0].split("_")[-2] in PAIRS:
                for arm, extra in ARMS:
                    if g[0].split("_")[-2] in ARM_PAIRS[arm] and (arms is None or arm in arms):
                        q.append((arm, extra, g))
    return q


def run(item, out, end, data):
    arm, extra, g = item
    return arm + " " + run_one(g, os.path.join(out, arm), end, os.path.join(data, arm), extra)


def run_one(g, out, end, data, extra):
    """qa_matches.run_one with its own extra args (passed per call: thread safe)"""
    return qm.run_one(g, out, end, data, list(extra))


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if len(sys.argv) < 2 or sys.argv[1] not in ("list", "run"):
        print(__doc__)
        sys.exit(1)
    al = arg("--arms", "")
    gl = queue(al.split(",") if al else None)
    if sys.argv[1] == "list":
        for a, e, g in gl:
            print(a, g[0], g[1], g[2], g[3])
        sys.exit(0)
    out = os.path.abspath(sys.argv[2])
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/crown_brood_army/data")))
    end = int(arg("--end", "720"))
    qm.RUN_ROOT = os.path.abspath(arg("--root", qm.ROOT))     # (a frozen checkout to run, so the code can change meanwhile)
    print("%d games" % len(gl), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda it: run(it, out, end, data), gl):
            print("done", t, flush=True)
