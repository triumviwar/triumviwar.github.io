#!/usr/bin/env python3
"""CLOCKWORK v BROOD, COACHED AGAIN (clockwork-v-brood-coach-2, docs/clockwork_v_brood_coach_2.md): the 38 Brood v
Clockwork games of the win-rate studies (tools/study/qa_matches.py base(), the same tags, seeds and seats), run to 12:00 by
default, and the report from the CLOCKWORK's side. A measuring tool: it changes no rule.
    python3 tools/study/cvb2.py run OUT --data DATA [--jobs 2] [--end 720] [--root DIR] [--maps a,b,c] [--x arg,arg]
    python3 tools/study/cvb2.py report DATA [DATA2 ...]      (several DATA: a table each, then side by side)
--root: the project to run (a worktree of main for "before"); --x: more user args for every game (a switch, e.g.
cvb2:off); --maps: only those maps (the quick coaching loop), both seats of each.
The report: the Clockwork's W-D-L, won or led (a draw's leader: income earned + 2 x army 10% ahead, as the studies), income
a minute and army at 5/8/10/12, its built halls lost a game, its Winders lost 6:00-11:00 and where (by its order), and
what killed its units."""
import os, sys, json, glob, statistics as st
from collections import Counter
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm


def queue(maps):
    q = []
    for r in (0, 1):
        for g in qm.base(r):
            if g[0].split("_")[-2] == "brcw" and (not maps or g[1] in maps):
                q.append(g)
    return q


def load(data):
    rows = []
    for f in sorted(glob.glob(os.path.join(data, "base_*_brcw_r*", "result.json"))):
        g = json.load(open(f))
        facs = [s[0] for s in g["slots"]]
        si = facs.index("clockwork")
        oi = 1 - si
        at = {}
        for r in g["minutes"]:
            at[(r["p"], int(round(r["t"] / 60)))] = r
        sc = [f["income"] + 2 * f["army"] for f in g["final"]]
        if g["winner"] >= 0:
            res = "W" if g["winner"] == si else "L"
            lead = res
        else:
            res = "D"
            lead = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")
        halls = [0, 0]
        for e in g["events"]:
            if e.get("ev") == "hall_lost" and e.get("built"):
                halls[e["p"]] += 1
        rows.append({"tag": os.path.basename(os.path.dirname(f)), "g": g, "si": si, "oi": oi, "res": res, "lead": lead,
                     "at": at, "halls": halls, "end": g["end"]})
    return rows


def med(xs):
    xs = [x for x in xs if x is not None]
    return st.median(xs) if xs else None


def val(r, p, m, k):
    x = r["at"].get((p, m))
    return x[k] if x else None


def per_min(r, p, m):
    a, b = val(r, p, m, "income"), val(r, p, m - 1, "income")
    return None if a is None or b is None else a - b


def f0(x):
    return "-" if x is None else "{:,}".format(int(round(x)))


def summary(rows):
    w = sum(r["res"] == "W" for r in rows)
    d = sum(r["res"] == "D" for r in rows)
    l = sum(r["res"] == "L" for r in rows)
    wol = sum(r["lead"] in ("W", "w") for r in rows)
    lol = sum(r["lead"] in ("L", "l") for r in rows)
    s = {"n": len(rows), "wdl": "%d-%d-%d" % (w, d, l), "wol": "%d / %d / %d" % (wol, lol, len(rows) - wol - lol)}
    for m in (5, 8, 10, 12):
        s["inc%d" % m] = med([per_min(r, r["si"], m) for r in rows])
        s["binc%d" % m] = med([per_min(r, r["oi"], m) for r in rows])
        s["army%d" % m] = med([val(r, r["si"], m, "army") for r in rows])
        s["barmy%d" % m] = med([val(r, r["oi"], m, "army") for r in rows])
        s["earn%d" % m] = med([val(r, r["si"], m, "income") for r in rows])
    s["halls"] = sum(r["halls"][r["si"]] for r in rows) / max(1, len(rows))
    s["bhalls"] = sum(r["halls"][r["oi"]] for r in rows) / max(1, len(rows))
    win = Counter()
    orders = Counter()
    killers = Counter()
    for r in rows:
        for d in r["g"]["deaths"]:
            if d[2] != r["si"] or not (360 <= d[0] <= 660):
                continue
            killers[d[3]] += 1
            if d[1] == "winder":
                win["winders"] += 1
                if len(d) > 7:
                    orders[d[7]] += 1
            elif d[1] not in ("winder",):
                win["army"] += 1
    s["winders611"] = win["winders"] / max(1, len(rows))
    s["army611"] = win["army"] / max(1, len(rows))
    s["worders"] = orders
    s["killers"] = killers
    return s


