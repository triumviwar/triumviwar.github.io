#!/usr/bin/env python3
"""THE BATTLE MATRIX, ALL MATCHUPS (job battle-matrix-all, docs/battle_matrix_all.md): from the lab's rows
(docs/battle_matrix_all/data/rows_*.jsonl, tools/battle_lab.gd run by tools/study/battle_lab.py) for each matchup and
ground and size: the cells, what beats what, the best answer to each comp, the safest comp, the game's value at equal
cost (each side's best blind mix), and the fighting counts. A MIRROR (one faction both sides) is read as one table: the
cell X v Y is the mean of "X as side A against Y" and "1 - (Y as side A against X)", so both spots count.

  python3 tools/study/battle_matrix_all_report.py [--data docs/battle_matrix_all/data] [--md docs/battle_matrix_all/tables.md]
"""
import argparse
import glob
import json
import math
import os
import sys
from collections import defaultdict

sys.path.insert(0, os.path.dirname(__file__))
import battle_lab as bl  # noqa: E402
from battle_matrix_report import nash  # noqa: E402

ROOT = bl.ROOT
FNAME = {"crown": "Crown", "brood": "Brood", "clockwork": "Clockwork"}
GROUND = {"open": "open field", "set": "the set line (side A formed by hand, ready)", "block": "the set block",
          "choke": "a choke (side A holds the gap)", "up": "a ramp, side A on top", "down": "a ramp, side B on top"}


def load(data):
    rows = []
    for f in sorted(glob.glob(os.path.join(data, "rows_*.jsonl"))):
        rows += bl.load_rows(f)
    out = []
    for r in rows:
        fa, ca, fb, cb = bl.side(r)
        r["_s"] = (fa, ca, fb, cb)
        out.append(r)
    return out


def mean(xs):
    return sum(xs) / len(xs) if xs else float("nan")


def matchup_cells(rows, fa, fb, ground, size):
    """{(compA, compB): [scores for compA]}; a mirror folds both orders."""
    c = defaultdict(list)
    for r in rows:
        if r["ground"] != ground or int(r["size"]) != size:
            continue
        a, x, b, y = r["_s"]
        if (a, b) == (fa, fb):
            c[(x, y)].append(r["score"])
            if fa == fb:
                c[(y, x)].append(1.0 - r["score"])
    return c


def verdict(xs):
    m, h = bl.ci95(xs)
    if math.isnan(h):
        h = 0.5
    return "A" if m - h > 0.5 else ("B" if m + h < 0.5 else "=")


def comps(fa):
    return bl.COMPS[fa]


def name(f, c):
    return bl.NAMES[f].get(c, c)


