#!/usr/bin/env python3
"""THE BATTLE MATRIX (job battle-matrix, docs/battle_matrix.md): every Crown composition against every Brood composition,
at three sizes, on four grounds, several seeds each, fought in tools/battle_lab.gd (no economy; each army its own
computer's fighting code; equal value).

  python3 tools/study/battle_lab.py jobs  [--sizes 600,1500,4000] [--grounds open] [--seeds 4] [--seed0 0]
                                          [--crown M,MC] [--brood R,S] > jobs.txt
  python3 tools/study/battle_lab.py run   jobs.txt [--workers 2] [--chunk 25] [--out docs/battle_matrix/data/rows.jsonl]
      (skips the fights already in the out file: a run can be stopped and started again)
  python3 tools/study/battle_lab.py report [--rows docs/battle_matrix/data/rows.jsonl] [--md docs/battle_matrix/tables.md]
"""
import argparse
import json
import math
import os
import subprocess
import sys
import tempfile
import time
from collections import defaultdict

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
GODOT = os.environ.get("GODOT", "/home/claude/godot/godot")
CROWN = ["M", "MC", "MCH", "MMo", "MCMo", "MH", "H", "D", "MD", "MO", "MB", "MMi", "CH"]
BROOD = ["R", "R3S1", "R1S1", "R1S3", "S", "B", "RSB", "TC", "TCS", "VC", "StC", "RSTd", "RSy"]
CLOCKWORK = ["K", "KW", "KN", "KP", "P", "Sp", "KSp", "KB", "Se", "KSe", "O", "CW", "KGW", "KPN"]
COMPS = {"crown": CROWN, "brood": BROOD, "clockwork": CLOCKWORK}
CROWN_NAMES = {
    "M": "Musketeers", "MC": "Musketeers + Field Cannons", "MCH": "the computer's wave (Musketeers, Cannons, Horsemen)",
    "MMo": "Musketeers + Mortars", "MCMo": "Musketeers + Cannons + Mortars", "MH": "Musketeers + Horsemen",
    "H": "Horsemen", "D": "Dragoons", "MD": "Musketeers + Dragoons", "MO": "Musketeers + Officers",
    "MB": "Musketeers + the band", "MMi": "Musketeers + a Missionary", "CH": "Cannons + Horsemen"}
BROOD_NAMES = {
    "R": "Raptors", "R3S1": "Raptors, a few Spitters (3:1)", "R1S1": "Raptors and Spitters (1:1)",
    "R1S3": "Spitters, a few Raptors (3:1)", "S": "Spitters", "B": "Brutes", "RSB": "Raptors, Spitters, Brutes",
    "TC": "Tyrant Challengers", "TCS": "Tyrant Challengers + Spitters", "VC": "Venom Challengers",
    "StC": "Storm Challengers (flyers)", "RSTd": "Raptors, Spitters, Mist Toads", "RSy": "Raptors and Spitters with the Tyrant Sire"}
CLOCKWORK_NAMES = {
    "K": "Clock Soldiers, no Winders", "KW": "Clock Soldiers + Winders", "KN": "Clock Soldiers + Netters",
    "KP": "Clock Soldiers + Pendulums", "P": "Pendulums", "Sp": "Springers", "KSp": "Clock Soldiers + Springers",
    "KB": "Clock Soldiers + Spring Ballistas", "Se": "Brass Serpents", "KSe": "Clock Soldiers + Brass Serpents",
    "O": "the air: Ticking Owls + Swifts", "CW": "the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)",
    "KGW": "Clock Soldiers + the Great Winder (no Winders)", "KPN": "Clock Soldiers + Pendulums + Netters"}
NAMES = {"crown": CROWN_NAMES, "brood": BROOD_NAMES, "clockwork": CLOCKWORK_NAMES}
SIZE_NAME = {-150: "at the supply cap (150 army supply each, late research)", 600: "early (600)", 1500: "mid (1,500)", 4000: "late (4,000)"}
GROUND_NAME = {"open": "open field", "set": "the set line (open ground, the Crown formed, guns up)", "block": "the set block (open ground, the Crown in a close block, guns up)", "choke": "a choke", "up": "a ramp, the Crown on top", "down": "a ramp, the Brood on top"}


def side(r):
    """(faction A, comp A, faction B, comp B) of a row (old rows: Crown v Brood)"""
    if "fa" in r:
        return (r["fa"], r["ca"], r["fb"], r["cb"])
    return ("crown", r["crown"], "brood", r["brood"])


def key(r):
    return side(r) + (int(r["size"]), r["ground"], int(r["seed"]))


def job_key(j):
    """a job line's key: five words = the old Crown v Brood line, seven = any two factions"""
    if len(j) == 5:
        return ("crown", j[0], "brood", j[1], int(j[2]), j[3], int(j[4]))
    return (j[0], j[1], j[2], j[3], int(j[4]), j[5], int(j[6]))


