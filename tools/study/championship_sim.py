#!/usr/bin/env python3
"""THE CHAMPIONSHIP SIMULATION (job tournament, docs/championship_sim.md; the owner 2026-11-24: "make a championship
simulation so we see"). The in-game tournament tool's ALL-COMPUTER mode, run by a script: the bracket is the game's own
Tournament (tools/tournament_cli.gd keeps it, makes the computers' map bans and picks, takes the results, applies the
time limit's lead rule); every game is a real headless match (tools/qa_match.gd) to 20:00.
    python3 tools/study/championship_sim.py run RUN [--seed N] [--jobs 2] [--end 1200]
    python3 tools/study/championship_sim.py show RUN
Data: docs/championship_sim/data/<RUN>/ (tournament.json, cfg.json, games/<mid>_<gi>_<k>/result.json + story.txt)."""
import os, sys, json, subprocess, shutil, time, threading, argparse
from concurrent.futures import ThreadPoolExecutor, wait, FIRST_COMPLETED

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA = os.environ.get("CHAMP_DATA", os.path.join(ROOT, "docs/championship_sim/data"))
GODOT = os.environ.get("GODOT", "/home/claude/godot/godot")
TMP = os.environ.get("CHAMP_TMP", "/tmp/claude-0/champ")
TIMEOUT = 3600
MAPS = ["greenhold", "dune_sea", "frostfang", "ashford_crossing", "hollowfen", "cinder_steps"]

# THE FIELD (16 entrants; docs/championship_sim.md "The field"): every faction's OPTIMAL (its best computer), Balanced
# (the default), Economy and a rush, plus each faction's own signature build; the Clockwork, with the most builds (10),
# brings a second one. All at Hard.
FIELD = [
    ("crown", "optimal"), ("crown", "balanced"), ("crown", "economy"), ("crown", "timing"), ("crown", "siege"),
    ("clockwork", "optimal"), ("clockwork", "balanced"), ("clockwork", "economy"), ("clockwork", "rush"),
    ("clockwork", "owls"), ("clockwork", "heavy"),
    ("brood", "optimal"), ("brood", "balanced"), ("brood", "economy"), ("brood", "rush"), ("brood", "spitter"),
]
PLAN_NAME = {"optimal": "Optimal", "balanced": "Balanced", "economy": "Economy", "timing": "Timing", "siege": "Siege",
             "rush": "Rush", "owls": "Owls", "heavy": "Heavy", "spitter": "Spitter"}
FAC_NAME = {"crown": "Crown", "clockwork": "Clockwork", "brood": "Brood"}

lock = threading.Lock()


def cli(run_dir, *args):
    cmd = [GODOT, "--headless", "--path", ROOT, "--script", "res://tools/tournament_cli.gd", "--",
           "file:" + os.path.join(run_dir, "tournament.json")] + list(args)
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=300)
    out = p.stdout.decode(errors="replace")
    lines = [l for l in out.splitlines() if l.startswith(("GAME ", "DONE", "OK", "TAKEN", "AGAIN", "STALE", "ERROR", "CHAMPION", "  ", " "))]
    if any(l.startswith("ERROR") for l in lines) or "SCRIPT ERROR" in out:
        print(out[-3000:])
        raise SystemExit("tournament_cli failed")
    return out


def play(run_dir, g, end):
    tag = "%d_%d_%d" % (g["mid"], g["gi"], g["replays"])
    dd = os.path.join(run_dir, "games", tag)
    if os.path.exists(os.path.join(dd, "result.json")):
        return g, json.load(open(os.path.join(dd, "result.json")))
    tmp = os.path.join(TMP, os.path.basename(run_dir), tag)
    shutil.rmtree(tmp, ignore_errors=True)
    os.makedirs(tmp, exist_ok=True)
    spec = ",".join("%s/%s/%d" % (s[0], s[1], i) for i, s in enumerate(g["slots"]))
    cmd = ["timeout", str(TIMEOUT), GODOT, "--headless", "--fixed-fps", "30", "--path", ROOT, "--script",
           "res://tools/qa_match.gd", "--", "map:" + g["map"], "seed:%d" % (g["seed"] % 100000 + 1), "end:%d" % end,
           "out:" + tmp, "slots:" + spec, "diff:hard"]
    t0 = time.time()
    with open(os.path.join(tmp, "run.out"), "wb") as f:
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        n = 0
        for chunk in iter(lambda: p.stdout.read(65536), b""):
            if n < 5_000_000:
                f.write(chunk)
            n += len(chunk)
        p.wait()
    os.makedirs(dd, exist_ok=True)
    res = None
    if os.path.exists(os.path.join(tmp, "result.json")):
        for fn in ("result.json", "story.txt"):
            if os.path.exists(os.path.join(tmp, fn)):
                shutil.copy(os.path.join(tmp, fn), dd)
        res = json.load(open(os.path.join(dd, "result.json")))
    else:
        shutil.copy(os.path.join(tmp, "run.out"), os.path.join(dd, "FAILED.txt"))
    with open(os.path.join(dd, "game.json"), "w") as f:
        json.dump(dict(g, wall=round(time.time() - t0)), f)
    shutil.rmtree(tmp, ignore_errors=True)
    return g, res


