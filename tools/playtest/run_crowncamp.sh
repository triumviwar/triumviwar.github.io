#!/bin/bash
# Runs one playtest driver: tools/playtest/run_crowncamp.sh <driver> [WxH|headless] [args...]   (log in /tmp/pt_<driver>_<n>.log)
# e.g. tools/playtest/run_crowncamp.sh pt_hub 1280x720 progress=p01 lang=pt
d=$1; shift
size=${1:-1280x720}; shift
cd "$(dirname "$0")/../.."
# each run its own user:// (settings, campaign progress, crash marker): runs and tests side by side never mix
export XDG_DATA_HOME=${PT_USER:-/tmp/pt_user_${d}_$$}
mkdir -p "$XDG_DATA_HOME"
if [ "$size" = headless ]; then
  exec timeout ${PT_TIMEOUT:-1800} godot --headless --path . --script res://tools/playtest/$d.gd -- "$@"
fi
exec timeout ${PT_TIMEOUT:-1800} xvfb-run -a -s "-screen 0 ${size}x24" godot --path . --resolution $size --script res://tools/playtest/$d.gd -- "$@"
