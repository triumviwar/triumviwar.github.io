#!/usr/bin/env python3
"""THE MOTHER GETS UP (brood-mother-uproot, docs/brood_mother_uproot.md): the lingering swamp, waiting Rootmaws and the
Rootmaws rooting back by themselves, with the Brood computer taught to use it, ON (the default) against OFF
(`-- broodlinger:off`, the game as before), in computer games: Brood Hard OPTIMAL v the Crown, v the Clockwork and the
Brood mirror (both Broods play the arm), the same 10 games a cell (5 maps x 2 rounds, start spots swapped), to END.
    python3 tools/study/brood_mother_uproot.py run ARM OPP [--jobs 2] [--end 900] [--extra a:b]   ARM: on | off | <name>
    python3 tools/study/brood_mother_uproot.py report [ARM ...]
Data: docs/brood_mother_uproot/data/<ARM>/<OPP>/<tag>/ (result.json, story.txt).
Score (the crown-1000 jobs'): g = ln of (income + 2 x army) Brood over the enemy's at the bell or the defeat (a beaten
side's counted a quarter); in the mirror side 0's. "v off": the paired difference game by game, its t, better/worse."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = ["greenhold", "ashford_crossing", "mirewood", "frostfang", "cinder_steps"]
DATA = os.path.join(qm.ROOT, "docs/brood_mother_uproot/data")
OPPS = ["crown", "clockwork", "brood"]
OPP_I = {"crown": 0, "brood": 1, "clockwork": 2}
ARM_ARGS = {"off": ["broodlinger:off"], "on": []}


def queue(opp):
    out = []
    for mi, m in enumerate(MAPS):
        for r in (0, 1):
            seed = 9300 + 97 * r + 11 * mi + 3 * OPP_I[opp]
            swap = (r + mi) % 2 == 1
            me, foe = ("brood", "optimal"), (opp, "optimal")
            s1, s2 = (foe, me) if swap else (me, foe)
            out.append(("bmu_%s_r%d" % (m, r), m, seed, [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
    return out


def run(arm, opp, jobs=2, end=900, extra=None):
    dd = os.path.join(DATA, arm, opp)
    os.makedirs(dd, exist_ok=True)
    args = ARM_ARGS.get(arm, []) + (extra or [])
    with open(os.path.join(dd, "extra.txt"), "w") as f:
        f.write(" ".join(args) + "\n")
    qm.RUN_ROOT = os.path.abspath(qm.ROOT)
    out = "/tmp/bmu_out/%s_%s" % (arm, opp)
    with ThreadPoolExecutor(jobs) as ex:
        for t in ex.map(lambda g: qm.run_one(g, out, end, dd, args), queue(opp)):
            print("done", arm, opp, t, flush=True)


def one(d, opp):
    f = os.path.join(d, "result.json")
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    tag = os.path.basename(d)
    m = tag[4:].rsplit("_r", 1)[0]
    r = int(tag.rsplit("_r", 1)[1])
    si = 1 if (r + MAPS.index(m)) % 2 == 1 else 0
    if opp == "brood":
        si = 0
    oi = 1 - si
    at = {}
    for x in g["minutes"]:
        at[(x["p"], int(round(x["t"] / 60)))] = x
    end, winner, fin = g["end"], g["winner"], g["final"]
    sc = [x["income"] + 2 * x["army"] for x in fin]
    s_me = sc[si] * (0.25 if winner == oi else 1.0)
    s_op = sc[oi] * (0.25 if winner == si else 1.0)
    gv = math.log(max(1.0, s_me) / max(1.0, s_op))
    if winner >= 0:
        res = "W" if winner == si else "L"
    else:
        res = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")

    def val(p, key, mn):
        for k in range(mn, -1, -1):
            if (p, k) in at:
                return at[(p, k)].get(key)
        return None

    def ratio(key, mn):
        a, b = val(si, key, mn), val(oi, key, mn)
        return (a / b) if a and b else None
    bl = (g.get("brood_linger") or {}).get(str(si), {})
    return {"tag": tag, "res": res, "end": end, "g": gv, "inc5": ratio("income", 5), "inc8": ratio("income", 8),
            "inc12": ratio("income", 12), "income12": val(si, "income", 12), "income8": val(si, "income", 8),
            "army8": ratio("army", 8), "maws12": val(si, "maws", 12), "up": bl.get("up", 0), "lost": bl.get("lost", 0),
            "wait_s": bl.get("wait_s", 0), "auto": bl.get("auto", 0), "beaten": end if res == "L" else None}


def cell(arm, opp):
    rows = {}
    for d in sorted(glob.glob(os.path.join(DATA, arm, opp, "bmu_*"))):
        x = one(d, opp)
        if x:
            rows[x["tag"]] = x
    return rows


def mean(v):
    v = [x for x in v if x is not None]
    return sum(v) / len(v) if v else None


def f2(x, n=2):
    return "-" if x is None else ("%." + str(n) + "f") % x


def report(arms):
    lines = []
    for opp in OPPS:
        base = cell("off", opp)
        lines.append("\n### Brood v %s\n" % {"crown": "the Crown", "clockwork": "the Clockwork", "brood": "the Brood (mirror, side 0)"}[opp])
        lines.append("| arm | games | won | won or led | lost | mean g | v off: diff g (t), better/worse | income 8:00 | income 12:00 (ratio) | Rootmaws 12:00 | Mother up | Rootmaws lost swamp | waited (Rootmaw-s) | rooted back |")
        lines.append("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for arm in arms:
            rows = cell(arm, opp)
            if not rows:
                continue
            rs = list(rows.values())
            won = sum(1 for x in rs if x["res"] == "W")
            wl = sum(1 for x in rs if x["res"] in ("W", "w"))
            lost = sum(1 for x in rs if x["res"] in ("L", "l"))
            cmpx = "-"
            if arm != "off" and base:
                ds = [rows[t]["g"] - base[t]["g"] for t in rows if t in base]
                if len(ds) >= 2:
                    md = sum(ds) / len(ds)
                    sd = st.stdev(ds)
                    tt = md / (sd / math.sqrt(len(ds))) if sd > 0 else 0.0
                    cmpx = "%+.2f (t %.1f), %d/%d" % (md, tt, sum(1 for x in ds if x > 0.05), sum(1 for x in ds if x < -0.05))
            lines.append("| %s | %d | %d | %d | %d | %+.2f | %s | %s | %s | %s | %s | %s | %s | %s |" % (
                arm, len(rs), won, wl, lost, mean([x["g"] for x in rs]), cmpx, f2(mean([x["inc8"] for x in rs])),
                f2(mean([x["inc12"] for x in rs])), f2(mean([x["maws12"] for x in rs]), 1), f2(mean([x["up"] for x in rs]), 1),
                f2(mean([x["lost"] for x in rs]), 1), f2(mean([x["wait_s"] for x in rs]), 0), f2(mean([x["auto"] for x in rs]), 1)))
    return "\n".join(lines)


if __name__ == "__main__":
    a = sys.argv[1:]
    if a and a[0] == "run":
        jobs = int(a[a.index("--jobs") + 1]) if "--jobs" in a else 2
        end = int(a[a.index("--end") + 1]) if "--end" in a else 900
        extra = a[a.index("--extra") + 1].split(",") if "--extra" in a else None
        run(a[1], a[2], jobs, end, extra)
    elif a and a[0] == "report":
        print(report(a[1:] or ["off", "on"]))
    else:
        print(__doc__)
