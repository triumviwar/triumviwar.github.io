#!/usr/bin/env python3
"""CROWN COACH MEASURE report (docs/crown_coach_measure.md): tables from DATA/on and DATA/off (tools/study/
crown_coach_measure.py). The win-rate studies' rules (tools/study/winrate_1115_report.py's load): a draw's LEADER =
income earned + 2 x army value 10% ahead; "won or led" = won, or led a draw. Ratios are the Crown's over its enemy's:
pooled (sum over sum, as the win-rate reports) and the per-game mean. A measuring tool only.
    python3 tools/study/crown_coach_measure_report.py DATA > tables.md"""
import os, sys, json, math, glob, statistics as st
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import winrate_1115_report as wr

PAIRS = ["crbr", "crcw"]
NAME = {"crbr": "Crown v Brood", "crcw": "Crown v Clockwork"}
ARMS = ["on", "off"]
RANK = {"W": 4, "w": 3, "=": 2, "l": 1, "L": 0}
MINS = [5, 8, 10, 12]


def sign_p(plus, minus):
    """two-sided exact sign test"""
    n = plus + minus
    if n == 0:
        return 1.0
    k = min(plus, minus)
    p = sum(math.comb(n, i) for i in range(k + 1)) / 2 ** n
    return min(1.0, 2 * p)


def pg(rows, m, k):
    """per-game ratios (Crown / enemy) at minute m"""
    o = []
    for r in rows:
        a, b = wr.val(r, r["si"], m, k), wr.val(r, r["oi"], m, k)
        o.append(None if a is None or b is None or b == 0 else a / b)
    return o


def mean(xs):
    xs = [x for x in xs if x is not None]
    return sum(xs) / len(xs) if xs else None


def f2(x):
    return "" if x is None else "%.2f" % x


def f1(x):
    return "" if x is None else "%.1f" % x


def extra(data, arm, rows):
    """the coach counters and story lines of each game (result.json crown_ai, story.txt)"""
    for r in rows:
        d = os.path.join(data, arm, r["tag"])
        g = json.load(open(os.path.join(d, "result.json")))
        r["ca"] = (g.get("crown_ai") or {}).get(str(r["si"]), {})
        s = open(os.path.join(d, "story.txt"), errors="replace").read() if os.path.exists(os.path.join(d, "story.txt")) else ""
        r["story"] = s
        r["picks_txt"] = " | ".join(p for t, p in r["picks"][r["si"]])
        r["errs"] = os.path.exists(os.path.join(d, "errors.txt"))


