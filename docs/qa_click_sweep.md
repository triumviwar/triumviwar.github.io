# The click sweep: every clickable thing, clicked (job qa-click-sweep)

The owner, 2026-11-28: "make a test everything, analyse everything clickable routine". This is that routine, a reusable
one: it clicks every button of the game like a hand (a real mouse click at the button's middle), walks every page the
clicks open, plays a match of each faction pressing every command card button, and reports what breaks. It was then run
in English, Portuguese and Spanish, as a computer and as a phone held sideways, and the clear, safe bugs it found were
fixed on the branch (patch note under 0.38.999).

## How to run it (one command)

```
tools/qa/click_sweep.sh --quick      # before a release: English, 1600x900, computer (about 45-60 minutes)
tools/qa/click_sweep.sh              # the whole sweep: en/pt/es x computer 1600x900 / phone 2400x1080 (6 runs, 2 at a time)
```

Options: `--parts matches,menus,veteran` (any of the three), `--runs "pt:mobile:2400x1080 es:pc:1600x900"` (any
language:device:size), `--jobs 2`, `--out <dir>`, `--no-shots`. It needs `godot` 4.7 on the PATH, `xvfb-run` and
`python3`. Each run gets its own fresh user folder (XDG_DATA_HOME under `--out`), so runs never share settings, saves or
campaign progress and never touch the owner's own. The exit code is 1 when a run found a script error or stopped early.

What comes out:

- `<out>/<tag>.json` (every click: screen, button, what it did, flags, time; every page; every flag) and `<tag>.log`;
- `docs/qa_click_sweep/report.md`: the numbers and every flag, worst first, the same problem in several runs folded to
  one line (`--quick` writes `<out>/report.md` instead and changes nothing in the repository);
- pictures in `docs/shots/qa_click_sweep/` (JPG, 1280 wide): one per screen in English, and in Portuguese and Spanish
  only the screens with a problem, so the set stays small.

A single run by hand (what the .sh does):
`xvfb-run -a -s "-screen 0 1600x900x24" godot --rendering-driver opengl3 --resolution 1600x900 --script
res://tools/qa/click_sweep.gd -- out=<dir> lang=en device=pc parts=matches,menus,veteran shots=all`.

## What it does

1. **Matches** (`parts=matches`). A skirmish on Greenhold for each faction (Crown, Clockwork, Brood) against a
   switched-off computer, rich, with every building of the faction put down by the hall and one of every unit beside it.
   Every kind is selected (a fresh pick) and **every command card button is clicked at its middle**, the HUD's own
   coordinates turned into the screen's (the phone's HUD is drawn bigger); a button that opens a page of the card
   (BUILD, research...) has every button of that page clicked too; a placement or a targeting mode it starts is moved
   over the map and cancelled with a right click. Buttons that would take the selection away (DEMOLISH, ABANDON,
   RECYCLE, SACRIFICE...) are listed but not clicked: tools/test_content_all.gd presses those. Then a mixed selection of
   every worker and of the whole army; F1-F10, F12, Tab, Space, Backspace, comma, period; a control group (Ctrl+1, 1);
   three clicks on the minimap; the in-game MENU (each button; SURRENDER and QUIT answered NO; SETTINGS over the match and
   its BACK); pause and RESUME; the autosave; and CONTINUE on the main menu.
