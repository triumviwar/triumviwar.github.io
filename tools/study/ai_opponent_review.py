#!/usr/bin/env python3
"""AI OPPONENT REVIEW (ai-opponent-review, docs/ai_opponent_review.md): a measuring tool.
    python3 tools/study/ai_opponent_review.py list
    python3 tools/study/ai_opponent_review.py run OUT [--data DATA] [--jobs 2] [--only sanity|bench0|matrix0|bench1|matrix1] [--root DIR] [--logs DIR]
Queue, in order (a run cut short still has every cell once):
  sanity : the benchmark players against each other (good v novice, good v average, average v novice), each faction once;
  bench0 : every benchmark faction x strength (novice, average, good) x computer faction x level (easy, normal, hard, the
           computer on its OPTIMAL plan), once, on a rotating map of the parity six, sides alternating;
  matrix0: Hard OPTIMAL v Hard OPTIMAL, the six pairings (nine matchups with the mirrors) on the parity six maps, round 0
           (the same tags and seeds as qa_matches.base / docs/winrate_2026_11_17.md);
  matrix1: round 1 of the matrix (the sides swapped);
  bench1 : the bench again, the next map, the sides swapped.
The matrix to 20:00, the benchmark games to 15:00. Done games (DATA/<tag>/result.json) are skipped."""
import os, sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

FACS = ["crown", "brood", "clockwork"]
SH = qm.SHORT
STRENGTHS = ["novice", "average", "good"]
LEVELS = ["easy", "normal", "hard"]
MAPS = qm.PARITY_MAPS
END = 1200          # the matrix (as the 2026-11-17 study's long games)
BENCH_END = 900     # the benchmark games: decided or clearly led by 15:00 (a quarter of an hour is a full game for most players)


def bench(r):
    out = []
    k = 0
    for bf in FACS:
        for st in STRENGTHS:
            for cf in FACS:
                for lv in LEVELS:
                    m = MAPS[(k + r * 3) % len(MAPS)]
                    seed = 9100 + 211 * r + k
                    me = (bf, "balanced", 0, st)
                    foe = (cf, "optimal", 1, lv)
                    swap = (k + r) % 2 == 1
                    s1, s2 = (foe, me) if swap else (me, foe)
                    tag = "bench_%s%s_v_%s%s_%s_r%d" % (SH[bf], st, SH[cf], lv, m, r)
                    out.append((tag, m, seed, [(s1[0], s1[1], 0, s1[3]), (s2[0], s2[1], 1, s2[3])]))
                    k += 1
    return out


def sanity():
    out = []
    k = 0
    for f in FACS:
        for a, b in (("good", "novice"), ("good", "average"), ("average", "novice")):
            o = FACS[(FACS.index(f) + 1 + k) % 3]
            m = MAPS[k % len(MAPS)]
            s1, s2 = (f, "balanced", 0, a), (o, "balanced", 1, b)
            if k % 2:
                s1, s2 = (o, "balanced", 0, b), (f, "balanced", 1, a)
            tag = "sanity_%s%s_v_%s%s_%s" % (SH[f], a, SH[o], b, m)
            out.append((tag, m, 9900 + k, [s1, s2]))
            k += 1
    return out


def matrix(r):
    return [g for g in qm.base(r) if g[1] in MAPS]


def fix_cells(name):
    """(the blunder fixes, measured) the bench0 games a fix touches, the same tags, seeds and sides, run on the fixed code"""
    if name == "levelgrubs":
        return [g for g in bench(0) if "_v_breasy_" in g[0] or "_v_brnormal_" in g[0]]
    if name == "ridersquad":
        # the Hard Crown OPTIMAL rides its Horsemen into every Brood: the matrix's Crown v Brood games, both rounds
        return [g for g in matrix(0) + matrix(1) if g[0].split("_")[-2] == "crbr"]
    return []


def queue(only=""):
    if only.startswith("fix:"):
        return fix_cells(only[4:])
    parts = {"sanity": sanity(), "bench0": bench(0), "matrix0": matrix(0), "bench1": bench(1), "matrix1": matrix(1)}
    if only:
        return parts[only]
    return parts["sanity"] + parts["bench0"] + parts["matrix0"] + parts["matrix1"] + parts["bench1"]


def run_one(g, out, data):
    tag, m, seed, slots = g
    spec = ",".join("/".join(str(x) for x in s) for s in slots)
    # qa_matches.run_one builds its slot spec from 3-tuples: ours (4 fields: faction/plan/side/who) goes last and wins
    return qm.run_one((tag, m, seed, []), out, END if tag.startswith("base_") else BENCH_END, data, ["slots:" + spec])


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if len(sys.argv) < 2 or sys.argv[1] not in ("list", "run"):
        print(__doc__)
        sys.exit(1)
    gl = queue(arg("--only", ""))
    if sys.argv[1] == "list":
        for g in gl:
            print(g[0], g[1], g[2], g[3])
        print(len(gl), "games")
        sys.exit(0)
    out = os.path.abspath(sys.argv[2])
    if "--logs" in sys.argv:
        qm.LOG_DIR = os.path.abspath(arg("--logs", ""))      # (the match logs, for the blunder hunt)
    if "--root" in sys.argv:
        qm.RUN_ROOT = os.path.abspath(arg("--root", qm.ROOT))      # (a frozen copy of the game: code edited meanwhile can't leak in)
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/ai_opponent_review/data")))
    print("%d games" % len(gl), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda g: run_one(g, out, data), gl):
            print("done", t, flush=True)
