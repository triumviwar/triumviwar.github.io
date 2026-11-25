#!/usr/bin/env python3
"""THE BATTLE MATRIX's analysis (job battle-matrix, docs/battle_matrix.md): from the lab's rows
(docs/battle_matrix/data/rows.jsonl, tools/study/battle_lab.py) the counters, the best answers, the best compositions,
the game's value at equal cost, and the fighting (micro) counts. Writes docs/battle_matrix/analysis.md and
docs/battle_matrix/data/analysis.json.

  python3 tools/study/battle_matrix_report.py [--rows ...] [--md ...] [--json ...]
"""
import argparse
import json
import math
import os
import sys
from collections import defaultdict

sys.path.insert(0, os.path.dirname(__file__))
import battle_lab as bl  # noqa: E402

ROOT = bl.ROOT


def score_cells(rows):
    c = defaultdict(list)
    for r in rows:
        c[(r["crown"], r["brood"], int(r["size"]), r["ground"])].append(r)
    return c


def nash(mat):
    """The value of the zero-sum game (rows: the Crown picks a composition, columns: the Brood; payoff: the Crown's score)
    and both sides' best mixes, by linear programming. [value, crown mix, brood mix]"""
    import numpy as np
    from scipy.optimize import linprog
    A = np.array(mat)
    m, n = A.shape
    # the Crown: max v s.t. x^T A >= v, sum x = 1
    c = np.zeros(m + 1)
    c[-1] = -1.0
    A_ub = np.hstack([-A.T, np.ones((n, 1))])
    b_ub = np.zeros(n)
    A_eq = np.hstack([np.ones((1, m)), np.zeros((1, 1))])
    res = linprog(c, A_ub=A_ub, b_ub=b_ub, A_eq=A_eq, b_eq=[1.0], bounds=[(0, None)] * m + [(None, None)])
    x = res.x[:m]
    v = res.x[-1]
    # the Brood: min w s.t. A y <= w
    c2 = np.zeros(n + 1)
    c2[-1] = 1.0
    A_ub2 = np.hstack([A, -np.ones((m, 1))])
    res2 = linprog(c2, A_ub=A_ub2, b_ub=np.zeros(m), A_eq=np.hstack([np.ones((1, n)), np.zeros((1, 1))]), b_eq=[1.0],
                   bounds=[(0, None)] * n + [(None, None)])
    y = res2.x[:n]
    return float(v), [float(t) for t in x], [float(t) for t in y]


