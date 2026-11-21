#!/bin/bash
# Run a playtest driver with a window (xvfb) and keep its console; list Godot's errors at the end.
#   tools/playtest/run_clock.sh <driver> <WxH> [key=value ...]
#   e.g. tools/playtest/run_clock.sh clock_hubs 1280x720 device=pc lang=en tag=pc_en
# The console goes to /tmp/pt_<driver>_<tag>.log; the "PT ERRORS" lines at the end are every SCRIPT ERROR / ERROR /
# WARNING Godot printed (each a finding).
set -u
drv="$1"; res="$2"; shift 2
tag="run"
for a in "$@"; do case "$a" in tag=*) tag="${a#tag=}";; esac; done
log="/tmp/pt_${drv}_${tag}.log"
cd "$(dirname "$0")/../.."
w="${res%x*}"; h="${res#*x}"
timeout "${PT_TIMEOUT:-3000}" xvfb-run -a -s "-screen 0 ${w}x${h}x24" godot --rendering-driver opengl3 --audio-driver Dummy \
	--resolution "$res" --script "res://tools/playtest/${drv}.gd" -- "$@" > "$log" 2>&1
echo "exit $? (log $log)"
grep -n "SCRIPT ERROR\|^ERROR\|ERROR:\|WARNING:\|Invalid call\|Invalid access\|null instance" "$log" | grep -v "Loading resource" | sort | uniq -c | sort -rn | head -40 | sed 's/^/PT ERRORS /'
grep "^PT FINDING\|^PT CHECK.*FAIL\|^PT END\|^PT findings" "$log" | sort | uniq | head -80
