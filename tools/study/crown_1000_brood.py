#!/usr/bin/env python3
"""CROWN 1000, THE BROOD HALF (crown-1000-brood, docs/crown_1000_brood.md): blocks of 10 games of the Crown computer (Hard
OPTIMAL) against the Brood computer (Hard OPTIMAL), to 20:00, on the SAME 10 map/seed/side pairings every block (5 maps x 2
rounds, the start spots swapped), so blocks compare game by game. A measuring tool: it changes no rule; the coaching
changes are study switches passed to every game of a block (`--extra a,b`).
    python3 tools/study/crown_1000_brood.py list
    python3 tools/study/crown_1000_brood.py run BLOCK [--extra sw1,sw2] [--jobs 2] [--end 1200] [--root DIR]
    python3 tools/study/crown_1000_brood.py report [--base BLOCK] [BLOCK ...]
Data: docs/crown_1000_brood/data/<BLOCK>/<tag>/ (result.json, story.txt); the switches of a block in
docs/crown_1000_brood/data/<BLOCK>/extra.txt. Game score = (income earned + 2 x army) Crown / Brood at the bell or the
defeat, a beaten Crown's score counted a quarter (plan_matrix_report's rule); g = ln(score ratio). A block's numbers:
mean g, survived (not beaten by 20:00), won or led, median minute of the defeats; against a base block: the paired mean
difference of g with its t, and the sign count."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = ["greenhold", "ashford_crossing", "mirewood", "frostfang", "cinder_steps"]
DATA = os.path.join(qm.ROOT, "docs/crown_1000_brood/data")


def queue():
    out = []
    for mi, m in enumerate(MAPS):
        for r in (0, 1):
            seed = 9100 + 97 * r + 11 * mi + 3
            swap = (r + mi) % 2 == 1
            me, foe = ("crown", "optimal"), ("brood", "optimal")
            s1, s2 = (foe, me) if swap else (me, foe)
            tag = "c1k_%s_r%d" % (m, r)
            out.append((tag, m, seed, [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
    return out


def crown_side(g):
    for i, s in enumerate(g["slots"]):
        if (s.get("faction") if isinstance(s, dict) else s[0]) == "crown":
            return i
    return 0


def one(d, cut=1200):
    f = os.path.join(d, "result.json")
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    tag = os.path.basename(d)
    m = tag[4:].rsplit("_r", 1)[0]
    r = int(tag.rsplit("_r", 1)[1])
    si = 1 if (r + MAPS.index(m)) % 2 == 1 else 0
    oi = 1 - si
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
    s_me = sc[si] * (0.25 if winner == oi else 1.0)
    s_op = sc[oi] * (0.25 if winner == si else 1.0)
    gv = math.log(max(1.0, s_me) / max(1.0, s_op))
    if winner >= 0:
        res = "W" if winner == si else "L"
    else:
        res = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")

    def ratio(key, mn):
        a, b = at.get((si, mn)), at.get((oi, mn))
        if not a or not b or not b.get(key):
            return None
        return a[key] / b[key]

    halls12 = at.get((si, 12), {}).get("halls")
    picks = [x.get("pick") for x in sorted(g.get("reads", []), key=lambda x: x["t"]) if x["p"] == si and "pick" in x]
    return {"tag": tag, "map": m, "r": r, "si": si, "res": res, "end": end, "g": gv, "sc": sc,
            "beaten": end if res == "L" else None, "inc8": ratio("income", 8), "inc12": ratio("income", 12),
            "army8": ratio("army", 8), "army12": ratio("army", 12), "halls12": halls12, "picks": picks,
            "version": g.get("version", "")}


def block(name):
    rows = {}
    for d in sorted(glob.glob(os.path.join(DATA, name, "c1k_*"))):
        x = one(d)
        if x:
            rows[x["tag"]] = x
    return rows


def summary(name, rows, base=None):
    gs = [x["g"] for x in rows.values()]
    surv = sum(1 for x in rows.values() if x["res"] != "L")
    wl = sum(1 for x in rows.values() if x["res"] in ("W", "w"))
    bt = [x["beaten"] for x in rows.values() if x["beaten"]]
    mean = lambda k: (lambda v: sum(v) / len(v) if v else None)([x[k] for x in rows.values() if x[k] is not None])
    s = {"block": name, "n": len(rows), "g": sum(gs) / len(gs) if gs else 0.0, "surv": surv, "wl": wl,
         "beat_med": st.median(bt) if bt else None, "inc8": mean("inc8"), "inc12": mean("inc12"), "army8": mean("army8"),
         "army12": mean("army12"), "halls12": mean("halls12")}
    if base is not None:
        ds = [rows[t]["g"] - base[t]["g"] for t in rows if t in base]
        if len(ds) >= 2:
            md = sum(ds) / len(ds)
            sd = st.stdev(ds)
            s["d"] = md
            s["t"] = md / (sd / math.sqrt(len(ds))) if sd > 0 else 0.0
            s["better"] = sum(1 for x in ds if x > 0.05)
            s["worse"] = sum(1 for x in ds if x < -0.05)
    return s


def mmss(v):
    return "-" if v is None else "%d:%02d" % (int(v) // 60, int(v) % 60)


def f2(v):
    return "" if v is None else "%.2f" % v


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
        out = os.path.abspath(arg("--out", "/tmp/c1k_out/" + name))
        end = int(arg("--end", "1200"))
        with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
            for t in ex.map(lambda g: qm.run_one(g, out, end, dd, extra), queue()):
                print("done", t, flush=True)
    elif cmd == "csv":
        # blocks.csv: one row a block (its switches, its numbers, and against the block named in its base.txt if any)
        import csv as _csv
        out = os.path.join(os.path.dirname(DATA), "blocks.csv")
        with open(out, "w", newline="") as f:
            w = _csv.writer(f)
            w.writerow(["block", "switches", "base", "n", "mean_g", "survived", "won_led", "median_defeat_s", "inc8", "inc12",
                        "army8", "army12", "halls12", "d_v_base", "t_v_base", "better", "worse"])
            for d in sorted(glob.glob(os.path.join(DATA, "b*"))):
                n = os.path.basename(d)
                ex = open(os.path.join(d, "extra.txt")).read().strip() if os.path.exists(os.path.join(d, "extra.txt")) else ""
                b = open(os.path.join(d, "base.txt")).read().strip() if os.path.exists(os.path.join(d, "base.txt")) else ""
                s = summary(n, block(n), block(b) if b else None)
                r = lambda v, k=2: "" if v is None else round(v, k)
                w.writerow([n, ex, b, s["n"], r(s["g"]), s["surv"], s["wl"], r(s["beat_med"], 0), r(s["inc8"]), r(s["inc12"]),
                            r(s["army8"]), r(s["army12"]), r(s["halls12"]), r(s.get("d")), r(s.get("t")), s.get("better", ""),
                            s.get("worse", "")])
        print(out)
    elif cmd == "report":
        names = [x for x in sys.argv[2:] if not x.startswith("--") and x != arg("--base", None)]
        base = arg("--base", None)
        brow = block(base) if base else None
        print("| block | n | mean g | survived | won/led | median defeat | inc 8 | inc 12 | army 8 | army 12 | halls 12 | v base d (t) | better/worse |")
        print("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for n in ([base] if base else []) + names:
            s = summary(n, block(n), brow if n != base else None)
            dt = "%+.2f (%.1f)" % (s["d"], s["t"]) if "d" in s else ""
            bw = "%d/%d" % (s["better"], s["worse"]) if "d" in s else ""
            print("| %s | %d | %+.2f | %d | %d | %s | %s | %s | %s | %s | %s | %s | %s |" % (
                n, s["n"], s["g"], s["surv"], s["wl"], mmss(s["beat_med"]), f2(s["inc8"]), f2(s["inc12"]),
                f2(s["army8"]), f2(s["army12"]), f2(s["halls12"]), dt, bw))
        if "--games" in sys.argv:
            for n in ([base] if base else []) + names:
                print("\n" + n)
                for t, x in sorted(block(n).items()):
                    print("  %-28s %s %5s g %+.2f inc8 %s army8 %s army12 %s halls12 %s %s" % (
                        t, x["res"], mmss(x["end"]), x["g"], f2(x["inc8"]), f2(x["army8"]), f2(x["army12"]),
                        x["halls12"], "/".join(p for p in x["picks"] if p)))
    else:
        print(__doc__)
