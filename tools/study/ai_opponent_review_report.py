#!/usr/bin/env python3
"""AI OPPONENT REVIEW report (docs/ai_opponent_review.md): tables from tools/study/ai_opponent_review.py's result.json files.
A measuring tool only.
    python3 tools/study/ai_opponent_review_report.py DATA [--csv games.csv] > tables.md
Outcome of a game: W / L if it ended by 20:00, else a draw at the bell, LED by a side whose score (income earned + 2 x army
value, the earlier studies' rule) is 10% ahead (w / l), else even (=). "Won or led" counts W + w.
The matrix is also cut at 12:00 (a game decided later counts as a draw led by its 12:00 row) and set beside
docs/winrate_2026_11_17 (to 12:00) on the same tags (map, seed, sides).
Blunder scan: the match tool's STALLS (an army standing still while 300+ of the enemy is in its base, a bank of 400+ unspent
for a minute, no unit made for 90 s), stuck units, first attacks that traded badly, games with no attack and too few halls."""
import os, sys, json, glob, math
from collections import Counter, defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CODE = {"cr": "crown", "br": "brood", "cw": "clockwork"}
NAMEF = {"crown": "Crown", "brood": "Brood", "clockwork": "Clockwork"}
PAIRS = ["crbr", "crcw", "brcw", "crcr", "brbr", "cwcw"]
PNAME = {"crbr": "Crown v Brood", "crcw": "Crown v Clockwork", "brcw": "Brood v Clockwork", "crcr": "Crown v Crown (P1)",
         "brbr": "Brood v Brood (P1)", "cwcw": "Clockwork v Clockwork (P1)"}
OLD = os.path.join(ROOT, "docs/winrate_2026_11_17/data")
LEVELS = ["easy", "normal", "hard"]
STRS = ["novice", "average", "good"]


def binom_p(k, n):
    if n == 0:
        return 1.0
    pk = [math.comb(n, i) / 2 ** n for i in range(n + 1)]
    return min(1.0, sum(p for p in pk if p <= pk[k] + 1e-12))


