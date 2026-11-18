#!/usr/bin/env python3
"""SCOUT DENY STUDY (scout-deny, docs/scout_deny.md): the six pairings (Crown v Brood, Crown v Clockwork, Clockwork v Brood
and the three mirrors) on four maps and two seeds (the base rounds' tags, seeds and sides of tools/study/qa_matches.py),
Hard OPTIMAL v Hard OPTIMAL to 12:00, each game twice: the rule ON (arm "on") and OFF (arm "off", `scoutdeny:off`).
A measuring tool.
    python3 tools/study/scout_deny.py list
    python3 tools/study/scout_deny.py run OUT --data DATA [--jobs 2] [--end 720] [--arms on,off]
DATA/<arm>/<tag>/ keeps result.json, story.txt and scout.txt (the match log's lines about scouts, reads and picks)."""
import os, re, sys, shutil, subprocess
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

MAPS = ["greenhold", "dune_sea", "ashford_crossing", "hollowfen"]
ARMS = {"on": [], "off": ["scoutdeny:off"]}
KEEP = re.compile(r"scout|scouted|read|optimal|sends|killed|lets the|rush|greedy|GREEDY", re.I)


def queue(arms):
    q = []
    for r in (0, 1):
        for g in qm.base(r):
            if g[1] in MAPS:
                for a in arms:
                    q.append((a,) + g)
    return q


def run(job, out, data, end):
    arm, tag, m, seed, slots = job
    dd = os.path.join(data, arm, tag)
    if os.path.exists(os.path.join(dd, "result.json")) or os.path.exists(os.path.join(dd, "FAILED.txt")):
        return arm + "/" + tag + " (had)"
    d = os.path.join(out, arm, tag)
    os.makedirs(d, exist_ok=True)
    spec = ",".join("%s/%s/%d" % s for s in slots)
    cmd = ["timeout", "3000", "godot", "--headless", "--fixed-fps", "30", "--path", qm.ROOT, "--script",
           "res://tools/qa_match.gd", "--", "map:" + m, "seed:%d" % seed, "end:%d" % end, "out:" + d, "slots:" + spec] + ARMS[arm]
    with open(os.path.join(d, "run.out"), "wb") as f:
        rc = subprocess.call(cmd, stdout=f, stderr=subprocess.STDOUT)
    os.makedirs(dd, exist_ok=True)
    for fn in ("result.json", "story.txt"):
        if os.path.exists(os.path.join(d, fn)):
            shutil.copy(os.path.join(d, fn), dd)
    if os.path.exists(os.path.join(d, "log.txt")):
        with open(os.path.join(d, "log.txt"), errors="replace") as f, open(os.path.join(dd, "scout.txt"), "w") as o:
            for l in f:
                if l.startswith("[") and KEEP.search(l) and "busy with" not in l:
                    o.write(l)
    errs = 0
    with open(os.path.join(d, "run.out"), errors="replace") as f:
        for l in f:
            if qm.ERR.search(l):
                errs += 1
    if errs:
        with open(os.path.join(dd, "errors.txt"), "w") as f:
            f.write("%d error lines (see the raw run in OUT)\n" % errs)
    if not os.path.exists(os.path.join(d, "result.json")):
        with open(os.path.join(dd, "FAILED.txt"), "w") as f:
            f.write("no result: exit code %d\n" % rc)
    else:
        shutil.rmtree(d, ignore_errors=True)
    return arm + "/" + tag


if __name__ == "__main__":
    arg = lambda k, dflt: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else dflt
    if len(sys.argv) < 2 or sys.argv[1] not in ("list", "run"):
        print(__doc__)
        sys.exit(1)
    arms = arg("--arms", "on,off").split(",")
    q = queue(arms)
    if sys.argv[1] == "list":
        for j in q:
            print(*j[:4])
        print(len(q), "games")
        sys.exit(0)
    out = os.path.abspath(sys.argv[2])
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/scout_deny/data")))
    end = int(arg("--end", "720"))
    print("%d games" % len(q), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda j: run(j, out, data, end), q):
            print("done", t, flush=True)
