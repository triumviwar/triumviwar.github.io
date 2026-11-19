#!/usr/bin/env python3
"""CROWN BUILD STACK report (docs/crown_build_stack.md): tables from DATA/{on,off} (Crown v Brood, v Clockwork) and
DATA/{a,b} (the Crown mirror: in "a" team 0 has the change, in "b" team 1) of tools/study/crown_build_stack.py. The
win-rate studies' rules (winrate_1115_report.load): a draw's LEADER = income earned + 2 x army value 10% ahead; "won or
led" = won, or led a draw. A measuring tool only.
    python3 tools/study/crown_build_stack_report.py DATA [--label on=...,off=...] > tables.md"""
import os, sys, json, math, statistics as st
from collections import Counter, defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import winrate_1115_report as wr

NAME = {"crbr": "Crown v Brood", "crcw": "Crown v Clockwork"}
RANK = {"W": 4, "w": 3, "=": 2, "l": 1, "L": 0}
MINS = [3, 5, 8, 12]
KEY = ["farm", "cottage", "barracks", "gate", "powder_mill", "foundry", "horse_breeder", "armoury", "town_hall"]


def sign_p(plus, minus):
    n = plus + minus
    if n == 0:
        return 1.0
    k = min(plus, minus)
    return min(1.0, 2 * sum(math.comb(n, i) for i in range(k + 1)) / 2 ** n)


def mean(xs):
    xs = [x for x in xs if x is not None]
    return sum(xs) / len(xs) if xs else None


def med(xs):
    xs = [x for x in xs if x is not None]
    return st.median(xs) if xs else None


def f(x, d=2):
    return "" if x is None else ("%." + str(d) + "f") % x


