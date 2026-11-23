# Act 2, "The Gold of Vila Rica": what was built (job d01-minas)

Act 2 step 7 (docs/campaign_act2_plan.md "d01_minas"): the Crown line's first Act 2 mission, after the Council of Rome.
Minas Gerais, 2772: two years after Rome, Father Tomasz is a missionary in Brazil. In Vila Rica, the gold town, the Crown
reads the DERRAMA on the square (the gold tax the town still owes, collected in one day), and the Free Assembly's
Brazilian cell means to use that day: seize the Royal Foundry House and its gold and proclaim a free republic of the
mines. Tomasz tells it; the King frames it, and the old Cardinal (Tomasz himself, in the present) has two lines. It is
also THE ROSTER LADDER's C5: the garrison's new pieces are the ARMOURY, the MATCHLOCK and the SOCKET BAYONET.

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite (kept short and plain on purpose). The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/d01_minas.json`, written by `tools/campaign/make_d01_mission.py` (edit the script, run it) |
| the map | `campaign/maps/vila_rica.json` (`campaign:vila_rica`, THE HIGHLANDS biome: cold grass and the red earth of the mines), written by `tools/campaign/make_vila_rica_map.py` with THE CITY GENERATOR IN HILLS; opens in the MAP EDITOR |
| the city generator in hills | `tools/campaign/city_gen.py`: `hill_blob` (a rounded hill) and `stairs` (a stair found at a ragged hill edge); docs/city_generator.md |
| the stills (stand-ins) | `campaign/stills/d01_01.jpg` .. `d01_04.jpg`, drawn by `tools/campaign/make_d01_stills.py`; the King's pages reuse p01_01 |
| texts pt / es | `tools/i18n/campaign/d01_minas.txt` (written by the mission script; then `python3 tools/i18n_build.py`) |
| the storyline, the hub | `campaign/campaign.json`: d01 joins THE CROWN's line after a07 (`needs` a07); the King's study: the King's and the Cardinal's talks after d01 (the King's third line only when Ramos fled) |
| the war map | `campaign/warmap.json` already had d01's pin and rules (act2-warmap): won by `crown` / `conspiracy`, `minas` quiet / restless, `gold` few / some / all, `conspirator` taken / fled; this mission sets them as they are. tools/test_war_map.gd: d01 is open after Rome now (its "planned pin" check moved to d05) |
| the roster ladder | `tools/campaign/roster_ladder.py`: C5 = d01 (ARMOURY + MATCHLOCK + SOCKET BAYONET), bound team `garrison`, NEW cards at 8 s, side `crown`, the cards in pt / es (the game's own words: Arsenal / Armería, Mecha, Baioneta de Encaixe / Bayoneta de Cubo, AUTO-REEQUIPAR / AUTOEQUIPAR); docs/campaign_roster_ladder.md's tables updated |
| roles | `scripts/campaign/rebels.gd`: `tomasz_minas`, `meneses` (Captain Luís de Meneses, a Horseman), `ramos` (Lieutenant Inácio Ramos, an Officer on foot), `conspirator`, `martyr` (a06 Varenne executed), `miner` (a Pikeman with the townsman's look), `agitator`, `townsman`, `captured_gun`, `mule_rider` |
| the engine | `scripts/campaign/mission_act2.gd`: the condition `researched` (and its check in `campaign.gd`); docs/campaign_engine.md "Added by Act 2's d01_minas" |
| tests | `tools/test_campaign_d01.gd` (`godot --headless --fixed-fps 30 --path . --script res://tools/test_campaign_d01.gd`) |
| balance | `tools/sim_campaign_d01.gd` (`-- active [diff=easy|normal|hard] [families=save|leave] [lyon=calm|sullen|risen] [varenne=spared|executed] [rome=few|some|all] [careless] [noledges] [until=s] [save_at=s] [shots=dir] [debug]`) |
| pictures | `docs/shots/d01_minas/` (the sim's `shots=`, run under xvfb-run) |

## The map: Vila Rica (128 x 96, the highlands)

- THE TWO HILLS: the PILAR (west) and the CARMO (east), high ground made with `hill_blob`, each crowned by its church
  with a churchyard (the adro, a stone cross before the church), house blocks down the slopes, STAIRS on every side.
- THE RIDGE between them: one street on the high ground, widening into THE SQUARE with the ROYAL FOUNDRY HOUSE on its
  north side. The RUA DIREITA comes down from the square's south side by a broad stair to the lower town; a narrow
  stair goes down its north side to the diggings.
- THE DIGGINGS (north, low): the miners' shacks and pits between the hills, SANTA EFIGÊNIA at the top.
- THE LOWER TOWN (south, low): the garrison's quarter under the square (the Barracks, the ARMOURY, the Horse Breeder,
  five cottages), THE ROSÁRIO (south-west: the miners' brotherhood's church and their houses), houses south-east.
