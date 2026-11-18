# Act 1, "The Fürth Line": what was built (job a02-furth, 0.38.53)

Act 1's first mission (docs/campaign_act1_plan.md, "a02_furth", built as its OWNER ANSWERS say: the guild in exile at
Fürth holding the line for the Crown against the Machine; a SOLO MIRROR where the player can lead the Machine; Hollweg
tells it from his exile and the King frames it; EASY / NORMAL / HARD). It is the Clockmaker line's second mission, open
when the guild has won The Thirteenth Hour, and the first mission that reads a prologue's flags from another mission: it
proves the CARRY (c01's five flags change the start and the parts) and the SOLO SIDE PICK.

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite (kept short and plain on purpose). The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/a02_furth.json`, written by `tools/campaign/make_a02_mission.py` (edit the script, run it) |
| the map | `campaign/maps/furth_line.json` (`campaign:furth_line`), written by `tools/campaign/make_furth_map.py`; opens in the MAP EDITOR |
| the stills (stand-ins) | `campaign/stills/a02_01.jpg` .. `a02_05.jpg`, drawn by `tools/campaign/make_a02_stills.py`; the King's pages reuse `c01_01` |
| texts pt / es | `tools/i18n/campaign/a02_furth.txt` (then `python3 tools/i18n_build.py`); texts c01 already has are not repeated |
| the storyline, the hub | `campaign/campaign.json` ("clockmaker": missions c01, a02; the hub at Fürth; the Machine's City by side) |
| c01's way on | `tools/campaign/make_c01_mission.py`: `"next": {"guild": "a02_furth"}` (a machine win in c01 leads nowhere) |
| the engine | `scripts/campaign/mission_run.gd` (count `"built"`), `campaign.gd` (the record keeps the side), `campaign_menu.gd` (the hub by side) |
| test | `tools/test_campaign_a02.gd` (`godot --headless --fixed-fps 30 --script res://tools/test_campaign_a02.gd`) |
| balance | `tools/sim_campaign_a02.gd` (`-- active side=guild|machine bells=... saved=... jakob=... cut=... gate=... diff=... none`) |

## The map: Fürth and the road to Nuremberg (128 x 80, the snow biome, March: the snow melting)

The PEGNITZ comes out of Nuremberg (east edge) and runs west to Fürth; the REDNITZ comes in from the south-east and the
two make the REGNITZ, which flows north past Fürth's west side (the woods beyond it are scenery). Fords: Fürth's own
bridge over the Pegnitz, and the old bridge by Nuremberg's walls (where the machine crosses from bank to bank).

- FÜRTH (west): the old town's houses and church on the north bank, the guild's yard between them with THE HONEST ONE
  (the guild's Clocktower, the standard start at [44, 16]), the Crown's tents in the north, the refugees' tents on the
  south bank in the angle of the two rivers.
- THE LINE: the Crown's earthworks, palisades (team `army`, tag `earthworks`) at x = 58 from the woods in the north to
  the Pegnitz, and from the Pegnitz to the Rednitz, with two GATES: the ROAD GATE (north bank) and the MEADOW GATE
  (south bank). The stretches next to the gates stand at the start; the army digs the north bank's at 0:50 and the
  south bank's at 1:50 (the `build` action, one stake a cell).
- THE WATER MEADOWS between the rivers, open and wet, THE REDNITZ MILL half way (a windmill prop: the Part 3 seed is the
  mission's), a farm on the north road.
- NUREMBERG (east edge): its walls and red towers, unwalkable, with two gates; the machine's two SEEDS (Clocktowers,
  spared: nothing at Fürth can touch the city) stand outside them, and two Regulators (its LINKS) on the road and the
  meadows.

## How it plays: THE GUILD (the default side; solo, co-op with the Franconian army, versus against the Machine)

Opening (the King in Rome, then Hollweg): the Machine kept Nuremberg through the winter; the guild went to Fürth; the
Honest One; "every machine it made would have a stop-work. I swore it."

- PART 1, THE HONEST ONE. The guild (BLUE): the Honest One with its presses and Winders, 4 Clock Soldiers and a Netter,
  400 cogs, MEISTER HOLLWEG in the town (north), JAKOB if he got out. The Franconian army (PURPLE, scripted; the friend in
  co-op): COLONEL VON RAUCH and 10 Musketeers at the two gates. No flyers, Serpent, Great Winder or Ballista; the Heavy
  Works and the Pendulum not yet. Objectives: FIT THE STOP-WORK (Hollweg stays by the Honest One for 25 seconds: a STAY),
  BUILD A LIGHT WORKS (done when one stands finished), Hollweg must live, the Honest One must stand (Jakob must live,
  optional). The stop-work fitted: the bell, a flag `stopwork`, and (quiet bells) the commissary's leave to build.
- PART 2, THE SORTIE (15 s after both are done, or at 7:00 whatever happened). "Hold the earthworks: n of 3 sorties
  beaten back." A sortie every 2 minutes, the first a minute in: 1) 5 Clock Soldiers and a Springer over the meadows,
  2) 6 Clock Soldiers, a Springer and a Netter on the north road (the meadows if c01's links were cut), 3) on both banks
  (5 + 1 on the meadows, 4 + 1 on the road), or all of it on the meadows (8 + 2) if the links were cut. Jakob hears each
  sortie's ticking 12 s before it comes. They go for the gate on their bank, then on at the Honest One; those stopped at
  the palisade break it (the stake nearest them); through the line they go for the Honest One and Hollweg. Hollweg's tip:
  off the Honest One's ground the guild's soldiers run down as the machine's do: Winders with them (the game's own rule:
  70% damage, 75% speed when run down).
- PART 3, THE MILL (6 s after the third sortie is beaten, or 3:20 after it set out). Dusk; the machine seeds the
  Rednitz mill (a Clocktower, 6 Clock Soldiers and 2 Springers on guard), and while it stands it sends 2 Clock Soldiers
  every 40 s at the meadow gate (and the south gate's seed 2 every 60 s), never more than 30 machines. The colonel's
  reserve (4 Musketeers) comes down. "Burn the machine's seed at the Rednitz mill." With c01's drawings (`gate` pattern)
  the Heavy Works and the Pendulum open now; built from memory (`gate` people) four more of the people's Winders instead.
- THE WIN: the mill burns, night falls, "Safe this time." Ten seconds later THE LINE HOLDS (a real win: the Clockwork
  line needs one after its loss). The Franconian army's men still standing make the flag `furth` (10 or more: strong;
  fewer: thin). The ending's stills: Hollweg's lines by the flags, then the King: "He believes it. I believe he believes
  it. A stop-work is a wheel like any other. A wheel can be taken out."
- THE DEFEATS (retry): Hollweg killed, or the Honest One burnt.

## How it plays: THE MACHINE (the solo side pick, YOU PLAY: THE MACHINE; or the friend in versus)

No narrator (the machine has no voice: c01): the King's two lines in the opening, objectives and its tick.

- The machine (RED) by Nuremberg's gates: 12 Clock Soldiers, 2 Springers and 3 Winders, a Light Works by the south gate,
  500 cogs and 200 Tension. No Cog Presses or Mainspring: its income is THE SEEDS' TIMETABLE (130 cogs and 30 Tension
  every 30 s while its seeds stand, and a free Clock Soldier out of each gate every minute). Off its ground its
  constructs run down, so the Regulators (10 supply each) are also how it carries its ground west.