def load_rows(path):
    rows = []
    if os.path.exists(path):
        for ln in open(path):
            ln = ln.strip()
            if ln.startswith("{"):
                try:
                    rows.append(json.loads(ln))
                except json.JSONDecodeError:
                    pass
    return [r for r in rows if "err" not in r]


def cmd_jobs(a):
    sizes = [int(x) for x in a.sizes.split(",")]
    grounds = a.grounds.split(",")
    if a.fa:
        # (battle-matrix-all) any two factions: every comp of A against every comp of B (a mirror: each pairing once
        # each way round, so both spots are played)
        ca = a.ca.split(",") if a.ca else COMPS[a.fa]
        cb = a.cb.split(",") if a.cb else COMPS[a.fb]
        for g in grounds:
            for sz in sizes:
                for s in range(a.seed0, a.seed0 + a.seeds):
                    for c in ca:
                        for b in cb:
                            print(f"{a.fa} {c} {a.fb} {b} {sz} {g} {s}")
        return
    crown = a.crown.split(",") if a.crown else CROWN
    brood = a.brood.split(",") if a.brood else BROOD
    for g in grounds:
        for sz in sizes:
            for s in range(a.seed0, a.seed0 + a.seeds):
                for c in crown:
                    for b in brood:
                        print(f"{c} {b} {sz} {g} {s}")


def cmd_run(a):
    jobs = [ln.split() for ln in open(a.jobs) if ln.strip() and not ln.startswith("#")]
    out = os.path.abspath(a.out)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    done = {key(r) for r in load_rows(out)}
    todo = [j for j in jobs if job_key(j) not in done]
    print(f"{len(jobs)} jobs, {len(todo)} to do", flush=True)
    chunks = [todo[i:i + a.chunk] for i in range(0, len(todo), a.chunk)]
    tmp = tempfile.mkdtemp(prefix="battle_lab_")
    running = []
    t0 = time.time()
    n_done = 0
    while chunks or running:
        while chunks and len(running) < a.workers:
            ch = chunks.pop(0)
            jf = os.path.join(tmp, f"jobs_{len(chunks)}_{time.time_ns()}.txt")
            of = jf.replace("jobs_", "rows_").replace(".txt", ".jsonl")
            with open(jf, "w") as f:
                f.write("\n".join(" ".join(j) for j in ch) + "\n")
            cmd = [GODOT, "--headless", "--fixed-fps", "30", "--path", ROOT, "--script", "res://tools/battle_lab.gd", "--",
                   f"jobs:{jf}", f"out:{of}"] + (a.extra.split() if a.extra else [])
            p = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            running.append((p, of, len(ch), time.time()))
        time.sleep(2)
        for item in running[:]:
            p, of, n, ts = item
            if time.time() - ts > a.timeout:
                p.kill()
            if p.poll() is not None:
                running.remove(item)
                got = load_rows(of) if os.path.exists(of) else []
                with open(out, "a") as f:
                    for r in got:
                        f.write(json.dumps(r) + "\n")
                n_done += len(got)
                el = time.time() - t0
                print(f"chunk done: {len(got)}/{n} rows (exit {p.returncode}); {n_done}/{len(todo)} in {el / 60:.1f} min, "
                      f"~{(len(todo) - n_done) * el / max(1, n_done) / 60:.0f} min left", flush=True)


# ------------------------------------------------------------------ the report

def mean(xs):
    return sum(xs) / len(xs) if xs else float("nan")


def ci95(xs):
    """the mean and the half-width of its 95% interval (t with n - 1 degrees of freedom, roughly)"""
    n = len(xs)
    if n < 2:
        return mean(xs), float("nan")
    m = mean(xs)
    sd = math.sqrt(sum((x - m) ** 2 for x in xs) / (n - 1))
    t = {2: 12.7, 3: 4.3, 4: 3.18, 5: 2.78, 6: 2.57, 7: 2.45, 8: 2.36, 9: 2.31, 10: 2.26}.get(n, 2.0)
    return m, t * sd / math.sqrt(n)


def crown_won(r):
    return 1.0 if r["winner"] in ("crown", "crown_t") else (0.0 if r["winner"] in ("brood", "brood_t") else 0.5)


def cells(rows):
    c = defaultdict(list)
    for r in rows:
        c[(r["crown"], r["brood"], int(r["size"]), r["ground"])].append(r)
    return c


def verdict(m, h):
    """the cell's word: the Crown's share of the value lost in the fight (the score), with its interval"""
    if math.isnan(h):
        h = 0.5
    if m - h > 0.5:
        return "C"          # the Crown wins it, clearly
    if m + h < 0.5:
        return "B"
    return "="


