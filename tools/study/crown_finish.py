#!/usr/bin/env python3
"""THE CROWN FINISHER STUDY (crown-finish, docs/crown_finish.md; the owner 2026-11-25 from the championship simulation:
the Crown gets ahead and does not finish). Hard OPTIMAL games to 20:00 on the 6 parity maps (qa_matches.PARITY_MAPS), the
SAME 20 map/seed/side games for each arm in each matchup (k = 0..19: map PARITY[k % 6], round k // 6, start spots swapped
every other game and on a map's next round), so the arms compare game by game. Arms are sets of match switches:
    base   cfin:off   (the game as it is today)
    fin    (the finisher on: its default)
    python3 tools/study/crown_finish.py list [MATCHUP]
    python3 tools/study/crown_finish.py run ARM MATCHUP[,MATCHUP] [--extra sw1,sw2] [--jobs 2] [--root DIR] [--games a-b]
    python3 tools/study/crown_finish.py report [ARM ...] [--games]
MATCHUP: clock (Crown v Clockwork), brood (Crown v Brood), mirror (Crown v Crown).
Data: docs/crown_finish/data/<ARM>/<MATCHUP>/<tag>/ (result.json, story.txt, planlog.txt: the Crown's plan lines, the
finisher's among them). The bell's verdict is the tournament's: income earned + 2 x army, 10% ahead (docs/tournament.md)."""
import os, sys, json, glob, math, statistics as st, gzip, shutil
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = qm.PARITY_MAPS
DATA = os.path.join(qm.ROOT, "docs/crown_finish/data")
OPP = {"clock": "clockwork", "brood": "brood", "mirror": "crown"}
SEED0 = {"clock": 31000, "brood": 32000, "mirror": 33000}
ARMS = {"base": ["cfin:off"], "fin": []}
N = 20


