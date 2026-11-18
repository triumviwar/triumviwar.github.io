#!/usr/bin/env python3
"""PLAN MATRIX REPORT (docs/plan_matrix_<faction>.md): the tables of tools/study/plan_matrix.py's games.
    python3 tools/study/plan_matrix_report.py FACTION DATA [--csv games.csv] > tables.md
"The subject" = the side whose plan was forced (in the mirror with both OPTIMAL: the side on spot A in round 0 and on
spot B in round 1, as plan_matrix.py lays the spots out). Each game is scored for the subject:
  W / L      won / lost (the game ended before the bell);
  w / l / =  a draw at the bell (20:00) led / trailed / even by income earned + 2 x army value, 10% the margin.
"Won or led" = W + w. Against OPTIMAL: each plan's games paired with OPTIMAL's on the same map, round and opponent (the
same seed and spots): better / worse (W > w > = > l > L), two-sided sign test. A measuring tool."""
import os, sys, glob, json, math, re, statistics as st
from collections import defaultdict, Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plan_matrix as pm
import qa_matches as qm

MINS = [5, 8, 12, 16, 20]
RANK = {"W": 2, "w": 1, "=": 0, "l": -1, "L": -2}
NAME = {"crown": "Crown", "clockwork": "Clockwork", "brood": "Brood"}
TAG = re.compile(r"pm_(\w\w)-(\w+)_v_(\w\w)_(\w+)_r(\d)$")
LONG = {v: k for k, v in qm.SHORT.items()}


