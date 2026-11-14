#!/usr/bin/env python3
"""NO FARM/PRESS LIMIT, every matchup (job econ-nocap-all, docs/econ_nocap_all.md): Hard OPTIMAL v Hard OPTIMAL to 15:00,
GROUND SYSTEM ON in both arms, the per-hall Farm / Cog Press limit KEPT (`ground:1`) against DROPPED (`ground:1
groundcap:off`), all six pairings (the 9 ordered matchups: the sides swap between rounds), the qa-matches seeds.
    python3 tools/study/econ_nocap_all.py run OUT DATA [--jobs 2] [--maps a,b,c] [--rounds 0,1]
    python3 tools/study/econ_nocap_all.py report DATA > report.md
    python3 tools/study/econ_nocap_all.py json DATA > summary.json
Built on tools/study/ground_nocap.py (the runner and the per-side stats). A game is done when DATA/<arm>/<tag>/result.json
exists; run again to resume. Map by map, both arms of a game queued next to each other, so a cut run stays balanced."""
import os, sys, json, math, statistics as st
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as Q
import ground_nocap as G

MAPS = ["greenhold", "hollowfen", "dune_sea", "frostfang", "cinder_steps", "ashford_crossing", "highmoor", "red_coast",
        "twin_fords", "kestrel_rise", "redrock_canyon", "amberfall_vale", "ashfall", "mirewood", "border_march",
        "thornwood_maze", "saltmarsh_isles", "glimmerdeep", "frostmere"]
PAIRS = ["crcr", "cwcw", "brbr", "crcw", "crbr", "brcw"]
NAME = {"crcr": "Crown mirror", "cwcw": "Clockwork mirror", "brbr": "Brood mirror", "crcw": "Crown v Clockwork",
        "crbr": "Crown v Brood", "brcw": "Brood v Clockwork"}
FN = {"cr": "crown", "cw": "clockwork", "br": "brood"}


def queue(maps, rounds):
    out = []
    for m in maps:
        for r in rounds:
            for g in Q.base(r):
                if g[1] == m and g[0].split("_")[-2] in PAIRS:
                    for arm in ("kept", "drop"):
                        out.append((arm, g))
    return out


def pair_of(tag):
    return tag.split("_")[-2]


def first_fac(tag):
    return FN[pair_of(tag)[:2]]


def outcome(d, tag):
    """W / D / L from the first-named faction's view (a mirror: from slot 0's view)"""
    if not d.get("over") or d.get("winner", -1) < 0:
        return "D"
    w = d["winner"]
    pr = pair_of(tag)
    if pr[:2] == pr[2:]:
        return "W" if w == 0 else "L"
    fac = G.side_stats(d, w)["fac"]
    return "W" if fac == first_fac(tag) else "L"


def med(v):
    v = [x for x in v if x is not None]
    return st.median(v) if v else float("nan")


def mean(v):
    v = [x for x in v if x is not None]
    return st.mean(v) if v else float("nan")


def fmt(x, nd=0):
    if x is None or (isinstance(x, float) and math.isnan(x)):
        return "-"
    return ("{:,.%df}" % nd).format(x)


def ratio(a, b):
    if a is None or b is None or (isinstance(a, float) and math.isnan(a)) or not b or (isinstance(b, float) and math.isnan(b)):
        return "-"
    return "%.2f" % (a / b)


def spent_at(d, p, m):
    r = G.row(d, p, m * 60)
    return r.get("spent") if r else None