def report(datas):
    P = print
    sums = []
    for data in datas:
        rows = load(data)
        if not rows:
            P("no games in", data)
            continue
        s = summary(rows)
        sums.append((data, s))
        P("## %s (%d games)\n" % (data, s["n"]))
        P("| game | result | lead | end | CW income/min 8:00 | 10:00 | CW army 8 / 10 / 12 | BR army 8 / 10 / 12 | CW halls lost |")
        P("|---|---|---|---|---|---|---|---|---|")
        for r in rows:
            P("| %s | %s | %s | %d:%02d | %s | %s | %s / %s / %s | %s / %s / %s | %d |" % (
                r["tag"].replace("base_", "").replace("_brcw", ""), r["res"], r["lead"], r["end"] // 60, r["end"] % 60,
                f0(per_min(r, r["si"], 8)), f0(per_min(r, r["si"], 10)),
                f0(val(r, r["si"], 8, "army")), f0(val(r, r["si"], 10, "army")), f0(val(r, r["si"], 12, "army")),
                f0(val(r, r["oi"], 8, "army")), f0(val(r, r["oi"], 10, "army")), f0(val(r, r["oi"], 12, "army")),
                r["halls"][r["si"]]))
        P("")
        P("Winders lost 6:00-11:00 by order: %s; killers of its units: %s\n" % (dict(s["worders"].most_common(8)),
                                                                              dict(s["killers"].most_common(6))))
    if sums:
        P("## Side by side (the Clockwork's view; medians)\n")
        P("| | " + " | ".join(os.path.basename(os.path.normpath(d)) for d, _ in sums) + " |")
        P("|---|" + "---|" * len(sums))
        keys = [("games", "n"), ("W-D-L", "wdl"), ("won or led / lost or trailed / even", "wol")]
        for m in (5, 8, 10, 12):
            keys.append(("CW income a minute at %d:00" % m, "inc%d" % m))
        for m in (5, 8, 10, 12):
            keys.append(("BR income a minute at %d:00" % m, "binc%d" % m))
        for m in (5, 8, 10, 12):
            keys.append(("CW army at %d:00" % m, "army%d" % m))
        for m in (5, 8, 10, 12):
            keys.append(("BR army at %d:00" % m, "barmy%d" % m))
        for m in (5, 8, 10, 12):
            keys.append(("CW earned by %d:00" % m, "earn%d" % m))
        keys += [("CW built halls lost a game", "halls"), ("BR grounds lost a game", "bhalls"),
                 ("CW Winders lost 6:00-11:00 a game", "winders611"), ("CW fighters lost 6:00-11:00 a game", "army611")]
        for name, k in keys:
            cells = []
            for _, s in sums:
                v = s[k]
                cells.append(("%.2f" % v) if isinstance(v, float) and k in ("halls", "bhalls", "winders611", "army611")
                             else (f0(v) if isinstance(v, (int, float)) and k != "n" else str(v)))
            P("| %s | %s |" % (name, " | ".join(cells)))


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if len(sys.argv) < 3 or sys.argv[1] not in ("run", "report", "list"):
        print(__doc__)
        sys.exit(1)
    if sys.argv[1] == "report":
        report([a for a in sys.argv[2:] if not a.startswith("--")])
        sys.exit(0)
    maps = [m for m in arg("--maps", "").split(",") if m]
    gl = queue(maps)
    if sys.argv[1] == "list":
        for g in gl:
            print(g)
        sys.exit(0)
    out = os.path.abspath(sys.argv[2])
    data = os.path.abspath(arg("--data", os.path.join(out, "data")))
    end = int(arg("--end", "720"))
    if "--root" in sys.argv:
        qm.RUN_ROOT = os.path.abspath(arg("--root", qm.ROOT))
    qm.EXTRA = [x for x in arg("--x", "").split(",") if x]
    print("%d games" % len(gl), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda g: qm.run_one(g, out, end, data), gl):
            print("done", t, flush=True)
