#!/usr/bin/env python3
"""WIN RATES 2026-11-26, THE BROOD MIRROR (job winrate-brood-mirror, docs/winrate_2026_11_26_brood_mirror.md).
A measuring tool: it changes no rule and no AI.

Hard OPTIMAL Brood v Hard OPTIMAL Brood, every game to 20:00 (a defeat ends it sooner), on the six parity maps
(qa_matches.PARITY_MAPS), 30 games a cell, the same 30 in every arm and in the other three winrate-2026-11-26 jobs:
  game i (0..29): seed 1126001 + i, map PARITY_MAPS[i % 6], spot (i // 6) % 2.
In a mirror both sides are the Brood, so "spot" decides which PLAYER stands on spot A: spot 0 = player 1 on spot A (the
map's own order), spot 1 = the match switch `spotswap` (player 1 on spot B, player 2 on spot A). "Our" side for g is the
Brood on spot A, so player order and the spot can be told apart (the P1 split below).
Arms: default (main as it is) and nerf (`farmaw:2.0`: the far Rootmaw pays x2.0, not x2.2; here on both sides).

    python3 tools/study/winrate_1126_brood_mirror.py list
    python3 tools/study/winrate_1126_brood_mirror.py run ARM [--jobs 2] [--only i,j,..]
    python3 tools/study/winrate_1126_brood_mirror.py report        (the markdown tables of the doc)
Data: docs/winrate_2026_11_26/data/brood_mirror/<arm>/<tag>/ (result.json, story.txt).
Score = income earned + 2 x army at the bell or the defeat, a beaten side's score counted a quarter (plan_matrix_report /
ai_lessons); g = ln(score A / score B); "led" = 10% ahead at the bell."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = qm.PARITY_MAPS
DATA = os.path.join(qm.ROOT, "docs/winrate_2026_11_26/data/brood_mirror")
ARMS = {"default": [], "nerf": ["farmaw:2.0"]}
N = 30
END = 1200


def games():
    out = []
    for i in range(N):
        m = MAPS[i % 6]
        spot = (i // 6) % 2
        tag = "g%02d_%s_s%d" % (i, m, spot)
        out.append((i, tag, m, 1126001 + i, spot))
    return out


def run(arm, jobs, only=None):
    dd = os.path.join(DATA, arm)
    os.makedirs(dd, exist_ok=True)
    with open(os.path.join(dd, "extra.txt"), "w") as f:
        f.write(" ".join(ARMS[arm]) + "\n")
    out = "/tmp/claude-0/wr1126_out/" + arm
    gl = [g for g in games() if only is None or g[0] in only]

    def go(g):
        i, tag, m, seed, spot = g
        ex = list(ARMS[arm]) + (["spotswap"] if spot == 1 else [])
        slots = [("brood", "optimal", 0), ("brood", "optimal", 1)]
        return qm.run_one((tag, m, seed, slots), out, END, dd, ex)
    with ThreadPoolExecutor(jobs) as ex:
        for t in ex.map(go, gl):
            print("done", arm, t, flush=True)


def at_or_last(at, p, mn):
    for k in range(mn, -1, -1):
        if (p, k) in at:
            return at[(p, k)]
    return None


def one(d):
    f = os.path.join(d, "result.json")
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    tag = os.path.basename(d)
    spot = int(tag[-1])
    a = 1 if spot == 1 else 0          # the player index on spot A
    b = 1 - a
    at = {(x["p"], int(round(x["t"] / 60))): x for x in g["minutes"]}
    end, winner, fin = g["end"], g["winner"], g["final"]
    if end > END:
        mm = END // 60
        if (0, mm) in at and (1, mm) in at:
            fin = [at[(0, mm)], at[(1, mm)]]
        end, winner = END, -1
    if not g.get("over"):
        winner = -1
    sc = [x["income"] + 2 * x["army"] for x in fin]
    sa = sc[a] * (0.25 if winner == b else 1.0)
    sb = sc[b] * (0.25 if winner == a else 1.0)
    gv = math.log(max(1.0, sa) / max(1.0, sb))
    if winner >= 0:
        res = "W" if winner == a else "L"
    else:
        res = "w" if sc[a] > 1.1 * sc[b] else ("l" if sc[b] > 1.1 * sc[a] else "=")

    def val(p, key, mn):
        x = at_or_last(at, p, mn)
        return x.get(key) if x else None
    r = {"tag": tag, "i": int(tag[1:3]), "map": g["map"], "spot": spot, "res": res, "end": end, "g": gv,
         "decided": winner >= 0, "p1a": a == 0}
    for mn in (8, 12, 16):
        for key, k in (("income", "inc"), ("army", "army")):
            r["%s%d_a" % (k, mn)] = val(a, key, mn)
            r["%s%d_b" % (k, mn)] = val(b, key, mn)
    for mn in (12, 20):
        r["halls%d_a" % mn] = val(a, "halls", mn)
        r["halls%d_b" % mn] = val(b, "halls", mn)
    return r


def arm_rows(arm):
    rows = {}
    for d in sorted(glob.glob(os.path.join(DATA, arm, "g*"))):
        x = one(d)
        if x:
            rows[x["i"]] = x
    return rows


def tstat(v):
    if len(v) < 2:
        return 0.0
    sd = st.stdev(v)
    return (sum(v) / len(v)) / (sd / math.sqrt(len(v))) if sd > 0 else 0.0


def mean(v):
    v = [x for x in v if x is not None]
    return sum(v) / len(v) if v else None


def fmt(v, f="%.0f"):
    return "-" if v is None else f % v


def report():
    R = {a: arm_rows(a) for a in ARMS}
    print("## The table (spot-A Brood v spot-B Brood)\n")
    print("| arm | games | A won | A led | even | B led | B won | A won or led | B won or led | decided | median minute (decided) | mean g (t) |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for arm, rows in R.items():
        c = {k: sum(1 for x in rows.values() if x["res"] == k) for k in "Ww=lL"}
        dm = [x["end"] / 60 for x in rows.values() if x["decided"]]
        gs = [x["g"] for x in rows.values()]
        print("| %s | %d | %d | %d | %d | %d | %d | %d | %d | %d | %s | %+.2f (%.1f) |" % (
            arm, len(rows), c["W"], c["w"], c["="], c["l"], c["L"], c["W"] + c["w"], c["L"] + c["l"], len(dm),
            fmt(st.median(dm) if dm else None, "%.1f"), mean(gs) or 0.0, tstat(gs)))
    d, n = R["default"], R["nerf"]
    common = sorted(set(d) & set(n))
    if len(common) >= 2:
        ds = [n[i]["g"] - d[i]["g"] for i in common]
        print("\nNerf v default, the same %d games: g difference %+.2f (t %.1f), spot A better in %d, worse in %d (more than 0.05)." % (
            len(common), mean(ds), tstat(ds), sum(1 for x in ds if x > 0.05), sum(1 for x in ds if x < -0.05)))
        # how far apart the two sides end (|g|) and how long the games last, paired
        ad = [abs(n[i]["g"]) - abs(d[i]["g"]) for i in common]
        ln = [n[i]["end"] - d[i]["end"] for i in common]
        print("How far apart the two sides end (|g|): %+.2f (t %.1f). Game length: %+.0f s (t %.1f)." % (mean(ad), tstat(ad), mean(ln), tstat(ln)))
    print("\n## Income and army (each side, mean; a side beaten sooner counts its last minute)\n")
    print("| arm | income 8:00 A / B | 12:00 A / B | 16:00 A / B | army 8:00 A / B | 12:00 A / B | 16:00 A / B | halls 12:00 A / B | 20:00 A / B |")
    print("|---|---|---|---|---|---|---|---|---|")
    for arm, rows in R.items():
        m = lambda k: fmt(mean([x[k] for x in rows.values()]))
        h = lambda k: fmt(mean([x[k] for x in rows.values()]), "%.1f")
        print("| %s | %s / %s | %s / %s | %s / %s | %s / %s | %s / %s | %s / %s | %s / %s | %s / %s |" % (
            arm, m("inc8_a"), m("inc8_b"), m("inc12_a"), m("inc12_b"), m("inc16_a"), m("inc16_b"),
            m("army8_a"), m("army8_b"), m("army12_a"), m("army12_b"), m("army16_a"), m("army16_b"),
            h("halls12_a"), h("halls12_b"), h("halls20_a"), h("halls20_b")))
    print("\n## Spot A v spot B, and player 1 v player 2\n")
    print("| arm | spot A won or led | spot B won or led | mean g (t) | P1 won or led | P2 won or led | P1 on spot A: A won or led | P2 on spot A: A won or led |")
    print("|---|---|---|---|---|---|---|---|")
    for arm, rows in R.items():
        xs = list(rows.values())
        aw = sum(1 for x in xs if x["res"] in "Ww")
        bw = sum(1 for x in xs if x["res"] in "lL")
        p1 = sum(1 for x in xs if (x["res"] in "Ww" and x["p1a"]) or (x["res"] in "lL" and not x["p1a"]))
        p2 = sum(1 for x in xs if (x["res"] in "lL" and x["p1a"]) or (x["res"] in "Ww" and not x["p1a"]))
        s0 = [x for x in xs if x["p1a"]]
        s1 = [x for x in xs if not x["p1a"]]
        gs = [x["g"] for x in xs]
        print("| %s | %d | %d | %+.2f (%.1f) | %d | %d | %d of %d | %d of %d |" % (
            arm, aw, bw, mean(gs) or 0.0, tstat(gs), p1, p2, sum(1 for x in s0 if x["res"] in "Ww"), len(s0),
            sum(1 for x in s1 if x["res"] in "Ww"), len(s1)))
    print("\n## Every game\n")
    print("| # | map | P1 on | default | min | g | nerf | min | g |")
    print("|---|---|---|---|---|---|---|---|---|")
    for g in games():
        i = g[0]
        a, b = d.get(i), n.get(i)
        cell = lambda x: ("-", "-", "-") if not x else (x["res"], "%.1f" % (x["end"] / 60), "%+.2f" % x["g"])
        print("| %d | %s | %s | %s | %s | %s | %s | %s | %s |" % ((i, g[2], "A" if g[4] == 0 else "B") + cell(a) + cell(b)))
    print("\n(W = spot A beat B, w = A 10% ahead at the bell, = even, l = B ahead, L = B beat A)")


if __name__ == "__main__":
    arg = lambda k, dflt: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else dflt
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "list":
        for g in games():
            print(*g)
    elif cmd == "run":
        only = arg("--only", "")
        run(sys.argv[2], int(arg("--jobs", "2")), [int(x) for x in only.split(",")] if only else None)
    elif cmd == "report":
        report()
    else:
        print(__doc__)
