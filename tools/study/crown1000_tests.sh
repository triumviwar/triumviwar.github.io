#!/bin/sh
# (crown-1000-clockwork) runs the AI tests (tools/test_ai_*.gd, tools/test_crown_*.gd) two at a time and lists each
# PASS / FAIL (exit code; the FAIL lines kept):  tools/study/crown1000_tests.sh OUTDIR [ROOT]
out=${1:?out dir}; root=${2:-$(cd "$(dirname "$0")/../.." && pwd)}
mkdir -p "$out"
ls "$root"/tools/test_ai_*.gd "$root"/tools/test_crown_*.gd | xargs -n1 basename | \
	xargs -P 2 -I{} sh -c 'timeout 2400 godot --headless --fixed-fps 30 --path "$1" --script res://tools/{} > "$2/{}.out" 2>&1; echo "$? {}" >> "$2/rc.txt"' _ "$root" "$out"
sort -k2 "$out/rc.txt" | awk '{print ($1==0 ? "PASS" : "FAIL (" $1 ")"), $2}'