2. **Menus** (`parts=menus`). From the main menu, the device page, the ranked page (DEV sign-in only), every campaign
   hub, the war map in its three skins and the tutorial list, every visible button of every page is clicked, the page
   shown fresh before each click (the clicks that led there are replayed from a clean state: the skirmish setup and the
   campaign page's picks and progress are put back). A click that opens a page not seen before queues that page, so
   the walk goes breadth first through Settings' tabs, patch notes, the music player, the skirmish setup and its lists,
   replays (WATCH, EXPORT...), match logs, the map editor, online rooms (the relay is pointed at a closed port, so no
   real network), world war, tournaments, the campaign hubs' rooms, war tables, briefings and mission starts. A click that
   starts a match, a lesson, a mission or a replay gets a 2-second look and a picture (once per kind), then the menu.
   Never clicked: EXIT / YES, QUIT on the main menu and links that open the browser (downloads, Discord).
3. **Veteran** (`parts=veteran`). The campaign walked again after a made-up progress that finishes every mission
   (Campaign.record on each), so every hub, room, war table pin and card is open.

For each click the sweep records what it did (opens a page, started a match, changed this page, nothing changed,
mode X on the card, refused...) and flags:

| flag | meaning | severity |
|---|---|---|
| ERROR | a script error, push_error or engine error while the click ran (message and file:line) | high |
| DEAD | a button wired to nothing | high |
| STUCK | a page none of whose buttons leads anywhere, Esc doing nothing (also: a question with no NO) | high |
| OFFSCREEN / COVERED | a button whose middle is outside the window / under another control | medium |
| HUDOFF | a card button outside the window | medium |
| CUT / OFF / SQUEEZED | text cut by its box / reaching outside the window / broken letter by letter | medium |
| NOBACK | a page with no BACK and Esc (the phone's back) doing nothing | low |
| OVERLAP / HUDOVERLAP | texts / card buttons over each other | low |
| EN | English left on screen in pt / es | low |
| SLOW | a click that took over 6 s to settle (software drawing under xvfb: about 3x a real GPU) | low |
| NOCHANGE | wired, but nothing visible changed (often fine: STOP on an idle unit, the view already chosen) | look |

How the checks work:

- Every click is a real event at the button's middle (`Input.parse_input_event`); before it, the control under the
  pointer is asked (`gui_get_hovered_control`): something else there is COVERED. An open dropdown list or a question box
  is the only thing a hand can reach while it is up, so then only its buttons count.
- "Nothing changed" compares every visible text, switch and slider, the settings file, the page and a small grey copy
  of the screen (so a map that moved or a picture that changed counts as a change).
- Esc is pressed on every page (the phone's back does the same in main.gd): a page that stays is NOBACK.
- The text checks are tools/qa_ui_audit.gd's, on every new page (only the open list or box when one is up; names that
  only show when pointed at, like the hubs' hotspots over the painting, are left out).
- English left on screen: Loc now keeps, while tools ask it (`Loc.track`), every whole text it gave out (`Loc.shown`);
  each piece of it ("a · b", two spaces, a new line) is weighed by its words: more words found only in the English
  texts than only in the translations is English. (Loc.misses, used before, also holds every piece Loc tried on the way
  to a good translation, so it said "Limbered" was missing where the screen showed "Atrelado".)
- Engine messages that only say this machine has no speech engine (the narrator asks once a run: `Parameter "synth" is
  null`) are left out.

## The numbers

RESULTS_TABLE

## What it found, and what was done

### Fixed on the branch (0.38.999)

| what | where | fix |
|---|---|---|
| SCRIPT ERROR (es run, Brood match, STOP on a Raptor): "Invalid access to property 'global_position' on a previously freed" object in worker_labels.gd (the HUD's hover) and in draw_all: the frame's cached list of labelled units kept a unit freed later in that frame (a grub morphing, a creature sacrificed) | scripts/worker_labels.gd | the cached list drops freed units before it is used; tools/test_worker_labels.gd passes |
| Esc and the phone's back did nothing in an online room (friendly room, campaign VERSUS room); on a phone the back asked "Quit the game?" | scripts/ui/multiplayer_menu.gd | LEAVE is the page's back (`main._set_back`) |
| The same on the music player (Settings > SOUND > OPEN) and the animation viewer (Settings > OTHER > OPEN) | scripts/main.gd, scripts/anim_viewer.gd | their BACK is the page's back |
| World war: SAVE & LEAVE (and Esc, the phone's back) did nothing while a computer was moving; in a war with only computers (allowed by the setup) the page could not be left at all | scripts/worldwar/ww_page.gd | pressed while a computer moves, it says "Leaving after this move..." and leaves at the next step (the war saved there); tools/test_world_war.gd passes |
| A long room title ("Los Aposentos de Valadares en la Barra", es) pushed the storyline buttons and the GO TO panel 51 px off the right of a 1280-wide screen in the Naturalist's hub | scripts/campaign/campaign_menu.gd | a long title is drawn smaller and ends with "…" if it still doesn't fit (the whole title in its tooltip) |
| pt/es: a Field Cannon's and a Mortar's state ("Limbered: the horse tows it. UNLIMBER to fire.", "Packed: it rolls...") shown in English | scripts/loc.gd | two spaces join pieces like " · " does, so the bare "%s: %s" key no longer cut the line at its colon |
| pt/es: "Pólvora 120/120 shots" on the Powder Wagon | scripts/loc.gd | the most specific key that fits wins ("Powder %d/%d shots" over "Powder %d/%d%s") |
| pt/es: "Horses here: 1 (Horsemen, Dragoons...)" on the Barracks and the Foundry | scripts/ui/hud.gd | translated before the number goes in |
| pt/es: "NO HORSE: it can't move (HARNESS one). It still supplies." | scripts/ui/hud.gd | each sentence translated by itself |
| pt/es on a computer: the order hints ("Click where to move", "Click the rally point"...) | tools/i18n/85_qa_click_sweep.txt | the "Click" wording translated (the phone's "Tap" one was) |
| pt/es: "canister" in "Set up: canister loaded" | tools/i18n/85_qa_click_sweep.txt | translated |
| The map editor: Esc did nothing; on a phone the back asked "Quit the game?" | scripts/main.gd, scripts/ui/map_editor.gd | Esc / back press its BACK (which still asks first when the map isn't saved) |
| The interface layout page (Settings > GAMEPLAY > OPEN): Esc did nothing | scripts/main.gd, scripts/ui/layout_editor.gd | its BACK carries the meta `page_back`, which `menu_back` finds when a page builds its buttons again |
| A campaign hub's hotspot under a bigger one on the painting (the Armoury's MUSTER BOOK under the Swiss captain) could not be clicked there | scripts/campaign/campaign_menu.gd | the smaller hotspot lies on top where two overlap |
| pt/es: the map editor's DECORATIONS note ("Red frame: blocks like a rock...") pushed its panel off the right of the screen | scripts/ui/map_editor.gd | the note wraps |
| pt/es: "Pistol LOADED (HOLD FIRE)" on an Officer / Cuirassier with HOLD FIRE | scripts/ui/hud.gd | each part translated |
| pt/es: the BUILD page's economy buttons ("FARM 1/2", "COG 1/2", "POWDER 0/1", "MAINSPRING 1/1") | tools/i18n/85_qa_click_sweep.txt | "FARM %d/%d" etc. translated |
| pt/es: a single Hatchling's name and its BITE line on the stats page | tools/i18n/85_qa_click_sweep.txt | translated |

Each fix was checked with a small script showing the page before and after (the hub at 1280x720: 51 px over -> 0;
the map editor's panel in pt: off the screen -> 0; Esc on each page: leaves). The two Loc changes were checked with tools/test_i18n.gd and tools/test_card_text.gd (both pass) and on the strings
above in both languages.

### Not fixed: proposals for the owner, worst first

1. **World war, the top bar (pt / es, medium).** "Ouro 784 · renda 293, manutenção 109 por estação · terras…" is cut
   by its box at 1600x900 (CUT, 483 px of text in 242). Proposal: two lines, or the gold and income only with the rest
   in a tooltip. (Not changed: it is the mode's layout.)
2. **The war map's title (es, low).** "EL MAPA DE GUERRA · Acto 2" is 6 px wider than its box and clipped: a smaller
   font from 22 letters, as the skins' long titles already get.
3. **The device page opened from Settings (low).** Settings > GAMEPLAY > COMPUTER / MOBILE opens the first start's
   page, which has no BACK and ignores Esc: the player has to choose again. Proposal: a BACK there when it was opened
   from Settings.
4. **The world war while the computers move (low, NOBACK).** Esc / SAVE & LEAVE now leave after the move under way
   (fixed above), so the sweep, looking 4 frames later, still sees the page: expected. The turn banner covers the top
   bar's buttons until it is closed: by design (the sweep no longer counts a box over the whole page as COVERED).
5. **The opening stills before a mission (low).** No BACK to the briefing: Esc skips them into the mission. A player who
   pressed START by mistake has to quit the mission. Proposal: Esc goes back to the briefing on the first still.
6. **The map editor's decoration groups (pt / es, low).** VILLAGE, CAMP, RUINS, SHRINE, SNOWCAMP, WRECK, GROVE, LUMBER,
   RIVERBANK, FORGE are English, and WATCH is shown as "ASSISTIR" / "OBSERVAR" (the replays' verb, not a watch post).
   Not translated here: "WATCH" is already the replays' key and the buttons are narrow; the groups need their own
   labels (e.g. "kit:watch" names) before they can be translated.
7. **Slow pages (low).** The PATCH NOTES page takes 7-10 s to open and the music player and animation viewer 6-8 s under
   software drawing under xvfb (not measured on real hardware; the page builds every version's entry at once).
   Proposal: build the newest 20 and a SHOW OLDER button.
8. **Map and music names stay English** in pt / es (the map picker, the music player): by design, as said in an
   earlier patch note; the sweep leaves the music's titles out of its English check, the maps' not yet.
9. **NOCHANGE lines** ("look", see the report): STOP on an idle unit, + WORKER / - WORKER (the worker is sent but only
   counts when he arrives), the view already chosen on the war map, the region already picked on the ranked page:
   fine. None of them is a dead button (no DEAD in any run).
10. **The narrator on a machine with no speech engine** (Linux without speech-dispatcher) prints two engine errors
    (`Parameter "synth" is null`) the first time it asks for a voice; the game already stops asking after that. The
    sweep leaves them out.

## Claude's choices

1. **One routine, three parts.** Matches, menus and the finished campaign are parts of one script, so the quick run
   before a release is one command; the older tools (tools/qa_ui_audit.gd, tools/qa_ui_press_all.gd,
   tools/test_content_all.gd) are kept: they check other things (every map's setup page, the content's numbers).
2. **Real clicks at the middle**, not `pressed.emit()`: a covered or off-screen button is what a player meets. Where the
   hand misses, the sweep presses the button the code's way so the walk goes on, and says so.
3. **Pages by their buttons.** Two screens are the same page when their buttons' words mostly match (Jaccard 0.72, 0.3
   for small boxes), numbers and ON/OFF left out, so a switch turned or a map picked is not a new page.
4. **Cut short on purpose**: the third and later rows of identical buttons (WATCH on every replay), more than 30 buttons
   of a long list (the map picker, the music player's songs, the animation viewer's units) and the pages of a page with
   more than 40 buttons; DEMOLISH-like card buttons; links to the browser. Each is listed in the run's JSON as skipped.
5. **A made-up finished campaign** (every mission recorded as won by its first side) for the veteran part: it opens
   everything, though the flags it sets are the defaults, so a hub talk that depends on a choice shows one branch only.
6. **Severity** is the sweep's guess (STUCK and ERROR high, NOCHANGE only "look"); the report keeps them apart so the
   owner can read the top of it only.
7. **The phone size** is 2400x1080 with `device=mobile`, clicked with the mouse (the HUD and menus take the same events;
   touch-only gestures are not part of this sweep: tools/playtest's drivers do touch).
8. **English check by words**, not by the translation tables' misses (see above): it can miss a single English word in a
   long translated line, and a made-up name never counts.
