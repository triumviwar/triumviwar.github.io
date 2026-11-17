#!/usr/bin/env python3
"""CROWN GUNS COACH report (docs/crown_guns_coach.md): tables from DATA/A (as is) and DATA/C (`gunscoach:off`) of
tools/study/crown_guns_coach.py, by the rules of the win-rate studies (tools/study/winrate_1115_report.py: a draw's
LEADER = income earned + 2 x army value 10% ahead; "won or led" = won, or led a draw; ratios the Crown's over its
enemy's, pooled sum over sum) plus the Crown's fights (result.json crown_ai "guns", scripts/ai_crown_guns.gd's count: an
armed enemy within 260 px of a Crown soldier after 20 s of none there; fights worth under 60 of kills + losses are left
out). A measuring tool only.
    python3 tools/study/crown_guns_coach_report.py DATA > tables.md"""
import os, sys, json
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import winrate_1115_report as wr
from crown_coach_measure_2_report import sign_p, pg, mean, f2, f1, RANK

PAIRS = ["crcw", "crbr"]
NAME = {"crbr": "Crown v Brood", "crcw": "Crown v Clockwork"}
ARMS = ["A", "C"]
ANAME = {"A": "A as is", "C": "C gunscoach:off"}
MINS = [5, 8, 10, 12]
BIG = 300            # a fight worth this (kills + losses) is a "real" fight in the fight tables


def ca(data, arm, r):
    g = json.load(open(os.path.join(data, arm, r["tag"], "result.json")))
    return ((g.get("crown_ai") or {}).get(str(r["si"])) or {}).get("guns") or {}


