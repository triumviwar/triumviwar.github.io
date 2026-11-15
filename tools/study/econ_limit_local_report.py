#!/usr/bin/env python3
"""econ-limit-local (docs/econ_limit_local.md): the economy bench and the computers alone, before (main) and after (the
local limit), primary (p_cum) and secondary (s_cum) earned at 5, 8, 10 and 12 minutes, the means of the maps.
  python3 tools/study/econ_limit_local_report.py <dir with b_*.json and a_*.json>
Files: <b|a>_<bench|alone>_<crown|clockwork>_<map>.json (tools/econ_bench.gd, econ_ai_alone.gd, econ_alone_cw.gd out=)."""
import glob, json, os, sys

D = sys.argv[1] if len(sys.argv) > 1 else "docs/econ_limit_local"
MINS = [5, 8, 10, 12]


def load(tag, kind, fac):
    out = {}
    for f in sorted(glob.glob(os.path.join(D, "%s_%s_%s_*.json" % (tag, kind, fac)))):
        m = os.path.basename(f)[:-5].split("_", 3)[3]
        rows = json.load(open(f))["rows"]
        out[m] = {int(r["min"]): r for r in rows}
    return out


for kind in ["bench", "alone"]:
    for fac in ["crown", "clockwork"]:
        b, a = load("b", kind, fac), load("a", kind, fac)
        maps = sorted(set(b) & set(a))
        if not maps:
            continue
        print("\n### %s, %s (%s)\n" % (kind, fac, ", ".join(maps)))
        print("| | " + " | ".join("%d:00" % m for m in MINS) + " |")
        print("|---|" + "---|" * len(MINS))
        for lab, src in [("before", b), ("after", a)]:
            cells = []
            for m in MINS:
                ps = [src[mp][m]["p_cum"] for mp in maps if m in src[mp]]
                ss = [src[mp][m]["s_cum"] for mp in maps if m in src[mp]]
                cells.append("%s (%s)" % (format(round(sum(ps) / len(ps)), ","), format(round(sum(ss) / len(ss)), ",")) if ps else "-")
            print("| %s | %s |" % (lab, " | ".join(cells)))
        cells = []
        for m in MINS:
            pb = [b[mp][m]["p_cum"] for mp in maps if m in b[mp] and m in a[mp]]
            pa = [a[mp][m]["p_cum"] for mp in maps if m in b[mp] and m in a[mp]]
            cells.append("%+.1f%%" % (100.0 * (sum(pa) / sum(pb) - 1.0)) if pb and sum(pb) else "-")
        print("| change | %s |" % " | ".join(cells))
        for mp in maps:
            eb = b[mp].get(12, {}).get("econ", {})
            ea = a[mp].get(12, {}).get("econ", {})
            pb12 = b[mp].get(12, {}).get("p_cum", 0)
            pa12 = a[mp].get(12, {}).get("p_cum", 0)
            print("- %s at 12:00: %s -> %s (%+.1f%%); buildings %s -> %s" % (mp, format(pb12, ","), format(pa12, ","),
                  100.0 * (pa12 / pb12 - 1.0) if pb12 else 0.0, json.dumps(eb, sort_keys=True), json.dumps(ea, sort_keys=True)))
