#!/usr/bin/env python3
"""WIN-RATE STUDY 2026-11-15 report (docs/winrate_2026_11_15.md): tables from tools/qa_match.gd's result.json files, now
against the 2026-11-12 study (docs/winrate_2026_11_12/winrate-{a,b,c}/data). A measuring tool only.
    python3 tools/study/winrate_1115_report.py DATA [OLD_ROOT] > tables.md
The subject of a pairing is its first-named faction (crbr: the Crown; brbr: P1). A draw's LEADER: income earned + 2 x army
value 10% ahead (the old studies' rule). Income per minute at minute m = earned in (m-1, m]. Bench: docs/economy_parity.md
(cumulative primary income of each faction alone with the ideal build, original economy)."""
import os, sys, json, glob, statistics as st
from collections import Counter, defaultdict

CODE = {"cr": "crown", "br": "brood", "cw": "clockwork"}
PAIRS = ["crbr", "crcw", "brbr", "brcw"]
NAME = {"crbr": "Crown v Brood", "crcw": "Crown v Clockwork", "brbr": "Brood v Brood (P1)", "brcw": "Brood v Clockwork"}
OLD_SUB = {"crbr": "winrate-a", "crcw": "winrate-a", "brbr": "winrate-c", "brcw": "winrate-b"}
BENCH = {"crown": {5: 4180, 8: 9500, 10: 13180, 15: 24460}, "clockwork": {5: 4354, 8: 9796, 10: 13865, 15: 25087},
         "brood": {5: 4344, 8: 9237, 10: 14074, 15: 25585}}


