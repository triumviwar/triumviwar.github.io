#!/bin/bash
# (winrate-2026-11-15) film one study game: winrate_1115_film.sh NAME A B MAP SEED SWAP
#   A, B = the factions of a: and b: (swap:1 puts a: at P2); both Hard OPTIMAL, to 15:00
# out: $FILM_DIR/NAME (default /tmp/claude-0/film): pictures, coach.txt, story.txt, stats.txt, log.txt, result.txt
cd "$(dirname "$0")/../.."
d=${FILM_DIR:-/tmp/claude-0/film}/$1
mkdir -p "$d"
date +%s > "$d/start.txt"
timeout 7200 xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --fixed-fps 30 --path . \
	--script res://tools/shot_ai_match.gd -- a:$2 b:$3 pa:optimal pb:optimal map:$4 seed:$5 swap:$6 out:$d coach:1 every:30 end:900 \
	> "$d/run.out" 2>&1
date +%s > "$d/end.txt"
