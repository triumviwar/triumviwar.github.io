#!/usr/bin/env python3
"""THE CLOCKWORK'S FIGHT MICRO, the study (clockwork-micro, docs/clockwork_micro.md). Two halves:

1. THE BENCH (tools/bench_clockwork_micro.gd): equal-value set-piece fights, each part alone against the baseline.
    python3 tools/study/clockwork_micro.py bench NAME [--sets crown,brood,mirror] [--runs 3] [--extra a,b] [--jobs 2]
    python3 tools/study/clockwork_micro.py compare BASE NAME [NAME ...]      (paired by fight: the change, its t)
   Data: docs/clockwork_micro/bench/<NAME>.json (one file a set, joined), the switches in its "args".

2. REAL GAMES (tools/qa_match.gd, the method of tools/study/crown_micro.py): Hard OPTIMAL against Hard OPTIMAL to 20:00 on
   the six parity maps, 10 games a block (round 0 on all six, round 1 with the starts swapped on the first four), the
   Clockwork against the Crown, the Brood and itself, with and without the micro.
    python3 tools/study/clockwork_micro.py run BLOCK --opp crown|brood|clockwork [--extra cwmic:off] [--jobs 2]
    python3 tools/study/clockwork_micro.py report BLOCK [BLOCK ...]  (the win-rate table, the Clockwork's side)
   Data: docs/clockwork_micro/data/<BLOCK>/<tag>/ (result.json, story.txt, cwlog.txt).
   In the mirror the micro is on for the Clockwork of slot 0 only (`cwmicteam:0`, put in by `run`); "ours" is slot 0.
Game score = (income earned + 2 x army) ours / theirs at 20:00 or the defeat (a beaten side's score counted a quarter);
g = ln(score ratio). A measuring tool: it changes no rule."""
import os, sys, json, glob, math, subprocess, statistics as st
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, HERE)
BENCH = os.path.join(ROOT, "docs/clockwork_micro/bench")
DATA = os.path.join(ROOT, "docs/clockwork_micro/data")


def arg(k, d):
    return sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d


# ------------------------------------------------------------------ the bench

SETTINGS = {"real": ["tech:1", "down:0.3"]}


def bench_one(name, s, runs, extra, root):
    out = "/tmp/claude-0/cwmic_%s_%s.json" % (name, s)
    cmd = ["godot", "--headless", "--fixed-fps", "30", "--path", root, "--script", "res://tools/bench_clockwork_micro.gd", "--",
           "set:" + s, "runs:%d" % runs, "out:" + out, "cwmicteam:0"] + SETTINGS.get(s, []) + extra
    with open(out + ".log", "w") as f:
        subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT)
    return json.load(open(out)) if os.path.exists(out) else {"runs": []}


def bench(name):
    sets = arg("--sets", "crown,brood,mirror").split(",")
    extra = [x for x in arg("--extra", "").split(",") if x]
    runs = int(arg("--runs", "3"))
    root = os.path.abspath(arg("--root", ROOT))
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        parts = list(ex.map(lambda s: bench_one(name, s, runs, extra, root), sets))
    allr = []
    for p in parts:
        allr += p["runs"]
    os.makedirs(BENCH, exist_ok=True)
    f = os.path.join(BENCH, name + ".json")
    old = json.load(open(f))["runs"] if os.path.exists(f) and "--add" in sys.argv else []
    json.dump({"args": " ".join(extra), "sets": sets, "runs": old + allr}, open(f, "w"), indent=0)
    print(name, len(old + allr), "fights")


def load(name):
    d = json.load(open(os.path.join(BENCH, name + ".json")))
    return {(r["sc"], r["run"]): r for r in d["runs"]}, d.get("args", "")


def foe_group(sc):
    foe = sc.split("-")[2]
    size = sc.split("-")[1]
    g = "crown" if foe == "crown" else ("mirror" if foe == "cw" else "brood")
    return ("real " if size in ("M", "L") else "") + g


