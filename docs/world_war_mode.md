# THE WORLD WAR mode (job world-war-mode)

The owner, 2026-11-22 22:55-23:00, "Yes do it": a mode like The Battle for Middle-earth II's War of the Ring. A war for
the whole world on the war map, fought skirmish by skirmish. Not the campaign's story: a war of your own. Built on what
the game already has (the war map's look and the land, the skirmish, its maps and computers, the save files).

All numbers below are in `scripts/worldwar/ww_rules.gd` (WWRules), in one place, with a comment on each.

## What the player sees

- The main menu has a new button, WORLD WAR (row 3, column 2, after CONTINUE).
- THE SETUP PAGE: a line on what the mode is; YOUR WARS (each saved war: its season, its sides, CONTINUE, DELETE, which
  asks first); A NEW WAR: for each side YOU / EASY COMPUTER / NORMAL COMPUTER / HARD COMPUTER / NOT IN THIS WAR, HOW TO
  WIN (take the enemy capitals / hold 8 of the 15 key regions / the most land at the last season), THE LAST SEASON (48
  seasons = 12 years by default; 24, 80 or none), STORY HEROES on or off, HOW TO PLAY, START THE WAR. At least two sides
  must be in a war (the page says so). More than one YOU is hot-seat on one device.
- THE WAR'S PAGE: the world on the war map's parchment, the land drawn from Natural Earth (wider than the campaign's map:
  170 W to 165 E, so Manila, Nagasaki and New Holland are on it), each region striped in the colour of the side holding
  it (the Crown purple, the Clockwork red, the Brood green; free land only its edge). A star is a capital, a diamond a
  key region, a small black disc with a letter a building (F Fort, C Church, M Market, W Works, T Trade Post, R
  Regulator, N Nest, S Swamp). Dotted lines are sea lanes between ports. An army is a disc in its side's colour with its
  strength in it ("1.4k"), a gold ring while it can still march this season, a gold star with a hero, gold chevrons for
  its veteran ranks.
- THE TOP BAR: the season ("Spring 2771 (season 1 of 48)"), whose turn, the gold, the income and upkeep a season, the
  lands and key regions held; the buttons - and + (zoom), HELP, LOG, SAVE & LEAVE (also Esc and the phone's back: an open
  panel closes first) and END TURN.
- THE HINT along the bottom always says what to do next, in plain words ("Your armies are the discs with a gold ring.
  Tap one, then a glowing region to march...").
- A TAP on an army picks it; the regions it may go to glow gold; a tap on one marches there. A tap on a region opens its
  CARD (right on a computer, the bottom half on a phone, the map gliding so the place stays in view): who holds it, its
  land and what that land means for each side, its worth and income, its unrest, its building, the armies there (what
  they are, veterans, heroes and their gifts, MARCH WITH THIS ARMY, SPLIT IN TWO), and for your own region BUILD (each
  building with its price and what it does, or why it can't go up now) and RAISE SOLDIERS (at a capital or a muster
  building).
- THE TURN BANNER at the start of each of your turns: what came in (income, upkeep), what happened since your last turn
  (battles, risings, events), "pass the device to..." in a hot-seat war; OK goes to your capital with its army picked.
- THE BATTLE QUESTION when your army meets an army: who attacks what, both sides' soldiers and strength, the region's
  guard, "your side wins about N times in 100" if it is decided at once, and AUTO-RESOLVE or FIGHT IT. It also comes up
  in the middle of a computer's turn when it attacks one of your armies.
- LOG: what happened, newest first. HELP: nine short sections (what this is, armies, battles, defence, money, unrest,
  the sides, winning, saving). THE END: who won, every side's regions and key regions, LOOK AT THE MAP or BACK TO THE
  WARS.
- The computers' turns run by themselves, one march every 0.18 s, so a turn of three sides is over in a few seconds.

Pictures (computer 1280x720 and a phone held sideways 1600x720, by `tools/shot_world_war.gd`): docs/shots/world_war/
`<pc|mobile>_1_setup`, `_2_turn_banner`, `_3_new_war`, `_4_army_picked`, `_5_region_card`, `_6_years_on` (the computers
played three years), `_7_log`, `_8_battle_question`, `_9_help`, `_10_battle_field` (FIGHT IT: the skirmish with the
armies placed), `_11_after_battle`, `_12_victory`.

## The rules, with their numbers

### The map
- 60 regions (the list is at the end), each with a land (temperate, cold, wet, jungle, desert), a worth (1-3), maybe a
  port, maybe a key region (15). Each region's shape is the land nearer its town than any other town, cut to the coasts
  and to 20 degrees round the town. Land neighbours are regions whose shapes touch (with a few cut where a sea or the
  Alps is in the way, and a few joined); SEA LANES join ports along the old trade routes (Lisbon to Rio, Luanda, Goa's
  route round the Cape, the Manila galleon to New Spain...).
- The sides start with: the Crown Rome (capital), Naples, Milan (worth 7), and Lyon too in a three-side war (it stands
  between the other two); the Clockwork Nuremberg (capital), Saxony, Poland (7); the Brood the Amazon (its Queen), Pará,
  New Granada (7). Everything else is FREE LAND held by its own
  militia (worth x 250 + 150). 600 gold each, and one army at the capital worth about 1,300 (the Crown 12 Musketeers,
  3 Horsemen, 2 Field Cannons; the Clockwork 12 Clock Soldiers, 3 Springers, 1 Pendulum; the Brood 24 Raptors,
  8 Spitters, 2 Brutes). The Crown's fourth region makes up for standing between the other two (the simulation).

### A turn
- One turn is a SEASON (spring, summer, autumn, winter; 2771 is the first year). The sides play one after another, the
  Crown, the Clockwork, the Brood (those in the war).
- At the start of a side's turn: its INCOME comes in and its UPKEEP goes out; the climate hits its armies; armies on a
  mending place grow back; wounded heroes come back; unrest grows or falls in its regions, and a restless region may rise.
- Then the side may: MARCH each army once to a neighbouring region (land, or sea along a lane); BUILD one thing in each of
  its regions (one building a region, ever); RAISE SOLDIERS at its capital and its muster buildings (a regiment joins the
  army there, or is a new army that marches next season); SPLIT an army in two. Then END TURN.
- An army holds at most 80 units (a fought battle stays playable). Marching into your own region joins the army there.

### Soldiers (regiments)
| side | regiment | units | gold = strength |
| --- | --- | --- | --- |
| Crown | Musketeers | 6 Musketeers | 360 |
| Crown | Horsemen | 3 Horsemen | 300 |
| Crown | Field Cannons | 2 Field Cannons | 340 |
| Clockwork | Clock Soldiers | 6 Clock Soldiers | 420 |
| Clockwork | Springers | 3 Springers | 300 |
| Clockwork | Pendulums | 2 Pendulums | 400 |
| Brood | Raptors | 12 Raptors | 300 |
| Brood | Spitters | 6 Spitters | 270 |
| Brood | Brutes | 2 Brutes | 300 |
Each unit is worth its skirmish price (a Horseman with his horse 100; the Brood's creatures that hatch two from an egg at
half an egg). An army's STRENGTH is the sum.

### Buildings (one a region)
| side | building | gold | what it does |
| --- | --- | --- | --- |
| Crown | Fort | 250 | soldiers raised here, +400 to the region's defence, -6 unrest a season, armies here get back 10% a season |
| Crown | Church | 200 | -20 unrest a season, +10% income, armies here get back 10% a season (the Crown raises its own) |
| Crown | Market | 250 | +50% income |
| Clockwork | Works | 250 | soldiers raised here, +400 defence, armies here mended 10% a season (the Winders) |
| Clockwork | Trade Post | 250 | +40% income, +10% more for each Trade Post of its side next to it (land or sea) |
| Clockwork | Regulator | 200 | -18 unrest a season, +150 defence |
| Brood | Nest | 250 | soldiers laid here, +400 defence, -10 unrest a season, armies here grow back 10% a season |
| Brood | Swamp | 150 | +50% income, the land becomes WET (the Clockwork rusts in it), armies here grow back 10%; not in cold or desert |
A building taken by another side is pulled down. A capital is always a muster place and always mends its armies.

### Money (anti-snowball)
- A region pays its worth x 50 gold a season, times how well its holder lives there: the Crown temperate and wet 1.0, cold
  0.85, desert 0.9, jungle 0.8; the Clockwork temperate 1.0, cold and desert 0.8, wet 0.6, jungle 0.5; the Brood jungle 1.0,
  wet 1.0, temperate 0.75, desert 0.6, cold nothing.
- THE BEND: the side's total is raw x 1,800 / (raw + 1,800): 450 raw gives 360, 1,800 gives 900, 3,600 gives 1,200. The
  more land, the less each new region adds.
- UPKEEP: an army costs 8% of its worth a season (the Clockwork 9%: it must be wound), 2% more for each veteran rank; every
  region more than 3 steps from the capital costs 15 gold a season for each step more. A side that can't pay loses 15% of
  every army that season (deserters). Computers: Easy earns 10% less, Hard 10% more.

### Climate
- THE CLOCKWORK RUSTS: an army of it that starts its side's turn in wet land or the jungle loses 10%; at sea 5% a crossing.
  It fights at x0.85 there.
- THE BROOD CAN'T LIVE IN THE COLD: an army of it in cold land loses 30% a season (45% in winter) and fights at x0.75; a
  cold region it wins is laid waste and left free (it can't hold it). It fights x1.15 in the jungle, x1.1 in the wet,
  x0.9 in temperate land, x0.85 in the desert. A Swamp turns temperate land wet.
- THE CROWN fights x1.05 in temperate land.
- The sea: one crossing in ten meets a storm (a fifth of the army lost).

### Unrest and risings (anti-snowball)
- Every held region but the capital has unrest 0-100. Each season: +4 for each step from the capital past 2, +8 in a land
  the side hates (the Clockwork: wet and jungle; the Brood: cold and desert), +0.5 for every region the side holds past 6
  (an empire stretched thin), -8 with an army there, minus its building's calm, -4 by itself.
- From 40 a region with no army in it may RISE: the chance a season is (unrest - 40) / 120. It becomes free land again
  (its guard worth x 150 + 150), its building gone.

### Battles
- Marching into a region of another side, or into free land, is a battle. With an army on each side and one of them a
  player's (and the other a computer's), the player chooses FIGHT IT or AUTO-RESOLVE; any other battle is decided at once.
- AUTO-RESOLVE: the attacker's strength = its army's worth x (1 + 0.1 a veteran rank) x 1.1 with a hero x its land's
  factor (and the heroes' gifts). The defender's = (its armies' worth with the same bonuses + the region's guard) x its land
  factor x 1.2 (x1.35 at a capital). The guard: free land its militia; a held region worth x 100, plus its building's
  defence, plus at a capital 1,500 that FADES as the war goes on (x (1 - season / 40), never under 40%: defender's
  advantage early, a winner can finish). Each side then x a roll between 0.85 and 1.15. The stronger wins.
- The winner loses 5% + 55% x (the weaker's strength / the stronger's)^2 of its army; the loser loses 60% and FALLS BACK
  to a neighbouring region of its own with no enemy in it (an attacker to where it came from); with nowhere to go it is
  lost. The winner's armies become veterans (+1 rank, at most 3). An attacker that wins takes the region.
- A side whose capital is taken is OUT: its lands become free, its armies scatter (for the Brood: "The Queen is dead").

### FIGHT IT: a battle on the field (scripts/worldwar/ww_battle.gd, WWBattle)
1. The war is saved (with the battle in it), then a normal skirmish starts: one of the skirmish's 1v1 maps of the
   region's land (temperate: Greenhold, Twin Fords, Ashford Crossing, Amberfall Vale, Highmoor, Kestrel Rise; cold:
   Frostfang, Frostmere, Border March, Thornwood Maze; desert: Dune Sea, Redrock Canyon, Red Coast; jungle: Mirewood,
   Hollowfen, Glimmerdeep; wet: Mirewood, Hollowfen, Saltmarsh Isles, Twin Fords), picked by the war's dice.
2. The player against that side's own skirmish computer at the war's level (Hard when the other side is a player's).
   Each side has its usual camp (the hall and workers; the Brood's Mother), and beside it, a little toward the middle,
   EXACTLY the army it brought from the world map, unit by unit, with full ammunition. The region's holder gets 300 gold
   more (its walls and stores).
3. When the match ends, the survivors of each side are counted on the field: the units of the kinds its army had (units
   trained during the battle join, up to a quarter more of each kind). The winner keeps its own; if the attacker won
   and the region was the defender's, the region's guard (and a capital's walls) still stand against what is left and
   are decided at once; the loser's survivors fall back (or are lost). Then the war's page comes back with the result.
4. QUIT in the battle counts as a lost battle for the player's side. A battle cut short by closing the game is decided at
   once the next time the war is opened. A battle leaves no skirmish CONTINUE save.

### Heroes (setup STORY HEROES, on by default)
- With the first army of their side: the Crown's Lord Fairleigh (his army loses only half as much when beaten), Captain
  Ruggieri (+15% attacking a region with a building or a capital), Lieutenant Valadares (no storms at sea, no jungle
  penalty, +10% in the jungle); the Clockwork's Meister Hollweg (his army never rusts). An army with a hero is x1.1.
- A hero is never killed: when his army is destroyed he is wounded and back at the capital 2 seasons later, joining the
  army there. The Brood has no heroes (it is no person; no names, no speeches): its armies grow back in its own swamps,
  nests and at the Queen instead.

### Seasonal events (one season in five)
A plague year (every army in the jungle or the wet loses a tenth), a council in Rome (the Crown's lands calm by 20 if it
holds Rome), a season of storms (three times as many storms at sea), a good harvest (100 gold to every side).

### Winning
- TAKE THE ENEMY CAPITALS: the last side holding its capital wins.
- HOLD 8 OF THE 15 KEY REGIONS (at the end of a season), or be the last.
- In every war, at THE LAST SEASON (48 by default; 24, 80 or none) the side holding the most worth of land wins.
  THE MOST LAND AT THE LAST SEASON is only that.

### Saving
One file per war (user://worldwar/<name>.json, plain JSON), written at the end of every turn, after a battle and by SAVE
& LEAVE. The war's dice are saved too, so a loaded war goes on exactly as it would have (tested).

## The computers on the map (scripts/worldwar/ww_ai.gd, WWAI)
One order at a time, through the same calls the player uses. First soldiers until its armies are worth 1,400 + 260 for
each region it holds (where the danger is greatest, near the front, at the capital), then one building at a time (a
calming one where unrest passes 30, a muster one at a threatened front, else an income one), then more soldiers with what
is left. Then each army, the biggest first: the capital's army stays while an enemy within two steps could take it (a
part may go when it is far bigger), an army in a climate that hurts it leaves, a region of its own that is threatened is
reinforced (the capital first), armies gather into big ones near the front, a strong army marches toward the enemy;
attacks need its strength to be 1.6 (Easy), 1.25 (Normal) or 1.05 (Hard) times the defender's; the best target is
the worthiest (key regions, capitals far more, armies to beat, the side with the most land first: everyone's first
enemy), near home, not across the sea if it can help it, not where the climate hurts. The Brood never takes cold land.

## The simulation (tools/sim_world_war.gd: computers against computers, every battle auto-resolved)

`godot --headless --script res://tools/sim_world_war.gd -- wars=30 seasons=48 [level=hard] [win=keys] [off=brood]`.
Results on the final rules (seeds 1000-1029):

| war (30 each, three sides) | the Crown won | the Clockwork won | the Brood won | most regions one side ever held (of 60) | regions held at the end, on average |
| --- | --- | --- | --- | --- | --- |
| Normal computers, take the capitals, 48 seasons (the default) | 10 | 7 | 13 | 29 | 10.5 / 8.1 / 11.9 |
| Hard computers | 8 | 11 | 11 | 23 | 9.5 / 9.0 / 12.6 |
| Easy computers | 14 | 11 | 5 | 23 | 11.0 / 8.7 / 9.3 |
| Normal, hold 8 key regions | 9 | 6 | 15 | 20 | 9.6 / 8.8 / 12.5 |
| Normal, no last season, stopped at 80 | 4 by conquest | 0 | 1 by conquest | 31 | (25 wars still on at 80; 20 capitals fell) |

TWO-SIDE WARS between computers are NOT balanced yet (30 each, 48 seasons): the Crown beat the Clockwork 29-1 and the
Brood 30-0; the Brood beat the Clockwork 27-3. With two sides the free land near each start decides it and the brakes
that need a third side (everyone against the leader) don't work. With a player against one computer the player decides;
a tuning pass for two-side wars is in "What is left".

Reading it: no side runs away (no side ever held more than half of the 60 regions (31 at most, in an 80-season war); a side
averages 8-13 regions at the end); every side wins some wars at every level; the three-way war keeps itself in balance (the leader is everyone's
first enemy, unrest grows with size). Wars between computers mostly end at the last season: in 80 seasons with no limit
5 of 30 wars were won by taking every enemy capital and 20 capitals fell. A player who presses on can take capitals sooner: a capital's own guard fades from 1,500 at the start to
600 by season 24.

## How it is built
- `campaign/worldwar/regions.json`, `campaign/worldwar/land.json`: written by `tools/worldwar/make_regions.py` from Natural
  Earth's 1:50m land (public domain; the command is in its header). The regions' towns, lands, worths, ports and key
  flags, the cut and added neighbours and the long sea lanes are in that script. (In campaign/ so the export packs them.)
- `scripts/worldwar/ww_rules.gd` WWRules: every number; `ww_war.gd` WWWar: the war, every rule that changes it, saving;
  `ww_ai.gd` WWAI; `ww_map.gd` WWMap: the drawing and the camera; `ww_page.gd` WWPage: the setup, the page, the card,
  the banners, help; `ww_battle.gd` WWBattle: FIGHT IT.
- In scripts/main.gd only: the menu slot "worldwar" (MENU_SLOTS' 10th, was empty), `ww_battle` and `_ww_back` (a battle's
  end or QUIT goes back to the war), no skirmish autosave while a war's battle is on.
- Texts: tools/i18n/82_world_war.txt (227 entries, pt and es); the patch note under 0.38.999.
- Tests: `tools/test_world_war.gd` (60 checks: the data, the setup, computer turns to a winner, save/load the same and
  going on the same, the cold, winter, the waste land, rust, Hollweg, the Swamp, upkeep, far lands, the bend, unrest and
  risings, a Church, deserters, the capital's guard, a Fort, veterans, falling back, FIGHT IT with exactly the armies,
  the right computer, survivors carried back, no CONTINUE left, QUIT loses, the menu page, START, END TURN, the save each
  turn, HELP, every text in pt and es). `tools/test_menu_grid.gd` checks the new slot.

## Claude's choices (for the owner)

1. TURNS ARE ONE SIDE AFTER ANOTHER (as in Battle for Middle-earth II), not orders given together and played at once: a
   battle happens when an army arrives, so a player can always choose FIGHT IT.
2. ONE CURRENCY, GOLD, for the world map (the skirmish's gold, powder, cogs, Tension and food are inside a battle only);
   each side earns it differently by land.
3. THE STARTS are three or four regions each, the rest FREE LAND with militia (not the lore's Crown empire holding the
   world): fairness first. The Crown's fourth region (Lyon, three-side wars only) makes up for standing between the
   other two (without it the Crown won 1-3 wars in 20; with it 8-14 in 30).
4. THE CLIMATE'S NUMBERS: rust 10% a season (5% a crossing), cold 30% (45% in winter), the Brood can't hold cold land.
5. A CAPITAL'S GUARD FADES (1,500 to 600 by season 24): the design principle's "defender's advantage early that fades
   mid-game"; without it no computer ever took a capital in 80 seasons.
6. AN EMPIRE STRETCHED THIN: +0.5 unrest a season everywhere for each region past 6, and the computers attack the side
   with the most land first: the quiet brakes that kept any side from running away in the simulation.
7. MENDING for every side (capital + its buildings, 10% a season up to the army's best): the Crown raises its own
   (Church, Fort), the Winders mend (Works), the Brood lays again (Nest, Swamp). Without it the side with a mending gift
   ran away.
8. THE CLOCKWORK'S UPKEEP IS 9% (it must be wound), the others' 8%: the Clockwork won too often in the simulation.
9. FIGHT IT: both sides get their normal start camp (hall, workers, the Brood's Mother) besides the army they brought,
   so a battle is a real skirmish with an economy; the region's holder gets 300 gold more. A battle between two players
   (hot-seat) is decided at once (one screen).
10. SURVIVORS: units of the kinds the army brought; units trained in the battle join, up to a quarter more of each kind.
11. QUIT IN A BATTLE = a lost battle; a battle cut short by closing the game is decided at once next time.
12. HEROES: Fairleigh, Ruggieri and Valadares all start with the Crown's army, Hollweg with the Clockwork's; their gifts are
    small and different; wounded, never killed; the Brood has none (mending instead).
13. THE MAP is drawn in code on the war map's parchment (the code map's look), not on the painted Catholic sheets: they
    stop at 110 E and their places are fitted by hand for the campaign's pins; the world war needs Asia and New Holland and
    60 regions anywhere. The land file is new and wider (campaign/worldwar/land.json).
14. THE REGIONS: 60, named in English with pt/es names; Nuremberg and Fürth are one region; Rome, Paris, Lisbon, Nuremberg,
    Constantinople, Egypt, Luanda, the Cape, Goa, Canton, Nagasaki, Virginia, New Spain, the Amazon, Rio are the key ones.
15. A WAR ALWAYS HAS A LAST SEASON (48 by default; "none" can be chosen): computers' wars rarely end by conquest alone.
16. NO ONLINE yet (hot-seat only): it would need the war's state shared between the friends' devices and a battle's
    survivors agreed by both.
17. The computers' wait between marches is 0.18 s (a three-side turn takes a few seconds); there is no "skip" button.
18. The skirmish maps per land are hand-picked from the 1v1 maps (no jungle 1v1 map: the marsh and glow-wood maps stand in).

## What is left
- ONLINE world wars (two devices, a battle fought online between two players).
- Pictures made for the mode: the map is the code's; the painted world sheet could take its regions once it covers Asia.
- More seasonal events with stills (a plague, the council in Rome, a fleet lost) and the campaign's people in them.
- A battle between two players on one device (now decided at once).
- TWO-SIDE WARS: a balance pass (see the simulation: lopsided between computers).
- The computers could use their heroes and the sea better; the Brood leans a little strong at Normal and in key-region
  wars, weak at Easy (see the simulation): a later tuning pass with the owner's own wars.
- Sounds for the map (a march, a battle, a season's turn) and the faction music on the map.
