#!/usr/bin/env python3
"""WR1000, THE BROOD MIRROR (wr1000-brood-mirror, docs/wr1000_brood_mirror.md): blocks of 10 games of the Brood computer
(Hard OPTIMAL) against the Brood computer (Hard OPTIMAL), to 20:00, on the SAME 10 map/seed pairings every block (the 6
parity maps of ai-opponent-review, then 4 of them again with other seeds), so blocks compare game by game. A measuring tool:
it changes no rule; the coaching changes are study switches passed to every game of a block (`--extra a,b`).
    python3 tools/study/wr1000_brood_mirror.py list
    python3 tools/study/wr1000_brood_mirror.py run BLOCK [--extra sw1,sw2] [--jobs 2] [--end 1200]
    python3 tools/study/wr1000_brood_mirror.py report [BLOCK ...] [--games]
    python3 tools/study/wr1000_brood_mirror.py csv
Both seats are the same computer, so a game's "g" is P1's (spot A's) ln score ratio: (income earned + 2 x army) P1 / P2 at
20:00 or at the defeat, the beaten side's score counted a quarter. A mirror is measured by how DECISIVE it is, not by who
wins: decided (a side beaten by 20:00), |g| at 20:00, the side ahead at 12:00 that goes on to win or lead (closes it out),
comebacks, the median minute of the defeats; and the spot edge: P1's record and mean g."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = qm.PARITY_MAPS   # greenhold, dune_sea, frostfang, ashford_crossing, hollowfen, cinder_steps
DATA = os.path.join(qm.ROOT, "docs/wr1000_brood_mirror/data")


def queue():
    out = []
    for k in range(10):
        m = MAPS[k % len(MAPS)]
        r = k // len(MAPS)
        seed = 12100 + 97 * r + 11 * MAPS.index(m)
        tag = "wbm_%s_r%d" % (m, r)
        out.append((tag, m, seed, [("brood", "optimal", 0), ("brood", "optimal", 1)]))
    return out


def one(d, cut=1200):
    f = os.path.join(d, "result.json")
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    tag = os.path.basename(d)
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
        res = "W" if winner == 0 else "L"          # P1's view
    else:
        res = "w" if sc[0] > 1.1 * sc[1] else ("l" if sc[1] > 1.1 * sc[0] else "=")

    def last(p, mn):
        for k in range(mn, -1, -1):
            if (p, k) in at:
                return at[(p, k)]
        return None

    def gat(mn):
        a, b = last(0, mn), last(1, mn)
        if not a or not b:
            return None
        return math.log(max(1.0, a["income"] + 2 * a["army"]) / max(1.0, b["income"] + 2 * b["army"]))

    def ratio(key, mn):
        a, b = at.get((0, mn)), at.get((1, mn))
        if not a or not b or not b.get(key):
            return None
        return a[key] / b[key]
    g12 = gat(12)
    # the side ahead at 12:00 (by 10% or more): did it win or lead at the end (closed it out)? (None: even at 12:00)
    lead12 = None if g12 is None or abs(g12) < 0.0953 else (0 if g12 > 0 else 1)
    endside = 0 if res in ("W", "w") else (1 if res in ("L", "l") else None)
    closed = None if lead12 is None else (endside == lead12)
    comeback = None if lead12 is None else (endside is not None and endside != lead12)
    def side_at(p, mn, k):
        x = last(p, mn)
        return x.get(k) if x else None
    return {"tag": tag, "res": res, "end": end, "g": gv, "absg": abs(gv), "sc": sc, "decided": winner >= 0,
            "beaten": end if winner >= 0 else None, "g8": gat(8), "g12": g12, "g14": gat(14), "lead12": lead12,
            "closed": closed, "comeback": comeback, "inc8": ratio("income", 8), "inc12": ratio("income", 12),
            "army8": ratio("army", 8), "army12": ratio("army", 12),
            "halls12": [side_at(0, 12, "halls"), side_at(1, 12, "halls")],
            "maws12": [side_at(0, 12, "maws"), side_at(1, 12, "maws")],
            "lost20": [side_at(0, 20, "lost"), side_at(1, 20, "lost")],
            "picks": [[x.get("pick") for x in sorted(g.get("reads", []), key=lambda x: x["t"]) if x["p"] == p and "pick" in x] for p in (0, 1)],
            "version": g.get("version", "")}


def block(name):
    if "+" in name:
        parts = [block(x) for x in name.split("+")]
        rows = {}
        for t in parts[0]:
            xs = [p[t] for p in parts if t in p]
            r = dict(xs[0])
            for k in ("g", "absg", "g8", "g12", "g14"):
                v = [x[k] for x in xs if x[k] is not None]
                r[k] = sum(v) / len(v) if v else None
            r["decided"] = sum(1 for x in xs if x["decided"]) / len(xs)
            rows[t] = r
        return rows
    rows = {}
    for d in sorted(glob.glob(os.path.join(DATA, name, "wbm_*"))):
        x = one(d)
        if x:
            rows[x["tag"]] = x
    return rows


def summary(name, rows, base=None):
    v = list(rows.values())
    n = len(v)
    mean = lambda k: (lambda a: sum(a) / len(a) if a else None)([x[k] for x in v if x[k] is not None])
    bt = [x["beaten"] for x in v if x.get("beaten")]
    leads = [x for x in v if x.get("lead12") is not None]
    halls = [h for x in v for h in (x.get("halls12") or []) if h is not None]
    s = {"block": name, "n": n, "decided": sum(float(x["decided"]) for x in v),
         "absg": mean("absg"), "g": mean("g"), "g14": mean("g14"), "absg14": (lambda a: sum(a) / len(a) if a else None)([abs(x["g14"]) for x in v if x["g14"] is not None]),
         "p1": "%d-%d-%d" % (sum(1 for x in v if x["res"] in ("W", "w")), sum(1 for x in v if x["res"] == "="), sum(1 for x in v if x["res"] in ("L", "l"))),
         "p1won": sum(1 for x in v if x["res"] == "W"), "p2won": sum(1 for x in v if x["res"] == "L"),
         "lead12": len(leads), "closed": sum(1 for x in leads if x["closed"]), "comeback": sum(1 for x in leads if x["comeback"]),
         "beat_med": st.median(bt) if bt else None, "halls12": sum(halls) / len(halls) if halls else None}
    if base is not None:
        ds = [rows[t]["absg"] - base[t]["absg"] for t in rows if t in base]
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
        qm.KEEP_GREP = "Brood"
        qm.LOG_DIR = os.path.abspath(arg("--logs", "/tmp/wbm_logs/" + name))
        out = os.path.abspath(arg("--out", "/tmp/wbm_out/" + name))
        end = int(arg("--end", "1200"))
        with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
            for t in ex.map(lambda g: qm.run_one(g, out, end, dd, extra), queue()):
                print("done", t, flush=True)
    elif cmd in ("report", "csv"):
        names = [x for x in sys.argv[2:] if not x.startswith("--") and x != arg("--base", None)]
        if cmd == "csv" or not names:
            names = sorted(os.path.basename(d) for d in glob.glob(os.path.join(DATA, "b*")))
        base = arg("--base", None)
        brow = block(base) if base else None
        hdr = "| block | switches | n | decided | mean abs g | mean abs g14 | P1 W/=/L (P1 g) | led at 12:00 / closed / comeback | median defeat | halls 12 | v base d abs g (t) | better/worse |"
        lines = [hdr, "|" + "---|" * 12]
        for n in ([base] if base else []) + names:
            exf = os.path.join(DATA, n, "extra.txt")
            ex = open(exf).read().strip() if os.path.exists(exf) else ""
            s = summary(n, block(n), brow if n != base else None)
            dt = "%+.2f (%.1f)" % (s["d"], s["t"]) if "d" in s else ""
            bw = "%d/%d" % (s["better"], s["worse"]) if "d" in s else ""
            lines.append("| %s | %s | %d | %g | %s | %s | %s (%+.2f) | %d / %d / %d | %s | %s | %s | %s |" % (
                n, ex or "-", s["n"], s["decided"], f2(s["absg"]), f2(s["absg14"]), s["p1"], s["g"] or 0, s["lead12"],
                s["closed"], s["comeback"], mmss(s["beat_med"]), f2(s["halls12"]), dt, bw))
        txt = "\n".join(lines)
        if cmd == "csv":
            open(os.path.join(os.path.dirname(DATA), "blocks.md"), "w").write(txt + "\n")
        print(txt)
        if "--games" in sys.argv:
            for n in ([base] if base else []) + names:
                print("\n" + n)
                for t, x in sorted(block(n).items()):
                    print("  %-24s %s %5s g %+.2f g12 %s g14 %s halls12 %s maws12 %s %s" % (
                        t, x["res"], mmss(x["end"]), x["g"], f2(x["g12"]), f2(x["g14"]), x["halls12"], x["maws12"],
                        " | ".join("/".join(p for p in ps if p) for ps in x["picks"])))
    else:
        print(__doc__)
