# THE WAR MAP's ACT 3 (job act3-warmap, step 2 of Act 3's build order)

Step 2 of docs/campaign_act3_plan.md's build order ("THE WAR MAP's ACT 3: the world view, theatre views, the clock, a
CLOCK SIM"), built on the owner's answers of 2026-11-28 (all fifteen as recommended; answer 6: "the clock, one colony a
year from the theatre left alone longest"). The same data file and the same code as Acts 1 and 2 (docs/war_map_v1.md,
docs/war_map_act2.md); the new views are drawn in code with a painting slot each. ALL TEXT IS A PLACEHOLDER. There is
still NO Brood skin.

## What the player sees

- Once BOTH FRONTS of Brazil are won (d10 The Jungle Front and d11 The Siege of Concórdia) the war map's act turns to
  ACT 3 ("Act 3: 2781-2790") and it opens on THE WORLD: the whole globe, from Quebec to Sydney and the edge of the ice.
  The view buttons are now THE WORLD, THE AMERICAS, AFRICA, THE INDIES, THE SOUTHERN SEAS and EUROPE (a wider one, with
  Lisbon, for the night and the finale). Acts 1 and 2 keep their own buttons (the painted world, Brazil, Virginia,
  Europe, the Amazon) and see nothing of Act 3 until it opens (every Act 3 pin, mark, region and note carries `"act": 3`).
- After the night (e16, e17 and e18 all won) the act is "The present: 2795" and the map opens on EUROPE (the finale).
- THE THEATRES' NAMES stand large on the map in spaced capitals, and under each the clock's word for it: SETTLED (in
  green), "Not fought yet", "Fought this year", "Left alone 2 years", and, in red with a small ticking clock, NEXT TO FALL.
- THE CLOCK'S PLATE (bottom middle of the map, in every skin, every view of Act 3): THE YEAR 2784, "Colonies held: 9 of
  12", and in red "Next to fall, after 1 more win: THE AMERICAS (Potosí)" (or "No colony is at risk at the next turn of
  the year.", or after the night "The night has come: the clock has stopped."). SAY IT PLAINLY: the player always sees
  what the next win costs.
- THE COLONIES: twelve regions on the clock, each the Crown's at the act's start (the strong purple); a fallen one turns
  green (the creatures) or red (the machines), with a ledger line ("2783: Mozambique fell to the creatures."). Taken back,
  it turns purple again ("2786: The Moluccas was taken back.").
- THE LEDGER opens with THE CLOCK: the year, the rule in one sentence, and each theatre with its colonies, "(fallen)" by
  the lost ones, "settled" or "next to fall" by its name (the next to fall in red).
- THE PINS e01-e20 (all planned for now: each says what it will be about, where and when, and what opens it). The five
  OPTIONAL pins wear a small gold ribbon under the seal, and their card says "OPTIONAL: it holds its theatre, and turns
  half a year". Once the night has begun the optional pins not played are CLOSED (a grey seal, a grey ribbon, "Closed:
  the night came before it was fought."). The night's three pins wear the night's clock once all ten core missions are
  won ("The night: three ports burn at once. The first you fight is the freshest; the last has grown."). A pin whose
  colony the clock took says "The clock took this colony: winning here takes it back."
