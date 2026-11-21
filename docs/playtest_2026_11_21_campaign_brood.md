# Playtest 2026-11-21: the campaign, the Naturalist line

Job playtest-campaign-brood, branch `playtest-campaign-brood`, made from main at 0.38.106.

## What was played

The Naturalist line was played from the main menu by "players" driven by real mouse, key and touch events: the
menu's CAMPAIGN button, the Naturalist tab, the hub's hotspots on the painting and in the GO TO list, every talk to
its end, the SPECIMEN CHART (war table), every mission's modes, BRIEFING, side pick and difficulty, START, the
opening stills, the match, the end panel and where it leads. In the match every order was given as a person gives it:
the view moved by a click on the minimap, a creature picked by clicking on it, F2 for the army, Ctrl+1 and 1 for a
group, the command card's buttons clicked at their place, ROOT placed with a click, right-clicks to move or attack,
A and a click to attack-move. The drivers only read the game's state to decide; they never change it.

The players:

- careful: plays the mission's own steps (b01 the teaching strip, a03 the climb, the four marks and the way down, a05
  the young, the eggs and the carts).
- reckless: sends the hero into the enemy (the loss on purpose: the Sire into the rival den, Valadares and Lindqvist
  into the nest).
- idle: sits there.
- confused: 160 random acts: clicks and double clicks anywhere, right-clicks, drags, random keys, the match menu
  opened and shut, pause, Settings, the window resized to four sizes, the dialogue's NEXT and SKIP.
- fast: START clicked three times, NEXT in the opening as fast as the mouse goes.
- quitter: plays a minute, QUIT TO MENU, checks what is kept.
- the mirrors: the Nest (a03) and the creatures (a05).

Runs: 26 mission runs (b01 x 12 with the probes, a03 x 7, a05 x 7), 15 hub runs (every state of the hub: fresh, b01 saved,
b01 burned, a03 party, a03 map withheld, a03 nest, a05 expedition, a05 few, a05 creatures), and six check tools.
Difficulties EASY, NORMAL and HARD; languages English, Portuguese and Spanish; screens 1280 x 720 (computer), 844 x 390
and 2340 x 1080 (phone, touch). Every choice was taken both ways (b01 TAKE / LEAVE THE CLUTCH and the default in time;
a03 DRAW / WITHHOLD THE MAP, both ways down).

Results in short:

- b01 Specimen One: won 4 times (TAKE, LEAVE and the default in time; EASY, NORMAL, HARD; English and Portuguese),
  lost 4 times (three times when the pack died at the pen, once on purpose), idle 25 minutes: nothing happens.
- a03 The Lost Plateau: won as the party twice (map drawn and withheld, NORMAL and HARD, both ways down), lost on
  purpose (EASY, the nest woken), quit once; as the Nest won twice (once only by the clock), lost once (HARD).
- a05 The Specimens: won as the expedition twice (EASY, NORMAL), lost twice (once on purpose); as the creatures won
  twice (once only by the clock: the scripted expedition caged nothing in ten minutes).