def paired(a, b, keys):
    ds = [b[k]["score"] - a[k]["score"] for k in keys]
    if len(ds) < 2:
        return 0.0, 0.0, len(ds)
    m = sum(ds) / len(ds)
    sd = st.stdev(ds)
    return m, (m / (sd / math.sqrt(len(ds))) if sd > 0 else 0.0), len(ds)


def kl(rows, keys):
    k = sum(rows[x]["killed"] for x in keys)
    l = sum(rows[x]["lost"] for x in keys)
    return k / max(1, l)


def compare():
    base, _ = load(sys.argv[2])
    print("| block | switches | group | n | score before | score after | change | t | k/l before | k/l after | micro |")
    print("|---|---|---|---|---|---|---|---|---|---|---|")
    for name in sys.argv[3:]:
        if name.startswith("--"):
            break
        rows, args = load(name)
        keys = [k for k in rows if k in base]
        groups = {}
        for k in keys:
            groups.setdefault(foe_group(k[0]), []).append(k)
        groups["ALL"] = keys
        for gname in sorted(groups, key=lambda x: (x == "ALL", x)):
            ks = groups[gname]
            m, t, n = paired(base, rows, ks)
            sb = sum(base[k]["score"] for k in ks) / len(ks)
            sa = sum(rows[k]["score"] for k in ks) / len(ks)
            mic = {}
            for k in ks:
                for c, v in rows[k].get("micro", {}).items():
                    mic[c.replace("cwmic_", "")] = mic.get(c.replace("cwmic_", ""), 0) + v
            print("| %s | %s | %s | %d | %+.2f | %+.2f | %+.3f | %.2f | %.2f | %.2f | %s |" % (
                name, args or "(none)", gname, n, sb, sa, m, t, kl(base, ks), kl(rows, ks),
                " ".join("%s %d" % (c, v) for c, v in sorted(mic.items()))))
        if "--sc" in sys.argv:
            for sc in sorted({k[0] for k in keys}):
                ks = [k for k in keys if k[0] == sc]
                m, t, n = paired(base, rows, ks)
                print("|  | | %s | %d | %+.2f | %+.2f | %+.3f | %.2f | | | |" % (sc, n, sum(base[k]["score"] for k in ks) / n,
                                                                       sum(rows[k]["score"] for k in ks) / n, m, t))


# ------------------------------------------------------------------ real games

MAPS = ["greenhold", "dune_sea", "frostfang", "ashford_crossing", "hollowfen", "cinder_steps"]
OPP_I = {"crown": 0, "brood": 1, "clockwork": 2}