- "Fürth's line is finished in 18:00" (the raced countdown) and "Burn the Honest One or kill Meister Hollweg before the
  line is finished." At 6:00 it seeds the Rednitz mill by itself (a forward ground, 70 cogs more every 30 s while it
  stands; "keep the seed", optional). The guild is scripted: its Light Works stands at once, 6 Clock Soldiers, 3
  Springers and 2 Netters hold inside the gates, 2 more Clock Soldiers every 70 s while the Honest One stands, and at
  10:00 a strike of 8 Clock Soldiers and 2 Springers at the mill seed. The Franconian army holds the line as in the
  guild's game, and the army digs it on the same timetable.
- THE WIN: the Honest One burnt or Hollweg killed (the flag `furth` fallen). The machine's ending is the King's own:
  "That is not how it went. The line held at Fürth. But it could have gone that way."
- THE LOSS: the countdown out.
- A machine win counts for its player: the progress keeps `"side": "machine"`, and the Clockmaker hub stays NUREMBERG,
  THE MACHINE'S CITY for him.

## The prologue's flags (c01_thirteenth) and what they change

A flag that is missing (c01 not in the progress: a test, an old save) reads as c01's defaults: the bells quiet, some
saved, Jakob alive, the links not cut, the pattern taken.

| c01 flag | value | a02 |
| --- | --- | --- |
| `bells` | rung | 16 Musketeers and 2 Field Cannons at the line (not 10, none); the Light Works allowed at once; 200 cogs more; the colonel thanks the guild |
| | quiet | a Crown COMMISSARY at the Honest One (Ferrer's letter got there first): no Light Works until the stop-work is fitted |
| `saved` | few / some / many | Fürth's refugee cottages 0 / 2 / 4 and labourers on the earthworks 0 / 4 / 8; with many, the LOYAL QUARTER's signal 20 s before the first sortie: a lamp in Nuremberg, both gates revealed for 40 s |
| `jakob` | alive | Jakob at Fürth ("Jakob must live", optional); he hears each sortie coming; the ending's line about his log |
| | lost | no Jakob, no warnings |
| `cut` | yes | the sorties keep to the south bank (the road is silent: "we cut its links last winter") |
| | no | the second sortie on the north road, the third on both banks |
| `gate` | pattern | the Heavy Works and the Pendulum open in Part 3 ("I have my drawings") |
| | people | no Heavy Works; four more Winders in Part 3 ("only our hands") |

Flags it SETS (kept when won): `stopwork` fitted, `furth` strong / thin (the guild's win, with `furth_n` the men
standing) or fallen (the machine's win), `jakob` alive / lost. For a04 (Ferrer's visit): `furth` is the escort the plan
names; `jakob` carries c01's on (alive only if he got out of Nuremberg and lived through Fürth).

## The engine (small; docs/campaign_engine.md "Added by Act 1's a02_furth")

- condition `count` with `"buildings": true, "built": true`: only finished buildings (the Light Works, whoever's machine
  runs the mission: the tutorial's `built` reads only this machine's player).
- `Campaign.record` keeps `"side"`: the side this player led when the mission counted.
- the hub by side: an `"after"` entry, a hotspot or a talk entry may carry `"sides": {"<mission>": side}` (that mission
  finished with this player on that side) and `"not_sides"` (CampaignMenu.sides_ok).
- Everything else was already there: `if` on units and buildings (the flags), `solo_sides` and `control` "foe", the
  STAY (a `reach` objective with `secs`), `difficulty`, `playing`, the `spare`, `deny` / `unlock`, `hunt`, counters,
  clocks, `tally`, the winter lights and snow, the `hollweg` / `jakob` / `citizen` roles, endings and openings per side.

## The hub (owner answer 2)

After The Thirteenth Hour the Clockmaker's hub is THE GUILD IN EXILE AT FÜRTH (a barn workshop; until the owner's
painting comes, the Nuremberg workshop painting with Hollweg in it, tinted cold: `"tint": [0.84, 0.86, 0.94]`): Hollweg
there with new lines (and new ones after a02), the guild's travelling clock, a new automaton with a STOP-WORK FITTED
plate. A player who won The Fürth Line as the Machine gets NUREMBERG, THE MACHINE'S CITY (the c01 hub after the fall:
Hollweg gone, his letter, red tint, the clock that strikes thirteen). The tests of c01 follow (its hub check now reads
Fürth after c01 and the Machine's City after a02 as the Machine).

## Balance (tools/sim_campaign_a02.gd, NORMAL)

The guild's bot: Hollweg to the tower, then back to the town; a Light Works, Regulators, a second Light Works, a
Mainspring and (when open) the Heavy Works; Clock Soldiers and Springers; the army at the gate the machine is coming at
(a quarter at the other), everything at any machine through the line; in Part 3 everything but three at the mill seed.
The machine's bot: Light Works and Regulators by the south gate, Clock Soldiers and Springers, the army gathered on the
meadows until 22 strong (or 10:00), then the palisade nearest it and on at the Honest One.

BALANCE_TABLE

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

House style as the prologues (campaign/stills/p01_*.jpg, c01_*.jpg): an oil painting in the manner of an 18th-century
history painting, visible brushwork, 3:2 landscape (cut to 1280 x 853), no text or lettering anywhere. The Crown's men in
PURPLE coats; the guild's machines brass with BLUE enamel; the runaway machines brass with RED enamel. References: p01_05
(the style); where Hollweg appears campaign/hub/nuremberg_hollweg.png (grey curly hair, moustache, leather apron,
red-brown coat). Save each as `art/campaign/stills/a02_0N.png` and cut it to 1280 x 853 into
`campaign/stills/a02_0N.jpg` (nothing else changes). The King's pages reuse c01_01 (the King listening in Rome).

- a02_01 THE GUILD IN EXILE. "Oil painting, 18th-century history painting style. Early spring, a big timber barn turned
  into a clockmaker's workshop: a great brass map of the world made of engraved turning rings on a trestle table, tools,
  half-built small brass machines with blue enamel plates. An old clockmaker with grey curly hair and a moustache, in a
  leather apron and a red-brown coat, stands by the open barn door with a young apprentice; through the door, across
  snowy fields, the red towers and walls of a lost German city on the horizon. Warm lamplight inside, cold light
  outside. 3:2 landscape, no text." (References: nuremberg_hollweg.png, p01_05.)
- a02_02 THE HONEST ONE. "Oil painting, 18th-century history painting style. A muddy yard with melting snow beside a
  small German town of half-timbered houses: a tall new brass clock tower machine with blue enamel plates and great
  gears at its base. An old clockmaker with grey curly hair on a ladder against it fits a small bright brass part into
  its works with his own hands. Below, an officer of the Crown in a purple coat with a notebook watches him, unsmiling,
  and soldiers in purple dig an earthwork in the background. Cold morning light. 3:2 landscape, no text."
  (References: nuremberg_hollweg.png, p01_05.)
- a02_03 THE SORTIE. "Oil painting, 18th-century history painting style. Wet water meadows by a river in early spring,
  grey sky: from the open gate of a walled city with red towers on the right, a tide of small brass clockwork soldiers
  with RED enamel plates pours across the meadows toward the viewer. On the left, behind a raw earthwork with a wooden
  palisade, a line of musketeers in purple coats levels its muskets, and small brass soldiers with BLUE enamel plates
  stand with them. Smoke, mud, puddles reflecting the sky. 3:2 landscape, no text." (Reference: p01_05.)
- a02_04 THE REDNITZ MILL. "Oil painting, 18th-century history painting style. Dusk by a small river: an old windmill
  overgrown by a sprawling network of brass gears with RED enamel, meshed over its walls and sails, turning, and a
  small red-plated clock tower grown out of its side. The first flames catch at its base. Small brass soldiers with
  BLUE plates and musketeers in purple coats advance on it from the left, torches raised. Orange firelight against a
  violet sky. 3:2 landscape, no text." (Reference: p01_05.)
- a02_05 THE LINE HOLDS. "Oil painting, 18th-century history painting style. Dawn over an earthwork with a wooden
  palisade: tired musketeers in purple coats rest on it, a small brass machine with a BLUE plate stands still beside
  them. In the foreground, seen from behind, an old clockmaker with grey curly hair in a red-brown coat looks east
  across the meadows at the red towers of a walled city on the horizon, a thin smoke still rising from a burnt mill.
  Pale pink light. 3:2 landscape, no text." (References: nuremberg_hollweg.png, p01_05.)

## The voice lines (for the owner's Chatterbox recordings)

Recorded lines go in `campaign/voice/a02/<line id>.ogg` (or .wav / .mp3); the game plays them when present
(CampaignVoice). The King's in the King's voice (tools/voice_clone, refs king_ref.wav). MEISTER HOLLWEG and JAKOB as
designed for c01 (still to design); COLONEL VON RAUCH and THE COMMISSARY need designed voices first (a 10-20 s sample
each, ElevenLabs only to design, then Chatterbox). "Fürth" (the narrator) and "The Machine" (machine side only) can stay
text, or the off-beat tick.

VOICE_TABLE

## What is placeholder

- Every line, every objective's words, the briefings and the debriefs.
- The stills (simple drawings), and the hub painting (the Nuremberg workshop, tinted).
- Colonel von Rauch and the Commissary are a Dismounted Officer (named); Hollweg a Missionary, Jakob and the refugees
  Labourers (the campaign roles' stand-ins, as in c01). The earthworks are the Crown's palisade; the mill a windmill.
- The voice folder a02 is empty (silent).

## Claude's choices for the owner

1. THE HONEST ONE STANDS AT THE START (the standard start), and Part 1 is fitting its stop-work and building the works:
   a Clocktower raised by hand would be a long wait for nothing; the plan's "raise the new Clocktower" is the opening's
   still and line instead.
2. THE STOP-WORK IS A STORY BEAT: Hollweg stays 25 s by the tower (a STAY); nothing in the rules changes (the guild's
   units are blue and stay blue).
3. QUIET BELLS LOCK THE LIGHT WORKS until the stop-work is fitted (the plan's "the guild's roster tighter until Part
   2"): it only orders Part 1 (stop-work first). Rung bells give 200 cogs more as well as the bigger army.
4. THE LINE IS THE CROWN'S PALISADE, dug in three stages on a timetable (not by labourers: scripted building is
   reliable, sites with scripted workers are not); the refugees' labourers stand on it as the people's hands (`saved`).
5. THE MACHINE IS SCRIPTED (as c01): the sorties, the seeds and the mill are triggers; the gate seeds are SPARED (the
   city can't be taken in 1768). Machines stopped at the palisade break it (a `hunt` for the stakes within 3 tiles every
   12 s), and through the line hunt the Honest One (11 tiles) and Hollweg (6 tiles): without that, a passive player's
   line would stand for ever with the machine idle behind it.
6. THE MIRROR'S GUILD IS SCRIPTED (defenders on hold, reinforcements, one strike at the mill), not the Clockwork
   computer: the skirmish computer plans for a whole map and would march on Nuremberg; a scripted guild keeps the
   machine player's race against the line the same every time.
7. THE MACHINE'S INCOME IS THE TIMETABLE (cogs, Tension, free constructs), its presses and Mainspring denied: the plan's
   "the seeds' timetable as income". 18:00 on NORMAL (22:30 EASY, 16:12 HARD).
8. A MACHINE WIN COUNTS (the progress keeps the side, `furth` fallen) and its ending is the King saying it did not
   happen that way; it leads nowhere (`next` empty both ways until a04). A reclaim mission is the plan's answer for a
   lost battle, not built.
9. THE ARMY'S STRENGTH (`furth`) counts the Franconian army's men standing at the win, the colonel's reserve included:
   10 or more strong, fewer thin.
10. THE GUILD'S SOLDIERS RUN DOWN at the line as the machine's do (the line is beyond the Honest One's ground):
    Hollweg's tip says Winders go with them. This is the game's rule, not changed for the mission.
11. Jakob's flag after a02 is `alive` only if he was at Fürth and lived; c01's `lost` stays lost.
12. Co-op: the friend commands the Franconian army (purple). Versus: the friend is the Machine with its own objectives
    and countdown; the guild's Part 2 sorties are then the friend's own units (as c01's versus). Neither was played on
    two devices.

## Tests run

TESTS_RUN
