#!/usr/bin/env python3
"""CROWN-COACH-BALLOON's measuring batch (docs/crown-coach-balloon.md): Hard OPTIMAL Crown v Hard OPTIMAL Clockwork on 12
maps (the win-rate study's tags and seeds, one round per map), 15:00, tools/qa_match.gd headless, the Crown's plan forced
by the study switches. A measuring tool only.
    python3 tools/study/crown_coach_balloon.py run DATA VARIANT      (VARIANT: bl_old, bl_new, timing, economy, default)
    python3 tools/study/crown_coach_balloon.py report DATA VARIANT...
GODOT=/path/to/godot (default `godot`), JOBS=2 games at once, ROOTP=the project folder to run (default this checkout)."""
import os, sys, subprocess, json, re, glob, statistics as st
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as q
from concurrent.futures import ThreadPoolExecutor
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
VAR = {
 "bl_old": ["normalclock:balloon", "greedyclock:balloon", "blfix:off", "bltrace:1"],
 "bl_new": ["normalclock:balloon", "greedyclock:balloon", "bltrace:1"],
 "timing": ["normalclock:timing", "greedyclock:timing"],
 "economy": ["normalclock:economy", "greedyclock:economy"],
 "default": ["bltrace:1"],
}
MAPS12 = ["greenhold", "highmoor", "dune_sea", "frostfang", "twin_fords", "ashfall", "red_coast", "ashford_crossing",
          "kestrel_rise", "redrock_canyon", "cinder_steps", "hollowfen"]


def games():
    gs = [g for g in q.crcw_all((0, 1)) if g[1] in MAPS12]
    return [g for g in gs if int(g[0][-1]) == MAPS12.index(g[1]) % 2]      # (one round a map: both start spots appear)


def run_one(data, var, g):
    tag, m, seed, slots = g
    d = os.path.join(data, var, tag)
    if os.path.exists(os.path.join(d, "result.json")):
        return
    os.makedirs(d, exist_ok=True)
    spec = ",".join("%s/%s/%d" % s for s in slots)
    cmd = ["timeout", "3000", os.environ.get("GODOT", "godot"), "--headless", "--fixed-fps", "30", "--path",
           os.environ.get("ROOTP", ROOT), "--script", "res://tools/qa_match.gd", "--", "map:" + m, "seed:%d" % seed,
           "end:900", "out:" + d, "slots:" + spec] + VAR[var]
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    with open(os.path.join(d, "run.out"), "w") as f:
        f.write("\n".join(l for l in p.stdout.decode(errors="replace").splitlines() if l.startswith("BL") or "SCRIPT ERROR" in l))
    if os.path.exists(os.path.join(d, "log.txt")):
        with open(os.path.join(d, "log.txt"), errors="replace") as f, open(os.path.join(d, "bl.txt"), "w") as o:
            for l in f:
                if "Crown's plan" in l or "Crown scouted" in l:
                    o.write(l)
        os.remove(os.path.join(d, "log.txt"))


def at(minutes, p, t):
    best = None
    for m in minutes:
        if m["p"] == p and m["t"] <= t + 5:
            best = m
    return best


def one(d):
    r = json.load(open(os.path.join(d, "result.json")))
    cp = [i for i, s in enumerate(r["slots"]) if s[0] == "crown"][0]
    wp = 1 - cp
    ms = r["minutes"]
    res = "D" if r["winner"] in (-1, None) else ("W" if r["winner"] == cp else "L")
    row = {"tag": os.path.basename(d), "res": res, "end": max(m["t"] for m in ms)}
    for t in (300, 480, 600, 900):
        a, b = at(ms, cp, t), at(ms, wp, t)
        if a and b:
            row.update({"inc%d" % t: a["income"], "cinc%d" % t: b["income"], "army%d" % t: a["army"], "carmy%d" % t: b["army"],
                        "lab%d" % t: a["workers"]})
    fa = [f for f in r["final"] if f["p"] == cp][0]
    fb = [f for f in r["final"] if f["p"] == wp][0]
    row["score"] = (fa["income"] + 2 * fa["army"]) / max(1, fb["income"] + 2 * fb["army"])
    row["lost_u"], row["cw_lost_u"] = fa["lost"], fb["lost"]
    row["halls_lost"] = sum(1 for e in r["events"] if e.get("ev") == "hall_lost" and e.get("p") == cp)
    row["cw_halls_lost"] = sum(1 for e in r["events"] if e.get("ev") == "hall_lost" and e.get("p") == wp)
    ro = os.path.join(d, "run.out")
    if os.path.exists(ro):
        s = [l for l in open(ro, errors="replace") if l.startswith("BLSUM")]
        if s:
            g = re.search(r"strikes (\d+) \(drops (\d+).*killed (\d+) \((\d+) workers\), lost (\d+) balloons and (\d+) men \| parties (\d+)", s[-1])
            row.update(strikes=int(g[1]), blk=int(g[3]), blw=int(g[4]), blb=int(g[5]), blm=int(g[6]), blp=int(g[7]))
    bl = os.path.join(d, "bl.txt")
    if os.path.exists(bl):
        txt = open(bl, errors="replace").read()
        row["few"] = txt.count("too few aboard")
        m = re.search(r"\[(\d+):(\d+)\] P\d Crown's plan: party 1 forms", txt)
        row["form1"] = int(m[1]) * 60 + int(m[2]) if m else None
        m = re.search(r"\[(\d+):(\d+)\] P\d Crown's plan: the first strike", txt)
        row["strike1"] = int(m[1]) * 60 + int(m[2]) if m else None
    return row


def report(data, var):
    rows = [one(d) for d in sorted(glob.glob(os.path.join(data, var, "*"))) if os.path.exists(os.path.join(d, "result.json"))]
    if not rows:
        print(var, "no games")
        return
    out = {"n": len(rows), "W-D-L": "%d-%d-%d" % tuple(sum(r["res"] == k for r in rows) for k in "WDL"),
           "score": round(st.mean(r["score"] for r in rows), 3)}
    for k in ["inc300", "cinc300", "inc480", "cinc480", "inc600", "cinc600", "army480", "carmy480", "army600", "carmy600",
              "army900", "carmy900", "lab480", "lost_u", "cw_lost_u", "halls_lost", "cw_halls_lost", "form1", "strike1"]:
        v = [r[k] for r in rows if r.get(k) is not None]
        out[k] = round(st.mean(v)) if v else None
    for k in ["strikes", "blk", "blw", "blb", "blm", "blp", "few"]:
        out[k + "_total"] = sum(r.get(k) or 0 for r in rows)
    dec = [r["end"] for r in rows if r["res"] != "D"]
    out["decided_mean_end"] = round(st.mean(dec)) if dec else None
    print("==", var, json.dumps(out))
    for r in rows:
        print("   ", r["tag"], r["res"], r["end"], round(r["score"], 2), r.get("blk"), r.get("blb"), r.get("blm"))


if __name__ == "__main__":
    if len(sys.argv) >= 4 and sys.argv[1] == "run":
        with ThreadPoolExecutor(int(os.environ.get("JOBS", "2"))) as ex:
            list(ex.map(lambda g: run_one(sys.argv[2], sys.argv[3], g), games()))
    elif len(sys.argv) >= 4 and sys.argv[1] == "report":
        for v in sys.argv[3:]:
            report(sys.argv[2], v)
    else:
        print(__doc__)
