#!/usr/bin/env python3
"""Writes tools/voice_clone/lines_big.txt: every voice line still to record whose voice is designed (a ref in refs/,
or the King), in one run for the owner's PC (docs/chatterbox_todo.md).

  python3 tools/voice_clone/make_big_lines.py

Names: brood__<key> (the Brood announcer, assets/voice/announcer/brood/<key>.ogg) and <folder>__<line id> (a mission's
line, campaign/voice/<folder>/<line id>.ogg). Lines that already have a file in the game are left out. Bring the out/
folder back (a zip) and tools/voice_clone/import_voice.py puts every file where the game plays it."""
import glob, json, os, re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HERE = os.path.join(ROOT, "tools", "voice_clone")

# who -> (reference, pitch, exaggeration). The King as in the prologue (deeper, calm).
VOICES = {
    "king": ("king_ref.wav", 0.0, 0.4),  # pitch 0: -1.5 muffled him (owner 2026-11-18)
    "hollweg": ("refs/hollweg_ref.wav", 0.0, 0.5),
    "lindqvist": ("refs/lindqvist_ref.wav", 0.0, 0.5),
    "valadares": ("refs/explorer_ref.wav", 0.0, 0.5),
    "fairleigh": ("refs/fairleigh_ref.wav", 0.0, 0.45),
    "ruggieri": ("refs/ruggieri_ref.wav", 0.0, 0.7),
    "varenne": ("refs/varenne_ref.wav", 0.0, 0.7),
    "ferrer": ("refs/ferrer_ref.wav", 0.0, 0.45),    # designed 2026-11-22: a calm Spanish Jesuit of fifty
    # designed 2026-11-22 in the second ElevenLabs account (refs/README.txt)
    "jakob": ("refs/jakob_ref.wav", 0.0, 0.5),
    "delorme": ("refs/delorme_ref.wav", 0.0, 0.45),
    "benedito": ("refs/benedito_ref.wav", 0.0, 0.45),
    "brother": ("refs/brother_ref.wav", 0.0, 0.4),
    "colonel": ("refs/colonel_ref.wav", 0.0, 0.55),
    "machine": ("refs/machine_ref.wav", 0.0, 0.3),
    "captain": ("refs/captain_ref.wav", 0.0, 0.5),
    "pieter": ("refs/pieter_ref.wav", 0.0, 0.5),
    "sergeant": ("refs/sergeant_ref.wav", 0.0, 0.6),
    "cardinal": ("refs/cardinal_ref.wav", 0.0, 0.4),
    # designed 2026-11-22 (second batch): until a ref is in refs/, its lines wait (see main)
    "tomasz": ("refs/tomasz_ref.wav", 0.0, 0.45),
    "cardinal_dean": ("refs/cardinal_dean_ref.wav", 0.0, 0.35),
    "printer": ("refs/printer_ref.wav", 0.0, 0.6),
    "weaver": ("refs/weaver_ref.wav", 0.0, 0.5),
    "commissary": ("refs/commissary_ref.wav", 0.0, 0.4),
    "guide": ("refs/guide_ref.wav", 0.0, 0.4),
    "teles": ("refs/teles_ref.wav", 0.0, 0.6),
    "joaquim": ("refs/joaquim_ref.wav", 0.0, 0.6),
    "volunteer": ("refs/volunteer_ref.wav", 0.0, 0.5),
    "assembly": ("refs/assembly_ref.wav", 0.0, 0.5),
}
ORDER = ["ferrer", "lindqvist", "king", "hollweg", "valadares", "fairleigh", "ruggieri", "varenne", "jakob",
         "delorme", "benedito", "brother", "colonel", "machine", "captain", "pieter", "sergeant", "cardinal",
         "tomasz", "cardinal_dean", "printer", "weaver", "commissary", "guide", "teles", "joaquim", "volunteer", "assembly"]
# The same "who" key is two people in a few missions: (voice folder, who) -> the voice, or None (not designed yet).
SAME_KEY = {("a07", "cardinal"): "cardinal_dean"}     # the Cardinal Dean, not old Cardinal Tomasz
SKIP_MISSIONS = ["p01_revolt"]             # the engine's test bed, never voiced


def voice_of(folder, who):
    v = SAME_KEY.get((folder, who), who if who in VOICES else None)
    ref = VOICES.get(v, ("",))[0]
    return v if v and os.path.exists(os.path.join(HERE, ref)) else None


def announcer():
    """The Brood announcer's 21 lines from docs/chatterbox_todo.md's table (Lindqvist's v2 voice)."""
    out = []
    for ln in open(os.path.join(ROOT, "docs", "chatterbox_todo.md"), encoding="utf-8"):
        m = re.match(r"\| ([a-z0-9_]+) \| [^|]+ \| (.+?) \|\s*$", ln)
        if m and m.group(1) not in ("key", "mission") and not os.path.exists(
                os.path.join(ROOT, "assets", "voice", "announcer", "brood", m.group(1) + ".ogg")):
            out.append(("brood__" + m.group(1), m.group(2).strip()))
    return out


def mission_lines():
    by_who = {w: [] for w in VOICES}
    for f in sorted(glob.glob(os.path.join(ROOT, "campaign", "missions", "*.json"))):
        M = json.load(open(f, encoding="utf-8"))
        folder = M.get("voice")
        if not folder or M.get("id") in SKIP_MISSIONS:
            continue
        for lid, L in M.get("lines", {}).items():
            who = voice_of(folder, L.get("who")) if isinstance(L, dict) else None
            if who is None:
                continue
            if os.path.exists(os.path.join(ROOT, "campaign", "voice", folder, lid + ".ogg")):
                continue
            text = str(L.get("text", "")).replace("|", ",").replace("\n", " ").strip()
            if text:
                by_who[who].append(("%s__%s" % (folder, lid), text))
    return by_who


def main():
    rows = ["# The big run (docs/chatterbox_todo.md): run.bat --lines lines_big.txt",
            "# A stopped run picks up where it left off. EVERY CAMPAIGN LINE IS A PLACEHOLDER (rewritten later).", ""]
    ann = announcer()
    total = 0
    if ann:
        rows += ["# ---- The Brood announcer, Lindqvist's v2 voice (%d)" % len(ann),
                 "[ref refs/lindqvist_ref.wav]", "[pitch 0]", "[exaggeration 0.5]"]
        rows += ["%s | %s" % r for r in ann]
    total += len(ann)
    ml = mission_lines()
    for who in ORDER:
        ref, pitch, ex = VOICES[who]
        if not ml[who]:
            continue
        rows += ["", "# ---- %s (%d lines)" % (who, len(ml[who])), "[ref %s]" % ref, "[pitch %s]" % pitch,
                 "[exaggeration %s]" % ex]
        rows += ["%s | %s" % r for r in ml[who]]
        total += len(ml[who])
    with open(os.path.join(HERE, "lines_big.txt"), "w", encoding="utf-8") as fh:
        fh.write("\n".join(rows) + "\n")
    print("lines_big.txt:", total, "lines;", ", ".join("%s %d" % (w, len(ml[w])) for w in ORDER), "+ announcer", len(ann))


if __name__ == "__main__":
    main()
