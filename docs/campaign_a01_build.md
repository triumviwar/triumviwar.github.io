# Act 1, "The Printing Houses": what was built (job a01-presses, 0.38.57)

Step 5 of Act 1's build order (docs/campaign_act1_plan.md): THE CITY GENERATOR (docs/city_generator.md), then the
Crown line's first Act 1 mission, a01_presses, built as the plan and its OWNER ANSWERS of 2026-11-17 say: Lyon in the
spring of 2768, told by young Father Tomasz (the Crown's conscience) with the King framing it and old Tomasz, the
Cardinal, saying one line in the frame; a fog hunt in the streets, not a battle of lines; VERSUS ONLY (no solo
mirror: the Free Assembly is not a faction); EASY / NORMAL / HARD.

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite (kept short and plain on purpose). The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/a01_presses.json`, written by `tools/campaign/make_a01_mission.py` (edit the script, run it) |
| the map | `campaign/maps/lyon_presses.json` (`campaign:lyon_presses`), written by `tools/campaign/make_lyon_map.py` with the city generator `tools/campaign/city_gen.py`; opens in the MAP EDITOR |
| the stills (stand-ins) | `campaign/stills/a01_01.jpg` .. `a01_05.jpg`, drawn by `tools/campaign/make_a01_stills.py`; the King's pages reuse `p01_01` |
| texts pt / es | `tools/i18n/campaign/a01_presses.txt` (then `python3 tools/i18n_build.py`); the war map's new ledger line in `warmap.txt` |
| the storyline, the hub | `campaign/campaign.json`: the Crown line (id `prologue`, kept so saved progress stays) is titled THE CROWN, missions p01, a01; the King's and the Cardinal's talks after a01 |
| p01's way on | `campaign/missions/p01_leaf.json` `"next": {"crown": "a01_presses"}` (edited in the JSON: `make_m1_mission.py` is older than the file and was only given the same line) |
| the war map | `campaign/warmap.json`: a01's pin lost its working title (the mission's own is used), a rule for an Assembly win (Lyon in unrest, the seal broken) |
| the engine | `scripts/campaign/mission_run.gd` (disguise, unmask, tags, near, ping by tag, random default, counter min/max, only_team), `scripts/entity.gd` (cloth_colour, refresh_cloth), `scripts/ui/hud.gd` and `scripts/fog_memory.gd` (a disguised house on the minimap), `scripts/campaign/campaign.gd` (the checks), `scripts/campaign/rebels.gd` (roles) |
| tests | `tools/test_city_gen.gd`, `tools/test_campaign_a01.gd` (`godot --headless --fixed-fps 30 --script res://tools/<test>.gd`) |
| balance | `tools/sim_campaign_a01.gd` (`-- active layout=old_town|river|hill families=save|leave diff=easy|normal|hard until=<s>`) |

## The map: Lyon (128 x 96, grass, spring; the city generator, seed 1768)

- THE SAÔNE (west, narrow) and THE RHÔNE (east, wide) meet at the south edge. Three bridges (fords) over each.
- THE CROIX-ROUSSE, the silk-weavers' hill between the rivers to the north: high ground with a cliff all round, climbed
  by THREE STAIRS on its south face (west, middle, east). On top, the WEAVERS' HALL on its square; the weavers' blocks.
  Quays run along both rivers below it.
- LES PENTES, the slopes' foot: blocks with six TRABOULES (covered passages) through them, and the HIDDEN YARD: a block
  of its own with a yard inside, reached only by two traboules (from the street to the south and the street to the
  east). The great press stands in it.
- THE PRESQU'ÎLE between the rivers: a grid of streets and blocks, the TERREAUX square under the hill, the JACOBINS and
  the CORDELIERS in the middle, BELLECOUR (the great square) in the south; the rue Centrale down the middle and a street
  to each bridge.
- VIEUX LYON (west bank): the old town along the Saône, the cathedral by the SAINT-JEAN square; FOURVIÈRE, high ground
  behind it with its basilica (chapel props) and two ramps up.
- LA GUILLOTIÈRE (east bank): the GARRISON's open ground (its Barracks, Powder Mill and four quarters cottages), blocks
  north and south of it.
- 1,859 houses (props), 104 blocks, 30 lots (the twelve press candidates, sixteen of the town's own houses, the hall,
  the great press), 78 areas.

## How it plays: THE CROWN (solo; co-op with the City Watch; versus against the Free Assembly)

Opening (the King in Rome, the Cardinal, then young Tomasz): the year after Virginia the Assembly's pamphlets were in
every city of the Crown, most of them printed in Lyon; Tomasz's line about the Hollins families by p01's `families`;
Captain Delorme asks the priest who knows the streets to help him find the presses.

The garrison (PURPLE): CAPTAIN DELORME, FATHER TOMASZ (a Missionary, 360 health), 12 Musketeers, 4 Horsemen, a powder
wagon, 300 gold and 300 powder; the Barracks may train Musketeers (four quarters: room for six more); the city pays the
garrison 40 gold a minute, and every press closed 60. The CITY WATCH (PINK, the co-op friend's; scripted alone): 8
Musketeers holding four bridges. The TOWN (YELLOW): its houses (buildings), citizens on the squares. The FREE ASSEMBLY
(GREEN): the presses, the runners, the presses' men, the bands, the mob; the master printer and his men in the yard.

- PART 1, THE PAMPHLETS. Six of the twelve candidate houses are PRESSES. A press is DISGUISED: it wears the town's
  yellow (on the map, the minimap, its card, the fog's memory), and nothing can target it, until a Crown man STANDS 3
  SECONDS within 2 tiles of it (a man marching past doesn't see in): then it shows its green, its door is broken in
  (150 of its 400 health), two militia and a pikeman come out, and it can be burnt. Every press sends a RUNNER every 2:00 (EASY 2:30, HARD 1:35; the first at
  0:40, the others spread over the period) to the square nearest it; a runner who reaches a square is gone and raises
  THE CITY'S TEMPER by 1 (it starts at 2; at 15 a warning; at 20 THE CITY RISES and the mission is lost). A press closed
  takes 2 off, and FATHER TOMASZ standing on a square preaches it down 1 every 30 s. THE WATCH'S HINT: at 5:00 and every
  2:30 after (EASY 4:30, HARD 6:00) the Watch gives away the first press still hidden. "Find the Assembly's printing
  houses and close them: n of 4." A tip at 2:00: ten shots a musket, then the bayonet; the powder wagon refills them.
- PART 2, THE WEAVERS' HILL (8 s after the fourth press). The Assembly calls the weavers up the Croix-Rousse: 16
  weavers gather on the hall's square; the presses left stop printing; six more Musketeers wait below the stairs.
  FATHER TOMASZ must STAY on the hall's square 45 s (a STAY) while the garrison holds the three stairs: three BANDS come
  up them (at 0:40 the middle, 1:20 the west, 2:00 the east, with torch-bearers). From 0:25, every 15 s he is NOT on the
  square, the agitators turn two weavers into a MOB (the temper +1 each time) that goes for the Weavers' Hall (burnt:
  the temper +4; "The Weavers' Hall must stand", optional). When he has spoken the weavers who listened go home (off
  the map at the hilltop's west end), the temper -3.
- PART 3, THE LAST PRESS (once the speech is done and no Assembly man is left on the hill, or 1:30 after the speech).
  A weaver tells Tomasz of the yard under the hill; its two traboules, SHUT until now by doors in the town's colour, are
  opened and pinged. The GREAT PRESS (a Barracks) is disguised too; a Crown man in the yard finds it (3 s), three more
  militia come. While it stands it sends a runner to the Terreaux every 40 s. TAKE MASTER ROUVIÈRE ALIVE (a CAPTURE: he
  can't be brought under a quarter of his health; there, with a Crown man beside him, he is taken) and CLOSE THE GREAT
  PRESS. Rouvière names Paris (the a06 hint). Three seconds after both, "the great press is broken, Lyon is quiet", the
  flags, dawn; eight seconds later THE PRESSES ARE SILENT (the win).
- THE DEFEATS (retry): the temper at 20; Father Tomasz killed.

## How it plays: THE FREE ASSEMBLY (versus only)

No narrator but "the Free Assembly" (lines to its side only): the King's two lines in its opening. Its objectives: RAISE
THE CITY (walk the runners to the squares: the temper to 20) or SILENCE THE PRIEST (Father Tomasz killed); either wins.
Its units: the runners as they come out of the presses (the friend walks them), the presses' men, the bands, the mob,
the yard's men. It loses when the Crown wins. Where its presses print is THE LAYOUT (below), told to it in a line.

## Where the presses print: THE LAYOUT

Three layouts of six of the twelve candidates (the candidates are spread over every quarter: two on the hill, two on
the slopes, four on the Presqu'île, two in Vieux Lyon, two in Guillotière):

| layout | candidates | presses |
| --- | --- | --- |
| `old_town` | 1, 4, 5, 8, 9, 12 | the hill's west, the slopes' east, the Presqu'île north-west and south-east, Vieux Lyon's north, Guillotière's south |
| `river` | 2, 3, 6, 7, 10, 11 | the hill's east, the slopes, the Presqu'île east and south-west, Vieux Lyon's south, Guillotière's north |
| `hill` | 1, 3, 6, 7, 9, 11 | the hill's west, the slopes, the Presqu'île east and south-west, Vieux Lyon's north, Guillotière's north |

The other six candidates are the town's own houses. The pick is a CHOICE of the Assembly's side whose default is
`random`: the match's seed picks it (the same on every machine and in the replay). Each runner goes to the square
nearest its press (Terreaux for the hill, the Cordeliers for the slopes and Guillotière, the Jacobins, Bellecour,
Saint-Jean). The flag `layout` is kept with the mission.

## The prologue's flag (p01_leaf) and the flags it sets

A flag that is missing (p01 not in the progress) reads as `leave` (Tomasz carries it).

| p01 flag | value | a01 |
| --- | --- | --- |
| `families` | save | the opening: "The Hollins boys wrote to me from Virginia..."; in the streets: "In Virginia we saved the families. Here, too..."; the ending: he wrote to the Hollins boys that summer |
| | leave | the opening: "I still prayed for the families we left on the road..."; in the streets: "...I will not leave this city to the fire." |

Flags a01 SETS (kept when won): `lyon` calm (the temper under 6 at the end) / sullen (6 or more), with `lyon_n` the
temper; `risen` when the Assembly wins (versus); `printer` taken (the a06 hint: he named Paris); `layout`. The war map
already read `lyon` calm (Lyon purple) / sullen (uneasy); an Assembly win now turns Lyon to UNREST with a broken seal.
For a06 (Paris): `lyon` is the plan's "more or fewer Lyon men at the barricades" (sullen: more).

## The engine (small; docs/campaign_engine.md "Added by Act 1's a01_presses")

- DISGUISED buildings: `"disguise": {"as": team, "within": tiles, "by": side, "secs": s}` on a building or a `build`;
  `{"unmask": {"tag", "first"}}`; conditions `unmasked` and `disguised`. The colour shown is chosen per screen
  (Entity.cloth_colour: its own side sees its true colour), and nothing targets a disguised building (it is spared).
- `"tags"` (more than one tag), a building's `"name"`, a spawn `"near"` a tag, a ping at a tag, a choice's
  `"default": "random"`, a counter's `"min"` / `"max"`, an order's `"only_team"`.
- Roles `tomasz`, `delorme`, `runner`, `printer`, `weaver` (stand-ins).
- Everything else was already there: STAY, CAPTURE, convert, exits, counters, clocks, `past` and `if`, difficulty,
  versus seats, endings by flags, `hunt`, `spare`, `hurt`, lights.

## Balance (tools/sim_campaign_a01.gd, NORMAL)

The bot plays fair: it does not know which houses print. Its riders and four Musketeers go round the houses (every
lot: the twelve candidates and the town's sixteen, nearest first) stopping 4 s at each door, and break any press found;
the other Musketeers keep the five squares; Tomasz preaches on Bellecour; the Barracks trains Musketeers with the
city's money. In Part 2 everyone climbs to the hall's square and Tomasz goes up once four soldiers are there (or after
0:40) and stays among them; in Part 3 everyone goes into the yard, wears the printer down, takes him and breaks the press.

| run (NORMAL and `families` save unless said; the layout as given) | result | time |
| --- | --- | --- |
| active, `old_town` | WON (the presses are silent), `lyon` calm (temper 0) | 9:32 |
| active, `old_town` (an earlier bot) | won, calm / LOST: the bot kept Tomasz on the square among the bands after his speech | 11:51 / 10:41 |
| active, `old_town`, families left | won, calm (a long hunt: the riders lost, the Watch's hints found the last presses) | 20:48 |
| active, `river` | won, calm (temper 2) | 8:31 |
| active, `river`, families left | won, calm | 5:54 |
| active, `hill` (twice, once families left) | won, calm | 5:54, 5:56 |
| active, EASY: `old_town` / `river` / `hill` | won, calm | 6:02 / 8:50 / 5:55 |
| active, HARD: `old_town` / `river` / `hill` | won, calm | 11:32 / 9:29 / 9:46 |
| active, HARD `old_town` (before the door broken in and the powder tip) | won | 21:05 |
| active, HARD `hill` (before the door broken in and the powder tip) | not finished at 30:00: the riders lost, the muskets out of shot against a press's walls | - |
| passive (nothing done), NORMAL / EASY / HARD | LOST: the city rises (the temper at 20) | 7:04 / 8:38 / 6:01 |

Reading: Part 1 is the long part (the hunt: 3-8 minutes for the bot, 18 when its riders die early; longer for a
person who does not know which yellow houses to look at), Part 2 about two minutes, Part 3 under one for an army that
walks into the yard together. A person probably needs 15-25 minutes. A player who
guards the squares never loses to the temper; the danger is Father Tomasz in Part 2 (the bands come up the stairs he
must climb: send him up with soldiers). A player who does nothing loses when the city rises (about 6-7 minutes).
Speed: the sim runs about 2.5x real time headless.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

House style as the prologues (campaign/stills/p01_*.jpg): an oil painting in the manner of an 18th-century history
painting, visible brushwork, 3:2 landscape (cut to 1280 x 853), no text or lettering anywhere. The Crown's men in PURPLE
coats; the Free Assembly's men in GREEN AND BLACK with green cockades. References: p01_05 (the style);
campaign/hub/rome_tomasz.png (the Cardinal, old: Tomasz young is the same face fifty years younger, clean-shaven,
dark hair). Save each as `art/campaign/stills/a01_0N.png` and cut it to 1280 x 853 into `campaign/stills/a01_0N.jpg`
(nothing else changes). The King's pages reuse p01_01 (the King lighting his pipe).

- a01_01 PAMPHLETS ON THE BRIDGES. "Oil painting, 18th-century history painting style. Spring morning in a French river
  city: an old stone bridge with arches over a green river, tall ochre and pink houses with red roofs on the far bank,
  a cathedral's towers behind them. Hundreds of small printed papers blow across the bridge and along the quay in the
  wind. In the middle of the bridge a young Catholic priest in a black cassock, clean-shaven with dark hair, about
  twenty-five, has caught one of the papers and reads it, troubled. Townsfolk hurry past. Soft clear light. 3:2
  landscape, no text, the papers blank or with unreadable lines." (References: rome_tomasz.png, p01_05.)
- a01_02 THE PRINTING HOUSE. "Oil painting, 18th-century history painting style. The attic of a silk-weaver's house at
  night, low beams, the shutters closed: a wooden hand printing press with its great screw and bar, a printer in a
  leather apron and shirt sleeves pulling the bar, sheets of printed paper hanging to dry on strings across the room,
  a green cockade pinned to his apron, a young man in green and black tying bundles of papers for runners. One warm
  lamp, deep shadows. 3:2 landscape, no text, no legible writing on the papers." (Reference: p01_05.)
- a01_03 THE WEAVERS' HILL. "Oil painting, 18th-century history painting style. Dusk on the square at the top of a
  city hill: tall plain houses with many windows lit, a modest stone guild hall with steps. A crowd of silk-weavers,
  men and women in working clothes, fills the square, some holding stones, a few with green cockades shouting. On the
  hall's steps a young Catholic priest in a black cassock, clean-shaven, dark hair, speaks to them with one hand
  raised, calm. At the edges of the square soldiers in purple coats hold their muskets low. Violet sky, warm windows.
  3:2 landscape, no text." (References: rome_tomasz.png, p01_05.)
- a01_04 THROUGH THE TRABOULES. "Oil painting, 18th-century history painting style. Night inside a narrow covered
  passage that runs through old city houses: a low vaulted stone corridor with a stair winding up one side, at its end
  a doorway onto a moonlit inner courtyard. Three soldiers in purple coats with muskets and bayonets come through it,
  the first holding up a lantern; behind them a young priest in a black cassock. The lantern's warm light on the old
  stones, cold moonlight beyond. 3:2 landscape, no text." (References: rome_tomasz.png, p01_05.)
- a01_05 THE LAST PRESS. "Oil painting, 18th-century history painting style. Dawn in a hidden courtyard between tall
  old houses: a great wooden printing press lies broken and overturned, its type scattered on the cobbles among
  hundreds of printed sheets. Two soldiers in purple coats hold a grey-haired master printer in a leather apron by the
  arms; he looks up defiant. A young priest in a black cassock stands to one side, tired, his hand on his breviary; an
  officer in a purple coat with a gorget gives an order. Pale pink morning light. 3:2 landscape, no text, no legible
  writing." (References: rome_tomasz.png, p01_05.)

## The voice lines (for the owner's Chatterbox recordings)

Recorded lines go in `campaign/voice/a01/<line id>.ogg` (or .wav / .mp3); the game plays them when present
(CampaignVoice). The King's in the King's voice (tools/voice_clone, refs king_ref.wav). THE CARDINAL (old Tomasz) and
FATHER TOMASZ (young) are one man fifty years apart: one designed voice, the young one brighter and quicker; CAPTAIN
DELORME, THE SERGEANT OF THE WATCH, MÈRE GAUTIER (an old weaver) and MASTER ROUVIÈRE need designed voices first (a 10-20 s
sample each, ElevenLabs only to design, then Chatterbox). "Lyon" (the narrator) and "the Free Assembly" (versus only)
can stay text.

| file (campaign/voice/a01/) | voice | when | line |
| --- | --- | --- | --- |
| k_open1.ogg | The King | opening (crown) | The year after Virginia, the Assembly's pamphlets were in every city of the Crown. |
| k_open2.ogg | The King | opening (crown) | Most of them were printed in Lyon. The Cardinal was there. He was a young priest then. |
| c_open.ogg | Cardinal Tomasz | opening (crown) | I was ordained that spring and sent to a parish on the hill. I thought I would baptise silk-weavers' children. |
| t_open1.ogg | Father Tomasz | opening (crown) | The papers were on every church door by morning. Nobody saw who nailed them. |
| t_open_saved.ogg | Father Tomasz | opening (crown) | The Hollins boys wrote to me from Virginia. Their families were safe. I kept the letter in my breviary. |
| t_open_left.ogg | Father Tomasz | opening (crown) | I still prayed for the families we left on the road in Virginia. Nobody wrote to me about them. |
| t_open2.ogg | Father Tomasz | opening (crown) | Captain Delorme came to the presbytery. He said: Father, you know these streets. Help me find the presses. |
| k_open_a.ogg | The King | opening (assembly) | The Assembly left no account of that spring. Here is what it set out to do. |
| d_1.ogg | Captain Delorme | intro | Six presses at least, Father, hidden in houses like any other. The runners carry the papers to the squares. |
| t_1.ogg | Father Tomasz | intro | Then we watch the squares, and follow the runners home. |
| tip_1.ogg | Captain Delorme | intro | A press looks like a house until our men stand at its door. Every runner who reaches a square stirs the city. |
| tip_2.ogg | Captain Delorme | tip_riders | The riders are quick through the streets. Send them to look. Keep the muskets on the squares. |
| tip_powder.ogg | Captain Delorme | tip_powder | Ten shots a musket, Father, then the bayonet. The powder wagon fills them again: keep it near the men. |
| t_saved.ogg | Father Tomasz | intro_saved | We went back for the families in Virginia, Captain. I mean to do as well by these people. |
| t_left.ogg | Father Tomasz | intro_left | We left the families on the road in Virginia. I have confessed it. I will not do it twice. |
| w_runner.ogg | Sergeant of the Watch | first_runner | A runner, Captain! A boy with a bundle of papers, running for the squares. |
| w_hint.ogg | Sergeant of the Watch | the Watch's hint (5:00, then every 2:30) | We saw where a runner came out, Captain. That house there. The door was still open. |
| d_found.ogg | Captain Delorme | first_found | A press! Their men are inside. Break it. |
| t_found.ogg | Father Tomasz | first_found | Spare the boys who carry the papers if you can. They cannot read what they carry. |
| d_closed.ogg | Captain Delorme | first_closed | One press silent. The type goes into the river. |
| t_sermon.ogg | Father Tomasz | sermon_line | I spoke on the square until my voice went. Some of them listened. Some went home. |
| n_temper10.ogg | Lyon | temper_10 | Shutters close on the Presqu'île. Men gather at the corners and do not talk when soldiers pass. |
| n_temper15.ogg | Lyon | temper_15 | Stones are thrown at the Watch on the bridges. The city is close to rising. |
| d_temper15.ogg | Captain Delorme | temper_15 | Father, they are throwing stones on the bridges. Stop the runners or we lose the city. |
| d_2.ogg | Captain Delorme | part2 | Four presses closed. Now the Assembly calls the weavers up the hill, to their hall. |
| t_2.ogg | Father Tomasz | part2 | Let me speak to them, Captain. They are my parish. Hold the stairs and give me the time. |
| tip_3.ogg | Captain Delorme | part2 | Father Tomasz must stand on the hall's square. While he is not there, the agitators turn the weavers. |
| d_band1.ogg | Captain Delorme | band_1 | A band at the Terreaux, coming up the middle stair! |
| d_band2.ogg | Captain Delorme | band_2 | More from the Saône bridge, for the west stair. |
| d_band3.ogg | Captain Delorme | band_3 | And from the Rhône, with torches, for the east stair. |
| n_turn.ogg | Lyon | turn_line | Weavers pick up stones. A few of them follow the green cockades. |
| t_turn.ogg | Father Tomasz | turn_line | Bring me to them. They will not turn while I am speaking. |
| t_spoken.ogg | Father Tomasz | spoken | I told them who I was, and whose son. I told them nobody in that hall had ever printed bread. |
| wv_spoken.ogg | Mère Gautier | spoken | That's enough. Home, all of you, and at the looms by first light. The little Father is right. |
| n_hall.ogg | Lyon | hall_burnt | The Weavers' Hall is burning. The whole hill can see it. |
| wv_yard.ogg | Mère Gautier | part3 | Father. There is a yard under the hill with no street to it. You go in through the houses. |
| t_3.ogg | Father Tomasz | part3 | The traboules. Captain, the great press is there. |
| tip_4.ogg | Captain Delorme | part3 | Two passages lead into that yard. Take the printer alive: the King will want to know who pays him. |
| d_great.ogg | Captain Delorme | great_found | There it is. A press as big as a church organ. |
| pr_1.ogg | Master Rouvière | great_found | You are too late, Father. Half of France has read us already. |
| d_early.ogg | Captain Delorme | great_early | A great press in a yard! We will come back for it with more men. |
| pr_taken.ogg | Master Rouvière | taken | Take me, then. The paper comes from Paris. Ask there. |
| t_taken.ogg | Father Tomasz | taken | He said Paris. He said it as if it were a threat. |
| d_won.ogg | Captain Delorme | won | The great press is broken. Lyon is quiet. |
| t_won.ogg | Father Tomasz | won | The bells rang for Lauds. I had not slept, and I said Mass anyway. |
| d_hurt.ogg | Captain Delorme | tomasz_hurt | The Father is hurt! Men round the priest! |
| n_risen.ogg | Lyon | risen | Lyon rises. The Assembly's flags are on the Terreaux. |
| a_1.ogg | The Free Assembly | opening (assembly) | Your presses print in houses like any other. Walk the runners to the squares and the city will rise. |
| a_tip.ogg | The Free Assembly | intro_a | The Crown cannot touch a press it has not found. Keep its men away from your doors. |
| a_layout_old_town.ogg | The Free Assembly | layout (old_town, versus) | Your presses: the hill's west, the slopes, the Presqu'île, Vieux Lyon's north and Guillotière's south. |
| a_layout_river.ogg | The Free Assembly | layout (river, versus) | Your presses: the hill's east, the slopes, the Presqu'île, Vieux Lyon's south and Guillotière's north. |
| a_layout_hill.ogg | The Free Assembly | layout (hill, versus) | Your presses: the hill's west, the slopes, the Presqu'île, Vieux Lyon's north and Guillotière's north. |
| t_end1.ogg | Father Tomasz | ending (crown) | Rouvière went to Rome in chains. He never named the man who paid him. Only Paris, whenever they asked. |
| t_end_calm.ogg | Father Tomasz | ending (crown) | By Pentecost the weavers were back at their looms, and they came to Mass. |
| t_end_sullen.ogg | Father Tomasz | ending (crown) | The city stayed quiet. When I crossed a square, the talk stopped until I had gone by. |
| t_end_saved.ogg | Father Tomasz | ending (crown) | I wrote to the Hollins boys that summer. I told them about Lyon. I did not tell them everything. |
| c_end.ogg | Cardinal Tomasz | ending (crown) | I was proud of that spring, God forgive me. I was also lucky. |
| k_end1.ogg | The King | ending (crown) | Lucky. He talked a city home without a shot fired, and he calls it luck. |
| k_end2.ogg | The King | ending (crown) | Paris was another matter. |
| k_end_a1.ogg | The King | ending (assembly) | That is not how it went. Lyon did not rise. |
| k_end_a2.ogg | The King | ending (assembly) | Had it risen, Paris would not have stood alone that summer. |

## What is placeholder

- Every line, every objective's words, the briefings and the debriefs.
- The stills (simple drawings).
- Father Tomasz is a Missionary, Captain Delorme a Dismounted Officer, the runners, the printer and the weavers
  Labourers, the Watch Musketeers in pink (the campaign roles' stand-ins). The presses are the Crown's Cottage, the
  great press a Barracks, the Weavers' Hall a Town Hall, the traboules' doors palisades; the houses are cottage and
  shed props (a town of its own look waits for town-house props).
- The voice folder a01 is empty (silent).

## Claude's choices for the owner

1. A PRESS IS A COTTAGE AMONG THE TOWN'S COTTAGES. The town's own houses are buildings too (yellow, selectable), so a
   player learns to look at the yellow buildings: 28 of them, six of which print. The plain houses (props) never print.
2. SEEN ONLY BY A MAN WHO STOPS: a press is given away by a Crown man standing 3 s within 2 tiles of it, not by one
   marching past (without it, the garrison walking to the squares found half the presses in a minute).
3. THE WATCH'S HINT every 2:30 from 5:00 (the plan's "follow them back"): a player who can't find the last ones is
   not stuck. Runners also show where they come from: their street.
4. WHERE THE PRESSES PRINT: three layouts of six, the match's seed picks (not the versus friend: an online guest can't
   answer a choice yet; the engine's choice is offered to the player on the host's screen only). Picking six of twelve
   himself is the plan's; it waits for a "remote choice".
5. THE TEMPER: starts at 2, a runner +1, a press closed -2, a sermon -1 a 30 s, a turned pair of weavers +1, the hall
   burnt +4, the speech -3; 20 loses; `lyon` calm under 6 (a player who guards the squares ends near 0; one who lets runners through, or the weavers turn, does not). Numbers to tune with real players.
6. PART 2's PRESSURE is on the priest: the agitators turn weavers only while he is away from the square, so the player
   must bring him up the stairs the bands are climbing. The mob goes for the Weavers' Hall (its own riot), not for him.
7. THE YARD's TRABOULES ARE SHUT UNTIL PART 3 (doors in the town's colour, spared): without them the pathfinder used the
   yard as a shortcut and the great press was found by accident in Part 1. The other six traboules are open shortcuts.
8. THE GREAT PRESS PRINTS ON in Part 3 (a runner every 40 s) so a slow Part 3 still costs something.
9. THE GARRISON MAY TRAIN Musketeers (four quarters cottages, the city's 40 gold a minute and 60 a press): losses in
   Part 1 can be made good. Nothing else can be built.
10. THE CITY WATCH IS PINK (the plan says purple): two teams of one colour would be hard to tell apart in co-op.
11. TOMASZ HAS 360 HEALTH (Hollweg 260): he walks into the riot by design.
12. NO ASSEMBLY COMPUTER: the Assembly is scripted (its runners walk to their squares, its men hold their doors); in
    versus the friend leads everything it gets. The Free Assembly is still the Crown's stand-in in the rebels' colours.
13. THE MAP'S TOWN is generated (seed 1768): the quarters, rivers, hill and squares are placed by hand in the map script,
    the blocks and houses by the generator. Change the seed for a different town on the same plan.
14. p01's `families` changes Tomasz's words only (the plan: the volunteers go to Paris, a06).
15. ONLINE, THE DISGUISE IS THE HOST'S: the host's screen draws it; a co-op guest (the Watch) sees the presses in their
    true green, because a guest's world is the host's snapshots and the disguise is mission state. The host still
    refuses any order on a disguised press. Sending the disguise in the snapshot is a small follow-up (NetView).
16. A FOUND PRESS LOSES 150 OF ITS 400 HEALTH (its door broken in): Musketeers far from powder run dry and fight a
    house with the bayonet; without it the bot stood at one press for minutes. With the powder tip at 2:00.

## Tests run

- tools/test_campaign_a01.gd: 118 checks, 0 failures (the data and translations, the Crown line and p01's way on, the
  seats for every mode, the map and stills, the war map pin and its rules; p01's `families` save / leave / none; the
  layouts (random by the seed, each of the three), the disguise (the town's colour, untouchable; 5 tiles off nothing, at
  the door 3 s found; the Assembly's own man never; the Watch finds one too), the presses' men; Part 1's runners and
  squares, the temper (+1, -2, the sermon -1, never under 0), the Watch's hints; Part 2's weavers, the agitators turning
  them while Tomasz is away, the bands, the STAY, home; Part 3's doors, the great press found, its runners, the capture,
  the win, `lyon` calm / sullen, `printer`, the ending by the flags, the progress; the defeats; versus (the Assembly
  wins at the top, the story follows it); EASY and HARD (the runners' timetable, the presses' men, the hints); the hub's
  talks).
- tools/test_city_gen.gd: 12 checks, 0 failures (the same seed the same town, another seed another; Lyon's map is its
  script's; the loader places all 1,859 houses; every square, bridge, stair and lot reached from the garrison by the
  game's pathfinder (47 areas); the yard walled but for its traboules).
- tools/test_campaign.gd: 123 checks, 0 failures. tools/test_campaign_m1.gd: 103, 0 failures (its storyline check now
  reads p01 FIRST on the Crown line). tools/test_campaign_a02.gd: 139, 0. tools/test_campaign_a03.gd: 195, 0.
  tools/test_campaign_b01.gd: 176, 0. tools/test_campaign_c01.gd: 243, 0. tools/test_war_map.gd: 64, 0 (a01 is now
  built: locked before p01, open after it; Lyon purple / uneasy / in unrest by the flags). tools/test_tutorial.gd: 326, 0.
- Boot: `godot --headless --quit-after 300`, no SCRIPT ERROR (the class cache rebuilt with `godot --headless --editor
  --quit`).
- tools/sim_campaign_a01.gd: the runs in "Balance".
- As before on this cloud machine every headless Godot run ends with "Aborted" (exit 134) AFTER its last line: the
  engine's shutdown here, not a test.
- Not run: the faction and AI tests (no unit, price or skirmish rule changed: the engine's additions act only inside a
  mission that asks for them; the colour on the minimap and the card goes through Entity.cloth_colour, the same colour
  as before for anything not disguised). Not played on two devices (co-op, versus): a co-op guest's screen gets the
  host's snapshots, so it shows a disguised press in its true green (the disguise is drawn per screen from the host's
  mission state, which a guest does not run); the host still refuses to target it.
