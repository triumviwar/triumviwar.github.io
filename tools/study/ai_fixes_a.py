#!/usr/bin/env python3
"""AI FIXES A (ai-fixes-a, docs/ai_fixes_a.md): a measuring tool, it changes no rule.
    python3 tools/study/ai_fixes_a.py list  PART
    python3 tools/study/ai_fixes_a.py run   PART OUT --data DATA [--jobs 2] [--root DIR] [--extra a:b,c:d]
PART:
  bench:<lv>:<cf>[:<rounds>] : the opponent review's benchmark games (scripts/ai_bench_human.gd) against ONE computer faction
      <cf> at level <lv>: every benchmark faction x strength (novice, average, good), the review's tags, maps, seeds and
      sides (ai_opponent_review.bench(r)), rounds 0..rounds-1 (default 2), to 15:00;
  raid:<foe>[:<n>] : the Hard Clockwork OPTIMAL v the Hard <foe> OPTIMAL (crown or brood) on the six parity maps, qa_matches
      base rounds 0.. (the same seeds every arm), the first n games (default 20), to 20:00, the Clockwork's log lines kept.
The arm is the --extra switches (e.g. normalpace:off, cwraidsize:off,cwraidpart:off); give each arm its own --data."""
import os, sys, shutil
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm
import ai_opponent_review as aor


def queue(part):
    p = part.split(":")
    if p[0] == "bench":
        lv, cf = p[1], p[2]
        rounds = int(p[3]) if len(p) > 3 else 2
        out = []
        for r in range(rounds):
            out += [g for g in aor.bench(r) if "_v_%s%s_" % (qm.SHORT[cf], lv) in g[0]]
        return out, aor.BENCH_END
    if p[0] == "raid":
        foe = p[1]
        n = int(p[2]) if len(p) > 2 else 20
        pair = "cr" + "cw" if foe == "crown" else "brcw"
        out = []
        r = 0
        while len(out) < n:
            out += [g for g in qm.base(r) if g[1] in qm.PARITY_MAPS and g[0].split("_")[-2] == pair]
            r += 1
        return out[:n], 1200
    raise SystemExit("unknown part " + part)


def run_one(g, out, data, end, extra):
    tag, m, seed, slots = g
    if len(slots[0]) == 4:
        spec = ",".join("/".join(str(x) for x in s) for s in slots)
        r = qm.run_one((tag, m, seed, []), out, end, data, ["slots:" + spec] + extra)
    else:
        r = qm.run_one(g, out, end, data, extra)
    shutil.rmtree(os.path.join(out, tag), ignore_errors=True)      # (the raw output and match log are big; the disk is short)
    return r


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    gl, end = queue(sys.argv[2])
    if sys.argv[1] == "list":
        for g in gl:
            print(g[0], g[1], g[2], g[3])
        print(len(gl), "games")
        sys.exit(0)
    out = os.path.abspath(sys.argv[3])
    if "--root" in sys.argv:
        qm.RUN_ROOT = os.path.abspath(arg("--root", qm.ROOT))
    qm.KEEP_CW = True
    extra = [x for x in arg("--extra", "").split(",") if x]
    data = os.path.abspath(arg("--data", ""))
    print("%d games, extra %s" % (len(gl), extra), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda g: run_one(g, out, data, end, extra), gl):
            print("done", t, flush=True)
