# Act 1, "The Barricades of Paris": what was built (job a06-barricades, 0.38.59)

Step 6 of Act 1's build order (docs/campaign_act1_plan.md): the Crown line's second Act 1 mission, a06_barricades, built
as the plan and its OWNER ANSWERS of 2026-11-17 say: Paris in July 2769, told by Field Marshal Fairleigh (a Crown
narrator: truthful) with the King framing it; Father Tomasz, the King's chaplain to the army, at his side; THE ACT'S
CHOICE, VARENNE: Tomasz ASKS FOR MERCY, Fairleigh leaves the order to the player, the CANON is SPARED (exile); VERSUS
ONLY (no solo mirror: the Free Assembly is not a faction); EASY / NORMAL / HARD. It is also THE ROSTER LADDER's C3
(docs/campaign_roster_ladder.md): the FOUNDRY and the MORTAR, and the mission is built to show what they are for.

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite (kept short and plain on purpose). The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/a06_barricades.json`, written by `tools/campaign/make_a06_mission.py` (edit the script, run it) |
| the map | `campaign/maps/paris_barricades.json` (`campaign:paris_barricades`), written by `tools/campaign/make_paris_map.py` with the city generator `tools/campaign/city_gen.py`; opens in the MAP EDITOR |
| the stills (stand-ins) | `campaign/stills/a06_01.jpg` .. `a06_05.jpg`, drawn by `tools/campaign/make_a06_stills.py`; the King's pages reuse `p01_01` |
| texts pt / es | `tools/i18n/campaign/a06_barricades.txt` (then `python3 tools/i18n_build.py`); the war map's new ledger line in `warmap.txt` |
| the storyline, the hub | `campaign/campaign.json`: the Crown line is p01, a01, a06; the King's and the Cardinal's talks after a06 by `varenne`, Fairleigh's letter after a06 |
| a01's way on | `make_a01_mission.py` / `a01_presses.json`: `"next": {"crown": "a06_barricades"}` |
| the war map | `campaign/warmap.json`: a06's pin lost its working title (the mission's own is used); a rule for an Assembly win (Paris in unrest, the seal broken) beside the planned ones for `varenne` |
| the roster ladder | `tools/campaign/roster_ladder.py`: a06's CARD_AT / SIDE, the Foundry's and the Mortar's cards in pt / es |
| roles | `scripts/campaign/rebels.gd`: `fairleigh`, `ruggieri`, `volunteer`, `lyon_man`, `varenne_hall` (stand-ins) |
| tests | `tools/test_campaign_a06.gd` (`godot --headless --fixed-fps 30 --script res://tools/test_campaign_a06.gd`) |
| balance | `tools/sim_campaign_a06.gd` (`-- active families=save|leave lyon=calm|sullen|risen diff=easy|normal|hard verdict=spared|executed until=<s>`) |

## The map: Paris (128 x 96, grass, July; the city generator, seed 1769)

- THE ARMY'S CAMP (east): open ground outside THE TOLL WALL (a wall of rock down the map at x 106), with ONE gate, the
  PORTE SAINT-ANTOINE: the only way into the city. South of the river beyond the wall: wood.
- THE FAUBOURG SAINT-ANTOINE: one long street (5 cells wide) from the gate west to the PLACE DE LA BASTILLE, between
  solid house blocks: nobody goes round its THREE BARRICADES (the map script checks that, with them in, nothing west of
  them is reached from the camp).
- THE MARAIS (the right bank): a grid of streets west of the Bastille; the QUAY along the river; the PLACE DE GRÈVE and
  the HÔTEL DE VILLE (the Assembly's hall) on the quay, in an open ground the mission rings with palisades (60 pieces,
  one gate on the west side); the PORT SAINT-NICOLAS at the quay's west end (Varenne's boat).
- THE SEINE with THE ÎLE DE LA CITÉ between its two arms: the PONT NOTRE-DAME and the PONT AU CHANGE over the north arm,
  the PETIT PONT over the south arm, the PONT NEUF over the whole river in the west (all fords: the engine has no
  bridges). NOTRE-DAME (a Church) on the island's east end with its PARVIS.
- THE LEFT BANK: the Latin quarter's grid, the PLACE MAUBERT by the Petit Pont (where the torch-bearers gather).
- 2,404 houses (props), 60 blocks, 2 lots (the hall, the cathedral), 30 areas.

## How it plays: THE CROWN (solo; co-op with Ruggieri's guns; versus against the Free Assembly)

