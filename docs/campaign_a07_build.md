# Act 1, "The Council of Rome": what was built (job a07-council, 0.38.68)

Step 9 of Act 1's build order (docs/campaign_act1_plan.md): the engine's MORE THAN TWO SIDES and SPREADING FIRE (and a
MID-MATCH SHOW), then a07_council, the FIRST CROSSING of the three lines, built as the plan and its OWNER ANSWERS of
2026-11-17 say: Rome in Lent 2770, the young King tells it (the old King frames it: same speaker, his own story), BOTH
TELLERS AT ROME (Hollweg and Lindqvist heard, and both defy the verdict), ROME FOR TWO PLAYERS (the versus friend leads
the creatures OR the automata; the other is scripted), EASY / NORMAL / HARD, NO CHOICE (the verdict is canon). It is THE
ROSTER LADDER's C4 (docs/campaign_roster_ladder.md): the CHURCH and the MISSIONARY, and the mission is built to show
what a Missionary is for: he leads the people where a soldier can't. The WORLD LORE of 2026-11-18 is in it: the verdict
is the Church's memory of THE GHOST IN THE MACHINE, Ferrer says "I told him the night before the gift" (c01's quarrel),
and the Romans hate a clever machine (the people run from the automata; in Parione they turn on them).

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite (kept short and plain on purpose). The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/a07_council.json`, written by `tools/campaign/make_a07_mission.py` (edit the script, run it) |
| the map | `campaign/maps/rome_council.json` (`campaign:rome_council`), written by `tools/campaign/make_rome_map.py` with the city generator; opens in the MAP EDITOR |
| the stills (stand-ins) | `campaign/stills/a07_01.jpg` .. `a07_07.jpg`, drawn by `tools/campaign/make_a07_stills.py`; the King's pages reuse `p01_01` |
| texts pt / es | `tools/i18n/campaign/a07_council.txt` (then `python3 tools/i18n_build.py`); the war map's new ledger lines in `warmap.txt`; the war table's versus line in `tools/i18n/50_campaign.txt` |
| the storylines, the hubs | `campaign/campaign.json`: a07 is the LAST mission of ALL THREE lines (listed once by Campaign.mission_ids); talks after Rome: the King, Cardinal Tomasz, Hollweg in exile and Lindqvist held (the King's study), Lindqvist (the Barra), Hollweg (Fürth) |
| the way in | `make_a04_mission.py`, `make_a05_mission.py`, `make_a06_mission.py`: `"next"` of the winning side (visit / expedition / crown) is a07; a07's `"needs"` keeps it LOCKED until all three are won |
| the war map | `campaign/warmap.json`: a07's pin lost its working title; rules by `rome` (few / some / all), `people`, `hollweg`, and a creatures' or machines' win (the seal broken, the Papal States green or red) |
| the roster ladder | `tools/campaign/roster_ladder.py`: a07 binds `guard` and `garrison` (C4: the Church and the Missionary), its CARD_AT (30 s: after the verdict's show) and SIDE, the cards in pt / es |
| roles | `scripts/campaign/rebels.gd`: `king_young`, `swiss`, `captain_rome`, `roman`, `roman_mob` (stand-ins) |
| the engine | `scripts/campaign/mission_run.gd`, `campaign.gd`, `rebels.gd`, `campaign_menu.gd`, `scripts/net/net_lobby.gd` (below) |
| tests | `tools/test_campaign_a07.gd` (`godot --headless --fixed-fps 30 --script res://tools/test_campaign_a07.gd`) |
| balance | `tools/sim_campaign_a07.gd` (`-- active diff=easy|normal|hard cages=few|some|all broken=kept|melted varenne=spared|executed lost=<n> until=<s>`) |

## The map: Rome (128 x 96, grass, Lent; the city generator, seed 2770)

