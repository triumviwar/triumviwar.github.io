#!/usr/bin/env python3
"""CROWN 1000, CLOCKWORK HALF (crown-1000-clockwork, docs/crown_1000_clockwork.md): blocks of 10 games of the Crown computer
(Hard OPTIMAL) against the Clockwork computer (Hard OPTIMAL) to 20:00, the same 10 map/seed/side pairings in every block,
each block run with a set of study switches (the change being tried, on top of the kept ones). A measuring tool.
    python3 tools/study/crown1000.py list [--vs clockwork|brood|crown]
    python3 tools/study/crown1000.py run BLOCK [--extra sw1,sw2] [--jobs 2] [--vs clockwork] [--end 1200] [--root COPY]
    python3 tools/study/crown1000.py report [--base B1,B2] [--blocks B3,B4]   (tables of every block; paired v the base)
Data: docs/crown_1000_clockwork/data/<BLOCK>/<tag>/ (result.json, story.txt); <BLOCK>/extra.txt holds its switches.
The tags are plan_matrix's (pm_cr-optimal_v_cw_<map>_r<round>), so tools/study/plan_matrix_report.py reads a block too.
The seeds and sides are plan_matrix's for the Crown's OPTIMAL row (the plan-matrix-crown study's games of these maps)."""
import os, sys, re, json, math, glob, csv, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm
import plan_matrix as pm
import plan_matrix_report as pr

MAPS = ["greenhold", "ashford_crossing", "mirewood", "frostfang", "cinder_steps"]
DOC = os.path.join(qm.ROOT, "docs/crown_1000_clockwork")
DATA = os.path.join(DOC, "data")


def games(vs="clockwork"):
    return [g for g in pm.queue("crown", MAPS, ["optimal"], [vs])]


def rows_of(block, cut=1200):
    d = os.path.join(DATA, block)
    return pr.load(d, "crown", cut) if os.path.isdir(d) else []


def gkey(r):
    return (r["map"], r["r"])


def at(r, p, m, k):
    return pr.val(r, p, m, k)


def summary(rows):
    n = len(rows)
    if not n:
        return None
    surv = sum(r["res"] != "L" for r in rows)
    wol = sum(r["lead"] in ("W", "w") for r in rows)
    lr = [pr.lratio(r) for r in rows]
    defeats = [r["won_at"] for r in rows if r["res"] == "L"]
    def rat(m, k):
        return pr.ratio(rows, m, k)
    labs = [at(r, r["si"], 8, "workers") for r in rows]
    labs = [x for x in labs if x is not None]
    halls12 = [at(r, r["si"], 12, "halls") for r in rows]
    halls12 = [x for x in halls12 if x is not None]
    return {"n": n, "surv": surv, "wol": wol, "lr": sum(lr) / n, "score_x": math.exp(sum(lr) / n),
            "defeat_med": st.median(defeats) if defeats else None, "inc8": rat(8, "income"), "inc12": rat(12, "income"),
            "army8": rat(8, "army"), "army12": rat(12, "army"), "labs8": sum(labs) / len(labs) if labs else None,
            "halls12": sum(halls12) / len(halls12) if halls12 else None}


def paired(rows, base_rows_list):
    """each game of `rows` against the mean log score of the same game over the base blocks' runs"""
    bl = {}
    for brs in base_rows_list:
        for r in brs:
            bl.setdefault(gkey(r), []).append(pr.lratio(r))
    d = [pr.lratio(r) - sum(bl[gkey(r)]) / len(bl[gkey(r)]) for r in rows if gkey(r) in bl]
    if not d:
        return None
    t = None
    if len(d) > 2 and st.stdev(d) > 0:
        t = (sum(d) / len(d)) / (st.stdev(d) / math.sqrt(len(d)))
    return {"n": len(d), "up": sum(x > 0.05 for x in d), "down": sum(x < -0.05 for x in d), "d": sum(d) / len(d),
            "x": math.exp(sum(d) / len(d)), "t": t}


def fmt(x, f="%.2f"):
    return "" if x is None else f % x


