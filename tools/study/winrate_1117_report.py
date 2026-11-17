#!/usr/bin/env python3
"""WIN-RATE STUDY 2026-11-17 report (docs/winrate_2026_11_17.md): tables from tools/qa_match.gd's result.json files for all
six pairings, against the earlier studies CUT AT THE SAME TIME (12:00; the Crown mirror also at 15:00), with paired tests on
the same tag (map, seed and sides). A measuring tool only.
    python3 tools/study/winrate_1117_report.py DATA [--csv games.csv] > tables.md
    python3 tools/study/winrate_1117_report.py DATA --long LONGDATA          (adds the Crown mirror to 20:00)
The subject of a pairing is its first-named faction in the tag (crbr: the Crown; brcw: the Brood; mirrors: P1 = spot A).
A draw's LEADER: income earned + 2 x army value 10% ahead (the old studies' rule). A game cut at T: decided only if it ended
by T, else a draw led by its row at minute T. Old data: 2026-11-15 (crbr, crcw, brbr, brcw; ran to 15:00) and 2026-11-12
(crcr, cwcw; ran to 15:00), both re-cut. Paired tests: on the tags in both studies, the score W/w = +1, = 0, l/L = -1 of the
subject; a sign test of now v then (ties dropped), and a paired t on log(income ratio at 8:00)."""
import os, sys, json, glob, math, statistics as st
from collections import Counter, defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CODE = {"cr": "crown", "br": "brood", "cw": "clockwork"}
PAIRS = ["crbr", "crcw", "brcw", "crcr", "brbr", "cwcw"]
NAME = {"crbr": "Crown v Brood", "crcw": "Crown v Clockwork", "brcw": "Brood v Clockwork", "crcr": "Crown v Crown (P1)",
        "brbr": "Brood v Brood (P1)", "cwcw": "Clockwork v Clockwork (P1)"}
OLD = {"crbr": ("2026-11-15", "docs/winrate_2026_11_15/data"), "crcw": ("2026-11-15", "docs/winrate_2026_11_15/data"),
       "brbr": ("2026-11-15", "docs/winrate_2026_11_15/data"), "brcw": ("2026-11-15", "docs/winrate_2026_11_15/data"),
       "crcr": ("2026-11-12", "docs/winrate_2026_11_12/winrate-b/data"),
       "cwcw": ("2026-11-12", "docs/winrate_2026_11_12/winrate-c/data")}
BENCH = {"crown": {5: 4180, 8: 9500, 10: 13180}, "clockwork": {5: 4354, 8: 9796, 10: 13865},
         "brood": {5: 4344, 8: 9237, 10: 14074}}
CLASSIC = {"greenhold", "highmoor", "dune_sea", "frostfang", "twin_fords", "ashfall", "mirewood", "border_march", "red_coast"}


