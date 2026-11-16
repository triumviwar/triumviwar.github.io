#!/usr/bin/env python3
"""BROOD SPOT STUDY (docs/brood_spot_study.md): spot A's income over spot B's per game at each minute mark, plain and
spotswap games together: mean, sd, t (mean-1 over its standard error), games A ahead, sign test p. A measuring tool.
    python3 tools/study/brood_spot_income.py DATA [DATA2 ...]"""
import os, sys, json, glob, math


def sign_p(a, b):
    n = a + b
    k = min(a, b)
    return min(1.0, 2 * sum(math.comb(n, i) for i in range(k + 1)) / 2 ** n) if n else 1.0


for d in sys.argv[1:]:
    rows = {}
    for f in glob.glob(os.path.join(d, "*", "result.json")):
        g = json.load(open(f))
        a = 1 if os.path.basename(os.path.dirname(f)).endswith("_swap") else 0
        at = {(r["p"], round(r["t"] / 60)): r["income"] for r in g["minutes"]}
        for m in (2, 3, 5, 8, 10, 12):
            x, y = at.get((a, m)), at.get((1 - a, m))
            if x and y:
                rows.setdefault(m, []).append(x / y)
    print("%s\n| minute | games | A/B mean | sd | t | A ahead / B ahead | p |\n|---|---|---|---|---|---|---|" % d)
    for m in sorted(rows):
        r = rows[m]
        mu = sum(r) / len(r)
        s = (sum((x - mu) ** 2 for x in r) / (len(r) - 1)) ** 0.5
        up = sum(1 for x in r if x > 1.0001)
        dn = sum(1 for x in r if x < 0.9999)
        print("| %d:00 | %d | %.3f | %.3f | %.1f | %d / %d | %.4f |" % (m, len(r), mu, s, (mu - 1) / (s / len(r) ** 0.5), up, dn, sign_p(up, dn)))
