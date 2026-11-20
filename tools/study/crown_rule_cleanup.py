#!/usr/bin/env python3
"""CROWN RULE CLEANUP (crown-rule-cleanup, docs/crown_rule_cleanup.md): the Crown computer's coaching rules in GROUPS, a
CLEAN BASE with every group off, then the groups added back one at a time. A measuring tool on top of
tools/study/crown_1000_brood.py (its 10 games: 5 maps x 2 rounds with the start spots swapped, Hard OPTIMAL v Hard OPTIMAL
to 20:00, its score g = ln of the Crown's (income + 2 x army) over the enemy's, a beaten side counted a quarter).
    python3 tools/study/crown_rule_cleanup.py groups
    python3 tools/study/crown_rule_cleanup.py run OPP BLOCK [--on G1,G2] [--full] [--extra a,b] [--jobs 2] [--root COPY]
    python3 tools/study/crown_rule_cleanup.py report OPP [--base B1+B2] BLOCK ...
    python3 tools/study/crown_rule_cleanup.py fired OPP BLOCK ...     (how often each rule acted, result.json crown_ai)
OPP is brood, clockwork or crown (the mirror). `--on` names the groups kept ON; every other group's switches are passed
(off). `--full` = today's whole stack (no switch). Data: docs/crown_rule_cleanup/data/<OPP>/<BLOCK>/."""
import os, sys, json, glob, statistics as st
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qa_matches as qm
import crown_1000_brood as cb

# The groups, in the order they are added back (plan picks, economy, army floor, fighting, home), and the study
# switches that turn each one OFF (every switch already existed before this job; the doc lists what each does).
GROUPS = [
    ("plan", ["optlean:off", "c1kblean:off", "c1kbsiege:off", "cvcpick:off", "mirror:off"]),
    ("econ", ["labsfirst:off", "hallsontime:off", "farmfirst:off", "cvchall2:off", "cvctech3:off", "cbaecon:off"]),
    ("army", ["crownarmy:off", "armyfloor:off", "cba:off", "cvb:off", "screenfirst:off", "cvcdry:off"]),
    ("fight", ["gunscoach:off", "gunsfirst:off", "line:off", "screen:off", "cavmicro:off", "defence:off"]),
    ("home", ["hold:off", "cmc:off"]),
]
GNAMES = [g for g, _ in GROUPS]
ROOT_DATA = os.path.join(qm.ROOT, "docs/crown_rule_cleanup/data")


def switches(on):
    out = []
    for g, sw in GROUPS:
        if g not in on:
            out += sw
    return out


# Against the Clockwork the seeds of crown-1000-clockwork (plan_matrix_crown's), so its kept-set blocks 19 and 22 pair
# game by game with this job's (copied as old_b19, old_b22).
SEEDS_CW = {"c1k_ashford_crossing_r0": 9205, "c1k_ashford_crossing_r1": 9302, "c1k_cinder_steps_r0": 9282,
            "c1k_cinder_steps_r1": 9379, "c1k_frostfang_r0": 9139, "c1k_frostfang_r1": 9236, "c1k_greenhold_r0": 9106,
            "c1k_greenhold_r1": 9203, "c1k_mirewood_r0": 9172, "c1k_mirewood_r1": 9269}


def queue():
    q = cb.queue()
    if cb.OPP == "clockwork":
        q = [(t, m, SEEDS_CW.get(t, s), sl) for t, m, s, sl in q]
    return q


def setup(opp):
    cb.OPP = opp
    cb.DATA = os.path.join(ROOT_DATA, opp)


def fired(rows_dir):
    """Sum of the Crown side's rule counters over a block's games (the Crown side only; both sides in the mirror)."""
    tot, games = {}, 0
    for f in sorted(glob.glob(os.path.join(rows_dir, "c1k_*", "result.json"))):
        g = json.load(open(f))
        ca = g.get("crown_ai", {})
        games += 1
        for tm, d in ca.items():
            flat = {}
            for k, v in d.items():
                if isinstance(v, dict):
                    for k2, v2 in v.items():
                        if isinstance(v2, (int, float)):
                            flat[k + "." + k2] = v2
                elif isinstance(v, (int, float)) and not isinstance(v, bool):
                    flat[k] = v
                elif isinstance(v, list):
                    flat[k + ".n"] = len(v)
            for k, v in flat.items():
                a = tot.setdefault(k, [0.0, 0])
                a[0] += v
                a[1] += 1 if v else 0
    return tot, games


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "groups":
        for g, sw in GROUPS:
            print(g, " ".join(sw))
    elif cmd == "run":
        opp, name = sys.argv[2], sys.argv[3]
        setup(opp)
        on = GNAMES if "--full" in sys.argv else [x for x in arg("--on", "").split(",") if x]
        extra = switches(on) + [x for x in arg("--extra", "").split(",") if x]
        dd = os.path.join(cb.DATA, name)
        os.makedirs(dd, exist_ok=True)
        with open(os.path.join(dd, "extra.txt"), "w") as f:
            f.write(" ".join(extra) + "\n")
        with open(os.path.join(dd, "groups.txt"), "w") as f:
            f.write(" ".join(on) + "\n")
        qm.RUN_ROOT = os.path.abspath(arg("--root", qm.ROOT))
        qm.KEEP_GREP = "Crown's plan"
        out = os.path.abspath(arg("--out", "/tmp/crc_out/%s/%s" % (opp, name)))
        with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
            for t in ex.map(lambda g: qm.run_one(g, out, 1200, dd, extra), queue()):
                print("done", t, flush=True)
    elif cmd == "report":
        opp = sys.argv[2]
        setup(opp)
        base = arg("--base", None)
        names = [x for x in sys.argv[3:] if not x.startswith("--") and x != base]
        brow = cb.block(base) if base else None
        print("| block | groups on | games | mean g | survived | won/led | median defeat | inc 8 | inc 12 | army 8 | army 12 | g14 | v base: d g (t) · d g14 (t) · better/worse |")
        print("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for n in ([base] if base else []) + names:
            s = cb.summary(n, cb.block(n), brow if n != base else None)
            parts = [cb.block(x) for x in n.split("+")]
            allr = [r for pp in parts for r in pp.values()]
            surv = sum(1 for r in allr if r["res"] != "L")
            wl = sum(1 for r in allr if r["res"] in ("W", "w"))
            bt = sorted(r["beaten"] for r in allr if r["beaten"])
            med = st.median(bt) if bt else None
            gp = os.path.join(cb.DATA, n.split("+")[0], "groups.txt")
            gs = open(gp).read().strip() if os.path.exists(gp) else "?"
            dt = ("%+.2f (%.1f) · %+.2f (%.1f) · %d/%d" % (s["d"], s["t"], s.get("d14", 0), s.get("t14", 0), s["better"], s["worse"])) if "d" in s else ""
            print("| %s | %s | %d | %+.2f | %d | %d | %s | %s | %s | %s | %s | %s | %s |" % (
                n, gs or "none", len(allr), s["g"], surv, wl, cb.mmss(med), cb.f2(s["inc8"]),
                cb.f2(s["inc12"]), cb.f2(s["army8"]), cb.f2(s["army12"]), cb.f2(s["g14"]), dt))
    elif cmd == "fired":
        opp = sys.argv[2]
        setup(opp)
        for n in sys.argv[3:]:
            tot, games = fired(os.path.join(cb.DATA, n))
            print("## %s (%d games)" % (n, games))
            for k, (v, c) in sorted(tot.items()):
                print("  %-40s total %10.1f  in %2d sides" % (k, v, c))
    else:
        print(__doc__)
