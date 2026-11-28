#!/usr/bin/env python3
"""CROWN MIRROR TO 20:00 (job crown-mirror-20, docs/crown_mirror_20.md; the owner said yes 2026-11-28).
Hard OPTIMAL Crown v Hard OPTIMAL Crown, every game to 20:00 (a defeat ends it sooner), on the six parity maps
(qa_matches.PARITY_MAPS), the same seeds as winrate-2026-11-26 (1126001 + i) so the baseline can be set beside it.

    game i: seed 1126001 + i, map PARITY_MAPS[i % 6], spot (i + i // 6) % 2
    spot 0: player 0 (P1) starts on spot A (as every game of winrate-2026-11-26)
    spot 1: the switch `spotswap` puts P1 on spot B (the same map, the same seed): 15 / 15 over 30 games, 10 / 10 over 20,
            so a start spot's edge can be told from player order.

Arms (each the same seeds; "base" 30 games, the others N_ARM):
    base   main as it is
    p2     `cm20guns:on`   the guns' spot against a main: shell it from behind the wave's formed line
    p3     `cm20gates:on`  a pressed wave goes past the shared rule's other gates (what holds it now)
    p4     `cm20fade:on`   the defender's advantage fades (a BALANCE change: measured only, never on by default)
    p23    p2 + p3

    python3 tools/study/crown_mirror_20.py list [ARM]
    python3 tools/study/crown_mirror_20.py run ARM[,ARM] [--jobs 2] [--root DIR] [--push] [--n N]
    python3 tools/study/crown_mirror_20.py report [ARM ...]     (markdown tables)
    python3 tools/study/crown_mirror_20.py games ARM            (one line a game)
Data: docs/crown_mirror_20/data/<arm>/<tag>/ (result.json, story.txt, mirror.txt: the match log's mirror lines).
Score = income earned + 2 x army at the bell or the defeat, a beaten side's score counted a quarter; g = ln(P1 / P2);
led = 10% ahead at the bell (the winrate-2026-11-26 rule)."""
import os, sys, json, glob, math, subprocess, statistics as st, shutil
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = qm.PARITY_MAPS
DATA = os.path.join(qm.ROOT, "docs/crown_mirror_20/data")
N = 30
N_ARM = 20
CUT = 1200
ARMS = {"base": [], "p2": ["cm20guns:on"], "p3": ["cm20gates:on"], "p4": ["cm20fade:on"], "p23": ["cm20guns:on", "cm20gates:on"]}
KEEP = ("presses", "pressed wave", "shell", "past the gates", "the guns' screen", "fades", "beaten", "hunt", "finisher", "pulls back", "Siege push", "wave goes", "attacks")
LOGS = "/tmp/claude-0/cm20_logs"


