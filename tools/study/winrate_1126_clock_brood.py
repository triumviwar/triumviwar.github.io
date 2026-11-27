#!/usr/bin/env python3
"""WIN RATES 2026-11-26, CLOCKWORK v BROOD (job winrate-clock-brood, docs/winrate_2026_11_26_clock_brood.md).
A measuring tool: it changes no rule and no AI. The method shared by the four winrate-2026-11-26 jobs:
Hard OPTIMAL v Hard OPTIMAL, every game to 20:00 (a defeat ends it sooner), the six parity maps, 30 games a cell;
game i (0..29): seed 1126001 + i, map PARITY_MAPS[i % 6], spot (i // 6) % 2 (spot 0 = the Clockwork in slot 0 = start
spot A; spot 1 = the Brood in slot 0, the Clockwork on spot B). Every arm plays the same 30 games.
Arms: default (main as it is) and nerf (the match switch farmaw:2.0: the far Rootmaw pays x2.0, not x2.2).
"Our" side for g is the Clockwork.
    python3 tools/study/winrate_1126_clock_brood.py list
    python3 tools/study/winrate_1126_clock_brood.py run ARM [--jobs 2] [--first N] [--only i,j]
    python3 tools/study/winrate_1126_clock_brood.py table [ARM ...]      (the report's markdown tables)
Data: docs/winrate_2026_11_26/data/clock_brood/<arm>/<tag>/ (result.json, story.txt).
Score = income earned + 2 x army at the bell or the defeat, a beaten side's score counted a quarter; led = 10% ahead."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = qm.PARITY_MAPS
DATA = os.path.join(qm.ROOT, "docs/winrate_2026_11_26/data/clock_brood")
ME, FOE = "clockwork", "brood"
ARMS = {"default": [], "nerf": ["farmaw:2.0"]}
N = 30
END = 1200


def games():
    out = []
    for i in range(N):
        m = MAPS[i % 6]
        spot = (i // 6) % 2
        seed = 1126001 + i
        me, foe = (ME, "optimal"), (FOE, "optimal")
        s1, s2 = (me, foe) if spot == 0 else (foe, me)
        tag = "g%02d_%s_s%d" % (i, m, spot)
        out.append((tag, m, seed, [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
    return out


def one(d):
    f = os.path.join(d, "result.json")
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    tag = os.path.basename(d)
    i = int(tag[1:3])
    spot = int(tag[-1])
    si = 0 if spot == 0 else 1           # the Clockwork's player index
    oi = 1 - si
    at = {}
    for x in g["minutes"]:
        at[(x["p"], int(round(x["t"] / 60)))] = x
    end, winner, fin = g["end"], g["winner"], g["final"]
    if end > END:
        mm = END // 60
        if (0, mm) in at and (1, mm) in at:
            fin = [at[(0, mm)], at[(1, mm)]]
        end, winner = END, -1
    sc = [x["income"] + 2 * x["army"] for x in fin]
    s_me = sc[si] * (0.25 if winner == oi else 1.0)
    s_op = sc[oi] * (0.25 if winner == si else 1.0)
    gv = math.log(max(1.0, s_me) / max(1.0, s_op))
    if winner >= 0:
        res = "W" if winner == si else "L"
    else:
        res = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")

    def val(p, mn, key):
        x = at.get((p, mn))
        if x is None:
            # a side beaten before: 0 from then on; a game ended before (the other side beaten): its last minute
            if winner >= 0 and mn * 60 > end:
                if p == winner:
                    last = [at[k] for k in at if k[0] == p]
                    x = max(last, key=lambda y: y["t"]) if last else None
                    return x[key] if x else None
                return 0
            return None
        return x[key]

    row = {"tag": tag, "i": i, "map": MAPS[i % 6], "spot": spot, "res": res, "end": end, "g": gv, "sc": sc,
           "winner": winner, "version": g.get("version", "")}
    for mn in (8, 12, 16):
        row["inc%d" % mn] = (val(si, mn, "income"), val(oi, mn, "income"))
        row["army%d" % mn] = (val(si, mn, "army"), val(oi, mn, "army"))
    for mn in (12, 20):
        row["halls%d" % mn] = (val(si, mn, "halls"), val(oi, mn, "halls"))
    return row


def arm_rows(arm):
    rows = {}
    for d in sorted(glob.glob(os.path.join(DATA, arm, "g*"))):
        x = one(d)
        if x:
            rows[x["i"]] = x
    return rows


def mean(v):
    v = [x for x in v if x is not None]
    return sum(v) / len(v) if v else None


def tstat(v):
    if len(v) < 2:
        return None
    sd = st.stdev(v)
    return (sum(v) / len(v)) / (sd / math.sqrt(len(v))) if sd > 0 else 0.0


def counts(rows):
    c = {k: sum(1 for x in rows if x["res"] == k) for k in "Ww=lL"}
    dec = sorted(x["end"] / 60.0 for x in rows if x["res"] in "WL")
    return c, (st.median(dec) if dec else None)


def k(v, d=0):
    return "-" if v is None else ("{:,.%df}" % d).format(v)


def table(arms):
    out = []
    data = {a: arm_rows(a) for a in arms}
    out.append("| arm | games | Clockwork won | Clockwork led | even | Brood led | Brood won | Clockwork won or led | Brood won or led | median minute decided | mean g (t) |")
    out.append("|---|---|---|---|---|---|---|---|---|---|---|")
    for a in arms:
        rows = list(data[a].values())
        if not rows:
            continue
        c, md = counts(rows)
        gs = [x["g"] for x in rows]
        t = tstat(gs)
        out.append("| %s | %d | %d | %d | %d | %d | %d | %d | %d | %s | %+.2f (%s) |" % (
            a, len(rows), c["W"], c["w"], c["="], c["l"], c["L"], c["W"] + c["w"], c["L"] + c["l"],
            "-" if md is None else "%.1f" % md, mean(gs), "-" if t is None else "%.1f" % t))
    out.append("")
    out.append("Means, Clockwork / Brood (a side beaten counts 0 after its defeat):")
    out.append("")
    out.append("| arm | income 8:00 | income 12:00 | income 16:00 | army 8:00 | army 12:00 | army 16:00 | halls 12:00 | halls 20:00 |")
    out.append("|---|---|---|---|---|---|---|---|---|")
    for a in arms:
        rows = list(data[a].values())
        if not rows:
            continue
        cells = []
        for key in ("inc8", "inc12", "inc16", "army8", "army12", "army16"):
            cells.append("%s / %s" % (k(mean([x[key][0] for x in rows])), k(mean([x[key][1] for x in rows]))))
        for key in ("halls12", "halls20"):
            cells.append("%s / %s" % (k(mean([x[key][0] for x in rows]), 1), k(mean([x[key][1] for x in rows]), 1)))
        out.append("| %s | %s |" % (a, " | ".join(cells)))
    out.append("")
    out.append("By start spot (the Clockwork on spot A = slot 0, on spot B = slot 1):")
    out.append("")
    out.append("| arm | Clockwork's spot | games | Clockwork won or led | even | Brood won or led | mean g |")
    out.append("|---|---|---|---|---|---|---|")
    for a in arms:
        for sp in (0, 1):
            rows = [x for x in data[a].values() if x["spot"] == sp]
            if not rows:
                continue
            c, _ = counts(rows)
            out.append("| %s | %s | %d | %d | %d | %d | %+.2f |" % (a, "AB"[sp], len(rows), c["W"] + c["w"], c["="],
                                                                   c["L"] + c["l"], mean([x["g"] for x in rows])))
    # (the shared seed rule puts games 0-5, 12-17, 24-29 on spot A: 18 A, 12 B; the share of each spot weighted evenly)
    out.append("")
    for a in arms:
        sh = []
        for sp in (0, 1):
            rows = [x for x in data[a].values() if x["spot"] == sp]
            if rows:
                c, _ = counts(rows)
                sh.append((c["W"] + c["w"]) / len(rows))
        if len(sh) == 2:
            out.append("- %s, spots weighted evenly: the Clockwork won or led %.0f%% of games." % (a, 50 * (sh[0] + sh[1])))
    if "default" in arms and "nerf" in arms:
        b, n = data["default"], data["nerf"]
        common = sorted(set(b) & set(n))
        if len(common) >= 2:
            ds = [n[i]["g"] - b[i]["g"] for i in common]
            t = tstat(ds)
            out.append("")
            out.append("Nerf v default, the same games (%d pairs): mean change in g (Clockwork side) %+.2f, t %s; the Clockwork better in %d, worse in %d (by more than 0.05)." % (
                len(common), sum(ds) / len(ds), "-" if t is None else "%.1f" % t,
                sum(1 for x in ds if x > 0.05), sum(1 for x in ds if x < -0.05)))
    out.append("")
    out.append("By map (Clockwork won or led / Brood won or led):")
    out.append("")
    out.append("| map | " + " | ".join(arms) + " |")
    out.append("|---|" + "---|" * len(arms))
    for m in MAPS:
        cells = []
        for a in arms:
            rows = [x for x in data[a].values() if x["map"] == m]
            c, _ = counts(rows)
            cells.append("%d / %d of %d" % (c["W"] + c["w"], c["L"] + c["l"], len(rows)))
        out.append("| %s | %s |" % (m, " | ".join(cells)))
    return "\n".join(out)


def games_list(arm):
    for i, x in sorted(arm_rows(arm).items()):
        print("%-28s %s %5.1f g %+.2f sc %s / %s" % (x["tag"], x["res"], x["end"] / 60.0, x["g"], k(x["sc"][x["spot"]]), k(x["sc"][1 - x["spot"]])))


if __name__ == "__main__":
    arg = lambda kk, d: sys.argv[sys.argv.index(kk) + 1] if kk in sys.argv else d
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "list":
        for g in games():
            print(*g)
    elif cmd == "run":
        arm = sys.argv[2]
        dd = os.path.join(DATA, arm)
        os.makedirs(dd, exist_ok=True)
        with open(os.path.join(dd, "extra.txt"), "w") as f:
            f.write(" ".join(ARMS[arm]) + "\n")
        out = "/tmp/claude-0/wr1126_cb_" + arm
        gl = games()
        if "--only" in sys.argv:
            keep = {int(x) for x in arg("--only", "").split(",")}
            gl = [g for j, g in enumerate(gl) if j in keep]
        gl = gl[:int(arg("--first", str(len(gl))))]
        with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
            for t in ex.map(lambda g: qm.run_one(g, out, END, dd, list(ARMS[arm])), gl):
                print("done", arm, t, flush=True)
    elif cmd == "table":
        print(table([a for a in sys.argv[2:]] or ["default", "nerf"]))
    elif cmd == "games":
        games_list(sys.argv[2])
    else:
        print(__doc__)
