#!/usr/bin/env python3
"""BROOD SPOT STUDY report (brood-spot-study, docs/brood_spot_study.md). A measuring tool only.
    python3 tools/study/brood_spot_report.py study DATA [DATA2 ...]   the plain / _swap pairs: spot A v B, P1 v P2, mirror check
    python3 tools/study/brood_spot_report.py spots DATA [DATA2 ...]   any base_* games: each pairing's spot A v spot B
Spot A = the start given to team 0 by the map (starts[0]); with `spotswap` team 0 starts at spot B. A draw's LEADER: income
earned + 2 x army value 10% ahead (the win-rate studies' rule). Sign test p (two-sided) on won-or-led A v B."""
import os, sys, json, glob, math
from collections import defaultdict

T_MIN = [2, 3, 5, 8, 10, 12]


def sign_p(a, b):
    n = a + b
    if n == 0:
        return 1.0
    k = min(a, b)
    s = sum(math.comb(n, i) for i in range(0, k + 1)) / 2 ** n
    return min(1.0, 2 * s)


def load(f):
    g = json.load(open(f))
    at = {}
    for r in g["minutes"]:
        at[(r["p"], int(round(r["t"] / 60)))] = r
    g["_at"] = at
    sc = [x["income"] + 2 * x["army"] for x in g["final"]]
    if g["winner"] >= 0:
        g["_lead"] = g["winner"]
    elif sc[0] > 1.1 * sc[1]:
        g["_lead"] = 0
    elif sc[1] > 1.1 * sc[0]:
        g["_lead"] = 1
    else:
        g["_lead"] = -1
    g["_dec"] = g["winner"] >= 0
    return g


def inc(g, p, m):
    r = g["_at"].get((p, m))
    return r["income"] if r else None


def ratio(g, pa, pb, m):
    a, b = inc(g, pa, m), inc(g, pb, m)
    return a / b if a and b else None


def mean(xs):
    xs = [x for x in xs if x is not None]
    return sum(xs) / len(xs) if xs else None


def sd(xs):
    xs = [x for x in xs if x is not None]
    if len(xs) < 2:
        return None
    m = sum(xs) / len(xs)
    return (sum((x - m) ** 2 for x in xs) / (len(xs) - 1)) ** 0.5


def f2(x):
    return "" if x is None else "%.3f" % x


def roots(g, p, kind):
    return sorted(e["t"] for e in g["events"] if e.get("ev") == "root" and e["p"] == p and e["kind"] == kind)


