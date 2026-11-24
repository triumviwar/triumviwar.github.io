# Act 2, "The Council of Gears": what was built (job d07-spring)

Act 2 build step (docs/campaign_act2_plan.md "d07_spring"): the Clockmaker line's third mission of Act 2, after
d04_concordia. Concórdia in 2777, four years after its founding: the free city of the guild on the southern highlands,
spilled down off the mine's hill into the valley head. Meister Hollweg tells it; the King frames it. The night the city's
machines turn, workshop by workshop, from the great spring on the mine hill outward. EVERY LINE OF TEXT IS A PLACEHOLDER
for the owner.

THE LORE KEPT: Hollweg is DECEIVED, not wicked: he calls the meshing "a fault in the winding" and the council "concord";
the King tells the truth of it ("That was the night it was lost"). The Church is right without preaching: the only voice
of Rome is the King's last line ("No machine may govern itself, Rome said"). LOCAL PEOPLE ARE MINOR: Matthias (Jakob's
son), Master Ortlieb (the council's chairman) and the three honest masters (Kessler, Brandl, Weiss) are small parts;
Hollweg carries the mission.

## Files

| what | where |
| --- | --- |
| the map | `campaign/maps/concordia_city.json`, written by `tools/campaign/make_concordia_city_map.py` (THE CITY GENERATOR, hills and stairs as Vila Rica's; `--ascii` prints it) |
| the mission | `campaign/missions/d07_spring.json`, written by `tools/campaign/make_d07_mission.py` (edit the script, run it; it imports the map's `build()` for the areas and lots) |
| the stills (stand-ins) | `campaign/stills/d07_01.jpg` .. `d07_05.jpg`, drawn by `tools/campaign/make_d07_stills.py`; the King's page reuses c01_01 |
| texts pt / es | `tools/i18n/campaign/d07_spring.txt` (written by the mission script; then `python3 tools/i18n_build.py`) |
| the storyline, the hubs | `campaign/campaign.json`: d07 joins the Clockmaker line after d04; d04's `next` is d07 for both sides (`tools/campaign/make_d04_mission.py`); the Clockmaker's hub after d07: A FISHERMAN'S HOUSE ON THE COAST (`spring` stopped), the council hall still (running), THE GREAT SPRING'S TOWER (the machine won); Hollweg's and the automaton's talks by `spring`; `campaign/hubs_grow.json` Ulrich's lines after d07 |
| the war map | `campaign/warmap.json` already had d07's pin and rules (act2-warmap: Concórdia red on the parchment and the chart at once with `spring` stopped, after d09 with running; never red on Hollweg's brass map; the honest masters' mark at the coast; ledger lines by `spring` and `honest`). Checked against the flags set here: they match (`tools/campaign/warmap_act2.py` only had its comment changed) |
| the roster ladder | `tools/campaign/roster_ladder.py`: K6 = d07 (TICKING OWL morph + HIGH LEAP; the Ticking Owl comes with them), bound team `guild`, NEW cards at 8 s, side `guild`, the cards in pt / es; docs/campaign_roster_ladder.md |
| the roles | `scripts/campaign/rebels.gd`: matthias (a Winder, Jakob's art, 220 hp), ortlieb, concordia_citizen, city_master (stand-ins) |
| the engine | two small additions (docs/campaign_engine.md "Added by Act 2's d07_spring") |
| tests | `tools/test_campaign_d07.gd` (`godot --headless --fixed-fps 30 --path . --script res://tools/test_campaign_d07.gd [-- only=data,flags,part1,part2,part3,defeat,mirror,save,ironman,hubs]`); `tools/test_war_map.gd` (d07 built: locked until d04; d08 still planned) |
| the balance sim | `tools/sim_campaign_d07.gd` (`-- active [diff=easy/hard] [saved=few/many] [jakob=lost] [gate=people] [broken=melted] [varenne=executed] [colonists=parley] [stop] [nomasters] [noleap] [until=s] [every=s] [save_at=s] [shots=dir] [debug]`) |
| voices | docs/chatterbox_todo.md "d07_spring" (58 lines with their feeling); tools/voice_clone/emotions.json `d07__<id>` |
| pictures | docs/shots/d07_spring/ (CHECK THE FEEL, below) |
| patch note | scripts/patch_notes.gd and tools/i18n/patch/notes.txt under 0.38.999 |

## The map: Concórdia on its mine hill (120 x 88, the HIGHLANDS biome, seed 2777, night then a grey dawn)

- THE MINE HILL (north-east, high ground): the upper town over the old mine, and on its crown THE GREAT SPRING in its
  tower (a Clocktower's 5 x 4) over the shaft, in a walled SPRING YARD. Two STAIRS go down: the WEST STAIR (to the north
  road) and the SOUTH STAIR (to the forge quarter). Its other edges are cliffs: with HIGH LEAP a Springer jumps up them
  where one of yours (an owl above) sees the top. The brake stands by the spring (area `brake`).
- THE NUREMBERG QUARTER (north-west, open ground): the honest masters' own works round their tower, laid out as
  Concórdia's first tower was in d04 (every ring meshes), the Nuremberg families' houses down its west side (3 / 4 / 5 by
  c01 `saved`) and, with a04 `broken` kept, the broken ones under their sheets in its yard.
- THE COUNCIL SQUARE (the middle): the COUNCIL HALL (a Town Hall's 5 x 4) on its north side.
- THE QUARTERS: the north road (between the Nuremberg quarter and the hill), the upper town, the forge quarter (east,
  under the hill), the mill quarter (south-east, by the stream), the market (south and south-west): house blocks with
  the city's NINE MESHED WORKS on lots (movement works, cog presses, an escapement, regulators) and the three honest
  masters' houses (Kessler at the forge, Brandl at the mill, Weiss at the market).
- THE STREAM along the south with two fords; the road to the valley leaves by the west ford (where Captain Arruda's
  colonists come up with d04 `colonists` parley).
- THE PLATES: the crates of 2767's gear ground (d04) lies under every street: the machine's units are kept fully wound on
  it; the honest masters' machines are kept to 85% (a Winder or the quarter's tower winds the rest).

## How it plays: THE HONEST MASTERS (Hollweg's guild; solo, versus p1)

PART 1, THE VOTE AND THE DOORS (day). A mid-match show: the council votes Master Ortlieb's motion (let the machines wind
one another); Matthias walks out with the Nuremberg men, Hollweg goes with them to prove them wrong. Then FIND THE
MESHING: four pinged workshop doors (north road press, forge works, mill press, market press); a man of ours standing
at each a few seconds finds the sign (narrated, counted) and that doorway's machines turn on him. Ulrich asks for THE
NIGHT WATCH at 22 s: research the TICKING OWL at the Clock Aviary and morph two Swifts (NEW). When all four are found
Hollweg calls it "a fault in the winding" and Matthias says "It is Nuremberg again". The thirteenth hour comes soon
after; nobody looking, it comes at 5:30 anyway.

PART 2, THE CITY TURNS (night). The tower strikes thirteen. The great spring's tower becomes the machine's, and the
hill's automata with it. THE TURNING: building by building, nearest the spring first, a red ring showing the next a few
seconds before (every 13-20 s by difficulty, 2 s sooner with c01 `gate` pattern); each meshed works turns with its
men, and each quarter that turns sends a wave against the council hall and our quarter. A turned works keeps sending
machines: the owls break it (their weights on buildings). BRING OUT THE HONEST MASTERS: a man of ours at a master's house
before his quarter turns brings him to our quarter; too late, he stays with his machines. HIGH LEAP is asked 30 s into
the night (research it at the Escapement). THE HALL: three of the machine's fighters at its door for 10 s with none of
ours (or the valley's) by it and it turns: LOST. The Nuremberg quarter's tower and its houses must stand. Arruda's
colonists come up the valley road and stand at the hall's door (d04 parley); Varenne or Citizen Morel says his piece (a06).

PART 3, THE GREAT SPRING (a grey dawn). The whole city is red but our quarter and the hall. The machine holds both
stairs (a Netter and a Springer at each top, two soldiers at each foot) and the spring yard. All its waves come back to
the foot of the west stair. NOON: the council sits again and votes the brake away (8:00, a countdown): reach the brake
first or LOST. Leap the cliff beside a stair with the Springers (an owl over the top), break the guards, bring Hollweg
to the brake (4 s). THE CHOICE, THE GREAT SPRING (60 s; the default and the canon RUNNING): Matthias begs him to pull it,
Varenne warns, Morel argues, Hollweg is proud. STOP IT: every machine in Concórdia stops (theirs and ours); the city is
dead brass, the honest masters and the Nuremberg families walk the coast road. LET IT RUN: the machine's men stand still
at noon, the council meets again, half its chairs empty, and Hollweg calls the city saved. Either way it is a WIN.

## How it plays: THE MACHINE IN THE CITY (the solo pick, or versus p2)

From the start a meshed company on the hill round the spring's tower; Part 2 comes after 1:00. The city turns to it by
itself, nearest the spring first, and ANY of the city's works it stands at for 5 s turns at once (its choice of order).
Win: turn THE COUNCIL HALL (three fighters at its door, none of the masters' men by it) or break the Nuremberg quarter's
tower, before dawn (10:00). Dawn with the hall and the quarter standing: LOST. The scripted honest masters hold the hall
and their quarter, and the three masters run for the quarter by themselves if their quarters still stand. A win sets
`spring` running and `honest` few: the canon's flags (compatible: the King says "It did not need to win that night");
the hub is THE GREAT SPRING'S TOWER and no seal breaks.

## The flags read and set

| read | from | what it does here |
| --- | --- | --- |
| `saved` | c01 | the Nuremberg families' houses in the quarter: few 3, some 4, many 5; Hollweg's line at the walk-out |
| `jakob` | c01 | Matthias's father: alive (taught him the signs at Fürth) or lost (died because nobody stopped the first one): his lines |
| `gate` | c01 | `pattern` (Hollweg kept the drawings): the turning comes 2 s sooner, the machine knows the city's pattern |
| `broken` | a04 | kept: the broken ones stand up under their sheets in the quarter's yard and go to the machine at the thirteenth hour; melted: nothing |
| `varenne` | a06 | spared: Varenne sits in the council (three lines); executed: Citizen Morel does (the Assembly's man, three lines) |
| `colonists` | d04 | parley: Captain Arruda keeps his word and brings his colonists up to the hall's door; fought: nobody comes up the road |
| missing | | the canon (saved some, Jakob alive, the people at the gate, the broken ones kept, Varenne spared, the parley) |

| set | values | when |
| --- | --- | --- |
| `spring` | `stopped` / `running` | the choice (the machine's win: running) |
| `honest` | `few` / `some` / `many` | the honest masters brought out (0 few, half some, 9 in 10 many, of 3); the machine's win: few |
| `honest_n` | 0..3 | the count itself |

## Hollweg's growth (the plan's line for this mission)

d04 built the city and he was proud of it. Here he is shown the pattern four times and calls it a fault; he hears the
thirteenth hour he cut from the dial himself; he holds the hall and saves what he can; at the brake he hesitates. If he
pulls it, "It was the first thing he ever stopped", the King says: the road to the King's palace. If he lets it run he
calls the city saved and the King calls it lost. Nothing in his lines says he knows better yet: the deception stays.

## Balance (tools/sim_campaign_d07.gd; the last runs)

The bot finds the doors with small groups, makes two owls, sends men to the masters' houses, holds the hall and the
quarter, researches HIGH LEAP, rallies at the foot of the west stair at dawn, leaps the cliff, takes Hollweg to the brake.

| run | result |
| --- | --- |
| NORMAL active (the canon) | WON at 6:40-7:15 (spring running, honest many) |
| EASY active | WON at 7:11 |
| HARD active | WON at 6:29 |
| active stop | WON, spring stopped |
| saved few / jakob lost / broken melted | WON |
| colonists parley + varenne executed + gate people | WON (the valley came up) |
| save_at=200 (saved half way, loaded) | LOAD SAME, WON |
| nomasters + noleap | WON, honest few (the stairs fought up the hard way) |
| passive (nobody plays) | LOST: the hall turns at about 7:00 |
| NO WAITING | the longest idle stretch 14-17 s in every run |

## Pictures (docs/shots/d07_spring/, CHECK THE FEEL)

Eleven pictures from `xvfb-run ... sim_campaign_d07.gd -- active shots=docs/shots/d07_spring` (1280 x 720; the sim
draws only for the pictures, `RenderingServer.render_loop_enabled`, because the software renderer was far too slow):
1 start (0:06, Matthias says what to do, the guild at the camp), 2 find (0:24, Ulrich: four small groups go faster),
3 thirteen (0:58, the NEW HIGH LEAP card over the quarter), 4 master (1:08, a Winder winds another at the north road's
press), 5 turning (1:56, the mill's plates turn with nobody on them), 6 hall (2:46, Ulrich: the red ring; the base under
attack), 7 dawn (4:39, a rescued master: "Thank God"), 8 leap (5:23, grey dawn, the whole city red), 9 brake (6:39,
Hollweg's hands on the brake), 10 won (6:46, "If I pull it, everything stops"), 11 owls (1:56, a Ticking Owl ready; from
the run before, same seed).
What they show: the night lighting and the red-lamped streets read well; the scale of the hill and the yard is right.
Rough: the objectives list is long in Part 2 (seven lines) and covers much of the left; the dialogue box covers the top
middle as in every mission. Both are the HUD's, not this mission's.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

The stand-ins are drawn in code. Oil painting in the style of the other campaign stills (18th-century, warm lamplight,
the Clockwork brass and red, the guild's blue).

1. d07_01 THE COUNCIL OF GEARS: "An oil painting in an 18th-century style: the council hall of a small new city of
   clockmakers, timber and brass, lamplight. Craftsmen in blue coats sit on benches; at each one's shoulder stands a
   small brass automaton. An old clockmaker with a white beard presides from a raised chair under a great brass gear on
   the wall. A lean young craftsman stands, pointing at the automata, angry. Warm, quiet, uneasy."
2. d07_02 THE STREETS TURN: "An oil painting: night in a town of brass houses on a hill; along a street the lamps go red
   one after another. In a doorway, two clockwork figures wind each other with keys. A young craftsman with a lantern
   watches from a corner, afraid. Cold blue night, red lamps."
3. d07_03 THE GREAT SPRING: "An oil painting: inside a tall stone tower a huge coiled brass spring fills the space,
   humming. An old clockmaker with a white beard grips a great iron brake lever with both hands, hesitating. Behind him
   craftsmen in blue coats shout at him. Grey dawn light through a high window."
4. d07_04 THE COAST ROAD: "An oil painting: families in blue coats and two carts loaded with tools walk a road beside a
   grey sea. Behind them, on green highlands with tall Paraná pines, a silent city of brass with a tower; no lamp lit,
   no smoke. Overcast, sad, a long road."
5. d07_05 THE RED DAWN: "An oil painting: a small city of brass on a hill over an old mine, at a grey dawn; every lamp in
   the city burns red; a tall tower over the mine holds a great spring. Not one person in the streets. Still, cold,
   ominous."

## The voice lines

58 spoken lines (+30 narrator lines that can stay as text, 2 NEW cards): Hollweg 22, Matthias 12, Ulrich 8, the King
7, Varenne 3, Citizen Morel 3, Master Ortlieb 1, a rescued master 1, Captain Arruda 1. Every line with its feeling is in
docs/chatterbox_todo.md "d07_spring"; 12 presets in tools/voice_clone/emotions.json (`d07__<id>`). New voices to design:
Matthias (about twenty, Franconian, earnest and sharp; Jakob's voice made younger would do) and Master Ortlieb (one line).

## What is placeholder

Every line, every objective text, the masters' names (Ortlieb, Kessler, Brandl, Weiss), the hub texts, the five stills
(drawn in code), the roles' art (Matthias wears Jakob's), the voice lines (none recorded).

## Claude's choices for the owner

1. THE NUREMBERG QUARTER IS NORTH-WEST, not under the hill: on open low ground, as far from the spring as the map
   allows, so the turning reaches it last and the night has a front line.
2. THE PLATES WIND: the machine's men are kept fully wound on the plated streets; the honest masters' machines only to
   85% (the plates are theirs too, but the machine is in them). Without that the guild ran down and could not hold.
3. THE HALL TURNS ONLY TO FIGHTERS: three of the machine's fighters (not Winders) at its door for 10 s, nobody of ours
   or the valley's in the hall's yard. Winders alone were turning it by walking past.
4. THE TURNING'S PACE by difficulty: a building every 20 / 16 / 13 s (EASY / NORMAL / HARD), 2 s sooner with c01 `gate`
   pattern; a red ring 8 s before.
5. THE MASTERS' NAMES: Matthias (Jakob's son, the plan's), Master Ortlieb (the council's chair), Kessler (forge), Brandl
   (mill), Weiss (market). All German, as the guild's.
6. MATTHIAS IS A WINDER (220 hp, Jakob's art for now), wounded not killed (a story hero).
7. NOON IS A FAILSAFE: in Part 3 the council sits at noon (8:00 after dawn) and votes the brake away: reaching the brake
   after that is LOST. It keeps Part 3 from stalling; the bot reaches the brake with 4-6 minutes left.
8. AT DAWN THE MACHINE RECALLS ALL ITS WAVES to the foot of the west stair and stops sending; the hall's rule is off in
   Part 3 (the hall held the night: done). Otherwise the quarter fell while the column was up the hill.
9. THE CHOICE IS A WIN EITHER WAY; running is the default and the canon (the plan's). The machine's mirror win sets
   `spring` running and `honest` few, so it fits the canon: no broken seal, and the King's line says it lost nothing by
   waiting ("It had all the nights it wanted").
10. THE MIRROR TURNS BUILDINGS BY STANDING: the machine played by a person chooses the order (5 s at any works), on top
    of the city turning by itself; its win is the hall or the quarter's tower before dawn (10:00).
11. THE VALLEY'S HELP comes only with d04 `colonists` parley: Arruda and his men stand at the hall's door from the
    thirteenth hour. Fought: nobody comes.
12. THE BROKEN ONES (a04 kept) stand up under their sheets in the quarter's yard and go over to the machine at the
    thirteenth hour: a fight inside our own quarter. Melted: they are not there.
13. VARENNE OR MOREL sits in the council by a06 (spared / executed), three lines each, as d04 had them.
14. THE TENSION AT THE START is 400 against a cap of 200: what the K6 research costs (the Ticking Owl 150, two morphs
    100, HIGH LEAP 100), given at once so the player is not left waiting on Mainsprings at night. The bar shows 400/200
    until it is spent.
15. HIGH LEAP is asked 30 s into the night (with Part 3's cliff in mind), the TICKING OWL 22 s into Part 1.
16. TWO SMALL ENGINE ADDITIONS (docs/campaign_engine.md): `wind` by team or side; hub `after` keys "<mission>@<name>"
    so one mission can lead to two different hub rooms by a flag.
17. CONCÓRDIA'S NEW MAP: the d04 map (the founding on the dead mine) was a camp; four years on the city needed the city
    generator, so d07 has its own map, `concordia_city`, with d04's tower layout moved into the Nuremberg quarter.

## What is left

- The owner's lines, the stills, the voices.
- Roles' own art for Matthias, Ortlieb, the masters and the citizens.
- The HUD's objectives list grows long in Part 2 (a general HUD question, not this mission's).

## Tests run

- tools/test_campaign_d07.gd: data, every text in pt / es, the flags at the start, Parts 1-3, defeat, the mirror, SAVE /
  LOAD in Part 2, IRONMAN, the hubs and the war map after d07: all pass.
- Every tools/test_campaign_*.gd (a01-a07, b01, c01, d01-d07, heroes, ironman, m1, save), tools/test_war_map.gd and
  tools/test_roster_ladder.gd: 0 failures, except test_campaign_m1's "no recording yet for Tomasz" check, which fails on
  main too (campaign/voice/p01/t_open3.ogg has been recorded since; the check is stale, left for the owner's call).
- test_campaign_a07's "the clockmaker line reaches Rome" check failed on main (d04 did not list a07_council in its
  `needs`): d04 and d07 now list it, as d01 / d03 / d05 / d06 do.
- The game boots with no script error.
- `python3 tools/i18n_patch_build.py` prints [].