def main():
    data = sys.argv[1]
    P = print
    P("# Tables (tools/study/crown_coach_measure_report.py)\n")
    rows = {}
    for pair in PAIRS:
        for arm in ARMS:
            rr = wr.load(os.path.join(data, arm), pair)
            extra(data, arm, rr)
            rows[(pair, arm)] = rr
    # only the games played in both arms count in the paired tables; the summary uses the pairs too
    P("## Results (paired games only: played with the coach on and off)\n")
    P("| pairing | arm | games | W-D-L | won or led: Crown / enemy / even | decided (mean length) |")
    P("|---|---|---|---|---|---|")
    paired = {}
    for pair in PAIRS:
        on = {r["tag"]: r for r in rows[(pair, "on")]}
        off = {r["tag"]: r for r in rows[(pair, "off")]}
        tags = sorted(set(on) & set(off))
        paired[pair] = (tags, on, off)
        for arm, src in (("on", on), ("off", off)):
            rr = [src[t] for t in tags]
            if not rr:
                continue
            s = wr.summary(rr)
            P("| %s | %s | %d | %s | %s | %s |" % (NAME[pair], "coach on" if arm == "on" else "coach:off", s["n"], s["wdl"], s["wol"], s["dec"]))
    P("")
    P("## Economy and army (Crown / enemy): pooled (sum / sum), and in brackets the per-game mean\n")
    for pair in PAIRS:
        tags, on, off = paired[pair]
        if not tags:
            continue
        P("### %s (%d paired games)\n" % (NAME[pair], len(tags)))
        P("| arm | " + " | ".join("income %d:00" % m for m in MINS) + " | " + " | ".join("army %d:00" % m for m in MINS) + " |")
        P("|---|" + "---|" * (2 * len(MINS)))
        for arm, src in (("coach on", on), ("coach:off", off)):
            rr = [src[t] for t in tags]
            cells = []
            for k in ("income", "army"):
                for m in MINS:
                    cells.append("%s (%s)" % (f2(wr.ratio(rr, m, k)), f2(mean(pg(rr, m, k)))))
            P("| %s | %s |" % (arm, " | ".join(cells)))
        P("")
        P("| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |")
        P("|---|---|---|---|---|---|---|---|---|---|")
        for arm, src in (("coach on", on), ("coach:off", off)):
            rr = [src[t] for t in tags]
            # a side beaten before minute m has no row then: it counts 0 halls / workers (not left out)
            c = lambda side, m, k: f1(mean([wr.val(r, r[side], m, k) if wr.val(r, r[side], m, k) is not None
                                            else (0 if r["res"] == ("L" if side == "si" else "W") else None) for r in rr]))
            hl = "%.2f / %.2f" % (mean([r["halls"][r["si"]] for r in rr]), mean([r["halls"][r["oi"]] for r in rr]))
            P("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (arm, c("si", 8, "halls"), c("si", 12, "halls"), c("oi", 8, "halls"),
                c("oi", 12, "halls"), c("si", 5, "workers"), c("si", 8, "workers"), c("oi", 5, "workers"), c("oi", 8, "workers"), hl))
        P("")
    P("## The paired comparison: the same map and seed, coach on v off\n")
    P("Outcome rank: won > led a draw > even draw > trailed a draw > lost. A sign test counts the games where one arm did better.\n")
    P("| pairing | outcome: on better / off better / same (sign p) | income 8:00 per game: on higher / lower (p) | income 12:00 (p) | army 8:00 (p) | army 12:00 (p) |")
    P("|---|---|---|---|---|---|")
    for pair in PAIRS:
        tags, on, off = paired[pair]
        if not tags:
            continue
        b = sum(RANK[on[t]["lead"]] > RANK[off[t]["lead"]] for t in tags)
        w = sum(RANK[on[t]["lead"]] < RANK[off[t]["lead"]] for t in tags)
        cells = ["%d / %d / %d (%.3f)" % (b, w, len(tags) - b - w, sign_p(b, w))]
        for k, m in (("income", 8), ("income", 12), ("army", 8), ("army", 12)):
            a = pg([on[t] for t in tags], m, k)
            o = pg([off[t] for t in tags], m, k)
            pl = sum(1 for x, y in zip(a, o) if x is not None and y is not None and x > y)
            mi = sum(1 for x, y in zip(a, o) if x is not None and y is not None and x < y)
            cells.append("%d / %d (%.3f)" % (pl, mi, sign_p(pl, mi)))
        P("| %s | %s |" % (NAME[pair], " | ".join(cells)))
    P("")
    P("### Game by game\n")
    P("| game | map | on | off | income 8:00 on / off | army 8:00 on / off | Crown halls 12:00 on / off | the Crown's OPTIMAL picks (on) | (off) |")
    P("|---|---|---|---|---|---|---|---|---|")
    for pair in PAIRS:
        tags, on, off = paired[pair]
        for t in tags:
            a, o = on[t], off[t]
            gi = lambda r, m, k: f2(pg([r], m, k)[0])
            P("| %s | %s | %s | %s | %s / %s | %s / %s | %s / %s | %s | %s |" % (t.replace("base_", ""), a["map"], a["lead"], o["lead"],
                gi(a, 8, "income"), gi(o, 8, "income"), gi(a, 8, "army"), gi(o, 8, "army"),
                wr.val(a, a["si"], 12, "halls"), wr.val(o, o["si"], 12, "halls"), a["picks_txt"][:90], o["picks_txt"][:90]))
    P("")
    P("## Which coach rules fired (coach on; result.json crown_ai, means per game, and games where it fired)\n")
    P("| pairing | labourers trained by LABOURERS FIRST | s gold held for them | next hall moved up (games) | screen riders trained first | guns set early | lines formed on the march | lines deployed at contact unformed | screen sightings | screen riders sent / lost |")
    P("|---|---|---|---|---|---|---|---|---|---|")
    for pair in PAIRS:
        tags, on, off = paired[pair]
        for arm, src in (("on", on), ("off", off)):
            rr = [src[t] for t in tags]
            if not rr:
                continue
            ca = [r["ca"] for r in rr]
            g = lambda k: mean([float(c.get(k) or 0) for c in ca])
            fired = lambda k: sum(1 for c in ca if (c.get(k) or 0) > 0)
            moved = sum(1 for c in ca if c.get("bo_hall_moved"))
            P("| %s (%s) | %s (%d) | %s | %d | %s (%d) | %s (%d) | %s | %s | %s | %s / %s |" % (NAME[pair], arm, f1(g("labs_first_n")), fired("labs_first_n"),
                f1(g("labs_first_held_t")), moved, f1(g("screen_trained")), fired("screen_trained"), f1(g("guns_early_n")), fired("guns_early_n"),
                f1(g("line_forms")), f1(g("line_deploys")), f1(g("sc_sightings")), f1(g("sc_sent")), f1(g("sc_lost"))))
    P("")
    P("## The Crown's OPTIMAL picks\n")
    for pair in PAIRS:
        tags, on, off = paired[pair]
        for arm, src in (("coach on", on), ("coach:off", off)):
            c = Counter()
            rush = 0
            for t in tags:
                r = src[t]
                for tt, p in r["picks"][r["si"]]:
                    c[p.split("->")[-1].split("(")[0].strip()] += 1
                if "rush" in r["story"].lower() and "horse" in r["story"].lower():
                    rush += 1
            P("- %s, %s: picks %s; story mentions a Horseman rush in %d games" % (NAME[pair], arm, dict(c.most_common()), rush))
    P("")
    P("## The enemy's first arrival in the Crown's base (result.json first_arrival: 300+ army value within 500 px; medians)\n")
    P("| pairing | arm | games with one | when | its army | the Crown's army there | Crown units lost in 90 s | enemy units lost | Crown buildings lost | Crown army 5:00 (abs.) | 8:00 | the Crown's own first attack (games, when) | built Crown halls lost (games with one, first at) |")
    P("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    md = lambda xs: st.median(xs) if xs else None
    for pair in PAIRS:
        tags, on, off = paired[pair]
        for arm in ARMS:
            k = {x: [] for x in ("t", "val", "own", "ol", "fl", "ob", "fa", "hl", "a5", "a8")}
            hl_games = 0
            for t in tags:
                d = os.path.join(data, arm, t)
                g = json.load(open(os.path.join(d, "result.json")))
                si = [s[0] for s in g["slots"]].index("crown")
                at = {(r["p"], int(round(r["t"] / 60))): r for r in g["minutes"]}
                k["a5"].append(at.get((si, 5), {}).get("army", 0))
                k["a8"].append(at.get((si, 8), {}).get("army", 0))
                first_hl = None
                for e in g["events"]:
                    if e.get("ev") == "first_arrival" and e["p"] == si:
                        k["t"].append(e["t"]); k["val"].append(e["value"]); k["own"].append(e["own_army"])
                        k["ol"].append(e["own_lost"]); k["fl"].append(e["foe_lost"]); k["ob"].append(e["own_bld"])
                    if e.get("ev") == "first_attack" and e["p"] == si:
                        k["fa"].append(e["t"])
                    if e.get("ev") == "hall_lost" and e.get("built") and e["p"] == si and first_hl is None:
                        first_hl = e["t"]
                if first_hl is not None:
                    hl_games += 1
                    k["hl"].append(first_hl)
            mm = lambda x: "" if md(x) is None else wr.mmss(md(x))
            n0 = lambda x: "" if md(x) is None else "%d" % md(x)
            P("| %s | %s | %d | %s | %s | %s | %s | %s | %s | %s | %s | %d, %s | %d, %s |" % (NAME[pair], arm, len(k["t"]), mm(k["t"]), n0(k["val"]),
                n0(k["own"]), n0(k["ol"]), n0(k["fl"]), n0(k["ob"]), n0(k["a5"]), n0(k["a8"]), len(k["fa"]), mm(k["fa"]), hl_games, mm(k["hl"])))
    P("")
    nerr = {arm: sum(r["errs"] for pair in PAIRS for r in rows[(pair, arm)]) for arm in ARMS}
    nfail = {arm: len(glob.glob(os.path.join(data, arm, "*", "FAILED.txt"))) for arm in ARMS}
    P("Games with errors.txt: on %d, off %d; failed (no result): on %d, off %d." % (nerr["on"], nerr["off"], nfail["on"], nfail["off"]))


if __name__ == "__main__":
    main()
