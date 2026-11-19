#!/usr/bin/env python3
"""PLAN MATRIX (plan-matrix-crown / -clockwork / -brood; docs/plan_matrix_<faction>.md): every plan of one faction FORCED on
its computer, against each opponent faction (the two others and the mirror) playing OPTIMAL, Hard v Hard, by
tools/study/qa_matches.py's run_one (tools/qa_match.gd). A measuring tool: it changes no rule.
    python3 tools/study/plan_matrix.py list --faction crown [--maps m1,m2] [--plans p1,p2] [--opps brood,clockwork,crown]
    python3 tools/study/plan_matrix.py run OUT --faction crown --data DATA [--jobs 2] [--end 1200] [...the same filters]
A cell = one plan of FACTION v one opponent faction; each map is played twice (round 0 and 1, the start spots swapped),
so 6 maps = 12 games a cell. The seed is the same for every plan of a cell's map and round (paired against OPTIMAL's row).
Order: map by map (both rounds, every cell), so a run cut short after k maps has every cell on the same k maps.
Done games (DATA/<tag>/result.json or FAILED.txt) are skipped; run again to resume. OUT/STOP stops it after the games
under way."""
import os, sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = ["greenhold", "ashford_crossing", "mirewood", "frostfang", "cinder_steps", "dune_sea"]
FACS = ["crown", "brood", "clockwork"]
SHORT = {"crown": "cr", "brood": "br", "clockwork": "cw"}


def plans_of(fac):
    return qm.PLANS[fac] + ["optimal"]


def queue(fac, maps=None, plans=None, opps=None):
    maps = maps or MAPS
    plans = plans or plans_of(fac)
    opps = opps or [o for o in FACS if o != fac] + [fac]
    out = []
    for m in maps:
        mi = qm.MAPS.index(m)
        for r in (0, 1):
            for oi, o in enumerate(opps):
                seed = 9100 + 97 * r + 11 * mi + 3 * FACS.index(o) + 1 * FACS.index(fac)
                swap = (r + mi) % 2 == 1        # side 0 = spot A
                for p in plans:
                    me, foe = (fac, p), (o, "optimal")
                    s1, s2 = (foe, me) if swap else (me, foe)
                    tag = "pm_%s-%s_v_%s_%s_r%d" % (SHORT[fac], p, SHORT[o], m, r)
                    out.append((tag, m, seed, [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
    return out


def parse_tag(tag):
    """pm_cr-rush_v_cw_greenhold_r0 -> (fac, plan, opp, map, round)"""
    a = tag[3:]
    fp, rest = a.split("_v_", 1)
    f, p = fp.split("-", 1)
    o, rest = rest.split("_", 1)
    m, r = rest.rsplit("_r", 1)
    inv = {v: k for k, v in SHORT.items()}
    return inv[f], p, inv[o], m, int(r)


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if len(sys.argv) < 2 or sys.argv[1] not in ("list", "run"):
        print(__doc__)
        sys.exit(1)
    fac = arg("--faction", "crown")
    sp = lambda k: [x for x in arg(k, "").split(",") if x] or None
    gl = queue(fac, sp("--maps"), sp("--plans"), sp("--opps"))
    if sys.argv[1] == "list":
        for g in gl:
            print(g[0], g[1], g[2], g[3])
        print(len(gl), "games")
        sys.exit(0)
    out = os.path.abspath(sys.argv[2])
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/plan_matrix_%s/data" % fac)))
    end = int(arg("--end", "1200"))
    print("%d games" % len(gl), flush=True)

    def one(g):
        if os.path.exists(os.path.join(out, "STOP")):
            return g[0] + " (stopped)"
        return qm.run_one(g, out, end, data)

    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(one, gl):
            print("done", t, flush=True)
