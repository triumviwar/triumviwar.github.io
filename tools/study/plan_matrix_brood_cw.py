#!/usr/bin/env python3
"""PLAN MATRIX, Brood v the Clockwork (plan-matrix-brood, docs/plan_matrix_brood.md): almost every game is lost, so the
won/led count can't rank the plans. Here each plan's games are paired with the RUSH's (the plan OPTIMAL opens on its GREEDY
read) on the same map and round and ranked finer: result first (W > draw > L), then a loss later beats a loss sooner, a draw
by the score (income + 2 x army) share. Better / worse and a two-sided sign test; also the mean finer score.
    python3 tools/study/plan_matrix_brood_cw.py DATA [opponent] [base plan]
A measuring tool: it changes no rule."""
import os, sys
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plan_matrix_report as rep
import plan_matrix as pm


def fine(r):
    """a number: higher is better for the Brood"""
    if r["res"] == "W":
        return 3.0
    if r["res"] == "L":
        return -2.0 + r["end"] / 1200.0          # -2 at once .. -1 at the bell
    fin = r["final"]
    a = fin[r["si"]]["income"] + 2 * fin[r["si"]]["army"]
    b = fin[r["oi"]]["income"] + 2 * fin[r["oi"]]["army"]
    return 2.0 * a / max(a + b, 1)               # a draw: 0 .. 2 by the share


def main():
    data = sys.argv[1]
    opp = sys.argv[2] if len(sys.argv) > 2 else "clockwork"
    basep = sys.argv[3] if len(sys.argv) > 3 else "rush"
    rows = [r for r in rep.load("brood", data) if r["opp"] == opp]
    by = defaultdict(dict)
    for r in rows:
        by[r["plan"]][(r["map"], r["r"])] = r
    base = by[basep]
    print("| plan v %s | games | mean finer score | better / worse than %s (same map and round) | p |" % (rep.NAME[opp], basep))
    print("|---|---|---|---|---|")
    out = []
    for p in pm.plans_of("brood"):
        g = by.get(p, {})
        if not g:
            continue
        sc = [fine(r) for r in g.values()]
        up = down = 0
        for k, r in g.items():
            if p == basep or k not in base:
                continue
            d = fine(r) - fine(base[k])
            up += d > 0
            down += d < 0
        pv = rep.binom_p(min(up, down), up + down) if up + down else 1.0
        out.append((sum(sc) / len(sc), "| %s | %d | %.2f | %s | %s |" % (
            p, len(sc), sum(sc) / len(sc), "-" if p == basep else "%d / %d" % (up, down), "-" if p == basep else rep.fp(pv))))
    for _, l in sorted(out, reverse=True):
        print(l)
    print("\nFiner score: a win 3; a draw 0..2 by the Brood's share of income + 2 x army at the bell; a loss -2 (at once) .. "
          "-1 (at the bell).")


if __name__ == "__main__":
    main()