Opening (the King in Rome, then Fairleigh): Paris rose in 2769, a city with a government in its hall; the faubourg cut
three times; a line by a01's `printer` (Rouvière named Paris / no word from inside); a line by p01's `families` (the
Hollins boys came with the Virginia volunteers); Ruggieri's guns and the new mortar.

THE ARMY (PURPLE): FIELD MARSHAL FAIRLEIGH (an Officer, 320 health), FATHER TOMASZ (a Missionary, 360), COLONEL
RUGGIERI (an Officer) with 2 FIELD CANNONS and a MORTAR (the friend's in co-op, BLUE), 16 Musketeers, 4 Horsemen, a
powder wagon, 450 gold and 300 powder; the camp: a Barracks, THE FOUNDRY, a Horse Breeder (three horses by it), a
Powder Mill, seven tents (cottages: 56 supply). THE KING'S TREASURY pays 100 gold and 40 powder a minute. The ladder's
C3 allow-list (the Crown's kit, the Musketeer, the Field Cannon, the Horse Breeder and the Horseman, the Foundry and the
Mortar), with no Town Hall or Farm (the story's deny: a siege camp). With p01's `families` save: the VIRGINIA
VOLUNTEERS, six Musketeers named Will, Tom, Jacob, Ned, Sam and Eli Hollins. THE TOWN (YELLOW): Notre-Dame, three
citizens on the parvis. THE FREE ASSEMBLY (GREEN): everything else.

- PART 1, THE FAUBOURG. Three BARRICADES across the street, each two palisades deep (ten pieces, 200 health each), the
  Assembly's men holding behind them (NORMAL: 3 militia and a pike, then 4 and 1, then 5 and 2). The cannon's round
  shot breaks the palisades; the MORTAR lobs its shell over them onto the men (deployed 5 to 11 tiles off: out of
  their muskets' reach); when a barricade is BREACHED (its first piece down) its RUSH comes out down the street at the
  guns (2 pikes and a militiaman, then 3 and 1, then 3 and 2): Ruggieri calls for CANISTER and the card's button is
  pointed at. A barricade is TAKEN when its men are down: "Take the three barricades: n of 3". THE KING'S PATIENCE: a
  countdown of 20:00 (EASY 25:00, HARD 15:00) for the three; at 5:00 left the King's line, at 0:00 the marshal is
  recalled (a loss). While the first barricade stands, the Assembly SORTIES over it at the camp at 5:00 and every 3:00
  (3 militia, 2 pikes, a torch-bearer). Tips: the mortar (at the start), the Foundry and the treasury (0:40), the powder
  wagon (1:30).
- PART 2, THE BRIDGES (6 s after the third). The Bastille's POWDER MAGAZINE becomes the army's (a Powder Mill built
  there: the wagon and the muskets fill up near the fight, not back at the camp). The Assembly holds the north ends of the PONT NOTRE-DAME and the PONT AU CHANGE (3 militia and a pike each;
  a01's Lyon men with them by `lyon`) and the south end of the Petit Pont (3 militia). TORCH-BEARERS come over the
  Petit Pont from the Place Maubert at 1:00, 1:40 and 2:20 (two torches and two militia each) for NOTRE-DAME (900
  health): only the torch-bearers at its doors can burn it (6 a second each; no musket ball does): "Notre-Dame must not
  burn". "Take the bridges: n of 2".
- PART 3, THE HALL (5 s after both bridges are taken and the third wave's torches are down). The palisade round the
  Hôtel de Ville's square (spared until now) and the hall's men (8 militia, 3 pikes, Varenne's guard of 3 among them)
  can be hurt; the hall itself stays (the city's). "Take Varenne ALIVE" (a CAPTURE: he can't be brought under a
  quarter of his 260 health; there, with a Crown man beside him, he is taken). Once the ring is BREACHED (a piece down)
  Fairleigh warns: "Before we go in, men to the west gate: he will run." Once a Crown man is IN the square (STORMED),
  12 s later (EASY 25, HARD 6) Varenne RUNS out by the ring's west gate (the Assembly's: it opens for its own) with his
  guard for the boats at the PORT SAINT-NICOLAS; 30 s at the quay (EASY 45, HARD 20) and he is GONE (a loss).
- THE CHOICE, VARENNE. Taken: his line and Fairleigh's; 8 s later Tomasz ASKS FOR HIS LIFE and Fairleigh: "The order is
  yours." Two buttons, SPARE HIM: EXILE / EXECUTE HIM (two minutes; unanswered: SPARED, the canon). Each has its lines
  (Varenne's answer, Tomasz's). Then `paris` stood, "Paris was the King's again by morning", the dawn, THE WIN.
- THE DEFEATS (retry): Notre-Dame burnt; Field Marshal Fairleigh or Father Tomasz killed; Varenne escaped by the river;
  the King's patience out.

## How it plays: THE FREE ASSEMBLY (versus only)

No narrator but "the Free Assembly" (lines to its side only); the King's two lines in its opening. One objective: HOLD
PARIS: burn Notre-Dame, bring down the Field Marshal, or get Varenne out by the river (any of them wins it, as the
Crown's defeats; the patience running out too). Its units: everything on the map and every wave as it comes (the
friend leads them: the barricades' men, the rushes, the sorties, the bridges, the torches, the hall's men and Varenne,
whom the friend walks to the boat himself). It loses when the Crown wins.

## The flags read and set

A flag that is missing (p01 or a01 not in the progress) reads as: `families` not saved (no volunteers), `lyon` calm (no
Lyon men), `printer` not taken.

| flag | value | a06 |
| --- | --- | --- |
| p01 `families` | save | THE VIRGINIA VOLUNTEERS: six Musketeers named Hollins join at the start, Will Hollins' line and Tomasz's at 0:20; Fairleigh's opening line; the ending: they went home that winter, all six |
| | leave | none of it |
| a01 `lyon` | calm | no Lyon men |
| | sullen | 2 LYON MEN at each north bridge (the plan's "more Lyon men at the barricades"); the narrator's line and Tomasz's ("I know some of those faces") |
| | risen | 4 at each north bridge and 2 more at the third barricade; the narrator's line names them (only reachable in versus: a01 won by the Assembly leads nowhere on the Crown line) |
| a01 `printer` | taken | Fairleigh's opening: "The printer the young Father took at Lyon had named Paris." (else: "We had no word from inside the city.") |

Flags a06 SETS (kept when won): `varenne` spared / executed (the act's choice); `paris` stood (always with a Crown win:
Notre-Dame stood). The war map already read `varenne` (spared: his ship into exile; executed: Paris uneasy, risings in
Brittany and Provence); an Assembly win (versus) now turns Paris to UNREST with a broken seal. (`varenne` escaped is
set on that loss but a loss keeps no flags.)

## The engine

Nothing new: the mission uses keys that were there (spare, capture, choice with a default, stay, follow, clocks and a
countdown objective, repeating triggers with `while` by `when`, build, `if` on units by `past` flags, `tags`, `near`,
`only_team`, `idle`, ping by tag, difficulty multipliers on spawns and clocks, versus seats, endings by flags, hub talks
by flags). New roles in Rebels.ROLES: `fairleigh`, `ruggieri`, `volunteer`, `lyon_man`, `varenne_hall` (Varenne with
260 health in his hall: his p01 role is unchanged).

## Balance (tools/sim_campaign_a06.gd, NORMAL)

The bot plays as a careful player would: the guns set up 7-8 tiles from each barricade (the mortar on the men behind it,
never where its own men are; the cannons on the palisades; canister when a rush comes), the muskets as one body out of
the defenders' reach until the barricade is open, the powder wagon kept just behind the muskets (and to the magazine to
fill up), the heroes in the camp; in Part 2 the muskets at the bridges and then the parvis, the riders after the
torch-bearers; in Part 3 the whole army round to the hall's WEST side (Varenne's way out), the guns open the palisade
there, everyone in, everyone after Varenne once he runs; the choice answered at once. It runs the Foundry (mortars) and
the Barracks (Musketeers) with the treasury's money.

| run (flags: `families` save, `lyon` calm, `printer` taken unless said) | result | Part 2 / Part 3 from | time |
| --- | --- | --- | --- |
| NORMAL, three runs | WON (spared), `paris` stood | ~1:00-1:20 / ~3:30-3:40 | 5:17, 5:38, 5:41 |
| NORMAL, families left, Lyon sullen, EXECUTED | WON (executed) | ~1:20 / ~3:45 | 7:06 |
| NORMAL, Lyon risen | WON (spared) | ~1:20 / ~4:00 | 5:13 |
| EASY | WON | ~1:20 / ~3:40 | 5:09 |
| HARD, two runs | WON, WON | ~1:20 / ~3:50-5:05 | 5:32, 9:27 |
| passive (nothing done), NORMAL / EASY / HARD | LOST: the King's patience runs out (the sorties never got through the army at the camp) | - | 20:00 / 25:00 / 15:00 |

Earlier versions of the mission and the bot (what changed, in the order found): with a captured gun behind the second
and third barricades the army was cut down in the street (lost every run); with the barricades one palisade deep the
cannons broke each in three shots and the mortar had nothing to do; without the Bastille's magazine the muskets ran
dry on the bridges and the hall's men won with the bayonet; with Varenne running at the first breach (12 s, then 20 s
at the quay) the bot lost him two runs in three; with the bridges' men standing on the crossings they shot Notre-Dame
in Part 1. Sims run in parallel share user://campaign.json (the flags and the difficulty): run them ONE AT A TIME.

Reading: the bot knows the map and wins in 5-10 minutes; a person who finds the street, sets up the guns and walks the
army round to the west gate probably needs 15-25. Part 1 is short for an army that uses its guns (the barricades fall
in about a minute each) and long for one that walks its lines in (the barricade's men hold behind palisades and the
rushes meet them in the street). Part 2's danger is Notre-Dame (900 health: two torches burn it in about 75 s): cross
the bridges quickly or send the riders. Part 3's danger is the chase: go round to the west side before storming in. A
player who does nothing loses to the King's patience (20 minutes); a player who leaves the Field Marshal or the priest
in the way of the sorties loses sooner (HARD: Tomasz once died to one at 14:00 in an earlier passive run).
Speed: the sim runs about 4x real time headless (passive, more units standing) to 10x (active).

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

House style as the prologues (campaign/stills/p01_*.jpg): an oil painting in the manner of an 18th-century history
painting, visible brushwork, 3:2 landscape (cut to 1280 x 853), no text or lettering anywhere. The Crown's men in PURPLE
coats; the Free Assembly's men in GREEN AND BLACK with green cockades. References: p01_05 (the style);
campaign/hub/rome_tomasz.png (the Cardinal, old: Tomasz young is the same face fifty years younger, clean-shaven, dark
hair); for Fairleigh, the Governor in campaign/stills/p01_05 (the same man two years older, now a field marshal); for
Varenne, art/campaign/rebels/varenne_n_chatgpt.png (his look in the rebels' art); for Ruggieri's guns, p01_06. Save each as `art/campaign/stills/a06_0N.png`
and cut it to 1280 x 853 into `campaign/stills/a06_0N.jpg` (nothing else changes). The King's pages reuse p01_01.

- a06_01 THE BARRICADE. "Oil painting, 18th-century history painting style. Dawn in a long narrow street of tall grey
  Paris houses with many shuttered windows. Across the street, a barricade two layers deep: overturned carts, wine
  barrels, beams and heaped paving stones, higher than a man. Behind it men in green and black coats with green
  cockades hold muskets and pikes; two green flags on poles stand over it. The street in front is empty and strewn
  with stones. Cold pink morning light from the far end of the street. 3:2 landscape, no text." (Reference: p01_05.)
- a06_02 THE BATTERY. "Oil painting, 18th-century history painting style. A street of tall Paris houses filled with
  smoke. In the foreground a squat bronze siege mortar on its wooden bed, angled steeply upward, gunners in purple
  coats ramming it; beside it a field cannon. A colonel in a purple coat with grey hair and moustache, a long pipe in
  his teeth, points down the street. Through the smoke, far off, the outline of a barricade. Warm light on the smoke.
  3:2 landscape, no text." (References: p01_05, p01_06 for the guns and their crews.)
- a06_03 TORCHES FOR NOTRE-DAME. "Oil painting, 18th-century history painting style. Dusk on the Seine in Paris: the
  great gothic cathedral of Notre-Dame with its two square towers and rose window rises over the river. On a narrow
  stone bridge in the foreground men in green and black carry flaming torches towards the cathedral; on the parvis
  before its doors soldiers in purple coats run to meet them with bayonets. The torches and a few windows glow orange
  against a violet sky; reflections in the dark water. 3:2 landscape, no text." (Reference: p01_05.)
- a06_04 THE HÔTEL DE VILLE. "Oil painting, 18th-century history painting style. The great square before a
  Renaissance town hall in Paris, its tall roofs and many windows. A wooden palisade ringing the square has been
  smashed open by cannon fire; soldiers in purple coats with fixed bayonets pour through the breach, smoke drifting;
  men in green and black fall back towards the hall's doors. A green flag hangs from a balcony. Late afternoon light.
  3:2 landscape, no text." (Reference: p01_05.)
- a06_05 VARENNE BEFORE THE MARSHAL. "Oil painting, 18th-century history painting style. Night, inside a vaulted hall
  lit by candles. In the middle a lean man in his forties in a torn black coat with a green sash, hands chained before
  him, stands upright and defiant between two soldiers in purple coats. Facing him, a stern field marshal in a purple
  coat with gold braid and a sash, about fifty, his hand on a table with a written order and a pen. Beside the marshal
  a young Catholic priest in a black cassock, clean-shaven with dark hair, one hand raised, speaking for the prisoner.
  Warm candlelight, deep shadows. 3:2 landscape, no text, no legible writing on the paper." (References:
  rome_tomasz.png, p01_05 for the marshal, varenne_n_chatgpt.png for Varenne.)

## The voice lines (for the owner's Chatterbox recordings)

Recorded lines go in `campaign/voice/a06/<line id>.ogg` (or .wav / .mp3); the game plays them when present
(CampaignVoice). The King's in the King's voice (tools/voice_clone, refs king_ref.wav). FIELD MARSHAL FAIRLEIGH, COLONEL
RUGGIERI, ETIENNE VARENNE and WILL HOLLINS need designed voices first (a 10-20 s sample each, ElevenLabs only to design,
then Chatterbox; Fairleigh and Ruggieri also speak in p01, so their designs serve both); FATHER TOMASZ is a01's young
Tomasz. "Paris" (the narrator) and "the Free Assembly" (versus only) can stay text. The NEW cards are not voiced.

| file (campaign/voice/a06/) | voice | when | line |
| --- | --- | --- | --- |
| k_open1.ogg | The King | opening (crown) | Paris rose in the summer of 2769. They walled their streets with carts and paving stones and sat a government in the Hôtel de Ville. |
| k_open2.ogg | The King | opening (crown) | Fairleigh took it back. He was a field marshal by then. Let him tell it; he tells it shorter than I do. |
| f_open1.ogg | Field Marshal Fairleigh | opening (crown) | We camped outside the Porte Saint-Antoine. Beyond the gate the faubourg was one long street, and they had cut it three times. |
| f_open_printer.ogg | Field Marshal Fairleigh | opening (crown) | The printer the young Father took at Lyon had named Paris. He was right about that, if about nothing else. |
| f_open_noprinter.ogg | Field Marshal Fairleigh | opening (crown) | We had no word from inside the city. We learnt its streets the hard way. |
| f_open_saved.ogg | Field Marshal Fairleigh | opening (crown) | The Hollins boys came over with the Virginia volunteers. They had asked to. |
| f_open2.ogg | Field Marshal Fairleigh | opening (crown) | Ruggieri had his guns, and the King had sent us something new from the foundries: a mortar, to throw a shell over a wall. |
| k_open_a.ogg | The King | opening (assembly) | The Assembly wrote a great deal that summer. Here is what it meant to do. |
| f_1.ogg | Field Marshal Fairleigh | intro | Three barricades between us and the Bastille. Don't walk lines into them, gentlemen. Break them with the guns first. |
| r_1.ogg | Colonel Ruggieri | intro | The mortar throws over a barricade, Marshal. Set it up out of their muskets' reach, five to eleven tiles off. |
| t_1.ogg | Father Tomasz | intro | There are families behind those shutters, Marshal. They did not all choose this. |
| f_t1.ogg | Field Marshal Fairleigh | intro | Then we end it quickly. That is the mercy I can give them. |
| v_saved.ogg | Will Hollins | intro_saved | Sir. The Hollins boys, all six of us. We are here for the Father, and for you. |
| t_saved.ogg | Father Tomasz | intro_saved | I baptised your sister's boy, Will. Keep your head down for him. |
| tip_foundry.ogg | Colonel Ruggieri | tip_foundry | The Foundry casts more guns and mortars, each with a horse from the Breeder. The treasury pays us every minute. |
| tip_powder.ogg | Colonel Ruggieri | tip_powder | Ten shots a musket, Marshal, then the bayonet. Keep the powder wagon close behind the line: it fills them again. |
| r_sortie.ogg | Colonel Ruggieri | sortie_line | They are coming out over the barricade at our camp! While it stands they will keep coming. |
| k_patience.ogg | The King | patience_half | I gave Fairleigh a month. He knew I would not give him two. |
| n_patience.ogg | Paris | patience_out | The King's courier rides into the camp. The marshal is recalled; Paris holds behind its barricades. |
| r_rush.ogg | Colonel Ruggieri | first_rush | They are coming out over the barricade! Canister, load canister! |
| tip_canister.ogg | Colonel Ruggieri | first_rush | CANISTER on the gun's card: a cone of balls down the street. Keep the line in front of the guns. |
| f_bar_1.ogg | Field Marshal Fairleigh | taken_bar_1 | The first barricade is ours. Bring the guns up. |
| f_bar_2.ogg | Field Marshal Fairleigh | taken_bar_2 | Two. The third is the strongest: the Bastille is behind it. |
| f_bar_3.ogg | Field Marshal Fairleigh | taken_bar_3 | Three. The Bastille is open. |
| f_2.ogg | Field Marshal Fairleigh | part2 | Now the river. They hold the bridges to the Cité. |
| t_2.ogg | Father Tomasz | part2 | Marshal, look at the far bank. They are carrying torches towards Notre-Dame. |
| f_2b.ogg | Field Marshal Fairleigh | part2 | Then we take the bridges at the run. Notre-Dame does not burn while I command here. |
| f_magazine.ogg | Field Marshal Fairleigh | magazine_line | The Bastille's powder magazine is ours. The wagon and the muskets fill up there now, not back at the camp. |
| n_lyon_sullen.ogg | Paris | lyon_sullen | Lyon men are on the bridges: weavers who walked from the Croix-Rousse to fight. |
| n_lyon_risen.ogg | Paris | lyon_risen | Half of Lyon's Assembly is on the bridges and at the Bastille, under its own flags. |
| t_lyon.ogg | Father Tomasz | lyon_sullen | I know some of those faces. From the weavers' square. |
| n_torch.ogg | Paris | torch_1 | Torch-bearers on the Petit Pont, for the cathedral. |
| t_nd.ogg | Father Tomasz | nd_hurt | The doors are burning! Men onto the parvis! |
| f_bridges.ogg | Field Marshal Fairleigh | bridges_done | Both bridges. The Cité is ours. |
| f_3.ogg | Field Marshal Fairleigh | part3 | Now the Hôtel de Ville. Varenne is in there. I want him alive: the King will judge him, not a musket ball. |
| r_3.ogg | Colonel Ruggieri | part3 | They have palisaded the whole square. The guns will open it. |
| tip_3.ogg | Field Marshal Fairleigh | part3 | Take him alive: wear him down, then a man of ours beside him. If he reaches the river, he is gone. |
| f_breach.ogg | Field Marshal Fairleigh | breached | The palisade is open. Before we go in, men to the west gate: he will run. |
| n_flight.ogg | Paris | flight_easy | Varenne is out by the west gate, running for the boats at the Port Saint-Nicolas. |
| f_flight.ogg | Field Marshal Fairleigh | flight_easy | Riders! After him! |
| n_quay.ogg | Paris | at_quay | A boat is waiting at the quay. Its oarsmen are already at the oars. |
| va_taken.ogg | Etienne Varenne | taken | You will want me alive, Marshal. Kill me and I am a martyr, and your Church knows what martyrs are worth. |
| f_taken.ogg | Field Marshal Fairleigh | taken | I have taken the man who burned Virginia. That will do for today. |
| t_mercy.ogg | Father Tomasz | verdict | Marshal. I ask for his life. Send him away, but let him live. I prayed for his men in Virginia; I pray for him now. |
| f_order.ogg | Field Marshal Fairleigh | verdict | The King gave me the right to judge him here. The Father asks for mercy. The order is yours. |
| f_spared.ogg | Field Marshal Fairleigh | verdict (spared) | Exile, then. A ship, and never French ground again. |
| va_spared.ogg | Etienne Varenne | verdict (spared) | Exile. How very Christian of you, Marshal. Write to me when you regret it. |
| t_spared.ogg | Father Tomasz | verdict (spared) | Thank God. |
| f_exec.ogg | Field Marshal Fairleigh | verdict (executed) | The law, then. At dawn, on the Grève. |
| va_exec.ogg | Etienne Varenne | verdict (executed) | At noon, then, when the square is full. Let Paris watch the Crown at work. |
| t_exec.ogg | Father Tomasz | verdict (executed) | I will stay with him tonight, Marshal. Someone should. |
| f_won.ogg | Field Marshal Fairleigh | won | Paris was the King's again by morning. Someone rang the great bell of Notre-Dame, and I did not ask who. |
| r_marshal.ogg | Colonel Ruggieri | fairleigh_hurt | The Marshal is hit! Keep him behind the line! |
| f_priest.ogg | Field Marshal Fairleigh | tomasz_hurt | The Father is hurt! Men round the priest! |
| n_nd_burnt.ogg | Paris | nd_burnt | Notre-Dame is burning. The whole city can see it. |
| n_escaped.ogg | Paris | escaped_easy | A boat pushes off from the Port Saint-Nicolas. Varenne is gone down the river. |
| a_1.ogg | The Free Assembly | opening (assembly) | Hold the barricades. Burn Notre-Dame, bring down the Field Marshal, or get Varenne out by the river: any of them wins Paris. |
| a_tip.ogg | The Free Assembly | intro_a | Your men behind a barricade are safe from the Crown's line. Not from its guns: when a barricade breaks, rush the guns. |
| f_end1.ogg | Field Marshal Fairleigh | ending (crown) | Paris was quiet by the feast of the Assumption. The barricades went back to being carts and paving stones. |
| f_end_spared.ogg | Field Marshal Fairleigh | ending (crown) | Varenne sailed from Le Havre in September. I did not go to see him off. |
| f_end_exec.ogg | Field Marshal Fairleigh | ending (crown) | Varenne died on the Grève at dawn. The crowd was very quiet. |
| f_end_saved.ogg | Field Marshal Fairleigh | ending (crown) | The Hollins boys went home to Virginia that winter. All six of them. |
| t_end_spared.ogg | Father Tomasz | ending (crown) | I said a Mass of thanksgiving in Notre-Dame. The doors were still black with smoke. |
| t_end_exec.ogg | Father Tomasz | ending (crown) | I said a Mass for his soul. Some of his men came, and I did not send them away. |
| k_end_spared.ogg | The King | ending (crown) | I have never regretted that order. Tomasz asked for a life, and he was right to ask. |
| k_end_exec.ogg | The King | ending (crown) | It was the law. I have read that order more often than I care to say. |
| k_end2.ogg | The King | ending (crown) | That was the end of the Assembly's cities. The next fires were not theirs. |
| k_end_a1.ogg | The King | ending (assembly) | That is not how it went. Paris did not hold. |
| k_end_a2.ogg | The King | ending (assembly) | But if it had, the Crown would have had two capitals, and one of them against it. |

## What is placeholder

- Every line, every objective's words, the briefings and the debriefs.
- The stills (simple drawings).
- Fairleigh, Ruggieri and Varenne are Officers, Tomasz a Missionary, the volunteers and the Lyon men Musketeers (the
  campaign roles' stand-ins; Varenne and the Lyon men use the rebels' drawn art). The barricades and the hall's ring
  are palisades, the ring's gate a gate, the Hôtel de Ville a Town Hall, Notre-Dame a Church, the Bastille's magazine a
  Powder Mill, the tents cottages; the houses are cottage and shed props.
- The voice folder a06 is empty (silent).

## Claude's choices for the owner

1. NO CAPTURED GUNS. The plan gave the Assembly "a captured gun or two". Built, a captured gun behind the second and
   third barricades cut the army down in the street (the sim lost 15 men to it in 20 s: round shot and canister down a
   five-cell street into a column). They are gone; the Assembly's answer to the guns is the RUSH when a barricade is
   breached. A gun could come back as a counter-battery lesson (the mortar on it) once a player has been seen fighting
   one.
2. BARRICADES ARE TWO PALISADES DEEP and the street is the only way: one deep, the cannon broke a barricade in three
   shots and the mortar had nothing to do.
3. A BARRICADE IS TAKEN WHEN ITS MEN ARE DOWN (not its walls): the mortar's work counts, and a player who breaks the
   walls and walks in still has to finish them.
4. THE KING'S PATIENCE (20:00 for the barricades) and THE SORTIES (from 5:00 while the first barricade stands): the
   plan names no clock; without them a player who did nothing simply stood in the camp for ever (the Assembly holds and
   never attacks). Numbers to tune with real players.
5. THE BASTILLE'S MAGAZINE: the army gets a Powder Mill at the Bastille in Part 2. Without it the muskets ran dry on the
   bridges (the wagon carries 120 shots and fills only at a Mill, a Barracks or a Town Hall, all back at the camp) and
   the army walked into the hall with bayonets. The ladder's Powder Wagon is C7's; this mission keeps the one it gives.
6. VARENNE RUNS once the Crown is in his square (not at the first breach: a player then chooses when to storm), and 30
   s at the quay loses him: the plan's versus "Varenne gets out by the river" made into a solo threat, so the Horsemen
   have a job and the capture is a chase. EASY gives him a later start and a slower boat; a player who heeds the
   marshal ("men to the west gate") holds the gate first.
7. THE CHOICE UNANSWERED IS SPARED (the canon), after two minutes; it is the Crown's choice in versus too (the host's
   screen), as the plan says: "Fairleigh's order, the player's buttons".
8. EXECUTED does not kill Varenne on the map (he stays taken: the capture objective would read a death as a failure);
   the lines and the ending say it.
9. THE LYON MEN stand at the BRIDGES (the plan: "the Lyon men are there by `lyon`"), two a bridge when Lyon was sullen.
   `risen` is handled (four a bridge, two more at the third barricade) though only versus can reach it.
10. THE VOLUNTEERS are named Hollins (the farm the families were saved at): Will, Tom, Jacob, Ned, Sam and Eli. Never
    scaled by the difficulty, like the rest of the army.
11. The hall's ring, its men and Varenne are SPARED until Part 3 (nobody can hurt them before), and the hall itself is
    never open to attack (it is the city's; the ring is what the guns break). NOTRE-DAME IS ALWAYS SPARED and burns only
    at the torch-bearers' hands (a scripted 6 a second for each torch at its doors): with it open to every blow the
    Assembly's muskets on the quay and the torches' escorts shot it down before a torch arrived.
12. THE BRIDGES' MEN stand at the bridges' NORTH ends (and the Petit Pont's men at its south end): standing on the
    crossing their muskets reached Notre-Dame and they burnt it in Part 1.
13. The torch waves come at 1:00, 1:40 and 2:20 (the plan's "torch-bearers go for it"): two torches and two militia
    each; a torch burns Notre-Dame for 6 a second (two torches: about 75 s for the 900 health).
14. RUGGIERI'S GUNS ARE THE CO-OP FRIEND'S (BLUE, as in p01) and the army's in solo and versus. Both teams are bound to
    C3, so the friend's guns and the army's Foundry make the same pieces.
15. THE ARMY CAN'T BUILD A TOWN HALL OR FARMS (the story's deny on top of the ladder): the treasury pays it, 100 gold and
    40 powder a minute.

## Tests run

- tools/test_campaign_a06.gd: 140 checks, 0 failures (the data and translations, the Crown line and a01's way on, the
  seats for every mode, the map and stills, THE ROSTER LADDER's C3 and its cards, the war map pin and its rules; the
  flags at the start: p01 `families` save / leave / none with a01 `lyon` calm / sullen / risen / none and `printer`
  taken / not (the opening's lines, the volunteers, the Lyon men, the army, the camp, the NEW cards); Part 1: the
  barricades (ten palisades each, the men), what is spared, the hall's ring and its gate, a breach and its rush, the
  canister tip, each barricade taken, Part 2; Part 2: the magazine, the Lyon lines, the torch waves, Notre-Dame burnt
  only by torches (a musket can't, one torch 6 a second, two faster), the bridges, Part 3 waiting for the third wave;
  Part 3: the breach (Varenne stays), STORMED, his flight after 12 s, the boat (30 s: the escape, a loss), THE CAPTURE,
  THE CHOICE both ways (the flags, the lines, the win, the ending's lines by the flags, the progress), the choice left
  unanswered (two minutes: spared); the defeats (Notre-Dame burnt, the Field Marshal, Father Tomasz), THE KING'S
  PATIENCE (20:00, the sorties at 5:00 and 8:00, the King's line at 5:00 left, the loss; no sortie once the first
  barricade is taken); versus (the Assembly's objective, its win when Notre-Dame burns, the story follows it); EASY and
  HARD (the Assembly's numbers scaled, the army never, the patience 25:00 / 15:00, Varenne's flight 25 s / 6 s); the
  hub's talks after a06 by `varenne` and Fairleigh's letter).
- tools/test_campaign.gd: 124, 0 failures. tools/test_campaign_a01.gd: 118, 0 (its "a01 leads nowhere yet" check now
  reads a01 -> a06). tools/test_campaign_a02.gd: 139, 0. tools/test_campaign_a03.gd: 195, 0. tools/test_campaign_b01.gd:
  176, 0. tools/test_campaign_c01.gd: 243, 0. tools/test_campaign_m1.gd: 103, 0. tools/test_city_gen.gd: 12, 0.
  tools/test_war_map.gd: 66, 0 (a06 is now built: locked before a01, open after it; won by the Assembly = Paris in
  unrest; the map UI's "planned pin" check moved to Rome). tools/test_roster_ladder.gd: 234, 0 (a06 on the "built"
  list; its "a building on the list is not refused" check now skips the story's own refusals: with a01 on the list it
  picked the garrison's cottage, which a01 refuses for the story, and failed). tools/test_tutorial.gd: 326, 0.
- Boot: `godot --headless --quit-after 300`, no SCRIPT ERROR (the class cache rebuilt with `godot --headless --editor
  --quit`).
- tools/sim_campaign_a06.gd: the runs in "Balance" (one at a time).
- As before on this cloud machine every headless Godot run ends with "Aborted" (exit 134) AFTER its last line: the
  engine's shutdown here, not a test.
- Not run: the faction and AI tests (no unit, price or skirmish rule changed; the only script change is five new
  campaign roles). Not played on two devices (co-op, versus).