def cmd_report(a):
    rows = load_rows(a.rows)
    cl = cells(rows)
    sizes = sorted({int(r["size"]) for r in rows})
    grounds = [g for g in ["open", "set", "block", "choke", "up", "down"] if any(r["ground"] == g for r in rows)]
    crown = [c for c in CROWN if any(r["crown"] == c for r in rows)]
    brood = [b for b in BROOD if any(r["brood"] == b for r in rows)]
    md = []
    summary = {"rows": len(rows), "cells": {}}
    md.append(f"# The battle matrix: tables\n\n{len(rows)} fights. Each cell: **the Crown's share of the value lost** in "
              f"the fight, as a percent (the Brood's losses over both sides' losses: 50 = an even trade, above 50 the Crown "
              f"traded better), then the Crown's wins out of the fights (a win = the other side has nothing left that fights, "
              f"or is clearly behind at the 3-minute bell). Bold: the Crown clearly ahead (the 95% interval above 50); "
              f"italic: the Brood clearly ahead; plain: not told apart from even.\n")
    for g in grounds:
        for sz in sizes:
            sub = [r for r in rows if r["ground"] == g and int(r["size"]) == sz]
            if not sub:
                continue
            md.append(f"\n## {GROUND_NAME[g]}, {SIZE_NAME.get(sz, sz)}\n")
            md.append("| Crown \\ Brood | " + " | ".join(brood) + " | row |")
            md.append("|---|" + "---|" * (len(brood) + 1))
            for c in crown:
                line = [f"**{c}**"]
                allsc = []
                for b in brood:
                    rs = cl.get((c, b, sz, g), [])
                    if not rs:
                        line.append("")
                        continue
                    sc = [r["score"] for r in rs]
                    allsc += sc
                    m, h = ci95(sc)
                    w = sum(crown_won(r) for r in rs)
                    v = verdict(m, h)
                    summary["cells"][f"{c}|{b}|{sz}|{g}"] = {"score": round(m, 3), "ci": round(h, 3) if not math.isnan(h) else None,
                        "n": len(rs), "crown_wins": w, "trade": round(mean([r["trade"] for r in rs]), 2), "v": v}
                    txt = f"{round(m * 100)} ({w:g}/{len(rs)})"
                    line.append(f"**{txt}**" if v == "C" else (f"*{txt}*" if v == "B" else txt))
                line.append(f"{round(mean(allsc) * 100)}" if allsc else "")
                md.append("| " + " | ".join(line) + " |")
            col = ["**column**"]
            for b in brood:
                sc = [r["score"] for r in sub if r["brood"] == b]
                col.append(f"{round(mean(sc) * 100)}" if sc else "")
            col.append("")
            md.append("| " + " | ".join(col) + " |")
    open(a.md, "w").write("\n".join(md) + "\n")
    json.dump(summary, open(a.summary, "w"), indent=1, sort_keys=True)
    print(f"wrote {a.md} and {a.summary}: {len(rows)} rows, {len(summary['cells'])} cells")


def main():
    ap = argparse.ArgumentParser()
    sp = ap.add_subparsers(dest="cmd")
    j = sp.add_parser("jobs")
    j.add_argument("--sizes", default="600,1500,4000")
    j.add_argument("--grounds", default="open")
    j.add_argument("--seeds", type=int, default=4)
    j.add_argument("--seed0", type=int, default=0)
    j.add_argument("--crown", default="")
    j.add_argument("--brood", default="")
    j.add_argument("--fa", default="", help="any two factions: side A's faction (then --fb, --ca, --cb)")
    j.add_argument("--fb", default="")
    j.add_argument("--ca", default="")
    j.add_argument("--cb", default="")
    r = sp.add_parser("run")
    r.add_argument("jobs")
    r.add_argument("--workers", type=int, default=os.cpu_count() or 2)
    r.add_argument("--chunk", type=int, default=25)
    r.add_argument("--timeout", type=float, default=3600.0)
    r.add_argument("--extra", default="", help="more lab arguments, e.g. \"wind:0.5\" (keep their rows in a file of their own)")
    r.add_argument("--out", default=os.path.join(ROOT, "docs/battle_matrix/data/rows.jsonl"))
    p = sp.add_parser("report")
    p.add_argument("--rows", default=os.path.join(ROOT, "docs/battle_matrix/data/rows.jsonl"))
    p.add_argument("--md", default=os.path.join(ROOT, "docs/battle_matrix/tables.md"))
    p.add_argument("--summary", default=os.path.join(ROOT, "docs/battle_matrix/data/cells.json"))
    a = ap.parse_args()
    {"jobs": cmd_jobs, "run": cmd_run, "report": cmd_report}.get(a.cmd, lambda _: ap.print_help())(a)


if __name__ == "__main__":
    main()
