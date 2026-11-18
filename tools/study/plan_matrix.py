#!/usr/bin/env python3
"""PLAN MATRIX (plan-matrix-<faction>, docs/plan_matrix_<faction>.md): every plan of one faction FORCED on its Hard computer,
against each opponent faction (Crown, Clockwork, the mirror) playing Hard OPTIMAL. A measuring tool: it changes no rule.
    python3 tools/study/plan_matrix.py FACTION list [--maps a,b,..]
    python3 tools/study/plan_matrix.py FACTION run OUT --data DATA [--jobs 1] [--end 1200] [--maps ...] [--plans ...] [--opps ...] [--timeout 1800]
FACTION: crown, clockwork or brood. Plans: AI.STRATEGIES for that faction (scripts/ai.gd strategies_for: the shared ones,
the faction's own, OPTIMAL itself as the baseline; the hidden Turret turtle left out).
Each cell (plan x opponent) plays MAPS x 2 rounds: round 0 the subject on one spot, round 1 the spots swapped (as in
qa_matches.base: the same seeds per map and pairing, so the OPTIMAL cell is the earlier studies' games run longer).
Order: map by map, both rounds, every cell, so a run cut short has every cell on the same maps with both spots.
A game is done when DATA/<tag>/result.json (or FAILED.txt) exists; run again to resume. tools/qa_match.gd plays it."""
import os, sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = ["greenhold", "ashford_crossing", "mirewood", "frostfang", "cinder_steps", "dune_sea"]
SHARED = ["balanced", "rush", "economy", "timing"]
OWN = {"brood": ["air", "xrush", "spitter", "brute"],
       "clockwork": ["pendulum", "heavy", "springer", "cs_rush", "owls"],
       "crown": ["dragoon", "siege", "balloon"]}
FACS = ["crown", "clockwork", "brood"]


def plans_of(f):
    return SHARED + OWN[f] + ["optimal"]


def pair_code(a, b):
    """the qa_matches pairing code for two factions (its PAIRS order) and its index"""
    for i, (x, y) in enumerate(qm.PAIRS):
        if {x, y} == {a, b} and (a == b) == (x == y):
            return qm.SHORT[x] + qm.SHORT[y], i
    raise ValueError((a, b))


def queue(f, maps=MAPS, plans=None, opps=None):
    plans = plans or plans_of(f)
    opps = opps or FACS
    out = []
    for m in maps:
        mi = qm.MAPS.index(m)
        for r in (0, 1):
            for o in opps:
                code, pi = pair_code(f, o)
                seed = 1100 + 37 * r + 3 * mi + pi        # qa_matches.base's seed for this map, round and pairing
                swap = (r + mi) % 2 == 1                  # the subject on spot A in one round, spot B in the other
                for p in plans:
                    me, foe = (f, p), (o, "optimal")
                    s1, s2 = (foe, me) if swap else (me, foe)
                    tag = "pm_%s-%s_v_%s_%s_r%d" % (qm.SHORT[f], p, qm.SHORT[o], m, r)
                    out.append((tag, m, seed, [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
    return out


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if len(sys.argv) < 3 or sys.argv[1] not in FACS or sys.argv[2] not in ("list", "run"):
        print(__doc__)
        sys.exit(1)
    f = sys.argv[1]
    lst = lambda k: arg(k, "").split(",") if k in sys.argv else None
    gl = queue(f, lst("--maps") or MAPS, lst("--plans"), lst("--opps"))
    if sys.argv[2] == "list":
        for g in gl:
            print(g[0], g[1], g[2], g[3])
        print(len(gl), "games")
        sys.exit(0)
    out = os.path.abspath(sys.argv[3])
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/plan_matrix_%s/data" % f)))
    end = int(arg("--end", "1200"))
    qm.TIMEOUT = int(arg("--timeout", "1800"))      # (plan-matrix-brood-2: ~3x a 20:00 game; a hung game is killed, FAILED.txt, the run goes on)
    print("%d games" % len(gl), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "1"))) as ex:
        for t in ex.map(lambda g: qm.run_one(g, out, end, data), gl):
            print("done", t, flush=True)
            if os.path.exists(os.path.join(out, "STOP")):
                print("STOP seen", flush=True)
                os._exit(0)