def pct(x):
    return f"{round(x * 100)}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rows", default=os.path.join(ROOT, "docs/battle_matrix/data/rows.jsonl"))
    ap.add_argument("--md", default=os.path.join(ROOT, "docs/battle_matrix/analysis.md"))
    ap.add_argument("--json", default=os.path.join(ROOT, "docs/battle_matrix/data/analysis.json"))
    a = ap.parse_args()
    rows = bl.load_rows(a.rows)
    cl = score_cells(rows)
    out = {"fights": len(rows), "blocks": {}}
    md = [f"# The battle matrix: the analysis (made by tools/study/battle_matrix_report.py)\n",
          f"{len(rows)} fights. Score = the Crown's share of the value lost in the fight (50 = even). "
          f"C = the Crown clearly ahead (the 95% interval above 50), B = the Brood clearly ahead, = = not told apart.\n"]
    grounds = [g for g in ["open", "choke", "up", "down"] if any(r["ground"] == g for r in rows)]
    sizes = sorted({int(r["size"]) for r in rows})
    for g in grounds:
        for sz in sizes:
            crown = [c for c in bl.CROWN if any((c, b, sz, g) in cl for b in bl.BROOD)]
            brood = [b for b in bl.BROOD if any((c, b, sz, g) in cl for c in bl.CROWN)]
            if not crown or not brood:
                continue
            S = {}
            V = {}
            for c in crown:
                for b in brood:
                    rs = cl.get((c, b, sz, g), [])
                    if rs:
                        m, h = bl.ci95([r["score"] for r in rs])
                        S[(c, b)] = m
                        V[(c, b)] = bl.verdict(m, h)
            full = all((c, b) in S for c in crown for b in brood)
            blk = {"n": sum(len(cl.get((c, b, sz, g), [])) for c in crown for b in brood)}
            md.append(f"\n## {bl.GROUND_NAME[g]}, {bl.SIZE_NAME.get(sz, sz)} ({blk['n']} fights)\n")
            nc = sum(1 for v in V.values() if v == "C")
            nb = sum(1 for v in V.values() if v == "B")
            ne = sum(1 for v in V.values() if v == "=")
            blk["cells"] = {"C": nc, "B": nb, "=": ne}
            md.append(f"Pairings: the Crown clearly ahead in **{nc}**, the Brood in **{nb}**, even in {ne} (of {len(V)}). "
                      f"Mean score over all pairings: {pct(sum(S.values()) / len(S))}.\n")
            # the best Crown answer to each Brood composition, and the reverse
            md.append("| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |")
            md.append("|---|---|---|---|---|")
            best_c = {}
            for b in brood:
                lst = sorted([(S[(c, b)], c) for c in crown if (c, b) in S], reverse=True)
                best_c[b] = lst[0][1]
                beats = [c for c in crown if V.get((c, b)) == "C"]
                md.append(f"| {b} ({bl.BROOD_NAMES[b]}) | {lst[0][1]} ({pct(lst[0][0])}) | {(lst[1][1] + ' (' + pct(lst[1][0]) + ')') if len(lst) > 1 else ''} | "
                          f"{lst[-1][1]} ({pct(lst[-1][0])}) | {', '.join(beats) if beats else 'none'} |")
            md.append("")
            md.append("| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |")
            md.append("|---|---|---|---|---|")
            best_b = {}
            for c in crown:
                lst = sorted([(S[(c, b)], b) for b in brood if (c, b) in S])
                best_b[c] = lst[0][1]
                beats = [b for b in brood if V.get((c, b)) == "B"]
                md.append(f"| {c} ({bl.CROWN_NAMES[c]}) | {lst[0][1]} ({pct(lst[0][0])}) | {(lst[1][1] + ' (' + pct(lst[1][0]) + ')') if len(lst) > 1 else ''} | "
                          f"{lst[-1][1]} ({pct(lst[-1][0])}) | {', '.join(beats) if beats else 'none'} |")
            # the best composition overall: on average, and at its worst (what a side picks when it cannot see the other)
            avg_c = sorted([(sum(S[(c, b)] for b in brood if (c, b) in S) / max(1, sum(1 for b in brood if (c, b) in S)), c) for c in crown], reverse=True)
            worst_c = sorted([(min(S[(c, b)] for b in brood if (c, b) in S), c) for c in crown], reverse=True)
            avg_b = sorted([(sum(S[(c, b)] for c in crown if (c, b) in S) / max(1, sum(1 for c in crown if (c, b) in S)), b) for b in brood])
            worst_b = sorted([(max(S[(c, b)] for c in crown if (c, b) in S), b) for b in brood])
            md.append(f"\nBest Crown compositions on average: " + ", ".join(f"{c} {pct(v)}" for v, c in avg_c[:4]) +
                      f". Safest (best at its worst): " + ", ".join(f"{c} {pct(v)}" for v, c in worst_c[:3]) + ".")
            md.append(f"Best Brood compositions on average: " + ", ".join(f"{b} {pct(1 - v)}" for v, b in avg_b[:4]) +
                      f" (the Brood's own share). Safest: " + ", ".join(f"{b} {pct(1 - v)}" for v, b in worst_b[:3]) + ".")
            # dominance: a composition no composition of the other side beats
            dom_b = [b for b in brood if all(S.get((c, b), 0.0) < 0.5 for c in crown)]
            dom_b_clear = [b for b in brood if all(V.get((c, b)) == "B" for c in crown)]
            dom_c = [c for c in crown if all(S.get((c, b), 1.0) > 0.5 for b in brood)]
            dom_c_clear = [c for c in crown if all(V.get((c, b)) == "C" for b in brood)]
            md.append(f"Brood compositions that out-trade EVERY Crown composition: {', '.join(dom_b) or 'none'} "
                      f"(clearly, every one: {', '.join(dom_b_clear) or 'none'}). Crown compositions that out-trade every Brood "
                      f"composition: {', '.join(dom_c) or 'none'} (clearly: {', '.join(dom_c_clear) or 'none'}).")
            blk.update({"best_crown_answer": best_c, "best_brood_answer": best_b,
                        "avg_crown": [[c, round(v, 3)] for v, c in avg_c], "avg_brood": [[b, round(v, 3)] for v, b in avg_b],
                        "worst_crown": [[c, round(v, 3)] for v, c in worst_c], "worst_brood": [[b, round(v, 3)] for v, b in worst_b],
                        "dominant_brood": dom_b, "dominant_brood_clear": dom_b_clear, "dominant_crown": dom_c,
                        "dominant_crown_clear": dom_c_clear})
            if full:
                v, x, y = nash([[S[(c, b)] for b in brood] for c in crown])
                mx = ", ".join(f"{c} {round(p * 100)}%" for c, p in sorted(zip(crown, x), key=lambda t: -t[1]) if p > 0.01)
                my = ", ".join(f"{b} {round(p * 100)}%" for b, p in sorted(zip(brood, y), key=lambda t: -t[1]) if p > 0.01)
                md.append(f"\n**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's "
                          f"share **{pct(v)}**. The Crown's best mix: {mx}. The Brood's: {my}.")
                blk["nash"] = {"value": round(v, 3), "crown": dict(zip(crown, [round(t, 3) for t in x])),
                               "brood": dict(zip(brood, [round(t, 3) for t in y]))}
            out["blocks"][f"{g}|{sz}"] = blk
    # the fighting: guns, riders, pulls
    md.append("\n## The fighting (micro) counts\n")
    md.append("| ground, size | Crown armies with guns | guns set at contact | guns set 10 s after | guns that fired by 20 s | "
              "guns lost per gun | riders lost per rider | the Crown's pulls a fight | the Brood's pulls a fight |")
    md.append("|---|---|---|---|---|---|---|---|---|")
    mic = {}
    for g in grounds:
        for sz in sizes:
            rs = [r for r in rows if r["ground"] == g and int(r["size"]) == sz]
            if not rs:
                continue
            gr = [r for r in rs if r["guns"] > 0 and r["contact"] >= 0]
            ng = sum(r["guns"] for r in gr)
            s0 = sum(max(0, r["guns_set_contact"]) for r in gr)
            s10 = sum(max(0, r["guns_set_10"]) for r in gr)
            f20 = sum(max(0, r["guns_fired_20"]) for r in gr)
            gl = sum(r["guns_lost"] for r in gr)
            rid = [r for r in rs if any(k in r["crown_n"] for k in ("cuirassier", "dragoon"))]
            nr = sum(int(r["crown_n"].get("cuirassier", 0)) + int(r["crown_n"].get("dragoon", 0)) for r in rid)
            rl = sum(r["riders_lost"] for r in rid)
            pc = sum(r["pulls"][0] for r in rs) / len(rs)
            pb = sum(r["pulls"][1] for r in rs) / len(rs)
            mic[f"{g}|{sz}"] = {"guns": ng, "set0": s0, "set10": s10, "fired20": f20, "lost": gl, "riders": nr, "riders_lost": rl,
                                "pulls_c": pc, "pulls_b": pb}
            md.append(f"| {bl.GROUND_NAME[g]}, {sz} | {len(gr)} | {pct(s0 / max(1, ng))}% | {pct(s10 / max(1, ng))}% | "
                      f"{pct(f20 / max(1, ng))}% | {gl / max(1, ng):.2f} | {rl / max(1, nr):.2f} | {pc:.1f} | {pb:.1f} |")
    out["micro"] = mic
    # the guns' worth: the same army with and without its guns (M against MC, MCH; the score's difference, Brood by Brood)
    md.append("\n## What the guns, riders and the rest add (score against the plain Musketeer line, same Brood army)\n")
    md.append("| ground, size | " + " | ".join(c for c in bl.CROWN if c != "M") + " |")
    md.append("|---|" + "---|" * (len(bl.CROWN) - 1))
    for g in grounds:
        for sz in sizes:
            line = [f"{g}, {sz}"]
            for c in bl.CROWN:
                if c == "M":
                    continue
                d = []
                for b in bl.BROOD:
                    r1 = cl.get((c, b, sz, g))
                    r0 = cl.get(("M", b, sz, g))
                    if r1 and r0:
                        d.append(sum(r["score"] for r in r1) / len(r1) - sum(r["score"] for r in r0) / len(r0))
                line.append(f"{d and '%+d' % round(sum(d) / len(d) * 100) or ''}")
            md.append("| " + " | ".join(line) + " |")
    # THE FIGHTING OR THE NUMBERS: the same armies, the Crown marching under its computer (open) and set by hand (set)
    if "open" in grounds and "set" in grounds:
        md.append("\n## The fighting or the numbers: open field (the computer marches) against the set line (formed, guns up)\n")
        md.append("| size | mean score, open | mean score, set | pairings the Brood wins open but the Crown wins set | "
                  "the Brood wins both | the Crown wins both |")
        md.append("|---|---|---|---|---|---|")
        fx = {}
        for sz in sizes:
            o_all, s_all, flip, bb, cc = [], [], [], [], []
            for c in bl.CROWN:
                for b in bl.BROOD:
                    ro = cl.get((c, b, sz, "open"))
                    rs = cl.get((c, b, sz, "set"))
                    if not ro or not rs:
                        continue
                    mo, ho = bl.ci95([r["score"] for r in ro])
                    ms, hs = bl.ci95([r["score"] for r in rs])
                    o_all.append(mo)
                    s_all.append(ms)
                    vo, vs = bl.verdict(mo, ho), bl.verdict(ms, hs)
                    if vo == "B" and vs == "C":
                        flip.append(f"{c}-{b}")
                    if vo == "B" and vs == "B":
                        bb.append(f"{c}-{b}")
                    if vo == "C" and vs == "C":
                        cc.append(f"{c}-{b}")
            if not o_all:
                continue
            fx[sz] = {"open": round(sum(o_all) / len(o_all), 3), "set": round(sum(s_all) / len(s_all), 3), "flip": flip,
                      "brood_both": bb, "crown_both": cc}
            md.append(f"| {sz} | {pct(sum(o_all) / len(o_all))} | {pct(sum(s_all) / len(s_all))} | {len(flip)} | {len(bb)} | {len(cc)} |")
        md.append("")
        for sz in fx:
            md.append(f"- {sz}: the Brood wins open but the Crown wins set: {', '.join(fx[sz]['flip']) or 'none'}. "
                      f"The Brood wins both: {', '.join(fx[sz]['brood_both']) or 'none'}.")
        # by Crown composition
        md.append("\n| Crown composition | " + " | ".join(f"open {sz} | set {sz}" for sz in sizes) + " |")
        md.append("|---|" + "---|---|" * len(sizes))
        for c in bl.CROWN:
            line = [c]
            for sz in sizes:
                for g in ("open", "set"):
                    sc = [r["score"] for b in bl.BROOD for r in cl.get((c, b, sz, g), [])]
                    line.append(pct(sum(sc) / len(sc)) if sc else "")
            md.append("| " + " | ".join(line) + " |")
        out["fighting_or_numbers"] = fx
    open(a.md, "w").write("\n".join(md) + "\n")
    json.dump(out, open(a.json, "w"), indent=1, sort_keys=True)
    print(f"wrote {a.md}, {a.json}")


if __name__ == "__main__":
    main()
