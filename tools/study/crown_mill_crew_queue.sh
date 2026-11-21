#!/bin/bash
# THE MILLS' FULL CREW (docs/crown_mill_crew.md): on and off x matchup x block, block 1 of everything first (so a cut run
# still has a whole first round). Skips games already played. Commits and pushes the data after each block of 10.
#   [ARMS="on"] tools/study/crown_mill_crew_queue.sh [blocks, default "1 2"]
cd "$(dirname "$0")/../.."
for blk in ${1:-1 2}; do
  for opp in clockwork brood crown; do
    for arm in ${ARMS:-off on}; do
      python3 tools/study/crown_mill_crew.py run "$arm" "$opp" "$blk" --jobs 2
      git add docs/crown_mill_crew/data >/dev/null 2>&1
      git commit -q -m "WIP crown-mill-crew: data $arm v $opp block $blk

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01NtmEZhP1uA8k4DLQ7BYfMz" >/dev/null 2>&1 && git push -q >/dev/null 2>&1
    done
  done
done
echo QUEUE DONE