def section(rows, fa, fb, ground, size, md, summ):
    cells = matchup_cells(rows, fa, fb, ground, size)
    if not cells:
        return
    A = [c for c in comps(fa) if any(k[0] == c for k in cells)]
    B = [c for c in comps(fb) if any(k[1] == c for k in cells)]
    n = sum(len(v) for v in cells.values())
    mirror = fa == fb
    key = f"{fa}|{fb}|{ground}|{size}"
    md.append(f"\n### {FNAME[fa]} v {FNAME[fb]}: {GROUND.get(ground, ground)}, {bl.SIZE_NAME.get(size, size)} ({n} results)\n")
    md.append(f"Each cell: the **{FNAME[fa] + ' row' if not mirror else 'row'}'s share** of the value lost (50 = even; bold: the row clearly "
              f"ahead, italic: the column clearly ahead), then how many fights.\n")
    md.append("| " + ("row \\ column" if mirror else f"{FNAME[fa]} \\ {FNAME[fb]}") + " | " + " | ".join(B) + " | mean |")
    md.append("|---|" + "---|" * (len(B) + 1))
    M = []
    for a in A:
        line = [f"**{a}**"]
        row = []
        for b in B:
            xs = cells.get((a, b), [])
            if not xs:
                line.append("")
                row.append(0.5)
                continue
            m = mean(xs)
            row.append(m)
            v = verdict(xs)
            t = f"{round(m * 100)} ({len(xs)})"
            line.append(f"**{t}**" if v == "A" else (f"*{t}*" if v == "B" else t))
        M.append(row)
        line.append(f"{round(mean(row) * 100)}")
        md.append("| " + " | ".join(line) + " |")
    # what beats what
    md.append("")
    out = {"n": n, "A": A, "B": B, "matrix": [[round(x, 3) for x in r] for r in M]}
    best_vs_a = {}
    for i, a in enumerate(A):
        j = min(range(len(B)), key=lambda j: M[i][j])
        best_vs_a[a] = (B[j], M[i][j])
    best_vs_b = {}
    for j, b in enumerate(B):
        i = max(range(len(A)), key=lambda i: M[i][j])
        best_vs_b[b] = (A[i], M[i][j])
    safe_a = sorted(A, key=lambda a: -min(M[A.index(a)]))
    safe_b = sorted(B, key=lambda b: max(M[i][B.index(b)] for i in range(len(A))))
    avg_a = sorted(A, key=lambda a: -mean(M[A.index(a)]))
    avg_b = sorted(B, key=lambda b: mean([M[i][B.index(b)] for i in range(len(A))]))
    if mirror:
        md.append("| comp | its best counter (its share) | it beats clearly |")
        md.append("|---|---|---|")
        for a in A:
            i = A.index(a)
            beats = [B[j] for j in range(len(B)) if (a, B[j]) in cells and verdict(cells[(a, B[j])]) == "A"]
            md.append(f"| {a} ({name(fa, a)}) | {best_vs_a[a][0]} ({round((1 - best_vs_a[a][1]) * 100)}) | {', '.join(beats) or 'none'} |")
    else:
        md.append(f"| {FNAME[fa]} comp | {FNAME[fb]}'s best answer ({FNAME[fa]} share) | {FNAME[fb]} comp | {FNAME[fa]}'s best answer ({FNAME[fa]} share) |")
        md.append("|---|---|---|---|")
        for k in range(max(len(A), len(B))):
            c1 = f"{A[k]} ({name(fa, A[k])}) | {best_vs_a[A[k]][0]} ({round(best_vs_a[A[k]][1] * 100)})" if k < len(A) else " | "
            c2 = f"{B[k]} ({name(fb, B[k])}) | {best_vs_b[B[k]][0]} ({round(best_vs_b[B[k]][1] * 100)})" if k < len(B) else " | "
            md.append(f"| {c1} | {c2} |")
    md.append("")
    md.append(f"Best on average: {FNAME[fa]} " + ", ".join(f"{a} {round(mean(M[A.index(a)]) * 100)}" for a in avg_a[:4]))
    if not mirror:
        md.append(f"; {FNAME[fb]} " + ", ".join(f"{b} {round((1 - mean([M[i][B.index(b)] for i in range(len(A))])) * 100)}" for b in avg_b[:4]) + " (its own share).")
        md.append(f"\nSafest (best at its worst): {FNAME[fa]} " + ", ".join(f"{a} {round(min(M[A.index(a)]) * 100)}" for a in safe_a[:3])
                  + f"; {FNAME[fb]} " + ", ".join(f"{b} {round((1 - max(M[i][B.index(b)] for i in range(len(A)))) * 100)}" for b in safe_b[:3]) + ".")
    else:
        md.append(f"\nSafest (best at its worst): " + ", ".join(f"{a} {round(min(M[A.index(a)]) * 100)}" for a in safe_a[:3]) + ".")
    v, x, y = nash(M)
    mix_a = ", ".join(f"{A[i]} {round(x[i] * 100)}%" for i in sorted(range(len(A)), key=lambda i: -x[i]) if x[i] > 0.01)
    mix_b = ", ".join(f"{B[j]} {round(y[j] * 100)}%" for j in sorted(range(len(B)), key=lambda j: -y[j]) if y[j] > 0.01)
    if mirror:
        md.append(f"\n**The best blind mix** (each side picks blind, each at its best mix): {mix_a}.")
    else:
        md.append(f"\n**The game's value at equal cost** (both pick blind, each its best mix): {FNAME[fa]}'s share **{round(v * 100)}**. "
                  f"{FNAME[fa]}'s mix: {mix_a}. {FNAME[fb]}'s: {mix_b}.")
    out.update({"value": round(v, 3), "mix_a": dict(zip(A, [round(t, 3) for t in x])), "mix_b": dict(zip(B, [round(t, 3) for t in y])),
                "best_answer_to_a": {k: [w[0], round(w[1], 3)] for k, w in best_vs_a.items()},
                "best_answer_to_b": {k: [w[0], round(w[1], 3)] for k, w in best_vs_b.items()}})
    if "RSy" in B:
        jj = [j for j in range(len(B)) if B[j] != "RSy"]
        M2 = [[r[j] for j in jj] for r in M]
        v2, x2, y2 = nash(M2)
        md.append(f"Without the Tyrant Sire (RSy left out): {FNAME[fa]}'s share **{round(v2 * 100)}**.")
        out["value_no_sire"] = round(v2, 3)
    if "RSy" in A and not mirror:
        ii = [i for i in range(len(A)) if A[i] != "RSy"]
        v2, x2, y2 = nash([M[i] for i in ii])
        md.append(f"Without the Tyrant Sire (RSy left out): {FNAME[fa]}'s share **{round(v2 * 100)}**.")
        out["value_no_sire"] = round(v2, 3)
    summ[key] = out


