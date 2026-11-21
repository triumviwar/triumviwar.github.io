#!/bin/bash
# Runs one playtest driver: tools/playtest/run.sh <driver> [WxH|headless] [args...]   (log in /tmp/pt_<driver>_<n>.log)
# e.g. tools/playtest/run.sh pt_hub 1280x720 progress=p01 lang=pt
d=$1; shift
size=${1:-1280x720}; shift
cd "$(dirname "$0")/../.."
if [ "$size" = headless ]; then
  exec timeout ${PT_TIMEOUT:-1800} godot --headless --path . --script res://tools/playtest/$d.gd -- "$@"
fi
exec timeout ${PT_TIMEOUT:-1800} xvfb-run -a -s "-screen 0 ${size}x24" godot --path . --resolution $size --script res://tools/playtest/$d.gd -- "$@"
