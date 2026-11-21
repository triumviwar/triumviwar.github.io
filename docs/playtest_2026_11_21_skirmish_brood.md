# Playtest, 21 November 2026: SKIRMISH PLAYED AS THE BROOD (job playtest-skirmish-brood)

The owner (2026-11-21 02:45): "make multiple simulations of players, buttons pressed, and actually play the game ...
look for bad aspects of the game or bugs; it's very deep work." This part: skirmish as a person playing the Brood, from
the main menu to the end screen, against the Hard and OPTIMAL computers. Played on main 0.38.107 (branch
`playtest-skirmish-brood`). Pictures: `docs/shots/playtest_2026_11_21/skirmish_brood/`.

## In short

- Nine matches as the Brood against Hard (computer and phone sizes, English, Portuguese, Spanish), four kinds of
  player, and every Brood button tried by hand in the sandbox. No crash and no script error from the game.
- Five things fixed on the branch: grubs left standing forever by a HARVEST with no bodies (it killed an economy),
  the match log's first line, command card labels running into each other (Portuguese, phone), "1 eggs", and the
  useless "Attack: not now." on a rooted creature.
- Three things for the owner, which stopped the simulated player every time: getting the Mother up to fight drops
  every Rootmaw on her swamp and they stay up (finding 6); food piles up that the one Mother cannot lay fast enough to
  spend, and every step up needs spoils (7); research at a Sire stops his eggs (8).
- Smaller ones: the resource is "Biomass" and "food" at once (9), browsing maps in the setup changes the teams (10),
  SACRIFICE on all one's grubs with one key (11), a tap on the phone's hotkey bar that can become a long press (12),
  and a few view and label nits (13-23).

## How it was played

