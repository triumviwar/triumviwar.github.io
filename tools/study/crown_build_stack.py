#!/usr/bin/env python3
"""CROWN BUILD STACK MEASURE (crown-build-stack, docs/crown_build_stack.md): the Crown computer's labourers stacked on its
sites (scripts/ai_crown_stack.gd) and its labourer fixes measured with the win-rate design (qa_matches.base(): 19 maps x
round 0 and 1, Hard OPTIMAL v Hard OPTIMAL). A measuring tool.
    python3 tools/study/crown_build_stack.py list [--pairs crbr,crcw,crcr] [--rounds 0,1]
    python3 tools/study/crown_build_stack.py run OUT --data DATA [--jobs 2] [--end 720] [--pairs ...] [--rounds ...]
        [--root DIR] [--off buildstack:off,labs2:off] [--script res://tools/crown_econ_trace.gd]
Arms: Crown v Brood / v Clockwork: "on" (as is) and "off" (the --off switches); the Crown mirror: "a" (team 1's switches
off: team 0 has the change) and "b" (team 0's off), so each mirror game pits the change against its absence and the
spots swap between a and b. Order: round by round, map by map, pairing by pairing, a game's arms next to each other, so a
run cut short still has paired data. DATA/<arm>/<tag>/result.json done = skipped (resumable). trace.json is kept when
the script writes it (tools/crown_econ_trace.gd)."""
import os, sys, subprocess, shutil, re
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm

ERR = re.compile(r"SCRIPT ERROR|^ERROR")


def arms(pair, off, on=()):
    """the "on" arm plays the --on switches, the "off" arm the --off ones; in the mirror arm a gives team 0 the change
    (its --on switches with 0, the --off ones with 1), arm b team 1"""
    if pair == "crcr":
        return [("a", [s + "0" for s in on] + [s + "1" for s in off]), ("b", [s + "1" for s in on] + [s + "0" for s in off])]
    return [("on", list(on)), ("off", list(off))]


def queue(pairs, rounds, off, on=()):
    q = []
    for r in rounds:
        for g in qm.base(r):
            p = g[0].split("_")[-2]
            if p in pairs:
                for arm, extra in arms(p, off, on):
                    q.append((arm, extra, g))
    return q


def run_one(item, out, end, data, root, script):
    arm, extra, g = item
    tag, m, seed, slots = g
    dd = os.path.join(data, arm, tag)
    if os.path.exists(os.path.join(dd, "result.json")) or os.path.exists(os.path.join(dd, "FAILED.txt")):
        return arm + " " + tag + " (had)"
    d = os.path.join(out, arm, tag)
    os.makedirs(d, exist_ok=True)
    spec = ",".join("%s/%s/%d" % s for s in slots)
    cmd = ["timeout", "3000", "godot", "--headless", "--fixed-fps", "30", "--path", root, "--script", script, "--",
           "map:" + m, "seed:%d" % seed, "end:%d" % end, "out:" + d, "slots:" + spec] + extra
    with open(os.path.join(d, "run.out"), "wb") as f:
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        n = 0
        for chunk in iter(lambda: p.stdout.read(65536), b""):
            if n < 20_000_000:
                f.write(chunk)
            n += len(chunk)
        p.wait()
    os.makedirs(dd, exist_ok=True)
    for fn in ("result.json", "story.txt", "trace.json"):
        if os.path.exists(os.path.join(d, fn)):
            shutil.copy(os.path.join(d, fn), dd)
    with open(os.path.join(d, "run.out"), errors="replace") as f:
        errs = [l.strip() for l in f if ERR.search(l)]
    if errs:
        with open(os.path.join(dd, "errors.txt"), "w") as f:
            f.write("%d error lines\n" % len(errs))
            seen = {}
            for e in errs:
                seen[e] = seen.get(e, 0) + 1
            for e, c in sorted(seen.items(), key=lambda x: -x[1])[:60]:
                f.write("%5d  %s\n" % (c, e))
    if not os.path.exists(os.path.join(dd, "result.json")):
        with open(os.path.join(dd, "FAILED.txt"), "w") as f:
            f.write(" ".join(cmd) + "\n")
    shutil.rmtree(d, ignore_errors=True)
    return arm + " " + tag


if __name__ == "__main__":
    arg = lambda k, dflt: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else dflt
    if len(sys.argv) < 2 or sys.argv[1] not in ("list", "run"):
        print(__doc__)
        sys.exit(1)
    pairs = arg("--pairs", "crbr,crcw,crcr").split(",")
    rounds = [int(x) for x in arg("--rounds", "0,1").split(",")]
    off = [x for x in arg("--off", "").split(",") if x]
    on = [x for x in arg("--on", "buildstack:on,hallkeep:on").split(",") if x]
    gl = queue(pairs, rounds, off, on)
    if sys.argv[1] == "list":
        for a, e, g in gl:
            print(a, " ".join(e), g[0], g[1], g[2], g[3])
        print(len(gl), "games")
        sys.exit(0)
    out = os.path.abspath(sys.argv[2])
    data = os.path.abspath(arg("--data", os.path.join(qm.ROOT, "docs/crown_build_stack/data")))
    end = int(arg("--end", "720"))
    root = os.path.abspath(arg("--root", qm.ROOT))
    script = arg("--script", "res://tools/qa_match.gd")
    print("%d games" % len(gl), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda it: run_one(it, out, end, data, root, script), gl):
            print("done", t, flush=True)
