#!/usr/bin/env python3
"""PLAN MATRIX, the Brood's WAVES (plan-matrix-brood, docs/plan_matrix_brood.md): from each game's story.txt, the forced
Brood's attacks ("attacks with N supply") and the waves it pulled back ("pulls its wave back: only A of B is left"), per
plan x opponent: waves sent, waves pulled back, the share of a pulled-back wave lost, the first wave's size and time.
    python3 tools/study/plan_matrix_brood_waves.py DATA
A measuring tool: it changes no rule."""
import os, sys, re
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plan_matrix_report as rep
import plan_matrix as pm

ATT = re.compile(r"^\[(\d+):(\d+)\] P(\d) Brood attacks with (\d+) supply")
BACK = re.compile(r"^\[(\d+):(\d+)\] P(\d) Brood pulls its wave back: only (\d+) of (\d+)")


def main():
    data = sys.argv[1]
    rows = rep.load("brood", data)
    by = defaultdict(list)
    for r in rows:
        p = "P%d" % (r["si"] + 1)
        att, back = [], []
        with open(os.path.join(data, r["tag"], "story.txt"), errors="replace") as f:
            for l in f:
                m = ATT.match(l)
                if m and "P" + m.group(3) == p:
                    att.append((int(m.group(1)) * 60 + int(m.group(2)), int(m.group(4))))
                m = BACK.match(l)
                if m and "P" + m.group(3) == p:
                    back.append((int(m.group(4)), int(m.group(5))))
        by[(r["plan"], r["opp"])].append((att, back))
    print("| plan | opponent | games | waves a game | first wave (median time, supply) | waves pulled back a game | "
          "lost of a pulled-back wave |")
    print("|---|---|---|---|---|---|---|")
    for o in pm.FACS:
        for p in pm.plans_of("brood"):
            g = by.get((p, o))
            if not g:
                continue
            n = len(g)
            waves = sum(len(a) for a, _ in g) / n
            first = [a[0] for a, _ in g if a]
            ft = rep.med([x[0] for x in first])
            fs = rep.med([x[1] for x in first])
            pb = sum(len(b) for _, b in g) / n
            lost = [1 - a / b for _, bb in g for a, b in bb if b]
            print("| %s | %s | %d | %.1f | %s, %s | %.1f | %s |" % (
                p, rep.NAME[o], n, waves, rep.mmss(ft), rep.f0(fs), pb,
                "%d%%" % round(100 * sum(lost) / len(lost)) if lost else "-"))


if __name__ == "__main__":
    main()
