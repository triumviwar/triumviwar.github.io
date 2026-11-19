#!/usr/bin/env python3
"""CW WRITTEN OPENINGS report (job cw-written-openings, 2026-11-19; docs/cw_written_openings.md): the Clockwork plans the
job changed, BEFORE (the plan-matrix study's games, docs/plan_matrix_clockwork/data, 0.38.59) against AFTER (the same
tags, map, seed and spots, replayed on the job's build: docs/cw_written_openings/data). A measuring tool only.
    python3 tools/study/cw_written_openings_report.py [BEFORE AFTER] [--maps 4] > docs/cw_written_openings/tables.md
Results read as tools/study/plan_matrix_cw_report.py does (won or led = W + a draw led by 10% of income + 2 x army).
"before -> after": each tag's two games paired (score W/w +1, = 0, l/L -1): better / worse, two-sided sign test.
The economy: Winders, Cog Presses (live + spent), Clocktowers and cogs earned at 3:00, 5:00, 8:00 (medians).
The identity: from the Clockwork's lines of the match log (cwlog.txt, the after games only): when the written build began,
the Springer raid went out, the first Ticking Owl flew, the push went out, the Rush turned to the economy."""
import os, sys, re, statistics as st
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plan_matrix_cw as pm
import plan_matrix_cw_report as rp

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PLANS = ["owls", "springer", "heavy", "rush", "optimal"]
OPPS = ["crown", "brood", "clockwork"]
SH = {"crown": "Crown", "brood": "Brood", "clockwork": "Clockwork"}


def wl(rows):
    w = sum(1 for r in rows if r["lead"] in ("W", "w"))
    c = defaultdict(int)
    for r in rows:
        c[r["res"]] += 1
    return w, "%d-%d-%d" % (c["W"], c["D"], c["L"])


def paired(b, a):
    bk = {r["key"]: r for r in b}
    better = worse = 0
    for r in a:
        o = bk.get(r["key"])
        if o is None:
            continue
        d = rp.score(r) - rp.score(o)
        better += d > 0
        worse += d < 0
    return better, worse, rp.binom_p(min(better, worse), better + worse)


def econ(rows, m):
    out = []
    for k in ("workers", "presses", "halls", "income"):
        xs = []
        for r in rows:
            x = r["at"].get((r["si"], m))
            if x is None:
                continue
            if k == "presses":
                d = x.get("drink") or [0, 0, 0, 0]
                xs.append(d[0] + d[1])
            else:
                xs.append(x.get(k))
        out.append(rp.med(xs))
    return out


MARKS = [
    ("began", re.compile(r"\[(\d+):(\d+)\] P\d Clockwork's Clockwork: plays the .* from here")),
    ("raid", re.compile(r"\[(\d+):(\d+)\] P\d Clockwork's Clockwork: attack: the Springer raid goes out")),
    ("leap", re.compile(r"\[(\d+):(\d+)\] P\d Clockwork's Clockwork: leap: ")),
    ("owl", re.compile(r"\[(\d+):(\d+)\] P\d Clockwork's Clockwork: the first Ticking Owl flies")),
    ("sortie", re.compile(r"\[(\d+):(\d+)\] P\d Clockwork's Clockwork: out: sortie")),
    ("strike", re.compile(r"\[(\d+):(\d+)\] P\d Clockwork's Clockwork: strike: the Owls reach")),
    ("push", re.compile(r"\[(\d+):(\d+)\] P\d Clockwork's Clockwork: push: push \d+ goes out")),
    ("turn", re.compile(r"\[(\d+):(\d+)\] P\d Clockwork's Clockwork: the Rush turns to the economy")),
    ("spring", re.compile(r"\[(\d+):(\d+)\] P\d Clockwork's Clockwork: waits on Tension")),
]


def marks(data, tag, si):
    f = os.path.join(data, tag, "cwlog.txt")
    got = {}
    n = defaultdict(int)
    if not os.path.exists(f):
        return got
    who = "P%d " % (si + 1)
    for l in open(f, errors="replace"):
        if who not in l:
            continue
        for k, rx in MARKS:
            m = rx.search(l)
            if m:
                n[k] += 1
                if k not in got:
                    got[k] = int(m.group(1)) * 60 + int(m.group(2))
    got["n"] = n
    return got


