#!/usr/bin/env python3
"""keen-sabres-test (docs/keen_sabres_test.md): sums the fights of tools/study_keen_sabres.gd (its out:FILE.json files).
    python3 tools/study/keen_sabres_report.py docs/keen_sabres_test/*.json"""
import json, sys
from collections import defaultdict

ARMS = ["stand", "a", "b", "c", "c2", "d", "e", "f", "f2", "cr"]
rows = []
for f in sys.argv[1:]:
    rows += json.load(open(f))


def line(rs):
    w = sum(r["res"] == "W" for r in rs); d = sum(r["res"] == "D" for r in rs); l = sum(r["res"] == "L" for r in rs)
    k = sum(r["killed"] for r in rs); lo = sum(r["lost_v"] for r in rs)
    rl = sum(r["riders_lost"] for r in rs); rn = sum(r["size"] for r in rs)
    raps = sum(r["raptors"] for r in rs)
    kr = k / 25.0
    return "%d-%d-%d | %s | %d%% | %d%%" % (w, d, l, "%.2f" % (k / lo) if lo else "no loss", round(100 * rl / rn), round(100 * kr / raps) if raps else 0)


fights = [r for r in rows if not r["ground"].startswith("raid")]
print("By arm, all sizes summed (4 seeds x 4 sizes = 16 fights a cell)")
print("| arm | ground | Pack Hunt | W-D-L | trade | riders lost | Raptors killed |")
print("|---|---|---|---|---|---|---|")
for arm in ARMS:
    for pack in [False, True]:
        for gr in ["open", "base"]:
            rs = [r for r in fights if r["arm"] == arm and r["pack"] == pack and r["ground"] == gr]
            if rs:
                print("| %s | %s | %s | %s |" % (arm, gr, "yes" if pack else "no", line(rs)))
print()
print("By arm and size, open and base summed (8 fights a cell): trade (riders lost %)")
sizes = sorted({r["size"] for r in fights})
print("| arm | Pack Hunt | " + " | ".join("%d v %d" % (s, round(s * 5.6)) for s in sizes) + " |")
print("|---|---|" + "---|" * len(sizes))
for arm in ARMS:
    for pack in [False, True]:
        cells = []
        for s in sizes:
            rs = [r for r in fights if r["arm"] == arm and r["pack"] == pack and r["size"] == s]
            if not rs:
                cells.append("")
                continue
            k = sum(r["killed"] for r in rs); lo = sum(r["lost_v"] for r in rs)
            rl = sum(r["riders_lost"] for r in rs); rn = sum(r["size"] for r in rs)
            cells.append("%s (%d%%)" % ("%.2f" % (k / lo) if lo else "-", round(100 * rl / rn)))
        if any(cells):
            print("| %s | %s | %s |" % (arm, "yes" if pack else "no", " | ".join(cells)))
raids = [r for r in rows if r["ground"].startswith("raid")]
if raids:
    print()
    print("| raid | arm | W-D-L | value killed (mean) | grubs killed (of 10) | riders lost (of 4, mean) | rider health left |")
    print("|---|---|---|---|---|---|---|")
    groups = defaultdict(list)
    for r in raids:
        groups[(r["ground"], r["arm"])].append(r)
    for (gr, arm), rs in sorted(groups.items()):
        n = len(rs)
        print("| %s | %s | %d-%d-%d | %.0f | %.1f | %.1f | %d%% |" % (gr, arm, sum(r["res"] == "W" for r in rs), sum(r["res"] == "D" for r in rs),
              sum(r["res"] == "L" for r in rs), sum(r["killed"] for r in rs) / n, sum(r["grubs"] for r in rs) / n,
              sum(r["riders_lost"] for r in rs) / n, sum(r["hp_left"] for r in rs) / n))
