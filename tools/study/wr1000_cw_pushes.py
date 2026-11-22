#!/usr/bin/env python3
"""(wr1000-crown-clockwork) the Clockwork computer's pushes in a block, read from cwlog.txt: what each went out with, what
it reckoned of the Crown, what it lost and killed.   python3 tools/study/wr1000_cw_pushes.py BLOCK [BLOCK ...]"""
import os, re, sys, glob
DATA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../docs/wr1000_crown_clockwork/data")
OUT = re.compile(r"\[(\d+):(\d+)\].*army: goes out: worth (\d+) against the (\d+) it reckons")
BACK = re.compile(r"\[(\d+):(\d+)\].*push: pulls back .*?(\d+) value left of (\d+), killed (\d+)")
LOST = re.compile(r"lost (\d+) of the (\d+)")
for b in sys.argv[1:]:
    n = lost = killed = 0
    for f in sorted(glob.glob(os.path.join(DATA, b, "wcc_*", "cwlog.txt"))):
        for l in open(f, errors="replace"):
            if OUT.search(l):
                n += 1
            m = BACK.search(l)
            if m:
                k = int(m.group(5)); killed += k
                ml = LOST.search(l)
                lost += int(ml.group(1)) if ml else int(m.group(4)) - int(m.group(3))
    print("%s: %d pushes out: lost %d, killed %d (%.2f killed a lost)" % (b, n, lost, killed, killed / max(1, lost)))
