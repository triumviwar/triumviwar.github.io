# The click sweep (qa-click-sweep-2, 2026-11-28)

The owner (2026-11-28): "make a test everything, analyse everything clickable routine". A routine that presses every
clickable thing it can reach, in every part of the game, and reports what breaks; then a run of it and the safe fixes.

## How to run it

One command (needs `xvfb-run` and a Godot 4.7 binary; `GODOT=` points at it):

    GODOT=~/godot/godot tools/qa/click_sweep.sh              # everything: en/pt/es x computer 1600x900 and phone 2400x1080
    GODOT=~/godot/godot tools/qa/click_sweep.sh --quick      # BEFORE A RELEASE: every part, English, computer (~50 min)
    tools/qa/click_sweep.sh --parts menus,settings --lang pt --size phone [--depth 2] [--budget 250]
    python3 tools/qa/click_sweep_report.py /tmp/qa_click_sweep   # the numbers table and every flag, grouped

- `tools/qa/click_sweep.gd` is the routine; `tools/qa/click_sweep.sh` runs one Godot per part (a crash loses one part,
  not the run) and writes the logs and JSON to `$OUT` (default `/tmp/qa_click_sweep`); `tools/qa/click_sweep_report.py`
  sums the logs up (a Markdown table, then every flag grouped, with the runs it was seen in).
- PARTS, each runs alone: `menus` (the top menu and its OFFLINE / ONLINE groups, the device page, patch notes, music,
  layout, the art viewer, logs, the editor menu, every HOW TO PLAY page, the tutorial list), `settings` (every tab),
  `campaign` (each storyline's hub, the war map in its three skins, mission cards), `skirmish` (the setup page: 1v1,
  2v2, FFA and every option of every dropdown), `skirmish_crown` / `skirmish_clockwork` / `skirmish_brood` (a real
  match each), `editor`, `worldwar`, `tournaments`, `online` (the rooms page and ranked, no sign-in), `replays`.
- Pictures: one small JPG per new screen in `docs/shots/qa_click_sweep/` (every screen for en/computer; for the other
  languages and the phone only screens that raised a flag). A full run makes ~800 of them: the folder in git keeps 124
  (a spread of each part from the final English run, and the pt/es/phone pictures of the problems, taken BEFORE their
  fixes); don't commit a whole run's.

### What it does

- The menu parts CRAWL. A part's root pages are shown; every visible, enabled button ON TOP of the page (not one under
  a dialog's dim layer) is clicked with a REAL mouse click at its middle pushed through the viewport (so a control lying
  over it is found); an OptionButton is opened and each of its items picked (up to 10). Each press is made on a fresh
  copy of its page (the path replayed from the root). A press that opens a page not seen before (by its buttons'
  labels) is crawled in turn, two presses deep from the root, 250 presses at most a root. EXIT / QUIT and the buttons
  that open the browser (WINDOWS, ANDROID, PLAY ON THE WEB, DISCORD, DOWNLOAD, OPEN FOLDER) are never pressed. A press
  that starts a match is noted and the match left.
- The match parts start a match on Greenhold with the computer switched off and the player rich, spawn every building
  of `Defs.build_list` and every unit those buildings train (the Brood: every creature), select each kind and press
  every enabled button of its command card and of its sub pages, each on a fresh selection; a placement or a target is
  started then cancelled with Esc. Then F1..F12 and the hotkeys, Ctrl+2 / 2, two minimap clicks (a finger on the
  phone), the match menu's buttons (not SURRENDER / QUIT), pause, save, leave and CONTINUE (the save loaded again), and
  the 7.6 check below.
- Every press: a SCRIPT ERROR or engine error raised meanwhile is caught (a Logger) and tied to the button; what can be
  seen is compared before and after (texts, states, pages, popups; in a match money, page, mode, queues, orders, crews,
  the message, the card). Every new screen: the layout checks of `tools/qa_ui_audit.gd` and a way back.

### The flags

