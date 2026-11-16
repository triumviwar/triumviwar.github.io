#!/usr/bin/env python3
"""CROWN FARM FIRST, MEASURED: the report (docs/crown_farmfirst_measure.md) from tools/study/farmfirst_measure.py's data.
    python3 tools/study/farmfirst_report.py [DATA] > tables.md
Arms: ff = as is (the second Farm before the Barracks), off = farmfirst:off (the old order). The subject is the Crown.
Won or led: a win, or a draw at 12:00 led by income earned + 2 x army value 10% ahead (the win-rate studies' rule).
Income = gold earned by then (cumulative); a ratio is the Crown's over the enemy's, summed over the games still running.
Early loss: the game lost, or a built Crown hall lost, before 6:00. Paired sign test: the same map and seed in both arms."""
import os, sys, json, glob, math
from collections import defaultdict

CODE = {"cr": "crown", "br": "brood", "cw": "clockwork"}
NAME = {"crbr": "Crown v Brood", "crcw": "Crown v Clockwork"}
ARMS = ["ff", "off"]
ARMN = {"ff": "Farm first (as is)", "off": "farmfirst:off (old)"}
SCORE = {"W": 2, "w": 1, "=": 0, "l": -1, "L": -2}


def mmss(s):
    return "%d:%02d" % (int(s) // 60, int(s) % 60)


def mean(xs):
    xs = [x for x in xs if x is not None]
    return sum(xs) / len(xs) if xs else None


def f2(x):
    return "" if x is None else "%.2f" % x


def f0(x):
    return "" if x is None else "{:,}".format(int(round(x)))


def load(data, arm, pair):
    out = {}
    for d in sorted(glob.glob(os.path.join(data, arm, "base_*_%s_r*" % pair))):
        f = os.path.join(d, "result.json")
        if not os.path.exists(f):
            continue
        g = json.load(open(f))
        facs = [s[0] for s in g["slots"]]
        si = facs.index("crown")
        oi = 1 - si
        at = {(r["p"], int(round(r["t"] / 60))): r for r in g["minutes"]}
        sc = [x["income"] + 2 * x["army"] for x in g["final"]]
        if g["winner"] >= 0:
            res = "W" if g["winner"] == si else "L"
            lead = res
        else:
            res = "D"
            lead = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")
        hl = [e["t"] for e in g["events"] if e.get("ev") == "hall_lost" and e.get("built") and e["p"] == si]
        early = (res == "L" and g["end"] < 360) or any(t < 360 for t in hl)
        fa = [e["t"] for e in g["events"] if e.get("ev") == "first_attack" and e["p"] == oi]
        bar = None
        picks = [r["pick"] for r in g.get("reads", []) if "pick" in r and r["p"] == si]
        out[os.path.basename(d)] = {"map": g["map"], "seed": g["seed"], "si": si, "oi": oi, "res": res, "lead": lead,
                                    "end": g["end"], "at": at, "early": early, "hl": hl, "foe_attack": fa[0] if fa else None,
                                    "pick": picks[0].split("->")[-1].split("(")[0].strip() if picks else "(none)",
                                    "crown": g["minutes"]}
    return out


def val(r, p, m, k):
    x = r["at"].get((p, m))
    return x[k] if x else None


def ratio(rows, m, k):
    a = b = 0
    n = 0
    for r in rows:
        x, y = val(r, r["si"], m, k), val(r, r["oi"], m, k)
        if x is not None and y is not None:
            a += x
            b += y
            n += 1
    return (a / b if b else None), n


def binom_p(k, n):
    """two-sided sign test"""
    if n == 0:
        return 1.0
    k = min(k, n - k)
    p = sum(math.comb(n, i) for i in range(k + 1)) / 2 ** n
    return min(1.0, 2 * p)


def main():
    data = sys.argv[1] if len(sys.argv) > 1 else "docs/crown_farmfirst_measure/data"
    P = print
    P("# Tables (tools/study/farmfirst_report.py)\n")
    allp = {}
    for pair in NAME:
        arms = {a: load(data, a, pair) for a in ARMS}
        tags = sorted(set(arms["ff"]) & set(arms["off"]))
        if not tags:
            continue
        allp[pair] = (arms, tags)
    P("## In short (paired games only: the same map and seed in both arms)\n")
    P("| pairing | arm | games | W-D-L | won or led / trailed / even | early losses (<6:00) | income 5:00 (ratio) | 8:00 | 12:00 | army 5:00 (ratio) | 8:00 |")
    P("|---|---|---|---|---|---|---|---|---|---|---|")
    for pair, (arms, tags) in allp.items():
        for a in ARMS:
            rows = [arms[a][t] for t in tags]
            w = sum(r["res"] == "W" for r in rows); d = sum(r["res"] == "D" for r in rows); l = sum(r["res"] == "L" for r in rows)
            wl = sum(r["lead"] in "Ww" for r in rows); tl = sum(r["lead"] in "Ll" for r in rows)
            P("| %s | %s | %d | %d-%d-%d | %d / %d / %d | %d | %s | %s | %s | %s | %s |" % (
                NAME[pair], ARMN[a], len(rows), w, d, l, wl, tl, len(rows) - wl - tl, sum(r["early"] for r in rows),
                f2(ratio(rows, 5, "income")[0]), f2(ratio(rows, 8, "income")[0]), f2(ratio(rows, 12, "income")[0]),
                f2(ratio(rows, 5, "army")[0]), f2(ratio(rows, 8, "army")[0])))
    P("")
    for pair, (arms, tags) in allp.items():
        P("## %s\n" % NAME[pair])
        P("### The Crown's income earned (mean) and over the enemy's (ratio of sums, games still running)\n")
        P("| arm | 2:00 | 3:00 | 5:00 | 8:00 | 12:00 | ratio 2:00 | 3:00 | 5:00 | 8:00 | 12:00 | n at 12:00 |")
        P("|---|---|---|---|---|---|---|---|---|---|---|---|")
        for a in ARMS:
            rows = [arms[a][t] for t in tags]
            P("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %d |" % (
                ARMN[a], *[f0(mean([val(r, r["si"], m, "income") for r in rows])) for m in (2, 3, 5, 8, 12)],
                *[f2(ratio(rows, m, "income")[0]) for m in (2, 3, 5, 8, 12)], ratio(rows, 12, "income")[1]))
        P("\n### Army value (the Crown's mean) and over the enemy's\n")
        P("| arm | 3:00 | 5:00 | 8:00 | 12:00 | ratio 3:00 | 5:00 | 8:00 | 12:00 |")
        P("|---|---|---|---|---|---|---|---|---|")
        for a in ARMS:
            rows = [arms[a][t] for t in tags]
            P("| %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (
                ARMN[a], *[f0(mean([val(r, r["si"], m, "army") for r in rows])) for m in (3, 5, 8, 12)],
                *[f2(ratio(rows, m, "army")[0]) for m in (3, 5, 8, 12)]))
        P("\n### Workers, halls, the enemy's first attack (Crown side; means)\n")
        P("| arm | 2 Farms by 2:00 | workers 3:00 | 5:00 | 8:00 | halls 5:00 | 8:00 | enemy's first attack (mean, games with one) | Crown halls lost (built) a game | before 6:00 |")
        P("|---|---|---|---|---|---|---|---|---|---|")
        for a in ARMS:
            rows = [arms[a][t] for t in tags]
            f2n = sum(1 for r in rows if ((val(r, r["si"], 2, "crown") or {}).get("farms") or 0) >= 2)
            fa = [r["foe_attack"] for r in rows if r["foe_attack"] is not None]
            P("| %s | %d of %d | %s | %s | %s | %s | %s | %s (%d) | %.2f | %d |" % (
                ARMN[a], f2n, len(rows), *[f2(mean([val(r, r["si"], m, "workers") for r in rows])) for m in (3, 5, 8)],
                *[f2(mean([val(r, r["si"], m, "halls") for r in rows])) for m in (5, 8)],
                mmss(mean(fa)) if fa else "-", len(fa), mean([len(r["hl"]) for r in rows]),
                sum(1 for r in rows for t in r["hl"] if t < 360)))
        P("\n### Paired sign tests (ff better / off better / tie; two-sided p)\n")
        tests = [("result (W > w > = > l > L)", lambda r: SCORE[r["lead"]])]
        for m in (3, 5, 8, 12):
            tests.append(("income ratio %d:00" % m, lambda r, m=m: (val(r, r["si"], m, "income") / val(r, r["oi"], m, "income"))
                          if val(r, r["si"], m, "income") and val(r, r["oi"], m, "income") else None))
        for m in (5, 8):
            tests.append(("army ratio %d:00" % m, lambda r, m=m: (val(r, r["si"], m, "army") / max(1, val(r, r["oi"], m, "army")))
                          if val(r, r["si"], m, "army") is not None and val(r, r["oi"], m, "army") is not None else None))
        P("| measure | ff better | off better | tie | p |")
        P("|---|---|---|---|---|")
        for nm, fn in tests:
            b = o = t = 0
            for tg in tags:
                x, y = fn(arms["ff"][tg]), fn(arms["off"][tg])
                if x is None or y is None:
                    continue
                if abs(x - y) < 1e-9:
                    t += 1
                elif x > y:
                    b += 1
                else:
                    o += 1
            P("| %s | %d | %d | %d | %.3f |" % (nm, b, o, t, binom_p(b, b + o)))
        P("\n### Per game (Crown's result, its income ratio at 5:00 and 8:00, early loss *)\n")
        P("| game | Crown slot | ff | off | ff inc 5 / 8 | off inc 5 / 8 | ff pick | off pick |")
        P("|---|---|---|---|---|---|---|---|")
        for tg in tags:
            x, y = arms["ff"][tg], arms["off"][tg]
            c = lambda r: "%s%s%s" % (r["lead"], (" " + mmss(r["end"])) if r["res"] != "D" else "", " *" if r["early"] else "")
            ir = lambda r, m: f2(val(r, r["si"], m, "income") / val(r, r["oi"], m, "income")) if val(r, r["si"], m, "income") and val(r, r["oi"], m, "income") else "-"
            P("| %s | P%d | %s | %s | %s / %s | %s / %s | %s | %s |" % (tg[5:], x["si"] + 1, c(x), c(y), ir(x, 5), ir(x, 8),
                                                                  ir(y, 5), ir(y, 8), x["pick"], y["pick"]))
        P("")


if __name__ == "__main__":
    main()
