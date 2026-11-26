#!/usr/bin/env python3
"""WIN RATES 2026-11-26, CROWN v BROOD (job winrate-crown-brood, docs/winrate_2026_11_26_crown_brood.md). A measuring
tool: it changes no rule and no AI.
The owner (2026-11-26): win rate tests after the battle tests' lessons (ai-lessons, 0.38.221), and the same with the
Rootmaw nerf (`farmaw:2.0`: the far Rootmaw pays x2.0 instead of x2.2, Defs.FOOD_BONUS 1.2 -> 1.0).
The method shared by the four winrate-1126 jobs: Hard OPTIMAL v Hard OPTIMAL to 20:00 (defeat ends it sooner), 30 games
a cell on the six parity maps: game i (0..29) has seed 1126001 + i, map PARITY_MAPS[i % 6], spot (i // 6) % 2 (spot 0:
the first faction of the pairing, here the Crown, in slot 0 = start spot A; spot 1: the Brood in slot 0). Every arm plays
the SAME 30 games.
    python3 tools/study/winrate_1126_crown_brood.py list
    python3 tools/study/winrate_1126_crown_brood.py run ARM [--jobs 2] [--end 1200]     (ARM: default | nerf)
    python3 tools/study/winrate_1126_crown_brood.py report [--games]
Data: docs/winrate_2026_11_26/data/crown_brood/<arm>/<tag>/ (result.json, story.txt).
Score = income earned + 2 x army at the bell or the defeat, a beaten side's score counted a quarter; g = ln(Crown score /
Brood score). At the bell: led = 10% ahead on score, else even. Halls at 20:00 = at the end (0 for a beaten side's last
minute if it had none)."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

PAIR = ("crown", "brood")
NAME = "crown_brood"
ARMS = {"default": [], "nerf": ["farmaw:2.0"]}
DATA = os.path.join(qm.ROOT, "docs/winrate_2026_11_26/data", NAME)
N = 30


def queue():
    out = []
    for i in range(N):
        m = qm.PARITY_MAPS[i % 6]
        spot = (i // 6) % 2
        a, b = (PAIR[0], "optimal"), (PAIR[1], "optimal")
        s1, s2 = (a, b) if spot == 0 else (b, a)
        tag = "g%02d_%s_s%d" % (i, m, spot)
        out.append((tag, m, 1126001 + i, [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
    return out


def one(d, cut=1200):
    f = os.path.join(d, "result.json")
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    tag = os.path.basename(d)
    spot = int(tag.rsplit("_s", 1)[1])
    # our side (the pairing's first faction): slot 0 on spot 0, slot 1 on spot 1 (in a mirror the slot decides)
    si = spot
    if PAIR[0] != PAIR[1]:
        for i, s in enumerate(g["slots"]):
            if (s.get("faction") if isinstance(s, dict) else s[0]) == PAIR[0]:
                si = i
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

    def val(p, mn, key):
        x = at.get((p, mn))
        return None if x is None else x.get(key)

    r = {"tag": tag, "map": tag.split("_", 1)[1].rsplit("_s", 1)[0], "spot": spot, "res": res, "end": end, "g": gv,
         "version": g.get("version", "")}
    for mn in (8, 12, 16):
        for k, key in (("inc", "income"), ("army", "army")):
            r["%s%d_me" % (k, mn)] = val(si, mn, key)
            r["%s%d_op" % (k, mn)] = val(oi, mn, key)
    r["halls12_me"], r["halls12_op"] = val(si, 12, "halls"), val(oi, 12, "halls")
    r["halls20_me"] = fin[si].get("halls") if winner != oi else 0
    r["halls20_op"] = fin[oi].get("halls") if winner != si else 0
    return r


def arm_rows(arm):
    rows = {}
    for d in sorted(glob.glob(os.path.join(DATA, arm, "g*"))):
        x = one(d)
        if x:
            rows[x["tag"]] = x
    return rows


def tstat(v):
    if len(v) < 2:
        return 0.0
    sd = st.stdev(v)
    return (sum(v) / len(v)) / (sd / math.sqrt(len(v))) if sd > 0 else 0.0


def mean(v):
    v = [x for x in v if x is not None]
    return sum(v) / len(v) if v else None


def fmt(v, p=0):
    return "-" if v is None else ("{:,.%df}" % p).format(v)


def report(games=False):
    arms = [a for a in ARMS if os.path.isdir(os.path.join(DATA, a))]
    R = {a: arm_rows(a) for a in arms}
    me, op = PAIR[0].capitalize(), PAIR[1].capitalize()
    print("| arm | games | %s won | %s led | even | %s led | %s won | %s won or led | %s won or led | median minute decided | mean g (t) |" % (me, me, op, op, me, op))
    print("|---|---|---|---|---|---|---|---|---|---|---|")
    for a in arms:
        rows = R[a]
        c = {k: sum(1 for x in rows.values() if x["res"] == k) for k in "Ww=lL"}
        gs = [x["g"] for x in rows.values()]
        dec = [x["end"] / 60 for x in rows.values() if x["res"] in "WL"]
        print("| %s | %d | %d | %d | %d | %d | %d | %d | %d | %s | %+.2f (%.1f) |" % (
            a, len(rows), c["W"], c["w"], c["="], c["l"], c["L"], c["W"] + c["w"], c["L"] + c["l"],
            "%.1f" % st.median(dec) if dec else "-", mean(gs) or 0.0, tstat(gs)))
    if "default" in R and "nerf" in R:
        common = [t for t in R["nerf"] if t in R["default"]]
        ds = [R["nerf"][t]["g"] - R["default"][t]["g"] for t in common]
        if ds:
            print("\nNerf v default, paired on the same %d games: mean difference of g %+.2f (t %.1f); the Crown better in %d, worse in %d (a change of more than 0.05)." % (
                len(ds), mean(ds), tstat(ds), sum(1 for x in ds if x > 0.05), sum(1 for x in ds if x < -0.05)))
    print("\n| arm | income 8:00 (%s / %s) | 12:00 | 16:00 | army 8:00 | 12:00 | 16:00 | halls 12:00 | halls 20:00 |" % (me, op))
    print("|---|---|---|---|---|---|---|---|---|")
    for a in arms:
        rows = list(R[a].values())
        cell = lambda k: "%s / %s" % (fmt(mean([x[k + "_me"] for x in rows])), fmt(mean([x[k + "_op"] for x in rows])))
        cellf = lambda k: "%s / %s" % (fmt(mean([x[k + "_me"] for x in rows]), 1), fmt(mean([x[k + "_op"] for x in rows]), 1))
        print("| %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (a, cell("inc8"), cell("inc12"), cell("inc16"),
              cell("army8"), cell("army12"), cell("army16"), cellf("halls12"), cellf("halls20")))
    print("\n| arm | spot | games | %s won or led | even | %s won or led | mean g |" % (me, op))
    print("|---|---|---|---|---|---|---|")
    for a in arms:
        for sp in (0, 1):
            rows = [x for x in R[a].values() if x["spot"] == sp]
            if not rows:
                continue
            print("| %s | %s on %s | %d | %d | %d | %d | %+.2f |" % (a, me, "A" if sp == 0 else "B", len(rows),
                  sum(1 for x in rows if x["res"] in "Ww"), sum(1 for x in rows if x["res"] == "="),
                  sum(1 for x in rows if x["res"] in "Ll"), mean([x["g"] for x in rows])))
    print("\n| arm | map | %s won or led | even | %s won or led | mean g |" % (me, op))
    print("|---|---|---|---|---|---|")
    for a in arms:
        for m in qm.PARITY_MAPS:
            rows = [x for x in R[a].values() if x["map"] == m]
            if rows:
                print("| %s | %s | %d | %d | %d | %+.2f |" % (a, m, sum(1 for x in rows if x["res"] in "Ww"),
                      sum(1 for x in rows if x["res"] == "="), sum(1 for x in rows if x["res"] in "Ll"), mean([x["g"] for x in rows])))
    if games:
        for a in arms:
            print("\n" + a)
            for t, x in sorted(R[a].items()):
                print("  %-26s %s %2d:%02d g %+.2f inc12 %s/%s army12 %s/%s %s" % (t, x["res"], x["end"] // 60, x["end"] % 60,
                      x["g"], fmt(x["inc12_me"]), fmt(x["inc12_op"]), fmt(x["army12_me"]), fmt(x["army12_op"]), x["version"]))


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "list":
        for g in queue():
            print(*g)
    elif cmd == "run":
        a = sys.argv[2]
        dd = os.path.join(DATA, a)
        os.makedirs(dd, exist_ok=True)
        with open(os.path.join(dd, "extra.txt"), "w") as f:
            f.write(" ".join(ARMS[a]) + "\n")
        out = os.path.abspath(arg("--out", "/tmp/claude-0/wr1126_out/%s_%s" % (NAME, a)))
        end = int(arg("--end", "1200"))
        q = queue()
        if "--only" in sys.argv:
            ids = {int(x) for x in arg("--only", "").split(",")}
            q = [g for i, g in enumerate(q) if i in ids]
        with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
            for t in ex.map(lambda g: qm.run_one(g, out, end, dd, ARMS[a]), q):
                print("done", a, t, flush=True)
    elif cmd == "report":
        report("--games" in sys.argv)
    else:
        print(__doc__)
