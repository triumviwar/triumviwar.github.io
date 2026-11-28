#!/usr/bin/env python3
"""Writes tools/voice_clone/lines_big.txt: every voice line still to record whose voice is designed (a ref in refs/,
or the King), in one run for the owner's PC (docs/chatterbox_todo.md).

  python3 tools/voice_clone/make_big_lines.py

Names: brood__<key> (the Brood announcer, assets/voice/announcer/brood/<key>.ogg) and <folder>__<line id> (a mission's
line, campaign/voice/<folder>/<line id>.ogg). Lines that already have a file in the game are left out. Bring the out/
folder back (a zip) and tools/voice_clone/import_voice.py puts every file where the game plays it."""
import glob, json, os, re, sys

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
    # Act 2, designed 2026-11-28 (Voice Design; the first of three previews, trimmed to a pause near 18 s)
    "ulrich": ("refs/ulrich_ref.wav", 0.0, 0.6),
    "meneses": ("refs/meneses_ref.wav", 0.0, 0.55),
    "ramos": ("refs/ramos_ref.wav", 0.0, 0.65),
    "arruda": ("refs/arruda_ref.wav", 0.0, 0.5),
    "inacio": ("refs/inacio_ref.wav", 0.0, 0.6),
    "tiago": ("refs/tiago_ref.wav", 0.0, 0.5),
    "fonseca": ("refs/fonseca_ref.wav", 0.0, 0.5),
    "morel": ("refs/morel_ref.wav", 0.0, 0.4),
    "rider": ("refs/rider_ref.wav", 0.0, 0.7),
    "officer": ("refs/officer_ref.wav", 0.0, 0.5),       # Captain Sobral (d05), the captain of Obidos (d10)
    # Act 2 voices made from others (the owner's credits ran out 2026-11-28; pitch in semitones)
    "officer_old": ("refs/officer_ref.wav", -0.8, 0.5),  # Major Teixeira (d09)
    "brandt": ("refs/commissary_ref.wav", -0.5, 0.4),    # Commissary Brandt (d02): a dry chancery official
    "anselmo": ("refs/joaquim_ref.wav", -0.5, 0.5),      # Padre Anselmo (d04): a kind country priest
    "ortlieb": ("refs/captain_ref.wav", -1.0, 0.45),     # Master Ortlieb (d07): a comfortable old master
    "master": ("refs/brother_ref.wav", 1.0, 0.6),        # the frightened master of d07
    "townsman": ("refs/tiago_ref.wav", -1.5, 0.5),       # a townsman of Vila Rica (d01)
    "barra_sergeant": ("refs/sergeant_ref.wav", -1.0, 0.6),  # the Barra's sergeant (d08, d10)
    "tomasz_grown": ("refs/tomasz_ref.wav", -1.0, 0.45),     # Tomasz at thirty-five to forty (d01, d05, d09)
    "pieter_grown": ("refs/pieter_ref.wav", -1.0, 0.5),      # Pieter at thirty (d03, d06)
    "jakob_old": ("refs/jakob_ref.wav", -2.0, 0.45),         # Jakob in his sixties (d11)
    "matthias": ("refs/jakob_ref.wav", 1.0, 0.55),           # Jakob's son, about twenty (d07, d11)
    "hollins": ("refs/volunteer_ref.wav", -1.5, 0.5),        # Sergeant Hollins, Will grown (d09)
}
# A second reference, the same voice shouting (docs/chatterbox_todo.md: Chatterbox copies the reference's delivery):
# used for that voice's shout and angry lines (not urgent: a quiet plea would come out shouted). Owner 2026-11-28: Tomasz and Valadares sounded too calm.
ANGRY_REFS = {"tomasz": "refs/tomasz_angry_ref.wav", "tomasz_grown": "refs/tomasz_angry_ref.wav",
              # Valadares: made with Chatterbox alone, as the first line of the big run (--all): see SEED
              "valadares": "out_all/valadares_angry_seed.wav"}
ANGRY_LATER = {"valadares"}     # its reference is made in the same run, so it need not exist yet
SEED = ("valadares_angry_seed", "refs/explorer_ref.wav", 1.4, 0.3,
        "Torches! Into the forest, all of you! Now! You fools, I warned you, I warned every one of you, and you "
        "would not listen! Get the women to the canoes! Move!")
