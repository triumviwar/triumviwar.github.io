#!/bin/bash
# tools/playtest/tutorial_editor/run.sh <script> <W> <H> [args...]: one playtest driver under xvfb (opengl3, dummy audio); the log
# goes to stdout (the engine's resource lines dropped).
#   tools/playtest/tutorial_editor/run.sh pt_tut_basics 1280 720 lang:pt player:careful
s=$1; W=${2:-1280}; H=${3:-720}; shift 3 2>/dev/null
cd "$(dirname "$0")/../../.."
timeout ${PT_TIMEOUT:-1500} xvfb-run -a -s "-screen 0 ${W}x${H}x24" godot --rendering-driver opengl3 --audio-driver Dummy \
	--resolution ${W}x${H} --script res://tools/playtest/tutorial_editor/$s.gd -- "$@" 2>&1 | grep --line-buffered -v "^Loading resource\|^Completed load"
