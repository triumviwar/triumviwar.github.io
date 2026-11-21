# Playtest, 21 November 2026: Skirmish played as a human, the Crown

Job `playtest-skirmish-crown`, one of the owner's eight playtest jobs ("simulations of players, buttons pressed, actually
play the game"). Played on 0.38.106 (main), fixes on branch `playtest-skirmish-crown`. Pictures in
`docs/shots/playtest_2026_11_21/skirmish_crown/`. The drivers stay in `tools/playtest/` and can be run again.

## How it was played

Every driver starts at the MAIN MENU and acts only through real input fed to the window: mouse moves, clicks,
double clicks, drags, the wheel, keys with Ctrl / Shift / Alt, and on the phone touches, drags, two-finger pinches and
long presses. The "player" may read the game's state to decide what to do (where a HUD button is drawn, where its
labourers stand, which spot is free), but never calls the game to act. Engine.time_scale was raised to 2-4 to save
time. Godot 4.7 under xvfb, at 1280x720 (computer) and at 844x390 and 1600x720 (phone, touch only).

`tools/playtest/pt_base.gd` (the input layer) and `pt_setup_util.gd` (the setup screen), then the players:

- **pt_crown_player.gd, the "decent player" who tries to win.** Sets up the match through the setup screen, then plays
  a build order with the mouse (labourers, Cottage, Farm, Barracks, Powder Mill, an expansion at the gold spot, Foundry,
  more Barracks, Armoury, Church), keeps its farms and mill crewed (F1 idle workers, right-click), trains through F3
  (MAKE), sets rally points, puts the army in group 1, attack-moves through the minimap, comes home to defend.
  `mode=2v2` and `mode=ffa4` give 4-player games.
- **pt_card_cover.gd, every button on every Crown card.** A SANDBOX match (EDITOR > SANDBOX; its own panel gives gold
  and powder and turns the enemy computer off, as a player would). A labourer group builds every Crown building (a
  wrong spot first, on top of the Town Hall), a palisade dragged, a gate in it, a palisade with Shift-clicked corners,
  then every button of every building and unit card is hovered (its tooltip read) and pressed once, then DEMOLISH
  (twice) and ABANDON.
- **pt_specials.gd, the special buttons used for real:** the Horse Breeder (HORSE, the CAVALRY CHARGE), the three
  musicians trained and stood together (SELECT BAND, a SOLO, Ctrl+SOLO), the Field Cannon (UNLIMBER, CANISTER, ROUND
  SHOT, LIMBER), the Mortar (DEPLOY, Ctrl+A on the ground), ARM WITH POWDER off and RELOAD, the balloon (LOAD a
  Musketeer, fly, UNLOAD).
- **pt_controls.gd, every control of a computer player**, each a pass/fail check: click, Shift-click add and drop, Esc,
  Ctrl-click and double-click for a type, the box (units only, never a building), groups (Ctrl, Shift, Ctrl+Shift,
  recall, double tap to centre), right-click move, Shift queues, S, H, M, A, P, Esc, the right-drag line, the minimap
  (click, drag, right-click order), arrow keys, edge scroll, wheel zoom, Space, Shift+F5 / F5 views, F1 / F2 / F3, a
  card letter, Enter chat, the MENU (PAUSE, clock stops, RESUME, SETTINGS over the match, Esc back), QUIT TO MENU and
  CONTINUE (clock, units and groups come back), SURRENDER, COPY LOG.
- **pt_phone.gd, the phone, touch only:** tap, double tap, one-finger box, long press (move without fighting), pinch
  in and out, two-finger pan, DRAG: BOX / PAN, the minimap, a card tap, a long press on LABOURER (automatic training),
  hold a group to save it and tap it, a building placed by tap and tap again, the "?" help, quick chat, the menu.
- **pt_lang.gd, the same screens in Portuguese and Spanish** (setup, HUD, BUILD page with a tooltip, a refused spot,
  Barracks and Foundry cards with a tooltip, the menu, the end screen).
