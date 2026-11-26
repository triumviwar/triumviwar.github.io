# Act 1, "Father Ferrer's Visit": what was built (job a04-visit, 0.38.63)

Step 7 of Act 1's build order (docs/campaign_act1_plan.md): the Clockmaker line's third mission, a04_visit, built as the
plan and its OWNER ANSWERS of 2026-11-17 say: Fürth in the autumn of 2769, eighteen months after the line held; FATHER
FERRER tells it himself (a Crown-side narrator: truthful), the King frames it; THE CHOICE, THE BROKEN ONES: Ferrer MELT
them / Hollweg KEEP them, the CANON and the default KEPT; VERSUS ONLY (no solo mirror: the machine's side would be a
short wait for a riot); EASY / NORMAL / HARD. It is also THE ROSTER LADDER's K3 (docs/campaign_roster_ladder.md): the
HEAVY WORKS and the PENDULUM are the guild's new pieces, and the riot shows what a Pendulum is for.

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite (kept short and plain on purpose). The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/a04_visit.json`, written by `tools/campaign/make_a04_mission.py` (edit the script, run it) |
| the map | `campaign/maps/furth_works.json` (`campaign:furth_works`), written by `tools/campaign/make_furth_works_map.py` FROM a02's `furth_line.json` (the same ground; its props changed); opens in the MAP EDITOR |
| the stills (stand-ins) | `campaign/stills/a04_01.jpg` .. `a04_05.jpg`, drawn by `tools/campaign/make_a04_stills.py`; the King's pages reuse `c01_01` |
| texts pt / es | `tools/i18n/campaign/a04_visit.txt` (then `python3 tools/i18n_build.py`): the mission, the hubs' talks after a04, the K3 cards, the two new roles |
| the storyline, the hubs | `campaign/campaign.json`: the Clockmaker line is c01, a02, a04; Hollweg's and the automaton's talks at Fürth after a04 by `broken`, the travelling clock; the King's and Hollweg-in-exile's in the King's study by `broken` |
| a02's way on | `make_a02_mission.py` / `a02_furth.json`: `"next": {"guild": "a04_visit"}` (a machine win still leads nowhere) |
| the war map | `campaign/warmap.json`: a04's pin lost its working title (the mission's own is used); its rules (`broken` melted / kept, `lost_to_machine` 4 or more: Franconia's red spreads east) were already there and now check against the built mission |
| the roster ladder | `tools/campaign/roster_ladder.py`: a04's CARD_AT (8 s) / SIDE (`visit`), the Heavy Works' and the Pendulum's cards in pt / es |
| roles | `scripts/campaign/rebels.gd`: `ferrer_visit` (Ferrer with 300 health), `lay_brother` (Missionaries) |
| the engine | `scripts/campaign/mission_run.gd`, `campaign.gd`: the `wind` action (below) |
| tests | `tools/test_campaign_a04.gd` (`godot --headless --fixed-fps 30 --script res://tools/test_campaign_a04.gd`) |
| balance | `tools/sim_campaign_a04.gd` (`-- active furth=strong|thin jakob=alive|lost gate=pattern|people diff=easy|normal|hard broken=melted|kept careless until=<s>`) |

## The map: Fürth grown (128 x 80, the autumn biome)

a02's ground cell for cell (the rivers, the fords, the line's place, Nuremberg's walls): the map script starts from
a02's file, clears the props where the mission builds and adds its own:

