#!/usr/bin/env python3
"""BROOD INCOME IN THE GAMES (brood-rootmaw-spots, docs/brood_rootmaw_spots.md): the Brood's primary income earned
(cumulative) and per minute against the Crown and the Clockwork at 5, 8, 10 and 12 minutes, from qa_matches.py data
(`--only brood`). A measuring tool only.
    python3 tools/study/brood_spots_report.py DATA [LABEL] [DATA2 LABEL2 ...]"""
import json, os, sys, glob

AT = [5, 8, 10, 12]


def load(d):
    games = []
    for f in sorted(glob.glob(os.path.join(d, "*", "result.json"))):
        r = json.load(open(f))
        tag = os.path.basename(os.path.dirname(f))
        games.append((tag, r))
    return games


def rows_of(r, i):
    # one row a minute per player, in order: player i's rows
    n = len(r["slots"])
    return [m for k, m in enumerate(r["minutes"]) if k % n == i]


def at(rows, t, key):
    for m in rows:
        if m["t"] == t * 60:
            return m[key]
    return rows[-1][key] if rows else 0


def mean(v):
    return sum(v) / len(v) if v else 0.0


def report(d, label):
    games = load(d)
    out = {}
    for tag, r in games:
        facs = [s[0] for s in r["slots"]]
        if "brood" not in facs:
            continue
        b = facs.index("brood")
        o = 1 - b
        foe = facs[o]
        rb, ro = rows_of(r, b), rows_of(r, o)
        e = out.setdefault(foe, {"n": 0, "w": 0, "d": 0, "l": 0, "b": {t: [] for t in AT}, "o": {t: [] for t in AT},
                                 "br": {t: [] for t in AT}, "or": {t: [] for t in AT}, "maws": {t: [] for t in AT}})
        e["n"] += 1
        ws = r.get("winner_side", -1)
        if ws == -1:
            e["d"] += 1
        elif ws == r["slots"][b][2]:
            e["w"] += 1
        else:
            e["l"] += 1
        for t in AT:
            e["b"][t].append(at(rb, t, "income"))
            e["o"][t].append(at(ro, t, "income"))
            # the rate: what that minute and the one before earned, a minute
            e["br"][t].append((at(rb, t, "income") - at(rb, t - 2, "income")) / 2.0)
            e["or"][t].append((at(ro, t, "income") - at(ro, t - 2, "income")) / 2.0)
            e["maws"][t].append(at(rb, t, "maws"))
    print("\n## %s (%s)" % (label, d))
    for foe, e in out.items():
        print("\nBrood v %s: %d games, Brood W-D-L %d-%d-%d" % (foe.capitalize(), e["n"], e["w"], e["d"], e["l"]))
        print("| | " + " | ".join("%d:00" % t for t in AT) + " |")
        print("|---|" + "---|" * len(AT))
        print("| Brood earned (cumulative) | " + " | ".join("%d" % mean(e["b"][t]) for t in AT) + " |")
        print("| %s earned | " % foe.capitalize() + " | ".join("%d" % mean(e["o"][t]) for t in AT) + " |")
        print("| Brood / %s | " % foe.capitalize() + " | ".join("%.2f" % (mean(e["b"][t]) / max(1.0, mean(e["o"][t]))) for t in AT) + " |")
        print("| Brood a minute (the 2 minutes before) | " + " | ".join("%d" % mean(e["br"][t]) for t in AT) + " |")
        print("| %s a minute | " % foe.capitalize() + " | ".join("%d" % mean(e["or"][t]) for t in AT) + " |")
        print("| Brood Rootmaws | " + " | ".join("%.1f" % mean(e["maws"][t]) for t in AT) + " |")


if __name__ == "__main__":
    a = sys.argv[1:]
    if not a:
        print(__doc__)
        sys.exit(1)
    i = 0
    while i < len(a):
        lab = a[i + 1] if i + 1 < len(a) and not os.path.isdir(a[i + 1]) else os.path.basename(a[i].rstrip("/"))
        report(a[i], lab)
        i += 2 if lab == (a[i + 1] if i + 1 < len(a) else None) else 1
