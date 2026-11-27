#!/usr/bin/env python3
"""WIN RATES 2026-11-26, THE MATCHUPS WITHOUT THE BROOD (job winrate-no-brood, docs/winrate_2026_11_26_no_brood.md).
A measuring tool: it changes no rule and no AI. Hard OPTIMAL v Hard OPTIMAL, every game to 20:00 (a defeat ends it
sooner), on the six parity maps (qa_matches.PARITY_MAPS), 30 games a cell, main as it is (the DEFAULT arm only: the
Rootmaw nerf touches only the Brood). The same method as the other three winrate-2026-11-26 jobs:
    game i = 0..29: seed 1126001 + i, map PARITY_MAPS[i % 6], spot (i // 6) % 2
    spot 0: "our" side is player 0 (spot A); spot 1: "our" side is player 1 (spot B); in a mirror "our" side is
    always player 0 (spot A), so g is spot A v spot B and the two spot groups are just two seed groups.
Cells: crown_clock ("our" side the Crown), crown_mirror and clock_mirror ("our" side the one on spot A: in a mirror both
slots hold the same faction, so the spot alternation only changes the seed's pairing; g is spot A v spot B).
    python3 tools/study/winrate_1126_no_brood.py list [CELL]
    python3 tools/study/winrate_1126_no_brood.py run CELL[,CELL] [--jobs 2] [--end 1200] [--root DIR] [--push]
    python3 tools/study/winrate_1126_no_brood.py report [CELL ...]   (markdown tables)
    python3 tools/study/winrate_1126_no_brood.py games CELL           (one line a game)
Data: docs/winrate_2026_11_26/data/<cell>/default/<tag>/ (result.json, story.txt).
Score = income earned + 2 x army at the bell or the defeat, a beaten side's score counted a quarter (plan_matrix_report /
ai_lessons); g = ln(our score / their score); led = 10% ahead at the bell."""
import os, sys, json, glob, math, subprocess, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = qm.PARITY_MAPS
DATA = os.path.join(qm.ROOT, "docs/winrate_2026_11_26/data")
CELLS = {"crown_clock": ("crown", "clockwork"), "crown_mirror": ("crown", "crown"), "clock_mirror": ("clockwork", "clockwork")}
N = 30
CUT = 1200


