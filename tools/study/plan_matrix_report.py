#!/usr/bin/env python3
"""PLAN MATRIX report (docs/plan_matrix_<faction>.md): tables from tools/study/plan_matrix.py's games (tools/qa_match.gd's
result.json). A measuring tool only.
    python3 tools/study/plan_matrix_report.py DATA --faction crown [--csv games.csv] [--cut 1200] > tables.md
The SUBJECT of a game is the side playing the forced plan (in the mirror's OPTIMAL row, the side the queue puts the plan
on). Result: won (W) / lost (L) if a side was beaten by the bell, else a draw LED by income earned + 2 x army value 10%
ahead (w / l) or even (=). "Won or led" = W + w. Against OPTIMAL: each game is paired with the OPTIMAL row's game on the
same map, round, seed and sides; score W/w = +1, = 0, l/L = -1; a sign test of the plan v OPTIMAL (ties dropped), and the
geometric mean of the score ratio (subject / opponent) at the bell with a paired t on its log."""
import os, sys, json, glob, math, csv, statistics as st
from collections import Counter, defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm
import plan_matrix as pm

WORKERS = {"labourer", "winder", "grub"}
NAMES = {"crown": "Crown", "brood": "Brood", "clockwork": "Clockwork"}


def mmss(s):
    return "-" if s is None else "%d:%02d" % (int(s) // 60, int(s) % 60)


def mean(xs):
    xs = [x for x in xs if x is not None]
    return sum(xs) / len(xs) if xs else None


def med(xs):
    xs = [x for x in xs if x is not None]
    return st.median(xs) if xs else None


def binom_p(k, n):
    if n == 0:
        return 1.0
    pk = [math.comb(n, i) / 2 ** n for i in range(n + 1)]
    return min(1.0, sum(p for p in pk if p <= pk[k] + 1e-12))


def fp(p):
    return "%.3f" % p if p >= 0.001 else "<0.001"


def f2(x):
    return "" if x is None else "%.2f" % x


def f0(x):
    return "" if x is None else "{:,}".format(int(round(x)))


def load(data, fac, cut=1200):
    rows = []
    for d in sorted(glob.glob(os.path.join(data, "pm_%s-*" % pm.SHORT[fac]))):
        f = os.path.join(d, "result.json")
        if not os.path.exists(f):
            continue
        tag = os.path.basename(d)
        fac_, plan, opp, m, rnd = pm.parse_tag(tag)
        g = json.load(open(f))
        mi = qm.MAPS.index(m)
        si = 1 if (rnd + mi) % 2 == 1 else 0
        oi = 1 - si
        at = {}
        for r in g["minutes"]:
            at[(r["p"], int(round(r["t"] / 60)))] = r
        end, winner, fin = g["end"], g["winner"], g["final"]
        if end > cut:
            mm = cut // 60
            if (0, mm) in at and (1, mm) in at:
                fin = [at[(0, mm)], at[(1, mm)]]
            end, winner = cut, -1
        sc = [x["income"] + 2 * x["army"] for x in fin]
        if winner >= 0:
            res = lead = "W" if winner == si else "L"
        else:
            res = "D"
            lead = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")
        halls_lost = [0, 0]
        first_hall = [None, None]
        for e in g["events"]:
            if e.get("ev") == "hall_lost" and e.get("built") and e["t"] <= end:
                halls_lost[e["p"]] += 1
                if first_hall[e["p"]] is None:
                    first_hall[e["p"]] = e["t"]
        att = [None, None]
        arr = [None, None]
        for e in g["events"]:
            if e.get("ev") == "first_attack" and e["t"] <= end and att[e["p"]] is None:
                att[e["p"]] = e
            if e.get("ev") == "first_arrival" and e["t"] <= end and arr[e["p"]] is None:
                arr[e["p"]] = e
        # what the subject's first arrival killed in its 90 s (from the deaths: victim kind, victim team, killer kind, team)
        kill = None
        a = arr[si]
        if a:
            k = Counter()
            for dd in g.get("deaths", []):
                if a["t"] <= dd[0] <= a["t"] + 90 and dd[2] == oi and dd[4] == si:
                    k["workers" if dd[1] in WORKERS else "army"] += 1
            hl = sum(1 for e in g["events"] if e.get("ev") == "hall_lost" and e.get("built") and e["p"] == oi
                     and a["t"] <= e["t"] <= a["t"] + 90)
            kill = {"t": a["t"], "workers": k["workers"], "army": k["army"], "halls": hl, "lost": a.get("own_lost", 0)}
        picks = {0: [], 1: []}
        reads = {0: [], 1: []}
        for r in sorted(g.get("reads", []), key=lambda r: r["t"]):
            if r["t"] > end:
                continue
            if "pick" in r:
                picks[r["p"]].append((r["t"], r["pick"]))
            else:
                reads[r["p"]].append((r["t"], r["read"]))
        rows.append({"tag": tag, "plan": plan, "opp": opp, "map": m, "r": rnd, "si": si, "oi": oi, "res": res, "lead": lead,
                     "end": end, "won_at": g["end"] if g["winner"] >= 0 and g["end"] <= cut else None, "at": at,
                     "halls_lost": halls_lost, "first_hall": first_hall, "att": att, "arr": arr, "kill": kill,
                     "picks": picks, "reads": reads, "fin": fin, "sc": sc, "seed": g["seed"], "version": g.get("version", "")})
    return rows


def score(r):
    return 1 if r["lead"] in ("W", "w") else (-1 if r["lead"] in ("L", "l") else 0)


def val(r, p, m, k):
    x = r["at"].get((p, m))
    if x is None and r["won_at"] is not None and m * 60 > r["won_at"]:
        # the game ended before minute m: the last row it has (the loser counts as beaten, 0 left)
        last = max((mm for (pp, mm) in r["at"] if pp == p), default=None)
        x = r["at"].get((p, last)) if last is not None else None
    return x[k] if x else None


def ratio(rows, m, k):
    pr = [(val(r, r["si"], m, k), val(r, r["oi"], m, k)) for r in rows]
    pr = [(a, b) for a, b in pr if a is not None and b is not None]
    s = sum(b for _, b in pr)
    return sum(a for a, _ in pr) / s if pr and s else None


def lratio(r):
    """log of the subject's score / the opponent's at the bell (a beaten side: x0.25 of its score, floor 1)"""
    a, b = r["sc"][r["si"]], r["sc"][r["oi"]]
    if r["res"] == "W":
        b *= 0.25
    elif r["res"] == "L":
        a *= 0.25
    return math.log(max(a, 1) / max(b, 1))


def vs_optimal(rows, opt):
    ob = {(r["map"], r["r"]): r for r in opt}
    pr = [(r, ob[(r["map"], r["r"])]) for r in rows if (r["map"], r["r"]) in ob]
    up = sum(score(a) > score(b) for a, b in pr)
    down = sum(score(a) < score(b) for a, b in pr)
    d = [lratio(a) - lratio(b) for a, b in pr]
    t = None
    if len(d) > 2 and st.stdev(d) > 0:
        t = mean(d) / (st.stdev(d) / math.sqrt(len(d)))
    return {"n": len(pr), "up": up, "down": down, "p": binom_p(min(up, down), up + down) if up + down else 1.0,
            "dr": math.exp(mean(d)) if d else None, "t": t}


def cells(rows):
    c = defaultdict(list)
    for r in rows:
        c[(r["plan"], r["opp"])].append(r)
    return c


def short_pick(s):
    s = s.split("->")[1] if "->" in s else s
    return s.split("(")[0].strip()


def main():
    data = sys.argv[1]
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    fac = arg("--faction", "crown")
    cut = int(arg("--cut", "1200"))
    rows = load(data, fac, cut)
    plans = pm.plans_of(fac)
    opps = [o for o in pm.FACS if o != fac] + [fac]
    C = cells(rows)
    P = print
    P("# Plan matrix tables: %s (%d games, cut at %s)\n" % (NAMES[fac], len(rows), mmss(cut)))
    P("Versions: %s. Maps: %s.\n" % (", ".join(sorted(set(r["version"] for r in rows))),
                                     ", ".join(m for m in pm.MAPS if any(r["map"] == m for r in rows))))
    # 1. the matrix
    P("## Won or led of n (W-D-L), and v OPTIMAL\n")
    P("Each cell: won or led / games (W-D-L; trailed). Below: paired v the OPTIMAL row (same map, round, seed, sides): "
      "better / worse games (sign-test p) and the score ratio at the bell relative to OPTIMAL's (x, paired t).\n")
    P("| plan | " + " | ".join("v %s" % NAMES[o] + (" (mirror)" if o == fac else "") for o in opps) + " | all |")
    P("|---|" + "---|" * (len(opps) + 1))
    for p in plans:
        line = ["**%s**" % p]
        allr = []
        for o in opps:
            rs = C.get((p, o), [])
            allr += rs
            if not rs:
                line.append("")
                continue
            wl = sum(score(r) > 0 for r in rs)
            tr = sum(score(r) < 0 for r in rs)
            W = sum(r["res"] == "W" for r in rs)
            D = sum(r["res"] == "D" for r in rs)
            L = sum(r["res"] == "L" for r in rs)
            s = "%d/%d (%d-%d-%d; %d)" % (wl, len(rs), W, D, L, tr)
            if p != "optimal":
                v = vs_optimal(rs, C.get(("optimal", o), []))
                if v["n"]:
                    s += "<br>%d/%d p %s, x%s%s" % (v["up"], v["down"], fp(v["p"]), f2(v["dr"]),
                                                     "" if v["t"] is None else " t %.1f" % v["t"])
            line.append(s)
        wl = sum(score(r) > 0 for r in allr)
        line.append("%d/%d" % (wl, len(allr)) if allr else "")
        P("| " + " | ".join(line) + " |")
    P()
    # 2. per opponent: economy / army / halls / first attack
    for o in opps:
        P("## v %s%s\n" % (NAMES[o], " (mirror: the forced plan v OPTIMAL)" if o == fac else ""))
        P("Ratios subject / opponent (sums over the cell's games; a beaten side's last row carried).\n")
        P("| plan | n | income 5 | 8 | 12 | 16 | 20 | workers 8 | 12 | 20 (own) | army 8 | 12 | 16 | halls 12 | 20 (own/opp) | "
          "halls lost own / opp | won (median) | lost (median) |")
        P("|---|---|" + "---|" * 16)
        for p in plans:
            rs = C.get((p, o), [])
            if not rs:
                continue
            hl = (sum(r["halls_lost"][r["si"]] for r in rs) / len(rs), sum(r["halls_lost"][r["oi"]] for r in rs) / len(rs))
            wins = [r["won_at"] for r in rs if r["res"] == "W"]
            losses = [r["won_at"] for r in rs if r["res"] == "L"]
            mw = lambda m: mean([val(r, r["si"], m, "workers") for r in rs])
            mh = lambda m, s: mean([val(r, r[s], m, "halls") for r in rs])
            P("| %s | %d | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s/%s | %.2f / %.2f | %d (%s) | %d (%s) |" % (
                p, len(rs), f2(ratio(rs, 5, "income")), f2(ratio(rs, 8, "income")), f2(ratio(rs, 12, "income")),
                f2(ratio(rs, 16, "income")), f2(ratio(rs, 20, "income")), f2(ratio(rs, 8, "workers")),
                f2(ratio(rs, 12, "workers")), f0(mw(20)), f2(ratio(rs, 8, "army")), f2(ratio(rs, 12, "army")),
                f2(ratio(rs, 16, "army")), "%.1f/%.1f" % (mh(12, "si") or 0, mh(12, "oi") or 0), "%.1f" % (mh(20, "si") or 0),
                "%.1f" % (mh(20, "oi") or 0), hl[0], hl[1], len(wins), mmss(med(wins)), len(losses), mmss(med(losses))))
        P()
        P("| plan | own first attack lands (median, n) | kills in its 90 s (workers / army, mean) | halls taken in it | "
          "opp first attack lands | opp OPTIMAL picks |")
        P("|---|---|---|---|---|---|")
        for p in plans:
            rs = C.get((p, o), [])
            if not rs:
                continue
            at = [r["arr"][r["si"]]["t"] for r in rs if r["arr"][r["si"]]]
            ot = [r["arr"][r["oi"]]["t"] for r in rs if r["arr"][r["oi"]]]
            ks = [r["kill"] for r in rs if r["kill"]]
            picks = Counter(short_pick(r["picks"][r["oi"]][-1][1]) if r["picks"][r["oi"]] else "-" for r in rs)
            P("| %s | %s (%d) | %s / %s (%d arrivals) | %d | %s (%d) | %s |" % (
                p, mmss(med(at)), len(at), f2(mean([k["workers"] for k in ks])), f2(mean([k["army"] for k in ks])), len(ks),
                sum(k["halls"] for k in ks), mmss(med(ot)), len(ot), ", ".join("%s %d" % kv for kv in picks.most_common())))
        P()
    # 3. OPTIMAL's own picks on the subject side
    P("## What the subject's OPTIMAL picked\n")
    P("| opponent | map | round | read -> pick (time) | result |")
    P("|---|---|---|---|---|")
    for o in opps:
        for r in sorted(C.get(("optimal", o), []), key=lambda r: (pm.MAPS.index(r["map"]), r["r"])):
            pk = "; ".join("%s (%s)" % (pp.replace("opening ", ""), mmss(t)) for t, pp in r["picks"][r["si"]]) or "-"
            P("| %s | %s | %d | %s | %s |" % (NAMES[o], r["map"], r["r"], pk, r["lead"]))
    P()
    # 4. per map: best plan
    P("## By map: the subject's result per plan (W w = l L)\n")
    for o in opps:
        P("v %s\n" % NAMES[o])
        P("| plan | " + " | ".join("%s r%d" % (m, rr) for m in pm.MAPS for rr in (0, 1)) + " |")
        P("|---|" + "---|" * (len(pm.MAPS) * 2))
        for p in plans:
            rs = {(r["map"], r["r"]): r for r in C.get((p, o), [])}
            P("| %s | " % p + " | ".join(rs[(m, rr)]["lead"] if (m, rr) in rs else "" for m in pm.MAPS for rr in (0, 1)) + " |")
        P()
    if "--csv" in sys.argv:
        with open(arg("--csv", "games.csv"), "w", newline="") as f:
            w = csv.writer(f)
            w.writerow(["tag", "plan", "opp", "map", "round", "seed", "subject_side", "result", "lead", "end", "won_at",
                        "score_subj", "score_opp", "inc8_ratio", "inc12_ratio", "inc20_ratio", "army8_ratio", "army12_ratio",
                        "workers8", "workers20", "halls12", "halls20", "halls_lost", "opp_halls_lost", "first_attack",
                        "arrival_workers_killed", "arrival_army_killed", "opp_first_attack", "subj_picks", "opp_picks"])
            for r in rows:
                gr = lambda m, k: (val(r, r["si"], m, k) / val(r, r["oi"], m, k)) if val(r, r["si"], m, k) is not None and val(r, r["oi"], m, k) else None
                w.writerow([r["tag"], r["plan"], r["opp"], r["map"], r["r"], r["seed"], r["si"], r["res"], r["lead"], r["end"],
                            r["won_at"], r["sc"][r["si"]], r["sc"][r["oi"]], f2(gr(8, "income")), f2(gr(12, "income")),
                            f2(gr(20, "income")), f2(gr(8, "army")), f2(gr(12, "army")), val(r, r["si"], 8, "workers"),
                            val(r, r["si"], 20, "workers"), val(r, r["si"], 12, "halls"), val(r, r["si"], 20, "halls"),
                            r["halls_lost"][r["si"]], r["halls_lost"][r["oi"]],
                            r["arr"][r["si"]]["t"] if r["arr"][r["si"]] else "",
                            r["kill"]["workers"] if r["kill"] else "", r["kill"]["army"] if r["kill"] else "",
                            r["arr"][r["oi"]]["t"] if r["arr"][r["oi"]] else "",
                            " | ".join(pp for _, pp in r["picks"][r["si"]]), " | ".join(pp for _, pp in r["picks"][r["oi"]])])


if __name__ == "__main__":
    main()
