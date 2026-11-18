#!/bin/bash
# (winrate-2026-11-17) film one study game with tools/film_coach.gd shots:1 under xvfb-run:
#   winrate_1117_film.sh TAG [END]      TAG = a study tag (base_<map>_<pair>_r<n>): its map, seed and sides; END default 720
# raw out: $FILM_RAW/TAG (default /tmp/claude-0/films); kept: docs/winrate_2026_11_17/films/TAG/ (story.txt, coach.txt,
# result_short.json, maps every 3 minutes, the fights, each army every 2 minutes, the halls at 4:00/8:00; jpg).
cd "$(dirname "$0")/../.."
tag=$1; end=${2:-720}
read m seed spec < <(python3 -c "
import sys; sys.path.insert(0,'tools/study'); import qa_matches as qm
for r in (0,1):
  for g in qm.base(r):
    if g[0]=='$tag': print(g[1], g[2], ','.join('%s/%s/%d'%s for s in g[3]))")
raw=${FILM_RAW:-/tmp/claude-0/films}/$tag
keep=docs/winrate_2026_11_17/films/$tag
mkdir -p "$raw" "$keep"
date +%s > "$raw/start.txt"
LP_NUM_THREADS=1 nice -n 5 timeout 10800 xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --fixed-fps 30 --path . \
	--script res://tools/film_coach.gd -- map:$m seed:$seed end:$end out:$raw slots:$spec shots:1 army_every:120 > "$raw/run.out" 2>&1
date +%s > "$raw/end.txt"
cp "$raw"/story.txt "$raw"/coach.txt "$keep"/ 2>/dev/null
python3 - "$raw" "$keep" <<'P'
import sys, os, json, glob
raw, keep = sys.argv[1], sys.argv[2]
try:
    g = json.load(open(os.path.join(raw, "result.json")))
    short = {k: g[k] for k in ("map", "seed", "slots", "end", "winner", "version", "tech_at", "reads") if k in g}
    short["final"] = [{k: f.get(k) for k in ("income", "army", "halls", "workers", "plan", "supply", "lost")} for f in g["final"]]
    json.dump(short, open(os.path.join(keep, "result_short.json"), "w"), indent=1)
except Exception as e:
    print("no result", e)
from PIL import Image
for p in sorted(glob.glob(os.path.join(raw, "*.png"))):
    n = os.path.basename(p)
    k = False
    if n.startswith("map_"):
        mm = n[4:8]; k = mm.endswith("00") and int(mm[:2]) % 3 == 0 or mm == max(os.path.basename(x)[4:8] for x in glob.glob(os.path.join(raw, "map_*.png")))
    elif n.startswith("fight_") or n.startswith("army_"):
        k = True
    elif n.startswith("base_"):
        k = n.endswith("_0400.png") or n.endswith("_0800.png")
    if k:
        im = Image.open(p).convert("RGB")
        if im.width > 960:
            im = im.resize((960, im.height * 960 // im.width))
        im.save(os.path.join(keep, n[:-4] + ".jpg"), quality=60)
P
du -sh "$keep"