| flag | means |
|---|---|
| ERROR | a script error, push_error or engine error during the press |
| COVERED | the real click at the button's middle did not reach it (something lies over it) |
| NOOP | nothing visible changed: a dead button? (a candidate: sounds, files and native dialogs don't show) |
| NOBACK | a page with no BACK / CLOSE / SKIP button and no Esc target (the top menu excepted) |
| OFF / CUT / OVERLAP / SQUEEZED | text off the screen, cut by its box, two texts over each other, a word broken letter by letter |
| EN | pt/es: a text that reads as English (more of its words are words of the English keys than of the translations; not a name, an id, the art viewer, the match log or a music title) |
| SLOW | the page took over 2.5 s to come up after the press (wall clock under xvfb's software GL: compare, don't trust the number) |
| STALE | (match) the old command card stayed drawn and clickable after the selection changed |

## The run

Two runs on 0.38.241 (Godot 4.7, xvfb + llvmpipe on a 2-core cloud machine). Reports: `docs/qa_click_sweep/`.

**The whole matrix** (`tools/qa/click_sweep.sh`, 12 parts x en/pt/es x computer/phone, about 6 h): **3,385 screens,
16,082 presses**. The routine was sharpened during this run (what counts as a dialog, English, a phone's tap), so its
counts mix versions; `report_full_2026_11_28.md` re-reads the logs with the final rules.

| run | screens | presses | COVERED | CUT | EN (raw) | NOBACK | NOOP | OVERLAP | SLOW |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| en computer | 577 | 2,751 | 11 | 8 | 0 | 9 | 92 | 58 | 39 |
| en phone | 354 | 1,915 | 9 | 18 | 0 | 1 | 40 | 0 | 43 |
| pt computer | 636 | 2,946 | 17 | 5 | 3,307 | 3 | 59 | 0 | 56 |
| pt phone | 606 | 2,825 | 16 | 453 | 1,190 | 3 | 61 | 0 | 59 |
| es computer | 606 | 2,822 | 17 | 5 | 768 | 3 | 57 | 0 | 55 |
| es phone | 606 | 2,823 | 16 | 0 | 728 | 3 | 57 | 0 | 53 |

ERROR: none from the game in any press (one from the routine's own list, see FIXED 2); STALE: 4 before the fix, 0
after. The raw EN counts are mostly composites and names (see the false alarms); 744 distinct texts were left after the
final rules, of which the real gaps are listed below. The pt phone's 453 CUT are one line on every tournament map card.

**The final English run** (`--quick`, after all the fixes, 50 min; `report_quick_2026_11_28.md`): **606 screens, 3,058
presses**, no ERROR, CUT, OFF, OVERLAP, SQUEEZED or STALE; COVERED 17 (dialogs in front, as meant), NOBACK 3 (the device
page), NOOP 61 (all looked at: already-chosen choices, STOP on idle units, the native file dialog), SLOW 63 (starting a
match from WATCH, LOW 4).

| part | screens | presses |
|---|---:|---:|
| menus | 153 | 524 |
| settings | 138 | 511 |
| campaign | 103 | 409 |
| skirmish (setup) | 75 | 750 |
| skirmish_crown / clockwork / brood | 28 / 23 / 19 | 167 / 139 / 149 |
| editor | 4 | 36 |
| worldwar | 19 | 38 |
| tournaments | 25 | 75 |
| online | 4 | 10 |
| replays | 15 | 250 |

What the routine does not reach yet (next steps): the map editor's drawn tool bar (4 screens: its tools are drawn, not
Buttons), a world war past START THE WAR, a campaign mission in play, a real online room (no network here), the
in-match Settings' own pages; a deeper `--depth 3` run takes about twice as long.


## What was found and fixed (in this branch)

Each in a small commit on the branch; the patch note is under 0.38.999.

1. **A stale command card (the 7.6 of `docs/qa_ui_review.md`), confirmed and fixed.** The HUD rebuilds the command card
   at once after a click, a key or a touch, otherwise four times a second. A selection changed WITHOUT one (a unit of
   the selection dying, a group the game picks, a scripted pick, the picture tool's quick army -> Barracks) left the old
   card drawn AND clickable for up to a quarter of a second: measured 5-8 frames with the army's buttons on a Barracks,
   on every delay tried (0, 0.05, 0.2, 0.4 s). `Game.set_selection` now marks the card fresh whenever the selection
   really changes: 2 frames after the fix, in all three factions. (`scripts/game.gd`)
2. **`Game.set_selection` with a freed unit in its list** raised "Left operand of 'is' is a previously freed instance"
   (`e is Unit` before `is_instance_valid(e)`): freed entities are skipped first. (`scripts/game.gd`)
3. **PATCH NOTES froze the game 6-7 s** (it built every one of the ~700 versions as wrapped labels, 450 KB of text, each
   time it opened; also from the version line under the main menu): it opens with the newest 15 versions and an OLDER
   VERSIONS button that adds 40 at a time (85 ms to open, headless). (`scripts/main.gd`, new text OLDER VERSIONS pt/es)
4. **Untranslated text (pt/es)**, all through the project's i18n files (`tools/i18n/85_click_sweep.txt`, built with
   `tools/i18n_build.py`; `tools/test_i18n.gd` passes):
   - the order hints on a COMPUTER: the phone's "Tap where to move" was translated, the computer's "Click where to move",
     "Click a target or place to attack-move", "Click the rally point", "Click the enemy to lash with the tongue",
     "Click where to cast the storm / fog", "Click where new soldiers gather / workers go to work", "Click where to SCATTER
     COGS" were not (also "Tap where to cast the storm / fog");
   - the HOTKEYS page (Settings > layout) named the commands in English (Canister, Limber, Drop Here, Round Shot, Take
     Off...): it built "Round Shot" from the id with capitalize(); it now goes through `Loc.title` (`layout_editor.gd`);
   - the map editor's check line "1 PROBLEM" / "%d PROBLEMS" / "and N warnings" was glued from English pieces: whole
     phrases now (`map_editor.gd`); its decoration kinds PLANTS, RUINS, CAMP, STORES, FORGE, VILLAGE, WRECK and the
     "huge" size;
   - "Connecting..." (the online room's first status), BITE (a stat line), the building card's chip titles Soil,
     Saltpetre, Brass, Haulers.
5. **Text that did not fit**:
   - the war map's title in pt/es ("A CARTA DOS ESPÉCIMES · Ato 1", "LA CARTA DE LOS ESPECÍMENES · Acto 1") was cut: a
     size step for long titles and, once laid out, a point smaller until it fits (`campaign_menu.gd`);
   - a tournament map card's info line in Portuguese on a phone was cut on nearly every card ("4 jogadores · 110x80 ·
     clássico" 170 px in 158): its size follows its length (`tournament_page.gd`);
   - the world war's gold line in Portuguese on a computer (3 px): ends in "…" with the whole line as a tooltip
     (`ww_page.gd`);
   - the Spanish GRID hotkeys button "REJILLA (QWER/ASDF/ZXCV)": "REJILLA QWER/ASDF/ZXCV" (`tools/i18n/01_menus.txt`).
6. **Half-English card lines (pt/es).** `Loc.t` took a line like "Limbered: the horse tows it. UNLIMBER to fire.  Powder
   8/8" whole with the bare key "%s: %s" (it only split texts joined by " · " or new lines), so "Limbered" and the
   sentence stayed English and only "Pólvora 8/8" was translated. A double space now counts as a join too: the split
   and the bare key are both tried and the one leaving fewer English words wins (the rule already used for " · "). The
   cannon (limbered / set up), the mortar (packed / set up), the horse grazing, the powder wagon with no horse now read
   whole in pt/es; the words put into them: "canister", "ready" (the Dragoon's reload), "%.1f s left". (`scripts/loc.gd`)


## Problems left, by severity (proposals)

Nothing in the run crashed the game in a page or a press, and no script error came from the game's own code in any
press (the one error, `set_selection` with a freed unit, came from the routine's own list and is fixed in the game
anyway). Every part's Godot ended with "Aborted" AFTER its summary, see 1.

**MEDIUM**
1. **The engine aborts at exit** (exit code 134 after `quit()`, every part, after `Main.release_cursor_art()` too): first
   "Texture with GL ID ... leaked" / "RenderingServer::get_singleton() is null" from `~CompressedTexture2D` (a texture
   kept in a static var freed after the renderer: there are ~17 static texture caches, e.g. `game.gd _tex_cache`,
   `powder_smoke.gd _atlas_tex`, `stun_mark.gd _tex`, `vet_chevrons.gd _atlas`, `map_thumb.gd _mem`), then SIGABRT. The
   player-comforts playtest saw the same on EXIT. Proposal: clear those caches in `quit_game()` before `quit()`, then
   check on Windows whether EXIT ends clean.
2. **The AI STORY's Clockwork army lines are English in pt/es** (`ai_cw_army.gd`: "the army rests on its gears at %s,
   where the enemy's way in reaches the base", "the whole army defends the base (...)", about 25 `say()` lines formatted
   before they reach Loc, with no keys in `tools/i18n/`). Proposal: one i18n file for them (a spectator feature).
3. **A dialog without a dim layer looks clickable underneath** (the world war's "Delete this war for good?", the hub's
   talk box over the painting): the page's buttons look live but a full-screen catcher takes the click (COVERED on
   START THE WAR, the hub's hotspots). Proposal: dim the page behind a question as the main menu's AskBox does.

**LOW**
4. Starting a match is slow from the lobby's WATCH (4v4: 11-13 s under xvfb; 1v1: 3-4 s) and from REPLAYS > WATCH (2-10 s,
   growing with the replay's length): software GL, so only the comparison counts (4v4 is three times 1v1). The same
   pages on the phone run were as slow. Worth a look with tools/perf on a real phone.
5. The King's study: the WAR TABLE's and FAIRLEIGH'S LETTER's clickable regions over the painting overlap (each is
   grown to 110 x 60 at least), so part of the letter opens the war table. Proposal: grow them only where they don't
   meet another.
6. IMPORT / EXPORT (replays) do nothing on a Linux desktop without the xdg desktop portal: `file_dialog_show` is
   called (the feature says yes) but no dialog comes and nothing is said. Windows and Android are not touched (Android
   says "no file picker here"). Proposal: if the callback never comes in a few seconds, fall back to Godot's FileDialog.
   That FileDialog's own words (Save, Open a File, Path:, Create Folder...) are the engine's, English in pt/es.
7. The DEVICE page has no BACK when opened from Settings (GAMEPLAY > COMPUTER / PHONE): picking a device goes on, so
   it is not a dead end, but a BACK to Settings would be kinder.
8. The music's titles are English in pt/es (MusicTracks and the ElevenLabs pieces). Names of pieces: by design? OWNER.
9. The match log and the art viewer (Settings > OTHER) are English in pt/es: by design (the log is pasted in playtest
   reports, the viewer is a tool for the art).

**Checked: 7.6 of docs/qa_ui_review.md** (a stale command card once on the computer, after selecting the whole army then
a Barracks within 0.4 s) was real and is fixed (FIXED 1 above). The sweep checks it in every match part from now on
(the STALE flag; "7.6 check delay ...: the drawn card was the building's after N frames" in the log).


## Not problems (the sweep's false alarms, checked by hand)

The routine is careful to say "a candidate"; these were looked at and are fine:

- **NOOP** on a choice that is already chosen (the layout's STANDARD / IN USE / POSITIONS, ranked's EUROPE, the art
  viewer's current unit / animation / view, the tournament pool's ALL / BUILT-IN / YOUR MAPS with no maps of your own,
  FIND with an empty search, ADD ALL SHOWN when all are in), STOP on an idle Brood creature, a hub person pressed again
  while talking, the war map's "−" at its widest. MUTE / UNMUTE changes only the drawn speaker icon. The war map's
  view buttons (THE WORLD, BRAZIL...) did change the map (a painted sheet each): the routine did not see it in its first
  version (fixed in the routine).
- **NOOP** IMPORT / EXPORT: the native file dialog (LOW 6 above).
- **COVERED** under a dialog or the hub's talk box: the dialog is in front, as it should be (MEDIUM 3 is about how it
  looks).
- **NOBACK** on a campaign opening's stills (SKIP and NEXT lead on), the device page (LOW 7), the layout's HOTKEYS page
  (it has BACK; the routine's first version took the hotkey grid for a dialog).
- **CUT** on the skirmish lobby's faction button with its icon (the icon is drawn smaller than its file; the first
  version measured the file).
- **SLOW** on the language flags and the version line: they open PATCH NOTES (FIXED 3).
- **EN** on composite lines whose pieces are translated when drawn (Loc tries the whole line, then its pieces: the
  whole one is a "miss"), map and player names, dates, the AI's match log lines, the Godot FileDialog.

