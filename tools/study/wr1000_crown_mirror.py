#!/usr/bin/env python3
"""WR1000, THE CROWN MIRROR (wr1000-crown-mirror, docs/wr1000_crown_mirror.md): blocks of 10 games of the Crown computer
(Hard OPTIMAL) against itself, to 20:00, on the SAME 10 map/seed games every block (the 6 parity maps, the first four twice
with another seed), so blocks compare game by game. A measuring tool: it changes no rule; the coaching changes are study
switches passed to every game of a block (`--extra a,b`).
    python3 tools/study/wr1000_crown_mirror.py list
    python3 tools/study/wr1000_crown_mirror.py run BLOCK [--extra sw1,sw2] [--jobs 2] [--end 1200] [--logs DIR]
    python3 tools/study/wr1000_crown_mirror.py report [--base BLOCK] [BLOCK ...] [--games]
    python3 tools/study/wr1000_crown_mirror.py csv
In a mirror both seats run the same code, so a block's mean score is about even by design. What a coaching change should
move is how DECISIVE the games are (the side ahead closes it out; the side behind fights back sensibly), not who wins:
  g      = ln(score of seat 1 (spot A) / score of seat 2 (spot B)) at 20:00 or the defeat, score = income earned + 2 x army,
           the beaten side's score counted a quarter (plan_matrix_report's rule); its sign is the spot edge;
  |g|    = how far apart the game ended (0 = dead even; a defeat ~ 1.4 or more);
  |g14|  = the same at 14:00 (steadier);
  decided  = a side beaten by 20:00;  apart = decided or 1.5x apart at 20:00;
  kept     = the side ahead at 12:00 (by 10%+) won or led at 20:00; turned = the side behind at 12:00 won or led at 20:00.
Data: docs/wr1000_crown_mirror/data/<BLOCK>/<tag>/ (result.json, story.txt, planlog.txt), the block's switches in
docs/wr1000_crown_mirror/data/<BLOCK>/extra.txt, its base in base.txt."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

PMAPS = ["greenhold", "dune_sea", "frostfang", "ashford_crossing", "hollowfen", "cinder_steps"]
DATA = os.path.join(qm.ROOT, "docs/wr1000_crown_mirror/data")


def queue():
    out = []
    for k in range(10):
        mi, r = k % 6, k // 6
        m = PMAPS[mi]
        seed = 12300 + 97 * r + 11 * mi
        tag = "wcm_%s_r%d" % (m, r)
        out.append((tag, m, seed, [("crown", "optimal", 0), ("crown", "optimal", 1)]))
    return out


def one(d, cut=1200):
    f = os.path.join(d, "result.json")
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    tag = os.path.basename(d)
    m = tag[4:].rsplit("_r", 1)[0]
    at = {}
    for x in g["minutes"]:
        at[(x["p"], int(round(x["t"] / 60)))] = x
    end, winner, fin = g["end"], g["winner"], g["final"]
    if end > cut:
        mm = cut // 60
        if (0, mm) in at and (1, mm) in at:
            fin = [at[(0, mm)], at[(1, mm)]]
        end, winner = cut, -1
    sc = [x["income"] + 2 * x["army"] for x in fin]
    s0 = sc[0] * (0.25 if winner == 1 else 1.0)
    s1 = sc[1] * (0.25 if winner == 0 else 1.0)
    gv = math.log(max(1.0, s0) / max(1.0, s1))
    if winner >= 0:
        res = "A" if winner == 0 else "B"     # spot A / spot B won outright
    else:
        res = "a" if sc[0] > 1.1 * sc[1] else ("b" if sc[1] > 1.1 * sc[0] else "=")

    def last(p, mn):
        for k in range(mn, -1, -1):
            if (p, k) in at:
                return at[(p, k)]
        return None

    def sg(mn):
        a, b = last(0, mn), last(1, mn)
        if not a or not b:
            return None
        return math.log(max(1.0, a["income"] + 2 * a["army"]) / max(1.0, b["income"] + 2 * b["army"]))

    def ratio(key, mn):
        a, b = at.get((0, mn)), at.get((1, mn))
        if not a or not b or not b.get(key):
            return None
        return a[key] / b[key]

    g12, g14 = sg(12), sg(14)
    lead12 = 0 if g12 is not None and g12 > math.log(1.1) else (1 if g12 is not None and g12 < -math.log(1.1) else -1)
    ahead20 = 0 if res in ("A", "a") else (1 if res in ("B", "b") else -1)
    halls12 = [at.get((p, 12), {}).get("halls") for p in (0, 1)]
    army12 = [at.get((p, 12), {}).get("army") for p in (0, 1)]
    lost12 = [at.get((p, 12), {}).get("bld_lost") for p in (0, 1)]
    picks = [[x.get("pick") for x in sorted(g.get("reads", []), key=lambda x: x["t"]) if x["p"] == p and "pick" in x]
             for p in (0, 1)]
    apart = winner >= 0 or abs(gv) >= math.log(1.5)
    return {"tag": tag, "map": m, "res": res, "end": end, "g": gv, "ag": abs(gv), "sc": sc, "g12": g12, "g14": g14,
            "ag14": abs(g14) if g14 is not None else None, "decided": winner >= 0, "apart": apart,
            "beaten": end if winner >= 0 else None, "lead12": lead12, "ahead20": ahead20,
            "kept": lead12 >= 0 and ahead20 == lead12, "turned": lead12 >= 0 and ahead20 == 1 - lead12,
            "inc8": ratio("income", 8), "inc12": ratio("income", 12), "army8": ratio("army", 8),
            "army12r": ratio("army", 12), "halls12": halls12, "army12": army12, "lost12": lost12, "picks": picks,
            "version": g.get("version", "")}


def block(name):
    if "+" in name:
        parts = [block(x) for x in name.split("+")]
        rows = {}
        for t in parts[0]:
            xs = [p[t] for p in parts if t in p]
            r = dict(xs[0])
            for k in ("g", "ag", "g14", "ag14", "g12", "inc8", "inc12", "army8", "army12r"):
                v = [x[k] for x in xs if x[k] is not None]
                r[k] = sum(v) / len(v) if v else None
            for k in ("decided", "apart", "kept", "turned"):
                r[k] = sum(1 for x in xs if x[k]) / len(xs)
            bt = [x["beaten"] for x in xs if x["beaten"]]
            r["beaten"] = st.median(bt) if bt else None
            rows[t] = r
        return rows
    rows = {}
    for d in sorted(glob.glob(os.path.join(DATA, name, "wcm_*"))):
        x = one(d)
        if x:
            rows[x["tag"]] = x
    return rows


def paired(rows, base, k):
    ds = [rows[t][k] - base[t][k] for t in rows if t in base and rows[t][k] is not None and base[t][k] is not None]
    if len(ds) < 2:
        return None
    md = sum(ds) / len(ds)
    sd = st.stdev(ds)
    return md, (md / (sd / math.sqrt(len(ds))) if sd > 0 else 0.0), sum(1 for x in ds if x > 0.05), sum(1 for x in ds if x < -0.05)


def summary(name, rows, base=None):
    n = len(rows)
    mean = lambda k: (lambda v: sum(v) / len(v) if v else None)([x[k] for x in rows.values() if x[k] is not None])
    cnt = lambda k: sum(float(x[k]) for x in rows.values())
    bt = [x["beaten"] for x in rows.values() if x["beaten"]]
    lead = sum(1 for x in rows.values() if x.get("lead12", -1) >= 0) if "+" not in name else None
    s = {"block": name, "n": n, "g": mean("g"), "ag": mean("ag"), "ag14": mean("ag14"), "decided": cnt("decided"),
         "apart": cnt("apart"), "kept": cnt("kept"), "turned": cnt("turned"), "lead12": lead,
         "beat_med": st.median(bt) if bt else None,
         "A": sum(1 for x in rows.values() if x["res"] in ("A", "a")), "B": sum(1 for x in rows.values() if x["res"] in ("B", "b")),
         "inc8": mean("inc8"), "army8": mean("army8"), "inc12": mean("inc12"), "army12r": mean("army12r")}
    if base is not None:
        s["d_ag"] = paired(rows, base, "ag")
        s["d_ag14"] = paired(rows, base, "ag14")
    return s


def mmss(v):
    return "-" if v is None else "%d:%02d" % (int(v) // 60, int(v) % 60)


def f2(v):
    return "" if v is None else "%.2f" % v


def fd(p):
    return "" if not p else "%+.2f (%.1f) %d/%d" % p


def fc(v):
    return ("%d" % v) if abs(v - round(v)) < 1e-6 else ("%.1f" % v)


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "list":
        for g in queue():
            print(*g)
    elif cmd == "run":
        name = sys.argv[2]
        dd = os.path.join(DATA, name)
        os.makedirs(dd, exist_ok=True)
        extra = [x for x in arg("--extra", "").split(",") if x]
        with open(os.path.join(dd, "extra.txt"), "w") as f:
            f.write(" ".join(extra) + "\n")
        qm.RUN_ROOT = os.path.abspath(arg("--root", qm.ROOT))
        qm.KEEP_GREP = "Crown's plan"
        qm.LOG_DIR = arg("--logs", "")
        out = os.path.abspath(arg("--out", "/tmp/wcm_out/" + name))
        end = int(arg("--end", "1200"))
        with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
            for t in ex.map(lambda g: qm.run_one(g, out, end, dd, extra), queue()):
                print("done", t, flush=True)
    elif cmd == "csv":
        import csv as _csv
        out = os.path.join(os.path.dirname(DATA), "blocks.csv")
        with open(out, "w", newline="") as f:
            w = _csv.writer(f)
            w.writerow(["block", "switches", "base", "n", "mean_g_spotA", "mean_abs_g", "mean_abs_g14", "decided", "apart",
                        "kept_lead", "turned", "median_defeat_s", "spotA_won_led", "spotB_won_led", "d_abs_g", "t_abs_g",
                        "d_abs_g14", "t_abs_g14"])
            for d in sorted(glob.glob(os.path.join(DATA, "b*"))):
                n = os.path.basename(d)
                rd = lambda fn: open(os.path.join(d, fn)).read().strip() if os.path.exists(os.path.join(d, fn)) else ""
                b = rd("base.txt")
                s = summary(n, block(n), block(b) if b else None)
                r = lambda v, k=2: "" if v is None else round(v, k)
                da, d14 = s.get("d_ag"), s.get("d_ag14")
                w.writerow([n, rd("extra.txt"), b, s["n"], r(s["g"]), r(s["ag"]), r(s["ag14"]), s["decided"], s["apart"],
                            s["kept"], s["turned"], r(s["beat_med"], 0), s["A"], s["B"], r(da[0]) if da else "",
                            r(da[1], 1) if da else "", r(d14[0]) if d14 else "", r(d14[1], 1) if d14 else ""])
        print(out)
    elif cmd == "report":
        base = arg("--base", None)
        names = [x for x in sys.argv[2:] if not x.startswith("--") and x != base]
        brow = block(base) if base else None
        print("| block | n | mean g (spot A) | mean abs g | abs g14 | decided | 1.5x apart | lead at 12 kept | turned | median defeat | A/B won-led | v base d abs g (t) b/w | d abs g14 (t) b/w |")
        print("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for n in ([base] if base else []) + names:
            s = summary(n, block(n), brow if n != base else None)
            print("| %s | %d | %+.2f | %.2f | %s | %s | %s | %s | %s | %s | %d/%d | %s | %s |" % (
                n, s["n"], s["g"] or 0, s["ag"] or 0, f2(s["ag14"]), fc(s["decided"]), fc(s["apart"]),
                fc(s["kept"]) + ("/%d" % s["lead12"] if s["lead12"] is not None else ""), fc(s["turned"]),
                mmss(s["beat_med"]), s["A"], s["B"], fd(s.get("d_ag")), fd(s.get("d_ag14"))))
        if "--games" in sys.argv:
            for n in ([base] if base else []) + names:
                print("\n" + n)
                for t, x in sorted(block(n).items()):
                    print("  %-26s %s %5s g %+.2f g12 %s g14 %s inc8 %s army8 %s army12 %s halls12 %s lost12 %s %s" % (
                        t, x["res"], mmss(x["end"]), x["g"], f2(x["g12"]), f2(x["g14"]), f2(x["inc8"]), f2(x["army8"]),
                        x.get("army12"), x.get("halls12"), x.get("lost12"),
                        " | ".join("/".join(p for p in pp if p) for pp in x.get("picks", [[], []]))))
    else:
        print(__doc__)
