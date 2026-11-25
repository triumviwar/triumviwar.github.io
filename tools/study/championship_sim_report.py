#!/usr/bin/env python3
"""The championship simulation's report (docs/championship_sim.md): reads docs/championship_sim/data/<RUN>/ and prints
markdown tables: each run's champion and places, its bracket match by match, and over every run the factions, the
plans, the matchups, the game lengths and the maps.
    python3 tools/study/championship_sim_report.py [RUN ...]      (default: every finished run)"""
import os, sys, json, glob, statistics as st
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA = os.path.join(ROOT, "docs/championship_sim/data")
FAC = {"crown": "Crown", "clockwork": "Clockwork", "brood": "Brood"}
MAPN = {"greenhold": "Greenhold", "dune_sea": "Dune Sea", "frostfang": "Frostfang", "ashford_crossing": "Ashford Crossing",
        "hollowfen": "Hollowfen", "cinder_steps": "Cinder Steps"}


def mmss(s):
    return "%d:%02d" % (int(s) // 60, int(s) % 60)


def pct(a, b):
    return "%d%%" % round(100.0 * a / b) if b else "-"


def label(t, m):
    st_ = m["stage"]
    tops = defaultdict(int)
    for x in t["matches"]:
        tops[x["stage"]] = max(tops[x["stage"]], x["round"])
    if st_ == "gf":
        return "Grand final (reset)" if m.get("reset") else "Grand final"
    if st_ == "wb":
        return "Upper final" if m["round"] == tops["wb"] else "Upper round %d" % m["round"]
    if st_ == "lb":
        return "Lower final" if m["round"] == tops["lb"] else "Lower round %d" % m["round"]
    return "%s %d" % (st_, m["round"])


def load(run):
    d = os.path.join(DATA, run)
    t = json.load(open(os.path.join(d, "tournament.json")))
    pl = {p["id"]: p for p in t["players"]}
    attempts = defaultdict(int)
    walls = []
    for gd in glob.glob(os.path.join(d, "games", "*")):
        mid, gi, k = map(int, os.path.basename(gd).split("_"))
        attempts[(mid, gi)] += 1
        gj = os.path.join(gd, "game.json")
        if os.path.exists(gj):
            walls.append(json.load(open(gj)).get("wall", 0))
    games = []
    for m in t["matches"]:
        for gi, g in enumerate(m["games"]):
            if g["how"] == "set":
                continue
            pa, pb = pl[m["a"]], pl[m["b"]]
            w = pa if g["win"] == "a" else pb
            l = pb if g["win"] == "a" else pa
            games.append({"run": run, "mid": m["id"], "gi": gi, "stage": m["stage"], "map": g["map"], "len": g["len"], "how": g["how"],
                          "w": w, "l": l, "wf": w["faction"], "lf": l["faction"], "again": attempts[(m["id"], gi)] - 1})
    return t, pl, games, walls


def placings(t, pl):
    out_at = {}
    for m in t["matches"]:
        if m["state"] != "done" or m.get("skip") or m["loser"] < 0:
            continue
        elim = m["stage"] in ("lb", "gf")
        if m["stage"] == "gf" and not m.get("reset"):
            elim = m["loser"] == m["b"]
        if elim:
            depth = (1000 + m["round"]) if m["stage"] == "gf" else (100 + 2 * m["round"])
            out_at[m["loser"]] = depth
    order = sorted(out_at, key=lambda p: -out_at[p])
    res = [(1, t["champion"])]
    i, place = 0, 2
    while i < len(order):
        j = i
        while j < len(order) and out_at[order[j]] == out_at[order[i]]:
            j += 1
        for k in range(i, j):
            res.append((place, order[k]))
        place += j - i
        i = j
    return res


def main(runs):
    if not runs:
        runs = sorted(r for r in os.listdir(DATA) if os.path.exists(os.path.join(DATA, r, "tournament.json")))
    allg, champs, places_all, wall_all = [], [], defaultdict(list), []
    for run in runs:
        t, pl, games, walls = load(run)
        wall_all += walls
        done = t["state"] == "done"
        print("\n### Run %s (seed %s)%s\n" % (run, t["seed"], "" if done else " (NOT FINISHED)"))
        if done:
            ch = pl[t["champion"]]
            champs.append((run, ch))
            print("Champion: **%s**. %d games in %d matches, %d games played again at the bell.\n" % (
                ch["name"], len(games), sum(1 for m in t["matches"] if m["games"]), sum(g["again"] for g in games)))
            print("| Place | Player | Seed |\n|---|---|---|")
            for place, pid in placings(t, pl):
                print("| %d | %s | %d |" % (place, pl[pid]["name"], pl[pid]["seed"]))
                places_all[pl[pid]["name"]].append(place)
        print("\nThe bracket, match by match:\n")
        print("| Match | Players | Score | Maps (winner) |\n|---|---|---|---|")
        for m in t["matches"]:
            if not m["games"] or m["a"] < 0 or m["b"] < 0:
                continue
            wa = sum(1 for g in m["games"] if g["win"] == "a")
            wb = len(m["games"]) - wa
            maps = ", ".join("%s (%s%s)" % (MAPN.get(g["map"], g["map"]), "A" if g["win"] == "a" else "B", ", bell" if g["how"] == "time" else "") for g in m["games"])
            print("| %s | A %s v B %s | %d-%d | %s |" % (label(t, m), pl[m["a"]]["name"], pl[m["b"]]["name"], wa, wb, maps))
        allg += games
    if not allg:
        return
    n = len(allg)
    print("\n### Over every run (%d games, %d runs finished)\n" % (n, len(champs)))
    print("Champions: " + ", ".join("%s %s" % (r, c["name"]) for r, c in champs) + "\n")
    # factions
    fw, fp = defaultdict(int), defaultdict(int)
    for g in allg:
        if g["wf"] == g["lf"]:
            continue
        fw[g["wf"]] += 1
        fp[g["wf"]] += 1
        fp[g["lf"]] += 1
    mirror = sum(1 for g in allg if g["wf"] == g["lf"])
    print("Games between two factions (mirrors left out, %d of them):\n" % mirror)
    print("| Faction | Won | Played | Win rate |\n|---|---|---|---|")
    for f in ("crown", "clockwork", "brood"):
        print("| %s | %d | %d | %s |" % (FAC[f], fw[f], fp[f], pct(fw[f], fp[f])))
    # matchups
    print("\nMatchups (the row's faction's wins against the column's):\n")
    print("| | Crown | Clockwork | Brood |\n|---|---|---|---|")
    mu = defaultdict(int)
    for g in allg:
        mu[(g["wf"], g["lf"])] += 1
    for a in ("crown", "clockwork", "brood"):
        cells = []
        for b in ("crown", "clockwork", "brood"):
            if a == b:
                cells.append("(%d mirror)" % mu[(a, a)])
            else:
                cells.append("%d-%d (%s)" % (mu[(a, b)], mu[(b, a)], pct(mu[(a, b)], mu[(a, b)] + mu[(b, a)])))
        print("| %s | %s |" % (FAC[a], " | ".join(cells)))
    # plans (each entrant)
    pw, pp = defaultdict(int), defaultdict(int)
    for g in allg:
        pw[g["w"]["name"]] += 1
        pp[g["w"]["name"]] += 1
        pp[g["l"]["name"]] += 1
    print("\nEach entrant (faction and plan), over every run:\n")
    print("| Entrant | Games won | Played | Win rate | Places |\n|---|---|---|---|---|")
    for name in sorted(pp, key=lambda x: (-pw[x] / max(1, pp[x]), x)):
        print("| %s | %d | %d | %s | %s |" % (name, pw[name], pp[name], pct(pw[name], pp[name]), ", ".join(str(p) for p in places_all.get(name, []))))
    # lengths
    played = [g for g in allg if g["how"] == "played"]
    bell = [g for g in allg if g["how"] == "time"]
    print("\nHow games ended: %d of %d (%s) by a side beaten before 20:00, %d (%s) at the bell by the lead rule; %d games were "
          "played again because nobody was clearly ahead at the bell.\n" % (len(played), n, pct(len(played), n), len(bell), pct(len(bell), n),
                                                                            sum(g["again"] for g in allg)))
    if played:
        ls = sorted(g["len"] for g in played)
        print("Games won outright lasted %s at the median (the quickest %s, the slowest %s).\n" % (mmss(st.median(ls)), mmss(ls[0]), mmss(ls[-1])))
        print("| Faction that won | Won outright | Median length | Won at the bell |\n|---|---|---|---|")
        for f in ("crown", "clockwork", "brood"):
            pl_ = [g["len"] for g in played if g["wf"] == f]
            print("| %s | %d | %s | %d |" % (FAC[f], len(pl_), mmss(st.median(pl_)) if pl_ else "-", sum(1 for g in bell if g["wf"] == f)))
    # maps
    print("\nMaps (games, and each faction's wins there in games between two factions):\n")
    print("| Map | Games | Crown | Clockwork | Brood | At the bell |\n|---|---|---|---|---|---|")
    for mp in MAPN:
        gs = [g for g in allg if g["map"] == mp]
        cells = []
        for f in ("crown", "clockwork", "brood"):
            w = sum(1 for g in gs if g["wf"] == f and g["lf"] != f)
            p = sum(1 for g in gs if (g["wf"] == f) != (g["lf"] == f))
            cells.append("%d of %d" % (w, p))
        print("| %s | %d | %s | %d |" % (MAPN[mp], len(gs), " | ".join(cells), sum(1 for g in gs if g["how"] == "time")))
    if wall_all:
        print("\nA game took %s of real time at the median on this machine (2 at a time on 2 cores)." % mmss(st.median(wall_all)))


if __name__ == "__main__":
    main(sys.argv[1:])
