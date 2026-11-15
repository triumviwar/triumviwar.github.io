#!/usr/bin/env python3
"""NO FARM/PRESS LIMIT, the benches for all three sides (job econ-nocap-all, docs/econ_nocap_all.md). GROUND ON in every run.
    python3 tools/study/econ_nocap_all_bench.py run DIR [--jobs 1] [--maps greenhold,hollowfen,dune_sea,highmoor]
    python3 tools/study/econ_nocap_all_bench.py report DIR > bench_report.md
Runs:
  bench_<fac>_<map>_d<N>      tools/econ_bench.gd, the scripted ideal build, N Farms / Presses a hall (2 = the limit kept,
                              3 and 4 with groundcap=off); the Brood: _kept / _drop (it has no such limit: a check)
  alone_<fac>_<map>_<arm>     the Hard OPTIMAL computer alone (tools/econ_ai_alone.gd; the Brood: econ_ai_alone_brood.gd)
Each writes <name>.json (the tool's RESULT) and <name>.out (its log: the '(ground)' lines date the dry districts)."""
import json, os, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MAPS = ["greenhold", "hollowfen", "dune_sea", "highmoor"]
FACS = ["crown", "clockwork", "brood"]
MINS = [5, 8, 10, 12, 15, 20]


def runs(maps):
    out = []
    for mp in maps:
        for f in FACS:
            if f == "brood":
                out.append(("bench_%s_%s_kept" % (f, mp), "econ_bench", [f, "map=" + mp, "ground=1"]))
                out.append(("bench_%s_%s_drop" % (f, mp), "econ_bench", [f, "map=" + mp, "ground=1", "groundcap=off"]))
                out.append(("alone_%s_%s_kept" % (f, mp), "econ_ai_alone_brood", [f, "minutes=20", "map=" + mp, "ground=1"]))
                out.append(("alone_%s_%s_drop" % (f, mp), "econ_ai_alone_brood", [f, "minutes=20", "map=" + mp, "ground=1", "groundcap=off"]))
            else:
                out.append(("bench_%s_%s_d2" % (f, mp), "econ_bench", [f, "map=" + mp, "ground=1"]))
                for n in (3, 4):
                    out.append(("bench_%s_%s_d%d" % (f, mp, n), "econ_bench", [f, "map=" + mp, "ground=1", "groundcap=off", "drink=%d" % n]))
                foe = "clockwork" if f == "crown" else "crown"
                out.append(("alone_%s_%s_kept" % (f, mp), "econ_ai_alone", [f, "minutes=20", "map=" + mp, "foe=" + foe, "ground=1"]))
                out.append(("alone_%s_%s_drop" % (f, mp), "econ_ai_alone", [f, "minutes=20", "map=" + mp, "foe=" + foe, "ground=1", "groundcap=off"]))
    return out


def run_one(r, d):
    name, tool, args = r
    js = os.path.join(d, name + ".json")
    if os.path.exists(js):
        return name + " (had)"
    cmd = ["timeout", "2400", "godot", "--headless", "--fixed-fps", "30", "--path", ROOT, "--script", "res://tools/%s.gd" % tool,
           "--"] + args + ["out=" + js]
    with open(os.path.join(d, name + ".out"), "wb") as f:
        rc = subprocess.call(cmd, stdout=f, stderr=subprocess.STDOUT)
    if not os.path.exists(js):   # (some tools only print the RESULT line)
        for l in open(os.path.join(d, name + ".out"), errors="replace"):
            if l.startswith("RESULT "):
                open(js, "w").write(l[7:])
    return "%s rc %d" % (name, rc)


def load(p):
    try:
        return json.load(open(p))
    except Exception:
        return None


def cum(rows, m, key):
    r = [x for x in rows if x.get("min") == m]
    if not r:
        return None
    return r[0].get(key, r[0].get("p_cum"))


def dry_times(out):
    first = {}
    if not os.path.exists(out):
        return []
    for l in open(out, errors="replace"):
        m = re.search(r"\(ground\) (\d+) s: a spent \S+ at .* district \[([\d.e+-]+), ([\d.e+-]+)\]", l)
        if m:
            t, left, full = int(m.group(1)), float(m.group(2)), float(m.group(3))
            key = round(full)
            if left < 0.05 * full and key not in first:
                first[key] = t
    return sorted(first.values())