- THE TIBER down the middle from north to south, six cells wide, with THREE BRIDGES and no other way over (the map
  script checks it: with the bridges shut, nothing of the east bank is reached from the castle): the PONTE DI RIPETTA
  (north, row 16), the PONTE SANT'ANGELO (the middle, row 40, under the castle), the PONTE SISTO (south, row 74).
  Each bridge has a west foot (`<bridge>_w`, the guard's post) and an east foot (`<bridge>_e`, the garrison's).
- THE WEST BANK: SAINT PETER'S (a Church, "Saint Peter's") on the Vatican's ground west of its PIAZZA (16-32 x 34-52,
  the obelisk and two fountains), THE APOSTOLIC PALACE (a Town Hall: the council's hall) north of it, the BORGO with
  its long street from the piazza to the castle's bridge, the CASTEL SANT'ANGELO's yard by the middle bridge (the
  guard's Barracks and Powder Mill), SANTO SPIRITO (a Church) north of the piazza, TRASTEVERE in the south-west, the
  open PRATI in the north-west (the guard's tents).
- THE EAST BANK: three quarters, each a grid of solid house blocks round a square: CAMPO MARZIO (the Piazza del
  Popolo's square), PARIONE (the PIAZZA NAVONA), REGOLA (the CAMPO DE' FIORI); THE STABLES of the specimens in the
  north-east (a Horse Breeder named "The Academy's stables", the pen), THE EXHIBITION HALL of the automata in the
  south-east (an Armoury named "The exhibition hall"), the CORSO down the east side, the PORTA PIA's square in the east
  (the Assembly's cell comes in there), the Via Papalis, the Via Giulia and the Via di Ripetta across.
- THE HOUSES THAT CAN BURN: 20 Cottages of the town ("Houses") on the city generator's lots near each quarter's square:
  5 in each east quarter, 2 in the Borgo, 3 in Trastevere (tags `q_<quarter>`, all `houses`). The rest of the town is
  props, as in Lyon and Paris.
- 898 props, 55 blocks, 22 lots, 51 areas (plus the mission's: the banks, the piazza's inside, the basilica's STEPS,
  the hall's floor, the castle's yard, the pens, the bridges' feet, the Corso's two ends).

## How it plays: THE CROWN (solo; co-op with the garrison; versus against the creatures or the automata)

Opening (the old King, then the council in session, by the flags below): Rome, Lent 2770, the King three years
crowned; Varenne's letter from exile read out (or his friends who had not forgotten); FERRER's testimony (Hollweg's own
drawings, or his own report) and "I told him the night before the gift. The ghost in the machine destroyed the
apostasy once. It was the enemy then. It is the enemy now."; VALADARES (he drew the plateau for the Crown, or gave his
map to the Church alone) and Linnea seen grown among her own; HOLLWEG (a witness, or one accused) "My machines are not
the ghost of the old age... They could learn."; the King on LINDQVIST's eggs (no secret, found out under questioning,
or ashes) and Lindqvist: "They are not monsters... the oldest things alive."

THE KING'S GUARD (PURPLE, the player): THE KING (a field officer, 380 health), FATHER TOMASZ (a Missionary, 360), 14
Musketeers, 4 Horsemen, 2 Field Cannons, a powder wagon, 400 gold and 250 powder; the castle's Barracks and Powder
Mill, SANTO SPIRITO (the Church: NEW), four tents (cottages); six SWISS GUARDS (pikemen) holding the piazza. THE KING'S
TREASURY pays 80 gold and 30 powder a minute. The ladder's C4 allow-list (the Crown's kit, the Musketeer and Field
Cannon, the Horse Breeder and Horseman, the Foundry and Mortar, the CHURCH and the MISSIONARY), no Town Hall or Farm.
THE GARRISON (BLUE: the friend's in co-op, else scripted, holding): four Musketeers at each bridge's east foot and the
Captain of the Garrison at Sant'Angelo's. THE TOWN (YELLOW): Saint Peter's, the palace, the houses, the stables and the
hall (all spared from blows), the council's four (Ferrer, Valadares, Hollweg, Lindqvist) before the palace, and THE
PEOPLE: six Romans in each east quarter's square (18).

- PART 1, THE VERDICT (2 s in). A MID-MATCH SHOW over the match (solo pauses): the Cardinal Dean reads the verdict ("No
  machine may govern itself... The specimens are to be destroyed"), Hollweg's and Lindqvist's refusal, the King: "I
  let them go. My mercy, or my mistake." Then they WALK OUT (Hollweg over Sant'Angelo to his exhibition hall, Lindqvist
  to his stables: gone when they get there), Ferrer and Valadares go into the basilica; flags `hollweg`, `lindqvist`
  defied. The King's tips: the three bridges, the garrison on their east ends. The NEW cards at 0:30.
- PART 2, THE NIGHT OF FIRE (0:50). The light to the fire night, THE FIRST FIRE in the Campo Marzio (a SPREADING FIRE:
  a house burns down in 90 s and every 18 s lights the next house within 7 tiles; Musketeers, riders or any men of the
  guard or the garrison standing by a burning house put it out: 14 s of one man's work, four men under 4 s, and they
  stop its spreading meanwhile). THE ASSEMBLY'S CELL (ORANGE) comes in by the Porta Pia: two torch-bearers and two
  militia for Parione at +0:30 and Regola at +1:10 (with a06's `varenne` EXECUTED two more groups, +1:50 and +2:30,
  and three militia at Sant'Angelo's east foot at +1:30); a torch-bearer at a house sets it alight (`torch_fire`) and
  walks to the next. Tomasz: "Let me go to them"; the King: Santo Spirito trains Missionaries, any priest can call a
  quarter. THE PEOPLE: Father Tomasz OR ANY MISSIONARY of the guard or the garrison within 4 tiles of a quarter's
  people CALLS them: they make for Saint Peter's over their own bridge (Ripetta, Sant'Angelo, Sisto) and are SAVED at
  the basilica's steps (counted). Uncalled, they RUN when the machines or the beasts come within 6 tiles (no one to
  lead them), or when three of their quarter's houses burn (25 s later). They are no longer spared: a beast that meets
  them on the way kills them. THE ROMANS FEAR THE MACHINES: an automaton near Parione's people and four Romans with
  pikes come out of the Piazza Navona and hunt the machines. +1:10 THE SPECIMENS BREAK LOOSE (the pens open; Lindqvist:
  "Not like this!"): the Raptors (and the young Sire) for the Ripetta bridge, the Spitters (and the Challenger) through
  Parione for Sant'Angelo. +1:50 HOLLWEG'S DEMONSTRATION GOES WRONG (a04's `broken` kept: "I mended them!"): the Clock
  Soldiers and Winders for the Sisto bridge, the Springers and the Pendulum through Parione for Sant'Angelo; or (melted)
  his two stop-work pieces start in the smoke and do not stop. The automata wind each other (every 15 s). Where the
  beasts and the machines meet (Parione, the Corso) they FIGHT EACH OTHER ("Let them. Every one they kill is one fewer
  at my bridges").
- PART 3, HOLD THE BRIDGES (a minute after both are out, about 3:40): "Hold the three bridges: nothing of the
  creatures or the machines may reach Saint Peter's Square" and DAWN IN 9:00 (EASY 7:12, HARD 10:48). The stables'
  cellars send a wave every 80 s, by turns to Ripetta and through Parione to Sant'Angelo (by `cages`: 4, 6 or 8, two
  of them Spitters; with all, two Tyrant Challengers at +3:20); the exhibition hall's crates send three Clock Soldiers
  and a Springer every 100 s (kept only), by turns through Parione and to Sisto. 90 s before dawn the light greys and
  RAIN comes (it puts out what is still burning). DAWN: `rome` (the quarters with at least half their houses standing:
  all five / half or more / fewer), `people` (saved of 18: few / some from 40% / many from 75%), the King's and
  Tomasz's lines at Lauds, THE WIN.
- THE DEFEATS (retry): three of the creatures or of the machines in Saint Peter's Square (their side WINS: below); the
  King or Father Tomasz killed.

## How it plays: THE CREATURES or THE AUTOMATA (versus: the friend picks one; the other is scripted)

No narrator of their own (no creature speaks, the machine has no voice): their opening is the old King's first line,
Lindqvist's (or Hollweg's) plea, and one line of instruction. One objective: CROSS THE RIVER: three of your own in
Saint Peter's Square before dawn. Their units: the specimens (or the demonstration pieces) and every wave of their side
as it comes (spawned for the friend: no scripted order reaches a person's team); caged until their part's minute (the
pens open at +1:10, the hall at +1:50). The automata are wound by the mission every 15 s (they wind each other). The
scripted other side may cross first and win (a loss for both persons: the story then follows that side). The Crown's
win at dawn ends it for both.

## The flags read and set

A flag that is missing (its mission not in the progress) reads as THE CANON: `gate` pattern, `bells` quiet, `map` drawn,
`clutch` saved, `teles` quiet, `broken` kept, `varenne` spared, `cages` some, no `eggs` taken, no `lost_to_machine`.

| flag | value | a07 |
| --- | --- | --- |
| c01 `gate` | pattern (canon) / people | Ferrer's testimony: Hollweg's own drawings / his own report from Nuremberg |
| c01 `bells` | rung / quiet (canon) | Hollweg came as a witness / as one accused |
| a03 `map` | drawn (canon) / withheld | Valadares drew the plateau for the Crown / gave his map to the Church alone, sealed |
| b01 `clutch` + `teles` | saved + told / saved + quiet (canon) / burned | the eggs no secret (Teles had written) / found out under questioning / ashes |
| a05 `cages` | few (or none) / some (canon) / all | the specimens: 3 Raptors and a Spitter / 4 and 2 / 5 Raptors, 2 Spitters, a Tyrant Challenger and THE YOUNG SIRE; Part 3's waves 4 / 6 / 8 (all: two more Challengers) |
| a05 `eggs` | taken | two more Raptors (the plateau's clutch hatched in the stables) |
| a04 `broken` | kept (canon) / melted | Hollweg's demonstration: 5 Clock Soldiers, 2 Springers, a Pendulum, 2 Winders, and the crates' waves in Part 3 / two stop-work Clock Soldiers that fail anyway, no waves |
| a04 `lost_to_machine` | 2 or more | two Springers more: the Machine's own among his pieces (the King's line) |
| a06 `varenne` | spared (canon) / executed | the opening: his letter condemns the fire; the cell small (two torch groups) / his friends burn Rome for him: four torch groups and militia at Sant'Angelo |

Flags a07 SETS (kept when won): `rome` few / some / all (and `rome_n`, the quarters that stood), `people` few / some /
many (and `people_n`, the saved), `hollweg` defied, `lindqvist` defied (always, at the walk-out). A creatures' or
machines' win sets `rome` few (`rome_n` 0). The war map reads `rome` (few: the Papal States contested), `people` (the
ledger's count), `hollweg` (the defiance's ledger line) and the creatures' / machines' win (the seal broken, the
region green / red).

