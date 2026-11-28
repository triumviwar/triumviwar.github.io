# World War: a way out of a battle (job ww-call-off)

The owner, 2026-11-28: a way out of a battle you can't win in WORLD WAR. Until now the battle question only offered
FIGHT IT or AUTO-RESOLVE, even at "your side wins about 0 times in 100". Now the question shows the odds as before and
adds a way out for each side.

## What the player sees

- ATTACKING: **CALL IT OFF**. The march is cancelled: the army turns back and stays where it was, nothing is lost. Its
  march this season is spent (it may not march somewhere else this season). The log says "The Crown calls off the attack
  on Vienna."
- DEFENDING: **RETREAT**. The army (every army of the side in that region) falls back to the SAFEST region of its own
  next door and loses a tenth of its men (the rear guard); the region is given up to the attacker, which marches in
  without a battle (no losses, no veteran rank; the region's building is pulled down as when a region is taken). The
  question names where it will go: "RETREAT: your army falls back to Rome and loses 10% of its men to the rear guard;
  Milan is given up to the Clockwork."
- NO RETREAT, said on the question instead of the button:
  - a CAPITAL is never given up ("A capital is never given up: its army must stand and fight."): taking it would put the
    side out of the war, so there is nowhere to retreat to that matters;
  - NO WAY OUT: no region of its own next door is free of the enemy ("NO WAY OUT: no region of your side next door is
    free of the enemy. Your army must fight.").
- A key region may be given up (it is only land; the computers do too).
- A MARCH INTO A REGION WITH NO ARMY IN IT (free militia, or a side's region left empty: only its guard) used to be
  decided at once with no question. It still is when the player's side wins 50 times in 100 or more; below that the
  battle question comes first, with CALL IT OFF and AUTO-RESOLVE (no FIGHT IT: there is no army to fight).
- HOT-SEAT: a player attacking another player's army used to be decided at once. Now the attacker is asked: CALL IT OFF
  or AUTO-RESOLVE (no FIGHT IT: one screen). The defending player is not at the device, so no RETREAT there.
- Esc and the phone's back no longer close the battle question (a closed question left the march half done); it must
  be answered, and CALL IT OFF is the way out.
- HELP has a new section, A WAY OUT.

Pictures (computer 1280x720, a phone held sideways 1600x720, and the computer in Portuguese), by
`tools/shot_ww_call_off.gd`, in docs/shots/world_war/call_off/: `<pc|mobile|pc_pt>_1_attacker_call_off` (0 in 100,
CALL IT OFF / AUTO-RESOLVE / FIGHT IT), `_2_called_off` (the army back at Milan, the toast), `_3_defender_retreat`,
`_4_retreated` (Milan the Clockwork's, the Crown's army at Rome), `_5_capital_stands`, `_6_no_way_out`,
`_7_free_land_asked`, `_8_help`.

## The rules, with their numbers (scripts/worldwar/ww_rules.gd)

| rule | value |
| --- | --- |
| RETREAT_LOSS: the rear guard left behind on a retreat | 10% of each kind (5% with Lord Fairleigh, as his army loses half when beaten) |
| where a retreat goes | a LAND neighbour the side holds with no other side's army in it; the safest first (the least enemy army strength in the regions next to it, the attacker not counted), then the best held (its guard + its own armies), then the nearest to the capital |
| joining | a retreating army joins an army of its own there when the two fit in 80 units (the best veteran rank kept), else it stands beside it |
| a retreating army | is marked as moved (as a beaten army falling back is) |
| ASK_BELOW: a march into a region with no army asks first | when the player's side wins fewer than 50 times in 100 |
| the odds | the same as the question has always shown: 400 rolls of the battle's luck on the strengths with every bonus, on dice of their own (asking never changes what the war's dice do next) |
| CALL_OFF_AI: the computers use the way out | on in new wars (rules version 3), off in wars saved before (versions 1-2) |
| AI_RETREAT_AT: a computer's army retreats when its side wins fewer than | Easy 5, Normal 10, Hard 15 times in 100 (and may: not a capital, a way out) |
| AI_CALLOFF_AT: a computer's attack is called off when it wins fewer than | Easy 10, Normal 15, Hard 20 times in 100 |
| AI_RETREAT_MIN: a computer retreats only an army worth keeping | its armies there worth 600 gold or more (a garrison of a few men stands and fights) |
| AI_RETREAT_KEYS: a computer may give up a key region | yes (a capital never) |

CALL IT OFF on a sea crossing: the army sailed and turned back, so a storm (or the Clockwork's rust, the Brood's losses
in the holds) on the way still counts; it is back in the port it left.

## The computers (scripts/worldwar/ww_war.gd, WWWar.move)

In `move`, before the battle is asked or decided: a computer's attacker below AI_CALLOFF_AT calls it off; a computer's
defender below AI_RETREAT_AT retreats when it may and its armies there are worth AI_RETREAT_MIN (600) or more. So a computer facing the player does it before the player is asked
(the player then sees "The Brood's army retreats from Pará to Amazon; the Crown takes Pará." as a toast), and the
computer-only wars of the simulation use it the same way. The computers' choice of target already wants 1.05-1.6 times
the defender's strength, so a computer calling off an attack is rare (0.0-0.2 a war in the simulation below);
retreats are the part that matters.

Easy retreats least (it stands and loses its army more often, a weaker opponent), Hard most.

## Measured (tools/sim_world_war_tune.gd, tools/study/ww_call_off.sh)

The five setups of the tuning pass (docs/world_war_tune.md), 100 wars each, Normal computers, take the capitals, 48
seasons, story heroes on; BEFORE = today's code with the computers' way out switched off (`tune=CALL_OFF_AI:0`), AFTER
= on. Two seed sets (1000-1099 and 3000-3099). Raw lines in docs/ww_call_off/ (`before_seed*.txt`, `after_seed*.txt`;
the SUMMARY line now ends with the retreats and called-off attacks a war).

Who won (the sides in the order of the "war" column), how the wars ended, capitals taken, land left free at the end,
and the computers' ways out a war (AFTER):

| war | seeds | BEFORE won | AFTER won | BEFORE ended by | AFTER ended by | capitals fell (before / after) | free regions at the end | retreats / called off a war |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| three sides (Crown / Clockwork / Brood) | 1000 | 43 / 28 / 29 | 40 / 25 / 35 | land 97, conquest 3 | land 94, conquest 6 | 62 / 71 | 21.3 / 24.1 | 2.8 / 0.0 |
| three sides | 3000 | 35 / 29 / 36 | 44 / 26 / 30 | land 100 | land 92, conquest 8 | 45 / 64 | 20.1 / 22.7 | 2.8 / 0.1 |
| **three sides, both sets (200)** | | **78 / 57 / 65** (39 / 28.5 / 32.5%) | **84 / 51 / 65** (42 / 25.5 / 32.5%) | land 197, conquest 3 | land 186, conquest 14 | 107 / 135 | | |
| Crown / Clockwork | 1000 | 48 / 52 | 46 / 54 | land 80, conquest 20 | land 68, conquest 32 | 20 / 32 | 30.8 / 32.8 | 1.1 / 0.0 |
| Crown / Clockwork | 3000 | 50 / 50 | 54 / 46 | land 64, conquest 36 | land 65, conquest 35 | 36 / 35 | 33.4 / 33.4 | 1.1 / 0.1 |
| Crown / Brood | 1000 | 60 / 40 | 50 / 50 | land 97, conquest 3 | land 96, conquest 4 | 3 / 4 | 26.3 / 26.6 | 2.1 / 0.1 |
| Crown / Brood | 3000 | 49 / 51 | 55 / 45 | land 96, conquest 4 | land 93, conquest 7 | 4 / 7 | 26.9 / 27.5 | 2.3 / 0.1 |
| Clockwork / Brood | 1000 | 55 / 45 | 63 / 37 | land 100 | land 100 | 0 / 0 | 25.3 / 25.3 | 1.9 / 0.0 |
| Clockwork / Brood | 3000 | 62 / 38 | 71 / 29 | land 100 | land 100 | 0 / 0 | 23.9 / 24.7 | 1.8 / 0.1 |
| three sides, no last season (stopped at 120) | 1000 | 7 / 3 / 3, none 87 | 11 / 2 / 7, none 80 | conquest 13 | conquest 20 | 93 / 105 | 22.5 / 26.7 | 6.2 / 0.1 |
| three sides, no last season | 3000 | 6 / 1 / 1, none 92 | 15 / 1 / 4, none 80 | conquest 8 | conquest 20 | 82 / 106 | 21.5 / 25.3 | 6.0 / 0.2 |

Reading it:

- WARS STILL END, and end a little more decisively: every war with a last season ends at it as before; more of them
  end by conquest (three sides 3 -> 14 of 200; no last season 21 -> 40 of 200 finished by season 120) and more capitals
  fall. An army that retreats keeps 90% of its men instead of 40%, so the armies stay bigger and the fronts move
  faster (an attacker takes a region given up without losses).
- THE THREE-SIDE RESULTS DON'T SWING beyond the noise: 39 / 28.5 / 32.5% before, 42 / 25.5 / 32.5% after. These wars
  are chaotic (one changed march changes everything after it), so two arms on the same seeds are nearly independent
  samples: the spread of a side's count in 200 wars is about 6, of a difference about 9. The Clockwork's -6 is under one
  spread (it is still the side whose capital falls most, as before).
- TWO-SIDE WARS: Crown / Clockwork 98 / 102 -> 100 / 100, Crown / Brood 109 / 91 -> 105 / 95, Clockwork / Brood
  117 / 83 -> 134 / 66 (the one move near two spreads, not explained by the logs; worth watching in the next two-side
  pass, not changed here).
- Calling off is almost never used by the computers (0.0-0.2 a war: they pick their targets at 1.05-1.6 times the
  defender's strength); retreats 2-3 a war (6 a war in the 120-season wars).

THE FIRST TRY (every computer army retreated, AI_RETREAT_MIN 0; same seeds): 8 retreats a war, mostly garrisons of a few
Brood creatures; three sides 87 / 45 / 68 of 200 (the Clockwork 57 -> 45), conquest 3 -> 22 and capitals fallen
107 -> 163 of 200; two sides Crown / Brood 128 / 72 (was 109 / 91). Lower thresholds (Normal 5 in 100: the same 8
retreats a war, the same results: a hopeless fight is near 0 in 100) and a bigger rear guard (25%: the Clockwork worse,
38 of 200) did not help; keeping garrisons out of it (600 gold) did, so that is the rule.

## Saving

- The choice is applied at once and goes into the war's file like any other order: the log line, where the armies
  are, who holds the region, and a count of each side's ways out (`ways_out`: {side: {"call_off": n, "retreat": n}}).
  The file is written as before (end of a turn, after a battle, SAVE & LEAVE).
- Old wars load and play on: a war without a rules version (or with 1 or 2) gets the player's CALL IT OFF and RETREAT,
  but its computers keep playing as they did (WWRules.V2 keeps CALL_OFF_AI off). A new war is rules version 3.

## How it is built

- `ww_rules.gd`: RETREAT_LOSS, ASK_BELOW, CALL_OFF_AI, AI_RETREAT_AT, AI_CALLOFF_AT, AI_RETREAT_MIN, AI_RETREAT_KEYS; RULES_VERSION 3 and V2 (read by
  `WWRules.value` for versions under 3).
- `ww_war.gd`: `ask_offered` (when a player is asked), `odds` / `chance` (moved here from the page), `call_off`,
  `retreat_problem`, `retreat_to`, `retreat`, `_count_way_out`; the computers' choice in `move` (`_ai_may_retreat`).
- `ww_page.gd`: the battle question's buttons (CALL IT OFF / RETREAT / AUTO-RESOLVE / FIGHT IT) and lines, `_way_out`
  (one ending for every answer on the map), toasts for a computer's retreat or called-off attack, Esc keeps the
  question, HELP's A WAY OUT.
- Texts: tools/i18n/82_world_war.txt (13 new entries, pt and es); patch note under 0.38.999.
- Tests: `tools/test_world_war.gd` (28 new checks, 96 in all: CALL IT OFF keeps the army and spends its march; RETREAT moves the
  army with a tenth fewer men and gives the region up without a battle; the safest neighbour; a capital; NO WAY OUT;
  a computer retreats in a new war and fights in an old one; a computer's garrison of a few men stands; a computer calls off a hopeless attack; hot-seat; free
  land asked only when weak; saved and loaded the same; an old war loads and plays; the page's buttons, Esc, the
  capital's missing RETREAT). `_battle_rules`' falling-back check now switches the computers' retreat off (it needs a
  battle). Every text in pt and es is checked by the same test.
- Pictures: `tools/shot_ww_call_off.gd`.

## Claude's choices (for the owner)

1. RETREAT GIVES THE REGION UP WITHOUT A FIGHT: the region's guard (its militia, a Fort's walls) leaves with the army;
   the attacker marches in with no losses and no veteran rank. The other reading (the guard still fights alone) would
   make RETREAT mean "lose the army's help but maybe keep the land", which is AUTO-RESOLVE with fewer men.
2. THE REAR GUARD COSTS 10% of each kind of soldier (5% with Lord Fairleigh), not the slowest regiments: the world map
   has no speeds per regiment, and a share is what every other loss on the map is.
3. A CAPITAL IS NEVER GIVEN UP; KEY REGIONS MAY BE. A capital lost puts the side out of the war, so its army must stand.
4. THE SAFEST NEIGHBOUR is the one with the least enemy strength next to it (the attacker itself not counted, it will be
   next door to any of them), then the best held, then the nearest to the capital. Land neighbours only: no retreat by
   sea (no ships waiting).
5. CALL IT OFF SPENDS THE MARCH, as the owner asked; what the sea took on a crossing stays lost.
6. A MARCH INTO A REGION WITH NO ARMY IN IT IS ASKED ONLY UNDER 50 IN 100, so the common march into weak free land stays
   one tap and the hopeless one gets the question (the owner's "even at 0 in 100" happens there too).
7. HOT-SEAT: the attacking player is asked (CALL IT OFF / AUTO-RESOLVE); the defending player is not at the device and
   gets no RETREAT. A question to pass the device over was left out (one screen, as the battle itself is).
8. THE COMPUTERS' THRESHOLDS: retreat under 5 / 10 / 15 in 100 (Easy / Normal / Hard), call off under 10 / 15 / 20.
   Hopeless, not merely bad: a computer that gave up every doubtful region would never hold a front. And only an army
   worth 600 gold or more retreats: a garrison of a few men stands and dies (the first try, where every garrison ran,
   moved the three-side results; see "Measured"). The player's RETREAT has no such floor.
9. OLD WARS KEEP THEIR COMPUTERS AS THEY WERE (rules version 3, like the tuning pass's version 2); the player's new
   buttons work in every war.
10. ESC NO LONGER CLOSES THE BATTLE QUESTION (closing it left the march half done: an attacker stuck where it was with its
    march spent, a computer's turn waiting). CALL IT OFF is the way out of it now.
11. A computer that retreats or calls off in front of the player shows it as a toast, like a battle the player was in.

## What is left

- The region card could show the odds before the march (today they show only on the question).
- A retreat by sea (to a port of one's own) for island regions with no land neighbour of their own.
- Hot-seat: ask the defending player too (pass the device).
