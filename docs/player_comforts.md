# Player comforts (job player-comforts, 2026-11-21)

The owner answered the playtests' questions on 2026-11-21 at 15:43. This job builds the five things he said yes to.
He said no to a game speed setting in skirmish, to hiding the gold and supply in missions without an economy, and to
making Normal easier: none of those were touched.

Everything is on the branch player-comforts. The patch note is under the placeholder version 0.38.999.

## 1. Saving inside a campaign mission, and checkpoints

### What the player sees

- A campaign mission now saves itself while you play: every 15 seconds, when you leave it, and when a phone puts the
  game away. Before, a mission was never saved: quitting, or a phone closing the game, lost the whole mission.
- The match menu has two new buttons in a mission: SAVE (your own save, at this moment) and LOAD SAVE (back to that
  save; it asks first, because what happened since is lost). LOAD SAVE is greyed out until you have saved once.
- CHECKPOINTS: when a new part of a mission begins (Part 2, Part 3), or you meet one of its main objectives, the game
  keeps a checkpoint by itself and says "Checkpoint." for a moment.
- After a DEFEAT the end screen offers RETRY FROM CHECKPOINT, which puts you back at the start of the part you lost in,
  and RESTART MISSION, which starts it over (this button was PLAY AGAIN; after a victory it still is).
- The mission's card in the campaign (on the war table, and on the war map's pin card) shows, when they exist:
  CONTINUE (where you left it, with the game time), LOAD SAVE (your own save) and FROM CHECKPOINT (the last checkpoint).
  BRIEFING still starts the mission from its beginning.
- If the game closed unexpectedly during a mission, the crash page now says your mission was saved and that CONTINUE is
  on its card in the campaign.

### What a save keeps

Everything the story counts and reads: the objectives and their states, every choice and flag, the counters, the
countdowns, which triggers have fired and when, the lines already said, the pieces the roster ladder or the story
denies, the light, the weather and the mist, the reveals, the routes and followers under way, the sleepers (and what
wakes them), the caged, the cage carts with their creatures, the fires (and how far they have been put out), the
disguised presses, the people taken captive, the sides that are out, the checkpoints already taken, and on every unit
and building what the mission put on it: its tag, its name, its role (a hero's own health and picture), its health
floor, whether it is spared, held, asleep or caged. The scripted waves keep walking where they were going (a save of a
skirmish drops orders; a mission's keeps the scripted units' move, attack and hold orders). A choice that was on
offer is offered again.

What is not kept: the line of dialogue on the screen at the moment of the save (the next one comes as usual), and the
replay (a continued mission records a new replay from the moment it continues).

### Where the files are

Three files a mission, in the game's user folder under missions/: "where you left it", your own SAVE, and the last
checkpoint. Like the skirmish's save, they are kept for the version of the game that wrote them: after an update a
mission begun before it starts again. They are apart from the skirmish's autosave: a mission never writes over a skirmish you left, and the
main menu's CONTINUE is still the skirmish's. A finished mission no longer deletes the skirmish's autosave either (it
did before, by accident).

### How it was checked

- tools/test_campaign_save.gd (every Act 1 mission: p01, a01 to a07, b01, c01): each is played for 20 seconds, its next
  part is begun, it is saved, loaded, and everything listed above is compared with the state before the save (it must
  be the same); it plays on 25 seconds with no script error; a save of the loaded game comes back the same too. Also:
  the checkpoint, the defeat's end screen with RETRY FROM CHECKPOINT and RESTART MISSION, RETRY going back to the
  checkpoint's time, a victory clearing the mission's saves, QUIT TO CAMPAIGN, CONTINUE on the card, the menus, the
  pause keys and the questions (below). All checks pass.
- tools/test_campaign_save.sh plays every Act 1 mission to its end with its simulation bot (tools/sim_campaign_*.gd)
  twice: once straight through, once saved and loaded half way. The results are in the table below. The game is not
  exactly repeatable (the computers and the fights roll dice), so the numbers kept with a flag (how many were saved,
  how many automata were lost) differ a little from run to run, with or without a save; what the story decides (the
  choices, who won, the flags written) matched in every mission the bot finished both times.

