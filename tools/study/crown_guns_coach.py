#!/usr/bin/env python3
"""CROWN GUNS COACH measure (crown-guns-coach, docs/crown_guns_coach.md; after tools/study/crown_coach_measure_2.py): the
Crown computer's fighting coached (scripts/ai_crown_guns.gd) measured with the win-rate design (qa_matches.base(): 19 maps x
round 0 and 1, Hard OPTIMAL v Hard OPTIMAL, to 12:00). Arms:
  A  as is (crbr, crcw)
  C  `gunscoach:off` (crbr, crcw)
    python3 tools/study/crown_guns_coach.py list
    python3 tools/study/crown_guns_coach.py run OUT --data DATA [--jobs 2] [--end 720]
Order: round 0 then round 1, map by map, crcw then crbr, each game's arms next to each other, so a run cut short still has
paired data. DATA/<arm>/<tag>/result.json done = skipped (resumable). A measuring tool only."""
import os, sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

ARMS = [("A", []), ("C", ["gunscoach:off"])]
PAIRS = ["crcw", "crbr"]


def queue():
    q = []
    for r in (0, 1):
        gl = [g for g in qm.base(r) if g[0].split("_")[-2] in PAIRS]
        gl.sort(key=lambda g: (qm.MAPS.index(g[1]), PAIRS.index(g[0].split("_")[-2])))
        for g in gl:
            for arm, extra in ARMS:
                q.append((arm, extra, g))
    return q


def run(item, out, end, data):
    arm, extra, g = item
    return arm + " " + qm.run_one(g, os.path.join(out, arm), end, os.path.join(data, arm), list(extra))


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
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/crown_guns_coach/data")))
    end = int(arg("--end", "720"))
    print("%d games" % len(gl), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda it: run(it, out, end, data), gl):
            print("done", t, flush=True)