def queue(cell):
    me, foe = CELLS[cell]
    out = []
    for i in range(N):
        m = MAPS[i % 6]
        spot = (i // 6) % 2
        seed = 1126001 + i
        a, b = ((me, "optimal"), (foe, "optimal")) if spot == 0 else ((foe, "optimal"), (me, "optimal"))
        tag = "g%02d_%s_%s" % (i, m, "A" if spot == 0 else "B")
        out.append((tag, m, seed, [(a[0], a[1], 0), (b[0], b[1], 1)]))
    return out


def one(d):
    f = os.path.join(d, "result.json")
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    tag = os.path.basename(d)
    i = int(tag[1:3])
    spot = (i // 6) % 2
    mirror = CELLS[os.path.basename(os.path.dirname(os.path.dirname(d)))][0] == CELLS[os.path.basename(os.path.dirname(os.path.dirname(d)))][1]
    si = 0 if mirror else spot      # our side's player index (a mirror: always spot A = player 0)
    oi = 1 - si
    at = {}
    for x in g["minutes"]:
        at[(x["p"], int(round(x["t"] / 60)))] = x
    end, winner, fin = g["end"], g["winner"], g["final"]
    if end > CUT:
        mm = CUT // 60
        if (0, mm) in at and (1, mm) in at:
            fin = [at[(0, mm)], at[(1, mm)]]
        end, winner = CUT, -1
    fin = sorted(fin, key=lambda x: x["p"])
    sc = [x["income"] + 2 * x["army"] for x in fin]
    s_me = sc[si] * (0.25 if winner == oi else 1.0)
    s_op = sc[oi] * (0.25 if winner == si else 1.0)
    gv = math.log(max(1.0, s_me) / max(1.0, s_op))
    if winner >= 0:
        res = "W" if winner == si else "L"
    else:
        res = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")

    def val(p, key, mn):
        x = at.get((p, mn))
        return None if x is None else x.get(key)

    def halls_end(p):
        if winner >= 0 and p != winner:
            return 0
        return fin[p].get("halls")

    return {"tag": tag, "map": g.get("map", ""), "spot": spot, "res": res, "end": end, "g": gv, "sc": [sc[si], sc[oi]],
            "inc": {mn: (val(si, "income", mn), val(oi, "income", mn)) for mn in (8, 12, 16)},
            "army": {mn: (val(si, "army", mn), val(oi, "army", mn)) for mn in (8, 12, 16)},
            "halls12": (val(si, "halls", 12), val(oi, "halls", 12)), "halls20": (halls_end(si), halls_end(oi)),
            "plans": (fin[si].get("plan", ""), fin[oi].get("plan", "")), "version": g.get("version", "")}


def rows_of(cell):
    rows = []
    for d in sorted(glob.glob(os.path.join(DATA, cell, "default", "g*"))):
        x = one(d)
        if x:
            rows.append(x)
    return rows


def mean(v):
    v = [x for x in v if x is not None]
    return sum(v) / len(v) if v else None


def tstat(v):
    if len(v) < 2:
        return 0.0
    sd = st.stdev(v)
    return (sum(v) / len(v)) / (sd / math.sqrt(len(v))) if sd > 0 else 0.0


def summ(rows):
    c = {k: sum(1 for x in rows if x["res"] == k) for k in "Ww=lL"}
    gs = [x["g"] for x in rows]
    dec = [x["end"] / 60.0 for x in rows if x["res"] in ("W", "L")]
    s = {"n": len(rows), "c": c, "wl_us": c["W"] + c["w"], "wl_them": c["L"] + c["l"], "g": mean(gs) or 0.0, "t": tstat(gs),
         "dec_med": st.median(dec) if dec else None, "dec": sorted(dec)}
    for k in ("inc", "army"):
        for mn in (8, 12, 16):
            s["%s%d" % (k, mn)] = (mean([x[k][mn][0] for x in rows]), mean([x[k][mn][1] for x in rows]))
    s["halls12"] = (mean([x["halls12"][0] for x in rows]), mean([x["halls12"][1] for x in rows]))
    s["halls20"] = (mean([x["halls20"][0] for x in rows]), mean([x["halls20"][1] for x in rows]))
    return s


def k(v):
    return "-" if v is None else ("%.1fk" % (v / 1000.0))


def h(v):
    return "-" if v is None else "%.1f" % v


NAMES = {"crown_clock": ("Crown", "Clockwork"), "crown_mirror": ("spot A", "spot B"), "clock_mirror": ("spot A", "spot B")}
TITLE = {"crown_clock": "Crown v Clockwork", "crown_mirror": "Crown mirror", "clock_mirror": "Clockwork mirror"}


def report(cells):
    print("| matchup | games | %s won | %s led | even | %s led | %s won | won or led (us / them) | decided: median min | mean g (t) |" % ("us", "us", "them", "them"))
    print("|---|---|---|---|---|---|---|---|---|---|")
    S = {}
    for cell in cells:
        rows = rows_of(cell)
        if not rows:
            continue
        s = S[cell] = summ(rows)
        a, b = NAMES[cell]
        c = s["c"]
        print("| %s (us = %s) | %d | %d | %d | %d | %d | %d | %d / %d | %s | %+.2f (%.1f) |" % (
            TITLE[cell], a, s["n"], c["W"], c["w"], c["="], c["l"], c["L"], s["wl_us"], s["wl_them"],
            "-" if s["dec_med"] is None else "%.1f" % s["dec_med"], s["g"], s["t"]))
    print()
    print("Income earned so far and army value (mean; us / them), halls (mean; us / them):")
    print()
    print("| matchup | income 8:00 | income 12:00 | income 16:00 | army 8:00 | army 12:00 | army 16:00 | halls 12:00 | halls 20:00 |")
    print("|---|---|---|---|---|---|---|---|---|")
    for cell, s in S.items():
        print("| %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (
            TITLE[cell], *["%s / %s" % (k(s[key][0]), k(s[key][1])) for key in ("inc8", "inc12", "inc16", "army8", "army12", "army16")],
            "%s / %s" % (h(s["halls12"][0]), h(s["halls12"][1])), "%s / %s" % (h(s["halls20"][0]), h(s["halls20"][1]))))
    print()
    print("By start spot (crown_clock: the Crown on spot A / on spot B; a mirror: the seed group, us = spot A in both):")
    print()
    print("| matchup | our spot | games | us won | us led | even | them led | them won | mean g |")
    print("|---|---|---|---|---|---|---|---|---|")
    for cell in S:
        for sp in (0, 1):
            rows = [x for x in rows_of(cell) if x["spot"] == sp]
            if not rows:
                continue
            s = summ(rows)
            c = s["c"]
            print("| %s | %s | %d | %d | %d | %d | %d | %d | %+.2f |" % (TITLE[cell], "AB"[sp], s["n"], c["W"], c["w"], c["="], c["l"], c["L"], s["g"]))
    print()
    print("By map (us won-led-even-led-won them):")
    print()
    print("| matchup | " + " | ".join(MAPS) + " |")
    print("|---|" + "---|" * len(MAPS))
    for cell in S:
        cols = []
        for m in MAPS:
            rows = [x for x in rows_of(cell) if x["map"] == m]
            c = summ(rows)["c"] if rows else {k_: 0 for k_ in "Ww=lL"}
            cols.append("%d-%d-%d-%d-%d" % (c["W"], c["w"], c["="], c["l"], c["L"]))
        print("| %s | %s |" % (TITLE[cell], " | ".join(cols)))


def push(msg):
    subprocess.run(["git", "-C", qm.ROOT, "add", "docs/winrate_2026_11_26"], check=False)
    r = subprocess.run(["git", "-C", qm.ROOT, "commit", "-q", "-m", msg + "\n\nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>\n"
                        "Claude-Session: https://claude.ai/code/session_01NtmEZhP1uA8k4DLQ7BYfMz"], check=False)
    if r.returncode == 0:
        subprocess.run(["git", "-C", qm.ROOT, "push", "-q", "origin", "HEAD"], check=False)


if __name__ == "__main__":
    arg = lambda key, d: sys.argv[sys.argv.index(key) + 1] if key in sys.argv else d
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "list":
        for cell in ([sys.argv[2]] if len(sys.argv) > 2 else CELLS):
            for g in queue(cell):
                print(cell, *g)
    elif cmd == "run":
        cells = sys.argv[2].split(",")
        qm.RUN_ROOT = os.path.abspath(arg("--root", qm.ROOT))
        end = int(arg("--end", str(CUT)))
        jobs = int(arg("--jobs", "2"))
        work = []
        for cell in cells:
            dd = os.path.join(DATA, cell, "default")
            os.makedirs(dd, exist_ok=True)
            out = "/tmp/claude-0/wr1126_out/" + cell
            work += [(cell, g, out, dd) for g in queue(cell)]
        # interleave the cells so a cut run has some of each
        work.sort(key=lambda w: (int(w[1][0][1:3]), list(CELLS).index(w[0])))
        done = [0]
        with ThreadPoolExecutor(jobs) as ex:
            for t in ex.map(lambda w: (w[0], qm.run_one(w[1], w[2], end, w[3])), work):
                print("done", *t, flush=True)
                if "(had)" not in t[1]:
                    done[0] += 1
                    if "--push" in sys.argv and done[0] % 4 == 0:
                        push("winrate-no-brood: data (%d more games)" % 4)
        if "--push" in sys.argv:
            push("winrate-no-brood: data")
    elif cmd == "report":
        report(sys.argv[2:] or list(CELLS))
    elif cmd == "games":
        for x in rows_of(sys.argv[2]):
            print("%-26s %s %5.1f g %+.2f score %s/%s inc12 %s/%s halls20 %s/%s plans %s/%s" % (
                x["tag"], x["res"], x["end"] / 60.0, x["g"], k(x["sc"][0]), k(x["sc"][1]), k(x["inc"][12][0]),
                k(x["inc"][12][1]), x["halls20"][0], x["halls20"][1], *x["plans"]))
    else:
        print(__doc__)
