#!/bin/sh
# player-comforts: every Act 1 mission played to its end by its sim bot (tools/sim_campaign_*.gd, "active") twice: once
# straight through, once SAVED and LOADED in the middle (save_at=, tools/sim_save_hook.gd), and the flags written at the
# end compared. Each run has a user folder of its own (the sims write the campaign's progress file).
#   tools/test_campaign_save.sh [mission ...]          (none: all eleven)   JOBS=2 at once; OUT=<dir> for the logs
# The quick checks (a save of every mission loaded back, the checkpoints, the menu, QUIT to the hub) are
# tools/test_campaign_save.gd.
cd "$(dirname "$0")/.." || exit 1
OUT=${OUT:-/tmp/campaign_save}
JOBS=${JOBS:-2}
mkdir -p "$OUT"
# mission sim save_at extra-args (save_at: about half way through the sim's own run; p01's sim plays only its night)
LIST="p01 m1 300 active until=490
a01 a01 180 active layout=hill
a02 a02 400 active
a03 a03 300 active
a04 a04 150 active
a05 a05 170 active
a06 a06 160 active
a07 a07 400 active
b01 b01 300 active
c01 c01 400 active
d02 d02 120 active"
run() {   # tag sim save_at args...
	tag=$1; sim=$2; at=$3; shift 3
	for how in plain saved; do
		home="$OUT/home_${tag}_$how"
		rm -rf "$home"; mkdir -p "$home"
		extra=""
		[ "$how" = saved ] && extra="save_at=$at"
		XDG_DATA_HOME="$home" timeout ${T:-1500} godot --headless --fixed-fps 30 --script res://tools/sim_campaign_$sim.gd -- "$@" $extra \
			> "$OUT/${tag}_$how.log" 2>&1
	done
	p=$(grep "SIM end" "$OUT/${tag}_plain.log" | sed 's/.*winner=\([^ ]*\).*flags=\(.*\)/winner=\1 flags=\2/' | sed 's/ objectives=.*//; s/ went=.*flags=/ flags=/')
	s=$(grep "SIM end" "$OUT/${tag}_saved.log" | sed 's/.*winner=\([^ ]*\).*flags=\(.*\)/winner=\1 flags=\2/' | sed 's/ objectives=.*//; s/ went=.*flags=/ flags=/')
	same=$(grep "SIM LOAD SAME" "$OUT/${tag}_saved.log" | head -1)
	echo "$tag | plain: $p"
	echo "$tag | saved: $s"
	echo "$tag | $same"
	grep -h "SCRIPT ERROR" "$OUT/${tag}_saved.log" | sort | uniq -c | head -3 | sed "s/^/$tag | /"
}
want="$*"
echo "$LIST" | while read tag sim at args; do
	if [ -n "$want" ] && ! echo " $want " | grep -q " $tag "; then continue; fi
	echo "$tag $sim $at $args"
done > "$OUT/todo.txt"
# JOBS at once
i=0
while read tag sim at args; do
	run $tag $sim $at $args > "$OUT/${tag}_result.txt" &
	i=$((i + 1))
	if [ $((i % JOBS)) -eq 0 ]; then wait; fi
done < "$OUT/todo.txt"
wait
cat "$OUT"/*_result.txt