ANGRY_TAGS = ("shout", "angry")
ORDER = ["ferrer", "lindqvist", "king", "hollweg", "valadares", "fairleigh", "ruggieri", "varenne", "jakob",
         "delorme", "benedito", "brother", "colonel", "machine", "captain", "pieter", "sergeant", "cardinal",
         "tomasz", "cardinal_dean", "printer", "weaver", "commissary", "guide", "teles", "joaquim", "volunteer", "assembly",
         "ulrich", "meneses", "ramos", "arruda", "inacio", "tiago", "fonseca", "morel", "rider", "officer", "officer_old",
         "brandt", "anselmo", "ortlieb", "master", "townsman", "barra_sergeant", "tomasz_grown", "pieter_grown",
         "jakob_old", "matthias", "hollins"]
# The same "who" key is two people in a few missions: (voice folder, who) -> the voice, or None (not designed yet).
SAME_KEY = {("a07", "cardinal"): "cardinal_dean",    # the Cardinal Dean, not old Cardinal Tomasz
            ("d01", "tomasz"): "tomasz_grown", ("d05", "tomasz"): "tomasz_grown", ("d09", "tomasz"): "tomasz_grown",
            ("d03", "pieter"): "pieter_grown", ("d06", "pieter"): "pieter_grown",
            ("d11", "jakob"): "jakob_old",
            ("d08", "sergeant"): "barra_sergeant", ("d10", "sergeant"): "barra_sergeant",
            ("d05", "sobral"): "officer", ("d10", "captain"): "officer", ("d09", "commander"): "officer_old",
            ("d02", "rauch"): "colonel"}
SKIP_MISSIONS = ["p01_revolt"]             # the engine's test bed, never voiced


def voice_of(folder, who):
    v = SAME_KEY.get((folder, who), who if who in VOICES else None)
    ref = VOICES.get(v, ("",))[0]
    return v if v and os.path.exists(os.path.join(HERE, ref)) else None


def announcer():
    """The Brood announcer's 21 lines from docs/chatterbox_todo.md's table (Lindqvist's v2 voice)."""
    out, on = [], False
    for ln in open(os.path.join(ROOT, "docs", "chatterbox_todo.md"), encoding="utf-8"):
        if ln.startswith("## "):
            on = ln.startswith("## 1. The Brood announcer")     # only its own section's table (the rest are missions)
            continue
        if not on:
            continue
        m = re.match(r"\| ([a-z0-9_]+) \| [^|]+ \| (.+?) \|\s*$", ln)
        if m and m.group(1) not in ("key", "mission") and not os.path.exists(
                os.path.join(ROOT, "assets", "voice", "announcer", "brood", m.group(1) + ".ogg")):
            out.append(("brood__" + m.group(1), m.group(2).strip()))
    return out


EMO = json.load(open(os.path.join(HERE, "emotions.json"), encoding="utf-8"))


def emotion(name, who):
    """(exaggeration, cfg) for a line: its emotion in emotions.json (no stronger than needed: a voice whose own
    exaggeration is already higher keeps it), else the voice's own and the calm cfg 0.3."""
    base = VOICES[who][2]
    tag = EMO["lines"].get(name)
    if not tag:
        return base, 0.3
    pr = EMO["presets"][tag]
    return max(base, pr["exaggeration"]), pr["cfg"]


def ref_for(name, who):
    """The reference for a line: the voice's angry one for its shout and angry lines, when it has one."""
    if EMO["lines"].get(name) in ANGRY_TAGS and who in ANGRY_REFS and (
            who in ANGRY_LATER and "--all" in sys.argv or os.path.exists(os.path.join(HERE, ANGRY_REFS[who]))):
        return ANGRY_REFS[who]
    return VOICES[who][0]


def rerecord_ids():
    """(mission id, line id) of every line in docs/chatterbox_todo.md's RE-RECORD tables (the writing passes changed
    their words, so their old takes no longer match)."""
    ids, on = set(), False
    for ln in open(os.path.join(ROOT, "docs", "chatterbox_todo.md"), encoding="utf-8"):
        if ln.startswith("#"):
            on = "RE-RECORD" in ln
            continue
        m = re.match(r"\| ([a-z0-9]+_[a-z0-9_]+) \| ([a-z0-9_]+) \|", ln)
        if on and m and m.group(1) != "mission":
            ids.add((m.group(1), m.group(2)))
    return ids


