#!/bin/bash
# CROWN DEFENCE BENCH batch (crown-coach-defence): runs tools/crown_defence_bench.gd over a list of games, JOBS at a time.
#   GODOT=/path/godot tools/crown_defence_bench.sh OUTDIR "SWITCHES" < games.list
# games.list: one game a line: map seed foe crown_side end   (e.g. "hollowfen 4287366311 clockwork 0 720")
# SWITCHES: extra user args for every game (e.g. "defence:off"). Each game writes OUTDIR/<map>_<seed>_<side>/bench.json.
OUT=$1
SW=$2
JOBS=${JOBS:-2}
mkdir -p "$OUT"
run() {
	local map=$1 seed=$2 foe=$3 side=$4 end=$5
	local d="$OUT/${map}_${seed}_${side}"
	mkdir -p "$d"
	timeout 3000 "$GODOT" --headless --fixed-fps 30 --script res://tools/crown_defence_bench.gd -- map:$map seed:$seed foe:$foe \
		crown:$side end:$end out:$d $SW 2>&1 | grep -a -E "^BENCH|SCRIPT ERROR|Invalid" | head -20 > "$d/out.txt"
	echo "$map $seed $side: $(cat $d/out.txt | head -3)"
}
export -f run
export OUT SW GODOT
xargs -P "$JOBS" -L 1 bash -c 'run "$@"' _