def mmss(s):
    return "%d:%02d" % (int(s) // 60, int(s) % 60)


def med(xs):
    xs = [x for x in xs if x is not None]
    return st.median(xs) if xs else None


def mean(xs):
    xs = [x for x in xs if x is not None]
    return sum(xs) / len(xs) if xs else None


def f2(x):
    return "" if x is None else "%.2f" % x


def f0(x):
    return "" if x is None else "{:,}".format(int(round(x)))


def load(data, pair):
    out = []
    for d in sorted(glob.glob(os.path.join(data, "base_*_%s_r*" % pair))):
        f = os.path.join(d, "result.json")
        if not os.path.exists(f):
            continue
        g = json.load(open(f))
        tag = os.path.basename(d)
        facs = [s[0] for s in g["slots"]]
        subj = CODE[pair[:2]]
        si = 0 if pair[:2] == pair[2:] else facs.index(subj)
        oi = 1 - si
        at = {}
        for r in g["minutes"]:
            at[(r["p"], int(round(r["t"] / 60)))] = r
        sc = [f["income"] + 2 * f["army"] for f in g["final"]]
        if g["winner"] >= 0:
            res = "W" if g["winner"] == si else "L"
            lead = res
        else:
            res = "D"
            lead = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")
        halls = [0, 0]
        for e in g["events"]:
            if e.get("ev") == "hall_lost" and e.get("built"):
                halls[e["p"]] += 1
        picks = {0: [], 1: []}
        first_read = {0: None, 1: None}
        for r in g.get("reads", []):
            if "pick" in r:
                picks[r["p"]].append((r["t"], r["pick"]))
            elif first_read[r["p"]] is None:
                first_read[r["p"]] = r["read"]
        tech = {0: {}, 1: {}}
        for k, t in (g.get("tech_at") or {}).items():
            tm, name = k.split(":", 1)
            tech[int(tm)][name] = t
        out.append({"tag": tag, "map": g["map"], "seed": g["seed"], "r": tag[-1], "si": si, "oi": oi, "res": res,
                    "lead": lead, "end": g["end"], "slot": "P%d" % (si + 1), "at": at, "halls": halls, "picks": picks,
                    "read": first_read, "tech": tech, "facs": facs, "final": g["final"], "version": g.get("version", "")})
    return out


def wl(rows):
    w = sum(r["res"] == "W" for r in rows)
    d = sum(r["res"] == "D" for r in rows)
    l = sum(r["res"] == "L" for r in rows)
    return w, d, l


def woled(rows):
    a = sum(r["lead"] in ("W", "w") for r in rows)
    b = sum(r["lead"] in ("L", "l") for r in rows)
    return a, b, len(rows) - a - b


def val(r, p, m, k):
    x = r["at"].get((p, m))
    return x[k] if x else None


def per_min(r, p, m):
    a, b = val(r, p, m, "income"), val(r, p, m - 1, "income")
    return None if a is None or b is None else a - b


def ratio(rows, m, k):
    a = [val(r, r["si"], m, k) for r in rows]
    b = [val(r, r["oi"], m, k) for r in rows]
    a2 = [x for x, y in zip(a, b) if x is not None and y is not None]
    b2 = [y for x, y in zip(a, b) if x is not None and y is not None]
    return (sum(a2) / sum(b2)) if b2 and sum(b2) else None


def summary(rows):
    w, d, l = wl(rows)
    a, b, e = woled(rows)
    dec = [r["end"] for r in rows if r["res"] != "D"]
    pa = sum((r["lead"] in ("W", "w")) == (r["si"] == 0) and r["lead"] not in ("=",) for r in rows)
    pb = sum(r["lead"] not in ("=",) for r in rows) - pa
    return {"n": len(rows), "wdl": "%d-%d-%d" % (w, d, l), "wol": "%d / %d / %d" % (a, b, e),
            "dec": "%d (%s)" % (len(dec), mmss(mean(dec)) if dec else "-"), "spot": "%d v %d" % (pa, pb)}


def main():
    data = sys.argv[1]
    old_root = sys.argv[2] if len(sys.argv) > 2 else "docs/winrate_2026_11_12"
    P = print
    P("# Tables (tools/study/winrate_1115_report.py)\n")
    P("## All pairings, now v 2026-11-12\n")
    P("| pairing (first side's view) | games | W-D-L | won or led: first / second / even | decided (mean length) | spot A v B (won or led) | 2026-11-12 W-D-L | 11-12 won or led | 11-12 decided |")
    P("|---|---|---|---|---|---|---|---|---|")
    allrows = {}
    oldrows = {}
    for pair in PAIRS:
        rows = load(data, pair)
        if not rows:
            continue
        old = load(os.path.join(old_root, OLD_SUB[pair], "data"), pair)
        allrows[pair], oldrows[pair] = rows, old
        s, o = summary(rows), summary(old)
        P("| %s | %d | **%s** | %s | %s | %s | %s | %s | %s |" % (NAME[pair], s["n"], s["wdl"], s["wol"], s["dec"], s["spot"],
                                                             o["wdl"], o["wol"], o["dec"]))
    P("")
    for pair, rows in allrows.items():
        old = oldrows[pair]
        sf = CODE[pair[:2]]
        of = CODE[pair[2:]]
        P("## %s\n" % NAME[pair])
        P("### Economy and army (first side over second; games still running at that minute)\n")
        P("| | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |")
        P("|---|---|---|---|---|---|---|---|---|")
        for nm, rr in (("now", rows), ("2026-11-12", old)):
            P("| %s | %s | %s | %s | %s | %s | %s | %s | %s |" % ((nm,) + tuple(f2(ratio(rr, m, "income")) for m in (5, 8, 10, 12))
                                                              + tuple(f2(ratio(rr, m, "army")) for m in (5, 8, 10, 12))))
        P("\nIncome PER MINUTE (median, earned in the minute before) and earned by then over the bench (mean of the games / "
          "bench, docs/economy_parity.md):\n")
        P("| side | n at 5 | /min 5:00 | 8:00 | 10:00 | 12:00 | earned 5:00 / bench | 8:00 | 10:00 | 2026-11-12 /min 8:00 | 11-12 earned 8:00 / bench |")
        P("|---|---|---|---|---|---|---|---|---|---|---|")
        for side, fac in (("si", sf), ("oi", of)):
            lab = fac + (" (P1)" if pair[:2] == pair[2:] and side == "si" else (" (P2)" if pair[:2] == pair[2:] else ""))
            pm = [med([per_min(r, r[side], m) for r in rows]) for m in (5, 8, 10, 12)]
            bb = [mean([val(r, r[side], m, "income") for r in rows]) for m in (5, 8, 10)]
            opm = med([per_min(r, r[side], 8) for r in old])
            ob = mean([val(r, r[side], 8, "income") for r in old])
            P("| %s | %d | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (
                lab, sum(val(r, r[side], 5, "income") is not None for r in rows), *[f0(x) for x in pm],
                *[f2(b / BENCH[fac][m]) if b else "" for b, m in zip(bb, (5, 8, 10))], f0(opm),
                f2(ob / BENCH[fac][8]) if ob else ""))
        classic = {"greenhold", "highmoor", "dune_sea", "frostfang", "twin_fords", "ashfall", "mirewood", "border_march", "red_coast"}
        for nm, rr in (("now", rows), ("2026-11-12", old)):
            parts = []
            for grp, sel in (("classic maps", lambda r: r["map"] in classic), ("named maps", lambda r: r["map"] not in classic)):
                g2 = [r for r in rr if sel(r) and r["lead"] != "="]
                a = sum((r["lead"] in ("W", "w")) == (r["si"] == 0) for r in g2)
                parts.append("%s A %d v B %d" % (grp, a, len(g2) - a))
            P("\nSpot A (P1) v B, won or led, %s: %s." % (nm, "; ".join(parts)))
        P("\nHalls lost (built) per game, mean: first %.2f, second %.2f (2026-11-12: %.2f, %.2f). Halls at 8:00 (median): %s v %s.\n" % (
            mean([r["halls"][r["si"]] for r in rows]), mean([r["halls"][r["oi"]] for r in rows]),
            mean([r["halls"][r["si"]] for r in old]), mean([r["halls"][r["oi"]] for r in old]),
            med([val(r, r["si"], 8, "halls") for r in rows]), med([val(r, r["oi"], 8, "halls") for r in rows])))
        # plans
        P("### OPTIMAL's picks (the first side) and how they did\n")
        P("| opening pick (read -> plan) | games | W-D-L | won or led | later switches |")
        P("|---|---|---|---|---|")
        groups = defaultdict(list)
        for r in rows:
            pk = r["picks"][r["si"]]
            key = pk[0][1].split("(")[0].strip() if pk else "(none)"
            groups[key].append(r)
        for k, rr in sorted(groups.items(), key=lambda x: -len(x[1])):
            sw = Counter(p[1].split("(")[0].strip() for r in rr for p in r["picks"][r["si"]][1:])
            P("| %s | %d | %s | %d | %s |" % (k, len(rr), "%d-%d-%d" % wl(rr), woled(rr)[0],
                                         "; ".join("%s x%d" % x for x in sw.most_common(4))))
        P("\nThe second side's opening picks: %s.\n" % "; ".join("%s x%d" % x for x in Counter(
            (r["picks"][r["oi"]][0][1].split("(")[0].strip() if r["picks"][r["oi"]] else "(none)") for r in rows).most_common()))
        P("First scout read of the first side: %s; of the second: %s.\n" % (
            ", ".join("%s %d" % x for x in Counter(r["read"][r["si"]] for r in rows).most_common()),
            ", ".join("%s %d" % x for x in Counter(r["read"][r["oi"]] for r in rows).most_common())))
        P("Plan at the end, first side: %s.\n" % ", ".join("%s %d" % x for x in Counter(r["final"][r["si"]].get("plan", "") for r in rows).most_common()))
        # research
        P("### Research: games where done, median time\n")
        for side, fac in (("si", sf), ("oi", of)):
            c = defaultdict(list)
            for r in rows:
                for k, t in r["tech"][r[side]].items():
                    c[k].append(t)
            P("- **%s%s**: %s" % (fac, " (P1)" if pair[:2] == pair[2:] and side == "si" else (" (P2)" if pair[:2] == pair[2:] else ""),
                                 "; ".join("%s %d (%s)" % (k, len(v), mmss(st.median(v))) for k, v in sorted(c.items(), key=lambda x: st.median(x[1])))))
        P("")
        # per map
        P("### Per map (first side's result: r0 / r1, its slot; W L win/loss, w l = led/trailed a draw, = even draw)\n")
        P("| map | now r0 | now r1 | 2026-11-12 r0 | r1 | first side's pick r0 / r1 |")
        P("|---|---|---|---|---|---|")
        bym = defaultdict(dict)
        for r in rows:
            bym[r["map"]]["n" + r["r"]] = r
        for r in old:
            bym[r["map"]]["o" + r["r"]] = r
        cell = lambda r: "" if r is None else "%s %s%s" % (r["lead"], r["slot"], (" " + mmss(r["end"])) if r["res"] != "D" else "")
        for m in sorted(bym):
            x = bym[m]
            pk = lambda r: "" if r is None or not r["picks"][r["si"]] else r["picks"][r["si"]][0][1].split("->")[1].split("(")[0].strip()
            P("| %s | %s | %s | %s | %s | %s / %s |" % (m, cell(x.get("n0")), cell(x.get("n1")), cell(x.get("o0")), cell(x.get("o1")),
                                                    pk(x.get("n0")), pk(x.get("n1"))))
        P("")


if __name__ == "__main__":
    main()
