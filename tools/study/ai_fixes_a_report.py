#!/usr/bin/env python3
"""(ai-fixes-a, docs/ai_fixes_a.md) the study's tables.
    python3 tools/study/ai_fixes_a_report.py bench DATA [DATA...]   the benchmark player's record against each arm
    python3 tools/study/ai_fixes_a_report.py raid OFF ON             the Clockwork side, paired on the same tags, + its defence lines
Results read as ai_opponent_review_report.outcome: W won, w led by 10%+, = even, l trailed, L lost (score income + 2 x army)."""
import os, sys, glob, re, math
from collections import Counter
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ai_opponent_review_report import load_game, outcome, STRS

SC = {"W": 2, "w": 1, "=": 0, "l": -1, "L": -2}


def games(data):
    out = {}
    for f in sorted(glob.glob(os.path.join(data, "*", "result.json"))):
        out[os.path.basename(os.path.dirname(f))] = load_game(f)
    return out


def bench(datas):
    print("| arm | games | novice W-D-L (won or led) | average | good | all: won or led / lost or trailed / even | mean score | computer army 8:00 | income 8:00 |")
    print("|---|---|---|---|---|---|---|---|---|")
    for d in datas:
        g = games(d)
        by = {s: Counter() for s in STRS}
        allc = Counter()
        sc = []
        army = []
        inc = []
        for tag, x in g.items():
            sl = x["g"]["slots"]
            bi = [i for i, s in enumerate(sl) if len(s) > 3 and s[3] in STRS][0]
            o = outcome(x, bi)
            by[sl[bi][3]][o] += 1
            allc[o] += 1
            sc.append(SC[o])
            a = x["at"].get((1 - bi, 8))
            if a:
                army.append(a["army"])
                inc.append(a["income"])
        f = lambda c: "%d-%d-%d (%d)" % (c["W"], c["w"] + c["="] + c["l"], c["L"], c["W"] + c["w"])
        m = lambda v: "%d" % (sum(v) / len(v)) if v else "-"
        print("| %s | %d | %s | %s | %s | %d / %d / %d | %+.2f | %s | %s |" % (os.path.basename(d.rstrip("/")), len(g), f(by["novice"]), f(by["average"]), f(by["good"]),
              allc["W"] + allc["w"], allc["L"] + allc["l"], allc["="], sum(sc) / max(1, len(sc)), m(army), m(inc)))


WHOLE = re.compile(r"whole army defends the base \((\d+) units, (\d+),.*raid worth (\d+)")
GROUP = re.compile(r"small raid worth (\d+) .*sends (\d+) units \((\d+)\)")
HOME = re.compile(r"turns home fighting")
PART = re.compile(r"home fighting for Brood raiders")


def lines(data, tag):
    f = os.path.join(data, tag, "cwlog.txt")
    if not os.path.exists(f):
        return []
    return [l for l in open(f, errors="replace") if "Clockwork" in l]


def raid(off, on):
    a, b = games(off), games(on)
    better = worse = same = 0
    diffs = []
    rows = []
    stat = {}
    for name, d, g in (("off", off, a), ("on", on, b)):
        c = Counter()
        big = whole = grp = home = part = 0
        for tag, x in g.items():
            si = [i for i, s in enumerate(x["g"]["slots"]) if s[0] == "clockwork"][0]
            c[outcome(x, si)] += 1
            for l in lines(d, tag):
                m = WHOLE.search(l)
                if m:
                    whole += 1
                    if int(m.group(2)) > 5 * max(1, int(m.group(3))):
                        big += 1
                if GROUP.search(l):
                    grp += 1
                if HOME.search(l):
                    home += 1
                if PART.search(l):
                    part += 1
        stat[name] = (len(g), c, whole, big, grp, home, part)
    for tag in sorted(set(a) & set(b)):
        x, y = a[tag], b[tag]
        si = [i for i, s in enumerate(x["g"]["slots"]) if s[0] == "clockwork"][0]
        o1, o2 = outcome(x, si), outcome(y, si)
        diffs.append(SC[o2] - SC[o1])
        better += SC[o2] > SC[o1]
        worse += SC[o2] < SC[o1]
        same += SC[o2] == SC[o1]
        f = lambda r, m, k: str(r["at"].get((si, m), {}).get(k, "-"))
        rows.append("| %s | %s | %s | %s / %s | %s / %s |" % (tag, o1, o2, f(x, 12, "army"), f(y, 12, "army"), f(x, 16, "income"), f(y, 16, "income")))
    print("| arm | games | Clockwork W-D-L | won or led / lost or trailed / even | whole-army answers | of them over 5x the raid | sized groups sent | whole push home | part of the push home |")
    print("|---|---|---|---|---|---|---|---|---|")
    for name in ("off", "on"):
        n, c, whole, big, grp, home, part = stat[name]
        print("| %s | %d | %d-%d-%d | %d / %d / %d | %d | %d | %d | %d | %d |" % (name, n, c["W"], c["w"] + c["="] + c["l"], c["L"], c["W"] + c["w"], c["L"] + c["l"], c["="], whole, big, grp, home, part))
    n = len(diffs)
    if n > 1:
        mu = sum(diffs) / n
        sd = math.sqrt(sum((d - mu) ** 2 for d in diffs) / (n - 1))
        t = mu / (sd / math.sqrt(n)) if sd > 0 else 0.0
        print("\nPaired on %d tags (the Clockwork's side): better %d, worse %d, the same %d; mean change %+.2f (t %.1f)." % (n, better, worse, same, mu, t))
    print("\n| game | off | on | Clockwork army 12:00 off / on | income 16:00 off / on |")
    print("|---|---|---|---|---|")
    for r in rows:
        print(r)


if __name__ == "__main__":
    if sys.argv[1] == "bench":
        bench(sys.argv[2:])
    else:
        raid(sys.argv[2], sys.argv[3])