- THE MARKS: the allies' crowns (Kongo, Ethiopia, the Viceroy of Goa, Manila, New Spain; Kongo's falls with `kongo`
  fell), the SEA ROADS that carried the dangers (the eggs from the Barra to Luanda and the machines from Concórdia round
  the Cape to Goa, shown when Act 2's sparks got away; the Spice Islands' eggs, the Manila ship to the gold fields, the
  Luanda hulk to the northern shore, shown with their missions), the REFUGEES' ROADS (Virginia to Quebec, Brazil's
  interior to the coast), THE RUIN (a sealed stone, or an open book in red, by e06 `ruin`), the Cold Forge ("Beyond the
  map", then broken), Lisbon burning, Goa lost, the siege of Rome and the fleet off the Tiber.
- THE SKINS: THE BRASS MAP (the Clockmaker's) engraves "Goa. The guild's last brass map, 2783.", "Nagasaki. Where it can
  be stopped.", the gold fields, "South of every map: the forge in the ice."; THE SPECIMEN CHART (the Naturalist's) has
  Valadares' notes up the Congo and, after e06, LINDQVIST'S ANNOTATIONS IN RED INK ("L.: they were made. I was wrong
  about the one thing that mattered.", "L.: the heat hurries them; the cold nights stop them."). Both read the same
  holders as the King's parchment (Act 2's rule), both show the clock's plate.

## THE CLOCK

### The rule (campaign/warmap.json "clock"; WarMapData.clock)

1. The year starts at 2781 when Act 3 opens. It TURNS after every TWO wins of Act 3's theatre missions (e01-e15; any
   side's win counts, as the story goes on); an OPTIONAL mission counts HALF a win (`optional_weight` 0.5). At most 8
   turns. Lost tries do not count: a mission lost and played again costs no years.
2. At each turn the theatres that are not SETTLED (all their core missions won) and have been LEFT ALONE (no win there)
   for at least TWO whole years (`grace` 2) are candidates; the one left alone LONGEST loses its next colony. Ties: the
   one whose next colony falls to the creatures (the plan: "the swarm is quicker than the Machine"), then the order
   Africa, the Americas, the Indies, the Southern Seas. A theatre with nothing left to lose passes the loss to the next
   (`pass_on`). At most one colony a year: owner answer 6.
3. A win counts as attention for its own theatre; e15 (the Cold Forge, beyond every theatre) for Africa and the Indies.
4. HEAD STARTS: Act 2's sparks that got away start their theatre a year behind: Africa if d12 (Luanda) was not played or
   its eggs escaped, the Indies if d13 (Goa) was not played or its machines were shipped (the plan's Claude's choice 3
   reads both unplayed as got away).
5. TAKEN BACK: a fallen colony whose own mission is won the Crown's way comes back and is safe from then on: Potosí by
   e02 `potosi` held, the Moluccas by e11 `spice` cleared, Manila and the lake by e10 `manila` held, the gold fields by
   e13 `goldfields` held, the northern shore by e14 `shore` burned (the rangers' win). Won before the colony fell, the
   mission keeps it safe.
6. THE NIGHT STOPS THE CLOCK: once e16, e17 or e18 is won nothing more turns (an optional mission played after it
   changes nothing), and the optional pins not played close.
7. The colonies, in their fall order (the climate's, the plan's table): THE AMERICAS the Caribbean (green), Brazil's
   interior (to the danger left to grow at d09: `first` brood = the machines, `first` clockwork = the creatures),
   Potosí (red), Virginia's interior (green); AFRICA Luanda's hinterland, Mozambique, the Cape (all green); THE INDIES the
   Moluccas, Malacca, Manila and the lake (all red); THE SOUTHERN SEAS the gold fields (red), the northern shore (green).
   Never on the clock: Quebec, New Spain, Ethiopia, Goa, Nagasaki, Sydney Cove (their fates are their missions' flags).
8. The progress keeps the order of the wins: Campaign.record numbers every newly recorded mission (`seq`, a counter in
   the progress) and writes THE CLOCK's colonies (`colonies`: {region: holder}) after every record: the ledger's last
   mark ("The colonies standing: half or more still the Crown's", act3-engine0) reads them through
   Campaign.colonies_share. An old save without `seq` takes the pins' order.

### The numbers, before and after (tools/sim_war_clock.gd)

The sim plays Act 3 through WarMapData.clock itself, 1,704 runs a setting: RANDOM orders (any open pin next; with every
optional pin, none, half at random, and with 20% lost tries and 30% of wins going to the danger), the 24 THEATRE BY
THEATRE orders (each theatre's whole line, then the next; with and without the optional pins), ROUND ROBIN (one mission
from each theatre in turn) and CAREFUL (always the theatre left alone longest, its optional pin as soon as it opens);
every one again with Act 2's sparks stopped. Colonies lost of 12, mean (min-max):

| order | BEFORE: the plan's proposal | AFTER: the numbers in the data |
| --- | --- | --- |
| careful, all optional | 5.00 (5-5) | 0.00 (0-0) |
| careful, no optional | 4.00 (4-4) | 0.00 (0-0) |
| round robin, all optional | 6.00 (6-6) | 0.00 (0-0) |
| round robin, no optional | 4.00 (4-4) | 0.00 (0-0) |
| random, all optional | 4.99 (3-7) | 2.13 (0-4) |
| random, half the optional | 4.71 (3-7) | 2.02 (0-4) |
| random, no optional | 3.85 (3-4) | 2.12 (0-4) |
| random, losses and mirror wins | 4.63 (3-7) | 2.23 (0-5) |
| theatre by theatre, all optional | 5.00 (4-6) | 2.58 (1-4) |
| theatre by theatre, no optional | 3.75 (3-4) | 2.75 (2-4) |
| theatre by theatre, no optional, Act 2's sparks stopped | 3.75 (3-4) | 1.92 (1-3) |

When they fall (all runs): BEFORE 2782 1704, 2783 1704, 2784 1704, 2785 1578, 2786 810, 2787 218, 2788 16 (a colony
every year to the end); AFTER 2782 515, 2783 1069, 2784 916, 2785 514, 2786 100 (the danger is early, while the
theatres are open). Which fall most AFTER: Luanda's hinterland (1003 of 1704 runs), the Caribbean 648, Mozambique 484,
Malacca 328, Brazil's interior 276; Virginia's interior almost never (3).

THE PLAN'S PROPOSAL ("the year turns after every two wins; the theatre neglected longest loses a colony", no grace)
FAILS ITS OWN AIM: with four theatres and two wins a year there is ALWAYS a theatre left alone, so a colony falls every
year until everything is settled, whatever the order. A careful player loses as much as a careless one (5 v 4.4 on
average), and the optional missions, which the plan calls "extra years of help", only cost colonies (every optional
win turns the clock: round robin with them loses 6, without 4). The plan's "about six to eight" fall only when every
optional pin is played. So the numbers were tuned (the grid: `-- grid`, below):

- GRACE 2 (a theatre loses a colony only after two whole years without a win): the order matters. Keeping every
  theatre in hand (careful, round robin) keeps all twelve colonies; a theatre fought to its end before the next
  (theatre by theatre) loses 2-4, 2.7 on average; a random order 2.1.
- OPTIONAL WINS COUNT HALF A YEAR: they still turn the clock (the plan), but they hold their theatre and are no longer a
  net loss (random with all optional 2.13 v without 2.12).
- TAKEN BACK (the plan's "a fallen colony can return as a RECLAIM PART in a later mission in its theatre", as the
  mission at its place).
- HEAD STARTS from Act 2's sparks: stopping d12 and d13 is worth about one colony (theatre by theatre 2.75 -> 1.92).
- The campaign NEVER LOCKS: the clock only changes holders and ledger lines; no core pin ever closes; every one of the
  3,408 runs (both settings) reached the night with all ten core missions played. Never two colonies in a year, never one
  from a settled theatre, never one after the night began (the sim's checks). The worst order of all loses 5 of 12.

The grid tried (careful / round robin / theatre by theatre / random / the worst): per_year 2, grace 1: 2.0 / 2.5 / 2.7 /
2.7 / 5 (a careful order is no better); per_year 1.5: 3-4 everywhere (too harsh, and again order-blind); grace 3: 0 /
0 / 1.8 / 0.9 / 3 (toothless); a year's head start for every theatre (or the Americas and the Seas): 0 / 0 / 2.7-3.1 /
2.2-2.6 / 5-6 (no better reason in the story than the sparks, so not kept).

`godot --headless --script res://tools/sim_war_clock.gd` prints both tables and its CHECK lines ("war clock: 0
failures"); `-- detail` every order and its fallen colonies; `-- grid` the tuning grid.

### The years shown and the pins' dates

The clock's year counts turns (2781 + turns): with every optional played the act ends in 2787 at most (12.5 wins), with
the core only in 2786. The pins keep the plan's story dates (e12 Sydney Cove 2788, e14 and e15 2789): Claude's choice
6. The night is always 2790.

## The data (campaign/warmap.json, written by tools/campaign/warmap_act3.py)

`python3 tools/campaign/warmap_act3.py` writes Act 3's part (every item carries `"act3": true` and is taken out first,
so it can run again; tools/campaign/warmap_act2.py now keeps Act 3's acts, notes and the views' `acts` when it runs).
New in the file:
- `bounds` [-170, -72, 180, 76] (was [-170, -48, 110, 76]); campaign/warmap_land.json made again for them by
  tools/campaign/make_warmap_land.py (Natural Earth 1:50m: Asia, Australia, the edge of Antarctica; the Congo, Lualaba,
  Zambezi, Nile, Ganges, Indus, Murray and Darling added to the rivers; Acts 1-2's land unchanged, checked: the old
  file is made again byte for byte from the old bounds).
- `views`: `globe` [-118, -48, 160, 62], `americas`, `africa`, `indies`, `seas`, `europe3`, each with `"acts": [3, 4]`;
  the old views got `"acts"` ([1, 2]; Brazil [2]). WarMapData.views_for(act).
- `acts`: Act 3 (if d10 and d11 are done: view `globe`) and the present (if e16-e18 are done: view `europe3`, act 4).
- `regions` (17): the twelve colonies, Quebec, New Spain, the Kingdom of Kongo, Ethiopia, Nagasaki, Sydney Cove (Virginia's
  interior and Luanda, Goa are Act 1's and Act 2's).
- `marks` (26) with the new kinds `theatre`, `crown`, `ruin`, `ruin_open`; `pins` e01-e20 with `theatre`, `optional`,
  `night`; `rules` (62) by the plan's flags; `notes` (10) with `red` for Lindqvist's.
- `clock`: start, stop, first_year, per_year, optional_weight, grace, pass_on, max_turns, tie, attention, the theatres
  (core, optional, head, colonies with `to`, `to_if`, `reclaim`) and the ledger's words.
- campaign/warmap_mountains.json: the Great Dividing Range, the Himalaya's east, the Western Ghats, the Andes south.

### The pins

| pin | line | theatre | place, date | after |
| --- | --- | --- | --- | --- |
| e01_brazil | Crown | the Americas | Brazil, the road to the coast, 2781 | d10, d11 |
| e02_potosi | Crown | the Americas, optional | Potosí, the Andes, 2784 | e01 |
| e03_virginia | Crown | the Americas | Virginia, 2787 | e01 |
| e04_kongo | Crown | Africa | São Salvador do Congo, 2781 | d10, d11 |
| e05_river | Naturalist | Africa | The Congo, 2782 | e04 |
| e06_taken | Naturalist | Africa | A station in the forest, 2783 | e05 |
| e07_highlands | Crown | Africa, optional | The Ethiopian highlands, 2784 | e06 |
| e08_arsenal | Clockmaker | the Indies | Goa, 2783 | d10, d11 |
| e09_nagasaki | Clockmaker | the Indies | Nagasaki, 2785 | e08 |
| e10_manila | Crown | the Indies, optional | Manila and the lake, 2786 | e09 |
| e11_spice | Naturalist | the Indies | The Moluccas, 2787 | e09 |
| e12_exiles | Crown | the Southern Seas | Sydney Cove, 2788 | d10, d11 |
| e13_gold | Clockmaker | the Southern Seas | The gold fields, 2788 | e12 |
| e14_shore | Naturalist | the Southern Seas, optional | The northern shore, 2789 | e13 |
| e15_forge | Clockmaker | (Africa and the Indies), optional | The edge of Antarctica, 2789 | e06, e09 |
| e16_lisbon, e17_goa, e18_port | all three | the night | Lisbon / Goa / the Atlantic port, Pentecost eve 2790 | the ten core |
| e19_tiber | all three | the finale | The Tiber, 2795 | e16-e18 |
| e20_rome | all three | the finale | Rome, 2795 | e19 |

### The rules (by the plan's flags; WarMapData.problems checks them against each mission's JSON once it is built)

| when | the map |
| --- | --- |
| d10 + d11 won | every colony and ally the Crown's, the theatres' names, the allies' crowns, "Beyond the map", Lisbon |
| d12 not played or `luanda` escaped | the eggs' sea road; Luanda uneasy; Africa a year behind |
| d13 not played or `goa_seed` shipped | the machines' sea road; Goa uneasy; the Indies a year behind |
| e01 `colonists` few / some / many | the refugees' road to the coast; a ledger line each |
| e02 `potosi` held / lost | Potosí taken back or the machines' |
| e03 `fairleigh` rode_out / rode_with, `virginia` few / some / many | the refugees' road to Quebec; Virginia uneasy |
| e04 `kongo` stood / fell | Kongo's crown stays, or Kongo green and São Salvador burnt |
| e05 `nests` found / blind | ledger lines |
| e06 done, `ruin` sealed / opened | Lindqvist taken; the sealed stone or the open book |
| e07 `ethiopia` held / lost | lost = Ethiopia uneasy |
| e08 done, `matthias` alive | ledger lines |
| e09 `stopwork` rung / kept, `nagasaki` few / some / many | kept = Nagasaki uneasy |
| e10 `manila` held / lost | the Manila ship's road; lost = the lake the machines' |
| e11 done, `spice` cleared / burning | the eggs' road to the islands; burning = the Moluccas uneasy |
| e12 `exiles` canister / pardon | canister = Sydney uneasy |
| e13 `goldfields` held / lost | lost = the gold fields the machines' |
| e14 done, `shore` green / burned | the Luanda hulk's road; green = the shore the creatures' |
| e15 `forge` broken / standing | the broken forge |
| the night begun | "The clock has stopped." |
| e16 `lisbon` held / burning; e17 `goa_night` held / lost; e18 `atlantic` held / lost | Lisbon burning; Goa the machines' |
| e19 done, `deserters` spared / hanged | the siege of Rome, the fleet |
| e20 `ending` holds / falls | falls = Rome uneasy |

The flag names are the plan's (and act3-engine0's ledger in campaign.json uses the same: `kongo` stood, `ethiopia` held,
`virginia`, `fairleigh` rode_with, `stopwork` kept, `ruin` opened, `exiles` pardon, `forge` broken, `colonists`,
`lisbon` held, `goa_night` held, `atlantic` held, `deserters` spared). A mission built later that names them otherwise
fails WarMapData.problems (test_war_map's data check) and must rename them here or there.

## Code

- `scripts/campaign/war_map_data.gd`: THEATRES; MARK_KINDS + theatre, crown, ruin, ruin_open; `views_for(act)`,
  `theatre(id)`, `attention_of`, `won_order`, `clock(p, over)` and `_clock_pick` (THE CLOCK, pure: the sim passes its
  own numbers in `over`), `colonies(p)`; `state()` applies the clock (fallen and taken-back colonies, their ledger lines
  with `loc_args` translated in `ledger_text`, the night's closed optional pins) and returns `"clock"`; `problems()`
  checks the clock's data and the views' acts; `strings()` has the clock's words and the theatres' names.
- `scripts/campaign/war_map.gd`: `now(x)` (an item of an act not reached yet is not drawn or tapped), `_draw_theatre`,
  `_draw_clock_plate` (both drawn and painted maps), `_draw_ribbon` (the optional pins), a closed pin drawn locked, the
  crown / ruin / open-book marks, the chart's red notes.
- `scripts/campaign/campaign_menu.gd`: the view buttons by act; THE CLOCK at the top of the ledger (`LedgerClock`); the
  pin card's theatre and OPTIONAL line (`CardTheatre`), closed (`CardClosed`), taken back (`CardReclaim`).
- `scripts/campaign/campaign.gd` (two small places in `record`): the wins' `seq`, the progress's `colonies`.
- Texts: tools/i18n/campaign/warmap_act3.txt (en, pt, es); the patch notes under 0.38.999.

## Pictures (docs/shots/war_map/act3/, by tools/shot_war_map_act3.gd)

`xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_war_map_act3.gd -- <dir> pc`
(and `--resolution 1600x720 ... mobile`); saved as 256-colour PNGs. Each as pc_ and mobile_: a3_1 THE WORLD at the act's
start (Africa next to fall, a year behind); a3_2 the middle of the act (2784, 9 of 12, the Americas next); a3_3 THE
AMERICAS; a3_4 AFRICA with an optional pin's card (the ribbon); a3_5 THE INDIES with a planned pin's card; a3_6 THE
SOUTHERN SEAS (settled); a3_7 the ledger with THE CLOCK; a3_8 the night begun, an optional pin closed; a3_9 the present
on EUROPE; a3_10 THE BRASS MAP on the world; a3_11 the brass map zoomed on Goa (its engraved words); a3_12 THE SPECIMEN
CHART on the world; a3_13 the chart zoomed on the Congo (Lindqvist's notes in red ink, the open book). Checked for
overlaps: the clock's plate moved from the top (over Europe's seals) to the bottom middle (the South Atlantic); the
globe view narrowed to the theatres (the whole bounds did not fit a screen and showed only the north); the Americas'
and Africa's names moved off the allies' crowns; the chart's notes off the Congo's pins.

## ChatGPT prompts for the owner (one request each, standing alone, at most 3 reference images)

Each sheet, once made, goes to art/campaign/warmap_<view>_chatgpt.png and is fitted by tools/campaign/
fit_warmap_paintings.py (its landmark lists for the five views are written there); the brass and chart redraws follow
as painted_brass_<view>.jpg / painted_chart_<view>.jpg on the same fit (owner 2026-11-28).

1. THE WHOLE WORLD (view `globe`; references: (a) docs/shots/war_map/act3/pc_a3_1_parchment_world_start.png for the
   coasts, (b) campaign/warmap_art/painted_world.jpg for the style, the frame and the saints):
   "An antique hand-painted world map in the style of an 18th-century Catholic royal cartographer, landscape format,
   1536 x 1024 pixels, from the Pacific coast of America on the left to Japan and Australia on the right, from the
   Arctic down to the edge of Antarctica. Follow the first reference image's coasts as closely as you can. The land
   painted by its landscape, never by countries: rainforests dark green, deserts ochre, mountains as small inked peaks,
   the great rivers in blue. The seas pale blue-green with fine wave hatching, three Portuguese ships with red crosses on
   their sails on the long routes round Africa and to the Indies, one sea serpent in the Pacific. In the top left a small
   icon of Our Lady Star of the Sea with a gold halo; bottom left an empty crowned cartouche with laurel. No text, no
   letters, no borders between regions. Soft even light."
2. THE AMERICAS (view `americas`, references: (a) pc_a3_3_parchment_americas.png, (b) the Brazil sheet
   art/campaign/warmap_brazil_chatgpt.png for the style): "An antique hand-painted map of the Americas from Quebec to the
   Rio de la Plata ... [as 1, the land by its landscape: the northern forests, the Caribbean islands in turquoise
   shallows, the Andes as a chain of inked peaks, the Amazon dark green, the silver mountain of Potosí as a lone red-brown
   peak]; one ship off Virginia; an empty crowned cartouche bottom left; no text."
3. AFRICA (view `africa`, references: (a) pc_a3_4_parchment_africa_optional_card.png, (b) the world sheet): "An antique
   hand-painted map of Africa from Cape Verde to Madagascar ... [the Sahara ochre, the Sahel's dry grass, the Congo's
   forest dark green with the great river in blue, the Ethiopian highlands as raised green tablelands, the Cape's
   mountains]; a ship rounding the Cape; no text."
4. THE INDIES (view `indies`): "An antique hand-painted map of the Indies from Goa to Japan and the Spice Islands ...
   [the Western Ghats, the Ganges' green delta, the islands of Malacca, the Philippines and the Moluccas in jungle green
   with turquoise reefs, Japan's mountains]; a Portuguese carrack and a Japanese ship; no text."
5. THE SOUTHERN SEAS (view `seas`): "An antique hand-painted map of New Holland (Australia), New Zealand and the southern
   ocean down to the edge of the ice ... [the red interior, the green east coast and its mountains, the mangroves of the
   tropical north, a white band of ice and icebergs at the bottom]; one ship; no text."

## Claude's choices (for the owner)

1. A GRACE OF TWO YEARS: a colony falls only from a theatre left alone two whole years or more (the plan's rule took one
   every year whatever the player did; the sim shows it could not tell a careful order from a careless one). Still at
   most one a year, from the theatre left alone longest (owner answer 6). A careful player can keep all twelve.
2. AN OPTIONAL MISSION TURNS HALF A YEAR (the plan: "they also turn the clock"; at a full year they only cost colonies).
3. TAKEN BACK BY THE MISSION AT ITS PLACE, and then safe (the plan's reclaim part made concrete: Potosí e02, the Moluccas
   e11, Manila e10, the gold fields e13, the northern shore e14 burned). Missions built later may add reclaim parts of
   their own (a colony's `reclaim` condition).
4. ACT 2's SPARKS SET THE HEAD START (Africa by d12, the Indies by d13, unplayed = got away as the plan's choice 3):
   Act 2's optional missions now pay in Act 3 (about one colony).
5. ANY SIDE's WIN TURNS THE CLOCK and counts as attention (a versus friend's win still moved the story); only the Crown's
   way of winning takes a colony back. Lost tries cost nothing.
6. THE YEAR ON THE PLATE IS THE CLOCK'S (2781 + its turns, 2786-2787 at the most); the pins keep the plan's dates. The
   mission builds may date their pins by the clock instead (their openings could say "the year the Moluccas fell").
7. THE CLOCK's YEAR IS ON A PLATE, not in the cartouche: the cartouche is the parchment's only (the brass map and the
   chart have none) and too small to read on a phone; the cartouche keeps the act's title.
8. ACT 3 IS HIDDEN BEFORE ACT 3 (`act` on its items): its pins on the painted world would land where the sheet has no
   Asia, and twenty dashed seals in Act 1 would say nothing yet. Acts 1 and 2 look exactly as before.
9. THE WHOLE WORLD IS A NEW VIEW (`globe`), not the old THE WORLD: the King's painted world sheet covers the Atlantic
   only; Act 3's buttons replace Acts 1-2's (six again).
10. A WIDER EUROPE (`europe3`, Lisbon to Vienna, drawn) for the night and the finale; the painted Europe (Lyon to Rome)
    has no Lisbon.
11. PLACES (proposals, as the plan's): e01 on the coast below Salvador (where the column comes out); e06's station by an
    old ruin in the forest north of the Congo's great bend (21.8 E, 0.6 S); the gold fields by Bathurst over the Blue
    Mountains; the Cold Forge on the ice south of Australia (110.6 E, 66.6 S: the shortest way from the Indies);
    Ternate's pin on the Halmahera shore opposite (Ternate is too small for the map's land); e18's pin at Salvador (the
    plan's port is decided by the ledger: its card says so).
12. THE MOLUCCAS FALL RED (the plan's "red, then green": the green turn is e11's own story, `spice` burning makes them
    uneasy).
13. BRAZIL'S INTERIOR falls to the danger left to grow at d09 (`first` brood: the city grew, so the machines).
14. THE COLONIES WRITTEN TO THE PROGRESS count "uneasy" ones as the Crown's (held, but uneasy); only fallen ones (green
    or red) count against the ledger's last mark.
15. THE BRASS MAP SHOWS THE CLOCK'S FALLS like the others (Hollweg in Act 3 knows what the Machine takes; Act 2's rule
    that his plate never shows Concórdia red stays).
16. e15 (the Cold Forge, no theatre) HOLDS AFRICA AND THE INDIES (Valadares and Hollweg together, after e06 and e09).
17. LEFT-ALONE WORDS: "Not fought yet" for a theatre never won in and not behind; "Fought this year"; "Left alone n
    years"; "NEXT TO FALL" in red with the ticking clock.

## What is left

- The owner's five paintings (prompts above) and their landmarks in tools/campaign/fit_warmap_paintings.py.
- The missions e01-e20: each build checks its flags against these rules and the ledger's; optional missions that the
  night closed should also be closed in the campaign's gating (Campaign.unlocked: a pin's `closed` in WarMapData.state).
- The voyages (stills playing a dashed sea line as they play) and the refugees' arrows' animation: their own step.
- The King's study's Act 3 hotspots (Fairleigh's letter, Ferrer's report) and the Clockmaker's / Naturalist's Act 3
  rooms: the hubs' own build.

## Tests run (on 0.38.253 + this branch)

- `tools/test_war_map.gd`: 0 failures (Acts 1 and 2 as before, and Act 3's: the views by act, the bounds and the land,
  the acts, a pin for every mission with its title and about line, every pin on land, the five optional pins, twelve
  colonies with outlines, no clock before Act 3, the start, Africa next at risk, a scripted order (three falls in three
  years, the Southern Seas settled, Brazil's interior to the machines, the map and the ledger), taken back and not, the
  sparks stopped, a careful order keeping all twelve, the night stopping the clock and closing the optional pins, the
  night's clock, every skin with both ends of every choice, the chart's red notes, no Brood skin, Campaign.record's `seq`
  and `colonies`, and the page in all three skins: THE WORLD drawn, the act's views, the clock, an optional card, the
  ledger, every view drawn, a closed card).
- `tools/sim_war_clock.gd`: 0 failures.
- `tools/test_campaign.gd`, `tools/test_act3_engine0.gd`, `tools/test_hubs_grow.gd`, `tools/test_roster_ladder.gd`: 0
  failures.
- Boot `godot --headless --path . --quit-after 120`: no SCRIPT ERROR or Parse Error.
- `python3 tools/i18n_build.py` (no errors), `python3 tools/i18n_patch_build.py` reports [].
