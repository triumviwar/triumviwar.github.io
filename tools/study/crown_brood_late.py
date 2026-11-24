#!/usr/bin/env python3
"""(crown-brood-late, docs/crown_brood_late.md: crown_brood_fix.py with its own data folder docs/crown_brood_late/data; the same
10 games, the same seeds, as the wr1000 and crown-brood-fix Crown v Brood blocks.)
(crown-brood-fix, docs/crown_brood_fix.md: wr1000_crown_brood.py with its own data folder and --me / --opp for the
side checks; the same 10 games, the same seeds as the wr1000 crown-brood baseline for the Crown v the Brood.)
WIN RATE 1000 OVER 10s, CROWN v BROOD (wr1000-crown-brood, docs/wr1000_crown_brood.md; the method of
tools/study/crown_1000_brood.py): blocks of 10 games of the Crown computer (Hard OPTIMAL) against the Brood computer (Hard
OPTIMAL), to 20:00, on the SAME 10 map/seed/side pairings every block (the six parity maps of ai-opponent-review: round 0 on
all six, round 1 (the start spots swapped) on the first four; 5 games on each start spot), so blocks compare game by game. A measuring tool: it changes no rule; the coaching
changes are study switches passed to every game of a block (`--extra a,b`).
    python3 tools/study/wr1000_crown_brood.py list
    python3 tools/study/wr1000_crown_brood.py run BLOCK [--extra sw1,sw2] [--jobs 2] [--end 1200] [--root DIR]
    python3 tools/study/wr1000_crown_brood.py report [--base BLOCK] [BLOCK ...]
    python3 tools/study/wr1000_crown_brood.py results BLOCK[+BLOCK] ...   (the win-rate table: won/led/even/behind/lost)
Data: docs/wr1000_crown_brood/data/<BLOCK>/<tag>/ (result.json, story.txt); the switches of a block in
docs/wr1000_crown_brood/data/<BLOCK>/extra.txt. Game score = (income earned + 2 x army) Crown / Brood at the bell or the
defeat, a beaten Crown's score counted a quarter (plan_matrix_report's rule); g = ln(score ratio). A block's numbers:
mean g, survived (not beaten by 20:00), won or led, median minute of the defeats; against a base block: the paired mean
difference of g with its t, and the sign count."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = qm.PARITY_MAPS      # greenhold, dune_sea, frostfang, ashford_crossing, hollowfen, cinder_steps
DATA = os.path.join(qm.ROOT, "docs/crown_brood_late/data")
ME = "crown"     # (--me brood: the side checks Brood v Clockwork and the Brood mirror; ME is "our" side in g)


OPP = "brood"      # (--opp clockwork / crown: the check blocks of the other matchups, plan_matrix_crown's seeds)
OPP_I = {"crown": 0, "brood": 1, "clockwork": 2}


def queue():
    out = []
    for r in (0, 1):
        for mi, m in enumerate(MAPS):
            if r == 1 and mi >= 4:
                continue
            seed = 4100 + 97 * r + 11 * mi + 3 * OPP_I[OPP] + (0 if ME == "crown" else 50 + 7 * OPP_I[ME])
            swap = (r + mi) % 2 == 1
            me, foe = (ME, "optimal"), (OPP, "optimal")
            s1, s2 = (foe, me) if swap else (me, foe)
            tag = "wcb_%s_r%d" % (m, r)
            out.append((tag, m, seed, [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
    return out


def crown_side(g):
    # (the Crown's slot = its player index in "minutes")
    # (a mirror: "our" side is the one that was slot 0 in round 0's order, i.e. player index 0 when not swapped)
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
    si = crown_side(g)
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
            "army8": ratio("army", 8), "army12": ratio("army", 12), "halls12": halls12, "g14": g14, "picks": picks,
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
            r["res"] = "L" if sum(1 for x in xs if x["res"] == "L") * 2 > len(xs) else ("W" if all(x["res"] == "W" for x in xs) else "=")
            bt = [x["beaten"] for x in xs if x["beaten"]]
            r["beaten"] = st.median(bt) if bt and r["res"] == "L" else None
            rows[t] = r
        return rows
    rows = {}
    for d in sorted(glob.glob(os.path.join(DATA, name, "wcb_*"))):
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
         "army12": mean("army12"), "halls12": mean("halls12"), "g14": mean("g14")}
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
    OPP = arg("--opp", "brood")
    ME = arg("--me", "crown")
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
        qm.KEEP_GREP = "Crown's"
        out = os.path.abspath(arg("--out", "/tmp/cbl_out/" + name))
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
    elif cmd == "results":
        # (the win rate of every block: won / led / even / behind / lost at 20:00, as the job's summary table has it)
        print("| block | switches | games | won | led | even | behind | lost | mean g | g14 | inc 8 / 12 | army 8 / 12 | halls 12 | defeats (min) |")
        print("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        _vals = {sys.argv[i + 1] for i, x in enumerate(sys.argv[:-1]) if x.startswith("--")}
        for n in [x for x in sys.argv[2:] if not x.startswith("--") and x not in _vals]:
            rows = {}
            for part in n.split("+"):
                for t, x in block(part).items():
                    rows[part + t] = x
            s = summary(n, rows)
            c = {k: sum(1 for x in rows.values() if x["res"] == k) for k in "Ww=lL"}
            ex = " ".join(sorted(set(open(os.path.join(DATA, p, "extra.txt")).read().strip() for p in n.split("+")
                                     if os.path.exists(os.path.join(DATA, p, "extra.txt")))))
            dm = sorted(x["beaten"] / 60.0 for x in rows.values() if x["beaten"])
            print("| %s | %s | %d | %d | %d | %d | %d | %d | %+.2f | %+.2f | %s / %s | %s / %s | %s | %s |" % (
                n, ex or "(none)", len(rows), c["W"], c["w"], c["="], c["l"], c["L"], s["g"], s["g14"], f2(s["inc8"]),
                f2(s["inc12"]), f2(s["army8"]), f2(s["army12"]), "%.1f" % s["halls12"], ", ".join("%.1f" % v for v in dm)))
    elif cmd == "report":
        _vals = {sys.argv[i + 1] for i, x in enumerate(sys.argv[:-1]) if x.startswith("--")}
        names = [x for x in sys.argv[2:] if not x.startswith("--") and x not in _vals]
        base = arg("--base", None)
        brow = block(base) if base else None
        print("| block | n | mean g | survived | won/led | median defeat | inc 8 | inc 12 | army 8 | army 12 | halls 12 | v base d (t) | better/worse | g 14:00 | v base d14 (t) |")
        print("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for n in ([base] if base else []) + names:
            s = summary(n, block(n), brow if n != base else None)
            dt = "%+.2f (%.1f)" % (s["d"], s["t"]) if "d" in s else ""
            bw = "%d/%d" % (s["better"], s["worse"]) if "d" in s else ""
            d14 = "%+.2f (%.1f)" % (s["d14"], s["t14"]) if "d14" in s else ""
            print("| %s | %d | %+.2f | %d | %d | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (
                n, s["n"], s["g"], s["surv"], s["wl"], mmss(s["beat_med"]), f2(s["inc8"]), f2(s["inc12"]),
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
