#!/usr/bin/env python3
"""BROOD v CLOCKWORK ARMY (brood-v-clockwork-army, docs/brood_v_clockwork_army.md): before v after, from two plan-matrix
data folders (tools/study/plan_matrix_brood.py runs, the same tags, seeds and spots).
    python3 tools/study/brood_v_cw_army_report.py BEFORE AFTER
Per plan and opponent: won or led (W-D-L, w/l at the bell), the finer score (plan_matrix_brood_cw.fine), better / worse
paired game by game (sign test); against the Clockwork also the army mix by minute (median count of each kind), the
deaths by 12:00 (a game) and what killed the Raptors, army and income ratios. A measuring tool: it changes no rule."""
import os, sys, json, statistics as st
from collections import defaultdict, Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plan_matrix_brood_report as rep
from plan_matrix_brood_cw import fine

KINDS = ["raptor", "spitter", "venom_challenger", "tyrant_challenger", "brute", "mist_toad", "hatchlings", "storm_challenger"]


def rows_of(data):
    out = {}
    for r in rep.load("brood", data):
        out[(r["plan"], r["opp"], r["map"], r["r"])] = r
    return out


def res(r):
    if r["res"] in ("W", "L"):
        return r["res"]
    fin = r["final"]
    a = fin[r["si"]]["income"] + 2 * fin[r["si"]]["army"]
    b = fin[r["oi"]]["income"] + 2 * fin[r["oi"]]["army"]
    return "w" if a > b * 1.1 else ("l" if b > a * 1.1 else "=")


def raw(data, r):
    return json.load(open(os.path.join(data, r["tag"], "result.json")))


def side_min(g, team, t):
    for m in g["minutes"]:
        if m["p"] == team and m["t"] == t:
            return m
    return None


def main():
    bdir, adir = sys.argv[1], sys.argv[2]
    B, A = rows_of(bdir), rows_of(adir)
    print("## Results\n")
    print("| plan v | before: won or led (W-D-L) | after: won or led (W-D-L) | better / worse (p) | finer score before / after |")
    print("|---|---|---|---|---|")
    for key in sorted({(k[0], k[1]) for k in A}):
        ks = [k for k in A if (k[0], k[1]) == key and k in B]
        if not ks:
            continue
        line = []
        for D in (B, A):
            c = Counter(res(D[k]) for k in ks)
            line.append("%d (%d-%d-%d)" % (c["W"] + c["w"], c["W"], c["w"] + c["="] + c["l"], c["L"]))
        up = sum(1 for k in ks if fine(A[k]) > fine(B[k]) + 1e-9)
        dn = sum(1 for k in ks if fine(A[k]) < fine(B[k]) - 1e-9)
        fb = sum(fine(B[k]) for k in ks) / len(ks)
        fa = sum(fine(A[k]) for k in ks) / len(ks)
        print("| %s v %s (%d games) | %s | %s | %d / %d (%s) | %.2f / %.2f |" % (key[0], rep.NAME[key[1]], len(ks), line[0], line[1],
            up, dn, rep.fp(rep.binom_p(min(up, dn), up + dn)), fb, fa))
    for plan in sorted({k[0] for k in A if k[1] == "clockwork"}):
        print("\n## %s v the Clockwork\n" % plan)
        for name, D, d in (("before", B, bdir), ("after", A, adir)):
            ks = [k for k in D if k[0] == plan and k[1] == "clockwork" and k in A and k in B]
            if not ks:
                continue
            mix = defaultdict(lambda: defaultdict(list))
            ratios = defaultdict(lambda: defaultdict(list))
            deaths = Counter()
            killers = Counter()
            ends = []
            for k in ks:
                r = D[k]
                g = raw(d, r)
                bt = g["slots"][r["si"]][2]
                ct = g["slots"][r["oi"]][2]
                ends.append(g.get("end", 1200) if g.get("over") else 1200)
                for t in (360, 480, 600, 720, 960):
                    mb, mc = side_min(g, bt, t), side_min(g, ct, t)
                    if mb and mc and not mb["out"]:
                        for kk in KINDS:
                            mix[t][kk].append(int(mb.get("kinds", {}).get(kk, 0)))
                        ratios[t]["army"].append(mb["army"] / max(1, mc["army"]))
                        ratios[t]["income"].append(mb["income"] / max(1, mc["income"]))
                for t, kd, tm, kk, kt, *_ in g["deaths"]:
                    if t > 720:
                        continue
                    if tm == bt:
                        deaths["B " + kd] += 1
                        if kd == "raptor":
                            killers[kk] += 1
                    else:
                        deaths["C " + kd] += 1
            n = len(ks)
            print("**%s** (%d games; mean end %s)\n" % (name, n, rep.mmss(sum(ends) / n)))
            print("| minute | games alive | " + " | ".join(KINDS[:6]) + " | army ratio | income ratio |")
            print("|---|---|" + "---|" * 6 + "---|---|")
            for t in sorted(mix):
                print("| %d | %d | %s | %.2f | %.2f |" % (t // 60, len(ratios[t]["army"]), " | ".join(
                    "%g" % st.median(mix[t][kk]) for kk in KINDS[:6]), st.median(ratios[t]["army"]), st.median(ratios[t]["income"])))
            bl = {k[2:]: round(v / n, 1) for k, v in deaths.most_common() if k.startswith("B ") and v / n >= 0.5}
            cl = {k[2:]: round(v / n, 1) for k, v in deaths.most_common() if k.startswith("C ") and v / n >= 0.5}
            print("\nDeaths by 12:00, a game. Brood: %s. Clockwork: %s. The Raptors killed by: %s.\n" % (
                bl, cl, {k: round(v / n, 1) for k, v in killers.most_common(5)}))


if __name__ == "__main__":
    main()
