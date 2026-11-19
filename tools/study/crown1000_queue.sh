#!/bin/sh
# (crown-1000-clockwork) runs the blocks of a queue file one after another, each on a fresh run copy of the working tree:
#   tools/study/crown1000_queue.sh QUEUE COPY      (a QUEUE line: "BLOCK [switch,switch] [--vs brood]"; "-" = no switch)
# A line is taken off the top when its block starts; an empty queue waits; a file STOP next to QUEUE ends it.
q=${1:?queue file}; copy=${2:?run copy dir}
here=$(cd "$(dirname "$0")/../.." && pwd)
while [ ! -e "$q.STOP" ]; do
	line=$(head -n 1 "$q" 2>/dev/null)
	if [ -z "$line" ]; then sleep 30; continue; fi
	sed -i '1d' "$q"
	set -- $line
	b=$1; ex=${2:--}; shift 2 2>/dev/null || shift $#
	[ "$ex" = "-" ] && ex=""
	echo "$(date +%H:%M) block $b [$ex] $*"
	if ! sh "$here/tools/study/crown1000_sync.sh" "$copy"; then echo "sync failed: $b put back"; sed -i "1i $line" "$q"; sleep 120; continue; fi
	python3 "$here/tools/study/crown1000.py" run "$b" --extra "$ex" --root "$copy" "$@"
	echo "$(date +%H:%M) block $b done"
done