- **pt_chaos.gd, the player who tries to break it:** double presses, Esc while a page changes, every preset, 7-8
  players, every dropdown of a row opened and Esc'd, the map arrow 30 times, players removed with ×, START pressed
  twice, then 220 random clicks / right clicks / keys / Shift and Ctrl clicks / drags (some leaving the window) / wheel
  turns across the whole screen and the HUD, the window resized, the menu opened while placing a building, QUIT TO
  MENU while placing, CONTINUE pressed twice, Esc spam, F11.
- **pt_exit.gd / pt_exit0.gd:** EXIT from the main menu, before and after a match.

Run: `xvfb-run -a -s "-screen 0 1280x720x24" godot --rendering-driver opengl3 --resolution 1280x720 --audio-driver Dummy
--script res://tools/playtest/<driver>.gd -- out=<folder> [device=mobile] [lang=pt] [opp=BROOD plan=OPTIMAL mins=22
speed=2.5 mode=2v2]`. Every step prints `PT ...`; `PT FINDING`, `PT CHECK ... FAIL` and SCRIPT ERROR lines are the
things to look at.

### The matches

| # | Setup (all through the setup screen) | Map | Result |
|---|---|---|---|
| 1 | You (Crown) v Hard Brood, OPTIMAL | Greenhold | lost at 12:38 (the Brood earned twice as much) |
| 2 | You v Hard Brood, OPTIMAL | (random 1v1) | lost at 11:58 |
| 3 | You v Hard Crown, OPTIMAL | (random 1v1) | still on at 22:05, a draw (both alive) |
| 4 | You v Hard Clockwork, OPTIMAL | Glimmerdeep | **won at 15:23** (106 kills for 32 losses) |
| 5 | 2v2: you + Hard Crown v Hard Clockwork + Hard Brood | Whitecap Pass | lost at 12:25 |
| 6 | You v Hard Brood, OPTIMAL (the improved player) | (random 1v1) | lost at 13:33 (Raptor raids from 4:30 on) |
| - | Easy Crown (controls), Easy Brood (phone x2), Easy Clockwork / Brood in the sandbox (cards, specials, pt, es), Hard Clockwork (chaos) | several | (not played to the end) |

About 14 matches started from the main menu, 6 played to the end; 3 screen sizes; English, Portuguese and Spanish.

**No game SCRIPT ERROR in any run**: not in the matches, not in the 220 random inputs, not in the card coverage. The
only errors in the logs were my drivers' own while I wrote them, and the exit problem (finding 8).

## Findings

Severity: CRASH, BUG, UX (works but confuses or wastes the player's time), DESIGN (a question for the owner), ART.
FIXED means a commit on this branch; PROPOSAL means left for the owner.

### Fixed on this branch

1. **BUG / ART, the command card's labels ran into each other.** At the Foundry, OBSERVATION BALLOON was too wide even
   at the smallest size and was drawn across MORTAR and POWDER WAGON ("MORTAROBSERVATION BALLOPOWDER WAGON"). The same
   happens to long words in pt/es (ARMAR COM PÓLVORA). Now a label that still doesn't fit has its first words cut
   ("OBS. BALLOON") and then ends in "…". Commit a36cb7d1. Pictures `before_foundry_card_labels.png`,
   `after_foundry_card_labels.png`.
2. **BUG, clicking a building in a crowded base selected the wrong one.** The game asked the buildings in the order they
   were built, so a click on a Barracks' ground under a newer building's roof, or a building's picture over an older
   one's footprint, picked whichever was built first (my player clicked a Barracks and got the Foundry; a Horse
   Breeder and got the Powder Mill). Now of the buildings under the click the one drawn in front wins. Commit
   67f63389. (Units still win over buildings, as before.)