- The flags carry forward: b01's clutch / eggs / saved / pieter / rival, a03's map / party / survey, a05's cages /
  eggs reach the next mission and the hub (the hub's lines and hotspots change with them).

Pictures are in `docs/shots/playtest_2026_11_21/campaign_brood/<run>/` (each run's folder; most kept as JPEG). The
drivers are in `tools/playtest/` and can be run again (how at the top of each file):

- `pt_lib.gd` (real input, buttons found and clicked at their rect, screenshots, an engine logger that catches every
  error), `pt_hand.gd` (the player's hand in a match), `brood_hub.gd` (the hub), `brood_mission.gd` and
  `brood_brains.gd` (a mission from the main menu to the end, by player type).
- Checks: `check_b01_gate.gd`, `check_brief.gd`, `check_briefing.gd`, `check_end_panel.gd`, `check_openings.gd`.

No crash of the game was seen. Every script error seen came from one bug (finding 3), now fixed.

## Findings

Severity: CRASH, BUG, UX (works but is hard or confusing), DESIGN (a question for the owner), ART.

### Fixed on the branch

1. BUG, softlock for a person: in Specimen One the pen's GATE could not be targeted. A right-click on the gate (or A and
   a click on it) attacked the palisade south of it, because the click test for buildings leans ten pixels down for
   tall sprites and the next palisade piece came first in the list. The pack hacked the wrong wall and the gate never
   broke (the old simulation never noticed: it ordered the attack in code). Fixed in `Game.entity_at`: a one-tile piece
   (a palisade or gate) under the click itself comes first. Check `tools/playtest/check_b01_gate.gd`. Picture
   `b01_careful/18_gate_hit.jpg` (the tooltip says "Palisade" over the gate). Commit "the pen's gate can be clicked".
2. BUG: The Specimens could not be started at 1280 x 720: its briefing (two sides, five objectives) put START at y 737,
   under the screen. The briefing's words now scroll, and the side and difficulty picks stay in view below them. Check
   `check_briefing.gd` (every mission, every side, en / pt / es, computer and phone): on main a05 fails, on the branch
   all pass. Picture `check_briefing_a05_expedition_1280x720.jpg`.
3. BUG (script errors): The Specimens' opening broke with "Invalid call 'String' constructor" in StillShow._ready, then
   "Invalid assignment of 'text' on Nil" at every NEXT. An opening line with an "if" (what Lindqvist says depends on
   b01's clutch) reached the still show as a dictionary. The Printing Houses (a01) has the same kind of lines, so the
   Crown's line had it too. Now `Campaign.pages_before` keeps an "if" line when its condition holds (past flags,
   difficulty, not / all / any) before the match starts. Check `check_openings.gd` (every mission, every side).
4. BUG: the end panel of a won Specimen One at 1280 x 720 pushed NEXT MISSION, PLAY AGAIN and CAMPAIGN under the bottom
   edge (the debrief, its flag lines and nine objectives). The words now scroll. Check `check_end_panel.gd`. Before:
   `b01_careful2/33_end_panel.jpg`; after: `check_end_panel_1280x720.jpg`.
5. BUG: the mission's dialogue box, objectives and choice were drawn over the match MENU (PAUSED panel and its music
   list) and took its clicks. They now step aside while the menu or Settings is open, and a line is not used up unseen
   meanwhile. Before: `b01_main_probe` (removed), after: `b01_probe2/17_paused.jpg`.
6. BUG: the briefing showed raw codes: "Dawn in {clock:dawn}", "({caged} of {young0} caged)", "The rains come in
   {clock:rains}". Now a clock reads its length at the chosen difficulty ("Dawn in 10:00"), an aside with numbers not
   known yet is left out, counts read their start. This was in every line's briefings (a01, a02, a04, a06 too). Check
   `check_brief.gd`. Picture of the old one: `hub_a05_exp_pt_phone/25_briefing_Mission_a05_specimens_Side_expedition.jpg`.
7. BUG: "LAY AND HATCH ... (22 of 6 Raptors)": the count went on past its target. A count with an "of" now reads at most
   that number in "n of N". (Also "{x.of}" no longer prints "6.0".)
8. BUG: won as the Nest or as the creatures (a mirror), the end panel said "The next mission is being written." The
   story only goes on from the other side, so it now says "That is not how it went. To go on with the story, win it as
   The Crown's Party." (pt and es added to `tools/i18n/50_campaign.txt`, lang files rebuilt). Picture
   `a03_nest_es/16_end_panel.jpg`.
9. BUG: the hub did not follow who won. Won as the creatures, the warehouse said "The cages from the cloud mountain
   stand in the Academy's warehouse" and showed the plateau's egg and specimen jar; won as the Nest, "Lindqvist reads
   the mapmaker's report" though Valadares never came down. Those hub entries and hotspots now carry "sides".
10. BUG: in the hub, THE EGG (after a05) sat exactly under THE CRATE IN THE CELLAR and could not be clicked on the
    painting (the crate, the cellar crate and the singed notebook all used the egg's spot). The three crate hotspots
    moved onto the straw nest beside Lindqvist.
11. BUG: the war table's heading still said "Lindqvist's Station · WAR TABLE" after the station was lost (the hub is then
    The Warehouse at the Barra).
12. ART: the war map's cartouche read "THE WAR MA": its title now shrinks to fit the frame.

### Not fixed: bugs and things to look at

13. BUG, to look at: The Lost Plateau's mirror (the Nest) on HARD, Spanish: the scripted party never took a survey mark;
    the Nest won when the rains ran out at 12:36, after twelve minutes of nothing, and the win left NO flags (no
    `plateau: kept`: only the hunt's two ways to win set it). The same setup in English on HARD went normally (the
    party surveyed and got away), so the party's script can stall. Picture `a03_nest_es/13_final.jpg`.
14. UX: in The Specimens, netting the third young one ends the night at once: the optional eggs objective fails that
    instant, with no warning. A player who reads the objectives in order (THE TAKING first, the eggs "optional") loses
    the eggs every time. Doing the eggs first works (won with eggs taken). A line from Lindqvist ("the eggs before the
    last young one, or the sun") or the eggs listed first would help.
15. DESIGN: The Specimens ends at once, DEFEAT, when Lindqvist walks too near the nest (0:24 in the reckless run): no
    warning shot, no second chance. The Lost Plateau handles the same mistake better (the nest wakes, Part 3 comes early).
16. DESIGN: an idle Specimen One never ends: 25 minutes, nothing happened (no clock, the rival never came). Missions with
    rains or dawn have a clock; this one has none.
17. DESIGN: the mirrors are short and easy: the Nest won in 4:42 and the creatures in 3:52 by waiting and sending
    everything once the hunt opened (the scripted Lindqvist walked his carts into the raptors). The roster's new pieces
    (GROW, MATURE, Spitters) were never needed.
18. DESIGN: Specimen One is hard to win for a person who sends the pack out early: twice the whole pack died at the pen
    (the station's guns and the rival's hunters) and the rival killed the Old Mother at about 10:00 while the Sire sat
    rooted by the pen with no one left to break the gate. 24 Raptors before going out worked every time (4 wins).
19. DESIGN: Pieter was "lost" in every won Specimen One (4 of 4). If he can be saved, the game never showed how.
20. UX: campaign missions cannot be saved or continued: QUIT TO MENU (or a phone closing the app) loses the mission; the
    menu has no CONTINUE for it. The crash page also says "Your match was autosaved: CONTINUE is on the menu" even when
    the last session was in a menu or a mission.
21. UX: the roster ladder's cards: the pieces not in this mission (Brute, Spitters, Mist Toad, Hatchlings, GROW, Quick
    Roots) show on the Brood Mother's card with their prices, dimmed exactly like a piece that is only not ready yet
    (the Raptors before the Sire is rooted); pressing one says "Not in this mission." Hiding them, or a lock, would read
    better. The Tyrant Sire's card also says "he fathers Raptors and Brutes" in a mission without Brutes. Picture
    `b01_probe2/14_roster_presses.jpg`.
22. UX: the objectives panel is big and takes the clicks under it: Specimen One lists up to nine long objectives, about
    380 x 450 pixels on a 1280 x 720 screen. Clicks on creatures under it do nothing (the driver's first runs could not
    pick the Old Mother there). On a phone the objectives and the dialogue box cover the top half of the screen
    (`b01_probe_phone/16_card_tyrannosaur.jpg`). It folds ("OBJECTIVES -"), but folding it is not obvious.
23. UX: the HUD's economy bar in missions without an economy: The Lost Plateau and The Specimens show gold 0, powder, a
    supply of "11 / 0" (it reads like an error) and "Horses: 0"; the party's card offers BUILD, REPAIR, WORK and MOUNT.
24. UX: The Lost Plateau's survey marks have no mark on the ground and no bar for the 40 seconds: only "(2 of 4)" in the
    objectives tells you a mark counted (`a03_careful/16_mark_rim.jpg`).
25. UX: the CHOICE panel (THE MAP, THE CLUTCH) opens in the middle of the screen while the match goes on, over the units
    you are moving (both come as the enemy arrives). `a03_careful/19_choice_map.jpg`.
26. UX: Specimen One's DEFEAT always says "The rival pack held the forest", also when the station's guns killed the Sire.
27. ART: overlapping labels: the Mother's "Eggs: 4/10" over "The Old Mother", "GRUBS 5/6" cut by the top bar, "too far
    from the Mother" and "The Tyrant Sire" drawn over the top bar, "Valadares" over "Benedito" (`b01_probe2/09_card_brood_mother.jpg`,
    `a03_careful/14_mark_cairn.jpg`).
