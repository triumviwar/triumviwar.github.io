# Playtest 2026-11-21: the campaign, the Crown line

Job playtest-campaign-crown, branch playtest-campaign-crown, on 0.38.106 (no version bump, no patch notes: the owner merges).

## What was played

A simulated human player, with real mouse, key and touch events, starting from the main menu every time: CAMPAIGN, the
King's study (every hotspot and every talk, at four points of progress: fresh, after the Prologue, after Lyon, after
everything), the WAR MAP (pan, wheel zoom, pinch, the four views, every pin, the pin card, BRIEFING, CO-OP, VERSUS, the
ledger, the list), then the four Crown missions:

- p01_leaf, the Prologue (Virginia): won and lost on purpose, both families choices, Easy / Normal / Hard.
- a01_presses, Lyon: won on Easy, lost twice on Normal.
- a06_barricades, Paris: played on Easy and Normal (the King's patience ran out on Normal), the Varenne choice seen
  (offered by the driver on a phone and on a computer), spare and execute set by the driver.
- a07_council, Rome: won on Easy, lost twice on Normal, the verdict show read page by page.

Player types: careful (groups, focus fire, posts, canister), idle (touches nothing), reckless (whole army at once), killer
(walks a must-live hero alone into the enemy), and a fiddler (skips, mashes, pauses, menus, surrenders, quits, plays again).
Screens 1280 x 720 and phone 844 x 390, in English, Portuguese and Spanish. About 60 runs. Every run watched the engine's
error log: no engine error was left at the end.

The drivers are kept in tools/playtest/ (pt_hub, pt_warmap, pt_p01, pt_p01_ui, pt_a01, pt_a06, pt_a07, pt_modes, pt_phone
and three probes). Run one with `tools/playtest/run.sh pt_a07 1280x720 style=careful diff=normal lang=en` (log in
/tmp/pt_<driver>_<n>.log; each run gets its own user folder so runs and tests never mix). The chosen pictures are in
docs/shots/playtest_2026_11_21/campaign_crown/.

## Fixed on the branch (each a small commit; all campaign tests pass)

1. BUG, high. Lyon, Paris, Rome and the Specimens opened on a blank screen: an opening with a conditional line
   crashed the still show, so the story before the match was never seen. Fixed in 2c7952f5. Picture 14.
2. BUG. Rome's verdict show over the match ignored mouse and touch: NEXT, SKIP and the picture did nothing, only keys
   worked. Fixed in 1eee14c7. Picture 20.
3. BUG. The Prologue's defeat at dawn ticked "Hold until dawn, with at least three barns standing" as done, the very thing
   that failed. Fixed in 041469ad (a survive objective may carry an "if"). 
4. BUG. Paris's "King's patience" was ticked green on the defeat when it ran out. Fixed in 6189ecb4 (a countdown may
   "fail"). Picture 18 is before the fix.
5. BUG. Hint arrows stayed for the whole mission (the canister arrow in Paris, the Church arrow in Rome). Fixed in dab0216c.
6. BUG. Briefings showed raw words like {temper}, {closed}, {clock:patience} (Lyon to Paris). Fixed in a529d81a; a clock
   not started yet now shows an ellipsis (cbdc3507). Picture 12 is before, 19 after.
7. BUG. Numbers read "Saved: 13 of 18.0" in Rome. Fixed in 3651406e.
8. BUG. Rome's victory panel read "Saved on the steps of Saint Peter's: {saved}" (the Fürth visit too). Fixed in 93bcb2f9.
   Picture 22 is before.
9. BUG. Rome's VERSUS page pushed BACK and WAR MAP off a 1280 x 720 screen. Fixed in 26c1df06. Picture 24.
10. UX. On a phone the mission end panel's words were a few pixels high. Fixed in a5399289. Pictures 28 and 29.
11. UX. In a mission the HUD's short messages ("Group 1 is empty") were drawn under the objectives and the dialogue box.
    Moved lower in aac5dd12. Picture 15.

## Proposals for the owner (not changed: story, design or balance)

12. DESIGN. Difficulty. A player who uses groups, focus fire and posts, but not per-unit micro, lost Normal often: the
    Prologue 3 of 4, Lyon 2 of 2, Rome 2 of 2, Paris ran out of the King's patience. All four were won on Easy. The first
    mission of the game is hard for a newcomer on Normal. Proposal: make Easy the default for a first campaign, or soften
    the Prologue's night.