def mm(s):
    return "" if s is None else "%d:%02d" % (int(s) // 60, int(s) % 60)


def own(r, side, m, k):
    v = wr.val(r, r[side], m, k)
    if v is None and k in ("workers", "halls", "army"):
        lost = r["res"] == ("L" if side == "si" else "W")
        return 0 if lost else None
    return v


def stack_of(data, arm, r):
    g = json.load(open(os.path.join(data, arm, r["tag"], "result.json")))
    return (g.get("crown_ai") or {}).get(str(r["si"]), {}).get("stack", {})


def hall_times(sk):
    """the 2nd and 3rd Town Hall's done clock (the first halls finished, in order)"""
    t = sorted(e[2] for e in sk.get("built", []) if e[0] == "town_hall")
    return (t[0] if len(t) > 0 else None, t[1] if len(t) > 1 else None)


def build_secs(rows_sk):
    """placed -> done seconds by kind, all games of an arm"""
    by = defaultdict(list)
    crew = defaultdict(list)
    for sk in rows_sk:
        for k, p, d, n in sk.get("built", []):
            by[k].append(d - p)
            crew[k].append(n)
    return by, crew


def paired_test(tags, A, B, fn):
    up = dn = 0
    for t in tags:
        a, b = fn(A[t]), fn(B[t])
        if a is None or b is None:
            continue
        if a > b:
            up += 1
        elif a < b:
            dn += 1
    return up, dn, sign_p(up, dn)


def cross(data, pair, arms, label, P):
    A = {r["tag"]: r for r in wr.load(os.path.join(data, arms[0]), pair)}
    B = {r["tag"]: r for r in wr.load(os.path.join(data, arms[1]), pair)}
    tags = sorted(set(A) & set(B))
    if not tags:
        return
    for src, arm in ((A, arms[0]), (B, arms[1])):
        for t in tags:
            src[t]["sk"] = stack_of(data, arm, src[t])
    P("## %s (%d paired games, Crown's view)\n" % (NAME[pair], len(tags)))
    P("| arm | W-D-L | won or led: Crown / enemy / even | built halls lost (Crown / enemy) | 2nd hall done (median) | 3rd hall done |")
    P("|---|---|---|---|---|---|")
    for src, arm in ((A, arms[0]), (B, arms[1])):
        rr = [src[t] for t in tags]
        w, d, l = wr.wl(rr)
        a, b, e = wr.woled(rr)
        h2 = [hall_times(r["sk"])[0] for r in rr]
        h3 = [hall_times(r["sk"])[1] for r in rr]
        P("| %s | %d-%d-%d | %d / %d / %d | %.2f / %.2f | %s (%d games) | %s (%d games) |" % (label[arm], w, d, l, a, b, e,
            mean([r["halls"][r["si"]] for r in rr]), mean([r["halls"][r["oi"]] for r in rr]),
            mm(med(h2)), sum(x is not None for x in h2), mm(med(h3)), sum(x is not None for x in h3)))
    P("")
    P("Crown labourers, the Crown's own income earned (gold), halls, army value; per-game mean, and the enemy's workers:\n")
    P("| arm | " + " | ".join("labs %d:00" % m for m in MINS) + " | " + " | ".join("earned %d:00" % m for m in MINS)
      + " | halls 8:00 | 12:00 | army 8:00 | 12:00 | enemy workers 8:00 |")
    P("|---|" + "---|" * (2 * len(MINS) + 5))
    for src, arm in ((A, arms[0]), (B, arms[1])):
        rr = [src[t] for t in tags]
        cells = [f(mean([own(r, "si", m, "workers") for r in rr]), 1) for m in MINS]
        cells += [f(mean([own(r, "si", m, "income") for r in rr]), 0) for m in MINS]
        cells += [f(mean([own(r, "si", m, "halls") for r in rr]), 1) for m in (8, 12)]
        cells += [f(mean([own(r, "si", m, "army") for r in rr]), 0) for m in (8, 12)]
        cells += [f(mean([own(r, "oi", 8, "workers") for r in rr]), 1)]
        P("| %s | %s |" % (label[arm], " | ".join(cells)))
    P("")
    P("Crown / enemy, pooled (sum / sum):\n")
    P("| arm | " + " | ".join("income %d:00" % m for m in MINS) + " | " + " | ".join("army %d:00" % m for m in MINS) + " |")
    P("|---|" + "---|" * (2 * len(MINS)))
    for src, arm in ((A, arms[0]), (B, arms[1])):
        rr = [src[t] for t in tags]
        P("| %s | %s |" % (label[arm], " | ".join(f(wr.ratio(rr, m, k)) for k in ("income", "army") for m in MINS)))
    P("")
    P("Paired, game by game (%s higher / lower, sign test p):\n" % label[arms[0]])
    P("| measure | higher | lower | p |")
    P("|---|---|---|---|")
    tests = [("outcome rank", lambda r: RANK[r["lead"]])]
    for m in MINS:
        tests.append(("Crown labourers %d:00" % m, lambda r, m=m: own(r, "si", m, "workers")))
    for m in MINS:
        tests.append(("Crown income earned %d:00" % m, lambda r, m=m: own(r, "si", m, "income")))
    for m in (8, 12):
        tests.append(("income ratio %d:00" % m, lambda r, m=m: (own(r, "si", m, "income") or 0) / max(1, own(r, "oi", m, "income") or 1)))
        tests.append(("army ratio %d:00" % m, lambda r, m=m: (own(r, "si", m, "army") or 0) / max(1, own(r, "oi", m, "army") or 1)))
    tests.append(("2nd hall sooner", lambda r: -(hall_times(r["sk"])[0] or 9999)))
    tests.append(("3rd hall sooner", lambda r: -(hall_times(r["sk"])[1] or 9999)))
    tests.append(("built halls lost (fewer)", lambda r: -r["halls"][r["si"]]))
    for name, fn in tests:
        up, dn, p = paired_test(tags, A, B, fn)
        P("| %s | %d | %d | %s%.3f%s |" % (name, up, dn, "**" if p < 0.05 else "", p, "**" if p < 0.05 else ""))
    P("")
    P("Build times, placed to done (median s, and the median most labourers on the site):\n")
    P("| arm | " + " | ".join(KEY) + " |")
    P("|---|" + "---|" * len(KEY))
    for src, arm in ((A, arms[0]), (B, arms[1])):
        by, crew = build_secs([src[t]["sk"] for t in tags])
        P("| %s | %s |" % (label[arm], " | ".join("%s (%s)" % (f(med(by[k]), 0), f(med(crew[k]), 0)) if by[k] else "" for k in KEY)))
    P("")
    sk = [A[t]["sk"] for t in tags]
    by = Counter()
    for s in sk:
        by.update(s.get("by", {}))
    P("Helpers sent (%s), a game: %s (idle %s, to an urgent site %s); by kind: %s\n" % (label[arms[0]],
        f(mean([s.get("sent", 0) for s in sk]), 1), f(mean([s.get("sent_idle", 0) for s in sk]), 1),
        f(mean([s.get("urgent", 0) for s in sk]), 1), ", ".join("%s %.1f" % (k, v / len(sk)) for k, v in by.most_common())))


def mirror(data, P):
    """arm a: team 0 has the change; arm b: team 1. Each game: the side with it against the side without."""
    rows = []
    for arm, side in (("a", 0), ("b", 1)):
        for r in wr.load(os.path.join(data, arm), "crcr"):
            if side == 1:
                r["si"], r["oi"] = 1, 0
                r["lead"] = {"W": "L", "L": "W", "w": "l", "l": "w", "=": "="}[r["lead"]]
                r["res"] = {"W": "L", "L": "W", "D": "D"}[r["res"]]
            r["arm"] = arm
            rows.append(r)
    if not rows:
        return
    P("## Crown mirror (%d games: the side with the change v the side without; arm a = team 0 has it, b = team 1)\n" % len(rows))
    w, d, l = wr.wl(rows)
    a, b, e = wr.woled(rows)
    P("With the change: W-D-L %d-%d-%d, won or led %d / %d / %d (sign p %.3f); built halls lost %.2f v %.2f.\n" % (
        w, d, l, a, b, e, sign_p(a, b), mean([r["halls"][r["si"]] for r in rows]), mean([r["halls"][r["oi"]] for r in rows])))
    P("| measure (with / without, per-game mean) | " + " | ".join("%d:00" % m for m in MINS) + " | with higher / lower (p) at 8:00 |")
    P("|---|" + "---|" * len(MINS) + "---|")
    for k, nm in (("workers", "labourers"), ("income", "income earned"), ("army", "army"), ("halls", "halls")):
        cells = ["%s / %s" % (f(mean([own(r, "si", m, k) for r in rows]), 0), f(mean([own(r, "oi", m, k) for r in rows]), 0)) for m in MINS]
        up = sum(1 for r in rows if (own(r, "si", 8, k) or 0) > (own(r, "oi", 8, k) or 0))
        dn = sum(1 for r in rows if (own(r, "si", 8, k) or 0) < (own(r, "oi", 8, k) or 0))
        P("| %s | %s | %d / %d (%.3f) |" % (nm, " | ".join(cells), up, dn, sign_p(up, dn)))
    P("")


def main():
    data = sys.argv[1]
    label = {"on": "on", "off": "off"}
    if "--label" in sys.argv:
        for kv in sys.argv[sys.argv.index("--label") + 1].split(","):
            k, v = kv.split("=")
            label[k] = v
    P = print
    P("# Tables (tools/study/crown_build_stack_report.py %s)\n" % os.path.basename(data.rstrip("/")))
    for pair in ("crbr", "crcw"):
        cross(data, pair, ("on", "off"), label, P)
    mirror(data, P)


if __name__ == "__main__":
    main()
