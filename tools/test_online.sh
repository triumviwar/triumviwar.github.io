#!/bin/sh
# Online play on one computer: a relay, a host and a guest process (see tools/test_online.gd).
#   tools/test_online.sh [coop] [fac_host:brood fac_guest:clockwork ...]
# Needs godot on the PATH and node. Prints the CHECK lines and the LAG lines; exit code 1 if any failed.
# LAG_MS=40 JITTER_MS=20 tools/test_online.sh ...: the relay holds every frame 40 ms each way, plus up to 20 ms at random
# (a real connection's round trip and its unevenness).
#   tools/test_online.sh spectators: a host, a guest who plays and two spectators (one joins the match under way, then
#   leaves): tools/test_online_spectators.gd (docs/online_spectators.md). SHOTS=<dir> takes pictures (xvfb-run).
#   The upload in a real fight: HOST_ARGS=ai GUEST_ARGS=match:300 SPEC2_AFTER=220 SPEC2_ARGS=stay:60 tools/test_online.sh spectators
cd "$(dirname "$0")/.." || exit 1
if [ "$1" = "tournament" ]; then
	# TOURNAMENTS online (docs/tournament.md): the desk, ten players, a match's room, in one process
	PORT=${PORT:-8799}
	OUT=${TMPDIR:-/tmp}/triumviwar_tournament_$$
	mkdir -p "$OUT"
	node tools/relay/local_relay.mjs $PORT > "$OUT/relay.log" 2>&1 &
	RELAY=$!
	sleep 1
	godot --headless --script res://tools/test_tournament_online.gd -- relay:ws://127.0.0.1:$PORT > "$OUT/run.log" 2>&1
	RC=$?
	kill $RELAY 2>/dev/null
	grep -h "CHECK\|ALL OK\|SOME FAILED\|SCRIPT ERROR\|checks" "$OUT/run.log"
	echo "(full log in $OUT)"
	exit $RC
fi
if [ "$1" = "spectators" ]; then
	PORT=${PORT:-8798}
	OUT=${TMPDIR:-/tmp}/triumviwar_spectators_$$
	mkdir -p "$OUT"
	node tools/relay/local_relay.mjs $PORT > "$OUT/relay.log" 2>&1 &
	RELAY=$!
	sleep 1
	if [ -n "$SHOTS" ]; then
		mkdir -p "$SHOTS"
		RUN="xvfb-run -a godot --resolution 1280x720 --script res://tools/test_online_spectators.gd --"
		EXTRA="shots:$SHOTS"
	else
		RUN="godot --headless --script res://tools/test_online_spectators.gd --"
		EXTRA=""
	fi
	$RUN role:host relay:ws://127.0.0.1:$PORT code:SPEC $EXTRA $HOST_ARGS > "$OUT/host.log" 2>&1 &
	HOST=$!
	sleep 3
	$RUN role:spec1 relay:ws://127.0.0.1:$PORT code:SPEC $EXTRA > "$OUT/spec1.log" 2>&1 &
	S1=$!
	sleep 6
	$RUN role:guest relay:ws://127.0.0.1:$PORT code:SPEC $EXTRA $GUEST_ARGS > "$OUT/guest.log" 2>&1 &
	GUEST=$!
	sleep ${SPEC2_AFTER:-25}
	$RUN role:spec2 relay:ws://127.0.0.1:$PORT code:SPEC $SPEC2_ARGS > "$OUT/spec2.log" 2>&1 &
	S2=$!
	wait $S2 $GUEST $S1 $HOST
	kill $RELAY 2>/dev/null
	grep -h "CHECK\|BW \|ALL OK\|SOME FAILED\|TIMEOUT\|SCRIPT ERROR" "$OUT/host.log" "$OUT/spec1.log" "$OUT/guest.log" "$OUT/spec2.log"
	echo "(full logs in $OUT)"
	! grep -q "SOME FAILED\|TIMEOUT\|SCRIPT ERROR\| FAIL " "$OUT/host.log" "$OUT/spec1.log" "$OUT/guest.log" "$OUT/spec2.log"
	exit $?
fi
PORT=${PORT:-8799}
OUT=${TMPDIR:-/tmp}/holdfast_online_$$
mkdir -p "$OUT"
node tools/relay/local_relay.mjs $PORT > "$OUT/relay.log" 2>&1 &
RELAY=$!
sleep 1
godot --headless --script res://tools/test_online.gd -- role:host relay:ws://127.0.0.1:$PORT code:TEST "$@" > "$OUT/host.log" 2>&1 &
HOST=$!
sleep 3
godot --headless --script res://tools/test_online.gd -- role:guest relay:ws://127.0.0.1:$PORT code:TEST "$@" > "$OUT/guest.log" 2>&1 &
GUEST=$!
wait $GUEST
wait $HOST
kill $RELAY 2>/dev/null
grep -h "CHECK\|RESULT\|LAG \|ALL OK\|SOME FAILED\|hash\|FAILED\|TIMEOUT\|SCRIPT ERROR" "$OUT/host.log" "$OUT/guest.log"
echo "(full logs in $OUT)"
! grep -q "SOME FAILED\|TIMEOUT\|SCRIPT ERROR" "$OUT/host.log" "$OUT/guest.log"