def queue(mu):
    out = []
    for k in range(N):
        m, r = MAPS[k % len(MAPS)], k // len(MAPS)
        seed = SEED0[mu] + 97 * k
        swap = (k + r) % 2 == 1
        me, foe = ("crown", "optimal"), (OPP[mu], "optimal")
        s1, s2 = (foe, me) if swap else (me, foe)
        out.append(("cf%s_%02d_%s_r%d" % (mu[0], k, m, r), m, seed, [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
    return out


def side_of(g):
    # the Crown's side (the mirror: side 0 is "ours", only decisiveness matters there)
    for i, s in enumerate(g["slots"]):
        f = s.get("faction") if isinstance(s, dict) else s[0]
        if f == "crown":
            return i
    return 0


def one(d):
    f = os.path.join(d, "result.json")
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    tag = os.path.basename(d)
    si = side_of(g)
    oi = 1 - si
    at = {}
    for x in g["minutes"]:
        at[(x["p"], int(round(x["t"] / 60)))] = x
    end, winner, fin = g["end"], g["winner"], g["final"]
    sc = [x["income"] + 2 * x["army"] for x in fin]
    if winner >= 0:
        res = "W" if winner == si else "L"          # an outright end (the mirror: W = side 0 won)
    else:
        res = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")

    def last(p, mn):
        for k in range(mn, -1, -1):
            if (p, k) in at:
                return at[(p, k)]
        return None
    row = {"tag": tag, "map": g.get("map", ""), "si": si, "res": res, "end": end, "sc": sc}
    for mn in (12, 16):
        a, b = last(si, mn), last(oi, mn)
        row["army%d" % mn] = a["army"] if a else None
        row["farmy%d" % mn] = b["army"] if b else None
    # halls lost by each side (the events), and the finisher's own lines
    hl = [0, 0]
    for e in g.get("events", []):
        if e.get("ev") == "hall_lost":
            p = int(e.get("p", e.get("player", -1)))
            if p in (0, 1):
                hl[p] += 1
    row["halls_lost"] = hl[si]
    row["foe_halls_lost"] = hl[oi]
    pl = os.path.join(d, "planlog.txt")
    fl = []
    if os.path.exists(pl):
        fl = [l for l in open(pl, errors="replace") if "finisher:" in l]
    row["fin_starts"] = sum(1 for l in fl if "clearly ahead" in l)
    row["fin_lines"] = fl
    return row


def rows(arm, mu):
    out = {}
    for d in sorted(glob.glob(os.path.join(DATA, arm, mu, "cf*"))):
        x = one(d)
        if x:
            out[x["tag"]] = x
    return out


def mmss(v):
    return "-" if v is None else "%d:%02d" % (int(v) // 60, int(v) % 60)


def summary(rs, mirror=False):
    n = len(rs)
    c = {k: sum(1 for x in rs.values() if x["res"] == k) for k in ("W", "w", "=", "l", "L")}
    out_t = [x["end"] for x in rs.values() if x["res"] in ("W", "L")]
    beaten = [x["end"] for x in rs.values() if x["res"] == "L"]
    won_t = [x["end"] for x in rs.values() if x["res"] == "W"]
    mean = lambda k: (lambda v: sum(v) / len(v) if v else None)([x[k] for x in rs.values() if x[k] is not None])
    return {"n": n, **c, "decided": c["W"] + c["L"], "won_led": c["W"] + c["w"], "lost": c["L"] + c["l"],
            "end_med": st.median(out_t) if out_t else None, "won_med": st.median(won_t) if won_t else None,
            "beat_med": st.median(beaten) if beaten else None,
            "hl": mean("halls_lost"), "fhl": mean("foe_halls_lost"), "a12": mean("army12"), "a16": mean("army16"),
            "fa12": mean("farmy12"), "fa16": mean("farmy16"),
            "fin_games": sum(1 for x in rs.values() if x["fin_starts"] > 0),
            "fin_starts": sum(x["fin_starts"] for x in rs.values())}


def run(arm, mus, extra, jobs, root, rng):
    qm.RUN_ROOT = os.path.abspath(root)
    qm.KEEP_GREP = "Crown's plan"
    qm.KEEP_CW = False
    games = []
    for mu in mus:
        dd = os.path.join(DATA, arm, mu)
        os.makedirs(dd, exist_ok=True)
        with open(os.path.join(dd, "extra.txt"), "w") as f:
            f.write(" ".join(ARMS.get(arm, []) + extra) + "\n")
        q = queue(mu)
        if rng:
            a, b = [int(x) for x in rng.split("-")]
            q = q[a:b + 1]
        for g in q:
            games.append((mu, g))
    logs = "/tmp/claude-0/cf_logs/%s" % arm

    def go(item):
        mu, g = item
        qm.LOG_DIR = os.path.join(logs, mu)
        out = "/tmp/claude-0/cf_out/%s/%s" % (arm, mu)
        t = qm.run_one(g, out, 1200, os.path.join(DATA, arm, mu), ARMS.get(arm, []) + extra)
        lf = os.path.join(qm.LOG_DIR, g[0] + ".log")
        if os.path.exists(lf):
            with open(lf, "rb") as a, gzip.open(lf + ".gz", "wb") as b:
                shutil.copyfileobj(a, b)
            os.remove(lf)
        return mu + "/" + t
    with ThreadPoolExecutor(jobs) as ex:
        for t in ex.map(go, games):
            print("done", t, flush=True)


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "list":
        for mu in ([sys.argv[2]] if len(sys.argv) > 2 else list(OPP)):
            for g in queue(mu):
                print(mu, *g)
    elif cmd == "run":
        run(sys.argv[2], sys.argv[3].split(","), [x for x in arg("--extra", "").split(",") if x], int(arg("--jobs", "2")),
            arg("--root", qm.ROOT), arg("--games", ""))
    elif cmd == "report":
        arms = [x for x in sys.argv[2:] if not x.startswith("--")] or ["base", "fin"]
        print("| matchup | arm | games | Crown won outright | won at the bell | even | behind at the bell | beaten | decided by 20:00 | median end of a decided game | Crown halls lost | enemy halls lost | Crown army 12:00 | enemy army 12:00 | Crown army 16:00 | enemy army 16:00 | games the finisher started (times) |")
        print("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for mu in OPP:
            for a in arms:
                rs = rows(a, mu)
                if not rs:
                    continue
                s = summary(rs, mu == "mirror")
                f1 = lambda v: "-" if v is None else "%.1f" % v
                f0 = lambda v: "-" if v is None else "%d" % round(v)
                print("| %s | %s | %d | %d | %d | %d | %d | %d | %d | %s | %s | %s | %s | %s | %s | %s | %d (%d) |" % (
                    mu, a, s["n"], s["W"], s["w"], s["="], s["l"], s["L"], s["decided"], mmss(s["end_med"]), f1(s["hl"]),
                    f1(s["fhl"]), f0(s["a12"]), f0(s["fa12"]), f0(s["a16"]), f0(s["fa16"]), s["fin_games"], s["fin_starts"]))
        if "--games" in sys.argv:
            for mu in OPP:
                for a in arms:
                    rs = rows(a, mu)
                    if not rs:
                        continue
                    print("\n%s %s" % (mu, a))
                    for t, x in sorted(rs.items()):
                        print("  %-32s %s %5s army12 %s/%s army16 %s/%s halls lost %s/%s fin %d" % (
                            t, x["res"], mmss(x["end"]), x["army12"], x["farmy12"], x["army16"], x["farmy16"],
                            x["halls_lost"], x["foe_halls_lost"], x["fin_starts"]))
    else:
        print(__doc__)
