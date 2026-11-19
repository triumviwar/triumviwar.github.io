#!/usr/bin/env python3
"""PLAN MATRIX report (tools/study/plan_matrix.py; docs/plan_matrix_<faction>.md): tables from tools/qa_match.gd's
result.json files. A measuring tool only.
    python3 tools/study/plan_matrix_report.py FACTION DATA [--csv games.csv] [--maps N] > tables.md
(--maps N: only the first N maps of plan_matrix.MAPS, so a run cut inside a map leaves every cell the same games.)
The SUBJECT is the faction's forced plan (slot P1 in round 0, P2 in round 1; in the mirror the opponent is OPTIMAL).
Result at the bell (20:00 or the game's end): W / L when decided, else a draw LED by the side with income earned + 2 x army
value 10% ahead (w / l), or even (=), the win-rate studies' rule. "Won or led" = W + w.
"v OPTIMAL": each plan's games are paired with OPTIMAL's on the same tag (map, seed, sides, opponent): score W/w = +1,
= 0, l/L = -1; better / worse = games where the plan scored higher / lower than OPTIMAL did; p = two-sided sign test."""
import os, sys, json, glob, math, statistics as st
from collections import Counter, defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plan_matrix as pm

CODE = {"cr": "crown", "br": "brood", "cw": "clockwork"}
NAMES = {"optimal": "OPTIMAL", "balanced": "Balanced", "rush": "Rush", "economy": "Economy", "timing": "Timing attack",
         "pendulum": "Pendulums", "heavy": "Heavy Works push", "springer": "Springer timing", "cs_rush": "Clock Soldier rush",
         "owls": "Owl raids", "dragoon": "Dragoon raids", "siege": "Siege push", "balloon": "Balloon harass",
         "air": "Air rush", "xrush": "Extreme rush", "spitter": "Spitter timing", "brute": "Brute siege"}
MINS = [5, 8, 12, 16, 20]