def main():
    args = [a for i, a in enumerate(sys.argv[1:]) if not a.startswith("--") and sys.argv[i] != "--maps"]
    nm = int(sys.argv[sys.argv.index("--maps") + 1]) if "--maps" in sys.argv else 4
    before = args[0] if args else os.path.join(ROOT, "docs/plan_matrix_clockwork/data")
    after = args[1] if len(args) > 1 else os.path.join(ROOT, "docs/cw_written_openings/data")
    maps = pm.MAPS[:nm]
    B = [r for r in rp.load("clockwork", before, maps) if r["plan"] in PLANS]
    A = rp.load("clockwork", after, maps)
    cell = lambda R, p, o: [r for r in R if r["plan"] == p and (o is None or r["opp"] == o)]
    out = []
    P = out.append
    P("# CW written openings: before (0.38.59, the plan matrix) and after (%d games after)\n" % len(A))
    P("Won or led of 8 (W-D-L at 20:00); before -> after paired on the same tag (better / worse, sign test p).\n")
    P("## Won or led\n")
    P("| plan | v Crown before | after | v Brood before | after | v Clockwork before | after | all before | all after | paired better / worse (p) |")
    P("|---|---|---|---|---|---|---|---|---|---|")
    for p in PLANS:
        row = [rp.NAMES[p]]
        for o in OPPS:
            for R in (B, A):
                c = cell(R, p, o)
                if not c:
                    row.append("-")
                    continue
                w, s = wl(c)
                row.append("%d (%s)" % (w, s))
        row.append(str(wl(cell(B, p, None))[0]))
        row.append(str(wl(cell(A, p, None))[0]) + " of %d" % len(cell(A, p, None)))
        bt, wt, pv = paired(cell(B, p, None), cell(A, p, None))
        row.append("%d / %d (%s)" % (bt, wt, rp.fp(pv)))
        P("| " + " | ".join(row) + " |")
    P("")
    P("## Against the OPTIMAL of the same build (after: each plan paired with OPTIMAL's after game on the same tag)\n")
    P("| plan | better / worse than OPTIMAL before (p) | after (p) |")
    P("|---|---|---|")
    for p in PLANS[:-1]:
        r2 = []
        for R in (B, A):
            base = {r["key"]: r for r in cell(R, "optimal", None)}
            bt = wt = 0
            for r in cell(R, p, None):
                o = base.get(r["key"])
                if o is None:
                    continue
                d = rp.score(r) - rp.score(o)
                bt += d > 0
                wt += d < 0
            r2.append("%d / %d (%s)" % (bt, wt, rp.fp(rp.binom_p(min(bt, wt), bt + wt))))
        P("| %s | %s | %s |" % (rp.NAMES[p], r2[0], r2[1]))
    P("")
    P("## The economy (medians of all the plan's games: Winders / Cog Presses / Clocktowers / cogs earned)\n")
    for o in OPPS + [None]:
        P("### %s\n" % ("v " + SH[o] if o else "all three"))
        P("| plan | 3:00 before | after | 5:00 before | after | 8:00 before | after | earned 12:00 before | after | 20:00 before | after |")
        P("|---|---|---|---|---|---|---|---|---|---|---|")
        for p in PLANS:
            row = [rp.NAMES[p]]
            for m in (3, 5, 8):
                for R in (B, A):
                    e = econ(cell(R, p, o), m)
                    row.append("-" if e[0] is None else "%s / %s / %s / %s" % (rp.f0(e[0]), rp.f0(e[1]), rp.f0(e[2]), rp.f0(e[3])))
            for m in (12, 20):
                for R in (B, A):
                    row.append(rp.f0(econ(cell(R, p, o), m)[3]))
            P("| " + " | ".join(row) + " |")
        P("")
    P("## Army value and halls lost (medians; halls lost: own / the enemy's, means)\n")
    P("| plan | v | army 8:00 before | after | army 12:00 before | after | halls lost before | after | first attack before | after |")
    P("|---|---|---|---|---|---|---|---|---|---|")
    for p in PLANS:
        for o in OPPS:
            row = [rp.NAMES[p], SH[o]]
            for m in (8, 12):
                for R in (B, A):
                    row.append(rp.f0(rp.med([rp.val(r, "si", m, "army") for r in cell(R, p, o)])))
            for R in (B, A):
                c = cell(R, p, o)
                if not c:
                    row.append("-")
                    continue
                row.append("%.2f / %.2f" % (st.mean(r["halls_lost"][r["si"]] for r in c), st.mean(r["halls_lost"][r["oi"]] for r in c)))
            for R in (B, A):
                row.append(rp.mmss(rp.med([r["first_att"][r["si"]] for r in cell(R, p, o)])))
            P("| " + " | ".join(row) + " |")
    P("")
    P("## The plans' identity (after; medians of the games where it happened, with how many of 8)\n")
    P("| plan | v | own build began | Springer raid out | first leap | first Owl flies | first sortie | first strike | push out | Rush turned | Mainspring for Tension | leaps / sorties / strikes / pushes a game |")
    P("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for p in PLANS[:-1]:
        for o in OPPS:
            c = cell(A, p, o)
            ms = [marks(after, r["tag"], r["si"]) for r in c]
            row = [rp.NAMES[p], SH[o]]
            for k in ("began", "raid", "leap", "owl", "sortie", "strike", "push", "turn", "spring"):
                xs = [m[k] for m in ms if k in m]
                row.append("-" if not xs else "%s (%d)" % (rp.mmss(st.median(xs)), len(xs)))
            row.append(" / ".join("%.1f" % (st.mean(m["n"][k] for m in ms) if ms else 0) for k in ("leap", "sortie", "strike", "push")))
            P("| " + " | ".join(row) + " |")
    P("")
    print("\n".join(out))


if __name__ == "__main__":
    main()