def micro(rows, md, summ):
    md.append("\n## The fighting counts (all grounds and sizes)\n")
    md.append("| matchup | fights | fight length s (mean) | pulls a minute, side A / B | Clockwork constructs run down (a fight) | under a quarter wind | Crown guns set at contact | guns fired in the first 20 s | own men killed by own splash |")
    md.append("|---|---|---|---|---|---|---|---|---|")
    g = defaultdict(list)
    for r in rows:
        a, x, b, y = r["_s"]
        g[(a, b)].append(r)
    for (a, b), rs in sorted(g.items()):
        mins = [max(0.5, (r["time"] + max(0.0, r["contact"])) / 60.0) for r in rs]
        pa = mean([r["pulls"][0] / m for r, m in zip(rs, mins)])
        pb = mean([r["pulls"][1] / m for r, m in zip(rs, mins)])
        wd = [sum(r.get("wind_down", [0, 0])) for r in rs]
        wl = [sum(r.get("wind_low", [0, 0])) for r in rs]
        gr = [r for r in rs if r.get("guns", 0) > 0 and r.get("guns_set_contact", -1) >= 0]
        gs = mean([r["guns_set_contact"] / r["guns"] for r in gr]) if gr else float("nan")
        gf = [r for r in rs if r.get("guns", 0) > 0 and r.get("guns_fired_20", -1) >= 0]
        gfs = mean([r["guns_fired_20"] / r["guns"] for r in gf]) if gf else float("nan")
        ff = mean([r.get("c_friendly_kills", 0) + r.get("b_friendly_kills", 0) for r in rs])
        cw = "clockwork" in (a, b)
        md.append(f"| {FNAME[a]} v {FNAME[b]} | {len(rs)} | {mean([r['time'] for r in rs]):.0f} | {pa:.1f} / {pb:.1f} | "
                  f"{mean(wd):.2f} | {mean(wl):.2f} | " if cw else
                  f"| {FNAME[a]} v {FNAME[b]} | {len(rs)} | {mean([r['time'] for r in rs]):.0f} | {pa:.1f} / {pb:.1f} | - | - | ")
        md[-1] += (f"{round(gs * 100)}% | {round(gfs * 100)}% | {ff:.2f} |" if gr else f"- | - | {ff:.2f} |")
        summ[f"micro|{a}|{b}"] = {"n": len(rs), "pulls_a_min": round(pa, 2), "pulls_b_min": round(pb, 2),
                                  "wind_down": round(mean(wd), 2) if cw else None, "wind_low": round(mean(wl), 2) if cw else None,
                                  "guns_set_contact": None if not gr else round(gs, 3), "guns_fired_20": None if not gf else round(gfs, 3)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", default=os.path.join(ROOT, "docs/battle_matrix_all/data"))
    ap.add_argument("--md", default=os.path.join(ROOT, "docs/battle_matrix_all/tables.md"))
    ap.add_argument("--json", default=os.path.join(ROOT, "docs/battle_matrix_all/data/analysis.json"))
    a = ap.parse_args()
    rows = load(a.data)
    md = [f"# The battle matrix, all matchups: the tables\n\n{len(rows)} fights (tools/study/battle_matrix_all_report.py). "
          "Side A is the first faction named. The score is side A's share of the value lost in a fight (50 = an even trade).\n"]
    summ = {}
    pairs = []
    for r in rows:
        p = (r["_s"][0], r["_s"][2])
        if p not in pairs:
            pairs.append(p)
    for fa, fb in pairs:
        md.append(f"\n## {FNAME[fa]} v {FNAME[fb]}\n")
        for ground in ["open", "set", "block", "choke", "up", "down"]:
            for size in sorted({int(r["size"]) for r in rows}):
                section(rows, fa, fb, ground, size, md, summ)
    micro(rows, md, summ)
    open(a.md, "w").write("\n".join(md) + "\n")
    json.dump(summ, open(a.json, "w"), indent=1, sort_keys=True)
    print(f"wrote {a.md} and {a.json}: {len(rows)} rows")


if __name__ == "__main__":
    main()
