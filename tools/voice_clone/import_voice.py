#!/usr/bin/env python3
"""Puts the big run's recordings where the game plays them (make_big_lines.py names them):

  python3 tools/voice_clone/import_voice.py <folder or zip of .wav files>

brood__<key>.wav  -> assets/voice/announcer/brood/<key>.ogg   (the Brood announcer)
<folder>__<id>.wav -> campaign/voice/<folder>/<id>.ogg         (a mission line)
Each is trimmed of leading/trailing silence and written as Ogg Vorbis (mono, 44.1 kHz) with ffmpeg."""
import os, subprocess, sys, tempfile, zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def wavs(src):
    if src.lower().endswith(".zip"):
        tmp = tempfile.mkdtemp()
        zipfile.ZipFile(src).extractall(tmp)
        src = tmp
    for dp, _, fs in os.walk(src):
        for f in fs:
            if f.lower().endswith(".wav"):
                yield os.path.join(dp, f)


def target(name):
    if "__" not in name:
        return None
    head, key = name.split("__", 1)
    if head == "brood":
        return os.path.join(ROOT, "assets", "voice", "announcer", "brood", key + ".ogg")
    return os.path.join(ROOT, "campaign", "voice", head, key + ".ogg")


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    done, skipped = 0, []
    for w in wavs(sys.argv[1]):
        name = os.path.splitext(os.path.basename(w))[0]
        dst = target(name)
        if not dst:
            skipped.append(name)
            continue
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        flt = ("silenceremove=start_periods=1:start_threshold=-50dB,areverse,"
               "silenceremove=start_periods=1:start_threshold=-50dB,areverse")
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", w, "-af", flt, "-ac", "1", "-ar", "44100",
                        "-c:a", "libvorbis", "-q:a", "5", dst], check=True)
        done += 1
    print("imported", done, "files;", "skipped (not from the big run):", skipped if skipped else "none")


if __name__ == "__main__":
    main()
