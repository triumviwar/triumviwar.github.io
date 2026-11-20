#!/usr/bin/env python3
"""(crown-rule-cleanup) THE BROOD QUESTION: the Crown's and the enemy's army, supply, income a minute and halls, minute by
minute, the median over the games of the blocks given (games still going at that minute only), from result.json "minutes".
    python3 tools/study/crown_rule_cleanup_curve.py OPP BLOCK[+BLOCK...] [...]"""
import os, sys, json, glob, statistics as st
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import crown_rule_cleanup as c

MINS = [6, 8, 10, 12, 13, 14, 15, 16, 17, 18, 19]


def curve(opp, blocks):
    rows = {m: [] for m in MINS}
    for b in blocks.split("+"):
        for f in glob.glob(os.path.join(c.ROOT_DATA, opp, b, "c1k_*", "result.json")):
            g = json.load(open(f))
            ci = 0 if (g["slots"][0].get("faction") if isinstance(g["slots"][0], dict) else g["slots"][0][0]) == "crown" else 1
            at = {(x["p"], int(round(x["t"] / 60))): x for x in g["minutes"]}
            for m in MINS:
                a, e = at.get((ci, m)), at.get((1 - ci, m))
                if a and e:
                    rows[m].append((a["army"], e["army"], a["supply"], e["supply"], a["income"], e["income"], a["halls"], e["halls"]))
    return rows


if __name__ == "__main__":
    opp = sys.argv[1]
    for b in sys.argv[2:]:
        print("\n%s v %s: median of the games still going (Crown / enemy)" % (b, opp))
        print("| min | games | army | supply | income so far | halls |")
        print("|---|---|---|---|---|---|")
        for m, xs in curve(opp, b).items():
            if not xs:
                continue
            md = lambda i: st.median(x[i] for x in xs)
            print("| %d:00 | %d | %d / %d | %d / %d | %d / %d | %.1f / %.1f |" % (m, len(xs), md(0), md(1), md(2), md(3), md(4), md(5), md(6), md(7)))
