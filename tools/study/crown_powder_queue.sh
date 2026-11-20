#!/bin/bash
# CROWN POWDER STUDY (docs/crown_powder_study.md): every option x matchup x block, the blocks round by round (so a cut run
# still has block 1 of everything). Skips games already played. Pushes the data after each block of 10.
#   tools/study/crown_powder_queue.sh [opts...]     (default: base salt2500 floor35 nitre buy)
cd "$(dirname "$0")/../.."
OPTS=${@:-"base salt2500 floor35 nitre buy"}
for blk in 1 2; do
  for opp in brood clockwork crown; do
    for opt in $OPTS; do
      python3 tools/study/crown_powder_study.py run "$opt" "$opp" "$blk" --jobs 2
      git add docs/crown_powder_study/data >/dev/null 2>&1
      git commit -q -m "WIP crown-powder-study: data $opt v $opp block $blk" >/dev/null 2>&1 && git push -q >/dev/null 2>&1
    done
  done
done
echo QUEUE DONE