## The engine (docs/campaign_engine.md "Added by Act 1's a07_council")

- MORE THAN TWO SIDES: a side whose primary objective fails (or is wiped out, or `lose`) is OUT (MissionRun.side_lost;
  `out_sides`; condition `{"out": side}`). With two sides the other wins at once, as always. With more, the winner is a
  side still in with a primary objective DONE (the machines whose crossing failed the Crown's bridges); else the only
  side still in with primary objectives; when the side out is a person's, the other person's side (versus) or, nobody
  else playing, the first side still in; when it is a scripted side, NOBODY YET: the match goes on between the sides
  still in. Teams are hostile by side, so the creatures and the automata fight each other where they meet.
- THE SPREADING FIRE: `{"burn": {"tag", "secs", "spread": {"tag", "within", "every"}, "douse_side", "douse_teams",
  "douse_secs", "first"}}`: a burning building lights the nearest building of the spread tag within `within` tiles
  every `every` s (the new fire spreads the same way); units of the dousing side (or only of `douse_teams`) standing
  within 2 tiles of its edge put it out in `douse_secs` of one man's work (two men twice as fast), slowing it and
  stopping its spread meanwhile; RAIN works as one man at every fire and no fire spreads in it. Condition
  `{"burning": {"tag", "at_least" / "below"}}`, action `{"douse": {"tag"}}`, MissionRun.fires_out (counted), mission
  `"torch_fire": {<the burn keys>, "tag"}`: a torch-bearer at a building of that tag sets it ALIGHT instead of hacking
  at it (Rebels.tick; a house already alight: he walks on to the next).
- THE MID-MATCH SHOW: `{"show": {"pages": [{"still", "lines"}]}}`: the pages (their `if` lines) full screen over the
  match (StillShow); a solo match is paused while it plays (online it is not); sent to the friend online
  (MissionRun.shows records them).
- THE VERSUS PICK: mission `"versus_pick": [sides]`: in versus the friend's seat (p2) leads ONE of these sides
  (Campaign.control_of / seat_side / make_cfg take the pick; the cfg's campaign keeps `"pick"`); the other sides'
  p2 teams are scripted. The war table's YOU PLAY row has a button for each (THE CROWN / THE CREATURES / THE
  AUTOMATA) and a line naming the computer's side; the online room (NetLobby.set_campaign) carries it.
- A CROSSING'S NEEDS: mission `"needs": [missions]`: unlocked only when every one is finished (Campaign.unlocked),
  whichever led to it; a mission in several storylines is listed once (Campaign.mission_ids).
- `"auto_tags": [{"team", "kind", "tag"}]`: every unit of that team and kind gets the tag, the ones a person trains too
  (the Missionaries of Santo Spirito are `leaders` like Tomasz).
- Roles `king_young`, `swiss`, `captain_rome`, `roman`, `roman_mob` (Rebels.ROLES).

Not built (the plan's "later"): THREE SEATS online (one person per side); the MID-MATCH SHOW is not used for the
testimony (the opening carries it).

## Balance (tools/sim_campaign_a07.gd)

The bot plays as a careful player would: the guard's Musketeers split over the three bridges' west feet (5 at Ripetta,
6 at Sant'Angelo, 4 at Sisto), one gun each at Ripetta and Sisto, the King kept in the castle's yard; from Part 2 Father
Tomasz with the four Horsemen round him goes over Sant'Angelo to the Piazza Navona, the Piazza del Popolo and the Campo
de' Fiori in turn to call the people, then home, and the riders put out the fires (nearest first); two Missionaries
trained at Santo Spirito go to the far squares; the gold buys Musketeers for the thinnest bridge. Flags: canon unless
said.

BALANCE_TABLE

Reading: a player who guards all three bridges and sends a priest to the squares wins on NORMAL in about 12:50, with
losses; one who does nothing loses when the machines (or the beasts) walk into the piazza around 7:00-10:00 (the
garrison on the east feet and the six Swiss are not enough). The people mostly save themselves when the beasts and
the fires come (they run), but uncalled they run late and the beasts take some of them on the way. The fires are cheap
to put out with the riders once the people are called; left alone a quarter burns in about two minutes.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

House style as the prologues: an oil painting in the manner of an 18th-century history painting, visible brushwork, 3:2
landscape (cut to 1280 x 853), no text or lettering anywhere. The Crown's men in PURPLE coats. References: p01_05 (the
style); campaign/hub/rome_king.png (the King, old: young here, fifty years younger, the same face, clean-shaven, dark
hair, a light crown or a circlet only in the council); campaign/hub/nuremberg_hollweg.png (Hollweg); campaign/hub/
station_lindqvist.png (Lindqvist); campaign/hub/rome_tomasz.png (Tomasz old: young here). Save each as
`art/campaign/stills/a07_0N.png` and cut it to 1280 x 853 into `campaign/stills/a07_0N.jpg` (nothing else changes). The
King's pages reuse p01_01.

- a07_01 THE COUNCIL IN SESSION. "Oil painting, 18th-century history painting style. A long Renaissance hall in the
  Vatican under a gilded coffered ceiling, frescoed walls, tall windows with evening light. Rows of cardinals in red
  robes and red birettas sit on benches along both sides. At the far end, on a raised chair under a canopy, a young
  king in his twenties in a purple coat with an ermine collar listens, chin on his hand. In the middle of the floor an
  empty space and a small table with papers. Warm, solemn light. 3:2 landscape, no text." (References: p01_05,
  rome_king.png.)
- a07_02 FATHER FERRER TESTIFIES. "Oil painting, 18th-century history painting style. In a Vatican council hall lit by
  candles, a lean Jesuit priest in his fifties in a black cassock, grey-haired, stands before rows of cardinals in red.
  He holds up a large unrolled engineering drawing of gears and a clockwork mechanism. His face is grave. An oil lamp
  on the table beside him. 3:2 landscape, no text, no legible writing on the drawing." (Reference: p01_05.)
- a07_03 VALADARES AND HIS MAP. "Oil painting, 18th-century history painting style. A weathered Portuguese explorer in
  his forties, sunburnt, in a worn leather coat and a sash with a machete at his side, stands at a table in a Vatican
  hall with a hand-drawn map of a jungle river and a towering flat-topped mountain spread before him. Pinned beside
  the map, a naturalist's sketch of a reptilian creature. Cardinals in red listen in the shadows behind. 3:2 landscape,
  no text, no legible writing on the map." (Reference: p01_05.)
- a07_04 THE ACCUSED. "Oil painting, 18th-century history painting style. In a Vatican council hall, two men stand
  apart before the cardinals: on the left an old German clockmaker with a white beard and a leather apron over his
  coat, holding a brass gear in his hand, defiant; on the right a tall elderly Scandinavian naturalist in a dark coat,
  holding a glass specimen jar with a small coiled reptile in it, his chin raised, contemptuous. Between them the
  floor is empty. Candlelight. 3:2 landscape, no text." (References: nuremberg_hollweg.png, station_lindqvist.png.)
- a07_05 THE VERDICT. "Oil painting, 18th-century history painting style. An old cardinal in red robes, the dean of the
  college, stands at a lectern in a vast Vatican hall reading aloud from a sealed parchment. Tall candles on either
  side, the other cardinals standing. The mood is final and grave. 3:2 landscape, no text, no legible writing."
  (Reference: p01_05.)
- a07_06 ROME BURNING. "Oil painting, 18th-century history painting style. Night over Rome seen from across the Tiber:
  the roofs and bell towers of the old city on the far bank lit orange by three great fires, smoke rolling up into a
  dark sky. On the near bank the dark dome of Saint Peter's. In the streets, small shapes of beasts and of tall
  mechanical brass figures among fleeing people. Reflections of fire in the river. 3:2 landscape, no text."
  (Reference: p01_05.)
- a07_07 THE BRIDGES AT DAWN. "Oil painting, 18th-century history painting style. Grey dawn and light rain over a
  stone bridge across the Tiber, the round Castel Sant'Angelo behind it. A line of soldiers in purple coats with
  muskets holds the bridge; at their head a young king in a purple coat with a drawn sword, beside a young Catholic
  priest in a black cassock. Behind them smoke rises from the far bank. Broken brass gears and a dead reptilian beast
  lie on the bridge's stones. 3:2 landscape, no text." (References: p01_05, rome_king.png, rome_tomasz.png.)

## The voice lines (for the owner's Chatterbox recordings)

Recorded lines go in `campaign/voice/a07/<line id>.ogg` (or .wav / .mp3); the game plays them when present
(CampaignVoice). The King's in the King's voice (refs king_ref.wav: the old King and the young King are the same
speaker); Hollweg's and Lindqvist's in theirs (refs hollweg_ref.wav, lindqvist_ref.wav). FATHER FERRER, VALADARES and
FATHER TOMASZ (young) are on the list of voices to design; THE CARDINAL DEAN* needs one too (two lines: the verdict).
"Rome" (the narrator), "The Creatures" and "The Automata" (versus only) can stay text. The NEW cards are not voiced.
49 lines: the King 28, Father Tomasz 7, Meister Hollweg 4, Father Ferrer 3, Dr. Lindqvist 3, Valadares 2, the Cardinal
Dean* 2.

VOICE_TABLE

## What is placeholder

- EVERY LINE (the dialogue, the objectives, the briefings, the debriefs, the hub talks, the ledger).
- The stills (stand-ins drawn in code; the prompts above).
- The roles' art (the young King, the Swiss, the Romans, the mob are other units' pictures).
- The map's look (the city generator's houses; no dome, no obelisk prop of its own: a column stands for it).