def fights_table(P, data, rows_by, title, keep):
    P("| pairing | arm | games | fights | begun formed | with a gun near | guns near (sum) | set at contact | fired in the first 10 s | fights where a gun fired in 10 s (of those with a gun near) | killed / lost in them | kills per loss |")
    P("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for pair in PAIRS:
        tags, src = rows_by[pair]
        for arm in ARMS:
            n = formed = withg = gsum = gset = gfired = ffired = 0
            k = l = 0
            for t in tags:
                for f in ca(data, arm, src[arm][t]).get("fights", []):
                    # [t0, home, formed, guns, set, fired, killed, lost, x, y]
                    if not keep(f):
                        continue
                    n += 1
                    formed += 1 if f[2] else 0
                    if f[3] > 0:
                        withg += 1
                        ffired += 1 if f[5] > 0 else 0
                    gsum += f[3]
                    gset += f[4]
                    gfired += f[5]
                    k += f[6]
                    l += f[7]
            P("| %s | %s | %d | %d | %d (%s) | %d | %d | %d (%s) | %d (%s) | %d (%s) | %d / %d | %s |" % (NAME[pair], ANAME[arm], len(tags), n,
                formed, pc(formed, n), withg, gsum, gset, pc(gset, gsum), gfired, pc(gfired, gsum), ffired, pc(ffired, withg), k, l,
                f2(k / l) if l else ""))
    P("")


def pc(a, b):
    return "%d%%" % round(100.0 * a / b) if b else ""


def main():
    data = sys.argv[1]
    P = print
    P("# Tables (tools/study/crown_guns_coach_report.py)\n")
    rows_by = {}
    P("## Results (paired games only: played in both arms)\n")
    P("| pairing | arm | games | W-D-L | won or led: Crown / enemy / even | decided (mean length) |")
    P("|---|---|---|---|---|---|")
    for pair in PAIRS:
        src = {arm: {r["tag"]: r for r in wr.load(os.path.join(data, arm), pair)} for arm in ARMS}
        tags = sorted(set.intersection(*[set(v) for v in src.values()]))
        rows_by[pair] = (tags, src)
        for arm in ARMS:
            rr = [src[arm][t] for t in tags]
            if not rr:
                continue
            s = wr.summary(rr)
            P("| %s | %s | %d | %s | %s | %s |" % (NAME[pair], ANAME[arm], s["n"], s["wdl"], s["wol"], s["dec"]))
    P("")
    P("## Economy and army (Crown / enemy): pooled, and in brackets the per-game mean\n")
    for pair in PAIRS:
        tags, src = rows_by[pair]
        if not tags:
            continue
        P("### %s (%d paired games)\n" % (NAME[pair], len(tags)))
        P("| arm | " + " | ".join("income %d:00" % m for m in MINS) + " | " + " | ".join("army %d:00" % m for m in MINS) + " | built halls lost a game (Crown / enemy) |")
        P("|---|" + "---|" * (2 * len(MINS) + 1))
        for arm in ARMS:
            rr = [src[arm][t] for t in tags]
            cells = []
            for k in ("income", "army"):
                for m in MINS:
                    cells.append("%s (%s)" % (f2(wr.ratio(rr, m, k)), f2(mean(pg(rr, m, k)))))
            hl = "%.2f / %.2f" % (mean([r["halls"][r["si"]] for r in rr]), mean([r["halls"][r["oi"]] for r in rr]))
            P("| %s | %s | %s |" % (ANAME[arm], " | ".join(cells), hl))
        P("")
    P("## Paired: the same map and seed (A v C)\n")
    P("| pairing | outcome: A better / C better / same (sign p) | income 8:00: A higher / lower (p) | income 12:00 (p) | army 5:00 (p) | army 8:00 (p) | army 10:00 (p) | army 12:00 (p) |")
    P("|---|---|---|---|---|---|---|---|")
    for pair in PAIRS:
        tags, src = rows_by[pair]
        if not tags:
            continue
        on, off = src["A"], src["C"]
        b = sum(RANK[on[t]["lead"]] > RANK[off[t]["lead"]] for t in tags)
        w = sum(RANK[on[t]["lead"]] < RANK[off[t]["lead"]] for t in tags)
        cells = ["%d / %d / %d (%.3f)" % (b, w, len(tags) - b - w, sign_p(b, w))]
        for k, m in (("income", 8), ("income", 12), ("army", 5), ("army", 8), ("army", 10), ("army", 12)):
            a = pg([on[t] for t in tags], m, k)
            o = pg([off[t] for t in tags], m, k)
            pl = sum(1 for p_, q_ in zip(a, o) if p_ is not None and q_ is not None and p_ > q_)
            mi = sum(1 for p_, q_ in zip(a, o) if p_ is not None and q_ is not None and p_ < q_)
            cells.append("%d / %d (%.3f)" % (pl, mi, sign_p(pl, mi)))
        P("| %s | %s |" % (NAME[pair], " | ".join(cells)))
    P("")
    P("## The Crown's fights (scripts/ai_crown_guns.gd's count)\n")
    P("### Every fight (worth 60 or more)\n")
    fights_table(P, data, rows_by, "", lambda f: True)
    P("### Real fights (worth %d or more of kills + losses)\n" % BIG)
    fights_table(P, data, rows_by, "", lambda f: f[6] + f[7] >= BIG)
    P("### Real fights out (the wave) and at home\n")
    P("Out:\n")
    fights_table(P, data, rows_by, "", lambda f: f[6] + f[7] >= BIG and not f[1])
    P("At home:\n")
    fights_table(P, data, rows_by, "", lambda f: f[6] + f[7] >= BIG and f[1])
    P("## The new rules fired (sums over the games; scripts/ai_crown_guns.gd counters)\n")
    keys = ["kept", "sets", "ups", "follows", "paces", "spots", "feet", "climbs", "leaves", "def_sets", "post_sets"]
    P("| pairing | arm | " + " | ".join(keys) + " | screen sightings | lines formed on the march | met unformed |")
    P("|---|---|" + "---|" * (len(keys) + 3))
    for pair in PAIRS:
        tags, src = rows_by[pair]
        for arm in ARMS:
            tot = Counter()
            sc = fo = de = 0
            for t in tags:
                r = src[arm][t]
                g = ca(data, arm, r)
                for k in keys:
                    tot[k] += int(g.get(k) or 0)
                gg = json.load(open(os.path.join(data, arm, t, "result.json")))
                c = ((gg.get("crown_ai") or {}).get(str(r["si"])) or {})
                sc += int(c.get("sc_sightings") or 0)
                fo += int(c.get("line_forms") or 0)
                de += int(c.get("line_deploys") or 0)
            P("| %s | %s | %s | %d | %d | %d |" % (NAME[pair], ANAME[arm], " | ".join(str(tot[k]) for k in keys), sc, fo, de))
    P("")
    P("### Game by game\n")
    for pair in PAIRS:
        tags, src = rows_by[pair]
        P("#### %s\n" % NAME[pair])
        P("| game | map | A / C | income 8:00 A / C | army 8:00 A / C | army 12:00 A / C | real fights (A / C) | guns fired in 10 s (A / C) |")
        P("|---|---|---|---|---|---|---|---|")
        for t in tags:
            rs = [src[a][t] for a in ARMS]
            gi = lambda r, m, k: f2(pg([r], m, k)[0])
            ff = []
            gf = []
            for a in ARMS:
                fs = [f for f in ca(data, a, src[a][t]).get("fights", []) if f[6] + f[7] >= BIG]
                ff.append(str(len(fs)))
                gf.append("%d/%d" % (sum(f[5] for f in fs), sum(f[3] for f in fs)))
            P("| %s | %s | %s | %s | %s | %s | %s | %s |" % (t.replace("base_", ""), rs[0]["map"], " / ".join(r["lead"] for r in rs),
                " / ".join(gi(r, 8, "income") for r in rs), " / ".join(gi(r, 8, "army") for r in rs),
                " / ".join(gi(r, 12, "army") for r in rs), " / ".join(ff), " / ".join(gf)))
        P("")


if __name__ == "__main__":
    main()