def report(base, blocks):
    base_rows = [rows_of(b) for b in base]
    base12 = [rows_of(b, 720) for b in base]
    out = []
    P = out.append
    P("| block | switches | games | survived | won or led | score x (Crown/Cw) | v base x (t, up/down) | 12:00 score x / v base | income 8:00 | 12:00 "
      "| army 8:00 | 12:00 | labourers 8:00 | halls 12:00 | median defeat |")
    P("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    csvrows = []
    for b in blocks:
        rows = rows_of(b)
        s = summary(rows)
        if not s:
            continue
        ex = open(os.path.join(DATA, b, "extra.txt")).read().strip().replace("\n", " ") if os.path.exists(os.path.join(DATA, b, "extra.txt")) else ""
        p = paired(rows, base_rows) if b not in base else None
        pv = "" if not p else "x%.2f (t %s, %d/%d)" % (p["x"], fmt(p["t"], "%.1f"), p["up"], p["down"])
        r12 = rows_of(b, 720)
        s12 = summary(r12)
        p12 = paired(r12, base12) if b not in base else None
        pv12 = "x%.2f" % s12["score_x"] + ("" if not p12 else " / x%.2f (t %s)" % (p12["x"], fmt(p12["t"], "%.1f")))
        P("| %s | %s | %d | %d | %d | %.2f | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (
            b, ex or "-", s["n"], s["surv"], s["wol"], s["score_x"], pv, pv12, fmt(s["inc8"]), fmt(s["inc12"]), fmt(s["army8"]),
            fmt(s["army12"]), fmt(s["labs8"], "%.1f"), fmt(s["halls12"], "%.1f"), pr.mmss(s["defeat_med"])))
        csvrows.append([b, ex, s["n"], s["surv"], s["wol"], "%.3f" % s["score_x"], "" if not p else "%.3f" % p["x"],
                        "" if not p or p["t"] is None else "%.2f" % p["t"], "%.3f" % s12["score_x"],
                        "" if not p12 else "%.3f" % p12["x"], "" if not p12 or p12["t"] is None else "%.2f" % p12["t"], fmt(s["inc8"]), fmt(s["inc12"]), fmt(s["army8"]),
                        fmt(s["army12"]), fmt(s["labs8"], "%.1f"), fmt(s["halls12"], "%.1f"), pr.mmss(s["defeat_med"])])
    return out, csvrows


def per_game(block):
    rows = rows_of(block)
    out = []
    for r in sorted(rows, key=gkey):
        out.append("%-18s r%d %s%s end %s  score x%.2f  inc8 %s army8 %s labs8 %s halls12 %s plan %s" % (
            r["map"], r["r"], r["res"], r["lead"], pr.mmss(r["won_at"] or r["end"]), math.exp(pr.lratio(r)),
            at(r, r["si"], 8, "income"), at(r, r["si"], 8, "army"), at(r, r["si"], 8, "workers"),
            at(r, r["si"], 12, "halls"), ",".join(p for _, p in r["picks"][r["si"]])))
    return out


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    cmd = sys.argv[1]
    vs = arg("--vs", "clockwork")
    if cmd == "list":
        for g in games(vs):
            print(g)
    elif cmd == "run":
        block = sys.argv[2]
        extra = [x for x in arg("--extra", "").split(",") if x]
        dd = os.path.join(DATA, block)
        os.makedirs(dd, exist_ok=True)
        root = os.path.abspath(arg("--root", qm.ROOT))
        kept = re.search(r"const KEPT := (\{.*\})", open(os.path.join(root, "scripts/ai_crown_v_clock.gd")).read())
        kept = ",".join(k for k, v in json.loads(kept.group(1)).items() if v) if kept else ""
        with open(os.path.join(dd, "extra.txt"), "w") as f:
            f.write(",".join(extra) + ("" if vs == "clockwork" else " (v %s)" % vs) + "\n" + "kept: " + kept + "\n")
        out = os.path.abspath(arg("--out", "/tmp/c1000_out/" + block))
        gl = games(vs)
        qm.RUN_ROOT = os.path.abspath(arg("--root", qm.ROOT))     # (a copy of the repo to run, so editing goes on meanwhile)
        with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
            for t in ex.map(lambda g: qm.run_one(g, out, int(arg("--end", "1200")), dd, extra), gl):
                print("done", t, flush=True)
    elif cmd == "report":
        blocks = [x for x in arg("--blocks", "").split(",") if x] or sorted(os.listdir(DATA))
        base = [x for x in arg("--base", "b00").split(",") if x]
        out, csvrows = report(base, blocks)
        print("\n".join(out))
        if "--csv" in sys.argv:
            with open(arg("--csv", ""), "w", newline="") as f:
                w = csv.writer(f)
                w.writerow(["block", "switches", "games", "survived", "won_or_led", "score_x", "v_base_x", "v_base_t", "score12_x", "v_base12_x", "v_base12_t",
                            "income8", "income12", "army8", "army12", "labourers8", "halls12", "median_defeat"])
                w.writerows(csvrows)
    elif cmd == "games":
        print("\n".join(per_game(sys.argv[2])))
