#!/bin/sh
# Runs a playtest driver with a virtual screen.  tools/playtest/run.sh <driver> [WxH] [args...]
#   tools/playtest/run.sh pt_menus 1280x720 out:docs/shots/playtest_2026_11_21/menus_online lang:pt
cd "$(dirname "$0")/../.." || exit 1
D=$1; shift
RES=${1:-1280x720}; shift
# PT_HOME=<dir>: a user folder of its own (settings, saves, replays) so runs side by side do not share settings.cfg
[ -n "$PT_HOME" ] && mkdir -p "$PT_HOME" && export XDG_DATA_HOME="$PT_HOME"
exec timeout ${PT_TIMEOUT:-900} xvfb-run -a -s "-screen 0 2560x1440x24" godot --audio-driver Dummy --resolution $RES --script res://tools/playtest/$D.gd -- size:$RES "$@"