The full runs (tools/test_campaign_save.sh; "saved" = saved and loaded half way through the run, at the time in
brackets; the bot plays the mission's default side on Normal):

| mission | straight through | saved and loaded |
|---|---|---|
| p01 The Leaf and the Fire | the sim plays only the night (8 minutes): no flag yet | the same (saved at 5:00); the state after the load identical |
| a01 The Printing Houses | Crown won: printer taken, Lyon calm | the same (saved at 3:00) |
| a02 The Fürth Line | guild won: stop-work fitted, Fürth strong (11 men), Jakob alive | the same flags, Fürth strong with 13 men (saved at 6:40) |
| a03 The Lost Plateau | party won: survey full, map drawn, the Sire by the split, party few (3), Linnea seen | the same (saved at 5:00) |
| a04 Father Ferrer's Visit | the visit won: stop-works found, 5 lost to the machine, the broken ones kept, Jakob alive | the same (saved at 2:30) |
| a05 The Specimens | expedition won: eggs taken, the short way, cages some (2), crates seen, Pieter lost | the same (saved at 2:50) |
| a06 The Barricades of Paris | Crown won: Varenne spared, Paris stood | the same (saved at 2:40) |
| a07 The Council of Rome | Crown won: both defied, Rome some (4), people many (18) | the same (saved at 6:40) |
| b01 Specimen One | the Sire's pack won (clutch saved, eggs left, saved some (15), Pieter lost, the rival standing) in 2 of 3 runs | won once, stalled at the pen's gate twice (saved at 5:00) |
| c01 The Thirteenth Hour | guild won: bells quiet, drawings taken, gate pattern, saved some (54), Jakob alive, cut no | the same (saved at 6:40) |

Specimen One: the sim's pack sometimes never breaks Linnea's pen gate and the rival pack wins in the end. That happened
in a run with no save too (the first straight run), so it is the bot, not the save: the Raptors sent at the gate from
the north of the pen try to walk through the pen's wall, which the story keeps unbreakable until the gate falls, and
stand there. A player who clicks the gate from the north may meet the same thing; it is worth a look in a pathfinding
job (the siege path should not go through a building nobody can hurt). Not changed here.

## 2. QUIT goes back to the campaign

In a campaign mission the match menu's QUIT TO MENU is now QUIT TO CAMPAIGN. It asks first ("Leave the mission? It is
saved: CONTINUE is on its card."), then takes you to the camp of the storyline the mission belongs to, with the mission
picked, where its card offers CONTINUE. Rome (a07, in all three storylines) goes back to the storyline you came from.
A tutorial lesson still goes back to the main menu.

## 3. A pause key

Pause/Break or F10 pauses the match, and either one resumes it. It works like the menu's PAUSE: online it uses up one
of your pauses and cannot resume a match the host's absence holds; an online spectator cannot pause. HOW TO PLAY says
so (in English, Portuguese and Spanish).

F10 was the key of the seventh camera view. That view is still there (its tab above the group bar, now marked with a
dot instead of "F10"): click or tap the tab to use it. The other views keep F4 to F9.

## 4. Questions before leaving

- EXIT on the main menu asks "Quit the game?" with YES, QUIT and NO.
- The phone's back button, where it used to close the game at once (on the main menu, and in a match), asks the same.
- QUIT TO MENU (in a skirmish) and QUIT TO CAMPAIGN (in a mission) ask first. Online it already asked; it still says
  that leaving ends the match for the friend.
- LOAD SAVE asks first.
- In every question Esc (or the phone's back) says NO, Enter says YES. All words are in English, Portuguese and Spanish.

## 5. A phone held sideways

On a phone held sideways, on a short wide screen (twice as wide as tall or nearly: 844 by 390, 780 by 360, 915 by
412), the interface now takes less room. A tablet, a phone held upright and a computer are unchanged, and if you chose
an INTERFACE SIZE in Settings the interface keeps your size.

- The whole interface is drawn at 1.3 times instead of 1.5 times, so the resource bar, the selection panel, the group
  bar and the menu are a little smaller.
- The command card's buttons are 54 units at 1.3 (70 of the game's screen units): a little smaller than before (78) but
  still a thumb's width, well over 44.
- The minimap is smaller.
- The OBJECTIVES are folded to one line: "OBJECTIVES +" and the first open objective, cut to fit. A tap on the line
  opens the whole list; a tap on its title folds it again. Once you open or fold it yourself, it stays as you left it.
- The DIALOGUE box is narrower and shorter, with a smaller portrait, and shows three lines at a time. A long line shows
  "1/2" in its corner: tap the box (or NEXT) for the rest; it also turns the page by itself after its share of the
  reading time. NEXT and SKIP stay a thumb's height. A still shown with a line is smaller.

Measured on 844 by 390, in the Prologue's first minute (shares of the screen's height):

| | before | after |
|---|---|---|
| the interface at the bottom (card, panel, group bar, minimap) | 37% | 32% |
| the objectives | 31% (always open) | 6% (one line; 28% when opened) |
| the dialogue box | 21% | 15% |

Pictures (docs/shots/player_comforts/):

- before_phone/01_mission_dialogue.jpg and after_phone/01_mission_dialogue.jpg: the same moment before and after.
- before_phone/02_mission_objectives_tapped.jpg (the objectives folded by a tap, the only way to fold them before) and
  after_phone/02_mission_objectives_tapped.jpg (opened by a tap).
- after_phone/03 and 04: a long line in two pages ("1/2", then "2/2" after a tap on the box).
- after_phone/05_mission_selected.jpg: a Barracks selected, the compact card and panel.
- before_phone/04_skirmish.jpg and after_phone/06_skirmish.jpg: a skirmish.
- after_phone_780_b01/: the Naturalist's prologue on a 780 by 360 phone (03: a creature selected).
- after_phone_menu/: on the phone: paused by F10, the match menu with SAVE and LOAD SAVE, the LOAD and QUIT questions,
  the hub after QUIT, the card with CONTINUE and LOAD SAVE, the mission continued, the main menu's EXIT question.