- THE ROAD TO THE COAST runs east along the hills' foot and through THE GORGE: two rock LEDGES (high ground) over the
  road, a stair up each (one from the road, one from the scrub south of it), then off the map in the east.
- THE RIBEIRÃO along the south with two fords; beyond the east ford THE HOLLOW in the scrub (where taken carts go).

## How it plays: THE GOLD OF VILA RICA (the Crown; solo, or versus against the conspiracy)

THE GARRISON (PURPLE): Captain Meneses (a hero: wounded, not killed), 14 Musketeers, 4 Horsemen, a Field Cannon, the
Barracks, the Armoury, the Horse Breeder, five cottages, 400 gold and 400 powder (40 gold and 15 powder a minute: the
Crown pays its garrison). FATHER TOMASZ (a hero: wounded, not killed). No hall, no labourers, no Foundry: a garrison
in a town, not a colony.

1. PART 1, THE DERRAMA (day). The decree is read on the square. THE TOWN'S TEMPER (starts at 3; top EASY 24 / NORMAL
   20 / HARD 16: at the top Vila Rica rises and the mission is lost) rises by one every 60 s in each of the four
   quarters nobody has spoken to, and by one for every AGITATOR who reaches a churchyard or the square. FATHER TOMASZ
   goes to the people: a moment (4 s) in a quarter's churchyard calms it (the temper -3, its rise stops; his line for
   each quarter). THE TWO HIDDEN ARMOURIES (a01's disguised houses, where the seed or the versus friend picks, among
   eight candidate houses, two in each quarter) look like any house until a man of the Crown stands a moment at the
   door; found, its men come out; closed, the temper -2 and 60 gold. The agitators come out of the armouries (one every
   65 s each, EASY 85, HARD 50) and walk to the churchyards the priest has not reached yet: the Horsemen ride them down.
   The town gives away the first armoury still hidden at 3:00 and the next at 4:30 (EASY sooner, HARD later); with
   a01's printer taken (the canon) the printer's mark gives one away at 0:24. THE ARMOURY's lesson at 0:30: research
   the MATCHLOCK and the SOCKET BAYONET, then AUTO REFIT. The signal is expected in 6:00 (a countdown: EASY 7:30,
   HARD 5:24), or 40 s after both armouries are closed (they know they are found).
2. PART 2, THE NIGHT OF THE SIGNAL. A bell from the wrong church: the night, the temper tallied (`minas`: quiet under
   10, else restless), every armoury still hidden opens its doors. The Royal Foundry House is open to blows now (it
   must stand). THE RISING comes up the stairs to the square in three waves: from the Rosário (the Rua Direita) and the
   diggings (the north stair) at once, with miners carrying picks among the muskets (three more muskets in a band whose
   quarter's armoury still stands); 55 s later along the ridge from the Pilar with THE CAPTURED GUN, and more from the
   diggings; 110 s later RAMOS's LAST PUSH up the Rua Direita. The miners are no soldiers: FATHER TOMASZ a moment in the
   Rosário's churchyard rings its bell and calls them home (they change side and walk off; the last push then comes
   without its miners). The second armoury, if it still stands, holds the conspiracy's ledger. The rising breaks when
   its last wave is spent and fewer than three are left (or 5:00 after the signal at the latest).
