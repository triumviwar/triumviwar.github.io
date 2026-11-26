#!/bin/bash
# (crown-micro-2, docs/crown_micro_2.md) run bench arms two at a time: each line of the queue file is
#   NAME SET RUNS [switches...]
# and writes docs/crown_micro_2/bench/NAME.json (an arm already there is skipped).
#   tools/study/crown_micro_2_arms.sh queue.txt [jobs]
cd "$(dirname "$0")/../.."
Q="$1"; J="${2:-2}"
one() {
	set -- $1
	n=$1; st=$2; runs=$3; shift 3
	out="$PWD/docs/crown_micro_2/bench/$n.json"
	[ -f "$out" ] && { echo "had $n"; return; }
	timeout 7200 godot --headless --fixed-fps 30 --path . --script res://tools/bench_crown_micro.gd -- set:$st runs:$runs \
		out:$out "$@" 2>&1 | grep -E "^ALL" | sed "s/^/$n /"
}
export -f one
grep -v '^#' "$Q" | grep -v '^$' | xargs -d '\n' -P "$J" -I{} bash -c 'one "$@"' _ {}