- THE WORKS round THE HONEST ONE (the guild's Clocktower at [44, 16], the standard start): six workshops (the
  mission's buildings): the LIGHT WORKS, the ESCAPEMENT, a COG PRESS, the MAINSPRING, the PRESS-HOUSE (a Cog Press with
  the journeymen's lockers) and the HEAVY WORKS; crates, forges, carts at the yard's edges. HOLLWEG'S BARN (west).
- THE TOWN grown north; the refugees' tent ground on the south bank built up into cottages.
- THE RIVERBANK below the chapel (north bank of the Pegnitz, inside the line): reeds, a boat, crates: where the night
  shift goes.
- THE LINE dug its whole length (the mission's palisades, team `party`), the ROAD GATE (two gates) on the north bank,
  and on the meadow bank an OPEN GAP for the carts (four cells): the riot's way out.
- THE MEADOWS: the Rednitz mill a burnt ruin; the MACHINE'S GROUND crept west: a Clocktower SEED at [78, 43] with three
  Regulators (its links), the seeds by Nuremberg's gates as in a02.

## How it plays: FATHER FERRER'S VISIT (solo; co-op with the guild; versus against the Machine)

Opening (the King in Rome, then Ferrer): the Roman College asked leave to inspect the guild; the King sent the man who
had warned Hollweg once; Fürth had grown into a town of gears; Hollweg met him at the gate, proud.

FERRER'S PARTY (PURPLE, the player): FATHER FERRER (a Missionary, 300 health), two LAY BROTHERS (Missionaries: they bring
the fallen back), an ESCORT of Franconian Musketeers by a02's `furth` (strong 8, thin 5), the line's GATE MEN (4 at the
meadow gap, 3 at the road gate, on hold), 300 powder. No production: the party is not bound by the ladder.
THE GUILD (BLUE, allied; the friend in co-op, else scripted): MEISTER HOLLWEG, JAKOB if he is alive (a02's or c01's
`jakob` lost: no Jakob), the Honest One with its presses and Winders, the six workshops (spared: nobody burns them),
4 Clock Soldiers by the barn, a line of 2 Clock Soldiers and 2 Springers and THE PENDULUM on hold at the yard's south
gate, 300 cogs; bound to K3 (the Clockwork kit, the Winder, Clock Soldier, Springer, Netter, Escapement, and NEW: the
Heavy Works and the Pendulum). THE WORKS (TEAL, scripted always): the guild's automata that work by themselves (the
winding pair in the Escapement, the night Winder, the broken ones). THE MACHINE (RED): a garrison of 4 Clock Soldiers on
its meadow ground (scripted), its seeds spared.

- PART 1, THE INSPECTION. "Inspect the guild's six workshops: n of 6." Ferrer STAYS 10 s in each (any order): four show
  nothing ("Nothing here."), two show the signs: the ESCAPEMENT, a Winder winding another Winder ("Who told it to?");
  the PRESS-HOUSE, the Free Assembly's pamphlets in the journeymen's lockers, and 8 s later, if a01 was played, Ferrer
  knows the type from Father Tomasz's report from Lyon (the broken letter E), else "someone pays for this". Hollweg
  walks with Ferrer (follows him) until the third workshop, when Jakob (a journeyman, if Jakob is lost) calls him away to
  the presses; then JAKOB comes to
  the Father ("Not in front of the Meister") and, at his side, shows him the STOP-WORKS he found in a bin behind the
  Escapement, twelve, taken out clean (flag `stopworks` found). With Jakob lost (or killed before he speaks), after the
  six workshops: "Read Jakob's old log in Hollweg's barn" (a STAY of 6 s): the same signs, two years old (flag
  `stopworks` logged). The dusk: "The works shut at dusk" (10:00 NORMAL, EASY 12:30, HARD 8:30, a raced countdown);
  Hollweg warns 1:30 before; out with the inspection unfinished, THE VISIT IS LOST.
