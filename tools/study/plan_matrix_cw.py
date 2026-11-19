#!/usr/bin/env python3
"""PLAN MATRIX (jobs plan-matrix-clockwork / plan-matrix-crown / plan-matrix-brood, 2026-11-18; the owner: "open up the
testing to all strategies against all factions"): every plan of ONE faction FORCED on its Hard computer, against each
opponent faction playing Hard OPTIMAL, run by tools/study/qa_matches.py's run_one (tools/qa_match.gd). A measuring tool.
    python3 tools/study/plan_matrix.py FACTION list [--maps N]
    python3 tools/study/plan_matrix.py FACTION run OUT --data DATA [--jobs 1] [--end 1200] [--maps N] [--plans a,b] [--opps x,y]
FACTION: crown, brood or clockwork. Its plans: AI.STRATEGIES' for that faction (not the hidden Turret turtle: tools/qa_match.gd
cannot force a hidden plan), OPTIMAL
included (the baseline every plan is compared with, game for game).
A cell = (plan, opponent): MAPS x 2 rounds. The seed is the map's and the round's only (the same for every plan and every
opponent), and the round swaps the start spots (round 0: the subject on slot P1 / spot A, round 1 on P2), so each plan
plays the same games as OPTIMAL: a paired design. Tags: pm_<f>-<plan>_v_<opp>_<map>_r<round>.
Order: the maps in MAPS order, each map's two rounds with every cell, so a run cut short has whole maps for every cell
(--maps N keeps the first N maps). Done games (DATA/<tag>/result.json or FAILED.txt) are skipped."""
import os, sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

# the study's six maps (all kinds: three classic, three named), the first four the ones kept if time is short
MAPS = ["greenhold", "ashford_crossing", "mirewood", "cinder_steps", "frostfang", "dune_sea"]
PLANS = {
    "crown": ["optimal", "balanced", "rush", "economy", "timing", "dragoon", "siege", "balloon"],
    "brood": ["optimal", "balanced", "rush", "economy", "timing", "air", "xrush", "spitter", "brute"],
    "clockwork": ["optimal", "balanced", "rush", "economy", "timing", "pendulum", "heavy", "springer", "cs_rush", "owls"],
}
OPPS = ["crown", "brood", "clockwork"]
SHORT = qm.SHORT


def seed_of(mi, r):
    return 2100 + 37 * r + 3 * mi


def queue(fac, maps=6, plans=None, opps=None):
    plans = plans or PLANS[fac]
    opps = opps or OPPS
    q = []
    for mi, m in enumerate(MAPS[:maps]):
        for r in (0, 1):
            for o in opps:
                for p in plans:
                    me, foe = (fac, p), (o, "optimal")
                    s1, s2 = (me, foe) if r == 0 else (foe, me)
                    tag = "pm_%s-%s_v_%s_%s_r%d" % (SHORT[fac], p, SHORT[o], m, r)
                    q.append((tag, m, seed_of(mi, r), [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
    return q


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if len(sys.argv) < 3 or sys.argv[1] not in PLANS or sys.argv[2] not in ("list", "run"):
        print(__doc__)
        sys.exit(1)
    fac = sys.argv[1]
    plans = arg("--plans", "")
    plans = plans.split(",") if plans else PLANS[fac]
    opps = arg("--opps", "")
    opps = opps.split(",") if opps else None
    gl = queue(fac, int(arg("--maps", "6")), plans, opps)
    if sys.argv[2] == "list":
        for g in gl:
            print(g[0], g[1], g[2], g[3])
        sys.exit(0)
    out = os.path.abspath(sys.argv[3])
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/plan_matrix_%s/data" % fac)))
    end = int(arg("--end", "1200"))
    qm.KEEP_CW = "--cwlog" in sys.argv          # (cw-written-openings: the Clockwork's own match-log lines, cwlog.txt)
    if arg("--extra", ""):
        qm.EXTRA = arg("--extra", "").split(",")      # study switches for every game, e.g. cwcommon:off
    print("%d games" % len(gl), flush=True)

    def one(g):
        if os.path.exists(os.path.join(out, "STOP")):
            return g[0] + " (stopped)"
        return qm.run_one(g, out, end, data)

    with ThreadPoolExecutor(int(arg("--jobs", "1"))) as ex:
        for t in ex.map(one, gl):
            print("done", t, flush=True)