## Claude's choices for the owner

1. THE YOUNG KING IN THE FIELD: the King is a unit (an officer, 380 health) and must live; he could instead be in the
   palace only (a voice), leaving the field to Tomasz and a captain.
2. THE SAME SPEAKER for the old King's frame and the young King's lines (the King tells his own story): no separate
   "young King" voice.
3. THE CARDINAL DEAN reads the verdict (a new speaker, two lines), not the Pope (the Pope is never shown).
4. THE VERDICT AS A MID-MATCH SHOW at 2 s rather than in the opening: the opening carries the testimony, Part 1 is the
   verdict itself, short.
5. HOLLWEG AND LINDQVIST WALK OUT and are gone (removed) when they reach their hall and stables; they do not fight. Their
   defiance is always set (`hollweg`, `lindqvist` defied).
6. FOUR SIDES: the Crown, the creatures, the automata and THE ASSEMBLY'S CELL as a side of its own (ORANGE, hostile
   to all; the plan said green and black, but GREEN is the creatures'). Its torch-bearers set the houses alight
   (`torch_fire`); it has no objectives (scripted only).
7. THE PEOPLE are called by Father Tomasz OR ANY MISSIONARY (the ladder's NEW piece earns its place); they walk to the
   basilica over their own bridge by themselves (a route), not as followers of the priest. Uncalled they flee late
   (beasts or machines within 6 tiles, or three houses of their quarter burning).
8. THE ROMANS TURN ON THE MACHINES only in Parione (four Romans with pikes, once); elsewhere they flee.
9. THE FIRES are put out by the guard and the garrison only (`douse_teams`), not by the people (they run); 14 s of one
   man's work.
10. `rome` counts the QUARTERS (five, the Borgo and Trastevere among them) that kept half their houses; `people` is a
   share of 18 (few / some from 40% / many from 75%).
11. THE WIN is the Crown's at DAWN (9:00 after Part 3, the clock LONGER on HARD and SHORTER on EASY: it is a survival
   clock); the creatures' or machines' is THREE of theirs in Saint Peter's Square.
12. RAIN 90 s before dawn puts out what still burns (the plan's "or by rain").
13. THE CREATURES WITH NO MOTHER: the specimens and the stables' "cellar" waves; the plan's "number by cages" is the
   start and the wave size. The automata wound by the mission every 15 s (they wind each other: a04's lore).
14. a05 `cages` none (the creatures won a05 in versus) reads as few (a stray few in the stables).
15. THE VERSUS PICK on the war table (THE CROWN / THE CREATURES / THE AUTOMATA under YOU PLAY): the host may take
   either of the two as well; three seats (one person a side) is the plan's "later".
16. ROME IS IN ALL THREE LINES' war tables (the last mission of each), locked until a04, a05 and a06 are won.
17. NO HALL OR FARM for the guard (the King's treasury pays 80 gold and 30 powder a minute), as Paris.
18. The Swiss Guard as six pikemen on the piazza (the guard's, held), a stand-in role.

## Tests run

TESTS_RUN