def mission_lines(redo_emotion=False, angry_only=False, all_mode=False):
    """Every line still to record, by voice; with redo_emotion, every line with an emotion instead (recorded or not:
    the owner 2026-11-22 "certain lines have no emotion at all")."""
    by_who = {w: [] for w in VOICES}
    again = rerecord_ids() if all_mode else set()
    for f in sorted(glob.glob(os.path.join(ROOT, "campaign", "missions", "*.json"))):
        M = json.load(open(f, encoding="utf-8"))
        folder = M.get("voice")
        if not folder or M.get("id") in SKIP_MISSIONS:
            continue
        for lid, L in M.get("lines", {}).items():
            who = voice_of(folder, L.get("who")) if isinstance(L, dict) else None
            if who is None:
                continue
            if all_mode:
                have = os.path.exists(os.path.join(ROOT, "campaign", "voice", folder, lid + ".ogg"))
                if have and (M.get("id"), lid) not in again and ref_for("%s__%s" % (folder, lid), who) == VOICES[who][0]:
                    continue
            elif angry_only:
                if ref_for("%s__%s" % (folder, lid), who) == VOICES[who][0]:
                    continue
            elif redo_emotion:
                if "%s__%s" % (folder, lid) not in EMO["lines"]:
                    continue
            elif os.path.exists(os.path.join(ROOT, "campaign", "voice", folder, lid + ".ogg")):
                continue
            text = str(L.get("text", "")).replace("|", ",").replace("\n", " ").strip()
            if text:
                by_who[who].append(("%s__%s" % (folder, lid), text))
    return by_who


def main():
    allm = "--all" in sys.argv
    angry = "--angry" in sys.argv
    redo = "--emotion" in sys.argv or angry
    out_name = "lines_all.txt" if allm else ("lines_angry.txt" if angry else ("lines_emotion.txt" if redo else "lines_big.txt"))
    rows = ["# The big run (docs/chatterbox_todo.md): run.bat --lines %s%s" % (out_name, " --out out_emotion" if redo else ""),
            "# A stopped run picks up where it left off. EVERY CAMPAIGN LINE IS A PLACEHOLDER (rewritten later).", ""]
    ann = [] if redo else announcer()
    total = 0
    if ann:
        rows += ["# ---- The Brood announcer, Lindqvist's v2 voice (%d)" % len(ann),
                 "[ref refs/lindqvist_ref.wav]", "[pitch 0]", "[exaggeration 0.5]"]
        rows += ["%s | %s" % r for r in ann]
    total += len(ann)
    if allm:
        rows[0] = ("# THE ONE RUN (owner 2026-11-28): every line not yet recorded, every line the writing passes changed, "
                   "and every shout / angry line of a voice with an angry reference.\n# run.bat --lines lines_all.txt --out out_all "
                   "(then send out_all back). Its first line makes Valadares' angry reference.")
        rows += ["# ---- Valadares' angry reference, made first (Chatterbox alone; keep it if it sounds right)",
                 "[ref %s]" % SEED[1], "[pitch 0]", "[exaggeration %s]" % SEED[2], "[cfg %s]" % SEED[3],
                 "%s | %s" % (SEED[0], SEED[4])]
    ml = mission_lines(redo and not allm, angry, allm)
    for who in ORDER:
        ref, pitch, ex = VOICES[who]
        if not ml[who]:
            continue
        rows += ["", "# ---- %s (%d lines)" % (who, len(ml[who])), "[ref %s]" % ref, "[pitch %s]" % pitch]
        cur = None
        cur_ref = ref
        for name, text in ml[who]:
            r = ref_for(name, who)
            if r != cur_ref:
                rows.append("[ref %s]" % r)
                cur_ref = r
            e = emotion(name, who)
            if e != cur:
                tag = EMO["lines"].get(name, "calm")
                rows += ["# " + tag, "[exaggeration %s]" % e[0], "[cfg %s]" % e[1]]
                cur = e
            rows.append("%s | %s" % (name, text))
        total += len(ml[who])
    with open(os.path.join(HERE, out_name), "w", encoding="utf-8") as fh:
        fh.write("\n".join(rows) + "\n")
    print(out_name + ":", total, "lines;", ", ".join("%s %d" % (w, len(ml[w])) for w in ORDER), "+ announcer", len(ann))


if __name__ == "__main__":
    main()
