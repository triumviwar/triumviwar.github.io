#!/usr/bin/env python3
"""CROWN MIRROR COACH (crown-mirror-coach, docs/crown_mirror_coach.md): the Crown mirror's 38 games (the QA study's design:
tools/study/qa_matches.py base(), 19 maps x round 0/1, Hard OPTIMAL v Hard OPTIMAL, to 15:00), played with
tools/film_coach.gd so every game keeps its log, story, coach lines and a map picture every 15 s. A measuring tool: it
changes no rule.
    python3 tools/study/crown_mirror_coach.py run DATA [--jobs 2] [--end 900] [--extra cmc:off,...] [--only map1,map2]
        [--round 0|1] [--maps]        (--maps keeps the map pictures; default: only every 60 s)
A game is done when DATA/<tag>/result.json exists; run again to resume."""
import os, sys, subprocess, shutil, glob
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import qa_matches as Q  # noqa: E402


def queue(rounds=(0, 1), only=None):
    out = []
    for r in rounds:
        for g in Q.base(r):
            if g[0].split("_")[-2] != "crcr":
                continue
            if only and g[1] not in only:
                continue
            out.append(g)
    return out


def run_one(g, data, end, extra, keep_maps):
    tag, m, seed, slots = g
    d = os.path.join(data, tag)
    rj = os.path.join(d, "result.json")
    if os.path.exists(rj) and os.path.getsize(rj) > 0:
        return tag + " (had)"
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(d, exist_ok=True)
    spec = ",".join("%s/%s/%d" % s for s in slots)
    cmd = ["timeout", "1800", "godot", "--headless", "--fixed-fps", "30", "--path", ROOT, "--script",
           "res://tools/film_coach.gd", "--", "map:" + m, "seed:%d" % seed, "end:%d" % end, "out:" + d,
           "slots:" + spec] + extra
    with open(os.path.join(d, "run.out"), "wb") as f:
        rc = subprocess.call(cmd, stdout=f, stderr=subprocess.STDOUT)
    if not keep_maps:
        for p in glob.glob(os.path.join(d, "map_*.png")):
            mm = os.path.basename(p)[4:8]
            if mm[2:] != "00":
                os.remove(p)
    for p in glob.glob(os.path.join(d, "siege_*.txt")):
        os.remove(p)
    if not os.path.exists(os.path.join(d, "result.json")):
        with open(os.path.join(d, "FAILED.txt"), "w") as f:
            f.write("exit %d\n" % rc)
    else:
        # the run's raw output is big and only its errors matter
        errs = [l for l in open(os.path.join(d, "run.out"), errors="replace") if "SCRIPT ERROR" in l or l.startswith("ERROR")]
        if errs:
            open(os.path.join(d, "errors.txt"), "w").writelines(errs[:200])
        os.remove(os.path.join(d, "run.out"))
    return tag


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    arg = lambda k, dflt: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else dflt
    data = os.path.abspath(sys.argv[2])
    extra = [x for x in arg("--extra", "").split(",") if x]
    only = arg("--only", "")
    rounds = (int(arg("--round", "")),) if "--round" in sys.argv else (0, 1)
    gl = queue(rounds, only.split(",") if only else None)
    print("%d games" % len(gl), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda g: run_one(g, data, int(arg("--end", "900")), extra, "--maps" in sys.argv), gl):
            print("done", t, flush=True)
