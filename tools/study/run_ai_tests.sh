#!/bin/bash
# (ai-opponent-review) run every tools/test_ai_*.gd in ROOT (default: this repo) one at a time; a line per test:
#   tools/study/run_ai_tests.sh [ROOT] > results.txt
ROOT=${1:-$(cd "$(dirname "$0")/../.." && pwd)}
cd "$ROOT"
for t in tools/test_ai_*.gd; do
	s=$(date +%s)
	out=$(timeout 1500 godot --headless --fixed-fps 30 --path . --script res://$t 2>&1)
	rc=$?
	fails=$(echo "$out" | grep -E "FAIL" | grep -v "ALL PASS" | head -3 | tr '\n' ' ' | cut -c1-240)
	verdict=FAIL
	if echo "$out" | grep -qE "ALL PASS|ALL OK|^PASS|RESULT: 0 failed"; then verdict=PASS; fi
	if [ -n "$fails" ]; then verdict=FAIL; fi
	# (the engine often aborts on exit after a finished test: rc 134 with "ALL PASS" is a pass)
	echo "$(basename $t) $verdict rc=$rc $(( $(date +%s) - s ))s ${fails}"
done
