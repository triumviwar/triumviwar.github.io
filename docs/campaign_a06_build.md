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
RUGGIERI (an Officer) with 2 FIELD CANNONS and a MORTAR (the friend's in co-op, BLUE), 14 Musketeers, 4 Horsemen, a
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
  there: the wagon and the muskets fill up near the fight, not back at the camp). Notre-Dame, spared until now, can be
  hurt. The Assembly holds the north ends of the PONT NOTRE-DAME and the PONT AU CHANGE (3 militia and a pike each;
  a01's Lyon men with them by `lyon`) and the south end of the Petit Pont (3 militia). TORCH-BEARERS come over the
  Petit Pont from the Place Maubert at 1:00, 1:40 and 2:20 (two torches and two militia each) for NOTRE-DAME (900
  health; a torch burns 6 a second): "Notre-Dame must not burn". "Take the bridges: n of 2".
- PART 3, THE HALL (5 s after both bridges are taken and the third wave's torches are down). The palisade round the
  Hôtel de Ville's square (spared until now) and the hall's men (8 militia, 3 pikes, Varenne's guard of 3 among them)
  can be hurt; the hall itself stays (the city's). "Take Varenne ALIVE" (a CAPTURE: he can't be brought under a
  quarter of his 260 health; there, with a Crown man beside him, he is taken). Once the ring is BREACHED (a piece down,
  or a Crown man inside) Fairleigh warns "watch the west gate"; 12 s later (EASY 25, HARD 6) Varenne RUNS out by the
  ring's west gate (the Assembly's: it opens for its own) with his guard for the boats at the PORT SAINT-NICOLAS; 30 s
  at the quay (EASY 45, HARD 20) and he is GONE (a loss).
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

BALANCE_TABLE

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

VOICE_TABLE

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
6. VARENNE RUNS once his ring is breached, and 30 s at the quay loses him: the plan's versus "Varenne gets out by the
   river" made into a solo threat, so the Horsemen have a job and the capture is a chase. EASY gives him a later start
   and a slower boat; a player who heeds "watch the west gate" holds the gate first.
7. THE CHOICE UNANSWERED IS SPARED (the canon), after two minutes; it is the Crown's choice in versus too (the host's
   screen), as the plan says: "Fairleigh's order, the player's buttons".
8. EXECUTED does not kill Varenne on the map (he stays taken: the capture objective would read a death as a failure);
   the lines and the ending say it.
9. THE LYON MEN stand at the BRIDGES (the plan: "the Lyon men are there by `lyon`"), two a bridge when Lyon was sullen.
   `risen` is handled (four a bridge, two more at the third barricade) though only versus can reach it.
10. THE VOLUNTEERS are named Hollins (the farm the families were saved at): Will, Tom, Jacob, Ned, Sam and Eli. Never
    scaled by the difficulty, like the rest of the army.
11. Notre-Dame, the hall, its ring, its men and Varenne are SPARED until their part (nobody can hurt them before), and
    the hall itself is never open to attack (it is the city's; the ring is what the guns break).
12. THE BRIDGES' MEN stand at the bridges' NORTH ends (and the Petit Pont's men at its south end): standing on the
    crossing their muskets reached Notre-Dame and they burnt it in Part 1.
13. The torch waves come at 1:00, 1:40 and 2:20 (the plan's "torch-bearers go for it"): two torches and two militia
    each; a torch burns Notre-Dame for 6 a second (two torches: about 75 s for the 900 health).
14. RUGGIERI'S GUNS ARE THE CO-OP FRIEND'S (BLUE, as in p01) and the army's in solo and versus. Both teams are bound to
    C3, so the friend's guns and the army's Foundry make the same pieces.
15. THE ARMY CAN'T BUILD A TOWN HALL OR FARMS (the story's deny on top of the ladder): the treasury pays it, 100 gold and
    40 powder a minute.

## Tests run

TESTS_RUN
