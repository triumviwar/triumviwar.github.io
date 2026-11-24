#!/bin/bash
# THE WORLD WAR's tuning measure (docs/world_war_tune.md): one arm = 100 wars (seeds 1000-1099) in each of five setups:
# three sides to 48 seasons, the three two-side pairings to 48, three sides with no last season (stopped at 120).
#   tools/study/ww_tune.sh "<tune>" [out file]      (tune: "" = today's rules, "v1" = the first numbers, "K:v,K2:v")
T="$1"; OUT="${2:-/dev/stdout}"; W="${WARS:-100}"
cd "$(dirname "$0")/../.."
run() { godot --headless --script res://tools/sim_world_war_tune.gd -- wars=$W tune="$T" "$@" 2>&1 | grep SUMMARY; }
{
run sides=crown,clockwork,brood &
run sides=crown,clockwork &
wait
run sides=crown,brood &
run sides=clockwork,brood &
wait
run sides=crown,clockwork,brood seasons=0 limit=120
} >> "$OUT"
