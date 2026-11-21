#!/bin/bash
# (ai-opponent-review) film one study game (tools/film_coach.gd shots:1 under xvfb-run) on its map, seed and sides:
#   ai_opponent_review_film.sh TAG [END] [extra film_coach args, e.g. focus:0730-0830]
# raw out: $FILM_RAW/TAG (default /tmp/claude-0/films); the pictures are picked by hand into docs/shots/ai_opponent_review/.
# A film is a new game (the match is not deterministic): it shows a kind of game, not its study game.
cd "$(dirname "$0")/../.."
tag=$1; end=${2:-900}; shift; shift
read m seed spec < <(python3 -c "
import sys; sys.path.insert(0,'tools/study'); import ai_opponent_review as a
for g in a.queue():
    if g[0]=='$tag': print(g[1], g[2], ','.join('/'.join(str(x) for x in s) for s in g[3]))")
raw=${FILM_RAW:-/tmp/claude-0/films}/$tag
mkdir -p "$raw"
LP_NUM_THREADS=1 nice -n 5 timeout 14400 xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --fixed-fps 30 \
	--path "${FILM_ROOT:-.}" --script res://tools/film_coach.gd -- map:$m seed:$seed end:$end out:$raw slots:$spec shots:1 "$@" \
	> "$raw/run.out" 2>&1
ls "$raw" | wc -l
