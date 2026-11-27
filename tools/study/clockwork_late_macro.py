#!/usr/bin/env python3
"""CLOCKWORK LATE MACRO (job clockwork-late-macro, docs/clockwork_late_macro.md). A measuring tool: it changes no rule.
Hard OPTIMAL v Hard OPTIMAL to 20:00 on the parity maps, the SAME games as the win-rate study of 2026-11-26
(tools/study/winrate_1126_*.py: game i = seed 1126001 + i, map PARITY_MAPS[i % 6], spot (i // 6) % 2), so that study's
"default" data (docs/winrate_2026_11_26/data/<cell>/default/) is the BEFORE arm. A block = games 1..10 (spot A 1-5, spot B
6-10: every parity map, five games on each spot).
    python3 tools/study/clockwork_late_macro.py run ARM CELL[,CELL] [--games 1-10] [--jobs 2] [--extra a,b]
    python3 tools/study/clockwork_late_macro.py table CELL ARM [ARM ...]     (ARM "before" = the 2026-11-26 data)
    python3 tools/study/clockwork_late_macro.py games CELL ARM
Cells: crown_clock (the Clockwork v the Crown), clock_brood (v the Brood), clock_mirror ("our" side = spot A's).
Data: docs/clockwork_late_macro/data/<arm>/<cell>/<tag>/ (result.json, story.txt, cwlate.txt: the match log's cwlate lines,
cwtrace.txt.gz: tools/cw_trace.gd's trace every 5 s)."""
import os, sys, json, glob, gzip, math, shutil, subprocess, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = qm.PARITY_MAPS
ROOT = qm.ROOT
DATA = os.path.join(ROOT, "docs/clockwork_late_macro/data")
BEFORE = os.path.join(ROOT, "docs/winrate_2026_11_26/data")
# cell -> (our faction, their faction, the 2026-11-26 tag style)
CELLS = {"crown_clock": ("clockwork", "crown"), "clock_brood": ("clockwork", "brood"), "clock_mirror": ("clockwork", "clockwork")}
CUT = 1200