- pc/: the same on a computer at 1280 by 720 (a computer's layout is unchanged).

The driver that takes them plays with real input: tools/playtest/pt_comforts.gd
(tools/playtest/run.sh pt_comforts 844x390 phone tag=<name> what=layout|menu|all).

## Tests

New: tools/test_campaign_save.gd (107 checks, all pass), tools/test_campaign_save.sh (the full runs above), the playtest
driver tools/playtest/pt_comforts.gd (all its checks pass on a computer at 1280 by 720 and a phone at 844 by 390).

Existing tests run after the job, all passing: test_i18n, test_campaign, test_campaign_m1, test_campaign_b01,
test_campaign_c01, test_qa_save_continue, test_qa_save_roundtrip, test_save_job, test_hotkeys (changed: it used F10 for
the seventh camera view; it now checks that F10 is no view key and uses the tab), test_hud_frames, test_menu_grid,
test_drag_release_ui, test_tutorial, test_war_map, test_roster_ladder. test_gear_save fails with 4 failures both on main
and on the branch (its save has no match set-up, which the save check added by the playtests refuses): not this job's.
Every headless run still ends with the engine's abort at quit (exit code 134), as on main.

## Claude's choices (for the owner to confirm or change)

1. Online CO-OP and VERSUS missions are not saved (no SAVE or LOAD in their menu, no checkpoints). Saving there would
   need both players to agree and load together; leaving it off is the safe choice. Solo missions only.
2. Tutorial lessons are not saved, and QUIT from a lesson still goes to the main menu (they are short).
3. Three saves a mission: where you left it (written by itself), your own SAVE, and the last checkpoint. The main
   menu's CONTINUE stays the skirmish's only; missions continue from their card in the campaign.
4. Starting a mission again from BRIEFING, RESTART MISSION or PLAY AGAIN deletes "where you left it" and the
   checkpoints of the run before; your own SAVE stays until you save again.
5. A victory deletes "where you left it" and the checkpoint (the mission is done); a defeat deletes "where you left it"
   and keeps the checkpoint for RETRY FROM CHECKPOINT. Your own SAVE stays in both cases.
6. What makes a checkpoint: a trigger whose id begins with "part" (part2, part3, part2_go; not "party"), or one of the
   player's side's primary objectives met. Each only once. Missions without such triggers (the Prologue, Specimen One)
   get their checkpoints from their objectives. A mission can name more later the same way.
7. SAVE closes the menu, so the "Saved." note is seen over the match.
8. F10 now pauses (as asked), so the seventh camera view has no key; its tab still works by click or tap.
9. The phone's back button now asks "Quit the game?" everywhere it used to close the game at once, a match included
   (it saves the match or mission first, as before).
10. No SAVE / LOAD buttons in a skirmish: a skirmish already saves itself and the main menu's CONTINUE brings it back.
11. The compact layout turns itself on by the screen's shape on a phone (1.85 times as wide as tall or more); there is
    no switch for it. A chosen INTERFACE SIZE keeps the interface at that size (the objectives and dialogue are still
    compact).
12. A save fix found on the way: a saved Pikeman (back as a campaign-only unit) came back as a Musketeer; he now comes
    back a Pikeman.

## IRONMAN (0.38.119, the owner 2026-11-21 20:59: "Campaign in Ironman mode you can't save load scam")

A switch on the campaign hub, under the difficulty: IRONMAN: OFF asks first, then stays ON for this campaign
(`Campaign.ironman()`, progress key `ironman`; `Campaign.set_ironman()` also clears every mission's own SAVE and
CHECKPOINT: `MissionSave.clear_kept()`). With it on:

- only "where you left it" (MissionSave `auto`) is ever written (`MissionSave.write` refuses `save` / `checkpoint`);
- the match menu has no SAVE / LOAD SAVE; a CHECKPOINT moment writes where you left it instead (`Main.mission_checkpoint`);
- a CHOICE is saved the moment it is made (`MissionRun.choose` emits `checkpoint_wanted("choice:<id>")`);
- the card shows only CONTINUE; the briefing's START is shut while a mission is under way (CONTINUE beside it) and for
  good once it is won (`CampaignMenu.ironman_lock`); the end panel has no RETRY FROM CHECKPOINT and no PLAY AGAIN after
  a win; a DEFEAT may still be tried again from the mission's start (RESTART MISSION).

Test: `tools/test_campaign_ironman.gd` (12 checks). Claude's choices for the owner: (1) it can't be turned off (no
campaign reset exists yet); (2) a defeat may be restarted from the start, a win can't be replayed; (3) online co-op and
versus are untouched (they never saved); (4) the 15-second autosave stays, so a game killed by the phone can lose up
to 15 seconds, but quitting, a choice and a checkpoint moment save at once.
