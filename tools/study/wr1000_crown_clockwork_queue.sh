#!/bin/sh
# (wr1000-crown-clockwork) runs the blocks of a queue file one after another, each on a light frozen copy of the committed
# HEAD (tools/study/freeze_copy.sh), so the next change can be written while a block runs:
#   tools/study/wr1000_crown_clockwork_queue.sh QUEUE COPY      (a QUEUE line: "BLOCK [switch,switch]"; "-" = no switch)
# A line is taken off the top when its block starts; an empty queue waits; a file QUEUE.STOP ends it.
q=${1:?queue file}; copy=${2:?run copy dir}
here=$(cd "$(dirname "$0")/../.." && pwd)
while [ ! -e "$q.STOP" ]; do
	line=$(head -n 1 "$q" 2>/dev/null)
	if [ -z "$line" ]; then sleep 30; continue; fi
	sed -i '1d' "$q"
	set -- $line
	b=$1; ex=${2:--}
	[ "$ex" = "-" ] && ex=""
	echo "$(date +%H:%M) block $b [$ex] at $(cd "$here" && git rev-parse --short HEAD)"
	bash "$here/tools/study/freeze_copy.sh" "$copy" HEAD
	python3 "$here/tools/study/wr1000_crown_clockwork.py" run "$b" --extra "$ex" --root "$copy"
	echo "$(date +%H:%M) block $b done"
done