3. PART 3, THE GOLD ROAD (dawn). Four GOLD CARTS (d02's cargo carts with a chest of gold each) at the Foundry House;
   they leave in 40 s (put an escort with them) and go down the Rua Direita and east along the road at a walk. Nine men
   wait on THE LEDGES over the gorge (Meneses says so plainly, and pings them): send men up the ledges' two stairs.
   When the first cart nears the gorge THE AMBUSH: Ramos and his takers come down the road for the carts (TAKE A CART:
   conspirators round a cart with no soldier of the Crown by it for 5 s take it, gold and all; taken, it drives for
   the hollow over the east ford; the Crown's men round it take it back), and 8 s later three mule-train riders come
   out of the hollow over the ford, from behind. CATCH RAMOS ALIVE (a capture: worn down, a man of the Crown beside
   him); when his takers are down (or 2:30 after the ambush, or the road is done) he runs for the hollow: catch him
   before he is across, or he is gone south. The mission is won when no cart is left on the road and at least one
   reached the coast.

Lost: the town rises (the temper at the top), the Foundry House burns at night, or no gold cart reaches the coast.

## How it plays: THE CONSPIRACY (versus only)

The friend leads Lieutenant Ramos and four men in the Rosário; the armouries' places are his choice at the start (four
layouts, 30 s, else random); the agitators, the night's bands and the gorge's ambush are his to move (no scripted
orders on his men). He wins by raising the town, burning the Foundry House, bringing Tomasz down (a person hunting him:
the hero is mortal then), or taking three carts over the ford (or no gold at the coast). The King's ending for the
conspiracy: "That is not how it went." No solo mirror (the plan: versus only).

## The flags read and set

| flag | effect here |
| --- | --- |
| p01 `families` save (canon here: a01 reads it the same) / leave | Tomasz's opening line: standing by these families / "I never stopped praying for the road we left them on" |
| a01 `lyon` calm (canon) / sullen | the pamphlets on the Lyon type: "the last of it" / "Lyon still prints" (0:38) |
| a01 `lyon` risen (the Assembly won a01) | THE RECLAIM NOTE: Tomasz's letter from Lyon in unrest in the opening; no printer's mark (nothing given away) |
| a01 `printer` taken (canon: a01 is won only with him) | the printer's mark gives one armoury away at 0:24 |
| a06 `varenne` executed | VARENNE'S MARTYRS: the temper starts 2 higher, two martyrs in every night band and two more on the ledges, Tomasz's line (he asked for Varenne's life; they made his death a banner) |
| a07 `rome` few | the temper starts 3 higher; Rome's pamphlet ("ROME BURNED AND THE CHURCH DID NOT FALL") |
| d04 `crates` opened (if the Clockmaker's d04 was won) | THE D04 HINT made plain: Tomasz reads Concórdia's name in the ledger (the plan's cross-link: the guild's agents' gold) |
| SETS `minas` | quiet / restless: the temper at the signal (under 10 / 10 or more) |
| SETS `gold` | few / some / all: the carts at the coast, as a share of four (`gold_n` the number) |
| SETS `conspirator` | taken (Ramos captured) / fled (he crossed the ford, or a versus win without his capture) |
| SETS `ledger` | found: the second armoury closed (the conspiracy's ledger read). Not in the plan's list: Claude's choice 9 |

Missing flags take the canon (families saved, Lyon calm, the printer taken, Varenne spared, Rome some).

## How Tomasz grows in this mission (the owner asked for the existing cast made deeper)

- In Lyon (a01) he was a young priest who found his voice on a square; here he is about thirty, a missionary who ASKED
  to go to Brazil after Rome ("He said the fire would come there next, and he wanted to be standing in it").
- He goes to the people before the soldiers do: four churches, four different people (shopkeepers, the masters of the
  mines, the miners' own brotherhood, the diggers), and at the Rosário he LISTENS before he speaks ("They knew the tax
  better than any officer").
- He sees the grievance is real and does not take the rebels' side: the tax may be argued, a rising cannot be taken
  back; the Church is "on the side of the souls in this square, all of them". The King, in the frame, admits the doubt
  himself ("I did not lower the tax. Perhaps I should have. Tomasz never said so; he only sent me the names of the
  dead.").
- At night he does what no soldier can: he calls the miners home from the Rosário by its own bell, and not all come.
- On the gold road he rides with the gold "to bury whoever died on that road". He hears Ramos's confession and writes
  to the King for his life, as he did for Varenne's.
- His lesson: "In Lyon I had learnt to speak to a crowd. In Minas I learnt to stay with it afterwards." The old
  Cardinal still keeps the list of the dead (three hundred names) and reads it on the feast of the Rosary.
- With a06 `varenne` EXECUTED, Varenne's MARTYRS: his face on every pamphlet, drawn as a saint; Tomasz, who asked for
  his life in Paris, sees the execution turned into a banner (twice the trouble for the garrison: more muskets in every
  band and on the ledges, a hotter town).
- Captain Meneses is a local minor figure (the owner's rule): blunt, loyal, respectful of the priest ("Then go and get
  them back, Father, if you can").

## Balance (tools/sim_campaign_d01.gd; the last runs)

The bot (the garrison): the Armoury researches both pieces, AUTO REFIT on, the Barracks trains Musketeers while there
is gold; Tomasz walks to the nearest uncalmed churchyard, at night to the Rosário, at dawn behind the carts; the
Horsemen ride down agitators, at dawn go for Ramos; two Musketeers knock at the candidate houses in turn and the rest
break into any armoury found; at night a third of the men at each of the square's stairs and on the ridge; at dawn
eight climb the ledges (four each) and the rest escort the carts.

BALANCE_TABLE

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

- d01_01 VILA RICA. "Oil painting, 18th-century history painting style. A colonial mining town spread over two steep
  green hills joined by a ridge, whitewashed houses with red tiled roofs, a baroque church with twin towers on each
  height, a stone square on the ridge with a crowd in the middle, red earth showing where the hills are dug. Morning
  light, blue mountains behind. 3:2 landscape, no text." (References: a01_01.jpg, p01_05.jpg.)
- d01_02 THE DERRAMA. "Oil painting, 18th-century history painting style. In a stone square an official in black reads
  a tax decree from the steps of a white colonial government building before a line of soldiers in purple coats; an
  angry crowd of miners and townsmen in work clothes; a young priest in a black cassock moves among them. 3:2
  landscape, no text." (References: rome_tomasz.png (younger), a01_03.jpg.)
- d01_03 THE STAIRS. "Oil painting, 18th-century history painting style. Night on steep stone stairs between white
  houses; soldiers in purple coats charge upward with fixed bayonets against men with muskets behind an overturned cart
  at the top; a fire glows behind the houses. 3:2 landscape, no text." (References: a06_01.jpg, a01_04.jpg.)
- d01_04 THE GOLD ROAD. "Oil painting, 18th-century history painting style. A mule train of carts with iron-bound chests
  goes down a rocky gorge road at dawn escorted by horsemen and musketeers in purple coats; men fire from the rocks
  above; a priest in black walks behind the last cart. 3:2 landscape, no text." (References: a05_03.jpg, a06_02.jpg.)

The conspiracy's opening reuses d01_02, its ending d01_03 and the King's Rome still (p01_01).

## The voice lines

The table is in docs/chatterbox_todo.md ("d01_minas"), with each dramatic line's feeling (VOICE_COUNT lines; the
narrator's lines and the three NEW cards can stay as text). New voices to design: Tomasz grown (about thirty; one voice
aged by pitch between a01's young priest and the Cardinal would do), Captain Luís de Meneses, Lieutenant Inácio Ramos,
"a townsman" (one line).

## Pictures (docs/shots/d01_minas/, CHECK THE FEEL)

SHOTS_NOTE

## What is placeholder

Every line of text (en, pt, es). The four stills. Meneses, Ramos, the conspirators (the rebels' militia art), the
miners (a Pikeman with the townsman's look), the agitators (Lyon's runners), the captured gun and the mule riders wear
stand-in art; no portraits for Meneses or Ramos yet (their initials show; Tomasz, the King and the Cardinal have
theirs). No new sounds (the bell is c01's bell_toll).

## Claude's choices for the owner

1. THE MAP ON THE HIGHLANDS BIOME: Minas is not the southern highlands, but the biome's red earth (terra roxa) and cold
   grass read as the gold country's dug red hills better than Lyon's green; its araucaria trees are a stretch for Minas
   (a Minas biome later could swap them).
2. TWO HEIGHTS ONLY: the engine has low and high ground, so Vila Rica is two hills and a ridge as ONE high mass with
   stairs down every side, the diggings and the lower town below. The "height pass" the plan asked for is a rounded
   hill (`hill_blob`) and stairs that find a ragged edge (`stairs`), not a third level.
3. THE TEMPER RISES BY QUARTERS AND AGITATORS: a quarter nobody has spoken to adds one every 60 s (the tax collectors
   at work), every agitator at a churchyard or the square one more. Tomasz's STAY in a churchyard (4 s) calms that
   quarter for good (-3 and its rise stops). So the day is Tomasz's walk, the riders' chase and the search at once.
4. THE ARMOURY STANDS AT THE START: the garrison has no labourers to build one; the C5 lesson is the research and the
   REFIT (AUTO REFIT), told plainly on the NEW cards and by Meneses.
5. THE RISING IN THREE WAVES (the plan's "two quarters at once" first, then the Pilar along the ridge with the
   CAPTURED GUN, then Ramos's last push): one wave would be over in a minute; three keep the night about holding three
   stairs and choosing where the reserve goes.
6. THE MINERS CALLED HOME: the plan has Tomasz going house to house by day; at night he has a job too (the Rosário's
   bell), and the last push comes without its miners if he did it. The brotherhood is the miners' own (the Rosário
   churches of Minas were the brotherhoods'); written with respect, no accent and no caricature.
7. THE GOLD ROAD: the carts wait 40 s at the Foundry House, then go by themselves at a walk (0.8 of a cart's pace);
   the ledges' men hold and shoot until the ambush is sprung, then come down the stairs for the carts; three mule-train riders
   come from behind out of the hollow. Taken carts drive back to the hollow over the east ford and can be taken back
   on the way. The carts are spared (only TAKEN, never shot to pieces), as d02's.
8. AT LEAST ONE CART MUST REACH THE COAST: none = the gold is the conspiracy's, lost (a passive player loses long
   before). `gold` few is one cart, some two or three, all four.
9. A NEW FLAG `ledger` found (the second armoury closed): not in the plan's list, but it is the d04 hint made a fact the
   later missions (d07's council, d09's crossing) can read.
10. RAMOS RUNS FOR THE HOLLOW when his takers are down, 2:30 after the ambush, or the road is done; the player can still
    catch him on the way (45 s at most). Fled = `conspirator` fled and the war map's dashed road to Concórdia.
11. VARENNE'S MARTYRS are "more", not "twice": two more muskets in every band and on the north ledge, the temper 2
    higher. Twice the militia measured too hard for a first Act 2 mission at NORMAL.
12. THE KING'S DOUBT ABOUT THE TAX ("Perhaps I should have"): the King narrates truthfully and the Crown is the good
    side; a king who admits a hard tax may have been too hard is honest, not a twist. The owner may cut it.
13. a01 `lyon` RISEN is a RECLAIM NOTE only (Tomasz's letter, no printer's mark): a whole reclaim part waits on the
    owner's answer to the plan's question 6.
14. THE KING COMMUTES RAMOS TO EXILE when he was taken ("You may judge whether I learnt from Paris"): the echo of
    Varenne. If the owner wants him hanged, one line changes.
15. THE CONSPIRACY'S COLOUR is ORANGE (a07's choice for the Assembly; GREEN is the creatures').

## What is left

- The owner's text, the stills, voices and portraits.
- d05 reads nothing from d01 yet; d07 / d09 may read `conspirator` fled (Ramos in Concórdia's council) and `ledger`.
- A Minas biome (no araucarias) if the owner wants one.

## Tests run

TESTS_RUN
