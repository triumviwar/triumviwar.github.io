#!/bin/bash
# A WAY OUT's measure (docs/ww_call_off.md): the computers with and without CALL IT OFF / RETREAT (tune CALL_OFF_AI:0),
# 100 wars in each of the five setups of tools/study/ww_tune.sh, on two seed sets (1000-1099, 3000-3099).
#   tools/study/ww_call_off.sh [out dir]      (GODOT=path/to/godot; default "godot")
OUT="${1:-docs/ww_call_off}"; W="${WARS:-100}"; G="${GODOT:-godot}"
cd "$(dirname "$0")/../.."
mkdir -p "$OUT"
run() { "$G" --headless --script res://tools/sim_world_war_tune.gd -- wars=$W "$@" 2>&1 | grep SUMMARY; }
for seed in 1000 3000; do
  for arm in before after; do
    T=""; [ "$arm" = before ] && T="CALL_OFF_AI:0"
    F="$OUT/${arm}_seed${seed}.txt"; : > "$F"
    {
    run tune="$T" seed=$seed sides=crown,clockwork,brood &
    run tune="$T" seed=$seed sides=crown,clockwork &
    wait
    run tune="$T" seed=$seed sides=crown,brood &
    run tune="$T" seed=$seed sides=clockwork,brood &
    wait
    run tune="$T" seed=$seed sides=crown,clockwork,brood seasons=0 limit=120
    } >> "$F"
  done
done
