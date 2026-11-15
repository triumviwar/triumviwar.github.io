#!/usr/bin/env python3
"""econ-limit-local (docs/econ_limit_local.md): the economy bench and the computers alone, before (main) and after (the
local limit), primary (p_cum) and secondary (s_cum) earned at 5, 8, 10 and 12 minutes: the mean of the runs on each map,
then of the maps.
  python3 tools/study/econ_limit_local_report.py [dir, default docs/econ_limit_local]
Files: <b|a>_<bench|alone>_<crown|clockwork>_<map>[.r<n>].json (tools/econ_bench.gd, econ_ai_alone.gd, econ_alone_cw.gd
out=; .r2 = a second run of the same, the computers do not play a game the same way twice)."""
import glob, json, os, sys

D = sys.argv[1] if len(sys.argv) > 1 else "docs/econ_limit_local"
MINS = [5, 8, 10, 12]


def load(tag, kind, fac):
    out = {}            # map -> [ {min: row} per run ]
    for f in sorted(glob.glob(os.path.join(D, "%s_%s_%s_*.json" % (tag, kind, fac)))):
        m = os.path.basename(f).split(".")[0].split("_", 3)[3]
        rows = json.load(open(f))["rows"]
        out.setdefault(m, []).append({int(r["min"]): r for r in rows})
    return out


def mean(xs):
    return sum(xs) / len(xs) if xs else 0.0


def at(src, mp, m, key):
    return mean([float(run[m][key]) for run in src[mp] if m in run])


for kind in ["bench", "alone"]:
    for fac in ["crown", "clockwork"]:
        b, a = load("b", kind, fac), load("a", kind, fac)
        maps = sorted(set(b) & set(a))
        if not maps:
            continue
        runs = "%d / %d runs" % (sum(len(b[m]) for m in maps), sum(len(a[m]) for m in maps))
        print("\n**%s, %s** (%s; %s before / after)\n" % ("The bench" if kind == "bench" else "The computer alone", fac.capitalize(), ", ".join(maps), runs))
        print("| | " + " | ".join("%d:00" % m for m in MINS) + " |")
        print("|---|" + "---|" * len(MINS))
        for lab, src in [("before", b), ("after", a)]:
            cells = []
            for m in MINS:
                cells.append("%s (%s)" % (format(round(mean([at(src, mp, m, "p_cum") for mp in maps])), ","),
                                          format(round(mean([at(src, mp, m, "s_cum") for mp in maps])), ",")))
            print("| %s | %s |" % (lab, " | ".join(cells)))
        cells = []
        for m in MINS:
            pb = mean([at(b, mp, m, "p_cum") for mp in maps])
            pa = mean([at(a, mp, m, "p_cum") for mp in maps])
            cells.append("%+.1f%%" % (100.0 * (pa / pb - 1.0)) if pb else "-")
        print("| change | %s |" % " | ".join(cells))
        print()
        for mp in maps:
            pb, pa = at(b, mp, 12, "p_cum"), at(a, mp, 12, "p_cum")
            each = lambda src: " / ".join(format(int(run[12]["p_cum"]), ",") for run in src[mp] if 12 in run)
            print("- %s at 12:00: %s -> %s (%+.1f%%; runs %s -> %s)" % (mp, format(round(pb), ","), format(round(pa), ","),
                  100.0 * (pa / pb - 1.0) if pb else 0.0, each(b), each(a)))
