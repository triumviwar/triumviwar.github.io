#!/usr/bin/env python3
"""KEEN SABRES IN COMPUTER GAMES (keen-sabres-test, docs/keen_sabres_test.md): Hard Crown OPTIMAL v Hard Brood OPTIMAL
(tools/qa_match.gd, 15:00) with Keen Sabres researchable ("on") and with it removed by the study switch keensabres:off
("off"). A measuring tool: it changes no rule. cavalry-charge-package (docs/cavalry_charge_package.md) reran it with
the arm "package" (Keen Sabres gone, the Charge at the Horse Breeder x2.2 on light, the riders' swarm rule, Officer 100;
no switch) and "swarmoff" (the same with `cavswarm:off`); --arms picks them (the old "off" switch is gone with Keen
Sabres: on today's build "on" and "off" run the package too).
    python3 tools/study/keen_sabres_games.py run OUT [--jobs 2] [--godot PATH] [--maps a,b] [--seeds 2] [--arms package]
    python3 tools/study/keen_sabres_games.py report OUT
Each game: OUT/<arm>_<map>_s<k>/result.json (k odd = the sides swapped)."""
import json, os, sys, glob, subprocess, argparse
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MAPS = ["greenhold", "mirewood", "hollowfen", "dune_sea"]


ARM_ARGS = {"on": [], "off": ["keensabres:off"], "package": [], "swarmoff": ["cavswarm:off"]}


def games(maps, seeds, arms=("on", "off")):
    out = []
    for arm in arms:
        for i, m in enumerate(maps):
            for k in range(seeds):
                slots = "crown/optimal/0,brood/optimal/1" if k % 2 == 0 else "brood/optimal/0,crown/optimal/1"
                out.append(("%s_%s_s%d" % (arm, m, k), arm, m, 5100 + 10 * i + k, slots))
    return out


def run(a):
    q = games(a.maps.split(","), a.seeds, a.arms.split(","))

    def one(gm):
        tag, arm, m, sd, slots = gm
        d = os.path.join(os.path.abspath(a.out), tag)
        if os.path.exists(os.path.join(d, "result.json")):
            return
        os.makedirs(d, exist_ok=True)
        cmd = [a.godot, "--headless", "--fixed-fps", "30", "--path", ROOT, "--script", "res://tools/qa_match.gd", "--",
               "map:" + m, "seed:%d" % sd, "end:900", "out:" + d, "slots:" + slots, "diff:hard"]
        cmd += ARM_ARGS.get(arm, [])
        with open(os.path.join(d, "run.log"), "w") as lf:
            subprocess.run(cmd, stdout=lf, stderr=subprocess.STDOUT, timeout=5400)
        print("done", tag, flush=True)

    with ThreadPoolExecutor(a.jobs) as ex:
        list(ex.map(one, q))


def leader(d, crown, brood):
    """A draw's leader as in docs/winrate_2026_11_12.md: income earned + 2 x army, 10% ahead."""
    fin = d.get("final") or []
    def score(p):
        for x in fin:
            if x.get("p") == p:
                return float(x.get("income", 0)) + 2.0 * float(x.get("army", 0))
        return 0.0
    c, b = score(crown), score(brood)
    if c > b * 1.1:
        return "crown"
    if b > c * 1.1:
        return "brood"
    return "even"


def report(a):
    rows = {}
    for f in sorted(glob.glob(os.path.join(a.out, "*", "result.json"))):
        tag = os.path.basename(os.path.dirname(f))
        arm = tag.split("_")[0]
        rows.setdefault(arm, [])
        d = json.load(open(f))
        crown = [i for i, s in enumerate(d["slots"]) if s[0] == "crown"][0]
        brood = 1 - crown
        res = "D"
        if d["over"] and d["winner"] == crown:
            res = "W"
        elif d["over"] and d["winner"] == brood:
            res = "L"
        rid = cid = 0
        rap_by_riders = work_by_riders = 0
        raptors_lost = riders_lost = 0
        for t, kind, team, by, by_team in d.get("deaths", []):
            if kind == "cuirassier" and team == crown:
                riders_lost += 1
            if kind == "raptor" and team == brood:
                raptors_lost += 1
            if by == "cuirassier" and by_team == crown and team == brood:
                rid += 1
                if kind == "raptor":
                    rap_by_riders += 1
                if kind == "grub":
                    work_by_riders += 1
        ta = d.get("tech_at", {})
        keen = ta.get("%d:keen_sabres" % crown)
        charge = ta.get("%d:charge" % crown)
        rows[arm].append({"tag": tag, "res": res, "lead": leader(d, crown, brood) if res == "D" else "", "end": d["end"],
                          "riders": d.get("riders_seen", [0, 0])[crown], "riders_lost": riders_lost, "kills": rid,
                          "raptors": rap_by_riders, "grubs": work_by_riders, "keen": keen, "charge": charge})
    print("| arm | game | Crown result | leader (draw) | length | riders made | riders lost | kills by riders | Raptors | grubs | Keen Sabres at | Charge at |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for arm in rows:
        for r in rows[arm]:
            mmss = lambda s: "" if s is None else "%d:%02d" % (int(s) // 60, int(s) % 60)
            print("| %s | %s | %s | %s | %s | %d | %d | %d | %d | %d | %s | %s |" % (arm, r["tag"][len(arm) + 1:], r["res"], r["lead"],
                  mmss(r["end"]), r["riders"], r["riders_lost"], r["kills"], r["raptors"], r["grubs"], mmss(r["keen"]), mmss(r["charge"])))
    print()
    print("| arm | games | Crown W-D-L | won or led Crown/Brood/even | riders made | riders lost | kills by riders | of them Raptors | grubs |")
    print("|---|---|---|---|---|---|---|---|---|")
    for arm in rows:
        rs = rows[arm]
        if not rs:
            continue
        w = sum(r["res"] == "W" for r in rs)
        dr = sum(r["res"] == "D" for r in rs)
        l = sum(r["res"] == "L" for r in rs)
        cw = w + sum(r["lead"] == "crown" for r in rs)
        bw = l + sum(r["lead"] == "brood" for r in rs)
        ev = sum(r["lead"] == "even" for r in rs)
        s = lambda k: sum(r[k] for r in rs)
        print("| %s | %d | %d-%d-%d | %d/%d/%d | %d | %d | %d | %d | %d |" % (arm, len(rs), w, dr, l, cw, bw, ev, s("riders"),
              s("riders_lost"), s("kills"), s("raptors"), s("grubs")))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd")
    ap.add_argument("out")
    ap.add_argument("--jobs", type=int, default=2)
    ap.add_argument("--godot", default=os.environ.get("GODOT", "godot"))
    ap.add_argument("--maps", default=",".join(MAPS))
    ap.add_argument("--seeds", type=int, default=2)
    ap.add_argument("--arms", default="on,off")
    a = ap.parse_args()
    run(a) if a.cmd == "run" else report(a)
