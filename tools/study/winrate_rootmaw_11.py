#!/usr/bin/env python3
"""WIN RATES, THE ROOTMAW AT 1.1 (job winrate-rootmaw-1-1, docs/winrate_rootmaw_1_1.md). A measuring tool: it changes no
rule and no AI.
The owner (2026-11-27): "What if we nerfed the Rootmaw from 1.2 to 1.1?" Defs.FOOD_BONUS 1.2 = the far Rootmaw pays
x2.2 (the default arm); 1.1 = the match switch `farmaw:2.1`; 1.0 = `farmaw:2.0` (measured on 2026-11-26).
The method of tools/study/winrate_1126_*.py: Hard OPTIMAL v Hard OPTIMAL to 20:00 (a defeat ends it sooner), the six
parity maps, score = income earned + 2 x army at the bell or the defeat (a beaten side's score a quarter), led = 10% ahead
at the bell. THE SPOT SPLIT IS FIXED: game i (0..29) has seed 1127001 + i, map PARITY_MAPS[i % 6] (5 games a map) and
spot ((i // 6) + (i % 6)) % 2, so exactly 15 games on spot 0 and 15 on spot 1. Every matchup and arm plays the SAME 30.
Matchups: crown_brood, clock_brood, brood_mirror. Spot 0: the matchup's first side (the Crown / the Clockwork) in slot 0
= start spot A, the Brood on B; spot 1 the other way round. In the mirror spot 1 = the match switch `spotswap` (player 1
on spot B); "our" side there is the Brood on spot A, so the mirror's g is the spot A edge.
    python3 tools/study/winrate_rootmaw_11.py list
    python3 tools/study/winrate_rootmaw_11.py run MATCHUP ARM [--jobs 2] [--only i,j]   (ARM: default | r11 | r10)
    python3 tools/study/winrate_rootmaw_11.py queue [--jobs 2]                         (every matchup and arm, interleaved)
    python3 tools/study/winrate_rootmaw_11.py status
    python3 tools/study/winrate_rootmaw_11.py report [--games]
Data: docs/winrate_rootmaw_1_1/data/<matchup>/<arm>/<tag>/ (result.json, story.txt)."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MATCHUPS = {"crown_brood": ("crown", "brood"), "clock_brood": ("clockwork", "brood"), "brood_mirror": ("brood", "brood")}
ARMS = {"default": [], "r11": ["farmaw:2.1"], "r10": ["farmaw:2.0"]}
ARM_NAME = {"default": "x2.2 (today, 1.2)", "r11": "x2.1 (1.1)", "r10": "x2.0 (1.0)"}
DATA = os.path.join(qm.ROOT, "docs/winrate_rootmaw_1_1/data")
OUT = "/tmp/claude-0/wrr11_out"
N = 30
END = 1200


def games():
    out = []
    for i in range(N):
        m = qm.PARITY_MAPS[i % 6]
        spot = ((i // 6) + (i % 6)) % 2
        out.append((i, "g%02d_%s_s%d" % (i, m, spot), m, 1127001 + i, spot))
    return out


def job(mu, arm, g):
    i, tag, m, seed, spot = g
    a, b = MATCHUPS[mu]
    ex = list(ARMS[arm])
    if a == b:
        slots = [(a, "optimal", 0), (b, "optimal", 1)]
        if spot == 1:
            ex.append("spotswap")
    else:
        s1, s2 = ((a, "optimal"), (b, "optimal")) if spot == 0 else ((b, "optimal"), (a, "optimal"))
        slots = [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]
    dd = os.path.join(DATA, mu, arm)
    os.makedirs(dd, exist_ok=True)
    with open(os.path.join(dd, "extra.txt"), "w") as f:
        f.write(" ".join(ARMS[arm]) + "\n")
    return qm.run_one((tag, m, seed, slots), os.path.join(OUT, mu, arm), END, dd, ex)


def at_or_last(at, p, mn):
    for k in range(mn, -1, -1):
        if (p, k) in at:
            return at[(p, k)]
    return None


def one(mu, d):
    f = os.path.join(d, "result.json")
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    tag = os.path.basename(d)
    spot = int(tag[-1])
    a, b = MATCHUPS[mu]
    if a == b:
        si = 1 if spot == 1 else 0      # the player index on spot A
    else:
        si = 0
        for k, s in enumerate(g["slots"]):
            if (s.get("faction") if isinstance(s, dict) else s[0]) == a:
                si = k
    oi = 1 - si
    at = {(x["p"], int(round(x["t"] / 60))): x for x in g["minutes"]}
    end, winner, fin = g["end"], g["winner"], g["final"]
    if end > END:
        mm = END // 60
        if (0, mm) in at and (1, mm) in at:
            fin = [at[(0, mm)], at[(1, mm)]]
        end, winner = END, -1
    if not g.get("over", winner >= 0):
        winner = -1
    sc = [x["income"] + 2 * x["army"] for x in fin]
    s_me = sc[si] * (0.25 if winner == oi else 1.0)
    s_op = sc[oi] * (0.25 if winner == si else 1.0)
    gv = math.log(max(1.0, s_me) / max(1.0, s_op))
    if winner >= 0:
        res = "W" if winner == si else "L"
    else:
        res = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")

    def val(p, key, mn):
        x = at_or_last(at, p, mn)
        return x.get(key) if x else None
    r = {"tag": tag, "i": int(tag[1:3]), "map": g.get("map", tag.split("_", 1)[1].rsplit("_s", 1)[0]), "spot": spot,
         "res": res, "end": end, "g": gv, "version": g.get("version", "")}
    for mn in (8, 12, 16):
        for key, k in (("income", "inc"), ("army", "army")):
            r["%s%d_me" % (k, mn)] = val(si, key, mn)
            r["%s%d_op" % (k, mn)] = val(oi, key, mn)
    for mn in (8, 12, 16):
        r["halls%d_me" % mn] = val(si, "halls", mn) if not (winner == oi and end < mn * 60) else 0
        r["halls%d_op" % mn] = val(oi, "halls", mn) if not (winner == si and end < mn * 60) else 0
    return r


def rows(mu, arm):
    out = {}
    for d in sorted(glob.glob(os.path.join(DATA, mu, arm, "g*"))):
        x = one(mu, d)
        if x:
            out[x["tag"]] = x
    return out


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


def names(mu):
    a, b = MATCHUPS[mu]
    if a == b:
        return "Spot A", "Spot B"
    return ("Crown" if a == "crown" else "Clockwork"), "Brood"


def report(games_list=False):
    for mu in MATCHUPS:
        me, op = names(mu)
        R = {a: rows(mu, a) for a in ARMS if os.path.isdir(os.path.join(DATA, mu, a))}
        if not R:
            continue
        print("\n## %s\n" % {"crown_brood": "Crown v Brood", "clock_brood": "Clockwork v Brood",
                             "brood_mirror": "Brood mirror (spot A Brood v spot B Brood)"}[mu])
        print("| Rootmaw | games | %s won | %s led | even | %s led | %s won | %s won or led | %s won or led | mean g (t) |" % (me, me, op, op, me, op))
        print("|---|---|---|---|---|---|---|---|---|---|")
        for a, rr in R.items():
            c = {k: sum(1 for x in rr.values() if x["res"] == k) for k in "Ww=lL"}
            gs = [x["g"] for x in rr.values()]
            print("| %s | %d | %d | %d | %d | %d | %d | %d | %d | %+.2f (%.1f) |" % (ARM_NAME[a], len(rr), c["W"], c["w"], c["="],
                  c["l"], c["L"], c["W"] + c["w"], c["L"] + c["l"], mean(gs) or 0.0, tstat(gs)))
        print("\nPaired on the same games (g of the nerfed arm minus g of the other; plus = better for %s):\n" % me)
        print("| compared | games | mean difference (t) | better | worse |")
        print("|---|---|---|---|---|")
        for x, y in (("r11", "default"), ("r10", "default"), ("r10", "r11")):
            if x in R and y in R:
                common = [t for t in R[x] if t in R[y]]
                ds = [R[x][t]["g"] - R[y][t]["g"] for t in common]
                if ds:
                    print("| %s v %s | %d | %+.2f (%.1f) | %d | %d |" % (ARM_NAME[x], ARM_NAME[y], len(ds), mean(ds), tstat(ds),
                          sum(1 for d in ds if d > 0.05), sum(1 for d in ds if d < -0.05)))
        if MATCHUPS[mu][0] == MATCHUPS[mu][1]:
            print("\nBy which player stood on spot A (spot 0 = player 1 on A, spot 1 = player 2 on A):\n")
            print("| Rootmaw | player on A | games | spot A won or led | even | spot B won or led | mean g |")
        else:
            print("\nBy spot:\n")
            print("| Rootmaw | spot | games | %s won or led | even | %s won or led | mean g |" % (me, op))
        print("|---|---|---|---|---|---|---|")
        for a, rr in R.items():
            for sp in (0, 1):
                xs = [x for x in rr.values() if x["spot"] == sp]
                if not xs:
                    continue
                lab = ("player %d" % (1 + sp)) if MATCHUPS[mu][0] == MATCHUPS[mu][1] else ("%s on %s" % (me, "AB"[sp]))
                print("| %s | %s | %d | %d | %d | %d | %+.2f |" % (ARM_NAME[a], lab, len(xs), sum(1 for x in xs if x["res"] in "Ww"),
                      sum(1 for x in xs if x["res"] == "="), sum(1 for x in xs if x["res"] in "Ll"), mean([x["g"] for x in xs])))
        print("\nIncome earned, army and halls (%s / %s), means:\n" % (me, op))
        print("| Rootmaw | income 8:00 | 12:00 | 16:00 | army 8:00 | 12:00 | 16:00 | halls 8:00 | 12:00 | 16:00 |")
        print("|---|---|---|---|---|---|---|---|---|---|")
        for a, rr in R.items():
            xs = list(rr.values())
            c = lambda k, p=0: "%s / %s" % (fmt(mean([x[k + "_me"] for x in xs]), p), fmt(mean([x[k + "_op"] for x in xs]), p))
            print("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (ARM_NAME[a], c("inc8"), c("inc12"), c("inc16"),
                  c("army8"), c("army12"), c("army16"), c("halls8", 1), c("halls12", 1), c("halls16", 1)))
        print("\nBy map (won or led %s / even / %s, mean g):\n" % (me, op))
        print("| map | " + " | ".join(ARM_NAME[a] for a in R) + " |")
        print("|---|" + "---|" * len(R))
        for m in qm.PARITY_MAPS:
            cells = []
            for a, rr in R.items():
                xs = [x for x in rr.values() if x["map"] == m]
                cells.append("%d / %d / %d, %+.2f" % (sum(1 for x in xs if x["res"] in "Ww"), sum(1 for x in xs if x["res"] == "="),
                             sum(1 for x in xs if x["res"] in "Ll"), mean([x["g"] for x in xs]) or 0.0) if xs else "-")
            print("| %s | %s |" % (m, " | ".join(cells)))
        if games_list:
            for a, rr in R.items():
                print("\n%s %s" % (mu, a))
                for t, x in sorted(rr.items()):
                    print("  %-26s %s %2d:%02d g %+.2f inc12 %s/%s army12 %s/%s %s" % (t, x["res"], x["end"] // 60, x["end"] % 60,
                          x["g"], fmt(x["inc12_me"]), fmt(x["inc12_op"]), fmt(x["army12_me"]), fmt(x["army12_op"]), x["version"]))


def all_jobs():
    # interleaved: game by game, every matchup and arm, so a cut run is still balanced
    return [(mu, arm, g) for g in games() for mu in MATCHUPS for arm in ARMS]


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "list":
        for g in games():
            print(*g)
    elif cmd in ("run", "queue"):
        if cmd == "run":
            q = [(sys.argv[2], sys.argv[3], g) for g in games()]
        else:
            q = all_jobs()
        if "--only" in sys.argv:
            ids = {int(x) for x in arg("--only", "").split(",")}
            q = [j for j in q if j[2][0] in ids]
        if "--part" in sys.argv:   # k/n: every n-th job from k (to share the queue between machines)
            k, n = (int(x) for x in arg("--part", "0/1").split("/"))
            q = q[k::n]
        with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
            for t in ex.map(lambda j: "%s %s %s" % (j[0], j[1], job(*j)), q):
                print("done", t, flush=True)
    elif cmd == "status":
        for mu in MATCHUPS:
            for a in ARMS:
                d = os.path.join(DATA, mu, a)
                ok = len(glob.glob(os.path.join(d, "g*", "result.json")))
                bad = len(glob.glob(os.path.join(d, "g*", "FAILED.txt")))
                print("%-13s %-8s %2d done %d failed" % (mu, a, ok, bad))
    elif cmd == "report":
        report("--games" in sys.argv)
    else:
        print(__doc__)