def mmss(t):
    return "%d:%02d" % (int(t) // 60, int(t) % 60)


def summary(d, maps):
    """{fac: {map: {arm: {"inc": {m: v}, ...}}}}"""
    S = {}
    for f in FACS:
        S[f] = {}
        for mp in maps:
            e = {}
            arms = [("kept", "kept"), ("drop", "drop")] if f == "brood" else [("d2", "kept"), ("d3", "drop3"), ("d4", "drop4")]
            for suf, lab in arms:
                j = load(os.path.join(d, "bench_%s_%s_%s.json" % (f, mp, suf)))
                if j:
                    e["bench_" + lab] = {"inc": {m: cum(j["rows"], m, "value_cum") for m in MINS},
                                         "dry": dry_times(os.path.join(d, "bench_%s_%s_%s.out" % (f, mp, suf))),
                                         "halls": j["rows"][-1].get("econ", {}).get("halls")}
            for arm in ("kept", "drop"):
                j = load(os.path.join(d, "alone_%s_%s_%s.json" % (f, mp, arm)))
                if j:
                    last = j["rows"][-1]
                    ek = {"crown": "farm", "clockwork": "cog_press", "brood": "rootmaw"}[f]
                    econ = last.get("econ", {}) if isinstance(last.get("econ"), dict) else {}
                    e["alone_" + arm] = {"inc": {m: cum(j["rows"], m, "value_cum") for m in MINS},
                                         "halls_at": j.get("halls_at", []), "workers": last.get("workers"),
                                         "drinkers": econ.get(ek), "halls": econ.get("halls"),
                                         "dry": dry_times(os.path.join(d, "alone_%s_%s_%s.out" % (f, mp, arm)))}
            S[f][mp] = e
    return S


def report(d, maps):
    S = summary(d, maps)
    print("## The scripted bench (ideal build, ground ON): income earned by m:00 (cumulative value), the limit dropped as a share of kept\n")
    print("| faction, map | arm | " + " | ".join("%d:00" % m for m in MINS) + " | districts dry at |")
    print("|---|---|" + "---|" * len(MINS) + "---|")
    for f in FACS:
        for mp in maps:
            e = S[f][mp]
            base = e.get("bench_kept")
            for lab in ("kept", "drop", "drop3", "drop4"):
                x = e.get("bench_" + lab)
                if not x:
                    continue
                cells = []
                for m in MINS:
                    v, b = x["inc"][m], base["inc"][m] if base else None
                    cells.append("-" if v is None else ("%d" % v if lab == "kept" or not b else "%.2f" % (v / b)))
                name = {"kept": "kept (2 a hall)" if f != "brood" else "kept", "drop": "dropped", "drop3": "dropped, 3 a hall",
                        "drop4": "dropped, 4 a hall"}[lab]
                print("| %s, %s | %s | %s | %s |" % (f.capitalize(), mp, name, " | ".join(cells), ", ".join(mmss(t) for t in x["dry"]) or "-"))
    print("\n## The computer alone (Hard OPTIMAL, nobody in its way, ground ON): income earned by m:00, dropped as a share of kept\n")
    print("| faction, map | arm | " + " | ".join("%d:00" % m for m in MINS) + " | halls up at | workers 20:00 | Farms/Presses/Rootmaws 20:00 | districts dry at |")
    print("|---|---|" + "---|" * len(MINS) + "---|---|---|---|")
    for f in FACS:
        for mp in maps:
            e = S[f][mp]
            base = e.get("alone_kept")
            for arm in ("kept", "drop"):
                x = e.get("alone_" + arm)
                if not x:
                    continue
                cells = []
                for m in MINS:
                    v, b = x["inc"][m], base["inc"][m] if base else None
                    cells.append("-" if v is None else ("%d" % v if arm == "kept" or not b else "%.2f" % (v / b)))
                print("| %s, %s | %s | %s | %s | %s | %s | %s |" % (f.capitalize(), mp, "kept" if arm == "kept" else "dropped",
                      " | ".join(cells), ", ".join(mmss(t) for t in x["halls_at"]) or "-", x["workers"], x["drinkers"],
                      ", ".join(mmss(t) for t in x["dry"]) or "-"))
    print("\n## Parity, the bench (ideal build, value earned by m:00 as a share of the Crown's on the same map)\n")
    print("| map | arm | Clockwork 8:00 | 12:00 | 15:00 | Brood 8:00 | 12:00 | 15:00 |")
    print("|---|---|---|---|---|---|---|---|")
    for mp in maps:
        for lab, cl, bl in (("kept", "bench_kept", "bench_kept"), ("dropped, 3 a hall", "bench_drop3", "bench_drop"),
                            ("dropped, 4 a hall", "bench_drop4", "bench_drop")):
            c = S["crown"][mp].get(cl)
            w = S["clockwork"][mp].get(cl)
            b = S["brood"][mp].get(bl)
            if not c:
                continue
            cells = []
            for x in (w, b):
                for m in (8, 12, 15):
                    cells.append("%.2f" % (x["inc"][m] / c["inc"][m]) if x and x["inc"][m] and c["inc"][m] else "-")
            print("| %s | %s | %s |" % (mp, lab, " | ".join(cells)))
    print("\n## Parity, the computers alone (value earned by m:00 as a share of the Crown computer's on the same map)\n")
    print("| map | arm | Clockwork 8:00 | 12:00 | 15:00 | Brood 8:00 | 12:00 | 15:00 |")
    print("|---|---|---|---|---|---|---|---|")
    for mp in maps:
        for arm in ("kept", "drop"):
            c = S["crown"][mp].get("alone_" + arm)
            if not c:
                continue
            cells = []
            for f in ("clockwork", "brood"):
                x = S[f][mp].get("alone_" + arm)
                for m in (8, 12, 15):
                    cells.append("%.2f" % (x["inc"][m] / c["inc"][m]) if x and x["inc"][m] and c["inc"][m] else "-")
            print("| %s | %s | %s |" % (mp, "kept" if arm == "kept" else "dropped", " | ".join(cells)))
    return S


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    d = a[1]
    maps = a[a.index("--maps") + 1].split(",") if "--maps" in a else MAPS
    if a[0] == "run":
        os.makedirs(d, exist_ok=True)
        jobs = int(a[a.index("--jobs") + 1]) if "--jobs" in a else 1
        rs = runs(maps)
        print("%d runs" % len(rs), flush=True)
        with ThreadPoolExecutor(jobs) as ex:
            for r in ex.map(lambda x: run_one(x, d), rs):
                print(r, flush=True)
    elif a[0] == "report":
        report(d, maps)
    elif a[0] == "json":
        print(json.dumps(summary(d, maps), indent=1))


if __name__ == "__main__":
    main()
