#!/usr/bin/env bash
# THE CLICK SWEEP (docs/qa_click_sweep.md): press everything clickable, report what breaks.
#   tools/qa/click_sweep.sh                      every part x en/pt/es x computer (1600x900) and phone (2400x1080)
#   tools/qa/click_sweep.sh --quick              every part, English, computer only (before a release)
#   tools/qa/click_sweep.sh --parts menus,settings --lang pt,es --size phone [--depth 2] [--budget 400]
# GODOT=<binary> (default: godot on the PATH). Logs and JSON in $OUT (default /tmp/qa_click_sweep), pictures in
# docs/shots/qa_click_sweep/ (every screen for en/pc, only screens with a flag for the rest). The last lines of each
# log are "SWEEP-SUMMARY ..."; flags are the "SWEEP <KIND> ..." lines (grep them).
set -u
cd "$(dirname "$0")/../.."
GODOT="${GODOT:-godot}"
OUT="${OUT:-/tmp/qa_click_sweep}"
SHOTS="docs/shots/qa_click_sweep"
PARTS="all"
LANGS="en,pt,es"
SIZES="pc,phone"
EXTRA=()
while [ $# -gt 0 ]; do
  case "$1" in
    --quick) LANGS="en"; SIZES="pc"; shift;;
    --parts) PARTS="$2"; shift 2;;
    --lang) LANGS="$2"; shift 2;;
    --size) SIZES="$2"; shift 2;;
    --depth) EXTRA+=("depth=$2"); shift 2;;
    --budget) EXTRA+=("budget=$2"); shift 2;;
    *) echo "unknown option $1"; exit 2;;
  esac
done
mkdir -p "$OUT" "$SHOTS"
if [ "$PARTS" = "all" ]; then
  PARTS="menus,settings,campaign,skirmish,skirmish_crown,skirmish_clockwork,skirmish_brood,editor,worldwar,tournaments,online,replays"
fi
fail=0
for lang in ${LANGS//,/ }; do
  for size in ${SIZES//,/ }; do
    res="1600x900"; [ "$size" = "phone" ] && res="2400x1080"
    shots="flags"; [ "$lang" = "en" ] && [ "$size" = "pc" ] && shots="all"
    # (the other languages and the phone: the same screens, a shorter walk unless --depth/--budget say otherwise)
    more=(); [ "$shots" = "flags" ] && [ ${#EXTRA[@]} -eq 0 ] && more=("budget=200")
    # one Godot a part: a crash in one part does not lose the others
    for part in ${PARTS//,/ }; do
      log="$OUT/${lang}_${size}_${part}.log"
      echo "== $lang $size $part"
      timeout 5400 xvfb-run -a -s "-screen 0 ${res}x24" "$GODOT" --rendering-driver opengl3 --resolution "$res" \
        --path . --script res://tools/qa/click_sweep.gd -- "out=$SHOTS" "lang=$lang" "size=$size" "parts=$part" \
        "shots=$shots" "${EXTRA[@]}" "${more[@]}" > "$log" 2>&1
      code=$?
      if [ $code -ne 0 ]; then
        if grep -q '^SWEEP-SUMMARY' "$log"; then
          echo "   (Godot exit $code after the summary: the engine's abort at exit, docs/qa_click_sweep.md MEDIUM 1)"
        else
          echo "   exit $code (crash or timeout before the end): see $log"; fail=1
        fi
      fi
      grep -E '^SWEEP-SUMMARY' "$log" | sed 's/^/   /'
      mv -f "$SHOTS/sweep_${lang}_${size}.json" "$OUT/sweep_${lang}_${size}_${part}.json" 2>/dev/null
    done
  done
done
echo "flags by kind:"
cat "$OUT"/*.log | grep -oE '^SWEEP [A-Z]+' | sort | uniq -c | sort -rn
exit $fail
