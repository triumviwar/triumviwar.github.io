#!/bin/bash
# (ai-opponent-review) a light frozen copy of the game at a commit, for study games that must not see later edits:
#   freeze_copy.sh DEST [COMMIT]
# scripts/, tools/, campaign/, project.godot and the small .godot files are real copies of COMMIT; the art, the import cache
# and everything else are symlinks into this repo (a full worktree is 3-5 GB; the disk here is short).
SRC=$(cd "$(dirname "$0")/../.." && pwd)
DEST=$1; C=${2:-HEAD}
rm -rf "$DEST"; mkdir -p "$DEST/.godot"
cd "$SRC"
for e in * .[!.]*; do
	case "$e" in .git|.godot|scripts|tools|campaign|project.godot|docs) ;; *) ln -s "$SRC/$e" "$DEST/$e" ;; esac
done
git archive "$C" scripts tools campaign project.godot | tar -x -C "$DEST"
ln -s "$SRC/.godot/imported" "$DEST/.godot/imported"
cp -r .godot/editor .godot/global_script_class_cache.cfg .godot/uid_cache.bin "$DEST/.godot/" 2>/dev/null
for f in .godot/*.cfg .godot/*.bin; do cp "$f" "$DEST/.godot/" 2>/dev/null; done
cp scripts/*.uid "$DEST/scripts/" 2>/dev/null
echo "frozen $(git rev-parse --short $C) at $DEST"
