#!/bin/bash
# THE CLICK SWEEP (docs/qa_click_sweep.md): every clickable thing in the game clicked, what breaks reported.
#   tools/qa/click_sweep.sh            the full sweep: English, Portuguese and Spanish, at 1600x900 as a computer and
#                                      2400x1080 as a phone held sideways (6 runs, 2 at a time; a few hours)
#   tools/qa/click_sweep.sh --quick    one run (English, 1600x900, computer): before a release (~30-45 min)
#   options: --parts matches,menus,veteran   --jobs 2   --out <dir>   --no-shots   --runs "en:pc:1600x900 pt:mobile:2400x1080"
# Needs godot (4.7) on the PATH, xvfb-run and python3. Each run gets its own fresh user folder (XDG_DATA_HOME), so the
# runs never share settings, saves or campaign progress, and the owner's own are never touched.
# Writes <out>/<tag>.json + <tag>.log; then tools/qa/click_sweep_report.py writes docs/qa_click_sweep/report.md and
# copies the pictures to docs/shots/qa_click_sweep/. Exit code 1 if any run found an ERROR (or stopped before its end).
cd "$(dirname "$0")/../.." || exit 1
QUICK=0
PARTS="matches,menus,veteran"
JOBS=2
OUT=${TMPDIR:-/tmp}/triumviwar_click_sweep
SHOTS=1
RUNS=""
while [ $# -gt 0 ]; do
	case "$1" in
		--quick) QUICK=1 ;;
		--parts) PARTS="$2"; shift ;;
		--jobs) JOBS="$2"; shift ;;
		--out) OUT="$2"; shift ;;
		--no-shots) SHOTS=0 ;;
		--runs) RUNS="$2"; shift ;;
		*) echo "unknown option $1"; exit 2 ;;
	esac
	shift
done
if [ -z "$RUNS" ]; then
	if [ $QUICK = 1 ]; then
		RUNS="en:pc:1600x900"
	else
		RUNS="en:pc:1600x900 en:mobile:2400x1080 pt:pc:1600x900 pt:mobile:2400x1080 es:pc:1600x900 es:mobile:2400x1080"
	fi
fi
mkdir -p "$OUT"
one() {
	local lang=${1%%:*} rest=${1#*:}
	local dev=${rest%%:*} size=${rest#*:}
	local w=${size%x*} h=${size#*x}
	local tag="${lang}_${dev}_${size}"
	local shots=flagged
	[ "$lang" = en ] && shots=all
	[ $SHOTS = 0 ] && shots=none
	rm -rf "$OUT/user_$tag"
	mkdir -p "$OUT/user_$tag"
	echo "run $tag ..."
	XDG_DATA_HOME="$OUT/user_$tag" timeout 4h xvfb-run -a -s "-screen 0 ${w}x${h}x24" godot --rendering-driver opengl3 \
		--resolution "${w}x${h}" --script res://tools/qa/click_sweep.gd -- out="$OUT" lang="$lang" device="$dev" \
		parts="$PARTS" shots="$shots" > "$OUT/$tag.log" 2>&1
	grep -h "SWEEP DONE\|WATCHDOG" "$OUT/$tag.log" || echo "$tag: stopped before its end (see $OUT/$tag.log)"
	rm -rf "$OUT/user_$tag"
}
n=0
for r in $RUNS; do
	one "$r" &
	n=$((n + 1))
	if [ $n -ge "$JOBS" ]; then
		wait -n
		n=$((n - 1))
	fi
done
wait
python3 tools/qa/click_sweep_report.py "$OUT" $([ $QUICK = 1 ] && echo --quick)