3. **BUG, the match log did not start with its header.** The computers start a moment before the log's header is
   written, so a skirmish log began "[00:00] P2 Crown opens with a Powder Mill (Musketeers)" and the
   "Triumviwar v0.38.106 match log" line came after it. Reports pasted by the owner are recognised by that first line
   (GameName.is_log_header). Now the header is always first and the computers' early lines follow it. Commit b4999dfb.
4. **BUG, pt/es: half-English tooltips on the train buttons.** A unit's train tooltip in Portuguese read "[Leve] Light
   line infantry: 10 shots (1 powder each, ...)": the tag and the text were joined before translation, so no
   dictionary entry matched. Each piece is now translated on its own (the "Comes out with ..." line and the band's note
   too). Also the BUILD page's "POWDER 0/1" (the first word of "Powder Mill" with the count) stayed English in pt/es:
   it now takes the first word of the translated name ("MOINHO 0/1", "MOLINO 0/1"; English unchanged). Commit 2271373c.
   Pictures `before_pt_tooltip_english.png`, `after_pt_tooltip.png`, `before_pt_build_page_powder.png`.
5. **BUG, Esc on an open dropdown left the whole setup page.** On the skirmish setup, opening any dropdown (player,
   faction, colour, plan, team, map) and pressing Esc (or a phone's back button) closed the list AND went back to the
   main menu. Now Esc closes the list only. Commit e50ee7ff.
6. **BUG (text), the Armoury's card line said "guns and the charge"**: the Cavalry Charge is researched at the Horse
   Breeder now (the Charge package). It now says "guns and the band" (the Armoury trains the musicians), in en/pt/es.
   Commit 363a8ed9. Picture `before_armoury_text_the_charge.png`.
7. **BUG (test), the Town Hall's card line was over 80 characters in pt and es** (tools/test_card_text.gd failed on
   main). Shortened ("... perto.", "... cerca."). Commit 951aa8e4.
8. **CRASH (on exit), partly fixed.** EXIT on the main menu (and closing the window) ended the program with an abort
   (exit code 134) on the test machine, every time, after "ERROR: Texture with GL ID of 23: leaked 5460 bytes" and
   "RenderingServer::get_singleton() is null": the custom cursor's picture was held by Input past the renderer. EXIT
   and the window's close now let go of the cursor first, and that error is gone (commit 9686acde). **The abort itself
   is still there** on this machine: a segmentation fault inside the engine's shutdown (no symbols in the official
   build, so not traced). It may be this headless Linux machine only (xvfb, software OpenGL). PROPOSAL: check on the
   owner's Windows build and phone whether closing the game reports a crash (a Windows "stopped working" box, or the
   crash page on the next start: it should not show, the running marker is removed before the abort).
9. (code comment) Controls' header said Shift+number "adds the group to the selection"; it adds the selection to the
   group (StarCraft 2's way, as HOW TO PLAY says). Comment fixed, commit 54281c9d.

### Not fixed: proposals for the owner

10. **BUG (seen once, not traced), a building site that stayed a ghost.** In the specials run the labourer group
    (group 2, four labourers) placed an Armoury, then at once a Foundry next to it without Shift. The Foundry was built;
    the Armoury stayed a see-through ghost for more than two minutes with its price paid: the labourers did not take it
    up after the Foundry (the "next unfinished site within 8 tiles" rule, Game.next_site) and the sweep that cancels a
    Crown ghost nobody is coming to (Game.sweep_ghosts, all of its cost back) did not remove it either, probably
    because `_crown_chain` still counted it as part of a chain. To reproduce: sandbox, group of labourers, place
    Armoury, then Foundry 3-6 tiles away (no Shift), wait. PROPOSAL: a look at `_crown_chain` (a chain whose root is
    finished should let its ghosts go or be taken up).
11. **UX, a new Powder Mill (and Farm) gets no workers by itself, and nothing says so.** In matches 1 and 2 my player
    had 0 powder for most of the game while the Musketeers came out with bayonets only: the Mill stood at "POWDER
    MAKERS 0/6" and its builders went off to other work. The label is there
    but easy to miss. PROPOSAL: a one-time toast "Your Powder Mill has no workers: right-click Labourers onto it (or
    + WORKER)", or the builders of a new Mill/Farm stay on as its crew.
