#!/bin/sh
# ONLINE playtest: the local relay and several copies of the game, each driven by tools/playtest/pt_online.gd.
#   tools/playtest/online.sh <scen> <outdir> [secs]
#   scen: basic (host + guest), spec (host + guest + a spectator), full (host + guest + a third who JOINs),
#         host_leave, guest_drop (the guest's program is killed mid-match, then a new copy rejoins), wrong (a bad code)
# Copies after the first two run headless (no pictures) to spare the CPU unless ALLWIN=1.
cd "$(dirname "$0")/../.." || exit 1
SCEN=${1:-basic}; OUT=${2:-/tmp/pt_online_out}; SECS=${3:-60}
PORT=${PORT:-8797}
SYNC=$OUT/sync; rm -rf "$SYNC"; mkdir -p "$SYNC" "$OUT"
node tools/relay/local_relay.mjs $PORT > "$OUT/relay.log" 2>&1 &
RELAY=$!
sleep 1
RUN="tools/playtest/run.sh pt_online"
COMMON="relay:ws://127.0.0.1:$PORT sync:$SYNC scen:$SCEN secs:$SECS out:$OUT/shots lang:${LANG_PT:-en}"
headless() {  # role
	XDG_DATA_HOME=$OUT/home_$1 timeout 900 godot --headless --audio-driver Dummy --script res://tools/playtest/pt_online.gd -- role:$1 $COMMON > "$OUT/$1.log" 2>&1 &
}
win() {  # role [size]
	PT_HOME=$OUT/home_$1 $RUN ${2:-1280x720} role:$1 $COMMON > "$OUT/$1.log" 2>&1 &
}
if [ "$SCEN" = "wrong" ]; then
	win wrong; W=$!
	wait $W
else
	win host; H=$!
	sleep 2
	win guest ${GUEST_SIZE:-1280x720}; G=$!
	case $SCEN in
		spec) headless spec ;;
		full) headless third ;;
	esac
	if [ "$SCEN" = "guest_drop" ]; then
		while [ ! -f "$SYNC/guest_dropped" ]; do sleep 1; if ! kill -0 $H 2>/dev/null; then break; fi; done
		sleep 1
		pkill -9 -f "role:guest .*sync:$SYNC" ; echo "killed the guest" >> "$OUT/guest.log"
		sleep 6
		win rejoin
	fi
	wait $H
	sleep 3
	pkill -f "sync:$SYNC" 2>/dev/null
fi
kill $RELAY 2>/dev/null
grep -h "^PT \|SCRIPT ERROR" "$OUT"/*.log | grep -v "PT PRESS\|PT NOTE-OUT\|PT WARN"
