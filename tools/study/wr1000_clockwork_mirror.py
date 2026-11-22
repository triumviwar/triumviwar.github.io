#!/usr/bin/env python3
"""WR1000, THE CLOCKWORK MIRROR (wr1000-clockwork-mirror, docs/wr1000_clockwork_mirror.md): blocks of 10 games of the
Clockwork computer (Hard OPTIMAL) against itself, to 20:00, on the SAME 10 map/seed games every block (the ai-opponent-review
parity games of the Clockwork mirror, tags and seeds of qa_matches' base rounds: 6 maps round 0, 4 of them round 1), so blocks
compare game by game. P1 (slot 0) always starts on the map's spot A (the top-left start), P2 on spot B. A measuring tool: it
changes no rule; the coaching changes are study switches passed to every game of a block (`--extra a,b`).
    python3 tools/study/wr1000_clockwork_mirror.py list
    python3 tools/study/wr1000_clockwork_mirror.py run BLOCK [--extra sw1,sw2] [--jobs 2] [--end 1200] [--root DIR]
    python3 tools/study/wr1000_clockwork_mirror.py report [BLOCK ...] [--games]
    python3 tools/study/wr1000_clockwork_mirror.py csv
Data: docs/wr1000_clockwork_mirror/data/<BLOCK>/<tag>/ (result.json, story.txt, cwlog.txt); the switches of a block in
data/<BLOCK>/extra.txt.
A game's numbers (P1's view): score = income earned + 2 x army; g = ln(score P1 / score P2) at 20:00 or at the defeat (the
beaten side's score a quarter). A mirror is judged by how it ENDS, not by who wins: decided by 20:00, the median end, the
P1 (spot A) record, and the LEADER CONVERTS: of the decided games, how many the side ahead at 12:00 (10%+ on the score)
went on to win; |g| at the end (how clear the result is) and the lead changes after 8:00."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

DATA = os.path.join(qm.ROOT, "docs/wr1000_clockwork_mirror/data")
R0 = ["greenhold", "dune_sea", "frostfang", "ashford_crossing", "hollowfen", "cinder_steps"]
R1 = ["greenhold", "dune_sea", "frostfang", "ashford_crossing"]


def queue():
    want = set(("base_%s_cwcw_r0" % m) for m in R0) | set(("base_%s_cwcw_r1" % m) for m in R1)
    return [g for r in (0, 1) for g in qm.base(r) if g[0] in want]


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
        res = "W" if winner == 0 else "L"
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
    lead12 = 0 if g12 is None or abs(g12) < math.log(1.1) else (1 if g12 > 0 else -1)
    # lead changes after 8:00: the sign of the score ratio (10%+ either way) flips
    signs = []
    for mn in range(8, end // 60 + 1):
        v = gat(mn)
        if v is not None and abs(v) >= math.log(1.1):
            signs.append(1 if v > 0 else -1)
    flips = sum(1 for i in range(1, len(signs)) if signs[i] != signs[i - 1])
    win_side = 1 if res in ("W", "w") else (-1 if res in ("L", "l") else 0)
    picks = {0: [], 1: []}
    for x in sorted(g.get("reads", []), key=lambda x: x["t"]):
        if "pick" in x and x.get("pick"):
            picks[x["p"]].append(x["pick"])
    return {"tag": tag, "res": res, "end": end, "decided": winner >= 0, "g": gv, "g12": g12, "g14": gat(14),
            "lead12": lead12, "win_side": win_side, "flips": flips,
            "inc8": ratio("income", 8), "inc12": ratio("income", 12), "army8": ratio("army", 8),
            "army12": ratio("army", 12),
            "halls12": [at.get((p, 12), {}).get("halls") for p in (0, 1)], "picks": picks,
            "version": g.get("version", "")}


def block(name):
    rows = {}
    for d in sorted(glob.glob(os.path.join(DATA, name, "base_*"))):
        x = one(d)
        if x:
            rows[x["tag"]] = x
    return rows


def summary(name, rows):
    xs = list(rows.values())
    n = len(xs)
    dec = [x for x in xs if x["decided"]]
    ends = [x["end"] for x in dec]
    p1w = sum(1 for x in dec if x["res"] == "W")
    p2w = sum(1 for x in dec if x["res"] == "L")
    led = [x for x in xs if x["lead12"] != 0]
    conv = sum(1 for x in led if x["win_side"] == x["lead12"] and x["decided"])
    conv_any = sum(1 for x in led if x["win_side"] == x["lead12"])
    turned = sum(1 for x in led if x["win_side"] == -x["lead12"])
    mean = lambda v: sum(v) / len(v) if v else None
    return {"block": name, "n": n, "decided": len(dec), "end_med": st.median(ends) if ends else None,
            "p1w": p1w, "p2w": p2w, "p1g": mean([x["g"] for x in xs]),
            "absg": mean([abs(x["g"]) for x in xs]), "led12": len(led), "conv": conv, "conv_any": conv_any,
            "turned": turned, "flips": mean([x["flips"] for x in xs]),
            "p1_ahead": sum(1 for x in xs if x["res"] in ("W", "w")), "p2_ahead": sum(1 for x in xs if x["res"] in ("L", "l")),
            "inc8": mean([x["inc8"] for x in xs if x["inc8"]]), "army8": mean([x["army8"] for x in xs if x["army8"]]),
            "absg14": mean([abs(x["g14"]) for x in xs if x["g14"] is not None])}


def mmss(v):
    return "-" if v is None else "%d:%02d" % (int(v) // 60, int(v) % 60)


def f2(v):
    return "" if v is None else "%.2f" % v


HEAD = ("| block | n | decided by 20:00 | median end | P1 (spot A) W-L | P1 / P2 won or led | led at 12:00 | leader won "
        "(decided) | turned round | lead flips after 8:00 | mean abs g end | mean abs g 14:00 | P1 g | P1 inc 8 | P1 army 8 |")


def row(s):
    return "| %s | %d | %d | %s | %d-%d | %d / %d | %d | %d (%d) | %d | %s | %s | %s | %+.2f | %s | %s |" % (
        s["block"], s["n"], s["decided"], mmss(s["end_med"]), s["p1w"], s["p2w"], s["p1_ahead"], s["p2_ahead"],
        s["led12"], s["conv_any"], s["conv"], s["turned"], f2(s["flips"]), f2(s["absg"]), f2(s["absg14"]),
        s["p1g"] or 0.0, f2(s["inc8"]), f2(s["army8"]))


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
        out = os.path.abspath(arg("--out", "/tmp/wkm_out/" + name))
        end = int(arg("--end", "1200"))
        with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
            for t in ex.map(lambda g: qm.run_one(g, out, end, dd, extra), queue()):
                print("done", t, flush=True)
    elif cmd == "csv":
        import csv as _csv
        out = os.path.join(os.path.dirname(DATA), "blocks.csv")
        with open(out, "w", newline="") as f:
            w = _csv.writer(f)
            w.writerow(["block", "switches", "n", "decided", "median_end_s", "p1_wins", "p2_wins", "p1_won_or_led",
                        "p2_won_or_led", "led12", "leader_won", "leader_won_decided", "turned", "flips", "abs_g", "abs_g14",
                        "p1_g", "p1_inc8", "p1_army8"])
            for d in sorted(glob.glob(os.path.join(DATA, "b*"))):
                n = os.path.basename(d)
                ex = open(os.path.join(d, "extra.txt")).read().strip() if os.path.exists(os.path.join(d, "extra.txt")) else ""
                s = summary(n, block(n))
                r = lambda v, k=2: "" if v is None else round(v, k)
                w.writerow([n, ex, s["n"], s["decided"], r(s["end_med"], 0), s["p1w"], s["p2w"], s["p1_ahead"], s["p2_ahead"],
                            s["led12"], s["conv_any"], s["conv"], s["turned"], r(s["flips"]), r(s["absg"]), r(s["absg14"]),
                            r(s["p1g"]), r(s["inc8"]), r(s["army8"])])
        print(out)
    elif cmd == "report":
        names = [x for x in sys.argv[2:] if not x.startswith("--")]
        print(HEAD)
        print("|" + "---|" * HEAD.count("|")[:-0] if False else "|---" * (HEAD.count("|") - 1) + "|")
        for n in names:
            print(row(summary(n, block(n))))
        if "--games" in sys.argv:
            for n in names:
                print("\n" + n)
                for t, x in sorted(block(n).items()):
                    print("  %-32s %s %5s g %+.2f g12 %s lead12 %+d flips %d inc8 %s army8 %s halls12 %s P1 %s | P2 %s" % (
                        t, x["res"], mmss(x["end"]), x["g"], f2(x["g12"]), x["lead12"], x["flips"], f2(x["inc8"]),
                        f2(x["army8"]), x["halls12"], "/".join(x["picks"][0]), "/".join(x["picks"][1])))
    else:
        print(__doc__)
