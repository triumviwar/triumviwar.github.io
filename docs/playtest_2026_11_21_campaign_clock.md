# Playtest 2026-11-21: the campaign, the Clockmaker line (job playtest-campaign-clock)

The owner asked (2026-11-21 02:45) for players simulated with real input, playing the game for real and looking for
bugs and bad parts. This job's area: CAMPAIGN from the main menu, the Clockmaker's hubs (Hollweg's Workshop, the Guild
in Exile at Fürth, the Machine's City), every hotspot and talk, the BRASS MAP war table and the WAR MAP, and the three
Clockmaker missions played to the end: c01 The Thirteenth Hour, a02 The Fürth Line (as the guild and as the Machine),
a04 Father Ferrer's Visit; and the flags they carry on (c01 to a02 to a04, and into a07, The Council of Rome).

Branch `playtest-campaign-clock`, made from main at 0.38.106. No version bump on the branch (the merge does it).

## What was played

The drivers are in `tools/playtest/` and can be run again (`tools/playtest/run_clock.sh <driver> <WxH> key=value ...`,
it starts Godot in a virtual screen, keeps the console in `/tmp/pt_<driver>_<tag>.log` and lists every SCRIPT ERROR,
ERROR and WARNING at the end).

- Every driver starts at the MAIN MENU and plays with real input events: mouse moves and clicks (or screen touches on
  the phone layout) at the place on the screen where the button or the unit is drawn, keys (Esc, Space, F2, A), drags
  for box selection. The view is moved by clicking the minimap; orders are right clicks on the minimap or on a unit;
  buildings are placed by pressing BUILD and the building on the command card and clicking the ground (on a phone: a
  tap for the ghost and a tap to build). The game is only read, to know where things are and to check the results;
  the match runs 4 to 8 times faster (Engine.time_scale).
- `pt_lib.gd` (clicks, touches, keys, screenshots, a layout check for text off screen or cut, a list of texts that
  found no translation), `pt_match.gd` (the map: minimap, selection, orders, the command card, building, the pause
  menu, the mission's end).
- `clock_hubs.gd`: the hubs in 7 states of the story (nothing played; the Crown's prologue done; c01 done; a02 won by
  the guild; a02 won as the Machine; a04 done; everything before Rome done): the painting's hotspots hovered and
  clicked, every GO TO entry, every talk read to its end, the BRASS MAP with each mission, SOLO / CO-OP / VERSUS and
  every seat, the BRIEFING with each side and difficulty, BACK and Esc everywhere, the WAR MAP.
- `clock_c01.gd`, `clock_a02.gd`, `clock_a04.gd`: the missions, with several players: a CAREFUL one (plays to win),
  a PASSIVE one (never gives an order), a RECKLESS one (walks the hero into the enemy), for c01 a JAKOB one (sends Jakob
  alone onto the mill island) and a CHAOS one (random clicks on the map and the HUD, Esc, PAUSE / RESUME, SETTINGS over
  the match, hotkey storms, double clicks, orders off the map, QUIT TO MENU in the middle and starting again), for a04 a
  CLOSE follower (walks into the night Winder), a WANDERER (lets it go) and the careful one.
- `clock_carry.gd`: the flags carried forward: a02 started after two different c01 endings, a04 after the four
  combinations of a02's line and Jakob, a07 after a04's two answers.
- `opening_check.gd`: every mission's opening played from START with the flags its lines read.
- `online_seats.gd`: CO-OP and VERSUS from the war table to OPEN AN ONLINE ROOM.

About 60 runs in all: the hub driver 9 times (computer 1280 x 720 and phone 844 x 390; English, Portuguese, Spanish),
c01 16 times, a02 9 times, a04 10 times, the carry and opening checks, the online seats. Difficulties: c01 EASY,
NORMAL, HARD; a02 EASY, NORMAL, HARD; a04 EASY, NORMAL, HARD. Every choice both ways and by its default: c01's BELLS
(rung, quiet, default) and GATE (people, pattern, default, and no drawings), a04's BROKEN ONES (melted, kept, default).
Screenshots of every step went to `docs/shots/playtest_2026_11_21/campaign_clock/` (about 600; a chosen few are kept
in the repository as JPG, named below).

Existing tests before and after (all on main first): test_campaign, test_campaign_c01, test_campaign_a02,
test_campaign_a04, test_campaign_a07, test_war_map, test_roster_ladder: 0 failures each, before and after this
branch's changes (test_campaign_a02 checks the new refusal words, see 7). Every headless Godot run here still ends
with "Aborted" (exit code 134) AFTER its last line, a crash inside the engine while it shuts down (gdb: a null mutex in
the engine's shutdown); a script that only loads the main scene and quits does it too. So a test's exit code says
nothing here: read its last line.

## Fixed on this branch (each its own commit)

1. BUG, the campaign's openings were broken for a01, a05, a06 and a07 (commit 376f6104). An opening line written as
   {"id", "if"} (a07's Varenne, Ferrer's pattern or people, the King's bells; a05's and a06's too) reached StillShow
   raw, and its `_ready` stopped with "Invalid call 'String' constructor": the opening came up as pictures with no words
   and no SKIP / NEXT, with a SCRIPT ERROR at each step. Reproduce on main: finish a04, a05 and a06 (or set the
   progress), open The Council of Rome from the Clockmaker's war table, START. Now `Campaign.pages_before` decides
   those lines from the menu (the flags of earlier missions, the difficulty, the side), as the match does for its own
   shows. Checked by `opening_check.gd` (a05 5 pages, a07 10, c01 11, a02 4, a04 4, all with words and buttons).
   NOTE FOR THE MERGE: the Crown job (2c7952f5) and the Brood job (f0f7a5ed) fixed the same bug their own way; keep
   one of the three.
2. BUG, the war table's heading kept the hub's first name ("Hollweg's Workshop · WAR TABLE" after Nuremberg fell);
   now the hub as the story left it, "The Guild in Exile at Fürth · WAR TABLE" (c71d3d09). The Brood job fixed the
   same line the same way (164c94be).
3. BUG, the war table pushed BACK and WAR MAP under the bottom of a 1280 x 720 screen: a02's VERSUS page once a mission
   said "(won by Father Ferrer's Visit)" (the long button widened the list and squeezed the mission's panel), and a07's
   VERSUS page with its three seats. The mission buttons now wrap their words, and the picture is at least 140 tall
   (was 220) (c71d3d09). Shot `before_war_table_back_off_screen.jpg`.
4. BUG, the BRIEFING's START was cut in half under the bottom of the screen in Portuguese (a02's guild side). Its
   words now scroll (c71d3d09). Shot `before_briefing_start_cut_pt.jpg`. The Brood job made the briefing scroll too
   (11e62ef8, 6f434f23): keep one.
5. BUG, c01: Jakob killed AFTER fetching the master drawings left "[+] Jakob fetches the master drawings" ticked on
   the panel and the end screen, next to "Hollweg's drawings burned in the workshop". The drawings objective now fails
   with him (c413d385). Seen in 3 runs (Jakob dies a lot, see 21).
6. BUG, c01: Hollweg alive but caught inside the walls at the thirteenth stroke got DEFEAT "Meister Hollweg is dead".
   The defeat now says "The clockmaker did not get out" and then which it was: "Meister Hollweg is dead." or "The
   thirteenth stroke finds Meister Hollweg inside the walls." (pt, es) (c413d385). Shot `c01_defeat_trapped.jpg`.
7. UX, a02 with c01's bells kept quiet: the briefing says "Build a Light Works by the Honest One", and the button
   answered "Not in this mission." until the stop-work was fitted (the commissary's rule). A mission's deny can now
   give its reason; a02's: "The commissary forbids it until the stop-work is fitted." (pt, es) (b533c46e).
8. BUG, a02's end screens told the wrong story: the guild's victory said "The Rednitz mill burned" when the Machine's
   player simply ran out of time with the seed standing, and the Machine's victory said "The guild's tower is down"
   when it had killed Hollweg with the tower at full health. Each line now by what happened (fe03e6bc). Shot
   `before_a02_tower_down_but_standing.jpg`.
9. BUG, the end screen's main text was never filled in: a04's VICTORY read "Stopped: {riot} broken automata; lost to the
   machine: {lost_to_machine}." (a07's "{saved}" the same). Filled now; a04's words also had to change, because
   {riot} is the whole number of broken ones, not the stopped ones: "Of 15 broken automata, 13 reached the machine's
   ground." (pt, es) (fe03e6bc). Shot `before_a04_placeholders.jpg`.
10. BUG, SCRIPT ERROR spam in a04's riot: "Invalid access to property or key 'position' / 'velocity' on a base object
    of type 'previously freed'" from scripts/winder_escort.gd, 30 or more per run: Winders escorting the broken ones
    read men who had just been taken off the map by the mission's exit. Pruned at once now (fe03e6bc); no error in the
    runs after.
11. BUG, a07 gave the Machine's own pieces only for 2 to 12 automata lost at a04, but a04 can lose up to 21 (HARD 19,
    c01's gate "people" +2) and HARD lost 20 in my run: a player who lost 13 or more got fewer machines in Rome than
    one who lost 12. Now 2 to 30, as a04 counts (8dc92d82).
12. UX, the crash page ("THE GAME CLOSED UNEXPECTEDLY") always said "Your match was autosaved: CONTINUE is on the
    menu.", also after a campaign mission (missions are never saved) or the menus, when there is no CONTINUE. Now only
    when the autosave holds a match of this version (pt, es) (894eaab7).

## Found and not fixed (for the owner)

Numbered on from the fixes. Severity: CRASH, BUG, UX, DESIGN, ART.

### The hubs, the war table, the briefing

13. UX. QUIT TO MENU in a campaign mission goes to the MAIN MENU, not back to the hub you came from; a player who wants
    to try again has to click CAMPAIGN, the tab, the BRASS MAP, the mission, BRIEFING again. Proposal: back to the hub.
14. UX. No way to watch a mission's opening or ending stills again once skipped (no REPLAY in the hub or the war table;
    StillShow has no BACK either, a click or Space only goes forward). The task asked for it: it is not there.
    Proposal: a "watch again" on the war table's mission card for an opening, and the ending for a finished mission.
15. UX. A mission can't be saved and resumed: an autosave is skipped in missions (by design, main._autosave), but c01
    lasts about 25 minutes. Quitting or the phone closing the game loses the whole mission. Proposal: a save at each
    part, or at least the warning in the pause menu that leaving loses the mission.
16. UX. The side of a04 is named after the mission: "Father Ferrer's Visit", so the war table reads "Father Ferrer's
    Visit (won by Father Ferrer's Visit)" and VERSUS "YOU PLAY: FATHER FERRER'S VISIT". Proposal: name the side "Father
    Ferrer's party" or "The Visit".
17. ART. Hollweg's Workshop, in NUREMBERG, shows a great dome like Saint Peter's in Rome through its window (the hub
    painting `campaign/hub/nuremberg_room.jpg`). After the fall the hub "The Guild in Exile at Fürth", a barn, shows the
    same Nuremberg workshop and dome, only tinted blue. Shot `hub_workshop_dome.jpg`. Proposal: a barn painting for
    Fürth; no dome in Nuremberg's window.
18. UX, phone. On a phone held sideways (844 x 390) the campaign's pages are drawn at about half size: the briefing's
    words are about 8 pixels high and hard to read (the whole menu layer is scaled to fit 1280 x 720). Shot
    `phone_briefing_tiny_text.jpg`. For the menus job too.
19. UX, phone. After tapping a hotspot in the hub painting that has no person layer (THE AUTOMATON), its box stays
    lit: a phone has no "mouse left" to switch it off (seen in the screenshots; I did not confirm it on a device).

### c01, The Thirteenth Hour

20. UX. The start runs straight into "Need more supply: build a Regulator." The first tip says only "Build a Light
    Works by the Perpetual and train Clock Soldiers. Winders build and wind."; the supply is 10 of 10 at 0:50, so the
    Light Works can't train anything until a Regulator stands. A new player is stuck at the first step. Proposal: the
    tip names the Regulator, or the start leaves room for the six.
21. DESIGN. Jakob dies in most careful games: in 4 of 6 runs that sent him for the drawings at the start of Part 3, he
    was killed on the way back (120 health, alone through streets the machine hunts). Fetching them asks the player
    to escort him with the army that is also guarding Hollweg. Maybe intended (a costly errand): say so if it is.
22. DESIGN. The townsfolk count hardly depends on play: a player who gave NO order at all got 60 of 72 out (quiet
    bells); a careful player with no army at all got 63 of 72; the bells decide almost everything (rung: 113-135 of
    120-140). The build doc says this already (Claude's choice 7); confirmed by play.
23. DESIGN. The mission can be "won" (the story loss that counts) without ever destroying the mill seed, a PRIMARY
    objective: Part 2 ends by itself after 7 minutes. The end screen then lists "[ ] Destroy the seed on the mill
    island." unticked under "NUREMBERG IS LOST" in every careful run: it reads like a failure. Proposal: hide the mill
    objective when Part 3 starts (as the order and the look are), or make it optional.
24. DESIGN. "(optional) Catch one of the red machines in a net" ticks itself: the Netter the mission hands you nets
    the first turned child near the yard without an order (passive run: caught 2 s after the turn).
25. UX. The CHOICE panels (THE BELLS, THE GATE; a04's THE BROKEN ONES) show no time left and don't say which answer
    comes if you don't pick: after 90 s (50 s, 2:00) the default is taken silently. Proposal: a shrinking bar and
    "(if you don't choose: KEEP IT QUIET)". On a phone the panel also covers the objectives and half the map (shot
    `phone_choice_bells.jpg`).
26. UX. Hollweg (and Ferrer, a04) are stand-in Missionaries, so their unit card says "Missionary · Light" and "In
    danger near enemy buildings!", and Ferrer has a MOUNT button. Proposal: the role's name on the card.
27. UX. Hollweg standing in the workshop is where the turned children march in Part 2 (the CHAOS run lost him there
    with 32 soldiers elsewhere). No warning says to move him; the "Meister, you are hurt" line comes only after damage.
28. ART/UX. SETTINGS opened over the pause menu is see-through: the pause menu's words show through it ("PAUSED",
    "BACK TO THE MATCH" under the bottom edge). Shot `settings_over_pause.jpg`.

### a02, The Fürth Line

29. DESIGN. The guild's careful player lost Hollweg in 2 of 3 NORMAL games: he waits in the barn during Part 3 while
    the army goes to burn the mill seed, and the 6:00 TIDE goes past the line to him. The mill seed with its guard takes
    a long time to burn with Clock Soldiers (as the doc says, "poor at burning buildings"). It won on EASY with the
    bells rung (Portuguese and Spanish runs). Hard to say how a human fares: worth a look.
30. UX. "Hold the earthworks: 2 of 3 sorties beaten back." is ticked done when Part 3 starts on its clock with a sortie
    still out (shot `a02_hold_2_of_3_ticked.jpg`). Proposal: count the late sortie as beaten when Part 3 starts, or say
    "The line held."
31. DESIGN. As the Machine (solo pick) a plain player won in about 7 minutes: four waves of 12 to 16 constructs sent
    with ARMY at the Honest One killed Hollweg at 7:10 of the 18:00. One game only.
32. UX. Won as the Machine, the end screen says "The next mission is being written." while a04 stays locked (the
    machine's win leads nowhere). The Brood job fixed this for every mirror (6f434f23: "That is not how it went. To go
    on with the story, win it as ..."), which covers a02 once merged. Shot `a02_machine_win_being_written.jpg`.

### a04, Father Ferrer's Visit

33. DESIGN. THE RIOT can hardly be stopped: in every run 12 to 20 of the broken ones reached the machine's ground
    (EASY 10 of 10, NORMAL 12-14 of 15, HARD 20 of 21), about 45 seconds after they set off, while the party's musketeers stand in the
    town where the inspection and the night left them. The player can't know beforehand where to wait. It is never a
    defeat (counted, as the doc says), but the objective "Stop the broken automata" is then ticked done with "Lost to
    the machine: 13". Proposals: a few seconds' warning ("they are gathering on the bank") before the march, a slower
    march, or the line's gate men closer; and the objective failed (or neutral) when most were lost.
34. UX. During the night shift the Winder was "spotted" a second time while Ferrer kept six tiles away: the escort and
    the lay brothers also count ("shadow"), and the escort waits in the town the Winder walks round. Nothing tells the
    player to keep the escort away. Proposal: "Keep your men back" in the brother's line, or only Ferrer counts.
35. UX. Standing too close for good is not a softlock: the Winder waits, the dawn comes and the visit is lost with a
    clear line. Fine; the "Back off, and wait." line is said once only.
36. UX. The party shows "15/0" supply in red and "Horses: 0" in the top bar (it has no buildings): it looks like an
    error. Shot `a04_riot_supply_red.jpg`.
37. UX. A visit lost to the dusk (inspection unfinished) shows the Machine's words: "The machine's. Father Ferrer's
    report was never written. The guild's broken ones are the Machine's." Fine for VERSUS, odd for a solo player who
    simply ran out of time.

### Flags carried forward (all as written)

- c01 to a02: bells rung gives 16 Musketeers and 2 Field Cannons and the Light Works at once; quiet gives the
  commissary and no Light Works before the stop-work; Jakob in a02 only if he lived; with the drawings ("pattern")
  the Heavy Works and the Pendulum open 10 s into Part 3 (checked: the refusal changes from "Not in this mission." to
  "Needs an Escapement first.", the Heavy Works' own rule; Hollweg's "Open the Heavy Works: we will build a Pendulum"
  doesn't mention the Escapement, a small thing).
- a02 to a04: the escort is 8 after a strong line, 5 after a thin one; no Jakob if he was lost in c01 or a02 (then
  Ferrer reads the log in the barn: played, works).
- a04 to a07: the automata in Rome are 12 with the broken ones kept, 4 with them melted; a07's opening says Ferrer's
  pattern or people line by c01's gate, the King's bells line by c01's bells.
- The hubs change after c01 (the barn at Fürth), after a02 won as the Machine (the Machine's City, Hollweg's letter,
  no Hollweg), back to Fürth when a02 is won as the guild; each talk changes after each mission (all read in full in
  the logs, no "..." empty talk).

### Checked and fine

- The NEW roster cards (K1 Winder and Clock Soldier in c01, K2 Springer and Netter in a02, K3 Heavy Works and Pendulum
  in a04) come 5-8 s in. In a04 solo the player leads Ferrer's party, which builds nothing, so the K3 cards describe
  the scripted guild's pieces: harmless, a little odd.
- Pause stops the clock; SETTINGS and Esc over the match work; Esc on every campaign page goes back one page.
- The winter lights and the snow (c01, a02), the dusk and night (c01, a04), the portraits of every speaker (the
  narrators "Nuremberg" and "Fürth" and the NEW card keep initials, as designed), the stills in all three languages.
- No missing translation found in the Clockmaker's campaign pages and missions (the translation tracker in pt and es).
- Not reachable here: voices (no recorded lines for these missions yet; the game plays text without sound), music
  (no sound device in the virtual screen); resizing the window (the virtual screen ignored it).
- Not done: a real two-device CO-OP or VERSUS game (OPEN AN ONLINE ROOM was pressed and the room page looked at, see
  the online_seats run; the online job covers rooms).

## What the drivers can't do well (so the results above are read rightly)

- The careful players are simple: they build what the card's refusals ask for, send the army in one group and
  follow the objectives; they don't micro. A human will do better in fights (findings 21, 27, 29, 33 may weigh less
  for a good player, but they showed in every run).
- On the phone layout the selection is weaker (no Shift; a box only when the units fit in the middle of the view), so
  the phone runs were mostly about the screens, the choices and the dialogue, though c01 to the stroke, a02 and a04
  were all played to their end on it.
- The window could not be resized in the virtual screen, so "a phone turned round" was not tested.

## Pictures kept

In `docs/shots/playtest_2026_11_21/campaign_clock/` (JPG): see the list in that folder's `captions.md`.