def mmss(s):
    return "-" if s is None else "%d:%02d" % (int(s) // 60, int(s) % 60)


def med(xs):
    xs = [x for x in xs if x is not None]
    return st.median(xs) if xs else None


def f2(x):
    return "-" if x is None else "%.2f" % x


def f0(x):
    return "-" if x is None else "{:,}".format(int(round(x)))


def binom_p(k, n):
    if n == 0:
        return 1.0
    pk = [math.comb(n, i) / 2 ** n for i in range(n + 1)]
    return min(1.0, sum(p for p in pk if p <= pk[k] + 1e-12))


def fp(p):
    return "%.3f" % p if p >= 0.001 else "<0.001"


def plan_of(s):
    s = s.split("->")[1] if "->" in s else s
    return s.split("(")[0].strip()


def load(fac, data, maps=None):
    rows = []
    for d in sorted(glob.glob(os.path.join(data, "pm_*"))):
        f = os.path.join(d, "result.json")
        if not os.path.exists(f):
            continue
        g = json.load(open(f))
        tag = os.path.basename(d)
        head, rest = tag[3:].split("_v_")
        plan = head.split("-", 1)[1]
        opp = CODE[rest[:2]]
        mp = rest[3:-3]
        rnd = int(tag[-1])
        if maps is not None and mp not in maps:
            continue
        si, oi = (0, 1) if rnd == 0 else (1, 0)
        at = {}
        for r in g["minutes"]:
            at[(r["p"], int(round(r["t"] / 60)))] = r
        fin = g["final"]
        sc = [x["income"] + 2 * x["army"] for x in fin]
        if g["winner"] >= 0:
            res = lead = "W" if g["winner"] == si else "L"
        else:
            res = "D"
            lead = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")
        halls_lost = [0, 0]
        first_att = [None, None]
        for e in g["events"]:
            if e.get("ev") == "hall_lost" and e.get("built"):
                halls_lost[e["p"]] += 1
            if e.get("ev") == "first_attack" and first_att[e["p"]] is None:
                first_att[e["p"]] = e["t"]
        picks = {0: [], 1: []}
        for r in sorted(g.get("reads", []), key=lambda r: r["t"]):
            if "pick" in r:
                picks[r["p"]].append(plan_of(r["pick"]))
        rows.append({"tag": tag, "plan": plan, "opp": opp, "map": mp, "r": rnd, "si": si, "oi": oi, "res": res,
                     "lead": lead, "end": g["end"], "at": at, "fin": fin, "sc": sc, "halls_lost": halls_lost,
                     "first_att": first_att, "picks": picks,
                     "final_plan": [fin[0].get("plan", ""), fin[1].get("plan", "")],
                     "key": (opp, mp, rnd)})
    return rows


def score(r):
    return 1 if r["lead"] in ("W", "w") else (-1 if r["lead"] in ("L", "l") else 0)


def val(r, side, m, k):
    x = r["at"].get((r[side], m))
    if x is None:
        return None
    return x.get(k)


def ratio(r, m, k):
    a, b = val(r, "si", m, k), val(r, "oi", m, k)
    if a is None or b is None or not b:
        return None
    return a / b


def main():
    fac, data = sys.argv[1], sys.argv[2]
    nm = int(sys.argv[sys.argv.index("--maps") + 1]) if "--maps" in sys.argv else len(pm.MAPS)
    rows = load(fac, data, pm.MAPS[:nm])
    out = []
    P = out.append
    plans = [p for p in pm.PLANS[fac] if any(r["plan"] == p for r in rows)]
    opps = [o for o in pm.OPPS if any(r["opp"] == o for r in rows)]
    cell = defaultdict(list)
    for r in rows:
        cell[(r["plan"], r["opp"])].append(r)
    base = {(r["opp"], r["map"], r["r"]): r for r in rows if r["plan"] == "optimal"}

    P("# Plan matrix: %s (%d games)\n" % (fac, len(rows)))
    P("Read from the %s's side. W-D-L at the bell; won or led = W + a draw led by 10%% (income earned + 2 x army)."
      % fac)
    P("v OPTIMAL = paired with OPTIMAL's game on the same map, seed and spots (better / worse, sign test p).\n")

    # the main table
    P("## Won or led\n")
    P("| plan | " + " | ".join("v %s: won or led (W-D-L) | v OPTIMAL better/worse (p)" % o.capitalize() for o in opps) + " | all |")
    P("|---|" + "---|---|" * len(opps) + "---|")
    for p in plans:
        line = "| %s |" % NAMES.get(p, p)
        tot = [0, 0]
        for o in opps:
            rr = cell[(p, o)]
            wl = sum(r["lead"] in ("W", "w") for r in rr)
            tot[0] += wl
            tot[1] += len(rr)
            w, d, l = (sum(r["res"] == x for r in rr) for x in "WDL")
            if p == "optimal":
                cmp = ""
            else:
                b = wo = 0
                for r in rr:
                    q = base.get(r["key"])
                    if q is None:
                        continue
                    if score(r) > score(q):
                        b += 1
                    elif score(r) < score(q):
                        wo += 1
                cmp = "%d / %d (%s)" % (b, wo, fp(binom_p(b, b + wo)))
            line += " **%d of %d** (%d-%d-%d) | %s |" % (wl, len(rr), w, d, l, cmp)
        line += " %d of %d |" % tuple(tot)
        P(line)

    # the score ratio
    P("\n## Median score ratio at the bell (subject / opponent: income earned + 2 x army)\n")
    P("| plan | " + " | ".join("v " + o.capitalize() for o in opps) + " |")
    P("|---|" + "---|" * len(opps))
    for p in plans:
        cells = []
        for o in opps:
            rr = cell[(p, o)]
            xs = [r["sc"][r["si"]] / max(1, r["sc"][r["oi"]]) for r in rr if r["res"] == "D"]
            xs += [3.0 if r["res"] == "W" else 0.0 for r in rr if r["res"] != "D"]
            cells.append(f2(med(xs)))
        P("| %s | %s |" % (NAMES.get(p, p), " | ".join(cells)))
    P("\n(a decided game counts as 3.0 won, 0.0 lost)")

    # per opponent detail
    for o in opps:
        P("\n## v %s\n" % o.capitalize())
        P("| plan | earned 5 | 8 | 12 | 16 | 20 | ratio 8 | 12 | 20 | workers 8 | 12 | 20 | army 8 | 12 | 16 | 20 | army ratio 12 | 20 | halls 12 | 20 | halls lost (own / foe) | first attack | foe first attack |")
        P("|---|" + "---|" * 22)
        for p in plans:
            rr = cell[(p, o)]
            if not rr:
                continue
            e = [f0(med([val(r, "si", m, "income") for r in rr])) for m in MINS]
            ra = [f2(med([ratio(r, m, "income") for r in rr])) for m in (8, 12, 20)]
            wk = [f0(med([val(r, "si", m, "workers") for r in rr])) for m in (8, 12, 20)]
            ar = [f0(med([val(r, "si", m, "army") for r in rr])) for m in (8, 12, 16, 20)]
            arr = [f2(med([ratio(r, m, "army") for r in rr])) for m in (12, 20)]
            ha = [f2(med([val(r, "si", m, "halls") for r in rr])) for m in (12, 20)]
            hl = "%.2f / %.2f" % (sum(r["halls_lost"][r["si"]] for r in rr) / len(rr), sum(r["halls_lost"][r["oi"]] for r in rr) / len(rr))
            fa = mmss(med([r["first_att"][r["si"]] for r in rr]))
            fo = mmss(med([r["first_att"][r["oi"]] for r in rr]))
            P("| %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (NAMES.get(p, p), " | ".join(e), " | ".join(ra), " | ".join(wk),
                                                         " | ".join(ar), " | ".join(arr), " | ".join(ha), hl, fa + " | " + fo))
        # the opponent's OPTIMAL picks
        P("\n%s OPTIMAL's opening pick against each plan:\n" % o.capitalize())
        P("| plan | the %s's opening pick | its plan at the end |" % o)
        P("|---|---|---|")
        for p in plans:
            rr = cell[(p, o)]
            pk = Counter(r["picks"][r["oi"]][0] if r["picks"][r["oi"]] else "(none)" for r in rr)
            fp_ = Counter(r["final_plan"][r["oi"]] for r in rr)
            P("| %s | %s | %s |" % (NAMES.get(p, p), ", ".join("%s %d" % x for x in pk.most_common()),
                                    ", ".join("%s %d" % x for x in fp_.most_common())))
        # per map
        P("\n%s by map (won or led of 2 / the score of each round: W w = l L):\n" % o.capitalize())
        mps = [m for m in pm.MAPS if any(r["map"] == m for r in rows)]
        P("| plan | " + " | ".join(mps) + " |")
        P("|---|" + "---|" * len(mps))
        for p in plans:
            cs = []
            for m in mps:
                rr = sorted([r for r in cell[(p, o)] if r["map"] == m], key=lambda r: r["r"])
                cs.append("".join(r["lead"] for r in rr) or "-")
            P("| %s | %s |" % (NAMES.get(p, p), " | ".join(cs)))

    # the subject's own OPTIMAL picks
    P("\n## The %s OPTIMAL's own picks (the subject's OPTIMAL games)\n" % fac)
    P("| opponent | opening pick | later picks | plan at the end | its won or led by opening pick |")
    P("|---|---|---|---|---|")
    for o in opps:
        rr = cell[("optimal", o)]
        pk = Counter(r["picks"][r["si"]][0] if r["picks"][r["si"]] else "(none)" for r in rr)
        later = Counter(x for r in rr for x in r["picks"][r["si"]][1:])
        fpl = Counter(r["final_plan"][r["si"]] for r in rr)
        by = defaultdict(list)
        for r in rr:
            by[r["picks"][r["si"]][0] if r["picks"][r["si"]] else "(none)"].append(r)
        byt = ", ".join("%s %d of %d" % (k, sum(x["lead"] in ("W", "w") for x in v), len(v)) for k, v in by.items())
        P("| %s | %s | %s | %s | %s |" % (o, ", ".join("%s %d" % x for x in pk.most_common()),
                                          ", ".join("%s %d" % x for x in later.most_common()) or "-",
                                          ", ".join("%s %d" % x for x in fpl.most_common()), byt))

    print("\n".join(out))
    if "--csv" in sys.argv:
        fn = sys.argv[sys.argv.index("--csv") + 1]
        with open(fn, "w") as f:
            f.write("tag,plan,opp,map,round,res,lead,end,score_s,score_o," + ",".join(
                "earned%d_s,earned%d_o,workers%d_s,workers%d_o,army%d_s,army%d_o,halls%d_s" % ((m,) * 7) for m in MINS)
                    + ",halls_lost_s,halls_lost_o,first_attack_s,first_attack_o,opp_pick,opp_plan_end,subj_pick,subj_plan_end\n")
            for r in rows:
                v = [r["tag"], r["plan"], r["opp"], r["map"], r["r"], r["res"], r["lead"], r["end"], r["sc"][r["si"]], r["sc"][r["oi"]]]
                for m in MINS:
                    for k in ("income", "workers", "army"):
                        v += [val(r, "si", m, k), val(r, "oi", m, k)]
                    v.append(val(r, "si", m, "halls"))
                v += [r["halls_lost"][r["si"]], r["halls_lost"][r["oi"]], r["first_att"][r["si"]], r["first_att"][r["oi"]],
                      r["picks"][r["oi"]][0] if r["picks"][r["oi"]] else "", r["final_plan"][r["oi"]],
                      r["picks"][r["si"]][0] if r["picks"][r["si"]] else "", r["final_plan"][r["si"]]]
                f.write(",".join("" if x is None else str(x) for x in v) + "\n")


if __name__ == "__main__":
    main()
