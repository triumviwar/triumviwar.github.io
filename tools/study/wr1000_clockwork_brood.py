#!/usr/bin/env python3
"""WR1000, THE CLOCKWORK V THE BROOD (wr1000-clockwork-brood, docs/wr1000_clockwork_brood.md): the owner 2026-11-22 01:29,
a fresh win-rate study as "1000 over 10s" (six jobs, one a pairing). Blocks of 10 games of the Clockwork computer (Hard
OPTIMAL) against the Brood computer (Hard OPTIMAL), to 20:00, on the SAME 10 map/seed/side games every block (the 6 parity
maps of ai-opponent-review, 4 of them twice with the start spots swapped), so blocks compare game by game. Copied from
crown_1000_brood.py; the score is the Clockwork's: g = ln(Clockwork / Brood).
    python3 tools/study/wr1000_clockwork_brood.py list
    python3 tools/study/wr1000_clockwork_brood.py run BLOCK [--extra sw1,sw2] [--jobs 2] [--end 1200] [--logs DIR]
    python3 tools/study/wr1000_clockwork_brood.py report [--base BLOCK] [BLOCK ...] [--games]
    python3 tools/study/wr1000_clockwork_brood.py csv
Data: docs/wr1000_clockwork_brood/data/<BLOCK>/<tag>/ (result.json, story.txt, cwlog.txt); the block's switches in
extra.txt. Game score = (income earned + 2 x army) Clockwork / Brood at the bell or the defeat, a beaten side's score
counted a quarter; res W won, w led (10%+ ahead at 20:00), = even, l behind, L lost."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = list(qm.PARITY_MAPS)
DATA = os.path.join(qm.ROOT, "docs/wr1000_clockwork_brood/data")
ME, OPP = "clockwork", "brood"


def games():
    # 10 games: the 6 maps, then the first 4 again; the start spots alternate, flipped on the second pass
    out = []
    for i in range(10):
        mi, r = i % 6, i // 6
        swap = (i + r) % 2 == 1
        out.append((MAPS[mi], r, 11300 + 37 * i, swap))
    return out


def queue():
    out = []
    for m, r, seed, swap in games():
        me, foe = (ME, "optimal"), (OPP, "optimal")
        s1, s2 = (foe, me) if swap else (me, foe)
        out.append(("wkb_%s_r%d" % (m, r), m, seed, [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
    return out


def my_side(g):
    for i, s in enumerate(g["slots"]):
        if (s.get("faction") if isinstance(s, dict) else s[0]) == ME:
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
    si = my_side(g)
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
    ohalls12 = at.get((oi, 12), {}).get("halls")
    # (a steadier second measure: the score ratio at 14:00, before most defeats; the last minute of a side beaten sooner)
    def at_or_last(p, mn):
        for k in range(mn, -1, -1):
            if (p, k) in at:
                return at[(p, k)]
        return None
    a14, b14 = at_or_last(si, 14), at_or_last(oi, 14)
    g14 = math.log(max(1.0, a14["income"] + 2 * a14["army"]) / max(1.0, b14["income"] + 2 * b14["army"])) if a14 and b14 else None
    picks = [x.get("pick") for x in sorted(g.get("reads", []), key=lambda x: x["t"]) if x["p"] == si and "pick" in x]
    return {"tag": tag, "map": m, "r": r, "si": si, "res": res, "end": end, "g": gv, "sc": sc,
            "beaten": end if res == "L" else None, "inc8": ratio("income", 8), "inc12": ratio("income", 12),
            "army8": ratio("army", 8), "army12": ratio("army", 12), "halls12": halls12, "ohalls12": ohalls12, "g14": g14, "picks": picks,
            "version": g.get("version", "")}


def block(name):
    if "+" in name:
        # a pooled base: several blocks of the same code, each game's numbers the mean of its runs
        parts = [block(x) for x in name.split("+")]
        rows = {}
        for t in parts[0]:
            xs = [p[t] for p in parts if t in p]
            r = dict(xs[0])
            for k in ("g", "g14", "inc8", "inc12", "army8", "army12", "halls12"):
                v = [x[k] for x in xs if x[k] is not None]
                r[k] = sum(v) / len(v) if v else None
            r["resl"] = [x["res"] for x in xs]
            r["res"] = "L" if sum(1 for x in xs if x["res"] == "L") * 2 > len(xs) else ("W" if all(x["res"] == "W" for x in xs) else "=")
            bt = [x["beaten"] for x in xs if x["beaten"]]
            r["beaten"] = st.median(bt) if bt and r["res"] == "L" else None
            rows[t] = r
        return rows
    rows = {}
    for d in sorted(glob.glob(os.path.join(DATA, name, "wkb_*"))):
        x = one(d)
        if x:
            rows[x["tag"]] = x
    return rows


def summary(name, rows, base=None):
    gs = [x["g"] for x in rows.values()]
    rl = lambda x: x.get("resl", [x["res"]])
    surv = sum(sum(1 for r in rl(x) if r != "L") / len(rl(x)) for x in rows.values())
    wl = sum(sum(1 for r in rl(x) if r in ("W", "w")) / len(rl(x)) for x in rows.values())
    won = sum(sum(1 for r in rl(x) if r == "W") / len(rl(x)) for x in rows.values())
    bt = [x["beaten"] for x in rows.values() if x["beaten"]]
    mean = lambda k: (lambda v: sum(v) / len(v) if v else None)([x[k] for x in rows.values() if x[k] is not None])
    med = lambda k: (lambda v: st.median(v) if v else None)([x[k] for x in rows.values() if x[k] is not None])
    s = {"block": name, "n": len(rows), "g": sum(gs) / len(gs) if gs else 0.0, "surv": surv, "wl": wl, "won": won,
         "beat_med": st.median(bt) if bt else None, "inc8": med("inc8"), "inc12": med("inc12"), "army8": med("army8"),
         "army12": med("army12"), "halls12": mean("halls12"), "g14": mean("g14")}
    if base is not None:
        ds = [rows[t]["g"] - base[t]["g"] for t in rows if t in base]
        if len(ds) >= 2:
            md = sum(ds) / len(ds)
            sd = st.stdev(ds)
            s["d"] = md
            s["t"] = md / (sd / math.sqrt(len(ds))) if sd > 0 else 0.0
            s["better"] = sum(1 for x in ds if x > 0.05)
            s["worse"] = sum(1 for x in ds if x < -0.05)
        d14 = [rows[t]["g14"] - base[t]["g14"] for t in rows if t in base and rows[t]["g14"] is not None and base[t]["g14"] is not None]
        if len(d14) >= 2:
            s["d14"] = sum(d14) / len(d14)
            sd = st.stdev(d14)
            s["t14"] = s["d14"] / (sd / math.sqrt(len(d14))) if sd > 0 else 0.0
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
        qm.KEEP_CW = True
        if arg("--logs", ""):
            qm.LOG_DIR = arg("--logs", "")
        out = os.path.abspath(arg("--out", "/tmp/wkb_out/" + name))
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
        print("| block | n | mean g | CW survived | CW won | CW won/led | median defeat | inc 8 (med) | inc 12 (med) | army 8 (med) | army 12 (med) | halls 12 | v base d (t) | better/worse | g 14:00 | v base d14 (t) |")
        print("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for n in ([base] if base else []) + names:
            s = summary(n, block(n), brow if n != base else None)
            dt = "%+.2f (%.1f)" % (s["d"], s["t"]) if "d" in s else ""
            bw = "%d/%d" % (s["better"], s["worse"]) if "d" in s else ""
            d14 = "%+.2f (%.1f)" % (s["d14"], s["t14"]) if "d14" in s else ""
            print("| %s | %d | %+.2f | %.1f | %.1f | %.1f | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (
                n, s["n"], s["g"], s["surv"], s["won"], s["wl"], mmss(s["beat_med"]), f2(s["inc8"]), f2(s["inc12"]),
                f2(s["army8"]), f2(s["army12"]), f2(s["halls12"]), dt, bw, f2(s["g14"]), d14))
        if "--games" in sys.argv:
            for n in ([base] if base else []) + names:
                print("\n" + n)
                for t, x in sorted(block(n).items()):
                    print("  %-28s %s %5s g %+.2f inc8 %s army8 %s army12 %s halls12 %s %s" % (
                        t, x["res"], mmss(x["end"]), x["g"], f2(x["inc8"]), f2(x["army8"]), f2(x["army12"]),
                        x["halls12"], "/".join(p for p in x["picks"] if p)))
    else:
        print(__doc__)
