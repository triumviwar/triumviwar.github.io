#!/bin/sh
# (crown-1000-clockwork) copy the working tree to a run copy (docs/, art/ and .git left out; its .godot import cache kept)
# and import it, so a block runs on a frozen copy while the next change is written:  tools/study/crown1000_sync.sh /path/copy
set -e
dst=${1:?copy dir}
src=$(cd "$(dirname "$0")/../.." && pwd)
mkdir -p "$dst"
find "$dst" -mindepth 1 -maxdepth 1 ! -name .godot -exec rm -rf {} +
(cd "$src" && tar -cf - --exclude=./.git --exclude=./docs --exclude=./art --exclude=./.godot .) | (cd "$dst" && tar -xf -)
[ -d "$dst/.godot" ] || cp -a "$src/.godot" "$dst/.godot"
timeout 900 godot --headless --import --path "$dst" > "$dst/.import.log" 2>&1 || true
if grep -E "SCRIPT ERROR|Parse Error" "$dst/.import.log"; then exit 1; fi
