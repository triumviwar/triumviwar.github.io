#!/usr/bin/env python3
"""(ai-opponent-review) a fix's games beside the study's games on the same tags (map, seed, sides): the result from the
named side's point of view (W/w/=/l/L, see ai_opponent_review_report.py) and its army and income at 8:00 and 12:00.
    python3 tools/study/ai_opponent_review_fix.py FIXDATA BASEDATA [--side computer|crown|brood|clockwork]
--side computer (default): the computer's side in a bench game; a faction: that faction's side (the first if a mirror)."""
import os, sys, glob, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ai_opponent_review_report import load_game, outcome, STRS

fix, base = sys.argv[1], sys.argv[2]
side = sys.argv[sys.argv.index("--side") + 1] if "--side" in sys.argv else "computer"
SC = {"W": 2, "w": 1, "=": 0, "l": -1, "L": -2}
better = worse = same = 0
print("| game | before | after | army 8:00 before / after | income 8:00 before / after | end before / after |")
print("|---|---|---|---|---|---|")
for d in sorted(glob.glob(os.path.join(fix, "*", "result.json"))):
    tag = os.path.basename(os.path.dirname(d))
    b = os.path.join(base, tag, "result.json")
    if not os.path.exists(b):
        continue
    x, y = load_game(b), load_game(d)
    sl = x["g"]["slots"]
    if side == "computer":
        si = [i for i, s in enumerate(sl) if not (len(s) > 3 and s[3] in STRS)][0]
    else:
        si = [i for i, s in enumerate(sl) if s[0] == side][0]
    o1, o2 = outcome(x, si), outcome(y, si)
    a1, a2 = x["at"].get((si, 8)), y["at"].get((si, 8))
    better += SC[o2] > SC[o1]
    worse += SC[o2] < SC[o1]
    same += SC[o2] == SC[o1]
    f = lambda r, k: str(r[k]) if r else "-"
    print("| %s | %s | %s | %s / %s | %s / %s | %d / %d |" % (tag, o1, o2, f(a1, "army"), f(a2, "army"), f(a1, "income"), f(a2, "income"), x["end"], y["end"]))
print("\nFrom that side: better %d, worse %d, the same %d." % (better, worse, same))
