#!/usr/bin/env python3
"""CROWN COACH V BROOD (crown-coach-v-brood, docs/crown-coach-v-brood.md): Hard Crown OPTIMAL v Hard Brood OPTIMAL games
measured with tools/qa_match.gd, before and after this job's coaching. A measuring tool: it changes no rule.
    python3 tools/study/crown_coach_v_brood.py run OUT --data DATA [--only measure|r0|r1|extra|controls] [--jobs 2]
        [--end 900] [--root DIR] [--extra a:b,c:d]
    python3 tools/study/crown_coach_v_brood.py report DATA [DATA2 ...]
  measure: the 16 games of docs/crown_ai_v2.md (8 maps, 2 seeds, sides swapped; r0 / r1 = one seed each);
  extra:   8 more Crown v Brood games on other maps (ashford_crossing, kestrel_rise, redrock_canyon, ashfall; 2 seeds);
  controls: Crown OPTIMAL v Clockwork OPTIMAL and the Crown mirror on 3 maps (the matchups this job must not hurt).
--extra passes study switches to every game (e.g. cvb:off plays the Crown v Brood game plan as before this job)."""
import json, os, sys, glob
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as Q
import crown_ai_v2 as C

EXTRA_MAPS = ["ashford_crossing", "kestrel_rise", "redrock_canyon", "ashfall"]
CTRL = ["greenhold", "dune_sea", "hollowfen"]


def measure():
    return [g for g in C.measure((0,)) if "crbr" in g[0]]


def extra():
    out = []
    k = 0
    for m in EXTRA_MAPS:
        for r in range(2):
            me, foe = ("crown", "optimal"), ("brood", "optimal")
            s1, s2 = (foe, me) if r else (me, foe)
            out.append(("x_%s_crbr_r%d" % (m, r), m, 9700 + k, [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
            k += 1
    return out


def controls():
    return [g for g in C.measure((0,)) if ("crcw" in g[0] or "crcr" in g[0]) and g[1] in CTRL and g[0].endswith("_r0")]


def queue(only):
    q = []
    for part in only.split("+"):
        if part == "r0":
            q += [g for g in measure() if g[0].endswith("_r0")]
        elif part == "r1":
            q += [g for g in measure() if g[0].endswith("_r1")]
        else:
            q += {"measure": measure, "extra": extra, "controls": controls}[part]()
    return q


def summary(dd):
    rows = []
    for f in sorted(glob.glob(os.path.join(dd, "*", "result.json"))):
        d = json.load(open(f))
        tag = os.path.basename(os.path.dirname(f))
        crowns = [i for i, s in enumerate(d["slots"]) if s[0] == "crown"]
        if not crowns:
            continue
        c = crowns[0]
        fo = 1 - c
        by = {(m["p"], m["t"]): m for m in d["minutes"]}
        g = lambda p, t, k: (by.get((p, t)) or {}).get(k, 0) if (p, t) in by else None
        end = max(t for (_, t) in by)
        if d["winner"] == c:
            res = "W"
        elif d["winner"] == fo:
            res = "L"
        else:
            sc = (g(c, end, "income") or 0) + 2 * (g(c, end, "army") or 0)
            sf = (g(fo, end, "income") or 0) + 2 * (g(fo, end, "army") or 0)
            res = "D+" if sc > 1.1 * sf else ("D-" if sf > 1.1 * sc else "D=")
        ts = (240, 360, 480, 600, 720)
        rows.append(dict(tag=tag, res=res, end=end, foe=d["slots"][fo][0],
                         army=[(g(c, t, "army") or 0, g(fo, t, "army") or 0) for t in ts],
                         inc=[(g(c, t, "income") or 0, g(fo, t, "income") or 0) for t in (300, 480, 600)],
                         wk=[(g(c, t, "workers") or 0, g(fo, t, "workers") or 0) for t in (360, 480)],
                         lost=sum(1 for m in d["minutes"] if m["p"] == c and m["halls"] == 0)))
    return rows


def report(dirs):
    for dd in dirs:
        rows = summary(dd)
        for foe in sorted(set(r["foe"] for r in rows)):
            rs = [r for r in rows if r["foe"] == foe]
            cnt = Counter(r["res"][0] for r in rs)
            led = sum(1 for r in rs if r["res"] in ("W", "D+"))
            rat = lambda k, i: sum(r[k][i][0] for r in rs) / max(1, sum(r[k][i][1] for r in rs))
            dec = [r["end"] for r in rs if r["res"] == "L"]
            print("%-28s v %-9s %2d games  W-D-L %d-%d-%d  won/led %d  army 4/6/8/10/12 %s  income 5/8/10 %s  labs 6/8 %s  lost games end %s" % (
                os.path.basename(dd.rstrip("/")), foe, len(rs), cnt["W"], cnt["D"], cnt["L"], led,
                "/".join("%.2f" % rat("army", i) for i in range(5)), "/".join("%.2f" % rat("inc", i) for i in range(3)),
                "/".join("%.2f" % rat("wk", i) for i in range(2)),
                ("%d:%02d" % divmod(int(sum(dec) / len(dec)), 60)) if dec else "-"))
        if "--games" in sys.argv:
            for r in rows:
                print("   %-34s %-3s %4d army %s" % (r["tag"], r["res"], r["end"], r["army"]))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    arg = lambda k, dflt: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else dflt
    if sys.argv[1] == "report":
        report([a for a in sys.argv[2:] if not a.startswith("--")])
        sys.exit(0)
    gl = queue(arg("--only", "measure"))
    if sys.argv[1] == "list":
        for g in gl:
            print(g[0], g[1], g[2], g[3])
        sys.exit(0)
    out = os.path.abspath(sys.argv[2])
    Q.RUN_ROOT = os.path.abspath(arg("--root", Q.ROOT))
    if arg("--extra", ""):
        Q.EXTRA = arg("--extra", "").split(",")
    data = os.path.abspath(arg("--data", os.path.join(out, "data")))
    jobs = int(arg("--jobs", "2"))
    end = int(arg("--end", "900"))
    print("%d games" % len(gl), flush=True)
    with ThreadPoolExecutor(jobs) as ex:
        for t in ex.map(lambda g: Q.run_one(g, out, end, data), gl):
            print("done", t, flush=True)