12. **UX, S (STOP) cannot stop a worker.** S on labourers turns them straight back to gathering (automatic WORK is on),
    so a player who stops one to keep him free has to know to turn WORK off. PROPOSAL: S on workers leaves them idle
    until the next order (WORK resumes on its own after, say, 20 s), or a toast pointing at WORK.
13. **UX, no keyboard key opens the menu or pauses a skirmish.** Esc only cancels or clears the selection; F10 is a
    camera view; P is patrol. The MENU button is the only way to PAUSE, SURRENDER or reach SETTINGS. PROPOSAL: the
    Pause/Break key (and F12, or F10 if the camera views move) pauses / opens the menu.
14. **DESIGN, no game speed and no save slots in skirmish.** The task asked to test "speed controls" and "save
    mid-match and load it": a skirmish has neither. Only the SANDBOX has SPEED x1/x2/x4, and saving is the one
    autosave that QUIT TO MENU leaves for CONTINUE (it worked: clock, units and control groups came back). A new
    skirmish replaces it. PROPOSAL (owner's call): a game speed in the skirmish setup (single player only), and a few
    named save slots.
15. **UX, a click on an empty group or camera tab saves silently.** A misclick on an empty group button (or an empty
    F4-F10 tab) stores the current selection (or view) with only a toast ("Group 2 set (1)." / "View F7 saved."). This
    happened to my players twice when a click meant for the map or the menu landed on the bar. Minor; the
    tooltip explains it. PROPOSAL: only Ctrl+click / long press saves; a plain click on an empty one does nothing.
16. **UX, "Blocked." is the whole message for a refused spot** (in pt "Bloqueado."). It doesn't say what blocks it
    (another building, cliff, too far from the hall). The farm refused next to another hall said "Must be near your
    Town Hall." which is clear. PROPOSAL: "Blocked: a building is in the way." / "... the ground is not level." etc.
17. **UX, the skirmish setup with many players.** At 7-8 players (1280x720) the + ADD PLAYER row sits half under the
    note at the bottom of the list (it scrolls, but looks cut). Removing YOU with × is allowed (the START button
    becomes WATCH) and the 1v1 preset does not bring YOU back: the player has to find YOU in the first row's list.
    Picture `setup_seven_players_add_hidden.png`.
18. **UX (phone), the HUD takes a lot of a landscape phone.** On a phone (logical 1558x720 / 1600x720) the hotkey bar,
    selection panel and card take about 37% of the height, and the selection panel is mostly empty space; at a low
    resolution (844x390) the card labels and the selection text are tiny. Everything worked by touch (16 of 17 checks
    passed; the one fail was my test's own count). PROPOSAL: a compact phone layout (selection panel shorter, card
    beside it). Pictures `phone_844x390_auto_train.png`, `phone_1600x720_pt_placing.png`.
19. **UX, the view can go far past the map's edge** (CAMERA_MARGIN_TILES plus the room for the HUD): at the start the
    camera in the corner shows a wide black band at the top and left (about 180 and 235 pixels at 1280x720). Intended
    (units at the edge are never under the HUD), but in a corner start it wastes a lot of a small screen. Picture
    `camera_margin_and_group_tooltip.png`.
20. **ART, small things seen in passing.** The worker label of a spent Farm reads "spent  0%" in lower case next to
    the upper-case "POWDER MAKERS 6/6"; world labels (a farm's "FARMERS 1/8") are drawn under the top bar when the farm
    is at the top of the screen; the in-match MENU panel is see-through and the top bar's text shows through its title.
    Units behind buildings are drawn as team-coloured silhouettes (the x-ray): intended, but at first look they read as
    a red smudge on the building (`cannon_card_occluded_units.png`).
21. **DESIGN (balance, not changed), what the Hard computers did against a simple scripted player.** My player is a
    plain macro script (no micro at all): it beat Hard Clockwork OPTIMAL at 15:23 (the Clockwork threw its whole army
    at my musket line and cannons at 7:30 and lost it, 106 kills to 32), drew Hard Crown OPTIMAL at 22:00, and lost to
    Hard Brood OPTIMAL three times (it earned about twice my income). In the 2v2 my Hard Crown ally earned 5,320 to the
    Clockwork's 17,953. This matches the win-rate studies: the Crown computer is the weakest, and the Clockwork
    computer is easy to bait into a prepared defence.
22. **DESIGN (colours), FITS MAP colours vs the faction colours.** With FITS MAP the Crown came out green and the Brood
    red in the 2v2, the Crown red in match 1 (the owner decided Crown purple, Clockwork red, Brood green). Players will
    read colour as faction. PROPOSAL: FITS MAP keeps each faction's own colour family when it can.

### What worked well (nothing to fix)

- Every control check passed: selection (click, Shift add/drop, Ctrl / double click for a type, box takes units only),
  groups (set, recall, double tap centres, Shift adds), orders (right click, Shift queue of 2, S, H, M, A, P, Esc), the
  right-drag line (the four labourers spread along it), the minimap (click, drag, right-click order), arrow keys, edge
  scroll, wheel zoom (1.5 -> 2.1 -> 1.07), Space, Shift+F5 / F5, F1-F3, a card letter (S trains a Labourer), chat,
  PAUSE (the clock stops) / RESUME, SETTINGS over the match with Esc back, QUIT TO MENU and CONTINUE (clock within 1.3
  s, units and groups back), SURRENDER with its confirm, COPY LOG.
- Every Crown building was built by labourers placed with the mouse, every train and research button pressed, every
  unit card's buttons pressed; refusals always came with a reason ("Needs a Cottage first.", "Queue is full.", "No
  free horse of yours within 8 tiles.", "They are all full."). DEMOLISH asks twice ("Press DEMOLISH again to pull it
  down."), ABANDON gives the whole price back. The palisade by drag (6 pieces) and by Shift-clicked corners, a gate in
  a palisade, LOCK on the gate.
- The specials: UNLIMBER / LIMBER and CANISTER / ROUND SHOT switch and their buttons follow; the Mortar DEPLOYs and
  takes Ctrl+A; the band forms when the three stand together (SELECT BAND then works) and a second SOLO is refused
  while one plays; the balloon LOADs a Musketeer and UNLOADs him; ARM WITH POWDER's toast explains it.
- The phone: tap, double tap, one-finger box, long press move, pinch, two-finger pan, DRAG: BOX / PAN, minimap tap,
  card taps, long press for automatic training ("Training Labourer automatically."), hold a group to save it, tap and
  tap again (or PLACE) to build, the "?" help, quick chat, the menu: all worked, in English and Portuguese.
- The chaos player found no crash: 220 random inputs, drags off the window, menus during placement, QUIT while
  placing, a double CONTINUE, a double START.

## Not covered (other jobs or no time)

- Online rooms, spectators, ranked, the web build (job playtest-menus-online); the tutorial, editor and replays (job
  playtest-tutorial-editor). WATCH REPLAY on the end screen was seen but not played.
- The FFA and 3v3/4v4 presets were set up and looked at, not played; only one 4-player game (2v2) was played to the end.
- A real phone or the Android APK (this was touch input on the desktop build at phone sizes).
- An unconfirmed oddity: once the FLINTLOCK refit button's tooltip read "Refit: Socket Bayonet"; the card had just
  changed under the mouse (one man left to be refitted), so it is probably a stale hover, not a wrong text.
