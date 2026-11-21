#!/usr/bin/env python3
"""THE MILLS' FULL CREW (crown-mill-crew, docs/crown_mill_crew.md): the Crown computer's rule AICrownMillCrew
(scripts/ai_crown_mill_crew.gd) ON (the default) against OFF (`-- millcrew:off`), in computer games: Crown Hard OPTIMAL v
the Brood, v the Clockwork and the Crown mirror (both Crowns play the arm), the SAME 10 games as the crown-1000 and powder
jobs (5 maps x 2 rounds, start spots swapped, their seeds), to 20:00; blocks of the same 10 pooled.
    python3 tools/study/crown_mill_crew.py run ARM OPP BLOCK [--jobs 2] [--extra a:b,c:d]    ARM: on | off   OPP: brood | clockwork | crown
    python3 tools/study/crown_mill_crew.py report [--games]
Data: docs/crown_mill_crew/data/<ARM>/<OPP>_b<BLOCK>/<tag>/ (result.json, story.txt, planlog.txt).
The measures and the score are the powder study's (tools/study/crown_powder_study.py): g = ln of (income + 2 x army)
Crown over the enemy's at 20:00 or the defeat; "v off" the paired difference game by game, its t, better/worse."""
import os, sys, json, glob, math, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm
import crown_1000_brood as cb
import crown_powder_study as cps

DATA = os.path.join(qm.ROOT, "docs/crown_mill_crew/data")
ARMS = ["off", "on"]
OPPS = ["brood", "clockwork", "crown"]
NAMES = {"brood": "the Brood", "clockwork": "the Clockwork", "crown": "the Crown (mirror)"}


def run(arm, opp, blk, jobs=2, extra_args=None):
    cb.OPP = opp
    dd = os.path.join(DATA, arm, "%s_b%d" % (opp, blk))
    os.makedirs(dd, exist_ok=True)
    extra = (["millcrew:off"] if arm == "off" else []) + (extra_args or [])
    with open(os.path.join(dd, "extra.txt"), "w") as f:
        f.write(" ".join(extra) + "\n")
    qm.RUN_ROOT = os.path.abspath(qm.ROOT)
    qm.KEEP_GREP = "Crown's plan"
    out = "/tmp/cmc_out/%s_%s_b%d" % (arm, opp, blk)
    with ThreadPoolExecutor(jobs) as ex:
        for t in ex.map(lambda g: qm.run_one(g, out, 1200, dd, extra), cb.queue()):
            print("done", arm, opp, blk, t, flush=True)


def game(d, opp):
    x = cps.game(d, opp)
    if x is None:
        return None
    g = json.load(open(os.path.join(d, "result.json")))
    ca = (g.get("crown_ai") or {}).get(str(x["si"])) or {}
    mc = ca.get("millcrew") or {}
    x["mc_on"] = mc.get("on_s", 0)
    x["mc_moved"] = mc.get("moved", 0)
    x["mc_times"] = mc.get("times", 0)
    return x


def pool(arm, opp):
    rows = []
    for d in sorted(glob.glob(os.path.join(DATA, arm, opp + "_b*", "c1k_*"))):
        x = game(d, opp)
        if x:
            x["block"] = os.path.basename(os.path.dirname(d))
            rows.append(x)
    return rows


def paired_key(rows, base, key):
    def by_tag(rs):
        d = {}
        for r in rs:
            if r.get(key) is not None:
                d.setdefault(r["tag"], []).append(r[key])
        return {t: sum(v) / len(v) for t, v in d.items()}
    a, b = by_tag(rows), by_tag(base)
    ds = [a[t] - b[t] for t in a if t in b]
    if len(ds) < 2:
        return None
    md = sum(ds) / len(ds)
    sd = st.stdev(ds)
    return md, (md / (sd / math.sqrt(len(ds))) if sd > 0 else 0.0), sum(1 for v in ds if v > 0), sum(1 for v in ds if v < 0), len(ds)