def mmss(s):
    return "-" if s is None else "%d:%02d" % (int(s) // 60, int(s) % 60)


def load_game(f, cut=None):
    g = json.load(open(f))
    at = {}
    for r in g["minutes"]:
        at[(r["p"], int(round(r["t"] / 60)))] = r
    end, winner, fin = g["end"], g["winner"], g["final"]
    if cut is not None and end > cut:
        m = cut // 60
        if (0, m) not in at or (1, m) not in at:
            return None
        fin = [at[(0, m)], at[(1, m)]]
        end, winner = cut, -1
    sc = [x["income"] + 2 * x["army"] for x in fin]
    return {"g": g, "at": at, "end": end, "winner": winner, "fin": fin, "sc": sc}


def outcome(x, si):
    oi = 1 - si
    if x["winner"] >= 0:
        return "W" if x["winner"] == si else "L"
    if x["sc"][si] > 1.1 * x["sc"][oi]:
        return "w"
    if x["sc"][oi] > 1.1 * x["sc"][si]:
        return "l"
    return "="


def tally(res):
    c = Counter(res)
    return c


def wdl(c):
    return "%d-%d-%d" % (c["W"], c["w"] + c["="] + c["l"], c["L"])


def led(c):
    return "%d / %d / %d" % (c["W"] + c["w"], c["L"] + c["l"], c["="])


def matrix(data, out):
    out.append("## The matrix: Hard OPTIMAL v Hard OPTIMAL to 20:00\n")
    out.append("Read from the first-named side (mirrors: P1 = spot A). W-D-L = won, drawn at the bell, lost. Won or led = "
               "first / second / even. The 12:00 cut beside the 2026-11-17 study's games on the same tags.\n")
    out.append("| pairing | games | W-D-L 20:00 | won or led 20:00 | median end of decided | W-D-L 12:00 | won or led 12:00 | 11-17 same tags (12:00) | paired better / worse (p) |")
    out.append("|---|---|---|---|---|---|---|---|---|")
    rows_csv = []
    for pair in PAIRS:
        res20, res12, old12, ends = [], [], [], []
        better = worse = 0
        for d in sorted(glob.glob(os.path.join(data, "base_*_%s_r*" % pair))):
            f = os.path.join(d, "result.json")
            if not os.path.exists(f):
                continue
            tag = os.path.basename(d)
            x = load_game(f)
            facs = [s[0] for s in x["g"]["slots"]]
            si = 0 if pair[:2] == pair[2:] else facs.index(CODE[pair[:2]])
            o20 = outcome(x, si)
            res20.append(o20)
            if x["winner"] >= 0:
                ends.append(x["end"])
            x12 = load_game(f, 720)
            o12 = outcome(x12, si) if x12 else None
            if o12:
                res12.append(o12)
            of = os.path.join(OLD, tag, "result.json")
            if os.path.exists(of) and o12:
                y = load_game(of, 720)
                if y:
                    oo = outcome(y, si)
                    old12.append(oo)
                    s_now = 1 if o12 in "Ww" else (-1 if o12 in "Ll" else 0)
                    s_old = 1 if oo in "Ww" else (-1 if oo in "Ll" else 0)
                    better += s_now > s_old
                    worse += s_now < s_old
            rows_csv.append([tag, pair, x["g"]["map"], o20, o12 or "", x["end"]])
        if not res20:
            continue
        c20, c12, co = tally(res20), tally(res12), tally(old12)
        ends.sort()
        out.append("| %s | %d | %s | %s | %s | %s | %s | %s | %d / %d (%.2f) |" % (
            PNAME[pair], len(res20), wdl(c20), led(c20), mmss(ends[len(ends) // 2]) if ends else "-", wdl(c12), led(c12),
            led(co) if old12 else "-", better, worse, binom_p(min(better, worse), better + worse) if better + worse else 1.0))
    out.append("")
    return rows_csv


def bench(data, out):
    out.append("## The benchmark players against the computer (to 20:00)\n")
    cells = defaultdict(list)       # (comp faction, level, strength) -> outcomes from the HUMAN's side
    by_bf = defaultdict(list)       # (bench faction, level, strength)
    games = []
    for d in sorted(glob.glob(os.path.join(data, "bench_*"))):
        f = os.path.join(d, "result.json")
        if not os.path.exists(f):
            continue
        x = load_game(f)
        sl = x["g"]["slots"]
        hi = [i for i, s in enumerate(sl) if len(s) > 3 and s[3] in STRS][0]
        ci = 1 - hi
        o = outcome(x, hi)
        bf, st, cf, lv = sl[hi][0], sl[hi][3], sl[ci][0], sl[ci][3]
        cells[(cf, lv, st)].append(o)
        by_bf[(bf, lv, st)].append(o)
        games.append((os.path.basename(d), bf, st, cf, lv, o, x["end"], x))
    out.append("Each cell is the HUMAN-LIKE PLAYER's record against that computer (all three benchmark factions together): "
               "won-drawn-lost (W-D-L at 20:00), then won or led / trailed / even at the bell. The owner's targets: a novice "
               "usually beats Easy; an average player has close games with Normal; a good player finds Hard a real fight.\n")
    for st in STRS:
        out.append("### %s player\n" % st.upper())
        out.append("| computer | v EASY | v NORMAL | v HARD |")
        out.append("|---|---|---|---|")
        for cf in ["crown", "brood", "clockwork"]:
            row = []
            for lv in LEVELS:
                c = tally(cells[(cf, lv, st)])
                n = sum(c.values())
                row.append("-" if n == 0 else "%s (%s)" % (wdl(c), led(c)))
            out.append("| %s computer | %s |" % (NAMEF[cf], " | ".join(row)))
        row = []
        for lv in LEVELS:
            c = Counter()
            for cf in ["crown", "brood", "clockwork"]:
                c.update(cells[(cf, lv, st)])
            row.append("%s (%s)" % (wdl(c), led(c)) if sum(c.values()) else "-")
        out.append("| **all** | %s |" % " | ".join(row))
        out.append("")
    out.append("### By the benchmark player's own faction (all computers together)\n")
    out.append("| player | v EASY | v NORMAL | v HARD |")
    out.append("|---|---|---|---|")
    for st in STRS:
        for bf in ["crown", "brood", "clockwork"]:
            row = []
            for lv in LEVELS:
                c = tally(by_bf[(bf, lv, st)])
                row.append("%s (%s)" % (wdl(c), led(c)) if sum(c.values()) else "-")
            out.append("| %s %s | %s |" % (st, NAMEF[bf], " | ".join(row)))
    out.append("")
    # how long decided games took, and economy at 8:00 human / computer
    out.append("### Economy at 8:00 and decided games\n")
    out.append("| strength | level | games | human income / computer at 8:00 (median) | human workers / computer at 8:00 | computer wins: median end | human wins: median end |")
    out.append("|---|---|---|---|---|---|---|")
    for st in STRS:
        for lv in LEVELS:
            rs, ws, cw_end, hw_end = [], [], [], []
            n = 0
            for tag, bf, s2, cf, l2, o, end, x in games:
                if s2 != st or l2 != lv:
                    continue
                n += 1
                sl = x["g"]["slots"]
                hi = [i for i, s in enumerate(sl) if len(s) > 3 and s[3] in STRS][0]
                a, b = x["at"].get((hi, 8)), x["at"].get((1 - hi, 8))
                if a and b and b["income"] > 0:
                    rs.append(a["income"] / b["income"])
                    if b["workers"]:
                        ws.append(a["workers"] / b["workers"])
                if o == "L":
                    cw_end.append(end)
                if o == "W":
                    hw_end.append(end)
            med = lambda v: sorted(v)[len(v) // 2] if v else None
            out.append("| %s | %s | %d | %s | %s | %s | %s |" % (st, lv, n, "%.2f" % med(rs) if rs else "-",
                       "%.2f" % med(ws) if ws else "-", mmss(med(cw_end)) if cw_end else "-", mmss(med(hw_end)) if hw_end else "-"))
    out.append("")
    return games


def sanity(data, out):
    rows = []
    for d in sorted(glob.glob(os.path.join(data, "sanity_*"))):
        f = os.path.join(d, "result.json")
        if not os.path.exists(f):
            continue
        x = load_game(f)
        sl = x["g"]["slots"]
        rank = {"novice": 0, "average": 1, "good": 2}
        hi = 0 if rank[sl[0][3]] > rank[sl[1][3]] else 1
        rows.append((os.path.basename(d), sl[hi][3], NAMEF[sl[hi][0]], sl[1 - hi][3], NAMEF[sl[1 - hi][0]], outcome(x, hi), x["end"]))
    if rows:
        out.append("## Sanity: the benchmark players against each other (from the stronger one's side)\n")
        out.append("| game | stronger | weaker | result | end |")
        out.append("|---|---|---|---|---|")
        for r in rows:
            out.append("| %s | %s %s | %s %s | %s | %s |" % (r[0], r[1], r[2], r[3], r[4], r[5], mmss(r[6])))
        c = Counter(r[5] for r in rows)
        out.append("\nStronger player won or led %d of %d (lost or trailed %d).\n" % (c["W"] + c["w"], len(rows), c["L"] + c["l"]))


def blunders(data, out):
    out.append("## Blunder scan (computer sides only)\n")
    out.append("Per computer level, the share of its games with each event (the match tool's own detectors), and how often. "
               "army idle = its army stood still (fewer than a quarter fighting) while 300+ of the enemy was in its base for "
               "the stall's length; bank = 400+ unspent for a minute; no units = nothing made for 90 s below the supply cap; "
               "stuck = a unit stuck on a move order; bad first attack = its first attack lost 2x what it killed; no attack = "
               "never attacked by 12:00; one hall = still one hall at 10:00.\n")
    agg = defaultdict(lambda: Counter())
    ngames = Counter()
    examples = defaultdict(list)
    for d in sorted(glob.glob(os.path.join(data, "*", "result.json"))):
        g = json.load(open(d))
        tag = os.path.basename(os.path.dirname(d))
        for i, s in enumerate(g["slots"]):
            who = s[3] if len(s) > 3 and s[3] else "hard"
            if who in STRS:
                continue
            key = (NAMEF[s[0]], who)
            ngames[key] += 1
            seen = set()
            for e in g["events"]:
                if e.get("p") != i:
                    continue
                k = None
                if e.get("ev") == "stall":
                    k = {"army_idle_enemy_in_base": "army idle", "bank_unspent": "bank", "no_units": "no units"}.get(e.get("kind"), e.get("kind"))
                elif e.get("ev") == "stuck":
                    k = "stuck"
                elif e.get("ev") == "first_attack" and e.get("lost", 0) >= 2 * max(1, e.get("foe_lost", 0)) and e.get("lost", 0) >= 200:
                    k = "bad first attack"
                if k:
                    agg[key][k + " (events)"] += 1
                    if k not in seen:
                        agg[key][k] += 1
                        seen.add(k)
                        if len(examples[k]) < 12:
                            examples[k].append("%s P%d %s at %s" % (tag, i + 1, key[0], mmss(e.get("t"))))
            if not any(e.get("ev") == "first_attack" and e.get("p") == i and e["t"] <= 720 for e in g["events"]) and g["end"] >= 720:
                agg[key]["no attack by 12:00"] += 1
                if len(examples["no attack by 12:00"]) < 12:
                    examples["no attack by 12:00"].append("%s P%d %s" % (tag, i + 1, key[0]))
            r10 = [m for m in g["minutes"] if m["p"] == i and int(round(m["t"] / 60)) == 10]
            if r10 and s[0] != "brood" and r10[0].get("halls", 0) <= 1:
                agg[key]["one hall at 10:00"] += 1
                if len(examples["one hall at 10:00"]) < 12:
                    examples["one hall at 10:00"].append("%s P%d %s" % (tag, i + 1, key[0]))
    kinds = ["army idle", "bank", "no units", "stuck", "bad first attack", "no attack by 12:00", "one hall at 10:00"]
    out.append("| computer | games | " + " | ".join(kinds) + " |")
    out.append("|---|---|" + "---|" * len(kinds))
    for key in sorted(ngames):
        n = ngames[key]
        out.append("| %s %s | %d | " % (key[0], key[1].upper(), n) + " | ".join(
            "%d%% (%d)" % (round(100 * agg[key][k] / n), agg[key][k + " (events)"]) if k + " (events)" in agg[key] else
            ("%d%%" % round(100 * agg[key][k] / n)) for k in kinds) + " |")
    out.append("\nExamples:\n")
    for k in kinds:
        if examples[k]:
            out.append("- %s: %s" % (k, "; ".join(examples[k][:8])))
    out.append("")


if __name__ == "__main__":
    data = sys.argv[1]
    out = ["# AI opponent review: tables (tools/study/ai_opponent_review_report.py)\n"]
    n = len(glob.glob(os.path.join(data, "*", "result.json")))
    out.append("%d games with a result.\n" % n)
    rows = matrix(data, out)
    games = bench(data, out)
    sanity(data, out)
    blunders(data, out)
    print("\n".join(out))
    if "--csv" in sys.argv:
        with open(sys.argv[sys.argv.index("--csv") + 1], "w") as f:
            f.write("tag,bench,strength,computer,level,human_result,end\n")
            for tag, bf, st, cf, lv, o, end, x in games:
                f.write("%s,%s,%s,%s,%s,%s,%d\n" % (tag, bf, st, cf, lv, o, end))
            f.write("\ntag,pair,map,res20,res12,end\n")
            for r in rows:
                f.write(",".join(str(v) for v in r) + "\n")