def mmss(s):
    return "-" if s is None else "%d:%02d" % (int(s) // 60, int(s) % 60)


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


def binom_p(k, n):
    """two-sided exact binomial p for k of n at 1/2"""
    if n == 0:
        return 1.0
    pk = [math.comb(n, i) / 2 ** n for i in range(n + 1)]
    return min(1.0, sum(p for p in pk if p <= pk[k] + 1e-12))


def fp(p):
    return "%.3f" % p if p >= 0.001 else "<0.001"


def plan_of(s):
    s = s.split("->")[1] if "->" in s else s
    return s.split("(")[0].strip()


def load(data, pair, cut=None):
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
        end = g["end"]
        winner = g["winner"]
        fin = g["final"]
        if cut is not None and end > cut:
            # re-cut: the state at minute cut/60
            m = cut // 60
            if (0, m) not in at or (1, m) not in at:
                continue
            fin = [at[(0, m)], at[(1, m)]]
            end, winner = cut, -1
        elif cut is not None and winner < 0 and end < cut:
            continue   # an old game that stopped early with no winner (none expected)
        sc = [f["income"] + 2 * f["army"] for f in fin]
        if winner >= 0:
            res = "W" if winner == si else "L"
            lead = res
        else:
            res = "D"
            lead = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")
        halls = [0, 0]
        first_hall = [None, None]
        for e in g["events"]:
            if e.get("ev") == "hall_lost" and e.get("built") and e["t"] <= end:
                halls[e["p"]] += 1
                if first_hall[e["p"]] is None:
                    first_hall[e["p"]] = e["t"]
        first_att = [None, None]
        for e in g["events"]:
            if e.get("ev") == "first_attack" and e["t"] <= end:
                first_att[e["p"]] = e["t"]
        picks = {0: [], 1: []}
        first_read = {0: None, 1: None}
        for r in sorted(g.get("reads", []), key=lambda r: r["t"]):
            if r["t"] > end:
                continue
            if "pick" in r:
                picks[r["p"]].append((r["t"], r["pick"]))
            elif first_read[r["p"]] is None:
                first_read[r["p"]] = r["read"]
        tech = {0: {}, 1: {}}
        for k, t in (g.get("tech_at") or {}).items():
            tm, name = k.split(":", 1)
            if t <= end:
                tech[int(tm)][name] = t
        out.append({"tag": tag, "map": g["map"], "seed": g["seed"], "r": tag[-1], "si": si, "oi": oi, "res": res,
                    "lead": lead, "end": end, "slot": "P%d" % (si + 1), "at": at, "halls": halls, "picks": picks,
                    "read": first_read, "tech": tech, "facs": facs, "final": fin, "version": g.get("version", ""),
                    "first_hall": first_hall, "first_att": first_att,
                    "final_plan": [g["final"][0].get("plan", ""), g["final"][1].get("plan", "")]})
    return out


def score(r):
    return 1 if r["lead"] in ("W", "w") else (-1 if r["lead"] in ("L", "l") else 0)


def wl(rows):
    return (sum(r["res"] == "W" for r in rows), sum(r["res"] == "D" for r in rows), sum(r["res"] == "L" for r in rows))


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
    pr = [(x, y) for x, y in zip(a, b) if x is not None and y is not None]
    return (sum(x for x, _ in pr) / sum(y for _, y in pr)) if pr and sum(y for _, y in pr) else None


def game_ratio(r, m, k):
    a, b = val(r, r["si"], m, k), val(r, r["oi"], m, k)
    return a / b if a and b else None


def spot(rows):
    """won or led by spot A (slot P1) v spot B, even draws dropped"""
    g = [r for r in rows if r["lead"] != "="]
    a = sum((score(r) > 0) == (r["si"] == 0) for r in g)
    return a, len(g) - a


def paired(rows, old):
    ob = {r["tag"]: r for r in old}
    pr = [(r, ob[r["tag"]]) for r in rows if r["tag"] in ob]
    up = sum(score(a) > score(b) for a, b in pr)
    down = sum(score(a) < score(b) for a, b in pr)
    d = []
    for a, b in pr:
        x, y = game_ratio(a, 8, "income"), game_ratio(b, 8, "income")
        if x and y:
            d.append(math.log(x) - math.log(y))
    t = None
    if len(d) > 2 and st.stdev(d) > 0:
        t = mean(d) / (st.stdev(d) / math.sqrt(len(d)))
    inc_up = sum(x > 0 for x in d)
    nz = sum(x != 0 for x in d)
    return {"n": len(pr), "up": up, "down": down, "p": binom_p(min(up, down), up + down) if up + down else 1.0,
            "dinc": math.exp(mean(d)) if d else None, "t": t, "inc_up": inc_up, "inc_n": len(d),
            "inc_p": binom_p(min(inc_up, nz - inc_up), nz) if nz else 1.0}


def summary(rows):
    w, d, l = wl(rows)
    a, b, e = woled(rows)
    dec = [r["end"] for r in rows if r["res"] != "D"]
    return {"n": len(rows), "wdl": "%d-%d-%d" % (w, d, l), "wol": "%d / %d / %d" % (a, b, e),
            "dec": "%d (%s)" % (len(dec), mmss(mean(dec)) if dec else "-")}


def picks_table(P, rows, side, fac):
    P("| %s opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |" % fac)
    P("|---|---|---|---|---|")
    groups = defaultdict(list)
    for r in rows:
        pk = r["picks"][r[side]]
        groups[plan_of(pk[0][1]) if pk else "(none)"].append(r)
    for k, rr in sorted(groups.items(), key=lambda x: -len(x[1])):
        sw = Counter(plan_of(p[1]) for r in rr for p in r["picks"][r[side]][1:])
        w, d, l = wl(rr)
        a, b, _ = woled(rr)
        if side == "oi":
            w, l, a = l, w, b
        P("| %s | %d | %d-%d-%d | %d | %s |" % (k, len(rr), w, d, l, a, "; ".join("%s x%d" % x for x in sw.most_common(4))))
    P("")


def section(P, pair, rows, old, oldname, cutname):
    sf, of = CODE[pair[:2]], CODE[pair[2:]]
    mirror = sf == of
    lab = lambda side, fac: fac + ((" (P1)" if side == "si" else " (P2)") if mirror else "")
    P("## %s%s\n" % (NAME[pair], cutname))
    s, o = summary(rows), summary(old)
    P("W-D-L **%s**, won or led first / second / even **%s**, decided %s; %s cut at the same time: %s, %s, %s.\n" % (
        s["wdl"], s["wol"], s["dec"], oldname, o["wdl"], o["wol"], o["dec"]))
    pa = paired(rows, old)
    P("Paired on the same %d tags: the first side's result better in %d, worse in %d (sign test p %s); its income ratio at 8:00 "
      "x%s of the old (geometric mean; up in %d of %d, p %s; paired t %s).\n" % (
          pa["n"], pa["up"], pa["down"], fp(pa["p"]), f2(pa["dinc"]), pa["inc_up"], pa["inc_n"], fp(pa["inc_p"]),
          "%.1f" % pa["t"] if pa["t"] is not None else "-"))
    a, b = spot(rows)
    oa, ob = spot(old)
    P("Spot A (P1) v spot B, won or led (even draws dropped): now %d v %d (p %s); %s %d v %d (p %s).\n" % (
        a, b, fp(binom_p(min(a, b), a + b)), oldname, oa, ob, fp(binom_p(min(oa, ob), oa + ob))))
    for nm, rr in (("now", rows), (oldname, old)):
        parts = []
        for grp, sel in (("classic maps", lambda r: r["map"] in CLASSIC), ("named maps", lambda r: r["map"] not in CLASSIC)):
            x, y = spot([r for r in rr if sel(r)])
            parts.append("%s A %d v B %d" % (grp, x, y))
        P("- %s: %s" % (nm, "; ".join(parts)))
    P("")
    P("| first / second | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |")
    P("|---|---|---|---|---|---|---|---|---|")
    for nm, rr in (("now", rows), (oldname, old)):
        P("| %s | %s | %s | %s | %s | %s | %s | %s | %s |" % ((nm,) + tuple(f2(ratio(rr, m, "income")) for m in (5, 8, 10, 12))
                                                          + tuple(f2(ratio(rr, m, "army")) for m in (5, 8, 10, 12))))
    P("\n(sums over the games still running at that minute)\n")
    P("| side | /min 5:00 | 8:00 | 10:00 | 12:00 | earned/bench 5:00 | 8:00 | 10:00 | workers 8:00 | halls 8:00 | 12:00 | %s earned/bench 8:00 |" % oldname)
    P("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for side, fac in (("si", sf), ("oi", of)):
        pm = [med([per_min(r, r[side], m) for r in rows]) for m in (5, 8, 10, 12)]
        bb = [mean([val(r, r[side], m, "income") for r in rows]) for m in (5, 8, 10)]
        ob8 = mean([val(r, r[side], 8, "income") for r in old])
        P("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (
            lab(side, fac), *[f0(x) for x in pm], *[f2(b / BENCH[fac][m]) if b else "" for b, m in zip(bb, (5, 8, 10))],
            f0(med([val(r, r[side], 8, "workers") for r in rows])), f0(med([val(r, r[side], 8, "halls") for r in rows])),
            f0(med([val(r, r[side], 12, "halls") for r in rows])), f2(ob8 / BENCH[fac][8]) if ob8 else ""))
    P("")
    hl = lambda rr, side: mean([r["halls"][r[side]] for r in rr])
    P("Built halls lost per game: first %s, second %s (%s: %s, %s). First hall lost (median, games): first %s (%d), second %s (%d). "
      "First attack (median): first %s (%d), second %s (%d). Decided games' length: mean %s, median %s.\n" % (
          f2(hl(rows, "si")), f2(hl(rows, "oi")), oldname, f2(hl(old, "si")), f2(hl(old, "oi")),
          mmss(med([r["first_hall"][r["si"]] for r in rows])), sum(r["first_hall"][r["si"]] is not None for r in rows),
          mmss(med([r["first_hall"][r["oi"]] for r in rows])), sum(r["first_hall"][r["oi"]] is not None for r in rows),
          mmss(med([r["first_att"][r["si"]] for r in rows])), sum(r["first_att"][r["si"]] is not None for r in rows),
          mmss(med([r["first_att"][r["oi"]] for r in rows])), sum(r["first_att"][r["oi"]] is not None for r in rows),
          mmss(mean([r["end"] for r in rows if r["res"] != "D"])), mmss(med([r["end"] for r in rows if r["res"] != "D"]))))
    P("### OPTIMAL's picks\n")
    picks_table(P, rows, "si", lab("si", sf))
    picks_table(P, rows, "oi", lab("oi", of))
    for side, fac in (("si", sf), ("oi", of)):
        P("- %s: first read %s; plan at the end %s; %s opening picks %s." % (
            lab(side, fac), ", ".join("%s %d" % x for x in Counter(r["read"][r[side]] for r in rows).most_common()),
            ", ".join("%s %d" % x for x in Counter(r["final_plan"][r[side]] for r in rows).most_common()), oldname,
            ", ".join("%s %d" % x for x in Counter(plan_of(r["picks"][r[side]][0][1]) if r["picks"][r[side]] else "(none)" for r in old).most_common())))
    P("")
    P("### Research (games, median time)\n")
    for side, fac in (("si", sf), ("oi", of)):
        c = defaultdict(list)
        for r in rows:
            for k, t in r["tech"][r[side]].items():
                c[k].append(t)
        P("- **%s**: %s" % (lab(side, fac), "; ".join("%s %d (%s)" % (k, len(v), mmss(st.median(v)))
                                                      for k, v in sorted(c.items(), key=lambda x: st.median(x[1])))))
    P("")
    P("### Per map (first side: r0 / r1 with its slot; W L win/loss, w l led/trailed a draw, = even)\n")
    P("| map | now r0 | now r1 | %s r0 | r1 | first side's pick r0 / r1 | second's r0 / r1 |" % oldname)
    P("|---|---|---|---|---|---|---|")
    bym = defaultdict(dict)
    for r in rows:
        bym[r["map"]]["n" + r["r"]] = r
    for r in old:
        bym[r["map"]]["o" + r["r"]] = r
    cell = lambda r: "" if r is None else "%s %s%s" % (r["lead"], r["slot"], (" " + mmss(r["end"])) if r["res"] != "D" else "")
    pk = lambda r, side: "" if r is None or not r["picks"][r[side]] else plan_of(r["picks"][r[side]][0][1])
    for m in sorted(bym):
        x = bym[m]
        P("| %s | %s | %s | %s | %s | %s / %s | %s / %s |" % (m, cell(x.get("n0")), cell(x.get("n1")), cell(x.get("o0")),
                                                       cell(x.get("o1")), pk(x.get("n0"), "si"), pk(x.get("n1"), "si"),
                                                       pk(x.get("n0"), "oi"), pk(x.get("n1"), "oi")))
    P("")


def main():
    data = sys.argv[1]
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    csvf = arg("--csv", "")
    longd = arg("--long", "")
    P = print
    P("# Tables (tools/study/winrate_1117_report.py)\n")
    P("All six pairings now (0.38.46, to 12:00; the Crown mirror to 15:00) against the earlier study cut at 12:00.\n")
    P("| pairing (first side's view) | games | W-D-L | won or led first / second / even | decided (mean length) | spot A v B (p) | earlier study | its W-D-L at 12:00 | won or led | paired better / worse (p) |")
    P("|---|---|---|---|---|---|---|---|---|---|")
    secs = []
    allrows = {}
    for pair in PAIRS:
        rows = load(data, pair, 720)
        if not rows:
            continue
        oldname, od = OLD[pair]
        old = load(os.path.join(ROOT, od), pair, 720)
        allrows[pair] = rows
        s, o = summary(rows), summary(old)
        a, b = spot(rows)
        pa = paired(rows, old)
        P("| %s | %d | **%s** | %s | %s | %d v %d (%s) | %s | %s | %s | %d / %d (%s) |" % (
            NAME[pair], s["n"], s["wdl"], s["wol"], s["dec"], a, b, fp(binom_p(min(a, b), a + b)), oldname, o["wdl"],
            o["wol"], pa["up"], pa["down"], fp(pa["p"])))
        secs.append((pair, rows, old, oldname, ""))
        if pair == "crcr":
            r15 = load(data, pair, 900)
            o15 = load(os.path.join(ROOT, od), pair, 900)
            if r15 and r15[0]["end"] is not None:
                secs.append((pair, r15, o15, oldname, " to 15:00"))
                s, o = summary(r15), summary(o15)
                a, b = spot(r15)
                pa = paired(r15, o15)
                P("| %s to 15:00 | %d | **%s** | %s | %s | %d v %d (%s) | %s | %s | %s | %d / %d (%s) |" % (
                    NAME[pair], s["n"], s["wdl"], s["wol"], s["dec"], a, b, fp(binom_p(min(a, b), a + b)), oldname,
                    o["wdl"], o["wol"], pa["up"], pa["down"], fp(pa["p"])))
    if longd:
        r20 = load(longd, "crcr", 1200)
        if r20:
            s = summary(r20)
            a, b = spot(r20)
            P("| Crown v Crown (P1) to 20:00, round 0 | %d | **%s** | %s | %s | %d v %d (%s) | | | | |" % (
                s["n"], s["wdl"], s["wol"], s["dec"], a, b, fp(binom_p(min(a, b), a + b))))
            r20at15 = [r for r in load(data, "crcr", 900) if r["r"] == "0"]
            s2 = summary(r20at15)
            P("\n(The same 19 round-0 Crown mirror games of the main run at 15:00: %s, won or led %s.)" % (s2["wdl"], s2["wol"]))
    P("")
    for sec in secs:
        section(P, *sec)
    if longd:
        r20 = load(longd, "crcr", 1200)
        if r20:
            P("## Crown v Crown to 20:00 (round 0, 19 games)\n")
            for m in (12, 15, 18, 20):
                P("- at %d:00: income P1/P2 %s, army %s, games still running %d" % (
                    m, f2(ratio(r20, m, "income")), f2(ratio(r20, m, "army")),
                    sum(val(r, 0, m, "income") is not None for r in r20)))
            P("\n| map | result | length | halls lost P1 / P2 | P1 pick / P2 pick |")
            P("|---|---|---|---|---|")
            for r in r20:
                P("| %s | %s | %s | %d / %d | %s / %s |" % (r["map"], r["lead"], mmss(r["end"]), r["halls"][0], r["halls"][1],
                                                      plan_of(r["picks"][0][0][1]) if r["picks"][0] else "",
                                                      plan_of(r["picks"][1][0][1]) if r["picks"][1] else ""))
            P("")
    if csvf:
        with open(csvf, "w") as f:
            f.write("tag,map,seed,pair,version,subj_slot,res,lead,end,pick_s,pick_o,plan_end_s,plan_end_o,halls_lost_s,halls_lost_o,"
                    + ",".join("%s%d_%s" % (k, m, s) for m in (5, 8, 10, 12) for k in ("inc", "army") for s in ("s", "o")) + "\n")
            for pair, rows in allrows.items():
                for r in rows:
                    pk = lambda side: plan_of(r["picks"][r[side]][0][1]) if r["picks"][r[side]] else ""
                    v = [r["tag"], r["map"], r["seed"], pair, r["version"], r["slot"], r["res"], r["lead"], r["end"], pk("si"),
                         pk("oi"), r["final_plan"][r["si"]], r["final_plan"][r["oi"]], r["halls"][r["si"]], r["halls"][r["oi"]]]
                    for m in (5, 8, 10, 12):
                        for k in ("income", "army"):
                            for s in ("si", "oi"):
                                x = val(r, r[s], m, k)
                                v.append("" if x is None else x)
                    f.write(",".join(str(x) for x in v) + "\n")


if __name__ == "__main__":
    main()
