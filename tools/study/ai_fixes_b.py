#!/usr/bin/env python3
"""AI FIXES B (job ai-fixes-b, docs/ai_fixes_b.md). A measuring tool: it changes no rule.
Hard OPTIMAL v Hard OPTIMAL to 20:00, the Crown against the Brood (cb) and against the Clockwork (ck), 20 games a
matchup: game i (0..19) has seed 2811001 + i, map PARITY_MAPS[i % 6], spot (i // 6) % 2 (spot 0: the Crown in slot 0).
Every arm plays the SAME games. tools/afb_watch.gd (in tools/qa_match.gd) counts the wheels' stuck seconds and the
Crown's fights at its halls below its main.
    python3 tools/study/ai_fixes_b.py run ARM [--jobs 2] [--end 1200] [--only cb|ck] [--n 20]
    python3 tools/study/ai_fixes_b.py report [ARM ...]
ARM: off (both fixes off) | on (both on, the default code) | home (only the home fix) | wheels (only the wheels fix).
Data: docs/ai_fixes_b/data/<arm>/<tag>/ (result.json, story.txt)."""
import os, sys, json, glob, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

ARMS = {"off": ["afbhome:off", "afbwheels:off"], "on": [], "home": ["afbwheels:off"], "wheels": ["afbhome:off"]}
DATA = os.path.join(qm.ROOT, "docs/ai_fixes_b/data")
OUT = "/tmp/claude-0/afb_runs"
PAIRS = {"cb": "brood", "ck": "clockwork"}


def queue(n=20, only=""):
    out = []
    for i in range(n):
        for key, foe in PAIRS.items():
            if only and key != only:
                continue
            m = qm.PARITY_MAPS[i % 6]
            spot = (i // 6) % 2
            a, b = ("crown", "optimal"), (foe, "optimal")
            s1, s2 = (a, b) if spot == 0 else (b, a)
            tag = "%s_g%02d_%s_s%d" % (key, i, m, spot)
            out.append((tag, m, 2811001 + i, [(s1[0], s1[1], 0), (s2[0], s2[1], 1)]))
    return out


def run(arm, jobs=2, end=1200, only="", n=20):
    qm.EXTRA = ARMS[arm]
    data = os.path.join(DATA, arm)
    out = os.path.join(OUT, arm)
    q = queue(n, only)
    with ThreadPoolExecutor(jobs) as ex:
        for r in ex.map(lambda g: qm.run_one(g, out, end, data), q):
            print(r, flush=True)


def crown_slot(tag):
    return 0 if tag.endswith("_s0") else 1


def score(side):
    return float(side.get("income", side.get("earned", 0)) or 0) + 2.0 * float(side.get("army", 0) or 0)


def load(arm):
    out = {}
    for f in sorted(glob.glob(os.path.join(DATA, arm, "*", "result.json"))):
        tag = os.path.basename(os.path.dirname(f))
        out[tag] = json.load(open(f))
    return out


def outcome(tag, r):
    c = crown_slot(tag)
    if r.get("over") and r.get("winner", -1) >= 0:
        return "won" if r["winner"] == c else "lost"
    fin = r.get("final", [])
    if len(fin) < 2:
        return "?"
    a, b = score(fin[c]), score(fin[1 - c])
    if a > b * 1.1:
        return "led"
    if b > a * 1.1:
        return "behind"
    return "even"


def summ(arm, key):
    rs = {t: r for t, r in load(arm).items() if t.startswith(key + "_")}
    if not rs:
        return None
    res = {"games": len(rs), "won": 0, "led": 0, "even": 0, "behind": 0, "lost": 0}
    eps = won = lost_h = watched = 0
    guns = mov = stk = 0
    runs = []
    for t, r in rs.items():
        res[outcome(t, r)] = res.get(outcome(t, r), 0) + 1
        a = r.get("afb", {})
        c = crown_slot(t)
        for e in a.get("home", []):
            if e["p"] != c:
                continue
            eps += 1
            won += 1 if e["won"] else 0
            lost_h += 1 if e["hall_lost"] else 0
            if e["army0"] >= e["foe_max"] and e["near_max"] < 0.5 * e["foe_max"]:
                watched += 1
        w = a.get("wheels", {}).get(str(c), {})
        guns += w.get("guns", 0)
        mov += w.get("moving_s", 0)
        stk += w.get("stuck_s", 0)
        runs += [x for x in a.get("runs", []) if x["p"] == c]
    res.update({"home_fights": eps, "home_won": won, "halls_lost_below": lost_h, "watched": watched,
                "guns": guns, "moving_s": mov, "stuck_s": stk, "stuck_per_gun": round(stk / max(guns, 1), 1),
                "stuck_share": round(100.0 * stk / max(mov, 1), 1), "runs10": len(runs),
                "runs30": len([x for x in runs if x["len"] >= 30])})
    return res


def report(arms):
    for key in PAIRS:
        print("==", key)
        for arm in arms:
            s = summ(arm, key)
            if s:
                print(arm, json.dumps(s))


def runs_list(arm):
    for t, r in load(arm).items():
        for x in r.get("afb", {}).get("runs", []):
            print(t, x["t"], x["p"], x["kind"], x["order"], x["mode"], x["at"], "->", x["goal"], x["len"])


if __name__ == "__main__":
    a = sys.argv[1:]
    if not a:
        print(__doc__)
    elif a[0] == "run":
        kw = {}
        i = 2
        while i < len(a):
            if a[i] == "--jobs": kw["jobs"] = int(a[i + 1])
            if a[i] == "--end": kw["end"] = int(a[i + 1])
            if a[i] == "--only": kw["only"] = a[i + 1]
            if a[i] == "--n": kw["n"] = int(a[i + 1])
            i += 2
        run(a[1], **kw)
    elif a[0] == "report":
        report(a[1:] or list(ARMS))
    elif a[0] == "runs":
        runs_list(a[1])
