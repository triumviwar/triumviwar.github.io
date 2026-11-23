#!/bin/bash
# The checks of the hubs-grow job (docs/hubs_grow.md "Checks"): every campaign test, then every mission's sim at NORMAL
# with the active bot, without the hub's things and with all of them (`hubgrow:a`, `hubgrow:b`: each choice's two sides).
#   GODOT=godot tools/hubs_grow_checks.sh <outdir> [tests|sims|all] [extra sim args...]
# One line a run in <outdir>/summary.txt: the test's failures, or the sim's end (winner, clock).
GODOT=${GODOT:-godot}
OUT=${1:-/tmp/hubs_grow_checks}
WHAT=${2:-all}
shift 2 2>/dev/null
mkdir -p "$OUT"
SUM="$OUT/summary.txt"
: > "$SUM"
if [ "$WHAT" = tests ] || [ "$WHAT" = all ]; then
	for t in tools/test_campaign.gd tools/test_campaign_*.gd tools/test_war_map.gd tools/test_roster_ladder.gd tools/test_hubs_grow.gd; do
		[ -f "$t" ] || continue
		n=$(basename "$t" .gd)
		timeout 1500 "$GODOT" --headless --fixed-fps 30 --script "res://$t" > "$OUT/$n.log" 2>&1
		f=$(grep -c "FAIL" "$OUT/$n.log")
		e=$(grep -c "SCRIPT ERROR" "$OUT/$n.log")
		last=$(grep -E "failures|passed|FAIL" "$OUT/$n.log" | tail -1)
		echo "TEST $n fails=$f script_errors=$e | $last" | tee -a "$SUM"
	done
fi
if [ "$WHAT" = sims ] || [ "$WHAT" = all ]; then
	for s in a01 a02 a03 a04 a05 a06 a07 b01 c01 m1; do
		for sw in ${SWITCHES:-none hubgrow:a hubgrow:b}; do
			f=tools/sim_campaign_$s.gd
			[ -f "$f" ] || continue
			args="active diff=normal"
			[ "$sw" != none ] && args="$args $sw"
			timeout 1800 "$GODOT" --headless --fixed-fps 30 --script "res://$f" -- $args "$@" > "$OUT/sim_${s}_${sw/:/_}.log" 2>&1
			end=$(grep -E "^SIM end|^SIM.*(won|lost|over)" "$OUT/sim_${s}_${sw/:/_}.log" | tail -1 | cut -c1-160)
			hub=$(grep -c "(hub)" "$OUT/sim_${s}_${sw/:/_}.log")
			echo "SIM $s $sw | $end" | tee -a "$SUM"
		done
	done
fi
