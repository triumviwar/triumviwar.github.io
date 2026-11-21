#!/bin/sh
# RANKED playtest: relay + ladder (--dev) + two copies of the game played through the menus (tools/playtest/pt_ranked.gd).
#   tools/playtest/ranked.sh <outdir>
cd "$(dirname "$0")/../.." || exit 1
OUT=${1:-/tmp/pt_ranked_out}; mkdir -p "$OUT"; SYNC=$OUT/sync; rm -rf "$SYNC"; mkdir -p "$SYNC"
RPORT=${RPORT:-8821}; LPORT=${LPORT:-8822}
export LADDER_SECRET="pt-secret-$(date +%s)-0123456789"
export LADDER_MAPS=${LADDER_MAPS:-hollowfen}
node tools/relay/local_relay.mjs $RPORT > "$OUT/relay.log" 2>&1 &
RELAY=$!
node tools/ladder/ladder.mjs --dev --port $LPORT --relay ws://127.0.0.1:$RPORT --godot godot --db "$OUT/ladder.db" \
	--out "$OUT" --max-matches 2 > "$OUT/ladder.log" 2>&1 &
LADDER=$!
sleep 2
C="ranked_dev ladder:http://127.0.0.1:$LPORT sync:$SYNC out:$OUT/shots"
PT_HOME=$OUT/home_a tools/playtest/run.sh pt_ranked 1280x720 role:a dev_sid:76561190000000111 dev_name:Alice faction:crown $C > "$OUT/a.log" 2>&1 &
A=$!
PT_HOME=$OUT/home_b tools/playtest/run.sh pt_ranked 960x540 role:b dev_sid:76561190000000222 dev_name:Bruno faction:brood $C > "$OUT/b.log" 2>&1 &
B=$!
wait $A $B
kill $LADDER $RELAY 2>/dev/null
grep -h "^PT \|SCRIPT ERROR" "$OUT/a.log" "$OUT/b.log" | grep -v "PT PRESS\|PT WARN"
grep -h "\[ladder\]\|\[match" "$OUT/ladder.log" | head -20
