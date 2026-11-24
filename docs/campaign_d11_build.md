# Act 2, "The Siege of Concórdia": what was built (job d11-siege)

Act 2 build step 13, the second half (docs/campaign_act2_plan.md "d11_siege"): the crossing's branch against the
machines. In 2780 the army's southern column climbs to the southern highlands and lays siege to the city of gears.
Father Ferrer comes with it as Rome's witness, an old man now, and Jakob comes with him and listens to the city ticking.
Ferrer tells it, in his report to Rome (the owner's answer to question 3); the King frames it.

The mission comes in TWO VERSIONS, picked by the crossing's choice in d09:

- FRESH (d09 `first` = clockwork: the city was fought first). The wall is not finished: two stretches are only
  scaffolding. The city's army is out on the roads, so its garrison is small. A true siege: the pioneers go down the old
  mine under the wall and blow the great spring's tower from beneath. The city is crippled, not taken: `siege` close.
- GROWN (d09 `first` = brood: the city waited a year while the army was in the jungle). The wall is finished, a Spring
  Ballista stands behind every gate, owls fly over the camp. The galleries under the wall are the city's now. The Crown
  can only hold the road: it holds the camp against the great sortie until dusk. `siege` held_off.

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite.

The rules it keeps. WORLD LORE: Hollweg is deceived, not wicked. On his wall he "listens to the city"; with the spring
stopped he comes with the Crown as a prisoner who asked to come, shows the old shaft, and asks Ferrer to hear his
confession. Nobody gives the machines a will: the city "runs", "turns", "comes out"; nobody in its council will say who
gives the orders. The Crown and the Church are the good side: Ferrer writes only what he saw, and says plainly "We had
not come to take it. We had come to stop it." LOCAL PEOPLE ARE MINOR: Captain Arruda has two lines, Matthias one. THE
BROOD IS NOT A PERSON: no creature appears; the jungle front is one line of Ferrer's.

## Files

| what | where |
| --- | --- |
| the map | `campaign/maps/concordia_siege.json`, written by `tools/campaign/make_concordia_siege_map.py` (it imports d07's map script and moves its city east; `--ascii` prints it) |
| the mission | `campaign/missions/d11_siege.json`, written by `tools/campaign/make_d11_mission.py` (edit the script, run it; it imports the map's `build()` for the areas, the lots and the wall's openings) |
| the stills (stand-ins) | `campaign/stills/d11_01.jpg` .. `d11_03.jpg`, drawn by `tools/campaign/make_d11_stills.py`; the King's pages reuse p01_01 |
| texts pt / es | `tools/i18n/campaign/d11_siege.txt` (written by the mission script; then `python3 tools/i18n_build.py`) |
| the storylines | `campaign/campaign.json`: d11 after d09 on all three lines (as d09 is the last of all three) |
| the hubs | the King's study: the King's talk and Ruggieri's dispatch after d11 by `siege`; the Clockmaker's hub: Hollweg after d11 (on his wall; with d07 `spring` stopped, his confession) |
| the war map | `tools/campaign/warmap_act2.py` (run it: it writes `campaign/warmap.json`): d11's rules were already planned (`siege` close = Concórdia besieged with the siege ring, held_off = the machine's and the valley contested, Jakob's line in the ledger); added: the city's win breaks the seal |
| the roster ladder | `tools/campaign/roster_ladder.py`: C9 = d11 (PREPARED CHARGES + the GUNNER'S QUADRANT), bound team `column`; K7 = d11 too (SPRING BALLISTA + LONG CHAIN), bound team `city` (a mission's second rung: `BOUND_MORE`); the cards in pt / es; docs/campaign_roster_ladder.md (the C9 and K7 rows) |
| the roles | `scripts/campaign/rebels.gd`: ferrer_siege, jakob_siege, pioneer, hollweg_prisoner, hollweg_walls (new keys) |
| the engine | a conditional need (`"needs": [..., {"id", "if"}]`: THE DIAMOND's lock) in `scripts/campaign/campaign.gd`; docs/campaign_engine.md "Added by Act 2's d11_siege" |
| tests | `tools/test_campaign_d11.gd` (`godot --headless --fixed-fps 30 --path . --script res://tools/test_campaign_d11.gd [-- only=data,flags,part1,part2,fresh,grown,defeat,city,save,ironman,hubs]`); `tools/test_roster_ladder.gd` (two rungs in one mission); `tools/test_war_map.gd` (d11 built) |
| the balance sim | `tools/sim_campaign_d11.gd` (`-- active [lazy] [diff=easy/hard] [first=brood/clockwork] [jakob=lost] [stopworks=logged] [spring=stopped] [colonists=fought] [until=s] [save_at=s] [shots=dir]`) |
| voices | docs/chatterbox_todo.md "d11_siege" (47 spoken lines with their feeling); tools/voice_clone/emotions.json `d11__<id>` |
| pictures | docs/shots/d11_siege/ (CHECK THE FEEL, below) |
| patch note | scripts/patch_notes.gd and tools/i18n/patch/notes.txt under 0.38.999 |

## The map: Concórdia and its siege (176 x 96, the HIGHLANDS biome, seed 2780)

d07's city, the same quarters, moved east, with a wall along its west side facing the plateau.

- THE CAMP (west): the column's depot (the camp's Barracks, Armoury in the north, the siege train's Foundry in the
  south, the horse lines, the column's tents) and THE SIEGE PARK's magazine (a Powder Mill: it must stand). In the camp's
  north, THE OLD MINE'S MOUTH: an adit of the dead mine, with spoil and an old headframe. Its galleries run east under the
  wall to the great spring's tower.
- THE SIEGE LINES: open ground between the camp and the wall, with three battery sites facing the three gates.
- THE WALL: timber on rock footings. Three GATES (north, west, south: the city's gates, three pieces each), two
  UNFINISHED STRETCHES (scaffolding in FRESH, finished wall in GROWN) and a POSTERN by the old Nuremberg quarter.
- THE CITY: d07's town. The old Nuremberg quarter, just inside the wall, is the city's ARSENAL now (d07's meshed layout:
  a tower, the Escapement, the Light and Heavy Works, the Mainspring, the Aviary, a press, regulators). The council
  square in the middle, the quarters with their works, THE MINE HILL with THE GREAT SPRING in its yard.
- THE STREAM along the south, out of the city and on under the camp's south edge: there is no way round the wall.

## How it plays: THE SOUTHERN COLUMN (solo; co-op p1; versus p1)

The player has Father Ferrer and General Ruggieri (heroes: wounded, not killed), Jakob (if he is alive: NOT protected),
5 pioneers (Labourers), 8 Musketeers and 4 Guardsmen (with the C5 kit), 3 Cuirassiers, 3 Field Cannons, 2 Mortars, a
powder wagon, 500 gold and 300 powder, and a pay convoy up the valley road every half minute (60 gold, 20 powder). The
camp's Barracks, Armoury and Foundry train and research; no halls, farms or new magazines, no Labourers (a siege camp),
and no balloon (the jungle front's rung). NEW (C9): PREPARED CHARGES and the GUNNER'S QUADRANT at the camp's Armoury,
both explained by their NEW card and asked for by Ruggieri at 0:52 (an optional objective).

- PART 1, THE LINES. The pioneers dig the earthworks: twelve palisade sites, four before each gate, pinged. Jakob marks
  the two weak gates at 0:14 (their stop-works were taken out: the guns knock them down sooner). Captain Arruda says the
  valley is here; Hollweg is seen on his wall (or speaks with Ferrer, a prisoner who asked to come). Small sorties come
  out at the diggers (0:42 the north gate, 1:45 the south gate); GROWN: two owls over the camp at 1:15. Nightfall comes
  when the lines are dug (after the first minute at least) or when its clock runs out (4:00 NORMAL).
- PART 2, THE SORTIES. Night. Three sorties, 50 s apart: owls and chains at the west gate, then at dawn Clock Soldiers out
  of the north and south gates, then the heaviest at the west gate with a Pendulum (GROWN: and a Spring Ballista).
  Optional: knock a gate down. With the stop-works only in Jakob's old log (or Jakob lost) Ferrer reads it by the lantern
  and marks the west gate. With d07 `spring` stopped Matthias says the postern is still the masters' (it opens for the
  Crown, never for the city). The sorties are beaten when the third is out and fewer than three of the city's men stand
  outside the wall; at full day (3:20) they go back behind the wall anyway (NO WAITING).
- PART 3, FRESH: THE MINE. Bring two pioneers to the old mine's mouth (pinged); after three seconds every pioneer goes
  down the galleries (Jakob with them). Hold the mouth while they are under the ground (45 s NORMAL, 36 EASY, 54 HARD:
  two waves of the city come at it). They come up under the great spring and blow its tower: every machine in Concórdia
  runs down where it stands (the brake), they come back up the gallery, WON: `siege` close. (No pioneer left: three more
  come from the baggage. The guns may bring the spring down too: the same end.)
- PART 3, GROWN: THE GREAT SORTIE. Hold the camp and the siege park until dusk (3:00 NORMAL). Jakob hears them digging
  under the camp (or the sentries do): the city's diggers come up at the old mine's mouth after 40 s, in the middle of the
  camp, and four waves come out of the gates (the third out of all three at once, with a Spring Ballista). At dusk they go
  back: WON, `siege` held_off.
- LOST: the siege park's magazine blown (any time).

## Co-op and versus

- CO-OP: the second player is the valley (BLUE: Captain Arruda and the militia; d04 `colonists` fought = 7 militia and 2
  ranchers, parley = 3 militia); scripted it holds the south battery.
- VERSUS (and THE CITY, the solo pick): the friend is the city (bound to K7: the arsenal's Heavy Works makes SPRING
  BALLISTAS, its Escapement teaches LONG CHAIN; cogs every 10 s; the plates keep it all wound). Every sortie is his. He
  wins by blowing the siege park's magazine or bringing down Father Ferrer (who is not protected against a person hunting
  him). He loses when the Crown's work is done: FRESH the scripted column sends its pioneers down the mine by itself;
  GROWN dusk comes. A city's win is not how it went: the war map's seal is broken.

## The flags read and set

Read (every one has the canon as its default when missing; d09 `first` has no canon: missing reads GROWN):

| flag | effect |
| --- | --- |
| d09 `first` clockwork / brood | the VERSION: FRESH / GROWN (above) |
| c01 / a02 / a04 `jakob` alive (canon) / lost | Jakob in the column (he can fall: NOT a hero) or not (Ferrer has his log; the opening says so) |
| a04 `stopworks` found (canon) / logged | found and Jakob alive: the north and south gates weak from the start (Jakob's line); else Ferrer reads the log in Part 2: the west gate |
| d07 `spring` running (canon) / stopped | running: Hollweg on his wall (spared: seen, not met); stopped: Hollweg with the column (a hero), the honest masters (Matthias and a few machines) and their POSTERN, the city smaller (its gates and stretches three-quarters as strong, every sortie one Clock Soldier fewer) |
| d07 `honest` many | (with stopped) two more of the masters' machines |
| d04 `colonists` parley (canon) / fought | the valley: a few / many (Arruda's two lines) |
| d10 `jungle` held / thin (GROWN only) | one line of Ferrer's in the opening |

Set:

| flag | values |
| --- | --- |
| `siege` | close (FRESH: the spring blown) / held_off (GROWN: dusk held) |
| `jakob` | alive / lost (lost before, or fallen here) |
| `version` | fresh / grown (the engine keeps it) |

## Balance (tools/sim_campaign_d11.gd; the last runs)

The bot sends the pioneers to dig every earthwork, sets the line and the guns behind the west and north batteries, keeps
Ferrer and Ruggieri at the camp, researches both C9 pieces, trains Musketeers with the pay, fights what comes out of the
gates; FRESH: walks two pioneers to the mine's mouth and holds it; GROWN: holds the camp with a few men at the mouth.

BALANCE_TABLE

## Pictures (docs/shots/d11_siege/, CHECK THE FEEL)

From `xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/sim_campaign_d11.gd -- active
first=clockwork shots=docs/shots/d11_siege` (and first=brood): the camp at the start, the lines being dug, the first probe,
Hollweg on his wall, the lines dug, the night's sortie, the dawn sortie, the third, the mine's mouth, the pioneers under
the ground, the spring falling; GROWN: the owls over the camp, the great sortie, the diggers coming up, the big wave, dusk.
What was looked at is in "Looked at" below.

LOOKED_AT

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

House style as Act 1: an oil painting in the manner of an 18th-century history painting, visible brushwork, 3:2
landscape (cut to 1280 x 853), no text. Save each as `art/campaign/stills/d11_0N.png` and cut it into
`campaign/stills/d11_0N.jpg`.

- d11_01 THE SIEGE LINES. "Oil painting, 18th-century history painting style. Earthwork batteries on a grassy plateau
  with araucaria pines; cannons with purple-coated gun crews fire at the timber and brass walls and the clocktower of a
  town; in front, an old Jesuit priest with white hair and a telescope, and beside him an old journeyman clockmaker
  listening, head cocked. 3:2 landscape, no text." (References: campaign/stills/a04_01.jpg, campaign/stills/d04_04.jpg,
  campaign/stills/a06_02.jpg.)
- d11_02 THE SORTIE. "Oil painting, 18th-century history painting style. At dawn brass clockwork soldiers with red
  shields and a great spring-driven crossbow engine on cog wheels pour out of a town gate onto earthwork siege lines;
  soldiers in purple coats with bayonets meet them in the smoke. 3:2 landscape, no text." (References:
  campaign/stills/a02_03.jpg, campaign/stills/a04_04.jpg.)
- d11_03 HOLLWEG ON THE WALLS. "Oil painting, 18th-century history painting style. On a town's brass and timber wall at
  sunset an old clockmaker in a dark master's coat looks down at siege lines on the plateau below; behind him, very
  still, rows of brass clockwork figures. 3:2 landscape, no text." (References: campaign/hub/nuremberg_hollweg.png,
  campaign/stills/c01_06.jpg.)

## The voice lines

docs/chatterbox_todo.md "d11_siege": 47 spoken lines (Ferrer 24, the King 9, Jakob 5, Ruggieri 4, Hollweg 2, Arruda 2,
Matthias 1) with the feeling of each; the 39 narrator lines ("The Siege Lines", and "The City" for the city's player) and
the four NEW cards can stay as text. Ten lines have a preset in tools/voice_clone/emotions.json (`d11__<id>`). New voice to
design: Jakob old (section 3 of that file); Ferrer is ferrer_ref.wav aged a little.

## What is placeholder

Every line of text (en, pt, es). The three stills (drawn in code). The people's art: Ferrer, Jakob and Hollweg are Act 1's
art; the pioneers plain Labourers. The city's wall is the Crown's palisade and gate pieces in the city's red (the wall of
timber of d04); the siege park's magazine is a Powder Mill, the column's tents Cottages, the old mine's mouth a ruin prop
and stones.

## Claude's choices for the owner

1. THE MAP is d07's city moved east with a wall on its west side and the camp on the plateau west of it (the plan's
   "campaign:concordia_siege"); the stream closes the south, so the only ways in are the gates, the stretches and the
   postern. The old Nuremberg quarter is the city's arsenal now.
2. RUGGIERI COMES SOUTH in both versions (he is the army's general; the plan names "Ruggieri's siege train"). Ferrer is
   the narrator and the hero who must live; Ruggieri is a hero too.
3. JAKOB IS NOT PROTECTED (the plan: "he can fall here: the war's cost"): the sorties and the owls can kill him; FRESH he
   goes down the mine with the pioneers (safe under the ground). `jakob` lost if he dies here or was lost before.
4. THE WEAK GATES are gates at 35% of their strength (their stop-works taken out); Jakob's two at the start, Ferrer's one
   from the log in Part 2. Knocking a gate down is optional: the story's way into the city is the mine.
5. THE MINE takes all the pioneers left once two stand at its mouth for three seconds (the engine's SAPPING moves a tag).
   They come back up after the blast, so Jakob lives through it.
6. THE GREAT SPRING'S TOWER has 6,000 health: the mine's work, not the guns'. If the guns bring it down anyway (FRESH, after
   breaking in), it is the same end: the city braked, `siege` close.
7. THE CITY RUNS DOWN when its spring falls: THE BRAKE on the city's team (d07's), the "crippled, not taken" of the plan.
8. GROWN's PART 3 is a fight to dusk with the city's DIGGERS coming up in the camp: "the galleries are the city's now"
   made into something to do (have men at the mouth), not only a line.
9. THE PAY CONVOY (60 gold and 20 powder every 30 s): a siege lasts; without it the bot ran out of gold in Part 1 and lost
   the great sortie.
10. NO BALLOON in d11 whichever front comes first (the story's deny): C8 stays the jungle's rung (Act 2's choice 14).
11. THE CITY IS BOUND TO K7 (Act 2's choice 15) as a second rung of the same mission: `BOUND_MORE` in roster_ladder.py;
    the city may not build new towers, presses or mainsprings (the plates keep it wound: wind every 4 s).
12. THE POSTERN with d07 `spring` stopped belongs to the honest masters, an ally: it opens for the Crown and stays shut to
    the city. With running it is the city's.
13. THE DIAMOND'S LOCK (owner question 9): d11 needs d10 only when the swarm was chosen first: a conditional need, an
    engine key. Missing d09 `first` reads as GROWN (no canon: the plan's lean was the swarm first).
14. THE CITY'S PLAYER (solo pick and versus) wins by the siege park's magazine or by Ferrer, and loses when the Crown's
    scripted work is done (FRESH: its pioneers go down by themselves at Part 3; GROWN: dusk).
15. THE CO-OP SEAT is the valley (Arruda), not the honest masters: the masters come only with `spring` stopped, and a seat
    must always be there; the masters are scripted (they hold their postern).
16. HOLLWEG'S HUB LINES after d11: on his wall "the city was not afraid" (running), or his confession (stopped).
17. FERRER'S REPORT is the telling (the owner's answer to question 3): "I wrote to Rome that ...".

## Looked at (CHECK THE FEEL)

See "Pictures" above.

## What is left

- The owner's texts, stills and voices; Jakob old to design.
- d10_jungle (built at the same time on its own branch): when both merge, d10's own conditional need (d10 waits for d11
  when the city was chosen first) uses the same key; the war map's "d10 / d11 planned" check is already tolerant.
- The heir's practice and the act's close (after both fronts) are later steps.

## Tests run

TESTS_RUN