13. DESIGN. Powder runs out with little warning. In the Prologue the guns reach the gate with 0 of 8 shots, so "Canister.
    On my word." cannot be obeyed, and the powder mill starts with no workers and nothing says so. In Lyon the muskets are
    on bayonets by part 2 unless the wagon is walked along. In Paris the guns go dry at the second barricade. Proposal:
    a dialogue line or objective about the mill and the wagon, or more powder at the start. Pictures 08 and 09.
14. DESIGN. Prologue, SAVE THE FAMILIES fails about ten seconds after choosing it on Normal: the raiders are already at the
    Hollins' farm when the choice appears. On Easy it works. Proposal: the choice a little earlier, or the raiders slower.
15. DESIGN. Prologue, "Break their charge with canister" is ticked even when no canister was fired. And after the army
    died at the charge the match went on for about 19 minutes before the stragglers were dead. Proposal: end it sooner.
16. DESIGN. Lord Fairleigh can be killed in the Prologue (sent alone, dead in about 100 seconds); the mission goes on, he
    keeps giving orders in the dialogue, and the victory text says he ended the rising. He is the next missions' Field
    Marshal. Proposal: a "Fairleigh must live" objective as in Paris.
17. DESIGN. Father Tomasz (must live) walks by himself to the wounded when idle, into the fight: he died at 1:45 in Paris
    with the player doing nothing wrong. HOLD stops it. Proposal: story Missionaries who must live start on HOLD.
18. UX. F2 (ARMY) also selects the must-live people (Fairleigh, Ruggieri, Tomasz in Paris; the young King in Rome), so the
    first attack-move walks them in with the army. Proposal: leave heroes out of ARMY in missions.
19. UX. The debrief names the wrong cause: the Prologue's defeat at dawn says "The manor fell" while the manor stood; Rome
    lost because Tomasz died says "The beasts are in Saint Peter's Square". Proposal: debrief lines by what failed.
20. UX. A victory panel shows open boxes for optional objectives (Lyon's city temper) and Lyon reads "Lyon went home." then
    "The city is sullen". Proposal: hide optional objectives that were never failed, or show them neutral.
21. UX. The war map's CO-OP and VERSUS buttons open the war table with SOLO selected. Picture 04.
22. UX. On a phone the war map's pin card covers more than half the map; the Amazon's pins cannot be tapped until CLOSE,
    and at the world view the European pins overlap. Pictures 05 and 06.
23. UX. On a phone the mission's dialogue box and objectives cover almost half the screen; the hotkey bar's labels are
    tiny. Picture 26.
24. UX. SURRENDER razes the buildings, so the end panel crosses the manor and barns and says "The manor fell".
25. UX. The battle report and the campaign room page do nothing on Esc.
26. UX. No save inside a mission; QUIT records nothing; PLAY AGAIN skips the opening. Picture 11 (the in-game menu).
27. UX. Rome starts with supply 46 of 32 (over the cap). Picture 21.
28. UX. The Prologue's Barracks card lists Dragoon, Horseman and Officer although the roster allows only Musketeers and
    guns (the refusal works; the list is just long).
29. ART. The hub's "FAIRLEIGH'S LETTER" fills its button to the pixel in all three languages; on a phone the Spanish
    briefing is one line short of room; the Lord's and Tomasz's name tags sit under the top bar.
30. VOICE. Lines with recordings: Prologue 41 of 55, Lyon 7 of 63, Paris 48 of 71, Rome 37 of 68 (Tomasz mostly silent).
    For docs/chatterbox_todo.md.

## Checked and fine

- The hub's talks change with progress; the war map's seals, ledger and list follow the flags.
- Flags carry: with the families saved, Paris starts with the six Hollins volunteers; Lyon's temper reaches Paris's Lyon men.
- NEW roster cards appear in each mission, portraits show, the night and dawn light work, PAUSE / RESUME / SETTINGS work.
- RELOAD works for cannons packed or not; a palisade never seen cannot be targeted (a right-click there is a move: fog).
- The Varenne choice (spare / execute) and the families choice read well on a phone. Pictures 27 and 30.

## Tests

tools/test_campaign.gd, test_campaign_m1, test_campaign_a01, a06, a07, test_war_map, test_roster_ladder and test_tutorial
pass before and after (new checks added for the fixes). Every headless test run ends with an abort at quit (exit 134), on
main too: an old engine shutdown issue, not these changes.