def mmss(s):
    return "-" if s is None else "%d:%02d" % (int(s) // 60, int(s) % 60)


def med(xs):
    xs = [x for x in xs if x is not None]
    return st.median(xs) if xs else None


def mean(xs):
    xs = [x for x in xs if x is not None]
    return sum(xs) / len(xs) if xs else None


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


def load(fac, data):
    rows = []
    for d in sorted(glob.glob(os.path.join(data, "pm_*"))):
        mt = TAG.match(os.path.basename(d))
        f = os.path.join(d, "result.json")
        if not mt or not os.path.exists(f):
            continue
        _, plan, oc, m, r = mt.groups()
        r = int(r)
        g = json.load(open(f))
        slots = g["slots"]
        cand = [i for i, s in enumerate(slots) if s[0] == fac and s[1] == plan]
        if len(cand) == 1:
            si = cand[0]
        else:   # the mirror with both OPTIMAL: the subject's spot as plan_matrix.queue lays it
            swap = (r + qm.MAPS.index(m)) % 2 == 1
            si = 1 if swap else 0
        oi = 1 - si
        at = {}
        for x in g["minutes"]:
            at[(x["p"], int(round(x["t"] / 60)))] = x
        fin = g["final"]
        sc = [x["income"] + 2 * x["army"] for x in fin]
        if g["winner"] >= 0:
            res = "W" if g["winner"] == si else "L"
        else:
            res = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")
        hl = [0, 0]
        fa = [None, None]
        for e in g["events"]:
            if e.get("ev") == "hall_lost" and e.get("built"):
                hl[e["p"]] += 1
            if e.get("ev") == "first_attack" and fa[e["p"]] is None:
                fa[e["p"]] = e["t"]
        picks = {0: [], 1: []}
        read = {0: None, 1: None}
        for x in sorted(g.get("reads", []), key=lambda x: x["t"]):
            if "pick" in x:
                picks[x["p"]].append((x["t"], x["pick"]))
            elif read[x["p"]] is None:
                read[x["p"]] = x["read"]
        rows.append({"tag": os.path.basename(d), "plan": plan, "opp": LONG[oc], "map": m, "r": r, "si": si, "oi": oi,
                     "res": res, "end": g["end"], "at": at, "final": fin, "hl": hl, "fa": fa, "picks": picks,
                     "read": read, "spot": "A" if si == 0 else "B", "version": g.get("version", "")})
    return rows


def val(r, p, m, k):
    x = r["at"].get((p, m))
    return x[k] if x else None


def ratio(rows, m, k):
    pr = [(val(r, r["si"], m, k), val(r, r["oi"], m, k)) for r in rows]
    pr = [(a, b) for a, b in pr if a is not None and b is not None]
    s = sum(b for _, b in pr)
    return (sum(a for a, _ in pr) / s) if pr and s else None


def won_led(rows):
    return sum(r["res"] in ("W", "w") for r in rows)


def lost_trailed(rows):
    return sum(r["res"] in ("L", "l") for r in rows)


def wdl(rows):
    c = Counter(r["res"] for r in rows)
    return "%d-%d-%d" % (c["W"], c["w"] + c["="] + c["l"], c["L"])


def vs_opt(rows, base):
    ob = {(r["opp"], r["map"], r["r"]): r for r in base}
    up = down = 0
    for r in rows:
        b = ob.get((r["opp"], r["map"], r["r"]))
        if b is None:
            continue
        d = RANK[r["res"]] - RANK[b["res"]]
        up += d > 0
        down += d < 0
    return up, down, binom_p(min(up, down), up + down) if up + down else 1.0


def pick_of(r, side):
    pk = r["picks"][r[side]]
    return plan_of(pk[0][1]) if pk else "(none)"


def main():
    fac = sys.argv[1]
    data = sys.argv[2]
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    rows = load(fac, data)
    plans = pm.plans_of(fac)
    out = []
    P = out.append
    by = defaultdict(list)
    for r in rows:
        by[(r["plan"], r["opp"])].append(r)
    opps = [o for o in pm.FACS if any(r["opp"] == o for r in rows)]
    P("# Plan matrix, %s: tables (%d games, version %s)\n" % (NAME[fac], len(rows), ", ".join(sorted({r["version"] for r in rows}))))
    P("Each cell: won or led / games (W-D-L) and, against OPTIMAL's games on the same map, round and opponent, better / "
      "worse and the sign test's p.\n")
    P("| %s plan | %s |" % (NAME[fac], " | ".join("v %s OPTIMAL" % NAME[o] for o in opps)))
    P("|---|%s" % "---|" * len(opps))
    for p in plans:
        cells = []
        for o in opps:
            rr = by[(p, o)]
            if not rr:
                cells.append("")
                continue
            c = "**%d** / %d (%s)" % (won_led(rr), len(rr), wdl(rr))
            if p != "optimal":
                u, d, pv = vs_opt(rr, by[("optimal", o)])
                c += " · %d/%d p %s" % (u, d, fp(pv))
            cells.append(c)
        P("| %s | %s |" % (p, " | ".join(cells)))
    P("")
    for o in opps:
        P("## v %s OPTIMAL\n" % NAME[o])
        P("| plan | games | W-D-L | won or led | lost or trailed | income ratio 5/8/12/16/20 | army ratio 5/8/12/16/20 | "
          "workers 8:00 (own v opp) | halls 12:00 (own v opp) | halls lost (own / opp) | first attack (own / opp) | "
          "decided (mean length) |")
        P("|---|---|---|---|---|---|---|---|---|---|---|---|")
        for p in plans:
            rr = by[(p, o)]
            if not rr:
                continue
            inc = "/".join(f2(ratio(rr, m, "income")) for m in MINS)
            arm = "/".join(f2(ratio(rr, m, "army")) for m in MINS)
            wk = "%s v %s" % (f0(mean([val(r, r["si"], 8, "workers") for r in rr])), f0(mean([val(r, r["oi"], 8, "workers") for r in rr])))
            hl = "%s v %s" % (f2(mean([val(r, r["si"], 12, "halls") for r in rr])), f2(mean([val(r, r["oi"], 12, "halls") for r in rr])))
            lost = "%s / %s" % (f2(mean([r["hl"][r["si"]] for r in rr])), f2(mean([r["hl"][r["oi"]] for r in rr])))
            fa = "%s / %s" % (mmss(med([r["fa"][r["si"]] for r in rr])), mmss(med([r["fa"][r["oi"]] for r in rr])))
            dec = [r["end"] for r in rr if r["res"] in ("W", "L")]
            P("| %s | %d | %s | %d | %d | %s | %s | %s | %s | %s | %s | %d (%s) |" % (
                p, len(rr), wdl(rr), won_led(rr), lost_trailed(rr), inc, arm, wk, hl, lost, fa, len(dec), mmss(mean(dec))))
        P("")
        P("OPTIMAL's opening pick on the %s side (read -> plan), over all of this column's games:\n" % NAME[o])
        c = Counter(pick_of(r, "oi") for p in plans for r in by[(p, o)])
        P(", ".join("%s x%d" % x for x in c.most_common()) + "\n")
        base = by[("optimal", o)]
        if base:
            P("The %s's own OPTIMAL (the baseline row): its opening picks and how they went:\n" % NAME[fac])
            P("| %s OPTIMAL picked | games | W-D-L | won or led |" % NAME[fac])
            P("|---|---|---|---|")
            g = defaultdict(list)
            for r in base:
                g[pick_of(r, "si")].append(r)
            for k, rr in sorted(g.items(), key=lambda x: -len(x[1])):
                P("| %s | %d | %s | %d |" % (k, len(rr), wdl(rr), won_led(rr)))
            P("")
            reads = Counter(r["read"][r["si"]] for r in base)
            P("Its first read of the %s: %s\n" % (NAME[o], ", ".join("%s x%d" % x for x in reads.most_common())))
    P("## Spots\n")
    a = [r for r in rows if r["spot"] == "A"]
    b = [r for r in rows if r["spot"] == "B"]
    P("Won or led on spot A %d of %d, on spot B %d of %d.\n" % (won_led(a), len(a), won_led(b), len(b)))
    P("## By map (all cells)\n")
    P("| map | games | won or led | lost or trailed |")
    P("|---|---|---|---|")
    for m in pm.MAPS:
        rr = [r for r in rows if r["map"] == m]
        if rr:
            P("| %s | %d | %d | %d |" % (m, len(rr), won_led(rr), lost_trailed(rr)))
    P("")
    print("\n".join(out))
    if "--csv" in sys.argv:
        with open(arg("--csv", ""), "w") as f:
            hd = ["tag", "plan", "opp", "map", "round", "spot", "res", "end", "opp_pick", "own_pick", "own_read",
                  "first_attack_own", "first_attack_opp", "halls_lost_own", "halls_lost_opp"]
            for m in MINS:
                hd += ["inc%d_own" % m, "inc%d_opp" % m, "wk%d_own" % m, "wk%d_opp" % m, "army%d_own" % m,
                       "army%d_opp" % m, "halls%d_own" % m, "halls%d_opp" % m]
            f.write(",".join(hd) + "\n")
            for r in rows:
                v = [r["tag"], r["plan"], r["opp"], r["map"], r["r"], r["spot"], r["res"], r["end"],
                     pick_of(r, "oi").replace(",", ";"), pick_of(r, "si").replace(",", ";"), r["read"][r["si"]] or "",
                     r["fa"][r["si"]] or "", r["fa"][r["oi"]] or "", r["hl"][r["si"]], r["hl"][r["oi"]]]
                for m in MINS:
                    for k in ("income", "workers", "army", "halls"):
                        for s in ("si", "oi"):
                            x = val(r, r[s], m, k)
                            v.append("" if x is None else x)
                f.write(",".join(str(x) for x in v) + "\n")


if __name__ == "__main__":
    main()