28. ART: the Warehouse at the Barra is the station's painting, tinted: the jungle window, the specimen chart and the
    egg under the bell jar are still there (`hub_b01_saved_en/03_naturalist_hub.jpg`). It needs its own painting.
29. ART: at the nest's rim (a03) a ruler-straight dark line crosses the whole view (the hollow's edge?) (`a03_careful/16_mark_rim.jpg`).
30. ART: on the war map, the region name "The Upper Rio Negro" sits under the green seals and cannot be read.
31. Voices: lines without a voice file: b01 17 (Pieter, the narrator's places, Teles late, ...), a03 13 (Benedito, the
    guide, the roars), a05 13. Voices are English in every language (known).
32. Translation: Spanish calls the Tyrant Sire "el Señor Tirano" and the pack "La Manada del Señor", which reads as "the
    Lord's Pack" in a Catholic game; the Portuguese keeps "Sire". The Portuguese mission texts are European ("Amazónia",
    "trouxeram-mo") while the menus read Brazilian ("vencida", "Espécime"): one of the two?

### THE BROOD IS NOT A PERSON (the owner, 2026-11-19): lines that give the creatures a mind

Already on the owner's list: b01's ending (the King): "He wrote that his lure called them. It did not. She called them,
and they came for her." / "She was never stolen. She went home." / "And what he carried out of the fire was not research.
It was her children." / "He never knew." Found besides:

- b01 briefing (the pack's side): "One of your kind calls from a crate ... take her home"; the objective "Take her home"
  and the debrief title "She is home"; the rival: "before she is home".
- b01 Lindqvist (a narrator who may be wrong, so perhaps fine): "She knows that voice.", "He did not want to eat her. He
  lay down beside her like a groom.", "He took her from me as a thief takes a horse."; the hub: "He stole her."
- a03 the Nest's briefing: "Strangers are climbing your cliff. Let them come. When the Sire is home, hunt them" (a plan,
  a will); Valadares: "She knows her home."
- a05 the hub: "They know my whistle already" (Lindqvist, fine as his belief).

## Tests

Run on the branch and on main (`tools/test_campaign.gd`, `test_campaign_b01.gd`, `test_campaign_a03.gd`,
`test_campaign_a05.gd`, `test_war_map.gd`, `test_roster_ladder.gd`), headless: every one reports 0 failures on
both. Every one also ends with exit code 134 on both (Godot aborts while shutting down: "Texture ... leaked", then
"RenderingServer::get_singleton() is null"), after its result is printed: harmless for the tests, but worth knowing
when a script reads the exit code.

## Proposals for the owner

- P1 (finding 14): warn before the last young one is netted, or list the eggs first.
- P2 (15, 17): a warning (a raptor stirs, one chance) before The Specimens ends on Lindqvist's mistake; the mirrors a
  little longer, with the new pieces needed (the scripted side stronger, or the hunt sooner).
- P3 (16): a clock or a rival push in Specimen One so an idle game ends.
- P4 (20): save and continue a mission, or at least say on QUIT that the mission will start again.
- P5 (21, 23): hide what a mission's roster does not allow; hide the economy bar where there is no economy.
- P6 (13): look at the a03 party's script on HARD; set `plateau: kept` when the rains end it too.
- P7 (32): a Spanish name for the Tyrant Sire that does not read as "the Lord".