def spot_of(i):
    return (i + i // 6) % 2


def queue(arm, n=None):
    n = n or (N if arm == "base" else N_ARM)
    out = []
    for i in range(n):
        m = MAPS[i % 6]
        sp = spot_of(i)
        tag = "g%02d_%s_%s" % (i, m, "A" if sp == 0 else "B")
        out.append((tag, m, 1126001 + i, [("crown", "optimal", 0), ("crown", "optimal", 1)], ARMS[arm] + (["spotswap"] if sp else [])))
    return out


def run(arm, g, out, dd):
    tag, m, seed, slots, extra = g
    r = qm.run_one((tag, m, seed, slots), out, CUT, dd, extra)
    lf = os.path.join(LOGS, tag + ".log")
    if os.path.exists(lf):
        with open(lf, errors="replace") as f, open(os.path.join(dd, tag, "mirror.txt"), "w") as o:
            for l in f:
                if any(k in l for k in KEEP):
                    o.write(l)
        os.remove(lf)
    return r


def one(d):
    f = os.path.join(d, "result.json")
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    tag = os.path.basename(d)
    i = int(tag[1:3])
    sp = spot_of(i)
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
    s0 = sc[0] * (0.25 if winner == 1 else 1.0)
    s1 = sc[1] * (0.25 if winner == 0 else 1.0)
    gv = math.log(max(1.0, s0) / max(1.0, s1))
    if winner >= 0:
        res = "W" if winner == 0 else "L"
    else:
        res = "w" if sc[0] > 1.1 * sc[1] else ("l" if sc[1] > 1.1 * sc[0] else "=")

    def val(p, key, mn):
        x = at.get((p, mn))
        return None if x is None else x.get(key)

    def hmax(p):
        v = [x.get("halls") or 0 for x in g["minutes"] if x["p"] == p and x["t"] <= CUT + 30]
        return max(v) if v else None

    def hend(p):
        if winner >= 0 and p != winner:
            return 0
        return fin[p].get("halls")

    # the leader at 12:00 (score 10% ahead): did it win (finish) by 20:00?
    lead12 = None
    if (0, 12) in at and (1, 12) in at:
        a = at[(0, 12)]["income"] + 2 * at[(0, 12)]["army"]
        b = at[(1, 12)]["income"] + 2 * at[(1, 12)]["army"]
        lead12 = 0 if a > 1.1 * b else (1 if b > 1.1 * a else -1)
    lost = [None, None]
    for p in (0, 1):
        mx, e = hmax(p), hend(p)
        if mx is not None and e is not None:
            lost[p] = mx - e
    return {"tag": tag, "map": g.get("map", ""), "spot": sp, "res": res, "end": end, "g": gv, "sc": sc, "winner": winner,
            "lead12": lead12, "lost": lost, "halls20": (hend(0), hend(1)),
            "inc": {mn: (val(0, "income", mn), val(1, "income", mn)) for mn in (8, 12, 16)},
            "army": {mn: (val(0, "army", mn), val(1, "army", mn)) for mn in (8, 12, 16)},
            "plans": (fin[0].get("plan", ""), fin[1].get("plan", "")), "version": g.get("version", ""),
            "press": mlines(d, "presses its lead"), "held": mlines(d, "pressed wave is held"),
            "shell": mlines(d, "shells the enemy hall"), "along": mlines(d, "past the gates"),
            "screen": mlines(d, "the guns' screen")}


def mlines(d, s):
    f = os.path.join(d, "mirror.txt")
    if not os.path.exists(f):
        return None
    return sum(1 for l in open(f, errors="replace") if s in l)


def rows_of(arm, n=None):
    rows = []
    for d in sorted(glob.glob(os.path.join(DATA, arm, "g*"))):
        if n is not None and int(os.path.basename(d)[1:3]) >= n:
            continue
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
    dec = [x["end"] / 60.0 for x in rows if x["res"] in ("W", "L")]
    # the side on spot A (P1 in spot-0 games, P2 in spot-1 games)
    a_wl = sum(1 for x in rows if (x["res"] in "Ww" and x["spot"] == 0) or (x["res"] in "Ll" and x["spot"] == 1))
    b_wl = sum(1 for x in rows if (x["res"] in "Ll" and x["spot"] == 0) or (x["res"] in "Ww" and x["spot"] == 1))
    a_g = [x["g"] if x["spot"] == 0 else -x["g"] for x in rows]
    leads = [x for x in rows if x["lead12"] in (0, 1)]
    fin = sum(1 for x in leads if x["winner"] == x["lead12"])
    kept = sum(1 for x in leads if x["winner"] == x["lead12"] or (x["winner"] < 0 and x["res"] == ("w" if x["lead12"] == 0 else "l")))
    turned = sum(1 for x in leads if (x["winner"] >= 0 and x["winner"] != x["lead12"]) or (x["winner"] < 0 and x["res"] == ("l" if x["lead12"] == 0 else "w")))
    lost = [sum(x["lost"]) for x in rows if None not in x["lost"]]
    return {"n": len(rows), "c": c, "dec": len(dec), "dec_med": st.median(dec) if dec else None,
            "p1": c["W"] + c["w"], "p2": c["L"] + c["l"], "a": a_wl, "b": b_wl, "ag": mean(a_g) or 0.0, "at": tstat(a_g),
            "leads": len(leads), "fin": fin, "kept": kept, "turned": turned, "lost": mean(lost),
            "g_abs": mean([abs(x["g"]) for x in rows]),
            "press": mean([x["press"] for x in rows]), "held": mean([x["held"] for x in rows]),
            "shell": mean([x["shell"] for x in rows]), "along": mean([x["along"] for x in rows]),
            "screen": mean([x["screen"] for x in rows]),
            "inc12": mean([(x["inc"][12][0] or 0) + (x["inc"][12][1] or 0) for x in rows]),
            "army12": mean([(x["army"][12][0] or 0) + (x["army"][12][1] or 0) for x in rows])}


def f1(v, fmt="%.1f"):
    return "-" if v is None else fmt % v


TITLE = {"base": "main as it is", "p2": "P2 guns' screen (cm20guns:on)", "p3": "P3 past the gates (cm20gates:on)",
         "p4": "P4 fading defence (cm20fade:on)", "p23": "P2 + P3"}


def report(arms):
    print("| arm | games | decided (median min) | P1 won-led-even-led-won P2 | spot A won or led / spot B (mean g for A, t) | leader at 12:00: finished / kept / turned (of) | halls lost a game | mean abs g |")
    print("|---|---|---|---|---|---|---|---|")
    for arm in arms:
        for n in ([None, N_ARM] if arm == "base" else [None]):
            rows = rows_of(arm, n)
            if not rows:
                continue
            s = summ(rows)
            c = s["c"]
            name = TITLE[arm] + (" (first %d)" % n if n else "")
            print("| %s | %d | %d (%s) | %d-%d-%d-%d-%d | %d / %d (%+.2f, %.1f) | %d / %d / %d (%d) | %s | %.2f |" % (
                name, s["n"], s["dec"], f1(s["dec_med"]), c["W"], c["w"], c["="], c["l"], c["L"], s["a"], s["b"], s["ag"], s["at"],
                s["fin"], s["kept"], s["turned"], s["leads"], f1(s["lost"]), s["g_abs"] or 0.0))
    print()
    print("| arm | presses a game | pressed waves held (lines) | shellings | waves past the gates | guns' screens | income 12:00 (both) | army 12:00 (both) |")
    print("|---|---|---|---|---|---|---|---|")
    for arm in arms:
        rows = rows_of(arm)
        if not rows:
            continue
        s = summ(rows)
        print("| %s | %s | %s | %s | %s | %s | %s | %s |" % (TITLE[arm], f1(s["press"]), f1(s["held"]), f1(s["shell"]), f1(s["along"]),
              f1(s["screen"]), f1(s["inc12"] / 1000.0 if s["inc12"] else None, "%.1fk"), f1(s["army12"] / 1000.0 if s["army12"] else None, "%.1fk")))


def pairs(arm):
    """game by game against the base (the same seeds): decided / not, |g|."""
    b = {x["tag"]: x for x in rows_of("base")}
    out = []
    for x in rows_of(arm):
        y = b.get(x["tag"])
        if y:
            out.append((x["tag"], y["res"], x["res"], y["end"] / 60.0, x["end"] / 60.0))
    return out


def push(msg):
    subprocess.run(["git", "-C", qm.ROOT, "add", "docs/crown_mirror_20"], check=False)
    r = subprocess.run(["git", "-C", qm.ROOT, "-c", "user.name=Salgarellius", "-c",
                        "user.email=337888439+cavaleirobrancopensante@users.noreply.github.com", "commit", "-q", "-m",
                        msg + "\n\nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>\n"
                        "Claude-Session: https://claude.ai/code/session_01NtmEZhP1uA8k4DLQ7BYfMz"], check=False)
    if r.returncode == 0:
        subprocess.run(["git", "-C", qm.ROOT, "push", "-q", "origin", "HEAD"], check=False)


if __name__ == "__main__":
    arg = lambda key, d: sys.argv[sys.argv.index(key) + 1] if key in sys.argv else d
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "list":
        for arm in ([sys.argv[2]] if len(sys.argv) > 2 else ARMS):
            for g in queue(arm):
                print(arm, *g)
    elif cmd == "run":
        arms = sys.argv[2].split(",")
        qm.RUN_ROOT = os.path.abspath(arg("--root", qm.ROOT))
        qm.LOG_DIR = LOGS
        jobs = int(arg("--jobs", "2"))
        n = int(arg("--n", "0")) or None
        work = []
        for arm in arms:
            dd = os.path.join(DATA, arm)
            os.makedirs(dd, exist_ok=True)
            work += [(arm, g, "/tmp/claude-0/cm20_out/" + arm, dd) for g in queue(arm, n)]
        work.sort(key=lambda w: (int(w[1][0][1:3]), arms.index(w[0])))
        done = [0]
        with ThreadPoolExecutor(jobs) as ex:
            for t in ex.map(lambda w: (w[0], run(*w)), work):
                print("done", *t, flush=True)
                if "(had)" not in t[1]:
                    done[0] += 1
                    if "--push" in sys.argv and done[0] % 6 == 0:
                        push("crown-mirror-20: data (%d more games)" % 6)
        if "--push" in sys.argv:
            push("crown-mirror-20: data")
    elif cmd == "report":
        report(sys.argv[2:] or list(ARMS))
    elif cmd == "games":
        for x in rows_of(sys.argv[2]):
            print("%-26s %s %5.1f g %+.2f lead12 %s halls20 %s/%s lost %s press %s held %s shell %s along %s screen %s plans %s/%s" % (
                x["tag"], x["res"], x["end"] / 60.0, x["g"], x["lead12"], x["halls20"][0], x["halls20"][1], x["lost"],
                x["press"], x["held"], x["shell"], x["along"], x["screen"], *x["plans"]))
    elif cmd == "pairs":
        for p in pairs(sys.argv[2]):
            print("%-26s base %s %4.1f  arm %s %4.1f" % (p[0], p[1], p[3], p[2], p[4]))
    else:
        print(__doc__)
