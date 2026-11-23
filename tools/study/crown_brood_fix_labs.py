#!/usr/bin/env python3
"""(crown-brood-fix, docs/crown_brood_fix.md) THE OUTLYING HALLS: the Crown's labourers lost in a block of Crown v Brood
games (tools/study/crown_brood_fix.py or wr1000_crown_brood.py data), from result.json "deaths" ([t, kind, team, killer
kind, killer team, x, y, order]) and "minutes" (halls):
    python3 tools/study/crown_brood_fix_labs.py DATA_DIR/BLOCK [...]
Per block: games, labourers lost a game (all / from 12:00), who killed them, what they were doing (move = walking or
running away, gather = at work, build), and the Crown halls lost from 12:00 (the most halls held minus the halls at the
end). A measuring tool: it changes no rule."""
import sys, os, json, glob, collections


def crown(g):
    for i, s in enumerate(g["slots"]):
        if (s.get("faction") if isinstance(s, dict) else s[0]) == "crown":
            return i
    return 0


for d in sys.argv[1:]:
    n = lost = late = 0
    by = collections.Counter()
    do = collections.Counter()
    halls_lost = 0
    minute = collections.Counter()
    for f in sorted(glob.glob(os.path.join(d, "*", "result.json"))):
        g = json.load(open(f))
        si = crown(g)
        n += 1
        for x in g["deaths"]:
            if x[1] == "labourer" and x[2] == si:
                lost += 1
                minute[int(x[0] // 120) * 2] += 1
                if x[0] >= 720:
                    late += 1
                    by[x[3] or "?"] += 1
                    do[x[7]] += 1
        hs = [(m["t"], m.get("halls", 0)) for m in g["minutes"] if m["p"] == si]
        top = max([h for t, h in hs if t >= 720] or [0])
        endh = hs[-1][1] if hs else 0
        halls_lost += max(0, top - endh)
    if not n:
        continue
    tot = sum(by.values()) or 1
    print("%s: %d games, labourers lost %.1f a game (%.1f from 12:00), Crown halls lost from 12:00 %.1f a game" % (
        os.path.basename(d.rstrip("/")), n, lost / n, late / n, halls_lost / n))
    print("   from 12:00 killed by: " + ", ".join("%s %d%%" % (k, round(100 * v / tot)) for k, v in by.most_common(5)))
    print("   from 12:00 doing: " + ", ".join("%s %d%%" % (k, round(100 * v / tot)) for k, v in do.most_common(5)))
    print("   by two-minute span (start minute: lost): " + ", ".join("%d: %d" % (k, minute[k]) for k in sorted(minute)))