def report():
    f2, mmss, mean, med = cps.f2, cps.mmss, cps.mean, cps.med
    for opp in OPPS:
        base = pool("off", opp)
        print("\n### Crown v %s\n" % NAMES[opp])
        print("| arm | games | survived | won or led (won) | mean g | g 14:00 | v off: d g (t) better/worse | v off: d g14 (t) | median defeat | income 8/12/16 (x enemy) | army 8/12/16 (x enemy) | dry minutes | powder bank 8/12/16 | gold bank 8/12/16 | musket men armed/no shot 12 | armed/no shot 16 |")
        print("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for arm in ARMS:
            rows = pool(arm, opp)
            s = cps.summary(rows)
            if not s:
                continue
            p = cps.paired(rows, base) if arm != "off" and base else {}
            pg = "%+.2f (%.1f) %d/%d" % p["g"] if "g" in p else ""
            p14 = "%+.2f (%.1f)" % p["g14"][:2] if "g14" in p else ""
            print("| %s | %d | %d | %d (%d) | %+.2f | %s | %s | %s | %s | %s / %s / %s | %s / %s / %s | %.1f | %s / %s / %s | %s / %s / %s | %s / %s | %s / %s |" % (
                arm, s["n"], s["surv"], s["wl"], s["won"], s["g"], f2(s["g14"]), pg, p14, mmss(s["beat"]),
                f2(s["inc8"]), f2(s["inc12"]), f2(s["inc16"]), f2(s["army8"]), f2(s["army12"]), f2(s["army16"]), s["dry"],
                f2(s["pow8"], 0), f2(s["pow12"], 0), f2(s["pow16"], 0), f2(s["gold8"], 0), f2(s["gold12"], 0), f2(s["gold16"], 0),
                f2(s["arm12"], 0), f2(s["bay12"], 0), f2(s["arm16"], 0), f2(s["bay16"], 0)))
    print("\n### The Mills (medians, the Crown side): Mills built / hands on them / saltpetre left in all its halls / halls, at 8:00, 12:00, 16:00; the rule: minutes on, hands it sent (means)\n")
    print("| matchup | arm | 8:00 | 12:00 | 16:00 | rule on (min) | hands sent |")
    print("|---|---|---|---|---|---|---|")
    for opp in OPPS:
        for arm in ARMS:
            rows = pool(arm, opp)
            s = cps.summary(rows)
            if s:
                print("| %s | %s | %s | %.1f | %.0f |" % (opp, arm, " | ".join("%s / %s / %s / %s" % (f2(s["mills%d" % mn], 0), f2(s["hands%d" % mn], 0), f2(s["salt%d" % mn], 0), f2(s["halls%d" % mn], 0)) for mn in (8, 12, 16)),
                                                     mean([r["mc_on"] for r in rows]) / 60.0, mean([r["mc_moved"] for r in rows])))
    print("\n### Paired, on minus off, game by game (mean difference (t) better/worse of n)\n")
    print("| matchup | g | g 14:00 | income at 12:00 | income at 16:00 | army at 12:00 | army at 16:00 | powder bank 12 | hands on Mills 12 | hands on Mills 16 | saltpetre left 16 | musket men with no shot 12 | no shot 16 |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    for opp in OPPS:
        on, off = pool("on", opp), pool("off", opp)
        cells = []
        for k in ("g", "g14", "inc12_v", "inc16_v", "army12_v", "army16_v", "pow12", "hands12", "hands16", "salt16", "bay12", "bay16"):
            p = paired_key(on, off, k)
            cells.append("" if p is None else ("%+.2f (%.1f) %d/%d of %d" % p if k in ("g", "g14") else "%+.0f (%.1f) %d/%d of %d" % p))
        print("| %s | %s |" % (opp, " | ".join(cells)))
    print("\n### The mirror: how far apart the two Crowns end (both play the arm)\n")
    print("| arm | games | decided by 20:00 | mean abs(g) | 1.5x apart at 16:00 | median minute decided |")
    print("|---|---|---|---|---|---|")
    for arm in ARMS:
        rows = pool(arm, "crown")
        if not rows:
            continue
        dec = [r for r in rows if r["res"] in ("W", "L")]
        apart = sum(1 for r in rows if r.get("g16") is not None and abs(r["g16"]) > math.log(1.5))
        print("| %s | %d | %d | %.2f | %d | %s |" % (arm, len(rows), len(dec), mean([abs(r["g"]) for r in rows]), apart, mmss(med([r["end"] for r in dec]))))
    if "--games" in sys.argv:
        for opp in OPPS:
            for arm in ARMS:
                for r in pool(arm, opp):
                    print(opp, arm, r["block"], r["tag"], r["res"], mmss(r["end"]), "g %+.2f" % r["g"], "on %ds" % r["mc_on"], "sent", r["mc_moved"],
                          "hands12", r.get("hands12"), "hands16", r.get("hands16"), "pow12", r.get("pow12"), "dry12", r.get("bay12"), "gold12", r.get("gold12"))


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "run":
        ex = arg("--extra", "")
        run(sys.argv[2], sys.argv[3], int(sys.argv[4]), int(arg("--jobs", "2")), [e for e in ex.split(",") if e])
    elif cmd == "report":
        report()
    else:
        print(__doc__)
