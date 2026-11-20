#!/bin/bash
# CROWN POWDER STUDY (docs/crown_powder_study.md): every option x matchup x block, the blocks round by round (so a cut run
# still has block 1 of everything; block 2 of the Clockwork first, where the dry bank shows most). Skips games already
# played. Commits and pushes the data after each block of 10.
#   tools/study/crown_powder_queue.sh            (then the A+C combination: tools/study/crown_powder_queue.sh extra)
cd "$(dirname "$0")/../.."
OPTS="base salt2500 floor35 nitre buy"
PLAN="1:brood 1:clockwork 1:crown 2:clockwork 2:brood 2:crown"
if [ "$1" = extra ]; then OPTS="salt2500+nitre"; PLAN="1:clockwork 1:brood 1:crown 2:clockwork 2:brood 2:crown"; fi
for p in $PLAN; do
  blk=${p%%:*}; opp=${p#*:}
  for opt in $OPTS; do
    python3 tools/study/crown_powder_study.py run "$opt" "$opp" "$blk" --jobs 2
    git add docs/crown_powder_study/data >/dev/null 2>&1
    git commit -q -m "WIP crown-powder-study: data $opt v $opp block $blk" >/dev/null 2>&1 && git push -q >/dev/null 2>&1
  done
done
echo QUEUE DONE