def summarise(data):
    arms = {a: G.load(os.path.join(data, a)) for a in ("kept", "drop")}
    tags = sorted(set(arms["kept"]) & set(arms["drop"]))
    S = {"games": len(tags), "pairs": {}, "facs": {}, "snow": {}}
    sides = {a: [] for a in arms}
    for a in arms:
        for t in tags:
            d = arms[a][t]
            for p in (0, 1):
                s = G.side_stats(d, p)
                s["spent12"] = spent_at(d, p, 12)
                s["pair"] = pair_of(t)
                s["won"] = 1 if d.get("over") and d.get("winner") == p else 0
                sides[a].append(s)
    for pr in PAIRS:
        pt = [t for t in tags if pair_of(t) == pr]
        e = {"n": len(pt)}
        for a in arms:
            res = [outcome(arms[a][t], t) for t in pt]
            ends = [arms[a][t]["end"] for t in pt if arms[a][t].get("over")]
            e[a] = {"W": res.count("W"), "D": res.count("D"), "L": res.count("L"), "decided": len(ends),
                    "end_mean": mean(ends)}
            # per faction in this pairing (a mirror: both sides pooled)
            for f in set([pr[:2], pr[2:]]):
                ss = [s for s in sides[a] if s["pair"] == pr and s["fac"] == FN[f]]
                e[a][f] = {k: med([s[k] for s in ss]) for k in ("inc5", "inc8", "inc10", "inc12", "army8", "army12",
                                                                   "spent12")}
                e[a][f].update({k: mean([s[k] for s in ss]) for k in ("halls_max", "halls_lost", "most", "per_hall8",
                                                                        "over3", "home")})
            # paired same-game swing: P1's income share by 12:00
        S["pairs"][pr] = e
    for f in ("crown", "clockwork", "brood"):
        e = {}
        for a in arms:
            ss = [s for s in sides[a] if s["fac"] == f]
            e[a] = {"n": len(ss)}
            for k in ("inc5", "inc8", "inc10", "inc12", "inc15", "rate8", "rate12", "army8", "army12", "spent12"):
                e[a][k] = med([s[k] for s in ss])
            for k in ("halls10", "halls15", "halls_max", "halls_lost", "per_hall8", "per_hall12", "most", "over3", "home"):
                e[a][k] = mean([s[k] for s in ss])
            e[a]["hall2"] = med([s["hall2"] for s in ss])
            e[a]["hall3"] = med([s["hall3"] for s in ss])
        S["facs"][f] = e
    # snowball: in each decided game, the side ahead in income by 8:00, its share then and of the 10th-12th minute income
    for a in arms:
        n = won = 0
        sh8, sh12 = [], []
        for t in tags:
            d = arms[a][t]
            r0, r1 = G.row(d, 0, 480), G.row(d, 1, 480)
            q0, q1 = G.row(d, 0, 720), G.row(d, 1, 720)
            p0, p1 = G.row(d, 0, 540), G.row(d, 1, 540)
            if not (r0 and r1 and r0["income"] + r1["income"] > 0):
                continue
            lead = 0 if r0["income"] >= r1["income"] else 1
            rs = (r0, r1)
            sh8.append(rs[lead]["income"] / (r0["income"] + r1["income"]))
            if q0 and q1 and p0 and p1:
                g0, g1 = q0["income"] - p0["income"], q1["income"] - p1["income"]
                if g0 + g1 > 0:
                    sh12.append((g0, g1)[lead] / (g0 + g1))
            if d.get("over") and d.get("winner", -1) >= 0:
                n += 1
                won += 1 if d["winner"] == lead else 0
        S["snow"][a] = {"share8": mean(sh8), "share10_12": mean(sh12), "decided": n, "leader_won": won}
    return S