def queue(opp):
    out = []
    for r in (0, 1):
        for mi, m in enumerate(MAPS):
            if r == 1 and mi >= 4:
                continue
            seed = 4100 + 97 * r + 11 * mi + 3 * OPP_I[opp] + 77
            swap = (r + mi) % 2 == 1 and opp != "clockwork"
            me, foe = ("clockwork", "optimal"), (opp, "optimal")
            s1, s2 = (foe, me) if swap else (me, foe)
            if opp == "clockwork" and (r + mi) % 2 == 1:
                tag = "cwm_%s_r%d" % (m, r)
                out.append((tag, m, seed, [(s1[0], s1[1], 1), (s2[0], s2[1], 0)]))     # (the start spots swapped)
                continue
            tag = "cwm_%s_r%d" % (m, r)
            out.append((tag, m, seed, [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
    return out


def our_side(g, opp):
    if opp == "clockwork":
        return 0
    for i, s in enumerate(g["slots"]):
        if (s.get("faction") if isinstance(s, dict) else s[0]) == "clockwork":
            return i
    return 0


def one(d, opp, cut=1200):
    f = os.path.join(d, "result.json")
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    si = our_side(g, opp)
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

    def last(p, mn):
        for k in range(mn, -1, -1):
            if (p, k) in at:
                return at[(p, k)]
        return None
    a14, b14 = last(si, 14), last(oi, 14)
    g14 = math.log(max(1.0, a14["income"] + 2 * a14["army"]) / max(1.0, b14["income"] + 2 * b14["army"])) if a14 and b14 else None
    a12, b12 = at.get((si, 12)), at.get((oi, 12))
    return {"tag": os.path.basename(d), "res": res, "end": end, "g": gv, "g14": g14,
            "army12": (a12["army"] / b12["army"]) if a12 and b12 and b12.get("army") else None,
            "beaten": end if res == "L" else None, "micro": g.get("cw_micro", {})}


def block(name, opp):
    rows = {}
    for d in sorted(glob.glob(os.path.join(DATA, name, "cwm_*"))):
        x = one(d, opp)
        if x:
            rows[x["tag"]] = x
    return rows


def run_games(name):
    import qa_matches as qm
    opp = arg("--opp", "crown")
    dd = os.path.join(DATA, name)
    os.makedirs(dd, exist_ok=True)
    extra = [x for x in arg("--extra", "").split(",") if x]
    if opp == "clockwork":
        extra.append("cwmicteam:0")
    with open(os.path.join(dd, "extra.txt"), "w") as f:
        f.write("opp:%s %s\n" % (opp, " ".join(extra)))
    qm.RUN_ROOT = os.path.abspath(arg("--root", qm.ROOT))
    qm.KEEP_CW = True
    out = os.path.abspath(arg("--out", "/tmp/claude-0/cwm_out/" + name))
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda g: qm.run_one(g, out, 1200, dd, extra), queue(opp)):
            print("done", t, flush=True)


def report():
    print("| block | switches | games | won | led | even | behind | lost | mean g | g at 14:00 | army 12:00 | defeats (min) |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for n in sys.argv[2:]:
        if n.startswith("--"):
            break
        ex = open(os.path.join(DATA, n.split("+")[0], "extra.txt")).read().strip()
        opp = ex.split()[0][4:]
        rows = {}
        for part in n.split("+"):
            for t, x in block(part, opp).items():
                rows[part + t] = x
        if not rows:
            continue
        c = {k: sum(1 for x in rows.values() if x["res"] == k) for k in "Ww=lL"}
        mean = lambda k: (lambda v: sum(v) / len(v) if v else 0.0)([x[k] for x in rows.values() if x[k] is not None])
        dm = sorted(x["beaten"] / 60.0 for x in rows.values() if x["beaten"])
        print("| %s | %s | %d | %d | %d | %d | %d | %d | %+.2f | %+.2f | %.2f | %s |" % (n, ex, len(rows), c["W"], c["w"], c["="],
              c["l"], c["L"], mean("g"), mean("g14"), mean("army12"), ", ".join("%.1f" % v for v in dm)))


def paired_games():
    a = sys.argv[2]
    ex = open(os.path.join(DATA, a, "extra.txt")).read().strip()
    opp = ex.split()[0][4:]
    ra = block(a, opp)
    for b in sys.argv[3:]:
        rb = block(b, opp)
        ks = [k for k in ra if k in rb]
        ds = [rb[k]["g"] - ra[k]["g"] for k in ks]
        d14 = [rb[k]["g14"] - ra[k]["g14"] for k in ks if rb[k]["g14"] is not None and ra[k]["g14"] is not None]
        t = lambda v: (sum(v) / len(v)) / (st.stdev(v) / math.sqrt(len(v))) if len(v) > 1 and st.stdev(v) > 0 else 0.0
        print("%s v %s: n %d  d g %+.2f (t %.2f, better %d worse %d)  d g14 %+.2f (t %.2f)" % (
            b, a, len(ks), sum(ds) / max(1, len(ds)), t(ds), sum(1 for x in ds if x > 0.05), sum(1 for x in ds if x < -0.05),
            sum(d14) / max(1, len(d14)), t(d14)))


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "bench":
        bench(sys.argv[2])
    elif cmd == "compare":
        compare()
    elif cmd == "run":
        run_games(sys.argv[2])
    elif cmd == "report":
        report()
    elif cmd == "paired":
        paired_games()
    else:
        print(__doc__)