Every match was started from the main menu and played with REAL input only: mouse moves, clicks, double clicks, drags,
right-button drags, the wheel, keys, Shift and Ctrl held, and on the phone size finger taps, finger drags and two-finger
pinches (Godot's `Input.parse_input_event`, the mouse moved with `warp_mouse`). The simulated player READS the game to
decide (where its grubs are, what the command card shows, where the gold spots are, which tooltip is up) but ACTS only
through input: the command card buttons are clicked at their place on the screen, the camera is moved by clicking the
minimap or with the arrow keys, Rootmaws and Sires are placed by moving the ghost and clicking. The only thing not done
by input is the game speed (Engine.time_scale x1.5 or x2, as the skirmish has no speed control).

The drivers stay in `tools/playtest/` so all of it can be run again:

- `brood_pt_lib.gd`: the "hand" (mouse, keys, touch, the menus, the command card by its labels, pictures).
- `brood_setup.gd`: the first start (the device page, the language flags) and every option of the skirmish setup.
- `brood_play.gd`: a whole match. Four players: `careful` (a decent macro player: grubs, Rootmaws on the gold spots,
  turtles for supply, the Tyrant and Venom Sires, research, GROW, MATURE, harvest and sacrifice, defends, attacks with
  control group 1 and attack-move on the minimap), `fast` (the same plus spam: double clicks, Space, F2), `confused`
  (random clicks and right clicks, Esc, random letters, the MENU, the wheel, drags, double clicks, window resizes),
  `breaker` (Rootmaws on the enemy and off the swamp, drags out of the window, UPROOT then at once GROW / GRUB / ROOT,
  Delete on cocoons and eggs, rally drags, Shift queues, SACRIFICE on everything, Pause and F10).
- `brood_probe.gd`: every Brood button by hand in the SANDBOX (EDITOR > SANDBOX: its own +1000 BIOMASS, +200 SPOILS
  and AI: OFF buttons, pressed like a person) in four parts: `eco` (the Mother, grubs, the count, the gold spots, a 4th
  Rootmaw, HARVEST, UPROOT / ROOT, HAUL), `army` (a turtle, the Tyrant Sire in and out of the father range, Raptor eggs,
  his research, hotkeys, hold, drag-a-line, Shift queue, patrol, sacrifice, camera views, zoom), `late` (GROW to stage
  2 and 3, the Venom and Storm Sires, every creature, MATURE, the Mist Toad, a turtle on new ground), `toad` (FOG and
  MIASMA researched at the Venom Sire, Mist Toads laid, enemy Musketeers put down with the sandbox, the spells cast),
  `ui` (the top bar
  tooltips, the Pause key, the MENU, PAUSE / RESUME, SETTINGS in the match, QUIT TO MENU then CONTINUE, SURRENDER, the
  end screen tabs, COPY LOG, VIEW MAP).

Run one with, e.g.:
`xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 --script res://tools/playtest/brood_play.gd -- who=careful opp=crown map=HOLLOWFEN mins=18 ts=2`
(add `mobile` for the phone, `lang=pt` or `lang=es`, `--resolution 844x390` for a phone's landscape size).

## What was played

Nine matches against the Hard computers (and a few short ones while the drivers were made), plus the sandbox
probes. Hard OPTIMAL unless said. All from the main menu, with the skirmish setup clicked as a person does.

| # | player | against | map | screen and input | language | how long | result |
|---|---|---|---|---|---|---|---|
| 1 | careful (first version) | Crown | Hollowfen | computer 1280x720, mouse and keys | en | 12:58 | lost (see 1 and 7) |
| 2 | careful | Crown | Hollowfen | computer | en | 19:36 (time) | no result: 15,574 food unspent, the Crown maxed out |
| 3 | careful | Clockwork | Frostfang | computer | en | 13:32 | lost (army value 2,475 v 7,105) |
| 4 | careful | Brood | Greenhold | phone 844x390, touch | en | 9:41 | lost (income 4,095 v 13,247) |
| 5 | confused | Crown | Dune Sea | computer, the window resized 20 times | en | 2:31, then 8:00 | it quit to the menu with one click (2:31); 1,050 random actions, no error |
| 6 | breaker | Clockwork | Twin Fords | computer | en | 8:00 | its own UPROOT / ROOT cycling stopped all income (see 6) |
| 7 | careful | Crown BALANCED | Hollowfen | computer | en | 22:00 (time) | the Crown down to 1 unit at 19:30, its buildings kept standing; no end (see 18) |
| 8 | careful (with hunting) | Crown BALANCED | Greenhold | computer | en | 22:54 | lost (income 17,991 v 47,140; units killed 86 v 451) |
| 9 | fast (spam, double taps) | Clockwork BALANCED | Highmoor | phone 844x390, touch, pinch, two-finger pan | pt | 6:00 | no result (a short run for the phone controls; APM 464) |

Sandbox probes (every Brood button): `eco` in English on the computer, in Portuguese on the computer (twice) and in
Spanish on the phone size with touch; `army` (twice: its second run lost its way when a click picked a grub just turned
into a cocoon, a driver slip; the first run's checks all passed) and `ui` in English; `late` three times; `toad` three
times. The setup driver (every preset,
the colour and team lists, 40 maps stepped through with >, the map list) in English.

No SCRIPT ERROR, no engine error and no crash came from the game in any of these runs (the only error lines are the
engine's texture-leak notes when the test program quits, as with every tool in tools/).

## Findings

Severity: BUG (wrong), UX (works but confuses, hides or punishes), DESIGN (a rule that plays badly: for the owner to
decide), NOTE. FIXED ones have their commit on the branch.

### Fixed on the branch

1. **BUG, FIXED: HARVEST with no body near leaves the grubs out of work for good.** A HARVEST order (the button, or Q)
   on grubs with nothing to wrap around them: they stood at their spot forever, out of work, and they were not idle, so
   F1 (IDLE) and the idle count never found them either. In the first short matches against the Crown the careful player
   pressed HARVEST a few times (meaning 2 grubs, but clicks picked more) and at 4:03 14 of its 15 grubs stood
   "harvesting" nothing; the food stayed at 42 for a whole minute and the Horseman rush finished it. Fix (scripts/unit.gd, commit "a HARVEST order with no body left
   near its spot ends after 6 s"): after 6 s with nothing to wrap the order ends, the grub goes idle and WORK sends it
   back to its post. Proved by the probe after the fix: "0 of 6 grubs still out of work after 25 s".
   test_brood_controls (60 pass) and test_brood_fix3 (43 pass) still pass. The Brood computer uses the same order: its
   grubs now come back too.
2. **BUG, FIXED: every match log started with the computer's plan, not with its header.** The computers are made
   before MatchLog.begin (it names their plans) and their first lines ("[00:00] P2 Crown's plan: optimal: leans to
   Rush...") went in before "Triumviwar v0.38.107 match log", so GameName.is_log_header found no header on the first
   line of any log with a computer (seen in all 9 saved logs and in COPY LOG). Fix (scripts/match_log.gd): the header
   goes in front. New test tools/test_match_log_header.gd (fails before, passes after).
3. **BUG, FIXED: command card labels ran over each other.** At the smallest size (8) a label still too wide spilled
   over its neighbours: in Portuguese the Mother's card read "RAÍZES RÁPIDASCURA DO PÂNTANO" (QUICK ROOTS and SWAMP
   MENDING), and on the phone size more of them. Now such a label takes two lines on a taller strip
   (scripts/ui/hud.gd `_card_two_lines`). Picture: `after_pt_card_two_lines.png`; phone: `probe_eco_phone_es_03_mother_card.jpg`.
   test_hud_frames passes; test_card_text fails on the Town Hall's pt/es line lengths (87 and 85 characters), which my
   change does not touch (a text length, as on main).
4. **BUG, FIXED: "1 eggs".** The Sire's nest label said "1 eggs" (scripts/brood_new.gd; "1 egg", pt "1 ovo", es "1 huevo").
5. **UX, FIXED: "Attack: not now."** A, M, S, H or P with the rooted Brood Mother (or another rooted creature) picked
   said "Attack: not now." / "Hold: not now." (seen 5 times in match 1), which tells nothing. Now: "Rooted: UPROOT it
   first." (pt and es too). New test tools/test_rooted_key_note.gd.

### For the owner: the Brood plays badly here

6. **DESIGN (the biggest): getting the Mother up to fight takes the whole economy down, and it does not come back by
   itself.** The Mother is the defence and rooted she cannot attack, so against a push she must UPROOT (the computer
   does the same). But her swamp recedes a ring a second as soon as she gets up, and every Rootmaw on it loses its
   swamp and uproots: in the probe, 3 rooted Rootmaws became 0 within 14 s of UPROOT (`probe_eco_pc_pt_14_mother_uprooted_14s.jpg`).
   When she roots again the Rootmaws stay up: they have to be found, picked and ROOTed again one by one, and not too
   soon (her swamp grows back at a walk; ROOT on it right away says "No swamp here"). In matches 1, 3 and 4 the careful
   player had to get her up when the enemy reached her, and its Rootmaws went down with her swamp ("A Rootmaw lost its
   swamp and uprooted."); the breaker, which cycles UPROOT and ROOT, earned nothing for 8 minutes
   (food 14 from 1:00 to 8:00 with 8 grubs). Proposals: the swamp lingers while she is up (say 30-60 s, or as long as
   she stays within her ring), or the Rootmaws root again by themselves on their own spot when the swamp is back, or
   they "wait" (stop feeding) instead of uprooting while the swamp is gone for a short time.
7. **DESIGN: the bank piles up; laying is the limit, and spoils are the brake.** With 9-10 Rootmaws the food cannot be
   spent: match 2 had 15,574 food unspent at 19:35 (stage 2, spoils 0), match 7 had 8,765 at 21:50, match 3 4,490 at
   11:13 (its end screen: income 14,198, spent 10,630). Every egg comes from the one Mother, so the levers that raise
   laying (stage 3: 75 spoils; the Venom and Storm Sires: 25 and 50 spoils; research: 15 spoils each) all need spoils,
   and spoils come only from bodies (HARVEST) or from offering up one's own creatures. A player who is ahead in food
   simply cannot turn it into an army ("a big bank must not be a win button" in reverse: here the bank is useless).
   For the owner: is that the intended feel? If not: a food price for something that raises laying, or spoils from
   food at a poor rate, or a visible "your Mother lays at most N eggs a minute" so the player understands the ceiling.
8. **DESIGN: research at a Sire stops his eggs.** "The Tyrant Sire is researching: no eggs of his line until he is
   done." PACK HUNT (35 s) or BIGGER CLUTCH (40 s) means no Raptors for that long; in match 3 the careful player's
   Raptor eggs were refused three times at 6-7 minutes. The tooltip says it, but it is easy to miss and costly against
   a rush. (The Crown's Armoury research does not stop its Barracks.)
9. **UX: the resource has two names.** The top bar and every refusal say BIOMASS ("Not enough biomass.", the tooltip's
   title "Biomass: 326"), while the tooltip's own text and every other line say FOOD ("Food pays for everything",
   GROW "300 food", "3,000 food in a 8-tile circle", "food pile", BIGGER CLUTCH "75 food for three"; Portuguese
   "3000 de comida no chão" under "Biomassa"). The end screen calls it "Gold spent" for the Brood too, and its
   "Structures built / razed / lost" are always 0 for the Brood, whose Rootmaws, turtles and Sires are creatures
   (match 8: "Structures built 0" after 10 Rootmaws and 12 turtles: `keep/w2_end.jpg`). Pick one word
   (`keep/probe_ui_pc_03_tip_top_3.jpg`, `probe_eco_pc_pt_09_rootmaw_ghost_on_gold.jpg`).
10. **UX: browsing the maps changes the match.** In the setup, stepping through the maps with > reshapes the players to
    each map: past a 4v4 map the 1v1 became 8 players and the Hard Crown OPTIMAL picked as the enemy moved to MY team
    (teams 1,1,1,1,2,2,2,2); stepping on to a random pool keeps the 8. Someone who looks through the maps and presses
    START gets a different game than the one set up. Proposal: the arrows only change the map; a map that can't hold
    the players shows the problem line (as the START button already does).
11. **UX: SACRIFICE on workers has no second step.** The confused player offered up all 5 starting grubs at 2:01 with
    one key (C on the grub card: it was a random letter): the economy was gone. Offering up grubs is useful (spoils), but
    a whole selection of workers on one key is a big mistake to make by accident. Proposal: a confirm (or a second
    press) when the selection holds more than a couple of grubs.
12. **UX (phone): a quick tap on the hotkey bar can become a long press.** The bar's hold is measured by the wall clock
    (HotkeyBar.release: held > 0.45 s sets the group or saves the view); in the phone runs, short taps came out as "Group
    8 set (2)", "Grupo 4 definido (5)" and "View F9 saved" (the test machine ran at 10-20 frames a second, so a slow
    frame fell inside the tap). On a slow phone the same overwrites a control group without warning. Proposal: count a
    hold only after a few frames as well as 0.45 s, or flash the group button "SET" for a moment so the player sees it.
13. **UX: the camera starts with the Mother's egg line under the top bar** (`keep/start_greenhold.jpg`: the
    "Eggs 5/10 ..." line over her is behind the timer). Start the view a little lower.
14. **UX: a Sire's "N eggs" label lies on the Mother** when he nests just south of her, and "0 eggs" stays over an idle
    Sire all game (`keep/c2_12_t10.jpg`). A Barracks shows nothing when its queue is empty: the same for him?
15. **UX: the view can go far below the map.** At the bottom edge three quarters of the screen can be black void
    (`keep/c2_18_t19.jpg`, after a click low on the minimap and the arrow keys).
16. **UX (phone): the camera tabs over the hotkey bar show F4-F10**, keyboard keys a phone does not have
    (`keep/careful_brood_phone_05_t03.jpg`).
17. **NOTE: several toasts say "Tap" on a computer** ("Tap where the hatchlings go.", "Tap where her new grubs go to work.",
    and others in hud.gd and cw_units.gd).
18. **DESIGN/NOTE: a beaten Crown kept the match going.** In match 7 the Crown was down to 1 unit at 19:30, with my
    80-90 supply of Raptors, Challengers and Spitters inside its base; by 22:00 its buildings still stood and the match had
    not ended. Raptors (6 damage) are slow against buildings and Brutes need stage 3 (75 spoils, see 7). The "beaten" rule
    needs the side to have no means either.
19. **NOTE: no game speed in a skirmish.** Only the sandbox has SPEED. A long macro game against the computer can't be
    sped up.
20. **NOTE: the Pause key does nothing**; pausing is MENU > PAUSE (P is PATROL). A Pause/Break or F10 key would help.
21. **NOTE: QUIT TO MENU has no confirm** (one click from the MENU; the confused player left the match that way). It is
    safe: CONTINUE on the main menu brought the match back exactly (clock 29.3 s -> 30.2 s, the same grubs, Rootmaws, food
    and stage).
22. **NOTE (pt): a gender slip.** "Um Tartaruga-Montículo saiu do casulo, enraizado." (the turtle is feminine: "Uma ...,
    enraizada"); the one Portuguese line serves every creature ("Um %s saiu do casulo, enraizado.").
23. **NOTE: tedium in the late game.** Each spent Rootmaw ("A Rootmaw's ground is spent: UPROOT it and root it on fresh
    ground") and each Rootmaw dropped by the Mother's swamp (6) must be moved and rooted by hand, one by one.

### What works well (checked by hand)

- The count: ROOTMAWS 1/3, 2/3, 3/3 on the Mother's card (and n/2 on a rooted Mound Turtle's) is right, its tooltip
  explains the 3 and the 2; a 4th Rootmaw near the others is refused with the reason ("Too close to another Rootmaw's
  ground: their circles may not overlap.").
- The gold BEST ROOTMAW SPOTS: the ghost on a spot says ROOT HERE and "3000 food on the ground"; three Rootmaws on the
  spots rooted at once.
- The father range: the ring shows, the ghost out of it is red ("OUT OF RANGE") and the click is refused with
  "Out of range: he must nest within 7 tiles of the Brood Mother."; in range the lure grows and the Sire comes.
- Eggs, the Sire's nest, hatching, Raptors (4 eggs -> 8 Raptors), Spitters, Hatchlings, the Mist Toad, GROW to stage 2
  and 3 (45 s and 60 s), the Venom and Storm Sires, MATURE (a Tyrant Challenger), HAUL and ROOT again, SACRIFICE (+15
  spoils), HARVEST autocast by right-click, a Mound Turtle on new ground.
- Controls: F1 IDLE, F2 ARMY, Ctrl+1 and 1, H, P + click, right-button drag-a-line, Shift-queued moves, Shift+F5 / F5
  views, the wheel zoom, double click, minimap click and A + minimap click.
- The match menu (PAUSE, RESUME, SETTINGS over the match, SURRENDER with its confirm, the end screen and its three
  graphs, COPY LOG (6,073 characters), VIEW MAP), the three languages' toasts, and 1,050 random actions plus 20 window
  resizes without an error.
- The phone: a pinch zooms (1.50 -> 2.60 -> 0.73), a two-finger drag pans, a one-finger drag box-selects (DRAG: BOX),
  the PLACE button confirms a ROOT ghost, a double tap picks every grub on the screen.
- The Mist Toad: FOG and MIASMA are refused on its card with "Research FOG at the Venom Sire first." until researched
  there (the toasts "Fog Bank researched: ..." and "Miasma Cloud researched: ..." say what they do); FOG was cast on the
  enemy by a click on the card and the map (`probe_toad_pc_06_toad_fog.jpg`). MIASMA and TONGUE were on the card, but
  the two toads died to the four Musketeers before they were tried: not checked by hand.
- No sprite was seen drawn wrong (extra tails, limbs) in play; the HALLUCINATED SPRITES AUDIT is its own job.

## Did the simulated player win?

No, in eight matches against Hard. Its best was match 7 (the Crown on BALANCED): it held the Horseman rush, reached 9-10
Rootmaws, matured Challengers, and by 19:30 the Crown was down to 1 unit with its buildings still standing, and the match
ran out at 22:00 (finding 18). Against OPTIMAL it lost to the Crown (12:58), the Clockwork (13:32) and the Brood mirror on
the phone (9:41), and survived the Crown to 19:36 once. Part of that is the simulated player: it attacks with Raptors
into Musketeer lines (match 8: 86 killed for 451 lost), it offers up too many grubs for spoils, and it has no micro. But
the same three walls stopped it every time, and they are the game's (findings 6, 7 and 8): getting the Mother up to
defend drops the Rootmaws; food piles up that the one Mother cannot lay fast enough to spend; and spoils, which every
step up needs, come only from bodies and sacrifices. A person playing well would hit the same walls later, not avoid them.

## Pictures

All in `docs/shots/playtest_2026_11_21/skirmish_brood/` (JPEG, named `<player>_<against>_<screen>_<n>_<what>`; the
probes `probe_<part>_<screen>[_<language>]_<n>_<what>`); `keep/` holds the ones quoted above from runs whose names were
used again later.

## Tests run

Before and after the fixes: test_brood_controls (60 pass), test_brood_fix3 (43 pass), test_hud_frames (18 pass),
test_card_text (fails on the Town Hall's pt/es lengths, not touched here), the two new tests
(test_match_log_header, test_rooted_key_note).

## What the drivers can't do (for whoever runs them again)

- They play at x1.5-x2 game speed on a software renderer (10-50 frames a second); timings of taps are not a real phone's.
- A finger drag does not scroll a list on a machine with no touch screen (Godot's lists listen for it only there), so
  on the phone size the drivers scroll lists with the wheel.
- The simulated player is a macro player with no micro; it is not a measure of balance (see "Did the simulated player win?").
- Clicks on moving grubs sometimes pick a neighbour; the drivers check what got picked and try again, and they don't
  report that as a finding.