def report(data):
    S = summarise(data)
    A = ("kept", "drop")
    print("# NO FARM/PRESS LIMIT, every matchup: Hard OPTIMAL v Hard OPTIMAL to 15:00, ground ON, limit kept v dropped\n")
    print("%d games an arm, paired (same map, seed and sides).\n" % S["games"])
    print("## Results by pairing (first-named faction's view; a mirror: slot 0's view)\n")
    print("| pairing | games | kept W-D-L | dropped W-D-L | decided kept / dropped | mean end of decided kept / dropped |")
    print("|---|---|---|---|---|---|")
    for pr in PAIRS:
        e = S["pairs"][pr]
        k, d = e["kept"], e["drop"]
        print("| %s | %d | %d-%d-%d | %d-%d-%d | %d / %d | %s / %s |" % (NAME[pr], e["n"], k["W"], k["D"], k["L"], d["W"], d["D"],
              d["L"], k["decided"], d["decided"], mmss(k["end_mean"]), mmss(d["end_mean"])))
    print("\n## Income by pairing (median income earned, each faction in that pairing; dropped as a share of kept)\n")
    print("| pairing | side | kept 5:00 | 8:00 | 10:00 | 12:00 | dropped/kept 5:00 | 8:00 | 10:00 | 12:00 | army 12:00 kept / dropped | most halls kept / dropped | most drinkers in a district kept / dropped |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    for pr in PAIRS:
        e = S["pairs"][pr]
        for f in sorted(set([pr[:2], pr[2:]])):
            k, d = e["kept"][f], e["drop"][f]
            print("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s / %s | %s / %s | %s / %s |" % (NAME[pr], FN[f],
                  fmt(k["inc5"]), fmt(k["inc8"]), fmt(k["inc10"]), fmt(k["inc12"]), ratio(d["inc5"], k["inc5"]),
                  ratio(d["inc8"], k["inc8"]), ratio(d["inc10"], k["inc10"]), ratio(d["inc12"], k["inc12"]),
                  fmt(k["army12"]), fmt(d["army12"]), fmt(k["halls_max"], 1), fmt(d["halls_max"], 1), fmt(k["most"], 1),
                  fmt(d["most"], 1)))
    print("\n## Per faction (every side it played)\n")
    rows = [("income earned by 5:00", "inc5", 0, 1), ("by 8:00", "inc8", 0, 1), ("by 10:00", "inc10", 0, 1),
            ("by 12:00", "inc12", 0, 1), ("by 15:00", "inc15", 0, 1), ("income in the 8th minute", "rate8", 0, 1),
            ("income in the 12th minute", "rate12", 0, 1), ("spent by 12:00", "spent12", 0, 1),
            ("army value 8:00", "army8", 0, 1), ("army value 12:00", "army12", 0, 1),
            ("halls at 10:00 (mean)", "halls10", 2, 0), ("halls at 15:00 (mean)", "halls15", 2, 0),
            ("most halls held (mean)", "halls_max", 2, 0), ("halls lost (mean)", "halls_lost", 2, 0),
            ("2nd hall up (median, s)", "hall2", 0, 0), ("3rd hall up (median, s)", "hall3", 0, 0),
            ("Farms/Presses live a hall 8:00", "per_hall8", 2, 0), ("most in one district", "most", 2, 0),
            ("share of sides with 3+ in a district", "over3", 2, 0), ("army near home from 5:00 (turtle measure)", "home", 2, 0)]
    print("| | Crown kept | dropped | Clockwork kept | dropped | Brood kept | dropped |")
    print("|---|---|---|---|---|---|---|")
    for lab, k, nd, rt in rows:
        cells = []
        for f in ("crown", "clockwork", "brood"):
            kv, dv = S["facs"][f]["kept"][k], S["facs"][f]["drop"][k]
            cells.append(fmt(kv, nd))
            cells.append(fmt(dv, nd) + ((" (%s)" % ratio(dv, kv)) if rt else ""))
        print("| %s | %s |" % (lab, " | ".join(cells)))
    print("\n## Parity (median income earned by each faction, as a share of the Crown's)\n")
    print("| | kept 8:00 | dropped 8:00 | kept 12:00 | dropped 12:00 |")
    print("|---|---|---|---|---|")
    for f in ("clockwork", "brood"):
        c = S["facs"]
        print("| %s | %s | %s | %s | %s |" % (f, ratio(c[f]["kept"]["inc8"], c["crown"]["kept"]["inc8"]),
              ratio(c[f]["drop"]["inc8"], c["crown"]["drop"]["inc8"]), ratio(c[f]["kept"]["inc12"], c["crown"]["kept"]["inc12"]),
              ratio(c[f]["drop"]["inc12"], c["crown"]["drop"]["inc12"])))
    print("\n## Snowball check (all games)\n")
    print("| | leader's share of income by 8:00 | its share of the 10th-12th minutes' income | decided games won by the 8:00 leader |")
    print("|---|---|---|---|")
    for a in A:
        s = S["snow"][a]
        print("| %s | %.2f | %.2f | %d of %d |" % (a, s["share8"], s["share10_12"], s["leader_won"], s["decided"]))


def mmss(s):
    if s is None or (isinstance(s, float) and math.isnan(s)):
        return "-"
    return "%d:%02d" % (int(s) // 60, int(s) % 60)


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    if a[0] == "run":
        out, data = a[1], a[2]
        jobs = int(a[a.index("--jobs") + 1]) if "--jobs" in a else 2
        maps = a[a.index("--maps") + 1].split(",") if "--maps" in a else MAPS
        rounds = [int(x) for x in a[a.index("--rounds") + 1].split(",")] if "--rounds" in a else [0, 1]
        q = queue(maps, rounds)
        print("%d games queued" % len(q), flush=True)
        with ThreadPoolExecutor(jobs) as ex:
            for r in ex.map(lambda x: G.run_one(x[0], x[1], out, data), q):
                print(r, flush=True)
    elif a[0] == "report":
        report(a[1])
    elif a[0] == "json":
        print(json.dumps(summarise(a[1]), indent=1, default=str))


if __name__ == "__main__":
    main()
