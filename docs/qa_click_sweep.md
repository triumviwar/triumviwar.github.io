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
  languages and the phone only screens that raised a flag).

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

<!-- NUMBERS -->

## What was found and fixed (in this branch)

<!-- FIXED -->

## Problems left, by severity (proposals)

<!-- LEFT -->

## Not problems (the sweep's false alarms, checked by hand)

<!-- FALSE -->