- PART 2, THE NIGHT SHIFT (6 s after the inspection and Jakob's word or the log). Hollweg bids the Father good night,
  "the works rest at night"; Ferrer stays up. Dusk, then night (20 s each). The broken ones stand on the riverbank and
  by the Mainspring (the press-house's night shift); a REGULATOR of the works' own, "Gear ground", on the bank: the gear
  ground nobody laid. THE NIGHT WINDER comes out of the Honest One's yard and, 8 s later, walks its way (a ROUTE in three
  legs with a 12 s stop between them: round the town, the camp behind the line, down past the Mainspring to the
  forge in the west, then to the river). "Follow the night Winder. Keep it within 8 tiles, and never closer than 3, or it
  turns back." TOO CLOSE (one of Ferrer, the brothers or the escort within 3 tiles): it stops and turns its head ("Back
  off, and wait."); it goes on only when none of them is within 4 tiles and 12 s have passed, with the leg it was on.
  TOO FAR (none within 8 for 10 s): a brother says where it went (a ping; it doesn't wait). At the bank: "Watch from the
  bank": Ferrer 3 s in the bank's watch ground (or a man of the party by the gear ground): THE REVEAL: the automata
  stand in a ring on gear ground nobody laid, MESHING. By c01's `gate`: PATTERN (the canon) "the Perpetual's pattern,
  every wheel, with a stop-work bolted on: they took it off themselves" (the flaw in the drawings); PEOPLE "red brass in
  every one: parts salvaged from the line, fitted to save time" (the flaw in the machine), and two more of them. The
  dawn: 7:00 (EASY 8:45, HARD 5:57) to see it; out before the reveal, THE VISIT IS LOST.
- PART 3, THE RIOT (12 s after the reveal). The broken ones CONVERT (red, the c01 stutter, 3 s), wound to 0.6 (they
  wind each other: the new `wind` action), and march for the machine's ground: a ROUTE over the bridge, the south bank,
  the open gap, onto the meadows (on the machine's ground they are counted and gone: `lost_to_machine`). Off their
  ground they run down as they go: slower, and still at nothing. The two in the Escapement keep their stop-works:
  Hollweg stops them with his key (caged, spared). The machine SENDS A SORTIE to meet them at the gap (6 Clock Soldiers
  and 2 Springers 6 s in; its garrison 10 s later) that goes for Ferrer once through. The guild's PENDULUM and line hold
  the yard's south gate, where the press-house shift comes past (the scripted guild's Winders keep them wound). NORMAL
  15 broken (10 at the bank: 6 Clock Soldiers, 2 Springers, 2 Winders; 5 by the Mainspring: 4 and a Springer); EASY 10;
  HARD 19; c01 `gate` people +2. "Stop the broken automata before they reach the machine's ground. Lost to the machine:
  n."
- THE CHOICE, THE BROKEN ONES (6 s after the last one is down or gone): Ferrer "Melt them, Meister. Every wheel.",
  Hollweg "No. Let me keep them. I must learn what went wrong." MELT THEM (Ferrer) / KEEP THEM (Hollweg); unanswered
  in 2:00, KEPT (the default and canon). Then dawn, "I rode for Rome that morning with my report", and the visit WINS.
- THE DEFEATS (retry): Father Ferrer killed, Meister Hollweg killed, the dusk with the inspection unfinished, the dawn
  with nothing seen. Losing broken ones to the machine is never a defeat: it is counted.

The ending (Ferrer, then the King): the report not softened; melted ("Hollweg did not speak to me again until Rome") or
kept ("Hollweg swore he would mend them"); some reached the machine (if any); Jakob told him and not his master (if
Jakob found the stop-works); the King read it twice; kept: "Hollweg brought his mended machines to Rome. I let him. That
was my mistake, not his." / melted: "Hollweg came to Rome with nothing but his drawings, and his anger."

## How it plays: THE MACHINE (versus only)

The friend is the machine (RED) on its meadow ground: 6 Clock Soldiers, 2 Springers, 3 Winders, a Light Works, 400 cogs
and 150 Tension, its seed paying 150 cogs and 15 Tension every 30 s while it stands (not spared in versus: the visit
may fight for it). No presses, no Mainspring. "Kill Father Ferrer, or bring 6 of the guild's broken automata to your
ground: n of 6. They wake at night." At the riot the broken ones become ITS units (the convert), and the scripted march
order is the start of their walk. No scripted sortie (the machine is a person's). The win: Ferrer dead (the visit's own
protect objective fails) or 6 brought home. The ending is the King's one line (the machine has no voice).

## The flags read and set

A flag that is missing reads as the canon: a02 `furth` strong, Jakob alive, c01 `gate` pattern, a01 not played.

| flag | value | a04 |
| --- | --- | --- |
| a02 `furth` | strong / thin | the escort: 8 / 5 Musketeers; thin: Ferrer's line "the colonel could spare me only five men" |
| a02 `jakob`, c01 `jakob` | lost in either | no Jakob: no word from him; Ferrer reads his old log in the barn instead |
| c01 `gate` | pattern / people | the reveal's lines (the flaw in the drawings / in the salvaged parts); people: two more broken ones (salvaged) |
| a01 `printer` / `lyon` | any (a01 played) | Ferrer knows the pamphlets' type from Tomasz's report |

Flags it SETS (kept when won): `broken` melted / kept (the choice), `lost_to_machine` the number (0, 1, 2, ...: a tally
whose bands are the numbers themselves, so the war map's `flag_at_least` reads it; `lost_to_machine_n` the same),
`stopworks` found (Jakob) / logged (the log), `jakob` alive / lost (alive only if he was there and lived). For a07 (Rome):
`broken` kept = Hollweg's demonstration; `lost_to_machine` = Franconia's red; `stopworks` found = Jakob's evidence.

## The engine (one action; docs/campaign_engine.md "Added by Act 1's a04_visit")

- `{"wind": {"tag", "share"}}`: Clockwork units wound up to that share at least. The broken ones stood run down on the
  bank (the works have no ground of their own: run down to nothing a construct STANDS STILL) and would never have
  marched; the scripted guild's Pendulum and line are kept wound on their post (a scripted Winder's job).
- Everything else was there: STAY (`reach` with `secs` and the `stay` condition), FOLLOW (Hollweg after Ferrer, Jakob
  to Ferrer), ROUTE and `route_done` (the night Winder, the riot), NEAR (too close, too far, the party at the gear
  ground), `convert` with its stutter, `exits` with `after` (the machine's ground), counters, `tally`, clocks and
  countdown objectives, a choice with a default, `cage` and `spare`, `if` by `past` and `difficulty`, trigger `modes`
  (the scripted guild's lines only when nobody leads it), lights `day` / `dusk` / `night` / `dawn`.

## Balance (tools/sim_campaign_a04.gd)

The bot: Ferrer to each workshop in turn with the escort round him (and to the barn for the log); at night the party
shadows the Winder 5.5 tiles off; at the bank Ferrer into the watch ground; in the riot the escort runs for the gap
(attack-moving), chasing what is past it, the gate men and the gap men at the gap, Ferrer and the brothers back in the
yard; the choice answered at once. `careless` keeps the party 2 tiles off the Winder (it stops every time).

| run (c01's and a02's canon unless said) | result | time | lost to the machine |
| --- | --- | --- | --- |
| active, NORMAL | WON, kept | 5:29 | 4 of 15 (spotted 6 times) |
| active, NORMAL (again) | WON, kept | 6:20 | 6 of 15 (spotted 10 times) |
| active, EASY | WON | 5:12 | 1 of 10 |
| active, HARD | WON | 4:55 | 5 of 19 |
| active, `furth` thin (5 escorts) | WON | 5:15 | 8 of 15 |
| active, Jakob lost, `gate` people, melted | WON, the log read (`stopworks` logged), melted, `jakob` lost | 5:08 | 7 of 17 |
| active, careless (2 tiles off the Winder) | LOST at dawn: the Winder stopped and never went on | 9:08 | - |
| passive, NORMAL | LOST at dusk (the works shut, nothing inspected) | 10:01 | - |
| passive, EASY | LOST at dusk | 12:31 | - |
| (earlier tunings: the broken ones run down on the bank, never marching; then wound in full and marching straight, 7-8 of 18 lost; the guild's Pendulum walking off its ground and standing run down) | | | |

Reading: Part 1 takes the bot about 2 minutes (six workshops at 10 s each and the walks), Part 2 about 2-3 (the
Winder's three legs, its stops, and every time it is spotted), Part 3 about a minute: the bot wins in 5-6 minutes;
a human who walks the town, watches the night shift and fights the riot will take 10-15. The riot is a chase: the broken
ones only walk, but they are many and close to the gap; a player who gets ahead of them at the gap (or holds the bridge)
loses few, one who chases from behind loses about half. The careless shadow loses at dawn; the passive player loses at
dusk. The sim runs about 2x real time headless.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

House style as the prologues (campaign/stills/p01_*.jpg, c01_*.jpg, a02_*.jpg): an oil painting in the manner of an
18th-century history painting, visible brushwork, 3:2 landscape (cut to 1280 x 853), no text or lettering anywhere.
The Crown's men in PURPLE coats; the guild's machines brass with BLUE enamel; the runaway machines brass with RED enamel.
Father Ferrer: a Jesuit in a black cassock and cloak, about fifty, lean, grey at the temples, spectacles, a notebook.
References: p01_05 (the style); campaign/hub/nuremberg_hollweg.png where Hollweg appears (grey curly hair, moustache,
leather apron, red-brown coat). Save each as `art/campaign/stills/a04_0N.png` and cut it to 1280 x 853 into
`campaign/stills/a04_0N.jpg` (nothing else changes). The King's pages reuse c01_01.

- a04_01 THE ARRIVAL. "Oil painting, 18th-century history painting style. Autumn in a small German town that has grown
  into a works of brass gears: a tall brass clock tower machine with blue enamel plates in a busy yard, workshops and
  turning gears round it, falling orange leaves. At the gate a lean Jesuit priest in a black cassock and cloak with
  spectacles and a notebook arrives with two lay brothers in brown and a file of musketeers in purple coats; an old
  clockmaker with grey curly hair, a moustache, a leather apron and a red-brown coat comes to meet them, proud. Warm
  afternoon light. 3:2 landscape, no text." (References: nuremberg_hollweg.png, p01_05.)
- a04_02 THE INSPECTION. "Oil painting, 18th-century history painting style. Inside a timber workshop full of brass
  gears: a small brass automaton with a blue enamel plate fits a large wind-up key into the back of another automaton and
  turns it, by itself. A lean Jesuit priest in black with spectacles watches and writes in a notebook; beside him an old
  clockmaker with grey curly hair in a leather apron looks away. Lamplight and dust. 3:2 landscape, no text."
  (References: nuremberg_hollweg.png, p01_05.)
- a04_03 THE NIGHT SHIFT. "Oil painting, 18th-century history painting style. Night by a river below a chapel: a ring of
  small brass automata with blue enamel plates stands on a patch of large brass gears set into the riverbank, turning
  slowly, faint cold light between the teeth. Behind stacked crates in the foreground a Jesuit priest in black and two
  lay brothers watch, one shading a lantern with his hand. Moonlight on the water. 3:2 landscape, no text."
  (Reference: p01_05.)
- a04_04 THE RIOT. "Oil painting, 18th-century history painting style. Dawn over wet water meadows by a river: a crowd of
  small brass automata walks east in a stream, their enamel plates turning from blue to red; musketeers in purple coats
  fire into them from a ford, powder smoke; by a workshop yard a tall brass machine on long legs swings two great
  crescent blades on weights through the crowd like scythes. On the horizon a walled city with red towers. 3:2
  landscape, no text." (Reference: p01_05.)
- a04_05 THE BROKEN ONES. "Oil painting, 18th-century history painting style. Morning in a works yard: stopped brass
  automata laid out in rows on the cobbles, some plates blue, some red. On one side a lean Jesuit priest in black with
  spectacles points to a glowing furnace door behind; on the other an old clockmaker with grey curly hair in a leather
  apron and red-brown coat stands between him and the automata, one hand raised. Cold light, orange glow from the
  furnace. 3:2 landscape, no text." (References: nuremberg_hollweg.png, p01_05.)

## The voice lines (for the owner's Chatterbox recordings)

Recorded lines go in `campaign/voice/a04/<line id>.ogg` (or .wav / .mp3); the game plays them when present
(CampaignVoice). The King's in the King's voice (tools/voice_clone, refs king_ref.wav). MEISTER HOLLWEG and JAKOB as
designed for c01 / a02 (still to design); FATHER FERRER and BROTHER ANSELM need designed voices first (a 10-20 s sample
each, ElevenLabs only to design, then Chatterbox). "Fürth" (the narrator) and "The Machine" (versus only) can stay text,
or the off-beat tick. The NEW cards are text.

| file (campaign/voice/a04/) | voice | when | line |
| --- | --- | --- | --- |
| k_open1.ogg | The King | opening (visit) | In the autumn of 2769 the Roman College asked me for leave to inspect the guild at Fürth. |
| k_open2.ogg | The King | opening (visit) | I sent Father Ferrer. He had warned Hollweg once. I wanted him to see whether he had been wrong. |
| f_open1.ogg | Father Ferrer | opening (visit) | Fürth had grown. Eighteen months of work, and the barn was a town of gears. |
| f_open2.ogg | Father Ferrer | opening (visit) | Hollweg met me at the gate. He was proud of it. He had a right to be, I thought then. |
| k_open_m.ogg | The King | opening (machine) | The machine had no voice. It waited across the meadows, and its ground crept west. |
| f_1.ogg | Father Ferrer | intro | Six workshops, Meister. I will see every one. |
| h_1.ogg | Meister Hollweg | intro | See what you like, Father. There is nothing here to hide. |
| b_tip1.ogg | Brother Anselm | intro | Walk the Father into each workshop and keep him there a moment. The guild shuts its doors at dusk. |
| f_thin.ogg | Father Ferrer | intro_thin | The colonel could spare me only five men. He has not forgotten the Rednitz. |
| h_heavy.ogg | Meister Hollweg | tip_pend | That is our Pendulum, from the Heavy Works. One swing clears a street. |
| f_ws1.ogg | Father Ferrer | ws_1 | The Light Works. Clean benches, good men. Nothing here. |
| f_ws3.ogg | Father Ferrer | ws_3 | A cog press. Every tooth stamped with the guild's mark. Nothing here. |
| f_ws4.ogg | Father Ferrer | ws_4 | The Mainspring. Wound tight, and the stop-work on it. Nothing here. |
| f_ws6.ogg | Father Ferrer | ws_6 | The Heavy Works. Big machines, built slowly. Nothing here. |
| f_wind.ogg | Father Ferrer | ws_2 | That Winder is winding another Winder. Who told it to? |
| h_wind.ogg | Meister Hollweg | ws_2 | They help each other. It saves the journeymen's backs. |
| f_wind2.ogg | Father Ferrer | ws_2 | I will write that down, Meister. |
| f_print.ogg | Father Ferrer | ws_5 | Pamphlets in the journeymen's lockers. The Free Assembly's. |
| h_print.ogg | Meister Hollweg | ws_5 | Young men read. I cannot stop them reading. |
| f_type.ogg | Father Ferrer | print_type | I know this type. Father Tomasz sent a page of it from Lyon. The same broken letter E. |
| f_type_no.ogg | Father Ferrer | print_plain | Good paper, a good press. Someone pays for this. |
| j_call.ogg | Jakob | call_j | Meister, the presses need you. The big one is off its beat. |
| n_call.ogg | Fürth | call_n (Jakob lost) | A journeyman calls Meister Hollweg away to the presses. The big one is off its beat. |
| j_word.ogg | Jakob | jakob_comes | Father. A word, please. Not in front of the Meister. |
| j_bin.ogg | Jakob | jakob_told | I found these in a bin behind the Escapement. Stop-works. Twelve of them. |
| f_bin.ogg | Father Ferrer | jakob_told | Taken out clean. Not broken. Taken out. |
| j_bin2.ogg | Jakob | jakob_told | Nobody here took them out, Father. I asked every man. |
| f_log0.ogg | Father Ferrer | log_obj | Jakob kept a log in Nuremberg. Hollweg keeps it now. I want to read it. |
| f_log.ogg | Father Ferrer | log_read | Two years old. Winders winding each other. Machines at work with no one at the bench. |
| f_log2.ogg | Father Ferrer | log_read | The same signs, Meister. Written down before Nuremberg fell. |
| h_log.ogg | Meister Hollweg | log_read | That was the Perpetual. These have stop-works. |
| h_dusk.ogg | Meister Hollweg | dusk_warn | We shut at dusk, Father. You have a little time left. |
| n_dusk.ogg | Fürth | dusk_out | The guild shut its doors. Father Ferrer's report stayed unwritten. |
| h_night.ogg | Meister Hollweg | part2 | That is all of it, Father. Sleep well. The works rest at night. |
| f_night.ogg | Father Ferrer | part2 | Then I will say Matins and not go to bed. Brothers, stay up with me. |
| b_night.ogg | Brother Anselm | night | Father, a Winder. Alone, out of the yard. Nobody sent it. |
| f_follow.ogg | Father Ferrer | night | Follow it. Quietly. |
| b_tip2.ogg | Brother Anselm | night | Keep it within eight tiles. Closer than three and it will see us. |
| n_spotted.ogg | Fürth | spotted | The Winder stops. Its head turns. Back off, and wait. |
| n_resume.ogg | Fürth | resume_1 | The Winder sets out again. |
| b_lost.ogg | Brother Anselm | lost_it | We have lost sight of it, Father. It went that way. |
| b_bank.ogg | Brother Anselm | at_bank | It stopped by the river, below the chapel. There are others there. |
| n_mesh.ogg | Fürth | reveal | On the bank the guild's automata stand in a ring on gear ground nobody laid. They are meshing. |
| f_mesh.ogg | Father Ferrer | reveal | They are building, Brother. And there is nobody at the bench. |
| f_pattern.ogg | Father Ferrer | reveal_pattern | The Perpetual's pattern, wheel for wheel. The stop-work was bolted on after, and they have taken it off. |
| b_pattern.ogg | Brother Anselm | reveal_pattern | Then the flaw is in the drawings, Father. |
| f_people.ogg | Father Ferrer | reveal_people | Red brass in every one. Parts salvaged from the line, fitted to save time. |
| b_people.ogg | Brother Anselm | reveal_people | Then the flaw is in the machine, Father, whatever the drawings say. |
| n_dawn.ogg | Fürth | dawn_out | Dawn came. Whatever the Winder went to do, it was done, and nobody saw it. |
| n_riot.ogg | Fürth | riot | They turn red, one by one, off the beat. Then they walk for the meadows. |
| f_riot.ogg | Father Ferrer | riot | They are going to the machine. Stop them before they reach its ground! |
| h_key.ogg | Meister Hollweg | riot_key | These two in the yard still had their stop-works. I stopped them with my key. Not those. |
| h_pend.ogg | Meister Hollweg | riot_key | The Pendulum, to the yard's gate! The press-house shift must come past it. |
| b_sortie.ogg | Brother Anselm | m_sortie | The machine is coming out to meet them, at the open gap in the line! |
| n_over.ogg | Fürth | riot_over | The last of them is down or gone. Dawn over the meadows. |
| f_none.ogg | Father Ferrer | over_none | Not one reached it. Thank God. |
| f_some.ogg | Father Ferrer | over_some | Some of them reached it. It will use them. |
| f_melt.ogg | Father Ferrer | broken_choice | Melt them, Meister. Every wheel. |
| h_keep.ogg | Meister Hollweg | broken_choice | No. Let me keep them. I must learn what went wrong. |
| f_melted.ogg | Father Ferrer | broken_choice | Into the furnace. I watched it done. |
| h_melted.ogg | Meister Hollweg | broken_choice | You have burned the only witnesses, Father. |
| h_kept.ogg | Meister Hollweg | broken_choice | I will find the fault. I will mend them, and show Rome they are mended. |
| f_kept.ogg | Father Ferrer | broken_choice | I wrote that down too. |
| f_won.ogg | Father Ferrer | won | I rode for Rome that morning with my report. |
| b_hurt.ogg | Brother Anselm | ferrer_hurt | The Father is hurt! Keep the muskets round him! |
| f_hhurt.ogg | Father Ferrer | hollweg_hurt | Meister Hollweg is hurt. Get men to him. |
| h_jakob.ogg | Meister Hollweg | jakob_dies | Jakob. Not him too. |
| m_intro.ogg | The Machine | intro_m | Tick. Tock. A priest walks in the guild's yard. Kill him. |
| m_tip.ogg | The Machine | intro_m | Your seed on the meadows pays cogs and Tension while it stands. At night, some of theirs will come to you. |
| m_night.ogg | The Machine | m_night | Night. By the river, the guild's machines are meshing. Soon they are yours. |
| m_riot.ogg | The Machine | m_riot | They are walking to you. Bring them home: 6 is enough. |
| f_end1.ogg | Father Ferrer | ending (visit) | I wrote my report on the road. I did not soften it. |
| f_end_melted.ogg | Father Ferrer | ending (visit) | The broken ones were melted. Hollweg did not speak to me again until Rome. |
| f_end_kept.ogg | Father Ferrer | ending (visit) | The broken ones were kept. Hollweg swore he would mend them. |
| f_end_lost.ogg | Father Ferrer | ending (visit) | And some of them reached the machine. I counted them in my report. |
| f_end_jakob.ogg | Father Ferrer | ending (visit) | Jakob found the stop-works and told me. He did not tell his master. I put that in too. |
| k_end1.ogg | The King | ending (visit) | Ferrer's report was on my table before the snow. I read it twice. |
| k_end_kept.ogg | The King | ending (visit) | Hollweg brought his mended machines to Rome, and I let him. That mistake was mine. |
| k_end_melted.ogg | The King | ending (visit) | Hollweg came to Rome with nothing but his drawings, and his anger. |

## What is placeholder

- Every line, every objective's words, the briefings and the debriefs.
- The stills (simple drawings).
- Ferrer is a Missionary (named), the lay brothers Missionaries, Hollweg a Missionary, Jakob a Labourer (the campaign
  roles' stand-ins). The gear ground nobody laid is a Regulator. The earthworks are the Crown's palisade.
- The voice folder a04 is empty (silent).

## Claude's choices for the owner

1. THE SIDES: the visit is one side, `visit` ("Father Ferrer's Visit"): Ferrer's party (PURPLE, the player), the guild
   (BLUE, the co-op friend) and THE WORKS (TEAL, scripted always: the automata that act by themselves). The works are a
   team of their own so the night Winder and the broken ones are never a friend's units (a co-op friend could otherwise
   walk them home) and are never shown as the guild's own in the selection.
2. THE GUILD IS THE CO-OP FRIEND (as the plan): so the K3 pieces (Heavy Works, Pendulum) are MADE only in co-op; solo,
   the guild's Pendulum stands at the yard's gate and Hollweg's lines say what it is for (the ladder doc's choice 2).
3. "UNSEEN" IS DISTANCE, NOT SIGHT. The engine's `seen` reads a SIDE's sight, and the guild and the works (same side)
   see the Winder all the time, so the follow is a band: keep within 8 tiles (else a brother tells where it went) and
   never closer than 3 (it stops, turns its head, and goes on only when you have backed off to 4 and 12 s have passed).
   Being seen costs time against the dawn, not the mission.
4. THE GEAR GROUND NOBODY LAID is a Regulator of the works' own (teal), not the machine's: a machine building next to the
   guild's automata would be fought over before the reveal (a disguise was tried: the moment it is unmasked the guild's
   Pendulum walks off its ground to it).
5. THE RIOT HAS TWO GROUPS: the bank (10) and the press-house's night shift by the Mainspring (5), one march. The plan
   names one group; the second one is the Pendulum's (it comes past the yard's gate) so the K3 piece has a job.
6. THE BROKEN ONES ARE WOUND TO 0.6 when they rise (the new `wind` action) and run down as they go: run down to
   nothing a construct stands still, and they would never have marched; at 0.6 they reach the meadows in about 40 s at
   about 0.9 of their pace.
7. THE MEADOW GATE IS A GAP (open for the carts): with a gate the converted ones would stop and hack at it; the gap keeps
   the riot a chase, and the machine's sortie meets them there.
8. LOST TO THE MACHINE is never a defeat: the count goes to the war map (4 or more: Franconia's red spreads east) and
   the ending. The flag is a tally whose bands are the numbers 0-30 themselves (`lost_to_machine` = the count), so the
   war map's rule as written (`flag_at_least ... 4`) reads it.
9. THE STOP-WORKS' CARRIER: Jakob tells the FATHER, not Hollweg (the plan): Hollweg is called away to the presses at the
   third workshop so Jakob can come. A new flag `stopworks` found / logged records which (for Rome).
10. THE TWO IN THE ESCAPEMENT (the winding pair) keep their stop-works and are stopped by Hollweg's key: so there are
    always broken ones in the yard for the choice, even if every rioter reached the machine.
11. DEFEATS: Ferrer killed, Hollweg killed, the dusk (the inspection unfinished: 10:00) and the dawn (nothing seen:
    7:00). Jakob is optional (his death is a line).
12. THE ESCORT: a02's `furth` strong 8 / thin 5 Musketeers (a02's own numbers: 10 or more men standing = strong), plus
    the line's gate men (4 + 3) on hold, so a thin escort still has the gap held.
13. DIFFICULTY: EASY / HARD scale the raced clocks (x1.25 / x0.85), the machine's garrison and sortie (x0.75 / x1.25)
    and the riot (EASY 10, NORMAL 15, HARD 19, by `if` entries: the broken ones are the visit side's own works, which
    the engine's spawns scaling never touches).
14. NO SOLO MIRROR: the machine's side here is a garrison and a wait for the night (the plan: versus only).
15. THE MAP STARTS FROM A02'S FILE (not from a02's script): the same cells by construction; a change to a02's map is
    picked up by running both scripts.
16. HOLLWEG FOLLOWS FERRER in Part 1 (scripted orders reach only units no person plays: in co-op the friend walks him,
    and Jakob, himself).

## Tests run

All on Godot 4.7, headless, one at a time (the campaign tests share user://campaign.json); 0 failures each:

- tools/test_campaign_a04.gd: 151 checks (the data and translations, the line and its gating, the seats for every mode,
  the map (a02's cells, autumn) and the stills, the K3 roster, the war map's data; each flag at the start: `furth`
  strong / thin / missing, Jakob lost in a02 or c01; the visit played through with c01's canon and a01 played: the six
  STAYs (9 s not enough, 10 s), the two signs, the Lyon type, Hollweg called away, Jakob's bin, the dusk clock stopped,
  the night, the works' gear ground, the Winder's three legs, the bank, the reveal (pattern), the riot's convert, the
  winding pair caged, the march, two counted on the machine's ground, the sortie, the riot over, the flag the count,
  MELTED, the win, the ending's lines, the progress; Jakob lost with the people: the journeyman's call, the plain
  pamphlets, the log in the barn, 17 broken, the reveal by a man at the gear ground, none lost, the choice unanswered:
  KEPT; the night Winder's rules: too far (the brother's word), too close (it stops, waits while you stand close, goes on
  with its leg when you back off), the dawn lost; the defeats (Ferrer, Hollweg, the passive dusk); VERSUS with the
  machine's seat a friend's: its objective, army, income, the rioters its own, six brought home win it, the progress
  follows; EASY / HARD: the garrison, the escort never scaled, the clocks, the riot's size, the sortie; the hubs after
  a04 by `broken`, Fürth and the King's study).
- tools/test_campaign.gd 125, test_campaign_a02.gd 139 (its "a02 leads nowhere yet" check now reads "a02 leads to
  a04"), test_campaign_c01.gd 243, test_war_map.gd 68 (a04 now built: locked until a02, open after a guild win; the
  rules by `broken` and `lost_to_machine` with the side `visit`), test_roster_ladder.gd 257 (K3 checked live: the guild
  refused exactly what is off its list), test_campaign_a01.gd 118, test_campaign_a03.gd 195, test_campaign_a06.gd 140,
  test_campaign_b01.gd 176, test_campaign_m1.gd 103, test_city_gen.gd 12, test_tutorial.gd 326.
- Boot: `godot --headless --quit-after 300`, no SCRIPT ERROR.
- tools/sim_campaign_a04.gd: the runs in "Balance".
- As before on this cloud machine every headless Godot run ends with "Aborted" (exit 134) AFTER its last line: the
  engine's shutdown here, not a test.
- `python3 tools/i18n_patch_build.py`: versions without translation: [].
- Not run: the faction and AI tests (no unit, price or skirmish rule changed: the `wind` action only acts inside a mission
  that asks for it). Not played on two devices (co-op, versus).