def game(cell, i):
    me, foe = CELLS[cell]
    m = MAPS[i % 6]
    spot = (i // 6) % 2
    seed = 1126001 + i
    if cell == "crown_clock":
        # (the 2026-11-26 study's "our" side was the Crown: spot 0 = the Crown in slot 0)
        a, b = ("crown", "clockwork") if spot == 0 else ("clockwork", "crown")
        tag = "g%02d_%s_%s" % (i, m, "AB"[spot])
    elif cell == "clock_brood":
        a, b = ("clockwork", "brood") if spot == 0 else ("brood", "clockwork")
        tag = "g%02d_%s_s%d" % (i, m, spot)
    else:
        a, b = "clockwork", "clockwork"
        tag = "g%02d_%s_%s" % (i, m, "AB"[spot])
    return tag, m, seed, [(a, "optimal", 0), (b, "optimal", 1)]


def run_one(cell, arm, i, extra):
    tag, m, seed, slots = game(cell, i)
    dd = os.path.join(DATA, arm, cell, tag)
    if os.path.exists(os.path.join(dd, "result.json")):
        return tag + " (had)"
    d = os.path.join("/tmp/claude-0/cwlate_out", arm, cell, tag)
    os.makedirs(d, exist_ok=True)
    spec = ",".join("%s/%s/%d" % s for s in slots)
    cmd = ["timeout", "3000", "godot", "--headless", "--fixed-fps", "30", "--path", ROOT, "--script", "res://tools/cw_trace.gd",
           "--", "map:" + m, "seed:%d" % seed, "end:%d" % CUT, "out:" + d, "slots:" + spec] + extra
    with open(os.path.join(d, "run.out"), "wb") as f:
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        n = 0
        for chunk in iter(lambda: p.stdout.read(65536), b""):
            if n < 20_000_000:
                f.write(chunk)
            n += len(chunk)
        p.wait()
    os.makedirs(dd, exist_ok=True)
    for fn in ("result.json", "story.txt"):
        if os.path.exists(os.path.join(d, fn)):
            shutil.copy(os.path.join(d, fn), dd)
    if os.path.exists(os.path.join(d, "cwtrace.txt")):
        with open(os.path.join(d, "cwtrace.txt"), "rb") as f, gzip.open(os.path.join(dd, "cwtrace.txt.gz"), "wb") as o:
            o.write(f.read())
    if os.path.exists(os.path.join(d, "log.txt")):
        with open(os.path.join(d, "log.txt"), errors="replace") as f, open(os.path.join(dd, "cwlate.txt"), "w") as o:
            for l in f:
                if "[cwlate" in l:
                    o.write(l)
    errs = [l.strip() for l in open(os.path.join(d, "run.out"), errors="replace") if qm.ERR.search(l)]
    if errs:
        with open(os.path.join(dd, "errors.txt"), "w") as f:
            f.write("\n".join(errs[:200]) + "\n")
    return tag + ("" if os.path.exists(os.path.join(dd, "result.json")) else " FAILED") + (" (%d error lines)" % len(errs) if errs else "")


def path_of(cell, arm, tag):
    if arm == "before":
        return os.path.join(BEFORE, cell, "default", tag, "result.json")
    return os.path.join(DATA, arm, cell, tag, "result.json")


def one(cell, arm, i):
    tag, m, seed, slots = game(cell, i)
    f = path_of(cell, arm, tag)
    if not os.path.exists(f):
        return None
    g = json.load(open(f))
    spot = (i // 6) % 2
    if cell == "clock_mirror":
        si = 0
    else:
        si = [k for k, s in enumerate(g["slots"]) if s[0] == "clockwork"][0]
    oi = 1 - si
    at = {}
    for x in g["minutes"]:
        at[(x["p"], int(round(x["t"] / 60)))] = x
    end, winner, fin = g["end"], g["winner"], g["final"]
    if end > CUT:
        mm = CUT // 60
        if (0, mm) in at and (1, mm) in at:
            fin = [at[(0, mm)], at[(1, mm)]]
        end, winner = CUT, -1
    fin = sorted(fin, key=lambda x: x["p"])
    sc = [x["income"] + 2 * x["army"] for x in fin]
    s_me = sc[si] * (0.25 if winner == oi else 1.0)
    s_op = sc[oi] * (0.25 if winner == si else 1.0)
    gv = math.log(max(1.0, s_me) / max(1.0, s_op))
    if winner >= 0:
        res = "W" if winner == si else "L"
    else:
        res = "w" if sc[si] > 1.1 * sc[oi] else ("l" if sc[oi] > 1.1 * sc[si] else "=")

    def val(p, key, mn):
        if winner >= 0 and p != winner and mn * 60 > end:
            return 0          # (beaten: nothing left)
        x = at.get((p, mn))
        if x is None and mn * 60 > end:
            x = fin[p]
        return None if x is None else x.get(key)

    mins = (10, 12, 14, 16, 18, 20)
    row = {"tag": tag, "i": i, "spot": spot, "res": res, "end": end, "g": gv}
    for key in ("bank", "supply", "cap", "army", "halls", "bld_lost"):
        row[key] = {mn: (val(si, key, mn), val(oi, key, mn)) for mn in mins}
    sb = fin[si].get("sb", {})
    row["works"] = sb.get("b:movement_works", 0) // 150
    row["springs"] = sb.get("b:mainspring", 0) // 140
    row["heavy"] = sb.get("b:heavy_works", 0) // 175
    return row


def rows_of(cell, arm, games):
    return [x for x in (one(cell, arm, i) for i in games) if x]


def mean(v):
    v = [x for x in v if x is not None]
    return sum(v) / len(v) if v else None


def tstat(v):
    if len(v) < 2:
        return 0.0
    sd = st.stdev(v)
    return (sum(v) / len(v)) / (sd / math.sqrt(len(v))) if sd > 0 else 0.0


def table(cell, arms, games):
    out = []
    out.append("| arm | games | Clockwork won | led | even | foe led | foe won | won or led | mean g (t) |")
    out.append("|---|---|---|---|---|---|---|---|---|")
    R = {}
    for a in arms:
        rows = R[a] = rows_of(cell, a, games)
        if not rows:
            continue
        c = {k: sum(1 for x in rows if x["res"] == k) for k in "Ww=lL"}
        gs = [x["g"] for x in rows]
        out.append("| %s | %d | %d | %d | %d | %d | %d | %d / %d | %+.2f (%.1f) |" % (a, len(rows), c["W"], c["w"], c["="], c["l"], c["L"],
                   c["W"] + c["w"], c["L"] + c["l"], mean(gs), tstat(gs)))
    out.append("")
    for key, name in (("bank", "Clockwork cogs in the bank"), ("supply", "Clockwork supply used"), ("cap", "Clockwork supply limit"),
                      ("army", "army value (Clockwork / foe)"), ("halls", "halls standing (Clockwork / foe)"),
                      ("bld_lost", "buildings lost so far (Clockwork / foe)")):
        out.append("%s, mean (a beaten side counts 0):" % name)
        out.append("")
        out.append("| arm | 10:00 | 12:00 | 14:00 | 16:00 | 18:00 | 20:00 |")
        out.append("|---|---|---|---|---|---|---|")
        for a in arms:
            rows = R[a]
            if not rows:
                continue
            cols = []
            for mn in (10, 12, 14, 16, 18, 20):
                me = mean([x[key][mn][0] for x in rows])
                op = mean([x[key][mn][1] for x in rows])
                if key in ("army", "halls", "bld_lost"):
                    cols.append("%s / %s" % (fmt(me), fmt(op)))
                else:
                    cols.append(fmt(me))
            out.append("| %s | %s |" % (a, " | ".join(cols)))
        out.append("")
    out.append("What the Clockwork built in all (means): Light Works, Mainsprings, Heavy Works:")
    out.append("")
    for a in arms:
        rows = R[a]
        if rows:
            out.append("- %s: %.1f Light Works, %.1f Mainsprings, %.1f Heavy Works" % (a, mean([x["works"] for x in rows]),
                       mean([x["springs"] for x in rows]), mean([x["heavy"] for x in rows])))
    return "\n".join(out)


def fmt(v):
    if v is None:
        return "-"
    return ("%.1fk" % (v / 1000.0)) if abs(v) >= 1000 else ("%.1f" % v if abs(v) < 20 else "%d" % round(v))


def parse_games(s):
    a, b = s.split("-")
    return list(range(int(a), int(b) + 1))


if __name__ == "__main__":
    arg = lambda key, d: sys.argv[sys.argv.index(key) + 1] if key in sys.argv else d
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    games = parse_games(arg("--games", "1-10"))
    if cmd == "run":
        arm, cells = sys.argv[2], sys.argv[3].split(",")
        extra = [x for x in arg("--extra", "").split(",") if x]
        work = [(c, i) for i in games for c in cells]
        with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
            for t in ex.map(lambda w: (w[0], run_one(w[0], arm, w[1], extra)), work):
                print("done", *t, flush=True)
    elif cmd == "table":
        print(table(sys.argv[2], sys.argv[3:], games))
    elif cmd == "games":
        for x in rows_of(sys.argv[2], sys.argv[3], games):
            print("%-24s %s %5.1f g %+.2f bank16 %s bank20 %s sup20 %s/%s halls20 %s works %d springs %d heavy %d" % (
                x["tag"], x["res"], x["end"] / 60.0, x["g"], x["bank"][16][0], x["bank"][20][0], x["supply"][20][0], x["cap"][20][0],
                x["halls"][20], x["works"], x["springs"], x["heavy"]))
    else:
        print(__doc__)
