#!/usr/bin/env python3
"""THE CROWN'S ARMY AND ITS TIMING (crown-coach-army, docs/crown-coach-army.md): Hard Crown OPTIMAL against Hard Clockwork
and Brood OPTIMAL, measured with tools/measure_crown_army.gd (qa_match.gd plus the Crown's production every second).
A measuring tool: it changes no rule.
    python3 tools/study/crown_army.py run OUT [--jobs 2] [--end 600] [--args crownarmy:off] [--maps a,b] [--seeds 1,2] [--vs clockwork,brood]
    python3 tools/study/crown_army.py report OUT [OUT2]"""
import json, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
GODOT = os.environ.get("GODOT", "/home/claude/godot/godot")
MAPS = ["greenhold", "dune_sea", "hollowfen", "kestrel_rise", "ashford_crossing", "red_coast", "frostmere", "border_march"]


def games(maps, seeds, vs):
    out = []
    for foe in vs:
        for m in maps:
            for s in seeds:
                side = s % 2          # the Crown in slot A on odd seeds, B on even ones
                slots = "crown/optimal/0,%s/optimal/1" % foe if side else "%s/optimal/0,crown/optimal/1" % foe
                out.append(("%s_%s_%d" % (foe, m, s), m, s, slots))
    return out


def run_one(g, out, end, extra):
    tag, m, s, slots = g
    d = os.path.join(out, tag)
    if os.path.exists(os.path.join(d, "army.json")):
        return tag + " (had)"
    os.makedirs(d, exist_ok=True)
    cmd = ["timeout", "2400", GODOT, "--headless", "--fixed-fps", "30", "--path", ROOT, "--script",
           "res://tools/measure_crown_army.gd", "--", "map:" + m, "seed:%d" % s, "end:%d" % end, "out:" + d,
           "slots:" + slots] + extra
    with open(os.path.join(d, "run.out"), "wb") as f:
        subprocess.call(cmd, stdout=f, stderr=subprocess.STDOUT)
    return tag


def crown_team(res):
    for i, s in enumerate(res["slots"]):
        if s[0] == "crown":
            return i
    return -1


def at(track, t):
    v = 0
    for tt, val in track:
        if tt <= t:
            v = val
    return v


def summary(out):
    rows = []
    for tag in sorted(os.listdir(out)):
        d = os.path.join(out, tag)
        if not os.path.exists(os.path.join(d, "army.json")):
            continue
        res = json.load(open(os.path.join(d, "result.json")))
        arm = json.load(open(os.path.join(d, "army.json")))
        ct = crown_team(res)
        ft = 1 - ct
        tr = {int(k): v for k, v in arm["army"].items()}
        pr = arm["prod"].get(str(ct), {})
        arrival = next((e for e in res["events"] if e.get("ev") == "first_arrival" and e.get("p") == ct), None)
        r = {"tag": tag, "foe": res["slots"][ft][0], "winner": ("crown" if res["winner"] == ct else ("foe" if res["winner"] == ft else "-")),
             "end": res["end"]}
        for t in (240, 300, 360, 420, 480, 600):
            r["c%d" % t] = at(tr.get(ct, []), t)
            r["f%d" % t] = at(tr.get(ft, []), t)
        for k in ("brk_idle", "sup_block", "pw_wait"):
            v = pr.get(k, [])
            r[k + "_0_6"] = sum(v[:6])
        r["arrive_t"] = arrival["t"] if arrival else -1
        r["arrive_v"] = arrival["value"] if arrival else 0
        r["arrive_own"] = arrival["own_army"] if arrival else 0
        fin = res["final"]
        r["lost_c"] = fin[ct].get("lost", 0)
        r["lost_f"] = fin[ft].get("lost", 0)
        rows.append(r)
    return rows


def report(outs):
    for out in outs:
        rows = summary(out)
        print("==", out, len(rows), "games")
        for foe in ("clockwork", "brood"):
            rs = [r for r in rows if r["foe"] == foe]
            if not rs:
                continue
            w = sum(r["winner"] == "crown" for r in rs)
            l = sum(r["winner"] == "foe" for r in rs)
            print("v %s: W-D-L %d-%d-%d" % (foe, w, len(rs) - w - l, l))
            avg = lambda k: sum(r[k] for r in rs) / len(rs)
            print("  army at  " + "  ".join("%d:%02d %4d v %4d" % (t // 60, t % 60, avg("c%d" % t), avg("f%d" % t)) for t in (240, 300, 360, 420, 480, 600)))
            arr = [r for r in rs if r["arrive_t"] >= 0]
            if arr:
                print("  first enemy arrival (300+ value at our base): %d of %d games, mean %d s, value %d v our %d" % (
                    len(arr), len(rs), sum(r["arrive_t"] for r in arr) / len(arr), sum(r["arrive_v"] for r in arr) / len(arr),
                    sum(r["arrive_own"] for r in arr) / len(arr)))
            print("  0:00-6:00: Barracks idle %.0f s, supply-blocked %.0f s, waiting for powder %.0f s; units lost %.1f v %.1f" % (
                avg("brk_idle_0_6"), avg("sup_block_0_6"), avg("pw_wait_0_6"), avg("lost_c"), avg("lost_f")))
        for r in rows:
            print("   %-28s %-6s c/f 5:00 %4d/%4d 6:00 %4d/%4d 8:00 %4d/%4d idle %3d sup %3d pw %3d arr %4d" % (
                r["tag"], r["winner"], r["c300"], r["f300"], r["c360"], r["f360"], r["c480"], r["f480"],
                r["brk_idle_0_6"], r["sup_block_0_6"], r["pw_wait_0_6"], r["arrive_t"]))


if __name__ == "__main__":
    arg = lambda k, d: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    if sys.argv[1] == "report":
        report([a for a in sys.argv[2:] if not a.startswith("--")])
        sys.exit(0)
    out = os.path.abspath(sys.argv[2])
    gl = games(arg("--maps", ",".join(MAPS)).split(","), [int(x) for x in arg("--seeds", "1,2").split(",")],
               arg("--vs", "clockwork,brood").split(","))
    extra = [a for a in arg("--args", "").split(",") if a]
    end = int(arg("--end", "600"))
    print("%d games" % len(gl), flush=True)
    with ThreadPoolExecutor(int(arg("--jobs", "2"))) as ex:
        for t in ex.map(lambda g: run_one(g, out, end, extra), gl):
            print("done", t, flush=True)