def study(dirs):
    plain, swap = {}, {}
    for d in dirs:
        for f in glob.glob(os.path.join(d, "*", "result.json")):
            tag = os.path.basename(os.path.dirname(f))
            if tag.endswith("_swap"):
                swap[tag[:-5]] = load(f)
            else:
                plain[tag] = load(f)
    print("| run | games | spot A won or led / B / even | p | P1 won or led / P2 | decided | income A/B 2:00 | 3:00 | 5:00 | 8:00 | 10:00 | 12:00 |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for name, gs, a_team in (("plain (P1 at A)", plain, 0), ("spotswap (P1 at B)", swap, 1), ("both", None, None)):
        rows = []
        if gs is None:
            rows = [(g, 0) for g in plain.values()] + [(g, 1) for g in swap.values()]
        else:
            rows = [(g, a_team) for g in gs.values()]
        if not rows:
            continue
        a = sum(1 for g, at in rows if g["_lead"] == at)
        b = sum(1 for g, at in rows if g["_lead"] == 1 - at)
        e = sum(1 for g, at in rows if g["_lead"] == -1)
        p1 = sum(1 for g, at in rows if g["_lead"] == 0)
        p2 = sum(1 for g, at in rows if g["_lead"] == 1)
        dec = sum(1 for g, at in rows if g["_dec"])
        rs = [mean([ratio(g, at, 1 - at, m) for g, at in rows]) for m in T_MIN]
        print("| %s | %d | %d / %d / %d | %.3f | %d / %d | %d | %s |" % (name, len(rows), a, b, e, sign_p(a, b), p1, p2, dec,
              " | ".join(f2(x) for x in rs)))
    # the mirror check: is the swapped game the plain game with the players exchanged?
    same, near, diff = 0, 0, []
    for tag, g in sorted(plain.items()):
        s = swap.get(tag)
        if s is None:
            continue
        ok = True
        first = None
        for m in range(1, 13):
            for p in (0, 1):
                x, y = g["_at"].get((p, m)), s["_at"].get((1 - p, m))
                if x is None or y is None:
                    continue
                if x["income"] != y["income"] or x["army"] != y["army"] or x["workers"] != y["workers"]:
                    ok = False
                    if first is None:
                        first = m
        if ok:
            same += 1
        else:
            diff.append((tag, first))
    print("\nMirror check (the swapped game = the plain game with the players exchanged, minute by minute: income, army, "
          "workers): %d of %d identical." % (same, same + len(diff)))
    if diff:
        print("First differing minute: " + ", ".join("%s %s" % (t.replace("base_", ""), m) for t, m in diff))
    # per game: spot A's result and income ratio, plain and swapped
    print("\n| game | plain: A's result, inc A/B 5:00, 8:00 | swapped: A's result, inc A/B 5:00, 8:00 |")
    print("|---|---|---|")
    for tag in sorted(plain):
        g = plain[tag]
        s = swap.get(tag)
        def cell(g, at):
            if g is None:
                return ""
            r = "W" if g["_dec"] and g["_lead"] == at else "L" if g["_dec"] else "w" if g["_lead"] == at else "l" if g["_lead"] == 1 - at else "="
            return "%s %s %s" % (r, f2(ratio(g, at, 1 - at, 5)), f2(ratio(g, at, 1 - at, 8)))
        print("| %s | %s | %s |" % (tag.replace("base_", ""), cell(g, 0), cell(s, 1)))
    # the roots: when spot A's and spot B's k-th Rootmaw / Mound Turtle rooted (plain and swapped together)
    print("\n| kind | k-th | spot A mean root time (s) | spot B | A first / B first / same |")
    print("|---|---|---|---|---|")
    for kind in ("rootmaw", "mound_turtle"):
        for k in range(1, 7):
            ta, tb, af, bf, eq = [], [], 0, 0, 0
            for gs, at in ((plain, 0), (swap, 1)):
                for g in gs.values():
                    ra, rb = roots(g, at, kind), roots(g, 1 - at, kind)
                    if len(ra) >= k and len(rb) >= k:
                        ta.append(ra[k - 1])
                        tb.append(rb[k - 1])
                        if ra[k - 1] < rb[k - 1]:
                            af += 1
                        elif rb[k - 1] < ra[k - 1]:
                            bf += 1
                        else:
                            eq += 1
            if ta:
                print("| %s | %d | %.0f | %.0f | %d / %d / %d |" % (kind, k, mean(ta), mean(tb), af, bf, eq))


def spots(dirs):
    by = defaultdict(list)
    for d in dirs:
        for f in glob.glob(os.path.join(d, "base_*", "result.json")):
            tag = os.path.basename(os.path.dirname(f))
            pair = tag.split("_")[-2]
            g = load(f)
            by[pair].append(g)
    print("| pairing | games | spot A won or led / B / even | p | income A/B 5:00 (sd) | 8:00 (sd) | 10:00 |")
    print("|---|---|---|---|---|---|---|")
    for pair in sorted(by):
        gs = by[pair]
        a = sum(1 for g in gs if g["_lead"] == 0)
        b = sum(1 for g in gs if g["_lead"] == 1)
        e = sum(1 for g in gs if g["_lead"] == -1)
        r5 = [ratio(g, 0, 1, 5) for g in gs]
        r8 = [ratio(g, 0, 1, 8) for g in gs]
        r10 = [ratio(g, 0, 1, 10) for g in gs]
        print("| %s | %d | %d / %d / %d | %.3f | %s (%s) | %s (%s) | %s |" % (pair, len(gs), a, b, e, sign_p(a, b),
              f2(mean(r5)), f2(sd(r5)), f2(mean(r8)), f2(sd(r8)), f2(mean(r10))))
    # per faction at spot A v at spot B in the cross pairings: income per minute (its own), so A v B for the same faction
    print("\n| faction (cross pairings) | at spot A: income 5:00 / 8:00 | at spot B: 5:00 / 8:00 | won or led at A / at B |")
    print("|---|---|---|---|")
    fac = defaultdict(lambda: {"A5": [], "A8": [], "B5": [], "B8": [], "wa": 0, "na": 0, "wb": 0, "nb": 0})
    for pair, gs in by.items():
        if pair[:2] == pair[2:]:
            continue
        for g in gs:
            for p in (0, 1):
                fa = g["slots"][p][0]
                k = "A" if p == 0 else "B"
                fac[fa][k + "5"].append(inc(g, p, 5))
                fac[fa][k + "8"].append(inc(g, p, 8))
                fac[fa]["w" + k.lower()] += 1 if g["_lead"] == p else 0
                fac[fa]["n" + k.lower()] += 1
    for fa, v in sorted(fac.items()):
        print("| %s | %s / %s | %s / %s | %d of %d / %d of %d |" % (fa, f2(mean(v["A5"])), f2(mean(v["A8"])), f2(mean(v["B5"])),
              f2(mean(v["B8"])), v["wa"], v["na"], v["wb"], v["nb"]))


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    {"study": study, "spots": spots}[sys.argv[1]](sys.argv[2:])