def scores(res):
    if not res:
        return 0, 0
    fin = res.get("final") or []
    sc = [x.get("income", 0) + 2 * x.get("army", 0) for x in fin]
    while len(sc) < 2:
        sc.append(0)
    return sc[0], sc[1]


def report(run_dir, g, res, end):
    if res is None:
        w, s0, s1, ln = -1, 0, 0, 0
    else:
        w = int(res.get("winner", -1))
        ln = int(res.get("end", end))
        if ln > end:
            w, ln = -1, end
        s0, s1 = scores(res)
    with lock:
        out = cli(run_dir, "cmd:result", "mid:%d" % g["mid"], "gi:%d" % g["gi"], "winner:%d" % w, "s0:%d" % s0, "s1:%d" % s1,
                  "len:%d" % ln, "map:" + g["map"], "swap:%d" % (1 if g["swap"] else 0), "seed:%d" % g["seed"],
                  "replay:%d_%d_%d" % (g["mid"], g["gi"], g["replays"]))
    word = [l for l in out.splitlines() if l.startswith(("TAKEN", "AGAIN", "STALE"))]
    print("[%s] %s %s v %s on %s: winner slot %d, %s" % (time.strftime("%H:%M:%S"), g["label"], g["a"], g["b"], g["map"], w,
                                                        word[0] if word else "?"), flush=True)


def next_games(run_dir):
    with lock:
        out = cli(run_dir, "cmd:next")
    if any(l.startswith("DONE") for l in out.splitlines()):
        return None
    return [json.loads(l[5:]) for l in out.splitlines() if l.startswith("GAME ")]


def run(name, seed, jobs, end):
    run_dir = os.path.join(DATA, name)
    os.makedirs(os.path.join(run_dir, "games"), exist_ok=True)
    if not os.path.exists(os.path.join(run_dir, "tournament.json")):
        players = [{"name": "%s %s" % (FAC_NAME[f], PLAN_NAME[p]), "faction": f, "who": "hard", "plan": p} for f, p in FIELD]
        cfg = {"name": "Championship %s" % name, "format": "double", "bo": 3, "bo_final": 3, "maps": MAPS,
               "map_rule": "veto", "loser_picks": True, "factions": "event", "seeding": "random", "seed": seed,
               "time_limit": end, "players": players}
        json.dump(cfg, open(os.path.join(run_dir, "cfg.json"), "w"), indent=1)
        cli(run_dir, "cmd:new", "cfg:" + os.path.join(run_dir, "cfg.json"))
    running = {}
    with ThreadPoolExecutor(max_workers=jobs) as ex:
        while True:
            games = next_games(run_dir)
            if games is None and not running:
                break
            for g in games or []:
                key = (g["mid"], g["gi"], g["replays"])
                if key not in running and len(running) < jobs:
                    running[key] = ex.submit(play, run_dir, g, end)
            if not running:
                if games is None:
                    break
                time.sleep(1)
                continue
            done, _ = wait(list(running.values()), return_when=FIRST_COMPLETED)
            for k in [k for k, f in running.items() if f in done]:
                g, res = running.pop(k).result()
                report(run_dir, g, res, end)
    print(cli(run_dir, "cmd:show"))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd")
    ap.add_argument("name")
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--jobs", type=int, default=2)
    ap.add_argument("--end", type=int, default=1200)
    a = ap.parse_args()
    if a.cmd == "run":
        run(a.name, a.seed, a.jobs, a.end)
    elif a.cmd == "show":
        print(cli(os.path.join(DATA, a.name), "cmd:show"))
