#!/usr/bin/env python3
"""(wr1000-crown-clockwork) the Clockwork's Winders lost a game in a block, and what killed them with what order on.
    python3 tools/study/wr1000_winders.py BLOCK [BLOCK ...]"""
import os, sys, json, glob, collections
DATA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../docs/wr1000_crown_clockwork/data")
for b in sys.argv[1:]:
    n = 0; lost = 0; by = collections.Counter()
    for f in glob.glob(os.path.join(DATA, b, "wcc_*", "result.json")):
        g = json.load(open(f)); n += 1
        cw = [i for i, s in enumerate(g["slots"]) if (s.get("faction") if isinstance(s, dict) else s[0]) == "clockwork"][0]
        for r in g["deaths"]:
            if r[2] == cw and r[1] == "winder":
                lost += 1; by[r[7] + " by " + r[3]] += 1
    print("%s: %d games, %.1f Winders lost a game; %s" % (b, n, lost / max(1, n), ", ".join("%s %.1f" % (k, v / n) for k, v in by.most_common(5))))
