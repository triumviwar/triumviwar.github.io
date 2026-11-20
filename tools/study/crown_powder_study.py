#!/usr/bin/env python3
"""CROWN POWDER STUDY (crown-powder-study, docs/crown_powder_study.md): the design options for the Crown's late powder,
each a match switch (`-- powder:<opt>`, scripts/crown_powder.gd), measured in computer games: Crown Hard OPTIMAL v the
Brood, v the Clockwork and the Crown mirror, the SAME 10 games as the crown-1000 jobs (5 maps x 2 rounds, start spots
swapped, their seeds: tools/study/crown_1000_brood.py), to 20:00; 2 blocks per option per matchup, pooled.
    python3 tools/study/crown_powder_study.py run OPT OPP BLOCK [--jobs 2] [--root DIR]
        OPT: base (no switch) | salt2500 | floor35 | nitre | buy | salt2500+nitre ...   OPP: brood | clockwork | crown
    python3 tools/study/crown_powder_study.py report [--md]
Data: docs/crown_powder_study/data/<OPT>/<OPP>_b<BLOCK>/<tag>/ (result.json, story.txt, planlog.txt)."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm
import crown_1000_brood as cb

DATA = os.path.join(qm.ROOT, "docs/crown_powder_study/data")
OPTS = ["base", "salt2500", "floor35", "nitre", "buy", "salt2500+nitre"]
OPPS = ["brood", "clockwork", "crown"]
DRY_POWDER = 10        # a dry minute: under a Musketeer's load banked ...
DRY_GOLD = 400         # ... while this much gold is banked


def run(opt, opp, blk, jobs=2, root=None):
    cb.OPP = opp
    dd = os.path.join(DATA, opt, "%s_b%d" % (opp, blk))
    os.makedirs(dd, exist_ok=True)
    extra = [] if opt == "base" else ["powder:" + opt]
    with open(os.path.join(dd, "extra.txt"), "w") as f:
        f.write(" ".join(extra) + "\n")
    qm.RUN_ROOT = os.path.abspath(root or qm.ROOT)
    qm.KEEP_GREP = "Crown's plan"
    out = "/tmp/cps_out/%s_%s_b%d" % (opt, opp, blk)
    with ThreadPoolExecutor(jobs) as ex:
        for t in ex.map(lambda g: qm.run_one(g, out, 1200, dd, extra), cb.queue()):
            print("done", opt, opp, blk, t, flush=True)


def game(d, opp):
    """One game's numbers: crown_1000_brood's (g, survived, won or led, ratios) + the powder measures of the Crown side
    (the side the queue calls "me"; in the mirror both sides play the option)."""
    cb.OPP = opp
    x = cb.one(d)
    if x is None:
        return None
    g = json.load(open(os.path.join(d, "result.json")))
    si, oi = x["si"], 1 - x["si"]
    mins = {}
    for m in g["minutes"]:
        mins[(m["p"], int(round(m["t"] / 60)))] = m
    end_m = min(20, int(x["end"] // 60))
    dry = 0
    salt0 = None
    for mn in range(1, end_m + 1):
        m = mins.get((si, mn))
        if not m:
            continue
        ce = m.get("crown") or {}
        if ce.get("powder", 99999) < DRY_POWDER and m.get("bank", 0) >= DRY_GOLD:
            dry += 1
    def at(p, mn, key, sub=None):
        m = mins.get((p, mn))
        if not m:
            return None
        if sub:
            return (m.get("crown") or {}).get(sub)
        return m.get(key)
    x["dry"] = dry
    for mn in (8, 12, 16):
        x["pow%d" % mn] = at(si, mn, None, "powder")
        x["gold%d" % mn] = at(si, mn, "bank")
        x["arm%d" % mn] = at(si, mn, None, "musk_armed")
        x["bay%d" % mn] = at(si, mn, None, "musk_dry")
        x["army%d_v" % mn] = at(si, mn, "army")
        x["inc%d_v" % mn] = at(si, mn, "income")
        x["hands%d" % mn] = at(si, mn, None, "on_mills")
        x["mills%d" % mn] = at(si, mn, None, "mills")
        x["salt%d" % mn] = at(si, mn, None, "salt")
        x["halls%d" % mn] = at(si, mn, "halls")
        x["inc%d" % mn] = cb_ratio(mins, si, oi, mn, "income")
        x["army%d" % mn] = cb_ratio(mins, si, oi, mn, "army")
    last = None
    for mn in range(end_m, 0, -1):
        if (si, mn) in mins:
            last = mins[(si, mn)]
            break
    made = ((last or {}).get("crown") or {}).get("opt_made") or {}
    x["nitre"] = made.get("nitre", 0)
    x["bought"] = made.get("bought", 0)
    x["res2"] = (last or {}).get("res2")
    # the mirror: the opponent's own option use too
    return x


def cb_ratio(mins, si, oi, mn, key):
    a, b = mins.get((si, mn)), mins.get((oi, mn))
    if not a or not b or not b.get(key):
        return None
    return a[key] / b[key]


def pool(opt, opp):
    rows = []
    for d in sorted(glob.glob(os.path.join(DATA, opt, opp + "_b*", "c1k_*"))):
        x = game(d, opp)
        if x:
            x["block"] = os.path.basename(os.path.dirname(d))
            rows.append(x)
    return rows


def mean(v):
    v = [a for a in v if a is not None]
    return sum(v) / len(v) if v else None


def med(v):
    v = [a for a in v if a is not None]
    return st.median(v) if v else None


def summary(rows):
    if not rows:
        return None
    s = {"n": len(rows), "g": mean([r["g"] for r in rows]), "g14": mean([r["g14"] for r in rows]),
         "surv": sum(1 for r in rows if r["res"] != "L"), "wl": sum(1 for r in rows if r["res"] in ("W", "w")),
         "won": sum(1 for r in rows if r["res"] == "W"), "beat": med([r["beaten"] for r in rows]),
         "dry": mean([r["dry"] for r in rows]), "nitre": mean([r["nitre"] for r in rows]), "bought": mean([r["bought"] for r in rows]),
         "res2": mean([r["res2"] for r in rows])}
    for mn in (8, 12, 16):
        for k in ("inc", "army"):
            # a ratio's mean in logs (x of the enemy's)
            v = [math.log(r["%s%d" % (k, mn)]) for r in rows if r.get("%s%d" % (k, mn))]
            s["%s%d" % (k, mn)] = math.exp(sum(v) / len(v)) if v else None
        for k in ("pow", "gold", "arm", "bay", "army%d_v", "inc%d_v", "hands", "mills", "salt", "halls"):
            kk = k % mn if "%" in k else "%s%d" % (k, mn)
            s[kk] = med([r.get(kk) for r in rows])
    return s


def paired(rows, base):
    """the paired difference of g against the base pool, game by game (each tag's mean over its blocks)"""
    def by_tag(rs, key):
        d = {}
        for r in rs:
            if r.get(key) is not None:
                d.setdefault(r["tag"], []).append(r[key])
        return {t: sum(v) / len(v) for t, v in d.items()}
    out = {}
    for key in ("g", "g14"):
        a, b = by_tag(rows, key), by_tag(base, key)
        ds = [a[t] - b[t] for t in a if t in b]
        if len(ds) >= 2:
            md = sum(ds) / len(ds)
            sd = st.stdev(ds)
            out[key] = (md, md / (sd / math.sqrt(len(ds))) if sd > 0 else 0.0, sum(1 for x in ds if x > 0.05), sum(1 for x in ds if x < -0.05))
    return out


def f2(v, k=2):
    return "" if v is None else ("%." + str(k) + "f") % v


def mmss(v):
    return "-" if v is None else "%d:%02d" % (int(v) // 60, int(v) % 60)


def report():
    for opp in OPPS:
        base = pool("base", opp)
        print("\n### Crown v %s\n" % {"brood": "the Brood", "clockwork": "the Clockwork", "crown": "the Crown (mirror)"}[opp])
        print("| option | games | survived | won or led (won) | mean g | g 14:00 | v base: d g (t) b/w | v base: d g14 (t) | median defeat | income 8/12/16 (x enemy) | army 8/12/16 (x enemy) | dry minutes | powder bank 8/12/16 | gold bank 8/12/16 | musket men armed/bayonet 12 | armed/bayonet 16 | made: nitre / bought |")
        print("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for opt in OPTS:
            rows = pool(opt, opp)
            s = summary(rows)
            if not s:
                continue
            p = paired(rows, base) if opt != "base" and base else {}
            pg = "%+.2f (%.1f) %d/%d" % p["g"] if "g" in p else ""
            p14 = "%+.2f (%.1f)" % p["g14"][:2] if "g14" in p else ""
            print("| %s | %d | %d | %d (%d) | %+.2f | %s | %s | %s | %s | %s / %s / %s | %s / %s / %s | %.1f | %s / %s / %s | %s / %s / %s | %s / %s | %s / %s | %s / %s |" % (
                opt, s["n"], s["surv"], s["wl"], s["won"], s["g"], f2(s["g14"]), pg, p14, mmss(s["beat"]),
                f2(s["inc8"]), f2(s["inc12"]), f2(s["inc16"]), f2(s["army8"]), f2(s["army12"]), f2(s["army16"]), s["dry"],
                f2(s["pow8"], 0), f2(s["pow12"], 0), f2(s["pow16"], 0), f2(s["gold8"], 0), f2(s["gold12"], 0), f2(s["gold16"], 0),
                f2(s["arm12"], 0), f2(s["bay12"], 0), f2(s["arm16"], 0), f2(s["bay16"], 0), f2(s["nitre"], 0), f2(s["bought"], 0)))
    print("\n### The Mills (medians, the Crown side): Mills built / hands on them / saltpetre left in all its halls / halls, at 8:00, 12:00, 16:00\n")
    print("| matchup | option | 8:00 | 12:00 | 16:00 |")
    print("|---|---|---|---|---|")
    for opp in OPPS:
        for opt in OPTS:
            s = summary(pool(opt, opp))
            if s:
                print("| %s | %s | %s |" % (opp, opt, " | ".join("%s / %s / %s / %s" % (f2(s["mills%d" % mn], 0), f2(s["hands%d" % mn], 0), f2(s["salt%d" % mn], 0), f2(s["halls%d" % mn], 0)) for mn in (8, 12, 16))))
    if "--games" in sys.argv:
        for opp in OPPS:
            for opt in OPTS:
                for r in pool(opt, opp):
                    print(opp, opt, r["block"], r["tag"], r["res"], mmss(r["end"]), "g %+.2f" % r["g"], "dry", r["dry"],
                          "pow12", r.get("pow12"), "gold12", r.get("gold12"), "nitre", r["nitre"], "bought", r["bought"])


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "run":
        run(sys.argv[2], sys.argv[3], int(sys.argv[4]), int(arg("--jobs", "2")), arg("--root", None))
    elif cmd == "report":
        report()
    else:
        print(__doc__)
