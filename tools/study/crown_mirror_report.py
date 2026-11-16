#!/usr/bin/env python3
"""CROWN MIRROR COACH (docs/crown_mirror_coach.md): the measuring table of Crown mirror batches made with
tools/study/crown_mirror_coach.py (one folder per game: result.json, log.txt, coach.txt). A measuring tool: it changes no rule.
    python3 tools/study/crown_mirror_report.py DIR [DIR2 ...]          (a table row per DIR)
    python3 tools/study/crown_mirror_report.py --games DIR              (a line per game)
Definitions: score = income + 2 x army (as crown-v-crown-coach); "led" = ahead at the end by 10% on score; "won or led" =
decided for it or led; a "lead" at a minute = score 1.15 x the other's; "idle ahead" = a minute where a side's army is
1.3 x the other's (and 800+) and it has no wave out; "dominant" = army 1.8 x and 800+, "converted" = an enemy hall lost
within 3 minutes. The spot edge: a two-sided sign test on P1 v P2 won-or-led."""
import json, sys, glob, os, re, math, statistics as S

COACH = re.compile(r"(\d+):(\d+) \| (.*)")
SIDE = re.compile(r"army (\d+).*? halls (\d+) att (true|false)")


def binom_p(k, n):
    """two-sided exact sign test"""
    if n == 0:
        return 1.0
    k = min(k, n - k)
    p = sum(math.comb(n, i) for i in range(0, k + 1)) / 2 ** n
    return min(1.0, 2 * p)


def coach_rows(d):
    out = {}
    fn = os.path.join(d, "coach.txt")
    if not os.path.exists(fn):
        return out
    for l in open(fn, errors="replace"):
        m = COACH.match(l)
        if not m:
            continue
        t = int(m.group(1)) * 60 + int(m.group(2))
        parts = m.group(3).split(" | ")
        sides = []
        for p in parts[:2]:
            s = SIDE.search(p)
            sides.append((int(s.group(1)), int(s.group(2)), s.group(3) == "true") if s else None)
        out[t] = sides
    return out


def game(d):
    r = json.load(open(os.path.join(d, "result.json")))
    m = {(x["t"], x["p"]): x for x in r["minutes"]}
    fin = {x["p"]: x for x in r["final"]}
    sc = lambda x: x["income"] + 2 * x["army"]
    end = r["end"]
    lead = r["winner"] if r["winner"] >= 0 else (0 if sc(fin[0]) > 1.1 * sc(fin[1]) else 1 if sc(fin[1]) > 1.1 * sc(fin[0]) else -1)
    halls = [e for e in r["events"] if e["ev"] == "hall_lost"]
    log = open(os.path.join(d, "log.txt"), errors="replace").read() if os.path.exists(os.path.join(d, "log.txt")) else ""
    waves = [len(re.findall(r"P%d Crown's (first attack goes out|wave \d+ goes out)" % (p + 1), log)) for p in (0, 1)]
    pulls = len(re.findall(r"pulls its wave back|Crown pulls back from the ", log))
    dom = conv = 0
    for t in range(360, end + 1, 60):
        for p in (0, 1):
            a, b = m.get((t, p)), m.get((t, 1 - p))
            if a and b and a["army"] >= 800 and a["army"] >= 1.8 * max(1, b["army"]):
                dom += 1
                if any(e["p"] == 1 - p and t <= e["t"] <= t + 180 for e in halls):
                    conv += 1
    ratio = {}
    leader = {}
    for t in (480, 720, 900):
        a, b = m.get((t, 0)), m.get((t, 1))
        if a and b:
            sa, sb = sc(a), sc(b)
            ratio[t] = max(sa, sb) / max(1, min(sa, sb))
            leader[t] = 0 if sa > 1.15 * sb else 1 if sb > 1.15 * sa else -1
    cr = coach_rows(d)
    idle = 0
    for t, s in cr.items():
        if t < 360 or None in s or len(s) < 2:
            continue
        for p in (0, 1):
            a, b = s[p], s[1 - p]
            if a[0] >= 800 and a[0] >= 1.3 * max(1, b[0]) and not a[2]:
                idle += 0.25
    plans = [fin[p].get("plan", "") for p in (0, 1)]
    return dict(name=os.path.basename(d), end=end, winner=r["winner"], lead=lead, halls=len(halls),
                halls_p=[sum(1 for e in halls if e["p"] == p) for p in (0, 1)], waves=waves, pulls=pulls, dom=dom,
                conv=conv, ratio=ratio, leader=leader, idle=idle, plans=plans, m=m,
                beaten="beaten: nothing left" in log)


def rows(d):
    return [game(os.path.dirname(f)) for f in sorted(glob.glob(os.path.join(d, "*", "result.json")))]


def mean(v):
    return S.mean(v) if v else float("nan")


def table(dirs):
    print("| batch | games | decided | W-D-L (P1) | P1 won or led - P2 | spot p | mean length | halls lost / game | waves / game | "
          "score lead 8:00 / 12:00 / 15:00 (median) | leader at 8:00 still ahead at 15:00 | idle-ahead min / game | "
          "dominant min -> hall in 3 min |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    for d in dirs:
        g = rows(d)
        if not g:
            continue
        n = len(g)
        dec = [x for x in g if x["winner"] >= 0]
        w1 = sum(1 for x in dec if x["winner"] == 0)
        w2 = len(dec) - w1
        l1 = sum(1 for x in g if x["lead"] == 0)
        l2 = sum(1 for x in g if x["lead"] == 1)
        meds = []
        for t in (480, 720, 900):
            v = [x["ratio"][t] for x in g if t in x["ratio"]]
            meds.append("%.2f" % S.median(v) if v else "-")
        kept = [x for x in g if x["leader"].get(480, -1) >= 0]
        kk = sum(1 for x in kept if x["lead"] == x["leader"][480])
        print("| %s | %d | %d | %d-%d-%d | %d - %d | %.3f | %s | %.2f | %.1f | %s | %d of %d | %.1f | %d -> %d |" % (
            os.path.basename(os.path.normpath(d)), n, len(dec), w1, n - len(dec), w2, l1, l2, binom_p(l1, l1 + l2),
            "%d:%02d" % divmod(int(mean([x["end"] for x in g])), 60), mean([x["halls"] for x in g]),
            mean([sum(x["waves"]) for x in g]), " / ".join(meds), kk, len(kept), mean([x["idle"] for x in g]),
            sum(x["dom"] for x in g), sum(x["conv"] for x in g)))


def games(d):
    for x in rows(d):
        res = ("P%d won %d:%02d" % (x["winner"] + 1, *divmod(x["end"], 60))) if x["winner"] >= 0 else (
            "draw, P%d led" % (x["lead"] + 1) if x["lead"] >= 0 else "draw, even")
        print("%-34s %-22s %-18s ratio8 %.2f r12 %.2f r15 %.2f halls lost %s waves %s idle-ahead %.1f" % (
            x["name"], " v ".join(x["plans"]), res, x["ratio"].get(480, 0), x["ratio"].get(720, 0), x["ratio"].get(900, 0),
            x["halls_p"], x["waves"], x["idle"]))


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "--games":
        games(sys.argv[2])
    else:
        table(sys.argv[1:])
